# SleepNoise · 09 · Ecosistema Apple

**Equipo E6 (Ecosistema Apple) · 16 de noviembre de 2026 · Documento 09 de la serie de diseño · Fase de especificación · revisión tras la puerta de los jurados (§11) y tras la reconciliación producto–diseño (§12)**

Cubre las pantallas 19-26 y 34 del inventario de `03-DIRECCION-DE-DISENO` §5: Live Activity recortada (19; 1.0 solo en escenario A, 1.1 en B), Dynamic Island mínima y compacta (20; sin expandida), StandBy nocturno (21), widgets (22; mediano en 1.1), Centro de control y botón de Acción (23; 1.0 con corte sin coste en la semana 14), Siri / Atajos / "Al acostarte" (24), Focus de Sueño (25, 1.1), Apple Watch mínimo (26, 1.2) y Reproduciendo del sistema + Salida (34, 1.0). Es la especificación de todo lo que SleepNoise enseña **fuera de la app**: desde la mesilla, sin encender nada.

**Insumos leídos completos:** `03-DIRECCION-DE-DISENO-2026-11-16.md` (§3 tokens, §4 componentes, §5 inventario y §8.3 puertas son ley aquí), `04-SISTEMA-FUNDAMENTOS.md` (tokens, escala, retícula), `10-GUIA-DE-COPY.md` (toda cadena de §5 (e) es suya), `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§0–§6; manda sobre 03 y sobre el plan; §12 lista lo aplicado); el brief del director creativo para E6; `specs/tokens.md`, `specs/grafts.md`, `specs/decisions.md`; `00-BRIEF-CREATIVO` (P1-P12 y las dos listas negras); `02-MATERIALES` (§2.3 StandBy, §3 movimiento, §4 háptica, §6 iconografía, §7 accesibilidad, §8.3 degradación a iOS 17); `concepts/silencio.md` entero y, por tema, `grafito.md`, `marea.md` y `dial.md`; el código de `main` (`AccessPolicy.swift`, `SoundID.swift`, `MixerModel.swift`, `Features/Breathing`, `Features/Timer`, `Features/Paywall`, `Features/Library`, `Audio/AudioSessionObserver.swift`, `Audio/NowPlayingController.swift`, `Localizable.xcstrings`, `project.yml`); el informe de mercado §1, §5.2 y §6; `REVIEW-PR3` §"Encaje" y hallazgos de UI y de Atajos; las cinco listas de los jurados (§11).

**Lo que el código de `main` fija y esta entrega no contradice sin decirlo:** seis texturas hoy en `SoundID` (blanco, rosa, marrón, lluvia, ventilador, océano) y once en 1.0 vía PR-A (C19); gratis = blanco, rosa, marrón, lluvia y viento (`.wind` entra en la rama libre de `soundIsIncluded`, C04); Marea Pro (`breathingIsIncluded`) que suena para todos en Madrugada (C05); temporizador entero libre (`freeTimerMinutes` desaparece, C03; Manto por hora, C22); `freeSavedMixLimit` 1 → 3 (§1 regla 3 de la reconciliación); `SavedMix` en formato v2 (pares id+nivel, `version: 2`, C20; la entidad de Atajos y del widget mediano se construye sobre ella); `BreathingGuideController.anchor`; `SleepTimerController {selectedMinutes, remaining, isFading}` (los hitos que la Live Activity escucha; fundido de ganancia 10-15 min con cuenta entera, C31); `AudioSessionObserver` distingue interrupción (`.began`), `.oldDeviceUnavailable`, cambio de ruta y `mediaServicesWereReset`, y desde 1.0 se le añade `CXCallObserver` para distinguir la llamada (C48); `NowPlayingController` expone `pauseCommand` (llega igual desde el botón del bloqueo, un toque en el auricular o la pausa automática de AirPods; con auriculares conectados se trata como pausa de auriculares con fundido de 3 s, C49); `master` con rampa en `EngineCommand` entra en 1.0 (C51); **no existe** ningún target de widget, de Live Activity, de Control ni de Watch en `project.yml`, ni ningún `AppIntent`: todo lo de este documento es nuevo. Lo que el PR #3 hizo mal y aquí se resuelve: frases de Siri que interpolaban un `Int` (aquí solo `AppEnum`/`AppEntity`), frases ES en `Localizable.xcstrings` en vez de `AppShortcuts.xcstrings`, "Parar" abriendo la app a pantalla completa (aquí ningún intent de parada abre nada), "Stopped" cuando no sonaba nada, el paywall por Atajo sin explicación (aquí Siri nunca vende), "Pon ${sound} **con** SleepNoise" (aquí "en").

**Lo que la extensión necesita y hoy no existe (cambios en la app que esta entrega exige):**
- **App Group** `group.com.cesareme.sleepnoise` desde 1.0 (C09): widgets, Controls, la extensión de la actividad y, en 1.2, el Watch corren en otros procesos y no pueden leer `UserDefaults.standard` ni `MixStore`. Migración de `sleepnoise.mixes.v1` (→ formato v2), `sleepnoise.levels.v1`, `sleepnoise.timerMinutes.v1` y `sleepnoise.breath.v1` a `UserDefaults(suiteName:)`. iCloud KVS: 1.1 (C09). El anillo de Diagnóstico queda **fuera** del App Group (C56).
- **Snapshot de sesión** `sleepnoise.session.v1` `{isPlaying, endDate, mixName, strippedLayers, substituteMix, phase, mode, pausedAt, route}` escrito por la app en cada hito. Es lo único que leen el widget, el valor del toggle (`ControlValueProvider.currentValue()`) y el Smart Stack.
- **En cada hito**, además de `Activity.update`: `WidgetCenter.shared.reloadTimelines(ofKind:)` y `ControlCenter.shared.reloadControls(ofKind:)` (iOS 18). Sin la segunda llamada el toggle no cambia nunca a *on*. Son las señales reales de M7 y M8.
- **Hitos, no ticker**: la Live Activity escucha `isFading` y `endDate`, no el `Timer` a 4 Hz de `SleepTimerController`. Se pide a E4 / I0 sustituir el ticker por dos disparos únicos (`Timer(fire: fadeDate)` y `Timer(fire: endDate)`, como hace `BreathingGuideController.schedule(at:)`): es condición del presupuesto de 03 §3.7 ("10 min bloqueado sin actividad periódica salvo el audio") y la puerta de dispositivo lo medirá.
- **Política de acceso**: `AccessPolicy.breathingIsIncluded(hasFullAccess:, inSmallHours:)` devuelve `true` en Madrugada para todos (C05); `MixerModel.refreshEntitledAudio()` no termina la Marea si `isSmallHours`; Madrugada es una receta fija (`playSmallHours()`: océano a 0,3, Marea 8/min, 20 min, entrada 3 s, retirada de la Marea hacia el minuto 13, fundido final 5 min) que no pasa por `showPaywall`. Sin escucha de 30 s (C06): ningún intent toca una capa Pro sin acceso.
- **Ruta y sesión**: `routeSharingPolicy = .longFormAudio`; `outputLatency` leído en cada cambio de ruta para corregir la ancla de la Marea y los fundidos (C41); caída de ruta = fundido de 40 ms + pausa; reanudación por el altavoz capada a 0,4 solo si la ruta cambió (C49); una sola constante `NightWindow` 21:00–07:00 (C40) que esta entrega no necesita (fuera de la app nunca se vende) pero cuyo nombre reutiliza para no inventar otra.
- **Live Activity y Siri**: `PlayLastMixIntent`, `PlayMixIntent`, `SetTimerIntent` y `SmallHoursIntent` adoptan `LiveActivityIntent` (iOS 17.2) para poder solicitar la actividad desde su `perform()` con la pantalla bloqueada. `SleepNoiseShortcuts.updateAppShortcutParameters()` tras guardar, renombrar o borrar una mezcla.

**Convenciones.** Medidas en pt para 393 × 852 (iPhone 16 / 15; el iPhone 17 Pro y el 17 miden 402 × 874: la actividad se ensancha 9 pt a la derecha, la columna crece, nada se mueve **[a medir]**) en tamaño Large; las superficies del sistema llevan su propio lienzo (Live Activity de bloqueo 393 × 160; StandBy = la presentación de bloqueo escalada ×2 por el sistema, 786 × 320 vistos; widget pequeño 158 × 158, mediano 338 × 158; Watch 45 mm 198 × 242). **Retícula de 4 pt**: toda cota es múltiplo de 4; "un tercio" se redondea al múltiplo de 4 más cercano. Hex: solo los de 03 §3 / 04 §2.0.1; aquí se citan por token y ninguno se escribe. Textos ES con EN entre corchetes; **toda cadena es una clave de 10 §5e** (las que 10 aún no tiene se marcan *pendiente de E7* en §9 y usan la redacción más cercana de la guía). **[a medir]** = no verificado en dispositivo. **[spike I0-3]** = `Button(intent:)` sobre una actividad en estado `.ended`, retirada de la actividad al forzar el cierre, precisión del tiempo vivo. **[spike I0-6]** = tinte real de StandBy (modelos A/B de 02 §2.3). Versiones: **[1.1]** / **[1.2]** según §4-§5 de la reconciliación; sin marca = 1.0. Los ratios bajo rojo citados son los de 03 §3.1 (modelo A / modelo B: 4,43 / 4,30 para `texto`); criterio fuera de la app (C62): texto ≥ 24 pt vistos y ≥ 3:1 bajo rojo medido en dispositivo; plan B `texto` → `#F0ECE4` si la medida queda por debajo de 3,5 (04 §2.0.1). Fuera de la app rige 03 §3.1 regla 4: **una tinta (`texto`), formas ≥ 2 pt, estado por forma, se diseña primero en rojo.** Única excepción: el tinte *on* del Centro de control, que pone el sistema con `AccentColor` (= `índice`; `ocre` en apariencia clara, 04 §2.0.1; C61). `widgetAccentable` solo en texto, horizonte y glifo; nunca en fondo (C61).

**Gates de disponibilidad.** Dentro de la app sigue habiendo un único `#available(iOS 26)` (03 §4.4, C66). Fuera de la app hay dos más, confinados a la extensión y sin que ninguna vista sepa en qué iOS corre: `#available(iOS 18, *)` en el `WidgetBundle` para los dos `ControlWidget`, y `@available(iOS 17.2, *)` en la conformidad `LiveActivityIntent` de los cuatro intents que arrancan sesión. Alternativa de un solo gate propuesta al dueño en §9: deployment target 17.2 para la extensión.

**Versalitas fuera de la app.** La palabra de estado (03 §4.8) es paso 9 (13 Medium `texto2`) dentro de la app. Fuera, `texto2` no existe; aquí la versalita se escribe en el **paso 7 de noche: 15 Medium `texto`, `.smallCaps()`, tracking +2 %, `relativeTo: .subheadline`** (un paso que ya existe en 03 §3.4; ningún estilo nuevo), que escalada ×2 en StandBy da 30 pt vistos (≥ 24, C62). La versalita lleva palabras y, cuando 10 lo fija así, el prefijo que precede al tiempo vivo (`la.hasta`, `la.madrugada.prefijo`, `la.estado.terminada`): la tensión con 03 §3.4 ("nunca un dato en versalitas") se registra en §9 para E1/E7.

