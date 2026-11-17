# Tablero de estado · SleepNoise 1.0

Última actualización: 17-11-2026. Plan vigente: `docs/PLAN-SIMPLE-1.0.md` (12 paquetes, 4 semanas). Este tablero sustituye al de 67 paquetes del plan anterior.

Solo lo edita Claude Code, en el mismo PR que cambia un estado o en el siguiente. Si el tablero y el plan difieren en autor o revisor, manda el plan.

Estados: pendiente, en curso, en revisión, cambios, integrado, atascado, cancelado.

Resumen: 1 en curso (S-04), 9 pendientes, 2 integrados (S-01 y S-02). PR abiertos del plan: 0 de 2.

| Id | Paquete | Autor | Revisor | Semana | Rama | Estado | PR |
|---|---|---|---|---|---|---|---|
| S-01 | `scripts/verify.sh`, CI de macOS, `AGENTS.md` corto, solo iPhone | Claude | Cursor (lectura) | 1 | `claude/s-01-verify-ci` | fusionado 17-11 | 5 |
| S-02 | Rescate del PR #3: motor, texturas, modelo e intents compilando | Claude | Cursor (CI) | 1 | `claude/s-02-rescate-pr3` | fusionado 17-11 | 6 |
| S-03 | Lógica pura con tests: `NightWindow`, reloj de la prueba, receta de Madrugada (mitad A) y `AccessPolicy` (mitad B) | Cursor | Claude | 1 | `cursor/s-03a-logica-pura`, `cursor/s-03b-politica-acceso` | pendiente | - |
| S-04 | Tokens Grafito, Horizonte (con nivel RMS desde el hilo de audio), Disco, filas, página principal y Capas | Claude | Cursor (CI) | 2 | `claude/s-04-pagina-grafito` | en curso | - |
| S-05 | Códec de mezclas v2, mezclas de la casa, políticas de interrupción y de ruta | Cursor | Claude | 2 | `cursor/s-05-mezclas-politicas` | pendiente | - |
| S-06 | Noche, Madrugada, Temporizador, Marea y Mezclas en Grafito (con ganancia maestra con rampa) | Claude | Cursor (CI) | 2-3 | `claude/s-06-noche-temporizador` | en curso | - |
| S-07 | Hoja Pro, prueba de 7 noches, recibo y estados de la tienda; sandbox | Claude | Cursor (CI) | 3 | `claude/s-07-hoja-pro` | pendiente | - |
| S-08 | Catálogo de cadenas EN y ES, test de interfaz que genera las capturas | Claude | Cursor (CI) | 3 | `claude/s-08-cadenas-capturas` | pendiente | - |
| S-09 | Ficha de App Store EN y ES, notas para revisión, "Lo que no hay", política de privacidad | Cursor | Claude + dueño | 3 | `cursor/s-09-ficha` | pendiente | - |
| S-10 | Icono "La regla y la marea" | Claude o diseñador | Dueño | 3 | `claude/s-10-icono` | pendiente | - |
| S-11 | Correcciones de la beta | Claude | Cursor (CI) | 4 | `claude/s-11-beta` | pendiente | - |
| S-12 | Build de lanzamiento y envío | Claude + dueño | Dueño | 4 | `claude/s-12-lanzamiento` | pendiente | - |

Notas:

- S-03 va en dos PR. La mitad A puede empezar cuando S-01 esté en `main`; la mitad B espera a S-02 (PLAN-SIMPLE §10). Brief: `docs/briefs/S-03.md`.
- Las ramas de los paquetes pendientes son nombres propuestos: se fijan al lanzar cada paquete.
- Pendiente del dueño tras fusionar S-01: proteger `main` y marcar el check `verify` de la CI como obligatorio. En ese momento conviene añadir `.github/CODEOWNERS` para `scripts/`, `.github/` y `project.yml`: hoy la CI solo avisa cuando un PR toca la puerta, no lo impide.
- El PR #3 se cerró el 17-11-2026 al fusionar S-02 (PR 6), que lo sustituye.
- Mínimo de tests: `scripts/verify-min-tests.txt` (hoy 49). Claude lo sube al total nuevo al fusionar cada paquete que añade tests.
- El lint de la lista negra de palabras (`docs/design/10-GUIA-DE-COPY.md` §0.5) todavía no existe: `CopyLintTests` solo cubre los términos médicos. Propuesta del integrador: entra con S-08, ampliando `CopyLintTests` junto al catálogo de cadenas. Hasta entonces el punto 4 de la definición de hecho se revisa a mano.
- La mitad B del brief S-03 se revalidó contra `main` el 17-11-2026, con S-02 ya fusionado. Las dos mitades se pueden lanzar; la B después de que entre la A, por el límite de un PR de Cursor.

## Lo que S-03 deja abierto

De la revisión de S-03 (17-11-2026). S-03 solo podía tocar lógica pura, así que estos puntos quedan para el paquete que se indica. Quien abra ese paquete los lee antes de empezar.

### Puertas del reparto antiguo que siguen vivas

- **Temporizador a medida (S-06).** `SleepNoise/Features/Timer/SleepTimerView.swift`, fila "Custom": se bifurca por `hasFullAccess` sin consultar `AccessPolicy`. Sin acceso completo enseña un candado y la cadena `timer.locked`, y `MixerView` abre la hoja Pro al tocarla, a cualquier hora. Contradice C03: el temporizador entero es libre. Arreglo: quitar el candado y la rama `else`, y dejar el Stepper y el botón para todos. Si S-06 sustituye la vista entera, su revisión comprueba que no hereda la bifurcación.
- **Hecho en S-06 (tarea 2).** `SleepTimerView` se borró entera, con `timer.locked` y el resto de sus cadenas. La hoja nueva (`TimerSheet`) no consulta el acceso en ningún punto y `TimerCatalogTests.testTheWordProDoesNotAppearInTheTimer` vigila que la palabra "pro" no vuelva a sus cadenas.
- **Respuesta de Siri inalcanzable.** `IntentReply.timerNeedsPro` (`SleepNoise/Intents/SleepIntents.swift`) ya no se alcanza. Al retirarla se van también `intent.timerNeedsProFormat` y el ayudante `lengthThatNeedsPro` de `SleepNoiseTests/PolicyTests.swift`.

### Cadenas del catálogo que afirman el reparto antiguo

Hablan de un temporizador de 60 minutos, de una sola mezcla, de cuatro sonidos gratis (falta el viento) o de una prueba que empieza con Play. Las de la prueba y la hoja Pro se reescriben o retiran en S-07; el resto, en S-08.

```
timer.locked
paywall.trial.activeFormat
paywall.trial.notStartedFormat
paywall.trial.endedDetail
intent.timerNeedsProFormat
```

S-04 retiró las que vivían en la pantalla antigua (`trial.intro.*`, `trial.ended.*`, `mixes.stripped`), junto con el resto de cadenas que solo usaba ella. `paywall.trial.activeFormat` es la que ve hoy toda instalación nueva que abre la hoja Pro mientras corre la prueba. `timer.locked` ya no se enseña: la página abre la hoja del temporizador con todas las duraciones libres. La corrección de S-04 quitó de la hoja Pro la ventaja del temporizador (`paywall.benefit.timer*`, que vendía algo que ya es gratis) y puso en las tres `paywall.trial.*` el viento y "el temporizador entero"; siguen hablando de días y de una prueba que empieza con Play, y se reescriben en S-07.

### Textos fuera del catálogo

