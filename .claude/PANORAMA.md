# PANORAMA — Orquestación COT Driver (multi-repo)

> Se lee ANTES de entrar al `Estado_actual.md` puntual de cada repo, al arrancar cualquier sesión nueva.
> Se actualiza con 2-3 líneas al CERRAR cada sesión, sea cual sea el repo tocado.
> Este documento es solo lectura/registro — no toca código, no rompe nada.
>
> **Este archivo existe en DOS repos** (`app-kilometros-completa` Android, rama `main`, y
> `driverlog-rutauy` iOS) porque no hay carpeta física compartida entre ambos. Si esta sesión
> edita este archivo, ANTES de cerrar hay que propagar el mismo cambio (texto idéntico o resumen
> equivalente) a la copia del otro repo y pushear las dos. Un PANORAMA.md desincronizado es peor
> que no tener PANORAMA.md — ver paso correspondiente en el PROTOCOLO DE CIERRE de cada repo.
>
> **Corrección 29/09 (reemplaza la "Corrección 16/09", que era falsa):** en GitHub hay UN solo
> repo, `claudio3964/app-kilometros-completa`, con dos ramas sin historia común:
> - `main` = Kotlin + `:shared` — núcleo Android, producción (sección 2).
> - `dev-rebuild-core` = JS/Capacitor legacy, rama huérfana (sección 5).
>
> `cot_devapp_kilometros-completa-android-koltin` NO es un repo: es solo el nombre de la carpeta
> local del checkout en el PC Windows (confirmado con `git remote -v` en el PC, que apunta a
> `app-kilometros-completa`). En la Mac la carpeta se llama `app-kilometros-completa`, y ese es
> el nombre que espera el path relativo de `driverlog.xcodeproj`. Verificado también desde la
> Mac: `origin` responde sin redirect y `claudio3964/cot_devapp_…` no existe en GitHub.

## Regla de secuencia (mientras dure el port a KMP)

**`:shared` → Android núcleo (si hay algo bloqueante) → panel → iOS puro**

Motivo: `:shared` es el frente de mayor apalancamiento hoy — cada cosa portada ahí avanza
Android e iOS al mismo tiempo. iOS puro (Swift/UI) tiene poco sentido invertir tiempo
todavía más allá de lo mínimo, porque gran parte de la lógica que necesitaría todavía
no salió de Kotlin compartido.

---

## 1. `:shared` (KMP) — módulo compartido Android/iOS

**Estado (17/08):** `LaudoCalculator` portado a `commonMain`, conectado a la app Android real
(`SharedMappers.kt`, 3 call sites actualizados), 11/11 tests unitarios pasan, `LaudoCalculator.kt`
viejo queda como legacy sin borrar. Primer `.xcframework` generado y conectado al target Xcode
de `driverlog` (Embed & Sign) — todavía sin código Swift que lo consuma.

**Próximo paso:** portar `SolapamientoValidator` a `:shared`.

**Antes de abrir `driverlog.xcodeproj` en cualquier máquina/sesión nueva:** el
`sharedKit.xcframework` es un build artifact de `:shared`, nunca se commitea (ni a este repo
ni al de iOS) — hay que regenerarlo local:
```
cd app-kilometros-completa   # checkout local del repo Android (en Windows la carpeta se llama cot_devapp_kilometros-completa-android-koltin)
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"  # si falta un JDK en PATH
./gradlew :shared:assembleSharedKitDebugXCFramework
```
El proyecto Xcode de `driverlog` espera el resultado en
`../app-kilometros-completa/shared/build/XCFrameworks/debug/sharedKit.xcframework`
(path relativo en `project.pbxproj`, verificado 29/09 — asume que `driverlog` y la carpeta
`app-kilometros-completa` son hermanas) — la task ya lo deja ahí, no requiere copiar nada.
Si el build de Xcode falla con el framework no encontrado o símbolos viejos, esta es la
primera causa a revisar.

**Repos que toca:** `app-kilometros-completa`, rama `main` (PC Windows) + `driverlog` (Mac).

