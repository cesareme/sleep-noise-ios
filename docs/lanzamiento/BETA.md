# Beta de TestFlight · 5 noches

Fecha: 17-11-2026. Textos listos para copiar: la invitación, lo que va en los campos de TestFlight, qué probar cada noche y el formulario de comentarios. Todo en español y en inglés. El paso a paso de TestFlight está en `GUIA.md` §12.

Plan: entre diez y quince personas (familia, amigos, equipo), cinco noches seguidas, en la semana 4.

## 1. Antes de invitar

- [ ] **A quién.** Busca variedad antes que cantidad: alguien con un iPhone pequeño y alguien con uno grande; alguien en iOS 17 y alguien en la versión actual; al menos tres personas que duerman con auriculares y tres que usen el altavoz; al menos dos con el iPhone en inglés; alguien que use VoiceOver o texto grande, si lo conoces.
- [ ] **Dónde recoges las respuestas.** Un documento tuyo, fuera del repositorio. Al repositorio solo llegan resumidas y sin nombres.
- [ ] **Qué dirección das.** La de contacto de la app, la misma de la política de privacidad. Donde abajo pone `[dirección de contacto]`, va esa. No se escribe en este fichero.
- [ ] **Qué build.** Uno con `AppLinks` relleno y con la compra probada en sandbox (`PRUEBAS-EN-DISPOSITIVO.md` §8). Si la hoja Pro dice que la tienda no responde, los probadores no podrán probar Pro.
- [ ] **Qué deben saber y no es obvio**, y por eso va en la invitación: en TestFlight comprar no cuesta dinero; la hoja Pro solo se abre de día; la prueba de 7 noches se empieza una sola vez; el build caduca.

Estos textos pasan las listas de palabras de `docs/design/10-GUIA-DE-COPY.md` §0.5, con una sola coincidencia, que la guía admite ("Lock Screen"), y no prometen nada sobre el sueño ni la salud. Tampoco cuentan texturas. Si los cambias, mantén eso.

## 2. Mensaje de invitación

Para enviar tú, por el medio que uses con cada persona, junto al enlace de TestFlight.

### Español

```text es
Hola:

Estoy terminando SleepNoise, una app de sonidos para dormir para iPhone, y me gustaría que la usaras cinco noches antes de publicarla.

Qué es: sonidos (ruido blanco, rosa y marrón, lluvia, viento, océano y otros) que el iPhone fabrica mientras suenan. Los mezclas a tu gusto, pones un temporizador y apagas la pantalla. No hay cuenta, no hay anuncios y la app no recoge ningún dato.

Cómo instalarla:
1. Instala TestFlight, la app de Apple para versiones de prueba, desde el App Store.
2. Abre este enlace en el iPhone: [enlace de TestFlight]
3. Pulsa Instalar. Necesitas iOS 17 o posterior.

Tres cosas que conviene saber:
- La app tiene una compra, Pro. En esta versión de prueba comprar no cuesta dinero: no se cobra nada. Pruébala sin miedo.
- La app no vende nada de noche. La pantalla de Pro solo se abre entre las 07:00 y las 21:00.
- Hay una prueba de 7 noches con todo abierto. Se empieza una sola vez, desde esa misma pantalla.

Qué te pido: que duermas con ella cinco noches y que al final me contestes unas pocas preguntas. Te las mando el quinto día. Si algo falla antes, cuéntamelo en el momento: en TestFlight, una captura de pantalla te deja enviarla con un comentario, o escríbeme a [dirección de contacto].

Esta versión de prueba caduca sola pasadas unas semanas.

Gracias por ayudarme.
```

### English

