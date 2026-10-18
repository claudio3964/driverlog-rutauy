# DRIVERLOG iOS — ESTADO ACTUAL

> **Fuente de verdad portable de este repo** (`driverlog-rutauy`). Se pega al inicio de cada
> sesión en la Mac. Se REESCRIBE en cada cierre de jornada de trabajo (ver PROTOCOLO al pie).
> Lo que deja de ser cierto se borra de "Dónde estoy parado hoy", no se acumula.
>
> **Última actualización:** 17/10/2026 (cierre de sesión)

## REGLA DE TRABAJO (29/09) Y FRENTE ACTUAL

- **Un frente a la vez, hasta cerrarlo.** Todo hallazgo nuevo se anota en la cola (1-2 líneas:
  qué es, dónde, gravedad estimada) y **no se trabaja**, salvo: (1) bloquea el cierre del frente
  actual; (2) daño activo o riesgo inmediato de pérdida. Si hay duda, se le pregunta a Claudio.
  (Texto completo en `CLAUDE.md`, sección Reglas; ahí también la regla del 17/10 sobre revertir
  código temporal de prueba.)
- **Frente actual: auth real iOS** — rama `feat/ios-auth-real` (este repo) + `:shared` en
  `feat/shared-auth-contrato` (repo Android). Código completo y validado con el fake; **falta
  la primera prueba real, BLOQUEADA** (ver "Dónde estoy parado").
- **Placeholders intencionales del Dashboard (no tocarlos sueltos):**
  `DashboardView.jornadaDeMuestra`, el banner "EN CURSO" fijo (`eventoEnCurso = "Viaje"`) y la
  lista `eventos` fija. Se resuelven en el frente **"jornada real"**, después de la auth real.
- **Cola:**
  - **Frente de diseño pendiente: alta y aprobación de choferes desde el panel.** Hoy el panel
    no da de alta choferes ni genera códigos de enrolamiento (el 9999998 se hizo por SQL con
    claims de admin). Ni Android ni el panel tienen definido el flujo (quién da el alta, cómo se
    entrega el código, si hay aprobación). Sesión de diseño propia; no arrancar suelto.
  - **`ContentView.swift` huérfano:** ninguna vista lo instancia (solo su `#Preview`); era la
    prueba manual del puente a `sharedKit` del 29/09 y tiene `"4112"` y `8.0122`/`455.26`
    hardcodeados. Decidir si se borra o se deja como POC documentada. Gravedad: baja.
  - **Formato de números en el Dashboard (frente "jornada real"):** la lista de eventos usa
    punto ("42.5 km", texto fijo en `eventos`) y el resumen coma ("262,5", `Text` con
    `specifier`, que formatea con el locale). Se resuelve al armar `eventos` desde la jornada
    real con un único formateador. Gravedad: baja, cosmética.
  - **Para cuando se conecte `NuevoViajeView` (no se hace ahora):** reemplazar el toggle
    `esViajeDirecto` (`driverlog/Views/NuevoViajeView.swift:15` y `:62`) por la lista de tipos
    de servicio, idealmente expuesta desde `:shared` para que las dos plataformas usen la
    misma — Android hoy la tiene propia (`TIPOS_SERVICIO`, `NuevoViajeScreen.kt:97`). Igual
    con las ciudades: los pickers de origen/destino (`NuevoViajeView.swift:29-41`) tienen
    4 hardcodeadas, Android tiene su propia `BASES` (`NuevoViajeScreen.kt:92`). Gravedad:
    baja hoy (la pantalla solo hace `print`), bloqueante para conectarla — un booleano no
    alcanza para que `LaudoCalculator` decida tome y cese / acoplado.
  - **Laudo y viático: NO exponer `8.0122` / `455.26` como constantes en `:shared`.** Replicar
    a Android: leer la tabla `configuracion` de Supabase (`SupabaseService.getConfiguracion()`,
    claves `precio_km_conductor` y `viatico_comida`) y usar los valores fijos **solo como
    fallback** (`ViajeRepositoy.kt:1381` y `:1753`). Hoy Swift pasa los dos valores fijos en
    `DashboardView.calcularTotales` y `ContentView.probarCalculator`. Depende de red real
    (frente "jornada real"); gravedad: baja mientras la jornada sea de muestra.
  - **Requisito del frente "jornada real": manejar la edición de un viaje desde el panel**
    (tipo, hora, coche) y reprogramar lo que dependa de la hora (activación, GPS). Android
    tiene ese hueco (`MensajesPollingWorker` no tiene rama para editar un viaje) — **no
    copiarlo** (ver PANORAMA 13/10 noche).
  - `LoginViewModel.legajoSesion` todavía no lo lee nadie (la sesión completa ya está en
    Keychain con el legajo); `jornadaDeMuestra` va con `legajo: ""`. Se resuelve al conectar la
    jornada real. Gravedad: baja.

