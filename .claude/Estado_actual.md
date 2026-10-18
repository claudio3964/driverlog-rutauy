# DRIVERLOG iOS — ESTADO ACTUAL

> **Fuente de verdad portable de este repo** (`driverlog-rutauy`). Se pega al inicio de cada
> sesión en la Mac. Se REESCRIBE en cada cierre de jornada de trabajo (ver PROTOCOLO al pie).
> Lo que deja de ser cierto se borra de "Dónde estoy parado hoy", no se acumula.
>
> **Última actualización:** 15/10/2026

## REGLA DE TRABAJO (29/09) Y FRENTE ACTUAL

- **Un frente a la vez, hasta cerrarlo.** Todo hallazgo nuevo se anota en la cola (1-2 líneas:
  qué es, dónde, gravedad estimada) y **no se trabaja**, salvo: (1) bloquea el cierre del frente
  actual; (2) daño activo o riesgo inmediato de pérdida. Si hay duda, se le pregunta a Claudio.
  (Texto completo en `CLAUDE.md`, sección Reglas.)
- **Frente cerrado (17/10):** `DashboardView` → `LaudoCalculator` de `sharedKit`, mergeado a
  `main` (PR #1, `2d610f8`). **PLACEHOLDERS INTENCIONALES (no tocarlos sueltos):**
  `DashboardView.jornadaDeMuestra`, el banner "EN CURSO" fijo (`eventoEnCurso = "Viaje"`) y la
  lista `eventos` fija. Se resuelven en el frente **"jornada real"**, después de la auth real.
- **Frente actual: auth real iOS** (rama `feat/ios-auth-real`; `:shared` en
  `feat/shared-auth-contrato` del repo Android). Hecho al 17/10, **sin ninguna llamada real**:
  bundle id `com.driverlog.app.ios`; contrato en `:shared` (mapeo puro por `code` y status,
  perfil nullable, `SesionStore` + `SesionChofer` completa con legajo/perfil/
  `refreshExpiraAtMs`); `KtorChoferAuthApi` (Ktor 2.3.12, motor Darwin solo en `iosMain`);
  `SupabaseConfig` desde `Config/Info.plist` (solo URL + publishable key);
  `KeychainSesionStore` (un ítem, `AfterFirstUnlockThisDeviceOnly`) que se limpia en el primer
  arranque tras reinstalar (el device_id no se toca).
  **`ActivacionView` validada con el fake (17/10, `82cd237`):** código con guiones (normalizado
  como `activar-chofer`), PIN + confirmación, activar → login automático → sesión completa en
  Keychain → app; errores separados (PIN inválido / credenciales genérico / servidor / red);
  entradas desde "¿Primera vez?" y desde un 409 `PIN_NOT_SET` con el legajo cargado. El login
  también guarda la sesión en Keychain. Recorrido a mano de Claudio OK en: "¿Primera vez?" con
  legajo cargado, PIN no configurado → activación, activación OK/OK, credenciales inválidas,
  OK + login con error de red (vuelve al login con aviso), código de 7 caracteres con el botón
  apagado. El resto de los escenarios (PIN inválido, error de servidor/red en la activación,
  PIN distintos) verificado solo por código en el simulador, no a mano.
  **Próximo paso, BLOQUEADO hasta tener un legajo de prueba iOS** (enrolado desde el panel
  con su código): reemplazar `FakeChoferAuthApi` por `KtorChoferAuthApi(config:
  SupabaseConfig.desdeInfoPlist())` en `LoginViewModel` y `ActivacionViewModel`, y probar
  activación + login reales. Refresh / `X-Chofer-Token` para `/rest/v1/*` llega con
  "jornada real".
- **Cola:**
  - **PENDIENTE en Windows, antes de mergear `feat/shared-auth-contrato` (repo Android):**
    `:shared:testAndroidHostTest` y `:app:assembleDebug`. En la Mac no hay Android SDK; la
    rama agrega `ktor-client-core` 2.3.12 como `api` en `commonMain`, que entra al classpath
    de `:app` aunque no lo use. Gravedad: bloquea el merge de esa rama.
  - **Para cuando se conecte `NuevoViajeView` (no se hace ahora):** reemplazar el toggle
    `esViajeDirecto` (`driverlog/Views/NuevoViajeView.swift:15` y `:62`) por la lista de tipos
    de servicio, idealmente expuesta desde `:shared` para que las dos plataformas usen la
    misma — Android hoy la tiene propia (`TIPOS_SERVICIO`, `NuevoViajeScreen.kt:97`). Igual
    con las ciudades: los pickers de origen/destino (`NuevoViajeView.swift:29-41`) tienen
    4 hardcodeadas, Android tiene su propia `BASES` (`NuevoViajeScreen.kt:92`). Gravedad:
    baja hoy (la pantalla solo hace `print`), bloqueante para conectarla — un booleano no
    alcanza para que `LaudoCalculator` decida tome y cese / acoplado.
  - **Laudo y viático: NO exponer `8.0122` / `455.26` como constantes en `:shared`** (corrige
    lo anotado el 13/10). Replicar a Android: leer la tabla `configuracion` de Supabase
    (`SupabaseService.getConfiguracion()`, claves `precio_km_conductor` y `viatico_comida`) y
    usar los valores fijos **solo como fallback** si no vienen (`ViajeRepositoy.kt:1381` y
    `:1753`: `config["precio_km_conductor"] ?: 8.0122`, `config["viatico_comida"] ?: 455.26`).
    Hoy Swift pasa los dos valores fijos en `DashboardView.calcularTotales` y
    `ContentView.probarCalculator`. Depende de tener red real (después de la auth real);
    gravedad: baja mientras la jornada sea de muestra.
  - **Requisito del frente "jornada real": manejar la edición de un viaje desde el panel**
    (tipo, hora, coche) y reprogramar lo que dependa de la hora (activación, GPS). Android
    tiene ese hueco (`MensajesPollingWorker` no tiene rama para editar un viaje) — **no
    copiarlo** (ver PANORAMA 13/10 noche).
  - **Para el frente "jornada real": formato de números consistente en el Dashboard.** Hoy la
    lista de eventos usa punto ("42.5 km", texto fijo en `eventos`) y el resumen usa coma
    ("262,5", `Text` con `specifier`, que formatea con el locale). Gravedad: baja, cosmética;
    se resuelve al armar `eventos` desde la jornada real con un único formateador.
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

**15/10/2026 — rama `feat/ios-legajo-dashboard`, con `origin/main` de este repo mergeado
(trae las entradas de PANORAMA del 12/10 noche y 13/10 noche).** Sin cambios de Swift en esta
sesión.

- **`sharedKit.xcframework`:** `app-kilometros-completa` pasado a `main` (`706a369`, al día con
  `origin/main`; `fix/semi-alias` ya no existe en el remoto, el alias `SEMI` → `SEMIDIRECTO`
  está en `main` desde `ac1f215`). Entre `ac1f215` y `706a369` no cambió nada en `shared/`, así
  que el framework regenerado es el mismo del 13/10 (`BUILD SUCCESSFUL`, sin recompilar
  `:shared`). Build de `driverlog` para simulador: `BUILD SUCCEEDED`.
- **Dashboard verificado de nuevo en simulador (iPhone 17 Pro):** `calcularTotales(de:
  jornadaDeMuestra)` → **262.5 km / $2103.20** (220 de viaje + 42,5 de tome y cese por `"SEMI"`;
  0 viáticos). Verificado con un `print` temporal en `driverlogApp.init()`, revertido antes del
  commit; no se recorrió la pantalla a mano.
- **Login:** legajo canónico al enviar y `SesionChoferDto.legajo` como fuente de la sesión
  (`52b0fcf`). Sin probar contra el servidor real: sesión solo en memoria y contra
  `FakeChoferAuthApi` (lo resuelve el próximo frente).
- **Tipos de servicio en Swift:** no hay ninguna lista ni comparación literal — la lista y el
  alias viven solo en `:shared`.

**Entorno de esta Mac:** no hay Java en el PATH ni Android Studio; para Gradle se usó
`JAVA_HOME=~/Developer/jdk/jdk-21.0.12.1+1/Contents/Home`.

---

## PRÓXIMOS PASOS

1. **Esperar la confirmación de Claudio** para abrir PR / mergear
   `feat/ios-legajo-dashboard` a `main`. No se hace sin ella.
2. **Frente auth real:** `ChoferAuthApi` con Ktor en `:shared` contra Supabase (en el repo
   Android, commits separados), regenerar el xcframework y reemplazar `FakeChoferAuthApi` en
   `driverlog/Auth/`.
3. **Después, frente "jornada real":** reemplazar los placeholders del Dashboard
   (`jornadaDeMuestra`, banner "EN CURSO", `eventos`), laudo y viático desde `configuracion`
   con fallback (ver cola), y la edición de viaje del panel (ver cola).
4. **Antes de implementar viajes, guardias, mensajes o cierre de jornada en iOS, leer los
   "Para iOS" de `PANORAMA.md`** (entradas del 30/09 al 13/10). Lo que más cambia respecto de
   lo que iOS tiene hoy: `TransicionesViaje` y `TransicionesGuardia` de `:shared` en vez de
   reglas propias (`resultadoCancelacionPanel`, no `cancelablePorPanel`, que ya no existe);
   `cancelar_viaje` con `fuente` / `asignacionId` (`Models/Mensaje.swift`); ids
   `ASG-<mensaje_id>-<ORI>`; guardias con estado `programada`, `inicioMs` y `asignacionId`;
   jornadas con `data.deleted = true`; y los hallazgos de Android del 11/10, 12/10 y 13/10 que
   no hay que copiar.
5. Si se conecta otra pantalla a un tipo de `:shared`, seguir la convención de commit
   detallado del `CLAUDE.md` de este repo.

---

## CHANGELOG

- **15/10/2026** — Merge de `origin/main` (PANORAMA 12/10 noche y 13/10 noche);
  `app-kilometros-completa` a `main` (`706a369`), xcframework regenerado, build y Dashboard
  (262.5 km / $2103.20) verificados. Cola: sale el alias SEMI (ya en `main` de Android);
  laudo/viático pasa a "leer `configuracion` con fallback, como Android" en vez de constantes
  en `:shared`; entra la edición de viaje como requisito de "jornada real". Placeholders del
  Dashboard marcados como intencionales. Próximo frente: auth real.
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
