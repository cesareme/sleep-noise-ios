# Concepto «Marea»

**Equipo Marea · concepto de identidad e interfaz para SleepNoise · 16 de noviembre de 2026**
**Linaje declarado:** Tide Guide y Moonlitt (ADA 2026), Bang & Olufsen, Smart Design, Dieter Rams en su versión más suave.
**Postura frente a la tensión del brief (§5):** *somos sobre todo instrumento, y la noche es un modo.* La pantalla principal **es** el mezclador; la noche es la misma pantalla con la luz bajada hasta que solo queda la línea.

Maqueta estática: `scratchpad/design/concepts/marea.html` (misma sesión). Todas las medidas están en puntos, en el ajuste Large de Dynamic Type y en un marco de 393 × 852 (iPhone 17 Pro). Las ratios de contraste son WCAG 2.x calculadas con la fórmula de luminancia relativa (`scratchpad/design/wcag_marea.py`); «bajo rojo» usa el modelo A del documento 02 (StandBy nocturno conserva solo el canal rojo), que es el más severo de los dos.

---

## 1. Tesis

SleepNoise es un instrumento que fabrica sonido ahora, y la única prueba honesta de eso es **la envolvente real del DSP dibujada como una línea de horizonte a un tercio de la pantalla**: plana y tenue cuando nada suena, ondulada y clara cuando el motor trabaja, lenta y ancha cuando la Marea respira (sube 4 segundos, baja 6, nunca un círculo que crece). Todo lo demás es tipografía sobre negro real: el nombre de la mezcla, seis capas como seis líneas de nivel que se arrastran con un dedo, tres palabras en una barra. No hay tarjetas, iconos de biblioteca, candados ni resplandores; hay un solo acento, *brasa*, reducido a una línea y a un punto que marca el «ahora», como el segundero amarillo de Braun. Según avanza la noche, la paleta no cambia de matiz sino de luminancia (Descenso → Noche → Madrugada → Despertar), de modo que la misma pantalla que se enseña en una Apple Store a plena luz es la que se mira a las 3 de la mañana con los ojos a medio abrir: la misma línea, menos luz. Todo lo que se mueve tiene causa en el audio; nada más se mueve.

---

## 2. Identidad

### 2.1 Paleta (tokens exactos)

Negro OLED real como material; nada de degradados, sombras ni rellenos grandes (evita bandas y *smear*). Ninguna superficie, botón ni pulgar se rellena con el acento: *brasa* solo existe como trazo (≥ 1 pt) o como punto (≥ 6 pt).

| Token | Hex | Sobre `#000` | Sobre `hoja` | Bajo rojo (canal R) | Uso |
|---|---|---|---|---|---|
| `negro` | `#000000` | — | — | — | Fondo de toda superficie nocturna y de la principal |
| `hoja` | `#1C1C1E` | 1,23 | — | — | Fondo de hojas modales (Marea, Temporizador, Noches, Pro) |
| `trazo` | `#2A2A2E` | 1,47 | 1,19 | — | Hairline decorativa de 0,5 pt (nunca transmite información) |
| `texto` | `#E8E4DC` | **16,56** | **13,42** | `#E80000` **4,43** | Texto principal, cifras, nivel lleno de una capa, glifos de la barra |
| `texto2` | `#9C9A96` | **7,48** | **6,06** | 2,41 (no usar bajo rojo) | Secundario, estado, valores, capa a cero |
| `texto3` | `#6E6C68` | **4,01** | 3,25 | 1,66 | Solo no textual: pista vacía del nivel, anillo del botón, ≥ 18 pt si es texto |
| `brasa` | `#C9A27A` | **8,93** | **7,24** | `#C90000` **3,48** | El acento: envolvente sonando, punto «ahora», ola de la Marea, toggle activo |
| `brasa-tenue` | `#8C6E52` | **4,47** | 3,62 | 2,12 | Horizonte en reposo (línea de 1 pt), hairline del botón primario |
| `brasa-noche` | `#8D7155` | **4,63** | — | — | Acento en fase Noche (70 % de luminancia de `brasa`), solo formas |
| `brasa-madrugada` | `#6F5943` | **3,19** | — | — | Acento en fase Madrugada (55 %), solo formas ≥ 2 pt |
| `texto-noche` | `#A2A09A` | **8,03** | — | — | Único texto de la pantalla Noche (70 % de `texto`) |
| `texto-madrugada` | `#908D88` | **6,35** | — | — | Reloj de Madrugada, solo tras un toque |
| `arena` | `#D9C7AE` | 12,73 | 10,31 | 3,95 | `brasa` con «Aumentar contraste» (texto del botón primario) |
| `error` | sistema `.red` oscuro | 5,4 | — | — | Solo el aviso de sesión de audio fallida |

Variantes *High Contrast* en el catálogo: `texto2 → #B4B2AE` (9,92), `texto3 → #7A7672` (4,66), `brasa → #D9B98F` (11,29), `brasa-noche → #A68A6C` (≈ 6,3).

**Por qué los números que no están.** `brasa` al 60 % (`#796149`) da 3,62 sobre negro pero 2,93 sobre `hoja` y 1,81 bajo rojo; por eso Noche usa el 70 %. `brasa` al 35–45 % (`#46392B`–`#5A4937`, 1,9–2,4) no alcanza el 3:1 de componente gráfico, así que el horizonte en reposo no es «brasa apagada» sino `brasa-tenue` (4,47), que es la misma familia a la luminancia mínima que sigue leyéndose. El índigo y el teal mueren bajo rojo (1,65 y 1,00); el ámbar actual `#EBB873` (11,6) es demasiado luminoso para las 3 de la mañana: *brasa* es ese ámbar bajado de luz y de saturación, continuidad con el icono actual sin la lámpara.

**Las cuatro fases de la noche** (la paleta cambia de luminancia, nunca de matiz; la transición entre fases dura 2 s en opacidad):

| Fase | Cuándo | `texto` | Acento | Qué hay en pantalla |
|---|---|---|---|---|
| **Descenso** | App delante, antes de acostarse (y de día) | `#E8E4DC` | `brasa` | Principal completa: nombre, horizonte, seis capas, barra |
| **Noche** | Pantalla Noche (gesto o automática) | `texto-noche` | `brasa-noche` | Horizonte congelado, reloj, hora de fundido |
| **Madrugada** | Desbloqueo ≥ 20 min después del bloqueo mientras suena o tras parar | ninguno hasta tocar | `brasa-madrugada` | Solo el horizonte; el reloj aparece 5 s al tocar |
| **Despertar** | Últimos 15–30 min antes de la alarma del sistema (si hay despertar progresivo) | sube de `texto-noche` a `texto` | sube de `brasa-madrugada` a `brasa` | El «amanecer» es luminancia, no naranja |

**Bajo el rojo de StandBy** (widgets y Live Activity) hay **una sola tinta**: `texto` (4,43 bajo rojo, el único valor que supera 4,5 a tamaño grande con margen; cumple AA para texto ≥ 18 pt Medium y AA de componente). `brasa` solo como forma de ≥ 3 pt (3,48 ≥ 3). Nada de `texto2`, nada de opacidades. El estado se lee por forma: línea continua = suena; línea discontinua = en pausa; `pause.fill` / `play.fill`.

**Paleta de día «papel»** (sigue la apariencia del sistema; no hay selector propio): `papel #F3F0E9`, `tinta #1E1C19` (14,94), `tinta2 #5F5A53` (6,00), `cobre #8A5A2B` (5,16; el *brasa* de día), `trazo-papel #D8D3C9`. El horizonte de día es `cobre`; las reglas de línea y punto son las mismas.

### 2.2 Tipografía

**Una familia: SF Pro.** La voz Bear no está en Avenir Next: está en lo que Bear hace con su letra (tamaño generoso, interlineado amplio, dos pesos, nada en mayúsculas, una línea en vez de una caja). Se valoró Avenir Next Medium para títulos: queda **descartada** porque obligaría a `Font.custom(_:size:relativeTo:)` sin tamaños ópticos ni respuesta a Bold Text, no existe en Watch ni en widgets (habría dos letras) y su contraste de trazo a 13–15 pt sobre negro es menor que el de SF Text. Si algún día entra texto escrito por el usuario (notas de noche), Avenir Next entra solo dentro de la nota, como en Bear.

**SF Pro Rounded, solo en la cifra que se mira a un metro** (reloj de Noche, cuenta atrás, precio). **SF Mono, nunca como cifra grande**; solo en lecturas técnicas bajo pulsación larga («−18 dBFS», «6,0/min»).

| Paso | Uso | Familia · peso | Tamaño / interlineado (Large) | `relativeTo` | Noche |
|---|---|---|---|---|---|
| 1 · Cifra | Reloj de Noche, cuenta atrás, precio | SF Rounded Regular, tabular, tracking −1,5 % | 72 / 80 (Noche); 56 / 64 (hojas) | `.largeTitle`, tope `accessibility2` | Regular |
| 2 · Título | Nombre de la mezcla, título de hoja | SF Pro Medium | 22 / 28 | `.title2` | Medium |
| 3 · Encabezado | Nombre de capa, nombre de fila | SF Pro Semibold | 17 / 22 | `.headline` | Semibold |
| 4 · Cuerpo | Frases de una línea, texto del Pro | SF Pro Regular | 17 / 22 | `.body` | Medium |
| 5 · Secundario | Estado («Suena · se funde a las 00:42»), subtítulos | SF Pro Regular | 15 / 20 | `.subheadline` | Medium |
| 6 · Nota | Prueba, pie legal, notas de temporizador | SF Pro Regular | 13 / 18 | `.footnote` | Medium |
| 7 · Dato | Nivel «65», «42 min», versalitas de estado | SF Pro Medium tabular; versalitas reales (`.smallCaps()`) con tracking +2 % | 13 / 18 | `.footnote` | Medium |

Reglas: nada < 13 pt; nada < Medium sobre negro; Regular solo ≥ 20 pt; Bold nunca; Light/Thin nunca; cifras siempre `monospacedDigit()`; mayúsculas sostenidas nunca (estados en versalitas: «Pro», «Prueba»). De xSmall a AX5: las filas de capa pasan de «nombre y valor en línea» a «nombre arriba, línea de nivel debajo» con `ViewThatFits` a partir de AX1; la pantalla principal admite scroll solo desde AX1 (en Large cabe entera: 852 pt sin desplazamiento).

### 2.3 Espaciado, hairline, radios, iconografía

- **Retícula**: columna única de 353 pt (393 − 2 × 20). Escala de 4 pt: 4 / 8 / 12 / 20 / 32 / 56 / 80. Margen lateral 20. Separación vertical entre grupos ≥ 2 × la separación dentro del grupo (32 frente a 12).
- **El horizonte** está siempre a **y = 284** (un tercio de 852) en la principal, en Noche, en Madrugada y en la Marea de la Live Activity escalada. Es la constante del sistema: el usuario sabe dónde mirar sin leer.
- **Hairline**: 0,5 pt (1 px en 2× y 3×) en `trazo`, de margen a margen (x = 20 → 373), nunca de borde a borde. Es el único separador. Solo donde el aire no basta (listas de hojas).
- **Radios**: 0 en líneas y pistas; 999 (cápsula) en los dos únicos contornos de la app (anillo del botón de reproducir, botón primario del Pro); 12 en la Live Activity y el widget (los pone el sistema); las hojas usan el radio del sistema.
- **Sin sombras, sin materiales propios, sin `glassEffect` en contenido.** El vidrio solo en la barra inferior de la principal (`ToolbarItemGroup(placement: .bottomBar)`) y en las barras de las hojas, y solo el que el sistema pone. Un único `#available(iOS 26)` en el `ViewModifier` de la barra.
- **Iconografía**: cero iconos en las filas de capa (las palabras son los iconos). SF Symbols monocromos, peso heredado (Medium), solo en la barra (`timer`, `play.fill`/`pause.fill` con `.contentTransition(.symbolEffect(.replace))`) y donde el sistema exige glifo (Live Activity, widget, Control, Watch). Un símbolo propio: **la ola de Marea** (dos arcos asimétricos 4:6 con un punto en la cresta), dibujado como símbolo personalizado desde la plantilla de SF Symbols en nueve pesos y tres escalas; es el glifo del botón «Marea», del Control del Centro de control, de la Live Activity y del icono de la app. Para widgets de atajo por textura, el mapa del documento 02 (líneas de pendiente espectral para blanco/rosa/marrón; `cloud.rain`, `fan`, `water.waves`…).
- **Objetivos**: ≥ 44 × 44 pt en todo; 56 pt de alto en cada fila de capa (toda la fila es el control); 64 pt el anillo de reproducir; 100 % de la pantalla en Noche y Madrugada. ≥ 12 pt entre objetivos con contorno, ≥ 24 pt entre filas (las filas se separan por 56 pt de paso, con la línea de nivel a 12 pt del borde inferior).

### 2.4 Movimiento (tabla elemento → señal del motor)

| Elemento animado | Señal | Frecuencia / curva | Reduce Motion | `isLuminanceReduced` / Noche |
|---|---|---|---|---|
| Horizonte (envolvente) | RMS sumado por capa, seqlock de `SoundGains`, τ = 400–800 ms | 20 Hz, `Canvas` en `TimelineView(.periodic)` pausado si no suena | 4 Hz, τ = 1,5 s | Congelado en la última forma, 2 s de `easeInOut`, después quieto |
| Capa del horizonte por capa (pulsación larga) | RMS de esa capa | igual, grosor 0,75 / 1 / 1,5 pt | igual | igual |
| Punto «ahora» | Posición fija x = 373, altura = nivel maestro | sigue la envolvente | sigue | congelado |
| Ola de la Marea | `BreathCurve` del audio, ancla `guide.anchor`, 4 s sube / 6 s baja a 6/min | `KeyframeAnimator` con 24 claves por ciclo, resincronizado por ciclo (compensa 2 s de AirPlay) | solo opacidad ±25 % | congelada en marea baja |
| Línea de nivel bajo el dedo | gain de la capa | directo al gesto, 0 ms | igual | n/a |
| Arranque / parada | fundido del motor | 800 ms `easeOut` / 1.500–2.000 ms `easeInOut` | igual (es opacidad y altura) | igual |
| Cambio de fase de la noche | reloj de fase | 2.000 ms opacidad | igual | igual |
| Play ↔ Pause | estado del motor | `.replace` del sistema | fundido | n/a |

Nada más se mueve. Sin springs, sin rebotes, sin transiciones de hoja propias, sin `symbolEffect` salvo `.pulse` en `timer` durante el fundido final.

### 2.5 Háptica

La del documento 02 sin cambios: `.selection` al cruzar el cero de una capa; `.impact(.light, 0.6)` al tope; `.impact(.medium, 0.7)` al arrancar; `.impact(.light, 0.5)` al parar; `.success` al guardar una noche; **nada** al terminar el temporizador, nada en Noche y Madrugada, nada si el iPhone está quieto y horizontal; Marea háptica opcional («Mínima» 3–5 respiraciones, «Marcada» toda la guía) solo con el iPhone en la mano; en el Watch, `.directionUp` al inicio de cada inhalación.

---

## 3. Sistema de componentes

Cada componente tiene seis estados: **normal · activo · bloqueado-Pro (sin castigo) · prueba · deshabilitado · VoiceOver**. Columna «sistema / propio».

### 3.1 Fila de capa = control de nivel (propio)

La fila **es** el deslizador. 56 pt de alto, margen 20. Nombre en paso 3 alineado a la izquierda, con línea base a 22 pt del borde superior; valor en paso 7 alineado a la derecha, misma línea base; **línea de nivel** a 12 pt del borde inferior, de x = 20 a x = 373: la parte llena en `texto` a 2 pt, la vacía en `texto3` a 1 pt. Arrastre horizontal en cualquier punto de la fila (`DragGesture(minimumDistance: 4)` con bloqueo de eje) cambia el nivel; un toque en una capa a cero la enciende al 40 %. Pulsación larga (0,5 s) abre bajo la fila, en la misma superficie, la segunda línea de timbre: «cálido ———●——— brillante» (un corte de agudos/graves por capa) y, para blanco/rosa/marrón, «cerca ———●——— lejos» (filtro de distancia); se cierra al soltar en otra fila.

| Estado | Nombre | Línea | Valor | Otro |
|---|---|---|---|---|
| Normal (a cero) | `texto2` | 1 pt `texto3` completa | oculto | — |
| Activo (suena) | `texto` | llena 2 pt `texto` + resto 1 pt `texto3` | «65» `texto2` tabular | VoiceOver: «Lluvia, 65 por ciento, ajustable» |
| Bajo el dedo | `texto` | llena 3 pt `texto`; punta con un punto de 6 pt | «65» en `texto` 17 Medium, junto a la punta | `.selection` al cruzar 0; `.impact(.light)` al llegar a 100 |
| Bloqueado-Pro (gratis tras la prueba) | `texto2` | 1 pt `texto3` | «Pro» en versalitas `texto2` | Toque: la capa **suena 30 s** y se presenta la hoja Pro con el precio en la primera línea; nunca un candado |
| Prueba | igual que Activo/Normal | igual | igual | Nada en la fila: la prueba es «todo abierto» |
| Deshabilitado (motor caído) | `texto3` | 1 pt `trazo` | — | Solo durante el aviso de sesión de audio |
| VoiceOver | `.adjustable`, pasos del 5 %; acciones «Silenciar», «Máximo», «Timbre»; Pro: «Lluvia, requiere Pro, botón; toca para escuchar 30 segundos» | | | |

