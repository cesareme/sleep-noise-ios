# SleepNoise 1.0 · Cuaderno de trabajo de Codex

Fecha: 16-11-2026. Manda `docs/PLAN-DESARROLLO-AGENTES-2026-11-16.md`. Si algo de aquí lo contradice, gana el plan.

Leyenda: [V] comprobado hoy en el Mac o en documentación oficial. [INF] inferencia. [SV] sin verificar: se confirma con `--help` o con la prueba de humo.

Codex lleva 31 paquetes como autor. Es el único escritor del contrato de audio. Todo lo que escribe lo revisa Claude.

- Con brief en §3 (18). Oleada 0: I-02, R-01, R-02. Oleada 1: S-04, S-02, P-01, P-02, P-03b, DS-02. Oleada 2: P-05, A-06, A-01, DS-04, DS-05, A-03a, A-03b, B-01, C-03.
- En la tabla de §4 (13): A-02a, A-02b, A-07, B-03, B-05b, C-04, B-04, A-05, D-01a, D-01b, D-02, D-03, D-04.

## 1. Cómo se usa Codex en este proyecto

### 1.1 Entorno

- Corre en el Mac del dueño, con Xcode 26.6, XcodeGen 2.46.0 y simulador [V]. La nube de Codex no se usa: su imagen es Linux, sin Xcode [INF fuerte].
- Binario: el de ChatGPT.app, 0.167.0-alpha.3.2, fuera del PATH [V]. El de Codex.app es más antiguo y no se usa.
- Un worktree por paquete en `~/wt/sleepnoise/codex-<id>`, creado por Claude. No se usa `--worktree` ni los worktrees de la app [INF: no regeneran el proyecto].
- Simulador fijo: iPhone 17 Pro como autor, iPhone Air como revisor. DerivedData dentro del worktree, en `.build/DerivedData`.
- Sandbox. Comprobado el 16-11-2026 con `codex sandbox -P :workspace`: ese perfil no llega a CoreSimulator (`simctl` da "Unable to deliver request") y deja `.git` en solo lectura, también en un worktree enlazado [V]. `--add-dir` no arregla el simulador: el fallo es de XPC. La sesión real `exec -s workspace-write` está [SV] y se prueba el día 1 con commit incluido (plan §9).
- Modo de trabajo, a elegir por el dueño el día 1. **Opción A:** `-s danger-full-access -C <worktree>`, con las guardas fuera del agente (`main` protegida, `pushurl` bloqueado en el worktree y comparación de `git ls-remote --heads origin` antes y después). **Opción B:** `-s workspace-write`, Codex solo edita, y Claude ejecuta `scripts/verify.sh`, le devuelve el log y hace los commits. Opción elegida: pendiente.
- El dueño marca el repo como de confianza. Que la marca valga para `~/wt/sleepnoise/` está [SV].

### 1.2 Pasar una tarea, paso a paso

Lo hace Claude. Codex no crea ramas ni worktrees por su cuenta.

1. Claude copia el brief de §3 a `docs/briefs/<ID>.md`, rellena `main@<sha>` y lo deja en `main`. Antes de lanzar comprueba que el brief y cada ruta de LEE existen en la base: `git cat-file -e origin/main:<ruta>`.
2. Crea el worktree y lanza la sesión:

```
CODEX="/Applications/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"
ID=r-01; RAMA=codex/r-01-pr-a-base; WT=~/wt/sleepnoise/codex-$ID
cd ~/sleep-noise-ios && git fetch origin
git worktree add "$WT" -b "$RAMA" origin/main
mkdir -p "$WT/.build"
MODO=danger-full-access        # opción A. En la opción B: workspace-write
git config extensions.worktreeConfig true
git -C "$WT" config --worktree remote.origin.pushurl bloqueado://sin-push     # solo opción A
"$CODEX" exec -C "$WT" -s "$MODO" -o "$WT/.build/ENTREGA.md" < "$WT/docs/briefs/R-01.md"
```

Esta es la única orden de lanzamiento. `docs/agents/CLAUDE-ORQUESTADOR.md` §3 usa la misma. Cada lanzamiento lleva tope de reloj: 90 minutos si el paquete es de hasta 2 días, 3 horas el resto (plan §3.7).

`-C`, `-s` y `-o` salen de `codex exec --help` [V]. El brief por stdin está documentado; la forma exacta de la redirección está [SV]. `.build/` queda fuera de Git desde I-01.

3. Codex trabaja, hace commits en la rama y termina. Su mensaje final es la descripción del PR y queda en `.build/ENTREGA.md`. Si el commit falla (opción B, o un bloqueo del sandbox), Codex deja los cambios sin commit y termina con `git status --short`. Claude revisa el diff y hace el commit con el mensaje que Codex propone.
4. Claude repite `scripts/verify.sh` en un worktree de revisión (`git worktree add --detach ~/wt/sleepnoise/claude-rev-<id> <rama>`), hace push, abre el PR con ese texto y revisa.
5. Segunda ronda: `cd "$WT" && "$CODEX" exec resume --last "<hallazgos>"`. `resume` no admite `-C` ni `-s` [V]. `--last` filtra por directorio: vale porque cada paquete tiene worktree propio y el revisor usa otro [SV]. No hay tercera ronda (plan §3.7).

Alternativa interactiva, si el sandbox no deja compilar con `exec`: abrir ChatGPT.app, entrar en Codex, abrir la carpeta del worktree y pegar el brief. Los nombres de los menús están [SV].

Modelo (`-m`): el más capaz del plan contratado para audio, StoreKit y ecosistema. Uno más barato para I-02 y para revisar [SV: plan sin confirmar].

### 1.3 Fichero de instrucciones

- Codex lee `AGENTS.md` desde la raíz de Git hasta el directorio de trabajo y lo corta a 32 KiB [V]. Lo escribe Claude en I-03.
- No se crea `~/.codex/AGENTS.md` (afectaría a otros proyectos del Mac) ni `AGENTS.override.md` ni `.codex/` en el repo.

### 1.4 Codex como revisor

Revisa lo de Kimi, Cursor y Claude (plan §2.3). `exec review` no admite `-C` ni `-s` y corre en solo lectura [V]: no puede ejecutar `scripts/verify.sh`. Por eso lo ejecuta Claude antes.

```
git worktree add --detach ~/wt/sleepnoise/codex-rev-<id> <agente>/<id>-<slug>
cd ~/wt/sleepnoise/codex-rev-<id> && mkdir -p .build
SN_SIM='iPhone Air' scripts/verify.sh > .build/verify.log 2>&1        # lo ejecuta Claude, fuera del sandbox
"$CODEX" exec review --base origin/main -o .build/REVISION.md \
  "Revisa contra docs/briefs/<id>.md y AGENTS.md. El resultado de verify.sh está en .build/verify.log. Hallazgos con fichero y línea. No corrijas."
```

Las opciones salen de `codex exec review --help` [V]. El comportamiento está [SV]. Claude pega `REVISION.md` en el PR y borra el worktree de revisión al dar el veredicto. Codex no corrige. Si un paquete se reasigna a Codex y Codex era su revisor, lo revisa Claude (plan §2.3).

