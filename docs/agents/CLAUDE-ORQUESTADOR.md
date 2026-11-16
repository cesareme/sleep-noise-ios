> **Aviso (16-11-2026):** sustituido para 1.0 por `docs/PLAN-SIMPLE-1.0.md`. Se conserva como referencia.

# Claude Code · orquestador, revisor e integrador

Fecha: 16-11-2026. Acompaña a `docs/PLAN-DESARROLLO-AGENTES-2026-11-16.md` y no lo sustituye. Si algo de aquí lo contradice, manda el plan. Si el plan contradice a la reconciliación, manda la reconciliación. Las reglas comunes están en `AGENTS.md`. Aquí solo va lo propio de Claude Code.

Nada de esto se ha ejecutado todavía. Los comandos marcados [SV] se confirman con `--help` antes de lanzarlos.

---

## 1. El papel en seis líneas

1. Escribe los briefs y lanza cada paquete cuando sus dependencias están en `main` y su zona caliente está libre.
2. Es el único que edita en `main` `project.yml`, `Info.plist`, los entitlements, el catálogo de cadenas, `scripts/verify.sh`, la CI y `AGENTS.md`.
3. Es el único que hace push de las ramas locales de Codex y Kimi, y el único que abre sus PR.
4. Revisa todo lo que escribe Codex, todo el carril de audio y todo lo que toca zona caliente, specs o catálogo.
5. Integra: lee el diff de todo lo que entra, repite la verificación en su worktree y fusiona.
6. Prepara las sesiones del dueño, escribe sus actas y mantiene el tablero de estado.

**Lo que Claude no hace.**

- No escribe lo que tiene que revisar. Como autor solo lleva los cuatro paquetes de §2.
- No reescribe entregas ajenas. Su tope de arreglo en la integración es de unas 30 líneas, anotadas en el PR.
- No fusiona nada que no haya pasado las seis puertas en orden (§4 y §5).
- No publica en GitHub, no cambia ajustes del repo ni de las cuentas y no gasta sin permiso expreso del dueño. Esto incluye el primer push de `docs/`, la protección de `main` y cualquier comentario en un PR ajeno. Única excepción prevista: la autorización general que el dueño da el día 1 para devolver el log de la CI en los PR de Cursor. Antes de cualquier push el dueño decide la visibilidad del repo, que hoy es público.
- No da por cerrado nada de audio sin la escucha del dueño.
- No decide el escenario de la decisión 3 ni recorta alcance. Presenta los datos y decide el dueño.
- No entrega a ningún agente credenciales, cuentas de sandbox ni acceso a Connect.

---

## 2. Paquetes propios

| Id | Qué | Rama | Depende de | Revisor | Puerta propia |
|---|---|---|---|---|---|
| I-01 | `scripts/verify.sh` con semáforo de dos plazas (PID por plaza, libera la de un PID muerto, sale con 75 a los 30 minutos) y variables `SN_SIM` y `SN_DERIVED`. Guarda el log y falla con cualquier aviso, también los del procesador de metadatos de App Intents. Modo `--bench` con `SleepNoiseTests/RenderCostTests.swift` y línea base en `docs/research/bench/BASELINE.md`. Target `SleepNoiseUITests` vacío. `.build/` en `.gitignore`. `TARGETED_DEVICE_FAMILY: "1"` | `claude/i-01-verify` | nada | Codex | 49 tests en verde. Falla con un error sembrado y con un aviso sembrado. Menos de 10 minutos |
| I-03 | `.cursor/rules/sleepnoise.mdc` que solo remite a `AGENTS.md`, plantilla de PR y resto de briefs. `AGENTS.md`, `docs/` y los briefs de I-02 y F-02 ya entraron en `main` el día 1 | `claude/i-03-agents-md` | I-01 | Codex | `AGENTS.md` por debajo de 32 KiB. Cada ruta de "Lee antes" existe en `origin/main` |
| F-01 | Motor tras un protocolo inyectado en `MixerModel`. `MixerModel` partido en extensiones por fichero. Primeros tests con motor de pega. Ficheros: `SleepNoise/Audio/AudioEngineControlling.swift` (protocolo), `SleepNoiseTests/FakeAudioEngine.swift` (doble), `MixerModel.swift` y sus extensiones nuevas, `SleepAudioEngine.swift` solo para declarar la conformidad, y `MixerModelTests.swift`. Protocolo y doble incluyen `setMaster` de P-01 | `claude/f-01-motor-protocolo` | R-02, P-01 | Codex | Puertas 1 a 5. Sin cambio de comportamiento |
| P-04b | App Group, `MixStore` al contenedor compartido, entitlements y target de widgets vacío en `project.yml` | `claude/p-04b-app-group-widgets` | P-04a, F-01 | Codex | Puertas 1 a 5. Los dos targets compilan en simulador |

