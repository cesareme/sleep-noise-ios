# Oportunidades competitivas después de 1.0 (19-11-2026)

Documento de decisión. Responde a una sola pregunta: qué construir después de 1.0 para competir mejor contra BetterSleep y contra los líderes de suscripción, sin romper lo que hace distinto al producto. Se apoya en los tres documentos del 16-11-2026 (`INVESTIGACION-MERCADO-SUENO`, `COMPETIDORES`, `FUNCIONES-PRIORIZADAS`) y en cinco barridos nuevos hechos el 19-11-2026 (competidores mayo-noviembre de 2026, reseñas y foros posteriores al 01-06-2026, negocio de pago único, plataforma Apple y DSP, ciencia 2020-2026). No repite lo ya escrito: lo cita por sección y añade lo que cambia. Cada dato lleva su fuente en §9; VERIFICADO significa leído en la fuente con fecha, ESTIMACIÓN significa deducción o fuente secundaria.

Convenciones: los ids entre acentos graves (`timbre`, `watch`) son los del catálogo de FUNCIONES §3.1. Las fichas nuevas se numeran N-01 a N-23. Coste en semanas para una pareja (una persona de audio, otra de app) a dedicación completa: S = hasta 1 semana, M = 2 a 3, L = 4 a 6, XL = más de 6. El copy propuesto pasa AGENTS.md §5.4 y el lint de `docs/design/10-GUIA-DE-COPY.md` §0.4 y §0.5.

---

## 0. Resumen de una página

**La tesis en tres frases.** BetterSleep gana por catálogo y medición, y pierde por confianza: en noviembre de 2026 sus reseñas recientes hablan de paywall, suscripción y tarjeta en 15 de 20 en inglés y 8 de 20 en español, y su propia respuesta oficial del 17-11-2026 dice "BetterSleep is now a paid app". Los indies que compartían nuestra tesis técnica (síntesis, pocos MB) han añadido suscripción al lado del pago único entre agosto y noviembre de 2026 (Veil, Slo, Sonora), de modo que las cinco casillas de la lección 2 de COMPETIDORES (síntesis, seis capas, pago único puro, sin cuenta ni rastreo, pocos MB) siguen sin ocupante. La distancia no se crea con más texturas sino con tres cosas que un catálogo grabado y un modelo de suscripción no pueden copiar sin dejar de ser lo que son: fiabilidad nocturna demostrada, control del sonido con un gesto y una relación con el sistema (Siri, mesilla, muñeca) que no exige cuenta ni red.

**Las cinco apuestas que más distancia crean.**

1. **Siri AI con esquemas de audio de iOS 27** (N-01): "pon lluvia suave y viento" sin frase fija, con las once texturas y las mezclas guardadas como entidades `ambientSound`. Ninguna de las 40 fichas de competidores lo declara; la ventana se cierra en primavera de 2027, cuando Apple abra el envío a todos.
2. **Fiabilidad nocturna publicada como contrato con cifra** (N-02): "se para de noche" es la segunda queja del mercado y la primera entre usuarios de pago único (White Noise Lite, myNoise); nadie publica una cifra ni un diagnóstico local del motivo de cada parada.
3. **Timbre de un gesto y graves de verdad** (N-04): "más grave" es la petición de sonido más repetida de 2026 y el control espectral ya es estándar en los indies (Slo, Veil, Sonora, myNoise, Apple). Nosotros lo tenemos en 1.1; el mercado en 1.0.
4. **La mesilla completa desde el día uno de 1.1** (N-08, N-09, N-10): Live Activity con tres botones que aparece en el Watch sin app de Watch, widget de bloqueo y StandBy bajo tinte rojo, Centro de control, y "Dormir" como intent de larga duración que arranca con el Focus de Sueño. Dark Noise marca el listón; Veil y Portal lo alcanzaron en otoño de 2026.
5. **Honestidad como contenido** (N-12, N-13, N-07): cartas de novedades con texto real frente a las notas vacías de las cinco apps grandes, "Qué sabemos" con las cinco cifras de 2026 (REM y ruido continuo, respiración lenta, AAP, 10 lux, muesca contradictoria) y Madrugada sin hora ni cuenta atrás, que es la única función de la app cuyo diseño es literalmente la evidencia.

**Lo que no vamos a hacer aunque lo haga el mercado** (§5): tracker, puntuación o "sleep score"; contenido grabado o narrado; suscripción, paquete anual de funciones o rebajas con fecha; voz o coach por IA y mezcla por frase con modelo; binaurales, 432 y 528 Hz; alarma propia y "alarma por fase"; cuenta, servidor o sincronización fuera de iCloud del usuario; recordatorios que venden; CarPlay; detección de apnea o ronquidos como medición; importar audio propio; Pulso lento como textura.

---

## 1. Qué ha cambiado desde el 16-11-2026

Solo lo nuevo o lo que no estaba. Fuentes en §9 por grupo.

### 1.1 Plataforma

- **El sistema vigente es iOS 27, no iOS 26.** La página de novedades de Apple se titula "The 27 platform releases - June 2026"; Dark Noise 3.6 (12-09-2026), Portal 4.1.1 (28-10-2026) y White Noise 9.0.x citan iOS 27. La matriz de INVESTIGACION §6.1 ("SDK iOS 26.5") describe un estado anterior. VERIFICADO.
- **Siri AI abierta a todos los desarrolladores el 03-11-2026** en las betas de iOS 27.3, con esquemas de dominio Audio (`AppSchema.AudioEntity.ambientSound`, `AppSchema.AudioIntent.playAudio`, iOS 27.0). Según prensa (ESTIMACIÓN en los detalles): envío a la App Store en primavera de 2027, pruebas solo en builds de desarrollo o TestFlight interno, no disponible en la Unión Europea en iPhone, exige dispositivo con Apple Intelligence.
- **App Review**: revisión del 08/09-06-2026 de la guía 4.3(b) nombra categorías saturadas, entre ellas "sound effects" y "simple timers", que deben ofrecer "a meaningfully different or improved experience"; 4.5.3 nueva contra Live Activities usadas como spam; revisión del 16-10-2026 contra apps "bait-and-switch". La 3.1.1 (prueba de no suscripción con no consumible a nivel 0 "XX-day Trial") no cambia. VERIFICADO vía prensa y texto de la guía.

### 1.2 Competidores

- **BetterSleep** (ficha 7): 26.8 a 26.20 con trece notas de versión vacías entre mayo y noviembre de 2026; pantalla de pago con nueve precios en dos escalones (con y sin tracker), sin lifetime listado; evento de tienda con badge PREMIERE "Fall Back Into Better Sleep" ligado al cambio de hora y sin función nueva identificable; #75 en Health & Fitness gratis EE. UU. el 19-11 (#88 el 18-11); 4,7 con 391K; 313,9 MB; etiqueta de privacidad con rastreo. Respuesta oficial en Google Play del 17-11-2026: "BetterSleep is now a paid app". VERIFICADO.
- **Veil abandonó el pago único puro** el 14-08-2026 (24,99 $ una vez más anual 11,99 $ y mensual 2,99 $), añadió Studio (dar forma al ruido), rutinas gratis, nueve idiomas con español, y el 18-11-2026 piezas Pro "432 Hz" y "528 Hz"; su etiqueta declara Device ID para publicidad de terceros pese a decir "no ads". 5,0 con 26 valoraciones. **Slo** añadió inicio de sesión opcional (11-11-2026), profundidad por sonido en tres niveles y rastreo. **Sonora** añadió lifetime 79,99 $ y análisis espectral. Quedan como pago único puro y sin rastreo **myNoise** (19,99 / 14,99 $, Creation Mode de diez deslizadores, botón de compra en todas las pantallas desde el 29-10-2026) y **Nava** (2,99 $ por adelantado, 15,8 MB, "Data Not Collected", una valoración). VERIFICADO.

### 1.3 Demanda (muestra nueva: unas 125 reseñas de tienda del 29-09 al 18-11-2026, unos 60 comentarios de Hacker News 2025-2026, unos 30 mensajes de foros de padres y de Apple; Reddit inaccesible por tercera vez)

- **Confianza** sigue siendo la clase dominante y ha subido en BetterSleep tras el cambio de modelo (36 de 125 reseñas por paywall retroactivo o suscripción obligatoria). Lo que piden con palabras exactas: "upfront cost and no subscription" (06-11-2026), "Podrian poneer un par de sonidos gratuitos" (04-11-2026). En español pesan más la tarjeta y el alta que el precio (8 de 20 frente a 2 de 20).
- **"Se para de noche"** aparece con fuerza propia en las apps de pago único (9 de 22 en White Noise Lite, 3 de 20 en myNoise; la reseña más votada de la muestra, 35 votos, 30-10-2026: "playback will stop randomly ... you can't have the basics break").

### 1.4 Ciencia (2020-2026, lo que cambia una decisión)

- **Ruido rosa continuo y REM**: ensayo polisomnográfico de siete noches en *SLEEP* 2026 (n=25) halla reducción del REM dependiente de la dosis a 40 y 50 dBA; los tapones sí funcionan; los autores advierten contra el uso "widespread and indiscriminate" del ruido de banda ancha toda la noche. Convierte el fundido de "Hasta dormirme" y el −6 dB de Manto en decisiones con respaldo. Nivel B para el daño.

---

## 2. Mapa de demanda: lo que piden y nadie da, cruzado con lo que tenemos

Volumen = recuento dentro de las muestras del 16-11 (2.351 reseñas de 19 apps) y del 19-11 (unas 215 piezas nuevas), no tasa de mercado. Estado: **lo tenemos** (en 1.0), **a medias** (parcial o previsto), **no lo tenemos**.

