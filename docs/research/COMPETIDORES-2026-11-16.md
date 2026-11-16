# Fichas de competidores de SleepNoise

**Fecha:** 16 de noviembre de 2026 · **Mercados:** EE. UU./inglés y España/LatAm/español · **Autor:** análisis de competencia (síntesis de las 15 investigaciones de la primera y segunda ronda).

**Qué es este documento.** Cuarenta fichas de producto, agrupadas por tipo (gigantes de meditación, especialistas en sonido, audio generativo y sintetizado, trackers y Apple, CBT-I digital, hardware, adyacentes), precedidas de una tabla comparativa y cerradas con las lecciones transversales. Cada ficha sigue la misma plantilla: qué es, para quién, precio exacto y modelo, funciones destacadas, diseño visual y tono, lo que aman y lo que odian los usuarios (citas literales con fuente), qué podemos aprender y qué hueco deja para SleepNoise.

**Convenciones.** Los precios son los de las fichas de la App Store de EE. UU. (USD) y, cuando se indica, España (EUR), México (MXN), Argentina (USD) y Colombia (COP), leídos el 16-11-2026 salvo fecha distinta. Las valoraciones ("4,8 / 3,7K") son nota media y número de valoraciones de la tienda de EE. UU. salvo que se indique otra tienda. Las citas de usuarios van en su idioma original y con la tienda, el agregador o el medio de donde proceden; las de las tiendas ES/MX/CO/AR proceden del feed RSS oficial de reseñas de Apple (2.351 reseñas descargadas y codificadas en la segunda ronda). Lo marcado **[E]** es estimación propia o de las investigaciones de origen; **[P]** es afirmación del propio competidor sin contrastar. Las cifras de ingresos de empresas privadas son estimaciones de terceros (Sensor Tower, Business of Apps, Appfigures, Udonis) salvo Sleep Cycle, que cotiza y publica cuentas auditadas.

**Punto de partida de SleepNoise, para leer las fichas en contexto.** App iOS 17+, SwiftUI, sin dependencias, sin red salvo StoreKit, sin cuentas ni analítica; DSP propio que genera en tiempo real (sin grabaciones ni bucles) ruido blanco/rosa/marrón y texturas de lluvia, ventilador y océano; mezclador de seis capas, temporizador con fundido, mezclas guardadas, "Marea respiratoria" (oleaje acompasado a 4-8 respiraciones por minuto durante 15 minutos que después se disuelve), prueba local de 7 días y un único pago Pro. Peso: pocos MB frente a los 190-725 MB de la mayoría de competidores.

---

## 1. Tabla comparativa

| # | Producto | Empresa | Tipo de audio | Mezclador | Timer | Funciones de sueño | Integraciones Apple | Precio y modelo (EE. UU.) | Nota / valoraciones | Última act. | Cliente principal | Punto fuerte | Punto débil |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Calm (+Calm Sleep) | Calm.com Inc. | Grabado: 500 Sleep Stories, soundscapes, música | Sleep mixer básico | Sí | Historias, meditaciones, respiración; Calm Sleep: plan diario, "sleep readiness", HealthKit | HealthKit (Calm Sleep), Watch, Siri parcial | Susc. 69,99-79,99 $/año, 14,99-16,99 $/mes; lifetime 399-499,99 $ | 4,8 / 2M (ES 4,6 / 24K) | Continua; Calm Sleep 16-09-2025 | Mujer 35-55, "racing thoughts", ingresos medio-altos | Marca y catálogo de voces famosas; 1.000M reproducciones de Sleep Stories | Trustpilot 1,3-1,5/5 (78 % de 1★) por renovaciones; 189 MB; todo requiere cuenta y red |
| 2 | Headspace | Headspace Inc. (vendida a Sword Health 2026) | Grabado: sleepcasts 45 min, sleep radio, ruido blanco/verde | No | Sí | Sleepcasts con variación nocturna, "Racing Mind SOS", curso de sueño | Watch, widgets, HealthKit mindful | Susc. 69,99 $/año, 12,99 $/mes; sin lifetime | 4,8 / 974K (ES 4,7 / 19K) | Continua | 25-44, mixto, entra por estrés | Sleepcasts; voz de marca | 450 MB; controles de bloqueo rotos; ingresos IAP 71→39 M$ (2022-25); ficha ES solo en inglés |
| 3 | Balance | Elevate Labs / The Mind Company | Grabado: 5 ruidos, 3 historias, sleepcasts | No | Sí | Plan personalizado; "Wind Down" con estimulación bilateral + respiración | Descargas offline | 49,99-69,99 $/año, 11,99 $/mes; lifetime 399,99 $ | 4,9 / 121K | Continua | Principiante "meditation-curious" | UI contenida (5 secciones) que convierte a 4,9★ | Sonido decorativo; "daily check-ins can feel repetitive"; empuja upgrade |
| 4 | Insight Timer | Insight Network Inc. | Grabado: 120.000 meditaciones, Sleep Mixer, ruido blanco 8 h | Sleep Mixer (gratis) | Sí (con bugs) | Programas de sueño, cursos MemberPlus | Básicas | Gratis + MemberPlus 59,99 $/año, 9,99 $/mes | 4,9 / 449K | Continua | Meditador habitual, sensible al precio | "Free. No Ads. No AI." | Feed social, "10 popups", offline y rebobinar solo de pago |
| 5 | Aura | Aura Health | Grabado: miles de pistas, "Spotify of mindfulness" | No | Sí | Sleep tales, hipnosis, CBT, coaching, IA de recomendación | Básicas | 47,99-99,99 $/año, 7,99-14,99 $/mes; lifetime 399-499 $ | 4,7 / 35K (Google Play 3,9) | Continua | Perfil espiritual/terapéutico | Catálogo y personalización | Precios ilegibles; "charge you 300 % trial cost"; 264 MB |
| 6 | Meditopia + Petit BamBou | Meditopia (TR) / FeelVeryBien (FR) | Grabado, voces en español | No | Sí | Catálogo de sueño, respiración (coherencia cardíaca gratis en PB) | Básicas | Susc. mensual/anual + "de por vida" (PB, sin precio) | Meditopia ES 4,x / 11-52K; PB ES 4,75 / 28K | Continua | Hispanohablante de meditación | Localización real al español | Queja de "mezcla de acentos"; contenido hablado |
| 7 | BetterSleep (+Sleep Pillow) | Ipnos Software / BetterSleep Health | Grabado: 300+ sonidos, 250+ meditaciones, 100+ SleepTales | Sí + Smart Mix | Sí | Tracker, grabadora de ronquidos, cronotipo, HealthKit | HealthKit, Watch | Susc. 59,99-69,99 $/año, 9,99 $/mes; lifetime 249,99 $ (99,99 € promo ES) | 4,7 / 391K (ES 4,7 / 3,8K; MX 4,8 / 7,7K) | 05-11-2026 (semanal) | Masivo; padres, ansiedad, hispanos | Ecosistema completo en una suscripción | Paywall retroactivo 2025-26: "90 % of my mixes are now locked"; 314 MB |
| 8 | myNoise | myNoise BVBA (Stéphane Pigeon) | Grabaciones de campo aleatorizadas + síntesis, 350+ paisajes, 10 sliders | Creation Mode (perdió "multis") | 1 min-23h59 | Animate Mode, Tape Speed, calibración iEQ | Básicas | Gratis + Full Access 19,99 $ (22,99 €) pago único | 4,7 / 1,2K (ES 4,9 / 27) | 29-10-2026 | Usuario exigente, tinnitus, 3 personas en el equipo | Control espectral; "no ads, no subscription, no AI" | Relanzamiento 2024 perdió el mezclador; "apilar generadores needs a lot of CPU"; solo inglés |
| 9 | Dark Noise | Dark Noise LLC (Charlie Chapman) | Grabado, bucles largos, 50+ sonidos, 430 MB | Sí + Magic Mix (Apple Intelligence) | Sí, fade | Temporizador, temas, iconos animados | Shortcuts/Siri (incl. HomePod), widgets, Live Activities, Control Center, StandBy, AirPlay, Mac | Gratis (8 sonidos) + Pro 2,99 $/mes, 19,99 $/año, lifetime 49,99 $ (59,99 €) | 4,8 / 3,7K (ES 4,8 / 73) | 17-10-2026 (iOS 26+) | Usuario Apple que valora diseño; TDAH, tinnitus | Integración iOS referente; MacStories: "design is what really pushes it over the edge" | 430 MB; "jump when it loops" en marrón; cambio a suscripción; solo inglés |
| 10 | White Noise (TMSoft) | TMSoft (Todd Moore) | Grabado, 50+ bucles + 50.000 del Market; "Generator" IAP | Mix Pad | Sí + alarmas | Reloj de mesilla, grabación propia | Watch, Apple TV, Siri/Shortcuts, widget | 0,99 $ (Full) + 0,99 $ Generator; Lite gratis; Pro 2,99 $ | 4,8 / 46K (271K históricas) | 06-11-2026 | Veterano desde 2008-2010, padres | Precio, estabilidad ("UI stayed the same for years") | Loops cortos en gratis; menús confusos; estética 2010 |
| 11 | Noisli | Noisli Labs UG | Grabado, 16-28 sonidos | Sí | Básico | Combos guardados | Ninguna moderna | 1,99 $ pago único iOS; web 8 €/mes | 4,2 / 255 | 19-04-2017 (abandonada) | Productividad, nostálgicos | Fue referente estético 2014-16 | Sin actualizar 9 años; sin AirPlay; "shoulda saved the $2" |
| 12 | Rain Rain | Stable Dynamics (Tim Gostony) | Grabado, 100+ "endless" | Sí (3 capas) + Oscillator/Soften | Sí, fade | Mezclas en iCloud | iCloud | Gratis + Premium 9,99 $/mes, 29,99-35,99 $/año; packs 4,99 $ | 4,8 / 138K (ES 4,75 / 286) | 22-01-2025 | Masivo, ES localizado | Oscillator y Soften (modulación lenta y pasa-bajos) | Suscripción ("I can't support greed"); máximo 3 capas; fade silencia alarma |
| 13 | Tide | Moreless (Guangzhou) | Grabado, 490 MB | Sí | Sí + rutinas | Respiración 4-7-8, Pomodoro, tracker, Watch HRV | Watch | Gratis + Plus 9,99-11,99 $/mes, 54,99-59,99 $/año | 4,8 / 8,4K | 03-11-2026 | Estudiante/joven profesional | Estética editorial (fotografía, tipografía) | "Pricing model is way too expensive for what the app is"; funciones gratis movidas al paywall |
| 14 | Portal | Portal Labs Ltd (UK) | Grabado espacial + vídeo 12K, 100+ portales | No (un portal) | Sí | Circadian Flow, alarma de amanecer, Hue/HomeKit, respiración | Spatial Audio head-tracked, Live Activities, HomeKit | Gratis (3 portales) + 5,99 $/mes, 29,99 $/año, lifetime 99,99 $; prueba 7 días sin tarjeta | 4,8 / 10K (ES 4,6 / 220) | 28-10-2026 | Amante del diseño, "lujo digital" | Editors' Choice, Webby; "should be studied" | Necesita red para contenido; 284 MB; vídeo |
| 15 | Atmosphere / Bedtime Fan / Noise Machine | Peak Pocket / Slumber Studios / ZipoApps | Grabado 70+ / 8 ventiladores / generado 4 colores | Sí / No / No | Sí | Binaurales; "Background Mix" | Básicas | 4,99 $ sin anuncios / 19,99 $/año / lifetime 6,99-9,99 $ + susc. | 4,8 / 2,6K; 4,8 / 205K; 4,6 / 4,3K | 2024 / oct-2026 / jul-2026 | Casual, padres de bebés, TDAH | Nichos muy grandes (ventilador: 205K valoraciones) | Anuncios; "a skip… can absolutely wake me up"; 11 IAP confusos |
| 16 | Slumber Studios + micro-apps hispanas | Slumber Studios; Kaluzynski; 冬魁 岳; Phase4 | Grabado | Básico | Sí (1 h en algunas) | Sonidos de bebé (matriz, latido) | Ninguna | Gratis + IAP baratos / anuncios | ES: Slumber 4,73 / 1.216; bebés 4,71 / 991; Ruido Blanco App 4,75 / 616 | Variable | Padres hispanohablantes | Dominan "ruido blanco" en la tienda ES | Copy traducido a máquina; "Anuncios pornográficos"; sin tracción indie premium |
| 17 | Veil | Colin Shepard Hanson (NY) | **Síntesis en tiempo real**, 28 sonidos, lluvia "drop by drop" | 3 capas | 20 min-24 h, fade | Rutinas, reloj atenuado, Studio (EQ paramétrico 3 bandas) | Widgets, Siri/Control Center (iOS 18+), AirPlay | Gratis (6 sonidos) + 2,99 $/mes, 11,99 $/año, lifetime 24,99 $ | 5,0 / 26 (ES y MX: 0) | 12-11-2026 (lanzada 04-2026) | Light sleeper técnico, Reddit | Misma tesis técnica que SleepNoise, bien documentada | 3 capas, sin función fisiológica, ancla el precio en 24,99 $; etiqueta de privacidad con "Advertising Data" |
| 18 | Slo (+Sonora, NoiseNest, Nava, Ambi, Noizio) | Karlie Kowalska; indies | Grabado en bucle, 150+ | Sí | Sí (4 toques) | Mezcla "Pink Noise and River for Tinnitus Masking" | Mac, visionOS | 5,99 $/mes, 29,99 $/año, lifetime 24,99/49,99 $ | 4,8 / 68 | 15-11-2026 | SEO ("Slo vs X") | Ficha ES: "El ruido marrón no trata nada: enmascara" | Cascada "fades out then starts again"; acaba de añadir cuentas; rastreo publicitario |
| 19 | Endel | Endel Sound GmbH (Berlín) | Generativo: stems humanos + sistema de nodos ("IA") | No | Sí | Inputs: hora, clima, pulso Watch, movimiento; modos Sleep/Focus/Relax | Watch standalone, Apple TV, Vision, Siri | 2,99-19,99 $/mes, 34,99-119,99 $/año, lifetime 124,99 $ | 4,6 / 34K (ES 4,55 / 1.113) | nov-2026 (iOS 26+) | Early adopter, TDAH, "sci-fi minimal" | Apple Watch App of the Year 2020; estética negra minimal | Trustpilot 2,8/5 (58 % de 1★); "The sounds are NOT personalized"; 338 MB |
| 20 | Brain.fm | Brain.fm Inc. | Música humana + modulación de amplitud patentada | No | Sí | Sleep, Power Nap, Wind Down, 3D | Offline | 14,99 $/mes, 99,99 $/año; sin lifetime | 4,5 / 5,6K | Continua | Knowledge worker, TDAH | Única del segmento con estudio propio (Commun Biol 2024, foco) | Admite "has not published a sleep study"; usuario: "gave a sense of anxiety" |
| 21 | Pzizz | Pzizz Ltd | Híbrido: stems humanos remezclados ("100 billion sequences") + voz | No | Hasta 24 h | Sleep, Nap, Focus; historial a Apple Health | HealthKit | Gratis + Premium 9,99 $ único + Pro 7,99 $/mes, 49,99-69,99 $/año | 4,8 / 9,7K | Continua | Viajero, tripulaciones, insomne ocasional | "Nunca se repite" como argumento desde hace 10 años; 34 MB | No se pueden personalizar los sonidos; empuja la suscripción |
| 22 | Loóna (+Slumber app, Moshi) | Loóna Inc.; Slumber; Moshi | Escenas 3D narradas + música | No | — | "Sleepscapes", test de cronotipo | — | 39,99 $/año o 9 $/semana | 4,8 / ~30K; Trustpilot 2,5/5 | Abandonada ("left abandoned", 2024) | Joven, ansiedad, gamificación | Onboarding y estética cuidados | Modelo de episodios que muere sin producción; "charge you during the free trial" |
| 23 | Apple: Sonidos de fondo + Sueño/Sleep Score | Apple | 16 sonidos grabados con EQ (iOS 26) | No | Sí (iOS 26) | Sleep Score 0-100 (watchOS 26), apnea, Vitals, AirPods pausan al dormirse | Nativo: Control Center, Shortcuts, Focus | Gratis | n/a | iOS 26 (sept. 2025) | Todo usuario de iPhone/Watch | Gratis, preinstalado, sin afirmaciones médicas | Un sonido a la vez, sin fundido, sin mezclas, sin respiración; Score genera ansiedad |
| 24 | Sleep Cycle | Sleep Cycle AB (cotizada, Estocolmo) | Grabado: historias, meditaciones, lluvia | No | Sí | Fases por micrófono, alarma inteligente 30 min, ronquidos | Watch, HealthKit | Gratis + Premium ~39,99-57,99 $/año | 4,7 / 32K; #3 gratis H&F en España | Continua | Sin wearable, quiere despertar mejor | Alarma inteligente; datos auditados | Suscriptores 918K→631K (2024-26); "I'll go back to the Apple alarm" |
| 25 | Pillow | Neybox (Grecia) | Sonidos de biblioteca | No | Sí | Fases con Watch, audio on-device (ronquidos), puntuación, Siri Wind Down, CSV | Watch, HealthKit, Dynamic Island (límite 8 h) | Gratis + 39,99 $/año, 19,99 $/mes | 4,4 / 96K | Continua | Dueño de Apple Watch | "Apple Watch plus" | Fricción Watch/iPhone; recurrente |
| 26 | AutoSleep | Tantsissa (Australia) | Sin audio | — | — | Sueño automático, Sleep Bank, Readiness, alarma háptica | Watch, HealthKit, HomeKit "Lights Off" | **9,99 $ pago único**, sin cuenta, sin IAP | 4,7 / 62K (ES 4,6 / 6,7K) | Continua | Técnico anti-suscripción, privacidad | "Pay once. No subscription. Private by design." | Ancla la categoría a 9,99 $; sin prueba |
| 27 | Rise | Rise Science | Sin sonidos relevantes | — | — | Deuda de sueño 14 noches, Melatonin Window, energía diurna | HealthKit | 69,99 $/año; "AI Expert Access" 29,99 $ | 4,7 / 74K, Editors' Choice | Continua | Profesional de rendimiento | Vende sueño sin hipnograma | Mattress Clarity: carece de "white noise, or extensive soothing sounds" |
| 28 | SleepScore (+Sleep++, SleepWatch) | ResMed; Cross Forward; Bodymatter | Sin audio relevante | — | — | Sónar desde la mesilla; Readiness | HealthKit | 9,99 $/mes, 59,99 $/año; gratis+ads; 39,99 $/año | 4,3-4,4; ~4,1; 4,5 | Continua | Quiere "ciencia" sin wearable | Apellido ResMed | Sónar audible "to them and their pets"; validación limitada |
| 29 | ShutEye | ENERJOY PTE (Singapur) | Grabado, "white noise app free", 725 MB | Sí | Sí | Tracker con micrófono, ronquidos | — | 9,99 $/mes, 59,99 $/año (en USD también en ES/MX) + ofertas en cascada 29,99/19,99 $ | 4,8 / 350K (ES 4,69 / 8,2K; MX 4,81 / 12K) | 06-11-2026 | Masivo, ASO | Máquina de valoraciones | Paywall sobre tus propias grabaciones; "seriously disgusted"; rastreo |
| 30 | Stellar Sleep | Stellar Sleep (YC) | Sin audio relevante | — | — | CBT-I de consumo: control de estímulos, restricción, diario, reto 30 noches | HealthKit | ~188 $/mes facturado trimestral (TechCrunch 2024: 60 $/mes) | 4,7 / 2,8K | Continua | Insomne crónico que puede pagar | "This really, actually works." | "It would have been nice to know just how difficult this was before I paid" |
| 31 | Sleep Reset + Dawn Health | Sleep Reset; Dawn Health | Sin audio | — | — | CBT-I con coach humano, compresión de sueño | — | 19 $ prueba → 297 $/28 días; Dawn 0-75 $/mes vía seguro | — | Continua | Extremo alto del mercado | Acompañamiento humano | Precio de terapia; sin diseño |
| 32 | PDT con receta: Somryst, SleepioRx, somnio | Nox Health; Big Health; mementor | Sin audio | — | — | CBT-I regulada (FDA 510(k), NICE, DiGA) | — | 899 $ lista; ~45 £ / 400 $; 224,99 € reembolsado | — | — | Paciente con receta | Evidencia clínica real (ISI −5,0) | Receta, aseguradora, formularios clínicos |
| 33 | CBT-i Coach + Insomnia Coach (VA) | VA (EE. UU.) | Sin audio | — | — | Diario, herramientas, plan de 5 semanas, restricción | — | Gratis, sin anuncios | 4,6 / 13K; 3,7 / 89 | Esporádica | Veteranos, pacientes en CBT-I | "A free application with no ads!" | "it's created more anxiety than relief"; UI de formulario |
| 34 | Hatch Restore 3 | Hatch | Grabado en bucle, ~40 libres / 60-80 pago | No | Rutinas | Luz de amanecer, "unwind", alarma | Wi-Fi propio | 169,99 $ + Hatch+ 4,99 $/mes o 49,99 $/año | Trustpilot 2,0 / 11 | — | Familias, consumidor premium de mesilla | Rutina noche-mañana sin pantalla | "My alarm won't work unless I pay $50 usd a year."; necesita Wi-Fi |
| 35 | Ozlo Sleepbuds | Ozlo (ex-ingenieros Bose) | Biblioteca propia + streaming de cualquier audio | No | Alarma en oído | Autoplay al detectar sueño, Sleep Patterns | Bluetooth | 299-349 $, sin suscripción | — | — | Light sleeper que ya gasta en hardware | ">50 M$ y >180.000 unidades en 18 meses" [P] | "The sound library could be larger"; presión lateral tras 4-5 h |
| 36 | Soundcore Sleep A20/A30 | Anker | Biblioteca interna + Bluetooth; paisajes "brainwave" ajustables | 3 capas | Sí | ANC, enmascarado adaptativo de ronquidos (mic del estuche), tracker prometido | Bluetooth | 149,99 $ (A20) / 229,99 $ (A30) | SoundGuys 7,4/10 | — | Pareja que ronca, viajero | Única app gratuita con paisaje modulable (densidad/espacio/brillo) | Controles táctiles "on the third or fourth try"; sonidos "kind of flat" |
| 37 | Eight Sleep, Oura, Kokoon, Withings | Eight Sleep; Oura; Kokoon/Philips; Withings | Audio en base de cama / historias / biblioteca / sin audio | No | Fade al dormirse | Temperatura, NSDR, alarma multisensorial; invitaciones a rutina; apnea (UE) | HealthKit (Oura, Withings) | 2.799 $+ y 199-399 $/año; 349 $ + 69,99 $/año; £249; 149,95 € | — | — | High-end absoluto | Validan "audio + cierre al dormirse" | Suscripción obligatoria sobre hardware de miles de dólares |
| 38 | Breathwrk + Othership (+Apple Breathe) | Peloton; Breathwork Plus; Apple | Cues sonoros por fase / música con voz / sin sonido | No | — | 4-7-8 para dormir, haptics, visuales por hora del día | Watch (Breathe), HealthKit mindful | ≈49 $/año o 9 $/mes; ≈130 $/año; incluido | 4,8 / 18K; 4,9 / 2,3K | 28-10-2026 | Ansiedad, biohacker | Lenguaje "manage stress and anxiety" aprobado desde 2019 | "so many timers locked behind a paywall"; ninguna acopla un paisaje continuo a la respiración |
| 39 | Apps de tinnitus: ReSound, Oto, Tinnitus HQ, muesca indies | GN; Oto Health; Phase4; indies 2026 | Grabaciones filtradas / blanco-rosa-marrón con muesca | Parcial | Sí | Pitch-matching, muesca, "distract your brain" | — | Gratis + 69,99 $/año; vía clínica 500-1.000 $; 89,99 $ único (99,99 € ES); lifetime 79,99 $ | 4,7 / 19,5K; 4,7 / 848; 4,66 / 426; 0-4 | 2025-2026 | 1 de cada 10 adultos con acúfeno molesto | Molde de lenguaje que pasa App Review | Ninguna sintetiza con muesca en tiempo real; nicho sin dueño |
| 40 | Napper | Napper AB (Estocolmo) | 30+ sonidos ("Pink Noise: Bass-boosted", "In the womb") | No | Sí | Horarios de sueño de bebés | — | Prueba "7 days for $0" + suscripción (precio no publicado) | ES 4,89 / 3.673 | 15-11-2026 | Padres hispanohablantes | Top 25 de ingresos H&F en ES, MX, AR y CO | Nicho bebé; sin adulto |