---

## 2. Android — `app-kilometros-completa`, rama `main` (núcleo, producción real)

**Estado:** sin frente activo bloqueante. Últimos frentes cerrados y validados en campo
(fail-safe jornada colgada, borrado real de jornadas, Solapamiento vs. jornadas `deleted`,
refresco reactivo de `MainScreen`).

**Pendiente grande (sesión de diseño propia, no arrancar suelto):** sistema de recálculo de
`totalsSnapshot` para jornadas ya cerradas (motivado por `4112-20260610`).

**Pendientes chicos sueltos:** indicador de color gris al reabrir jornada, timer de 8h no
descuenta tiempo cerrado, identidad firmada del chofer (Auth real), filtro de fecha en
Mensajes del panel, gap de reactividad Home con actividad *programada* (no solo en curso).

---

## 3. iOS — `driverlog` (repo GitHub: `driverlog-rutauy`)

**Estado:** en pausa relativa hasta que `:shared` tenga más superficie portada.
`.xcframework` ya conectado al proyecto Xcode.

**Próximo paso (cuando corresponda):** código Swift real consumiendo tipos de `:shared`
(ej. invocar `LaudoCalculator.calcular()`) para confirmar que el puente Kotlin↔Swift funciona.

**Nota de entorno:** se trabaja en una Mac prestada (no del usuario) — repos movidos a
`~/Developer/` para evitar el conflicto con iCloud Desktop sync.

---

## 4. Panel — `cot-admin-next`

**Estado:** deployado en Netlify (preview), 10 tabs cargando sin errores, sin blockers de
deploy pendientes. Deuda no bloqueante: ~31 errores de lint (`react-hooks/set-state-in-effect`
sobre todo), credenciales Supabase duplicadas en ~13-14 archivos.

**Pendientes (features, no bugs):** tab de historial de actividad del chofer con edición
superadmin, estadísticas globales de la empresa (fase de diseño, definir qué decisiones de
negocio se van a tomar con esos datos primero).

---

## 5. JS/Capacitor legacy — `app-kilometros-completa`, rama `dev-rebuild-core` (huérfana)

**Estado:** app de chofer ya migrada 100% a Kotlin (sección 2) — esta rama queda como legacy,
pero sigue teniendo código real cargado desde `www/index.html` (`ui_registro.js`,
`push_notifications.js`, `sync.js`, `ui_mensajes.js`), mantenido por seguridad aunque no haya
confirmación de uso real en dispositivos hoy. También contiene el panel admin viejo
(`www/admin/index.html`), con corte de dominio decidido hacia `cot-admin-next` pero sin
ejecutar (ver `Estado_actual.md` de esta rama).

**Trabajo reciente (15-16/09):** cierre del bloque de seguridad RLS de Supabase (ver sección
Supabase abajo) — los 4 archivos JS de arriba migrados de acceso directo a la tabla con la anon
key a RPCs `SECURITY DEFINER`, en commits separados de los de la rama `main` (Kotlin).

**Deuda de repo (no de código), limpiada 16/09:** repo git anidado dentro de sí mismo (clon
accidental de mayo, borrado) + carpeta de un experimento abandonado de reescribir la app en
Kotlin/Compose dentro del wrapper Capacitor de este mismo repo, previo a que existiera el repo
Kotlin dedicado (borrada). `RUTAUY_CONTEXT.md`/`PLAN_DESARROLLO_KOTLIN.md`/`CLAUDE.md` —
documentos de arranque que el `CLAUDE.md` del repo Kotlin espera encontrar acá — existían en
disco pero nunca se habían commiteado; commiteados 16/09.

**Repos que toca:** solo esta rama (PC Windows).

---

## Supabase

No es un frente aparte — es infraestructura compartida. El trabajo sobre RLS/RPCs queda
registrado dentro del frente que lo dispara (Android, panel, o `:shared`), no en una cola propia.

---

## Log de sesiones (agregar abajo, no reescribir lo de arriba)

