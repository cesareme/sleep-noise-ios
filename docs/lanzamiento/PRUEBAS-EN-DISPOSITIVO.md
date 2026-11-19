# Pruebas en dispositivo · lo que ningún simulador prueba

Fecha: 17-11-2026. El simulador no tiene batería, ni llamadas, ni auriculares que se agotan, ni pantalla de bloqueo real, ni Siri, ni la tienda de verdad. Todo eso está programado y probado por lógica, y **nada se ha ejecutado en un iPhone**. Este documento es la lista de lo que hay que ver con tus ojos, con pasos y con lo que debe pasar.

Los resultados esperados salen del código leído en el commit `80ebd1b`. Si lo que ves no coincide, no supongas que te equivocas tú: apúntalo.

Tiempo: unas 3 horas repartidas, más una noche.

| # | Prueba | Tiempo | Build que necesita |
|---|---|---|---|
| 1 | Una noche entera, con medida de energía | 1 noche y 30 min | Cualquiera; mejor el de TestFlight |
| 2 | Interrupciones: llamada, alarma, otra app de audio | 30 min | Cualquiera |
| 3 | Auriculares que se quitan o se agotan | 20 min | Cualquiera |
| 4 | Bloqueo de pantalla y entrada a Noche | 15 min | Cualquiera, de noche |
| 5 | Pantalla de bloqueo y Centro de control | 10 min | Cualquiera |
| 6 | Atajos por voz, en español y en inglés | 30 min | Cualquiera |
| 7 | VoiceOver | 30 min | Cualquiera |
| 8 | Compra: comprar, restaurar, pendiente, reembolso, En familia | 1 h | Xcode con tienda local, y sandbox |
| 9 | Prueba de 7 noches avanzando la fecha | 30 min | Uno sin Pro, con el llavero limpio: un iPhone que nunca la haya empezado (ver el apartado 9) |
| 10 | Actualización desde una instalación antigua | 30 min | Dos builds, lanzados desde Xcode. Los pasos 1 a 10, el 11 y el 12 piden cada uno un llavero limpio (ver el apartado 10) |
| 11 | Las bandas pintadas de Mezclas, a la luz, a oscuras y a las 21:00 | 15 min, de 20:50 a 21:05 | Cualquiera |

## 0. Antes de empezar

**Tres maneras de tener la app en el iPhone**, que no se comportan igual:

| Cómo | Tienda | Depuración | Para qué |
|---|---|---|---|
| Lanzada **desde Xcode** con el esquema tal cual | La local (`SleepNoise.storekit`): compras de mentira, se borran y se reembolsan desde Xcode | Sí | Pruebas 8 (parte local) y 10 |
| Lanzada desde Xcode **sin** configuración de StoreKit (en el esquema, Run, Options, StoreKit Configuration: ninguna; *comprobar en la pantalla*) | Sandbox: el producto real de App Store Connect, sin cobrar, con la cuenta de sandbox puesta en los ajustes del iPhone | Sí | Prueba 8 (parte sandbox). El esquema lo genera XcodeGen: el cambio se pierde al regenerar |
| Instalada desde **TestFlight** | Sandbox, pero con la **cuenta de Apple real** del iPhone (la de Contenido y compras), no con la de sandbox | No | Todo lo demás; es lo más parecido a la tienda. Antes de comprar con este build, lee 8.B |

**Dos avisos:**

- Los estados de depuración (`-pageState …`) sirven para capturas, no para estas pruebas: usan un reloj fijo, una tienda de guion y unos ajustes aparte. Aquí se prueba la app de verdad.
- **De 21:00 a 07:00 la app no vende**: la hoja Pro no se abre, y tampoco en la página nocturna ni en Madrugada. Las pruebas 8 y 9 se hacen de día, salvo los pasos de "Restaurar compra" en Ajustes (8.A, pasos 18 a 20b, y 8.B, paso 5b), que piden la noche o cambiar la hora del iPhone. La 4 se hace de noche, o cambiando la hora del iPhone.

**Cómo apuntar.** Cada tabla tiene una columna "Resultado": **sí** (pasó lo esperado), **no** (pasó otra cosa: cuál) o **no probado**. Un "no" lleva modelo de iPhone, versión de iOS, build y los pasos exactos.

iPhone: ______ · iOS: ______ · Build: ______ · Auriculares: ______

---

## 1. Una noche entera, con medida de energía

Qué se busca: que el sonido aguante toda la noche sin cortes, que el iPhone no se caliente, que no gaste más batería de la razonable y que por la mañana gane tu despertador.

Son dos medidas, porque se estorban: con el iPhone enchufado al Mac, el porcentaje de batería no dice nada.

### 1.A La noche real, sin cable

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Carga el iPhone al 100 % y desenchúfalo. Apunta la hora y el porcentaje | | |
| 2 | Pon tu despertador real del iPhone, como cada día | | |
| 3 | Carga la mezcla con la que dormirías, temporizador en **Manto** con el fin **entre 1 y 59 minutos después** de tu despertador (despertador a las 07:00, Manto hasta las 07:30), volumen de mesilla. Play | Suena; la página dice "Sonando · hasta las …" | |
| 4 | Bloquea el iPhone | Sigue sonando. Al encender la pantalla, de noche, está Noche (prueba 4) | |
| 5 | Si puedes, deja otro dispositivo **grabando el sonido de la habitación** toda la noche (una nota de voz en otro teléfono, o el micrófono del Mac). Es la única forma de saber si hubo un corte mientras dormías | En la forma de onda se ve un nivel continuo, un escalón suave hacia abajo a los 45 minutos (la bajada del Manto, 6 dB en un minuto) y ningún hueco | |
| 6 | Duerme. Si te despiertas, anota la hora y si sonaba | | |
| 7 | Cuando suene el despertador | El despertador se oye; SleepNoise calla. Al apagarlo, SleepNoise **no vuelve**: con Manto, desde una hora antes de su fin una interrupción da la noche por terminada. La franja de 05:00 a 11:00 solo rige sin Manto: si el fin del Manto queda a más de una hora del despertador, SleepNoise vuelve tras la alarma (prueba 2, paso 14) | |
| 8 | Apunta hora y porcentaje de batería | Ver la nota de abajo | |
| 9 | Abre la app, ya pasadas las 07:00 | Con la noche terminada y de día, Noche ya no está delante: se funde sola a la página de día, "En silencio" (o, en ese mismo sitio, la nota de la prueba si es tu última noche o ya ha terminado), sin ninguna hoja y sin que suene nada. **Esta pantalla ya no demuestra que la app aguantó la noche**: es la misma que enseña un arranque en frío después de un cierre. Eso lo dicen el paso 5 (la grabación), el 10 (tiempo en segundo plano) y el 12 (datos de análisis) | |
| 9b | Mientras Noche se funde (unos dos segundos), toca donde estaba "Madrugada · 20 min" | No arranca nada: ni Madrugada ni el Play de la página, que queda justo debajo. Pasado el fundido, la página responde como siempre | |
| 10 | Ajustes del iPhone, Batería: mira la parte de SleepNoise y su tiempo en segundo plano | Tiempo en segundo plano cercano a las horas dormidas | |
| 11 | Toca el iPhone al despertar | No está caliente | |
| 12 | Ajustes, Privacidad y seguridad, Análisis y mejoras, Datos de análisis: busca entradas con el nombre de la app (*comprobar en la pantalla*) | Ninguna de esa noche | |

