# DRIVERLOG iOS — ESTADO ACTUAL

> **Fuente de verdad portable de este repo** (`driverlog-rutauy`). Se pega al inicio de cada
> sesión en la Mac. Se REESCRIBE en cada cierre de jornada de trabajo (ver PROTOCOLO al pie).
> Lo que deja de ser cierto se borra de "Dónde estoy parado hoy", no se acumula.
>
> **Última actualización:** 03/09/2026

## REGLA DE TRABAJO (29/09) Y FRENTE ACTUAL

- **Un frente a la vez, hasta cerrarlo.** Todo hallazgo nuevo se anota en la cola (1-2 líneas:
  qué es, dónde, gravedad estimada) y **no se trabaja**, salvo: (1) bloquea el cierre del frente
  actual; (2) daño activo o riesgo inmediato de pérdida. Si hay duda, se le pregunta a Claudio.
  (Texto completo en `CLAUDE.md`, sección Reglas.)
- **Frente actual:** _(sin definir — fijarlo al abrir la próxima sesión)_
- **Cola:**
  - `.claude/PANORAMA.md`: ya sincronizado con la copia Android desde Windows (034bff7), pero
    la "Corrección 16/09" que trae es falsa. Verificado 29/09 en la Mac: `app-kilometros-completa`
    (GitHub) ES el repo Android — `main` = Kotlin + `:shared` (HEAD 56e485c), `dev-rebuild-core`
    = JS/Capacitor legacy (rama huérfana, sin historia común con `main`); no hay redirect y
    `claudio3964/cot_devapp_kilometros-completa-android-koltin` no existe en GitHub (probable
    nombre de la carpeta local en Windows). Gravedad baja (docs), pero confunde en cada sesión.
    Corregir en ambas copias.

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
3. **PANORAMA.md** (paso agregado 29/09, mismo texto que el repo Android): si la sesión
   cambió algo que el otro cliente necesita saber para no divergir (RPCs nuevas o
   modificadas, reglas de negocio, forma de `data`/`travels`/`guards`, decisiones de flujo,
   cambios en `:shared` o en cómo iOS lo consume), agregá una entrada fechada con qué cambió
   y qué implica para el otro lado. Si no, no se agrega. Cambios internos de una sola
   plataforma van solo en este archivo.
4. **Compilar** (`xcodebuild`, ver `CLAUDE.md` sección Build) antes del commit.
5. **Commit** del/los `.md` junto con el código de la sesión. El md viaja CON el código.
6. Si esta sesión editó `.claude/PANORAMA.md` → propagar el mismo cambio a la copia que vive
   en el repo Android (commit y push en cada repo por separado) antes de cerrar. Ver nota al
   pie de PANORAMA.md.

**Regla de oro:** si abrís una sesión nueva acá y este archivo no refleja la realidad, el
protocolo falló. Este es la fuente de verdad portable de este repo.
