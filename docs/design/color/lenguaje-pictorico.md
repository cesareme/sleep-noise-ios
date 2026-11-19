# SleepNoise · Lenguaje pictórico propio ("Brasa y lluvia")

Exploración de diseño, 2026-11-19. No toca la dirección 03 ni el código: propone una capa de color sobre Grafito sin cambiar su estructura. Muestras en `paleta.html`, pintadas con canvas y código.

## 0. La idea en tres frases

La página de día gana una **pintura generada en el dispositivo**, igual que el sonido: una ventana de pinceladas cortas y densas, de pigmento saturado y borde empastado, que vive en la banda del horizonte y se apaga con la noche. Nace del motor, no de una imagen: el nivel RMS y la Marea mueven la luz y la respiración de los trazos, nunca su matiz. Y cumple la misma ley que el Índice: **el color es sonido**; cuando el sonido se va, la pintura se seca y se funde a negro, y no vuelve sola.

Nombre interno del lenguaje: **Pigmento**. Tres principios:

1. **Trazo corto, pigmento alto, borde duro.** Lo que da calor es la saturación junta y la textura de empaste, no el degradado suave. Prohibidos los desenfoques gaussianos y los gradientes radiales blandos: eso es el "aurora" que comparten las apps de la categoría.
2. **Un motivo por textura, abstracto antes que figurativo.** Lluvia es dirección y ritmo, no gotas; hoguera es lenguas que suben, no un fuego dibujado; el mar es campo de flujo, no olas con cresta. Nada de paisaje con horizonte, árboles, casas, estrellas ni luna (§3.6 de 03: nunca una luna).
3. **La pintura es fondo, nunca figura.** Jerarquía intacta: texto, Índice y horizonte van encima, con velo y zonas de reserva; la pintura jamás supera cierta luminancia ni toca un píxel de texto.

## 1. Paleta por textura

Once paletas, tres o cuatro tintas cada una. Temperatura declarada; contraste medido sobre `negro #000000` (WCAG). La tinta más clara de cada paleta se usa poco (del 8 al 12 % de los trazos, el "toque de luz"); la más oscura es la base. Ninguna tinta pasa a texto ni a glifos: son pigmento, no tokens de interfaz. El Índice `#F0C020` sigue siendo el único color de la interfaz.

| Textura | Motivo | Tintas (hex · nombre · contraste sobre negro) | Temperatura |
|---|---|---|---|
| Blanco | Campo abstracto fino | `#E3E0D8` hueso 15,9 · `#A9B8C6` gris azulado 10,4 · `#5E6B78` pizarra 3,9 | Neutra fría |
| Rosa | Campo abstracto medio | `#F3D2B8` arena cálida 14,7 · `#E8A598` coral pálido 10,3 · `#C77B8A` rosa viejo 6,6 · `#7A4A5E` ciruela 3,0 | Cálida |
| Marrón | Campo abstracto grueso | `#D9A66B` ocre claro 9,6 · `#B07A4A` tierra 5,7 · `#7A4E2E` castaño 3,0 · `#4A3222` tabaco 1,8 | Cálida |
| Lluvia | Trazos oblicuos | `#B9CDD9` gris agua 12,8 · `#7FA7C9` azul lluvia 8,3 · `#4A6B8A` azul noche 3,8 · `#2E4A5E` pizarra azul 2,3 | Fría |
| Ventilador | Arcos concéntricos | `#D7DBE0` aluminio claro 15,1 · `#B8BFC9` aluminio 11,3 · `#7C8794` gris frío 5,8 · `#4F5862` gris hierro 2,9 | Fría neutra |
| Océano | Campo de flujo | `#CFE7E0` espuma 16,2 · `#3FA7B0` turquesa 7,4 · `#1F6F8B` petróleo 3,7 · `#0F3C56` profundo 1,8 | Fría |
| Trueno | Campo oscuro con una grieta | `#C9C4E8` relámpago lila 12,5 · `#8E7FB8` violeta claro 5,9 · `#6A5A8E` violeta tormenta 3,5 · `#3A3250` añil oscuro 1,8 | Fría |
| Hoguera | Lenguas ascendentes con núcleo de calor y negro entre ellas | `#FFB15C` llama clara 11,7 · `#F08A24` naranja fuego 8,4 · `#D9442B` rojo brasa 4,8 · `#5A2A14` madera quemada 1,8 | Muy cálida |
| Arroyo | Cintas sinuosas | `#BFE3C8` espuma verde 15,0 · `#5FB08A` verde agua 8,1 · `#2F7A5A` musgo 4,1 · `#1E4A3A` poza 2,1 | Fría húmeda |
| Viento | Hebras largas tumbadas | `#E8E0C4` trigo claro 15,9 · `#C9C2A8` hierba seca 11,8 · `#8FA07A` oliva pálido 7,5 · `#5F6B55` oliva oscuro 3,7 | Cálida seca |
| Cabina | Bandas horizontales con grano | `#D6CFC8` lino 13,6 · `#B9A9A0` beige rosado 9,3 · `#8A7F96` gris malva 5,6 · `#5B5566` malva oscuro 2,9 | Neutra tibia |

