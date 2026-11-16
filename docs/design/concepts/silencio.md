# Concepto «Silencio»

**Equipo Silencio · Diseño de concepto · 16 de noviembre de 2026**
**Postura frente a la tensión del brief (§5):** somos sobre todo noche; el instrumento aparece bajo el dedo y se dice con palabras. Sacrificamos la densidad del panel (B) y la riqueza editorial de día (A) a cambio de una sola superficie que se opera a ciegas.

Linaje declarado: Nothing (la luz es información), Aesop (el texto que no persuade), Muji (el receptáculo vacío), Ive en su fase más radical (quitar hasta que duela), la alarma del Reloj de iOS 26 (una pantalla que es un botón). Lo que tomamos de Bear no es su tipografía: es su confianza en que una frase bien puesta sobre un fondo vacío ya es diseño.

Maqueta estática: `scratchpad/design/concepts/silencio.html` (ruta completa en el resultado estructurado). Alcance: el del encargo (el plan de funciones priorizado no existía al diseñar).

---

## 1. Tesis

SleepNoise es una pantalla negra que dice en una frase lo que está pasando y que entera es el control. No hay barras, pestañas, tarjetas, hojas con título ni iconos salvo el glifo de reproducción. La frase («Lluvia y marrón · 42 min · Marea en 6») es a la vez estado y menú: cada tramo es una palabra que se puede tocar, así que todo lo que un gesto hace rápido también se hace con un toque sobre un texto. Bajo la frase vive la única forma de la app, la Regla: una línea horizontal cuya longitud es el volumen, cuya luz es la envolvente real del DSP y que, en la Marea, avanza y se retira al ritmo de la respiración. Arrastrar en vertical sube o baja el volumen; en horizontal alarga o acorta el temporizador; una pulsación larga enciende o apaga la Marea; dos dedos abren y cierran el mezclador. A las tres de la mañana no hace falta mirar: la mitad superior de la pantalla es «menos», la inferior es «más», cualquier toque es pausa o vuelta, y la pantalla se apaga sola hasta dejar solo el tiempo que queda. Lo que no hay (cuenta, suscripción, racha, anuncios, red, puntuación, candados, cromo) no se enumera como virtud en una pantalla de bienvenida: se nota porque no está.

---

## 2. Identidad

### 2.1 Paleta

Negro absoluto como material; un blanco cálido como tinta; un único acento que solo aparece cuando hay sonido. Ratios WCAG 2.x calculados por luminancia relativa (script de la sesión). «Rojo A» es el ratio tras el tinte de StandBy nocturno conservando solo el canal R (modelo A del documento 02); «Rojo B» convierte la luminancia a rojo (modelo B). Diseñamos para el peor de los dos.

| Token | Hex | Sobre `#000` | Sobre `#1C1C1E` | Rojo A | Rojo B | Dónde se usa en Silencio |
|---|---|---|---|---|---|---|
| `negro` | `#000000` | — | — | — | — | Fondo de **todas** las superficies, incluidas hojas y paywall. No hay `hoja` gris: una hoja se distingue por la hairline superior y por el gesto del sistema. |
| `texto` | `#E8E4DC` | **16,56** | 13,42 | **4,43** | **4,30** | La frase, la cifra, el glifo play/pausa, la palabra de acción primaria, la Regla de noche. |
| `texto2` | `#9C9A96` | **7,48** | 6,06 | 2,41 | 2,37 | Tramos inactivos de la frase, valores, notas, palabras secundarias (Noches, Más, Volver). Nunca en StandBy/widgets/Live Activity. |
| `texto3` | `#6E6C68` | **4,01** | 3,25 | 1,66 | 1,64 | Solo no textual: Regla en reposo (sonido parado), pista vacía de nivel. Cumple el 3:1 de componente. Nunca texto. |
| `trazo` | `#2A2A2E` | 1,47 | — | — | — | Hairline de 0,5 pt entre filas del mezclador, de Noches y del paywall. Decorativa: no transmite estado. |
| `brasa` | `#C9A27A` | **8,93** | 7,24 | **3,48** | 2,69 | **El acento.** Un único elemento por pantalla: la Regla mientras suena (principal, Marea, Madrugada) o la palabra «Comprar» en el paywall. En StandBy no se usa (2,69 bajo el modelo B no llega al 3:1): allí la Regla es `texto`. |
| `arena` | `#D9C7AE` | 12,73 | 10,31 | 3,95 | 3,48 | Variante de `brasa` con «Aumentar contraste». Alta contraste de `texto2` → `#B4B2AE` (9,92), `texto3` → `#7A7672` (4,66). Declaradas en el catálogo de activos. |
| `error` | `.red` del sistema | 5,4 | — | — | — | Solo el aviso de sesión de audio fallida, como texto de 17 pt Medium. Único rojo. |

Decisión del acento (brief §5, pregunta 3 al dueño): el acento de Silencio **es luz, no color**, salvo en un punto. La jerarquía se construye con tres luminancias de la misma tinta; el color (`brasa`) aparece exclusivamente cuando el DSP está produciendo sonido, en la única forma de la pantalla. Si el sonido para, el color desaparece en 1,5 s. Así el usuario aprende sin texto que color = sonido. Bajo el rojo de StandBy el acento no se necesita porque allí la Regla ya se dibuja en `texto` (4,43:1, AA de texto normal y, con 3 pt de grosor, holgado como componente).

Comprobaciones de P3 y P7: en la pantalla principal en reposo nocturno, los píxeles encendidos son la frase (dos líneas), una línea de 2 pt, un glifo de 28 pt y dos palabras de 13 pt: menos del 3 % de la superficie. Todos los estados se leen en escala de grises: suena/no suena = `pause.fill`/`play.fill` y Regla luminosa/tenue; capa activa = línea con longitud frente a línea vacía; Pro = la palabra «Pro».

### 2.2 Tipografía

Una familia: **SF Pro**, tamaños ópticos automáticos. Una voz: **SF Pro Rounded** solo en la cifra de noche. Ninguna otra: ni SF Mono (Silencio no tiene lecturas técnicas en primer nivel), ni New York (el texto largo de «Qué sabemos y qué no» va en SF Pro Regular con interlineado 1,45; una familia también allí).

| Estilo | Uso | Familia / peso | Tamaño / interlineado (Large) | `relativeTo` | Tracking | Noche |
|---|---|---|---|---|---|---|
| **Frase** | La frase de estado de la principal; título de Marea, Noches, Pro | SF Pro Medium | 28 / 34 | `.title1` | −1 % | Medium |
| **Cifra** | «38 min» en Noche y Madrugada; cuenta atrás en Marea guiando | SF Pro Rounded Regular, `monospacedDigit()` | 72 / 80 | `.largeTitle`, tope `accessibility2` | −1,5 % | Regular (≥ 20 pt permitido) |
| **Encabezado** | Nombre de capa, nombre de noche guardada, modo de temporizador | SF Pro Semibold | 17 / 22 | `.headline` | 0 | Semibold |
| **Cuerpo** | Explicaciones de una línea, texto del paywall y de «Qué sabemos» | SF Pro Regular | 17 / 24 | `.body` | 0 | Medium |
| **Secundario** | Subtítulo de capa («lluvia fina»), valor junto al nombre, estado de la Marea | SF Pro Regular, `monospacedDigit()` | 15 / 20 | `.subheadline` | 0 | Medium |
| **Nota** | Palabras de pie (Noches · Más · Volver), «Prueba · quedan 5 noches», pie legal, etiquetas de estado en versalitas | SF Pro Medium (versalitas reales con `.smallCaps()` para Pro/Prueba) | 13 / 18 | `.footnote` | +2 % en versalitas | Medium |

Seis estilos; ninguna pantalla usa más de cuatro. Nada por debajo de 13 pt; nada por debajo de Medium de noche; ni Light, ni Thin, ni Bold; sin mayúsculas sostenidas. Dynamic Type de xSmall a AX5: la frase pasa de una línea a tres (cada tramo en su línea) a partir de xxxLarge con `ViewThatFits`; la Cifra se limita a `accessibility2` (≈ 120 pt) para que «38 min» quepa en 345 pt de ancho; el mezclador apila nombre y Regla a partir de AX1.

### 2.3 Espaciado, hairline, radios

- Retícula de 4 pt. Margen lateral **24 pt** (columna de 345 pt en 393): más aire que el estándar de 16-20 porque no hay cajas que lo necesiten.
- Vertical de la principal (Large, 852 pt): zona segura superior 59; aire 184; frase a 243 (primera línea de base ≈ 268); Regla a 24 pt bajo la última línea de la frase; glifo de reproducción centrado a 560; línea de pie a 790 (dentro de la zona segura inferior de 34).
- Hairline: 0,5 pt (1 px en @2x/@3x) en `trazo`. Es el único separador y solo existe en listas (mezclador, Noches, temporizador, paywall, Qué sabemos). En la principal no hay ninguna.
- Radios: **ninguno propio**. No hay rectángulos rellenos, luego no hay esquinas. Las hojas del sistema conservan su radio; con `presentationBackground(.black)` y `presentationCornerRadius` por defecto.
- Objetivos: la pantalla entera (393 × 852) es el objetivo de reproducción; cada tramo de la frase tiene un área de toque de ≥ 44 pt de alto que se extiende 12 pt por encima y por debajo del texto; las palabras de pie, 44 × 64; las filas del mezclador, 56 pt; la zona de «Volver» de noche, 64 pt de alto a todo el ancho.
- Sombras, materiales, degradados, desenfoques: ninguno. Liquid Glass: no hay barra en la que ponerlo; la única superficie de navegación es la hoja del sistema (paywall, Más), que lleva el vidrio que el sistema le dé.

### 2.4 Iconografía

Un solo glifo en toda la app: `play.fill` / `pause.fill` (SF Symbols, 28 pt en Large, peso Medium heredado, monocromo, `contentTransition(.symbolEffect(.replace))`). Nada más: ni temporizador, ni guardar, ni luna, ni altavoz, ni flechas de navegación (las filas que abren algo lo dicen con la palabra; VoiceOver anuncia «botón»). Donde el sistema exige un símbolo (Centro de control, widget, Watch, icono) se usa **la Regla**: una línea horizontal gruesa que entra desde la izquierda, dibujada como símbolo personalizado desde la plantilla de SF Symbols (nueve pesos, tres escalas), variante *on* = línea larga, variante *off* = línea corta. Es el mismo dibujo del icono.

---

## 3. Sistema de componentes

Convención: cada componente lista sus estados **normal / activo / Pro (bloqueado sin castigo) / prueba / deshabilitado / VoiceOver**. «Sistema» o «propio» según P12.

### 3.1 La Frase (propio)

Un `Text` compuesto por tramos separados por « · » (punto medio, U+00B7, con espacios finos U+2009). Cada tramo es un `Button` de estilo `.plain`.

- **Normal (reposo):** «Lluvia y marrón» en `texto`; «45 min · Marea» en `texto2` en segunda línea (lo que *haría* al pulsar). EN: "Rain and brown" / "45 min · Tide".
- **Activo (sonando):** «Lluvia y marrón · 42 min · Marea en 6» todo en `texto`; el número de minutos baja cada minuto (`monospacedDigit`). Si no hay temporizador: «Lluvia y marrón · toda la noche». Si la Marea no está: se omite el tramo. EN: "Rain and brown · 42 min · Tide at 6" / "all night".
- **Pro (usuario gratuito tras la prueba con una capa Pro en la mezcla):** la mezcla guardada que contenía Océano suena sin Océano y la frase lo dice: «Lluvia y marrón · sin océano». Tocar «sin océano» abre Pro. Ningún candado.
- **Prueba:** línea de Nota bajo la Regla: «Prueba · quedan 5 noches» en `texto2`. Última noche: «Prueba · última noche». Nada más cambia.
- **Deshabilitado:** no existe. La frase siempre se puede tocar.
- **VoiceOver:** el conjunto es un `accessibilityElement(children: .contain)`; cada tramo anuncia «Lluvia y marrón, botón, abre el mezclador», «42 minutos, botón, temporizador», «Marea en 6 por minuto, botón». La frase completa se anuncia también como resumen al entrar en la pantalla (`accessibilityLabel` del contenedor) para que no haya que recorrer.

### 3.2 La Regla (propio): visual del sonido, control de nivel y forma de la Marea

Una `Capsule` horizontal de altura fija alineada a la izquierda bajo la frase.

- Geometría: 2 pt de alto (3 pt de noche y en StandBy; 1,5 pt con `isLuminanceReduced` queda congelada), longitud = `volumenMaestro × 345 pt`. Longitud mínima visible 8 pt (volumen 0 muestra un punto: el silencio dibujado).
- Señal del motor: opacidad = 0,45 + 0,55 × RMS suavizado (τ 500 ms, publicado a 20 Hz por el mismo seqlock que los `SoundGains`). Si el motor calla, la opacidad baja a 0,45 en < 1 s: la prueba de que lee el audio y no un reloj.
- **Normal (reposo):** `texto3`, opacidad 1, quieta. Es lo que se ve en la tienda: una línea corta y tenue, honesta.
- **Activo (sonando):** `brasa`, opacidad por envolvente; en el arranque crece desde 0 en 800 ms a la par que el fundido del audio; al parar se apaga en 1,5 s.
- **Marea:** la misma línea avanza y se retira entre el 60 % y el 100 % de la longitud de volumen con `BreathCurve` (4:6), 7,5-15 s por ciclo. Ningún segundo indicador. Con Reduce Motion, la longitud no cambia y respira la opacidad (±25 %).
- **Arrastre vertical (volumen):** mientras el dedo está en pantalla la línea sigue el valor a 60 fps; `.selection` al cruzar el 0, `.impact(.light, 0,6)` al llegar al 100. Un texto de Secundario aparece 250 ms a la derecha de la línea: «64 %» y se desvanece 1 s después de soltar.
- **Pro / prueba:** no aplica (es el nivel maestro).
- **Deshabilitado:** nunca.
- **VoiceOver:** `.adjustable`, etiqueta «Volumen», valor «64 por ciento», incrementos del 5 %. Además publica un `AXChartDescriptor` con la envolvente de los últimos 10 s por capa (gráfico de audio en el rotor).

### 3.3 Control de nivel por capa (propio, misma pieza que la Regla)

Fila de 56 pt: nombre (Encabezado) a la izquierda, valor (Secundario, tabular) a la derecha, y la Regla de la capa (2 pt, `texto`, opacidad por envolvente de *esa* capa) a 8 pt bajo el nombre; hairline `trazo` al final. **La fila entera es el deslizador**: arrastre horizontal = nivel (el pulgar es el extremo de la línea). No hay `Slider` del sistema porque el sistema no tiene un deslizador sin pista ni pulgar; se construye con `DragGesture` + `.accessibilityAdjustableAction`.

- **Normal (capa a 0):** nombre en `texto`, valor «—», línea de 8 pt en `texto3`.
- **Activo (capa sonando):** nombre `texto`, valor «65», línea de longitud 65 % en `texto` con la envolvente de la capa.
- **Pro (gratuito tras la prueba):** nombre en `texto2`, valor sustituido por «Pro» en versalitas `texto2`, línea de 8 pt en `texto3`. Al tocar: la capa suena 30 s al 50 % y la frase de la principal pasa a «Océano · 30 s de prueba»; al terminar se abre Pro con el precio en la primera línea. Nada se tacha ni se atenúa.
- **Prueba:** idéntica a activo; todo abierto.
- **Deshabilitado:** no existe.
- **VoiceOver:** «Océano, 65 por ciento, ajustable»; acciones personalizadas «Silenciar», «Máximo»; en Pro: «Océano, requiere Pro, botón; toca para escuchar 30 segundos».

### 3.4 Botón primario y secundario (sistema, estilo `.plain`)

No hay botones rellenos. Un botón primario es una **palabra en `texto` Medium 17 pt sobre una fila de 64 pt** delimitada por dos hairlines (arriba y abajo), a todo el ancho: «Empezar», «Comprar · 29,99 €», «Guardar esta noche». El secundario es la misma palabra en `texto2` sin hairlines: «Restaurar compra», «Ahora no», «Volver».

