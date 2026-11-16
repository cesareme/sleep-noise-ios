# Cuaderno de trabajo de Cursor · SleepNoise 1.0

Fecha: 16-11-2026. Manda `docs/PLAN-DESARROLLO-AGENTES-2026-11-16.md`. Si este cuaderno lo contradice, gana el plan. Sobre el plan manda `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`.

Nada de esto se ha ejecutado. Leyenda: [V] comprobado hoy en el Mac o en documentación oficial. [INF] inferencia. [SV] sin verificar.

En la oleada 0 Cursor no tiene paquetes. Sus briefs son P-03a, P-04a y T-01 (oleada 1) y B-05a (oleada 2). A-02c (oleada 2) está en la tabla de §4. Son 5 paquetes.

---

## 1. Cómo se usa Cursor aquí

### 1.1 Entorno

| Dato | Valor | Evidencia |
|---|---|---|
| Dónde corre | Una VM en la nube por agente. Clona el repo, trabaja en rama propia y hace push | [V] |
| Qué tiene | Linux. Sin Xcode, sin simulador, sin `xcodebuild`, sin XcodeGen | [INF fuerte], dos PR lo confirman |
| Qué ve | No está comprobado que vea el check ni el log de la CI de su PR. La corrección automática de CI solo existe en Teams y Enterprise | [SV] y [V-web] |
| Plan | Los agentes en la nube piden Premium o superior. El contrato no está comprobado | [V] y [SV] |
| Coste | Por consumo, según modelo. El repo es público hoy y el runner estándar no consume minutos. Si pasa a privado, cada push gasta minutos de macOS | [V] y [SV] |
| Visibilidad | El repo es público: el issue con el brief y los comentarios del PR los lee cualquiera. El dueño decide el día 1 si lo pasa a privado | [V] `gh repo view` |

"My Machines" (un worker de Cursor en el Mac) existe [V] y este plan no lo usa: ocuparía una plaza de compilación. `.cursor/environment.json` no resuelve Xcode.

### 1.2 Qué instrucciones lee

- `AGENTS.md` en la raíz. Fuente única para los tres agentes (I-03).
- `.cursor/rules/sleepnoise.mdc`, de aplicación permanente, que solo remite a `AGENTS.md`. El orden entre los dos no está documentado [SV], así que no puede haber dos textos.
- `CLAUDE.md` en la raíz, si llega a existir: Cursor lo lee y lo aplica siempre [V]. No puede contradecir a `AGENTS.md`.
- El brief. El bloque de este cuaderno es el borrador. La copia de `docs/briefs/<id>.md`, pegada en el issue, es la que vale.

### 1.3 Condiciones antes del primer encargo

1. I-02 fusionado: CI en verde sobre `main` y en rojo en el PR de control (`claude/ci-control-pr3`, plan §9).
2. `main` protegida con PR y check de CI obligatorios. Lo activa el dueño.
3. I-03 fusionado: `AGENTS.md`, regla de Cursor y plantilla de PR.
4. Los documentos que cita el brief están en `main`: `docs/` entra por PR el día 1. Claude lo comprueba con `git cat-file -e origin/main:<ruta>` antes de pegar el brief.
5. El dueño ha confirmado el plan de Cursor y ha fijado un límite de gasto.
6. El dueño ha autorizado de forma general los comentarios de Claude en los PR de Cursor para devolver el log de la CI.

Si el día 3 falta alguna de estas condiciones, P-03a pasa a su suplente, Kimi, y Cursor se calibra con P-04a (plan §2.2, R7).

### 1.4 Cómo se le pasa una tarea

1. **Brief.** Claude copia el bloque de la sección 3 a `docs/briefs/<id>.md`, rellena el sha de base, comprueba que las dependencias están en `main` y lo sube con un PR de documentación.
2. **Issue.** Con permiso del dueño para publicar, y con la visibilidad del repo ya decidida, porque en un repo público el issue es público: `gh issue create --title "<id> · <título>" --body-file docs/briefs/<id>.md`
3. **Lanzamiento.** Vía preferida, porque deja rastro: un comentario en el issue que menciona a `@cursor` y dice "Haz este paquete tal como dice el brief. Rama `cursor/<id>-<slug>`, base `main`. Abre un PR con la plantilla." El canal existe [V]. El texto que entiende no está probado [SV]. Alternativa: la web de agentes de Cursor, con base `main` y el brief pegado [V el canal, SV la pantalla].
4. **Modelo.** Composer 2.5, por precio. Otro modelo solo si P-03a sale mal y el dueño acepta el gasto.
5. **PR.** Cursor lo abre desde su rama. Sus dos ramas anteriores llevan sufijo automático, así que puede no respetar el nombre pedido [INF]. Claude anota la rama real y no se pierde una ronda por eso.
6. **CI.** Cursor abre el PR y termina. No se da por hecho que vea el check [SV]. Mientras esté en rojo, nadie revisa (puerta 3 del plan §3.5).
7. **Corrección.** Claude pega en el PR las líneas del log que fallan y menciona a `@cursor`, con la autorización general del día 1. Si está en verde, Claude añade el enlace a la ejecución. Cada vuelta cuenta para la regla de las dos rondas. 24 horas sin PR, o 24 horas en rojo sin push nuevo, cuentan como ronda.
8. **Revisión de Codex en local**, con la CI en verde. `scripts/verify.sh` lo ejecuta Claude, porque `codex exec review` corre en solo lectura. Después Codex revisa con ese log (`docs/agents/CODEX.md` §1.4). `SN_SIM` es la variable que el plan §9 prevé para I-01 [SV hasta que exista]:

       git fetch origin <rama>
       git worktree add --detach ~/wt/sleepnoise/codex-rev-<id> origin/<rama>
       cd ~/wt/sleepnoise/codex-rev-<id> && SN_SIM='iPhone Air' scripts/verify.sh > .build/verify.log 2>&1

