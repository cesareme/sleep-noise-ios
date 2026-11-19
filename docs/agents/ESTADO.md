# Tablero de estado · SleepNoise 1.0

Última actualización: 17-11-2026. Plan vigente: `docs/PLAN-SIMPLE-1.0.md` (12 paquetes, 4 semanas). Este tablero sustituye al de 67 paquetes del plan anterior.

Solo lo edita Claude Code, en el mismo PR que cambia un estado o en el siguiente. Si el tablero y el plan difieren en autor o revisor, manda el plan.

Estados: pendiente, en curso, en revisión, cambios, integrado, atascado, cancelado.

Resumen: 9 integrados (S-01 a S-07, S-09 y S-10), 1 en revisión (S-08), 2 pendientes que dependen del dueño (S-11 beta y S-12 envío). Por indicación del dueño, Claude hizo también los paquetes asignados a Cursor. Guía del dueño: `docs/lanzamiento/`.

| Id | Paquete | Autor | Revisor | Semana | Rama | Estado | PR |
|---|---|---|---|---|---|---|---|
| S-01 | `scripts/verify.sh`, CI de macOS, `AGENTS.md` corto, solo iPhone | Claude | Cursor (lectura) | 1 | `claude/s-01-verify-ci` | fusionado 17-11 | 5 |
| S-02 | Rescate del PR #3: motor, texturas, modelo e intents compilando | Claude | Cursor (CI) | 1 | `claude/s-02-rescate-pr3` | fusionado 17-11 | 6 |
| S-03 | Lógica pura con tests: `NightWindow`, reloj de la prueba, receta de Madrugada (mitad A) y `AccessPolicy` (mitad B) | Claude (era Cursor) | Claude | 1 | `claude/s-03-logica-pura` | fusionado 17-11 | 8 |
| S-04 | Tokens Grafito, Horizonte (con nivel RMS desde el hilo de audio), Disco, filas, página principal y Capas | Claude | Cursor (CI) | 2 | `claude/s-04-pagina-grafito` | fusionado 17-11 | 10 |
| S-05 | Códec de mezclas v2, mezclas de la casa, políticas de interrupción y de ruta | Claude (era Cursor) | Claude | 2 | `claude/s-05-mezclas-politicas` | fusionado 17-11 | 9 |
| S-06 | Noche, Madrugada, Temporizador, Marea y Mezclas en Grafito (con ganancia maestra con rampa) | Claude | Cursor (CI) | 2-3 | `claude/s-06-noche-temporizador` | fusionado 17-11 | 11 |
| S-07 | Hoja Pro, prueba de 7 noches, recibo y estados de la tienda; sandbox | Claude | Cursor (CI) | 3 | `claude/s-07-pro-prueba` | fusionado 17-11 | 14 |
| S-08 | Catálogo de cadenas EN y ES, test de interfaz que genera las capturas | Claude | Cursor (CI) | 3 | `claude/s-08-cadenas-capturas` | en revisión | - |
| S-09 | Ficha de App Store EN y ES, notas para revisión, "Lo que no hay", política de privacidad | Claude (era Cursor) | Claude + dueño | 3 | `claude/s-09-ficha` | fusionado 17-11 | 12 |
| S-10 | Icono "La regla y la marea" | Claude | Dueño | 3 | `claude/s-10-icono` | fusionado 17-11, pendiente de aprobar por el dueño | 13 |
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
- `observe(now:)` se llama al lanzar la app y al volver a primer plano. Sin esas llamadas, atrasar el reloj antes de cada Play alarga la prueba sin límite. **Sigue abierto** (corrección de S-07): atrasar la fecha antes de abrir la app cada tarde la alarga igual, porque la primera muestra ya ve el reloj falso. Ver "Tarea 3", al final.
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
- *Cerrada el 17-11-2026 (D-32, `LayerCap`): ver "Decisiones del dueño aplicadas".* Una mezcla guardada con más de seis capas se carga entera: el tope solo impide añadir la séptima (ver "Lo que la corrección de S-04 aplaza").

## Lo que la corrección de S-04 aplaza

De la revisión de la página y de Capas (17-11-2026). Lo que sigue no se arregló en S-04 porque es de otro paquete o porque lo decide el dueño.

### Preguntas al dueño

- **Fondo de Capas de noche.** Abierta desde la página nocturna, Capas cambia toda la tinta (título incluido), pero la hoja entera en `#1C1C1E` enciende la pantalla. 03 §4.10 la quería negra por eso; PLAN-SIMPLE §4.1 prohíbe hojas negras sobre negro. ¿Capas sobre `negro` solo de noche?
- **Pomo del interruptor de Marea.** *Cerrada en la corrección de S-06: `GrafitoToggleStyle`, dibujado con tokens.* 03 §4.12 y 04 §9 #14 cierran "Toggle del sistema con `.tint(texto)`", y así está. En iOS 26 el pomo es una píldora blanca de unos 37 × 23 pt: lo más luminoso de la página nocturna, y encendido queda blanco sobre pista `texto`. Se mantiene el del sistema como coste aceptado; la alternativa es un `ToggleStyle` propio dibujado con tokens. Capturas `page-tide` y `page-nightTide`.
- **Tope de seis (C19) fuera de `setLevel`.** *Cerrada el 17-11-2026 (D-32, `LayerCap`): ver "Decisiones del dueño aplicadas".* La Marea ya no sube el océano si suenan seis. Quedan dos vías: (a) quien recupera el acceso con capas Pro guardadas a nivel puede pasar a sonar con más de seis; (b) una mezcla guardada, o los niveles de una versión anterior, con más de seis se cargan enteros. Hace falta una sola regla en un solo sitio. Propuesta de la revisión: `currentGains()` deja sonar las seis capas incluidas más altas y las demás conservan su nivel sin sonar, como una capa Pro sin acceso.
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
- **Noche terminada por la mañana.** *Cerrada el 17-11-2026 (D-52, `leaveNightScreenIfOverByDay`): ver "Decisiones del dueño aplicadas".* La tarea 1 decidió que la mañana nunca quita la pantalla Noche (test `testTheNightPageStaysWhileItsNightIsAlive`): quien abre la app a las 08:00 con Noche delante ve "Terminó a las 23:45" y "Madrugada · 20 min", y al salir llega a la página nocturna. 07 (S5) la fundía sola a la página de día. A decidir por el dueño.
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
- **Tienda detrás de `ProStore`.** `AppStoreProStore` es StoreKit 2; `ScriptedProStore` (solo DEBUG) es el doble de los tests y de los arranques escenificados. Estados: `productState` (cargando, cargado, no disponible), `activity` (comprando, restaurando), `isPurchasePending`, `notice` (nueve líneas) y `receipt` (fecha y En familia). Tope propio: 8 s para el producto; lo que llega tarde se aplica igual. Restaurar no tiene tope (tarea 3).
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
- **`pro.prueba.empezar.nota`**: cambiado en la tarea 3. Es la línea del pie fijo mientras la prueba está en oferta, a la vista en todos los tamaños (guía 10 §2.8, C07).
- **`pro.pendiente.boton`** ("Pendiente" / "Pending") viene de 08 §5e, donde está marcada como pendiente de la guía.
- **Con texto de accesibilidad** el pie fijo guarda la prueba, Comprar y Restaurar; "Ahora no", la nota de la prueba o el pie de privacidad y la línea de resultado pasan al final de la columna (tarea 3: el pie ya no cambia de alto).
- **La hoja con la prueba sin usar ya cabe sin desplazar** en 402×874, 393×852 y 390×844, en español y en inglés (tarea 3). En 375×667 desplaza, como prevé 08.
- **De la hoja Pro abierta desde Ajustes se vuelve a Ajustes**; desde Marea y Mezclas, a la página (como ya era).

### Sin verificar

- **VoiceOver real**: etiquetas, valores, pistas y rasgos están puestos y la lógica probada, pero nadie ha recorrido las pantallas con VoiceOver.
- **La compra de verdad**: los estados de la hoja se han visto con la tienda de guion (`ScriptedProStore`), no con StoreKit. Comprar, restaurar, Pedir para comprar, el reembolso y En familia quedan para el sandbox del dueño.
- **Pantallas de 375 pt y de 667 pt de alto**: en una pantalla corta la nota "La prueba terminó" no cabe sobre el Horizonte y lo empuja mientras está; no se ha capturado. Tampoco de xL a xxxL, donde 08 §5d quiere la nota bajo el Horizonte.
- **`mailto:` y el enlace a la tienda**: con las constantes vacías no se pueden probar.
- Capturas en `.build/shots/` (`pro-*` y `settings-*`, español e inglés, AX3 y tres con Aumentar contraste), sin versionar.

### Tarea 3 · Corrección tras la revisión (17-11-2026)

Treinta hallazgos de tres revisores. Lo que cambió, por zonas:

