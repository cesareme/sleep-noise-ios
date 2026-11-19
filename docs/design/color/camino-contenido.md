# Camino A · Color contenido

Exploración de diseño, 2026-11-19, revisada tras el jurado el mismo día. Maqueta: `camino-contenido.html` (siete marcos de 402 × 874, pinturas generadas en canvas con la paleta y la pincelada de `lenguaje-pictorico.md`). No toca la dirección 03 ni el código.

## Tesis en tres frases

La pintura es contenido, como la receta de una mezcla, no interfaz: vive sobre todo donde se elige algo (Mezclas, Capas, tienda) y entra en la página principal solo como una ventana alrededor del horizonte, el injerto del camino B que pidió el jurado. Grafito no cambia ni un token: la página sigue siendo negro, un Horizonte y un Índice, y el color llega como lámina junto al texto, nunca debajo de él. Cada pieza nace de una semilla fija por mezcla o textura, con cero imágenes descargadas, y se apaga a las 21:00 igual que la venta.

## Dónde aparece y dónde no

- **Página principal (día).** Ventana de 240 pt centrada en el horizonte (y 292): densidad plena en la banda del horizonte y al 25 % a 120 pt de ella; velo del 35 % en el centro y 75 % en los bordes; franja de reserva de 24 pt bajo el Índice con velo del 80 % y sin tintas de luz; velo del 90 % bajo cualquier fila que entre en la ventana. Nombre, estado, filas y barra siguen sobre negro y `texto2` se conserva. Halo seco de 3 pt a cada lado del horizonte.
- **Mezclas (día).** Una banda de 64 pt a sangre por la izquierda en cada mezcla de la casa (rosa y lluvia, mar y viento, marrón y hoguera, pared), velo negro del 12 %. El texto empieza a 20 pt de la banda; las mezclas propias y "Ajustes" no llevan pintura. La casa pinta, lo tuyo es tuyo.
- **Capas (día).** Una regla vertical pintada de 4 pt en el margen izquierdo, a la altura de la fila, con las dos tintas oscuras de la textura. El nombre no se mueve. (El jurado descartó las pastillas de 32 pt: a ese tamaño el motivo no se lee.)
- **Hoja Pro (día).** En revisión: la maqueta conserva una pieza de 402 × 120 bajo el indicador para que el dueño compare, pero el estudio y el jurado prefieren la hoja gris de 03 sin pintura: nada de color donde se vende. La hoja no se abre entre las 21:00 y las 07:00.
- **Icono.** Sin cambios: "La regla y la marea" de 03 #27 en negro. El fondo pintado rompía 11 §2.1 (fondo plano, sin segundo color) y obligaba a dos iconos. El color de tienda va en las capturas.
- **Tienda.** Una captura nueva (Mezclas de día) con el titular común a los tres caminos, "Lo que suena, se pinta.", y el texto de reserva de la ficha como subtítulo. Las otras cinco capturas de C57 siguen en negro.
- **Nunca:** Noche, Madrugada, página nocturna, Live Activity, StandBy, widgets, Watch.

## Reglas de día y noche

Fase Día de 03 §3.2: la pintura existe. Dos gestos distintos:

- **Atenuar** (hoja encima, app al fondo): opacidad 0,3 en 1,5 s y vuelta en 800 ms al cerrar la hoja o volver. Abrir el Temporizador de día no mata la pintura.
- **Fundir** (entrar en Noche o Madrugada, página nocturna, las 21:00 con la app delante, `isLuminanceReduced`): a negro en 3 s (250 ms con Reducir movimiento) y no vuelve sola. Vuelve solo con la salida deliberada de la página nocturna (C40) y solo de día. Nada se mueve de sitio: el hueco de la banda se queda y se lee como margen.

## Cómo responde al sonido