Geometría alternativa explorada y descartada para 1.0: «un objeto»: las seis capas como seis bandas horizontales apiladas dentro del propio horizonte (cada banda una ola con su grosor), arrastrables verticalmente. Más bella en la tienda, pero a 3 de la mañana no se distingue qué banda se coge; se guarda como visualización bajo pulsación larga del horizonte (ver 3.7).

### 3.2 Botón primario (propio) y botón secundario (sistema)

- **Primario = el anillo de reproducir**: círculo de 64 pt, contorno 1,5 pt `texto3` (4,01 ≥ 3), glifo `play.fill` / `pause.fill` de 24 pt en `texto`. Nunca relleno, nunca `brasa`. Pulsado: el contorno pasa a `texto` 200 ms. Deshabilitado: contorno `trazo`, glifo `texto3`. VoiceOver: «Reproducir, botón» / «Pausar, botón; suena Lluvia fina y marrón».
- **Primario de compra** (solo en la hoja Pro): cápsula de 56 pt de alto y 353 de ancho, contorno 1,5 pt `brasa`, texto 17 Semibold `brasa` («Comprar · 29,99 €»). Con «Aumentar contraste» el texto pasa a `arena`. Es el único lugar donde el acento es borde de un botón, porque es el único botón que cuesta dinero. Deshabilitado (StoreKit sin producto): contorno `texto3`, texto `texto3`, debajo en paso 6: «La tienda no responde. Nada cambia: sigue sonando.»
- **Secundario**: `Button` de texto del sistema, 17 Regular `texto2`, 44 pt de alto, sin fondo («Restaurar compra», «Entendido», «Guardar»). Con Button Shapes activo muestra su contorno del sistema.

### 3.3 Chip de estado (propio, tipográfico)

No es una cápsula: es una palabra en versalitas de paso 7 en `texto2` con tracking +2 %. Valores: «Prueba · quedan 5 noches», «Pro», «Suena», «Pausa», «Fundiendo». Nunca lleva fondo ni color. En Pro, desaparece toda mención salvo «SleepNoise Pro · gracias» en Ajustes.

### 3.4 Hoja (sistema)

`sheet` estándar con `presentationBackground(hoja)`, `presentationDragIndicator(.visible)`, título inline 17 Semibold centrado, **sin botón «Cerrar»** (se arrastra o se toca fuera; en iOS 26 el sistema añade el cierre). Detents: `.large` para Marea, Noches y Pro; `.medium` para Temporizador. Dentro de la hoja: texto, filas de 56 pt separadas por hairline, cero rectángulos rellenos. Las hojas nunca aparecen solas: solo tras un toque del usuario (P9).

### 3.5 Barra (sistema)

`ToolbarItemGroup(placement: .bottomBar)` con tres elementos: **Temporizador** (izquierda, `timer` + etiqueta 15 Medium: «Temporizador» o «42 min»), **Reproducir** (centro, el anillo de 3.2), **Marea** (derecha, glifo propio + «Marea» o «6/min»). Elemento activo en `texto`, inactivo en `texto2`; el glifo adopta `.fill` cuando la función está activa (estado por variante, no por color). En iOS 26 recibe vidrio regular monocromo; en iOS 17–18, material `.bar` más una hairline encima. La envolvente pasa por debajo de la barra al desplazarse (solo en AX), que es lo único que el vidrio refracta.

### 3.6 Visual del sonido: el horizonte (propio)

Una trayectoria de `Canvas` de borde a borde (x = 0 → 393) centrada en y = 284. Eje horizontal = tiempo: los últimos 20 s de envolvente, con el **ahora** en x = 373 (margen derecho) marcado con un punto de 6 pt en `brasa`; el pasado se desplaza hacia la izquierda y se desvanece en los últimos 40 pt (opacidad → 0 en x < 40). Altura = RMS maestro mapeado a ±48 pt (−60 dBFS → 0, −6 dBFS → 48). Grosor 1,5 pt en `brasa`.

| Estado | Forma |
|---|---|
| Reposo (nada suena) | Línea recta de 1 pt en `brasa-tenue`, sin punto. Es el «silencio dibujado»: no miente, porque el motor publica 0 |
| Sonando | Ondulación real a 20 Hz, `brasa`, punto «ahora» |
| Fundido (temporizador) | La amplitud baja con el nivel real hasta volver a la recta en 1,5–2 s |
| Pausa (iOS 26 AirPods, llamada) | Baja a recta en 2 s; la recta queda **discontinua** (trazo 6 / hueco 6) mientras la sesión esté en pausa |
| Marea activa | La misma línea: la ola lenta (período 10 s a 6/min, 4:6) se superpone a la envolvente; en los 20 s visibles caben dos respiraciones; el punto sube con la inhalación |
| Pulsación larga sobre el horizonte | Se descompone en una línea por capa (0,75 / 1 / 1,5 pt según nivel), misma tinta, distinta opacidad, 2 s; vuelve a sumarse al soltar |
| Reduce Motion | 4 Hz, τ = 1,5 s; la Marea solo cambia de opacidad |
| Noche / Madrugada / `isLuminanceReduced` | Congelado (continuo = suena, discontinuo = pausa), en `brasa-noche` / `brasa-madrugada` |
| VoiceOver | «Sonido: nivel medio, Lluvia y Marrón» + `AXChartDescriptor` del nivel por capa (rotor Audio Graph) |

### 3.7 Forma de la Marea (propio)

Nunca un círculo. Una **ola de un ciclo**: línea base a la altura del horizonte; sube durante 4 s hasta +48 pt con curva `BreathCurve` (la del audio), baja durante 6 s hasta la base. En la principal vive dentro del horizonte (3.6). En la hoja Marea se dibuja grande (353 × 120, trazo 2 pt `texto`, base hairline `trazo`), con el punto de fase en `brasa` de 8 pt recorriendo la curva: es indicador y control (TP-7): arrastrar el punto hacia la izquierda acelera el ritmo (hasta 8/min), hacia la derecha lo ralentiza (hasta 4/min), con `.selection` en cada entero. Estados: **guiando** (ola completa, punto en movimiento, texto «Guiando · 6 por minuto»), **disolviéndose** (la amplitud decrece linealmente durante los últimos 5 min; texto «Se retira · 4 min»), **retirada** (línea base sola, «Se ha retirado. El mar sigue.»), **apagada** (sin ola; solo la fila con el toggle). Reduce Motion: la ola queda fija en su forma máxima y respira por opacidad. VoiceOver: «Marea respiratoria, activada, 6 respiraciones por minuto, se retira a las 23:58; ajustable».

---

## 4. Pantallas y superficies

Alcance diseñado (no existe aún el plan de funciones): principal (reposo y sonando), mezclador = principal bajo el dedo, Marea, Temporizador, Noche, Madrugada, Noches (mezclas guardadas), Pro y prueba, primer uso, «Qué sabemos y qué no», Live Activity / Dynamic Island / StandBy, widgets, Centro de control, Watch, icono, capturas. Para 1.1 se anotan las variaciones (Marea en todas las texturas, Salud, despertar progresivo).

Convención: coordenadas (x, y) desde la esquina superior izquierda de un marco 393 × 852; textos ES / EN.

### 4.1 Principal (Descenso). Pregunta: «¿qué suena, y lo controlo?»

Fondo `negro`. Sin título de app, sin logotipo, sin cabecera.

| y | Elemento | Especificación |
|---|---|---|
| 0–59 | Barra de estado del sistema | — |
| 59–132 | Aire | Nada. Es el lujo |
| 132–160 | **Nombre de la mezcla** | Paso 2, `texto`, x = 20. Botón: abre la hoja Noches. Texto por defecto antes de guardar nada: «Esta noche» / «Tonight». A la derecha, solo cuando la mezcla difiere de la guardada: «Guardar» / «Save» 17 Regular `texto2`, 44 pt de alto |
| 168–188 | **Estado** | Paso 5, `texto2`. Reposo: «En reposo» / «Resting». Sonando: «Suena · se funde a las 00:42» / «Playing · fades at 00:42». Con Marea: «Suena · Marea 6/min · se funde a las 00:42». Sin temporizador: «Suena · sin temporizador» / «Playing · no timer» |
| 196–214 | **Prueba** (solo durante la prueba y los 7 días siguientes) | Paso 7 versalitas `texto2`: «Prueba · quedan 5 noches» / «Trial · 5 nights left». Noches 5–7: «Prueba · última noche. Después siguen gratis blanco, rosa, marrón, lluvia y 60 minutos.» en paso 6, dos líneas. Toque: hoja Pro |
| 236–332 | **Horizonte** | 3.6; centro en y = 284; punto «ahora» en x = 373 |
| 364–700 | **Seis filas de capa** | 3.1; orden fijo: Blanco, Rosa, Marrón, Lluvia, Ventilador, Océano (en 1.1 las once, agrupadas: las que suenan arriba y «Más capas ›» en una fila; nunca scroll en Large) |
| 740–800 | **Barra** | 3.5 |
| 818–852 | Indicador de inicio | sistema |

Textos de capa ES / EN: Blanco / White · Rosa / Pink · Marrón / Brown · Lluvia / Rain · Ventilador / Fan · Océano / Ocean. Subtítulo humano solo en VoiceOver y en la segunda línea de timbre: «siseo parejo / even hiss», «suave y equilibrado / soft and even», «retumbo grave / low rumble», «lluvia fina / fine rain», «ventilador lejano / distant fan», «oleaje lento / slow swell».

Qué pasa al tocar: nombre → Noches; «Guardar» → campo de nombre inline (teclado) y `.success`; fila → nivel (3.1); horizonte (pulsación larga) → líneas por capa; horizonte (arrastre hacia abajo ≥ 80 pt, «bajar la persiana») → pantalla Noche; barra izquierda → hoja Temporizador; anillo → arranca (fundido 800 ms, `.impact(.medium)`) o para; barra derecha → activa la Marea con el último ajuste y abre la hoja Marea; pulsación larga en el anillo → menú del sistema «Noche», «Dormir con la Marea», «Parar en 15 min».

**Primer uso (sin tutorial).** La primera vez, la principal se abre con la mezcla «Esta noche» = Rosa 55 + Lluvia 35 (suena bien en altavoz y en auriculares) y, bajo el estado, en lugar de la línea de prueba, una nota de dos líneas (y = 196–254) que es un solo botón de 58 pt de alto: paso 5 `texto` «7 noches con todo. Sin tarjeta.» / «7 nights with everything. No card.» y paso 6 `texto2` «Después, 29,99 € una vez; o sigue gratis con blanco, rosa, marrón y lluvia. Toca para cerrar.» / «Then 29.99 € once; or stay free with white, pink, brown and rain. Tap to close.» Un toque en el anillo y suena; la nota se va al tocarla (VoiceOver: «Entendido, botón») o a la segunda apertura, y la sustituye la línea de prueba en versalitas. Ningún permiso se pide al abrir. Un único tip de TipKit, la segunda noche, bajo la primera fila: «Arrastra sobre una capa para cambiar su nivel.» / «Drag across a layer to change its level.»

### 4.2 Mezclador. Pregunta: «¿cuánto de cada capa?»

No hay pantalla: es la principal con el dedo encima (3.1). Lo que cambia mientras se arrastra: la fila bajo el dedo pasa a 3 pt y muestra el valor en 17 Medium junto a la punta; el horizonte responde en < 300 ms porque lee el motor; nada más se mueve. Tras la prueba, para el usuario gratuito: Ventilador y Océano con nombre en `texto2`, pista vacía y «Pro» en versalitas a la derecha; tocarlas suena 30 s y abre la hoja Pro. Cero candados en la principal.

### 4.3 Marea respiratoria (hoja). Pregunta: «¿cómo respiro, y hasta cuándo?»

Hoja `.large` sobre `hoja`. Título «Marea» / «Tide».

| y (dentro de la hoja) | Elemento |
|---|---|
| 0–56 | Indicador de arrastre + título |
| 72–192 | **La ola** (3.7): 353 × 120, línea base en y = 168, trazo 2 pt `texto`, punto de fase `brasa` 8 pt. Indicador y control (arrastre horizontal = ritmo) |
| 208–230 | Estado, paso 3 `texto`: «Guiando · 6 por minuto» / «Guiding · 6 per minute»; disolviéndose: «Se retira · 4 min» / «Receding · 4 min» |
| 234–254 | Origen, paso 5 `texto2`: «Ritmo por defecto. Con Apple Watch puede partir de tu respiración nocturna.» / «Default pace. With Apple Watch it can start from your night-time breathing.» (1.1 con Salud: «Parte de tu ritmo nocturno medio, 14 por minuto, según Salud» / «Starts from your average night-time rate, 14 per minute, from Health») |
| 278 | hairline |
| 278–334 | Fila **Marea** / **Tide** con `Toggle` del sistema teñido `brasa` (el único acento de la hoja) |
| 334–390 | Fila **Ritmo** / **Pace** · valor «Lento · 6 por minuto» / «Slow · 6 per minute». Toque: tres opciones inline en paso 4: «Más lento · 5» / «Lento · 6» / «Natural · 7». Pulsación larga: stepper 4–8 con décimas |
| 390–446 | Fila **Duración** / **Duration** · valor «15 min, luego se retira» / «15 min, then recedes». Toque: 5 · 10 · 15 · 20 · 30 inline; 20 y 30 en «Pro» para el usuario gratuito |
| 446–502 | Fila **Háptica** / **Haptics** · «Mínima» / «Minimal» (Ninguna · Mínima · Marcada / None · Minimal · Pronounced). Solo visible con el iPhone en la mano |
| 502 | hairline |
| 522–562 | Paso 5 `texto2`: «Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla.» / «Breathe in as the wave rises, out as it recedes. No need to watch the screen.» |
| 578 | Paso 6 `texto2` enlace: «Por qué seis por minuto · Qué sabemos y qué no ›» / «Why six per minute · What we know and what we don't ›» |

En 1.0 la Marea actúa sobre Océano; si Océano está a cero al activarla, sube a 45 con fundido de 800 ms (se dice en el estado: «Guiando · Océano al 45»). En 1.1 modula la textura que suene (regla de descenso 12 → 6/min en 4–5 min).

### 4.4 Temporizador (hoja `.medium`). Pregunta: «¿cuándo y cómo se apaga?»

Título «Temporizador» / «Timer». Tres filas de 64 pt seleccionables por **forma**: la elegida lleva un punto lleno de 8 pt `texto` a la izquierda (x = 20), las otras un anillo de 1 pt `texto3`; el nombre en paso 3, el detalle en paso 5 `texto2`:

- **Hasta dormirme** / **Until I fall asleep** · «45 min · se funde en los últimos 10» / «45 min · fades over the last 10».
- **Escudo nocturno** / **Night shield** · «Toda la noche · baja de nivel a las 2 h · para a las 7:30 con tu alarma» / «All night · lowers after 2 h · stops at 7:30 with your alarm». «Pro» en versalitas para el usuario gratuito.
- **Siesta** / **Nap** · «20 min · se funde en los últimos 3» / «20 min · fades over the last 3».
- **Apagado** / **Off** (cuarta fila, sin detalle).

Debajo, para la fila elegida, **la escala**: una línea de 1 pt `texto3` de margen a margen con marcas de 1 × 6 pt cada 15 min y cifras paso 7 debajo (15 · 30 · 45 · 60 · 90 · 120); el valor actual con un punto de 8 pt `texto` que se arrastra (`.selection` por marca). Valores > 60 llevan «Pro» en versalitas junto a la cifra para el usuario gratuito; elegir uno abre la hoja Pro sin perder el ajuste anterior. Pie en paso 6: «El sonido se funde antes de terminar. Tu alarma no se silencia.» / «Sound fades before the end. Your alarm is never silenced.» Prolongar desde cualquier superficie: «+15 min» es el arrastre hacia arriba en Noche, el botón de la Live Activity y la corona del Watch.

### 4.5 Pantalla Noche. Pregunta: «¿va todo bien?»

`fullScreenCover`, fondo `negro`, fase Noche, `UIApplication.isIdleTimerDisabled = false` (la pantalla puede apagarse; el sonido sigue). Entrada: «bajar la persiana» en la principal, el menú del anillo, o automática a los 20 s de empezar a sonar entre las 21:00 y las 6:00 si el iPhone está quieto y horizontal (CoreMotion; sin señal, no se entra sola).

| y | Elemento |
|---|---|
| 284 | **Horizonte congelado**: 1 pt `brasa-noche` (4,63), de borde a borde; continuo = suena, discontinuo (6/6) = en pausa |
| 340–420 | **Reloj** paso 1, 72 pt Rounded Regular tabular `texto-noche` (8,03), centrado: «03:12». Actualiza 1 vez por segundo (minuto si `isLuminanceReduced`) |
| 436–464 | Paso 2 Medium `texto-noche`: «Se funde a las 03:42» / «Fades at 03:42»; sin temporizador: «Toda la noche» / «All night»; en pausa: «En pausa» / «Paused» |
| resto | Nada. Ni botones, ni nombre de mezcla, ni logotipo |