- **Restaurar ya no tiene tope.** `AppStore.sync()` pide la contraseña de la cuenta de Apple; con el tope de 10 s la hoja decía "La tienda no responde" con el diálogo delante, soltaba el botón (un segundo toque lanzaba otro `sync`) y el resultado tardío se perdía. Ahora "Buscando…" dura lo que tarde App Store y la línea que se escribe es la que toca (`.restored`, `.nothingToRestore`, cancelado o sin tienda). Coste: si `sync()` no volviera nunca, Comprar y Restaurar quedarían sin responder hasta el siguiente arranque; "Ahora no" sigue cerrando la hoja.
- **Una lectura vieja de derechos no deshace una compra.** `refreshEntitlements` descarta un "nada" o un "no da derecho" si Pro se concedió después de pedir la lectura (contador `grantCount`) o si hay una compra en curso. El doble `ScriptedProStore` puede retener `currentEntitlement` (`holdsEntitlement`).
- **El fin de la prueba se dice aunque se descubra en un arranque** (`sleepnoise.trial.endEvaluated.v1`): una prueba que vence entre dos lanzamientos, sin Play en medio, nace ya terminada y antes no dejaba nota. La prueba antigua que ya estaba agotada al migrar no la deja: terminó hace tiempo.
- **Una prueba antigua sin migrar cuenta como usada**: la migración se reintenta al volver a primer plano, al empezar una noche y al tocar "Empezar la prueba", y mientras las claves antiguas sigan ahí no se concede otra.
- **Una sesión gratis solo cuenta si suena** (`sessionDidStart()`). La evaluación sigue yendo antes del sonido, a propósito: la mezcla debe sonar ya recortada.
- **La puerta nocturna cubre lo que ya estaba en pantalla.** `MixerModel` despierta una vez en cada borde de la ventana (21:00 y 07:00, `NightWindow.nextBorder`) mientras la app está delante: cierra la hoja Pro y publica `saleClock`, que hace que la página y Ajustes vuelvan a leer `canSell` (palabra de la prueba, nota, precio de la fila Pro). Comprar pasa por `MixerModel.purchasePro()`, con la misma puerta que la hoja.
- **`StoreKitError.unsupported`** (iOS 18.4) ya solo se nombra tras `#available`; el resto del `switch` tiene `default` (no confirmado).
- **Hoja Pro.** Renglones de "con pro" a 36 pt (el primero, con detalle, a 40 desde el ajuste final) y la lista de "gratis siempre" pegada a su cabecera. El pie reserva el alto de la línea más larga que puede decir en ese ancho y ese idioma (textos ocultos), no 60 pt fijos. `pro.prueba.empezar.nota` es la línea del pie mientras "Empezar la prueba" existe. Con texto de accesibilidad la línea de resultado va al final de la columna y la columna se desplaza hasta ella: el pie no cambia de alto. El texto del pie fijo no crece más allá de AX3. Restaurar y "Ahora no" comparten fila solo si caben en una línea cada uno; si no, se apilan. El recibo pone "· en familia" en su propia línea (la reserva de dos líneas para "Gracias. Todo abierto." se quitó en el ajuste final). La hoja no se puede arrastrar mientras dice "Comprando…" y al abrirse borra un aviso que quedara de una visita anterior.
- **VoiceOver.** El título del recibo y la lista gratis se leen sin puntos medios y con el mes entero; la fila Pro de Ajustes lee el nombre como etiqueta y "gracias, 16 de noviembre de 2026" como valor. Los anuncios de la hoja van con prioridad alta; con VoiceOver "Gracias" dura 3 s, y el anuncio de la prueba se publica 0,7 s después de empezar a cerrarse la hoja.
- **Ajustes.** El valor de "Mantener encendida" va en el paso 7, como el de la fila Pro (`MenuRow.valueStep`; la hoja de la Marea no cambia). Sin precio, la fila Pro no lleva nada a la derecha. "En familia" es el subtítulo de la fila. "Lo que no hay" ya no repite el pie de privacidad.
- **Documentos.** `docs/ROADMAP.md` (producto, notas para revisión, paso de `AppLinks`), `README.md` (la prueba es una por dispositivo) y 08 §2.3, §3, §4.5, §5d y §5e (restaurar sin tope, nota de la prueba, AX).

Tests: 622 (suelo en `scripts/verify-min-tests.txt`).

### Decisiones de la tarea 3, a revisar

- **La nota de la prueba ocupa el sitio del pie de privacidad** mientras "Empezar la prueba" existe: "Sin suscripción. Sin cuenta. Sin rastreo." no se lee en la hoja Pro de una instalación nueva (sí con la prueba usada, en el recibo y en Ajustes). Las dos líneas no caben sin que la columna vuelva a cortarse.
- **Una compra empezada antes de las 21:00 se termina**: la hoja no se retira de debajo de la confirmación de App Store; si acaba en compra dice "Gracias" y se cierra sola, y si no, se cierra en silencio. Restaurar no pasa por la puerta: no es vender.
- **"Lo que no hay" sin pie** contradice la letra de 08 §2.10; el pie sigue en Ajustes y en la hoja Pro.
- **Tope de AX3 en el texto del pie fijo** de la hoja Pro (no en la columna).
- **El recibo en español deja una línea vacía** bajo "Gracias. Todo abierto.": es el precio de que los dos idiomas compartan cotas.
- **Con el recibo en familia la columna baja una línea** respecto al recibo propio (la segunda versalita). Nadie ve los dos.
- **En AX, las versalitas y la fila Pro parten antes del punto medio** ("· gracias", "· 16 nov 2026"), nunca después.

### Aplazado: necesita al dueño

- **Restaurar de noche** (mayor). *Cerrada el 17-11-2026 (D-08, `SettingsRestoreRow`): ver "Decisiones del dueño aplicadas".* De 21:00 a 07:00, en la página nocturna y en Madrugada no hay forma de llegar a "Restaurar compra": solo vive en la hoja Pro. Dos salidas: (a) una fila "Restaurar compra" en Ajustes › Pro cuando no hay Pro y no se puede vender, sin precio ni entrada a la hoja; (b) aceptar el hueco. En los dos casos las notas para revisión (S-09) dicen que la hoja Pro solo se abre de 07:00 a 21:00 de la hora del dispositivo y por dónde se llega (ya está en `docs/ROADMAP.md`).
- **Nombre antes de que la tienda responda**: "Pro" (`comun.pro`) en la versalita de la hoja y en la fila de Ajustes hasta la primera respuesta de la tienda en esa instalación. Es la palabra del nivel, no un nombre de producto; roza "el nombre sale de StoreKit". Falta el sí del dueño o la alternativa (título vacío).
- **`pro.pendiente`** ("Pendiente de aprobación familiar…") atribuye todo estado pendiente a Pedir para comprar, y StoreKit devuelve `.pending` también con la autenticación reforzada del banco. Propuesta, sin aplicar porque es copy cerrado de la guía 10 §5e.10: "Pendiente de aprobación. Se abrirá solo cuando llegue." / "Waiting for approval. It will open on its own."
- **El recibo no tiene control de cierre** ("Ahora no" no existe en él), igual que Ajustes (08 §9.13): no hay cadena de cierre en el catálogo. Con VoiceOver queda el gesto de escape; con Control por botón, el del sistema.
- **"Lo que no hay" usa el botón de volver del sistema**: en iOS 26 es un círculo de cristal, lo único redondo de la hoja; en iOS 17 y 18 no está capturado. Alternativa: ocultarlo y poner una `TextAction` "Ajustes".
- **Háptica fuera de Ajustes** se aparta de PLAN-SIMPLE §4.3 (superficie 18): falta el sí explícito o la nota en el plan.
- **`AppLinks` vacío**: sin identificador ni dirección, 1.0 saldría sin "Escribir una reseña" ni "Escribir al autor". Está en la lista de envío de `docs/ROADMAP.md`; nada lo impide en código.
- **Atrasar el reloj antes de abrir la app** sigue alargando la prueba. Cerrarlo pide un reloj que la persona no pueda mover (el reloj continuo del sistema, guardado en el registro), y eso toca el manifiesto de privacidad (categoría de tiempo de arranque): decisión del dueño.

### Aplazado a S-08 y S-09

- **S-08:** las capturas de referencia de la página siguen escenificadas con Pro comprado; la página de una instalación nueva (`-pageState restFree`) ya se puede capturar. Capturas en 375 pt de xL a xxxL.
- **S-09:** la ficha y las notas para revisión salen de `docs/ROADMAP.md`, ya al día con el reparto de 1.0.

### Sin verificar tras la tarea 3

- **Dispositivo y sandbox**: el orden real en que StoreKit entrega la compra y la lectura de derechos, cuánto tarda el diálogo de `AppStore.sync()`, y `StoreKitError.unsupported` en iOS 17.0 a 18.3 (solo se ha ejecutado en el simulador de iOS 26.5).
- **VoiceOver real**: la prioridad alta de los anuncios y los 3 s de "Gracias" no se han oído.
- **El despertar de las 21:00** está probado por su efecto (`nightWindowChanged()` y `NightWindow.nextBorder`), no esperando a la hora.
- **Capturas** (`.build/shots/`, sin versionar): hoja Pro en 402×874, 393×852, 390×844 y 375×667, AX3 y AX5 también en 375, xxxLarge, la hoja sobre Ajustes y sobre Capas y la página de una instalación nueva. Los simuladores de 393, 390 y 375 se crearon para la ocasión y se borraron.

## Ajuste final de S-07 (17-11-2026)

De la crítica visual de las capturas. Los cuatro hallazgos eran ciertos y se aplicaron; ninguno se rechazó. Todo en `SleepNoise/Features/Pro/`; no cambia ninguna cadena. Test nuevo: `testTheFootDrawsItsOwnEdgeOnlyWhereNoActionDoes` (`ProSheetTests.swift`).

### Hecho

