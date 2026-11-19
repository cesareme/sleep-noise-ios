# Camino B · Lienzo vivo

Exploración de diseño, 2026-11-19, revisada tras el jurado el mismo día. Maqueta: `camino-lienzo.html`.

## Tesis en tres frases

La página de día lleva una pintura generada en el iPhone de la mezcla que suena, en una ventana de 240 pt alrededor del horizonte: cada capa activa pone su motivo y su color en proporción a su nivel, los campos (blanco, rosa, marrón, cabina, ventilador) debajo y las camas (lluvia, hoguera, mar, arroyo, viento, trueno) encima. La pintura es sonido, como el Índice: nace con el audio, respira con el RMS maestro, se desliza con la Marea, se seca al pausar y se funde a negro a las 21:00 o al entrar en Noche, y no vuelve sola. Fuera de la ventana la página es la de Grafito: negro puro, `texto` y `texto2` intactos, y el Índice sigue siendo lo único con color en la interfaz.

Lo que cambió tras el jurado: la primera versión pintaba toda la página bajo un velo y pasaba el texto a una sola tinta. Eso contradecía la regla "texto sobre pintura: nunca" del lenguaje §5, aplanaba la jerarquía y dejaba `texto2` en 2,4 a 3,6:1. Ahora la pintura vive solo en la ventana, con reservas negras para nombre, filas y barra.

## Reglas de día y de noche

- Día (07:00 a 21:00): pintura en la ventana 172 a 412 pt de la página principal. Nunca en Capas (es toda texto), Mezclas, hojas grises, Pro ni Ajustes. Si el dueño quiere color en Capas, el injerto es la regla vertical de 4 pt del camino A.
- Densidad: 100 % en la banda del horizonte (184 a 312, la de la Marea), cayendo al 25 % a 120 pt de la banda. Fuera de la banda el fondo es negro, no tinta base al 55 %.
- Velo: 42 % en la banda, 75 % en los bordes de la ventana, franja de reserva de 24 pt centrada en el horizonte al 80 % y sin tintas de luz, 90 % bajo las filas que entran en la ventana. Tintas de luz solo dentro de la banda, con pluma de 20 pt. El Índice (Y 0,58) sigue siendo lo más luminoso y lleva halo negro seco de 3 pt.
- Barra inferior sobre negro, sin material ni desenfoque: en SwiftUI un `backdrop-filter` es un material que Reducir transparencia sí altera y que cuesta una pasada fuera de pantalla por fotograma.
- Atenuar (hoja encima, app al fondo): opacidad 0,3 en 1,5 s y vuelta en 800 ms. Pausa: igual, trazos vivos quietos, horizonte en hairline; pausa no es noche.
- Fundir (Noche, Madrugada, página nocturna, las 21:00 con la app delante, `isLuminanceReduced`): a negro en 3 s (250 ms con Reducir movimiento), sin vuelta sola; vuelve solo con la salida deliberada de la página nocturna y entre 07:00 y 21:00.
- Noche, Madrugada y página nocturna: negro, como hoy. La vista de pintura no existe (nil, no opacidad 0).
- Semilla por (mezcla, día del año): la de hoy no es la de ayer y no cambia en la sesión.

## Qué parámetro del sonido mueve qué

| Señal del motor | Qué mueve | Rango y suavizado |
|---|---|---|
| Niveles de la mezcla | Composición: listones por motivo = densidad del motivo × nivel / suma de niveles; fondo = tinta más oscura de la capa dominante al 55 % solo en la banda | Se regenera al cambiar de mezcla o de día |
| `presence` (RMS −72 a −66 dBFS) | Opacidad global: nacimiento y muerte | 0 → 1 en 2 s, 1 → 0 en 3 s; τ 500 ms a 20 Hz |
| `level` (RMS −48 a −9 dBFS) | Solo la opacidad de la capa viva (18 % de los listones, fijos por semilla): 0,45 → 0,85. Sin escala: escalar un raster difumina el empaste y mueve posición | τ 500 ms, tope 0,5 por segundo; nunca matiz, posición ni número |
| Fase de la `BreathCurve` (Marea) | Deslizamiento de la ventana ±6 pt en la dirección del motivo dominante, con `offset` redondeado a píxel (`Grid.pixelRound`) | La propia curva, 4 s sube y 6 s baja |
| Ganancia del temporizador | Lo mismo que `presence` | Sigue el RMS que baja |

