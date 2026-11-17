# Protocolo de escucha · SleepNoise 1.0

Fecha: 17-11-2026. El sonido de SleepNoise se ha analizado sin oírlo (nivel, espectro, modulación, correlación entre canales), pero **nadie lo ha escuchado todavía en un iPhone**. Este protocolo es esa escucha. Su resultado es un sí, un no o un "retocar" para cada textura y para cada cosa que suena, y decide qué entra en 1.0 (`DECISIONES.md`, D-04).

Tiempo: unas 2 horas. Una con auriculares, 45 minutos por el altavoz y 15 para pasar las tablas a limpio. Se puede partir en dos tardes.

## 1. Preparación

- [ ] **Un iPhone real** con el build que quieres juzgar. El simulador no vale: suena por los altavoces del Mac.
- [ ] **Acceso a todo.** Seis de las once texturas y la Marea son de Pro. La forma de abrirlas sin gastar nada: lanza la app **desde Xcode** en tu iPhone, abre la hoja Pro y pulsa Comprar. Lanzada así usa la tienda local de pruebas: la compra es de mentira y no toca la prueba de 7 noches. La hoja Pro solo se abre **entre las 07:00 y las 21:00** del reloj del iPhone: haz esa compra de día aunque escuches de noche. No uses "Empezar la prueba" para esto: en un iPhone real solo se puede empezar una vez (`DECISIONES.md`, D-47). Durante la escucha, vuelve a la app sin cerrarla: la tienda local solo existe cuando la app se lanza desde Xcode, y abierta desde su icono puede volver al nivel gratuito. Si el producto ya está creado en App Store Connect, la otra vía es un build de TestFlight, donde comprar no cuesta nada. Pero ahí compras con tu cuenta de Apple real: esa compra no se borra desde App Store Connect y Pro te queda fijo en los builds de TestFlight, lo que estropea las pruebas que empiezan sin Pro (`PRUEBAS-EN-DISPOSITIVO.md` §8.B y §9). Para la escucha, mejor la compra de mentira de Xcode.
- [ ] **Los auriculares con los que dormirías**, y si tienes otros distintos (de cable, de diadema), también. Si los tuyos ofrecen audio espacial o "espacializar estéreo", apágalo durante la escucha: cambia la imagen estéreo que quieres juzgar.
- [ ] **Una habitación en silencio.** Para la parte del altavoz, el iPhone donde lo dejas de noche: sobre la mesilla, boca arriba, a la distancia real de tu cabeza.
- [ ] **Volumen del sistema fijo.** Elige uno cómodo con rosa a 40 y no lo toques durante toda la pasada. Apúntalo en la tabla (por ejemplo, "8 de 16 pasos"). La app nunca toca el volumen del sistema: lo que cambie, lo cambias tú.
- [ ] **Cuida el oído.** Las pruebas "a 100" duran unos segundos. Con auriculares no subas el volumen del sistema para hacerlas; la prueba de saturación a volumen alto se hace solo por el altavoz.
- [ ] Papel y lápiz, o esta tabla copiada en una nota. No la rellenes en el repositorio con datos tuyos: basta el sí, el no y una frase.

Cómo aislar una textura: abre "Todas las capas", baja todo a cero y sube solo la que toca. De día, una pulsación larga sobre el nombre de la mezcla ofrece "Vaciar".

Palabras para apuntar, siempre las mismas:

| Palabra | Qué es |
|---|---|
| **Clic** | Un chasquido seco al arrancar, parar, tocar un nivel o cruzar el cero |
| **Escalón** | El nivel sube o baja a saltos al arrastrar, en vez de deslizarse |
| **Bucle** | Reconoces algo que vuelve: la misma gota, la misma racha, el mismo trueno, cada tantos segundos |
| **Áspero** | Arenoso, metálico o chillón; cansa a los dos minutos |
| **Satura** | El altavoz zumba, cruje o distorsiona en los graves |
| **Bombea** | El conjunto sube y baja de forma que se nota y molesta |
| **Tono** | Una nota fija que sobresale y que acabas persiguiendo |

## 2. Orden

1. **Hoguera.** Es la que más riesgo tiene: lleva unos pocos chasquidos cortos, que son justo lo que puede sonar a clic digital, y su línea de uso en la app dice "brasas, sin chasquidos" (`DECISIONES.md`, D-38).
2. **Viento.** Es gratuita y nueva: la oye todo el mundo y entra en dos de las cuatro mezclas de la casa.
3. **Rosa.** Es lo primero que suena en una instalación nueva: el primer Play sube rosa a 40. Además es tu vara de medir para el nivel de las demás.
4. Marrón, blanco y lluvia: el resto de las gratuitas.
5. Océano, ventilador, trueno, arroyo y cabina: las de Pro.

