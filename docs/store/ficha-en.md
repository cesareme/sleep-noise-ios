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

## Texto promocional

```text en
Sleep sound that never loops, made on your iPhone. Seven nights with everything, no card. One payment.
```

Recuento: 102 de 170.

## Palabras clave

Separadas por comas, sin espacio tras la coma y sin tildes. No repiten ninguna palabra del nombre ni del subtítulo (ni "sleep", "sounds", "pay" ni "once").

Opción A, la de `11-ICONO-Y-APP-STORE.md` §5.e:

```text en keywords
brown noise,white,pink,rain,wind,ocean,fan,breathing,generative,insomnia,tinnitus,snoring,loop
```

Recuento: 94 de 100. Lleva dos palabras de diagnóstico que la guía de copy solo admite en este campo, que no se enseña a nadie (§0.4 de la guía).

Opción B, sin esas palabras:

```text en keywords
brown noise,white,pink,rain,wind,ocean,fan,breathing,generative,loop,thunder,campfire,brook,timer
```

Recuento: 97 de 100. Elige el dueño. Si no dice nada, vale la A, que es la que fija el documento 11. En las dos, "noise" se mantiene como en el documento 11: el nombre se escribe en una sola palabra y la tienda no lo parte.

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

What's not here.
```

Recuento: 756 de 4000. Los cuatro primeros párrafos son los de la guía; los seis últimos son los titulares de las capturas, en orden, porque VoiceOver no lee las capturas (documento 11 §2.10). "Breathing tide" solo se escribe aquí, en prosa de ficha (C15).

## Novedades de la 1.0

```text en
SleepNoise: a black page, one line that breathes with the real sound, and a Night screen that is all button.
Named mixes, four from the house. A timer that fades instead of cutting. Small hours: twenty minutes of sea that recedes on its own.
Seven nights with everything. After that, Pro is one payment. Free stays free.
If something won't play, Settings › Write to the author. We'd like to know.
```

Recuento: 396 de 4000. App Store Connect no pide este campo en la primera versión de una app (a comprobar al crear la ficha); el texto queda listo para la nota de TestFlight y como base de la 1.0.1. Tres cambios respecto a la plantilla de la guía, para no prometer lo que `docs/PLAN-SIMPLE-1.0.md` §4.3 y §4.4 dejan fuera: no dice que la app esté rediseñada, porque es la primera versión en la tienda; Madrugada no se anuncia desde la pantalla de bloqueo del iPhone, porque no hay widgets ni Live Activity; y el aviso de fallos lleva a "Escribir al autor", porque el Diagnóstico pasa a 1.1.

## Capturas

Seis, en este orden, solo iPhone y solo fondo negro (C57). Sin vídeo de vista previa en 1.0. Las genera el test de interfaz de S-08.

### Captura 1 · la página sonando

```text en
One payment.
```

Recuento: 12 de 41. Pantalla: mezcla de la casa "Rosa y lluvia" cargada, sonando, con el estado de la prueba en la cabecera.

Subtítulo de la captura:

```text en
Seven nights with everything, no card.
```

Recuento: 38 de 42.

### Captura 2 · el primer uso, en reposo

```text en
One tap and it plays.
```

Recuento: 21 de 41. Pantalla: la página tal como se abre la primera vez: mezcla "Esta noche", en silencio, cabecera vacía, el Disco en Play.

### Captura 3 · la hoja Capas bajo el dedo

```text en
Six layers at once. One line each.
```

Recuento: 34 de 41. Pantalla: la hoja "Todas las capas" con seis capas sonando y un dedo arrastrando un nivel.

Subtítulo de la captura:

```text en
Drag across the name to change the level.
```

Recuento: 41 de 42.

### Captura 4 · Marea guiando

```text en
The sea breathes six times a minute.
```

Recuento: 36 de 41. Pantalla: la hoja de Marea con la línea de agua en movimiento y el ritmo a seis por minuto.

### Captura 5 · Noche sola

```text en
At three in the morning, nothing.
```

Recuento: 33 de 41. Pantalla: la pantalla Noche: negra, con la palabra de estado y nada más.

### Captura 6 · la página "Lo que no hay"

```text en
What's not here.
```

Recuento: 16 de 41. Pantalla: la página real de la app con la lista de ausencias y el pie.

Lista que se ve en la captura (es la de la página, no un campo de la tienda):

```text en
No subscription · No account · No tracking · No ads · No score · No streak · No tutorial
```

Pie de la captura, con el peso real de la app en lugar de `{MB}`:

```text en
Data Not Collected · {MB} MB
```