- `README.md`, párrafo de lo gratis y lo Pro: dice temporizador de 15, 30 o 60 minutos, una mezcla guardada y prueba de 7 días que empieza con el primer Play. Se corrige cuando la interfaz ya no tenga la puerta del temporizador a medida (S-06) y la prueba esté cableada (S-07).
- `SleepNoise/Resources/SleepNoise.storekit`, descripciones EN y ES del producto: mencionan "timers past 60 minutes and custom". Se reescriben en S-07, que ya toca la tienda, y se replican en App Store Connect.

### Condiciones para cablear `NightTrial` (S-07)

- **La cifra de "quedan n noches" no se enseña sin cerrar con el dueño la pregunta 08 §9.3.** `nightsRemaining` ancla hoy cada noche al día en que empezó (hasta las 07:00 sigue siendo la noche anterior), así que la cifra ya no baja a medianoche. Queda un defecto: el día en que la prueba se agota el suelo devuelve 1 ("última noche") aunque esa noche el arranque de sesión ya la dé por terminada. `testNightsRemainingWithADaytimeStart` lo deja escrito. Propuesta de la revisión: contar los comienzos de noche (21:00) que quedan antes del fin; el último día da 0 y la interfaz dice que la prueba termina hoy o no muestra cifra.
- `start(now:)` no se ofrece ni se llama dentro de `NightWindow`, y el paso a `.ended` no se anuncia de noche. Son contratos del comentario del tipo: la función no los comprueba.
- `start(now:)` devuelve `false` y no da acceso si el registro no se puede crear. La interfaz necesita un estado para ese caso.
- `observe(now:)` se llama al lanzar la app y al volver a primer plano. Sin esas llamadas, atrasar el reloj antes de cada Play alarga la prueba sin límite.
- `KeychainTrialStorage.loadTrial` no distingue "no hay registro" de un fallo de lectura. Ya no permite una segunda prueba (`createTrial` no pisa un registro), pero con la prueba activa un fallo de lectura deja ese arranque en el nivel gratuito sin explicación. Decidir en S-07 si se reintenta.
- `TrialRecord` se mantiene compatible hacia atrás: un campo nuevo es opcional.

### Madrugada (S-06)

- La revisión añadió `AccessPolicy.soundIsIncluded(_:hasFullAccess:inSmallHours:)`, que el brief no pedía: en Madrugada el sonido de la receta (`SmallHoursRecipe.standard.sound`, océano) suena para todos, igual que la Marea. `MixerModel.currentGains()` y `isSilent` usan hoy la firma de dos argumentos: si Madrugada se cablea por ese camino sin la firma nueva, quien no tiene Pro oye silencio.
- **Hecho en S-06 (cimientos).** Madrugada no pasa por la mezcla: `SmallHoursController.gains(hasFullAccess:)` y la Marea de la sesión usan las firmas `inSmallHours`, y `MixerModel.currentGains()` devuelve la receta mientras `isSmallHours`. Test: `SmallHoursModelTests.testItPlaysTheRecipeForEveryoneAndTouchesNothingOfThePerson`.

## Lo que S-04 deja abierto

De la entrega de la página y de Capas (17-11-2026). Quien abra el paquete indicado lo lee antes de empezar.

### Decisiones tomadas al construir, a confirmar

