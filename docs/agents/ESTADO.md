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
- **Hecho en S-06 (tarea 4).** `IntentReply` entero, `lengthThatNeedsPro` y todas las cadenas `intent.*` y `shortcut.*` se fueron con los intents antiguos. `IntentOutcome` ya no tiene ningún caso que pida Pro.

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

**Hecho en S-07 (tarea 2):** no queda ninguna. `PaywallView` se borró con todas las `paywall.*` y con `common.close` (`ProCatalogTests.testTheStringsOfTheOldSheetAreGone`).

### Textos fuera del catálogo

- `README.md`, párrafo de lo gratis y lo Pro: dice temporizador de 15, 30 o 60 minutos, una mezcla guardada y prueba de 7 días que empieza con el primer Play. Se corrige cuando la interfaz ya no tenga la puerta del temporizador a medida (S-06) y la prueba esté cableada (S-07).
- `SleepNoise/Resources/SleepNoise.storekit`, descripciones EN y ES del producto: mencionan "timers past 60 minutes and custom". Se reescriben en S-07, que ya toca la tienda, y se replican en App Store Connect.
- **Hecho en S-07:** el `.storekit` en la tarea 1 y el README en la tarea 2 (reparto, prueba, Atajos, pasos de la tienda local y mapa).

### Condiciones para cablear `NightTrial` (S-07)

**Hecho en S-07 (tarea 1):** las seis están resueltas; el detalle está en "Lo que S-07 lleva hecho", al final.

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
- **La barra inferior** es "Mezclas", el Disco y, desde S-06 (tarea 3), "Noche". Marea y Temporizador son filas de la página, como en la maqueta. La barra es propia (no `ToolbarItemGroup`), para que se vea igual en iOS 17 y 26.
- **La línea de estado** elige así cuando coinciden varias cosas: fundiendo, capa por defecto ("rosa a 40"), hora del temporizador, "sin {capa}", "Sonando".
- **"y N más"** cuenta las capas por encima de cero que no tienen fila, también las Pro que conservan nivel.
- **Versalitas con `.smallCaps()`**, como pide 03 §3.4 y dibuja la maqueta (`all-small-caps`): las cifras y las mayúsculas bajan a la altura de la versalita ("pro · 50", "prueba · 7 días"). 04 §2.0.2 y su anexo A2 escriben `.lowercaseSmallCaps()`, que deja las cifras a altura de mayúscula; manda 03.
- **Las notas de Capas son un solo párrafo** (`capas.nota`, salto de línea, `capas.cero`), para que el interlineado del paso 7 valga también entre las dos. VoiceOver las lee como un elemento.
- **Play con la mezcla en silencio** (vacía o toda Pro sin acceso) sube rosa a 40 como nivel real (05 §2.12). Desde S-06 (tarea 4) los intents y las filas de Mezclas hacen lo mismo: el instrumento siempre suena (guía 10 §4.10).

### Página nocturna (S-06)

- La tinta nocturna es por procedencia (C40): `MixerModel.beginNightSession()`, que ya llama `leaveBedtime()`. Hoy nada entra en Noche, así que la página nocturna solo se ve con `-pageState night`. Vive en memoria: falta decidir qué es "la sesión" y guardarla.
- **Hecho en S-06 (tarea 3).** "Noche" está en la barra (página y Capas) y Noche es una capa sobre la página: salir de ella (pulsación larga, botón de VoiceOver, gesto de escape) deja la página nocturna; el fin de Madrugada también.
- La venta se cierra por `NightWindow` y, además, mientras dure la página nocturna (`SaleGate`). Toda petición de la hoja Pro pasa por `MixerModel.offerPro()`.
- **Hecho en S-06 (cimientos): qué es "la sesión".** La noche es la sesión de audio: va del Play hasta que acaba sola (fin del temporizador, 20 minutos en pausa por `SessionPause`, la ventana de la mañana o el fin de Madrugada). No se guarda: tras un reinicio no suena nada y no hay sesión. La página nocturna dura hasta que la persona toca el nombre o hasta que la app pasa a primer plano de día (fuera de `NightWindow`) con esa noche ya terminada; mientras se mira no la cambia ningún reloj (`MixerModel.appDidBecomeActive()`, tests en `BedtimeModelTests`). A confirmar por el dueño.

### Prueba (S-07)

**Hecho en S-07 (tarea 1):** la prueba ya no empieza con Play. La cabecera usa `pro.prueba.estado*` en noches; los renglones de la nota de una vez tienen modelo (`MixerModel.visibleTrialNote`) y les falta la vista.

- La cabecera de la página está vacía hasta que la prueba empieza (05 §2.1, C07) y enseña después la prueba de 7 días de hoy con la cadena del chip antiguo (`trial.chip.daysFormat`), como palabra de estado. La tarjeta de bienvenida y la de "prueba terminada" se fueron con la pantalla antigua: la prueba sigue empezando con Play hasta S-07, y ahora solo lo dice la hoja Pro.
- Los renglones de la nota de una vez (noche 7 y noche 8) no se construyeron: dependen de `NightTrial`. La cabecera tiene su renglón fijo.
- **Hecho en S-07 (tarea 2):** los dos renglones tienen vista (`PageTrialNote`, `TrialEndedNote`) y la palabra de cabecera no existe de noche. Detalle al final de este fichero.

### Lo que la página no hace todavía