En estos cuatro Claude es un autor más: rama propia, lista cerrada de ficheros y revisión de Codex antes de fusionar. No se salta ninguna puerta por ser el integrador.

**Trabajo propio que no es un paquete.**

- Briefs en `docs/briefs/<id>.md` (plantilla en §9).
- Commits de preparación en `project.yml`, `Info.plist` o entitlements antes de lanzar L-01, C-03, D-02 y D-04. El de S-02 vive solo en la rama del spike y nunca llega a `main`.
- El PR del día 1 que lleva `docs/`, `docs/agents/` y `AGENTS.md` de `research/plan-sueno` a `main`, con permiso del dueño.
- El PR de control de la CI (`claude/ci-control-pr3`), que se cierra sin fusionar.
- La línea base `docs/research/bench/BASELINE.md`, que actualiza al integrar cada turno de audio.
- La copia del mockup con la opción (b) del acento, antes del 27-11-2026.
- El fichero local sin versionar `Signing.local.xcconfig` con el equipo de firma que dé el dueño.
- Push y PR de las ramas de Codex y Kimi.
- Notas de spike: las lleva a `main` desde `docs/research/spikes/` en un commit aparte. La rama del spike no se fusiona.
- Enganche del test de T-01 al modo largo de `scripts/verify.sh` y de la CI.
- La línea de registro de cada hoja en `PageView.swift` y de cada componente en `SystemGallery.swift`, que tras A-03 y DS-02 son solo de Claude.
- La columna Estado de `docs/PLAN-MAESTRO-2026-11-16.md` cuando se integran X-01, X-02 y X-03.
- La retirada final de `Theme.swift`.
- Las actas de H-01 a H-06b en sus ramas `claude/h-...`, con lo que el dueño dicte.
- El tablero `docs/agents/ESTADO.md` (§7).

---

## 3. Lanzar un paquete

**Antes de lanzar.** Las siete condiciones deben ser ciertas:

1. Todas sus dependencias figuran como integradas en el tablero.
2. Su zona caliente está libre según la tabla de turnos del plan §3.9. Si el turno anterior sigue abierto, el paquete espera.
3. Hay menos de cuatro PR abiertos (plan §3.6).
4. Si necesita un cambio en `project.yml`, `Info.plist` o entitlements, el commit de preparación ya está en `main`.
5. El brief está escrito, cabe en una pantalla y cita secciones y fichas, no documentos enteros.
6. El agente tiene worktree, simulador asignado y cuota para empezar.
7. El brief y cada ruta de "Lee antes" existen en la base: `git cat-file -e origin/main:<ruta>` para cada una.

**Worktree y simulador.**

```
git fetch origin
git worktree add ~/wt/sleepnoise/<agente>-<id> -b <agente>/<id>-<slug> origin/main
```

| Quién | Simulador |
|---|---|
| Claude, integración y revisión | iPhone 17 |
| Codex, autor | iPhone 17 Pro |
| Kimi | iPhone 17e |
| Codex, revisor | iPhone Air |
| Reserva para tests de interfaz largos | iPhone 17 Pro Max |