| Petición en palabras del usuario | Volumen y cita | Quién lo da hoy | Estado nuestro | Ficha |
|---|---|---|---|---|
| Pagar una vez, sin suscripción, sin tarjeta para probar, sin preguntas al entrar | Clase dominante: 36 + 9 + 5 de 125 reseñas recientes; "Would be fine if the app had an upfront cost and no subscription model" (06-11-2026); "me voy a otra app más simple y que no me pida darme de alta" (28-11-2025) | myNoise y Nava (pago único); Portal (prueba sin tarjeta); nadie junta las tres | **Lo tenemos** (`precio-un-sku`, `prueba-sin-tarjeta`, sin cuenta). Falta el orden de la ficha en español: tarjeta, alta, precio | §6 |
| Que no se pare ni salte de noche, que no cambie de sonido tras una llamada | Segunda clase: 14 de 125; 37 reseñas US anteriores sobre bucles; "randomly close even though the timer hasn't run out, which now wakes me up" (23-08-2026) | Nadie lo publica; White Noise reescribió su motor (10-2026); TMSoft responde con cinco trucos | **A medias**: reglas C48/C49 en 1.0; sin cifra publicada ni diagnóstico del motivo | N-02, N-03 |
| Más grave, "más profundo", menos agudo | 6 menciones espontáneas en dos meses, la petición de sonido más repetida; "Rain recordings through a phone are often too high-pitched" | Slo (depth), Veil (Studio), myNoise (Pitch), Rain Rain (Soften), Apple (EQ); todos con panel | **A medias**: `timbre` condicionado a un spike; "Pared" y "Marrón y hoguera" existen | N-04 |
| Que no se repita, que no haya costura | 37 reseñas US sobre bucles; "if you can spot a single loop you have superhuman hearing" (sobre myNoise, 13-10-2025); Veil publica "months to repeat" (16-09-2026) | myNoise y Veil por síntesis; nadie lo demuestra | **Lo tenemos** en el motor; falta la demostración con cifra | N-05 |
| Mezclar varias a la vez y que las mezclas sobrevivan años | 58 reseñas US de fidelidad; "I created a mix 10 years ago and still play it every night"; "90% of my mixes are now locked"; tres reencuentros tras años en un mes (11-2026) | BetterSleep (y las rompe), myNoise (sin multicapa en móvil, Creation Mode de 10 en la app nueva), Rain Rain (3) | **Lo tenemos** (seis capas, formato v2, App Group); iCloud en 1.1 | N-18 |
| Controlar sin coger el teléfono: desde el reloj, la pantalla de bloqueo, la mesilla | 4 menciones de Watch siempre como mando ("basic audio control from the watch without picking up the phone"); widgets es la función más citada en reseñas positivas de Dark Noise; "a handy dimable digital clock mode" (10-11-2026) | Dark Noise (todo menos Watch), Portal, Veil, Nava; Watch autónomo solo Endel | **A medias**: Noche y widgets pequeños en 1.0; Live Activity, StandBy, Centro de control en 1.1; Watch en 1.2 | N-08, N-09, N-20 |
| Ruido grave continuo para el zumbido de oídos | 2 de 125 reseñas y 8 de 60 comentarios de HN sin que nadie preguntara; "the deep brown noise ... kept my Tinnitus at bay" (10-05-2025) | Cualquiera con marrón; muesca solo apps de tinnitus | **Lo tenemos** (marrón, Pared); muesca en 1.2 | N-22 |

Lectura: de ocho peticiones, siete ya están cubiertas o a medias en 1.0; lo que falta no son funciones nuevas sino **demostración** (cifra de fiabilidad, cifra de no repetición, consumo por noche) y **superficies** (Siri AI, mesilla, muñeca).

---

## 3. Catálogo de propuestas

Veinticinco fichas. Cuando un campo falta es porque no aplica (DSP propio), no depende de nada o no tiene riesgo de App Review. Campos: qué es; para quién (segmentos de INVESTIGACION §3.3: S1 enmascaradores crónicos, S2 rumiación e insomnio de mantenimiento, S3 usuarios Apple que compran diseño; además padres, turnos y viajeros); evidencia; encaje con el instrumento, el pago único y "sin red, sin cuenta, sin rastreo"; qué permite el DSP propio frente a un catálogo grabado; API y permisos; riesgo de App Review; coste; dependencias; versión propuesta; copy permitido en ES y EN; copy prohibido; y qué cambia respecto a FUNCIONES §3 cuando la ficha ya existía.

### N-01 · Siri AI con esquemas de audio (nueva; absorbe `spotlight-sugerencias`, 1.2)
- **Qué es.** Las once texturas y las mezclas guardadas se declaran como entidades `ambientSound` y "Dormir" y "Madrugada" como `playAudio`, de modo que "pon lluvia suave y viento media hora" llega a la app sin frase fija ni "en SleepNoise". Las mezclas se indexan en Spotlight como `IndexedEntity` para que el índice semántico de iOS 27 las encuentre descritas vagamente. Las cinco frases de 1.0 se conservan para iOS 17 a 26.
- **Para quién.** S3 primero (es la función que la prensa Apple enseña en vídeo); S2 de noche, porque hablar es más fácil que mirar.
- **Evidencia.** Dominio Audio y entidad `ambientSound` documentados (iOS 27.0); Siri AI abierta a todos el 03-11-2026; ninguna de las 40 fichas de competidores declara esquemas de audio; Dark Noise 3.6 solo soporta la Siri con conciencia de pantalla. VERIFICADO.
- **Encaje.** Total con pago único (es capacidad, no contenido). Tensión con "sin red": la app no abre red, pero Siri AI puede procesar la voz en la nube de Apple; se dice en "Lo que no hay" ("Siri decide dónde procesa tu voz; la app no envía nada"). Según prensa, la UE queda fuera: el beneficio inmediato es EE. UU., Reino Unido y Latinoamérica.
- **DSP propio.** Una mezcla pedida por voz se construye al instante con parámetros, sin descargar nada; un catálogo tendría que tener el fichero.
- **API y permisos.** `@AppEntity(schema: .audio.ambientSound)`, `@AppIntent(schema: .audio.playAudio)`, `IndexedEntity`, iOS 27.0, preview en 27.3. Sin permisos.
- **Riesgo App Review.** Bajo. La beta prohíbe enviarlo hasta primavera de 2027.
- **Coste.** M (2 a 3 semanas) más 1 de Spotlight.
- **Depende de.** Nada; comparte rama con N-10.
- **Versión.** Rama abierta en 1.1, envío en 1.2 en cuanto Apple lo permita.
- **Copy.** ES: "Pídeselo a Siri con tus palabras." EN: "Ask Siri in your own words." Prohibido: "IA", "AI", "inteligente", "smart", "entiende lo que necesitas".
- **Qué cambia.** `spotlight-sugerencias` (1.2, media 7,0) deja de ser una ficha menor: es el prerrequisito de Siri AI y sube a la misma entrega.

### N-02 · Contrato de fiabilidad nocturna con cifra y diagnóstico del motivo (`fiabilidad-nocturna`, `diagnostico`, `cuadro-mando`)
- **Qué es.** Publicar en "Cómo se genera" y en la ficha dos cifras medidas: horas seguidas con pantalla bloqueada sin corte y porcentaje de batería por noche de ocho horas. El informe local de diagnóstico registra el motivo de cada parada de sesión (interrupción, cambio de ruta, temporizador, suspensión) y se puede enviar por correo desde Ajustes. El buffer de audio se fija al máximo (0,093 s) y se mide con Instruments antes de publicar nada.
- **Para quién.** S1 (uso crónico toda la noche) y padres (Manto hasta la hora).
- **Evidencia.** Segunda queja del mercado (14 de 125) y primera en apps de pago único; la reseña más votada de la muestra (myNoise, 30-10-2026); White Noise 9.0 reescribe su motor y expone "tamaño de búfer" al usuario; el 100 % de las respuestas de los competidores a "se paró" son adivinanzas. VERIFICADO.
- **Encaje.** Es la definición del instrumento. Sin red: el informe sale por la hoja de compartir del sistema, nunca por `URLSession`.
- **DSP propio.** Un solo `AVAudioSourceNode` que renderiza once texturas en un bucle es más barato en CPU que decodificar ficheros; la cifra de batería puede ser mejor que la de cualquier catálogo y se puede demostrar.
- **API y permisos.** `setPreferredIOBufferDuration(0.093)`, `AVAudioSession.InterruptionReason` (incluye `routeDisconnected`, iOS 17), Energy Log de Instruments. Sin permisos.
- **Riesgo.** Ninguno. Cuidado con 4.5.3: la Live Activity solo mientras suena.
- **Coste.** S para el buffer y la medición; S-M para el motivo en el diagnóstico.
- **Depende de.** N-03 (la pausa de AirPods es un motivo de parada).
- **Versión.** Medición en la beta de 1.0; cifra publicada en 1.1 con "Cómo se genera".
- **Copy.** ES: "No se para. No se repite. No cambia de sonido si entra una llamada." EN: "It doesn't stop. It doesn't repeat. It doesn't change sound when a call comes in." Prohibido: "garantizado", "sueño ininterrumpido", "perfecto".
- **Qué cambia.** Las fichas de 1.0 fijan reglas; esta añade la cifra publicada y el motivo por parada, que es lo que ningún competidor tiene.

### N-03 · Pausa de AirPods al dormirse: fundido y una línea que la explique (C49)
- **Qué es.** La pausa que envía el sistema cuando los AirPods detectan sueño se trata como fundido de 3 s, nunca como corte; en Ajustes > Salida una línea dice que el ajuste existe, dónde está y que cortará el sonido a quien esté quieto aunque siga despierto; Manto por hora sigue sonando por el altavoz si el usuario lo elige.
- **Para quién.** S1 y S2 con AirPods Pro; es el usuario que paga 29,99 €.
- **Evidencia.** Ajuste activado por defecto según prensa (29-08-2025); hilo de foros de Apple (08/09-2026) con sesiones cortadas a los 15-20 min de quietud también en iOS 27 beta, sin API; `InterruptionReason` no tiene caso de sueño. VERIFICADO. Ninguna ficha de competidor lo menciona.
- **Encaje.** Total. Sin permisos ni red.
- **DSP propio.** El fundido se aplica en la ganancia maestra del render, sin cortar el stream.
- **API.** `MPRemoteCommandCenter.pauseCommand`, rampa de ganancia. Sin permisos.
- **Coste.** S (prototipo de una semana con AirPods Pro 2 o posteriores).
- **Versión.** Ahora, en la beta de 1.0.
- **Copy.** ES: "Si tus AirPods creen que duermes, el sonido se retira despacio." EN: "If your AirPods think you are asleep, the sound steps back slowly." Prohibido: "detecta que duermes" (no detectamos nada), "inteligente".