Poco y a propósito. La ventana de la página respira como en el lenguaje §3: `presence` la levanta y la apaga, `level` mueve solo la opacidad del 18 % de trazos vivos (sin escala: Motion prohíbe mover posición y escalar un raster difumina el borde), la Marea la desliza ±6 pt con desplazamiento redondeado a píxel. Las reglas de Capas están vivas (100 %) si la capa suena y secas (42 %) si está a cero. Las bandas de Mezclas no escuchan el motor: son láminas quietas. "Color = sonido o dedo" se mantiene en la página y se relaja, declaradamente, en las pantallas de elección.

## Qué cambia en el código, por pantalla

| Pantalla | Cambio | Coste |
|---|---|---|
| Piezas estáticas | Generadas en tiempo de compilación como PNG en `Assets.xcassets` con un script hermano de `scripts/icon/generate.sh` (generador de listones portado a Swift con el mismo LCG y FNV-1a, semilla fija por textura, 2x y 3x, menos de 2 MB en el paquete): once reglas de 4 × 56, cuatro bandas de 64 × 92, una captura. Sin motor de pintura en runtime para estas piezas. | S (4 días) |
| Página principal | `PaintWindow` detrás del `VStack`: geometría en un actor, raster en cola de fondo con `UIGraphicsImageRenderer` recortado a la ventana (3,5 MB a 3x), capa viva solo en opacidad leída dentro del `TimelineView` del horizonte; a nil con `nightPhase.isNight`, `NightWindow.contains(now)`, `isLuminanceReduced` y al pasar al fondo | M (1,5 semanas) |
| Mezclas | Fila de la casa con banda a sangre, velo, atenuar y fundir; `ViewThatFits` en AX | S (3 días) |
| Capas | Regla de 4 pt en `LevelRule` con opacidad por nivel; VoiceOver la ignora | S (1 día) |
| Tienda | Una captura compuesta por `screenshots.sh` desde un `-pageState`; lint de S-08 al titular | S (1 día) |
| Pruebas | Snapshots con semilla fija; luminancia media del raster velado ≤ 0,08 fuera de la banda; test en `NightScreenTests` de que la vista de pintura no existe bajo Noche | S (2 días) |

Total aproximado: 3 a 3,5 semanas de una persona, sin Metal, sin dependencias. Sin la ventana de la página principal, 2 a 2,5 semanas.

## Riesgos

- **Marca.** Bajo. Grafito sigue intacto donde se le reconoce (la Noche y la estructura de la página); el riesgo era el contrario, que el color se viera tan poco que no respondiera a la queja del dueño, y la ventana lo corrige.
- **Batería y memoria.** Bajos. Piezas estáticas sin coste por fotograma; un solo raster vivo de 3,5 MB. Medir con MetricKit (`MXDisplayMetric.averagePixelLuminance`, `MXCPUMetric`) una hora de página negra frente a una hora pintada, de 20:00 a 21:00; las cifras de consumo no se publican hasta medirlas.
- **Propiedad intelectual.** Composiciones abstractas, paleta propia, nada figurativo, nada de nombres; cumple `propiedad-intelectual.md`.

## Accesibilidad

Reglas, bandas y ventana son decorativas (`accessibilityHidden`), nunca llevan texto, no cambian el objetivo táctil. Aumentar contraste sube el velo y sustituye la tinta de luz por la base; con Aumentar contraste la capa viva no existe. Reducir movimiento: pintura estática, solo opacidad con `presence` a 4 Hz y τ 1,5 s. Diferenciar sin color: el estado sigue en palabras. Ajuste "Pintura: de día / nunca". Dynamic Type: la banda crece con la fila; en AX1+ la ventana se recorta a 120 pt bajo la cabecera.

## Decisión que pide al dueño

¿Basta con la ventana de la página de día, las bandas de la casa en Mezclas, las reglas en Capas y una captura, con icono y hoja Pro sin pintura? Si quiere la página entera pintada, el camino es C; si quiere algo antes de enviar 1.0, la variante mínima son las bandas de Mezclas y la captura, que no tocan la página.
