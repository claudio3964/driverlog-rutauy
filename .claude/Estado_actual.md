# DRIVERLOG iOS — ESTADO ACTUAL

> **Fuente de verdad portable de este repo** (`driverlog-rutauy`). Se pega al inicio de cada
> sesión en la Mac. Se REESCRIBE en cada cierre de jornada de trabajo (ver PROTOCOLO al pie).
> Lo que deja de ser cierto se borra de "Dónde estoy parado hoy", no se acumula.
>
> **Última actualización:** 03/09/2026

---

## SNAPSHOT

- **Qué es:** app iOS nativa (SwiftUI + SwiftData) para choferes COT, contraparte de la app
  Android real de producción (`app-kilometros-completa`, repo Kotlin).
- **Stack:** SwiftUI, SwiftData, `sharedKit` (framework KMP generado desde `:shared` del repo
  Android — hoy expone al menos `LaudoCalculator`, más lo que se vaya portando ahí).
- **Fase:** exploratoria / puente. Views existentes en `driverlog/Views/`: `MainTabView`,
  `DashboardView`, `HistorialView`, `GuardiasListView`, `ViajesListView`, `NuevaGuardiaView`,
  `NuevoViajeView`, `DeviceApprovalView`. No confirmado todavía cuáles están conectadas a
  datos reales de Supabase vs. son solo UI — verificar al retomar.
- **Entorno:** se trabaja en una Mac prestada, repos movidos a `~/Developer/` para evitar
  conflicto con iCloud Desktop sync. El proyecto Xcode espera al repo Android/`:shared` como
  carpeta hermana con el nombre exacto `app-kilometros-completa` (path relativo hardcodeado en
  el `.pbxproj`: `../app-kilometros-completa/shared/build/XCFrameworks/debug`) — si el
  checkout local tiene otro nombre de carpeta, el build de Xcode no encuentra el
  `.xcframework`.

---

## DÓNDE ESTOY PARADO HOY

**03/09/2026 — puente Kotlin↔Swift confirmado funcionando.** `ContentView.swift` tiene un
POC (botón "Probar LaudoCalculator") que instancia `sharedKit.Viaje` / `sharedKit.JornadaCompleta`
y llama a `LaudoCalculator.calcular()` real, con el mapeo de nulables ya resuelto (`Long?` →
`KotlinLong`, etc.) — confirma que el `.xcframework` generado del lado Android se consume bien
desde Swift. Esto se hizo trabajando con otra IA (más lento y laborioso que con Claude Code).
Este `Estado_actual.md` y el `CLAUDE.md` del repo son la primera vez que este lado tiene ese
soporte — no hay sesiones previas de Claude Code acá, así que no hay CHANGELOG todavía.

**Pendiente inmediato:** hay pantallas nuevas hechas con la otra IA que todavía NO están
subidas a este repo. El usuario quiere que se revisen (misma línea de trabajo que el resto del
proyecto) antes de pushearlas. Al retomar la sesión en la Mac, pedir ese código si no llegó por
otra vía (chat, rama aparte, etc. — ver conversación de la sesión Windows del 03/09).

---

## PRÓXIMOS PASOS

1. Recibir y revisar las pantallas nuevas pendientes de subir (ver arriba) antes de pushearlas.
2. Confirmar contra `.claude/PANORAMA.md` si ya corresponde avanzar UI real conectada a
   `:shared`, o si sigue siendo prioridad portar más superficie a `:shared` primero (regla de
   secuencia del PANORAMA).
3. Si se conecta una pantalla real a un tipo de `:shared`, seguir la convención de commit
   detallado del `CLAUDE.md` de este repo (qué tipo se consumió, mapeos no triviales).

---

## ⚠️ PROTOCOLO DE CIERRE DE JORNADA DE TRABAJO (LEER SIEMPRE)

Al terminar cada sesión de edición de código en este repo, ANTES de cerrar:
1. **REESCRIBIR** "Dónde estoy parado hoy" y "Próximos pasos" — borrar lo que ya no es
   cierto, no acumular.
2. Si se agregó una entrada de sesión que vale la pena preservar en detalle, empezar acá
   mismo una sección de CHANGELOG (no existe todavía — crearla la primera vez que haga falta).
3. Si cambió algo que afecta a los otros repos (Android, panel, `:shared`) → dejarlo anotado
   acá Y considerar si corresponde tocar `.claude/PANORAMA.md`.
4. Si esta sesión editó `.claude/PANORAMA.md` → propagar el mismo cambio a la copia que vive
   en `app-kilometros-completa` (Android) antes de cerrar. Ver nota al pie de PANORAMA.md.
5. **Commit** del/los `.md` junto con el código de la sesión. El md viaja CON el código.

**Regla de oro:** si abrís una sesión nueva acá y este archivo no refleja la realidad, el
protocolo falló. Este es la fuente de verdad portable de este repo.