Como mucho dos `xcodebuild` a la vez en el Mac. Lo impone el semáforo de `scripts/verify.sh`. Como mucho tres worktrees que compilan a la vez: uno de autor de Codex, uno de autor de Kimi y uno de Claude o de revisión. Codex puede tener dos de autor si uno es del carril de audio y el otro no toca zona caliente (plan §3.2). Kimi: dos paquetes a la vez hasta confirmar su plan, contando los de solo documentos.

**Cómo recibe la tarea cada agente.**

```
CODEX="/Applications/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"
WT=~/wt/sleepnoise/codex-<id>; mkdir -p "$WT/.build"
"$CODEX" exec -C "$WT" -s "$MODO" -o "$WT/.build/ENTREGA.md" < "$WT/docs/briefs/<ID>.md"       # MODO: opción A o B
cd ~/wt/sleepnoise/kimi-<id> && kimi --print --quiet -w "$PWD" -p "$(cat docs/briefs/<ID>.md)"  # [SV]
```

La orden de Codex es la de `docs/agents/CODEX.md` §1.2. Sin `-o`, el mensaje final, que es la descripción del PR, solo sale por la salida estándar. El brief se lee desde dentro del worktree: por eso tiene que estar en `origin/main` (condición 7).

**Tope de reloj.** Cada lanzamiento va en segundo plano con tope: 90 minutos si el paquete es de hasta 2 días, 3 horas el resto. Al vencer, Claude mata el proceso. En la opción A de Codex, Claude compara `git ls-remote --heads origin` antes y después de la sesión.

- Codex: se usa la opción que eligió el dueño el día 1 (plan §9). Opción A: `danger-full-access` con `pushurl` bloqueado en el worktree. Opción B: `workspace-write`, y Claude ejecuta `scripts/verify.sh` y hace los commits. Los worktrees de `--worktree` no se usan.
- Kimi: el modo print aprueba todas las herramientas. Siempre en worktree aislado, sin push y con lista cerrada. Con la CLI nueva la orden es `kimi -p` [SV].
- Cursor: el brief se pega en un issue de GitHub con el mismo texto. Solo después de I-02 e I-03, y solo paquetes de lógica pura en ficheros nuevos. Cursor abre el PR y termina. El resultado de la CI se lo pega Claude en un comentario.

Al lanzar, el tablero pasa a "en curso" y se anota la base (`main@<sha corto>`).

---

## 4. Protocolo de revisión de cada PR

Vale para todo PR en el que Claude es el revisor nombrado. Si el revisor es Codex, Claude hace igualmente los pasos 0, 1, 2 y 6 al integrar, porque lee el diff de todo lo que entra.

**Paso 0. Admisión.** Una entrega que no compila o no pasa los tests no se revisa. Vuelve al autor con el log de `scripts/verify.sh` o de la CI y cuenta como una ronda. Para Cursor, la CI en verde es condición para empezar.

**Paso 1. Compilar y probar en el worktree de Claude.**

```
git worktree add --detach ~/wt/sleepnoise/claude-rev-<id> <agente>/<id>-<slug>
cd ~/wt/sleepnoise/claude-rev-<id>
SN_SIM='iPhone 17' scripts/verify.sh
```

Va con `--detach` porque Git no deja sacar una rama que ya está abierta en el worktree del autor, que sigue vivo por si hay segunda ronda. Debe devolver 0 y sin avisos. El número de tests no baja respecto a `main` y ningún test se ha desactivado o debilitado. El worktree de revisión se borra al dar el veredicto.

**Paso 2. Alcance del diff.**

```
git diff --name-only origin/main...HEAD
```

La lista debe coincidir con "Ficheros que puedes tocar" del brief. Un fichero de más es motivo de devolución, sobre todo si es zona caliente, `project.yml`, `docs/` o el catálogo editado a mano. Se comprueba también: ninguna dependencia nueva, ningún `URLSession`, ningún `import CoreMotion`, ningún fichero de audio.

