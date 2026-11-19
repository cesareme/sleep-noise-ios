# SleepNoise · Pintura de la casa · generador

**19 de noviembre de 2026 · Notas del generador, no una spec. Manda `docs/design/12-EXPLORACION-COLOR-2026-11-19.md` (§2 lenguaje, §6.1 variante mínima, §7 fases 0 y 1); la paleta y la pincelada son las de `docs/design/color/lenguaje-pictorico.md`; la composición de las cuatro mezclas es la de `docs/design/color/camino-contenido.html`.**

## Qué es

Las piezas pintadas de las cuatro mezclas de la casa: una banda de 64 × 288 pt por mezcla, a 2x y 3x, en `SleepNoise/Resources/Assets.xcassets/Paint/HouseMix-<id>.imageset` (`id` es `HouseMix.rawValue`: `pinkAndRain`, `seaAndWind`, `brownAndFire`, `wall`; el nombre en el catálogo es `Paint/HouseMix-<id>`, `HousePaint.bandName`). Se generan en tiempo de compilación con este script y van al paquete como PNG opacos: la app no pinta nada en tiempo de ejecución. Unos 1,14 MB en total; el tope es 2 MB (`HousePaintTests`).

**Obra propia generada por código.** Cada pieza nace de una paleta por textura, de una pincelada descrita en el lenguaje y de una semilla fija. No se parte de ninguna imagen: nada descargado, nada incrustado, nada calcado, sin referencia a ninguna obra, pintor, museo ni movimiento. El historial del repositorio es la prueba de autoría (`docs/design/color/propiedad-intelectual.md`).

## Cómo se pinta

`PaintGenerator.swift` porta el JavaScript de `camino-contenido.html` (que a su vez copia la pincelada de `paleta.html`) a Swift con CoreGraphics, sin dependencias (ImageIO, del mismo SDK, solo para escribir el PNG):

- **Generador pseudoaleatorio.** El mismo congruencial lineal de las maquetas, `s = s × 1664525 + 1013904223 mod 2³²`, con los sorteos en el mismo orden, para que una semilla pinte la misma composición que la maqueta.
- **Listón.** Curva central con ruido (o campo de flujo en el océano), grosor en huso (cónico en las lenguas de la hoguera) y relleno con gradiente perpendicular de tres paradas donde dos coinciden: tinta clara hasta el 38 %, tinta base después y banda de sombra en el último 12 %. El salto seco es el empaste; no hay desenfoque.
- **Fondo.** La tinta base de la mezcla llevada un 45 % hacia el negro, un grano del 6 % y encima la composición.
- **Mezclas de la casa**, heredan por capa dominante:

| Mezcla | `id` | Semilla | Composición |
|---|---|---|---|
| Rosa y lluvia | `pinkAndRain` | 2101 | campo rosa y encima trazos oblicuos de lluvia a 72° |
| Mar y viento | `seaAndWind` | 2102 | campo de flujo del océano y solo las dos tintas oliva oscuras del viento al 70 % (ningún pigmento cálido sobre el océano) |
| Marrón y hoguera | `brownAndFire` | 2103 | campo marrón y lenguas de hoguera (30 % negras, núcleo central claro, brasa en los bordes) |
| Pared | `wall` | 2104 | campo marrón solo |

Las semillas son las de la maqueta. La maqueta pinta la banda a 64 × 72 (o 92) y aquí mide 288: la semilla es la misma, pero el número de trazos sigue al área, así que la composición es la misma pincelada, no la misma imagen. Cambiarlas cambia la pintura; el resto de motivos (blanco, ventilador, trueno, arroyo, cabina) están portados para las piezas de 1.1 y no se usan todavía.

- **Paleta** (hex, de la más clara a la base; lenguaje §1): rosa `F3D2B8 E8A598 C77B8A 7A4A5E`, marrón `D9A66B B07A4A 7A4E2E 4A3222`, lluvia `B9CDD9 7FA7C9 4A6B8A 2E4A5E`, océano `CFE7E0 3FA7B0 1F6F8B 0F3C56`, viento `E8E0C4 C9C2A8 8FA07A 5F6B55`, hoguera `FFB15C F08A24 D9442B 5A2A14`. Las once paletas están en el fichero. Ninguna tinta pasa a texto ni a glifos.

