import Foundation
import sharedKit

// Qué se hace con un 200 de login-chofer, venga del login o de la activación (que loguea
// enseguida después de activar): arma la `SesionChofer` completa y la guarda en el store.
// Devuelve el legajo de la sesión (canónico: el del servidor o, si no vino, el enviado).
// El PIN no pasa por acá: nunca se guarda.
enum SesionLogin {
    static func guardar(
        _ dto: SesionChoferDto,
        legajoEnviado: String,
        store: SesionStore = KeychainSesionStore.shared,
        ahora: Date = Date()
    ) -> String {
        let ahoraMs = Int64(ahora.timeIntervalSince1970 * 1000)
        let sesion = dto.aSesionChofer(ahoraMs: ahoraMs, legajoEnviado: legajoEnviado)
        store.guardar(sesion: sesion)
        return sesion.legajo
    }
}
