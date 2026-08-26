import SwiftUI

struct HistorialPantallaView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Resumen Hoy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen jornada")
                            .font(.headline)
                        
                        HStack {
                            VStack { Text("Km viajes"); Text("0,0").bold() }
                            Spacer()
                            VStack { Text("Guardias"); Text("0,0").bold() }
                            Spacer()
                            VStack { Text("Tome/Cese"); Text("0,0").bold() }
                            Spacer()
                            VStack { Text("Viáticos"); Text("0").bold() }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        HStack {
                            Text("Total: 0,0 km").bold()
                            Spacer()
                            Text("$ 0,00").bold().foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Historial")
        }
    }
}