**Paso 3. Criterio de aceptación.** Cada línea del brief se empareja con un test con nombre o con un grep. Los greps se repiten, no se dan por buenos por el texto del PR.

**Paso 4. Lectura del diff del hilo de audio.** Obligatoria si el diff toca `SleepNoise/Audio/`. Se lee línea a línea contra las reglas de `AGENTS.md` §4. Lista de comprobación:

- `RenderState` y `EngineCommand` siguen siendo POD. Ningún `Array`, `String`, `Optional` de clase, clase ni closure.
- Ninguna asignación, lock, `DispatchQueue`, `print` ni `Date()` dentro del camino de render.
- Todo campo nuevo de `EngineCommand` está en los cuatro sitios: el struct, `RenderState`, `publishCurrent` y el test de desgarro, que desde R-01 es por bytes (`SeqlockTearTests`).
- Todo método público nuevo de `SleepAudioEngine` está también en `AudioEngineControlling.swift` y en `FakeAudioEngine.swift`.
- Una rampa en curso sobrevive a `prepare(sampleRate:)`: conserva la fracción recorrida y la duración restante.
- Todo parámetro nuevo entra suavizado. Ningún escalón.
- Los eventos son contadores. No hay cola ni estado que el lector pueda perder.
- Duraciones y fases en muestras enteras.
- Coeficientes calculados en `prepare()`, no en el render.
- Salida acotada, sin NaN, a 22,05, 44,1, 48 y 96 kHz.
- `scripts/verify.sh --bench`: la mediana no sube más del 10 % sobre `docs/research/bench/BASELINE.md`. La mide el autor y la repite Claude con el Mac en reposo. El coste real en un A15 se mide con Instruments en H-03.
- Los tests existentes de envolvente y de Marea siguen en verde sin haberse tocado.

Ayuda rápida, que no sustituye a la lectura:

```
git diff origin/main...HEAD -- SleepNoise/Audio/DSP | grep -nE '^\+.*(\[[A-Za-z]|Array|String|class |DispatchQueue|NSLock|malloc|print\(|Date\()'
```

Un paquete de audio se aprueba como código, no como sonido. El PR deja escrito a qué sesión del dueño queda la escucha (H-02a, H-02b o H-03).

**Paso 5. Captura en simulador contra la spec.** Obligatoria si el diff toca vistas.

- Se lanza la app o la galería DEBUG en el iPhone 17 y se captura cada estado que nombra el brief: `xcrun simctl io 'iPhone 17' screenshot <ruta>.png`. Las capturas se guardan fuera del repo y se adjuntan al PR.
- Se comparan con la sección exacta de la spec que cita el brief y con la ficha de la reconciliación. No con el gusto del revisor.
- Se mira siempre: fase de día y fase de noche, tamaño normal y AX5, Reduce Motion, y que no haya candados, cifras de precio ni recuentos de texturas.
- Se comprueba la regla de la noche con el reloj inyectado: ninguna superficie de venta entre las 21:00 y las 07:00.
- Lo que el simulador no garantiza se anota para H-03 o H-05: Auto-Lock, StandBy, bloqueo, voz, háptica.

**Paso 6. Lint de copy.** Obligatorio si el diff toca cadenas.

- Desde L-01 va dentro de `scripts/verify.sh`. Antes de L-01 se pasa a mano con las listas de `docs/design/10-GUIA-DE-COPY.md` §0.5, cada lista sobre su idioma.
- Toda clave nueva tiene inglés y español. El paquete trae su fragmento `strings/<id>.json` además del catálogo fusionado.
- Vocabulario de la reconciliación §3. Ninguna palabra de la lista que no se graba.
- Ninguna afirmación sobre efectos en el sueño o la salud (10 §0.4), sin excepción.
- Los números visibles salen del código. Ninguna cadena lleva cifra de precio ni recuento de texturas.