- **La columna de la oferta cabe en 393 y 390 pt.** El detalle de "Todas las texturas" va en el paso 8 (13/18, `texto2`), el de la nota, como pide 10 §2.8: la hoja queda en seis estilos y el detalle en español cabe en una línea. Su fila mide 40 (22 + 18) y el titular queda a 16 de la primera hairline, no a 24. Aire medido en las capturas entre la última línea de "gratis siempre" y la hairline del pie: 17,6 pt (EN 393), 21,6 (EN 390), 33,0 (ES 393), 37,0 (ES 390), 36,6 (EN 402) y 52,0 (ES 402). Antes: 5,6, 9,6, 6,6 y 10,6 en los cuatro primeros.
- **El pie del recibo y el de "Gracias" tienen borde superior**: una hairline de `trazo-hoja` con el margen de 20 pt (`ProSheetContent.footOpensWithRule`), dibujada sobre el pie, sin sumarle alto. Con Aumentar contraste sale en `#3A3836` (leído de la captura).
- **El recibo no reserva una segunda línea para "Gracias. Todo abierto."**: la caja mide lo que mida el idioma. En español lo de debajo sube 34 pt; en inglés no cambia.
- **Pantallas con botón de inicio (375×667).** El indicador de desplazamiento del sistema parpadea al abrir la hoja cuando la columna no cabe (`scrollIndicatorsFlash(onAppear:)`; visto en una captura a menos de 1 s del arranque, y ausente en 393, donde cabe). Sin indicador de inicio, el aire bajo la última línea del pie es de 16 pt, no de 6.
- **Documentos.** 08 §2.3: el detalle de texturas es paso 8.
- **Capturas.** Regeneradas todas las de la hoja Pro (`pro-*` salvo `pro-*-page-*`) en 402, 393, 390 y 375 pt, y una nueva, `pro-es-contrast-receipt`. Los simuladores de 393, 390 y 375 se crearon para la ocasión y se borraron.

Tests: 623 (suelo en `scripts/verify-min-tests.txt`).

### Decisiones tomadas al ajustar, a confirmar

- **La hairline del pie es una capa sobre el pie, no su primer elemento**: así el pie mide lo mismo con ella y sin ella y nada se mueve cuando la hoja da las gracias.
- **El alto de 40 de la fila con detalle escala con el texto** (`@ScaledMetric` sobre el cuerpo), como los 36 de las demás.
- **El recibo deja de compartir cotas entre idiomas**: "Una vez." queda 34 pt más arriba en español que en inglés.
- **En 375×667 el pie corta ahora "Mezclas sin límite" a media altura** (antes cortaba entre dos renglones). Lleva hairline encima y el indicador parpadea; es el corte normal de una lista bajo una barra fija.
- **El dibujo de 08 §2.3 conserva sus cotas antiguas** (filas de 44 y 24 pt sobre la primera hairline): solo se corrigió el paso del detalle. Redibujarlo queda para quien cierre las láminas.

### Sin verificar

- El parpadeo del indicador y los 16 pt del pie en un iPhone SE real (solo simulador de iOS 26.5).
- Que la columna no se desplace nada en 393 y 390 pt: se deduce de las medidas (cabe con 17,6 pt de sobra), no se arrastró.

## Lo que S-08 lleva hecho (17-11-2026)

Rama `claude/s-08-cadenas-capturas`, apilada sobre S-07.

### Hecho

- **Catálogo auditado por test** (`CatalogAuditTests`, sobre los dos `.xcstrings` y los fuentes Swift): toda clave en inglés y español y en ningún idioma más, todo valor en estado traducido, mismos especificadores de formato en los dos idiomas, parámetros de las frases de Siri iguales a los de su clave, plural donde una cifra cuenta minutos o noches, ninguna clave huérfana, ninguna clave leída que no exista, ningún texto de interfaz escrito en Swift fuera de `#if DEBUG` y de los `#Preview`, y nada del reparto antiguo. La auditoría no encontró claves huérfanas ni literales a mano: el catálogo ya estaba completo. Un cambio: `ax.la.madrugada` pasa a plural, como las demás cadenas habladas con minutos.
- **Lint de copy** (`CopyLintTests`): las dos listas negras de la guía 10 (§0.4 y §0.5) enteras, por idioma y sobre valores; cifras de precio, porcentajes, recuentos de texturas, exclamaciones, emojis, interrogaciones fuera de sus dos claves y dígitos escritos a mano (solo "7 noches", "+15 min" y el singular "1 noche"). Trece falsos positivos declarados uno a uno, cada uno atado a su clave, su idioma y su frase; uno declarado que deje de encontrarse hace fallar el test. Los titulares de las capturas (`docs/store/ficha-*.md`) pasan por el mismo lint.
- **La contradicción de "Until I sleep" está cerrada** en la guía 10 (§0.2 y §0.5): el nombre del modo es "Until I sleep" (§5e.6, C15, reconciliación §3) y lo vetado es la forma larga anterior, "Until I fall asleep", junto con "Sleep timer". El sinónimo de Siri `atajo.modo.dormirme.sinonimo` ("until I fall asleep") queda como falso positivo declarado: Siri lo entiende y nunca se ve.
- **Capturas de tienda**: `scripts/screenshots.sh` y `scripts/screenshots/ShotComposer.swift` (notas en `scripts/screenshots/README.md`). Doce PNG de 1320 × 2868 px en `.build/store-shots/<idioma>/`, con el titular de la ficha compuesto sobre el lienzo de 11 §2.2, más la pantalla sola en `raw/`. Estados nuevos: `storePlaying`, `storeLayers`, `storeTide`, `storeNight`; `-storeShot` oculta la barra de estado y el indicador de inicio. Las doce se miraron una a una en ES y EN.
- **La segunda línea de la captura 3 cabe**: "Arrastra sobre el nombre para cambiar el nivel." mide 355 pt de 376 a 17 pt (la cifra anterior, 330, salía de una fuente creada a 51 pt; ver la corrección). No hace falta la variante corta que 11 §9 dejaba pendiente.
- **Firma sin datos en el repo**: `Config/Signing.xcconfig` (versionado) incluye `Config/Local.xcconfig` (ignorado por Git) si existe. Sin él, simulador y CI compilan igual.
- **Noche en AX3 sobre 667 pt** (pendiente de S-06): el solape existía, en español y en inglés. Ahora lo que Noche enseña se dispone por encima de sus acciones y el estado baja de tamaño (hasta la mitad) antes de meterse bajo "Seguir por el altavoz"; la hora conserva el suyo. Mirado en un simulador de iPhone SE (3.ª generación) de AX1 a AX3 y en 956 pt de Large a AX5.
- **Página en 375 pt de xL a xxxL** (pendiente de S-07): mirada en ES y EN con instalación nueva y con prueba; nada se solapa ni se corta. La fila del Temporizador queda bajo la barra y se alcanza desplazando.

### Decisiones de S-08, a confirmar

- **La captura 1 es de tarde (20:15), no de las 23:57 de 11 §3.2**: dentro de `NightWindow` la página no nombra la prueba, y la captura la necesita ("prueba · quedan 6 noches"). Las capturas 3 y 4 van a la misma hora.
- **La captura 2** era una instalación nueva tal cual (`restFree`, "Rosa y lluvia"). Cambiada en la corrección: ver abajo.
- **La pantalla de dentro** era la de 6,9 pulgadas a 0,764. Cambiada en la corrección a la de un iPhone 17 Pro a 0,836: ver abajo.
- **"Small hours" sigue con minúscula en la segunda palabra**, como fija la guía (§0.2, §5e.8), también en los títulos de los Atajos.
- **El inglés no se ha reescrito**: los valores coinciden letra a letra con la guía 10 §5e. Las cadenas que conviene que lea un hablante nativo de en-US están en el informe de entrega del paquete y aquí abajo.

### Para un hablante nativo de en-US

`temporizador.dormirme` "Until I sleep" (un nativo diría "Until I'm asleep" o "Until I fall asleep"; lo fija C15) · `temporizador.manto` "Blanket" (reconciliación §6.4) · `capas.seccion.camas` "beds" (en una app de dormir se lee como camas de verdad; lo fija el glosario) · `madrugada.titulo` "Small hours" · `mezclas.vacio` "Tonight’s mix is saved from its name." · `capas.cabin.detalle` "aircraft at cruise" · `capas.campfire.detalle` "embers, no crackle" · `marea.retirada` "It has receded. The sea goes on." · `siri.mezcla.cual` "Which of your mixes?" · `mezcla.casa.marron_hoguera` "Brown and fire" · `lo_que_no_hay.resena` "We won’t ask you to rate it." · titular de la captura 4 "The sea breathes six times a minute." Las demás de la primera lista se reescribieron en la corrección.

### Abierto

- **Noche en AX4 y AX5 sobre 667 pt con la oferta del altavoz**: el estado, ya a la mitad de tamaño, sigue tocando "Seguir por el altavoz". Pide la disposición apilada de 07 §6 (reloj arriba, Horizonte debajo), que no está construida. "Terminó a las…" con "Madrugada · 20 min" en AX5 queda muy justo.
- **El titular y la segunda línea de la captura 1** ("Un solo pago." / "sin tarjeta") siguen pendientes del sí del dueño por la directriz 2.3.7 (`docs/store/README.md`). Ver "Aplazado: necesita al dueño" en la corrección.

### Sin verificar

- Las capturas en App Store Connect y en un iPhone real; el juego es-419.
- El cambio de Noche en un iPhone SE real y con VoiceOver.
- La firma con un equipo de verdad: sin `Config/Local.xcconfig` todo compila igual; con él no se ha archivado nada.

## Corrección de S-08 (17-11-2026)

