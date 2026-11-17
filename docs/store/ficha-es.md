# Ficha de App Store · español (España)

Localización "Spanish (Spain)" de la versión 1.0 en App Store Connect. Cada bloque es el texto para pegar tal cual; el recuento, hecho con un script, va debajo. Los límites son los de App Store Connect, salvo los de las capturas, que son los de la maqueta (`docs/design/11-ICONO-Y-APP-STORE.md` §5.e).

Los textos salen de `docs/design/10-GUIA-DE-COPY.md` §5e.15 y de `docs/design/11-ICONO-Y-APP-STORE.md` §5.e. Donde se apartan de ellos, lo dice la nota del campo. Varias frases describen funciones de 1.0 que todavía no están en `main`: la lista está en `README.md` de esta carpeta y hay que repasarla antes de enviar.

## Nombre

```text es
SleepNoise
```

Recuento: 10 de 30. Provisional: el nombre se confirma el 04-12-2026 (`docs/PLAN-SIMPLE-1.0.md` §4.2).

## Subtítulo

```text es
Sonidos para dormir
```

Recuento: 19 de 30.

## Texto promocional

```text es
Sonido que nunca se repite, fabricado en tu iPhone. Siete noches con todo, sin tarjeta. Un solo pago.
```

Recuento: 101 de 170.

## Palabras clave

Separadas por comas, sin espacio tras la coma y sin tildes. No repiten ninguna palabra del nombre ni del subtítulo (ni "sonidos" ni "dormir").

Opción A, la de `11-ICONO-Y-APP-STORE.md` §5.e:

```text es keywords
ruido blanco,marron,rosa,lluvia,viento,mar,ventilador,respiracion,sin suscripcion,insomnio,acufenos
```

Recuento: 99 de 100. Lleva dos palabras de diagnóstico que la guía de copy solo admite en este campo, que no se enseña a nadie (§0.4 de la guía).

Opción B, sin esas palabras:

```text es keywords
ruido blanco,marron,rosa,lluvia,viento,mar,ventilador,respiracion,sin suscripcion,olas,trueno,arroyo
```

Recuento: 100 de 100. Elige el dueño. Si no dice nada, vale la A, que es la que fija el documento 11.

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
```

Recuento: 787 de 4000. Los cuatro primeros párrafos son los de la guía; los seis últimos son los titulares de las capturas, en orden, porque VoiceOver no lee las capturas (documento 11 §2.10). Un cambio respecto a la guía: "acompasa el mar" en lugar de la palabra que la lista de palabras vetadas (§0.5) reserva a la línea de uso del océano.

## Novedades de la 1.0

```text es
SleepNoise: una página negra, una línea que respira con el sonido real y una pantalla de Noche que es toda ella el botón.
Mezclas con nombre, cuatro de la casa. Un temporizador que se funde en vez de cortar. Madrugada: veinte minutos de mar que se retira solo.
Siete noches con todo. Después, Pro es un solo pago. Lo gratis sigue gratis.
Si algo no suena, Ajustes › Escribir al autor. Nos gustaría saberlo.
```

Recuento: 406 de 4000. App Store Connect no pide este campo en la primera versión de una app (a comprobar al crear la ficha); el texto queda listo para la nota de TestFlight y como base de la 1.0.1. Tres cambios respecto a la plantilla de la guía, para no prometer lo que `docs/PLAN-SIMPLE-1.0.md` §4.3 y §4.4 dejan fuera: no dice que la app esté rediseñada, porque es la primera versión en la tienda; Madrugada no se anuncia desde la pantalla de bloqueo del iPhone, porque no hay widgets ni Live Activity; y el aviso de fallos lleva a "Escribir al autor", porque el Diagnóstico pasa a 1.1.

## Capturas

Seis, en este orden, solo iPhone y solo fondo negro (C57). Sin vídeo de vista previa en 1.0. Las genera el test de interfaz de S-08.

### Captura 1 · la página sonando

```text es
Un solo pago.
```

Recuento: 13 de 41. Pantalla: mezcla de la casa "Rosa y lluvia" cargada, sonando, con el estado de la prueba en la cabecera.

Subtítulo de la captura:

```text es
Siete noches con todo, sin tarjeta.
```

Recuento: 35 de 42.

### Captura 2 · el primer uso, en reposo

```text es
Un toque y suena.
```

Recuento: 17 de 41. Pantalla: la página tal como se abre la primera vez: mezcla "Esta noche", en silencio, cabecera vacía, el Disco en Play.

### Captura 3 · la hoja Capas bajo el dedo

```text es
Seis capas a la vez. Una línea cada una.
```

Recuento: 40 de 41. Pantalla: la hoja "Todas las capas" con seis capas sonando y un dedo arrastrando un nivel.

Subtítulo de la captura:

```text es
Arrastra sobre el nombre para cambiar el nivel.
```

Recuento: 47 de 42. Supera el tope de maqueta: `11-ICONO-Y-APP-STORE.md` §9 deja la variante corta a quien monte la captura.

### Captura 4 · Marea guiando

```text es
El mar respira a seis por minuto.
```

Recuento: 33 de 41. Pantalla: la hoja de Marea con la línea de agua en movimiento y el ritmo a seis por minuto.

### Captura 5 · Noche sola

```text es
A las tres de la mañana, nada.
```

Recuento: 30 de 41. Pantalla: la pantalla Noche: negra, con la palabra de estado y nada más.

### Captura 6 · la página "Lo que no hay"

```text es
Lo que no hay.
```

Recuento: 14 de 41. Pantalla: la página real de la app con la lista de ausencias y el pie.

Lista que se ve en la captura (es la de la página, no un campo de la tienda):

```text es
Sin suscripción · Sin cuenta · Sin rastreo · Sin anuncios · Sin puntuación · Sin racha · Sin tutorial
```

Pie de la captura, con el peso real de la app en lugar de `{MB}`:

```text es
No se recopilan datos · {MB} MB
```

## Si se abre también "Spanish (Mexico)"

Todo igual salvo tres cambios (guía de copy §0.3): "generado" por "fabricado" en el texto promocional, "genera" por "fabrica" en la descripción, y "respirar" por "respiracion" en las palabras clave. La app solo lleva una localización `es`, así que esa ficha enseñaría la misma interfaz.
