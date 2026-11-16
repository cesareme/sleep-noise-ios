# Concepto «Dial» · SleepNoise como instrumento de precisión

**Equipo de concepto Dial · 16 de noviembre de 2026 · Responde al brief 00, a la auditoría 01 y a los materiales 02.**
Postura declarada frente a la tensión del brief (§5): **somos sobre todo instrumento, y la noche es un modo del instrumento.** Lo que se sacrifica: la voz editorial de Bear como forma (no como disciplina) y cualquier "atmósfera". Lo que se gana: cada valor de la app se puede leer, tocar y oír cambiar bajo el dedo, con la pantalla apagada o encendida.

Alcance: el plan de funciones por versión (`docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md`) no existía al escribir esto. Se diseña para la lista de superficies del encargo: principal, mezclador, Marea, temporizador de tres modos, Noche, Modo Madrugada, mezclas guardadas, paywall y prueba, primer uso, "Qué sabemos y qué no", Live Activity / Dynamic Island / StandBy, widgets, Centro de control, Watch mínimo, icono y capturas. Maqueta estática: `scratchpad/design/concepts/dial.html` (ocho marcos).

---

## 1. Tesis

SleepNoise no reproduce: fabrica. Un instrumento que fabrica algo se diseña como un aparato de medida de mesilla, no como una biblioteca ni como un spa: una esfera negra mate, una escala de marcas finas, **un solo índice de color que se mueve con causa** (el segundero amarillo de Lubs en el AB1 de Braun), y un control continuo largo que el pulgar encuentra a oscuras y que responde con un detente háptico en cada marca. Todo lo que se ve es un valor leíble (nivel, minutos, respiraciones por minuto) o la prueba de que el sonido se está generando ahora (la banda de marcas que avanza a la velocidad real del DSP); todo lo demás es negro apagado. La noche no es otra app: es el mismo instrumento con la esfera atenuada, un gesto y el índice más tenue. Y la precisión no se impone: lo que se lee de día bajo el dedo (65, 6 por minuto, −18 dBFS) vive debajo de una pulsación larga, de modo que quien no quiere cifras ve solo una regla, una marca y un punto amarillo. El objeto resultante debe poder estar en el escaparate junto a una Leica M11-D y una TP-7 sin pedir perdón, y en una mesilla a las 3 de la mañana sin que nadie lo note.

---

## 2. Identidad

### 2.1 Paleta

Dos superficies, tres tintas, un índice. Ratios WCAG 2.x calculados sobre los hex indicados (fórmula de luminancia relativa; script en el scratchpad de la sesión). «Rojo A» es el color filtrado como en StandBy nocturno según el modelo "solo canal rojo" (el peor de los dos modelos del documento 02; el modelo "luminancia a rojo" da siempre valores iguales o mejores). Referencia dura: el rojo puro `#FF0000` sobre negro solo alcanza 5,25:1, así que bajo StandBy ningún color pasa de AA grande salvo los casi blancos.

| Token | Hex (RGB) | Sobre negro | Sobre grafito | Sobre grafito 2 | Rojo A sobre negro | Uso |
|---|---|---|---|---|---|---|
| `negro` | `#000000` (0,0,0) | — | — | — | — | Fondo de toda superficie. Píxel apagado. |
| `grafito` | `#1E1D1B` (30,29,27) | 1,25 | — | — | — | **Único relieve**: fondo de hojas, cuerpo del Disco de Play, pulgar de la Regla. Grafito cálido, no el azulado de Apple; es el "plástico negro mate" del ET66. |
| `grafito2` | `#2A2826` (42,40,38) | 1,43 | 1,15 | — | — | Relieve dentro de una hoja (una sola vez por hoja: el control que se coge). |
| `trazo` | `#2C2A27` (44,42,39) | 1,47 | 1,18 | 1,03 | — | Hairline decorativa de 0,5 pt entre filas. No transmite información. |
| `texto` | `#E8E4DC` (232,228,220) | **16,56** | 13,28 | 11,58 | **4,43** | Tinta principal, cifras, glifos, marcas largas de la escala, pulgar activo. Único valor permitido en StandBy, widgets y Live Activity. |
| `texto2` | `#9C9A96` (156,154,150) | **7,48** | 6,00 | 5,23 | 2,41 | Secundario, subtítulos, unidades, estado en versalitas. Nunca en StandBy. |
| `texto3` | `#6E6C68` (110,108,104) | **4,01** | 3,21 | 2,80 | 1,66 | Marcas cortas de la escala, pista vacía, contornos de control (cumple 3:1 de componente sobre negro y grafito). Como texto solo ≥ 18 pt. Nunca dentro de `grafito2`. |
| `índice` | `#F0C020` (240,192,32) | **12,27** | 9,84 | 8,58 | **4,71** | **El acento. Amarillo Lubs atemperado.** Solo en el Índice (§3.0): aguja de la Regla, marca "ahora" de la Banda, punta del Mareógrafo. Nunca relleno de botón, nunca texto corrido. Cumple 3:1 gráfico bajo rojo con margen. |
| `índice-noche` | `#BA941C` (186,148,28) | 7,34 | 5,89 | — | 3,09 | El mismo Índice en Noche y Madrugada (esfera atenuada). Solo formas ≥ 3 pt. Nunca en StandBy (allí el sistema atenúa solo; se entrega `índice`). |
| `índice-contraste` | `#FFD23C` (255,210,60) | 14,54 | 11,66 | 10,17 | 5,25 | Variante *High Contrast* en el asset catalog para `índice`. |
| `error` | `.red` oscuro del sistema `#FF4245` | 6,12 | 4,91 | — | 5,25 | Único rojo: aviso de sesión de audio fallida. Jamás en "Borrar" (que es texto `texto` con hairline). |

Variantes *Increase Contrast* (en el asset catalog, no en código): `texto2 → #B4B2AE` (9,92:1), `texto3 → #7A7672` (4,66:1), `índice → #FFD23C`.

**Día (apariencia clara del sistema, "papel").** La app sigue la apariencia del sistema (HIG: sin selector propio). El Focus de Sueño pone el iPhone en oscuro solo. Papel `#F3F0E9`; tinta `#1E1C19` (14,94:1); tinta2 `#5F5A53` (6,00:1); hairline `#D8D3C9`; **el Índice de día es `ocre #8A6508`** (4,68:1 sobre papel: cumple 3:1 de componente y AA de texto grande; el amarillo Lubs sobre papel da 1,50:1 y no sirve). Mismo matiz, menos luz: igual que el segundero del AB1 blanco frente al negro. Sin sombras: el papel es mate.

**Por qué amarillo y no brasa.** El ámbar `#C9A27A` del documento 02 es correcto como *luz*; el Dial necesita un *índice*: un color que se vea como señal, no como calor. El amarillo Lubs tiene la luminancia más alta del set (0,56 relativa) y por eso sobrevive al rojo de StandBy (4,71:1 bajo el peor modelo, frente a 3,48:1 del brasa) y a la escala de grises (es el píxel más claro después del texto). Se defiende porque ocupa **menos del 0,3 % de la superficie** en cualquier pantalla: una aguja de 2 × 22 pt, una marca de 1 × 28 pt o un punto de 6 pt. Si en algún concepto el amarillo rellenase algo, dejaría de ser Braun para ser Teenage Engineering mal entendido; aquí no rellena nunca.

**Cuenta de color por pantalla** (criterio P3): negro, tres grises, un amarillo. Nada más, salvo el rojo del sistema en un único aviso.

### 2.2 Tipografía

Dos familias del sistema, sin empaquetar nada:

- **SF Pro** (Text/Display automáticos): toda palabra. Dynamic Type nativo.
- **SF Mono**: toda cifra que sea una *lectura de instrumento* (nivel, minutos, respiraciones por minuto, dBFS, MB). Es la decisión que separa este concepto de los otros dos, y se defiende así: en un aparato de medida el número es un dato, y la monoespaciada es honesta con el dato (cada dígito ocupa lo mismo, el reloj no baila, la columna de valores del mezclador queda alineada sin tabuladores). A 56-72 pt, SF Mono **Medium** con tracking −2 % y con la escala de marcas debajo no se lee como terminal sino como el display de una Braun: la prueba está en la maqueta. SF Rounded no se usa en ninguna parte.

| Paso | Uso | Familia / peso | Tamaño / interlineado (Large) | Noche | `relativeTo` | Color |
|---|---|---|---|---|---|---|
| 1 · Cifra | Cuenta atrás, reloj de Noche, "/min" grande en Marea | SF Mono Medium, tracking −2 % | 56 / 60 (Noche 72 / 76) | Medium | `.largeTitle`, tope `accessibility2` | `texto` |
| 2 · Título | Nombre de la noche en la principal; cabecera de hoja | SF Pro Medium | 22 / 28 | Medium | `.title2` | `texto` |
| 3 · Encabezado | Nombre de capa, nombre de modo de temporizador | SF Pro Semibold | 17 / 22 | Semibold | `.headline` | `texto` |
| 4 · Cuerpo | Frases de una línea, paywall, "Qué sabemos" | SF Pro Regular | 17 / 22 | Medium | `.body` | `texto` |
| 5 · Secundario | Subtítulo de capa ("lluvia fina"), estado de Marea | SF Pro Regular | 15 / 20 | Medium | `.subheadline` | `texto2` |
| 6 · Nota | Pies, "no es un producto sanitario", nota de fundido | SF Pro Regular | 13 / 18 | Medium | `.footnote` | `texto2` |
| 7 · Lectura | Valor junto a cada control (65, 6 /min, 45 min) | SF Mono Medium | 13 / 18; **20 / 24 mientras se arrastra** | Medium | `.footnote` / `.title3` | `texto2`; `texto` al arrastrar |
| 8 · Unidad | min, /min, dB, versalitas de estado (Pro, Prueba) | SF Pro Medium, versalitas reales (`.smallCaps()`), tracking +2 % | 13 / 18 | Medium | `.footnote` | `texto2` |

Reglas: nada por debajo de 13 pt; nada por debajo de Medium sobre negro; Regular solo ≥ 20 pt o de día; Bold, Light y Thin, nunca; sin mayúsculas sostenidas (versalitas reales); cifras siempre tabulares (SF Mono lo es; cualquier cifra que por excepción vaya en SF Pro lleva `.monospacedDigit()`); Large Title no existe (la app no se titula a sí misma). Dynamic Type: de xSmall a AX5; la Regla crece en altura con `@ScaledMetric(relativeTo: .body)`; las filas del mezclador pasan de "nombre + valor en línea, regla debajo" a "nombre / valor / regla apilados" en AX1 con `ViewThatFits`. La Cifra lleva tope en AX2 para no superar 112 pt.

Máximo de estilos por pantalla: 5 (principal: título, secundario, encabezado, lectura, unidad).

### 2.3 Espaciado, hairline, radios

- **Retícula**: columna única de 353 pt (393 − 2 × 20). Escala de 4 pt. Margen lateral 20. Aire entre grupos ≥ 32 (siempre ≥ 2× el aire interno, que es 12-16).
- **Filas**: lista 56 pt; fila con control 64 pt (44 de objetivo + 20 de aire); objetivos nocturnos ≥ 64 pt; separación entre objetivos sin borde ≥ 24 pt.
- **Hairline**: 0,5 pt (`1 / displayScale`) en `trazo`, de margen a margen. Es el único separador. Nunca bordes de caja.
- **Marcas de escala** (la retórica del concepto): 1 pt de ancho, colgando de la línea base. Regla de capa: una marca media de 10 pt cada 5 unidades (21 marcas, 17,65 pt de separación en 353 de recorrido) en `texto3`, y larga de 14 pt en 0 / 50 / 100 en `texto`. Regla maestra y de ritmo ("fina"): además una marca corta de 6 pt cada 2,5 unidades (41 marcas, 8,8 pt). Nunca una marca por unidad (moiré).
- **Radios**: 0 en reglas, marcas y hairlines; 12 en botones; hojas y Disco, los del sistema (el Disco es circular). Nada de radio 18-24 (la app actual).
- **Relieve**: solo el Disco de Play y el pulgar de la Regla, con `grafito` de relleno y una sombra interior de 1 pt en `negro` al 60 % (la tecla convexa del ET66). Nada más tiene volumen.

### 2.4 Iconografía

- Cero iconos en el mezclador y en la pantalla principal fuera de la barra (las palabras son los iconos).
- SF Symbols monocromos, peso heredado del texto (Medium de noche), estado por variante (`play.fill` ↔ `pause.fill` con `.contentTransition(.symbolEffect(.replace))`), nunca por color. Barra: `timer`, `play.fill`/`pause.fill`, `square.and.arrow.down` (iOS 17) y `slider.horizontal.3` (mezclador). Sin `lock`, sin `crown`, sin `checkmark.seal`.
- Símbolos propios (plantilla de SF Symbols, 9 pesos): los tres **glifos de pendiente** (blanco 0 dB/oct, rosa −3, marrón −6), el **glifo de regla** (línea con índice: control de Centro de control, Live Activity mínima, Watch) y el **glifo de marea** (línea horizontal con punto en el extremo). Trazo 1,5 pt a 17 pt.

---

## 3. Sistema de componentes

Convención: cada componente se describe con sus estados **normal / activo / bloqueado-Pro / prueba / deshabilitado / VoiceOver**. "Bloqueado-Pro" nunca tiene castigo visual: la cosa existe, se toca, suena 30 s y después se explica.

### 3.0 El Índice (regla transversal)

Hay **un** elemento amarillo por pantalla, y está en lo que manda ahora: si el dedo arrastra un control, el Índice es el pulgar de ese control; si no, y suena algo, el Índice es la marca "ahora" de la Banda; si no suena nada, el Índice es la aguja de la Regla principal, quieta. Los demás elementos que podrían ser amarillos se dibujan en `texto`. Así el amarillo siempre significa "esto es lo vivo", y el estado "¿suena?" se lee de lejos por *dónde* está el amarillo (quieto en la regla = en reposo; recorriendo la banda = sonando), además de por forma.

### 3.1 Fila (lista)

Texto sobre negro, 56 pt, hairline debajo de margen a margen. Izquierda: encabezado (17 Semibold) y, opcional, secundario (15); derecha: lectura (13 SF Mono) o chevron del sistema.
- Normal: como se describe. Activo (pulsado): fondo `grafito` durante la pulsación, sin animación de escala. Bloqueado-Pro: igual que normal, con la palabra "Pro" en versalitas `texto2` a la derecha de la lectura; al tocar, actúa 30 s y abre la hoja Pro. Prueba: idéntica a normal (la prueba es "todo abierto"). Deshabilitado: texto en `texto3` (solo si ≥ 17 pt) y sin hairline inferior. VoiceOver: "Lluvia fina, 40 por ciento, botón" / "Rain, 40 percent, button"; Pro: "…, requiere Pro, toca para escuchar 30 segundos".

### 3.2 La Regla (control de nivel, el componente propio principal)

Un deslizador horizontal largo y sin caja: una línea base de 1 pt en `texto3` de margen a margen (353 pt), una escala de marcas debajo (§2.3), un **pulgar** de 28 × 44 pt (área táctil 64 × 64) en `grafito` con relieve y, en su centro, la **aguja**: 2 × 22 pt. La porción recorrida de la línea base va en `texto` (1,5 pt); la vacía, en `texto3` (1 pt). Es un `Slider` del sistema por debajo (accesibilidad, Liquid Glass transitorio en iOS 26 mientras el dedo está encima) con `labelsHidden()` y un *track* propio; no se reimplementa el gesto.
- Normal: aguja en `texto`; lectura 13 SF Mono `texto2` a la derecha del nombre. Activo (dedo encima): aguja en `índice`, la lectura crece a 20 pt en `texto` **en su sitio** (alineada a la derecha, nunca flotando sobre el pulgar, donde taparía el nombre y perdería el orden de lectura de VoiceOver); háptica `.selection` en cada marca de 5 (detentes), `.impact(.light, 0,6)` al llegar a 100, `.selection` al cruzar 0. Pulsación larga sobre la lectura: cambia a "−18 dBFS" (nivel real en la salida) mientras dure. Bloqueado-Pro: línea base y marcas iguales, **sin pulgar**; la palabra "Pro" en versalitas donde iría la lectura; tocar cualquier punto de la línea arranca la capa 30 s a ese nivel (el pulgar aparece amarillo durante los 30 s y se disuelve) y abre la hoja Pro. Prueba: normal. Deshabilitado (p. ej. nivel maestro durante el fundido final): marcas en `texto3`, pulgar en `texto3`, sin háptica. VoiceOver: `.adjustable`, pasos del 5 %, "Lluvia fina, 40 por ciento"; acciones personalizadas "Silenciar" y "Máximo". Reduce Motion: no cambia (no hay animación propia).
- Variante **Regla de tiempo** (temporizador, duración de Marea): mismas piezas, escala en minutos con marcas largas en los valores con nombre (15, 30, 45, 60, 90); los valores Pro llevan la versalita "Pro" bajo la marca; el pulgar salta entre marcas (detentes duros).
- Variante **Regla de ritmo** (Marea): escala 4-8 /min, detente cada 0,5.

### 3.3 Botón primario y secundario

Viven solo en hojas (contexto despierto). Primario: 50 pt de alto, radio 12, relleno `texto`, etiqueta 17 Semibold en `negro` (16,56:1); sombra interior 1 pt (tecla). Secundario: mismo tamaño, sin relleno, borde 1 pt `texto3`, etiqueta `texto`. Terciario: solo texto `texto2` 17 Regular (Restaurar, Cerrar textual nunca: las hojas cierran con el sistema).
- Activo: relleno `#D9D5CD` (pulsado). Deshabilitado: relleno `grafito2`, etiqueta `texto3` (solo mientras StoreKit responde; nunca por estado de prueba). VoiceOver: etiqueta + "botón"; el primario del paywall anuncia el precio completo: "Comprar SleepNoise Pro, 29,99 euros, pago único".
- **El Índice nunca entra en un botón.**

### 3.4 Chip de estado

No es una cápsula: es una **palabra en versalitas** (13 Medium, +2 %) en `texto2`, alineada a la línea de base del texto al que acompaña. Valores: "Pro", "Prueba · 5 noches", "Noche", "Siesta", "Fundiendo", "Guiando", "Disolviéndose". Nunca color, nunca fondo, nunca icono. VoiceOver lo lee como parte de la etiqueta del elemento al que pertenece (no es foco propio).

### 3.5 Hoja

Hoja del sistema (`.sheet` con `presentationDetents([.medium, .large])` donde aplica), fondo `grafito` vía `presentationBackground`, indicador de arrastre del sistema, cierre por gesto o por el botón estándar de cierre; **sin botón "Cerrar" pintado ni título centrado**: la hoja abre con su pregunta como título 22 Medium alineado a la izquierda ("¿Cuándo se apaga?"). Dentro: filas, reglas, hairlines; un solo relieve `grafito2` por hoja como máximo.

### 3.6 Barra

`ToolbarItemGroup(placement: .bottomBar)` estándar; en iOS 26 el sistema le pone vidrio regular; en 17/18, material `bar` sobre negro más una hairline `trazo` encima. Cuatro elementos: Temporizador · Mezclador · **Disco** · Noches. Ningún control teñido (ni siquiera el Disco: la HIG permite un tinte, pero el Índice no se gasta en un botón).

### 3.7 El Disco (Play/Pausa)

Círculo de 72 pt (área 72 × 72, en Noche la pantalla entera) en `grafito` con relieve de tecla, glifo `play.fill` / `pause.fill` 28 pt en `texto`. Único botón con volumen de la app, como el Magic Plus de Things es el único con física.
- Normal: play. Activo (sonando): pause; alrededor no hay anillo ni halo; lo que cambia es la Banda (empieza a moverse) y el Índice (pasa de la Regla a la Banda). Pulsado: el relieve se invierte (sombra interior 2 pt) 200 ms. Durante el fundido final: `symbolEffect(.pulse)` en el glifo (único efecto repetitivo permitido), apagado con Reduce Motion. Deshabilitado: nunca (nada bloquea el sonido). VoiceOver: "Reproducir, botón" / "Pausar, botón"; anuncia "Sonando" al arrancar.

### 3.8 La Banda (visual del sonido)

La envolvente real, dibujada con la retórica del instrumento: **una fila de 60 marcas verticales de 1 pt** separadas 6 pt (353 pt de ancho), apoyadas en una línea base de 1 pt `texto3`. Cada marca es la envolvente RMS sumada de las capas en una ventana de 100 ms; la fila avanza de derecha a izquierda a 10 marcas por segundo (20 Hz de muestreo, decimado), de modo que la Banda muestra los últimos 6 segundos de sonido real. Altura máxima 56 pt. Color: `texto3` las marcas antiguas, `texto2` las últimas 12, y **la marca "ahora" (la del extremo derecho) es el Índice**, 1,5 pt. No es espectro, no es simétrica, no tiene degradado ni resplandor; suavizado 400 ms; si el motor se silencia, cae a reposo en < 1 s porque lee el motor y no un reloj.
- **Reposo (nada suena): todas las marcas a 2 pt de altura.** Una línea de puntos quieta: el silencio dibujado. Es bello porque es una escala; no miente porque está a cero.
- Pulsación larga: se descompone en una fila por capa activa (hasta 3 líneas de 18 pt de altura cada una, nombre a la izquierda en 13 Mono): la transparencia de Halide/Nothing bajo el gesto.
- Reduce Motion: 4 Hz, constante 1,5 s. `isLuminanceReduced` y Noche: congelada en la última posición y, a los 2 s, fundida al reposo. Widget y Live Activity: estática, 24 marcas cuya altura es el nivel por capa en el momento de emitir.
- VoiceOver: "Nivel del sonido, 62 por ciento" + `AXChartDescriptor` con la serie de los últimos 6 s por capa.
- Señal del motor que mueve cada elemento (tabla exigida por la lente 2): altura de marca ← RMS sumado (`SoundGains` seqlock, 20 Hz); color/posición del Índice ← estado `isPlaying` y ventana actual; nada más se mueve.

### 3.9 El Mareógrafo (forma de la Marea)

