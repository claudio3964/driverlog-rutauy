import SwiftUI

@main
struct driverlogApp: App {
    // Login real (ver driverlog/Auth/) antes que nada -- reemplaza el gate hardcodeado que
    // había acá. DeviceApprovalView queda sin usar por ahora (era demo de un flujo de
    // aprobación de dispositivo distinto al login, no se borró por si se retoma).
    @State private var estaLogueado: Bool = false

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
                LoginView {
                    estaLogueado = true
                }
            }
        }
    }
}