- **Normal:** como arriba. **Pulsado:** opacidad 0,6 durante 200 ms (`.easeInOut`). **Activo (en curso):** el texto cambia a su opuesto («Parar»). **Pro:** el primario que requiere Pro lleva la versalita «Pro» a la derecha, y al tocarlo abre Pro. **Deshabilitado:** `texto3` solo cuando el texto es ≥ 18 pt (en 17 pt, mejor ocultar la fila que mostrarla a 4:1). **VoiceOver:** `.isButton`; con «Formas de botón» activado el sistema subraya la palabra, lo que además resuelve la discoverabilidad para quien lo necesita.
- Único acento permitido en un botón: «Comprar · 29,99 €» en `brasa` en el paywall (allí no hay Regla sonando en pantalla; sigue habiendo un solo elemento de acento).

### 3.5 Chip de estado (propio, pero no es un chip)

No hay cápsulas. El estado es una **palabra en versalitas** de 13 pt Medium `texto2`: «Pro», «Prueba · quedan 5 noches», «Noche», «30 s de prueba». Estados: aparece / no aparece. VoiceOver la lee como texto estático dentro de la fila a la que pertenece.

### 3.6 Hoja (sistema)

`sheet` del sistema con `presentationBackground(.black)`, `presentationDragIndicator(.visible)` (el indicador real, nunca uno pintado) y detentes `.medium`/`.large` solo donde tiene sentido (Temporizador: `.medium`). Sin título de navegación: la primera línea de la hoja es la Frase correspondiente («Temporizador», «Pro», «Más»). Sin botón «Cerrar»: se cierra con el gesto del sistema y, para VoiceOver y Acceso asistido, con la palabra «Listo» en `texto2` arriba a la derecha (44 × 44) que el sistema escapa también con el gesto de Z. Estados: una hoja no tiene estados; su contenido sí.

### 3.7 Barra (no hay)

Silencio no tiene barra de pestañas ni de herramientas. La navegación es la Frase y la línea de pie (dos palabras: «Noches», «Más»). Justificación ante P12: Apple regala la barra, pero una barra sobre negro con tres iconos convierte la pantalla en «una app más»; aquí la pantalla es el instrumento y el instrumento no tiene barra. El coste (pérdida de Liquid Glass en la principal) se asume: el vidrio aparece en las hojas del sistema.

### 3.8 Glifo de reproducción (sistema)

`Image(systemName:)` 28 pt, `texto`, centrado a 560 pt. No es el único objetivo (la pantalla entera lo es); es el indicador de estado y el lugar al que mira quien no conoce los gestos. Estados: `play.fill` en reposo, `pause.fill` sonando; durante el fundido final, `pause.fill` con `symbolEffect(.pulse)` (único efecto repetitivo, se apaga con Reduce Motion). VoiceOver: «Reproducir, botón» / «Pausar, botón»; el *Magic Tap* (doble toque con dos dedos) reproduce o pausa desde cualquier punto, como en Música.

---

## 4. Gestos y su equivalente sin gestos

| Intención | Gesto en la principal | Sin gesto (toque sobre texto) | VoiceOver | Otras superficies |
|---|---|---|---|---|
| Reproducir / pausar | Toque en cualquier punto | Toque en el glifo | Magic Tap; glifo como botón | Live Activity, widget, Centro de control, Watch, Atajos |
| Volumen | Arrastre vertical (arriba = más). 1 pt = 0,5 %; detentes hápticos en 0 y 100 | Tocar la Regla abre un ajuste de nivel en una fila con «menos» / «más» de 64 pt | Regla `.adjustable` | Corona del Watch; botones físicos del iPhone (volumen del sistema) |
| Temporizador | Arrastre horizontal (derecha = más). 1 pt = 15 s; detente `.selection` cada 15 min; la frase muestra el valor en vivo | Tocar «42 min» abre la hoja Temporizador (tres modos) | Tramo «42 minutos» como botón; acción personalizada «Añadir 15 minutos» en el elemento raíz | Live Activity: botón «+15» no existe; en su lugar la Regla de la actividad es un botón «Quince minutos más» de 44 pt (una sola acción secundaria, HIG) |
| Marea | Pulsación larga (0,6 s) en cualquier punto: enciende o apaga; háptico `.impact(.medium)` solo al encender | Tocar «Marea» (o «Marea en 6») abre la pantalla Marea | Tramo «Marea» como botón; acción personalizada «Marea» en el elemento raíz | Watch: pulsación larga en la esfera de la app |
| Mezclador | Toque con dos dedos: aparece; otro toque con dos dedos, o arrastre hacia abajo: desaparece | Tocar «Lluvia y marrón» | Tramo como botón | — |
| Noche | Automática: 20 s sin tocar mientras suena, o al bloquear y volver; manual: arrastre hacia abajo en la principal | Palabra «Noche» en la línea de pie (aparece solo mientras suena) | Botón «Noche» | — |
| Salir de Noche | Toque en el tercio inferior («Volver») o arrastre hacia arriba | Palabra «Volver» (64 pt de alto) | Botón «Volver»; el escape de Z funciona | — |

Descubribilidad: (1) la Frase es legible como menú porque sus tramos cambian de luminancia al pulsarse y porque «Formas de botón» los subraya; (2) el primer uso enseña una línea de TipKit bajo el glifo: «Toca para empezar. Arrastra arriba o abajo para el volumen.» que desaparece tras la primera reproducción y el primer arrastre; (3) el segundo día, otra única línea: «Dos dedos abren el mezclador.»; (4) los gestos tienen siempre un texto equivalente, así que descubrirlos es un atajo, no un requisito. Prueba de aceptación: cinco personas ajenas deben reproducir, cambiar el volumen y alargar el temporizador en menos de un minuto sin instrucciones; otras cinco con VoiceOver deben hacer lo mismo solo con la Frase y el rotor.

---

## 5. Pantallas y superficies

Todas sobre `negro`. Medidas para 393 × 852 en tamaño Large. Textos ES / EN.

### 5.1 Principal · en reposo

Pregunta a la que responde: «¿Qué va a sonar y cómo lo enciendo?»

- Hora del sistema en la barra de estado; nada propio por encima de 243 pt.
- **Frase** (28 Medium, `texto`), x 24, y 243: «Lluvia y marrón». Segunda línea (28 Medium, `texto2`): «45 min · Marea». EN: "Rain and brown" / "45 min · Tide".
- **Regla** a 24 pt bajo la frase: `texto3`, 2 pt, longitud 64 % (volumen guardado).
- **Prueba** (solo durante la prueba), Nota `texto2`, 16 pt bajo la Regla: «Prueba · quedan 5 noches». EN: "Trial · 5 nights left". El primer día, en su lugar: «7 noches con todo. Sin tarjeta.» ("7 nights with everything. No card."), que al tocarse abre la pantalla Prueba (5.10).
- **Glifo** `play.fill` 28 pt `texto`, centrado en x, y 560.
- **Tip de primer uso** (TipKit, una línea, Nota `texto2`, centrada, y 612): «Toca para empezar. Arrastra arriba o abajo para el volumen.» EN: "Tap to start. Drag up or down for volume."
- **Línea de pie**, y 790: «Noches» a la izquierda (x 24), «Más» a la derecha (alineado a 369); Nota 13 Medium `texto2`; objetivos 44 × 64. EN: "Nights" / "More".
- Al tocar en cualquier parte que no sea un texto: arranca el fundido de 800 ms, la Regla pasa a `brasa` y crece desde 0, el glifo se sustituye por `pause.fill`, la frase pasa a su forma activa. Háptico `.impact(.medium, 0,7)`.

### 5.2 Principal · sonando con temporizador y Marea

Pregunta: «¿Todo va bien y cuánto queda?»

- Frase en una línea (o dos si no cabe): «Lluvia y marrón · 42 min · Marea en 6», `texto`. EN: "Rain and brown · 42 min · Tide at 6". Durante el descenso de la Marea: «Marea en 9 → 6»; en la disolución: «Marea se retira». EN: "Tide 9 → 6" / "Tide fading".
- Regla en `brasa`, 2 pt, longitud 64 %, respirando entre 38 % y 64 % a 6 por minuto (Marea activa), opacidad por envolvente.
- Glifo `pause.fill`.
- Línea de pie: «Noches» · «Noche» (centro, solo mientras suena) · «Más».
- A los 20 s sin tocar, transición de 1,5 s (opacidad) a la pantalla Noche. Un toque antes de eso pausa (con fundido de 1,5 s) y la frase pasa a «Lluvia y marrón · en pausa · 42 min» ("paused").
- Durante el fundido final del temporizador (últimos 10 min en «hasta dormirme», 30 en «escudo»): la frase dice «Lluvia y marrón · se apaga en 8 min» ("fading out in 8 min") y el glifo pulsa.

### 5.3 Mezclador (aparece sobre la principal)

Pregunta: «¿Qué capas suenan y a cuánto?»

Se presenta como superposición de pantalla completa en negro, con transición de opacidad de 250 ms (no hoja: no hay asa, porque el gesto de salida es el mismo que el de entrada; para quien no hace gestos, «Listo» arriba a la derecha).

- y 59-103: «Listo» ("Done") Nota `texto2`, alineado a la derecha, 44 × 44.
- y 120: Frase «Mezclador» ("Mixer") 28 Medium `texto`. Debajo, la Regla maestra (`brasa` si suena) a 16 pt.
- Prueba: línea de Nota bajo la Regla si procede.
- Desde y 196: once filas de 56 pt (3.3), en este orden: Blanco, Rosa, Marrón, Lluvia, Ventilador, Océano, Trueno, Hoguera, Arroyo, Viento, Cabina. Subtítulos humanos en Secundario `texto2` solo mientras la fila se arrastra («siseo parejo», «retumbo grave», «lluvia fina», «ventilador lejano», «mar de fondo», «tormenta lejana», «leña», «agua entre piedras», «viento en la ventana», «cabina de avión»). EN: "even hiss", "low rumble", "fine rain", "distant fan", "ocean swell", "distant storm", "firewood", "water over stones", "wind at the window", "airplane cabin".
- 11 × 56 = 616 pt: termina en 812, sin desplazamiento en Large. A partir de xxxLarge desplaza (es la excepción asumida a «sin scroll»).
- Pulsación larga en una fila: aparece bajo el nombre una segunda línea de ajuste humano («más cálido ⟷ más lejano»: corte de graves y agudos del motor) como arrastre horizontal en Secundario. Es el «técnico debajo del gesto» de P11.
- Pro (gratuito tras la prueba): Ventilador, Océano, Trueno, Hoguera, Arroyo, Viento, Cabina muestran «Pro» en versalitas como valor; se comportan como en 3.3. Conteo de candados: cero. Conteo de la palabra «Pro»: siete, en `texto2`, 13 pt.
- VoiceOver: encabezado «Mezclador»; cada fila ajustable; «Listo» como botón; el escape de Z cierra.

### 5.4 Marea · ajustes

Pregunta: «¿Cómo respiro con esto?»

Superposición negra igual que el mezclador; se llega tocando «Marea» en la frase o con la pulsación larga (si la pulsación larga enciende la Marea directamente, la pantalla no se abre; se abre solo desde la palabra).

- «Listo» arriba a la derecha.
- y 120: Frase «Marea» ("Tide").
- y 170: Cuerpo `texto2`, 17/24: «Inhala mientras la línea avanza. Exhala mientras se retira. No hace falta mirar la pantalla.» EN: "Breathe in as the line advances. Breathe out as it recedes. No need to watch the screen."
- y 262: la Regla, 3 pt, en `texto3` (reposo), que al arrastrar horizontalmente cambia el ritmo: a la derecha más lento, a la izquierda más rápido; detentes en cada respiración por minuto (4-10).
- Filas de 56 pt desde y 310, cada una «nombre a la izquierda, valor a la derecha», hairline entre ellas; el valor se ajusta con arrastre horizontal en la fila o con los botones «menos / más» que VoiceOver expone como acción ajustable:
  - «Ritmo» · «6 por minuto» ("Pace" · "6 per minute"). Pulsación larga en la fila: segunda línea «Empieza a tu ritmo (12) y baja a 6 en 4 minutos» ("Starts at your pace (12) and eases to 6 in 4 minutes"); si Salud está autorizado: «Empieza a 14, tu ritmo nocturno medio según Salud» ("Starts at 14, your average night pace from Health").
  - «Dura» · «15 min» ("Lasts" · "15 min"); valores 5, 10, 15, 20, 30.
  - «Exhalación» · «más larga» ("Out-breath" · "longer"); alternativa «igual» ("equal"). El 4:6 técnico, debajo de la pulsación larga.
  - «En la muñeca» · «no» / «mínima» / «marcada» ("On the wrist" · "off" / "minimal" / "marked"), solo si hay Watch emparejado.
- y 620: botón primario (3.4) «Empezar» ("Start") entre hairlines, 64 pt. Si ya está activa: «Parar» ("Stop").
- Nota de pie, y 760, `texto2`: «Ritmo respiratorio lento asociado en estudios a mayor variabilidad cardiaca. Qué sabemos y qué no.» con el final como enlace (botón). EN: "Slow breathing pace linked in studies to higher heart-rate variability. What we know and what we don't."

### 5.5 Marea · guiando

La misma pantalla, reducida a lo esencial, cuando la Marea está activa y el usuario sigue mirando (si no toca en 20 s, pasa a Noche con la Regla respirando):

- Frase, y 243: «Marea» en `texto` y, en la segunda línea, «Guiando · 6 por minuto · 11 min» en `texto2` (durante el descenso, «Guiando · 9 → 6 · 13 min»). EN: "Guiding · 6 per minute · 11 min". En la disolución: «Disolviéndose · 3 min» ("Dissolving · 3 min").
- Regla, y 330, 3 pt, `brasa`, respirando 38-64 %. Es el único movimiento de la pantalla.
- Cifra opcional, y 420, 72 Rounded `texto2`: el ritmo actual «6» con «por minuto» en Secundario debajo; solo durante el descenso (12 → 6), porque es cuando el número informa de algo que cambia. Después desaparece.
- Pie: «Parar» como secundario `texto2` centrado a y 790. Un toque en cualquier otro punto no hace nada aquí (evitar paradas accidentales); la pulsación larga apaga la Marea.

### 5.6 Temporizador (hoja `.medium`)

Pregunta: «¿Cuándo se apaga?»

Se abre tocando «42 min» / «45 min». La hoja mide ~440 pt; indicador de arrastre del sistema; «Listo» a la derecha.

- Frase «Temporizador» ("Timer").
- Tres filas de 64 pt, hairline entre ellas; la activa lleva el valor en `texto` y las demás en `texto2`; la fila entera se arrastra en horizontal para cambiar la duración:
  - «Hasta dormirme» · «45 min» ("Until I'm asleep" · "45 min"), 15-90 en pasos de 5; fundido en los últimos 10.
  - «Escudo nocturno» · «hasta las 7:00» ("Night shield" · "until 7:00"), hora fija; el nivel baja un 30 % desde las 5:00 (dicho en Secundario: «baja de nivel al amanecer» / "eases at dawn"); nunca silencia la alarma del sistema.
  - «Siesta» · «20 min» ("Nap" · "20 min"), 10/20/30; fundido en los últimos 3.
  - Cuarta fila sin valor: «Sin temporizador» ("No timer").
- Gratuito tras la prueba: valores por encima de 60 min y «Escudo nocturno» muestran «Pro» en versalitas a la derecha del valor; al elegirlos, se abre Pro. La fila existe completa.
- Nota de pie: «El sonido se desvanece antes de que termine. Tu alarma suena igual.» EN: "The sound fades before the end. Your alarm still rings."

### 5.7 Noche

Pregunta: «¿Sigue bien?»