9. **Integración.** Claude actualiza sobre `main`, repite la verificación, hace push con `--force-with-lease`, espera a la CI, fusiona, cierra el issue y borra la rama. El push forzado solo se hace con el PR ya aprobado: Cursor no vuelve a tocar esa rama.

### 1.5 Ritmo

- Un solo PR de Cursor abierto a la vez (plan §3.6). Van en fila: P-03a, P-04a, T-01, B-05a, A-02c.
- P-03a es la calibración (plan §3.7): CI en verde en dos vueltas o menos y sin errores de fondo para Codex. Si no, el resto pasa a Kimi.
- Suplente: Kimi, también en A-02c. P-03a y P-04a están en la ruta crítica: tres días laborables de "listo" a "aprobado", o pasan al suplente (plan §2.2, R7).

---

## 2. Reglas propias de Cursor

Van además de `AGENTS.md`, no en su lugar.

### 2.1 Fallos conocidos y su regla

| Fallo (fuente: `docs/REVIEW-PR3-2026-11-16.md`) | Regla |
|---|---|
| El PR #3 no compilaba: un `inclusiveRange` mal tipado y una frase de AppShortcut con un `Int` | Nada de App Intents, WidgetKit, ActivityKit, StoreKit, TipKit ni SwiftUI. Solo Foundation y XCTest |
| Los dos PR se escribieron sin Xcode | La CI es su única prueba. Nunca dice "los tests pasan". El resultado y el enlace a la ejecución los pone Claude en el PR |
| Interfaz sin dirección: baldosas, cápsulas, 14 candados | Ningún paquete suyo tiene interfaz ni cadenas. Si cree que hace falta una, para |
| Un test comprobaba constantes contra sí mismas. Otros renderizaban 2 s y no veían una envolvente atascada | Cada test dice qué cambio lo pondría en rojo. Las tablas llevan casos verdaderos y falsos. La duración de un render se justifica |
| Una secuencia afín presentada como hash | No inventa generadores. Usa los del repo o dice que falta uno |
| El README documentaba una frase que no existía. Español flojo en el catálogo | No toca README, `docs/` ni catálogos. El PR solo afirma lo que hay en el diff |

### 2.2 Lo que no toca nunca

- `project.yml`, `Info.plist`, entitlements, `SleepNoise.storekit`, los dos `.xcstrings`, `Assets.xcassets`, `SleepNoise.xcodeproj` (se genera, está en `.gitignore`).
- `scripts/`, `.github/`, `AGENTS.md`, `.cursor/`, `README.md`, `docs/`.
- El contrato de audio: `EngineCommand`, `RenderState`, `ParameterMailbox`, `AtomicBridge`, `SleepAudioEngine`.
- `SoundID`, `SoundGains`, `AccessPolicy`, `TrialClock`, `PurchaseManager`, `MixerModel` y sus extensiones, `MixerView`, `AppRoot`, `Theme`, `MixStore`, `SavedMix`.
- Cualquier fichero de test existente. Los tests nuevos van en ficheros nuevos.

En las oleadas 1 y 2 sus listas cerradas solo tienen ficheros nuevos (plan §2.2, R4), que entran solos con `xcodegen generate` [V]. No hay excepción: A-02c también son solo ficheros nuevos. El PRNG y las texturas los cambia Codex en A-02a y A-02b.

### 2.3 Escribir sin compilador

- Swift 5.9, iOS 17.0, sin `#available`. Los avisos son errores: nada sin usar, ningún `var` que no muta.
- Imports: `Foundation` en la app. `XCTest` y `@testable import SleepNoise` en tests. `Accelerate` solo en T-01.
- XCTest, no Swift Testing. Tests deterministas: sin `Date()`, `Calendar.current`, `TimeZone.current` ni `Locale.current`. El runner no está en la zona horaria del dueño. Sin red, sin esperas, sin ficheros.
- Los tests corren en simulador y en serie. Presupuesto por paquete: menos de 5 s, salvo T-01.
- Si la VM tiene Swift para Linux, `swiftc -typecheck` sobre los ficheros de solo Foundation ayuda [SV]. No es prueba. Sin `Package.swift`.

### 2.4 Disciplina de CI

- La CI no es un bucle de compilar. Repasa el diff entero antes de cada push y corrige todo de una vez.
- Un push por vuelta. Abre el PR y termina. No esperes a la CI: su resultado te llega en un comentario con @cursor.
- Tope de tres pushes por paquete. Si el tercero sale en rojo, atasco.
- Nunca busques el verde por fuera: no toques el workflow ni `scripts/verify.sh`, no desactives ni renombres tests, no uses `XCTSkip`, no relajes umbrales existentes.
- No fusiones `main` en tu rama ni hagas rebase. Los conflictos son de Claude (plan §3.8). Un solo PR.

### 2.5 Idioma

Briefs en español: las specs lo están y los términos tienen que casar uno a uno (Manto, Madrugada, Marea). Identificadores y comentarios de código en inglés, como el repo. Commits y PR en español, con el formato de `AGENTS.md`. Un texto para el usuario iría en inglés y en español según `docs/design/10-GUIA-DE-COPY.md` §0.2 y la reconciliación §3. En estos cuatro briefs no hay cadenas. Sin afirmaciones médicas en ningún texto.

### 2.6 Atasco

El plan pide `ATASCO.md` en el worktree. Cursor no tiene. Su equivalente: PR en borrador y un comentario en el PR, o en el issue si aún no hay PR, con el error, lo probado y su hipótesis. Sin commit de `ATASCO.md`.

---

## 3. Briefs listos para pegar

Uno cada vez, en este orden. Antes de pegar, Claude rellena el sha de base y comprueba las dependencias. Siguen la plantilla del plan §3.3, con pasos añadidos y la entrega adaptada a un agente sin Xcode. "Decisión del brief" marca lo que la spec no fija y ha cerrado este cuaderno. Claude puede cambiarlo antes de pegar.

### 3.1 P-03a · NightWindow, SaleGate y TipGate (oleada 1, calibración de Cursor)