**Lectura rápida de la tabla.** Nadie ocupa a la vez las cinco casillas que SleepNoise ya tiene (síntesis en tiempo real, seis capas, pago único, sin cuentas, pocos MB); el más cercano es Veil (síntesis, pago único, 3 capas, 26 valoraciones). La queja dominante en las 40 fichas no es el sonido sino el cobro: renovaciones, pruebas cobradas, paywalls retroactivos. Y el competidor gratuito real es doble: Apple (Sonidos de fondo con EQ y temporizador en iOS 26) y los bucles de 10 horas de YouTube/Spotify.

---

## 2. Fichas por producto

### A. Gigantes de meditación y bienestar

#### 1. Calm (y Calm Sleep)

**Qué es.** La app de meditación con más facturación del mundo convertida en plataforma de sueño: Sleep Stories desde 2016 (la ficha de EE. UU. dice "100+ exclusive stories"; el comunicado de Calm Sleep habla de 500 historias y más de 300 horas), soundscapes, música para dormir, meditaciones y respiración "aimed at easing anxiety, stress, and insomnia". En septiembre de 2025 lanzó **Calm Sleep**, una app aparte solo iOS con cuestionario inicial, plan diario de tareas (higiene digital, ejercicio, estrés, entorno), barra de "sleep readiness" que se reinicia cada mañana y sincronización con HealthKit; vende además ropa de cama (Target) y auriculares Calm x Ozlo con un año de Calm Sleep incluido. Ingresos estimados ~210 M$ en 2025 (−24 % interanual), 7,3 M descargas, ~3,5 M suscriptores; Calm Health (B2B2C) es ya "the primary growth engine" (Business of Apps vía resumen; Sacra). App de 189 MB.

**Para quién.** Dos encuestas revisadas por pares a suscriptores de pago (financiadas por Calm) lo retratan con precisión: edad media 47 años, **85 % mujeres**, ingreso mediano 80.000 USD, mayoría universitaria; 78 % malos dormidores más 10,5 % con diagnóstico de insomnio; causa principal de la mala noche **"racing thoughts" (82 %)** y "stress or anxiety" (73 %), ruido ambiental solo el 16 %; el 90 % de los insomnes la descargó "to improve sleep", la usa 5 noches/semana y **el 50-59 % la pone al despertarse de madrugada para volver a dormir** (Huberty et al., JMIR Formative Research 2020; PLOS ONE 2021). La cliente tipo no compra sonido, compra una voz que apaga el rumiar.

**Precio exacto y modelo.** App Store EE. UU.: Calm Premium 69,99-79,99 $/año, 14,99-16,99 $/mes, familia 99,99 $/año, prueba 7 días. España: 49,99-64,99 €/año, 12,99 €/mes (reseñas ES 2026 citan 65 €). Lifetime 499,99 $ según el artículo de soporte oficial (399,99 $ en ofertas; RevenueCat lo tenía en 399 $ en noviembre de 2025); "Final sale", sin devolución. Calm Sleep Premium: 69,99 $/año, suscripción separada. En la lista de las diez compras más populares de la ficha de EE. UU. el lifetime no aparece: es un anclaje de precio, no una fuente de ingresos.

**Funciones destacadas.** Sleep Stories con famosos (McConaughey, Stephen Fry, Harry Styles), soundscapes, Sleep Mixer, Calm Sleep con plan y barra de readiness, HealthKit, ventana de exclusividad de 4 semanas para contenido nuevo. Dato de marketing sin verificar: "about 92% of users who listen to Sleep Stories five times a week say they sleep better".

**Diseño visual y tono.** Marca histórica: wordmark minimalista sobre degradados azules nocturnos, escena de lago de montaña con agua ondulante, sin mascota. El sistema 2025 de BUCK para Calm Sleep va hacia "ethereal lighting behaviors", personajes "alive in action" y degradados narrativos: ilustración y gamificación, no sobriedad. Tono cálido y aspiracional: "Bedtime should be revered, not feared" (Greg Justice, CCO).

**Lo que aman.** "the SLEEP STORIES!!! they are so good" y "The soundscapes are probably what I utilize for the longest periods" (App Store US, 02-07-2025). Un reviewer de 2026 llama la biblioteca "genuinely unique and effective for insomnia" (ai-health-apps.com, 04-11-2026).

**Lo que odian.** Trustpilot 1,3-1,5/5 con 500 reseñas y **78 % de 1 estrella**: "I cancelled Calm months ago, yet they still took £49.99 from me for an annual renewal" (20-09-2026); "after clicking on each step to cancel it takes you to a page to upgrade to premium" (01-11-2026); "my Premium subscription disappeared and I cannot log in" (05-10-2026); "too much content from too many different artists" (01-09-2025). Sobre Calm Sleep: "Feeling pressure to complete every task added a little stress to her day" (Her Campus). España: "cuesta 49.99 euros yo tengo insighttimer que es gratuita y creo que bastante mejor" (App Store ES, 21-06-2020); "⚠️450€… robo" (ES, 2019, sobre el lifetime); "deberían considerar establecer precios regionales" (CO, 2024); un usuario de Calm MX (2025) rechaza las narraciones: "Lo que busco es un estímulo que ayude a cesar los pensamientos y las narraciones me estimulan el pensamiento analítico".

**Qué podemos aprender.** El sueño es el motivo real de pago de la categoría (77 % de sus suscriptores empezó por dormir) y el despertar de madrugada es un caso de uso de primer orden. La gamificación del sueño (barra, tareas) añade estrés al peor momento. El lifetime a 6-7 veces el anual es irrelevante en volumen.

**Hueco para SleepNoise.** El extremo opuesto: cero contenido que caduque, cero tareas, cero cuenta, sonido que empieza en un toque y funciona en modo avión; un "modo madrugada" sin voz para el 50-59 % que la usa a las 3 de la mañana; y la frase que sus propias reseñas piden: sin suscripción, sin renovaciones, sin historias que se acaban.

Fuentes: https://apps.apple.com/us/app/calm-sleep-meditation/id571800810 · https://apps.apple.com/es/app/calm-sleep-meditation/id571800810 · https://www.calm.com/blog/calm-sleep-press-release · https://techcrunch.com/2025/09/16/calm-launches-standalone-ios-app-for-sleep-support · https://support.calm.com/hc/en-us/articles/30958037515419-Calm-Lifetime-Membership-Cost-Benefits-Is-it-worth-it · https://www.trustpilot.com/review/calm.com · https://pmc.ncbi.nlm.nih.gov/articles/PMC7695531/ · https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0257518 · https://sacra.com/c/calm/ · https://www.buck.co/work/calm-sleep-visual-system · https://www.hercampus.com/wellness/calm-sleep-i-tried-it/ · https://www.revenuecat.com/blog/growth/lifetime-subscriptions/

#### 2. Headspace

**Qué es.** La segunda gran app de meditación, con una oferta de sueño editorial: **Sleepcasts** de ~45 min con "wind-down" previo que varían ligeramente cada noche para que no se memoricen ("Cabin Porch", "Rainday Antiques", "Midnight Launderette"), sleep music, Sleep Radio ("Rain Radio", "Cave Winds"), ruido blanco y verde, "Racing Mind SOS" para despertares nocturnos y un curso de 18 sesiones. Compañero de IA "Ebb" sin función de sueño. 449,6 MB. Trayectoria: ingresos in-app 71 M$ (2022) → 39 M$ (2025), descargas 9,7 M (2021) → 3,5 M (2025), MAU 1,55-1,85 M (Udonis/AppMagic, 26-05-2026); **vendida a Sword Health por 200-300 M$ en 2026**, un 90 % por debajo de los ~3.000 M$ de valoración de 2021.

**Para quién.** ~60 % mujeres, grupo mayoritario 25-44, mercados anglófonos y Alemania; perfil más joven y mixto que Calm, entra por meditación/estrés y descubre el sueño después; es la "puerta de entrada" de principiantes (ChoosingTherapy).

**Precio exacto y modelo.** 12,99 $/mes (prueba 7 días) o 69,99 $/año (prueba 14 días); estudiantes 9,99 $/año; "Headspace Plus" 94,99 $ en la lista de IAP. España 57,99-69,99 €/año, 12,99 €/mes. Promoción permanente "50% off your first year". **No existe lifetime.** 4,8 / 974K (ES 4,7 / 19K).

