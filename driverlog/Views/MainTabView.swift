import SwiftUI

struct AppMainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            ViajesListView()
                .tabItem {
                    Label("Viajes", systemImage: "bus.fill")
                }
            
            GuardiasListView()
                .tabItem {
                    Label("Guardias", systemImage: "lock.fill")
                }
            
            HistorialPantallaView()
                .tabItem {
                    Label("Historial", systemImage: "calendar")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AppMainTabView()
}
