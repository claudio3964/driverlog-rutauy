import Foundation
import Observation
import sharedKit

// Qué ChoferAuthApi usan el login y la activación: el fake de :shared (escenarios de debug) o
// el real (KtorChoferAuthApi contra las Edge Functions de Supabase).
//
// Default (decisión 17/10): Fake en el simulador, Real en un iPhone -- así la primera llamada
// real sale del iPhone y no de una prueba en el simulador. En DEBUG hay un toggle Fake/Real en
// el menú de debug del login y de la activación; la elección queda en UserDefaults (se borra
// al desinstalar). En Release siempre Real, sin toggle.
//
// Al pasar a Real se borra la sesión del Keychain: una sesión guardada en modo Fake tiene
// tokens inventados ("fake-access-token-…") que el servidor rechazaría.
@Observable
final class ProveedorAuth {
    enum Modo: String {
        case fake
        case real
    }

    static let shared = ProveedorAuth()

    private(set) var modo: Modo

    // nil si falta o es inválida la config del Info.plist (SupabaseConfig.desdeInfoPlist):
    // en ese caso el modo Real muestra un error en vez de caer al fake en silencio.
    private let real: ChoferAuthApi?

    private let defaults: UserDefaults
    private let store: SesionStore
    private static let claveModo = "proveedorAuthModo"

    static let mensajeSinConfig = "Falta la configuración del servidor (Info.plist). Avisale a soporte."

    init(
        defaults: UserDefaults = .standard,
        store: SesionStore = KeychainSesionStore.shared,
        config: SupabaseConfig? = SupabaseConfig.desdeInfoPlist()
    ) {
        self.defaults = defaults
        self.store = store
        self.real = config.map { KtorChoferAuthApi(config: $0) }
        #if DEBUG
        self.modo = defaults.string(forKey: Self.claveModo).flatMap(Modo.init(rawValue:)) ?? Self.modoPorDefecto
        #else
        self.modo = .real
        #endif
    }

    static var modoPorDefecto: Modo {
        #if targetEnvironment(simulator)
        .fake
        #else
        .real
        #endif
    }

    // La API a usar: el fake que trae cada pantalla (con su escenario de debug) o la real.
    // nil = modo Real sin config válida (ver mensajeSinConfig).
    func api(fake: FakeChoferAuthApi) -> ChoferAuthApi? {
        modo == .fake ? fake : real
    }

    #if DEBUG
    func cambiar(a nuevo: Modo) {
        guard nuevo != modo else { return }
        if nuevo == .real {
            store.borrar()
        }
        modo = nuevo
        defaults.set(nuevo.rawValue, forKey: Self.claveModo)
    }
    #endif
}