````text
# BRIEF P-03a · NightWindow, SaleGate y TipGate
Agente: Cursor                         Revisor: Codex
Rama: cursor/p-03a-nightwindow         Base: main@<sha corto>
Worktree y simulador: no aplica. Nube, sin Xcode.

## Objetivo
La app tiene una sola ventana horaria de noche, de 21:00 a 07:00. Dentro de ella
no se vende nada y no se enseña ningún tip. Este paquete crea esa constante y las
dos puertas que la consultan, como lógica pura con tests. Las cablean otros.

## Lee antes (y nada más)
- AGENTS.md
- docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md: §1 regla 7 (línea 42) y las
  fichas C40 (línea 596), C08 (línea 159), C06 (línea 128) y C65 (línea 939).
- docs/design/04-SISTEMA-FUNDAMENTOS.md, Anexo A12, líneas 1927 a 1943. Es el
  listado de referencia de los tres tipos.

## Ficheros que puedes tocar (lista cerrada, todos nuevos)
- SleepNoise/Model/NightWindow.swift
- SleepNoiseTests/NightWindowTests.swift

## Ficheros prohibidos en este paquete
Todos los demás. En especial project.yml, AccessPolicy.swift, PolicyTests.swift,
MixerModel.swift, PurchaseManager.swift, Localizable.xcstrings, scripts/, .github/
y docs/. No crees SaleGateTests.swift ni TipGateTests.swift: esos nombres son de
C-04 y A-04.

## Qué construir
En NightWindow.swift, solo con `import Foundation`:

    enum NightWindow {
        static let startHour = 21
        static let endHour = 7
        static func contains(_ date: Date, calendar: Calendar = .current) -> Bool
    }
    enum SaleGate {
        static func allows(now: Date = Date(), isNightPhase: Bool, sceneIsActive: Bool,
                           calendar: Calendar = .current) -> Bool
    }
    enum TipGate {
        static func allows(now: Date = Date(), tideActive: Bool, shownThisSession: Bool,
                           calendar: Calendar = .current) -> Bool
    }

Reglas:
- contains es cierto si la hora local es 21 o más, o menor que 7. 21:00:00 entra.
  07:00:00 no entra.
- SaleGate.allows es cierto solo si now está fuera de NightWindow, isNightPhase es
  falso y sceneIsActive es cierto.
- TipGate.allows es cierto solo si now está fuera de NightWindow, tideActive es
  falso y shownThisSession es falso.
- Decisión del brief: el listado A12 recibe `phase: NightPhase` y `scene: ScenePhase`.
  Esos tipos son de SwiftUI y del sistema de diseño, que aún no existe en main.
  Aquí entran como Bool. No importes SwiftUI. La sobrecarga con los tipos de
  interfaz la añade DS-02 como extension, o A-03a si DS-02 entró antes. Los tres
  tipos se declaran solo en este fichero.
- calendar existe para que los tests no dependan de la zona horaria de la máquina.
- Sin estado, sin singletons, sin UserDefaults. Tres enum sin casos.

## Pasos
1. Lee lo citado.
2. Escribe NightWindow.swift, con un comentario `///` en inglés por tipo que cite
   la ficha (C40, C08, C65).
3. Escribe los tests. Crea las fechas con un Calendar gregoriano de zona fija
   (`TimeZone(identifier:)`) y un ayudante privado.
4. Repasa el diff entero. Un solo push. Abre el PR y termina. No esperes a la
   CI: su resultado te llega en un comentario con @cursor.

## Cómo escribir para que compile a la primera
- Swift 5.9, iOS 17. Los avisos son errores. Nada sin usar.
- XCTest y `@testable import SleepNoise`. En el test no puede aparecer Date(),
  Calendar.current, TimeZone.current ni Locale.current.
- No toques project.yml: los ficheros nuevos entran solos.

## Criterio de aceptación
Tests con estos nombres, todos en NightWindowTests:
- testWindowEdges: 20:59:59 falso, 21:00:00 cierto, 23:59:59 cierto, 00:00:00
  cierto, 06:59:59 cierto, 07:00:00 falso, 12:00:00 falso.
- testWindowUsesTheGivenCalendar: el mismo instante da cierto en una zona y falso
  en otra. Usa Europe/Madrid, America/Los_Angeles y UTC.
- testWindowOnClockChangeNights: las madrugadas del 29-03-2026 y del 25-10-2026 en
  Europe/Madrid siguen dentro de la ventana entre la 01:00 y las 04:00. Recorre
  ese tramo sumando minutos a un instante base: el 29-03 las 02:00 no existen y
  `calendar.date(from:)` puede devolver nil.
- testSaleGateTruthTable: las 8 combinaciones de (dentro o fuera de la ventana,
  isNightPhase, sceneIsActive). Solo una da cierto.
- testSaleGateAtHalfPastEleven: a las 23:30, con fase de día y escena activa, falso.
- testTipGateTruthTable: las 8 combinaciones. Solo una da cierto.
Cada test lleva un comentario de una línea que dice qué cambio lo pondría en rojo.

Comprobaciones que puedes ejecutar tú, en Linux:
    git diff --name-only origin/main...HEAD
        # exactamente los dos ficheros de la lista
    grep -n '^import ' SleepNoise/Model/NightWindow.swift
        # una línea: import Foundation
    grep -nE 'Date\(\)|Calendar\.current|TimeZone\.current|Locale\.current' \
        SleepNoiseTests/NightWindowTests.swift
        # ninguna línea

La prueba que cuenta es el check de CI del PR en verde. El número de tests sube en
los que añades y no desaparece ninguno de los que había.

Lo que ejecutará el revisor en el Mac (tú no puedes):
    SN_SIM='iPhone Air' scripts/verify.sh
    xcodebuild test -project SleepNoise.xcodeproj -scheme SleepNoise \
      -destination 'platform=iOS Simulator,name=iPhone Air' -only-testing:SleepNoiseTests/NightWindowTests

## Cadenas
Ninguna. Si crees que hace falta una, para.

