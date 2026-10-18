import SwiftUI

@main
struct driverlogApp: App {
    // Login real (ver driverlog/Auth/) antes que nada -- reemplaza el gate hardcodeado que
    // había acá. DeviceApprovalView queda sin usar por ahora (era demo de un flujo de
    // aprobación de dispositivo distinto al login, no se borró por si se retoma).
    @State private var estaLogueado: Bool = false

    // Login <-> activación, igual que PantallaAuth de MainActivity.kt. El legajo viaja entre
    // las dos pantallas para no hacerlo tipear de nuevo; el aviso es para volver al login
    // después de una activación que no pudo loguear sola.
    private enum PantallaAuth: Equatable {
        case login(legajo: String, aviso: String?)
        case activacion(legajo: String)
    }
    @State private var pantallaAuth: PantallaAuth = .login(legajo: "", aviso: nil)

    init() {
        // Antes de cualquier lectura de la sesión: si es el primer arranque tras instalar,
        // borra la sesión que el Keychain haya conservado de una instalación anterior
        // (el device_id no se toca). Ver KeychainSesionStore.limpiarSiEsInstalacionNueva.
        KeychainSesionStore.shared.limpiarSiEsInstalacionNueva()
    }

    var body: some Scene {
        WindowGroup {
            if estaLogueado {
                AppMainTabView()
            } else {
                switch pantallaAuth {
                case .login(let legajo, let aviso):
                    LoginView(
                        legajoInicial: legajo,
                        aviso: aviso,
                        onLoginSuccess: { estaLogueado = true },
                        onIrAActivacion: { pantallaAuth = .activacion(legajo: $0) }
                    )
                case .activacion(let legajo):
                    ActivacionView(
                        legajoInicial: legajo,
                        onActivado: { _ in estaLogueado = true },
                        onVolverALogin: { pantallaAuth = .login(legajo: $0, aviso: $1) }
                    )
                }
            }
        }
    }
}