No un círculo (Apple Breathe, Balance) ni una ola ilustrada: un **mareógrafo lineal**. Una línea horizontal de 2 pt en `texto` que nace en el margen izquierdo y **se alarga al inhalar y se acorta al exhalar**, siguiendo exactamente `BreathCurve` (la misma función que modula el oleaje; 4:6 por defecto; 7,5-15 s por ciclo). Debajo, una escala de marcas fija de 0 a 100 (la misma retórica de la Regla), con marcas largas en las fracciones de la respiración. En la punta de la línea, el Índice como punto de 6 pt. Marea baja (exhalación completa) = 12 % del recorrido; marea alta = 100 %. Altura total del componente 72 pt.
- Estado "guiando": la línea respira; texto 15 `texto2` debajo: "Guiando · 6 por minuto · se retira en 12 min". "Disolviéndose": la amplitud del recorrido se reduce con la del audio (la línea respira cada vez menos) y el texto pasa a "Disolviéndose · 3 min"; al terminar, la línea queda en marea baja y el Índice vuelve a la Regla. Inactiva: línea en marea baja, sin Índice, texto "Marea respiratoria · apagada".
- Se puede **arrastrar la punta**: cambia el ritmo (la bobina de la TP-7: indicador y control a la vez); mientras se arrastra, la lectura "6,0 /min" aparece en 20 Mono y hay detentes cada 0,5.
- Reduce Motion: longitud fija al 56 %, opacidad respira entre 100 y 70 % con la misma curva. `isLuminanceReduced`: congelada en marea baja en ≤ 2 s.
- Bloqueado-Pro (tras la prueba): la hoja de Marea se abre, la línea respira 30 s y después se queda en marea baja; la versalita "Pro" junto al título; el toggle sigue siendo un toggle del sistema.
- VoiceOver: "Marea respiratoria, guiando, 6 por minuto, 12 minutos restantes"; con la guía activa, anuncio discreto "Inhala" / "Exhala" solo si el usuario lo activa en la hoja (opción "Voz de guía").
- Señal: longitud ← `BreathCurve(t)` del motor (ancla `guide.anchor`, compensa `outputLatency`); amplitud ← ganancia de la Marea durante la disolución.

### 3.10 La Cifra

Lectura grande (paso 1) con unidad en versalitas a la derecha, alineada a la línea de base: "48 min", "6 /min", "00:42". Siempre tabular. En Noche, 72 pt. Nunca acompañada de icono. VoiceOver lee en palabras: "48 minutos restantes" / "las doce y cuarenta y dos".

### 3.11 Tabla sistema / propio / por qué

| Componente | Origen | Por qué |
|---|---|---|
| Navegación, hojas, toolbar, toggles, pickers de hora, alertas, Live Activity, widgets, Control Center | Sistema | HIG P12; Liquid Glass solo donde el sistema lo pone |
| Regla | Propio sobre `Slider` | El slider del sistema no tiene escala ni detentes visibles; se reutiliza su gesto y su accesibilidad |
| Banda | Propio (`Canvas` + `TimelineView` aislado) | No existe componente del sistema; es la prueba "nunca se repite" |
| Mareógrafo | Propio (`KeyframeAnimator` con `BreathCurve` muestreada) | Es la función diferencial del producto |
| Disco | Propio (botón con estilo) | Un solo botón con física; el `.glassProminent` teñiría con el acento y el acento no rellena |
| Cifra, Chip, Fila, Botones | Sistema con estilo | Texto y `buttonStyle` del sistema |

---

## 4. Pantallas y superficies

Dimensiones sobre iPhone 17 Pro (393 × 852 pt, safe area superior 59, inferior 34). Posiciones en pt desde la esquina superior izquierda de la pantalla. Textos en ES / EN. Cada pantalla lleva su pregunta (P10).

### 4.1 Pantalla principal · "¿Qué suena y cómo lo controlo?"

**Jerarquía (de arriba abajo):**
1. **y 72, x 20**: nombre de la noche actual, 22 Medium `texto`: "Lluvia fina" / "Light rain". Es el nombre de la mezcla guardada o, si se ha tocado algo, "Lluvia fina · editada" / "Light rain · edited". Sin nombre de app.
2. **y 102**: línea de estado 15 `texto2`, una sola línea: en reposo "45 min hasta dormirme" / "45 min until I fall asleep"; sonando "Se funde a las 00:42" / "Fades out at 00:42", y si la Marea guía, "· Guiando 6 /min" / "· Guiding 6 /min" en versalitas; en prueba se antepone la versalita "Prueba · 5 noches ·" / "Trial · 5 nights ·". Es la única mención de la prueba en toda la pantalla.
3. **y 164-220**: la **Banda** (§3.8), 353 × 56, línea base en y 220. En reposo, 60 puntos quietos. Debajo, y 228, la escala de tiempo: marcas cada segundo (6) con "−6 s" y "ahora" / "now" en 13 Mono `texto3` en los extremos (solo cuando suena).
4. **y 284-428**: **las capas que suenan**, máximo dos filas de 64 pt sin hairline (aire de 16 entre ellas): nombre 17 Semibold a la izquierda ("Lluvia" / "Rain"; "Marrón" / "Brown"), lectura 13 Mono a la derecha ("40", "20"), y bajo cada una su Regla (§3.2) de 353 pt. Si la noche tiene más de dos capas, la segunda fila se sustituye por "y 2 más" / "and 2 more" en 15 `texto2` con chevron. Tocar un nombre abre el mezclador en esa capa. Las capas a 0 **no aparecen** en la principal: lo que no suena no ocupa píxeles.
4b. **y 446-500**: la **fila de la Marea** (acceso a un toque, P2 y §6 del brief): apagada, una fila de 44 pt con la versalita "Marea respiratoria" / "Breathing tide" a la izquierda y "apagada" / "off" en `texto2` a la derecha; activa, la versalita "Marea" / "Tide", el estado "se retira en 12 min" / "fades in 12 min" y debajo el **Mareógrafo compacto** (353 × 40, §3.9) respirando. Tocar la fila abre la hoja de la Marea; pulsación larga la enciende o apaga sin abrir nada.
5. **y 540-624**: la **Regla maestra**: etiqueta 13 versalitas "Nivel" / "Level" a la izquierda y lectura "62" en Mono a la derecha (y 540); la Regla fina de 353 pt con escala completa en y 584; pulgar de 64 pt de área. Es el control continuo principal del concepto: el que se busca a oscuras con el pulgar desde la mitad inferior. Es independiente del volumen del sistema (la alarma suena a su propio nivel; se dice en una nota del temporizador).
6. **y 752-852**: la **Barra** (§3.6): `timer` "Temporizador" / "Timer" (x 44) · `slider.horizontal.3` "Mezclador" / "Mixer" (x 118) · **Disco** 72 pt centrado (y 756-828, sobre el indicador de inicio) · `square.stack` "Noches" / "Nights" (x 304). La toolbar del sistema pondría etiquetas de 10-11 pt bajo los iconos y eso está prohibido: se usan **solo glifos** de 22 pt con `accessibilityLabel`, objetivos de 44 pt y separación ≥ 24 pt.

**Qué pasa al tocar:** Disco → fundido de 800 ms, háptica `.impact(.medium, 0,7)`, el Índice salta de la Regla maestra a la Banda, la línea de estado pasa a "Se funde a las 00:42". Arrastre en cualquier Regla → cambia el nivel con detentes; el Índice va al pulgar. Pulsación larga en la Banda → una línea por capa. Pulsación larga en una lectura → dBFS. Tocar el nombre de la noche → hoja "Noches" con la actual arriba. Deslizar hacia abajo desde cualquier punto vacío con la sesión sonando → **Noche** (§4.5); también se entra sola al bloquear si el temporizador está en marcha (volver a la app con la pantalla bloqueada muestra Noche, no la principal).

**Candados visibles: cero. Rectángulos rellenos: cero** (el Disco y los pulgares son controles que se cogen, permitidos por P6). **Estilos de texto: 5.** Cabe sin scroll en 393 × 852 con tamaño Large; en iPhone SE (375 × 667) la Banda baja a 40 pt y se muestran dos capas; a partir de AX1 la pantalla hace scroll y la barra permanece.

**Primer uso (sin tutorial):** la app abre con la noche "Lluvia fina" cargada (Lluvia 40, Marrón 20, nivel 62, temporizador "Hasta dormirme" 45 min), todo en reposo. Lo único que falta es tocar el Disco. Una sola línea de TipKit, bajo la Barra, la primera vez y nunca más: "Toca el disco. Arrastra las reglas. Nada más que aprender." / "Tap the disc. Drag the rulers. Nothing else to learn." No hay permisos, no hay registro, no hay precio.

### 4.2 Mezclador (hoja a `.large`) · "¿Qué capas y a qué nivel?"

Título y 24 de la hoja: "Capas" / "Layers" 22 Medium; debajo, 15 `texto2`: "Se oyen cambiar bajo el dedo." / "You hear them change under your finger."