## Fuera de alcance
- Llamar a estas puertas desde cualquier vista o modelo.
- Una puerta de reseña. No es de este paquete.
- La ventana de la mañana de las interrupciones. Es otra regla y va en B-05a.
- AccessPolicy, la prueba de 7 noches y Keychain. Son de P-03b.

## Entrega
Un PR contra main. Título: P-03a · NightWindow, SaleGate y TipGate.
Descripción en español con la plantilla del repo: id y secciones leídas, lista de
ficheros del diff, la
frase literal "No he compilado ni ejecutado nada en local." y las dudas de spec
que hayas resuelto por tu cuenta. El enlace a la CI lo añade Claude. No verificado
en dispositivo: nada que verificar.
Commits pequeños con el formato de AGENTS.md, sin commits de fusión.

## Si te atascas
Para tras dos intentos fallidos sobre el mismo error o si el tercer push sale en
rojo. PR en borrador y un comentario en él: error literal, lo probado y tu
hipótesis. No amplíes el alcance.
````

### 3.2 P-04a · Códec de mezcla v2 (oleada 1)

Se lanza con P-03a fusionado y R-01 en `main`: el test de instantánea necesita los once casos de `SoundID`.

````text
# BRIEF P-04a · Códec de mezcla v2 en ficheros nuevos
Agente: Cursor                         Revisor: Codex
Rama: cursor/p-04a-mezcla-v2           Base: main@<sha corto>
Worktree y simulador: no aplica. Nube, sin Xcode.

## Objetivo
Definir el formato en disco de una mezcla guardada, versión 2, de forma que dos
versiones distintas de la app puedan compartir el mismo almacén sin perder datos.
Este paquete entrega solo los tipos, el códec y sus tests. MixStore sigue usando
el formato actual hasta P-04b, que lo cambia.

## Lee antes (y nada más)
- AGENTS.md
- docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md: fichas C09 (línea 172) y C20
  (línea 330).
- docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md: §7 punto 4 (línea 603) y la
  ficha mezclas-que-sobreviven (línea 361).
- docs/design/08-MEZCLAS-PRO-PRUEBA.md, línea 109 (la receta) y línea 520.
- Código, solo lectura: SleepNoise/Features/Library/SavedMix.swift, MixStore.swift
  y SleepNoise/Model/SoundID.swift.

## Ficheros que puedes tocar (lista cerrada, todos nuevos)
- SleepNoise/Features/Library/MixRecord.swift
- SleepNoise/Features/Library/MixCodec.swift
- SleepNoise/Features/Library/JSONValue.swift
- SleepNoiseTests/SavedMixFormatTests.swift

## Ficheros prohibidos en este paquete
Todos los demás. En especial SavedMix.swift, MixStore.swift, SoundID.swift,
MixerModel.swift, AccessPolicy.swift, PolicyTests.swift, project.yml, los
entitlements, scripts/, .github/ y docs/.

## Qué construir
Solo `import Foundation`. Nombres nuevos para no chocar con SavedMix y MixLevel.

    enum JSONValue: Codable, Equatable { null, bool, number, string, array, object }

    struct MixLayer: Equatable {
        var id: String                    // rawValue de SoundID, o un id desconocido
        var level: Float                  // 0...1
        var extra: [String: JSONValue]    // claves desconocidas
        var sound: SoundID? { SoundID(rawValue: id) }
    }

    struct MixRecord: Equatable, Identifiable {
        static let currentVersion = 2
        var id: UUID
        var name: String
        var version: Int
        var layers: [MixLayer]
        var updatedAt: Date
        var extra: [String: JSONValue]
        init(id: UUID, name: String, levels: [SoundID: Float], updatedAt: Date)
        func level(for sound: SoundID) -> Float     // 0 si no está
    }

    enum MixEntry: Equatable {
        case mix(MixRecord)
        case opaque(JSONValue)    // entrada que esta versión no sabe leer
    }

    enum MixCodec {
        static func decode(_ data: Data) throws -> [MixEntry]
        static func encode(_ entries: [MixEntry]) throws -> Data
        static func merge(local: [MixEntry], remote: [MixEntry]) -> [MixEntry]
    }

Forma en disco: un array JSON. Cada mezcla es un objeto con las claves "version"
(2), "id", "name", "layers" (array de objetos con "id" y "level") y "updatedAt".

Reglas:
- Decodificación permisiva. Una clave desconocida, en la mezcla o en una capa, se
  guarda en extra y se vuelve a escribir igual al codificar.
- Una capa con un id de textura desconocido se conserva y se vuelve a escribir.
  `sound` devuelve nil y `level(for:)` la ignora.
- Una entrada que no se puede leer como versión 2 (version mayor que 2, o le falta
  una clave obligatoria) no se descarta: queda como `.opaque` y se reescribe tal
  cual. Solo falla `decode` si el dato no es un array JSON.
- level se recorta a 0...1 al decodificar y al construir.
- `init(levels:)` escribe solo las capas con nivel mayor que 0, en el orden de
  SoundID.allCases. Son pares de textura y nivel, sin huecos.
- Codificación determinista: `outputFormatting = [.sortedKeys]`.
- merge une por id. Si una mezcla está en los dos lados, gana la de updatedAt más
  reciente. Si empatan, gana local. Conserva el orden de local y añade al final
  las que solo están en remote. Las entradas opacas de los dos lados se conservan
  sin duplicar las que son iguales.
- Decisiones del brief, porque la spec no las fija: la clave del array es
  "layers", el nivel es un Float de 0 a 1 como en MixLevel.value, y updatedAt se
  escribe en ISO 8601 UTC con segundos. Dilo en el PR como puntos a confirmar.
- Solo struct y enum. Sin singletons, sin UserDefaults, sin ficheros.

## Pasos
1. Lee lo citado y los tres ficheros de código.
2. Escribe JSONValue, MixLayer y MixRecord con Codable manual: una CodingKey
   dinámica lee las claves conocidas y manda el resto a extra.
