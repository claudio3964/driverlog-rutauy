import SwiftUI

@main
struct driverlogApp: App {
    // Login real (ver driverlog/Auth/) antes que nada -- reemplaza el gate hardcodeado que
    // había acá. DeviceApprovalView queda sin usar por ahora (era demo de un flujo de
    // aprobación de dispositivo distinto al login, no se borró por si se retoma).
    @State private var estaLogueado: Bool = false

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