El trueno no destella: su grieta es fija. La pintura no tiene `TimelineView` propio: lee el `isFrozen` del Horizonte y comparte su pausa.

## Qué cambia en el código real

| Pantalla | Cambio | Coste |
|---|---|---|
| Motor de pintura | Generador de listones en Swift (mismo LCG 1664525 / 1013904223 y FNV-1a como `RandomNumberGenerator`, `Float` con redondeo a 1/4 pt); geometría en un actor; raster en cola de fondo con `UIGraphicsImageRenderer` o `CGContext` (como `scripts/icon/IconGenerator.swift`); `ImageRenderer` solo en tests de snapshot | M (2 semanas) |
| Principal (`PageView`) | `PaintWindow` detrás del `VStack`: capa seca y capa viva recortadas a la ventana (3,5 MB a 3x cada una), capa viva solo en opacidad dentro del `TimelineView` del horizonte; velo y reservas; atenuar y fundir con `nightPhase`, `scenePhase`, `sheetPresented`, `isLuminanceReduced`, `NightWindow`; rasters a nil al entrar en Noche o al pasar al fondo | M (2 semanas) |
| `Ink` | Nada: fuera de la ventana no hay pintura y `texto2` se conserva | 0 |
| Capas, Noche, Madrugada, nocturna | Nada en pantalla; test en `NightScreenTests` de que la vista de pintura no existe bajo Noche | S |
| Ajustes | Fila "Pintura: de día / nunca" | S |
| CI | Snapshots de las cuatro mezclas de la casa con semilla fija; luminancia media del raster velado ≤ 0,08 fuera de la banda; pintura ausente al entrar en Noche y a las 21:00 | M (1 semana) |

Total: 5 a 6 semanas de una persona (la versión a toda página estimaba 6 a 8 y costaba además tocar `Ink.secondary`, `TextAction`, `StateWord`, `PageStatus` y `DesignTokenTests`).

## Riesgos

- Marca: el color entra en la página, que era lo que hacía distinta a la app (negro con una línea). Lo sostiene que la pintura sea sonido, que viva solo en la ventana del horizonte y que se apague a las 21:00. Si la pincelada degenera en degradado, se parece a las "auroras" de la categoría.
- Propiedad intelectual: ningún listón parte de obra ni foto; sin nombres de pintores, obras ni movimientos en código, ficha, capturas ni commits; si una escena recuerda a una obra concreta, se rehace.
- Batería: no hay cifra hasta medir. En OLED el consumo sigue la luminancia media de subpíxeles; la página negra enciende un 3 a 5 % de la pantalla y la ventana con tintas oscuras veladas debería quedar por debajo de Y 0,10 de media. Medir con MetricKit una hora de página negra frente a una hora pintada, de 20:00 a 21:00, en una build interna.
- Memoria: dos rasters de 3,5 MB, a nil fuera de Día. Con audio de fondo toda la noche la app debe quedar pequeña para no ser expulsada.

## Accesibilidad

Reducir movimiento: pintura estática, solo opacidad con `presence` a 4 Hz y τ 1,5 s, fundidos de 250 ms, sin Marea. Aumentar contraste: velo 65 % en banda y 90 % en bordes, sin tintas de luz, sin capa viva. Reducir transparencia: sin efecto (el velo es un relleno, la barra es negra). Diferenciar sin color: la pintura no comunica estado. VoiceOver: ventana decorativa; solo la nombra Ajustes ("Pintura generada en este iPhone, 0 MB de imágenes"). AX1+: ventana de 120 pt bajo la cabecera.

## La decisión que le pide al dueño

Una: ¿acepta que la página de día lleve una ventana pintada alrededor del horizonte, con el resto negro como hoy? Dos: la prueba de cinco segundos con la maqueta en un iPhone, a la luz y a oscuras en la mesilla, antes del 27-11-2026.
