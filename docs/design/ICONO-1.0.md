# SleepNoise · Icono 1.0 · "La regla y la marea"

**17 de noviembre de 2026 · Paquete S-10 · Fuente: `11-ICONO-Y-APP-STORE.md` §2.1 y §3.1; tokens de `03-DIRECCION-DE-DISENO-2026-11-16.md` §3.1.**

## Qué es

Una línea quieta (la regla, `texto #E8E4DC`) de la que se levanta una ola que sube deprisa y baja despacio (la marea, `índice #F0C020`) sobre `negro #000000`. Lienzo de 1024 px, trazo de 112 px en las dos formas, la regla encima de la marea. Sin letra, sin degradado, sin sombra, sin esquinas propias: la máscara la pone el sistema. La geometría es la del SVG de 11 §2.1, punto por punto.

`SleepNoise/Resources/Assets.xcassets/AppIcon.appiconset` lleva tres PNG de 1024 px, opacos y sin canal alfa:

| Fichero | Apariencia | Contenido |
|---|---|---|
| `AppIcon.png` | Por defecto (la única que lee iOS 17) | Negro, regla en `texto`, marea en `índice` |
| `AppIcon-Dark.png` | Oscura (iOS 18 y posteriores) | Idéntico al anterior, byte a byte: Default = Dark (C32) |
| `AppIcon-Tinted.png` | Tintada (iOS 18 y posteriores) | Regla y marea en un solo gris `#E4E4E4` (la luminancia de `texto`) sobre negro; el tinte lo pone el sistema |

La cuarta apariencia de 11, Clear, es de Icon Composer (iOS 26) y no cabe en un `appiconset`: no entra en este paquete. Con `--layers` el generador deja las capas transparentes que haría falta llevar a Icon Composer.

## Cómo regenerarlo

```
scripts/icon/generate.sh            # los tres PNG y Contents.json
scripts/icon/generate.sh --proof    # además, pruebas en .build/icon-proof/
scripts/icon/generate.sh --layers   # además, capas para Icon Composer en .build/icon-layers/
```

Solo necesita Xcode: `scripts/icon/IconGenerator.swift` dibuja con CoreGraphics y se compila en `.build/icon/`. Dos ejecuciones seguidas dan los mismos bytes. Los PNG no se editan a mano: se cambia el generador y se vuelve a ejecutar. Las constantes de geometría y de color están al principio del fichero.

Las pruebas son una hoja por fondo (`sheet-light.png`, `sheet-dark.png`) con cuatro filas (por defecto, tintada tal cual, tintada con un tinte azul de ejemplo, escala de grises) y cuatro columnas (29, 40, 60 y 120 pt a 3x), más cada icono suelto y una ampliación sin suavizado de los 29 pt (`zoom-29pt-*.png`). Medido en el PNG exportado: la marea visible ocupa el 5,60 % del lienzo y la regla el 6,84 % (11 §2.1 estimaba ≈ 6 % y 6,8 %).

## Qué decide aún el dueño

1. **La cresta: 576 o 563.** Está construida en 576 (retícula de 64), la recomendación de 11 §9.1. El 4:6 literal son dos números en el generador: cresta en x 563 y control de bajada en x 723.
2. **El acento.** La marea va en Índice `#F0C020`, la recomendación de la reconciliación §6 #1 (cierre el 27-11-2026). Otro matiz es un hex en `Token.indice`.
3. **La hoja junto a los diez iconos de la categoría** y la prueba de cinco segundos con diez personas (11 §2.1): necesitan capturas en dispositivo. A tamaño pequeño y en tintado la forma puede leerse como un arco sobre una base; si alguien dice "gráfica", 11 manda repetir con la cresta en 563 antes de tocar el grosor.
4. **Clear y el fichero de Icon Composer** para iOS 26 (11 §9.11): si se quiere el vidrio con `tinta` y `ocre` en Clear claro, es un paquete aparte.
5. **El gris del tintado.** `#E4E4E4` es decisión de este paquete (11 solo dice "una capa monocroma"); un gris más claro da un tinte más intenso.

## Sin verificar

Visto en el simulador (iOS 26): el icono por defecto en la pantalla de inicio, con el sistema en claro y en oscuro. No visto: la pantalla de inicio en estilo de iconos Oscuro y Tintado (hay que elegirlo a mano en "Personalizar"), iOS 17 y 18 reales, un dispositivo físico y la ficha de App Store. Que las tres apariencias están compiladas en el catálogo sí está comprobado.