### N-04 · Timbre de un gesto y graves de verdad (`timbre`, `loudness-camas`)
- **Qué es.** La fila "Timbre" (Grave a Lejos) sobre el bus maestro, con tilt de ±6 dB por década y pasa-bajos de distancia, pasa de condicionada a comprometida; en 1.1 por capa. El extremo grave se diseña para altavoces pequeños (compensación de la caída bajo 150 Hz hasta el límite del transductor, medida en iPhone y HomePod mini), que es lo que el usuario llama "más profundo".
- **Para quién.** S1 (acúfenos y ronquidos viven en graves-medios), S3.
- **Evidencia.** "Más grave" es la petición de sonido más repetida de 2026 (6 menciones en dos meses); control espectral en 7 apps y en Apple; lección 6 de COMPETIDORES. VERIFICADO.
- **Encaje.** Total: un gesto, sin panel, sin números.
- **DSP propio.** Un catálogo grabado solo puede ecualizar; la síntesis puede regenerar la textura con más energía grave sin distorsión ni ruido de fondo del fichero.
- **API.** `AVAudioUnitEQ` o biquad propio en el hilo de render. Sin permisos.
- **Coste.** M (1 a 2 semanas en bus; 1 a 2 más por capa).
- **Depende de.** Spike I0-7 (ya previsto).
- **Versión.** 1.0 si el spike cabe antes del envío; si no, 1.0.1 (primera corrección tras el lanzamiento), nunca más tarde.
- **Copy.** ES: "Más grave, más lejos, con un dedo." EN: "Lower, farther, with one finger." Prohibido: "profundo", "deep sleep", "ecualizador", "EQ".
- **Qué cambia.** De "condicionado al spike" a "la segunda función donde más nos hemos quedado atrás en seis meses".

### N-05 · "Nunca se repite" demostrado con un test de diez horas (`nunca-se-repite`, C53)
- **Qué es.** El test de autocorrelación de CI pasa de 10 minutos a una ventana de 10 horas por textura y falla si aparece un pico de periodicidad; la cifra y el método se publican en "Cómo se genera" (sin el periodo del PRNG como reclamo). El Horizonte sigue siendo RMS real.
- **Para quién.** S1 y S3.
- **Evidencia.** 37 reseñas US sobre bucles y clics; Veil es el primero en poner un número ("months to repeat", 16-09-2026) sin demostrarlo; Sonora muestra espectros estáticos. VERIFICADO.
- **Encaje.** Total. Es hecho técnico, no promesa de sueño.
- **DSP propio.** Solo un generador puede afirmar ausencia de bucle y probarla; un catálogo solo puede alargar el fichero.
- **API.** Ninguna; test en CI con vDSP.
- **Riesgo.** Ninguno si el copy no promete efecto.
- **Coste.** S.
- **Versión.** 1.0 (test) y 1.1 (página).
- **Copy.** ES: "Se genera en tu iPhone y no se repite. Lo comprobamos con una prueba de diez horas." EN: "Generated on your iPhone and never repeated. We check it with a ten-hour test." Prohibido: "infinito", "tu cerebro nunca se acostumbra", cifras de años.

### N-06 · Arco de la noche: modulación lenta y regla de estacionariedad (nueva; amplía C24)
- **Qué es.** Envolventes de minutos y horas atadas al minuto del temporizador: la lluvia amaina, el fuego se asienta, el oleaje se alarga. Y una regla: después del fundido inicial no hay eventos discretos (truenos, chasquidos); el trueno y la hoguera bajan su densidad de eventos en Manto y Madrugada, y su ficha dice "no para toda la noche".
- **Para quién.** S1 y S2.
- **Evidencia.** Lo que despierta es lo nuevo, no lo continuo: voces desconocidas provocan más complejos K (*J Neurosci* 2021); el cerebro dormido se habitúa al fondo pero reacciona a eventos (*Sleep Med Rev* 2023); Endel ("bad dreams", "caos") y BetterSleep ("squeaking every 15 seconds") son el contraejemplo. Nivel B.
- **Encaje.** Total; es la antítesis del "paisaje evolutivo" de la competencia.
- **DSP propio.** Una grabación no puede amainar durante dos horas sin repetirse; un generador cambia parámetros con constante de tiempo de minutos.
- **API.** Ninguna. Sin permisos.
- **Riesgo.** Ninguno; el copy no dice "se adapta a tu cuerpo".
- **Coste.** M (1 a 2 semanas).
- **Depende de.** N-04 (comparte el bus).
- **Versión.** 1.1.
- **Copy.** ES: "La noche tiene su arco: lo que suena a las tres no es lo que sonaba a las once." EN: "The night has its own arc: what plays at three is not what played at eleven." Prohibido: "se adapta a ti", "evoluciona contigo", "adaptativo".

### N-07 · Madrugada sin hora ni cuenta atrás (`madrugada`, C60)
- **Qué es.** En Madrugada la pantalla no muestra reloj ni "quedan X minutos"; el Horizonte quieto es el único indicador; la Live Activity de Madrugada no lleva cuenta atrás; al disolverse no hay frase. La línea de salida de la cama ("si no vuelve el sueño, levantarse un rato a algo aburrido suele ayudar más que seguir en la cama") vive en "Qué sabemos", no en la pantalla.
- **Para quién.** S2 (50-59 % de malos dormidores vuelven a la app de madrugada).
- **Evidencia.** Mirar el reloj a las tres se asocia con más frustración y más fármacos (N=4.886, 2023); AASM 2021; no existe ensayo de sonido para volver a dormir, así que la conducta es lo único respaldado. Nadie tiene un modo "son las 3" sin pantalla brillante.
- **Encaje.** Total: es la función cuyo diseño es la evidencia.
- **DSP propio.** Receta fija (océano bajo con Marea a 8/min) generada al instante sin cargar nada.
- **API.** Ninguna. La hora del sistema sigue en la pantalla de bloqueo (no se puede ocultar).
- **Coste.** S (texto y ocultar el contador).
- **Depende de.** N-08 (variante de Live Activity sin contador).
- **Versión.** 1.0 si cabe en Noche; si no, 1.0.1.
- **Copy.** ES: "Madrugada no enseña la hora." EN: "Small hours does not show the time." Prohibido: "vuelve a dormirte en minutos", "SOS", "detecta tus despertares".
- **Qué cambia.** C60 fijaba "nada al terminar" y hora opt-in; lo nuevo es la ausencia de cuenta atrás y la cita que lo sostiene.

### N-08 · Live Activity con tres botones, diseñada para el Watch y el Mac (`live-activity-standby`)
- **Qué es.** La Live Activity de 1.1 lleva los tres botones que se usan de noche (parar, +15 min, Madrugada) y seis estados; el mismo diseño aparece en el Smart Stack del Watch (watchOS 11) y en la barra de menús del Mac sin código extra. En StandBy, tocarla expande a pantalla completa. Si Manto supera 8 h, la pantalla avisa de que la Live Activity terminará antes que el sonido.
- **Para quién.** S2 y S3; la petición de Watch es siempre "sin coger el teléfono".
- **Evidencia.** Live Activity en Dark Noise (2023), Portal (10-2026), Nava, Sonora; Smart Stack del Watch desde junio de 2024 y Mac desde junio de 2025 (VERIFICADO en ActivityKit); 4 peticiones de mando desde el reloj. Lección 13.
- **Encaje.** Total; adelanta a 1.1 el "+15 min desde la muñeca" que estaba en 1.2.
- **API.** ActivityKit, 8 h activas y 12 h en bloqueo; Dynamic Island apaisada (WWDC26). Sin permisos.
- **Riesgo.** 4.5.3: solo mientras suena, terminación `.immediate` al acabar el fundido.
- **Coste.** M.
- **Versión.** 1.1.
- **Copy.** ES: "Parar, quince minutos más o Madrugada, sin desbloquear el teléfono." La palabra "desbloquear" está vetada en ES: variante "sin encender el teléfono". EN: "Stop, fifteen more minutes, or Small hours, without waking the phone." Prohibido: "Night mode", "widget inteligente".
- **Qué cambia.** De dos botones a tres (Madrugada) y diseño pensado para el Watch desde el principio.

### N-09 · Superficies de bloqueo: widget de bloqueo, StandBy en rojo, Centro de control (`widgets`, `control-center-boton-accion`)
- **Qué es.** Widget rectangular e inline de pantalla de bloqueo con fondo removible y una sola tinta (se lee bajo el tinte rojo de StandBy); widget mediano en 1.1; control de Centro de control y botón de Acción con símbolos on/off. Incluye la comprobación de Noche en el iPhone Duo medio abierto sobre la mesilla (Dark Noise, Portal y Nava ya publican diseños para él; Nava lo llama "half-folded nightstand mode"). Cierra la discrepancia entre FUNCIONES (Centro de control en 1.0) y PLAN-SIMPLE §9 (en 1.1).
- **Para quién.** S3 y cualquiera que use la app a oscuras.
- **Evidencia.** Widgets en 9 de 18 apps analizadas, función más citada en reseñas positivas de Dark Noise; Centro de control en Dark Noise (09-2024), Portal (4.0) y Veil (10-2026): en 1.0 seríamos la única app de sonido reciente sin él; StandBy diseñado para la noche: nadie (lección 13). VERIFICADO.
- **Encaje.** Total.
- **API.** WidgetKit, `ControlWidgetButton/Toggle` (iOS 18; en watchOS y macOS desde junio de 2025). Sin permisos.
- **Coste.** S-M (el control), M (widgets).
- **Versión.** Widget de bloqueo y control en 1.0 si el corte de la semana 14 lo permite (FUNCIONES), si no en 1.0.1; StandBy y mediano en 1.1.
- **Copy.** ES: "Dormir, desde la pantalla de bloqueo." EN: "Sleep, from the Lock Screen." Prohibido: "widget inteligente", "acceso rápido premium".
- **Qué cambia.** Se adelanta el widget de bloqueo (la función donde más nos hemos quedado atrás, junto a Timbre) y se fija de una vez en qué versión va el Centro de control.

