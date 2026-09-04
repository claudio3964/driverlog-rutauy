# PANORAMA — Orquestación COT Driver (multi-repo)

> Se lee ANTES de entrar al `Estado_actual.md` puntual de cada repo, al arrancar cualquier sesión nueva.
> Se actualiza con 2-3 líneas al CERRAR cada sesión, sea cual sea el repo tocado.
> Este documento es solo lectura/registro — no toca código, no rompe nada.
>
> **Este archivo existe en DOS repos** (`app-kilometros-completa` Android y `driverlog-rutauy`
> iOS) porque no hay carpeta física compartida entre ambos. Si esta sesión edita este archivo,
> ANTES de cerrar hay que propagar el mismo cambio (texto idéntico o resumen equivalente) a la
> copia del otro repo y pushear las dos. Un PANORAMA.md desincronizado es peor que no tener
> PANORAMA.md — ver paso correspondiente en el PROTOCOLO DE CIERRE de cada repo.

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
ni al de Android) — hay que regenerarlo local:
```
cd app-kilometros-completa   # (o la ruta a ese repo)
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"  # si falta un JDK en PATH
./gradlew :shared:assembleSharedKitDebugXCFramework
```
El proyecto Xcode de `driverlog` espera el resultado en
`../app-kilometros-completa/shared/build/XCFrameworks/debug/sharedKit.xcframework` (path
relativo, asume que `driverlog` y `app-kilometros-completa` son carpetas hermanas) — la task
ya lo deja ahí, no requiere copiar nada. Si el build de Xcode falla con el framework no
encontrado o símbolos viejos, esta es la primera causa a revisar.

**Repos que toca:** `app-kilometros-completa` (PC Windows) + `driverlog` (Mac).

---

## 2. Android — `app-kilometros-completa` (núcleo, producción real)

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

## Supabase

No es un frente aparte — es infraestructura compartida. El trabajo sobre RLS/RPCs queda
registrado dentro del frente que lo dispara (Android, panel, o `:shared`), no en una cola propia.

---

## Log de sesiones (agregar abajo, no reescribir lo de arriba)

- 03/09 — **Deuda detectada, no urgente:** este archivo se dice espejo de un `PANORAMA.md`
  en `app-kilometros-completa`, pero ese espejo nunca existió ahí (ni en el working tree ni
  en el historial de git de ese repo). El protocolo de propagación del encabezado asume una
  copia que no está. Pendiente: crear esa copia en `app-kilometros-completa/.claude/PANORAMA.md`
  la próxima vez que se edite este archivo desde cualquiera de los dos repos, para que el
  protocolo deje de ser aspiracional.
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
