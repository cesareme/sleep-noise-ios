> **Aviso (16-11-2026):** sustituido para 1.0 por `docs/PLAN-SIMPLE-1.0.md`. Se conserva como referencia.

# SleepNoise 1.0 · Plan de desarrollo con agentes

Fecha: 16-11-2026. Estado: propuesta para arrancar el 17-11-2026. Rama de trabajo de los documentos: `research/plan-sueno`.

Este documento reparte el alcance 1.0 cerrado en la reconciliación §5 entre tres agentes externos (Cursor, Codex y Kimi), con Claude Code como orquestador, revisor e integrador. No cambia ninguna decisión de producto ni de diseño. Si algo de aquí contradice a `RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`, manda la reconciliación.

Cuadernos por agente y tablero: `docs/agents/`. Mandan menos que este plan.

Para escribirlo no se compiló, no se ejecutó ningún agente externo y no se tocó código. Lo que no está comprobado se marca como tal. En la revisión del 16-11-2026 sí se probó el perfil de sandbox de Codex con `codex sandbox`, sin sesión de agente (§9).

Leyenda de evidencia: [V] comprobado hoy en el Mac o en documentación oficial. [INF] inferencia. [SV] sin verificar.

---

## 0. Resumen de una página

**Quién hace qué, en cinco líneas.**

1. **Claude Code** orquesta, revisa e integra. Escribe los briefs, es el único que edita `project.yml`, los entitlements y el catálogo de cadenas en `main`, el único que hace push y abre PR de los agentes locales, y el único que fusiona. Como autor solo lleva cuatro paquetes de infraestructura (I-01, I-03, F-01, P-04b).
2. **Codex (local, con Xcode)** lleva lo que no se puede dar por bueno sin compilar y lo que rompe más cuando falla: el hilo de audio entero, el rescate del PR #3, StoreKit, App Intents, widgets, Live Activity y las piezas de interfaz con gesto. 31 paquetes. Es el único escritor del contrato de audio.
3. **Kimi (local, con Xcode)** lleva volumen acotado y verificable: las tres specs pendientes de reconciliar, el catálogo de cadenas, los tokens, las pantallas tipográficas, las hojas sencillas, la auditoría de accesibilidad, el icono y la ficha de la tienda. 19 paquetes. Antes pasa una prueba de humo, porque la CLI instalada está archivada por su fabricante.
4. **Cursor (nube, sin Xcode)** lleva solo lógica pura en ficheros nuevos cuyo criterio de aceptación corre entero en la CI de macOS: NightWindow y sus puertas, el códec de mezcla v2, las políticas de interrupción y de ruta, el test de autocorrelación y los tests del criterio de texturas. 5 paquetes. No empieza hasta que la CI sea puerta obligatoria y los documentos estén en `main`.
5. **El dueño** hace lo que ningún agente puede hacer: las cuatro decisiones de la reconciliación §6, las altas en el portal y en Connect, la escucha con auriculares, las noches reales, la compra en sandbox, la puerta de diseño a oscuras, la beta y el envío. 8 paquetes (H-01 a H-06, con H-02 y H-06 en dos partes). En total, de 12,5 a 21,5 días de trabajo del dueño repartidos en todo el plan.

**Las tres reglas que sostienen el reparto.**

- Quien puede compilar manda. Nada entra en `main` sin `scripts/verify.sh` en verde en el Mac y sin el check de CI. El precedente es directo: los dos PR de Cursor se escribieron sin Xcode y el PR #3 no compilaba.
- El hilo de audio y las zonas calientes del código tienen un solo escritor a la vez. Las oleadas están ordenadas para que nunca haya dos ramas abiertas sobre el mismo fichero caliente.
- Autor y revisor nunca son el mismo agente. Lo que escribe Codex lo revisa Claude. Lo que escriben Kimi y Cursor lo revisa Codex con el log de `scripts/verify.sh` que Claude ejecuta en local, salvo audio y zonas calientes, que revisa Claude. Lo que escribe Claude lo revisa Codex. Si una reasignación junta autor y revisor, cambia el revisor (§2.3).

**Qué hace el dueño mañana (una hora).** El repo sigue público: decidido el 16-11-2026 (paso 0 de §9). Autoriza llevar `docs/` y `AGENTS.md` a `main` por PR y protege `main`. Confirma qué plan tiene contratado en Cursor, ChatGPT y Kimi. Confirma su cuenta de desarrollador y la firma. Elige cómo trabaja Codex (opción A o B). Decide si instala la CLI nueva de Kimi. Acepta o rechaza dos propuestas de este plan: la equivalencia de la decisión 3 y fusionar R-01 antes de la escucha. El detalle está en §9.

**Qué no se promete.** No hay ningún dato de velocidad de agentes. La referencia sigue siendo la del plan maestro: semana 30 en escenario A y semana 44 en B. Si los tres agentes pasan su calibración el envío puede adelantarse, pero sin dato de velocidad no hay suelo creíble por debajo de 20 semanas (§7). Hasta el 27-11-2026 no se da ninguna fecha. Se recalcula con datos ese día y el 14-12-2026. La escucha en dispositivo, la revisión, las decisiones, la beta y App Review no se aceleran con más agentes.

**Cambios sobre la lista de 55 paquetes.** Quedan 67: dos refactors nuevos que abren paralelismo (F-01, F-02), tres paquetes partidos en parte pura y parte de cableado (P-03, P-04, B-05), la primera sesión de dispositivo partida en dos (H-02a, H-02b) y, tras la revisión del 16-11-2026, A-02 partido en tres, A-03, D-01 y H-06 partidos en dos y E-02 nuevo. Detalle en §5.

---

## 1. Supuestos y hechos verificados

### 1.1 Hechos verificados hoy

| Hecho | Evidencia |
|---|---|
| El repo es SwiftUI para iOS 17 o superior, con XcodeGen, sin dependencias, 34 ficheros Swift y 49 tests en `main`. | [V] mapa del código. |
| En el Mac hay Xcode 26.6 y XcodeGen 2.46.0. Un solo esquema, `SleepNoise`. Cinco simuladores de iPhone, todos con iOS 26.5. | [V] `xcodebuild -list` y lista de simuladores. |
| Los tests están alojados en la app y el esquema fija `parallelizable: false`. Siempre hace falta simulador. | [V] `project.yml`. |
| `SleepNoise.xcodeproj` está en `.gitignore` y se genera. Los ficheros nuevos entran solos con `xcodegen generate`. | [V] mapa del código. |
| No hay CI, ni `AGENTS.md`, ni `.cursor/rules`, ni script de verificación. | [V]. |
| La rama `research/plan-sueno` no tiene commits y `docs/` está sin seguimiento. Un agente en la nube no puede leer hoy ninguna spec. | [V] `git status`. |
| El PR #3 de Cursor no compilaba: error de metadatos de App Intents y un `inclusiveRange` mal tipado. Su interfaz no seguía la dirección de diseño. Su motor y su modelo sí eran aprovechables. | [V] `docs/REVIEW-PR3-2026-11-16.md`. |
| No hay app ni CLI de Cursor en el Mac. Cursor trabaja como agente en la nube contra GitHub. | [V]. |
| Codex tiene dos binarios, ninguno en el PATH. El que referencia `~/.codex/config.toml` es el de ChatGPT.app (0.167.0-alpha.3.2). `codex exec` admite `-s`, `-C`, `--worktree`, `--add-dir` y tiene `review`. `exec review` y `exec resume` no admiten `-C` ni `-s`. Este repo no está marcado como de confianza. | [V] `codex exec --help` y listado de `~/.codex`. |
| Con el perfil `:workspace` de `codex sandbox`, `git commit` falla en un worktree enlazado (`.git/worktrees/<nombre>/index.lock`: operación no permitida) y `simctl` no llega a CoreSimulator. | [V] probado en un repo de prueba, sin sesión de agente. |
| El repo de GitHub es público y `main` no está protegida. El PR #3 sigue abierto. | [V] `gh repo view`, `gh api` de la protección y `gh pr list`. |
| En `main`, `docs/` solo tiene `REVIEW-2026-11-15.md` y `ROADMAP.md`. | [V] `git ls-tree -r origin/main docs`. |
| `project.yml` compila para iPhone y iPad (`TARGETED_DEVICE_FAMILY: "1,2"`) y no fija equipo de firma. | [V] `project.yml`. |
| El `kimi` 1.42.0 de `~/.local/bin` es la CLI antigua. Su repositorio oficial la declara archivada y avisa de que dejará de funcionar. Su configuración no tiene proveedor ni modelo. Kimi Code.app 1.3.3 sí tiene sesión. La CLI nueva no está instalada. | [V] local y aviso oficial. |
| Cursor, Codex y Kimi leen `AGENTS.md` en la raíz. Codex lo corta a 32 KiB por defecto. | [V] documentación oficial de los tres. |
| Las cuatro decisiones abiertas del dueño tienen plazo: 27-11-2026, 04-12-2026, 14-12-2026 y semana 6. | [V] reconciliación §6. |

### 1.2 Lo que no está verificado y cómo lo trata el plan

| Dato sin verificar | Qué pasa si sale mal | El plan no depende de él porque |
|---|---|---|
| Cómo se comporta una sesión real `codex exec -s workspace-write`. El perfil `:workspace` de `codex sandbox` no llega al simulador ni deja hacer commit [V]. La sesión real está [SV]. | Codex no puede cerrar su bucle de compilar y probar, ni hacer commit, en ese modo. | El dueño elige el día 1 entre las opciones A y B de §9. La prueba de humo incluye un commit. |
| Si Kimi responde hoy desde la CLI. [SV] | Kimi no arranca hasta instalar la CLI nueva o usar la app. | Nueve paquetes de Kimi están en la ruta crítica (R7). Cada uno tiene suplente y plazo de corte de tres días laborables. |
| Plan contratado en Cursor. Los agentes en la nube piden plan Premium o superior. [SV] | Cursor no puede trabajar. | Cursor lleva 5 paquetes. Dos están en la ruta crítica (P-03a y P-04a) y tienen plazo de corte (R7). Todos tienen suplente. |
| Plan de ChatGPT y cuota real de Codex por ventana de 5 horas. [SV] | Codex se queda sin cuota a mitad de oleada. | Es el riesgo mayor, porque Codex lleva 31 paquetes. §8 fija qué pasa a Kimi si ocurre. |
| Minutos de macOS en GitHub Actions si el repo pasa a privado [SV]. Hoy es público [V] y el runner estándar no consume minutos. Versión de Xcode del runner [SV]. | La CI no puede ser puerta de cada PR. | La puerta primaria es `scripts/verify.sh` en el Mac. La CI es la segunda puerta. Solo Cursor depende de ella. |
| Cuenta de desarrollador activa y equipo de firma. [SV] | H-02a no se puede hacer y R-02 no se fusiona. | Se comprueba el día 1, antes de lanzar R-01 (§6.2). |
| Si Cursor ve por sí mismo el check y el log de la CI de su PR. [SV] | No corrige solo y la calibración mide otra cosa. | Claude pega el resultado de la CI en el PR. Cursor abre el PR y termina. |
| Si el plan de GitHub permite proteger `main` en repo privado. [SV] | Sin protección, la regla de no hacer push depende solo de la instrucción. | No aplica mientras el repo siga público (decidido el 16-11-2026). |
| Fiabilidad de Kimi con SwiftUI y API recientes de Apple. [INF] | Sus pantallas no pasan revisión. | Regla de calibración de §3.7: el primer paquete de interfaz de Kimi decide si conserva ese carril. |
| Orden de precedencia entre `AGENTS.md` y `.cursor/rules` en Cursor. [SV] | Reglas duplicadas que se contradicen. | Una sola fuente, `AGENTS.md`. La regla de Cursor solo remite a ella. |
| Comportamiento en iOS 17. Solo hay simuladores con iOS 26.5. [V] | Fallos que solo aparecen en la versión mínima. | Se prueba en iPhone real en H-03. Instalar un runtime de iOS 17 en el simulador es decisión del dueño. |

### 1.3 Supuestos de trabajo

- Un único Mac compartido por Claude, Codex y Kimi. Como mucho dos compilaciones a la vez (§3.2).
- Un único integrador. Como mucho cuatro PR abiertos a la vez (§3.6).
- Los documentos de `docs/` y `AGENTS.md` llegan a `main` por PR el día 1, con permiso del dueño y antes de crear ningún worktree de agente. Todos los worktrees nacen de `origin/main`: sin eso ningún agente puede leer las specs que cita su brief.
- Ningún agente externo recibe credenciales, cuentas de sandbox ni acceso a Connect.
- Enviar código del repo a los servicios de Cursor, Codex y Kimi es una decisión del dueño. Cursor ya lo tiene, porque escribió dos PR. Para Kimi se confirma el día 1.

---

