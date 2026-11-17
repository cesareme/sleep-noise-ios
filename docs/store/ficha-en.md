# Ficha de App Store · inglés (EE. UU.)

Localización "English (U.S.)" de la versión 1.0 en App Store Connect. Es el idioma principal de la ficha (`developmentLanguage: en` en `project.yml`). Cada bloque es el texto para pegar tal cual; el recuento, hecho con un script, va debajo. Los límites son los de App Store Connect, salvo los de las capturas, que son los de la maqueta (`docs/design/11-ICONO-Y-APP-STORE.md` §5.e).

Los textos salen de `docs/design/10-GUIA-DE-COPY.md` §5e.15 y de `docs/design/11-ICONO-Y-APP-STORE.md` §5.e. Donde se apartan de ellos, lo dice la nota del campo. Varias frases describen funciones de 1.0 que todavía no están en `main`: la lista está en `README.md` de esta carpeta y hay que repasarla antes de enviar.

## Nombre

```text en
SleepNoise
```

Recuento: 10 de 30. Provisional: el nombre se confirma el 04-12-2026 (`docs/PLAN-SIMPLE-1.0.md` §4.2).

## Subtítulo

```text en
Sleep sounds. Pay once.
```

Recuento: 23 de 30.

Riesgo anotado: "Pay once." es una condición de precio dentro de un subtítulo, y la directriz 2.3.7 pide que nombre, subtítulo y capturas no lleven precios ni condiciones. Además no dice lo mismo que el subtítulo español. Lo fija la guía §5e.15 y no se cambia sin el sí del dueño. Reserva lista, igual que el español:

```text en
Sleep sounds
```

Recuento: 12 de 30. Con la reserva, "pay" y "once" dejan de estar en el subtítulo y podrían entrar en las palabras clave.

## Texto promocional

```text en
Sleep sound that never loops, made on your iPhone. Seven nights with everything, no card. One payment.
```

Recuento: 102 de 170.

"Never loops" es una afirmación de hecho que `main` no sostiene todavía (`README.md`, "Antes de enviar"). Si el cambio de audio y su test no llegan, o si el dueño lo prefiere, este es el texto de reserva, que solo dice lo que ya se puede comprobar:

```text en
No audio files, no loops: the sound is made on your iPhone as it plays. Seven nights with everything, no card. One payment.
```

Recuento: 123 de 170.

## Palabras clave

Separadas por comas, sin espacio tras la coma y sin tildes. No repiten ninguna palabra del nombre ni del subtítulo (ni "sleep", "sounds", "pay" ni "once").

Opción A, la de `11-ICONO-Y-APP-STORE.md` §5.e:

```text en keywords
brown noise,white,pink,rain,wind,ocean,fan,breathing,generative,insomnia,tinnitus,snoring,loop
```

Recuento: 94 de 100. Lleva tres palabras de salud: dos de diagnóstico (`insomnia` y `tinnitus`) y `snoring`, que el documento 11 añade en inglés y ninguna fuente declara.

Opción B, sin esas palabras:

```text en keywords
brown noise,white,pink,rain,wind,ocean,fan,breathing,generative,loop,thunder,campfire,brook,timer
```

Recuento: 97 de 100.

Elige el dueño. **Si no dice nada, vale la B.** La A es la que fija el documento 11, pero las fuentes se contradicen y hasta que el dueño lo resuelva vale la lectura más estricta: `AGENTS.md` §5.4 veta la primera de esas palabras sin excepción; la guía de copy §0.4 reserva el nombre del diagnóstico a las notas de revisión y su §5e.15 lo admite en este campo; el informe §5.2 y el documento 11 §2.10 lo admiten solo aquí. El campo no se enseña en la tienda, pero el revisor sí lo ve, y las notas de revisión le dicen "The app makes no health claims". La B nombra texturas de Pro que dependen de la escucha del dueño (`README.md`, "Antes de enviar").

En las dos, "noise" se mantiene como en el documento 11: el nombre se escribe en una sola palabra y la tienda no lo parte.

## Descripción

```text en
SleepNoise makes, on your iPhone and as it plays, a noise that never loops: white, pink and brown noise, rain, wind, ocean and the other textures, mixed under one finger. All textures, one line each.

The Breathing tide paces the sea to six breaths a minute and recedes on its own. The timer fades instead of cutting and never touches your alarm. At three in the morning the whole screen is the button.

Seven nights with everything, no card. After that, Pro is one payment; white, pink, brown, rain, wind, the whole timer and three mixes stay free.

No subscription. No account. No tracking.

One payment.

One tap and it plays.

Six layers at once. One line each.

The sea breathes six times a minute.

At three in the morning, nothing.

What’s not here.
```

Recuento: 756 de 4000. Los cuatro primeros párrafos son los de la guía; los seis últimos son los titulares de las capturas, en orden, porque VoiceOver no lee las capturas (documento 11 §2.10). "Breathing tide" solo se escribe aquí, en prosa de ficha (C15).

Dos enmiendas propuestas, que no se aplican sin el sí del dueño porque el texto por defecto es el de la guía, letra a letra.

Primera frase de reserva, por el mismo motivo que la del texto promocional (sustituye a la que va hasta los dos puntos):

```text en
SleepNoise makes the sound on your iPhone, as it plays, with no audio files and no loops:
```

Recuento: 89. Con ella la descripción pasa de 756 a 770.

Tercer párrafo, para la directriz 2.3.2. La descripción presenta la Marea y las capturas 3 y 4 enseñan funciones de Pro sin decir que lo son; hoy solo se deduce de la lista de lo gratis. Enmienda propuesta, también en la guía §5e.15:

```text en
Seven nights with everything, no card. After that, Pro, which adds the other textures, the Tide and unlimited mixes, is one payment; white, pink, brown, rain, wind, the whole timer and three mixes stay free.
```

Recuento: 207. Con ella la descripción pasa de 756 a 818; con las dos enmiendas, a 832.

## Novedades de la 1.0

```text en
SleepNoise: a black page, one line that breathes with the real sound, and a Night screen that is all button.
Named mixes, four from the house. A timer that fades instead of cutting. Small hours: twenty minutes of sea that recedes on its own.
Seven nights with everything. After that, Pro is one payment. Free stays free.
If something won’t play, Settings › Write to the author. We’d like to know.
```

Recuento: 396 de 4000. App Store Connect no pide este campo en la primera versión de una app (a comprobar al crear la ficha); el texto queda listo para la nota de TestFlight y como base de la 1.0.1. Tres cambios respecto a la plantilla de la guía, para no prometer lo que `docs/PLAN-SIMPLE-1.0.md` §4.3 y §4.4 dejan fuera: no dice que la app esté rediseñada, porque es la primera versión en la tienda; Madrugada no se anuncia desde la pantalla de bloqueo del iPhone, porque no hay widgets ni Live Activity; y el aviso de fallos lleva a "Escribir al autor", porque el Diagnóstico pasa a 1.1.

## Capturas

Seis, en este orden, solo iPhone y solo fondo negro (C57). Sin vídeo de vista previa en 1.0. Las genera `scripts/screenshots.sh` (S-08), que lee de este fichero el titular (el primer bloque de cada captura) y su segunda línea (el bloque que sigue a "Subtítulo de la captura:"). Cada nota "Pantalla:" dice lo que sale en la captura generada (`scripts/screenshots/README.md`), no lo que dibujaba la maqueta.

### Captura 1 · la página sonando

```text en
One payment.
```

Recuento: 12 de 41. Pantalla: mezcla de la casa "Rosa y lluvia" cargada (Lluvia 55 · Rosa 20), sonando a las 20:15, con "trial · 6 nights left" en la cabecera y el estado "Playing · fades at 9:00 PM" (en español, "prueba · quedan 6 noches" y "Sonando · se funde a las 21:00").

Riesgo anotado: la directriz 2.3.7 pide que nombre, subtítulo y capturas no lleven precios ni condiciones. Este titular y "no card" en su subtítulo son condiciones de pago; los fija C57 y no se cambian sin el sí del dueño. Reserva lista si App Review lo discute o el dueño lo prefiere, titular y subtítulo:

```text en
Made on your iPhone.
```

Recuento: 20 de 41.

```text en
Seven nights with everything.
```

Recuento: 29 de 42. Si se usa la reserva, cambia también el quinto párrafo de la descripción, que repite este titular.

Subtítulo de la captura:

```text en
Seven nights with everything, no card.
```

Recuento: 38 de 42.

### Captura 2 · el primer uso, en reposo

```text en
One tap and it plays.
```

Recuento: 21 de 41. Pantalla: la página de quien no ha comprado nada ni ha empezado la prueba, en reposo: mezcla "Tonight" (Rain 30 · Pink 50, la del documento 11 §2.4), en silencio, cabecera vacía, el Disco en Play y la fila de la Marea con "Off · pro". No es la primera apertura al pie de la letra, que carga "Rosa y lluvia": con ella las capturas 1 y 2 enseñaban la misma página.

### Captura 3 · la hoja Capas bajo el dedo

```text en
Six layers at once. One line each.
```

Recuento: 34 de 41. Pantalla: la hoja "Layers" con seis capas sonando (blanco, rosa, marrón, lluvia, viento y océano) y la fila de la lluvia bajo el dedo, a 52. Seis capas a la vez no se pueden tener con las cinco texturas gratuitas: la captura se hace con la prueba en marcha (documento 11 §12) y enseña algo que después es de Pro. La directriz 2.3.2 pide que descripción y capturas dejen claro qué requiere compra; ver la nota de la descripción.

Subtítulo de la captura:

```text en
Drag across the name to change the level.
```

Recuento: 41 de 42.

### Captura 4 · Marea guiando

```text en
The sea breathes six times a minute.
```

Recuento: 36 de 41. Pantalla: la hoja de Marea con la línea de agua detenida en la subida de la tercera respiración, "guiding · 6 per minute", "Recedes at 8:27 PM" y las filas Tide, Pace, Descent y "Recedes after". La Marea es de Pro: vale lo dicho en la captura 3. La captura se hace sin la frase sobre estudios de variabilidad cardiaca (`marea.evidencia`) y sin el enlace "Qué sabemos" que el documento 11 §2.6 dibuja en esa hoja: "Qué sabemos" pasa a 1.1 (`docs/PLAN-SIMPLE-1.0.md` §4.4) y esa frase, dentro de una captura, sería una afirmación fisiológica en la ficha. La hoja de 1.0 no las lleva.

### Captura 5 · Noche sola

```text en
At three in the morning, nothing.
```

Recuento: 33 de 41. Pantalla: la pantalla Noche, negra: el Horizonte, la hora (3:07), el estado "Fades at 3:42 AM" y "+15 min" al pie. Nada más.

### Captura 6 · la página "Lo que no hay"

```text en
What’s not here.
```

Recuento: 16 de 41. Pantalla: la página real de la app, dentro de la hoja de Ajustes: el título, la lista de ausencias (una por línea) y "We won’t ask you to rate it." No lleva pie: la página construida no lo tiene (repetiría sus tres primeras líneas) y la app no muestra su peso.

Lista que se ve en la captura (es la de la página, no un campo de la tienda):

```text en
No subscription · No account · No tracking · No ads · No score · No streak · No tutorial
```