- **Capas va sobre `hoja`**, como pide PLAN-SIMPLE §4.1 ("nunca hojas negras sobre negro"). 03 §4.10 y 05 §2.7 la querían sobre `negro`. Sobre `hoja` el relieve ya no es `grafito` (1E1D1B sobre 1C1C1E, 1,01:1) sino `negro` (`Ink.relief(on:)`, 1,23:1, sin hex nuevo): el Disco, la pista bajo el dedo y la fila editorial pulsada. Si se prefiere el negro, es un argumento en `LayersSheet` (`grafitoSheet(surface:)`).
- **La barra inferior** es "Mezclas" y el Disco; el sitio de "Noche" queda vacío hasta S-06. Marea y Temporizador son filas de la página, como en la maqueta. La barra es propia (no `ToolbarItemGroup`), para que se vea igual en iOS 17 y 26.
- **La línea de estado** elige así cuando coinciden varias cosas: fundiendo, capa por defecto ("rosa a 40"), hora del temporizador, "sin {capa}", "Sonando".
- **"y N más"** cuenta las capas por encima de cero que no tienen fila, también las Pro que conservan nivel.
- **Versalitas con `.smallCaps()`**, como pide 03 §3.4 y dibuja la maqueta (`all-small-caps`): las cifras y las mayúsculas bajan a la altura de la versalita ("pro · 50", "prueba · 7 días"). 04 §2.0.2 y su anexo A2 escriben `.lowercaseSmallCaps()`, que deja las cifras a altura de mayúscula; manda 03.
- **Las notas de Capas son un solo párrafo** (`capas.nota`, salto de línea, `capas.cero`), para que el interlineado del paso 7 valga también entre las dos. VoiceOver las lee como un elemento.
- **Play con la mezcla en silencio** (vacía o toda Pro sin acceso) sube rosa a 40 como nivel real (05 §2.12). Los intents siguen negándose a empezar una noche en silencio.

### Página nocturna (S-06)

- La tinta nocturna es por procedencia (C40): `MixerModel.beginNightSession()`, que ya llama `leaveBedtime()`. Hoy nada entra en Noche, así que la página nocturna solo se ve con `-pageState night`. Vive en memoria: falta decidir qué es "la sesión" y guardarla.
- La venta se cierra por `NightWindow` y, además, mientras dure la página nocturna (`SaleGate`). Toda petición de la hoja Pro pasa por `MixerModel.offerPro()`.
- **Hecho en S-06 (cimientos): qué es "la sesión".** La noche es la sesión de audio: va del Play hasta que acaba sola (fin del temporizador, 20 minutos en pausa por `SessionPause`, la ventana de la mañana o el fin de Madrugada). No se guarda: tras un reinicio no suena nada y no hay sesión. La página nocturna dura hasta que la persona toca el nombre o hasta que la app pasa a primer plano de día (fuera de `NightWindow`) con esa noche ya terminada; mientras se mira no la cambia ningún reloj (`MixerModel.appDidBecomeActive()`, tests en `BedtimeModelTests`). A confirmar por el dueño.

### Prueba (S-07)

- La cabecera de la página está vacía hasta que la prueba empieza (05 §2.1, C07) y enseña después la prueba de 7 días de hoy con la cadena del chip antiguo (`trial.chip.daysFormat`), como palabra de estado. La tarjeta de bienvenida y la de "prueba terminada" se fueron con la pantalla antigua: la prueba sigue empezando con Play hasta S-07, y ahora solo lo dice la hoja Pro.
- Los renglones de la nota de una vez (noche 7 y noche 8) no se construyeron: dependen de `NightTrial`. La cabecera tiene su renglón fijo.

### Lo que la página no hace todavía

- Marea: la banda de 120 pt y la línea de agua, "Se retira a las", y que el interruptor arranque el sonido (S-06). El interruptor arma la Marea como hasta ahora.
- **S-06 (tarea 2):** el interruptor ya arranca el sonido (`setBreathingEnabled(_:startsSound:)`), y la línea de agua y "Se retira a las" existen en la hoja Marea. **La banda de 120 pt de la página sigue sin hacer**: el Horizonte de la página no cambia con la Marea.
- Línea 2: "Seguir por el altavoz", "Sonando · al 40", "En pausa · llamada", "· AirPods" y el fin de sesión a los 20 minutos en pausa dependen de cablear `RoutePolicy` e `InterruptionPolicy` (S-06).
- Menú del nombre: solo "Guardar como mezcla…". Renombrar y Vaciar, con Mezclas (S-06).
- Descomposición del Horizonte por pulsación larga, TipKit del segundo arrastre, fila Timbre (1.1) y "Enviar informe".
- Una mezcla guardada con más de seis capas se carga entera: el tope solo impide añadir la séptima (ver "Lo que la corrección de S-04 aplaza").

