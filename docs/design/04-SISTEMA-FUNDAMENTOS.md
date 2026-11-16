# SleepNoise · 04 · Sistema y fundamentos

**Equipo E1 (diseño de sistemas + iOS que construye) · 16 de noviembre de 2026 · Documento 04 de la serie de diseño · fase de especificación · reconciliación producto–diseño aplicada el 16-11-2026 (§12)**

Insumos leídos completos: `03-DIRECCION-DE-DISENO-2026-11-16.md` (§3 tokens, §4 componentes, §5 inventario y §8.3 puertas son ley), el brief del director creativo para E1, `tokens.md`, `grafts.md`, `decisions.md`, `00-BRIEF-CREATIVO` (P1-P12, listas negras §7), `02-MATERIALES` (§1.4-1.5, §2, §3, §4, §7, §8), `concepts/grafito.md` entero (§1-§2, §10-§16 son el linaje directo), `concepts/dial.md` §2.1 y §3.0-3.8 (Índice, Disco, Regla), `concepts/marea.md` §2.1, §3.1-3.7 y §4.5-4.6 (horizonte a un tercio, hoja, línea de agua como control, guarda de 300 ms), `concepts/silencio.md` §2.1, §3.2-3.8 y §4 (color = sonido, palabra entre hairlines, gestos y alternativas), el código de `main` (`AccessPolicy.swift`, `SoundID.swift`, `MixerModel.swift`, `Features/Breathing`, `Features/Timer`, `Features/Paywall`, `Features/Library`, `Audio/DSP/Breath.swift`, `EngineCommand.swift`, `SoundGains.swift`, `Theme.swift`, `Localizable.xcstrings`), `INVESTIGACION-MERCADO` §1 y §5.2, y `REVIEW-PR3` §"Encaje" y hallazgos de interfaz.

**Convenciones.** Medidas en pt para 393 × 852 en tamaño Large (área segura 59 arriba, 34 abajo). Hex: únicamente los de §3 de 03; si un token no existe, se propone en §9 y se usa el más cercano. Textos de interfaz ES con EN entre corchetes; las cadenas de §5e son las que se compilan. **[a medir]** = no verificado en dispositivo. **[spike I0-n]** = depende de ingeniería (I0-1 medidor RMS render → main; I0-2 geometría del arrastre en dispositivo, que valida el umbral de `LevelRule` (C52); I0-3 intents, del que dependen "terminada → Madrugada" y el hueco del "+15 min" (C25, C27); I0-5 CoreMotion, solo investigación, sin producción en 1.0 (C35); I0-6 tinte real de StandBy, criterio de C62; I0-7 timbre en el bus maestro, del que depende la fila Timbre (C29)). Nombres de tipos en `monoespaciado`; los listados SwiftUI están en el Anexo A y **no se han añadido al proyecto Xcode** (cada listado dice qué fichero crearía). La build de referencia es compilable conceptualmente en iOS 17 con un único `#available(iOS 26)` (en `PrimaryActionStyle`).

**Lo que este documento fija y lo que no.** Fija los tokens como asset catalog, la escala tipográfica con `relativeTo`, la retícula, la hairline, el único relieve, los seis componentes propios en sus seis estados, los cinco patrones y la checklist de aceptación. No fija pantallas (E2-E6): cuando aquí aparece una pantalla es para cotar un componente dentro de ella y la cota manda sobre la de 03 solo si 03 no la daba. Alcance, versiones y reparto gratis/Pro son los de `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` §4-§5 (1.0 solo oscura; Papel 1.1; temporizador entero libre; 3 mezclas gratis; 5 texturas libres / 6 Pro) y el vocabulario el de su §3, que 10 fija; §12 lista cada delta aplicado.

**Dónde este documento contradice a `main`, dicho.** (1) `AccessPolicy.freeSavedMixLimit = 1` y `freeTimerMinutes = {15, 30, 60}`: el sistema se diseña para 3 mezclas gratis (`freeSavedMixLimit` 1 → 3; sin límite con Pro, reconciliación §1 regla 3) y un temporizador entero libre (C03: `freeTimerMinutes` y `timerIsIncluded` desaparecen; `maxTimerMinutes = 360` queda como tope técnico de Hasta dormirme para todos; Manto se expresa por hora, C22); el viento pasa a la rama libre de `soundIsIncluded` (C04). (2) `MixerModel.setLevel` abre el paywall al tocar una capa Pro: el toque sigue siendo el disparador, pero pasa por `SaleGate` (de noche y fuera de `.active` no hay hoja, C06/C08) y la hoja arranca la prueba con un `startTrial()` propio: `startTrialIfNeeded()` sale de `play()` (C07) y `TrialClock` pasa a Keychain. No hay escucha de 30 s en 1.0 (C06): `preview(_:seconds:)` no se pide. (3) `Palette` y `NightBackground` (`Theme.swift`) desaparecen: degradados y resplandor son lista negra §7.1. (4) `SoundID.symbolName` deja de usarse en el mezclador (cero iconos); se conserva para Atajos y widgets, donde E6 decide. (5) No existe medidor RMS: el horizonte lee la ganancia maestra (`envelopeTarget × Σ gains`) y se marca provisional hasta I0-1. El nivel maestro sí entra en 1.0 como `EngineCommand.setMaster(level:, ramp:)` (C51: nivel de sesión, no persiste, nunca toca el volumen del sistema); el arrastre vertical de Noche y Madrugada lo mueve y el estado dice "Sonando · al 40". (6) `BreathCurve` real: inhalación 0,40 del ciclo, exhalación 0,45, reposo 0,15 (a 6 por minuto: 4 s arriba, 4,5 s abajo, 1,5 s quieta en bajamar). El "4:6" de 03 es la lectura visual correcta; la línea de agua usa la curva tal cual, nunca una aproximada. (7) Las rampas del motor no son las de 03 §3.7: `SleepAudioEngine.defaultFadeIn` pasa de 1,5 s a 0,8 s y `MixerModel.pause(resumeLater:)` de 0,04 s a 1,5 s (la pausa por llamada mantiene 0,3 s); el fin de temporizador ya llega fundido. Sin ese cambio M1 y M3 serían animaciones sin señal. (8) `SleepTimerController.startTicking` (un `Timer` a 4 Hz toda la noche) pasa a dos timers de un disparo (`Timer(fire:)` a la fecha del fundido y a la de fin, como ya hace `BreathingGuideController.schedule(at:)`); `remaining` se calcula desde `endDate` solo cuando una vista lo pide (`Text(timerInterval:)` en Noche y en la Live Activity). Es requisito de la puerta de dispositivo ("10 min bloqueado sin actividad periódica salvo el motor"), no de E4. (9) La disolución de la Marea pasa de 120 s fijos tras `guideEndsAt` a `max(30 s, 20 % de guideMinutes)`, y `setBreathingEnabled(false)` llama a `release(over: 30)` en vez de `end()` (nunca un corte). (10) Ninguna entrada a Noche depende del Focus de Sueño en 1.0: no hay API para leerlo salvo un Focus filter (1.1).

---

## 1. Intención

P10 exige una pregunta por superficie. E1 no entrega pantallas; entrega las piezas con las que E2-E6 responden a las suyas. Cada pieza responde a una sola pregunta y, si necesitara texto para explicarse, estaría mal partida.