**Paso 7. Veredicto.** Un comentario en el PR con tres partes: lo comprobado con su resultado, los hallazgos ordenados por gravedad (bloqueante, mayor, menor) con fichero y línea, y lo que queda sin verificar en dispositivo con su paquete H. El veredicto es uno de tres: aprobado, cambios pedidos (cuenta una ronda) o parado.

**Rondas.** Si un paquete vuelve dos veces al mismo autor sin pasar las puertas 1 a 4, Claude lo para, escribe el diagnóstico en el PR y lo reasigna al suplente con lo aprovechable de la rama. No hay tercera ronda con el mismo agente. Si el suplente es el revisor nombrado, cambia el revisor: nunca autor igual a revisor (plan §2.3). El carril de audio no cambia de escritor a mitad de paquete.

**Cuando el revisor es Codex.** `codex exec review` no admite `-C` ni `-s` y corre en solo lectura. Claude crea `~/wt/sleepnoise/codex-rev-<id>` con `--detach`, ejecuta él `SN_SIM='iPhone Air' scripts/verify.sh > .build/verify.log 2>&1` y después lanza la revisión desde dentro del worktree, con `--base origin/main -o .build/REVISION.md` (orden completa en `docs/agents/CODEX.md` §1.4) [flags V, comportamiento SV]. Los hallazgos de Codex se pegan en el PR. Si Codex no puede revisar, Claude revisa lo de Kimi y lo de Cursor, y los cuatro paquetes de Claude esperan a Codex o los aprueba el dueño con el diff y el log (plan §2.3). Si el paquete es de Kimi y toca `MixerModel` u otra zona caliente aunque el revisor nombrado sea Codex, Claude lee esa parte del diff con el mismo cuidado que si fuera el revisor.

---

## 5. Orden de integración

**Puertas, en orden (plan §3.5).** 1 verificación local del autor. 2 lint de copy. 3 CI en el PR. 4 revisión cruzada. 5 integración. 6 dispositivo, que no bloquea la fusión salvo en R-02 (espera a H-02a) y en A-05 (solo existe si H-02b lo aprueba).

**Qué se atiende primero cuando hay cola.**

1. Lo que está en la ruta crítica: I-01, I-02, R-01, R-02, S-04, P-01, F-01, P-02, P-03b, A-03a, B-01, B-03, B-04, D-01a, D-01b, D-02, Q-01. Y los once paquetes de Cursor y Kimi de los que depende, con plazo de corte de tres días laborables (plan §2.2, R7): P-03a, P-04a, F-02, DS-01, DS-03, S-01, X-01, X-02, X-03, L-01 y C-01.
2. Lo que libera una zona caliente para el siguiente turno.
3. Lo demás, por antigüedad. Un PR que espera más de dos días envejece.

**Orden por oleada.** Es el del plan §4. Lo que no se puede alterar:

- Oleada 0: el PR de `docs/` a `main` y I-01 primero. Después I-03, I-02 y F-02. R-01 tras I-02 y tras cerrar el PR de control de la CI. R-01 se fusiona en cuanto pasa las puertas 1 a 5, si el dueño aceptó esa excepción el día 1. Si no, espera a H-02a. R-02 espera a H-02a. X-01 y X-02 arrancan tras I-03, y X-03 cuando entregue el primero.
- Oleada 1: P-01 tras R-01 y S-04, sin esperar a R-02. F-01 tras R-02 y P-01. P-02 antes de P-03b. P-03a antes de P-03b. P-04a antes de P-04b. L-01 tras R-02 y F-02. DS-01, DS-02, DS-03 en ese orden.
- Oleada 2: P-05, A-02a, A-02b y A-01 en serie. A-06 en paralelo con P-05. A-02c tras A-02b. A-03a espera a DS-02, DS-03, DS-04, P-03b, F-01, X-01 y L-01. A-03b tras A-03a. B-01 espera además a X-02.
- Oleada 3: A-04 tras A-03b. C-04 tras C-03 y A-04. B-03 tras B-01, DS-05, A-03a y X-02.
- Oleada 4: B-04, D-01a, D-01b, D-02 y D-03 en serie. A-05 solo si H-02b dice que pasa. D-04 solo en escenario A, con un sí escrito del dueño. E-02 tras las hojas. H-03 espera además a D-07.
- Oleada 5: Q-01, H-05, H-06a, H-06b.