- 03/09 — desalineamiento del espejo resuelto: la copia de este archivo en `driverlog` decía
  ser espejo de este, pero este archivo todavía no existía acá (creado recién en el commit
  `06a8662`, cruzado con una sesión en `driverlog` que investigaba el mismo día). Ambas copias
  quedan alineadas de nuevo con este commit; agregado también el bloque de regeneración de
  `sharedKit.xcframework` en la sección 1, que la copia de `driverlog` ya tenía.
- 03/09 — **Deuda detectada y resuelta el mismo día:** este archivo se decía espejo de un
  `PANORAMA.md` en `app-kilometros-completa` que en ese momento no existía ahí (ni en el
  working tree ni en el historial de git de ese repo). Cruzado con otra sesión que creó esa
  copia el mismo día (commit `06a8662` en `app-kilometros-completa`) — al traerla acá con
  `git pull --rebase` ambas copias quedaron alineadas de nuevo. El protocolo de propagación
  del encabezado deja de ser aspiracional a partir de ahora.
  *(Entrada escrita en la copia de `driverlog`; traída acá el 29/09 para que las dos copias
  tengan el mismo log. `app-kilometros-completa` es el repo Android (rama `main`) — ver la
  corrección del 29/09 en el encabezado.)*
- 19/08 — creado este documento. Sin sesión de código todavía.
- 19/08 — :shared: SolapamientoValidator portado, conectado (3 call sites) y validado
  (11 tests de paridad + 3 de campo con datos reales, solo lectura). Commits 3bb9693
  (frente) + 14c79ce (convención de mensaje detallado, CLAUDE.md), ambos pusheados.
  Próximo paso de :shared: definir capa de red/Supabase (diseño, sesión aparte) o
  retomar en la Mac código Swift consumiendo los tipos ya portados.
- 19/08 — :shared: contrato de Mensajes portado (envelope + 7 subtipos + dispatch por
  tipo, corrigiendo el nesting real de cada tipo — protección estructural contra el
  bug histórico data.guardia). Serializers flexibles (data JSONObject-o-string,
  timestamps polimórficos). Validado con 22 tests (20 paridad + 2 con datos reales de
  producción, mensajes 507/509). La validación de campo encontró y corrigió un bug
  real (id numérico en JSON, faltaba isLenient), centralizado en MensajesJson
  compartido. SupabaseMensajesApi conectado como wrapper en :app, sin tocar
  SupabaseService.kt. Pendiente: conectar MensajesPollingWorker.kt al contrato nuevo
  (no se tocó hoy — próximo paso). Commits c21cd0c (frente) + 6c8cec4 (mandato de
  sesión), ambos pusheados.
- 15/09 — Supabase: cerrado `choferes_insert` (policy dejaba insertar a `anon` con
  `empresa_id='cot'` como único check). RPC `registrar_chofer` + policy restringida a
  `authenticated`. Kotlin y JS legacy (`ui_registro.js`) migrados los dos, commits
  separados, 3 pruebas contra Supabase real. Encontrado de rebote: mismo patrón abierto
  en `choferes_update`, no tocado esa sesión.
- 16/09 — Supabase: cerrado el resto del bloque RLS — `choferes_update` (3 RPCs),
  `jornadas_update`+`jornadas_insert` (1 RPC, `sincronizar_jornada_js`, cubre las dos),
  `mensajes_select`/`mensajes_update` (5 RPCs). Kotlin y JS legacy (`push_notifications.js`,
  `sync.js`, `ui_mensajes.js`) migrados, commits separados por repo. Todo validado con
  pruebas puntuales contra Supabase real (INSERT/UPDATE directo con `anon` bloqueado,
  RPCs funcionando). No queda ningún punto abierto de este bloque.