## 2. Reglas propias de Codex

Salen de sus fallos conocidos (sandbox con herramientas de Apple, cuota por ventanas) y de lo que rompió el PR #3.

1. **Nada está hecho sin `SN_SIM='iPhone 17 Pro' scripts/verify.sh` con salida 0 y sin avisos.** Pega las últimas 30 líneas.
2. **Si el sandbox bloquea `xcodebuild`, el simulador o el commit, para.** No te subas los permisos ni cambies de simulador. La salida es la opción A o la B que eligió el dueño (plan §9).
3. **Sin GitHub.** No uses `gh`, no hagas push, no fusiones ni rebases `main`. Los conflictos son de Claude.
4. **Ejecuta `xcodegen generate` después de crear, mover o borrar ficheros.** `SleepNoise.xcodeproj` se genera y no se versiona.
5. **Lista cerrada de ficheros.** Nunca `project.yml`, `Info.plist`, entitlements, `scripts/verify.sh` ni `ci.yml` (salvo I-02). Si hace falta, Claude lo deja en un commit de preparación.
6. **Cadenas.** Desde L-01 no edites `Localizable.xcstrings` a mano. Entrega `strings/<ID>.json` con inglés y español y ejecuta `scripts/strings-merge.sh`. Vocabulario de la reconciliación §3 y de `docs/design/10-GUIA-DE-COPY.md` §0.2. Listas vetadas en 10 §0.4 y §0.5. Sin cifras de precio, sin recuento de texturas, sin afirmaciones médicas.
7. **Hilo de audio.** `EngineCommand` y `RenderState` solo llevan Float, enteros y structs de eso. Sin heap, locks, clases, closures, `Array` ni `String` en el render. Ningún parámetro entra en escalón. Coeficientes en `prepare()`. Los eventos son contadores, no colas. Un campo nuevo toca cuatro sitios: `EngineCommand`, `RenderState`, `SleepAudioEngine.publishCurrent` y el test de desgarro (`SeqlockTearTests`, por bytes desde R-01). Un método público nuevo de `SleepAudioEngine` toca además `AudioEngineControlling.swift` y `FakeAudioEngine.swift`, en el mismo PR.
8. **Un paquete de audio a la vez, en el orden de turnos del plan §3.9.** Da la mediana de `scripts/verify.sh --bench` antes y después. No puede subir más del 10 % sobre `docs/research/bench/BASELINE.md`. La repite Claude con el Mac en reposo. El coste real en un A15 se mide con Instruments en H-03.
9. **App Intents.** Los parámetros de una frase solo pueden ser `AppEnum` o `AppEntity`. `inclusiveRange` es una tupla. Las frases localizadas viven en `AppShortcuts.xcstrings`. Un aviso del procesador de metadatos en el log es un fallo: lo comprueba `scripts/verify.sh`.
10. **Interfaz.** Sale de la sección de la spec y del listado del Anexo A de 04 que cita el brief. Sin candados, sin `AccentColor`, sin fuentes propias ni pesos light, thin o bold, y un solo `#available(iOS 26`. Cada componente trae su sección de galería.
11. **Lógica en reductores o políticas puras, con reloj inyectado.** Lo que no se puede probar sin dispositivo se lista, no se afirma.
12. **Cuota.** Un paquete por sesión. Lee los documentos por secciones con `grep -n` y `sed -n`, nunca enteros. Si la ventana se acaba, para en un estado que compile. Si no puedes hacer commit, deja los cambios sin commit y termina con `git status --short`.
13. **Idioma.** Documentación y notas en español. Cadenas en inglés (fuente) y español. Identificadores y comentarios de código en inglés.
14. **Dos intentos fallidos sobre el mismo error y paras.** `ATASCO.md` en la raíz del worktree, sin commit, con el error literal, lo probado y tu hipótesis. No amplíes el alcance.

## 3. Briefs listos para pegar (oleadas 0, 1 y 2)

Van en español: las specs y el vocabulario cerrado están en español, y traducir Manto, Marea o Madrugada mete errores. Comandos e identificadores, en inglés. Cada bloque es autocontenido. El mensaje final de la sesión es la descripción del PR, con la plantilla de `.github/pull_request_template.md`.

### Oleada 0