**Diseño visual y tono.** Naranja (~#F47D31) de las túnicas budistas, "orange smiley", ilustración "playful and expressive", animación guiada por la respiración; refresh 2024 con tipografía a medida de Colophon pensada para moverse "between playful and clinical registers". Tono amistoso, voz de Andy Puddicombe como activo de marca.

**Lo que aman.** "Sleepcasts have truly added value to my nighttime routine" (App Store US); "I put on Rainday Antiques to help me sleep" (04-02-2021); "sleep sounds. These are great". Piden cola de reproducción "so sleepcasts can play one after another" y más sleepcasts gratis porque "I usually have a hard time falling asleep which results in me having to play 2-3 Sleepcasts a night".

**Lo que odian.** "The programmes are very repetitive" (Trustpilot UK); "slow, laggy, and unreliable"; **"whenever I listen to a sleep cast the pause, rewind, and fast forward thing when my mobile is locked never shows up"** (App Store US); dependencia de red: "mijn sleepcasts waarvoor ik de app heb aangeschaft worden constant onderbroken omdat ik zogenaamd offline ben" (Trustpilot NL); "unexpected renewals and difficulties in canceling". España: en 2017 "esperando que hagan versión en español"; en 2019 un usuario señala que la versión es "variante latinoamericana"; la ficha ES sigue listando solo "Inglés".

**Qué podemos aprender.** Una base joven y mixta ya valora el ruido verde y los soundscapes, pero los recibe como pista grabada que se corta sin red y que no puede modular. El caso de "varía ligeramente cada noche" es la versión editorial de "nunca se repite".

**Hueco para SleepNoise.** Controles completos en pantalla de bloqueo y Dynamic Island (queja literal), audio que no se corta sin red, secuencias de mezclas encadenadas (petición literal de cola) y un producto sin voz que no arrastra el problema de acento que Headspace tiene en España.

Fuentes: https://apps.apple.com/us/app/headspace-sleep-meditation/id493145008 · https://apps.apple.com/es/app/headspace-sleep-meditation/id493145008 · https://www.headspace.com/sleep · https://fortune.com/well/article/headspace-app-finding-your-best-sleep · https://www.blog.udonis.co/statistics/headspace · https://nataliaburakova.substack.com/p/from-3b-valuation-to-300m-acquisition · https://uk.trustpilot.com/review/headspace.com?page=3 · https://standards.site/examples/headspace

#### 3. Balance

**Qué es.** Plan de meditación personalizado que se ajusta cada día con preguntas de ánimo y objetivos; el sueño es un módulo con "Sleep meditations, Sleep Sounds, and a Wind Down activity" que usa **"bilateral stimulation and controlled breathing"**. ChoosingTherapy cuenta 5 ruidos blancos y 3 historias ("not very large"); Lila (01-10-2026) añade sleepcasts de 30-60 min, temporizador y descargas offline. 200 MB. Famosa por el "first year free" (2021-2024), hoy retirado. Premio: Google Play Best App 2021 (no Apple, como corrigió la segunda ronda).

**Para quién.** Principiantes y "meditation-curious" que quieren que la app decida el siguiente paso; perfil que entró por el año gratis; no encaja con quien quiere biblioteca grande o control total ("Structured progression limits user control", Lila).

**Precio exacto y modelo.** IAP EE. UU.: 49,99 $/año (variante con 7 días de prueba) y 69,99 $/año, 11,99 $/mes; **Lifetime 399,99 $** (reseña: "buying the lifetime plan was a no brainer", 28-05-2022). 4,9 / 121K. Reseña ES: "Me he sacado la suscripción de por vida"; AR: "licencia lifetime"; en Argentina un usuario pagó "70usd… 45 in taxes" (2024).

**Diseño visual y tono.** "Calm, soothing interface with no bright colors, cluttered menus, or distracting graphics", "polished and easy to navigate, with only five main sections" (ChoosingTherapy). Es la más cercana a la estética Bear de las cinco: tipografía grande, pocos elementos, una tarjeta "Today". Referencia de cómo se ve el minimalismo que ya convierte en esta categoría.

**Lo que aman.** "i was able to sleep more after using the app" (11-11-2022); "you get a full year too fully try this app out in its entirety".

**Lo que odian.** AppImp: el tema **Billing** aparece un +2,5 % por encima de la norma de Health & Fitness; en la wishlist: "no subscription", "timer", "music". "Daily check-ins can feel repetitive", "Some prompts seem to push toward an upgrade" (Lila). Petición de widget (Balance CO, 2026) y de español.

**Qué podemos aprender.** La UI contenida y la tarjeta única son valoradas con 4,9★; el lifetime a 399,99 $ se percibe como "no brainer" por una minoría leal: el pago único no es tabú, solo está mal preciado. Y Balance ya acopla estimulación bilateral y respiración en su Wind Down: SleepNoise no es "la única que acopla algo", sí la única que acopla la propia textura del ruido.

**Hueco para SleepNoise.** Tomar su sobriedad y darle profundidad sonora real (5 ruidos frente a síntesis de seis capas); medir sin check-ins.

Fuentes: https://apps.apple.com/us/app/balance-meditation-sleep/id1361356590 · https://www.choosingtherapy.com/balance-meditation-app-review/ · https://appimp.app/apps/balance-meditation-sleep · https://getlila.com/blog/balance-app-review · https://themindcompany.com/apps/balance

#### 4. Insight Timer

**Qué es.** La mayor biblioteca gratuita de meditación: "120,000+ free meditations", 30.000 profesores, "30 million people practising"; posicionamiento oficial **"Free. No Ads. No AI."**, "Healing is a human right". Sueño: música, soundscapes, cuentos, **Sleep Mixer accesible sin pagar**, pistas de ruido blanco de 8 horas ("esto forma parte de su rutina nocturna diaria", Trustpilot), cursos de sueño solo para MemberPlus.

**Para quién.** Practicante habitual con años de meditación, o usuario sensible al precio que rechaza Calm. Paga por convicción: "I subscribe to support the content providers who don't have that luxury" (App Store US, 29-12-2025); "it's only 60 dollars a year" (Trustpilot, 17-06-2025).

**Precio exacto y modelo.** MemberPlus 59,99 $/año o 9,99 $/mes, prueba 7 días; desbloquea cursos, **descargas offline, repetición, avance/retroceso y "resume"** (en gratis no se puede rebobinar), sonidos premium de larga duración, carpetas y journal. Sin reembolsos. Mentoring 220-1.450 $, talleres 25-250 $, B2B 5-12 $/empleado/mes. Ingresos estimados ~20 M$ (2023, baja confianza). 4,9 / 449K (la más alta de las cinco); Trustpilot 4,2.

**Diseño visual y tono.** "Audio-focused rather than visual, with a simpler look than Headspace" (ChoosingTherapy), pero con cinco pestañas (Home, Discover, Connect, Learn, Profile), feed social, citas, "stories" y solicitudes de amistad; el temporizador original quedó relegado al perfil.

**Lo que aman.** "no ads and no strings" (29-12-2025); "It helps me fall asleep, whether that be music, stories, or guided meditations" (23-01-2023).

**Lo que odian.** "Organization of the app however, needs major work" (15-06-2025); "I just want the option to 'skip' or turn off the questions and app guidance"; **"Cannot access the app without 10 popups each time"** (29-09-2026); "ahora parece mucho más comercial, con anuncios constantes de caras sonrientes" (Justuseapp, traducido). Bugs del temporizador: "The timer function constantly pauses during calls and won't restart" (20-11-2021); "every update also introduces new bugs which make the timer harder to use" (18-06-2021).

**Qué podemos aprender.** El territorio ético ("free, no ads, no AI") existe y fideliza, pero Insight Timer lo ha pagado con ruido de interfaz: un temporizador puro convertido en red social. Offline es un lujo de pago también aquí.

**Hueco para SleepNoise.** Una app de una sola pantalla, sin feed, sin preguntas, que arranca en el sonido y cuyo temporizador sobrevive a una llamada.

Fuentes: https://insighttimer.com/about · https://help.insighttimer.com/support/solutions/articles/67000664702-what-is-memberplus- · https://www.choosingtherapy.com/insight-timer-review/ · https://apps.apple.com/us/app/insight-timer-meditate-sleep/id337472899?see-all=reviews · https://www.trustpilot.com/review/www.insighttimer.com?page=5

#### 5. Aura

**Qué es.** "The world's largest premium wellness library": miles de meditaciones, sleep tales, música y sonidos (lluvia, truenos, "Brown Noise For Relaxation", "Alchemy Sound Bath" de 63 min), yoga nidra, hipnosis, CBT, coaching de "hundreds of top coaches, therapists, storytellers"; motor "AI-driven personalization" con "billions of data points"; claims "98% report that Aura helps" [P], "Trusted by over 8 million+" [P], "the 'Spotify of mindfulness'" (Travel + Leisure). 264 MB; 4,7 / 35K; Google Play 3,9.

**Para quién.** Perfil espiritual/terapéutico ("love and light", "nurturing community"), ansiedad y búsqueda de sentido, muy sensible a la voz del narrador: "We have become 'addicted' to Jiva Masheder's voice reading us bedtime stories" (Trustpilot, 16-07-2026).

**Precio exacto y modelo.** Lista IAP caótica: anual 47,99 / 69,99 / 99,99 $, semestral 29,99 $, mensual 7,99 / 11,99 $; soporte dice 14,99 $/mes, 69,99 $/año individual y 129,99 $ familiar; **lifetime 399-499 $** "depending on promotions" (healthynexercise, 01-08-2025). Gratis: una sesión de 3 min cada dos horas. Cláusula: "No cancellation of the current subscription is allowed during active subscription period".

**Diseño visual y tono.** Degradados suaves, flores, atardeceres, luna, logo de anillo arcoíris, maquetación "light, airy"; tono afirmativo y espiritual con barniz clínico. La antítesis de un producto técnico y sobrio.

**Lo que aman.** "With Aura I never have an issue falling right back into sleep" (24-04-2026); "I have used the sound backgrounds at night while we sleep" (02-07-2026); soporte "resolved within 24 hours" (23-09-2026).

**Lo que odian.** Trustpilot 3,9/5 con 30 % de 1★: "you can't cancel your membership and they continue to take your money no matter what" (18-06-2026); "the charge you 300% trial cost as a subscription without warning" (09-08-2026); "every meditation, story, music, even nature sounds- a 'premium feature'". Petición de control sonoro: **"I would like to see more flexibility around customizing the sounds that continue after a story"** (15-07-2026).

**Qué podemos aprender.** El techo del modelo "biblioteca infinita + IA": precios ilegibles, trial que explota, tono místico. Su propio usuario pide personalizar la cama sonora que sigue a la historia.

**Hueco para SleepNoise.** Ser ese "después": el fondo sonoro que no se acaba y que convive con el audio de otra app (modo mezcla), con un relevo que sube cuando termina la narración.

Fuentes: https://apps.apple.com/us/app/aura-meditation-sleep-cbt/id1114223104 · https://www.aurahealth.io/ · https://www.trustpilot.com/review/aurahealth.io · https://healthynexercise.com/how-much-does-the-aura-app-cost-a-complete-guide-to-aura-health-pricing-and-features/

#### 6. Meditopia y Petit BamBou (los gigantes del español)

**Qué es.** Las dos apps de meditación con mayor presencia hispanohablante en los rankings: **Meditopia** ("Meditopia: Meditación & Dormir", 52.593 valoraciones en MX, 11.295 en ES) es la referencia de "sonidos para dormir" en la búsqueda de la App Store de México y España; **Petit BamBou** ("Petit BamBou : Meditación", FeelVeryBien SAS, Francia, 4,75 / 28.267 en España) tiene secciones "Sueño" (cuentos, sofrología), "Respiración" (coherencia cardíaca, gratis e ilimitada) y "Estrés y ansiedad" ("Herramientas para transitar la ansiedad cotidiana"). Ambas en el top 50 de ingresos H&F de España (PB #29-#40) y Meditopia en MX (#50) y AR (#43).

**Para quién.** Hispanohablante que busca meditación y sueño con voz en su idioma; en Colombia piden "en español latino", en España "versión en castellano".

**Precio exacto y modelo.** Suscripciones mensual/anual; Petit BamBou añade plan "de por vida" sin precio en ficha ni web. Meditopia tiene 50 reseñas recientes codificadas en español en la segunda ronda, con el mismo campo semántico que el resto: suscripción, pagar, gratis.

**Diseño visual y tono.** Catálogo de tarjetas y voces; Petit BamBou con ilustración amable y lenguaje terapéutico suave; Meditopia con fotografía y degradados.

**Lo que aman y lo que odian.** Lo que se valora es la localización; lo que se castiga, la voz: queja contra "una mezcla de acentos de diferentes países sudamericanos" (Meditopia ES). Petición constante de "en español / castellano / idioma / acento" (33 reseñas del corpus hispano, repartidas entre Balance, Tide, Endel, Calm y Meditopia).

**Qué podemos aprender.** Petit BamBou demuestra que "ansiedad" en castellano pasa App Review si se formula como "transitar la ansiedad cotidiana" y no como tratarla; y que la respiración (coherencia cardíaca) puede ser el gancho gratuito. En español la demanda hispana de sueño está dentro de estas apps y de BetterSleep, no en apps de ruido.

**Hueco para SleepNoise.** Un producto sin voz no tiene problema de acento: basta texto cuidado en es-ES y es-419. La respiración lenta sin narración (Marea) es exactamente lo que el usuario de Calm MX pide: "un estímulo que ayude a cesar los pensamientos".

Fuentes: https://itunes.apple.com/search?term=sonidos+para+dormir&country=mx&entity=software&limit=25 · https://itunes.apple.com/search?term=petit%20bambou&country=es&entity=software · https://www.petitbambou.com/es/ · https://itunes.apple.com/es/rss/topgrossingapplications/limit=50/genre=6013/json · feed RSS de reseñas ES/MX/CO/AR (id 1190294015)

### B. Especialistas en ruido y sonidos para dormir

#### 7. BetterSleep (antes Relax Melodies) y Sleep Sounds by Sleep Pillow

**Qué es.** El líder por ingresos del segmento "sonidos para dormir": "300+ sleep sounds and music tracks (nature, white noise, binaural beats…)", 250+ meditaciones/hipnosis, 100+ SleepTales, mezclador con volumen por capa, mezclas guardadas y "Smart Mix", temporizador, recordatorios, tracker, grabadora de ronquidos, "chronotype" y HealthKit (ficha US, 16-11-2026). Ipnos mantiene además **Sleep Sounds by Sleep Pillow** (~280 sonidos "naturally recorded, pre-mastered" en packs; 4,9 / 90K; última versión 30-10-2023; una mezcla guardada en gratis; packs 9,99-19,99 $ y "All Sound Packs Subscription" 4,99 $) como producto en mantenimiento que canaliza a BetterSleep. Ingresos: Sensor Tower Q1 2023 EE. UU. "around $247K" semanales (≈12-13 M$/año iOS US); Appfigures 2023: 13 M$ (+53 %); snapshots de 600-800 K$/mes iOS US. 314 MB; cadencia de releases semanal (v26.20, 05-11-2026); #57 en H&F gratis EE. UU. La web afirma "67M+ people use BetterSleep" [P].

**Para quién.** El cliente masivo del sueño: padres ("Lo uso todas las noches para dormir a mi bebe y después para dormirme yo!!", AR 2018), ansiosos ("I have a very hard time sleeping, but with this app it helps me quit my head", nov. 2025; "help my racing thoughts"), hispanohablantes (ES 3.764 valoraciones, MX 7.740, el mayor volumen hispano de una app de sonidos), terapeutas ("will recommend to others, including my clients", 2025).

**Precio exacto y modelo.** IAP EE. UU.: Premium 59,99 / 39,99 / 99,99 / 69,99 / 11,99 / 23,99 $, Premium-Tracker 69,99 / 52,99 $; prensa 2024: 9,99 $/mes, 59,99 $/año, **lifetime 249,99 $** (Saatva, 21-05-2024; reseña US 16-08-2026: "asked for $250"). España: Premium 59,99 € y 39,99 €, mensual 9,99 €, **"Promoción de acceso vitalicio: 99,99 €"**; MX 749-1.149 MXN anual, 1.999 MXN vitalicio; reseñas MX: 999 MXN/año tras 99 MXN promocional (2025); un "lifetime" de 5 $ que resultó anual (US, 2026). La web pide cancelar "48 hours before". Figura como ejemplo de paywall en PaywallScreens/Superwall.

**Diseño visual y tono.** Interfaz oscura, tarjetas tipo streaming, mezclador por iconos, densidad de catálogo y paywall temprano ("right after entering an email"). Marketing con "sleep experts" y claims tipo "91% of our listeners say they slept better after using the app for just one week". Sleep Foundation (2022): sonidos "less realistic than those in some other apps".

**Lo que aman.** El mezclador: "Posibilidad de hacer mezclas que no he encontrado en otras aplicaciones" (ES, 2024); "Puedes crear tu propio loop" (MX, 2026). Un usuario de Slumber: "I created a mix 10 years ago and still play it every night" ilustra el mismo apego que BetterSleep ha roto.

**Lo que odian.** El experimento natural de agosto-noviembre de 2026: de 150 reseñas US recientes, 81 son de 1★, 84 hablan de paywall o "used to be free", 34 llevan "for years / since 2013", 19 dicen "deleted", 7 nombran YouTube como destino y 7 piden pago único. Literal: "I have had my premium benefits taken from me completely and am now being told to pay a subscription fee"; "BetterSleep wants me to pay a whopping $99 to have these things accessible again?!"; "you can't even use basic white noise without paying a monthly subscription"; **"90% of my mixes are now locked"**; "$60 a year for sounds when it used to be free!??"; "I'd pay for the app once but the subscription model is just bs"; "the voiceover on the iPhone no longer works" (usuaria legalmente ciega tras un rediseño); "an obnoxious squeaking in the Rain sound every 15 seconds" (2026); "hace que se calienten demasiado los dispositivos" (MX, 2025). En español: "Llevo años usándola, y de la nada todas las mezclas se volvieron premium" (AR); "Descargada por primera vez en 2017… Me la descargo ahora en 2025 y todo bloqueado" (ES); "Lo que antes era gratis ahora es de pago, eso no lo podéis hacer" (ES, 08-05-2023); "esta app empezó siendo gratuita y hoy esté tan cara" (MX, 2025); "mejor pongo los sonidos en YouTube" (MX); "Solicité la prueba gratuita de 7 días… me cobraron al instante" (AR, 2026); "Es una estafa! No quiero pagar por un año" (MX). Sleep Pillow: "puts a commercial in when you try to go to set it to sleep mode".

**Qué podemos aprender.** El mezclador con mezclas guardadas es la razón de fidelidad más citada en toda la categoría; cambiar las reglas a usuarios de diez años destruye en tres meses una década de reseñas de 5★. El cliente hispano de sonidos para dormir está aquí: 11.500 valoraciones entre ES y MX.

**Hueco para SleepNoise.** Mezclas que sobreviven a reinstalaciones, cambios de iPhone y años sin abrir ("Vuelve cuando lo necesites; tus mezclas te esperan"); un IAP con nombre claro y precio regional; sin anuncios ni voces; audio sin "squeaking every 15 seconds" porque no hay bucle.

Fuentes: https://apps.apple.com/us/app/bettersleep-relax-and-sleep/id314498713 · https://apps.apple.com/es/app/bettersleep-relax-and-sleep/id314498713 · https://apps.apple.com/mx/app/bettersleep-relax-and-sleep/id314498713?see-all=reviews · https://www.saatva.com/blog/bettersleep-app-review/ · https://justuseapp.com/en/app/314498713/relax-melodies-sleep-sounds/reviews · https://sensortower.com/blog/2023-q1-unified-top-5-wellness%20apps-units-us-63e274e1e1714cfff10eaa2f · https://appfigures.com/resources/insights/20231222?f=2 · https://apps.apple.com/us/app/sleep-sounds-by-sleep-pillow/id410606661 · https://www.sleepfoundation.org/best-sleep-apps/best-white-noise-apps · feed RSS de reseñas US/ES/MX/AR (id 314498713)

#### 8. myNoise

**Qué es.** El referente histórico del audio no repetitivo: "350+ customizable soundscapes" construidos con grabaciones de campo y músicos reales, descompuestos en bandas controladas por 10 sliders y reproducidos con aleatorización de capas (la web usa Web Audio API). Pigeon: "I have never used generative AI to create sound for myNoise" (manifiesto, ene. 2026). La app nueva (29-10-2024, dos años de trabajo porque "the original iOS developer had left the project") **perdió los "multis"** (mezclar hasta 5 generadores) y en 2025 añadió "Creation Mode" (10 sliders de distintos paisajes). El blog (ago. 2023) admite que apilar generadores **"needs a lot of CPU"**. Funciones únicas: calibración auditiva iEQ, "Animate Mode" (los sliders se mueven solos), "Tape Speed" (pitch más "warmer and less fatiguing"), test de audición. Equipo de 3 personas; 60,3 MB; v3.21.79 del 29-10-2026; solo inglés. La web vive de donaciones ("less than 0.25% of users donate"; costes declarados 75.000 $/año).

**Para quién.** Usuario exigente y crónico: tinnitus, hipersensibilidad, insomnes de largo recorrido ("helps me greatly with insomnia, stress, and tinnitus"), viajeros ("helping with insomnia while traveling as an easily homesick individual", nov. 2025).

**Precio exacto y modelo.** Gratis (7 días de acceso ilimitado sin pedir pago, luego 10 paisajes gratis) + **Full Access 19,99 $** / Acceso Completo 22,99 € / 399 MXN / 99.900 COP (pago único); compra heredada "All You Can Hear" 14,99 $. "One purchase, for life. Free to download, no ads, no subscription"; la empresa "strongly oppose" la suscripción. Las donaciones web **no** desbloquean la app, lo que generó fricción. 4,7 / 1,2K (ES 4,9 / 27).

**Diseño visual y tono.** La app nueva "styled like a mainstream music app" (fondo oscuro, portadas cuadradas, pestañas); los 10 sliders verticales por banda son su firma; tono de ingeniero de sonido honesto ("sounds are engineered to be easily ignored by the brain, creating an illusion of silence").

**Lo que aman.** "Being able to control the sliders is so vital as someone who gets unpredictably annoyed by certain tones" (10-11-2025); "For $20 it is one of the best purchases you can make"; "the fact that they don't bother you with ads and subscriptions is just fantastic" (jun. 2026); "paying $20 for the new app is worth it to me"; ES (17-08-2026): "una opción para que suba y baje automáticamente diferentes sonidos del fondo… la sensación es como estar paseando".

**Lo que odian.** "The new app misses some key features such as a longer timer (no 2 hour option) and the multi gen mixer" (09-2025); "I would love to blend multiple soundscapes at a time though" (01-2026); "there seems to be a bug that makes my speakers crackle. It only happens with this app" (06-2026); "I strongly dislike the new UI" (rebranding 2026); "SIN CONTROL DE VOLUMEN… tengas que modificar el volumen general de todo el equipo" (ES, 2024); petición de exportar "even just a simple text list of our downloaded and favorited soundscapes".

**Qué podemos aprender.** El control espectral fideliza; la honestidad técnica vende; el pago único de 20 $ se defiende con orgullo. Pero mezclar generadores es caro en CPU para un motor basado en muestras, y perder el mezclador rompió la confianza.

**Hueco para SleepNoise.** El mezclador de seis capas en tiempo real que myNoise ya no tiene; control de timbre con un gesto en lugar de 10 sliders; volumen propio independiente del sistema; exportación de mezclas; localización al español (27 valoraciones en ES, ficha en inglés). Precio: 29,99 $ es narrable como "síntesis viva frente a catálogo grabado"; por debajo de 19,99 $ SleepNoise se colocaría debajo de myNoise.

Fuentes: https://apps.apple.com/us/app/mynoise-the-soundscape-app/id1523675125 · https://apps.apple.com/es/app/mynoise-the-soundscape-app/id1523675125 · https://mynoise.net/blog.php · https://mynoise.net/faq.php · https://mynoise.net/donate.php · https://mynoise.net/oneTimeLetter.php · https://apps.apple.com/mx/app/mynoise-ruido-blanco-a-medida/id1523675125

#### 9. Dark Noise

**Qué es.** La app indie de ruido mejor integrada en iOS: "50+ ambient sounds with animated icons", mezclas con nombre y volumen por capa (desde v2, 2020), **Magic Mix** por prompt con Apple Intelligence (v3.5, 14-09-2025), temporizador con fade, Shortcuts/Siri (incluido HomePod), widgets interactivos, Live Activities (2023), control de Centro de control (2024), StandBy, AirPlay, 10 temas incluido True Black, 20+ iconos, Mac; v3.6 (12-09-2026) rediseñó el Now Playing con Liquid Glass; v3.6.1 (17-10-2026) requiere **iOS 26**. Grabaciones en bucle largo: **430 MB**. Historia pública de negocio (blog de Charlie Chapman): lanzamiento 27-08-2019 a pago anticipado, día 1 "990 copies, $4,190", mes 1 4.545 descargas y 19 K$ brutos, después "20-30 downloads a day"; rebaja al 50 % (dic. 2020): conversión +59,3 % (elasticidad de arco ≈ −0,7); 2022 "sales were down pretty significantly"; marzo 2023 MAU 11-12K, DAU 2.300-2.500, "Brown Noise is the most-played sound"; abril 2023 Dark Noise 3.0 freemium con Pro y lifetime, antiguos compradores conservan Pro ("Dark Originals"). MacStories (2019): "Beautiful, whimsical, delight-inducing design is hard to put into words"; "Dark Noise's design is what really pushes it over the edge". App of the Day.

**Para quién.** Usuario del ecosistema Apple que valora el diseño y la integración (r/Apple, MacStories), uso mixto noche + concentración: "I listen to a customized Thunder/Rain/Crickets sound while I work and it's perfect"; TDAH ("the gray noise is so amazingggg i got this originally for my ADHD", 2026); tinnitus ("the deep brown noise… kept my Tinnitus at bay", 2025); padres ("Yo la uso para mi hijo… le pongo el ruido de la aspiradora", ES 2020).

**Precio exacto y modelo.** Gratis (8 sonidos, loop, Siri, timer) + Pro 2,99 $/mes, 19,99 $/año (prueba de 1 semana según reseña de 11-08-2024), **lifetime 49,99 $**; España 22,99 €/año, 59,99 € lifetime; MX 999 MXN; CO 229.900 COP. 4,8 / 3,7K (ES 4,8 / 73). Posicionamiento del autor: "that market tends to prefer paying up front and is a little more averse to ads". Web: "Simple. Fast. White noise, refined.", "Independent since 2019", "Made by Charlie Chapman in St. Louis, MO".

**Diseño visual y tono.** Rejilla de iconos lineales monocromos que se animan al reproducir, tipografía del sistema, temas, estética Apple-native; es el referente más cercano al tono Bear que busca SleepNoise. Subtítulo de ficha como saco de keywords ("Green Brown Pink White Sleep"); no localizado al español.

**Lo que aman.** "Best single purchase app for soundscapes… I hate subscription services so I try and avoid anything that is based on that platform" (2022); "doesn't contain any greedy micro-transactions or stupid subscriptions and is just sold for one fair price" (2020); "collects no data, has no subscription ask" (2021); "Dark Noise does a great job of staying out of your way"; "the best Shortcuts support I've seen in any sound app!"; "you can control the volume of the dark noise app independently of other audio apps. that feature alone makes this app indispensable" (2026); "I have an automation to play drippy rain on my home pods each night" (2025); "Whenever I'm out of Wi-Fi… I know I can rely on Dark Noise" (2023).

**Lo que odian.** **"Brown noise has audible 'jump' when it loops… Only brown is affected and that's the one I downloaded the app for"** (06-01-2025); "Sounds cycle repeat often, they sound like a broken record" (2025); "if I have it on and I get a text, call or an alert on my phone, the app CHANGES my sound… to a real low and soft WHITE NOISE sound about 8-10 seconds after the alert" (2025, usuario con tinnitus); "the moment the timer stops the sound and my body naturally wakes up"; "Sound quality is off… the sounds sound thinned out"; "[Almost] all sounds are monaural" (2020); "I wish that it had EQ sliders"; "all my custom mixes are still here by name but contain no sounds" (2024); sobre precio: "The paid version price is ridiculous at $20 per year. This would be a perfect app for a lifetime price of maybe $5" (2025); "that I must now pay, AGAIN, every year, to continue using an app that I already bought"; "almost $2 a month??? Settings -> Accessibility -> Audio -> Background Sounds. Just saying" (2024); MX: "Aunque todo cue$ta a mi me parece caro" (2024); petición: "Would love to see an Apple Watch app—being able to use Dark Noise at night without reaching for my iPhone" (2026).

**Qué podemos aprender.** Es la vara de medir de la integración iOS y la prueba de que el lanzamiento indie se hace con prensa Apple-centric, beta pública y Reddit. Pero su audio son muestras en bucle (el "jump" del marrón) y el precio lifetime de 49,99 $ solo parece razonable porque está al lado de un anual de 19,99 $.

**Hueco para SleepNoise.** Síntesis sin costuras (ataca su queja técnica más citada), robustez de sesión ante notificaciones, Apple Watch autónomo, localización al español (73 valoraciones en ES, cero en búsquedas en español), y un modelo sin suscripción al lado.

Fuentes: https://apps.apple.com/us/app/dark-noise-ambient-sounds/id1465439395 · https://apps.apple.com/es/app/dark-noise-ambient-sounds/id1465439395 · https://darknoise.app/ · https://darknoise.app/releases · https://darknoise.app/posts/dark-noise-3_5 · https://www.macstories.net/reviews/dark-noise-review-ambient-noise-never-looked-so-good/ · https://www.macstories.net/news/dark-noise-3-0-has-a-new-business-model-and-a-few-other-updates/ · https://charliemchapman.com/posts/2019/9/4/dark-noise-week-1/ · https://charliemchapman.com/posts/2021/1/1/first-sale/ · https://charliemchapman.com/posts/2023/3/1/2023-dark-noise-stats/ · https://charliemchapman.com/posts/2023/4/2/dark-noise-3/ · https://heydingus.net/blog/2023/4/dark-noise-does-the-subscription-transition-right · https://justuseapp.com/en/app/1465439395/dark-noise-sound-machine/reviews

#### 10. White Noise (TMSoft)

**Qué es.** La utilidad veterana (2008-2009, "#1 overall spot on iTunes when it was initially released"): "50+ looping sounds" más White Noise Market con "50,000+ free sounds" subidos por usuarios, grabación y loop de sonidos propios, Mix Pad, temporizador y alarmas con fade, reloj de mesilla, Apple Watch y Apple TV; v9.0.6 (06-11-2026) con "new audio engine", Siri/Shortcuts y widget. IAP "Generator" (ruido coloreado, binaurales, tonos) por 0,99 $. El negocio migró al streaming: su podcast "White Noise Sleep Sounds" recibe ~50.000 escuchas/día en Spotify y, según Bloomberg (2023), el streaming aporta ya la mayoría de los ingresos.

**Para quién.** Veterano que lleva una década ("I bought this app in 2010 with the birth of my first child", 2023), padres, oficinistas ("I work in a noisy office… this app has saved my sanity", 2018), gente que duerme en el coche ("I use the app on lunch breaks, as I sleep in my car", 2017); España: White Noise Lite "para ocultar y camuflar todo tipo de ruidos en un piso tan ruidoso como este" (2017), "I use this when I travel all the time" (ES 2025).

**Precio exacto y modelo.** iOS 0,99 $ (Full) + Generator 0,99 $; Lite gratis; Pro 2,99 $; 0,99 € en España. "No subscription required, ever". 4,8 / 46K en la ficha actual; la web cita "4.8 ★ from 271k App Store reviews" históricas.

**Diseño visual y tono.** Fotos a pantalla completa por sonido, reloj digital grande, múltiples menús; estética de 2010; marca "utilidad".

**Lo que aman.** "the fact that the UI and features have stayed exactly the same for years is a HUGE plus" (2026); "Worth every penny" (2026).

**Lo que odian.** Sleep Foundation: "Volume differs noticeably between sounds" y "Free sounds have fairly short loops"; "The option menus are not very intuitive, and they are confusing" (2020); "The upgrade wipes all the playlist, mix creations, and manually recorded sounds"; "your sleep noise stops. Suddenly." (2017); un usuario pide "a sort of low-pass frequency filter" para las mezclas.

**Qué podemos aprender.** El suelo del nicho es 0,99 $ y "gratis y en bucle" en Spotify. La estabilidad de la UI durante años es un elogio en este público. La petición de pasa-bajos es la misma de Rain Rain (Soften) y myNoise (sliders).

**Hueco para SleepNoise.** No competir en precio ni en catálogo: competir en que nada se corta, nada se pierde al actualizar, y el timbre se controla con un gesto.

Fuentes: https://apps.apple.com/us/app/white-noise/id289894882 · https://apps.apple.com/us/app/white-noise/id289894882?see-all=reviews · https://www.tmsoft.com/white-noise/ · https://www.tmsoft.com/about/ · https://podcastmovement.com/podmov/white-noise-podcasts-spotify-revenue/ · https://apps.apple.com/es/app/white-noise-lite/id292987597?see-all=reviews · https://www.sleepfoundation.org/best-sleep-apps/best-white-noise-apps

#### 11. Noisli

**Qué es.** El referente estético de 2014-2016 (fondos de color que cambian lentamente, iconos lineales) convertido en negocio web de productividad: 16 sonidos (free) / 28 (Pro) en la web, mezclas de lluvia, viento, bosque, océano, fuego, cafetería y ruido blanco/rosa/marrón, combos guardados con cuenta opcional, timer Pomodoro con fade. La app iOS está en **v1.1.4 del 19-04-2017**, 266 MB, requiere iOS 7: abandonada en la práctica.

**Para quién.** Nostálgicos y usuarios de productividad; algunos la siguen comprando por el precio.

**Precio exacto y modelo.** iOS 1,99 $ pago único; web Free / Pro 8 €/mes facturado anual (≈96 €/año) / Business 20 €/mes. 4,2 / 255.

**Lo que aman.** "No tricks. It's just… peaceful" (2023); "worth the small fee to have this available when I'm not connected to WiFi" (2020); "The white/pink/blue noise worked well to help with my tinnitus" (2020).

**Lo que odian.** "Good but shoulda saved the $2" (2020); "does not have a customizable timer"; "The sound samples are way too short (a few seconds)" (2015); "Won't output sound to another device such as an Apple HomePod… Wasted $1.99" (2024); sigue sonando tras cerrarse (2016).

**Qué podemos aprender.** La marca del "minimalismo bonito" en este nicho está vacante en iOS desde 2017; y 1,99 $ ancla a "utilidad" tan fuerte que incluso dos dólares se discuten.

**Hueco para SleepNoise.** Ocupar la estética que Noisli dejó libre con audio que no son "samples of a few seconds" y con AirPlay.

Fuentes: https://apps.apple.com/us/app/noisli/id862773459 · https://www.noisli.com/pricing · https://www.veilsleep.app/best-white-noise-apps · feed RSS de reseñas US (id 862773459)

#### 12. Rain Rain Sleep Sounds

**Qué es.** "Over 100 endless sounds", 50+ HD gratis sin límite de tiempo, mezclador con volumen individual y mezclas en iCloud, dos efectos que son la mejor pista de UX de la categoría para "modular sin tecnicismos": **Oscillator** (fade in/out cíclico a velocidad ajustable) y **Soften** ("reduces high frequencies to mimic sound from another room"); temporizador con fade y recordatorio. v6.9.10 del 22-01-2025; idiomas EN, FR, IT, **ES** (4,75 / 286 en España). 4,8 / 138K.

**Para quién.** Público masivo de lluvia; neurodivergentes ("The neurodivergent mind is always active… nature sounds while sleeping always helps", 2026; "I have misophonia and sensory issues and this app is a godsend… being able to muffle the sounds", 2026); parejas ("My husband doesn't like hearing people talking on sleep stories, so I'll often use these sounds", 2026); duelo ("Redownloaded since she passed a month ago", 2026).

**Precio exacto y modelo.** Gratis + Premium 3,99 / 5,99 $ (legacy), mensual 9,99 $, anual 29,99 / 35,99 $, packs 4,99 $, "One Sound Token" 1,99 $; España Premium anual 30,99 €, packs 5,99 €; MX 599-799 MXN; prueba 7 días.

**Diseño visual y tono.** Lista de tarjetas con foto y nombre sobre azul oscuro; funcional, no premium.

**Lo que aman.** "the widest selection of sounds that you cannot tell is a loop" (2026); "no se repiten los truenos ni ningún sonido" (MX, 2011); "los sonidos son muy naturales y no se escuchan repetitivos como en otra aplicación… 3 segundos y se repetía lo cual era muy estresante" (MX, 2015); "olas+viento+truenos=tempestad en alta mar… ¡Yo me creo los escenarios!" (ES, 2015); "El temporizador es un logro" (ES, 2018); "Se escucha con el móvil bloqueado, en segundo plano" (ES, 2025).

**Lo que odian.** "I can't support greed" (2023, al pasar a suscripción); "would give five stars if it were a one-time purchase"; **"the fade out mutes my phone so I don't hear my alarm set for 10 minutes later"** (2026); "The max on a phone is 3 but I feel like it needs more" (2026); "I'll go from 3/4 of a battery to it dying in the middle of the night" (2026).

**Qué podemos aprender.** Los usuarios perciben y premian la ausencia de bucle audible, piden más de 3 capas y castigan un fade que silencia la alarma del sistema. Oscillator y Soften son el vocabulario de la modulación lenta y el pasa-bajos en lenguaje de cliente.

**Hueco para SleepNoise.** Seis capas, oscilación lenta y "suavizar" aplicables a cualquier textura sintetizada, fade que no toca el volumen del sistema, consumo de batería publicado.

Fuentes: https://apps.apple.com/us/app/rain-rain-sleep-sounds/id478687481 · https://apps.apple.com/us/app/rain-rain-sleep-sounds/id478687481?see-all=reviews · https://apps.apple.com/mx/app/rain-rain-sleep-sounds/id478687481 · feed RSS de reseñas US/ES/MX (id 478687481)

#### 13. Tide

**Qué es.** Paisajes de naturaleza descargables, meditaciones (en inglés), respiración 4-7-8 y box breathing, Pomodoro con sonido, sleep tracking con grabación de ronquidos, Apple Watch con HRV, rutinas de bedtime, "gentle-wake alarm". 490 MB; v5.13.0 del 03-11-2026; "App Store Best of 2017". 4,8 / 8,4K.

**Para quién.** Estudiante o joven profesional que usa la misma app para estudiar y dormir.

**Precio exacto y modelo.** Gratis + Tide Plus 9,99-11,99 $/mes, 54,99-59,99 $/año; planes históricos 1,99 $/mes y 15,99 $/año; España 39,99 €/año, 3,49-12,99 €/mes; MX 799 MXN/año.

**Diseño visual y tono.** El más cercano a "editorial" del segmento: fotografía a sangre, tipografía serif/grotesca cuidada, mucho aire. Buen referente de tono visual, pero en dirección opuesta (contenido, no instrumento).

**Lo que aman.** "Ads free and minimalist design is really great"; "I use it every night for white noise while I sleep"; "Tide forces nothing on it's users when it comes to making additional payments".

**Lo que odian.** **"The pricing model is way too expensive for what the app is"** (10-2024); "This app has frozen in IOS in focus mode" (10-2024); funciones gratuitas movidas al paywall; tracker que deja de guardar; ES (2023): "la herramienta de sonido integrada en iOS es más sencilla".

**Qué podemos aprender.** El diseño editorial no compensa un precio percibido como desproporcionado para "lo que la app es". La respiración y el sonido viven en Tide como funciones separadas, no acopladas.

**Hueco para SleepNoise.** Acoplar sonido y respiración (Marea) y vender el peso (490 MB frente a pocos MB) como argumento.

Fuentes: https://apps.apple.com/us/app/tide-sleep-focus-meditation/id1077776989 · https://apps.apple.com/us/app/tide-sleep-focus-meditation/id1077776989?see-all=reviews · https://tide.fm/en_US/ · feed RSS de reseñas ES (id 1077776989)

#### 14. Portal – Escape Into Nature

**Qué es.** El "lujo digital" del segmento: "Over 100 portals" con audio espacial head-tracked, vídeo "up to 12K", integración Hue/Nanoleaf/HomeKit, "Circadian Flow", alarma de amanecer, respiración, Pomodoro, Live Activities. Un portal a la vez (sin mezclador clásico). 283,9 MB; requiere iOS 18.4; v4.1.1 del 28-10-2026. Premios: Editors' Choice ("the prettiest clock you've ever seen"), "App Of The Year Finalist", Webby "Best Visual Design, People's Choice"; **sin Apple Design Award** (la segunda ronda lo confirmó). 4,8 / 10K (ES 4,6 / 220).

**Para quién.** Amante del diseño que quiere una ventana a la naturaleza en el salón o la mesilla; también usuarios de concentración.

**Precio exacto y modelo.** Gratis (3 portales rotativos al mes) + 5,99 $/mes, 29,99 $/año, **lifetime 99,99 $**; España 3,99 €/mes, 19,99 €/año, lifetime 59,99 €; MX 249/50 MXN y 749 MXN lifetime. Frase clave de la ficha: **"Try Premium free for 7 days: no upfront payment details, no auto-subscribe and no need to cancel"**: precedente aprobado de una prueba sin tarjeta en la misma categoría. Antes fue pago único ("they allowed the users who previously paid the $4 to buy the app to keep the full version").

**Diseño visual y tono.** Pantalla completa, controles mínimos, transiciones cuidadas; "Portal is an app that should be studied" (08-2025), "one of the most beautiful applications I've come across" (10-2025). Depende de vídeo, red y 284 MB.

**Lo que aman.** Las citas anteriores y "the monetization model was really wonderful".

**Lo que odian.** "a lot of sounds are locked behind paywall"; "the app needs an internet connection to run".

**Qué podemos aprender.** Apple premia editorialmente la experiencia cuidada y un lifetime a 99,99 $ se sostiene con producto excepcional. La prueba de 7 días sin tarjeta pasa App Review.

**Hueco para SleepNoise.** El mismo nivel de acabado sin vídeo ni red: un lienzo monocromo que respira con el DSP, y una prueba "7 noches, nada que cancelar" con el mismo lenguaje que Portal.

Fuentes: https://apps.apple.com/us/app/portal-escape-into-nature/id1436994560 · https://apps.apple.com/us/app/portal-escape-into-nature/id1436994560?see-all=reviews · https://apps.apple.com/es/app/portal-escape-into-nature/id1436994560 · https://apps.apple.com/mx/app/portal-rewild-your-mind/id1436994560 · https://portal.app

#### 15. Atmosphere, Bedtime Fan y Noise Machine (utilidades freemium de nicho)

**Qué es.** Tres apps que muestran el tamaño de los nichos y el coste de la publicidad. **Atmosphere: Relaxing Sounds** (Peak Pocket Studios): "over 70 relaxing sounds" en 9 entornos, binaurales e isocrónicos, mezclador con volumen por sonido y mezclas guardadas, timer que cierra la app; v5.2 del 15-08-2024 con "bug fixes" de "background sounds stopping". **Bedtime Fan, White Noise Baby** (Slumber Studios): 8 ventiladores grabados, hogueras, lluvia, grillos, 5 binaurales, sin mezclador real, timer con fade y "End Time"; v2.33.0 del 02-10-2026; **4,8 / 205K**: el nicho "ventilador" por sí solo mueve más valoraciones que myNoise y Dark Noise juntos multiplicado por 50. **Noise Machine — Brown, White** (ZipoApps): ruido blanco, rosa, verde y marrón **generados**, "Background Mix" para sonar sobre otras apps, sin mezclador, timer con fade; v6.2.6 del 01-07-2026; 4,6 / 4,3K.

**Para quién.** Casual con anuncios (Atmosphere), padres de bebés (Bedtime Fan: ilustración de ventilador y botones grandes), TDAH/ruido marrón (Noise Machine).

**Precio exacto y modelo.** Atmosphere: gratis con anuncios + "Ad-free" 4,99 $ único. Bedtime Fan: gratis con anuncios + Premium 19,99 $/año (y variantes 0,99-14,99 $), "Unlock All" 7,99 $, quitar anuncios 4,99 $. Noise Machine: gratis + lifetime 6,99-9,99 $, "Unlimited Noise" 12,99-19,99 $, suscripción 9,99 $; lista confusa de 11 IAP.

**Diseño visual y tono.** Ilustraciones flat de colores y tarjetas (Atmosphere, aspecto de app Android portada); ventilador ilustrado orientado a padres (Bedtime Fan); utilitario (Noise Machine).

**Lo que aman.** Nichos muy concretos resueltos: el ventilador de toda la vida; el ruido marrón que suena sobre un podcast.

**Lo que odian.** Atmosphere: "better volume balance between sounds", poder "edit saved favorites", un glitch que despertó a alguien "at 3 AM". Bedtime Fan: "After running the fan on medium for a few hours it started making a higher pitch sound" (09-2024); "the fan sound can be a little bit better". Noise Machine: **"A skip keeps me from going to sleep, and can absolutely wake me up if I hear it"** (03-11-2025); "it seems to require an internet connection far more often than it should".

**Qué podemos aprender.** Incluso apps de "ruido de color" usan archivos con costuras y red; el ventilador y el marrón son puertas de entrada enormes; 11 IAP sin nombre destruyen la confianza.

**Hueco para SleepNoise.** Un ventilador sintetizado que no cambia de tono a las tres horas, un marrón sin costuras, un solo IAP con nombre, cero anuncios.

Fuentes: https://apps.apple.com/us/app/atmosphere-relaxing-sounds/id1259186300 · https://apps.apple.com/us/app/bedtime-fan-white-noise-baby/id907295335 · https://apps.apple.com/us/app/noise-machine-brown-white/id1261956119

#### 16. Slumber Studios y las micro-apps hispanas de ruido blanco

**Qué es.** El bloque que domina las búsquedas en español. **Sonidos para Dormir y Relax / White Noise Deep Sleep Sounds** (Slumber Studios, id 1083248251): ES 4,73 / 1.216; Sleep Foundation señaló loops de ~10 segundos en su versión gratuita. **Ruido blanco para dormir bebés** (P. Kaluzynski): #1 en la búsqueda "ruido blanco" en España (4,71 / 991) y top 2 en MX, AR y CO. **White Noise: Ruido Blanco App** (冬魁 岳): #1 en MX (875 valoraciones), ES 4,75 / 616. **Ruido Blanco HQ / Sonidos de Lluvia HQ / Relajantes sonidos para dormir** (Phase4 Mobile): 119-452 valoraciones. **Sonidos para dormir** (鋆 张): #1 en "sonidos para dormir" en MX y ES con 306-340 valoraciones. Muchas fichas son traducciones automáticas de apps coreanas, rusas o chinas (los URL muestran nombres en hangul o cirílico).

**Para quién.** Padres hispanohablantes (38 reseñas del corpus mencionan bebé/hijos/niños: "Desde que mi hija nació se dormía con el sonido blanco del ventilador, y con 5 meses sigue funcionando", Slumber ES 2019; "Hasta los 9 meses le poníamos el sonido de matriz. Ahora el de olas del océano", ES 2020; "En mi casa solo se escucha el shhhh", ES 2026), estudiantes ("Me ayuda a desconectar del entorno pero sin distraerme; también ayuda con los acúfenos", Slumber ES 2021), gente en hostales ("Lo uso cuando duermo en hostales y hay gente que ronca", White Noise App ES 2025), vecinos ("Bloquear el ruido que producen en el parque de juego de abajo de mi casa", ES 2026).

**Precio exacto y modelo.** Gratis con anuncios e IAP baratos; ninguna app de ruido cobra la descarga en MX/ES/AR/CO salvo White Noise (TMSoft) a 0,99 € y "SoundNC" a 19 MXN.

**Diseño visual y tono.** Rejillas de fotos de stock, copy de traducción automática, anuncios intersticiales.

**Lo que aman.** "El ruido marrón ha sido un descubrimiento! Perfecto para dormir" (Slumber ES, 18-06-2018: la única mención de "ruido marrón" en 1.197 reseñas en español); "Acúfenos: a mí me ha ayudado muchísimo a poder conciliar el sueño" (Slumber ES, 2017); "We are all addicted to the sounds. I love this App!" (Slumber US, 2026).

**Lo que odian.** "Lo malo es que solamente dura 1 hora" (Slumber ES, 2016); "Falta sonido de corazón" (White Noise App ES, 2023); **"Anuncios pornográficos"** (White Noise App ES, 2024) y "Full of spam and porn" (White Noise HQ US, 2025); "Funde la batería" (Slumber ES, 2018); "even when plugged and charging and set for 11 hours, it will sometimes arbitrarily just quit in the middle of the night" (White Noise HQ, 2025); "THEY CHANGED MY FAN… now sounds more static wooshy and has little TINKS IN IT… I need consistent noise" (White Noise HQ, 2024); "an intermittent beeping that now keeps me awake" (2024).

**Qué podemos aprender.** En español "ruido blanco" ya pertenece a los padres; el líder genérico en España tiene menos de 1.000 valoraciones; rankea quien lleva la keyword en el título; el vocabulario de categoría es "sonidos para dormir" (122 apariciones de "sonidos" frente a 20 de "ruido"); "ruido café", "ruido rosa" y "brown noise" tienen cero apariciones en reseñas.

**Hueco para SleepNoise.** Una ficha es-ES y es-419 escrita por un nativo con "Ruido Blanco" en el título y "para dormir" en el subtítulo, sin anuncios, con temporizador largo y modo bebé con límite de volumen y aviso de distancia. Decisión pendiente: si se entra en el segmento bebé (monetiza: Napper) o se renuncia a la keyword para no diluir el posicionamiento adulto.

Fuentes: https://itunes.apple.com/search?term=ruido+blanco&country=es&entity=software&limit=25 · https://itunes.apple.com/search?term=ruido+blanco&country=mx&entity=software&limit=25 · https://itunes.apple.com/search?term=sonidos+para+dormir&country=es&entity=software&limit=25 · feed RSS de reseñas ES/MX/CO/AR/US (ids 1083248251, 1481584395, 1500423385, 888963581, 1577010193) · https://www.sleepfoundation.org/best-sleep-apps/best-white-noise-apps

### C. Audio generativo, adaptativo y sintetizado

#### 17. Veil

**Qué es.** El único rival que reclama lo mismo que SleepNoise: síntesis en tiempo real documentada con detalle público. Desarrollador individual **Colin Shepard Hanson**, ingeniero de software de Nueva York, "lifelong light sleeper" cuyo detonante fue que el aire acondicionado de ventana era su mejor enmascarador "pero solo funcionaba en verano" (blog, abril 2026). Lanzada el 02-04-2026, v1.5.5 del 12-11-2026, 64,9 MB, iOS 15.1+, Mac (Apple silicon) y visionOS; sin app de Watch. Motor: ruido blanco por muestras aleatorias, rosa por integradores en cascada, marrón por integrador con fugas, ventiladores como ruido filtrado + LFO; lluvia "synthesized, drop by drop, on your phone" con miles de impactos individuales en dos capas de longitud distinta para no repetirse en ~283 días, cinco controles en vivo (Density, Closeness, Patter, Puddles, Lightness) y sin trueno "so there is nothing that could wake you". 28 sonidos (6 colores, 7 ventiladores, 8 mecánicos, 4 de naturaleza, 3 tonales). **Studio**: EQ paramétrico de tres puntos con anchura ajustable (muescas posibles). Mezclador de **3 capas**, timer 20 min-24 h con fade, reloj atenuado, rutinas, widgets, Siri/Control Center en iOS 18+, AirPlay. Nada parecido a la Marea respiratoria. Ficha localizada a 19 idiomas ("Veil: Ruido Blanco para Dormir — Ventilador, Rosa y Marrón"). Su blog ya ocupa el discurso anti-tracker ("Can sleep scores make sleep worse?", citando Baron 2017: "no score", "no streak").

**Para quién.** Light sleeper técnico que llega por Reddit: "Really simple private app" (MarkMiller455, 11-04-2026, que estuvo a punto de pagar otra app).

**Precio exacto y modelo.** Gratis (6 sonidos "uno a la vez, sin límite de tiempo ni anuncios") + Premium 2,99 $/mes, 11,99 $/año (prueba 7 días), **lifetime 24,99 $** (ES 22,99 €, MX 399 MXN, AR 19,99 USD, CO 99.900 COP). Confesión útil del fundador: el pago único es "the right default for a utility app", pero añadió mensual/anual "porque mucha gente dudaba en pagar por adelantado". 5,0 / 26 en EE. UU.; **0 valoraciones en ES y MX**; Google Play 4,2 / 32 [P]. La etiqueta de privacidad de la ficha declara "Third-Party Advertising: Device ID, Advertising Data" aunque la descripción dice no tener anuncios.

**Diseño visual y tono.** Discurso de ingeniero, no de diseño; página de comparación propia frente a Dark Noise (53,9 MB frente a 429,7 MB) donde admite carecer de widget de bloqueo, app Mac nativa y "Magic Mixes". Claims: "Fall asleep in minutes", "Sleep through anything", techo de ~50 dB citando "sleep researchers" sin fuente; pasó App Review.

**Lo que aman.** "Big fan of the UI and tuning feature" (10-04-2026).

**Lo que odian.** Sin muestra suficiente (26 valoraciones). Su propia 1.5.5 "improves overnight playback reliability".

**Qué podemos aprender.** La tesis técnica de SleepNoise ya existe en el mercado ocho meses antes y a 24,99 $; el lifetime solo no convertía ni para quien lo defiende ideológicamente; la localización a 20 idiomas aún no le ha dado tracción fuera de EE. UU.

**Hueco para SleepNoise.** Diferenciarse por **experiencia + fisiología + diseño**, no por "somos los únicos que sintetizamos": seis capas frente a tres, Marea respiratoria, diseño de nivel editorial, etiqueta "Data Not Collected" frente a su "Advertising Data", prueba completa de 7 días frente a free tier de un sonido, y publicar en español antes de que Veil acumule valoraciones.

Fuentes: https://veilsleep.app · https://veilsleep.app/blog/why-i-built-veil · https://veilsleep.app/blog/rain-sounds-for-sleep · https://veilsleep.app/blog/can-sleep-scores-make-sleep-worse · https://veilsleep.app/compare/veil-vs-dark-noise · https://apps.apple.com/us/app/veil-white-noise-sleep-sounds/id6760920621 · https://apps.apple.com/mx/app/veil-ruido-blanco-para-dormir/id6760920621

#### 18. Slo (y los otros indies de pago único: Sonora, NoiseNest, Nava, Ambi, Noizio, Sleep Machine)

**Qué es.** **Slo: Sleep Sounds, Brown Noise** (Karlie Alexis Kowalska, lanzada 19-12-2024, v3.135.17 del 15-11-2026 con cadencia casi diaria, 104,8 MB, 33 idiomas): librería de **grabaciones en bucle** ("each loops seamlessly"), 150+ sonidos, opción "Soft, Deep, Deepest" (oct. 2026) y, desde noviembre de 2026, **inicio de sesión opcional** para sincronizar mezclas. Competidor de SEO (decenas de páginas "Slo vs X") más que de producto. Alrededor: **Sonora** (sangen GmbH, 1 valoración, sin actualizar 5 meses, "AI-driven Sound Therapy" que analiza la voz, "100% free"); **NoiseNest** (tres apps homónimas con 0 valoraciones; la de Ron Vaisman: 234 sonidos, mezclas de 6 capas, Pro lifetime, sin cuenta, 27 MB); **Nava** (78 sonidos, 3 capas, Live Activities, 0 valoraciones, Pro por suscripción pese a los roundups); **Ambi** (61,6 MB, 4,92 / 92, sin IAP visibles, Show HN oct. 2025); **Noizio** (desde 2015, 4,52 / 242, todo gratis + compra única, Family Sharing, VoiceOver); **Sleep Machine** (3,99 $ desde 2009, 4,73 / 3.016, sin actualizar desde 2021).

**Para quién.** Buscadores de "brown noise" y "tinnitus masking" en Google.

**Precio exacto y modelo.** Slo: 5,99 $/mes, 29,99 $/año, **Lifetime 49,99 $ y un segundo Lifetime a 24,99 $** (dos SKU sin explicación). Privacidad: rastreo con identificadores, nombre, email, ubicación aproximada y compras para publicidad de terceros. 4,8 / 68 (ES 4,43 / 7; MX 3,0 / 1).

**Diseño visual y tono.** Ficha ES literal que ha pasado App Review: **"El ruido marrón no trata nada — enmascara"**. Mezcla "Pink Noise and River for Tinnitus Masking". Su comparación con Endel: "Endel changes the sound for you; Slo keeps the mix you set".

**Lo que odian.** El sonido de cascada "fades out then starts again" y "not looped"; poner el timer "takes 4 touches" (08-08-2025). En HN sobre la categoría: "The other white noise apps I use for my kids when we travel work on a subscription"; varios piden poder filtrar la App Store por "sin suscripción".

**Qué podemos aprender.** El ciclo de copia en esta categoría es de meses (decenas de indies nuevos en 2025-2026); el que añade cuentas pierde su argumento; "no trata nada: enmascara" es una fórmula aprobada en español.

**Hueco para SleepNoise.** Ser el único del grupo sin cuentas, sin rastreo y con síntesis; registrar la descripción de la Marea en vídeo y capturas antes de que un indie la copie.

Fuentes: https://apps.apple.com/us/app/slo-sleep-sounds-brown-noise/id6739538343 · https://slonoise.com · https://slonoise.com/compare · https://itunes.apple.com/lookup?id=6742666392&country=us · https://itunes.apple.com/search?term=noisenest&country=us&entity=software · https://itunes.apple.com/search?term=nava%20noise&country=us&entity=software · https://itunes.apple.com/search?term=ambi%20white%20noise&country=us&entity=software · https://itunes.apple.com/search?term=noizio&country=us&entity=software · https://news.ycombinator.com/item?id=45558611

#### 19. Endel

**Qué es.** El único "generativo de verdad" con escala. Endel Sound GmbH (Berlín, 2018, Techstars Music; inversores Alexa Fund, Warner Music, Sonos; Serie A de 5 M$ en 2020). Página de tecnología ("Endel Pacific", patentada): inputs de hora, luz natural, hora de dormir, clima, pulso del Apple Watch, movimiento y posición de la cabeza; el audio se genera "in real-time, on-device" a partir de "sound logic and elements" prediseñados por humanos mapeados por un "AI-powered node system". Es decir: **stems compuestos por humanos + reglas de mezcla parametrizadas**; ninguna red neuronal genera audio. Nadie, ni Endel ni ningún reseñador independiente, describe qué pasa con el sonido cuando el pulso baja de 70 a 55. Ciencia: cita un estudio de **foco** (Arctop/Haruvi 2022, "7x") y notas al pie de estudios ajenos sobre ruido; para sueño no hay estudio propio. Premios: Apple Watch App of the Year 2020, Editors' Choice, Google Play Best of 2021; sin ADA. "over 4 million downloads" [P]; ARR estimado 15,8 M$ (GetLatka, no oficial). 337,6 MB; requiere iOS 26; Watch standalone, Apple TV, Vision; alianzas con Sony, Mercedes-Benz y Amazon Music. Subtítulo pivotado a "ADHD Productivity Timer" (EE. UU.) / "ADHD Sounds for Focus" (UK).

**Para quién.** Early adopter, TDAH ("literally Ritalin for the ears", Endel CO 2023; "ADHD saver", ES 2023; "I'm a therapist and I have ADHD"), horarios caóticos ("I have a very chaotic schedule with different work schedules", ES 2026).

**Precio exacto y modelo.** 1 mes 2,99 / 7,49 / 19,99 $; 12 meses 34,99 / 59,99 / 119,99 $; **Lifetime 124,99 $**; España 17,99-59,99 €/año, lifetime 300 € (2024) y 150 € con "50 % OFF" permanente (2026); MX 359-1.299 MXN. Sin trial de 7 días en la app según Pratt (02-2026); tier gratuito con sesiones limitadas. Trustpilot **2,8/5, 58 % de 1★**. 4,6 / 34K (ES 4,55 / 1.113).

**Diseño visual y tono.** Protey Temen: inspiración en "the minimalist art movement", "experimental music notations" y "sci-fi worlds"; arranque con "thin white lines and sparkling dots appear on a black screen"; cada soundscape tiene una "semi-generative animated visualization"; Stavitsky: "black-and-white, minimal, a bit enigmatic", no gamificada. Crítica de Pratt Institute (02-2026): controles "small and less prominent", salida por gesto sin señalizar ("users must rely on habit or trial and error"), límite gratuito que corta a los ~10 min sin aviso; UX Planet: "an overload of text that can be daunting".

**Lo que aman.** "my nervous system has never been more stable and calm" (Trustpilot); "It's like your drawn to sleep by some magical spell"; "The personalization is effective and invaluable compared to other free and generic sound apps"; "Solo duermo 5 horas y con la aplicación mi calidad y duración de sueño ha mejorado" (CO, 2023); "A descansar cuando da vueltas la mente" (ES, 2026).

**Lo que odian.** "I cancelled 1-2 days BEFORE the free trial ended, yet I was charged for a year long subscription."; **"The app lets you start a free trial but charges you $120 immediately."**; "Why should I have to get set up under subscription just to try the free trial?" (10-2025); "they will incessantly bug you to buy a 'lifetime subscription'" (IE, 2025); "every time I open the app, I'm given a full-screen ad to buy a yearly subscription" (suscriptor); **"The sounds are NOT personalized."**; "There's nothing on this that seems to be 'adapting' to me specifically"; "I find it frustrating when I'm nearly asleep and I'm awoken by the timer."; "the music is annoying and repetitive my ADHD brain does not like it"; "The new sound scape has a rustling sound like crunching paper"; ES: "te hace contratar 3 meses con la condición de una prueba gratuita y te cobra al momento" (2024); "Primero tarjeta, luego prueba… ¿Por qué no dejáis hacer la prueba gratuita sin tener que poner la tarjeta?" (2023); "Soy estudiante y no tengo 50 euros para una aplicación, encima para siempre son 300 EUROS!!" (2024); "en otros se forma un caos que me pone de los nervios… demasiado artificiales, así sonaban los instrumentos electrónicos en los 80" (2023); "dangerous for using while sleeping… may end as bad dreams" (2024); "no sé cómo escuchar los sonidos ambientales sin el temporizador… cuando se pare me tengo que despertar para volverlo a ponerlo" (2024); "En Apple Watch no se escucha nada! Mal" (2022); AR: "sale como 500 % lo que cuesta Spotify o Tidal en Argentina" (2025).

**Qué podemos aprender.** El minimalismo oscuro vende como premium y la editorial de Apple premia a quien "explica un algoritmo"; pero la opacidad (adaptación no demostrada, gestos ocultos, paywalls intrusivos, texto) erosiona la confianza; y el audio generativo que "hace cosas" de noche puede despertar. No usar la palabra IA.

**Hueco para SleepNoise.** Bear + Endel sin sus pecados: hacer visible y honesta la adaptación (un panel "qué está pasando ahora" con hora/fase, nivel ambiente, respiración y su evidencia), controles grandes, cierre visible, cero recordatorios de compra, modulación nocturna lenta, previsible y desactivable, y "lo que cuesta un mes de Endel, para siempre".

Fuentes: https://endel.io/ · https://endel.io/technology · https://endel.io/science · https://en.wikipedia.org/wiki/Endel_(app) · https://www.apple.com/newsroom/2021/05/endel-app-creator-on-the-power-of-endless-ambient-music/ · https://apps.apple.com/us/app/endel-focus-sleep-sounds/id1346247457 · https://apps.apple.com/gb/app/endel-focus-sleep-relax/id1346247457 · https://uk.trustpilot.com/review/endel.io · https://justuseapp.com/en/app/1346247457/endel-focus-sleep-relax/reviews · https://ixd.prattsi.org/2026/02/design-critique-endel-ios-app/ · https://blog.readymag.com/tune-in-drop-out-how-endel-helps-get-into-the-flow-via-immersive-soundscapes-5ab08d932687/ · https://getlatka.com/companies/endel.io · feed RSS de reseñas ES/CO/AR (id 1346247457)

#### 20. Brain.fm

**Qué es.** Música compuesta por humanos a la que se añade "patented neural phase locking" (modulación de amplitud rítmica); categorías Focus, Relax, Sleep (Guided Sleep, Deep Sleep, Sleep And Wake, Wind Down, Power Nap) y Meditate; música de sueño con "3D spatialization"; modos "ADHD boost" y Pomodoro; descargas offline; 176,5 MB; 4,5 / 5,6K. La ficha afirma "Improve brain signatures of deep sleep" y "reduce tension/anxiety by 2x". Evidencia: Woods et al. 2024 (*Communications Biology*, con Northeastern, NSF STTR), cuatro experimentos sobre **atención**, 16 Hz ayudó más a quienes tenían más síntomas de TDAH (p=0,048), primer autor empleado de Brain.fm; reseñador independiente: beneficio "real but modest", "No large independent replication yet". Para sueño, su propio blog dice que la compañía **"has not published a sleep study"** y que la categoría Sleep "isn't backed by proven sleep results".

**Para quién.** Knowledge worker y TDAH orientado a productividad; el sueño es secundario.

**Precio exacto y modelo.** 14,99 $/mes o 99,99 $/año, sin lifetime (brain.fm/pricing, 16-11-2026); otras fuentes citan 9,99 $/mes o 69,99 $/año (ofertas o precios antiguos); trial 14 días.

**Diseño visual y tono.** Técnico-científico, con lenguaje de "brain state" y cifras de laboratorio.

**Lo que odian.** "I actually found it hard to sleep with the sleep track (the neural beats made me feel very uncomfortable and gave a sense of anxiety rather than relaxation)" (makeheadway.com).

**Qué podemos aprender.** El referente de "evidencia" de la categoría tiene un único programa de investigación propio sobre atención. Una app de sueño gana la conversación de credibilidad citando con precisión la literatura externa y no exagerando. La modulación de amplitud para sueño no tiene resultados publicados: no merece imitarse.

**Hueco para SleepNoise.** Una pantalla "Qué sabemos y qué no" con estudios, tamaños de muestra y financiadores: honestidad como rasgo de lujo.

Fuentes: https://www.brain.fm/science · https://www.brain.fm/pricing · https://www.brain.fm/blog/music-and-sleep-quality · https://apps.apple.com/app/id1110684238 · https://pmc.ncbi.nlm.nih.gov/articles/PMC11499863/ · https://theunhacked.com/brain-fm-review-what-the-science-actually-says-and-who-should-skip-it/ · https://makeheadway.com/blog/brain-fm-review/

#### 21. Pzizz

**Qué es.** El precedente directo de "audio que nunca se repite" como argumento de venta, con diez años de ventaja: "hybrid music system" de stems compuestos por humanos remezclados algorítmicamente ("Over 100 billion sequences to experience"; "Every time you listen to Pzizz it creates a unique session for you"), narración de voz con género, volumen y efecto 3D ajustables por separado, duración hasta 24 h, uso offline, historial de sueño en Apple Health, "Join over 1,000,000+ people" [P]. **34,1 MB**, la más ligera del grupo generativo. Prensa citada por la marca: Jenna Wortham (NYT) "I was out before 20 minutes had passed"; TechRadar: dreamscapes "astonishingly effective". 4,8 / 9,7K.

**Para quién.** Viajeros y tripulaciones ("Best sleep for International Flight Attendants… puts me to sleep in five minutes", 2024), insomnes episódicos que vuelven ("Recent events and illness have impacted my sleep, so I thought this would be a pleasant and nostalgic return", 2025).

**Precio exacto y modelo.** Gratis ("Classic Pzizz") + "Premium - Full" 9,99 $ pago único (gama clásica, residual) + Pro 7,99 $/mes o 49,99-69,99 $/año; la página de compra solo ofrece Pro (49,99 $/año "MOST POPULAR" y un "Subscribe for $99.99"); prueba 7 días; España Pro 55,99-69,99 €/año, Premium 10,99-24,99 €.

**Lo que aman.** "eventually I didn't need it anymore. Got out of the habit" (2025) y "it trained me to be able to sleep quickly and now all I have to do is put it on every once in a while" (2022): el patrón de "graduación". "Just saw they don't collect data. Perfect to support" (2021).

**Lo que odian.** No poder personalizar los sonidos (queja recurrente, Kimola); "I'm not paying $8 a month or $79 a year just for something I can get on YouTube"; **"Is there an option for lifetime purchase? I'd buy it"** (2023).

**Qué podemos aprender.** Convertir la no repetición en una cifra memorable; el peso ligero como argumento; el uso episódico es la norma de la categoría y no es un fracaso del producto.

**Hueco para SleepNoise.** Síntesis real (no remezcla de stems) con control total del usuario, pago único de verdad y una cifra verificable propia ("el generador no repite un segundo de audio en X años continuos").

Fuentes: https://pzizz.com/ · https://pzizz.com/buy/ · https://apps.apple.com/us/app/pzizz/id915664862 · https://www.techradar.com/reviews/pzizz · feed RSS de reseñas US (id 915664862)

#### 22. Loóna (y los modelos de contenido: Slumber app, Moshi)

**Qué es.** **Loóna**: "sleepscapes", escenas 3D que el usuario colorea tocando mientras una voz narra, más música, lluvia y un test de "Circadian Type"; onboarding de 18 pasos con quiz estético y pantalla "Personalizing your escapes"; paywall blando tras el quiz. Bustle (14-08-2025): 4,8★ y casi 30.000 valoraciones, "Free trial, then $9/week", veredicto 3,5/5 "slightly glitchy". Estimación de agregador: 5.000 instalaciones/mes y 65.000 $/mes. **Slumber** (historias y meditaciones): 4,7 / ~25,9K, 10-20 episodios gratis, compras 5,99-59,99 $, "new sleep audio content every week day"; reseña 2026: "Charging as much as Netflix for a monthly subscription is absurd. Cheaper to buy a box fan". **Moshi Kids**: afirma en la ficha que un estudio de NYU demostró que los niños "fall asleep 28 min earlier, stay asleep 22 min longer & experience 50% less night wakings"; el artículo revisado (Chung et al., IJERPH 2022) es un estudio de factibilidad pre-post con 25 díadas sin grupo control; subida de 59,99 a 79,99 $ un mes después de pagar (Trustpilot).

**Para quién.** Joven con ansiedad que quiere algo que hacer con las manos antes de dormir; padres (Moshi).

**Precio exacto y modelo.** Loóna 39,99 $/año o 9 $/semana; Trustpilot **2,5/5, 204 reseñas, 27 % de 1★**.

**Lo que aman.** "Loona is the one thing that has totally transformed my insomnia."

**Lo que odian.** "App has been left abandoned" (11-2024); "I've continued subscribing in hopes that new content would come" (03-2025); "They charge you during the free trial period, even if you cancel" (07-2026).

**Qué podemos aprender.** El modelo de episodios exige producción continua y muere cuando se para; un estudio de factibilidad convertido en "28 minutos antes" es el ejemplo de cómo no citar un estudio; 18 pasos de onboarding antes de oír nada ahuyentan.

**Hueco para SleepNoise.** El audio generado no envejece ni se "abandona"; onboarding de dos pantallas; cero promesas numéricas.

Fuentes: https://screensdesign.com/showcase/loona-sleep-reduce-anxiety · https://nl.trustpilot.com/review/loona.app · https://www.bustle.com/wellness/loona-sleep-app-ambient-noise-games-features-price · https://apps.apple.com/us/app/-/id1109543953 · https://apps.apple.com/gb/app/id1306719339 · https://ideas.repec.org/a/gam/jijerp/v19y2022i15p9416-d877506.html

### D. Trackers, alarmas inteligentes y la base gratuita de Apple

#### 23. Apple: Sonidos de fondo y Sueño/Sleep Score

**Qué es.** El competidor gratuito preinstalado y la base contra la que todo se compara. **Sonidos de fondo** (Ajustes › Accesibilidad › Audio y visual, desde iOS 15): en **iOS 26** pasa de 8 a 16 sonidos (Balanced/Bright/Dark Noise, Ocean, Rain, Stream, Night, Fire + Babble, Steam, Airplane, Boat, Bus, Train, Rain on Roof, Quiet Night), añade **Equalizer** (Balance izquierda/derecha y "Tone grid" con presets "Broad … richer sound" y "Focused … less audio distraction") y **"Stop Sounds with a Timer"** (hora fija o duración), baja su volumen cuando suena otro medio, para al bloquear, se activa desde Centro de control y desde Atajos al entrar en un Focus. Apple lo encuadra como accesibilidad ("might help a person relax and rest easier"). No mezcla capas, no tiene fundido, no guarda mezclas, no modula, no tiene respiración ni presentación visual. En español Apple lo llama *Ruido balanceado, Ruido intenso, Ruido oscuro, Océano, Lluvia*. **Sueño**: Sleep Score 0-100 (watchOS 26 / iOS 26, sept. 2025) = duración (50 puntos) + consistencia de hora de acostarse en 13 noches (30) + interrupciones (20); no usa frecuencia cardíaca ni fases; bandas endurecidas en 26.2 (Very Low 0-40 … Very High 96-100) porque "five or six hours of restless sleep can still earn a 'High' score"; funciona con datos de terceros escritos en Salud; **sin API** ("As of today, there is no API that allows the access to sleep scores", DTS sept. 2025). Avisos de apnea (Series 9+, FDA 510(k) 13-09-2024), Vitals. **AirPods Pro 2/3, AirPods 4/5, Max 2: "Pause Media When Falling Asleep"** (iOS 26), pausa el audio de todas las apps. HomePod: 7 sonidos ambientales por Siri. Watch Breathe: animación que crece y encoge, haptics None/Minimal/Prominent, 1-5 min, sin sonido.

**Para quién.** Todo usuario de iPhone/Watch; el usuario casual que quiere "lluvia" ya.

**Precio y modelo.** Gratis.

**Lo que aman y lo que odian.** Siete reseñas US envían al usuario a Ajustes: "almost $2 a month??? Settings -> Accessibility -> Audio -> Background Sounds. Just saying" (Dark Noise, 2024); "I'll use the free white noise built into my phone" (BetterSleep, 2026); Tide ES 2023: "la herramienta de sonido integrada en iOS es más sencilla". Infobae Tecno (09-11-2023) recomienda Sonidos de fondo porque "no requiere de una aplicación de streaming adicional". Sobre el Score: Macworld (29-10-2025): "Sleep Score is essentially just the same old Apple Watch sleep tracking with a new coat of paint"; 9to5mac (12-08-2026), comentario más votado: el tracking "increased their anxiety rather than helping"; el autor acabó desactivando las notificaciones.

**Qué podemos aprender.** La propuesta "ruido blanco + temporizador" está muerta como producto de pago; cualquier puntuación propia compite con una gratuita que ya genera ansiedad (ortosomnia, Baron et al. 2017); Apple no usa afirmaciones médicas. Riesgo a vigilar en cada WWDC: si Apple añade mezcla de capas o fundido, el foso se reduce a Marea, rituales y diseño.

**Hueco para SleepNoise.** Competir solo en lo que Apple no hace en un submenú de accesibilidad: seis capas, textura que no se repite, fundidos largos, Marea, mezclas guardadas, rutina y cierre inteligente (reaccionar bien a la pausa de AirPods, guiar la automatización del Focus de Sueño), diseño; y leer HealthKit solo para adaptar, no para repetir el número de Apple.

Fuentes: https://support.apple.com/HT212775 · https://www.macrumors.com/2025/06/09/ios-26-background-sounds/ · https://support.apple.com/guide/watch/apded441a669/watchos · https://www.macrumors.com/2025/11/04/watchos-26-2-updates-sleep-score-ranges/ · https://www.macworld.com/article/2947066/i-dont-trust-my-apple-watchs-sleep-score-and-neither-should-you.html · https://9to5mac.com/2026/08/12/apple-watch-sleep-score-became-more-useful-for-me-with-these-settings/ · https://developer.apple.com/forums/thread/800403 · https://support.apple.com/en-us/120031 · https://9to5mac.com/2025/10/23/ios-26-gave-airpods-pro-a-new-setting-you-might-want-to-turn-on · https://support.apple.com/guide/watch/mindfulness-apd371dfe3d7/watchos · https://www.infobae.com/tecno/2023/11/09/como-reproducir-sonidos-de-lluvia-en-iphone-para-dormir-mejor/

#### 24. Sleep Cycle

**Qué es.** El tracker histórico y la única empresa cotizada del sector (Nasdaq Estocolmo): fases por micrófono/acelerómetro, ronquidos, tos, habla, alarma inteligente con ventana de 30 min, biblioteca de "sleep aids" (historias, meditaciones, lluvia, océano), "patented sound technology". Datos auditados: 2024 ventas 261,5 M SEK (+10,7 %), **918K suscriptores**, ARPU 278 SEK (~25 €/año), margen operativo 29,4 %; T3-2025 832K suscriptores (−9 %) y el CEO habla de "a continued slowdown in the market for consumer-facing sleep apps"; **T3-2026 ventas −17,3 %, 631K suscriptores (−24 % en un año)**, EBITDA 5,2 %, "new sales in the App Store remain challenging", B2B 19,7 % de ventas, opada (Snark BidCo) y propuesta de fusión con Audiowell (catálogo musical). **#3 en apps gratis H&F de España** el 16-11-2026. 4,7 / 32K, Editors' Choice.

**Para quién.** Usuario sin wearable que quiere despertar mejor; 200K descargas y ~900K $/mes en iOS EE. UU. según Sensor Tower (snapshot).

**Precio exacto y modelo.** Gratis + Premium: IAP de 2,99 a 57,99 $ (prensa ~39,99 $/año y 9,99 $/mes; "Premium: Unlock all features 39,99 $" probable desbloqueo heredado); subida de precio ~10 % en EE. UU. en 2025 para priorizar ARPU.

**Lo que aman.** "The smart alarm is the main strength... Otherwise the free version covers most needs" (liveworksleep, 2026); "This alarm is gradual and soft".

**Lo que odian.** Usuario de más de cinco años: **"I'll go back to the Apple alarm, which is just as effective as this"** (04-2026); la 6.25.9 "substantially overprocesses the sleep graph"; "The alarm goes off at the earliest possible time, even when by its own metrics I am in deep sleep."; "Add more content to premium or lower the price" (justuseapp).

**Qué podemos aprender.** El modelo "suscripción anual a una app de sueño" está saturado y el líder huye a B2B, apnea médica y música; la alarma "inteligente" funciona sobre todo por suavidad, no por fase (precisión de actigrafía 66-77 %).

**Hueco para SleepNoise.** Despertar progresivo acústico de 15-30 min sin prometer fases, y un producto que no mide: "la app de sueño que no te puntúa".

Fuentes: https://apps.apple.com/us/app/sleep-cycle-tracker-sounds/id320606217 · https://justuseapp.com/en/app/320606217/sleep-cycle-tracker-sounds/reviews · https://liveworksleep.com/sleep-cycle-app-review/ · https://sleepcycle.com/newsroom/press-release/sleep-cycle-year-end-report-2024-a-strong-year-marked-by-continuous-growth · https://storage.mfn.se/b9ebb334-a819-48ed-8e3e-6b84b93a62f3/sleep-cycle-interim-report-jul-sep-2025.pdf · https://attachment.news.eu.nasdaq.com/a261b009a50cb200a277195c4b9cc1f7f · https://itunes.apple.com/es/rss/topfreeapplications/limit=50/genre=6013/json

#### 25. Pillow

**Qué es.** El "Apple Watch plus" (Neybox, Grecia): fases con Watch, frecuencia cardíaca, audio en el dispositivo de ronquidos/apnea/habla ("All processing is done using on-device intelligence to ensure privacy"), puntuación, tendencias, Siri Wind Down, exportación CSV, biblioteca de sonidos; Live Activity en Dynamic Island con la advertencia de que "Live Activity sessions longer than 8 hours may not update as expected". 4,4 / 96K.

**Para quién.** Dueño de Apple Watch que quiere más detalle que Apple; gancho emocional matinal: "It is one of the first things I look at EVERY morning!".

**Precio exacto y modelo.** Gratis + Premium 39,99 $/año, 19,99 $/mes, 59,99 $/trimestre; "Premium Sleep Tracking" 39,99 $.

**Lo que odian.** Fricción: "not being able to just start the alarm on my watch without also needing the phone app open".

**Qué podemos aprender.** El límite de 8 h de las Live Activities obliga a representar "la sesión hasta el temporizador", no la noche entera; la fricción Watch/iPhone se castiga.

**Hueco para SleepNoise.** Watch mínimo con play/pausa, +15 min y haptics de Marea, sin seguimiento propio.

Fuentes: https://apps.apple.com/us/app/pillow-sleep-tracker/id878691772 · https://pillow.app/news/page/3

#### 26. AutoSleep

**Qué es.** El caso de estudio del pago único en la categoría (Tantsissa, Australia): sueño automático con Watch, Sleep Bank (deuda/crédito), Readiness por HRV y pulso al despertar, anillos, alarma háptica con ventana, "Lights Off" con HomeKit. Posicionamiento literal: **"Pay once. No subscription.", "Private by design.", "No data upload, no analytics, no third-party code.", "Your data stays in Apple Health on your devices."** Disclaimer modelo: "No watch or app measures sleep stages as precisely as a sleep lab", "built for spotting your patterns and trends over time, not for diagnosis", "If you're worried about your sleep, talk to your doctor." Web: "Millions of users worldwide", "225,000+ reviews", "Ranked #1 Health & Fitness App for Many Years in 100+ Countries" [P].

**Para quién.** Usuario técnico que odia las suscripciones y valora la privacidad.

**Precio exacto y modelo.** **9,99 $ pago único** (9,99 € en España), sin cuenta, sin IAP, sin prueba. 4,7 / 62K (ES 4,6 / 6,7K).

**Diseño visual y tono.** Onboarding "Start with three things", semáforo de colores; denso en datos pero honesto.

**Qué podemos aprender.** El modelo de SleepNoise (pago único, offline, sin cuentas) tiene demanda masiva y se defiende como señal de calidad; la estructura de su disclaimer es reutilizable palabra por palabra. Pero 9,99 $ es un juego de volumen apoyado en el Watch: a ese precio el usuario clasifica la app como "utilidad tipo AutoSleep", no como producto de diseño.

**Hueco para SleepNoise.** Ser el AutoSleep del sonido y el hábito, con un precio que lea como objeto de diseño (29,99 $) y no como utilidad.

Fuentes: https://autosleepapp.tantsissa.com/home/overview · https://autosleepapp.tantsissa.com/ · https://apps.apple.com/us/app/autosleep-track-sleep-on-watch/id1164801111 · https://apps.apple.com/es/app/autosleep-track-sleep-on-watch/id1164801111

#### 27. Rise

**Qué es.** Sueño sin hipnograma (Rise Science): deuda de sueño a 14 noches, necesidad de sueño individual, "Melatonin Window", picos y valles de energía, 20+ recordatorios de higiene cronometrados al reloj circadiano, alarma que avisa de cuánta deuda añade cada hora. Datos propios: 1,95 M usuarios, necesidad mediana de 8 h, "Eighty percent of RISE users say they get better sleep within five days" [P]. 4,7 / 74K, Editors' Choice, #4 H&F. No aparece en ningún listado de Apple Design Awards 2024-2026 (afirmación de la primera ronda no verificada).

**Para quién.** Profesional orientado a rendimiento y energía diurna, no al dormitorio.

**Precio exacto y modelo.** 69,99 $/año (5,83 $/mes), prueba 7 días; IAP "AI Expert Access" 29,99 $.

**Lo que odian.** Mattress Clarity (11-11-2026), 3,4/5: "RISE isn't a great fit for people who want detailed information about their overall sleep quality" y carece de **"sleep stories, white noise, or extensive soothing sounds"**.

**Qué podemos aprender.** Se puede vender sueño con una métrica simple y una ventana de hora de dormir; la higiene del sueño como 20 recordatorios genera presión (la AASM recomienda en contra de la higiene como tratamiento aislado).

**Hueco para SleepNoise.** El sonido de calidad que a Rise le falta, y una "ventana de sueño" con tres recordatorios máximos elegidos por el usuario, sin puntuación ni culpa.

Fuentes: https://apps.apple.com/us/app/rise-sleep-tracker/id1453884781 · https://www.risescience.com/blog/rise-app-review · https://www.mattressclarity.com/accessories/rise-app-review/ · https://developer.apple.com/design/awards/

#### 28. SleepScore, Sleep++ y SleepWatch

**Qué es.** **SleepScore** (ResMed): sónar desde la mesilla (respiración y movimiento), fases, puntuación, "sleep guide", "patented, non-contact, sonar sleep tracker technology"; la validación se limita a una lista corta de teléfonos antiguos; el soporte afirma que dos personas en la cama no afectan la precisión mientras una reseña independiente dice lo contrario. **Sleep++** (Cross Forward): duración y "restfulness" con Watch, Readiness Score, minimalista; ~4,1 / ~5.600. **SleepWatch** (Bodymatter): sueño automático con Watch/iPhone, sugerencias de hábitos; 60K descargas y ~400K $/mes iOS US (Sensor Tower, snapshot).

**Precio exacto y modelo.** SleepScore 9,99 $/mes o 59,99 $/año con "7-day Trial"; Sleep++ gratis + IAP para quitar anuncios; SleepWatch 4,99 $/mes o 39,99 $/año. SleepScore 4,3-4,4 (600-7.100 valoraciones según storefront).

**Lo que odian.** Un usuario de SleepScore: el sónar era audible "to them and their pets"; trackers en general: "I think it is priced too high annually for what you get".

**Qué podemos aprender.** El apellido médico (ResMed) no compensa un dato en disputa; medir con sónar es territorio 1.4.1 ("if the level of accuracy or methodology cannot be validated, we will reject your app").

**Hueco para SleepNoise.** No medir. Si se usa el micrófono, que sea para el nivel de ruido ambiente (sin grabar), nunca para detectar fases, ronquidos o apnea.

Fuentes: https://apps.apple.com/us/app/sleepscore/id1364781299 · https://support.sleepscore.com/hc/en-us/articles/7715071513236-How-does-it-compare-to-other-sleep-tracking-apps · https://apps.apple.com/in/app/sleep/id1038440371 · https://apps.apple.com/app/id1138066420 · https://app.sensortower.com/overview/1138066420?country=US

#### 29. ShutEye

**Qué es.** El gigante que vende "ruido blanco gratis" dentro de un tracker: *ShutEye®: Sleep Tracker, Sound* (ENERJOY PTE. LTD., Singapur; mismo grupo que JustFit, Me+ y Eato, "80M+ downloads" en las cuatro apps [P]), lanzada 09-12-2019, v3.6.0 del 06-11-2026, **724,7 MB**, **4,8 / 350.472** en EE. UU. (#144 en H&F), ES 4,69 / 8.248, MX 4,81 / 11.952, AR #31 en ingresos H&F. "Extensive library of sleep sounds and ambient noise", "Customizable sound mixes, including white noise app free" (sic); grabaciones. Privacidad: identificadores usados para rastrear, audio del usuario (ronquidos) para analítica. Afirma "92% of users saw noticeable sleep improvements within 3 weeks" sin metodología [P]. Appfigures estimó 17 M$ en 2023 (más que BetterSleep), cifra de segunda mano no verificada.

**Para quién.** Público masivo captado por ASO y por el tracker gratuito como anzuelo.

**Precio exacto y modelo.** 9,99 $/mes, **59,99 $/año**, Family Plan 59,99 $, y una cascada de ofertas en la propia ficha (29,99 $ "Limited Time Offer", 19,99 $ 6 meses, "ShutEye Gold Special Offer" 29,99 $). Las fichas ES y MX repiten literalmente "59,99 $/año" en dólares, sin localizar.

**Lo que odian.** "stops recording me, stops giving me any valuable data", **"I am seriously disgusted with this application"** (Lilibelle19, tras una actualización); "kept making you buy the subscription" para ver las grabaciones nocturnas (22-12-2023).

**Qué podemos aprender.** Descuentos en cascada son señal de conversión forzada; el paywall sobre los datos ya grabados del usuario es la forma más rápida de generar asco; su ventaja no es el sonido, es una máquina de valoraciones. Sensor Tower muestra su caída: 377K $ → 186K $ semanales en EE. UU. entre T1 y T2 de 2024.

**Hueco para SleepNoise.** El segmento que ShutEye expulsa: el que quiere "sonido y nada más", sin micrófono que grabe, sin rastreo, con precio localizado en euros y pesos.

Fuentes: https://apps.apple.com/us/app/shuteye-sleep-tracker-sound/id1490078804 · https://itunes.apple.com/lookup?id=6760920621,1490078804,6739538343&country=es · https://www.shuteye.ai · https://enerjoy.life · https://sensortower.com/blog/2024-q2-unified-top-5-wellness%20apps-revenue-us-63e274e1e1714cfff10eaa2f

### E. CBT-I digital

#### 30. Stellar Sleep

**Qué es.** CBT-I de consumo sin regulación (Y Combinator, 6 M$ seed 2024): control de estímulos, reestructuración cognitiva, "sleep restriction therapy", hábitos, relajación, diario sincronizado con Health, journaling, reto de 30 noches; 5-10 min/día durante varias semanas. 4,7 / 2.800.

**Para quién.** Insomne crónico con capacidad de pago; "this seems to focus on those who have trouble falling asleep".

**Precio exacto y modelo.** TechCrunch (02-2024): 60 $/mes; guías 2026: **~188 $/mes facturado trimestralmente**, elegible HSA/FSA.

**Lo que aman.** "It basically slowly taught me how to identify what exactly was going on in my life that was destroying my sleep"; "This really, actually works."

**Lo que odian.** **"It would have been nice to know just how difficult this was before I paid for the subscription."**; un agregador contó 155 reseñas US con ~52 % positivas y ~42 % negativas, con quejas repetidas de "subscription unreasonable" y problemas para cancelar.

**Qué podemos aprender.** El contenido de CBT-I funciona cuando funciona (metaanálisis de 33 ECA: ISI −5,00 al terminar), pero la ejecución es abusiva en precio y nadie en el segmento tiene una UI tipo Bear. La restricción de sueño es "brutal" y tiene contraindicaciones (epilepsia no controlada, bipolaridad, apnea sin tratar, conductores).

**Hueco para SleepNoise.** Las piezas no clínicas de la CBT-I como "rituales" dentro de la UI minimalista (Descenso de 30-45 min con cambio de textura + Marea, Pausa de 20 minutos, Ancla de despertar, Notas de noche de tres toques, Cuaderno de preocupaciones), sin módulos, cursos ni semanas numeradas, y sin automatizar nunca la restricción de sueño.

Fuentes: https://techcrunch.com/2024/02/06/stellar-sleep-app-chronic-insomnia · https://apps.apple.com/us/app/stellar-sleep-insomnia-cbt/id1602312365 · https://appshunter.io/ios/app/stellar-sleep-insomnia-cbt/id1602312365/reviews · https://getrest.app/blog/the-best-cbt-i-apps · https://a-better-life.net/en/blog/cbti-app-cost/

#### 31. Sleep Reset y Dawn Health

**Qué es.** El extremo alto del mercado de consumo: acompañamiento humano. **Sleep Reset**: programa CBT-I con coach por mensajería, encuesta inicial y varios días de diario, método de compresión del sueño (1:00-7:00), "encourages relying on your own perceptions over fitness trackers"; afirma "53% faster to fall asleep" y "Over 90% of members find the program effective" basándose en abstracts propios. Sleepopolis (06-2023): app "sleek and easy to use". **Dawn Health**: sesiones semanales 1-1 por vídeo, chat con terapeuta, lecciones diarias de 5-7 min, informes semanales, "Covered by most major insurances" (Aetna, Cigna, UHC, BCBS).

**Precio exacto y modelo.** Sleep Reset: trial 19 $/semana y después **"$297 / 28 days"** (App Store muestra compras de 229,99 y 299,99 $). Dawn: 0-75 $/mes según seguro (fuente secundaria); la web no muestra precio.

**Qué podemos aprender.** El extremo alto paga 300 $/mes por estructura y acompañamiento, no por sonido; cualquier cifra tipo "53 % faster" es exactamente lo que App Review 1.4.1 y la guía de bienestar de la FDA (06-01-2026) sitúan fuera del bienestar ("claims of clinical equivalence", "treatment guidance").

**Hueco para SleepNoise.** Ofrecer la parte conductual inofensiva (diario mínimo local, ventana de sueño orientativa, rutina de desconexión) con lenguaje de "hábitos" y "noches más tranquilas", nunca "tratar el insomnio".

Fuentes: https://www.thesleepreset.com/pricing · https://sleepopolis.com/news/sleep-reset-app/ · https://www.dawn.health/ · https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices

#### 32. Terapias digitales con receta: Somryst, SleepioRx y somnio

**Qué es.** La CBT-I regulada. **Somryst** (Nox Health, antes Pear): FDA 510(k) clase II 2020, único PDT de insomnio crónico con receta en EE. UU.; diario, restricción, control de estímulos, higiene, reestructuración, prevención de recaídas; 9 semanas; Pear quebró en 2023 y Nox compró Somryst por 3,9 M$. **SleepioRx** (Big Health): FDA 510(k) 08-08-2024 como "adjunct to usual care for chronic insomnia" 90 días; Sleepio (bienestar) con NICE MTG70 (05-2022); seis sesiones semanales, test de sueño, diario, comunidad, relajación muscular; "76% of patients achieve clinical improvement" [P]. **somnio** (mementor, Alemania): DiGA permanente (BfArM) 2022, 6 semanas. La AASM (2021, 2026) hace una única recomendación "fuerte": CBT-I multicomponente, "the most efficacious first-line treatment for insomnia", y recomienda en contra de la higiene del sueño como tratamiento aislado.

**Para quién.** Paciente diagnosticado, vía empleador, aseguradora o receta.

**Precio exacto y modelo.** Somryst: lista 899 $, copago 100-899 $. Sleepio: Reino Unido 45 £ sin IVA (NHS gratis en zonas), EE. UU. ~100-450 $ vía empleador, ~400 $ cash-pay. somnio: 224,99 €, gratis para el paciente (seguro alemán).

**Diseño visual y tono.** Formularios clínicos y embudos; ninguna tiene una UI que un consumidor describiría como bella.

**Qué podemos aprender.** Es la frontera regulatoria. La FDA (guía del 06-01-2026) autoriza expresamente "Claims to promote sleep management, such as to track sleep trends" y "Claims to promote relaxation or manage stress", y su ejemplo 1 es "A software function plays music to 'soothe and relax' an individual and to 'manage stress.' Such a software function is not a device function": palabra por palabra SleepNoise. Lo que saca del bienestar: "references to specific diseases, clinical conditions, or diagnostic thresholds", "treatment guidance", "clinical grade". WHOOP recibió una Warning Letter en 2025 por "medical-grade". En App Store, un desarrollador cuya app "assesses insomnia and anxiety from questionnaire answers" acumuló rechazos 1.4.1 repetidos.

**Hueco para SleepNoise.** Glosario cerrado: permitido "relajación", "manejo del estrés", "rutina", "hábitos", "tendencias", "noches más tranquilas"; prohibido "insomnio", "apnea", "tratar", "terapia", "clínico", "grado médico", "diagnóstico", porcentajes de eficacia, umbrales. Una única notificación permitida: "si tu sueño te preocupa, hablar con un profesional puede ayudar".

Fuentes: https://pmc.ncbi.nlm.nih.gov/articles/PMC11530488/ · https://www.statnews.com/2024/08/08/big-health-sleepio-insomnia-fda-clearance/ · https://www.nice.org.uk/guidance/mtg70 · https://sleepreviewmag.com/sleep-disorders/insomnia/nox-health-closes-acquisition-somryst/ · https://aasm.org/combination-treatment-chronic-insomnia-guideline/ · https://www.fda.gov/media/90652/download · https://www.dlapiper.com/en-us/insights/publications/2026/01/fda-updates-its-clinical-decision-support-and-general-wellness-guidances-key-points · https://developer.apple.com/forums/thread/772732

#### 33. CBT-i Coach e Insomnia Coach (VA, EE. UU.)

**Qué es.** Las dos apps gubernamentales gratuitas. **CBT-i Coach**: "built to supplement clinician-delivered CBT-I"; diario, herramientas, educación, cuestionarios; ajusta la ventana de sueño por algoritmo; aviso si TST < 5 h. 4,6 / 13K. **Insomnia Coach**: autoguiado, plan semanal de 5 semanas, "sleep coach" con feedback, diario, 17 herramientas; "less useful for individuals who are shift workers" (healthify.nz, 2021). 3,7 / 89.

**Precio y modelo.** Gratis, sin anuncios.

**Lo que aman.** "A free application with no ads! Yay for that!" (2021); "Easy to use and helped me discover and understand my sleep patterns" (2023); "I truly feel like it saved my life." (2022).

**Lo que odian.** "The new one is awful and full of bugs" (2023); **"it's created more anxiety than relief"** (11-10-2025); la restricción de sueño descrita como "brutal"; "I didn't find the app user-friendly" (2022); el diario "assumes they were in bed that whole time".

**Qué podemos aprender.** Lo gratuito es tosco; el diario con fricción de entrada es la queja universal de los DTx; el algoritmo de restricción genera ansiedad.

**Hueco para SleepNoise.** Diario de tres toques al despertar (cómo dormí 1-5, cuántas veces me desperté, nota opcional), todo local, sin "síntomas" y sin algoritmo que recorte horas.

Fuentes: https://apps.apple.com/us/app/cbt-i-coach/id655918660?see-all=reviews · https://www.gale.care/health/cbt-i-coach-free-va-app · https://apps.apple.com/us/app/insomnia-coach/id1341944736 · https://healthify.nz/apps/i/insomnia-coach

### F. Hardware de sueño

#### 34. Hatch Restore 3

**Qué es.** La mesilla de noche premium: luz de amanecer, sonidos de sueño en bucle (~40 libres, 60-80 de pago según fuente), "unwind" (meditaciones, historias), alarma, rutinas programadas, botones físicos y rueda de luz; sin mezclador real ni detección de sueño. Hatch Sleep fue la única app de wellness cuyos ingresos crecían en EE. UU. en T2-2024 (239K → 258K $ semanales, Sensor Tower). La web muestra 3.932 reseñas.

**Para quién.** Familias y consumidor premium que quiere rutina noche-mañana sin pantalla.

**Precio exacto y modelo.** **169,99 $** con 30 días de Hatch+ incluidos; Hatch+ **4,99 $/mes o 49,99 $/año**.

**Lo que odian.** Trustpilot 2,0/5 (11 reseñas, muestra pequeña): "App frozen and can't even set up after many tries"; "The stupid device disconnects from the app anytime you unplug it"; "You cannot play any sleep sounds at all."; **"My alarm won't work unless I pay $50 usd a year."**; en Best Buy varios compradores reportan que necesita Wi-Fi incluso para la alarma y Hatch lo confirma; Reddit resumido como "mixto, tirando a negativo": app lenta, contenido tras muro de pago.

**Qué podemos aprender.** La propuesta "rutina de noche y mañana, luz + sonido" es la que más se parece a un producto de gestión del sueño para consumidor premium, y su talón de Aquiles es la nube.

**Hueco para SleepNoise.** "Sin cuenta, sin Wi-Fi, sin suscripción, funciona en modo avión": cada frase responde a una queja literal de hardware de 170 $; un "modo mesilla" en StandBy con amanecer sonoro.

Fuentes: https://www.hatch.co/restore · https://www.trustpilot.com/review/hatch.co · https://www.bestbuy.com/site/reviews/hatch-restore-3-sunrise-alarm-clock-sound-machine-and-smart-light-putty/6615166 · https://www.wareable.com/health-tech/hatch-restore-3-review · https://sensortower.com/blog/2024-q2-unified-top-5-wellness%20apps-revenue-us-63e274e1e1714cfff10eaa2f

#### 35. Ozlo Sleepbuds

**Qué es.** Los herederos de los Bose Sleepbuds (Bose: campaña 2017, lanzamiento 2018, defecto de batería y retirada 2019, Sleepbuds II 2020, discontinuación 2023 "citing low demand and shifting business priorities"; "didn't allow music playback", solo biblioteca precargada). Tres ex-ingenieros de Bose fundaron Ozlo, adquirieron la marca y licenciaron tecnología. Funciones: biblioteca de enmascarado propia, **streaming de cualquier audio** del teléfono vía estuche, alarma personal en el oído, "Autoplay" que sustituye el streaming por enmascarado al detectar sueño, "Sleep Patterns" añadido después; aislamiento pasivo, sin ANC; batería 10 h declaradas, 8-8,5 h medidas (GearJunkie). Según su dirección: **">50 M$ acumulados y >180.000 unidades en menos de 18 meses"**, ~100 % de crecimiento interanual, >65 % de usuarios activos semanales [P, Ami Capital 07-2026]; prepara capa de suscripción y test de tinnitus. Calm vende auriculares Calm x Ozlo.

**Para quién.** Light sleeper que ya gasta 300 $ en hardware; parejas que roncan; viajeros.

**Precio exacto y modelo.** 299-349 $ según fecha/mercado, sin suscripción obligatoria, HSA/FSA.

**Lo que aman.** "They have become a reliable way for me to get sleep, even in the noisiest situations."; "Ozlo Sleepbuds feel better than anything else I've tried." (GearJunkie).

**Lo que odian.** **"The sound library could be larger. This is a common criticism, and it's fair."** (LiveWorkSleep); "Side sleeper comfort is genuinely compromised beyond four to five hours of continuous pressure."; "The buds only work within a close distance of both the charging case and your smartphone."; sobre Bose: "wish we were able to use other sleep apps".

**Qué podemos aprender.** Hay demanda probada de gastar 100-300 $ en enmascarar ruido mientras se duerme; la biblioteca pequeña y repetitiva es la crítica recurrente a 300 $; el "sonido enlatado" sin flexibilidad se percibe como jaula.

**Hueco para SleepNoise.** Audio procedural infinito enviado por Bluetooth a cualquier auricular, incluidos Ozlo; precio percibido como "la parte software de un sistema de sueño premium", no como app de 0,99 $.

Fuentes: https://ozlosleep.com/blogs/news/why-were-bose-sleepbuds-discontinued · https://gearjunkie.com/technology/ozlo-sleepbuds-review · https://liveworksleep.com/ozlo-sleepbuds-review/ · https://amicapital.substack.com/p/ozlo-designed-to-improve-sleep-not · https://www.adorama.com/boslpbdii.html

#### 36. Anker Soundcore Sleep A20 / A30

**Qué es.** Auriculares de sueño con la app gratuita más ambiciosa del hardware: A30 con ANC (primera vez en auriculares de sueño, mayor efecto en 20-200 Hz), **enmascarado adaptativo de ronquidos** (el estuche en la mesilla escucha el ronquido en tiempo real y ajusta el audio), tres paisajes "brainwave" binaurales (Starry Sky, Ocean, Forest) con ajustes de **densidad, espacio y brillo**, biblioteca de ruido blanco con **mezcla de hasta tres capas**, modo Bluetooth (música) vs Local (biblioteca interna), seguimiento de sueño prometido con una semana de datos locales. Batería 9 h declaradas, 7 h 33 min medidas. SoundGuys 7,4/10.

**Para quién.** Pareja que ronca, viajero; usuarios del A20 divididos entre "work great" y "make my ears feel extremely sore and painful".

**Precio exacto y modelo.** A20 149,99 $ de lanzamiento (visto a 108-180 $); A30 **229,99 $** MSRP (Kickstarter 139 $, Amazon 199,99 $); SoundGuys: "an ideal price point would have been around $199".

**Lo que odian.** Controles táctiles que funcionaban "on the third or fourth try"; sonidos que "just sound kind of flat".

**Qué podemos aprender.** Anker ha puesto en una app gratuita el patrón de "paisaje modulable" (densidad/espacio/brillo) que SleepNoise ya hace mejor por DSP; el "ronquido adaptativo" vía micrófono es la función de hardware más copiable: iPhone también tiene micrófono. Los controles a oscuras y medio dormido deben ser grandes.

**Hueco para SleepNoise.** Enmascarado adaptativo con el micrófono del iPhone (medir nivel, no grabar; verificado como REAL con auriculares vía A2DP + mic del iPhone, y solo iPhone 16+ con iOS 18.2 para altavoz propio con cancelación de eco), perfil "pareja que ronca" con energía en graves-medios, controles de 44 pt operables sin mirar.

Fuentes: https://www.soundguys.com/anker-soundcore-sleep-a30-review-140300/ · https://tech.yahoo.com/audio/review/soundcore-sleep-a30-earbuds-review-154052445.html · https://forums.tomsguide.com/threads/soundcore-sleep-a20-earbuds.533123/post-2050801 · https://www.techbuzz.ai/articles/anker-sleep-a20-earbuds-hit-108-best-price-since-launch · https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions-swift.struct/allowbluetootha2dp

#### 37. Eight Sleep, Oura, Kokoon y Withings (el high-end con suscripción sobre hardware)

**Qué es.** **Eight Sleep Pod 5**: desde 2.799 $ (Full) hasta ~6.197 $; Autopilot **199-399 $/año obligatorio el primer año**; altavoz en la Base bajo el colchón que reproduce solo contenido de la app: paisajes, NSDR de Andrew Huberman (solo miembros), alarmas con vibración y temperatura; "No Bluetooth. No pairing."; el audio puede "fade out after sleep onset" o sonar toda la noche. **Oura Ring 4**: 349 $ + membresía 5,99 $/mes o 69,99 $/año; "Sleep Sounds" (2021) con historias y soundscapes que se apagan al acabar la pista; invitación contextual en la home antes de la hora de dormir; "Relax Mode" con cinco sonidos (2025). **Philips Sleep Headphones with Kokoon**: £249 con 12 meses de Premium incluidos; sensores ópticos de FC + acelerómetro; el audio **se desvanece al detectar sueño**; streaming de Audible/Spotify/Headspace; ~11 h de batería; botones "fiddly", "fairly expensive". **Withings Sleep Analyzer**: 149,95 € (199,95 $ en EE. UU.), alfombrilla bajo el colchón: ciclos, FC, duración de ronquidos y, en la UE, apnea (dispositivo médico); senses.se la considera "unreliable" para apnea; sin audio.

**Para quién.** High-end absoluto; quien ya ha comprado el hardware y acepta la cuota.

**Qué podemos aprender.** La marca más cara del sector valida tres patrones: audio + cierre por detección de sueño, contenido de "descanso profundo sin dormir" (NSDR) y alarma multisensorial. Oura usa el momento contextual (invitar a la rutina al acercarse la hora de dormir) con poca inversión en audio. Kokoon vendió como diferencial lo que Apple regala en iOS 26 con AirPods. El dato "ronquido" ya vive en el ecosistema del usuario (Withings, Apple "Breathing Disturbances"). Patrón a estudiar: hardware + 12 meses incluidos.

**Hueco para SleepNoise.** Sesiones "descanso sin dormir" de 10/20 min con Marea más rápida y salida suave; cierre inteligente apoyado en los sensores que el usuario ya tiene (pausa de AirPods, quietud del iPhone por acelerómetro); invitación contextual a la rutina leída de la hora de dormir elegida; sin suscripción obligatoria ni "AirPods pausan" no manejado.

Fuentes: https://www.eightsleep.com/blog/pod-5-spotlight-unlocking-surround-sound-with-the-new-base/ · https://www.sleepfoundation.org/mattress-reviews/eight-sleep-pod-mattress-review · https://the5krunner.com/2025/05/14/eight-sleep-pod-5-everything-you-need-to-know/ · https://ouraring.com/blog/sleep-sounds/ · https://www.techradar.com/health-fitness/oura-ring-4-review · https://www.expertreviews.co.uk/technology/headphones-audio/philips-sleep-headphones-with-kokoon-review · https://www.withings.com/en-eu/products/sleep · https://en.senses.se/?p=534

### G. Adyacentes: respiración, tinnitus y bebés

#### 38. Breathwrk y Othership (y Apple Breathe como referencia de UI)

**Qué es.** Comprobación de si alguien acopla un paisaje sonoro a la respiración. **Breathwrk** (Peloton Interactive, 4,8 / 18.037, 623 MB, iOS 26+): "customizable sounds, visuals, haptic vibrations, and breath coaches"; visuales por hora del día ("Bright visuals match your active and focused day, whilst muted colors prepare you for a restful night"); 4-7-8 para dormir; "fall asleep quickly", "helps manage stress and anxiety" en la ficha desde 2019. **Othership** (Breathwork Plus, 4,9 / 2.274, 140 MB): 114 sesiones "down" (incluidas "Sleep routines"), "music-driven", facilitadores (psicoterapeutas, DJs), "wind down for a deep sleep", "Soothe anxiety and find centre". Otras revisadas: Breathe+ (sin sonido), BreathWise ("per-phase background sounds and metronome cues"), prāṇa (HRV en vivo en Watch), Pranayama ("haptic and audio sync"). **Apple Breathe** (Watch): animación que crece y encoge, haptics None/Minimal/Prominent, 1-5 min, Breath Rate configurable, guarda FC en Salud, sin sonido.

**Para quién.** Ansiedad, biohackers, miembros Peloton (gratis para ellos).

**Precio exacto y modelo.** Breathwrk Pro 9 $/mes o 4,08 $/mes anual (≈49 $/año), prueba 7 días, sin lifetime, 10 SKU de 1,99 a 69,99 $. Othership 17,99 $/mes o 10,83 $/mes anual (≈130 $/año), oferta "2 weeks for $99".

**Lo que aman.** "The music that plays while you inhale and exhale also is a good touch" (Breathwrk, 03-04-2024); "I can sleep again and rarely take my anxiety meds" (02-11-2021); "The app is beautifully designed." (Othership).

**Lo que odian.** **"with so many timers locked behind a paywall, I find it difficult to justify paying such a high price"** (Breathwrk).

**Qué podemos aprender.** Ninguna app revisada acopla un paisaje sonoro continuo (oleaje, lluvia, viento) a una respiración lenta que luego se disuelve: lo más cercano son cues por fase o música con voz. El lenguaje "fall asleep quickly", "soothe anxiety", "manage stress and anxiety" ha pasado App Review de forma sostenida (versiones aprobadas en oct.-nov. 2026) sin decir "tratar" ni "insomnio". El 4-7-8 es la lingua franca del "modo dormir". Apple Breathe es la referencia de UI minimalista: una forma, tres niveles de haptics, sin sonido. En 2.351 reseñas no hay ninguna petición de "respiración guiada por sonido": es una propuesta de valor que hay que enseñar, no una demanda latente.

**Hueco para SleepNoise.** La Marea respiratoria como mecánica inédita: por defecto 6/min con exhalación larga (ratio ~4:6), arranque desde la frecuencia nocturna medida por HealthKit (o 12/min) y descenso a 6/min en 4-5 min, 15-20 min, variante 4-7-8 opcional etiquetada como popular, haptics "Minimal" al inicio de cada ola que se retiran, extensible a lluvia (densidad) y ventilador (oscilación). Presentarla como "el mar que respira contigo" y "ayuda que se retira", nunca como técnica clínica; grabar la descripción en vídeo y capturas antes de que un indie la copie.

Fuentes: https://apps.apple.com/us/app/breathwrk-breathing-exercises/id1481804500 · https://www.breathwrk.com · https://www.othership.us/app · https://itunes.apple.com/search?term=breathe%2B%20simple%20breath%20trainer&country=us&entity=software · https://itunes.apple.com/search?term=prana%20breath&country=us&entity=software · https://support.apple.com/guide/watch/mindfulness-apd371dfe3d7/watchos · https://hub.tmu.edu.tw/en/publications/efficacy-of-paced-breathing-for-insomnia-enhances-vagal-activity-/ · https://pmc.ncbi.nlm.nih.gov/articles/PMC6137615/

#### 39. Apps de tinnitus: ReSound Tinnitus Relief, Oto, Tinnitus HQ y los indies de muesca

**Qué es.** El nicho con mayor LTV y sin dueño. Prevalencia: 30,8 % de adultos estadounidenses con algún acúfeno y **11,6 % con acúfeno molesto** (Apple Hearing Study, BMC Public Health, 19-03-2026, n=125.252); solo el 49 % lo ha comentado con un médico (NHIS). **ReSound Tinnitus Relief** (GN, desde 2014, v5.2.8 del 06-05-2025, 4,7 / 19.500-20.000; ES 4,78 / 338 con ficha solo en inglés): gratis + "My Plan" 6,99 $/mes o 69,99 $/año; lenguaje aprobado: "aim to distract your brain from focusing on tinnitus", "Over time the brain learns to focus less on the tinnitus", "should be used in combination with a tinnitus management programme… set up by a hearing care professional". Beltone Tinnitus Calmer (misma matriz, 4,8 / 3.543, gratis). Widex Zen (4,2 / 40, cautivo del audífono). **Oto** (Oto Health, UK, 4,7 / 848; ES 4,71 / 7 con castellano cuidado; v6.5.3 del 15-11-2026): ya no se vende al consumidor; el acceso lo da una clínica de audiología a 500-1.000 $; IAP residual "90 Day Tinnitus Tune Out" 137,99 $; lenguaje: "the ringing or buzzing you hear in your ears", "Oto no realiza diagnósticos ni sustituye la atención profesional"; ensayo DEFINE (RCT, 210 participantes) "currently in peer review". **Tinnitus HQ** (Phase4, desde 2016, 4,66 / 426): **89,99 $ pago único en EE. UU., 99,99 € en España** ("Acúfenos HQ"), bandpass para localizar el pitch + bandstop de 0,1-4 octavas sobre 500+ grabaciones; su hermana Tinnitus Aid afirma que el tinnitus "can be treated by listening to sounds that have been filtered" (el claim más fuerte de la categoría, actualizado el 15-11-2026). **Indies de muesca 2026**: al menos seis nuevas (Tinnitus Saurus 7,99 $/mes, 59,99 $/año, lifetime 79,99 $; Lull 6,5 MB; Hushh con "octave-confusion check"; Harmonic; mindtone; Soundblanket), casi todas con 0-4 valoraciones y el mismo molde: "wellness app, not a medical device", "does not diagnose, treat, or cure". **Misophonia Sleep Kit** (2018, gratis, 9 valoraciones): tres fondos de banda ancha "engineered to avoid standout sounds", mezclables con podcasts, pausa en llamadas, "does not collect any data".

**Para quién.** Uso crónico, nocturno, todos los días durante años; desconfía de cuentas y datos de salud; ya paga 20 $ por myNoise.

**Lo que aman.** "the deep brown noise on a sound machine kept my Tinnitus at bay… I was able to mix some sounds to get that deep brown noise" (Dark Noise, 2025); "Brown noise even seemed to take away my tinnitus" (White Noise HQ, 2023); "a mix of noise masked the ringing and helped me fall asleep" (ReSound, 21-08-2025); "a literal life saver at times" (ReSound, 2022); "The way the background noise is tuned to your tinnitus specifically is amazing" (Oto, 2021); "Audioterapia en tinnitus postrauma sonoro agudo" (White Noise HQ CO, 2020).

**Lo que odian.** **"Shame on ReSound For Charging $70/Year!"** ("for something that might not even help", 2020); apps que necesitan "volumen peligrosamente alto"; "I wish that it had EQ sliders" (Dark Noise); "there aren't any stereo sounds".

**Qué podemos aprender.** La evidencia es baja (Cochrane 2018: 8 ECA, 590 personas, sin diferencias entre dispositivos; muesca y banda ancha "equally effective at the mixing point"), pero la práctica de enriquecimiento sonoro nocturno es estándar y el mercado paga 70-100 $ por grabaciones filtradas. Todas las apps pasan App Review con el mismo molde: nombrar el síntoma, verbo de enmascarar/distraer, sustantivo "wellness", disclaimer. Ninguna sintetiza el ruido base con control continuo de la muesca en tiempo real. En español las fichas usan "acúfenos" en título y "tinnitus/zumbido" en cuerpo; casi todo está en categoría Medical.

**Hueco para SleepNoise.** Tinnitus como función, no como app: un "Enmascarador con muesca" en Pro (barrido guiado por oído 100 Hz-15 kHz con control de confusión de octava, muesca de anchura variable aplicada en tiempo real a cualquier textura sintetizada, preset "rosa + océano con muesca"), llamado "confort para quienes oyen un pitido" o "enmascaramiento personalizado", nunca "terapia" ni "tratamiento"; "acúfenos" solo en keywords de es-ES.

Fuentes: https://link.springer.com/article/10.1186/s12889-026-27048-2 · https://www.sciencedaily.com/releases/2016/07/160721142805.htm · https://apps.apple.com/us/app/resound-tinnitus-relief/id928432517 · https://apps.apple.com/us/app/oto-tinnitus-sounds-support/id1528362618 · https://joinoto.com/pricing · https://itunes.apple.com/lookup?id=891628361,6782113924,6788676557,6758923584,6762468342&country=us · https://itunes.apple.com/search?term=tinnitus%20ac%C3%BAfenos&country=es&entity=software · https://itunes.apple.com/search?term=misophonia%20sleep&country=us&entity=software · https://europepmc.org/search?query=%22Sound%20therapy%22%20tinnitus%20Sereda%202018

#### 40. Napper

**Qué es.** La prueba de que el sueño del bebé monetiza en español. *Napper: Horario de sueño bebés* (Napper AB, Estocolmo), ficha ES en español, **4,89 / 3.673 valoraciones en España**, v6.97.0 del 15-11-2026; horarios de sueño y 30+ sonidos ("Pink Noise: Bass-boosted white noise", "In the womb", "Lawnmower"); "Featured by Apple" [P]. Está en el **top 25 de ingresos H&F en los cuatro storefronts hispanos** (ES #11, MX #23, AR #20, CO #16), mientras ninguna app de ruido puro aparece en ningún top 50. Contexto de seguridad: Hugh et al. (*Pediatrics* 2014) midieron 14 máquinas infantiles a volumen máximo y todas superaban 50 dBA a 30 cm, tres superaban 85 dBA; la AAP pidió a los pediatras (10-2023) "counsel families about infant sleep machines… about safe use"; recomendación de prensa (Infobae 24-10-2026): >200 cm de la cuna y volumen bajo. 49 % de la Generación Z usa ruido blanco o similar para dormir (Talker Research/Newsweek, n=1.000, vía Infobae 25-11-2024).

**Para quién.** Padres hispanohablantes de 0-24 meses; uso transitorio (2-3 años) pero disparador potentísimo de descarga y boca a boca ("Been using this app for 7 years for each baby", app de bebés US 2026; "This app did better for my baby and I than any sound machine ever could", 2022).

**Precio exacto y modelo.** Prueba "7 days for $0" + suscripción; precios no publicados en ficha ni web.

**Qué podemos aprender.** En español "ruido blanco" ya está asociado a bebés mucho más que en inglés (el #1 de la búsqueda en España es la app de Kaluzynski, 991 valoraciones); el segmento es el único de sonido que monetiza en la cima hispana, pero prefiere suscripción o hardware (Hatch) y es muy sensible al precio.

**Hueco para SleepNoise.** Un "modo cuna" seguro (límite duro de volumen, aviso "colócalo lejos de la cuna, el mínimo volumen, hasta que se duerma", temporizador de retirada gradual 2 h → 1 h → 30 min, sonidos de matriz/latido/aspiradora que las reseñas piden) como función que captura el disparador "nacimiento" sin cambiar el posicionamiento adulto high-end. Decisión de producto pendiente: si se renuncia a la keyword "bebé" para no diluir la marca.

Fuentes: https://itunes.apple.com/search?term=napper&country=es&entity=software · https://napper.app · https://itunes.apple.com/es/rss/topgrossingapplications/limit=50/genre=6013/json · https://itunes.apple.com/mx/rss/topgrossingapplications/limit=50/genre=6013/json · https://europepmc.org/search?query=%22Infant%20sleep%20machines%20and%20hazardous%20sound%20pressure%20levels%22 · https://mother.ly/news/aap-warning-sound-machines/ · https://www.infobae.com/tendencias/2026/10/24/ruido-blanco-para-dormir-4-riesgos-que-puede-tener-su-uso-prolongado/ · https://www.infobae.com/tendencias/2024/11/25/el-ruido-blanco-una-ayuda-para-el-descanso-cada-vez-mas-aceptado-entre-las-generacion-z/

---

## 3. Lecciones transversales

1. **La queja número uno de las 40 fichas es el cobro, no el sonido.** En EE. UU. el 32 % de las reseñas de 1-3★ de apps de ruido habla de precio/suscripción y el 17 % de "antes era gratis"; en español, 26 % y 12 %, más un 24 % que denuncia prueba cobrada o cancelación imposible. Trustpilot: Calm 1,3-1,5/5 (78 % de 1★), Endel 2,8/5 (58 % de 1★), Loóna 2,5/5. Las palabras se repiten en los dos idiomas: "auto renewed", "charged after cancelling", "6x the rate", "estafa" (20), "robo" (10). El pago único de SleepNoise es un argumento de marca, no un detalle de precio; en boca del usuario se llama "de por vida" ("pónganla directamente como paga"). Fuentes: feed RSS de reseñas US/ES/MX/CO/AR; Trustpilot calm.com, endel.io, loona.app.

2. **Nadie ocupa a la vez las cinco casillas.** Síntesis en tiempo real (solo Veil, 3 capas), mezclador de seis capas (NoiseNest con grabaciones), pago único puro (Things, AutoSleep, myNoise, TMSoft), sin cuentas ni analítica (AutoSleep, Gentler Streak, Misophonia Sleep Kit), y peso de pocos MB (Pzizz 34 MB, Veil 65 MB, NoiseNest 27 MB frente a Dark Noise 430 MB, Tide 490 MB, ShutEye 725 MB). Hoy se consigue como máximo tres. Fuentes: fichas de App Store citadas en cada ficha; veilsleep.app/compare/veil-vs-dark-noise.

3. **Los bucles son el único defecto técnico que el usuario percibe y castiga.** 37 reseñas US mencionan bucles, repeticiones o clics (7 % de los 1-3★ de apps de ruido): "A skip… can absolutely wake me up" (Noise Machine), "Brown noise has audible 'jump' when it loops" (Dark Noise), "an obnoxious squeaking in the Rain sound every 15 seconds" (BetterSleep), "3 segundos y se repetía lo cual era muy estresante" (Rain Rain MX). Todas las fichas dicen "seamless" o "endless"; ninguna lo demuestra. "Nunca se repite" merece prueba visible (onda en la preview de la ficha, modo de escucha de 60 s) y respaldo científico indirecto (Debellemanière 2022: variar estímulos reduce la habituación). Fuentes: feed RSS de reseñas; https://orca.cardiff.ac.uk/id/eprint/150873/.

4. **La fiabilidad nocturna es la función.** Las quejas técnicas transversales son: se para en segundo plano (Atmosphere, White Noise HQ: "set for 11 hours, it will sometimes arbitrarily just quit"), cambia de sonido tras una notificación (Dark Noise), el timer falla o silencia la alarma del sistema (Rain Rain), consume batería o calienta (BetterSleep MX, Rain Rain, Slumber, Calm CO), sigue sonando tras cerrarse (BetterSleep, Noisli), no se pausa al desconectar auriculares. Para un DSP propio son triviales; publicarlas como garantías medibles ("10 h con pantalla bloqueada; X % de batería en 8 h") vale más que diez texturas nuevas. Apple añade en iOS 26 la pausa de AirPods al dormirse, que la app debe manejar como fundido corto, no corte seco. Fuentes: feed RSS de reseñas; https://support.apple.com/guide/airpods/change-settings-for-airpods-or-airpods-pro-dev57e5b7e58/27/web/27.

5. **El mezclador con mezclas guardadas es la razón de fidelidad más citada y su pérdida un motivo de 1★ por sí solo.** "I created a mix 10 years ago and still play it every night" (Slumber); "olas+viento+truenos=tempestad en alta mar" (Rain Rain ES); frente a "90% of my mixes are now locked" (BetterSleep), "all my custom mixes are still here by name but contain no sounds" (Dark Noise), "The max on a phone is 3 but I feel like it needs more" (Rain Rain). El uso es episódico y por reinstalación (bebé, mudanza, obras, duelo, racha de estrés; "eventually I didn't need it anymore", Pzizz), así que la retención que importa es que el usuario vuelva años después con sus mezclas intactas y sin un nuevo cobro. Fuentes: feed RSS de reseñas US/ES/MX/AR.

6. **El control espectral fideliza al usuario exigente, pero nadie lo hace con UI minimalista.** Los sliders de myNoise ("so vital as someone who gets unpredictably annoyed by certain tones"), el Soften y el Oscillator de Rain Rain, el Tape Speed, el Studio de Veil, los ajustes densidad/espacio/brillo de Soundcore, y la petición literal de "a low-pass frequency filter" (TMSoft) y "EQ sliders" (Dark Noise). El hueco es un gesto de una mano a oscuras para "más grave / más lejano" con el detalle técnico escondido, más un filtro de muesca para acúfenos sobre síntesis. Fuentes: fichas 8, 9, 10, 12, 17, 36, 39.

7. **Apple ya regala la capa básica y mide mejor que nadie: no competir en medir ni en "ruido + temporizador".** Sonidos de fondo (16 sonidos, EQ, timer en iOS 26), Sleep Score, apnea, Vitals, pausa de AirPods. Los usuarios ya envían a Ajustes a quien cobra 2 $/mes por ruido. La oportunidad está en lo que un submenú de accesibilidad no hace: capas, textura viva, fundidos largos, respiración acoplada, rutina, cierre inteligente, diseño. Cualquier puntuación propia compite con una gratuita que ya genera ansiedad (ortosomnia). Fuentes: https://support.apple.com/HT212775; https://www.macworld.com/article/2947066/i-dont-trust-my-apple-watchs-sleep-score-and-neither-should-you.html; Baron et al., JCSM 2017.

8. **La Marea respiratoria es la función mejor alineada con la evidencia y nadie la tiene.** Respiración lenta a ~6/min: evidencia alta para HRV (223 estudios, Laborde 2022) y media-baja para latencia (Tsai 2015: 20 min antes de acostarse redujo latencia y despertares en 14 insomnes). Ninguna app de respiración (Breathwrk, Othership, Breathe+, BreathWise, Pranayama, Apple Breathe) acopla un paisaje continuo que se acompasa y se disuelve; Balance acopla estimulación bilateral y respiración, no la textura del ruido. Riesgo aprendido de Endel: el audio que "hace cosas" de noche puede inquietar ("bad dreams", "caos que me pone de los nervios"), así que la Marea debe ser opt-in, lenta, previsible y desactivable; y en 2.351 reseñas nadie la pide: hay que enseñarla, y poner el enmascaramiento primero en la ficha. Fuentes: https://onlinelibrary.wiley.com/doi/abs/10.1111/psyp.12333; https://pmc.ncbi.nlm.nih.gov/articles/PMC6137615/; ficha 38.

9. **El hueco de precio de pago único está entre 20 y 49 $, y la escalera real es pública.** 0,99 $ White Noise → 9,99 $ AutoSleep / Pzizz Premium → 19,99 $ myNoise → 24,99 $ Veil → [vacío] → 49,99 $ Dark Noise lifetime (junto a un anual de 19,99 $) → 99,99 $ Portal → 124,99 $ Endel → 399-499 $ Calm. Los informes de origen discrepan (9,99 frente a 29,99-49,99 $) porque miran comparables distintos: las reseñas de apps "de sonidos" consideran 19,99 $/año "ridiculous" y 5 $ "perfect lifetime price", mientras los lifetimes indie de calidad viven en 50-70 $. La única elasticidad medida en el nicho (Dark Noise, −50 % → +59,3 % de conversión, ≈ −0,7 de arco) indica que subir de 9,99 a 29,99 $ gana entre 0 % y 39 % de ingreso por descarga y solo pierde si la elasticidad supera −1,3. Síntesis: 29,99 $ / 29,99 € como precio de lista defendible solo si la ficha vende "más que sonidos" (síntesis, seis capas, Marea, diseño, Watch/HomePod, Family Sharing); 19,99-24,99 $ si se quiere evitar toda fricción; nunca 9,99 $ (estante AutoSleep) ni 49,99 $ sin suscripción al lado. En LatAm Apple equaliza al dólar íntegro (MX ≈ 20×, CO ≈ 4.600-5.000×, AR en USD) y hay 14 reseñas pidiendo precio regional. Fuentes: https://charliemchapman.com/posts/2021/1/1/first-sale/; https://www.revenuecat.com/state-of-subscription-apps; fichas MX/ES/AR/CO citadas en la sección de mercado hispano.

10. **La prueba sin tarjeta es un titular, no un detalle.** La prueba cobrada es el trauma hispanohablante (42 reseñas de apps de ruido y 65 de meditación en español describen cobros al activar la prueba; "Primero tarjeta, luego prueba… ¿Por qué no dejáis hacer la prueba gratuita sin tener que poner la tarjeta?", Endel ES). Portal demuestra que una prueba de 7 días "no upfront payment details, no auto-subscribe and no need to cancel" pasa App Review en esta categoría; la guía 3.1.1 ofrece el non-consumable "XX-day Trial" a nivel 0 con pantalla previa de duración, pérdidas y precio como vía canónica (y habilita Family Sharing, que no puede desactivarse después). Un reviewer de Calm dice que 7 días "is too short to evaluate the product"; RevenueCat: las pruebas de 17-32 días convierten mejor. Fuentes: https://apps.apple.com/us/app/portal-escape-into-nature/id1436994560; https://developer.apple.com/app-store/review/guidelines/; https://www.revenuecat.com/state-of-subscription-apps.

11. **El lenguaje que pasa App Review está probado en apps vivas; el que no, también.** Permitido y habitual: "fall asleep faster", "sleep through anything", "wind down", "soothe/manage stress and anxiety", "mask", "distract your brain from tinnitus", "wellness app, not a medical device"; en español: "enmascara", "El ruido marrón no trata nada — enmascara" (Slo), "transitar la ansiedad cotidiana" (Petit BamBou), "no es un producto sanitario". Prohibido: "treat", "cure", "insomnia" como diagnóstico, "therapy" sin matizar, "clinically proven", porcentajes de mejora, umbrales, "grado médico" (Warning Letter a WHOOP). La FDA (06-01-2026) describe literalmente a SleepNoise como no-dispositivo ("plays music to 'soothe and relax'… and to 'manage stress'"). "Insomnio" solo en el campo de keywords. Fuentes: fichas 18, 6, 32, 38, 39; https://www.fda.gov/media/90652/download.

12. **El diseño premium de la categoría es monocromo, oscuro y "ignorable", y Apple premia la restricción.** Endel (líneas blancas finas sobre negro, "semi-generative animated visualization"), Dark Noise (iconos animados, True Black, Liquid Glass solo en navegación), Portal (controles mínimos), Balance (cinco secciones, sin colores brillantes, 4,9★), Tide (editorial). Las tres apps nativas premiadas con ADA en 2026 (Moonlitt, Tide Guide, Interaction y Visuals) exigen iOS 26, mantienen el vidrio en la navegación y la identidad en la capa de contenido, y mueven algo con causa física (la curva de la marea con marcador del momento). Lo que ahuyenta: gestos ocultos y "overload of text" (Endel), vidrio apilado, animación que no para en Always-On, onboarding de 18 pasos (Loóna), pedir valoración al abrir, ofertas a quien ya pagó. Territorio libre: materialidad e instrumento (negro OLED real, una tipografía, un acento de baja luminancia verificado bajo el tinte rojo de StandBy, la envolvente real de la síntesis como única fuente de color), más cerca de un objeto de diseño industrial que de una app de bienestar. Fuentes: https://ixd.prattsi.org/2026/02/design-critique-endel-ios-app/; https://developer.apple.com/design/awards/; https://developer.apple.com/design/human-interface-guidelines/materials; https://developer.apple.com/design/human-interface-guidelines/live-activities.

13. **El listón de integración Apple lo marca Dark Noise y hay superficies sin explotar.** Esperado en 2026: Siri/Shortcuts con AudioPlaybackIntent (iOS 17), widgets interactivos y de bloqueo, Live Activity de la sesión (límite 8 h activa / 12 h en bloqueo), control de Centro de control y botón de Acción (iOS 18), AirPlay 2 con compensación de 2 s de latencia para la animación de la Marea, Apple Watch autónomo ("¿Quién duerme con auriculares??", Calm ES; "Would love to see an Apple Watch app", Dark Noise). Sin explotar por nadie: StandBy diseñado para el tinte rojo nocturno, Focus Filter para el Focus de Sueño, reaccionar a la pausa de AirPods al dormirse, leer la frecuencia respiratoria nocturna de HealthKit para calibrar el punto de partida de la Marea (nunca como condición de Pro, 5.1.1) y escribir la sesión como mindfulSession. Fuentes: ficha 9; https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities; https://developer.apple.com/documentation/appintents/audioplaybackintent; https://developer.apple.com/documentation/avfaudio/avaudiosession/outputlatency.

14. **El mercado hispano está vacío en la cima y se habla distinto.** Ninguna app de ruido puro en el top 50 de ingresos H&F de ES, MX, AR ni CO (solo Napper, híbridos tracker+ruido y meditación); Dark Noise tiene 73 valoraciones en España, myNoise 27, Veil 0, frente a 24.162 de Calm y 3.764 de BetterSleep; rankea quien lleva la keyword en el título y myNoise entra en el top 10 de "ruido marrón" solo por su título localizado. La categoría se llama "sonidos para dormir" (122 apariciones de "sonidos" frente a 20 de "ruido"); "ruido blanco" pertenece a los bebés; "ruido café", "ruido rosa" y "brown noise" tienen cero apariciones en reseñas; "ansiedad" (27) triplica a "insomnio" (8); el éxito se dice "duermo como un bebé" y "antes del minuto estoy dormido"; el enmascaramiento se dice "bloquear" o "tapar" el ruido; "temporizador", "mezcla", "reloj de noche", "pago único / de por vida". Fichas separadas es-ES y es-419, con copy nativo frente a la traducción automática dominante, y prensa de Infobae (única con cobertura recurrente, nunca nombra una app de terceros y recomienda Sonidos de fondo) con el ángulo "lo que Sonidos de fondo no hace". Fuentes: feeds RSS de rankings y reseñas de Apple (16-11-2026); https://itunes.apple.com/search?term=ruido+marron&country=es&entity=software&limit=15; https://www.infobae.com/tag/ruido-blanco/.

15. **El crecimiento es orgánico o no es, y el diseño es una decisión de negocio.** Con CPI de 4-10 $ en wellness y conversión descarga→pago del 3-7 %, un comprador cuesta 70-330 $ frente a ≈25 $ netos de un Pro de 29,99 $: la publicidad no cierra. Lo que sí multiplicó descargas 10-40× durante semanas fue el featuring de Apple (Dark Noise: "Apps We Love", MacStories, r/Apple; 4.545 compras en el primer mes de 2019; Portal: Editors' Choice con lifetime a 99,99 $). El consumo de apps de sueño se contrae (Calm −24 %, Headspace 71→39 M$, Sleep Cycle −24 % de suscriptores) y los líderes huyen a B2B, pero el pico de instalaciones del 1 de enero (+46 %) y el ruido marrón viral en TikTok siguen ahí. Maximizar la probabilidad de featuring (diseño impecable, adopción de plataforma, honestidad técnica, Notes for Review contra 4.3(b) con la síntesis como defensa) es el plan de marketing. Fuentes: https://charliemchapman.com/posts/2019/9/27/marketing-dark-noise/; https://admiral.media/mobile-app-marketing-benchmarks-2026/; https://www.adjust.com/blog/2024-holiday-app-trends/; https://attachment.news.eu.nasdaq.com/a261b009a50cb200a277195c4b9cc1f7f.

---

## 4. Lagunas heredadas de las investigaciones de origen

- Reddit (r/insomnia, r/tinnitus, r/ADHD, r/misophonia, r/beyondthebump, r/Apple) fue inaccesible en las dos rondas; la voz del cliente procede de App Store (US, ES, MX, CO, AR), Trustpilot, agregadores, HN y ADDitude.
- Las cifras de ingresos de Calm, Headspace, BetterSleep, ShutEye, Endel y Aura son estimaciones de terceros (Business of Apps, Udonis, Sensor Tower, Appfigures, GetLatka), algunas tomadas de resúmenes de búsqueda por 403 en la fuente.
- No se analizó el audio de Veil ni se verificó el lifetime de 249,99 $ de BetterSleep en su ficha actual (solo la promoción de 99,99 € en España y reseñas que citan "$250").
- Prensa española (Xataka, Applesfera, Hipertextual, El País) y Google Trends no se pudieron consultar; la lista de prensa hispana se apoya solo en Infobae y El Tiempo.
- Precios de Portal, Pzizz, Rain Rain y Tide en AR y CO; tipos de IVA por país (21/16/19/21 son conocimiento propio); prevalencia nacional de insomnio en Argentina, Colombia y Chile.
- Mecanismo exacto de la pausa de AirPods al dormirse y comportamiento de Endel Sleep con Apple Watch: sin documentación ni prueba independiente.
