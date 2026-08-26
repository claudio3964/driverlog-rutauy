import SwiftUI

@main
struct driverlogApp: App {
    // Si ponés 'estaAprobado = true' ves la Main Screen (DashboardView)
    // Si ponés 'estaAprobado = false' ves la espera de autorización del Admin
    @State private var estaAprobado: Bool = true

    var body: some Scene {
        WindowGroup {
            if estaAprobado {
               AppMainTabView()
            } else {
                DeviceApprovalView(deviceId: "UUID-TEST-2026-COT") {
                    print("Verificando aprobación...")
                }
            }
        }
    }
}
