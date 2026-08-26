import SwiftUI

struct ViajesListView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("No hay viajes registrados")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                }
                .padding()
            }
            .navigationTitle("Viajes")
        }
    }
}

#Preview {
    ViajesListView()
}
