import SwiftUI

#if DEBUG
// Toggle Fake / Real del menú de debug (login y activación). Pasar a Real borra la sesión del
// Keychain (ProveedorAuth.cambiar). En Real se avisa que las llamadas van a producción.
struct SelectorModoAuthDebug: View {
    @Bindable var proveedor: ProveedorAuth = .shared

    var body: some View {
        VStack(spacing: 4) {
            Picker("Modo (debug)", selection: Binding(
                get: { proveedor.modo },
                set: { proveedor.cambiar(a: $0) }
            )) {
                Text("Fake").tag(ProveedorAuth.Modo.fake)
                Text("Real").tag(ProveedorAuth.Modo.real)
            }
            .pickerStyle(.segmented)
            if proveedor.modo == .real {
                Text("Real: las llamadas van a Supabase de producción")
                    .font(.system(size: 11))
                    .foregroundColor(.orange)
            }
        }
    }
}
#endif