---

## SNAPSHOT

- **Qué es:** app iOS nativa (SwiftUI + SwiftData) para choferes COT, contraparte de la app
  Android real de producción (`app-kilometros-completa`, repo Kotlin).
- **Stack:** SwiftUI, SwiftData, `sharedKit` (framework KMP generado desde `:shared` del repo
  Android: `LaudoCalculator`, `SolapamientoValidator`, contrato de auth del chofer con
  `KtorChoferAuthApi`, más lo que se vaya portando).
- **Fase:** exploratoria / puente. Bundle id `com.driverlog.app.ios` (desde el 17/10).
  - `driverlog/Auth/`: `LoginView`/`LoginViewModel`, `ActivacionView`/`ActivacionViewModel`,
    `ProveedorAuth` (Fake/Real), `KeychainSesionStore`, `DeviceIdStore`, `SesionLogin`,
    `NormalizacionAuth`, `SupabaseConfig+InfoPlist`. Config en `Config/Info.plist` (URL +
    publishable key; fuera de `driverlog/` porque es un grupo sincronizado).
  - `driverlog/Views/`: `MainTabView`, `DashboardView` (totales desde `LaudoCalculator`, jornada
    de muestra), `HistorialView`, `GuardiasListView`, `ViajesListView`, `NuevaGuardiaView`,
    `NuevoViajeView` (solo `print`), `DeviceApprovalView` (sin usar). Ninguna lee datos reales
    ni usa SwiftData.
- **29/09/2026 — primer build real y primera ejecución en simulador OK.** Puente
  Swift↔`sharedKit` validado en ejecución: `LaudoCalculator` devolvió 220 km × 8,0122 =
  1762,684.
- **Entorno:** Mac prestada, repos en `~/Developer/` (evita iCloud Desktop sync). El proyecto
  Xcode espera al repo Android como carpeta hermana con el nombre exacto
  `app-kilometros-completa` (path relativo en el `.pbxproj`:
  `../app-kilometros-completa/shared/build/XCFrameworks/debug`). Sin Java en el PATH ni
  Android Studio: Gradle con `JAVA_HOME=~/Developer/jdk/jdk-21.0.12.1+1/Contents/Home`. Sin
  Android SDK (no corren `testAndroidHostTest` ni `:app:assembleDebug`). `gh` no instalado (los
  PR se abren desde el navegador).

---

## DÓNDE ESTOY PARADO HOY