```
BRIEF I-02 · CI en GitHub Actions con runner macOS
Revisa Claude · rama codex/i-02-ci · base main (con I-01) · ~/wt/sleepnoise/codex-i-02
OBJETIVO: un workflow que ejecute scripts/verify.sh en cada PR y en main, y un trabajo aparte para el modo
largo. Será el check obligatorio de main y la única prueba de Cursor.
LEE: AGENTS.md si existe · scripts/verify.sh entero · docs/PLAN-DESARROLLO-AGENTES-2026-11-16.md §3.5.
TOCAS: .github/workflows/ci.yml (nuevo). scripts/verify.sh solo para una variable que pida el runner, y lo dices.
PROHIBIDO: project.yml, cualquier .swift, gh, push, ajustes del repo.
PASOS
1. Antes de nada: SN_SIM='iPhone 17 Pro' scripts/verify.sh. Si el sandbox lo bloquea, ATASCO.md y paras.
2. ci.yml: on pull_request y push a main, concurrency con cancel-in-progress. Job verify en macOS, timeout
   30 min: lista los Xcode y simuladores del runner (sus versiones no están comprobadas), elige con
   xcode-select y SN_SIM, instala xcodegen, ejecuta scripts/verify.sh y sube el xcresult con if: always().
3. Job largo: solo workflow_dispatch y schedule diario, con el modo largo del script. Sin matrices.
4. No haces push. Claude sube la rama y te deja los logs de las ejecuciones en .build/ci-logs/. Caso de
   control: Claude crea claude/ci-control-pr3 desde origin/cursor/calm-launch-features-015c, fusiona en
   ella la rama de I-02 (trae ci.yml y scripts/verify.sh) y abre un PR en borrador contra main, con
   permiso del dueño. Ese PR debe salir en rojo. Se cierra sin fusionar, antes de fusionar R-01.
ACEPTACIÓN
- SN_SIM='iPhone 17 Pro' scripts/verify.sh  -> 0
- ruby -ryaml -e 'YAML.load_file(".github/workflows/ci.yml")'  -> sin error
- Tras el push de Claude: verde en main, rojo en el PR de control con el error de metadatos de App Intents
  del PR #3, xcresult descargable. El check obligatorio lo activa el dueño.
ENTREGA: commits sin push. Mensaje final = PR "I-02: CI en macOS": Xcode y simulador elegidos, 30 últimas
líneas de verify.sh y lo que no has podido comprobar sin runner.
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF R-01 · PR-A base: motor, once texturas, modelo e intents con los cinco arreglos
Revisa Claude · rama codex/r-01-pr-a-base · base main (con I-01 e I-02) · ~/wt/sleepnoise/codex-r-01
OBJETIVO: llevar a main lo aprovechable del PR #3 (motor, modelo, tests, intents) sin su interfaz. La lista
de main enseña las once texturas sin diseño nuevo.
LEE: AGENTS.md · docs/REVIEW-PR3-2026-11-16.md líneas 22-34 (bloqueantes y mayores) ·
docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md §5 (509-531).
TOCAS: SleepNoise/Audio/DSP (texturas nuevas, BurstVoice, RenderState, SoundGains), Model/SoundID.swift,
Model/SoundPreset.swift, Model/AccessPolicy.swift, Features/Bedtime/BedtimeScreenPolicy.swift tal cual.
BedtimeView.swift adaptado: sustituye cada DesignTokens.* por un valor literal privado dentro del propio
fichero (negro puro, tinta Palette.text, espaciados 8, 16, 24 y 32, fuente del sistema .largeTitle con peso
regular). No crees DesignTokens.swift ni toques Theme.swift. B-03 rehace la vista con los tokens de DS-01.
Features/Mixer/MixerModel.swift, MixerView.swift y SoundRowView.swift (solo once filas y una entrada simple
a Noche), App/AppRoot.swift (la línea del puente), Intents/SleepIntents.swift,
Resources/AppShortcuts.xcstrings (nuevo), Localizable.xcstrings (solo claves de texturas, presets e intents),
SleepNoiseTests/DSPGeneratorTests.swift, SeqlockTearTests.swift (nuevo), PolicyTests.swift, README.md.
PROHIBIDO: MixSheet, PresetStrip, SoundTileView, DesignTokens, Theme, colorsets, Info.plist, project.yml,
PaywallView, BreathingCard, SleepTimerView. No cambies la matriz gratis/Pro que trae el PR (es P-03b) ni
el crack del trueno (es A-02b).
PASOS
1. git checkout origin/cursor/calm-launch-features-015c -- SleepNoise/Audio SleepNoise/Model \
   SleepNoise/Intents SleepNoise/Features/Bedtime SleepNoiseTests/DSPGeneratorTests.swift \
   SleepNoiseTests/PolicyTests.swift   (no la carpeta de tests entera: F-02 parte BreathingTests.swift)
   El resto (MixerModel, AppRoot, catálogo) a mano, desde git diff origin/main <esa rama> -- <fichero>.
2. Arreglo 1: inclusiveRange como tupla (1, 360). Arreglo 2: quita la frase que interpola un Int, su clave
   muerta y la línea del README.
3. Arreglo 3: AppShortcuts.xcstrings con las frases en inglés y español. Si no entra en el bundle sin
   project.yml, pídelo.
4. Arreglo 4: StopPlaybackIntent con openAppWhenRun = false, y sin "Stopped" si no sonaba nada.
5. Arreglo 5: sube arroyo (x2 aprox.) y hoguera (x2,5 aprox.) y limita el viento para que no toque el techo.
   Test nuevo ponderado A: arroyo y hoguera a menos de 4 dB del resto a ganancia 1,0.
6. Mueve el test de desgarro a SleepNoiseTests/SeqlockTearTests.swift y hazlo por bytes: el escritor publica
   comandos con todos los bytes iguales a un patrón k (memset sobre una copia) y el lector comprueba con
   withUnsafeBytes que todos los bytes coinciden. ParameterMailbox.publish sobrescribe generation:
   exclúyelo del patrón por offset. Añade
   XCTAssertEqual(MemoryLayout<EngineCommand>.size, MemoryLayout<EngineCommand>.stride).
   Así todo campo nuevo queda cubierto sin tocar el test.
ACEPTACIÓN
- SN_SIM='iPhone 17 Pro' scripts/verify.sh  -> 0, sin avisos, 54 tests más el de nivel
- git diff --name-only origin/main | grep -cE 'MixSheet|PresetStrip|SoundTileView|DesignTokens'  -> 0
- grep -c DesignTokens SleepNoise/Features/Bedtime/BedtimeView.swift  -> 0
- El log no tiene errores ni avisos del procesador de metadatos de App Intents: lo comprueba
  scripts/verify.sh, que también exige es.lproj/AppShortcuts.strings dentro de SleepNoise.app
- test -e SleepNoiseTests/SeqlockTearTests.swift, y testConcurrentReadsNeverTear ya no está en
  DSPGeneratorTests.swift
ENTREGA: commits sin push. Mensaje final = PR "R-01: PR-A base": los cinco arreglos con su commit, dBFS(A)
de las once texturas, 30 últimas líneas de verify.sh. No verificado: escucha y atajo por voz (H-02a).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF R-02 · PR-A segunda parte: modelo de Noche, hash del trueno, tests y catálogo
Revisa Claude · rama codex/r-02-pr-a-noche · base main (con R-01) · ~/wt/sleepnoise/codex-r-02
OBJETIVO: cerrar los menores de la revisión del PR #3 en modelo y audio. Noche deja de crear un
temporizador y el trueno deja de repetirse. Se fusiona solo tras la escucha del dueño (H-02a).
LEE: AGENTS.md · docs/REVIEW-PR3-2026-11-16.md líneas 36-46 (menores) · fichas C46, C47 y C23
(grep -n '^### C46' docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md) · FUNCIONES §5 puntos 4, 5, 7 y 8.
TOCAS: Features/Bedtime/BedtimeScreenPolicy.swift, BedtimeView.swift, Features/Mixer/MixerModel.swift,
Audio/DSP/ThunderTexture.swift (solo el generador de huecos), Resources/Localizable.xcstrings,
Resources/SleepNoise.storekit, SleepNoiseTests/TextureLongRenderTests.swift (nuevo), PolicyTests.swift,
README.md, docs/ROADMAP.md.
PROHIBIDO: EngineCommand, RenderState, SoundGains, DSPGeneratorTests.swift (es de R-01, A-02a, A-02b y
A-01), MixerView (congelado hasta A-03a), project.yml. Vas en paralelo con P-01: no compartís ficheros.
PASOS
1. Noche: no fuerza ni guarda un temporizador. Distingue "nunca elegí" de "Apagado". Tiene estado de
   silencio. La hoja de compra no puede presentarse encima.
2. La política de pantalla sale de una tabla: ajuste por estado de batería. Sustituye el test tautológico.
3. ThunderTexture.unit(): hash real en lugar de la secuencia afín.
4. Tests de texturas con render de 30 s, en TextureLongRenderTests.swift, para que detecten una envolvente
   atascada.
5. Catálogo (en y es, guía 10 §0.4 y §0.5): corrige el español que señala la revisión. Descripción del producto de 45 caracteres o menos.
ACEPTACIÓN (tests con nombre)
- Entrar en Noche sin temporizador no crea ni guarda ninguno. Un fallo de play no deja estado guardado.
- Tabla completa ajuste x batería para la pantalla encendida.
- Render de 30 s detecta una envolvente de trueno atascada. Huecos sin repetición en 200 eventos.
- SN_SIM='iPhone 17 Pro' scripts/verify.sh  -> 0
ENTREGA: commits sin push. Mensaje final = PR "R-02: PR-A, Noche y trueno": criterio -> test, 30 últimas
líneas de verify.sh. No verificado: Noche con Auto-Lock real y escucha (H-02a).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

### Oleada 1

```
BRIEF S-04 · Spike I0-7: timbre en el bus maestro (no se fusiona)
Revisa Claude · rama codex/s-04-spike-i0-7 · base main (con R-01) · ~/wt/sleepnoise/codex-s-04
OBJETIVO: saber si un tilt (shelving biquad) y un pasa-bajos (SVF) sobre la suma caben en el render sin
clics y con coste despreciable. El veredicto decide si la fila Timbre entra en 1.0 (A-05).
LEE: AGENTS.md · reconciliación §1 regla 5 y fichas C29, C31 · FUNCIONES §7 punto 2 (línea 601).
TOCAS: Audio/DSP/Filters.swift, RenderState.swift, SleepNoiseTests/MasterBusSpikeTests.swift (nuevo),
docs/research/spikes/I0-7.md (nuevo). PROHIBIDO: EngineCommand, mailbox, interfaz, project.yml.
PASOS: 1. Filtros como structs puros con parámetros Float suavizados. 2. Tests offline. 3. Cinco renders de
30 s en .build/renders/i0-7/ (sin commit), uno por posición. 4. Nota en español: método, medidas, veredicto.
ACEPTACIÓN: sin NaN a 22,05, 44,1, 48 y 96 kHz · barrido del parámetro sin discontinuidad mayor que el
umbral que fijes y justifiques · scripts/verify.sh --bench: la mediana no sube más del 10 % sobre
docs/research/bench/BASELINE.md ·
SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0 · la nota dice "pasa" o "no pasa".
ENTREGA: commits sin push. Mensaje final: veredicto, cifras, rutas de los cinco WAV. No verificado: escucha (H-02b).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF S-02 · Spikes I0-3 e I0-6: intent sobre Live Activity y contraste bajo rojo (no se fusiona)
Revisa Claude · rama codex/s-02-spike-i0-3-6 · base: commit de preparación de Claude (target de
extensión mínimo y NSSupportsLiveActivities), que vive solo en esta rama y nunca llega a main ·
~/wt/sleepnoise/codex-s-02
OBJETIVO: responder dos preguntas. ¿Funciona un AudioPlaybackIntent desde una actividad ya terminada, y cómo
se reemite pasado el límite de 8 h? ¿Mide 3:1 o más el texto bajo el tinte rojo de StandBy?
LEE: AGENTS.md · docs/design/09-ECOSISTEMA.md §2.19 a §2.21, §3.1, §4.2 y §4.5 · fichas C25, C50, C62.
TOCAS: código de la extensión y de la app en esta rama, docs/research/spikes/I0-3.md e I0-6.md (nuevos),
scripts/contrast-from-photo.swift (nuevo). PROHIBIDO: project.yml e Info.plist (pídelos), push.
PASOS: 1. Live Activity mínima con un botón que lanza un intent de audio. 2. Script que lee una foto y dos
rectángulos y da el contraste WCAG. 3. Notas en español con el procedimiento exacto para el dueño y las
casillas de resultado en dispositivo vacías.
ACEPTACIÓN: SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0 · la actividad arranca en simulador (captura con
xcrun simctl io) · el script devuelve 21:1 con una imagen sintética blanco sobre negro · si el contraste
sale por debajo de 3,5, la nota I0-6 deja escrito el plan B del token texto.
ENTREGA: commits sin push. Mensaje final: qué responde el simulador y qué queda a H-02b.
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF P-01 · Bus maestro con master, rampas y fundido de cuenta entera
Revisa Claude · rama codex/p-01-bus-maestro · base main (con R-01 y la nota de S-04; no espera a R-02) · ~/wt/sleepnoise/codex-p-01
OBJETIVO: fijar el contrato de audio ampliado. Lo usarán el temporizador, Noche, la Marea y las rutas.
LEE: AGENTS.md (hilo de audio) · FUNCIONES §7 puntos 1 y 2 (599-601) · fichas C31, C49, C51 ·
SleepAudioEngine.swift 97-115 y RenderState.swift 136-141 y 253.
TOCAS: Audio/DSP/EngineCommand.swift, RenderState.swift, FadeCurve.swift, Audio/SleepAudioEngine.swift,
SleepNoiseTests/EngineCommandEnvelopeTests.swift, SeqlockTearTests.swift y MasterBusTests.swift (nuevo).
PROHIBIDO: DSPGeneratorTests.swift (no se toca), MixerModel (no cablees master a la interfaz), AtomicBridge,
SoundGains, tilt y pasa-bajos (A-05). El protocolo AudioEngineControlling y el motor de pega nacen después,
en F-01, y ya traen tu setMaster: deja su firma exacta en el mensaje final.
PASOS
1. master: nivel de sesión con rampa en EngineCommand y setMaster(level:ramp:) en el motor. No persiste y
   no toca el volumen del sistema. Evento modelado como contador, como envelopeGeneration.
