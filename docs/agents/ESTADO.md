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
| S-06 | Noche, Madrugada, Temporizador, Marea y Mezclas en Grafito (con ganancia maestra con rampa) | Claude | Cursor (CI) | 2-3 | `claude/s-06-noche-temporizador` | pendiente | - |
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

### Prueba (S-07)

- La cabecera de la página está vacía hasta que la prueba empieza (05 §2.1, C07) y enseña después la prueba de 7 días de hoy con la cadena del chip antiguo (`trial.chip.daysFormat`), como palabra de estado. La tarjeta de bienvenida y la de "prueba terminada" se fueron con la pantalla antigua: la prueba sigue empezando con Play hasta S-07, y ahora solo lo dice la hoja Pro.
- Los renglones de la nota de una vez (noche 7 y noche 8) no se construyeron: dependen de `NightTrial`. La cabecera tiene su renglón fijo.

### Lo que la página no hace todavía

- Marea: la banda de 120 pt y la línea de agua, "Se retira a las", y que el interruptor arranque el sonido (S-06). El interruptor arma la Marea como hasta ahora.
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

- **Temporizador de 45 minutos en el primer uso** (03 §5 #8, 05 fila "Noche 1"). Hoy la fila dice "Apagado" y el primer Play suena sin fin. Hay que distinguir el primer uso de un "Apagado" elegido por la persona.
- **La identidad de la mezcla cargada no sobrevive al reinicio.** Quien carga una mezcla guardada y vuelve a abrir la app ve "Esta noche" con los niveles de su mezcla, y pierde el "· sin Océano" del título recortado. Guardar nombre base, receta e id de la mezcla de la casa junto a los niveles.
- **Mezclas de la casa.** La hoja Mezclas solo lista las guardadas: "Mar y viento", "Marrón y hoguera" y "Pared" no se cargan desde ninguna pantalla, y "Rosa y lluvia" no se recupera tras la primera edición.
- **Nombre automático de la mezcla** (`mezcla.nombre.auto.*`, guía §4.2). Al guardar, el campo se precarga con el nombre que la mezcla ya tiene, o con "Esta noche".
- **La Marea sube el océano a 50** (`MixerModel.tideOceanLevel`) y lo vuelve a bajar si se apaga sin tocarlo. La guía dice 40 y "nunca lo vuelve a bajar". La cadena `marea.oceano.subido` lleva la cifra del modelo.
- **Copy heredado en las hojas antiguas**, a borrar al rehacerlas: `common.close` como botón en las cuatro (las hojas Grafito no llevan botón de cerrar), `breath.title` ("Marea respiratoria"; C15: "Marea"), `timer.title` EN ("Sleep timer"), `timer.note` ("se desvanece"), `timer.custom` ("Personalizado"), `mixes.title` ("Mezclas guardadas"). En `SleepTimerView` las ramas del candado, `timer.locked` y `onLocked` están muertas: la página pasa `hasFullAccess: true`.

### S-07 (hoja Pro y prueba)

- **S-04 no se publica sin S-07.** La prueba sigue arrancando con el primer Play, también de madrugada, y la página no lo dice: solo lo explica la hoja Pro antigua.
- **Cabecera vacía tras la prueba.** Con la prueba terminada y sin compra, comprar y restaurar se alcanzan solo desde una fila "pro" de Capas, desde la Marea o al guardar la cuarta mezcla, y nunca de noche. `pro.prueba.estado.gratis` ("gratis siempre") y las cadenas `pro.prueba.estado*` en noches entran aquí.
- **Cadenas de la hoja Pro que faltan en la lista de arriba:** `paywall.purchaseFormat` ("Desbloquear Pro", en la lista negra), `paywall.restore` ("Restaurar compras"; la guía pide "Restaurar compra"), `paywall.trial.titleFormat` (días) y `common.close`.

### S-08 (cadenas y capturas)

- Las capturas de referencia en inglés son cuatro (`page-en-rest`, `page-en-timer`, `page-en-layersSix`, `page-en-layersEnd`): el resto del inglés no se ha mirado en pantalla.
