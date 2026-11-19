# SleepNoise · Capturas de la App Store

**Paquete S-08 · Notas del generador, no una spec. Manda `docs/design/11-ICONO-Y-APP-STORE.md` §2.2 a §2.8 y §3.2; los titulares son los de `docs/store/ficha-es.md` y `ficha-en.md` (C57).**

## Qué hace

```
scripts/screenshots.sh              # compila, captura y compone ES y EN
scripts/screenshots.sh --no-build   # reutiliza la app ya compilada
scripts/screenshots.sh es           # un solo idioma
```

Crea un simulador propio para la ejecución (`SN_SHOT_DEVICE`, por defecto el tipo "iPhone 17 Pro", el de 11 §4.4), compila la app de depuración, la instala en él, fija la barra de estado (9:41, batería llena, sin operador) y lanza cada pantalla con su estado de depuración, `-storeShot`, `-silentOutput` y el idioma. Deja en `.build/store-shots/<idioma>/`:

- `NN-nombre.png`: la captura para subir, 1320 × 2868 px (la clase de 6,9 pulgadas que pide App Store Connect), con el titular compuesto sobre negro;
- `raw/NN-nombre.png`: la pantalla sola, al tamaño del simulador (1206 × 2622 px en un iPhone 17 Pro). No se sube.

**El simulador es del script.** Lo crea al empezar (`xcrun simctl create`) y lo borra al terminar, también si falla, si se interrumpe con Ctrl-C o si lo matan (`trap cleanup EXIT`). Así no hereda ajustes de otro simulador (Aumentar contraste, Negrita, 24 horas), no depende de que exista uno con cierto nombre y no toca ninguno que alguien esté usando: antes instalaba encima de la app de un simulador compartido, la terminaba y le fijaba y limpiaba la barra de estado. Para usar uno que ya existe hay que decirlo con `SN_SHOT_UDID`: entonces no se crea ni se borra nada, se instala la app sobre la que tenga y al acabar se limpia su barra de estado.

**Cada pantalla se toma dos veces.** Un simulador recién creado enseña avisos del sistema encima de lo que haya ("Ready for Apple Intelligence" salió sobre la captura 2). Las dos tomas van separadas ocho segundos, más de lo que dura un aviso, y el compositor compara su sexto superior (`shot-composer --same-top`), donde nada de la app se mueve en estos siete estados. Si no coinciden, el script espera y repite, hasta tres veces. Aun así, las catorce se miran antes de subirlas.

Nada se versiona ni se sube. Termina con `SHOTS OK · 14 captures` o `SHOTS FAIL · motivo`; el log está en `.build/screenshots.log`.

| Captura | Estado (`-pageState`) | Qué enseña |
|---|---|---|
| 01-page-playing | `storePlaying` | "Rosa y lluvia" sonando a las 20:15, segundo día de la prueba, se funde a las 21:00 |
| 02-first-use | `storeFirstUse` | Sin compra ni prueba, en silencio: "Esta noche" con Lluvia 30 · Rosa 50 (11 §2.4) y la Marea con "Apagada · pro" |
| 03-layers | `storeLayers` | Capas con seis sonando (la prueba abre el océano) y la lluvia bajo el dedo |
| 04-tide | `storeTide` | Marea guiando a seis por minuto, detenida al 70 % de la subida de la tercera respiración |
| 05-night | `storeNight` | Noche a las 3:07, se funde a las 3:42 |
| 06-not-here | `settingsNotHere` | La página "Lo que no hay" |
| 07-mixes | `storeMixes` | Mezclas de día a las 20:15, segundo día de la prueba: dos mezclas propias y las cuatro de la casa con su banda pintada (`HousePaint`, exploración 12 §6.1), "Rosa y lluvia" sonando. Titular común de la exploración, con segunda línea |

## El lienzo