**Carril de audio, un escritor y en serie.** R-01, S-04 (spike, no se fusiona), P-01, P-05, A-02a, A-02b, A-01, A-05. No se abre un turno hasta que el anterior está en `main`. R-02 va en paralelo con P-01: solo toca `ThunderTexture.swift`. A-06 va en paralelo con P-05: no toca el contrato. A-02c (Cursor) son solo tests en ficheros nuevos. B-05b toca `SleepAudioEngine` fuera del render y espera a que no haya turno abierto. D-07 no toca `SleepNoise/Audio/`: implementa el `DiagnosticsSink` que deja B-05b.

**Pasos de la integración (puerta 5).**

```
git worktree remove ~/wt/sleepnoise/<agente>-<id>          # el worktree del autor se cierra al aprobar
git fetch origin
git worktree add ~/wt/sleepnoise/claude-int-<id> <agente>/<id>-<slug>
cd ~/wt/sleepnoise/claude-int-<id> && git rebase origin/main
SN_SIM='iPhone 17' scripts/verify.sh
git push --force-with-lease origin <agente>/<id>-<slug>
```

Se espera a la CI sobre ese sha y se fusiona. En un PR de Cursor el push forzado solo se hace con el PR ya aprobado: Cursor no vuelve a tocar esa rama.

1. Actualiza la rama sobre `main`. Los conflictos los resuelve Claude, nunca el agente.
2. En zona caliente no debería haber conflicto. Si lo hay, es un fallo de orquestación: gana lo que ya está en `main` y el segundo paquete se rehace encima.
3. El catálogo de cadenas no se resuelve a mano. Se toma el de `main` y se vuelve a ejecutar `scripts/strings-merge.sh` con el fragmento del paquete.
4. Repite `scripts/verify.sh`. Si falla tras actualizar, el paquete no entra.
5. Comprueba las siete condiciones de la definición de hecho (plan §3.4) y la CI en verde sobre el sha rebasado.
6. Fusiona el PR y borra la rama y el worktree de integración. El tablero se actualiza en el PR diario de documentación (§7).
7. Si el paquete cerraba un turno de zona caliente, lanza el siguiente de la tabla §3.9.

Push, apertura de PR y fusión se hacen con la autorización del dueño. Mientras no la haya dado de forma expresa y general para este flujo, se pide cada vez.

**Límite de PR abiertos.** Cuatro: dos de agentes locales en revisión, uno de Cursor y uno de documentación o infraestructura. Con cuatro abiertos no se lanza nada que vaya a producir un PR en menos de un día.

---

## 6. Atascos, cuota y calibración

Resumen operativo del plan §3.7.

