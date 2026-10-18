import Foundation
import Observation
import sharedKit

// Espejo de ActivacionScreen.kt (Android) sin sus huecos (PANORAMA 17/10):
// - el código acepta guiones/espacios/minúsculas (Android lo corta en 8 caracteres y no deja
//   escribir "ABCD-EFGH"); se normaliza igual que el servidor, nada más;
// - un 400 sin `code` y un 500 no se muestran como "PIN inválido" ni como "código inválido":
//   el mapeo de :shared ya separa PinInvalido / CredencialesInvalidas / ErrorServidor / ErrorRed.
//
// Flujo (igual que Android): activar-chofer -> si Ok, login-chofer enseguida con el mismo PIN
// (en memoria) -> sesión guardada -> app. Si la activación salió bien pero el login no, se
// vuelve al login con el legajo cargado y un aviso: la cuenta ya quedó activada.
//
// Fake o real según ProveedorAuth (Fake por defecto en el simulador, Real en un iPhone). Dos
// instancias del fake, una por llamada, para poder probar en debug "activa bien pero el login
// posterior falla" -- con una sola, el mismo escenario rige para las dos llamadas. En modo Real
// las dos llamadas van a la misma KtorChoferAuthApi.
@Observable
final class ActivacionViewModel {
    enum Resultado {
        case activadoYLogueado(legajo: String)
        case activadoSinSesion(legajo: String)
        case sigueEnPantalla
    }

    var legajo: String
    var codigo: String = ""
    var pin: String = ""
    var pinConfirmacion: String = ""
    var procesando: Bool = false
    var errorMsg: String? = nil

    private let fakeActivar = FakeChoferAuthApi(escenario: .ok, delayMs: 400)
    private let fakeLogin = FakeChoferAuthApi(escenario: .ok, delayMs: 400)
    private let deviceIdStore: DeviceIdStore
    private let proveedor: ProveedorAuth

    init(legajoInicial: String = "", deviceIdStore: DeviceIdStore = .shared, proveedor: ProveedorAuth = .shared) {
        self.legajo = legajoInicial
        self.deviceIdStore = deviceIdStore
        self.proveedor = proveedor
    }

    var legajoCanonico: String { NormalizacionAuth.legajo(legajo) }
    var codigoNormalizado: String { NormalizacionAuth.codigoEnrolamiento(codigo) }

    var codigoCompleto: Bool { codigoNormalizado.count == NormalizacionAuth.largoCodigo }
    var pinCompleto: Bool { pin.count == NormalizacionAuth.largoPin }
    var confirmacionCompleta: Bool { pinConfirmacion.count == NormalizacionAuth.largoPin }
    // Solo se avisa cuando ya están los dos completos: mientras tipea la confirmación no.
    var pinesNoCoinciden: Bool { pinCompleto && confirmacionCompleta && pin != pinConfirmacion }

    var puedeActivar: Bool {
        !legajoCanonico.isEmpty && codigoCompleto && pinCompleto && confirmacionCompleta
            && pin == pinConfirmacion && !procesando
    }

    func actualizarLegajo(_ v: String) { legajo = v; errorMsg = nil }
    func actualizarCodigo(_ v: String) { codigo = v; errorMsg = nil }

    // Mismo patrón que LoginViewModel.sanearPin: se llama desde `.onChange` del SecureField.
    func sanearPin(_ crudo: String) {
        let s = NormalizacionAuth.pin(crudo)
        if s != pin { pin = s }
        errorMsg = nil
    }

    func sanearConfirmacion(_ crudo: String) {
        let s = NormalizacionAuth.pin(crudo)
        if s != pinConfirmacion { pinConfirmacion = s }
        errorMsg = nil
    }

    func activar() async -> Resultado {
        guard puedeActivar else { return .sigueEnPantalla }
        guard let apiActivar = proveedor.api(fake: fakeActivar),
              let apiLogin = proveedor.api(fake: fakeLogin)
        else {
            errorMsg = ProveedorAuth.mensajeSinConfig
            return .sigueEnPantalla
        }
        procesando = true
        errorMsg = nil
        defer { procesando = false }

        let legajoEnviado = legajoCanonico
        let deviceId = deviceIdStore.deviceId
        // El PIN solo vive en estas variables y en el body de las dos llamadas.
        let pinElegido = pin

        let activacion: ActivarChoferResult
        do {
            activacion = try await apiActivar.activarChofer(
                legajo: legajoEnviado,
                codigo: codigoNormalizado,
                deviceId: deviceId,
                pin: pinElegido
            )
        } catch {
            errorMsg = Self.mensajeSinConexion
            return .sigueEnPantalla
        }

        switch onEnum(of: activacion) {
        case .ok:
            break
        case .pinInvalido(let p):
            // El motivo viene del servidor (pinEsTrivial de activar-chofer), sin el prefijo
            // "PIN invalido: " que lo saca el mapeo de :shared. El código NO se consumió.
            errorMsg = "PIN no válido: \(p.motivo)."
            return .sigueEnPantalla
        case .credencialesInvalidas:
            // Genérico a propósito, como el servidor: no distingue legajo inexistente, código
            // vencido/incorrecto ni "ya activado".
            errorMsg = "No se pudo activar. Revisá el legajo y el código; si sigue fallando, pedile un código nuevo a tu supervisor."
            return .sigueEnPantalla
        case .errorServidor:
            errorMsg = Self.mensajeServidor
            return .sigueEnPantalla
        case .errorRed:
            errorMsg = Self.mensajeSinConexion
            return .sigueEnPantalla
        }

        // Activada: login enseguida con el mismo PIN, sin pedírselo de nuevo.
        do {
            let login = try await apiLogin.loginChofer(legajo: legajoEnviado, deviceId: deviceId, pin: pinElegido)
            if case .ok(let ok) = onEnum(of: login) {
                return .activadoYLogueado(legajo: SesionLogin.guardar(ok.sesion, legajoEnviado: legajoEnviado))
            }
        } catch {}
        return .activadoSinSesion(legajo: legajoEnviado)
    }

    static let mensajeSinConexion = "Sin conexión. Verificá tu internet e intentá de nuevo."
    static let mensajeServidor = "Hubo un problema del servidor. Probá de nuevo en unos minutos."

    #if DEBUG
    func aplicarEscenariosDebug(activar: ChoferAuthEscenario, loginPosterior: ChoferAuthEscenario) {
        fakeActivar.escenario = activar
        fakeLogin.escenario = loginPosterior
    }
    #endif
}