- 16/09 — Limpieza de documentación/repo (sin tocar código de app ni Supabase): confirmado
  que `.claude/Estado_actual.md` es la única copia real (la de la raíz, congelada desde
  17/08, se eliminó); corregida la referencia residual a `choferes_insert` como pendiente
  (ya cerrado); puntero a `DISENO_INTEGRIDAD_LAUDO.md` reemplazado por una nota (el diseño
  se hizo en conversación, nunca se bajó a archivo); este mismo archivo corregido (ver nota
  al pie del header); `CLAUDE.md` de este repo y del JS legacy limpiados del preámbulo sin
  ejecutar que tenían pegado (ver sección 5); repo git anidado + experimento Kotlin
  abandonado borrados del repo JS legacy; 4 documentos de arranque de ese repo commiteados
  por primera vez.
- 17/09–29/09 — **Consolidado de lo que afecta a cualquier cliente (Android/iOS).** Detalle
  en `Estado_actual.md` del repo Android.
  - **Auth del chofer (17-23/09):** login con **legajo + PIN** por Edge Function `login-chofer`
    (alta con código de enrolamiento: `activar-chofer`; renovación: `refresh-chofer`). Devuelve
    un JWT propio del chofer que viaja en el header **`X-Chofer-Token`** y se verifica en Postgres
    (`chofer_actual()`), más un refresh token. **Desde el 29/09 `login-chofer` devuelve además
    `nombre`, `base` y `tipo`** (el cliente los guarda como perfil). Las Edge Functions de chofer
    se deployan con `--no-verify-jwt`.
  - **Keys (19-20/09):** el cliente usa la **publishable key nueva** (`sb_publishable_…`) en
    `apikey`; las keys legacy en formato JWT (anon / service_role) están **deshabilitadas** y el
    secreto HS256 legacy revocado. Ningún cliente puede depender de ellas.
  - **RLS / RPC (23-25/09):** `jornadas_select` y `choferes_select` sin rama `anon`;
    `estado_jornada` exige `X-Chofer-Token`; `sincronizar_jornada_js` y `registrar_chofer` sin
    `EXECUTE` para anon. **Tanda 1 (25/09):** las 9 RPC que escriben `jornadas.data` exigen
    `X-Chofer-Token` del chofer dueño (o admin de la misma empresa para las de edición); sin
    token → 403 (28000), jornada ajena → 42501, inexistente → 404 con `code`
    (`JORNADA_NOT_FOUND`/`VIAJE_NOT_FOUND`/…), `data` mal formado → 409 `DATA_INVALIDA`. Ya no
    hay 204 silencioso sobre algo que no existe.
  - **Activación de viajes (29/09): solo por la RPC `activar_viaje(p_viaje_id, p_inicio_real,
    p_motivo)`.** Guard P→E (si el viaje no está `programado`, no hace nada y devuelve
    `activado:false`). `inicioReal` = **hora oficial** (`inicioProgramado`); en "Iniciar ahora"
    (respaldo sin señal) vale `min(hora del toque, inicioProgramado)` con **cota de 10 min**: si
    el adelanto es mayor, se usa la hora oficial y queda `ajuste = 'ADELANTO_MAYOR_AL_LIMITE'`.
    `p_inicio_real` se captura en el toque y viaja en la cola offline (nunca se recalcula);
    `p_motivo` = motivo que se le pide al chofer si arranca antes de hora. La RPC registra
    `travels[i].activacion = {por, servidor_en, inicio_solicitado, ajuste, motivo}`.
  - **Cancelación:** un **viaje en curso no se cancela**, solo se edita desde el panel (edición
    auditada); en Android se elimina `cancelarViajeEnCurso` (A7). La **anulación es solo desde P
    y la hace el panel**. Finalizado y cancelado son terminales.
  - **Varios choferes en un servicio:** `travels[i].servicio_id` + `rol` =
    `'dupla' | 'relevado' | 'relevo'` (null en viajes normales). Relevo: el viaje original se
    cierra en F con `rol = 'relevado'` a la hora del cambio y el nuevo arranca en curso con
    `rol = 'relevo'`; nunca se mueve un viaje entre jornadas. Dupla: los dos viajes con
    `rol = 'dupla'` (laudo sin cambios).
  - **Cron D5 en producción (29/09):** `enviar-push-viaje` activa por fecha + hora
    (`inicioProgramado`) con la misma `activar_viaje`, para todos los choferes (tengan o no token
    de push), y ya no hace PATCH del `data` entero. Si el sync le trae al cliente un viaje ya
    `en_curso`, el cliente no lo vuelve a activar.
  - **Regla de trabajo nueva:** un frente a la vez hasta cerrarlo (ver `CLAUDE.md` del repo
    Android).
  - **Protocolo de cierre, paso nuevo (29/09):** "PANORAMA.md: si la sesión cambió algo que el
    otro cliente necesita saber para no divergir (…), agregá una entrada fechada con qué cambió
    y qué implica para el otro lado." **El repo iOS (`driverlog`) tiene que adoptar el mismo paso
    en su `CLAUDE.md` en la próxima sesión en la Mac.**