Gestos (toda la pantalla es el botón, 393 × 852): **toque** = pausa / reanuda (fundido, sin háptica); **arrastre hacia arriba** = +15 min por cada 60 pt, la hora de fundido se actualiza bajo el dedo; **arrastre hacia abajo ≥ 80 pt** = volver a la principal. VoiceOver: un solo elemento «Suena Lluvia fina y marrón, se funde a las 3:42; toca dos veces para pausar; acciones: añadir 15 minutos, salir». Reduce Motion: idéntica (no hay movimiento). Acceso asistido: esta pantalla con un único botón «Pausar / Reanudar».

### 4.6 Modo Madrugada. Pregunta: «¿puedo volver a dormirme sin despertarme del todo?»

Se entra solo: si el usuario desbloquea el iPhone ≥ 20 min después del último bloqueo mientras la app estaba sonando o había terminado hace < 2 h, la app abre directamente aquí; también desde la Live Activity («Madrugada») y el Watch. Fase Madrugada: fondo `negro`, **solo el horizonte** (1,5 pt `brasa-madrugada`, 3,19), nada de texto. Un toque: si estaba parado, arranca la última mezcla al 60 % de su nivel con la Marea de 20 min que se disuelve sola (`.impact(.medium)` una vez); si sonaba, pausa. Tras el toque, el reloj aparece 5 s en 34 pt Medium `texto-madrugada` (6,35) a y = 420 y se funde. Arrastre hacia arriba = +15 min. Sale solo al bloquear; «bajar la persiana» al revés (arrastre hacia abajo) lleva a la principal. Es la respuesta al 50–59 % que vuelve a la app a las 3 (JMIR 2020) sin convertirlo en terapia.

### 4.7 Noches (mezclas guardadas, hoja `.large`). Pregunta: «¿cuál de mis noches?»

