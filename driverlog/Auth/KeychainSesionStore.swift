import Foundation
import Security
import sharedKit

// `SesionStore` de :shared sobre Keychain -- equivalente iOS de SesionChoferStore de Android
// (EncryptedSharedPreferences). Guarda la `SesionChofer` completa: tokens, vencimientos, legajo y
// perfil (decisión 17/10: a diferencia de Android, que guarda legajo/perfil en prefs aparte).
//
// Dos ítems genéricos bajo el mismo service:
//   - "sesion": JSON de la sesión completa en un solo ítem, así guardar/leer nunca ven un
//     access token de una sesión con el refresh token (o el legajo) de otra.
//   - "vencida": marca (sin contenido útil) que deja `marcarVencida()` para forzar el login
//     aunque el rechazo del servidor haya pasado en segundo plano.
// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, mismo criterio que DeviceIdStore: se
// puede leer en segundo plano después del primer desbloqueo, y no viaja a otro iPhone por
// backup ni por iCloud (la sesión está atada al device_id de este dispositivo).
//
// NSObject: `SesionStore` llega a Swift como protocolo Objective-C (header de sharedKit).
final class KeychainSesionStore: NSObject, SesionStore {
    static let shared = KeychainSesionStore()

    private let service = "com.driverlog.app.ios.sesion"
    private let cuentaSesion = "sesion"
    private let cuentaVencida = "vencida"

    // Opcionales los que son nullable en `SesionChofer`. Un JSON guardado con un formato
    // anterior (sin legajo) no decodifica y `leer()` da nil: obliga a loguear de nuevo, que es
    // lo correcto (nunca hubo sesiones reales con ese formato).
    private struct SesionGuardada: Codable {
        let accessToken: String
        let refreshToken: String
        let expiraAtMs: Int64
        let refreshExpiraAtMs: Int64?
        let legajo: String
        let nombre: String?
        let base: String?
        let tipo: String?
    }

    private override init() {}

    // MARK: - Reinstalación

    // El Keychain sobrevive a desinstalar la app; UserDefaults no. Si falta la marca, es el
    // primer arranque de esta instalación: se borra cualquier sesión que haya quedado de una
    // instalación anterior (tokens + marca de vencida), para que reinstalar = volver a loguear,
    // igual que en Android. El device_id (DeviceIdStore, otro service) NO se toca: tiene que
    // sobrevivir a la reinstalación porque login-chofer identifica al chofer por él.
    // Se llama una vez al arrancar, antes de cualquier lectura de la sesión (driverlogApp.init).
    private static let claveInstalacionVerificada = "sesionKeychainLimpiadaEnInstalacion"

    func limpiarSiEsInstalacionNueva(defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: Self.claveInstalacionVerificada) else { return }
        borrarItem(cuenta: cuentaSesion)
        borrarItem(cuenta: cuentaVencida)
        defaults.set(true, forKey: Self.claveInstalacionVerificada)
    }

    func guardar(sesion: SesionChofer) {
        let guardada = SesionGuardada(
            accessToken: sesion.accessToken,
            refreshToken: sesion.refreshToken,
            expiraAtMs: sesion.expiraAtMs,
            refreshExpiraAtMs: sesion.refreshExpiraAtMs?.int64Value,
            legajo: sesion.legajo,
            nombre: sesion.nombre,
            base: sesion.base,
            tipo: sesion.tipo
        )
        guard let data = try? JSONEncoder().encode(guardada) else { return }
        escribir(data, cuenta: cuentaSesion)
        borrarItem(cuenta: cuentaVencida)
    }

    func leer() -> SesionChofer? {
        guard
            let data = leerItem(cuenta: cuentaSesion),
            let guardada = try? JSONDecoder().decode(SesionGuardada.self, from: data)
        else { return nil }
        // `Long?` de Kotlin llega a Swift como `KotlinLong?` (boxed), no como `Int64?`.
        return SesionChofer(
            accessToken: guardada.accessToken,
            refreshToken: guardada.refreshToken,
            expiraAtMs: guardada.expiraAtMs,
            refreshExpiraAtMs: guardada.refreshExpiraAtMs.map { KotlinLong(value: $0) },
            legajo: guardada.legajo,
            nombre: guardada.nombre,
            base: guardada.base,
            tipo: guardada.tipo
        )
    }

    func borrar() {
        borrarItem(cuenta: cuentaSesion)
    }

    func marcarVencida() {
        borrarItem(cuenta: cuentaSesion)
        escribir(Data([1]), cuenta: cuentaVencida)
    }

    func estaVencida() -> Bool {
        leerItem(cuenta: cuentaVencida) != nil
    }

    // MARK: - Keychain

    private func consultaBase(cuenta: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: cuenta,
        ]
    }

    private func leerItem(cuenta: String) -> Data? {
        var query = consultaBase(cuenta: cuenta)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var resultado: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &resultado) == errSecSuccess else { return nil }
        return resultado as? Data
    }

    // Borrar + agregar (mismo patrón que DeviceIdStore): SecItemAdd falla con
    // errSecDuplicateItem si el ítem ya existe.
    private func escribir(_ data: Data, cuenta: String) {
        borrarItem(cuenta: cuenta)
        var atributos = consultaBase(cuenta: cuenta)
        atributos[kSecValueData as String] = data
        atributos[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(atributos as CFDictionary, nil)
    }

    private func borrarItem(cuenta: String) {
        SecItemDelete(consultaBase(cuenta: cuenta) as CFDictionary)
    }
}