- Marea: la banda de 120 pt y la línea de agua, "Se retira a las", y que el interruptor arranque el sonido (S-06). El interruptor arma la Marea como hasta ahora.
- **S-06 (tarea 2):** el interruptor ya arranca el sonido (`setBreathingEnabled(_:startsSound:)`), y la línea de agua y "Se retira a las" existen en la hoja Marea. **La banda de 120 pt de la página sigue sin hacer**: el Horizonte de la página no cambia con la Marea. **Hecha en la corrección de S-06** (ver el final de este fichero).
- Línea 2: "Seguir por el altavoz", "Sonando · al 40", "En pausa · llamada", "· AirPods" y el fin de sesión a los 20 minutos en pausa dependen de cablear `RoutePolicy` e `InterruptionPolicy` (S-06).
- **S-06 (tarea 3):** "Seguir por el altavoz" y "Sonando · al 40" existen en Noche. **La segunda línea de la página sigue sin hacer**: en la página, tras perder los auriculares, la línea de estado dice "En pausa · auriculares" y el Disco reanuda con la misma regla del 40, pero no hay botón de texto ni nota del nivel. Pide el sitio reservado de 64 pt de la cabecera (guía §2.1), que la página no tiene, y un dato nuevo en el modelo ("capado hasta el primer toque"). **Hecha en la corrección de S-06**, sobre la segunda línea de las dos que la línea de estado ya reservaba.
- Menú del nombre: solo "Guardar como mezcla…". Renombrar y Vaciar, con Mezclas (S-06).
- **S-06 (tarea 4):** el menú del nombre lleva "Guardar como mezcla…", "Renombrar" (si la cargada es una mezcla propia) y "Vaciar", solo de día: en la página nocturna la pulsación larga no hace nada (08 §2.2). "Guardar en «…»" no está.
- Descomposición del Horizonte por pulsación larga, TipKit del segundo arrastre, fila Timbre (1.1) y "Enviar informe".
- Una mezcla guardada con más de seis capas se carga entera: el tope solo impide añadir la séptima (ver "Lo que la corrección de S-04 aplaza").

## Lo que la corrección de S-04 aplaza

De la revisión de la página y de Capas (17-11-2026). Lo que sigue no se arregló en S-04 porque es de otro paquete o porque lo decide el dueño.

### Preguntas al dueño

- **Fondo de Capas de noche.** Abierta desde la página nocturna, Capas cambia toda la tinta (título incluido), pero la hoja entera en `#1C1C1E` enciende la pantalla. 03 §4.10 la quería negra por eso; PLAN-SIMPLE §4.1 prohíbe hojas negras sobre negro. ¿Capas sobre `negro` solo de noche?
- **Pomo del interruptor de Marea.** *Cerrada en la corrección de S-06: `GrafitoToggleStyle`, dibujado con tokens.* 03 §4.12 y 04 §9 #14 cierran "Toggle del sistema con `.tint(texto)`", y así está. En iOS 26 el pomo es una píldora blanca de unos 37 × 23 pt: lo más luminoso de la página nocturna, y encendido queda blanco sobre pista `texto`. Se mantiene el del sistema como coste aceptado; la alternativa es un `ToggleStyle` propio dibujado con tokens. Capturas `page-tide` y `page-nightTide`.
- **Tope de seis (C19) fuera de `setLevel`.** La Marea ya no sube el océano si suenan seis. Quedan dos vías: (a) quien recupera el acceso con capas Pro guardadas a nivel puede pasar a sonar con más de seis; (b) una mezcla guardada, o los niveles de una versión anterior, con más de seis se cargan enteros. Hace falta una sola regla en un solo sitio. Propuesta de la revisión: `currentGains()` deja sonar las seis capas incluidas más altas y las demás conservan su nivel sin sonar, como una capa Pro sin acceso.
- **"Requiere Pro" de noche con VoiceOver.** La guía 10 §3 dice que en la página nocturna no existe "requiere Pro"; su tabla 5b solo dice "de noche sin pista". Se aplicó la regla: en la página nocturna una fila Pro se lee como cualquier otra, con el valor "en silencio, nivel guardado N", y el interruptor de Marea dice solo que está apagado. Confirmar.
- **Dos contradicciones de la guía 10**, a cerrar antes del lint de S-08: `temporizador.estado.dormirme` en inglés ("Until I sleep · %lld min", §5e) casa con la lista negra EN de la propia guía (`until I sleep`); y "y n más" (`capas.mas`) es paso 5 en la guía y paso 9 en 05 §2.1. Se siguió 05: paso 9, como dato.

### S-06 (Noche, Temporizador, Marea y Mezclas)

