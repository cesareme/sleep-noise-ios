# Concepto "Grafito" · SleepNoise

**Equipo Grafito · concepto de diseño · 16 de noviembre de 2026**
Linaje: Bear (Red Graphite llevado a la noche), Things 3, iA Writer, Pentagram editorial. Insumos leídos completos: brief creativo (00), auditoría de referencias (01), materiales (02), resumen ejecutivo y sección 6 del informe de mercado, capturas de `main` y del PR #3. El plan de funciones priorizadas no existía al escribir; el alcance es el que fija el encargo (pantalla principal, mezclador, Marea, temporizador de tres modos, Noche, Madrugada, noches guardadas, paywall y prueba, primer uso, "Qué sabemos y qué no", Live Activity/Dynamic Island/StandBy, widgets, Centro de control, Watch mínimo, icono y capturas).

Maqueta estática: `scratchpad/design/concepts/grafito.html` (ocho pantallas de 393×852, un marco de StandBy con tinte rojo y la Live Activity/widget).

---

## 0. Postura y tesis

**Somos sobre todo editorial: SleepNoise es una página, no un panel.** De las tres fuerzas del brief (§5) manda la A, el minimalismo Bear; el instrumento (B) se expresa como tipografía con peso y como una sola línea que dice la verdad del sonido; la noche (C) es la misma página con la tinta bajada, no otra app. La tesis en un párrafo: *Red Graphite, el tema que los usuarios de Bear piden en negro desde 2024 y que nadie ha hecho, aplicado a una app que casi no tiene texto. Papel negro, tinta de papel cálido, un rojo grafito que nunca rellena nada: solo subraya, dibuja un trazo o marca "ahora". La interfaz es una columna de texto con hairlines de 0,5 pt; el mezclador es una lista editorial en la que el nivel de cada capa es la regla fina bajo su nombre, y se arrastra sobre la propia fila como se subraya una línea con el dedo. El Play no es un disco: es un trazo de 1,5 pt. Lo que suena se ve en una sola línea roja que recorre la columna como el trazo de un sismógrafo lento; cuando nada suena, esa línea es una hairline gris quieta: el silencio dibujado. A las 3 de la mañana la página pierde el texto y queda el reloj, la línea y un gesto. El lujo está en el ritmo vertical, los márgenes de 20 pt, el peso de las palabras y todo lo que se ha quitado.* Lo que se sacrifica a propósito: densidad de instrumento a la vista (las cifras existen, pero aparecen al tocar), cualquier forma rellena de color, y el ámbar de la app actual (que es el color de medio sector y el de los paywalls que el usuario hispano llama estafa).

---

## 1. Identidad

### 1.1 Paleta nocturna (tokens exactos)

Ratios WCAG 2.x calculados con luminancia relativa (script de la sesión). "Rojo A" es el color tras un filtro que conserva solo el canal R (modelo A de StandBy nocturno); "Rojo B" tras un filtro que pinta la luminancia en rojo (modelo B). Apple no publica la matriz; se diseña para que funcione en los dos **[a medir en dispositivo]**.

| Token | Hex | Sobre `negro` | Sobre `grafito` | Rojo A → ratio | Rojo B → ratio | Uso |
|---|---|---|---|---|---|---|
| `negro` | `#000000` | — | — | — | — | Fondo de toda superficie, también de las hojas. Píxel apagado. |
| `grafito` | `#1C1C1E` | 1,23 | — | — | — | Único relieve: fondo de una fila **mientras está pulsada** (200 ms) y pista del control de nivel bajo el dedo. Nunca como tarjeta ni como fondo de hoja. |
| `trazo` | `#2C2A28` | 1,47 | 1,19 | 1,11 | 1,10 | Hairline de 0,5 pt (1 px físico). Decorativa: no transmite información. Es el "gris cálido" de la regla en reposo. |
| `texto` | `#E8E4DC` | **16,56** | 13,42 | `#E80000` **4,43** | `#E40000` **4,30** | Texto principal, cifra del reloj, regla de nivel activa, glifos de Live Activity y StandBy. Es la **única tinta** de las superficies del sistema. |
| `texto2` | `#9C9A96` | **7,48** | 6,06 | 2,41 | 2,37 | Secundario, subtítulos de capa, estado, notas. Nunca en StandBy/Live Activity/widget. |
| `texto3` | `#6E6C68` | **4,01** | 3,25 | 1,66 | 1,64 | Solo ≥ 18 pt o elementos no textuales de ≥ 3 pt (pista vacía del nivel, "Pro" nunca). Cumple 3:1 de componente. |
| `grafito-rojo` | `#E0524D` | **5,48** | 4,44 | `#E00000` **4,17** | `#700000` 1,69 | **El acento.** Solo en líneas (≥ 1 pt), glifos (Play, pausa, "ahora") y texto grande (≥ 18 pt o ≥ 14 pt Semibold). Nunca relleno, nunca cuerpo de texto, nunca en destructivo ni error, **nunca en superficies del sistema** (porque muere bajo el modelo B). |
| `grafito-rojo-ac` | `#FF7A75` | 8,29 | 6,72 | `#FF0000` 5,25 | 2,30 | Variante de "Aumentar contraste" del acento (asset catalog, High Contrast). |
| `texto2-ac` | `#B4B2AE` | 9,92 | — | — | — | Variante de contraste aumentado de `texto2`. |
| `error` | sistema `.secondaryLabel` + hairline | — | — | — | — | No hay rojo de error: un fallo de sesión de audio es una línea de texto en `texto2` bajo la regla ("No se pudo iniciar el audio. Toca para reintentar."). El rojo es nuestro, no el del sistema. |

Decisiones que fija la tabla:

- **Negro en todas partes, hojas incluidas.** Una hoja en Grafito es otra página negra que sube con la esquina del sistema y una hairline `trazo` en su borde superior; el sistema ya atenúa la página de detrás. No existe el `#1C1C1E` de "hoja elevada" de 02-Materiales porque es la única concesión a la caja que este concepto rechaza (Bear separa el panel de la nota con una línea, no con otro gris). `grafito` queda reservado al estado pulsado.
- **El acento es rojo grafito, no brasa.** `#E0524D` es el rojo de Red Graphite desaturado y bajado para que no sea el `systemRed` (`#FF453A`): 5,48:1 sobre negro, AA en texto normal y sobrado en líneas. Sobrevive al modelo A de StandBy (4,17:1, apto para formas y texto grande) y **no** al modelo B (1,69:1). La consecuencia es una regla, no una excepción: **en StandBy, Live Activity, widgets y Watch no hay acento**; todo es `texto` y el estado se lee por forma. Es exactamente lo que Bear hace fuera del editor (sus widgets son monocromos) y lo que la HIG pide para Night Mode.
- **Blanco nunca puro.** `texto` es el papel cálido de la app actual: es lo que mejor sobrevive al rojo (canal R alto).
- **Colores por pantalla:** negro + tres grises + un acento. En la pantalla principal el acento aparece en **un** elemento: la regla del sonido mientras suena (y el trazo del Play, que forma parte del mismo sistema: trazo = acción, línea = estado; se admite como un único "color de instrumento" porque nunca coexisten dos superficies rojas).

### 1.2 Paleta de día ("papel")

Sigue la apariencia del sistema; no hay selector propio. Es la app de concentración del segmento 3.

| Token | Hex | Sobre `papel` | Uso |
|---|---|---|---|
| `papel` | `#F3F0E9` | — | Fondo |
| `tinta` | `#1E1C19` | **14,94** | Texto principal, regla activa |
| `tinta2` | `#5F5A53` | **6,00** | Secundario |
| `grafito-rojo-día` | `#9E3733` | **6,05** | Acento (mismas reglas: líneas, glifos, texto grande) |
| `trazo-papel` | `#D8D3C9` | 1,31 | Hairline |
| `pulsado-papel` | `#E9E5DC` | 1,10 | Fila pulsada |

### 1.3 Tipografía

Dos familias, las dos del sistema, con papeles que no se cruzan:

- **SF Pro** es el instrumento: toda la interfaz, todos los controles, todas las cifras, toda la noche. Text/Display se eligen solos; `monospacedDigit()` en toda cifra; versalitas reales (`.smallCaps()`) para estado; nunca `uppercased()`.
- **New York** es la voz: aparece únicamente en (a) el **nombre de la mezcla** en la pantalla principal y en la lista de noches guardadas (la etiqueta escrita a mano en el bote), (b) el **titular del paywall** y (c) el **texto de lectura larga** de "Qué sabemos y qué no". Nunca en un control, nunca en una cifra, nunca en la pantalla Noche, nunca por debajo de 19 pt (las serifas finas se pierden a brillo mínimo). Con esto, la pantalla principal tiene dos familias (título + interfaz) y todas las demás, una, salvo las de lectura.
- SF Pro Rounded no se usa. La cifra grande va en SF Pro Display Regular con tracking −1 %: a 72 pt la Display ya es suave, y Rounded es el código tipográfico del wellness (01-Referencias §5.3) que este concepto evita.
- SF Mono no se usa en la interfaz. Las lecturas técnicas (dB estimados, respiraciones por minuto exactas) van en SF Pro Medium tabular: el monoespaciado es la voz de Teenage Engineering, no la de Bear.

Escala (tamaño Large; `relativeTo` indica el estilo con el que escala; "Noche" indica el peso mínimo cuando la superficie se opera a oscuras):

| Paso | Uso | Familia · peso | pt / interlineado | relativeTo | Noche | Color |
|---|---|---|---|---|---|---|
| 1 · Cifra | Reloj de Noche, cuenta atrás grande, precio | SF Pro Display Regular, tabular, tracking −1 % | 72 / 80 (Noche); 56 / 64 (precio, temporizador) | `.largeTitle`, tope `.accessibility2` | Regular (≥ 20 pt) | `texto` |
| 2 · Nombre | Nombre de la mezcla, titular del paywall | **New York Medium** | 28 / 34 | `.title1` | — (no aparece de noche) | `texto` |
| 3 · Cabecera | Título de hoja ("Temporizador", "Marea respiratoria") | SF Pro Semibold | 22 / 28 | `.title2` | Semibold | `texto` |
| 4 · Fila | Nombre de capa, nombre de ajuste, botón primario | SF Pro Semibold | 17 / 22 | `.headline` | Semibold | `texto` |
| 5 · Cuerpo | Explicaciones de una línea, botón secundario | SF Pro Regular | 17 / 24 | `.body` | Medium | `texto` / `texto2` |
| 6 · Lectura | "Qué sabemos y qué no", nota larga del paywall | **New York Regular** | 19 / 28 | `.body` | — | `texto` |
| 7 · Secundario | Subtítulo de capa ("lluvia fina"), estado de fila | SF Pro Regular | 15 / 20 | `.subheadline` | Medium | `texto2` |
| 8 · Nota | Pie, nota de fundido, "no es un producto sanitario" | SF Pro Regular | 13 / 18 | `.footnote` | Medium | `texto2` |
| 9 · Dato | Valor de nivel, minutos, versalitas de estado ("pro", "prueba · 5 noches", "guiando") | SF Pro Medium tabular; versalitas con tracking +2 % | 13 / 18 | `.footnote` | Medium | `texto2` (`texto` si ≥ 18 pt) |

Nada por debajo de 13 pt; nada Light/Thin; Bold nunca; nada en mayúsculas sostenidas; máximo seis estilos por pantalla (la principal usa 2, 4, 7, 9 y el Play). Dynamic Type de xSmall a AX5: a partir de AX1 la fila de capa pasa de "nombre + valor en línea" a "nombre arriba, valor debajo" con `ViewThatFits`; la regla de nivel conserva su grosor en puntos (`@ScaledMetric` solo para la altura de la fila, no para la línea).

### 1.4 Espaciado, hairline, radios

- Retícula de 4 pt. Margen lateral **20 pt** (columna de 353 pt en 393). Margen superior del contenido 16 pt bajo la barra de estado (no hay barra de navegación en la principal).
- Fila simple 56 pt; fila con subtítulo y regla 72 pt; fila de capa en mezclador 76 pt (nombre 22 + subtítulo 20 + regla 1 + aire). Separación entre grupos 32 pt, el doble del aire interno (16): la agrupación se hace con espacio y una hairline, nunca con cajas (P6).
- **Hairline: 0,5 pt lógicos = 1 px físico** (`1 / displayScale`), color `trazo`, de margen a margen (no se interrumpe bajo el texto). Es el único separador. En papel, `trazo-papel`.
- **Regla de nivel: 1 pt** en `texto`; mientras se arrastra, 1,5 pt en `grafito-rojo`. **Regla del sonido (envolvente): 1 pt** en `grafito-rojo`; en reposo, la misma hairline `trazo`.
- Radios: **0** en todo lo propio. El único radio es el de la hoja del sistema y el del contorno del botón primario del paywall (8 pt, hairline roja). Objetivos táctiles sin forma visible: 44 × 44 mínimo, 64 en Play, Noche y Madrugada; 24 pt de aire entre objetivos sin borde.
- Sombras: ninguna. Degradados: ninguno. Materiales: solo el de la barra inferior (sistema).

### 1.5 Iconografía

- En el mezclador y en la principal **no hay iconos de sonido**: las palabras son los iconos.
- SF Symbols monocromos, peso Regular a 20 pt, solo en la barra inferior: `timer` (temporizador), `square.stack` (noches guardadas), `moon.zzz` **prohibido** (cliché): la entrada a Noche es la palabra "Noche" (texto 17 Medium) en la barra. Estados por variante (`.fill` = activo), nunca por color.
- Glifos propios dibujados como símbolos personalizados (plantilla SF Symbols, 9 pesos): **Play** (triángulo trazado de 1,5 pt, 28 pt de alto, vértices sin redondear), **Pausa** (dos trazos verticales de 1,5 pt, 24 pt, separados 8 pt), **Marea** (la "línea de agua": un trazo horizontal con una elevación asimétrica 4:6), **pendientes espectrales** de blanco / rosa / marrón (línea plana, −3 dB/oct, −6 dB/oct) para widgets, Centro de control y Atajos.
- Sin `lock`, sin `checkmark.seal`, sin `gift`, sin `hourglass`, sin `crown`. El estado es una palabra en versalitas.

### 1.6 Movimiento y háptica (lo que cambia respecto a 02-Materiales)

Se adopta íntegro 02 §3 y §4 (tres causas: respiración, fundido, nivel; 200-250 ms controles; 800 ms arranque; 1,5-2 s parada; sin springs; Reduce Motion → opacidad; `.selection` al cruzar 0, `.impact` medio al arrancar, nada al terminar el temporizador). Lo propio de Grafito: la regla del sonido se dibuja como **trazo que avanza de izquierda a derecha** a 20 Hz con una ventana de 20 s (la línea "escribe"); bajo Reduce Motion, se congela en una línea cuyo grosor (1-2 pt) sigue el nivel maestro a 4 Hz; bajo `isLuminanceReduced`, hairline quieta en ≤ 2 s.

---

## 2. Sistema de componentes

Convención: cada componente lista sus estados **normal / activo / bloqueado-Pro / prueba / deshabilitado / VoiceOver**. Columna "sistema / propio": qué se construye.

### 2.1 Fila editorial (`EditorialRow`) · propio, sobre `List` del sistema

La unidad de toda la app. Texto a la izquierda (paso 4), subtítulo opcional (paso 7), valor o estado a la derecha (paso 9 o 7), hairline inferior de margen a margen. Altura 56 / 72. Sin fondo, sin chevron salvo cuando empuja una pantalla (entonces `chevron.right` en `texto3`, 13 pt).

| Estado | Expresión |
|---|---|
| Normal | Nombre `texto`, subtítulo `texto2`, valor `texto2`, hairline `trazo`. |
| Activo (seleccionado en una lista de opciones) | Nombre `texto` Semibold; a la derecha `checkmark` 17 pt en `texto` (convención del sistema). En listas de opciones no hay rojo. |
| Pulsado | Fondo `grafito` durante la pulsación (200 ms, `.easeInOut`). |
| Bloqueado-Pro | Nombre en `texto2` en vez de `texto`; a la derecha la palabra "pro" en versalitas `texto2`. Todo lo demás igual. Sin opacidad, sin candado. Al tocar: la función **se ejecuta 30 s** (capa suena / Marea guía / temporizador largo corre) y sube la hoja Pro con el precio en la primera línea. |
| Prueba | Idéntico a Normal (todo abierto). La prueba se dice una sola vez en la cabecera. |
| Deshabilitado | Solo existe para "Guardar" sin cambios: texto `texto3` (≥ 18 pt no se da; se compensa con `accessibilityHint` "Sin cambios que guardar"). |
| VoiceOver | Un elemento: "Lluvia, lluvia fina, 40 por ciento, ajustable" o "Trueno, requiere Pro, botón; toca para escuchar 30 segundos". |

### 2.2 Regla de nivel (`LevelRule`) · propio

El control de volumen de una capa. **No es un slider con pulgar:** es una línea de 1 pt bajo el nombre, de margen a margen, cuya parte dibujada en `texto` es el nivel y cuya parte restante es hairline `trazo`. Toda la fila (76 pt) es el área de arrastre; un arrastre horizontal cambia el nivel (1 pt = 1/333 del recorrido, 353 − 20 de reserva), un toque alterna 0 ↔ último valor. Es el scrub de la TP-7 convertido en subrayado.

| Estado | Expresión |
|---|---|
| Normal (nivel > 0) | Regla `texto` 1 pt hasta el nivel; resto hairline. Valor "65" en paso 9 a la derecha. |
| Normal (nivel 0) | Solo hairline. Nombre en `texto` igualmente (la capa existe; no está "apagada", está a cero). Valor oculto. |
| Activo (bajo el dedo) | Regla pasa a **1,5 pt `grafito-rojo`**; el valor crece a 17 pt `texto` tabular junto al dedo; pista `grafito` de 44 pt de alto visible solo durante el arrastre (es la única forma rellena de la app y dura lo que el gesto). Háptico `.selection` al cruzar 0, `.impact(.light)` al llegar a 100. Pulsación larga: aparece bajo la fila una segunda línea "Timbre · más cálido ◂ ▸ más lejano" (P11), hairline con dos palabras; el gesto es el mismo arrastre. |
| Bloqueado-Pro | Hairline completa `trazo`, nombre `texto2`, "pro" versalitas. Arrastrar no mueve nada; tocar dispara la previsualización de 30 s (la regla se dibuja en `texto2` esos 30 s y vuelve a cero). |
| Prueba | Como Normal. |
| Deshabilitado | No existe (nada deshabilita el sonido). |
| VoiceOver | `.adjustable`, pasos del 5 %, acciones "Silenciar" y "Máximo"; anuncio "Lluvia, 40 por ciento". `AXChartDescriptor` opcional con la envolvente de la capa. |

