# Ficha de App Store · español (España)

Localización "Spanish (Spain)" de la versión 1.0 en App Store Connect. Cada bloque es el texto para pegar tal cual; el recuento, hecho con un script, va debajo. Los límites son los de App Store Connect, salvo los de las capturas, que son los de la maqueta (`docs/design/11-ICONO-Y-APP-STORE.md` §5.e).

Los textos salen de `docs/design/10-GUIA-DE-COPY.md` §5e.15 y de `docs/design/11-ICONO-Y-APP-STORE.md` §5.e. Donde se apartan de ellos, lo dice la nota del campo. Las funciones que describen ya están en el código de 1.0. Las frases que todavía dependen de un cambio de audio o de algo que el dueño tiene que dar o decidir están en `README.md` de esta carpeta, "Antes de enviar": hay que repasar esa lista antes de enviar.

## Nombre

```text es
SleepNoise
```

Recuento: 10 de 30. Provisional: el nombre se confirma el 04-12-2026 (`docs/PLAN-SIMPLE-1.0.md` §4.2).

## Subtítulo

```text es
Sonidos para dormir
```

Recuento: 19 de 30. No dice lo mismo que el subtítulo inglés, que añade una condición de precio; el riesgo y el texto de reserva están en `ficha-en.md`. Este no cambia.

## Texto promocional

```text es
Sonido que nunca se repite, fabricado en tu iPhone. Siete noches con todo, sin tarjeta. Un solo pago.
```

Recuento: 101 de 170.

"Nunca se repite" es una afirmación de hecho que el código no sostiene todavía (`README.md`, "Antes de enviar"). Si el cambio de audio y su test no llegan, o si el dueño lo prefiere, este es el texto de reserva, que solo dice lo que ya se puede comprobar:

```text es
Sin archivos de audio ni bucles: el sonido se fabrica en tu iPhone mientras suena. Siete noches con todo, sin tarjeta. Un solo pago.
```

Recuento: 132 de 170.

## Palabras clave

Separadas por comas, sin espacio tras la coma y sin tildes. No repiten ninguna palabra del nombre ni del subtítulo (ni "sonidos" ni "dormir").

Opción A, la de `11-ICONO-Y-APP-STORE.md` §5.e:

```text es keywords
ruido blanco,marron,rosa,lluvia,viento,mar,ventilador,respiracion,sin suscripcion,insomnio,acufenos
```

Recuento: 99 de 100. Lleva dos palabras de diagnóstico, las dos últimas.

Opción B, sin esas palabras:

```text es keywords
ruido blanco,marron,rosa,lluvia,viento,mar,ventilador,respiracion,sin suscripcion,olas,trueno,arroyo
```

Recuento: 100 de 100.

Elige el dueño. **Si no dice nada, vale la B.** La A es la que fija el documento 11, pero las fuentes se contradicen y hasta que el dueño lo resuelva vale la lectura más estricta: `AGENTS.md` §5.4 veta la primera de esas palabras sin excepción; la guía de copy §0.4 reserva el nombre del diagnóstico a las notas de revisión y su §5e.15 lo admite en este campo; el informe §5.2 y el documento 11 §2.10 lo admiten solo aquí. El campo no se enseña en la tienda, pero el revisor sí lo ve, y las notas de revisión le dicen "The app makes no health claims". La B nombra texturas de Pro que dependen de la escucha del dueño (`README.md`, "Antes de enviar").

## Descripción

```text es
SleepNoise fabrica en tu iPhone, mientras suena, un ruido que no se repite jamás: ruido blanco, rosa y marrón, lluvia, viento, océano y las demás texturas, mezcladas a tu gusto bajo un dedo. Todas las texturas, una línea cada una.

La Marea acompasa el mar a seis respiraciones por minuto y se retira sola. El temporizador se funde en vez de cortar y nunca toca tu alarma. A las tres de la mañana, la pantalla entera es el botón.

Siete noches con todo, sin tarjeta. Después, Pro es un solo pago; blanco, rosa, marrón, lluvia, viento, todo el temporizador y tres mezclas siguen gratis.

Sin suscripción. Sin cuenta. Sin rastreo.

Un solo pago.

Un toque y suena.

Seis capas a la vez. Una línea cada una.

El mar respira a seis por minuto.

A las tres de la mañana, nada.

Lo que no hay.

Lo que suena, se pinta.
```

Recuento: 812 de 4000. Los cuatro primeros párrafos son los de la guía; los siete últimos son los titulares de las capturas, en orden, porque VoiceOver no lee las capturas (documento 11 §2.10); el séptimo es el de la captura nueva de la exploración 12 (19-11-2026). Un cambio respecto a la guía: "acompasa el mar" en lugar de la palabra que la lista de palabras vetadas (§0.5) reserva a la línea de uso del océano.

