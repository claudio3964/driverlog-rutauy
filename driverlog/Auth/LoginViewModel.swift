import Foundation
import Observation
import sharedKit

// Espejo de LoginScreen.kt (Android) -- mismos textos, misma validación de PIN, mismo criterio
// de habilitado del botón. Dos divergencias deliberadas de Android, documentadas en los
// comentarios de cada rama de `ingresar()`: ErrorServidor con texto propio (decisión explícita,
// no es un "mismo que Android" -- ver más abajo) y el placeholder de enrolamiento (la pantalla
// de activación real todavía no existe en iOS).
//
// SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor a nivel de proyecto -- esta clase y sus métodos ya
// corren en el main actor sin anotación explícita.
@Observable
final class LoginViewModel {
    var legajo: String = ""
    var pin: String = ""
    var verificando: Bool = false
    var errorMsg: String? = nil
    // `intentos_restantes`, no `intentos` -- el servidor ya manda el conteo correcto, no hace
    // falta hardcodear el umbral (5) del lado del cliente. Ver nota de cola: LoginScreen.kt de
    // Android hoy muestra "Intento N de 5" con `intentos` + un "5" hardcodeado, en vez de usar
    // `intentosRestantes` que el DTO ya le da -- queda anotado para corregir ahí también.
    var intentosRestantes: Int32? = nil
    var mostrarPlaceholderEnrolamiento: Bool = false

    // Todavía no existe una implementación real de ChoferAuthApi (ver PANORAMA.md, pendiente de
    // :app) -- se usa el Fake siempre por ahora. Cuando exista la real, este `let` pasa a
    // recibirse por constructor en vez de crearse acá.
    private let fakeApi = FakeChoferAuthApi(escenario: .ok, delayMs: 400)

    private let deviceIdStore: DeviceIdStore

    init(deviceIdStore: DeviceIdStore = .shared) {
        self.deviceIdStore = deviceIdStore
    }

    // Mismo criterio que el botón de LoginScreen.kt: `legajo.isNotBlank() && pin.length == 6 && !verificando`.
    var puedeIngresar: Bool {
        !legajo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pin.count == 6 && !verificando
    }

    // Mismo que LoginScreen.kt: `onValueChange = { legajo = it; errorMsg = null }`.
    func actualizarLegajo(_ nuevoValor: String) {
        legajo = nuevoValor
        errorMsg = nil
    }

    // Mismo filtro y mismo efecto que LoginScreen.kt:
    // `onValueChange = { if (it.length <= 6 && it.all(Char::isDigit)) { pin = it; errorMsg = null } }`.
    //
    // Se llama desde un `.onChange(of: pin)` en la vista, no desde el `set` de un Binding
    // custom -- con SecureField, un Binding(get:set:) que devuelve algo distinto de lo tecleado
    // (acá, truncado a 6) no sincroniza de vuelta el buffer interno del campo seguro de forma
    // confiable: el campo seguía aceptando teclas de más (bug encontrado en el simulador,
    // llegó a 21 dígitos) aunque el binding ya devolviera un valor truncado. `.onChange` corrige
    // el modelo DESPUÉS de que SwiftUI ya escribió el valor crudo -- hay un round-trip de más,
    // pero es lo que realmente queda sincronizado con SecureField.
    func sanearPin(_ valorCrudo: String) {
        let saneado = String(valorCrudo.filter(\.isNumber).prefix(6))
        if saneado != pin {
            pin = saneado
        }
        errorMsg = nil
    }

    /// Devuelve `true` si el login fue exitoso (caller navega al Dashboard). La sesión (`sesion`
    /// del caso `.ok`) queda solo en memoria por ahora -- no se persiste ni se guarda ningún
    /// token, a propósito (pendiente de la implementación real).
    func ingresar() async -> Bool {
        guard puedeIngresar else { return false }
        verificando = true
        errorMsg = nil
        intentosRestantes = nil
        defer { verificando = false }

        let legajoLimpio = legajo.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let resultado = try await fakeApi.loginChofer(
                legajo: legajoLimpio,
                deviceId: deviceIdStore.deviceId,
                pin: pin
            )
            switch onEnum(of: resultado) {
            case .ok:
                return true
            case .pinNoConfigurado(_):
                // Android navega a la pantalla real de activación (onIrAActivacion) -- todavía
                // no existe en iOS, se muestra el placeholder pedido en su lugar.
                mostrarPlaceholderEnrolamiento = true
            case .credencialesInvalidas(let c):
                errorMsg = "Legajo o PIN incorrectos."
                intentosRestantes = c.intentosRestantes?.int32Value
            case .bloqueado(_):
                errorMsg = "Contactá a tu supervisor."
            case .cuentaPausada(_):
                errorMsg = "Tu cuenta está pausada. Contactá a tu supervisor."
            case .errorServidor(_):
                // Decisión explícita (no espejo de Android): a diferencia de Android --que
                // colapsa un 500 real en el mismo `else` que un 401 genérico, ver
                // SupabaseService.kt-- iOS distingue ErrorServidor a propósito con su propio
                // texto, porque el contrato de :shared ya lo expone como un caso separado.
                errorMsg = "Hubo un problema del servidor. Probá de nuevo en unos minutos."
            case .errorRed(_):
                errorMsg = "Sin conexión. Verificá tu internet e intentá de nuevo."
            }
        } catch {
            errorMsg = "Sin conexión. Verificá tu internet e intentá de nuevo."
        }
        return false
    }

    // Botón "¿Primera vez? Activá tu cuenta" -- mismo destino que PinNoConfigurado (ver arriba).
    func mostrarPlaceholderActivacion() {
        mostrarPlaceholderEnrolamiento = true
    }

    #if DEBUG
    func aplicarEscenarioDebug(_ escenario: ChoferAuthEscenario) {
        fakeApi.escenario = escenario
    }
    #endif
}