Sobre el paso 9: desde que Noche cede sola por la mañana (`DECISIONES.md`, D-52), la hora a la que terminó la noche y qué la terminó ("Terminó a las …", con la hora del despertador o la del Manto) solo se leen **antes de las 07:00**. Para no perder ese dato, haz la primera noche real con el despertador y el fin del Manto antes de las 07:00 (por ejemplo, despertador a las 06:30 y Manto hasta las 06:50) y abre la app antes de esa hora: Noche sigue ahí y dice "Terminó a las …". Con esa hora también sabes que el proceso seguía vivo cuando sonó el despertador.

Sobre el paso 8: el plan no fija una cifra de batería. Como orientación de esta guía, que no es una cifra del plan: si una noche de ocho horas con la pantalla apagada se lleva más de una quinta parte de la batería, enséñaselo a Claude con los datos del paso 10.

### 1.B Una hora con el Mac midiendo

Para ver consumo de procesador, memoria y energía con cifras. El modo Debug gasta más que el build real, así que se mide con **Product, Profile**, que compila como el build de la tienda y abre Instruments.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | iPhone conectado al Mac. En Xcode, destino tu iPhone, menú Product, Profile | Se abre Instruments | |
| 2 | Elige una plantilla que registre actividad del procesador y energía (el nombre cambia entre versiones, *comprobar en la pantalla*) y empieza a grabar | | |
| 3 | En el iPhone: seis capas a 40, Marea encendida, Play. Bloquea la pantalla | Es el caso más caro que la app permite | |
| 4 | Deja pasar 60 minutos sin tocar | Uso del procesador **bajo y plano**, sin dientes de sierra ni crecimiento. Memoria **plana**: si sube sin parar durante la hora, es una fuga | |
| 5 | Minuto 60: pausa. Espera 2 minutos | El uso cae a prácticamente cero: sin sonido no debe quedar nada trabajando. La app no usa temporizadores periódicos; espera con un solo disparo al siguiente hecho | |
| 6 | Guarda la traza o una captura de las gráficas | Para dársela a Claude | |

Si quieres toda la noche con el Mac, repite 1.B dejándolo grabar; el Mac no debe dormirse y la traza puede ser grande. Recuerda que con el cable el iPhone carga: con el ajuste de fábrica "Mantener encendida · Mientras carga", la pantalla Noche se queda encendida y atenuada toda la noche. Es lo previsto; comprueba que no te molesta.

## 2. Interrupciones

Regla del código, para leer la tabla: una interrupción **fuera de la mañana** se reanuda sola con una subida de 3 segundos, siempre por la misma salida por la que sonaba; una llamada nunca termina la noche, dure lo que dure; cualquier otra cosa que la tenga en pausa 20 minutos la termina. **De 05:00 a 11:00** ninguna interrupción se reanuda: se supone que es tu despertador. **Con Manto** esa franja no cuenta: la sustituye la última hora antes de su fin (pasos 14 y 15).

El sistema no le dice a la app qué la interrumpió, salvo las llamadas. Por eso la hora manda.

| # | Paso (sonando, a una hora fuera de 05:00 a 11:00) | Esperado | Resultado |
|---|---|---|---|
| 1 | Que te llamen. No contestes; deja que deje de sonar | Calla al entrar la llamada. Al terminar, vuelve sola subiendo en 3 s | |
| 2 | Que te llamen. Contesta, habla un minuto, cuelga | Durante la llamada, la página dice "En pausa · llamada". Al colgar, vuelve sola | |
| 3 | Durante una llamada, toca el Disco | No arranca, y al colgar vuelve igualmente | |
| 4 | Durante una llamada, pausa tú: con el Atajo "Pausa" o con el reproductor del Centro de control, si te deja. Cuelga | **No** vuelve: lo que tú decides gana | |
| 5 | Pon un temporizador de la app Reloj a un minuto. Déjalo sonar y páralo | Calla mientras suena el aviso; al pararlo, vuelve sola | |
| 6 | Llama a Siri y pregunta la hora | Calla mientras Siri habla y vuelve | |
| 7 | Abre Música o Podcasts y dale a reproducir | SleepNoise calla (no suena debajo de otro audio: eso es de 1.1) | |
| 8 | Para la otra app | Apunta lo que pase. iOS no siempre avisa de que la otra app terminó: puede volver sola o quedarse en pausa. Si se queda, el Disco la reanuda | |
| 9 | Deja la otra app sonando más de 20 minutos y párala | La noche ha terminado: no vuelve. El siguiente Play empieza una noche nueva, con el temporizador desde el principio | |
| 10 | Mueve el interruptor de silencio del iPhone | Sigue sonando: el modo silencio no la calla | |
| 11 | Recibe una notificación con sonido | No la para. Apunta si el aviso se oye por encima o si la baja un instante | |

| # | Paso (cambia primero la hora del iPhone y arranca el sonido después) | Esperado | Resultado |
|---|---|---|---|
| 12 | Hora entre las 05:00 y las 11:00, temporizador que no sea Manto. Pon una alarma de Reloj a dos minutos. Déjala sonar y apágala | La alarma se oye. SleepNoise **no vuelve** | |
| 13 | Misma franja. Que te llamen y cuelga | **No vuelve**: en esas horas también una llamada termina la noche | |
| 14 | Hora a las 08:00; Manto hasta las 13:00; Play; alarma a dos minutos | Vuelve sola: con una hora de fin fijada, la franja de la mañana es solo la última hora antes de ese fin | |
| 15 | Hora a las 12:10; Manto hasta las 13:00; Play; alarma a dos minutos | **No vuelve** | |

## 3. Auriculares que se quitan o se agotan

Regla del código: cuando la salida desaparece, la app se calla en 40 milisegundos y **nunca vuelve a sonar sola por el altavoz del iPhone**. Vuelve sola solo si regresa la misma salida y la app está en pantalla.