Por qué estas y no otras:

- **Los tres ruidos de color** son la mitad del uso real y no tienen imagen. Se resuelven como **campos abstractos** cuyo único parámetro visible es el grano: blanco = dabs pequeños y densos (espectro plano), rosa = dabs medios, marrón = trazos largos y gruesos (energía en los graves). El color sigue la metáfora del nombre sin volverse literal.
- **Hoguera** es la paleta más caliente y la más cercana al Índice. Se evita el amarillo puro: la llama clara es `#FFB15C`, matiz 36° frente a los 47° del Índice, y va bajo velo (§5): el amarillo del horizonte sigue siendo lo más luminoso de la pantalla.
- **Trueno** no es un rayo blanco sobre gris: casi todo añil con una sola grieta lila que no cambia de sitio en toda la sesión. Un rayo que parpadee sería un flash en un cuarto a oscuras, y una mentira: el motor no sincroniza nada con la imagen.
- **Ventilador y cabina** son máquinas tranquilas: arcos de aluminio y bandas de lino. Su calor es textura, no color.
- Las mezclas de la casa heredan por capa dominante: "Rosa y lluvia" pinta lluvia con la paleta rosa al 30 %; "Mar y viento" océano con hebras encima; "Marrón y hoguera" la hoguera sobre tabaco; "Pared" el campo marrón solo.

## 2. La pincelada

Todo trazo es un **listón** (ribbon): una curva central más un grosor variable a lo largo, rellenado como polígono. Se genera así:

- **Curva central.** Punto de partida, dirección base del motivo, longitud L. Se muestrea en 6 a 10 pasos y a cada paso se desvía la dirección con **ruido de valor 1D** de amplitud ±12° (lluvia, viento, arroyo) o se sigue el **campo de flujo** (océano, ventilador) o se añade una deriva ascendente con ruido (hoguera). Resultado: un `Path` de cuádricas, nunca una recta.
- **Grosor.** Perfil en huso: 0,35 w en los extremos, w en el 40 % central, con jitter ±15 %. Lo que hace "pincel" es que el inicio sea más ancho que el final en lluvia y hoguera (carga de pintura y arrastre).
- **Empaste como gradiente de borde duro.** Cada listón se rellena con un gradiente lineal perpendicular al trazo de **tres paradas con dos en la misma posición**: tinta clara del 0 al 0,38, tinta base del 0,38 al 1 con una banda sombra `rgba(0,0,0,0.35)` en los últimos 0,12. El salto seco en 0,38 es el relieve del empaste; no hay difuminado.
- **Campo de flujo.** Rotacional rotacional de un ruido 2D de dos octavas; cada listón nace en una rejilla con jitter y sigue el campo 8 pasos. Da el oleaje del mar sin dibujar espirales a mano. Límites: curvatura máxima 0,3 rad por paso y ángulo inclinado hacia la horizontal, para que nada se cierre en círculo (§7).
- **Densidad.** Entre 420 (viento) y 1.300 (blanco) listones por ventana de 402 × 240 pt, con densidad plena en la banda del horizonte y cayendo al 25 % a 120 pt de ella: la pintura tiene un centro y descansa hacia los bordes. Dentro de la banda el fondo no es negro sino la tinta base al 55 % con grano, para que la pintura se lea como pasta; fuera de la banda el fondo es negro.
- **Hoguera, revisada tras el jurado.** La primera versión se leía como hierba o trigo seco: lenguas finas, densas y uniformes, sin negro ni foco de calor. Ahora: densidad ancho × alto / 90, lenguas de 8 a 14 pt en la base que se estrechan hasta la punta (perfil cónico, no huso), un 30 % de lenguas negras entre las de color, llama clara solo en un núcleo central del 40 % del ancho, rojo brasa en los bordes y madera quemada fuera; media docena de brasas de 2 a 3 pt por encima del núcleo.
- **Semilla.** Determinista por `(mezcla, día del año)`: la pintura de hoy no es la de ayer, y la de esta noche no cambia aunque la página se redibuje. Nunca se resiembra en sesión.

Dirección y longitud por motivo:

| Motivo | Dirección | Longitud (pt) | Grosor (pt) | Generador |
|---|---|---|---|---|
| Blanco | Aleatoria isótropa | 6-10 | 3-4 | dabs, ruido fino |
| Rosa | Aleatoria con sesgo horizontal ±20° | 10-18 | 4-6 | dabs medios |
| Marrón | Horizontal ±15° | 22-40 | 7-10 | trazos largos |
| Lluvia | 72° (cae a la derecha) ±6° | 18-34 | 2-3 | ruido 1D, cabeza ancha |
| Ventilador | Tangencial a un centro fuera de la ventana | 24-48 | 3-5 | campo radial |
| Océano | Campo de flujo, deriva horizontal | 18-36 | 5-8 | rotacional de ruido |
| Trueno | Horizontal ±8°, más una grieta de 5 quiebros | 16-30 | 5-7 | dabs oscuros + polilínea |
| Hoguera | Vertical hacia arriba ±14°, cónica | 28-72 | 8-14 en la base, 2-3 en la punta | deriva con ruido, núcleo central, 30 % de negro |
| Arroyo | Horizontal con seno de 3 periodos | 40-90 | 3-5 | cintas sinuosas |
| Viento | Horizontal ±10° con curvatura suave | 60-140 | 1,5-2,5 | hebras |
| Cabina | Horizontal 0° | 80-200 | 6-12 | bandas + grano |

## 3. Cómo responde al sonido real

El motor ya publica el RMS maestro (lineal, convertido por `SoundLevelScale` a `level` 0-1 y `presence` 0-1) y la fase de la Marea. La pintura **solo escucha esas dos cosas** y solo mueve luz y aliento:

| Señal | Parámetro que mueve | Rango | Suavizado | Lo que nunca mueve |
|---|---|---|---|---|
| `presence` | Nacimiento y muerte de la pintura (opacidad global) | 0 → 1 en 2 s, 1 → 0 en 3 s | igual que el horizonte: 20 Hz, τ 500 ms | nada se dibuja si presence = 0 |
| `level` | Luminancia del 18 % de los trazos marcados "vivos" | solo opacidad, 0,45 → 0,85 | τ 500 ms; tope de cambio 0,5 por segundo | matiz, posición, longitud, escala, número de trazos (escalar un raster difumina el empaste y mueve posición, que Motion prohíbe) |
| Marea (fase 0-1, 6-12 por minuto) | Deslizamiento del campo entero en su dirección base, con `offset` redondeado a píxel | ±6 pt, seno de la fase | la propia Marea, ya es lenta | nada más: la Marea es una respiración, no un oleaje |
| Pausa | La pintura se "seca" | opacidad global a 0,6 en 1,5 s, trazos vivos quietos | | no se funde: pausa no es noche |
| Fundiendo (temporizador) | Igual que presence hacia 0 | sigue el RMS que baja | | |