`ShotComposer.swift` dibuja con CoreGraphics y CoreText el lienzo de 11 §2.2: 440 × 956 pt a 3×, fondo `negro`, titular en el paso 2 (SF Pro Display Medium 28/34, `texto`, x 32, primera línea base en y 100, una o dos líneas), segunda línea en el paso 6 (17/22, `texto2`, caja y 152-174, solo capturas 1, 3 y 7) y la pantalla a 336 pt de ancho en x 52, y 196, sin radio ni contorno. El 3× lo lleva el contexto y las fuentes se crean a 28 y 17 pt, como en la app: una fuente creada a 84 o 51 pt lleva el corte óptico y el tracking de ese tamaño y sale más estrecha (un 3 % el titular y un 7 % la segunda línea). La segunda línea más larga, "Arrastra sobre el nombre para cambiar el nivel.", mide 355 pt de 376 (`shot-composer --ficha docs/store/ficha-es.md --list`). Lee los titulares de las fichas: bajo cada "### Captura N", el primer bloque es el titular y el bloque que sigue a "Subtítulo de la captura:" es la segunda línea. Si el dueño pasa a los textos de reserva, se cambia el orden de los bloques en la ficha y se vuelve a ejecutar.

El salto de un titular de dos líneas va tras un punto, o tras una coma, o donde las dos líneas quedan más parejas sin dejar colgada una palabra de tres letras o menos. Un titular de tres líneas o una segunda línea más ancha que 376 pt paran el script.

## Diferencias con el documento 11, a propósito

- **La pantalla es la de un iPhone 17 Pro (402 × 874 pt) a 0,836**, no la de 393 × 852 a 0,855: 11 §4.4 pide el simulador de iPhone 17 Pro, y ese mide 402 pt de ancho. Su alto son 731 pt y el margen inferior 29, no 32. El texto de 13 pt de la app queda en 10,9 pt del lienzo (32,6 px), un 2 % por debajo de los 33 px de 11 §2.2. La primera versión capturaba en el de 6,9 pulgadas a 0,764 (29,8 px) solo para que la pantalla sola midiera 1320 × 2868, y esa no se sube. `SN_SHOT_DEVICE="iPhone 17 Pro Max"` la recupera.
- **Las horas son de tarde, no de noche.** 11 §3.2 fija las 23:57 para la captura 1, pero a esa hora la página no dice nada de la prueba (`NightWindow`, AGENTS §5.1). Las capturas 1, 3 y 4 van a las 20:15 y 20:12.
- **La captura 2 lleva "Esta noche" con Lluvia 30 · Rosa 50, como 11 §2.4, y además "Apagada · pro"** en la fila de la Marea, porque es la página de quien no ha comprado ni empezado la prueba. La primera apertura de verdad carga "Rosa y lluvia" (Lluvia 55 · Rosa 20), que es justo lo que suena en la captura 1: con ella las dos primeras capturas, las que salen en los resultados de búsqueda, eran casi la misma imagen (menos de un 1 % de píxeles distintos).
- **La captura 4 no lleva la frase sobre estudios ni "Qué sabemos"**: la hoja de 1.0 no las tiene (`docs/store/README.md`).
- **La captura 6 es la página tal como se construyó** (lista en el paso de lectura, dentro de la hoja de Ajustes, con el botón de volver del sistema), sin el pie "No se recopilan datos · {MB} MB" de 11 §2.8.
- **El indicador de inicio se repinta.** La captura pide ocultarlo (`-storeShot`) y el simulador lo deja atenuado. El compositor cubre esa franja del área segura, donde la app solo pinta su fondo, con la columna de píxeles de su izquierda. La pantalla sola de `raw/` queda como salió; `--keep-home-indicator` lo conserva también en la compuesta.
- **El Horizonte de la captura 1 es el RMS real** del motor en el instante de la captura: su grosor varía un poco entre ejecuciones. Todo lo demás se repite igual.

## Sin verificar

- La ficha real en App Store Connect y la miniatura a tamaño de teléfono.
- es-419: la app solo lleva `es`; ese juego sería el mismo.