**17/10/2026 — cierre.** `feat/ios-auth-real` pusheada; `main` de este repo en `2d610f8`
(merge del PR #1). **Para compilar esta rama, el xcframework tiene que salir de
`feat/shared-auth-contrato`** del repo Android (en `main` de Android todavía no existen
`SesionStore` ni `KtorChoferAuthApi`); el checkout local de Android quedó en esa rama.

- **Auth real iOS — hecho, sin ninguna llamada real a Supabase:**
  - Bundle id `com.driverlog.app.ios` (antes del primer enrolamiento: el Keychain y con él el
    device_id están ligados al bundle id).
  - `:shared` (`feat/shared-auth-contrato`: `42415af`, `132cf32`, `0bebc4b`): mapeo puro
    `mapearLogin/Activar/Refresh` (primero `code`, después status), perfil nullable,
    `SesionStore` + `SesionChofer` completa (tokens, vencimientos, legajo, perfil),
    `KtorChoferAuthApi` (Ktor 2.3.12, Darwin solo en `iosMain`) + `SupabaseConfig`. Tests
    `iosSimulatorArm64Test` 125/125.
  - `KeychainSesionStore`: la sesión completa en un ítem; se borra en el primer arranque tras
    reinstalar (el device_id no). Verificado desinstalando/instalando en el simulador.
  - `ActivacionView`: validada a mano con el fake por Claudio (¿Primera vez? con legajo, PIN
    no configurado → activación, OK/OK, credenciales inválidas, OK + login con error de red,
    código de 7 con el botón apagado); el resto de los escenarios, solo por código.
  - API real conectada (`db8882e`): `ProveedorAuth`, **Fake por defecto en el simulador y Real
    en un iPhone**, toggle en el menú de debug.
- **Legajo de prueba iOS: 9999998** ("TEST IOS BORRAR", Montevideo, efectivo, `cot`), alta y
  código de enrolamiento por SQL (Claudio, SQL Editor). Sin device ni PIN. **El código vence
  el 20/10 a las 22:08**; si vence, se regenera con `generar_codigo_enrolamiento('9999998')`
  desde el SQL Editor con los claims de admin (revoca el anterior). El 9999999 es de Android y
  no se toca.
- **BLOQUEADO — primera prueba real desde el iPhone de pruebas** (iPhone 12, iOS 18.7.8, UDID
  `00008101-000D2C3222C1001E`, puerto Lightning). Está emparejado con esta Mac pero
  `unavailable` (última conexión 12/05); por Wi-Fi no conectó (no se anuncia en la red). **Falta
  un cable USB-C a Lightning** para el primer emparejamiento por cable; después se puede
  marcar "Connect via network" en Xcode. Además falta elegir el Team de firma (Claudio, con su
  Apple ID; `DEVELOPMENT_TEAM` no se toca desde acá).

---

## PRÓXIMOS PASOS

1. **Primera prueba real (cuando haya cable):** conectar el iPhone 12 por cable → Team de
   firma → instalar (arranca en Real) → "¿Primera vez?" → 9999998 + código + PIN no trivial
   → login automático → app. Si el código venció, regenerarlo antes por SQL.
2. **En Windows:** `:shared:testAndroidHostTest` + `:app:assembleDebug` sobre
   `feat/shared-auth-contrato`; si dan bien, mergearla a `main` del repo Android. **Recién
   después, PR de `feat/ios-auth-real`** (depende de esa rama para compilar).
3. **Después, frente "jornada real":** placeholders del Dashboard, refresh + `X-Chofer-Token`
   para `/rest/v1/*`, laudo y viático desde `configuracion` con fallback, edición de viaje del
   panel, formato de números (ver cola).
4. **Antes de implementar viajes, guardias, mensajes o cierre de jornada en iOS, leer los
   "Para iOS" de `PANORAMA.md`** (entradas del 30/09 al 17/10). Lo que más cambia respecto de
   lo que iOS tiene hoy: `TransicionesViaje` y `TransicionesGuardia` de `:shared` en vez de
   reglas propias (`resultadoCancelacionPanel`, no `cancelablePorPanel`); `cancelar_viaje` con
   `fuente` / `asignacionId` (`Models/Mensaje.swift`); ids `ASG-<mensaje_id>-<ORI>`; guardias
   con estado `programada`, `inicioMs` y `asignacionId`; jornadas con `data.deleted = true`; y
   los hallazgos de Android del 11/10 al 13/10 que no hay que copiar.
5. Si se conecta otra pantalla a un tipo de `:shared`, seguir la convención de commit
   detallado del `CLAUDE.md` de este repo.

---

## CHANGELOG

- **17/10/2026** — PR #1 mergeado (Dashboard + legajo canónico, `2d610f8`). Frente auth real
  iOS: bundle id `com.driverlog.app.ios` (`19cffa2`); contrato de auth en `:shared` (mapeos,
  `SesionStore`, `SesionChofer` completa, `KtorChoferAuthApi` + tests MockEngine; rama Android
  `feat/shared-auth-contrato`); `KeychainSesionStore` + `SupabaseConfig` desde `Info.plist`
  (`80c5c5a`) con limpieza al reinstalar (`80aacf9`); `ActivacionView` con el fake, validada a
  mano (`82cd237`); API real conectada, Fake en simulador / Real en iPhone (`db8882e`). Legajo
  de prueba 9999998 dado de alta por SQL. Regla nueva en `CLAUDE.md`: revertir código temporal
  por archivo puntual o `git stash`, con `status`/`diff` antes (`fd7c073`). PANORAMA: 4
  hallazgos de Android en su cola, contrato de auth, legajo 9999998. Bloqueado: prueba real en
  el iPhone (falta cable).
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