Reglas anti-parpadeo: ningún parámetro cambia más de un 50 % de su rango por segundo; los trazos vivos son siempre los mismos en la sesión (se eligen con la semilla); el ruido blanco y rosa tienen RMS casi plano y por tanto una pintura casi quieta, y eso es verdad, igual que el horizonte (03 §1.4). Lluvia, océano, trueno y hoguera son los que respiran. El trueno **no** destella con el RMS: su grieta es fija y su respuesta al nivel es la misma luminancia lenta que los demás.

## 4. Día y noche

- **La pintura vive de día**, en la fase Día de 03 §3.2, en la página principal y en Capas (detrás del horizonte y tras velo). No existe en hojas, en Mezclas, en Ajustes ni en Pro: nada de color donde se vende.
- **Dos gestos distintos, atenuar y fundir.** Atenuar: con una hoja encima o la app al fondo la pintura baja a opacidad 0,3 en 1,5 s y vuelve en 800 ms al cerrar la hoja o volver; abrir el Temporizador de día no mata la pintura. Fundir: a negro en 3 segundos (250 ms con Reducir movimiento) al entrar en Noche o en Madrugada, cuando la página pasa a nocturna, cuando el reloj llega a las 21:00 con la app delante o con `isLuminanceReduced`. El fundido es opacidad lineal, sin desplazamiento, y al terminar la vista de pintura deja de existir (nil, no opacidad 0).
- **Tras fundir, nunca vuelve sola.** Ni a las 07:00, ni al desbloquear. Vuelve solo con la salida deliberada de la página nocturna (tocar el nombre de la mezcla, C40) y solo si son entre las 07:00 y las 21:00. Antes de las 21:00 vuelve en 2 s; de noche la salida deliberada deja la página con tinta nocturna y sin pintura.
- **Noche y Madrugada: nada.** Pantalla negra, horizonte, reloj, palabra. La "brasa" de hoguera a 2 % de luminancia se explora como experimento de 1.1 tras ajuste, apagada por defecto, un solo listón de `#5A2A14` al 10 % (Y ≈ 0,002) bajo el horizonte; si en la prueba de la mesilla a oscuras se ve desde la almohada, se descarta. La página nocturna tampoco lleva pintura.

## 5. Convivencia con el Índice y la tipografía

- **Ventana.** La pintura ocupa una banda de 240 pt centrada en el horizonte (y = altura × 0,333, 03 §3.5): 120 pt arriba y 120 pt abajo, ancho completo sin margen. En SE la banda baja a 180 pt. Fuera de la ventana, negro puro. En AX1+ la banda se recorta a 120 pt y se ancla bajo la cabecera.
- **Zonas de reserva.** Nombre de la mezcla y estado (arriba), filas de capas y barra (abajo): siempre sobre negro. Si una fila entra en la ventana (SE, AX), el velo sube al 90 % debajo de esa fila.
- **Velo.** Capa `negro` sobre la pintura: 35 % en el centro de la banda, 75 % en sus bordes superior e inferior, curva ease-in-out, para que la pintura "se apague hacia el texto" sin línea de corte. Tope de luminancia del píxel más claro tras velo: Y ≤ 0,28 (equivale a un gris de contraste 6,6:1). El Índice `#F0C020` tiene Y = 0,58: siempre es lo más luminoso de la pantalla, y lo más saturado en su matiz.
- **Horizonte.** Encima de la pintura y del velo, con una franja de reserva de 24 pt centrada en el horizonte: velo del 80 % y sin tintas de luz, más un halo negro seco de 3 pt a cada lado del trazo (sin blur). Un halo de 2 pt no bastaba cuando la pintura detrás es clara: el Índice sobre llama se perdía a un vistazo. Con Marea, la línea de agua se dibuja igual y la reserva la acompaña.
- **Texto sobre pintura: nunca.** Si una medición encuentra un glifo sobre la ventana, es un bug. El único texto cercano es el valor bajo el dedo (17 Medium), que ya lleva su pista `grafito`.
- **Un Índice por pantalla** sigue vigente. La pintura no cuenta como acento porque no es un elemento: es el papel.