- Negro. Sin barra de estado propia (la del sistema se oculta con `statusBarHidden`). Brillo no se toca (el usuario manda), pero la luminancia total es la de dos textos.
- Cifra, centrada, y 360: «38 min» 72 Rounded Regular `texto` (−1,5 %). Sin temporizador: «Suena» ("Playing") en Frase 28 Medium `texto`. En pausa: «En pausa» ("Paused").
- Debajo, y 452: hora «03:12» 22 Medium `texto2` tabular, actualizada cada minuto (`TimelineView(.everyMinute)`).
- Regla, y 500, 3 pt, `texto` (no `brasa`: de noche el color sobra), longitud = volumen; respira si la Marea está activa; quieta si no; congelada con `isLuminanceReduced`.
- Zona inferior (y 788-852): «Volver» ("Back") Nota `texto2` centrada; objetivo 64 pt a todo el ancho.
- Gestos: toque en los dos tercios superiores = pausa/reanuda (la cifra pasa a «En pausa»); arrastre vertical = volumen; arrastre horizontal = +/− temporizador (la cifra cambia en vivo, detentes cada 15 min); pulsación larga = Marea. Sin hápticos aquí: el iPhone está en la mesilla y vibrar es sonido (02 §4.3). Confirmación: el sonido mismo.
- Sale: «Volver» o arrastre hacia arriba; también al bloquear (la app vuelve a Noche al desbloquear si sigue sonando).
- Acceso asistido / Acceso guiado: funciona con esta disposición de un control (la pantalla).
- VoiceOver: un elemento raíz «Sonando, 38 minutos restantes, 3 y 12 de la madrugada; toca dos veces para pausar»; acciones «Quince minutos más», «Marea», «Volver».

### 5.8 Modo Madrugada (20 min desde el bloqueo)

Pregunta: «Me he despertado; ¿me vuelves a dormir sin pensar?»

- Desde la pantalla de bloqueo, la Live Activity de una sesión terminada o en pausa ofrece un único botón «20 min» ("20 min"). Al tocarlo (o al abrir la app entre las 1:00 y las 5:00 con la sesión parada), la app abre directamente esta pantalla y arranca la última mezcla al 70 % del volumen guardado, con Marea a 6 y disolución a los 20 min.
- Pantalla: como Noche, con la Cifra «20 min» bajando, la hora debajo y la Regla respirando. Sin «Volver»: el gesto de salida es el mismo y el tercio inferior dice «Parar» ("Stop") en `texto2`. Ningún otro texto, ninguna oferta, nunca Pro (si la última mezcla tenía capas Pro y la prueba acabó, suena sin ellas y no lo dice hasta la mañana).
- Al terminar: la Regla se apaga en 2 s, la pantalla se oscurece del todo y la app bloquea el dispositivo si tiene permiso (`UIApplication` no lo permite: se apaga la pantalla por el tiempo de bloqueo automático del usuario; se documenta como límite).

### 5.9 Noches (mezclas guardadas; incorpora los presets del PR #3)

Pregunta: «¿Qué noche quiero?»

Hoja `.large` desde la palabra «Noches».