3. Escribe MixCodec. decode pasa primero por [JSONValue] y después intenta leer
   cada elemento como MixRecord.
4. Escribe los tests con JSON literal en cadenas multilínea.
5. Repasa el diff entero. Un solo push. Abre el PR y termina. No esperes a la
   CI: su resultado te llega en un comentario con @cursor.

## Cómo escribir para que compile a la primera
- Swift 5.9, iOS 17. Los avisos son errores. Nada sin usar. Ninguna dependencia.
- Decodifica los números como Double y convierte a Float de forma explícita.
- En los tests, fechas con `Date(timeIntervalSince1970:)`. Nunca Date().

## Criterio de aceptación
Tests con estos nombres, todos en SavedMixFormatTests:
- testRoundTripKeepsEverything: una mezcla de tres capas se codifica, se
  decodifica y es igual.
- testFutureFieldsSurviveARoundTrip: un JSON con una clave extra en la mezcla y
  otra en una capa. Tras decode y encode, las dos claves siguen ahí con su valor.
- testUnknownTextureIsKeptAndIgnored: una capa con id "aurora". Las otras capas se
  leen bien, level(for:) no la cuenta y al codificar "aurora" sigue con su nivel.
- testNewerVersionEntryStaysOpaque: un array con una mezcla de versión 2 y un
  objeto de versión 3 con otra forma. La de versión 2 se lee. La otra queda opaca
  y se reescribe idéntica.
- testMergePrefersTheNewestUpdate: mismo id en los dos lados, gana el updatedAt
  mayor, en los dos sentidos. Con empate gana local.
- testMergeKeepsBothSidesAndOrder: ids distintos en cada lado.
- testLevelsAreClamped: niveles -0,2 y 1,7 quedan en 0 y 1.
- testEncodingIsDeterministic: dos codificaciones de lo mismo dan los mismos bytes.
- testSoundIDRawValuesAreFrozen: el conjunto de rawValue de SoundID.allCases es
  exactamente white, pink, brown, rain, fan, ocean, thunder, campfire, stream,
  wind, cabin. Si alguien renombra o añade un caso, este test obliga a mirarlo.
- testGarbageThrows: un dato que no es un array JSON hace fallar decode.
Cada test lleva un comentario de una línea que dice qué cambio lo pondría en rojo.

Comprobaciones que puedes ejecutar tú:
    git diff --name-only origin/main...HEAD
        # exactamente los cuatro ficheros de la lista
    grep -n '^import ' SleepNoise/Features/Library/MixRecord.swift \
        SleepNoise/Features/Library/MixCodec.swift \
        SleepNoise/Features/Library/JSONValue.swift
        # solo import Foundation
    grep -nE 'Date\(\)|UserDefaults|FileManager' SleepNoiseTests/SavedMixFormatTests.swift
        # ninguna línea

La prueba que cuenta es el check de CI del PR en verde.

Lo que ejecutará el revisor en el Mac:
    SN_SIM='iPhone Air' scripts/verify.sh
    xcodebuild test -project SleepNoise.xcodeproj -scheme SleepNoise \
      -destination 'platform=iOS Simulator,name=iPhone Air' -only-testing:SleepNoiseTests/SavedMixFormatTests

## Cadenas
Ninguna.

## Fuera de alcance
- MixStore, SavedMix, la clave de almacenamiento, App Group, entitlements y el
  target de widgets. Son de P-04b.
- Migrar datos de la versión 1. No hay base instalada.
- iCloud y borrados sincronizados. Es 1.1.
- El límite de tres mezclas gratis y el recorte del nombre.
- Guardar la Marea o el temporizador. La mezcla no los guarda.

## Entrega
Un PR contra main. Título: P-04a · Códec de mezcla v2.
Descripción en español con la plantilla del repo: id y secciones leídas, lista de
ficheros, la frase "No
he compilado ni ejecutado nada en local.", los tres puntos a confirmar del formato
y un ejemplo del JSON que produce el códec. El enlace a la CI lo añade Claude. No
verificado en dispositivo: nada.

## Si te atascas
Para tras dos intentos fallidos sobre el mismo error o si el tercer push sale en
rojo. PR en borrador y un comentario en él: error literal, lo probado y tu
hipótesis. No amplíes el alcance.
````

### 3.3 T-01 · Test de autocorrelación (oleada 1)

Se lanza con R-01 en `main`. Conviene fusionarlo después de P-01, que cambia `EngineCommand` en la misma oleada. Cursor entrega solo el test. El enganche al modo largo y los WAV son de Claude.

````text
# BRIEF T-01 · Test de autocorrelación de las texturas
Agente: Cursor                         Revisor: Codex
Rama: cursor/t-01-autocorrelacion      Base: main@<sha corto>
Worktree y simulador: no aplica. Nube, sin Xcode.

## Objetivo
La app dice que su sonido se genera y no se repite. Este test lo comprueba:
renderiza cada textura sin motor de audio y mide si la señal se parece a sí misma
desplazada. Tiene un control que sí se repite, para demostrar que el test detecta
un bucle. Solo se añaden ficheros de test.

## Lee antes (y nada más)
- AGENTS.md
- docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md, ficha C53 (línea 777).
- docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md: ficha nunca-se-repite (línea
  327) y §7, párrafo "Tests, CI y renders de referencia" (línea 617).
- Código, solo lectura: SleepNoiseTests/DSPGeneratorTests.swift (clase
  StereoRenderTests, como patrón de render), SleepNoiseTests/Spectrum.swift,
  SleepNoise/Audio/DSP/RenderState.swift, EngineCommand.swift, SoundGains.swift
  y XorShift32.swift.

## Ficheros que puedes tocar (lista cerrada, todos nuevos)
- SleepNoiseTests/Autocorrelation.swift        (ayudante puro, como Spectrum.swift)
- SleepNoiseTests/AutocorrelationTests.swift

## Ficheros prohibidos en este paquete
Todo lo que hay bajo SleepNoise/. Spectrum.swift y los demás tests existentes.
scripts/verify.sh, .github/, project.yml y docs/.

