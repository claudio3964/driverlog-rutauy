import Foundation

// Saneo de lo que tipea el chofer en login y activación, en un solo lugar para que las dos
// pantallas no diverjan. Cada regla replica lo que hace el servidor (o la pantalla Android),
// sin agregar validaciones propias: el servidor sigue siendo quien decide.
enum NormalizacionAuth {
    // Forma canónica de `choferes.legajo`: trim + mayúsculas. Mismo que `normalizarLegajo` de
    // ViajeRepositoy.kt y que login-chofer/activar-chofer (`trim().toUpperCase()`).
    static func legajo(_ crudo: String) -> String {
        crudo.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    // Solo dígitos, máximo 6. Mismo filtro que LoginScreen.kt/ActivacionScreen.kt
    // (`it.length <= 6 && it.all(Char::isDigit)`), aplicado como saneo y no como rechazo de la
    // tecla (ver el comentario de SecureField en LoginView.swift). `isASCII` además de
    // `isNumber`: un dígito arábigo-índico o de ancho completo pasa `isNumber` pero el servidor
    // exige `^\d{6}$`.
    static let largoPin = 6

    static func pin(_ crudo: String) -> String {
        String(crudo.filter { $0.isASCII && $0.isNumber }.prefix(largoPin))
    }

    // Código de enrolamiento: exactamente lo que hace activar-chofer (index.ts:113) y nada más
    // -- `codigo.toUpperCase().replace(/[^A-Z0-9]/g, '')`. Así "ab3d-efgh", "AB3D EFGH" y
    // "AB3DEFGH" son el mismo código. Es válido si quedan 8 caracteres (index.ts:114).
    static let largoCodigo = 8

    static func codigoEnrolamiento(_ crudo: String) -> String {
        String(crudo.uppercased().filter { $0.isASCII && ($0.isLetter || $0.isNumber) })
    }
}
