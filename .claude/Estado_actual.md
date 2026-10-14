# DRIVERLOG iOS — ESTADO ACTUAL

> **Fuente de verdad portable de este repo** (`driverlog-rutauy`). Se pega al inicio de cada
> sesión en la Mac. Se REESCRIBE en cada cierre de jornada de trabajo (ver PROTOCOLO al pie).
> Lo que deja de ser cierto se borra de "Dónde estoy parado hoy", no se acumula.
>
> **Última actualización:** 13/10/2026

## REGLA DE TRABAJO (29/09) Y FRENTE ACTUAL

- **01/10 — ANTES de la próxima sesión en la Mac: `git pull`.** Desde Windows se commiteó
  `.claude/PANORAMA.md` (entradas 30/09: fase 0 tanda 2 -- RPC de jornada/mensajes exigen
  `X-Chofer-Token`; y 01/10: trigger de `travels` en prod + no replicar el patrón de activación
  de Android). Leer esas dos entradas antes de tocar activación de viajes o mensajes en iOS.
- **Un frente a la vez, hasta cerrarlo.** Todo hallazgo nuevo se anota en la cola (1-2 líneas:
  qué es, dónde, gravedad estimada) y **no se trabaja**, salvo: (1) bloquea el cierre del frente
  actual; (2) daño activo o riesgo inmediato de pérdida. Si hay duda, se le pregunta a Claudio.
  (Texto completo en `CLAUDE.md`, sección Reglas.)
- **Frente actual:** conectar `DashboardView` a `LaudoCalculator` de `sharedKit` — **a medias
  (13/10).** Hecho: "KM Totales", "Monto Est." y el "Acumulado" del banner salen de
  `LaudoCalculator.shared.calcular(...)` y el monto se muestra a 2 decimales. Falta para
  cerrarlo: que la jornada de entrada sea real (hoy es `DashboardView.jornadaDeMuestra`, un
  `sharedKit.JornadaCompleta` fijo armado en Swift) y que el banner "EN CURSO" y la lista
  `eventos` dejen de estar hardcodeados.
- **Cola:**
  - **FRENTE NUEVO, PRIORITARIO — para la próxima sesión en el PC Windows — normalizar
    `legajo` a mayúsculas (decidido 03/10, diagnóstico ya corrido en el repo Android).**
    El servidor (`login-chofer/index.ts:108`, `activar-chofer/index.ts:119`) compara
    `legajo` con igualdad exacta — "TEST01" ≠ "test01" falla, y en `login-chofer` ese
    mismatch cuenta contra el umbral de bloqueo (`UMBRAL_DEVICE_MISMATCH=3`) — afecta a
    Android también, no es solo un problema de iOS. **Resultados del diagnóstico**
    (`supabase/diagnostico/20261003_legajo_case_sensitivity.sql` del repo Android):
    todos los legajos ya canónicos, sin colisiones, sin FKs reales sobre `legajo`;
    existe como columna `text` en 8 tablas (`choferes`, `jornadas`, `viajes`,
    `inconsistencias_cierre`, `inconsistencias_continuidad`, `registro_alertas`,
    `alertas_login_chofer.legajo_objetivo`, `private.backup_jornadas_rotacion_20260917`),
    sin integridad referencial declarada en ninguna. **Decisión:** forma canónica en
    mayúsculas con `CHECK` solo en `choferes` (sin `citext`, sin migración de datos —
    ya están todos canónicos); las Edge Functions normalizan con
    `trim().toUpperCase()`; el alta del panel (`cot-admin-next`) manda el legajo ya en
    mayúsculas. Implementación pendiente (migración + Edge Functions + panel) — ver
    detalle en la cola de `Estado_actual.md` del repo Android. **Lado iOS: hecho el 13/10**
    — `LoginViewModel` manda el legajo canónico (trim + mayúsculas, mismo criterio que
    `normalizarLegajo` de `ViajeRepositoy.kt`) y guarda como legajo de sesión
    `SesionChoferDto.legajo`, con fallback al enviado mientras `login-chofer` lo devuelva
    null. El campo de `LoginView` sigue mostrando lo tipeado tal cual (con
    `.textInputAutocapitalization(.characters)` como sugerencia de teclado); la
    normalización se aplica al enviar. Sigue pendiente todo el lado servidor y panel.
  - Bundle id actual `driverlog.driverlog` (`project.pbxproj`, Debug y Release) → cambiar a
    `com.driverlog.app.ios` antes de firmar para un iPhone real.
  - **Para cuando se conecte `NuevoViajeView` (no se hace ahora):** reemplazar el toggle
    `esViajeDirecto` (`driverlog/Views/NuevoViajeView.swift:15` y `:62`) por la lista de tipos
    de servicio, idealmente expuesta desde `:shared` para que las dos plataformas usen la
    misma — Android hoy la tiene propia (`TIPOS_SERVICIO`, `NuevoViajeScreen.kt:97`). Igual
    con las ciudades: los pickers de origen/destino (`NuevoViajeView.swift:29-41`) tienen
    4 hardcodeadas, Android tiene su propia `BASES` (`NuevoViajeScreen.kt:92`). Gravedad:
    baja hoy (la pantalla solo hace `print`), bloqueante para conectarla — un booleano no
    alcanza para que `LaudoCalculator` decida tome y cese / acoplado.
  - **Prioridad media — exponer laudo y viático desde `:shared`** (constantes públicas, o
    que los defaults de `calcular()` lleguen a Swift) y sacar `8.0122` / `455.26` de
    `DashboardView.calcularTotales` y de `ContentView.probarCalculator`. Hoy `LAUDO_KM` y
    `MONTO_VIATICO` son `private` en `LaudoCalculator.kt` y el header ObjC solo exporta
    `calcular(jornada:laudoKm:montoViatico:)`, así que Swift duplica los dos valores. Se hace
    junto con el próximo cambio en `:shared`.
  - `LoginViewModel.legajoSesion` todavía no lo lee nadie: `jornadaDeMuestra` va con
    `legajo: ""` y `ContentView.swift:77` con `"4112"` hardcodeado. Gravedad: baja, se
    resuelve al conectar la jornada real.

