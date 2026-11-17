# SleepNoise · Capturas de la App Store

**Paquete S-08 · Notas del generador, no una spec. Manda `docs/design/11-ICONO-Y-APP-STORE.md` §2.2 a §2.8 y §3.2; los titulares son los de `docs/store/ficha-es.md` y `ficha-en.md` (C57).**

## Qué hace

```
scripts/screenshots.sh              # compila, captura y compone ES y EN
scripts/screenshots.sh --no-build   # reutiliza la app ya compilada
scripts/screenshots.sh es           # un solo idioma
```

Compila la app de depuración, la instala en el simulador de 6,9 pulgadas (`SN_SHOT_SIM`, por defecto "iPhone 17 Pro Max"), fija la barra de estado (9:41, batería llena, sin operador) y lanza cada pantalla con su estado de depuración, `-storeShot`, `-silentOutput` y el idioma. Deja en `.build/store-shots/<idioma>/`:

- `NN-nombre.png`: la captura para subir, 1320 × 2868 px, con el titular compuesto sobre negro;
- `raw/NN-nombre.png`: la pantalla sola, también 1320 × 2868 px.

Nada se versiona ni se sube. Termina con `SHOTS OK · 12 captures` o `SHOTS FAIL · motivo`; el log está en `.build/screenshots.log`.

| Captura | Estado (`-pageState`) | Qué enseña |
|---|---|---|
| 01-page-playing | `storePlaying` | "Rosa y lluvia" sonando a las 20:15, segundo día de la prueba, se funde a las 21:00 |
| 02-first-use | `restFree` | Instalación nueva tal cual: sin prueba, en silencio, la Marea dice "pro" |
| 03-layers | `storeLayers` | Capas con seis sonando (la prueba abre el océano) y la lluvia bajo el dedo |
| 04-tide | `storeTide` | Marea guiando a seis por minuto, detenida al 70 % de la subida de la tercera respiración |
| 05-night | `storeNight` | Noche a las 3:07, se funde a las 3:42 |
| 06-not-here | `settingsNotHere` | La página "Lo que no hay" |

## El lienzo

`ShotComposer.swift` dibuja con CoreGraphics y CoreText el lienzo de 11 §2.2: 440 × 956 pt a 3×, fondo `negro`, titular en el paso 2 (SF Pro Display Medium 28/34, `texto`, x 32, primera línea base en y 100, una o dos líneas), segunda línea en el paso 6 (17/22, `texto2`, caja y 152-174, solo capturas 1 y 3) y la pantalla a 336 pt de ancho en x 52, y 196, sin radio ni contorno. Lee los titulares de las fichas: bajo cada "### Captura N", el primer bloque es el titular y el bloque que sigue a "Subtítulo de la captura:" es la segunda línea. Si el dueño pasa a los textos de reserva, se cambia el orden de los bloques en la ficha y se vuelve a ejecutar.

El salto de un titular de dos líneas va tras un punto, o tras una coma, o donde las dos líneas quedan más parejas sin dejar colgada una palabra de tres letras o menos. Un titular de tres líneas o una segunda línea más ancha que 376 pt paran el script.

## Diferencias con el documento 11, a propósito

- **La pantalla es la del simulador de 6,9 pulgadas (440 × 956 pt) a 0,764**, no la de 393 × 852 a 0,855: así la pantalla sola ya tiene el tamaño que pide App Store Connect. Su alto son 730 pt y el margen inferior 30, no 32. El texto de dentro sale un 10 % más pequeño que en la maqueta.
- **Las horas son de tarde, no de noche.** 11 §3.2 fija las 23:57 para la captura 1, pero a esa hora la página no dice nada de la prueba (`NightWindow`, AGENTS §5.1). Las capturas 1, 3 y 4 van a las 20:15 y 20:12.
- **La captura 2 es una instalación nueva de verdad**: la mezcla es "Rosa y lluvia" (lo que carga el primer uso) y la fila de la Marea dice "Apagada · pro". 11 §2.4 la dibujaba con "Esta noche" y sin "pro".
- **La captura 4 no lleva la frase sobre estudios ni "Qué sabemos"**: la hoja de 1.0 no las tiene (`docs/store/README.md`).
- **La captura 6 es la página tal como se construyó** (lista en el paso de lectura, dentro de la hoja de Ajustes, con el botón de volver del sistema), sin el pie "No se recopilan datos · {MB} MB" de 11 §2.8.
- **El indicador de inicio se repinta.** La captura pide ocultarlo (`-storeShot`) y el simulador lo deja atenuado. El compositor cubre esa franja del área segura, donde la app solo pinta su fondo, con la columna de píxeles de su izquierda. La pantalla sola de `raw/` queda como salió; `--keep-home-indicator` lo conserva también en la compuesta.
- **El Horizonte de la captura 1 es el RMS real** del motor en el instante de la captura: su grosor varía un poco entre ejecuciones. Todo lo demás se repite igual.

## Sin verificar

- La ficha real en App Store Connect y la miniatura a tamaño de teléfono.
- es-419: la app solo lleva `es`; ese juego sería el mismo.
