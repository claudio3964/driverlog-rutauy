# DriverLog iOS — Instrucciones para Claude Code

## Leer siempre al iniciar sesión
- .claude/PANORAMA.md — orquestación multi-repo (leer ANTES que nada). Nota: es una copia
  del que vive en el repo Android (`app-kilometros-completa`) — puede desincronizarse si se
  edita solo de un lado; si hay dudas sobre cuál es la versión vigente, preguntar antes de
  asumir. Protocolo de propagación: ver nota al pie del propio PANORAMA.md.
- .claude/Estado_actual.md — fuente de verdad portable de ESTE repo (qué se hizo, dónde se
  quedó, próximos pasos). Se reescribe al cerrar cada sesión (protocolo al pie del archivo).
- El contexto de negocio completo (RUTAUY_CONTEXT.md, PLAN_DESARROLLO_KOTLIN.md) vive en los
  otros dos repos, no en este. Si hace falta ese detalle, pedírselo al usuario.

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
  de trabajo)
- Branch activo: main

## Stack
SwiftUI + SwiftData + `sharedKit` (framework KMP generado desde `:shared` del repo Android).
El puente Kotlin→Swift ya está probado y funcionando (`LaudoCalculator` invocado desde
Swift con mapeo de tipos nulables Kotlin↔Swift, ej. `Long?` → `KotlinLong`).

## Entorno
Se trabaja en una Mac prestada (no del usuario) — repos movidos a `~/Developer/` para evitar
el conflicto con iCloud Desktop sync. El repo trae `xcuserdata` de otro usuario
(`tamaraperezricardo`) — es ruido del entorno compartido, no asumir que es del usuario ni
limpiarlo sin que lo pida.

## Reglas
- Siempre leer el archivo antes de modificarlo
- No mezclar archivos de este repo con los de `app-kilometros-completa` o
  `cot_devapp_kilometros-completa-android-koltin` en el mismo commit
- `:shared` es la fuente de verdad para lógica de negocio (cálculo de laudo, validaciones,
  etc.) — no duplicar esa lógica en Swift. Si una pantalla necesita algo que todavía no está
  portado a `:shared`, ese es el frente a levantar primero (ver regla de secuencia en
  PANORAMA.md), no resolverlo con Swift nativo como atajo
- Commits que conectan código Swift a un tipo/función de `:shared`: mensaje detallado (qué
  tipo de `:shared` se consumió, decisiones de mapeo Kotlin→Swift no triviales), no un
  one-liner — misma convención que rige los ports a `:shared` del lado Android