| # | Paso (sonando por AirPods u otros auriculares Bluetooth) | Esperado | Resultado |
|---|---|---|---|
| 1 | Quítate **un** AirPod | Los propios AirPods piden pausa: baja en unos 3 s y queda en pausa | |
| 2 | Vuelve a ponértelo | Los AirPods piden reanudar: vuelve | |
| 3 | Quítate los dos y mételos en el estuche | Silencio inmediato. **Nada suena por el altavoz**, ni un instante. La página dice "En pausa · auriculares" y, durante un minuto, ofrece "Seguir por el altavoz" | |
| 4 | Toca "Seguir por el altavoz" | Suena por el altavoz con el nivel de la noche limitado a 40. La página dice "Sonando · al 40" hasta tu primer toque en un nivel | |
| 5 | Repite el 3 y espera más de un minuto | "Seguir por el altavoz" desaparece; sigue en pausa. El Disco reanuda con el mismo límite de 40 | |
| 6 | Repite el 3 con la app en pantalla y vuelve a ponerte los AirPods antes de 20 minutos | Vuelve sola por los AirPods, subiendo en 0,8 s, con el nivel que tenía | |
| 7 | Repite el 3 con el iPhone **bloqueado** y vuelve a ponértelos | **No** vuelve sola: la app no está en pantalla. La reanudas tú | |
| 8 | Repite el 3, espera más de 20 minutos y vuelve a ponértelos | La noche ha terminado: no vuelve | |
| 9 | Apaga el Bluetooth del iPhone mientras suena | Igual que el 3 | |
| 10 | **Batería agotada.** Deja unos auriculares casi sin batería sonando hasta que se apaguen. Si no puedes esperar, sirve apagarlos con su botón | Igual que el 3: silencio, nada por el altavoz | |
| 11 | Auriculares de cable (con adaptador): desenchúfalos mientras suena | Igual que el 3 | |
| 12 | Lo mismo que el 3, pero en la pantalla **Noche** | Noche dice "En pausa" y ofrece "Seguir por el altavoz" | |
| 13 | Con los AirPods puestos, **durante una llamada**, guárdalos en el estuche y cuelga | Queda en pausa; no vuelve sola al colgar | |
| 14 | Sonando por el altavoz del iPhone, conecta los AirPods | El sonido pasa a los AirPods sin corte brusco ni salto de volumen. Apunta lo que oigas: es cambio de ruta en mitad del sonido | |
| 15 | Un altavoz Bluetooth: apágalo mientras suena | Igual que el 3. La página dirá "auriculares": Bluetooth no distingue un altavoz de unos auriculares (`DECISIONES.md`, C-09) | |

## 4. Bloqueo de pantalla y entrada a Noche

Hazla entre las 21:00 y las 07:00, o cambia la hora. El iPhone debe tener **código de acceso**: la app se entera del bloqueo por el aviso de protección de datos, que sin código no llega.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | De noche, sonando, con la página a la vista y ninguna hoja abierta: bloquea. Espera 15 segundos y enciende la pantalla y entra con tu código o con Face ID | Está **Noche**: pantalla negra con la hora, la palabra de estado y nada más | |
| 2 | La primera vez que entras en Noche | Lee "Puedes apagar la pantalla. El sonido sigue." y "Mantén pulsado para volver". Solo esa vez | |
| 3 | No toques nada durante 60 segundos | La pantalla se atenúa. La app no toca el brillo del sistema: dibuja menos luz | |
| 4 | Arrastra un dedo en vertical por el centro | Cambia el nivel de la noche, con una regla a la vista. No cambia el volumen del sistema | |
| 5 | Arrastra desde muy cerca del borde superior o inferior | No cambia el nivel: son los gestos del sistema (Centro de control, inicio) | |
| 6 | Mantén pulsado | Vuelves a la página, en tinta nocturna | |
| 7 | En esa página, toca una capa "pro" o el interruptor de la Marea sin tener Pro | No se abre nada. De noche no se vende | |
| 8 | Toca el nombre de la mezcla | Vuelves a la página de día | |
| 9 | De noche, sonando, con una **hoja abierta** (Capas): bloquea y vuelve | No entra en Noche: una hoja abierta manda | |
| 10 | **De día**, sonando: bloquea y vuelve | No entra en Noche: de día un bloqueo es solo un bloqueo | |
| 11 | En Noche, enchufado al cargador, con "Mantener encendida · Mientras carga" (Mezclas, Ajustes) | La pantalla no se apaga sola | |
| 12 | En Noche, sin cargador | La pantalla se apaga a su tiempo; el sonido sigue | |
| 13 | Cambia a "Siempre" y a "Nunca" y repite 11 y 12 | Siempre: no se apaga nunca en Noche. Nunca: se apaga también cargando | |
| 14 | Con el temporizador en marcha, deja que termine estando en Noche | "Fundiendo · n min", luego "Terminó a las …" y aparece "Madrugada · 20 min" | |
| 15 | En Noche, durante el fundido, toca "+15 min" | El nivel vuelve y la hora de fin se mueve 15 minutos | |
| 16 | Con la pantalla apagada una hora | El sonido no se ha cortado | |
| 17 | Con Noche terminada delante ("Terminó a las …"), cierra la app sin salir de Noche y ábrela pasadas las 07:00; o deja la app abierta hasta las 07:00 | Noche se funde sola a la página de día, en silencio. No suena nada, no se abre ninguna hoja y no hace falta la pulsación larga. Antes de las 07:00 sigue como en el paso 14 | |
| 18 | Con una noche que **sigue sonando** a las 07:00 (sin temporizador), en Noche | Noche sigue delante y el sonido sigue: la mañana no toca una noche viva. Si la pausas, sigue ahí sus veinte minutos | |

## 5. Pantalla de bloqueo y Centro de control

En 1.0 no hay widgets, Live Activity ni control propio en el Centro de control: lo que se prueba es el reproductor del sistema.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Sonando, bloquea y enciende la pantalla | Aparece el reproductor del sistema con el **nombre de la mezcla** como título y el nombre de la app debajo | |
| 2 | Mira los controles | Solo reproducir y pausar. Sin anterior ni siguiente, y sin barra para moverse por el tiempo: se presenta como emisión en directo | |
| 3 | Pausa desde ahí | Se va en 1,5 s | |
| 4 | Reproduce desde ahí | Vuelve, sin pedir el código | |
| 5 | Abre el Centro de control y usa el reproductor | Lo mismo | |
| 6 | Cambia la salida desde el Centro de control (AirPlay, AirPods) | El sonido pasa a la otra salida; apunta si hay corte | |
| 7 | Pausa y espera más de 20 minutos; reproduce desde la pantalla de bloqueo, si el reproductor sigue ahí | Empieza una noche nueva: el temporizador cuenta desde el principio | |
| 8 | Carga otra mezcla y mira la pantalla de bloqueo | El título cambia | |
| 9 | Con una mezcla recortada (sin Pro) | El título es el recortado, como "Mar y viento · sin Océano" | |
| 10 | Botón de los AirPods, o del cable | Pausa y reanuda | |
| 11 | En CarPlay o con un reloj, si los tienes | Reproducir y pausar funcionan. No hay app para el reloj en 1.0 | |
| 12 | Sube y baja el volumen con los botones | Cambia el volumen del sistema. La app no lo toca por su cuenta | |

## 6. Atajos por voz, en español y en inglés

Hay cinco. Abre la app al menos una vez tras instalarla para que se registren, y comprueba que aparecen en la app Atajos.

Lo que el código garantiza: ninguno abre la hoja Pro ni empieza la prueba; lo que pide Pro sin acceso simplemente no suena; si la mezcla quedaría en silencio, suena rosa a 40. "Pausa" no abre la app; **los otros cuatro la traen al frente**, y por eso con el iPhone bloqueado pueden pedir el código o Face ID. Eso es justo lo que hay que mirar (`DECISIONES.md`, D-12).

Lo que nadie ha comprobado: que Siri entienda estas frases en español, y cómo pronuncia y reconoce el nombre de la app en español.

