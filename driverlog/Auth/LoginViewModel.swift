import Foundation
import Observation
import sharedKit

// Espejo de LoginScreen.kt (Android) -- mismos textos, misma validación de PIN, mismo criterio
// de habilitado del botón. Una divergencia deliberada de Android, documentada en su rama de
// `ingresar()`: ErrorServidor con texto propio (decisión explícita, no es un "mismo que
// Android" -- ver más abajo). PinNoConfigurado lleva a ActivacionView, como Android lleva a
// ActivacionScreen.
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
    // Aviso no-error (ej. "Cuenta activada…" al volver de la activación sin sesión).
    var aviso: String? = nil
    // Legajo de la sesión activa, ya canónico. Fuente: `SesionChoferDto.legajo` (el que devuelve
    // el servidor, dueño.legajo de `choferes`); mientras login-chofer no lo mande (null), cae al
    // que se envió, ya normalizado -- mismo criterio que documenta el DTO en :shared.
    private(set) var legajoSesion: String? = nil

    // Todavía no existe una implementación real de ChoferAuthApi (ver PANORAMA.md, pendiente de
    // :app) -- se usa el Fake siempre por ahora. Cuando exista la real, este `let` pasa a
    // recibirse por constructor en vez de crearse acá.
    private let fakeApi = FakeChoferAuthApi(escenario: .ok, delayMs: 400)

    private let deviceIdStore: DeviceIdStore

    init(legajoInicial: String = "", aviso: String? = nil, deviceIdStore: DeviceIdStore = .shared) {
        self.legajo = legajoInicial
        self.aviso = aviso
        self.deviceIdStore = deviceIdStore
    }

    // Forma canónica del legajo (NormalizacionAuth.legajo: trim + mayúsculas) -- lo tipeado se
    // normaliza antes de mandarlo para que un "abc1" no caiga en la rama
    // device_legajo_mismatch de login-chofer y cuente contra el umbral de bloqueo.
    var legajoCanonico: String {
        NormalizacionAuth.legajo(legajo)
    }

    // Mismo criterio que el botón de LoginScreen.kt: `legajo.isNotBlank() && pin.length == 6 && !verificando`.
    var puedeIngresar: Bool {
        !legajoCanonico.isEmpty && pin.count == 6 && !verificando
    }

    // Mismo que LoginScreen.kt: `onValueChange = { legajo = it; errorMsg = null }`.
    func actualizarLegajo(_ nuevoValor: String) {
        legajo = nuevoValor
        errorMsg = nil
        aviso = nil
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
        let saneado = NormalizacionAuth.pin(valorCrudo)
        if saneado != pin {
            pin = saneado
        }
        errorMsg = nil
    }

    enum Resultado {
        case logueado
        // 409 PIN_NOT_SET: el chofer existe pero nunca activó -> ActivacionView con este legajo.
        case irAActivacion(legajo: String)
        case sigueEnPantalla
    }

    /// `.logueado` -> el caller navega a la app. La sesión del `.ok` se guarda completa en
    /// Keychain (SesionLogin.guardar), igual que tras una activación; el PIN no se guarda.
    func ingresar() async -> Resultado {
        guard puedeIngresar else { return .sigueEnPantalla }
        verificando = true
        errorMsg = nil
        aviso = nil
        intentosRestantes = nil
        defer { verificando = false }

        let legajoEnviado = legajoCanonico
        do {
            let resultado = try await fakeApi.loginChofer(
                legajo: legajoEnviado,
                deviceId: deviceIdStore.deviceId,
                pin: pin
            )
            switch onEnum(of: resultado) {
            case .ok(let ok):
                legajoSesion = SesionLogin.guardar(ok.sesion, legajoEnviado: legajoEnviado)
                return .logueado
            case .pinNoConfigurado(_):
                // Mismo destino que Android (onIrAActivacion), con el legajo ya cargado.
                return .irAActivacion(legajo: legajoEnviado)
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
        return .sigueEnPantalla
    }

    #if DEBUG
    func aplicarEscenarioDebug(_ escenario: ChoferAuthEscenario) {
        fakeApi.escenario = escenario
    }
    #endif
}
