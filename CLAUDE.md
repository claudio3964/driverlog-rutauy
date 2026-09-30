# DriverLog iOS — Instrucciones para Claude Code

## Idioma
Todo en español: respuestas, documentación (`.claude/*.md`), mensajes de commit y comentarios
nuevos. Los identificadores de código siguen la convención existente (mezcla de español del
dominio — `Viaje`, `Guardia`, `Jornada` — con nombres Swift/SwiftUI en inglés).

## Leer siempre al iniciar sesión
- .claude/PANORAMA.md — orquestación multi-repo (leer ANTES que nada; regla de secuencia:
  `:shared` → Android núcleo → panel → iOS puro). Nota: es una copia del que vive en el repo
  Android — puede desincronizarse si se edita solo de un lado; si hay dudas sobre cuál es la
  versión vigente, preguntar antes de asumir. Protocolo de propagación: ver nota al pie del
  propio PANORAMA.md.
- .claude/Estado_actual.md — única fuente de verdad del estado de ESTE repo (qué se hizo,
  dónde se quedó, próximos pasos, frente actual). No crear otra copia en la raíz ni en ningún
  otro lugar. Se reescribe al cerrar cada sesión (protocolo al pie del archivo).
- El contexto de negocio completo (RUTAUY_CONTEXT.md, PLAN_DESARROLLO_KOTLIN.md) vive en los
  otros repos, no en este. Si hace falta ese detalle, pedírselo al usuario.

## Rutas clave de este repo (iOS Swift/SwiftUI)
- App entry: driverlog/driverlogApp.swift
- Views: driverlog/Views/ (MainTabView, DashboardView, HistorialView, GuardiasListView,
  ViajesListView, NuevaGuardiaView, NuevoViajeView, DeviceApprovalView)
- Models: driverlog/Models/ (Viaje, Guardia, Jornada, Mensaje) — SwiftData
- ContentView.swift: prueba manual/POC del puente a sharedKit (botón que invoca
  `sharedKit.LaudoCalculator.shared.calcular(...)`) — no es una pantalla real de la app
- sharedKit.xcframework: referenciado en el proyecto Xcode vía path relativo
  `../app-kilometros-completa/shared/build/XCFrameworks/debug` — asume que este repo y
  `app-kilometros-completa` son carpetas hermanas en el filesystem (`~/Developer/` en la Mac
  de trabajo). Es un build artifact (`build/`), nunca se commitea a ningún repo — hay que
  regenerarlo local en cada máquina/sesión antes de compilar `driverlog.xcodeproj` si no
  existe o quedó viejo:
  ```
  cd ../app-kilometros-completa
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"  # si `java -version` falla
  ./gradlew :shared:assembleSharedKitDebugXCFramework
  ```
  Escribe en `shared/build/XCFrameworks/debug/sharedKit.xcframework`, que es exactamente
  donde Xcode lo espera — no hace falta copiar nada. (Task hermana `assembleSharedKitReleaseXCFramework`
  para release; `assembleSharedKitXCFramework` genera ambas variantes.)
- Branch activo: main

## Stack
SwiftUI + SwiftData + `sharedKit` (framework KMP generado desde `:shared` del repo Android).
El puente Kotlin→Swift ya está probado y funcionando (`LaudoCalculator` invocado desde
Swift con mapeo de tipos nulables Kotlin↔Swift, ej. `Long?` → `KotlinLong`).

## Build
```bash
# Regenerar sharedKit primero si hace falta (ver arriba), después:
xcodebuild -project driverlog.xcodeproj -scheme driverlog \
  -destination 'generic/platform=iOS Simulator' build
```

## Entorno
Se trabaja en una Mac prestada (no del usuario) — repos movidos a `~/Developer/` para evitar
el conflicto con iCloud Desktop sync. El repo trae `xcuserdata` de otro usuario
(`tamaraperezricardo`) — es ruido del entorno compartido, no asumir que es del usuario ni
limpiarlo sin que lo pida.

## Reglas
- **Un frente a la vez, hasta cerrarlo (regla del 29/09, misma que el repo Android).** Todo
  hallazgo nuevo se anota en la cola de `.claude/Estado_actual.md` (1-2 líneas: qué es, dónde,
  gravedad estimada) y **NO se trabaja**, salvo dos excepciones: (1) bloquea el cierre del
  frente actual; (2) daño activo o riesgo inmediato de pérdida (datos rotos en producción,
  código en un solo lugar, agujero explotándose). Si hay duda, se le pregunta a Claudio antes
  de desviarse. "Es rápido" no es excepción. El frente actual está al principio de
  `Estado_actual.md`.
- **Protocolo de cierre:** el del pie de `.claude/Estado_actual.md`. Incluye, antes del commit
  final, este paso (29/09): **"PANORAMA.md: si la sesión cambió algo que el otro cliente
  necesita saber para no divergir (RPCs nuevas o modificadas, reglas de negocio, forma de
  `data`/`travels`/`guards`, decisiones de flujo, cambios en `:shared` o en cómo iOS lo
  consume), agregá una entrada fechada con qué cambió y qué implica para el otro lado. Si no,
  no se agrega. Cambios internos de una sola plataforma van solo en `Estado_actual.md`."**
- Siempre leer el archivo antes de modificarlo
- Compilar (`xcodebuild ... build`, ver sección Build) antes de commit — con el
  `sharedKit.xcframework` regenerado si hubo cambios en `:shared`
- No mezclar archivos de este repo con los de `app-kilometros-completa` o
  `cot_devapp_kilometros-completa-android-koltin` en el mismo commit — commits separados en
  cada repo, aunque sean parte del mismo frente de trabajo
- `:shared` es la fuente de verdad para lógica de negocio (cálculo de laudo, validaciones,
  etc.) — no duplicar esa lógica en Swift. Si una pantalla necesita algo que todavía no está
  portado a `:shared`, ese es el frente a levantar primero (ver regla de secuencia en
  PANORAMA.md), no resolverlo con Swift nativo como atajo
- Convención de commits: prefijo tipo (`feat:`, `fix:`, `docs:`, …) + descripción en español.
  Commits que conectan código Swift a un tipo/función de `:shared`: mensaje detallado, no un
  one-liner — misma convención que rige los ports a `:shared` del lado Android. Cuerpo con qué
  tipo/función de `:shared` se consumió y en qué pantallas, decisiones de mapeo Kotlin→Swift
  no triviales (nulables → `KotlinLong`/`KotlinInt`, `List` → `[Any]`, companion/`shared`,
  sealed classes, `suspend` → async/completion handler), qué lógica Swift quedó como legacy
  sin borrar y por qué, resultado de la prueba con cifras reales (no "funciona"), y cualquier
  hipótesis descartada en el camino documentada ahí, no solo en un comment de código.