---

## SNAPSHOT

- **Qué es:** app iOS nativa (SwiftUI + SwiftData) para choferes COT, contraparte de la app
  Android real de producción (`app-kilometros-completa`, repo Kotlin).
- **Stack:** SwiftUI, SwiftData, `sharedKit` (framework KMP generado desde `:shared` del repo
  Android — hoy expone al menos `LaudoCalculator`, más lo que se vaya portando ahí).
- **Fase:** exploratoria / puente. Views existentes en `driverlog/Views/`: `MainTabView`,
  `DashboardView`, `HistorialView`, `GuardiasListView`, `ViajesListView`, `NuevaGuardiaView`,
  `NuevoViajeView`, `DeviceApprovalView`. Al 13/10 ninguna lee datos reales: no hay llamadas a
  Supabase ni uso de SwiftData (`@Query` / `modelContext`) en ningún `.swift`. El login
  (`driverlog/Auth/`) usa `FakeChoferAuthApi` de `:shared`; `NuevoViajeView` solo hace `print`.
- **29/09/2026 — primer build real y primera ejecución en simulador OK.** Puente
  Swift↔`sharedKit` validado en ejecución (no solo compilación): `LaudoCalculator` devolvió
  220 km × 8,0122 = 1762,684.
- **Entorno:** se trabaja en una Mac prestada, repos movidos a `~/Developer/` para evitar
  conflicto con iCloud Desktop sync. El proyecto Xcode espera al repo Android/`:shared` como
  carpeta hermana con el nombre exacto `app-kilometros-completa` (path relativo hardcodeado en
  el `.pbxproj`: `../app-kilometros-completa/shared/build/XCFrameworks/debug`) — si el
  checkout local tiene otro nombre de carpeta, el build de Xcode no encuentra el
  `.xcframework`.

---

## DÓNDE ESTOY PARADO HOY

**13/10/2026 — rama local `feat/ios-legajo-dashboard` (desde `main`), sin push.** Compilado
contra el `sharedKit.xcframework` regenerado desde `app-kilometros-completa` en
`fix/semi-alias` (`ac1f215`), que trae el alias `SEMI` → `SEMIDIRECTO` en `LaudoCalculator`.
Tests de `:shared` en `iosSimulatorArm64`: 84 OK, incluido `LaudoTipoSemiTest` (6 casos).

- **Login:** legajo canónico al enviar y `SesionChoferDto.legajo` como fuente de la sesión
  (`52b0fcf`). La sesión sigue solo en memoria y contra `FakeChoferAuthApi`.
- **Dashboard:** totales desde `LaudoCalculator` (`ff38f9c`), con la jornada de muestra en
  `tipoServicio: "SEMI"` (decisión de Claudio, 13/10). Muestra **262.5 km / $2103.20**
  (220 de viaje + 42,5 de tome y cese; 0 viáticos por ser un viaje en curso). Verificado
  ejecutando el código de `DashboardView` en el simulador, no recorriendo la pantalla a mano.
- **Tipos de servicio en Swift:** no hay ninguna lista ni comparación literal — la lista y el
  alias viven solo en `:shared`.

**Sin verificar en esta sesión:** el pendiente del 03/09 sobre pantallas hechas con otra IA
que no estaban subidas al repo. Preguntarle a Claudio si sigue vigente.

**Entorno de esta Mac:** no hay Java en el PATH ni Android Studio; para Gradle se usó
`JAVA_HOME=~/Developer/jdk/jdk-21.0.12.1+1/Contents/Home`.

---

## PRÓXIMOS PASOS

1. Decidir qué se hace con `feat/ios-legajo-dashboard` (push / PR / merge a `main`) — hoy
   existe solo en esta Mac.
2. Cerrar el frente actual: jornada real en el Dashboard en vez de `jornadaDeMuestra`. Antes,
   confirmar contra `.claude/PANORAMA.md` de dónde sale esa jornada (regla de secuencia:
   primero `:shared`).
3. Con el próximo cambio en `:shared`: exponer laudo y viático (ver cola) y regenerar el
   xcframework.
4. Si se conecta otra pantalla a un tipo de `:shared`, seguir la convención de commit
   detallado del `CLAUDE.md` de este repo.

---

## CHANGELOG

- **13/10/2026** — Legajo canónico en el login de iOS (`52b0fcf`); totales del Dashboard
  desde `LaudoCalculator` de `sharedKit` (`ff38f9c`); cola: tipos de servicio y ciudades de
  `NuevoViajeView` desde `:shared` (`3abb003`), laudo y viático desde `:shared`. Detalle de
  mapeos y cifras en el cuerpo de `ff38f9c`.

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
