import SwiftUI

struct NuevaGuardiaView: View {
    var body: some View {
        NavigationStack {
            Form {
                Text("Formulario Nueva Guardia")
            }
            .navigationTitle("Nueva Guardia")
        }
    }
}

#Preview {
    NuevaGuardiaView()
}