## Qué construir
1. Render. Por cada caso de SoundID.allCases: un RenderState a 44 100 Hz, esa
   textura a ganancia 1 y el resto a 0, la Marea apagada. Descarta los 3 primeros
   segundos para saltar el fundido de entrada. Usa el canal izquierdo.
   Construye el EngineCommand en un único ayudante privado y por asignación de
   propiedades, no con el inicializador de miembros:
       var command = EngineCommand()
       command.gains.set(sound, 1)
       command.envelopeTarget = 1
       command.rampSamples = 1
       command.generation = 1
       command.envelopeGeneration = 1
   Así un campo nuevo con valor por defecto no rompe el test.
2. Medida. Blanquea con la primera diferencia, reduce la frecuencia por 4 sumando
   bloques y calcula la autocorrelación normalizada de todos los retardos del
   tramo con una FFT de Accelerate (vDSP), rellenando con ceros hasta el doble de
   la longitud. Un cálculo directo retardo a retardo no cabe en tiempo. El
   resultado por textura es el máximo en valor absoluto y el retardo donde cae.
3. Dos modos. Se elige con la variable de entorno que nombre AGENTS.md para el
   modo largo. Si AGENTS.md no la nombra, usa SN_LONG_TESTS=1 y dilo en el PR.
   - Rápido, por defecto: 20 s por textura, retardos de 2 a 8 s. Control con un
     bucle de 3 s. Todo el fichero en menos de 60 s.
   - Largo: 600 s por textura, retardos de 5 a 300 s. Control con un bucle de 30 s.
4. Control. Una señal de ruido blanco de XorShift32 con semilla fija, repetida en
   bucle. El test del control pasa cuando el detector supera el umbral.
5. Umbral. Una constante con nombre. Valor provisional 0,05. Cada test imprime por
   textura el máximo medido y su retardo. El revisor mide el modo largo en el Mac
   y fija el valor final.
6. Si una textura tiene un componente periódico por diseño, como un zumbido, no lo
   confundas con un bucle. Dale un umbral propio con nombre y explica por qué en
   un comentario. No subas el umbral común para taparlo.

## Pasos
1. Lee lo citado. Copia el patrón de render de StereoRenderTests.
2. Escribe Autocorrelation.swift: funciones puras sobre [Float], sin XCTest.
3. Escribe AutocorrelationTests.swift. Un solo push. Abre el PR y termina. No
   esperes a la CI.
4. Los máximos impresos por textura los copia Claude en el PR desde el log de
   la CI. El umbral final se fija después de A-02a, que cambia el PRNG.

## Cómo escribir para que compile a la primera
- Swift 5.9, iOS 17. Los avisos son errores.
- Imports: XCTest, Accelerate y `@testable import SleepNoise`.
- Con vDSP usa la FFT real clásica (vDSP_create_fftsetup, vDSP_fft_zrip,
  vDSP_destroy_fftsetup). Si no estás seguro de una firma, no la inventes:
  declara el atasco.
- Reserva los arrays una vez por textura: el modo largo mueve unos 26 millones
  de muestras. Sin Date(), sin esperas, sin ficheros.

## Criterio de aceptación
Tests con estos nombres:
- testHelperFindsAKnownLag: una señal sintética con repetición a un retardo
  conocido da un máximo cercano a 1 en ese retardo. Ruido blanco sin repetir da
  menos que el umbral.
- testControlLoopIsDetected: el control supera el umbral cerca del retardo del bucle.
- testNoTextureRepeats: recorre SoundID.allCases, sin lista escrita a mano. Una
  textura nueva queda cubierta sin tocar el test.
- testEveryTextureProducesSound: el RMS de cada render es mayor que 0,001, para
  que una textura muda no pase por "no se repite".
Cada test lleva un comentario que dice qué cambio lo pondría en rojo.

Comprobaciones que puedes ejecutar tú:
    git diff --name-only origin/main...HEAD     # exactamente los dos ficheros
    git diff --stat origin/main...HEAD -- SleepNoise/     # vacío
    grep -n 'allCases' SleepNoiseTests/AutocorrelationTests.swift     # al menos una

La prueba que cuenta es el check de CI del PR en verde, que corre el modo rápido.
El modo largo lo ejecuta el revisor en el Mac:
    SN_SIM='iPhone Air' scripts/verify.sh
    TEST_RUNNER_SN_LONG_TESTS=1 xcodebuild test -project SleepNoise.xcodeproj -scheme SleepNoise \
      -destination 'platform=iOS Simulator,name=iPhone Air' -only-testing:SleepNoiseTests/AutocorrelationTests

## Cadenas
Ninguna.

## Fuera de alcance
Escribir WAV. Tocar verify.sh o la CI. Cambiar cualquier textura o generador,
aunque el test encuentre una que se repite: en ese caso no la arregles ni la
excluyas. Deja el test como está, aunque la CI quede en rojo, y explica el
hallazgo en el PR. Decide Claude.

## Entrega
Un PR contra main. Título: T-01 · Test de autocorrelación de las texturas.
Descripción en español con la plantilla del repo: secciones leídas, ficheros,
la frase "No he compilado ni ejecutado nada en local." y, como no
verificado, el modo largo y el umbral final. El enlace a la CI, los máximos por
textura y la duración del fichero de tests los añade Claude desde el log.

## Si te atascas
Para tras dos intentos fallidos sobre el mismo error o si el tercer push sale en
rojo. PR en borrador y un comentario en él: error literal, lo probado y tu
hipótesis. No amplíes el alcance.
````

### 3.4 B-05a · Políticas puras de interrupción y de ruta (oleada 2)

Se lanza con P-03a fusionado y con X-02 y X-03 aplicados a las specs 07 y 09. El cableado es B-05b, de Codex.

````text
# BRIEF B-05a · Políticas puras de interrupción y de ruta
Agente: Cursor                         Revisor: Codex
Rama: cursor/b-05a-politicas           Base: main@<sha corto>
Worktree y simulador: no aplica. Nube, sin Xcode.

