# SleepNoise · Icono 1.0 · "La regla y la marea"

**17 de noviembre de 2026 · Paquete S-10 · Notas del generador, no una spec. Manda `docs/design/11-ICONO-Y-APP-STORE.md` §2.1 y §3.1; los tokens son de `docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md` §3.1.**

## Qué es

Una línea quieta (la regla, `texto #E8E4DC`) de la que se levanta una ola que sube deprisa y baja despacio (la marea, `índice #F0C020`) sobre `negro #000000`. Lienzo de 1024 px, trazo de 112 px en las dos formas, la regla encima de la marea. Sin letra, sin degradado, sin sombra, sin esquinas propias: la máscara la pone el sistema. La geometría es la del SVG de 11 §2.1, punto por punto.

`SleepNoise/Resources/Assets.xcassets/AppIcon.appiconset` lleva tres PNG de 1024 px, opacos y sin canal alfa:

| Fichero | Apariencia | Contenido |
|---|---|---|
| `AppIcon.png` | Por defecto (la única que lee iOS 17) | Negro, regla en `texto`, marea en `índice` |
| `AppIcon-Dark.png` | Oscura (iOS 18 y posteriores) | Idéntico al anterior, byte a byte: Default = Dark (C32) |
| `AppIcon-Tinted.png` | Tintada (iOS 18 y posteriores) | Regla y marea en un solo gris `#E4E4E4` (la luminancia de `texto`) sobre negro; el tinte lo pone el sistema |

## Estado frente al plan: tres apariencias de cuatro

`docs/PLAN-SIMPLE-1.0.md` (S-10) y 03 §5 fila 27 piden **cuatro apariencias**. Aquí hay tres. La cuarta, Clear, y los pares claro / oscuro de Clear y Tinted se definen en 11 §2.1 y §3.1 sobre un fichero de Icon Composer, que este paquete no lleva. **S-10 no está cerrado** hasta que el dueño elija una de estas dos salidas:

- **(a)** un paquete siguiente monta `AppIcon.icon` con las capas de `generate.sh --layers` y lo mínimo de `project.yml`; o
- **(b)** 1.0 sale con el `appiconset` y se cambia "cuatro apariencias" por "tres" en el plan y en 03.

Para decidir (b) con datos: en iOS 26 el estilo Transparente no deja el icono sin atender. El sistema lo deriva de `AppIcon-Tinted.png`: la forma sale en blanco sobre su vidrio, en claro y en oscuro (capturas `home-clear-*.png`). Lo que no llega nunca son los tokens `tinta` y `ocre` de Clear claro.

## Cómo regenerarlo

```
scripts/icon/generate.sh            # los tres PNG y Contents.json
scripts/icon/generate.sh --proof    # además, pruebas en .build/icon-proof/
scripts/icon/generate.sh --layers   # además, capas para Icon Composer en .build/icon-layers/
```

Solo necesita Xcode: `IconGenerator.swift` dibuja con CoreGraphics y se compila en `.build/icon/`. Dos ejecuciones seguidas dan los mismos bytes. Los PNG no se editan a mano: se cambia el generador y se vuelve a ejecutar. Las constantes de geometría y de color están al principio del fichero.

Las pruebas son una hoja por fondo (`sheet-light.png`, `sheet-dark.png`) con cinco columnas (20, 29, 40, 60 y 120 pt a 3x) y seis filas, de arriba abajo:

1. por defecto;
2. tintada tal cual, un nivel de gris (la que está en el catálogo);
3. tintada a dos niveles, **candidata, no está en el catálogo**: regla `#E4E4E4`, marea `#C6C6C6` (la luminancia de `índice`);
4. la fila 2 con un tinte azul de ejemplo;
5. la fila 3 con el mismo tinte;
6. por defecto en escala de grises.

Además, cada icono suelto, una ampliación sin suavizado de los 20 y los 29 pt a 2x y 3x (`zoom-20pt-*.png`, `zoom-29pt-*.png`) y `master-tinted-two-level.png`, el PNG de 1024 px de la candidata. Las filas 4 y 5 son una multiplicación hecha por el generador, no lo que pinta iOS: para eso están las capturas de abajo. Medido en el PNG exportado: la marea visible ocupa el 5,60 % del lienzo y la regla el 6,84 % (11 §2.1 estimaba ≈ 6 % y 6,8 %).