- **Sesión que no termina o termina sin entrega.** Al vencer el tope de reloj, Claude mata el proceso. Una sesión que acaba sin commits nuevos, sin mensaje final y sin `ATASCO.md` cuenta como atasco y como una ronda. Cursor: 24 horas sin PR, o 24 horas en rojo sin push nuevo, cuentan como ronda.
- **Sesión de Claude cortada.** Ningún agente lanza nada por su cuenta. La siguiente sesión reconstruye el estado con `docs/agents/ESTADO.md`, `git worktree list` y `gh pr list` antes de lanzar.
- **Plazo de corte en la ruta crítica.** P-03a, P-04a, F-02, DS-01, DS-03, S-01, X-01, X-02, X-03, L-01 y C-01: tres días laborables de "listo" a "aprobado". Si no, pasan al suplente sin esperar a la segunda ronda. P-03a pasa a Kimi el día 3 si Cursor no está listo.
- **`ATASCO.md` en un worktree.** Claude decide entre acotar el brief, partir el paquete o reasignarlo. El tablero pasa a "atascado" con el motivo.
- **Cuota de Codex agotada.** Sus paquetes en curso esperan. No se pasan a medias a otro agente salvo que el brief sea mecánico. Suplente Kimi solo en P-02, DS-04, DS-05, B-04 y D-03.
- **Calibración de Kimi.** F-02, X-01 y DS-01. Si los tres pasan en dos rondas o menos, conserva DS-03, A-04, B-02, C-02, D-05 y D-06, y además DS-04, DS-05, D-03 y B-04 pasan a Kimi por defecto, con revisión de Claude. Si no, ese carril pasa a Codex y lo revisa Claude.
- **Calibración de Cursor.** P-03a. Si la CI se pone en verde en dos vueltas o menos y Codex no encuentra errores de fondo, sigue con P-04a, T-01, B-05a y A-02c. Si no, pasan a Kimi. La CI la lee Claude y pega el resultado en el PR.
- **Fin de la oleada 2.** Si la media supera las dos rondas por paquete o hay más de cuatro PR en cola de forma sostenida, Claude lleva al dueño una propuesta de recorte y el dueño decide. D-03 se corta sin consulta si no está integrado el 22-02-2027, que es el inicio de la semana 14 (C26). D-04 sigue la decisión 3. A-05 no se recorta por capacidad: la reconciliación §5 y §6 solo permite moverla por el spike I0-7 o por la puerta del bus. Sacarla por otro motivo es una decisión nueva del dueño, escrita en un acta.

Claude anota en cada PR el número de rondas. Es el dato con el que se recalcula la horquilla el 27-11-2026 y el 14-12-2026.

---

## 7. Tablero de estado

Fichero: `docs/agents/ESTADO.md`. Una fila por paquete, con seis columnas: id, agente, rama, estado, PR y revisor. Nace con los 67 paquetes en estado "pendiente".

**Estados.**

| Estado | Significa |
|---|---|
| pendiente | Sin lanzar. Dependencias sin cumplir o turno ocupado |
| listo | Dependencias en `main`, turno libre y brief escrito |
| en curso | Lanzado. El agente trabaja en su worktree |
| entregado | Rama con commits y `scripts/verify.sh` en verde según el autor. PR abierto |
| en revisión | El revisor nombrado está en ello |
| cambios (r1), cambios (r2) | Devuelto al autor. El número es la ronda |
| aprobado | Puertas 1 a 4 pasadas. Espera integración o sesión del dueño |
| integrado | En `main`. Rama y worktree borrados |
| atascado | Hay `ATASCO.md` o un bloqueo externo. Se anota el motivo |
| reasignado | Pasa al suplente. La fila cambia de agente, de rama y, si coincide con el autor nuevo, de revisor |
| cancelado | Recorte o puerta que no pasa (A-05, D-03, D-04) |

**Reglas.**

- Solo Claude lo edita. Ningún agente lo toca.
- Cambia en cuatro momentos: al lanzar, al recibir la entrega, tras cada veredicto y al integrar.
- La columna PR lleva el número cuando existe. Un guion mientras no hay PR.
- La marca "integrado" no va en el PR del paquete: todos los PR abiertos tocarían la misma línea y cada fusión dejaría en conflicto a los demás. Va en el PR diario de documentación, junto con los briefs nuevos y los demás cambios de estado. Así solo ocupa la plaza de documentación del límite de cuatro PR.
- Los contadores de la línea Resumen se recalculan solo en ese PR diario.
- Entre dos actualizaciones, la verdad es el estado del PR. El tablero es el resumen.
- Las correcciones que salgan de las sesiones del dueño se añaden como filas nuevas con el id del acta, por ejemplo `H-03-c1`.
- Bajo la tabla hay un registro breve: fecha, paquete y qué cambió. Sirve para medir días y rondas por agente.

---

## 8. Sesiones del dueño y puntos de medida