## Lo que la corrección de S-04 aplaza

De la revisión de la página y de Capas (17-11-2026). Lo que sigue no se arregló en S-04 porque es de otro paquete o porque lo decide el dueño.

### Preguntas al dueño

- **Fondo de Capas de noche.** Abierta desde la página nocturna, Capas cambia toda la tinta (título incluido), pero la hoja entera en `#1C1C1E` enciende la pantalla. 03 §4.10 la quería negra por eso; PLAN-SIMPLE §4.1 prohíbe hojas negras sobre negro. ¿Capas sobre `negro` solo de noche?
- **Pomo del interruptor de Marea.** 03 §4.12 y 04 §9 #14 cierran "Toggle del sistema con `.tint(texto)`", y así está. En iOS 26 el pomo es una píldora blanca de unos 37 × 23 pt: lo más luminoso de la página nocturna, y encendido queda blanco sobre pista `texto`. Se mantiene el del sistema como coste aceptado; la alternativa es un `ToggleStyle` propio dibujado con tokens. Capturas `page-tide` y `page-nightTide`.
- **Tope de seis (C19) fuera de `setLevel`.** La Marea ya no sube el océano si suenan seis. Quedan dos vías: (a) quien recupera el acceso con capas Pro guardadas a nivel puede pasar a sonar con más de seis; (b) una mezcla guardada, o los niveles de una versión anterior, con más de seis se cargan enteros. Hace falta una sola regla en un solo sitio. Propuesta de la revisión: `currentGains()` deja sonar las seis capas incluidas más altas y las demás conservan su nivel sin sonar, como una capa Pro sin acceso.
- **"Requiere Pro" de noche con VoiceOver.** La guía 10 §3 dice que en la página nocturna no existe "requiere Pro"; su tabla 5b solo dice "de noche sin pista". Se aplicó la regla: en la página nocturna una fila Pro se lee como cualquier otra, con el valor "en silencio, nivel guardado N", y el interruptor de Marea dice solo que está apagado. Confirmar.
- **Dos contradicciones de la guía 10**, a cerrar antes del lint de S-08: `temporizador.estado.dormirme` en inglés ("Until I sleep · %lld min", §5e) casa con la lista negra EN de la propia guía (`until I sleep`); y "y n más" (`capas.mas`) es paso 5 en la guía y paso 9 en 05 §2.1. Se siguió 05: paso 9, como dato.

### S-06 (Noche, Temporizador, Marea y Mezclas)

