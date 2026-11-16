# SleepNoise · Brief creativo

**Dirección creativa del estudio · 16 de noviembre de 2026 · Documento 00 de la serie de diseño**

Este brief abre el trabajo de diseño. Lo leen los equipos de concepto, el equipo del sistema final, el jurado interno y el dueño. Todo lo que afirma sobre mercado, clientes, ciencia y plataforma procede de los tres informes de investigación de la misma fecha (`docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md`, la auditoría visual del set de referencia y el informe de posicionamiento premium) y de la revisión del PR #3 (`docs/REVIEW-PR3-2026-11-16.md`); lo que es criterio del estudio se dice como tal. Las citas de usuarios y de diseñadores van en su idioma original.

Nota sobre el alcance de pantallas: el plan de funciones priorizado por versión (`docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md`) **no existía al escribir este brief**. Las superficies de la sección 6 se derivan del producto actual (mezclador de seis capas, temporizador con fundido, mezclas guardadas, Marea respiratoria, prueba de 7 días, paywall de pago único) y de las diez oportunidades del informe de mercado. El inventario definitivo de pantallas por versión llegará de ese plan; este brief fija el carácter, no el alcance.

---

## 1. El encargo en una página

**Qué es.** SleepNoise es una app de iPhone (iOS 17+, SwiftUI, sin dependencias, sin red salvo StoreKit, sin cuentas) que **genera** sonido en tiempo real con un DSP propio: ruido blanco, rosa y marrón, y texturas (lluvia, ventilador, océano; en revisión: trueno, hoguera, arroyo, viento, cabina). No reproduce grabaciones; sintetiza, así que no hay bucle que se repita ni costura que despierte. Tiene un mezclador de capas, un temporizador con fundido, mezclas guardadas y la **Marea respiratoria**: el oleaje se acompasa a una respiración lenta y se disuelve. Se prueba siete noches sin tarjeta y se compra una sola vez. Pesa casi nada (el DSP sustituye a 300-700 MB de archivos de audio de la competencia) y suena en un segundo.

**Para quién.** Tres personas, en este orden:

1. **Quien enmascara cada noche desde hace años**: acúfenos, hipersensibilidad, pareja que ronca, calle. Necesita graves que pueda modular, un sonido que nunca se repita y una app que no le falle a las 4. Ya paga 19,99 $ a myNoise y lo defiende ("For $20 it is one of the best purchases you can make").
2. **El adulto de 30-55 con la cabeza acelerada** que se despierta a las 3 y vuelve a la app para dormirse otra vez (el 50-59 % de los malos dormidores de Calm lo hace; *JMIR* 2020). Quiere oscuridad, cero texto, un ritmo que le lleve y se retire solo. Está harto de suscripciones: la factura es la queja número uno de la categoría (32 % de las reseñas de 1-3★ en EE. UU.; 24 % en español denuncian una prueba gratuita cobrada).
3. **El usuario Apple que compra diseño**: el perfil Dark Noise / Bear / Things / MacStories. Usa la app de noche y de día (concentración), paga 20-50 $ una vez, exige Atajos, widgets, Watch, HomePod, StandBy, y es quien prescribe en prensa y Reddit. Es el camino al featuring de Apple, la única palanca de crecimiento que ha funcionado en esta categoría indie.

**Qué debe sentir alguien a las 3 de la mañana.** Nada. Esa es la medida. Coge el iPhone con una mano, medio dormido, con la vista nublada, y en un gesto el sonido vuelve, o baja, o se alarga quince minutos. La pantalla no le ilumina la cara ni la habitación (negro OLED real, no gris oscuro); no hay nada que leer; no hay nada que decidir; no hay nada que pueda tocar por error y le enseñe un precio. Si abre los ojos a medias, lo que ve se entiende por forma y posición, no por color ni por texto, porque en la mesilla con StandBy nocturno todo se verá en rojo. La app se comporta como el interruptor de una lámpara de buena fábrica: se encuentra a ciegas, responde con peso y no hace ruido.

**Qué debe sentir alguien que la abre por primera vez en una Apple Store.** Que es un objeto, no un servicio. En la tienda la luz es blanca y el ruido alto: ahí la app no puede apoyarse en la atmósfera, solo en la factura. Lo que debe leerse en los primeros cinco segundos, sin tutorial: una tipografía bien puesta, mucho aire, una superficie negra mate con una sola nota de color, y algo que se mueve con causa (la envolvente real del sonido que está sonando, no una decoración). Un toque y suena; otro y se calla. El precio, cuando aparezca, se dice una vez, con un número y sin tachaduras. La sensación que buscamos es la de abrir Things o Bear por primera vez, o de coger una radio Braun: "aquí alguien ha decidido todo, y ha decidido quitar". El cliente lo resume con su propia referencia: la app de notas Bear. No es un estilo que copiar; es un nivel de confianza en la tipografía y en el vacío que igualar.

**El trabajo.** Dar a SleepNoise una identidad y un sistema de interfaz que la sitúen, de forma verificable, como la app de sonido para dormir mejor diseñada de la App Store, candidata natural a un Apple Design Award en Interaction o Innovation, sin añadir nada que no esté al servicio de dormir. El dueño va a invertir todo lo posible en diseño; el estudio le debe a cambio restricción, no espectáculo.

---

## 2. Posicionamiento traducido a diseño

La investigación fija el posicionamiento en tres palabras: **"el instrumento de sueño"**. Una app que genera sonido como un instrumento, no que reproduce grabaciones; que se compra una vez, como un objeto; que es honesta hasta el último detalle. En una línea: *"Sonido para dormir que nunca se repite. Nace en tu iPhone, no en un estudio. Un solo pago."*

Lo que eso significa para quien diseña:

### 2.1 Instrumento, no biblioteca