- 29/09 (Mac) — Corregida la "Corrección 16/09" del encabezado, que era falsa: en GitHub hay un
  solo repo, `claudio3964/app-kilometros-completa` (`main` = Kotlin + `:shared`,
  `dev-rebuild-core` = JS legacy huérfana); `cot_devapp_kilometros-completa-android-koltin` es
  solo la carpeta local en Windows. Referencias a ese nombre corregidas en todo el archivo. Las
  dos copias quedan con texto idéntico (se quita de la de `driverlog` la nota del 29/09 para la
  Mac: sus tres tareas ya están hechas — pull, paso PANORAMA en el `CLAUDE.md` iOS, y el puente
  Swift↔`:shared` estaba commiteado desde `ba388e6`). Solo documentación, sin impacto en código.
- 30/09 (Windows) — **Fase 0 tanda 2 aplicada en prod.** Para el otro cliente:
  `crear_jornada`, `marcar_mensaje_leido`, `responder_mensaje`,
  `enviar_mensaje_urgente_jornada_colgada`/`_borrada`, `obtener_mensajes_pendientes` y
  `obtener_estado_mensaje` **exigen `X-Chofer-Token`** (sin token → 403 `28000`; admin → 42501).
  `crear_jornada` solo acepta la jornada propia: `p_legajo` = legajo del token, `p_chofer_id` =
  `p_legajo`, `p_empresa_id` = empresa del token, `p_order_number` = `<legajo>-YYYYMMDD` de
  `p_fecha` (si no, 42501). `responder_mensaje` **solo toma `viajeId`/`guardiaId` de `p_data`** y
  los mergea sobre el `data` actual (el resto se ignora; sin ninguno → 400). `marcar`/`responder`
  sobre un id inexistente o ajeno → 404 `MENSAJE_NOT_FOUND` (antes `200 false`).
  `obtener_mensajes_pendientes` ignora `p_legajo` y usa el del token; `obtener_estado_mensaje` de
  un mensaje ajeno → conjunto vacío. Firmas y tipos de retorno sin cambios.
- 01/10 (Windows) — **Bug 1 3a.1: trigger de `travels` en prod** (aplicado 30/09,
  `20260930010000_bug1_3a1_trigger_travels.sql`; validado en campo 01/10). **Aplica a todos los
  clientes** (Android, iOS, panel, cron): toda escritura de `jornadas.data.travels` pasa por
  `trg_jornadas_travels`. Máquina de estados P/E/F/C — solo P→E, P→C, E→F (P→F, E→C, E→P y
  cualquier salida de F o C → **409 `TRANSICION_INVALIDA`**); `inicioReal`/`finReal` ya seteados
  (número > 0 o texto no vacío; 0 y null cuentan como vacío) no cambian → 409 `CAMPO_INMUTABLE`;
  ningún viaje se borra de `travels` → 409 `VIAJE_ELIMINADO`; entrar a F exige `inicioReal` y
  `finReal`. `agregar_viaje_a_jornada` es idempotente por id. **Para iOS:** no replicar el patrón
  de activación de Android (worker que activa sin chequear status ni el resultado de la RPC, y GPS
  arrancado desde la UI por estado local antes de la confirmación del servidor): en campo 01/10 un
  viaje cancelado recibió el 409 pero quedó en curso en el celu, con GPS y notificación. Activar
  solo desde P y tocar estado local/GPS recién con 2xx. Ver 3b en `Estado_actual.md` de Android.