Diecinueve hallazgos de la revisión. Todos comprobados contra el código, el catálogo y las doce capturas; ninguno era falso. Las doce capturas se regeneraron y se miraron una a una. `scripts/verify.sh` en verde con 657 tests (suelo subido de 650 a 657).

### Hecho

- **"A la 1:30", no "a las 1:30".** Nueve cadenas fijaban "a las %@" / "hasta las %@" y la hora llega como "1:30". Cada una tiene ahora una segunda clave con el sufijo `.una` ("Se funde a la %@"); la elige `HourPhrase.key(_:at:)` (`SleepNoise/Design/HourPhrase.swift`) mirando la hora ya formateada, así que vale en 24 horas ("1:30", "01:30"; no "13:30") y en 12 ("1:30 p. m."). `HourPhraseTests` pasa 01:30 y 13:30 por la página, Noche, el Temporizador y la Marea, y comprueba que ninguna otra cadena española fija "las" delante de un `%`.
- **"SleepNoise Off" ya no es una frase de Siri.** La segunda variante de `SetTimer` era "${applicationName} ${mode}": con el modo Apagado quitaba el temporizador y dejaba el sonido toda la noche. Ahora es "${applicationName} timer ${mode}" / "Temporizador ${mode} en ${applicationName}" (código, catálogo y guía §5e.14).
- **El lint caza la afirmación más corriente**: `(duerm|dorm|descans)\w* mejor`; `sleep\w* better`, `better (night|rest)`, `deep(er|ly)? sleep`, `sleep\w* deep\w*`. Pasa por todos los bloques de texto de las dos fichas, no solo por los titulares, con sus diez falsos positivos declarados (las ausencias, "sin suscripcion" en las palabras clave y los diagnósticos de la opción A de las palabras clave). `siete .*pro` pasa a `siete (\w+ ){0,2}pro`. `testNoMedicalClaimsInEitherLanguage` mira valores y palabras enteras, no el JSON crudo ("oscura" casaba con "cura "). La guía ya no declara "no close strikes".
- **Signos tipográficos**: ’ en los diecisiete valores ingleses que llevaban apóstrofo recto, “%@” y «%@» en `mezclas.eliminar.titulo`, y en los bloques de `ficha-en.md`. `CatalogAuditTests` y el lint de las fichas fallan con un `'` o un `"` rectos.
- **Inglés reescrito** (catálogo y guía §5e): "trial · final night" y "Final night with everything…" ("last night" es anoche); "Start at 12 per minute"; "no card is needed"; "The purchase didn’t go through. Nothing was charged."; "…Restore purchase will open Pro."; "Pro opens on its own once it’s approved."; "…and uses no power."; "Opens your email app."
- **VoiceOver**: el nivel de una fila tiene acciones propias, `ax.nivel.subir` / `.bajar` ("Increase" / "Decrease"; "Move up" / "Move down" quedan para reordenar mezclas); las pistas de pulsación larga dicen el gesto entero ("Toca dos veces y mantén pulsado para volver." / "Double-tap and hold to go back."); "Ajustar con deslizador"; "Apagada, requiere Pro", como la fila.
- **`capas.fan.detalle`** deja de repetir el nombre: "lejano y constante" / "far and steady".
- **Las capturas 1 y 2 ya no son la misma página.** La 2 usa el estado nuevo `storeFirstUse`: sin compra ni prueba, en silencio, "Esta noche" con Lluvia 30 · Rosa 50, que es lo que dibujan 11 §2.4 y su §12 (C33), y conserva "Apagada · pro". La 1 sigue con "Rosa y lluvia" (Lluvia 55 · Rosa 20) sonando. `StoreShotTests` falla si las dos vuelven a llevar los mismos niveles.
- **El script trabaja en un simulador suyo.** `scripts/screenshots.sh` crea uno (`xcrun simctl create`, tipo "iPhone 17 Pro"), lo pone en oscuro y lo borra al acabar, también con Ctrl-C, con un fallo o si lo matan (`trap cleanup EXIT`). Ya no elige un simulador por nombre ni toca el de otro; uno existente solo con `SN_SHOT_UDID`. Un simulador recién creado enseña avisos del sistema encima de la app (salió "Ready for Apple Intelligence" sobre la captura 2): cada pantalla se toma dos veces con ocho segundos entre medias y, si la franja de arriba no coincide, se repite. El aviso salió en una de tres ejecuciones, antes de existir la comprobación; con ella no volvió a salir, así que la repetición solo está probada comparando a mano aquella toma con una limpia.
- **La pantalla es la de un iPhone 17 Pro a 0,836** (11 §4.4 pide ese simulador): el texto de 13 pt queda en 32,6 px, frente a los 29,8 px de antes y los 33 de 11 §2.2. La pantalla sola de `raw/` mide 1206 × 2622 y no se sube; la compuesta, 1320 × 2868.
- **El compositor dibuja los pasos 2 y 6 como la app**: el 3× lo lleva el contexto y las fuentes se crean a 28 y 17 pt. La segunda línea de la captura 3 mide 355 pt de 376, no 330.
- **Las fichas describen lo que sale**: notas "Pantalla:" de las seis capturas en ES y EN, fuera el bloque del pie de la captura 6 (la página no lo tiene) y la nota de la variante corta de la captura 3.

### Decisiones tomadas al corregir, a confirmar

- **La captura 2 vuelve a 11 §2.4 ("Esta noche", Lluvia 30 · Rosa 50) en lugar de cambiar la 1.** La revisión proponía dejar la 2 como instalación nueva y cargar "Mar y viento" en la 1; eso contradice 11 §2.3, que nombra "Rosa y lluvia", y necesita al dueño. La 2 no es la primera apertura al pie de la letra (esa carga "Rosa y lluvia"): es la página de quien aún no ha comprado ni probado, con dos niveles movidos. Si el dueño prefiere la otra, es una línea en `PageDebug.swift`.
- **Las pistas de VoiceOver juntan dos hallazgos**: "Toca dos veces y mantén pulsado", que es como lo escribe el sistema en español.
- **`pro.fallo` en inglés** también se enseña cuando la persona cancela: "The purchase didn’t go through." vale para los dos casos.

### Aplazado: necesita al dueño

- **Antes de enviar, directriz 2.3.2.** Las capturas 3 (océano sonando) y 4 (Marea) enseñan funciones de Pro y nada en la imagen lo dice; la descripción por defecto tampoco. La enmienda del tercer párrafo ("Después, Pro, que añade las demás texturas, la Marea y mezclas sin límite, es un solo pago…") está redactada en las dos fichas y en la guía §5e.15, y las fichas dicen que no se aplica sin el sí del dueño. Recomendación del corrector: aplicarla.
- **Antes de enviar, directriz 2.3.7.** El titular y la segunda línea de la captura 1 ("Un solo pago." / "sin tarjeta") son condiciones de pago. La reserva está redactada ("Fabricado en tu iPhone." / "Siete noches con todo."): basta poner esos dos bloques los primeros en "Captura 1" de cada ficha y volver a ejecutar el script.
- **La captura 6 sigue medio vacía y la 4 un quinto.** En la 6 la última línea queda al 55 % del alto de la pantalla. 11 §2.8 dibujaba la lista en el paso 2 con filas de 72 pt y hairlines hasta el pie; PLAN-SIMPLE §4.3 la dejó en "página de texto corta" y así se construyó en S-07. Rehacerla es un cambio de la app, fuera de S-08: o entra como tarea antes de enviar, o el dueño acepta la página actual. La hoja de Marea no tiene un detent más bajo: la 4 se queda como está salvo que el dueño pida otra cosa.
- **"beds" y "Blanket"** a la revisión de un hablante nativo de en-US, con el resto de la lista de arriba.
- **Opción A o B de las palabras clave** (la A nombra diagnósticos; por defecto vale la B). El lint la deja pasar como falso positivo declarado hasta que el dueño elija.

### Sin verificar

- Las frases nuevas de Siri dichas en un iPhone, y las pistas de VoiceOver oídas.
- Que un aviso del sistema que dure más de ocho segundos no se cuele en las dos tomas: la comprobación compara dos tomas, no sabe qué hay debajo. Las doce capturas se miran antes de subirlas.
- Lo que ya estaba sin verificar: App Store Connect, un iPhone real, es-419.

## Arreglos del repaso completo (17-11-2026)

Veintiún hallazgos del recorrido de la app entera (dos de ellos, el mismo). Cada uno se comprobó contra el código de esta rama antes de tocar nada. Tests nuevos en `AppWalkthroughFixTests.swift`; lo de las vistas se miró en el simulador (iPhone 17 Pro, ES y EN). `scripts/verify.sh` en verde con 672 tests (suelo subido de 657 a 672).

### Hecho