2. Fundido largo con contador entero de muestras, no con paso Float acumulado. prepare(sampleRate:)
   reescala las muestras restantes de toda rampa en curso.
3. Selector de curva POD: entrada de 0,8 s con easeOut. La salida sigue con la curva actual.
ACEPTACIÓN (tests offline)
- Un fundido de 15 min termina en 0 exacto en la muestra prevista. El arranque sigue easeOut de 0,8 s.
- Una rampa de master publicada tras start no pisa el fundido de entrada.
- El test de desgarro por bytes (SeqlockTearTests) sigue en verde sin tocar su lógica. EngineCommand sigue
  siendo POD (test con _isPOD).
- A mitad de un fundido de 15 min y de una rampa de master, prepare(sampleRate:) de 48 000 a 44 100
  conserva la fracción recorrida y la duración restante en segundos, con error menor de 10 ms. El valor de
  la envolvente no salta.
- Sin NaN a las cuatro frecuencias. scripts/verify.sh --bench: la mediana no sube más del 10 % sobre
  docs/research/bench/BASELINE.md.
- SN_SIM='iPhone 17 Pro' scripts/verify.sh  -> 0
ENTREGA: commits sin push. Mensaje final = PR "P-01: bus maestro": la interfaz pública nueva, coste antes
y después, criterio -> test, 30 últimas líneas de verify.sh. No verificado: clics al oído (dueño).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF P-02 · Temporizador sin tick de 4 Hz
Revisa Claude · rama codex/p-02-timer-sin-tick · base main (con R-02 y P-01) · ~/wt/sleepnoise/codex-p-02
OBJETIVO: que con la pantalla bloqueada no haya actividad periódica fuera del motor. El plan pasa a ser una
lista de fases con fecha y un temporizador único por frontera.
LEE: AGENTS.md · FUNCIONES §7 punto 1 (599) · docs/design/04-SISTEMA-FUNDAMENTOS.md Anexo B (1948-1992).
TOCAS: Features/Timer/SleepTimerController.swift, SleepTimerView.swift, TimeFormat.swift,
SleepNoiseTests/TimerFormatTests.swift (nuevo: mueves ahí la clase TimerFormatTests y no tocas nada más de
PolicyTests.swift), SleepTimerTests.swift (nuevo). Tu turno en SleepTimerView va antes que el de P-03b. En MixerView.swift solo
TimerButtonLabel, si no hay otra forma, y lo declaras. PROHIBIDO: MixerModel, audio, project.yml.
PASOS: 1. Reloj y planificador inyectables (hoy Date() en 41, 52 y 77, Timer en 59). 2. Fases con fecha, un
disparo por frontera, que publican rampas de P-01. 3. La vista pinta el tiempo con un intervalo del sistema
(Text con timerInterval o estilo timer), sin refresco propio.
ACEPTACIÓN
- grep -rn 'repeats: true' SleepNoise/Features/Timer | wc -l  -> 0
- Tests con reloj inyectado, que da dos lecturas: hora de pared y tiempo monótono. 45 min acaban en fundido
  y parada. Pausa y reanudación conservan la hora de fin. Hasta dormirme cuenta en monótono: adelantar o
  atrasar la hora de pared 2 h no mueve el corte. La hora de pared solo se usa para pintar la hora de fin.
  Manto por hora fija es de B-01 y usa hora de pared.
