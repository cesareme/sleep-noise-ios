# Tablero de estado · SleepNoise 1.0

Última actualización: 16-11-2026. Plan vigente: `docs/PLAN-SIMPLE-1.0.md` (12 paquetes, 4 semanas). Este tablero sustituye al de 67 paquetes del plan anterior.

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
paywall.benefit.timer
paywall.benefit.timer.detail
paywall.trial.activeFormat
paywall.trial.notStartedFormat
paywall.trial.endedDetail
intent.timerNeedsProFormat
```

S-04 retiró las que vivían en la pantalla antigua (`trial.intro.*`, `trial.ended.*`, `mixes.stripped`), junto con el resto de cadenas que solo usaba ella. `paywall.trial.activeFormat` es la que ve hoy toda instalación nueva que abre la hoja Pro mientras corre la prueba. `timer.locked` ya no se enseña: la página abre la hoja del temporizador con todas las duraciones libres.

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

- **Capas va sobre `hoja`**, como pide PLAN-SIMPLE §4.1 ("nunca hojas negras sobre negro"). 03 §4.10 y 05 §2.7 la querían sobre `negro`. Sobre `hoja` el relieve `grafito` del Disco y de la pista bajo el dedo casi no se distingue (1E1D1B sobre 1C1C1E). Si se prefiere el negro, es un argumento en `LayersSheet` (`grafitoSheet(surface:)`).
- **La barra inferior** es "Mezclas" y el Disco; el sitio de "Noche" queda vacío hasta S-06. Marea y Temporizador son filas de la página, como en la maqueta. La barra es propia (no `ToolbarItemGroup`), para que se vea igual en iOS 17 y 26.
- **La línea de estado** elige así cuando coinciden varias cosas: fundiendo, capa por defecto ("rosa a 40"), hora del temporizador, "sin {capa}", "Sonando".
- **"y N más"** cuenta las capas por encima de cero que no tienen fila, también las Pro que conservan nivel.
- **Play con la mezcla en silencio** (vacía o toda Pro sin acceso) sube rosa a 40 como nivel real (05 §2.12). Los intents siguen negándose a empezar una noche en silencio.

### Página nocturna (S-06)

- La tinta nocturna es por procedencia (C40): `MixerModel.beginNightSession()`, que ya llama `leaveBedtime()`. Hoy nada entra en Noche, así que la página nocturna solo se ve con `-pageState night`. Vive en memoria: falta decidir qué es "la sesión" y guardarla.
- La venta se cierra por `NightWindow` y, además, mientras dure la página nocturna (`SaleGate`). Toda petición de la hoja Pro pasa por `MixerModel.offerPro()`.

### Prueba (S-07)

- La cabecera de la página enseña la prueba de 7 días de hoy con las cadenas del chip antiguo (`trial.chip.*`), como palabra de estado. Es la única entrada a la hoja Pro mientras todo está abierto. La tarjeta de bienvenida y la de "prueba terminada" se fueron con la pantalla antigua: la prueba sigue empezando con Play hasta S-07, y ahora solo lo dice la hoja Pro.
- Los renglones de la nota de una vez (noche 7 y noche 8) no se construyeron: dependen de `NightTrial`. La cabecera tiene su renglón fijo.

### Lo que la página no hace todavía

- Marea: la banda de 120 pt y la línea de agua, "Se retira a las", y que el interruptor arranque el sonido (S-06). El interruptor arma la Marea como hasta ahora.
- Línea 2: "Seguir por el altavoz", "Sonando · al 40", "En pausa · llamada", "· AirPods" y el fin de sesión a los 20 minutos en pausa dependen de cablear `RoutePolicy` e `InterruptionPolicy` (S-06).
- Menú del nombre: solo "Guardar como mezcla…". Renombrar y Vaciar, con Mezclas (S-06).
- Descomposición del Horizonte por pulsación larga, TipKit del segundo arrastre, fila Timbre (1.1) y "Enviar informe".
- Una mezcla guardada con más de seis capas se carga entera: el tope solo impide añadir la séptima.