## Visto en el simulador (iPhone Air, iOS 26.5)

Capturas en `.build/icon-proof/` con prefijo `home-` (no se versionan). Se tomaron con la pantalla de inicio en cada estilo de "Personalizar"; en ellas aparece también una app de prueba, "Two levels", que lleva la candidata de dos niveles como imagen tintada.

- **Por defecto y Oscuro** (`home-default.png`, `home-dark-icons.png`): el mismo dibujo en los dos. En Por defecto iOS 26 añade un filo de luz en el canto de la regla y de la marea y aclara un punto los colores (regla medida `#ECE8E1`, filo `#FFF0DE`); en Oscuro la regla sale casi en el token (`#E9E4DC`). Las hojas son planas y no simulan ese relieve.
- **Tintado claro y oscuro**, con el tinte del fondo de pantalla (azul) y con uno cálido (`home-tinted-*.png`): el sistema cambia el negro por su propio fondo teñido y pinta la forma en blanco (claro) o en el tinte (oscuro). La forma aguanta, pero con un solo gris regla y marea se funden en una silueta cerrada: un arco sobre una base, con un hueco triangular.
- **Transparente claro y oscuro** (`home-clear-light.png`, `home-clear-dark.png`): la misma silueta en blanco sobre vidrio.
- **29 pt y 20 pt reales** (`home-settings-29pt.png`, `home-spotlight.png`, ampliados en `home-zoom-small-sizes.png`): en Ajustes › Apps y en las filas de acciones de Spotlight se lee una línea con una ola; el filo del sistema no emborrona el trazo.
- **Un nivel frente a dos** (`home-zoom-styles.png`: arriba el icono actual, abajo la candidata; columnas Por defecto, Tintado claro, Tintado oscuro, Transparente claro, Transparente oscuro): iOS 26 conserva los niveles de gris, así que con dos la regla sigue siendo una línea continua y la marea se apoya en ella, algo más apagada. La diferencia es discreta a 60 pt.

## Qué decide aún el dueño

1. **La cresta: 576 o 563.** Está construida en 576 (retícula de 64), la recomendación de 11 §9.1. El 4:6 literal son dos números en el generador: cresta en x 563 y control de bajada en x 723.
2. **El acento.** La marea va en Índice `#F0C020`, la recomendación de la reconciliación §6 #1 (cierre el 27-11-2026). Otro matiz es un hex en `Token.indice`.
3. **Clear y el fichero de Icon Composer**: la salida (a) o (b) de arriba (11 §9.11).
4. **El gris del tintado: un nivel o dos.** Un nivel es la letra de 11 ("una sola capa monocroma") y lo que hay en el catálogo; `#E4E4E4` es decisión de este paquete. Dos niveles devuelven la lectura "una línea de la que se levanta algo" en Tintado y en Transparente. Si gana, es una línea en la paleta `tinted` del generador y una nota en 11 §2.1.
5. **La hoja junto a los diez iconos de la categoría** y la prueba de cinco segundos con diez personas (11 §2.1): necesitan capturas en dispositivo. 11 manda repetir la prueba con la cresta en 563 si alguien dice "electrocardiograma" o "gráfica". Propuesta de la revisión de este paquete, a aprobar: tratar igual las respuestas "amanecer" o "sol" (a 29-40 pt un arco amarillo sobre una horizontal clara se parece a ese pictograma) y "sombrero" o "campana" (a 120 pt la regla es una losa y el conjunto puede leerse como un objeto sobre una repisa), y hacer la prueba también a 29 pt. El orden de corrección sería el de 11: primero la cresta en 563, después el acento, el grosor lo último.

## Sin verificar

- iOS 17 y iOS 18 reales: solo se ha visto iOS 26. Que las tres apariencias están compiladas en el catálogo sí está comprobado.
- Un dispositivo físico y la ficha de App Store.
- Las opciones "Auto" de cada estilo, los iconos grandes, las carpetas de la pantalla de inicio y el Centro de control.
- El relieve que iOS 26 añade al icono plano solo está juzgado en las capturas del simulador de arriba, no en las hojas ni en pantalla real.
- Nada de Icon Composer: ni el fichero ni cómo aplana Xcode las capas (11 §9.11).