### N-10 · "Dormir" como intent de larga duración y filtro del Focus de Sueño (`focus-sueno`, `siri-atajos`)
- **Qué es.** El intent "Dormir" se declara `LongRunningIntent` con progreso del temporizador, de modo que la automatización "al activar Sueño" arranca la mezcla sin abrir la app y sin que el sistema la mate. Un `SetFocusFilterIntent` hace que, en el Focus de Sueño, la app abra en Noche con brillo mínimo. Guía de dos pantallas en Ajustes para configurar ambas.
- **Para quién.** S2 y S3.
- **Evidencia.** Apple permite desde iOS 26 encender Sonidos de fondo con un Focus; ninguna app tercera ofrece lo mismo con mezclas propias (lección 13 y barrido de competidores §6.5); `LongRunningIntent` nuevo en junio de 2026. VERIFICADO.
- **Encaje.** Total; una rutina que no notifica.
- **API.** `LongRunningIntent` (iOS 27; en iOS 17 a 26 el intent actual), `SetFocusFilterIntent` (iOS 16). Sin permisos.
- **Coste.** S-M.
- **Depende de.** N-01 (misma rama de App Intents).
- **Versión.** 1.1.
- **Copy.** ES: "Cuando activas Sueño, empieza tu mezcla." EN: "When Sleep comes on, your mix begins." Prohibido: "rutina inteligente", "automático" sin decir qué lo dispara.
- **Qué cambia.** `focus-sueno` (1.1, media 7,3) gana el arranque sin abrir la app, que antes dependía del intent corto.

### N-11 · Capa: debajo de otro audio (`debajo-de-otro-audio`)
- **Qué es.** Modo "Capa" (`mixWithOthers`, sin ducking del otro audio) y modo "Solo", con el maestro propio; el estado de sesión se muestra en una línea.
- **Para quién.** S3 de día (estudio), misofonía, quien duerme con podcast.
- **Evidencia.** Tres citas de dos extremos (podcast y música); "that feature alone makes this app indispensable" (Dark Noise); BetterSleep "bleed over". VERIFICADO.
- **Encaje.** Total. Es el único paso hacia el día que no convierte la app en productividad.
- **DSP propio.** La ganancia maestra es nuestra, no del reproductor del sistema.
- **API.** `AVAudioSession.CategoryOptions.mixWithOthers`. Sin permisos.
- **Coste.** M.
- **Depende de.** N-02 (el estado de sesión entra en el diagnóstico).
- **Versión.** 1.1 (sin cambio).
- **Copy.** ES: "Debajo de tu podcast, a su propio volumen." EN: "Under your podcast, at its own level." Prohibido: "foco", "concentración" como nombre, "productividad".

### N-12 · Cartas de novedades con contenido real (`cartas-novedades`)
- **Qué es.** Cada versión lleva una carta de novedades dentro de la app (qué cambió, por qué, qué se midió), y las notas de versión de la tienda dicen lo mismo en español e inglés. Sin fechas de venta.
- **Para quién.** S3 y prensa.
- **Evidencia.** BetterSleep, Calm, Headspace, Sleep Cycle y ShutEye publican notas vacías e idénticas semana tras semana (13, 7, 16, 25 y 25 versiones en 2026); los indies que escriben con contenido son los que la prensa cita. VERIFICADO.
- **Encaje.** Total; coste casi nulo.
- **API.** Ninguna. Sin permisos.
- **Riesgo.** Ninguno (sin precios ni superlativos).
- **Coste.** S por versión.
- **Versión.** 1.1 (sin cambio), con la primera carta escrita ya para 1.0.
- **Copy.** ES: "Qué cambió y por qué, en una carta." EN: "What changed and why, in a letter." Prohibido: "¡", "increíble", "mejoras".

### N-13 · "Qué sabemos" con las cinco cifras de 2026 (`que-sabemos`)
- **Qué es.** La página añade: REM y ruido continuo (*SLEEP* 2026) como razón del fundido; la revisión de respiración lenta (2026) con la asimetría autoinformado frente a objetivo; la frase literal de la AAP sin cifra; los 10 lux melanópicos del consenso de 2022; la contradicción de la muesca (2024-2025). Más dos líneas honestas: los tapones hacen más que cualquier sonido para el ruido fuerte, y mucha gente con zumbido duerme con un ruido grave de fondo sin que eso trate nada.
- **Para quién.** S1, S2, prensa y App Review.
- **Evidencia.** Las cinco fuentes de §1.4; Brain.fm admite no tener estudio de sueño; ninguna app expone una contradicción científica. VERIFICADO.
- **Encaje.** Total; la honestidad como rasgo de gama alta.
- **API.** Ninguna.
- **Riesgo.** Bajo si el lint pasa; la página deja de estar exenta (C54).
- **Coste.** S.
- **Versión.** 1.1 según PLAN-SIMPLE §9 (FUNCIONES la tenía en 1.0; se acepta 1.1 y se escribe ya).
- **Copy.** ES: "El sonido baja solo. El ruido toda la noche no ha demostrado ventaja y a cierto volumen cambia la estructura del sueño." EN: "The sound fades on its own. All-night noise has shown no advantage, and at some volumes it changes sleep structure." Prohibido: "sueño reparador", "ondas lentas", "limpia tu cerebro", "clínicamente".

### N-14 · Papel bloqueado por la ventana nocturna (`papel`)
- **Qué es.** El modo claro de 1.1 no se activa entre 21:00 y 07:00 aunque el sistema esté en claro; la misma constante `NightWindow` que bloquea la venta.
- **Para quién.** Todos.
- **Evidencia.** Consenso *PLoS Biology* 2022: máximo 10 lux melanópicos desde tres horas antes de acostarse; una pantalla blanca sola puede superar 60. Nivel A.
- **Encaje.** Total y barato.
- **API.** `preferredColorScheme` condicionado. Sin permisos.
- **Coste.** S.
- **Depende de.** `papel` (1.1).
- **Versión.** 1.1.
- **Copy.** ES: "De noche, negro de verdad." EN: "At night, truly black." Prohibido: "protege tu melatonina", "filtro de luz azul", "modo circadiano".

### N-15 · Manto con aviso de duración y fundido espectral (`temporizador-dos-modos`, `retirada-de-manto`, C22)
- **Qué es.** Cuando la hora de fin de Manto implica más de 8 h de sonido continuo, una línea lo dice al fijarla (sin impedirlo); el −6 dB a los 45 min se mantiene; la retirada de Manto y el final de "Hasta dormirme" oscurecen el timbre además de bajar la ganancia (fundido espectral).
- **Para quién.** S1 (Manto) y padres.
- **Evidencia.** *SLEEP* 2026 (REM dependiente de la dosis a 40-50 dBA toda la noche); el mecanismo del despertar es el salto de nivel (*Sleep Med* 2005; *HERD* 2026); no hay ECA de fundido frente a corte: se publica como ingeniería. Nivel B.
- **Encaje.** Total; Manto existe por el usuario que lo pide, pero nunca como argumento de venta.
- **DSP propio.** El fundido espectral regenera la textura más oscura; un catálogo solo puede filtrar el fichero.
- **API.** Ninguna. Sin permisos.
- **Coste.** S (aviso), S-M (fundido espectral).
- **Depende de.** N-04.
- **Versión.** 1.1.
- **Copy.** ES: "Nunca se corta de golpe." EN: "It never stops dead." Prohibido: "se apaga cuando te duermes", "sigue tu ciclo", "modo noche completa".
- **Qué cambia.** `retirada-de-manto` (1.1) gana la dimensión espectral y el aviso de 8 h, con cita de 2026.

### N-16 · Textura "Secador" (`texturas-con-criterio`)
- **Qué es.** Ruido filtrado con resonancia de motor y modulación lenta de velocidad, gratuita (la lista gratis solo crece), con trims y test de autocorrelación como las demás.
- **Para quién.** Padres (viaje); S1 como alternativa al ventilador.
- **Evidencia.** "settles immediately to the sound of the hair dryer" y el miedo a dejar el secador encendido (foro de padres, 30-01-2026); apps de bebé lo tienen; ninguna app de sonido de adultos. VERIFICADO.
- **Encaje.** Total con DSP; cero con contenido grabado.
- **DSP propio.** Un secador grabado se repite y lleva ruido de sala; el sintetizado es estacionario y sin costura.
- **API.** Ninguna.
- **Riesgo.** Ninguno; sin la palabra "bebé" en la promesa (INVESTIGACION §3.3).
- **Coste.** S-M.
- **Versión.** 1.1.
- **Copy.** ES: "Secador: el ruido que calma en el baño, sin el calor." La palabra "calma" no está vetada, pero "relaja" sí: no usar la variante. EN: "Hair dryer: the bathroom hum, without the heat." Prohibido: "para bebés", "seguro para la cuna".