**Tiempo vivo.** Fuera de la app no hay reloj propio (10 §2.11, 03 §5 #19): toda cifra de tiempo es `Text(timerInterval:, countsDown: true, showsHours: false)` ("38:12"), que el sistema pinta sin que la app corra; en Manto, el restante con `showsHours: true` ("3:53:12"); en pausa, `Text(timerInterval:pauseTime:)` congela el valor. La precisión (segundos visibles) queda en el **[spike I0-3]**: en iOS 18 `Text(.currentDate, format: .timer(countingDownIn:, maxPrecision: .seconds(60)))` da "38 min" sin segundos; si el spike lo confirma, es la forma de 1.0 en iOS 18 y la de iOS 17 sigue siendo `timerInterval`. Nunca una cifra estática de minutos recargada por hito (sería falsa a los dos minutos); nunca `%lld` en una clave de superficie.

---

## 1. Intención (P10: una superficie, una pregunta)

| # | Superficie | V | Pregunta a la que responde | Lo que **no** responde (vive en otra pantalla) |
|---|---|---|---|---|
| 19 | Live Activity recortada (bloqueo) | 1.0 (A) / 1.1 (B) | "¿Sigue sonando y cuánto queda? Y si me he despertado, ¿puedo añadir tiempo o volver a dormirme sin desbloquear?" | Qué capas, a qué nivel (Capas); comprar (Pro: nunca aquí); la Marea en detalle (Marea) |
| 20 | Dynamic Island (mínima, compacta) | 1.0 (A) / 1.1 (B) | "¿Sigue sonando?" (mínima); "¿cuánto queda?" (compacta) | Todo lo demás: no hay vista expandida (C25); tocar la Isla abre la app en Noche |
| 21 | StandBy nocturno | 1.0 (A) / 1.1 (B) | "A un metro, con un ojo: ¿suena, cuánto queda?" | El nombre de la mezcla (a un metro no se lee y a las 3 no importa); prolongar (un solo control: pausa/play, C25) |
| 22 | Widgets | 1.0 (pequeño, bloqueo) / 1.1 (mediano) | "¿Dormir ahora, con lo de anoche?" (pequeño); "¿suena?" (bloqueo); "¿con cuál de mis mezclas?" (mediano, 1.1) | Ajustar nada; el widget no es un mando; nunca un circular (C42) |
| 23 | Centro de control + botón de Acción | 1.0 (iOS 18; corte semana 14, C26) | "Dormir, sin abrir nada" / "Madrugada, sin encender la pantalla" | Elegir mezcla, tiempo, Marea |
| 24 | Siri / Atajos / Al acostarte | 1.0 | "Que suene (o calle) por voz, y que empiece sola cuando me acueste" | Vender, explicar, enseñar |
| 25 | Focus de Sueño | 1.1 | "Cuando estoy en Sueño, que la app abra ya en Noche" | Arrancar el sonido (no lo permite la plataforma: lo hace la automatización de 24); vender nada, ni por la mañana (C08) |
| 26 | Apple Watch | 1.2 (C28) | "Pausar, quince minutos más, el nivel y la Marea en la muñeca, sin coger el iPhone" | Mezclar, elegir, comprar. En 1.0 el reloj ya controla con el Reproduciendo del sistema |
| 34 | Reproduciendo del sistema + Salida | 1.0 | "¿Qué suena y por dónde?" (bloqueo, AirPods, CarPlay, reloj) | Elegir ruta con una pantalla propia: el picker del sistema vive en Ajustes › Salida (C41) |

Regla transversal (03 §1.4, C27): **prolongar desde el bloqueo es un botón**; **Madrugada vive aquí** (actividad terminada, widget pequeño de 00:00 a 06:00, bloqueo por `widgetURL`, Centro de control, botón de Acción, Siri; Watch en 1.2), nunca en un doble toque dentro de la app; **el sonido nunca se bloquea y nada se vende fuera de la app** (§1 regla 7 de la reconciliación): ninguna superficie del sistema enseña "pro", precio, prueba, candado ni cuenta atrás de prueba.

**Ventanas horarias (las dos únicas del ecosistema):** la actividad **terminada** solo se emite si la sesión acaba entre las **21:00 y las 06:00** (fuera de esa franja la actividad se cierra con `.immediate` y nada queda en el bloqueo: a las 7 nadie quiere "20 min"). El widget pequeño en reposo, el bloqueo y el Focus ofrecen Madrugada entre las **00:00 y las 06:00** (C27, C42): antes de medianoche la persona todavía no se ha dormido y el verbo es "Dormir". La `NightWindow` de la app (21:00–07:00, C40) rige tips, venta y reseña, que aquí no existen. La **ventana de la mañana** (05:00–11:00, o fin de Manto −60 min si hay Manto; C48) es la única en que una interrupción termina la sesión en vez de pausarla, y no emite terminada.

---

## 2. Anatomía de cada superficie

### 2.19 Live Activity recortada · presentación de bloqueo (393 × 160) · 1.0 solo en escenario A (C25)

Lienzo: ancho de pantalla, 160 pt de alto (el máximo que el sistema concede; se usa entero porque los dos botones de 64 pt lo exigen, P2/P8). Fondo `activityBackgroundTint(negro)`, esquinas del sistema, sin borde propio. Márgenes internos 20 pt (columna de 353). Dos botones en posiciones fijas que nunca cambian de significado (03 §1.4, C50): **izquierda = tiempo, derecha = sonido.** En escenario B la actividad entera pasa a 1.1 y la pantalla de bloqueo muestra solo el Reproduciendo del sistema (2.34).

**El horizonte va bajo el texto, a y = 72, continuo de margen a margen.** La constante del tercio (03 §1.3) no rige en un lienzo de 160 pt con dos filas de texto: el tercio (y 53) cruzaría la palabra de estado, y una línea cortada se lee como pausa. Es la misma excepción por tamaño de lienzo que el widget pequeño (y 88). Regla: **el horizonte nunca se interrumpe; si hay texto en su cota, el que se mueve es el horizonte, no la línea.**

```
 0                 20                                   372   393
 ┌───────────────────────────────────────────────────────────┐ 0
 │                                                           │
 │  Rosa y lluvia ───────── 17 Semibold ─────────  38:12    │ 16-38   nombre · tiempo vivo 28 Medium tabular alineado a 372 (y 12-46)
 │  sonando · hasta dormirme ── 15 Medium versalitas ──      │ 40-60   versalita de estado (paso 7 de noche)
 │                                                           │
 │  ═══════════════════════════════════════════════════════  │ 72 ← horizonte 2 pt `texto`, x 20 → 372, continuo (= suena); banda 60-84
 │                                                           │
 │  ┌───────────────────────────────┐   ┌───────────────┐   │ 88
 │  │          +15 min              │   │      ❚❚       │   │      dos botones de 64 pt: x 20-280 (260) y x 308-372 (64)
 │  │   20 Medium `texto`           │   │  pause.fill   │   │      canal de 28 pt entre ambos (P8: ≥ 24)
 │  └───────────────────────────────┘   └───────────────┘   │ 152
 │                                                           │ 160
 └───────────────────────────────────────────────────────────┘
```

Las cajas del ASCII son el área del `Button` (64 pt de alto); no se dibujan salvo con Button Shapes (§6). Entre la versalita (hasta y 60) y el horizonte (72) hay 12 pt; entre el horizonte y los botones (88), 16.

**Capas (de arriba abajo, de izquierda a derecha):**

| Elemento | Estilo (escala de nueve) | Color | Medidas (pt) | Comportamiento |
|---|---|---|---|---|
| Nombre de la mezcla | 5 · Fila, 17 Semibold | `texto` | x 20, y 16, alto 22, ancho máx. 220 (x 20-240); una línea; `minimumScaleFactor(0.8)` (el nombre lo escribe el usuario) | "Rosa y lluvia", "Pared", `mezcla.esta_noche` "Esta noche" si la mezcla viva no tiene nombre (§3 de la reconciliación). Nunca el nombre de la app. Mezcla recortada (guardada o de la casa, C18): `mezcla.nombre.sin` "Mar y viento · sin Océano"; mezcla toda Pro sin acceso: Play arranca Rosa a 40 (03 §1.3) y el nombre es el de la mezcla sustituta (`la.mezcla.sustituta`, pendiente de E7) |
| Tiempo | paso 2 por tamaño (28), **Medium** tabular, `monospacedDigit()`, un solo estilo | `texto` | alineado a la derecha en x 372, y 12, alto 34, ancho máx. 120 (desde x 252; 12 pt de aire con el nombre) | `Text(timerInterval:, countsDown: true, showsHours: false)`: "38:12", lo pinta el sistema sin actualizaciones de la app **[spike I0-3: precisión por minuto en iOS 18]**. Manto: el restante con `showsHours: true` ("3:53:12"; nunca la hora de fin pelada, que a un metro se lee como "son las siete") y la versalita dice `la.hasta` "hasta las 7:00". En pausa: `Text(timerInterval:pauseTime:)` congela el valor. Fundiendo: el restante (el fundido dura lo que queda). Terminada y Madrugada: el hueco queda vacío (el tiempo va en la versalita, como fija 10 §2.11). Sin temporizador: nada |
| Versalita de estado | 7 de noche · 15 Medium `texto`, `.smallCaps()`, tracking +2 % | `texto` | x 20, y 40, alto 20 | `la.estado.sonando` "sonando · hasta dormirme" / "sonando · manto" · `la.estado.sonando.solo` "sonando" · `la.estado.pausa` "en pausa" · `la.estado.pausa.causa` "en pausa · auriculares / airpods / llamada" · `la.estado.fundiendo` "fundiendo" · `marea.estado.guiando.corto` "guiando · 6 por minuto" · `marea.estado.disolviendo` "disolviendo" · `la.estado.terminada` "se fundió a las 00:25" · `la.estado.pausa.hora` "se pausó a las 00:12 · airpods" · `la.estado.detenido` "se detuvo a las 00:12" · `la.hasta` "hasta las 7:00" (Manto) · `la.madrugada.prefijo` "madrugada · " + tiempo vivo · `la.madrugada.retirada` "se retira · " + tiempo vivo (§3). Es el único texto que cambia de contenido; nunca de posición |
| Horizonte (`SoundLine`, 03 §4.1 "Live Activity") | — | `texto` | x 20 → 372, y 72, grosor **2 pt** (`master` < 0,5 al emitir) o **3 pt** (≥ 0,5); banda de 24 (60-84) | **Continuo = suena. Ausente = pausa / terminada.** Siempre entero: nunca un hueco. Fundiendo: el grosor sigue al nivel; el fundido se lee en la palabra y en la cifra. Guiando: línea quieta a media banda (la actividad no anima; la respiración está en el oído). Nunca escribe, nunca corre |
| Botón izquierdo · tiempo | 4 · Acción nocturna, 20 Medium | `texto` | x 20-280, y 88-152 (260 × 64); texto centrado | `Button(intent: ExtendTimerIntent(.quince))`: `comun.mas15` **"+15 min"** sonando, en pausa, fundiendo, guiando **y en Madrugada** (prolonga la Madrugada 15 min, con la Marea ya disuelta si procede: el mismo intent, la misma palabra). Terminada: `madrugada.estado` **"Madrugada · 20 min"** (`SmallHoursIntent`; 03 §1.3 Silencio, C27: el único botón de texto de la terminada). **Manto o sin temporizador: el botón no existe; el espacio queda vacío y muerto** (C50; no abre nada). Pulsado: opacidad 0,6 durante 200 ms (lo único que "anima" la actividad, y lo hace el sistema). El botón izquierdo siempre significa **minutos de sonido**: añadirlos o empezarlos |
| Botón derecho · sonido | glifo 28 pt, peso Medium | `texto` | x 308-372, y 88-152 (64 × 64); glifo centrado | `Button(intent: ToggleIntent())`: `pause.fill` sonando / `play.fill` en pausa o terminada (ahí `play` arranca Madrugada: 03 §1.3, Silencio). Pausa con fundido de **3 s** (C50); reanudación 800 ms. Nunca color, nunca anillo, nunca relleno: el glifo solo (el Disco de 03 §4.4 no sale de la app: la actividad no tiene relieve) |
| Zona restante | — | — | **y 0-80**: `widgetURL("sleepnoise://noche")`; **y 80-160 fuera de los botones: nada** (la fila inferior va en un contenedor sin `Link`: el canal entre botones y el hueco del botón ausente son espacio muerto, P8) | abre la app **en Noche** si suena, en la página si no (Grafito 13.1). Nunca en la principal con sonido: a las 3 la principal deslumbra |

Qué no hay: nombre de la app, icono, "pro", precio, prueba, candado, "prueba caducada", "bajando" (C50), segundo horizonte, `texto2`, acento, animación, polilínea, barra de progreso (03 §6).

**Presupuesto y ciclo de vida (ActivityKit): una actividad por sesión, creada en Play.** `Activity.request` solo funciona con la app visible o, desde iOS 17.2, dentro del `perform()` de un `LiveActivityIntent`; desde segundo plano lo rechaza (`ActivityAuthorizationError.visibility`). Por tanto:
1. **`request` en el instante de Play** (en la app: la actividad no se ve mientras la app está delante, así que no cuesta nada y evita la carrera con `.visibility` al bloquear). Si la sesión arranca desde un intent, un Control o Siri, la solicita el propio `perform()` (`LiveActivityIntent`).
2. `staleDate` = hora de fin + 60 s mientras suena; = ahora + 20 min en el hito de pausa. **La actividad nunca depende de que la app esté viva para cambiar de estado: lo que no ocurre en un hito lo decide `isStale` en la extensión** (3.1).
3. Actualizaciones **solo por hito**: arranque, pausa / reanudación (con causa), "+15", inicio del fundido (`isFading`), inicio / disolución / retirada de la Marea, fin. Nunca periódicas: el tiempo lo cuenta `Text(timerInterval:)`. Contenido < 4 KB.
4. **Fin de sesión entre 21:00 y 06:00** (fundido completo o 20 min en pausa): `update` al estado **terminada** (misma actividad, mismo `id`) y `end(…, dismissalPolicy: .after(fin + 4 h))` **[spike I0-3: si `Button(intent:)` no se entrega en una actividad `.ended`, no se llama a `end`: la terminada vive hasta el tope de 8 h del sistema y se cierra en el siguiente `foreground`; "terminada → Madrugada" está condicionado a este spike (C25)]**. Fuera de esa franja: `end(…, dismissalPolicy: .immediate)` y nada.
5. **Límite de 8 h asumido y cerrado por la app** (C50): un Manto de más de 8 h pierde la actividad a las 7 h 55 (la app llama a `end(.immediate)` antes de que el sistema la retire) y el sonido sigue; no hay segunda actividad (no se puede solicitar desde segundo plano). El widget rectangular del bloqueo sigue diciendo "hasta las 7:00".

**Smart Stack del Watch (watchOS 11, con la actividad):** la actividad aparece sola en el Smart Stack del Watch con `supplementalActivityFamilies([.small])`: contenido = la compacta de la Isla (glifo + tiempo vivo), sin botones (watchOS no los entrega); toque → `widgetURL` (abre la app del iPhone). En 1.2 la app del Watch (2.26) **sustituye** a esa tarjeta, no la añade.

### 2.20 Dynamic Island · mínima y compacta (sin expandida, C25)

Dos presentaciones del sistema; la gramática es la de la actividad de bloqueo reducida. iPhone con Isla; en iPhone SE / 16e no existe (§6). **No hay vista expandida** (C25): la pulsación larga sobre la Isla no muestra nada propio; el toque abre la app en Noche, donde está todo.

**Mínima** (otra actividad ocupa la Isla): solo el glifo, 14 pt, `texto`: `pause.fill` suena / `play.fill` pausa o terminada. Toque: abre la app en Noche (si suena) o en la página.

**Compacta:**

```
        ┌──────────────────────────┐
        │ ❚❚ ░░░░░░░░░░░░░░ 38:12  │   leading: glifo 16 pt `texto`  ·  trailing: tiempo vivo 15 Medium tabular `texto`
        └──────────────────────────┘
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Glifo (leading) | SF Symbol 16 pt Medium | `texto` | 16 × 16, margen del sistema | `pause.fill` / `play.fill`; `.contentTransition(.symbolEffect(.replace))` lo hace el sistema al actualizar |
| Tiempo (trailing) | 15 Medium tabular | `texto` | ancho máx. 56, `minimumScaleFactor(0.8)` | `Text(timerInterval:)` ("38:12"; Manto: el restante con horas, "3:53:12"; Madrugada: "20:00"; en pausa: congelado; terminada: `play.fill` y nada en trailing) |
| Toque | — | — | toda la Isla | abre la app (Noche si suena; página si no) |

Nada alterna cada n segundos (Grafito 13.1 alternaba "38 m" / "6/min": se descarta; la Isla no parpadea). Parar una Madrugada desde la Isla no existe: pausarla (en la actividad de bloqueo) la termina a los 20 min, como toda la gramática; "Parar" vive solo en la pantalla Madrugada (03 §5 #11).

### 2.21 StandBy nocturno (la presentación de bloqueo escalada ×2, un solo control, rojo primero)

StandBy no da un lienzo propio ni admite diseño propio (C25): el sistema dibuja **la presentación de bloqueo escalada al 200 %** (393 × 160 → 786 × 320 vistos, centrada en 852 × 393). `isActivityFullscreen == true` solo permite cambiar el contenido de esa misma vista; lo que cambia es exactamente lo que la reconciliación fija: **sin nombre de mezcla, sin "+15", un solo control (pausa/play)**, todo lo demás igual. **Las reglas de tamaño mínimo (texto ≥ 24 pt vistos, formas ≥ 2 pt) se evalúan sobre el tamaño visto** (C62). Tinte rojo del sistema en poca luz. Se diseña y se juzga **en rojo**: todo `texto` (4,43 / 4,30 bajo rojo; criterio ≥ 3:1 medido en dispositivo, **[spike I0-6]**), estado por forma. **Nada se anima** (ActivityKit no lo permite y aquí tampoco se querría; `isLuminanceReduced` no cambia nada porque ya es una tinta). **Nunca venta**: ni "prueba caducada" ni ninguna otra palabra de compra (C25, C50).

```
 cotas fuente (393 × 160) · entre paréntesis, vistas (×2)
 0        20                                           372 393
 ┌─────────────────────────────────────────────────────────┐ 0
 │                                                         │
 │  38:12 ──── 48 Display Regular tabular (96) ────        │ 8-56 (16-112)
 │  sonando · hasta dormirme ── 12 Medium versalitas (24)  │ 60-72 (120-144)
 │  ═════════════════════════════════════════════════════  │ 80 (160) ← horizonte 1,5 / 2 pt fuente (3 / 4 vistos), x 20 → 372
 │                                                         │
 │                                      ┌───────────────┐  │ 88 (176)
 │          (hueco vacío y muerto)      │      ❚❚       │  │        un solo objetivo de 64 fuente (128 vistos): x 308-372
 │                                      │  glifo 28 (56)│  │
 │                                      └───────────────┘  │ 152 (304)
 └─────────────────────────────────────────────────────────┘ 160 (320)
```

La caja es el área del `Button`; no se dibuja. El glifo conserva su posición de la vista de bloqueo (derecha = sonido; nada cambia de posición, 03 §3.7); el hueco del botón izquierdo queda vacío.

| Elemento | Estilo (fuente → visto) | Color | Medidas fuente (vistas) | Comportamiento |
|---|---|---|---|---|
| Tiempo | 1 · Cifra, Display Regular 48 (96), tracking −1 %, tabular; sin unidad junto a la cifra | `texto` | x 20, y 8-56 (16-112), un solo estilo | `Text(timerInterval:)` como en bloqueo ("38:12"). Manto: el restante con horas ("3:53:12") y la versalita `la.hasta` "hasta las 7:00". Madrugada y terminada: vacío (el tiempo va en la versalita). Fundiendo: el restante |
| Versalita | 12 Medium versalitas (24 vistos), tracking +2 % | `texto` | x 20, y 60-72 (120-144) | las mismas claves que en bloqueo (§3.1). 24 pt vistos es el mínimo de C62 |
| Horizonte | — | `texto` | x 20 → 372, y 80 (160), **1,5 / 2 pt fuente = 3 / 4 pt vistos** (`master` < 0,5 / ≥ 0,5) | continuo = suena; ausente = pausa / terminada; quieto siempre; nunca un hueco |
| Botón glifo (único control) | glifo 28 (56), trazo visto ≥ 6 | `texto` | x 308-372, y 88-152 (64 fuente, 128 vistos) | `ToggleIntent`: `pause.fill` / `play.fill`; en terminada, `play.fill` arranca Madrugada **[spike I0-3]** |
| Fondo | — | `negro` | todo | removible por el sistema; en StandBy el sistema pinta sobre negro |

Bajo rojo: `texto` da 4,43 / 4,30 sobre negro según modelo A / B (02 §2.3, 03 §3.1): AA de texto grande (≥ 18 pt vistos) y de componente (≥ 3:1) en ambos modelos; si la medida en dispositivo queda por debajo de 3,5, plan B `texto` → `#F0ECE4` (C62, 04 §2.0.1). El estado se lee por `pause.fill`/`play.fill` y por la presencia del horizonte, nunca por tono. **[spike I0-6: foto calibrada a un metro de la actividad de prueba en rojo; si la versalita de 24 vistos no se lee a un metro con brillo mínimo, sube a 14 fuente (28 vistos) y se declara]**.

**StandBy · modo widgets (C42):** el widget pequeño (2.22) sin fondo (`containerBackground` removible; `showsWidgetContainerBackground == false`); el sistema lo pinta en rojo monocromo. En esa condición el pequeño enseña **solo la versalita de estado en 24 vistos, el tiempo vivo, el horizonte y el glifo; el nombre desaparece** (C62: todo texto en StandBy ≥ 24 pt vistos; 17 Semibold bajo rojo no llega). Se mide igual **[spike I0-6]**. En StandBy no hay widget mediano (1.1, y tampoco entonces).

**StandBy sin actividad (sesión parada por la noche):** el sistema enseña el reloj o los widgets; si el usuario eligió el widget pequeño de SleepNoise, verá "Dormir" con `play.fill`: un verbo (Silencio), un toque, y suena la última mezcla con su último temporizador. Entre 00:00 y 06:00 el widget pequeño en reposo dice `madrugada.estado` **"Madrugada · 20 min"** en vez de "Dormir" (C27, C42). Se recarga con `TimelineReloadPolicy` a las 00:00 y a las 06:00.

### 2.22 Widgets

Todos: `containerBackground(negro, for: .widget)` marcado removible; una tinta `texto`; sin `texto2`; sin acento (`widgetAccentable` solo en texto, horizonte y glifo; nunca en fondo, C61); sin animación; el tiempo es siempre `Text(timerInterval:)` vivo (nunca una cifra estática recargada por hito); `TimelineReloadPolicy.after(fin)` + recarga en cada hito. Interactivos por `Button(intent:)` con `AudioPlaybackIntent`: el widget suena sin abrir la app. **Solo oscura en 1.0** (C32): los widgets son negros también de día; con Papel (1.1) siguen la apariencia del sistema con `tinta` sobre `papel` (C61). Familias 1.0: pequeño "Dormir", bloqueo rectangular e inline; mediano "Mezclas" en 1.1; **sin circular** (C42).

**Pequeño (158 × 158), inicio y StandBy:**

```
 0      16                       142 158
 ┌─────────────────────────────────┐ 0
 │  Rosa y lluvia ── 17 Semibold   │ 16-38   nombre, una línea, `minimumScaleFactor(0.8)`
 │  sonando ── 15 Medium versalitas│ 44-64   versalita de estado (`widget.sonando` / `widget.silencio`)
 │  38:12 ── 17 Medium tabular     │ 64-84   tiempo vivo · en reposo, en su lugar: Dormir (17 Semibold) / Madrugada · 20 min
 │                                 │
 │  ═══════════════════════════    │ 88  horizonte 2 pt `texto`, x 16 → 142
 │                     ┌────────┐  │ 96
 │                     │   ❚❚   │  │       glifo 28 centrado en 44 × 44 (x 96-140, y 96-140)
 │                     └────────┘  │ 140
 └─────────────────────────────────┘ 158
```

**Todo el widget es un solo `Button(intent:)`** (158 × 158: un objetivo, P8); la caja del glifo marca dónde está el glifo, no un segundo objetivo, y no se dibuja. En el widget el horizonte no puede ir a un tercio (y 52) porque ahí está el texto; va a **y = 88**, bajo el texto y sobre el glifo, por la misma regla que la actividad: el horizonte se mueve, nunca se corta.

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Nombre de la última mezcla | 17 Semibold | `texto` | x 16, y 16, ancho 126, **una línea** fija, `minimumScaleFactor(0.8)` y truncado | la mezcla cargada en la app ("Rosa y lluvia"); nunca "SleepNoise"; recortada: `mezcla.nombre.sin` "Mar y viento · sin Océano"; de fábrica, si nunca hubo una: "Esta noche" con la receta de 05 |
| Versalita de estado | 7 de noche · 15 Medium versalitas | `texto` | x 16, y 44-64, una línea | `widget.sonando` "sonando" (también fundiendo y guiando: los minutos van en el tiempo vivo, y el ritmo no cabe) · `widget.silencio` "en silencio" (reposo y pausa) |
| Tiempo / verbo | 17 Medium tabular (tiempo) · 17 Semibold (verbo) | `texto` | x 16, y 64-84 | sonando: `Text(timerInterval:)` vivo; Manto: restante con horas; en pausa: congelado; reposo: `widget.dormir` **"Dormir"**; reposo 00:00-06:00: `madrugada.estado` "Madrugada · 20 min"; Madrugada sonando: `la.madrugada.prefijo` + tiempo vivo |
| Horizonte | — | `texto` | x 16 → 142, y 88, 2 pt | continuo = suena; ausente = reposo / pausa |
| Glifo | 28 pt Medium | `texto` | centrado en x 96-140, y 96-140 | `pause.fill` sonando / `play.fill` en reposo y pausa |
| Botón | — | — | **158 × 158: todo el widget** | `ToggleIntent`; en reposo arranca la última mezcla con su temporizador (`PlayLastMixIntent`); de madrugada en reposo, `SmallHoursIntent`. **No hay `widgetURL`**: abrir la app no responde a la pregunta del pequeño ("¿dormir ahora?"); el acceso a la app desde el bloqueo lo da el rectangular |

Modos *accented* / *vibrant* (iOS 18): nombre, versalita y tiempo en la capa primaria, horizonte y glifo con `widgetAccentable`; el estado sigue leyéndose por forma; nunca `widgetAccentable` en el fondo (C61). Sin fondo (StandBy "quitar fondo", bloqueo): solo versalita en 24 vistos, tiempo, horizonte y glifo (2.21).

**Mediano "Mezclas" (338 × 158) [1.1] (C42):** tres mezclas (03 §5 #22; `widget.mediano.descripcion` "Tres mezclas. Un toque y suenan."): la columna izquierda es el pequeño (un solo botón de 158 × 158) y la derecha lleva **tres filas-botón de 44** (x 182 → 322; y 8-52 · 56-100 · 104-148; hairlines `trazo` 0,5 pt entre ellas, las únicas del ecosistema), nombre 17 Semibold y, solo en xS-L, la receta en paso 7 (15) debajo del nombre como fija 10 §2.11; la que suena, con `widget.sonando` en versalita. `Button(intent: PlayMixIntent(mix:))`: **carga y reproduce** con fundido cruzado de 1,5 s (03 §5 #12); la app no se abre. Orden: las tres primeras "tuyas" y, si faltan, "de la casa" (`mezcla.casa.rosa_lluvia`, `mezcla.casa.pared`, `mezcla.casa.mar_viento`…); configurable en el intent de edición del widget. Mezcla con capas Pro sin acceso: el título honesto (`mezcla.nombre.sin`); suena lo que hay; el widget no vende. Depende de `MixEntity` estable (C42); se detalla al cerrar 1.0. El mediano no se muestra en StandBy.

**Bloqueo (iOS 17; monocromo vibrante del sistema).** Los widgets interactivos de iOS 17 funcionan en las familias de inicio y en StandBy, no en los accesorios del bloqueo: en el bloqueo todo toque abre la app por `widgetURL`. Por eso no hay `accessoryCircular` (un glifo que solo abre la app duplica al rectangular y añade una decisión; C42). La pausa desde el bloqueo la da la Live Activity (escenario A) y, en iOS 18, el `ControlWidgetToggle` en los dos botones inferiores.

| Familia | Contenido | Interacción |
|---|---|---|
| `accessoryRectangular` (≈ 160 × 72) | fila 1: nombre 15 Semibold (una línea); fila 2: `widget.sonando` + tiempo vivo / `la.hasta` "hasta las 7:00" (Manto) / `widget.silencio` "en silencio" / `madrugada.estado` "Madrugada · 20 min" (reposo 00:00-06:00) **15 Medium** (nada < 15 fuera de la app); fila 3: horizonte 2 pt de ancho completo (continuo / ausente) | toque: abre la app en Noche si suena, página si no (`widgetURL`); entre 00:00 y 06:00 en reposo, `sleepnoise://madrugada` arranca Madrugada (C27: la pantalla de bloqueo es una entrada de Madrugada) |
| `accessoryInline` | `widget.inline.prefijo` "SleepNoise · " + tiempo vivo / `widget.inline.silencio` "SleepNoise · en silencio" / `widget.inline.prefijo` + `madrugada.estado` (reposo 00:00-06:00) | abre la app (madrugada: `sleepnoise://madrugada`) |

El inline es el único sitio del ecosistema donde aparece "SleepNoise" como texto (el sistema no da nombre de widget; sin él la línea no se entiende).

### 2.23 Centro de control y botón de Acción (iOS 18+; 1.0 condicionado a la semana 14, C26)

Dos controles de `ControlWidget`, cada uno con su símbolo propio (plantilla SF Symbols, 9 pesos, 3 escalas, 03 §3.6), disponibles en el Centro de control, en la pantalla de bloqueo (los dos botones inferiores, con pulsación larga: justo lo que se quiere a las 4) y en el botón de Acción. Corren sobre los intents de C43; si en la semana 14 no están, se cortan sin coste (C26). El sistema dibuja todo: la app aporta símbolo, título, valor, pista e intent. En iOS 17 no existen: los Atajos de 2.24 cubren el caso y Ajustes lo dice. **El estado del toggle sale del snapshot `sleepnoise.session.v1` del App Group y solo cambia cuando la app llama a `ControlCenter.shared.reloadControls(ofKind:)` en cada hito.**

```
   Centro de control (pequeño 1×1 y mediano 2×1):

   ┌──────────┐   ┌──────────┐      ┌──────────────────────────────┐
   │  ⟍       │   │  ≈       │      │  ⟍   SleepNoise               │
   │          │   │          │      │      Rosa y lluvia · 45 min   │
   │SleepNoise│   │Madrugada │      └──────────────────────────────┘
   └──────────┘   └──────────┘
    toggle          botón             toggle mediano: título + subtítulo
```

| Elemento | Tipo | Símbolo | Título | Valor / subtítulo | Intent | Comportamiento |
|---|---|---|---|---|---|---|
| **SleepNoise** | `ControlWidgetToggle` | `noise.pink` (pendiente rosa, −3 dB/oct). Off: el símbolo en el gris del sistema. **On: el sistema rellena el control con `AccentColor` (`índice`; `ocre` en apariencia clara) y dibuja el símbolo en oscuro** (relleno del sistema, la única excepción de 03 §3.1 / C61; símbolo sobre `índice`: ≥ 3:1 [a medir]) | `control.titulo` "SleepNoise" (03 §5 #23; = `app.name`) | valor on: `pagina.estado.sonando` "Sonando" ["Playing"]; off: `pagina.estado.silencio` "En silencio" ["Silent"]; subtítulo on: `control.sub.on` "Rosa y lluvia · 45 min" (la mezcla y los minutos del **ajuste**: el Control no tiene reloj vivo; Manto: `la.hasta` "hasta las 7:00"); off: `control.sub.off` "Última: Rosa y lluvia" | `SetPlaybackIntent(value:)` (`SetValueIntent` + `AudioPlaybackIntent`) | on → arranca la última mezcla con su último temporizador, fundido 800 ms; off → pausa con fundido 1,5 s. Mezcla toda Pro sin acceso → Rosa a 40 (03 §1.3 "el instrumento siempre suena") y la Live Activity lo dice en el nombre |
| **Madrugada** | `ControlWidgetButton` | `tide.line` (la línea de agua, elevación 4:6) | `madrugada.titulo` "Madrugada" ["Small hours"] | `control.madrugada.sub` "20 min" | `SmallHoursIntent` | arranca la receta fija de Madrugada (C05: océano a 0,3 con Marea 8/min para todos, 20 min, entrada 3 s). No tiene estado on. **Si ya suena algo (sesión o Madrugada): no hace nada**; el valor del toggle ya dice "Sonando" (la alternativa, cortar un temporizador de 45 a los 20, sería una sorpresa nocturna) |

Pistas del botón de Acción (`controlWidgetActionHint`): `accion.pista` "Mantén para dormir" ["Hold for sleep"] (toggle) y `accion.pista.madrugada` "Mantén para Madrugada" ["Hold for Small hours"] (botón). El tinte *on* es el único momento en que el sistema pinta el acento fuera de la app; la app declara `.tint(AccentColor)` en el control y nada más. Con "Aumentar contraste" el sistema usa `índice-ac` del asset catalog.

### 2.24 Siri, Atajos y "Al acostarte" (C43, C10)

No hay pantalla propia salvo la página de texto de Ajustes (2.24.2). Lo que se especifica es la **superficie de voz**: siete `AppShortcut` con frase (`PlayLastMix`, `Pause`, `PlayMix`, `PlayLayer`, `ExtendTimer`, `SetTimer`, `SmallHours`) y dos intents sin frase (`Toggle`, `CurrentState`), todos `AudioPlaybackIntent` salvo `CurrentState` (el sistema evita el diálogo y no interrumpe el audio); `StartTide` / `StopTide` / `SetLevel` y el Focus filter pasan a 1.1 (C43). Frases en `AppShortcuts.xcstrings` (ES/EN), respuestas en `Localizable.xcstrings` (`siri.*`, 10 §5e.17) y la regla de oro: **Siri nunca vende** (sin acceso, lo Pro no suena y no se explica salvo al preguntar el estado o al pedir una capa Pro, donde `siri.pro` describe). Todas las frases con `${applicationName}` (C10: el nombre de la app nunca se escribe en una frase).

**Entidades y enumeraciones (lo único que una frase puede interpolar):**
- `MixEntity` (`AppEntity`): las mezclas guardadas de `MixStore` ("tuyas") y las cuatro de la casa (C18: `mezcla.casa.rosa_lluvia` "Rosa y lluvia", `mezcla.casa.mar_viento` "Mar y viento", `mezcla.casa.marron_hoguera` "Marrón y hoguera", `mezcla.casa.pared` "Pared"; EN "Pink and rain", "Sea and wind", "Brown and fire", "Wall"); `displayRepresentation` = nombre; consulta por nombre con tolerancia a mayúsculas y acentos. En EN las tuyas se exponen tal cual las escribió el usuario (no se traducen). `MixEntity.defaultQuery.suggestedEntities()` devuelve las tuyas + las cuatro de la casa; **tras guardar, renombrar o borrar una mezcla la app llama a `SleepNoiseShortcuts.updateAppShortcutParameters()`** (sin ese hito, "Pon Pared en SleepNoise" no se reconoce hasta el siguiente arranque).
- Capa (`AppEntity` sobre `SoundID`, nombres de `sound.*`): las once texturas de 1.0 (C19). Sinónimos: "ruido blanco / rosa / marrón" ["white / pink / brown noise"] y "tormenta" / "storm" para Trueno (C13).
- Minutos (`AppEnum`): 5 · 10 · 15 · 30 (10 §5e.14); los botones usan 15.
- Modo (`AppEnum`): `temporizador.dormirme` "Hasta dormirme" · `temporizador.manto` "Manto" · `temporizador.apagado` "Apagado"; sinónimos ES "hasta que me duerma", "toda la noche", "sin temporizador"; EN "until I sleep", "all night", "no timer" (C11). "Siesta" solo desde 1.1 (C30). `TimerMode.blanket` en código.
- Tope de la plataforma: **10 App Shortcuts con frase** por app; esta entrega usa 7 en 1.0 y 9 en 1.1 (Marea on/off, nivel).

**Los siete intents con frase y los dos sin frase** (claves de 10 §5e.14; `${applicationName}` es "SleepNoise"):

| # | Intent | Título ES [EN] | Frases ES | Frases EN | Qué hace | Respuesta hablada (solo si se pregunta o falla) |
|---|---|---|---|---|---|---|
| 1 | `PlayLastMix` | Pon ${applicationName} [Play ${applicationName}] | Pon ${applicationName} · Reproduce ${applicationName} | Play ${applicationName} · Start ${applicationName} | última mezcla, último temporizador, fundido 800 ms; solicita la Live Activity desde `perform()` (`LiveActivityIntent`). Si ya sonaba: nada cambia | ninguna; sin sesión de audio: `siri.error` "No se ha podido iniciar el sonido." ["Couldn't start the sound."] |
| 2 | `PlayMix(mix: MixEntity)` | Pon una mezcla [Play a mix] | Pon ${mix} en ${applicationName} · Pon la mezcla ${mix} en ${applicationName} | Play ${mix} in ${applicationName} · Play the ${mix} mix in ${applicationName} | carga y reproduce con fundido cruzado 1,5 s; con capas Pro sin acceso suena lo que hay (recortada, título honesto en la actividad) y no se explica | sin coincidencia: `siri.mezcla.cual` "¿Cuál de tus mezclas?" ["Which of your mixes?"] (desambiguación del sistema) |
| 3 | `PlayLayer(layer)` | Pon una capa [Play a layer] | Pon ${layer} en ${applicationName} · Pon ruido ${layer} en ${applicationName} | Play ${layer} in ${applicationName} · Play ${layer} noise in ${applicationName} | mezcla de una sola capa a 50 (libre) o la sube en la mezcla cargada; capa Pro sin acceso: no suena (sin escucha de 30 s, C06), la última mezcla sigue o arranca | capa Pro sin acceso: `siri.pro` "${layer} es Pro. Suena lo demás." ["${layer} is Pro. Playing the rest."] (describe, no vende) |
| 4 | `Pause` | Pausa ${applicationName} [Pause ${applicationName}] | Pausa ${applicationName} · Para ${applicationName} | Pause ${applicationName} · Stop ${applicationName} | fundido 1,5 s; `openAppWhenRun = false` **siempre** (REVIEW-PR3 #4) | ninguna. Si no sonaba nada: **ninguna** (no "Stopped"; REVIEW-PR3 #4) |
| 5 | `ExtendTimer(minutes)` | Añade minutos [Add minutes] | Añade ${minutes} minutos en ${applicationName} · Alarga ${applicationName} | Add ${minutes} minutes in ${applicationName} · Extend ${applicationName} | suma al temporizador vivo (también a una Madrugada); Manto: mueve la hora fija; sin temporizador: lo crea ("Hasta dormirme" con esos minutos); libre para todos, sin tope de 60 (C03). Corre **en la app**, en segundo plano, con el motor ya vivo | `siri.quedan` "Quedan %lld minutos." ["%lld minutes left."] |
| 6 | `SetTimer(mode)` | Temporizador [Timer] | Pon ${mode} en ${applicationName} · ${applicationName} ${mode} | Set ${mode} in ${applicationName} · ${applicationName} ${mode} | como la hoja Temporizador, con los valores guardados de cada modo (Manto: su hora fija); arranca si no sonaba | ninguna (el temporizador es libre, C03) |
| 7 | `SmallHours` | Madrugada [Small hours] | Madrugada en ${applicationName} · Empieza Madrugada en ${applicationName} | Small hours in ${applicationName} · Start Small hours in ${applicationName} | la receta fija de Madrugada (C05); nunca prueba ni hoja (C27); si ya suena algo, nada | ninguna |
| 8 | `Toggle` (sin frase) | Alternar [Toggle] | — (es el intent de los botones de la Live Activity, StandBy, el widget pequeño y los Atajos) | — | pausa / reanuda | ninguna |
| 9 | `CurrentState` (sin frase) | Qué suena [What's playing] | — (solo Atajos; devuelve texto y `IntentDialog`; es el que las automatizaciones usan para ramificar) | — | consulta | `siri.estado` "%@, quedan %lld minutos." · `siri.estado.sin_temporizador` "%@, sin temporizador." · `siri.estado.sin` "%@, sin %@, quedan %lld minutos." · `siri.estado.marea` "%@, Marea a %lld por minuto, quedan %lld minutos." · `siri.silencio` "Nada suena ahora." ["Nothing is playing."] |
| — | `StartTide` / `StopTide` / `SetLevel` [1.1] | Marea [Tide] · Nivel [Level] | Activa la Marea en ${applicationName} · Quita la Marea en ${applicationName} | Turn on the tide in ${applicationName} · Turn off the tide in ${applicationName} | 1.1 (C43); Marea sin acceso: no suena y no se explica; `SetLevel` = `master` de sesión (`Int` 0-100 solo como parámetro de Atajos, nunca en frase) | — |

Reglas de voz: respuestas sin exclamaciones, sin "Listo", sin "Hecho", sin precio, sin "versión", sin "insomnio", sin "mejora"; "Pro" solo en `siri.pro`, que describe; de noche, las menos posibles (los `AudioPlaybackIntent` no hablan). Todas las frases viven en **`AppShortcuts.xcstrings`** (en + es), nunca en `Localizable.xcstrings` (REVIEW-PR3 mayor #3). Ninguna frase interpola un `Int` (bloqueante #2 del PR #3). `openAppWhenRun = false` en todos. Los intents de `Button(intent:)`, de los Controls y de Siri **corren en el proceso de la app** (lanzada en segundo plano si hace falta), no en la extensión; solo `WidgetConfigurationIntent` corre en la extensión. Todos pasan por `AccessPolicy` igual que los botones y resuelven `.needsPro` **sin paywall**: recortan y describen.

**2.24.2 Página "Al acostarte" (Ajustes › Al acostarte)**: una sola pantalla empujada de texto (C43), `negro`, cabecera paso 3, cuerpo 17/26 `texto`, sin capturas, sin flechas, sin iconos; `List` del sistema con una `HairlineAction`. Es el único autoarranque de la app (C33: la app abre en reposo y suena con Play; sin ajuste "abrir sin sonar").

```
 Pantalla "Al acostarte"
 ┌────────────────────────────────┐
 │ ‹ Ajustes                       │
 │                                 │
 │ Al acostarte ── 22 Semibold     │ y 120   `ajustes.acostarte`
 │ ─────────────────── hairline    │ 152
 │ Que suene sola al activar       │ 168   `ajustes.acostarte.sub`
 │ Sueño. Dos pasos en Atajos.     │
 │                                 │
 │ En Atajos, toca Automatización  │ 232   `ajustes.acostarte.p1`
 │ y elige el modo de concentración│
 │ Sueño, "Al activarse".          │
 │                                 │
 │ Añade la acción "Pon SleepNoise"│ 328   `ajustes.acostarte.p2` (`%@` = `app.name`)
 │ y elige "Ejecutar               │
 │ inmediatamente". Desde esa      │
 │ noche sonará sola al acostarte. │
 │ ┌─────────────────────────────┐ │ 700
 │ │        Abrir Atajos         │ │  64   HairlineAction (03 §4.6) · `ajustes.acostarte.abrir`
 │ └─────────────────────────────┘ │
 └────────────────────────────────┘
```

"Abrir Atajos" abre la app Atajos con `UIApplication.shared.open(URL(string: "shortcuts://")!)` y nada más: no existe URL pública que abra "Automatización › Nueva" (`shortcuts://create-shortcut` crea atajos, no automatizaciones) y la página ya ha dicho los dos pasos. Los literales "Al activarse" / "Ejecutar inmediatamente" son los de Atajos en iOS 17 y 18 **[a medir en la build de referencia antes de compilar]**. La app **propone**; nunca instala una automatización por su cuenta. El párrafo sobre parar por la mañana y la recomendación de asignar Madrugada al botón de Acción quedan pendientes de E7 (§9); la pista del botón de Acción (`accion.pista.madrugada`) ya enseña el camino en el propio sistema.

### 2.25 Focus de Sueño [1.1] · filtro de concentración

`SetFocusFilterIntent` `focus.titulo` "SleepNoise en este modo" ["SleepNoise in this Focus"]. El usuario lo configura en Ajustes de iOS › Modos de concentración › Sueño › Filtros de apps; la app no sabe qué Focus está activo, solo recibe los parámetros del filtro. Dos parámetros y nada más:

| Parámetro | Valores | Efecto mientras el filtro está activo |
|---|---|---|
| `focus.abrir` "Abrir en" ["Open in"] | Noche (defecto, `noche.titulo`) · `focus.abrir.pagina` "Página" | la app abre en Noche si suena o va a sonar; en Madrugada entre 00:00 y 06:00 con sesión parada; nunca en la principal con sonido |
| `focus.mezcla` "Mezcla a cargar" ["Mix to load"] | `MixEntity` · `focus.mezcla.ultima` "La última" (defecto) | la mezcla queda **cargada** con Play a un toque. No arranca (la plataforma no lo permite): el arranque es la automatización de 2.24 |

Efectos implícitos (no configurables): se oculta la cabecera de prueba de la página y cualquier tip (que de noche ya no existen: `NightWindow`, C40, C65); el paso a Noche automático baja a 60 s aunque "Pasar sola a Noche" diga 3 min. **Nada se pospone a la mañana** (C08): de noche no se vende, no hay línea matinal ni recordatorio; el toque en una capa Pro no abre nada. El nivel maestro al arrancar desde intent se limita a 0,7 bajo el filtro. Ajustes de la app: una fila que explica el filtro con un botón "Abrir Ajustes" (`UIApplication.openSettingsURLString`; `App-prefs:` no está garantizado); sus cadenas quedan pendientes de E7 para 1.1 (§9).

### 2.26 Apple Watch mínimo [1.2] (C28) · 45 mm, 198 × 242

**En 1.0 y 1.1 no hay app de Watch: el reloj controla con el Reproduciendo del sistema** (pausa / play, volumen con la corona, desde la propia Live Activity en el Smart Stack mientras exista); prototipo de batería en 1.1 (C28). Lo que sigue es la especificación de 1.2, cerrada ahora para que entre sin rediseño.

Una sola pantalla, fuente del sistema de watchOS, `negro`, sin acento, sin corona de progreso, sin lista, sin mezclador, sin precio. **Nunca más de dos botones. Nunca vende.** El Watch es mando y metrónomo: no genera audio (manda al iPhone por `WCSession`). Se especifica y se mide en 45 mm; el lienzo de 41 mm (176 × 215) se deriva proporcionalmente y se mide **[a medir]**.

```
 0        16                               182 198
 ┌─────────────────────────────────────────────┐ 0
 │           Rosa y lluvia ── 15 Medium        │ 20-38   nombre `texto`, centrado
 │  ═══════════════════════════════════════   │ 80  ← horizonte 2 pt `texto` (un tercio de 242, a retícula), x 16 → 182
 │                                             │
 │                 ┌─────────┐                 │ 100
 │                 │   ❚❚    │   Disco 64      │        círculo `grafito` + relieve 1 pt, glifo 28 `texto`
 │                 │         │                 │        área táctil: la zona central, y 60-178 (198 × 118)
 │                 └─────────┘                 │ 164
 │                                   │ 2 pt    │        regla vertical efímera del nivel (x 186, y 60-178) mientras gira la corona
 │  ┌───────────────────────────────────────┐  │ 190
 │  │             +15 min                   │  │        botón de texto 17 Medium, 44 pt, a todo el ancho (canal de 12 con el Disco)
 │  └───────────────────────────────────────┘  │ 234
 └─────────────────────────────────────────────┘ 242
```

Las cajas son áreas de `Button`; solo el Disco se dibuja.

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Nombre de la mezcla | 15 Medium (fuente del sistema) | `texto` | centrado, y 20, una línea, `minimumScaleFactor(0.8)` | el de la sesión del iPhone; sin iPhone al alcance: un texto estático (pendiente de E7, §9) y **nada más** (sin Disco, sin horizonte, sin botón: no hay nada que tocar) |
| Horizonte | — | `texto` | x 16 → 182, y 80, 2 pt | continuo = suena; ausente = pausa / reposo; **respira** si la Marea guía (es la única superficie fuera del iPhone que anima, porque hay sesión extendida y la ancla viene por `WCSession`); Always-On: congelado en bajamar |
| Disco (`PlayDisc`, 03 §4.4) | glifo 28 pt | `grafito` cuerpo, `texto` glifo | círculo 64 centrado en (99, 132); área táctil 198 × 118 (y 60-178) | toque = pausa / reanuda (`.start` / `.stop`); reposo: `play.fill` arranca la última mezcla. Es el único relieve fuera de la app porque el Watch es un objeto que se toca a ciegas. Nunca deshabilitado (si no hay iPhone, no se dibuja) |
| Regla vertical del nivel | 2 pt | `texto` | x 186, y 60-178, altura llena = `master` de sesión | aparece al girar la Digital Crown y desaparece 1 s después; cifra 15 Medium tabular junto a ella (etiqueta `watch.volumen` "Volumen"); detents del sistema cada 5; `.click` en 0 y 100 |
| Botón inferior | 17 Medium | `texto` | x 16 → 182, y 190-234 (44) | sonando y madrugada: `comun.mas15` **"+15 min"** (`ExtendTimer` por `WCSession`; `.click`; anuncio `comun.min.quedan`). Reposo: `watch.madrugada` **"Madrugada · 20 min"** (`SmallHours`). Es el segundo y último botón; con Marea, la versalita `watch.marea` "8 por minuto · 12 min" bajo el horizonte |

Marea en la muñeca (C35): `.directionUp` al inicio de cada inhalación **toda la guía** (háptica "Marcada", `watch.haptica.marcada`; la "Mínima" de 3-5 respiraciones es del iPhone y opt-in). Sincronía: `WCSession` lleva `guide.anchor`, ritmo y `outputLatency`; el Watch calcula `BreathCurve` localmente (sin tráfico por ciclo). Sesión extendida `WKExtendedRuntimeSession` (mindfulness, hasta 1 h): si expira, la línea se queda y la háptica para sin aviso. Ruta AirPlay (latencia hasta 2 s): la háptica se desactiva (no se puede sincronizar). Un mensaje de `WCSession` en segundo plano no puede solicitar una Live Activity: si no existe, el Watch arranca el sonido sin ella (2.19).

**Smart Stack (1.2, sustituye a la tarjeta de 2.19):** nombre + tiempo vivo con el horizonte y el glifo; relevancia alta de 21:00 a 08:00 y mientras suena. **Complicación** circular / esquina: glifo `tide.line` (la línea de agua, 03 §3.6; `noise.pink` queda para el toggle del Centro de control y los Atajos); rectangular: nombre + tiempo vivo. Sin tracking, sin HealthKit en el Watch (C34: Salud en 2.0).

### 2.34 Reproduciendo del sistema (Now Playing) y Salida (1.0; C28, C38, C41)

`NowPlayingController` ya existe: título = el nombre de la mezcla (`nowplaying.title`; "Rosa y lluvia", "Mar y viento · sin Océano", "Esta noche"), artista = `nowplaying.artist` "SleepNoise", subtítulo "En directo" (pendiente de E7, §9), sin carátula propia (el icono del sistema), `isLiveStream = true` (sin barra de progreso: el sonido no tiene duración). Es el control remoto de 1.0 en el bloqueo (escenario B y cuando la actividad no existe), en los AirPods, en CarPlay y **en el reloj** (C28): `playCommand`, `pauseCommand`, `togglePlayPauseCommand`; `nextTrack` / `previousTrack` deshabilitados (nada que saltar). Los estados de ruta viven en la app (`estado.ruta` "Sonando · en Dormitorio", `estado.pausa.auriculares` "En pausa · auriculares"; C41) y la actividad los refleja en su versalita.

**Salida (C41):** sin superficie propia de AirPlay. `routeSharingPolicy = .longFormAudio` (la sesión aparece en el selector de salida del sistema y en el HomePod); el picker del sistema (`AVRoutePickerView`, `.tint(texto)`) es la fila `ajustes.salida` "Salida" del grupo `ajustes.seccion.salida` de Ajustes, y nada más. `outputLatency` se lee en cada `.routeChange` y corrige la ancla de la Marea y el inicio de los fundidos. Vuelta al altavoz: el nivel se capa a 0,4 (`estado.volumen` "Sonando · al 40"; C49). `longFormAudio` es incompatible con "Debajo de otro audio" (1.1, C44): al entrar en ese estado la política cambia a `mixWithOthers` solo durante la sesión, con la preferencia `ajustes.debajo` (Preguntar / Siempre / Nunca) y el botón `debajo.sonar` "Sonar debajo".

---

## 3. Estados completos

Convención de 03 §4: normal · activo · bloqueado-Pro (sin castigo) · prueba · deshabilitado · VoiceOver, más los del ecosistema: reposo, sonando, pausa (con causa), fundiendo, guiando, terminada, madrugada, error, vacío, cargando, sin red. Lo que una superficie no tiene se dice.

### 3.1 Live Activity (bloqueo, Isla, StandBy): los seis estados (C50)

| Estado | Versalita (clave · ES / EN) | Cifra | Horizonte | Botón izquierdo (tiempo; ausente en StandBy) | Botón derecho (sonido) | Cuándo entra / sale |
|---|---|---|---|---|---|---|
| **Sonando** | `la.estado.sonando` "sonando · hasta dormirme" / "playing · until I sleep" · "sonando · manto" / "playing · blanket" (modo en minúscula; Manto además `la.hasta` "hasta las 7:00" en el sitio del modo) · `la.estado.sonando.solo` "sonando" / "playing" (sin temporizador) | tiempo vivo "38:12" / restante con horas (Manto) / nada | 2 / 3 pt continuo | "+15 min" (ausente en Manto y sin temporizador, C50) | `pause.fill` | en Play; al reanudar |
| **En pausa (con causa)** | `la.estado.pausa` "en pausa" / "paused" (toque, botones, `.began` sin llamada: el sistema no dice la causa) · `la.estado.pausa.causa` "en pausa · auriculares" (`.oldDeviceUnavailable`) · "en pausa · airpods" (`pauseCommand` con auriculares conectados, C49) · "en pausa · llamada" (`CXCallObserver`, C48) | congelada (`pauseTime`) | **ausente** | "+15 min" (sigue: prolongar en pausa es legítimo) | `play.fill` | las causas de `AudioSessionObserver` + `CXCallObserver` + `pauseCommand`; `staleDate` = pausa + 20 min. Sale al reanudar; a los 20 min en pausa `isStale == true` y la extensión dibuja **terminada** sin que la app esté viva |
| **Fundiendo** | `la.estado.fundiendo` "fundiendo" / "fading" | el restante | 2 / 3 pt (el grosor sigue al nivel; el fundido se lee en la palabra y en la cifra) | "+15 min" (cancela el fundido: la ganancia vuelve en 800 ms, 03 §1.2) | `pause.fill` | `isFading == true` (fundido de ganancia de 10-15 min con cuenta entera, C31). Sale al terminar → terminada |
| **Guiando** | `marea.estado.guiando.corto` "guiando · 6 por minuto" / "guiding · 6 per minute" (sin hora de retirada: vive en la app, 03 §3.4) | tiempo vivo | 2 / 3 pt quieto a media banda (no respira) | "+15 min" | `pause.fill` | `BreathingPhase.guiding`; disolviendo: `marea.estado.disolviendo` "disolviendo" / "dissolving"; retirada: vuelve a **sonando** sin aviso (la nota "Se ha retirado. El mar sigue." es de la app) |
| **Terminada** | `la.estado.terminada` "se fundió a las 00:25" / "faded at 12:25 AM" (tras fundido) · `la.estado.pausa.hora` "se pausó a las 00:12 · airpods" (20 min en pausa por AirPods) · "se pausó a las 00:12" (otras causas; pendiente de E7) · `la.estado.detenido` "se detuvo a las 00:12" / "stopped at 12:12 AM" (motor caído no recuperado, 30 min) | vacía (sin duración: la app no te puntúa) | ausente | `madrugada.estado` **"Madrugada · 20 min"** (`SmallHours`) **[spike I0-3]** | `play.fill` (también Madrugada) | fin del fundido, 20 min en pausa o 30 min sin motor, **solo entre 21:00 y 06:00**; fuera de esa franja no hay terminada (`.immediate`). Se queda **4 h** y se descarta sola; antes si la persona la cierra |
| **Madrugada** | `la.madrugada.prefijo` "madrugada · " + tiempo vivo ("madrugada · 20:00"); últimos 5 min: `la.madrugada.retirada` "se retira · " + tiempo vivo (C60) | vacía | 2 / 3 pt continuo (con Marea la línea de agua no se distingue a esta escala; se dibuja igual) | **"+15 min"** (`ExtendTimer`: prolonga la Madrugada) | `pause.fill` | `SmallHours` desde la actividad terminada, el Control, el botón de Acción, Siri, el widget o el bloqueo; al terminar → terminada ("se fundió a las 04:01") |

Bloqueado-Pro / prueba / deshabilitado: **no aplican**. La actividad nunca enseña "pro", prueba ni "prueba caducada" (C25, C50); una mezcla recortada se nombra con el título honesto (`mezcla.nombre.sin`), nada más. VoiceOver: §5 (b).

**Error.** La actividad no tiene estado de error propio: el fallo de audio a mitad de la noche que no se recupera en 10 s es **en pausa** (`la.estado.pausa`, sin causa: no se afirma lo que no se sabe) con `play.fill`. Toque en `play.fill`: reintento por `Toggle`. Si falla, la versalita no cambia y el glifo sigue en `play.fill` (un intent fallido no puede abrir la app: `openAppWhenRun = false`); el resto de la actividad (`widgetURL`, y 0-80) abre la app, donde está la escalera del error (08 / Diagnóstico, C56). A los 30 min sin motor: terminada con `la.estado.detenido`. Nunca rojo, nunca código, nunca notificación push (no hay).

**Cargando / sin red / vacío.** No existen: la actividad se emite con datos locales; no hay red que esperar; no hay estado vacío porque sin sesión no hay actividad.

### 3.2 Dynamic Island (mínima · compacta)

| Estado | Mínima | Compacta (leading · trailing) |
|---|---|---|
| Sonando | `pause.fill` | `pause.fill` · "38:12" (Manto: "3:53:12") |
| En pausa | `play.fill` | `play.fill` · congelado |
| Fundiendo | `pause.fill` | `pause.fill` · el restante |
| Guiando | `pause.fill` | `pause.fill` · "38:12" (el ritmo se lee en la app) |
| Terminada | `play.fill` | `play.fill` · nada |
| Madrugada | `pause.fill` | `pause.fill` · "20:00" |

### 3.3 StandBy nocturno

Los mismos seis estados que 3.1 con las cotas de 2.21 (fuente ×2) y **un solo control** (C25): en **terminada**, cifra vacía, versalita "se fundió a las 00:25" en 24 vistos, `play.fill` (arranca Madrugada **[spike I0-3]**); en **madrugada**, versalita "madrugada · 20:00", `pause.fill`. Sin "+15", sin nombre, sin venta. Sin estado de carga ni de red. Always-On atenuado (`isLuminanceReduced`): el sistema reduce luminancia; la composición no cambia (ya es una tinta).

### 3.4 Widgets

| Estado | Pequeño | Mediano [1.1] (columna derecha) | Bloqueo rectangular | Inline |
|---|---|---|---|---|
| **Reposo** (nada suena) | nombre de la última mezcla · "en silencio" · "Dormir" · horizonte ausente · `play.fill` | tres mezclas; ninguna marcada | nombre · "en silencio" · sin horizonte | "SleepNoise · en silencio" |
| **Reposo 00:00-06:00** | nombre · "en silencio" · "Madrugada · 20 min" · `play.fill` (→ `SmallHours`) | igual | nombre · "Madrugada · 20 min" (`widgetURL` → Madrugada) | "SleepNoise · Madrugada · 20 min" |
| **Sonando** | nombre · "sonando" · tiempo vivo (Manto: restante con horas) · horizonte 2 pt · `pause.fill` | la que suena: "sonando" | nombre · "sonando" + tiempo vivo / "hasta las 7:00" (Manto) · horizonte | "SleepNoise · " + tiempo vivo |
| **En pausa** | "en silencio" · tiempo congelado · horizonte ausente · `play.fill` | la pausada: "en silencio" | "en silencio" | "SleepNoise · en silencio" |
| **Fundiendo / guiando / madrugada** | "sonando" + tiempo vivo (madrugada: "madrugada · " + tiempo vivo); sin ritmo (no cabe; vive en la app) | igual que sonando | igual | igual que sonando |
| **Vacío** (sin mezclas propias) | no existe: siempre hay una última mezcla ("Esta noche" de fábrica) | las de la casa | — | — |
| **Bloqueado-Pro** | no existe: el widget no vende; la mezcla con capas Pro muestra el título honesto | "Mar y viento · sin Océano" | — | — |
| **Cargando** | no existe: datos locales | — | — | — |
| **Marcador de posición** (galería de widgets, `placeholder`) | "Rosa y lluvia" · "en silencio" · "Dormir" · `play.fill` redactados por el sistema | tres nombres de la casa | — | — |

Ninguna celda enseña una cifra de minutos estática: el tiempo lo pinta siempre `Text(timerInterval:)`.

### 3.5 Centro de control y botón de Acción

| Estado | Toggle "SleepNoise" | Botón "Madrugada" |
|---|---|---|
| Reposo | off (símbolo gris del sistema) · "En silencio" · "Última: Rosa y lluvia" | "20 min" |
| Sonando | **on** (relleno `AccentColor` del sistema) · "Sonando" · "Rosa y lluvia · 45 min" / "Rosa y lluvia · hasta las 7:00" | "20 min" (si se pulsa: nada; ya suena) |
| En pausa | off · "En silencio" · "Última: Rosa y lluvia" (el toggle a off refleja que no suena) | "20 min" (arranca Madrugada: la sesión en pausa termina) |
| Madrugada | on · "Sonando" · "Madrugada · 20 min" | "20 min" (si se pulsa: nada) |
| Pulsado (en curso) | el sistema anima el cambio; la app no añade nada | el sistema |
| Error de audio | off · "En silencio" (la escalera del error vive en la app; `siri.error` solo se dice por voz) | — |
| Bloqueado-Pro | no existe | no existe (Madrugada es para todos) |

### 3.6 Siri / Atajos

| Situación | Respuesta |
|---|---|
| Intent de reproducción, éxito | ninguna (el sonido es la respuesta) |
| Pausa sin nada sonando | ninguna |
| Mezcla con capas Pro, sin acceso | ninguna: suena lo que hay (la actividad lleva el título honesto) |
| Capa Pro por voz, sin acceso | `siri.pro` "%@ es Pro. Suena lo demás." |
| Mezcla que no existe | `siri.mezcla.cual` "¿Cuál de tus mezclas?" |
| Extender | `siri.quedan` "Quedan %lld minutos." (sin tope, C03) |
| Error de audio al arrancar por voz | `siri.error` "No se ha podido iniciar el sonido." (sin "inténtalo", sin pantalla) |
| Estado | `siri.estado` / `.sin_temporizador` / `.sin` / `.marea` / `siri.silencio` "Nada suena ahora." |

### 3.7 Focus de Sueño [1.1] y Watch [1.2]

Focus: activo (filtro aplicado) / inactivo / no configurado (nada cambia; la fila de Ajustes explica). Watch: reposo ("Madrugada · 20 min" como botón inferior, `play.fill`), sonando ("+15 min", `pause.fill`), en pausa (`play.fill`, "+15 min"), guiando (horizonte respira; háptica; `watch.marea`), madrugada ("madrugada · 20:00"; botón inferior "+15 min"), **iPhone fuera de alcance** (texto estático 15 Medium `texto`; sin Disco, sin horizonte, sin botón: no hay estado deshabilitado y no hay `texto3` fuera de la app), cargando (los primeros 2 s tras abrir: nombre "—" y horizonte ausente; sin spinner).

---

## 4. Flujos: entradas, salidas, interrupciones

### 4.1 Play → bloquear con sesión sonando → Live Activity → desbloquear (escenario A)

1. 23:40, página sonando "Rosa y lluvia · 45 min". La actividad ya existe desde Play (no se ve con la app delante). Bloquea. **Se oye:** nada cambia. **Se ve (bloqueo):** la actividad está ahí con "sonando · hasta dormirme", "45:00" contando, horizonte 2 / 3 pt, "+15 min" y `pause.fill`. **Se siente:** nada (segundo plano: nunca vibra, 03 §3.8).
2. Deja el iPhone en la mesilla. Si entra en StandBy: 2.21 en rojo, un solo control; si Always-On: el sistema atenúa; si se apaga: nada, cero fotogramas.
3. 00:15, se despierta, levanta el iPhone (raise to wake). Lee "20:00" en la cifra, toca "+15 min" **sin desbloquear**: `ExtendTimer` corre **en la app, en segundo plano, con el motor ya vivo**; la cifra pasa a "35:00" (`.numericText()` lo hace el sistema al actualizar); **se oye:** nada (sigue igual); **se siente:** nada (la Live Activity no vibra; la confirmación es la cifra). Si estaba fundiendo, la ganancia vuelve en 800 ms y la versalita vuelve a "sonando · hasta dormirme".
4. Desbloquea: la app abre **en Noche** (`widgetURL` o `scenePhase`), no en la página; 03 §5 #10.
5. 00:50, fundido completo. La misma actividad pasa a **terminada** (`update` + `end(.after(fin + 4 h))`): "Rosa y lluvia", "se fundió a las 00:50", "Madrugada · 20 min", `play.fill`. Se queda 4 h.

En escenario B no hay actividad en 1.0: el bloqueo muestra el Reproduciendo del sistema (pausa / play, volumen); "+15" y Madrugada viven en Noche, el widget, el Control y Siri.

### 4.2 Madrugada desde la actividad terminada

1. 03:41, el iPhone en la mesilla, pantalla apagada o StandBy en rojo. Toca o levanta: bloqueo con la terminada.
2. Toca **"Madrugada · 20 min"** (o `play.fill`). `SmallHours` **sin abrir la app** **[spike I0-3]**. **Se oye (C05):** océano fijo a nivel bajo (0,3) que sube de 0 en 3 s (a las 3 nada llega de golpe), con la Marea a 8 por minuto desde el primer ciclo para todos; nunca la última mezcla, nunca una sustituta, nunca prueba ni paywall. **Se ve:** la actividad pasa a "madrugada · 20:00" bajando, horizonte continuo, "+15 min", `pause.fill`. **Se siente:** nada.
3. Si desbloquea: la app abre en **Madrugada** (07): "20 min", sin hora (opt-in en Ajustes, C60), "Parar".
4. Hacia el minuto 13 la Marea se retira; minutos 15-20: el mar funde ("se retira · 4:59"); la actividad → terminada ("se fundió a las 04:01"). Nada vibra, nada se enciende, nada al terminar.
5. 04:30, otra vez: el mismo gesto, otros 20. Sin contador, sin límite, sin "¿cómo has dormido?".
6. Si la terminada ya se descartó (> 4 h), o en escenario B: el widget pequeño en reposo dice "Madrugada · 20 min"; el rectangular del bloqueo también (`widgetURL`); el Centro de control tiene "Madrugada"; el botón de Acción, si se asignó; Siri "Madrugada en SleepNoise"; el Watch en 1.2.

### 4.3 Dormir sin abrir la app (Control / botón de Acción / Siri / widget)

Entrada: toggle on, "Mantén para dormir", "Pon SleepNoise", `play.fill` del widget. **Se oye:** última mezcla, último temporizador (entero, sin recorte: el temporizador es libre, C03), fundido 800 ms (Rosa a 40 si la mezcla era toda Pro sin acceso; capas Pro sin acceso a cero: la degradación nunca escribe, C23). **Se ve:** la Live Activity (A), solicitada desde el `perform()` del intent (`LiveActivityIntent`, iOS 17.2+; en 17.0-17.1 no hay actividad hasta que la app pase a primer plano); el toggle pasa a on tras `reloadControls`. **Se siente:** la háptica del propio sistema del Control, ninguna de la app. Siri: silencio (`AudioPlaybackIntent`). Prueba: se evalúa **solo aquí**, al arrancar la sesión (03 §1.3 Dial): noche 7 arrancada por Atajo a las 23:50 es noche 7 entera; ninguna superficie del sistema la nombra.

### 4.4 Interrupciones (C48, C49: `AudioSessionObserver` + `CXCallObserver` + `pauseCommand`)

Regla madre (C48): **dentro de la ventana de la mañana (05:00–11:00, o fin de Manto −60 min si hay Manto) ninguna interrupción reanuda: la sesión termina** (`end(.immediate)`, sin terminada; es la alarma del sistema, que no se distingue de otra interrupción y debe ganar siempre, también a un Hasta dormirme de 6 h puesto a la 1:00); **fuera de ella, toda interrupción reanuda al terminar con fundido de 3 s**, y una llamada (`CXCallObserver`) nunca termina la sesión. La tabla es igual para todos los modos.

| Causa | Audio | Actividad | Al terminar la interrupción (fuera de la ventana) | Dentro de la ventana de la mañana |
|---|---|---|---|---|
| Interrupción del sistema (`.began`; Siri, alarma, otra app) | fundido 300 ms (la otra fuente ya suena) | "en pausa" (`la.estado.pausa`); `play.fill`; horizonte ausente; cifra congelada; `staleDate` = ahora + 20 min | `.ended` → reanuda con fundido de 3 s, misma fase de la Marea; un toque en cualquier superficie reanuda antes; 20 min en pausa → terminada por `isStale` | la interrupción **termina** la sesión: `end(.immediate)`, sin terminada |
| Llamada (`CXCallObserver`, C48) | igual | "en pausa · llamada" (`la.estado.pausa.causa`); `play.fill` | al colgar, reanuda con fundido de 3 s; nunca termina la sesión | termina (coste aceptado en C48) |
| Auriculares fuera / desconectados (`.oldDeviceUnavailable`) | **fundido de 40 ms y pausa** (C49); **nunca** salta al altavoz | "en pausa · auriculares"; `play.fill` | al reconectar en < 20 min: sola, 800 ms, al nivel completo. **Nunca reanuda sola por el altavoz**; "Seguir por el altavoz" (`ruta.seguir_altavoz`, 60 s) vive en la app (Noche y página), no en la actividad; el toque en `play.fill` de la actividad reanuda **capado a 0,4** si la ruta cambió (`estado.volumen` "Sonando · al 40" lo dice la app) | termina |
| `pauseCommand` con auriculares conectados (botón del bloqueo, toque en el auricular, pausa automática de AirPods: C49 los trata igual) | **fundido de 3 s** | "en pausa · airpods"; `play.fill` | toque reanuda (800 ms); 20 min en pausa → terminada "se pausó a las 00:12 · airpods" (`la.estado.pausa.hora`) | termina |
| `pauseCommand` por el altavoz | fundido 1,5 s | "en pausa" (sin causa) | toque reanuda; 20 min → terminada "se pausó a las …" (pendiente de E7) | termina |
| `mediaServicesWereReset` | el motor se reconstruye y reanuda en < 2 s con 800 ms sin decir nada | si no lo consigue en 10 s: "en pausa"; `play.fill` | toque en `play.fill` → reintento por intent; si falla, nada cambia; el resto de la actividad abre la app (escalera del error, Diagnóstico); 30 min sin motor → terminada "se detuvo a las …" | termina |
| Cambio de ruta a AirPlay / HomePod (`.routeChange`) | sigue; `outputLatency` se lee y la ancla de la Marea y los fundidos se corrigen (C41) | nada cambia (la app dice "Sonando · en Dormitorio") | — | — |

### 4.5 Manto > 8 h (C50)

22:30 arranca con Manto "hasta las 7:00". La actividad se emite en Play con `staleDate` 06:25, cifra = el restante con horas ("8:30:00") y versalita "hasta las 7:00". A las 06:25 (7 h 55) **la app cierra la actividad** (`end(.immediate)`) antes de que el sistema la retire a las 8 h; no se solicita una segunda (desde segundo plano no se puede): el bloqueo queda limpio, el sonido sigue (el Reproduciendo del sistema lo controla), el widget rectangular dice "hasta las 7:00". La envolvente del Manto (−6 dB a los 45 min, C22) y el fundido final de ganancia (10-15 min, C31) no emiten nada si la actividad ya no existe; **no** se emite terminada por la mañana (fuera de 21:00-06:00).

### 4.6 Salidas

- La actividad terminada se va sola a las 4 h; la persona puede descartarla antes (gesto del sistema): no vuelve a aparecer hasta la siguiente sesión.
- Cerrar la app a mano (app switcher) con sesión sonando: el audio para; la app no puede avisar a la actividad (el proceso muere). El sistema la retira al forzar el cierre **[spike I0-3: comprobar en iOS 17 y 18; si no la retira, `staleDate` (fin + 60 s) la atenúa y la vista estale dibuja "se detuvo a las …" con la hora prevista]**.
- Comprar Pro con la actividad viva: nada cambia en ella (no enseña Pro); la capa Pro entra con 800 ms y, si la mezcla se llamaba "Mar y viento · sin Océano", el nombre vuelve a "Mar y viento" en el siguiente hito.
- Fin de la prueba con la actividad viva: nada cambia en ella (la prueba se evalúa solo al arrancar una sesión, 03 §1.3; la degradación nunca escribe, C23).

---

## 5. Las cinco tablas obligatorias

### 5 (a) Movimiento: elemento → señal del motor → duración / curva → Reduce Motion → Always-On / `isLuminanceReduced`

Fuera de la app casi nada se mueve, y lo que se mueve lo mueve el sistema. La tabla existe para demostrarlo (03 §3.7: "la tabla M1…Mn nombra la señal").

| M | Elemento | Qué cambia | Señal del motor | Duración · curva | Reduce Motion | Always-On / `isLuminanceReduced` / StandBy |
|---|---|---|---|---|---|---|
| M1 | Live Activity · cualquier cambio de estado | contenido (versalita, cifra, glifo, horizonte presente/ausente, grosor) | hito: `isPlaying`, `isFading`, `BreathingPhase`, interrupción (con causa), fin; o `isStale` en la extensión | lo decide el sistema al aplicar `update(…)`; la app no anima nada | igual | igual; en StandBy, igual (nada se anima nunca) |
| M2 | Live Activity, Isla, StandBy, widgets · tiempo vivo | dígitos | `endDate` (y `pauseTime`) al emitir | `Text(timerInterval:)`: lo pinta el sistema; al pulsar "+15", el sistema aplica `.numericText()` en la actualización **[spike I0-3: precisión por minuto en iOS 18]** | sustitución seca | el sistema decide la tasa en Always-On |
| M3 | Live Activity · botón pulsado | opacidad 0,6 | toque | 200 ms, del sistema | igual | — |
| M4 | Horizonte en actividad / widget | grosor 2 ↔ 3 pt (StandBy 3 ↔ 4 vistos) entre hitos | `master` de `EngineCommand` (C51; nivel de sesión con rampa, en 1.0), leído **una vez** por hito; umbral ≥ 0,5 → 3 pt, < 0,5 → 2 pt | cambio seco en la actualización | igual | igual |
| M5 | Isla · glifo play ↔ pause | sustitución | `isPlaying` | `.contentTransition(.symbolEffect(.replace))`, 250 ms, lo hace el sistema | fundido (ya lo es) | — |
| M6 | Isla · aparición / desaparición de la compacta | geometría | el sistema | del sistema | del sistema | — |
| M7 | Widget · recarga | contenido | hitos: `WidgetCenter.shared.reloadTimelines(ofKind:)` en cada hito + `TimelineReloadPolicy.after(fin)` | ninguna animación | igual | StandBy: el sistema pinta |
| M8 | Control · toggle on/off | relleno del control | `isPlaying` en el snapshot + `ControlCenter.shared.reloadControls(ofKind:)` en cada hito | del sistema | del sistema | — |
| M9 | Watch · horizonte respirando [1.2] | elevación de la línea en banda de 24 pt | `BreathCurve` con `guide.anchor` + `outputLatency` por `WCSession`; `TimelineView` a 30 Hz pausable | 7,5-15 s por ciclo, 4:6, la curva del audio (nunca `sin()`) | posición fija a media banda; opacidad 0,6 → 1,0 con la misma curva | Always-On: congelado en bajamar en ≤ 2 s; pantalla apagada: 0 fotogramas |
| M10 | Watch · regla vertical del nivel [1.2] | altura; aparece / desaparece | giro de la Digital Crown → `master` | 0 ms al seguir la corona; 1 s `.easeInOut` para irse tras soltar | igual | — |
| M11 | Watch · Disco pulsado [1.2] | sombra interior 1 → 2 pt | toque | 200 ms `.easeInOut` | igual | — |
| M12 | Transición al abrir la app desde la actividad | la app aparece en Noche | `widgetURL` | la del sistema (abrir app); Noche ya está dibujada, sin fundido propio | — | — |

Lo que no se mueve nunca fuera de la app: el horizonte de la actividad (no respira, no escribe, no se corta), ningún `symbolEffect` salvo el `.replace` del glifo, ningún fundido propio de opacidad. Presupuesto: cero fotogramas de la app con la pantalla apagada; la extensión de widget no corre código entre hitos; la app no tiene `Timer` periódico con la pantalla bloqueada (cabecera: hitos, no ticker).

### 5 (b) VoiceOver por control: etiqueta → valor → pista → rasgos → acciones personalizadas

Las claves `ax.*` son de 10 §5e.16; las que 10 aún no tiene se marcan *(E7)* y van a §9.

| Superficie · control | Etiqueta ES [EN] | Valor | Pista | Rasgos | Acciones personalizadas |
|---|---|---|---|---|---|
| LA · actividad (contenedor) | "SleepNoise, Rosa y lluvia" ["SleepNoise, Pink and rain"] *(E7: `la.vo.contenedor`)* | el estado hablado: "sonando, quedan treinta y ocho minutos" / "en pausa, auriculares" / "fundiendo, quedan ocho minutos" / "guiando, seis por minuto" / "terminada, se fundió a las doce y veinticinco" / "madrugada, quedan doce minutos" *(E7: `la.vo.estado.*`; de `ax.noche.valor` y `ax.madrugada.valor` se toma la redacción)* | "Toca dos veces para abrir." ["Double-tap to open."] *(E7: `la.vo.abrir`)* | `.button`; sin `.updatesFrequently` (cambia por hitos); `.startsMediaSession` en el botón, no aquí | "Quince minutos más" (`ax.mas15`), "Pausar" / "Reanudar" (`ax.accion.pausar` / `.reanudar`), "Madrugada, veinte minutos" (`ax.la.madrugada`, en terminada) |
| LA · botón izquierdo | `ax.mas15` "Quince minutos más" ["Fifteen more minutes"] (también en madrugada) · terminada: `ax.la.madrugada` "Madrugada, veinte minutos" ["Small hours, twenty minutes"] | — | — | `.button` | — (tras activar, anuncio `ax.anuncio.quedan` "Quedan cincuenta y tres minutos"; Manto: `ax.anuncio.hasta` "Hasta las siete y cuarto") |
| LA · botón derecho | `ax.la.pausar` "Pausar SleepNoise" / `ax.la.reproducir` "Reproducir SleepNoise" ["Pause SleepNoise" / "Play SleepNoise"] · terminada: `ax.la.madrugada` "Madrugada, veinte minutos" | — | — | `.button`, `.startsMediaSession` | — (anuncio "En pausa" / "Sonando", los de 10 5b) |
| LA · horizonte | oculto (`accessibilityHidden`): el estado ya está en el valor del contenedor | — | — | — | — |
| LA · Smart Stack del Watch | "SleepNoise, sonando, quedan treinta y ocho minutos" | — | "Toca dos veces para abrir en el iPhone." *(E7)* | `.button` | — |
| Isla · compacta / mínima | "SleepNoise, sonando, treinta y ocho minutos" *(E7: `di.vo.etiqueta`)* | — | "Toca dos veces para abrir." | `.button` | las de la actividad |
| StandBy (un solo control, C25) | `ax.la.pausar` / `ax.la.reproducir` | — | — | `.button`, `.startsMediaSession` | — |
| Widget pequeño (todo el widget es el botón) | `ax.widget.pequeno` "%@, %@. %@" → "Rosa y lluvia, en silencio. Dormir." / "Rosa y lluvia, sonando. Pausar." · madrugada en reposo: "Rosa y lluvia, en silencio. Madrugada, veinte minutos." | — | — | `.button`, `.startsMediaSession` | — |
| Widget mediano · fila [1.1] | `ax.widget.fila` "%@, %@. Reproducir." ["%@, %@. Play."] (nombre, receta hablada; recortada: + `ax.receta.pro` "océano requiere Pro") | la que suena: "sonando" | — | `.button` | — |
| Widget bloqueo rectangular / inline | "SleepNoise, Rosa y lluvia, quedan treinta y ocho minutos" / "…, en silencio" / "…, Madrugada, veinte minutos" *(E7: `widget.vo.rect`)* | — | "Toca dos veces para abrir." | `.button` | — |
| Control · toggle | "SleepNoise" | "activado, Sonando, Rosa y lluvia, cuarenta y cinco minutos" / "desactivado, En silencio" (compuesto por el sistema de título, valor y subtítulo) | del sistema | `Toggle` del sistema | — |
| Control · botón Madrugada | `ax.control.madrugada` "Madrugada, veinte minutos" ["Small hours, twenty minutes"] | — | del sistema | `.button` | — |
| Botón de Acción | lo que el sistema anuncie con `accion.pista` "Mantén para dormir" / `accion.pista.madrugada` "Mantén para Madrugada" | | | | |
| Siri / Atajos | las respuestas de 3.6 son el anuncio; cada intent lleva `title` y `description` localizados (10 §5e.14) | | | | |
| Ajustes · fila "Al acostarte" | `ajustes.acostarte` "Al acostarte" ["At bedtime"] | `ajustes.acostarte.sub` "Que suene sola al activar Sueño. Dos pasos en Atajos." | del sistema (`EditorialRow`, 03 §4.7) | `.button` | — |
| Al acostarte · cabecera | "Al acostarte" | — | — | `.header` | — |
| Al acostarte · "Abrir Atajos" (`HairlineAction`) | `ajustes.acostarte.abrir` "Abrir Atajos" ["Open Shortcuts"] | — | "Abre la app Atajos." *(E7)* | `.button` | — |
| Ajustes · Salida (`AVRoutePickerView`) | `ajustes.salida` "Salida" ["Output"] | la ruta actual (del sistema) | del sistema | del sistema | — |
| Ajustes · fila del Focus [1.1] | *(E7, 1.1)* | | — | `.staticText` | — |
| Focus filter [1.1] | `focus.titulo` "SleepNoise en este modo" · parámetros `focus.abrir` / `focus.mezcla` | valores | del sistema | del sistema | — |
| Watch · Disco [1.2] | "Pausar" / "Reproducir" (`ax.accion.pausar` / `ax.accion.reanudar` como redacción) | "Rosa y lluvia, quedan treinta y ocho minutos" | — | `.button`, `.startsMediaSession` | "Quince minutos más", "Madrugada", "Volumen" |
| Watch · nivel [1.2] | `watch.volumen` "Volumen" ["Volume"] | "sesenta y cuatro por ciento" | *(E7: "Gira la corona.")* | `.adjustable` (pasos 5) | `ax.accion.silenciar` "Silenciar" / `ax.accion.maximo` "Máximo" |
| Watch · botón inferior [1.2] | `ax.mas15` "Quince minutos más" / `ax.la.madrugada` "Madrugada, veinte minutos" | — | — | `.button` | — |
| Watch · "iPhone fuera de alcance" [1.2] | *(E7)* | — | — | `.staticText` | — |
| Watch · Smart Stack / complicación [1.2] | "SleepNoise, Rosa y lluvia, quedan treinta y ocho minutos" / "SleepNoise, en silencio" | — | "Toca dos veces para abrir." | `.button` | — |
| Watch · Marea háptica [1.2] | anuncio opcional "Inhala" / "Exhala" (`marea.fase.*` de 10), ajuste "Guía hablada" *(E7, 1.2)*, apagado por defecto | | | | |

**Orden de lectura en la actividad: contenedor → botón izquierdo ("+15 min") → botón derecho (glifo)**, el orden visual. Pausar desde cualquier foco es el **Magic Tap** (`.startsMediaSession`): así las dos acciones a ciegas son "Magic Tap = pausa" y "siguiente + doble toque = +15". VoiceOver no detiene la cama (ducking del sistema, 02 §7.8). Cada háptico del Watch tiene su anuncio (§7).

### 5 (c) Gesto → alternativa sin gesto → Control por botón → teclado / Pointer

| Gesto | Dónde | Alternativa sin gesto | Control por botón / Control por voz / Acceso asistido | Teclado completo / Pointer (iPad) |
|---|---|---|---|---|
| Toque en "+15 min" | LA | ya es un toque simple; Siri "Añade quince minutos en SleepNoise"; Noche "+15 min"; Watch [1.2] | elemento "Quince minutos más"; Control por voz: "Quince minutos más" | — fuera de la app (el foco de teclado sobre botones de una actividad en el bloqueo de iPadOS no está documentado [a medir]) |
| Toque en el glifo | LA, StandBy, widget | toque simple; Siri "Pausa SleepNoise"; botones de los auriculares; toggle del Centro de control; Magic Tap | elemento "Pausar / Reproducir"; Control por voz: "Pausar SleepNoise" | — |
| Raise to wake + toque "Madrugada · 20 min" | bloqueo | Siri "Madrugada en SleepNoise"; botón de Acción; Centro de control; widget pequeño y rectangular de madrugada; Watch [1.2] | elemento "Madrugada, veinte minutos"; Control por voz: "Madrugada" | — |
| Mantener el botón de Acción | iPhone 15 Pro+ / 16 / 16e / 17 | el control en el Centro de control (toque); Siri | Control por voz: "Pon SleepNoise" (Atajo) | — |
| Pulsación larga en los controles del bloqueo (iOS 18) | bloqueo | los mismos controles en el Centro de control con toque simple | elemento del sistema | — |
| Deslizar para descartar la actividad terminada | bloqueo | esperar 4 h (se va sola) | acción del sistema "Borrar" | — |
| Volver desde el borde | Al acostarte (Ajustes) | botón ‹ del sistema | elemento "Atrás" | Esc |
| Giro de la Digital Crown [1.2] | Watch | acciones "Subir" / "Bajar" en el rotor; "Silenciar", "Máximo" | AssistiveTouch del Watch: acciones del elemento "Volumen" | — |
| Toque en la zona central [1.2] | Watch | el Disco es un botón con foco | elemento "Pausar / Reproducir" | — |
| Hablar a Siri | todas | todo lo que Siri hace tiene un botón: Live Activity, Centro de control, widget, app; Watch [1.2] | Control por voz ejecuta los Atajos por nombre | — |

Ningún gesto es la única vía; ninguno es de varios dedos ni de pellizco; ninguno es oculto (C27: Madrugada siempre es un botón). Fuera de la app no hay arrastres propios: todo es toque, pulsación larga del sistema o corona.

### 5 (d) Dynamic Type por tramo

Las superficies del sistema escalan con la categoría de contenido del usuario; ActivityKit, WidgetKit y los controles limitan el lienzo, no el texto. La Isla compacta / mínima es del sistema. **StandBy no sigue Dynamic Type en ningún tramo: la cifra ya es grande** (es la vista de bloqueo escalada ×2; el sistema la dibuja igual). Qué cambia en cada tramo:

| Tramo | Live Activity (bloqueo) | StandBy | Widget pequeño | Widget mediano [1.1] | Bloqueo (rect. / inline) | Control | Al acostarte / Ajustes | Watch [1.2] |
|---|---|---|---|---|---|---|---|---|
| **xS-L** | lo especificado: nombre 17, versalita 15, cifra 28, botones 64 | lo de 2.21 | 17 / 15 / 17 / glifo 28 | filas 44, nombre 17, receta 15 | 15 / 15 | título del sistema | cabecera 22 (`.title2`), cuerpo 17/26 (`.body`), `HairlineAction` 64 | 15 / Disco 64 / 17 |
| **xL-xxxL** | nombre hasta 23 (`.headline`), versalita hasta 20 (`.subheadline`), cifra hasta 34 (`.title1` tope); el lienzo sigue en 160: **el horizonte se queda en y 72** y el texto crece hacia arriba (nombre y 8, versalita y 36-60); botones 64 (no crecen: ya son grandes), texto "+15 min" hasta 26 (`.title3`) | no cambia | nombre a dos líneas (16-60); versalita y tiempo en una línea 18 en y 64-84; horizonte baja a y 96; el glifo se queda en 96-140 (el horizonte toca el glifo: se acepta; nada se corta) | dos filas si no caben tres (`ViewThatFits`); sin receta | rectangular: la fila 2 se funde con la 1 ("Rosa y lluvia · 38:12") | del sistema | cabecera hasta 28, cuerpo hasta 23; `HairlineAction` crece en alto | nombre 17; "+15 min" 20 |
| **AX1-AX2** | nombre 28 (tope `.headline` AX2 ≈ 28), cifra tope 40; **la versalita desaparece** (el estado está en el glifo, el horizonte y VoiceOver); nombre a dos líneas si hace falta; botones 64; "+15 min" 28; horizonte en y 72, bajo el nombre | no cambia | nombre 1 línea con `minimumScaleFactor(0.8)` + tiempo / verbo 2 líneas, **o** solo el nombre (`ViewThatFits`); glifo 28 fijo | **una** fila a la derecha (la primera "tuya"): el widget pasa a "última + una" | rectangular: solo el tiempo vivo | del sistema | `ViewThatFits`: cabecera 34, cuerpo 28 con scroll; `HairlineAction` a dos líneas, 64 mínimo, hairlines | nombre 2 líneas; "+15 min" 24 |
| **AX3-AX5** | solo tres cosas: cifra 40 (izquierda, arriba), horizonte, dos botones de 64 con "+15 min" a 28 y glifo 32; el nombre **desaparece** (lo lee VoiceOver); es la actividad de StandBy en pequeño | no cambia | solo "Dormir" / el tiempo vivo a 24 (`.title2`) y el glifo; sin nombre | igual que AX1-AX2 | rectangular: el tiempo vivo a 22; inline del sistema | del sistema | igual que AX1-AX2, cuerpo hasta AX5 sin truncar | Disco 64 + "+15 min"; sin nombre |

Lo que nunca cambia: los botones de 64 (y 128 vistos en StandBy) y su posición (izquierda = tiempo, derecha = sonido); el horizonte, siempre entero; cero cajas. Nombres de mezcla escritos por el usuario: `minimumScaleFactor(0.8)` en todos los tramos (03 §3.4: la única excepción permitida); ninguna otra cadena escala. Capturas de control del entregable: Large, xxxLarge, AX3 y AX5 de la actividad de bloqueo, del widget pequeño y de "Al acostarte", ES y EN.

### 5 (e) Catálogo de cadenas ES / EN por clave

Definitivas: son las que se compilan, **copiadas letra a letra de 10 §5e** (10 §5e.12 Ajustes, §5e.13 superficies del sistema, §5e.14 Siri, §5e.16 accesibilidad, §5e.17 respuestas). Las filas marcadas **(E7)** son cadenas que esta entrega necesita y 10 aún no tiene: se proponen con la redacción más cercana de la guía y se piden en §9; no se compilan hasta que 10 las adopte. `%@` / `%lld` son argumentos de formato; `${…}` interpolaciones de App Shortcuts (solo `AppEnum` / `AppEntity` / `applicationName`). El tiempo vivo nunca es un argumento: es `Text(timerInterval:)` junto al prefijo. Sin "insomnio", "ansiedad", "mejora", "timer", "mix", "vitalicio", "IA", "versión", "Escudo", "chip", "envolvente", "v1/v2" en ninguna (10 §0.5). **Ninguna cadena visible fuera de la app contiene "Pro" ni "prueba"**; la única hablada que lo nombra, `siri.pro`, describe.

**Live Activity, Isla y StandBy (`Localizable.xcstrings`, target de la extensión; 10 §5e.13):**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `la.estado.sonando` | sonando · %@ | playing · %@ | versalita; `%@` = modo en minúscula ("hasta dormirme", "manto"; "siesta" en 1.1) | 28 |
| `la.estado.sonando.solo` | sonando | playing | sin temporizador | 8 |
| `la.estado.pausa` | en pausa | paused | pausa sin causa conocida (toque, `.began`, reset) | 10 |
| `la.estado.pausa.causa` | en pausa · %@ | paused · %@ | causa en minúscula: auriculares, airpods, llamada (C48, C49) | 24 |
| `la.estado.pausa.hora` | se pausó a las %@ · airpods | paused at %@ · airpods | terminada por 20 min en pausa de AirPods (C49) | 30 |
| `la.estado.fundiendo` | fundiendo | fading | fundido de ganancia 10-15 min (C31) | 10 |
| `la.estado.terminada` | se fundió a las %@ | faded at %@ | terminada tras fundido (versalita; la cifra queda vacía) | 22 |
| `la.estado.detenido` | se detuvo a las %@ | stopped at %@ | motor caído no recuperado, 30 min | 22 |
| `la.hasta` | hasta las %@ | until %@ | Manto: versalita de tiempo en la Live Activity y en StandBy (la cifra grande es el restante); también fila 2 del rectangular y subtítulo del Control en Manto | 14 |
| `la.madrugada.prefijo` | madrugada · | small hours · | durante Madrugada: prefijo + tiempo vivo ("madrugada · 20:00") | 12 |
| `la.madrugada.retirada` | se retira · %@ | winding down · %@ | versalita de Madrugada los últimos 5 min; `%@` = tiempo vivo (C60) | 20 |
| `marea.estado.guiando.corto` | guiando · %lld por minuto | guiding · %lld per minute | versalita con Marea (10 §5e.5: también en la Live Activity) | 26 |
| `marea.estado.disolviendo` | disolviendo | dissolving | últimos 20 % de la Marea | 12 |
| `madrugada.estado` | Madrugada · 20 min | Small hours · 20 min | botón izquierdo de la terminada (C27); widget pequeño y bloqueo 00:00-06:00 | 20 |
| `comun.mas15` | +15 min | +15 min | botón izquierdo (sonando, pausa, fundiendo, guiando, madrugada); vacío en Manto (C50) | 8 |
| `mezcla.esta_noche` | Esta noche | Tonight | nombre de la mezcla viva sin nombre (10 §0.2; §3 de la reconciliación) | 24 |
| `mezcla.nombre.sin` | %@ · sin %@ | %@ · without %@ | título honesto de la recortada ("Mar y viento · sin Océano") | 34 |
| `la.madrugada` | madrugada · 20 min | small hours · 20 min | **no se usa en 09**: el botón de la terminada es `madrugada.estado` (mayúscula, como en Noche y el widget); se pide a E7 retirarla o fundirla (§9) | 20 |
| `la.estado.pausa.hora.sin` **(E7)** | se pausó a las %@ | paused at %@ | terminada por 20 min en pausa de otra causa (redacción de `la.estado.pausa.hora` sin "· airpods") | 22 |
| `la.mezcla.sustituta` **(E7)** | Rosa · en lugar de %@ | Pink · instead of %@ | nombre cuando la mezcla cargada era toda Pro sin acceso y Play arrancó Rosa a 40 (03 §1.3; redacción derivada de `pagina.estado.sonando.defecto` "Sonando · rosa a 40") | 28 |
| `la.vo.contenedor` **(E7)** | SleepNoise, %@. %@. | SleepNoise, %@. %@. | VoiceOver, contenedor (mezcla, estado) | — |
| `la.vo.abrir` **(E7)** | Toca dos veces para abrir. | Double-tap to open. | pista del contenedor y de los widgets de bloqueo (redacción de `ax.capa.pro.pista`) | — |
| `la.vo.estado.*` **(E7)** | sonando, quedan %lld minutos · en pausa, %@ · fundiendo, quedan %lld minutos · guiando, %lld por minuto · terminada, se fundió a las %@ · madrugada, quedan %lld minutos | playing, %lld minutes left · paused, %@ · fading, %lld minutes left · guiding, %lld per minute · over, faded at %@ · small hours, %lld minutes left | valor hablado del contenedor (redacción de `ax.noche.valor`, `ax.madrugada.valor`, `ax.madrugada.retirada`) | — |
| `la.stack.vo` **(E7)** | SleepNoise, %@. Toca dos veces para abrir en el iPhone. | SleepNoise, %@. Double-tap to open on iPhone. | Smart Stack del Watch con la actividad | — |
| `di.vo.etiqueta` **(E7)** | SleepNoise, %@ | SleepNoise, %@ | Isla compacta / mínima | — |

**Accesibilidad de la actividad y los controles (10 §5e.16):** `ax.la.pausar` "Pausar SleepNoise" / "Pause SleepNoise" · `ax.la.reproducir` "Reproducir SleepNoise" / "Play SleepNoise" · `ax.la.madrugada` "Madrugada, veinte minutos" / "Small hours, twenty minutes" · `ax.mas15` "Quince minutos más" · `ax.accion.pausar` "Pausar" / "Pause" · `ax.accion.reanudar` "Reanudar" / "Resume" · `ax.anuncio.quedan` "Quedan %lld minutos" · `ax.anuncio.hasta` "Hasta las %@" · `ax.control.madrugada` "Madrugada, veinte minutos" · `ax.widget.pequeno` "%@, %@. %@" · `ax.widget.fila` [1.1] "%@, %@. Reproducir." · `ax.accion.silenciar` "Silenciar" · `ax.accion.maximo` "Máximo" · `ax.isla.parar` [retirada por C25].

**Widgets (10 §5e.13):**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `widget.dormir` | Dormir | Sleep | pequeño, sin sesión, 17 Semibold en el sitio del tiempo; también nombre del widget en la galería; 00:00-06:00 el botón dice `madrugada.estado` (C27, C42) | 8 |
| `widget.silencio` | en silencio | silent | versalita (reposo, pausa); rectangular fila 2 | 12 |
| `widget.sonando` | sonando | playing | versalita; el tiempo, `Text(timerInterval:)` vivo al lado | 8 |
| `widget.inline.prefijo` | SleepNoise · | SleepNoise · | inline de bloqueo: prefijo + tiempo vivo (o + `madrugada.estado` de 00:00 a 06:00) | 12 |
| `widget.inline.silencio` | SleepNoise · en silencio | SleepNoise · silent | inline en reposo y pausa | 26 |
| `widget.pequeno.descripcion` | Tu última mezcla, con Play. | Your last mix, with Play. | descripción en la galería | 30 |
| `widget.mediano.nombre` [1.1] | Mezclas | Mixes | galería (C42) | 8 |
| `widget.mediano.descripcion` [1.1] | Tres mezclas. Un toque y suenan. | Three mixes. One tap and they play. | galería (03 §5 #22: tres mezclas) | 36 |
| `widget.config.mezclas` [1.1] **(E7)** | Mezclas a mostrar | Mixes to show | intent de edición del mediano | — |
| `widget.vo.rect` **(E7)** | SleepNoise, %@, %@. Toca dos veces para abrir. | SleepNoise, %@, %@. Double-tap to open. | rectangular / inline | — |

**Centro de control y botón de Acción (10 §5e.13 y §5e.2):**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `control.titulo` | SleepNoise | SleepNoise | `ControlWidgetToggle` (= `app.name`; 03 §5 #23); 1.0 sobre los intents de C43, corte sin coste en la semana 14 (C26); el tinte "on" es la única excepción al "sin acento fuera de la app" (C61) | 10 |
| `pagina.estado.sonando` | Sonando | Playing | valor *on* del Control | 8 |
| `pagina.estado.silencio` | En silencio | Silent | valor *off* del Control | 12 |
| `control.sub.on` | %@ · %lld min | %@ · %lld min | subtítulo con la mezcla y los minutos del ajuste (el Control no tiene reloj vivo); Manto: `%@` + `la.hasta` | 26 |
| `control.sub.off` | Última: %@ | Last: %@ | subtítulo off | 24 |
| `madrugada.titulo` | Madrugada | Small hours | título del `ControlWidgetButton` | 10 |
| `control.madrugada.sub` | 20 min | 20 min | subtítulo del botón | 6 |
| `accion.pista` | Mantén para dormir | Hold for sleep | pista del botón de Acción (toggle) | 20 |
| `accion.pista.madrugada` | Mantén para Madrugada | Hold for Small hours | pista del botón de Acción (Madrugada) | 24 |
| `cc.descripcion.toggle` **(E7)** | Empieza o pausa tu última mezcla. | Starts or pauses your last mix. | galería de controles (redacción de `widget.pequeno.descripcion`) | — |
| `cc.descripcion.madrugada` **(E7)** | Veinte minutos de mar, con la Marea. | Twenty minutes of sea, with the Tide. | galería (receta fija de C05) | — |

**Siri y Atajos (10 §5e.14 frases en `AppShortcuts.xcstrings`; títulos y respuestas en `Localizable.xcstrings`, 10 §5e.17):**

| Intent | Título ES [EN] | Frases ES | Frases EN |
|---|---|---|---|
| `PlayLastMix` | Pon ${applicationName} [Play ${applicationName}] | Pon ${applicationName} · Reproduce ${applicationName} | Play ${applicationName} · Start ${applicationName} |
| `PlayMix(mix)` | Pon una mezcla [Play a mix] | Pon ${mix} en ${applicationName} · Pon la mezcla ${mix} en ${applicationName} | Play ${mix} in ${applicationName} · Play the ${mix} mix in ${applicationName} |
| `PlayLayer(layer)` | Pon una capa [Play a layer] | Pon ${layer} en ${applicationName} · Pon ruido ${layer} en ${applicationName} | Play ${layer} in ${applicationName} · Play ${layer} noise in ${applicationName} |
| `Pause` | Pausa ${applicationName} [Pause ${applicationName}] | Pausa ${applicationName} · Para ${applicationName} | Pause ${applicationName} · Stop ${applicationName} |
| `ExtendTimer(minutes)` | Añade minutos [Add minutes] | Añade ${minutes} minutos en ${applicationName} · Alarga ${applicationName} | Add ${minutes} minutes in ${applicationName} · Extend ${applicationName} |
| `SetTimer(mode)` | Temporizador [Timer] | Pon ${mode} en ${applicationName} · ${applicationName} ${mode} | Set ${mode} in ${applicationName} · ${applicationName} ${mode} |
| `SmallHours` | Madrugada [Small hours] | Madrugada en ${applicationName} · Empieza Madrugada en ${applicationName} | Small hours in ${applicationName} · Start Small hours in ${applicationName} |
| `Toggle` (sin frase) | Alternar [Toggle] | — | — |
| `CurrentState` (sin frase) | Qué suena [What's playing] | — | — |
| `StartTide` / `StopTide` / `SetLevel` [1.1] | Marea [Tide] · Nivel [Level] | Activa la Marea en ${applicationName} · Quita la Marea en ${applicationName} | Turn on the tide in ${applicationName} · Turn off the tide in ${applicationName} |

| Clave | ES | EN | Contexto |
|---|---|---|---|
| `siri.estado` | %@, quedan %lld minutos. | %@, %lld minutes left. | `CurrentState` con temporizador |
| `siri.estado.sin_temporizador` | %@, sin temporizador. | %@, no timer. | sin temporizador |
| `siri.estado.sin` | %@, sin %@, quedan %lld minutos. | %@, without %@, %lld minutes left. | mezcla con capas Pro sin acceso |
| `siri.estado.marea` | %@, Marea a %lld por minuto, quedan %lld minutos. | %@, tide at %lld per minute, %lld minutes left. | con Marea |
| `siri.silencio` | Nada suena ahora. | Nothing is playing. | nada suena |
| `siri.quedan` (pl) | Quedan %lld minutos. | %lld minutes left. | tras `ExtendTimer` |
| `siri.pro` | %@ es Pro. Suena lo demás. | %@ is Pro. Playing the rest. | `PlayLayer` sin acceso (describe) |
| `siri.mezcla.cual` | ¿Cuál de tus mezclas? | Which of your mixes? | `requestDisambiguation` |
| `siri.error` | No se ha podido iniciar el sonido. | Couldn't start the sound. | sin sesión de audio |
| `temporizador.dormirme` / `temporizador.manto` / `temporizador.apagado` | Hasta dormirme · Manto · Apagado | Until I sleep · Blanket · Off | `AppEnum` de modos (C11; "Blanket" pendiente de verificar en en-US, reconciliación §6.4); sinónimos "hasta que me duerma", "toda la noche", "sin temporizador" |
| `sound.*` | Blanco · Rosa · Marrón · Lluvia · Viento · Océano · Ventilador · Trueno · Hoguera · Arroyo · Cabina | White · Pink · Brown · Rain · Wind · Ocean · Fan · Thunder · Campfire · Brook · Cabin | entidad de capa (once en 1.0, C19); sinónimos "ruido blanco / rosa / marrón", "tormenta" / "storm" (C13) |
| `mezcla.casa.rosa_lluvia` / `.mar_viento` / `.marron_hoguera` / `.pared` | Rosa y lluvia · Mar y viento · Marrón y hoguera · Pared | Pink and rain · Sea and wind · Brown and fire · Wall | `MixEntity` de la casa (C18) |
| `enum.minutos.*` **(E7)** | cinco · diez · quince · treinta | five · ten · fifteen · thirty | `AppEnum` de minutos de `ExtendTimer` (10 §5e.14 fija los valores 5·10·15·30, no sus cadenas) |

**Ajustes · Al acostarte, Salida, Now Playing, Focus [1.1] y Watch [1.2] (10 §5e.12 y §5e.13):**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `ajustes.seccion.acostarte` | al acostarte | at bedtime | versalita del grupo | 14 |
| `ajustes.acostarte` | Al acostarte | At bedtime | fila → una página de texto con los pasos de Atajos (C43); el único autoarranque (C33) | 34 |
| `ajustes.acostarte.sub` | Que suene sola al activar Sueño. Dos pasos en Atajos. | Start on its own when Sleep turns on. Two steps in Shortcuts. | subtítulo de la fila y primera frase de la página | 56 |
| `ajustes.acostarte.p1` | En Atajos, toca Automatización y elige el modo de concentración Sueño, "Al activarse". | In Shortcuts, tap Automation and choose the Sleep Focus, "When turning on". | párrafo 1, paso 6 | 100 |
| `ajustes.acostarte.p2` | Añade la acción "Pon %@" y elige "Ejecutar inmediatamente". Desde esa noche sonará sola al acostarte. | Add the action "Play %@" and choose "Run immediately". From that night on it will start on its own at bedtime. | párrafo 2; `%@` = `app.name` | 120 |
| `ajustes.acostarte.abrir` | Abrir Atajos | Open Shortcuts | `HairlineAction` | 14 |
| `ajustes.seccion.salida` | salida | output | versalita (C41) | 8 |
| `ajustes.salida` | Salida | Output | fila con el `AVRoutePickerView` del sistema (`longFormAudio`); la única superficie de AirPlay (C41) | 8 |
| `estado.ruta` | Sonando · en %@ | Playing · on %@ | línea de estado de la app con ruta externa (C41) | 30 |
| `estado.pausa.auriculares` | En pausa · auriculares | Paused · headphones | `oldDeviceUnavailable` en la app (es-419: audífonos) | 24 |
| `ruta.seguir_altavoz` | Seguir por el altavoz | Keep playing on speaker | botón 60 s en Noche y página, nunca en la actividad (C49) | 28 |
| `estado.volumen` | Sonando · al %lld | Playing · at %lld | tras reanudar por el altavoz capado a 0,4 y tras el arrastre vertical (C49, C51) | 20 |
| `nowplaying.artist` | SleepNoise | SleepNoise | Now Playing (existente) | 10 |
| `nowplaying.title` | (nombre de la mezcla) | (mix name) | Now Playing: el título es la mezcla | 24 |
| `nowplaying.en_directo` **(E7)** | En directo | Live | subtítulo del Now Playing (03 §5 #34) | 12 |
| `ajustes.debajo` [1.1] | Debajo de otro audio | Under other audio | preferencia Preguntar / Siempre / Nunca (C16, C44) | 24 |
| `debajo.sonar` [1.1] | Sonar debajo | Play underneath | botón de entrada al estado (C44) | 14 |
| `acostarte.parar` [1.1] **(E7)** | Para parar por la mañana, otra automatización con "Al desactivarse" y la acción "Pausa %@". | To stop in the morning, another automation with "When turning off" and the action "Pause %@". | tercer párrafo de la página, si E7 lo acepta | — |
| `acostarte.accion` **(E7)** | Si tu iPhone tiene botón de Acción, asígnale Madrugada. | If your iPhone has an Action button, assign Small hours to it. | cuarto párrafo (sin condición por modelo) | — |
| `ajustes.ios17` **(E7)** | En iOS 17 no hay control en el Centro de control: el Atajo hace lo mismo. | On iOS 17 there is no Control Center control: the Shortcut does the same. | nota, solo en iOS 17 | — |
| `focus.titulo` [1.1] | SleepNoise en este modo | SleepNoise in this Focus | título del filtro | 26 |
| `focus.abrir` [1.1] | Abrir en | Open in | parámetro | 10 |
| `focus.abrir.pagina` [1.1] | Página | Page | valor (el otro valor es `noche.titulo` "Noche") | 8 |
| `focus.mezcla` [1.1] | Mezcla a cargar | Mix to load | parámetro | 16 |
| `focus.mezcla.ultima` [1.1] | La última | The last one | valor por defecto | 12 |
| `ajustes.focus` [1.1] **(E7)** | Noche directa en el modo Sueño | Straight to Night in Sleep Focus | fila de Ajustes con explicación y botón "Abrir Ajustes" | 36 |
| `watch.madrugada` [1.2] | Madrugada · 20 min | Small hours · 20 min | segundo botón cuando no suena (= `madrugada.estado`) | 20 |
| `watch.marea` [1.2] | %lld por minuto · %lld min | %lld per minute · %lld min | versalita bajo la línea de agua | 26 |
| `watch.volumen` [1.2] | Volumen | Volume | etiqueta accesible de la corona | 8 |
| `watch.haptica.marcada` [1.2] | Marcada | Prominent | háptica Marcada en el Watch (C35) | 10 |
| `comun.min.quedan` (pl) [1.2 aquí] | quedan %lld min | %lld min left | anuncio tras "+15" en el Watch | 16 |
| `watch.fuera` [1.2] **(E7)** | iPhone fuera de alcance | iPhone out of reach | sin conexión (texto estático) | 24 |
| `watch.vo.corona` [1.2] **(E7)** | Gira la corona. | Turn the crown. | pista | — |
| `ajustes.guia_hablada` [1.2] **(E7)** | Guía hablada | Spoken guide | ajuste del anuncio "Inhala" / "Exhala" (`marea.fase.*`), apagado por defecto | 24 |

Formatos: horas con el ajuste regional ("00:25" / "12:25 AM"); el tiempo vivo lo formatea el sistema; nunca `%lld` de minutos fuera de la app salvo `control.sub.on` (minutos del ajuste, no restantes) y las respuestas habladas de Siri.

---

## 6. Variantes

| Variante | Qué cambia | Qué no cambia |
|---|---|---|
| **Escenario A / B** (C25) | A (dos parejas): Live Activity recortada, Isla y StandBy en 1.0. B (una pareja): todo eso pasa a 1.1 y en 1.0 el bloqueo muestra solo el Reproduciendo del sistema (2.34); widgets, Control, Siri y Al acostarte no cambian de versión | la gramática entera; nada se rediseña al pasar de B a A |
| **iPhone 16 / 15** (393 × 852, Dynamic Island, Always-On, botón de Acción en 16) | todo lo especificado; la Isla existe; Always-On atenúa la actividad (`isLuminanceReduced`: nada que congelar, ya es estática) | — |
| **iPhone 17 Pro / 17** (402 × 874) | la actividad mide 402 × 160: la columna crece 9 pt, el botón izquierdo mide 269, el derecho sigue en 64 a la derecha **[a medir]** | nada se mueve |
| **iPhone SE (3.ª gen.)** (375 × 667, Touch ID, sin Isla, sin Always-On, sin botón de Acción) | no hay Isla (ni mínima ni compacta): la actividad vive solo en el bloqueo y en StandBy; actividad de bloqueo 375 × 160, columna de 335, botones x 20-262 y x 290-354; StandBy 750 × 320 vistos; widgets 148 × 148 y 321 × 148 (tabla de la HIG) | la gramática entera; "+15 min" y el glifo |
| **iPhone 16e** (390 × 844, notch, sin Isla, con botón de Acción) | como el SE en la Isla (columna de 350); como el 16 en el botón de Acción | — |
| **iPad** (`TARGETED_DEVICE_FAMILY "1,2"`) | Live Activity de bloqueo en iPadOS 17 con la misma vista; widgets de inicio solo `systemSmall` y `systemMedium` (sin `systemLarge` / `ExtraLarge`); sin Isla, sin StandBy, sin Control en el bloqueo; foco de teclado sobre la actividad [a medir] | — |
| **Solo oscura (1.0) / Papel (1.1, C32)** | 1.0: todo negro, también de día (`preferredColorScheme(.dark)` en la raíz; los widgets, negros). 1.1 con Papel: los widgets de día siguen la apariencia del sistema con `tinta` sobre `papel` (C61) y `trazo-papel` para las hairlines del mediano; la Live Activity, la Isla y StandBy son **siempre negras** (`activityBackgroundTint(negro)`; la noche manda, P1). Ningún acento propio fuera de la app; en apariencia clara el *on* del Control usa `AccentColor` Light = `ocre` (04 §2.0.1). El Control y el Watch son del sistema (el Watch siempre negro) | formas, medidas, estados |
| **ES / EN** | las cadenas de 5 (e); las versalitas ES son hasta un 30 % más largas: "sonando · hasta dormirme" (26 caracteres) cabe en 220 pt a 15 Medium; ninguna versalita supera 28 caracteres y ninguna escala; horas "00:25" frente a "12:25 AM" | posiciones |
| **es-419** | `estado.pausa.auriculares` "audífonos", `ruta.seguir_altavoz` "bocina", `mezcla.casa.marron_hoguera` "fogata" (10 §0.3) | — |
| **High Contrast** ("Aumentar contraste") | fuera de la app no hay `texto2` ni `texto3`, así que nada cambia salvo el tinte *on* del Control (`índice-ac` del asset catalog) y las hairlines del mediano (`trazo-ac`) | todo |
| **Button Shapes** ("Formas de botón") | los botones de texto de la actividad ("+15 min", "Madrugada · 20 min") y del Watch muestran el subrayado / contorno del sistema; el glifo ya es forma; en la actividad el sistema dibuja el contorno en el área del `Button` (64 pt): por eso los botones son `Button` reales y no zonas táctiles invisibles (lección del PR #3 y de Silencio 5.14); el widget pequeño entero muestra el contorno (es un botón) | — |
| **Escala de grises** ("Filtros de color") | nada se pierde: no hay color fuera de la app salvo el *on* del Control, que además cambia de forma (relleno frente a símbolo gris, y el sistema añade el estado) | — |
| **Filtro rojo de StandBy** (modelos A / B) | `texto` bajo rojo: 4,43 / 4,30 sobre negro (02 §2.3, 03 §3.1; sin hex propios); criterio ≥ 3:1 medido en dispositivo, plan B `#F0ECE4` (C62); **todo texto visto ≥ 24 pt**; glifo 56 visto con trazos ≥ 6; horizonte 3 / 4 pt vistos; sin opacidades; sin `texto2`; el estado por `pause.fill`/`play.fill` y horizonte presente/ausente; el widget pequeño sin fondo pierde el nombre (2.21) **[spike I0-6]** | — |
| **Reduce Transparency / Smart Invert** | la actividad no usa materiales; el horizonte y los glifos llevan `accessibilityIgnoresInvertColors()` en widgets (son contenido) | — |
| **Bold Text** | SF escala de peso solo; las versalitas 15 Medium pasan a Semibold del sistema (la decide el usuario) | — |
| **iOS 17.0-17.1** | sin `LiveActivityIntent`: una sesión arrancada por Siri, Atajo o widget no tiene actividad hasta que la app pasa a primer plano (lo demás, igual); sin Controls (Ajustes lo dice: `ajustes.ios17`, E7) | — |
| **Modo claro en el Centro de control** | el sistema pinta el control; el *on* con `AccentColor` Light (`ocre #8A6508`, 04 §2.0.1; 4,68 sobre papel) sobre el gris claro del Centro de control **[a medir el ratio ≥ 3:1]** | — |
| **Debajo de otro audio [1.1]** (C44) | con el estado activo la sesión pasa a `mixWithOthers`; la actividad y el Reproduciendo del sistema siguen igual; la línea "Debajo de tu podcast" es de la app | — |

---

## 7. Háptica por evento

Regla de 03 §3.8 y C35: fuera de la app, **nada vibra por decisión de la app**; en segundo plano, nunca; la puerta es por fase (de noche nunca vibra), sin CoreMotion en producción 1.0. Lo que vibra lo vibra el sistema o, en 1.2, el Watch.

| Evento | iPhone (actividad, widget, Control) | Watch [1.2] | Anuncio VoiceOver |
|---|---|---|---|
| Tocar "+15 min" / "Madrugada · 20 min" en la actividad | ninguna (ActivityKit no vibra; la confirmación es la cifra) | `.click` | "Quedan 53 minutos" / "Madrugada, veinte minutos" |
| Tocar el glifo (pausa / play) | ninguna | `.stop` / `.start` | "En pausa" / "Sonando" |
| Toggle del Centro de control | la del sistema para controles (no la define la app) | — | del sistema |
| Botón de Acción | la del sistema al mantener | — | del sistema |
| Madrugada arranca (desde cualquier superficie) | ninguna | `.start` si se arrancó desde el Watch; si no, nada | "Madrugada, veinte minutos" |
| Marea · inicio de inhalación | ninguna (Core Haptics no corre en segundo plano; la "Mínima" de 3-5 respiraciones es de la app, opt-in y solo de día, C35) | `.directionUp` toda la guía ("Marcada", C35); se desactiva en ruta AirPlay (latencia) y si la sesión extendida expira | opcional "Inhala" / "Exhala" (ajuste "Guía hablada", apagado por defecto) |
| Marea · inicio de exhalación | ninguna | ninguna (03 §3.8: solo `.directionUp` por inhalación; dos pulsos por ciclo es un metrónomo) | — |
| Corona · cruzar 0 / llegar a 100 | — | `.click` (detents del sistema en el resto) | "Silenciar" / "Máximo" |
| Fin del temporizador, fin de Madrugada, retirada de la Marea, fin de prueba, error de audio | **ninguna**, en ninguna superficie | ninguna | anuncio de la versalita si VoiceOver está activo y la pantalla encendida |
| Actividad terminada aparece | ninguna | ninguna | nada (no es una notificación) |

---

## 8. Lo que se queda fuera y por qué

| Fuera | Por qué |
|---|---|
| **Isla expandida** (con "Noche", "Parar" o "+10 min") | C25: la Live Activity recortada no tiene vista expandida; tocar la Isla ya abre en Noche |
| **"+15" y segundo control en StandBy** | C25: un solo control (pausa/play) a un metro; prolongar vive en la actividad de bloqueo y en Noche |
| **Venta, "prueba caducada", "bajando"** en cualquier superficie del sistema | C25, C50 y §1 regla 7 de la reconciliación: fuera de la app nada se vende; seis estados y ninguno de compra |
| **Widget circular** | C42: no tiene nada que decir sin un valor numérico; un glifo que solo abre la app duplica al rectangular |
| **Widget mediano en 1.0** | C42: depende de `MixEntity` estable; 1.1 |
| **Escucha de 30 s por voz o desde el widget** | C06: no hay escucha de 30 s en 1.0; una capa Pro sin acceso no suena y `siri.pro` lo describe |
| **Tope de 60 min, recortes de temporizador o "sin Manto" por voz** | C03: el temporizador es entero libre; la palabra "pro" no aparece en él |
| **"Rosa · en lugar de …" y la última mezcla en Madrugada** | C05: Madrugada es una receta fija (océano a 0,3 con Marea 8/min); no hay nada que sustituir |
| **Línea matinal "Anoche probaste Océano…" (Focus, `focus.manana`)** | C08: de noche no se vende y no hay recordatorio por la mañana; `showPaywall` se consume sin cola |
| **`StartTide` / `StopTide` / `SetLevel` con frase en 1.0** | C43: no se dicen en voz alta a las 3:00; 1.1 |
| **Doble toque, deslizamientos o gesto oculto para Madrugada** | C27: Madrugada siempre es un botón |
| Polilínea, traza o "regla que escribe" en la Live Activity y en StandBy | 03 §1.2 y §6: el motor no produce esa señal; ActivityKit no anima; sería mentira dos veces |
| Horizonte interrumpido alrededor del texto (y 53 "a un tercio") | una línea con hueco es una tercera forma en una gramática de dos (continua = suena, ausente = pausa); el horizonte se mueve bajo el texto (y 72), nunca se corta |
| Alternar "38 m" / "6/min" cada n segundos en la Isla compacta (Grafito 13.1) | la Isla no parpadea; la Marea se lee en la app |
| Acento en la actividad, StandBy, widgets y Watch | 03 §3.1 regla 4 y C61: "color = sonido" no sale de la app; bajo rojo el único color que sobrevive es el casi blanco; `widgetAccentable` nunca en fondo |
| Anillo alrededor del glifo (Marea 4.10) y Disco en la actividad (Dial 12.1) | la actividad no tiene relieve; el glifo solo ya es el estado |
| Un tercer botón en la actividad de bloqueo ("Noche", "Madrugada" junto a "+15") | 03 §1.4 y C50: dos botones, posiciones fijas, significado fijo; tocar la actividad ya abre en Noche |
| "Dormir" como botón de la terminada de día | fuera de 21:00-06:00 no hay terminada; el verbo de día ya vive en el widget pequeño |
| "Seguir por el altavoz" en la actividad | sería un botón que cambia de significado en la misma posición (03 §1.2); vive en Noche y en la página (C49); el `play.fill` de la actividad reanuda capado a 0,4 |
| Cifra estática de minutos en widgets, Control, Smart Stack y complicación ("quedan 38 min") | un número recargado por hito es falso casi siempre; el tiempo vivo lo pinta `Text(timerInterval:)` o no se enseña (el Control enseña los minutos del ajuste) |
| Duración de la sesión en la terminada ("· 73 min") | la primera cifra de informe en una app que no te puntúa (brief §7.1) |
| Causa "interrumpido" o cualquier causa que el motor no distingue | se afirma solo lo que se sabe: auriculares (ruta), airpods (`pauseCommand` con auriculares, C49), llamada (`CXCallObserver`, C48); lo demás es "en pausa" |
| Nombre de la mezcla en StandBy y en el widget pequeño sin fondo | un elemento legible a un metro (C25, C62); 17 Semibold bajo rojo no llega |
| `texto2` / `texto3` y opacidades fuera de la app | mueren bajo rojo (02 §2.3); el Disco deshabilitado del Watch desaparece con ellas |
| Un paso tipográfico nuevo ("9-ext", 15 Semibold versalitas) | 03 §3.4 ya tiene el paso 7 de noche (15 Medium); ningún estilo nuevo; 17 Medium cuenta como estilo (C67) |
| 13 pt fuera de la app | 13 no sobrevive al rojo ni al bloqueo atenuado; nada < 15 fuera de la app (24 vistos en StandBy, C62) |
| Segunda actividad del Manto a las 7 h 55 | `Activity.request` desde segundo plano se rechaza (`.visibility`); la app cierra la primera y el widget rectangular cubre "hasta las 7:00" (C50) |
| Live Activity solicitada al bloquear | carrera con `.visibility`; se solicita en Play, donde no se ve y no cuesta nada |
| Frases de Siri con `Int` ("Start a {minutes} minute timer") | no compila (REVIEW-PR3 bloqueante #2); el `AppEnum` de minutos lo sustituye |
| Siri diciendo precio, "versión", "prueba" o "Desbloquear" | "Siri nunca vende" (03 §5 #24); `siri.pro` describe lo que suena |
| Notificaciones locales (fin de prueba, "¿cómo has dormido?", recordatorio de acostarse) | no hay permiso de notificaciones en SleepNoise (brief §7.1; Silencio 18); nada se vende de noche (C08) |
| Autoplay por Focus filter | la plataforma no lo permite (informe §6.1); lo hace la automatización |
| Pantalla propia de AirPlay | C41: el picker del sistema en Ajustes › Salida ya es la pantalla |
| Watch en 1.0 / 1.1; Watch autónomo con audio, mezclador, lista de mezclas, precios | C28: Watch 1.2; en 1.0 el Reproduciendo del sistema ya controla; 03 §7.7: "de verdad mínimo" |
| Segunda pantalla de Marea en el Watch (Grafito 13.5, Dial 12.4) | una pantalla (03 §5 #26); la Marea en la muñeca es háptica, no una vista |
| Pulso del Watch, HealthKit en el Watch, tracking | informe §6.3; Salud en 2.0 (C34) |
| CoreMotion para suprimir háptica | C35: la puerta es por fase; sin sensor en producción 1.0 |
| iCloud KVS en 1.0 | C09: 1.1; en 1.0 formato v2 + App Group |
| Luna, estrellas, nubes, `moon.zzz`, candados, coronas, `checkmark.seal`, iconos de capa en widgets | brief §7.1; 03 §3.6 |

---

## 9. Preguntas abiertas

**Cerradas por la reconciliación (16-11-2026; se dejan como registro):**
- ~~1. Tercer botón de la Isla expandida ("Noche")~~ → cerrada por C25: no hay Isla expandida.
- ~~2. "+15 min" en Madrugada en vez del "+10 min" de 03 §5 #20~~ → cerrada por C25 (la expandida que daba casa a "+10" no existe) y 03 §4.5 consolidado: "+15 min" prolonga la Madrugada.
- ~~3. Título del toggle del Centro de control ("Dormir" frente a "SleepNoise")~~ → cerrada por 03 §5 #23 consolidado y 10 `control.titulo`: "SleepNoise".
- ~~4. Tinte del Control en apariencia clara (`ocre`)~~ → cerrada por C61 y 04 §2.0.1: `AccentColor` Light = `ocre #8A6508`; queda solo la medida del ratio (§6).
- ~~5. Widgets en papel de día~~ → cerrada por C32 y C61: solo oscura en 1.0; en 1.1 `tinta` sobre `papel`.
- ~~7. Línea "Anoche probaste Océano…" como requisito para E2~~ → cerrada por C08: no hay línea matinal.
- ~~9. "Al acostarte" en una pantalla~~ → cerrada por C43: una página de texto.
- ~~12. [spike I0-4] pausa de AirPods~~ → cerrada por C49: `pauseCommand` con auriculares conectados = pausa de auriculares con fundido de 3 s; causa "airpods".
- ~~13. [spike I0-1] nivel maestro en `EngineCommand`~~ → cerrada por C51: `master` con rampa entra en 1.0; M4 lo lee.

**Para el dueño:**
6. **Fuente del Watch (1.2)**: 03 §3.4 dice "Una familia: SF Pro" sin contemplar el Watch. ¿Se enmienda a "SF Pro; en watchOS, la del sistema"? (Sin prisa: 1.2.)
8. **Deployment target 17.2 para la extensión**: evita el segundo `@available` (`LiveActivityIntent`) y da Live Activity a las sesiones arrancadas por Siri desde el primer día (escenario A). Coste de diseño cero. ¿Se acepta?
16. **Segunda pareja (escenario A)**: reconciliación §6 #3; si el 14-12-2026 no está confirmada, la Live Activity, la Isla y StandBy pasan a 1.1 sin discusión y 2.34 es el bloqueo de 1.0.

**Para los spikes:**
10. **[spike I0-3]** ¿Se entrega un `Button(intent:)` desde una actividad en estado `.ended` (terminada con `end(.after(fin + 4 h))`)? Si no: no se llama a `end` y la terminada vive hasta el tope de 8 h; "terminada → Madrugada" depende de esto (C25). ¿Retira el sistema la actividad al forzar el cierre de la app en iOS 17 y 18? ¿`Text(.currentDate, format: .timer(countingDownIn:, maxPrecision: .seconds(60)))` (iOS 18) enseña "38 min" sin segundos? Si sí, es la forma de 1.0 en iOS 18 y `Text(timerInterval:)` ("38:12") queda para iOS 17.
11. **[spike I0-6]** Foto calibrada a un metro de la actividad en StandBy rojo con brillo mínimo: ¿se lee la versalita de 24 vistos? ¿Se distingue el horizonte de 3 / 4 pt presente/ausente? ¿Cuál de los dos modelos (A/B) es el real? ¿Llega `texto` a 3:1 o entra el plan B `#F0ECE4` (C62)?
14. **Watch (1.2)**: `WKExtendedRuntimeSession` de tipo mindfulness con la app en segundo plano: ¿sigue entregando `.directionUp` tras bajar la muñeca? Si no, "Marcada" se limita a la primera hora con la muñeca levantada y se dice. Lienzo de 41 mm [a medir].
15. **`IntentDialog` en `AudioPlaybackIntent`**: ¿lo lee Siri? Si no, `siri.pro` y `siri.quedan` se escriben en la versalita de la actividad.

**Para E1 / E7 (coherencia con 10 y 03):**
17. **Datos en versalitas fuera de la app**: 10 §2.11 y §5e.13 ponen la hora y el tiempo vivo en la versalita (`la.estado.terminada` "se fundió a las 00:25", `la.hasta` "hasta las 7:00", `la.madrugada.prefijo` + "20:00"); 03 §3.4 / §4.8 dicen "nunca un dato en versalitas". Esta entrega sigue a 10 (la cadena manda) y deja la cifra grande vacía en terminada y Madrugada para no duplicar. Se pide a E1 declarar la excepción en 03 §3.4 ("fuera de la app, la versalita puede llevar el tiempo") o a E7 mover la hora a una clave de cifra.
18. **Pendiente de E7** (cadenas que 09 necesita y 10 no tiene; redacción propuesta en 5 (e), no se compilan hasta que 10 las adopte): `la.estado.pausa.hora.sin`, `la.mezcla.sustituta`, `la.vo.contenedor`, `la.vo.abrir`, `la.vo.estado.*`, `la.stack.vo`, `di.vo.etiqueta`, `widget.config.mezclas` [1.1], `widget.vo.rect`, `cc.descripcion.toggle`, `cc.descripcion.madrugada`, `enum.minutos.*`, `nowplaying.en_directo`, `acostarte.parar`, `acostarte.accion`, `ajustes.ios17`, `ajustes.focus` [1.1], `watch.fuera` [1.2], `watch.vo.corona` [1.2], `ajustes.guia_hablada` [1.2]. Y una retirada: `la.madrugada` ("madrugada · 20 min") no se usa; el botón de la terminada es `madrugada.estado`.
19. **Para E4 (07)**: la Live Activity escucha `isFading` y `endDate` (hitos, no ticker) y necesita `pausedAt` en el snapshot; la ventana de la mañana (C48) la calcula el modelo (fin de Manto −60 min) y la actividad solo la refleja.

---

## 10. Autoevaluación

### 10.1 Puerta de formato (03 §8.3)

| Requisito | Dónde | Estado |
|---|---|---|
| Tabla de movimiento con señal del motor (M1…Mn) | §5 (a), M1-M12 | completa; cada fila nombra señal (`master` de `EngineCommand` en M4), duración/curva, Reduce Motion y Always-On |
| Tabla VoiceOver por control (etiqueta / valor / pista / rasgos / acciones) | §5 (b) | completa para 19-26 y 34; claves `ax.*` de 10; las que faltan, marcadas (E7) y pedidas en §9.18 |
| Tabla gesto → alternativa → Control por botón → teclado | §5 (c) | completa; ningún gesto es la única vía ni es oculto (C27); teclado fuera de la app marcado [a medir] |
| Dynamic Type por tramo (xS-L · xL-xxxL · AX1-AX2 · AX3-AX5) | §5 (d) | completa por superficie; StandBy declarado fuera de Dynamic Type |
| Catálogo de cadenas ES/EN por clave con contexto y longitud | §5 (e) | 103 claves: 83 de 10 §5e (letra a letra) y 20 pendientes de E7; frases de Siri en `AppShortcuts.xcstrings`, sin `Int` |
| Todas las medidas en pt | §2, §6 | sí; lienzos del sistema declarados; retícula de 4 pt; StandBy en cotas fuente y vistas |
| Un único juego de hex: el de 03 §3 / 04 §2.0.1 | todo | sí; se citan por token; ningún hex propio escrito (solo el plan B de C62 citado de 04); `índice-ac`, `trazo-ac` para High Contrast |
| Reparto gratis/Pro y versiones = §4-§5 de la reconciliación | §1, §2, §5 (e) | sí: nada Pro fuera de la app; Live Activity 1.0 (A) / 1.1 (B); mediano, Focus y Debajo de otro audio 1.1; Watch 1.2 |
| Maqueta y texto coinciden | §2 wireframes ASCII cotados frente a tablas de capas | sí; las cotas del ASCII son las de la tabla; las cajas se declaran como áreas de `Button` |

### 10.2 Las doce pruebas del brief

| P | Prueba | Cómo la pasa esta entrega |
|---|---|---|
| P1 Noche manda | se diseñó en rojo y a un metro primero (StandBy §2.21), después sin filtro; la actividad es siempre negra, también de día; solo oscura en 1.0 (C32) |
| P2 Un gesto a ciegas | pausa y "+15 min" son dos botones de 64 pt en posiciones fijas en la actividad; en StandBy un solo control de 128 vistos; el canal y el hueco del botón ausente no hacen nada; Madrugada es un toque desde cinco superficies (C27); prueba a ciegas de cinco personas en bloqueo repetida al cierre (03 §8.3) |
| P3 Negro real, un acento | fondo `negro` removible; cero color fuera de la app salvo el *on* del Control, que pinta el sistema (C61); conteo de colores distintos del gris por superficie: 0 |
| P4 Causa en el sonido | §5 (a): fuera de la app nada se mueve por decisión de la app; el horizonte es estático y su grosor es `master` al emitir (dos valores, ≥ 1 pt de diferencia); el Watch (1.2) respira con `BreathCurve` + `guide.anchor` |
| P5 Una familia | SF Pro (en el Watch, la fuente del sistema: §9.6); **4 estilos en la actividad**: 17 Semibold (nombre), 15 Medium versalitas (estado), 28 Medium tabular (cifra), 20 Medium (botón); nada < 15 pt fuera de la app (24 vistos en StandBy), nada < Medium; ningún paso nuevo (C67) |
| P6 Aire antes que cajas | cero rectángulos rellenos propios en toda la entrega; dos hairlines `trazo` en el mediano (1.1); los botones son texto y glifo, sin fondo |
| P7 Forma, no color | `pause.fill`/`play.fill`, horizonte presente/ausente (nunca cortado), cifra presente/ausente; §6 escala de grises y rojo |
| P8 44 y 64 | botones de la actividad 64, StandBy 128 vistos, widget pequeño = un solo objetivo de 158, filas del mediano 44 (1.1), Watch 64 + 44 con 12 de canal (1.2); canales ≥ 24 en la actividad |
| P9 Nada bloquea el sonido | ninguna superficie enseña "pro", prueba, precio ni candado; Siri recorta y describe (`siri.pro`); el widget y el Control arrancan siempre (Rosa a 40 si hace falta); Madrugada es una receta fija para todos (C05); recorrido del día 8 desde el bloqueo: idéntico al del día 7 (C23: la degradación nunca escribe) |
| P10 Una pantalla, una decisión | §1: cada superficie con su pregunta y con lo que no responde |
| P11 Técnico bajo el gesto | el nivel exacto solo con la corona del Watch (1.2) y `SetLevel` en Atajos (1.1); nada técnico en la actividad ni en el widget (receta solo en el mediano de 1.1, como fija 10 §2.11) |
| P12 Componentes de Apple | todo es del sistema: ActivityKit, WidgetKit, ControlWidget, App Intents, `AVRoutePickerView`, Now Playing, Focus filter (1.1), WatchKit (1.2); propios solo los dos símbolos (pendiente rosa, línea de agua) y el Disco del Watch; cero `glassEffect` propio (C66); dos gates de disponibilidad confinados a la extensión |

### 10.3 Conteos

Botones por superficie: actividad 2 · Isla 0 (sin expandida) · StandBy 1 · widget pequeño 1 · mediano (1.1) 4 · bloqueo 0 · Control 2 · Watch (1.2) 2. Palabras "Pro" visibles fuera de la app: 0, también en VoiceOver; habladas: 1 (`siri.pro`, que describe). "prueba": 0. Candados: 0. Colores fuera de la app: 0 propios. Animaciones propias fuera de la app: 0 (M9-M11 son del Watch, 1.2, con sesión). Hex escritos: 0 propios. Cifras estáticas que pueden mentir: 0 (todo tiempo es `Text(timerInterval:)`; el Control enseña el ajuste). Afirmaciones médicas: 0. Palabras vetadas (10 §0.5): 0. Intents 1.0: 7 con frase + 2 sin frase; 1.1: +3.

Desempate del brief: la versión que ha quitado más sin perder función. Frente a los cuatro conceptos, esta entrega quita el anillo, el Disco en la actividad, la alternancia de la Isla, el acento, `texto2`, la receta en gris, la segunda pantalla del Watch, el control "+15" del Centro de control y las frases con `Int`; frente a su propia primera versión, quita el horizonte cortado, el paso tipográfico nuevo, los minutos falsos de los widgets, dos intents, la segunda actividad del Manto, el `accessoryCircular`, el estado deshabilitado del Watch y la segunda pantalla de "Al acostarte"; con la reconciliación, quita la Isla expandida, el segundo control de StandBy, la escucha de 30 s por voz, los recortes del temporizador, la sustituta de Madrugada, la línea matinal, tres intents con frase y el widget mediano de 1.0; conserva pausa, +15 min, Madrugada, Dormir, estado y tiempo desde la mesilla, sin encender nada.

---

## 11. Respuesta al jurado

Registro histórico de la segunda versión (previa a la reconciliación). Donde §12 cambia una respuesta (Isla expandida, tiempo vivo con `Text(timerInterval:)`, control único en StandBy, título del toggle, causas de pausa, Watch 1.2), manda §12.

Las cinco listas se aplicaron en su totalidad para los hallazgos bloqueantes y mayores y para los menores compatibles con 03 §3-§4. Lo rechazado entonces, con la razón:

| Jurado · hallazgo | Respuesta |
|---|---|
| 3 de la mañana · Terminada sin botón izquierdo (`play.fill` arranca Madrugada; "20 min" fuera) | **Rechazado.** 03 §1.3 (injerto de Silencio) fija la terminada con el único botón de texto "Madrugada · 20 min" (C27). El botón izquierdo no cambia de significado: siempre son minutos de sonido (añadirlos o empezarlos). Sí se aplica lo demás: fuera "Dormir", fuera la duración. |
| 3 de la mañana · `la.estado.terminada.dia` "dormir" (06:00-21:00) | **Rechazado por innecesario.** No hay terminada de día (regla única: 21:00-06:00). |
| 3 de la mañana · "en pausa · se cortó el audio" | **Sustituido** entonces por "en pausa · sin audio"; tras la reconciliación, el motor caído es "en pausa" sin causa y, a los 30 min, `la.estado.detenido` (10). |
| 3 de la mañana · `Text(.currentDate, format: .timer(… maxPrecision: .seconds(60)))` (iOS 18) + "min" en 17 Medium | **Parcial entonces; adoptado en parte por §12.** El tiempo vivo es `Text(timerInterval:)` (10 §2.11, 03 §5 #19) y la precisión por minuto en iOS 18 queda en el spike I0-3. La unidad en otro cuerpo se descarta: 03 §3.4 ≤ 6 estilos y P5 piden menos estilos, no más. |
| Honestidad · unificar la ventana de widgets y Focus (00:00-06:00) con la de la terminada (21:00-06:00) | **Rechazado, justificado en §1.** Son dos preguntas distintas; C27 y C42 confirman 00:00-06:00 para el widget. |
| Honestidad · `Text(timerInterval:)` como opción para la cuenta atrás en widgets (M7) | **Rechazado entonces; superado por §12.** 10 §2.11 fija el tiempo vivo también en los widgets; lo que sigue fuera es la cifra estática recargada por hito. |
| Honestidad · `cc.on` → "Sonando · hasta las {hora}" fusionado | **Superado por §12**: el valor del toggle es `pagina.estado.sonando` "Sonando" y el subtítulo `control.sub.on` lleva la mezcla y los minutos del ajuste (10). |
| Restricción · horizonte de grosor fijo (2 pt) y M4 "presente / ausente" | **Rechazado en su primera forma, aplicado en la segunda.** 03 §4.1 fija "grosor = nivel maestro al emitir" fuera de la app: dos valores con ≥ 1 pt de diferencia (2 / 3 pt; 3 / 4 vistos en StandBy). |
| Restricción · cotas de StandBy en un lienzo de 852 × 393 | **Rechazado.** StandBy no da ese lienzo: es la vista de bloqueo escalada ×2 (C25 lo confirma: sin diseño propio). |
| Restricción · widget pequeño: botón x 96-140 e y 96-140, horizonte 88 | **Aplicado** en la geometría; pero el botón es todo el widget: la caja marca el glifo, no un objetivo. |
| Restricción · `focus.manana` con copy nuevo | **Sin objeto tras C08**: no hay línea matinal. |
| Restricción · "Parar" en la Isla expandida | **Sin objeto tras C25**: no hay Isla expandida. |
| Plataforma · `.relative` para la Isla compacta "o quitar el trailing" | **Se conserva el trailing** con el tiempo vivo y `minimumScaleFactor(0.8)`: 03 §5 #20 fija "Glifo + '38 m'". |
| Plataforma · `la.vo.causa` "interrumpido / los auriculares / el audio" | **Superado por §12**: las causas son las que el motor distingue (auriculares, airpods, llamada; C48, C49). |
| Primera impresión · Isla expandida con dos botones | **Sin objeto tras C25.** |
| Primera impresión · fuera de la app el estado como frase en caja normal (sin versalitas) | **Rechazado en la actividad, aplicado en los widgets.** 03 §4.8 y §5 #19 fijan la versalita de estado en la Live Activity; en el widget la versalita lleva solo la palabra y el tiempo vivo va aparte (10 §2.11). |
| Primera impresión · segunda línea de la actividad como "Se funde a las 00:25" | **Rechazado.** La cifra ya cuenta; duplicar la hora en la versalita sería un dato dos veces. (La hora de la terminada sí va en la versalita porque 10 lo fija así: §9.17.) |
| Primera impresión · widget mediano con tres filas de 44 | **Rechazado entonces por P8 / 03 §3.5; adoptado en 1.1** por 03 §5 #22 y 10 ("tres mezclas"): tres filas-botón de 44, el mínimo de P8. |
| Primera impresión · `widget.mediano.descripcion` "Tu última mezcla y tres más." | **Superado**: 10 fija "Tres mezclas. Un toque y suenan." |
| Primera impresión · "se pausó a las 00:12 · AirPods" con caja de marca | **Adoptado por C49 / 10**: `la.estado.pausa.hora` "se pausó a las %@ · airpods" (minúscula, como escribe 10). |
| Primera impresión · Watch: área táctil y 60-180 | **Aplicado como y 60-178** (retícula de 4 y canal de 12 con el botón de 190). |
| Varios · los dos hex del filtro rojo (resultado de 02 §2.3, no tokens) | **Aplicado**: ningún hex propio escrito en este documento; se citan los ratios de 02 §2.3 / 03 §3.1 y el plan B de C62 por referencia a 04. |