Pon Siri en **español** y di cada frase con el iPhone en uso; luego bloqueado; luego con los AirPods.

| # | Frase en español | Esperado | En uso | Bloqueado | AirPods |
|---|---|---|---|---|---|
| 1 | "Pon SleepNoise" · "Reproduce SleepNoise" | Suena la última mezcla, con el temporizador elegido. Si ya sonaba, nada cambia | | | |
| 2 | "Pausa SleepNoise" · "Para SleepNoise" | Pausa, sin abrir la app | | | |
| 3 | "Pon Pared en SleepNoise" · "Pon la mezcla Pared en SleepNoise" | Carga y suena esa mezcla. Prueba una de la casa y una tuya | | | |
| 4 | "Pon Mar y viento en SleepNoise", sin Pro | Suena recortada (solo viento). No se abre nada que venda | | | |
| 5 | "Pon Manto en SleepNoise" · "SleepNoise toda la noche" | Temporizador en Manto, con la hora que ya tenía; si estaba en reposo, arranca | | | |
| 6 | "Pon Hasta dormirme en SleepNoise" · "SleepNoise hasta que me duerma" | Temporizador en "Hasta dormirme", con los minutos que ya tenía; arranca si estaba en reposo | | | |
| 7 | "SleepNoise sin temporizador" | Temporizador apagado; no arranca nada | | | |
| 8 | "Madrugada en SleepNoise" · "Empieza Madrugada en SleepNoise" | Veinte minutos de mar bajo, con Pro y sin Pro. A las tres de la mañana, con el iPhone bloqueado en la mesilla, es el caso que importa | | | |

Pon Siri en **inglés** y repite:

| # | Frase en inglés | En uso | Bloqueado | AirPods |
|---|---|---|---|---|
| 1 | "Play SleepNoise" · "Start SleepNoise" | | | |
| 2 | "Pause SleepNoise" · "Stop SleepNoise" | | | |
| 3 | "Play Wall in SleepNoise" · "Play the Wall mix in SleepNoise" | | | |
| 4 | "Play Sea and wind in SleepNoise", sin Pro | | | |
| 5 | "Set Blanket in SleepNoise" · "SleepNoise all night" | | | |
| 6 | "Set Until I sleep in SleepNoise" · "SleepNoise until I fall asleep" | | | |
| 7 | "SleepNoise no timer" | | | |
| 8 | "Small hours in SleepNoise" · "Start Small hours in SleepNoise" | | | |

Y tres comprobaciones sin voz:

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 9 | En la app Atajos, crea un atajo con "Temporizador" y dale minutos | El campo de minutos admite de 1 a 360 y solo existe ahí, nunca en una frase | |
| 10 | Crea una automatización que lance "Pon la última mezcla" a una hora, o al activar el modo de concentración Sueño | Suena a su hora. Apunta si pide confirmación o el código | |
| 11 | De noche, lanza cualquier Atajo sin tener Pro | Nada vende ni menciona Pro | |

Apunta también cada vez que Siri **entienda otra cosa** (por ejemplo, que busque música): esas frases habrá que cambiarlas.

## 7. VoiceOver

Las etiquetas están puestas y probadas por lógica; nadie las ha oído (`DECISIONES.md`, D-15). Activa VoiceOver con el triple clic del botón lateral (Ajustes, Accesibilidad, Función rápida).

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Recorre la página deslizando a la derecha | Nombre de la mezcla, estado, cada capa con su nivel, Marea, Temporizador, Mezclas, Play, Noche. Todo tiene nombre; nada dice "botón" a secas | |
| 2 | Sobre una capa, desliza arriba y abajo | Cambia el nivel y lo dice | |
| 3 | Toque con dos dedos, dos veces (el gesto mágico) | Reproduce o pausa. Si no hace nada, apúntalo | |
| 4 | Abre Capas, Temporizador, Marea, Mezclas y Ajustes | Al abrir, el foco entra en la hoja; al cerrar con el gesto de escape (una Z con dos dedos), vuelve a donde estaba | |
| 5 | Entra en Noche | El foco entra en la pantalla; lee la hora; hay un elemento de volumen ajustable y uno para volver. La hora se relee al cambiar el minuto | |
| 6 | Hoja Pro, de día | Lee el nombre, el precio, lo que incluye y cada botón con su pista. Al comprar, anuncia "Gracias" | |
| 7 | Página nocturna, sin Pro, sobre una capa de Pro | La lee como cualquier otra, "en silencio, nivel guardado", sin mencionar Pro | |
| 8 | Con el recibo de Pro o con Ajustes abiertos | Se puede salir con el gesto de escape. No hay botón de cierre (`DECISIONES.md`, D-29): apunta si lo echas en falta | |

## 8. Compra

Se prueba en dos sitios. Con la **tienda local de Xcode**, lo que hay que poder provocar a voluntad: pendiente de aprobación, reembolso, fallos. Con **sandbox**, lo que solo existe de verdad en App Store Connect: el precio real, el nombre localizado, restaurar con una cuenta y En familia.

Todo de día, salvo los pasos que dicen otra hora. Empieza cada bloque sin Pro.

### 8.A Tienda local (lanzada desde Xcode en tu iPhone)