### N-17 · iCloud de mezclas sin cuenta (`mezclas-que-sobreviven`, C09)
- **Qué es.** Las mezclas guardadas viajan entre iPhones del mismo Apple ID con iCloud Key-Value Store; sin servidor propio ni cuenta; la restauración de compra en la primera pantalla.
- **Para quién.** Todos; el comprador que vuelve a los tres años.
- **Evidencia.** Tres reencuentros tras años en un mes (myNoise 17-11-2026, BetterSleep 15-11-2026, Endel 06-11-2026); lección 5 (uso episódico y por reinstalación); Slo añadió cuenta para lo mismo y pierde su argumento. VERIFICADO.
- **Encaje.** Total si es iCloud del usuario; AGENTS §5.11 veta iCloud en 1.0, no después.
- **API.** `NSUbiquitousKeyValueStore`. Capability de iCloud; sin permiso de usuario.
- **Coste.** M.
- **Depende de.** Formato v2 (1.0).
- **Versión.** 1.1 (sin cambio).
- **Copy.** ES: "Vuelve cuando lo necesites; tus mezclas te esperan." EN: "Come back when you need it; your mixes are waiting." Prohibido: "sincronización en la nube", "cuenta".

### N-18 · Noches con Marea, sin racha (nueva)
- **Qué es.** En Marea, una línea discreta con el número total de noches en que se ha usado ("Marea · 23 noches"), sin días seguidos, sin reinicio, sin culpa, sin aviso. Se presenta como "la Marea se nota con las semanas".
- **Para quién.** S2.
- **Evidencia.** Los estudios con efecto subjetivo duran 28 a 30 días (*Sleep Med Rev* 2026); FUNCIONES §4.2 descarta rachas, insignias y contador de noches por presión y culpa. Lo que cambia la razón: no es racha ni meta, es un total que no se rompe; si el dueño lo considera igual de culpabilizador, se descarta.
- **Encaje.** Encaja con el pago único (no hay prisa por demostrar nada en 7 noches). Tensión con "sin puntuación": por eso es un recuento, no una cifra de sueño.
- **API.** Contador local. Sin permisos.
- **Coste.** S.
- **Versión.** 1.1, decisión del dueño (§8).
- **Copy.** ES: "La Marea se nota con las semanas." EN: "The Tide shows with the weeks." Prohibido: "racha", "reto", "no pierdas tu progreso", "streak".

### N-19 · Marea en la muñeca: háptica y mando (`watch`, C28)
- **Qué es.** App de Watch mínima: parar, +15 min, Madrugada, y la Marea como háptica a seis respiraciones por minuto durante 15 min con la pantalla apagada (sesión extendida tipo Mindfulness). Sin audio en el Watch, sin pulso en vivo, sin tracking.
- **Para quién.** S2 y S3.
- **Evidencia.** 4 peticiones, todas de mando ("without picking up the phone"); Dark Noise, Portal, Veil, Slo, myNoise, Nava y Sonora no tienen Watch; solo Endel lo tiene autónomo; `WKExtendedRuntimeSession` Mindfulness corre 1 h en primer plano con háptica. VERIFICADO.
- **Encaje.** Total; el alcance de mando abarata el coste.
- **DSP propio.** No aplica (la háptica sigue la fase de la Marea del iPhone).
- **API.** WatchKit, `WKExtendedRuntimeSession(.mindfulness)`, Watch Connectivity. Background Modes del Watch.
- **Riesgo.** Bajo.
- **Coste.** L (4 a 6 semanas).
- **Depende de.** N-08 (la Live Activity ya cubre el mando sin app).
- **Versión.** 1.2 (sin cambio), solo si 1.1 confirma demanda en reseñas.
- **Copy.** ES: "La Marea en la muñeca, sin mirar." EN: "The Tide on your wrist, without looking." Prohibido: "mide tu pulso", "detecta tu sueño", "smart".
- **Qué cambia.** Alcance explícito: mando y háptica, no altavoz ni sensores.

### N-20 · HealthKit solo lectura: "Tu nivel de esta noche" y respiración de partida (`healthkit-solo-lectura`)
- **Qué es.** Con permiso, una página muestra la exposición sonora por auriculares que el sistema ya midió con AirPods o Beats y la compara con el techo que el usuario eligió; la Marea puede arrancar a la frecuencia respiratoria nocturna real (12/min sin permiso). La app no mide ni escribe nada salvo, opcionalmente, `mindfulSession`.
- **Para quién.** S1 (volumen peligroso es queja documentada) y S2.
- **Evidencia.** `headphoneAudioExposure` desde iOS 13; no hay API para el horario de sueño de Salud (foros de Apple); 5.1.1(ii): la función Pro no puede depender del permiso. VERIFICADO.
- **Encaje.** Los datos quedan en el iPhone; exige política de privacidad y texto de uso.
- **DSP propio.** La Marea ajusta su ritmo inicial sin cargar nada.
- **API.** HealthKit lectura (`headphoneAudioExposure`, `respiratoryRate`, `sleepAnalysis`). `NSHealthShareUsageDescription`.
- **Riesgo.** Medio (5.1.1, 1.4.1 si el copy sugiere medición propia).
- **Coste.** M (1 a 2 semanas la página; 3 a 4 el conjunto).
- **Versión.** 1.2 (adelantada desde 2.0 por la página de exposición, que es honesta y barata).
- **Copy.** ES: "Lo que tu iPhone ya midió esta noche, junto al techo que elegiste." EN: "What your iPhone already measured tonight, next to the ceiling you chose." Prohibido: "protege tu oído", "seguro", "mide tu sueño".
- **Qué cambia.** De 2.0 a 1.2, con la exposición por auriculares como primer uso.

### N-21 · Enmascarador con muesca, con la contradicción expuesta (`muesca`)
- **Qué es.** Barrido guiado por oído con techo de nivel, muesca de un tercio de octava sobre cualquier textura, "punto de mezcla" (nivel igual o justo por debajo del pitido) con aviso de que subir más no ayuda. La pantalla "Mi pitido" lleva la frase de confort y "Qué sabemos" expone los tres metaanálisis contradictorios.
- **Para quién.** S1 (11,6 % con acúfeno molesto, Apple Hearing Study 2026).
- **Evidencia.** Demanda real pero de app de tinnitus (2 de 125 reseñas, 8 de 60 comentarios de HN); metaanálisis 2024 sin efecto, 2025 con efecto, carta al editor; nadie la hace sobre síntesis con UI mínima. VERIFICADO.
- **Encaje.** Total si el copy dice "no trata nada".
- **DSP propio.** La muesca se aplica antes de generar la textura, sin el ruido de fondo del fichero que una grabación arrastra dentro de la banda.
- **API.** `AVAudioUnitEQ` o biquad propio. Sin permisos.
- **Riesgo.** Medio si el copy insinúa tratamiento; bajo con la fórmula aprobada.
- **Coste.** M (prototipo cerrado con cinco personas antes de publicar).
- **Depende de.** N-04.
- **Versión.** 1.2 (sin cambio), prototipo en 1.1.
- **Copy.** ES: "La muesca quita del sonido la banda de tu tono. No trata nada: acompaña." EN: "The notch removes the band where your tone sits. It treats nothing: it keeps you company." Prohibido: "reduce el tinnitus", "alivio", "terapia", "TRT".

### N-22 · Modo cuna con la frase literal de la AAP (`modo-cuna`)
- **Qué es.** Techo de ganancia interno, aviso de distancia con la frase literal de la AAP (sin cifra), temporizador por defecto obligatorio de 45 min con retirada gradual, Manto no disponible, texturas "shhh", lluvia lejana y secador; sin "latido uterino".
- **Para quién.** Padres (el único subsegmento que monetiza en el top 25 hispano).
- **Evidencia.** AAP 21-10-2023 (política sin cifra); revisión *Sleep Med* 2024 (máquinas de hasta 91 dB, limitar intensidad y duración); padres de 2026 compran hardware por "sin pantalla, sin wifi, toda la noche" y usan la app en viaje. VERIFICADO.
- **Encaje.** Total; la seguridad acústica como argumento, no la palabra "bebé" en la promesa.
- **DSP propio.** El techo se aplica en el render, no depende del volumen del sistema; un catálogo no puede garantizar que ningún fichero supere el techo.
- **API.** Ninguna. Sin permisos.
- **Riesgo.** Bajo si no se dice "seguro para bebés" ni "recomendado por pediatras".
- **Coste.** M.
- **Depende de.** N-16.
- **Versión.** 1.2 (sin cambio).
- **Copy.** ES: "Para la cuna, lejos y bajo. Este modo limita el nivel y se apaga solo. No es un producto sanitario." EN: "For the cot, far and low. This mode caps the level and switches itself off. Not a medical product." Prohibido: "seguro para bebés", "50 dB como la AAP", "como en el útero", "ayuda a tu bebé a dormir toda la noche".

### N-23 · Fundido por quietud sin permiso (`fundido-por-quietud`, C37)
- **Qué es.** Con el iPhone bajo la almohada o en la cama, el acelerómetro crudo a 10-20 Hz detecta veinte minutos de quietud y arranca el fundido; en la mesilla se degrada al temporizador. Opt-in.
- **Para quién.** S2.
- **Evidencia.** `CMMotionManager` no exige `NSMotionUsageDescription` (solo actividad, podómetro, grabador y cabeza); todo el hardware premium ofrece "apagar al dormirte" y Apple lo hace con AirPods. VERIFICADO. Valor depende del spike I0-5b.
- **Encaje.** Total: sin permiso, sin dato guardado.
- **DSP propio.** El fundido es una rampa del render.
- **API.** `CMMotionManager`. Sin permisos.
- **Riesgo.** Bajo; el copy no dice "se apaga cuando te duermes".
- **Coste.** M (1 a 2 semanas).
- **Depende de.** Spike I0-5b.
- **Versión.** 1.2 (sin cambio).
- **Copy.** ES: "Si llevas un rato quieto, el sonido se va bajando." EN: "If you have been still for a while, the sound eases down." Prohibido: "detecta que duermes", "sensor de sueño".
- **Qué cambia.** Se confirma que no hace falta texto de permiso, lo que quita la pregunta al usuario.

