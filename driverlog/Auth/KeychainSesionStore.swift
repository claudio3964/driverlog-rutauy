import Foundation
import Security
import sharedKit

// `SesionStore` de :shared sobre Keychain -- equivalente iOS de SesionChoferStore de Android
// (EncryptedSharedPreferences). Solo tokens + vencimiento (`SesionChofer`); legajo y perfil van
// aparte, como en Android.
//
// Dos ítems genéricos bajo el mismo service:
//   - "sesion": JSON de la sesión completa en un solo ítem, así guardar/leer nunca ven un
//     access token de una sesión con el refresh token de otra.
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

    private struct SesionGuardada: Codable {
        let accessToken: String
        let refreshToken: String
        let expiraAtMs: Int64
    }

    private override init() {}

    func guardar(sesion: SesionChofer) {
        let guardada = SesionGuardada(
            accessToken: sesion.accessToken,
            refreshToken: sesion.refreshToken,
            expiraAtMs: sesion.expiraAtMs
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
        return SesionChofer(
            accessToken: guardada.accessToken,
            refreshToken: guardada.refreshToken,
            expiraAtMs: guardada.expiraAtMs
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