## 6. Accesibilidad

- **Reducir movimiento.** Pintura estática. Solo opacidad global con presence (4 Hz, τ 1,5 s, como el horizonte reducido). Sin deslizamiento de Marea, sin trazos vivos. Fundidos a 250 ms.
- **Aumentar contraste.** Velo al 60 % en el centro y 90 % en los bordes; tope Y ≤ 0,14; tintas de luz sustituidas por la base (la pintura pierde brillo, no textura). El Índice pasa a `índice-ac`.
- **Reducir transparencia.** No afecta: no hay materiales ni blur. El velo es un relleno negro con opacidad, no un material.
- **Diferenciar sin color.** La pintura no comunica estado; el estado sigue en palabras. Se puede apagar en Ajustes ("Pintura: de día / nunca"), y se apaga sola con `accessibilityReduceMotion` + `increaseContrast` a la vez.

## 7. Lo que lo haría parecer una copia

Las trampas se describen por lo que no se hace, sin identificar obras ni autores (este fichero vive en un repositorio público):

- **Nada de paisaje.** Sin cielo, sin astros, sin horizonte pictórico, sin figuras verticales oscuras en primer plano, sin reflejos de puntos de luz en agua. Nuestro campo de flujo no cierra espirales (curvatura limitada) y no hay escena.
- **Nada vegetal ni figurativo.** Ni flores, ni espigas, ni árboles, ni orillas. Viento es hebras, no espigas; arroyo es cinta, no orilla.
- **Nada urbano ni de interior.** Ni luz artificial, ni calles, ni habitaciones, ni perspectiva. Nuestro amarillo es solo el Índice y es una línea.
- **Nada de la pareja azul más ocre o amarillo en el mismo motivo.** Es la combinación más asociada a la pincelada corta y curva; en océano y lluvia no entra ningún pigmento cálido (Mar y viento usa solo las dos tintas oliva oscuras del viento, al 70 %), y en hoguera no entra ningún azul.
- **Nada de trazos cortos todos iguales, paralelos y curvos.** Se evita con tres cosas: grosor variable (huso o cono), dirección que nace del motivo (vertical en fuego, oblicua en lluvia) y densidad que cae hacia los bordes.
- **Marco, lienzo, craquelado, firma.** Nada que simule un objeto de museo; la pintura no tiene bordes.
- **Nombres.** En la app, la ficha, las capturas, el código, los commits y los ficheros del repositorio no se nombra a ningún pintor, obra ni movimiento. Internamente el lenguaje se llama Pigmento y el estilo se describe como "pincelada corta de pigmento alto".

## 8. Lo que lo hace nuestro

- **La pincelada nace del sonido.** No es una ilustración que acompaña a un sonido; la pintura se levanta con presence, respira con level, se desliza con la Marea y se seca con la pausa. Y es generativa y determinista como el ruido: la de hoy no es la de ayer, y en Ajustes puede decir "pintura generada en este iPhone, 0 MB de imágenes".
- **Once motivos de un solo gesto.** Lluvia = oblicua y ritmo; hoguera = lengua que sube y se estrecha; mar = flujo que gira sin cerrarse; arroyo = cinta sinuosa; viento = hebra larga tumbada; trueno = añil quieto con una grieta fija; ventilador = arcos de aluminio; cabina = bandas de lino con grano; blanco, rosa y marrón = campos abstractos que solo se diferencian en el grano, exactamente como se diferencian en el espectro.
- **El negro sigue mandando.** La pintura es una ventana en una página negra, no una página pintada. Se apaga a las 21:00 y no vuelve sola. Ninguna app de la categoría se atreve a apagar su color por la noche: ese es el gesto propio.
- **Empaste sin blur.** Borde duro, relieve por gradiente de parada doble, grano. Lo contrario del "aurora" difuminado de la competencia y lo contrario del render fotográfico.