Las herramientas están en Xcode: el gestor de transacciones (menú Debug, StoreKit, Manage Transactions) y las opciones del fichero `.storekit` abierto en el editor (menú Editor: pedir para comprar, compras interrumpidas, país de la tienda). Los nombres exactos, *comprobar en la pantalla*.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Abre la hoja Pro: enciende la Marea, sube una capa "pro" en "Todas las capas", o Mezclas, Ajustes, fila Pro | La hoja enseña el nombre del producto, el precio, "Una vez.", lo que incluye, lo que es gratis siempre, "Empezar la prueba · 7 noches" (si no se ha usado), "Comprar · precio", "Restaurar compra" y "Ahora no" | |
| 2 | Toca Comprar y **cancela** en la hoja del sistema | La hoja Pro sigue ahí y dice "No se ha podido completar. No se ha cobrado nada." Es la misma línea que para un fallo: apunta si te parece bien para una cancelación tuya | |
| 3 | Toca Comprar y confirma | "Comprando…", luego "Gracias. Todo abierto." durante un segundo y medio, y la hoja se cierra sola | |
| 4 | Sube océano; enciende la Marea; guarda una cuarta mezcla | Todo funciona | |
| 5 | Mezclas, Ajustes, fila Pro | Abre el **recibo**: nombre, "gracias" y la fecha. Nada que cueste dinero | |
| 6 | Cierra la app y vuelve a lanzarla | Sigue con Pro, también antes de que la tienda conteste | |
| 7 | En el gestor de transacciones, **reembolsa** la compra, con la app en silencio | Pro desaparece. Las capas de Pro conservan su nivel como "pro · N" y no suenan. Las mezclas guardadas siguen todas | |
| 8 | Compra otra vez, pon a sonar el océano y **reembolsa mientras suena** | El océano sigue sonando hasta que pares. Al parar y volver a arrancar, ya no suena | |
| 9 | Borra la transacción y toca "Restaurar compra" | "Buscando…" y después el aviso de que no hay ninguna compra con esa cuenta | |
| 10 | Activa **pedir para comprar** en el editor del `.storekit`. Toca Comprar | El botón dice "Pendiente" y la línea de abajo, que está pendiente de aprobación y que se abrirá solo. Nada se abre todavía | |
| 11 | En el gestor de transacciones, **aprueba** | Pro se abre solo, sin tocar nada | |
| 12 | Repite el 10 y **rechaza** | Sigue sin Pro, y el botón **sigue en "Pendiente"**, sin poder comprar, hasta que cierres la app del todo y la abras: la tienda no avisa de un rechazo y la app solo retira ese estado cuando Pro se abre (`DECISIONES.md`, D-53). Tras relanzar, el botón vuelve a "Comprar · precio". Apunta qué dice la hoja | |
| 13 | Repite el 10, cierra la app, aprueba y abre la app | Arranca ya con Pro | |
| 14 | Activa las **compras interrumpidas** o un fallo de compra, si el editor lo ofrece | "No se ha podido completar. No se ha cobrado nada." | |
| 15 | Cambia el país de la tienda a España en el editor | La descripción y el precio salen en su versión española | |
| 16 | Con la hoja Pro abierta, cambia la hora del iPhone a las 20:59 y espera a las 21:00 | La hoja se cierra sola a las 21:00 | |
| 17 | A las 21:05, toca una capa "pro" | No se abre nada | |
| 18 | A las 21:05, sin Pro: Mezclas, Ajustes | Bajo "pro", la fila del producto no lleva precio y no abre nada. Debajo hay una fila "Restaurar compra". De día esa fila no existe | |
| 19 | Con la transacción borrada, toca esa fila | La fila dice "Buscando…" y después, debajo, el aviso de que no hay ninguna compra con esa cuenta. La hoja Pro no se abre y nada de lo de abajo cambia de sitio | |
| 20 | Lo mismo en la página nocturna, de día (entra en Noche, vuelve con la pulsación larga, Mezclas, Ajustes) | La fila "Restaurar compra" está también, a cualquier hora | |
| 20b | Con **VoiceOver**, a las 21:05 y sin Pro: activa "Restaurar compra" | Dice "Buscando" al empezar y el resultado al terminar. Mientras busca la fila se anuncia atenuada, y el foco sigue en ella cuando llega la respuesta | |

### 8.B Sandbox (producto real de App Store Connect)

Antes: el producto del paso 6 de `GUIA.md` existe, el acuerdo de apps de pago está activo, y has creado en App Store Connect una o dos **cuentas de prueba de sandbox** (Usuarios y acceso, Sandbox; *comprobar en la pantalla*). En el iPhone, la cuenta de sandbox se pone en Ajustes (en el apartado de desarrollador o en el de App Store, según la versión de iOS; *comprobar en la pantalla*). Nunca inicies sesión con una cuenta de sandbox como cuenta principal del iPhone. Las contraseñas las escribes tú.

**Con qué build.** Con el lanzado **desde Xcode sin configuración de StoreKit** (tabla del apartado 0): ese compra con la cuenta de sandbox. Un build de **TestFlight** no: compra con la cuenta de Apple real del iPhone, la de Contenido y compras. No se cobra, pero la compra queda unida a tu cuenta en el entorno de pruebas, y App Store Connect solo borra el historial de las cuentas de sandbox (*comprobar en la pantalla*): Pro te saldría ya comprado en cada build de TestFlight, y dejarían de valer los pasos 4, 5, 6 y 10 de esta tabla y el "sin Pro" de la prueba 9. Para usar un build de TestFlight con la cuenta de sandbox, la ayuda de App Store Connect ("Testing subscriptions and In-App Purchases in TestFlight") pide **cerrar antes la sesión de tu cuenta en Contenido y compras** y entrar después con la de sandbox en los ajustes de desarrollador. Vuelve a iniciar sesión con tu cuenta al terminar.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Con el build lanzado desde Xcode sin configuración de StoreKit (o uno de TestFlight con la sesión de Contenido y compras cerrada, como se explica arriba): abre la hoja Pro | El precio es el **real**, en euros, y el nombre es el de App Store Connect. Si sale "—" y "La tienda no responde", falta el acuerdo, el producto no está listo o no hay red | |
| 2 | Con el iPhone en inglés, la misma hoja | Nombre y precio con formato inglés | |
| 3 | Comprar, con la cuenta de sandbox | No se cobra nada. "Gracias. Todo abierto." | |
| 4 | Borra la app, reinstala y toca "Restaurar compra" | Puede pedir la contraseña de la cuenta. "Buscando…" dura lo que tarde; Pro vuelve | |
| 5 | Borra la app, reinstala y **no** toques Restaurar; espera un minuto con la app abierta | Apunta si Pro vuelve solo: la app lee los derechos al arrancar | |
| 5b | **De noche** (entre las 21:00 y las 07:00, o cambiando la hora): borra la app, reinstala y, si Pro no ha vuelto solo, Mezclas, Ajustes, "Restaurar compra" | Puede pedir la contraseña. "Buscando…" en la fila y después "Gracias. Todo abierto." debajo. Nada cambia de sitio: la fila de arriba sigue con el nombre solo y "Restaurar compra" se queda donde estaba, ya sin responder al toque. Al cerrar Ajustes y volver a abrirlo, la fila de arriba es el recibo y "Restaurar compra" ya no está. La hoja Pro no se abre. Si Pro ya había vuelto solo, la fila "Restaurar compra" no está: también es correcto | |
| 5c | De noche, sin Pro: toca "Restaurar compra" y **cancela** el diálogo de la cuenta de Apple, si sale | La fila vuelve a "Restaurar compra" sin ninguna línea debajo: no habla de compras ni de cobros. Se puede volver a tocar | |
| 5d | De noche, sin Pro: toca "Restaurar compra" y, mientras pide la contraseña o busca, cierra Ajustes y vuelve a abrirlo | La fila dice "Buscando…" y, cuando la tienda contesta, deja debajo su línea, igual que si no lo hubieras cerrado | |
| 6 | Con una segunda cuenta de sandbox que no ha comprado: Restaurar | El aviso de que no hay ninguna compra con esa cuenta | |
| 7 | Modo avión; abre la hoja Pro en una instalación nueva | Precio "—"; tras unos 8 segundos, "La tienda no responde. Nada cambia". Si sonaba, sigue sonando. Comprar no hace daño | |
| 8 | Modo avión, con Pro ya comprado; cierra y abre la app | Sigue con Pro: no depende de la red | |
| 9 | **En familia.** Si App Store Connect deja agrupar cuentas de sandbox en una familia (*comprobar en la pantalla*): compra con una y abre la app con la otra en otro iPhone | El segundo iPhone tiene Pro sin comprar, y su recibo añade "en familia" | |
| 10 | Saca a la segunda cuenta de la familia, o borra el historial de compras de la primera desde App Store Connect | El segundo iPhone pierde Pro, sin perder mezclas ni niveles | |
| 11 | En el recibo, "Escribir una reseña" | Solo aparece si `AppLinks.appStoreID` está relleno. Antes de publicar, la página de la tienda puede no existir | |
| 12 | Durante la revisión de Apple no puedes mirar, pero sí repetir esto con el build exacto que envías, el de TestFlight, con la sesión de Contenido y compras cerrada y la cuenta de sandbox | Los pasos 1, 3 y 4 pasan | |