Después: mezclas de la casa, seis capas a la vez, fundidos, Marea y Madrugada.

## 3. Cinco pruebas por textura

Con la textura sola, primero con auriculares:

| # | Prueba | Cuánto | Qué apuntas |
|---|---|---|---|
| 1 | A 40, ojos cerrados | 2 minutos | Carácter, bucle, tono, bombeo |
| 2 | Arrastra el nivel de 0 a 100 y vuelta, una vez despacio y otra deprisa | 20 segundos | Clic al salir del cero o al volver a él, escalones |
| 3 | A 100 | 10 segundos | Áspero, saturación |
| 4 | Pausa y Play, tres veces | 20 segundos | Clic al arrancar o al parar. El arranque sube en 0,8 s y la pausa se va en 1,5 s: ninguno debe ser un corte |
| 5 | Vuelve a 40 y alterna con rosa a 40 | 20 segundos | Nivel relativo: más bajo, igual o más alto que rosa |

Por el altavoz repite la 1 (un minuto basta), la 3 y la 5, y añade:

| # | Prueba | Cuánto | Qué apuntas |
|---|---|---|---|
| 6 | A 100 con el volumen del sistema alto | 10 segundos | Si el altavoz satura con los graves |
| 7 | A 40 con el volumen de tu mesilla | 1 minuto | Si la textura se reconoce todavía o se queda en un siseo. Las más graves pueden casi desaparecer en un altavoz pequeño: apúntalo, no es un fallo del código |

Y una prueba de repetición, solo con hoguera, lluvia y trueno:

| # | Prueba | Qué apuntas |
|---|---|---|
| 8 | Arranca, escucha los primeros 15 segundos, cierra la app del todo, ábrela y arranca otra vez (si usas la tienda local, relánzala desde Xcode) | Si reconoces el mismo principio. Las semillas del sonido son fijas en cada arranque (solo el calendario del trueno cambia): interesa saber si se nota. Tiene que ver con la frase "nunca se repite" de la ficha (`DECISIONES.md`, D-11) |

## 4. Qué oír en cada textura

El nombre y la línea de uso son los que enseña la app. La columna del medio dice cómo está hecha, para que sepas qué buscar.

| Textura · línea de uso | Cómo está hecha | Qué vigilar |
|---|---|---|
| **Hoguera** · brasas, sin chasquidos | Un cuerpo grave de llama que parpadea despacio y unos pocos chasquidos cortos, repartidos entre los dos canales | Que los chasquidos suenen a leña y no a clic digital. Que no caigan siempre en el mismo oído. Que el parpadeo no bombee. Y si lo que oyes casa con "sin chasquidos" |
| **Viento** · entre árboles | Aire de banda ancha cuyo brillo y nivel siguen dos rachas lentas de distinto periodo; sin tono de motor | Que no puedas predecir la siguiente racha. Que no silbe. Que las rachas vengan del centro y no de un lado. Que entre racha y racha no se quede en nada |
| **Rosa** · suave y equilibrado | Ruido rosa clásico | Que sea liso: ni ondas lentas ni brillo que canse. A 40 con tu volumen, que sirva de fondo sin imponerse |
| **Marrón** · retumbo grave | Ruido marrón: casi todo graves | Por el altavoz: si satura a 100 y si a 40 se oye algo. Con auriculares: que no haya un vaivén lento ni presión incómoda |
| **Blanco** · siseo parejo | Ruido blanco | Es la más brillante: con la misma cifra parecerá más fuerte. Apunta cuánto. Que no sea áspera con auriculares a 40 |
| **Lluvia** · sobre el tejado | Un fondo de siseo y cinco voces de gotas que llegan al azar, cada una con su tono | Una gota que reconozcas porque vuelve igual. Gotas que suenen a tic. Que el fondo y las gotas parezcan una sola cosa |
| **Océano** · oleaje lento | Un retumbo grave bajo dos olas lentas de distinto periodo, y una banda de espuma que rompe un poco antes de la ola | Que no cuentes el periodo de la ola. Que la espuma no sea áspera. Por el altavoz, si el retumbo satura o si sin él suena solo a siseo. Es la base de la Marea y de Madrugada: júzgala con calma |
| **Ventilador** · ventilador lejano | Un soplo de banda ancha, un zumbido bajo de motor con su armónico, un aleteo leve de aspas y un vaivén lento | El zumbido como tono que persigues. Un aleteo que suene a helicóptero. Si "lejano" es verdad |
| **Trueno** · lejano, sin rayos cerca | Lluvia suave de fondo y retumbos lentos cada 4,5 a 12,5 segundos; el primero llega en el primer segundo; ninguno empieza con golpe | Que ningún retumbo empiece con un clic o un golpe. Que no sean demasiado seguidos para dormir. Por el altavoz, si saturan. Que no reconozcas el mismo trueno |
| **Arroyo** · agua sobre piedras | Agua de banda media, un gorgoteo grave más suave y unas pocas burbujas | Burbujas que suenen a pitido sintético. Que no se quede en un siseo fijo. Que no haya un patrón de burbujas que vuelve |
| **Cabina** · avión en crucero | Un rugido grave de banda ancha y un zumbido de motores que late despacio | Si el latido se vuelve un bucle que cuentas. El zumbido como tono. Los graves por el altavoz. No debe tener ningún clic |