```text en
Hi,

I am finishing SleepNoise, an iPhone app of sounds for sleeping, and I would like you to use it for five nights before it goes out.

What it is: sounds (white, pink and brown noise, rain, wind, ocean and others) that the iPhone makes as they play. You mix them your way, set the timer and turn the screen off. There is no account, there are no ads and the app collects no data.

How to install it:
1. Install TestFlight, Apple's app for test versions, from the App Store.
2. Open this link on your iPhone: [TestFlight link]
3. Tap Install. You need iOS 17 or later.

Three things worth knowing:
- The app has one purchase, Pro. In this test version buying costs nothing: you are not charged. Go ahead and try it.
- The app sells nothing at night. The Pro screen only opens between 07:00 and 21:00.
- There is a 7-night trial with everything open. It starts only once, from that same screen.

What I am asking: sleep with it for five nights and answer a few questions at the end. I will send them on day five. If something goes wrong before that, tell me right away: in TestFlight, taking a screenshot lets you send it with a comment, or write to [contact address].

This test version expires by itself after a few weeks.

Thank you for helping.
```

## 3. Campos de TestFlight

### Descripción de la beta (Beta App Description)

```text en
SleepNoise plays sleep sounds that are made on the iPhone as they play: textures to mix, a timer that fades out, a black Night screen and a one-time purchase. No account, no ads, no data collected. This beta checks that the sound lasts the whole night and that nothing gets in the way in the dark.
```

```text es
SleepNoise reproduce sonidos para dormir que se fabrican en el iPhone mientras suenan: texturas para mezclar, un temporizador que se funde, una pantalla Noche en negro y una compra de un solo pago. Sin cuenta, sin anuncios y sin recoger datos. Esta beta comprueba que el sonido dura toda la noche y que nada estorba a oscuras.
```

### Correo para comentarios (Feedback Email)

`[dirección de contacto]`: se escribe solo en App Store Connect.

### Qué probar (What to Test)

```text en
Five nights, one thing each night. Use it the way you would really sleep.

Night 1. Open the app and tap the round Play button. Open "All layers" and drag a level sideways. Set the timer and turn the screen off. In the morning: did it play, did it fade out, did your alarm ring?
Night 2. Open "Mixes" and play one of the four house mixes. Make your own mix and save it from its name. Try the other timer mode, the one that ends at an hour.
Night 3. By day, between 07:00 and 21:00, open the Pro screen (turn the Tide on, or tap a layer marked "pro") and buy it: in TestFlight you are not charged. At night, turn the Tide on with the ocean.
Night 4. Use it your usual way, with headphones or with the speaker. Take the headphones off while it plays. Let a call or a message come in. Use the play and pause controls on the Lock Screen.
Night 5. If you wake up in the night, try "Small hours" (from the Night screen once the night has ended, or ask Siri: "Small hours in SleepNoise"). Ask Siri "Play SleepNoise" and "Pause SleepNoise".

Tell us about: any click, cut or sudden jump in the sound; anything too bright or hard to read in the dark; anything you could not find; battery used overnight.
```

```text es
Cinco noches, una cosa cada noche. Úsala como dormirías de verdad.

Noche 1. Abre la app y toca el botón redondo de Play. Abre "Todas las capas" y arrastra un nivel hacia los lados. Pon el temporizador y apaga la pantalla. Por la mañana: ¿sonó?, ¿se fundió al final?, ¿sonó tu despertador?
Noche 2. Abre "Mezclas" y pon una de las cuatro mezclas de la casa. Haz tu propia mezcla y guárdala desde su nombre. Prueba el otro modo del temporizador, "Manto", que termina a una hora.
Noche 3. De día, entre las 07:00 y las 21:00, abre la pantalla de Pro (enciende la Marea o toca una capa marcada "pro") y cómprala: en TestFlight no se cobra nada. Por la noche, enciende la Marea con el océano.
Noche 4. Úsala a tu manera, con auriculares o por el altavoz. Quítate los auriculares mientras suena. Deja que entre una llamada o un mensaje. Usa los controles de reproducir y pausar de la pantalla de bloqueo.
Noche 5. Si te despiertas de madrugada, prueba "Madrugada" (desde la pantalla Noche cuando la noche ha terminado, o pídeselo a Siri: "Madrugada en SleepNoise"). Pídele a Siri "Pon SleepNoise" y "Pausa SleepNoise".

Cuéntanos: cualquier clic, corte o salto brusco en el sonido; cualquier cosa demasiado brillante o difícil de leer a oscuras; cualquier cosa que no hayas encontrado; la batería gastada en la noche.
```

