import SwiftUI
import sharedKit

// Espejo de ActivacionScreen.kt (Android) -- ver ActivacionViewModel.swift para el flujo y en
// qué se aparta a propósito de Android (guiones en el código, errores separados).
struct ActivacionView: View {
    @State private var viewModel: ActivacionViewModel
    var onActivado: (String) -> Void
    // (legajo, aviso para mostrar en el login)
    var onVolverALogin: (String, String?) -> Void

    #if DEBUG
    @State private var escenarioActivar: ChoferAuthEscenario = .ok
    @State private var escenarioLoginPosterior: ChoferAuthEscenario = .ok
    #endif

    init(
        legajoInicial: String = "",
        onActivado: @escaping (String) -> Void,
        onVolverALogin: @escaping (String, String?) -> Void
    ) {
        _viewModel = State(initialValue: ActivacionViewModel(legajoInicial: legajoInicial))
        self.onActivado = onActivado
        self.onVolverALogin = onVolverALogin
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                #if DEBUG
                selectorEscenariosDebug
                #endif

                VStack(spacing: 8) {
                    Text("Activá tu cuenta")
                        .font(.system(size: 26, weight: .bold))
                    Text("Usá el código que te dio tu supervisor")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                .padding(.bottom, 32)

                TextField("", text: Binding(
                    get: { viewModel.legajo },
                    set: { viewModel.actualizarLegajo($0) }
                ), prompt: Text("Legajo").foregroundColor(Color(.secondaryLabel)))
                .campoLogin()
                .disabled(viewModel.procesando)
                .accessibilityLabel("Legajo")
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)

                // Acepta guiones, espacios y minúsculas: se normaliza al mandar, igual que el
                // servidor. Sin tope de 8 al tipear (ese es el hueco de Android).
                TextField("", text: Binding(
                    get: { viewModel.codigo },
                    set: { viewModel.actualizarCodigo($0) }
                ), prompt: Text("Código de activación").foregroundColor(Color(.secondaryLabel)))
                .campoLogin()
                .disabled(viewModel.procesando)
                .accessibilityLabel("Código de activación")
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .keyboardType(.asciiCapable)
                .padding(.top, 12)

                Text("8 letras o números, con o sin guion")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)

                // Binding directo + saneo en .onChange, mismo motivo que el PIN del login
                // (SecureField no resincroniza bien con un Binding(get:set:) que trunca).
                SecureField("", text: $viewModel.pin, prompt: Text("PIN nuevo (6 dígitos)").foregroundColor(Color(.secondaryLabel)))
                    .campoLogin()
                    .keyboardType(.numberPad)
                    .disabled(viewModel.procesando)
                    .accessibilityLabel("PIN nuevo")
                    .padding(.top, 12)
                    .onChange(of: viewModel.pin) { _, nuevo in viewModel.sanearPin(nuevo) }

                SecureField("", text: $viewModel.pinConfirmacion, prompt: Text("Repetí el PIN").foregroundColor(Color(.secondaryLabel)))
                    .campoLogin()
                    .keyboardType(.numberPad)
                    .disabled(viewModel.procesando)
                    .accessibilityLabel("Repetí el PIN")
                    .padding(.top, 12)
                    .onChange(of: viewModel.pinConfirmacion) { _, nuevo in viewModel.sanearConfirmacion(nuevo) }

                if viewModel.pinesNoCoinciden {
                    Text("Los PIN no coinciden.")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }

                if let errorMsg = viewModel.errorMsg {
                    Text(errorMsg)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Button {
                    Task {
                        switch await viewModel.activar() {
                        case .activadoYLogueado(let legajo):
                            onActivado(legajo)
                        case .activadoSinSesion(let legajo):
                            onVolverALogin(legajo, "Cuenta activada. Ingresá con tu legajo y el PIN nuevo.")
                        case .sigueEnPantalla:
                            break
                        }
                    }
                } label: {
                    if viewModel.procesando {
                        HStack(spacing: 8) {
                            ProgressView().tint(.white)
                            Text("Activando…").font(.system(size: 16))
                        }
                    } else {
                        Text("Activar cuenta").font(.system(size: 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.puedeActivar ? Color.accentColor : Color.accentColor.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!viewModel.puedeActivar)
                .padding(.top, 24)

                Button {
                    onVolverALogin(viewModel.legajoCanonico, nil)
                } label: {
                    Text("← Volver a iniciar sesión")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .disabled(viewModel.procesando)
                .padding(.top, 12)
            }
            .padding(32)
        }
    }

    #if DEBUG
    // Dos menús: qué responde activar-chofer y qué responde el login-chofer que se hace
    // enseguida después de una activación OK (cada uno con su instancia del fake).
    private var selectorEscenariosDebug: some View {
        VStack(spacing: 4) {
            Picker("Activación (debug)", selection: $escenarioActivar) {
                Text("Activación: OK").tag(ChoferAuthEscenario.ok)
                Text("Activación: PIN inválido").tag(ChoferAuthEscenario.pinInvalido)
                Text("Activación: credenciales inválidas").tag(ChoferAuthEscenario.credencialesInvalidasSinIntentos)
                Text("Activación: error de servidor").tag(ChoferAuthEscenario.errorServidor)
                Text("Activación: error de red").tag(ChoferAuthEscenario.errorRed)
            }
            Picker("Login posterior (debug)", selection: $escenarioLoginPosterior) {
                Text("Login posterior: OK").tag(ChoferAuthEscenario.ok)
                Text("Login posterior: error de red").tag(ChoferAuthEscenario.errorRed)
                Text("Login posterior: error de servidor").tag(ChoferAuthEscenario.errorServidor)
                Text("Login posterior: credenciales inválidas").tag(ChoferAuthEscenario.credencialesInvalidasSinIntentos)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: escenarioActivar) { _, _ in aplicarDebug() }
        .onChange(of: escenarioLoginPosterior) { _, _ in aplicarDebug() }
    }

    private func aplicarDebug() {
        viewModel.aplicarEscenariosDebug(activar: escenarioActivar, loginPosterior: escenarioLoginPosterior)
    }
    #endif
}

#Preview {
    ActivacionView(legajoInicial: "ABC4112", onActivado: { _ in }, onVolverALogin: { _, _ in })
}