## 9. Coste de render en SwiftUI

Tres caminos evaluados:

1. **Raster en segundo plano más una capa viva en opacidad (recomendado para 1.0).** La geometría (entre 420 y 1.300 listones por ventana, con sus gradientes) se genera en un `actor` con el mismo generador que las maquetas: LCG (1664525, 1013904223) y FNV-1a portados como `struct RandomNumberGenerator`, `Float` con redondeo a 1/4 pt, semilla fijada en los tests para que las piezas coincidan entre iPhone, simulador y CI. Se rasteriza en una cola de fondo con `UIGraphicsImageRenderer` o `CGContext` (como ya hace `scripts/icon/IconGenerator.swift`), nunca con `ImageRenderer`, que es `@MainActor` y pintaría miles de listones en el hilo principal al abrir la app o cambiar de mezcla; `ImageRenderer` solo en tests de snapshot. Dos rasters recortados a la ventana (3,5 MB cada uno a 3x): la **capa seca** (82 % de los trazos) y la **capa viva** (18 %), que cambia solo de opacidad, leída dentro del mismo `TimelineView` de `SoundLine` (20 Hz; 4 Hz y τ 1,5 s con Reducir movimiento). Sin `scaleEffect`: escalar un raster difumina el borde y mueve posición. La Marea desliza con `offset` redondeado a píxel. Coste por fotograma: una composición de dos imágenes. Las piezas estáticas pequeñas (reglas de Capas, bandas de Mezclas, captura) se generan en tiempo de compilación como PNG en `Assets.xcassets` con un script hermano de `scripts/icon/generate.sh`, menos de 2 MB en el paquete, y no llevan motor en runtime.
2. **Metal.** Sobra: pocos trazos y sin partículas. Añadiría shaders, un objetivo de test y un camino de fallo en simulador. Para 2.0 si la pintura quisiera reaccionar por capa.
3. **Imágenes prerrenderizadas para la ventana.** Descartadas: once texturas por tres escalas por dos fases rondan 40 MB, contradice "cero imágenes", pierde la semilla diaria y la respuesta al sonido. (Las piezas pequeñas sí se prerrenderizan: pesan KB, no MB.)

Reglas de coste: nada se dibuja fuera de Día; la pintura no tiene `TimelineView` propio y lee el `isFrozen` del Horizonte; los rasters se ponen a nil (no a opacidad 0) con `nightPhase.isNight`, con `NightWindow.contains(now)`, con `isLuminanceReduced` y al pasar al fondo; la capa seca se regenera solo al cambiar de mezcla o de día; en StandBy, Live Activity, widgets y Watch no hay pintura (03 C62: una sola tinta fuera de la app). Batería: ninguna cifra hasta medirla con MetricKit (`MXDisplayMetric.averagePixelLuminance` y `MXCPUMetric`) en una build interna, una hora de página negra frente a una hora pintada, de 20:00 a 21:00. Pruebas en CI: snapshot de las once ventanas con semilla fija; luminancia media del raster velado ≤ 0,08 fuera de la banda y máximo Y ≤ 0,28 tras velo; test en `NightScreenTests` de que la vista de pintura no existe bajo Noche ni a las 21:01.

## 10. Siguientes pasos

1. Ver `paleta.html` en un iPhone a oscuras y a la luz.
2. Prototipo SwiftUI de la ventana con hoguera y lluvia sobre la página real, con el horizonte encima, para la prueba de cinco segundos.
3. Decidir si Capas lleva la regla vertical de 4 pt por fila, o nada.
4. Medir batería real con la página delante de 20:00 a 21:00.