- 01/10 (Windows, cont.) — **Bug 1 3a.2 aplicada en prod: RPC `editar_viaje_panel`.** Para todos
  los clientes: `editar_viaje_panel(p_viaje_id, p_motivo, p_status, p_inicio_real, p_fin_real) →
  jsonb` corrige un viaje con auditoría. **Solo admin** (sesión del panel; chofer, anon y
  service_role → 42501). **Solo jornadas cerradas de días anteriores** (hoy o futura → 409
  `JORNADA_EN_CURSO`; `closed:false` de cualquier fecha → 409 `JORNADA_ABIERTA`; borrada → 409
  `JORNADA_BORRADA`). Permite F↔C, E→F (varados, exige `finReal`) y corregir `inicioReal`/`finReal`;
  P → `ESTADO_NO_EDITABLE`, E→C → `TRANSICION_INVALIDA`; motivo ≥ 10 caracteres. Auditoría en
  `private.ediciones_viaje` (no expuesta por la API). **Clave nueva en `jornadas.data`:
  `totalsDesactualizados = {at, edicion_id}`** — se agrega cuando la jornada editada tenía
  `totalsSnapshot`; el snapshot NO se recalcula. App Android, iOS y panel deberían mostrar que los
  totales de esa jornada están desactualizados (fuera de 3a.2; hoy nadie la lee). La reapertura y
  `cerrar_jornada` la conservan (merge). Los datos de plan de viajes P siguen por
  `editar_viaje_en_jornada`. UI del panel: 3a.3.
- 02/10 (Windows) — **Bug 1 3b.1 cerrado en campo (Android, rama `fix/bug1-3b1` `d446e26`, SIN
  merge a main todavía — falta 3b.1-bis).** Lo que el otro lado necesita saber:
  - **`:shared` nuevo: `TransicionesViaje`** (`shared/.../data/TransicionesViaje.kt`, 7 tests / 66
    filas): transiciones P/E/F/C, `decidirMerge(local, remoto)` (C del servidor gana sobre P/E
    local; F↔C no se pisa — conflicto para 3b.3) e `interpretarActivacion(activado, status_actual)`.
    **iOS debería usarlo** para el sync y la activación en vez de reglas propias. Tests de `:shared`
    pendientes de correr en la Mac (en Windows no compila iOS) antes de regenerar el xcframework.
  - **Activación = servidor primero:** `activar_viaje` y recién con `activado=true` (o
    `status_actual=en_curso`) se toca el estado local, el GPS y la notificación; con
    `activado=false status_actual=cancelado|finalizado` el local adopta ese estado sin GPS.
    Validado en campo (caso 2).
  - **"Iniciar ahora": `p_inicio_real` = hora del click del botón de la card** (decisión explícita
    02/10), no la de confirmar el diálogo de motivo; queda en `activacion.inicio_solicitado`. El
    servidor aplica la cota de 10 min (`ajuste=ADELANTO_MAYOR_AL_LIMITE` → hora programada).
    Motivo ("Orden de tránsito" / "Otro" + detalle) en `p_motivo` cuando es antes de hora.
  - **El sync trae los cancelados** (antes el parser los descartaba) y conserva `coche`,
    `origenCreacion`, `cierreAutomatico`.
  - **`cancelar_viaje` (mensaje del panel) solo se aplica sobre P**; sobre E/F se marca leído y se
    ignora. **Ojo, hallazgo ALTA:** "Anular asignación" del panel NO escribe el C en el servidor,
    solo manda el mensaje; el C lo escribe el cliente al procesarlo. iOS debe hacer lo mismo
    mientras no se corrija (va al parate, candidato a 3b.3).