## 5. Tabla de texturas

Una fila por textura. En cada casilla: **sí** (vale), **no** (no entra) o **retocar** (entra si se corrige, y dices qué). La columna "Nivel" es frente a rosa a 40: más bajo, igual o más alto.

Volumen del sistema con auriculares: ______ · Auriculares: ______ · Volumen por el altavoz: ______ · Build: ______

| Textura | Clics | Escalones | Bucle | Áspero | Tono o bombeo | Satura el altavoz | Nivel | Auriculares | Altavoz | Qué retocar |
|---|---|---|---|---|---|---|---|---|---|---|
| Hoguera | | | | | | | | | | |
| Viento | | | | | | | | | | |
| Rosa | | | | | | | referencia | | | |
| Marrón | | | | | | | | | | |
| Blanco | | | | | | | | | | |
| Lluvia | | | | | | | | | | |
| Océano | | | | | | | | | | |
| Ventilador | | | | | | | | | | |
| Trueno | | | | | | | | | | |
| Arroyo | | | | | | | | | | |
| Cabina | | | | | | | | | | |

Regla para decidir: un **clic** o una **saturación con el volumen de la mesilla** son un "no" hasta que se corrijan. Un **bucle** que solo notas buscándolo es un "retocar" que puede esperar. El **nivel relativo** rara vez es un "no": se corrige con un número.

Si cae una textura de Pro, cambia la lista de la hoja Pro y la ficha. Si cae el océano, caen con él la Marea, Madrugada y "Mar y viento": avisa antes de darlo por malo. Si cae la hoguera, cae "Marrón y hoguera".

## 6. Mezclas de la casa

Están en la hoja Mezclas. Cárgalas una a una, con auriculares y por el altavoz. Las cifras son las de la receta.

| Mezcla | Receta | Qué oír |
|---|---|---|
| **Rosa y lluvia** | Lluvia a 55, rosa a 20 | Es la que ve todo el mundo el primer día. Que la lluvia mande y el rosa rellene sin taparla |
| **Mar y viento** | Océano a 50, viento a 20 | Que las olas y las rachas no coincidan siempre ni se peleen. Lleva océano, que es de Pro |
| **Marrón y hoguera** | Marrón a 40, hoguera a 30 | Que los chasquidos asomen sobre el marrón sin sobresaltar. Por el altavoz, si el marrón satura. Lleva hoguera, que es de Pro |
| **Pared** | Marrón a 40, lluvia a 30, viento a 30 | Que haga lo que su nombre dice: tapar. Que no sea un bloque áspero |

Cuatro cosas más:

- [ ] **Salto entre mezclas.** Con una sonando, carga otra. ¿El cambio es un corte, un clic o un paso suave? Hoy las ganancias se cruzan en unos 20 milisegundos, sin fundido cruzado (`DECISIONES.md`, D-36).
- [ ] **Volumen entre mezclas.** Pasa por las cuatro sin tocar nada: ¿alguna pega un salto de volumen?
- [ ] **Recortadas.** Sin Pro, "Mar y viento" se carga como "Mar y viento · sin Océano" (queda viento a 20) y "Marrón y hoguera" queda en marrón a 40. Para oírlas así hace falta un iPhone sin Pro; en el tuyo, baja a cero la capa de Pro y juzga lo que queda: ¿se sostiene sola o suena a mezcla rota?
- [ ] **Seis a la vez.** Sube seis capas a 100. La salida está acotada para no romper, pero puede volverse áspera: apunta desde qué punto. Luego seis capas a 40, que es un uso real.