- **Todas las capas a cero mientras suena.** Al soltar la última capa en cero (o al fijarla sin dedo, con VoiceOver) la noche termina como con "Vaciar": fundido de pausa, temporizador fuera, "En silencio" y Play. Con el dedo aún puesto no termina nada. Antes la página decía "Sonando · se funde a las…" con el motor y el temporizador corriendo sobre silencio.
- **Manto vencido en silencio.** Una reanudación que nadie pidió (auriculares de vuelta, fin de una interrupción, reinicio de los servicios de audio) con la hora del Manto ya pasada cierra la noche a esa hora en vez de arrancar: el temporizador la tomaba por la de mañana y sonaba un día entero. Y la bajada del Manto que venció durante una pausa ya no se aplica al reanudar dentro del fundido final.
- **Reinstalar con la prueba gastada.** El registro vive en el llavero y las preferencias no: el fin de una prueba que esta instalación nunca vio en marcha no es noticia, así que no hay párrafo ni "gratis siempre". `endEvaluatedKey` existe desde que la prueba empieza aquí o se encuentra aquí en marcha; solo entonces su fin deja nota.
- **Madrugada no despierta cada minuto con la pantalla apagada.** El minuto solo es un hecho mientras la app está delante (`SmallHoursController.figureIsWatched`); al volver, la cifra se lee otra vez.
- **Marea.** La línea "Se retira a las…" nunca da una hora posterior al fin del temporizador. El océano que la Marea sube ocupa la fila libre de la página (`tideOceanRaises`). El menú Ritmo usa la forma corta ("Tranquilo · 6"), que cabe en una línea con su marca.
- **Nombre de una mezcla.** El campo deja de aceptar caracteres donde se corta el nombre guardado (`MixCodec.maxNameLength`): ya no se recorta nada a espaldas de la persona.
- **Teclado.** La barra (Mezclas, Disco, Noche) no sube con el teclado de la alerta de nombre, ni en la página ni en Mezclas.
- **Menú de guardar la cuarta mezcla.** "pro" es la segunda línea del ítem (`mezcla.menu.guardar` + `comun.pro`), no parte del título, y el ítem sale desactivado mientras no se vende. `mezcla.menu.guardar.pro` sale del catálogo; anotado en la guía 10.
- **Texto de accesibilidad.** La página, al desplazarse, se corta bajo la barra de estado en vez de leerse a través del reloj del sistema. La columna de la hoja Pro se corta bajo el tirador en vez de cruzarlo (la franja del tirador es de la hoja; el título sigue a 24 pt).
- **Prueba empezada desde Ajustes.** Ajustes baja con la hoja Pro y se cae en la página, que es la única que lo dice ("prueba · quedan 7 noches"). Capas se queda, como estaba.
- **`-pageClock HH:mm`** (solo DEBUG): un lanzamiento normal, sobre las preferencias reales, cuyo reloj empieza a esa hora de hoy y corre. La prueba del llavero lee ese mismo reloj: para simulador.
- **Release se compila en la puerta.** `scripts/verify.sh` compila también en Release tras los tests, con la misma criba de avisos (24 s más). El aviso que nadie había visto (`var opensLarge` en `TimerSheet`) está quitado.

### Decisiones tomadas al arreglar, a confirmar

- **Soltar la última capa en cero termina la noche**, no la pausa: el siguiente Play es una noche nueva (temporizador desde el principio, y cuenta como sesión para "gratis siempre").
- **El campo corta a 40, no a los 24 de la guía 10.** Los nombres automáticos llegan a 28 ("Ventilador, hoguera y cabina") y ya hay nombres guardados más largos: bajar la cota los cortaría. Si el dueño quiere 24, hay que decidir antes qué pasa con esos.
- **La mezcla conserva su nombre cuando la Marea sube el océano** (decisión de S-06: `writeLevel`). Por eso Mezclas sigue listando la receta con que se cargó y no hay fila "Esta noche". Solo se añadió la fila de la página.
- **La puerta tarda unos 25 s más** por la compilación en Release; la CI la hereda porque ejecuta el mismo script.

### Descartado: ya estaba abierto aquí

- **Noche terminada no cede sola a la página por la mañana.** *Cerrada el 17-11-2026 (D-52, `leaveNightScreenIfOverByDay`): ver "Decisiones del dueño aplicadas".* Es la decisión de S-06 (tarea 3, "Noche terminada por la mañana"), con su test (`testTheNightPageStaysWhileItsNightIsAlive`), a la espera del dueño. La revisión insiste y añade un dato: con la entrada por bloqueo (C47) es lo que se ve al abrir la app al día siguiente, y de ahí solo se sale con la pulsación larga. Recomendación: seguir 07 S5 (de día, con la noche terminada, volver a la página de día). Son seis líneas en `appDidBecomeActive` y el cambio de ese test.
- **Tope de seis (C19) por las tres vías que quedan** *Cerrada el 17-11-2026 (D-32, `LayerCap`): ver "Decisiones del dueño aplicadas".* (mezcla guardada de siete o más, acceso recuperado con capas Pro a nivel, niveles de una versión anterior): sigue en "Preguntas al dueño" de la corrección de S-04, con la misma propuesta (`currentGains()` deja sonar las seis más altas).

### Aplazado: necesita al dueño

- **Política de privacidad dentro de la app** (mayor; directriz 5.1.1(i)). Las notas para revisión dicen que se lee en Ajustes › "Lo que no hay", y allí no hay ni texto ni enlace. No se construyó porque faltan tres cosas que no son de código: la guía 10 veta "Política" y "Privacidad" como título (§0.2) y no hay cadena para la fila; `docs/privacy/index.md` tiene datos pendientes del dueño; y la dirección pública no existe todavía. `docs/store/README.md` recomienda el texto dentro de la página, no un enlace. La tabla de `docs/store/notas-revision.md` está al día: mientras no se haga, esa frase no va en las notas.
- **Acceso que llega solo de noche y sonando** (compra pendiente aprobada, familia): sube al momento las capas Pro guardadas y arranca la Marea con la persona dormida. La pérdida de acceso espera al fin de la sesión; la ganancia no ("comprar se oye al momento" es la regla escrita en `PurchaseManager.applyAccess`). Aplazarla pide un estado nuevo (acceso concedido que aún no suena) en todo lo que lee `hasFullAccess`: decisión de producto antes que código.
- **Las ruedas del Temporizador no siguen el tamaño de texto** (AX3: filas de unos 13 pt junto a etiquetas de 28). Son las ruedas del sistema, que no escalan. Sustituirlas en tamaños de accesibilidad (lista de duraciones, selector compacto) es rediseñar el control: ver también "Rechazado" en la corrección de S-06.

### Visto de paso, sin tocar

- Cargar, mientras suena y sin acceso, una mezcla cuyas capas son todas Pro deja el motor sonando en silencio ("Sonando · sin…"): `apply` no levanta la capa de reserva como hace Play.

### Sin verificar

- En dispositivo: el teclado real sobre la barra, la reanudación con auriculares de verdad pasada la hora del Manto y los despertares de Madrugada con la pantalla apagada (probados por su regla, no medidos).
- El menú de guardar con "pro" en segunda línea se vio en Mezclas; el de la página comparte la etiqueta y se vio con la primera línea sola.
- La línea "Se retira a las…" con un temporizador más corto que la Marea: por test, no en pantalla.


## Decisiones del dueño aplicadas (17-11-2026): D-08, D-32 y D-52

Rama `claude/decisiones-producto`. El dueño dijo que sí a la recomendación de `docs/lanzamiento/DECISIONES.md` en las tres. Un commit por decisión y uno de documentación. Sin cadenas nuevas en el catálogo.

### Hecho

- **D-08, restaurar de noche.** `SettingsRestoreRow` (`SettingsLogic.swift`): sin Pro y con `MixerModel.canSell` en falso (ventana de noche, página nocturna, Madrugada), Ajustes tiene bajo "pro" una fila "Restaurar compra". No lleva precio ni entra a la hoja: llama a `PurchaseManager.restore()`, que no pasa por la puerta de venta, dice "Buscando…" en su sitio (la fila no responde mientras tanto) y deja debajo una línea con lo que contestó la tienda: `pro.gracias`, `pro.restaurar.no` o `pro.sin_tienda` / `pro.sin_tienda.silencio`. Hasta xxxLarge el sitio de esa línea está reservado con el alto de la más larga, así que nada de lo de abajo se mueve. Que la fila esté o no se decide al abrir Ajustes y vale para toda la visita; al cerrar se borra el aviso. De día no existe. (Corregido tras la revisión: ver "Corrección de la revisión" más abajo.) Cierra "Restaurar de noche" de la corrección de S-07.
- **D-32, tope de seis.** `LayerCap` (`SleepNoise/Model/LayerCap.swift`): función pura de los niveles y del acceso. Suenan las seis capas incluidas de nivel más alto; las demás conservan su nivel sin sonar. Se aplica en `MixerModel.currentGains()`, por donde pasa todo lo que llega al motor, y `soundingLayers` y `waitingLayers` leen la misma regla. Nada guardado se reescribe: ni los niveles ni las mezclas. La séptima desde cero sigue rechazada en `setLevel` (C19); una capa que ya está en la mezcla se mueve siempre, suene o espere, y las seis se recalculan en cada cambio. La fila que espera: tinta secundaria, su cifra, sin tinta en la línea y "Seis a la vez" debajo mientras espera; VoiceOver dice "en silencio, nivel guardado N, Seis a la vez". Cierra el tope de seis de las correcciones de S-04 y del repaso completo.
- **D-52, Noche terminada por la mañana.** `MixerModel.leaveNightScreenIfOverByDay()`: con Noche delante, la noche cerrada (ni sonando, ni retenida por una interrupción, ni en pausa dentro de sus veinte minutos) y la hora fuera de `NightWindow`, Noche cede a la página de día (`isBedtime` y `isNightSession` a falso). Se llama al volver la app al frente, al cruzar las 07:00 con la app abierta (`nightWindowChanged`) y cuando una noche termina sola (`closeNight`). `NightCover` hace el fundido de siempre (2 s; 0,25 s con Reducir movimiento). `testTheNightPageStaysWhileItsNightIsAlive` conserva lo que protegía (la noche viva, también en Noche) y su último tramo, que fijaba lo contrario para la noche terminada, pasa a tres tests nuevos.
- **Estados de depuración**: `settingsNightRestoring`, `settingsNightNothing`, `settingsNightRestored`, `settingsNightRestoredFamily`, `settingsNightStoreAway` (antes `settingsNightFailed`), `settingsNightCancelled`, `layersOver`, `pageOver` y `nightEndedMorning`.
- **Documentos**: `DECISIONES.md` (las tres cerradas), `docs/store/notas-revision.md` (texto EN en 3867 de 4000, resumen, tabla y condición 6), `PRUEBAS-EN-DISPOSITIVO.md` (§1.A paso 9, §4 pasos 17 y 18, §8.A pasos 18 a 20, §8.B paso 5b, §10 paso 5b), `GUIA.md` (fila del rechazo por restaurar) y la guía 10 (`capas.tope`, `pro.restaurar`, `pro.buscando`, `ax.capa.pro.valor`).