- **Temporizador de 45 minutos en el primer uso** (03 §5 #8, 05 fila "Noche 1"). Hoy la fila dice "Apagado" y el primer Play suena sin fin. Hay que distinguir el primer uso de un "Apagado" elegido por la persona. **Hecho en S-06 (cimientos):** `TimerChoice.firstUse` rige mientras no haya nada guardado; "Apagado" es una elección que se guarda (`MixerModel.chooseTimer`).
- **La identidad de la mezcla cargada no sobrevive al reinicio.** Quien carga una mezcla guardada y vuelve a abrir la app ve "Esta noche" con los niveles de su mezcla, y pierde el "· sin Océano" del título recortado. Guardar nombre base, receta e id de la mezcla de la casa junto a los niveles.
- **Mezclas de la casa.** La hoja Mezclas solo lista las guardadas: "Mar y viento", "Marrón y hoguera" y "Pared" no se cargan desde ninguna pantalla, y "Rosa y lluvia" no se recupera tras la primera edición.
- **Nombre automático de la mezcla** (`mezcla.nombre.auto.*`, guía §4.2). Al guardar, el campo se precarga con el nombre que la mezcla ya tiene, o con "Esta noche".
- **La Marea sube el océano a 50** (`MixerModel.tideOceanLevel`) y lo vuelve a bajar si se apaga sin tocarlo. La guía dice 40 y "nunca lo vuelve a bajar". La cadena `marea.oceano.subido` lleva la cifra del modelo.
- **Hecho en S-06 (tarea 2).** `tideOceanLevel` es 0,4 y la Marea no vuelve a bajar el océano que subió (`oceanBeforeTide` se fue).
- **Copy heredado en las hojas antiguas**, a borrar al rehacerlas: `common.close` como botón en las cuatro (las hojas Grafito no llevan botón de cerrar), `breath.title` ("Marea respiratoria"; C15: "Marea"), `timer.title` EN ("Sleep timer"), `timer.note` ("se desvanece"), `timer.custom` ("Personalizado"), `mixes.title` ("Mezclas guardadas"). En `SleepTimerView` las ramas del candado, `timer.locked` y `onLocked` están muertas: la página pasa `hasFullAccess: true`.
- **Hecho en S-06 (tarea 2)** para Temporizador y Marea: se borraron `timer.*` y `breath.*` enteras (`TimerCatalogTests.testTheStringsOfTheOldSheetsAreGone`). `common.close` y `mixes.title` siguen en Mezclas y en la hoja Pro.

### S-07 (hoja Pro y prueba)

- **S-04 no se publica sin S-07.** La prueba sigue arrancando con el primer Play, también de madrugada, y la página no lo dice: solo lo explica la hoja Pro antigua.
- **Cabecera vacía tras la prueba.** Con la prueba terminada y sin compra, comprar y restaurar se alcanzan solo desde una fila "pro" de Capas, desde la Marea o al guardar la cuarta mezcla, y nunca de noche. `pro.prueba.estado.gratis` ("gratis siempre") y las cadenas `pro.prueba.estado*` en noches entran aquí.
- **Cadenas de la hoja Pro que faltan en la lista de arriba:** `paywall.purchaseFormat` ("Desbloquear Pro", en la lista negra), `paywall.restore` ("Restaurar compras"; la guía pide "Restaurar compra"), `paywall.trial.titleFormat` (días) y `common.close`.

### S-08 (cadenas y capturas)

- Las capturas de referencia en inglés son cuatro (`page-en-rest`, `page-en-timer`, `page-en-layersSix`, `page-en-layersEnd`): el resto del inglés no se ha mirado en pantalla.

## Lo que S-06 lleva hecho

### Tarea 1 · Cimientos de audio y modelo (17-11-2026)

Sin vistas nuevas. Las hojas antiguas (Temporizador, Marea, Mezclas, Pro) siguen compilando sobre el modelo nuevo; las tareas siguientes de S-06 las sustituyen.

- **Ganancia maestra** (C51): `EngineCommand.masterTarget`, `masterRampSamples` y `masterGeneration`, aplicada después del `softClip` (cambia el nivel, no el timbre). Las dos ganancias del render (envolvente y maestro) cuentan muestras enteras con `SampleRamp` (C31).
- **Temporizador de dos modos** (C03, C22): `TimerChoice` (`.off`, `.untilAsleep`, `.blanket`) y `SleepTimerController` con reloj inyectado. Fundido final de un cuarto de la noche con techo de 15 minutos; Manto baja 6 dB a los 45 minutos por el maestro, en un minuto. "+15 min" sin tope y nunca crea un temporizador (C47).
- **Madrugada** (C05, C60): `SmallHoursController` y `MixerModel.startSmallHours()`. No toca la mezcla, el temporizador ni la Marea de la persona, no arranca la prueba y no vende a ninguna hora.
- **Interrupciones y ruta** (C48, C49): `InterruptionTracker`, `MorningWindow`, `RoutePolicy` y `SessionPause` cableados en `MixerModel` a través de `AudioSessionObserving`, con `CXCallObserver` para distinguir la llamada.
- **Noche** (C40, C46, C47): atenuación a los 60 s, "Mantener encendida" (por defecto mientras carga), eje vertical como nivel de sesión.

Decisiones tomadas al construir, a confirmar:

- **Duración del fundido final.** C31 dice "10 a 15 minutos" sin decir cuándo cada uno: se aplica un cuarto de la duración con techo de 15 (10 minutos a los 40, 15 desde una hora). Una noche de menos de 40 minutos funde ese mismo cuarto.
- **Rampa del Manto.** C22 fija los −6 dB y los 45 minutos, no la rampa: un minuto, como proponía 07.
- **Manto y "+15 min".** C50 deja el "+15" vacío en Manto para la Live Activity (1.1); en la app suma a la hora de fin de esa noche sin tocar la hora elegida.
- **Suelo del nivel de sesión** en 0,05 (`MixerModel.minimumSessionLevel`): el arrastre de Noche baja la noche, no la apaga. El nivel es la ganancia tal cual (0,4 son −8 dB).
- **"En pausa · AirPods"** (`pagina.estado.pausa.airpods`) no se usa: la pausa pedida con auriculares puestos dice "En pausa · auriculares", porque no se puede afirmar que sean AirPods.
- **Interrupción sin `.ended`.** Se cierra al volver la app a primer plano, salvo que haya una llamada en curso u otra app sonando: nada se reanuda encima de otro audio.
- **`CallKit` en China.** `CXCallObserver` es la decisión de C48; antes de publicar en China continental hay que comprobar si la tienda de allí sigue rechazando las apps que enlazan `CallKit`.

Sin hacer en esta tarea, y de quién es:

- Las vistas: fila y línea de estado de la página para Manto ("Sonando · hasta las %@", `temporizador.estado.manto`), "Seguir por el altavoz" y "Sonando · al %lld" en la segunda línea, Noche, Madrugada y las hojas nuevas (tareas 2 a 4 de S-06).
- "Pasar sola a Noche" al bloquear o a 1 y 3 minutos (C47): es de la vista de Noche y de Ajustes; el modelo solo tiene `enterBedtime()`.
- Aplicar `isIdleTimerDisabled`: la vista de Noche pregunta a `bedtimeKeepsScreenAwake(isCharging:)` con el estado de la batería.
- El intent `SmallHours` y retirar `IntentReply.timerNeedsPro` (superficie 24).
- La Marea sigue subiendo el océano a 50 y la identidad de la mezcla sigue sin sobrevivir al reinicio: son de las tareas de Marea y de Mezclas.
- Sin verificar en dispositivo: el audio real (rampa del maestro, fundido largo), las interrupciones y los cambios de ruta de verdad, y `CXCallObserver`. Todo lo anterior está probado con dobles y render offline.

### Tarea 2 · Temporizador y Marea (17-11-2026)

Las hojas `TimerSheet` (superficie 8) y `TideSheet` (superficie 6) sustituyen a `SleepTimerView` y `BreathingSettingsView`, que se borraron con sus cadenas. La lógica de presentación es pura y está probada (`TimerSheetText`, `TideStatus`, `TideSheetText`, `TideBreath`). Estados de depuración `-pageState timer…` y `tide…` en `PageDebug.swift`.

- **Temporizador** (C03, C22, C31): dos modos y "Apagado", sin "Aceptar"; la fila es la elección. Sonando, un bloque sobre la lista dice lo que queda como cifra, el fin como hora ("Se funde a las 03:42") y "+15 min". El control del modo (rueda de 5 a 360 en pasos de 5, o el selector de hora del sistema) se abre bajo su fila. La fila de la página dice "Manto · hasta las 07:00" y la línea de estado "Sonando · hasta las 7:00".
- **Marea** (C24, C59, C06, C08): línea de agua (`TideLine`, 03 §4.3) que lee la misma curva y el mismo ancla que el audio, palabra de estado, "Se retira a las", y cuatro filas: interruptor, Ritmo, Descenso y "Se retira a los". Sin acceso, "pro" junto al título y el interruptor pide la hoja Pro solo fuera de `NightWindow` y de la página nocturna; de noche no pasa nada.
- **Descenso** (C14, C24): `BreathingSettings.descends`. La guía empieza a 12 por minuto y baja un entero cada 40 s hasta el ritmo elegido; cero parámetros nuevos en el motor (solo cambia `rate`, que ya conserva la fracción del ciclo).

Decisiones tomadas al construir, a confirmar:

- **Tinta de las hojas de noche.** Abiertas desde la página nocturna, Temporizador y Marea toman la tinta única, como Capas, y siguen sobre `hoja`. 07 §2.1 quería el Temporizador siempre en tinta de día y 06 §3.13 la Marea sobre `negro`; manda PLAN-SIMPLE §4.1 (nunca negro sobre negro) y la coherencia con Capas.
- **Línea bajo la cifra.** Con las claves de la guía, fundiendo se lee "8 min" y debajo "Fundiendo · 8 min", y con Manto "7:00" y debajo "hasta las 7:00 · baja un poco a los 45 min" (lo que pide 07 §2.1.2). La cifra se repite: evitarlo pide dos cadenas que la guía no tiene ("Fundiendo" a secas y una línea propia del Manto).
- **Las cifras de las cadenas salen del código** (AGENTS §5.2): los 45 minutos de `temporizador.manto.detalle`, el 12 de `marea.ritmo` y el 6 y el 8 de `marea.ritmo.tranquilo*` y `.suave*` son argumentos. La guía los escribe dentro del texto.
- **"Apagado" no tiene valor en el hueco de control**: la fila queda vacía, con su altura. 07 ponía "toda la noche"; la guía no trae esa cadena.
- **El menú Ritmo** ofrece los dos nombres ("Tranquilo · 6", "Suave · 8") y, si la línea se arrastró a otro, ese valor. El ajuste exacto es el arrastre de la línea (un entero cada 56 pt) y la acción ajustable de VoiceOver.
- **"Armada"** (interruptor encendido sin sonar, tras un arranque en frío): la caja de estado queda vacía. "empieza al reproducir" está pendiente de la guía (06 §9).
- **"Toda la noche"** ya no se ofrece (06 §8): un ajuste guardado con 0 se lee como 30 minutos.
- **Las ruedas del sistema** llevan la tinta de la fase con `colorMultiply`; la banda de selección es la del sistema.

Sin hacer en esta tarea, y por qué:

- **La banda de 120 pt y la línea de agua en la página** (03 §3.5, 05 §2.3): cambia la geometría de la página para todo el que tiene Marea. Queda para quien cierre la página en S-06.
- **Paquete I0-8 de 06** (cambios de `main` que la spec pide): la disolución dentro de la ventana (hoy la guía dura la ventana entera y disuelve 120 s después), los 30 s de disolución al apagar a mano (hoy corta con el suavizado del motor), que el interruptor vuelva a apagado solo tras la retirada, y corregir el ancla con `outputLatency`.
- **Háptica "Mínima"** (C35): 06 la mantiene en 1.0, pero no hay base de Core Haptics en el código. La fila Háptica y su nota no están; entra con Ajustes.
- **"Qué sabemos ›"**: la pantalla de destino no existe (E5, E7).
- **`Slider` de pulsación larga sobre la banda** y la fila "Ritmo exacto" para Control por botón.
- **Rueda de minutos de 5 en 5 en el selector de hora**: el `DatePicker` de SwiftUI no lo ofrece sin tocar la apariencia global.
- **README**: el párrafo de lo gratis sigue diciendo 15, 30 o 60 minutos; se corrige con la prueba en S-07.
- Sin verificar en dispositivo: VoiceOver sobre las dos hojas, el arrastre de la línea con un dedo real, la háptica de selección y que la línea de agua vaya con el oleaje (en el simulador el audio se silenció).