**Geometría alternativa B** (entregable 9.1.9 del brief): el mezclador como **una sola regla** de 11 segmentos verticales de 1 pt a lo ancho de la columna, uno por capa, con el nombre girado 90°; un dedo arrastra en vertical el segmento que toca. Se descarta para 1.0 porque no escala con Dynamic Type ni se lee a un metro; se documenta como "vista compacta" posible en Watch.

### 2.3 Botón primario (`StrokeAction`) · propio, encapsula `.borderedProminent` en iOS 17

- **Play / Pausa** (pantalla principal y Noche): glifo propio trazado de 1,5 pt en `grafito-rojo` (triángulo 28 pt; pausa 24 pt). Objetivo 64 × 64 invisible. Transición play ↔ pausa con `.contentTransition(.symbolEffect(.replace))` (fundido). En iOS 26 vive en la barra inferior como único control teñido (`.glassProminent` no se usa: el prominente es el **trazo**, no el fondo; se usa `.tint(grafito-rojo)` sobre `.borderless`). En Noche y Madrugada el Play no es un botón: es toda la pantalla (2.9).
- **Acción de hoja** ("Comprar · 29,99 €", "Empezar la prueba", "Guardar"): fila de 56 pt de alto, texto 17 Semibold `texto`, contorno hairline de **1 pt `grafito-rojo`**, radio 8. Una por pantalla.

| Estado | Expresión |
|---|---|
| Normal | Trazo rojo, texto `texto`. |
| Pulsado | Trazo 1,5 pt, 150 ms; háptico según acción. |
| Bloqueado-Pro | No aplica: el primario nunca está bloqueado (P9). |
| Prueba | Idéntico. |
| Deshabilitado | Trazo `texto3`, texto `texto2`; solo en "Comprar" mientras StoreKit carga el precio ("Cargando precio…"). |
| VoiceOver | "Reproducir, botón" / "Comprar SleepNoise Pro por 29,99 euros, botón". |

### 2.4 Botón secundario (`TextAction`) · sistema (`.borderless`)

Texto 17 Regular `texto2` (con "Button Shapes" activo, el sistema le pone contorno). "Restaurar compra", "Ahora no", "Entendido", "+15 min". Nunca rojo. Objetivo 44 pt; 64 en Noche ("+15 min").

### 2.5 Chip de estado (`StateWord`) · propio (es texto)

No hay cápsulas. El estado es una palabra en versalitas, paso 9, `texto2`, tracking +2 %: "prueba · 5 noches", "pro", "guiando", "disolviendo", "en pausa", "se funde a las 00:42". Nunca color, nunca fondo. Variante grande (17 Medium `texto`) en Noche: "en pausa".

| Estado | Palabra ES | Palabra EN |
|---|---|---|
| Prueba activa | prueba · quedan 5 noches | trial · 5 nights left |
| Última noche | prueba · última noche | trial · last night |
| Gratis tras prueba | gratis · blanco, rosa, marrón, lluvia y 60 min | free · white, pink, brown, rain and 60 min |
| Función Pro en fila | pro | pro |
| Pro comprado | (nada) | (nothing) |
| Marea | guiando · 6 por minuto / disolviendo | guiding · 6 per minute / dissolving |
| Sesión | sonando / en pausa / fundiendo | playing / paused / fading |

### 2.6 Hoja (`Sheet`) · sistema

`.sheet` estándar con `presentationDetents([.medium, .large])` donde proceda, `presentationBackground(negro)`, indicador de arrastre del sistema, **sin botón "Cerrar"** (se cierra arrastrando o con el gesto del sistema; en iOS 26, el botón de cierre del propio sistema). Dentro: cabecera paso 3 alineada a la izquierda a 20 pt, hairline, lista. Nada relleno. Todas las hojas respetan Reduce Transparency solas.

### 2.7 Barra (`BottomBar`) · sistema

`ToolbarItemGroup(placement: .bottomBar)`: izquierda "Noches" (texto 17 Medium `texto`, abre las noches guardadas), centro Play (2.3), derecha "Noche" (texto 17 Medium, entra en la pantalla Noche). En iOS 26 el sistema le pone vidrio regular; bajo él pasa la regla roja cuando se desplaza (la única razón de que el vidrio se vea). En iOS 17-18, material `bar` sobre negro + hairline `trazo` encima. VoiceOver: "Noches guardadas, botón", "Reproducir, botón", "Pantalla de noche, botón".

### 2.8 Visual del sonido: la regla (`SoundRule`) · propio

Una línea horizontal de margen a margen, 24 pt de banda, bajo el nombre de la mezcla.

- **Reposo (nada suena):** hairline `trazo` recta. Es el silencio dibujado; en la tienda, con el sonido apagado, se ve una página con una línea fina, y eso es verdad.
- **Sonando:** trazo de 1 pt `grafito-rojo` que **escribe** de izquierda a derecha la suma de las envolventes RMS reales por capa (hilo de audio, mismo seqlock que `SoundGains`, ≤ 20 Hz, τ 400-800 ms), amplitud máxima ±10 pt, ventana de 20 s; al llegar al margen derecho la línea se desplaza (como un sismógrafo), no se borra. Opacidad 0,55 + 0,45 × nivel maestro.
- **Fundiendo:** la misma línea pierde amplitud hasta quedar recta y, al terminar, pasa a `trazo` en 1,5-2 s.
- **Marea activa:** la línea del sonido **es** la línea de agua (2.9): no hay dos indicadores.
- **Pulsación larga:** se descompone en una línea por capa (hasta 11, 0,5 pt cada una, `grafito-rojo` con opacidad por nivel), la transparencia de Halide; se recompone al soltar.
- **Reduce Motion:** línea recta cuyo grosor (1-2 pt) sigue el nivel maestro a 4 Hz con τ 1,5 s. **`isLuminanceReduced` / Noche / fondo:** congelada a hairline en ≤ 2 s; `TimelineView(.periodic(by: 1/20))` sobre un `Canvas` aislado, `paused` cuando no suena, cuando `scenePhase != .active` y en Noche.
- **Bloqueado-Pro / prueba / deshabilitado:** no aplica (el sonido nunca se bloquea).
- **VoiceOver:** "Sonando, nivel medio" / "En silencio"; rotor "Audio Graph" con la envolvente.

Prueba del nueve: si se silencia el motor, la línea queda recta en < 1 s porque lee el motor, no un reloj.

### 2.9 Forma de la Marea: la línea de agua (`TideLine`) · propio

No es un círculo (código ocupado por Apple Breathe, Balance, Breathwrk). Es **una línea horizontal que sube y baja dentro de una banda de 120 pt**, como el nivel del agua en una regla de marea: sube 4 s (inhalación) hasta el borde superior, baja 6 s (exhalación) hasta el inferior, con la misma `BreathCurve` que modula el audio (nunca una `sin()` de la vista). Grosor 1 pt `grafito-rojo` en la app; 1,5 pt `texto` en Watch y Live Activity. Dos marcas hairline `trazo` fijas en los extremos de la banda (pleamar / bajamar). A su derecha, en paso 9, la palabra de fase: "inhala" / "exhala" (`texto2`), que desaparece a las tres respiraciones (ya no hace falta mirar).

| Estado | Expresión |
|---|---|
| Apagada | No se dibuja; en su lugar la regla del sonido (2.8). En la fila de Marea: toggle del sistema en off. |
| Guiando | Línea subiendo/bajando a la frecuencia real (4-8/min), palabra "guiando · 6 por minuto" en versalitas bajo el nombre de la mezcla. |
| Disolviendo | Amplitud decreciente durante los últimos 20 % de la duración; palabra "disolviendo". Al terminar, la línea se queda en bajamar 2 s y vuelve a ser la regla del sonido. |
| Bloqueado-Pro (tras la prueba) | La fila "Marea respiratoria" conserva el toggle; al activarlo, guía **30 s** y sube la hoja Pro ("pro" en versalitas junto al nombre mientras tanto). |
| Prueba | Normal. |
| Reduce Motion | La línea no se mueve; su opacidad respira (0,45 → 1,0) con la misma curva. |
| `isLuminanceReduced` | Quieta en bajamar. |
| Háptica (opt-in "Mínima" / "Marcada") | Core Haptics continuo siguiendo `BreathCurve`, solo las 3-5 primeras respiraciones y solo si el iPhone se sostiene (CoreMotion); en Watch, `.directionUp` al inicio de cada inhalación. |
| VoiceOver | "Marea respiratoria, guiando, seis respiraciones por minuto, se retira en catorce minutos"; anuncios "inhala"/"exhala" opcionales (ajuste en la hoja). |

### 2.10 Pantalla como botón (`FullScreenControl`) · propio

En Noche y Madrugada toda la superficie es el control: toque = pausa/reanuda (háptico ninguno: lo confirma el sonido), arrastre vertical = volumen maestro (aparece una regla vertical de 1 pt `texto` de 200 pt a la derecha mientras dura el gesto), pulsación larga 0,6 s = salir. `+15 min` es un botón de texto de 64 pt en la parte inferior. Funciona en Acceso guiado y Acceso asistido.

---

## 3. Pantallas y superficies

Medidas en puntos para iPhone de 393 × 852 (área segura: 59 arriba, 34 abajo), tamaño Large, español; textos EN entre corchetes. "Toca →" describe la acción.

### 3.1 Pantalla principal · en reposo

Pregunta: *¿qué va a sonar?*

| y | Elemento |
|---|---|
| 0-59 | Barra de estado del sistema. Sin barra de navegación, sin título de app, sin logotipo. |
| 76 | **Cabecera editorial**, paso 9 versalitas `texto2`, izquierda: "prueba · quedan 5 noches" ["trial · 5 nights left"]. Derecha: nada. Con Pro: la línea desaparece y todo sube 24 pt. Toca → hoja "SleepNoise Pro" (3.9). |
| 104 | **Nombre de la mezcla**, New York Medium 28/34 `texto`: "Rosa y lluvia" ["Pink and rain"]. Nombre generado de las capas > 0 hasta que el usuario lo escribe; el campo es editable con un toque (teclado del sistema; es la única entrada de texto de la app). Pulsación larga → menú del sistema: "Guardar como noche…", "Renombrar", "Vaciar la mezcla" ["Save as a night…", "Rename", "Clear mix"]. |
| 146-170 | **La regla** (2.8) en reposo: hairline `trazo` recta a y = 158. |
| 178 | Línea de estado, paso 7 `texto2`: "En silencio" ["Silent"]. |
| 226 | Hairline. **Lo que suena**: una fila por capa con nivel > 0 (máx. 4; si hay más, "y 2 capas más" como fila). Fila 76 pt: "Rosa" Semibold 17 + "suave y equilibrado" 15 `texto2`; derecha "65" paso 9; regla de nivel al 65 % en `texto` a y = fondo de fila − 16. Arrastre horizontal → cambia el nivel aquí mismo (no hace falta abrir el mezclador). |
| 302 | "Lluvia" / "lluvia fina" / "40" / regla al 40 %. |
| 378 | Fila 56: "Todas las capas" ["All layers"] `texto` + chevron `texto3`; subtexto a la derecha "11" paso 9. Toca → mezclador (3.3) como pantalla empujada. |
| 466 | Grupo 2 (32 pt de aire): fila 56 "Marea respiratoria" ["Breathing tide"] + Toggle del sistema (tinte `texto2`; en on el pulgar lo dice por posición). Subtítulo 15 `texto2`: "Apagada" ["Off"] / "6 por minuto · se retira a los 15 min" ["6 per minute · fades at 15 min"]. Toca el texto → hoja Marea (3.4). |
| 522 | Fila 56 "Temporizador" ["Timer"] + estado a la derecha paso 7 `texto2`: "Apagado" ["Off"] / "Hasta dormirme · 45 min" ["Until I fall asleep · 45 min"]. Toca → hoja Temporizador (3.5). |
| 578-760 | Aire. Nada. (En Dynamic Type grande este aire se consume; la lista desplaza; la barra se queda.) |
| 769-818 | **Barra inferior**: "Noches" (izq.) · Play trazado rojo 28 pt en objetivo 64 (centro) · "Noche" (der.). |

Toca Play → arranque en 800 ms: la regla pasa de hairline a trazo rojo escribiendo, la línea de estado pasa a "Sonando" y el glifo a pausa. Háptico `.impact(.medium, 0.7)`. Si no hay ninguna capa > 0, Play sube Rosa a 50 (la mezcla por defecto) y lo dice en la línea de estado: "Sonando · rosa a 50" (nunca una alerta).

Primer uso (3.10): esta misma pantalla, sin nada encima.

### 3.2 Pantalla principal · sonando, con temporizador y Marea activa

Lo que cambia respecto a 3.1:

- Cabecera: "prueba · quedan 5 noches" se mantiene (no crece).
- Regla (146-170): trazo rojo escribiendo la envolvente; con la Marea activa, la regla es la línea de agua en una banda de 120 pt (146-266), y lo de abajo baja 96 pt. A la derecha de la banda, "inhala" ["breathe in"] paso 9 durante las tres primeras respiraciones.
- Línea de estado: "Sonando · se funde a las 00:42" ["Playing · fades at 00:42"]; con Marea: segunda línea en versalitas "guiando · 6 por minuto · se retira a las 23:27" ["guiding · 6 per minute · fades at 23:27"].
- Fila Temporizador: "Hasta dormirme · quedan 38 min" ["Until I fall asleep · 38 min left"], cifra tabular que cambia por minuto (no por segundo: nada parpadea).
- Play → pausa (dos trazos rojos). Toca → fundido de 1,5 s; estado "En pausa"; la regla vuelve a hairline en 2 s.
- Al bloquear el iPhone o tras 60 s sin tocar mientras suena, la app pasa sola a Noche (3.6) con un fundido de 2 s; al volver a la app de día, vuelve a esta pantalla. Esto es la "separación en el tiempo" que pedía el brief §5: antes de acostarse, la página; ya acostado, la noche.

### 3.3 Mezclador · "Todas las capas"

Pregunta: *¿qué capas, a qué nivel?*

Pantalla empujada (no hoja: once filas necesitan la altura entera), barra de navegación del sistema con título "Capas" ["Layers"] en `inline` y botón atrás estándar. Contenido:

| y | Elemento |
|---|---|
| 110 | Encabezado de sección en versalitas paso 9 `texto2`: "colores" ["colors"]. Hairline. |
| 128 | Fila de capa 76: **Blanco** / "siseo parejo" ["White" / "even hiss"] / regla a 0 (hairline) / sin valor. |
| 204 | **Rosa** / "suave y equilibrado" ["Pink" / "soft and balanced"] / 65 / regla 65 %. |
| 280 | **Marrón** / "retumbo grave" ["Brown" / "low rumble"] / 0. |
| 388 | (32 de aire) Encabezado "camas" ["beds"]. Hairline. El término viene del PR #3 y es exacto: una cama es una textura continua sobre la que se duerme. |
| 406 | **Lluvia** / "lluvia fina" ["Rain" / "fine rain"] / 40 / regla 40 %. |
| 482 | **Ventilador** / "ventilador lejano" ["Fan" / "distant fan"] / 0. |
| 558 | **Océano** / "oleaje lento" ["Ocean" / "slow swell"] / 0. |
| 634 | **Trueno** / "lejano, sin rayos cerca" ["Thunder" / "far off, no close strikes"] / nombre `texto2` / "pro" versalitas (usuario gratuito tras la prueba; en prueba y en Pro, igual que las demás). |
| 710 | **Hoguera** / "brasas, sin chasquidos" ["Campfire" / "embers, no crackle"] / pro. |
| 786 | **Arroyo** / "agua sobre piedras" ["Brook" / "water over stones"] / pro. |
| 862 | **Viento** / "entre árboles" ["Wind" / "through trees"] / pro. |
| 938 | **Cabina** / "avión en crucero" ["Cabin" / "aircraft at cruise"] / pro. |
| 1030 | Nota paso 8 `texto2`: "Se mezclan en tu iPhone mientras suenan. Nada se repite." ["Mixed on your iPhone as they play. Nothing loops."] |

Gestos: arrastre horizontal en cualquier fila = nivel; toque = 0 ↔ último valor; pulsación larga = timbre ("más cálido ◂ ▸ más lejano" ["warmer ◂ ▸ farther"]). La barra inferior **se mantiene** (Play siempre accesible: nada bloquea el sonido). Mientras se arrastra una capa, su regla es la única cosa roja de la pantalla. En AX1+ las filas pasan a 96 pt con el valor bajo el nombre. VoiceOver: cada fila es un ajustable; las "pro" anuncian "requiere Pro, toca para escuchar 30 segundos".

### 3.4 Marea respiratoria · ajustes y estado guiando

Pregunta: *¿cómo respiro?*

Hoja `.large`. Cabecera "Marea respiratoria" ["Breathing tide"] paso 3. Debajo, paso 5 `texto2`, el texto que ya existe y se conserva: "Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla." ["Breathe in as the wave rises, out as it pulls back. No need to watch the screen."]

| y (en la hoja) | Elemento |
|---|---|
| 120-240 | **Línea de agua** (2.9), banda 120 pt, marcas hairline arriba y abajo; en estado guiando la línea roja sube y baja; a la derecha "inhala"/"exhala" paso 9. En apagado, la línea descansa en bajamar en `trazo`. |
| 256 | Versalitas paso 9: "guiando · 6 por minuto · se retira a las 23:27" ["guiding · 6 per minute · fades at 23:27"]; o "apagada". |
| 296 | Hairline. Fila 56 "Marea" + Toggle del sistema (on). |
| 352 | Fila 56 **Ritmo** ["Pace"]: a la derecha, en `texto`, la opción activa. Toca → despliega tres filas de opción con `checkmark`: "Tranquilo · 6 por minuto" ["Calm · 6 per minute"], "Suave · 8 por minuto" ["Gentle · 8 per minute"], "Mi ritmo nocturno · 14 por minuto, según Salud" ["My night pace · 14 per minute, from Health"] (esta última pide el permiso de Salud **en el momento de elegirla**, nunca antes; si se niega, dice "valor por defecto"). Pulsación larga sobre "Ritmo" → stepper del sistema de 4 a 12 en pasos de 0,5 (P11). |
| 408 | Fila 56 **Descenso** ["Slow-down"]: "Empieza a tu ritmo y baja a 6 en 4 minutos" ["Starts at your pace, settles to 6 in 4 minutes"] + Toggle. |
| 464 | Fila 56 **Se retira a los** ["Fades after"]: "15 min" `texto`; toca → opciones 5 · 10 · 15 · 20 · 30 con `checkmark`. |
| 520 | Fila 56 **Háptica** ["Haptics"]: "Ninguna · Mínima · Marcada" como opciones ["None · Minimal · Prominent"]. Nota 13: "Solo mientras sostienes el iPhone; en la mesilla no vibra." ["Only while you hold your iPhone; it won't buzz on the nightstand."] |
| 600 | Nota paso 8 `texto2`: "Respirar a unas 6 veces por minuto se asocia en estudios a mayor variabilidad cardiaca. Qué sabemos y qué no →" ["Breathing at about 6 per minute is linked in studies to higher heart-rate variability. What we know and what we don't →"]. Toca → 3.11. |