| Pieza | Pregunta a la que responde | Qué no responde (lo hace otra pieza) |
|---|---|---|
| **Horizonte** (`SoundLine`) | "¿Está sonando ahora?" | Cuánto suena cada capa (LevelRule); cuánto queda (StateWord). |
| **Regla de nivel** (`LevelRule`) | "¿Cuánto de esta capa?" (y, en la fila Timbre al pie de Capas, "¿grave o lejos?", C29) | Si la capa es Pro se dice con una palabra, no con la regla. |
| **Línea de agua** (`TideLine`) | "¿Inhalo o exhalo, y a qué ritmo?" | Cuándo se retira (StateWord en paso 7). |
| **Disco** (`PlayDisc`) | "¿Dónde empiezo?" | El estado se lee en el horizonte, no en el Disco. |
| **Pantalla como botón** (`FullScreenControl`) | "¿Puedo pausar sin mirar?" | La hora y el estado son texto encima; la pieza es solo el gesto. |
| **Acción primaria** (`HairlineAction`) | "¿Qué hago aquí, y cuánto cuesta?" | Lo que no es primario es `TextAction`. |
| Fila editorial, palabra de estado, acción secundaria, hoja, barra, toggle, tip | Del sistema con estilo; responden a lo que el sistema ya responde. | — |
| **Patrones** (§4) | Entrar/salir de Noche: "¿cómo me acuesto y cómo vuelvo?". Pro sin castigo: "¿qué pasa si toco lo que no tengo?" (de día, la hoja Pro; de noche, nada). Permiso: "¿por qué me lo pides ahora?" (porque lo acabas de elegir). Hoja: "¿dónde estoy y cómo salgo?". Tip: "¿qué no he descubierto solo?" (una línea, una vez). | — |
| **Galería de referencia** (`SystemGallery`, solo DEBUG; contenido en §2.8) | "¿Se ve cada componente en sus seis estados, cuatro tramos de Dynamic Type y dos apariencias?" Es la pantalla con la que se pasa la puerta de dispositivo (03 §8.3.3). | No es una pantalla de producto. |
| **Modo papel** (inventario #29, **1.1**, C32) | "¿La misma app, de día?" Mismos componentes; cambian los tokens, nada más. En 1.0 la app es solo oscura (`preferredColorScheme(.dark)` en la raíz); los tokens quedan en el catálogo marcados 1.1. | Noche, Madrugada y página nocturna son siempre negras. |

---

## 2. Anatomía

### 2.0 Fundamentos

#### 2.0.1 Asset catalog de tokens

Un color = un `Color Set` con cuatro apariencias: *Any* (= Dark, nocturno), *Dark · High Contrast*, *Light* (papel, **1.1**, C32) y *Light · High Contrast*. Las variantes High Contrast de papel no existen en 03: se declaran iguales a la normal y se miden en 1.1 (§9 #22). Nombres de activo sin acentos; el código los expone como `Ink.*` (Anexo A1).

| Activo | Token 03 | Nocturno (Any/Dark) | Dark · High Contrast | Papel (Light) · 1.1 | Light · High Contrast · 1.1 | Uso |
|---|---|---|---|---|---|---|
| `negro` | `negro` / `papel` | `#000000` | `#000000` | `#F3F0E9` | `#F3F0E9` [a medir] | Fondo de principal, Noche, Madrugada, Mezclas, Capas, Qué sabemos |
| `hoja` | `hoja` / `hoja-papel` | `#1C1C1E` | `#1C1C1E` | `#FFFFFF` α 0,60 | `#FFFFFF` α 0,60 | Fondo de hojas; nunca en Noche ni Madrugada |
| `grafito` | `grafito` / `pulsado-papel` | `#1E1D1B` | `#1E1D1B` | `#E9E5DC` | `#E9E5DC` | Único relieve: Disco, pista de 44 pt bajo el dedo y fila editorial pulsada (200 ms); nunca tarjeta |
| `trazo` | `trazo` / `trazo-papel` | `#2A2A2E` | `#3A3836` | `#D8D3C9` | `#D8D3C9` [a medir] | Hairline sobre `negro` |
| `trazoHoja` | `trazo-hoja` | `#38383B` | `#3A3836` (más cercano; §9) | `#D8D3C9` (más cercano; §9) | `#D8D3C9` | Hairline sobre `hoja` |
| `texto` | `texto` / `tinta` | `#E8E4DC` | `#E8E4DC` | `#1E1C19` | `#1E1C19` | Tinta principal; única tinta fuera de la app. Criterio (C62): ≥ 4,5:1 dentro de la app; fuera (StandBy, bloqueo) texto ≥ 24 pt y ≥ 3:1 bajo rojo medido en dispositivo (spike I0-6); plan B: `#F0ECE4` si la medida queda por debajo de 3,5 |
| `texto2` | `texto2` / `tinta2` | `#9C9A96` | `#B4B2AE` | `#5F5A53` | `#5F5A53` [a medir] | Secundario, estado, versalitas |
| `texto3` | `texto3` / `tinta3` | `#6E6C68` | `#7A7672` | `#9C958A` | `#5F5A53` (02 §2.4: componentes a 3:1 usan `tinta2`) | Solo no textual o ≥ 18 pt |
| `textoNoche` | `texto-noche` | `#A2A09A` | `#B4B2AE` (más cercano; §9) | `#A2A09A` | `#B4B2AE` | Única tinta de texto de noche; sin variante papel porque la noche es negra |
| `indice` | `índice` / `ocre` | `#F0C020` | `#FFD23C` | `#8A6508` | `#8A6508` [a medir] | El acento. Solo líneas ≥ 1,5 pt, glifos ≥ 3 pt, texto ≥ 18 pt. Nunca relleno; nunca fuera de la app salvo el tinte *on* del Control (C61) |
| `indiceNoche` | `índice-noche` | `#BA941C` | `#FFD23C` (más cercano; §9) | `#BA941C` | `#FFD23C` | Índice de noche, solo formas ≥ 2 pt bajo el dedo |
| `AccentColor` | — | `#F0C020` | `#FFD23C` | `#8A6508` | `#8A6508` | Tinte *on* del control del Centro de control: la única excepción al "sin acento fuera de la app" (C61). Dentro de la app la raíz lleva `.tint(Ink.text)`: ningún control (barra, Toggle de Marea, Slider, cursores, chevrons) hereda el acento (03 §4.12 consolidado: el Toggle va en `texto`) |

Ratios (03 §3.1): `texto` 16,56 sobre negro / 13,42 sobre hoja / 4,43 rojo A; `texto2` 7,48; `texto3` 4,01; `texto-noche` 8,03; `índice` 12,27 / 9,84 / 4,71; `índice-noche` 7,34; `ocre` 4,68 sobre papel (1.1). Si el dueño elige el rojo grafito (`#E0524D`; reconciliación §6 #1, plazo 27-11-2026), cambian `indice` Any, `indiceNoche` Any y `AccentColor` Any; nada más.

No existe `error`: el fallo de audio es texto `texto2` que es botón; el único rojo es la acción "Eliminar" del sistema al deslizar. No existe un token de opacidad. Opacidad solo en cinco sitios: el horizonte y la línea de agua (0,6-1,0 por señal del motor; con Reduce Motion la línea de agua respira en opacidad), la sombra interior del Disco (`negro` al 60 %), el estado pulsado de cualquier botón de texto (`HairlineAction`, `TextAction`, botones de Noche: 0,6 durante 200 ms) y `hoja-papel` (blanco al 60 % sobre papel). Ninguna tinta de texto en reposo lleva opacidad.

#### 2.0.2 Escala tipográfica (nueve pasos, SF Pro, Text/Display automáticos)

`TypeStep` (Anexo A2) construye cada paso con `@ScaledMetric(relativeTo:)` sobre el tamaño Large, de modo que escala con el estilo indicado y respeta Bold Text. Sin New York, SF Mono ni Rounded. Versalitas con `.lowercaseSmallCaps()`; cifras con `.monospacedDigit()`. El interlineado de la tabla es la **altura de línea** de 03 §3.4, no el `lineSpacing` de SwiftUI (que es aire extra): `Stepped` calcula `lineSpacing = max(0, alturaObjetivo × escala − UIFont.systemFont(ofSize: escalado).lineHeight)`, de modo que 17 pt mide 22 de línea y no ≈ 25. El tracking de la cifra es `−1 %` del tamaño escalado (no −0,72 fijo).

| Paso | Nombre en código | Peso | Large pt / interlineado | `relativeTo` | Tope | De noche | Tracking |
|---|---|---|---|---|---|---|---|
| 1 Cifra | `.figure` (72) / `.figureSmall` (56) | Regular | 72 / 80 · 56 / 64 | `.largeTitle` | `.accessibility2` | Regular (≥ 20 pt) | −1 % |
| 2 Nombre | `.name` | Medium | 28 / 34 | `.title` | — | — | 0 |
| 3 Cabecera | `.header` / `.nightState` | Semibold / Medium | 22 / 28 | `.title2` | — | Medium | 0 |
| 4 Acción nocturna | `.nightAction` | Medium | 20 / 25 | `.title3` | — | Medium | 0 |
| 5 Fila | `.row` / `.value` (17 Medium tabular: el valor de nivel bajo el dedo) | Semibold / Medium | 17 / 22 | `.headline` | — | Semibold / Medium | 0 |
| 6 Cuerpo | `.body` / `.reading` (17 / 26) / `.bar` (17 Medium, solo "Mezclas" y "Noche" en la barra) | Regular / Medium | 17 / 22 | `.body` | — | Medium | 0 |
| 7 Secundario | `.secondary` | Regular | 15 / 20 | `.subheadline` | — | Medium | 0 |
| 8 Nota | `.note` | Regular | 13 / 18 | `.footnote` | — | Medium | 0 |
| 9 Dato | `.data` (tabular) / `.stateWord` (versalitas) | Medium | 13 / 18 | `.footnote` | — | Medium | +2 % en versalitas |

Reglas en código: `TypeStep.font(phase:)` sube Regular → Medium cuando `NightPhase` es Noche, página nocturna o Madrugada (nunca por debajo de Medium de noche; Regular solo en la cifra ≥ 20 pt). Light, Thin y Bold no existen en `TypeStep`. `minimumScaleFactor(0.8)` solo en el nombre de mezcla escrito por el usuario. Ningún `Text` lleva `.font(.system(size:))` directo: todo pasa por `.step(_:)` (prueba en Anexo B). ≤ 6 pasos por pantalla (la galería cuenta los que usa cada pantalla de E2-E6 en su checklist); `.value` y `.bar` no son pasos nuevos de la escala (sigue siendo de nueve), pero **17 Medium cuenta como un estilo** en el conteo de ≤ 6 por pantalla (C67); la principal en reposo usa ≤ 4 (2, 5, 7, 9). La principal con Marea terminando usa 2, 5, 7, 9 y la barra: la nota "Se ha retirado. El mar sigue." va en paso 7 (no 8) para que E2 conserve un estilo libre.

#### 2.0.3 Retícula, hairline, radios, relieve, objetivos

`Grid` (Anexo A3): unidad 4; margen 20 (columna 353 en 393, 335 en 375); fila 56; fila con subtítulo 72; **fila de capa 80 = 56 táctiles + 24 de canal muerto** (el canal es `padding` fuera del `contentShape`); grupos 32; aire interno 16; **banda del horizonte 24, o 120 siempre que la mezcla cargada tenga Marea disponible** (`HorizonLayout(bandHeight:)`; la línea de agua vive dentro de esa banda y nada de lo de debajo cambia de sitio al activarla); objetivo 44; objetivo nocturno 64; pulsación larga única `Grid.longPress = 0,6 s` (fila, horizonte, Noche). **Horizonte a un tercio**: `HorizonLayout` sitúa el centro de la banda en `y = H × 0,333` medido sobre la pantalla completa (redondeado al múltiplo de 4 más próximo: 284 en 852; 224 en 667; 280 en 844), tomando H del `GeometryReader` del contenedor más sus `safeAreaInsets` (nunca `UIScreen`, que miente en iPad y Stage Manager), nunca en un `y` absoluto; con `dynamicTypeSize.isAccessibilitySize` se ancla a 24 pt bajo la cabecera. 03 §1.3 y §3.5 coinciden ya en esta cota (§9 #15 cerrada). Hairline: `Hairline` dibuja `1 / displayScale` de alto (0,5 pt en 2× y 0,33 en 3×), de margen a margen, `trazo` sobre negro y `trazoHoja` sobre hoja; es el único separador (no existe una hairline vertical: tres objetivos contiguos se separan con 32 pt de aire). Radios: 0 en todo lo propio; el sistema pone los suyos en hojas, Live Activity y widgets; el Disco es un círculo. Relieve: solo el Disco (`grafito` + sombra interior 1 pt `negro` al 60 %), la pista `grafito` de 44 pt bajo el dedo (fila tocada = pista grafito de 44 pt en todas las versiones de iOS, C66) y la fila editorial pulsada 200 ms; sin sombras exteriores, degradados ni materiales propios. Objetivos: ≥ 44 × 44; 64 en Disco, "+15 min", acciones de Noche; pantalla completa en Noche y Madrugada; ≥ 24 pt entre objetivos sin borde.

#### 2.0.4 Reglas transversales resueltas en código

| Regla (03 §3.1) | Mecanismo |
|---|---|
| Color = sonido o dedo | `SoundLine` solo pinta `indice` cuando `meter.isProducingAudio` y nadie arrastra; `LevelRule` pinta `indice` solo mientras dura el gesto; al soltar, el horizonte recupera el índice en 200 ms; al parar el motor, el índice se va en ≤ 1,5 s con la ganancia. En reposo sin dedo no hay ningún píxel de acento. Excepción única: las dos hairlines de "Comprar" con precio cargado. |
| Un índice por pantalla | `IndexArbiter` (entorno): el dueño del índice es `.finger(SoundID)` > `.tide` > `.horizon`; cada componente pregunta `arbiter.owns(.horizon)` antes de pintar acento. El Disco nunca lo pide. Las hairlines de "Comprar" con precio quedan fuera del árbitro por regla, no por reclamación. El Toggle de Marea va en `.tint(texto)` (03 §3.1 regla 2 y §4.12 consolidados; §9 #14 cerrada) y el `Slider` del sistema bajo pulsación larga también: nunca índice. |
| De noche una tinta | `NightPhase` (entorno) y `Ink.primary/secondary`: en `.night`, `.nightPage` y `.smallHours` toda tinta de texto resuelve a `textoNoche`, las hairlines a `trazo` y el índice a `indiceNoche` (solo bajo el dedo). `Ink.secondary` de noche devuelve `textoNoche` (no `texto2`). El glifo del Disco también pasa por `Ink.primary(phase)` (página nocturna). Prueba: la galería renderiza cada componente en `.nightPage`, `.night` y `.smallHours` y comprueba que ningún `Text` resuelve a `texto`, `texto2` ni a un `Font.Weight` < `.medium`. |
| Fuera de la app una tinta, estado por forma | `Ink.system` = `texto`; las vistas de la extensión importan solo `Ink.system`, `Grid` y `TypeStep` (sin `indice`). Estado: `play.fill` / `pause.fill`; línea continua = suena, ausente = pausa. |
| Sin tinte heredado | La raíz de la app lleva `.tint(Ink.text)`; `AccentColor` del catálogo solo tiñe el *on* del Centro de control. Cada `Text` o `Image` dentro de un `Button` fija su `foregroundStyle`. Prueba: `grep -n "foregroundStyle" Design/` cubre cada `Text` e `Image` de botón; ninguna captura de la galería en reposo contiene el hex del índice. |
| Nada cambia de posición | No hay `offset`, `position` ni `scaleEffect` animados en ningún listado; todo `withAnimation` toca grosor, longitud, opacidad o contenido. Tampoco cambia de tamaño ningún contenedor con contenido debajo: la banda del horizonte es de 120 pt siempre que la mezcla tenga Marea disponible (no "crece" al activarla) y la descomposición por pulsación larga se superpone dentro de la banda. Prueba: `grep -n "offset\|scaleEffect\|matchedGeometryEffect" Design/` devuelve cero, y ningún `.frame(height:)` de un listado está animado. |

### 2.1 Horizonte (`SoundLine`)

```
 x: 0        20                                            373   393
    ┌────────┬───────────────────────────────────────────────┬────┐
y=272│        │                 banda 24 pt                    │    │
    │        │  ·····································hairline │    │  reposo: hairline trazo 0,5
y=284│        │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │    │  sonando: índice, 1,5→3 pt, op. 0,6→1,0
y=296│        │                                                │    │
    └────────┴───────────────────────────────────────────────┴────┘
     margen 20                 353 (335 en 375)             margen 20

 Pulsación larga (0,6 s; aparece en 400 ms): dentro de la MISMA banda de 24 pt se superponen n líneas (una por capa),
 a paso 4 pt centradas (nunca más de seis: tope de capas simultáneas de C19; 6 capas = 20 pt), grosor 1→3 pt por nivel
 de esa capa, texto con opacidad por su RMS. La banda no cambia de tamaño: nada de lo de debajo se mueve.
 Marea disponible en la mezcla: la banda es de 120 pt SIEMPRE (reservada, con el horizonte centrado en ella);
 al activar la Marea aparecen las marcas y la línea es la línea de agua (§2.3). Nada baja.
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Banda | — | transparente | 353 × 24 (353 × 120 si la mezcla tiene Marea disponible), centro en H × 0,333 | Nunca cambia de posición ni de tamaño durante una sesión |
| Línea en reposo | — | `trazo` | 0,5 pt (hairline) | Quieta. En papel (1.1) `trazo-papel` |
| Línea sonando | — | `indice` (`texto` si un dedo arrastra; `textoNoche` en la página nocturna) | grosor 1,5 + 1,5·rms (03 §4.1: el índice nunca baja de 1,5 pt); opacidad 0,6 + 0,4·rms | RMS maestro, τ 500 ms, evaluado en el `TimelineView` (el único reloj); nace de la hairline en 800 ms `.easeOut` (= `defaultFadeIn`, §0 (7)) |
| Línea fundiendo | — | `indice` → `trazo` | 3 → 0,5 pt | Sigue la ganancia real suavizada: 1,5 s en pausa (§0 (7)), lo que dure el fundido final |
| Líneas por capa | — | `texto` | 1→3 pt cada una, paso 4 pt, superpuestas en la banda | Aparecen en 400 ms con opacidad; se recomponen al soltar; la banda no crece |
| Noche / Madrugada | — | `textoNoche` | 2 pt; continua / ausente | Estática; no lee el medidor (`TimelineView` pausado); el estado accesible vive en el `FullScreenControl` (C63) |
| Página nocturna | — | `textoNoche` | 1→3 pt por RMS, siempre en `textoNoche` | Lee el motor como de día; nunca índice (el `indiceNoche` lo lleva solo la línea de nivel bajo el dedo) |
| Fuera de la app | — | `texto` | 2-3 pt | Estática; grosor = nivel maestro al emitir |

### 2.2 Regla de nivel (`LevelRule`)

```
 x: 0   20                                                   373  393
    ┌───┬──────────────────────────────────────────────────────┬───┐
 0  │   │  canal muerto 12 pt (no responde)                     │   │
 12 │   ├──────────────────────────────────────────────────────┤   │  ┐
 32 │   │  Lluvia                 (paso 5, Semibold 17)   40   │   │  │ área     ← línea base del nombre (20 bajo el borde del área)
 48 │   │  sobre el tejado        (paso 7, 15)        (paso 9) │   │  │ táctil   ← línea base del subtítulo
 56 │   │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──────────  │   │  │ 56       ← línea de nivel (su marco de 3 pt termina a 12 del borde inferior del área)
 68 │   ├──────────────────────────────────────────────────────┤   │  ┘
 80 │   │  canal muerto 12 pt                                   │   │
    └───┴──────────────────────────────────────────────────────┴───┘
      paso de fila 80 = 56 táctiles + 24 de canal (12 arriba + 12 abajo); etiquetas con padding inferior 16, línea con 12 (retícula de 4)

 Bajo el dedo:  pista grafito 353 × 44 (y 12→56, de margen a margen) detrás del texto; línea 3 pt índice; valor 17 pt texto tabular, derecha, en su sitio.
 Pro:           "Océano" en texto2 · subtítulo honesto (E2) · "pro · 30" versalitas; pista texto3 completa. Toque = hoja Pro ("Empezar la prueba · 7 noches" / "Comprar · {displayPrice}") solo si SaleGate lo permite; de noche nada (C06, C08).
 Pulsación larga (0,6 s): un Slider del sistema de 44 pt en texto SUSTITUYE a la línea de nivel en su sitio (dentro del área táctil, y 12→56); nada crece ni se mueve (03 §4.2); se retira a los 5 s sin dedo encima (C21).
 Página nocturna: el arrastre exige 16 pt y un cono de 20°; si el eje se fija vertical, el gesto cede al scroll; mientras un scroll
 está en curso ninguna fila acepta arrastre (valor hasta I0-2). De día 8 pt y 30°: el umbral lo valida el spike I0-2 (C52); horizontal = nivel,
 vertical = scroll, sin gesto de timbre.
 Fila Timbre (C29): la misma regla al pie de Capas, con "Grave" / "Lejos" (paso 9 versalitas) en los extremos en lugar del valor; actúa sobre el bus maestro [spike I0-7].
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Nombre | 5 | `texto` (`texto2` si Pro sin acceso) | línea base a 20 del borde superior del área táctil (y 32) | Nunca se trunca; en AX1+ pasa arriba solo |
| Subtítulo | 7 | `texto2` | línea base a 36 (y 48) | Honesto ("lejano, sin rayos cerca") |
| Valor | 9 (tabular) | `texto2` | derecha, misma línea base que el nombre | Oculto a 0; bajo el dedo `.value` (17 Medium tabular, `texto`), en su sitio: ancho mínimo fijo para tres cifras, nunca salta al pasar de 9 a 10 |
| Palabra Pro | 9 versalitas | `texto2` | donde iría el valor | "pro" o "pro · 30" (conserva el nivel guardado: el motor lo ignora sin acceso y la degradación nunca escribe, C23) |
| Línea llena | — | `texto` | 2 pt, de margen a margen × nivel; y 56 | Longitud sigue al dedo; 1 pt = 1/(ancho de la columna − 20), tomado del `GeometryReader` de la regla (1/333 en 393, 1/315 en 375) |
| Línea vacía (pista) | — | `texto3` | 1 pt | Siempre visible |
| Línea bajo el dedo | — | `indice` (`indiceNoche` de noche) | 3 pt | 150 ms entrada / 250 ms salida |
| Pista táctil | — | `grafito` | 353 × 44 (y 12→56), radio 0 | Solo mientras dura el gesto; termina donde empieza la línea de nivel |
| Slider del sistema | — | `tint(texto)` (`textoNoche` de noche), pista del sistema | 44 pt, en el sitio de la línea de nivel (y 12→56) | Alternativa sin gesto y ajuste fino (C21); se lee por forma (pulgar y pista), nunca índice; se retira a los 5 s sin dedo encima o al tocar fuera (03 §4.2); etiqueta accesible `capas.deslizador` ("Nivel de {capa}") |
| Arrastre en la página nocturna | — | — | `minimumDistance` 16 pt; cono 20° (`abs(h) < abs(w) × 0,364`) | Si el primer evento fija el eje vertical, el gesto no consume (`simultaneousGesture`) y el scroll gana; con un scroll en curso (`onScrollPhaseChange` en 18+, `isScrolling` propio en 17) ninguna fila acepta arrastre. De día: 8 pt y 30° [spike I0-2 valida el umbral, C52] |
| Fila Timbre (C29) | 5 / 9 | como una capa | al pie de Capas; extremos "Grave" / "Lejos" en versalitas donde iría el valor | Mismo componente sobre el bus maestro; 1.0 condicionada al spike I0-7 (puerta semana 4–6; si no llega, 1.1 sin cambiar el copy); timbre por capa en 1.1 |

### 2.3 Línea de agua (`TideLine`)

```
 x: 20                                                    373
    ┌──────────────────────────────────────────────────────┐
 0  │  ·····································  pleamar (hairline texto3)       inhala  (paso 7, derecha, 3 primeras resp.)
    │                                                      │
    │                                                      │
 60 │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  línea 2 pt (índice en la principal, texto en la hoja)
    │                                                      │        y = 120 − 120 × BreathCurve(t)
    │                                                      │
120 │  ·····································  bajamar (hairline texto3)
    └──────────────────────────────────────────────────────┘
 banda 120 pt, RESERVADA en la principal siempre que la mezcla tenga Marea disponible (el horizonte en reposo es la hairline
 centrada en ella, en H × 0,333); al activar la Marea aparecen las marcas y la línea de agua con opacidad (800 ms): nada se mueve.
 En la hoja, y 120-240 desde la cabecera.
 En la hoja: arrastre vertical sobre la banda = ritmo (4-8 por minuto); .selection por entero; aplicado al siguiente ciclo.
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Marcas pleamar / bajamar | — | `texto3` (principal y hoja) / `trazo` (Madrugada: de noche las hairlines van en `trazo`, 03 §3.1 regla 3) | hairline, de margen a margen | Fijas mientras la Marea guía o se disuelve; aparecen y desaparecen con opacidad (800 ms). En Reduce Motion también |
| Línea de agua | — | `indice` (principal) / `texto` (hoja) / `textoNoche` (Madrugada, 1,5 pt) | 2 pt | `BreathCurve.value(secondsSinceStart:parameters:)` con `anchor + outputLatency`, amplitud × `guide.scheduledWeight(now:)`; 30 Hz pausable; se pausa sola a los 20 min (`windowClosed`) y con una hoja delante |
| Palabra de fase | 7 | `texto2` | derecha de la banda, línea base a 16 | "inhala" / "exhala"; 250 ms; desaparece tras la tercera exhalación (500 ms) |
| Palabra de estado | 9 versalitas | `texto2` | bajo la banda, izquierda | "guiando · 6 por minuto" / "disolviendo" |
| Hora de retirada | 7 | `texto2` | misma línea, derecha | "Se retira a las 23:27" (nunca en versalitas: dato nocturno) |
| Nota de retirada | 7 | `texto2` | bajo la banda, 10 s | "Se ha retirado. El mar sigue." (paso 7, no 8: la principal no gasta un estilo en una nota de 10 s) |

### 2.4 Disco (`PlayDisc`)

```
          64 × 64 objetivo (invisible)
        ┌──────────────┐
        │   ╭──────╮   │   círculo 44 pt grafito #1E1D1B
        │   │  ▶   │   │   sombra interior 1 pt negro 60 % (tecla)
        │   │      │   │   glifo play.fill / pause.fill 22 pt texto
        │   ╰──────╯   │   pulsado: sombra interior 2 pt, 200 ms
        └──────────────┘   iOS 26: el vidrio del sistema (la barra envuelve el ítem) sustituye al relieve
   Barra inferior:  [ Mezclas ]        ( ▶ )        [ Noche ]     y 754-818 [a medir]
   = 64 + 34 de área segura; el Disco (44 visible, 64 táctil) centrado en y 786; "Mezclas" y "Noche" con línea base en 790.
   La barra del sistema (`ToolbarItemGroup(.bottomBar)`) mide ≈ 49 pt en 17/18: el objetivo de 64 se consigue con un
   `contentShape` que desborda 7,5 pt arriba y abajo; el círculo visible de 44 nunca sale de la barra. Si la barra recorta
   el ítem o el toque [a medir], el Disco pasa a un `.safeAreaInset(edge: .bottom)` propio (`Material.bar` + `Hairline`,
   64 + área segura) en 17/18 y a `ToolbarItemGroup` en 26 dentro del mismo `#available` de A6, no de uno nuevo.
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Cuerpo | — | `grafito` | círculo 44 | Único relieve; nunca color |
| Sombra interior | — | `negro` 60 % | 1 pt (2 pt pulsado) | `.shadow(.inner)` en el relleno |
| Glifo | — | `Ink.primary(phase)` (`texto`; `textoNoche` en la página nocturna) | 22 pt, peso Medium | `.contentTransition(.symbolEffect(.replace))`; `.pulse` solo fundiendo |
| Objetivo | — | — | 64 × 64 | `contentShape(Circle())` |

### 2.5 Pantalla como botón (`FullScreenControl`)

```
 393 × 852, negro, sin barra de estado
 ┌─────────────────────────────────────────┐
 │                                         │  toda la superficie: toque = pausa / reanuda
 │                 3:07                    │  (contenido de E4: hora 72, estado 22, horizonte 2 pt)
 │   ─────────────────────────────────     │
 │            Se funde a las 03:42         │
 │                                         │  ┃  regla vertical 1 pt textoNoche, 200 pt (solo la parte llena:
 │                                         │  ┃  el vacío es negro, como la línea ausente = pausa),
 │                                         │  ┃  x = 373−8 (dentro del margen), solo mientras dura el arrastre
 │                                         │
 │       Seguir por el altavoz             │  y 690-754, 64 pt, paso 4 (20 Medium textoNoche); solo tras pausa
 │                                         │  de auriculares, 60 s; aparece encima, "+15 min" no se mueve
 │              +15 min                    │  y 754-818, 64 pt a todo el ancho, 20 Medium textoNoche, centrado,
 │                                         │  sin borde ni fondo: el objetivo es toda la franja
 └─────────────────────────────────────────┘  (Madrugada: "Parar", 03 §4.5); nunca cambia de sitio ni de significado
 El apilado es de abajo arriba: "+15 min" (754-818) nunca se mueve; lo que aparece lo hace encima.
 "+15 min" solo existe si hay temporizador (Noche nunca crea uno: `extend(by:)` sobre el existente, C47); sin él la franja 754-818 queda vacía;
 cuando Noche ha terminado, la franja la ocupa "Madrugada · 20 min" (`madrugada.estado`), botón de 64 con el mismo paso 4 (C27).
 Controles visibles de noche (Switch Control / AssistiveTouch / ajuste): la fila [ −15 min ] [ pausa ] [ +15 min ]
 de 64 pt SUSTITUYE al botón "+15 min" en y 754-818 (un objetivo menos, misma función); tres palabras separadas
 por 32 pt de aire, sin separador (no existe hairline vertical); "Seguir por el altavoz" sigue en 690-754.
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Superficie | — | `negro` | pantalla completa | Toque, pulsación larga y arrastre comparten la guarda `tapAllowed()`: 300 ms tras `scenePhase == .active` (también en la primera presentación) y nunca boca abajo (`UIDevice.orientation == .faceDown` [a medir]; exige `beginGeneratingDeviceOrientationNotifications`). Un deslizamiento que no fija el eje vertical cuenta como toque |
| Regla de volumen | — | `textoNoche` (solo la parte llena; sin pista vacía) | 1 pt × 200 × volumen, a 8 pt del margen derecho (x = 365) | 150 ms in / 250 ms out; sigue al dedo sin animación; `DragGesture(minimumDistance: 24)` con eje fijado en el primer evento (vertical si `abs(h) > abs(w) × 1,73`); 200 pt = 100 %; es el `master` de sesión con rampa (`EngineCommand.setMaster`), no el volumen del sistema; al soltar, el estado de E4 dice "Sonando · al {n}" 3 s (`estado.volumen`, C51) |
| "+15 min" / "Parar" | 4 | `textoNoche` | 64 pt alto, ancho completo | Botón de texto sin borde; `.numericText()` en la cifra de E4 al tocar; "+15 min" siempre extiende y es libre para todos (temporizador entero libre, C03), pero solo existe si hay temporizador: Noche nunca crea uno (C47); con Noche terminada el botón es "Madrugada · 20 min" (C27) |
| "Madrugada · 20 min" | 4 | `textoNoche` | 64 pt, y 754-818 | Ocupa el hueco del "+15 min" cuando Noche ha terminado (C27); abre Madrugada (intent `SmallHours`, spike I0-3); nunca un gesto oculto |
| "Seguir por el altavoz" | 4 | `textoNoche` | 64 pt, encima (y 690-754) | 60 s (C49), 250 ms de opacidad al entrar y salir; "+15 min" no se mueve; la reanudación va capada a 0,4 solo si la ruta cambió y el estado dice "Sonando · al 40" (`estado.volumen`, C49/C51) |
| Controles visibles | 4 | `textoNoche` | 3 × 64, a 32 pt de aire | Aparecen solos bajo Switch Control o AssistiveTouch (observando `switchControlStatusDidChangeNotification` y `assistiveTouchStatusDidChangeNotification`); opción en Ajustes. Ocupan el sitio de "+15 min" |
| "Volver a la página" | — | — | 1 × 1 pt, opacidad 0,011, primero en el orden | Botón solo para VoiceOver, Switch Control y Control por voz (Noche); `accessibilitySortPriority(2000)`; verificar en dispositivo que no se filtra al tacto |
| Pulsación larga (volver) | — | — | `Grid.longPress` 0,6 s, `maximumDistance` 10 pt | Solo Noche; pasa por `tapAllowed()`; háptica por `MotionGate` |

### 2.6 Acción primaria (`HairlineAction`)

```
 x: 20                                                    373
    ┌──────────────────────────────────────────────────────┐
  0 │ ─────────────────────────────────────────────────────│  hairline trazoHoja (1,5 pt índice si Comprar con precio)
    │                                                      │
 32 │              Comprar · {displayPrice}                │  17 Semibold texto, centrado
    │                                                      │
 64 │ ─────────────────────────────────────────────────────│  hairline
    └──────────────────────────────────────────────────────┘
    Debajo, si StoreKit no responde (paso 8 texto2, 8 pt de aire):
    La tienda no responde. Nada cambia.            (con sonido: "…Nada cambia: sigue sonando.")
    Debajo, si la compra queda pendiente de aprobación (paso 8 texto2):
    Pendiente de aprobación familiar. Se abrirá solo cuando llegue.
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Palabra | 5 | `texto` (`texto2` deshabilitado, cargando precio, en curso y pendiente: 03 §3.1 reserva `texto3` al texto ≥ 18 pt, como anota 10 en `pro.comprar.sin_precio`; §9 #31) | centrada, fila 64 | "Comprando…" / "Buscando…" como texto, sin spinner |
| Hairlines | — | `trazoHoja` (`trazo` sobre negro) / `indice` **1,5 pt** con precio | de margen a margen | Las únicas hairlines de acento de la app; 1,5 pt es el mínimo que 03 §3.1 admite para el índice (03 §4.6 consolidado ya dice 1,5 pt; §9 #16 cerrada) |
| Pulsado | — | opacidad 0,6 | — | 200 ms `.easeInOut` |
| Nota de deshabilitado / pendiente | 8 | `texto2` | bajo la fila | Sin producto de StoreKit (`sys.store.down` / `sys.store.down.playing` según `meter.isProducingAudio`); compra pendiente (`sys.store.pending`) |

### 2.7 Sistema con estilo

- **Fila editorial** (`EditorialRow`): `List` del sistema con `.listStyle(.plain)` (el fondo pulsado queda con radio 0), `listRowInsets` 0/20, `listRowSeparator(.hidden)` y `Hairline` propia; 56 / 72; pulsada `grafito` 200 ms (`listRowBackground` con `.tint`); activa en lista de opciones: `checkmark` del sistema en `texto`; Pro: nombre `texto2` + "pro"; al tocar abre la hoja Pro si `SaleGate` lo permite (C06); de noche nada (C08). Ejemplo del primer uso en la página: "Temporizador · Hasta dormirme · 45 min" (07 manda sobre la maqueta de 05).
- **Palabra de estado** (`StateWord`): `Text` paso 9 versalitas, `texto2`, +2 %; nunca fondo ni color; nunca para datos nocturnos. Al cambiar de estado de sesión emite `AccessibilityNotification.Announcement`.
- **Acción secundaria** (`TextAction`): `Button` `.borderless`, paso 6 `texto2` (Medium de noche), 44 pt (64 de noche). Las acciones de la pantalla Noche ("+15 min", "Parar", "Seguir por el altavoz", controles visibles) no son `TextAction`: son botones de paso 4 y 64 pt (03 §3.4, §3.5).
- **Hoja** (`.systemSheet(detent:)`): `presentationBackground(Ink.sheet)`, `presentationDragIndicator(.visible)`, sin "Cerrar", cabecera paso 3 a 20 pt + `Hairline(.onSheet)`, detents `.medium` (Temporizador) / `.large` (resto). Capas es hoja `.large` **sobre `negro`**, con hairlines `trazo` y la barra inferior debajo (03 §4.10 consolidado: comparte fondo con la página porque hace lo mismo que la página; es la única hoja que no va sobre `hoja`). **La página que presenta la hoja marca `.environment(\.sheetPresented, activeSheet != nil)` sobre sí misma**: el horizonte y la línea de agua, que viven debajo, lo leen; la hoja no se detecta a sí misma.
- **Barra inferior** (`BottomBar`): `ToolbarItemGroup(placement: .bottomBar)` con "Mezclas" · `PlayDisc` · "Noche" en `.step(.bar)` (17 Medium, escala con `.body`) y `foregroundStyle(Ink.text)` explícito (nada hereda `AccentColor`); en AX4-AX5 los dos textos pasan a `square.stack` y `circle.lefthalf.filled` con etiqueta accesible, también en `Ink.text`. Material `.bar` + `Hairline` en 17/18; vidrio en 26 sin código. El tramo de Dynamic Type llega como parámetro desde la vista que construye la barra (`@Environment` en un `ToolbarContent` no está garantizado en 17).
- **Toggle** del sistema con `.tint(Ink.text)` (03 §3.1 regla 2 y §4.12 consolidados: nunca `índice`; se lee por la posición del pomo, P7; §9 #14 cerrada); **Picker/DatePicker/TextField/contextMenu** sin estilo propio; **TipKit** `maxDisplayCount = 1`, `.tipBackground(.clear)`, sin imagen ni flecha, paso 7 `texto2`, `TipViewStyle` propio (`LineTipStyle`).

### 2.8 Galería de referencia (`SystemGallery`, DEBUG)

`Design/SystemGallery.swift`, solo en `#if DEBUG`, accesible desde Ajustes con la build de desarrollo. No es una pantalla de producto; es el instrumento con el que se pasa la puerta de dispositivo (03 §8.3.3) y la que produce las capturas de la checklist (Anexo B). Contiene, en una `List` plana con `EditorialRow` como fila de navegación:

| Sección | Contenido | Lo que comprueba |
|---|---|---|
| Por componente (6) | Cada componente propio en los estados de §3, en una columna, con el nombre del estado en paso 9 versalitas (`.isHeader`) | Maqueta ↔ texto: cada fila de §3 tiene un caso |
| Tramos de Dynamic Type | Cada caso a L, xxxL, AX3 y AX5 (`.environment(\.dynamicTypeSize, …)`), uno debajo de otro | §5d; nada truncado; `ViewThatFits` |
| Fases | Cada componente en `.day`, `.nightPage`, `.night`, `.smallHours` | Ninguna tinta ≠ `textoNoche` ni peso < Medium de noche (prueba de §2.0.4) |
| Apariencia | Conmutador negro / papel (1.1) y High Contrast | Tokens del catálogo; sin hex fuera de §2.0.1 |
| Medidor | Indicador "provisional · hasta I0-1" (`sys.gallery.provisional`, paso 9) mientras `meter.isProvisional`; un `Slider` de desarrollo que fija `target` para ver M1-M3 sin motor | [spike I0-1] |
| Capturas | Botón "Exportar" que escribe PNG de cada caso en gris, en rojo (modelos A y B) y en color, en Large y AX3 | Anexo B, filtro rojo y escala de grises; conteos de §8 del brief |
| Conteos | Por caso: pasos tipográficos usados, colores no grises, rectángulos rellenos | Conteos de §8 del brief |

VoiceOver en la galería: el título de cada caso es `.isHeader`; los componentes se exponen como en producto (§5b). La galería no se localiza (solo ES; sus rótulos no van al String Catalog salvo `sys.gallery.provisional`).

---

## 3. Estados completos

Convención de 03 §4: **normal · activo · bloqueado-Pro (sin castigo) · prueba · deshabilitado · VoiceOver**, más los estados de sesión que cada pieza expresa. "No aplica" es una decisión, no una omisión: el sonido nunca se bloquea.

### 3.1 `SoundLine`

| Estado | Expresión | Señal |
|---|---|---|
| Reposo | Hairline `trazo` quieta. Sin color. | `meter.isProducingAudio == false` |
| Sonando | `indice`; grosor 1,5→3, opacidad 0,6→1,0; nace en 800 ms (= `defaultFadeIn`, §0 (7)) | RMS maestro (provisional: `envelopeTarget × Σ gains`, siguiendo la rampa real `rampSeconds` y después τ 500 ms) [spike I0-1] |
| Sonando con dedo en un nivel | Misma geometría en `texto` | `IndexArbiter.owner == .finger` |
| Pausa | Vuelve a hairline en 1,5 s con la ganancia suavizada (la rampa de `pause`, §0 (7)); después reposo. `isProducingAudio` se calcula sobre el valor suavizado, no sobre el objetivo, para que la bajada se vea entera | `envelopeTarget → 0` |
| Fundiendo | Baja con la ganancia real; el glifo del Disco pulsa | `SleepTimerController.isFading` |
| Marea | La banda (120, reservada) es `TideLine`; `SoundLine` no se dibuja | `BreathingGuideController.phase != .idle` |
| Pulsación larga (0,6 s) | n líneas por capa superpuestas en la banda, `texto`, aparecen en 400 ms | `meter.perLayer` |
| Noche / Madrugada | 2 pt `textoNoche`, continua / ausente; `TimelineView` pausado | `isPlaying` |
| Página nocturna | `textoNoche` 1→3 pt por RMS, siempre; nunca índice (el `indiceNoche` lo lleva solo la línea de nivel bajo el dedo; pasa a Noche al bloquear o, si el ajuste "Pasar sola a Noche" lo dice, a 1 / 3 min, §4.1) | fase `.nightPage` |
| Fondo / hoja encima / convergido | Congelado a hairline en ≤ 2 s, luego pausado; también pausado cuando `|master − target| < 0,001` (con el valor provisional la línea solo cambia en eventos) | `scenePhase`, `sheetPresented` (lo marca la página, §2.7), `meter` |
| Error de audio | Hairline; la línea de estado de E2 dice el error (es botón) | `audioError != nil` |
| Pro / prueba / deshabilitado / vacío / cargando / sin red | No aplica | — |
| VoiceOver | Elemento de estado "Sonido" + valor "Sonando, nivel medio" / "En silencio" con histéresis de 3 s; acción "Ver capas por separado"; sin `AXChartDescriptor` ni rotor Audio Graph (C63) | — |

### 3.2 `LevelRule`

| Estado | Nombre | Línea | Valor | Toque | Arrastre |
|---|---|---|---|---|---|
| Normal, nivel > 0 | `texto` | 2 pt `texto` × nivel + 1 pt `texto3` | "65" paso 9 | nada | relativo, min 8 pt, eje 30° [spike I0-2, C52] |
| Normal, nivel 0 | `texto` | 1 pt `texto3` | oculto | nada | igual (enciende desde 0; `.selection` al cruzar) |
| Activo (dedo) | `texto` | 3 pt `indice` | "65" 17 pt `texto`, en su sitio | — | el horizonte pasa a `texto` |
| Pulsación larga (0,6 s, ≤ 10 pt) | igual | igual | igual | — | `Slider` del sistema de 44 pt en el sitio de la línea, en `texto`; se retira a los 5 s sin dedo encima o al tocar fuera; nada más (el timbre no es un gesto: es la fila Timbre, C29) |
| Bloqueado-Pro sin acceso | `texto2` | 1 pt `texto3` completa | "pro" / "pro · 30" versalitas | abre la hoja Pro ("Empezar la prueba · 7 noches" / "Comprar · {displayPrice}") si `SaleGate` lo permite (C06); de noche (21:00–07:00, `NightWindow`, o fase nocturna) o con la app fuera de `.active` no pasa nada (C08); sin límite de veces; sin escucha de 30 s en 1.0 (1.1). El nivel guardado se conserva: el motor lo ignora y la degradación nunca escribe (C23). VoiceOver: sin acciones de nivel | no mueve nada |
| Prueba | idéntico a Normal | | | | |
| Deshabilitado | no existe | | | | |
| Noche / página nocturna | `textoNoche` | `textoNoche` + `texto3`; bajo el dedo `indiceNoche` 3 pt | `textoNoche` | igual | 16 pt y cono de 20°; cede al scroll (§2.2) |
| Papel (1.1) | `tinta` | `tinta` + `tinta3`; dedo `ocre` | `tinta2` | igual | igual |
| Fila Timbre (C29) | "Timbre" | igual | "Grave" / "Lejos" en los extremos (versalitas) | nada | igual; sobre el bus maestro [spike I0-7] |
| Button Shapes | igual | igual | valor subrayado (`.underline`) | igual | el `Slider` sigue bajo pulsación larga y acción de VoiceOver; nunca permanente |
| VoiceOver | `.adjustable`, pasos 5 %; acciones "Silenciar", "Máximo", "Ajuste con deslizador" solo si la capa está incluida; Pro: botón "requiere Pro" + pista "Toca dos veces para ver Pro." y acción "Ver Pro" de día; de noche sin pista, sin acción y sin rasgo de botón (C06, C08) | | | | |

### 3.3 `TideLine`

| Estado | Línea | Palabra | Otro |
|---|---|---|---|
| Apagada | No se dibuja; el horizonte ocupa su sitio | — | Toggle off en la fila |
| Guiando | 2 pt `indice` (principal) / `texto` (hoja), `BreathCurve` | "inhala"/"exhala" 3 resp.; "guiando · 6 por minuto"; "Se retira a las 23:27" | En la hoja es control: arrastre = ritmo |
| Pro sin acceso | No se dibuja | — | El toggle abre la hoja Pro sin guiar (C06); de noche no abre nada (C08); si compra, la Marea arranca al activarla |
| Disolviendo | Amplitud → 0 con `guide.scheduledWeight(now:)` durante `max(30 s, 20 %)` de la guía (§0 (9)) | "disolviendo" | 2 s en bajamar; vuelve a ser horizonte (las marcas se van con opacidad; la banda no cambia); nota 10 s "Se ha retirado. El mar sigue." |
| Apagada a mano | Disolución de 30 s (`release(over: 30)`, §0 (9)) | "disolviendo" | Nunca un corte |
| Pausa | Congelada donde está | "en pausa" | Al reanudar, retoma desde el inicio de una inhalación (`begin` crea época nueva) |
| Reduce Motion | Posición fija a media banda; opacidad 0,6→1,0 con la misma curva | igual | — |
| Noche | No se dibuja | — | La guía está en el oído / la mano |
| Madrugada | 1,5 pt `textoNoche`; marcas en `trazo` | — | Para todos, sin Pro: receta fija a 8 por minuto, sin control, se retira hacia el minuto 13 (C05) |
| Fondo / hoja encima / 20 min | Quieta en bajamar | — | Pausada (`scenePhase`, `sheetPresented`, `windowClosed` a los 20 min como el `BreathIndicator` actual) |
| Prueba | Normal | | |
| Deshabilitado | No existe | | |
| VoiceOver | "Marea, inhala, seis por minuto, se retira en doce minutos"; `.adjustable` (ritmo) en la hoja | | |

### 3.4 `PlayDisc`

| Estado | Glifo | Relieve | Otro |
|---|---|---|---|
| Normal (reposo) | `play.fill` | 1 pt | — |
| Activo (sonando) | `pause.fill` | 1 pt | `.replace` 200 ms |
| Pulsado | igual | 2 pt, 200 ms | háptica al soltar |
| Fundiendo | `pause.fill` + `.pulse` | 1 pt | `.pulse` apagado con Reduce Motion |
| Error de audio | `play.fill` tras 200 ms en `pause.fill` | 1 pt | la línea de estado (E2) es el botón de reintento |
| Pro / prueba | idéntico | | Nada bloquea el sonido |
| Deshabilitado | nunca | | |
| Noche / Madrugada | no existe | | La pantalla es el botón |
| Página nocturna | glifo en `textoNoche` (`Ink.primary(phase)`) | 1 pt | De noche una tinta |
| Mezcla toda Pro sin acceso | `play.fill` → suena Rosa a 40 y lo dice (E2) | | El instrumento siempre suena |
| iOS 26 | igual | vidrio del sistema (la barra envuelve el ítem; `PrimaryActionStyle` devuelve la etiqueta sin relieve) | único `#available` |
| Háptica | play `.impact(.medium, 0.7)` / pausa `.impact(.light, 0.5)` | | Solo con `MotionGate` (de noche nunca; hasta I0-5, "en la mano" = fase de día) |
| VoiceOver | "Reproducir" / "Pausar", `.startsMediaSession`; Magic Tap lo declara la raíz de la página (E2), no el Disco; orden en §5b | | |

### 3.5 `FullScreenControl`

| Estado | Expresión |
|---|---|
| Sonando | Toque = pausa (fundido 1,5 s). Sin háptica. "+15 min" siempre extiende y es libre (C03); solo existe si hay temporizador: Noche nunca crea uno (C47). |
| Sin temporizador | El hueco de "+15 min" está vacío; la pantalla sigue siendo el botón (C47). |
| Noche terminada | El hueco lo ocupa "Madrugada · 20 min" (C27); nada más cambia. |
| En pausa | Toque = reanuda (800 ms). La causa va en el texto de E4 ("En pausa · llamada"). |
| Tras `scenePhase == .active` (< 300 ms) | Toque, pulsación larga y arrastre ignorados (`tapAllowed()`); también en la primera presentación. |
| Boca abajo | Ignorados (`UIDevice.orientation == .faceDown`; exige `beginGeneratingDeviceOrientationNotifications` en `onAppear`) [a medir]. |
| Arrastrando | 24 pt y eje vertical fijado en el primer evento; regla vertical visible; volumen maestro sigue al dedo (200 pt = 100 %). Un deslizamiento horizontal o corto cuenta como toque al soltar. |
| Pulsación larga 0,6 s (≤ 10 pt) | Noche: vuelve a la página (`.impact(.light, 0.4)` solo por `MotionGate`). Madrugada: nada. |
| Pausa de auriculares (caída de ruta: 40 ms + pausa, C49) | "Seguir por el altavoz" (paso 4, 64 pt) 60 s encima de "+15 min"; nunca reanuda sola por el altavoz; el toque reanuda capado a 0,4 solo si la ruta cambió. |
| Fundiendo | El contenido de E4 lo dice; el gesto no cambia. |
| Sin sonido (error) | "Sin sonido" en `textoNoche` (E4); toque = reintentar. |
| Switch Control / AssistiveTouch | "Controles visibles de noche" aparecen solos (observando las notificaciones de estado); la fila sustituye a "+15 min". |
| Acceso asistido (1.1, C39) | Disposición de un botón: la pantalla entera; sin "volver". |
| Pro / prueba / deshabilitado | No aplica. |
| VoiceOver | Contenedor (`children: .contain`): primero el botón "Volver a la página" (solo Noche), después la superficie como elemento `.button` con valor (hora, estado, tiempo) y acciones "Quince minutos más" (solo si hay temporizador) y "Volumen" (el propio elemento es `.adjustable` ±5 %), después "Seguir por el altavoz" y "+15 min" / "Parar" como botones hermanos; escape en Z; Magic Tap en la raíz. |

### 3.6 `HairlineAction`

| Estado | Palabra | Hairlines | Debajo |
|---|---|---|---|
| Normal | `texto` | `trazoHoja` | — |
| Comprar con precio cargado | "Comprar · {displayPrice}" `texto` | 1,5 pt `indice` | — |
| Cargando precio | "Comprar" `texto2` (`pro.comprar.sin_precio`); **no responde al toque** (`.disabled`) | `trazoHoja` | — (hasta 8 s). VoiceOver: "Comprar {displayName}", valor "precio no disponible" (`sys.action.buy.loading.label`, `.value`) |
| Sin red / sin producto | "Comprar" `texto2` | `trazoHoja` | "La tienda no responde. Nada cambia." (`sys.store.down`); con sonido, "…Nada cambia: sigue sonando." (`sys.store.down.playing`, elegida por `meter.isProducingAudio`) |
| En curso | "Comprando…" / "Buscando…" `texto2` | `trazoHoja` | — |
| Pulsado | opacidad 0,6, 200 ms | | |
| Éxito | la fila entera pasa a "Gracias. Todo abierto." `texto` 1,5 s | `trazoHoja` | `.success` |
| Cancelación del usuario | sin cambio: la fila vuelve a Normal | `indice` 1,5 pt (sigue habiendo precio) | sin nota, sin háptica |
| Pendiente de aprobación (Pedir para comprar / SCA) | "Comprar · {displayPrice}" `texto2`; deshabilitada | `trazoHoja` | "Pendiente de aprobación familiar. Se abrirá solo cuando llegue." paso 8 `texto2` (`sys.store.pending`); sin háptica |
| Fallo | sin cambio | | "No se ha podido completar. No se ha cobrado nada." paso 8 `texto2`; `.error` solo con la hoja delante |
| Pro / prueba | no aplica (el primario nunca está bloqueado) | | |
| Button Shapes | subrayado del sistema | | |
| VoiceOver | "Comprar {displayName}, {displayPrice}, botón. Un solo pago. Abre la confirmación de App Store." (`ax.comprar` + `ax.comprar.pista` de 10; la moneda la lee VoiceOver; nunca una cifra ni un nombre escritos a mano, C12) | | |

### 3.7 Sistema con estilo

- `EditorialRow`: normal / pulsada (`grafito` 200 ms) / activa (`checkmark`) / Pro ("pro" en versalitas; al tocar abre la hoja Pro si `SaleGate` lo permite; de noche nada, C06/C08) / deshabilitada (solo si ≥ 18 pt en `texto3`; si no, se oculta) / VoiceOver (un elemento con valor).
- `StateWord`: aparece / no aparece. Nunca anima su posición; cambia de contenido con opacidad 250 ms.
- `TextAction`: normal / pulsada (opacidad 0,6) / Button Shapes (contorno del sistema).
- Hoja: presentada / cerrándose (sistema). `SoundLine` y `TideLine` se congelan (hairline / bajamar) cuando una hoja está delante: la página que la presenta pone `sheetPresented` en su propio entorno (§2.7); `SystemSheet` no lo hace.
- Tip: visible una vez / nunca más. Ningún tip 21:00–07:00 (`NightWindow`, C40) (salvo las dos frases de Noche, que no son tips) ni durante la Marea.

---

## 4. Flujos y patrones

### 4.1 Entrar y salir de Noche

**Entradas** (todas con 2 s de opacidad; 250 ms con Reduce Motion): "Noche" en la barra; bloqueo del iPhone mientras suena (entrada por defecto, C47); 1 o 3 min sin tocar mientras suena, solo si el ajuste "Pasar sola a Noche" (Al bloquear / 1 min / 3 min / Nunca) lo dice y solo desde la página (también la nocturna). Noche nunca crea un temporizador (`extend(by:)` solo sobre uno existente) y duerme por defecto (`isIdleTimerDisabled = false`; ajuste "Mantener encendida": mientras carga (defecto) / siempre / nunca, según `batteryState`); se atenúa a los 60 s mientras está encendida y "atenuada" no es un estado (C46, C47). El Focus de Sueño **no** es entrada en 1.0: no hay API para leerlo salvo un Focus filter (`SetFocusFilterIntent`), que 03 §6 deja para 1.1. **Nunca** con una hoja abierta ni sin sonido. Mecanismo: `NightPhase` pasa a `.night`; **no se usa `fullScreenCover`** (siempre entra deslizando desde abajo en 17/18, y `Transaction.disablesAnimations` mataría también la opacidad): en la raíz de E2, `ZStack { page; if phase.isNightScreen { FullScreenControl(…).transition(.opacity) } }.animation(.easeInOut(duration: reduceMotion ? 0.25 : 2), value: phase)` y `.statusBarHidden(phase.isNightScreen)`; así M20 es exactamente la opacidad de las tintas; `SoundLine` pausa su `TimelineView` antes del primer fotograma de Noche.

**Salidas**: pulsación larga 0,6 s (háptica `.impact(.light, 0.4)` por `MotionGate`); "Volver a la página" (botón de 1 × 1 pt visible solo para VoiceOver, Switch Control y Control por voz, primero en el orden); escape en Z; Control por voz "Volver a la página". Al volver de Noche la página entra en fase `.nightPage` por procedencia, a cualquier hora (una tinta, `textoNoche`; `indiceNoche` solo bajo el dedo), dura toda la sesión y solo sale de ella al tocar el nombre de la mezcla: sin salida por reloj (03 §3.2, C40). Nunca vuelve sola a Día de noche.

**Interrupciones dentro de Noche**: llamada (`CXCallObserver`) → pausa 300 ms, "En pausa · llamada" (E4), y nunca termina la sesión fuera de la ventana de la mañana; AirPods fuera (caída de ruta) → 40 ms de audio + pausa y 2 s en la interfaz (M3, C49), "Seguir por el altavoz" 60 s, reanudación capada a 0,4 solo si la ruta cambió; `pauseCommand` con auriculares → fundido de 3 s; regla única de interrupciones (C48, igual en todos los modos): dentro de la ventana de la mañana (05:00–11:00, o fin de Manto −60 min si hay Manto) ninguna interrupción reanuda y la sesión termina (es el detector de la alarma del sistema); fuera de ella toda interrupción reanuda con fundido de 3 s; 20 min en pausa → la sesión termina y la Live Activity (solo escenario A, C25) ofrece "Madrugada · 20 min", condicionado al spike I0-3 (E6). Mecanismo de los 20 min: el proceso no está vivo (al pausar, `stop` desactiva la sesión de audio y el sistema suspende la app en segundos), así que al pausar se hace `Activity.update(ActivityContent(state:, staleDate: now + 20 min))` y la vista de E6 dibuja "madrugada · 20 min" cuando `context.isStale`; ningún timer del modelo. La guarda de 300 ms se rearma en cada `scenePhase == .active` y en la primera presentación.

### 4.2 Pro sin castigo (sin candados, sin escucha)

1. La cosa existe, se ve entera y se toca: fila de capa Pro ("pro" / "pro · 30" en versalitas), toggle de Marea, "Guardar como mezcla…" a partir de la cuarta mezcla propia (`freeSavedMixLimit` 1 → 3; sin límite con Pro). Nada en el temporizador: es entero libre (C03) y **"+15 min" en Noche, en la Live Activity y en Madrugada extiende para todos, sin hoja ni nota**, siempre que exista un temporizador (Noche nunca crea uno, C47).
2. Al tocar, **si `SaleGate.allows(now:phase:scene:)` lo permite**, sube la hoja Pro con el precio en la primera línea y la acción primaria "Empezar la prueba · 7 noches" (si la prueba no se ha usado) o "Comprar · {displayPrice}" (C06, C07). Nada suena antes: la escucha de 30 s no existe en 1.0 (pasa a 1.1 y, cuando llegue, no abrirá hoja sola). `SaleGate` (A12, junto a `TipGate`) devuelve falso dentro de `NightWindow` (21:00–07:00), en cualquier fase nocturna (`.nightPage`, `.night`, `.smallHours`) y con `scenePhase != .active`: entonces **no pasa nada** (la fila sigue diciendo "pro") y no hay cola ni línea matinal: `showPaywall` se consume sin efecto (C08). Si el toque llega en mitad de un arrastre, la hoja espera a que suelte. Es la hoja que §4.4 permite: la consecuencia del toque en la fila Pro, anunciada por su pista ("Toca dos veces para ver Pro.").
3. La prueba se dispara solo desde esa hoja (`startTrial()`; `startTrialIfNeeded()` sale de `play()`), nunca con Play; su estado vive en Keychain y la versalita "prueba · quedan n noches" aparece en la cabecera desde que empieza (C07). Madrugada nunca abre la hoja Pro (C05).
4. Si compra: fundido de entrada de 800 ms en el instante de comprar (la compra se oye); la versalita "pro" desaparece y el nivel guardado vuelve a dibujarse; si la Marea estaba pedida, arranca.
5. Si no: todo como antes. Sin límite de veces. Sin notificación, sin cuenta atrás, sin candado, sin opacidad.
6. La prueba se evalúa solo al arrancar una sesión (`refreshAccess(canDowngrade:)`); nunca a medianoche ni al reanudar. La degradación tras la prueba conserva el nivel de cada capa Pro ("pro · N"), el motor la ignora sin acceso y **nada se escribe en disco** (`endPlayback` no toca `SavedMix`; C23): comprar después devuelve la mezcla entera. Guardar una mezcla con capas Pro sin acceso conserva el nivel sin diálogo.

### 4.3 Permiso en el momento de uso

Ningún permiso al arrancar. Salud (Marea, **2.0**, C34; en 1.0 el ritmo de partida es un parámetro, "Empezar a 12 por minuto") se pediría al elegir "Mi ritmo nocturno", con el texto de E7; si se niega, la fila dice "valor por defecto" y no vuelve a pedirse. Micrófono: fuera de alcance. CoreMotion: fuera de producción en 1.0 (C35). Notificaciones: nunca. La Live Activity no pide permiso. Patrón en código: `PermissionRow` es una `EditorialRow` cuya acción pide el permiso y cuyo valor refleja la respuesta; nunca una hoja previa que explique el permiso (la explicación es el `NSHealthShareUsageDescription`).

### 4.4 Hoja

Siempre tras un toque (P9); nunca sola (la hoja Pro es consecuencia del toque en la fila Pro y su pista lo anuncia; de noche no sube, §4.2). `.systemSheet(detent:)`: fondo `hoja`, indicador real, sin "Cerrar", cabecera paso 3 a la izquierda a 20 pt y `Hairline(.onSheet)`; contenido sobre `hoja` usa `trazoHoja`. Al presentarse, **la página marca `.environment(\.sheetPresented, true)` sobre sí misma** (responsabilidad de E2-E5: el componente no detecta la hoja), `SoundLine` y `TideLine` se congelan y el índice de la página cede (las hairlines de "Comprar" con precio son la excepción por regla, fuera del árbitro). Se cierra con el gesto del sistema, el indicador, el escape en Z y Control por voz "Cerrar" en todas las versiones (iOS 26 no añade un botón de cierre por sí solo; `Button(role: .close)` exigiría un segundo `#available` y no se usa). La barra inferior sigue debajo (el Disco siempre está).

### 4.5 Tip

`LineTipStyle`: una línea paso 7 `texto2`, sin fondo, imagen ni flecha, 250 ms, bajo el control que explica; `maxDisplayCount = 1`; reglas de hora y de Marea en `TipGate` (entorno). Tips de 1.0: el del segundo arrastre ("Arrastra sobre el nombre para cambiar el nivel."), solo de día, y nada más (lista cerrada, C65); las dos frases de la primera Noche no son tips (las dibuja E4).

### 4.6 Entradas, salidas e interrupciones por componente

| Componente | Entra | Sale | Interrupción |
|---|---|---|---|
| `SoundLine` | con la página; nace de la hairline al arrancar | con la página; a hairline al parar | hoja encima, fondo, Noche → hairline ≤ 2 s |
| `LevelRule` | con la fila | — | si el motor para en mitad del gesto, el gesto sigue (el nivel se guarda); si llega una llamada, el gesto se cancela sin cambiar el valor |
| `TideLine` | toggle / Madrugada | disolución (nunca corte) | pausa → congelada; reanudar → nueva época |
| `PlayDisc` | con la barra | — | error → vuelve a play en 200 ms |
| `FullScreenControl` | 4.1 | 4.1 | 4.1 |
| `HairlineAction` | con la hoja | con la hoja | StoreKit sin producto → deshabilitado con nota |

---

## 5. Las cinco tablas obligatorias

### 5a. Movimiento: elemento → señal del motor → duración / curva → Reduce Motion → Noche / fondo / hoja

Lo que no está aquí no se mueve. Nada cambia de posición ni de tamaño. Curvas: `.easeInOut`, `.easeOut`, `BreathCurve` (la del motor). `isLuminanceReduced` no existe dentro de la app en iPhone (Always-On muestra el bloqueo y la Live Activity, nunca la app, que ya está en `.background`): solo lo leen las vistas de WidgetKit (E6); aquí la columna es "Noche / fondo / hoja".

| # | Elemento | Señal del motor | Duración / curva | Reduce Motion | Noche / fondo / hoja |
|---|---|---|---|---|---|
| M1 | `SoundLine`: hairline → línea de índice | `envelopeTarget` 0 → 1 (arranque, rampa `defaultFadeIn` 0,8 s, §0 (7)) | 800 ms `.easeOut` (la rampa real; el medidor la sigue) | igual (es grosor y opacidad) | no arranca: hairline |
| M2 | `SoundLine`: grosor 1,5→3, opacidad 0,6→1,0 | RMS maestro, τ 500 ms, evaluado en el `TimelineView` (`master(at: ctx.date)`) [spike I0-1: provisional `envelopeTarget × Σ gains`] | continua, lectura del motor | `minimumInterval` 0,25 s, τ 1,5 s | congelada a hairline ≤ 2 s; `TimelineView` pausado; también pausado cuando el valor ha convergido |
| M3 | `SoundLine`: línea → hairline | ganancia → 0 (pausa 1,5 s, §0 (7); fin fundido; llamada) | la rampa real: 1,5 s pausa; llamada 300 ms; caída de ruta (AirPods fuera) 40 ms de audio + pausa, 2 s UI; `pauseCommand` con auriculares 3 s (C49) | igual | igual |
| M4 | `SoundLine`: índice ↔ `texto` al entrar/salir un dedo | `IndexArbiter.owner` | 200 ms opacidad cruzada | igual | n/a |
| M5 | `SoundLine`: descomposición en n líneas superpuestas en la banda | pulsación larga 0,6 s; `meter.perLayer` | 400 ms opacidad; la banda no cambia de tamaño | igual | n/a |
| M6 | `LevelRule`: 2→3 pt, `texto`→`indice`, pista `grafito`, valor 13→17 pt | dedo sobre la fila | 150 ms in / 250 ms out `.easeInOut` | igual (sigue al dedo; sin posición) | n/a |
| M7 | `LevelRule`: longitud de la línea | dedo (delta) | 0, directo | igual | n/a |
| M8 | `LevelRule`: el `Slider` del sistema sustituye a la línea en su sitio | pulsación larga | 250 ms opacidad; nada crece ni se mueve; se retira a los 5 s | fundido | n/a |
| M9 | [retirada por C06] sin escucha de 30 s en 1.0 | — | — | — | — |
| M10 | `TideLine`: aparecen las marcas y la línea de agua | `BreathingGuideController.begin` | 800 ms opacidad; la banda (120, reservada) no cambia de tamaño; nada baja | 250 ms opacidad | n/a |
| M11 | `TideLine`: sube / baja | `BreathCurve.value(secondsSinceStart:parameters:)`, ancla `guide.anchor + outputLatency`, amplitud × `scheduledWeight` | continua, 30 Hz pausable; se pausa sola a los 20 min (`windowClosed`) | posición fija a media banda; opacidad 0,6→1,0 misma curva | quieta en bajamar con hoja encima o en fondo; Noche no se dibuja; Madrugada 1,5 pt |
| M12 | `TideLine`: "inhala" / "exhala" | fase de la curva (p < inhale) | 250 ms opacidad; desaparece tras la 3.ª exhalación en 500 ms | igual | n/a |
| M13 | `TideLine`: amplitud → 0 (disolución) | `scheduledWeight(now:) → 0` | `max(30 s, 20 %)` de la guía (o 30 s a mano), lineal sobre la amplitud (§0 (9)) | opacidad → 0,6 | n/a |
| M14 | `TideLine`: arrastre de ritmo en la hoja | dedo; `settingsDidChange` rebasa el ancla | 0 directo; se aplica al siguiente ciclo | igual | n/a |
| M15 | `PlayDisc`: play ↔ pause | `isPlaying` | 200 ms `.symbolEffect(.replace)` | igual (es fundido) | Live Activity: cambio seco en la siguiente actualización |
| M16 | `PlayDisc`: sombra 1→2 pt | pulsación | 200 ms `.easeInOut` | igual | n/a |
| M17 | `PlayDisc`: `.pulse` del glifo | `isFading` | sistema | apagado | n/a |
| M18 | `FullScreenControl`: regla de volumen aparece / sigue / desaparece | dedo (24 pt, eje vertical) | 150 / 0 / 250 ms | igual | — |
| M19 | `FullScreenControl` → página (fase) | pulsación larga 0,6 s | 250 ms opacidad en todas las tintas | igual | — |
| M20 | Página → Noche (fase) | bloqueo / "Noche" / 60 s | 2 s opacidad (`ZStack` + `.transition(.opacity)`, nunca `fullScreenCover`) | 250 ms | — |
| M21 | Página nocturna → Día | toque en el nombre (nunca por reloj, C40) | 2 s opacidad | 250 ms | — |
| M22 | `HairlineAction`: hairlines `trazoHoja` → `indice` 1,5 pt | StoreKit devuelve el precio | 250 ms opacidad | igual | n/a |
| M23 | `HairlineAction`: pulsado | toque | opacidad 0,6, 200 ms | igual | n/a |
| M24 | `HairlineAction`: texto "Comprar" → "Comprando…" → "Gracias. Todo abierto." / nota "Pendiente de aprobación…" | StoreKit | 250 ms opacidad por cambio; 1,5 s visible | igual | n/a |
| M25 | `EditorialRow` pulsada: fondo `grafito` | toque | 200 ms | igual | — |
| M26 | `StateWord`: cambio de contenido | estado | 250 ms opacidad | igual | — |
| M27 | Tip: aparece / desaparece | `TipGate` | 250 ms opacidad; 6 s | igual | nunca de noche |
| M28 | Hojas y navegación | sistema | sistema | sistema | — |
| M29 | "Seguir por el altavoz": aparece / desaparece | pausa de auriculares (ruta de audio) | 250 ms opacidad; 60 s; nunca mueve "+15 min" | igual | solo en Noche |
| M30 | "Controles visibles de noche": aparecen / desaparecen | Switch Control / AssistiveTouch / ajuste | 250 ms opacidad, con la fase; ocupan el sitio de "+15 min" | igual | solo en Noche |
| M31 | [retirada por C08] sin cabecera matinal | — | — | — | — |
| M32 | [retirada por C06] | — | — | — | — |
| M33 | `FullScreenControl`: "Madrugada · 20 min" ocupa el hueco del "+15 min" | Noche terminada (fin del temporizador) | 250 ms opacidad; nada se mueve | igual | solo en Noche |

Límites: ninguna finita > 2 s; ninguna infinita salvo M2 y M11 (son el sonido); 0 fotogramas con la pantalla apagada (`TimelineView` pausado por `scenePhase`, `isProducingAudio`, convergencia, `sheetPresented`, fase; el único reloj de la interfaz es el `TimelineView`: no hay `Timer` en `SoundMeter`); ningún píxel cambia de luminancia > 3 veces/s (τ ≥ 300 ms en M2, M11 ≥ 7,5 s por ciclo); interfaz ≤ 30 % del coste del motor con pantalla encendida.

### 5b. VoiceOver por control

| Control | Etiqueta ES [EN] | Valor | Pista ES [EN] | Rasgos | Acciones personalizadas |
|---|---|---|---|---|---|
| `PlayDisc` | "Reproducir" / "Pausar" ["Play" / "Pause"] | — | — (sin pista: el rasgo ya lo dice) | `.isButton`, `.startsMediaSession` | Magic Tap desde cualquier foco: lo declara la raíz de la página (`.accessibilityAction(.magicTap) { model.togglePlayback() }`, E2), no el Disco |
| `SoundLine` | "Sonido" ["Sound"] | "Sonando, nivel medio" / "Sonando, nivel bajo" / "Sonando, nivel alto" / "En silencio" ["Playing, medium level" …/ "Silent"] | — | `.isImage`, `.updatesFrequently` | "Ver capas por separado" ["Show layers separately"] (`onToggleLayers`); sin rotor Audio Graph ni `AXChartDescriptor` (C63); el valor cambia con histéresis de 3 s |
| `LevelRule` | "{Capa}, {subtítulo}" ["{Layer}, {subtitle}"] | "{n} por ciento" ["{n} percent"] (clave `a11y.percentFormat` ya existente) | "Desliza arriba o abajo para ajustar." ["Swipe up or down to adjust."] | `.adjustable`, pasos del 5 % | "Silenciar" ["Mute"], "Máximo" ["Maximum"], "Ajuste con deslizador" ["Adjust with slider"]; el `Slider` desplegado lleva la etiqueta de la capa |
| `LevelRule` Pro sin acceso | "{Capa}, {subtítulo}, requiere Pro" ["…, requires Pro"] | "en silencio" / "en silencio, nivel guardado {n}" ["silent" / "silent, saved level {n}"] | "Toca dos veces para ver Pro." ["Double-tap to see Pro."] solo de día; de noche sin pista (C06, C08) | `.isButton` de día; de noche solo `.isStaticText` | "Ver Pro" ["See Pro"] de día; ninguna acción de nivel (la capa no suena) |
| `TideLine` (principal) | "Marea" ["Tide"] | "Inhala, seis por minuto, se retira en doce minutos" ["Breathe in, six per minute, recedes in twelve minutes"] (`sys.tide.value`; minutos desde `guide.guideEndsAt`) | — | `.isImage`, `.updatesFrequently` | anuncios "inhala"/"exhala" si el ajuste de voz está activo |
| `TideLine` (hoja, control) | "Ritmo" ["Pace"] (`marea.ritmo.fila`; "Ritmo de la Marea" pendiente de E7, §9 #26) | "seis por minuto" ["six per minute"] | "Desliza arriba o abajo para cambiar el ritmo." ["Swipe up or down to change the pace."] | `.adjustable`, paso 1 | — |
| `FullScreenControl` (Noche), contenedor `.contain` | — | — | — | orden: "Volver a la página" → superficie → "Seguir por el altavoz" → "+15 min" (o "Madrugada · 20 min" con Noche terminada, o la fila de controles visibles; nada si no hay temporizador) | escape en Z = volver |
| Superficie (Noche) | "Pantalla de noche" ["Night screen"] | "{hora}. {estado}" (`sys.night.value` = `ax.noche.valor` de 10): la palabra de estado de E4 ya lleva el tiempo ("Sonando. Se funde a las tres y cuarenta y dos." / Manto: "Sonando. Hasta las siete." / "En pausa.") | "Toca dos veces para pausar. Mantén para volver." ["Double-tap to pause. Hold to go back."]; con "Sin sonido": "Toca dos veces para reintentar." | `.isButton`, `.adjustable` (volumen ±5 %, valor "{n} por ciento" hablado al ajustar); `.allowsDirectInteraction` no | "Quince minutos más" ["Fifteen more minutes"] (solo si hay temporizador), "Volumen" ["Volume"] (anuncia el valor; el ajustable es la propia superficie), "Volver a la página" ["Back to the page"] |
| Superficie (Madrugada) | "Madrugada" ["Small hours"] | "Quedan {n} minutos. Sonando" (`sys.smallHours.value` = `ax.madrugada.valor`); los últimos 5 min "Se retira, quedan {n} minutos" (`sys.smallHours.receding`) | "Toca dos veces para pausar." | `.isButton`, `.adjustable` | "Parar" ["Stop"], "Volumen" |
| "Volver a la página" (Noche) | "Volver a la página" ["Back to the page"] | — | — | `.isButton`; 1 × 1 pt, opacidad 0,011; primero en el orden (`sortPriority 2000`); visible para VoiceOver, Switch Control y Control por voz | tras volver, anuncio "Página" (`sys.a11y.page`) |
| "+15 min" | "Quince minutos más" ["Fifteen more minutes"] | — | — | `.isButton` (hermano de la superficie) | tras tocar, anuncio "Quedan {n} minutos" ["{n} minutes left"] |
| "−15 min" (controles visibles) | "Quince minutos menos" ["Fifteen minutes less"] | — | — | `.isButton` | — |
| "pausa" (controles visibles) | "Pausar" / "Reproducir" (`sys.pause` / `sys.play`) | — | — | `.isButton` | — |
| "Seguir por el altavoz" | "Seguir por el altavoz" ["Keep playing on speaker"] | — | "El volumen baja al cuarenta." ["The volume drops to forty."] | `.isButton` | — |
| `HairlineAction` Comprar | "Comprar {displayName}, {displayPrice}" ["Buy {displayName}, {displayPrice}"] (`ax.comprar`; VoiceOver lee la moneda) | — | "Un solo pago. Abre la confirmación de App Store." ["One payment. Opens the App Store confirmation."] | `.isButton` | — |
| `HairlineAction` cargando precio | "Comprar {displayName}" ["Buy {displayName}"] | "precio no disponible" ["price unavailable"] | — | `.isButton`, `.isNotEnabled` | — |
| `HairlineAction` otras | la palabra | — | — | `.isButton` | — |
| `HairlineAction` deshabilitada | la palabra + "no disponible" (sistema) | — | "La tienda no responde. Nada cambia." / "…: sigue sonando." (la nota resuelta) | `.isButton`, `.isNotEnabled` | — |
| `HairlineAction` pendiente | "Comprar {displayName}, {displayPrice}" + "no disponible" (sistema) | — | "Pendiente de aprobación familiar. Se abrirá solo cuando llegue." | `.isButton`, `.isNotEnabled` | — |
| `TextAction` | la palabra | — | — | `.isButton` | — |
| `StateWord` | el texto tal cual | — | — | `.isStaticText`; forma parte del elemento al que acompaña | `AccessibilityNotification.Announcement` al cambiar de estado de sesión |
| `EditorialRow` | nombre + subtítulo | valor | — | `.isButton` (o `Toggle` del sistema) | las que E2-E5 definan |
| Toggle Marea | "Marea" ["Tide"] (`marea.titulo`, antes `breath.title`; C15) | "Guiando, seis por minuto, se retira a las 23:27" / "Desactivada" / "Desactivada, requiere Pro" (`sys.tide.toggle.on` / `.off` / `.off.pro` = `ax.marea.*`) | con acceso y en silencio: "Toca dos veces para encenderla; el sonido arranca."; sin acceso, de día: "Toca dos veces para ver Pro." | `Toggle` del sistema, `.tint(texto)` | sin acceso: al activarlo abre la hoja Pro sin guiar (C06); de noche nada (C08) |
| Barra: "Mezclas" / "Noche" | "Mezclas" ["Mixes"] / "Pantalla de noche" ["Night screen"] | — | — | `.isButton` | — |
| Tip | el texto | — | — | `.isStaticText`; `.announcement` al aparecer | — |
| `SystemGallery` (DEBUG) | título de cada caso | — | — | `.isHeader` | — |

Orden de la página (E2 lo hereda): cabecera → nombre → horizonte → línea de estado → capas → "Todas las capas" → Marea → Temporizador → "Mezclas" → Disco → "Noche". El Disco vive en la barra inferior, que VoiceOver lee después del contenido; `accessibilitySortPriority` solo ordena dentro de su contenedor, así que el Disco no puede ser el primero: lo que sí funciona desde cualquier foco es Magic Tap en la raíz de la página y `.startsMediaSession` en el Disco (desviación de 03 §4.4 "primero en el orden", registrada en §9.17). VoiceOver no detiene la cama: la sesión permite *ducking* y recupera el nivel en 1 s.

### 5c. Gesto → alternativa sin gesto → Control por botón → teclado / Pointer

| Gesto | Dónde | Alternativa sin gesto | Control por botón (Switch Control) | Teclado / Pointer (iPad, Full Keyboard Access) |
|---|---|---|---|---|
| Arrastre horizontal relativo (nivel; vertical = scroll, C52; umbral validado por el spike I0-2) | `LevelRule` | Pulsación larga → `Slider` del sistema; VoiceOver `.adjustable` | La fila es un elemento; las acciones "Subir", "Bajar", "Silenciar", "Máximo" aparecen en el menú del conmutador; el `Slider` del sistema es operable | Tab al valor; ←/→ ±5; ⇧ ±1; Space abre el `Slider`; Pointer: arrastre o clic en la línea |
| Arrastre en la página nocturna (valor hasta I0-2) | `LevelRule` | 16 pt y cono de 20°; vertical = scroll; con scroll en curso ninguna fila acepta arrastre; las mismas alternativas | igual | igual |
| Toque en la fila | `LevelRule` | Capa incluida: no hace nada (decisión). Capa Pro: abre la hoja Pro de día (acción "Ver Pro"); de noche nada (C06, C08) | Acción "Ver Pro" en el menú (de día) | Space |
| Pulsación larga sobre la fila (0,6 s, ≤ 10 pt) | `LevelRule` | Acción "Ajuste con deslizador" | Acción en el menú | Space |
| Pulsación larga sobre el horizonte (0,6 s) | `SoundLine` | Acción "Ver capas por separado" (sin Audio Graph, C63) | Acción en el menú | Space mientras el foco está en el horizonte |
| Arrastre vertical sobre la banda (ritmo) | `TideLine` hoja | Fila "Ritmo" con opciones (E3) | Fila "Ritmo" | ↑/↓ ±1 por minuto |
| Toque en toda la pantalla (pausa) | `FullScreenControl` | La superficie es un botón accesible; "Controles visibles de noche" | Un elemento para la superficie; controles visibles activados solos (la fila sustituye a "+15 min") | Space / Return; Pointer: clic en cualquier punto |
| Arrastre vertical (volumen maestro; 24 pt, eje fijado) | `FullScreenControl` | La superficie es `.adjustable` (±5 %); acción "Volumen" anuncia el valor; botones físicos del iPhone | Acción "Volumen" → ajustable; botones físicos | ↑/↓ ±5 % |
| Pulsación larga 0,6 s, ≤ 10 pt (volver) | `FullScreenControl` Noche | Botón "Volver a la página" (1 × 1 pt, primero en el orden); escape en Z; acción con nombre | Botón "Volver a la página" al principio del orden | Esc |
| Toque en "+15 min" | `FullScreenControl` | Es un botón: no es gesto | Botón de 64 | Tab + Space |
| Toque en el Disco | `PlayDisc` | Magic Tap (raíz de la página); `AudioPlaybackIntent` desde fuera | Botón | Space; Pointer |
| Toque en la palabra | `HairlineAction` | Es un botón | Botón | Space |
| Arrastrar para cerrar hoja | Hoja | Escape en Z; el indicador; Control por voz "Cerrar" (en todas las versiones; iOS 26 no añade botón) | El indicador de arrastre es operable; escape | Esc |
| `contextMenu` del nombre | Página (E5) | VoiceOver lo expone como acciones | Menú accesible | Menú con teclado |

Ningún gesto es la única vía; ninguno es de varios dedos ni de pellizco; ninguno horizontal en Noche; ningún doble toque en ninguna superficie. El gesto de timbre no existe: Timbre es una fila (C29, C52).

### 5d. Dynamic Type por tramo

| Componente | xS-L | xL-xxxL | AX1-AX2 | AX3-AX5 |
|---|---|---|---|---|
| Tokens, hairline, retícula | — | — | hairline sigue en 1/displayScale; filas crecen por `@ScaledMetric(relativeTo: .headline)` | igual |
| Horizonte a un tercio | H × 0,333 | igual | se ancla a 24 pt bajo la cabecera (`isAccessibilitySize`) | igual |
| `SoundLine` | banda 24 | igual | banda 24 (es gráfica; no escala) | igual; grosor 1,5→3 no escala |
| `LevelRule` | mínimo 56 táctiles + 24 de canal; nombre y valor en línea | mínimo 56; la altura la empuja el texto escalado (`relativeTo`), sin `@ScaledMetric` en el área táctil; medidas en galería [a medir] | `ViewThatFits` → nombre arriba, subtítulo, valor debajo a la izquierda; línea abajo; altura por contenido [a medir] | igual; valor en 17 pt desde AX3; subtítulo puede ir a dos líneas |
| `TideLine` | banda 120; palabra a la derecha | igual | banda 120 (gráfica); palabra de fase bajo la banda a la izquierda | igual |
| `PlayDisc` | 44 en objetivo 64 | igual | igual (el sistema no escala la barra) | igual |
| Barra ("Mezclas" / "Noche") | 17 Medium (`.bar`) | escala con `.body` hasta xxxL (≈ 23 pt) | el sistema deja de escalar la barra desde AX1 | AX4-AX5: glifos `square.stack` / `circle.lefthalf.filled` con etiqueta |
| `FullScreenControl` | "+15 min" 20 Medium, fila 64 | 20 → escala con `.title3` | fila 64 → 72; texto hasta ≈ 28 pt | igual; nada se corta (tres elementos: superficie, altavoz, "+15 min" o la fila). Controles visibles: en AX3+ las tres palabras pasan a tres filas de 64 apiladas (y 626-818) |
| `HairlineAction` | palabra 17, fila 64 | fila 64; palabra a 23 pt cabe | fila 64 → 80; palabra a dos líneas si hace falta | igual |
| `EditorialRow` | 56 / 72 | 64 / 80 (`@ScaledMetric(relativeTo: .headline)`) | `ViewThatFits` → valor debajo del nombre; 88-104 | igual; subtítulo a dos líneas |
| Toggle Marea | del sistema | del sistema | etiqueta a dos líneas desde AX1 | igual |
| `StateWord` | 13 versalitas | escala con `.footnote` | igual; nunca se oculta | igual |
| `TextAction` | 17, 44 | 44 → 56 | 56 | 64 |
| Cifra (paso 1) | 72 / 56 | escala con `.largeTitle` | tope `.accessibility2` (≈ 100 / 80) | tope (no crece más) |
| Hoja | cabecera 22 | escala | la hoja desplaza; cabecera a dos líneas | igual |
| Tip | 15, una línea | dos líneas | tres líneas máx.; si no cabe, no se muestra | igual |

### 5e. Catálogo de cadenas ES / EN por clave

Cadenas que pertenecen al sistema (componentes y patrones). **Cada ES y EN coincide letra a letra con `10-GUIA-DE-COPY` §5e** (columna "Clave en 10"): el String Catalog de E7 usa la clave de 10 y `sys.*` es el nombre con el que los listados del Anexo A la referencian hasta que E7 cierre el catálogo (una clave por texto). Las claves marcadas **[retirada por Cnn]** o **[absorbida]** no se compilan. Las que no están en 10, o que 10 fija de otro modo, van a §9 como "pendiente de E7" y usan la redacción más cercana de la guía. Las claves de `main` que se conservan: `a11y.percentFormat` ("%lld por ciento"), `breath.title` (→ `marea.titulo`), `control.play`, `control.pause`. Las que este sistema sustituye: `common.close` (no hay Cerrar), `sound.locked`, `sound.proOnly` (cápsula), `trial.chip.*`, `paywall.purchaseUnavailable`, `paywall.keepFormat`, `paywall.purchaseFormat`, `mixer.tagline`. **Máx. = caracteres del idioma más largo de cada clave (ES o EN)**: es la longitud que E2-E6 comprueban en Large sin truncar en 375 pt [a medir en la galería]. El EN no es siempre más corto. Las claves con argumentos se escriben sin el formato en el nombre; el código las resuelve con `L.text(_:_:)` (A1: `Text(verbatim: String(format: String(localized:), …))`), nunca con interpolación dentro de `LocalizedStringKey` (que buscaría "sys.pro.saved %@" en el catálogo). Los números que se enseñan (`displayPrice`, `displayName`, cuenta de capas, noches de prueba) son los del código, nunca constantes de copy (reconciliación §1 regla 8).

| Clave | Clave en 10 | ES | EN | Contexto | Máx. |
|---|---|---|---|---|---|
| sys.play | `control.play` (main) | Reproducir | Play | VoiceOver del Disco | 10 |
| sys.pause | `control.pause` (main) / `ax.accion.pausar` | Pausar | Pause | VoiceOver del Disco y acción de Noche | 6 |
| sys.resume | `ax.accion.reanudar` | Reanudar | Resume | Acción de Noche / Madrugada en pausa | 8 |
| sys.sound | `ax.horizonte` | Sonido | Sound | Etiqueta del horizonte (elemento de estado, C63) | 6 |
| sys.sound.silent | `pagina.estado.silencio` | En silencio | Silent | Valor del horizonte y línea de estado de E2 | 11 |
| sys.sound.low | `ax.horizonte.valor.bajo` | Sonando, nivel bajo | Playing, low level | Valor del horizonte (rms < 0,33), histéresis 3 s | 19 |
| sys.sound.medium | `ax.horizonte.valor.medio` | Sonando, nivel medio | Playing, medium level | Valor (0,33-0,66) | 21 |
| sys.sound.high | `ax.horizonte.valor.alto` | Sonando, nivel alto | Playing, high level | Valor (> 0,66) | 19 |
| sys.sound.layers | `ax.accion.capas_separadas` | Ver capas por separado | Show layers separately | Acción del horizonte | 22 |
| sys.level.label | `ax.capa` | %@, %@ | %@, %@ | Etiqueta de `LevelRule`: nombre + subtítulo | 6 |
| sys.level.hint | `ax.capa.pista` | Desliza arriba o abajo para ajustar. | Swipe up or down to adjust. | Pista de `LevelRule` | 36 |
| sys.level.mute | `ax.accion.silenciar` | Silenciar | Mute | Acción | 9 |
| sys.level.max | `ax.accion.maximo` | Máximo | Maximum | Acción; anuncio al llegar a 100 | 7 |
| sys.level.up | `ax.accion.subir` | Subir | Move up | Acción de nivel (5 %) para Switch Control | 7 |
| sys.level.down | `ax.accion.bajar` | Bajar | Move down | Ídem | 9 |
| sys.level.slider | `ax.accion.deslizador` | Ajuste con deslizador | Adjust with slider | Acción / pulsación larga | 21 |
| sys.level.slider.label | `capas.deslizador` | Nivel de %@ | %@ level | Etiqueta del `Slider` del sistema; %@ capa | 11 |
| sys.pro | `comun.pro` | pro | pro | Versalita; `StateWord` | 3 |
| sys.pro.level | `comun.pro.nivel` | pro · %lld | pro · %lld | Versalita con nivel guardado (C23) | 10 |
| sys.pro.label | `ax.capa.pro` | %@, %@, requiere Pro | %@, %@, requires Pro | Etiqueta VoiceOver de capa Pro sin acceso | 20 |
| sys.pro.saved | `ax.capa.pro.valor` | en silencio, nivel guardado %@ | silent, saved level %@ | Valor VoiceOver de capa Pro; %@ cifra hablada; sin nivel guardado: `sys.sound.silent` | 30 |
| sys.pro.hint | `ax.capa.pro.pista` | Toca dos veces para ver Pro. | Double-tap to see Pro. | Pista capa Pro, solo de día (C06, C08) | 28 |
| sys.pro.see | `ax.accion.ver_pro` | Ver Pro | See Pro | Acción de la fila Pro (no existe de noche) | 7 |
| sys.pro.hint.night | [retirada por C08] | — | — | De noche la fila Pro no tiene pista ni acción | — |
| sys.pro.lastNight | [retirada por C08] | — | — | Sin cabecera matinal: `showPaywall` se consume sin cola | — |
| sys.tide | `marea.titulo` | Marea | Tide | Etiqueta de `TideLine` y del Toggle (C15: una unidad léxica) | 5 |
| sys.tide.pace | `marea.ritmo.fila` (pendiente de E7, §9 #26) | Ritmo | Pace | Etiqueta del control de ritmo en la hoja | 5 |
| sys.tide.pace.hint | `ax.agua.pista` | Desliza arriba o abajo para cambiar el ritmo. | Swipe up or down to change the pace. | Pista | 45 |
| sys.tide.in | `marea.fase.inhala` | inhala | breathe in | Palabra de fase, paso 7 | 10 |
| sys.tide.out | `marea.fase.exhala` | exhala | breathe out | Palabra de fase | 11 |
| sys.tide.guiding | `marea.estado.guiando.corto` | guiando · %lld por minuto | guiding · %lld per minute | Versalita | 25 |
| sys.tide.dissolving | `marea.estado.disolviendo` | disolviendo | dissolving | Versalita | 11 |
| sys.tide.paused | `marea.estado.pausa` | en pausa | paused | Versalita | 8 |
| sys.tide.recedesAt | `marea.retira.hora` | Se retira a las %@ | Recedes at %@ | Paso 7, hora; nunca versalitas | 18 |
| sys.tide.receded | `marea.retirada` | Se ha retirado. El mar sigue. | It has receded. The sea goes on. | Nota 10 s | 32 |
| sys.tide.perMinute | `marea.ritmo.exacto` | %lld por minuto | %lld per minute | Valor VoiceOver del control de ritmo (hoja), C59 | 15 |
| sys.tide.value | `ax.agua.valor` | %@, %lld por minuto, se retira en %lld minutos | %@, %lld per minute, recedes in %lld minutes | Valor VoiceOver del indicador (principal) | 46 |
| sys.tide.toggle.on | `ax.marea.valor` | Guiando, %lld por minuto, se retira a las %@ | Guiding, %lld per minute, recedes at %@ | Valor VoiceOver del Toggle encendido | 44 |
| sys.tide.toggle.off | `ax.marea.off` | Desactivada | Off | Valor del Toggle apagado | 11 |
| sys.tide.toggle.off.pro | `ax.marea.off.pro` | Desactivada, requiere Pro | Off, requires Pro | Valor del Toggle sin acceso | 25 |
| sys.tide.toggle.hint | `ax.marea.pista` | Toca dos veces para encenderla; el sonido arranca. | Double-tap to turn it on; the sound starts. | Pista del Toggle con acceso, en silencio | 50 |
| sys.tide.toggle.hint.pro | `ax.marea.pista.pro` | Toca dos veces para ver Pro. | Double-tap to see Pro. | Pista del Toggle sin acceso, solo de día (C06) | 28 |
| sys.night | `ax.noche.pantalla` / `barra.noche.ax` | Pantalla de noche | Night screen | Etiqueta de `FullScreenControl` y de "Noche" en la barra | 17 |
| sys.night.value | `ax.noche.valor` | %@. %@ | %@. %@ | Valor de Noche: hora hablada + palabra de estado de E4 (que ya lleva "Se funde a las…" / "Hasta las…") | 6 |
| sys.night.value.noTimer | [absorbida en `sys.night.value`] | — | — | La palabra de estado de E4 dice "En pausa" o "Sonando" | — |
| sys.night.value.until | [retirada] | — | — | Manto: el estado de E4 dice "hasta las %@" (`noche.estado.hasta`) | — |
| sys.night.hint | `ax.noche.pista` | Toca dos veces para pausar. Mantén para volver. | Double-tap to pause. Hold to go back. | Pista de la superficie en Noche | 47 |
| sys.night.hint.error | `ax.noche.pista.error` | Toca dos veces para reintentar. | Double-tap to try again. | Pista con "Sin sonido" | 31 |
| sys.smallHours | `madrugada.titulo` | Madrugada | Small hours | Etiqueta de la superficie de Madrugada | 11 |
| sys.smallHours.hint | `ax.madrugada.pista` | Toca dos veces para pausar. | Double-tap to pause. | Pista de la superficie en Madrugada | 27 |
| sys.smallHours.value | `ax.madrugada.valor` | Quedan %lld minutos. %@ | %lld minutes left. %@ | Valor de Madrugada; %@ = Sonando / En pausa | 23 |
| sys.smallHours.receding | `ax.madrugada.retirada` (pl) | Se retira, quedan %lld minutos | Winding down, %lld minutes left | Valor de Madrugada los últimos 5 min (C60) | 31 |
| sys.night.add15 | [absorbida en `sys.night.plus15.label`] | — | — | La acción se llama como el botón | — |
| sys.night.volume | `ax.volumen` | Volumen | Volume | Acción / ajustable (maestro de sesión, C51) | 7 |
| sys.night.back | `ax.accion.volver` | Volver a la página | Back to the page | Botón de 1 × 1 pt / acción / Control por voz | 18 |
| sys.night.plus15 | `comun.mas15` | +15 min | +15 min | Botón de 64; solo si hay temporizador (C47); libre (C03) | 7 |
| sys.night.plus15.label | `ax.mas15` | Quince minutos más | Fifteen more minutes | VoiceOver; también la acción personalizada | 20 |
| sys.night.minus15 | `noche.ctl.menos15` | −15 min | −15 min | Controles visibles | 7 |
| sys.night.minus15.label | `ax.menos15` | Quince minutos menos | Fifteen minutes less | VoiceOver | 20 |
| sys.night.minutesLeft | `ax.anuncio.quedan` (pl) | Quedan %lld minutos | %lld minutes left | Anuncio tras +15 | 19 |
| sys.night.until | `ax.anuncio.hasta` | Hasta las %@ | Until %@ | Anuncio tras +15 con Manto | 12 |
| sys.night.stop | `comun.parar` | Parar | Stop | Botón de 64 en Madrugada (03 §4.5) | 5 |
| sys.night.smallHours | `madrugada.estado` | Madrugada · 20 min | Small hours · 20 min | Botón de 64 en el hueco del "+15 min" con Noche terminada (C27) | 20 |
| sys.night.smallHours.label | `ax.la.madrugada` / `ax.control.madrugada` | Madrugada, veinte minutos | Small hours, twenty minutes | VoiceOver de ese botón | 27 |
| sys.night.speaker | `ruta.seguir_altavoz` | Seguir por el altavoz | Keep playing on speaker | Botón de 64, paso 4, 60 s (C49); es-419 "bocina" | 23 |
| sys.night.speaker.hint | `ax.altavoz.pista` | El volumen baja al cuarenta. | The volume drops to forty. | Pista | 28 |
| sys.state.volume | `estado.volumen` | Sonando · al %lld | Playing · at %lld | Estado 3 s tras el arrastre vertical y tras reanudar por el altavoz capado a 0,4 (C49, C51); sustituye `sys.night.speaker.note` | 17 |
| sys.night.speaker.note | [sustituida por `sys.state.volume`] | — | — | "Nivel bajado al 40 para el altavoz" no está en 10 | — |
| sys.night.noSound | `noche.estado.sin_sonido` | Sin sonido | No sound | Error en Noche, `textoNoche`; es botón | 10 |
| sys.night.controls | `ajustes.noche.controles` | Controles visibles de noche | Visible controls at night | Ajuste y VoiceOver (tres botones de 64, 03 §4.5; §9 #29) | 27 |
| sys.state.playing | `pagina.estado.sonando` | Sonando | Playing | Palabra de estado / anuncio | 7 |
| sys.state.paused | `pagina.estado.pausa` | En pausa | Paused | Palabra de estado / anuncio | 8 |
| sys.state.paused.cause | `noche.estado.pausa.causa` | En pausa · %@ | Paused · %@ | Causa en minúscula: auriculares, AirPods, llamada (C48, C49) | 13 |
| sys.state.fading | `noche.estado.fundiendo` | Fundiendo · %lld min | Fading · %lld min | Palabra de estado (22 Medium en Noche); fundido de ganancia 10–15 min (C31) | 20 |
| sys.state.fadesAt | `noche.estado.funde` | Se funde a las %@ | Fades at %@ | Estado de Noche (03 §1.3) | 17 |
| sys.state.until | `noche.estado.hasta` | hasta las %@ | until %@ | Estado de Noche con Manto (C22) | 12 |
| sys.state.playing.without | `pagina.estado.sonando.sin` | Sonando · sin %@ | Playing · without %@ | Línea de estado de E2 con una capa Pro fuera; %@ capa en minúscula | 20 |
| sys.action.buy | `pro.comprar` | Comprar · %@ | Buy · %@ | `HairlineAction`; %@ = `displayPrice` (regla 8: números del código) | 12 |
| sys.action.buy.loading | `pro.comprar.sin_precio` | Comprar | Buy | Sin producto o cargando: `texto2` entre hairlines `trazoHoja`, `.disabled` | 7 |
| sys.action.buy.loading.label | `ax.comprar.sin_precio` | Comprar %@ | Buy %@ | VoiceOver sin producto; %@ = `displayName` | 10 |
| sys.action.buy.loading.value | `ax.comprar.sin_precio.valor` | precio no disponible | price unavailable | Valor VoiceOver sin producto | 20 |
| sys.action.buy.loading.hint | `ax.comprar.sin_precio.pista` | La tienda no responde. | The store isn't responding. | Pista sin producto | 27 |
| sys.action.buy.label | `ax.comprar` | Comprar %@, %@ | Buy %@, %@ | VoiceOver; %@ `displayName`, %@ `displayPrice` (C12) | 14 |
| sys.action.buy.hint | `ax.comprar.pista` | Un solo pago. Abre la confirmación de App Store. | One payment. Opens the App Store confirmation. | Pista | 48 |
| sys.action.buying | `pro.comprando` | Comprando… | Buying… | En curso (Comprar) | 10 |
| sys.action.restore | `pro.restaurar` | Restaurar compra | Restore purchase | `TextAction` | 16 |
| sys.action.restoring | `pro.buscando` (pendiente de E7, §9 #27) | Buscando… | Looking… | En curso (Restaurar compra, `TextAction`) | 9 |
| sys.action.save | `comun.guardar` | Guardar | Save | `HairlineAction` | 7 |
| sys.action.startTrial | `pro.prueba.empezar` | Empezar la prueba · 7 noches | Start the trial · 7 nights | `HairlineAction` de la hoja Pro mientras la prueba no se ha usado (C07) | 28 |
| sys.action.startTrial.label | `ax.prueba.empezar` | Empezar la prueba de siete noches | Start the seven-night trial | VoiceOver | 33 |
| sys.action.startTrial.hint | `ax.prueba.empezar.pista` | No se cobra nada ni se pide tarjeta. | Nothing is charged and no card is asked. | Pista | 40 |
| sys.action.gotIt | `comun.entendido` | Entendido | Got it | `TextAction` | 9 |
| sys.action.notNow | `comun.ahora_no` | Ahora no | Not now | `TextAction` | 8 |
| sys.store.down | `pro.sin_tienda.silencio` | La tienda no responde. Nada cambia. | The store isn't responding. Nothing changes. | Nota bajo Comprar deshabilitado, sin sonido | 44 |
| sys.store.down.playing | `pro.sin_tienda` | La tienda no responde. Nada cambia: sigue sonando. | The store isn't responding. Nothing changes: it keeps playing. | Nota mientras suena (`meter.isProducingAudio`) | 62 |
| sys.store.pending | `pro.pendiente` | Pendiente de aprobación familiar. Se abrirá solo cuando llegue. | Waiting for family approval. It will open on its own. | Nota bajo Comprar, compra pendiente (Pedir para comprar / SCA) | 63 |
| sys.store.thanks | `pro.gracias` | Gracias. Todo abierto. | Thank you. Everything's open. | Fila tras la compra, 1,5 s | 29 |
| sys.store.failed | `pro.fallo` | No se ha podido completar. No se ha cobrado nada. | Couldn't complete. Nothing was charged. | Nota bajo Comprar | 49 |
| sys.store.unconfirmed | `pro.fallo.sin_confirmar` | No se ha podido confirmar. Si App Store te ha cobrado, Restaurar compra lo abre. | Couldn't confirm. If the App Store charged you, Restore purchase opens it. | Nota: `.unverified` y errores de red tras la hoja del sistema | 80 |
| sys.bar.mixes | `barra.mezclas` | Mezclas | Mixes | Barra, `.bar` (17 Medium) | 7 |
| sys.bar.night | `barra.noche` | Noche | Night | Barra, `.bar` (17 Medium) | 5 |
| sys.audio.failed | `pagina.error.inicio` | No se ha podido iniciar el sonido. Toca para reintentar. | Couldn't start the sound. Tap to try again. | Línea de estado que es botón; sin rojo | 56 |
| sys.audio.failed.2 | `pagina.error.inicio.2` | Si sigue sin sonar, cierra la app y vuelve a abrirla. | If it still won't play, close the app and open it again. | Segundo fallo | 56 |
| sys.audio.failed.3 | `pagina.error.inicio.3` (pendiente de E7, §9 #28) | Cierra las apps que usen el micrófono y vuelve a intentarlo. | Close any app using the microphone and try again. | Tercer fallo | 60 |
| sys.tip.drag | `tip.arrastre` | Arrastra sobre el nombre para cambiar el nivel. | Drag across the name to change the level. | Tip único de 1.0 (C65) | 47 |
| sys.layers.cap | `capas.tope` | Seis a la vez | Six at once | Nota 3 s al activar la séptima capa (C19); la pinta E2 | 13 |
| sys.layers.tone | `capas.timbre` | Timbre | Tone | Fila Timbre al pie de Capas (C29) [spike I0-7] | 6 |
| sys.layers.tone.deep | `capas.timbre.grave` | Grave | Deep | Extremo izquierdo, versalita | 5 |
| sys.layers.tone.far | `capas.timbre.lejos` | Lejos | Far | Extremo derecho, versalita | 5 |
| sys.mix.tonight | `mezcla.nombre.vacio` / `mezclas.esta_noche` | Esta noche | Tonight | Nombre de la mezcla viva sin guardar (§3); no es una pantalla | 10 |
| sys.a11y.layersChart | [retirada por C63] | — | — | Sin `AXChartDescriptor` | — |
| sys.a11y.page | `ax.anuncio.pagina` | Página | Page | Anuncio al volver de Noche | 6 |
| sys.a11y.saved | `mezclas.guardada` | Guardada | Saved | Anuncio al guardar una mezcla | 8 |
| sys.gallery.provisional | — (DEBUG; no se localiza, §9 #30) | provisional · hasta I0-1 | provisional · until I0-1 | Galería DEBUG, paso 9 versalitas | 24 |

Versalitas: la cadena se escribe en minúscula y `.lowercaseSmallCaps()` la compone; nunca `uppercased()`. Cifras con `monospacedDigit()`. Ningún texto de esta tabla usa palabras de la lista negra ni de las que §3 de la reconciliación veta ("Escudo", "chip", "ranura", "envolvente", "Desbloquear", "v1/v2"…); "Mezclas" y "Noche" son las palabras de la barra (nunca "Noches").

---

## 6. Variantes

| Variante | Qué cambia | Qué no cambia |
|---|---|---|
| **iPhone 17 Pro (393 × 852, por convención de 03)** | Horizonte en y = 284; columna 353; `LevelRule` 1 pt = 1/333 | — |
| **iPhone SE / 16e (375 × 667 · 390 × 844)** | Horizonte en y = 224 / 280 (múltiplo de 4, 03 §3.5); columna 335 / 350; 1 pt = 1/315 / 1/330; la banda de 120 (reservada cuando hay Marea disponible) cabe porque el tercio es proporcional y la columna de capas (máx. 3 en la principal) va debajo; "+15 min" y controles visibles conservan 64 pt | Tamaños de paso, hairline, objetivos |
| **iPad (`TARGETED_DEVICE_FAMILY 1,2`) y Stage Manager** | Ninguna cota usa `UIScreen`: el tercio y el recorrido del arrastre salen del `GeometryReader` del contenedor | Todo lo demás |
| **Negro (nocturno)** | Tokens Any/Dark | — |
| **Papel (apariencia clara del sistema; 1.1, C32)** | `negro`→papel, `texto`→tinta, `texto2`→tinta2, `texto3`→tinta3 (componentes a 3:1 → tinta2), `indice`→ocre, `trazo`→trazo-papel, `grafito`→pulsado-papel, `hoja`→blanco al 60 %; sin sombras (papel mate); el Disco conserva el relieve con `pulsado-papel` | Noche, Madrugada y página nocturna son siempre negras (`NightPhase` fuerza `.dark` con `preferredColorScheme` solo en esas vistas); sin selector propio. En 1.0 la raíz entera lleva `preferredColorScheme(.dark)`: los tokens de papel están en el catálogo y no se usan hasta 1.1 |
| **ES / EN** | Longitudes de §5e (Máx. = el mayor de los dos idiomas); "inhala"/"breathe in" cabe a la derecha de la banda en 375 pt (ancho ≤ 92 pt a 15 pt) | Nada se abrevia; versalitas reales en los dos |
| **High Contrast** (`accessibilityContrast == .increased`) | Variantes del catálogo: `texto2` → `#B4B2AE`, `texto3` → `#7A7672`, `trazo` → `#3A3836`, `indice` → `#FFD23C`; hairlines de 1 pt en `HairlineAction`; la línea vacía de `LevelRule` pasa a 1,5 pt | Nada en código: solo el catálogo, salvo los dos grosores |
| **Button Shapes** (`accessibilityShowButtonShapes`) | `TextAction`, "Mezclas", "Noche", "+15 min", "Parar" subrayados por el sistema (`.borderless`); `HairlineAction` subrayado; `PlayDisc` ya es forma; `LevelRule`: el valor subrayado (lo que el sistema haría con un botón de texto); el `Slider` sigue bajo pulsación larga y acción de VoiceOver, nunca permanente (seis sliders genéricos serían la categoría) | — |
| **Escala de grises** | Suena / no suena: línea con grosor frente a hairline y `pause.fill` / `play.fill`; capa a cero: pista sola; Pro: la palabra; dedo: 3 pt y pista `grafito`; Marea: línea que se mueve entre dos marcas. Ningún estado depende del matiz | — |
| **Filtro rojo de StandBy / Night Mode** [spike I0-6] | Solo superficies del sistema (E6): una tinta `texto` (4,43 / 4,30 calculados; criterio C62: texto ≥ 24 pt y ≥ 3:1 **medido en dispositivo** en el spike I0-6; plan B `texto` → `#F0ECE4` si queda por debajo de 3,5), formas ≥ 2 pt, estado por forma; `indice` no sale de la app salvo el tinte *on* del Control (C61) | La app no se muestra bajo el filtro; Noche se diseñó en gris igualmente |
| **Reduce Transparency** | El vidrio de iOS 26 pasa a opaco solo; `hoja` ya es opaca; sin materiales propios | — |
| **Bold Text** | SF escala de peso solo; `TypeStep` no fija pesos con `.custom` | — |
| **Smart Invert** | `SoundLine`, `TideLine` y glifos de pendiente llevan `.accessibilityIgnoresInvertColors()` | El negro invertido es decisión del usuario |
| **Acceso asistido** | Noche y Madrugada con disposición de un botón (la pantalla) | — |

---

## 7. Háptica por evento

02 §4 íntegro y 03 §3.8 tal cual. Cada evento con su anuncio de VoiceOver. **Toda háptica pasa por `MotionGate`** (`condition:` de cada `sensoryFeedback`, A5, A9, A10, A11): la puerta es **por fase** (`MotionGate.allows(phase) = !phase.isNight`, C35): de día vibra; en cualquier fase nocturna (Noche, Madrugada, página nocturna), nunca (un `.impact(.medium)` sobre la mesilla despierta a quien duerme al lado). Sin CoreMotion en producción 1.0; el spike I0-5 queda como investigación y, de día, la háptica no sabe si el teléfono está en la mano (coste aceptado en C35). "Háptica del sistema" desactivada = nada; segundo plano = nada. Sostener el iPhone 0,6 s para volver no cuenta como "en la mano": la pulsación larga también pasa por la puerta.

| Evento | Componente | iPhone (`sensoryFeedback` / Core Haptics) | Anuncio VoiceOver |
|---|---|---|---|
| Play | `PlayDisc` | `.impact(weight: .medium, intensity: 0.7)` al inicio del fundido de 800 ms; por `MotionGate` | "Sonando" |
| Pausa | `PlayDisc` | `.impact(weight: .light, intensity: 0.5)`; por `MotionGate` | "En pausa" |
| Nivel cruza 0 | `LevelRule` | `.selection`; por `MotionGate` | valor hablado |
| Nivel llega a 100 | `LevelRule` | `.impact(weight: .light, intensity: 0.6)`; por `MotionGate` | "Máximo" |
| Pasos intermedios | `LevelRule` | ninguna | valor hablado al soltar |
| Ritmo cruza un entero | `TideLine` (hoja) | `.selection` | "{n} por minuto" |
| Toque en Noche / Madrugada | `FullScreenControl` | **ninguna** (lo confirma el sonido) | "En pausa" / "Sonando" |
| Arrastre de volumen en Noche | `FullScreenControl` | ninguna | "Volumen {n} por ciento" al soltar |
| "+15 min" | `FullScreenControl` | `.selection` solo de día (`MotionGate` por fase; en Noche nunca, C35) | "Quedan {n} minutos" |
| Pulsación larga (volver) | `FullScreenControl` | `.impact(weight: .light, intensity: 0.4)` al cumplirse 0,6 s; por `MotionGate` (en Noche nunca) | "Página" (`sys.a11y.page`) |
| Pulsación larga (Slider / capas) | `LevelRule`, `SoundLine` | ninguna | nombre del control que aparece |
| Marea "Mínima" | `TideLine` | Core Haptics continuo siguiendo `BreathCurve`, nitidez 0,2, 3-5 respiraciones al empezar; **opt-in** en la hoja Marea (C35); de noche nunca; `playsHapticsOnly`; motor destruido al terminar | opcional "inhala" / "exhala" |
| Marea "Marcada" (Watch 1.2, C35) | — | se va al Watch: transitorio por inhalación toda la guía; no se compila en iPhone 1.0 | idem |
| Toggle de Marea | sistema | el del `Toggle` | "Marea, activada" |
| Guardar mezcla | `HairlineAction` | `.success`; por `MotionGate` | "Guardada" (`sys.a11y.saved`) |
| Compra completada | `HairlineAction` | `.success` (hoja delante) | "Gracias. Todo abierto." |
| Fallo de compra | `HairlineAction` | `.error` solo con la hoja delante | texto del fallo |
| Compra cancelada por el usuario, compra pendiente de aprobación | `HairlineAction` | **ninguna** | — / texto de la nota |
| Fin de temporizador, fin de Marea, fin de prueba, error de audio, abrir el paywall, enseñar el precio | — | **ninguna** | anuncio de la línea de estado |

---

## 8. Lo que se queda fuera y por qué

- **Timbre por capa** (1.1, C29) y **gesto de timbre** (C52): en 1.0 el timbre es la fila "Timbre" al pie de Capas sobre el bus maestro [spike I0-7]; la pulsación larga abre el `Slider` del sistema (C21).
- **Toque en la fila = silenciar** (Grafito) y **toque en capa a cero = 40 %** (Marea): filas contiguas sin canal visible; un roce apaga la lluvia (03 §1.2). El toque no hace nada.
- **Traza temporal del sonido** en cualquier forma (sismógrafo, banda de marcas, horizonte que corre, polilínea): el RMS del ruido es plano; sería mentira o AGC (03 §1.4).
- **Play trazado de 1,5 pt**, **Disco de 72**, **anillo de 64** (Grafito, Dial, Marea): el Disco es 44 en objetivo 64, único relieve.
- **Doble toque, arrastre horizontal, "bajar la persiana", arrastre desde el borde, dos dedos, pellizco** en Noche o en cualquier superficie.
- **Cápsula de volumen con porcentaje flotante** (Silencio 3.2) y **valor junto al dedo** (Grafito): el valor crece en su sitio.
- **Hojas negras**, botón "Cerrar", título centrado, radios propios, sombras exteriores, degradados, `glassEffect` en contenido, `GlassEffectContainer`.
- **Rojo de error**, `.red` del sistema en avisos: el fallo es texto `texto2` que es botón.
- **Acento fuera de la app** y **acento en el Disco**: `Ink.system` no lo exporta; `PlayDisc` no lo pide.
- **`KeyframeAnimator` para la línea de agua** (02 §3.4 lo barajaba): se reutiliza el `TimelineView` a 30 Hz pausable del `BreathIndicator` actual (03 §3.7).
- **Iconos en el mezclador y en la principal**; `SoundID.symbolName` queda para Atajos y widgets, bajo E6.
- **Luna, estrellas, nubes, candados, coronas, sellos, relojes de arena, regalos** en cualquier glifo.
- **Variantes papel de los tokens nocturnos** (`textoNoche`, `indiceNoche`): la noche es siempre negra.
- **Selector de apariencia propio**, **ajuste de brillo**, `isIdleTimerDisabled = true` por defecto en Noche: la pantalla duerme salvo que "Mantener encendida" diga otra cosa (mientras carga, por defecto; C46).
- **Sonidos de interfaz**: ninguno (02 §5).
- **Micrófono, modo cuna, Watch (1.2, C28), Focus filter (1.1, C43), gestos de Marea por textura (1.1, C24), Salud (2.0, C34), escucha de 30 s (1.1, C06), Papel (1.1, C32)**: fuera de 1.0; el sistema deja sitio (la hoja de Marea reserva la fila "Mi ritmo nocturno"; `Ink.system` ya sirve al Watch). El Focus de Sueño como entrada a Noche va con el Focus filter (1.1).
- **Hairline vertical** entre los controles visibles de Noche: sería un segundo tipo de separador (03 §3.5); tres palabras de 64 pt separadas por 32 pt de aire.
- **Pista vacía de la regla de volumen en Noche** (`texto3`, 4,01:1, invisible a brillo mínimo): solo la parte llena en `textoNoche`; el vacío es negro, como la línea ausente es la pausa.
- **`isLuminanceReduced` dentro de la app**: en iPhone nunca es verdadero con la app delante; solo lo leen las vistas de la Live Activity y StandBy (E6).
- **`Slider` permanente con Button Shapes**: seis sliders genéricos bajo seis filas serían el mezclador de la categoría; el valor se subraya y el `Slider` sigue bajo pulsación larga.
- **`fullScreenCover` para Noche**: entra deslizando desde abajo en 17/18, la violación más visible de "nada cambia de posición"; Noche es una capa del `ZStack` de la raíz con `.transition(.opacity)`.
- **`Timer` en `SoundMeter`**: el único reloj de la interfaz es el `TimelineView`, que ya se pausa; el medidor es una función del tiempo (`master(at:)`).
- **Hoja Pro de noche y línea matinal**: dentro de `NightWindow` (21:00–07:00) y en cualquier fase nocturna el toque en una capa Pro no hace nada y no deja cola ni cabecera "Anoche probaste…" (`SaleGate`; C08).
- **`AXChartDescriptor` / rotor Audio Graph** en el horizonte: comunica estado, no datos (C63).
- **Acento en el Toggle de Marea**: `.tint(texto)` (03 §4.12 consolidado).
- **Cápsulas / "chips"**: el estado es `StateWord` o fila con estado en versalita (C64).
- **Código muerto**: `PlayDisc.pressed`, `PrimaryActionStyle.pressedDepth`, `HairlineAction.noColor`, `IndexArbiter.Owner.purchase` (la excepción de "Comprar" es por regla, no por reclamación): eliminados de los listados.

---

## 9. Preguntas abiertas

Las que la reconciliación del 16-11-2026 cierra se marcan **cerrada por Cnn** y salen de la lista abierta (§12 detalla el cambio); el resto sigue con dueño y plazo.

**Para el dueño**
1. **Acento (reconciliación §6 #1, plazo 27-11-2026).** El sistema se entrega con `índice #F0C020`; si prefiere `#E0524D`, cambian tres entradas del catálogo. Prueba de cinco segundos con la página real sonando en un iPhone en la mesilla a oscuras; si más de dos de diez dicen "aviso", bajamos a `#E6BC3A` antes de cambiar de matiz.
2. ~~Modo papel en 1.0 (03 §7.3)~~ **cerrada por C32**: solo oscura en 1.0; Papel en 1.1 con los tokens ya en el catálogo.
3. ~~Reparto gratuito (03 §7.9-7.10)~~ **cerrada por C03, C04 y §1 regla 3**: `freeSavedMixLimit` 1 → 3 (sin límite con Pro), `freeTimerMinutes` desaparece (temporizador entero libre), viento libre.
4. ~~"Controles visibles de noche" como ajuste manual~~ **cerrada por C58**: fila "Controles visibles" en el grupo Noche de Ajustes.
5. ~~"Parar" en Madrugada (03 §4.5, §5 #11)~~ **cerrada por 03 §4.5 consolidado y C25**: se mantiene "Parar"; la Isla expandida que daba casa a "+10 min" ya no existe.

**Para los spikes de ingeniería (semana 2, C45)**
6. **[I0-1]** Medidor RMS por capa en el hilo de audio, canal sin bloqueos render → main. Hasta entonces `SoundMeter` deriva el valor de `envelopeTarget × Σ gains` siguiendo la rampa real (`rampSeconds`) y el horizonte respira solo en arranques y fundidos; **se marca provisional en la galería**. ¿τ 500 ms en el hilo de audio o en el main? Con el medidor real el `TimelineView` ya no podrá pausarse por convergencia: hay que medir el coste a 20 Hz. El nivel maestro ya no depende de este spike: entra en 1.0 como `EngineCommand.setMaster(level:, ramp:)` (C51).
7. **[I0-2]** Arrastre relativo con `minimumDistance` 8 y bloqueo de eje a 30° dentro de una `List`/`ScrollView` (C52: horizontal = nivel, vertical = scroll; el spike valida el umbral): ¿`simultaneousGesture` o `highPriorityGesture`? ¿El canal muerto de 24 pt basta para que un scroll que empieza sobre la fila no cambie el nivel? Prueba con VoiceOver y Switch Control. Hasta el spike, la página nocturna lleva el fallback de §2.2 (16 pt, cono de 20°, cede al scroll).
8. ~~[I0-5] CoreMotion "en la mano"~~ **cerrada por C35**: la puerta de la háptica es por fase (`!phase.isNight`), sin CoreMotion en producción 1.0; el spike queda como investigación.
9. **[I0-6]** Matriz real del tinte de StandBy, medida en dispositivo (C62): fuera de la app texto ≥ 24 pt y ≥ 3:1 bajo rojo; si la medida queda por debajo de 3,5, plan B `texto` → `#F0ECE4` (cambia una entrada del catálogo y `Ink.system`). Decide también si la línea estática necesita ≥ 2 o ≥ 3 pt.
10. ~~`preview(_:seconds:)` en `MixerModel`~~ **cerrada por C06**: sin escucha de 30 s en 1.0; vuelve en 1.1 sin hoja automática.
11. **iOS 26 y el Disco (C66 lo confirma: único `#available`).** `.buttonStyle(.glass)` sobre `configuration.label` dentro de `makeBody` no hace nada (la etiqueta no es un `Button`). En la rama `#available(iOS 26, *)` de A6 el estilo devuelve la etiqueta sin relieve y confía en que `ToolbarItemGroup(.bottomBar)` envuelve el ítem en vidrio [a verificar en el SDK 26.6]; si no lo hace, la alternativa es `configuration.label.glassEffect(.regular.interactive(), in: .circle)` (capa de navegación, permitido por P12), nunca `.buttonStyle` sobre una etiqueta. Fila tocada = pista grafito de 44 pt en todas las versiones; sin `glassEffect` en contenido; sin control teñido; la app se ve igual en iOS 17 y 26 salvo el Disco.
12. **Altura real de la barra inferior** (≈ 49 pt en 17/18) frente al objetivo de 64 del Disco: [a medir] si el ítem se recorta; la salida está en §2.4.
13. ~~`AXChartDescriptor`~~ **cerrada por C63**: el horizonte es un elemento de estado con valor (histéresis 3 s) y acción; `LayerChart` y `sys.a11y.layersChart` eliminados.
24. **[I0-7]** Timbre en el bus maestro (C29): si el spike pasa, la fila "Timbre" (Grave–Lejos) entra en 1.0 como una `LevelRule` más al pie de Capas (§2.2); puerta de decisión en la semana 4–6; si no llega, la fila cae a 1.1 sin cambiar el copy. Es el mismo bus del que depende el corte de filtro del fundido (C31).
25. **[I0-3]** Intents: "Madrugada · 20 min" en el hueco del "+15 min" y "terminada → Madrugada" en la Live Activity dependen del intent `SmallHours` (C25, C27); la Live Activity recortada solo existe en el escenario A.

**Correcciones a 03 que este documento aplicaba y que 03 consolidado ya recoge (cerradas)**
14. ~~Acento en el Toggle de Marea (03 §4.12)~~ **cerrada**: 03 §3.1 regla 2 y §4.12 fijan `.tint(texto)`; §2.7 y A1 lo aplican; el toggle *on* se lee por la posición del pomo (P7).
15. ~~Cota del horizonte~~ **cerrada**: 03 §3.5 alinea "284 en 852, 280 en 844, 224 en 667" (múltiplo de 4); §2.0.3 y §6 actualizados.
16. ~~Hairlines de "Comprar" (03 §4.6)~~ **cerrada**: 03 §4.6 ya dice 1,5 pt.
17. ~~Orden de VoiceOver (03 §4.4)~~ **cerrada**: 03 §4.4 adopta Magic Tap en la raíz (C63).
18. ~~Hoja en iOS 26 (03 §4.10)~~ **cerrada**: 03 §4.10 ya dice "sin botón Cerrar en ninguna versión".
19. ~~Banda de la Marea (03 §4.1)~~ **cerrada**: 03 §4.1 ya dice "120 desde el principio; no crece".
20. ~~Rampas del motor (03 §3.7)~~ **cerrada**: 03 §3.7 ya fija 800 ms / 1,5-2 s.
21. ~~High Contrast de `texto-noche`, `índice-noche` y `trazo-hoja`~~ **cerrada**: 03 §3.1 los declara, por decisión, iguales a `texto2-ac`, `índice-ac` y `trazo-ac`.

**Tokens que faltan (se miden en 1.1 con Papel, C32)**
22. **High Contrast de papel** (`tinta2`, `tinta3`, `ocre`, `trazo-papel`): sin variante en 03; se declaran iguales a los normales.
23. **`hoja-papel`**: hex aplanado de "blanco al 60 % sobre `#F3F0E9`", medido, para declararlo opaco y que ningún activo contenga `#FFFFFF`. Hasta entonces el catálogo lo declara con alfa.

**Pendiente de E7 (cadenas de §5e que no están en 10 o que 10 fija de otro modo)**
26. `sys.tide.pace`: la etiqueta "Ritmo de la Marea" del control de ritmo en la hoja no está en 10; se usa "Ritmo" / "Pace" (`marea.ritmo.fila`) hasta que E7 decida.
27. `sys.action.restoring`: 10 fija "Buscando…" / "Looking…" (`pro.buscando`) y 03 §4.6 lo recoge; proponemos "Restaurando…" / "Restoring…", que dice lo que pasa (jurado de honestidad, §11); mientras, se usa la de 10.
28. `sys.audio.failed.3`: 10 fija "Cierra las apps que usen el micrófono y vuelve a intentarlo."; la app no usa el micrófono y la frase puede confundir; proponemos "…que usen el audio…"; mientras, la de 10.
29. "Controles visibles de noche": 03 §4.5 fija tres botones (−15 · pausa · +15) y 10 (`ajustes.noche.controles.nota`, `noche.ctl.pagina`) escribe cuatro, con "Página"; este documento sigue a 03 (el cuarto es el botón "Volver a la página", operable por Switch Control); E4 y E7 deben alinear la nota.
30. `sys.gallery.provisional` no se localiza (DEBUG) y no va al catálogo.
31. Palabra de "Comprar" sin producto: 03 §4.6 escribe `texto3`; 03 §3.1 reserva `texto3` al texto ≥ 18 pt; se usa `texto2` como 10 (`pro.comprar.sin_precio`) y se pide a 03 corregir §4.6.

---

## 10. Autoevaluación

### 10.1 Puerta de formato (03 §8.3.1)

| Requisito | Dónde | Estado |
|---|---|---|
| Tabla de movimiento con señal del motor | §5a, M1-M32 | Completa; M2 marcada provisional [I0-1]; ninguna fila cambia posición ni tamaño |
| VoiceOver por control (etiqueta / valor / pista / rasgos / acciones) | §5b | Completa para los seis propios, los del sistema con estilo y la galería; cada entrada tiene su línea en el Anexo A |
| Gesto → alternativa → Control por botón → teclado | §5c | Completa; ningún gesto es la única vía; incluye el fallback de la página nocturna |
| Dynamic Type por tramo | §5d | Completa por componente, barra, `EditorialRow` y Toggle incluidos; `LevelRule` en AX marcada [a medir] |
| Cadenas ES/EN por clave | §5e | 107 claves vivas (más las retiradas, marcadas) con clave equivalente en 10, contexto y longitud máxima; cada ES/EN idéntica a 10 §5e |
| Todas las medidas en pt | §2, §5d, §6 | Sí; el icono (px) es de E8 |
| Un único juego de hex | §2.0.1 | Solo los de 03 §3; los de papel marcados 1.1; el plan B de `texto` (`#F0ECE4`) es de 03 §3.1 / C62 |
| Maqueta y texto coinciden | §2 wireframes ↔ tablas ↔ listados | Las cotas del wireframe son las constantes de `Grid`; la galería (§2.8) las comprueba en dispositivo; lo no verificado lleva [a medir] |

### 10.2 Las doce pruebas del brief

| P | Prueba hecha sobre este sistema |
|---|---|
| P1 Noche manda | `NightPhase` y `Ink` resuelven primero la noche; `FullScreenControl`, `textoNoche` e `indiceNoche` existen antes que el papel. Se comprueba en dormitorio a oscuras con la galería. |
| P2 Un gesto | Pausar: toque en toda la pantalla (Noche), Disco (página), Magic Tap. +15: botón de 64 fijo que siempre extiende. Volumen: arrastre vertical o botones físicos. Prueba a ciegas de cinco personas al cierre de E4. |
| P3 Negro real | `negro #000000`; sin degradados ni rellenos salvo `grafito` del Disco (44 pt) y la pista bajo el dedo (transitoria); un acento por pantalla por `IndexArbiter`; el Toggle de Marea va en `texto` (03 §4.12 consolidado). Ningún tinte heredado: la raíz lleva `.tint(Ink.text)`. Conteo de color por pantalla: negro + 3 grises + 1 acento. |
| P4 Causa en el sonido | §5a nombra la señal de cada fila; M1 y M3 son las rampas reales del motor (§0 (7)); M2 y M11 leen el motor; Reduce Motion → opacidad; fondo / hoja → congelado ≤ 2 s. |
| P5 Tipografía primero | Una familia (`TypeStep` no admite otra); nueve pasos; ≤ 6 estilos por pantalla (17 Medium cuenta, C67; la principal ≤ 4 en reposo); xS → AX5 con `ViewThatFits` en `LevelRule`. |
| P6 Aire antes que cajas | Cero rectángulos rellenos en los componentes salvo los dos transitorios; grupos 32 = 2 × 16; hairline único separador. |
| P7 Estado por forma | §6 escala de grises: grosor, continuidad, variante del glifo, palabra. |
| P8 44 / 64 | `Grid.target 44`, `Grid.nightTarget 64`; canal de 24 entre reglas; pantalla completa en Noche. |
| P9 Nada bloquea | `PlayDisc` nunca deshabilitado; `LevelRule` Pro abre la hoja solo de día (`SaleGate`) y de noche no hace nada; nada se bloquea ni se castiga (C06, C08); hojas solo tras un toque; cero candados en ningún listado (`grep lock` = 0). |
| P10 Una pantalla, una decisión | §1: una pregunta por pieza. |
| P11 Lo técnico debajo | `Slider` exacto bajo pulsación larga; capas por separado bajo pulsación larga; ritmo exacto en la hoja. |
| P12 Componentes de Apple | Seis propios (§2.1-2.6, con "por qué": no existen en el sistema); el resto del sistema con estilo; único `#available` en `PrimaryActionStyle`; cero `glassEffect` en contenido. |

Listas negras: ningún listado ni cadena usa luna, nubes, estrellas, candados, coronas, `hourglass`, `gift`, `checkmark.seal`; ninguna cadena usa "insomnio", "ansiedad", "mejora el sueño", "IA", "vitalicio", "timer" ni "mix" en español, ni los términos que §3 de la reconciliación veta ("Escudo", "chip", "ranura", "envolvente", "Desbloquear", "Lluvia fina", "Cama rosa", "Mar lento", "v1/v2"), que solo aparecen aquí como vetados. `grep -i` sobre este documento y el Anexo A lo confirma.

---

## Anexo A · Build de referencia (listados SwiftUI, iOS 17)

Carpeta propuesta: `SleepNoise/Design/` (añadir al target cuando ingeniería lo decida; **no se ha tocado `project.yml`**). Un único `#available(iOS 26)` en A6. Ningún listado importa nada fuera de SwiftUI, AVFAudio (latencia de salida) y UIKit (escala, orientación, accesibilidad). Compilable conceptualmente: los tipos del motor (`SoundID`, `SoundGains`, `BreathParameters`, `BreathCurve`, `BreathingGuideController`) son los de `main`.

### A1 · `Design/Ink.swift` — tokens, fase y árbitro del índice

```swift
import SwiftUI

/// Fase de la noche (03 §3.2). Cambia luminancia, nunca matiz.
enum NightPhase: Equatable {
    case day          // página de día ("Descenso" es solo el ritual de Marea, C14)
    case nightPage    // la página al volver de Noche: por procedencia, dura la sesión, sin salida por reloj (C40)
    case night        // pantalla Noche
    case smallHours   // Madrugada
    var isNight: Bool { self != .day }
}

/// Tokens del asset catalog (Any/Dark = nocturno, Light = papel [1.1, C32], + High Contrast).
enum Ink {
    static let background = Color("negro")
    static let sheet      = Color("hoja")
    static let relief     = Color("grafito")
    static let rule       = Color("trazo")
    static let ruleSheet  = Color("trazoHoja")
    static let text       = Color("texto")
    static let text2      = Color("texto2")
    static let text3      = Color("texto3")
    static let textNight  = Color("textoNoche")
    static let index      = Color("indice")
    static let indexNight = Color("indiceNoche")
    /// Única tinta fuera de la app (Live Activity, StandBy, widgets, Watch 1.2); excepción: el tinte *on* del Control usa AccentColor (C61).
    /// Plan B (C62): si el spike I0-6 mide < 3,5:1 bajo rojo, `texto` pasa a #F0ECE4 en el catálogo.
    static let system     = Color("texto")

    /// De noche, una tinta. Regla 3 de 03 §3.1.
    static func primary(_ phase: NightPhase) -> Color { phase.isNight ? textNight : text }
    static func secondary(_ phase: NightPhase) -> Color { phase.isNight ? textNight : text2 }
    static func accent(_ phase: NightPhase) -> Color { phase.isNight ? indexNight : index }
}

extension NightPhase {
    /// Noche y Madrugada: la pantalla es el botón (FullScreenControl delante).
    var isNightScreen: Bool { self == .night || self == .smallHours }
}

/// Cadenas con argumentos: la clave del catálogo es "sys.pro.saved", no "sys.pro.saved %lld".
/// Nunca interpolar dentro de LocalizedStringKey (buscaría la clave con el formato).
enum L {
    static func string(_ key: String, _ args: CVarArg...) -> String {
        String(format: String(localized: String.LocalizationValue(key)), arguments: args)
    }
    static func text(_ key: String, _ args: CVarArg...) -> Text {
        Text(verbatim: String(format: String(localized: String.LocalizationValue(key)), arguments: args))
    }
}

/// Un índice por pantalla (Dial §3.0). Prioridad: dedo > marea > horizonte.
/// Las hairlines de "Comprar" con precio quedan fuera por regla (§2.0.4); el Toggle de Marea va en `texto` (03 §4.12).
@MainActor final class IndexArbiter: ObservableObject {
    enum Owner: Equatable { case finger(SoundID), tide, horizon }
    @Published private(set) var owner: Owner?
    private var requests: [Owner] = []

    func claim(_ o: Owner) { requests.removeAll { $0 == o }; requests.append(o); resolve() }
    func release(_ o: Owner) { requests.removeAll { $0 == o }; resolve() }
    func owns(_ o: Owner) -> Bool { owner == o }

    private func resolve() {
        func rank(_ o: Owner) -> Int {
            switch o { case .finger: return 0; case .tide: return 1; case .horizon: return 2 }
        }
        owner = requests.min { rank($0) < rank($1) }
    }
}

private struct NightPhaseKey: EnvironmentKey { static let defaultValue = NightPhase.day }
/// La pone la PÁGINA que presenta una hoja (`.environment(\.sheetPresented, activeSheet != nil)` sobre sí misma);
/// SoundLine y TideLine, que viven debajo, la leen. SystemSheet no la pone: la hoja no se detecta a sí misma.
private struct SheetPresentedKey: EnvironmentKey { static let defaultValue = false }
extension EnvironmentValues {
    var nightPhase: NightPhase { get { self[NightPhaseKey.self] } set { self[NightPhaseKey.self] = newValue } }
    var sheetPresented: Bool { get { self[SheetPresentedKey.self] } set { self[SheetPresentedKey.self] = newValue } }
}
```

### A2 · `Design/TypeStep.swift` — escala de nueve pasos con `relativeTo`

```swift
import SwiftUI

/// Los nueve pasos de 03 §3.4. Solo SF Pro; Text/Display los elige el sistema.
enum TypeStep {
    case figure, figureSmall, name, header, nightState, nightAction, row, value, body, reading, bar, secondary, note, data, stateWord
    // .value = paso 5 en Medium tabular (el valor de nivel bajo el dedo); .bar = paso 6 en Medium (solo la barra inferior).
    // 17 Medium (.value, .bar) no es un paso nuevo, pero cuenta como un estilo en el ≤ 6 por pantalla (C67).

    var size: CGFloat {
        switch self {
        case .figure: 72; case .figureSmall: 56; case .name: 28; case .header, .nightState: 22
        case .nightAction: 20; case .row, .value, .body, .reading, .bar: 17; case .secondary: 15; case .note, .data, .stateWord: 13
        }
    }
    /// Altura de línea de 03 §3.4 en Large (no el lineSpacing de SwiftUI).
    var lineHeight: CGFloat {
        switch self {
        case .figure: 80; case .figureSmall: 64; case .name: 34; case .header, .nightState: 28; case .nightAction: 25
        case .row, .value, .body, .bar: 22; case .reading: 26; case .secondary: 20; case .note, .data, .stateWord: 18
        }
    }
    var textStyle: Font.TextStyle {
        switch self {
        case .figure, .figureSmall: .largeTitle; case .name: .title; case .header, .nightState: .title2
        case .nightAction: .title3; case .row, .value: .headline; case .body, .reading, .bar: .body; case .secondary: .subheadline
        case .note, .data, .stateWord: .footnote
        }
    }
    /// Peso de día; de noche nada baja de Medium salvo la cifra (≥ 20 pt).
    func weight(_ phase: NightPhase) -> Font.Weight {
        switch self {
        case .figure, .figureSmall: return .regular
        case .name, .nightState, .nightAction, .value, .bar, .data, .stateWord: return .medium
        case .header, .row: return .semibold
        case .body, .reading, .secondary, .note: return phase.isNight ? .medium : .regular
        }
    }
    /// Tracking como fracción del tamaño: −1 % en la cifra, +2 % en versalitas (sigue siendo −1 % en AX).
    var trackingFraction: CGFloat { switch self { case .figure, .figureSmall: -0.01; case .stateWord: 0.02; default: 0 } }
    var capsDynamicType: DynamicTypeSize? { switch self { case .figure, .figureSmall: .accessibility2; default: nil } }
    var isTabular: Bool { self == .data || self == .value || self == .figure || self == .figureSmall }
}

/// Aplica un paso escalando con su estilo de texto (nunca un tamaño congelado).
struct Stepped: ViewModifier {
    let step: TypeStep
    @Environment(\.nightPhase) private var phase
    @ScaledMetric private var scaled: CGFloat
    init(_ step: TypeStep) {
        self.step = step
        _scaled = ScaledMetric(wrappedValue: step.size, relativeTo: step.textStyle)
    }
    /// lineSpacing de SwiftUI es aire EXTRA entre líneas: se calcula contra la altura real de SF
    /// para que la altura de línea sea la de 03 §3.4 (17 → 22, no ≈ 25).
    private var extraLineSpacing: CGFloat {
        let target = step.lineHeight * scaled / step.size
        let natural = UIFont.systemFont(ofSize: scaled, weight: step.weight(phase).uiWeight).lineHeight
        return max(0, target - natural)
    }
    func body(content: Content) -> some View {
        var font = Font.system(size: scaled, weight: step.weight(phase))
        if step == .stateWord { font = font.lowercaseSmallCaps() }
        if step.isTabular { font = font.monospacedDigit() }
        return content
            .font(font)
            .tracking(scaled * step.trackingFraction)
            .lineSpacing(extraLineSpacing)
            .dynamicTypeSize(...(step.capsDynamicType ?? .accessibility5))
    }
}
extension View { func step(_ s: TypeStep) -> some View { modifier(Stepped(s)) } }

private extension Font.Weight {
    var uiWeight: UIFont.Weight { self == .semibold ? .semibold : self == .medium ? .medium : .regular }
}
```

### A3 · `Design/Grid.swift` — retícula, hairline, horizonte a un tercio

```swift
import SwiftUI

enum Grid {
    static let unit: CGFloat = 4
    static let margin: CGFloat = 20
    static let row: CGFloat = 56
    static let rowSubtitle: CGFloat = 72
    static let layerTouch: CGFloat = 56      // área táctil de la fila de capa
    static let layerChannel: CGFloat = 24    // canal muerto (12 arriba + 12 abajo)
    static let layerRow: CGFloat = 80        // = layerTouch + layerChannel
    static let group: CGFloat = 32
    static let inner: CGFloat = 16
    static let horizonBand: CGFloat = 24     // banda del horizonte sin Marea disponible
    static let tideBand: CGFloat = 120       // banda reservada siempre que la mezcla tenga Marea disponible
    static let target: CGFloat = 44
    static let nightTarget: CGFloat = 64
    static let horizonFraction: CGFloat = 0.333
    static let longPress: TimeInterval = 0.6 // única duración de pulsación larga (fila, horizonte, Noche)
    static let longPressSlop: CGFloat = 10   // maximumDistance: un pulgar que se posa no "vuelve"
    static let sliderDismiss: TimeInterval = 5 // el Slider por pulsación larga se retira a los 5 s sin dedo (03 §4.2)
}

/// 1 / displayScale de alto, de margen a margen. Único separador (no existe una variante vertical).
struct Hairline: View {
    enum Surface { case onBlack, onSheet }
    var surface: Surface = .onBlack
    var color: Color? = nil
    var thickness: CGFloat? = nil
    @Environment(\.displayScale) private var scale
    var body: some View {
        Rectangle()
            .fill(color ?? (surface == .onBlack ? Ink.rule : Ink.ruleSheet))
            .frame(height: thickness ?? 1 / scale)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

/// Sitúa `horizon` con su centro en H × 0,333 de la pantalla completa (proporcional, nunca un y
/// absoluto; 03 §1.3: 284 en 852). H se toma del GeometryReader del contenedor más sus insets
/// (nunca UIScreen: miente en iPad y Stage Manager). Con tamaños de accesibilidad se ancla bajo la cabecera.
/// `bandHeight` es Grid.tideBand siempre que la mezcla tenga Marea disponible: la banda nunca cambia de tamaño.
struct HorizonLayout<Header: View, Horizon: View, Below: View>: View {
    var bandHeight: CGFloat = Grid.horizonBand
    @ViewBuilder var header: Header
    @ViewBuilder var horizon: Horizon
    @ViewBuilder var below: Below
    @Environment(\.dynamicTypeSize) private var type
    var body: some View {
        GeometryReader { geo in
            let fullH = geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
            let centerY = fullH * Grid.horizonFraction - geo.safeAreaInsets.top   // en coordenadas del contenedor
            let topY = max(0, centerY - bandHeight / 2)
            VStack(spacing: 0) {
                if type.isAccessibilitySize {
                    header
                    Spacer().frame(height: Grid.group - Grid.unit * 2)
                } else {
                    header.frame(height: topY, alignment: .top)                      // la cabecera ocupa exactamente hasta la banda
                }
                horizon.frame(height: bandHeight)
                below
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Grid.margin)
        }
    }
}
```

### A4 · `Design/SoundMeter.swift` — lo que mueve el horizonte [spike I0-1]

```swift
import Combine
import Foundation

/// Fuente de verdad del horizonte. PROVISIONAL: hasta I0-1 deriva el nivel de la
/// ganancia maestra publicada (envelopeTarget × Σ gains), no del RMS medido.
/// SIN Timer: el medidor es una función del tiempo; el único reloj es el TimelineView del
/// Canvas (que ya se pausa). Así "10 min bloqueado = 0 actividad periódica salvo el motor".
@MainActor final class SoundMeter: ObservableObject {
    @Published private(set) var perLayer: [SoundID: Float] = [:]
    @Published private(set) var target: Float = 0            // objetivo publicado por el motor
    private(set) var targetDate = Date.distantPast           // cuándo cambió el objetivo
    private(set) var valueAtChange: Float = 0                // valor suavizado en ese instante
    private(set) var rampSeconds: TimeInterval = 0           // rampa real del motor hacia el objetivo
    var isProvisional = true                                 // la galería lo muestra
    var tau: TimeInterval = 0.5                              // 1,5 s con Reduce Motion

    /// Lo llama MixerModel cada vez que publica al motor, con la rampa que el motor va a aplicar
    /// (defaultFadeIn 0,8 s; pause 1,5 s; llamada 0,3 s; cambio de nivel ≈ 0).
    func update(gains: SoundGains, envelope: Float, rampSeconds: TimeInterval) {
        let now = Date()
        valueAtChange = master(at: now)
        targetDate = now
        self.rampSeconds = rampSeconds
        let sum = SoundID.allCases.reduce(Float(0)) { $0 + gains.value(for: $1) }
        target = min(1, envelope * min(1, sum))
        perLayer = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, gains.value(for: $0) * envelope) })
    }
    /// Valor suavizado en `date`: lineal durante la rampa real del motor, después τ hacia el objetivo.
    func master(at date: Date) -> Float {
        let dt = date.timeIntervalSince(targetDate)
        guard dt > 0 else { return valueAtChange }
        if dt < rampSeconds { return valueAtChange + (target - valueAtChange) * Float(dt / rampSeconds) }
        let k = Float(1 - exp(-(dt - rampSeconds) / tau))
        return valueAtChange + (target - valueAtChange) * k
    }
    /// Sobre el valor suavizado, no sobre el objetivo: la bajada a hairline se ve entera.
    func isProducingAudio(at date: Date = Date()) -> Bool { master(at: date) > 0.002 }
    /// Con el valor provisional la línea solo cambia en eventos: el TimelineView se pausa al converger.
    func hasConverged(at date: Date = Date()) -> Bool { abs(master(at: date) - target) < 0.001 }
}
```

### A5 · `Design/PlayDisc.swift` — el único botón con física

```swift
import SwiftUI

/// Magic Tap NO se declara aquí: lo declara la raíz de la página (E2), para que funcione desde cualquier foco.
struct PlayDisc: View {
    var isPlaying: Bool
    var isFading: Bool
    var action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.nightPhase) private var phase
    @State private var playTrigger = 0
    @State private var pauseTrigger = 0

    var body: some View {
        Button {
            if isPlaying { pauseTrigger += 1 } else { playTrigger += 1 }
            action()
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 22, weight: .medium))                     // glifo: tamaño fijo del símbolo, no texto
                .foregroundStyle(Ink.primary(phase))                           // de noche (página nocturna) una tinta
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.pulse, isActive: isFading && !reduceMotion)
                .frame(width: Grid.target, height: Grid.target)
        }
        .buttonStyle(PrimaryActionStyle())
        .frame(width: Grid.nightTarget, height: Grid.nightTarget)              // [a medir] dentro de la barra de ≈ 49 pt (§2.4)
        .contentShape(Circle())
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.7), trigger: playTrigger, condition: { _, _ in MotionGate.allows(phase) })
        .sensoryFeedback(.impact(weight: .light, intensity: 0.5), trigger: pauseTrigger, condition: { _, _ in MotionGate.allows(phase) })
        .accessibilityLabel(Text(isPlaying ? "sys.pause" : "sys.play"))
        .accessibilityAddTraits(.startsMediaSession)
        .accessibilityIdentifier("playButton")
    }
}
```

### A6 · `Design/PrimaryActionStyle.swift` — el único `#available(iOS 26)`

```swift
import SwiftUI

/// Relieve del Disco: grafito + sombra interior 1 pt (2 pt pulsado). En iOS 26 el
/// vidrio del sistema sustituye al relieve. Es el único #available del proyecto.
struct PrimaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let depth: CGFloat = configuration.isPressed ? 2 : 1
        if #available(iOS 26, *) {
            // Sin relieve: ToolbarItemGroup(.bottomBar) envuelve el ítem en vidrio [a verificar en SDK 26.6].
            // `.buttonStyle(.glass)` sobre la etiqueta no haría nada (no es un Button). Si la barra no lo
            // envuelve, la alternativa es `configuration.label.glassEffect(.regular.interactive(), in: .circle)` (§9.11).
            configuration.label
                .clipShape(Circle())
        } else {
            configuration.label
                .background(
                    Circle().fill(
                        Ink.relief.shadow(.inner(color: Ink.background.opacity(0.6), radius: 0, x: 0, y: depth))
                    )
                )
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
}
```

### A7 · `Design/HairlineAction.swift` — palabra entre dos hairlines de 64 pt

```swift
import SwiftUI

struct HairlineAction: View {
    /// Las cuatro salidas de StoreKit (03 #14): éxito, cancelación (vuelve a .normal/.purchase sin nota),
    /// fallo (nota bajo la fila, la pone el padre con `.purchase` + `note`) y pendiente de aprobación.
    enum Mode {
        case normal
        case purchase(priceLoaded: Bool, note: LocalizedStringKey? = nil)   // note = sys.store.failed tras un fallo
        case inProgress(LocalizedStringKey)                                   // sys.action.buying / sys.action.restoring
        case disabled(note: LocalizedStringKey?)                              // note ya resuelta: sys.store.down / sys.store.down.playing
        case pending                                                          // sys.store.pending; deshabilitada; sin háptica
        case success
    }
    var title: LocalizedStringKey
    var mode: Mode = .normal
    var onSheet = true
    var action: () -> Void
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes

    private var accentRules: Bool { if case .purchase(true, _) = mode { return true } else { return false } }
    /// Cargando precio también deshabilita: el precio se dice antes de cualquier toque (00 §2.2, 03 #14).
    private var isDisabled: Bool {
        switch mode { case .disabled, .inProgress, .pending, .purchase(false, _): true; default: false }
    }
    private var ruleColor: Color { accentRules ? Ink.index : (onSheet ? Ink.ruleSheet : Ink.rule) }
    private var wordColor: Color {
        switch mode {
        case .disabled, .purchase(false, _): return Ink.text2   // 03 §3.1 reserva texto3 al texto ≥ 18 pt (10 `pro.comprar.sin_precio`; §9 #31)
        case .inProgress, .pending: return Ink.text2
        default: return Ink.text
        }
    }
    private var note: LocalizedStringKey? {
        switch mode {
        case .disabled(let n): return n
        case .purchase(_, let n): return n
        case .pending: return "sys.store.pending"
        default: return nil
        }
    }
    private var a11yLabel: Text {
        switch mode {
        case .purchase(false, _): return Text("sys.action.buy.loading.label")   // "Comprar {displayName}": el padre resuelve el nombre con L.text; valor sys.action.buy.loading.value
        default: return Text(title)
        }
    }

    var body: some View {
        VStack(spacing: Grid.unit * 2) {
            Button(action: action) {
                Group {
                    switch mode {
                    case .inProgress(let word): Text(word)
                    case .success: Text("sys.store.thanks")
                    default: Text(title)
                    }
                }
                .step(.row)
                .foregroundStyle(wordColor)
                .underline(buttonShapes, color: wordColor)
                .frame(maxWidth: .infinity, minHeight: Grid.nightTarget)
                .contentTransition(.opacity)
            }
            .buttonStyle(FadeStyle())
            .disabled(isDisabled)
            .accessibilityLabel(a11yLabel)
            .overlay(alignment: .top) { Hairline(color: ruleColor, thickness: accentRules ? 1.5 : nil) }      // 1,5: mínimo del índice (03 §3.1)
            .overlay(alignment: .bottom) { Hairline(color: ruleColor, thickness: accentRules ? 1.5 : nil) }
            .animation(.easeInOut(duration: 0.25), value: accentRules)
            if let note {
                Text(note).step(.note).foregroundStyle(Ink.text2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
    }
    /// Pulsado: opacidad 0,6 durante 200 ms. Nada se mueve.
    struct FadeStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
}
```

### A8 · `Design/SoundLine.swift` — el horizonte

```swift
import SwiftUI

/// Línea quieta cuyo grosor (1,5→3 pt) y opacidad (0,6→1,0) siguen el RMS maestro.
/// Sin historia, sin desplazamiento. Color = sonido o dedo (03 §3.1 regla 1).
struct SoundLine: View {
    @ObservedObject var meter: SoundMeter
    @EnvironmentObject var arbiter: IndexArbiter
    var isPlaying: Bool
    var decomposed = false                       // pulsación larga (la gestiona el padre)
    var onToggleLayers: () -> Void = {}          // acción de VoiceOver "Ver capas por separado"
    @Environment(\.nightPhase) private var phase
    @Environment(\.scenePhase) private var scene
    @Environment(\.sheetPresented) private var sheetUp   // la pone la página que presenta la hoja
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.displayScale) private var scale
    @State private var converged = false
    @State private var spokenKey: LocalizedStringKey = "sys.sound.silent"   // valor hablado con histéresis de 3 s (C63)
    @State private var spokenAt = Date.distantPast

    /// Vivo = hay algo que dibujar y alguien que lo mire. Pausado también cuando el valor ha convergido
    /// (con el valor provisional la línea solo cambia en eventos; el onChange de `target` lo rearma).
    private var live: Bool {
        isPlaying && meter.isProducingAudio() && scene == .active && !sheetUp && !phase.isNightScreen && !converged
    }
    private var color: Color {
        if phase.isNight { return Ink.textNight }                              // página nocturna: nunca índice
        return arbiter.owns(.horizon) ? Ink.index : Ink.text
    }

    var body: some View {
        // `.animation(minimumInterval:paused:)` es el único horario con pausa (`.periodic` no la admite).
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.25 : 0.05, paused: !live)) { ctx in
            Canvas { g, size in
                let midY = size.height / 2
                if phase.isNightScreen {
                    guard isPlaying else { return }              // ausente = pausa
                    stroke(g, y: midY, width: size.width, thickness: 2, opacity: 1, color: Ink.textNight)
                    return
                }
                let rms = CGFloat(isPlaying ? meter.master(at: ctx.date) : 0)   // el único reloj es ctx.date
                if rms <= 0.002 {
                    stroke(g, y: midY, width: size.width, thickness: 1 / scale, opacity: 1, color: Ink.rule)
                    return
                }
                if decomposed {
                    // Superpuestas DENTRO de la banda: paso 4 pt (6 capas = 20 pt); la banda no crece.
                    let layers = SoundID.allCases.filter { (meter.perLayer[$0] ?? 0) > 0.002 }
                    let step = min(Grid.unit, (size.height - Grid.unit) / CGFloat(max(1, layers.count - 1)))
                    for (i, id) in layers.enumerated() {
                        let v = CGFloat(meter.perLayer[id] ?? 0)
                        let y = midY + (CGFloat(i) - CGFloat(layers.count - 1) / 2) * step
                        stroke(g, y: y, width: size.width, thickness: 1 + 2 * v, opacity: 0.6 + 0.4 * v, color: Ink.text)
                    }
                } else {
                    stroke(g, y: midY, width: size.width, thickness: 1.5 + 1.5 * rms, opacity: 0.6 + 0.4 * rms, color: color)   // el índice nunca baja de 1,5 pt (03 §4.1)
                }
            }
            .onChange(of: ctx.date) { _, now in
                converged = meter.hasConverged(at: now)
                let k = valueKey(at: now)
                if k != spokenKey, now.timeIntervalSince(spokenAt) > 3 { spokenKey = k; spokenAt = now }   // histéresis 3 s: VoiceOver no parlotea (C63)
            }
        }
        .frame(maxHeight: .infinity)                                         // la banda la fija HorizonLayout(bandHeight:)
        .animation(.easeInOut(duration: 0.4), value: decomposed)            // opacidad de las líneas por capa; ningún frame
        .onChange(of: live) { _, now in if now { arbiter.claim(.horizon) } else { arbiter.release(.horizon) } }
        .onChange(of: meter.target) { _, _ in converged = false }            // un evento del motor rearma el reloj
        .onAppear { meter.tau = reduceMotion ? 1.5 : 0.5 }
        .accessibilityElement()
        .accessibilityLabel(Text("sys.sound"))
        .accessibilityValue(Text(spokenKey))
        .accessibilityAddTraits([.isImage, .updatesFrequently])
        .accessibilityAction(named: Text("sys.sound.layers")) { onToggleLayers() }
        .accessibilityIgnoresInvertColors()                                  // sin AXChartDescriptor: el horizonte comunica estado, no datos (C63)
    }
    private func valueKey(at date: Date) -> LocalizedStringKey {
        let m = meter.master(at: date)
        guard isPlaying, m > 0.002 else { return "sys.sound.silent" }
        return m < 0.33 ? "sys.sound.low" : m < 0.66 ? "sys.sound.medium" : "sys.sound.high"
    }
    private func stroke(_ g: GraphicsContext, y: CGFloat, width: CGFloat, thickness: CGFloat, opacity: CGFloat, color: Color) {
        var p = Path(); p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: width, y: y))
        g.stroke(p, with: .color(color.opacity(opacity)), lineWidth: thickness)   // extremos rectos (.butt)
    }
}

```

### A9 · `Design/LevelRule.swift` — la fila es el control

```swift
import SwiftUI

/// La página (E2) marca `isScrolling` en el entorno (`onScrollPhaseChange` en 18+; `isScrolling` propio en 17)
/// para que, en la página nocturna, ninguna fila acepte arrastre mientras un scroll está en curso.
private struct IsScrollingKey: EnvironmentKey { static let defaultValue = false }
extension EnvironmentValues { var isScrolling: Bool { get { self[IsScrollingKey.self] } set { self[IsScrollingKey.self] = newValue } } }

struct LevelRule: View {
    let sound: SoundID
    let subtitle: String                         // clave del catálogo (capas.{id}.detalle)
    @Binding var level: Float                    // 0…1
    var isIncluded: Bool                         // AccessPolicy.soundIsIncluded
    var savedLevel: Float?                       // "pro · 30": nivel conservado; el motor lo ignora sin acceso; la degradación nunca escribe (C23)
    var onProTap: () -> Void                     // abre la hoja Pro si SaleGate lo permite (C06); de noche nada (C08); sin escucha de 30 s en 1.0
    var endpoints: (leading: LocalizedStringKey, trailing: LocalizedStringKey)? = nil   // fila Timbre (C29): "Grave" / "Lejos" en lugar de subtítulo y valor [spike I0-7]
    @EnvironmentObject var arbiter: IndexArbiter
    @Environment(\.nightPhase) private var phase
    @Environment(\.isScrolling) private var scrolling
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes
    @State private var dragging = false
    @State private var startLevel: Float = 0
    @State private var axisFixed: Bool? = nil     // nil = aún no decidido; true = horizontal
    @State private var crossedZero = 0
    @State private var reachedMax = 0
    @State private var showSlider = false
    @State private var columnWidth: CGFloat = 353 // del GeometryReader de la regla (nunca UIScreen)

    private var name: String { sound.localizedName }
    private var value: Int { Int((level * 100).rounded()) }
    private var usable: Bool { isIncluded }
    private var saleAllowed: Bool { SaleGate.allows(phase: phase, scene: .active) }

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: Grid.layerChannel / 2)                  // canal muerto (y 0-12)
            ZStack(alignment: .bottom) {                                      // área táctil (y 12-68)
                if dragging {                                                 // pista grafito 353 × 44 (y 12→56), radio 0
                    Rectangle().fill(Ink.relief).frame(height: Grid.target)
                        .padding(.horizontal, Grid.margin)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .transition(.opacity)
                }
                ViewThatFits(in: .horizontal) { inlineLabels; stackedLabels }
                    .padding(.horizontal, Grid.margin)
                    .padding(.bottom, Grid.unit * 4)                          // 16: subtítulo con línea base en y 48
                if showSlider {                                               // el Slider SUSTITUYE a la línea en su sitio (03 §4.2): nada crece ni se mueve
                    Slider(value: $level, in: 0...1).tint(Ink.primary(phase))     // se lee por forma; nunca índice
                        .frame(height: Grid.target).padding(.horizontal, Grid.margin)
                        .accessibilityLabel(L.text("sys.level.slider.label", name))
                        .onTapGesture {}                                           // retiene el toque
                        .task(id: "\(showSlider)-\(value)") { try? await Task.sleep(for: .seconds(Grid.sliderDismiss)); showSlider = false }   // 5 s sin dedo
                        .transition(.opacity)
                } else {
                    rule.padding(.horizontal, Grid.margin).padding(.bottom, Grid.unit * 3)   // 12: línea en y 56
                }
            }
            .frame(minHeight: Grid.layerTouch)                                // mínimo 56; el texto escalado empuja (sin @ScaledMetric)
            .contentShape(Rectangle())
            .simultaneousGesture(usable && !scrolling ? drag : nil)           // cede al scroll si el eje se fija vertical
            .onTapGesture { if !usable, saleAllowed { onProTap() } }         // incluida: nada; Pro: hoja de día; de noche nada (C06, C08)
            .onLongPressGesture(minimumDuration: Grid.longPress, maximumDistance: Grid.longPressSlop) { if usable { showSlider = true } }
            .animation(.easeInOut(duration: dragging ? 0.15 : 0.25), value: dragging)
            .animation(.easeInOut(duration: 0.25), value: showSlider)
            Color.clear.frame(height: Grid.layerChannel / 2)
        }
        .onTapGesture { showSlider = false }                                   // tocar fuera (el contenedor de la lista hace lo mismo)
        .sensoryFeedback(.selection, trigger: crossedZero, condition: { _, _ in MotionGate.allows(phase) })
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: reachedMax, condition: { _, _ in MotionGate.allows(phase) })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L.text(usable ? "sys.level.label" : "sys.pro.label", name, L.string(subtitle)))
        .accessibilityValue(usable ? Text(verbatim: TimeFormat.percentSpoken(value))
                                   : (savedLevel.map { L.text("sys.pro.saved", String(Int($0 * 100))) } ?? Text("sys.sound.silent")))
        .accessibilityHint(usable ? Text("sys.level.hint") : (saleAllowed ? Text("sys.pro.hint") : Text(verbatim: "")))   // de noche sin pista (C08)
        .accessibilityAddTraits(usable || !saleAllowed ? [] : .isButton)      // de noche la fila Pro no es botón
        .accessibilityActions {                                               // solo si la capa suena: en Pro no hay nivel que hablar
            if usable {
                Button("sys.level.mute") { level = 0 }
                Button("sys.level.max") { level = 1 }
                Button("sys.level.slider") { showSlider = true }
            } else if saleAllowed {
                Button("sys.pro.see") { onProTap() }                              // "Ver Pro" solo de día (C06)
            }
        }
        .accessibilityAdjustableAction { d in guard usable else { return }; level = min(1, max(0, level + (d == .increment ? 0.05 : -0.05))) }
    }

    private var inlineLabels: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: Grid.unit) {
                Text(name).step(.row).foregroundStyle(usable ? Ink.primary(phase) : Ink.secondary(phase))
                subtitleText
            }
            Spacer(minLength: Grid.inner)
            trailing
        }
    }
    private var stackedLabels: some View {      // AX1+
        VStack(alignment: .leading, spacing: Grid.unit) {
            Text(name).step(.row).foregroundStyle(usable ? Ink.primary(phase) : Ink.secondary(phase))
            subtitleText
            trailing
        }
    }
    @ViewBuilder private var subtitleText: some View {                       // fila Timbre: el extremo izquierdo va donde el subtítulo
        if let endpoints { Text(endpoints.leading).step(.stateWord).foregroundStyle(Ink.secondary(phase)) }
        else { Text(verbatim: L.string(subtitle)).step(.secondary).foregroundStyle(Ink.secondary(phase)) }
    }
    @ViewBuilder private var trailing: some View {
        if let endpoints {                                                    // fila Timbre: el extremo derecho donde iría el valor
            Text(endpoints.trailing).step(.stateWord).foregroundStyle(Ink.secondary(phase))
        } else if !usable {
            (savedLevel.map { L.text("sys.pro.level", Int64($0 * 100)) } ?? Text("sys.pro"))
                .step(.stateWord).foregroundStyle(Ink.secondary(phase))
        } else if level > 0.004 || dragging {
            Text("\(value)").step(dragging ? .value : .data)              // crece en su sitio, nunca flota; tabular en los dos pasos
                .foregroundStyle(dragging ? Ink.primary(phase) : Ink.secondary(phase))
                .underline(buttonShapes && !dragging, color: Ink.secondary(phase))   // Button Shapes: el valor subrayado
                .frame(minWidth: Grid.unit * 9, alignment: .trailing)        // sitio para tres cifras: de 9 a 10 nada salta
                .contentTransition(.numericText())
        }
    }
    private var rule: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Rectangle().fill(Ink.text3).frame(height: 1)                                   // pista vacía
                if usable {
                    Rectangle().fill(dragging ? Ink.accent(phase) : Ink.primary(phase))
                        .frame(width: w * CGFloat(level), height: dragging ? 3 : 2)
                }
            }.frame(height: 3, alignment: .center)
            .onAppear { columnWidth = w }.onChange(of: w) { _, new in columnWidth = new }
        }.frame(height: 3)
    }
    /// Arrastre relativo (delta), horizontal = nivel, vertical = scroll (C52): de día 8 pt y cono de 30° [el spike I0-2 valida el umbral];
    /// en la página nocturna 16 pt y 20°.
    /// 1 pt = 1/(columna − 20), con la columna del GeometryReader (1/333 en 393; iPad incluido).
    private var drag: some Gesture {
        let night = phase == .nightPage
        return DragGesture(minimumDistance: night ? 16 : 8, coordinateSpace: .local)
            .onChanged { g in
                if axisFixed == nil { axisFixed = abs(g.translation.height) < abs(g.translation.width) * (night ? 0.364 : 0.577) }
                guard axisFixed == true else { return }                      // vertical: no consume; el scroll gana
                if !dragging { dragging = true; startLevel = level; arbiter.claim(.finger(sound)) }
                let travel = columnWidth - 20
                let next = min(1, max(0, startLevel + Float(g.translation.width / travel)))
                if (level == 0) != (next == 0) { crossedZero += 1 }
                if next == 1, level < 1 { reachedMax += 1 }
                level = next
            }
            .onEnded { _ in dragging = false; axisFixed = nil; arbiter.release(.finger(sound)) }
    }
}
```

### A10 · `Design/TideLine.swift` — la línea de agua

```swift
import AVFAudio
import SwiftUI

/// Reutiliza el TimelineView a 30 Hz pausable del BreathIndicator actual. Misma BreathCurve,
/// mismo ancla (guide.anchor) más la latencia de salida. Nunca sin().
struct TideLine: View {
    @ObservedObject var guide: BreathingGuideController
    enum Role { case main, sheetControl, smallHours }
    var role: Role
    var onPaceChange: ((Int) -> Void)? = nil        // aplicado al siguiente ciclo (settingsDidChange)
    @EnvironmentObject var arbiter: IndexArbiter
    @Environment(\.nightPhase) private var phase
    @Environment(\.scenePhase) private var scene
    @Environment(\.sheetPresented) private var sheetUp   // la pone la página: con una hoja delante, quieta en bajamar
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var paceTicks = 0
    @State private var breathsShown = 0
    @State private var startPace: Int? = nil
    @State private var windowClosed = false               // 20 min: el reloj se para solo (como el BreathIndicator actual)

    /// `isActive` cubre guiando Y disolviendo (`isVisuallyActive()` solo es true en .guiding: la línea saltaría a bajamar).
    private var active: Bool {
        guide.phase != .idle && scene == .active && !sheetUp && !windowClosed && phase != .night
    }
    private var lineColor: Color {
        switch role { case .main: return arbiter.owns(.tide) ? Ink.index : Ink.text; case .sheetControl: return Ink.text; case .smallHours: return Ink.textNight }
    }
    private var markColor: Color { role == .smallHours ? Ink.rule : Ink.text3 }   // de noche, hairlines en trazo (03 §3.1 regla 3)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !active)) { ctx in
            let breath = value(at: ctx.date)
            ZStack(alignment: .top) {
                VStack { Hairline(color: markColor); Spacer(); Hairline(color: markColor) }         // pleamar / bajamar
                    .opacity(guide.phase != .idle ? 1 : 0)                                               // aparecen con la Marea; la banda no cambia
                    .animation(.easeInOut(duration: reduceMotion ? 0.25 : 0.8), value: guide.phase != .idle)
                Canvas { g, size in
                    let y = reduceMotion ? size.height / 2 : size.height - size.height * CGFloat(breath)
                    var p = Path(); p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: size.width, y: y))
                    let opacity = reduceMotion ? 0.6 + 0.4 * CGFloat(breath) : 1
                    g.stroke(p, with: .color(lineColor.opacity(opacity)), lineWidth: role == .smallHours ? 1.5 : 2)
                }
                if role != .smallHours, breathsShown < 3 {
                    Text(isInhaling(at: ctx.date) ? "sys.tide.in" : "sys.tide.out").step(.secondary)
                        .foregroundStyle(Ink.text2).frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 2).transition(.opacity).animation(.easeInOut(duration: 0.25), value: isInhaling(at: ctx.date))
                }
            }
        }
        .frame(height: Grid.tideBand)
        .gesture(role == .sheetControl ? paceDrag : nil)
        .sensoryFeedback(.selection, trigger: paceTicks, condition: { _, _ in MotionGate.allows(phase) })
        .onChange(of: active) { _, now in if now, role == .main { arbiter.claim(.tide) } else { arbiter.release(.tide) } }
        .task(id: guide.anchor) {
            breathsShown = 0; windowClosed = false
            await countBreaths()
            try? await Task.sleep(for: .seconds(20 * 60)); windowClosed = true      // ventana de 20 min, como BreathIndicator
        }
        .accessibilityElement()
        .accessibilityLabel(Text(role == .sheetControl ? "sys.tide.pace" : "sys.tide"))
        .accessibilityValue(role == .sheetControl
            ? L.text("sys.tide.perMinute", Int64(guide.settings.breathsPerMinute))
            : L.text("sys.tide.value", L.string(isInhaling(at: Date()) ? "sys.tide.in" : "sys.tide.out"),
                     Int64(guide.settings.breathsPerMinute), Int64(minutesLeft(at: Date()))))
        .accessibilityHint(Text(role == .sheetControl ? "sys.tide.pace.hint" : ""))
        .accessibilityAddTraits(role == .sheetControl ? [] : [.isImage, .updatesFrequently])
        .accessibilityAdjustableAction { d in
            guard role == .sheetControl else { return }
            let next = min(BreathingSettings.rateRange.upperBound, max(BreathingSettings.rateRange.lowerBound, guide.settings.breathsPerMinute + (d == .increment ? 1 : -1)))
            onPaceChange?(next)
        }
        .accessibilityIgnoresInvertColors()
    }

    private var params: BreathParameters { BreathParameters.guided(breathsPerMinute: guide.settings.breathsPerMinute) }
    private func seconds(at date: Date) -> Double {
        guard let anchor = guide.anchor else { return 0 }
        return date.timeIntervalSince(anchor) - AVAudioSession.sharedInstance().outputLatency
    }
    /// Amplitud × peso programado: la disolución (M13) baja la línea a bajamar en vez de cortarla.
    private func value(at date: Date) -> Float {
        guard active else { return 0 }                                       // en bajamar cuando está quieta
        let amp = guide.scheduledWeight(now: date) ?? 0
        return BreathCurve.value(secondsSinceStart: seconds(at: date), parameters: params) * amp
    }
    private func isInhaling(at date: Date) -> Bool {
        let ph = seconds(at: date) * Double(params.rate); return ph - floor(ph) < Double(params.inhale)
    }
    private func minutesLeft(at date: Date) -> Int {
        Int(ceil((guide.guideEndsAt?.timeIntervalSince(date) ?? 0) / 60))
    }
    private func countBreaths() async {
        guard params.rate > 0 else { return }
        for _ in 0..<3 { try? await Task.sleep(for: .seconds(Double(1 / params.rate))); breathsShown += 1 }
    }
    /// Arrastre vertical sobre la banda = ritmo 4-8; .selection por entero; aplicado al siguiente ciclo.
    /// Relativo al ritmo al EMPEZAR el arrastre (como LevelRule): sin cascada por acumulación.
    private var paceDrag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { g in
                if startPace == nil { startPace = guide.settings.breathsPerMinute }
                let step = Int((-g.translation.height / 24).rounded())
                let next = min(8, max(4, (startPace ?? guide.settings.breathsPerMinute) + step))
                if next != guide.settings.breathsPerMinute { paceTicks += 1; onPaceChange?(next) }
            }
            .onEnded { _ in startPace = nil }
    }
}
```

### A11 · `Design/FullScreenControl.swift` — Noche y Madrugada: la pantalla es el botón

```swift
import SwiftUI
import UIKit

/// Se presenta como capa del ZStack de la raíz (E2) con `.transition(.opacity)`, nunca como fullScreenCover
/// (que entra deslizando). La raíz pone `.statusBarHidden(phase.isNightScreen)`.
struct FullScreenControl<Content: View>: View {
    enum Role { case night, smallHours }
    var role: Role
    var isPlaying: Bool
    @Binding var masterVolume: Float
    var onToggle: () -> Void
    var onExtend: (() -> Void)?                  // +15 min (Noche; siempre extiende; nil = sin temporizador: el hueco queda vacío, C47) / Parar (Madrugada)
    var smallHoursOffer: (() -> Void)? = nil     // Noche terminada: "Madrugada · 20 min" ocupa el hueco del +15 (C27); intent SmallHours [spike I0-3]
    var onMinus15: () -> Void = {}
    var onBack: () -> Void                       // pulsación larga 0,6 s (solo Noche)
    var speakerOffer: (() -> Void)? = nil        // "Seguir por el altavoz", 60 s
    var accessibilityValue: Text                  // sys.night.value (hora + estado) / sys.smallHours.value, resuelto por E4 con L.text
    @ViewBuilder var content: Content           // hora, estado, horizonte (E4)
    @Environment(\.scenePhase) private var scene
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("sys.visibleNightControls") private var visibleControlsSetting = false
    @State private var activeSince = Date()                      // la primera presentación también cuenta
    @State private var assistRunning = UIAccessibility.isSwitchControlRunning || UIAccessibility.isAssistiveTouchRunning
    @State private var draggingVolume = false
    @State private var volumeAxisFixed: Bool? = nil              // nil = no decidido; true = vertical
    @State private var startVolume: Float = 0
    @State private var backTrigger = 0
    @State private var extendTrigger = 0

    private var phase: NightPhase { role == .night ? .night : .smallHours }
    private var showVisibleControls: Bool { role == .night && (visibleControlsSetting || assistRunning) }
    /// Una sola guarda para toque, pulsación larga y arrastre: 300 ms tras .active, y nunca boca abajo.
    private func tapAllowed() -> Bool {
        Date().timeIntervalSince(activeSince) > 0.3 && UIDevice.current.orientation != .faceDown   // [a medir] boca abajo
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // La superficie es un elemento accesible propio: botón + ajustable (volumen).
            Ink.background.ignoresSafeArea()
                .accessibilityElement()
                .accessibilityLabel(Text(role == .night ? "sys.night" : "sys.smallHours"))
                .accessibilityValue(accessibilityValue)
                .accessibilityHint(Text(role == .night ? "sys.night.hint" : "sys.smallHours.hint"))
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { onToggle() }
                .accessibilityAdjustableAction { d in masterVolume = min(1, max(0, masterVolume + (d == .increment ? 0.05 : -0.05))) }
                .accessibilityAction(named: Text(role == .night ? "sys.night.plus15.label" : "sys.night.stop")) { onExtend?() }   // solo si hay temporizador
                .accessibilityAction(named: Text("sys.night.volume")) {
                    AccessibilityNotification.Announcement(TimeFormat.percentSpoken(Int((masterVolume * 100).rounded()))).post()
                }
                .accessibilitySortPriority(1000)
            content
            if draggingVolume {                                              // regla vertical: solo la parte llena, 1 pt × 200 × volumen
                HStack { Spacer()
                    Rectangle().fill(Ink.textNight).frame(width: 1, height: 200 * CGFloat(masterVolume))
                        .frame(height: 200, alignment: .bottom)
                        .padding(.trailing, Grid.margin + Grid.unit * 2)      // x = 373 − 8: dentro del margen
                }.transition(.opacity)
            }
            VStack(spacing: 0) {                                             // apilado de abajo arriba; "+15 min" nunca se mueve
                if role == .night {
                    // Visible solo para VoiceOver, Switch Control y Control por voz; primero en el orden. [a medir] que no se filtra al tacto.
                    Button("sys.night.back", action: onBack)
                        .frame(width: 1, height: 1).opacity(0.011)
                        .accessibilitySortPriority(2000)
                }
                if let speakerOffer {                                        // paso 4, 64 pt: una acción de Noche (03 §3.4, §3.5)
                    nightButton("sys.night.speaker", label: "sys.night.speaker", action: speakerOffer)
                        .accessibilityHint(Text("sys.night.speaker.hint"))
                        .transition(.opacity)
                }
                if showVisibleControls {                                     // la fila SUSTITUYE a "+15 min"; 32 pt de aire, sin separador
                    HStack(spacing: Grid.group) {
                        nightButton("sys.night.minus15", label: "sys.night.minus15.label", action: onMinus15)
                        nightButton(isPlaying ? "sys.pause" : "sys.play", label: isPlaying ? "sys.pause" : "sys.play", action: onToggle)
                        nightButton("sys.night.plus15", label: "sys.night.plus15.label") { extendTrigger += 1; onExtend?() }
                    }
                    .padding(.horizontal, Grid.margin)
                    .transition(.opacity)
                } else if let smallHoursOffer, role == .night {                 // Noche terminada: el hueco del +15 es "Madrugada · 20 min" (C27)
                    nightButton("sys.night.smallHours", label: "sys.night.smallHours.label", action: smallHoursOffer)
                        .transition(.opacity)
                } else if let onExtend {                                         // solo si hay temporizador: Noche nunca crea uno (C47)
                    nightButton(role == .night ? "sys.night.plus15" : "sys.night.stop",
                                label: role == .night ? "sys.night.plus15.label" : "sys.night.stop") { extendTrigger += 1; onExtend() }
                } else {
                    Color.clear.frame(height: Grid.nightTarget)                  // sin temporizador: la franja queda vacía; la pantalla sigue siendo el botón
                }
            }
            .animation(.easeInOut(duration: 0.25), value: speakerOffer == nil)
            .animation(.easeInOut(duration: 0.25), value: smallHoursOffer == nil)
            .animation(.easeInOut(duration: 0.25), value: showVisibleControls)
        }
        .environment(\.nightPhase, phase)                                    // TODOS los hijos resuelven la fase (pesos ≥ Medium)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: Grid.longPress, maximumDistance: Grid.longPressSlop) {
            if role == .night, tapAllowed() { backTrigger += 1; onBack() }
        }
        .gesture(volumeDrag)                                                 // el toque vive en onEnded: sin háptica, lo confirma el sonido
        .onAppear { UIDevice.current.beginGeneratingDeviceOrientationNotifications(); activeSince = Date() }
        .onDisappear { UIDevice.current.endGeneratingDeviceOrientationNotifications() }
        .onChange(of: scene) { _, now in if now == .active { activeSince = Date() } }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.switchControlStatusDidChangeNotification)) { _ in
            assistRunning = UIAccessibility.isSwitchControlRunning || UIAccessibility.isAssistiveTouchRunning
        }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.assistiveTouchStatusDidChangeNotification)) { _ in
            assistRunning = UIAccessibility.isSwitchControlRunning || UIAccessibility.isAssistiveTouchRunning
        }
        .preferredColorScheme(.dark)                                        // la noche es siempre negra (en 1.0, toda la app: C32)
        .sensoryFeedback(.impact(weight: .light, intensity: 0.4), trigger: backTrigger, condition: { _, _ in MotionGate.allows(phase) })
        .sensoryFeedback(.selection, trigger: extendTrigger, condition: { _, _ in MotionGate.allows(phase) })
        .animation(.easeInOut(duration: 0.25), value: draggingVolume)
        .accessibilityElement(children: .contain)                            // superficie, altavoz y +15 son elementos hermanos
        .accessibilityAction(.escape) { if role == .night { onBack() } }
        .accessibilityAction(named: Text("sys.night.back")) { if role == .night { onBack() } }
    }

    private func nightButton(_ title: LocalizedStringKey, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).step(.nightAction).foregroundStyle(Ink.textNight)
                .frame(maxWidth: .infinity, minHeight: Grid.nightTarget)
                .contentTransition(.numericText())
        }
        .buttonStyle(HairlineAction.FadeStyle())
        .accessibilityLabel(Text(label))
    }
    /// Arrastre vertical = volumen maestro; 200 pt = 100 %. 24 pt mínimos y eje fijado en el primer evento
    /// (vertical si |h| > |w| × 1,73). Todo lo que no sea un arrastre vertical es un toque (en onEnded).
    /// Nunca horizontal con significado, nunca doble toque.
    private var volumeDrag: some Gesture {
        DragGesture(minimumDistance: 24)
            .onChanged { g in
                if volumeAxisFixed == nil { volumeAxisFixed = abs(g.translation.height) > abs(g.translation.width) * 1.73 }
                guard volumeAxisFixed == true, tapAllowed() else { return }
                if !draggingVolume { draggingVolume = true; startVolume = masterVolume }
                masterVolume = min(1, max(0, startVolume + Float(-g.translation.height / 200)))
            }
            .onEnded { _ in
                let wasVertical = volumeAxisFixed == true && draggingVolume
                draggingVolume = false; volumeAxisFixed = nil
                if !wasVertical, tapAllowed() { onToggle() }                  // un deslizamiento corto u horizontal cuenta como toque
            }
    }
}

/// Puerta de la háptica POR FASE (C35, 03 §3.8): de día vibra; en cualquier fase nocturna, nunca.
/// Sin CoreMotion en producción 1.0 (el spike I0-5 queda como investigación): de día no sabe si el iPhone está en la mano.
/// TODA háptica del sistema (A5, A9, A10, A11) pasa por aquí.
enum MotionGate {
    static func allows(_ phase: NightPhase) -> Bool { !phase.isNight }
}
```

### A12 · `Design/SystemStyled.swift` — palabra de estado, acción secundaria, hoja, barra, tip

```swift
import SwiftUI
import TipKit

/// Texto en versalitas paso 9, texto2, +2 %. Nunca fondo, nunca color.
/// Al cambiar de contenido anuncia el nuevo estado (VoiceOver), como promete §5b.
struct StateWord: View {
    var key: String                              // clave del catálogo; se resuelve con L.string para poder anunciarla
    @Environment(\.nightPhase) private var phase
    var body: some View {
        Text(verbatim: L.string(key)).step(.stateWord).foregroundStyle(Ink.secondary(phase))
            .contentTransition(.opacity).animation(.easeInOut(duration: 0.25), value: key)
            .onChange(of: key) { _, new in AccessibilityNotification.Announcement(L.string(new)).post() }
    }
}

/// Button .borderless, paso 6 texto2 (Medium de noche), 44 pt (64 de noche).
struct TextAction: View {
    var title: LocalizedStringKey
    var night = false
    var action: () -> Void
    @Environment(\.nightPhase) private var phase
    var body: some View {
        Button(action: action) {
            Text(title).step(.body).foregroundStyle(night ? Ink.textNight : Ink.secondary(phase))   // paso 6; Medium de noche por la fase
                .frame(maxWidth: .infinity, minHeight: night ? Grid.nightTarget : Grid.target)
        }
        .buttonStyle(.borderless)
    }
}

/// Hoja del sistema: fondo hoja, indicador real, sin Cerrar, cabecera a la izquierda + hairline.
struct SystemSheet<Content: View>: View {
    var title: LocalizedStringKey
    var detents: Set<PresentationDetent> = [.large]
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).step(.header).foregroundStyle(Ink.text)
                .padding(.horizontal, Grid.margin).padding(.top, Grid.inner).padding(.bottom, Grid.inner)
            Hairline(surface: .onSheet)
            content
        }
        .presentationBackground(Ink.sheet)
        .presentationDragIndicator(.visible)
        .presentationDetents(detents)
        // `sheetPresented` NO se pone aquí: lo pone la página que presenta la hoja sobre sí misma (§2.7, §4.4).
    }
}

/// Barra inferior: "Mezclas" · Disco · "Noche". Vidrio del sistema en 26 sin código propio.
/// Cada Text/Image fija su color: nada hereda AccentColor. El tramo de Dynamic Type llega como
/// parámetro (un @Environment en ToolbarContent no está garantizado en iOS 17).
struct BottomBar: ToolbarContent {
    var isPlaying: Bool
    var isFading: Bool
    var dynamicType: DynamicTypeSize
    var onPlay: () -> Void
    var onMixes: () -> Void
    var onNight: () -> Void
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button(action: onMixes) {
                if dynamicType >= .accessibility4 { Image(systemName: "square.stack").foregroundStyle(Ink.text) }
                else { Text("sys.bar.mixes").step(.bar).foregroundStyle(Ink.text) }
            }.tint(Ink.text).accessibilityLabel(Text("sys.bar.mixes")).accessibilityIdentifier("openMixes")
            Spacer()
            PlayDisc(isPlaying: isPlaying, isFading: isFading, action: onPlay)
            Spacer()
            Button(action: onNight) {
                if dynamicType >= .accessibility4 { Image(systemName: "circle.lefthalf.filled").foregroundStyle(Ink.text) }
                else { Text("sys.bar.night").step(.bar).foregroundStyle(Ink.text) }
            }.tint(Ink.text).accessibilityLabel(Text("sys.night"))
        }
    }
}

/// TipKit: una línea paso 7 texto2, sin fondo, imagen ni flecha. maxDisplayCount = 1.
struct LineTipStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.message?.step(.secondary).foregroundStyle(Ink.text2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Grid.margin)
            .transition(.opacity)
    }
}
/// Ningún tip en NightWindow (21:00–07:00, C40), ninguno durante la Marea, máximo uno por sesión; un solo tip en 1.0 (C65).
enum TipGate {
    static func allows(now: Date = Date(), tideActive: Bool, shownThisSession: Bool) -> Bool {
        !NightWindow.contains(now) && !tideActive && !shownThisSession
    }
}
/// Nada se vende de noche (reconciliación §1 regla 7, patrón 4.2): dentro de NightWindow o en fase nocturna el toque en una capa Pro
/// no hace nada y no deja cola (C08). Tampoco con la app fuera de .active (la hoja llegaría con la pantalla bloqueada o con Noche delante).
enum SaleGate {
    static func allows(now: Date = Date(), phase: NightPhase, scene: ScenePhase) -> Bool {
        !NightWindow.contains(now) && !phase.isNight && scene == .active
    }
}
/// Única constante horaria de la app (C40): tips, venta y reseña. La ventana de la mañana de las interrupciones (C48) es otra regla, no otra fase.
enum NightWindow {
    static func contains(_ date: Date) -> Bool { let h = Calendar.current.component(.hour, from: date); return h >= 21 || h < 7 }
}
```

---

## Anexo B · Checklist de aceptación (QA de diseño, puerta de dispositivo 03 §8.3.3)

Se pasa sobre la build de referencia con la galería (`SystemGallery`) y, en la semana 4, sobre cada pantalla de E2-E6. Cada línea tiene una prueba y un resultado binario.

**Las doce pruebas del brief (§4 de 00)**
- [ ] P1 · Dormitorio a oscuras, brillo mínimo, iPhone 17 Pro y SE: todos los componentes legibles; después en luz de tienda.
- [ ] P2 · Cinco personas a ciegas pausan y añaden quince minutos a la primera en app y bloqueo.
- [ ] P3 · Captura de la página en reposo: > 90 % de píxeles apagados; conteo de colores no grises por pantalla ≤ 1 (sin excepciones: el Toggle de Marea va en `texto`); `grep -n "AccentColor" Design/` = 0 y ningún `Text`/`Image` de botón sin `foregroundStyle` (el tinte heredado = 0 fuera del Centro de control).
- [ ] P4 · Cada fila de §5a tiene señal; con el motor silenciado el horizonte vuelve a hairline en < 1 s; Reduce Motion sin `scale`/`offset` (UI test `-UIAccessibilityReduceMotionEnabled YES`); hoja delante / fondo congela en ≤ 2 s; `grep -n "Timer" Design/` = 0 (el único reloj es el `TimelineView`).
- [ ] P5 · Una familia (`grep -nE "custom\(|design: \.rounded|design: \.serif" Design/*.swift` = 0; `grep -nE "Font\.Weight\.(light|thin|bold)|weight: \.(light|thin|bold)\)" Design/*.swift | grep -v sensoryFeedback` = 0; `grep -n "font(.system(size:" Design/*.swift` solo en el glifo del Disco); ≤ 6 estilos por pantalla (17 Medium cuenta, C67); capturas en Large, xxxLarge, AX3 y AX5 sin truncar; la galería comprueba `Font.Weight ≥ .medium` en todo `Text` de `.nightPage`, `.night` y `.smallHours`.
- [ ] P6 · Rectángulos rellenos por pantalla: 0 en la página (los dos transitorios no cuentan en reposo); ≤ 3 en cualquier otra; aire entre grupos ≥ 2 × aire interno.
- [ ] P7 · Capturas en escala de grises y con filtro rojo: suena/no suena, capa a cero, Pro y dedo se distinguen.
- [ ] P8 · Accessibility Inspector: ningún objetivo < 44; Disco, "+15 min", "Seguir por el altavoz" y acciones de Noche ≥ 64; ≥ 24 entre reglas; 32 entre los controles visibles; el botón "Volver a la página" de 1 × 1 pt no recibe toques [a medir].
- [ ] P9 · Recorrido del día 8 (abajo): de día la hoja Pro solo tras un toque en algo Pro; de noche ninguna hoja; grep `lock` en `Design/` = 0.
- [ ] P10 · Cada pantalla de E2-E6 lleva su pregunta; ningún componente necesita título para explicarse.
- [ ] P11 · Ninguna acción habitual a más de dos toques; ningún parámetro técnico a menos de una pulsación larga.
- [ ] P12 · Lista sistema / propio / por qué completa; `glassEffect` en contenido = 0; "Reducir transparencia" y "Aumentar contraste" pasados.

**Conteos de §8 del brief (por pantalla)**: familias = 1 · estilos ≤ 6 · colores no grises ≤ 1 · rectángulos rellenos (0 / ≤ 3) · hairlines como único separador · `#available` = 1 en todo el proyecto.

**Recorrido del usuario gratuito, día 8** (once texturas, C19; Océano es la capa Pro del ejemplo; 3 mezclas gratis)
- [ ] Abre: cabecera informativa (E5; geometría de 05, redacción de 08: "prueba · quedan n noches"), ninguna hoja, ningún candado; la mezcla de anoche con sus valores; "Océano" en `texto2` con "pro · 30".
- [ ] Play: suena blanco/rosa/marrón/lluvia/viento con "Hasta dormirme · 45 min" (07); estado "Sonando · sin océano" (`sys.state.playing.without`).
- [ ] Toca "Océano" (de día): sube la hoja Pro con el precio primero y "Empezar la prueba · 7 noches" (nada suena antes); cierra; todo como antes; repetible sin límite (C06).
- [ ] Activa la Marea sin acceso: hoja Pro sin guiar (C06); el toggle en `texto`; nada de la página cambia de sitio (la banda ya era de 120).
- [ ] Guarda una tercera mezcla propia gratis; la cuarta ofrece Pro sin perder la mezcla.
- [ ] Bloquea: Noche (entrada por defecto, C47); pausa y +15 a ciegas; "+15 min" con 50 min restantes → 65 min, sin hoja; al terminar, "Madrugada · 20 min" en el hueco (C27); Madrugada con Marea a 8/min sin Pro (C05).

**Recorrido nocturno del día 8 (23:30, brillo mínimo)**
- [ ] Vuelve de Noche con pulsación larga: página nocturna, una tinta; el glifo del Disco y las palabras de la barra en `textoNoche`/`texto`, nada en índice salvo bajo el dedo.
- [ ] Scroll diagonal sobre tres filas a oscuras, 10 intentos: 0 cambios de nivel.
- [ ] Toca "Océano": **no pasa nada** (ni hoja ni sonido, C08); ninguna vibración; la fila sigue en "pro · 30".
- [ ] Mañana siguiente, al abrir: ninguna cabecera matinal ni hoja (C08); la página nocturna no salió sola a las 07:00 (C40): sale al tocar el nombre.
- [ ] En Noche: un pulgar posado 0,6 s sin moverse no vuelve a la página (hay que mantener ≤ 10 pt); un deslizamiento horizontal pausa como un toque; nada vibra en la mesilla.

**Filtro rojo y escala de grises**: cada componente exportado con desaturación y con rojo (modelos A y B hasta I0-6); ningún estado desaparece.

**Dispositivo**: VoiceOver recorrido completo en ES y EN (orden de §5b; la cama no se detiene; en Noche: "Volver a la página" → superficie (ajustable: volumen) → "+15 min"); Switch Control (controles visibles aparecen solos y sustituyen a "+15 min"; "Volver a la página" operable); Button Shapes (valor subrayado, sin sliders permanentes); Acceso asistido (1.1) con disposición de un botón; Dynamic Type xS → AX5; negro (papel en 1.1); iOS 17 (SE 3), 18 (iPhone 15), 26 (17 Pro, con Reduce Transparency; el Disco con vidrio dentro de la barra [a medir]); altura real de la barra inferior y el objetivo de 64 del Disco [a medir].

**Instruments**: 10 min bloqueado con audio → 0 actividad periódica que no sea el motor (CPU por proceso; exige §0 (8): sin el tick de 4 Hz de `SleepTimerController`); pantalla encendida → interfaz ≤ 30 % del coste del motor (Energy Log + Time Profiler); Animation Hitches sin tirones > 16 ms en el arrastre.

**Puerta de formato de la propia entrega**: §10.1 marcado; cadenas de §5e idénticas a las de 10 §5e y al String Catalog de E7 (claves sin formato en el nombre; argumentos por `L.text`); hex solo de 03 §3 (grep `#[0-9A-F]{6}` contra la lista de §2.0.1); maqueta ↔ tabla ↔ listado: cada cota de §2 aparece igual en los tres sitios o lleva [a medir].

---

## 11. Respuesta al jurado

Cinco jurados, 106 hallazgos (2 bloqueantes, 52 mayores, 52 menores). Se han aplicado todos los bloqueantes y mayores que no contradicen 03 §3-§4 y los menores coherentes con la dirección. **Registro histórico (16-11, antes de la reconciliación):** donde una fila de esta tabla contradice §12 (Toggle de Marea en `texto`, sin escucha de 30 s, sin salida a las 07:00, entrada a Noche al bloquear, "Buscando…", fase "Día"), manda §12. Los rechazos, con su razón:

| Jurado | Hallazgo rechazado | Razón escrita |
|---|---|---|
| 3 de la mañana | Nivel de la escucha nocturna `min(saved ?? 50, 30)` | 03 §4.2 fija "a su nivel guardado (o 50)"; el volumen maestro, que de noche el usuario ya ha bajado, escala la escucha. Se aplica solo la parte de `SaleGate` (sin hoja de noche). |
| 3 de la mañana | "Parar" → "+10 min" en Madrugada; claves `sys.night.plus10` | 03 §4.5, §3.4 (paso 4) y §5 #11 fijan "Parar" en Madrugada. El riesgo (mismo botón, otro significado) se reconoce y se eleva al dueño en §9.5; si lo acepta, cambia 03 y entonces las claves. |
| 3 de la mañana | Página nocturna con horizonte estático (línea de 2 pt, `TimelineView` pausado) | 03 §4.1 hace que el horizonte lea el motor en la página; la página nocturna es "la misma página con una tinta" (03 §3.2). El caso "toda la noche delante" no existe: a los 60 s sin tocar la página pasa a Noche (§4.1). Se aplica la corrección de texto del jurado tipográfico (siempre `textoNoche`, nunca índice). |
| 3 de la mañana | Quitar el toque en el nombre como salida de la página nocturna | 03 §3.2 fija "vuelve a Descenso al tocar el nombre de la mezcla o a las 07:00". Queda anotado como riesgo para E2 (el nombre es también el disparador del `contextMenu`). |
| 3 de la mañana | `sys.state.fadesIn` relativo ("Se funde en %lld min") para Noche | 03 §1.3 y §5 #10 fijan la forma absoluta "Se funde a las 03:42" como estado de Noche. Una clave sin pantalla dueña es una cadena de más. |
| 3 de la mañana · high-end | Eliminar `sys.night.speaker.note` | "Nivel bajado al 40 para el altavoz" es un injerto nominal de 03 §1.3 (Dial). Se conserva; la pista se reescribe ("Suena por el altavoz al 40 %."). |
| 3 de la mañana · tipográfico · high-end | Toggle de Marea con `.tint(texto)` | 03 §1.2 y §4.12 deciden expresamente el tinte `índice` en el Toggle ("el único control del sistema que lleva el acento"). Se mantiene y se registra para el dueño en §9.14. El `Slider` sí pasa a `texto` (03 no fija su tinte). |
| 3 de la mañana | Pulsación larga de 1,0 s en Noche; 300 pt = 100 % en el volumen | 03 §4.5 y §3.8 fijan 0,6 s; la regla vertical es de 200 pt (03 §4.5), así que 200 pt = 100 %. Se aplican `maximumDistance` 10, `tapAllowed()` en los tres gestos y 24 pt con eje fijado. |
| 3 de la mañana · plataforma · high-end | Separador vertical `Hairline(axis: .vertical)` / `Rectangle` entre los controles visibles | Sería un segundo tipo de separador (03 §3.5: la hairline de margen a margen es el único). Se adopta la variante del jurado tipográfico: tres palabras de 64 pt con 32 pt de aire. |
| Tipográfico · plataforma | Adoptar la cota de 03 §3.5 ("bajo el área segura", ≈ 323 / 312) | 03 se contradice: §1.3 fija "y = 284 en 852". Se adopta 284 (la cota numérica; el usuario ve la pantalla entera) y se pide a 03 alinear §3.5 (§9.15). El layout sí se corrige (sin `UIScreen`, cabecera hasta la banda). |
| Tipográfico · plataforma | Quitar `lineSpacing` y documentar los interlineados naturales de SF (17/20, 15/18…) | 03 §3.4 fija los interlineados (17/22, 15/20, 13/18…). Se aplica la opción (2): `lineSpacing = altura objetivo − altura natural de SF`, un `UIFont` por `Text`. |
| High-end | Quitar la descomposición por pulsación larga de 1.0 (M5, `sys.sound.layers`, `decomposed`) | 03 §1.4 y §4.1 la fijan ("se descompone en una línea por capa"). Se aplica la variante que no mueve nada: líneas superpuestas dentro de la banda, sin crecimiento. |
| High-end | Hoja Pro solo si no hubo otro gesto en 30 s; línea de estado "prueba terminada · Pro" como botón | 03 §4.2 fija que a los 30 s sube la hoja. Se aplica la parte compatible: `SaleGate` (noche, fuera de `.active`) y esperar a que suelte si hay un arrastre en curso; §4.4 se reescribe para que sea verdad (la hoja es consecuencia del toque, anunciada por la pista). |
| Plataforma | Pista bajo el dedo de 56 pt (toda el área táctil) | 03 §3.5 y §4.2 fijan "pista `grafito` de 44 pt". Se alinea el código con 03: 353 × 44 en y 12→56, que termina donde empieza la línea. |
| Plataforma | Claves de §5e con el formato en el nombre ("sys.pro.saved %lld") | Se adopta la otra salida propuesta: claves sin formato y resolución con `L.text` (`Text(verbatim: String(format: String(localized:)…))`); así el catálogo de E7 y la tabla son idénticos. |
| Plataforma | `TideLine` con `var frozen: Bool` en vez de la clave de entorno | Se conserva `sheetPresented` como clave, pero la pone la página que presenta la hoja (no `SystemSheet`); `SoundLine` y `TideLine` la leen. Misma función, un parámetro menos en cada vista. |
| Honestidad | Eliminar `sys.action.looking` sin sustituto | Se sustituye por `sys.action.restoring` ("Restaurando…"), que dice lo que pasa (la otra salida que proponía el propio jurado). |

Aplicado además, fuera de las listas: el tramo de Dynamic Type llega a `BottomBar` como parámetro; `MotionGate` es función de la fase (desde la reconciliación, solo de la fase: C35); el conteo de claves de §10.1 se ha recalculado sobre la tabla.

---

## 12. Reconciliación aplicada (16-11-2026)

Fuente: `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§0–§6). Orden de aplicación 10 → **04** → 05–09 → 11 → 03 → FUNCIONES: este documento hereda el vocabulario de 10 (ya corregido) y los tokens/componentes de 03 consolidado, y es la base de 05–09. Una línea por delta que nombra a 04, por regla de todo el paquete (§3 vocabulario, §4 reparto, §5 alcance, §1 reglas 7 y 8) y por la pasada de coherencia contra 03 §3-§4 y 10 §5e. Nada de lo aplicado toca el hilo de audio más allá de lo que la propia reconciliación decide (`master` en `EngineCommand`, C51).

### 12.1 Deltas aplicados

| C | Qué cambió en 04 |
|---|---|
| C01 | Cabecera: alcance, versiones y reparto son los de la reconciliación §4-§5; §9 reescrito como lista única (cerradas marcadas "cerrada por Cnn"; abiertas con plazo: acento 27-11-2026, spikes semana 2). |
| C02 | Sin cifra escrita: "Comprar · {displayPrice}" en el wireframe y las tablas de `HairlineAction` (§2.6, §3.6), en 5b y en 5e; VoiceOver "Comprar {displayName}, {displayPrice}" (`ax.comprar`). Regla 8 ("los números son los del código") escrita en §5e. |
| C03 | Temporizador entero libre: §0 (1) (`freeTimerMinutes` y `timerIsIncluded` desaparecen; 360 tope técnico), §4.2 (sin "opción de temporizador > 60"), §2.5 / §3.5 ("+15 min" libre para todos), 5b ("Escudo" → Manto en el valor de Noche). |
| C04 | Viento libre: §0 (1), recorrido del día 8 (Anexo B) suena con viento; "once texturas" en vez de "las seis capas de main". |
| C05 | Madrugada = receta fija (océano bajo, Marea 8/min para todos, retirada hacia el minuto 13): §3.3, §4.2 punto 3 ("Madrugada nunca abre la hoja Pro"), Anexo B. |
| C06 | Sin escucha de 30 s: §0 (2), §1, §2.2 (wireframe y tabla), §3.2, §3.3 ("Guiando, 30 s de muestra" → "Pro sin acceso: el toggle abre la hoja sin guiar"), §3.7, §4.2 reescrito ("Pro sin castigo"), §4.4, M9 y M32 retiradas, 5b, 5c, 5e (`sys.pro.hint` = "Toca dos veces para ver Pro.", `sys.pro.see` = "Ver Pro"), A9 (`onPreview` → `onProTap`; acción "Ver Pro" solo de día), §7, §8, §9 #10 cerrada, Anexo B. |
| C07 | Prueba desde la hoja Pro: §0 (2) (`startTrialIfNeeded()` sale de `play()`, Keychain), §4.2 punto 3, `sys.action.startTrial` = "Empezar la prueba · 7 noches" (+ `.label`, `.hint` de 10), Anexo B. |
| C08 | Nada se vende de noche, sin cola ni línea matinal: `sys.pro.lastNight` y `sys.pro.hint.night` retiradas; M31 retirada; A9 (de noche la fila Pro no es botón, sin pista, sin acción); A12 `SaleGate` con `NightWindow`; §8; Anexo B (mañana siguiente sin cabecera). |
| C11 | "Escudo" → "Manto" (5b valor de Noche, 5e `sys.state.until` = `noche.estado.hasta`); "Escudo" solo aparece como término vetado (§5e, §10). |
| C12 | Hoja "{displayName}": `sys.action.buy.label` / `.loading.label` con `displayName` en vez de "SleepNoise Pro" escrito; sin "Desbloquear". |
| C14 | Fase "Día": `NightPhase.descent` → `.day` en A1, §2.8, M21, §4.1 ("Nunca vuelve sola a Día de noche"); "Descenso" queda reservado al ritual de Marea. |
| C15 | Toggle de Marea etiquetado "Marea" / "Tide" (`marea.titulo`), no "Marea respiratoria" / "Breathing tide" (5b, §7). |
| C19 | Tope de seis capas simultáneas como regla de modelo: §2.1 (descomposición: nunca más de seis líneas), `sys.layers.cap` = "Seis a la vez" (la pinta E2). |
| C21 | Pulsación larga → `Slider` del sistema (ajuste fino y alternativa sin gesto), §2.2, §3.2, 5c, A9; etiqueta `capas.deslizador` ("Nivel de {capa}"). |
| C22 | Manto por hora: `sys.state.until` ("hasta las %@") como estado de Noche con Manto; §0 (1) (Manto sin tope en minutos). |
| C23 | "pro · N" conserva el nivel; el motor lo ignora; la degradación nunca escribe: §2.2, §3.2, §4.2 punto 6, A9 (comentario de `savedLevel`), 5e `sys.pro.level`. |
| C24 / C34 | Marea 1.0 = profundidad común + ritual; Salud a 2.0: §4.3 ("Mi ritmo nocturno" 2.0; ritmo de partida "Empezar a 12 por minuto" como parámetro), §8. |
| C25 / C50 | Live Activity recortada solo en escenario A; "terminada → Madrugada" condicionado al spike I0-3: §4.1 (interrupciones), §9 #25; "Parar" en Madrugada se mantiene (§9 #5 cerrada: la Isla expandida que daba casa a "+10 min" ya no existe). |
| C27 | Madrugada siempre botón: "Madrugada · 20 min" ocupa el hueco del "+15 min" cuando Noche ha terminado (§2.5 wireframe y tabla, §3.5, M33, 5b, 5e `sys.night.smallHours` = `madrugada.estado`, A11 `smallHoursOffer`); sin doble toque (5c ya lo prohibía). |
| C29 / C52 | Timbre = fila `LevelRule` al pie de Capas sobre el bus maestro, extremos "Grave" / "Lejos", condicionada al spike I0-7: §1, §2.2 (wireframe y fila nueva), §3.2, 5c, 5e (`sys.layers.tone*` = `capas.timbre*`), A9 (`endpoints`), §8, §9 #24. Arrastre horizontal = nivel, vertical = scroll; el gesto de timbre no existe; "validado por spike I0-2" añadido en §2.2, §3.2, 5c, A9 y §9 #7. |
| C32 | Solo oscura en 1.0: tokens `papel`, `tinta*`, `ocre`, `trazo-papel`, `pulsado-papel`, `hoja-papel` marcados **1.1** (§2.0.1 cabecera y columnas, §1, §2.1, §2.8, §3.2, §6, A1); §9 #2 cerrada, #22-23 pasan a 1.1; Anexo B "negro (papel en 1.1)"; `preferredColorScheme(.dark)` en la raíz citado en §1, §6 y A11. |
| C35 | Háptica por fase, sin CoreMotion en producción: `MotionGate.allows(phase) = !phase.isNight` (A11, sin reloj), §7 (Mínima opt-in, Marcada al Watch 1.2, "+15 min" solo de día), §4.3, §9 #8 cerrada. |
| C39 | "Esta noche" como nombre de la mezcla viva (`sys.mix.tonight` = `mezcla.nombre.vacio`); Acceso asistido marcado 1.1 (§3.5, Anexo B). |
| C40 | Una sola constante horaria `NightWindow` 21:00–07:00 (A12, antes `NightHours` 22:00–07:00; §3.7, §4.2, §8); página nocturna por procedencia, dura la sesión, sin salida a las 07:00 (A1, §3.1, §4.1, M21, Anexo B). |
| C45 | Spikes con los nombres de la reconciliación (I0-2, I0-3, I0-5 investigación, I0-6, I0-7) en la cabecera y §9. |
| C46 / C47 | Noche entra al bloquear (opción 1 / 3 min solo desde la página), nunca crea temporizador ("+15 min" solo si existe; hueco vacío si no: §2.5, §3.5, §4.1, A11 `onExtend` opcional), duerme por defecto con "Mantener encendida", atenuada a 60 s, "atenuada" no es estado (§4.1, §8); "60 s sin tocar" eliminado de §3.1 y §4.1. |
| C48 / C49 | Regla única de interrupciones por ventana de la mañana (`CXCallObserver`) y regla de AirPods (caída de ruta 40 ms + pausa; `pauseCommand` 3 s; "Seguir por el altavoz" 60 s; reanudación capada a 0,4 solo si la ruta cambió): §2.5, §3.5, §4.1, M3. |
| C51 | Nivel maestro de sesión `EngineCommand.setMaster(level:, ramp:)` en 1.0 (§0 (5), §2.5, §9 #6); estado "Sonando · al {n}" = `sys.state.volume` (`estado.volumen`), que sustituye a `sys.night.speaker.note`. |
| C58 | "Controles visibles" como fila de Ajustes (§9 #4 cerrada); 5e `sys.night.controls` EN alineado con 10. |
| C60 | Madrugada: `sys.smallHours.value` / `.receding` ("Se retira, quedan n minutos") de 10; una tinta; cierre silencioso (5b, 5e). |
| C61 | Sin acento fuera de la app con la única excepción del tinte *on* del Control: fila `AccentColor` e `índice` de §2.0.1, A1 (`Ink.system`), §6 (filtro rojo). |
| C62 | Criterio de contraste y plan B en el token `texto` (§2.0.1, A1): ≥ 4,5 en app; fuera, ≥ 24 pt y ≥ 3:1 bajo rojo medido (spike I0-6); plan B `#F0ECE4` si < 3,5; §6 y §9 #9. |
| C63 | Horizonte = elemento de estado "Sonido" con valor (histéresis 3 s) y acción "Ver capas por separado"; `LayerChart`, `accessibilityChartDescriptor` y `sys.a11y.layersChart` eliminados (A8, §2.1, §3.1, 5b, 5c, 5e, §8, §9 #13 cerrada); Magic Tap en la raíz (ya estaba; §9 #17 cerrada). |
| C64 | "chip" vetado; el estado es `StateWord` o fila con estado en versalita (§8, §10). |
| C65 | Un solo TipKit, solo de día, lista cerrada; `TipGate` con `NightWindow` (§4.5, A12). |
| C66 | "Fila tocada: pista grafito 44 pt" añadido en §2.0.3; único `#available` confirmado; sin `glassEffect` en contenido; sin control teñido (§9 #11). |
| C67 | "17 Medium es un estilo (cuenta)" en §2.0.2, A2, §10.2 P5 y Anexo B P5; nueve pasos, ≤ 6 estilos por pantalla, principal ≤ 4 en reposo. |
| §3 vocabulario | "Escudo", "Lluvia fina" (subtítulo de Lluvia → "sobre el tejado", `capas.rain.detalle`), "Marea respiratoria", "Ajustar con deslizador" (→ "Ajuste con deslizador"), "Descenso" como fase, "Keep on the speaker" (→ "Keep playing on speaker"), "Fifteen fewer minutes" (→ "Fifteen minutes less") sustituidos; lista de términos vetados en §5e y §10. |
| §4 reparto / §5 alcance | Versiones en todo el documento: Papel 1.1, Watch 1.2, Focus filter 1.1, gestos de Marea por textura 1.1, Salud 2.0, escucha 30 s 1.1, Acceso asistido 1.1, Live Activity 1.0 solo en A; 3 mezclas gratis; 5 libres / 6 Pro; temporizador libre; Marea Pro salvo Madrugada. |
| §1 regla 7 | `SaleGate` y `TipGate` sobre `NightWindow` y fase nocturna; de noche el toque Pro no hace nada (A9, A12, §4.2). |
| §1 regla 8 | `displayPrice` / `displayName` en todas las cadenas y wireframes de compra; ninguna cifra ni nombre de producto escritos a mano. |

### 12.2 Deltas rechazados o aplicados con matiz (con razón)

| Qué | Qué se hace y por qué |
|---|---|
| Ningún delta rechazado. | Ninguno de los que nombran a 04 contradice el código del hilo de audio ni es imposible: C32, C52, C61, C62, C63, C66 y C67 están aplicados tal cual. |
| Slider por pulsación larga (03 §4.2 consolidado: "sustituye a la línea en su sitio… se retira a los 5 s"). | 04 lo ponía debajo de la fila (y 80→124, 8 s). Se adopta 03 (§2.2, §3.2, M8, A9, `Grid.sliderDismiss = 5`): el Slider ocupa el sitio de la línea dentro del área táctil y nada crece; coste: el nombre y el subtítulo quedan encima del Slider durante 5 s. |
| Grosor del horizonte sonando (03 §3.7 y §4.1 consolidados: 1,5 → 3 pt). | 04 decía 1 → 3. Se adopta 1,5 → 3 en la línea de índice (§2.1, §3.1, M2, 5d, A8); las sublíneas por capa en `texto` conservan 1 → 3 (no son índice). |
| Toggle de Marea (03 §3.1 regla 2 y §4.12 consolidados: `.tint(texto)`). | 04 mantenía `.tint(índice)` por 03 §4.12 anterior y lo elevaba al dueño (§9 #14). 03 consolidado lo cierra: `.tint(Ink.text)` en §2.7, A1, §2.0.4, §10.2 P3 y Anexo B P3; §9 #14 cerrada. Revierte la fila correspondiente de §11 (nota al pie de §11). |
| Cota del horizonte en 844 / 667 (03 §3.5 consolidado: múltiplo de 4). | 04 decía 281 / 222; 03 fija 280 / 224. Se adopta 03 (§2.0.3, §6). |
| `sys.action.restoring` ("Restaurando…", decisión del jurado de honestidad en §11). | 10 fija "Buscando…" / "Looking…" (`pro.buscando`) y 03 §4.6 lo recoge; la guía manda en vocabulario (§1 regla 4). Se usa la de 10 y se deja la propuesta en §9 #27. |
| `sys.night.speaker.hint` ("Suena por el altavoz al 40 %.") y `sys.night.speaker.note` ("Nivel bajado al 40 para el altavoz"). | No están en 10: la pista pasa a `ax.altavoz.pista` ("El volumen baja al cuarenta.") y la nota a `estado.volumen` ("Sonando · al 40", C51). Revierte una fila de §11 (nota al pie). |
| "Controles visibles de noche": tres botones (03 §4.5) frente a cuatro con "Página" (10 `ajustes.noche.controles.nota`). | Se sigue a 03 §4 (componentes): tres de 64 pt más el botón "Volver a la página" para Switch Control; discrepancia anotada en §9 #29 para E4 y E7. |
| `sys.night.value` con tres variantes (duración / Manto / sin temporizador). | 10 tiene una sola (`ax.noche.valor` "%@. %@": hora + estado); el estado de E4 ya lleva "Se funde a las…", "hasta las…" o "En pausa". Se reduce a una clave; `.until` y `.noTimer` retiradas. |
| C25 "cuatro estados" frente a C50 "seis estados" de la Live Activity. | No es de 04; se cita C50 (la ficha específica) en §4.1, como hace 10 (12.2). |

### 12.3 Pasada de coherencia (03 §3-§4 consolidado, 10 §5e, maqueta)

- **Hex**: ningún hex nuevo; los de §2.0.1 son los de 03 §3.1 y §3.3; el plan B de `texto` (`#F0ECE4`) y las variantes AC "por decisión" (03 §3.1) anotados; papel marcado 1.1.
- **Medidas y estilos**: horizonte 284 / 280 / 224; banda 24 / 120; fila de capa 80 = 56 + 24; pista grafito 44; Disco 44 en 64; "+15 min" 64; Slider 44 en el sitio de la línea; nueve pasos, ≤ 6 estilos (17 Medium cuenta), principal ≤ 4; hairline 1/escala; hairlines de "Comprar" 1,5 pt; índice ≥ 1,5 pt.
- **Componentes**: los seis propios de 03 §4.1-4.6 con los mismos nombres (`SoundLine`, `LevelRule`, `TideLine`, `PlayDisc`, `FullScreenControl`, `HairlineAction`) y el sistema con estilo de §4.7-4.13 (`EditorialRow`, `StateWord`, `TextAction`, hoja, barra, Toggle en `texto`, TipKit).
- **Hoja Capas**: `.large` sobre `negro`, hairlines `trazo`, barra inferior debajo (03 §4.10 consolidado; §2.7).
- **Cabecera de la página**: geometría de 05; redacción de la prueba de 08 / 10 ("prueba · quedan n noches", `pro.prueba.estado`; aparece solo desde que la prueba empieza, C07) (§4.2, Anexo B).
- **Mezcla viva**: "Esta noche" / "Tonight" (reconciliación §3; `sys.mix.tonight`); no es una pantalla.
- **Fila Temporizador en el primer uso**: 07 manda: "Temporizador · Hasta dormirme · 45 min" (§2.7, Anexo B); nunca "pro" en el temporizador (C03).
- **Cadenas**: las 107 claves vivas de §5e coinciden letra a letra con 10 §5e (columna "Clave en 10"); 9 retiradas o absorbidas; 6 pendientes de E7 en §9 #26-31.
- **Reparto y versiones**: idénticos a la reconciliación §4 y §5 (ver fila "§4 reparto / §5 alcance" de 12.1).
- **Código del hilo de audio**: ningún listado del Anexo A añade parámetros a `RenderState`; `master` con rampa en `EngineCommand` es decisión de C51; `MotionGate`, `NightWindow` y `SaleGate` viven en la interfaz.