Dos enmiendas propuestas, que no se aplican sin el sí del dueño porque el texto por defecto es el de la guía, letra a letra.

Primera frase de reserva, por el mismo motivo que la del texto promocional (sustituye a la que va hasta los dos puntos y quita "jamás", que afirma más que el inglés):

```text es
SleepNoise fabrica el sonido en tu iPhone, mientras suena, sin archivos de audio ni bucles:
```

Recuento: 91. Con ella la descripción pasa de 812 a 822.

Tercer párrafo, para la directriz 2.3.2. La descripción presenta la Marea y las capturas 3 y 4 enseñan funciones de Pro sin decir que lo son; hoy solo se deduce de la lista de lo gratis. Enmienda propuesta, también en la guía §5e.15:

```text es
Siete noches con todo, sin tarjeta. Después, Pro, que añade las demás texturas, la Marea y mezclas sin límite, es un solo pago; blanco, rosa, marrón, lluvia, viento, todo el temporizador y tres mezclas siguen gratis.
```

Recuento: 216. Con ella la descripción pasa de 812 a 874; con las dos enmiendas, a 884.

## Novedades de la 1.0

```text es
SleepNoise: una página negra, una línea que respira con el sonido real y una pantalla de Noche que es toda ella el botón.
Mezclas con nombre, cuatro de la casa. Un temporizador que se funde en vez de cortar. Madrugada: veinte minutos de mar que se retira solo.
Siete noches con todo. Después, Pro es un solo pago. Lo gratis sigue gratis.
Si algo no suena, Ajustes › Escribir al autor. Nos gustaría saberlo.
```

Recuento: 406 de 4000. App Store Connect no pide este campo en la primera versión de una app (a comprobar al crear la ficha); el texto queda listo para la nota de TestFlight y como base de la 1.0.1. Tres cambios respecto a la plantilla de la guía, para no prometer lo que `docs/PLAN-SIMPLE-1.0.md` §4.3 y §4.4 dejan fuera: no dice que la app esté rediseñada, porque es la primera versión en la tienda; Madrugada no se anuncia desde la pantalla de bloqueo del iPhone, porque no hay widgets ni Live Activity; y el aviso de fallos lleva a "Escribir al autor", porque el Diagnóstico pasa a 1.1. Esa fila de Ajustes solo aparece cuando el dueño da una dirección pública (`AppLinks.authorAddress`, hoy vacía): si la 1.0 sale sin ella, la última línea de este texto se quita.

## Capturas

Siete, en este orden, solo iPhone: las seis de C57 sobre fondo negro y, la última, la de Mezclas de día con las bandas pintadas de la casa (exploración 12 §6.1, aprobada el 19-11-2026; su lienzo sigue siendo negro y el color es el de la pantalla). Sin vídeo de vista previa en 1.0. Las genera `scripts/screenshots.sh` (S-08), que lee de este fichero el titular (el primer bloque de cada captura) y su segunda línea (el bloque que sigue a "Subtítulo de la captura:"). Cada nota "Pantalla:" dice lo que sale en la captura generada (`scripts/screenshots/README.md`), no lo que dibujaba la maqueta.

### Captura 1 · la página sonando

```text es
Un solo pago.
```

Recuento: 13 de 41. Pantalla: mezcla de la casa "Rosa y lluvia" cargada (Lluvia 55 · Rosa 20), sonando a las 20:15, con "prueba · quedan 6 noches" en la cabecera y el estado "Sonando · se funde a las 21:00".

Riesgo anotado: la directriz 2.3.7 pide que nombre, subtítulo y capturas no lleven precios ni condiciones. Este titular y "sin tarjeta" en su subtítulo son condiciones de pago; los fija C57 y no se cambian sin el sí del dueño. Reserva lista si App Review lo discute o el dueño lo prefiere, titular y subtítulo:

```text es
Fabricado en tu iPhone.
```

Recuento: 23 de 41.

```text es
Siete noches con todo.
```

Recuento: 22 de 42. Si se usa la reserva, cambia también el quinto párrafo de la descripción, que repite este titular.

Subtítulo de la captura:

```text es
Siete noches con todo, sin tarjeta.
```

Recuento: 35 de 42.

### Captura 2 · el primer uso, en reposo

```text es
Un toque y suena.
```

Recuento: 17 de 41. Pantalla: la página de quien no ha comprado nada ni ha empezado la prueba, en reposo: mezcla "Esta noche" (Lluvia 30 · Rosa 50, la del documento 11 §2.4), en silencio, cabecera vacía, el Disco en Play y la fila de la Marea con "Apagada · pro". No es la primera apertura al pie de la letra, que carga "Rosa y lluvia": con ella las capturas 1 y 2 enseñaban la misma página.

### Captura 3 · la hoja Capas bajo el dedo