### Decisiones tomadas al aplicarlas, a confirmar

- **Desempate del tope.** Con niveles iguales suena la capa que va antes en `SoundID.allCases` (blanco, rosa, marrón, lluvia, ventilador, océano, trueno, hoguera, arroyo, viento, cabina): el mismo criterio que ya usa `MixLoad.omitted`, y un orden que no cambia porque es el de los identificadores guardados. Alternativa: el orden de la página (camas antes que colores).
- **La regla no tiene memoria.** Las seis son las seis más altas en cada momento: bajar una de las seis por debajo de una que espera las intercambia, también a mitad de un arrastre. El motor suaviza el cambio. La alternativa (que las seis se queden fijas hasta llegar a cero) pide estado y deja de ser una sola regla.
- **Una capa que espera se puede arrastrar**, hacia arriba (entra si supera a la sexta) o hasta cero (sale de la mezcla). No se trata como una fila Pro.
- **La página dice qué capas esperan** (corregido tras la revisión; antes no lo decía). Mientras suena, la línea de estado las nombra con la clave que ya usaba para las capas Pro sin acceso (`pagina.estado.sonando.sin`: "Sonando · sin blanco ni marrón"), y la fila "Todas las capas" añade `capas.tope` a "y n más" cuando alguna de las que esperan no tiene fila ("y 5 más · Seis a la vez"). Sin cadenas nuevas. A confirmar: que "sin …" valga también para una capa que espera, y no solo para una Pro. Con un temporizador en marcha la línea de estado dice la hora, como ya pasaba con las capas Pro; queda la fila "Todas las capas".
- **VoiceOver reutiliza `ax.capa.pro.valor`** para la capa que espera, seguida de `capas.tope`, en vez de una cadena nueva.
- **Restaurar cancelado no dice nada** (corregido tras la revisión; antes decía `pro.fallo`). Quien cierra el diálogo de la cuenta ve la fila volver a "Restaurar compra", sin línea. `pro.fallo` habla de una compra y de un cobro y no se dice nunca bajo esta fila. Alternativa, si se prefiere decir algo: una cadena nueva sin "compra" ni "cobrado".
- **El hueco bajo la fila de restaurar.** Reservar el alto de la línea más larga deja aire de más bajo la fila en reposo: unas dos líneas en el tamaño normal. En tamaños de accesibilidad ya no se reserva (corregido tras la revisión): eran unos 237 pt de negro en AX3; allí la línea aparece y lo de abajo, que ya está fuera de pantalla o en su borde, baja.
- **Una noche que termina sola ya de día** (temporizador a las 07:35 con Noche delante) no llega a enseñar "Terminó a las…": Noche se funde a la página en ese momento. Es la misma regla, sin excepción.
- **Notas de revisión.** Para que la frase nueva cupiera junto a la línea de la política que tiene que volver (condición 1), se acortaron tres líneas de la compra sin cambiar lo que afirman. Con la línea de la política el texto queda en 3995 de 4000.

### Sin verificar

- En un iPhone o en el sandbox: nada. La restauración real desde Ajustes de noche (contraseña de la cuenta incluida), el fundido de Noche a la página al abrir por la mañana tras una noche de verdad y cómo suena el intercambio de capas del tope están probados por su regla y vistos en capturas del simulador, no medidos ni oídos.
- VoiceOver: el valor de la fila que espera y el anuncio del resultado de restaurar, por test o por lectura del código, no con VoiceOver encendido.
- Madrugada que termina ya de día sigue dejando la página nocturna hasta que la app se abre de nuevo: no era parte de D-52 y no se ha tocado.

### Corrección de la revisión (17-11-2026)

Tres revisores leyeron los cuatro commits. Lo que sigue se aplicó en la misma rama; los tests pasan de 690 a 700.

**D-32, tope de seis**

- **La página dice que hay capas esperando.** Sus tres filas se eligen por orden de página (camas antes que colores), no por lo que suena: en la mezcla de ocho de las capturas eran lluvia, viento y océano, las tres sonando, y nada decía que blanco y marrón no sonaban. Ahora la línea de estado las nombra mientras suena (`MixerModel.unheardLayers`, con `pagina.estado.sonando.sin`) y "Todas las capas" añade `capas.tope` a "y n más" cuando alguna de las que esperan no tiene fila (`PageLayers.moreValue`). El número sigue contando las capas de la mezcla sin fila, suenen o no, como ya hacía con una capa Pro guardada a nivel. Sin cadenas nuevas.
- **Un arrastre que toca cero tiene vuelta.** Al llegar a cero entraba la siguiente capa y la subida, con el dedo aún abajo, se rechazaba como séptima: el nivel se perdía al soltar. `MixerModel` recuerda las capas que el gesto abierto llevó a cero (`zeroedUnderFinger`) y las deja volver; compiten por nivel como cualquiera. Se olvida al levantar el último dedo. Sin dedo (pasos de VoiceOver) cero es cero al momento.
- **El nivel se compara como porcentaje entero**, el que enseña la fila y el que se guarda (`LayerCap.percent`): lo que se oye a mitad de un arrastre es lo que queda al soltar, y dos filas con la misma cifra siempre suenan en el orden documentado.
- **La fila que espera no lleva tinta de nivel ni acento bajo el dedo** (`LevelRuleFace.Mode.waitingUnderFinger`): la cifra crece y la pista aparece, como en cualquier arrastre, pero la línea no se pinta hasta que la capa entra entre las seis. Caso nuevo en la galería.
- **La Marea con el océano esperando dice "Seis a la vez"**, no solo con el océano a cero.
- **VoiceOver ya no dice "Seis a la vez" dos veces** en la fila que espera: la nota del canal se oculta a la accesibilidad cuando el valor de la fila ya lo dice.

**D-08, restaurar de noche**

- **Nada se mueve al restaurar.** La fila Pro pasaba a la línea de recibo y crecía (tres líneas en AX3; 16 pt más a tamaño normal con compra en familia), empujando la fila recién pulsada. En la visita en que se pulsó Restaurar la fila Pro se queda con el nombre solo (`SettingsProRow`, `holdsName`); "Gracias. Todo abierto." ya lo dice debajo, y el recibo aparece al volver a abrir Ajustes.
- **Con Pro devuelto la fila no responde.** Un segundo toque volvía a llamar a `AppStore.sync()` (que puede pedir la contraseña) y, con una respuesta vacía, podía retirar el Pro recién devuelto. `isEnabled` exige ahora que no haya Pro, y el toque pasa por `SettingsRestoreRow.restore(with:)`, que tiene test.
- **Cancelar no dice nada.** Cerrar el diálogo de la cuenta dejaba `pro.fallo`, que habla de una compra y de un cobro, de noche y bajo una fila que no vende. La fila vuelve a "Restaurar compra" sin línea, y `pro.fallo` sale de las líneas de esta fila.
- **La existencia de la fila se decide al abrir Ajustes** (`existsOnOpen`) y vale para toda la visita: ya no aparece a las 21:00 ni desaparece a las 07:00 con la hoja abierta.
- **Una restauración lenta no pierde su respuesta**: si Ajustes se cierra mientras busca y se vuelve a abrir, esa visita dice lo que contestó la tienda (`askedOnOpen`).
- **En tamaños de accesibilidad no se reserva el hueco** de la línea de resultado (eran unos 237 pt de negro en AX3).
- **VoiceOver**: la fila es el mismo botón del toque a la respuesta (deshabilitado mientras busca y con Pro, no sustituido), y "Buscando" se anuncia al pulsar.

**D-52, Noche terminada por la mañana**

- **Tests de la noche viva con interrupciones**: llamada que retiene la noche a las 08:00, alarma antes y después de las 07:00, y salida perdida a las 06:55. Quitar `!heldByInterruption` de la guarda pone ahora un test en rojo.
- **El fundido que nadie pidió no responde a toques** (`MixerModel.nightYields`, `NightCover`): "Madrugada · 20 min" queda justo sobre el Play de la página, y quien toca lo que se desvanece no arranca nada. Un fundido pedido por la persona sigue como estaba.

**Documentos**: paso 9 de `PRUEBAS-EN-DISPOSITIVO.md` reescrito (la página de día ya no demuestra que la app aguantó la noche) y pasos 9b, 20b, 5c y 5d nuevos; reglas de noche de la guía 10 (§3 y P1) con la excepción de Restaurar, y su §2.10; 08 §4.7; `docs/ROADMAP.md`; `notas-revision.md` (recuento en bytes y qué prueba cada test); las seis entradas antiguas de este tablero llevan su marca de cierre.

