import Foundation
import sharedKit

// `SupabaseConfig` (de :shared) armado desde Config/Info.plist: claves `SupabaseURL` y
// `SupabasePublishableKey`. Devuelve nil si falta alguna, si la URL no es https, o si la clave
// no es una publishable key (`sb_publishable_…`) -- defensa para que nunca viaje en el binario
// una service_role ni una clave legacy en formato JWT (deshabilitadas desde el 19-20/09).
extension SupabaseConfig {
    static func desdeInfoPlist(_ bundle: Bundle = .main) -> SupabaseConfig? {
        guard
            let url = bundle.object(forInfoDictionaryKey: "SupabaseURL") as? String,
            url.hasPrefix("https://"),
            let clave = bundle.object(forInfoDictionaryKey: "SupabasePublishableKey") as? String,
            clave.hasPrefix("sb_publishable_")
        else { return nil }
        return SupabaseConfig(url: url, publishableKey: clave)
    }
}