Estado "disolviendo": la versalita cambia, la amplitud baja, y al terminar la fila Marea pasa a off sola con la nota "Se retiró a las 23:27" durante 10 s.

### 3.5 Temporizador · tres modos

Pregunta: *¿cuándo se apaga?*

Hoja `.medium` → `.large`. Cabecera "Temporizador" ["Timer"].

| Fila (56) | ES | EN | Detalle |
|---|---|---|---|
| Opción | **Hasta dormirme** · "45 min · se funde los últimos 10" | **Until I fall asleep** · "45 min · fades over the last 10" | Por defecto. `checkmark` si activa. |
| Opción | **Escudo nocturno** · "hasta las 07:00 · baja un poco cada hora" · "pro" | **Night shield** · "until 07:00 · eases down each hour" · "pro" | La hora se toma de la alarma de Sueño si existe; si no, picker del sistema al elegirla. Tras la prueba, correr 30 s y hoja Pro. |
| Opción | **Siesta** · "20 min · termina con una subida suave" | **Nap** · "20 min · ends with a soft rise" | El "despertar progresivo" es la textura aclarándose; nunca sustituye a la alarma. |
| Opción | **Apagado** | **Off** | — |
| Ajuste | **Duración** · a la derecha "45 min" | **Length** · "45 min" | Toca → `Picker` de rueda del sistema (5 min a 6 h; de 65 min en adelante, "pro" junto al valor para el usuario gratuito). Botones "−5 / +5" de 44 pt a los lados para una mano. |
| Nota 13 | "El sonido se funde; tu alarma no se toca. Si el iPhone lleva 20 minutos quieto en la mesilla, el fundido puede empezar antes." | "Sound fades out; your alarm is never touched. If your iPhone has sat still for 20 minutes, the fade may start early." | La segunda frase solo si el fundido por quietud está activo (fila Toggle "Fundido por quietud" ["Fade when still"] debajo). |

Mientras suena, la cabecera de la hoja añade la cifra paso 1 a 56 pt: "38:12" tabular, y bajo ella "+15 min" como botón de texto de 44 pt. Prolongar desde la app cuesta un toque (P2).

### 3.6 Pantalla Noche

Pregunta: *¿sigue todo bien?*

Negro `#000`, sin barra de estado (`.statusBarHidden`), `isIdleTimerDisabled = false` (la pantalla puede apagarse: el sonido sigue), brillo no se toca.

| y | Elemento |
|---|---|
| 330 | **Hora**, SF Pro Display Regular 72 tabular `texto`, centrada: "3:07". Sin "AM/PM" salvo configuración regional de 12 h, y entonces "3:07" con "am" en paso 9 a la derecha. A 1 Hz. |
| 418 | **La regla**, 96 pt de ancho, 1 pt, centrada: `texto` continua = sonando; **ausente** y en su lugar la palabra "en pausa" ["paused"] 17 Medium `texto` = en pausa; `trazo` = fundiendo (los últimos 10 min). Es la forma, no el color, la que dice el estado. |
| 450 | **Tiempo que queda**, 22 Medium tabular `texto2`… corregido: `texto` (a brillo mínimo `texto2` no se lee a un metro): "38 min" ["38 min"]. Sin temporizador: nada. |
| 740-804 | Botón de texto "+15 min" 17 Medium `texto2`, objetivo 64 pt de alto a todo el ancho. Toca → "53 min" con fundido de 250 ms. |
| Toda la pantalla | Toque = pausa/reanuda. Arrastre vertical = volumen maestro (regla vertical de 1 pt a la derecha durante el gesto). Pulsación larga 0,6 s = volver a la página. |