#### A confirmar por el dueño

- **"Sonando · sin blanco ni marrón"** para capas que esperan: es la frase que ya nombraba las capas Pro sin acceso. Si prefieres no nombrarlas en la línea de estado, queda "y n más · Seis a la vez" en la fila.
- **A las 21:00 con Ajustes abierto la fila Restaurar no aparece** hasta cerrarlo y volver a abrirlo. Es el precio de que nada salte en la hoja.
- **Tras restaurar, la fila Pro no enseña el recibo hasta reabrir Ajustes.** Alternativa: reservar en la fila Pro el alto de su estado más alto, que deja aire de más en reposo.
- **Con Pro devuelto la fila Restaurar sigue dibujada**, sin responder, hasta cerrar Ajustes. VoiceOver la dice atenuada. Es lo que evita que algo cambie de sitio.
- **Cancelar la restauración no deja ninguna línea.** Si prefieres decir algo, hace falta una cadena nueva sin "compra" ni "cobrado".
- **Primera noche real antes de las 07:00** (despertador y fin del Manto), para leer "Terminó a las …" (paso 9 de las pruebas).
- **Campo de notas de App Store Connect**: comprobar en pantalla si cuenta caracteres o bytes (condición 1 de `notas-revision.md`).

#### Sin verificar tras la corrección

- El bloqueo de toques durante el fundido de la mañana está razonado sobre el código, no ejecutado con un dedo: paso 9b de las pruebas.
- VoiceOver de verdad: que el foco siga en la fila Restaurar del toque a la respuesta y que se oiga "Buscando" (paso 20b).
- El deslizador fino (pulsación larga) sobre una fila que espera sigue dibujando su pista llena en tinta mientras está fuera: es el control del sistema y dura cinco segundos. No se ha tocado.
- Cómo suena el intercambio de capas al volver de cero a mitad de arrastre: por su regla, no oído.

## Pigmento 1.0 (19-11-2026)

Decisión del dueño sobre `docs/design/12-EXPLORACION-COLOR-2026-11-19.md` (D-55 a D-57): camino A con la ventana del Horizonte, icono y hoja Pro sin color, y en la 1.0 solo la variante mínima de §6.1. Rama `claude/pigmento-1-0`, dos tareas en serie sobre `main` (700 tests).

### Hecho

- **Generador** `scripts/paint/` (Swift y CoreGraphics, sin dependencias): porta el generador de listones de `camino-contenido.html` con el mismo congruencial lineal y las semillas de la maqueta (2101 a 2104), y escribe las cuatro bandas de 64 × 288 pt a 2x y 3x en `Assets.xcassets/Paint/` (1,14 MB; tope de 2 MB en `HousePaintTests`), con la composición en los 92 pt de arriba (`bandFocus`: el campo sigue por debajo y las lenguas de la hoguera no bajan con la altura), pruebas a tamaño real (`--proof`) y piezas de página para mirar (`--store`, no van al paquete). Dos ejecuciones dan los mismos bytes. Ninguna imagen ajena; ningún nombre de pintor, obra, museo ni movimiento en código, recursos, docs ni commits.
- **Mezclas** (`MixesSheet`, `HousePaint`): cada fila de la casa lleva su banda a sangre por la izquierda, velo negro del 12 %, texto a 20 pt de la banda (84 pt del borde), hairline desde el texto; la altura de la fila no cambia y VoiceOver ignora la banda. Las guardadas y "Ajustes" no llevan pintura. La banda es una columna transparente de la altura de la fila con la pieza colgada de su borde superior y recortada a ella: la pieza mide más que cualquier fila (288 pt frente a unos 260 en AX5), así que se dibuja a 1:1 a todos los tamaños y nunca se escala. Comprobado con medida en `paint-measure-mixes-es.png`: cada banda empieza en su hairline menos 72 y termina en la hairline.
- **Regla de día y noche** en una sola función pura, `PaintPolicy.showsHousePaint(now:nightSession:reduceTransparency:increaseContrast:)` (`PaintPolicyTests`): falsa dentro de `NightWindow`, en la página nocturna y con Aumentar contraste o Reducir transparencia. La hoja la lee al abrir y decide con ella la disposición de las filas para toda la visita; si la regla se vuelve falsa con la hoja abierta (las 21:00, que `saleClock` ya redibuja) la banda se funde en `Motion.phase` (2 s; 0,25 s con Reducir movimiento) y no vuelve sola, y el hueco queda como margen. Abierta con la regla falsa, la fila es exactamente la de antes. `MixerModel.currentDate` expone el reloj (real o escenificado) para esa lectura.
- **Tienda**: captura 7, "Lo que suena, se pinta." / "What plays gets painted.", sin subtítulo (el texto de reserva de la exploración 12 §5 habla de pintura generada en el dispositivo, que es la ventana de 1.1), Mezclas de día con las bandas (`-pageState storeMixes`, 20:15, segundo día de la prueba, "Rosa y lluvia" sonando), la última de `scripts/screenshots.sh`; el compositor y el lint de S-08 pasan a siete capturas; fichas ES y EN con la captura, su "Pantalla:" y el titular como séptimo párrafo de la descripción (recuentos actualizados).
- **Estados de depuración**: `mixesPaint`, `mixesPaintEvening` (21:30 en la página de día), `mixesPaintContrast`, `mixesPaintAX3`, `mixesPaintAX5` y `storeMixes`. Capturas `paint-*` en `.build/shots/` en ES y EN.

### Decisiones tomadas al construir, a confirmar

- La disposición de la fila (con hueco o sin él) se decide al abrir la hoja y no cambia mientras está abierta: a las 21:00 la banda se funde y el hueco se queda (camino A, "fundir"); al abrirla de noche no hay hueco. La maqueta dibuja el hueco también de noche.
- La pieza mide 288 pt para que ningún tamaño de texto la escale; en la fila de AX5 la hoguera queda arriba y debajo se ve el campo marrón (la composición está en los 92 pt de arriba, la banda de la maqueta). Si el dueño prefiere fuego en toda la altura, es un cambio del generador (`bandFocus`).
- "What plays gets painted." es traducción propia: la exploración solo escribe el titular en español. Alternativa: "What you hear, painted." El dueño elige y se quita la coletilla "a confirmar" de `ficha-en.md` (titular de la captura 7 y séptimo párrafo de la descripción).
- Las bandas no se atenúan bajo otra hoja ni al pasar la app al fondo: el "atenuar" de la exploración §3 es de la ventana de la página, que es de 1.1. La propia exploración se contradice (§6.1 dice "su velo, su atenuado y su fundido nocturno"): a confirmar por el dueño; si quiere el atenuado en 1.0, es opacidad 0,3 en 1,5 s bajo hoja o al fondo.
- El séptimo párrafo de la descripción de la tienda es el titular común "Lo que suena, se pinta." (documento 11 §2.10: VoiceOver no lee las capturas). En la 1.0 la pintura es estática, suene o no la mezcla; la captura lo sostiene ("Sonando ahora" junto a la banda), el párrafo suelto menos. A confirmar: si el dueño lo prefiere, se omite ese párrafo hasta la 1.1 (recuentos a 787/756).
- Las hebras del viento sobre el mar (60 a 140 pt, casi rectas) cruzan la banda de 64 pt de lado a lado y se leen como rayones; son fieles a la maqueta, que se juzgó a 402 pt. Propuesta para el dueño: hebras de 30 + R × 40 pt y desviación 0,2 (curvan), misma semilla y mismas dos tintas oliva al 70 %. No se ha tocado: es dirección.
- La captura 7 va la última porque la exploración no sustituye ninguna de las seis de C57.

### Sin verificar

- Un iPhone: las bandas a la luz y a oscuras, y el fundido real al cruzar las 21:00 con la hoja abierta (paso 11 de `PRUEBAS-EN-DISPOSITIVO.md`). En el simulador el estado de las 21:30 se ha visto sin banda; el fundido de 2 s está razonado sobre `saleClock`, no cronometrado. La vuelta del fondo después de las 21:00 con la hoja abierta (salir a las 20:58, volver a las 21:05) se apoya en que `MixesSheet` lee `scenePhase`: razonado, no visto.
- La rama "página nocturna de día" de `PaintPolicy` solo tiene prueba pura (`testTheNightPageNeverPaints`): la captura `paint-mixes-night` se toma a las 2:14, dentro de `NightWindow`, y un estado escenificado de página nocturna de día no es alcanzable (`appDidBecomeActive` la cierra). Paso 11.5 del dispositivo.
- El fundido deja la banda en la jerarquía a opacidad 0 (no `nil`): con un PNG no cuesta memoria y `allowsHitTesting(false)` la aparta del dedo; el "nil, no opacidad 0" de la exploración §3 es de la ventana viva de 1.1.
- Aumentar contraste y Reducir transparencia con los interruptores reales del sistema: la captura usa el estado que fuerza el contraste por código.
- VoiceOver con la banda: oculta por `accessibilityHidden`, no oída.

### Corrección de la revisión (19-11-2026)