Si en sandbox no hay forma de probar **pedir para comprar** o el **reembolso**, valen los de 8.A y se declara así en `docs/agents/ESTADO.md`.

## 9. Prueba de 7 noches avanzando la fecha

**Léelo entero antes de tocar nada.** El registro de la prueba vive en el llavero del iPhone y sobrevive a borrar la app: en un iPhone real, "Empezar la prueba" se puede pulsar **una sola vez**, salvo que borres todo el contenido del iPhone (`DECISIONES.md`, D-47). Si tienes un iPhone secundario, usa ese. Ese mismo registro manda también en la prueba 10: si vas a hacer las dos en un solo iPhone, lee antes el orden que da el apartado 10.

Cambiar la fecha a mano (Ajustes, General, Fecha y hora, sin ajuste automático) descoloca otras apps mientras dura: mensajes, códigos de verificación, certificados. Hazlo seguido y **vuelve a poner el ajuste automático al terminar**.

Cómo cuenta la app: la prueba empieza solo con su botón, de día. Se evalúa al **empezar una noche nueva** (un Play con la noche anterior ya cerrada), nunca en mitad de una. Abrir la app sin Play cuenta el tiempo pasado y lo guarda, pero no cambia nada a la vista: el cambio llega con el siguiente Play o la siguiente vez que la app arranca desde cero. La cifra de la cabecera son las noches que todavía empiezan (a las 21:00) antes del fin, con tope 7. De 21:00 a 07:00 la cabecera no dice nada.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Instalación nueva, sin Pro, de día (por ejemplo a las 12:00) | Cabecera vacía. La Marea se lee "Apagada · pro" | |
| 2 | Pulsa Play | Suena rosa a 40. **La prueba no ha empezado**: Play nunca la empieza | |
| 3 | Abre la hoja Pro | "Empezar la prueba · 7 noches" y debajo: "Dura siete noches. No se cobra nada ni se pide tarjeta. Al acabar, lo gratis sigue gratis y tus mezclas se conservan." | |
| 4 | Pulsa "Empezar la prueba · 7 noches" | La hoja se cierra. Todo abierto. La cabecera dice "prueba · quedan 7 noches". No se ha pedido cuenta ni pago | |
| 5 | Sube océano y hoguera, enciende la Marea, guarda cinco mezclas. Para el sonido | Todo funciona | |
| 6 | Cambia la hora a las 22:00 del mismo día y abre la app | La cabecera está vacía: de noche no se habla de la prueba | |
| 7 | Avanza la fecha dos días, a las 12:00, y abre la app | "prueba · quedan 5 noches". Apunta la cifra exacta que veas | |
| 8 | Avanza hasta el día 7 (seis días después de empezar), a las 12:00 | "prueba · última noche". Con la app en silencio, en el sitio de "En silencio": "Última noche con todo. Mañana, lo gratis sigue gratis." Desaparece con el Play y no vuelve | |
| 9 | Avanza al día 8, a las 10:00 (antes de la hora a la que empezaste) | La cabecera está **vacía**: no queda ninguna noche, aunque todo sigue abierto hasta la hora en que empezaste. Es el caso de `DECISIONES.md`, D-23: apunta si echas en falta un aviso | |
| 10 | Avanza al día 9, a las 12:00. Abre la app **sin** pulsar Play | Todavía **nada cambia**: la cabecera sigue vacía y todo sigue abierto, la Marea sin "pro". Esta apertura solo anota el tiempo pasado | |
| 11 | Cierra la app **del todo** (quítala del selector de apps), ábrela, mira y después pulsa Play | Al abrir, la prueba ya consta como terminada: la Marea vuelve a leerse "pro" y aparece "La prueba terminó. Lo que usaste sigue aquí." con "Entendido". Con el Play suena solo lo gratuito: océano y hoguera conservan su nivel como "pro · N" y no suenan. La nota se va con el Play o con "Entendido". La otra vía, si en el paso 10 pulsas Play sin cerrar la app: suena solo lo gratuito y la nota sale al parar | |
| 12 | Mira las mezclas guardadas | Están las cinco. Las que llevan capas de Pro se cargan recortadas. No puedes guardar una nueva por encima de tres | |
| 13 | Mira la cabecera en los días siguientes | "gratis siempre" durante siete arranques de sonido, y luego nada | |
| 14 | Abre la hoja Pro | Ya **no** ofrece la prueba. Comprar y Restaurar siguen | |
| 15 | Borra la app y reinstala | La prueba no se ofrece otra vez | |
| 16 | Compra Pro (tienda local o sandbox) | Todo vuelve, con los niveles que tenías | |
| 17 | Vuelve a poner la fecha automática | | |

Tres casos más. El 18 y el 19 empiezan la prueba, así que cada uno pide otro llavero limpio: otro iPhone sin estrenar, o lo que dice el apartado 10.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 18 | Empieza la prueba, pon a sonar el océano y, **mientras suena**, avanza la fecha nueve días | Sigue sonando: la prueba no se corta en mitad de una noche. Al parar y volver a arrancar más de 20 minutos después, ya no suena | |
| 19 | Empieza la prueba y **atrasa** la fecha un día antes de abrir la app, varias veces | Hueco conocido (`DECISIONES.md`, D-25): la prueba se alarga. Apunta cuánto | |
| 20 | Intenta empezar la prueba a las 22:00 | No se puede: la hoja Pro no se abre | |

## 10. Actualización desde una instalación antigua

La app no se ha publicado nunca, así que "antigua" quiere decir dos cosas: los builds que ya han pasado por tu iPhone y, durante la beta, el build anterior de cada probador.

El caso duro es el salto desde la primera versión del repositorio (la que se fusionó con el PR 2, commit `639a301`): tenía una prueba de 7 **días** que empezaba con el primer Play y se guardaba en los ajustes de la app, una sola mezcla guardada en el formato antiguo y un temporizador de hasta 60 minutos. Usa el mismo identificador de paquete que la app de hoy, así que el build nuevo se instala encima.

Preparación, que puede hacer Claude: una copia de trabajo aparte en ese commit, generar el proyecto y lanzarlo en tu iPhone con el **mismo identificador de paquete y el mismo equipo**, para que el build nuevo se instale encima y no al lado.

**El llavero manda, y no se borra con la app.** El build nuevo guarda la prueba en el llavero del iPhone, y un registro que ya esté allí gana a la prueba antigua: la app se queda con el del llavero y descarta la otra. Por eso los pasos 1 a 10, el paso 11 y el paso 12 piden **cada uno un llavero limpio**, igual que la prueba 9, y borrar la app en el paso 1 no lo limpia. En un solo iPhone:

- Haz primero el **paso 11**, que no deja registro mientras no pulses "Empezar la prueba".
- Después cabe **una** de estas tres: la prueba 9, los pasos 1 a 10 o el paso 12. Elige los pasos 1 a 10, que son el caso duro.
- Las otras dos, en otro iPhone sin estrenar; o en el simulador, que se limpia con Device, Erase All Content and Settings (*comprobar en la pantalla*) y cuya fecha es la del Mac, así que avanzarla es cambiar la del Mac; o en el mismo iPhone cuando exista el borrado de depuración de `DECISIONES.md`, D-47. Para hacer las tres en un solo iPhone, D-47 es un requisito.

Si te saltas este orden lo verás enseguida: después de la prueba 9, el paso 8 enseña una prueba ya terminada en vez de la antigua, y el paso 11 no ofrece "Empezar la prueba".

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Borra la app del iPhone. Instala el build antiguo desde Xcode | | |
| 2 | En el antiguo: ajusta niveles, guarda una mezcla con nombre, elige un temporizador, enciende la Marea y pulsa Play (eso empieza la prueba antigua). Para. Apunta todo | | |
| 3 | **Sin borrar la app**, lanza el build nuevo desde Xcode | Arranca sin cerrarse | |
| 4 | Mira la página | Los niveles son los que dejaste. No suena sola | |
| 5 | Abre Mezclas | Tu mezcla está, con su nombre y sus niveles, bajo "tuyas", junto a las cuatro de la casa | |
| 5b | Si en el build antiguo dejaste **más de seis capas** por encima de cero: abre "Todas las capas" y pulsa Play | Suenan las seis de nivel más alto. Las demás conservan su número, en tinta secundaria, sin tinta en su línea y con "Seis a la vez" debajo. Al bajar a cero una de las seis, entra la siguiente por nivel; si la vuelves a subir sin levantar el dedo, vuelve. Nada se ha borrado: la mezcla guardada sigue entera. En la página, mientras suena, la línea de estado nombra las que esperan ("Sonando · sin …") y la fila "Todas las capas" añade "Seis a la vez" si alguna de ellas no tiene fila | |
| 6 | Mira el Temporizador | Conserva lo que tenías. Si lo tenías apagado, sigue en "Apagado", no en los 45 minutos de una instalación nueva | |
| 7 | Mira la Marea | Conserva ritmo y duración | |
| 8 | Mira la cabecera, de día | La prueba antigua sigue como estaba, con el tiempo que llevaba gastado, contada ahora en noches | |
| 9 | Abre la hoja Pro | **No** ofrece "Empezar la prueba": la antigua cuenta como usada | |
| 10 | Avanza la fecha ocho días y pulsa Play | Termina como en la prueba 9 | |
| 11 | **Hazlo antes que los demás** (ver arriba). Repite 1 a 3 **sin pulsar Play** en el antiguo | Es una instalación nueva: la hoja Pro sí ofrece la prueba. No la empieces: gastarías el llavero | |
| 12 | Con el llavero limpio (ver arriba), repite 1 a 3 con la prueba antigua **ya agotada** (avanza la fecha en el antiguo) | Sigue agotada, sin prueba nueva y sin la nota "La prueba terminó" | |
| 13 | Con Pro comprado en el antiguo (tienda local) | Sigue con Pro | |
| 14 | Abre la app Atajos | Los cinco Atajos nuevos están; los antiguos no dejan restos que fallen | |

Durante la beta, la misma idea en pequeño:

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 15 | Con un build de TestFlight usado varias noches, instala el siguiente | Mezclas, niveles, temporizador, Marea, "Mantener encendida", estado de la prueba y Pro: todo igual | |
| 16 | Instala el build nuevo **mientras suena** el anterior | El sonido para al actualizarse (lo hace el sistema); al abrir, todo está y no suena sola | |

No hay camino de vuelta: no instales un build antiguo encima de uno nuevo y esperes que lea sus datos.

## 11. La pintura: bandas de Mezclas, ventana de la página y reglas de Capas