### N-24 · Guía de nivel con el micrófono, hacia el tramo bajo (`guia-nivel-microfono`)
- **Qué es.** Diez segundos de medición del fondo de la habitación al iniciar (LAeq de un escalar, el buffer se descarta), propuesta de nivel fondo + 5 dB con techo, y texto de que subir más no añade nada. Nunca continuo.
- **Para quién.** S1.
- **Evidencia.** Mecanismo del salto de nivel (A); *SLEEP* 2026 pide el tramo bajo (40 antes que 50 dBA); punto naranja inevitable; eco cancelado solo en iPhone de 2024+ con iOS 18.2. VERIFICADO.
- **Encaje.** Tensión: el micrófono y el punto naranja contradicen "sin rastreo" en la percepción aunque no en los hechos. Por eso 10 s y nunca de fondo.
- **DSP propio.** El nivel se aplica como ganancia objetivo en el render.
- **API.** `AVAudioEngine.inputNode` tap, `.playAndRecord`. `NSMicrophoneUsageDescription`.
- **Riesgo.** Medio (5.1.1 si el texto no es impecable).
- **Coste.** M más 1 semana de batería.
- **Versión.** 2.0 (sin cambio), condicionada.
- **Copy.** ES: "Mide la habitación diez segundos y propone un nivel. No graba ni guarda nada." EN: "Measures the room for ten seconds and suggests a level. Nothing is recorded or kept." Prohibido: "adaptativo", "menos despertares", "escucha tu habitación".

### N-25 · Studio: el segundo instrumento como segundo pago único (`modelo-2-0-studio`)
- **Qué es.** En 2.0, un segundo no consumible con las funciones grandes (Escena, Watch con Marea háptica, adaptación al ruido), con reglas públicas antes de venderlo: nada se mueve de Pro a Studio, los antiguos conservan todo, Family Sharing también, y "para siempre" se define por escrito como "esta versión y sus actualizaciones mientras existan".
- **Para quién.** El negocio: la única recurrencia honesta sin suscripción.
- **Evidencia.** Dark Noise 3 (regalo a antiguos, elogiado) frente a Calendar 366 v3 (app aparte sin camino, castigado, abril de 2026); Screen Studio retiró su licencia y lo llamó error (01-10-2025); Overcast y Dark Noise acabaron en suscripción por no tener segunda compra. VERIFICADO.
- **Encaje.** Total si las reglas se publican antes; rompe la confianza si se publican después.
- **API.** StoreKit 2, segundo producto. Sin permisos.
- **Riesgo.** Bajo.
- **Coste.** L (producto) y S (reglas).
- **Depende de.** 18 meses de ventas de Pro.
- **Versión.** 2.0 (sin cambio); las reglas se escriben en la web E8 en 1.1.
- **Copy.** ES: "Lo grande se paga una vez más. Lo tuyo sigue siendo tuyo." EN: "The big things are paid once more. What is yours stays yours." Prohibido: "vitalicio", "lifetime", "upgrade", "pase".
- **Qué cambia.** La frase sobre "para siempre" se escribe antes de que alguien la pregunte (error documentado de Notability y Screen Studio).

---

## 4. Priorización

### 4.1 Tabla

Cada criterio de 0 a 5: distancia competitiva que crea (D), demanda expresada por usuarios (Dm), coste invertido (C: 5 = una semana, 1 = más de seis), riesgo invertido (R: 5 = ninguno), encaje con instrumento, pago único y sin rastreo (E). Total sobre 25. La versión de cada ficha está en §3 y en §4.2. La tabla mide urgencia con los datos de hoy; por eso N-01 (Siri AI) puntúa por debajo de su peso estratégico en §0: nadie la pide todavía y no se puede enviar hasta primavera de 2027.

| Ficha | D | Dm | C | R | E | Total |
|---|---|---|---|---|---|---|
| N-02 Fiabilidad con cifra y motivo de parada | 5 | 5 | 4 | 5 | 5 | 24 |
| N-04 Timbre de un gesto y graves | 4 | 5 | 4 | 5 | 5 | 23 |
| N-05 Nunca se repite, test de 10 h | 4 | 4 | 5 | 5 | 5 | 23 |
| N-07 Madrugada sin hora | 4 | 4 | 5 | 5 | 5 | 23 |
| N-03 Pausa de AirPods explicada | 3 | 4 | 5 | 5 | 5 | 22 |
| N-06 Arco de la noche y estacionariedad | 4 | 3 | 4 | 5 | 5 | 21 |
| N-09 Widget de bloqueo, StandBy, Centro de control, Duo | 2 | 5 | 4 | 5 | 5 | 21 |
| N-10 Dormir de larga duración y Focus de Sueño | 4 | 3 | 4 | 5 | 5 | 21 |
| N-12 Cartas de novedades | 3 | 2 | 5 | 5 | 5 | 20 |
| N-13 Qué sabemos con cifras de 2026 | 4 | 2 | 5 | 4 | 5 | 20 |
| N-15 Manto: aviso de 8 h y fundido espectral | 3 | 3 | 4 | 5 | 5 | 20 |
| N-01 Siri AI con esquemas de audio | 5 | 3 | 3 | 4 | 4 | 19 |
| N-08 Live Activity de tres botones para el Watch | 3 | 4 | 3 | 4 | 5 | 19 |
| N-17 iCloud de mezclas sin cuenta | 3 | 4 | 3 | 5 | 4 | 19 |
| N-14 Papel bloqueado de noche | 2 | 1 | 5 | 5 | 5 | 18 |
| N-16 Textura Secador | 2 | 2 | 4 | 5 | 5 | 18 |
| N-11 Capa: debajo de otro audio | 2 | 3 | 3 | 5 | 4 | 17 |
| N-18 Noches con Marea, sin racha | 2 | 2 | 5 | 5 | 3 | 17 |
| N-21 Muesca con contradicción expuesta | 4 | 2 | 3 | 3 | 4 | 16 |
| N-23 Fundido por quietud sin permiso | 3 | 2 | 3 | 4 | 4 | 16 |
| N-22 Modo cuna con la frase de la AAP | 2 | 2 | 3 | 4 | 4 | 15 |
| N-19 Marea háptica en el Watch | 3 | 2 | 1 | 4 | 4 | 14 |
| N-20 HealthKit lectura: exposición y respiración | 3 | 2 | 3 | 3 | 3 | 14 |
| N-25 Studio, segundo pago único | 3 | 1 | 1 | 4 | 4 | 13 |
| N-24 Guía de nivel con micrófono | 3 | 2 | 2 | 3 | 2 | 12 |

### 4.2 Contenido de cada versión, revisado frente a PLAN-SIMPLE §9

**Beta de 1.0 (ahora, sin tocar el alcance cerrado).** Entra como criterio de aceptación o texto: N-03 (fundido de 3 s ante la pausa de AirPods y la línea en Salida), la prueba de aceptación de la mezcla completa por AirPlay y HomePod (N-02), la medición de batería y buffer de N-02 (sin publicar aún), el test de 10 h de N-05 en CI, el orden de la ficha en español (§6.1), la nominación de enero (§6.2), y la primera carta de N-12 escrita como notas de versión. N-07 (sin cuenta atrás en Madrugada) si cabe en Noche. Por qué: todo es S y responde a la queja número dos del mercado.

**1.0.1 (dos a tres semanas después del lanzamiento).** N-04 (Timbre en el bus) y la parte de N-09 que no haya entrado en 1.0 (widget de bloqueo, Centro de control). Por qué: son las dos funciones donde el mercado nos ha adelantado en seis meses (siete apps con control espectral, nueve con widgets) y ambas son S-M. PLAN-SIMPLE §9 las tenía en 1.1; se adelantan sin mover el resto.

**1.1 "La mesilla" (tres a cinco semanas después).** Se mantiene todo lo de §9 (Live Activity, StandBy, Dynamic Island, widget Dormir, Centro de control si no entró antes, Papel, Timbre por capa, "Qué sabemos" y "Cómo se genera", diagnóstico, iCloud). Entra además: N-08 con tres botones y diseño para el Smart Stack del Watch; N-10 (intent de larga duración y filtro de Focus); N-06 (arco de la noche y estacionariedad); N-11 (Capa); N-13 (cifras de 2026); N-14 (Papel bloqueado de noche); N-15 (aviso de 8 h y fundido espectral); N-16 (Secador); N-17 (iCloud, ya previsto); N-18 si el dueño lo aprueba; la cifra publicada de N-02; y la rama de N-01 abierta y probada en la beta 27.3 sin enviarla. Sale: nada. Se aplaza: compartir mezclas por enlace (FUNCIONES 1.1) hasta que exista la web E8, porque sin ella el enlace no abre nada en quien no tiene la app.

**1.2 "La voz y la muñeca".** PLAN-SIMPLE §9 decía Watch, HealthKit e iPad. Revisado: primero N-01 (envío de Siri AI y Spotlight en cuanto Apple abra la puerta, con beneficio inmediato fuera de la UE), después N-20 (HealthKit solo lectura, con la página de exposición por auriculares como primer uso), N-21 (muesca con prototipo cerrado), N-22 (modo cuna), N-23 (fundido por quietud). N-19 (Watch) solo si las reseñas de 1.1 piden el reloj después de tener la Live Activity en el Smart Stack; iPad solo si las ventas lo justifican, como ya decía §9. Por qué cambia el orden: la Live Activity de 1.1 ya pone el mando en la muñeca sin app de Watch, y Siri AI tiene ventana de meses.

**2.0 "El segundo instrumento" (no antes del mes 18).** N-25 (Studio con reglas publicadas en 1.1), la Escena espacial con cabeza fija (sin ficha: demanda cero, L, solo con auriculares), N-24 y el ducking por ronquido con el clasificador del sistema (sin ficha: medio-alto en review, L) solo con batería medida y texto de uso probado, el amanecer acústico de FUNCIONES, y la migración a Now Playing cuando el mínimo suba a iOS 27.

---

## 5. Lo que no haremos y por qué

Cada línea amplía FUNCIONES §4.2 con lo verificado en 2026; se escribe en "Lo que no hay" con la forma de ausencia ("Sin puntuación"), que es la única que pasa el lint.

