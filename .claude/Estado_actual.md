# DRIVERLOG iOS — ESTADO ACTUAL

> **Fuente de verdad portable de este repo** (`driverlog-rutauy`). Se pega al inicio de cada
> sesión en la Mac. Se REESCRIBE en cada cierre de jornada de trabajo (ver PROTOCOLO al pie).
> Lo que deja de ser cierto se borra de "Dónde estoy parado hoy", no se acumula.
>
> **Última actualización:** 13/10/2026

## REGLA DE TRABAJO (29/09) Y FRENTE ACTUAL

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
  - **El alias `SEMI` → `SEMIDIRECTO` todavía no está en `main` de `app-kilometros-completa`**
    (al 13/10 vive solo en `fix/semi-alias`, `04ea909`; `origin/main` es `434a059`). PANORAMA
    11/10 y 12/10 decían "no arreglar solo de un lado" y que faltaba decidir si se corrige en
    el panel o en `:shared`: esa rama lo corrige en `:shared`. Si se regenera el xcframework
    desde `main` sin ese merge, `jornadaDeMuestra` (tipo `"SEMI"`) pierde el tome y cese y el
    Dashboard vuelve a 220.0 km / $1762.68. Gravedad: media, hasta que la rama se mergee.
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
  (`52b0fcf`). Con esto el frente del legajo queda cerrado en los tres lados: servidor y
  Android ya lo estaban desde el 04/10 (PANORAMA: `CHECK choferes_legajo_canonico`,
  `login-chofer` v17 y `activar-chofer` v14 normalizan, el 200 de `login-chofer` trae
  `legajo`). Sin probar contra el servidor real: la sesión de iOS sigue solo en memoria y
  contra `FakeChoferAuthApi`.
- **Dashboard:** totales desde `LaudoCalculator` (`ff38f9c`), con la jornada de muestra en
  `tipoServicio: "SEMI"` (decisión de Claudio, 13/10). Muestra **262.5 km / $2103.20**
  (220 de viaje + 42,5 de tome y cese; 0 viáticos por ser un viaje en curso). Verificado
  ejecutando el código de `DashboardView` en el simulador, no recorriendo la pantalla a mano.
- **Tipos de servicio en Swift:** no hay ninguna lista ni comparación literal — la lista y el
  alias viven solo en `:shared`.

**`main` local y la rama están al día con `origin/main` (`4aedff5`, 13/10).** Se leyeron las
entradas de `PANORAMA.md` del 04/10 al 12/10. Lo que piden para iOS y ya está: regenerar el
xcframework, correr los tests de `:shared` en iOS, y el legajo canónico en el login. Lo demás
es para cuando se implemente cada cosa (ver Próximos pasos, punto 4).

**Entorno de esta Mac:** no hay Java en el PATH ni Android Studio; para Gradle se usó
`JAVA_HOME=~/Developer/jdk/jdk-21.0.12.1+1/Contents/Home`.

---

## PRÓXIMOS PASOS

1. Decidir qué se hace con `feat/ios-legajo-dashboard` (PR / merge a `main`) — pusheada a
   `origin` el 13/10, con `origin/main` ya mergeado adentro.
2. Cerrar el frente actual: jornada real en el Dashboard en vez de `jornadaDeMuestra`. Antes,
   confirmar contra `.claude/PANORAMA.md` de dónde sale esa jornada (regla de secuencia:
   primero `:shared`).
3. Con el próximo cambio en `:shared`: exponer laudo y viático (ver cola) y regenerar el
   xcframework.
4. **Antes de implementar viajes, guardias, mensajes o cierre de jornada en iOS, leer los
   "Para iOS" de `PANORAMA.md`** (entradas del 30/09 al 12/10). Lo que más cambia respecto de
   lo que iOS tiene hoy: `TransicionesViaje` y `TransicionesGuardia` de `:shared` en vez de
   reglas propias (`resultadoCancelacionPanel`, no `cancelablePorPanel`, que ya no existe);
   `cancelar_viaje` con `fuente` / `asignacionId` (`Models/Mensaje.swift`); ids
   `ASG-<mensaje_id>-<ORI>`; guardias con estado `programada`, `inicioMs` y `asignacionId`;
   jornadas con `data.deleted = true`; y los hallazgos de Android del 11/10 y 12/10 que no hay
   que copiar.
5. Si se conecta otra pantalla a un tipo de `:shared`, seguir la convención de commit
   detallado del `CLAUDE.md` de este repo.

---

## CHANGELOG

- **13/10/2026** — Legajo canónico en el login de iOS (`52b0fcf`); totales del Dashboard
  desde `LaudoCalculator` de `sharedKit` (`ff38f9c`); cola: tipos de servicio y ciudades de
  `NuevoViajeView` desde `:shared` (`3abb003`), laudo y viático desde `:shared`. Detalle de
  mapeos y cifras en el cuerpo de `ff38f9c`. `origin/main` (18 commits de `PANORAMA.md`,
  04/10 al 12/10) mergeado en la rama.

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
6. Si esta sesión agregó una entrada fechada a `.claude/PANORAMA.md` → **agregar esa misma
   entrada fechada** a la copia que vive en el repo Android (commit aparte en cada repo, push)
   antes de cerrar. **Sin pisar su redacción:** nunca copiar el archivo entero encima del
   otro. Cada copia habla de "este repo" y "el otro repo" desde su lado, y esa diferencia es
   correcta (corregido 04/10).

**Regla de oro:** si abrís una sesión nueva acá y este archivo no refleja la realidad, el
protocolo falló. Este es la fuente de verdad portable de este repo.
