import SwiftUI
import sharedKit

// Espejo de LoginScreen.kt (Android) -- ver LoginViewModel.swift para el detalle de qué texto
// sale de dónde y qué dos casos no tienen equivalente en Android (ErrorServidor, placeholder de
// enrolamiento).
struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    var onLoginSuccess: () -> Void

    #if DEBUG
    @State private var escenarioDebug: ChoferAuthEscenario = .ok
    #endif

    var body: some View {
        VStack(spacing: 0) {
            #if DEBUG
            selectorEscenarioDebug
            #endif

            Spacer()

            VStack(spacing: 8) {
                Text("COT Driver")
                    .font(.system(size: 32, weight: .bold))
                Text("Sistema de registro de kilómetros")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 48)

            // Teclado normal, no numérico: `legajo` es `text` plano en Supabase, sin CHECK de
            // formato, y hay al menos un legajo real alfanumérico en producción (`TEST01`,
            // fixture de test permanente) -- confirmado antes de elegir el teclado, no asumido.
            // Mismo criterio que Android (LoginScreen.kt tampoco restringe el teclado acá).
            //
            // Estilo de campo propio, no .roundedBorder: ese estilo apenas se distingue del
            // fondo en modo oscuro (borde y relleno demasiado sutiles). Título vacío + `prompt:`
            // en vez de pasar el label como título -- así se puede fijar el color del
            // placeholder (si no, toma el gris por defecto de `.placeholderText`, que es el que
            // se veía con poco contraste).
            TextField("", text: Binding(
                get: { viewModel.legajo },
                set: { viewModel.actualizarLegajo($0) }
            ), prompt: Text("Legajo").foregroundColor(Color(.secondaryLabel)))
            .campoLogin()
            .disabled(viewModel.verificando)
            .accessibilityLabel("Legajo")
            .autocorrectionDisabled()
            .textInputAutocapitalization(.characters)

            // Binding directo (no Binding(get:set:) custom como en Legajo): con SecureField,
            // un setter que devuelve un valor truncado no sincroniza el buffer interno del
            // campo de forma confiable (bug real visto en el simulador -- llegaba a 21 dígitos
            // aunque el modelo ya estuviera truncado a 6). El saneo se hace en `.onChange`,
            // después de que el campo ya escribió el valor crudo.
            SecureField("", text: $viewModel.pin, prompt: Text("PIN").foregroundColor(Color(.secondaryLabel)))
                .campoLogin()
                .keyboardType(.numberPad)
                .disabled(viewModel.verificando)
                .accessibilityLabel("PIN")
                .padding(.top, 12)
                .onChange(of: viewModel.pin) { _, nuevoValor in
                    viewModel.sanearPin(nuevoValor)
                }

            if let errorMsg = viewModel.errorMsg {
                Text(errorMsg)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }

            if let intentosRestantes = viewModel.intentosRestantes {
                Text("Te quedan \(intentosRestantes) intentos")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }

            Button {
                Task {
                    if await viewModel.ingresar() {
                        onLoginSuccess()
                    }
                }
            } label: {
                if viewModel.verificando {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Verificando…")
                            .font(.system(size: 16))
                    }
                } else {
                    Text("Ingresar")
                        .font(.system(size: 16))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(!viewModel.puedeIngresar)
            .padding(.top, 24)

            Button {
                viewModel.mostrarPlaceholderActivacion()
            } label: {
                Text("¿Primera vez? Activá tu cuenta")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .disabled(viewModel.verificando)
            .padding(.top, 12)

            Spacer()
        }
        .padding(32)
        .alert("Activación", isPresented: $viewModel.mostrarPlaceholderEnrolamiento) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("enrolamiento: próximo paso")
        }
    }

    #if DEBUG
    private var selectorEscenarioDebug: some View {
        Picker("Escenario (debug)", selection: $escenarioDebug) {
            ForEach(ChoferAuthEscenario.allCases, id: \.self) { escenario in
                Text(nombreDebug(escenario)).tag(escenario)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: escenarioDebug) { _, nuevo in
            viewModel.aplicarEscenarioDebug(nuevo)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func nombreDebug(_ escenario: ChoferAuthEscenario) -> String {
        switch escenario {
        case .ok: "OK"
        case .pinInvalido: "PIN inválido"
        case .credencialesInvalidasSinIntentos: "Credenciales inválidas (sin contador)"
        case .credencialesInvalidasConIntentos: "Credenciales inválidas (con contador)"
        case .pinNoConfigurado: "PIN no configurado"
        case .bloqueado: "Bloqueado"
        case .cuentaPausada: "Cuenta pausada"
        case .errorServidor: "Error de servidor"
        case .errorRed: "Error de red"
        }
    }
    #endif
}

// Fondo + borde con colores semánticos (secondarySystemBackground/separator) -- ninguno
// hardcodeado, los dos se adaptan solos en modo claro/oscuro, a diferencia de .roundedBorder
// (que en modo oscuro casi no se distingue del fondo de la pantalla).
private struct CampoLogin: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private extension View {
    func campoLogin() -> some View { modifier(CampoLogin()) }
}

#Preview {
    LoginView(onLoginSuccess: {})
}