| No haremos | Lo hace | Evidencia que lo sostiene |
|---|---|---|
| Tracker, puntuación, hipnograma, informe con número | BetterSleep, Calm Sleep, ShutEye, Sleep Cycle, Apple (Sleep Score en watchOS 26) | Feedback falso de un wearable empeoró la función diurna (*J Sleep Res* 2018); ortosomnia del 3 al 14 % (*Brain Sci* 2024); AASM 2018: la tecnología de consumo no diagnostica; Apple lo regala. Los trackers huyen a B2B (Sleep Cycle T1-2026). |
| Contenido grabado, narrado o "catálogo de 300 sonidos" | BetterSleep (313,9 MB), Calm, Headspace, Loóna (parada), Dark Noise (430 MB) | "you are paying for the same tracks on repeat" (Endel, 12-11-2026); el generativo con autor envejece, el ruido sin autor no; cuatro apps de contenido paradas en 2026; nuestro binario pequeño es la ventaja estructural. |
| Suscripción, paquete anual de funciones, rebajas con fecha, ventas colectivas | Veil desde 14-08-2026, Slo, Sonora, Dark Noise; ShutEye y Endel con "ofertas" | 36 de 125 reseñas recientes por paywall; "I'd pay for the app once but the subscription model is just bs"; Appfigures: la rebaja compra descargas, no ingreso; Apple rechaza eventos de precio; modelo Agenda acusado de retrasar funciones. |
| Voz o coach por IA, mezcla por frase con modelo | Sleep Cycle (Luma, ChatGPT), Headspace (Ebb), Dark Noise (Magic Mix) | "IA" vetada; Magic Mix es el único uso real en el dispositivo y aun así vende con la palabra; las mezclas de la casa con nombre por problema resuelven lo mismo sin modelo. |
| Binaurales, isocrónicos, 432 y 528 Hz, "limpia tu cerebro" | Veil (desde 18-11-2026), Slo, Sonora, Nava, Atmosphere, BetterSleep (blog) | ECA doble ciego 2019: ISI sin diferencia; ningún ensayo revisado sobre 528 Hz; metaanálisis de 2022 retractado; hipótesis glinfática sin ensayo. Es el contraste más barato de la ficha, dicho sin nombrarlos. |
| Alarma propia, "alarma por fase", despertador con luces | Portal, Sleep Cycle, BetterSleep, ShutEye, White Noise, Rain Rain | Apple ya tiene la alarma de Sueño; 66-70 % de precisión sin sensores y "little overall impact"; una alarma exige permisos y abre 1.4.1. El amanecer acústico de 2.0 no afirma fases. |
| Cuenta, servidor, sincronización fuera de iCloud, cuestionario de alta | Slo (11-11-2026), BetterSleep, Noisli | "you had me interested until you asked me if I was other than a male or female" (15-11-2026); cinco reseñas por cuestionario o datos al entrar; "Data Not Collected" es argumento de ficha (Nava, Portal). |
| Recordatorios y notificaciones que venden | Veil, Rain Rain, Sonora, BetterSleep, myNoise (avisos de paisajes nuevos) | Cero peticiones de recordatorios; los usuarios de myNoise leen una notificación de una app de pago único como anuncio (01-11-2026). La única notificación es la de "si tu sueño te preocupa". |
| Detección de apnea o ronquidos como medición, grabadora | BetterSleep, ShutEye, Sleep Cycle (cribado con validación clínica) | Territorio de dispositivo sanitario y de 1.4.1; punto naranja toda la noche; "I just wanted the 7 day free trial and was charged $63.74 TWICE" es la experiencia asociada a esas apps. Un ducking de 3 dB con el clasificador del sistema, sin grabar ni contar, queda para 2.0 y condicionado a batería medida. |
| Textura "Pulso lento" | Nadie | Metaanálisis 2022 retractado; efecto evaporado en 2023; REM a la baja con ruido continuo (2026). Recomendación: eliminarla del catálogo hasta que exista un instrumento (2.0). |

---

## 6. Palancas sin suscripción y calendario de eventos de tienda

### 6.1 Palancas que entran

1. **Nominación a featuring con evento adjunto**, tres semanas a tres meses antes, criterios públicos (experiencia, diseño, innovación, accesibilidad, localización, ficha). Featuring multiplicó 10-40× en Dark Noise y Portal.
2. **Beta pública de seis semanas con enlace público de TestFlight y carta a los testers** pidiendo la reseña del día uno sin `requestReview`: 4.545 descargas y 19.000 $ en el primer mes de Dark Noise (2019).
3. **Códigos de oferta gratuitos** (Free Offer) para testers, prensa y accesibilidad; un código personalizado con hasta 25.000 canjes para una campaña; nunca como descuento público ni contador de referidos. Sustituyen a los promo codes, retirados el 27-03-2026.
4. **Fichas personalizadas por palabra clave** (hasta 70, buscables desde el 28-10-2025; en español primero "sin tarjeta", luego "sin cuenta", luego "una vez") y **etiquetas de accesibilidad** publicadas (buscables en iOS 26+; criterio editorial explícito).

No entran: precio de lanzamiento o rebajas (−50 % de precio dio +59 % de conversión en Dark Noise, es decir, menos ingreso por descarga), Search Ads (CPI 4-10 $ frente a unos 25 $ netos por Pro), ventas colectivas indie (una cuenta atrás es una cuenta atrás), paquete anual de funciones.

### 6.2 Calendario de doce meses (enero a diciembre de 2027)

Supuesto: 1.0 publicada el 18-12-2026 o el 04-01-2027. Seis eventos como máximo, 31 días cada uno, promoción desde 14 días antes, función real y deep link a ella (de noche, a Noche), sin precios ni superlativos, arte 16:9 y 9:16 sin texto, nominación tres semanas antes. Fechas de cambio de hora: EE. UU. 14-03 y 07-11-2027; Europa 28-03 y 31-10-2027. La Semana del Sueño de EE. UU. (14 a 20-03-2027) y el Día Mundial del Sueño (19-03-2027) vienen de calendarios de terceros: confirmar.

| Mes | Momento | Badge y nominación | Nombre y descripción corta propuestos | Función que lo sostiene | Mercados |
|---|---|---|---|---|---|
| Enero | Pico de Año Nuevo, 28-12 a 14-01 | App Launch, o Premiere si 1.0 salió en diciembre | "Primeras noches" / "Un instrumento de sonido para la noche, sin cuenta." | Prueba de 7 noches, Madrugada, Siri "Al acostarte" | Todos |
| Febrero | 1.1 | Major Update / App Enhancements | "La mesilla" / "Pantalla de bloqueo, StandBy y Centro de control." | N-08, N-09, N-10, Papel | Todos |
| Marzo | Semana del Sueño y cambio de hora | Special Event / New Content | "Qué sabemos" / "Lo que se ha medido y lo que no, en una página." | N-13, Manto para la noche corta | EE. UU. 12 a 21-03; España y LatAm 15 a 29-03 |
| Julio | Calor en España y México | Premiere / New Content | "Ventana abierta" / "Mezcla nueva de la casa: ventilador y viento." | Mezcla de la casa gratuita (la lista gratis solo crece), Secador si entró | España, México, sur de Europa |
| Septiembre | Vuelta al cole España; semana de iOS 28 | Major Update / App Enhancements | "Listo para iOS 28" / "Las superficies nuevas del sistema, desde el día uno." | Lo que traiga iOS 28; Siri AI (N-01) si ya está enviada | Todos; España con "Volver a la rutina" del 01 al 15-09 |
| Octubre y noviembre | Cambio de hora Europa 31-10 y EE. UU. 07-11; ningún evento de precio en Black Friday | Special Event / New Content | "Una hora más" / "Para la noche que cambia el reloj: Madrugada." | N-07 como botón en Noche, widget y Siri (el precedente de BetterSleep usa PREMIERE sin función) | Europa y Reino Unido 24-10 a 07-11; EE. UU., Canadá y México 31-10 a 14-11 |
| Diciembre | Noches largas; nominación de enero antes del 01-12 | Premiere / New Content | "Tus mezclas te esperan" / "Vuelven contigo al cambiar de iPhone." | N-17 (iCloud) y, si existe, N-19 (Watch); carta de novedades | Todos |

---

## 7. Riesgos y señales que harían cambiar el plan

| Riesgo | Qué sabemos hoy | Señal que cambia el plan | Respuesta preparada |
|---|---|---|---|
| **Apple amplía Sonidos de fondo** (mezcla, fundido, mezclas guardadas) en la WWDC de junio de 2027 | iOS 26 añadió EQ y temporizador; iOS 27 no tocó Sonidos de fondo; sigue sin mezcla, sin fundido, sin memoria y con bucle audible en HomePod | Nota de la keynote o de las notas de la beta 1 de iOS 28 con "mix" o "fade" en Background Sounds | El foso pasa a Marea, Madrugada, arco de la noche, Siri AI y diseño; se adelanta N-06 y se refuerza "Qué sabemos" |
| **App Review y 4.3(b)** ("sound effects" y "simple timers" nombradas como saturadas desde junio de 2026) | La 3.1.1 no cambia; la prueba local de 7 noches sigue siendo zona gris; bait-and-switch vigilado desde 16-10-2026 | Rechazo en la primera revisión citando 4.3(b) o 3.1.1 | Notes for Review con síntesis, seis capas, Marea y diseño; alternativa de no consumible a nivel 0 "7-day Trial" preparada (PLAN-SIMPLE §10) |
| **Siri AI no llega a la UE** o llega tarde | La prensa dice que la UE queda fuera en iPhone; Apple no lo ha confirmado por escrito en la documentación | Nota de Apple con fecha para la UE, o ausencia en la versión de primavera de 2027 | Enviar igualmente para EE. UU., Reino Unido y LatAm; las cinco frases fijas siguen en la UE; no prometer Siri AI en la ficha es-ES |
| **Coste del Watch** (L, 4 a 6 semanas) sin demanda confirmada | Cuatro peticiones en total, todas de mando; la Live Activity ya aparece en el Smart Stack | Más de cinco reseñas de 1.1 que pidan el reloj tras tener el Smart Stack | Construir N-19 como mando y háptica; nunca altavoz ni sensores |
| **Pausa de AirPods corta sesiones a despiertos** | Activada por defecto; sin API; hilo de foros sin respuesta | Reseñas de la beta que digan "se paró a los 20 minutos" | N-03 ya en la beta; línea en Salida; Manto por altavoz |
| **El precio de 29,99 € frente a la ancla de 20-26 $** | El techo espontáneo de "app de sonidos" está en 20-30 $ tras conocer el producto; nadie en el nicho tiene lifetime a 29,99 | Conversión prueba a Pro por debajo del 3 % en la segunda cohorte mensual con reseñas que nombren el precio | No bajar el precio (principio 6); reforzar "más que sonidos" en la ficha (síntesis, seis capas, Marea, Siri) y la prueba sin tarjeta como titular |