Si el campo no admite los dos idiomas a la vez, pon el inglés en la localización inglesa y el español en la española (*comprobar en la pantalla*).

## 4. Recordatorio a mitad de la beta

Opcional, el tercer día.

```text es
Hola:

Vas por la mitad de las cinco noches con SleepNoise. Si algo te ha fallado o te ha extrañado, cuéntamelo ya, aunque sea en una línea. Hoy toca probar Pro, de día: en TestFlight no se cobra nada. Gracias.
```

```text en
Hi,

You are halfway through the five nights with SleepNoise. If anything has failed or seemed odd, tell me now, even in one line. Today is the day to try Pro, by day: in TestFlight you are not charged. Thank you.
```

## 5. Formulario de comentarios

Corto a propósito: doce preguntas, cinco minutos. Se envía el quinto día, como mensaje o como documento. No pide nombre.

### Español

```text es
SleepNoise · cinco noches

1. ¿Qué iPhone tienes y con qué versión de iOS? (Ajustes, General, Información.)
2. ¿Cuántas de las cinco noches la usaste?
3. ¿Por dónde sonaba: auriculares (¿cuáles?) o el altavoz del iPhone?
4. ¿Sonó toda la noche, o hasta donde le pediste? Si se cortó, ¿qué noche y qué estaba pasando?
5. ¿Oíste algún clic, un salto de volumen o algo que se repite? ¿En qué sonido?
6. ¿Qué sonidos usaste más? ¿Hay alguno que no te suene a lo que dice su nombre?
7. ¿El final del temporizador te despertó o te molestó alguna vez?
8. A oscuras, ¿hubo algo demasiado brillante, demasiado pequeño o difícil de tocar?
9. ¿Hubo algo que buscaste y no encontraste, o que no entendiste?
10. ¿Probaste Pro o la prueba de 7 noches? ¿Algo confuso al comprar o al restaurar?
11. ¿Cuánta batería gastó en una noche, más o menos? ¿El iPhone se calentó?
12. Si pudieras cambiar una sola cosa, ¿cuál sería?

Algo más que quieras contar:
```

### English

```text en
SleepNoise · five nights

1. Which iPhone do you have, and which iOS version? (Settings, General, About.)
2. On how many of the five nights did you use it?
3. Where did it play: headphones (which ones?) or the iPhone speaker?
4. Did it play all night, or for as long as you asked? If it cut out, which night, and what was going on?
5. Did you hear a click, a jump in volume or something that repeats? In which sound?
6. Which sounds did you use most? Is there one that does not sound like its name?
7. Did the end of the timer ever wake you or bother you?
8. In the dark, was anything too bright, too small or hard to tap?
9. Was there anything you looked for and did not find, or did not understand?
10. Did you try Pro or the 7-night trial? Anything confusing about buying or restoring?
11. Roughly how much battery did one night use? Did the iPhone get warm?
12. If you could change one thing, what would it be?

Anything else you want to say:
```

## 6. Qué hacer con las respuestas

- [ ] Pásalas a una tabla tuya: una fila por persona, sin nombre (probador 1, 2…), con el modelo de iPhone y la versión de iOS.
- [ ] Marca cada comentario como **fallo** (algo no funciona), **sonido** (clic, corte, repetición), **no lo encontré** o **gusto**.
- [ ] Dos personas con el mismo fallo, o una sola con un corte de sonido durante la noche, son motivo para un build nuevo antes de enviar.
- [ ] Dale la tabla a Claude sin nombres ni direcciones.
- [ ] Contesta a cada persona. Y cumple con sus correos el plazo de borrado que promete la política de privacidad.

Lo que Claude hace después: ordenar los fallos por gravedad, corregir (paquete S-11), preparar el build siguiente y decirte qué respuestas piden una decisión tuya y no un arreglo.

## 7. Lo que la beta no prueba

Diez o quince personas durante cinco noches no sustituyen a `PRUEBAS-EN-DISPOSITIVO.md`: nadie va a avanzar la fecha ocho días, pedir un reembolso o agotar unos auriculares a propósito. La beta sirve para lo que tú solo no puedes ver: otros iPhone, otros auriculares, otras costumbres y ojos que no conocen la app.