Una biblioteca se enseña con una rejilla de iconos y una lista de contenidos; un instrumento se enseña con **sus controles y su respuesta**. La pantalla principal no es un catálogo de doce baldosas (eso es BetterSleep, y es también lo que hizo el PR #3): es un conjunto pequeño de controles con peso que devuelven algo cuando se tocan. La interfaz debe hacer visible lo único que la competencia no puede enseñar: que el sonido se está **fabricando ahora**. La visualización de la pantalla principal es la envolvente real de la síntesis, por capa, a la velocidad real; en la Marea, una sola forma que respira a la frecuencia a la que suena el mar. Nada en pantalla se mueve si no tiene causa física en el audio. Es la "transparencia" de Nothing ("as soon as you go transparent you can start to tell a story about the components") y el "Zero AI" de Halide, aplicados al DSP.

Referencias de instrumento que el estudio debe tener en la pared: Braun (Rams/Lubs): un dial, una escala, un punto; Teenage Engineering: "I set up restrictions when I design", geometría simple, cada control hace una cosa; Bang & Olufsen: el gesto se siente antes de verse, el material manda; el Mindfulness de Apple Watch: una sola forma que crece y encoge, con un háptico que casi no se nota.

### 2.2 Honestidad Rams

Los principios 5, 6, 8 y 10 de Rams son la norma de calidad del proyecto, no una inspiración: *honest* ("should not appear more innovative, powerful, or valuable than it is"), *unobtrusive* ("neutral and restrained, leaving room for the user's self-expression"), *thorough down to the last detail* ("Nothing should be arbitrary"), *as little design as possible*. Traducido:

- **Nada que parezca más de lo que es.** Si una modulación es lenta y pequeña, la visualización es lenta y pequeña. No hay resplandor que sugiera "energía", ni partículas que sugieran "inteligencia". La palabra "IA" no aparece.
- **Cada afirmación lleva su prueba a un toque de distancia.** Las frases sobre respiración lenta, enmascaramiento o regularidad enlazan a una pantalla "Qué sabemos y qué no" con el estudio, su n y quién lo pagó. Lo que no se puede probar, no se dice (lista cerrada de prohibiciones de copy en §7.2).
- **El precio es una cifra.** Una, con confianza, sin cuenta atrás, sin "antes 59,99", sin lifetime "de oferta". Si hay precio de lanzamiento, se dice que es de lanzamiento y cuándo termina, y ya.
- **Ningún detalle es arbitrario.** Cada radio, cada grosor de línea, cada duración de animación tiene un valor y una razón escritos en el sistema. El estudio debe poder defender cualquier píxel ante el jurado.

### 2.3 Lo que no hay es parte del producto

El informe de mercado lo dice con datos: cada ausencia de SleepNoise responde a una queja literal y verificada. **Sin suscripción, sin cuenta, sin anuncios, sin red, sin puntuación, sin racha, sin tracker, sin petición de valoración.** El diseño tiene que hacer que esas ausencias se noten como lujo, igual que un reloj sin fecha o un envase de Aesop sin promesa:

- La primera pantalla no tiene onboarding ni registro (Bear: "No sign-up or tutorial"; HIG: "Postpone nonessential setup").
- No hay una sola pantalla que pida permiso antes de que el usuario quiera la función que lo necesita.
- La privacidad se enseña con una frase ("Nada sale de tu iPhone"), no con un icono de escudo.
- El vacío de la interfaz no se rellena con tarjetas informativas, consejos del día ni "descubre". Lo que no tiene función no tiene píxeles.
- La ficha de la App Store llevará "Data Not Collected": la única del grupo. El diseño de la ficha debe estar a la altura de esa etiqueta.

---

## 3. Atributos de marca

Seis atributos. Cada uno lleva su opuesto (lo que el estudio debe evitar aunque se parezca) y una manifestación concreta en pantalla. Son la vara con la que se mide cada concepto.

| # | Atributo | Opuesto a evitar | Cómo se manifiesta en pantalla |
|---|---|---|---|
| 1 | **Callado** (unobtrusive) | Mudo, inexpresivo, "vacío por pereza" | La pantalla de noche es negro puro con un único elemento legible a un metro: el estado (suena / no suena) y, si hay temporizador, el tiempo que queda. Ni logo, ni título, ni nombre de la mezcla. En reposo, nada se mueve. Un toque en cualquier parte pausa o reanuda; el usuario no tiene que buscar el botón. |
| 2 | **Preciso** (instrumento) | Técnico, frío, panel de ingeniería (myNoise con diez sliders) | Un slider de capa tiene valor visible mientras se arrastra, pasos con háptico de selección y una escala que se entiende sin número. El detalle técnico (frecuencia de corte, respiraciones por minuto exactas) existe, pero vive debajo de una pulsación larga: la precisión está disponible, no impuesta. |
| 3 | **Honesto** (Rams) | Ingenuo, descafeinado, "sin personalidad por miedo" | Lo que se mueve es la envolvente real. La Marea muestra la frecuencia actual ("6 por minuto") y de dónde viene ("tu ritmo nocturno medio, según Salud" o "valor por defecto"). El copy dice "enmascara" y "te acompaña a respirar más despacio", nunca "mejora tu sueño". La pantalla de compra enseña el precio antes de cualquier toque. |
| 4 | **Cálido sin ser blando** | Risueño, "wellness", pastel, ilustración de luna sonriente (Headspace); o su contrario: místico y cinematográfico (Calm, Aura) | El calor viene de la tipografía (una romana del sistema como New York o una humanista bien interlineada en los textos largos, si el concepto lo justifica), de la curva de los controles y de un solo acento templado; nunca de ilustraciones, degradados azul-noche ni estrellas. Las etiquetas de las capas son humanas ("lluvia fina", "ventilador lejano"), no comerciales ("Deep Sleep Pro"). |
| 5 | **Material** (objeto, no servicio) | Plano genérico de plantilla; o skeuomórfico (madera, cromados) | Negro OLED como material base, no como "modo"; superficies elevadas en gris 28,28,30 solo cuando hay una hoja encima; líneas finas (hairline de 0,5 pt) como único separador; una sombra o relieve solo donde hay un control que se puede coger. Las animaciones tienen masa: springs apretados, duraciones cortas, nada flota. |
| 6 | **Permanente** | Novedoso, "trendy", rediseño cada temporada | Lo que se diseña ahora debe seguir pareciendo correcto en 2031. Una reseña de White Noise lo pide así: "the UI and features have stayed exactly the same for years is a HUGE plus". Se traduce en: una familia tipográfica, una paleta de cinco valores, componentes del sistema de Apple siempre que existan, Liquid Glass solo en la capa de navegación y solo donde el sistema lo pone solo. Nada que Apple pueda dejar obsoleto en una WWDC. |

Un atributo que se descarta a propósito: **"relajante"**. Es el atributo de toda la categoría, no distingue nada y empuja a los degradados y a la música de spa. SleepNoise no relaja: funciona.

---

## 4. Principios de diseño

Doce principios, comprobables. Cada uno dice cómo lo sabremos (una prueba que cualquiera del equipo puede hacer) y un ejemplo de violación. Varios de los ejemplos están tomados del estado actual de la app o del PR #3: no son hipotéticos.

**P1. La noche manda sobre el día.** Toda pantalla se diseña primero para las 3 de la mañana, con la pantalla al mínimo brillo y los ojos a medio abrir, y después se comprueba que sigue bien a plena luz.
*Cómo lo sabremos:* cada concepto se revisa primero en un dormitorio a oscuras en un iPhone real con brillo al mínimo y después en la tienda; si solo funciona en uno de los dos, no pasa.
*Violación:* el PR #3 decidió la pantalla principal en claro, con un degradado animado y 23 formas rellenas, y la pantalla Noche quedó con el reloj a 2,7:1 de contraste.

**P2. Un gesto para lo que se hace medio dormido.** Reproducir/pausar, prolongar el temporizador y bajar el volumen deben hacerse con un solo toque o un solo arrastre, sin mirar, desde la app, la pantalla de bloqueo, la Live Activity o el Watch.
*Cómo lo sabremos:* prueba a ciegas: cinco personas con los ojos cerrados deben pausar el sonido y añadir quince minutos a la primera, en tres superficies distintas.
*Violación:* en el PR #3, cambiar el volumen de una capa costaba cuatro pasos (pestaña, hoja, pasar botón, tarjeta y fila); en la app actual, prolongar el temporizador exige abrir una hoja y elegir entre cinco botones.

**P3. Negro real, luz mínima.** La superficie nocturna es 0,0,0; las elevadas, 28,28,30. Ningún blanco puro. El acento es el único color y aparece en un solo elemento por pantalla.
*Cómo lo sabremos:* medición de luminancia de la pantalla principal en reposo nocturno (objetivo: píxeles apagados en más del 90 % de la superficie); conteo de colores distintos del gris por pantalla (máximo uno más los estados del sistema).
*Violación:* la app actual usa un fondo gris azulado (14,17,20) con degradado y un resplandor ámbar radial detrás del título mientras suena; ningún píxel está apagado.

**P4. Lo que se mueve tiene causa en el sonido.** Ninguna animación decorativa. La visualización es la envolvente real por capa; la forma de la Marea respira a la frecuencia a la que suena el oleaje; el fundido del temporizador se ve como baja el nivel real.
*Cómo lo sabremos:* para cada elemento animado, el sistema de diseño nombra la señal del motor de audio que lo mueve. Si no hay señal, no hay animación. Con Reduce Motion, todo se sustituye por fundidos; con `isLuminanceReduced`, todo se congela en ≤2 s "gracefully", nunca de golpe.
*Violación:* el degradado del PR #3 modula su opacidad del 5 al 21 % a 15 fps "mientras suena", sin relación con el audio, y consume GPU toda la noche.

**P5. Tipografía primero, una familia.** La jerarquía se construye con tamaño, peso e interlineado de una sola familia del sistema (SF Pro por defecto; New York o una humanista instalada solo para textos largos y solo si un concepto lo justifica). SF Rounded no se usa en cuerpo; como mucho, en la cifra grande del temporizador, y hay que defenderlo. Peso ≥ Medium en todo lo que se lea a oscuras. Dynamic Type de xSmall a AX5 sin romper el layout.
*Cómo lo sabremos:* captura de cada pantalla en Large, xxxLarge y AX3; conteo de familias (una, dos como máximo) y de estilos de texto (≤6 por pantalla).
*Violación:* el PR #3 puso SF Rounded en cuerpo y semibold casi en todo; la app actual mezcla seis tamaños en la primera pantalla y titula con el nombre de la app, que no aporta nada a quien ya la abrió.

**P6. Aire antes que cajas.** La agrupación se hace con espacio y, si hace falta, con una hairline; nunca con tarjetas rellenas apiladas. Una tarjeta solo existe cuando es un objeto que se puede coger (una mezcla guardada, por ejemplo), y entonces se nota que se puede coger.
*Cómo lo sabremos:* conteo de rectángulos rellenos por pantalla (objetivo: cero en la pantalla principal; ≤3 en cualquier otra); el espacio en blanco entre grupos es al menos el doble del espacio dentro del grupo.
*Violación:* la pantalla principal actual es una pila de siete tarjetas (prueba, Marea, seis capas) con 14 pt de padding cada una, y la primera, la de la prueba, ocupa un cuarto de la pantalla el primer día.

**P7. El estado se lee por forma, no por color.** Suena / no suena, capa activa / inactiva, Pro / no Pro: todo distinguible en escala de grises y bajo el tinte rojo de StandBy.
*Cómo lo sabremos:* cada pantalla se exporta con un filtro de desaturación y con un filtro rojo (simulación del Night Mode de StandBy); si algún estado desaparece, el concepto falla. Contraste WCAG AA (4,5:1 texto, 3:1 grande) medido también bajo el rojo.
*Violación:* en la app actual la única diferencia entre una capa a 0 y una capa sonando es que el icono pasa de gris a ámbar; en gris, las seis filas son iguales.

**P8. 44 puntos, y a oscuras 64.** Ningún control por debajo de 44×44 pt; los que se usan de noche (play/pausa, +15 min, volumen) no bajan de 64 pt o son de pantalla completa. Separación mínima de 12 pt entre objetivos, 24 pt si no tienen borde.
*Cómo lo sabremos:* inspección con Accessibility Inspector y regla sobre las capturas; prueba con el pulgar de una mano en un iPhone Pro Max tumbado de lado.
*Violación:* chips de 40 pt y un asa falsa de 40 pt en el PR #3; en la app actual, los botones "Temporizador" y "Guardar" de la barra inferior son etiquetas de texto sin área clara.

**P9. Nada bloquea el sonido.** Ni el paywall, ni la prueba, ni un permiso, ni un aviso aparece encima de la pantalla mientras el usuario intenta reproducir o pausar. La compra se ofrece; nunca se interpone.
*Cómo lo sabremos:* recorrido del usuario gratuito el día 8: debe poder reproducir blanco, rosa, marrón y lluvia con temporizador de 60 min sin ver una pantalla de venta. Conteo de candados visibles en la pantalla principal: cero.
*Violación:* el PR #3 enseñaba 14 candados (7 chips + 7 baldosas) al usuario gratuito; la app actual pinta "Pro" en cápsulas ámbar sobre las capas bloqueadas y un botón "Pro" permanente en la cabecera.

**P10. Una pantalla, una decisión.** Cada superficie responde a una sola pregunta del usuario (¿qué suena?, ¿cuándo se apaga?, ¿cómo respiro?). Si una pantalla necesita un título que explique lo que contiene, está mal partida.
*Cómo lo sabremos:* cada pantalla del inventario lleva escrita la pregunta a la que responde; el jurado tacha las que responden a dos.
*Violación:* la hoja "Niveles" del PR #3 contenía Noche, Temporizador, Marea y los sliders: cinco de siete grupos no eran niveles.

**P11. Lo técnico, debajo del gesto.** Todo ajuste fino existe (respiraciones por minuto, corte de graves, exhalación más larga que la inhalación) y se alcanza con pulsación larga o un segundo nivel; el primer nivel es un gesto con nombre humano ("más cálido", "más lejano", "más lento").
*Cómo lo sabremos:* mapa de profundidad: ninguna acción habitual a más de dos toques; ningún parámetro técnico a menos de uno largo.
*Violación:* la hoja actual de la Marea expone un stepper "6 por minuto" y cinco botones de duración como primera y única capa; ni gesto ni ajuste por oído.

**P12. Componentes de Apple cuando existen; propios solo cuando aportan.** Navegación, hojas, toggles, pickers, Live Activity, Control Center y widgets usan los componentes del sistema y adoptan Liquid Glass solos, solo en la capa de navegación (HIG: "Don't use Liquid Glass in the content layer"). Un control propio (el slider de capa, la forma de la Marea, el botón nocturno) se diseña una vez, con sus seis estados, y se documenta.
*Cómo lo sabremos:* lista de componentes del sistema de diseño con la columna "sistema / propio / por qué"; cero `glassEffect` en tarjetas, fondos o sliders en reposo; prueba con "Reducir transparencia" e "Incrementar contraste" activados.
*Violación:* el PR #3 pintó un botón como indicador de arrastre de hoja; la app actual usa un botón "Cerrar" en cápsula pintada en vez del cierre estándar de la hoja.

---

## 5. La tensión central que el estudio debe resolver

Hay tres fuerzas legítimas en el encargo y no se pueden satisfacer todas al máximo a la vez. El trabajo de concepto consiste en encontrar la proporción.

**A. Minimalismo Bear.** Tipografía primero, aire, líneas finas, un acento. Bear es una app de texto: su contenido ya es tipografía, así que "tipografía primero" le sale gratis. Bear vive de día, con fondo claro o gris cálido, y su minimalismo es editorial: márgenes generosos, pocas jerarquías, un acento rojo que aparece en un solo sitio. Lo que debemos tomar de Bear: la confianza en el vacío, la ausencia de onboarding, la disciplina de un acento, la decisión de dejar Liquid Glass en la barra y la identidad en el contenido. Lo que no se traslada: SleepNoise casi no tiene texto que leer y se usa, sobre todo, sin mirar.

**B. Instrumento.** Control físico, feedback, precisión. Un mezclador de seis capas con valores, un oleaje que respira a 6 por minuto, un corte de graves que se oye cambiar bajo el dedo. Lo que exige: controles con peso y recorrido, háptica, un visual que responda al audio en tiempo real, cierta densidad de información cuando el usuario la pide. El riesgo: convertirse en un panel (myNoise, con diez sliders verticales y 27 valoraciones en España) o en un juguete (Teenage Engineering mal entendido: colores, botones, pantallita).

**C. Dormitorio a oscuras.** Negro, casi nada, un gesto. A las 3 de la mañana no hay tipografía que valga ni control que leer; hay una superficie negra y un toque. Lo que exige: pantalla completa como botón, cero texto, cero color, movimiento que se detiene. El riesgo: que la app entera se convierta en una pantalla negra con un círculo, y que la primera impresión en la tienda sea "no hay nada".

Las tres fuerzas chocan en puntos concretos:

- **Tipografía (A) frente a no leer (C).** La solución probable no es elegir, sino **separar en el tiempo**: la app tiene una cara de "antes de acostarse" (A + B: se elige la mezcla, se ajusta, se decide el temporizador) y una cara de "ya acostado" (C: negro, un gesto). El paso de una a otra debe ser un único gesto o automático al bloquear. El PR #3 acertó en tener una pantalla Noche y falló en cómo se llegaba a ella y en lo que había antes.
- **Aire (A) frente a precisión (B).** Seis sliders con etiqueta, icono y valor ocupan toda una pantalla y la llenan de cajas. ¿Y si el mezclador no fuese seis filas sino **un objeto** (una forma que contiene las seis capas, con una capa a la vez bajo el dedo)? ¿O seis líneas finas horizontales sin caja, con el nombre a la izquierda y nada más hasta que se toca? El estudio debe explorar al menos dos geometrías del mezclador que no sean "lista de tarjetas con slider".
- **Un acento (A) frente a feedback (B) frente a rojo de StandBy (C).** El acento actual es ámbar cálido (235,184,115). El ámbar sobre negro cumple contraste, se lee bien con los ojos cansados y bajo el rojo de StandBy se convierte en un rojo más claro (sobrevive); un índigo o teal, en cambio, se vuelve gris bajo el rojo. Pero el ámbar es el color de medio sector "sueño" y de la calidez barata. El estudio debe decidir si el acento es un color o es **luz** (una sola intensidad de blanco cálido sobre negro), y demostrar la decisión en las tres superficies: app de día, app de noche, StandBy.
- **Nada decorativo (B, honestidad) frente a "algo que ver en la tienda" (A).** La única visualización legítima es la envolvente real del sonido. En la tienda, con el sonido apagado, no hay envolvente. El estudio debe diseñar el **estado de reposo** del visual (qué se ve cuando nada suena) con la misma honestidad: puede ser una línea quieta, una forma a nivel cero, el silencio dibujado. Que ese reposo sea bello es el reto; que no sea mentira, la condición.
- **Componentes de Apple (P12) frente a carácter propio (B).** Apple regala hojas, toggles, Liquid Glass y Live Activities; con ellos la app se parece a cualquier otra app bien hecha de 2026. El carácter tiene que venir de tres o cuatro piezas propias diseñadas a fondo (el visual del sonido, el slider de capa, la forma de la Marea, el botón nocturno) y de la tipografía; todo lo demás, del sistema.

Lo que el estudio **no** debe hacer con esta tensión: resolverla por mezcla ("un poco de cada"). Esperamos que cada equipo de concepto tome partido (por ejemplo: "somos sobre todo instrumento, y la noche es un modo" o "somos sobre todo noche, y el instrumento aparece bajo el dedo") y lo lleve hasta el final, para que el jurado compare posturas y no matices.

---

## 6. Qué debe comunicar cada superficie

Una frase por superficie: lo que la persona debe entender o sentir, no lo que la pantalla contiene. El inventario definitivo y su orden por versión llegará del plan de funciones; estas son las superficies que ya existen o que las diez oportunidades hacen inevitables.

| Superficie | Debe comunicar |
|---|---|
| **Pantalla principal** (antes de acostarse) | "Esto está sonando ahora, lo estoy fabricando yo y lo controlo con un dedo": el visual real del sonido, la mezcla actual con nombre humano, play/pausa, temporizador y Marea a un toque, y nada más por encima del pliegue. |
| **Sesión / noche** (ya acostado, pantalla bloqueada o modo noche) | "Todo sigue bien y no hace falta mirar": negro total, el estado y el tiempo que queda legibles a un metro, toda la pantalla es el botón, y se vuelve sola a este estado. |
| **Mezclador** (hoja o pantalla) | "Seis capas que se oyen cambiar bajo el dedo": cada capa es una línea con peso y valor, el timbre se ajusta con un gesto humano ("más cálido / más lejano") y lo técnico espera debajo de una pulsación larga. |
| **Marea respiratoria** | "El mar respira más despacio y yo con él, y después se retira": una sola forma que crece y encoge a la frecuencia real del oleaje, de dónde viene esa frecuencia dicho en una línea, y un final que se disuelve en vez de parar. |
| **Temporizador** | "Se apagará suavemente, sin despertarme y sin silenciar mi alarma": tres intenciones con nombre ("hasta dormirme", "toda la noche", "siesta"), hora fija o duración, y el fundido visible como lo que es. |
| **Mezclas guardadas** | "Mis noches, tal como las dejé, esperándome aunque vuelva dentro de dos años": pocas, con nombre propio, se cogen con un toque y sobreviven a reinstalar y a cambiar de iPhone. |
| **Paywall y prueba** | "Siete noches con todo, sin tarjeta; después un precio, una vez, y lo que seguirá siendo gratis dicho con claridad": el número antes de cualquier toque, sin tachaduras ni cuenta atrás, y Restaurar a la vista. |
| **Onboarding de una noche** | "No hay onboarding": la primera pantalla ya suena con un toque, y lo que haya que aprender se aprende en el momento de usarlo, con una línea de TipKit como mucho. |
| **Widgets, Live Activity, StandBy, Watch** | "Desde la mesilla, sin encender nada": un solo control (play/pausa), el tiempo como texto, forma antes que color para sobrevivir al rojo de StandBy, y en el Watch el háptico de la Marea en la muñeca. |
| **Icono** | "Un objeto, no una luna": una forma geométrica que podría estar grabada en un panel de Braun, legible a 29 pt, correcta en claro, oscuro, tinted y clear sin perder identidad. |
| **Capturas y app preview** | "Nunca se repite, y aquí se ve cómo se fabrica": la primera captura dice el precio y lo que no hay, la preview muda de 30 s enseña la onda generándose, la mezcla y la Marea ralentizándose, nada de rejillas de iconos. |
| **Pantalla "Qué sabemos y qué no"** | "Te decimos lo que la ciencia sostiene, con su n y quién lo pagó, y lo que no": una lista tipográfica sin iconos ni sellos, a un toque desde cada afirmación de la app y de la ficha. |

---

## 7. Lo prohibido

### 7.1 Lista negra visual

| Prohibido | Por qué |
|---|---|
| **Tarjetas por todas partes** (rectángulos rellenos apilados como forma de agrupar) | Es el patrón de BetterSleep y del estado actual; rompe P6; convierte una pantalla en una pila de cajas y obliga a un gris de relleno que impide el negro real. |
| **Resplandores, halos y degradados animados** detrás de controles o títulos | Decoración sin causa (P4); coste de GPU toda la noche (PR #3: modulación a 15 fps que nadie percibe); el idioma visual de Calm y de las apps de "energía". |
| **Degradado azul-noche, cielo estrellado, luna, nubes** | Es el fondo de pantalla de la categoría entera (Calm, BetterSleep, ShutEye); el usuario ya no lo ve y Apple ya no lo premia. |
| **Ilustraciones** (risueñas, orgánicas, 3D, "wellness") | Rompen el atributo *material* y *permanente*; envejecen en dos años; nada en SleepNoise es ilustrable sin mentir. |
| **Rejilla de baldosas de sonidos** como pantalla principal | Enseña una biblioteca, no un instrumento; el PR #3 lo demostró (once baldosas y el mezclador escondido). |
| **Gamificación, rachas, puntuaciones, anillos de progreso, confeti** | Contradice "la app que no te puntúa" (ortosomnia documentada; "increased their anxiety rather than helping"); activa 1.4.1 si se interpreta como medición. |
| **Candados por doquier** | 14 candados en el PR #3; cada candado es un reproche; lo bloqueado simplemente no aparece o aparece sin castigo visual (P9). |
| **Badges "Pro", "Premium", "Nuevo", cápsulas de oferta, precios tachados, cuentas atrás** | Señal opuesta al lujo; es lo que los usuarios citan como "estafa" en las reseñas en español. |
| **SF Rounded en cuerpo, pesos Light/Thin/Ultralight a oscuras, texto < 11 pt** | HIG: "Avoid Ultralight, Thin, and Light weights, especially at small sizes"; el timer actual es Light 44 pt redondeado y la pantalla Noche del PR #3 un reloj fino a 2,7:1. |
| **Blancos puros** (255,255,255) en texto o fondo | HIG: "Soften the color of white backgrounds"; a oscuras un blanco puro deslumbra; usar el blanco cálido del sistema atenuado. |
| **Liquid Glass en la capa de contenido** (tarjetas, fondos, sliders en reposo), vidrio apilado, vidrio *clear* sobre negro sin razón | HIG literal; el vidrio regular sobre negro es invisible y el clear sobre negro es ruido; solo en barras y solo el que el sistema pone. |
| **Más de un color de acento por pantalla; acento en varios controles** | HIG para iOS 26: "Avoid adding color to the backgrounds of multiple controls"; rompe P3. |
| **Ajuste de apariencia propio** (selector claro/oscuro dentro de la app) | HIG: "Avoid offering an app-specific appearance setting"; si la app es solo-oscura se declara como decisión de medio inmersivo y se siguen definiendo variantes claras para el vidrio. |
| **Falsas asas, botones que imitan indicadores del sistema, botones "Cerrar" pintados donde la hoja ya tiene cierre** | Engañan al gesto y duplican controles (PR #3; app actual). |
| **Animación que siga en Always-On, StandBy o con Reduce Motion** | HIG: "the system doesn't perform animations", "Gracefully transition motion to a resting state". |
| **Iconos de sonidos con "emoji" o símbolos animados** | Es el sello de Dark Noise ("each with an animated icon"); SleepNoise no enseña iconos de biblioteca, enseña el sonido. |
| **Pantalla de bienvenida, carrusel de onboarding, solicitud de notificaciones o valoración al abrir** | Bear: "No sign-up or tutorial"; reseñas: "Begging for an app store rating 1.2 seconds after opening". |

### 7.2 Lista negra de copy

Cerrada por el informe de investigación (sección 5.2) y por las guías 1.4.1, 2.3 y 1.1.6 de App Review. Vale para la interfaz, la ficha, la web y las notas de versión, en los dos idiomas.

| Prohibido | En su lugar |
|---|---|
| "Mejora el sueño", "mejora la calidad del sueño", "te dormirás un X % más rápido", "clínicamente probado", "científicamente demostrado" | "Enmascara los sonidos que te despiertan"; "sonido que nunca se repite, generado en tu iPhone". |
| "Más sueño profundo", "ondas lentas", "sincroniza tus ondas cerebrales", "consolida la memoria" | Nada; requieren EEG. |
| "Trata / cura / alivia el insomnio", "terapia", "tratamiento", "clínico", "grado médico" | "Insomnio" solo en el campo de keywords; en pantalla, nunca. |
| "Reduce los acúfenos", "trata el tinnitus", "TRT" | "Confort para quien oye un pitido"; "enmascaramiento personalizado". |
| "Activa el nervio vago", "regula tu sistema nervioso", "reduce la ansiedad" | "Te acompaña a respirar más despacio"; "ritmo respiratorio lento asociado en estudios a mayor variabilidad cardiaca". |
| "Te despierta en fase ligera", "detecta tus fases", "alarma inteligente" | "Despertar progresivo"; si hay Watch, "estimación de Apple". |
| "Seguro para bebés", "recomendado por la AAP" | "Recomendación de seguridad acústica: lejos de la cuna, al mínimo volumen, solo hasta que se duerma". |
| "Personalizado por IA", "se adapta a tu cuerpo", "sabe lo que necesitas", la palabra "IA" | "Se adapta a tu noche" más un panel que enseña qué entrada actúa y por qué. |
| "Funciona para el TDAH" | Preset "Foco", sin afirmación. |
| Porcentajes de mejora, umbrales ("si dormiste menos de 6 h…"), cuestionarios de insomnio | Nada. |
| Superlativos vacíos ("la mejor", "increíble", "mágico"), "relajante" como promesa | Frases cortas y concretas: "White noise, refined" (Dark Noise), "Zero AI" (Halide), "Simply Powerful" (Things). |
| "Vitalicio", "lifetime" en español | "De por vida" o "un solo pago" (es como lo dice el usuario hispano; "vitalicio" suena a seguro). |
| "Timer", "mix" en español | "Temporizador", "mezcla" (vocabulario real de las reseñas: "temporizador" 9 frente a "timer" 3). |
| "Protocolo", "sesión de terapia", "módulo", "semana 1" | "Ritual", "noche", "descenso". |
| Comparaciones nominales con Apple o con competidores | Decir lo que hacemos ("seis capas que se mezclan", "se apaga suavemente"), nunca lo que otros no hacen. |

Tono de referencia para todo el copy: corto, concreto, sereno; en segunda persona sin exclamaciones; sin diminutivos; sin emojis. Bear para la cadencia, Aesop para la serenidad, Things para la brevedad.

---

## 8. Criterios del jurado

Cinco lentes, con peso. Cada concepto se puntúa de 1 a 5 en cada lente, se multiplica por el peso y se suma; pero una puntuación de 1 en cualquiera de las dos primeras lentes elimina el concepto aunque gane en total.

| Lente | Peso | Qué se mira | Prueba que exigirá el jurado |
|---|---|---|---|
| **1. Las 3 de la mañana** | 30 % | ¿Funciona a oscuras, sin mirar, con una mano, medio dormido? ¿La superficie nocturna es negra de verdad? ¿Sobrevive al rojo de StandBy y a Always-On? ¿Puede pausarse, prolongarse y bajarse en un gesto desde app, bloqueo y Watch? | Demostración en dormitorio real con brillo al mínimo; capturas con filtro rojo y en escala de grises; prueba a ciegas de cinco personas. |
| **2. Honestidad e instrumento** | 25 % | ¿Todo lo que se mueve tiene causa en el audio? ¿La precisión está disponible sin imponerse? ¿El copy respeta la lista negra? ¿El precio se dice con confianza? ¿Hay algo que aparente más de lo que es? | Tabla "elemento animado → señal del motor"; lectura del copy contra §7.2; recorrido del paywall. |
| **3. Restricción tipográfica y material** | 20 % | ¿Una familia, una paleta de cinco valores, un acento? ¿Aire en vez de cajas? ¿Hairlines, no bordes? ¿Negro OLED como material? ¿Dynamic Type de xSmall a AX5 sin romper? ¿Resistiría cinco años? | Conteo de familias, estilos, colores y rectángulos rellenos por pantalla; capturas en tres tamaños de Dynamic Type; comparación lado a lado con Bear y Things. |
| **4. Plataforma Apple** | 15 % | ¿Componentes del sistema donde existen; Liquid Glass solo en navegación; Live Activity con un control; Control Center con símbolos on/off; widget con fondo removible; VoiceOver completo; Reduce Motion, Reducir transparencia e Incrementar contraste respetados? ¿Es creíble como candidata a ADA (Interaction / Innovation)? | Lista de componentes "sistema / propio / por qué"; auditoría con Accessibility Inspector; prototipo de Live Activity y StandBy en dispositivo. |
| **5. Primera impresión y venta** | 10 % | ¿En la tienda, con luz blanca y sin sonido, se entiende en cinco segundos que es un objeto de calidad? ¿La primera captura y la preview muda cuentan "nunca se repite" y "un solo pago"? ¿El icono se distingue a 29 pt de todos los de la categoría? | Prueba de cinco segundos con personas ajenas; maqueta de la ficha completa (icono, 3 primeras capturas, preview) junto a las de Dark Noise, Endel y Calm. |

Desempate: el concepto que haya **quitado más** sin perder función.

---

## 9. Entregables

### 9.1 De cada equipo de concepto

Tres equipos, cada uno con una postura declarada frente a la tensión de §5 (recomendado: uno "sobre todo instrumento", uno "sobre todo noche", uno "sobre todo editorial/Bear"). Todos entregan lo mismo para que el jurado compare:

1. **Postura en una página**: qué fuerza de §5 manda, qué se sacrifica y por qué.
2. **Las cinco pantallas clave en alta fidelidad**, en oscuro, iPhone 17 Pro y iPhone SE/16e: pantalla principal (reposo y sonando), superficie nocturna, mezclador, Marea, paywall. Cada una también en claro aunque la app sea solo-oscura (el vidrio lo exige).
3. **El estado de reposo y el estado sonando del visual del sonido**, con la señal del motor que mueve cada elemento y su comportamiento con Reduce Motion e `isLuminanceReduced`.
4. **Prototipo navegable** (SwiftUI o Figma con animación) del flujo "abrir → sonar → acostarse → despertar a las 3 → prolongar → dormir", para probarlo a oscuras.
5. **Live Activity (compacta, expandida, Lock Screen), widget pequeño en StandBy nocturno y complicación / Smart Stack del Watch**, con el filtro rojo aplicado.
6. **Icono** en Default, Dark, Tinted y Clear, a 1024, 60 y 29 pt, en una hoja junto a los diez iconos de la categoría.
7. **Hoja tipográfica**: familia(s), escala, pesos, interlineados; capturas de las cinco pantallas en Large, xxxLarge y AX3.
8. **Paleta**: los valores exactos en RGB, su contraste sobre 0,0,0 y 28,28,30, y su apariencia bajo rojo de StandBy y con Incrementar contraste.
9. **Dos geometrías alternativas del mezclador** (al menos una que no sea "lista de filas con slider").
10. **Autoevaluación contra los doce principios** de §4 con la prueba de cada uno hecha, y contra las dos listas negras de §7.

### 9.2 Del equipo del sistema final

Tras la elección del jurado, el equipo del sistema convierte el concepto ganador en algo que un equipo de iOS pueda construir sin interpretar:

1. **Fundamentos**: tokens de color (base, elevated, texto primario/secundario/terciario, acento, acento con contraste aumentado, estados), tipografía (estilos con nombre y mapeo a Dynamic Type), espaciado (escala de 4 pt), radios, hairlines, sombras (si las hay), duraciones y curvas de animación, háptica (qué patrón en qué gesto, con el límite HIG de "haptics that people may not be conscious of").
2. **Componentes**, cada uno con sus estados (reposo, pulsado, activo, deshabilitado, bloqueado sin castigo, foco de VoiceOver), su tamaño mínimo, su comportamiento con Dynamic Type y con Reduce Motion, y la columna "sistema / propio / por qué": slider de capa, visual del sonido, forma de la Marea, botón nocturno, fila de mezcla guardada, selector de temporizador, bloque de precio, nota de evidencia.
3. **Patrones**: cómo se entra y se sale del modo noche; cómo aparece y desaparece Pro sin candados; cómo se pide un permiso en el momento de uso; cómo se presenta una hoja y cómo se cierra; cómo se enseña un tip (TipKit) y cuándo no.
4. **Superficies del sistema**: especificación de Live Activity (los cuatro tamaños y el Night Mode), widgets (small/medium, accented, vibrant, StandBy), control de Centro de control (símbolos on/off, tinte en on), Watch (Smart Stack, app mínima, háptico de Marea), Focus filter.
5. **Guía de copy**: voz, tono, glosario ES/EN (incluido el vocabulario que el usuario usa de verdad: "de por vida", "temporizador", "mezcla", "tapar/bloquear el ruido"), las dos listas negras, y plantillas para notas de versión y textos de permisos.
6. **Kit de App Store**: icono final, diez capturas en es-ES, es-419 y en-US, guion y storyboard de la preview muda de 30 s, nombre y subtítulo de 30 caracteres por tienda, primera línea de descripción.
7. **Pantalla "Qué sabemos y qué no"**: plantilla tipográfica y las primeras entradas redactadas con el equipo de investigación.
8. **Checklist de aceptación** para QA de diseño: las doce pruebas de §4, los conteos de §8 y el recorrido del usuario gratuito del día 8.
9. **Fichero fuente** (Figma o equivalente) con los componentes en variantes, y una build de referencia SwiftUI de los cuatro componentes propios, compilable en iOS 17 con `#available` para iOS 26 donde haga falta.

---

## 10. Preguntas abiertas para el dueño

Las decisiones que condicionan el diseño y que el estudio no puede tomar solo. Pedimos respuesta antes de que los equipos de concepto empiecen la alta fidelidad.

1. **iOS mínimo del relanzamiento.** Las tres apps nativas premiadas en los ADA 2026 (Moonlitt, Tide Guide) y Dark Noise 3.6 exigen iOS 26. Mantener iOS 17 obliga a condicionar Liquid Glass y a diseñar dos navegaciones. ¿El relanzamiento high-end es iOS 26+ con una rama compatible para 17/18, o se diseña para 17 y se adopta 26 de forma progresiva? Nuestra recomendación: diseñar para 26 y degradar con dignidad.
2. **¿Solo oscura, o clara y oscura?** El producto es nocturno y la HIG admite la apariencia permanente para "immersive media"; pero el segmento 3 la usa de día para concentrarse y el PR #3 ya definió tokens claros con AA. ¿Aceptas una app solo-oscura (con variantes claras únicamente para el vidrio), o quieres un modo claro completo? Condiciona la paleta entera.
3. **El acento.** Hoy es ámbar cálido. Las alternativas serias son un índigo/teal nocturno (que se apaga bajo el rojo de StandBy) o "sin color": luz blanca cálida sobre negro. ¿Tienes una preferencia de temperatura, o nos dejas decidirlo por la prueba de StandBy y la de la tienda?
4. **El nombre.** "SleepNoise" es descriptivo y bueno para búsqueda, pero "noise" es exactamente la palabra que el usuario hispano no usa ("sonidos" 122 frente a "ruido" 20 en 1.197 reseñas) y que el posicionamiento ("instrumento", "nunca se repite") no necesita. ¿El nombre está cerrado, o el estudio puede proponer nombre y marca denominativa junto al icono?
5. **Precio y prueba, para diseñar el paywall de verdad.** El informe recomienda 29,99 $ / 29,99 €, con un precio de lanzamiento de 19,99 $ durante 2-4 semanas y Family Sharing desde el día uno; y convertir la prueba local en un non-consumable a 0 $ "7-Day Trial" con pantalla previa de duración, pérdidas y precio (guía 3.1.1), valorando 14 noches en vez de 7. ¿Qué cifra, qué duración y qué régimen de lanzamiento diseñamos? ¿Habrá descuento regional manual en México y LatAm?
6. **Qué queda gratis para siempre.** Hoy: blanco, rosa, marrón, lluvia y temporizador de 60 min, con las mezclas guardadas conservadas. La forma de enseñar Pro sin candados depende de que ese reparto sea estable. ¿Lo confirmas, o cambia con las texturas nuevas del PR #3?
7. **Alcance de la Marea en v1 del rediseño.** ¿Solo océano como ahora, o ya "Marea v2" en todas las texturas con lectura opcional de la frecuencia respiratoria de HealthKit? Condiciona la pantalla de la Marea y si hay que diseñar un flujo de permiso de Salud (solo lectura, y nunca como condición de Pro).
8. **Superficies de ecosistema en el primer lanzamiento.** Live Activity y Control Center parecen imprescindibles; ¿entran también widget de StandBy, app de Watch mínima con háptico de Marea y Focus filter en v1, o se diseñan ahora y se construyen en v2? El estudio los diseñará en cualquier caso; la pregunta es qué se promete en la ficha.
9. **Modo cuna.** Los padres son el mejor disparador de descarga y el único subsegmento que monetiza en el top 25 hispano, pero arrastran "ruido blanco" hacia la cuna y el precio mental hacia 0,99 $. ¿Diseñamos un modo cuna explícito (límite duro de volumen, aviso de distancia, retirada gradual) o renunciamos a esa keyword para proteger el posicionamiento adulto?
10. **Micrófono.** La guía de nivel y el enmascaramiento adaptativo encienden el punto naranja toda la noche y exigen un texto de permiso impecable en una app vendida como "no mira nada". ¿Está dentro del alcance de este rediseño, o fuera hasta medir batería y expectativas?
11. **Idioma de diseño.** ¿Diseñamos primero en español (es-ES y es-419 con fichas separadas, hueco real sin dueño en la categoría) y adaptamos a inglés, o al revés? Las longitudes de texto cambian la tipografía de los controles.
12. **Qué hacemos con el PR #3.** La revisión propone fusionar motor, modelo y Atajos (PR-A) y aparcar la capa de interfaz (PR-B) hasta este trabajo. ¿Confirmas que la rama de interfaz no se pule y que el rediseño parte de `main`?
13. **Icono y marca fuera de la app.** ¿Hay web, dominio o identidad previa que respetar, o el estudio parte de cero para icono, web "How it works" y kit de prensa?
14. **El jurado.** ¿Quieres estar en el jurado con voto, o recibir la recomendación del estudio con los tres conceptos y decidir después? Afecta a cómo preparamos la presentación de conceptos.

---

## Anexo A. Lectura del estado actual (lo que vimos)

Capturas de `main` (prueba de 7 días, español): la cabecera repite el nombre de la app en Title semibold con un subtítulo "Para la noche" que no informa; a la derecha, un icono de mezclas en verde-gris ("mist") y una cápsula "Prueba · 7 días" ámbar; debajo, una tarjeta de prueba de seis líneas que ocupa un cuarto de pantalla, con botón "Entendido" relleno; después, una tarjeta de Marea con toggle y, por fin, las capas como tarjetas de 18 pt de radio con icono en círculo, nombre semibold, descripción en caption, valor numérico y slider; barra inferior con "Temporizador" y "Guardar" como texto bajo icono y un play ámbar de 88 pt. Fondo 14,17,20 con degradado y resplandor ámbar radial cuando suena. Hojas de Temporizador, Marea y Mezclas con botón "Cerrar" en cápsula y título centrado; el temporizador en rejilla de botones 2×2 con "Personalizado" repetido como título y como botón; el reloj del temporizador en SF Rounded Light 44 pt. El vacío de "Mezclas guardadas" es un icono ámbar y una frase gris centrados.

Lo que ya está bien y hay que conservar: la frase "7 días con todo. Sin tarjeta." (es la respuesta exacta a la queja más repetida del mercado hispano); el texto de la Marea ("Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla."); la nota de fundido del temporizador; que el toggle de la Marea sea un toggle del sistema; los identificadores de accesibilidad; la lint de palabras médicas en el catálogo de cadenas.

Capturas del PR #3: play de 376 pt que invade la cabecera al hacer scroll, chip "Bedtime", fila de chips de presets, rejilla de once baldosas con borde ámbar en la activa, asa falsa "Levels" que abre una hoja con un segundo botón "Bedtime", fila "Timer", tarjeta de Marea y, por fin, los sliders. Pantalla Noche: negro real con reloj y cuenta atrás en gris muy oscuro (la intención correcta, el contraste incorrecto). En claro, fondo crema con baldosas blancas a 1,08:1 del fondo. Lo que vale del PR: la existencia de una pantalla de noche en negro puro, los presets de un toque como idea, los Atajos.

## Anexo B. Referencias que el estudio debe capturar antes de la alta fidelidad

Ningún informe pudo hacer capturas de las apps de referencia. El estudio debe capturarlas en dispositivo, en oscuridad y con StandBy, y pegarlas en el tablero: Dark Noise 3.6 (Now Playing en Liquid Glass y widget en StandBy nocturno), Sonidos de fondo de Apple en iOS 26 (ecualizador Broad/Focused, temporizador), Mindfulness/Breathe en Apple Watch con háptico Prominent, Moonlitt y Tide Guide (vidrio sobre contenido oscuro; la curva sinusoidal de marea con marcador del momento actual), Bear en tema oscuro con barra de vidrio, Things 3 (botón Magic Plus, "a hint of color shine through"), Endel en modo Sleep, paywalls de Endel, Balance y Portal (como lo que no hacer), y un Braun RT 20 o una radio Rams real sobre la mesa, no en foto.