- SN_SIM='iPhone 17 Pro' scripts/verify.sh  -> 0
ENTREGA: commits sin push. Mensaje final = PR "P-02: temporizador sin tick": criterio -> test, 30 últimas
líneas de verify.sh. No verificado: 0 actividad periódica en Instruments (H-03).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF P-03b · Política libre y Pro final, prueba en Keychain y startTrial
Revisa Claude · rama codex/p-03b-politica-keychain · base main (con R-02, F-01, P-03a y P-02) · ~/wt/sleepnoise/codex-p-03b
OBJETIVO: la matriz gratis/Pro cerrada, en código, y una prueba que solo empieza cuando la persona lo pide.
LEE: AGENTS.md · reconciliación §1 regla 3, §4 (1033-1066) y fichas C03, C04, C07 · FUNCIONES §7 StoreKit (614).
TOCAS: Model/AccessPolicy.swift, TrialClock.swift, KeychainStore.swift (nuevo), StoreKit/PurchaseManager.swift,
el fichero base de MixerModel (init) y sus extensiones de reproducción y de temporizador, solo las líneas
que llaman a timerIsIncluded o a startTrialIfNeeded, Features/Timer/SleepTimerView.swift (tras P-02),
SleepNoiseTests/PolicyTests.swift, el fichero de TrialClockTests, docs/ROADMAP.md.
PROHIBIDO: NightWindow, SaleGate y TipGate (son de P-03a: se usan, no se cambian), PaywallView, entitlements.
PASOS
1. AccessPolicy: viento libre, freeSavedMixLimit 3, freeTimerMinutes desaparece (temporizador libre entero).
2. TrialClock recibe un almacén por protocolo. Implementación en Keychain, sin sincronización, legible con el
   iPhone bloqueado. Doble de memoria para los tests.
3. startTrialIfNeeded() sale de play(). Nace startTrial(), que llamará la hoja Pro (C-04). Hasta entonces
   nada en la interfaz inicia la prueba: es lo esperado.
ACEPTACIÓN
- Tests: viento sin acceso. Duraciones de 1 a 360 sin acceso. La tercera mezcla se guarda y la cuarta pide
  Pro. play no inicia la prueba y startTrial sí. El inicio sobrevive a borrar UserDefaults.
- grep -rn freeTimerMinutes SleepNoise SleepNoiseTests | wc -l  -> 0
- grep -rn startTrialIfNeeded SleepNoise/Features/Mixer | wc -l  -> 0
- SN_SIM='iPhone 17 Pro' scripts/verify.sh  -> 0
ENTREGA: commits sin push. Mensaje final = PR "P-03b: política final y Keychain": tests que cambian, 30
últimas líneas de verify.sh. No verificado: la prueba sobrevive a reinstalar en un iPhone (H-04).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF DS-02 · PlayDisc, HairlineAction, sistema con estilo y galería DEBUG
Revisa Claude · rama codex/ds-02-disco-galeria · base main (con DS-01) · ~/wt/sleepnoise/codex-ds-02
OBJETIVO: las piezas de sistema que usan todas las pantallas, y la galería donde se revisa cada estado.
LEE: AGENTS.md · docs/design/04-SISTEMA-FUNDAMENTOS.md §2.4, §2.6 a §2.8, §3.4, §3.6, §3.7 y Anexo A5 a A7
(1163-1319) y A12 (1839-1947) · docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md §4 (242-309).
TOCAS (nuevos, en SleepNoise/Design): PlayDisc.swift, PrimaryActionStyle.swift, HairlineAction.swift,
SystemStyled.swift, SystemGallery.swift. SleepNoiseUITests/GalleryUITests.swift (nuevo). En
App/SleepNoiseApp.swift solo un gancho #if DEBUG que abre la galería con un argumento de lanzamiento.
PROHIBIDO: Ink, TypeStep y Grid (DS-01: se usan), Theme.swift, MixerView, catálogo de cadenas a mano.
NightWindow, SaleGate y TipGate: son de P-03a y viven en Model/NightWindow.swift. No los declares en
SystemStyled.swift aunque el listado A12 (líneas 1927-1943) los traiga. De A12 solo escribes hasta
LineTipStyle.
PASOS: 1. Sigue los listados del Anexo A, no inventes variantes. Si P-03a ya está en main, añade en
SystemStyled.swift una extension SaleGate con allows(now:phase:scene:) que delega en la versión con Bool.
Si no está, no la escribas: queda para A-03a. 2. El único #available(iOS 26 vive en
PrimaryActionStyle. 3. La galería enseña cada componente en todos sus estados, fases y tramos de Dynamic
Type, con identificadores de accesibilidad estables.
ACEPTACIÓN
- GalleryUITests abre la galería y encuentra cada estado. Marcos: 44 pt o más en acciones, 64 en el Disco.
- grep -rn '#available(iOS 26' SleepNoise | wc -l  -> 1
- grep -rnE '"lock|AccentColor' SleepNoise/Design | wc -l  -> 0
- grep -rnE 'enum (NightWindow|SaleGate|TipGate)' SleepNoise/Design | wc -l  -> 0
- SN_SIM='iPhone 17 Pro' scripts/verify.sh  -> 0
ENTREGA: commits sin push. Mensaje final = PR "DS-02: Disco y galería": capturas de la galería en tamaño
normal y en AX5, 30 últimas líneas de verify.sh. No verificado: a oscuras en iPhone (H-05).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

### Oleada 2