## 2. Perfil de cada agente y regla de reparto

### 2.1 Perfiles

| | Claude Code | Codex | Kimi | Cursor |
|---|---|---|---|---|
| Dónde corre | Mac del dueño | Mac del dueño (la nube de Codex no se usa: es Linux sin Xcode [INF fuerte]) | Mac del dueño | VM en la nube, sin Xcode [V más dos PR] |
| Compila y prueba | Sí [V] | Sí en local, con la opción A o B de §9 [V el límite del sandbox, SV la sesión real] | Sí en local [INF, prueba de humo el día 1] | No. El resultado de la CI se lo pega Claude en el PR [SV que lo vea por sí mismo] |
| Recibe la tarea | Sesión del dueño | `codex exec` con el brief, o la app | `kimi --print -p` con el brief, o la app | Web de agentes o comentario en un issue de GitHub |
| Entrega | PR | Rama en su worktree. Claude hace push y abre el PR | Rama en su worktree. Claude hace push y abre el PR | PR propio desde su rama |
| Punto fuerte según la evidencia | Conoce las specs y las dos revisiones. Tiene el simulador | Tareas largas y de precisión con bucle de compilar, probar y corregir. `codex review` [INF razonable] | Precio y contexto de un millón de tokens: specs enteras en contexto [V precio, INF uso] | Paralelismo sin ocupar el Mac. Motor y modelo aprovechables cuando es lógica pura [V, PR #3] |
| Fallo típico | Cuello de botella de revisión | Bloqueos de sandbox con herramientas de Apple. Cuota por ventanas [INF] | CLI archivada. Fiabilidad en API recientes de Apple sin medir. El modo print aprueba todo [V e INF] | Código que no compila. Interfaz sin dirección. API de Apple mal tipadas [V, dos veces] |
| Coste relativo | Sesión del dueño | Medio, por cuota de suscripción | Bajo | Medio o alto, por consumo |
| Paquetes como autor | 4 | 31 | 19 | 5 |
| Suplente si falla | No tiene | Kimi para lo mecánico. El resto espera | Codex | Kimi, y después Codex |

### 2.2 Reglas de reparto y su evidencia

**R1. Quien puede compilar manda.** App Intents, widgets, Live Activity, StoreKit y SwiftUI con previews solo se dan por buenos compilando. Los dos errores del PR #3 eran de exportación de metadatos de App Intents y solo se ven con `xcodebuild`. Por eso todo lo de clase `ecosistema`, `storekit` e `interfaz` va a un agente local. Cursor queda fuera de esas clases aunque exista la CI, porque un ciclo de corrección a través de la CI es lento y gasta minutos de macOS.

**R2. El contrato de audio tiene un solo escritor: Codex.** `EngineCommand.swift`, `RenderState.swift`, `ParameterMailbox.swift`, `SleepAudioEngine.publishCurrent` y el test de desgarro cambian siempre juntos. Un campo nuevo toca los cuatro. Un método público nuevo del motor toca además el protocolo y el motor de pega (§3.9). Se elige Codex porque es el agente local con mejor perfil para trabajo de precisión con bucle de pruebas, y porque así Claude queda libre para revisar todo el audio sin ser autor. No se elige Cursor aunque su motor del PR #3 fuera aprovechable, porque no puede ejecutar los tests offline ni medir el coste por frame. No se elige Kimi porque su fiabilidad en este tipo de código no está medida.

**R3. Las texturas no son una excepción.** Un generador es un struct puro en su fichero, con `init(seed:sampleRate:)`, `prepare(sampleRate:)` y `next()`. Cursor demostró que sabe escribirlos, pero el paquete A-02 pedía cambiar el PRNG de todas las texturas, medir el coste y escuchar el resultado. Eso toca ficheros existentes y tests espectrales, y Cursor no puede medir ni oír. Por eso A-02 se parte. A-02a (PRNG) y A-02b (trueno y hoguera) son de Codex, dentro del carril de audio y antes de A-01. Cursor solo escribe A-02c: los tests del criterio, en ficheros nuevos. El cableado en `SoundID`, `SoundGains` y `ChannelGenerators` sigue siendo de Codex.

**R4. Cursor solo toca ficheros nuevos.** Nunca una zona caliente. Un PR de Cursor puede tardar varias vueltas de CI en ponerse en verde, y mientras tanto bloquearía el fichero a los demás. Con ficheros nuevos no bloquea a nadie. Por eso tres paquetes se parten en parte pura (Cursor) y cableado (agente local).

**R5. Kimi lleva lo acotado, repetitivo y verificable.** Reconciliar tres specs contra una lista cerrada de deltas, sembrar un catálogo de cadenas, escribir páginas de texto, pasar una auditoría de accesibilidad. Son tareas donde un contexto grande y un precio bajo pesan más que la finura con API de Apple. Su acceso a hojas con gesto o con StoreKit depende de la calibración de §3.7.

**R6. Claude no escribe lo que tiene que revisar.** Solo es autor de la infraestructura que nadie más puede poseer: el script de verificación, `AGENTS.md`, el refactor de `MixerModel` que abre el paralelismo y los cambios de `project.yml` y entitlements. Esos cuatro los revisa Codex.

**R7. La ruta crítica pasa por los tres agentes, y por eso tiene plazos de corte.** La cadena de I-01 a D-02 es de Claude y de Codex, pero sus dependencias incluyen dos paquetes de Cursor (P-03a y P-04a) y nueve de Kimi (F-02, DS-01, DS-03, S-01, X-01, X-02, X-03, L-01 y C-01). B-01 espera a P-03a y a F-01 a través de P-03b, y a X-02. B-03 espera a X-02 y, a través de A-03a, a X-01, L-01, DS-01, DS-03 y S-01. D-01a espera a X-03 y a C-01, y C-01 espera a P-04a a través de P-04b. B-05a y T-01 (Cursor) entran al final, por H-03 y H-06a. Para esos once rige un plazo: si a los tres días laborables de estar en estado "listo" no están en "aprobado", pasan al suplente sin esperar a la segunda ronda. P-03a no espera a Cursor: si el día 3 el plan de Cursor no está confirmado, la CI no es puerta obligatoria o los documentos no están en `main`, lo escribe su suplente, Kimi, en local (un día de trabajo). Si Kimi tampoco ha pasado su prueba de humo, lo escribe Codex y lo revisa Claude. Cursor se calibra entonces con P-04a.

### 2.3 Matriz de revisión cruzada

| Autor | Revisor | Qué hace el revisor |
|---|---|---|
| Codex | Claude | Lee el diff contra la spec, ejecuta `scripts/verify.sh`, prueba en simulador lo que tenga interfaz. En audio comprueba además las reglas del hilo de render de `AGENTS.md`. |
| Kimi | Codex | Claude ejecuta `scripts/verify.sh` en un worktree de revisión y deja el log. Codex hace `codex exec review` con ese log. Devuelve hallazgos. |
| Kimi, si toca zona caliente o es documentación de specs o catálogo | Claude | Igual que la primera fila. Aplica a X-01, X-02, X-03, L-01, C-01, D-07 y E-02. |
| Cursor | Codex | Claude descarga la rama y ejecuta `scripts/verify.sh`. Codex revisa con ese log. La CI en verde es condición para empezar. Aplica también a A-02c. |
| Codex en el carril de audio (A-02a y A-02b incluidos) | Claude | Revisión de audio completa, con `scripts/verify.sh --bench`. |
| Claude | Codex | `codex exec review` sobre la rama, con el log de `scripts/verify.sh`. |

Claude lee el diff de todo lo que integra, aunque no sea el revisor nombrado. La revisión cruzada no sustituye a la integración.

**Reasignación.** Si el suplente es el revisor nombrado, el revisor cambia: Claude cuando el autor nuevo es Codex, Codex cuando el autor nuevo es Claude. Kimi y Cursor no revisan código. Pasa en 18 paquetes: I-01, I-02, F-02, X-01, X-02, X-03, S-01, F-01, DS-01, DS-03, P-04b, A-04, B-02, C-02, E-01, D-05, D-06 y Q-01. Nunca autor igual a revisor.

**Revisor de reserva.** Si Codex no puede revisar (cuota o sandbox), Claude revisa lo de Kimi y lo de Cursor. Los cuatro paquetes de Claude esperan a Codex, o los aprueba el dueño leyendo el diff con el log de `scripts/verify.sh`.

---

## 3. Protocolo de trabajo

### 3.1 Ramas

- Formato: `agente/id-slug`, en minúsculas. Ejemplos: `codex/r-01-pr-a-base`, `kimi/x-02-spec-07`, `cursor/p-03a-nightwindow`, `claude/i-01-verify`.
- Una rama por paquete. Un paquete por PR. Base siempre `main` actualizado, salvo que el brief diga otra cosa.
- Las ramas de spike no se fusionan. La nota de `docs/research/spikes/` la lleva Claude a `main` en un commit aparte.
- `main` queda protegida desde el día 1 con PR obligatorio. El check de CI obligatorio se añade en cuanto I-02 esté en verde. Esa configuración la hace el dueño o la autoriza de forma expresa.
- Solo Claude hace push de las ramas locales y abre sus PR. Codex y Kimi no usan `gh` ni hacen push. Motivo: el modo print de Kimi aprueba todas las herramientas sin preguntar [V], y Codex en la opción A de §9 trabaja sin sandbox.

### 3.2 Worktrees y uso del Mac

Un worktree por paquete en curso, fuera del repo principal:

```
~/wt/sleepnoise/<agente>-<id>      por ejemplo ~/wt/sleepnoise/codex-r-01
```

Cada worktree lleva su DerivedData dentro (`.build/DerivedData`, ignorado por Git) y su simulador fijo. Así dos agentes no instalan el mismo bundle en el mismo dispositivo.

| Quién | Simulador | Uso |
|---|---|---|
| Claude | iPhone 17 | Integración y revisión |
| Codex, autor | iPhone 17 Pro | Sus paquetes |
| Kimi | iPhone 17e | Sus paquetes |
| Codex, revisor | iPhone Air | Revisiones de ramas de Kimi, Cursor y Claude |
| Reserva | iPhone 17 Pro Max | Tests de interfaz largos |

**Límite de compilaciones.** Como mucho dos `xcodebuild` a la vez en el Mac. `scripts/verify.sh` lo impone con un semáforo de dos plazas (dos directorios de bloqueo creados con `mkdir`). Cada plaza guarda el PID de quien la ocupa. Si las dos están ocupadas, espera. El script libera una plaza cuyo PID ya no existe y sale con código 75 si espera más de 30 minutos. Los tests no se paralelizan dentro de un mismo proceso, porque el esquema lo prohíbe.

**Límite de worktrees.** Como mucho tres worktrees que compilan a la vez: uno de autor de Codex, uno de autor de Kimi y uno de Claude o de revisión. Excepción: Codex puede tener dos de autor cuando uno es del carril de audio y el otro no toca ninguna zona caliente de §3.9. Entonces ocupa también la plaza de Kimi o la de revisión, y el semáforo de dos compilaciones no cambia. Los paquetes de solo documentos no cuentan para este límite, pero sí para la concurrencia de Kimi: dos a la vez hasta confirmar su plan.

**Limpieza.** El worktree del autor se cierra al aprobar el paquete, porque Git no deja sacar la misma rama en dos worktrees y la integración necesita la rama. Los worktrees de revisión se crean con `--detach` y se borran al dar el veredicto. Al fusionar, Claude borra el worktree de integración y la rama local. Los worktrees que crea Codex por su cuenta con `--worktree` no se usan: no regeneran el proyecto de XcodeGen [INF] y quedan en disco.

### 3.3 Plantilla de brief

Los briefs viven en `docs/briefs/<id>.md`, versionados, para que los lean igual los tres agentes. Caben en una pantalla. El agente no recibe documentos enteros, recibe rutas y secciones.

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

Para Cursor el brief se pega en un issue de GitHub con el mismo texto. Su entrega es el PR, con la plantilla de PR rellena.

### 3.4 Definición de hecho

Un paquete está hecho cuando se cumplen las siete condiciones. Si falta una, no se fusiona.

1. `scripts/verify.sh` devuelve 0 en el worktree del autor y en el de integración de Claude, sin avisos: ni del compilador de Swift, ni de C, ni de los catálogos, ni del procesador de metadatos de App Intents. Los paquetes que solo tocan `docs/` no lo ejecutan: su puerta son los greps del brief.
2. Cada línea del criterio de aceptación del brief tiene un test con nombre o un grep que la demuestra.
3. El diff solo toca los ficheros de la lista cerrada del brief.
4. Las cadenas nuevas están en inglés y en español, pasan el lint de copy y usan el vocabulario de la reconciliación §3.
5. El revisor cruzado ha dado su visto bueno por escrito en el PR.
6. La CI está en verde en el PR.
7. El PR lista lo que no se ha verificado en dispositivo y a qué paquete del dueño queda (H-02 a H-05).

Para los paquetes de audio se añade: el test de desgarro por bytes (`SeqlockTearTests`, desde R-01) sigue en verde, no hay `Array`, `String`, clases ni closures en `RenderState`, y la mediana de `scripts/verify.sh --bench` no sube más del 10 % sobre `docs/research/bench/BASELINE.md`. La mide el autor y la repite Claude con el Mac en reposo. El coste real en un A15 se mide con Instruments en H-03.

### 3.5 Puertas, en orden

| # | Puerta | Quién la pasa | Qué bloquea |
|---|---|---|---|
| 1 | `scripts/verify.sh` local. Regenera el proyecto, compila con los avisos de Swift y de C como errores, guarda el log, falla si el log trae cualquier aviso (también los del procesador de metadatos de App Intents), pasa los tests en simulador y ejecuta el lint de copy. | El autor, si es local. Para Cursor no existe esta puerta. | La entrega. Una rama que no la pasa no se revisa. |
| 2 | Lint de copy. Palabras vetadas, sin cifras de precio, sin recuento de texturas, claves completas en los dos idiomas. | Va dentro de la puerta 1 desde L-01. | La entrega. |
| 3 | CI en macOS sobre el PR. Ejecuta el mismo script. Tras el rebase de integración se repite sobre el sha que se fusiona. | GitHub Actions. | La revisión de los PR de Cursor y la fusión de todos. |
| 4 | Revisión cruzada, según la matriz de §2.3. | El revisor nombrado. | La integración. |
| 5 | Integración. Claude actualiza la rama sobre `main`, repite la puerta 1 en su worktree, hace push con `--force-with-lease`, espera a la CI, fusiona y borra la rama. | Claude. | La entrada en `main`. |
| 6 | Dispositivo. Lo que solo se oye, se toca o se compra de verdad. | El dueño, en H-02 a H-05. | El cierre de bloque y el envío. No bloquea la fusión, salvo en R-02 (H-02a) y en la fila Timbre (A-05, tras H-02b). R-01 se fusiona antes de H-02a solo si el dueño acepta esa excepción (nota de la oleada 0). |

El modo largo del script (renders de referencia y autocorrelación de T-01) corre en un trabajo aparte de la CI, una vez al día sobre `main` y a petición. No es puerta de cada PR.

### 3.6 Límite de PR abiertos

Como mucho cuatro PR abiertos a la vez: dos de agentes locales en revisión, uno de Cursor y uno de documentación o infraestructura. Si hay cuatro, no se lanza ningún paquete nuevo que vaya a producir un PR en menos de un día. El motivo es el integrador único: un PR que espera más de dos días envejece, choca con `main` y obliga a repetir trabajo.

Orden de atención de Claude cuando hay cola: primero lo que está en la ruta crítica, después lo que desbloquea una zona caliente, después lo demás.

### 3.7 Cuando un agente se atasca o entrega algo que no compila

**Entrega que no compila o no pasa los tests.** No se revisa. Vuelve al autor con el log de `scripts/verify.sh` o de la CI. Cuenta como una ronda.

**Regla de las dos rondas.** Si un paquete vuelve dos veces al mismo autor sin pasar las puertas 1 a 4, Claude lo para, escribe el diagnóstico en el PR y lo reasigna al suplente con lo aprovechable de la rama. No hay tercera ronda con el mismo agente. Si el suplente es el revisor nombrado, cambia el revisor (§2.3).

**Sesión que no termina o termina sin entrega.** Cada lanzamiento lleva tope de reloj: 90 minutos si el paquete es de hasta 2 días, 3 horas el resto. Claude lanza en segundo plano y al vencer mata el proceso. Una sesión que acaba sin commits nuevos, sin mensaje final y sin `ATASCO.md` cuenta como atasco y como una ronda. Cursor: si a las 24 horas del encargo no hay PR, o el PR lleva 24 horas en rojo sin push nuevo, cuenta como ronda. Orquestador: si la sesión de Claude se corta, ningún agente lanza nada por su cuenta. La siguiente sesión reconstruye el estado con `docs/agents/ESTADO.md`, `git worktree list` y `gh pr list` antes de lanzar.

**Arreglos del integrador.** Claude puede corregir en la integración hasta unas 30 líneas (un nombre, un import, una clave de cadena) y lo anota en el PR. Por encima de eso, el paquete vuelve a su autor. Esta regla existe para que la revisión no se convierta en reescritura, que es lo que ocurrió con el PR #3.

**Atasco declarado.** El agente escribe `ATASCO.md` y para. Claude decide en ese momento entre tres salidas: acotar el brief, partir el paquete o reasignarlo.

**Agotamiento de cuota.** Si Codex agota su ventana, sus paquetes en curso esperan. No se pasan a medias a otro agente, salvo que el brief sea mecánico. El carril de audio nunca cambia de escritor a mitad de paquete. Si Codex tampoco puede revisar, rige el revisor de reserva de §2.3.

**Calibración de Kimi.** Sus tres primeros paquetes son la prueba: F-02 (mecánico, con compilación), X-01 (documentación) y DS-01 (Swift con tests). Si los tres pasan en dos rondas o menos, conserva el carril de interfaz sencilla (DS-03, A-04, B-02, C-02, D-05, D-06). Si no, ese carril pasa a Codex y lo revisa Claude, y Kimi se queda con documentación, catálogo, tests y auditoría. Si los tres pasan, DS-04, DS-05, D-03 y B-04 pasan a Kimi como asignación por defecto, con revisión de Claude: descargan el carril de Codex, que es el que fija el calendario (§7). El cambio se escribe en `docs/agents/ESTADO.md` en ese momento. Hasta entonces las tablas los dan a Codex.

**Calibración de Cursor.** Su primer paquete es P-03a (NightWindow). Si la CI se pone en verde en dos vueltas o menos y Codex no encuentra errores de fondo, sigue con P-04a, T-01, B-05a y A-02c. Si no, esos paquetes pasan a Kimi. La CI la lee Claude y pega el resultado en el PR: no se da por hecho que Cursor la vea.

### 3.8 Conflictos

- Los resuelve siempre Claude, en la integración. Ningún agente fusiona `main` en su rama por su cuenta.
- En zona caliente no debería haber conflictos, porque hay un turno por fichero (§3.9). Si aparece uno, es un fallo de orquestación: gana lo que ya está en `main` y el segundo paquete se actualiza encima.
- El catálogo de cadenas no se resuelve a mano. Claude toma el catálogo de `main` y vuelve a ejecutar `scripts/strings-merge.sh` con el fragmento del paquete. Por eso cada paquete entrega su fragmento `strings/<id>.json` además del catálogo ya fusionado.
- `project.yml`, `Info.plist` y los entitlements no los toca ningún agente. Si un paquete necesita un cambio ahí, el brief lo dice y Claude lo deja hecho en un commit de preparación antes de lanzar el paquete.

### 3.9 Turnos de las zonas calientes

Cada fila es un fichero o grupo de ficheros con un solo escritor a la vez. El orden de la columna es el orden de los turnos.

| Zona | Turnos, en orden | Nota |
|---|---|---|
| Contrato y carril de audio: `EngineCommand`, `RenderState`, `ParameterMailbox`, `SleepAudioEngine`, test de desgarro, ficheros de textura y `XorShift32.swift` | R-01, P-01, P-05, A-02a, A-02b, A-01, A-05 | Carril único de Codex. S-04 es un spike sobre rama que no se fusiona y no ocupa turno. R-02 solo toca `ThunderTexture.swift` y va en paralelo con P-01. A-06 no añade campos ni toca estos ficheros: va en paralelo con P-05. B-05b toca `SleepAudioEngine` fuera del render y espera a que no haya turno abierto. D-07 no toca `SleepNoise/Audio/`. |
| `AudioEngineControlling.swift`, `FakeAudioEngine.swift` (nacen en F-01) | F-01, y después cada turno que cambie la superficie pública del motor: P-05, B-05b, A-05 | Quien añade un método público a `SleepAudioEngine` lo añade en el mismo PR al protocolo y al doble. F-01 ya incluye `setMaster` de P-01. |
| `DSPGeneratorTests.swift` | R-01, A-02a, A-02b, A-01. Nadie más | El test de desgarro sale a `SeqlockTearTests.swift` en R-01. R-02 y P-01 usan ficheros de test nuevos. |
| `MixerModel.swift` | R-01, R-02, **F-01**, P-03b, A-03a, A-03b, B-01, C-01, A-04 | F-01 lo parte en extensiones por fichero. Después caben dos paquetes a la vez si tocan ficheros distintos. |
| `MixerView.swift`, `SoundRowView.swift` | R-01 (lista de once, sin diseño nuevo), A-03a (dejan de ser la raíz), A-03b (los borra) | Congelados entre medias. No se parten: A-03a los sustituye enteros. |
| `SoundID`, `SoundGains`, `ChannelGenerators` | R-01, A-01 | Después de R-01 nadie añade casos. |
| `AccessPolicy.swift`, `PolicyTests.swift` | R-01, R-02, P-02 (solo saca `TimerFormatTests` a su fichero), P-03b, C-01, B-04 | |
| `SleepTimerView.swift` | P-02, P-03b, B-02 (la sustituye) | |
| `Localizable.xcstrings` | R-01, R-02, L-01, y desde ahí solo por fragmento | L-01 entrega también `scripts/strings-merge.sh`. |
| `project.yml`, `Info.plist`, entitlements | I-01, P-04b, y commits de preparación para L-01, C-03, D-02 y D-04 | Solo Claude. I-01 pasa `TARGETED_DEVICE_FAMILY` a `"1"`. El commit de preparación de S-02 vive solo en la rama del spike y nunca llega a `main`. |
| `PurchaseManager.swift`, `TrialClock.swift` | P-03b, C-03, C-04 | |
| `AppRoot.swift` | P-04b, A-03a, D-01a, D-07 (inyecta el sumidero de diagnóstico) | |
| `Theme.swift` | DS-01 (alias), retirada al final por Claude | |
| `BreathingTests.swift` | **F-02** lo parte por clase en la oleada 0 | Después cada clase tiene su fichero. |
| `PageView.swift` (nace en A-03a) | A-03a, y después solo Claude | A-03a define un enum de rutas y deja una vista vacía por hoja en su fichero. Cada paquete posterior rellena su fichero. |
| `SystemGallery.swift` (nace en DS-02) | DS-02, y después solo Claude | Cada componente trae su sección de galería en su propio fichero. La línea de registro la añade Claude. |
| `Model/NightWindow.swift` (nace en P-03a) | P-03a | `NightWindow`, `SaleGate` y `TipGate` se declaran solo aquí. DS-02 no los redeclara aunque el listado A12 de 04 los traiga. |
| `scripts/verify.sh`, `.github/workflows/ci.yml` | I-01, I-02, y después solo Claude | T-01 entrega el test. Claude lo engancha al modo largo. `docs/research/bench/BASELINE.md` solo lo actualiza Claude, al integrar cada turno de audio. |

---

## 4. Oleadas

Una oleada no es un plazo, es un conjunto de paquetes que pueden estar abiertos a la vez sin pisarse. Dentro de cada oleada, las filas van en orden de arranque. En la columna Puerta, "1 a 5" son las puertas de §3.5 y lo demás es la condición propia del paquete.

### Oleada 0 · Infraestructura y rescate del PR #3

Objetivo: que exista una orden única de verificación, que la CI sea puerta, que los tres agentes hayan pasado su prueba de humo y que PR-A esté en `main`.

| Paquete | Agente | Rama | Depende de | Revisor | Puerta |
|---|---|---|---|---|---|
| H-01 Decisiones, planes contratados, firma y altas | Dueño | `claude/h-01-decisiones` (solo el acta) | nada | no aplica | Plazos de §6. Día 1: visibilidad del repo, permisos, planes y firma |
| I-01 Script de verificación, arnés de coste y target de tests de interfaz | Claude | `claude/i-01-verify` | nada | Codex | 49 tests en verde. Falla con un error sembrado y con un aviso sembrado. Menos de 10 minutos. `--bench` escribe `.build/bench.txt`. `grep -c 'TARGETED_DEVICE_FAMILY: "1"' project.yml` da 1 |
| I-03 Regla de Cursor, plantilla de PR y resto de briefs (`AGENTS.md` y `docs/` ya están en `main` desde el día 1) | Claude | `claude/i-03-agents-md` | I-01 | Codex | `AGENTS.md` por debajo de 32 KiB. Cada ruta de "Lee antes" de cada brief existe en `origin/main` |
| F-02 Partir `BreathingTests.swift` por clase (prueba de humo de Kimi) | Kimi | `kimi/f-02-partir-tests` | I-01 | Codex | 1 a 5. Mismos 49 tests, ningún cambio de lógica |
| I-02 CI en GitHub Actions con macOS (prueba de humo de Codex) | Codex | `codex/i-02-ci` | I-01 | Claude | Verde en `main`. Rojo en el PR de control (§9, día 3). Check obligatorio |
| R-01 PR-A base: motor, once texturas, modelo e intents con los cinco arreglos | Codex | `codex/r-01-pr-a-base` | I-01, I-02 | Claude | 1 a 5. Metadatos de App Intents sin errores ni avisos, comprobado por `verify.sh`. Sin ficheros de la interfaz de baldosas. `BedtimeView` sin `DesignTokens`. Test de desgarro por bytes |
| X-01 Reconciliación en la spec 05 | Kimi | `kimi/x-01-spec-05` | I-03 | Claude | Sección 12 con los 9 deltas. Greps a 0 |
| X-02 Reconciliación en la spec 07 | Kimi | `kimi/x-02-spec-07` | I-03 | Claude | Sección 12 con los 14 deltas. Greps a 0 |
| X-03 Reconciliación en la spec 09 | Kimi | `kimi/x-03-spec-09` | I-03 | Claude | Sección 12 con los 15 deltas. Greps a 0 |
| R-02 PR-A segunda parte: modelo de Noche, hash del trueno, tests, catálogo | Codex | `codex/r-02-pr-a-noche` | R-01 | Claude | 1 a 5 y H-02a antes de fusionar |
| H-02a Escucha de PR-A en iPhone real | Dueño | `claude/h-02a-acta` | R-02 listo para fusionar, firma de H-01 | no aplica | Lista firmada: once texturas, atajo por voz en inglés y en español, Noche con Auto-Lock y "Mantener encendida" en sus tres valores |

Notas. X-01 a X-03 no tocan `PLAN-MAESTRO`: la columna Estado la actualiza Claude al integrar, para que los tres puedan ir en paralelo. R-01 se fusiona en cuanto pasa las puertas 1 a 5, para no parar la cadena. R-02 espera a H-02a, que es una sesión de una o dos horas.

Esto es una excepción a FUNCIONES §5, que pide la escucha en iPhone antes de fusionar PR-A. El dueño la acepta el día 1. Si no la acepta, R-01 espera también a H-02a. Nada de audio de R-01 se da por cerrado hasta el acta de H-02a, y lo que falle allí abre un paquete de corrección antes de P-01.

Todos los worktrees nacen de `origin/main`. Por eso `docs/`, `docs/agents/`, `AGENTS.md` y los briefs de I-02 y F-02 entran en `main` el día 1, antes de lanzar nada (§9). I-03 lleva el resto de los briefs.

### Oleada 1 · Spikes y primitivas

Objetivo: fijar el contrato de audio ampliado, abrir `MixerModel`, sembrar el catálogo y los tokens, y cerrar los spikes que deciden alcance.

| Paquete | Agente | Rama | Depende de | Revisor | Puerta |
|---|---|---|---|---|---|
| S-04 Spike I0-7: timbre en el bus | Codex | `codex/s-04-spike-i0-7` | I-01, R-01 | Claude | Nota con veredicto y cinco WAV. No se fusiona |
| S-02 Spikes I0-3 e I0-6: intent sobre Live Activity y contraste bajo rojo | Codex | `codex/s-02-spike-i0-3-6` | I-01 y commit de preparación de Claude en la propia rama del spike | Claude | Compila y lanza la actividad. No se fusiona |
| S-01 Spike I0-2: umbral del arrastre | Kimi | `kimi/s-01-spike-i0-2` | I-01 | Codex | 10 scrolls diagonales, 0 cambios. No se fusiona |
| F-01 Motor tras un protocolo y `MixerModel` partido en extensiones | Claude | `claude/f-01-motor-protocolo` | R-02, P-01 | Codex | 1 a 5. Primeros tests de `MixerModel` con motor de pega. Protocolo y doble con `setMaster`. Sin cambio de comportamiento |
| P-01 Bus maestro, rampas y fundido de cuenta entera | Codex | `codex/p-01-bus-maestro` | R-01, S-04 cerrado | Claude | 1 a 5 y puerta de audio de §3.4. No espera a R-02: no comparten ficheros |
| P-03a NightWindow, SaleGate y TipGate (prueba de humo de Cursor) | Cursor | `cursor/p-03a-nightwindow` | I-02, I-03 | Codex | CI verde. Bordes 20:59, 21:00, 06:59 y 07:00 |
| P-04a Códec de mezcla v2 en ficheros nuevos | Cursor | `cursor/p-04a-mezcla-v2` | I-02, R-01 | Codex | CI verde. Ida y vuelta con campos futuros. Instantánea de `rawValue` |
| T-01 Test de autocorrelación | Cursor | `cursor/t-01-autocorrelacion` | I-02, R-01 | Codex | CI verde. Falla con un bucle de control de 30 s |
| DS-01 Tokens, escala y rejilla | Kimi | `kimi/ds-01-tokens` | I-01 | Codex | 1 a 5. Contraste 4,5:1. Greps de 04 Anexo B a 0 |
| L-01 Catálogo semilla, lint ampliado y script de fragmentos | Kimi | `kimi/l-01-catalogo` | I-01, R-02, F-02 | Claude | 1 a 5. Completitud en y es. Listas vetadas a 0 |
| P-02 Temporizador sin tick de 4 Hz | Codex | `codex/p-02-timer-sin-tick` | R-02, P-01 | Claude | 1 a 5. Reloj inyectado con hora de pared y tiempo monótono. `repeats: true` a 0 |
| P-03b Política final, prueba en Keychain y `startTrial` | Codex | `codex/p-03b-politica-keychain` | R-02, F-01, P-03a, P-02 | Claude | 1 a 5. Greps de `freeTimerMinutes` a 0 |
| P-04b App Group, `MixStore` al contenedor y target de widgets vacío | Claude | `claude/p-04b-app-group-widgets` | P-04a, F-01 | Codex | 1 a 5. Los dos targets compilan en simulador |
| DS-02 Disco, acción entre hairlines, sistema con estilo y galería | Codex | `codex/ds-02-disco-galeria` | DS-01 | Claude | 1 a 5. Un solo `#available(iOS 26`. No declara las puertas de P-03a |
| DS-03 Horizonte: SoundLine y SoundMeter | Kimi | `kimi/ds-03-horizonte` | DS-01, DS-02 | Codex | 1 a 5. Histéresis de 3 s. `Timer` a 0 en Design |
| S-03 Spikes I0-5 e I0-5b: háptica y quietud (relleno, decide 1.2) | Kimi | `kimi/s-03-spike-i0-5` | nada | Codex | Dos notas. `import CoreMotion` sigue a 0 en `main` |
| H-02b Spikes en dispositivo y puerta del bus | Dueño | `claude/h-02b-acta` | S-01, S-02, S-04 | no aplica | Veredicto por spike. Decisión escrita sobre la fila Timbre |

Carril de audio en esta oleada, en serie: S-04, después P-01. R-02 va en paralelo: solo toca `ThunderTexture.swift` y tiene prohibidos `EngineCommand` y `RenderState`. Nada más toca el contrato. F-01 espera a P-01 para que el protocolo del motor nazca con `setMaster`.

### Oleada 2 · Bloque A y bases de B y C

Objetivo: página principal en `main`, motor con Descenso y loudness, modelo de temporizador y de mezclas.

| Paquete | Agente | Rama | Depende de | Revisor | Puerta |
|---|---|---|---|---|---|
| P-05 Canal inverso del render | Codex | `codex/p-05-canal-inverso` | P-01, DS-03 | Claude | 1 a 5 y audio. Error de RMS menor de 0,5 dB |
| A-06 Marea 1.0 en el motor: Descenso | Codex | `codex/a-06-descenso` | P-01 | Claude | 1 a 5 y audio. Cero campos nuevos: `EngineCommand`, `RenderState` y `SleepAudioEngine` a 0 en el diff. No ocupa turno del contrato |
| A-02a PRNG nuevo: xoshiro128** con siembra splitmix32 | Codex | `codex/a-02a-prng` | R-02, P-05 | Claude | 1 a 5 y audio. Seeds y tests espectrales reajustados. T-01 fija su umbral final después |
| A-02b Trueno sin crack y hoguera acotada | Codex | `codex/a-02b-trueno-hoguera` | A-02a | Claude | 1 a 5 y audio. Render de 60 s por textura en `.build/renders/` para la escucha del dueño |
| A-01 Loudness entre texturas y compensador | Codex | `codex/a-01-loudness` | A-02b | Claude | 1 a 5 y audio. −20 dBFS(A) con 1 dB de tolerancia. Fija los trims finales |
| A-02c Tests del criterio de texturas | Cursor | `cursor/a-02c-criterio-texturas` | A-02b, I-02 | Codex | CI verde. Solo ficheros nuevos. Cresta menor de 12 dB, eventos a 6 dB o menos sobre el fondo, centroide distinto |
| DS-04 LevelRule | Codex | `codex/ds-04-levelrule` | DS-01, S-01 | Claude | 1 a 5. Reductor puro probado. Umbral ajustable tras H-02b |
| DS-05 TideLine y FullScreenControl | Codex | `codex/ds-05-tideline-fullscreen` | DS-01, DS-03 | Claude | 1 a 5. Reductores puros probados |
| A-03a Página principal, enum de rutas y hojas vacías | Codex | `codex/a-03a-pagina-rutas` | DS-02, DS-03, DS-04, P-03b, F-01, X-01, L-01 | Claude | 1 a 5. No arranca el motor al lanzar. `MixerView` deja de ser la raíz |
| A-03b Tope de seis capas, retirada de `MixerView` y tests de interfaz | Codex | `codex/a-03b-tope-retirada` | A-03a | Claude | 1 a 5. La séptima capa se rechaza. `MixerView.swift` no existe |
| B-01 Temporizador de dos modos en el modelo | Codex | `codex/b-01-temporizador-modelo` | P-01, P-02, P-03b, X-02 | Claude | 1 a 5. Manto cruza medianoche y cambio de hora |
| C-03 Estados de StoreKit y fichero de tienda | Codex | `codex/c-03-storekit-estados` | P-03b | Claude | 1 a 5 con sesión de StoreKit de pruebas |
| C-01 Mezclas en el modelo: guardadas, de la casa y Esta noche | Kimi | `kimi/c-01-mezclas-modelo` | P-04a, P-04b, P-03b, L-01 | Claude | 1 a 5. Cuatro mezclas de la casa. Bytes intactos al caducar |
| B-05a Políticas puras de interrupción y de ruta | Cursor | `cursor/b-05a-politicas` | I-02, P-03a, X-02, X-03 | Codex | CI verde. Tabla de casos 03:00, 06:30, Manto hasta 07:00 |

Carril de audio, en serie: P-05, A-02a, A-02b, A-01. A-06 va en paralelo con P-05, porque no toca el contrato. El PRNG cambia antes de fijar los trims de 1 dB de A-01 y el umbral de T-01, que de otro modo quedarían invalidados. Codex no puede llevar a la vez un paquete de audio y otro que toque `MixerModel` en el mismo fichero de extensión: Claude ordena los turnos con la tabla de §3.9.

### Oleada 3 · Hojas de A, B y C

| Paquete | Agente | Rama | Depende de | Revisor | Puerta |
|---|---|---|---|---|---|
| A-04 Hoja Todas las capas y el único tip | Kimi | `kimi/a-04-capas` | A-03b | Codex | 1 a 5. Once filas, ningún candado, nada de noche |
| A-07 Hoja Marea, toggle y háptica | Codex | `codex/a-07-hoja-marea` | A-06, DS-05, A-03a | Claude | 1 a 5. Puerta háptica probada |
| B-02 Hoja Temporizador | Kimi | `kimi/b-02-hoja-temporizador` | B-01, DS-02, X-02, L-01 | Codex | 1 a 5. Sin "pro" ni "Siesta" en claves |
| B-03 Noche y página nocturna | Codex | `codex/b-03-noche` | DS-05, P-01, B-01, A-03a, X-02 | Claude | 1 a 5. Tabla de batería. Auto-Lock real en H-03 |
| B-05b Sesión de audio, interrupciones y rutas cableadas | Codex | `codex/b-05b-sesion-rutas` | B-05a, P-01, B-01 | Claude | 1 a 5. Deja el protocolo `DiagnosticsSink`, que nunca se llama desde el render. Comportamiento real en H-03 |
| C-02 Pantalla Mezclas y menú del nombre | Kimi | `kimi/c-02-pantalla-mezclas` | C-01, DS-02, A-03a, L-01 | Codex | 1 a 5. La cuarta mezcla no pierde el nombre escrito |
| C-04 Hoja Pro, prueba de 7 noches y degradación | Codex | `codex/c-04-hoja-pro` | C-03, DS-02, A-04, L-01 | Claude | 1 a 5 con tienda de pruebas. Compra real en H-04 |
| E-01 Icono en sus cuatro apariencias | Kimi | `kimi/e-01-icono` | DS-01, H-01 (acento, 27-11-2026) | Codex | Test de píxeles. Sin avisos del catálogo |

### Oleada 4 · Bloque D, Madrugada y Timbre

| Paquete | Agente | Rama | Depende de | Revisor | Puerta |
|---|---|---|---|---|---|
| B-04 Madrugada | Codex | `codex/b-04-madrugada` | B-03, A-06 | Claude | 1 a 5. Mezcla y disco idénticos byte a byte |
| A-05 Fila Timbre (solo si H-02b dice que pasa) | Codex | `codex/a-05-timbre` | P-01, S-04, H-02b, A-04, A-01 | Claude | 1 a 5 y audio. Si no pasa, a 1.1 |
| D-01a Intents con frase y catálogo `AppShortcuts` | Codex | `codex/d-01a-intents-frase` | R-02, C-01, B-01, B-04, X-03 | Claude | 1 a 5. Metadatos sin errores ni avisos, comprobado por `verify.sh`. Voz en H-05 |
| D-01b Dos intents sin frase y snapshot del App Group | Codex | `codex/d-01b-intents-snapshot` | D-01a, P-04b | Claude | 1 a 5. El snapshot se lee desde el contenedor compartido |
| D-02 Widgets | Codex | `codex/d-02-widgets` | D-01a, D-01b, P-04b, DS-01 | Claude | 1 a 5. `AVAudioEngine` a 0 en la extensión |
| D-03 Control y botón de Acción (corte si no está integrado el 22-02-2027) | Codex | `codex/d-03-control-accion` | D-01a, D-02 | Claude | 1 a 5. Ningún `perform` nuevo |
| D-04 Live Activity recortada (solo escenario A) | Codex | `codex/d-04-live-activity` | D-01a, D-01b, D-02, S-02, P-05, H-01 | Claude | 1 a 5. Expiración real en H-05 |
| D-05 Ajustes, Salida, Reproduciendo y Al acostarte | Kimi | `kimi/d-05-ajustes` | DS-02, B-03, C-04, X-03, L-01 | Codex | 1 a 5. Filas de C58 y ninguna más |
| D-06 Páginas de confianza | Kimi | `kimi/d-06-confianza` | DS-02, L-01, T-01, D-05 | Codex | 1 a 5. Peso y periodo leídos del código |
| D-07 Diagnóstico local y Enviar informe | Kimi | `kimi/d-07-diagnostico` | D-05, B-05b | Claude | 1 a 5. `URLSession` a 0. Sin fechas ni nombres. No toca `SleepNoise/Audio/` |
| E-02 Ficha, capturas y Notes for Review | Kimi | `kimi/e-02-ficha-capturas` | L-01, A-04, B-03, C-02, C-04, D-05, H-01 (marca, 04-12-2026) | Claude | Textos en es y en según 11 y C57, sin cifra de precio ni recuento de texturas. Test de interfaz que genera las seis capturas por idioma |
| H-03 Noche real | Dueño | `claude/h-03-acta` | B-03, B-04, B-05b, D-07, y A-05 y D-04 si existen | no aplica | Diez horas en iOS 17 y en iOS 26, con energía y memoria en Instruments |
| H-04 Compra real en sandbox | Dueño | `claude/h-04-acta` | C-04, H-01 | no aplica | Cada estado de la hoja Pro visto en dispositivo |

### Oleada 5 · Cierre

| Paquete | Agente | Rama | Depende de | Revisor | Puerta |
|---|---|---|---|---|---|
| Q-01 Auditoría de accesibilidad | Kimi | `kimi/q-01-accesibilidad` | A-04, A-07, B-02, B-03, B-04, C-02, C-04, D-05, D-06 | Codex | Auditoría del sistema sin incidencias, normal y AX5 |
| H-05 Ecosistema, puerta de diseño y VoiceOver en dispositivo | Dueño | `claude/h-05-acta` | D-02, D-03, D-05, Q-01, E-01 | no aplica | 04 Anexo B completo o con paquete de corrección |
| H-06a Beta | Dueño | `claude/h-06a-beta-acta` | H-03, H-04, H-05, D-06, D-07, T-01 | no aplica | TestFlight de 7 noches con 30 personas o más. 5 de 8 lo prefieren. Pruebas de FUNCIONES §6.3 |
| H-06b Envío | Dueño | `claude/h-06b-appstore` | H-06a, E-02 | no aplica | E-02 aprobado. Build enviada |

Las correcciones que salgan de H-03, H-04 y H-05 se abren como paquetes nuevos con el id del acta (por ejemplo `H-03-c1`) y siguen el mismo protocolo.

### 4.1 Dependencias, en texto

```
RUTA CRÍTICA
I-01 > I-02 > R-01 > S-04 > P-01 > F-01 > P-03b > A-03a > B-03 > B-04 > D-01a > D-01b > D-02 > H-05 > H-06a > H-06b
B-04 + las hojas de las oleadas 3 y 4 > Q-01 > H-05
R-01 > R-02 (H-02a, dueño) > F-01
P-01 + R-02 > P-02 > P-03b > B-01 > B-03
Entradas laterales, con plazo de corte (R7):
  P-03a (Cursor) > P-03b
  P-04a (Cursor) > P-04b > C-01 (Kimi) > D-01a
  F-02, DS-01, DS-03, S-01, X-01, L-01 (Kimi) > A-03a
  X-02 (Kimi) > B-01, B-03        X-03 (Kimi) > D-01a

CARRIL DE AUDIO (un escritor, en serie)
R-01 > [S-04 spike] > P-01 > P-05 > A-02a > A-02b > A-01 > A-05 (si H-02b)
R-02 va en paralelo con P-01: solo toca ThunderTexture.swift.
A-06 va en paralelo con P-05: no toca el contrato.
A-02b > A-02c (Cursor, solo tests en ficheros nuevos)

CARRIL DE DISEÑO
I-01 > DS-01 > DS-02 > DS-03 > DS-05
              \ S-01 > DS-04
DS-02 + DS-03 + DS-04 + P-03b + F-01 + X-01 + L-01 > A-03a > A-03b
A-03b > A-04 > C-04 > H-04
A-03a + A-06 + DS-05 > A-07
A-03a + B-01 + DS-05 + X-02 > B-03 > B-04

CARRIL DE MODELO Y COMPRA
R-02 + P-01 > F-01 > P-03b > C-03 > C-04
I-02 > P-03a (Cursor) > P-03b          P-02 > P-03b
I-02 + R-01 > P-04a (Cursor) > P-04b > C-01 > C-02          L-01 > C-01
P-03a + X-02 + X-03 > B-05a (Cursor) > B-05b > D-07

CARRIL DE ECOSISTEMA
C-01 + B-01 + B-04 + X-03 > D-01a > D-01b (con P-04b) > D-02 > D-03
D-02 + S-02 + P-05 + H-01 > D-04 (solo escenario A)
B-03 + C-04 + X-03 > D-05 > D-06
A-04 + B-03 + C-02 + C-04 + D-05 + L-01 > E-02 > H-06b

CARRIL DE DOCUMENTOS Y CADENAS
Día 1: docs/, docs/agents/ y AGENTS.md entran en main por PR.
I-01 > I-03 > X-01, X-02, X-03 (dos a la vez)
R-02 + F-02 > L-01 > todo paquete con cadenas

PUERTAS DEL DUEÑO
H-01: firma antes de H-02a. Acento antes de E-01, sí escrito antes de D-04, palabra inglesa de Manto antes de cerrar L-01.
H-02a tras R-02.  H-02b tras S-01, S-02, S-04: decide A-05 y ajusta DS-04.
H-03 tras B-03, B-04, B-05b, D-07 (y A-05 y D-04 si existen).  H-04 tras C-04.  H-05 tras Q-01.
H-06a tras H-03, H-04 y H-05.  H-06b tras H-06a y E-02.
```

---

## 5. Tabla completa, paquete a paquete

67 paquetes. Reparto como autor: Codex 31, Kimi 19, Cursor 5, Claude 4, dueño 8. La columna Clase resume el riesgo: `audio` (hilo de render), `modelo`, `interfaz`, `storekit`, `ecosistema`, `infra`, `docs`, `tests`, `dispositivo`.

**Cambios sobre la lista original de 55.**

- **F-01 (nuevo).** Protocolo para el motor inyectado en `MixerModel`, y `MixerModel` partido en extensiones por fichero (reproducción y sesión, niveles y persistencia, Marea, temporizador y mezclas). El protocolo `AudioEngineControlling` vive en `SleepNoise/Audio/AudioEngineControlling.swift` y el doble en `SleepNoiseTests/FakeAudioEngine.swift`. Incluyen `setMaster` de P-01, y por eso F-01 espera a P-01. Hoy `MixerModel` tiene cero tests y es el fichero por el que pasan cinco de los cambios pendientes.
- **F-02 (nuevo).** Partir `BreathingTests.swift` en un fichero por clase. Hoy mezcla seis clases sin relación y tres paquetes de la oleada 1 añaden tests ahí.
- **P-03 partido.** P-03a: `NightWindow`, `SaleGate` y `TipGate` en ficheros nuevos. P-03b: matriz final de `AccessPolicy`, prueba en Keychain con abstracción de almacenamiento en `TrialClock`, y `startTrial` fuera de `play()`.
- **P-04 partido.** P-04a: códec y tests del formato v2 en ficheros nuevos. P-04b: App Group, `MixStore` al contenedor compartido, entitlements y target de widgets en `project.yml`.
- **B-05 partido.** B-05a: `InterruptionPolicy` y `RoutePolicy` puras con tests de tabla. B-05b: cableado en `AudioSessionObserver`, `AudioSessionConfigurator` y `SleepAudioEngine`.
- **H-02 partido.** H-02a: escucha de PR-A, que cierra R-02. H-02b: spikes en dispositivo y puerta del bus. Motivo: la sesión única hacía esperar a PR-A por tres spikes.
- **A-02 partido en tres (revisión del 16-11-2026).** A-02a (Codex, oleada 2, audio): sustituye `XorShift32` por xoshiro128** con siembra splitmix32 y reajusta seeds y tests espectrales. A-02b (Codex, oleada 2, audio): trueno sin crack y hoguera sin la oscilación de 9,4 dB, con render de 60 s por textura en `.build/renders/` para la escucha del dueño. A-02c (Cursor, oleada 2, tests): `SleepNoiseTests/TextureCriteria.swift` y `TextureCriteriaTests.swift`, ficheros nuevos, con cresta menor de 12 dB, eventos a 6 dB o menos sobre el fondo y centroide distinto. A-01 pasa a depender de A-02b y fija los trims finales. T-01 fija su umbral final después de A-02a.
- **A-03 partido.** A-03a: `Route`, `PageView` como raíz y hojas vacías. A-03b: tope de seis capas, retirada de `MixerView` y `SoundRowView` y tests de interfaz.
- **D-01 partido.** D-01a: los intents con frase y el catálogo `AppShortcuts`. D-01b: los dos sin frase y el snapshot del App Group.
- **H-06 partido y E-02 nuevo.** H-06a: beta. H-06b: envío. E-02 (Kimi, revisa Claude): ficha, capturas y Notes for Review, que antes caían enteras en el dueño.
- **B-05b y D-07.** B-05b deja en `SleepNoise/Audio/DiagnosticsSink.swift` un protocolo `DiagnosticsSink` con `record(_ event: DiagnosticEvent)`, llamado solo desde el hilo principal y con implementación por defecto vacía. D-07 implementa el anillo como `DiagnosticsSink` en ficheros nuevos y lo inyecta en `AppRoot`. No toca `SleepNoise/Audio/`.
- **I-01 crece.** Añade `SleepNoiseTests/RenderCostTests.swift` (60 s offline con todas las capas a 1,0 y la Marea activa, cinco repeticiones, mediana en ns por frame, solo con `TEST_RUNNER_SN_BENCH=1`), `scripts/verify.sh --bench` (compila con `-O`, ocupa las dos plazas del semáforo y escribe `.build/bench.txt`), la comprobación del log de avisos, el PID en cada plaza del semáforo y `TARGETED_DEVICE_FAMILY: "1"`. La línea base vive en `docs/research/bench/BASELINE.md`.
- **Ajustes de alcance sin cambio de id.** X-01 a X-03 ya no tocan `PLAN-MAESTRO`. A-03a crea además el enum de rutas y una vista vacía por hoja. L-01 entrega además `scripts/strings-merge.sh`. I-01 incluye el semáforo de dos compilaciones y las variables de simulador y DerivedData. T-01 entrega solo el test: el enganche al modo largo es de Claude. P-02 incluye el reloj inyectable en `SleepTimerController`. El refactor de `MixerView` no se hace, porque A-03 lo retira entero.


Días: tamaño relativo, en días de persona. Sirve para comparar paquetes entre sí. No se usa para fechas (nota bajo la tabla).

| Id | Agente | Suplente | Ol. | Revisor | Clase | Días | Por qué este agente |
|---|---|---|---|---|---|---|---|
| I-01 | Claude | Codex | 0 | Codex | infra | 1-2 | Es la puerta de todos y ya tiene el entorno probado |
| I-02 | Codex | Claude | 0 | Claude | infra | 0,5-1 | Local, puede observar las ejecuciones. Sirve de prueba de humo |
| I-03 | Claude | no | 0 | Codex | docs | 0,5 | Regla de Cursor, plantilla de PR y briefs. `AGENTS.md` ya entró el día 1 |
| F-02 | Kimi | Codex | 0 | Codex | tests | 0,5 | Mecánico y verificable. Prueba de humo con compilación |
| X-01 | Kimi | Claude | 0 | Claude | docs | 1-2 | Spec y reconciliación enteras en contexto |
| X-02 | Kimi | Claude | 0 | Claude | docs | 1-2 | Igual |
| X-03 | Kimi | Claude | 0 | Claude | docs | 1-2 | Igual |
| R-01 | Codex | no | 0 | Claude | audio | 2-4 | Toca el contrato de audio y los metadatos de intents |
| R-02 | Codex | no | 0 | Claude | modelo | 3-4 | Sigue en la rama de PR-A y toca textura y modelo |
| H-02a | Dueño | no | 0 | no aplica | dispositivo | 0,5 | Solo se puede oír en un iPhone |
| S-01 | Kimi | Codex | 1 | Codex | interfaz | 1-2 | Prototipo desechable. Calibra a Kimi en gestos |
| S-02 | Codex | no | 1 | Claude | ecosistema | 2-3 | Live Activity e intents piden compilar |
| S-03 | Kimi | no | 1 | Codex | dispositivo | 1-2 | Investigación barata que no bloquea 1.0 |
| S-04 | Codex | no | 1 | Claude | audio | 2-3 | Dueño del contrato de audio |
| F-01 | Claude | Codex | 1 | Codex | modelo | 2-3 | Refactor de zona caliente con el fichero cerrado a los demás. Dueño del protocolo del motor y del doble |
| L-01 | Kimi | Codex | 1 | Claude | tests | 3-5 | Volumen de claves con la guía de copy entera en contexto |
| DS-01 | Kimi | Codex | 1 | Codex | interfaz | 2-3 | Valores y tests de contraste. Calibra a Kimi en Swift |
| DS-02 | Codex | no | 1 | Claude | interfaz | 3-4 | Disponibilidad de iOS 26 y estilos del sistema. No declara las puertas de P-03a |
| DS-03 | Kimi | Codex | 1 | Codex | interfaz | 2-3 | Componente acotado con lógica probada por reloj |
| P-01 | Codex | no | 1 | Claude | audio | 3-5 | Contrato de audio |
| P-02 | Codex | Kimi | 1 | Claude | modelo | 1-2 | Ruta crítica. Concurrencia y reloj inyectado |
| P-03a | Cursor | Kimi | 1 | Codex | modelo | 1 | Lógica pura en ficheros nuevos. Prueba de humo de Cursor |
| P-03b | Codex | no | 1 | Claude | modelo | 2-3 | Keychain y tres zonas calientes |
| P-04a | Cursor | Kimi | 1 | Codex | modelo | 1-2 | Códec puro con tests de ida y vuelta |
| P-04b | Claude | Codex | 1 | Codex | infra | 1-2 | `project.yml` y entitlements son del integrador |
| T-01 | Cursor | Kimi | 1 | Codex | tests | 2-3 | Test puro y determinista que corre en la CI |
| H-02b | Dueño | no | 1 | no aplica | dispositivo | 1 | VoiceOver, StandBy y escucha de renders |
| P-05 | Codex | no | 2 | Claude | audio | 2-3 | Atómicos nuevos en el puente de C |
| A-02a | Codex | no | 2 | Claude | audio | 2-3 | Cambia el PRNG de todas las texturas: pide medir |
| A-02b | Codex | no | 2 | Claude | audio | 2-3 | Trueno y hoguera: pide medir y dejar renders para el oído |
| A-01 | Codex | no | 2 | Claude | audio | 2-3 | Contrato de audio y recortador. Trims finales, tras A-02b |
| A-02c | Cursor | Kimi | 2 | Codex | tests | 1-2 | Tests puros en ficheros nuevos que corren en la CI |
| A-06 | Codex | no | 2 | Claude | audio | 3-4 | Secuencia de `setBreathing` con fecha. Cero campos nuevos |
| DS-04 | Codex | Kimi | 2 | Claude | interfaz | 3-4 | Gesto con bloqueo de eje y accesibilidad |
| DS-05 | Codex | Kimi | 2 | Claude | interfaz | 3-4 | Dos gestos de pantalla completa |
| A-03a | Codex | no | 2 | Claude | interfaz | 2-3 | Sustituye la pantalla y toca `AppRoot` |
| A-03b | Codex | no | 2 | Claude | interfaz | 2 | Toca `MixerModel` y retira `MixerView` |
| B-01 | Codex | no | 2 | Claude | modelo | 3-5 | Ruta crítica. Publica rampas al motor |
| C-01 | Kimi | Codex | 2 | Claude | modelo | 2-3 | Modelo con tests de tabla sobre el códec ya hecho |
| C-03 | Codex | no | 2 | Claude | storekit | 2-4 | StoreKit solo se valida con sesión de pruebas |
| B-05a | Cursor | Kimi | 2 | Codex | modelo | 1-2 | Políticas puras con tests de tabla |
| A-04 | Kimi | Codex | 3 | Codex | interfaz | 3-4 | Lista de filas ya construidas en DS-04 |
| A-07 | Codex | no | 3 | Claude | interfaz | 3-5 | Háptica y línea de agua como control |
| B-02 | Kimi | Codex | 3 | Codex | interfaz | 2-3 | Hoja de sistema sobre un modelo ya probado |
| B-03 | Codex | no | 3 | Claude | interfaz | 4-5 | Ruta crítica. Pantalla encendida y batería |
| B-05b | Codex | no | 3 | Claude | modelo | 3 | Sesión de audio y `SleepAudioEngine`. Deja `DiagnosticsSink` |
| C-02 | Kimi | Codex | 3 | Codex | interfaz | 3-4 | Lista y menú del sistema |
| C-04 | Codex | no | 3 | Claude | storekit | 4-5 | Compra, prueba y puerta de venta |
| E-01 | Kimi | Codex | 3 | Codex | interfaz | 1-2 | Script reproducible con test de píxeles |
| A-05 | Codex | no | 4 | Claude | audio | 3-5 | Contrato de audio. Condicionado a H-02b |
| B-04 | Codex | Kimi | 4 | Claude | modelo | 3-4 | Ruta crítica. Gobierna motor y Marea |
| D-01a | Codex | no | 4 | Claude | ecosistema | 3 | Los metadatos de intents fallaron ya una vez |
| D-01b | Codex | no | 4 | Claude | ecosistema | 1-2 | Intents sin frase y snapshot para los widgets |
| D-02 | Codex | no | 4 | Claude | ecosistema | 3-5 | Extensión de WidgetKit |
| D-03 | Codex | Kimi | 4 | Claude | ecosistema | 2-3 | Controles bajo disponibilidad de iOS 18 |
| D-04 | Codex | no | 4 | Claude | ecosistema | 4-5 | ActivityKit. Solo en escenario A |
| D-05 | Kimi | Codex | 4 | Codex | interfaz | 3-4 | Lista de sistema con filas cerradas |
| D-06 | Kimi | Codex | 4 | Codex | interfaz | 2-3 | Páginas de texto con la guía de copy |
| D-07 | Kimi | Codex | 4 | Claude | modelo | 3-5 | Anillo puro con tests, como `DiagnosticsSink`. No toca audio |
| E-02 | Kimi | Codex | 4 | Claude | tests | 2-3 | Textos con la guía de copy entera en contexto y capturas por test |
| H-03 | Dueño | no | 4 | no aplica | dispositivo | 2-3 | Noches reales, llamadas y AirPods |
| H-04 | Dueño | no | 4 | no aplica | dispositivo | 1-2 | Solo el titular puede comprar en sandbox |
| Q-01 | Kimi | Codex | 5 | Codex | tests | 3-5 | Barrido amplio, repetitivo y con test automático |
| H-05 | Dueño | no | 5 | no aplica | dispositivo | 2-3 | Bloqueo, StandBy, Siri por voz y VoiceOver real |
| H-06a | Dueño | no | 5 | no aplica | dispositivo | 4-8 | Beta de 7 noches y pruebas con personas |
| H-06b | Dueño | no | 5 | no aplica | dispositivo | 1-2 | Solo el titular sube y envía |
| H-01 | Dueño | no | 0 a 1 | no aplica | dispositivo | 1-2 | Decisiones, firma y altas del titular de la cuenta |

La columna Días suma de 124,5 a 187 días de persona para los 59 paquetes de agentes (de 25 a 37 semanas-ingeniero): Codex 77,5-112, Kimi 36,5-57,5, Cursor 6-10 y Claude 4,5-7,5. La reconciliación §5 estima el mismo alcance en 64,5 a 73 semanas-ingeniero (de 322 a 365 días), sin la reserva del 30 %. La tabla es entre la mitad y un tercio de esa cifra y la diferencia no está explicada. Por eso la columna no se usa para fechas. Se revisa el 27-11-2026 con los datos de la oleada 0.

---

## 6. Lo que no se delega

Ningún agente puede hacer nada de esta sección. Claude prepara cada sesión (build instalable, lista de comprobación, plantilla del acta) y escribe el acta con lo que el dueño dicte.

### 6.1 Las cuatro decisiones de la reconciliación §6

| # | Decisión | Recomendación escrita | Plazo | Qué bloquea |
|---|---|---|---|---|
| 1 | Acento: Índice `#F0C020` o la alternativa (b) | Índice, tras una prueba de cinco segundos con la página real sonando a oscuras | Viernes 27-11-2026 | E-01. DS-01 no espera: el acento es un único token |
| 2 | Marca | SleepNoise | Viernes 04-12-2026 | Ficha de E-02 y de H-06b. Icono y legal avanzan |
| 3 | Segunda pareja, es decir, capacidad para la Live Activity | Si no está confirmada el 14-12-2026, escenario B y Live Activity a 1.1 | Lunes 14-12-2026 | D-04 |
| 4 | "Manto" en inglés | "Blanket", salvo veto de un hablante de inglés de Estados Unidos | Antes de grabar el copy en inglés (semana 6, que empieza el 28-12-2026) | Una sola clave de L-01 |

Si un plazo pasa sin respuesta, se aplica la recomendación.

**Sobre la decisión 1.** El 27-11-2026 no habrá página real ni galería en un iPhone: DS-02 espera a DS-01 y Codex lleva hasta esa fecha I-02, R-01 y R-02. Antes de ese día Claude deja una copia del mockup de `docs/design/mockups/` con la opción (b) del acento, porque el que hay solo trae el Índice. El dueño mira las dos a oscuras en su iPhone durante cinco segundos y elige, o deja pasar el plazo y se aplica Índice. La prueba que pide la reconciliación, con la página real sonando, se repite al integrar A-03a. Si entonces cambia de opinión, se cambia el token único y se rehace E-01.

**Sobre la decisión 3.** La reconciliación habla de una segunda pareja de ingenieros. Con agentes la pregunta equivalente es si hay capacidad demostrada. Propuesta para que el dueño decida con datos el 14-12-2026: escenario A solo si ese día PR-A está en `main`, la CI es puerta, Codex ha integrado P-01 sin agotar su cuota y el spike S-02 responde que sí. Si falta una de las cuatro, escenario B.

Esta equivalencia es una propuesta. El dueño la acepta o la rechaza el día 1 y queda en el acta de H-01. Si la rechaza, o si el 14-12-2026 no hay un sí escrito del dueño, se aplica la reconciliación §6 n.º 3: escenario B, D-04 cancelado y Live Activity a 1.1, aunque se cumplan los cuatro criterios. Claude presenta los datos y no decide el escenario.

**Sobre el iPad.** I-01 deja la app solo para iPhone (`TARGETED_DEVICE_FAMILY: "1"`), porque el iPad es de 1.2 y ninguna spec lo diseña. Si el dueño quiere mantener el iPad en 1.0, es una decisión nueva: pide diseño, un paquete propio y capturas. Conviene cerrarlo antes del primer envío.

### 6.2 Trabajo del dueño que no es una decisión

| Paquete | Qué | Cuándo |
|---|---|---|
| H-01 | Permisos y planes del día 1 (§9). Visibilidad del repo y protección de `main`. App Group, capacidades y firma en el portal. Producto con Family Sharing en Connect | Días 1 a 3. Firma antes de H-02a. App Group y producto antes de H-02b |
| H-01 · Firma para dispositivo | Antes del 20-11-2026 el dueño confirma que su cuenta de desarrollador está activa, inicia sesión en Xcode y da a Claude el identificador de equipo. Claude lo deja en un fichero local sin versionar (`Signing.local.xcconfig`, en `.gitignore`) e instala la build de `main` en el iPhone del dueño como prueba. Sin esto no hay H-02a | Antes del 20-11-2026 |
| H-01 · Nombre | Comprobación legal del nombre (C10) | 04-12-2026 |
| H-01 · Inglés | Hablante de inglés de Estados Unidos para el catálogo y para "Blanket" | Localizado el 11-12-2026. Revisión hecha antes del 28-12-2026 |
| H-01 · Dispositivos | Un iPhone con iOS 17, otro con iOS 26 y AirPods para H-03 | Confirmados el 14-12-2026 |
| H-01 · Connect | Precio de lista de 29,99 € sin precio promocional, Family Sharing y producto de nivel 0 oculto | Antes de lanzar C-03 |
| H-01 · Sandbox | Cuentas de sandbox con grupo familiar y tiendas de España, México y Argentina | Antes de H-04 |
| H-01 · Probadores | Reclutamiento de la beta: 30 personas o más, 8 de ellas usuarias de Sonidos de fondo | Al abrir la oleada 3 |
| H-01 · Featuring | Formulario de featuring | Seis semanas antes de la ventana elegida |
| H-02a | Once texturas con auriculares, un atajo por voz en inglés y en español, Noche con Auto-Lock y el ajuste "Mantener encendida" en sus tres valores | Cuando R-02 esté listo. Ventana orientativa: del 30-11-2026 al 04-12-2026 |
| H-02b | Arrastre con VoiceOver y Switch Control, intent sobre actividad terminada, foto del rojo de StandBy, escucha de los cinco renders de timbre. Puerta del bus | Al cerrar los spikes. Entre el 14-12-2026 y el 03-01-2027 |
| H-03 | Diez horas bloqueado con Instruments en iOS 17 y en iOS 26, llamadas, alarma, Siri, AirPods, Auto-Lock | Fin de la oleada 4 |
| H-04 | Compra, restauración, reembolso, grupo familiar, varias tiendas, reinstalación | Tras C-04 |
| H-05 | Widgets en bloqueo y StandBy, Control, botón de Acción, Siri por voz, puerta de diseño a oscuras y con filtro rojo, VoiceOver completo | Tras Q-01 |
| H-06a | Beta. TestFlight de 7 noches con 30 personas o más, 8 de ellas usuarias de Sonidos de fondo. Puerta: 5 de 8 lo prefieren y ninguna ausencia repetida en 3 respuestas. Pruebas de FUNCIONES §6.3: tres personas de más de 65 años llegan al sonido sin ayuda y, si existe A-05, 8 personas a oscuras encuentran "más grave" (7 de 8). Cuestionario de Marea | Cierre. El reclutamiento empieza al abrir la oleada 3 |
| H-06b | Envío. Aprueba E-02 (ficha, capturas y Notes for Review), sube y envía | Tras H-06a |

Las ventanas de H-02a a H-06b son orientativas y se actualizan el 27-11-2026. En total, de 12,5 a 21,5 días de trabajo del dueño.

Tampoco se delega: fusionar en `main`, publicar en GitHub, cambiar ajustes del repo o de las cuentas, y cualquier gasto.

---

## 7. Calendario

El plan maestro mide en semanas-pareja: de 34,25 a 36,5 en el escenario A y de 32,25 a 34 en el B, con una reserva del 30 % aparte. Sus hitos son la semana 30 con dos parejas y la semana 44 con una. La semana 1 empieza el 23-11-2026.

Esas cifras no se convierten en semanas de agente con una regla de tres. No hay ninguna medida de velocidad de agentes en este repo. El único precedente es el PR #3: llegó rápido, no compilaba y su interfaz se descartó. Lo que sigue son horquillas de trabajo, no fechas comprometidas.

| Oleada | Horquilla | Qué la fija |
|---|---|---|
| 0 | 1 a 2 semanas | Pruebas de humo, permisos del dueño, primera vuelta de la CI y la escucha H-02a |
| 1 | 2 a 4 semanas | P-01 en el carril de audio, F-01 y la sesión H-02b |
| 2 | 3 a 5 semanas | Cuatro paquetes de audio en serie y A-03a, que espera a siete dependencias |
| 3 | 3 a 4 semanas | Revisión de nueve paquetes con interfaz por un solo integrador |
| 4 | 3 a 5 semanas | Cadena B-04, D-01a, D-01b, D-02 en serie y las noches reales de H-03 |
| 5 | 6 semanas de referencia | Accesibilidad, puerta de diseño y la beta de 7 noches de H-06a. Se recalcula con H-06a. La referencia del plan para esta fase es de seis semanas (semanas 22 a 28) |
| **Suma** | **18 a 26 semanas**, contadas desde el 16-11-2026 | Es la suma aritmética de las horquillas, no una previsión. La referencia sigue siendo el plan maestro: semana 30 en A y semana 44 en B. App Review va aparte |

El suelo lo fija el carril de Codex: 31 paquetes, 77,5 a 112 días de tamaño relativo, más sus 20 revisiones, con un worktree de autor y en algún tramo dos (§3.2). Sin dato de velocidad no hay suelo creíble por debajo de 20 semanas. La cifra de 16 semanas de la primera versión de este plan se retira: exigía cuatro integraciones por semana desde la primera, ninguna segunda ronda y ningún paquete de corrección. La oleada 0 solo cierra el 27-11-2026 si cada paquete sale en su mínimo. Si Kimi pasa su calibración, cuatro paquetes de Codex pasan a Kimi por defecto (§3.7). Si Kimi o Cursor no pasan su calibración, el trabajo recae en Codex y Claude y la horquilla se va hacia los hitos del plan maestro. En ese caso, el escenario B y su semana 44 siguen siendo la referencia.

**Lo que no se acelera con más agentes.**

- La escucha y las pruebas en dispositivo: H-02a, H-02b, H-03, H-04 y H-05 suman entre 7 y 10 días del dueño. H-03 incluye dos noches de diez horas.
- La revisión y la integración. Hay un integrador y un límite de cuatro PR abiertos. Con 59 paquetes de agentes, a razón de tres o cuatro integraciones por semana, salen de 15 a 20 semanas solo de integración, con cero segundas rondas. Este es el techo real de velocidad.
- El carril de audio. Ocho paquetes en serie con revisión obligatoria.
- Las decisiones del dueño, con fechas fijas: 27-11-2026, 04-12-2026 y 14-12-2026.
- La beta: 7 noches con 30 personas o más, más el tiempo de reunirlas. Por eso el reclutamiento empieza al abrir la oleada 3.
- App Review, que no depende de nadie del proyecto.
- El Mac: dos compilaciones a la vez y las cuotas por ventanas de cinco horas.

**Puntos de medida y replanificación.**

- **27-11-2026.** Debería estar fusionado R-01. R-02 y H-02a pueden pasar a la semana siguiente. Se mide: días de I-01 a PR-A en `main`, rondas por paquete y por agente, minutos de CI gastados, cuota de Codex consumida. Con eso se recalcula la horquilla.
- **14-12-2026.** Claude presenta los cuatro criterios de §6.1. Decide el dueño. Sin respuesta, escenario B.
- **Fin de la oleada 2.** Si la media supera las dos rondas por paquete o hay más de cuatro PR en cola de forma sostenida, Claude lleva al dueño una propuesta de recorte y el dueño decide. D-03 se corta sin consulta si no está integrado el 22-02-2027, que es el inicio de la semana 14 (C26). D-04 sigue la decisión 3. A-05 no se recorta por capacidad: la reconciliación §5 y §6 solo permite moverla por el spike I0-7 o por la puerta del bus. Sacarla por otro motivo es una decisión nueva del dueño, escrita en un acta.

---

## 8. Riesgos de delegar y mitigaciones

| # | Riesgo | Precedente o evidencia | Mitigación |
|---|---|---|---|
| 1 | Código que no compila llega a revisión | PR #3: error de metadatos de App Intents y un rango mal tipado. PR #1 también se escribió sin Xcode | Puertas 1 y 3. Cursor fuera de intents, widgets, StoreKit y SwiftUI. Lo que no pasa la puerta no se revisa |
| 2 | Interfaz sin dirección de diseño | PR #3: baldosas, chips y resplandor que hubo que descartar | La interfaz solo va a agentes locales, con la spec y la sección exacta en el brief, galería DEBUG, tests de interfaz y la puerta de diseño H-05 |
| 3 | La revisión se convierte en reescritura | Revisar el PR #3 costó dos documentos y cinco arreglos | Tope de 30 líneas de arreglo del integrador y regla de las dos rondas |
| 4 | Dos agentes rompen el contrato de audio | Un campo nuevo toca cuatro sitios y el test de desgarro se rellena a mano | Un solo escritor (Codex), turnos de §3.9 y revisión de Claude en todo el carril |
| 5 | Choques en ficheros calientes | `MixerModel`, catálogo de cadenas y `project.yml` aparecen en decenas de paquetes | F-01, F-02, enum de rutas en A-03a, fragmentos de cadenas y `project.yml` solo de Claude |
| 6 | Codex agota la cuota | Lleva 31 paquetes y el plan contratado no está comprobado | Medir en la oleada 0. Modelo más barato para lo mecánico y para revisar. Suplente Kimi en DS-04, DS-05, B-04, D-03 y P-02 |
| 7 | Kimi no arranca o no rinde | CLI archivada. Fiabilidad sin medir. Nueve paquetes suyos están en la ruta crítica: F-02, DS-01, DS-03, S-01, X-01, X-02, X-03, L-01 y C-01 | Prueba de humo el día 1, calibración con tres paquetes, Codex de suplente y plazo de corte de tres días laborables (R7) |
| 8 | Kimi actúa sin preguntar | El modo print aprueba todas las herramientas | Worktree aislado, sin push, lista cerrada de ficheros, `main` protegida y revisión del diff completo |
| 9 | Cursor no puede trabajar | Plan sin comprobar. Docs sin publicar. Sin CI. P-03a y P-04a están en la ruta crítica | Solo cinco paquetes, todos con suplente. Ninguno antes de I-02 e I-03. P-03a pasa a Kimi el día 3 si Cursor no está listo (R7) |
| 10 | La CI gasta los minutos de macOS | Repo público hoy: sin coste de minutos en runner estándar. Si pasa a privado, consumo sin comprobar | La puerta primaria es local. CI solo en PR y en `main`. Modo largo una vez al día. Runner propio descartado mientras el repo sea público |
| 11 | El sandbox de Codex bloquea el simulador y el commit | Probado el 16-11-2026 con `codex sandbox -P :workspace` | El dueño elige el día 1 entre la opción A (sin sandbox, con guardas fuera del agente) y la B (Codex solo edita). Prueba de humo con commit (§9) |
| 12 | Tests en verde y audio malo | Arroyo y hoguera desnivelados en el PR #3 no los detectaba ningún test | Tests ponderados A, renders de referencia y escucha del dueño en H-02a y H-02b. Nada de audio se da por cerrado sin oído |
| 13 | Los agentes leen specs sin reconciliar | 05, 07 y 09 aún no tienen los deltas aplicados | X-01 a X-03 en la oleada 0. Hasta entonces los briefs citan la ficha de la reconciliación |
| 14 | El integrador es el punto único de fallo | Un solo revisor para 31 paquetes de Codex. Sin suplente | Límite de PR abiertos, orden de atención por ruta crítica, propuesta de recorte al dueño y reconstrucción del estado desde `ESTADO.md` si la sesión se corta (§3.7) |
| 15 | Fallos que solo salen en iOS 17 | Solo hay simuladores con iOS 26.5 | H-03 en un iPhone con iOS 17. Runtime de iOS 17 si el dueño lo instala |
| 16 | Afirmaciones médicas o vocabulario vetado en cadenas nuevas | Tres agentes escriben texto | Lint de copy dentro de `scripts/verify.sh` desde L-01 y revisión de Claude en todo lo que toque el catálogo |
| 17 | Lo publicado queda a la vista de cualquiera | El repo es público: `docs/` trae la investigación de mercado, el reparto gratis y Pro, las revisiones y este plan. Los briefs como issues también | Paso 0 del día 1: el dueño decide la visibilidad antes de cualquier push |
| 18 | Una sesión se cuelga o muere con una plaza del semáforo ocupada | Ningún lanzamiento tenía tope de reloj | Tope por lanzamiento, PID en cada plaza y salida 75 a los 30 minutos (§3.2 y §3.7) |
| 19 | Un aviso que no es de Swift pasa la puerta | El PR #3 compiló con `--no-app-shortcuts-localization` sin fallar | `verify.sh` guarda el log y falla con cualquier aviso. Comprueba que `AppShortcuts.strings` en español llega al bundle |

---

## 9. Primeros pasos: los tres primeros días

Nada de esto se ha ejecutado. Los comandos marcados [SV] usan opciones que hay que confirmar con `--help` antes de lanzarlos.

### Día 1 · martes 17-11-2026

**Dueño (una hora).**

0. **Decidido el 16-11-2026: el repo se queda público (opción b).** `docs/`, los briefs, los issues y los comentarios de PR son visibles para cualquiera. Los minutos de runner estándar no se cobran y la protección de `main` se puede activar hoy mismo. Consecuencia para todos los agentes: nada de datos personales, claves ni rutas de la máquina en commits, PR o issues.
1. Autoriza llevar `docs/` y `AGENTS.md` a `main` por PR. Sin esto no hay briefs legibles para ningún agente.
2. Protege `main` con PR obligatorio. El check de CI obligatorio se añade el día 3.
3. Confirma el plan de Cursor (los agentes en la nube piden Premium o superior) y fija un límite de gasto. Confirma el plan de ChatGPT y el de Kimi.
4. Decide sobre Kimi: instalar la CLI nueva o trabajar desde Kimi Code.app. Confirma que acepta enviar código del repo a ese servicio.
5. Abre el repo en Codex (ChatGPT.app) y lo marca como de confianza. Elige la opción A o la B de más abajo.
6. Confirma que su cuenta de desarrollador está activa y da el identificador de equipo de firma (§6.2). Sin esto no hay H-02a.
7. Acepta o rechaza que "capacidad demostrada" sustituya a "segunda pareja" en la decisión 3 (§6.1).
8. Acepta o rechaza que R-01 se fusione antes de la escucha H-02a (nota de la oleada 0).
9. Autoriza de forma general los comentarios de Claude en los PR de Cursor para devolver el log de la CI.

**Claude.**

```
cd ~/sleep-noise-ios
git add docs AGENTS.md && git commit -m "docs: plan maestro, reconciliación, specs, plan de agentes y AGENTS.md"
git push -u origin research/plan-sueno          # solo tras los pasos 0 y 1
mkdir -p ~/wt/sleepnoise
git fetch origin
git worktree add ~/wt/sleepnoise/claude-i-01 -b claude/i-01-verify origin/main
```

Con el permiso del paso 1, Claude abre un PR de `research/plan-sueno` a `main` con `docs/` (incluidos `docs/agents/` y los briefs de I-02 y F-02 en `docs/briefs/`) y `AGENTS.md`, y lo fusiona antes de crear ningún worktree de agente. Desde ese momento `docs/` vive en `main`. Con eso I-03 se reduce a la regla de Cursor, la plantilla de PR y los demás briefs.

Escribe `scripts/verify.sh` (I-01). Su núcleo, con simulador y DerivedData por variable:

```
SIM="${SN_SIM:-iPhone 17}"; DD="${SN_DERIVED:-$PWD/.build/DerivedData}"
xcodegen generate
xcodebuild test -project SleepNoise.xcodeproj -scheme SleepNoise \
  -destination "platform=iOS Simulator,name=$SIM" -derivedDataPath "$DD" \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES GCC_TREAT_WARNINGS_AS_ERRORS=YES 2>&1 | tee "$DD/../verify.log"
test ${PIPESTATUS[0]} -eq 0
! grep -nE 'warning: |appintentsmetadataprocessor.*(warning|error)|no-app-shortcuts-localization' "$DD/../verify.log"
```

`SWIFT_TREAT_WARNINGS_AS_ERRORS` no convierte en error los avisos del procesador de metadatos de App Intents, los de C, los del catálogo de cadenas ni los del catálogo de assets. Por eso el script guarda el log y lo inspecciona. Desde R-01 añade: `find "$DD" -path '*SleepNoise.app/es.lproj/AppShortcuts.strings' | grep -q .`. El patrón exacto del procesador se fija ejecutando el script una vez contra la rama del PR #3 [SV, no se ha compilado].

Lo ejecuta, comprueba los 49 tests y comprueba que falla con un error sembrado y con un aviso sembrado. Añade `.build/` a `.gitignore`, el semáforo de dos plazas con PID y caducidad (§3.2), el modo `--bench` con `RenderCostTests` (§5) y `TARGETED_DEVICE_FAMILY: "1"` en `project.yml`.

**Pruebas de humo, sobre la rama de I-01.**

```
CODEX="/Applications/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"
git worktree add ~/wt/sleepnoise/codex-humo -b codex/humo claude/i-01-verify
"$CODEX" exec -C ~/wt/sleepnoise/codex-humo -s workspace-write \
  "Ejecuta SN_SIM='iPhone 17 Pro' scripts/verify.sh y pega las últimas 20 líneas. Después crea .build/humo.txt, crea HUMO.md en la raíz, haz git add HUMO.md && git commit -m 'chore(humo): prueba' y pega git log -1 --oneline."
```

Comprobado el 16-11-2026 con `codex sandbox -P :workspace`: ese perfil no deja hablar con CoreSimulator y deja `.git` en solo lectura, también en un worktree enlazado, porque su índice vive en `<repo>/.git/worktrees/`. `--add-dir` no lo resuelve: el fallo del simulador es de XPC, no de rutas. Salvedad: se probó el perfil integrado con `codex sandbox`, no una sesión `exec -s workspace-write` [SV]. La prueba de humo de arriba lo confirma o lo desmiente. Si lo confirma, decisión del dueño el día 1, una de dos.

- **Opción A.** Codex con `-s danger-full-access -C <worktree>`. Entonces "sin push ni `gh`" depende de la instrucción, así que las guardas van fuera del agente: `main` protegida desde el día 1, `git config extensions.worktreeConfig true` y `git -C <worktree> config --worktree remote.origin.pushurl bloqueado://sin-push`, y Claude compara `git ls-remote --heads origin` antes y después de cada sesión.
- **Opción B.** Codex en `workspace-write` solo edita. Claude ejecuta `scripts/verify.sh` fuera del sandbox, le devuelve el log y hace los commits con el mensaje que Codex propone.

Lo que se elija se anota en `docs/agents/CODEX.md` §1.1.

```
kimi --print -p "Responde solo: OK"             # si falla, la CLI archivada queda descartada
git worktree add ~/wt/sleepnoise/kimi-humo -b kimi/humo claude/i-01-verify
kimi --print -w ~/wt/sleepnoise/kimi-humo \
  -p "Ejecuta SN_SIM='iPhone 17e' scripts/verify.sh y pega las últimas 20 líneas. Después crea HUMO.md en la raíz, haz git add HUMO.md && git commit -m 'chore(humo): prueba' y pega git log -1 --oneline."
```

Con la CLI nueva la orden equivalente es `kimi -p` [SV].

### Día 2 · miércoles 18-11-2026

- Codex revisa I-01. Claude ejecuta antes `scripts/verify.sh` y deja el log, porque `exec review` no admite `-C` ni `-s` y corre en solo lectura (`docs/agents/CODEX.md` §1.4). Si Codex no puede revisar, rige el revisor de reserva de §2.3. Claude abre el PR y lo fusiona.
- Claude escribe I-03: `.cursor/rules/sleepnoise.mdc` que solo remite a `AGENTS.md`, la plantilla de PR y los briefs que faltan en `docs/briefs/`: R-01, X-01, X-02, X-03, P-03a. Antes de lanzar cada paquete comprueba que el brief y cada ruta de "Lee antes" existen en `origin/main`.
- Codex arranca I-02 en `~/wt/sleepnoise/codex-i-02`. Kimi arranca F-02 en `~/wt/sleepnoise/kimi-f-02`. Sus briefs ya están en `main` desde el día 1.
- Al fusionar I-03, Kimi arranca X-01 y X-02. X-03 arranca cuando entregue el primero. No compilan, así que no ocupan plaza del semáforo, pero sí cuentan para la concurrencia de Kimi.

### Día 3 · jueves 19-11-2026

- CI en verde sobre `main` y en rojo en el PR de control. La rama del PR #3 no trae el workflow ni `scripts/verify.sh`, y el workflow solo se dispara con `pull_request` y con push a `main`. Por eso Claude crea `claude/ci-control-pr3` desde `origin/cursor/calm-launch-features-015c`, fusiona en ella la rama de I-02 y abre un PR en borrador contra `main`, con permiso del dueño. Ese PR debe salir en rojo con el error de metadatos de App Intents. Se cierra sin fusionar y se borra la rama, antes de fusionar R-01. El dueño añade el check obligatorio a la protección de `main`.
- Codex arranca R-01. La base es `main`. Los ficheros de motor, modelo, Noche, intents y dos ficheros de test salen de la rama del PR #3:

```
git worktree add ~/wt/sleepnoise/codex-r-01 -b codex/r-01-pr-a-base origin/main
cd ~/wt/sleepnoise/codex-r-01
git checkout origin/cursor/calm-launch-features-015c -- SleepNoise/Audio SleepNoise/Model SleepNoise/Intents \
  SleepNoise/Features/Bedtime SleepNoiseTests/DSPGeneratorTests.swift SleepNoiseTests/PolicyTests.swift
```

  No se trae la carpeta de tests entera: F-02 ya partió `BreathingTests.swift`. El resto (`MixerModel`, `AppRoot`, catálogo) va a mano, como dice el brief R-01. `BedtimeView.swift` se adapta: sin `DesignTokens`, con literales privados.

  El brief nombra los cinco arreglos de `docs/REVIEW-PR3-2026-11-16.md` y prohíbe `MixSheet.swift`, `PresetStrip.swift`, `SoundTileView.swift`, `DesignTokens`, `Theme`, los colorsets y `PaywallView`.
- Primer encargo a Cursor: P-03a, como issue de GitHub con el brief. Es su prueba de humo con la CI como puerta. Si el plan de Cursor no está confirmado, la CI no es puerta obligatoria o los documentos no están en `main`, P-03a pasa hoy a su suplente (R7).
- Con permiso del dueño, Claude comenta en el PR #3 que se parte y que PR-A lo sustituye.
- Claude revisa F-02 y el primero de los X. Con eso hay tres datos de calibración antes del fin de semana.

**Al cierre del día 3 debería ser cierto:** existe una orden única de verificación, la CI es puerta de `main`, los tres agentes han hecho al menos una entrega medible y PR-A está en marcha. Si algo de esto no se cumple, se corrige antes de lanzar la oleada 1.

---

## Registro de revisión

Revisión del 16-11-2026. 42 hallazgos comprobados contra el código, los documentos fuente y la máquina. Todos describen un problema cierto y se aplican. En seis se cambió el arreglo propuesto.

**Aplicado.**

- Publicación: el repo es público y el dueño decide antes de publicar. `docs/` y `AGENTS.md` entran en `main` el día 1. `main` protegida desde el día 1. Firma antes de H-02a.
- Codex: el sandbox no llega al simulador ni deja hacer commit (reproducido). Opciones A y B. Revisión con log previo.
- Ruta crítica: R7 reescrita con once paquetes de Cursor y Kimi y plazo de corte. Revisor de reserva.
- Audio: desgarro por bytes, P-01 sin esperar a R-02, A-06 sin campos nuevos, A-02 partido, protocolo del motor en F-01, `DiagnosticsSink`, `--bench`.
- Turnos y puertas: filas nuevas en §3.9, P-03b tras P-02, `verify.sh` falla con cualquier aviso, PR de control, topes de reloj.
- Producto: reglas de reparto en `AGENTS.md`, solo iPhone, A-05 fuera del recorte, decisión 3 del dueño, beta completa, E-02.
- Calendario: sin suelo de 16 semanas. Días no sirve para fechas.
- Paquetes: de 61 a 67.

**Arreglo cambiado, con motivo.**

- `--add-dir` para el sandbox: no resuelve el simulador. Opción A o B.
- Excepciones en `AGENTS.md` para A-02 y D-07: sobran tras partir A-02 y crear `DiagnosticsSink`.
- Suplente de P-03a: Kimi, como en la tabla. Codex solo si Kimi no arranca.
- Plazo de corte: tres días, no cinco.
- Suelo: "sin suelo creíble por debajo de 20 semanas", no 16 con condiciones.
- Prueba de humo: commit de `HUMO.md`, no `--allow-empty`.

**Rechazado.** Un dato de evidencia: el acento aparece cuatro veces en el mockup, no tres. La conclusión no cambia.