## Medidas

La fila de la casa en Mezclas mide 72 pt al tamaño Large (`Grid.rowSubtitle`; medido también en una captura del simulador, 216 px a 3x, en español y en inglés: las cuatro recetas caben en una línea), 80 a partir de xL, 92 cuando la receta ocupa dos líneas y unos 260 en AX5. La banda se pinta a 288 pt para que ninguna fila la escale: la hoja la cuelga del borde superior de la fila y la recorta a su altura, siempre a 1:1, y el borde duro del listón no se ablanda a ningún tamaño. La composición se coloca en los 92 pt de arriba (`bandFocus`, la banda de la maqueta): los campos (rosa, mar, marrón) siguen igual hasta abajo y las lenguas de la hoguera, que nacen en la mitad baja de su campo, se colocan y se cuentan dentro de esos 92 pt, así que en una fila de AX5 la hoguera queda arriba y debajo se ve el campo marrón. Ancho 64 pt a sangre por la izquierda; el texto empieza a 20 pt de ella; velo negro del 12 % encima (`HousePaint.veil`).

## Cómo regenerarlo

```
scripts/paint/generate.sh            # las cuatro bandas a 2x y 3x en Assets.xcassets/Paint
scripts/paint/generate.sh --proof    # además, pruebas a tamaño real en .build/shots/paint-bands-*.png
scripts/paint/generate.sh --store    # además, una pieza de página por mezcla (1320 × 2868) en .build/paint-store/
```

Solo necesita Xcode: se compila en `.build/paint/`. Dos ejecuciones seguidas en la misma máquina dan los mismos bytes; el sorteo es determinista (mismo congruencial, mismo orden), pero la rasterización de CoreGraphics y el codificador PNG pueden cambiar entre versiones de macOS o Xcode, así que una regeneración en otra máquina puede dar bytes distintos con la misma pintura. Si el catálogo cambia sin haber tocado el generador, es eso, no un cambio de la obra. Los PNG no se editan a mano: se cambia el generador y se vuelve a ejecutar.

Las pruebas son dos hojas por escala: las cuatro bandas sobre `hoja #1C1C1E` y sobre negro con el velo del 12 %, enteras (288 pt) y recortadas a la fila de 72 pt. Las piezas de tienda no van al paquete: se pintan 2,5 veces más de cerca (`storeZoom`) porque los trazos están medidos en puntos de la maqueta y a página entera, a 1:1, las lenguas se volvían briznas y el campo marrón, grava.

## Lo que mira el test

`SleepNoiseTests/HousePaintTests.swift`: que las cuatro bandas están en el paquete con el nombre de `HousePaint.bandName`, miden 64 × 288 pt a 2x o 3x; que el catálogo lleva las dos escalas y ninguna 1x, con menos de 2 MB en total; y que las constantes de tamaño del generador y de la app coinciden.

## Dónde se enseña

`MixesSheet` pinta la banda en las cuatro filas de la casa cuando `PaintPolicy.showsHousePaint` lo permite (de día, fuera de la página nocturna, sin Aumentar contraste ni Reducir transparencia); la decisión se toma al abrir la hoja y la banda se funde si la regla cambia con la hoja abierta. La captura 7 de `scripts/screenshots.sh` (`-pageState storeMixes`) es esa hoja de día. Las piezas de página de `--store` no se componen en ninguna captura: son para mirar la pintura de cerca.

## Sin verificar

- Un dispositivo físico, a la luz y a oscuras (`docs/lanzamiento/PRUEBAS-EN-DISPOSITIVO.md`, apartado 11).
- Las hebras del viento sobre el mar (60 a 140 pt, desviación 0,12) cruzan la banda de 64 pt de lado a lado y se leen como rayones; son las de la maqueta, juzgada a 402 pt. Propuesta pendiente del sí del dueño: hebras de 30 + R × 40 pt y desviación 0,2, misma semilla y mismas dos tintas oliva al 70 %.