```text es
Seis capas a la vez. Una línea cada una.
```

Recuento: 40 de 41. Pantalla: la hoja "Capas" con seis capas sonando (blanco, rosa, marrón, lluvia, viento y océano) y la fila de la lluvia bajo el dedo, a 52. Seis capas a la vez no se pueden tener con las cinco texturas gratuitas: la captura se hace con la prueba en marcha (documento 11 §12) y enseña algo que después es de Pro. La directriz 2.3.2 pide que descripción y capturas dejen claro qué requiere compra; ver la nota de la descripción.

Subtítulo de la captura:

```text es
Arrastra sobre el nombre para cambiar el nivel.
```

Recuento: 47 de 42. Supera el tope de caracteres de la maqueta, pero cabe: mide 355 pt de los 376 de la columna a 17 pt (`shot-composer --list`), así que no hace falta variante corta.

### Captura 4 · Marea guiando

```text es
El mar respira a seis por minuto.
```

Recuento: 33 de 41. Pantalla: la hoja de Marea con la línea de agua detenida en la subida de la tercera respiración, "guiando · 6 por minuto", "Se retira a las 20:27" y las filas Marea, Ritmo, Descenso y "Se retira a los". La Marea es de Pro: vale lo dicho en la captura 3. La captura se hace sin la frase sobre estudios de variabilidad cardiaca (`marea.evidencia`) y sin el enlace "Qué sabemos" que el documento 11 §2.6 dibuja en esa hoja: "Qué sabemos" pasa a 1.1 (`docs/PLAN-SIMPLE-1.0.md` §4.4) y esa frase, dentro de una captura, sería una afirmación fisiológica en la ficha. La hoja de 1.0 no las lleva.

### Captura 5 · Noche sola

```text es
A las tres de la mañana, nada.
```

Recuento: 30 de 41. Pantalla: la pantalla Noche, negra: el Horizonte, la hora (3:07), el estado "Se funde a las 3:42" y "+15 min" al pie. Nada más.

### Captura 6 · la página "Lo que no hay"

```text es
Lo que no hay.
```

Recuento: 14 de 41. Pantalla: la página real de la app, dentro de la hoja de Ajustes: el título, la lista de ausencias (una por línea) y "No te pediremos que la valores." No lleva pie: la página construida no lo tiene (repetiría sus tres primeras líneas) y la app no muestra su peso.

Lista que se ve en la captura (es la de la página, no un campo de la tienda):

```text es
Sin suscripción · Sin cuenta · Sin rastreo · Sin anuncios · Sin puntuación · Sin racha · Sin tutorial
```

### Captura 7 · Mezclas de día, con las bandas de la casa

```text es
Lo que suena, se pinta.
```

Recuento: 23 de 41. Titular común de la exploración 12 (§5 y §6.1; `docs/design/color/camino-contenido.md`), el mismo en los tres caminos. Pantalla: la hoja Mezclas de día, a las 20:15 del segundo día de la prueba: "Tuyas" con dos mezclas guardadas y "De la casa" con las cuatro mezclas, cada una con su banda pintada a sangre por la izquierda (`HousePaint`), y "Rosa y lluvia" sonando. La pintura es la de la app, generada por código en tiempo de compilación (`scripts/paint/`), sin imágenes ajenas; de noche y en la página nocturna la hoja no la enseña (`PaintPolicy`). Va la última porque la exploración no sustituye ninguna de las seis de C57: si el dueño prefiere que entre en los resultados de búsqueda, se cambia el orden en `scripts/screenshots.sh` y aquí.

Sin segunda línea. Texto de reserva, por si el dueño añade una captura de la página de día pintada (`-pageState windowPinkRainTide`), que es la pantalla que lo sostiene:

```text es
Se genera aquí, como el sonido. Sin archivos.
```

Recuento: 45 de 42 (manda `shot-composer --list`; la segunda línea de la captura 3 mide 355 pt con 47 caracteres). Es el texto de reserva de la exploración 12 §5, acortado para la columna de 376 pt. No va bajo esta captura: las bandas de Mezclas que enseña son PNG generados en compilación por el mismo pincel (`scripts/paint/`), y la ficha solo afirma lo que el código hace en la pantalla que enseña (C04). La ventana de la página sí se genera en el iPhone en tiempo de ejecución (`PaintRasterizer`): si el dueño quiere la línea, es con esa captura, como séptima u octava.

## Si se abre también "Spanish (Mexico)"

Todo igual salvo cuatro cambios (guía de copy §0.3): "generado" por "fabricado" en el texto promocional, "genera" por "fabrica" en la descripción, y "respirar" por "respiracion" en las palabras clave. En los textos de reserva el cambio es el mismo: "se genera", "genera" y "Generado". La app solo lleva una localización `es`, así que esa ficha enseñaría la misma interfaz.