Tres revisores leyeron los tres commits. Aplicado: la banda se recorta de verdad a su fila (antes la pieza de 92 pt se centraba en la fila de 72 y sobresalía 10 pt por arriba y por abajo; ahora es una columna de la altura de la fila con la pieza colgada del borde superior); la pieza pasa a 64 × 288 pt con la composición en los 92 de arriba, para que ningún tamaño de texto la escale (en AX5 el borde era blando); la vuelta al primer plano relee la regla (`scenePhase` en `MixesSheet`) y la hoja usa el calendario del modelo (`MixerModel.currentCalendar`, con test); la captura 7 pierde su subtítulo (prometía pintura sin archivos y en 1.0 son PNG); PLAN §4.3 y §9, DECISIONES "Fuera de 1.0" y documento 11 §2.2 puestos de acuerdo; notas de ImageIO y de reproducibilidad en el README del generador; suelo de tests al nuevo total. Rechazado: cambiar el test que lee literales del generador (los PNG del catálogo ya prueban el acuerdo con la app; se acepta tal cual para 1.0). Aplazado al dueño, arriba en "a confirmar": titular inglés, hebras del viento, "atenuado" de §6.1, séptimo párrafo de la descripción; y a 1.1 el `nil` en lugar de opacidad 0 al fundir.

## Pigmento 1.0 · tarea 2 (19-11-2026)

Segunda decisión del dueño la misma tarde (D-58, "seamos agresivos, metamos todo lo de diseño ahora"): el camino A completo entra en 1.0 con la medida de batería como condición de envío. Misma rama `claude/pigmento-1-0`, dos tareas en serie sobre la variante mínima: la primera dejó el motor (`Pigment` compartido con el generador, `PaintScene`, `PaintRasterizer`, `PaintBreath`, `PaintStore`, `PaintPolicy.phase`, `PaintSetting`, `PaintMetrics`, 25 tests); la segunda lo puso en la página.

### Hecho

- **Ventana** (`PaintWindow`, `PagePaint`, `PageView`): detrás del `VStack` de la página, en el `background` del contenido del `ScrollView`, colocada con anclas (`PaintAnchorKey`: Horizonte, filas, línea de estado) para que valga a cualquier tamaño de texto; 240 pt alrededor del Horizonte, 120 desde AX1. Capa seca como `Image` del raster; capa viva en su propia vista, que es la única que lee `PaintPulse`, el objeto que alimenta el `tick` del `TimelineView` de `SoundLine`: la pintura no tiene reloj propio, comparte el `isFrozen` del Horizonte y un tick solo invalida esa imagen. Marea: `PaintBreath.offset` con la misma curva del agua que dibuja `PageHorizon`, redondeado a píxel (`Grid.pixelRound`). Velo en un solo `LinearGradient` con las paradas de `PaintVeil` (35 % en el Horizonte, 75 % en los bordes, recto; 80 % en la franja de 24 pt; 96 % bajo el texto que entra, con paradas dobles en los cortes); halo negro seco de 9 pt (3 + 3 a cada lado del trazo más grueso) de margen a margen. Sin toque ni VoiceOver.
- **Fases** (`PaintPolicy.phase` más dos hechos de la página en `PageView.pagePaint`): antes del primer Play no hay pintura; la pausa la seca a 0,6 en 1,5 s y la devuelve en 0,8 s; hoja delante o escena inactiva, 0,3; Reducir movimiento congela la capa viva (si el sonido no la ha encendido aún, se dibuja quieta a 0,65, `PaintBreath.stillOpacity`, para que el cuadro esté entero); ausente (vista a nil y raster a nil) con la página nocturna, Noche, Madrugada, `NightWindow`, `isLuminanceReduced`, Aumentar contraste, Reducir transparencia, el ajuste "nunca" y la app al fondo (`inBackground`, nuevo en `PaintConditions`: al fondo el raster se suelta en seco; lo demás se funde en `Motion.phase`, 2 s o 0,25 s, y entonces se suelta). `PaintPolicy.fadeIsFinal`: la ausencia de la noche (ventana nocturna, fases de noche, `isLuminanceReduced`) deja un cerrojo, `paintFaded`, que solo abren la salida deliberada de la página nocturna y el fin de Noche o Madrugada por el día; ni las 07:00 ni el desbloqueo. Las 21:00 llegan por `saleClock`, que ya redibuja la página.
- **Raster**: `PaintStore` espera 0,35 s antes de repintar cuando ya hay un raster en pantalla (un dedo que arrastra un nivel cambia la escena muchas veces por segundo; se pinta donde se queda); el primero no espera. En DEBUG imprime tiempo, trazos y bytes de cada raster.
- **Capas** (`PaintRule`, `PaintRuleMark`, `LevelRulePaint` en `LevelRule`, `LayerRow`, `LayersSheet`): regla de 4 pt a 8 pt del borde, la altura del área táctil, tinta más oscura de la textura de fondo y nueve dabs por 56 pt de la siguiente al 90 %, fijos por semilla propia (`PaintRule.seed`); opacidad 0,42 a cero y 1 a tope, seca también en una fila bloqueada o que espera; formas, no raster. Decidida al abrir la hoja, se funde si la regla se vuelve ausente con la hoja abierta y no vuelve en esa visita. VoiceOver y el dedo la ignoran; el nombre no se mueve.
- **Ajustes**: sección "día" con la fila "Pintura" (`MenuRow`, De día / Nunca) y una nota debajo (`ajustes.pintura.nota`: "Generada en este iPhone, sin imágenes. Solo de día; se apaga sola con Reducir movimiento y Aumentar contraste a la vez."; `ajustes.pintura.nota.apagada` mientras los dos interruptores la apagan). El valor de la fila es lo efectivo; la elección guardada no se toca.
- **Estados de depuración**: `windowPinkRainTide`, `windowBrownFire`, `windowSeaWind`, `windowPaused`, `windowEvening` (20:59), `windowNight` (21:01), `windowContrast`, `windowReduceMotion` (`PaintArguments.forcesReduceMotion`), `windowAX3`. Capturas `window-*.png` en `.build/shots/` (ES, una EN, Capas de día y de noche, Ajustes ES y EN, y las cuatro ventanas veladas del test).
- **Medidas** (simulador iPhone 17 Pro, 3x): raster de 70 a 136 ms en la cola de utilidad (567 trazos la hoguera, 1.553 a 1.676 las demás), nunca en el hilo principal; 6,62 MB las dos capas (402 × 240 pt); pico de Y tras velo en la banda 0,19 a 0,28 en pantalla y 0,18 a 0,24 en el test de las cuatro casas (tope 0,28); fondo bajo las filas Y ≤ 0,02 con el velo del 96 %: `texto` 9:1 y `texto2` ≥ 4,8:1; la página nocturna, la página de día dentro de la ventana nocturna y Capas de noche, idénticas píxel a píxel a una build de `c93be5a`. Con toques reales: Play pinta la ventana en 2 s, Capas enseña las reglas, y el reloj fijado a las 20:59 deja la página negra al pasar las 21:00.
- **Tienda**: la captura 7 recupera su segunda línea, acortada para la columna ("Se genera aquí, como el sonido. Sin archivos." / "Made here, like the sound. No files."); `CopyLintTests` y `scripts/screenshots/README.md` lo saben; documento 11 §2.2 al día.

### Decisiones tomadas al construir, a confirmar

- El velo bajo el texto es del 96 %, no del 90 % del diseño: con 90 `texto2` quedaba a 3,6:1 sobre la pluma de la banda (medido). Y el velo va recto del 35 % al 75 %, no en ease-in-out: con la curva un píxel de la lluvia pasaba de Y 0,28.
- El halo del Horizonte no sigue la línea de agua de la Marea: es la franja fija alrededor del Horizonte (la reserva de 24 pt ya está donde el agua sube).
- "Nunca vuelve sola" se aplica así: el cerrojo del fundido nocturno lo abren la salida deliberada de la página nocturna y también el fin de Noche o Madrugada por el día (D-52: Noche cede sola a la página de día; sin esto, la página de la mañana se quedaría negra hasta el próximo arranque). Un arranque nuevo empieza sin cerrojo.
- Antes del primer Play no hay pintura ("nace con el audio"); la pausa seca y no funde. Una página en reposo recién abierta es la de Grafito.
- La app al fondo suelta el raster en seco y lo repinta al volver, que nace otra vez en 2 s: no hay fundido que nadie vea. Escena inactiva (centro de control encima), atenuada, no soltada.
- Las reglas de Capas se deciden al abrir la hoja, como las bandas de Mezclas; con Reducir movimiento se ven (son quietas) y con Aumentar contraste no.
- La segunda línea de la captura 7 va bajo Mezclas, cuyas bandas son PNG de compilación; la frase habla de la pintura de la app. Si el dueño prefiere la línea bajo una captura de la página pintada, es otra captura.
- La cadena inglesa de la nota de Ajustes y de la segunda línea de la captura 7 son propias.

### Sin verificar

- Un iPhone: todo el apartado 11 de `PRUEBAS-EN-DISPOSITIVO.md`, en especial la medida de MetricKit (11.1, condición de envío) y la prueba de cinco segundos (11.2). El simulador no entrega resúmenes de MetricKit.
- La respiración de la capa viva se ha razonado con `PaintPulse` y su test, y se ha visto el raster nacer con Play; no se ha cronometrado el movimiento en pantalla.
- `isLuminanceReduced` y Reducir transparencia con los interruptores reales; el contraste y el movimiento se han forzado por código en las capturas.
- El fundido de 2 s se ha visto terminado (página negra a las 21:01), no cronometrado; la vuelta del fondo después de las 21:00 (salir a las 20:58, volver a las 21:05) está razonada sobre `scenePhase`.
- Batería: ninguna cifra. No se publica hasta medirla.