Título «Noches» / «Nights». Las «mezclas guardadas» se llaman **noches** porque es lo que son (el usuario no mezcla: duerme). Dos secciones con cabecera en versalitas paso 7 `texto2`: **Tuyas** / **Yours** y **De la casa** / **From the house** (los presets del PR #3, redactados como noches: «Lluvia constante» / «Steady rain», «Concentración» / «Focus», «Mar lento» / «Slow sea», «Avión de noche» / «Night flight» en 1.1). Fila de 64 pt: nombre paso 3 `texto`; detalle paso 5 `texto2`: «Lluvia 65 · Marrón 40 · Marea 15 min · hasta dormirme». La fila es un objeto que se coge: toque = carga y suena (fundido cruzado de 1,5 s); deslizar = Renombrar / Borrar (del sistema); arrastrar = reordenar. Límite gratuito tras la prueba: las guardadas se conservan; guardar una más dice, inline bajo el campo de nombre: «Guardar más noches es parte de Pro.» / «Saving more nights is part of Pro.» con enlace a la hoja. Vacío: una sola frase paso 4 `texto2` centrada: «Guarda la mezcla de esta noche desde su nombre.» / «Save tonight's mix from its name.», sin icono. Persistencia: `UserDefaults` + copia en iCloud key-value (sobrevive a reinstalar y a cambiar de iPhone).

### 4.8 Pro y prueba (hoja `.large`). Pregunta: «¿cuánto, y qué pasa si no?»

Se abre solo por toque (prueba, capa Pro, valor Pro, Ajustes). Fondo `hoja`. Sin título en la barra.

| y | Elemento |
|---|---|
| 72 | Versalitas paso 7 `texto2`: «SleepNoise Pro» |
| 96–160 | **Precio** paso 1, 56 pt Rounded Regular tabular `texto`: «29,99 €» / «$29.99» (precio de StoreKit, nunca escrito a mano). Debajo, paso 4 `texto2`: «Una vez. Sin suscripción. Compartido en familia.» / «Once. No subscription. Family Sharing included.» Si hay precio de lanzamiento: «Precio de lanzamiento hasta el 14 de diciembre; después 34,99 €» en paso 6, sin tachaduras |
| 184 | hairline |
| 184–464 | Cinco filas de 56 pt, paso 4 `texto`, separadas por hairline, sin iconos: «Seis capas, y las que vengan» / «Six layers, and the ones to come» · «Marea respiratoria» / «Breathing tide» · «Escudo nocturno y temporizador sin límite» / «Night shield and unlimited timer» · «Noches guardadas sin límite» / «Unlimited saved nights» · «Apple Watch, widgets y Centro de control» / «Apple Watch, widgets and Control Center» |
| 464 | hairline |
| 480–520 | Paso 5 `texto2`: «Sigue siendo gratis: blanco, rosa, marrón, lluvia, 60 minutos de temporizador y las noches que ya guardaste.» / «Stays free: white, pink, brown, rain, a 60-minute timer and the nights you already saved.» |
| 548–604 | **Botón primario de compra** (3.2): «Comprar · 29,99 €» / «Buy · $29.99». Durante la prueba, encima en paso 7 versalitas: «Prueba · quedan 5 noches · todo abierto» / «Trial · 5 nights left · everything open» |
| 620–664 | Secundario «Restaurar compra» / «Restore purchase» |
| 680 | Paso 6 `texto2`: «Nada sale de tu iPhone.» / «Nothing leaves your iPhone.» · «Qué sabemos y qué no ›» / «What we know and what we don't ›» |

Tarjeta de prueba previa (guía 3.1.1, si la prueba pasa a non-consumable a 0 €): misma hoja con el precio sustituido por «7 noches» / «7 nights» en paso 1 y debajo «Con todo. Sin tarjeta. Después, 29,99 € una vez o la versión gratuita.» / «Everything. No card. Then $29.99 once, or the free version.»; botón «Empezar la prueba» / «Start the trial». Se valoran 14 noches: la cifra cambia, el diseño no.

### 4.9 «Qué sabemos y qué no» (pantalla de lectura, push)

Fondo `negro`, texto largo en New York Regular 17/26 (`.body`, única excepción tipográfica, solo aquí) sobre columna de 353. Sin iconos ni sellos. Estructura por afirmación: la frase que usa la app entre comillas en paso 3 SF Semibold; debajo, tres líneas en New York: *Lo que sostiene* (estudio, año, n, financiación), *Lo que no dice*, *Cómo lo usamos*. Entradas iniciales: «Enmascara los sonidos que te despiertan» (Stanchina 2005), «Te acompaña a respirar más despacio» (Zaccaro 2018, Tsai 2015), «Sonido que nunca se repite» (medición propia: horas sin repetir una muestra), «No es un producto sanitario». Enlace desde cada afirmación de la app y de la ficha.

### 4.10 Live Activity, Dynamic Island, StandBy

Diseñadas primero en rojo y después sin filtro. Una sola tinta (`texto`), `brasa` solo como forma ≥ 3 pt. Un control.

- **Pantalla de bloqueo (expandida, 361 × 128)**: fila 1: glifo de ola 22 pt + nombre de la mezcla 17 Semibold; a la derecha, botón `pause.fill` / `play.fill` en anillo de 44 pt (`AudioPlaybackIntent`, el único control). Fila 2: **horizonte estático** 2 pt `brasa`, de margen a margen, continuo = suena / discontinuo = pausa; su altura es el nivel maestro al emitir. Fila 3: «Se funde a las 00:42 · 42 min» 15 Medium `texto` (`Text(timerInterval:)` para que cuente sin actualizaciones). Fondo removible, `activityBackgroundTint(.black)`.
- **Dynamic Island compacta**: leading glifo de ola (continua/discontinua); trailing «42 min» 15 Medium tabular. **Mínima**: el glifo. **Expandida**: la de bloqueo.
- **StandBy**: la expandida escalada ×2 a pantalla completa (852 × 393): horizonte a un tercio (y = 131), nombre arriba a la izquierda a 34 pt, hora de fundido abajo a 44 pt Rounded, anillo de 88 pt a la derecha. Bajo el tinte rojo: `texto` → `#E80000` (4,43), `brasa` → `#C90000` (3,48 como forma). Toque = pausa. Actualizaciones solo al cambiar de estado (inicio, cada hito del temporizador, +15, fin); terminación `.immediate` al acabar el fundido.

### 4.11 Widgets

- **Pequeño (158 × 158)**: glifo de ola 28 pt arriba a la izquierda (18, 18); anillo de 44 pt con `pause.fill` arriba a la derecha (interactivo, el único control); «Suena» / «Playing» 17 Semibold en y = 82; «42 min» 34 Rounded tabular en y = 102, alineado al margen izquierdo de 18. Fondo negro removible; en *accented* y *vibrant* todo pasa a la tinta del sistema sin perder el estado (forma). En reposo: «En reposo» / «Resting» y `play.fill`: un toque arranca la última noche.
- **Mediano (338 × 158)**: lo mismo más, a la derecha, la última noche guardada como fila (nombre + detalle) con `AudioPlaybackIntent` propio.
- **Pantalla de bloqueo circular**: glifo de ola; rectangular: «Suena · 42 min».

### 4.12 Centro de control y botón de Acción (iOS 18)

`ControlWidgetToggle` «SleepNoise»: símbolo propio de ola, variante continua (on, tinte `brasa`) / discontinua (off, gris), etiqueta «Suena» / «Playing» y «En reposo» / «Resting». Segundo control de botón «Marea 20 min» / «Tide 20 min» para el botón de Acción con *hint* «Mantén para dormir» / «Hold to sleep». En iOS 17, el Atajo «Dormir con SleepNoise» cubre el caso.

### 4.13 Apple Watch (mínimo, 1.1)

Una pantalla: horizonte a un tercio de la esfera, estado en 17 Semibold («Suena» / «Playing»), hora de fundido en 34 tabular; toda la pantalla pulsa / reanuda; la corona añade 15 min por detent (`.directionUp`); pulsación larga activa la Marea 20 min. Smart Stack: la misma tarjeta. La Marea háptica vive aquí de forma natural: `.directionUp` al inicio de cada inhalación durante toda la guía («Marcada») o 5 respiraciones («Mínima»). Sin tracking, sin HealthKit en 1.0.

### 4.14 Icono

**Idea**: la marea de un ciclo con el punto «ahora». Un objeto que podría estar grabado en el panel de una radio Braun.

Construcción (lienzo de 1024, Icon Composer, dos capas):

1. **Fondo**: `negro` (Dark y Default), `papel` (Light), sin degradado. En Clear y Tinted el sistema lo sustituye.
2. **Trazo** (capa 1): una sola trayectoria de 56 px de grosor, extremos redondos, en `texto` (`tinta` en Light). Línea base en y = 640. Empieza en (112, 640), recta hasta (288, 640); **sube** con la curva respiratoria (Bézier cúbica con tangentes horizontales) hasta la cresta en (528, 400): la subida ocupa 240 px (40 % de la ola); **baja** hasta (888, 640) en 360 px (60 %): la asimetría 4:6 es literal; recta hasta (912, 640).
3. **Punto** (capa 2): círculo de 104 px de diámetro centrado en la cresta (528, 400), relleno `brasa` (`cobre` en Light). En Tinted el sistema lo monocromatiza; el estado sigue leyéndose por forma (una cresta con punto).

A 29 pt el trazo mide 1,6 pt y el punto 2,9 pt: legible y distinto de todas las lunas, nubes y ondas de la categoría. Nombre junto al icono en la ficha: «SleepNoise»; sin logotipo tipográfico dentro de la app.

### 4.15 Las seis capturas de la App Store (es-ES; en-US idéntica)

Marco: iPhone 17 Pro sobre fondo `negro` sin bisel decorativo; titular en paso 2 Medium `texto` arriba, una línea; sin degradados ni ilustraciones. Orden:

1. **«Sonido que nunca se repite. Un solo pago.»** Principal sonando: el horizonte vivo, «Lluvia fina y marrón», seis capas, barra. Debajo en paso 5: «Generado en tu iPhone · 29,99 € una vez · sin cuentas».
2. **«Seis capas bajo un dedo.»** Principal con la fila Lluvia bajo el dedo (3 pt, «65»).
3. **«La ola sube 4 segundos y baja 6. Tú respiras con ella.»** Hoja Marea guiando.
4. **«A las 3 de la mañana, solo esto.»** Pantalla Noche (negro, horizonte, reloj). Es la captura que más se parece a una pantalla apagada y, por eso, la más honesta.
5. **«Desde la mesilla, sin encender nada.»** StandBy en rojo nocturno con la Live Activity y, pequeño, el widget.
6. **«Lo que no hay.»** Lista tipográfica sobre negro: «Sin suscripción. Sin cuenta. Sin anuncios. Sin red. Sin puntuación. Sin racha. Data Not Collected.»

Preview muda de 30 s: 0–8 s un toque y el horizonte nace; 8–16 s el dedo recorre una capa y la línea cambia; 16–26 s la Marea se ralentiza de 7 a 6 por minuto; 26–30 s bajar la persiana: Noche.

---

## 5. Qué se elimina de la app actual y por qué

| Se elimina | Por qué |
|---|---|
| Título «SleepNoise» y subtítulo «Para la noche» | No informan a quien ya abrió la app (P5); el nombre vive en la ficha. El sitio lo ocupa el nombre de la mezcla |
| Fondo `#0E1114` con degradado y halo ámbar radial | No es negro, hace bandas en OLED y es decoración sin causa (P3, P4) |
| Siete tarjetas (prueba, Marea, capas) con radio 18 | Tarjetas por doquier (P6); el agrupado se hace con aire y hairlines |
| Cápsula «Prueba · 7 días» y botón «Pro» en cabecera | Badges y presión de venta en la principal (P9); la prueba es una línea de texto |
| Iconos en círculo por capa (`waveform`, `speaker`, `fan`) | Iconografía de biblioteca y mezcla de estilos; las palabras son los iconos |
| Play relleno de 88–112 pt en ámbar | Acento como superficie y fuente de luz; pasa a un anillo de 64 pt y el acento pasa al horizonte |
| Segundo acento `mist` (#A7BEC0) | Muere bajo rojo (2,6) y rompe «un acento» |
| Botón «Cerrar» en cápsula, títulos de hoja centrados con botón | La hoja del sistema ya se cierra (P12) |
| Rejilla 2 × 2 del temporizador y «Personalizado» repetido | Cinco botones para una decisión; se sustituye por tres intenciones con nombre y una escala |
| Stepper «6 por minuto» y cinco botones de duración como primera capa de la Marea | Lo técnico encima del gesto (P11); pasa a la ola arrastrable y a filas con nombre humano |
| Reloj SF Rounded Light 44 | Peso Light a oscuras (HIG); pasa a Rounded Regular 72 |
| `lock.fill`, cápsulas «PRO» ámbar, opacidad 0,72 en filas bloqueadas | Candados y castigo visual; la capa Pro suena 30 s y se dice con una palabra |
| Icono de «mezclas» en verde-gris en cabecera | Entrada escondida y segundo acento; las noches se abren desde el nombre de la mezcla |
| Estado vacío con icono ámbar centrado | Icono decorativo; una frase basta |

Se conserva: la frase «7 noches con todo. Sin tarjeta.» (ajustada de «días» a «noches»), el texto de la Marea («Inhala mientras la ola sube…»), la nota de fundido del temporizador, el toggle del sistema en la Marea, `sensoryFeedback`, el `BreathIndicator` aislado en su `TimelineView`, los identificadores de accesibilidad y el lint de palabras médicas.

## 6. Qué se aprovecha del PR #3 y cómo se expresa aquí

| Del PR #3 | En «Marea» |
|---|---|
| **Pantalla Noche en negro puro** con «The screen can sleep. Sound keeps playing.» | Es la fase Noche (4.5), con el contraste corregido (8,03 en vez de 2,7), sin botones (toda la pantalla es el control) y con el horizonte congelado como único estado por forma. La frase pasa a VoiceOver y al primer tip, no a la pantalla |
| **Presets de un toque** («Deep sleep», «Focus», «Steady rain») | Son «noches de la casa» en la hoja Noches (4.7), redactadas como noches y sin emoji ni chip; se cargan con un toque y se pueden guardar como propias |
| **Camas / «Bedtime»** (un botón que arranca y baja la luz) | Se reparte en dos gestos con causa: el anillo arranca; «bajar la persiana» (arrastre hacia abajo en el horizonte) entra en Noche. El menú largo del anillo ofrece «Dormir con la Marea» para quien quiere un solo toque |
| **Motor, modelo y Atajos** (PR-A de la revisión) | Se asumen sin cambios de interfaz; el Atajo «Dormir con SleepNoise» cubre iOS 17 donde no hay Control |
| **Tokens claros con AA** | La paleta «papel» hereda la idea; los valores son los de 2.1 |
| Lo que no se toma | Rejilla de once baldosas, chips, disco de 300 pt, asa falsa «Levels», SF Rounded en cuerpo, 14 candados, degradado animado a 15 fps |

## 7. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| **La primera impresión en la tienda es «no hay nada»** (en reposo el horizonte es una recta tenue) | La principal nunca está vacía: nombre, seis capas con dos ya a nivel y la barra. La mezcla por defecto «Esta noche» viene con Rosa 55 y Lluvia 35, así que la primera pantalla ya tiene dos líneas llenas; un toque y el horizonte nace. La captura 1 es la pantalla sonando, no en reposo |
| **El ámbar es el color más compartido** (Halide, Hatch, Calm cálido, la propia app) | `brasa` es más oscuro y menos saturado que todos ellos (8,9 frente a 11,6), y nunca es superficie: línea de 1,5 pt y punto de 6 pt. Si en la prueba de cinco segundos se confunde con «otra app de sueño cálida», el plan B medido es amarillo Lubs `#FFCC00` como punto únicamente (13,9; bajo rojo 5,25) |
| **Arrastrar sobre una fila choca con el scroll** en AX1+ | En Large no hay scroll (todo cabe en 852). Desde AX1 se activa bloqueo de eje (`DragGesture` con `minimumDistance: 4` y umbral angular 30°) y el valor también se ajusta con VoiceOver `.adjustable` y con pulsación larga + stepper |
| **El horizonte cuesta CPU/GPU toda la sesión** | 20 Hz, un solo `Canvas`, pausado si no suena, si `scenePhase != .active`, en Noche, Madrugada y `isLuminanceReduced`. Presupuesto: ≤ 30 % de lo que cuesta el motor con pantalla encendida, 0 con pantalla apagada (Instruments, 10 min bloqueado) |
| **La ola y el audio se desfasan** (AirPlay hasta 2 s, Bluetooth 150–300 ms) | La ola es un `KeyframeAnimator` reanclado por ciclo a `guide.anchor` corregido con `outputLatency`; la prueba de aceptación es un vídeo a 240 fps con el nivel de salida |
| **Noche automática entra cuando no se quiere** (uso de día en el escritorio) | Solo entre 21:00 y 6:00, solo con el iPhone quieto y horizontal 20 s, solo si no hay interacción; se puede apagar en Ajustes («Entrar en Noche solo») y se sale con un arrastre |
| **La capa Pro que «suena 30 s» se percibe como anuncio** | Solo ocurre al tocar la fila (nunca sola), sin háptica ni animación, y el fundido de salida es el mismo que el de cualquier capa; la hoja Pro se abre debajo, no encima del sonido |
| **StandBy / Live Activity: Apple no publica la matriz del tinte rojo** | Diseñado con el modelo más severo (canal R); una sola tinta; estado por forma. Validación con foto calibrada a un metro antes de la ficha |
| **El nombre «Noches» para las mezclas** no se encuentra al buscar «mezclas» | VoiceOver y Atajos exponen ambos («Noches (mezclas guardadas)»); el botón «Guardar» dice «Guardar esta noche» en su tip |
| **Dos letras** (New York en «Qué sabemos y qué no») | Solo en esa pantalla de lectura, nunca en controles ni de noche; si el dueño prefiere una sola familia, SF Pro 17/26 sin pérdida |
| **Prueba local sin StoreKit (3.1.1)** | El diseño es el mismo con prueba local o con non-consumable a 0 €: cambia la primera línea de la hoja Pro, no la estructura |

## 8. Autoevaluación rápida contra los doce principios

P1 noche primero: toda superficie se definió primero en fase Noche y Madrugada. P2 un gesto: toque = pausa, arrastre arriba = +15, fila = nivel, en app, Live Activity y Watch. P3 negro real: > 90 % de píxeles apagados en reposo nocturno; un acento. P4 causa en el sonido: tabla 2.4 completa. P5 una familia: SF Pro (+ Rounded en cifra; New York solo en lectura larga); ≤ 6 estilos por pantalla. P6 aire: cero rectángulos rellenos en la principal; ≤ 2 en cualquier otra (toggle, botón de compra). P7 forma: continuo/discontinuo, lleno/anillo, `.fill`/contorno. P8 44 / 64: filas 56, anillo 64, Noche 100 %. P9 nada bloquea: cero candados; la hoja Pro solo tras un toque; el gratuito del día 8 suena con 60 min sin ver precio. P10 una decisión por pantalla: la pregunta está escrita en cada título de 4.x. P11 técnico debajo: ritmo exacto, timbre y dB bajo pulsación larga. P12 sistema: hojas, toggle, barra, Live Activity, Control del sistema; propios solo horizonte, fila-nivel, ola, anillo.

---

# Parte II · Interacción

**Diseño de interacción del equipo Marea · 16 de noviembre de 2026.** Esta parte amplía el concepto sin tocar lo anterior: los flujos completos, la especificación de movimiento y háptica, las superficies del ecosistema, la accesibilidad y los textos definitivos en los dos idiomas. Donde una decisión de la Parte I se precisa o se corrige, se dice en una nota marcada **Precisión**. Convenciones: tiempos en segundos salvo indicación; «la principal» es 4.1; «Noche» y «Madrugada» son 4.5 y 4.6; «la barra» es 3.5; «el anillo» es el botón de reproducir (3.2). El plan de funciones por versión no existía al escribir; el alcance 1.0 es el de la Parte I y las variaciones 1.1 (Marea en todas las texturas, Salud, despertar progresivo, Watch) van anotadas.

## 9. Flujos completos paso a paso

Cada flujo lleva la pregunta del usuario, lo que hace, lo que ve, lo que oye y lo que siente, y lo que **no** pasa (porque lo que no hay es parte del producto). Los textos exactos están en §14; aquí se citan en español y la versión inglesa está allí.

### 9.1 La primera noche, sin tutorial

Pregunta: «¿qué es esto y cómo lo enciendo?»

1. **Toque en el icono.** La app abre en menos de un segundo, directamente en la principal, fase Descenso. Nada se pide: ni notificaciones, ni Salud, ni micrófono, ni valoración. No hay pantalla de bienvenida, carrusel ni logotipo.
2. **Lo que ve** (marco 1 de la maqueta): «Esta noche» como nombre de mezcla; debajo «En reposo»; debajo la nota de prueba en dos líneas («7 noches con todo. Sin tarjeta.» / «Después, 29,99 € una vez; o sigue gratis con blanco, rosa, marrón y lluvia. Toca para cerrar.»); el horizonte en reposo (recta de 1 pt, `brasa-tenue`); seis filas, con Rosa en 55 y Lluvia en 35 ya llenas; la barra con «Temporizador», el anillo y «Marea». Lo único que puede leerse como instrucción es la propia forma de las filas: dos tienen una línea llena.
3. **Toque en el anillo.** Háptico `.impact(.medium, 0.7)` en el mismo instante en que empieza el fundido de 800 ms del motor. El horizonte deja de ser recta: en esos 800 ms la amplitud crece de 0 a la envolvente real y aparece el punto «ahora». El glifo pasa de `play.fill` a `pause.fill` con `.replace`. El estado cambia a «Suena · sin temporizador». La nota de prueba sigue ahí.
4. **Lo que oye:** rosa suave y lluvia fina, sin ataque, a nivel maestro 60 % del sistema (el nivel del sistema no se toca; si está a 0 la app lo dice en el estado: «Suena · el volumen del iPhone está al mínimo»).
5. **Si arrastra sobre una fila** sin que nadie se lo haya dicho (sucede en la mayoría de pruebas con Dark Noise y Bear: la línea invita), la fila responde según 3.1. Si no lo hace, no pasa nada: el tip llega la segunda noche.
6. **Toque en la nota de prueba:** se funde en 250 ms y en su sitio aparece, a la segunda apertura, la línea en versalitas «prueba · quedan 7 noches». Si no la toca, se va sola en la segunda apertura.
7. **Bloquea el iPhone.** Suena igual. En la pantalla de bloqueo aparece la Live Activity (§12.1) con el nombre «Esta noche», el horizonte estático, «Sin temporizador» y el anillo de pausa. No hay notificación.
8. **Lo que no pasa:** no se pide valorar la app, no hay recordatorio al día siguiente, no se entra en Noche automáticamente la primera noche (la entrada automática se activa a partir de la segunda noche, para que la primera impresión sea la pantalla completa). No se guarda nada: «Esta noche» es la mezcla viva, y «Guardar» no aparece hasta que la mezcla difiera de la de fábrica.

Onboarding completo, por momentos, en §15.

### 9.2 Sesión normal (noche 3 en adelante)

Pregunta: «¿suena lo de siempre, y se apagará sola?»

1. Abre la app: la principal muestra la última mezcla por su nombre («Lluvia fina y marrón») y, si la última sesión tenía temporizador, la barra ya dice «45 min» (la intención del temporizador se recuerda con la noche; el valor se recuerda entre sesiones).
2. Toque en el anillo: fundido 800 ms, `.impact(.medium)`. Estado: «Suena · se funde a las 00:42» (la hora se calcula al arrancar, no al abrir la hoja).
3. Si quiere cambiar el temporizador: toque en «45 min» → hoja media (4.4) → toque en otra intención o arrastre del punto en la escala → arrastra la hoja hacia abajo. El estado y la barra se actualizan al soltar; nada se confirma.
4. Deja el iPhone en la mesilla. A los 20 s quieto y horizontal (solo entre 21:00 y 6:00): la pantalla pasa a Noche con 2 s de fundido de luminancia (texto → `texto-noche`, acento → `brasa-noche`, filas y barra → opacidad 0; el horizonte se congela en su última forma). Si el iPhone está en la mano, nada cambia; «bajar la persiana» (arrastre hacia abajo ≥ 80 pt sobre el horizonte) entra en Noche a voluntad.
5. La pantalla se apaga sola con el ajuste del sistema (no se bloquea el `idleTimer`). El sonido sigue. Con Always-On, la Noche se queda tal cual, porque ya está quieta.
6. Fundido final: en los últimos 10 min el nivel real baja; el horizonte en Noche sigue congelado (no hay nada que ver) y la Live Activity recibe **una** actualización al empezar el fundido («Se funde · 10 min») y otra al terminar (`.immediate`, desaparece). Sin háptica, sin sonido final.
7. Por la mañana no hay nada: ni resumen, ni «¿cómo has dormido?», ni notificación. Al abrir la app a mediodía, la principal está en Descenso con la misma mezcla.

### 9.3 Ajustar una capa a oscuras (3:10, la lluvia molesta)

Pregunta: «¿puedo bajar la lluvia sin encenderme la cara?»

1. Coge el iPhone. Face ID. Está en Noche (si la app estaba delante al bloquear) o en Madrugada (si hace ≥ 20 min). Ambas son negras.
2. **Arrastre hacia abajo ≥ 80 pt** en cualquier punto. La principal vuelve, pero **en luminancia de Noche**: `texto-noche` (8,03) en nombres y valores, `brasa-noche` en el horizonte, barra visible. **Precisión** respecto a 4.1: entre las 21:00 y las 6:00 la principal a la que se vuelve desde Noche o Madrugada hereda la fase Noche; vuelve a Descenso solo si el usuario pulsa el nombre de la mezcla (señal de que quiere trabajar) o pasa de las 6:00. Es la respuesta a «tipografía frente a no leer» del brief: la misma pantalla, menos luz.
3. Pone el dedo sobre la fila «Lluvia» (56 pt de alto: el objetivo es toda la fila, no la línea) y arrastra hacia la izquierda. La línea pasa a 3 pt, el valor «65 → 40» aparece junto a la punta en 17 Medium. El horizonte baja de amplitud en < 300 ms porque lee el motor, no el gesto. No hay háptica en los pasos intermedios; `.selection` solo si cruza el cero.
4. Suelta. La fila vuelve a 2 pt; el valor se queda en «40» en `texto2`. Nada se guarda: la noche guardada sigue siendo la que era, y «Guardar» aparece a la derecha del nombre (en `texto-noche`) por si mañana quiere conservarlo.
5. Deja el iPhone. A los 20 s quieto y horizontal vuelve a Noche sola. O arrastra hacia abajo sobre el horizonte.
6. **Volumen general**: los botones físicos, siempre. En Noche y Madrugada los botones de volumen funcionan como en cualquier reproductor; la app no dibuja su propio indicador (el del sistema ya es discreto desde iOS 13). Un ajuste de nivel maestro propio no existe en 1.0: las seis capas y el volumen del sistema bastan; evita un séptimo control.
7. **Lo que no pasa:** no se enciende la fase Descenso; el horizonte no vuelve a moverse hasta que el usuario toca una fila (en Noche heredada la envolvente se queda congelada salvo durante el arrastre, para que la pantalla no vibre mientras se mira medio dormido).

### 9.4 Activar la Marea: lo que se ve, se oye y se siente durante 15 minutos

Pregunta: «¿cómo respiro con esto, y cuándo me deja en paz?»

**Activación.** Toque en «Marea» en la barra. Dos cosas a la vez: (a) la Marea se activa con el último ajuste (por defecto 6 por minuto, 15 min, háptica Mínima) y (b) se abre la hoja Marea. Si Océano está a cero, sube a 45 con fundido de 800 ms y el estado lo dice: «Guiando · Océano al 45». Si el usuario cierra la hoja de inmediato, la Marea sigue: la hoja es para ajustar, no para activar.

**Minuto 0 → 1: el enganche.** El primer ciclo no empieza en mitad de una inhalación: la ola arranca en la base (marea baja) y la primera subida comienza en el siguiente ancla del motor (`guide.anchor`, como mucho 1,5 s de espera). Lo que se oye: el oleaje de Océano se hincha durante 4 s (más nivel, filtro más abierto, el «rompiente» más cerca) y se retira durante 6 s (menos nivel, filtro más cerrado, el «arrastre» de la arena). Las demás capas no cambian: la lluvia sigue siendo lluvia. Lo que se ve: en la hoja, la ola grande (353 × 120) con el punto `brasa` de 8 pt recorriendo la curva; en la principal (si se cierra la hoja), la misma ola lenta superpuesta a la envolvente en el horizonte, con el punto «ahora» subiendo con la inhalación. Lo que se siente (háptica Mínima, solo con el iPhone en la mano): un patrón continuo de Core Haptics cuya intensidad sigue la misma `BreathCurve` (sube con la ola, baja con el reflujo), nitidez 0,2, durante **las primeras cuatro respiraciones**; después se retira. Si el iPhone está sobre la mesilla (CoreMotion quieto y horizontal), no vibra nunca.

**Minutos 1 → 10: la guía.** Nada cambia de forma; la ola se repite seis veces por minuto, idéntica, resincronizada por ciclo con el audio (compensa Bluetooth y AirPlay). El usuario deja de mirar: el texto de la hoja lo dice («No hace falta mirar la pantalla»). Si bloquea el iPhone, la Live Activity muestra el glifo de ola con el punto en la cresta (estado «guiando»), y el trailing de la Dynamic Island alterna cada 30 s entre «6/min» y el tiempo de temporizador si lo hay. Si la pantalla sigue encendida y pasa a Noche automática, la ola se congela en marea baja y el reloj aparece; la Marea sigue sonando y vibrando (si procede) aunque no se vea: la guía es el sonido.

**Ajustar el ritmo sin mirar cifras.** En la hoja, arrastrar el punto hacia la izquierda acelera (hasta 8/min), hacia la derecha ralentiza (hasta 4/min), con `.selection` en cada entero; el estado dice «Guiando · 5 por minuto». El cambio de período se aplica al siguiente ciclo, nunca a mitad de una respiración. Pulsación larga sobre la fila «Ritmo» abre el stepper con décimas (lo técnico, debajo del gesto).

**Minutos 10 → 15: la disolución.** La amplitud de la modulación (nivel y filtro) decrece linealmente de 100 % a 0 % durante los últimos 5 min. Se oye como un mar que se calma: cada ola un poco menos alta que la anterior, hasta que Océano queda al nivel constante de 45. Se ve, en la hoja, como la ola que pierde altura ciclo a ciclo manteniendo la base; en la principal, la ola lenta se aplana dentro de la envolvente; el punto de fase sigue recorriendo la curva cada vez más plana. El estado dice «Se retira · 4 min». No hay háptica (se retiró en el minuto 1). La Live Activity recibe una única actualización al entrar en disolución: el glifo pasa a «punto en la base».

**Minuto 15: retirada.** El último ciclo termina en la base; la ola de la hoja es la línea base sola; el estado dice durante 10 s «Se ha retirado. El mar sigue.» y después vuelve al estado general («Suena · se funde a las 00:42»). En la barra, el glifo de Marea pierde el punto y la etiqueta vuelve a decir «Marea». Océano sigue sonando a 45: la Marea nunca apaga una capa que ella encendió, porque apagarla sería un cambio audible y lo que el usuario necesita a esa hora es que nada cambie. Si el usuario prefiere que Océano se vaya, la fila «Duración» tiene, bajo pulsación larga, «Al retirarse: dejar el mar / retirar también el mar».

**Reduce Motion.** La ola de la hoja queda en su forma máxima y respira por opacidad (0,55 → 1,0 → 0,55) con la misma curva; en la principal, el horizonte deja de ondular y la ola lenta se dibuja por opacidad. El punto de fase no se mueve: cambia de opacidad con la ola. La háptica no depende de Reduce Motion.

**1.1.** La Marea modula la textura que suene (lluvia, ventilador, rosa) con la regla de descenso 12 → 6/min en 4–5 min; con permiso de Salud (solo lectura), parte de la frecuencia respiratoria nocturna media y lo dice en la línea de origen. Sin permiso, funciona igual con el valor por defecto; el permiso se pide dentro de la hoja, al tocar «Partir de tu respiración», nunca antes.

### 9.5 Temporizador de tres modos

Pregunta: «¿cuándo y cómo se apaga, y mi alarma?»

1. Toque en «Temporizador» (o en «45 min») en la barra. Hoja media sobre `hoja`. Las tres intenciones y «Apagado», elegidas por forma (punto lleno / anillo). La fila elegida al abrir es la última usada; la primera vez, «Hasta dormirme».
2. **Hasta dormirme**: toque → el punto se llena, la escala aparece debajo con el valor actual (45) marcado. Arrastre del punto por la escala: `.selection` por marca de 15 min; el detalle de la fila cambia en vivo («60 min · se funde en los últimos 10»). Para el usuario gratuito, las marcas > 60 llevan «pro» en versalitas; arrastrar hasta ellas abre la hoja Pro **al soltar** (no mientras arrastra) y el valor vuelve al último válido.
3. **Escudo nocturno**: toque → la escala se sustituye por una fila de hora: «Para a las 7:30» con un `DatePicker` compacto del sistema (solo hora). **Precisión** respecto a 4.4: la app no puede leer la alarma del Reloj ni el horario de Sueño; la hora de parada la fija el usuario una vez y la app la recuerda. El detalle dice «Toda la noche · baja de nivel a las 2 h · para a las 7:30», y el pie recuerda que la alarma del sistema nunca se silencia (la app no la controla; simplemente no la pisa: la sesión es `.playback` con `mixWithOthers` desactivado, y la alarma del Reloj suena por encima). Para el usuario gratuito la fila lleva «pro»; tocarla abre la hoja Pro y el punto no se mueve.
4. **Siesta**: 20 min por defecto, escala 10 · 15 · 20 · 30 · 45. El fundido es más corto (3 min) y el estado de la principal dice «Siesta · se funde a las 15:42».
5. **Apagado**: sin escala; estado «Suena · sin temporizador».
6. Cierre: arrastrar la hoja o tocar fuera. No hay botón de aceptar: el valor que se ve es el que vale.
7. **Prolongar desde cualquier sitio**: +15 min por arrastre hacia arriba en Noche y Madrugada (cada 60 pt de recorrido, el texto «Se funde a las 03:57» cambia bajo el dedo, `.selection` por escalón); botón «+15» en la Live Activity expandida (sustituye al anillo mientras queda < 20 min, porque a esa hora prolongar es más probable que pausar); corona del Watch; Atajo «Añade 15 minutos a SleepNoise».
8. **Fundido**: en los últimos 10 min (3 en siesta) el nivel baja con curva `easeInOut` en el motor, y el espectro se oscurece ligeramente (el corte de agudos baja: un sonido que se aleja, no que se apaga). El horizonte en Descenso enseña la amplitud bajando; en Noche está congelado. En la barra, `timer` con `.pulse` del sistema solo durante estos minutos (apagado con Reduce Motion). Al llegar a 0: motor parado, Live Activity terminada, pantalla como estaba (Noche con «Terminó a las 00:42» en lugar de la hora de fundido, hasta que la pantalla se apague o el usuario toque).

### 9.6 Pantalla Noche, y la vuelta

Pregunta: «¿va todo bien?»

- **Entrar**: (a) «bajar la persiana»: arrastre hacia abajo ≥ 80 pt que empiece sobre el horizonte (y = 236–332); durante el arrastre la pantalla ya va perdiendo luminancia proporcionalmente, y al soltar por debajo del umbral vuelve en 250 ms; (b) automática a los 20 s de sonar, quieta y horizontal, 21:00–6:00, a partir de la segunda noche, desactivable en Ajustes; (c) menú de pulsación larga del anillo → «Noche».
- **Lo que hay**: horizonte congelado (continuo = suena, discontinuo = pausa) en `brasa-noche`; reloj 72 pt `texto-noche`; una línea: «Se funde a las 03:42» / «Toda la noche» / «En pausa» / «Terminó a las 00:42». Nada más.
- **Gestos**: toque en cualquier punto = pausa (fundido de salida 1,5 s) o reanuda (800 ms); sin háptica, porque el sonido es la confirmación. Arrastre hacia arriba = +15 min por cada 60 pt. Arrastre hacia abajo ≥ 80 pt = volver a la principal (en luminancia de Noche si es de noche, §9.3). Pulsación larga = nada (evita acciones involuntarias con la mejilla o la almohada; el sistema ya descarta toques de palma).
- **Protección contra el toque accidental**: un toque que llegue < 300 ms después de desbloquear se ignora (el pulgar que desbloquea y toca). Un toque mientras el iPhone está boca abajo (CoreMotion) se ignora.
- **Reloj**: se actualiza una vez por minuto (no hay segundos que mostrar). En Always-On (`isLuminanceReduced`) el sistema atenúa; la app no cambia nada porque ya no hay movimiento. StandBy no muestra esta pantalla: muestra la Live Activity (§12.2).
- **Salir**: por gesto, o automáticamente a las 6:00 si la app está delante (pasa a Despertar → Descenso con 2 s de fundido). Si llega una hoja del sistema (llamada), al volver la Noche sigue.

### 9.7 Modo Madrugada desde el bloqueo

Pregunta: «¿puedo volver a dormirme sin despertarme del todo?»

1. 3:40. El usuario se despierta; el sonido terminó a las 00:42 (o sigue sonando con el Escudo). Coge el iPhone, Face ID lo desbloquea. Si la app estaba delante al bloquear y han pasado ≥ 20 min, lo que ve es Madrugada: negro, el horizonte en `brasa-madrugada` (recta si está parado, congelado-continuo si suena), nada más. Si la app no estaba delante, la Live Activity (si sigue viva, ≤ 8 h) ocupa la pantalla de bloqueo con un solo botón; tocarla abre la app directamente en Madrugada (deep link `sleepnoise://madrugada`), no en la principal.
2. **Un toque.** Si estaba parado: arranca la última mezcla al 60 % de su nivel con fundido de 800 ms, `.impact(.medium)` una sola vez (es el único háptico de la madrugada: confirma «ha empezado» a quien tiene los ojos cerrados), y la Marea de 20 min se activa sola con disolución (estado interno; en pantalla no se escribe nada). El horizonte pasa de recta a envolvente congelada tras los 800 ms (no ondula: en Madrugada no hay movimiento). Si sonaba: pausa con fundido de 1,5 s, el horizonte pasa a discontinuo.
3. Tras el toque, el reloj aparece 5 s en 34 pt Medium `texto-madrugada` a y = 420 y se funde en 1 s. Es la única lectura que se ofrece, y solo a quien la pide tocando.
4. Arrastre hacia arriba: +15 min a lo que esté sonando (si no hay temporizador, el arranque de Madrugada lleva implícito uno de 45 min «hasta dormirme», porque a las 3:40 nadie quiere decidir).
5. Deja el iPhone. La pantalla se apaga sola. Nada más que hacer.
6. **Salir del modo**: bloquear sale de la pantalla; la próxima apertura vuelve a Madrugada si siguen cumpliéndose las condiciones (≥ 20 min desde el bloqueo, y sonaba o terminó hace < 2 h), o a la principal en Descenso si no. Arrastre hacia abajo ≥ 80 pt = principal en luminancia de Noche.
7. **Desde el Watch** (1.1): toque en la app o en el Smart Stack = lo mismo que el toque en Madrugada, con `.directionUp` en la muñeca.
8. **Lo que no pasa:** no se cuenta cuántas veces se despierta, no se guarda nada, no se pregunta nada por la mañana. Madrugada no aparece en ninguna lista ni ajuste salvo «Entrar en Madrugada al desbloquear de noche» (activado), para quien comparte iPhone.

### 9.8 La prueba caduca mientras suena, y después

Pregunta: «¿me va a cortar el sonido a medianoche?»

**Regla.** Una noche se consume por fecha de calendario en la que la app suena al menos una vez. La prueba caduca **al mediodía siguiente a la séptima noche**, nunca a medianoche y nunca mientras suena: si a las 12:00 hay una sesión activa, la caducidad espera a que el sonido pare. Nada se interrumpe jamás por razones comerciales (P9).

1. **Noches 5–7.** La línea de versalitas se convierte en dos líneas en paso 6: «Prueba · última noche. Después siguen gratis blanco, rosa, marrón, lluvia y 60 minutos.» Toque: hoja Pro. Nada más cambia. Sin notificación.
2. **La sesión que cruza la caducidad.** Suena «Verano con ventana» (Ventilador 70 · Rosa 20) con Escudo nocturno. A las 12:00 del día siguiente sigue sonando (siesta larga, o uso de día): la caducidad espera. Lo único visible, al mirar la principal: bajo el estado, en paso 6 `texto2`: «La prueba ha terminado. Esta sesión sigue entera.» (marco «Prueba caducada» de la maqueta). La Live Activity no cambia.
3. **Al parar.** Las entradas Pro pasan a su estado «bloqueado-Pro sin castigo»: Ventilador y Océano con nombre en `texto2`, pista vacía y «pro» en versalitas; el valor interno 70 se conserva en la mezcla (no se destruye nada); el temporizador se acota a 60 min (la barra dice «60 min» y la escala enseña «pro» a partir de ahí); la Marea queda disponible como muestra de 2 min una vez por noche (§9.10). La línea de prueba desaparece; durante 7 días más queda una sola línea en versalitas «sigue gratis · blanco, rosa, marrón, lluvia» que se va sola.
4. **Día 8, al abrir.** Es el marco 4 de la maqueta: la principal entera, sin candados, sin hoja, sin cuenta atrás. Toque en el anillo: suena con las capas libres de la mezcla. Si la mezcla solo tenía capas Pro (Océano 55 solo), el estado dice «En reposo · Océano es parte de Pro» y el anillo arranca Rosa 40 como mezcla mínima en lugar de no hacer nada: un instrumento siempre suena al tocarlo.
5. **Tocar una capa Pro.** Suena 30 s con fundido normal (sin háptica, sin animación propia) y la hoja Pro se abre **debajo del sonido**; cerrarla no corta los 30 s. Una muestra por capa y por noche; después, tocar la fila solo abre la hoja.
6. **Lo que no pasa:** no hay hoja al abrir el día 8, no hay descuento con cuenta atrás, no se pide valoración, no se mandan notificaciones «te queda 1 día». La frase de la ficha «7 noches con todo. Sin tarjeta.» se cumple literalmente.

### 9.9 Compra y restauración

Pregunta: «¿cuánto, qué pasa si no, y me va a fallar?»

1. **Entrada**: desde la línea de prueba, una fila Pro, un valor Pro, la fila «Pro» de Ajustes o el enlace de la hoja Noches. Siempre por toque. Nunca al abrir, nunca al parar el sonido.
2. **La hoja** (4.8): el precio de StoreKit en paso 1, en la moneda del usuario; si StoreKit aún no ha respondido (< 1 s normalmente) el hueco del precio muestra «—» en `texto3` y el botón está deshabilitado; nunca un precio escrito a mano.
3. **Toque en «Comprar · 29,99 €»**: se presenta la hoja del sistema (Face ID / doble clic). La app no añade nada encima. Si el usuario cancela, no pasa nada: la hoja Pro sigue tal cual, sin mensaje.
4. **Éxito**: el botón de compra se funde (250 ms) y en su lugar aparece en paso 4 `texto`: «Gracias. Todo abierto.» con un secundario «Listo» debajo. Háptico `.success` (está despierto y con luz). Sin confeti, sin sello. Al cerrar la hoja: la línea de prueba ya no está; las filas Pro son filas normales a su último valor (si «Verano con ventana» tenía Ventilador a 70 y está sonando, Ventilador entra con fundido de 800 ms en ese instante: la compra se oye); el temporizador recupera su valor completo si estaba acotado; en Ajustes, una fila «SleepNoise Pro · gracias» con la fecha.
5. **Error de StoreKit** (red, Apple ID): bajo el botón, paso 6 `texto2`: «No se ha podido completar. No se ha cobrado nada.» El botón vuelve a estar activo. Sin alerta modal.
6. **Restaurar compra**: el secundario pasa a «Buscando…» (texto, no spinner) hasta 10 s. Encontrada: idéntico al éxito. No encontrada: paso 6 bajo el botón: «No hay compras con este Apple ID.» Family Sharing no necesita nada: StoreKit la entrega como propia.
7. **Sin red**: el botón deshabilitado (contorno `texto3`) con la nota «La tienda no responde. Nada cambia: sigue sonando.» Los 30 s de muestra de una capa Pro funcionan igual sin red.
8. **Después de comprar**: la palabra «Pro» desaparece de la app entera salvo en Ajustes. La hoja Pro ya no es alcanzable (las filas que la abrían ya no existen; en Ajustes, «SleepNoise Pro · gracias» abre una hoja idéntica con el botón sustituido por «Comprado el 16 de noviembre de 2026» y «Restaurar» para otro dispositivo).

### 9.10 Una noche guardada que pierde capas Pro (usuario gratuito)

Pregunta: «¿me has roto mi mezcla?»

1. En la hoja Noches, «Verano con ventana» sigue en «Tuyas» con su detalle completo: «Ventilador 70 pro · Rosa 20 · escudo nocturno pro». La palabra «pro» en versalitas, al lado de cada parte que ahora no suena; nada tachado, nada en gris.
2. Toque en la fila: carga la noche con fundido cruzado de 1,5 s. Suena Rosa 20 (y, como muestra, Ventilador durante 30 s si es la primera vez esa noche, con el mismo fundido de salida). El estado dice «Suena · Ventilador es parte de Pro» durante 10 s y después «Suena · se funde a las 00:12» (el escudo nocturno se ha convertido en 60 min; el detalle de la fila lo decía).
3. Nada se modifica en la noche guardada: Ventilador sigue a 70 en el modelo, silenciado por derecho, no por valor. Por eso «Guardar» no aparece (la mezcla viva es igual a la guardada) y, si compra Pro mientras suena, Ventilador entra solo con 800 ms de fundido.
4. Si el usuario arrastra sobre la fila Ventilador: la fila no responde al arrastre (no hay línea que mover) y un toque hace lo de 9.8.5. VoiceOver: «Ventilador, 70 por ciento, requiere Pro; toca dos veces para escuchar 30 segundos».
5. Si guarda una noche nueva una vez agotado el límite gratuito: el campo de nombre se abre igual; al confirmar, bajo el campo, «Guardar más noches es parte de Pro ›» y el nombre no se pierde (queda en el campo hasta que cierre). Las noches ya guardadas no se borran nunca, ni siquiera las que superan el límite.

### 9.11 Interrupción por llamada y pausa de AirPods

Pregunta: «¿va a sonar el mar en mitad de la llamada, y volverá después?»

- **Llamada entrante** (`AVAudioSession.interruptionNotification` began): el motor para sin fundido (el sistema ya ha tomado la salida). En la app, el horizonte baja a recta en 2 s y queda **discontinuo**; estado «En pausa · llamada»; en Noche, la línea dice «En pausa». La Live Activity cambia a `play.fill` y línea discontinua con una sola actualización. El temporizador **se detiene con el sonido** (la hora de fundido se desplaza; al reanudar se recalcula y se escribe: «se funde a las 00:51»).
- **Fin de la llamada** con `shouldResume`: reanuda solo con 800 ms de fundido, sin háptica, sin tocar nada. Sin `shouldResume` (la llamada fue larga, o el usuario abrió otra app de audio): queda en pausa; un toque en cualquier superficie reanuda. La Live Activity sigue viva hasta 20 min en pausa; después termina (la noche se da por acabada y Madrugada queda disponible 2 h).
- **AirPods fuera de la oreja / desconexión** (`.oldDeviceUnavailable`): pausa con fundido de 3 s (nunca saltar al altavoz a las 2 de la mañana). Volver a ponerlos **no** reanuda solo (convención de Apple: la reanudación es del usuario): un toque en la Live Activity, en el Watch o en la pantalla.
- **«Pausar al dormirse» de AirPods (iOS 26)**: llega como `pauseCommand` del centro de control remoto: fundido de 3 s de audio, 2 s de interfaz. Estado «En pausa · AirPods». A diferencia de la llamada, aquí la pausa es el objetivo: a los 20 min la Live Activity termina y la sesión se da por buena. Si el usuario se despierta y toca: reanuda al 60 % con la Marea de 20 min, como Madrugada, porque la situación es la misma.
- **Otra app toma el audio** (podcast, vídeo): la sesión se interrumpe igual que con una llamada y no se reanuda sola (sería pisar el podcast). 1.1: el modo «Capa» con `mixWithOthers` convive y se atenúa.
- **Siri**: `AudioPlaybackIntent` evita que Siri hable encima; si lo hace, `duckOthers` del sistema baja la cama 1 s y vuelve.
- **Lo que no pasa:** ningún aviso, alerta ni háptica en ninguno de estos casos. El estado se lee en una palabra y en la forma de la línea.

### 9.12 Error de audio

Pregunta: «¿por qué no suena?»

- **No arranca** (sesión denegada, hardware ocupado, `AVAudioEngine` falla): el anillo se queda en `play.fill`; las filas pasan al estado «deshabilitado» (nombres `texto3`, pistas `trazo`); bajo el estado, en el único rojo de la app (`error`, 5,4:1), paso 5: «El sonido no ha podido empezar. Toca para intentarlo otra vez.» La app reintenta una vez sola a los 2 s; si funciona, el aviso se funde y todo vuelve. Sin alerta modal, sin código de error (el código va al registro y a Ajustes › Diagnóstico, para quien escriba al soporte).
- **Se cae a mitad de la noche** (`mediaServicesWereReset`, presión de memoria): la app reconstruye el motor y rearranca la última mezcla con fundido de 800 ms, sin interfaz. Si no puede: la Live Activity pasa a «En pausa» (no a «error»: a las 3 no se diagnostica), y la próxima vez que se abra la principal muestra el aviso anterior con «Se detuvo a las 02:14.» en paso 6.
- **Ruta de salida sin volumen** (HomePod apagado, AirPlay perdido): el motor sigue; estado «Suena · sin salida de audio» en `texto2`, no en rojo (no es un fallo de la app).
- **Sin sonido por volumen del sistema a 0**: estado «Suena · el volumen del iPhone está al mínimo». Ya está en 9.1.
- **Lo que no pasa:** ninguna hoja, ningún «Enviar informe», ninguna sugerencia de reinstalar.

## 10. Especificación de movimiento

Regla única: **cada cosa que se mueve nombra la señal del motor que la mueve; si no hay señal, no se mueve.** Nada es infinito salvo lo que es el sonido (envolvente, ola). Nada usa `spring`. Todas las curvas son `.easeOut` (empezar) o `.easeInOut` (parar), que son las del propio fundido del DSP.

| # | Elemento | Causa física (señal) | Duración / frecuencia | Curva | Reduce Motion | Always-On · StandBy · Noche · Madrugada |
|---|---|---|---|---|---|---|
| M1 | Horizonte: amplitud | RMS maestro, seqlock de `SoundGains`, τ 400–800 ms | continuo, 20 Hz | la del suavizado del motor | 4 Hz, τ 1,5 s | **Congelado** en la última forma; transición de 2 s `easeInOut` al congelarse |
| M2 | Horizonte: desplazamiento temporal | el tiempo (eje x = últimos 20 s) | 393 pt / 20 s ≈ 20 pt/s | lineal | igual (es lento: < 1 cambio de luminancia/s por píxel) | congelado |
| M3 | Punto «ahora» | altura = M1 | sigue M1 | — | sigue | congelado |
| M4 | Nacimiento del horizonte (arranque) | fundido de entrada del motor, 800 ms | 800 ms | `.easeOut` | igual (altura y opacidad) | n/a |
| M5 | Muerte del horizonte (parada, fin de fundido) | fundido de salida del motor | 1.500 ms (parada), 2.000 ms (fin de temporizador) | `.easeInOut` | igual | igual |
| M6 | Horizonte → discontinuo (pausa externa) | `interruption` / `pauseCommand` | 2.000 ms a recta; el patrón 6/6 aparece al llegar | `.easeInOut` | igual | igual |
| M7 | Ola de la Marea (hoja y horizonte) | `BreathCurve` del audio, reanclada por ciclo a `guide.anchor` + `outputLatency` | 10 s por ciclo a 6/min (4 s sube, 6 s baja); rango 7,5–15 s | `BreathCurve` (nunca `sin`) | tamaño fijo máximo; **opacidad** 0,55→1,0→0,55 con la misma curva | **Congelada en marea baja** (base); Live Activity: glifo estático |
| M8 | Disolución de la Marea | ganancia de modulación del motor (100 → 0 % en 5 min) | 300 s, lineal por ciclo | lineal | igual (afecta a la opacidad) | n/a |
| M9 | Punto de fase de la ola (hoja) | fase de M7 | sigue M7 | — | fijo en la cresta; opacidad con M7 | congelado |
| M10 | Línea de nivel bajo el dedo | ganancia de la capa (gesto) | 0 ms (directo) | — | igual | n/a |
| M11 | Grosor de línea 2 → 3 pt y punto de 6 pt al tocar | `DragGesture` empieza | 150 ms | `.easeOut` | fundido | n/a |
| M12 | Valor junto a la punta | gesto | 150 ms opacidad | — | igual | n/a |
| M13 | Descomposición del horizonte en capas (pulsación larga) | RMS por capa | 2.000 ms separar / 2.000 ms sumar | `.easeInOut` | fundido entre dos estados | n/a |
| M14 | Play ↔ Pause (glifo) | estado del motor | `.contentTransition(.symbolEffect(.replace))` | sistema | fundido | n/a |
| M15 | `timer` con `.pulse` | fundido final en curso | sistema, solo durante el fundido | sistema | **apagado** | n/a |
| M16 | Cambio de fase (Descenso ↔ Noche ↔ Madrugada ↔ Despertar) | reloj de fase / gesto / CoreMotion | 2.000 ms (automático); proporcional al arrastre al «bajar la persiana», 250 ms al soltar | `.easeInOut` | igual (es opacidad) | la fase **es** el estado congelado |
| M17 | Despertar (luminancia sube) | ventana antes de la hora de parada del Escudo (15–30 min) | 900–1.800 s, lineal | lineal | igual | sigue (es luminancia, 1 cambio/min) |
| M18 | Reloj de Noche | reloj del sistema | 1 cambio/min | `.replace`? **No**: cambio seco de texto | igual | 1/min |
| M19 | Reloj de Madrugada (5 s tras tocar) | toque | 250 ms entrar, 1.000 ms salir | opacidad | igual | igual |
| M20 | Nota de prueba al cerrarla | toque | 250 ms opacidad; el hueco se cierra sin animación de altura (las filas no se desplazan: las posiciones son fijas en Large) | — | igual | n/a |
| M21 | Hojas | sistema | sistema | sistema | sistema | n/a |
| M22 | Fundido cruzado al cargar una noche | el motor cruza ganancias | 1.500 ms | `.easeInOut` | igual | n/a |
| M23 | Escala del temporizador: punto arrastrado | gesto | 0 ms | — | igual | n/a |
| M24 | Botón de compra → «Gracias» | respuesta de StoreKit | 250 ms opacidad | — | igual | n/a |
| M25 | Live Activity: cualquier cambio | cambio de estado (inicio, hito, +15, pausa, Marea, fin) | actualización puntual, ≤ 1 por hito; nunca periódica | sistema | sistema | el sistema la atenúa; nada propio |

**Presupuesto.** Un solo `Canvas` (M1–M3, M7 en la principal) en `TimelineView(.periodic(by: 1/20))`, `paused` cuando no suena, `scenePhase != .active`, Noche, Madrugada, `isLuminanceReduced` o hoja encima. La ola de la hoja es un `KeyframeAnimator` (24 claves/ciclo) que corre en el render server. Todo lo demás es Core Animation finita. Cero fotogramas con la pantalla apagada; medido con Instruments 10 min bloqueado antes de la ficha.

**Qué se congela y cómo.** Al entrar en Noche, Madrugada o `isLuminanceReduced`: M1 deja de leer el motor y la última trayectoria se mantiene; durante 2 s se interpola de la forma viva a la forma congelada (sin «salto»); M7 completa el ciclo en curso hasta la base y se queda; M15 se apaga; M18 sigue a 1/min. Al salir: M1 reanuda desde la forma congelada hacia la real en 800 ms. En StandBy el sistema recibe una Live Activity que ya es estática (M25); no hay nada que congelar.

**WCAG 2.3.1**: ningún elemento cambia de luminancia más de 3 veces por segundo; M1 a 20 Hz tiene τ ≥ 400 ms, así que ningún píxel oscila a más de ~1 Hz perceptible. Prueba: grabación a 60 fps de la principal sonando con blanco a 100, análisis de luminancia por píxel.

## 11. Háptica

Principio del documento 02 sin cambios: la háptica es confirmación para los ojos cerrados y se gasta poco; un iPhone que vibra en la mesilla suena. Aquí, el inventario completo por superficie.

| Momento | iPhone en la mano | iPhone quieto y horizontal (mesilla) | Watch (1.1) | VoiceOver anuncia |
|---|---|---|---|---|
| Arrancar (anillo, Madrugada, Live Activity, widget, Control, Siri) | `.impact(.medium, 0.7)` al inicio del fundido | **nada** (el sonido confirma) | `.start` | «Suena Lluvia fina y marrón» |
| Parar / pausar | `.impact(.light, 0.5)` | nada | `.stop` | «En pausa» |
| Cruzar el cero de una capa | `.selection` | n/a (se está tocando) | — | valor |
| Llegar a 100 | `.impact(.light, 0.6)` | n/a | — | «100 por ciento, máximo» |
| Pasos intermedios de nivel | nada | — | — | valor cada 5 % |
| Escala del temporizador, por marca | `.selection` | — | corona: detent del sistema | «60 minutos» |
| +15 min (arrastre en Noche/Madrugada) | `.selection` por escalón | **nada** (está en la mano por definición, pero de noche se silencia: la hora cambia en pantalla) | `.directionUp` por detent | «Se funde a las 3:57» |
| Elegir intención del temporizador / ritmo de Marea (entero) | `.selection` | — | — | opción |
| Guardar noche | `.success` | — | — | «Guardada» |
| Compra correcta / restauración | `.success` | — | — | «Gracias. Todo abierto.» |
| Error de compra | `.error` solo si la hoja Pro está delante | — | — | texto del error |
| Fin de temporizador, fin de Marea, caducidad de prueba | **nada** | nada | nada | nada (duerme) |
| Entrar en Noche / Madrugada | nada | nada | — | «Noche» |
| Marea, háptica «Mínima» | patrón continuo Core Haptics, intensidad = `BreathCurve`, nitidez 0,2, **4 respiraciones** y se retira | nada | `.directionUp` al inicio de cada inhalación, 5 respiraciones | «Marea guiando» |
| Marea, háptica «Marcada» | el patrón continuo toda la guía + transitorio suave (intensidad 0,4) al inicio de cada inhalación | nada | `.directionUp` toda la guía | igual |
| Marea, «Ninguna» | nada | nada | nada | igual |
| Capa Pro: muestra de 30 s | nada (sería marketing) | — | — | «Ventilador, muestra de 30 segundos» |
| Cualquier error de audio | nada | nada | nada | texto |

Reglas: el motor de Core Haptics se crea con `playsHapticsOnly = true` y se destruye al terminar la guía; se consulta `supportsHaptics` y el ajuste «Háptica del sistema»; en el Watch, la Marea háptica es la superficie natural y no depende de la posición del iPhone. Todo háptico tiene su anuncio de VoiceOver (`AccessibilityNotification.Announcement`), y ninguno ocurre en segundo plano.

## 12. Superficies del ecosistema, dibujadas en palabras

Las reglas comunes de 4.10 valen para todas: una sola tinta (`texto`), `brasa` solo como forma ≥ 3 pt, estado por forma (línea continua / discontinua, `pause.fill` / `play.fill`, punto en la cresta / en la base), texto ≥ 15 pt Medium (≥ 18 donde haya rojo), un solo control por superficie. Diseñadas primero bajo el rojo de StandBy y después sin filtro. Cada una está en la maqueta (`scratchpad/design/concepts/marea.html`, fila «Desde la mesilla»).

### 12.1 Live Activity y Dynamic Island

| Presentación | Tamaño | Contenido | Control |
|---|---|---|---|
| **Pantalla de bloqueo** | 361 × 128 | Fila 1: glifo de ola 22 pt (punto en la cresta si la Marea guía; sin punto si no; trazo discontinuo si pausa) + nombre de la noche 17 Semibold. Fila 2 (y = 74): horizonte estático 2 pt `brasa`, de margen a margen, continuo/discontinuo; su altura relativa al centro es el nivel maestro al emitir (±6 pt). Fila 3: «Se funde a las 00:42 · 42 min» 15 Medium `texto` con `Text(timerInterval:)` (cuenta sin actualizaciones); «Toda la noche» en Escudo; «En pausa» en pausa; «Marea · 6/min · 12 min» mientras guía | Anillo 44 pt a la derecha: `pause.fill` / `play.fill` (`AudioPlaybackIntent`). Cuando quedan < 20 min, el anillo se sustituye por «+15» 17 Semibold en anillo (la acción probable a esa hora); la pausa sigue en el toque de la actividad entera (abre Madrugada) |
| **Dynamic Island compacta** | leading / trailing | Leading: glifo de ola (estado por forma). Trailing: «42 min» 15 Medium tabular; con Marea guiando alterna cada 30 s con «6/min»; en pausa, «Pausa» | toque: abre la app en Madrugada (de noche) o en la principal (de día) |
| **Dynamic Island mínima** | 1 glifo | glifo de ola | toque: igual |
| **Dynamic Island expandida** | 371 × ~150 | Leading: glifo 28 pt + nombre 17 Semibold; trailing: anillo 44 pt; bottom: horizonte 2 pt + «Se funde a las 00:42 · 42 min» 15 Medium | el anillo |
| **StandBy** (§12.2) | 852 × 393 | la de bloqueo escalada por el sistema | toque = pausa / reanuda |

Actualizaciones: inicio, cada hito del temporizador (inicio del fundido), +15, pausa / reanudación, inicio y disolución de la Marea, fin (`.immediate`). Nunca periódicas: el tiempo lo cuenta `timerInterval`. Fondo `activityBackgroundTint(.black)` y, en iOS 26, el vidrio que el sistema ponga; sin fondos propios. Límite de 8 h: en Escudo nocturno la actividad se emite al arrancar y se **re-emite** si la app vuelve al primer plano pasadas 7 h (Madrugada la trae); si caduca mientras duerme, la pantalla de bloqueo queda limpia, que es lo correcto.

### 12.2 StandBy nocturno

Apaisado, 852 × 393, tinte rojo del sistema. La Live Activity a pantalla completa: horizonte a un tercio (y = 131) en 3 pt `brasa` (→ `#C90000`, 3,48:1 como forma); nombre de la noche arriba a la izquierda a 34 pt Semibold `texto` (→ `#E80000`, 4,43); «Se funde a las 00:42» a 34 pt Medium; «42 min» a 88 pt Rounded; anillo de 112 pt a la derecha con `pause.fill` de 48 pt. Todo lo que es texto supera 18 pt; nada usa `texto2` ni opacidades. Estado por forma: continuo/discontinuo, `pause.fill`/`play.fill`. Al tocar la pantalla: pausa / reanuda. El widget pequeño en StandBy (modo widgets) enseña «Suena» y «42 min» con el anillo; en rojo se ve igual porque fue diseñado en rojo.

### 12.3 Widgets

| Familia | Contenido | Interacción |
|---|---|---|
| **Pequeño** 158 × 158 | glifo de ola 28 pt (18, 18); anillo 44 pt arriba a la derecha con `pause.fill` / `play.fill`; «Suena» / «En reposo» 17 Semibold en y = 82; «42 min» / «Sin temporizador» / nombre de la última noche 34 Rounded tabular en y = 102 | el anillo: arranca la última noche o pausa (`AudioPlaybackIntent`). Toque en el resto: abre la app |
| **Mediano** 338 × 158 | izquierda: el pequeño; derecha, separadas por hairline vertical `trazo`: las dos últimas noches como filas de 56 pt (nombre 17 Semibold, detalle 13 Medium `texto2`: «Lluvia 65 · Marrón 40 · 45 min») | cada fila arranca esa noche; la que suena lleva un punto de 6 pt `brasa` a la izquierda del nombre |
| **Bloqueo circular** | glifo de ola; con sonido, punto en la cresta | abre la app |
| **Bloqueo rectangular** | «Suena · 42 min» / «En reposo» 15 Semibold + glifo | abre la app |
| **Bloqueo en línea** | «SleepNoise · 42 min» | abre la app |
| **Configurable** (1.1) | el pequeño con una noche fija elegida por el usuario («Hotel») | arranca esa noche |

Fondo negro marcado como removible; en *accented* y *vibrant* todo pasa a la tinta del sistema y el estado sigue leyéndose por forma. Sin `texto2` en el pequeño (en StandBy rojo moriría); el detalle del mediano usa `texto2` porque el mediano no se muestra en StandBy.

### 12.4 Centro de control y botón de Acción (iOS 18+)

- **Toggle «SleepNoise»** (`ControlWidgetToggle`, `SetValueIntent`): símbolo propio de ola; *on* = trazo continuo con punto, tinte `brasa`; *off* = trazo discontinuo, gris del sistema. Etiqueta «SleepNoise»; valor «Suena» / «En reposo». Encender arranca la última noche con su temporizador; apagar para con fundido de 1,5 s.
- **Botón «Marea 20 min»** (`ControlWidgetButton`): símbolo de ola con punto; arranca la última noche (o Rosa 40 si no hay) con la Marea de 20 min que se disuelve. *Hint* para el botón de Acción: «Mantén para dormir». Es el control que recomendamos asignar al botón de Acción y al bloqueo.
- **Botón «+15 min»** (1.1): solo visible si hay sesión; añade 15 min.
- En iOS 17 no existe el Control: los Atajos de §12.6 cubren el caso.

### 12.5 Apple Watch (mínimo, 1.1)

Una pantalla, sin navegación, 198 × 242 (45 mm):

- **Horizonte** a un tercio (y = 80), 2 pt, continuo/discontinuo, `brasa` (en el Watch no hay tinte rojo, pero la regla de forma se mantiene).
- **Estado** «Suena» / «En reposo» / «En pausa» 17 Semibold en y = 108; **hora de fundido** «00:42» 34 Rounded tabular en y = 132; debajo, 13 Medium `texto2`: «42 min» o el nombre de la noche si no hay temporizador.
- **Toda la pantalla** es el botón: toque = pausa / reanuda (o arranca la última noche si está parado); `.start` / `.stop` en la muñeca.
- **Corona digital**: +15 min por detent hacia arriba (`.directionUp`), −15 hacia abajo hasta un mínimo de 5 min; la hora de fundido cambia bajo la corona.
- **Pulsación larga**: activa la Marea de 20 min (el glifo de ola con punto aparece junto al estado) y la **Marea háptica** en la muñeca: `.directionUp` al inicio de cada inhalación, 5 respiraciones («Mínima») o toda la guía («Marcada», ajustable en la app del iPhone). Es donde la Marea háptica es natural: la muñeca no suena sobre la madera y no hace falta sostener nada.
- **Smart Stack / complicación**: la misma tarjeta reducida (estado + hora de fundido + glifo); complicación circular: glifo de ola.
- Sin tracking, sin HealthKit en 1.0; el Watch es mando y metrónomo, nada más. Comunicación por `WatchConnectivity` con la sesión del iPhone (el Watch no genera audio en 1.1).

### 12.6 Siri y Atajos (`AudioPlaybackIntent`, iOS 17)

Intenciones y frases (ES / EN), todas sin diálogo de Siri cuando el audio arranca:

| Intención | Frases ES | Frases EN | Parámetros |
|---|---|---|---|
| Iniciar noche | «Oye Siri, pon SleepNoise» · «empieza la noche con SleepNoise» · «pon Lluvia fina y marrón en SleepNoise» | "Hey Siri, play SleepNoise" · "start tonight with SleepNoise" · "play Steady rain in SleepNoise" | noche (opcional), temporizador (opcional) |
| Parar | «para SleepNoise» · «apaga el sonido de SleepNoise» | "stop SleepNoise" · "turn off SleepNoise" | — |
| Añadir tiempo | «añade 15 minutos a SleepNoise» · «15 minutos más» | "add 15 minutes to SleepNoise" · "15 more minutes" | minutos (5–60) |
| Dormir con la Marea | «dormir con la Marea» · «pon la Marea 20 minutos» | "sleep with the Tide" · "start the Tide for 20 minutes" | duración, ritmo |
| Noche (modo) | «SleepNoise en modo Noche» | "SleepNoise Night mode" | — |
| Ajustar capa | «sube la lluvia en SleepNoise» · «pon el marrón al 40» | "turn up the rain in SleepNoise" · "set brown to 40" | capa, nivel |
| Estado | «¿cuánto le queda a SleepNoise?» | "how long is left on SleepNoise?" | — (respuesta hablada: «Se funde a las 0:42, 42 minutos») |

Automatizaciones recomendadas en la guía de dos pantallas dentro de Ajustes › Atajos (no se instalan solas): «Al activar el Focus de Sueño → Iniciar noche (la última) → modo Noche» y «Al desactivar el Focus de Sueño → Parar». Los Atajos exponen «Noches (mezclas guardadas)» con ambos nombres para la búsqueda.

### 12.7 Focus de Sueño

La app no puede saber qué Focus está activo; ofrece un **Focus filter** (`SetFocusFilterIntent`) con dos parámetros: «Entrar en Noche al abrir» (sí/no) y «Noche a cargar» (una noche guardada). El usuario lo configura en Ajustes › Focus › Sueño › Filtros de apps › SleepNoise, y la app enseña dónde con una pantalla de texto (sin capturas ni flechas). Con el Focus activo y el filtro configurado: la app abre directamente en Noche con la noche elegida ya sonando si el usuario pulsa el icono. Nada se promete que el sistema no permita (no hay autoplay sin toque fuera de los Atajos).

## 13. Accesibilidad

### 13.1 Orden de VoiceOver por pantalla

**Principal (Descenso).** 1 nombre de la mezcla (botón) → 2 «Guardar» (si existe) → 3 estado (texto estático, `.updatesFrequently` no: solo cambia por hitos) → 4 nota o línea de prueba (botón) → 5 horizonte (imagen con descripción + Audio Graph) → 6–11 las seis capas (`.adjustable`) → 12 Temporizador (botón) → 13 Reproducir / Pausar (botón) → 14 Marea (botón). Los grupos (cabecera, horizonte, capas, barra) son contenedores `.accessibilityElement(children: .contain)` con etiqueta de grupo para el rotor «Contenedores».

**Noche.** Un solo elemento, toda la pantalla: etiqueta + valor + pista; acciones personalizadas «Añadir 15 minutos», «Volver a la mezcla». **Madrugada.** Igual, con «Empezar» / «Pausar» como acción por defecto.

**Marea (hoja).** 1 título → 2 la ola (`.adjustable`: el ritmo) → 3 estado → 4 origen → 5 toggle Marea → 6 Ritmo → 7 Duración → 8 Háptica → 9 texto de uso → 10 enlace «Qué sabemos y qué no».

**Temporizador (hoja).** 1 título → 2–5 las cuatro intenciones (botones con rasgo `.isSelected`) → 6 la escala (`.adjustable`, pasos de 15 min) o el selector de hora → 7 pie.

**Noches.** 1 título → cabecera «Tuyas» → filas (botón; acciones: Renombrar, Borrar, Mover arriba/abajo) → cabecera «De la casa» → filas → nota de persistencia.

**Pro.** 1 «SleepNoise Pro» → 2 precio y condiciones (un elemento: «29,99 euros, una vez, sin suscripción, compartido en familia») → 3–7 las cinco filas (texto estático) → 8 «Sigue siendo gratis…» → 9 línea de prueba → 10 Comprar (botón) → 11 Restaurar (botón) → 12 privacidad y enlace.

### 13.2 Etiquetas, valores y pistas por control (ES / EN)

| Control | Etiqueta | Valor | Pista | Rasgos y acciones |
|---|---|---|---|---|
| Nombre de la mezcla | «Lluvia fina y marrón, mezcla actual» / "Steady rain and brown, current mix" | — | «Toca dos veces para elegir otra noche» / "Double-tap to choose another night" | `.isButton` |
| Guardar | «Guardar esta noche» / "Save tonight" | — | — | `.isButton` |
| Estado | «Suena. Se funde a las 0:42» / "Playing. Fades at 0:42" | — | — | `.isStaticText`; anuncio al cambiar |
| Nota de prueba | «7 noches con todo, sin tarjeta. Después 29,99 euros una vez, o sigue gratis con blanco, rosa, marrón y lluvia» | — | «Toca dos veces para cerrar» | `.isButton`; acción «Ver Pro» |
| Horizonte | «Sonido» / "Sound" | «nivel medio; Lluvia y Marrón» / "medium level; Rain and Brown" | «Toca dos veces y mantén para oír cada capa» / "Double-tap and hold to hear each layer" | `.isImage`; `AXChartDescriptor` con una serie por capa (Audio Graph) |
| Fila de capa (activa) | «Lluvia» / "Rain" | «65 por ciento» / "65 percent" | «Desliza arriba o abajo para ajustar» / "Swipe up or down to adjust" | `.adjustable` (5 %); acciones «Silenciar», «Máximo», «Timbre» |
| Fila de capa (a cero) | «Lluvia» | «silenciada» / "muted" | «Toca dos veces para encender al 40 por ciento» | `.adjustable`; acción «Encender» |
| Fila de capa (Pro, gratuito) | «Ventilador, requiere Pro» / "Fan, requires Pro" | «70 por ciento, silenciada» si la noche la tenía | «Toca dos veces para escuchar 30 segundos» / "Double-tap to hear 30 seconds" | `.isButton`; acción «Ver Pro» |
| Segunda línea de timbre | «Timbre de Lluvia» / "Rain tone" | «cálido 40 por ciento» / "warm, 40 percent" | «Desliza para ir de cálido a brillante» | `.adjustable` |
| Temporizador (barra) | «Temporizador» / "Timer" | «45 minutos, hasta dormirme» / "45 minutes, until I fall asleep" | «Toca dos veces para cambiar» | `.isButton` |
| Anillo | «Reproducir» / "Play" · «Pausar» / "Pause" | «suena Lluvia fina y marrón» | — | `.isButton`; acciones «Noche», «Dormir con la Marea», «Parar en 15 minutos» |
| Marea (barra) | «Marea respiratoria» / "Breathing tide" | «apagada» / «guiando, 6 por minuto, se retira a las 23:58» | «Toca dos veces para activar y ajustar» | `.isButton` |
| Pantalla Noche | «Noche» / "Night" | «Suena Lluvia fina y marrón, se funde a las 3:42» | «Toca dos veces para pausar» / "Double-tap to pause" | acciones «Añadir 15 minutos», «Volver a la mezcla» |
| Madrugada | «Madrugada» / "Small hours" | «en reposo» / «suena» | «Toca dos veces para empezar la última noche con la Marea» | acciones «Añadir 15 minutos», «Volver a la mezcla» |
| Ola (hoja Marea) | «Ritmo de la Marea» / "Tide pace" | «6 por minuto» | «Desliza arriba o abajo para cambiar el ritmo» | `.adjustable` (1/min; 0,1 con la acción «Ajuste fino») |
| Toggle Marea | «Marea» | «activada» / «desactivada» | — | `.isToggle` (sistema) |
| Intención del temporizador | «Hasta dormirme» / "Until I fall asleep" | «45 minutos, seleccionado» | — | `.isButton` + `.isSelected` |
| Escala | «Duración» / "Duration" | «45 minutos» | «Desliza arriba o abajo en pasos de 15 minutos» | `.adjustable`; valores Pro: «90 minutos, requiere Pro» |
| Fila de noche | «Verano con ventana» / "Summer with the window open" | «Ventilador 70, requiere Pro; Rosa 20; escudo nocturno, requiere Pro» | «Toca dos veces para que suene» | `.isButton`; acciones «Renombrar», «Borrar», «Subir», «Bajar» |
| Botón de compra | «Comprar SleepNoise Pro, 29,99 euros, una vez» / "Buy SleepNoise Pro, $29.99, once" | — | — | `.isButton` |
| Restaurar | «Restaurar compra» / "Restore purchase" | — | — | `.isButton` |
| Live Activity | «SleepNoise, suena Lluvia fina y marrón, 42 minutos» | — | — | el anillo: «Pausar», botón |
| Widget pequeño | «SleepNoise, suena, 42 minutos» | — | — | «Pausar», botón |
| Control del Centro de control | «SleepNoise» | «Suena» / «En reposo» | — | `.isToggle` |

El reloj de Noche se lee como hora en palabras («tres y doce de la madrugada»), nunca «03:12». Las cifras tabulares no cambian la lectura.

### 13.3 Dynamic Type hasta AX5: qué se reorganiza

| Tamaño | Principal | Hojas | Noche / Madrugada | Barra |
|---|---|---|---|---|
| xSmall–Large | Todo cabe en 852 sin scroll; filas de 56 pt; nombre y valor en la misma línea | Filas de 56; textos en una línea | Reloj 72 | tres elementos con etiqueta |
| xLarge–xxxLarge | Filas crecen con `@ScaledMetric` (56 → 64 → 72); el aire entre grupos se reduce (32 → 24) antes que las filas; desde xxLarge aparece scroll vertical y el horizonte deja de estar a y = 284 fijo: se ancla **bajo la cabecera** (sigue siendo lo primero que se ve). El gesto de «bajar la persiana» sigue sobre el horizonte | Filas 64–72; valores largos («15 min, luego se retira») pasan debajo de la clave con `ViewThatFits` | Reloj 72 → 88 (tope `accessibility2`); la línea de estado puede ocupar dos líneas | etiquetas se truncan a glifo + cifra («42 min», «6/min»); «Temporizador» y «Marea» pasan a solo glifo con etiqueta accesible |
| AX1–AX2 | Cada fila pasa a **dos líneas**: nombre arriba (y valor a la derecha), línea de nivel debajo con 12 pt de margen; altura 88–96; bloqueo de eje en el arrastre (umbral 30°) para no pelear con el scroll; la nota de prueba se convierte en tres líneas | Las tres intenciones del temporizador: título y detalle apilados, 88 pt; la ola de la Marea se mantiene a 120 pt (no es texto) y el estado baja | Reloj se queda en 88; la línea de estado en 28–34 | la barra pasa a **dos filas**: el anillo arriba (72 pt), Temporizador y Marea debajo como botones de texto completo; el sistema la convierte en barra desplazable si hace falta |
| AX3–AX5 | Filas de 112–140; el valor pasa bajo el nombre; el horizonte reduce su altura a ±32 pt (el espacio es para el texto); «Guardar» baja a una segunda línea bajo el nombre | Precio del Pro limitado a `accessibility2` (≈ 84 pt) para no partir «29,99 €»; las cinco filas en dos líneas; el botón de compra crece en alto (56 → 72) y mantiene una línea («Comprar · 29,99 €» cabe hasta AX5 en 353 pt; en inglés también) | Igual; «Se funde a las 03:42» en dos líneas centradas | igual que AX1 |

Comprobación: capturas de cada pantalla en Large, xxxLarge, AX3 y AX5, ES y EN, en el pipeline de UI tests; ningún texto truncado con `…` salvo el nombre de la noche (que se trunca al final, nunca en medio) y las etiquetas de la barra sustituidas por glifo.

### 13.4 Alternativa sin gestos para cada gesto

| Gesto | Alternativa |
|---|---|
| Arrastre horizontal sobre una fila (nivel) | VoiceOver `.adjustable`; pulsación larga → stepper «−5 / +5» inline con botones de 44 pt; Control por voz: «pon Lluvia al 40»; Siri |
| Toque en fila a cero (encender al 40 %) | acción de VoiceOver «Encender»; el stepper |
| Pulsación larga en fila (timbre) | acción de VoiceOver «Timbre»; en Ajustes › Accesibilidad de la app, «Mostrar siempre el timbre» añade la segunda línea de forma permanente |
| Pulsación larga en el horizonte (capas) | Audio Graph del rotor; acción «Oír por capas» |
| «Bajar la persiana» (arrastre hacia abajo → Noche) | botón «Noche» en el menú del anillo (pulsación larga) y, con VoiceOver o con «Botones de accesibilidad» activo, un botón «Noche» de 44 pt visible a la derecha del estado; Atajo; Control por voz «Noche» |
| Toque en Noche (pausa) | acción por defecto de VoiceOver; Acceso asistido: botón único |
| Arrastre hacia arriba en Noche / Madrugada (+15) | acción de VoiceOver «Añadir 15 minutos»; corona del Watch; «+15» de la Live Activity; Siri; en Ajustes de accesibilidad, «Mostrar +15 en Noche» añade un botón de 64 pt bajo la línea de estado |
| Arrastre hacia abajo en Noche (volver) | acción «Volver a la mezcla»; Botón de Atrás del sistema con Full Keyboard Access (Esc) |
| Arrastre del punto en la ola (ritmo) | la fila «Ritmo» con sus tres opciones; `.adjustable` |
| Arrastre del punto en la escala del temporizador | `.adjustable`; toque directo en una marca (cada marca es un objetivo de 44 pt) |
| Deslizar una fila de noche (renombrar / borrar) | acciones de VoiceOver; menú contextual por pulsación larga (sistema) |
| Arrastrar para reordenar noches | acciones «Subir» / «Bajar»; modo edición del sistema |
| Arrastrar la hoja para cerrarla | toque fuera; en iOS 26 el cierre del sistema; Esc con teclado; VoiceOver gesto en Z |
| Pulsación larga en el anillo (menú) | las tres acciones personalizadas de VoiceOver; con Control por voz, «mostrar menú» |

Más: Acceso asistido (iOS 17) con disposición de un botón («Pausar / Reanudar») para Noche y Madrugada; «Diferenciar sin color» ya satisfecho (nada depende de `brasa`); «Reducir transparencia» e «Incrementar contraste» con las variantes del catálogo; Smart Invert con `.accessibilityIgnoresInvertColors()` en horizonte, ola y glifos; Button Shapes muestra contorno en «Guardar», «Restaurar», «Entendido» y en los botones de la barra.

## 14. Textos de interfaz definitivos (ES / EN)

Voz: corta, concreta, serena; segunda persona; sin exclamaciones, diminutivos, emojis ni mayúsculas sostenidas; versalitas para estados; «temporizador», «mezcla», «noche», «de por vida / un solo pago»; nunca «mejora», «terapia», «insomnio», «ansiedad», «IA», «relajante», «vitalicio», «timer», «mix». Los textos en inglés se escriben, no se traducen (en-US; es-ES; es-419 difiere en lo anotado).

### 14.1 Principal

| Clave | ES | EN |
|---|---|---|
| mezcla por defecto | Esta noche | Tonight |
| guardar | Guardar | Save |
| estado reposo | En reposo | Resting |
| estado sonando sin temporizador | Suena · sin temporizador | Playing · no timer |
| estado sonando con temporizador | Suena · se funde a las 00:42 | Playing · fades at 00:42 |
| estado escudo | Suena · toda la noche · para a las 7:30 | Playing · all night · stops at 7:30 |
| estado siesta | Siesta · se funde a las 15:42 | Nap · fades at 15:42 |
| estado con Marea | Suena · Marea 6/min · se funde a las 00:42 | Playing · Tide 6/min · fades at 00:42 |
| estado Marea Océano | Guiando · Océano al 45 | Guiding · Ocean at 45 |
| estado pausa | En pausa | Paused |
| estado pausa llamada | En pausa · llamada | Paused · call |
| estado pausa AirPods | En pausa · AirPods | Paused · AirPods |
| estado volumen 0 | Suena · el volumen del iPhone está al mínimo | Playing · iPhone volume is at minimum |
| estado sin salida | Suena · sin salida de audio | Playing · no audio output |
| estado capa Pro | Suena · Ventilador es parte de Pro | Playing · Fan is part of Pro |
| estado reposo solo Pro | En reposo · Océano es parte de Pro | Resting · Ocean is part of Pro |
| nota de prueba, línea 1 | 7 noches con todo. Sin tarjeta. | 7 nights with everything. No card. |
| nota de prueba, línea 2 | Después, 29,99 € una vez; o sigue gratis con blanco, rosa, marrón y lluvia. Toca para cerrar. | Then $29.99 once; or stay free with white, pink, brown and rain. Tap to close. |
| línea de prueba | prueba · quedan 5 noches | trial · 5 nights left |
| última noche | Prueba · última noche. Después siguen gratis blanco, rosa, marrón, lluvia y 60 minutos. | Trial · last night. White, pink, brown, rain and 60 minutes stay free after. |
| caducada mientras suena | La prueba ha terminado. Esta sesión sigue entera. | The trial has ended. This session stays whole. |
| semana después | sigue gratis · blanco, rosa, marrón, lluvia | still free · white, pink, brown, rain |
| capas | Blanco · Rosa · Marrón · Lluvia · Ventilador · Océano | White · Pink · Brown · Rain · Fan · Ocean |
| subtítulos (VoiceOver / timbre) | siseo parejo · suave y equilibrado · retumbo grave · lluvia fina · ventilador lejano · oleaje lento | even hiss · soft and even · low rumble · fine rain · distant fan · slow swell |
| 1.1 capas | Trueno · Hoguera · Arroyo · Viento · Cabina | Thunder · Fire · Stream · Wind · Cabin |
| más capas (1.1) | Más capas › | More layers › |
| timbre | cálido — brillante · cerca — lejos | warm — bright · near — far |
| valor Pro | pro | pro |
| barra | Temporizador · Marea · 42 min · 6/min | Timer · Tide · 42 min · 6/min |
| menú del anillo | Noche · Dormir con la Marea · Parar en 15 min | Night · Sleep with the Tide · Stop in 15 min |
| tip 2.ª noche | Arrastra sobre una capa para cambiar su nivel. | Drag across a layer to change its level. |
| tip al diferir la mezcla | Guarda esta noche desde su nombre. | Save tonight from its name. |
| tip Noche (1 vez) | Baja la persiana: arrastra el horizonte hacia abajo. La pantalla puede apagarse; el sonido sigue. | Lower the blind: drag the horizon down. The screen can sleep; the sound keeps going. |
| error de audio | El sonido no ha podido empezar. Toca para intentarlo otra vez. | Sound couldn't start. Tap to try again. |
| error nocturno | Se detuvo a las 02:14. | Stopped at 02:14. |
| campo de nombre | Nombre de esta noche | Name for tonight |
| límite de noches | Guardar más noches es parte de Pro › | Saving more nights is part of Pro › |

es-419: «Prende» no se usa; «Toca» vale; «celular» no aparece porque el texto dice «iPhone»; «Siesta» igual; «Guardar» igual; «sigue gratis» igual.

### 14.2 Marea

| Clave | ES | EN |
|---|---|---|
| título | Marea | Tide |
| guiando | Guiando · 6 por minuto | Guiding · 6 per minute |
| se retira | Se retira · 4 min | Receding · 4 min |
| retirada (10 s) | Se ha retirado. El mar sigue. | It has receded. The sea goes on. |
| origen por defecto | Ritmo por defecto. Con Apple Watch puede partir de tu respiración nocturna. | Default pace. With Apple Watch it can start from your night-time breathing. |
| origen Salud (1.1) | Parte de tu ritmo nocturno medio, 14 por minuto, según Salud. | Starts from your average night-time rate, 14 per minute, from Health. |
| filas | Marea · Ritmo · Duración · Háptica | Tide · Pace · Duration · Haptics |
| ritmo valores | Más lento · 5 / Lento · 6 / Natural · 7 | Slower · 5 / Slow · 6 / Natural · 7 |
| duración valor | 15 min, luego se retira | 15 min, then recedes |
| al retirarse (pulsación larga) | Al retirarse: dejar el mar / retirar también el mar | When it recedes: leave the sea / take the sea with it |
| háptica valores | Ninguna · Mínima · Marcada | None · Minimal · Pronounced |
| uso | Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla. | Breathe in as the wave rises, out as it recedes. No need to watch the screen. |
| enlace | Por qué seis por minuto · Qué sabemos y qué no › | Why six per minute · What we know and what we don't › |
| muestra gratuita | Marea · 2 min de muestra | Tide · 2-minute sample |
| parte de Pro | La Marea es parte de Pro › | The Tide is part of Pro › |
| permiso Salud (1.1, purpose string) | SleepNoise lee tu frecuencia respiratoria nocturna para que la Marea empiece a tu ritmo. Solo lectura; nada sale de tu iPhone. | SleepNoise reads your night-time breathing rate so the Tide can start at your pace. Read only; nothing leaves your iPhone. |

### 14.3 Temporizador

| Clave | ES | EN |
|---|---|---|
| título | Temporizador | Timer |
| intención 1 | Hasta dormirme · 45 min · se funde en los últimos 10 | Until I fall asleep · 45 min · fades over the last 10 |
| intención 2 | Escudo nocturno · Toda la noche · baja de nivel a las 2 h · para a las 7:30 | Night shield · All night · lowers after 2 h · stops at 7:30 |
| intención 3 | Siesta · 20 min · se funde en los últimos 3 | Nap · 20 min · fades over the last 3 |
| apagado | Apagado | Off |
| hora del escudo | Para a las | Stops at |
| pie | El sonido se funde antes de terminar. Tu alarma no se silencia. | Sound fades before the end. Your alarm is never silenced. |
| escala | 15 · 30 · 45 · 60 · 90 pro · 2 h pro | 15 · 30 · 45 · 60 · 90 pro · 2 h pro |
| Noche: terminó | Terminó a las 00:42 | Ended at 00:42 |

### 14.4 Noche y Madrugada

| Clave | ES | EN |
|---|---|---|
| fundido | Se funde a las 03:42 | Fades at 03:42 |
| toda la noche | Toda la noche | All night |
| pausa | En pausa | Paused |
| VoiceOver Noche | Suena Lluvia fina y marrón, se funde a las tres y cuarenta y dos. Toca dos veces para pausar. | Playing Steady rain and brown, fades at three forty-two. Double-tap to pause. |
| VoiceOver Madrugada | Madrugada. Toca dos veces para empezar la última noche con la Marea. | Small hours. Double-tap to start last night's mix with the Tide. |
| Ajustes | Entrar en Noche sola (21:00–6:00, iPhone quieto) · Entrar en Madrugada al desbloquear de noche | Enter Night on its own (9 pm–6 am, iPhone still) · Enter Small hours when unlocking at night |

### 14.5 Noches

| Clave | ES | EN |
|---|---|---|
| título | Noches | Nights |
| secciones | tuyas · de la casa | yours · from the house |
| de la casa | Lluvia constante · Concentración · Mar lento · (1.1) Avión de noche | Steady rain · Focus · Slow sea · (1.1) Night flight |
| detalle | Lluvia 65 · Marrón 40 · Marea 15 min · hasta dormirme | Rain 65 · Brown 40 · Tide 15 min · until I fall asleep |
| acciones | Renombrar · Borrar | Rename · Delete |
| vacío | Guarda la mezcla de esta noche desde su nombre. | Save tonight's mix from its name. |
| persistencia | Tus noches se guardan en este iPhone y en iCloud: sobreviven a reinstalar y a cambiar de teléfono. | Your nights are kept on this iPhone and in iCloud: they survive reinstalling and changing phones. |
| borrar (confirmación del sistema) | ¿Borrar «Hotel»? No se puede deshacer. · Borrar · Cancelar | Delete "Hotel"? This can't be undone. · Delete · Cancel |

### 14.6 Pro y prueba

| Clave | ES | EN |
|---|---|---|
| cabecera | sleepnoise pro | sleepnoise pro |
| precio | 29,99 € (StoreKit) | $29.99 (StoreKit) |
| condiciones | Una vez. Sin suscripción. En familia. | Once. No subscription. Family Sharing included. |
| lanzamiento | Precio de lanzamiento hasta el 14 de diciembre; después 34,99 €. | Launch price until December 14; then $34.99. |
| filas | Seis capas, y las que vengan · Marea respiratoria · Escudo nocturno y temporizador sin límite · Noches guardadas sin límite · Apple Watch, widgets y Centro de control | Six layers, and the ones to come · Breathing tide · Night shield and unlimited timer · Unlimited saved nights · Apple Watch, widgets and Control Center |
| sigue gratis | Sigue siendo gratis: blanco, rosa, marrón, lluvia, 60 minutos de temporizador y las noches que ya guardaste. | Stays free: white, pink, brown, rain, a 60-minute timer and the nights you already saved. |
| línea de prueba | prueba · quedan 5 noches · todo abierto | trial · 5 nights left · everything open |
| comprar | Comprar · 29,99 € | Buy · $29.99 |
| comprando (sistema) | — | — |
| gracias | Gracias. Todo abierto. | Thank you. Everything's open. |
| listo | Listo | Done |
| restaurar | Restaurar compra | Restore purchase |
| buscando | Buscando… | Looking… |
| no encontrada | No hay compras con este Apple ID. | No purchases on this Apple ID. |
| error | No se ha podido completar. No se ha cobrado nada. | Couldn't complete. Nothing was charged. |
| sin tienda | La tienda no responde. Nada cambia: sigue sonando. | The store isn't responding. Nothing changes: it keeps playing. |
| privacidad | Nada sale de tu iPhone. | Nothing leaves your iPhone. |
| Ajustes tras comprar | SleepNoise Pro · gracias · Comprado el 16 de noviembre de 2026 | SleepNoise Pro · thank you · Bought November 16, 2026 |
| tarjeta de prueba previa (3.1.1) | 7 noches · Con todo. Sin tarjeta. Después, 29,99 € una vez o la versión gratuita. · Empezar la prueba | 7 nights · Everything. No card. Then $29.99 once, or the free version. · Start the trial |

### 14.7 «Qué sabemos y qué no»

| Clave | ES | EN |
|---|---|---|
| título | Qué sabemos y qué no | What we know and what we don't |
| cabeceras | Lo que sostiene · Lo que no dice · Cómo lo usamos | What it supports · What it doesn't say · How we use it |
| entrada 1 | «Enmascara los sonidos que te despiertan» | "Masks the sounds that wake you" |
| entrada 2 | «Te acompaña a respirar más despacio» | "Keeps you company while you breathe more slowly" |
| entrada 3 | «Sonido que nunca se repite» | "Sound that never repeats" |
| entrada 4 | No es un producto sanitario. | Not a medical device. |
| cierre | Si algo de esto deja de sostenerse, lo cambiaremos aquí y en la app. | If any of this stops holding up, we'll change it here and in the app. |

### 14.8 Ecosistema

| Clave | ES | EN |
|---|---|---|
| Live Activity | Se funde a las 00:42 · 42 min / Toda la noche / En pausa / Marea · 6/min · 12 min / Se funde · 10 min | Fades at 00:42 · 42 min / All night / Paused / Tide · 6/min · 12 min / Fading · 10 min |
| LA +15 | +15 | +15 |
| widget | Suena · En reposo · 42 min · Sin temporizador | Playing · Resting · 42 min · No timer |
| Control toggle | SleepNoise · Suena / En reposo | SleepNoise · Playing / Resting |
| Control botón | Marea 20 min · Mantén para dormir | Tide 20 min · Hold to sleep |
| Watch | Suena · En reposo · En pausa · 00:42 · 42 min | Playing · Resting · Paused · 00:42 · 42 min |
| Siri respuesta | Se funde a las 0:42, 42 minutos. | Fades at 0:42, 42 minutes. |
| Focus filter | Entrar en Noche al abrir · Noche a cargar | Enter Night when opening · Night to load |
| Atajo nombres | Iniciar noche · Parar · Añadir 15 minutos · Dormir con la Marea · Modo Noche · Ajustar capa · Cuánto queda | Start night · Stop · Add 15 minutes · Sleep with the Tide · Night mode · Set layer · Time left |

### 14.9 Ajustes (una sola pantalla, lista del sistema)

| ES | EN |
|---|---|
| Noche: Entrar en Noche sola · Entrar en Madrugada al desbloquear de noche | Night: Enter Night on its own · Enter Small hours when unlocking at night |
| Marea: Háptica (Ninguna / Mínima / Marcada) · Al retirarse | Tide: Haptics (None / Minimal / Pronounced) · When it recedes |
| Accesibilidad: Mostrar siempre el timbre · Mostrar +15 en Noche · Botón Noche visible | Accessibility: Always show tone · Show +15 in Night · Visible Night button |
| Atajos y Focus: Cómo empezar solo al acostarte › | Shortcuts and Focus: How to start on its own at bedtime › |
| SleepNoise Pro · gracias / Pro › | SleepNoise Pro · thank you / Pro › |
| Qué sabemos y qué no › · Nada sale de tu iPhone. · Versión 2.0 (1,8 MB) · Diagnóstico › | What we know and what we don't › · Nothing leaves your iPhone. · Version 2.0 (1.8 MB) · Diagnostics › |

## 15. Onboarding de una noche

No hay onboarding; hay una primera noche bien diseñada. Lo que se aprende, se aprende al usarlo, con una línea de TipKit como mucho por momento y nunca dos a la vez.

| Momento | Qué pasa | Qué se enseña (y cómo) | Qué no pasa |
|---|---|---|---|
| **0 s · abrir** | Principal con «Esta noche» (Rosa 55 · Lluvia 35), nota de prueba, horizonte en reposo | Nada explícito. La forma enseña: dos líneas llenas, un anillo | Ni permisos, ni bienvenida, ni nombre de la app |
| **primer toque en el anillo** | Suena en 800 ms, háptico, el horizonte nace | Que es un instrumento: toco y suena, y veo que se fabrica | Ninguna hoja; ningún «¿te gusta?» |
| **primer arrastre (si ocurre)** | La fila responde | Que la fila es el control | Nada |
| **primer bloqueo** | Live Activity en la pantalla de bloqueo | Que desde ahí se pausa y se ve cuánto queda | Ninguna notificación |
| **las 3 de la mañana** | Si desbloquea con la app delante: Noche o Madrugada | Que de noche la app es negra y un toque basta (VoiceOver lo dice; nadie más lo necesita leer) | No entra en Noche sola la primera noche |
| **la mañana** | Nada | Nada | Ni resumen, ni «¿cómo has dormido?», ni valoración |
| **2.ª noche · abrir** | La nota de prueba ha dado paso a «prueba · quedan 6 noches»; la mezcla de ayer por su nombre («Esta noche») | TipKit bajo la primera fila: «Arrastra sobre una capa para cambiar su nivel.» (se va al primer arrastre o al cerrar) | Nada más |
| **2.ª noche · a los 20 s quieta** | Entra en Noche sola (2 s de fundido) | TipKit, una sola vez, 4 s antes de entrar, bajo el estado: «Baja la persiana: arrastra el horizonte hacia abajo. La pantalla puede apagarse; el sonido sigue.» | No se pide confirmar |
| **la primera vez que la mezcla difiere** | Aparece «Guardar» a la derecha del nombre | TipKit junto a «Guardar»: «Guarda esta noche desde su nombre.» | No se guarda nada automáticamente |
| **la primera vez que toca «Marea»** | Se activa y abre la hoja | La propia hoja: la ola moviéndose y la frase «Inhala mientras la ola sube…» | Ningún vídeo, ningún tutorial de respiración |
| **la primera vez que toca «Temporizador»** | La hoja con «Hasta dormirme» elegida | La fila lo explica en su detalle | Nada |
| **noche 5** | La línea de prueba pasa a dos líneas | Qué seguirá gratis | Ninguna hoja, ninguna notificación |
| **día 8** | Principal entera, filas Pro sin castigo | Nada: el día 8 se parece al día 7 | Ninguna hoja al abrir |
| **primer uso de día** | Si el iPhone está en claro, la paleta papel | Que la app sirve para concentrarse | Ningún «modo foco» que anunciar |

Permisos, cuando lleguen y solo al tocar la función: Salud (1.1, dentro de la hoja Marea, al tocar «Partir de tu respiración»), micrófono (fuera de 1.0), notificaciones (nunca: la app no envía ninguna). Si el usuario deniega, la función que lo pedía sigue funcionando con su valor por defecto y lo dice en una línea.

## 16. Anexo · lo que se añadió a la maqueta

En `scratchpad/design/concepts/marea.html` se añaden, sin alterar los marcos existentes: la fila «Prueba caducada» con dos marcos (la principal en el momento de caducar mientras suena, con Ventilador aún sonando; la hoja Noches del usuario gratuito con «pro» junto a cada parte que no suena), y en la fila «Desde la mesilla»: la Dynamic Island expandida, el widget mediano, el control del Centro de control (on / off) y dos marcos del Apple Watch (sesión; Marea con el háptico). Todos siguen las reglas de §12.