- **Temporizador de 45 minutos en el primer uso** (03 §5 #8, 05 fila "Noche 1"). Hoy la fila dice "Apagado" y el primer Play suena sin fin. Hay que distinguir el primer uso de un "Apagado" elegido por la persona. **Hecho en S-06 (cimientos):** `TimerChoice.firstUse` rige mientras no haya nada guardado; "Apagado" es una elección que se guarda (`MixerModel.chooseTimer`).
- **La identidad de la mezcla cargada no sobrevive al reinicio.** Quien carga una mezcla guardada y vuelve a abrir la app ve "Esta noche" con los niveles de su mezcla, y pierde el "· sin Océano" del título recortado. Guardar nombre base, receta e id de la mezcla de la casa junto a los niveles.
- **Mezclas de la casa.** La hoja Mezclas solo lista las guardadas: "Mar y viento", "Marrón y hoguera" y "Pared" no se cargan desde ninguna pantalla, y "Rosa y lluvia" no se recupera tras la primera edición.
- **Nombre automático de la mezcla** (`mezcla.nombre.auto.*`, guía §4.2). Al guardar, el campo se precarga con el nombre que la mezcla ya tiene, o con "Esta noche".
- **Hecho en S-06 (tarea 4)** para los tres puntos anteriores: la identidad se guarda en `sleepnoise.loadedMix.v1` (origen, nombre base y receta) y se lee al arrancar; la hoja Mezclas lista las cuatro de la casa; y el campo de guardar se precarga con `MixAutoName` ("Rosa", "Rosa y lluvia", "Rosa, lluvia y viento", "Rosa y 3 más"; "Esta noche" solo con la mezcla vacía).
- **La Marea sube el océano a 50** (`MixerModel.tideOceanLevel`) y lo vuelve a bajar si se apaga sin tocarlo. La guía dice 40 y "nunca lo vuelve a bajar". La cadena `marea.oceano.subido` lleva la cifra del modelo.
- **Hecho en S-06 (tarea 2).** `tideOceanLevel` es 0,4 y la Marea no vuelve a bajar el océano que subió (`oceanBeforeTide` se fue).
- **Copy heredado en las hojas antiguas**, a borrar al rehacerlas: `common.close` como botón en las cuatro (las hojas Grafito no llevan botón de cerrar), `breath.title` ("Marea respiratoria"; C15: "Marea"), `timer.title` EN ("Sleep timer"), `timer.note` ("se desvanece"), `timer.custom` ("Personalizado"), `mixes.title` ("Mezclas guardadas"). En `SleepTimerView` las ramas del candado, `timer.locked` y `onLocked` están muertas: la página pasa `hasFullAccess: true`.
- **Hecho en S-06 (tarea 2)** para Temporizador y Marea: se borraron `timer.*` y `breath.*` enteras (`TimerCatalogTests.testTheStringsOfTheOldSheetsAreGone`). `common.close` y `mixes.title` siguen en Mezclas y en la hoja Pro.
- **Hecho en S-06 (tarea 4)** para Mezclas: `SavedMixesView` y `Theme.swift` se borraron, con todas las cadenas `mixes.*` (`MixesCatalogTests.testTheStringsOfTheOldSheetAndShortcutsAreGone`). `common.close` solo queda en la hoja Pro, que guarda su paleta como `private` hasta S-07.

### S-07 (hoja Pro y prueba)

- **S-04 no se publica sin S-07.** La prueba sigue arrancando con el primer Play, también de madrugada, y la página no lo dice: solo lo explica la hoja Pro antigua.
- **Cabecera vacía tras la prueba.** Con la prueba terminada y sin compra, comprar y restaurar se alcanzan solo desde una fila "pro" de Capas, desde la Marea o al guardar la cuarta mezcla, y nunca de noche. `pro.prueba.estado.gratis` ("gratis siempre") y las cadenas `pro.prueba.estado*` en noches entran aquí.
- **Cadenas de la hoja Pro que faltan en la lista de arriba:** `paywall.purchaseFormat` ("Desbloquear Pro", en la lista negra), `paywall.restore` ("Restaurar compras"; la guía pide "Restaurar compra"), `paywall.trial.titleFormat` (días) y `common.close`.
- **Hecho en S-07 (tarea 2)** para los tres puntos: la hoja Pro es `ProSheet`, la cabecera tras la prueba dice "gratis siempre" siete sesiones y abre la hoja de día, y esas cadenas ya no existen.

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
- **S-07 (tarea 2):** Ajustes existe y la fila Háptica sigue fuera: no hay háptica de la Marea que ajustar.
- **"Qué sabemos ›"**: la pantalla de destino no existe (E5, E7).
- **`Slider` de pulsación larga sobre la banda** y la fila "Ritmo exacto" para Control por botón.
- **Rueda de minutos de 5 en 5 en el selector de hora**: el `DatePicker` de SwiftUI no lo ofrece sin tocar la apariencia global.
- **README**: el párrafo de lo gratis sigue diciendo 15, 30 o 60 minutos; se corrige con la prueba en S-07.
- **Hecho en S-07.**
- Sin verificar en dispositivo: VoiceOver sobre las dos hojas, el arrastre de la línea con un dedo real, la háptica de selección y que la línea de agua vaya con el oleaje (en el simulador el audio se silenció).

### Tarea 3 · Noche y Madrugada (17-11-2026)

Noche (superficie 10) y Madrugada (superficie 11) son `NightScreen` y `SmallHoursScreen` sobre un mismo `FullScreenControl` (03 §4.5), como capa de la página (`NightCover`), no como presentación del sistema: entran y salen por opacidad (2 s; 0,25 s con Reducir movimiento; 0,25 s de Noche a Madrugada, que es negro sobre negro) y la barra de estado se oculta. La lógica es pura y está probada: `NightStatus`, `NightAxis`, `NightTouch`, `NightLayout`, `SmallHoursStatus`, `SmallHoursWater`. Estados de depuración `-pageState night…` y `smallHours…` en `PageDebug.swift`.

- **Noche** (C46, C47, C51, C27): negro, una tinta, Horizonte de 2 pt a un tercio (continuo o ausente), la hora del sistema, la palabra de estado y "+15 min" solo si hay cuenta (Noche nunca crea un temporizador; sin él el hueco queda vacío). Toque = pausa o reanuda; arrastre vertical = nivel de sesión, con la regla de 200 pt y "Sonando · al 40" tres segundos; pulsación de 0,6 a 2 s, al soltar = volver. Terminada, la pantalla deja de ser botón, dice "Terminó a las…" y el hueco del "+15 min" ofrece "Madrugada · 20 min". "Seguir por el altavoz" va encima, con 24 pt de canal, mientras dura la oferta. Atenuada a los 60 s sin tocar (tinta al 50 %); "Mantener encendida" se aplica con `isIdleTimerDisabled` y el estado de la batería.
- **Entrada**: "Noche" en la barra funciona siempre (con la mezcla parada arranca el sonido, como Play, también con una mezcla en silencio: sube rosa a 40). Al bloquear (C47), con `protectedDataWillBecomeUnavailableNotification`: sonando, sin hoja delante y dentro de `NightWindow`. Las dos frases de la primera vez (C65) cuentan sus 4 s solo con la app activa y no se dan por vistas hasta entonces.
- **Madrugada** (C05, C60): línea de agua de 1,5 pt sin marcas, leída del ancla de la receta, que se funde en bajamar cuando la Marea se retira y deja el Horizonte; la cifra de minutos; "Se retira · n min" los últimos cinco; "Parar". En pausa no hay palabra. Al terminar, nada: la capa se funde a la página nocturna. Nunca prueba ni hoja Pro.
- **VoiceOver**: la pantalla es un botón ("Pantalla de noche", con la hora y el estado como valor), "+15 min", "Seguir por el altavoz", "Volumen" ajustable (pasos de 5) y "Volver a la página" como botón propio; Magic Tap y gesto de escape. En Madrugada: la pantalla, "Parar" y "Volumen". Los anuncios de la guía ("Sonando", "En pausa", "Página", los minutos tras "+15").

Decisiones tomadas al construir, a confirmar:

- **`noche.estado.termino`** ("Terminó a las %@" / "Ended at %@") no está en la guía 10: es la frase de 07 §3.2. Sin ella Noche terminada no dice nada. También son nuevas `ax.noche.pista.reanudar` y `ax.madrugada.pista.reanudar`: la guía solo trae la pista "para pausar", que en pausa miente.
- **Sin háptica en la pulsación larga.** 03 §3.8 la pide (`.impact(.light, 0.4)`); C35 y `MotionGate` dicen que de noche nada vibra. Manda la reconciliación.
- **Las frases de primera vez duran 4 s** (guía T25), no los 10 s de 07, y se omiten desde AX3 (están en la pista de VoiceOver).
- **La cifra de Madrugada va a 72 pt en y 396** (03 §3.4, 07 y la maqueta). La guía §2.6 la pone a 56 pt en y 332, donde pisa la banda de la línea de agua.
- **La hora lleva el sufijo del sistema** donde la región usa 12 h (guía §2.5: "2:14 AM"); 07 lo quitaba. *Corregido: la cifra va sin sufijo; las frases lo conservan.*
- **Atenuada = tinta al 50 %** (`BedtimeScreenPolicy.dimmedOpacity`): ninguna spec da la cifra. *Corregido a 0,6 (3,3:1), el suelo de 03 §3.7; 0,8 con Aumentar contraste.* Volver la app a primer plano cuenta como un toque.
- **Entrada al bloquear solo dentro de `NightWindow`** (21:00–07:00): 07 decía 20:00–09:00 y C40 deja una sola constante. Sin código de bloqueo el sistema no avisa, y no se usa `scenePhase == .background` porque no distingue bloquear de salir de la app.
- **Los 20, los 40 y los minutos salen del código**: `madrugada.estado` y `ax.la.madrugada` reciben la duración de la receta y `ax.altavoz.pista` el tope de `RoutePolicy`.
- **La regla del nivel** dibuja su recorrido entero en `trazo` y el nivel en `texto-noche`; 07 solo describe "longitud llena = nivel".
- **Noche terminada por la mañana.** La tarea 1 decidió que la mañana nunca quita la pantalla Noche (test `testTheNightPageStaysWhileItsNightIsAlive`): quien abre la app a las 08:00 con Noche delante ve "Terminó a las 23:45" y "Madrugada · 20 min", y al salir llega a la página nocturna. 07 (S5) la fundía sola a la página de día. A decidir por el dueño.
- **`BedtimeEntryOutcome.nothingToPlay` desaparece**: 07 §4.1 pide que "Noche" funcione siempre, y Play ya sube rosa con la mezcla en silencio.

Sin hacer en esta tarea, y por qué:

- **Ajustes** (superficie 18, otro paquete): "Mantener encendida", "Pasar sola a Noche" (1 y 3 min), "Controles visibles de noche", "Mostrar la hora en Madrugada" y "Sin reloj" no tienen interfaz. Rigen los valores por defecto: mientras carga, al bloquear, sin controles visibles, sin hora.
- **Controles visibles de noche** (fila de cuatro botones y deslizador; se activan solos con Control por botón o AssistiveTouch): no están. Con VoiceOver y Control por botón todo es alcanzable por los elementos accesibles; con AssistiveTouch, por sus gestos.
- **Toque ignorado boca abajo**: pide el sensor de proximidad o CoreMotion (C35 lo deja fuera de 1.0).
- **"Nivel bajado al 40 para el altavoz"** (nota de 4 s de 07): la guía no trae la cadena; el nivel se dice con "Sonando · al 40" solo tras el arrastre.
- **Acceso asistido** (`UISupportsFullScreenInAssistiveAccess`), foco de teclado y atajos.
- Sin verificar en dispositivo: VoiceOver y Control por botón sobre las dos pantallas, la entrada al bloquear (el simulador no tiene código de bloqueo), la guarda de 300 ms tras desbloquear, `isIdleTimerDisabled` cargando (en el simulador la batería es desconocida; con "Siempre" se comprobó que se pide), el arrastre con un dedo real y la línea de agua contra el oleaje.

### Tarea 4 · Mezclas, Atajos y Now Playing (17-11-2026)

`MixesSheet` (superficies 12 y 13) sustituye a `SavedMixesView`. La lógica es pura y está probada: `MixesList`, `MixRecipe`, `MixAutoName`, `MixReference` (`MixesLogic.swift`). Estados de depuración `-pageState mixes…` en `PageDebug.swift`.

- **Mezclas** (C09, C18, C20, C23): hoja sobre `hoja`, como Capas, con la barra (el hueco de "Mezclas" vacío, el Disco y "Noche"). "tuyas": la mezcla viva como primera fila mientras es "Esta noche", y las guardadas; "de la casa": las cuatro. Cada fila es el nombre y la receta en palabras, de mayor a menor ("lluvia 55 · rosa 20"), con "· océano es Pro" al final sin acceso; "sonando ahora" en la cargada mientras suena. El toque carga y vuelve a la página: con algo sonando, la mezcla cede bajo la misma noche; en silencio arranca como un Play (08 §4.1). Recortada si lleva Pro, con su título "· sin …", y nunca hoja Pro. El temporizador y la Marea no se tocan.
- **Guardar, renombrar, eliminar, mover**: una sola alerta del sistema con campo (`mixNaming`), desde la fila "Esta noche" o desde el nombre de la página; "Renombrar", "Subir", "Bajar" y "Eliminar" en el menú de cada fila propia y como acciones de VoiceOver; eliminar pide confirmación (`mezclas.eliminar.*`). Guardar conserva las capas Pro a su nivel (C23). Tres gratis: la cuarta dice "pro" en la fila y " · pro" en el menú, y pide la hoja Pro solo si `canSell`. En la página nocturna el toque carga y nada más. Tras guardar desde la página, "Guardada" ocupa la línea de estado 3 s.
- **Identidad tras reinicio**: `MixerModel.loadedMix` (`.house` o `.saved`), guardada con su receta; un nivel editado la borra. La subida del océano por la Marea no cuenta como edición.
- **Atajos** (C43, C10, C03, C05): los cinco de PLAN-SIMPLE §4.3, `PlayLastMixIntent`, `PauseIntent`, `PlayMixIntent(MixEntity)`, `SetTimerIntent(modo)` y `SmallHoursIntent`, con las frases de la guía en `AppShortcuts.xcstrings`. No dicen nada cuando funcionan; si el sonido no arranca, `siri.error`; si la mezcla ya no existe, `siri.mezcla.cual`. Ninguno abre la hoja Pro ni arranca la prueba (`play(startsTrial: false)`). `MixEntity` son las propias y las cuatro de la casa, por nombre sin mayúsculas ni acentos; tras guardar, renombrar, mover o borrar se llama a `updateAppShortcutParameters()`.
- **Now Playing** (superficie 34): el título es el de la página (recortado si procede, "Esta noche" si no tiene nombre, "Madrugada" en Madrugada), `isLiveStream`, y Play y Pausa van por el mismo camino que Noche y Madrugada.

Decisiones tomadas al construir, a confirmar:

- **Mezclas es una hoja**, no una pantalla empujada sobre `negro` (08 §2.1): es lo que pedía el encargo y lo que ya es Capas.
- **La fila "Esta noche" guarda al tocarla**, además de con pulsación larga (la guía solo dice "Mantén para guardarla"). Solo aparece mientras la mezcla viva no tiene nombre y tiene alguna capa.
- **El campo de guardar llega precargado con el nombre automático** (guía §4.2); 08 §2.2 lo dejaba vacío. Un nombre vacío guarda con ese mismo nombre. No se evita repetir un nombre.
- **El nombre automático lee las capas en el orden de Capas** (colores y luego camas), que da "Rosa y lluvia" y "Marrón y hoguera".
- **Dos o más capas Pro en una receta** se dicen una a una ("· trueno es Pro · océano es Pro"): "son Pro" está pendiente en la guía.
- **`mezcla.guardar.titulo`** ("Guardar como mezcla") y las cadenas `atajo.*` (títulos, parámetros y sinónimos de los modos) no están en la guía 10, que no da claves para ellas.
- **`SetTimer` guarda el modo, como la hoja**, con la duración o la hora que ese modo ya tenía. Desaparece "solo por esta noche" y los 60 minutos de reserva del intent antiguo. "Apagado" no arranca el sonido; los otros dos sí. El parámetro `minutes` sigue existiendo para el editor de Atajos y nunca va en una frase.
- **`PlaySoundIntent` (una capa sola) se retira**: no está entre los cinco de PLAN-SIMPLE.
- **Sin descripciones de intent**: la guía no trae esos textos.
- **Agujero hasta S-07**: con la prueba antigua, que empieza con Play, quien solo use Atajos en una instalación nueva tiene todo abierto sin que la prueba empiece. Desaparece al cablear `NightTrial`.
- **`PageStage.setLevels`** (solo depuración) ya no dejaba la mezcla como "Esta noche" desde que un nivel escrito igual no es una edición; ahora hace una edición real primero.

Sin hacer en esta tarea, y por qué:

- **`openAppWhenRun` y `AudioPlaybackIntent`**: los intents de reproducción siguen abriendo la app y son `AppIntent` a secas. La guía pide `false` y `AudioPlaybackIntent` en todos; cambiarlo exige probarlo en un iPhone real.
- **Deslizar para renombrar o eliminar y arrastrar para reordenar** (08 §4.3): piden un `List`; están el menú de la fila y las acciones de VoiceOver.
- **"Guardar en «…»"**, la fila "Ajustes" (superficie 18) y el fundido cruzado de 1,5 s entre mezclas (cambio en el hilo de audio; hoy rige el suavizado del motor).
- **`PlayLayer`, `ExtendTimer`, `Toggle` y `CurrentState`** (C43): fuera de los cinco de PLAN-SIMPLE.
- **README**: sigue describiendo los atajos y el reparto antiguos; se corrige con S-07.
- **Hecho en S-07 (tarea 2)**, y la fila "Ajustes" de Mezclas también.
- Sin verificar en dispositivo: Siri y la app Atajos (frases, entidad, sinónimos, desambiguación), la pantalla de bloqueo ("En directo", título, controles), VoiceOver sobre la hoja y la háptica de guardar. En el simulador se comprobó a mano cargar una mezcla, el menú del nombre, "Vaciar", el menú de una fila y eliminar.

## Corrección de S-06 (17-11-2026)

De la revisión del paquete (audio, modelo, diseño, accesibilidad y producto). Lo cierto y mayor se arregló; lo menor y barato, también. Tests nuevos en `NightCorrectionTests.swift` y en los ficheros de cada superficie.

### Hecho

- **Motor.** Las decisiones de control (querido o no, qué parada sigue pendiente, longitud de la rampa del maestro, arranque desde silencio) viven en `EngineControl`, que usan `SleepAudioEngine` y el motor offline de los tests: ya no hay copia. Un arranque que falla (sesión, grafo o motor) no deja reinicio pendiente y devuelve la sesión. El cambio de frecuencia no vuelve a pedir ningún fundido: `SampleRamp.rescale(by:)` conserva valor, destino y segundos restantes (regla 4.8). El peso de la Marea se disuelve con un `SampleRamp` lineal (regla 4.5): con paso en `Float` se quedaba en 1 a partir de 700 s.
- **Sin actividad periódica** (03 §3.7): el temporizador y Madrugada esperan con un único temporizador de un disparo al siguiente hecho (bajada del Manto, inicio del fundido, minuto de "Fundiendo", fin). `remaining` no se publica: se lee. La hoja y la fila releen los minutos con un `TimelineView` solo mientras están en pantalla. La palabra "inhala / exhala" monta su línea de tiempo solo las tres primeras respiraciones.
- **Modelo.** Play fallido durante una llamada conserva la interrupción (C48); una reanudación no pedida no arranca la prueba; "+15 min" devuelve el nivel aunque el fundido no se hubiera vuelto a pedir; Madrugada en pausa más de 20 min cede a la mezcla y el Atajo "última mezcla" sale de Madrugada; el relevo a Madrugada mueve el maestro en sus 3 s; el tope de 0,4 caduca con su noche (6 h, o al abrir de día con la noche cerrada); quien venía sin temporizador sigue en "Apagado" (marca `sleepnoise.timer.firstUse.v1`); la mezcla del primer uso conserva su nombre tras reiniciar; Noche solo mantiene la pantalla mientras hay una noche abierta; los Atajos con mezcla se registran en cada arranque; la guía de la Marea usa el reloj del modelo.
- **Página.** La línea de agua de la Marea (06 §2.4, 05 §2.3): banda de 120 pt (96 en pantalla corta) que crece hacia arriba desde el borde inferior de la banda del Horizonte, sobre aire que ya estaba; nada se recoloca con o sin Marea. "Seguir por el altavoz" en la segunda línea de estado durante su minuto y "Sonando · al 40" tras reanudar capado, hasta el primer toque (C49). El título recortado nunca se corta en la capa: entero, luego hasta 0,7 de escala, y solo si aún no cabe, el nombre a secas.
- **Hojas.** Temporizador: el bloque de cabecera se decide al abrir y no aparece ni desaparece con la hoja abierta; abre en grande cuando lo lleva; la línea bajo la cifra no repite la cifra (`temporizador.cabecera.fundiendo`, `temporizador.cabecera.manto`, esta solo mientras la bajada está por venir); las dos ruedas, en la columna y al mismo ancho. Marea: la palabra de estado ya no se mueve entre "guiando" y "disolviendo". Mezclas: de noche ninguna receta dice "es Pro" ni "requiere Pro"; la fila "Esta noche" es texto de noche; eliminar es una alerta con "Cancelar".
- **Noche.** Reloj sin AM/PM; atenuado a 0,6; un dedo que nace a menos de 32 pt del borde superior o inferior no es nivel ni toque; un gesto que el sistema se lleva devuelve el nivel y quita la regla; el elemento "Volumen" de VoiceOver mide 44 × 200; la hora hablada se relee cada minuto; el foco entra en la pantalla al cubrir la página y vuelve al nombre al salir; el escape funciona desde cualquier elemento.
- **Resto.** `AccentColor` es `texto` y está declarado en `project.yml` (el cursor de las alertas ya no es azul); plurales de `comun.min.quedan`; `ax.nombre.pista` con el texto de la guía; README (temporizador, mezclas, viento y los cinco Atajos); la mezcla de ejemplo "Siesta de agosto" pasa a "Verano con ventana".

### Decisiones tomadas al corregir, a confirmar

- **"Auriculares" solo cuando lo dice el sistema.** AirPlay, coche y HDMI son "En pausa" a secas. Bluetooth no distingue auriculares de altavoz: cuenta como auriculares.
- **`ax.agua.valor` se retira** y `ax.temporizador.valor` pasa a "%1$@, %2$@" (modo y minutos con el plural de `ax.anuncio.quedan`). Anotado en la guía 10.
- **La línea de agua de la página** no reserva nada por acceso (crece sobre aire) y no se dibuja con tamaños de accesibilidad, donde el Horizonte va pegado a la línea de estado. La palabra "inhala / exhala" de la página no se hizo.
- **El título recortado baja hasta 0,7** (05 §2.1 decía que los nombres de la app no escalan; no está reconciliada).
- **La cabecera del Temporizador no aparece al elegir un modo con la hoja abierta**: la hora se lee detrás, en la página.
- **El maestro al arrancar** se pide con el tiempo de subida (0,8 s o 3 s); con el motor parado sigue siendo una muestra.

### Rechazado

- **"Volver a la página" primero en el orden de VoiceOver**: la guía 10 §5b lo fija quinto y último; 07 no está reconciliada.
- **Pista de "Noche" con la mezcla parada**: la guía no trae la cadena.
- **"Desplegado / plegado" en la fila Duración**: se quitó el rasgo `.isSelected`; la guía no trae esas cadenas.
- **Tinta del valor central de las ruedas**: es la rueda del sistema multiplicada por la tinta; igualarla pide una rueda propia.

### Aplazado

- **Audio, sin paquete asignado.** (a) Nivel de sesión y bajada del Manto comparten una rampa: un arrastre en Noche durante el minuto de la bajada la termina en 50 ms. Pide un campo nuevo en `EngineCommand` (regla 4.9). (b) El relevo de mezcla a Madrugada cruza las ganancias con el suavizado de 20 ms; va con el fundido cruzado de 1,5 s entre mezclas.
- **Condición de publicación (dispositivo real, dueño): `AudioPlaybackIntent` y `openAppWhenRun = false`** en los cuatro Atajos que hoy abren la app. No se cambia sin probarlo con el iPhone bloqueado.
- **S-08 (capturas):** `-pageState nightSpeaker` en AX3 en una pantalla de 667 pt (posible solape de "Seguir por el altavoz" con el estado en dos líneas); el simulador asignado aquí es un iPhone 17 Pro.
- **Dueño:** si "Noche", con la noche ya terminada dentro de `NightWindow`, debe abrir Noche terminada (con "Madrugada · 20 min") en vez de arrancar la mezcla. Hoy Madrugada solo se alcanza con el dedo si Noche ya cubría la página al acabar.
- **Dueño:** los commits del repo público llevan como autor una dirección de correo real; usar la dirección `noreply` de GitHub de aquí en adelante.
- **Sin verificar en dispositivo:** todo lo de VoiceOver de esta corrección (foco, marcos, valores), los gestos de borde del sistema sobre Noche, `isIdleTimerDisabled` cargando, el arranque fallido durante una llamada real y el cambio de frecuencia a mitad de un fundido.

## Ajuste final de S-06 (17-11-2026)

De la crítica visual de las capturas. Los cinco hallazgos eran ciertos y se aplicaron; ninguno se rechazó. Tests nuevos en `LineTiesTests.swift`.

### Hecho

- **Madrugada, últimos 5 min.** Bajo la cifra va solo "Se retira" / "Winding down" (`madrugada.retirada.palabra`): la cifra de 72 pt de encima ya dice los minutos. `madrugada.retirada` ("Se retira · %lld min") sale del catálogo; `ax.madrugada.retirada` no cambia. Anotado en la guía 10 (§2.6, T28 y tabla).
- **Receta de una mezcla.** Ningún segmento se parte por dentro y el punto medio abre el segmento siguiente (`LineTies`): la segunda línea es "· ventilador es Pro", como en la lámina 14. La fila mide 12 + 22 + 2 + 20 por línea de receta + 16: 72 pt con una línea y 92 con dos, medidos en la captura. `lineBox(_:)` da a un texto líneas enteras de la escala.
- **Línea de agua.** Su posición se redondea al píxel (`Grid.pixelRound`) en la hoja Marea, en la página y en Madrugada. Doce capturas en movimiento: 6 px (5 en Madrugada) de tinta llena, sin filas a medias.
- **Noche.** La frase de la primera vez se compone una frase por línea (el catálogo no cambia) y "Mantén pulsado para volver" va 8 pt aparte. Las palabras de estado y "Madrugada · 20 min" parten antes del punto medio.
- **Capturas.** Regeneradas las siete que eran anteriores a la corrección y todas las que tocan estos cambios.

### Decisiones tomadas al ajustar, a confirmar

- **"Se retira" sin cifra se aparta de la letra de C05 y C60**, que fijan `madrugada.retirada` = "Se retira · n min". Se mantiene el estado (palabra y minutos, juntos en pantalla) y se quita la repetición, igual que `temporizador.cabecera.fundiendo`. Si el dueño prefiere la letra, es devolver una clave.
- **Una línea puede empezar por punto medio** (receta, estados de Noche). Antes la regla era la contraria; manda la maqueta.
- **El nombre de la fila de Mezclas sube unos 3 pt** (a 12 pt del borde, como `.r72` de la maqueta); las filas editoriales del resto de la app siguen centradas en su alto.
- **En AX5 la cláusula "ventilador es Pro" puede partir tras el nombre**: entera no cabe en la columna.

### Sin verificar

- La línea de agua en un dispositivo real: a 30 fotogramas por segundo avanza de 2 a 3 px por fotograma; en los extremos del recorrido, donde frena, el paso es de un píxel.
- Pantallas de 375 pt de ancho: las medidas de la receta se calcularon, no se capturaron.

## Lo que S-07 lleva hecho

### Tarea 1 · Modelo y tienda (17-11-2026)

Sin vistas nuevas. La hoja Pro antigua (`PaywallView`) sigue compilando sobre el modelo nuevo, con el botón "Empezar la prueba · 7 noches" y las líneas de resultado de la guía; la tarea siguiente la rehace.

- **La prueba es `NightTrial`.** `TrialClock` y `AccessPolicy.trialDays` se borraron. Empieza solo con `MixerModel.startTrial()`, que pasa por la misma puerta que la hoja Pro (`canSell`): de noche, en la página nocturna y en Madrugada no hace nada. `play()` ya no tiene `startsTrial`: ningún Play ni ningún Atajo la empieza.
- **Se evalúa al empezar una noche nueva** (`startSound`, cuando `nightIsOpen` es falso) y en ningún otro arranque: ni al volver de una interrupción, ni al reanudar una pausa de menos de 20 minutos, ni en Madrugada. El reloj se muestrea al lanzar y al volver a primer plano (`observeClock`), sin cambiar la respuesta.
- **Una instalación nueva es el nivel gratuito.** Antes tenía todo abierto hasta el primer Play. Las capturas de referencia se escenifican con Pro comprado (cabecera vacía, todo abierto), no con una instalación nueva: la primera pantalla real enseña la Marea como "pro". A revisar en S-08.
- **Migración** (`LegacyTrial`): la prueba antigua que había empezado pasa al Keychain tal cual estaba, con el tiempo consumido; la que seguía en curso llega a su propio fin y la agotada sigue agotada. En los dos casos cuenta como usada. La que nunca empezó no deja nada.
- **Cifra de noches** (08 §9.3, a confirmar por el dueño): noches que no han terminado y empiezan (21:00) antes del fin, con tope 7. La noche en curso cuenta hasta las 07:00. El día en que la prueba se agota la cifra es 0 y la cabecera no enseña nada: no hay cadena aprobada para "termina hoy".
- **Lectura fallida del Keychain:** se reintenta al volver a primer plano, al empezar una noche y al tocar "Empezar la prueba" (`NightTrial.reloadIfMissing`).
- **Degradación sin escritura:** al terminar la prueba no se toca ni la mezcla, ni las mezclas guardadas, ni el interruptor de la Marea (test `testTheTrialEndsAtTheNextNightAndWritesNothing`). El modelo se entera solo del cambio de acceso (`PurchaseManager.onAccessChange`); la página ya no lo reenvía.
- **Una revocación (reembolso, fin de En familia) con el sonido puesto espera a que pare.** Antes cortaba en el acto.
- **Tienda detrás de `ProStore`.** `AppStoreProStore` es StoreKit 2; `ScriptedProStore` (solo DEBUG) es el doble de los tests y de los arranques escenificados. Estados: `productState` (cargando, cargado, no disponible), `activity` (comprando, restaurando), `isPurchasePending`, `notice` (nueve líneas) y `receipt` (fecha y En familia). Topes propios: 8 s para el producto y 10 s para restaurar; lo que llega tarde se aplica igual.
- **`SleepNoise.storekit`:** 29,99, Family Sharing, descripciones nuevas. Es solo la tienda local: el precio real sale de App Store Connect.
- **Cadenas:** fuera `trial.chip.daysFormat`, `paywall.trial.*`, `paywall.keepFormat`, `paywall.purchaseFormat`, `paywall.purchaseUnavailable`, `paywall.restore*`, `paywall.nothingToRestore`, `paywall.pending` y `paywall.failed`. Dentro, de la guía 10: `pro.prueba.empezar`, `pro.prueba.estado` (plural), `.ultima`, `.gratis`, `pro.comprar`, `pro.comprar.sin_precio`, `pro.restaurar`, `pro.gracias`, `pro.fallo`, `pro.fallo.sin_confirmar`, `pro.pendiente`, `pro.sin_tienda`, `pro.sin_tienda.silencio` y `pro.restaurar.no`. Siguen en la hoja antigua, hasta que se rehaga: `paywall.title`, `paywall.subtitle`, `paywall.benefit.*`, `paywall.active`, `paywall.once` y `common.close`.
- **README:** corregidos el párrafo de la prueba y los pasos de la tienda local.

### Lo que queda sin hacer o sin verificar

- **StoreKitTest no funciona aquí.** `SKTestSession` se crea, pero cada orden falla con `SKInternalErrorDomain Code=3` bajo `xcodebuild test` en el simulador (iOS 26.5), con los dos inicializadores. Los estados de la tienda se prueban con el doble. `AppStoreProStore` solo tiene test de su tabla de errores: la compra, Pedir para comprar, el reembolso y En familia reales quedan para el sandbox del dueño.
- **La compra o la prueba "que se oyen" entran con el suavizado normal del motor**, no con el fundido de 800 ms de 08 §2.3: pide una rampa por capa en `EngineCommand` (hilo de audio). Tampoco se guarda qué capa abrió la hoja para subirla al empezar la prueba.
- **Nota de "La prueba terminó":** muere con "Entendido" o con el siguiente Play de día. La tercera salida de 08 §2.4 ("la siguiente apertura de día") no está.
- **"Gratis siempre" solo existe tras la prueba**, siete sesiones (guía 10 §2 y este fichero). 08 §2.4 la pone también en una instalación nueva; no se ha hecho, para no cambiar la primera pantalla. A decidir.
- **Vistas:** hechas en la tarea 2 (abajo).

### Tarea 2 · Interfaz (17-11-2026)

`PaywallView` se borró. La lógica de presentación es pura y está probada: `ProSheetContent`, `ProSheetText`, `AppLinks` (`Features/Pro/ProSheetLogic.swift`), `PageTrialNote` y `PageTrialWord.spoken` (`PageLogic.swift`), `SettingsText` y `SettingsProRow` (`Features/Settings/SettingsLogic.swift`). Estados de depuración `-pageState pro…`, `trial…`, `settings…` y `mixesEnd` en `PageDebug.swift`.

- **Hoja Pro** (`ProSheet`, superficies 14, 15 y 33; anatomía de 08 §2.3). Versalita con `displayName`, `displayPrice` en paso 1 ("—" hasta que la tienda responde), "Una vez.", el titular, "con pro" (texturas nombradas y sin contar, Marea, mezclas sin límite, En familia) y "gratis siempre". Pie fijo: "Empezar la prueba · 7 noches" mientras la prueba no se ha usado, Comprar entre las dos únicas hairlines de acento, "Restaurar compra" y "Ahora no", y una línea que es el pie de privacidad o lo que acaba de pasar. Estados en palabras, sin spinner: "Comprando…", "Buscando…", "Pendiente", "Gracias. Todo abierto." (1,5 s y la hoja se cierra sola).
- **Recibo**: el estado comprado de la misma hoja. "{displayName} · gracias · {fecha}" (y "· en familia"), "Gracias. Todo abierto." en el sitio del precio, las mismas listas, sin nada que cueste dinero. "Escribir una reseña" abre la página de la tienda; nunca `requestReview` (hay un test que lee los fuentes).
- **Cabecera de la página**: la palabra solo existe mientras se puede vender. Dentro de `NightWindow`, en la página nocturna y en Madrugada el renglón queda vacío (antes, dentro de la ventana, era texto estático). VoiceOver lee "Prueba, quedan 5 noches" (`ax.prueba.cabecera`).
- **Los dos renglones de una vez**: "Última noche con todo. Mañana, lo gratis sigue gratis." ocupa el sitio de "En silencio" hasta el Play, una frase por línea; "La prueba terminó. Lo que usaste sigue aquí." va bajo la línea de estado con "Entendido". Solo de día, en página de día y en silencio (`MixerModel.visibleTrialNote`).
- **Ajustes** (`SettingsSheet`, superficie 18): hoja que ocupa el sitio de Mezclas al tocar su última fila, "Ajustes" (08 §2.1; única entrada). Lista de PLAN-SIMPLE §4.3: Noche ("Mantener encendida", con el menú del sistema, como las filas de la Marea), Pro (estado y entrada a la hoja), "Lo que no hay" y "Escribir al autor", más el pie de privacidad.
- **"Lo que no hay"** (superficie 32): página empujada dentro de Ajustes. Siete hechos, uno por línea, "No te pediremos que la valores." y el pie.
- **Componentes tocados**: `HairlineAction` (sin hairline inferior cuando la de debajo es de otra fila; etiqueta, valor y pista de VoiceOver), `EditorialRow` (`isInert`: palabras, no botón) y `MenuRow`, que sale de `TideSheet` para que la usen la Marea y Ajustes.
- **`Info.plist`**: `LSApplicationQueriesSchemes` con `mailto`, para que `canOpenURL` pueda decir si hay un cliente de correo. Sin eso la fila "Escribir al autor" no aparecería nunca.

### Decisiones de la tarea 2, a confirmar

- **Sin dirección y sin identificador, dos cosas no se ven.** `AppLinks.appStoreID` y `AppLinks.authorAddress` son cadenas vacías: "Escribir una reseña" y "Escribir al autor" no aparecen hasta que el dueño dé el identificador de la app en la tienda y una dirección pública. Rellenarlas es todo lo que hace falta.
- **Fila Pro de noche**: palabras, sin precio y sin toque. 08 §2.7 la deja con el precio como texto estático; aquí manda "de noche nada vende".
- **Nombre antes de que la tienda responda**: "Pro" (la palabra de `comun.pro`) en la versalita de la hoja y en la fila de Ajustes. Con la tienda respondida una vez, el nombre queda guardado.
- **"En familia"** se lista salvo que el producto cargado diga que no se comparte.
- **Háptica fuera de Ajustes**: no hay base (el código solo tiene la háptica de los controles, con su puerta nocturna; la de la Marea de C35 no existe).
- **"Lo que no hay" sin el párrafo del registro** (`lo_que_no_hay.diagnostico`): en 1.0 no hay diagnóstico (PLAN-SIMPLE §4.4) y la frase afirmaría algo que no existe.
- **Sin fila de versión**: no está en la lista de PLAN-SIMPLE y `ajustes.version` pide el tamaño en MB fijado en build.
- **`pro.prueba.empezar.nota`** solo se ve desde AX3, en la columna (08 §2.3 y §5d); en el resto es la pista de VoiceOver. La guía 10 §2.8 la pone bajo el botón.
- **`pro.pendiente.boton`** ("Pendiente" / "Pending") viene de 08 §5e, donde está marcada como pendiente de la guía.
- **Con texto de accesibilidad** el pie fijo guarda la prueba, Comprar y Restaurar; "Ahora no" y el pie de privacidad pasan al final de la columna. Una línea de resultado larga en AX3 lleva el pie fijo a algo más de la mitad de la hoja.
- **La hoja con la prueba sin usar desplaza unos 40 pt en un iPhone 17 Pro**: 08 cuenta 808 pt útiles sin el área del indicador de inicio.
- **De la hoja Pro abierta desde Ajustes se vuelve a Ajustes**; desde Marea y Mezclas, a la página (como ya era).

### Sin verificar

- **VoiceOver real**: etiquetas, valores, pistas y rasgos están puestos y la lógica probada, pero nadie ha recorrido las pantallas con VoiceOver.
- **La compra de verdad**: los estados de la hoja se han visto con la tienda de guion (`ScriptedProStore`), no con StoreKit. Comprar, restaurar, Pedir para comprar, el reembolso y En familia quedan para el sandbox del dueño.
- **Pantallas de 375 pt y de 667 pt de alto**: en una pantalla corta la nota "La prueba terminó" no cabe sobre el Horizonte y lo empuja mientras está; no se ha capturado. Tampoco de xL a xxxL, donde 08 §5d quiere la nota bajo el Horizonte.
- **`mailto:` y el enlace a la tienda**: con las constantes vacías no se pueden probar.
- Capturas en `.build/shots/` (`pro-*` y `settings-*`, español e inglés, AX3 y tres con Aumentar contraste), sin versionar.