```
BRIEF P-05 · Canal inverso del render al hilo principal
Revisa Claude · rama codex/p-05-canal-inverso · base main (con P-01 y DS-03) · ~/wt/sleepnoise/codex-p-05
OBJETIVO: que el Horizonte se mueva con el sonido real. El render publica unos pocos floats sin asignar ni
bloquear, y el hilo principal los lee a 30 Hz como máximo y solo con la pantalla encendida.
LEE: AGENTS.md (hilo de audio) · FUNCIONES §7 punto 3 (602) · 04 §2.1 y Anexo A4 (1118-1162) · C53, C63.
TOCAS: Audio/DSP/AtomicBridge.c y .h, RenderState.swift, MeterTap.swift (nuevo), Audio/SleepAudioEngine.swift,
Design/SoundMeter.swift, SleepNoiseTests/MeterTapTests.swift (nuevo). Si añades un método público al motor:
Audio/AudioEngineControlling.swift y SleepNoiseTests/FakeAudioEngine.swift, en este mismo PR.
PROHIBIDO: EngineCommand, mailbox, vistas.
PASOS: 1. Atómicos nuevos en C para RMS maestro, RMS por capa, fase de la Marea y fase del plan, escritos
una vez por buffer. 2. MeterTap los lee. 3. SoundMeter cambia el valor provisional por el real, sin Timer.
ACEPTACIÓN: RMS publicado a menos de 0,5 dB del calculado offline · lectura concurrente 5 s sin valores fuera
de rango · en silencio cae a 0 en menos de 1 s · scripts/verify.sh --bench: la mediana no sube más del
10 % sobre docs/research/bench/BASELINE.md ·
grep -nwE 'DispatchQueue|NSLock|os_unfair_lock|malloc' <ficheros DSP tocados> -> 0 ·
SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "P-05: canal inverso": coste antes y después, criterio -> test,
30 últimas líneas de verify.sh. No verificado: el Horizonte en iPhone real (H-05).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF A-06 · Marea 1.0 en el motor: ritual Descenso
Revisa Claude · rama codex/a-06-descenso · base main (con P-01; no ocupa turno del contrato y puede ir en paralelo con P-05) · ~/wt/sleepnoise/codex-a-06
OBJETIVO: el ritual baja de 12 a 6 por minuto, hace meseta y se disuelve. Deja lista la variante fija de 8
por minuto que usará Madrugada.
LEE: AGENTS.md · docs/design/06-MAREA.md §4.2 y §4.5 (248-315) y §5a · C24, C34, C05 · FUNCIONES §7 "Motor
de la Marea" (606).
TOCAS: Features/Breathing/BreathingGuideController.swift, Audio/DSP/Breath.swift (solo ayudantes puros de la
curva), BreathingRenderTests.swift y BreathingGuideControllerTests.swift. PROHIBIDO: EngineCommand,
RenderState, SleepAudioEngine. Cero campos nuevos. También BreathingCard y MixerModel.
PASOS: 1. El ritual se publica como una secuencia de setBreathing con fecha, un paso por frontera, con
cambios de ritmo de 1 por minuto como mucho por publicación. Sin Timer repetitivo. El ritmo de partida es
un parámetro. El render ya conserva la fracción del ciclo al cambiar rate y ya rampa el peso con
dissolveSeconds.
2. Disolución en el último 20 %. 3. Apagado manual que disuelve en 30 s. 4. Variante fija para B-04.
ACEPTACIÓN (tests offline, reloj inyectado): curva continua · pico a valle de 6 dB o menos · el cambio de
ritmo conserva la fase sin clics · disolución en el último 20 % · apagado manual de 30 s · test que fija
MemoryLayout<BreathParameters>.size al valor de main ·
git diff --name-only origin/main | grep -cE 'EngineCommand|RenderState|SleepAudioEngine' -> 0 ·
render offline de 15 min: ningún salto entre muestras mayor que el del test
testRateChangeKeepsTheCycleFraction · SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "A-06: Descenso": criterio -> test, render de 15 min en
.build/renders/, 30 últimas líneas de verify.sh. No verificado: cómo se siente al oído (dueño).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF A-01 · Loudness entre texturas y compensador de suma
Revisa Claude · rama codex/a-01-loudness · base main (con A-02b; turno de audio tras A-02b) · ~/wt/sleepnoise/codex-a-01
OBJETIVO: que todas las texturas midan lo mismo a ganancia 1,0 y que seis capas a la vez no saturen.
LEE: AGENTS.md · docs/REVIEW-PR3-2026-11-16.md mayor 5 (línea 33, con las medidas) · FUNCIONES §2.1 bloque
A (grep -n 'Loudness') · RenderState.swift 7-54 y Clip.swift.
TOCAS: Audio/DSP/SoundGains.swift, RenderState.swift, Clip.swift, los trims de los ficheros de textura,
SleepNoiseTests/LoudnessTests.swift (nuevo), Spectrum.swift. PROHIBIDO: EngineCommand, el carácter de las
texturas (lo cerraron A-02a y A-02b), SoundID. Tus trims son los finales: el PRNG ya no cambia.
PASOS: 1. Medidor ponderado A en Spectrum.swift. 2. Trims por textura. 3. Compensador sobre la suma de capas
activas, POD y suavizado, sin escalones al encender o apagar una capa.
ACEPTACIÓN: cada textura a 1,0 mide -20 dBFS(A) con 1 dB de tolerancia a 44,1 y 48 kHz · seis capas a 1,0
dan pico menor de 0,98 sin tocar el recortador · el test de autocorrelación (T-01) sigue en verde en el
modo largo · SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "A-01: loudness": tabla dBFS(A) antes y después por textura,
30 últimas líneas de verify.sh. No verificado: igualdad al oído con auriculares (dueño).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF DS-04 · LevelRule: la fila es el control
Revisa Claude · rama codex/ds-04-levelrule · base main (con DS-01 y la nota de S-01) · ~/wt/sleepnoise/codex-ds-04
OBJETIVO: la fila de nivel con arrastre relativo, que no cambia nada cuando la persona hace scroll.
LEE: AGENTS.md · 04 §2.2, §3.2, §5b, §5c y Anexo A9 (1411-1568) · docs/design/05-PAGINA-Y-CAPAS.md §2.6
(260-307) · docs/research/spikes/I0-2.md · C06, C08, C21, C23, C52.
TOCAS (nuevos): Design/LevelRule.swift (con su sección de galería), SleepNoiseTests/LevelRuleTests.swift,
SleepNoiseUITests/LevelRuleUITests.swift. PROHIBIDO: SystemGallery.swift (la línea de registro es de
Claude), MixerModel, cadenas a mano.
PASOS: 1. Reductor puro (estado, evento) -> estado. Umbrales en un solo sitio: 8 pt, 30 grados y lo que
fije I0-2. 2. Pulsación larga que cambia a Slider del sistema. 3. Fila Pro sin candado: palabra pro y nivel
conservado. De noche el toque no hace nada (la puerta entra por closure). 4. Acciones de accesibilidad del 5 %.
ACEPTACIÓN: tests del reductor: arrastre por encima del ángulo no cambia el valor · 333 pt recorren el rango
entero · el nivel 0 oculta el valor · la fila Pro ignora el arrastre y conserva el nivel. Test de interfaz:
10 scrolls diagonales con 0 cambios. SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "DS-04: LevelRule": umbrales usados, criterio -> test, 30
últimas líneas de verify.sh. No verificado: VoiceOver y Switch Control reales (H-02b, H-05).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF DS-05 · TideLine y FullScreenControl
Revisa Claude · rama codex/ds-05-tideline-fullscreen · base main (con DS-03) · ~/wt/sleepnoise/codex-ds-05
OBJETIVO: la línea de agua, que en la hoja también es el control del ritmo, y la pantalla como botón de
Noche y Madrugada.
LEE: AGENTS.md · 04 §2.3, §2.5, §3.3, §3.5 y Anexos A10 y A11 (1569-1838) · C47, C51, C59.
TOCAS (nuevos): Design/TideLine.swift, Design/FullScreenControl.swift (cada uno con su sección de galería),
SleepNoiseTests/TideLineTests.swift, FullScreenControlTests.swift. PROHIBIDO: SystemGallery.swift, audio
(la curva de respiración se lee, no se cambia), BedtimeView.
PASOS: 1. Gestos resueltos en reductores puros con reloj inyectado. 2. Toque con guarda de 300 ms, arrastre
vertical como nivel maestro (solo emite el valor), pulsación larga para volver, atenuación a los 60 s.
ACEPTACIÓN (tests): un toque dentro de los 300 ms tras desbloquear se ignora · una pulsación de 0,6 s con
más de 10 pt de movimiento no vuelve · un deslizamiento horizontal cuenta como toque · el arrastre de la
línea da enteros de 4 a 8 por minuto · con Reduce Motion la línea queda fija · la galería enseña las cuatro
fases con una sola tinta. SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "DS-05: TideLine y FullScreenControl": criterio -> test,
capturas de galería, 30 últimas líneas de verify.sh. No verificado: gestos a oscuras en iPhone (H-05).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF A-03a · Página principal, enum de rutas y hojas vacías
Revisa Claude · rama codex/a-03a-pagina-rutas · base main (con DS-02, DS-03, DS-04, P-03b, F-01, X-01,
L-01) · ~/wt/sleepnoise/codex-a-03a
OBJETIVO: sustituir la pantalla de main por la página de la dirección y dejar un fichero por hoja, para
que los paquetes siguientes no choquen.
LEE: AGENTS.md · 05 §2.0 a §2.4, §2.11 a §2.13, §3, §4 y §5 (ya con su sección 12) · 03 §5 filas 1, 2, 4 y
16 · C19, C20, C33, C38 · docs/design/10-GUIA-DE-COPY.md §2.1.
TOCAS: Features/Page/PageView.swift y Route.swift (nuevos), una vista vacía por hoja nueva en su fichero
(Layers/LayersSheet, Breathing/TideSheet, Night/NightView, Settings/SettingsView), el fichero de extensión
de MixerModel de reproducción, App/AppRoot.swift, strings/A-03a.json (en y es),
SleepNoiseTests/PageModelTests.swift. MixerView.swift y SoundRowView.swift dejan de ser la raíz pero no se
borran: los retira A-03b. PROHIBIDO: audio, PurchaseManager, project.yml, catálogo a mano, tope de seis
capas y tests de interfaz (A-03b).
PASOS: 1. Página: nombre de la mezcla, Horizonte, hasta tres filas que suenan con "y N más", línea de
estado, barra con Mezclas, Disco y Noche, pie. 2. Route: un enum único para hojas y pantallas empujadas.
3. La app abre en reposo y no activa la sesión de audio al lanzar. 4. Si DS-02 no dejó la sobrecarga de
SaleGate con NightPhase y ScenePhase, la añades aquí como extension, sin redeclarar el tipo.
ACEPTACIÓN: tests de modelo: como mucho tres filas y el resto como contador · el motor de pega
(FakeAudioEngine) no arranca al iniciar · la raíz de AppRoot es PageView ·
SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "A-03a: página principal": capturas en reposo, sonando y AX5,
criterio -> test, 30 últimas líneas de verify.sh. No verificado: la página a oscuras (H-05).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF A-03b · Tope de seis capas, retirada de MixerView y tests de interfaz
Revisa Claude · rama codex/a-03b-tope-retirada · base main (con A-03a) · ~/wt/sleepnoise/codex-a-03b
OBJETIVO: cerrar la sustitución de la pantalla. El modelo limita a seis capas a la vez, los ficheros de la
pantalla antigua desaparecen y la página queda cubierta por tests de interfaz.
LEE: AGENTS.md · 05 §2.4 y §3 (ya con su sección 12) · C19, C20, C33 · docs/design/10-GUIA-DE-COPY.md §2.1.
TOCAS: el fichero de extensión de MixerModel de niveles, SleepNoiseTests/PageModelTests.swift,
SleepNoiseUITests/PageUITests.swift (nuevo), strings/A-03b.json si hace falta. Borras
Features/Mixer/MixerView.swift y SoundRowView.swift. PROHIBIDO: PageView.swift y Route.swift (tras A-03a
son de Claude), audio, AppRoot, project.yml, catálogo a mano.
PASOS: 1. Modelo: tope de seis capas a la vez. 2. Borra los dos ficheros y lo que solo ellos usaban.
3. Tests de interfaz de la página.
ACEPTACIÓN: test de modelo: la séptima capa se rechaza con el estado "Seis a la vez". Test de interfaz:
abre con "Esta noche", Play suena, ninguna hoja al lanzar, siguen los once identificadores de
accesibilidad de main. test ! -e SleepNoise/Features/Mixer/MixerView.swift ·
SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "A-03b: tope de seis y retirada": criterio -> test, 30
últimas líneas de verify.sh. No verificado: la página a oscuras (H-05).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF B-01 · Temporizador de dos modos en el modelo
Revisa Claude · rama codex/b-01-temporizador-modelo · base main (con P-01, P-02, P-03b y X-02) · ~/wt/sleepnoise/codex-b-01
OBJETIVO: Hasta dormirme (minutos, hasta 360) y Manto (hora fija, con bajada de 6 dB a los 45 min), con el
fin expresado como hora. Sin interfaz nueva: la hoja es B-02.
LEE: AGENTS.md · docs/design/07-TEMPORIZADOR-NOCHE-MADRUGADA.md §2.1, §3.1 y §4.2 (ya con su sección 12) ·
C03, C11, C22, C31 · FUNCIONES §7 punto 1 (599).
TOCAS: Features/Timer/SleepTimerController.swift, TimeFormat.swift, el fichero de extensión de MixerModel
del temporizador, SleepNoiseTests/SleepTimerTests.swift. PROHIBIDO: SleepTimerView, audio, AccessPolicy.
PASOS: 1. Dos modos como fases con fecha (P-02) que publican rampas (P-01). La bajada de 6 dB se publica
con setMaster a través del protocolo AudioEngineControlling, que lo trae desde F-01. Los tests usan
FakeAudioEngine. Manto por hora fija usa hora de pared. Hasta dormirme, tiempo monótono. 2. Más quince solo sobre un
temporizador que ya existe. 3. Fundido final de ganancia, de 10 a 15 min, con estado Fundiendo y minutos.
ACEPTACIÓN (reloj inyectado): 45 min con fundido y parada · Manto cruza la medianoche y un cambio de hora ·
la bajada de 6 dB llega al minuto 45 · más quince sin temporizador no crea ninguno · el estado dice los
minutos enteros que faltan · grep -rnE 'MPVolumeView|setVolume' SleepNoise | wc -l -> 0 ·
SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "B-01: temporizador de dos modos": criterio -> test, 30 últimas
líneas de verify.sh. No verificado: una noche real con Manto (H-03).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

```
BRIEF C-03 · Estados de StoreKit, Family Sharing y fichero de tienda
Revisa Claude · rama codex/c-03-storekit-estados · base main (con P-03b y el commit de preparación
de Claude con la tienda de pruebas en project.yml) · ~/wt/sleepnoise/codex-c-03
OBJETIVO: que la compra tenga todos sus estados y que ninguno deje la app sin sonar.
LEE: AGENTS.md · FUNCIONES §7 StoreKit (614) · C02, C12 y reconciliación §4 (1033-1066) ·
docs/design/08-MEZCLAS-PRO-PRUEBA.md §2.3, §3 y §4.5.
TOCAS: StoreKit/PurchaseManager.swift, Resources/SleepNoise.storekit, SleepNoiseTests/PurchaseManagerTests.swift
(nuevo). PROHIBIDO: PaywallView (C-04), TrialClock, project.yml, cualquier cuenta real o de sandbox.
PASOS: 1. Estados: pendiente, cancelada, precio no disponible, pérdida de la propiedad compartida,
revocación. Degradación en el siguiente arranque, nunca en mitad de la noche. 2. Tienda local: Family
Sharing, descripción sin número de texturas, producto oculto del plan B.
ACEPTACIÓN (sesión de StoreKit de pruebas): compra correcta da acceso · pendiente no · cancelada no cambia
nada · un reembolso lo retira en el siguiente arranque · con la tienda caída el precio es nulo y la app
sigue sonando · descripción de 45 caracteres o menos y sin cifras · SN_SIM='iPhone 17 Pro' scripts/verify.sh -> 0
ENTREGA: commits sin push. Mensaje final = PR "C-03: estados de StoreKit": tabla estado -> test, 30 últimas
líneas de verify.sh. No verificado: compra, reembolso y familia en sandbox (H-04).
BLOQUEO: dos intentos fallidos con el mismo error y paras. Escribe ATASCO.md.
```

## 4. Oleadas 3 y 4 y lo añadido en la revisión, una línea por paquete

Su brief se escribe al abrir la oleada, con lo aprendido en las anteriores.

| Id | Ol. | Qué | Depende de | Condición |
|---|---|---|---|---|
| A-02a | 2 | PRNG nuevo: `XorShift32` pasa a xoshiro128** con siembra splitmix32. Seeds y tests espectrales reajustados | R-02, P-05 | Turno de audio tras P-05. Toca todas las texturas y `DSPGeneratorTests.swift`. `--bench` dentro del 10 % |
| A-02b | 2 | Trueno sin crack y hoguera sin la oscilación de 9,4 dB | A-02a | Render de 60 s por textura en `.build/renders/` para la escucha del dueño |
| A-07 | 3 | Hoja Marea, toggle en la página y háptica | A-06, DS-05, A-03a | Puerta háptica probada |
| B-03 | 3 | Noche y página nocturna | DS-05, P-01, B-01, A-03a, X-02 | Ruta crítica. Auto-Lock en H-03 |
| B-05b | 3 | Sesión de audio, interrupciones y rutas | B-05a, P-01, B-01 | Sin turno de audio abierto. Real en H-03. Deja en `SleepNoise/Audio/DiagnosticsSink.swift` un protocolo `DiagnosticsSink` con `record(_ event: DiagnosticEvent)`, llamado solo desde el hilo principal en inicio, parada, interrupción, cambio de ruta y reinicio del grafo. Implementación por defecto vacía. Nunca se llama desde el render. Toca además `AudioEngineControlling.swift` y `FakeAudioEngine.swift` |
| C-04 | 3 | Hoja Pro, prueba de 7 noches y degradación | C-03, DS-02, A-04, L-01 | Tienda de pruebas. Compra real en H-04 |
| B-04 | 4 | Madrugada | B-03, A-06 | Ruta crítica. Mezcla y disco intactos |
| A-05 | 4 | Fila Timbre sobre el bus | P-01, S-04, H-02b, A-04, A-01 | Solo si H-02b dice que pasa. Si no, a 1.1. No se recorta por capacidad. Toca además `AudioEngineControlling.swift` y `FakeAudioEngine.swift` |
| D-01a | 4 | Intents: los siete con frase y el catálogo `AppShortcuts` | R-02, C-01, B-01, B-04, X-03 | Metadatos limpios, comprobado por `verify.sh`. Voz en H-05 |
| D-01b | 4 | Intents: los dos sin frase y el snapshot del App Group | D-01a, P-04b | El snapshot se lee desde el contenedor compartido |
| D-02 | 4 | Widgets: pequeño, rectangular e inline | D-01a, D-01b, P-04b, DS-01 | `AVAudioEngine` a 0 en la extensión |
| D-03 | 4 | Control y botón de Acción | D-01a, D-02 | Ningún `perform` nuevo. Se corta si no está integrado el 22-02-2027 |
| D-04 | 4 | Live Activity recortada | D-01a, D-01b, D-02, S-02, P-05, H-01 | Solo en escenario A, con un sí escrito del dueño el 14-12-2026 |

## 5. Lista de comprobación del revisor (Claude) para los PR de Codex

1. `scripts/verify.sh` devuelve 0 en el worktree de integración, sobre `main` actualizado, sin avisos.
2. El diff solo toca la lista cerrada del brief. Nada de `project.yml`, `Info.plist`, entitlements ni `.xcodeproj`.
3. Cada línea de aceptación tiene un test con nombre o un grep. Ningún test compara una constante consigo misma.
4. Audio: `EngineCommand` sigue siendo POD, el test de desgarro por bytes sigue en verde, no hay heap, locks ni clases en el render, nada entra en escalón y `scripts/verify.sh --bench` queda dentro del 10 % de `BASELINE.md`, repetido por Claude. Un método público nuevo del motor está también en el protocolo y en el doble.
5. App Intents: log del procesador de metadatos limpio, frases solo con enum o entidad, catálogo `AppShortcuts.xcstrings` en los dos idiomas.
6. Interfaz: comparada en simulador con la spec, en tamaño normal y en AX5. Sin candados, sin `Timer` en `Design`, un solo `#available(iOS 26`.
7. Cadenas: fragmento `strings/<ID>.json`, inglés y español, lint de copy en verde, vocabulario de la reconciliación §3.
8. Turnos de §3.9 del plan respetados: ningún fichero caliente fuera de su turno.
9. El PR dice qué no se verificó en dispositivo y a qué paquete del dueño queda.
10. Si es la segunda devolución, se para y se reasigna. Los arreglos del integrador no pasan de 30 líneas.

## 6. Huecos del plan resueltos aquí de forma provisional

- I-02: Codex no hace push ni usa `gh`. Claude sube la rama y le devuelve los logs de la CI.
- R-01 trae `Features/Bedtime` y una entrada simple a Noche. Sin eso no compilan los 54 tests ni hay H-02a. `BedtimeView.swift` entra adaptado, sin `DesignTokens`: la vista se tokeniza en B-03.
- P-02 y DS-02 tocan un punto fuera de su lista: `TimerButtonLabel` y el gancho DEBUG de la galería.
- S-02 necesita un commit de preparación en `project.yml`. El plan §3.9 ya lo nombra: vive solo en la rama del spike y nunca llega a `main`.
- Si el plan y este cuaderno difieren en un comando, se corrige el que esté mal. El bloque de R-01 del plan §9 ya es el de este brief.