| Mezcla | Equilibrio | El nombre la describe | Salto al cargarla | Auriculares | Altavoz | Qué retocar |
|---|---|---|---|---|---|---|
| Rosa y lluvia | | | | | | |
| Mar y viento | | | | | | |
| Marrón y hoguera | | | | | | |
| Pared | | | | | | |
| Mar y viento, recortada | | | | | | |
| Marrón y hoguera, recortada | | | | | | |
| Seis capas a 100 | | | | | | |
| Seis capas a 40 | | | | | | |

## 7. Fundidos de arranque, pausa y final

Nada en la app debe empezar ni acabar de golpe. Los tiempos son los del código; si lo que oyes no se parece, apúntalo.

| Momento | Cómo provocarlo | Qué debe pasar | Qué vigilar |
|---|---|---|---|
| **Arranque** | Play desde silencio | Sube en 0,8 s | Clic al principio. Que no parezca un golpe con el volumen alto |
| **Pausa** | Tocar el Disco mientras suena | Se va en 1,5 s: "sale de la habitación" | Clic al final. Que no se corte antes de tiempo |
| **Pausa y Play seguidos** | Tocar dos veces rápido | Vuelve sin salto | Clic o hueco |
| **Final de "Hasta dormirme"** | Pon 5 minutos, lo mínimo que deja la rueda, y espera | Se funde el último minuto y cuarto. El fundido es una cuarta parte de la duración, con un tope de 15 minutos; con los 45 minutos de fábrica son los últimos 11 | Que la bajada sea continua, sin escalones, sobre todo al final, cuando casi no se oye. Que termine en silencio limpio, sin clic cuando el motor para. La página dice "Sonando · fundiendo · n min" |
| **"+15 min" durante el fundido** | En Noche, toca "+15 min" mientras funde | El nivel vuelve y la hora de fin se mueve | Que la vuelta no sea un salto |
| **Bajada del Manto** | Modo Manto; a los 45 minutos de empezar | Baja 6 dB a lo largo de un minuto, una sola vez | Necesita 45 minutos: hazlo leyendo, o en la noche entera. Que no se note como un cambio, solo como "está más bajo". Si arrastras el nivel en Noche durante ese minuto, hoy la bajada se completa de golpe (`DECISIONES.md`, D-36): prueba si se oye |
| **Quitarte un auricular** | Sonando por los auriculares, quítatelos o apágalos | Se calla en 40 milisegundos y queda en pausa | Que **no se escape nada por el altavoz**. Es lo más importante de esta tabla |
| **Volver de una llamada** | Que te llamen fuera de la franja de 05:00 a 11:00, en la que una interrupción da la noche por terminada; cuelga | Vuelve solo, subiendo en 3 s | Que la vuelta no sobresalte |
| **Reanudar por el altavoz** | Tras perder los auriculares, toca "Seguir por el altavoz" | Suena por el altavoz con el nivel de la noche limitado a 40; la página dice "Sonando · al 40" | Que ese nivel no sea un susto con el volumen que llevabas en los auriculares |

| Fundido | Sin clic | Sin escalones | Duración correcta | Sí, no o retocar | Nota |
|---|---|---|---|---|---|
| Arranque | | | | | |
| Pausa | | | | | |
| Final del temporizador | | | | | |
| "+15 min" | | | | | |
| Bajada del Manto | | | | | |
| Auricular fuera | | | | | |
| Vuelta de llamada | | | | | |
| Seguir por el altavoz | | | | | |

## 8. Marea

La Marea acompasa el mar a un ritmo lento y después se retira. Es una función de sonido: la app no mide ni promete nada sobre el cuerpo. Aquí solo se juzga cómo suena.

Preparación: océano solo, a 40. Enciende la Marea. Si el océano estaba a cero, la app lo sube a 40 y lo dice.