Dos grupos separados por 32 pt de aire y una etiqueta en versalitas (13, `texto2`):
- **"Cama" / "Bed"**: Blanco, Rosa, Marrón (los tres ruidos; lo que el PR #3 llamaba *beds*). Subtítulos humanos: "siseo parejo" / "even hiss", "suave y equilibrado" / "soft and even", "retumbo grave" / "low rumble".
- **"Texturas" / "Textures"**: Lluvia ("lluvia fina" / "light rain"), Ventilador ("ventilador lejano" / "distant fan"), Océano ("mar lento" / "slow sea"), y, cuando entren, Trueno, Hoguera, Arroyo, Viento, Cabina.

Cada capa es una **fila con Regla** de 88 pt: nombre 17 Semibold + subtítulo 15 en una línea de 22 (y 0-22), lectura 13 Mono a la derecha; Regla de 353 pt en y 48; hairline debajo (y 88). Sin iconos, sin cajas. Capa a 0: pulgar en el extremo izquierdo, línea base íntegra en `texto3`. Capa sonando: tramo recorrido en `texto` 1,5 pt. **Capa Pro para el usuario gratuito tras la prueba**: la misma fila, sin pulgar, con la versalita "Pro" en el sitio de la lectura; tocar la línea la hace sonar 30 s desde ese punto (pulgar amarillo que se disuelve a los 30 s) y abre la hoja Pro. En la prueba no hay ninguna marca.

Gesto humano (P11): deslizar horizontalmente **sobre el subtítulo** de una textura cambia el timbre con tres posiciones nombradas que se leen mientras se desliza: "más cerca · igual · más lejano" / "closer · as is · farther" (lluvia, ventilador, océano) o "más cálido · igual · más brillante" / "warmer · as is · brighter" (cama). Pulsación larga sobre el nombre abre la fila técnica: corte de graves (Hz) y pendiente, en 13 Mono, con su propia Regla pequeña. VoiceOver expone el timbre como un segundo `.adjustable` "Timbre de Lluvia, igual".

Pie de la hoja (y final, 13 `texto2`): "Lo que está a cero no suena ni gasta." / "What's at zero makes no sound and costs nothing."

**Geometría alternativa documentada (exigencia 9.1.9):** "la escala única": una sola Regla maestra de 353 pt con **seis agujas** (una por capa, con su inicial en 13 Mono encima: B R M Ll V O) sobre la misma escala; se coge la aguja más cercana al dedo; pulsación larga en una aguja aísla su capa (las demás bajan a −12 dB, solo monitor). Más densa y más "instrumento"; se descarta para 1.0 porque con VoiceOver seis agujas sobre una pista son seis `.adjustable` sin orden espacial claro y porque a AX3 las iniciales colisionan. Se guarda como "vista compacta" opcional para 1.1 si el usuario lo pide.

### 4.3 Marea respiratoria (hoja a `.medium`) · "¿Cómo respiro?"

- y 24: título "Marea respiratoria" / "Breathing tide" 22 Medium, con el toggle del sistema a la derecha (el toggle se conserva: ya está bien).
- y 64: **Mareógrafo** (§3.9), 353 × 72. Activo: respira. Inactivo: marea baja, sin Índice.
- y 148: frase 15 `texto2` (se conserva del producto actual, es correcta): "Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla." / "Breathe in as the wave rises, out as it draws back. No need to watch the screen."
- y 204: **Regla de ritmo**: etiqueta versalitas "Ritmo" / "Pace" y lectura "6 /min"; recorrido 4-8, detentes cada 0,5, marcas largas en 4, 6, 8. Debajo, 13 `texto2`: "6 por minuto es el ritmo de los estudios de respiración lenta. Si te falta el aire, sube el ritmo." / "6 per minute is the pace used in slow-breathing studies. If you run short of breath, raise the pace." con un enlace textual "Qué sabemos" / "What we know".
- y 284: **Regla de tiempo**: "Guiar durante" / "Guide for", recorrido 5-30 min con marcas largas en 5, 10, 15, 20, 30; lectura "15 min". Debajo, 13 `texto2`: "Después el oleaje sigue solo, sin guía." / "Afterwards the sea keeps going on its own, unguided."
- y 356: estado, 15 `texto2`: "Guiando · 6 por minuto · se retira en 12 min" / "Guiding · 6 per minute · fades in 12 min"; o "Disolviéndose · 3 min" / "Dissolving · 3 min"; o "Apagada" / "Off".
- Debajo de pulsación larga en la Regla de ritmo: fila técnica "Inhalar 4 s · Exhalar 6 s" con dos Reglas pequeñas, y, si HealthKit está autorizado, "Tu ritmo nocturno medio, según Salud: 13 /min" / "Your average night pace, from Health: 13 /min" con botón secundario "Empezar desde ahí" / "Start from there". El permiso de Salud se pide **aquí**, al tocar ese botón, nunca antes; la Marea funciona sin él.
- Háptica "Mínima / Marcada / Ninguna" como fila de segmentos del sistema al final; solo con el iPhone en la mano (CoreMotion), primeras 3-5 respiraciones.
- Pro tras la prueba: todo visible y operable 30 s; la versalita "Pro" junto al título; la hoja Pro se abre al terminar los 30 s, no antes.

### 4.4 Temporizador (hoja a `.medium`) · "¿Cuándo se apaga?"

Título y 24: "¿Cuándo se apaga?" / "When does it stop?" 22 Medium. Tres modos como **tres filas de 64 pt con hairline**, nombre 17 Semibold a la izquierda, lectura a la derecha, y el modo elegido marcado por forma: su fila lleva la Regla desplegada debajo (88 pt extra) y las otras dos solo nombre y último valor en `texto2`:

1. **"Hasta dormirme" / "Until I fall asleep"** · Regla de tiempo 15-90 min, marcas largas 15, 30, 45, 60, 90; lectura "45 min". Los valores > 60 llevan la versalita "Pro" bajo la marca para el usuario gratuito; al elegirlos, se aplican 30 s de prueba de la hoja Pro… no: aquí no hay nada que "escuchar", así que se aplica la **hoja Pro con el precio en la primera línea** y el temporizador queda en 60 si no compra. Nota 13: "El sonido baja durante los últimos 10 minutos. Tu alarma no se toca." / "The sound fades over the last 10 minutes. Your alarm is untouched."
2. **"Escudo nocturno" / "Night shield"** · `DatePicker` del sistema en modo hora compacta: "Hasta las 07:00" / "Until 07:00", con una segunda Regla "Bajar el nivel durante la noche" / "Lower the level through the night": 0-50 %, lectura "−20 %". Nota: "Toda la noche. A las 07:00 se funde en 10 minutos." / "All night. At 07:00 it fades over 10 minutes." Pro.
3. **"Siesta" / "Nap"** · Regla con tres marcas duras 10 · 20 · 30 min. Nota: "Se funde en los últimos 2 minutos." / "Fades over the last 2 minutes." Gratis.

Fila final, 56 pt: "Sin temporizador" / "No timer" en `texto2` (sustituye a "Apagado" como primer botón relleno de la app actual). Pie 13: "El fundido es espectral: primero se van los agudos, luego los graves." / "The fade is spectral: highs go first, then lows." (si el motor lo implementa; si no, "El audio se desvanece antes de que termine el temporizador." que ya existe).

**Prolongar a oscuras** (P2): no se abre esta hoja. Desde la Noche, la Live Activity y el Watch, **+15 min** es un gesto o un botón de 64 pt; aquí dentro, la Regla ya está desplegada en el valor actual.

### 4.5 Pantalla Noche · "¿Todo sigue bien?"

Negro absoluto; nada de barras. Se entra con el gesto de arrastre hacia abajo desde la principal con la sesión sonando, o sola al bloquear con temporizador en marcha (al desbloquear, se ve Noche, no la principal). La esfera atenuada del instrumento:

- **y 356-432, centrado**: la **Cifra** 72 SF Mono Medium `texto`: "48" con la versalita "min" / "min" a la derecha (unidad 15 `texto2`... no: de noche `texto2` sí se permite en la app, pero la unidad va en `texto` al 100 % a 15 pt Medium para no bajar de 7:1 en nada que importe). Si no hay temporizador: la hora "00:42" ocupa la Cifra.
- **y 452**: la hora en 22 Mono Medium `texto2` ("00:42") cuando hay cuenta atrás. Opción en la hoja Noche (pulsación larga): "Sin reloj" / "No clock" (el M11-D).
- **y 600**: la **Regla de la noche**: solo escala (marcas en `texto3`, largas en `texto`) de 353 pt, sin pulgar, y el Índice en `índice-noche` como aguja de 2 × 22 pt en la fracción de tiempo transcurrida; **sonando = línea base continua; en pausa = línea base discontinua (marcas sin base)**. Es el estado por forma, legible bajo rojo y en gris.
- Sin nombre de mezcla, sin logo, sin texto. Luminancia: < 4 % de píxeles encendidos.

**Gestos (los únicos):**
- **Un toque en cualquier parte** = pausa / reanuda (fundido 1,5 s / 800 ms). Sin háptica de noche: el sonido confirma.
- **Arrastre horizontal en cualquier parte** = **+15 min** por cada 64 pt hacia la derecha (la Cifra sube 48 → 63 con el dedo; la aguja retrocede); hacia la izquierda, −15 hasta un mínimo de 5. Sin pantalla intermedia.
- **Arrastre vertical** = nivel maestro (la Regla de la noche cambia momentáneamente a escala de nivel y la Cifra muestra el nivel "62" en 56 pt mientras dura el gesto, 1,5 s después vuelve al tiempo).
- Arrastre hacia arriba largo desde el borde inferior = volver a la principal (el gesto del sistema de ir a casa sigue siendo el del sistema; este es un arrastre dentro de la vista, con el indicador de inicio visible).
- Pulsación larga en la Cifra = hoja Noche: "Sin reloj", "Brillo mínimo al entrar" (sugerencia de ajuste, no control del brillo del sistema).

**Reduce Motion**: nada se mueve de por sí (solo cambios a 1 Hz). **Always-On / `isLuminanceReduced`**: la Regla se congela, el reloj a 1 Hz. Accesible en Acceso guiado con la disposición de un solo botón. VoiceOver: la vista entera es un botón "Sonando, 48 minutos restantes, toca para pausar; desliza a la derecha para añadir 15 minutos" (acciones personalizadas "+15 minutos", "−15 minutos", "Subir nivel", "Bajar nivel").

### 4.6 Modo Madrugada · "¿Puedo volver a dormirme sin encender nada?"

Variante de Noche que se lanza desde la pantalla de bloqueo (botón de la Live Activity "Madrugada" / "Small hours", el botón de Acción o un Atajo) y **dura 20 minutos desde el bloqueo**: arranca la última noche a nivel −6 dB con la Marea activa a 6 /min durante 5 min, luego el oleaje sigue solo y todo se disuelve en el minuto 20.

- Negro; **sin reloj** (saber la hora a las 4 es lo peor que se puede ofrecer); solo el **Mareógrafo** en `índice-noche` a y 426 (centrado verticalmente) respirando, y a y 540 la Regla de la noche con la aguja avanzando de 0 a 20. Nada de cifra: no hay nada que leer.
- Un toque = parar ahora (fundido 3 s). Arrastre horizontal = +10 min (máximo dos veces; después, "Madrugada" se convierte en "Escudo nocturno" hasta la alarma, dicho con una línea al despertar, no ahora).
- Reduce Motion: el Mareógrafo respira por opacidad.
- Copy de la Live Activity que lo lanza (botón secundario 44 pt): "Madrugada · 20 min" / "Small hours · 20 min".

### 4.7 Noches (mezclas guardadas, hoja a `.large`) · "¿Cuál de mis noches?"

Título: "Noches" / "Nights" 22 Medium; subtítulo 15 `texto2`: "Tal como las dejaste." / "Just as you left them."

Lista de **Filas de 64 pt** con hairline: nombre 17 Semibold ("Lluvia fina", "Ventilador lejano", "Mar lento", "La de viajar" …); debajo en 13 Mono `texto2` la receta: "Lluvia 40 · Marrón 20 · 45 min"; a la derecha, un Disco pequeño de 44 pt (glifo play 16) que reproduce **sin cerrar la hoja** (así se compara de oído). Tocar la fila carga la noche y cierra. La que suena ahora lleva la versalita "Sonando" / "Playing" junto al nombre y su Disco en pausa. Deslizar: "Renombrar" / "Rename" y "Borrar" / "Delete" estándar del sistema (destructivo en rojo del sistema solo porque es el sistema; dentro de la app no hay botón rojo). Reordenar con el gesto estándar de edición.

**Las noches de la casa** (el acierto de los presets del PR #3, con nombres de noche y no de promesa): "Lluvia fina" / "Light rain", "Ventilador lejano" / "Distant fan", "Mar lento" / "Slow sea" (con Marea), "Cama rosa" / "Pink bed" (solo rosa, para quien enmascara). Se pueden borrar; se restauran desde una fila terciaria al final: "Volver a poner las noches de la casa" / "Bring back the house nights". Nada de "Deep sleep" ni "Focus": la casa no promete, describe.

Guardar: desde la Barra (`square.and.arrow.down`) se abre una hoja `.medium` con un campo de texto del sistema precargado con el nombre humano de la receta ("Lluvia y marrón") y el botón primario "Guardar noche" / "Save night". Háptica `.success`. Vacío (nunca ocurre por las noches de la casa; si el usuario las borró): una línea 17 `texto2` a y 1/3: "Ninguna noche guardada. Toca Guardar en la barra cuando una te guste." / "No saved nights. Tap Save in the bar when you like one." Sin icono.

Límite gratuito: una noche propia además de las de la casa; la segunda abre la hoja Pro **después** de guardar (se guarda igual; Pro desbloquea la tercera y siguientes). Las guardadas se conservan siempre. iCloud Key-Value Store para sobrevivir a reinstalar y cambiar de iPhone (sin cuenta propia).

### 4.8 Paywall y prueba · "¿Qué cuesta y qué sigue gratis?"

**Hoja Pro** (`.large`, se abre solo cuando el usuario toca algo Pro fuera de la prueba, o desde "Pro" en Ajustes):

- y 24: título 22 Medium: "SleepNoise Pro" (única aparición del nombre de la app dentro de la app, junto con Ajustes).
- y 60: **la Cifra**: "29,99 €" / "$29.99" en 56 SF Mono Medium `texto`, con la unidad en versalitas a la derecha: "una vez" / "once". El precio es lo primero que se ve, antes de cualquier toque y antes de la lista. Si hay precio de lanzamiento: debajo, 13 `texto2`: "Precio de lanzamiento hasta el 14 de diciembre. Después, 34,99 €." / "Launch price until December 14. Then $34.99." Sin tachaduras, sin cuenta atrás.
- y 140: lista de cuatro Filas de 56 con hairline, 17 Regular `texto`, sin iconos:
  - "Todas las texturas, ahora y las que vengan." / "Every texture, now and to come."
  - "Marea respiratoria." / "Breathing tide."
  - "Temporizador de toda la noche y Escudo nocturno." / "All-night timer and Night shield."
  - "Noches guardadas sin límite." / "Unlimited saved nights."
- y 380: bloque 15 `texto2`, dos líneas: "Sigue siendo gratis para siempre: blanco, rosa, marrón, lluvia, siesta y 60 minutos. Tus noches guardadas se conservan." / "Free forever: white, pink, brown, rain, nap and 60 minutes. Your saved nights stay."
- y 452: botón primario "Comprar · 29,99 €" / "Buy · $29.99" (50 pt). Debajo, terciario "Restaurar compra" / "Restore purchase" y, en la misma línea, "Compartir en familia incluido" / "Family Sharing included" en 13 `texto2`.
- Pie 13 `texto2`: "Un solo pago. Sin suscripción, sin cuenta, sin red. Nada sale de tu iPhone." / "One payment. No subscription, no account, no network. Nothing leaves your iPhone."

Estados: durante StoreKit, el primario pasa a deshabilitado 1-2 s; error → línea 13 `texto` (no roja): "No se pudo completar. No se ha cobrado nada." / "Couldn't complete. Nothing was charged."; comprado → la hoja se cierra sola y la línea de estado de la principal dice una vez "Gracias. Pro, para siempre." / "Thank you. Pro, for good."; en Ajustes queda "SleepNoise Pro · desde el 16 de noviembre de 2026".

**Tarjeta de prueba** (hoja `.medium`, una sola vez, la primera vez que el usuario toca algo que sería Pro; nunca al abrir la app; cumple 3.1.1 con duración, pérdidas y precio):
- Título 22: "7 noches con todo. Sin tarjeta." / "7 nights with everything. No card." (se conserva literal: es la respuesta a la queja número uno). Si el dueño elige 14, "14 noches".
- Cuerpo 17: "Hoy empieza una prueba de 7 noches con todas las texturas, la Marea y el temporizador largo. No pedimos tarjeta ni cuenta: la prueba vive en este iPhone." / "A 7-night trial starts today with every texture, the tide and the long timer. We don't ask for a card or an account: the trial lives on this iPhone."
- 15 `texto2`: "Cuando termine, siguen gratis blanco, rosa, marrón, lluvia, siesta y 60 minutos, y tus noches guardadas se conservan. Pro cuesta 29,99 € una vez." / "When it ends, white, pink, brown, rain, nap and 60 minutes stay free and your saved nights stay. Pro is $29.99 once."
- Primario "Empezar las 7 noches" / "Start the 7 nights"; terciario "Ahora no" / "Not now" (y lo que se tocó queda sin aplicar, sin castigo).
- Durante la prueba, la única marca en toda la app es la versalita de la línea de estado: "Prueba · 5 noches". Noches 6 y 7: "Prueba · última noche. Después siguen gratis blanco, rosa, marrón, lluvia y 60 minutos." / "Trial · last night. Afterwards white, pink, brown, rain and 60 minutes stay free." Sin notificaciones.

### 4.9 "Qué sabemos y qué no" · "¿Esto está demostrado?"

Pantalla *push* desde cualquier afirmación (el enlace textual "Qué sabemos" de la Marea, del temporizador y de Ajustes) y desde la ficha. Lista tipográfica, sin iconos ni sellos, fondo negro, 17 Regular `texto` para la afirmación, 15 `texto2` para la prueba, hairline entre entradas:

- "Enmascarar un ruido intermitente con un ruido continuo reduce los despertares que ese ruido provoca." / "Masking intermittent noise with a continuous one reduces the awakenings that noise causes." — "Stanchina et al., 2005, n = 4 en laboratorio de sueño; financiación académica. Es un estudio pequeño." / "Stanchina et al., 2005, n = 4 in a sleep lab; academic funding. It is a small study."
- "Respirar a unas 6 veces por minuto se asocia en estudios a mayor variabilidad de la frecuencia cardiaca." / "Breathing at about 6 per minute is associated in studies with higher heart-rate variability." — "Zaccaro et al., 2018, revisión de 15 estudios; Tsai et al., 2015, n = 61. No mide el sueño." / "…does not measure sleep."
- "Que el ruido continuo mejore el sueño no está demostrado." / "That continuous noise improves sleep is not proven." — "Riedy et al., 2021, revisión de 38 estudios: evidencia de muy baja calidad. Por eso no lo decimos." / "…very low quality evidence. That is why we don't claim it."
- "Lo que esta app no hace: no mide tu sueño, no te puntúa, no trata nada." / "What this app does not do: it doesn't measure your sleep, score you or treat anything." — "No es un producto sanitario." / "Not a medical device."
- "Lo que sale de tu iPhone: nada." / "What leaves your iPhone: nothing." — "Sin red salvo la App Store al comprar. Ficha: Data Not Collected." / "No network except the App Store at purchase. Listing: Data Not Collected."
- "Cuánto pesa y cuánto tarda: 3,1 MB; suena en menos de un segundo." / "Size and start-up: 3.1 MB; plays in under a second." (cifras a medir y actualizar en cada versión).

### 4.10 Live Activity, Dynamic Island, StandBy

Diseñada primero en rojo. Un solo valor de tinta (`texto`), el Índice solo como forma ≥ 3 pt, texto ≥ 18 pt Medium, cifra ≥ 34 pt.

- **Lock Screen (compacta, 160 pt de alto en el peor caso):** izquierda arriba, nombre de la noche 17 Semibold ("Lluvia fina"); debajo, la **Cifra** 34 SF Mono "48" + versalita "min"; a la derecha, **un solo control**: Disco de 64 pt (play/pause, `AudioPlaybackIntent`); fila inferior: **Regla de tiempo** estática de borde a borde (marcas `texto` al 100 %, no opacidades) con la aguja `índice` en la fracción transcurrida; base continua = sonando, base discontinua = pausa. Botón secundario 44 pt "+15" en Mono a la izquierda del Disco y, si es de madrugada (00:00-06:00), "Madrugada · 20 min" como texto bajo la Regla.
- **Dynamic Island compacta:** *leading* glifo de regla (línea con índice) en `texto`; *trailing* "48 min" 15 Mono Medium. **Mínima:** el glifo de regla, con la aguja en `índice`. **Expandida:** nombre + Cifra 34 + Disco 56 + Regla.
- **StandBy nocturno (apaisado, rojo):** la Live Activity escala ×2: Cifra 68, Regla de borde a borde, Disco 96. Bajo el tinte, `texto` → 4,43:1 (AA de texto grande y de componente), `índice` → 4,71:1 como forma. El estado se lee por la base continua/discontinua y por `play`/`pause`: nunca por color. Nada se anima (ActivityKit no lo permite y no hace falta).
- Fin: `.immediate` al terminar el fundido; la Live Activity dura la sesión (≤ 8 h), no la noche entera; el Escudo nocturno la emite con la hora de fin y actualiza en los hitos (cada hora, últimos 10 min).

### 4.11 Widgets

- **Pequeño (StandBy, Lock Screen):** fondo negro marcado *removable*; nombre de la noche 15 Medium; **Cifra** 34 Mono "48 min" o, en reposo, "Lista" / "Ready"; Regla estática abajo con el Índice. Interactivo: toda la superficie es un botón play/pause (`AudioPlaybackIntent`). En *accented* y *vibrant*, la Regla hereda la tinta del sistema; el Índice pasa a `texto` (no hay color en esos modos y el estado sigue leyéndose por la base).
- **Mediano:** tres noches como tres Filas de 44 con su Disco pequeño: "Lluvia fina · 45 min", "Ventilador lejano", "Mar lento · Marea". Un toque = suena.
- **Circular / inline (Lock Screen):** glifo de regla; inline "SleepNoise · 48 min".

### 4.12 Centro de control (iOS 18+), botón de Acción, Atajos

`ControlWidgetToggle` "Sonido para dormir" / "Sleep sound": símbolo propio *regla* en dos variantes: *off* = línea con escala en gris; *on* = la misma con la aguja (el sistema tiñe el *on* con el tinte del control: se declara `índice`). Subtítulo del control: la noche actual. Botón de Acción: "Mantén para Madrugada" / "Hold for Small hours". Atajos: "Reproducir noche", "Pausar", "Añadir 15 minutos", "Empezar Marea", "Madrugada"; automatización sugerida en Ajustes: "Al activar el Focus Sueño → Reproducir 'Lluvia fina'".

### 4.13 Apple Watch (mínimo)

Una sola pantalla (SF Compact del sistema; la Cifra en SF Mono Compact... no existe: se usa `.monospacedDigit()` sobre SF Compact Medium 44): la Cifra "48" con "min", la Regla de tiempo abajo con el Índice (amarillo del sistema del Watch, `#F0C020` declarado), y **la Digital Crown es el dial**: gira = nivel maestro (la Regla pasa a escala de nivel durante el giro, con detentes hápticos `.click`); toque = play/pausa; deslizar a la derecha = +15 min. Complicación circular: glifo de regla; Smart Stack: nombre + Cifra. **Háptico de Marea**: `.directionUp` al inicio de cada inhalación, opción "Mínima / Marcada"; la muñeca es la superficie natural porque no suena sobre la mesilla. Sin tracking, sin pulso.

### 4.14 Icono

"Un objeto, no una luna": **la regla con su índice**, grabada en un panel negro.

Construcción geométrica sobre la retícula de 1024:
- Fondo: `negro` pleno (Default y Dark); en Clear y Tinted, el sistema aporta el material.
- **Línea base**: rectángulo horizontal de 640 × 56 px (x 192-832, y 484-540), esquinas rectas, en `texto` `#E8E4DC`. Ocupa el 62,5 % del ancho: la proporción de la escala de la Regla.
- **Tres marcas**: rectángulos de 32 × 112 px apoyados sobre la línea base hacia abajo (y 540-652) en x 192 (inicio), x 496 (centro, −16) y x 800 (fin, −32), en `texto`. Son las marcas largas 0 / 50 / 100.
- **El Índice**: rectángulo vertical de 56 × 232 px en `índice` `#F0C020`, centrado en x 644 (el 70 % del recorrido: "casi a tope", el nivel de una noche real), desde y 396 hasta y 628, cruzando la línea base (la aguja del AB1 sobre la esfera). Es el único color: 1,2 % de la superficie.
- Sin degradados, sin sombra, sin borde. Icon Composer: capa 1 fondo, capa 2 línea y marcas (`texto`), capa 3 índice (`índice`); en Tinted, capa 2 toma el tinte del sistema y la capa 3 se declara como "acento" para que conserve el matiz donde el sistema lo permita, o se funda con la tinta donde no (el icono sigue leyéndose: una regla con una aguja).
- A 29 pt: un guion claro con tres dientes y una barra amarilla que lo cruza. Ninguno de los diez iconos de la categoría tiene una línea horizontal con un índice vertical; todos tienen luna, onda, nube u ojo. A 60 pt se ven las tres marcas. En escala de grises el índice sigue siendo la barra más clara después de la línea.
- Día (Light): el mismo icono con fondo negro (permitido y preferible: el objeto es negro).

### 4.15 Capturas de la App Store (seis) y preview

Fondo negro en todas, texto de la captura en SF Pro 34 Medium `texto` arriba, iPhone sin bisel decorativo (marco del dispositivo del sistema), sin degradados ni ilustración; en es-ES, es-419 y en-US.

1. **"Un solo pago. Sin cuenta. Sin red."** / **"Pay once. No account. No network."** — la pantalla principal en reposo (Banda a cero, Regla maestra con el Índice) y, debajo del titular, en 17 `texto2`: "29,99 €, una vez. 7 noches de prueba sin tarjeta." / "$29.99, once. 7-night trial, no card." El precio en la primera captura: es la promesa.
2. **"Nunca se repite. Se fabrica ahora."** / **"Never loops. Made right now."** — la principal sonando: la Banda con marcas de altura real y el Índice en el extremo; pie: "Ruido blanco, rosa y marrón y texturas generados en tu iPhone, no grabados." / "White, pink and brown noise and textures generated on your iPhone, not recorded."
3. **"Se oyen cambiar bajo el dedo."** / **"You hear them change under your finger."** — el mezclador con una Regla arrastrándose (lectura "40" a 20 pt sobre el pulgar amarillo); pie: "Seis capas. Más cerca, más lejano, más cálido. Lo técnico, debajo de una pulsación larga." / "Six layers. Closer, farther, warmer. The technical bits sit under a long press."
4. **"El mar respira más despacio. Tú con él."** / **"The sea breathes slower. So do you."** — la hoja de Marea guiando a 6 /min; pie: "Marea respiratoria: el oleaje se acompasa a 6 por minuto y luego se retira solo." / "Breathing tide: the sea paces itself at 6 per minute, then draws back on its own."
5. **"A las 3 de la mañana, un toque."** / **"At 3 a.m., one tap."** — la pantalla Noche (Cifra "48 min", Regla de la noche) junto a un StandBy en rojo con la Live Activity; pie: "Negro real. Pausa con un toque, 15 minutos más con un gesto, desde la app, el bloqueo o el reloj." / "True black. Pause with a tap, 15 more minutes with a swipe, from the app, the Lock Screen or your watch."
6. **"Se apaga sin despertarte."** / **"Fades out without waking you."** — la hoja del temporizador con los tres modos; pie: "Hasta dormirme, Escudo nocturno, Siesta. Fundido suave. Tu alarma no se toca. Nada sale de tu iPhone." / "Until I fall asleep, Night shield, Nap. Gentle fade. Your alarm is untouched. Nothing leaves your iPhone."

**Preview muda de 30 s:** 0-5 s el Disco se pulsa y la Banda arranca desde cero (el fundido de 800 ms visto); 5-12 s una Regla se arrastra con la lectura creciendo; 12-20 s la Marea: el Mareógrafo respira dos ciclos; 20-26 s arrastre hacia abajo → Noche, un toque pausa, un gesto +15; 26-30 s StandBy en rojo, luego negro con el icono. Sin música (la app no la tiene), sin voz, sin texto animado.

---

## 5. Qué se elimina de la app actual y por qué

| Se elimina | Por qué |
|---|---|
| Título "SleepNoise" y subtítulo "Para la noche" en la principal | La app no se titula; el contenido (la noche) sí. Bear enseña el título de la nota, no "Bear". |
| Cápsula "Prueba · 7 días" ámbar y botón "Pro" en la cabecera | Badge de oferta y recordatorio permanente de venta (lista negra). Pasa a una versalita en la línea de estado. |
| Tarjeta de prueba de seis líneas en la principal | Ocupa un cuarto de la pantalla el día uno; se sustituye por la hoja de prueba, una sola vez y solo al tocar algo Pro. |
| Siete tarjetas rellenas (prueba, Marea, capas), radio 18 | P6: cero rectángulos rellenos; las filas son texto, Regla y hairline. |
| Fondo `#0E1114` con degradado y halo ámbar radial | P3/P4: negro real; el único "halo" es la Banda, que tiene causa. |
| Iconos en círculo por capa (waveform, speaker, fan…) | Las palabras son los iconos; los glifos propios solo donde el sistema exige símbolo. |
| Play ámbar relleno de 88-112 pt | El acento no rellena botones; el Disco es grafito con relieve y el amarillo se va al Índice. |
| Etiquetas de texto "Temporizador" / "Guardar" bajo icono en la barra | Texto < 13 pt; la barra del sistema con glifos y `accessibilityLabel`. |
| Hoja del temporizador en rejilla 2 × 2 + "Personalizado" repetido + stepper | Una pregunta, tres modos con nombre, una Regla con detentes; prolongar no pasa por aquí. |
| Stepper "6 por minuto" y cinco botones de duración en la Marea | Reglas con detentes y el Mareógrafo arrastrable; lo técnico bajo pulsación larga. |
| Botón "Cerrar" en cápsula y título centrado en las hojas | Cierre y asa del sistema; título a la izquierda como pregunta. |
| Icono ámbar + frase gris centrados en "Mezclas guardadas" vacío | Las noches de la casa hacen que nunca esté vacío; si lo está, una línea de texto. |
| `lock.fill` y cápsulas "PRO" | Cero candados; la palabra "Pro" en versalitas y 30 s de escucha. |
| Reloj SF Rounded Light 44 | SF Mono Medium 56/72; Light prohibido. |
| Segundo acento `mist` | Un acento. |
| `symbolEffect` salvo `.pulse` en el fundido | Sin movimiento sin causa. |

Lo que se conserva literal: "7 días/noches con todo. Sin tarjeta.", el texto de la Marea, la nota de fundido, el toggle del sistema de la Marea, `.sensoryFeedback(.selection)`, el `BreathIndicator` aislado en `TimelineView` (se reutiliza como base del Mareógrafo), `monospacedDigit()`, los identificadores de accesibilidad y la lint de palabras médicas.

## 6. Qué se aprovecha del PR #3 y cómo se expresa aquí

| Del PR #3 | Cómo lo expresa Dial |
|---|---|
| **Presets de un toque** ("Deep sleep", "Focus", "Steady rain") | Se convierten en **las noches de la casa**, con nombres de noche y no de promesa ("Lluvia fina", "Ventilador lejano", "Mar lento", "Cama rosa"), en la hoja Noches y en el widget mediano; no como chips en la principal. Ninguno promete dormir profundo ni concentrarse. |
| **Pantalla Noche** (negro puro, reloj, "The screen can sleep. Sound keeps playing.") | Es la base de §4.5, corregida: contraste 16,56:1 y 7,48:1 en lugar de 2,7:1; SF Mono Medium en lugar de un reloj fino; la Regla de la noche como estado por forma; un toque y dos arrastres; entrada por gesto y automática al bloquear; sin nombre de mezcla. La frase se conserva como nota de la hoja Noche: "La pantalla puede dormirse. El sonido sigue." / "The screen can sleep. Sound keeps playing." |
| **Camas** (*beds*: los tres ruidos como base sobre la que se ponen texturas) | El mezclador se organiza en "Cama" y "Texturas"; la noche de la casa "Cama rosa" nombra el concepto; en la Banda descompuesta, la cama es la primera línea. |
| Atajos / App Intents (PR-A) | Se asumen como están (§4.12); la Live Activity y el Control usan los mismos intents. |
| Un toque para empezar | El Disco es el único botón con volumen y lo único que falta al abrir. |
| Tokens claros con AA | Se heredan en la paleta "papel" (§2.1), con el Índice en ocre. |

Lo que no se toma: el disco de 300 pt, los chips, la rejilla de once baldosas, la hoja "Niveles", el asa falsa, SF Rounded, los 14 candados, el degradado a 15 fps.

## 7. Autoevaluación contra los doce principios y las listas negras

| P | Prueba | Resultado |
|---|---|---|
| P1 Noche manda | Noche diseñada primero (§4.5), principal después; la maqueta incluye ambas y el rojo de StandBy | Cumple |
| P2 Un gesto | Pausa (toque), +15 (arrastre), nivel (arrastre vertical / Regla / Crown) en app, bloqueo y Watch | Cumple; prueba a ciegas pendiente de prototipo |
| P3 Negro real | 0,0,0; grafito solo en Disco, pulgares y hojas; un amarillo; < 4 % píxeles encendidos en Noche | Cumple |
| P4 Causa en el sonido | Tabla elemento → señal en §3.8 y §3.9; nada más se anima | Cumple |
| P5 Tipografía | Dos familias (SF Pro + SF Mono, defendida en §2.2); ≤ 5 estilos por pantalla; ≥ Medium de noche; Dynamic Type con tope en la Cifra | Cumple (la segunda familia es la decisión que el jurado debe aceptar o rechazar) |
| P6 Aire | Cero rectángulos rellenos en la principal; ≤ 1 relieve por hoja; hairlines | Cumple |
| P7 Forma, no color | Sonando = base continua / Índice en la Banda; pausa = base discontinua; Pro = palabra; todo sobrevive a gris y rojo | Cumple |
| P8 44 / 64 | Pulgares 64 × 64, Disco 72, Noche pantalla completa, Live Activity 64 | Cumple |
| P9 Nada bloquea | Día 8: blanco, rosa, marrón, lluvia, siesta, 60 min sin hoja de venta; candados 0 | Cumple |
| P10 Una pregunta | Cada superficie lleva su pregunta en el título de §4 | Cumple |
| P11 Técnico debajo | dBFS, Hz, 4:6, HealthKit: todo bajo pulsación larga | Cumple |
| P12 Sistema primero | Tabla §3.11; cuatro propios | Cumple |

Lista negra visual: sin tarjetas, halos, degradados, luna, ilustración, rejilla, gamificación, candados, badges, Rounded, Light, blanco puro, vidrio en contenido, dos acentos, selector de apariencia, asas falsas, animación en Always-On, iconos animados, bienvenida. **Cumple.** Lista negra de copy: revisada frase a frase en §4; "Qué sabemos" dice lo que no está demostrado. **Cumple.**

## 8. Riesgos y mitigación

| Riesgo | Mitigación |
|---|---|
| **"Gadget técnico"**: las cifras y las escalas asustan al segmento 2 (rumiación) | En reposo solo hay dos cifras en la principal (nivel y la lectura de cada capa, en 13 pt gris); las grandes aparecen bajo el dedo o en Noche; el copy es humano ("lluvia fina", "más lejano"); prueba de cinco segundos con cinco personas ajenas antes de la alta fidelidad final. |
| **SF Mono se lee como terminal** | Solo Medium, tracking −2 %, siempre acompañada de la escala de marcas y de una unidad en versalitas de SF Pro; nunca en frases; comparar en dispositivo con SF Pro tabular y decidir en el prototipo de una semana. Si pierde, la Cifra pasa a SF Pro Display Medium `monospacedDigit()` y el concepto no cambia. |
| **Amarillo = Halide / TE / "aviso"** | Área < 0,3 %; nunca relleno; matiz atemperado `#F0C020` (no `#FFCC00` ni naranja); en pantalla nunca junto a rojo; test en StandBy real y en tienda. |
| **El índice que "salta" de la Regla a la Banda confunde** | Regla simple y única ("el amarillo está en lo vivo"); transición de 250 ms por opacidad; si el test lo contradice, el repliegue es: Índice fijo en la Banda cuando suena y la Regla siempre blanca. |
| **La Regla sobre `Slider` del sistema pierde el vidrio o la accesibilidad** | Se mantiene el `Slider` como base (gesto, `.adjustable`, Liquid Glass transitorio) y solo se sustituye el *track*; probar en iOS 17, 18 y 26 con VoiceOver y Switch Control. |
| **Gestos de Noche se disparan por accidente** (la mano sobre la pantalla) | Umbral de 24 pt antes de reconocer arrastre; el toque exige < 300 ms y < 10 pt de movimiento; la pantalla se apaga sola en 60 s si no hay interacción (brillo del sistema); toda acción se puede deshacer con el gesto contrario sin pantalla intermedia. |
| **Banda a 20 Hz cuesta batería o impide que ProMotion baje** | `Canvas` aislado, pausado cuando no suena, al bloquear, bajo `isLuminanceReduced` y en Noche; presupuesto: ≤ 30 % del coste del motor; medir con Instruments antes de aceptar. |
| **Precio en la Cifra parece agresivo** | Es la petición del brief (el precio antes de cualquier toque) y la respuesta a la queja número uno; se acompaña siempre de la línea "sigue siendo gratis". Si el dueño prefiere, la Cifra baja a 34 pt sin cambiar la jerarquía. |
| **iOS 17 sin Control Center ni vidrio** | Nada del concepto depende del vidrio; un solo `#available`; el Atajo cubre el control. |
| **Las "noches de la casa" ocupan el hueco del usuario** | Se borran con un gesto y se restauran con una fila; nunca se marcan como "recomendadas". |
| **Dos familias rompen "una familia"** | El brief admite dos como máximo; la segunda se usa solo en cifras; el jurado decide con la hoja tipográfica y las capturas en Large, xxxLarge y AX3. |

---

*Entregable 2 (maqueta): `scratchpad/design/concepts/dial.html`. Decisiones abiertas al dueño que afectan a este concepto: 7 o 14 noches de prueba; precio (29,99 / lanzamiento 19,99); si la Marea v2 va en todas las texturas en 1.0 (el Mareógrafo ya lo admite: respira con cualquier capa); iOS mínimo.*

---

# Segunda parte · Interacción del concepto «Dial»

**Diseño de interacción del equipo Dial · 16 de noviembre de 2026 · amplía las secciones 1-8 sin modificarlas.** Convenciones: los tiempos son de interfaz salvo que se diga "audio"; "Índice" es el único elemento amarillo (§3.0); "Regla", "Banda", "Mareógrafo", "Disco" y "Cifra" son los componentes de §3. Los textos de interfaz definitivos están en §14 y los flujos los citan tal cual. Lo que se afirma del sistema (ActivityKit, AVAudioSession, StoreKit) procede de la matriz de §6 del informe de mercado; lo que es decisión de diseño se dice como tal. La maqueta añade los marcos 13-17 (§16).

## 9. Flujos completos, paso a paso

Cada flujo dice qué ve, qué oye y qué siente la persona en cada paso, y qué hace el sistema por debajo. Cuando un paso tiene alternativa sin gesto, remite a §13.4.

### 9.1 Primera noche, sin tutorial

Punto de partida: instalación limpia, 23:40, dormitorio con la lámpara encendida, brillo medio.

1. **Abre la app.** Ve la principal en reposo (§4.1) con la noche de la casa «Lluvia fina» cargada: título, línea de estado "45 min hasta dormirme", la Banda a cero (60 puntos), dos capas (Lluvia 40, Marrón 20), la fila de la Marea apagada, la Regla maestra en 62 con el Índice quieto en la aguja, la Barra con el Disco en *play*. Bajo la Barra, una sola línea de TipKit (`.popoverTip` anclado al Disco, estilo del sistema, fondo `grafito`): "Toca el disco. Arrastra las reglas. Nada más que aprender." No hay permisos, no hay registro, no hay precio, no hay nombre de app. Tiempo de arranque hasta pantalla interactiva: < 1 s.
2. **Toca el Disco.** Oye la lluvia y el marrón entrar en 800 ms. Siente `.impact(.medium, 0,7)` una vez, al inicio del fundido. Ve: el glifo pasa a *pause* (`.replace`), la Banda empieza a avanzar con la envolvente real, el Índice se funde en la aguja (250 ms) y aparece en la marca "ahora" de la Banda (250 ms), la línea de estado cambia a "Se funde a las 00:25". El Tip se cierra solo al primer toque y no vuelve (`Tips.configure` con `.datastoreLocation` local; el evento "disco tocado" invalida el tip).
3. **Arrastra una Regla** (por curiosidad o porque quiere más lluvia). Ve la lectura "40" crecer a 20 pt y el pulgar amarillo; oye la lluvia subir bajo el dedo (ganancia aplicada por bloque, sin zipper); siente un `.selection` por cada marca de 5. Suelta: lectura vuelve a 13 pt, el Índice vuelve a la Banda. El título pasa a "Lluvia fina · editada".
4. **Apaga la lámpara y bloquea el iPhone.** Como el temporizador está en marcha, la app registra la Live Activity (§12.1) y guarda `nightModeOnReturn = true`. La pantalla se apaga. No vibra, no notifica.
5. **Mira el iPhone a oscuras a las 00:05** (p. ej., para comprobar que sigue sonando). En la pantalla de bloqueo ve la Live Activity: "Lluvia fina", la Cifra "20 min", el Disco con *pause*, la Regla con la aguja al 55 %. No tiene que desbloquear. Si desbloquea, entra en **Noche** (§4.5), no en la principal.
6. **Se duerme.** A las 00:15 el fundido final de 10 min empieza: el audio baja y, en la Live Activity, la base de la Regla sigue continua y la aguja avanza; a las 00:25 el audio llega a cero, la Live Activity termina con `.immediate` (nada queda en el bloqueo por la mañana) y el proceso se suspende. Sin háptica, sin sonido, sin notificación.
7. **Al día siguiente abre la app.** Principal en reposo, "Lluvia fina · editada" (el nivel de 40→55 se recuerda; nada se guardó como noche nueva). Ningún tip. Si quiere conservarla: Barra → Guardar (hoja con el nombre precargado "Lluvia y marrón") → "Guardar noche". Es la primera y única noche propia gratuita; no se dice nada de límites hasta la segunda.

Lo que no ha pasado en toda la primera noche: ningún permiso, ninguna hoja de venta, ninguna mención de Pro (la versalita "Prueba" no aparece porque la prueba todavía no ha empezado: empieza cuando se toca algo Pro, §9.8). Lo que ha aprendido: todo.

### 9.2 Sesión normal (noche 12, usuario Pro o en prueba)

1. Abre la app (desde el icono, el widget mediano o el Atajo). Ve la última noche cargada; si fue "Mar lento", con la fila de la Marea mostrando "apagada" (la Marea no se recuerda encendida entre noches: encenderla es una decisión de cada noche; sí se recuerda su ritmo y duración).
2. Opcional: toca el título → hoja Noches → toca otra fila (carga y cierra) o su Disco pequeño (suena sin cerrar para comparar). Al cerrar con la hoja sonando, la principal ya está sonando.
3. Toca el Disco (o ya suena desde la hoja). 800 ms, háptica media, Índice a la Banda.
4. Opcional: Barra → Temporizador → la Regla del modo actual ya está desplegada en el último valor; arrastra con detentes; la hoja se cierra con el gesto del sistema. La línea de estado refleja la hora de fundido al instante.
5. Opcional: pulsación larga en la fila de la Marea → se enciende sin abrir nada (háptica `.selection`; el Mareógrafo compacto aparece bajo la fila en 250 ms y empieza a respirar en marea baja).
6. Desliza hacia abajo desde cualquier punto vacío (o toca la línea de estado) → **Noche**. Bloquea o deja el iPhone boca arriba: la pantalla se apaga sola por el sistema; Always-On (si existe) muestra la Cifra a 1 Hz y la Regla congelada.
7. El resto es §9.6 y §9.1 pasos 5-6.

Toques mínimos de una sesión normal: **uno** (el Disco). Toques de una sesión con temporizador distinto y Marea: cuatro.

### 9.3 Ajustar una capa a oscuras

Situación: 01:30, pantalla al mínimo, el marrón retumba demasiado. Dos caminos, ambos sin leer.

**Camino A, desde Noche (el habitual).** La persona no sabe qué capa sobra; sabe que "hay demasiado". Arrastre vertical hacia abajo en cualquier parte: la Cifra pasa de "48 min" a "62" → "50" mientras el dedo baja (56 pt, sin unidad: el número a secas es nivel; con unidad "min" es tiempo), la Regla de la noche cambia su escala a 0-100 y la aguja sigue al dedo. Oye el conjunto bajar en tiempo real. No hay háptica de noche (§11). Suelta: 1,5 s después la Cifra vuelve a "47 min". Resultado: toda la mezcla baja; la relación entre capas no cambia. Es lo correcto a las 01:30: la decisión fina es de día.

**Camino B, desde la principal (quien quiere tocar la capa).** Arrastre hacia arriba largo desde el borde inferior de Noche → principal (la esfera "se enciende": brillo del sistema sin tocar; la app no cambia el brillo). La principal de noche se muestra con la misma luminancia que de día (negro + tintas): lo que se ve son dos filas (Lluvia, Marrón) y dos Reglas de 353 pt con pulgares de 64 pt de área. El pulgar se encuentra con el pulgar de la mano: la Regla de Marrón está a y 412, la zona cómoda de una mano. Arrastra hacia la izquierda: la lectura "20" crece a 20 pt (legible a 40 cm con los ojos a medio abrir), oye el marrón bajar, siente un `.selection` por marca (si el iPhone está en la mano; si está apoyado, la háptica se omite, §11.3). Suelta, desliza hacia abajo → Noche otra vez. Total: un gesto de entrada, un arrastre, un gesto de salida.

**Camino C, Watch.** Gira la Digital Crown: la Regla del Watch pasa a nivel durante el giro, detentes `.click` cada 5. Es el camino de quien tiene el iPhone en la mesilla boca abajo.

Lo que no existe: una pantalla de "volumen rápido", un botón de "menos graves", una hoja. Lo técnico (corte de graves del marrón) sigue debajo de una pulsación larga sobre "Marrón" en el mezclador, de día.

### 9.4 Activar la Marea respiratoria: 15 minutos y disolución

Precondición: suena "Mar lento" (Océano 55, Marrón 15) o cualquier noche (la Marea v2 modula la envolvente de cualquier textura; si solo hay cama de ruido, modula el nivel de la cama con la misma curva, de forma más sutil: −6 dB de excursión en vez de −12).

**Activar.** Toca la fila "Marea respiratoria · apagada" → hoja `.medium` (§4.3). Toggle del sistema → encendido. O pulsación larga en la fila desde la principal (sin hoja). O "Oye Siri, empieza la Marea".

**Qué pasa en el primer minuto.**
- *Oye:* el oleaje no cambia de golpe. Durante la primera respiración (10 s) el motor toma el ancla (`guide.anchor`) en el siguiente cruce por cero de la envolvente del océano, de modo que la primera subida coincide con una ola que ya venía. A partir de ahí la textura sube 4 s y baja 6 s, con excursión creciente hasta llegar a la nominal en tres ciclos (30 s). Si HealthKit está autorizado y el usuario eligió "Empezar desde ahí", el ritmo arranca en su frecuencia nocturna media (p. ej. 13 /min) y baja 1 /min cada 40 s hasta 6: el descenso dura 4-5 min y se oye como un mar que se calma.
- *Ve (si mira):* en la hoja, el Mareógrafo respira: la línea se alarga de 12 % a 100 % del recorrido y vuelve, con el punto amarillo en la punta; la escala de marcas debajo tiene marcas largas en 12 % (bajamar), 40 % (fin de la inhalación nominal si el ciclo fuese simétrico: no se usa; se elimina) y 100 % (pleamar). Corrección sobre §3.9: las marcas largas van en bajamar, en el punto de **cambio de sentido** real (100 %) y en el 56 % (el punto medio de la exhalación, que es donde Reduce Motion fija la línea). El estado: "Guiando · 6 por minuto · se retira en 15 min". En la principal, la fila de la Marea muestra el Mareógrafo compacto. En la Live Activity, una línea de texto: "Marea · 6 /min" bajo la Regla (sin animación).
- *Siente (opt-in):* con "Háptica · Mínima" y el iPhone en la mano, un patrón continuo de Core Haptics cuya intensidad sigue `BreathCurve` (0,15-0,45, nitidez 0,2) durante las primeras 3-5 respiraciones y luego se retira solo. Con "Marcada", además un transitorio suave (intensidad 0,5, 60 ms) al inicio de cada inhalación durante toda la guía. En el Watch, `.directionUp` al inicio de cada inhalación durante toda la guía (es la superficie recomendada, porque no suena sobre la mesilla). Si el iPhone está quieto y horizontal (CoreMotion), la háptica del iPhone no corre.

**Minutos 1-12.** Nada nuevo. Si la persona vuelve a mirar la principal, ve el Mareógrafo compacto y "se retira en 9 min". Si entra en Noche, no ve el Mareógrafo: en Noche solo hay Cifra y Regla (la Marea se siente, no se mira; el Mareógrafo de noche existe solo en Madrugada, donde no hay Cifra). Decisión del equipo: menos cosas en Noche vale más que ver la ola.

**Minutos 12-15: disolución.** Es la parte que nadie más diseña.
- *Oye:* la excursión de la modulación baja linealmente de nominal a cero en 3 min (la ola sigue subiendo y bajando, cada vez menos, hasta que el océano vuelve a su oleaje libre). El ritmo no se acelera ni se frena: se desvanece. No hay señal de fin.
- *Ve:* el Mareógrafo respira cada vez menos (la amplitud sigue a la ganancia real de la guía), el estado pasa a "Disolviéndose · 3 min"; a los 15 min la línea queda en bajamar, el punto amarillo se funde (250 ms) y el Índice vuelve a la Banda. La fila de la principal pasa a "Marea respiratoria · se retiró" durante el resto de la sesión y a "apagada" en la siguiente.
- *Siente:* nada. La háptica terminó en la respiración 5 (Mínima) o se retira con la misma rampa de 3 min (Marcada; en el Watch, los pulsos pierden intensidad de `.directionUp` a `.click` y cesan).
- *Sistema:* escribe un `HKCategoryTypeIdentifier.mindfulSession` de 15 min si HealthKit está autorizado para escritura (se pidió al activar "Registrar en Salud" en la hoja, nunca antes). Nada más.

**Con Reduce Motion:** la línea del Mareógrafo queda fija al 56 % y su opacidad respira entre 100 y 70 % con `BreathCurve`; el punto amarillo no se mueve. **Con Always-On / `isLuminanceReduced`:** la hoja no está visible (Always-On muestra Noche o el bloqueo), así que no hay caso; la Live Activity no anima.

### 9.5 Temporizador de tres modos

Hoja `.medium` desde la Barra (§4.4). Pregunta: "¿Cuándo se apaga?".

**Hasta dormirme (gratis hasta 60).** La fila está seleccionada por defecto y su Regla desplegada en el último valor. Arrastre con detentes duros en 15, 30, 45, 60, 90 y detentes blandos cada 5 entre medias (háptica `.selection` solo en los duros). La lectura "45 min" crece a 20 pt al arrastrar. Al soltar, la línea de estado de la principal (visible atenuada detrás de la hoja) cambia a "Se funde a las 00:42". Usuario gratuito que arrastra más allá de 60: el pulgar llega a 60 y se detiene con `.impact(.light)` (tope físico); las marcas 75 y 90 llevan la versalita "Pro" debajo; tocar **directamente** la marca 90 abre la hoja Pro con el precio en la primera línea, y al cerrarla sin comprar el pulgar sigue en 60. Nada se ha perdido.

**Escudo nocturno (Pro).** Tocar la fila la selecciona (la Regla de "Hasta dormirme" se pliega en 250 ms, la de Escudo se despliega). Dentro: `DatePicker` compacto del sistema "Hasta las 07:00" (precargado con la hora de la alarma de Sueño si el usuario ha configurado el Focus de Sueño: se lee del `nextSleepScheduleWakeTime`... no existe API pública para la hora de alarma de Sueño; se precarga con la última hora elegida, 07:00 por defecto, y se dice en la nota). Segunda Regla "Bajar el nivel durante la noche" 0-50 %: el nivel maestro desciende linealmente ese porcentaje entre el minuto 30 y las 3 h, y se mantiene; es la respuesta al "a las 4 suena demasiado alto" sin tocar la mezcla. Nota: "Toda la noche. A las 07:00 se funde en 10 minutos. Tu alarma suena a su propio volumen." La Live Activity de Escudo muestra la hora de fin en lugar de la Cifra de minutos ("hasta las 07:00") y se actualiza cada hora y en los últimos 10 min (presupuesto de ActivityKit: ≤ 10 actualizaciones; la actividad dura ≤ 8 h, así que un Escudo de 23:30 a 07:00 son 7,5 h: cabe; si el usuario programa > 8 h, la Live Activity termina a las 8 h con el estado "sigue sonando hasta las 07:00" y el sonido continúa).

**Siesta (gratis).** Regla de tres marcas duras 10 · 20 · 30, sin valores intermedios (el pulgar salta). Nota: "Se funde en los últimos 2 minutos." Al elegir Siesta, la principal no cambia de aspecto: la noche es la noche; la línea de estado dice "Siesta · se funde a las 15:20".

**Sin temporizador.** Fila final; al tocarla, la Regla seleccionada se pliega y la línea de estado dice "Suena hasta que lo pares". No hay fundido por quietud en esta versión (el prototipo CoreMotion decide en 1.1); si entra, se añade aquí como fila "Parar cuando me duerma (quietud)".

**Prolongar** nunca pasa por esta hoja: Noche (+15 por arrastre), Live Activity (+15 botón), Watch (deslizar), Siri ("añade quince minutos"). En Escudo nocturno, +15 no tiene sentido y el gesto hace otra cosa: retrasa la hora de fin 15 min, y la Cifra de Noche muestra "07:15" en lugar de minutos.

### 9.6 Pantalla Noche y vuelta

**Entrar.** Tres formas, todas con la sesión sonando: (a) deslizar hacia abajo desde cualquier punto vacío de la principal (umbral 24 pt; la principal se funde a negro en 400 ms y la Cifra aparece por opacidad; nada se desplaza); (b) tocar la línea de estado; (c) automática: al bloquear con temporizador en marcha, la próxima vez que la app se muestre será Noche. No se entra en Noche sin sonido (no hay nada que vigilar); si el usuario desliza en reposo, la pantalla no responde y no se explica: no hay error que explicar.

**Dentro (§4.5).** Cifra "48 min" en 72 pt, hora "00:42" en 22 pt (desactivable: "Sin reloj"), Regla de la noche con la aguja `índice-noche`. Un toque = pausa (fundido 1,5 s de audio; la base de la Regla pasa a discontinua en 250 ms; la Cifra se queda; sin háptica) / reanuda (800 ms). Arrastre horizontal = ±15 min por cada 64 pt (la Cifra cuenta con el dedo: "48 → 63 → 78"; la aguja retrocede; al soltar, nada rebota). Arrastre vertical = nivel (§9.3). El temporizador llega a su fin: el fundido de 10 min se ve en la Regla (la aguja llega al extremo) y la Cifra baja a "0 min"; al terminar, la pantalla pasa a negro total con la hora en 22 pt `texto2` durante 10 s y la app deja de dibujar (la pantalla se apaga por el sistema). Si el usuario toca en esos 10 s, se reanuda la última noche con 15 min nuevos: el "una más" sin pantalla.

**Volver.** Arrastre hacia arriba largo desde la zona inferior (dentro de la vista, con el indicador de inicio del sistema intacto por encima): Noche se funde (400 ms) y la principal aparece en su estado real (sonando, con el Índice en la Banda). También: el botón de la Barra no está (Noche no tiene Barra), así que la vuelta es solo por ese arrastre, por VoiceOver (acción "Volver a los controles") o por la alternativa visible de §13.4.

**Al desbloquear por la mañana**: si la sesión terminó, la app muestra la principal en reposo (Noche sin sonido no existe). Si el Escudo sigue sonando, Noche.

### 9.7 Modo Madrugada desde el bloqueo

Son las 04:10. La persona se ha despertado, el temporizador terminó hace horas. No quiere saber la hora ni elegir nada.

1. **Levanta el iPhone** (raise to wake). Pantalla de bloqueo. La Live Activity terminó a las 00:25; no queda rastro. Lo que hay: el **control de Centro de control** (si lo añadió a la pantalla de bloqueo en iOS 18+: botón "Madrugada" con el glifo de regla, pulsación larga como exige el sistema), el **botón de Acción** ("Mantén para Madrugada"), el widget pequeño de bloqueo (toque = play/pausa de la última noche; no es Madrugada), o el Atajo por Siri ("Oye Siri, madrugada": la voz a las 4 es la peor opción y se documenta como la última).
2. **Mantiene el botón de Acción** (o el control). Siente la háptica del sistema del botón de Acción (no la nuestra). Oye: la última noche entra a −6 dB en 3 s (más lento que los 800 ms de día: a las 4 todo es más lento), con la Marea activa a 6 /min durante 5 min. No se enciende la pantalla por nuestra parte; si estaba encendida, el sistema puede mostrar la app: y lo que muestra es la pantalla **Madrugada** (§4.6): negro, el Mareógrafo en `índice-noche` respirando, la Regla de 0 a 20 con la aguja avanzando. Sin Cifra, sin reloj, sin nombre.
3. **Deja el iPhone.** La pantalla se apaga sola (brillo y tiempo del sistema). El Watch, si lo lleva, pulsa `.directionUp` en cada inhalación durante los 5 min de guía (opción "Háptico en el Watch" de la hoja de Marea; por defecto encendida solo en Madrugada, porque es donde más vale).
4. **Minuto 5:** la guía se disuelve en 3 min (igual que §9.4), el oleaje sigue solo. **Minuto 17-20:** fundido final de 3 min. **Minuto 20:** silencio; el proceso se suspende. Ninguna Live Activity (sería luz en la mesilla), salvo que el usuario la active en Ajustes ("Mostrar Madrugada en el bloqueo", apagado por defecto).
5. **Si sigue despierto en el minuto 12**, arrastre horizontal en Madrugada (o deslizar en el Watch) = +10 min, máximo dos veces (hasta 40 min). Tras la segunda, el modo se convierte en Escudo nocturno hasta la hora de alarma: se dice **por la mañana**, una línea en la línea de estado al abrir: "Anoche Madrugada siguió hasta las 07:00." Nunca a las 4.
6. **Un toque = parar ahora** (fundido 3 s). El toque se reconoce solo con < 300 ms y < 10 pt; el pulgar apoyado por accidente no para nada.

Lo que Madrugada **no** hace: no registra la hora del despertar, no cuenta "despertares", no escribe en Salud, no propone nada al día siguiente salvo esa línea. "La app que no te puntúa" se juega aquí.

### 9.8 La prueba: cuándo empieza, cómo caduca mientras suena, qué pasa después

**Empieza** la primera vez que el usuario toca algo que será Pro: una textura Pro en el mezclador (Ventilador, Océano, las nuevas), la Marea, un valor > 60 en el temporizador, Escudo, la segunda noche guardada. Aparece la hoja de prueba (§4.8) **después** de que lo tocado haya actuado: la textura ya suena, la Marea ya respira, el temporizador ya está en 90. Si elige "Ahora no", lo tocado vuelve atrás sin castigo (la textura se funde en 1,5 s, el temporizador vuelve a 60) y la hoja no reaparece hasta la próxima vez que toque algo Pro (no "nunca más": el usuario puede cambiar de idea; sí se limita a una vez por sesión). Si elige "Empezar las 7 noches", la hoja se cierra, la línea de estado antepone "Prueba · 7 noches ·" y nada más cambia. Se cuenta por **noches** (fechas locales distintas con uso), no por horas: siete noches con uso son siete noches aunque haya saltado una; el reloj no corre en días que no se abre la app. Regla honesta: se dice "noches", y son noches.

**Caduca mientras suena.** Noche 7, 23:50: la persona arranca "Mar lento" con Marea y temporizador de 90. A las 00:00 cambia la fecha; la séptima noche "termina" según el calendario. **No pasa nada.** Regla: el estado de la prueba se evalúa **solo al arrancar una sesión** (toque del Disco, carga de una noche, Atajo), nunca durante una sesión en curso ni al reanudar tras una pausa de la misma sesión. El sonido, la Marea, el temporizador de 90 y la Live Activity siguen hasta su final natural. Ningún aviso a medianoche, ninguna notificación por la mañana. Si de madrugada toca "+15" en la Live Activity, se añaden 15 min: la sesión es la misma.

**Después.** Noche 8, al abrir la app: principal con la última noche cargada ("Mar lento"), y la línea de estado dice **una vez** (hasta el primer toque del Disco) "Prueba terminada · 45 min hasta dormirme". La noche se carga honesta (§9.10): título "Mar lento · sin Océano", Océano como fila Pro sin pulgar, la Marea "Pro". Marrón suena al tocar el Disco. Si toca la línea de Océano: suena 30 s desde ese nivel (pulgar amarillo que se disuelve al final), y **al terminar los 30 s**, no antes, se abre la hoja Pro con el precio en la primera línea. Si la cierra, la fila vuelve a su estado Pro; puede volver a tocar y volver a oír 30 s (sin límite de veces: el límite es la paciencia, no el castigo). Día 8 recorrido completo del usuario gratuito sin ver la hoja Pro: blanco, rosa, marrón, lluvia, siesta, "Hasta dormirme" hasta 60, Noche, Madrugada (con la última noche sin sus capas Pro y sin Marea: Madrugada gratuito es la noche a −6 dB, 20 min; la Marea de Madrugada es Pro y simplemente no suena; se dice en Ajustes, no a las 4), Live Activity, widgets, Watch, Atajos. **Nada de eso enseña una venta.**

**Noches 6 y 7** la versalita de estado cambia a "Prueba · última noche" y, bajo las capas, una línea 13 `texto2` una vez por noche: "Después siguen gratis blanco, rosa, marrón, lluvia, siesta y 60 minutos. Tus noches se conservan." Es la única comunicación anticipada, y es texto, no hoja.

### 9.9 Compra y restauración

**Compra.** Hoja Pro abierta (desde una fila Pro, desde el temporizador, desde Ajustes). Precio como Cifra arriba. Toca "Comprar · 29,99 €": el botón pasa a deshabilitado (relleno `grafito2`, etiqueta "Comprando…") mientras StoreKit presenta su hoja del sistema (Face ID, confirmación de Apple). Casos:
- *Éxito:* la hoja Pro se cierra sola (250 ms), la línea de estado de la principal dice "Gracias. Pro, para siempre." hasta el primer toque, y todo lo que era Pro simplemente ya no lleva la palabra: la fila de Océano recupera su pulgar en el nivel que tenía guardado (55), la Marea su toggle, el temporizador su recorrido hasta 90. Háptica: ninguna (la hoja del sistema ya la dio). Si una noche cargada había perdido capas, el título vuelve a "Mar lento" y las capas suenan **si la sesión está sonando** (fundido de 1,5 s): comprar mientras suena completa la noche en el acto, que es el momento más persuasivo y el más honesto a la vez.
- *Cancelado por el usuario:* el botón vuelve a normal, sin mensaje.
- *Error (red, StoreKit):* línea 13 `texto` bajo el botón: "No se pudo completar. No se ha cobrado nada." El botón vuelve a normal. Sin rojo, sin alerta.
- *Pendiente (Ask to Buy, menor en Familia):* línea 13: "Pendiente de aprobación familiar. Mientras tanto, todo sigue como estaba."
- *Ya comprado (Family Sharing, reinstalación con la misma cuenta):* StoreKit lo devuelve como `verified` al arrancar; la app nunca enseña la hoja Pro a un usuario que ya es Pro. Si la enseñara por error de sincronización, el botón "Comprar" lo detecta y pasa a "Ya es tuyo" y cierra.

**Restauración.** "Restaurar compra" (terciario, siempre visible, también en Ajustes). Toca → `AppStore.sync()` → casos: encontrado → mismo cierre que éxito con línea "Restaurado. Pro, para siempre."; no encontrado → línea 13: "No hay compra en esta cuenta de Apple. Si la hiciste con otra, inicia sesión con ella en Ajustes de iOS."; error → "No se pudo comprobar. Inténtalo con conexión."

**Ajustes** (hoja desde el título, pulsación larga, o desde Noches › fila final "Ajustes"): la fila "SleepNoise Pro · desde el 16 de noviembre de 2026" y, si no es Pro, "SleepNoise Pro" con la Cifra pequeña "29,99 € · una vez" y chevron. Es el único punto de entrada permanente a la venta y está a dos niveles de la principal.

**Prueba y 3.1.1.** Si el dueño elige el non-consumable a 0 € "7-Day Trial" (recomendación del informe), la hoja de prueba se convierte en su hoja previa (duración, pérdidas, precio: ya los tiene) y el botón "Empezar las 7 noches" dispara la compra a 0 € con la hoja del sistema; nada cambia en la interfaz salvo que la prueba sobrevive a reinstalar.

### 9.10 Mezcla guardada que pierde capas Pro

Casos: (a) prueba terminada; (b) Pro no restaurado tras cambiar de cuenta; (c) una textura futura retirada del catálogo (no previsto, pero el patrón lo cubre).

1. **Al cargar la noche** (desde Noches, el widget mediano, un Atajo, o como última noche al abrir): la app compara la receta con lo disponible. Las capas disponibles suenan a su nivel; las no disponibles **se conservan en la receta** (no se borran: la noche sigue siendo la que el usuario guardó) y se muestran como filas Pro en la principal, sin pulgar, en su posición, con su nivel recordado.
2. **El título dice la verdad:** "Mar lento · sin Océano" / "Slow sea · without Ocean". Si faltan dos: "· sin Océano ni Marea". Si falta todo lo que sonaba (una noche solo de Océano): "Mar lento · nada suena ahora" y el Disco sigue operable: tocarlo no hace nada audible y la línea de estado dice "Esta noche era toda Océano. Tócalo para oírlo 30 segundos." Nada bloquea el Disco, pero tampoco se finge sonido.
3. **La Banda** refleja lo real: solo la envolvente de lo que suena. Con Océano fuera, la Banda de "Mar lento" es la del marrón: más baja y más lisa. Es la demostración de honestidad más barata de la app.
4. **En la hoja Noches**, la fila de esa noche añade en su receta la palabra en versalitas: "Océano 55 <sc>Pro</sc> · Marrón 15 · Marea <sc>Pro</sc>". Sin iconos, sin atenuar la fila.
5. **Al tocar la fila Pro** en la principal: 30 s de escucha a su nivel guardado (la noche suena completa durante 30 s: eso es lo que se vende), pulgar amarillo que se disuelve, hoja Pro al terminar. En el widget mediano, la fila "Mar lento" con una capa Pro reproduce lo disponible y no abre nada (el widget no vende).
6. **Guardar encima** de una noche con capas Pro perdidas no las borra: "Guardar" escribe la receta actual completa, incluidas las capas Pro a su nivel recordado. Renombrar y reordenar, igual. Borrar borra, con el gesto del sistema y su confirmación.
7. **Al volver a Pro** (compra o restauración), todas las noches recuperan sus capas sin hacer nada: no hubo pérdida, hubo silencio.

### 9.11 Interrupción por llamada y pausa de AirPods

**Llamada entrante (o Siri, o alarma del sistema).** `AVAudioSession.interruptionNotification` `.began`: el motor se detiene por el sistema. Interfaz: el Disco pasa a *play* (250 ms), la Banda cae a reposo en < 1 s (lee el motor), el Índice vuelve a la Regla maestra, la línea de estado: "En pausa · llamada" (o "· alarma", "· Siri"; si el sistema no dice la causa, "En pausa"). El temporizador **no se detiene**: es una hora de fin ("se funde a las 00:42"), no una cuenta de segundos; la Live Activity pasa a base discontinua y *play*, con la misma Cifra decreciendo. `.ended` con `.shouldResume`: fundido de entrada de 800 ms, Disco a *pause*, Índice a la Banda, línea de estado de vuelta a "Se funde a las 00:42". Sin `.shouldResume` (el usuario cogió la llamada y la terminó desde otro sitio): la app queda en pausa y **no reanuda sola**; en la Live Activity el Disco está ahí. Si la hora de fin pasa durante la llamada, la sesión termina en silencio: línea de estado al volver "Terminó a las 00:42 durante la llamada", Live Activity cerrada. En Noche, una llamada muestra la pantalla de llamada del sistema; al volver, Noche en pausa (base discontinua), un toque reanuda.

**Alarma del sistema (despertador)**: igual que la llamada, y es el caso que importa: la alarma suena a su volumen, la app calla, y al descartar la alarma la app **no** reanuda (`.shouldResume` suele venir, pero por la mañana reanudar el ruido es un error de producto). Regla de diseño: entre las 05:00 y las 11:00, una interrupción por alarma termina la sesión en lugar de pausarla. Se dice en la nota del temporizador: "Tu alarma no se toca."

**Pausa de AirPods al dormirse (iOS 26, "Pausar al dormirse").** Llega como `pauseCommand` de Now Playing (hipótesis del informe; el prototipo lo confirma). La app responde con un fundido de **3 s de audio y 2 s de interfaz** (la interfaz acaba antes para que nada se mueva en una pantalla que se va a apagar): Disco a *play*, Live Activity a pausa con la línea "En pausa · tus AirPods" / "Paused · your AirPods". El temporizador sigue su hora de fin y, si llega estando en pausa, cierra la Live Activity. No reanuda sola. Si la persona se despierta y toca el Disco en la Live Activity, reanuda con 800 ms **por la misma ruta** si los AirPods siguen conectados; si no, por la ruta actual (altavoz) **solo si el nivel maestro ≤ 40**; si es mayor, reanuda a 40 y la línea de estado dice "Nivel bajado al 40 para el altavoz". Nunca un arranque a todo volumen por el altavoz a las 3.

**AirPods que se quitan o se agotan** (`routeChange` `.oldDeviceUnavailable`): el sistema pausa; misma interfaz con "En pausa · auriculares desconectados". No reanuda sola por el altavoz: jamás.

**HomePod/AirPlay** (`outputLatency` hasta 2 s): la Banda y el Mareógrafo compensan la latencia con `guide.anchor` para que lo que se ve coincida con lo que se oye en la habitación, no en el búfer.

### 9.12 Error de audio

Casos: la sesión de audio no se puede activar (otra app con sesión exclusiva, hardware ocupado, error del sistema tras un restart), el motor falla al arrancar (render callback no se instala), o se cae en mitad de la noche (watchdog del motor: 2 s sin callbacks con `isPlaying`).

**Al arrancar.** El Disco se pulsa, el relieve se invierte 200 ms, y… no entra sonido. La app lo sabe en < 500 ms. Interfaz: el Disco vuelve a *play*; bajo la línea de estado, en 13 `error` (el único rojo de la app, 6,12:1): "No se pudo arrancar el sonido. Toca el disco para reintentar." El Índice se queda en la Regla. No hay alerta modal, no hay hoja, nada bloquea. Segundo intento fallido: la línea añade "Si sigue sin sonar, cierra la app y vuelve a abrirla." Tercer fallo: añade un enlace textual "Enviar informe" que abre el correo del sistema con el log del motor (sin datos personales). VoiceOver anuncia la línea como `.announcement` con prioridad alta. Reintento automático: uno, a los 2 s, silencioso; después solo manual.

**Durante la noche.** El motor se cae a las 02:14. El watchdog lo detecta; intenta reiniciar el motor **una vez** con el mismo estado (fundido de 800 ms: si funciona, la persona no se entera). Si falla: la sesión termina; la Live Activity pasa a un estado final honesto y se queda 30 min: "Se detuvo a las 02:14" / "Stopped at 02:14" con el Disco en *play* (tocarlo reintenta desde el bloqueo). Sin notificación sonora, sin vibración. Al abrir la app por la mañana, la línea de estado: "Anoche el sonido se detuvo a las 02:14 por un error. Nos gustaría saberlo: Enviar informe." Es la única vez que la app pide algo, y pide ayuda, no una valoración.

**Previsualización de 30 s que falla** (capa Pro): la línea 13 `error` bajo la fila: "No se pudo escuchar. Inténtalo de nuevo." La hoja Pro **no** se abre: no se vende lo que no se ha podido oír.

---

## 10. Especificación de movimiento

Regla madre (brief P4, documento 02 §3): **nada se mueve sin causa física en el audio o en el dedo.** Tres causas: respiración, fundido, nivel. Una cuarta, instrumental: el cambio de estado de un control, que es el "clic" visual de la tecla (≤ 250 ms, sin rebote). Nada de `spring` con rebote de noche; `.smooth` (iOS 17) o `.easeInOut`. Ninguna animación infinita salvo la Banda y el Mareógrafo, que son el sonido.

| # | Elemento | Qué se mueve | Causa física | Duración | Curva | Reduce Motion | Always-On / StandBy / `isLuminanceReduced` |
|---|---|---|---|---|---|---|---|
| M1 | Banda (§3.8) | Altura de 60 marcas; la fila avanza de derecha a izquierda | RMS sumado por capa, 20 Hz, decimado a 10 marcas/s, suavizado 400 ms | Continua mientras suena | Lineal (es dato) | 4 Hz, constante 1,5 s; la fila sigue avanzando (es la prueba "nunca se repite"), pero sin "vibrar" | Congelada en la última posición; a los 2 s, fundido a reposo (2 pt) en 1 s. En Noche: no se dibuja |
| M2 | Banda: arranque | Marcas de 2 pt a altura real | Fundido de entrada del audio | 800 ms (sigue al audio) | `.easeOut` (la del audio) | Igual (es el dato) | — |
| M3 | Banda: parada | Marcas a 2 pt | Fundido de salida del audio | 1,5 s (pausa) / 10 min (temporizador) / 3 s (AirPods, Madrugada) | Sigue al audio | Igual | — |
| M4 | Índice: salto Regla ↔ Banda | Opacidad: se funde en un sitio y aparece en otro; **nunca se desplaza** | Cambio `isPlaying` | 250 ms | `.easeInOut` | Igual (ya es fundido) | No aplica (no hay Índice en Always-On) |
| M5 | Índice: en el pulgar | Aparece en la aguja del pulgar que se arrastra | Dedo encima (`isEditing`) | 150 ms | `.easeOut` | Igual | — |
| M6 | Regla: pulgar | Posición = valor | Dedo | Manipulación directa, 0 ms de latencia añadida | — | — | — |
| M7 | Regla: tramo recorrido | Longitud = valor | Dedo o automatización (Escudo baja el nivel) | Directa / 1 s por paso de automatización | Lineal | Igual | Congelado |
| M8 | Lectura 13 → 20 pt | Tamaño de texto, en su sitio | Dedo encima | 200 ms | `.smooth` | Cambio instantáneo (sin interpolar tamaño) | — |
| M9 | Pulgar Pro (30 s de escucha) | Aparece amarillo; se disuelve al final | Previsualización | Aparece 150 ms; opacidad 1 → 0 en los últimos 1,5 s | `.easeIn` | Igual | — |
| M10 | Mareógrafo (§3.9) | Longitud de la línea 12 % ↔ 100 %; el punto en la punta | `BreathCurve(t)` del motor, compensada `outputLatency` | 7,5-15 s por ciclo | `BreathCurve` (4:6), muestreada en 24 keyframes/ciclo y resincronizada en cada ancla | Longitud fija al 56 %; opacidad 100 → 70 % con la misma curva | Congelado en bajamar en ≤ 2 s |
| M11 | Mareógrafo: disolución | La amplitud del ciclo decrece | Ganancia de la guía → 0 | 3 min | Lineal (es la ganancia) | Opacidad decrece su excursión igual | — |
| M12 | Mareógrafo: arrastre de la punta | Ritmo (la longitud sigue al dedo; el ciclo se reanuda desde ahí) | Dedo | Directa; detentes cada 0,5 /min | — | Igual | — |
| M13 | Disco: pulsación | Relieve invertido (sombra interior 1 → 2 pt) | Tecla | 200 ms | `.easeInOut` | Igual (no es movimiento) | — |
| M14 | Disco: glifo play ↔ pause | `.contentTransition(.symbolEffect(.replace))` | `isPlaying` | Sistema (~300 ms) | Sistema | Fundido simple | — |
| M15 | Disco: fundido final | `symbolEffect(.pulse)` en el glifo | Fundido del temporizador en curso | Últimos 10 min (2 min en Siesta) | Sistema | Apagado | No se muestra |
| M16 | Hoja | Presentación/cierre | Sistema | Sistema | Sistema | Sistema | — |
| M17 | Entrada a Noche | Opacidad: principal → negro; Cifra y Regla aparecen | Gesto o bloqueo | 400 ms | `.easeInOut` | Igual (ya es fundido) | — |
| M18 | Salida de Noche | Inversa | Gesto | 400 ms | `.easeInOut` | Igual | — |
| M19 | Noche: Cifra ±15 | El número cambia por pasos de 15 con el dedo; `contentTransition(.numericText())` | Dedo | Directa; el `numericText` del sistema | Sistema | Sin `numericText` (cambio seco) | — |
| M20 | Noche: aguja de la Regla | Posición = fracción transcurrida | Reloj del temporizador | 1 actualización/min (la aguja se mueve 0,2 pt/min: imperceptible, honesta) | Lineal | Igual | Congelada; reloj a 1 Hz |
| M21 | Noche: base continua ↔ discontinua | `strokeDash` por opacidad de los huecos | Pausa / reanudación | 250 ms | `.easeInOut` | Igual | Congelada en el estado actual |
| M22 | Noche: nivel por arrastre vertical | La Cifra cambia a nivel; la escala de la Regla a 0-100 | Dedo | Directa; vuelta al tiempo 1,5 s después de soltar, por opacidad 250 ms | — | Igual | — |
| M23 | Madrugada: Mareógrafo | Como M10 en `índice-noche` | `BreathCurve` | 5 min de guía + 3 de disolución | Igual | Opacidad | No hay Always-On en Madrugada (la pantalla se apaga) |
| M24 | Madrugada: aguja 0 → 20 | Posición | Reloj | 20 min, 1 actualización/30 s | Lineal | Igual | — |
| M25 | Línea de estado | Cambio de texto | Estado | 250 ms opacidad | `.easeInOut` | Igual | — |
| M26 | Versalita de estado ("Guiando", "Fundiendo") | Aparece/desaparece | Estado | 250 ms opacidad | — | Igual | — |
| M27 | Tip (TipKit) | Sistema | Primer uso | Sistema | Sistema | Sistema | — |
| M28 | Fila de Marea en la principal: aparece el Mareógrafo compacto | Altura de la fila 44 → 84 por opacidad del contenido nuevo (la lista no "empuja": el hueco ya está reservado) | Toggle | 250 ms | `.smooth` | Igual | — |
| M29 | Temporizador: Regla que se despliega al cambiar de modo | Altura 0 → 88 (clip), la otra se pliega | Selección | 250 ms | `.smooth` | Sin cambio de altura animado: aparece/desaparece por opacidad | — |
| M30 | Live Activity | Nada (ActivityKit no anima); actualizaciones en hitos | Estado | — | — | — | Diseñada estática |
| M31 | Widgets | Nada | — | — | — | — | — |
| M32 | Watch: Regla ↔ nivel al girar la corona | Escala y aguja | Corona | Directa; vuelta a tiempo 1,5 s después | — | Igual | Always-On del Watch: Cifra a 1 Hz, Regla congelada |
| M33 | Watch: Mareógrafo | Como M10 | `BreathCurve` recibida del iPhone (ancla sincronizada por `WCSession`) | Igual | Igual | Opacidad | Congelado en bajamar |

Reglas transversales:
- **Ninguna animación supera 2 s** salvo las que son el sonido (M1, M10, M11, M23) y el fundido del temporizador (M3), que es el audio.
- **Lo que se congela en Always-On lo hace "gracefully"**: 2 s de margen y luego reposo; nunca un corte.
- **Nada cambia de luminancia más de 3 veces por segundo** en superficie > 1 % (WCAG 2.3.1): la Banda cambia marcas de 1 pt a 10 Hz, área total < 0,5 % de la pantalla; aceptable, y bajo Reduce Motion baja a 4 Hz.
- **Presupuesto**: la Banda es el único consumidor continuo (Canvas aislado, `TimelineView(.periodic(1/20))`, pausado en reposo, en Noche, bajo `isLuminanceReduced` y con `scenePhase != .active`); el Mareógrafo usa `KeyframeAnimator` (render server); todo lo demás es Core Animation finita. Cero fotogramas con la pantalla apagada: se verifica con Instruments 10 min bloqueado.

---

## 11. Háptica

### 11.1 Vocabulario del Dial

La háptica es el detente del instrumento: se nota en el dedo lo que la escala dice en la pantalla. Se gasta en los umbrales, no en el continuo. Todo con `sensoryFeedback` (iOS 17) salvo la Marea (Core Haptics) y el Watch.

| Momento | Patrón | Intensidad | Por qué así | Dónde no |
|---|---|---|---|---|
| Regla: cruzar una marca de 5 | `.selection` | Sistema | Detente de potenciómetro; 20 detentes por recorrido (no 100: moiré táctil) | Nunca de noche (Noche, Madrugada); nunca con el iPhone apoyado |
| Regla: cruzar 0 (silenciar / activar una capa) | `.selection` + `.impact(.light, 0,4)` 40 ms después | — | El umbral semántico: "¿la he apagado?" se contesta en el dedo | Igual |
| Regla: llegar a 100, o a un tope (60 gratuito en el temporizador) | `.impact(.light, 0,6)` | 0,6 | Tope físico | Igual |
| Regla de tiempo: detente duro (15/30/45/60/90; 10/20/30) | `.impact(.light, 0,5)` | 0,5 | Más que un detente, menos que un tope: el pulgar "cae" en el valor | — |
| Regla de ritmo: cada 0,5 /min | `.selection` | — | El ajuste fino se cuenta | — |
| Mareógrafo: arrastrar la punta, cada 0,5 /min | `.selection` | — | Igual que la Regla de ritmo: indicador y control dan lo mismo | — |
| Disco: arrancar | `.impact(.medium, 0,7)` una vez, al inicio del fundido | 0,7 | La confirmación más importante: "ha empezado" sin mirar | En Noche y Madrugada: ninguna (el sonido confirma; vibrar en la mesilla suena) |
| Disco: pausar | `.impact(.light, 0,5)` | 0,5 | Más suave que arrancar | Igual |
| Cambio de modo del temporizador | `.selection` | — | Es una selección | — |
| Toggle de Marea | El del sistema | — | Componente del sistema | — |
| Pulsación larga en la fila de Marea (encender sin hoja) | `.impact(.light, 0,5)` | — | Confirma un gesto que no abre nada | De noche, no |
| Pulsación larga (fila técnica, dBFS, Banda por capas) | `.selection` al abrir | — | "Se ha abierto algo bajo el dedo" | — |
| Guardar noche | `.success` | — | Única notificación de sistema; despierto y con luz | — |
| Noche: toque (pausa/reanuda), ±15, nivel | **Ninguna** | — | La mesilla de madera es un altavoz; el oído confirma | — |
| Madrugada: todo | **Ninguna** del iPhone | — | Igual; la Marea de Madrugada vibra en el Watch, no en el iPhone | — |
| Fin de temporizador, fin de Marea, fin de prueba | **Ninguna** | — | La persona duerme | — |
| Hoja Pro, precio, compra | Ninguna propia (la hoja del sistema tiene la suya) | — | Nunca háptica como marketing | — |
| Error de audio | `.error` **solo** si la app está delante y el usuario acaba de tocar el Disco | — | Respuesta a una acción; nunca espontánea | Nunca de noche |
| Live Activity, widgets, Centro de control | Las del sistema | — | No se controlan | — |
| Marea en el iPhone ("Mínima") | Core Haptics: `CHHapticPattern` continuo, intensidad 0,15 → 0,45 siguiendo `BreathCurve`, nitidez 0,2 | — | Guía para dejar de mirar; se retira tras 3-5 respiraciones | Solo con el iPhone en la mano (CoreMotion); motor con `playsHapticsOnly = true`, destruido al terminar |
| Marea en el iPhone ("Marcada") | Lo anterior + transitorio (intensidad 0,5, nitidez 0,3, 60 ms) al inicio de cada inhalación, toda la guía | — | Para quien quiere el pulso completo | Igual |
| Watch: Marea | `WKInterfaceDevice.play(.directionUp)` al inicio de cada inhalación; "Mínima" solo las 5 primeras, "Marcada" toda la guía; en la disolución pasa a `.click` y cesa | — | La muñeca no suena en la mesilla: es la superficie natural | — |
| Watch: corona (nivel) | `.click` cada 5; `.directionDown` al llegar a 0; `.directionUp` al llegar a 100 | — | Detentes de la corona | — |
| Watch: toque play/pausa | `.start` / `.stop` | — | Vocabulario del sistema | — |
| Watch: deslizar +15 | `.click` | — | Confirmación mínima | — |

### 11.2 Lo que se anuncia además de vibrar

Cada háptica tiene su equivalente para VoiceOver (`AccessibilityNotification.Announcement`), con prioridad baja para no pisar la lectura: "Sonando" / "Playing", "En pausa" / "Paused", "Lluvia, 45 por ciento" (solo al soltar), "Guardada" / "Saved", "Tope, 60 minutos; más allá requiere Pro" / "Limit, 60 minutes; beyond needs Pro".

### 11.3 Cuándo no vibrar (reglas de silencio)

1. **iPhone quieto y horizontal** (CoreMotion, misma señal que el futuro fundido por quietud): está en la mesilla; cualquier vibración es sonido. Se omiten todos los detentes y la Marea háptica.
2. **Noche y Madrugada**, siempre.
3. **Durante cualquier fundido** (arranque excluido: el impacto es *al inicio*).
4. **"Háptica del sistema" desactivada** en Ajustes de iOS: `sensoryFeedback` lo respeta; Core Haptics consulta `supportsHaptics` y el ajuste propio "Háptica · Ninguna".
5. **Segundo plano**: imposible y no se diseña nada que lo necesite.
6. **Nunca al abrir el paywall, al enseñar el precio ni al terminar la prueba.**

---

## 12. Superficies del ecosistema, dibujadas en palabras

Todas se diseñan primero en rojo (StandBy nocturno) y en gris: una sola tinta `texto`, el Índice solo como forma ≥ 3 pt, el estado por forma (base continua/discontinua, `play`/`pause`) y por palabra. Texto ≥ 18 pt Medium donde el sistema lo permita; cifra ≥ 34 pt. La gramática es la de la Live Activity de Flighty: **una línea por valor**, y aquí los valores son tres: qué noche, cuánto queda, suena o no.

### 12.1 Live Activity

**Ciclo de vida.** Se registra al bloquear con sesión sonando (no al arrancar: si la persona está mirando la app no hace falta), o al arrancar desde un Atajo/Watch/widget con la pantalla bloqueada. Dura la sesión (≤ 8 h). Se actualiza en hitos: arranque, pausa/reanudación, ±15, cada hora en Escudo, inicio del fundido final, fin. Termina con `.immediate` al terminar el fundido (nada queda por la mañana); en error, queda 30 min con el estado final (§9.12). `staleDate` = hora de fin + 1 min: si el proceso muriese sin avisar, el sistema la marca como obsoleta y la app la cierra al despertar.

**Pantalla de bloqueo (Lock Screen presentation), 160 pt de alto como máximo; aquí 160.** Fondo negro (`activityBackgroundTint(.black)`), esquinas del sistema. Izquierda, de arriba abajo: nombre de la noche 17 Semibold ("Lluvia fina"); la **Cifra** 34 SF Mono Medium con versalita "min" ("48 min"); en Escudo, "hasta las 07:00" en 22 Mono. Derecha: **un solo control principal**, el Disco de 64 pt (`Button(intent: TogglePlaybackIntent())`, `AudioPlaybackIntent` para que el sistema no abra la app ni hable), con `play.fill`/`pause.fill` 24 pt. A su izquierda, un botón secundario de 44 pt "+15" en Mono con contorno `texto3` de 1 pt (`Button(intent: ExtendIntent(minutes: 15))`). Abajo, de borde a borde: la **Regla de tiempo** estática (marcas `texto` al 100 %, 21 marcas, largas en 0/50/100) con la aguja `índice` 2 × 22 en la fracción transcurrida; **base continua = sonando; discontinua = pausa**. Entre 00:00 y 06:00 y si no hay temporizador (sesión en pausa o terminada por error), bajo la Regla una línea 15 Medium: "Madrugada · 20 min" como botón textual (`Button(intent: SmallHoursIntent())`). En pausa, la línea de la Cifra cambia a "en pausa" en 22 `texto` (no `texto2`: una sola tinta) y la causa en 15: "tus AirPods" / "llamada" / "auriculares desconectados". Tocar en cualquier parte que no sea botón abre la app en Noche (`widgetURL`), no en la principal.

**Dynamic Island.**
- *Mínima* (otra actividad ocupa la Isla): el glifo de regla (línea con tres dientes) 22 × 14 en `texto` con la aguja en `índice`; en pausa, la aguja en `texto`.
- *Compacta*: `leading` el glifo de regla; `trailing` la Cifra "48 min" en 15 Mono Medium (o "en pausa" en `texto2`: aquí sí, la Isla no va a StandBy). Toque → expandida.
- *Expandida* (371 × 150): la misma composición que el bloqueo con el Disco a 56 pt y la Regla de 327 pt; además la línea de estado "Sonando · se funde a las 00:42" en 13 Medium (la Isla se mira despierto).
- Nunca se usa la Isla para la Marea (no hay nada que animar y la HIG pide no animar la Isla sin causa); la Marea aparece como texto bajo la Regla en la expandida: "Marea · 6 /min · 9 min".

**StandBy nocturno (apaisado, rojo).** La presentación de bloqueo escala ×2 a pantalla completa (`isActivityFullscreen`): nombre 28, Cifra 68-120 (según el ancho), Disco 96, +15 de 60, Regla de 740 pt. Bajo el tinte: `texto` → 4,43:1 (AA grande y componente), `índice` → 4,71:1 como forma. El estado se lee por la base y por el glifo. **Nada se anima.** Con `isLuminanceReduced` (StandBy atenuado), el sistema reduce; no se cambia nada: ya es una tinta. La maqueta 11 lo enseña; la 16 enseña los widgets en el mismo tinte.

### 12.2 Widgets (WidgetKit, iOS 17+)

- **Pequeño** (Home, Lock Screen rectangular no; StandBy): `containerBackground(.black, for: .widget)` marcado *removable*. Nombre de la noche 15 Medium; la Cifra 34 Mono ("48 min") o, en reposo, "Lista" / "Ready" en 34 SF Pro Medium (una palabra, no un número: es honesto con el estado); la Regla estática abajo con el Índice (en reposo, sin aguja y base discontinua). Toda la superficie es `Button(intent: TogglePlaybackIntent())`. En *accented* y *vibrant* (iOS 18), la Regla hereda la tinta del sistema y el Índice pasa a tinta: el estado sigue en la base.
- **Mediano**: tres noches de la casa o las tres últimas del usuario (configurable en el intent de edición del widget: "Noches a mostrar"), como tres Filas de 44 con nombre 15 Semibold, receta 12 Mono `texto2` y un Disco de 36 pt. La que suena lleva su Disco en *pause* y la receta sustituida por "Sonando · 48 min". Toque en una fila = esa noche suena (`PlayNightIntent(night:)`); toque en el Disco de la que suena = pausa. El widget no vende: una noche con capas Pro perdidas reproduce lo disponible y su receta lleva la versalita "Pro" donde toca.
- **Lock Screen rectangular** (`accessoryRectangular`): nombre 13, Cifra 22 Mono, Regla de 128 pt. **Circular** (`accessoryCircular`): el glifo de regla; con `widgetAccentable` para la aguja. **Inline** (`accessoryInline`): glifo + "SleepNoise · 48 min" / "Lista".
- **Actualización**: `TimelineReloadPolicy.after(fin)` y recarga en cada hito; cero animación; "Lista" cuando no suena, nunca un reloj en vivo (los widgets no son relojes).

### 12.3 Centro de control, botón de Acción (iOS 18+)

- **Toggle "Sonido para dormir"** (`ControlWidgetToggle` con `SetValueIntent`): símbolo propio *regla* en dos variantes: *off* = línea con tres dientes en gris; *on* = la misma con la aguja; el sistema tiñe el *on* con el tinte declarado (`índice`): es la única vez que el sistema pinta amarillo un control, y lo hace el sistema, no la app. Título "Sonido para dormir" / "Sleep sound"; subtítulo dinámico: la noche actual ("Lluvia fina") o "Lista". Tamaño pequeño y mediano del control.
- **Botón "Madrugada"** (`ControlWidgetButton` con `SmallHoursIntent`): el mismo glifo con la aguja en la izquierda (0 de 20); título "Madrugada" / "Small hours"; subtítulo "20 min". Puede ir a la pantalla de bloqueo (donde el sistema exige pulsación larga: exactamente lo que queremos a las 4).
- **Botón de Acción**: el usuario elige el control; la sugerencia en Ajustes de la app: "Asigna Madrugada al botón de Acción: a las 4 de la mañana no hace falta encender la pantalla." Texto de sugerencia del sistema: "Mantén para Madrugada" / "Hold for Small hours".
- En iOS 17 no existe el control; el Atajo lo cubre y se dice en Ajustes.

### 12.4 Apple Watch (app mínima, watchOS 10+)

Dos pantallas, con paginación vertical del sistema, SF Compact; la Cifra en SF Compact Medium 44 con `monospacedDigit()`.

- **Sesión** (maqueta 15, izquierda): Cifra "48 min" (o "Lista"), la Regla de tiempo de 169 pt con la aguja en el amarillo del Watch (`#F0C020` declarado como tinte de la app), el nombre de la noche 15 `texto2`. **Toque en cualquier parte** = play/pausa (`.start`/`.stop`). **Digital Crown** = nivel maestro: la Regla pasa a escala 0-100 durante el giro con detentes `.click` cada 5, la Cifra muestra el nivel "62" sin unidad, y 1,5 s después vuelve al tiempo. **Deslizar a la derecha** = +15 (`.click`); en Escudo, retrasa el fin 15 min. Always-On: Cifra a 1 Hz, Regla congelada, aguja en tinta.
- **Marea** (maqueta 15, derecha): versalita "Marea" y "6 /min" arriba; el Mareógrafo compacto respirando con el ancla sincronizada desde el iPhone (`WCSession` envía el ancla y el ritmo; el Watch calcula `BreathCurve` localmente: sin tráfico por ciclo); debajo, la fila de pulsos hápticos dibujada como marcas de 2 pt cuya altura es la intensidad de cada pulso (es la única "visualización" del háptico, y es honesta: muestra lo que la muñeca va a sentir); estado "inhala · se retira en 12 min". **Toque** = enciende/apaga la Marea. **Corona** = ritmo (detentes cada 0,5). Háptico `.directionUp` al inicio de cada inhalación (§11).
- **Complicación circular**: el glifo de regla con la aguja (tinte del sistema; `widgetAccentable`). **Smart Stack**: nombre + Cifra + Regla pequeña, relevancia alta entre la hora de Sueño y la alarma (`TimelineEntryRelevance`) y cuando la sesión suena.
- **Sin app de Watch autónoma de audio** (el Watch no genera; manda al iPhone): si el iPhone no está alcanzable, la Cifra dice "iPhone fuera de alcance" / "iPhone out of reach" en 15 y nada más.

### 12.5 Siri y Atajos (App Intents, iOS 17+)

Intents: `PlayNightIntent(night?)`, `PauseIntent`, `TogglePlaybackIntent`, `ExtendIntent(minutes)`, `SetLevelIntent(level)`, `StartTideIntent(pace?, minutes?)`, `StopTideIntent`, `SmallHoursIntent`, `SetTimerIntent(mode, value)`, `SaveNightIntent(name)`. Todos `AudioPlaybackIntent` donde haya audio (el sistema evita diálogo). Frases (`AppShortcutsProvider`), ES / EN:

| Acción | Frases ES | Frases EN |
|---|---|---|
| Reproducir la última noche | "Pon SleepNoise", "Que suene SleepNoise", "Empieza mi noche en SleepNoise" | "Play SleepNoise", "Start my night in SleepNoise" |
| Reproducir una noche concreta | "Pon Lluvia fina en SleepNoise", "SleepNoise, Mar lento" | "Play Light rain in SleepNoise", "SleepNoise, Slow sea" |
| Pausar | "Para SleepNoise", "Pausa SleepNoise" | "Pause SleepNoise", "Stop SleepNoise" |
| +15 | "Añade quince minutos en SleepNoise", "Quince minutos más de SleepNoise" | "Add fifteen minutes to SleepNoise", "Fifteen more minutes of SleepNoise" |
| Nivel | "Baja SleepNoise", "Sube SleepNoise", "SleepNoise al cuarenta" | "Turn SleepNoise down", "SleepNoise to forty" |
| Marea | "Empieza la Marea en SleepNoise", "Marea respiratoria" | "Start the tide in SleepNoise", "Breathing tide" |
| Madrugada | "Madrugada en SleepNoise", "SleepNoise, madrugada" | "Small hours in SleepNoise" |
| Temporizador | "SleepNoise hasta las siete", "Siesta de veinte en SleepNoise" | "SleepNoise until seven", "Twenty-minute nap in SleepNoise" |

Respuestas de Siri (cuando hay que hablar; de noche, casi nunca): "Sonando Lluvia fina, 45 minutos." / "Playing Light rain, 45 minutes." · "Quince minutos más: se funde a las 00:57." / "Fifteen more: fades at 00:57." · "Esa noche tiene Océano, que es Pro. Suena lo demás." / "That night has Ocean, which is Pro. Playing the rest." Sin exclamaciones, sin "¡Listo!".

Automatizaciones sugeridas (texto en Ajustes › Atajos, con enlace al Atajo prehecho): "Al activar el Focus Sueño → Pon Lluvia fina" y "A las 06:45 → Para SleepNoise" (para quien usa Escudo sin alarma). La app no las crea: las propone.

### 12.6 Focus de Sueño

- **Focus filter** (`SetFocusFilterIntent`, iOS 16+): un solo parámetro, "Cara de noche" (bool, por defecto sí). Con el Focus Sueño activo: la app abre en Noche si hay sesión sonando (ya lo hace al bloquear) y, si no la hay, en la principal **sin Tip ni línea de prueba** (nada que leer de noche); el nivel maestro máximo al arrancar desde Atajo/Watch se limita a 70 (nunca arranca a tope en Sueño); la hoja Pro no se abre aunque se toque algo Pro: la escucha de 30 s ocurre y la hoja **se pospone a la mañana** (línea de estado: "Anoche probaste Océano. Pro, 29,99 € una vez." con chevron). Vender dentro del Focus de Sueño es exactamente lo que el usuario odia.
- La app no detecta el nombre del Focus (no hay API); el filtro lo configura el usuario en Ajustes › Focus › Sueño › Filtros de apps. Se explica en Ajustes de la app con dos frases y un botón que abre Ajustes de iOS.
- Durante el Focus, iOS atenúa la pantalla de bloqueo; nuestra Live Activity ya es negra.

---

## 13. Accesibilidad

### 13.1 Orden de VoiceOver por pantalla

**Principal.** 1 Título (header: "Lluvia fina, noche actual, botón; toca dos veces para elegir otra noche"); 2 Línea de estado (static; con sesión: "Sonando, se funde a las 00:42; toca dos veces para la pantalla de noche"); 3 Banda (image + `AXChartDescriptor`: "Nivel del sonido, 62 por ciento; gráfico de audio disponible en el rotor"); 4-5 Capas (cada una `.adjustable`); 6 "y 2 más" (botón, si aplica); 7 Fila de la Marea (botón, con acción "Encender" / "Apagar"); 8 Nivel (`.adjustable`); 9 Barra: Temporizador, Mezclador, **Reproducir/Pausar**, Noches. La Barra se agrupa como `tabBar`-like container para saltar con el rotor. Sin elementos decorativos focalizables (hairlines, escala de la Banda: `accessibilityHidden`).

**Mezclador (hoja).** Título ("Capas"), subtítulo, grupo "Cama" (header) → Blanco, Rosa, Marrón; grupo "Texturas" → Lluvia, Ventilador, Océano…; pie. Cada capa: un `.adjustable` (nivel) y, dentro del mismo elemento, acciones personalizadas "Timbre: más cerca / igual / más lejano", "Ajustes técnicos", "Silenciar", "Máximo". El timbre se expone también como segundo `.adjustable` si el usuario activa "Controles separados" en el rotor de la app (opción de Ajustes).

**Marea (hoja).** Título con toggle ("Marea respiratoria, interruptor, activado"), Mareógrafo (`.adjustable`: ritmo; valor "6 por minuto, inhalando" actualizado solo al cambiar de fase y solo si "Voz de guía" está activa), frase, Regla de ritmo, nota + enlace "Qué sabemos", Regla de duración, nota, estado, háptica (segmentos), "Voz de guía" (toggle, solo VoiceOver).

**Temporizador (hoja).** Título; tres modos como botones con `.isSelected`; la Regla del modo elegido inmediatamente después de su fila; DatePicker del sistema en Escudo; "Sin temporizador"; pie.

**Noche.** Un solo elemento: botón de pantalla completa. Etiqueta: "Sonando, 48 minutos restantes, las doce y cuarenta y dos". Pista: "Toca dos veces para pausar". Acciones personalizadas (rotor): "Añadir 15 minutos", "Quitar 15 minutos", "Subir nivel", "Bajar nivel", "Volver a los controles", "Sin reloj / Con reloj". En pausa: "En pausa, 47 minutos restantes; toca dos veces para reanudar".

**Madrugada.** Un elemento: "Madrugada, respirando a 6 por minuto, 14 minutos; toca dos veces para parar". Acciones: "Diez minutos más", "Parar".

**Noches (hoja).** Título, subtítulo, lista (cada fila: "Lluvia fina, Lluvia 40, Marrón 20, 45 minutos, botón"; acciones: "Escuchar sin cerrar", "Renombrar", "Borrar"; la que suena: "…, sonando"), "Volver a poner las noches de la casa", "Ajustes".

**Pro (hoja).** Título, **precio** ("29,99 euros, pago único"), nota de lanzamiento, cuatro líneas, "Sigue siendo gratis…", botón "Comprar SleepNoise Pro, 29,99 euros, pago único", "Restaurar compra", "Compartir en familia incluido", pie. El precio es el segundo elemento: antes de cualquier botón, como en la pantalla.

**Live Activity / widgets.** Etiquetas del sistema más las nuestras: "SleepNoise, Lluvia fina, 48 minutos, sonando"; botones "Pausar", "Añadir 15 minutos", "Madrugada, 20 minutos".

### 13.2 Etiquetas, valores y pistas por control (ES / EN)

| Control | Etiqueta | Valor | Pista | Rasgos / acciones |
|---|---|---|---|---|
| Disco | "Reproducir" / "Play"; sonando: "Pausar" / "Pause" | — | "Empieza el sonido con un fundido de un segundo" / "Starts the sound with a one-second fade" | `.button`, `.startsMediaSession` |
| Regla de capa | "Lluvia" / "Rain" | "40 por ciento" / "40 percent"; Pro: "requiere Pro" / "needs Pro" | "Desliza arriba o abajo para ajustar en pasos de 5" / "Swipe up or down to adjust in steps of 5"; Pro: "Toca dos veces para escuchar 30 segundos" / "Double-tap to hear 30 seconds" | `.adjustable`; acciones "Silenciar"/"Mute", "Máximo"/"Max", "Timbre"/"Timbre", "Ajustes técnicos"/"Technical settings" |
| Lectura (pulsación larga) | "Nivel de salida" / "Output level" | "−18 decibelios a escala completa" / "−18 dB full scale" | — | `.staticText`, se anuncia al abrir |
| Regla maestra | "Nivel" / "Level" | "62 por ciento" | "Desliza para ajustar; no cambia el volumen de tu alarma" / "Swipe to adjust; does not change your alarm volume" | `.adjustable` |
| Banda | "Nivel del sonido" / "Sound level" | "62 por ciento, sonando" / "62 percent, playing"; reposo: "en silencio" / "silent" | "Gráfico de audio disponible" / "Audio graph available" | `.image`, `accessibilityChartDescriptor` (series por capa, últimos 6 s); acción "Ver por capas" / "Show by layer" |
| Fila de Marea | "Marea respiratoria" / "Breathing tide" | "apagada" / "off"; "guiando, 6 por minuto, se retira en 12 minutos" / "guiding, 6 per minute, fades in 12 minutes" | "Toca dos veces para abrir; acción para encender" / "Double-tap to open; action to turn on" | `.button`; acciones "Encender"/"Turn on", "Apagar"/"Turn off" |
| Mareógrafo | "Ritmo de la marea" / "Tide pace" | "6 por minuto" | "Desliza arriba o abajo para cambiar el ritmo en medios" / "Swipe up or down to change pace by halves" | `.adjustable`, `.updatesFrequently` solo con "Voz de guía" |
| Toggle de Marea | "Marea respiratoria" | "activado" / "on" | sistema | `.toggle` (sistema) |
| Regla de ritmo | "Ritmo" / "Pace" | "6 por minuto" | igual que el Mareógrafo | `.adjustable` |
| Regla de duración | "Guiar durante" / "Guide for" | "15 minutos" | "Desliza para cambiar en pasos de 5" | `.adjustable` |
| Modo de temporizador | "Hasta dormirme" / "Until I fall asleep" | "45 minutos, seleccionado" / "45 minutes, selected" | "Toca dos veces para elegir este modo" / "Double-tap to choose this mode" | `.button`, `.isSelected` |
| Regla de tiempo | "Duración" / "Duration" | "45 minutos"; tope gratuito: "60 minutos, tope; más requiere Pro" / "60 minutes, limit; more needs Pro" | "Desliza para cambiar; los valores con nombre son 15, 30, 45, 60 y 90" | `.adjustable` |
| DatePicker de Escudo | "Hasta las" / "Until" | "07:00" | sistema | sistema |
| "Sin temporizador" | "Sin temporizador" / "No timer" | — | "Suena hasta que lo pares" / "Plays until you stop it" | `.button` |
| Noche (vista entera) | "Sonando, 48 minutos restantes, las 00:42" / "Playing, 48 minutes left, 12:42 a.m." | — | "Toca dos veces para pausar" / "Double-tap to pause" | `.button`; acciones §13.1 |
| Madrugada | "Madrugada, respirando a 6 por minuto, 14 minutos" / "Small hours, breathing at 6 per minute, 14 minutes" | — | "Toca dos veces para parar" | `.button`; acciones "Diez minutos más"/"Ten more minutes" |
| Fila de noche guardada | "Lluvia fina" / "Light rain" | "Lluvia 40, Marrón 20, 45 minutos"; "sonando" / "playing" | "Toca dos veces para cargar" / "Double-tap to load" | `.button`; acciones "Escuchar sin cerrar"/"Preview without closing", "Renombrar"/"Rename", "Borrar"/"Delete" |
| Disco pequeño (Noches, widget) | "Escuchar Lluvia fina" / "Preview Light rain"; sonando: "Pausar" | — | — | `.button` |
| Botón Comprar | "Comprar SleepNoise Pro, 29,99 euros, pago único" / "Buy SleepNoise Pro, $29.99, one-time payment" | deshabilitado: "comprando" / "purchasing" | — | `.button` |
| Restaurar | "Restaurar compra" / "Restore purchase" | — | "Busca una compra anterior en tu cuenta de Apple" / "Looks for a previous purchase on your Apple account" | `.button` |
| Enlace "Qué sabemos" | "Qué sabemos y qué no" / "What we know and what we don't" | — | "Abre la lista de estudios" / "Opens the list of studies" | `.link` |
| Barra: Temporizador | "Temporizador" / "Timer" | "45 minutos, hasta dormirme" | — | `.button` |
| Barra: Mezclador | "Capas" / "Layers" | "2 sonando" / "2 playing" | — | `.button` |
| Barra: Noches | "Noches" / "Nights" | "Lluvia fina" | — | `.button` |
| Guardar (hoja) | campo "Nombre de la noche" / "Night name" | "Lluvia y marrón" | — | `.textField` (sistema) |
| Watch: sesión | "Lluvia fina, 48 minutos, sonando" | — | "Toca para pausar; gira la corona para el nivel; desliza a la derecha para 15 minutos más" | — |
| Watch: Marea | "Marea, 6 por minuto, se retira en 12 minutos" | — | "Toca para apagar; gira la corona para el ritmo" | — |

Versalitas de estado ("Pro", "Prueba · 5 noches", "Guiando") no son foco propio: forman parte del valor del elemento al que acompañan. Las hairlines y las escalas de marcas están ocultas a VoiceOver.

### 13.3 Dynamic Type hasta AX5: qué se reorganiza

| Tamaño | Principal | Mezclador | Marea | Temporizador | Noche | Pro / Prueba | Live Activity / widgets |
|---|---|---|---|---|---|---|---|
| xSmall-Large | Como §4.1, sin scroll | Filas de 88 | Hoja `.medium` | Hoja `.medium` | Cifra 72 | Como §4.8 | Como §12 |
| xLarge-xxxLarge | La Banda se mantiene a 56; las filas crecen (`@ScaledMetric`); la pantalla empieza a hacer scroll en xxLarge; la Barra queda fija; el Disco no crece (72) | Filas 96-112; nombre y subtítulo siguen en línea mientras quepan (`ViewThatFits`) | La hoja pasa a `.large` automáticamente cuando el contenido no cabe (`presentationDetents` con `.height` medido) | Igual | Cifra escala con `.largeTitle` hasta 96 | El botón primario crece en altura (50 → 60); la Cifra del precio escala | El sistema recorta: la Cifra lleva `minimumScaleFactor(0.7)`; el nombre, dos líneas |
| AX1-AX2 | Las filas de capa se apilan: nombre / lectura / Regla (fila de 108); "y 2 más" aparece ya con una sola capa visible; la fila de la Marea pasa a dos líneas; la línea de estado a dos líneas; los glifos de la Barra crecen a 28 pt (tope) y la Barra a 110 | Nombre arriba, subtítulo debajo, lectura a la derecha del nombre, Regla debajo (fila de 132); los grupos "Cama"/"Texturas" se mantienen | Todo apilado; el Mareógrafo conserva 353 × 72; la frase larga puede ocupar 5 líneas: la hoja hace scroll | Las filas de modo pasan a dos líneas (nombre / valor); la Regla desplegada debajo | Cifra con tope en AX2 = **112 pt** (`dynamicTypeSize(...accessibility2)` para la Cifra únicamente; la unidad y la hora siguen escalando hasta AX5 pero en una segunda línea) | Las cuatro líneas pasan a 3-4 líneas cada una; el botón mantiene 17 Semibold escalado (hasta 28); la hoja hace scroll con el botón **al final del contenido**, no fijo (un botón fijo taparía el precio en AX) | Sistema |
| AX3-AX5 | La Banda se mantiene (es gráfico, no texto); una sola capa visible + "y N más"; la fila de la Marea es solo la versalita y el estado; la Regla maestra conserva 353 de ancho y crece en alto (pulgar 32 × 56); la línea de estado se recorta a lo esencial ("Se funde a las 00:42"; la versalita de prueba pasa a la siguiente línea); Barra: solo glifos, sin cambios; el título puede ocupar dos líneas (`lineLimit(2)`), nunca tres (`minimumScaleFactor(0.8)`) | Una capa por pantalla de alto en AX5: aceptable (se desplaza); el subtítulo se oculta en AX4-AX5 (está en la pista de VoiceOver y bajo pulsación larga) | La Regla de ritmo y la de duración conservan ancho y marcas; sus lecturas pasan debajo de la etiqueta | Igual; "Sin temporizador" puede ocupar dos líneas | La hora "00:42" baja a una línea propia bajo la Cifra; la Regla de la noche no cambia (no es texto) | El precio como Cifra se mantiene a tope AX2 (112) para que quepa "29,99 €" en una línea; "una vez" debajo | Sistema; el widget pequeño muestra solo la Cifra ("48 min") si el nombre no cabe en dos líneas |

Comprobación: previews en Large, xxxLarge, AX3 y AX5 de las siete pantallas en ES (30 % más largo) y EN; nada truncado con "…" salvo nombres de noche escritos por el usuario (que se truncan en el medio, `truncationMode(.middle)`, y se leen completos en VoiceOver). Bold Text: automático (familias del sistema). Button Shapes: los botones de texto (Restaurar, "Qué sabemos", "Ahora no", "Sin temporizador") muestran subrayado del sistema con el ajuste activo.

### 13.4 Alternativa sin gestos para cada gesto

Principio: **cada gesto tiene (a) una acción de VoiceOver, (b) un control visible al alcance cuando Switch Control, AssistiveTouch, Full Keyboard Access o el ajuste de la app "Controles visibles" están activos, y (c) un Atajo.** Ninguna función existe solo detrás de un gesto.

| Gesto | Dónde | Alternativa visible / sin gesto | VoiceOver | Atajo / otra superficie |
|---|---|---|---|---|
| Arrastrar una Regla | Principal, Mezclador, hojas | La Regla es un `Slider` del sistema: con Full Keyboard Access, flechas ±5; con Switch Control, el escaneo ofrece "Incrementar/Decrementar"; además, tocar la **lectura** abre un `Stepper` inline del sistema (−/+ de 44 pt) durante 4 s | `.adjustable` | "SleepNoise, lluvia al cuarenta" |
| Pulsación larga en la lectura (dBFS) | Reglas | Fila "Mostrar niveles en dB" en Ajustes (persistente) | Acción "Nivel de salida" | — |
| Pulsación larga en el nombre (fila técnica) | Mezclador | Fila final de la hoja: "Ajustes técnicos" (toggle que despliega las filas técnicas de todas las capas) | Acción "Ajustes técnicos" | — |
| Deslizar sobre el subtítulo (timbre) | Mezclador | Tocar el subtítulo abre un segmento del sistema de tres posiciones ("más cerca · igual · más lejano") inline | Acción "Timbre" (`.adjustable` secundario opcional) | — |
| Pulsación larga en la Banda (por capas) | Principal | Fila "Banda por capas" en Ajustes; o tocar la Banda (toque simple) alterna durante 10 s | Acción "Ver por capas" | — |
| Pulsación larga en la fila de Marea (encender sin hoja) | Principal | El toggle dentro de la hoja (un toque más) | Acción "Encender/Apagar" | "Empieza la Marea" |
| Arrastrar la punta del Mareógrafo (ritmo) | Marea | La Regla de ritmo, justo debajo, hace lo mismo | `.adjustable` | "Marea a seis" |
| Deslizar hacia abajo → Noche | Principal | **Tocar la línea de estado** mientras suena (un toque) | Acción "Pantalla de noche" en la línea de estado y en el Disco | "SleepNoise, noche"; automático al bloquear |
| Noche: toque = pausa | Noche | Con "Controles visibles de noche" (Ajustes de la app; **se activa solo** si `isSwitchControlRunning`, `isAssistiveTouchRunning` o Full Keyboard Access están activos): una fila de tres botones de 64 pt en `texto3` al pie: "−15" · pausa/play · "+15", con etiquetas en versalitas 13 debajo | Botón de pantalla completa | Live Activity (Disco), Watch (toque), "Para SleepNoise" |
| Noche: arrastre horizontal ±15 | Noche | Los botones "−15" / "+15" de la misma fila | Acciones "Añadir/Quitar 15 minutos" | Live Activity "+15", Watch (deslizar), "quince minutos más" |
| Noche: arrastre vertical = nivel | Noche | Pulsación larga en la Cifra (hoja Noche) incluye una Regla de nivel; con "Controles visibles", la fila añade una Regla de nivel de 353 pt encima de los tres botones | Acciones "Subir/Bajar nivel" | Watch (corona), "baja SleepNoise", botones de volumen del iPhone (volumen del sistema, que también actúa) |
| Noche: arrastre largo hacia arriba = volver | Noche | Con "Controles visibles": un cuarto botón textual "Controles" en 15 `texto2` encima de la fila; sin él, bloquear y desbloquear vuelve a Noche (no a la principal), así que la vuelta también es: cerrar y abrir la app desde el icono, que **sí** abre la principal si se hace desde el icono con la sesión sonando y la pantalla desbloqueada (regla: icono = principal; bloqueo = Noche) | Acción "Volver a los controles" | — |
| Noche: pulsación larga en la Cifra (hoja Noche) | Noche | Las mismas opciones ("Sin reloj", "Brillo mínimo al entrar", "Controles visibles") están en Ajustes › Noche | Acción "Opciones de noche" | — |
| Madrugada: toque = parar; arrastre = +10 | Madrugada | Con "Controles visibles": dos botones de 64 pt: "+10" y "Parar" | Acciones | Watch, Live Activity opcional de Madrugada, "Para SleepNoise" |
| Deslizar en fila de noche (Renombrar/Borrar) | Noches | Botón "Editar" del sistema en la hoja (modo edición con los controles estándar) | Acciones | — |
| Reordenar noches | Noches | Modo edición del sistema | Acciones "Mover arriba/abajo" (sistema) | — |
| Mantener el botón de Acción | Sistema | El control de Centro de control, el Atajo, el widget | — | "Madrugada en SleepNoise" |
| Watch: corona, deslizar | Watch | Pantalla "Más" con botones "+15", "−5 nivel", "+5 nivel" (tercera página, solo si Acceso asistido o VoiceOver del Watch están activos) | VoiceOver del Watch: acciones | iPhone |

Acceso guiado y Acceso asistido (iOS 17): Noche y Madrugada se registran con una disposición de un solo botón (pantalla completa = pausa/reanuda) y los botones visibles de la tabla; es la configuración recomendada para quien vive con alguien que necesita una interfaz de un solo control.

Otros ajustes respetados: Reduce Transparency (no hay materiales propios; la barra del sistema pasa a opaca sola); Increase Contrast (variantes del asset catalog, §2.1); Differentiate Without Color (ya es la regla: todo estado tiene forma o palabra); Smart Invert (`accessibilityIgnoresInvertColors` en la Banda, el Mareógrafo y los glifos de pendiente; el negro invertido se respeta); Reduce White Point (nada que hacer: ya no hay blanco puro); Prefer Cross-Fade Transitions (las de navegación son del sistema).

---

## 14. Textos de interfaz definitivos (ES / EN)

Voz: corta, concreta, serena; segunda persona sin exclamaciones; sin diminutivos; sin emojis; "temporizador", "mezcla/noche", "de por vida", nunca "timer", "mix", "vitalicio"; nada de la lista negra (§7.2 del brief): ni "mejora", ni "insomnio", ni "ansiedad", ni "terapia", ni "IA". Los nombres de las noches de la casa describen, no prometen. La columna ES vale para es-ES y es-419: se ha evitado el léxico que diverge ("coger", "ordenador", "móvil"), y "madrugada", "siesta", "escudo" y "noche" son comunes a ambas; si una ficha regional lo exige, solo cambia el formato de precio.

### 14.1 Principal

| Elemento | ES | EN |
|---|---|---|
| Título (noche) | Lluvia fina · Ventilador lejano · Mar lento · Cama rosa | Light rain · Distant fan · Slow sea · Pink bed |
| Título editado | Lluvia fina · editada | Light rain · edited |
| Título con capas perdidas | Mar lento · sin Océano / Mar lento · sin Océano ni Marea / Mar lento · nada suena ahora | Slow sea · without Ocean / Slow sea · without Ocean or Tide / Slow sea · nothing plays now |
| Estado, reposo con temporizador | 45 min hasta dormirme | 45 min until I fall asleep |
| Estado, reposo sin temporizador | Suena hasta que lo pares | Plays until you stop it |
| Estado, reposo Siesta | Siesta · 20 min | Nap · 20 min |
| Estado, reposo Escudo | Escudo nocturno · hasta las 07:00 | Night shield · until 07:00 |
| Estado, sonando | Se funde a las 00:42 | Fades out at 00:42 |
| Estado, sonando + Marea | Se funde a las 00:42 · <sc>Guiando</sc> 6 /min | Fades out at 00:42 · <sc>Guiding</sc> 6 /min |
| Estado, fundiendo | <sc>Fundiendo</sc> · 00:42 | <sc>Fading</sc> · 00:42 |
| Estado, en pausa | En pausa · llamada / · alarma / · tus AirPods / · auriculares desconectados / En pausa | Paused · call / · alarm / · your AirPods / · headphones disconnected / Paused |
| Estado, terminó durante una interrupción | Terminó a las 00:42 durante la llamada | Ended at 00:42 during the call |
| Estado, prueba (prefijo) | <sc>Prueba · 5 noches</sc> · | <sc>Trial · 5 nights</sc> · |
| Estado, última noche | <sc>Prueba · última noche</sc> · | <sc>Trial · last night</sc> · |
| Línea bajo capas, noches 6-7 | Después siguen gratis blanco, rosa, marrón, lluvia, siesta y 60 minutos. Tus noches se conservan. | Afterwards white, pink, brown, rain, nap and 60 minutes stay free. Your nights stay. |
| Estado, prueba terminada (una vez) | <sc>Prueba terminada</sc> · 45 min hasta dormirme | <sc>Trial over</sc> · 45 min until I fall asleep |
| Nota, noche con capas Pro perdidas | Océano y la Marea son Pro. Toca la línea para oírlos 30 segundos. | Ocean and the Tide are Pro. Tap the line to hear them for 30 seconds. |
| Estado, noche toda Pro | Esta noche era toda Océano. Tócalo para oírlo 30 segundos. | This night was all Ocean. Tap it to hear it for 30 seconds. |
| Estado, tras comprar (una vez) | Gracias. Pro, para siempre. | Thank you. Pro, for good. |
| Estado, tras restaurar | Restaurado. Pro, para siempre. | Restored. Pro, for good. |
| Estado, mañana tras Madrugada prolongada | Anoche Madrugada siguió hasta las 07:00. | Last night Small hours ran until 07:00. |
| Estado, mañana tras escucha Pro en Focus Sueño | Anoche probaste Océano. Pro, 29,99 € una vez. | Last night you tried Ocean. Pro, $29.99 once. |
| Estado, mañana tras error | Anoche el sonido se detuvo a las 02:14 por un error. Nos gustaría saberlo: Enviar informe | Last night the sound stopped at 02:14 due to an error. We'd like to know: Send report |
| Estado, nivel bajado por altavoz | Nivel bajado al 40 para el altavoz | Level lowered to 40 for the speaker |
| Capas | Blanco · Rosa · Marrón · Lluvia · Ventilador · Océano · Trueno · Hoguera · Arroyo · Viento · Cabina | White · Pink · Brown · Rain · Fan · Ocean · Thunder · Fire · Brook · Wind · Cabin |
| "y N más" | y 2 más | and 2 more |
| Fila Marea apagada | <sc>Marea respiratoria</sc> apagada | <sc>Breathing tide</sc> off |
| Fila Marea activa | <sc>Marea</sc> se retira en 12 min | <sc>Tide</sc> fades in 12 min |
| Fila Marea disolviéndose | <sc>Marea</sc> disolviéndose · 3 min | <sc>Tide</sc> dissolving · 3 min |
| Fila Marea tras retirarse | <sc>Marea respiratoria</sc> se retiró | <sc>Breathing tide</sc> drew back |
| Fila Marea, Pro tras prueba | <sc>Marea respiratoria</sc> <sc>Pro</sc> | <sc>Breathing tide</sc> <sc>Pro</sc> |
| Regla maestra | <sc>Nivel</sc> | <sc>Level</sc> |
| Banda, escala | −6 s · ahora | −6 s · now |
| Barra (etiquetas de accesibilidad) | Temporizador · Capas · Reproducir / Pausar · Noches | Timer · Layers · Play / Pause · Nights |
| Tip (una vez) | Toca el disco. Arrastra las reglas. Nada más que aprender. | Tap the disc. Drag the rulers. Nothing else to learn. |
| Error de audio | No se pudo arrancar el sonido. Toca el disco para reintentar. | Couldn't start the sound. Tap the disc to try again. |
| Error, segundo | Si sigue sin sonar, cierra la app y vuelve a abrirla. | If it still won't play, close the app and open it again. |
| Error, tercero | Enviar informe | Send report |

### 14.2 Mezclador

| Elemento | ES | EN |
|---|---|---|
| Título | Capas | Layers |
| Subtítulo | Se oyen cambiar bajo el dedo. | You hear them change under your finger. |
| Grupos | <sc>Cama</sc> · <sc>Texturas</sc> | <sc>Bed</sc> · <sc>Textures</sc> |
| Subtítulos de capa | siseo parejo · suave y equilibrado · retumbo grave · lluvia fina · ventilador lejano · mar lento · tormenta lejana · fuego bajo · agua que corre · viento en la ventana · cabina en vuelo | even hiss · soft and even · low rumble · light rain · distant fan · slow sea · distant storm · low fire · running water · wind at the window · cabin in flight |
| Timbre (texturas) | más cerca · igual · más lejano | closer · as is · farther |
| Timbre (cama) | más cálido · igual · más brillante | warmer · as is · brighter |
| Fila técnica | Corte de graves · 80 Hz · Pendiente · −6 dB/oct | Low cut · 80 Hz · Slope · −6 dB/oct |
| Pro | <sc>Pro</sc> | <sc>Pro</sc> |
| Escucha de 30 s (lectura durante) | 0:22 | 0:22 |
| Error de escucha | No se pudo escuchar. Inténtalo de nuevo. | Couldn't preview. Try again. |
| Pie | Lo que está a cero no suena ni gasta. | What's at zero makes no sound and costs nothing. |
| Fila final | Ajustes técnicos | Technical settings |

### 14.3 Marea respiratoria

| Elemento | ES | EN |
|---|---|---|
| Título | Marea respiratoria | Breathing tide |
| Frase | Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla. | Breathe in as the wave rises, out as it draws back. No need to watch the screen. |
| Escala del Mareógrafo | bajamar · pleamar | low tide · high tide |
| Ritmo | <sc>Ritmo</sc> · 6 /min | <sc>Pace</sc> · 6 /min |
| Nota de ritmo | 6 por minuto es el ritmo de los estudios de respiración lenta. Si te falta el aire, sube el ritmo. Qué sabemos | 6 per minute is the pace used in slow-breathing studies. If you run short of breath, raise the pace. What we know |
| Duración | <sc>Guiar durante</sc> · 15 min | <sc>Guide for</sc> · 15 min |
| Nota de duración | Después el oleaje sigue solo, sin guía. | Afterwards the sea keeps going on its own, unguided. |
| Estados | <sc>Guiando</sc> · 6 por minuto · se retira en 12 min / <sc>Disolviéndose</sc> · 3 min / <sc>Apagada</sc> / <sc>Se retiró</sc> | <sc>Guiding</sc> · 6 per minute · fades in 12 min / <sc>Dissolving</sc> · 3 min / <sc>Off</sc> / <sc>Drew back</sc> |
| Fila técnica | Inhalar 4 s · Exhalar 6 s | Breathe in 4 s · Breathe out 6 s |
| Salud (si autorizado) | Tu ritmo nocturno medio, según Salud: 13 /min · Empezar desde ahí | Your average night pace, from Health: 13 /min · Start from there |
| Salud (no autorizado) | Empezar desde tu ritmo nocturno (lee la frecuencia respiratoria de Salud; nada se escribe) · Permitir | Start from your night pace (reads respiratory rate from Health; nothing is written) · Allow |
| Purpose string de Salud (lectura) | SleepNoise lee tu frecuencia respiratoria nocturna para empezar la Marea a tu ritmo y bajar desde ahí. No guarda ni envía nada. | SleepNoise reads your night respiratory rate to start the tide at your pace and slow down from there. Nothing is stored or sent. |
| Registrar en Salud | Registrar la Marea como minutos de atención plena en Salud | Log the tide as mindful minutes in Health |
| Purpose string de Salud (escritura) | SleepNoise puede registrar cada Marea como una sesión de atención plena en Salud. | SleepNoise can log each tide as a mindfulness session in Health. |
| Háptica | <sc>Háptica</sc> · Ninguna · Mínima · Marcada | <sc>Haptics</sc> · None · Minimal · Marked |
| Háptica en el Watch | Pulso en el Watch al inhalar | Pulse on your watch when breathing in |
| Nota háptica | Solo con el iPhone en la mano. En la mesilla, vibrar es ruido. | Only while you hold the iPhone. On the nightstand, a buzz is noise. |
| Voz de guía (VoiceOver) | Voz de guía: "Inhala" y "Exhala" | Voice guide: "Breathe in" and "Breathe out" |
| Pro tras prueba | <sc>Pro</sc> (junto al título); tras 30 s, hoja Pro | <sc>Pro</sc> |

### 14.4 Temporizador

| Elemento | ES | EN |
|---|---|---|
| Título | ¿Cuándo se apaga? | When does it stop? |
| Modo 1 | Hasta dormirme · 45 min | Until I fall asleep · 45 min |
| Nota 1 | El sonido baja durante los últimos 10 minutos. Tu alarma no se toca. | The sound fades over the last 10 minutes. Your alarm is untouched. |
| Marcas Pro | <sc>Pro</sc> bajo 75 y 90 | <sc>Pro</sc> under 75 and 90 |
| Modo 2 | Escudo nocturno · hasta las 07:00 · <sc>Pro</sc> | Night shield · until 07:00 · <sc>Pro</sc> |
| Campo 2 | Hasta las | Until |
| Regla 2 | <sc>Bajar el nivel durante la noche</sc> · −20 % | <sc>Lower the level through the night</sc> · −20 % |
| Nota 2 | Toda la noche. A las 07:00 se funde en 10 minutos. Tu alarma suena a su propio volumen. | All night. At 07:00 it fades over 10 minutes. Your alarm plays at its own volume. |
| Modo 3 | Siesta · 20 min | Nap · 20 min |
| Nota 3 | Se funde en los últimos 2 minutos. | Fades over the last 2 minutes. |
| Fila final | Sin temporizador | No timer |
| Pie | El fundido es espectral: primero se van los agudos, luego los graves. El nivel de la app no toca el volumen de tu alarma. | The fade is spectral: highs go first, then lows. The app's level doesn't touch your alarm volume. |
| Pie alternativo (si el motor no es espectral) | El sonido se desvanece antes de que termine el temporizador. | The sound fades before the timer ends. |

### 14.5 Noche, Madrugada y hoja Noche

| Elemento | ES | EN |
|---|---|---|
| Cifra | 48 <sc>min</sc> · 00:42 · 62 (nivel) · hasta las 07:00 (Escudo) | 48 <sc>min</sc> · 12:42 · 62 · until 07:00 |
| Tip de Noche (una vez, 4 s) | Un toque pausa. Desliza para añadir 15 minutos. | One tap pauses. Swipe to add 15 minutes. |
| Fin de sesión (10 s) | 00:42 (hora, en gris) | 12:42 |
| Hoja Noche: título | Noche | Night |
| Hoja Noche: filas | Sin reloj · Brillo mínimo al entrar (recordatorio, no ajuste) · Controles visibles de noche | No clock · Lowest brightness when entering (a reminder, not a setting) · Visible controls at night |
| Hoja Noche: nota | La pantalla puede dormirse. El sonido sigue. | The screen can sleep. Sound keeps playing. |
| Controles visibles | −15 · (pausa) · +15 · Controles | −15 · (pause) · +15 · Controls |
| Madrugada: nombre | Madrugada | Small hours |
| Madrugada: botón de la Live Activity / control | Madrugada · 20 min | Small hours · 20 min |
| Madrugada: controles visibles | +10 · Parar | +10 · Stop |
| Madrugada: sugerencia del botón de Acción | Mantén para Madrugada | Hold for Small hours |
| Madrugada: Ajustes | Mostrar Madrugada en la pantalla de bloqueo (apagado: menos luz en la mesilla) | Show Small hours on the Lock Screen (off: less light on the nightstand) |

### 14.6 Noches (guardadas) y Guardar

| Elemento | ES | EN |
|---|---|---|
| Título / subtítulo | Noches · Tal como las dejaste. | Nights · Just as you left them. |
| Receta | Lluvia 40 · Marrón 20 · 45 min | Rain 40 · Brown 20 · 45 min |
| Receta con capas Pro | Océano 55 <sc>Pro</sc> · Marrón 15 · Marea <sc>Pro</sc> | Ocean 55 <sc>Pro</sc> · Brown 15 · Tide <sc>Pro</sc> |
| Sonando | <sc>Sonando</sc> | <sc>Playing</sc> |
| Acciones | Renombrar · Borrar · Escuchar | Rename · Delete · Preview |
| Confirmación de borrado (sistema) | ¿Borrar "La de viajar"? · Borrar · Cancelar | Delete "Travel one"? · Delete · Cancel |
| Noches de la casa | Lluvia fina · Ventilador lejano · Mar lento · Cama rosa | Light rain · Distant fan · Slow sea · Pink bed |
| Restaurar casa | Volver a poner las noches de la casa | Bring back the house nights |
| Vacío | Ninguna noche guardada. Toca Guardar en la barra cuando una te guste. | No saved nights. Tap Save in the bar when you like one. |
| Guardar: título | Guardar esta noche | Save this night |
| Guardar: campo (precargado) | Lluvia y marrón | Rain and brown |
| Guardar: botón | Guardar noche | Save night |
| Guardar: segunda noche gratuita (después de guardar) | Guardada. La tercera y siguientes son Pro. · Ver Pro · Ahora no | Saved. The third and beyond are Pro. · See Pro · Not now |
| Fila Ajustes | Ajustes | Settings |

### 14.7 Pro y prueba

| Elemento | ES | EN |
|---|---|---|
| Título | SleepNoise Pro | SleepNoise Pro |
| Precio | 29,99 € <sc>una vez</sc> | $29.99 <sc>once</sc> |
| Lanzamiento | Precio de lanzamiento hasta el 14 de diciembre. Después, 34,99 €. | Launch price until December 14. Then $34.99. |
| Líneas | Todas las texturas, ahora y las que vengan. · Marea respiratoria. · Temporizador de toda la noche y Escudo nocturno. · Noches guardadas sin límite. | Every texture, now and to come. · Breathing tide. · All-night timer and Night shield. · Unlimited saved nights. |
| Gratis | Sigue siendo gratis para siempre: blanco, rosa, marrón, lluvia, siesta y 60 minutos. Tus noches guardadas se conservan. | Free forever: white, pink, brown, rain, nap and 60 minutes. Your saved nights stay. |
| Botón | Comprar · 29,99 € | Buy · $29.99 |
| Botón, en curso | Comprando… | Purchasing… |
| Botón, ya es tuyo | Ya es tuyo | Already yours |
| Terciario | Restaurar compra · Compartir en familia incluido | Restore purchase · Family Sharing included |
| Pie | Un solo pago. Sin suscripción, sin cuenta, sin red. Nada sale de tu iPhone. | One payment. No subscription, no account, no network. Nothing leaves your iPhone. |
| Error | No se pudo completar. No se ha cobrado nada. | Couldn't complete. Nothing was charged. |
| Pendiente | Pendiente de aprobación familiar. Mientras tanto, todo sigue como estaba. | Waiting for family approval. Until then, everything stays as it was. |
| Restaurar: no hay | No hay compra en esta cuenta de Apple. Si la hiciste con otra, inicia sesión con ella en Ajustes de iOS. | No purchase on this Apple account. If you bought with another, sign in with it in iOS Settings. |
| Restaurar: error | No se pudo comprobar. Inténtalo con conexión. | Couldn't check. Try again with a connection. |
| Prueba: título | 7 noches con todo. Sin tarjeta. | 7 nights with everything. No card. |
| Prueba: cuerpo | Hoy empieza una prueba de 7 noches con todas las texturas, la Marea y el temporizador largo. No pedimos tarjeta ni cuenta: la prueba vive en este iPhone. | A 7-night trial starts today with every texture, the tide and the long timer. We don't ask for a card or an account: the trial lives on this iPhone. |
| Prueba: después | Cuando termine, siguen gratis blanco, rosa, marrón, lluvia, siesta y 60 minutos, y tus noches guardadas se conservan. Pro cuesta 29,99 € una vez. | When it ends, white, pink, brown, rain, nap and 60 minutes stay free and your saved nights stay. Pro is $29.99 once. |
| Prueba: botones | Empezar las 7 noches · Ahora no | Start the 7 nights · Not now |
| Ajustes: fila Pro | SleepNoise Pro · desde el 16 de noviembre de 2026 / SleepNoise Pro · 29,99 € una vez | SleepNoise Pro · since November 16, 2026 / SleepNoise Pro · $29.99 once |

### 14.8 "Qué sabemos y qué no"

Título: "Qué sabemos y qué no" / "What we know and what we don't". Entradas: las seis de §4.9, literales. Pie: "Si un estudio nuevo cambia algo de esta lista, cambiaremos la app, no la lista." / "If a new study changes anything on this list, we'll change the app, not the list."

### 14.9 Ajustes

| Elemento | ES | EN |
|---|---|---|
| Título | Ajustes | Settings |
| Grupo Noche | Noche: Sin reloj · Controles visibles de noche · Mostrar Madrugada en la pantalla de bloqueo | Night: No clock · Visible controls at night · Show Small hours on the Lock Screen |
| Grupo Sonido | Convivir con otras apps (baja el nivel cuando otra app suena) · Mostrar niveles en dB · Banda por capas | Play alongside other apps (lowers the level when another app plays) · Show levels in dB · Band by layer |
| Grupo Ecosistema | Atajos y Siri · Botón de Acción: Madrugada · Focus de Sueño: cara de noche (se configura en Ajustes de iOS › Focus › Sueño) · Watch: pulso de Marea | Shortcuts and Siri · Action button: Small hours · Sleep Focus: night face (set in iOS Settings › Focus › Sleep) · Watch: tide pulse |
| Grupo Accesibilidad | Controles separados en VoiceOver (nivel y timbre por separado) | Separate controls in VoiceOver (level and timbre apart) |
| Grupo Honestidad | Qué sabemos y qué no · Lo que sale de tu iPhone: nada · Enviar informe de un problema | What we know and what we don't · What leaves your iPhone: nothing · Report a problem |
| Pie | SleepNoise 2.0 · 3,1 MB · Hecho sin servidores. | SleepNoise 2.0 · 3.1 MB · Made without servers. |

### 14.10 Live Activity, widgets, Centro de control, Watch

| Elemento | ES | EN |
|---|---|---|
| LA: Cifra | 48 <sc>min</sc> · en pausa · hasta las 07:00 | 48 <sc>min</sc> · paused · until 07:00 |
| LA: causa de pausa | tus AirPods · llamada · auriculares desconectados | your AirPods · call · headphones disconnected |
| LA: botones | +15 · Madrugada · 20 min | +15 · Small hours · 20 min |
| LA: Marea | Marea · 6 /min · 9 min | Tide · 6 /min · 9 min |
| LA: estado expandida | Sonando · se funde a las 00:42 | Playing · fades out at 00:42 |
| LA: error final | Se detuvo a las 02:14 | Stopped at 02:14 |
| LA: Escudo > 8 h | Sigue sonando hasta las 07:00 | Still playing until 07:00 |
| Widget pequeño reposo | Lista | Ready |
| Widget mediano fila sonando | Sonando · 48 min | Playing · 48 min |
| Widget: configuración | Noches a mostrar | Nights to show |
| Inline | SleepNoise · 48 min / SleepNoise · Lista | SleepNoise · 48 min / SleepNoise · Ready |
| CC: toggle | Sonido para dormir · Lluvia fina / Lista | Sleep sound · Light rain / Ready |
| CC: botón | Madrugada · 20 min | Small hours · 20 min |
| Watch: sesión | 48 <sc>min</sc> · Lluvia fina · Lista | 48 <sc>min</sc> · Light rain · Ready |
| Watch: Marea | <sc>Marea</sc> · 6 /min · inhala · se retira en 12 min | <sc>Tide</sc> · 6 /min · breathe in · fades in 12 min |
| Watch: sin iPhone | iPhone fuera de alcance | iPhone out of reach |
| Watch: Más | +15 · −5 nivel · +5 nivel | +15 · −5 level · +5 level |

### 14.11 Permisos y textos del sistema

Solo dos permisos existen y ninguno se pide antes de que el usuario toque la función: Salud (lectura de frecuencia respiratoria; escritura de atención plena), §14.3. No hay notificaciones (no se pide el permiso nunca), no hay micrófono en esta versión, no hay seguimiento. `NSHealthShareUsageDescription` y `NSHealthUpdateUsageDescription` son las purpose strings de §14.3. Texto de la hoja de "Enviar informe" (correo del sistema): asunto "SleepNoise · informe" / "SleepNoise · report"; cuerpo: "Adjunto el registro del motor de sonido de anoche. No contiene datos personales." / "Attached is last night's sound engine log. It contains no personal data."

---

## 15. Onboarding de una noche

No hay onboarding: hay **una noche** en la que todo se aprende al usarlo. Presupuesto de enseñanza: **dos líneas de TipKit en toda la vida de la app** (una en la principal, otra en Noche), ningún carrusel, ningún permiso, ninguna cuenta, ningún precio hasta tocar algo Pro, ninguna valoración jamás solicitada.

| Momento | Qué ve | Qué aprende | Qué no pasa |
|---|---|---|---|
| **0 s · Abre** | La principal en reposo con "Lluvia fina" cargada y el Tip bajo el Disco: "Toca el disco. Arrastra las reglas. Nada más que aprender." | Que hay un botón y hay reglas | Bienvenida, registro, permisos, precio, nombre de la app |
| **1 s · Toca el Disco** | Suena en 800 ms; el Índice pasa a la Banda; el Tip se cierra para siempre | Que el sonido se fabrica ahora (la Banda avanza) | Nada más aparece |
| **~10 s · Arrastra una Regla** (lo hace solo: es lo único que se mueve bajo el dedo) | Lectura a 20 pt, pulgar amarillo, detentes | Que todo valor se lee y se oye cambiar | Sin tooltip de "¡Bien!" |
| **~1 min · Mira la Barra** | Cuatro glifos | Nada todavía: los glifos se explican al tocarlos (la hoja abre con su pregunta como título) | — |
| **Opcional · Toca Temporizador** | "¿Cuándo se apaga?", tres modos, la Regla desplegada | Que el temporizador es una pregunta con tres respuestas | — |
| **Opcional · Toca algo Pro** (Océano, Marea, 90 min) | Lo tocado actúa; después, la hoja de prueba "7 noches con todo. Sin tarjeta." | Qué es la prueba, qué cuesta Pro, qué sigue gratis: todo en una hoja, una vez | Cuenta atrás, tarjeta, cuenta |
| **~5 min · Bloquea** | Nada (la pantalla se apaga). Si mira: la Live Activity | Que no hace falta mirar | Notificación, vibración |
| **Primera vez que entra en Noche** (por gesto, por la línea de estado o al desbloquear con sesión) | Negro, Cifra, Regla; un Tip de 4 s: "Un toque pausa. Desliza para añadir 15 minutos." | Los dos gestos de la noche | Nada más, nunca más |
| **Mañana** | La principal en reposo, "Lluvia fina · editada" | Que la app recuerda | Resumen, puntuación, "¿qué tal dormiste?", petición de valoración |
| **Noche 2** | Igual, sin Tips | — | — |
| **Noche 6-7 (si hay prueba)** | La versalita "última noche" y una línea de lo que sigue gratis | Que la prueba termina, sin dramatismo | Hojas, notificaciones, descuentos |
| **Noche 8** | "Prueba terminada" una vez; lo gratis sigue igual | Que nada se ha roto | Candados, cápsulas, recordatorios |

Lo que el sistema hace por nosotros y no duplicamos: la hoja de compra de Apple, el permiso de Salud, la configuración de Atajos, la del botón de Acción y la del Focus. Cada una se explica en Ajustes con dos frases y un botón que lleva al sitio del sistema, nunca antes de que el usuario la busque.

Criterio de aceptación de la primera noche (lente 1 del jurado): cinco personas ajenas, dormitorio a oscuras, brillo al mínimo, sin instrucciones: todas deben haber arrancado el sonido en < 5 s, haber cambiado el nivel en < 20 s, haber pausado a oscuras con un toque y haber añadido 15 minutos con un gesto en la primera prueba; ninguna debe haber visto un precio sin haber tocado algo Pro.

---

## 16. Marcos añadidos a la maqueta

`scratchpad/design/concepts/dial.html` pasa de 12 a 17 marcos; los 12 primeros no cambian (generador `gen_dial.py`, misma semilla).

| # | Marco | Qué demuestra |
|---|---|---|
| 13 | Dynamic Island: mínima, compacta (sonando / en pausa) y expandida | El glifo de regla como gramática de la Isla; el estado por la aguja (Índice vs tinta) y por palabra; la expandida con un control de 56, +15 y la Regla estática |
| 14 | Prueba caducada (noche 8): "Mar lento · sin Océano" | Título honesto, "Prueba terminada" una vez, fila Pro sin pulgar, Marea con la palabra, Marrón sonando, Disco intacto, cero candados |
| 15 | Apple Watch: sesión, Marea con háptico, complicación, Smart Stack | La corona como dial; la fila de pulsos bajo el Mareógrafo como única visualización del háptico |
| 16 | StandBy nocturno con dos widgets bajo el rojo: sonando y "Lista" | Estado por base continua/discontinua y play/pause bajo el tinte; una sola tinta |
| 17 | Widget mediano sonando; widgets de bloqueo rectangular e inline | Tres noches, la que suena con su Disco en pausa; el glifo y la cifra como texto en el bloqueo |

Pendiente para el prototipo SwiftUI (no para la maqueta): la Regla sobre `Slider` con VoiceOver en iOS 17/18/26; la pausa de AirPods (hipótesis `pauseCommand`); la medida de la Banda con Instruments; el tinte real de StandBy con una Live Activity de prueba y una foto calibrada; la prueba a ciegas de §15.
