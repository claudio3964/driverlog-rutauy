import Foundation
import Security

// Identidad estable de este dispositivo para auth del chofer (login-chofer/activar-chofer/
// refresh-chofer exigen device_id). UUID generado una sola vez y guardado en Keychain, no
// identifierForVendor (cambia si se reinstalan todas las apps del vendor, UUID propio no).
// Keychain (no UserDefaults) porque sobrevive a un borrado/reinstalación de la app -- mismo
// criterio que un ANDROID_ID: tiene que identificar el dispositivo, no la instalación.
final class DeviceIdStore {
    static let shared = DeviceIdStore()

    private let service = "com.driverlog.app.ios.device"
    private let account = "device_id"

    private init() {}

    var deviceId: String {
        if let existente = leer() {
            return existente
        }
        let nuevo = UUID().uuidString
        guardar(nuevo)
        return nuevo
    }

    private func leer() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var resultado: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &resultado)
        guard status == errSecSuccess, let data = resultado as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func guardar(_ valor: String) {
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        // Por si quedó una entrada vieja corrupta -- SecItemAdd falla con errSecDuplicateItem
        // si ya existe una entrada con la misma clase/service/account.
        SecItemDelete(baseQuery as CFDictionary)

        var attributes = baseQuery
        attributes[kSecValueData as String] = Data(valor.utf8)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(attributes as CFDictionary, nil)
    }
}