## Objetivo
Decidir con funciones puras qué hace la app cuando el sistema la interrumpe y
cuando cambia la salida de audio. De noche un error aquí despierta a alguien: el
ruido que vuelve tras la alarma, o el altavoz que suena solo. Este paquete
entrega las reglas y sus tests de tabla. No toca la sesión de audio.

## Lee antes (y nada más)
- AGENTS.md
- docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md: fichas C48 (línea 708), C49
  (línea 722) y C41 (línea 611). Mandan sobre las specs.
- docs/design/09-ECOSISTEMA.md §4.4, la tabla de interrupciones (ya con su
  sección 12, de X-03).
- docs/design/07-TEMPORIZADOR-NOCHE-MADRUGADA.md §4.3, reglas 2, 3, 8 y 9 (ya
  con su sección 12, de X-02).
- docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md §7, párrafo "Sesión de audio".

## Ficheros que puedes tocar (lista cerrada, todos nuevos)
- SleepNoise/Audio/InterruptionPolicy.swift
- SleepNoise/Audio/RoutePolicy.swift
- SleepNoiseTests/InterruptionPolicyTests.swift
- SleepNoiseTests/RoutePolicyTests.swift

## Ficheros prohibidos en este paquete
Todos los demás. En especial AudioSessionObserver.swift,
AudioSessionConfigurator.swift, SleepAudioEngine.swift, NowPlayingController.swift,
MixerModel.swift, NightWindow.swift, project.yml, scripts/, .github/ y docs/.

## Qué construir
Solo `import Foundation`. Nada de AVFoundation ni CallKit: las entradas son tipos
propios. Traducir las notificaciones del sistema es de B-05b.

    enum InterruptionCause: Equatable { case system, call }
    enum InterruptionOutcome: Equatable {
        case resume(fadeIn: TimeInterval)
        case endSession
    }
    enum InterruptionPolicy {
        static let resumeFade: TimeInterval = 3
        static func morningWindow(around date: Date, mantoEnd: Date?,
                                  calendar: Calendar = .current) -> DateInterval
        static func outcome(cause: InterruptionCause, beganAt: Date, mantoEnd: Date?,
                            calendar: Calendar = .current) -> InterruptionOutcome
    }

    enum RoutePolicy {
        static let routeLossFade: TimeInterval = 0.04
        static let headphonePauseFade: TimeInterval = 3
        static let speakerPauseFade: TimeInterval = 1.5
        static let speakerOfferDuration: TimeInterval = 60
        static let resumeCap: Float = 0.4
        static func resumesAloneAfterRouteLoss(onSpeaker: Bool) -> Bool
        static func speakerOfferIsVisible(pausedAt: Date, now: Date) -> Bool
        static func masterOnResume(current: Float, routeChangedSincePause: Bool) -> Float
        static func fadeOutForPauseCommand(headphonesConnected: Bool) -> TimeInterval
    }

Reglas de interrupción (C48):
- La ventana de la mañana va de las 05:00 a las 11:00 del día de beganAt.
- Si hay Manto, la ventana empieza 60 minutos antes del fin del Manto, en lugar
  de a las 05:00. Con Manto hasta las 07:00 empieza a las 06:00.
- Decide el instante en que empieza la interrupción, no el instante en que acaba.
- Dentro de la ventana, cualquier causa termina la sesión, también una llamada.
- Fuera de la ventana, cualquier causa reanuda con fundido de 3 s. Una llamada
  fuera de la ventana nunca termina la sesión.
- Decisión del brief: la spec no fija el final de la ventana cuando hay Manto.
  Aquí termina a las 11:00 o al fin del Manto, lo que sea más tarde. Dilo en el PR.
- Esta ventana no es NightWindow. No la reutilices ni la importes.

Reglas de ruta (C49):
- Al caer la ruta (auriculares fuera, desconectados o sin batería): fundido de
  40 ms y pausa.
- Tras una caída de ruta nunca se reanuda sola por el altavoz.
- "Seguir por el altavoz" se ofrece durante 60 s desde la pausa. A los 60 s
  exactos ya no.
- Al reanudar con un toque, si la ruta cambió desde la pausa, el nivel maestro
  sale como mínimo entre el actual y 0,4. Si no cambió, no se toca.
- Una orden de pausa con auriculares conectados funde en 3 s. Por el altavoz, en
  1,5 s.

## Pasos
1. Lee lo citado. Si la reconciliación y una spec no coinciden, gana la
   reconciliación y lo anotas en el PR.
2. Escribe las dos políticas, con un comentario `///` en inglés por regla que
   cite la ficha.
3. Escribe los tests con un calendario fijo (Europe/Madrid) y un ayudante que
   construya instantes por hora y minuto.
4. Repasa el diff entero. Un solo push. Abre el PR y termina. No esperes a la
   CI: su resultado te llega en un comentario con @cursor.

## Cómo escribir para que compile a la primera
- Swift 5.9, iOS 17. Los avisos son errores. Nada sin usar.
- En los tests: sin Date(), Calendar.current ni TimeZone.current. Compara Float
  y TimeInterval con `accuracy:`.

## Criterio de aceptación
En InterruptionPolicyTests:
- testThreeInTheMorningResumes: 03:00, sin Manto, causa system: resume con 3 s.
- testHalfPastSixEnds: 06:30, sin Manto: endSession.
- testWindowEdgesWithoutManto: 04:59 reanuda, 05:00 termina, 10:59 termina, 11:00
  reanuda.
- testMantoMovesTheStartOfTheWindow: Manto hasta las 07:00. 05:30 reanuda, 06:00
  termina, 06:30 termina.
