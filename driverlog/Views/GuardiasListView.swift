import SwiftUI

struct GuardiasListView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("No hay guardias registradas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                }
                .padding()
            }
            .navigationTitle("Guardias")
        }
    }
}

#Preview {
    GuardiasListView()
}
