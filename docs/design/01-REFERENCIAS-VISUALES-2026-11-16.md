# SleepNoise · 01 · Auditoría de referencias visuales

**Estudio de diseño · investigación de diseño · 16 de noviembre de 2026**

Encargo: antes de dibujar una sola pantalla, fijar de dónde viene (y de dónde no) la dirección visual de "el instrumento de sueño". Este documento describe con precisión treinta y tantas referencias (apps, objetos, estudios), levanta el mapa de códigos ya ocupados en la categoría sueño, reclama un territorio libre con tres moodboards descritos en palabras y cierra con los clichés prohibidos y la lista de fuentes.

Insumos leídos completos: informe de investigación de mercado (`docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md`), auditoría visual del set de referencia y posicionamiento premium (segunda ronda, scratchpad), revisión del PR #3 (`docs/REVIEW-PR3-2026-11-16.md`), `Theme.swift`, `MixerView`, `SoundRowView`, `BreathingCard`, `PaywallView`, `SleepTimerView`, `SavedMixesView`, y las trece capturas (cinco del estado actual, ocho del PR #3). El plan de funciones priorizado (`docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md`) **no existía** al empezar: trabajo con las diez oportunidades del informe y dejo dicho que el inventario definitivo de pantallas llegará de ese plan.

Convenciones. **[V]** = verificado hoy en una fuente abierta (URL en §9). **[E]** = conocimiento del estudio o memoria no verificada hoy; se marca para que nadie lo cite como dato. Las citas van en su idioma original. Los ratios de contraste son cálculo WCAG propio sobre negro 0,0,0, redondeados.

---

## 0. Lo que ya sabemos antes de mirar fuera

### 0.1 Restricciones que mandan sobre cualquier referencia

- SwiftUI iOS 17+, adopción progresiva de 18/26; **Liquid Glass solo en navegación** (HIG: "Don't use Liquid Glass in the content layer"), y solo si se usa.
- **Sin fuentes empaquetadas** salvo justificación fuerte. Familias disponibles: SF Pro, SF Pro Rounded, SF Mono, SF Compact (Watch), New York, y las instaladas en iOS (Avenir Next, Georgia, Palatino, Menlo, Helvetica Neue, Charter, Baskerville, Didot, Optima, Futura, Gill Sans, Courier New, American Typewriter…). Esto importa porque **Avenir Next (la Bear de 2016-2023) y Optima (el logotipo de Aesop) están en iOS sin coste** [E: lista de familias instaladas de memoria; comprobar con `UIFont.familyNames` en el dispositivo].
- Dynamic Type, VoiceOver, Reduce Motion, WCAG AA (4,5:1 texto; 3:1 texto grande ≥ 18 pt o negrita ≥ 14 pt), objetivos de 44 pt.
- Negro OLED real (0,0,0) como superficie nocturna; legibilidad bajo el tinte rojo de StandBy nocturno (HIG: "the system applies a red tint… Check that your Live Activity design uses colors that provide enough contrast in Night Mode" [V]).
- Nada de afirmaciones médicas en el copy.

### 0.2 Qué dice el estado actual (capturas `ui/before/`)

Lo que ya funciona: una sola familia (SF Pro), negro casi puro, un único acento (ámbar 235,184,115 ≈ 11,6:1 sobre negro), copy corto y honesto ("7 días con todo. Sin tarjeta.", "El audio se desvanece antes de que termine el temporizador."), la Marea como una fila más del mezclador, sin onboarding. Lo que todavía no es high-end:

1. **Todo es tarjeta.** Mezclador, Marea, prueba, beneficios del paywall, temporizador y respiración viven en rectángulos rellenos de 16-18 pt de radio sobre un degradado. Es el lenguaje de "ajustes agrupados", no el de un instrumento. Bear y Things separan con aire y hairlines, no con cajas.
2. **El acento está repartido** (icono activo, slider, cifra, botón Play de 112 pt relleno, chips de prueba, toggle, lock, "Cerrar"). Cuando todo es ámbar, nada es el instrumento.
3. **El Play ocupa el sitio del valor.** El disco ámbar de la barra inferior es el elemento más grande de la pantalla; el sonido en sí (la envolvente real del DSP, la prueba "nunca se repite") no se ve en ninguna parte.
4. **Grises de capa**: `background` 14,17,20 y `card` 31,35,39 son azulados y no son negro OLED; el radial ámbar del fondo (`NightBackground`) es un resplandor decorativo que gasta GPU y suma "wellness".
5. **Iconografía mezclada**: SF Symbols de líneas (waveform) junto a rellenos (speaker, fan) y el símbolo de la Marea es un disco gris sin forma.
6. **Jerarquía tipográfica plana**: Large Title + Body + Caption, casi todo semibold; no hay un tamaño "de instrumento" (la cifra grande) salvo en el temporizador (44 pt light rounded, que la HIG desaconseja: "Avoid Ultralight, Thin, and Light weights").

### 0.3 Qué enseña el PR #3 (capturas `ui/pr3/`): la dirección contraria, útil como negativo

Veintitrés formas rellenas (disco de 300 pt, cápsulas, diez chips, once baldosas) sobre un degradado animado a 15 fps; catorce candados visibles para el usuario gratuito; el mezclador escondido tras una "asa" falsa en una hoja titulada "Niveles"; SF Rounded semibold en todo; contraste baldosa/fondo 1,08:1 en claro; objetivos de 40 pt. Dos cosas sí valen: la **pantalla Noche** (negro puro, reloj y cuenta atrás en un marrón apagado, dos controles de línea, "The screen can sleep. Sound keeps playing.") es lo más cerca de "instrumento" que hay en todo el repositorio, y la idea de **un toque para empezar**. Lo demás es exactamente el catálogo de lo que un estudio evita: rejilla de iconos como una tienda, acento en diez controles, resplandor que no significa nada.

Lección que se repite en toda la auditoría: **la app parece cara cuando hay una sola cosa que se mueve y significa algo, y todo lo demás está quieto.**

---

## 1. Apps

### 1.1 Bear (Shiny Frog) — la referencia declarada del dueño

**Observaciones [V salvo marca]**

1. **Red Graphite es blanco, negro y un solo rojo.** Es el tema por defecto desde Bear 1 (2016) y sigue gratuito en Bear 3; MacStories lo describe como "a white UI with black and red accents". El rojo no colorea superficies: colorea *marcas* (etiquetas, enlaces, el icono activo). Los usuarios llevan desde 2024 pidiendo una versión OLED: "Could we please have a Red Graphite theme for Dark Mode where the white background is replaced with a true OLED friendly black" (foro, 2-11-2024; apoyado en mayo de 2025). Shiny Frog respondió en enero de 2026 con temas "AMOLED" nuevos, no con Red Graphite negro. **Hay un hueco literal: nadie ha hecho "Red Graphite nocturno".**
2. **Avenir Next fue la voz de Bear de 2016 a 2023.** Luego llegó Bear Sans (agosto de 2023), "a customized version of Clarika by Brandon Knap", porque "Avenir can be fatiguing to read at smaller body text sizes": glifos demasiado uniformes, poco contraste de trazo, espaciado suelto. Querían conservar "Avenir's geometric spirit" con mayor altura de x, aperturas más abiertas y espaciado más prieto. Bear 3 (nov. 2026) extendió Bear Sans (BearSansUI / BearSansUIHeadline) a la interfaz y abrió la elección de cualquier tipografía [V vía blog de terceros; release notes no leídas]. **Lectura:** la "Bear-ness" no es Avenir, es *una familia geométrica humanista usada a tamaño generoso con interlineado amplio*. En iOS podemos tenerla sin empaquetar nada: Avenir Next está instalada; SF Pro a 17/22 con tracking ajustado es la alternativa segura.
3. **Hairlines y aire, no cajas.** Las separaciones son líneas de 0,5 pt (1 px) a baja opacidad y márgenes de 16-20 pt; las notas no tienen tarjetas; el estado activo se dice con color de texto, no con fondo. La tipografía del editor permite "line height, line width, and paragraph spacing" como ajustes de primer nivel: la retícula es del usuario.
4. **Jerarquía por peso y tamaño, con tres escalones**: título de nota, cuerpo, metadatos (fecha, etiquetas en gris). No hay cuarto escalón.
5. **Movimiento casi nulo.** Lo único que se mueve es lo que el dedo mueve (paneles, listas). Liquid Glass se adoptó el día del lanzamiento de iOS 26 (2.6, 15-09-2025), limitado a barras; el contenido no cambió.
6. **Copy**: principios publicados en el décimo aniversario (3-11-2026): "Simple" ("No sign-up or tutorial"), "Natural", "Rewarding to explore", "Private" ("No servers hold notes"), "delightful to use, and safe to trust". Reseña: "The UI is elegant and cozy and enjoyable to work in." Tono: frases cortas, primera persona del plural, sin superlativos.
7. **Qué la hace parecer cara**: la restricción (un rojo, una familia, una retícula), el peso del texto como material principal, y que todo lo que se ve es contenido del usuario.

**Qué tomar**: la tríada papel/tinta/un solo rojo, convertida a noche (negro/papel cálido/un acento); hairlines de 0,5 pt a 12-18 % de opacidad en lugar de tarjetas; tipografía humanista geométrica (SF Pro con tracking cerrado, o Avenir Next Medium si se decide "voz propia"); cero onboarding; el principio "safe to trust" como copy de privacidad.
**Qué no**: el blanco (es una app de día; la nuestra no); la sidebar y la densidad de una app de documentos; los 28 temas (una app de noche necesita un tema y, como mucho, una variante de día).

### 1.2 Things 3 (Cultured Code)

**Observaciones [V]**