---

## 8. Decisiones para el dueño

| # | Decisión | Recomendación | Plazo |
|---|---|---|---|
| 1 | Timbre y widget de bloqueo: ¿1.0 si el spike cabe, o 1.0.1 comprometida? | 1.0.1 comprometida con fecha, para no mover el envío de 1.0 | Antes de abrir la beta |
| 2 | Abrir ya la rama de Siri AI (N-01) y probarla en la beta 27.3, sin enviarla | Sí; dos a tres semanas de una persona durante 1.1 | Semana 1 de 1.1 |
| 3 | Publicar la cifra de fiabilidad y de batería (N-02) | Sí, en "Cómo se genera" de 1.1, solo si la medición de la beta la respalda | Fin de la beta |
| 4 | "Noches con Marea" sin racha (N-18): ¿recuento o nada? | Recuento total sin reinicio ni aviso; si el dueño lo lee como presión, nada | Antes del diseño de 1.1 |
| 5 | Eliminar "Pulso lento" del catálogo | Sí, hasta que exista un instrumento (2.0) | Ya |
| 6 | Orden de 1.2: Siri AI antes que Watch | Sí; Watch solo con señal de reseñas de 1.1 | Al cerrar 1.1 |
| 7 | HealthKit solo lectura adelantado de 2.0 a 1.2 con la página de exposición | Sí, con política de privacidad escrita y 5.1.1(ii) respetado | Al planificar 1.2 |
| 8 | Reglas de Studio ("para siempre" definido, nada se mueve de Pro a Studio) escritas en la web E8 | Sí, en 1.1, aunque Studio no exista hasta 2.0 | Con la web E8 |
| 9 | Mínimo de despliegue: mantener iOS 17 o subir | Mantener en 1.0 y 1.1; decidir en 1.2 con el reparto de versiones de la beta y de App Store Connect | Al planificar 1.2 |
| 10 | Calendario de eventos (§6.2) y nominación de enero | Aprobar el calendario; enviar la nominación de enero antes del 01-12-2026 | 01-12-2026 |

---

## 9. Fuentes

Agrupadas por tema; consultadas el 19-11-2026 salvo fecha indicada. Las fuentes del 16-11-2026 están en los tres documentos de origen y no se repiten.

**Documentos de origen.** `INVESTIGACION-MERCADO-SUENO-2026-11-16.md` (§2.7, §3, §5.2, §6, §8); `COMPETIDORES-2026-11-16.md` (ficha 7, lecciones 1 a 15); `FUNCIONES-PRIORIZADAS-2026-11-16.md` (§3.1, §4); `PLAN-SIMPLE-1.0.md` §9 y §10; `AGENTS.md` §5; `10-GUIA-DE-COPY.md` §0.4 y §0.5.

**Fichas de App Store (US) y webs de competidores.** BetterSleep https://apps.apple.com/us/app/id314498713 · Calm https://apps.apple.com/us/app/id571800810 · Sleep Cycle https://apps.apple.com/us/app/id320606217 y https://sleepcycle.com/newsroom/press-release/sleep-cycle-launches-luma · Dark Noise https://apps.apple.com/us/app/id1465439395 y https://darknoise.app/releases · myNoise https://apps.apple.com/us/app/id1523675125 · Endel https://apps.apple.com/us/app/id1346247457 · Portal https://apps.apple.com/us/app/id1436994560 · White Noise Lite https://apps.apple.com/us/app/id292987597 y https://www.tmsoft.com/blog/ · Veil https://apps.apple.com/us/app/id6760920621 · Slo https://apps.apple.com/us/app/id6739538343 · Nava https://apps.apple.com/us/app/id6756928575 · Sonora https://apps.apple.com/us/app/id6742157763 · Apple, Sonidos de fondo https://support.apple.com/HT212775

**Reseñas y foros.** Google Play, más recientes (19-11-2026): https://play.google.com/store/apps/details?id=ipnossoft.rma.free&hl=en&gl=US · ...&hl=es&gl=ES · https://play.google.com/store/apps/details?id=com.tmsoft.whitenoise.lite · https://play.google.com/store/apps/details?id=com.mynoise.mynoise · https://play.google.com/store/apps/details?id=com.endel.endel · https://play.google.com/store/apps/details?id=health.sleep.sounds.tracker.alarm.calm · Hacker News https://news.ycombinator.com/item?id=45558611 · https://news.ycombinator.com/item?id=50212507 · https://news.ycombinator.com/item?id=47287763 · Mumsnet https://www.mumsnet.com/talk/parenting/5483792-white-noise-that-sounds-like-a-hairdryer · MacRumors https://forums.macrumors.com/threads/here-are-the-new-background-sounds-in-ios-26.2458528/

**Plataforma Apple.** Esquemas de audio https://developer.apple.com/documentation/appintents/app-schema-domain-audio · https://developer.apple.com/documentation/appintents/appschema/audioentity/ambientsound · Siri AI https://developer.apple.com/documentation/appintents/apple-intelligence-and-siri-ai · https://developer.apple.com/news?id=gdk2umrf · https://ppc.land/apple-opens-siri-ai-to-all-developers-but-apps-cant-ship-it-until-spring/ · App Intents https://developer.apple.com/documentation/updates/appintents · Now Playing https://developer.apple.com/documentation/nowplaying · Live Activities https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities · Buffer https://developer.apple.com/documentation/avfaudio/avaudiosession/setpreferrediobufferduration(_:) · Interrupciones https://developer.apple.com/documentation/avfaudio/avaudiosession/interruptionreason · Pausa de AirPods https://developer.apple.com/forums/thread/842375 y https://www.macrumors.com/how-to/ios-26-airpods-auto-pause-media-when-asleep/ · Watch https://developer.apple.com/documentation/watchkit/using-extended-runtime-sessions · HealthKit https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/headphoneaudioexposure y https://developer.apple.com/forums/thread/728583 · SoundAnalysis https://developer.apple.com/documentation/soundanalysis/snclassifieridentifier/version1

**App Store Connect, App Review y negocio.** Guías https://developer.apple.com/app-store/review/guidelines/ · 4.3(b) https://9to5mac.com/2026/06/09/apple-tightens-app-review-guidelines-against-apps-that-do-not-add-value-to-the-app-store/ · Bait-and-switch https://9to5mac.com/2026/10/16/apples-new-app-store-rules-crack-down-on-ai-nudification-and-bait-and-switch-apps/ · Eventos https://developer.apple.com/app-store/in-app-events/ · Nominaciones https://developer.apple.com/help/app-store-connect/manage-featuring-nominations/nominate-your-app-for-featuring · Featuring https://developer.apple.com/app-store/getting-featured/ · Códigos de oferta https://developer.apple.com/news/?id=gf6mgrs6 y https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/create-offer-codes-for-in-app-purchases · Family Sharing https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/turn-on-family-sharing-for-in-app-purchases · Appfigures (21-11-2025) https://appfigures.com/resources/insights/20251121?f=5 · Dark Noise 2019 https://charliemchapman.com/posts/2019/9/27/marketing-dark-noise/ · Calendar 366 https://forums.macrumors.com/threads/calendar-366-has-had-a-major-upgrade-which-the-developer-is-calling-a-completely-new-app.2481751/ · Screen Studio https://alternativeto.net/news/2025/10/screen-studio-has-removed-their-non-subscription-licensing-options-for-new-customers · Cambios de hora 2027 https://time.is/DST_2027

**Ciencia.** *SLEEP* 2026 https://doi.org/10.1093/sleep/zsag001 · Retracción *J Sleep Res* 2022 https://ueaeprints.uea.ac.uk/id/eprint/93753/ · *Sleep Medicine Reviews* 2026 https://doi.org/10.1016/j.smrv.2026.102284 · Muesca 2024 https://doi.org/10.1007/s00405-024-08732-8 y https://doi.org/10.1016/j.amjoto.2024.104467 · Muesca 2025 https://doi.org/10.1007/s00405-025-09260-9 · AASM 2021 https://doi.org/10.5664/jcsm.8986 · Reloj y fármacos 2023 https://www.psychiatrist.com/pcc/use-of-sleep-aids-in-insomnia-the-role-of-time-monitoring-behavior/ · AAP 2023 https://www.healthychildren.org/English/news/Pages/sounds-the-alarm-on-excessive-noise-and-risks-to-children.aspx · *Sleep Medicine* 2024 https://doi.org/10.1016/j.sleep.2024.04.006 · *J Neurosci* 2021 https://www.jneurosci.org/lookup/doi/10.1523/JNEUROSCI.2524-20.2021 · *PLoS Biology* 2022 https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3001571 · Binaurales 2019 https://pubmed.ncbi.nlm.nih.gov/31433343/ · Wearable 2018 https://pubmed.ncbi.nlm.nih.gov/29989248/ · Ortosomnia 2024 https://doi.org/10.3390/brainsci14111123 · AASM 2018 https://pubmed.ncbi.nlm.nih.gov/29734997/