- [ ] **Ritmo "Tranquilo · 6" y "Suave · 8".** Dos minutos cada uno. ¿La ola sube y rompe con naturalidad, o se nota una mano subiendo y bajando el volumen?
- [ ] **Línea de agua y sonido a la vez.** En la hoja Marea, la línea sube mientras la ola crece. Compruébalo por el altavoz y con auriculares de cable si tienes. Con auriculares Bluetooth el sonido llega con algo de retraso: apunta si el desfase se nota y si molesta.
- [ ] **"Descenso".** Empieza a 12 por minuto y baja un paso cada 40 segundos hasta el ritmo elegido. ¿Los cambios de ritmo son suaves o hay un salto en cada paso?
- [ ] **Con otras capas.** Añade rosa a 40 y lluvia a 30. La Marea mueve también las demás capas con una profundidad común. ¿Respiran con el mar o bombean?
- [ ] **Retirada.** Pon "Se retira a los" 5 minutos. A los 5 la guía se disuelve durante 2 minutos y queda el mar a su aire. ¿Notas el momento, o solo te das cuenta después? Lo bueno es lo segundo.
- [ ] **Encender y apagar sonando.** ¿Clic? ¿Salto de nivel?
- [ ] **Por el altavoz, a volumen de mesilla.** ¿Se distingue todavía la ola?

| Marea | Natural | Sin saltos | Sí, no o retocar | Nota |
|---|---|---|---|---|
| Tranquilo · 6 | | | | |
| Suave · 8 | | | | |
| Línea y sonido a la vez, altavoz | | | | |
| Línea y sonido a la vez, Bluetooth | | | | |
| Descenso | | | | |
| Con otras capas | | | | |
| Retirada a los 5 min | | | | |
| Encender y apagar | | | | |
| Altavoz, volumen de mesilla | | | | |

## 9. Madrugada

Madrugada es una receta fija para quien se despierta a media noche: océano bajo (a 30) con la marea a 8 por minuto, veinte minutos, y después nada. Suena igual con Pro y sin Pro.

Cómo entrar: con el Atajo ("Madrugada en SleepNoise") o desde la pantalla Noche cuando la noche ha terminado, con "Madrugada · 20 min".

Escúchala entera una vez, a oscuras, con el volumen que tendrías a las tres de la mañana. Son 20 minutos.

| Minuto | Qué debe pasar | Qué vigilar |
|---|---|---|
| 0:00 | Entra en 3 segundos | Que no sobresalte. Que el nivel sea bajo de verdad con tu volumen de noche, por el altavoz y con auriculares |
| 0:00 a 10:30 | El mar guía a 8 por minuto | Que la ola se distinga a ese nivel tan bajo; por el altavoz puede perderse |
| 10:30 a 13:00 | La marea se disuelve | Que no notes el cambio |
| 13:00 a 15:00 | Mar a su aire | Nada |
| 15:00 a 20:00 | "Se retira": el mar se funde durante 5 minutos | Bajada continua, sin escalones al final |
| 20:00 | Silencio. No pasa nada más | Que no haya clic al terminar ni vuelva a sonar la mezcla anterior |

Dos pruebas más:

- [ ] **Entrar con una mezcla sonando.** Con "Pared" sonando, lanza Madrugada. ¿El relevo es un corte o un paso suave? (`DECISIONES.md`, D-36.)
- [ ] **Pausa dentro de Madrugada.** Pausa un minuto y vuelve. Debe seguir siendo Madrugada, no la mezcla de antes.

| Madrugada | Auriculares | Altavoz | Sí, no o retocar | Nota |
|---|---|---|---|---|
| Entrada | | | | |
| Nivel a las tres de la mañana | | | | |
| Disolución de la marea | | | | |
| Fundido final | | | | |
| Silencio al terminar | | | | |
| Relevo desde una mezcla | | | | |

## 10. Qué hacer con el resultado

- [ ] Pasa las tablas a limpio y dáselas a Claude tal cual, sin datos personales.
- [ ] Para cada "no" y cada "retocar", una frase que se pueda reproducir: textura o mezcla, nivel, por dónde sonaba, volumen del sistema, minuto y la palabra de la tabla del apartado 1. Ejemplo: "Lluvia sola a 40, auriculares de cable, volumen medio: hacia el segundo 20 vuelve una gota aguda idéntica".
- [ ] Si puedes, guarda una **grabación de pantalla** del iPhone mientras ocurre: recoge el sonido de la app y sirve para que Claude lo analice.
- [ ] Cada cambio de sonido se vuelve a escuchar: repite solo la fila afectada con el build nuevo.

Lo que Claude hace después: corregir las texturas marcadas "retocar", de una en una, porque el sonido tiene un solo escritor; quitar de la hoja Pro, de la ficha, de las notas de revisión y de la captura de Capas la textura que no entre; y ajustar los niveles relativos.