1. **95 % neutro, color con significado**: amarillo para Hoy, rojo para plazos, índigo/azul para Esta noche; el azul de marca solo en acciones. Tres fuentes de terceros dan tres hexadecimales distintos (#5c9cf5, #3A82F7, #2576eb): el color de Things es más una regla de uso que un valor.
2. **Tipografía del sistema, bien usada**: San Francisco con títulos grandes, listas a 17 pt, metadatos pequeños en gris; "revamped typography and generous white space" (MacStories 2017). No hay fuente propia; la personalidad está en el espaciado.
3. **El post "Things for OS 26" (15-09-2025)** es el mejor manual breve de Liquid Glass para una app tipo Bear: "a touch of glass in the sidebar that lets a hint of color shine through", botones con "a subtle glow and scale" al tocar, el botón Magic Plus con "new liquid nature" que se deforma al arrastrar, curvatura revisada de "windows, to-dos, dialogs, and controls" y "wider spacing that feels a bit more relaxed". No usan la palabra Liquid Glass en su blog.
4. **Un gesto-objeto**: el Magic Plus es el único control con física propia; todo lo demás es lista. Es el patrón que queremos para el Play/Marea.
5. **Precio**: 9,99 $ pago único en iPhone; la web no muestra precios; dos Apple Design Awards; Wirecutter: "the best combination of design and functionality of any app we tested".
6. **Copy**: "Simply Powerful", "Get Things, Get Done"; adjetivos *powerful, simple, beautiful, tactile, crisp*; secciones de dos o tres palabras.

**Qué tomar**: color = significado (un color por estado, nunca por decoración); un solo control con física; "wider spacing" como señal de iOS 26; precio dicho una vez.
**Qué no**: el blanco y la alegría diurna; los iconos de colores por proyecto.

### 1.3 Dark Noise 3.6 (Dark Noise LLC) — el competidor directo que ya ganó el canal Apple

**Observaciones [V]**

1. **Diez temas, incluido True Black**, más de veinte iconos alternativos; requiere iOS 26; 430 MB. El tema es una función de pago y un motivo de reseña ("Best alternate app icons ever? I think yes", MacStories 2019).
2. **Iconos animados por sonido** ("each with an animated icon"; en la pantalla de reproducción "they're animated… a lovely effect"). Son ilustraciones de línea monocromas, un icono por sonido, animación en bucle corto. Es la seña de identidad de la app y **está ocupada**.
3. **Lista, no rejilla**: la pantalla principal es una lista de sonidos por categorías (Water, Appliances, Nature, Fire, Urban, Human), favoritos arriba; la reproducción sube desde abajo "buttery smooth" con clics hápticos al final de la transición, al marcar favorito, al reordenar, al pausar. Hápticos reducibles en Ajustes.
4. **Now Playing rediseñado con Liquid Glass (3.6, 12-09-2026)**; Live Activities y Dynamic Island desde 3.0 (2023); widgets interactivos (2023); control de Centro de control (2024); "Magic Mix" por texto con Apple Intelligence (3.5). Cronología de adopción de plataforma inmediata, cada septiembre.
5. **Copy**: "Simple. Fast. White noise, refined." · "Independent since 2019" · "Quiet praise for a calmer app." · "Made by Charlie Chapman in St. Louis, MO". Web con tres citas de prensa y un sello.
6. **Fallos documentados**: "the app CHANGES my sound to a real low and soft WHITE NOISE sound about 8-10 seconds after the alert" (2025); "Brown noise has audible 'jump' when it loops" (2025); sin app de Watch (petición recurrente); sin español.

**Qué tomar**: la disciplina de plataforma (cada API de Apple el día que sale), hápticos como confirmación discreta, transición única y perfecta en lugar de muchas, el tono "quiet praise".
**Qué no**: iconos ilustrados animados por sonido (es su firma), temas de pago, 430 MB de grabaciones, rejillas de favoritos.

### 1.4 Endel

**Observaciones [V]**

1. **Negro con líneas blancas finas y puntos**: "thin white lines and sparkling dots appear on a black screen" (Protey Temen, director visual, en Readymag). Influencias declaradas: minimalismo, notación musical de vanguardia, ciencia ficción. Cada paisaje tiene "their own generative visual", una visualización semigenerativa que "symbolizes its theme". Apple: "elegant monochromatic interface on iOS and Apple Watch".
2. **Tipografía**: grotesca neutra, mayúsculas con tracking amplio para modos (SLEEP, FOCUS, RELAX), cuerpos pequeños [E: de memoria de la app; no verificado hoy]. Mucho texto "científico" ("7x" foco, "3.6x" menos estrés) que una crítica llama "science overload".
3. **Movimiento orgánico**: "organic and soothing, never jarring" (screensdesign). El visual se mueve siempre; es el centro de la pantalla.
4. **Lo que falla**: "There's nothing on this that seems to be 'adapting'", "rustling sound like crunching paper", límite de 10 minutos para no suscriptores, "Why should I have to get set up under subscription just to try the free trial?". Lifetime 124,99 $.
5. **Filosofía de Temen**: "the designed world should be as detailed as possible" para generar "trustability".

**Qué tomar**: la idea de que el visual *es* el sonido (no una ilustración al lado); el monocromo como voz.
**Qué no**: líneas blancas finas + puntos sobre negro con aire sci-fi (es Endel y lo reclama en cada captura); copy con multiplicadores; visual que no para nunca.

### 1.5 Portal (Portal Labs)

**Observaciones [V]**

1. Vídeo "up to 12K" de paisajes como superficie entera; la UI flota encima en blanco con blur. Editors' Choice: "the prettiest clock you've ever seen"; Webby "Best Visual Design" (autoproclamado en ficha; no verificado en webbyawards.com).
2. Luces Hue/Nanoleaf/HomeKit sincronizadas, Spatial Audio con head-tracking, Live Activities, Pomodoro.
3. Monetización bien recibida ("the monetization model was really wonderful"), 3 portales gratuitos rotativos al mes; lifetime 99,99 $.
4. Copy: "Fall asleep in the mountains", "Escape into nature". Cinematográfico.

**Qué tomar**: la ambición de dominar la mesilla entera (luces, reloj grande, AirPlay); la claridad de "qué se ve gratis".
**Qué no**: fotografía/vídeo como fondo (el código visual más caro de producir y el más copiado por BetterSleep y Calm); blancos con blur sobre imagen; cualquier cosa que no pueda ser negro puro a las 3 a. m.

### 1.6 Balance (The Mind Company)

**Observaciones [V]**

1. 4,9★ con 121 K; minimalismo de bienestar: "restrained color scheme, open spacing, and gentle motion"; crítica: "lacks the distinctive visual identity of Headspace or Calm"; "some screens felt slightly cramped on smaller phones".
2. **Wind Down**: "pairs bilateral stimulation with controlled breathing": sonido que alterna oído izquierdo/derecho mientras una forma guía la respiración. Es la objeción a "nadie acopla sonido y respiración" y la referencia que la Marea debe superar (la nuestra acopla *la textura*, no un tono).
3. Degradados pastel lavanda/azul/durazno en tarjetas, ilustración plana ocasional, voz humana como contenido central; "Google Play's Best App of 2021" (no Apple). Lifetime 399,99 $.

**Qué tomar**: el mecanismo Wind Down como competidor directo de la Marea (hay que medirlo con auriculares y documentarlo).
**Qué no**: pastel lavanda, tarjetas con degradado, "primer año gratis".

### 1.7 Tide (Moreless)

**Observaciones [V]**

1. "Less is more" declarado en la ficha; pantalla principal = fotografía a pantalla completa de un escenario (mar, lluvia, bosque) con cita literaria del día, hora y un botón de inicio centrado; "emotional visual effects". App Store Best of 2017.
2. Modo Focus inmersivo con cuenta atrás grande en blanco sobre la foto; "Ocean Breathing" y "Heart Coherence Breathing" recientes; optimizada para iOS 27, Liquid Glass, StandBy, Live Activities (ficha de nov. 2026).
3. Reseñas: "Ads free and minimalist design is really great"; "Tide forces nothing on its users when it comes to making additional payments". Tide Plus 34,99-59,99 $/año.

**Qué tomar**: la cuenta atrás como protagonista tipográfico; la ausencia de presión de compra.
**Qué no**: fotografía de naturaleza como fondo + cita inspiracional del día (código ocupado por Tide y Calm; y una cita a las 3 a. m. es lo contrario de descanso).

### 1.8 Gentler Streak (Gentler Stories)

**Observaciones [V]**

1. ADA 2024 Social Impact; jurado: "a subtle and consistently pleasing design language"; Sebastian Röhl: "The gold standard of how a native iOS app should look." Liquid Glass en 5.13 (14-09-2026).
2. Paleta cálida de crema y naranjas/rosas suaves sobre fondo oscuro o claro; gráfica propia del "camino" de actividad con una banda ondulada; tipografía SF con títulos redondeados [E: de memoria de la app]. Copy en lenguaje llano: "It's everyday language: no one is excluded".
3. Privacidad idéntica a la nuestra: "No user accounts. No servers." y "not a medical device". Tono: "powered not by insistent reminders but an optimistic and encouraging vibe" (Apple).
4. Equipo: "We want the app to be as accessible as possible… Every now and then, we throw in some cute surprises".

**Qué tomar**: la frase de privacidad como argumento de marca; el tono sin culpa (clave para "Descenso" y notas de noche); demostración de que Apple premia bienestar no coercitivo.
**Qué no**: ilustración de personajes, sorpresas "cute" (nuestro usuario está medio dormido).

### 1.9 Flighty (Flighty LLC)

**Observaciones [V]**

1. ADA 2023 Interaction; Apple: "a look that mirrors time-honored airport design conventions"; Ryan Jones: los paneles de aeropuerto tienen "one line per flight" y la Live Activity y la Dynamic Island se diseñaron sobre esa analogía.
2. Datos densos en calma: monoespaciado para horas y puertas, mayúsculas pequeñas para etiquetas, un verde/ámbar/rojo semafórico solo para estado [E: tipografías exactas no verificadas; el análisis público habla de "calm, clear design inspired by decades of airport signage"].
3. 15 "smart states" que cambian la pantalla según el momento del viaje: la jerarquía la decide el contexto, no un menú.
4. "Free on your first flight" como prueba; "Unlimited aviation nerdery" como voz. Rediseño con Liquid Glass en 2026.

**Qué tomar**: la **analogía con un lenguaje de señalización existente** (Flighty = aeropuerto; SleepNoise = instrumento de medida/mesa de mezclas) para que la Live Activity y StandBy hereden una gramática reconocible; "una línea por capa" como regla de la Live Activity; estados según momento de la noche.
**Qué no**: densidad de datos (nuestra noche tiene dos o tres cifras como mucho).

### 1.10 Halide Mark III (Lux)

**Observaciones [V]**

1. Lanzado el 27-05-2026 con interfaz nueva: "puts the most important tools within easy reach without overwhelming the user"; el diseño Mark II sigue disponible "with a few taps".
2. **Process Zero** ("Zero AI, Natural Photos, RAW") y el dial único de Image Lab: la transparencia técnica es el producto. Reseñas y prensa lo llaman "anti-intelligent".
3. Negro mate, controles amarillo-ámbar sobre negro, tipografía SF con cifras monoespaciadas en el visor, dial físico simulado con detentes hápticos [E: de memoria del Mark II].
4. Precio: 59,99 $ pago único o 19,99 $/año; "buy it outright with a one-time purchase".

**Qué tomar**: enseñar el mecanismo como argumento de valor (nuestro "Process Zero" es "sin grabaciones, sin bucles"); un dial con detentes para la Marea (respiraciones por minuto) y para el corte de timbre; el pago único dicho con orgullo.
**Qué no**: densidad de visor fotográfico; ámbar + negro como *único* rasgo (lo comparten Halide, Dark Noise en uno de sus temas, Hatch y nuestra propia app actual: ver §5).

### 1.11 Moonlitt (Flipping Hues) — ADA 2026 Interaction

**Observaciones [V]**

1. "best-in-class Liquid Glass integration, and easy onboarding" (Apple). Pizzano: "with Liquid Glass everything felt much more alive. It was like the interface was breathing". Mariniello: "the goal was never to make people feel the complexity".
2. Escena 3D de la luna sobre cielo púrpura profundo, mapa con la trayectoria lunar, vista de cámara; el contenido es rico y el vidrio flota encima: exactamente la arquitectura de dos capas que la HIG pide.
3. "We wanted Moonlitt to reflect the elegance and quiet of the moon": el objeto natural dicta la paleta.
4. Pivot de producto a partir de una reseña (eclipses); equipo de tres, Italia; iOS 26+; lifetime 29,99/59,99 $.

**Qué tomar**: la frase "the interface was breathing" es literalmente nuestra Marea; el modelo de dos capas (contenido oscuro y rico, vidrio monocromo encima).
**Qué no**: púrpura profundo del cielo nocturno (ocupado por Moonlitt, Calm, BetterSleep, Sleep Cycle).

### 1.12 Tide Guide (Condor Digital) — ADA 2026 Visuals & Graphics

**Observaciones [V]**

1. "The app's palette is even designed to match the color of the sky throughout the day" (Apple); "aqua-inspired palette".
2. **Una curva con causa física**: "a smooth blue sine wave for daily tides, with a red dot marking the current moment"; gráficos a pantalla completa; arcos de sol y luna; barra de condiciones; tarjetas de 10 días. Progressive disclosure: "Casual users see core tide information, while advanced users can access hour-by-hour".
3. Live Activities "look especially good in the Dynamic Island"; sesión propia en Apple sobre Liquid Glass; SwiftUI; desarrollador único autodidacta ("I'd say my designs were way prettier than the code I wrote").
4. iOS 26+; lifetime 150 $, nivel Ultra con Always-On.

**Qué tomar**: la **curva real con un punto "ahora"** es el modelo exacto de nuestra envolvente y de la Marea (una onda con causa física, no decoración); la paleta que cambia con la hora (en nuestro caso, con la fase de la noche: Descenso → Noche → Madrugada → Despertar).
**Qué no**: aqua/azul marino (es suya y de Tide); densidad de datos.

### 1.13 Apple Reloj (iOS 26) y Salud / Sleep Score (iOS 26 y 26.2)

**Observaciones [V]**

1. **Alarma en pantalla de bloqueo**: "two extra-chunky 'Stop' and 'Snooze' buttons at the bottom of the screen", del mismo tamaño; snooze configurable 1-15 min; críticas por posibles errores al despertar (MacRumors, heise) y por el temporizador que ahora exige "drag a slider from one end of the screen to the other" para parar (Tom's Guide). Lección: **a medio dormir, dos botones iguales confunden; un gesto largo molesta**. Un solo control grande + un gesto secundario discreto.
2. **Liquid Glass en el reloj de bloqueo**: iOS 26.2 añadió un deslizador de intensidad del vidrio para el reloj; la propia Apple reconoce la necesidad de graduarlo.
3. **Sleep Score**: número 0-100 con cinco etiquetas, componentes Duration / Bedtime / Interruptions; en 26.2 la cima pasó de "Excellent" a "Very High" ("a more objective term") y los umbrales subieron. Visualmente, un anillo/número con etiqueta en la app Sueño del Watch y en Salud [E: forma exacta no verificada en fuente Apple]. No existe API (DTS, FB20278031).
4. **Fondo de Salud**: blanco/negro de sistema con secciones de color por categoría (sueño en turquesa/índigo claro) [E].

**Qué tomar**: la lección de los botones de alarma; el tono "more objective term" (Apple corrige adjetivos: nosotros no debemos ponerlos); la decisión de **no puntuar**, que la investigación convierte en posicionamiento ("la app de sueño que no te puntúa").
**Qué no**: anillos de progreso y puntuaciones (territorio Apple y fuente de ortosomnia); turquesa-índigo de Salud.

### 1.14 StandBy nocturno (iOS 17-26)

**Observaciones [V]**

1. "the screen adapts to low ambient light at night, displaying items with a red tint to minimize disturbance while you sleep" (Apple, vía prensa). Se desactiva en Ajustes › StandBy › Pantalla › Modo noche; en iOS 26 algunos usuarios reportan que se reactiva solo.
2. HIG: widgets en StandBy a poca luz se renderizan "with a monochromatic red tint"; la Live Activity pasa a "minimal presentation" y al tocarla escala ×2; "Mark your widget's background as removable".
3. Implicación técnica: **el tinte colapsa el matiz; solo sobrevive la luminancia**. Un acento índigo 109,124,255 (L ≈ 0,25) se ve apagado; un ámbar 235,184,115 (L ≈ 0,53) o un amarillo Braun 255,204,0 (L ≈ 0,64) se ven claros; un rojo 255,66,69 se ve… rojo. El estado debe leerse **por forma** (anillo abierto/cerrado, línea continua/discontinua), nunca por color.
4. Nadie del set diseña para StandBy nocturno (auditoría §6.2): superficie libre.

**Qué tomar**: diseñar primero la versión "rojo monocromo" de cada superficie nocturna y derivar la de color después; luminancias del acento ≥ 0,5.
**Qué no**: depender del acento para decir "sonando".

---

## 2. Objetos

### 2.1 Braun / Dieter Rams: SK4 (1956), ET66 (1987), AB1 (finales de los 80)

**Observaciones [V salvo marca]**

1. **SK4** ("Snow White's coffin", Rams y Gugelot): caja blanca, tapa de acrílico transparente, dos superficies (madera de olmo a los lados), controles alineados en una sola fila; "moved household appliance design away from furniture styling". El mecanismo se ve a través de la tapa: la transparencia como honestidad, treinta años antes que Nothing.
2. **ET66** (Rams y Lubs): cuerpo negro, teclas redondas convexas, un solo color por función (marrón, amarillo "=", verde, rojo); "the buttons are inviting and the number and function keys are high-contrast". La Calculadora de iOS la copió literalmente; el Reloj de iOS 7 copió la gráfica del despertador Braun "down to the font and layout".
3. **AB1** (Lubs): despertador de viaje, esfera negra o blanca de alta legibilidad, **segundero amarillo**: en Braun "the second hand was always yellow and the sound of the alarm was identical for every model" (Cooper Hewitt). Un solo elemento de color, pequeño, en movimiento constante: **es la definición de nuestro acento**.
4. Tipografía Braun: Akzidenz-Grotesk / Helvetica en gris claro sobre negro, mayúsculas pequeñas, tracking abierto [E]. Los principios de Rams que la investigación ya invocó: *honest*, *unobtrusive*, *thorough down to the last detail*, *as little design as possible*.
5. Qué la hace parecer cara: nada es arbitrario; el color es una señal de función; los radios son pequeños y consistentes; el material es mate.

**Qué tomar**: el segundero amarillo como modelo de acento (una sola cosa pequeña, en movimiento, de un color saturado); teclas = objetivos de 44 pt con forma convexa (sombra interior mínima, nunca degradado); color por función (verde = sonando, rojo = parar, amarillo = tiempo) solo si el estado también se lee por forma; esfera negra de alta legibilidad para la pantalla Noche.
**Qué no**: el beige y el pop de los setenta; el skeuomorfismo de botones físicos como decoración.

### 2.2 Teenage Engineering: OP-1 field, TP-7, CM-15

**Observaciones [V]**

1. Kouthoofd: "I set up restrictions when I design." · "I always work with simple geometric shapes." · "If it doesn't look good, it doesn't sound good." · "Ninety-nine percent of people who buy synths don't use them as a productive tool" (los compran por lo que les hacen sentir).
2. **Paleta de cinco**: naranja industrial (#ff6600), negro, blanco, aluminio (#d4d4d4), verde OLED (#00ff66). Negro, no gris oscuro, para contraste. **Monoespaciada en todo**: productos, embalaje, web, documentación.
3. **Retícula brutal**: tablas con separaciones negras finas, cero radio en botones, especificaciones alineadas. Materiales vistos: "raw materials and exposed screws".
4. **OP-1 field**: pantalla OLED de 2,4" y cuatro encoders; cada modo ocupa toda la pantalla y los cuatro parámetros visibles mapean a los cuatro mandos. Restricción = velocidad.
5. **TP-7**: grabadora de aluminio CNC con una **bobina motorizada que gira mientras graba** y se puede arrastrar para hacer scrub: "a triumph of physical skeuomorphism" (Domus). Un solo elemento móvil que es, a la vez, indicador y control. **CM-15**: micrófono de aluminio, una sola superficie, un solo botón.
6. Qué los hace parecer caros: aluminio mate, tolerancias, gráficos serigrafiados minúsculos, y que el objeto hace *una* cosa visible.

**Qué tomar**: "cuatro parámetros = cuatro mandos" (la pantalla principal muestra solo lo que suena); un elemento que es indicador y control a la vez (la onda de la Marea se puede arrastrar para cambiar la frecuencia respiratoria); SF Mono / Menlo para las cifras de instrumento (minutos, respiraciones por minuto, dB estimados) sin empaquetar nada; embalaje/ficha en tono de hoja de especificaciones.
**Qué no**: naranja #ff6600 y verde #00ff66 (son suyos); cero radio en toda la UI (en iOS 26 choca con el vidrio; reservar las esquinas rectas para hairlines y tablas); cualquier parodia de botones físicos.

### 2.3 Bang & Olufsen: Beosound A1 (3.ª gen.) y Beosound Explore

**Observaciones [V]**

1. **A1**: cúpula de aluminio perlado ("pearl-blasted aluminium body"), correa de cuero, polímero en la base; B&O sobre la primera generación: el aluminio debe "feel like aluminum" y el plástico "not… try to hide that it's plastic". Honestidad de material declarada.
2. **Explore**: aluminio anodizado acanalado ("ribbed design"), resistente a arañazos; un objeto para exterior que sigue pareciendo joyería.
3. Interfaz física: botones integrados en la superficie sin etiquetas visibles; la app B&O en gris cálido con fotografía de producto [E].
4. Qué los hace parecer caros: una sola pieza de un solo material, con una textura (perforación, acanalado) que es a la vez función y ornamento.

**Qué tomar**: una sola superficie con una textura funcional (la rejilla de perforación como retícula de la visualización: puntos de luminancia variable); gris aluminio como neutro cálido (nunca gris azulado).
**Qué no**: cuero/premium-lifestyle; fotografía de producto.

### 2.4 Nothing Phone (2): Glyph Interface

**Observaciones [V]**

1. Trasera transparente con 11 tiras / 33 zonas LED que comunican notificaciones, volumen y temporizador con luz blanca; Adam Bates (Dezeen): "as soon as you go transparent you can start to tell a story about the components within the phone". Red Dot 2023.
2. Tipografía dot-matrix (NDot) y monoespaciada en el sistema operativo; blanco/negro/rojo como únicos colores [E: de memoria de Nothing OS].
3. Qué lo hace parecer caro: la coherencia obsesiva entre hardware, luz y tipografía; el "mecanismo visto".

**Qué tomar**: la idea de que **la luz es información** (la Glyph muestra el volumen y la cuenta atrás con segmentos): nuestro medidor de nivel por capa puede ser una fila de segmentos que se apagan con el fundido; el relato "componentes a la vista" aplicado al DSP (espectro, capas).
**Qué no**: dot-matrix (es Nothing); blanco frío; cualquier LED animado como decoración.

### 2.5 Hatch Restore 3 (2025-2026)

**Observaciones [V]**

1. Forma "clean and restrained", ≈18 cm de ancho; colores Putty, Greige y Cocoa: "could pass for a ceramic lamp or a minimalist decor piece".
2. **Cinco controles físicos** (pausa, Unwind Swap, "Big Button", luz de mesilla, alarma on/off): "making it easier to use without grabbing your phone". El reloj es "very subtle and hard to notice at a glance".
3. Noche organizada en tres fases (**unwind, sleep, wake**); amanecer gradual; atardecer "not as gradual as other sunrise alarms"; sin tracking ("doesn't track your sleep", presentado como virtud). 170 $ + Hatch+ 50 $/año.
4. App: tarjetas con degradados cálidos (melocotón, lavanda, ámbar), tipografía redondeada, ilustraciones de contenido [E].

**Qué tomar**: la estructura **unwind / sleep / wake** como arquitectura de la noche (nuestro Descenso / Noche / Despertar); el "Big Button"; la decisión de no puntuar.
**Qué no**: la gama "greige-putty" (es Hatch y la mitad del hogar escandinavo de Instagram); tarjetas con degradado cálido; suscripción de contenido.

### 2.6 Ozlo Sleepbuds

**Observaciones [V]**

1. Herederos de Bose Sleepbuds: silicona blanda con aleta, "sit flush in the ear", estuche cargador compacto. Diseño 9/10 (Gadgets & Wearables).
2. App "clean and usable in a dark room"; fondo negro, texto blanco, un acento verde-azulado, biblioteca en lista [E parcial]; críticas: volumen solo desde la app, función "My Sleep" prometida y retrasada, "work in progress".
3. Autoplay/parada al dormirse como promesa de producto.

**Qué tomar**: "usable in a dark room" como criterio de aceptación literal; la pausa al dormirse (nuestro fundido por quietud / respuesta a la pausa de AirPods en iOS 26).
**Qué no**: prometer funciones de seguimiento antes de tenerlas (la queja central de sus reseñas).

### 2.7 Loop Quiet 2

**Observaciones [V]**

1. Un anillo de silicona en una paleta de colores de moda; web con fotografía de producto, "65000+ 5-star reviews", nombres de línea por contexto (Quiet, Switch, Experience, Engage); 24 dB SNR, 19,95-27,95 $.
2. La marca vende *silencio como accesorio de estilo de vida*; los usuarios compran por el objeto tanto como por la atenuación.

**Qué tomar**: nombrar los perfiles de entorno por situación ("Pareja que ronca", "Calle y vecinos", "Con tapones": el preset "Con tapones" debe citar Loop por nombre en la documentación de calibración).
**Qué no**: paleta de temporada, lenguaje de D2C ("elevate your peace").

### 2.8 Dyson

**Observaciones [V]**

1. Jake Dyson: la OnTrac sigue "Dyson's design language, which has always been about exposing functional elements"; los productos "expose their engineering principles through the way they look". Desde el DC01: formas geométricas industriales, piezas internas a la vista, acentos de color saturado; gris plateado "to emphasise its solid engineering geometry".
2. Tipografía Dyson Futura-like propia, texto de especificación denso, cifras grandes [E].
3. Qué lo hace parecer caro: la ingeniería explicada con números (vatios, dB, horas) y el color como código de gama.

**Qué tomar**: el número como prueba (horas de batería medidas, MB de la app, segundos hasta que suena, años sin repetir un segundo de audio) en la ficha y en "Qué sabemos y qué no".
**Qué no**: acentos saturados múltiples (níquel/morado/cobre), densidad de catálogo.

### 2.9 Leica M (M11, M11-P, M11-D)

**Observaciones [V]**

1. "a minimalist design with direct access to ISO, shutter speed, and aperture"; placa superior con "just a shutter speed dial and a pull-up ISO dial"; M11 eliminó la placa inferior; M11-P y M11-D con placa de aluminio negro y la inscripción "Leica" grabada en lugar del punto rojo [E para el punto rojo, V para la placa]; el M11-D no tiene pantalla trasera.
2. Marketing propio: "by means of pure understatement, directing focus to the essential"; "a focus on the essential".
3. Qué la hace parecer cara: menos controles de los que el usuario cree necesitar; un material; quitar el logotipo como gesto de confianza.

**Qué tomar**: quitar cosas como lujo (el modo Noche sin reloj si el usuario quiere; la pantalla principal sin nombre de la app); grabado en lugar de etiqueta (el nombre de la mezcla como texto discreto, no como título).
**Qué no**: el fetiche del objeto; la nostalgia.

### 2.10 Aesop

**Observaciones [V parcial]**

1. Botellas ámbar iguales con etiqueta blanca o crema y texto negro en una grotesca neutra; "apothecary-like or laboratory-inspired"; L'Oréal señala el ámbar como "a key characteristic underpinning the brand's distinctive global identity". Tipografías citadas con discrepancia: logotipo tipo Optima (flared sans), Helvetica Neue en etiquetas, Suisse Int'l en web.
2. "Anti marketing": sin publicidad; tiendas distintas en cada ciudad; texto largo y sereno ("The typography declines to persuade you. It presents the product as though its merits are self-evident").
3. **Web diseñada por Work & Co** (Nueva York): "to carry the 'unselling' ethos online"; premios HOW International y Fast Company "Best Website Design".

**Qué tomar**: el copy que no persuade (ficha en tono de prospecto: qué contiene, cómo se usa, qué no hace); una etiqueta igual para todas las texturas (mismo tipo, mismo tamaño, cambia solo el nombre); Optima como candidata de "voz" para el nombre del producto si algún día hay logotipo tipográfico (está en iOS).
**Qué no**: el ámbar como color de superficie (en pantalla deriva a "sepia/retro"); el tono de boutique.

### 2.11 Muji

**Observaciones [V]**

1. Kenya Hara: "emptiness" como "creative receptacle", distinta de minimalismo; "the specific design quality that allows the user to discover their own unique way of using the object"; "a treatise against over-engineered objects". Sin logotipo en casi ningún producto; publicidad mínima.
2. Tipografía Helvetica Neue en señalética; materiales crudos (cartón, aluminio, algodón sin teñir) [V parcial].
3. Qué lo hace parecer caro (aunque no lo sea): la ausencia de marca como marca.

**Qué tomar**: la pantalla principal como receptáculo (la mezcla del usuario es el contenido; la app desaparece); sin logotipo en la UI; nombre del producto solo en la ficha y el paywall.
**Qué no**: beige/kraft como paleta (en pantalla de noche no tiene sentido).

---

## 3. Estudios

### 3.1 Pentagram (Nueva York)

**Observaciones [V]**

1. Salud y bienestar recientes: **Evernow** (menopausia; identidad de línea continua que "extends to the website and app", flechas que guían), **Phenology** (negro/blanco/beige con neón), **Lenus** (rebrand completo con tono de voz y UX/UI), **Abridge** (el nombre convertido en "a system of waveforms"), **Rugiet** (naranja vivo "that breaks from the pastel palette typical of the wellness category").
2. Método Pentagram: una idea gráfica (una línea, una forma de onda) que sirve de sistema entero; tipografía como protagonista; paletas de dos colores más uno.
3. Lección: dos de cinco proyectos de bienestar de Pentagram se definen **contra el pastel**. El estudio ya sabe que el pastel es el cliché de la categoría.

**Qué tomar**: una sola idea gráfica derivada del producto (la envolvente del DSP como línea que recorre ficha, icono, Live Activity y web); romper el pastel.
**Qué no**: identidad que viva en el marketing y no en la app.

### 3.2 Work & Co (Brooklyn, hoy Accenture Song)

**Observaciones [V]**

1. Aesop e-commerce ("Best Website Design", Fast Company; HOW International): "the goal was to make the site a true extension of the Aesop brand in-person" (Dever Thomas). Apple: "Today at Apple" (experiencias digitales de flagship). Otros clientes: Aldo, IKEA, Gatorade, Equinox+.
2. Método: equipos integrados de diseño e ingeniería que entregan producto, no mockups; prototipos en código desde la primera semana.
3. Lección: lo que vende es la **continuidad entre objeto y pantalla**; para nosotros, continuidad entre el sonido, la UI, la ficha y la Live Activity.

**Qué tomar**: prototipar en SwiftUI, no en Figma; una regla de retícula única del tamaño de la pantalla al widget.
**Qué no**: nada; es método, no estilo.

### 3.3 Smart Design (Nueva York)

**Observaciones [V]**

1. OXO Good Grips (1989-1990) en el MoMA como ejemplo de diseño universal: el mango de goma con aletas nació para manos con artritis y resultó mejor para todos; "a sizable gap in the housewares market".
2. Proyectos recientes OXO (organizadores, "Cookie Suite") con Good Design Awards 2022.
3. Lección: diseñar para el caso extremo (una mano, a oscuras, medio dormido, con acúfenos) produce el producto mejor para todos.

**Qué tomar**: el "mango con aletas" de SleepNoise son los **objetivos de 44-64 pt, el gesto vertical con una mano y el estado por forma**; probar con los ojos cerrados.
**Qué no**: nada.

### 3.4 frog (Nueva York / Norteamérica)

**Observaciones [V]**

1. Dispositivos de salud: identifeye (cámara retiniana automática; diseño de experiencia, industrial y digital), Lumen (metabolismo; "guided Lumen's design to ensure that it was a premium luxury product"), MeMed Key (Red Dot), Yona (espéculo; San Francisco).
2. Método frog: investigación + modelo de apariencia + guías de producción; el hardware médico que no parece médico.
3. Lección: lo "premium" en salud se construye con materiales mate, pocas superficies y lenguaje no clínico; exactamente lo que App Review (1.4.1) también premia.

**Qué tomar**: lenguaje de producto, no clínico; "modelo de apariencia" = una pantalla hero perfecta antes que diez correctas.
**Qué no**: estética de dispositivo médico (blancos, azules, iconos de corazón).

### 3.5 COLLINS (Nueva York / San Francisco)

**Observaciones [V]**

1. Muse Group (2025): "re-architected the brand across its products, aligning everything under a single design language"; propósito "Inspire the artist. Unleash their sound."; sistema basado en "Suprematism, musical notation and the language of sonic vibration".
2. Método COLLINS: un propósito en una frase, un sistema gráfico que se deriva de la física del producto (vibración), tipografía expresiva.
3. Lección: **la vibración sonora ya es un sistema gráfico de alguien en software musical**; nosotros debemos derivar la gráfica de la *envolvente temporal* y de la *respiración*, no del espectro de audio clásico (barras, osciloscopio).

**Qué tomar**: el propósito en una frase antes del moodboard ("Sonido que nace en tu iPhone y nunca se repite").
**Qué no**: barras de ecualizador, formas de onda de osciloscopio, notación musical.

### 3.6 Instrument (Portland / Nueva York)

**Observaciones [V]**

1. **Ōura app** (2025-2026): "a more intuitive app for members reading daily signals and long-term trends"; Webby 2026 (Health, Best Visual Design, Best UI); dejó la "card-style layout"; tres pestañas (Today, Vitals, My Health). Premios Fast Company Innovation by Design 2026 según trade press [no visto en la página de Instrument].
2. Ōura es la referencia de **lujo discreto en salud**: negro, tipografía serif/sans combinada, cifras grandes, anillos de puntuación, degradados sutiles azul-noche [E: de memoria de la app].
3. Lección: Ōura ya es dueño de "anillo + puntuación + azul noche + serif" en salud premium.

**Qué tomar**: abandonar las tarjetas como Ōura acaba de hacer; cifras grandes como contenido.
**Qué no**: anillos, puntuaciones, serif elegante + azul noche (es Ōura; además nosotros no puntuamos).

---

## 4. Tabla resumen: qué toma SleepNoise de cada referencia

| Referencia | Un rasgo que tomamos | Un rasgo que dejamos |
|---|---|---|
| Bear | papel/tinta/un rojo; hairlines; cero onboarding | blanco de día; 28 temas |
| Things 3 | color = significado; un control con física | alegría diurna |
| Dark Noise | disciplina de plataforma; hápticos | iconos animados; 430 MB |
| Endel | el visual es el sonido | líneas blancas sci-fi; "7x" |
| Portal | dominar la mesilla (luces, AirPlay) | vídeo de fondo |
| Balance | Wind Down como vara de medir | pastel |
| Tide | cuenta atrás protagonista | foto + cita del día |
| Gentler Streak | "No accounts. No servers."; tono sin culpa | personajes |
| Flighty | analogía con una señalética; una línea por capa | densidad |
| Halide | enseñar el mecanismo; dial con detentes | visor denso |
| Moonlitt | "the interface was breathing"; dos capas | púrpura |
| Tide Guide | curva real con punto "ahora"; paleta por fase | aqua |
| Reloj/Salud 26 | un botón grande; no puntuar | anillos |
| StandBy | diseñar en rojo monocromo primero | acento por color |
| Braun | segundero amarillo; teclas convexas | pop setentero |
| Teenage Engineering | 4 parámetros = 4 mandos; indicador = control; mono | naranja/verde TE |
| B&O | textura funcional como retícula | cuero |
| Nothing | luz = información | dot-matrix |
| Hatch | unwind/sleep/wake; Big Button | greige |
| Ozlo | "usable in a dark room" | prometer tracking |
| Loop | perfiles por situación | paleta de temporada |
| Dyson | el número como prueba | acentos múltiples |
| Leica | quitar como lujo | nostalgia |
| Aesop | copy que no persuade; etiqueta única | ámbar de superficie |
| Muji | receptáculo; sin logotipo en UI | kraft |
| Pentagram | una idea gráfica derivada del producto | identidad solo de marketing |
| Work & Co | prototipo en código | — |
| Smart Design | diseñar para el caso extremo | — |
| frog | no clínico | blanco médico |
| COLLINS | propósito en una frase | onda de osciloscopio |
| Instrument | sin tarjetas; cifras grandes | anillo + score |

---

## 5. a) Mapa de códigos ocupados en la categoría sueño

Lo que ya es de alguien y, por tanto, no puede ser nuestro rasgo principal (puede aparecer como detalle, nunca como firma).

### 5.1 Color

| Código | Dueño(s) | Evidencia |
|---|---|---|
| **Púrpura / índigo / azul noche con degradado** | Calm (dusk violet, deep pool), BetterSleep, Sleep Cycle ("dreamy gradients", rebrand 15-05-2025), Moonlitt (cielo púrpura), Headspace Sleep, Ōura | Buck "Calm Sleep Visual System"; nota de prensa Sleep Cycle; ADA 2026; artículo de tendencias (dic. 2025) que llama a "blues and purples" el cliché de la categoría |
| **Aqua / azul marino que cambia con el cielo** | Tide Guide, Tide | Apple ADA 2026 |
| **Blanco fino sobre negro con puntos** | Endel | Readymag (Temen) |
| **Ámbar/melocotón cálido con degradado de amanecer** | Hatch (Putty/Greige/Cocoa + luz), Calm Sleep (ethereal lighting), Gentler Streak (crema/naranja) | Yanko; Buck; ficha |
| **Pastel lavanda/menta/durazno en tarjetas** | Balance, Headspace, Breathwrk de noche ("muted colors prepare you for a restful night") | fichas y reseñas |
| **Naranja industrial + verde OLED + mono** | Teenage Engineering | guía TE |
| **Greige / cerámica** | Hatch, estética escandinava de mesilla | Yanko |
| **True Black como tema de pago** | Dark Noise | ficha |

**Lo que queda libre en color**: negro OLED real como *superficie única y gratuita* (nadie lo da por defecto a todos); **grafito cálido** (28,28,30 → 36,36,38) como único relieve; un acento que no sea púrpura, aqua, pastel, naranja TE ni greige. Candidatos con luminancia suficiente para StandBy: **amarillo Lubs** (≈ 255,204,0; 13,9:1 sobre negro), **ámbar de instrumento** (el actual 235,184,115, 11,6:1; libre si se usa *pequeño*, no en superficies), **rojo de cámara oscura** (255,66,69; 6,1:1; sobrevive al tinte de StandBy; riesgo semántico). El teal 0,210,224 (11,2:1) está técnicamente libre pero roza Tide/Tide Guide/Ōura.

### 5.2 Ilustración e imagen

- **Fotografía/vídeo de naturaleza** a pantalla completa: Portal, Tide, Calm, BetterSleep.
- **Personajes ilustrados** redondeados: Headspace, Calm Sleep (Buck: "characters alive in action"), Gentler Streak.
- **Iconos de línea animados por sonido**: Dark Noise.
- **Luna, estrellas, nubes, ovejas, "zzz"**: icono de media categoría (incluido el chip "Deep sleep" del PR #3).
- **Escena 3D del cielo**: Moonlitt.
- **Anillo de puntuación**: Apple Sleep Score, Ōura, Sleep Cycle, Rise.
- **Barras de ecualizador / osciloscopio**: myNoise (10 sliders por banda), Endel (líneas), software musical (COLLINS/Muse).

**Libre**: la **envolvente temporal real** de la síntesis (amplitud por capa en el tiempo, no espectro) dibujada como una línea de horizonte; la **forma que respira** como *marea* (línea que sube y baja), no como círculo que crece (Apple Breathe, Balance, Breathwrk ya tienen el círculo).

### 5.3 Tipografía

- **Redondeada (SF Rounded, Nunito, Quicksand, Poppins)**: Headspace, Calm, Hatch, Balance, BetterSleep; también el PR #3. Es *el* código tipográfico de bienestar.
- **Grotesca neutra con tracking amplio en mayúsculas**: Endel, Sleep Cycle (Innovator Grotesk).
- **Serif elegante + sans**: Ōura, Rise, apps de "longevity".
- **Monoespaciada total**: Teenage Engineering; dot-matrix: Nothing.
- **Geométrica humanista (Avenir/Bear Sans)**: Bear; nadie en sueño.

**Libre en sueño**: la pareja **SF Pro (texto) + SF Mono / Menlo (cifras de instrumento)**, o **Avenir Next Medium/Demi (texto) + cifras tabulares de SF**. New York (serif) está libre en sueño pero ocupada por Ōura/Rise en salud premium: descartada salvo para una sola palabra de marca.

### 5.4 Copy y tono

- **Místico/afirmativo** ("sleep better", "wake up refreshed", "91% of our listeners"): BetterSleep, Calm, Aura.
- **Científico con multiplicadores** ("7x focus"): Endel, Brain.fm.
- **Risueño con personajes**: Headspace.
- **Cinematográfico** ("Fall asleep in the mountains"): Portal.
- **Quiet praise / indie honesto** ("White noise, refined", "Independent since 2019"): Dark Noise; "No user accounts. No servers.": Gentler Streak; "Zero AI": Halide.

**Libre**: el tono de **hoja de especificaciones serena** (Braun/Aesop/TE): qué hace, con qué números, qué no hace, cuánto cuesta. Nadie en sueño habla así.

### 5.5 Interacción y superficies

- Live Activity con control único: Dark Noise la tiene; nadie la diseña para StandBy nocturno.
- Rejilla de iconos de sonidos: BetterSleep, Noisli, Rain Rain, el PR #3.
- Sliders verticales por banda: myNoise.
- Círculo que respira: Apple Breathe, Balance, Breathwrk, Calm.
- Pantalla negra con reloj grande: Hatch (sutil), Portal (reloj bonito), Noche del PR #3.
- Dial con detentes: Halide.

**Libre**: mezclador de **líneas horizontales con peso** (cada capa una línea cuya altura/grosor es su nivel, que se arrastra con un dedo), la **marea** como forma respiratoria, el **medidor segmentado** que se apaga con el fundido, y **StandBy en rojo** como pantalla de mesilla diseñada.

---

## 6. b) El territorio libre: "el instrumento de sueño"

### 6.1 La tesis visual en cinco reglas

1. **Negro OLED como silencio.** Fondo 0,0,0 siempre; el único relieve es un grafito cálido (28,28,30 base; 36,36,38 elevado), y solo en hojas. Nada de degradados de fondo ni resplandores.
2. **Una línea que significa algo.** La única cosa en movimiento es la envolvente real de la síntesis (y, en Marea, la línea que sube y baja con la respiración). Se congela bajo `isLuminanceReduced` y Reduce Motion, se disuelve en ≤ 2 s al parar.
3. **Un acento, pequeño y en movimiento** (el segundero de Lubs). Nunca rellena un botón; marca el "ahora", el valor activo y el control primario. Luminancia ≥ 0,5 para StandBy. El estado se lee por forma antes que por color.
4. **Dos familias, ambas del sistema**: una de texto (SF Pro o Avenir Next) y una de cifras de instrumento (SF Mono / Menlo tabular). Peso ≥ Medium en todo lo que se lea a oscuras; nada por debajo de 13 pt.
5. **Hairlines y aire en lugar de cajas.** Separadores de 0,5 pt al 12-18 % de blanco; márgenes de 20 pt; objetivos de 44-64 pt sin bezel visible (24 pt de aire). Liquid Glass regular, monocromo, solo en la barra; la línea de sonido vive debajo para que el vidrio la refracte.

### 6.2 Tres moodboards (descritos en palabras)

Los tres comparten las cinco reglas; difieren en temperatura, acento y voz tipográfica. Recomendación del estudio al final.

#### Moodboard A · "Dial de instrumento" (Braun · Leica · Halide · Teenage Engineering)

- **Idea**: un aparato de medida de mesilla. Esfera negra, escala fina, una aguja de color.
- **Paleta**: negro 0,0,0; grafito 28,28,30 / 36,36,38; texto papel 236,232,222 (actual `text`, 16:1); secundario 158,158,163 (≈ 7:1); **acento amarillo Lubs 255,204,0** (13,9:1), usado en: el punto "ahora" de la envolvente, el valor numérico activo, el borde del control primario (anillo de 1,5 pt, no relleno). Variante de contraste aumentado: 255,214,10. Bajo tinte rojo de StandBy se lee como el elemento más claro de la pantalla.
- **Tipografía**: SF Pro Text Medium 17/22 para etiquetas; SF Pro Display Regular 34 para títulos (solo en hojas); **SF Mono Medium tabular** para toda cifra (nivel de capa 0-100, minutos restantes, respiraciones/min, "≈ 46 dB en la almohada"). Mayúsculas pequeñas con tracking +6 % para unidades (MIN, RPM, DB) [tracking exacto a validar en dispositivo].
- **Retícula**: columna única de 353 pt (393 − 2×20); filas del mezclador de 64 pt (44 de objetivo + 20 de aire); escala de ticks de 1 pt cada 10 unidades bajo cada línea de capa, como un vúmetro analógico quieto.
- **Movimiento**: solo la envolvente (línea de 1,5 pt que recorre la pantalla de izquierda a derecha a la velocidad real del DSP, 30 fps máximo) y el punto amarillo que la sigue. Hápticos `.selection` en detentes de 5 unidades y `.light` al entrar en Marea.
- **Iconografía**: cero iconos en la pantalla principal; nombres de capa en texto. SF Symbols monocromos de peso Medium solo en la barra (timer, square.stack, moon). Un glifo propio: la marea (dos arcos asimétricos, inhalación corta / exhalación larga) dibujado en Core Graphics, 1,5 pt de trazo.
- **Material de referencia**: AB1 (segundero), ET66 (teclas convexas → sombra interior de 1 pt en el control primario, nada más), M11-D (sin pantalla trasera → modo Noche sin reloj como opción), OP-1 (cuatro parámetros visibles), TP-7 (bobina = indicador y control → la línea de Marea se puede arrastrar).
- **Copy**: hoja de especificaciones. "Rosa · 65", "Marea · 6 rpm · 15 min", "Se funde a las 00:42".
- **Riesgo**: puede derivar a "gadget técnico" y asustar al segmento 2 (rumiación nocturna) si las cifras dominan. Mitigación: las cifras aparecen solo al tocar.

#### Moodboard B · "Marea" (Tide Guide · Moonlitt · Smart Design · B&O)

- **Idea**: una línea de horizonte en una habitación a oscuras. La respiración como oleaje, no como círculo.
- **Paleta**: negro 0,0,0; grafito cálido; texto papel; **acento ámbar de instrumento 235,184,115** (el actual, 11,6:1; mantiene continuidad con la app y el icono), pero reducido a una línea de 1,5 pt y a un punto; superficies nunca. Secundario gris aluminio 174,174,178 (≈ 9:1). Variante de contraste aumentado: 242,196,130. La paleta **no cambia de color por fase, cambia de luminancia**: Descenso (acento al 100 %), Noche (acento al 60 %, texto al 70 %), Madrugada (acento al 40 %, sin texto), Despertar (acento sube de nuevo durante 15-30 min: el "amanecer" es luminancia, no naranja).
- **Tipografía**: **Avenir Next Medium / Demi Bold** para texto (la Bear original; geométrica humanista; instalada en iOS; x-height baja → usar 18 pt mínimo en cuerpo y no bajar de Medium), cifras en SF Pro con `monospacedDigit()` (Avenir Next no tiene tabulares fiables). Si Dynamic Type con Avenir Next da problemas en AX3-AX5 (hay que medirlo con `UIFontMetrics`), caer a SF Pro con tracking −1 %.
- **Retícula**: la pantalla principal es **una sola línea de horizonte** a un tercio de la altura (≈ 280 pt desde arriba en un 393×852), con la envolvente de cada capa superpuesta como capas de oleaje de distinto grosor (0,75 / 1 / 1,5 pt) y la Marea como la ola más lenta y gruesa; debajo, las capas como filas de texto con un valor; arriba, nada (el aire es el lujo). Las hojas (temporizador, mezclas, Pro) usan hairlines y 20 pt de margen.
- **Movimiento**: la ola de Marea sube 4 s y baja 6 s (4:6) a 6 rpm; las demás capas se mueven a su envolvente real; al activar Reduce Motion la ola se sustituye por una línea cuya opacidad respira; en Always-On/StandBy la línea queda quieta en marea baja.
- **Iconografía**: ninguna en la pantalla principal; el glifo de marea solo en Live Activity, widget y Centro de control (donde la HIG exige símbolo).
- **Material de referencia**: la sinusoide de Tide Guide con el punto rojo "ahora" (sustituido por el punto ámbar), "the interface was breathing" de Moonlitt, la rejilla perforada del A1 como textura de fondo de la Live Activity (puntos de 1 pt al 6 %), OXO Good Grips como criterio (una mano, a ciegas).
- **Copy**: sereno y físico. "La ola sube: inhala. Baja: exhala. No hace falta mirar." (ya existe), "Se retira sola a los 15 minutos", "Nada se repite."
- **Riesgo**: el ámbar es el color más compartido con Halide/Hatch/Calm cálido; se defiende solo si es línea y punto, nunca superficie ni botón relleno.

#### Moodboard C · "Red Graphite nocturno" (Bear · Nothing · Pentagram · Muji)

- **Idea**: el tema que los usuarios de Bear piden desde 2024 y que nadie ha hecho: papel negro, tinta clara, un rojo grafito. Un cuaderno de noche más que un aparato.
- **Paleta**: negro 0,0,0; **sin grafito**: las hojas también son negras y se separan por hairline; texto papel cálido 236,232,222; secundario 142,142,147 (6,4:1); **acento rojo grafito 221,71,69** (≈ 5,5:1 sobre negro: válido para texto ≥ 18 pt o Medium ≥ 14 pt, iconos y líneas; **no** para cuerpo de texto). Variante de contraste aumentado 255,97,101 (HIG Red accesible oscuro, ≈ 7:1). Es el único acento del set que **sobrevive intacto al tinte rojo de StandBy** y al modo de cámara oscura de astrónomos y submarinistas; también es el color que iOS reserva para destructivo, así que **nunca se usa en "Borrar" ni en errores** (que pasan a texto gris con hairline).
- **Tipografía**: SF Pro (o Avenir Next si B gana la voz) para todo el texto; cifras tabulares de SF; **New York Medium solo en una palabra**: el nombre de la mezcla guardada (como la etiqueta manuscrita de un bote), a 22 pt. Nada más en serif.
- **Retícula**: lista pura al estilo Bear: filas de 56 pt separadas por hairline de 0,5 pt al 14 %, sin tarjetas, texto a la izquierda, valor a la derecha, slider invisible hasta que se toca (la fila entera es el control: arrastre horizontal cambia el nivel, como el scrub de la TP-7). Márgenes de 20 pt; títulos de hoja a 28 pt Regular.
- **Movimiento**: la envolvente es una línea roja de 1 pt bajo la fila activa; nada más se mueve. Al tocar una fila, Liquid Glass "transient" solo en ese slider (la excepción que la HIG permite).
- **Iconografía**: SF Symbols de línea, peso Regular, 20 pt, solo en la barra; un icono de app de "glifo" rojo sobre negro (una línea de marea) a lo Nothing.
- **Material de referencia**: Red Graphite de Bear invertido, el hilo OLED del foro de Bear, la Glyph como "luz = información" (el nivel por capa como segmentos rojos que se apagan con el fundido en la Live Activity), Evernow de Pentagram (una línea que recorre todo), Muji (sin logotipo en la UI).
- **Copy**: el de Bear: corto, en plural, confiado. "Sin cuentas. Sin red. Un solo pago." "Tus mezclas te esperan."
- **Riesgo**: rojo = alerta en iOS; algunos usuarios lo leerán como error. Mitigación: saturación baja (221,71,69, no 255,59,48), trazo fino, nunca relleno; test de cinco segundos con usuarios ("¿qué pasa en esta pantalla?").

### 6.3 Recomendación del estudio

**Base B ("Marea") con la disciplina de A.** Razones: (1) B es la única de las tres cuya forma visual nace de la función diferencial del producto (la Marea) y de la prueba "nunca se repite" (la envolvente), lo que es la definición de *honest* en Rams y lo que Apple premió en Tide Guide y Moonlitt; (2) conserva el ámbar del icono y de la app actual (continuidad para usuarios y para la ficha) pero lo disciplina a línea y punto; (3) A aporta la tipografía de cifras (SF Mono) y la regla "cuatro parámetros visibles" que evitan que B derive a wellness. **C se guarda como tema alternativo gratuito** ("Grafito rojo") para el segmento 3, que coleccionará temas como en Bear y Dark Noise, y como prueba de StandBy: si una pantalla funciona en C, funciona en rojo nocturno.

Decisiones que este documento deja abiertas al plan de funciones y a la especificación de diseño (02): la voz tipográfica (SF Pro vs Avenir Next: prototipo de una semana con Dynamic Type AX5 y VoiceOver en ambas), el valor final del acento (ámbar actual vs amarillo Lubs: medir en StandBy real y en iPhone SE), y si el relanzamiento high-end es iOS 26+ con rama 17 (afecta a si la barra es vidrio o `.bar`).

---

## 7. c) Clichés a evitar (lista cerrada para la especificación)

1. Luna creciente, estrellas, nubes, ovejas, "zzz", cama, almohada, ojo cerrado: ni en icono, ni en chips, ni en estados vacíos.
2. Degradado púrpura → azul noche (y cualquier degradado de fondo).
3. Pastel lavanda/menta/durazno; tarjetas con degradado cálido.
4. Fotografía o vídeo de naturaleza como fondo; cita inspiracional del día.
5. Personajes ilustrados, mascotas, confeti, celebraciones, rachas.
6. Tipografía redondeada en todo (SF Rounded como voz; Nunito/Quicksand/Poppins empaquetadas).
7. Anillos de progreso y puntuaciones de sueño; adjetivos de calidad ("Excelente", "Óptimo").
8. Círculo que crece y encoge como guía respiratoria (Apple Breathe, Balance, Breathwrk).
9. Barras de ecualizador, osciloscopio, "visualizador" tipo reproductor de música; notación musical.
10. Rejilla de baldosas de iconos de sonidos; candados a la vista; chips de presets con emoji.
11. Resplandor animado, partículas, blur decorativo, Liquid Glass en tarjetas, sliders en reposo o fondos.
12. Acento repartido en más de un control por pantalla; botón primario relleno de 100+ pt.
13. Grises azulados como "oscuro"; fondos distintos de 0,0,0 en cualquier superficie nocturna.
14. Copy místico ("sueño profundo", "despierta renovado", "sana", "cura", "insomnio", "clínicamente"), multiplicadores ("3,6x"), porcentajes de encuesta propia, cuenta atrás de oferta, "oferta vitalicia".
15. Onboarding de pantallas, permisos al arranque, pedir valoración de noche.
16. Pesos Light/Thin/Ultralight (incluido el reloj de 44 pt light actual) y texto < 13 pt en cualquier cosa que se lea a oscuras.
17. Iconos animados por sonido (Dark Noise), líneas blancas finas con puntos sci-fi (Endel), dot-matrix (Nothing), naranja/verde (Teenage Engineering), greige (Hatch), aqua por hora del día (Tide Guide), serif + anillo (Ōura): rasgos de otros que un estudio no imita.
18. Dos botones iguales para la acción crítica (Stop/Snooze de iOS 26) o un gesto largo obligatorio para parar.
19. Emoji en copy o en nombres de mezcla por defecto.
20. Español traducido ("Niveles" para un mezclador, "Activado/Apagado" mezclados, "vitalicio"): el copy es-ES/es-419 se escribe, no se traduce.

---

## 8. Lo que este documento no pudo verificar y lo que el estudio debe capturar

- Sin acceso a Mobbin/screensdesign ni a dispositivo con las apps: las descripciones de pantallas de Endel, Balance, Hatch (app), Ozlo (app), Ōura, Halide Mark III y Flighty llevan [E] donde corresponde. **Capturar en iPhone real** (prioridad): Dark Noise 3.6 Now Playing y su widget en StandBy nocturno; Endel modo Sleep; Balance Wind Down con auriculares; Tide Guide y Moonlitt con Liquid Glass sobre contenido oscuro; Bear 3 tema AMOLED y Red Graphite; Halide Mark III dial; Reloj iOS 26 alarma y temporizador en pantalla de bloqueo; Salud Sleep Score; Ōura pantalla Today.
- Tipografías exactas de Flighty, Gentler Streak, Hatch, Ozlo: no verificadas; no condicionan ninguna decisión (ninguna es candidata).
- Braun AB1: atribución a Lubs y "finales de los 80" por catálogos de reedición; sin ficha de museo del modelo exacto.
- Avenir Next en Dynamic Type: hay que medir la escala AX3-AX5 y el espaciado de líneas en SwiftUI antes de elegirla como voz.
- Contrastes calculados sobre negro puro; sobre grafito 28,28,30 bajan ≈ 10 %. Validar con el inspector de accesibilidad de Xcode.
- El inventario definitivo de pantallas (y por tanto qué moodboard se aplica a qué superficie: Live Activity, widget, Watch, Centro de control) llegará de `FUNCIONES-PRIORIZADAS-2026-11-16.md`.

---

## 9. d) Fuentes

Leídas o consultadas el 16-11-2026 salvo indicación.

**Apple**
- HIG Materials / Liquid Glass: https://developer.apple.com/design/human-interface-guidelines/materials · Dark Mode: https://developer.apple.com/design/human-interface-guidelines/dark-mode · Live Activities (Night Mode, tinte rojo): https://developer.apple.com/design/human-interface-guidelines/live-activities · Typography: https://developer.apple.com/design/human-interface-guidelines/typography · Color: https://developer.apple.com/design/human-interface-guidelines/color · Accessibility: https://developer.apple.com/design/human-interface-guidelines/accessibility · Always-On: https://developer.apple.com/design/human-interface-guidelines/always-on · Widgets: https://developer.apple.com/design/human-interface-guidelines/widgets · Adopting Liquid Glass: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
- Apple Design Awards 2026 (ganadores): https://www.apple.com/newsroom/2026/06/apple-reveals-winners-of-the-2026-apple-design-awards/ · Developer News, Moonlitt: https://developer.apple.com/news/?id=v1nphz91 · Developer News, Tide Guide: https://developer.apple.com/news/?id=4r9b23wx · Historia App Store ADA 2026: https://apps.apple.com/us/iphone/story/id1896567319 · Sesión "Meet with Apple" de Tide Guide sobre Liquid Glass: https://developer.apple.com/videos/play/meet-with-apple/257/
- Behind the Design: Flighty (2023, espejo): https://cur.at/VcCahLU?m=web
- StandBy tinte rojo: https://www.macrumors.com/how-to/disable-red-tint-ios-standby-mode · https://www.macrumors.com/how-to/use-standby-mode-iphone/
- Reloj iOS 26 (alarma Stop/Snooze): https://www.macrumors.com/2025/06/24/new-alarm-design-ios-26-make-you-oversleep/ · https://www.macstories.net/stories/ios-and-ipados-26-the-macstories-review/14 · Temporizador: https://www.tomsguide.com/phones/iphones/i-use-timers-on-my-iphone-all-the-time-but-ios-26-has-made-things-worse · heise: https://heise.de/-10460457 · Liquid Glass del reloj en 26.2: https://www.phonearena.com/news/ios-26.2-dev-beta-lands-with-big-tweaks-to-liquid-glass-health-and-podcasts-heres-whats-new_id175479
- Sleep Score: https://9to5mac.com/2025/11/10/ios-26-2s-new-sleep-score-grades-already-feel-like-an-upgrade · https://www.macrumors.com/2025/09/15/apple-releases-watchos-26 · https://www.apple.com/newsroom/2025/09/new-versions-of-apples-software-platforms-are-available-today/

**Apps**
- Bear: temas gratuitos https://bear.app/faq/about-free-and-pro-themes-in-bear/ · hilo "OLED friendly Red Graphite theme" https://community.bear.app/t/oled-friendly-red-graphite-theme/14118 · Bear Sans (ago. 2023) https://blog.bear.app/2023/08/learn-about-our-new-custom-font-bear-sans/ · Bear 3 y BearSansUI (Rands) https://randsinrepose.com/?p=4893 · MacStories sobre Bear https://www.macstories.net/stories/why-im-considering-bear-as-a-notes-app-replacement/ · décimo aniversario https://blog.bear.app/2026/11/bear-turns-10-and-it-still-feels-like-day-one/ · guía de diseño https://blakecrosley.com/guides/design/bear
- Things 3: "Things for OS 26" https://culturedcode.com/things/blog/2025/09/things-for-os-26/ · MacStories https://www.macstories.net/reviews/things-3-beauty-and-delight-in-a-task-manager/ · análisis de color https://blakecrosley.com/blog/design-study-things
- Dark Noise: MacStories https://www.macstories.net/reviews/dark-noise-review-ambient-noise-never-looked-so-good/ · releases https://darknoise.app/releases · ficha https://apps.apple.com/us/app/dark-noise/id1465439395
- Endel: Readymag (Protey Temen) https://blog.readymag.com/tune-in-drop-out-how-endel-helps-get-into-the-flow-via-immersive-soundscapes-5ab08d932687/ · screensdesign https://screensdesign.com/showcase/endel-focus-sleep-sounds · crítica Pratt (feb. 2026) https://ixd.prattsi.org/2026/02/design-critique-endel-ios-app/ · Best of 2020 https://apps.apple.com/story/id1535416234
- Portal: ficha https://apps.apple.com/us/app/portal-escape-into-nature/id1436994560 · review https://www.igeeksblog.com/portal-immersive-escapes-ios-app-review/
- Balance: https://themindcompany.com/apps/balance · review https://www.choosingtherapy.com/balance-meditation-app-review/ · ficha https://apps.apple.com/app/1361356590
- Tide: ficha https://apps.apple.com/us/app/-/id1077776989 · https://tide.fm/en_US/
- Gentler Streak: Sketch case study https://sketch.com/blog/gentler-streak · ADA https://docs.gentler.app/release-notes-and-announcements/gentler-streak-wins-an-apple-design-award-for-social-impact · https://gentlerstories.com/gentlerstreak/
- Flighty: https://blakecrosley.com/guides/design/flighty · https://thesweetsetup.com/flightys-beautiful-design-fast-push-notifications-make-it-one-of-the-best-flight-tracking-apps-on-the-app-store/ · https://flighty.com/about
- Halide Mark III: https://lux.camera/halide-mark-iii/ · PetaPixel (27-05-2026) https://petapixel.com/2026/05/27/halide-mark-iii-promises-most-beautiful-photos-possible-on-iphone/ · Process Zero https://www.macstories.net/news/manual-camera-app-halide-introduces-process-zero-a-new-unprocessed-image-capture-mode/ · Engadget https://engadget.com/2182499/halide-mark-iii-adds-a-built-in-editor-to-the-popular-camera-app
- Moonlitt: ficha https://apps.apple.com/us/app/moonlitt-moon-phase-tracker/id6444718902 · Tide Guide: ficha https://apps.apple.com/us/app/tide-guide-charts-tables/id1406371071 · Forbes ES sobre Tide Guide https://forbes.es/en/nautik-magazine/946677/this-is-the-tide-app-that-apple-just-awarded-a-prize-to/ · AppStories ADA 2026 https://www.macstories.net/podcasts/appstories/489/
- Calm Sleep visual system (BUCK): https://buck.co/work/calm-sleep-visual-system · Sleep Cycle rebrand (15-05-2025): https://sleepcycle.com/newsroom/press-release/a-fresh-set-of-sheets-for-your-app-experience · tendencias en apps de mindfulness (dic. 2025): https://bighuman.com/blog/trends-in-mindfulness-app-design · Headspace guía https://blakecrosley.com/guides/design/headspace
- Ōura app (Instrument): https://www.instrument.com/work/oura-app · rediseño https://9to5google.com/2025/10/20/oura-app-redesign/ · https://www.wareable.com/wearable-tech/oura-cumulative-stress-cycle-insights-advisor-update-rollout-app-redesign

**Objetos**
- Dieter Rams, diez principios: https://www.readingdesign.org/ten-principles · Rams/Braun (SK4, ET66): https://www.Wikipedia.org/wiki/Dieter_Rams · Rams Foundation https://rams-foundation.org/?p=7213 · Cooper Hewitt (Braun, segundero amarillo; AB 21/s) https://collection.cooperhewitt.org/objects/1108968897 · AB1 (Lubs) https://www.manufactum.com/alarm-clock-braun-analog-a201144/ · ET66 https://dwell.com/photos/query/braun%20et66%20calculator
- Teenage Engineering: SFMOMA entrevista Kouthoofd (feb. 2024) https://www.sfmoma.org/read/stay-curious-stay-naive-an-interview-with-teenage-engineering-jesper-kouthoofd/ · Highsnobiety (2026) https://www.highsnobiety.com/p/teenage-engineering-interview/ · guía de diseño (paleta, mono) https://blakecrosley.com/guides/design/teenage-engineering · TP-7 "physical skeuomorphism" (Domus, 19-05-2023; 403 hoy, leído vía resumen) https://domusweb.it/en/news/gallery/2023/05/19/teenage-engineerings-new-recorder-is-a-triumph-of-physical-skeuomorphism.html · Engadget TP-7/CM-15 https://www.engadget.com/teenage-engineering-tp7-cm15-field-series-review-170052292.html · OP-1 field https://perfectcircuit.com/signal/teenage-engineering-op-1-field-review
- Bang & Olufsen: A1 3.ª gen. https://www.whathifi.com/speakers/wireless-speakers/bang-and-olufsen-beosound-a1-3rd-generation · https://www.headphonecheck.com/test/bang-olufsen-beosound-a1-3rd-gen/ · Explore https://www.t3.com/us/reviews/bang-olufsen-beosound-explore-review · https://livingetc.com/reviews/bang-and-olufsen-beosound-explore-review-an-impressive-outdoor-speaker-from-the-luxury-brand
- Nothing: Dezeen Phone (1) (Adam Bates) https://www.dezeen.com/2022/08/19/nothing-phone-1-design/ · Phone (2) Glyph https://www.macrumors.com/2023/07/11/nothing-phone-2-hands-on/ · Red Dot https://red-dot.org/project/nothing-phone-2-70900 · https://www.yankodesign.com/?p=443555
- Hatch Restore 3: Yanko (25-07-2026) https://www.yankodesign.com/2026/07/25/the-170-clock-that-wants-you-off-your-phone-at-night/ · T3 https://t3.com/home-living/wellness/hatch-restore-3 · Wareable https://www.wareable.com/health-tech/hatch-restore-3-review
- Ozlo Sleepbuds: Tom's Guide https://www.tomsguide.com/wellness/sleep-tech/ozlo-sleepbuds-review · Digital Trends https://digitaltrends.com/mobile/ozlo-sleepbuds-review · T3 https://t3.com/home-living/sleep/ozlo-sleepbuds-review · Gadgets & Wearables (mar. 2026) https://gadgetsandwearables.com/2026/03/18/ozlo-sleepbuds-review/
- Loop Quiet 2: Tom's Guide https://www.tomsguide.com/wellness/sleep-tech/loop-quiet-2-earplugs-review · Loop https://us.loopearplugs.com/products/quiet · Hearing Tracker (lab) https://www.hearingtracker.com/earplugs/loop-earplugs-review-lab-and-real-life-test-of-engage-experience-quiet-switch-2
- Dyson: Dezeen OnTrac (Jake Dyson) https://www.dezeen.com/2024/07/18/dyson-ontrac-first-headphones/ · TechRadar entrevista https://techradar.com/home/vacuums/were-not-hiding-how-things-work-were-expressing-it-i-sat-down-with-jake-dyson-to-talk-radical-product-design-and-why-your-favorite-vacuum-and-hair-dryer-look-like-nothing-else-on-the-planet · colores y materiales https://www.dyson.com/discover/innovation/behind-the-invention/dyson-colors-materials-finishes · Domus, diez lecciones https://domusweb.it/en/design/2023/01/02/ten-lessons-in-design-from-james-dyson.html
- Leica M11: TechRadar https://www.techradar.com/reviews/leica-m11 · Digital Camera World https://www.digitalcameraworld.com/au/reviews/leica-m11-review · M11-D https://www.digitalcameraworld.com/reviews/leica-m11-d-review · Red Dot Forum https://www.reddotforum.com/content/2022/01/leica-m11-review-the-ultimate-digital-m/ · Leica "metal grey" https://leica-camera.com/en-US/photography/products-metal-grey
- Aesop: Work & Co cliente https://work.co/clients/aesop · https://work.co/news/how-aesop · Fonts In Use https://fontsinuse.com/tags/11303/aesop · tipografía web https://fontalternatives.com/inspiration/aesop-suisse/ · "Anti Marketing: Aesop" https://theunpublished.substack.com/p/anti-marketing-aesop · The Dieline https://thedieline.com/?p=38088
- Muji: Quartz (Hara, "emptiness") https://qz.com/quartzy/1140182/mujis-design-philosophy-is-emptiness-not-minimalism-says-kenya-hara · Design Anthology https://designanthologymag.com/story/kenya-hara-conversation · Fast Company https://www.fastcompany.com/90152917/how-muji-japans-most-famous-anti-brand-plans-to-win-america · Muji "The art of simple design" https://uk.muji.eu/pages/muji-stories/the-art-of-simple-design.html

**Estudios**
- Pentagram: Evernow https://www.pentagram.com/work/evernow · Phenology https://www.pentagram.com/work/phenology · Lenus https://www.pentagram.com/work/lenus/story · Abridge https://www.pentagram.com/work/abridge · Rugiet https://pentagram.com/work/rugiet · Flight Center Gothic (TWA) https://pentagram.com/news/creating-a-custom-typeface-for-the-twa-hotel-at-jfk
- Work & Co: https://www.work.co/clients/ · entrevista Red Dot https://www.red-dot.org/magazine/interview-with-work-co-part-of-accenture-song
- Smart Design: MoMA Good Grips https://www.moma.org/collection/works/3754 · https://smartdesignworldwide.com/?p=796 · https://smartdesignworldwide.com/news/2022-good-design-awards/
- frog: identifeye https://www.frog.co/work/retinal-screening-reimagined · Lumen https://www.frog.co/work/breathing-life-into-lumen-via-product-and-ux-design/ · MeMed https://www.frog.co/work/revolutionizing-testing-at-the-point-of-need/ · AIGA Eye on Design https://eyeondesign.aiga.org/at-tech-forward-firm-frog-design-is-all-about-process/
- COLLINS: Muse Group https://wearecollins.com/work/muse · It's Nice That https://www.itsnicethat.com/articles/collins-muse-group-graphic-design-project-220725 · Creative Boom https://www.creativeboom.com/news/collins-rebrands-muse-group-as-a-creative-fluency-company-for-the-next-generation-of-musicians
- Instrument: https://instrument.com/ · Ōura app https://www.instrument.com/work/oura-app · Fast Company IBD 2026 (trade press) https://lbbonline.com/news/Instrument-Receives-Recognition-in-Fast-Companys-2026-Innovation-by-Design-Awards

**Internas (repositorio y scratchpad de la sesión)**
- `docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md` · `docs/REVIEW-PR3-2026-11-16.md` · `scratchpad/research/gap-design-visual-audit.md` · `scratchpad/research/premium-posicionamiento-aso.md` · `SleepNoise/App/Theme.swift` y vistas de Mixer, Breathing, Paywall, Timer, Library · capturas `scratchpad/ui/before/*.png` y `scratchpad/ui/pr3/*.png`.

**No accesibles hoy**: Domus TP-7 (403; citado vía resumen de búsqueda), Mobbin, screensdesign (catálogo), webbyawards.com (premio de Portal), ficha Apple del Sleep Score (forma visual), fichas de myNoise y Veil.