Las cuatro mezclas de la casa llevan de día una banda pintada a la izquierda (exploración 12 §6.1, D-57); desde D-58 la página de día lleva además una ventana pintada de 240 pt alrededor del Horizonte que respira con el sonido, y Capas una regla de 4 pt por fila. La regla es una sola (`PaintPolicy`): de 21:00 a 07:00, en la página nocturna, en Noche, en Madrugada, con la pantalla en reposo (`isLuminanceReduced`) y con Aumentar contraste o Reducir transparencia no hay pintura ninguna, y de noche no vuelve sola. Nadie la ha visto en un iPhone: en el simulador se ha visto de día, a las 20:59, a las 21:01, con el contraste y el movimiento reducido forzados, en AX3 y en inglés (`.build/shots/window-*.png`), y con toques reales (Play, Capas, el reloj cruzando las 21:00).

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | De día, con luz, abre Mezclas | "De la casa": cuatro bandas a sangre por la izquierda (rosa y lluvia, mar y viento, marrón y hoguera, pared), el texto empieza a su derecha; "Tuyas" y "Ajustes" sin pintura. Las filas miden lo mismo que antes | |
| 2 | A oscuras, en la mesilla, la misma hoja | La pintura se lee como papel, no como pantalla: nada deslumbra. Si ilumina el cuarto, apúntalo: el velo es del 12 % | |
| 3 | Abre Mezclas a las 20:58 y espera con la hoja abierta hasta las 21:01 | A las 21:00 las bandas se funden en unos 2 s (0,25 s con Reducir movimiento) y no vuelven; el texto no se mueve | |
| 3b | Otro día: abre Mezclas a las 20:58, sal de la app (inicio) y vuelve a las 21:05 con la hoja aún abierta | Al volver las bandas se funden igual: la vuelta al primer plano relee la regla (`scenePhase`) | |
| 4 | Cierra y vuelve a abrir Mezclas después de las 21:00 | Las filas de la casa son las de siempre, sin banda ni hueco | |
| 5 | Desde la página nocturna (tras volver de Noche), de día | Sin banda. Es la única comprobación de esta rama fuera del test puro: en el simulador no se puede escenificar de día | |
| 6 | Ajustes del iPhone, Accesibilidad, Pantalla: activa Aumentar contraste; luego Reducir transparencia | Sin banda con cualquiera de los dos; con los dos apagados, de día, vuelve al abrir la hoja | |
| 7 | Con VoiceOver, recorre "De la casa" | Lee nombre y receta como antes; la banda no se nombra | |
| 8 | Tamaño de texto AX3 y AX5 | La banda crece con la fila sin pisar el texto y el borde de los listones sigue duro (la pieza mide 288 pt y nunca se escala). En AX5 la hoguera queda arriba de su fila y debajo se ve el campo marrón | |
| 9 | De día, con luz, carga "Rosa y lluvia" y pulsa Play | Antes del Play la página es negra. En unos 2 s nace una ventana pintada de 240 pt alrededor del Horizonte (lluvia en oblicuo sobre un campo rosa); nombre, estado, filas y barra siguen sobre negro y se leen igual; el Índice sigue siendo lo más luminoso y lleva un halo negro. Nada cambia de sitio | |
| 10 | Con la mezcla sonando, sube y baja un nivel | La pintura se repinta sola al soltar (medio segundo), nunca mientras arrastras; no parpadea | |
| 11 | Enciende la Marea | La pintura se desliza unos píxeles con la respiración, sin saltos, y vuelve a su sitio al apagarla. El halo negro y la franja oscura de 24 pt acompañan a la línea de agua; donde estaba el Horizonte no queda ninguna barra negra | |
| 12 | Mira la ventana medio minuto | El 18 % de los trazos respira con el sonido, solo en luz; nada cambia de matiz, posición ni tamaño. Con blanco o rosa solos casi no se mueve: su RMS es casi plano, como el Horizonte | |
| 13 | Pausa | La pintura se seca (baja a 0,6 en 1,5 s) y los trazos vivos se apagan; no desaparece. Bajo las filas y en el halo sigue negro: secar oscurece, nunca aclara. Play la devuelve en menos de 1 s | |
| 14 | Abre Capas y vuelve | Al abrir, la pintura de la página se atenúa a 0,3; en Capas cada fila lleva una regla de 4 pt en el margen izquierdo con las tintas oscuras de su textura (viva si suena, seca a cero); el nombre no se ha movido. Al cerrar, la pintura vuelve en 0,8 s | |
| 15 | "Marrón y hoguera" y "Mar y viento" | Lenguas de fuego sobre un campo marrón; flujo de mar con hebras oliva. Ninguna se parece a un paisaje ni a una obra concreta: si algo recuerda a una, apúntalo | |
| 16 | A oscuras, en la mesilla, la página pintada | Se lee como papel, no como pantalla: nada ilumina el cuarto. Si deslumbra, apúntalo: el velo es del 35 % en el Horizonte y del 75 % en los bordes | |
| 17 | A las 20:59 con la página delante y sonando, espera a las 21:01 | A las 21:00 la pintura se funde en 2 s (0,25 s con Reducir movimiento) y no vuelve; tampoco al pausar y dar Play otra vez, ni a las 07:00 si la app sigue delante | |
| 18 | Entra en Noche de día y vuelve a la página; después, la página nocturna de noche | Noche, Madrugada y la página nocturna son negras como hoy. Al salir de la página nocturna tocando el nombre, la pintura vuelve solo si es de día | |
| 19 | Bloquea el iPhone con la página pintada delante y desbloquea | Al volver de día, la pintura nace otra vez en unos 2 s; de noche, no | |
| 20 | Ajustes › día › Pintura › Nunca; luego De día | Con Nunca la página es negra de día, Capas no lleva reglas y Mezclas no lleva bandas; con De día vuelven | |
| 21 | Ajustes del iPhone › Accesibilidad: Aumentar contraste; Reducir movimiento; los dos | Con contraste: sin pintura ni reglas. Con movimiento: pintura quieta, sin respiración ni Marea. Con los dos: Ajustes dice "Nunca" y la nota de debajo explica por qué; al apagar uno de los dos vuelve | |
| 22 | Con VoiceOver, recorre la página y Capas | Ni la ventana ni las reglas se nombran; la fila de Ajustes lee "Pintura" y su valor | |
| 23 | Tamaño de texto AX3 | La ventana mide 120 pt y las filas siguen en pantalla; el texto que entra en la ventana sigue legible | |
| 24 | Abre la app a las 22:30 sin pulsar Play; a las 10:00 del día siguiente vuelve a ella y pulsa Play | Hay pintura: el cerrojo nocturno solo lo echa un fundido visto (paso 17), y volver al frente por el día lo abre. Lo mismo si la página se fundió a las 21:00 y el iPhone se bloqueó: a la mañana siguiente, al desbloquear de día, la pintura nace otra vez | |
| 25 | Carga "Mar y viento" de día | Las hebras del viento van solo en las dos tintas oliva oscuras, al 70 %, también dentro de la banda: ningún trazo pajizo o trigo sobre el azul | |

### 11.1 Medida de batería con MetricKit (condición de envío, D-58)

Ninguna cifra de batería se publica hasta tenerla. La app ya escucha MetricKit (`PaintMetricsSubscriber`): cada día iOS entrega el resumen del anterior y la app guarda la luminancia media de píxel (`MXDisplayMetric.averagePixelLuminance`) y la CPU (`MXCPUMetric`) en `Documents/paint-metrics.json` del contenedor y en las preferencias, sin red. El simulador no entrega nunca un resumen: solo vale un iPhone.

| # | Paso | Esperado | Resultado |
|---|---|---|---|
| 1 | Una tarde, de 20:00 a 21:00, deja la página de día pintada y sonando con la pantalla encendida (brillo fijo, anota el nivel) | A las 21:00 la pintura se funde sola | Batería de ___ % a ___ % |
| 2 | Otra tarde igual, mismo brillo, con Ajustes › Pintura › Nunca | Página negra toda la hora | Batería de ___ % a ___ % |
| 3 | Al día siguiente de cada una, abre la app o léelo del contenedor (Xcode › Devices › descargar el contenedor › `Documents/paint-metrics.json`); en una build de depuración, `-paintMetricsDump` lo imprime al arrancar | Dos muestras con `averagePixelLuminance` y `cpuSeconds` del día pintado frente al negro | Luminancia ___ frente a ___; CPU ___ s frente a ___ s |

Si la hora pintada cuesta más de un punto de batería que la negra, o la luminancia media del día pintado dobla la del negro, se sube el velo o se reduce la ventana a 180 pt antes de enviar; el ajuste "Nunca" es la salida si la medida sale mal.

### 11.2 Prueba de cinco segundos (condición de envío, D-58)

Diez personas, una a una, con el iPhone en la mano: la página de día pintada y sonando ("Rosa y lluvia") y, al lado o después, la misma página sin pintura (Ajustes › Pintura › Nunca). Cinco segundos cada una y una sola pregunta: "¿qué hace esta app?". Apunta la respuesta tal cual.

| Persona | Con pintura | Sin pintura |
|---|---|---|
| 1 a 10 | | |

Si más de tres dicen "fondos", "pinturas" o "cuadros" con la pintura, se sube el velo o se reduce la ventana a 180 pt antes de enviar (exploración 12 §7 fase 3).

## 12. Resumen para Claude

| Prueba | Pasó entera | Pasos que fallaron | Notas |
|---|---|---|---|
| 1. Noche entera | | | Batería: de ___ % a ___ % en ___ h |
| 2. Interrupciones | | | |
| 3. Auriculares | | | |
| 4. Bloqueo y Noche | | | |
| 5. Pantalla de bloqueo | | | |
| 6. Atajos, español | | | |
| 6. Atajos, inglés | | | |
| 7. VoiceOver | | | |
| 8.A Tienda local | | | |
| 8.B Sandbox | | | |
| 9. Prueba de 7 noches | | | |
| 10. Actualización | | | |
| 11. Pintura: bandas, ventana y reglas | | | |
| 11.1 Batería con MetricKit | | | Pintada ___ % · negra ___ % |
| 11.2 Cinco segundos | | | ___ de 10 dicen "fondos" |

Lo que Claude hace después: corregir cada "no" (paquete S-11), actualizar `docs/agents/ESTADO.md` quitando de "sin verificar" lo que hayas visto, y ajustar las notas de revisión si algo de lo que afirman no se cumple en el iPhone.