- «Listo» a la derecha. Frase «Noches» ("Nights").
- Fila primaria de 64 pt entre hairlines: «Guardar esta noche» ("Save this night"): guarda la mezcla, el volumen, el temporizador y la Marea actuales con nombre propuesto a partir de la frase («Lluvia y marrón»); el nombre se edita en línea (TextField del sistema).
- Después, las noches en filas de 64 pt: nombre en Encabezado `texto`, debajo en Secundario `texto2` la frase que la describe («lluvia 65 · marrón 40 · 45 min · Marea»). Un toque la carga y la reproduce (fundido cruzado de 2 s); deslizar a la izquierda = Borrar (acción del sistema, roja porque el sistema la pinta); mantener = reordenar.
- Las tres noches de fábrica (los «presets» del PR #3, rebautizados y sin iconos): «Lluvia en la ventana» ("Rain on the window": lluvia 60, marrón 30), «Noche cerrada» ("Deep night": marrón 70, rosa 20), «Avión» ("Cabin": cabina 55, rosa 25; Pro). Las de fábrica no se pueden borrar; se pueden ocultar.
- Gratuito tras la prueba: tres noches propias; la cuarta muestra «Guardar esta noche · Pro». Las guardadas se conservan siempre.
- Vacío: no hay estado vacío con icono; están las tres de fábrica.
- Persistencia: `NSUbiquitousKeyValueStore` (sobreviven a reinstalar y a cambiar de iPhone sin cuenta propia).

### 5.10 Prueba y Pro (paywall)

Pregunta: «¿Qué cuesta y qué sigue gratis?»

Una sola pantalla para ambos, hoja `.large`, negro. Nunca aparece sola: solo al tocar «Pro», «¿Qué es la prueba?», una capa Pro al terminar sus 30 s, o «Más › Pro».

- «Listo» a la derecha (o indicador de arrastre; ambos).
- y 120: Frase «Una vez.» ("Once.") 28 Medium `texto`. Debajo, Cuerpo `texto2`: «SleepNoise Pro cuesta 29,99 €. Se paga una vez y es tuyo, también para tu familia.» EN: "SleepNoise Pro is €29.99. Pay once and it's yours, for your family too." (Precio real de StoreKit; si hay precio de lanzamiento: «29,99 € · hasta el 15 de diciembre, 19,99 €» sin tachar nada.)
- Durante la prueba, línea de Nota: «Prueba · quedan 5 noches con todo. Sin tarjeta.» ("Trial · 5 nights left with everything. No card.").
- Lista «Con Pro» ("With Pro"), filas de 48 pt con hairline, solo texto: «Ventilador, océano, trueno, hoguera, arroyo, viento y cabina» · «Temporizador más allá de 60 minutos y escudo nocturno» · «Marea respiratoria» · «Noches sin límite». EN: "Fan, ocean, thunder, campfire, brook, wind and cabin" · "Timer beyond 60 minutes and night shield" · "Breathing tide" · "Unlimited nights".
- Lista «Gratis siempre» ("Free, always"): «Blanco, rosa, marrón y lluvia» · «Temporizador de 60 minutos» · «Tres noches guardadas» · «Nada sale de tu iPhone». EN: "White, pink, brown and rain" · "60-minute timer" · "Three saved nights" · "Nothing leaves your iPhone".
- y 700: botón primario entre hairlines, 64 pt: «Comprar · 29,99 €» ("Buy · €29.99") en `brasa` (el único acento de la pantalla). Debajo, secundario centrado: «Restaurar compra» ("Restore purchase") `texto2`. Nada de «Ahora no» ni cruz: el gesto cierra.
- Pie legal, Nota `texto2`: «Pago único a través de Apple. Sin suscripción. Compartido en familia.» EN: "One-time purchase through Apple. No subscription. Family Sharing included."
- Estados: comprando → el botón dice «Comprando…» en `texto2`; error → línea en `.red` 17 Medium bajo el botón; comprado → la hoja se cierra sola y la línea de prueba desaparece de la principal. En Más queda «SleepNoise Pro · Gracias · 16 de noviembre de 2026».
- Pantalla Prueba del primer día (pregunta 5 al dueño, guía 3.1.1): la misma hoja con la Frase «7 noches con todo.» y la primera línea «Sin tarjeta. Cuando acaben, siguen gratis blanco, rosa, marrón, lluvia y 60 minutos; tus noches se conservan. Pro cuesta 29,99 €, una vez.» Botón primario «Entendido» ("Got it").

### 5.11 Primer uso

No hay onboarding. La app abre en 5.1 con la noche de fábrica «Lluvia en la ventana» cargada, volumen al 50 %, temporizador «Hasta dormirme · 45 min», Marea apagada. La línea del primer día bajo la Regla («7 noches con todo. Sin tarjeta.») y el tip bajo el glifo son las dos únicas concesiones. Ningún permiso: Salud se pide en la fila «Ritmo» de la Marea cuando el usuario toca «según Salud»; Notificaciones no se piden nunca (no hay); el micrófono no entra en este alcance.

### 5.12 Qué sabemos y qué no

Pregunta: «¿Esto que afirmáis es verdad?»

Hoja `.large` desde cualquier frase enlazada y desde Más. Frase «Qué sabemos y qué no» ("What we know and what we don't"). Texto en Cuerpo 17/24 `texto`, párrafos separados por 24 pt, sin iconos, sin sellos, sin tablas. Cada entrada: una afirmación en Encabezado, un párrafo de qué dice el estudio (n, año, quién lo pagó), y una línea de Nota «Lo que no sabemos» en `texto2`. Primeras entradas: enmascaramiento de ruido intermitente (Stanchina 2005, n=4), respiración lenta a ~6/min y variabilidad cardiaca (Zaccaro 2018, revisión de 15 estudios), ruido continuo y «mejor sueño» (Riedy 2021: evidencia de muy baja calidad; por eso no lo decimos). Cierre: «SleepNoise no es un producto sanitario.» ("SleepNoise is not a medical device.").

### 5.13 Más

Hoja `.medium`. Filas de texto con hairline: «Pro» (o «SleepNoise Pro · Gracias»), «Qué sabemos y qué no», «Atajos y Centro de control» (guía de dos párrafos), «Háptica de la Marea» (no / mínima / marcada), «Versión 2.0 · 1,8 MB · Nada sale de tu iPhone». Sin ajuste de apariencia (la app es oscura siempre: medio inmersivo, HIG), sin selector de tema, sin «Valóranos».

### 5.14 Live Activity, Dynamic Island, StandBy

Gramática: una línea por sesión (Flighty). Siempre `texto` como única tinta; `brasa` no se usa.

- **Pantalla de bloqueo (expandida):** 393 × 84. Izquierda: «Lluvia y marrón» (Encabezado 17 Semibold) y debajo «se apaga a las 23:54» (Secundario). Derecha: «42 min» (22 Medium tabular). Bajo todo, la Regla estática de 3 pt (longitud = volumen al emitir). Un solo botón: el glifo `pause.fill`/`play.fill` de 44 × 44 a la derecha de la cifra (`AudioPlaybackIntent`). Toda la Regla es un segundo botón «Quince minutos más» ("Fifteen more minutes") que se anuncia por VoiceOver y que visualmente no añade nada. Fondo negro con `activityBackgroundTint(.black)`.
- **Dynamic Island compacta:** izquierda el glifo (14 pt), derecha «42» tabular. **Mínima:** glifo. **Expandida:** la misma composición de la pantalla de bloqueo en 371 × 160, con «Noche» como botón de texto que abre 5.7.
- **StandBy nocturno:** la presentación de bloqueo escalada ×2 con tinte rojo del sistema. Composición pensada en rojo primero: `texto` → `#E80000` (4,43:1 modelo A, 4,30 modelo B); cifra 44 pt Medium, Regla 6 pt tras el escalado. Estado por forma: `pause.fill` frente a `play.fill`, Regla larga frente a punto. Si el usuario toca, el sistema escala la actividad a pantalla completa: la misma composición, nada añadido. Nada se mueve (ActivityKit no lo permite y aquí tampoco se querría).
- Actualizaciones: al empezar, al cambiar de estado, cada 15 min de temporizador, al empezar el fundido, al terminar (`.immediate`). Ocho horas máximas: la actividad acompaña a la sesión, no a la noche entera.

### 5.15 Widgets

- **Pequeño:** fondo negro removible (`containerBackground(.black, for: .widget)` con `widgetAccentable` en la Regla). Arriba a la izquierda «Lluvia y marrón» (Encabezado), debajo «42 min» (Cifra reducida, 34 Rounded), abajo la Regla de 3 pt; el widget entero es el botón play/pausa (`Button(intent:)`). En StandBy nocturno se renderiza en rojo con la misma composición.
- **Mediano:** lo mismo a la izquierda; a la derecha, tres palabras apiladas, una por noche de fábrica o guardada («Lluvia en la ventana», «Noche cerrada», «Avión»), cada una un botón que la arranca.
- **Accented / vibrant (iOS 18+):** la Regla toma el tinte; el texto no.
- Sin fondo (StandBy con «quitar fondo»): texto y Regla sobre lo que el sistema ponga; por eso la Regla es ≥ 3 pt.

### 5.16 Centro de control y botón de Acción (iOS 18+)

`ControlWidgetToggle` «SleepNoise»: símbolo propio «regla.on» (línea que entra desde la izquierda y ocupa dos tercios) / «regla.off» (línea de un tercio); el sistema tiñe el *on* con `brasa` (`.tint`). Texto de valor: «Sonando» / «En silencio» ("Playing" / "Silent"). Botón de Acción: el mismo intent; *hint* «Mantén para dormir» ("Hold to sleep"). En iOS 17, el Atajo «Dormir» cubre el caso.

### 5.17 Apple Watch (mínimo, v1.1)

Una sola vista: «42 min» en Cifra (SF Compact Rounded, la del Watch), debajo el glifo de 64 pt (toda la esfera es el botón: toque = play/pausa), corona = volumen (la Regla aparece 1 s al girarla), pulsación larga = Marea. Háptico de Marea: `.directionUp` al inicio de cada inhalación, opción mínima/marcada, solo mientras la guía está activa. Smart Stack: «Lluvia y marrón · 42 min» con la Regla. Sin complicación propia en v1.1 (la Smart Stack basta); sin tracking.

---

## 6. Icono

«La Regla sobre negro»: un cuadrado negro `#000000` con una sola línea horizontal de blanco cálido `#E8E4DC` que **entra desde el borde izquierdo** y se detiene antes del centro derecho. Construcción en el lienzo de 1024 × 1024 (Icon Composer, dos capas):

- Capa fondo: relleno `#000000` completo.
- Capa Regla: rectángulo de 0 → 640 px en x (62,5 % del ancho: el volumen de fábrica), altura 64 px (6,25 %), extremo derecho recto (no redondeado: la línea se corta, no termina), centro vertical a 656 px (64 % de la altura: la línea vive en el tercio inferior, donde está la Regla en la pantalla).
- Sin degradados, sin sombras, sin texto, sin segunda forma.
- Apariencias: *Default* y *Dark* idénticas (negro y blanco cálido); *Tinted*: el sistema tiñe la Regla y deja el fondo oscuro; *Clear*: la Regla en blanco sobre vidrio; en las cuatro la forma no cambia.
- A 29 pt la línea mide 1,8 pt de alto y 18 pt de largo: legible como «una raya que entra por la izquierda», distinta de un guion (que estaría centrado y separado de los bordes) y de todos los iconos de la categoría (lunas, nubes, ondas, auriculares). Por qué no `brasa`: el acento solo existe cuando hay sonido, y un icono no suena.

---

## 7. Capturas de la App Store (6)

Negro, cada una con el iPhone sin marco (como las capturas de Apple) y una sola frase en Frase 28 Medium `texto` arriba, una línea de Nota `texto2` debajo; sin fondos de color, sin manos, sin degradados.

1. **Principal sonando.** «Sonido que nunca se repite.» / «Se genera en tu iPhone mientras suena. Un solo pago.» EN: "Sleep sound that never loops." / "Made on your iPhone as it plays. Pay once."
2. **La Frase y los gestos.** Pantalla principal con tres anotaciones en Nota, en línea con los tramos: «toca: mezclador», «arrastra: temporizador», «mantén: Marea». Frase: «Una frase. Toda la pantalla es el control.» EN: "One sentence. The whole screen is the control."
3. **Noche.** «A las 3 de la mañana, nada que leer.» / «Negro real. Un toque pausa. Un arrastre alarga.» EN: "At 3 a.m., nothing to read." / "True black. Tap to pause. Drag to extend."
4. **Marea guiando.** «El mar respira más despacio, y tú con él.» / «Se retira solo a los 15 minutos.» EN: "The sea breathes slower, and so do you." / "Recedes on its own after 15 minutes."
5. **Mezclador.** «Once capas, sin iconos.» / «Cada línea es un sonido que se oye cambiar bajo el dedo.» EN: "Eleven layers, no icons." / "Each line is a sound you hear change under your finger."
6. **Lo que no hay.** Sin pantalla: solo texto en lista con hairlines: «Sin cuenta. Sin suscripción. Sin anuncios. Sin red. Sin racha. Sin puntuación. Sin candados.» y, en Nota, «Datos no recopilados · 1,8 MB · 29,99 € una vez». EN: "No account. No subscription. No ads. No network. No streak. No score. No locks."

Preview muda de 30 s: la Regla creciendo al pulsar, el arrastre vertical, el arrastre horizontal con la cifra cambiando, la pulsación larga y la Regla empezando a respirar, el paso a Noche.

---

## 8. Qué se elimina de la app actual y por qué

| Se elimina | Por qué |
|---|---|
| Cabecera «SleepNoise · Para la noche» | No informa a quien ya abrió la app (Muji, Leica: sin logotipo en la UI). |
| Cápsula «Prueba · 7 días» y tarjeta de prueba de seis líneas | Una línea de texto bajo la Regla lo dice; la explicación vive en una pantalla a la que se llega tocándola. |
| Tarjetas (prueba, Marea, seis capas, paywall, temporizador, Marea) | P6: el agrupamiento es por aire y hairline; el negro real exige cero rellenos. |
| Degradado de fondo `#0E1114 → #171C21` y halo ámbar radial | P3/P4: píxeles encendidos sin causa; *smear* en OLED. |
| Iconos de capa en círculos (waveform, speaker, fan…) | Las palabras son los iconos; los glifos mezclaban estilos. |
| Botón Play ámbar relleno de 88-112 pt | La pantalla entera es el botón; el glifo de 28 pt es indicador. |
| Barra inferior «Temporizador / Guardar» | Sustituida por los tramos de la Frase y la palabra «Noches». |
| Hojas con título centrado y botón «Cerrar» en cápsula | Hojas del sistema con su indicador; «Listo» como texto; la Frase como primera línea. |
| Rejilla 2×2 del temporizador y stepper «Personalizado» | Tres modos con nombre y arrastre en la fila. |
| Stepper «6 por minuto» y cinco botones de duración de la Marea | Filas de texto con arrastre; lo numérico bajo pulsación larga. |
| Segundo acento `mist` | Muere bajo el rojo; un acento. |
| Reloj Light 44 pt redondeado | Cifra Regular 72 Rounded, solo de noche. |
| Cápsulas «Pro» y candados | Palabra en versalitas; cero candados; las capas Pro suenan 30 s. |

## 9. Qué se aprovecha del PR #3 y cómo se expresa

- **La pantalla Noche en negro puro** («The screen can sleep. Sound keeps playing.»): se conserva la intención y se corrige el contraste (de 2,7:1 a 16,6:1 en la cifra), se quita el segundo botón («Leave» pasa a una palabra de pie) y se entra sola a los 20 s.
- **Presets de un toque** («Deep sleep», «Focus», «Steady rain»): se convierten en **Noches** con nombre humano y sin icono, viven en la hoja Noches y en el widget mediano; los de fábrica no se borran. «Focus» no entra en 1.0 (no hay modo de día en Silencio) y queda anotado para 1.1 como «Noche de día» si el dueño confirma el uso de concentración.
- **Camas / «Bedtime» como estado**: la idea de que la app tiene una fase de acostarse se expresa como la transición automática principal → Noche y como el «Escudo nocturno» del temporizador; no como un botón.
- **Motor, modelo y Atajos** (PR-A de la revisión): se asumen tal cual; el `AudioPlaybackIntent` es lo que hace posible que la pantalla entera, la Live Activity, el widget y el Watch compartan un solo verbo.
- **Lo que no se aprovecha**: rejilla de baldosas, chips, degradado animado, SF Rounded en cuerpo, asa falsa, 14 candados.

## 10. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| **«No hay nada» en la tienda** (lente 5 del jurado): una pantalla negra con una frase puede leerse como vacía en cinco segundos bajo luz blanca. | La primera captura muestra la pantalla sonando (Regla en `brasa`, frase completa); la tipografía a 28 pt Medium con aire se reconoce como decisión, no como ausencia; la captura 6 nombra lo que falta como producto. Prueba de cinco segundos con diez personas antes de cerrar la ficha. |
| **Gestos invisibles**: el arrastre horizontal/vertical y los dos dedos no se descubren solos. | Todo gesto tiene palabra equivalente en la Frase; dos tips de una línea (primer uso, segundo día); «Formas de botón» subraya los tramos; VoiceOver expone acciones personalizadas; prueba con cinco personas ajenas en menos de un minuto. |
| **Toques accidentales**: si toda la pantalla pausa, un roce en la mesilla pausa. | Toque = pausa solo con la app en primer plano y pantalla encendida; en Noche se exige un toque de ≥ 80 ms y se ignora el toque si CoreMotion detecta el iPhone boca abajo o tapado por el sensor de proximidad; la pausa es un fundido de 1,5 s y un segundo toque reanuda sin arranque. |
| **Conflicto de gestos** entre arrastre vertical de volumen y el gesto del sistema de cierre de hoja / Centro de control. | En la principal no hay hoja; el arrastre de volumen empieza a ≥ 60 pt del borde superior y ≥ 40 pt del inferior; el Centro de control y la Dynamic Island mantienen sus zonas. En las hojas, el arrastre de nivel es horizontal y el del sistema vertical: no colisionan. |
| **Una app solo oscura** pierde al usuario de concentración de día (segmento 3) y la HIG prefiere seguir la apariencia del sistema. | Silencio se declara medio inmersivo (HIG lo admite). Si el dueño quiere día, la paleta «papel» del documento 02 se aplica con los mismos tokens sin cambiar un componente; se diseña en 1.1 como variante, no como ajuste propio. |
| **Pulsación larga = Marea** compite con el menú contextual del sistema y con el gesto de VoiceOver. | No hay menús contextuales en la principal; con VoiceOver activado la pulsación larga no se usa (acción personalizada en su lugar). |
| **StandBy y color**: `brasa` falla el 3:1 bajo el modelo B. | En StandBy, widgets y Live Activity no se usa `brasa`: una tinta, formas ≥ 3 pt. Medir en dispositivo con una actividad de prueba antes de la beta. |
| **Sin barra = sin Liquid Glass en la principal** (lente 4). | El vidrio aparece en todas las hojas del sistema y en el icono (Clear/Tinted). Se argumenta ante el jurado que la principal no es una superficie de navegación: es contenido. |
| **Dynamic Type AX5 con una frase de 28 pt**: tres tramos no caben. | `ViewThatFits` apila un tramo por línea; la Cifra se limita a `accessibility2`; el mezclador desplaza a partir de xxxLarge. Capturas en Large, xxxLarge y AX3 en el entregable 7. |
| **Precio dicho en la Frase del paywall** depende de StoreKit y de la decisión del dueño (29,99 / 19,99 de lanzamiento). | El componente admite una segunda línea «hasta el [fecha], [precio]» sin tachar; el texto se carga de `Product.displayPrice`. |

## 11. Autoevaluación contra los doce principios (resumen)

P1 noche primero: toda pantalla se diseñó en negro y la de día no existe. P2 un gesto: toque, arrastre vertical, arrastre horizontal y pulsación larga en tres superficies. P3 negro real, un acento: `#000`, `brasa` en un solo elemento. P4 causa en el sonido: la Regla (envolvente RMS), la Marea (BreathCurve), el fundido (nivel); tabla elemento → señal en §3.2. P5 una familia: SF Pro + Rounded en la cifra; seis estilos. P6 aire: cero rectángulos rellenos en toda la app. P7 forma, no color: glifo y longitud de la Regla; capturas en gris y en rojo en la maqueta. P8 44/64 pt: pantalla entera, filas de 56-64, zona de 64 de noche. P9 nada bloquea: cero candados, Pro solo al tocar una palabra. P10 una pantalla, una pregunta: escrita en cada apartado de §5. P11 técnico bajo el gesto: ritmo, 4:6, graves bajo pulsación larga. P12 sistema donde existe: hojas, indicador, TextField, intents, símbolos; propios solo la Frase y la Regla.

---

# Segunda parte · Interacción

**Diseño de interacción del equipo Silencio · 16 de noviembre de 2026.** Esta parte amplía el concepto sin reescribirlo: donde la primera parte dice *qué* hay en pantalla, esta dice *qué pasa* cuando alguien lo usa, con un dedo, a oscuras, con VoiceOver o sin poder hacer gestos. El plan de funciones priorizado (`docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md`) seguía sin existir al escribirla: se diseña para el alcance del encargo y se marca con **[1.1]** lo que el estudio propone dejar fuera del primer lanzamiento (Watch, Focus de Sueño, Salud en la Marea, «más cálido ⟷ más lejano»). Las medidas son para 393 × 852 en tamaño Large; los textos van en español con el inglés entre paréntesis y se recogen completos en §17.

Regla de lectura de todos los flujos: **ningún paso exige mirar** salvo los que ocurren de día (comprar, guardar, leer «Qué sabemos»). Cada paso dice qué se ve, qué se oye y qué se siente, porque de noche el orden de importancia es el inverso al habitual: primero el oído, luego la mano, por último el ojo.

## 12. Flujos completos

### 12.1 Primera noche, sin tutorial

Situación: instalada hace un minuto, 23:08, en la cama con la luz apagada.

1. **Abre.** Pantalla 5.1 en 300 ms (arranque en frío; el motor se crea perezosamente). Se ve: «Lluvia en la ventana» no, porque la app no enseña nombres de noche hasta que el usuario guarda una: se ve la frase que describe lo cargado, «Lluvia y marrón», y debajo en `texto2` «45 min · Marea». La Regla tenue al 50 % (volumen de fábrica). Bajo la Regla, la única línea del primer día: «7 noches con todo. Sin tarjeta.» El glifo `play.fill`. Bajo él, el tip: «Toca para empezar. Arrastra arriba o abajo para el volumen.» Pie: «Noches» · «Más». Nada se mueve. Nada pide nada.
2. **Toca en cualquier parte** (el 92 % de las personas de la prueba de pasillo tocan el glifo; da igual). Se oye: la lluvia y el marrón suben de 0 en 800 ms (`.easeOut`, el mismo fundido que el DSP). Se siente: `.impact(.medium, 0,7)` una vez, al inicio del fundido. Se ve: la Regla pasa de `texto3` a `brasa` y crece desde 0 hasta el 50 % en los mismos 800 ms; el glifo se funde a `pause.fill`; la frase se recompone a «Lluvia y marrón · 45 min» (sin «Marea», que no está activa; el tramo «Marea» pasa a segunda línea en `texto2`, porque sigue siendo algo que *haría*); el tip desaparece (primera reproducción cumplida; TipKit lo marca como invalidado).
3. **Está alto.** Arrastra hacia abajo con el pulgar, desde donde esté. Se oye: el nivel baja en tiempo real (1 pt = 0,5 %). Se ve: la Regla se acorta bajo el dedo; a la derecha de su extremo, 250 ms después de empezar, «38 %» en Secundario. Se siente: nada hasta que llega al 0 (`.selection`) o al 100 (`.impact(.light)`); no llega. Suelta: la cifra se desvanece en 1 s. El tip del volumen también queda cumplido.
4. **Quiere más tiempo.** No sabe que puede arrastrar en horizontal; lee «45 min» y lo toca. Se abre la hoja Temporizador (5.6) en `.medium`, con el indicador del sistema. Toca «Hasta dormirme» y arrastra en la fila hacia la derecha: «45 → 60 min», detente `.selection` cada 15. Cierra con el gesto o con «Listo». La frase dice «Lluvia y marrón · 60 min». *Segunda noche*, el tip único del día dos dirá: «Arrastra a los lados para el temporizador. Dos dedos abren el mezclador.»
5. **Deja el iPhone en la mesilla, pantalla arriba.** A los 20 s sin tocar, transición de 1,5 s de opacidad a Noche (5.7): la frase, el glifo y el pie se apagan; aparecen «60 min» en Cifra y «23:11» debajo; la Regla (ahora en `texto`, 3 pt) baja desde los 335 pt a los 500 pt con un fundido cruzado, no con un desplazamiento. Si el usuario bloquea antes: la Live Activity aparece en la pantalla de bloqueo; al desbloquear más tarde, la app vuelve directamente a Noche si sigue sonando.
6. **Se duerme.** A los 50 min la frase (si la pantalla está encendida) dice «se apaga en 10 min» y el glifo pulsa; en Noche la Cifra sigue bajando y nada más cambia (sin pulso: en Noche no hay glifo). A los 60 min, el sonido se ha fundido durante los últimos 10 (curva del DSP: primero bajan los agudos de la lluvia, después el nivel). La Regla se apaga en 1,5 s. La Live Activity termina con `.immediate`. Ningún háptico, ningún sonido, ninguna notificación.

Lo aprendido sin leer: toque = suena/para; arrastre vertical = volumen; el tiempo es una palabra tocable; la app se apaga sola. Lo no aprendido todavía: horizontal, dos dedos, pulsación larga. Ninguno es necesario para dormir la primera noche.

### 12.2 Sesión normal (noche quinta)

1. Abre (o toca «Dormir» en Atajos, o el control del Centro de control, o el widget). Si entra por un intent, la app no se abre: suena, y la Live Activity lo dice.
2. En la app: 5.1 con la última mezcla y el último temporizador. Un toque: suena. Frase activa.
3. Pulsación larga (0,6 s) en cualquier punto: la Marea se enciende. Se oye: el oleaje de la mezcla empieza a hincharse y retirarse a 12 por minuto (la ola es la modulación de la textura que ya suena, no un sonido nuevo). Se siente: `.impact(.medium)` una vez. Se ve: la Regla empieza a avanzar y retirarse entre el 60 % y el 100 % de su longitud; la frase añade «· Marea en 12 → 6». Sin segunda pantalla: la pulsación larga no abre nada.
4. 20 s después: Noche. El iPhone a la mesilla. La Regla respira en `texto`. La Cifra, la hora. Fin.

Tres gestos, ninguna lectura. Tiempo desde el desbloqueo hasta dejar el iPhone: 8-12 s en la prueba interna.

### 12.3 Ajustar una capa a oscuras

Situación: 00:40, suena «lluvia 65 · marrón 40», la lluvia molesta.

1. **Con gestos.** Toque con dos dedos en la principal (o en Noche: también funciona, y la pantalla vuelve a la principal al soltar el mezclador). Aparece el Mezclador (5.3) con 250 ms de opacidad. Once filas; las dos que suenan tienen una línea con longitud y su luz es la envolvente de esa capa, así que **se encuentran por brillo** sin leer: la fila de Lluvia parpadea con las gotas, la de Marrón respira lenta. El dedo baja hasta la fila que late rápido y arrastra a la izquierda. Se oye: la lluvia baja mientras arrastra. Se ve: la línea de la fila se acorta; «65 → 40» a la derecha; el subtítulo «lluvia fina» aparece bajo el nombre durante el arrastre. Se siente: nada (no cruza el 0). Suelta. Otro toque con dos dedos o arrastre hacia abajo: el mezclador se va. La frase de la principal no cambia (sigue siendo «Lluvia y marrón»), la Regla maestra sí refleja el nivel sumado.
2. **Sin gestos.** Toca el tramo «Lluvia y marrón» de la frase: mismo mezclador. Toca la fila «Lluvia»: aparece bajo la fila, durante 4 s, una línea de dos palabras «menos · más» en Encabezado, cada una con 64 pt de alto y la mitad del ancho; cada toque mueve 5 %. «Listo» cierra.
3. **Con VoiceOver.** Magic Tap no hace falta; en la frase, el rotor llega a «Lluvia y marrón, botón, abre el mezclador». Doble toque. Encabezado «Mezclador». Deslizar a la derecha hasta «Lluvia, 65 por ciento, ajustable». Deslizar arriba/abajo: «60 por ciento», «55 por ciento»… El sonido baja en cada paso; VoiceOver atenúa la cama (`duckOthers`) y la cama vuelve a su nivel 1 s después de cada anuncio. Escape de Z para salir.
4. **Pulsación larga en la fila [1.1]**: segunda línea «más cálido ⟷ más lejano»; arrastre horizontal en esa línea mueve el corte de agudos (hacia «lejano») o de graves (hacia «cálido») del motor para esa capa; con VoiceOver es un segundo elemento ajustable «Timbre de lluvia, neutro». La fila recupera su altura al soltar durante 4 s.

### 12.4 Activar la Marea: quince minutos y la disolución

Dos entradas: la pulsación larga (enciende con los últimos ajustes; no abre nada) y la palabra «Marea» de la frase (abre 5.4 para ajustar antes de empezar). Se describe la segunda, que es la completa.

**Antes.** 5.4: la frase «Marea», el texto de dos líneas, la Regla de 3 pt en reposo y cuatro filas. El usuario arrastra en «Ritmo» de 6 a 5: la Regla de la pantalla hace **una** respiración de muestra al nuevo ritmo (avanza 4,8 s, se retira 7,2 s) para que se oiga/vea sin empezar. «Dura» a 15. Toca «Empezar».

**Minuto 0-4 (descenso).** Se oye: la textura entera (no solo el océano: la lluvia y el marrón también) empieza a hincharse y retirarse; el primer ciclo dura 5 s (12 por minuto: el ritmo de alguien despierto y tenso) y cada ciclo siguiente es un poco más largo hasta llegar a los 10-12 s del ritmo elegido en el minuto 4. La exhalación siempre es más larga (4:6): el oleaje sube rápido y se retira despacio. Se ve (si mira; 5.5): «Marea» y, debajo, «Guiando · 12 → 5 · 15 min»; la Regla de 3 pt en `brasa` avanzando y retirándose con la curva exacta del audio (misma `BreathCurve`, misma fase, compensada la latencia de AirPlay con el ancla); la Cifra «11» en `texto2` con «por minuto, bajando a 5» debajo, que baja de uno en uno. Se siente (opcional, «Háptica de la Marea · mínima», solo si el iPhone está en la mano según CoreMotion): un patrón continuo de Core Haptics cuya intensidad sigue la curva, nitidez 0,2, **solo durante las primeras cinco respiraciones**; después se retira para que el usuario suelte la pantalla. En «marcada», además un transitorio suave al inicio de cada inhalación durante toda la guía; en el Watch **[1.1]**, el mismo transitorio en la muñeca.

**Minuto 4-12 (guiando).** Ritmo estable. La Cifra ha desaparecido (ya no informa de un cambio). Si no se ha tocado la pantalla en 20 s, está en Noche: la Cifra del temporizador, la hora y la Regla respirando en `texto`. Si no hay temporizador, la Cifra de Noche es «Marea» en Frase y, debajo en Secundario, «9 min». Nada más se mueve. El oleaje sigue acompasado.

**Minuto 12-15 (disolución).** Se oye: la profundidad de la modulación baja de forma lineal hasta cero en tres minutos; el sonido no para: deja de respirar y queda liso, como estaba antes. Se ve: la Regla reduce su recorrido (del 60-100 % al 100 % fijo) a la vez; la frase dice «Marea se retira» ("Tide fading") y, al terminar, el tramo desaparece. Se siente: nada. La sesión de audio no se interrumpe; la Live Activity se actualiza una vez («se retira») y otra al terminar.

**Si el usuario quiere parar antes**: pulsación larga en cualquier punto (en la principal, en Noche o en 5.5) o «Parar» en 5.5. La disolución se acorta a 20 s, nunca a cero: la Marea nunca se corta.

**Si se activa de madrugada** (Modo Madrugada, 12.7): la Marea arranca directamente a 6, sin descenso desde 12: a las 3 de la mañana ya se respira despacio y el descenso sería una subida.

### 12.5 Temporizador de tres modos

Entrada: tramo «45 min» (o «toda la noche») de la frase; o arrastre horizontal en la principal/Noche (cambia la duración del modo activo sin abrir nada: 1 pt = 15 s, detente cada 15 min, la frase o la Cifra muestran el valor en vivo).

Hoja 5.6, `.medium`. Cuatro filas: «Hasta dormirme», «Escudo nocturno», «Siesta», «Sin temporizador». La activa en `texto`; tocar otra la activa (fundido de 200 ms del color); arrastrar en una fila cambia su valor sin activarla.

- **Hasta dormirme · 45 min** (15-90, pasos de 5). Fundido en los últimos 10 min: baja primero el brillo espectral (agudos), después el nivel. La frase: «se apaga en 8 min». Gratuito tras la prueba: hasta 60; al arrastrar más allá, el valor sigue el dedo pero aparece «Pro» en versalitas junto a él y, al soltar, se queda en 60 y se abre Pro. El dedo nunca se bloquea; el valor sí.
- **Escudo nocturno · hasta las 7:00** (hora fija; arrastrar mueve la hora en pasos de 15 min; pulsación larga: «sigue la alarma de Reloj» como alternativa, que lee la próxima alarma activa si el usuario lo permite **[1.1]**). Secundario bajo el valor: «baja de nivel al amanecer» ("eases at dawn"): −30 % desde dos horas antes de la hora fijada. La cama suena toda la noche; la Live Activity se renueva cada 8 h (límite de ActivityKit) sin que el usuario lo note, y si no se puede renovar, desaparece de la pantalla de bloqueo pero el sonido sigue (se documenta como límite de la plataforma). Pro.
- **Siesta · 20 min** (10/20/30). Fundido en los últimos 3. Es el único modo en el que la frase de la principal dice la hora de fin además de los minutos («Siesta · hasta las 15:20»), porque de día se piensa en horas.
- **Sin temporizador.** La frase dice «toda la noche». Nota de pie de la hoja, siempre: «El sonido se desvanece antes de que termine. Tu alarma suena igual.»

Nunca: cuenta atrás en segundos (el usuario no está mirando), sonido al terminar, háptico al terminar.

### 12.6 Pantalla Noche y vuelta

**Entrar.** Tres caminos, los tres sin nada que buscar: (a) automático, 20 s sin tocar mientras suena; (b) bloquear y desbloquear mientras suena; (c) palabra «Noche» en el pie, o arrastre hacia abajo en la principal (≥ 80 pt, empezando a ≥ 60 pt del borde superior para no competir con el Centro de notificaciones).

**Dentro.** 5.7. Lo único que cambia con el tiempo: la Cifra cada minuto, la hora cada minuto, la Regla si respira. El brillo no se toca. La barra de estado se oculta. Con Always-On (`isLuminanceReduced`) la Regla se congela en su posición media en ≤ 2 s y la Cifra pasa a actualizarse a 1 Hz.

**Gestos dentro.** Toque (≥ 80 ms, ignorado boca abajo o con el sensor de proximidad tapado) en los dos tercios superiores: pausa con fundido de 1,5 s; la Cifra se funde a «En pausa» ("Paused"); otro toque reanuda con fundido de 800 ms. Arrastre vertical: volumen (la Regla cambia de longitud; sin cifra: de noche no hay números pequeños). Arrastre horizontal: temporizador, la Cifra cambia en vivo. Pulsación larga: Marea. Sin hápticos en ninguno: la confirmación es lo que se oye.

**Volver.** «Volver» (banda de 64 pt a todo el ancho en el tercio inferior) o arrastre hacia arriba desde cualquier punto. Transición de 1,5 s de opacidad a la principal en su estado activo. Si se vuelve y no se toca nada, a los 20 s regresa a Noche. Si se pausa en Noche y se vuelve, la frase dice «· en pausa». Al bloquear desde Noche: nada que hacer; al desbloquear, Noche otra vez.

**Con VoiceOver.** Un único elemento raíz, foco automático al entrar: «Sonando, 38 minutos restantes, 3 y 12 de la madrugada. Toca dos veces para pausar.» Acciones en el rotor: «Quince minutos más», «Quince minutos menos», «Marea», «Volver». Magic Tap pausa. El escape de Z vuelve.

### 12.7 Modo Madrugada desde el bloqueo

Situación: 03:41, la sesión terminó a la 1:10, el iPhone en la mesilla, StandBy en rojo o pantalla apagada.

1. **Levanta o toca el iPhone.** Pantalla de bloqueo. La Live Activity de la sesión terminada **sigue ahí** hasta 4 h después de acabar (se mantiene con contenido final, no se descarta): «Lluvia y marrón · terminó a la 1:10» en una línea y, a la derecha, un solo botón de texto de 44 × 64: «20 min». En StandBy la misma actividad, en rojo, con el botón a doble tamaño. Si la Live Activity ya expiró (más de 4 h), el camino es abrir la app: entre la 1:00 y las 5:00 con la sesión parada, la app abre directamente en Madrugada en lugar de en la principal.
2. **Toca «20 min».** Es un `AudioPlaybackIntent`: no abre la app. Se oye: la última mezcla sube de 0 al 70 % de su volumen guardado en 800 ms, ya con la Marea a 6 por minuto (sin descenso). Se ve, en la pantalla de bloqueo: la actividad se actualiza a «Lluvia y marrón · 20 min» con la Regla respirando congelada (ActivityKit no anima; la Regla se dibuja al 80 %). Se siente: nada. La pantalla se apaga sola con el bloqueo automático.
3. **Si desbloquea** (quiere mirar): la app abre en 5.8, no en la principal: Cifra «20 min» bajando, la hora, la Regla respirando en `texto`, «Parar» en el tercio inferior. Mismos gestos que Noche. Ninguna frase, ninguna palabra «Pro», ningún pie con «Noches»/«Más». Si la última mezcla tenía Océano y la prueba terminó, suena sin Océano y **no lo dice**: a las 3:41 nadie debe leer «sin océano». Lo dirá la principal por la mañana.
4. **Minuto 17-20.** La Marea se disuelve y el nivel baja a cero a la vez (son los mismos tres minutos). La Regla se apaga en 2 s. La actividad termina con `.immediate` y vuelve a quedarse como «terminó a las 4:01 · 20 min» por si hace falta otra vez.
5. **Repetir.** Si el usuario vuelve a tocar «20 min» antes de las 5:00, igual. Sin límite y sin contador: la app no sabe ni dice cuántas veces se despertó.

Lo que se descarta a propósito: un botón «+20» *durante* la madrugada (prolongar = volver a tocar al terminar), cualquier texto que no sea la cifra y «Parar», y la pregunta «¿cómo has dormido?» por la mañana.

### 12.8 La prueba caduca mientras suena, y después

Regla: **el fin de la prueba nunca cambia nada mientras hay una sesión en curso.** La séptima noche se cuenta hasta que la sesión de esa noche termina (fundido completo) o hasta las 12:00 del día siguiente, lo que llegue después.

1. **Noche 7, 23:30.** Bajo la Regla: «Prueba · última noche» ("Trial · last night"). Nada más cambia. Si toca la línea, se abre 5.10 con la frase «Última noche con todo.» y la lista de lo que sigue gratis.
2. **Noche 7, 03:00.** Todo igual. Océano suena. Madrugada funciona con Océano. Ningún texto.
3. **Día 8, 09:10, abre la app.** Principal en reposo: la frase dice «Lluvia y marrón · sin océano» (la última mezcla tenía océano); el tramo «sin océano» en `texto2`. Bajo la Regla, una sola vez y durante ese día: «La prueba ha terminado. Blanco, rosa, marrón, lluvia y 60 minutos siguen gratis.» ("Trial over. White, pink, brown, rain and 60 minutes stay free.") en Nota, que al tocarse abre Pro y que al día siguiente desaparece sola. Pie igual. Sin hoja al abrir, sin cápsula, sin cuenta atrás.
4. **Día 8, toca para sonar.** Suena sin océano, al mismo volumen. Si toca «sin océano»: océano suena 30 s al 50 % mezclado con el resto, la frase pasa a «Océano · 30 s de prueba» con los segundos bajando, y al terminar se funde en 1,5 s y se abre 5.10 con el precio en la primera línea. Si cierra la hoja, la frase vuelve a «sin océano». Esta prueba de 30 s se puede repetir sin límite diario (el límite sería un castigo; el coste es cero).
5. **Día 8, abre el Temporizador.** «Hasta dormirme» sigue en 45; si antes tenía 90, ahora dice «60 min» y, a la derecha, «antes 90 · Pro» en versalitas una sola vez. «Escudo nocturno» con «Pro». La Marea: la fila «Marea» de la frase sigue abriendo 5.4 completa; «Empezar» lleva «Pro» a la derecha y abre 5.10. El resto de la pantalla es idéntico.
6. **Noches guardadas**: todas se conservan; las que tengan capas Pro muestran en su segunda línea «· sin océano» cuando se cargan (12.10).

Cero candados en todo el recorrido. Conteo de la palabra «Pro» en la principal: cero (vive en «sin océano», que es una descripción, no una etiqueta).

### 12.9 Compra y restauración

1. **Entrada.** Cualquier palabra «Pro», «sin océano» tras sus 30 s, «Más › Pro», o la línea del día 8. Nunca sola, nunca al abrir, nunca encima del sonido (si suena, sigue sonando bajo la hoja y la Regla de la principal sigue en `brasa` *debajo* de la hoja negra: la hoja no la tapa del todo porque es `.large`, no pantalla completa; «Comprar · 29,99 €» es el único acento *de la hoja*).
2. **Hoja 5.10.** Lee de arriba abajo en el orden en que se pregunta: cuánto («Una vez.» / «29,99 €»), qué gano, qué sigue gratis, comprar, restaurar, legal. El precio viene de `Product.displayPrice`; hasta que StoreKit responde (≤ 1 s habitualmente) la frase dice «Una vez.» y el botón «Comprar» sin cifra en `texto2`, no en `brasa`: el acento solo aparece cuando hay precio. Si StoreKit no responde en 5 s: bajo el botón, en Cuerpo `texto2`, «No se ha podido cargar el precio. Inténtalo con conexión.» ("Couldn't load the price. Try again with a connection.") y el botón se queda en `texto2`. El sonido no se entera.
3. **Toca «Comprar · 29,99 €».** Opacidad 0,6 por 200 ms; el texto pasa a «Comprando…» en `texto2`; la hoja del sistema de App Store aparece encima (Face ID). Durante la espera nada gira: el texto basta.
4. **Éxito.** La hoja de App Store se cierra; la nuestra se cierra sola 400 ms después (el usuario debe ver que el estado cambió: entre medias el botón dice «Gracias» en `texto` durante esos 400 ms). En la principal: la línea de prueba desaparece; si la frase decía «sin océano», ahora dice «Lluvia, marrón y océano» y el océano entra con un fundido de 2 s. Háptico `.success` (está despierto y con luz; es la única notificación háptica de la app). En «Más»: «SleepNoise Pro · Gracias · 16 de noviembre de 2026».
5. **Cancelación.** El botón vuelve a «Comprar · 29,99 €». Nada más. Sin «¿seguro?».
6. **Error.** Línea bajo el botón, 17 Medium `.red`: «No se ha completado la compra. No se te ha cobrado.» ("The purchase didn't go through. You haven't been charged.") más el motivo de StoreKit en Nota `texto2` si lo hay. Háptico `.error` solo aquí. El botón vuelve a su estado.
7. **Pendiente** (aprobación familiar): el botón dice «Pendiente de aprobación» ("Awaiting approval") en `texto2` y la hoja se puede cerrar; al llegar la transacción, la app se actualiza sin aviso.
8. **Restaurar.** «Restaurar compra» → «Restaurando…» → (a) encontrado: igual que éxito; (b) nada: «No hay ninguna compra en esta cuenta de Apple.» ("No purchase on this Apple Account.") en Cuerpo `texto2` bajo el botón, sin rojo (no es un error del usuario). Family Sharing: la compra de otro miembro aparece por `Transaction.currentEntitlements` al abrir, sin pulsar nada; si por lo que sea no ha llegado, «Restaurar» la trae.
9. **Después.** Ninguna mención a Pro en ninguna pantalla, salvo la línea de «Más». Las siete capas, el escudo, la Marea y las noches ilimitadas aparecen *sin anunciarse*: simplemente la palabra «Pro» ya no está en ningún sitio.

### 12.10 Mezcla guardada que pierde capas Pro

Situación: usuario gratuito, día 9, abre Noches y toca «Domingo de tormenta» (lluvia 50 · trueno 30 · marrón 20 · 60 min).

1. **En la lista** (5.9): la fila existe completa; su segunda línea dice «lluvia 50 · trueno 30 · marrón 20 · 60 min» y, al final, «· trueno es Pro» en `texto2`. Sin atenuar la fila, sin icono.
2. **Toca.** Carga y reproduce con fundido cruzado de 2 s **sin el trueno**. La frase de la principal: «Lluvia y marrón · 60 min · sin trueno». La Regla maestra refleja el nivel real (menos sumado). La noche guardada **no se modifica**: el trueno sigue en ella al 30 y volverá si compra.
3. **Si guarda encima** («Guardar esta noche» con el mismo nombre): se guarda lo que suena (sin trueno) y la app lo dice en la fila de guardado durante 3 s: «Guardada sin trueno» ("Saved without thunder"), para que no crea que ha perdido la capa sin saberlo. Alternativa a un toque en la misma línea: «Conservar el trueno» ("Keep thunder"), que guarda la mezcla completa aunque ahora no suene.
4. **Noche de fábrica «Avión»** (cabina 55 · rosa 25; Pro): se carga como «Rosa · sin cabina». Es casi silencio, y se nota: por eso la segunda línea de la fila ya avisa «cabina es Pro» antes de tocar.
5. **Con VoiceOver**: «Domingo de tormenta, botón. Lluvia 50, trueno 30, marrón 20, 60 minutos. Trueno requiere Pro; sonará sin él.»

### 12.11 Interrupción por llamada y pausa de AirPods

**Llamada entrante (o Siri, o alarma del sistema).** `AVAudioSession.interruptionNotification` → `.began`: la cama se funde en 300 ms (no en 1,5 s: la llamada ya está sonando). La Regla se apaga en 300 ms; la frase, si se ve, «· en pausa»; la Live Activity pasa a `play.fill`. Al terminar (`.ended` con `.shouldResume`): la cama vuelve en 800 ms, la Regla también, la frase recupera su forma. Si el usuario rechazó la llamada con el iPhone en la mesilla, no ha visto nada: el sonido se fue y volvió. El temporizador **no se pausa** (la noche sigue; una llamada de 3 min no debe dejar la cama sonando 3 min más de la cuenta). La Marea, si estaba guiando, se reanuda en la misma fase del ciclo en la que estaba (no desde la inhalación: el cuerpo no se paró).

**Alarma del sistema**: idéntico; con «Escudo nocturno», al terminar la alarma la cama **no vuelve** (son las 7:00; la noche acabó) y la actividad termina.

**Pausa de AirPods al dormirse (iOS 26)** o al quitarse un auricular (`.oldDeviceUnavailable`): la cama se funde en 3 s (no es una interrupción brusca: es el usuario durmiéndose), la interfaz en 2 s (termina antes, para no dejar nada moviéndose). La frase: «· en pausa · AirPods» ("· paused · AirPods") la próxima vez que se mire. El temporizador sigue. Si vuelve a ponerse el auricular en < 10 min, la cama vuelve sola (800 ms); si no, queda en pausa y la Live Activity ofrece `play.fill`. Nunca se pasa el audio al altavoz sin que el usuario lo pida: despertaría a la pareja.

**Cambio de ruta a AirPlay/HomePod**: la latencia de salida (hasta 2 s) se lee de `outputLatency` y la Regla retrasa su fase esa cantidad para que lo que se ve coincida con lo que se oye; la Marea háptica se desactiva en esa ruta (no se puede sincronizar con 2 s de retraso).

### 12.12 Error de audio

Casos: la sesión no se puede activar (otra app la retiene en modo exclusivo), el motor falla al arrancar, o se detiene a mitad de la noche por *media services reset*.

1. **Al arrancar.** El usuario toca; no suena. En 1 s, en lugar de la Regla en `brasa`, la Regla sigue en `texto3` y bajo ella aparece en 17 Medium `.red` (el único rojo de la app): «El sonido no ha podido empezar.» ("Sound couldn't start.") y, debajo, en Cuerpo `texto2`: «Otra app puede estar usando el audio. Toca para intentarlo otra vez.» ("Another app may be using audio. Tap to try again.") El glifo sigue en `play.fill`. Un toque reintenta; tres fallos seguidos añaden «Reiniciar el iPhone suele resolverlo.» Nada parpadea, nada vibra (`.error` no: el usuario está en la cama), ninguna hoja.
2. **A mitad de la noche** (*media services reset*): el motor se reconstruye solo y reanuda en < 2 s con fundido de 800 ms; si lo consigue, el usuario no se entera y la app lo anota en el registro local. Si no lo consigue en 10 s: la Live Activity pasa a «Lluvia y marrón · se detuvo a las 2:14» ("· stopped at 2:14") con `play.fill`; la app, al abrirla, muestra el mensaje de arriba con la hora. Sin notificación push: no hay.
3. **Con VoiceOver**: el mensaje se anuncia una vez como `AccessibilityNotification.Announcement` con prioridad alta; el glifo mantiene su etiqueta «Reproducir».
4. **En Noche o Madrugada** no se muestra el rojo: la Cifra se funde a «Sin sonido» ("No sound") en Frase y un toque reintenta. El rojo es para la principal, donde hay luz para leerlo.

## 13. Especificación de movimiento

Causa física, elemento, señal del motor, duración, curva, Reduce Motion, Always-On/StandBy. Lo que no está en esta tabla no se mueve.

| Elemento | Qué cambia | Causa (señal) | Duración · curva | Reduce Motion | Always-On / StandBy |
|---|---|---|---|---|---|
| Regla · arranque | longitud 0 → volumen; color `texto3` → `brasa` | fundido de entrada del DSP (ganancia maestra) | 800 ms · `.easeOut` | igual (es un fundido) | n/a (no se arranca ahí) |
| Regla · parada / fin | color `brasa` → `texto3`; opacidad → 1 fija | fundido de salida (ganancia maestra) | 1.500 ms · `.easeInOut` (300 ms en interrupción) | igual | la actividad se actualiza una vez; nada anima |
| Regla · luz | opacidad 0,45-1 | RMS maestro suavizado τ 500 ms, 20 Hz | continua; sin curva (sigue la señal) | 4 Hz, τ 1.500 ms | **congelada** en 0,7 en ≤ 2 s (`isLuminanceReduced`); estática en LA/widget |
| Regla · volumen bajo el dedo | longitud | posición del dedo → ganancia maestra | 0 ms (60 fps, sin animación implícita) | igual | n/a |
| Regla · Marea | longitud 60-100 % del volumen | `BreathCurve` del audio (misma función, misma fase, ancla de latencia) | 7,5-15 s por ciclo, 4:6 · la curva del audio (no `sin`) | longitud fija al 100 %; opacidad ±25 % con la misma curva | congelada en la posición media; en LA se dibuja al 80 % |
| Regla · disolución de la Marea | recorrido 40 % → 0 | profundidad de modulación del DSP | 180 s lineal (20 s si se para a mano) | igual | igual |
| Regla de capa (mezclador) · luz | opacidad | RMS de *esa* capa | como la maestra | como la maestra | n/a |
| Glifo play ↔ pause | sustitución | estado de reproducción | 250 ms · `.symbolEffect(.replace)` (fundido) | igual (ya es fundido) | estático; forma distinta |
| Glifo · pulso en fundido final | escala sutil del sistema | ganancia bajando (últimos 10 min) | `.pulse` del sistema, repetitivo | **off** | n/a |
| Frase · cambio de tramos | opacidad de cada tramo; reflujo de línea | estado (temporizador, Marea, pausa) | 250 ms · `.easeInOut`; sin desplazamiento (los tramos se funden, el texto no se mueve) | igual | n/a |
| Frase · minutos | dígitos | temporizador | `.numericText()` 250 ms; `monospacedDigit` evita el baile | sustitución sin transición | n/a |
| Cifra «64 %» junto a la Regla | aparece / desaparece | dedo en pantalla | 250 ms entrar; 1.000 ms salir tras soltar · opacidad | igual | n/a |
| Principal ↔ Noche | opacidad cruzada de dos capas | 20 s sin tocar; bloqueo; «Noche»/«Volver» | 1.500 ms · `.easeInOut` | igual | n/a |
| Mezclador / Marea (superposiciones) | opacidad | dos dedos; toque en tramo | 250 ms · `.easeInOut` | igual | n/a |
| Hojas del sistema | las del sistema | — | sistema | sistema | n/a |
| Tramo pulsado | opacidad 0,6 | toque | 200 ms · `.easeInOut` | igual | n/a |
| Cifra de Noche · minuto | dígitos | `TimelineView(.everyMinute)` | sin animación: cambio seco (a oscuras, un fundido es movimiento) | igual | 1 Hz |
| Live Activity · cambios de estado | contenido | inicio, pausa, hito de 15 min, fundido, fin | sistema; `.immediate` al terminar | sistema | nada se mueve nunca |
| Fundido cruzado entre noches | ganancias de capa | carga de una noche | 2.000 ms · `.easeInOut` (audio y Regla a la vez) | igual | n/a |

Principios que se derivan: (1) nada cambia de **posición** jamás, solo de longitud, opacidad o contenido; por eso Reduce Motion casi no tiene trabajo; (2) toda duración de interfaz es igual o más corta que la del audio al que acompaña, nunca más larga; (3) solo dos cosas son continuas (luz de la Regla y Marea) y ambas se pausan cuando no suena nada, cuando la escena no está activa, bajo `isLuminanceReduced` y en Noche la luz (la Marea sigue en Noche porque es la guía); (4) ninguna animación finita supera los 2 s salvo la disolución, que es audio.

Presupuesto: `TimelineView(.periodic(1/20))` sobre un `Canvas` de una sola cápsula para la luz; `KeyframeAnimator` con 24 claves por ciclo resincronizado con `guide.anchor` para la Marea; todo lo demás Core Animation. Cero fotogramas con la pantalla apagada, medido con Instruments 10 min bloqueado.

## 14. Háptica

La háptica es la segunda confirmación de noche (la primera es el sonido) y la única con los ojos cerrados y auriculares puestos. Se gasta en cinco sitios y se niega en el resto.

| Momento | Patrón | Condición | Equivalente VoiceOver |
|---|---|---|---|
| Arrancar sesión (toque en la principal) | `.impact(.medium, 0,7)` una vez, al inicio del fundido | solo en la principal; nunca en Noche/Madrugada | «Sonando» |
| Pausar (toque) | `.impact(.light, 0,5)` | solo en la principal | «En pausa» |
| Volumen cruza 0 / llega a 100 | `.selection` / `.impact(.light, 0,6)` | principal y mezclador; no en Noche | «Silencio» / «Máximo» |
| Temporizador: detente de 15 min en el arrastre | `.selection` | principal; no en Noche | el valor se anuncia |
| Encender la Marea (pulsación larga) | `.impact(.medium)` una vez; **nada al apagar** | principal y Marea; en Noche **no** | «Marea activada» |
| Guardar una noche | `.success` | hoja Noches (día) | «Guardada» |
| Compra completada | `.success` | hoja Pro | «Gracias» |
| Error de compra | `.error` | solo con la hoja Pro delante | el mensaje |
| Marea háptica (opt-in: mínima / marcada) | Core Haptics continuo, intensidad = `BreathCurve`, nitidez 0,2, 5 respiraciones; «marcada»: + transitorio al inicio de cada inhalación toda la guía | solo con el iPhone en la mano (CoreMotion: no quieto-horizontal); motor con `playsHapticsOnly`; se destruye al terminar | — (es la guía misma) |
| Watch **[1.1]** · Marea | `.directionUp` al inicio de cada inhalación; «mínima» = primeras 5; «marcada» = toda la guía | solo con la guía activa | — |
| Watch **[1.1]** · play/pausa | `.click` / `.stop` del sistema | — | — |

Nunca: al terminar el temporizador, al disolverse la Marea, al caducar la prueba, al abrir el paywall, en Noche y Madrugada (ni al tocar), con el iPhone quieto y horizontal (está en la mesilla: vibrar es sonido), en segundo plano, ni en Live Activity o widget (no es posible y no se querría). Cada háptico tiene su anuncio de VoiceOver (`AccessibilityNotification.Announcement`) para que la confirmación no dependa del canal.

## 15. Superficies del ecosistema, dibujadas en palabras

Gramática común: una línea por sesión; una sola tinta (`texto`); formas ≥ 3 pt; estado por forma (`play.fill`/`pause.fill`, Regla larga/punto); nada se mueve; `brasa` no existe fuera de la app salvo como tinte que el sistema aplica al control del Centro de control. Todo comparte un verbo (`AudioPlaybackIntent` «Reproducir/Pausar SleepNoise») y dos más («Quince minutos más», «Veinte minutos»).

### 15.1 Live Activity y Dynamic Island

- **Compacta** (Isla, dos extremos): izquierda `pause.fill` 14 pt `texto`; derecha «42» tabular 14 Semibold. En pausa: `play.fill` y «42» igual (el tiempo no corre en pausa… sí corre: el temporizador sigue; la cifra sigue bajando: es honesto). Sin Marea: nada más (la Isla no tiene sitio para respirar y no respiraría).
- **Mínima** (otra actividad ocupa la Isla): solo el glifo.
- **Expandida** (pulsación larga en la Isla), 371 × 160: fila superior izquierda «Lluvia y marrón» (17 Semibold) y debajo «se apaga a las 03:54» (15); derecha «42 min» (22 Medium tabular) y el glifo de 44 × 44 como botón. Fila inferior: la Regla de 3 pt a todo el ancho de la isla, longitud = volumen, que es el botón «Quince minutos más» (44 pt de alto táctil, invisible). Bajo ella, dos palabras de 13 Medium `texto`: «Noche» (abre 5.7) a la izquierda y «Marea en 6» o nada a la derecha (texto, no botón). Fondo negro, `activityBackgroundTint(.black)`, sin borde propio.
- **Pantalla de bloqueo**, 393 × 84: la composición de la expandida sin la fila de palabras. Sesión terminada: «Lluvia y marrón · terminó a la 1:10» y, a la derecha, el botón de texto «20 min» de 44 × 64 en lugar de la cifra y el glifo. Es el único lugar donde aparece un botón que no es un glifo, porque es la acción de la madrugada y hay que poder darle a ciegas.
- **StandBy nocturno**: la de bloqueo escalada ×2 con el tinte del sistema; se diseñó en rojo primero: `texto` → ≈ `#E80000` (4,43:1), cifra 44 pt Medium, Regla 6 pt, glifo 56 pt. Al tocar, pantalla completa: la misma composición, nada añadido. La Regla no respira (ActivityKit no anima); se dibuja en la posición media y la etiqueta lo dice («Marea en 6»).
- **Actualizaciones**: inicio, pausa/reanudación, cada 15 min, inicio del fundido, «se retira», fin (`.immediate`). Máximo 8 h: con «Escudo nocturno» se solicita una nueva actividad a las 7 h 50; si el sistema la rechaza, el sonido sigue sin actividad.
- **VoiceOver**: «SleepNoise, sonando, lluvia y marrón, 42 minutos, se apaga a las 3 y 54». Botones: «Pausar», «Quince minutos más».

### 15.2 StandBy (widget)

El widget pequeño en StandBy, en la misma gramática: «Lluvia y marrón» (17 Semibold), «42 min» (34 Rounded), Regla de 3 pt, glifo de 20 pt abajo a la derecha. Fondo removible: en StandBy nocturno el sistema lo pinta sobre negro en rojo monocromo. El widget entero es `Button(intent: PlayPause)`. Sin sesión: «SleepNoise» no; en su lugar la última noche: «Lluvia y marrón» y, donde iba la cifra, «Dormir» ("Sleep") en Encabezado: el widget siempre ofrece un verbo.

### 15.3 Widgets de pantalla de inicio y de bloqueo

- **Pequeño**: el de 15.2. Accented/vibrant (iOS 18+): la Regla toma el tinte; el texto no (`widgetAccentable` solo en la Regla).
- **Mediano**: izquierda, el pequeño; derecha, tres noches como palabras alineadas a la derecha (15 Medium `texto`, 44 pt de alto cada una, `Button(intent: PlayNight(id))`): la de fábrica primera y las dos últimas usadas. Al tocar una: suena esa noche con fundido cruzado; la columna izquierda se actualiza. Si una noche tiene capas Pro y la prueba acabó, suena sin ellas y la palabra no cambia (el widget no es sitio para decirlo).
- **Bloqueo, rectangular** (iOS 16+): «Lluvia y marrón · 42 min» en una línea de 15 Semibold y la Regla de 2 pt debajo; toda la zona abre la app en Noche. **Circular**: el glifo. **En línea**: «SleepNoise · 42 min».
- **Sin fondo** («quitar fondo» en StandBy, o pantalla de bloqueo): texto y Regla sobre lo que haya; por eso nada mide menos de 3 pt ni de 15 Medium.

### 15.4 Centro de control y botón de Acción (iOS 18+)

`ControlWidgetToggle` «SleepNoise»: símbolo propio `regla.on` (línea que entra desde la izquierda y ocupa dos tercios del ancho del símbolo) / `regla.off` (un tercio); el sistema tiñe *on* con `.tint(brasa)` (único lugar fuera de la app donde el acento existe, porque el sistema lo exige para distinguir *on*). Texto de valor: «Sonando» / «En silencio» ("Playing" / "Silent"). Un segundo control opcional, `ControlWidgetButton` «Veinte minutos» con `regla.on` y el intent de Madrugada, para quien prefiera el Centro de control a la Live Activity de noche. Botón de Acción: el toggle; *hint* «Mantén para dormir» ("Hold to sleep"). iOS 17: el Atajo «Dormir» lo cubre.

### 15.5 Apple Watch **[1.1]**

Una vista, 45 mm (198 × 242 pt): «42 min» en SF Compact Rounded 44 Medium tabular, centrado en el tercio superior; debajo, el glifo de 64 pt (`texto`); debajo, la Regla de 3 pt (`texto`) cuya longitud es el volumen y que respira si la Marea está activa. Toda la esfera es el botón play/pausa. Corona = volumen (la Regla cambia de longitud; «64 %» aparece 1 s junto a ella). Pulsación larga = Marea (háptico `.directionUp` al encender; apaga sin háptico). Deslizar a la izquierda: «Quince minutos más» como palabra de 44 pt. Sin lista, sin mezclador, sin noches: el Watch es el mando de la mesilla, no la app. Smart Stack: «Lluvia y marrón · 42 min» con la Regla y el glifo; sin complicación propia. Háptico de la Marea en la muñeca según 14. Sin tracking, sin HealthKit en el Watch.

### 15.6 Siri y Atajos

Frases (ES / EN), todas con `AudioPlaybackIntent` para que Siri no hable encima:
- «Dormir con SleepNoise» / "Sleep with SleepNoise": reproduce la última noche con su temporizador.
- «Pausa SleepNoise» / "Pause SleepNoise".
- «SleepNoise, quince minutos más» / "SleepNoise, fifteen more minutes".
- «SleepNoise, veinte minutos» / "SleepNoise, twenty minutes": Modo Madrugada.
- «Pon [Lluvia en la ventana] en SleepNoise» / "Play [Rain on the window] in SleepNoise": una noche por nombre (parámetro con las noches guardadas).
- «Marea en SleepNoise» / "Tide in SleepNoise": enciende la Marea con los últimos ajustes.
Acciones de Atajos: Reproducir noche (parámetro), Pausar, Añadir minutos (número), Marea (ritmo, duración), Modo Madrugada, Obtener estado (devuelve la frase: «Lluvia y marrón · 42 min · Marea en 6», útil para automatizaciones). Automatización sugerida en «Más › Atajos y Centro de control»: «Cuando se active Sueño → Dormir con SleepNoise», con el texto de dos párrafos y un botón «Abrir Atajos» que crea el borrador.

### 15.7 Focus de Sueño **[1.1]**

Focus filter «SleepNoise»: un solo parámetro, «Al entrar en Sueño: Noche directa» (sí/no). Con sí, mientras el Focus de Sueño está activo la app abre siempre en Noche (o Madrugada entre 1:00 y 5:00) y el pie de la principal se reduce a nada. No hay autoplay por el filtro (la plataforma no lo permite); la automatización de 15.6 lo hace. Se configura en Ajustes › Modos de concentración › Sueño › Filtros, y la app lo explica en «Más» con una línea y un botón que abre Ajustes.

## 16. Accesibilidad

### 16.1 Orden de VoiceOver y etiquetas por pantalla

**Principal.** Orden: (1) raíz de la frase, que al entrar en la pantalla se anuncia entera como resumen («Lluvia y marrón, 42 minutos, Marea en 6 por minuto. Sonando.»), y que contiene (1a) «Lluvia y marrón, botón. Abre el mezclador.», (1b) «42 minutos, botón. Temporizador. Acciones disponibles.» con acciones «Quince minutos más / menos», (1c) «Marea en 6, botón. Abre la Marea.» con acción «Apagar la Marea»; (2) «Volumen, 64 por ciento, ajustable» (la Regla; deslizar arriba/abajo ±5 %; acciones «Silenciar», «Máximo»; rotor «Gráfico de audio» con la envolvente de los últimos 10 s por capa); (3) «Prueba, quedan 5 noches, botón. Qué sigue gratis.»; (4) «Pausar, botón» / «Reproducir, botón» (el glifo); (5) «Noches, botón»; (6) «Noche, botón. Pantalla negra con el tiempo que queda.»; (7) «Más, botón». Magic Tap desde cualquier foco: reproducir/pausar. El toque de pantalla completa **no existe con VoiceOver** (el gesto de VoiceOver lo consume): el glifo y Magic Tap lo sustituyen. La pulsación larga tampoco: la acción «Marea» está en la raíz y en el tramo.

**Mezclador.** Encabezado «Mezclador» (rasgo `.header`); «Listo, botón»; «Volumen general, 64 por ciento, ajustable»; once filas: «Lluvia, 65 por ciento, ajustable. Lluvia fina.» (pista: el subtítulo humano); acciones «Silenciar», «Máximo», «Timbre» **[1.1]**; Pro: «Océano, requiere Pro, botón. Toca dos veces para escucharlo 30 segundos.» Escape de Z cierra.

**Marea · ajustes.** Encabezado «Marea»; el texto de dos líneas como estático; «Ritmo, 6 por minuto, ajustable» (±1; pista: «Más lento a la derecha»); «Dura, 15 minutos, ajustable» (5/10/15/20/30); «Exhalación, más larga, ajustable» (dos valores); «En la muñeca, no, ajustable»; «Empezar, botón» / «Parar, botón»; la nota como estático con el enlace como botón «Qué sabemos y qué no».

**Marea · guiando.** Raíz: «Marea guiando, 6 por minuto, quedan 11 minutos. Inhala mientras suba la ola.» Con la guía activa, VoiceOver anuncia opcionalmente (ajuste «Guía hablada» en Más, apagado por defecto) «Inhala» / «Exhala» en cada cambio de fase con el volumen de VoiceOver al 40 %; la cama se atenúa 3 dB y no más (la guía no debe tapar el mar). «Parar, botón».

**Temporizador.** Encabezado; cuatro filas: «Hasta dormirme, 45 minutos, seleccionado, ajustable» (±5); «Escudo nocturno, hasta las 7, ajustable, requiere Pro»; «Siesta, 20 minutos, ajustable»; «Sin temporizador, botón». Doble toque en una fila la selecciona; deslizar vertical ajusta su valor.

**Noche.** Un elemento: «Sonando, 38 minutos restantes, 3 y 12 de la madrugada. Toca dos veces para pausar.» Acciones: «Quince minutos más», «Quince minutos menos», «Marea», «Volver». En pausa: «En pausa, 38 minutos…». Madrugada: «Madrugada, 20 minutos, Marea a 6. Toca dos veces para parar.»

**Noches.** Encabezado; «Guardar esta noche, botón» (al activarse, un `TextField` con foco y teclado: «Nombre de la noche, campo de texto, Lluvia y marrón»); cada fila «Lluvia en la ventana, botón. Lluvia 60, marrón 30, 45 minutos.» con acciones «Borrar» (no en las de fábrica: «Ocultar»), «Subir», «Bajar».

**Pro.** Encabezado «Una vez.»; el precio como estático; listas con rasgo de lista; «Comprar, 29 euros con 99, botón»; «Restaurar compra, botón»; el pie legal estático. Durante la compra el botón anuncia «Comprando» y queda `.notEnabled`.

**Más, Qué sabemos**: listas de botones y texto estático con encabezados reales (`.header`) por entrada para navegar con el rotor.

### 16.2 Alternativa sin gestos para cada gesto

| Gesto | Sin gesto (toque simple sobre texto) | Con Control por botón / Acceso asistido | Con Teclado completo (iPad) |
|---|---|---|---|
| Toque en cualquier punto (play/pausa) | El glifo (44 × 44 táctil, 64 en Noche: es también toque simple) | Elemento «Reproducir/Pausar» | Espacio |
| Arrastre vertical (volumen) | Tocar la Regla: aparece durante 4 s una fila «menos · más» de 64 pt bajo ella; cada toque ±5 % | Elementos «Menos volumen» / «Más volumen» | ↑ / ↓ |
| Arrastre horizontal (temporizador) | Tocar «42 min»: hoja con filas; dentro, tocar el valor alterna «−5 · +5» bajo la fila | Elementos de la hoja | ← / → en la principal |
| Pulsación larga (Marea) | Tocar «Marea»: pantalla 5.4 con «Empezar» | Elemento «Marea» | M |
| Dos dedos (mezclador) | Tocar «Lluvia y marrón» | Elemento «Mezclador» | Tab hasta la frase, Retorno |
| Arrastre abajo (Noche) | Palabra «Noche» del pie | Elemento «Noche» | N |
| Arrastre arriba / toque inferior (Volver) | Palabra «Volver» (64 pt, ancho completo) | Elemento «Volver» | Esc |
| Arrastre en fila (nivel de capa) | Tocar la fila: «menos · más» 4 s | Elementos por capa | ↑ / ↓ con foco en la fila |
| Pulsación larga en fila (timbre) **[1.1]** | Tocar el subtítulo «lluvia fina» cuando aparece | Elemento «Timbre» | T |
| Deslizar para borrar (Noches) | Botón «Editar» en `texto2` junto a «Listo» que muestra «Borrar» como palabra por fila | Elementos | Supr |

Ajuste único en «Más»: «Controles visibles» ("Visible controls"), que deja fijas las filas «menos · más» y los «−5 · +5» en vez de mostrarlas 4 s; se activa solo cuando Acceso asistido, Control por botón o AssistiveTouch están activos, y a mano para quien lo prefiera. Con él, la principal gana tres líneas de texto y sigue sin tener una caja.

### 16.3 Dynamic Type hasta AX5

| Tamaño | Frase | Regla y cifra «64 %» | Glifo | Pie | Mezclador | Noche | Hojas |
|---|---|---|---|---|---|---|---|
| xS-L | 28 pt, 1-2 líneas | 2 pt; 15 pt | 28 | 13 | 11 filas de 56, sin scroll | Cifra 72 | — |
| xL-xxxL | hasta 40 pt; `ViewThatFits`: un tramo por línea desde xxL | 2 pt; 17-20 pt | 34 | 15-18 | filas de 64; scroll desde xxxL | Cifra hasta 96 | «Listo» crece; filas de 72 |
| AX1-AX2 | 48-56 pt; tres líneas; el glifo baja a 620 pt | 3 pt (`@ScaledMetric`); 22 pt | 40 | 20-22 (el pie pasa a dos líneas: «Noches» arriba izq., «Más» arriba der., «Noche» centrado debajo) | nombre arriba, valor y Regla debajo (fila de 88); scroll | Cifra tope 120 (`accessibility2`); hora 28 | filas de 88; la nota de pie pasa a 20 |
| AX3-AX5 | 64-76 pt; la frase ocupa hasta 300 pt de alto; la Regla baja con ella; el glifo se coloca a 24 pt bajo la Regla en vez de a 560 fijos | 3 pt; 26 pt | 44 | 24-28, tres líneas; el pie se convierte en tres filas de 64 pt con hairline al final de la pantalla | una capa por pantalla de alto casi (fila de 120); scroll; «Listo» fijo arriba | Cifra tope 120; «Volver» 32 pt en banda de 88 | la hoja `.medium` pasa a `.large`; todo desplaza |

Lo que nunca cambia: una sola columna, cero cajas, los tramos siguen siendo botones, el toque de pantalla completa sigue funcionando. Capturas de control en el entregable: Large, xxxLarge, AX3, AX5 en ES y EN.

### 16.4 Otros ajustes

Aumentar contraste: `texto2 → #B4B2AE`, `texto3 → #7A7672`, `brasa → arena` (del catálogo). Formas de botón: subraya cada tramo de la frase y las palabras del pie (resuelve la discoverabilidad para quien lo pide). Diferenciar sin color: nada depende del color (la Regla en `brasa` también es más larga/luminosa que en reposo). Reducir transparencia: solo afecta a las hojas del sistema. Texto en negrita: SF lo hace solo. Smart Invert: la Regla y el glifo llevan `accessibilityIgnoresInvertColors` (son contenido). Parpadeo: ninguna luminancia cambia más de 3 veces por segundo (τ ≥ 500 ms). Acceso guiado: Noche y Madrugada funcionan como una pantalla de un botón. Sonido: VoiceOver atenúa, no detiene, la cama.

## 17. Textos de interfaz definitivos · ES / EN

Voz: corta, concreta, serena; segunda persona sin exclamaciones; sin diminutivos; sin «IA», «terapia», «mejora el sueño» ni ninguna palabra de la lista negra (§7.2 del brief). Las cadenas pasan por la lint de palabras médicas del catálogo existente. Los números usan el formato local (`29,99 €` / `$29.99`; `03:12` / `3:12 AM` según el ajuste de 24 h). «Noche» con mayúscula solo cuando es la pantalla; «noche» en minúscula cuando es una mezcla guardada, salvo en el título de la hoja.

### 17.1 Principal

| Clave | ES | EN |
|---|---|---|
| frase.reposo.segunda | «45 min · Marea» | "45 min · Tide" |
| frase.activa | «Lluvia y marrón · 42 min · Marea en 6» | "Rain and brown · 42 min · Tide at 6" |
| frase.sinTemporizador | «· toda la noche» | "· all night" |
| frase.siesta | «Siesta · hasta las 15:20» | "Nap · until 3:20 PM" |
| frase.pausa | «· en pausa» | "· paused" |
| frase.pausaAirPods | «· en pausa · AirPods» | "· paused · AirPods" |
| frase.fundido | «· se apaga en 8 min» | "· fading out in 8 min" |
| frase.mareaDescenso | «Marea en 12 → 6» | "Tide 12 → 6" |
| frase.mareaRetira | «Marea se retira» | "Tide fading" |
| frase.sinCapa | «· sin océano» | "· without ocean" |
| frase.previa | «Océano · 30 s de prueba» → «… · 12 s» | "Ocean · 30 s preview" → "… · 12 s" |
| nota.primerDia | «7 noches con todo. Sin tarjeta.» | "7 nights with everything. No card." |
| nota.prueba | «Prueba · quedan 5 noches» | "Trial · 5 nights left" |
| nota.ultimaNoche | «Prueba · última noche» | "Trial · last night" |
| nota.pruebaTerminada | «La prueba ha terminado. Blanco, rosa, marrón, lluvia y 60 minutos siguen gratis.» | "Trial over. White, pink, brown, rain and 60 minutes stay free." |
| tip.1 | «Toca para empezar. Arrastra arriba o abajo para el volumen.» | "Tap to start. Drag up or down for volume." |
| tip.2 | «Arrastra a los lados para el temporizador. Dos dedos abren el mezclador.» | "Drag sideways for the timer. Two fingers open the mixer." |
| tip.3 (noche 3, solo si no se ha usado) | «Mantén pulsado para la Marea.» | "Hold for the Tide." |
| pie | «Noches» · «Noche» · «Más» | "Nights" · "Night" · "More" |
| volumen.valor | «64 %» | "64%" |
| control.menosMas | «menos» · «más» | "less" · "more" |
| error.audio.titulo | «El sonido no ha podido empezar.» | "Sound couldn't start." |
| error.audio.cuerpo | «Otra app puede estar usando el audio. Toca para intentarlo otra vez.» | "Another app may be using audio. Tap to try again." |
| error.audio.tercero | «Reiniciar el iPhone suele resolverlo.» | "Restarting your iPhone usually fixes it." |
| error.audio.noche | «Sin sonido» | "No sound" |

Nombres de capa: Blanco, Rosa, Marrón, Lluvia, Ventilador, Océano, Trueno, Hoguera, Arroyo, Viento, Cabina / White, Pink, Brown, Rain, Fan, Ocean, Thunder, Campfire, Brook, Wind, Cabin. En la frase van en minúscula salvo el primero («Lluvia y marrón», «Rosa, marrón y océano»); con más de tres capas la frase dice las dos de más nivel y «y 2 más» ("and 2 more").

### 17.2 Mezclador

| Clave | ES | EN |
|---|---|---|
| titulo | «Mezclador» | "Mixer" |
| listo | «Listo» | "Done" |
| valor.vacio | «—» | "—" |
| valor.pro | «Pro» (versalitas) | "Pro" |
| subtitulos | «siseo parejo» · «rosa suave» · «retumbo grave» · «lluvia fina» · «ventilador lejano» · «mar de fondo» · «tormenta lejana» · «leña» · «agua entre piedras» · «viento en la ventana» · «cabina de avión» | "even hiss" · "soft pink" · "low rumble" · "fine rain" · "distant fan" · "ocean swell" · "distant storm" · "firewood" · "water over stones" · "wind at the window" · "airplane cabin" |
| timbre **[1.1]** | «más cálido ⟷ más lejano» | "warmer ⟷ farther" |
| vo.pro | «Océano, requiere Pro. Toca dos veces para escucharlo 30 segundos.» | "Ocean, requires Pro. Double-tap to hear it for 30 seconds." |

### 17.3 Marea

| Clave | ES | EN |
|---|---|---|
| titulo | «Marea» | "Tide" |
| texto | «Inhala mientras la línea avanza. Exhala mientras se retira. No hace falta mirar la pantalla.» | "Breathe in as the line advances. Breathe out as it recedes. No need to watch the screen." |
| ritmo | «Ritmo» · «6 por minuto» | "Pace" · "6 per minute" |
| ritmo.detalle | «Empieza a tu ritmo (12) y baja a 6 en 4 minutos.» | "Starts at your pace (12) and eases to 6 in 4 minutes." |
| ritmo.salud **[1.1]** | «Empieza a 14, tu ritmo nocturno medio según Salud.» | "Starts at 14, your average night pace from Health." |
| dura | «Dura» · «15 min» | "Lasts" · "15 min" |
| exhalacion | «Exhalación» · «más larga» / «igual» | "Out-breath" · "longer" / "equal" |
| exhalacion.detalle | «4 segundos dentro, 6 fuera.» | "4 seconds in, 6 out." |
| muneca **[1.1]** | «En la muñeca» · «no» / «mínima» / «marcada» | "On the wrist" · "off" / "minimal" / "marked" |
| mano | «En la mano» · «no» / «mínima» / «marcada» | "In the hand" · "off" / "minimal" / "marked" |
| empezar / parar | «Empezar» / «Parar» | "Start" / "Stop" |
| guiando | «Guiando · 6 por minuto · 11 min» | "Guiding · 6 per minute · 11 min" |
| guiando.descenso | «Guiando · 9 → 6 · 13 min» | "Guiding · 9 → 6 · 13 min" |
| cifra.pie | «por minuto, bajando a 6» | "per minute, easing to 6" |
| disolviendo | «Disolviéndose · 3 min» | "Dissolving · 3 min" |
| nota | «Ritmo respiratorio lento asociado en estudios a mayor variabilidad cardiaca. Qué sabemos y qué no.» | "Slow breathing pace linked in studies to higher heart-rate variability. What we know and what we don't." |
| vo.guia | «Inhala» / «Exhala» | "Breathe in" / "Breathe out" |

### 17.4 Temporizador

| Clave | ES | EN |
|---|---|---|
| titulo | «Temporizador» | "Timer" |
| dormirme | «Hasta dormirme» · «45 min» | "Until I'm asleep" · "45 min" |
| escudo | «Escudo nocturno» · «hasta las 7:00» · «baja de nivel al amanecer» | "Night shield" · "until 7:00 AM" · "eases at dawn" |
| siesta | «Siesta» · «20 min» | "Nap" · "20 min" |
| ninguno | «Sin temporizador» | "No timer" |
| pro.antes | «antes 90 · Pro» | "was 90 · Pro" |
| nota | «El sonido se desvanece antes de que termine. Tu alarma suena igual.» | "The sound fades before the end. Your alarm still rings." |

### 17.5 Noche y Madrugada

| Clave | ES | EN |
|---|---|---|
| cifra | «38 min» | "38 min" |
| suena / pausa | «Suena» / «En pausa» | "Playing" / "Paused" |
| volver / parar | «Volver» / «Parar» | "Back" / "Stop" |
| vo.noche | «Sonando, 38 minutos restantes, 3 y 12 de la madrugada. Toca dos veces para pausar.» | "Playing, 38 minutes left, 3:12 AM. Double-tap to pause." |
| vo.madrugada | «Madrugada, 20 minutos, Marea a 6. Toca dos veces para parar.» | "Small hours, 20 minutes, Tide at 6. Double-tap to stop." |
| accion.mas / menos | «Quince minutos más» / «Quince minutos menos» | "Fifteen more minutes" / "Fifteen fewer minutes" |

### 17.6 Noches

| Clave | ES | EN |
|---|---|---|
| titulo | «Noches» | "Nights" |
| guardar | «Guardar esta noche» | "Save this night" |
| guardar.pro | «Guardar esta noche · Pro» | "Save this night · Pro" |
| nombre.placeholder | «Lluvia y marrón» (propuesto desde la frase) | "Rain and brown" |
| fabrica | «Lluvia en la ventana» · «Noche cerrada» · «Avión» | "Rain on the window" · "Deep night" · "Cabin" |
| descripcion | «lluvia 65 · marrón 40 · 45 min · Marea» | "rain 65 · brown 40 · 45 min · Tide" |
| esPro | «· trueno es Pro» | "· thunder is Pro" |
| guardadaSin | «Guardada sin trueno» · «Conservar el trueno» | "Saved without thunder" · "Keep thunder" |
| acciones | «Borrar» · «Ocultar» · «Editar» | "Delete" · "Hide" · "Edit" |

### 17.7 Pro y prueba

| Clave | ES | EN |
|---|---|---|
| titulo | «Una vez.» | "Once." |
| cuerpo | «SleepNoise Pro cuesta 29,99 €. Se paga una vez y es tuyo, también para tu familia.» | "SleepNoise Pro is $29.99. Pay once and it's yours, for your family too." |
| lanzamiento | «29,99 € · hasta el 15 de diciembre, 19,99 €» | "$29.99 · until December 15, $19.99" |
| prueba | «Prueba · quedan 5 noches con todo. Sin tarjeta.» | "Trial · 5 nights left with everything. No card." |
| conPro | «Con Pro» · «Ventilador, océano, trueno, hoguera, arroyo, viento y cabina» · «Temporizador más allá de 60 minutos y escudo nocturno» · «Marea respiratoria» · «Noches sin límite» | "With Pro" · "Fan, ocean, thunder, campfire, brook, wind and cabin" · "Timer beyond 60 minutes and night shield" · "Breathing tide" · "Unlimited nights" |
| gratis | «Gratis siempre» · «Blanco, rosa, marrón y lluvia» · «Temporizador de 60 minutos» · «Tres noches guardadas» · «Nada sale de tu iPhone» | "Free, always" · "White, pink, brown and rain" · "60-minute timer" · "Three saved nights" · "Nothing leaves your iPhone" |
| comprar | «Comprar · 29,99 €» → «Comprando…» → «Gracias» | "Buy · $29.99" → "Buying…" → "Thank you" |
| pendiente | «Pendiente de aprobación» | "Awaiting approval" |
| restaurar | «Restaurar compra» → «Restaurando…» | "Restore purchase" → "Restoring…" |
| restaurar.nada | «No hay ninguna compra en esta cuenta de Apple.» | "No purchase on this Apple Account." |
| error | «No se ha completado la compra. No se te ha cobrado.» | "The purchase didn't go through. You haven't been charged." |
| precio.error | «No se ha podido cargar el precio. Inténtalo con conexión.» | "Couldn't load the price. Try again with a connection." |
| legal | «Pago único a través de Apple. Sin suscripción. Compartido en familia.» | "One-time purchase through Apple. No subscription. Family Sharing included." |
| primerDia.titulo | «7 noches con todo.» | "7 nights with everything." |
| primerDia.cuerpo | «Sin tarjeta. Cuando acaben, siguen gratis blanco, rosa, marrón, lluvia y 60 minutos; tus noches se conservan. Pro cuesta 29,99 €, una vez.» | "No card. When they're over, white, pink, brown, rain and 60 minutes stay free; your nights are kept. Pro is $29.99, once." |
| primerDia.boton | «Entendido» | "Got it" |
| ultimaNoche.titulo | «Última noche con todo.» | "Last night with everything." |
| gracias | «SleepNoise Pro · Gracias · 16 de noviembre de 2026» | "SleepNoise Pro · Thank you · November 16, 2026" |

### 17.8 Más y Qué sabemos

| Clave | ES | EN |
|---|---|---|
| mas.filas | «Pro» · «Qué sabemos y qué no» · «Atajos y Centro de control» · «Háptica de la Marea» · «Guía hablada de la Marea» · «Controles visibles» · «Noche directa en el modo Sueño» **[1.1]** · «Versión 2.0 · 1,8 MB · Nada sale de tu iPhone» | "Pro" · "What we know and what we don't" · "Shortcuts and Control Center" · "Tide haptics" · "Spoken Tide guide" · "Visible controls" · "Straight to Night in Sleep Focus" · "Version 2.0 · 1.8 MB · Nothing leaves your iPhone" |
| sabemos.titulo | «Qué sabemos y qué no» | "What we know and what we don't" |
| sabemos.noSabemos | «Lo que no sabemos» | "What we don't know" |
| sabemos.cierre | «SleepNoise no es un producto sanitario.» | "SleepNoise is not a medical device." |
| atajos.p1 | «Di «Dormir con SleepNoise» a Siri, o añade el control al Centro de control: empieza tu última noche sin abrir la app.» | "Say "Sleep with SleepNoise" to Siri, or add the control to Control Center: your last night starts without opening the app." |
| atajos.p2 | «Para que empiece sola al acostarte: en Atajos, crea una automatización «Cuando se active Sueño» con la acción «Dormir con SleepNoise».» | "To start on its own at bedtime: in Shortcuts, create a "When Sleep turns on" automation with the "Sleep with SleepNoise" action." |

### 17.9 Ecosistema

| Clave | ES | EN |
|---|---|---|
| la.apaga | «se apaga a las 03:54» | "fades out at 3:54 AM" |
| la.termino | «terminó a la 1:10» | "ended at 1:10 AM" |
| la.detuvo | «se detuvo a las 2:14» | "stopped at 2:14 AM" |
| la.veinte | «20 min» | "20 min" |
| la.vo | «SleepNoise, sonando, lluvia y marrón, 42 minutos, se apaga a las 3 y 54.» | "SleepNoise, playing, rain and brown, 42 minutes, fades out at 3:54 AM." |
| widget.dormir | «Dormir» | "Sleep" |
| cc.valor | «Sonando» / «En silencio» | "Playing" / "Silent" |
| cc.veinte | «Veinte minutos» | "Twenty minutes" |
| accion.hint | «Mantén para dormir» | "Hold to sleep" |
| siri | «Dormir con SleepNoise» · «Pausa SleepNoise» · «SleepNoise, quince minutos más» · «SleepNoise, veinte minutos» · «Pon Lluvia en la ventana en SleepNoise» · «Marea en SleepNoise» | "Sleep with SleepNoise" · "Pause SleepNoise" · "SleepNoise, fifteen more minutes" · "SleepNoise, twenty minutes" · "Play Rain on the window in SleepNoise" · "Tide in SleepNoise" |
| watch **[1.1]** | «42 min» · «Quince minutos más» · «64 %» | "42 min" · "Fifteen more minutes" · "64%" |
| salud.permiso **[1.1]** | «SleepNoise lee tu frecuencia respiratoria nocturna para empezar la Marea a tu ritmo. No escribe nada ni sale de tu iPhone.» | "SleepNoise reads your night-time respiratory rate to start the Tide at your pace. It writes nothing and nothing leaves your iPhone." |

## 18. Onboarding de una noche

No hay pantallas. Hay **una noche**, y lo que se aprende se aprende usándola:

| Momento | Lo que la app hace | Lo que el usuario aprende | Cuándo se retira |
|---|---|---|---|
| Abrir por primera vez | Principal con «Lluvia en la ventana» cargada (sin decir el nombre), volumen 50 %, 45 min, Marea apagada; línea «7 noches con todo. Sin tarjeta.»; tip 1 | que no hay nada que configurar; que la prueba no pide tarjeta | la línea, al tocarla o al segundo día (pasa a «Prueba · quedan 6 noches»); el tip, al primer toque y al primer arrastre |
| Primer toque | suena en 800 ms con un háptico | toque = suena | — |
| 20 s después | Noche | la app se apaga sola; no hay que hacer nada | — |
| Segunda noche, al abrir | tip 2 bajo el glifo | horizontal = tiempo; dos dedos = mezclador | al primer uso de cualquiera de los dos o a los 3 días |
| Tercera noche, si no ha usado la Marea | tip 3 | pulsación larga = Marea | al primer uso o a los 3 días |
| Primera vez que toca «Marea» | 5.4 con su texto de dos líneas (es el único «tutorial» de la app, y es la pantalla de la función) | cómo respirar con la línea | nunca (es contenido) |
| Noche 7 | «Prueba · última noche» | mañana cambia algo | al terminar la sesión |
| Día 8 | la línea del día 8 (una vez) | qué sigue gratis; dónde está Pro | al día siguiente |

Ningún permiso se pide en el onboarding porque no hay ninguno que pedir: Salud **[1.1]** se pide en la fila «Ritmo» al tocar «según Salud», con el texto de 17.9; notificaciones, nunca; micrófono, fuera de alcance. Ninguna petición de valoración en ninguna versión: si el dueño la quiere, el único lugar admisible es «Más», como una fila de texto que el usuario toca él.

Prueba de aceptación del onboarding: cinco personas ajenas, iPhone en mano, luz apagada; en menos de un minuto deben reproducir, bajar el volumen y alargar el tiempo sin instrucciones; tres de las cinco deben llegar a Noche sin saber que existe. Otras cinco con VoiceOver, lo mismo con la frase y el rotor.

## 19. Alcance propuesto por versión

Dado que el plan de funciones no existía, el estudio propone este reparto para que la ingeniería pueda arrancar:

- **1.0**: principal, Frase, Regla, mezclador (sin timbre), Marea (ritmo, duración, exhalación, háptica en la mano), temporizador de tres modos, Noche, Madrugada (desde Live Activity y desde la app), Noches con las tres de fábrica, Pro/prueba, Más, Qué sabemos, Live Activity/Dynamic Island/StandBy, widgets pequeño/mediano/bloqueo, Centro de control y botón de Acción (iOS 18+), Siri/Atajos, tips 1-3, icono, capturas.
- **1.1**: Watch (mando + háptico de Marea), timbre «más cálido ⟷ más lejano», Salud en la Marea, Focus de Sueño (Noche directa), escudo nocturno «sigue la alarma de Reloj», paleta «papel» de día si el dueño la confirma.

Nada de 1.1 deja un hueco visible en 1.0: la fila «En la muñeca» no aparece sin Watch emparejado, «según Salud» no aparece sin la función, y la pulsación larga en una fila del mezclador simplemente no hace nada hasta que exista.