Para cada sesión (H-02a a H-06b) Claude prepara una build instalable, la lista de comprobación sacada del criterio de aceptación y la plantilla del acta. El acta la escribe Claude con lo que el dueño dicte, en su rama `claude/h-...`. Una casilla que falla abre un paquete de corrección.

Decisiones con plazo que Claude recuerda y, si vencen sin respuesta, aplica según la recomendación escrita (plan §6.1): acento el 27-11-2026, marca el 04-12-2026, capacidad para la Live Activity el 14-12-2026 y la palabra inglesa de Manto antes de la semana que empieza el 28-12-2026. En la decisión 3, sin un sí escrito del dueño el 14-12-2026 se aplica la reconciliación §6 n.º 3: escenario B, D-04 cancelado y Live Activity a 1.1, aunque se cumplan los cuatro criterios. Claude presenta los datos y no decide el escenario.

Tareas del dueño con fecha que Claude recuerda (plan §6.2): firma antes del 20-11-2026, comprobación legal del nombre el 04-12-2026, hablante de inglés localizado el 11-12-2026, dispositivos de H-03 el 14-12-2026, H-02b y puerta del bus entre el 14-12-2026 y el 03-01-2027, reclutamiento de la beta al abrir la oleada 3.

Puntos de medida:

- **27-11-2026.** Debería estar fusionado R-01. Días de I-01 a PR-A en `main`, rondas por paquete y por agente, minutos de CI gastados y cuota de Codex consumida.
- **14-12-2026.** Claude presenta los cuatro criterios del escenario A: PR-A en `main`, CI como puerta, P-01 integrado sin agotar la cuota y S-02 con respuesta afirmativa. Decide el dueño. Sin respuesta, escenario B.
- **Fin de la oleada 2.** Media de rondas y cola de PR. Si procede, la propuesta de recorte de §6, que decide el dueño.

---

## 9. Plantilla de brief

Los briefs viven en `docs/briefs/<id>.md` y caben en una pantalla. Para Cursor el mismo texto se pega en un issue.

```
# BRIEF <id> · <título>
Agente: <Codex | Kimi | Cursor>     Revisor: <agente>
Rama: <agente>/<id>-<slug>          Base: main@<sha corto>
Worktree: ~/wt/sleepnoise/<agente>-<id>     Simulador: <nombre>

## Objetivo
Dos o tres frases. Qué cambia para quien usa la app o para el siguiente paquete.

## Lee antes (y nada más)
- AGENTS.md
- docs/<fichero> §<sección>, líneas <a>-<b>
- Ficha(s) de la reconciliación: C<nn>

## Ficheros que puedes tocar (lista cerrada)
## Ficheros prohibidos en este paquete
Las zonas calientes que no son tuyas. project.yml siempre.

## Criterio de aceptación
Tests con nombre, greps con resultado esperado, y la orden exacta de verificación.

## Cadenas
Claves nuevas en strings/<id>.json (en y es). Ejecuta scripts/strings-merge.sh.

## Fuera de alcance
## Entrega
Commits en la rama, sin push. Últimas 30 líneas de scripts/verify.sh.
Lista de lo que no has podido verificar (dispositivo, audio real, compra).

## Si te atascas
Para tras dos intentos fallidos sobre el mismo error. Escribe ATASCO.md en la
raíz del worktree con el error, lo probado y tu hipótesis. No amplíes el alcance.
```

Al rellenarla:

- Los ficheros, el criterio y las referencias salen de la ficha del paquete en el plan. No se amplían al escribir el brief.
- En paquetes de audio se añade el criterio de `scripts/verify.sh --bench` (10 % sobre `BASELINE.md`) y la sesión del dueño a la que queda la escucha.
- En paquetes con interfaz se citan la sección exacta de la spec y los estados que hay que capturar.
- Mientras 05, 07 y 09 no tengan su sección 12, el brief cita la ficha C de la reconciliación y no la spec.
- Antes de L-01 no existen `strings/` ni `scripts/strings-merge.sh`. En R-01 y R-02 el apartado Cadenas dice que el catálogo se edita directamente, porque tienen el turno.