Nada se mueve: la regla aquí es estática (no escribe), la Marea no se dibuja (la guía ya está en el oído y, si se pidió, en la mano). El primer acceso muestra, durante 4 s, una línea paso 8 `texto2` bajo el reloj: "La pantalla puede dormir. El sonido sigue." ["The screen can sleep. Sound keeps playing."] (frase del PR #3, conservada) y, solo la primera vez, "Mantén pulsado para volver" ["Hold to go back"]. VoiceOver: "Tres y siete. Sonando. Quedan treinta y ocho minutos. Toca dos veces para pausar; mantén para volver."

Bajo el rojo de StandBy no aplica (es la app, no el widget), pero la pantalla se diseñó en gris: sin color, sobrevive a todo.

### 3.7 Modo Madrugada

Pregunta: *¿puedo volver a dormirme sin pensar?*

Entrada: botón "Madrugada" ["Small hours"] en la Live Activity cuando la sesión ya terminó, control del Centro de control, botón de Acción o Atajo; también desde Noche con doble toque. Arranca **20 minutos** de la última mezcla al 60 % del nivel con la Marea en descenso (si está en Pro o en prueba; si no, solo la mezcla) y se disuelve sola.

Pantalla: como Noche pero **sin hora** (saber que son las 3:40 no ayuda a nadie; es la única decisión de la app que esconde un dato, y se explica en Ajustes). Centro: la línea de agua en `texto` a 1 pt si hay Marea, o la regla estática si no. Debajo, "20 min" paso 1 a 56 pt que baja por minuto. Toda la pantalla pausa/reanuda; sin "+15" (si quiere más, vuelve a tocar el control: otros 20). Al terminar, la app no hace nada: ni háptico, ni pantalla, ni notificación. Copy de Ajustes: "Madrugada no enseña la hora a propósito." ["Small hours hides the clock on purpose."]

### 3.8 Noches guardadas

Pregunta: *¿cuál de mis noches?*

Pantalla empujada "Noches" ["Nights"] (el término del PR #3 para los presets, adoptado: una mezcla guardada es una noche). Lista editorial: cada fila 72 pt con el nombre en **New York Medium 22** `texto` (la etiqueta escrita a mano), debajo paso 7 `texto2` la receta: "rosa 65 · lluvia 40 · hasta dormirme 45 min". Sin iconos, sin tarjetas. Toca → carga y vuelve a la principal (no suena hasta Play, salvo que ya sonara: entonces cruza en 800 ms). Deslizar → "Renombrar" / "Eliminar" del sistema (el destructivo es el rojo del sistema en la acción de deslizar: es su convención, no nuestro acento). Reordenar con el modo edición estándar.

Tres noches vienen de serie, con nombre humano y sin afirmaciones: **"Lluvia constante"** (lluvia 55, rosa 20), **"Foco"** (marrón 45, ventilador 30; es el preset "Focus" del PR #3 sin la promesa de TDAH), **"Descenso"** (océano 50 con Marea 6/min 15 min, hasta dormirme 45). "Sueño profundo" del PR #3 no se conserva (copy prohibido). Vacío: una sola línea paso 5 `texto2`: "Guarda la mezcla de esta noche desde su nombre." ["Save tonight's mix from its name."]. Sin icono.

Límite gratuito: tres noches propias; la cuarta pide Pro con la palabra "pro" al lado de "Guardar como noche…" en el menú, y el toque sube la hoja Pro (la mezcla no se pierde: sigue cargada).

### 3.9 Paywall y prueba

Pregunta: *¿cuánto, una vez, y qué sigue gratis?*

Hoja `.large`, negra, sin imagen. Todo texto, columna de 20 pt:

| y | Elemento |
|---|---|
| 24 | Versalitas paso 9 `texto2`: "sleepnoise pro" |
| 48 | **Precio** paso 1 a 56 pt tabular `texto`: "29,99 €" ["$29.99"]. Antes de cualquier otro texto y de cualquier toque. Si hay precio de lanzamiento: "19,99 €" y debajo, paso 8: "Precio de lanzamiento hasta el 14 de diciembre. Después, 29,99 €." Sin tachaduras. |
| 120 | Titular **New York Medium 28**: "Un solo pago. Para siempre, en todos tus iPhone." ["One payment. Forever, on every iPhone you own."] |
| 196 | Hairline. Lista editorial de lo que incluye, filas 44 sin iconos, paso 5 `texto`: "Las once capas" · "Marea respiratoria" · "Temporizador sin límite y escudo nocturno" · "Noches ilimitadas" · "Familia incluida" ["All eleven layers" · "Breathing tide" · "Unlimited timer and night shield" · "Unlimited nights" · "Family Sharing included"]. |
| 436 | Hairline. Paso 5 `texto2`: "Sigue gratis siempre: blanco, rosa, marrón, lluvia, 60 minutos de temporizador y tres noches guardadas." ["Always free: white, pink, brown, rain, a 60-minute timer and three saved nights."] |
| 520 | **Botón primario** (2.3): "Comprar · 29,99 €" ["Buy · $29.99"]. Háptico ninguno. |
| 592 | Secundario: "Restaurar compra" ["Restore purchase"]. A la vista, no en un pie. |
| 640 | Paso 8 `texto2`: "Sin suscripción. Sin cuenta. Nada sale de tu iPhone." ["No subscription. No account. Nothing leaves your iPhone."] |

**Tarjetas de prueba** (no son tarjetas): la prueba se expresa en tres momentos, siempre como texto en la cabecera editorial de la principal (3.1):

1. **Noche 1, primera apertura**: bajo el nombre de la mezcla, dos líneas paso 5 `texto2` + botón secundario, visibles una sola vez: "Siete noches con todo. Sin tarjeta. Después seguirán gratis blanco, rosa, marrón, lluvia y 60 minutos; tus noches guardadas se conservan." ["Seven nights with everything. No card. After that, white, pink, brown, rain and 60 minutes stay free; your saved nights are kept."] · "Entendido" ["Got it"]. Si el dueño elige 14 noches, cambia la cifra y nada más. Si la prueba pasa a ser un non-consumable a 0 € (guía 3.1.1), esta misma pantalla gana una fila "Empezar la prueba" con el botón primario y una línea "Dura 7 noches. No se cobra nada ni se pide tarjeta. Al acabar, pierdes las capas Pro, la Marea y el temporizador largo; conservas tus noches." ["Lasts 7 nights. Nothing is charged and no card is asked. When it ends you lose the Pro layers, the tide and the long timer; your nights are kept."]
2. **Noches 2-7**: solo la versalita "prueba · quedan 5 noches".
3. **Noche 8**: versalita "gratis · blanco, rosa, marrón, lluvia y 60 min"; las filas Pro adoptan su estado (2.1). Ninguna hoja al abrir. Nunca una notificación.

Pro comprado: desaparece toda mención; en Ajustes, una fila "SleepNoise Pro · gracias · 16 nov 2026" ["SleepNoise Pro · thank you · Nov 16, 2026"].

### 3.10 Primer uso

No hay onboarding. La primera pantalla es 3.1 con "Rosa y lluvia" cargada (rosa 50, lluvia 30), la regla en reposo y el párrafo de la prueba (3.9.1). Toca Play → suena en < 1 s. Lo único que enseña algo es TipKit, una vez y en su momento: al segundo arrastre sobre una fila, "Arrastra sobre el nombre para cambiar el nivel" ["Drag across the name to change the level"]; al primer Play de noche, la línea de la pantalla Noche. Ningún permiso al arrancar (Salud se pide en "Mi ritmo nocturno"; micrófono no entra en este alcance; notificaciones nunca).

### 3.11 "Qué sabemos y qué no"

Pregunta: *¿qué sostiene cada frase?*

Pantalla empujada, título "Qué sabemos y qué no" ["What we know and what we don't"], **New York Regular 19/28** `texto`, columna de 20 pt, hairlines entre entradas. Sin iconos, sin sellos, sin tablas. Cada entrada: una frase de la app en Semibold (SF Pro 17), y debajo en New York: qué estudio, n, quién lo pagó, qué **no** decimos.

Entrada 1 (ES): **"Enmascara los sonidos que te despiertan."** El ruido continuo reduce los despertares por ruidos intermitentes en un estudio de laboratorio (Stanchina et al., *Sleep Medicine*, 2005; n = 4 voluntarios sanos; financiación académica). La evidencia de que el ruido "mejora el sueño" en general es de muy baja calidad (Riedy et al., *Sleep Medicine Reviews*, 2021; revisión de 38 estudios). Por eso no decimos que duermas mejor. [EN: **"Masks the sounds that wake you."** Continuous noise reduced arousals from intermittent noise in one lab study (Stanchina et al., *Sleep Medicine*, 2005; n = 4 healthy volunteers; academic funding). Evidence that noise "improves sleep" overall is of very low quality (Riedy et al., *Sleep Medicine Reviews*, 2021; 38 studies reviewed). That is why we never say you will sleep better.]

Entrada 2: **"Te acompaña a respirar más despacio."** Respirar a unas 6 veces por minuto se asocia a mayor variabilidad cardiaca y a menor activación en una revisión (Zaccaro et al., *Frontiers in Human Neuroscience*, 2018; 15 estudios) y en un ensayo con insomnio (Tsai et al., *Psychophysiology*, 2015; n = 20). No tratamos el insomnio ni la ansiedad; no es un producto sanitario.

Entrada 3: **"Nunca se repite."** El sonido se sintetiza en tu iPhone mientras suena; no hay archivo ni bucle. Puedes comprobarlo: la app pesa [X] MB. Lo que no podemos afirmar: que un sonido sin bucle te despierte menos que uno con bucle; no conocemos un estudio que lo mida.

Pie, paso 8: "Nada de lo anterior es consejo médico. Si duermes mal muchas noches, habla con un profesional." ["None of this is medical advice. If you sleep badly many nights, talk to a professional."]

### 3.12 Live Activity, Dynamic Island, StandBy

Un control. Una tinta (`texto`). Sin acento. Estado por forma.

- **Lock Screen** (160 pt de alto máx.): izquierda, nombre de la mezcla SF Pro Semibold 17 `texto` (una línea, `minimumScaleFactor(0.8)`); debajo, versalitas 13 Medium "sonando · hasta dormirme" ["playing · until I fall asleep"]; derecha, tiempo restante 28 Medium tabular `texto` ("38 min", `Text(timerInterval:)` del sistema); abajo, la regla estática de margen a margen (1 pt `texto` con amplitud = nivel maestro al emitir); botón único a la derecha de la regla: glifo pausa/play 44 pt `texto` (`AudioPlaybackIntent`). Fondo negro; `activityBackgroundTint(.black)`. En pausa: el glifo es play y la regla es `trazo`.
- **Dynamic Island compacta**: leading glifo pausa (sonando) / play (en pausa) `texto`; trailing "38 m" 15 Medium tabular. **Mínima**: el glifo. **Expandida**: nombre + versalita + tiempo + regla + glifo, misma gramática.
- **StandBy nocturno**: la presentación de bloqueo escalada ×2; todo `texto` (4,3-4,4:1 bajo rojo en los dos modelos) y la regla ≥ 2 pt (componente, 3:1). El tiempo a 56 pt. Sin `texto2`, sin rojo. Probado en la maqueta con el filtro rojo: el estado se lee por el glifo y por la continuidad de la regla.
- Sesión > 8 h (escudo nocturno): la actividad se emite para el tramo de la sesión que el sistema admite y se cierra con `.immediate` al terminar el fundido; el widget cubre el resto.

### 3.13 Widgets

- **Pequeño** (interactivo): nombre de la noche New York Medium 17 `texto` arriba a la izquierda; abajo a la izquierda versalitas "sonando" / "en silencio"; abajo a la derecha, glifo play/pausa 28 pt `texto` en un botón de 44 pt (`AudioPlaybackIntent`). Fondo negro, `containerBackgroundRemovable(true)` para StandBy; en `accented` y `vibrant` el sistema pinta la tinta y el glifo sigue leyéndose por forma.
- **Mediano**: lo mismo a la izquierda; a la derecha, tres noches guardadas como filas de texto (New York 15 + versalita de receta), cada una un botón que carga y reproduce.
- **Bloqueo (circular / rectangular)**: glifo play/pausa; rectangular añade el tiempo restante.
- Ningún widget usa `grafito-rojo`.

### 3.14 Centro de control y botón de Acción (iOS 18+)

`ControlWidgetToggle` "SleepNoise": símbolo propio **pendiente rosa** (línea con −3 dB/oct) en off; en on el sistema tiñe con el color de la app (`grafito-rojo`: es el único lugar fuera de la app donde el sistema lo pinta, y sobre el fondo gris del Centro de control da 4,4:1 **[a medir]**). Título "SleepNoise", subtítulo en on "Rosa y lluvia · 38 min". Un segundo control, botón, "Madrugada" ["Small hours"] (símbolo: la línea de agua). El botón de Acción ofrece el toggle con la pista "Mantén para dormir" ["Hold for sleep"].

### 3.15 Apple Watch mínimo

Una pantalla, SF Compact (del sistema), negro: nombre de la noche 15 Medium `texto`; glifo play/pausa 44 pt `texto` centrado; debajo "+15 min" como botón de texto 44 pt; Digital Crown = volumen maestro (regla vertical de 1 pt mientras gira). Marea háptica: `.directionUp` al inicio de cada inhalación ("Mínima") o además `.click` al inicio de la exhalación ("Marcada"), durante toda la guía: la muñeca no suena sobre la mesilla. Smart Stack: la misma tarjeta con nombre + tiempo + glifo. Complicación: glifo de pendiente rosa. Sin acento en el Watch.

---

## 4. Icono de la app

**"La regla y la marea."** Un objeto grabado, no una luna.

Construcción geométrica (lienzo 1024 × 1024, retícula de 64):

1. Fondo: `negro` `#000000` plano (Default y Dark).
2. **La regla**: un trazo horizontal de `texto` `#E8E4DC`, grosor 56 px, extremos rectos, de x = 192 a x = 832 (margen 18,75 %), con el eje en y = 608 (línea baja: el 59,4 % de la altura, el mismo tercio bajo que ocupa la regla en la pantalla principal).
3. **La marea**: desde el punto x = 384 de la regla, un segundo trazo de `grafito-rojo` `#E0524D`, mismo grosor 56 px, que **sube** en una curva de 256 px de ancho hasta y = 384 (cresta en x = 576; es la inhalación, 4 partes) y **baja** en una curva de 384 px de ancho hasta volver a la regla en x = 832 (la exhalación, 6 partes). Proporción 4:6 exacta: la de la `BreathCurve`. Curvas Bézier cúbicas con tangentes horizontales en la salida, la cresta y la llegada; la llegada coincide con el extremo derecho de la regla, que así termina en rojo.
4. Ningún otro elemento. Sin radio interior, sin sombra, sin degradado, sin nombre.

A 29 pt el trazo mide ≈ 1,6 pt: se lee como "una línea con una ola" y no se confunde con ninguna luna, nube ni onda de la categoría; junto a Dark Noise (D con ondas), Calm (fondo azul), Endel (círculo) y BetterSleep (luna), es el único icono con una sola línea sobre negro.

Apariencias (Icon Composer, dos capas: regla y marea):
- **Default / Dark**: como arriba.
- **Light** (iOS 26 por defecto en claro): fondo `papel` `#F3F0E9`, regla `tinta` `#1E1C19`, marea `grafito-rojo-día` `#9E3733`.
- **Tinted**: una capa monocroma (regla + marea unidas) sobre el tinte del sistema.
- **Clear**: solo los dos trazos en `texto`, sin fondo; el vidrio del sistema hace el resto.

---

## 5. Las seis capturas de la App Store (es-ES; en-US entre corchetes)

Fondo de todas: negro; la captura es la pantalla a tamaño real, sin marco pintado ni mockup inclinado; el titular en New York Medium 40 `texto` arriba, una línea; nada más.

1. **"Un solo pago. 29,99 €."** ["One payment. $29.99."] Pantalla principal en reposo con "Rosa y lluvia" y la regla quieta. El precio antes que nada; la ausencia de suscripción es la primera noticia.
2. **"Se fabrica en tu iPhone. Nunca se repite."** ["Made on your iPhone. It never loops."] Principal sonando: la regla roja escribiendo. Subtítulo paso 7: "La línea es el sonido real, ahora."
3. **"Once capas. Una línea cada una."** ["Eleven layers. One line each."] Mezclador con Lluvia bajo el dedo (regla roja a 1,5 pt y valor grande).
4. **"El mar respira a seis por minuto. Tú con él."** ["The sea breathes six times a minute. So do you."] Hoja de Marea con la línea de agua subiendo e "inhala".
5. **"A las tres de la mañana, nada."** ["At three in the morning, nothing."] Díptico en una sola captura: pantalla Noche a la izquierda y StandBy en rojo a la derecha. Sin titular adicional.
6. **"Lo que no hay."** ["What isn't here."] Una lista tipográfica sobre negro, New York 28, con hairlines: "Sin suscripción · Sin cuenta · Sin anuncios · Sin red · Sin puntuación · Sin racha · Sin tutorial" ["No subscription · No account · No ads · No network · No score · No streak · No tutorial"]. Pie: "Data Not Collected."

Preview muda de 30 s: Play (trazo) → la regla empieza a escribir → un dedo arrastra sobre "Lluvia" y la regla de la fila crece → se activa la Marea y la línea de agua sube y baja dos veces → la pantalla se funde a Noche → StandBy en rojo → negro.

---

## 6. Qué se elimina de la app actual y por qué

| Se elimina | Por qué |
|---|---|
| Título "SleepNoise" + subtítulo "Para la noche" | No informa a quien ya abrió la app (P5); el nombre vive en la ficha y en el paywall (Muji, Leica). |
| Icono "mist" de mezclas y cápsula ámbar "Prueba · 7 días" en la cabecera | Segundo acento y badge: señal opuesta al lujo; la prueba pasa a una versalita de texto. |
| Tarjeta permanente de prueba con botón relleno "Entendido" | Un cuarto de la pantalla el primer día (P6); pasa a dos líneas de texto que se ven una vez. |
| Tarjetas de capa con icono en círculo, slider con pulgar blanco y relleno ámbar | Son cajas; el icono no dice nada ("Marrón" es un altavoz); el nivel pasa a ser una regla bajo el nombre y la fila entera es el control. |
| Tarjeta de Marea con disco gris como icono | Pasa a fila editorial con toggle del sistema; la forma de la Marea es la línea de agua. |
| Disco Play ámbar de 88 pt | La fuente de luz más grande de la pantalla; pasa a un trazo de 1,5 pt en un objetivo de 64. |
| Fondo `#0E1114` con degradado y resplandor ámbar radial al sonar | No es negro, cuesta GPU, es decoración sin causa (P3, P4); pasa a `#000` y la regla. |
| Botones "Cerrar" en cápsula y títulos centrados de las hojas | La hoja ya se cierra; el título va a la izquierda a 20 pt (P12). |
| Rejilla 2×2 del temporizador y "Personalizado" duplicado | Pasa a una lista de tres intenciones con nombre y una duración. |
| Reloj SF Rounded Light 44 | Light prohibido; pasa a SF Pro Display Regular 56/72 tabular. |
| `lock.fill`, cápsulas "PRO" ámbar, opacidad 0,72 en filas | Cada candado es un reproche (P9); pasa a la palabra "pro" en versalitas y 30 s de prueba al tocar. |
| Icono ámbar y frase gris del vacío de "Mezclas guardadas" | Pasa a una frase que dice cómo guardar. |
| Segundo acento `mist` `#A7BEC0` | Muere bajo el rojo de StandBy (2,6:1) y rompe "un acento". |
| Texto "Mezclas" como nombre de sección | Pasa a "Noches" (PR #3), que es como se vive. |

Se conserva: "7 días con todo. Sin tarjeta." (reescrito en "Siete noches con todo. Sin tarjeta."), el texto de la Marea, la nota de fundido, el toggle del sistema en la Marea, los identificadores de accesibilidad, `monospacedDigit()`, el `BreathIndicator` aislado en `TimelineView` (se reutiliza para la línea de agua), la lint de palabras médicas.

## 7. Qué se aprovecha del PR #3 y cómo se expresa en Grafito

| Del PR #3 | En Grafito |
|---|---|
| **Presets de un toque** ("Deep sleep", "Focus", "Steady rain") | Pasan a ser **noches**: mezclas guardadas con nombre humano en New York, tres de serie ("Lluvia constante", "Foco", "Descenso"), en la pantalla "Noches" y como filas del widget mediano. Desaparecen los chips con emoji y "Sueño profundo" (copy prohibido). |
| **Pantalla Noche** en negro puro con "The screen can sleep. Sound keeps playing." | Se conserva la pantalla, la frase y el negro; se corrige el contraste (`texto` 16,6:1 en vez de 2,7:1), se quitan los dos botones de contorno (dos botones iguales confunden a medio dormir: lección del Reloj de iOS 26) y la pantalla entera pasa a ser el control, con "+15 min" como único botón. |
| **"Bedtime" como estado** (la app sabe que es la hora de acostarse) | Se convierte en la transición automática página → Noche al bloquear o tras 60 s sonando, y en "Hasta dormirme" como modo por defecto del temporizador. |
| **"Camas"** como término para las texturas | Se adopta como encabezado de sección del mezclador ("colores" / "camas"): es exacto y es castellano. |
| **Las once capas** (trueno, hoguera, arroyo, viento, cabina) | Entran al mezclador como filas iguales a las demás, con subtítulo honesto ("lejano, sin rayos cerca"). |
| **Atajos** y el modelo de datos | Se usan tal cual: `AudioPlaybackIntent`, Centro de control, botón de Acción. |
| Lo que no se aprovecha | La rejilla de baldosas, el disco de 300 pt, el degradado animado a 15 fps, SF Rounded en cuerpo, los 14 candados, el asa falsa "Levels", la hoja que mezclaba Noche, Temporizador, Marea y sliders. |

## 8. Riesgos y mitigación

| Riesgo | Mitigación |
|---|---|
| **El rojo se lee como error/destructivo** (es el color que iOS reserva para "Borrar"). | Saturación y luminancia bajadas (`#E0524D`, no `#FF453A`); nunca relleno, nunca en "Eliminar" (que usa la acción de deslizar del sistema, no nuestro acento), nunca en errores (que son texto gris). Prueba de cinco segundos con diez personas ajenas: "¿qué pasa en esta pantalla?"; si más de dos dicen "algo va mal", el acento baja a `#D9534F`-ish o se pasa al plan B (`brasa` con el mismo sistema de líneas: nada más cambia). |
| **El acento muere bajo el modelo B de StandBy** (1,69:1). | Regla dura: cero acento en StandBy, Live Activity, widgets y Watch; una sola tinta `texto` (4,3-4,4:1 en ambos modelos) y estado por forma. Medir el filtro real en dispositivo la primera semana. |
| **"No hay nada" en la tienda** (una página negra con una línea). | La primera captura lleva el precio como titular y el nombre de la mezcla en New York 28; la línea en reposo es una hairline *bella* (fina, cálida, bien colocada en el tercio bajo); la preview enseña la regla escribiendo en los primeros 3 s. Prueba de cinco segundos en la lente 5 del jurado. |
| **Dos familias** (New York + SF) frente al principio "una familia". | New York solo en tres lugares acotados, nunca < 19 pt, nunca de noche ni en controles; si el jurado lo rechaza, el nombre de la mezcla pasa a SF Pro Display Medium 28 y el concepto no pierde estructura. |
| **La regla de nivel es un control invisible hasta que se toca** (descubribilidad). | La parte dibujada ya enseña que hay una línea con longitud; TipKit una vez al segundo arrastre; VoiceOver lo expone como ajustable desde el primer día; el valor numérico a la derecha invita a cambiarlo. Prueba con cinco personas: todas deben cambiar un nivel sin ayuda en < 10 s. |
| **Smear OLED** al desplazar texto claro sobre negro puro. | La principal cabe sin scroll en Large (cuatro capas como máximo "arriba"); el mezclador desplaza, pero sus únicos elementos son texto y hairlines de 1 px (el peor caso del smear son los rellenos grises grandes, que no existen). |
| **Hojas negras sobre fondo negro** pierden la sensación de "otra habitación". | La hoja trae esquina del sistema, atenuación del fondo e indicador de arrastre; además hairline superior `trazo` y cabecera paso 3. Comprobar con "Reducir transparencia". Plan B: `grafito` como fondo de hoja (02-Materiales), sin tocar nada más. |
| **Madrugada sin hora** puede frustrar a quien quiera saberla. | La hora está a un gesto (pulsación larga vuelve a Noche); la decisión se explica en Ajustes y se puede desactivar ("Mostrar la hora en Madrugada"). |
| **El trazo del Play a 1,5 pt** se ve poco a brillo mínimo. | El objetivo es 64 pt y la barra lo centra; en Noche el Play es la pantalla entera; con "Aumentar contraste" el trazo pasa a 2 pt y `grafito-rojo-ac`. |

## 9. Autoevaluación contra los doce principios

| P | Prueba hecha sobre la maqueta |
|---|---|
| P1 Noche manda | Noche y Madrugada diseñadas primero (gris, sin color); la página se derivó después. |
| P2 Un gesto | Pausa: toque en cualquier parte (Noche), Play en barra, glifo en Live Activity, Watch. +15: un botón de 64 pt. Volumen: arrastre vertical. |
| P3 Negro real | Fondo `#000` en todas las superficies, hojas incluidas; > 90 % de píxeles apagados en la principal en reposo; un acento. |
| P4 Causa en el sonido | Regla ← RMS del motor; línea de agua ← `BreathCurve`; nada más se mueve. |
| P5 Tipografía primero | SF Pro + New York (acotada); 5 estilos en la principal; sin Rounded, sin Light. |
| P6 Aire antes que cajas | 0 rectángulos rellenos en la principal; 1 (el contorno del botón primario) en el paywall; agrupación por 32 pt y hairline. |
| P7 Estado por forma | Play/pausa por glifo; regla continua/ausente/hairline; capa Pro por palabra; comprobado con el filtro rojo de la maqueta. |
| P8 44/64 | Filas 56-76, Play 64, "+15" 64, Noche pantalla completa. |
| P9 Nada bloquea | Cero candados; capas Pro suenan 30 s; barra con Play presente en el mezclador; la prueba es texto. |
| P10 Una pantalla, una decisión | Cada pantalla lleva su pregunta escrita arriba en este documento. |
| P11 Lo técnico debajo | Ritmo con nombres humanos, stepper bajo pulsación larga; timbre bajo pulsación larga; envolvente por capa bajo pulsación larga. |
| P12 Componentes de Apple | Toggle, Picker, sheet, toolbar, Live Activity, widgets, Control Center del sistema; propios: regla de nivel, regla del sonido, línea de agua, Play trazado, pantalla-botón. |

---

# Parte II · Interacción

**Diseño de interacción del equipo Grafito · añadido el 16 de noviembre de 2026.** Lo que sigue amplía el concepto sin tocar lo anterior: flujos paso a paso, movimiento, háptica, superficies del sistema, accesibilidad, textos definitivos y la primera noche. Convenciones: cada paso dice qué **ve**, qué **oye** y qué **siente** la persona cuando los tres canales importan; los textos van en español con el inglés entre corchetes; las medidas, tokens y pasos tipográficos son los de la Parte I. Lo que no se pudo medir en dispositivo lleva **[a medir]**.

## 10. Flujos completos

### 10.1 Primera noche, sin tutorial

Situación: instalada hace un minuto, 23:10, luz de la mesilla encendida.

1. **Abre.** Ve 3.1 con "Rosa y lluvia" en New York, la regla quieta (hairline), "En silencio", dos filas de capa (Rosa 50, Lluvia 30) y, bajo el nombre, el párrafo de prueba de una sola vez: "Siete noches con todo. Sin tarjeta. Después seguirán gratis blanco, rosa, marrón, lluvia y 60 minutos; tus noches guardadas se conservan." y el botón de texto "Entendido". No hay pantalla previa, permiso, valoración ni notificación. Tiempo hasta pantalla útil: < 1 s (la app no carga nada).
2. **Toca Play** (trazo rojo en la barra). Oye el arranque en 800 ms; ve la regla pasar de hairline a trazo rojo que empieza a escribir desde el margen izquierdo; "En silencio" → "Sonando"; el glifo pasa a pausa con fundido. Siente `.impact(.medium, 0.7)` una vez. La Live Activity aparece en el bloqueo sin preguntar (no requiere permiso).
3. **Nada más ocurre.** Si no toca nada, el párrafo de prueba sigue ahí hasta que pulse "Entendido" o hasta la segunda apertura, lo que antes llegue; nunca vuelve.
4. **Arrastra sobre "Lluvia"** por curiosidad: ve la regla de la fila ponerse roja a 1,5 pt y el valor crecer a 17 pt junto al dedo; oye la lluvia subir sin escalones; siente `.selection` solo si cruza el cero. Al soltar, la regla vuelve a `texto` 1 pt. Al segundo arrastre de su vida (no al primero: el primero ya lo ha descubierto solo), TipKit muestra una línea bajo la fila durante 6 s: "Arrastra sobre el nombre para cambiar el nivel. Un toque lo silencia." ["Drag across the name to change the level. Tap to mute."]
5. **Toca "Temporizador".** Hoja `.medium`: "Hasta dormirme · 45 min" ya marcada (por defecto desde la primera noche; nadie tiene que configurar nada para que el sonido se apague). Cierra arrastrando.
6. **Toca "Noche"** o bloquea el iPhone. Ve el fundido de 2 s a la pantalla Noche con la línea "La pantalla puede dormir. El sonido sigue." y, solo esta vez, "Mantén pulsado para volver." durante 4 s. Apaga la luz.
7. **Deja el iPhone en la mesilla.** La pantalla se apaga sola (idle timer del sistema). El sonido sigue, se funde a las 23:55, la Live Activity termina sola.

Lo que la persona ha aprendido sin que nadie se lo explique: que suena con un toque, que el nivel se arrastra, que el temporizador ya estaba puesto, que la pantalla se puede apagar. Lo que no ha visto: precio, candado, permiso, tutorial.

### 10.2 Sesión normal (noche 3, usuario en prueba)

1. Abre a las 23:40. Cabecera "prueba · quedan 5 noches". La mezcla cargada es la de anoche (la app recuerda siempre la última; no hay pantalla de inicio distinta).
2. Toca Play. Igual que 10.1.2. Si anoche usó temporizador, hoy el mismo: la fila dice "Hasta dormirme · quedan 45 min" desde el primer segundo.
3. Opcional: toca el nombre "Rosa y lluvia" → pulsación larga → menú del sistema → "Guardar como noche…" → campo de texto del sistema precargado con el nombre generado → "Guardar". Siente `.success`. No sube ninguna hoja de Pro (en prueba todo está abierto).
4. Bloquea el iPhone. La app entra sola en Noche (no se ve: la pantalla ya está apagada; sí se verá si la enciende sin desbloquear: la Live Activity, y si desbloquea, Noche).
5. A las 00:25 el temporizador funde los últimos 10 min: el nivel baja con `.easeInOut`; si la pantalla estuviera encendida, la regla de Noche pasa de `texto` a `trazo`. Ningún háptico, ningún sonido final. La Live Activity se cierra con `.immediate` al terminar el fundido.

### 10.3 Ajustar una capa a oscuras (3:10, pantalla Noche, ojos a medias)

El caso que decide el jurado (lente 1). Hay tres niveles de ajuste y cada uno cuesta un gesto menos que el anterior:

- **Bajar todo** (lo más frecuente): arrastre vertical en cualquier punto de la pantalla Noche. Ve aparecer a la derecha una regla vertical de 1 pt `texto` de 200 pt cuya parte dibujada es el volumen maestro; oye el nivel seguir al dedo sin pasos; siente nada (en Noche no hay háptica). Al soltar, la regla desaparece en 250 ms. VoiceOver: rotor "Volumen", deslizar arriba/abajo.
- **Silenciar una capa concreta** (la lluvia molesta): pulsación larga 0,6 s → la app vuelve a la página (3.2) con la tinta bajada al 70 % durante 10 s (la "página nocturna": mismo layout, `texto` al 70 % de opacidad, sin rojo: la regla del sonido escribe en `texto2`). Las filas de "lo que suena" están a 76 pt y la fila entera es el control: un toque sobre "Lluvia" la pone a 0 (toque = 0 ↔ último valor). Oye la lluvia desaparecer en 250 ms. Toca "Noche" o no toca nada 60 s: vuelve a Noche.
- **Ajuste fino de una capa**: igual, pero arrastre horizontal sobre la fila. La regla se pone roja (el único rojo que se permite en la página nocturna, porque está bajo el dedo y dura lo que el gesto).

Regla: nada de lo anterior requiere leer. Las filas se encuentran por posición (siempre las mismas: primero las capas que suenan, en el orden del mezclador) y por el tamaño del nombre. Si la persona tiene Reduce Motion, el paso Noche → página es un fundido de 250 ms.

### 10.4 Activar la Marea y qué pasa durante 15 minutos

Premisa: "Descenso" cargado (océano 50), prueba o Pro, 23:12.

| Minuto | Ve | Oye | Siente (háptica "Mínima", iPhone en la mano) |
|---|---|---|---|
| 0:00 · toca el toggle de la fila "Marea respiratoria" | El toggle pasa a on (250 ms). La regla del sonido se abre en la banda de 120 pt de la línea de agua (la banda crece desde los 24 pt actuales en 800 ms; lo de abajo baja 96 pt con el mismo `.easeInOut`). Debajo del nombre, versalita "guiando · 12 por minuto · se retira a las 23:27" (empieza a su ritmo porque Descenso está activo; sin Descenso, "6 por minuto" desde el principio). A la derecha de la banda, "inhala". | El oleaje empieza a acompasarse: la ola sube con la inhalación y rompe con la exhalación. Sin corte: el audio pasa de "oleaje libre" a "oleaje guiado" en una respiración. | Un `CHHapticPattern` continuo cuya intensidad sube con la línea (0,15 → 0,55) y baja con ella, nitidez 0,2. |
| 0:00-0:30 · tres respiraciones | La línea sube 4 s hasta la marca alta, baja 6 s hasta la baja (a 12/min: 2 s / 3 s). La palabra alterna "inhala" / "exhala" con fundido de 250 ms. | Idem. | Idem, tres ciclos. |
| 0:30 · tercera exhalación | La palabra "inhala / exhala" desaparece (fundido 500 ms) y no vuelve: ya no hace falta mirar. | Idem. | La háptica se retira en la cuarta respiración (la intensidad máxima baja un 25 % por ciclo hasta cero en la quinta). "Marcada": la háptica continua se retira igual pero queda un transitorio suave (intensidad 0,3, 40 ms) al inicio de cada inhalación durante toda la guía. |
| 0:30-4:00 · descenso | La versalita baja la cifra cada 30 s: "11 por minuto" … "6 por minuto"; el periodo de la línea se alarga de 5 s a 10 s de forma continua (no por saltos: `BreathCurve` interpola el periodo entre ciclos, nunca dentro de uno). | El oleaje se ralentiza con la misma función. | Nada (ya retirada). Si el iPhone está en la mesilla (CoreMotion quieto), la háptica no habría arrancado. |
| 4:00-12:00 · guiando a 6 | Línea a 10 s por ciclo, 4 s arriba / 6 s abajo. Si la pantalla sigue encendida y la app delante. En Noche la línea no se dibuja; en Always-On queda quieta en bajamar. | Oleaje a 6 por minuto. | Nada. |
| 12:00-15:00 · disolviendo | Versalita "disolviendo"; la amplitud de la línea baja del 100 % al 0 % de la banda en los últimos 20 % de la duración (3 min), con la línea cayendo hacia la bajamar. | La modulación del oleaje se abre: la ola deja de marcar la respiración y vuelve a ser oleaje libre, a la misma sonoridad. No hay silencio: la Marea se retira, el mar se queda. | Nada. |
| 15:00 · fin | La línea descansa 2 s en bajamar `trazo`; la banda se cierra a 24 pt en 800 ms y vuelve a ser la regla del sonido escribiendo. El toggle pasa a off solo. Bajo la fila, nota paso 8 durante 10 s: "Se retiró a las 23:27." ["Pulled back at 23:27."] | Oleaje libre; el temporizador sigue su curso. | Nada. Nunca un háptico al terminar (la persona duerme). |

Si toca el toggle a off en mitad: la disolución se adelanta y dura 30 s (nunca un corte). Si pausa el sonido con la Marea activa: la línea se congela donde está y la versalita dice "en pausa"; al reanudar, la Marea retoma desde el inicio de un ciclo (inhalación), no desde donde quedó, para no empezar a medio respirar.

Caso gratuito tras la prueba: el toggle funciona, guía 30 s exactamente igual (línea, háptica, palabra), y a los 30 s la hoja Pro sube con el precio en la primera línea mientras la Marea se disuelve en 10 s. Si compra, la Marea vuelve a arrancar sola al cerrar la hoja. Si no, queda el oleaje libre; nunca se corta el sonido.

### 10.5 Temporizador de tres modos

| Paso | Hasta dormirme | Escudo nocturno | Siesta |
|---|---|---|---|
| Elegir | Fila con `checkmark`. Por defecto desde la primera noche. | Fila; al elegirla por primera vez: si existe horario de Sueño en Salud/Reloj, se precarga "hasta las 07:00" sin pedir permiso (la hora de despertar del horario de Sueño se lee con `HKCategoryType.sleepSchedule`… **[a verificar]**; si no hay API fiable, el picker del sistema). Para el usuario gratuito tras la prueba: corre 30 s y sube la hoja Pro. | Fila. Duración por defecto 20 min; "Duración" ofrece 10 · 20 · 30 · 45. |
| Mientras suena | Fila de la principal: "Hasta dormirme · quedan 38 min". Noche: "38 min". Live Activity: `Text(timerInterval:)`. | "Escudo nocturno · hasta las 07:00". Noche: "hasta las 7:00" en 22 Medium bajo la regla (no una cuenta atrás de 7 h: una hora fija se lee mejor a oscuras). Cada hora en punto el nivel maestro baja un 6 % (−0,5 dB aprox.) con `.easeInOut` de 60 s; el mínimo es el 50 % del inicial. | "Siesta · quedan 18 min". |
| Prolongar | "+15 min" (hoja, Noche, Live Activity expandida, Watch). | No hay "+15": la hora fija se mueve con "+30 min" en la hoja. | "+5 min" (una siesta se prolonga poco; el botón dice 5). |
| Final | Fundido de 10 min (`.easeInOut` sobre el nivel maestro). Si "Fundido por quietud" está activo y el iPhone lleva 20 min quieto y horizontal antes del final, el fundido empieza entonces (y el temporizador se acorta; la fila lo dice: "se funde ahora · quieto 20 min"). | A las 07:00 menos 15 min, la textura se aclara (más agudos, +3 dB en 2-4 kHz progresivos) y el nivel sube un 10 %: "subida suave"; a las 07:00 funde en 60 s. La alarma del sistema no se toca ni se sustituye; si suena antes, el sistema interrumpe el audio y la app pausa (10.11). | Últimos 3 min: subida suave igual que Escudo; termina con fundido de 30 s. Sin sonido final: la siesta la termina la alarma que la persona haya puesto, no nosotros (la nota lo dice). |
| Si la alarma del sistema suena durante el fundido | El sistema interrumpe; la app pausa con estado "En pausa · alarma"; no reanuda sola. | Idem. | Idem. |

Lo que nunca hace el temporizador: vibrar, sonar, encender la pantalla, enviar notificación, silenciar la alarma, cortar en seco.

### 10.6 Pantalla Noche y vuelta

**Entrar** (cualquiera de estas, todas con fundido de 2 s a negro, `.easeInOut`; Reduce Motion: 250 ms):
- Toca "Noche" en la barra.
- Bloquea el iPhone mientras suena (al desbloquear verá Noche).
- 60 s sin tocar la pantalla mientras suena (configurable: "Pasar a Noche sola · 1 min / 3 min / Nunca").
- El Focus de Sueño se activa con la app delante.
- No entra sola si no suena nada: la página en silencio se queda como está.

**Dentro:** 3.6. Solo hay cuatro cosas: hora, regla, tiempo, "+15 min". Y un gesto que se aprende una vez (pulsación larga).

**Volver** (fundido de 250 ms; la página aparece como "página nocturna": tinta al 70 % durante 10 s entre las 22:00 y las 07:00, porque el brillo ambiental no es accesible a la app):
- Pulsación larga 0,6 s en cualquier punto. Un transitorio `.impact(.light, 0.4)` confirma la salida (la única háptica de Noche, porque aquí el sonido no cambia y hace falta algo que diga "ya").
- Botón atrás de VoiceOver: "Volver a la página", botón situado al principio del orden de lectura.
- Acceso asistido: la pantalla Noche es la única; "volver" no existe y no hace falta.

**Si la persona pausa en Noche** (un toque): la regla desaparece y en su lugar "en pausa" 17 Medium `texto`; el reloj y el tiempo se quedan (el temporizador se congela; no corre en pausa). Otro toque: reanuda con 800 ms y la regla vuelve. Si pasan 20 min en pausa, la app termina la sesión y la Live Activity ofrece Madrugada.

### 10.7 Modo Madrugada desde el bloqueo

Situación: 3:38, la sesión terminó a las 00:25. La persona se despierta.

1. Levanta el iPhone (raise to wake). Ve el bloqueo con la Live Activity terminada, si no han pasado 12 h: "Sesión terminada · se fundió a las 00:25 · 73 min" y la fila "madrugada · 20 min" con el glifo Play. Si la actividad ya no está, ve el widget pequeño ("Descenso · en silencio · ▷") o abre el Centro de control (botón "Madrugada").
2. **Toca el Play de "madrugada".** `AudioPlaybackIntent` arranca sin abrir la app: oye la última mezcla al 60 % del nivel con el que se durmió, con fundido de 3 s (más largo que el arranque normal: a las 3 nada debe llegar de golpe); si tiene Pro o prueba, la Marea arranca en descenso desde 10/min. La Live Activity pasa a "madrugada · quedan 20 min" con pausa. La pantalla sigue en el bloqueo: no hace falta desbloquear nada.
3. Si desbloquea, la app abre directamente en la pantalla Madrugada (3.7): sin hora, la línea de agua en `texto` si hay Marea, "20 min" bajando por minuto. Todo lo demás es negro.
4. Deja el iPhone. A los 16 min la Marea se disuelve; a los 20 el sonido funde en 60 s. Nada vibra, nada se enciende. La Live Activity se cierra.
5. Si se despierta otra vez a las 4:30: el mismo gesto, otros 20.

Desde el Watch: la app del Watch, cuando no suena nada, muestra "Madrugada · 20 min" como único botón grande. Desde Siri: "Oye Siri, Madrugada en SleepNoise". Desde el botón de Acción: si la persona lo asignó al control "Madrugada", mantener pulsado.

Por qué 20 minutos y no "hasta que me duerma": porque "hasta que me duerma" exige un sensor que no tenemos y una promesa que no cumpliríamos; 20 minutos es el rango del control de estímulos sin llamarlo así (informe §8, oportunidad 4). Se puede cambiar en Ajustes: 10 · 20 · 30.

### 10.8 La prueba caduca mientras suena, y después

Regla de diseño que resuelve todo el flujo: **la prueba no termina en un instante, termina en una sesión.** La noche 7 cuenta hasta que la sesión en curso acaba (fundido, pausa de más de 20 min o parada); solo entonces la app pasa a "gratis". Nada cambia nunca mientras suena, ni en la Live Activity, ni en el widget.

1. **Noche 7, 23:00.** Cabecera: "prueba · última noche". Bajo el nombre de la mezcla, una vez, dos líneas paso 7 `texto2`: "Mañana seguirán gratis blanco, rosa, marrón, lluvia y 60 minutos. Tus noches guardadas se conservan." ["From tomorrow, white, pink, brown, rain and 60 minutes stay free. Your saved nights are kept."] Sin botón: desaparece al arrancar el sonido. Sin hoja, sin precio (el precio está a un toque en la versalita, como siempre).
2. **Suena hasta las 00:30** con trueno y Marea. Nada cambia.
3. **Noche 8, 23:05, abre la app.** Cabecera: "gratis · blanco, rosa, marrón, lluvia y 60 min". Bajo el nombre, una sola vez, paso 7: "La prueba terminó. Lo que usaste sigue aquí; las capas Pro, la Marea y el temporizador largo esperan a Pro." ["The trial is over. What you used is still here; the Pro layers, the tide and the long timer wait for Pro."] y el botón de texto "Entendido". La mezcla cargada sigue siendo la de anoche, **con sus valores**: "Rosa 65", "Lluvia 40" y "Trueno" con el nombre en `texto2`, su regla en hairline y a la derecha "pro · 30" (la palabra y el nivel que tenía: no se borra el valor, se guarda para cuando compre). Fila Marea: toggle off, subtítulo "Apagada · pro". Fila Temporizador: "Hasta dormirme · 45 min" (cabe en los 60 gratuitos; si tenía 90: "Hasta dormirme · 60 min · antes 90 · pro").
4. **Toca Play.** Suena rosa y lluvia. Línea de estado: "Sonando · sin trueno" ["Playing · without thunder"] durante la sesión: la honestidad de decir lo que falta, sin reproche. Ningún candado. La regla escribe.
5. **Toca "Trueno".** Suena 30 s mezclado a su nivel guardado; la regla de la fila se dibuja en `texto2`; a los 30 s sube la hoja Pro con "29,99 €" arriba. Mientras la hoja está abierta, el trueno se disuelve en 10 s; el resto sigue. Cierra la hoja: todo como antes. No hay límite de veces: puede escuchar 30 s de trueno cada noche de su vida.
6. **Si nunca compra:** la versalita "gratis · …" se queda para siempre en la cabecera (es el único recordatorio, y es información, no venta). Las filas "pro" no se mueven ni cambian de sitio. No hay notificación, correo, descuento ni cuenta atrás.

### 10.9 Compra y restauración

1. Entra a la hoja Pro desde: la versalita de cabecera, una fila "pro", el cuarto "Guardar como noche…", o Ajustes. Siempre la misma hoja; el precio ya está cargado porque `Product.products(for:)` se pide al abrir la app (una vez por sesión; sin red, el botón dice "Cargando precio…" en estado deshabilitado y la cifra grande muestra "—" hasta que llegue; si no llega en 8 s: "No se pudo cargar el precio. Comprueba la conexión." como nota bajo el botón; todo lo demás de la hoja se lee igual).
2. **Toca "Comprar · 29,99 €".** Sube la hoja del sistema de App Store (Face ID / contraseña). La nuestra queda debajo sin cambiar.
3. **Éxito.** La hoja del sistema se cierra; la nuestra muestra, en el lugar del botón, una línea paso 5 `texto` "Gracias. Todo abierto." ["Thank you. Everything's open."] durante 1,5 s y se cierra sola. Detrás, la versalita de cabecera ha desaparecido, las filas "pro" han recuperado nombre en `texto` y su nivel guardado; si el trueno estaba en previsualización, no se corta: sigue. Siente `.success` (está despierto, con luz, en una hoja). Ajustes: "SleepNoise Pro · gracias · 16 nov 2026".
4. **Cancelación.** La hoja del sistema se cierra y la nuestra queda igual. Sin mensaje: cancelar no es un error.
5. **Fallo** (`.failed`, red, tarjeta): bajo el botón, paso 8 `texto2`: "No se completó la compra. No se ha cobrado nada." ["The purchase didn't go through. Nothing was charged."] Botón intacto para reintentar. Nada rojo.
6. **Pendiente** (Ask to Buy): "Pendiente de aprobación familiar. Se abrirá solo cuando llegue." ["Waiting for family approval. It will unlock on its own."] La hoja se puede cerrar; al llegar la transacción, la app la aplica en silencio.
7. **Restaurar compra.** Botón de texto siempre visible bajo el primario. Al tocar: el texto cambia a "Buscando…" ["Looking…"] (sin spinner: texto), `AppStore.sync()`. Encontrada: como 3. No encontrada: "No hay ninguna compra con este Apple ID. Si la hiciste con otro, inicia sesión con él en la App Store." ["No purchase found for this Apple ID. If you bought with another one, sign in with it in the App Store."] Familia: la compra del organizador llega como `familyShared` y se aplica igual; el texto de Ajustes añade "· compartida en familia" ["· shared with family"].
8. **Reinstalar o cambiar de iPhone:** al primer arranque la app comprueba `Transaction.currentEntitlements` en silencio; si hay Pro, abre ya en Pro sin que la persona haga nada. Las noches guardadas viajan con la copia de iCloud del contenedor de la app (sin cuenta propia).

### 10.10 Noche guardada que pierde capas Pro

Situación: usuario gratuito tras la prueba; toca "Descenso" (océano 50 + Marea) en "Noches", o la segunda fila del widget mediano.

1. La noche se carga completa: la principal muestra "Descenso", fila "Océano · oleaje lento · 50" (océano es gratis), fila Marea con toggle off y subtítulo "6 por minuto · 15 min · pro" (la receta se conserva, la función espera). Si la noche tenía "Trueno 30": fila con nombre `texto2`, "pro · 30".
2. En la lista "Noches", la receta de cada noche sigue diciendo todo ("océano 50 · marea 6/min · 15 min"): no se tacha nada; lo Pro va en `texto2` dentro de la misma línea.
3. Toca Play: suena lo gratuito; estado "Sonando · sin marea" ["Playing · without tide"]. Si todas las capas de la noche son Pro (raro: "Hoguera y viento"): Play suena 30 s de la noche completa y sube la hoja Pro; al cerrarla sin comprar, el estado dice "En silencio · esta noche es Pro" y la regla queda en hairline. Nunca se sustituye por otra mezcla sin pedirlo.
4. Si compra, la noche vuelve a sonar entera al cerrar la hoja, con su Marea, sin recargarla.
5. Guardar cambios sobre una noche existente es gratis siempre (solo crear la cuarta pide Pro).

### 10.11 Interrupción por llamada y pausa de AirPods

**Llamada entrante / alarma / Siri / otra app toma la sesión** (`AVAudioSession.interruptionNotification`, `.began`):
- El sistema baja nuestro audio; la app marca estado "En pausa · llamada" ["Paused · call"] (o "· alarma", "· otra app"; no se distingue más que eso). Regla → hairline en 2 s si la pantalla está encendida; Live Activity: glifo play, versalita "en pausa"; Noche: "en pausa" bajo la hora. El temporizador se congela.
- `.ended` con `shouldResume`: la app reanuda con fundido de 800 ms y el temporizador retoma donde estaba. Sin `shouldResume` (la persona cortó): se queda en pausa; un toque en cualquier superficie reanuda. A los 20 min en pausa, la sesión termina y la Live Activity ofrece Madrugada.
- Nada se anuncia con sonido ni háptica: la llamada ya ha hecho bastante ruido.

**AirPods fuera de la oreja / desconectados** (`.routeChange`, `.oldDeviceUnavailable`):
- La app pausa con fundido de 1,5 s (nunca salta al altavoz de madrugada: despertaría a la pareja). Estado: "En pausa · auriculares" ["Paused · headphones"]. Bajo la línea de estado, un botón de texto durante 60 s: "Seguir por el altavoz" ["Keep playing on the speaker"]. En Noche: la palabra "en pausa" y el botón "+15 min" se sustituye por "Altavoz" ["Speaker"] durante esos 60 s. Pasados los 60 s, el botón desaparece; un toque normal reanuda por la salida que haya.
- Al volver a conectar los auriculares en < 20 min: reanuda sola con 800 ms (es lo que la persona espera al volver a ponérselos).

**Pausa de AirPods al dormirse (iOS 26, `pauseCommand` de Now Playing)** **[mecanismo a confirmar en prototipo]**:
- Fundido de 3 s de audio, 2 s de interfaz. Estado: "En pausa · AirPods" ["Paused · AirPods"]; en la Live Activity, versalita "se pausó a las 00:12 · airpods" ["paused at 00:12 · airpods"] con el glifo play. No reanuda sola (los AirPods han decidido que duerme; reanudar sería contradecirlos). El temporizador se da por terminado: la sesión acaba como si hubiera fundido. Madrugada queda disponible en la actividad.
- Ajuste en la hoja del temporizador, bajo "Fundido por quietud": nota "Si tus AirPods pausan el sonido al dormirte, SleepNoise lo respeta y no lo reanuda." ["If your AirPods pause sound when you fall asleep, SleepNoise respects that and won't resume."]

### 10.12 Error de audio

Hay dos y ninguno es rojo.

**No arranca** (sesión denegada: FaceTime activo, grabación en curso, hardware ocupado): al tocar Play, el glifo pasa a pausa 200 ms y vuelve a play; bajo la regla, en el lugar de la línea de estado: "No se pudo iniciar el audio. Toca para reintentar." ["Couldn't start audio. Tap to try again."] en paso 7 `texto2`. La frase es un botón de 44 pt. Si falla tres veces seguidas: "Cierra las apps que usen el micrófono o el altavoz y vuelve a intentarlo." ["Close apps using the microphone or speaker and try again."] Ningún háptico `.error` (la persona no está en una hoja de compra). VoiceOver anuncia la línea con `.announcement`.

**Se cae a mitad** (`mediaServicesWereReset`, fallo del motor): la app reconstruye el grafo y reanuda sola con 800 ms, sin decir nada, en < 1 s. Si no puede: estado "En pausa · se interrumpió el audio" ["Paused · audio was interrupted"]; la Live Activity pasa a play; en Noche, "en pausa". Un toque reintenta. El temporizador se congela, no se pierde.

**Nunca:** alerta modal, sonido, vibración, pantalla roja, código de error en pantalla (el código va al log de diagnóstico que la persona puede exportar desde Ajustes › "Diagnóstico").

## 11. Especificación de movimiento

Todo lo que se mueve en Grafito, con su causa física. Lo que no está en esta tabla no se mueve. Curvas: `.easeInOut` = `UIView` ease-in-out estándar; `.easeOut`; `BreathCurve` = la del motor. Reduce Motion (RM) y `isLuminanceReduced` / StandBy (AO) en columnas propias.

| # | Qué se mueve | Causa física | Duración | Curva | Reduce Motion | Always-On / StandBy / Noche |
|---|---|---|---|---|---|---|
| M1 | Regla del sonido: de hairline a trazo rojo, empieza a escribir | Arranque del motor (RMS sube de 0) | 800 ms hasta amplitud real | `.easeOut` (como la ganancia) | Fundido de color 800 ms; después grosor 1-2 pt a 4 Hz, τ 1,5 s | Congelada a hairline en ≤ 2 s; en Noche no existe (regla estática 96 pt) |
| M2 | Regla del sonido escribiendo | RMS por capa, ≤ 20 Hz, τ 400-800 ms | continua | lectura del motor | ver M1 | pausada |
| M3 | Regla del sonido: parada / fin de fundido | Ganancia → 0 | 1,5-2 s | `.easeInOut` | igual (es opacidad y amplitud) | igual |
| M4 | Regla de nivel bajo el dedo: 1 → 1,5 pt y `texto` → rojo; pista `grafito` aparece; valor 13 → 17 pt | Dedo sobre la fila | 150 ms entrada / 250 ms salida | `.easeInOut` | igual (no hay posición: es grosor, color y tamaño de texto; se admite porque sigue al dedo) | n/a |
| M5 | Regla de nivel: longitud sigue al dedo | Dedo | 0 (directo) | — | igual | n/a |
| M6 | Línea de agua: banda se abre de 24 a 120 pt y el contenido baja 96 pt | Activar la Marea | 800 ms | `.easeInOut` | Fundido cruzado 250 ms, sin desplazamiento | n/a |
| M7 | Línea de agua: sube / baja | `BreathCurve` del audio, periodo 5-15 s | continua | `BreathCurve` (4:6) | Posición fija a media banda; opacidad 0,45 → 1,0 con la misma curva | Quieta en bajamar; en Noche no se dibuja |
| M8 | Palabra "inhala" / "exhala" | Fase de la curva | 250 ms fundido | opacidad | igual | n/a |
| M9 | Disolución de la Marea: amplitud → 0 | Modulación del audio se abre | últimos 20 % de la duración | lineal sobre la amplitud (la curva interna sigue siendo `BreathCurve`) | opacidad → 0,45 | n/a |
| M10 | Play ↔ Pausa | Estado del motor | 200 ms | `.contentTransition(.symbolEffect(.replace))` (fundido) | igual | Live Activity: cambio inmediato en la siguiente actualización |
| M11 | Línea de estado ("Sonando" ↔ "En pausa") | Estado | 250 ms | opacidad | igual | — |
| M12 | Página → Noche | Bloqueo / "Noche" / 60 s | 2 s a negro, luego reloj aparece 500 ms | `.easeInOut` | 250 ms fundido | — |
| M13 | Noche → página | Pulsación larga | 250 ms | opacidad | igual | — |
| M14 | Regla de Noche: `texto` ↔ ausente ↔ `trazo` | Estado / fundido final | 250 ms | opacidad | igual | Es la única cosa de Noche que cambia; a 1 Hz como máximo |
| M15 | Reloj de Noche | Tiempo | 1 Hz, sin animación entre dígitos | — | — | 1 Hz en Always-On; `Text(.time)` del sistema |
| M16 | "+15 min" → cifra nueva | Toque | 250 ms | `.contentTransition(.numericText())` | opacidad | — |
| M17 | Regla vertical de volumen (Noche) aparece / sigue al dedo / desaparece | Dedo | 150 / 0 / 250 ms | `.easeInOut` | igual | — |
| M18 | Fila pulsada: fondo `grafito` | Toque | 200 ms | `.easeInOut` | igual | — |
| M19 | Hojas | Sistema | sistema | sistema | sistema | — |
| M20 | Línea de timbre "más cálido ◂ ▸ más lejano" aparece bajo la fila | Pulsación larga | 250 ms, la fila crece 24 pt | `.easeInOut` | fundido sin crecimiento (se superpone) | — |
| M21 | Descomposición de la regla en una línea por capa | Pulsación larga sobre la regla | 400 ms | `.easeInOut` | fundido | — |
| M22 | Nota de 10 s ("Se retiró a las 23:27") | Fin de Marea | 250 ms in / 500 ms out | opacidad | igual | — |
| M23 | Cambio de estado de prueba a gratis | Nueva sesión | 0: ocurre entre sesiones, nunca se ve animado | — | — | — |
| M24 | Live Activity: regla estática | Nivel maestro al emitir | 0 | — | — | 2 pt, estática |
| M25 | Watch: línea de agua | `BreathCurve` sincronizada por `WCSession` | continua | `BreathCurve` | opacidad | Always-On del Watch: quieta en bajamar |

Reglas transversales: nada rebota; ninguna animación finita dura más de 2 s; ninguna animación infinita que no sea el sonido (M2, M7, M25); con la pantalla apagada, 0 fotogramas; todo `TimelineView` lleva `paused:` ligado a `scenePhase`, `isLuminanceReduced` y "suena algo"; cero cambios de luminancia a más de 3 Hz (WCAG 2.3.1) por construcción (τ ≥ 300 ms).

## 12. Háptica

Se adopta 02 §4 íntegro. Lo propio de Grafito, por gesto y superficie:

| Gesto | iPhone | Watch | Anuncio VoiceOver equivalente |
|---|---|---|---|
| Play (barra, página) | `.impact(.medium, 0.7)` una vez, al inicio del fundido de 800 ms | `.start` | "Sonando" |
| Pausa (barra, página) | `.impact(.light, 0.5)` | `.stop` | "En pausa" |
| Toque en Noche / Madrugada (pausa o reanuda) | **ninguna**: lo confirma el sonido | `.click` (en la muñeca no suena) | "En pausa" / "Sonando" |
| Pulsación larga en Noche (volver) | `.impact(.light, 0.4)` al cumplirse 0,6 s | — | "Página" |
| Arrastre de nivel: cruzar 0 | `.selection` | Digital Crown: detents del sistema | valor hablado |
| Arrastre de nivel: llegar a 100 | `.impact(.light, 0.6)` | `.notification` suave | "Máximo" |
| Arrastre de nivel: pasos intermedios | ninguna | — | — |
| Arrastre vertical de volumen en Noche | ninguna | — | "Volumen 40 por ciento" |
| Toggle de Marea | el del sistema (`Toggle` lo trae) | `.click` | "Marea respiratoria, activada" |
| Marea guiando ("Mínima") | Core Haptics continuo, 3-5 respiraciones, solo si el iPhone se sostiene (CoreMotion) | `.directionUp` al inicio de cada inhalación, **toda la guía** | opcional: "inhala" / "exhala" |
| Marea guiando ("Marcada") | lo anterior + transitorio 0,3 / 40 ms al inicio de cada inhalación durante toda la guía | `.directionUp` + `.directionDown` al inicio de la exhalación | idem |
| Marea disolviendo | ninguna | la intensidad del `.directionUp` no se puede modular: se espacia (una de cada dos respiraciones, luego ninguna) | "disolviendo" |
| Fin de Marea, fin de temporizador, fundido por quietud | **ninguna** | ninguna | ninguna (duerme) |
| +15 min | `.selection` | `.click` | "Quedan 53 minutos" |
| Guardar noche | `.success` | — | "Guardada" |
| Compra completada | `.success` (está en la hoja) | — | "Gracias. Todo abierto." |
| Fallo de compra | `.error` (está en la hoja) | — | texto del fallo |
| Error de audio, interrupción, prueba caducada | ninguna | ninguna | anuncio de la línea de estado |
| Abrir hoja Pro, mostrar precio | ninguna (nunca marketing) | — | — |

Cuándo callar (además de 02 §4.3): si "Háptica del sistema" está desactivada; si el iPhone está quieto y horizontal (mesilla); durante cualquier fundido; en Noche y Madrugada salvo la salida por pulsación larga; en segundo plano. La Marea háptica del iPhone se destruye al terminar la guía (`CHHapticEngine` liberado); la del Watch vive en la app del Watch, no en el iPhone.

## 13. Superficies del ecosistema, dibujadas en palabras

Gramática común a todas: **una tinta (`texto`), un control, estado por forma, el nombre de la noche como título, la regla como firma.** El rojo grafito no aparece en ninguna (1.1). Texto ≥ 15 pt Medium; cifra ≥ 28 pt; glifos de 2 pt de trazo. Fondos negros declarados removibles para que StandBy los quite.

### 13.1 Live Activity

Estados: **sonando**, **en pausa**, **fundiendo** (últimos 10 min), **guiando** (Marea), **terminada** (ofrece Madrugada; se mantiene hasta 4 h o hasta que la persona la descarte), **madrugada** (20 min).

**Bloqueo** (393 × 132 pt, `activityBackgroundTint(.black)`, esquinas del sistema):
- Fila superior: izquierda, nombre de la noche SF Pro Semibold 17 `texto`, una línea con `minimumScaleFactor(0.8)`; debajo versalita 13 Medium `texto` "sonando · hasta dormirme" / "en pausa" / "fundiendo" / "guiando · 6 por minuto" / "madrugada". Derecha: tiempo restante 28 Medium tabular `texto` con `Text(timerInterval:countsDown:)`; en Escudo nocturno, "hasta las 7:00"; terminada, nada.
- Fila inferior: la regla (1,5 pt `texto`, amplitud = nivel maestro al emitir; `trazo` en pausa; en guiando, una línea recta a media banda entre las dos marcas, porque la actividad no anima) y, a la derecha, el único botón: glifo pausa / play 44 × 44 pt (`AudioPlaybackIntent`). En **terminada**: fila inferior "madrugada · 20 min" en versalita + glifo play; el intent arranca Madrugada.
- Toque en cualquier otra zona: abre la app en Noche (si suena) o en la página (si no).

**Dynamic Island**:
- **Compacta**: leading, glifo pausa (sonando) / play (pausa) 16 pt `texto`; trailing, "38 m" 15 Medium tabular (Escudo: "7:00"; Marea guiando: alterna cada 10 s entre "38 m" y "6/min"; madrugada: "20 m"). Toque: abre la app.
- **Mínima** (otra actividad ocupa la isla): el glifo solo, 14 pt.
- **Expandida** (pulsación larga; 371 × 160 máx.): misma gramática que el bloqueo más una fila de dos botones de texto 44 pt bajo la regla: "+15 min" y "Noche" (abre la app en Noche). En madrugada, "+10 min" y "Parar" ["Stop"]: la única vez que aparece la palabra "Parar", porque a las 3 un glifo de pausa que deja el temporizador vivo no es lo que se busca.

**Actualizaciones**: solo al cambiar de estado, al cruzar hitos del temporizador (inicio del fundido) y al prolongar; nunca periódicas. Presupuesto < 4 KB. Sesión > 8 h: la actividad cubre el primer tramo y se reemite al despertar el proceso por audio… **[a verificar: ActivityKit no permite reemitir sin interacción; plan B: el widget cubre el resto]**.

### 13.2 StandBy nocturno

La Live Activity a pantalla completa (`isActivityFullscreen`) y el widget pequeño en el modo de widgets. Diseñados en rojo primero (maqueta: multiplicación por rojo):
- Pantalla completa (852 × 393): nombre 34 Semibold; versalita 22; tiempo 96 Regular tabular con "min" en 40 Medium; regla de 2 pt de margen a margen (708 pt); glifo 88 pt abajo a la derecha, área 88 × 88. Todo `texto` → 4,3-4,4:1 bajo rojo. Nada más.
- Widget pequeño en StandBy: 13.3 sin fondo; el sistema lo tiñe entero.
- No hay animación en StandBy ni siquiera cuando el sistema lo permite: la regla está quieta siempre.

### 13.3 Widgets

- **Pequeño** (158 × 158, interactivo): nombre de la última noche New York Medium 17 `texto` arriba a la izquierda (dos líneas máx.); abajo a la izquierda versalita 13 "sonando" / "en silencio" / "quedan 38 min"; abajo a la derecha botón 44 × 44 con glifo play / pausa 28 pt. Toque fuera del botón: abre la app. `containerBackgroundRemovable(true)`; en `accented`, el nombre va en la capa de acento y el glifo en la primaria (ambos monocromos: se leen igual).
- **Mediano** (338 × 158): izquierda, lo mismo; hairline vertical `trazo`; derecha, tres noches guardadas (las tres primeras de la lista, reordenables en la app) como filas de 44 pt: nombre New York 15 + versalita de receta. Cada fila es un botón: carga **y reproduce** (un widget que solo carga obliga a dos toques). Si una noche tiene capas Pro y el usuario es gratuito, suena lo gratuito (10.10) y la app no se abre.
- **Bloqueo circular**: glifo play / pausa 2 pt en `texto`; con `AccessoryWidgetBackground`. Toque: `AudioPlaybackIntent` directo (iOS 17 permite botones en accesorios).
- **Bloqueo rectangular**: nombre 15 Semibold, versalita con tiempo, glifo a la derecha.
- **Inline**: "SleepNoise · quedan 38 min" / "SleepNoise · en silencio".
- Día (apariencia clara): fondo `papel`, tinta `tinta`; sin rojo también.

### 13.4 Centro de control y botón de Acción

- **Toggle "SleepNoise"** (`ControlWidgetToggle`, iOS 18): símbolo propio "pendiente rosa" en off (línea con −3 dB/oct, monocromo); en on, el sistema tiñe el fondo con el color de tinte de la app (`grafito-rojo`; único lugar del sistema donde se pinta, sobre el gris del Centro de control **[a medir]**). Título "SleepNoise"; subtítulo en on "Rosa y lluvia · 38 min", en off "Última: Rosa y lluvia". `SetValueIntent` → arranca / pausa la última noche con los fundidos normales.
- **Botón "Madrugada"** (`ControlWidgetButton`): símbolo "línea de agua"; subtítulo "20 min". Arranca Madrugada (10.7). No tiene estado on.
- **Botón de Acción**: ofrece ambos; pista del toggle "Mantén para dormir" ["Hold for sleep"], del botón "Mantén para Madrugada" ["Hold for Small hours"].
- iOS 17: ausentes; el Atajo cubre el caso.

### 13.5 Apple Watch (mínimo)

App autónoma de una sola jerarquía, SF Compact, fondo negro, sin acento, sin corona de progreso:

- **Pantalla 1 · Mando** (lo que se ve al abrir, si el iPhone suena o sonó hace menos de 12 h): nombre de la noche 15 Medium `texto` arriba; centro, glifo pausa / play 44 pt en botón de 64 × 64 (toda la zona central es el botón); abajo, "+15 min" botón de texto 44 pt a todo el ancho; Digital Crown = volumen maestro con la regla vertical de 1 pt a la derecha mientras gira (y los detents del sistema). Si no suena nada: el glifo es play y bajo él "Descenso" (la última noche); debajo, "Madrugada · 20 min" como segundo botón de texto. Nunca más de dos botones.
- **Pantalla 2 · Marea** (deslizar a la izquierda, solo si la Marea está activa o disponible): la línea de agua a 1,5 pt `texto` en una banda de 80 pt con sus dos marcas; debajo versalita "6 por minuto · 12 min". Háptica: `.directionUp` en cada inhalación ("Mínima"); "Marcada" añade `.directionDown` en la exhalación. La muñeca es la superficie natural de la Marea háptica: no suena sobre la mesilla y sigue en segundo plano mientras la app del Watch esté en primer plano con la sesión extendida (`WKExtendedRuntimeSession` de tipo mindfulness: hasta 1 h, la cubre entera). Si la sesión expira, la línea se queda y la háptica para; no hay aviso.
- **Smart Stack**: la misma tarjeta que la Live Activity de bloqueo: nombre, tiempo, glifo. Relevancia: alta de 21:00 a 08:00.
- **Complicación** (circular / rectangular / esquina): glifo de pendiente rosa; rectangular con tiempo.
- Sincronización: `WCSession` lleva estado, nombre y ancla de la curva (`guide.anchor`) para que la línea del Watch respire a la vez que el audio del iPhone (± la latencia de salida).
- Lo que el Watch no hace: mezclar capas, mostrar precios, pedir Pro (si la noche es Pro y el usuario gratuito, suena lo gratuito; nada más).

### 13.6 Siri y Atajos (App Intents)

Intents expuestos, con frases de ejemplo que la app registra (`AppShortcutsProvider`), ES / EN:

| Intent | Frases ES | Frases EN | Resultado |
|---|---|---|---|
| `PlayLastNight` (`AudioPlaybackIntent`) | "Pon SleepNoise", "Reproduce SleepNoise", "Duerme con SleepNoise" | "Play SleepNoise", "Start SleepNoise", "Put on SleepNoise" | Última noche, fundido 800 ms; sin diálogo |
| `PlayNight(name)` | "Pon la noche Descenso en SleepNoise", "Pon Lluvia constante en SleepNoise" | "Play Descent in SleepNoise", "Play Steady rain in SleepNoise" | Carga y reproduce; si no existe, Siri ofrece la lista |
| `PlayLayer(layer, level?)` | "Pon lluvia en SleepNoise", "Pon ruido rosa en SleepNoise" | "Play rain in SleepNoise", "Play pink noise in SleepNoise" | Mezcla de una capa a 50 |
| `Pause` / `Resume` | "Pausa SleepNoise", "Sigue SleepNoise" | "Pause SleepNoise", "Resume SleepNoise" | Fundidos normales |
| `ExtendTimer(minutes)` | "Añade quince minutos en SleepNoise", "Alarga SleepNoise" | "Add fifteen minutes in SleepNoise", "Extend SleepNoise" | +15 por defecto |
| `SetTimer(mode, length?)` | "Pon el escudo nocturno en SleepNoise", "SleepNoise hasta dormirme" | "Set night shield in SleepNoise", "SleepNoise until I fall asleep" | Como la hoja |
| `StartSmallHours` | "Madrugada en SleepNoise", "Empieza Madrugada" | "Small hours in SleepNoise", "Start Small hours" | 10.7 |
| `ToggleTide(on/off)` | "Activa la Marea en SleepNoise" | "Turn on the tide in SleepNoise" | Si gratuito: 30 s y nada más (Siri no vende) |
| `SetMasterVolume(percent)` | "SleepNoise al cuarenta por ciento" | "SleepNoise at forty percent" | — |
| `CurrentState` (consulta) | "¿Qué suena en SleepNoise?" | "What's playing in SleepNoise?" | Respuesta hablada: "Rosa y lluvia, quedan 38 minutos." |

Automatización recomendada (guiada desde Ajustes › "Al acostarte", dos pantallas de texto con capturas del sistema): "Cuando se active Sueño → Pon SleepNoise" con "Ejecutar al bloquear" y sin preguntar. Siri nunca habla encima del sonido: todos los intents de reproducción son `AudioPlaybackIntent`, que el sistema trata sin diálogo.

### 13.7 Focus de Sueño

`Focus filter` ("SleepNoise en este modo de concentración") con dos parámetros:
- **Abrir en**: "Noche" / "Página" (por defecto Noche en Sueño).
- **Noche al activar**: una noche guardada o "La última". No arranca el sonido (un filtro no puede): deja la noche cargada y la app abre con Play a un toque; el arranque automático es cosa de la automatización de 13.6.
Cuando el filtro de Sueño está activo, la app además oculta la cabecera editorial (versalita de prueba) y entra en Noche a los 60 s aunque el ajuste diga 3 min. Al salir de Sueño (mañana), todo vuelve.

## 14. Accesibilidad

### 14.1 Orden de VoiceOver por pantalla

El orden sigue la pregunta de la pantalla: primero el estado, después lo que se puede cambiar, al final la navegación. La barra inferior es `accessibilitySortPriority` alta solo para Play.

**Página (principal)**: 1 Play/Pausa (barra) → 2 estado de prueba (cabecera) → 3 nombre de la mezcla (editable) → 4 regla del sonido (imagen con valor) → 5 línea de estado → 6 cada capa que suena (ajustable) → 7 "Todas las capas" → 8 Marea (toggle) + su subtítulo como valor → 9 Temporizador → 10 "Noches" → 11 "Noche". Play va primero porque es lo que se busca a oscuras; VoiceOver con la pantalla apagada (cortina) también lo encuentra con un deslizamiento.

**Capas**: 1 Atrás → 2 título → 3 Play (barra) → 4 "colores", encabezado → 5-7 Blanco, Rosa, Marrón → 8 "camas", encabezado → 9-19 las ocho camas → 20 nota.

**Marea (hoja)**: 1 título → 2 texto de instrucción → 3 línea de agua (imagen; valor "inhala, seis por minuto, se retira en doce minutos") → 4 toggle Marea → 5 Ritmo → 6 Descenso → 7 Se retira a los → 8 Háptica → 9 Anuncios de voz (fila solo visible con VoiceOver: "Decir inhala y exhala") → 10 nota y enlace.

**Temporizador (hoja)**: 1 título → 2 cuenta atrás (valor hablado "treinta y ocho minutos y doce segundos") → 3 "+15 min" → 4-7 modos → 8 Duración → 9 Fundido por quietud → 10 nota.

**Noche**: 1 "Volver a la página" (botón invisible al principio) → 2 reloj → 3 estado ("Sonando" / "En pausa" / "Fundiendo") → 4 tiempo → 5 Play/Pausa (la pantalla, como botón) → 6 Volumen (ajustable) → 7 "+15 min".

**Madrugada**: 1 Volver → 2 estado → 3 tiempo → 4 Play/Pausa → 5 Volumen.

**Noches**: 1 Atrás → 2 título → 3 cada noche (botón; acciones personalizadas Renombrar, Eliminar, Mover) → 4 texto de vacío si procede.

**Pro (hoja)**: 1 "SleepNoise Pro" → 2 precio → 3 titular → 4-8 lo que incluye → 9 lo que sigue gratis → 10 Comprar → 11 Restaurar → 12 pie.

**Qué sabemos y qué no**: encabezados por entrada (rotor "Encabezados" salta de afirmación en afirmación).

### 14.2 Etiquetas, valores y pistas por control

| Control | Etiqueta ES [EN] | Valor | Pista ES [EN] | Rasgos / acciones |
|---|---|---|---|---|
| Play / Pausa | "Reproducir" / "Pausar" ["Play" / "Pause"] | — | "Suena en un segundo." ["Starts in a second."] | `.button`; `.startsMediaSession` |
| Cabecera de prueba | "Prueba, quedan cinco noches" ["Trial, five nights left"] | — | "Toca para ver qué incluye Pro." ["Tap to see what's in Pro."] | `.button` |
| Nombre de la mezcla | "Nombre de la mezcla" ["Mix name"] | "Rosa y lluvia" | "Toca dos veces para cambiarlo. Mantén para guardar como noche." ["Double-tap to edit. Hold to save as a night."] | `.button`; acciones: Guardar como noche, Renombrar, Vaciar |
| Regla del sonido | "Sonido" ["Sound"] | "Sonando, nivel medio" / "En silencio" ["Playing, medium level" / "Silent"] | — | `.image`; `.updatesFrequently`; Audio Graph |
| Línea de estado | (texto tal cual) | — | — | `.staticText`; anuncios al cambiar |
| Fila de capa | "Rosa, suave y equilibrado" ["Pink, soft and balanced"] | "65 por ciento" ["65 percent"] | "Desliza arriba o abajo para ajustar. Toca dos veces para silenciar o recuperar." ["Swipe up or down to adjust. Double-tap to mute or restore."] | `.adjustable` (pasos 5); acciones: Silenciar, Máximo, Timbre más cálido, Timbre más lejano |
| Fila de capa Pro (gratuito) | "Trueno, lejano, sin rayos cerca, requiere Pro" ["Thunder, far off, no close strikes, requires Pro"] | "en silencio" ["silent"] | "Toca dos veces para escucharlo treinta segundos." ["Double-tap to hear it for thirty seconds."] | `.button` |
| Todas las capas | "Todas las capas, once" ["All layers, eleven"] | — | — | `.button` |
| Toggle Marea | "Marea respiratoria" ["Breathing tide"] | "Activada, seis por minuto, se retira a los quince minutos" / "Desactivada" ["On, six per minute, fades at fifteen minutes" / "Off"] | — | `Toggle` del sistema |
| Línea de agua | "Marea" ["Tide"] | "Inhala" / "Exhala", "seis por minuto, se retira en doce minutos" | — | `.image`; `.updatesFrequently`; anuncios opcionales |
| Ritmo | "Ritmo" ["Pace"] | "Tranquilo, seis por minuto" | "Mantén para el ajuste exacto." ["Hold for the exact setting."] | `.button`; acción: Ajuste exacto (stepper) |
| Temporizador (fila) | "Temporizador" ["Timer"] | "Hasta dormirme, quedan treinta y ocho minutos" | — | `.button` |
| Modo de temporizador | "Hasta dormirme, cuarenta y cinco minutos, se funde los últimos diez" | "seleccionado" | — | `.button`, `.isSelected` |
| Escudo nocturno (gratuito) | "Escudo nocturno, hasta las siete, requiere Pro" | — | "Toca dos veces para probarlo treinta segundos." | `.button` |
| +15 min | "Quince minutos más" ["Fifteen more minutes"] | — | — | `.button`; tras tocar, anuncio "Quedan cincuenta y tres minutos" |
| Pantalla Noche | "Pantalla de noche" ["Night screen"] | "Tres y siete. Sonando. Quedan treinta y ocho minutos." | "Toca dos veces para pausar. Desliza con tres dedos arriba o abajo para el volumen. Mantén para volver." ["Double-tap to pause. Three-finger swipe up or down for volume. Hold to go back."] | `.button`; rotor Volumen (`.adjustable` propio) |
| Volumen (Noche) | "Volumen" ["Volume"] | "40 por ciento" | — | `.adjustable` |
| Volver (Noche) | "Volver a la página" ["Back to the page"] | — | — | `.button`; `accessibilityHidden(false)` solo con VoiceOver |
| Noche guardada | "Descenso, océano cincuenta, marea seis por minuto quince minutos" | — | "Toca dos veces para cargarla." ["Double-tap to load."] | `.button`; acciones: Renombrar, Eliminar, Subir, Bajar |
| Comprar | "Comprar SleepNoise Pro por veintinueve con noventa y nueve euros" ["Buy SleepNoise Pro for twenty-nine ninety-nine"] | — | "Un solo pago. Abre la confirmación de App Store." ["One payment. Opens the App Store confirmation."] | `.button` |
| Restaurar | "Restaurar compra" ["Restore purchase"] | — | — | `.button` |
| Reintentar audio | "No se pudo iniciar el audio. Reintentar" | — | — | `.button`; anuncio `.announcement` al aparecer |
| Live Activity botón | "Pausar SleepNoise" / "Reproducir SleepNoise" | — | — | `.button` |
| Widget fila de noche | "Lluvia constante, lluvia cincuenta y cinco, rosa veinte. Reproducir." | — | — | `.button` |
| Watch pantalla central | "Pausar" / "Reproducir" | "Rosa y lluvia, quedan treinta y ocho minutos" | — | `.button` |

El sonido y VoiceOver conviven: la sesión usa `.playback` con `mixWithOthers` deshabilitado pero `duckOthers` lo gestiona el sistema para la voz de VoiceOver; la cama baja 12 dB mientras VoiceOver habla y vuelve en 1 s.

### 14.3 Dynamic Type hasta AX5: qué se reorganiza

| Pantalla | Large (defecto) | xxxLarge | AX1-AX3 | AX4-AX5 |
|---|---|---|---|---|
| Página | Cabe sin scroll: 2 capas + 3 filas | Cabe con 2 capas; el aire de 578-760 se consume | `ScrollView`; fila de capa 96 pt: nombre, subtítulo y valor en columna, regla debajo; "Todas las capas" sin el "11" | Igual; el nombre de la mezcla (New York 28 → escala con `.title1`, tope AX3 = 40 pt) pasa a dos líneas; la barra inferior conserva 83 pt y "Noches" / "Noche" pasan a glifos monocromos (`square.stack` y `circle.lefthalf.filled`; nunca una luna) con etiquetas accesibles; Play no cambia |
| Capas | 11 filas de 76 | 11 × 88 | 11 × 96 apiladas; encabezados de sección mantienen versalitas (escalan con `.footnote`) | Igual; valor bajo el nombre en 17 pt |
| Marea (hoja) | `.large` | igual | La banda de la línea de agua mantiene 120 pt (no escala: es gráfica); las filas se apilan; la hoja desplaza | Igual; "inhala" / "exhala" a la izquierda bajo la banda en vez de a la derecha |
| Temporizador | `.medium` → `.large` | `.large` | Cifra 56 → tope AX2 (≈ 80 pt); "+15 min" baja debajo de la cifra, a todo el ancho | Igual |
| Noche | 72 / 22 / 17 | igual (Noche no escala con Dynamic Type por debajo de AX: ya es grande) | Reloj tope AX2 (≈ 100 pt); "38 min" 28; "+15 min" 22 | Igual; nada se corta porque solo hay cuatro elementos |
| Noches | 72 pt por fila | 88 | Nombre + receta en columna, 110 pt | Igual |
| Pro | todo en una pantalla | desplaza | Precio tope AX2; lista de 44 → 56 por fila; botón primario 56 → 64 con texto en dos líneas si hace falta | Igual |
| Live Activity / widgets | tamaños del sistema | — | el sistema limita; el nombre lleva `minimumScaleFactor(0.8)` y el tiempo `(0.7)` | — |

Con "Button Shapes": los botones de texto ("Noches", "Noche", "+15 min", "Entendido", "Restaurar compra") muestran contorno del sistema; el Play trazado ya es forma. Con "Bold Text": todo SF escala de peso solo; New York también. Con "Incrementar contraste": `texto2-ac`, `grafito-rojo-ac`, trazo del Play a 2 pt, hairline `trazo` a `#3A3836`.

### 14.4 Alternativa sin gestos para cada gesto

| Gesto | Dónde | Alternativa |
|---|---|---|
| Arrastre horizontal sobre la fila (nivel) | Página, Capas | VoiceOver: `.adjustable` (deslizar arriba/abajo); Control por conmutador y Control por voz: acciones "Subir", "Bajar", "Silenciar", "Máximo"; Full Keyboard Access: flechas; además, pulsación larga en la fila abre un `Slider` del sistema de 44 pt bajo la regla ("Ajuste con deslizador") para quien no quiera el gesto |
| Toque en la fila (0 ↔ último) | Página, Capas | Acción "Silenciar" / "Recuperar" |
| Pulsación larga (timbre) | Página, Capas | Acciones "Timbre más cálido" / "Timbre más lejano"; Control por voz: "Mostrar timbre" |
| Pulsación larga sobre la regla (una línea por capa) | Página | Acción "Ver capas por separado"; en VoiceOver el Audio Graph ya ofrece capa por capa |
| Pulsación larga sobre el nombre (menú) | Página | El menú es `contextMenu`, que VoiceOver expone como acciones; Control por voz: "Mostrar menú" |
| Toque en toda la pantalla (pausa) | Noche, Madrugada | Elemento `.button` "Pantalla de noche"; Control por conmutador lo recibe como un botón único |
| Arrastre vertical (volumen) | Noche, Madrugada | Rotor "Volumen" (ajustable); Control por voz: "Volumen cuarenta"; botones físicos de volumen del iPhone (siempre funcionan) |
| Pulsación larga 0,6 s (volver) | Noche, Madrugada | Botón "Volver a la página" al principio del orden; gesto de dos dedos en Z (escape) de VoiceOver; Control por voz: "Volver" |
| Doble toque (Madrugada desde Noche) | Noche | Acción "Empezar Madrugada" en el elemento de pantalla |
| Deslizar fila (renombrar / eliminar) | Noches | Acciones personalizadas; modo edición estándar |
| Arrastrar para cerrar hoja | Hojas | Gesto de escape de VoiceOver; en iOS 26 el botón de cierre del sistema; Control por voz: "Cerrar" |
| Reordenar noches | Noches | Acciones "Subir" / "Bajar"; modo edición |
| Digital Crown (volumen) | Watch | Botón "Volumen" con `.adjustable` |
| Raise to wake + toque (Madrugada) | Bloqueo | Siri "Madrugada en SleepNoise"; botón de Acción; Centro de control |

Ningún gesto es la única vía. Ningún gesto es de varios dedos ni de pellizco.

## 15. Textos de interfaz definitivos · ES / EN

Voz: corta, concreta, serena; segunda persona sin exclamaciones; sin diminutivos, sin emojis, sin mayúsculas sostenidas; las versalitas son tipográficas, aquí escritas en minúscula. El inglés no se traduce del español ni al revés: se escribe. "Temporizador", "mezcla", "noche", "de por vida"; nunca "timer", "mix", "preset", "vitalicio". Cero vocabulario médico (lista negra del brief §7.2). Lo que ya está en la Parte I se repite aquí solo si cambia o para que esta tabla sea la única fuente.

### 15.1 Página

| Clave | ES | EN |
|---|---|---|
| estado.silencio | En silencio | Silent |
| estado.sonando | Sonando | Playing |
| estado.sonando.funde | Sonando · se funde a las {hora} | Playing · fades at {time} |
| estado.sonando.sin | Sonando · sin {capas} | Playing · without {layers} |
| estado.sonando.defecto | Sonando · rosa a 50 | Playing · pink at 50 |
| estado.pausa | En pausa | Paused |
| estado.pausa.llamada | En pausa · llamada | Paused · call |
| estado.pausa.alarma | En pausa · alarma | Paused · alarm |
| estado.pausa.auriculares | En pausa · auriculares | Paused · headphones |
| estado.pausa.airpods | En pausa · AirPods | Paused · AirPods |
| estado.pausa.interrumpido | En pausa · se interrumpió el audio | Paused · audio was interrupted |
| estado.fundiendo | Fundiendo | Fading |
| estado.pro.noche | En silencio · esta noche es Pro | Silent · this night is Pro |
| accion.altavoz | Seguir por el altavoz | Keep playing on the speaker |
| cabecera.prueba | prueba · quedan {n} noches | trial · {n} nights left |
| cabecera.prueba.1 | prueba · última noche | trial · last night |
| cabecera.gratis | gratis · blanco, rosa, marrón, lluvia y 60 min | free · white, pink, brown, rain and 60 min |
| prueba.bienvenida | Siete noches con todo. Sin tarjeta. Después seguirán gratis blanco, rosa, marrón, lluvia y 60 minutos; tus noches guardadas se conservan. | Seven nights with everything. No card. After that, white, pink, brown, rain and 60 minutes stay free; your saved nights are kept. |
| prueba.ultima | Mañana seguirán gratis blanco, rosa, marrón, lluvia y 60 minutos. Tus noches guardadas se conservan. | From tomorrow, white, pink, brown, rain and 60 minutes stay free. Your saved nights are kept. |
| prueba.terminada | La prueba terminó. Lo que usaste sigue aquí; las capas Pro, la Marea y el temporizador largo esperan a Pro. | The trial is over. What you used is still here; the Pro layers, the tide and the long timer wait for Pro. |
| boton.entendido | Entendido | Got it |
| capas.todas | Todas las capas | All layers |
| capas.mas | y {n} capas más | and {n} more layers |
| capa.pro | pro | pro |
| capa.pro.nivel | pro · {n} | pro · {n} |
| menu.guardar | Guardar como noche… | Save as a night… |
| menu.renombrar | Renombrar | Rename |
| menu.vaciar | Vaciar la mezcla | Clear mix |
| mezcla.nombre.auto | {Capa} y {capa} | {Layer} and {layer} |
| marea.fila | Marea respiratoria | Breathing tide |
| marea.apagada | Apagada | Off |
| marea.apagada.pro | Apagada · pro | Off · pro |
| marea.activa | {n} por minuto · se retira a los {m} min | {n} per minute · fades at {m} min |
| temporizador.fila | Temporizador | Timer |
| temporizador.apagado | Apagado | Off |
| temporizador.quedan | {Modo} · quedan {n} min | {Mode} · {n} min left |
| temporizador.hasta | Escudo nocturno · hasta las {hora} | Night shield · until {time} |
| temporizador.quieto | se funde ahora · quieto 20 min | fading now · still for 20 min |
| barra.noches | Noches | Nights |
| barra.noche | Noche | Night |
| tip.arrastre | Arrastra sobre el nombre para cambiar el nivel. Un toque lo silencia. | Drag across the name to change the level. Tap to mute. |
| error.inicio | No se pudo iniciar el audio. Toca para reintentar. | Couldn't start audio. Tap to try again. |
| error.inicio.3 | Cierra las apps que usen el micrófono o el altavoz y vuelve a intentarlo. | Close apps using the microphone or speaker and try again. |

### 15.2 Capas

| Clave | ES | EN |
|---|---|---|
| titulo | Capas | Layers |
| seccion.colores | colores | colors |
| seccion.camas | camas | beds |
| blanco | Blanco · siseo parejo | White · even hiss |
| rosa | Rosa · suave y equilibrado | Pink · soft and balanced |
| marron | Marrón · retumbo grave | Brown · low rumble |
| lluvia | Lluvia · lluvia fina | Rain · fine rain |
| ventilador | Ventilador · ventilador lejano | Fan · distant fan |
| oceano | Océano · oleaje lento | Ocean · slow swell |
| trueno | Trueno · lejano, sin rayos cerca | Thunder · far off, no close strikes |
| hoguera | Hoguera · brasas, sin chasquidos | Campfire · embers, no crackle |
| arroyo | Arroyo · agua sobre piedras | Brook · water over stones |
| viento | Viento · entre árboles | Wind · through trees |
| cabina | Cabina · avión en crucero | Cabin · aircraft at cruise |
| timbre | Timbre · más cálido ◂ ▸ más lejano | Tone · warmer ◂ ▸ farther |
| nota | Se mezclan en tu iPhone mientras suenan. Nada se repite. | Mixed on your iPhone as they play. Nothing loops. |
| prueba30 | 30 s de muestra | 30 s preview |

### 15.3 Marea respiratoria

| Clave | ES | EN |
|---|---|---|
| titulo | Marea respiratoria | Breathing tide |
| instruccion | Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla. | Breathe in as the wave rises, out as it pulls back. No need to watch the screen. |
| fase.inhala | inhala | breathe in |
| fase.exhala | exhala | breathe out |
| estado.guiando | guiando · {n} por minuto · se retira a las {hora} | guiding · {n} per minute · fades at {time} |
| estado.disolviendo | disolviendo | dissolving |
| estado.pausa | en pausa | paused |
| estado.apagada | apagada | off |
| estado.retiro | Se retiró a las {hora}. | Pulled back at {time}. |
| ritmo | Ritmo | Pace |
| ritmo.tranquilo | Tranquilo · 6 por minuto | Calm · 6 per minute |
| ritmo.suave | Suave · 8 por minuto | Gentle · 8 per minute |
| ritmo.mio | Mi ritmo nocturno · {n} por minuto, según Salud | My night pace · {n} per minute, from Health |
| ritmo.mio.sin | Mi ritmo nocturno · valor por defecto | My night pace · default value |
| ritmo.exacto | Ajuste exacto | Exact setting |
| descenso | Descenso | Slow-down |
| descenso.sub | Empieza a tu ritmo y baja a 6 en 4 minutos | Starts at your pace, settles to 6 in 4 minutes |
| retira | Se retira a los | Fades after |
| retira.opciones | 5 · 10 · 15 · 20 · 30 min | 5 · 10 · 15 · 20 · 30 min |
| haptica | Háptica | Haptics |
| haptica.opciones | Ninguna · Mínima · Marcada | None · Minimal · Prominent |
| haptica.nota | Solo mientras sostienes el iPhone; en la mesilla no vibra. | Only while you hold your iPhone; it won't buzz on the nightstand. |
| voz | Decir inhala y exhala | Say breathe in and out |
| evidencia | Respirar a unas 6 veces por minuto se asocia en estudios a mayor variabilidad cardiaca. Qué sabemos y qué no › | Breathing at about 6 per minute is linked in studies to higher heart-rate variability. What we know and what we don't › |
| salud.permiso | SleepNoise lee tu frecuencia respiratoria nocturna para empezar la Marea a tu ritmo. Solo lectura; nada sale de tu iPhone. | SleepNoise reads your overnight respiratory rate to start the tide at your pace. Read-only; nothing leaves your iPhone. |

### 15.4 Temporizador

| Clave | ES | EN |
|---|---|---|
| titulo | Temporizador | Timer |
| dormirme | Hasta dormirme · {n} min · se funde los últimos 10 | Until I fall asleep · {n} min · fades over the last 10 |
| escudo | Escudo nocturno · hasta las {hora} · baja un poco cada hora | Night shield · until {time} · eases down each hour |
| siesta | Siesta · {n} min · termina con una subida suave | Nap · {n} min · ends with a soft rise |
| apagado | Apagado | Off |
| duracion | Duración | Length |
| duracion.pro | {n} min · pro | {n} min · pro |
| mas15 | +15 min | +15 min |
| mas30 | +30 min | +30 min |
| mas5 | +5 min | +5 min |
| quietud | Fundido por quietud | Fade when still |
| quietud.sub | Si el iPhone lleva 20 min quieto, empieza antes | If your iPhone has sat still for 20 min, it starts early |
| nota | El sonido se funde; tu alarma no se toca. | Sound fades out; your alarm is never touched. |
| nota.siesta | La siesta la termina tu alarma, no nosotros. | Your alarm ends the nap, not us. |
| nota.airpods | Si tus AirPods pausan el sonido al dormirte, SleepNoise lo respeta y no lo reanuda. | If your AirPods pause sound when you fall asleep, SleepNoise respects that and won't resume. |

### 15.5 Noche y Madrugada

| Clave | ES | EN |
|---|---|---|
| noche.pausa | en pausa | paused |
| noche.quedan | {n} min | {n} min |
| noche.hasta | hasta las {hora} | until {time} |
| noche.mas15 | +15 min | +15 min |
| noche.altavoz | Altavoz | Speaker |
| noche.primera | La pantalla puede dormir. El sonido sigue. | The screen can sleep. Sound keeps playing. |
| noche.volver | Mantén pulsado para volver | Hold to go back |
| madrugada | Madrugada | Small hours |
| madrugada.quedan | {n} min | {n} min |
| madrugada.ajuste | Madrugada no enseña la hora a propósito. | Small hours hides the clock on purpose. |
| madrugada.mostrar | Mostrar la hora en Madrugada | Show the clock in Small hours |
| madrugada.duracion | Madrugada · 10 · 20 · 30 min | Small hours · 10 · 20 · 30 min |
| noche.auto | Pasar a Noche sola · 1 min · 3 min · Nunca | Switch to Night on its own · 1 min · 3 min · Never |

### 15.6 Noches

| Clave | ES | EN |
|---|---|---|
| titulo | Noches | Nights |
| serie.lluvia | Lluvia constante · lluvia 55 · rosa 20 | Steady rain · rain 55 · pink 20 |
| serie.foco | Foco · marrón 45 · ventilador 30 | Focus · brown 45 · fan 30 |
| serie.descenso | Descenso · océano 50 · marea 6/min · 15 min · hasta dormirme 45 | Descent · ocean 50 · tide 6/min · 15 min · until I fall asleep 45 |
| vacio | Guarda la mezcla de esta noche desde su nombre. | Save tonight's mix from its name. |
| guardar.campo | Nombre de la noche | Night name |
| guardar.boton | Guardar | Save |
| guardada | Guardada | Saved |
| limite | Tres noches propias gratis. La cuarta es Pro; la mezcla sigue cargada. | Three nights of your own for free. The fourth is Pro; your mix stays loaded. |
| eliminar.confirmar | ¿Eliminar "{nombre}"? | Delete "{name}"? |

### 15.7 SleepNoise Pro

| Clave | ES | EN |
|---|---|---|
| cabecera | sleepnoise pro | sleepnoise pro |
| precio | {precio} | {price} |
| precio.cargando | — | — |
| lanzamiento | Precio de lanzamiento hasta el {fecha}. Después, {precio}. | Launch price until {date}. Then {price}. |
| titular | Un solo pago. Para siempre, en todos tus iPhone. | One payment. Forever, on every iPhone you own. |
| incluye.1 | Las once capas | All eleven layers |
| incluye.2 | Marea respiratoria | Breathing tide |
| incluye.3 | Temporizador sin límite y escudo nocturno | Unlimited timer and night shield |
| incluye.4 | Noches ilimitadas | Unlimited nights |
| incluye.5 | Familia incluida | Family Sharing included |
| gratis | Sigue gratis siempre: blanco, rosa, marrón, lluvia, 60 minutos de temporizador y tres noches guardadas. | Always free: white, pink, brown, rain, a 60-minute timer and three saved nights. |
| comprar | Comprar · {precio} | Buy · {price} |
| comprar.cargando | Cargando precio… | Loading price… |
| restaurar | Restaurar compra | Restore purchase |
| restaurar.buscando | Buscando… | Looking… |
| pie | Sin suscripción. Sin cuenta. Nada sale de tu iPhone. | No subscription. No account. Nothing leaves your iPhone. |
| gracias | Gracias. Todo abierto. | Thank you. Everything's open. |
| fallo | No se completó la compra. No se ha cobrado nada. | The purchase didn't go through. Nothing was charged. |
| pendiente | Pendiente de aprobación familiar. Se abrirá solo cuando llegue. | Waiting for family approval. It will unlock on its own. |
| restaurar.no | No hay ninguna compra con este Apple ID. Si la hiciste con otro, inicia sesión con él en la App Store. | No purchase found for this Apple ID. If you bought with another one, sign in with it in the App Store. |
| precio.error | No se pudo cargar el precio. Comprueba la conexión. | Couldn't load the price. Check your connection. |
| ajustes.pro | SleepNoise Pro · gracias · {fecha} | SleepNoise Pro · thank you · {date} |
| ajustes.pro.familia | · compartida en familia | · shared with family |
| prueba.0eur.boton | Empezar la prueba | Start the trial |
| prueba.0eur.nota | Dura 7 noches. No se cobra nada ni se pide tarjeta. Al acabar, pierdes las capas Pro, la Marea y el temporizador largo; conservas tus noches. | Lasts 7 nights. Nothing is charged and no card is asked. When it ends you lose the Pro layers, the tide and the long timer; your nights are kept. |

### 15.8 Qué sabemos y qué no

Título: "Qué sabemos y qué no" ["What we know and what we don't"]. Entradas en 3.11. Pie: "Nada de lo anterior es consejo médico. Si duermes mal muchas noches, habla con un profesional." ["None of this is medical advice. If you sleep badly many nights, talk to a professional."]

### 15.9 Superficies del sistema

| Clave | ES | EN |
|---|---|---|
| la.sonando | sonando · {modo} | playing · {mode} |
| la.pausa | en pausa | paused |
| la.pausa.hora | se pausó a las {hora} · {motivo} | paused at {time} · {reason} |
| la.fundiendo | fundiendo | fading |
| la.guiando | guiando · {n} por minuto | guiding · {n} per minute |
| la.terminada | Sesión terminada | Session over |
| la.terminada.sub | Se fundió a las {hora} · {n} min | Faded at {time} · {n} min |
| la.madrugada | madrugada · 20 min | small hours · 20 min |
| la.madrugada.quedan | madrugada · quedan {n} min | small hours · {n} min left |
| la.parar | Parar | Stop |
| di.tiempo | {n} m | {n} m |
| widget.silencio | en silencio | silent |
| widget.quedan | quedan {n} min | {n} min left |
| widget.inline | SleepNoise · quedan {n} min | SleepNoise · {n} min left |
| widget.inline.silencio | SleepNoise · en silencio | SleepNoise · silent |
| widget.descripcion | Tu última noche, con Play. | Your last night, with Play. |
| widget.m.descripcion | Tu última noche y tres noches guardadas. | Your last night and three saved nights. |
| cc.titulo | SleepNoise | SleepNoise |
| cc.on | {noche} · {n} min | {night} · {n} min |
| cc.off | Última: {noche} | Last: {night} |
| cc.madrugada | Madrugada · 20 min | Small hours · 20 min |
| accion.pista | Mantén para dormir | Hold for sleep |
| accion.pista.madrugada | Mantén para Madrugada | Hold for Small hours |
| watch.mas15 | +15 min | +15 min |
| watch.madrugada | Madrugada · 20 min | Small hours · 20 min |
| watch.marea | {n} por minuto · {m} min | {n} per minute · {m} min |
| siri.estado | {noche}, quedan {n} minutos. | {night}, {n} minutes left. |
| siri.silencio | Nada suena ahora. | Nothing is playing. |
| focus.titulo | SleepNoise en este modo | SleepNoise in this Focus |
| focus.abrir | Abrir en · Noche · Página | Open in · Night · Page |
| focus.noche | Noche al activar · {noche} · La última | Night on activation · {night} · The last one |
| ajustes.acostarte | Al acostarte | At bedtime |
| ajustes.acostarte.sub | Que suene sola cuando actives Sueño: dos pasos en Atajos. | Start on its own when Sleep Focus turns on: two steps in Shortcuts. |
| ajustes.diagnostico | Diagnóstico | Diagnostics |
| ajustes.privacidad | Nada sale de tu iPhone. | Nothing leaves your iPhone. |

## 16. Onboarding de una noche

No hay onboarding; hay una noche que enseña. Lo que la app muestra, cuándo, y lo que nunca muestra:

| Momento | Qué aparece | Regla |
|---|---|---|
| Primera apertura | La página con "Rosa y lluvia" cargada y el párrafo de prueba (15.1 prueba.bienvenida) + "Entendido" | Es la única pieza de texto "de bienvenida" de la app; se va con "Entendido" o en la segunda apertura |
| Primer Play | Nada: el sonido es la confirmación | Ningún tip antes del primer Play (no se enseña a usar lo que aún no se ha usado) |
| Primer arrastre de nivel | Nada (lo descubrió solo) | — |
| Segundo arrastre | Tip de una línea (tip.arrastre), 6 s, bajo la fila | TipKit, una vez en la vida; regla `maxDisplayCount = 1` |
| Primer "Todas las capas" | Nada; las palabras "pro" se explican solas al tocarlas (30 s) | — |
| Primera activación de la Marea | La palabra "inhala / exhala" durante tres respiraciones (es la guía, no un tip) | — |
| Primer "Ritmo" | Nada; el permiso de Salud solo si elige "Mi ritmo nocturno" | Permiso en el momento de uso, con el texto de 15.3 |
| Primera Noche | "La pantalla puede dormir. El sonido sigue." + "Mantén pulsado para volver", 4 s | Las dos frases, una sola vez en la vida de la instalación; no vuelven tras actualizar |
| Primer bloqueo con sonido | La Live Activity aparece sola | No se explica |
| Primera madrugada (sesión terminada + raise to wake) | "madrugada · 20 min" en la actividad terminada | Es la oferta en el lugar y momento exactos; nunca una notificación |
| Noche 2 | Nada nuevo | — |
| Noche 7 | prueba.ultima bajo el nombre, hasta el Play | — |
| Noche 8 | prueba.terminada + "Entendido" | Última pieza de texto de sistema que la persona verá si no compra |
| Nunca | Pantalla de bienvenida, carrusel, permiso de notificaciones, permiso de micrófono (fuera de alcance), petición de valoración, "novedades", encuesta, correo | Lista negra §7.1 del brief |

Máximo un tip por sesión; ningún tip entre las 22:00 y las 07:00 salvo las dos frases de Noche; ningún tip mientras suena la Marea; todos los tips son una línea de texto paso 7 `texto2` con fundido de 250 ms, sin flecha, sin globo, sin fondo (TipKit se estiliza con `.tipBackground(.clear)` y sin imagen).

## 17. Añadidos a la maqueta

`scratchpad/design/concepts/grafito.html` incorpora una tercera fila de marcos, descrita en 13 y 10.8:

1. **Dynamic Island** en sus tres presentaciones (compacta, mínima, expandida con "+15 min" y "Noche").
2. **Widgets**: el pequeño en StandBy nocturno con el tinte rojo (una tinta, fondo removido) y el mediano en apariencia de día sobre `papel`.
3. **Apple Watch**: las dos pantallas (mando con "+15 min" y la Digital Crown como volumen; Marea con la línea de agua y la háptica anotada).
4. **Prueba caducada** (noche 8): la página con la cabecera "gratis · …", la nota de una vez con "Entendido", "Trueno" como capa Pro con su nivel guardado ("pro · 30"), la Marea "Apagada · pro", y la línea de estado "Sonando · sin trueno".
5. **Interrupción**: la página en "En pausa · auriculares" con el botón de texto "Seguir por el altavoz" (estado de 10.11).
