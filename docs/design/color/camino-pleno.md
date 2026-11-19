# Camino C · Pintura plena

Exploración de diseño, 2026-11-19, revisada tras el jurado el mismo día. Maqueta: `camino-pleno.html` (siete iPhones de 402 × 874, pinturas en canvas con el lenguaje Pigmento y su paleta; nada incrustado). No toca código ni la dirección 03. El nombre anterior del camino aludía a un movimiento artístico y se ha retirado: en ramas, commits, PR y docs se usa solo Pigmento y descripciones de lo que se ve.

## Tesis en tres frases

De día, la página principal y Capas de SleepNoise son una pintura generada en el iPhone de la mezcla que suena, a sangre, con la tipografía, los pasos, las hairlines y el Índice de Grafito encima sobre velo. Mezclas lleva la banda de 64 pt de las mezclas de la casa, el Temporizador conserva la hoja gris con una cabecera pintada de 110 pt y la hoja Pro no lleva pintura: nada de color donde se vende. A las 21:00 todo se funde a negro y no vuelve solo: la noche sigue siendo la de Grafito.

Lo que cambió tras el jurado: se suprime el segundo acento (estado y nivel vuelven a `texto` y `texto2`; el único color de interfaz es el Índice y solo mientras suena), se quita la galería de bandas de 88 pt de Mezclas y la pieza de océano sobre el precio (el patrón visual del catálogo y el paywall de las apps de suscripción), las hojas conservan la hoja gris porque una `.sheet` de SwiftUI no ve el lienzo de debajo, y Mar lento pierde el marrón sobre el flujo turquesa.

## Reglas de día y de noche

- Día (07:00 a 21:00): la pieza ocupa la página y Capas; el texto se apoya sobre velo negro al 78 % y las ventanas abiertas llevan velo del 18 al 22 %. Franja de reserva de 24 pt centrada en el horizonte al 80 % y halo seco de 3 pt: el Índice sigue siendo lo más luminoso.
- Mezclas: banda de 64 pt a sangre por la izquierda solo en las mezclas de la casa, velo del 12 %; lo tuyo sin pintura.
- Hojas: Temporizador y Marea con hoja gris y como mucho una cabecera de 110 pt rasterizada una vez; Pro sin pintura. La hoja Pro no existe entre las 21:00 y las 07:00.
- Atenuar (hoja encima, app al fondo): opacidad 0,3 y vuelta en 800 ms. Fundir (Noche, Madrugada, página nocturna, las 21:00 con la app delante, `isLuminanceReduced`): a negro en 3 s (250 ms con Reducir movimiento), sin vuelta sola; solo la salida deliberada de la página nocturna, y de día.
- Noche, Madrugada y página nocturna: negro, una tinta, horizonte a 2 pt, ningún píxel de pintura; los rasters se ponen a nil, no a opacidad 0.
- Fuera de la app (Live Activity, StandBy, widgets, Watch): sin pintura, una tinta, como fija 03.

## Cómo responde al sonido

Como en Pigmento: `presence` levanta y apaga la pieza (2 s / 3 s); `level` mueve solo la opacidad del 18 % de trazos vivos (0,45 → 0,85), sin escala; la Marea desliza el campo ±6 pt con desplazamiento redondeado a píxel; la pausa seca la pintura al 30 % sin fundirla. Nada cambia de matiz, posición ni número de trazos, ni más de un 50 % de su rango por segundo. Solo la página y Capas respiran; bandas y cabeceras son estáticas. El trueno no destella. La pintura no tiene `TimelineView` propio: lee el `isFrozen` del Horizonte.

## Qué cambia en el código real, por pantalla

| Pantalla | Cambio | Coste |
|---|---|---|
| Motor de pintura | Listones por `(textura, semilla)` con el mismo LCG y FNV-1a portados a Swift; geometría en un actor; raster en cola de fondo con `UIGraphicsImageRenderer` o `CGContext`; `ImageRenderer` solo en tests de snapshot; pruebas de luminancia tras velo | L (3 a 4 semanas) |
| Página de día | Pieza a sangre con una sola capa viva recortada a la banda del horizonte (3,5 MB); velo por zonas; reserva y halo; las filas de capa bajan de y 312 a 472 para abrir la ventana (la página nocturna sigue la misma cota) | M (2 semanas) |
| Capas | Pieza de la mezcla, velo al 78 % bajo las seis filas, ventana bajo el título | S (1 semana) |
| Mezclas | Banda de 64 pt de la casa (la de A), rasterizada por fila visible y soltada al salir | S (3 días) |
| Temporizador y Marea | Hoja gris con cabecera de 110 pt rasterizada una vez | S (3 días) |
| Hoja Pro | Nada | 0 |
| Noche, Madrugada, nocturna | Fundido de entrada; rasters a nil; test en `NightScreenTests` de que la vista de pintura no existe bajo Noche | S (2 a 3 días) |
| Ajustes y accesibilidad | "Pintura: de día / nunca"; variantes para Reducir movimiento y Aumentar contraste | S (1 semana) |

Total estimado: 8 a 10 semanas de una persona (la versión anterior, con hojas repintadas y once bandas, costaba 10 a 12 y una semana más por hoja).

## Riesgo para la marca

Alto. Grafito se definió por lo que no hay: negro, tres grises, un acento, cero ilustración. Este camino convierte la app de día en una app de fondos pintados, el territorio de las apps de ambiente, y la diferencia pasa a ser la calidad de la pintura, no el instrumento. Lo salva la noche negra que ninguna otra tiene, la pintura generada y no descargada, que los tokens de texto no cambien y que la venta siga en gris. Lo hunde que una pieza recuerde a una obra concreta, que el velo se afloje o que la ficha hable de estilos. Si se elige, conviene renombrar la dirección y rehacer la ficha.

## Riesgo de batería, memoria y calor

Medio, sin cifra hasta medir. Una pieza a sangre a 3x son 12,6 MB RGBA; con la capa viva recortada a la banda se queda en 16 MB por pantalla, y todo a nil fuera de Día. En OLED una página casi llena de color consume bastante más que una negra: medir con MetricKit (`MXDisplayMetric.averagePixelLuminance`, `MXCPUMetric`) de 20:00 a 21:00 antes de publicar ninguna cifra. En CI, test de luminancia media del raster velado.

## Accesibilidad

- Texto siempre sobre velo del 78 %: 4,5:1 con `texto` frente a la tinta más clara; bajo texto las tintas de luz se limitan al 8 % y se mide por captura. Sin segundo acento no hay texto de 13 pt en color.
- Aumentar contraste: velo al 90 % bajo texto y al 60 % en ventanas, tintas de luz sustituidas por la base, sin capa viva, Índice en `índice-ac`.
- Reducir movimiento: pintura estática, solo opacidad global a 4 Hz, fundidos de 250 ms.
- Nada de estado vive en la pintura. Ajuste "Pintura: nunca". VoiceOver ignora las piezas.
- Dynamic Type AX1 o más: las ventanas abiertas se cierran y la pieza queda solo bajo velo al 78 %.

## Decisión que se le pide al dueño

Elegir entre tres cosas que no caben juntas: la calidez de una app pintada de día, la marca Grafito tal como está escrita, y el presupuesto de 1.0. Este camino da la primera a cambio de reescribir la segunda y de 8 a 10 semanas. Antes de decidir, la prueba de cinco segundos: la página de día de la maqueta en un iPhone junto a la página Grafito, a diez personas, "¿qué hace esta app?". Si más de tres dicen "fondos" o "pinturas" y menos de tres dicen "sonido", este camino no es el de SleepNoise y conviene A con la ventana de B.