- testCallOutsideTheWindowNeverEnds: llamada a las 03:00 y a las 23:30: resume.
- testCallInsideTheWindowEnds: llamada a las 06:30: endSession.
- testMantoPastElevenExtendsTheWindow: Manto hasta las 12:00. 11:30 termina.
En RoutePolicyTests:
- testRouteLossFadeIsFortyMilliseconds: la constante routeLossFade vale 0,04.
- testNeverResumesAloneOnSpeaker.
- testSpeakerOfferLastsSixtySeconds: 0 s y 59 s visible, 60 s y 61 s no.
- testResumeIsCappedOnlyWhenTheRouteChanged: actual 1,0 y ruta cambiada da 0,4.
  Actual 0,25 y ruta cambiada da 0,25. Actual 1,0 sin cambio da 1,0.
- testPauseCommandFades: 3 s con auriculares, 1,5 s por el altavoz.
Cada test lleva un comentario que dice qué cambio lo pondría en rojo.

Comprobaciones que puedes ejecutar tú:
    git diff --name-only origin/main...HEAD     # exactamente los cuatro ficheros
    grep -n '^import ' SleepNoise/Audio/InterruptionPolicy.swift SleepNoise/Audio/RoutePolicy.swift
        # solo import Foundation
    grep -nE 'AVAudioSession|CXCall|NightWindow|outputVolume' \
        SleepNoise/Audio/InterruptionPolicy.swift SleepNoise/Audio/RoutePolicy.swift
        # ninguna línea

La prueba que cuenta es el check de CI del PR en verde. El revisor ejecuta en el Mac:
    SN_SIM='iPhone Air' scripts/verify.sh
    xcodebuild test -project SleepNoise.xcodeproj -scheme SleepNoise \
      -destination 'platform=iOS Simulator,name=iPhone Air' \
      -only-testing:SleepNoiseTests/InterruptionPolicyTests -only-testing:SleepNoiseTests/RoutePolicyTests

## Cadenas
Ninguna.

## Fuera de alcance
Tocar la sesión de audio o el motor. El volumen del sistema, que nunca se toca.
Los 20 minutos en pausa, CarPlay, el reinicio de servicios de audio, la
reconexión de auriculares y la latencia de AirPlay: son de B-05b.

## Entrega
Un PR contra main. Título: B-05a · Políticas puras de interrupción y de ruta.
Descripción en español con la plantilla del repo: secciones leídas, ficheros,
la frase "No he compilado ni
ejecutado nada en local.", las decisiones de spec que has tomado y, como no
verificado, el comportamiento real con llamadas, alarma y auriculares (H-03).
El enlace a la CI lo añade Claude.

## Si te atascas
Para tras dos intentos fallidos sobre el mismo error o si el tercer push sale en
rojo. PR en borrador y un comentario en él: error literal, lo probado y tu
hipótesis. No amplíes el alcance.
````

---

## 4. Oleadas posteriores

| Paquete | Ol. | Depende de | Revisor | Nota |
|---|---|---|---|---|
| A-02c Tests del criterio de texturas | 2 | A-02b, I-02 | Codex | Rama `cursor/a-02c-criterio-texturas`. Solo ficheros nuevos: `SleepNoiseTests/TextureCriteria.swift` y `TextureCriteriaTests.swift`. Cresta menor de 12 dB, eventos a 6 dB o menos sobre el fondo, centroide distinto. No toca texturas ni el PRNG: eso es de Codex en A-02a y A-02b. Brief pendiente hasta fusionar A-02b. Suplente: Kimi |

En las oleadas 3, 4 y 5 Cursor no tiene paquetes. Esperan sus entregas: P-03b (P-03a), P-04b y C-01 (P-04a), D-06 y H-06a (T-01), B-05b (B-05a).

## 5. Lista del revisor para un PR de Cursor

1. La CI está en verde. Si no, no se revisa.
2. `git diff --name-only origin/main...HEAD` da solo la lista cerrada del brief.
3. No toca `.github/`, `scripts/`, `project.yml`, catálogos ni tests existentes. Sin `XCTSkip`.
4. `scripts/verify.sh` pasa en el worktree del revisor, sin avisos. El número de tests sube en los nuevos.
5. Cada línea del criterio tiene su test. Cada test puede fallar: el revisor rompe una regla a mano y lo ve en rojo.
6. Imports: solo los del brief. Ninguna API de Apple fuera de Foundation, salvo `Accelerate` en T-01.
7. Tests sin `Date()`, `Calendar.current`, `TimeZone.current`, esperas ni red.
8. Las firmas coinciden con el brief. Las decisiones de spec están en el PR.
9. El PR lleva la frase de no compilado y solo afirma lo que hay en el diff. El enlace a la CI lo añade Claude.
10. T-01: modo largo ejecutado en el Mac y umbral final anotado, después de A-02a. A-02c: los umbrales se contrastan con los renders de A-02b.
11. Rondas contadas. A la segunda vuelta fallida se reasigna (plan §3.7). Si el suplente fuera el revisor, cambia el revisor (plan §2.3).

## 6. Puntos que estaban abiertos y cómo quedan

1. **Dónde lee Cursor los documentos.** Cerrado: `docs/` llega a `main` por PR el día 1 (plan §9). Los briefs ya no llevan la línea de `git show`.
2. **Firma de SaleGate.** 04 A12 usa `NightPhase` y `ScenePhase` y sitúa los tres tipos en `Design/SystemStyled.swift` (DS-02). P-03a no depende de DS-01. El brief usa `Bool` y `Model/NightWindow.swift`. Cerrado: DS-02 tiene prohibido declararlos y solo añade la sobrecarga como extension si P-03a ya está en `main`. Si no, la añade A-03a (plan §3.9).
3. **Umbral de T-01.** Cursor no puede medirlo. Lo fija el revisor, después de A-02a. El modo largo no es puerta de PR.
4. **A-02.** Cerrado: se parte. El PRNG (A-02a) y el trueno y la hoguera (A-02b) son de Codex. Cursor solo escribe los tests del criterio (A-02c), en ficheros nuevos.
5. **Si Cursor ve la CI.** Sigue abierto [SV]. Mientras tanto Claude pega el resultado en el PR.
