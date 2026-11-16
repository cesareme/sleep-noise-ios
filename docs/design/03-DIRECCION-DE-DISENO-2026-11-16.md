# SleepNoise · 03 · Dirección de diseño

**Dirección creativa del estudio · 16 de noviembre de 2026 · Documento 03 de la serie de diseño**

Cierra la fase de concepto y abre la de especificación. Insumos leídos completos: brief creativo (00), auditoría de referencias (01), materiales (02), resumen ejecutivo y §6 del informe de mercado, los cuatro conceptos con sus maquetas (`concepts/grafito.md`, `marea.md`, `dial.md`, `silencio.md`), los veinte veredictos del jurado (cinco lentes por concepto), las capturas de `main` y del PR #3, y el código de `main` donde los conceptos lo contradecían (`AccessPolicy.swift`: gratis = blanco, rosa, marrón, lluvia; ventilador y océano Pro; temporizador {15, 30, 60}; una mezcla guardada; Marea Pro. `SoundID.swift`: seis capas; no existe nivel maestro ni medidor RMS ni canal render → main).

`docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md` (el plan) existe y ya está reconciliado con este documento en `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (16-11-2026, 67 conflictos). Jurisdicciones (C01): el plan manda **qué, cuándo y cuánto** (alcance, matriz libre/Pro, precio, calendario); esta dirección manda **cómo** (carácter, tokens, componentes, arquitectura de pantalla, copy); el código veta lo que toque el hilo de audio. El inventario de §5 lleva ya el reparto de versiones de la reconciliación (§4 y §5 de ese documento); §12 de este documento lista cada delta aplicado. El carácter que fija este documento no depende del reparto.

Convenciones: medidas en puntos para 393 × 852 en tamaño Large; ratios WCAG 2.x sobre los hex indicados (los de 02 y de los conceptos, recalculados por los jurados); textos ES con EN entre corchetes; lo no verificado en dispositivo lleva **[a medir]**.

---

## 1. La decisión

### 1.1 Gana Grafito. Se construye sin Red Graphite.

**Grafito** es el concepto ganador (36,6 ponderado; primero o empatado en cuatro de las cinco lentes; solo Dial lo supera en la lente de las 3 de la mañana). Gana por lo que el jurado le reconoció de forma unánime y que ningún otro concepto tiene entero:

1. **Es el que más ha quitado sin perder función**, que es el criterio de desempate del brief: cero formas rellenas propias en la principal, Noche y paywall; cero iconos en el mezclador; cero candados; un único relleno transitorio (la pista bajo el dedo). Lo demostró en la maqueta, no en el texto.
2. **Su arquitectura es la más barata de construir y la más completa de producto**: fila = control, estado como palabra en versalitas, la prueba que termina en una sesión y no en un instante (coincide con `endPlayback(canDowngrade:)`), la capa Pro que conserva su nivel ("pro · 30"), "Sonando · sin trueno", el paywall con el precio en la primera línea, la Madrugada desde la Live Activity terminada, las interrupciones en dos palabras y una acción, el error de audio sin rojo, la tabla de cadenas ES/EN por clave, el Play alcanzable desde cualquier foco de VoiceOver (Magic Tap en la raíz, §4.4), la alternativa sin gesto para cada gesto. Cuatro jurados distintos lo llamaron "lo más escribible como tickets".
3. **Su voz es la de un objeto de 29,99 € una vez**: "prueba · quedan 5 noches", "Madrugada no enseña la hora a propósito" / "Small hours hides the clock on purpose", "Gracias. Todo abierto.", la captura 6 "Lo que no hay". El inglés está escrito, no traducido.

Y pierde, con la misma unanimidad, en **la capa de identidad**: el rojo (derivativo de Bear, código del electrocardiograma, color destructivo de iOS, muere bajo el modelo B de StandBy), New York (el look "editorial premium 2025" que 01 había limitado a una palabra), el Play trazado de 1,5 pt (un control sin peso), las hojas negras sobre negro, la regla que "escribe" como un sismógrafo (ECG otra vez, y físicamente falsa: el RMS del ruido es plano), y una Noche correcta pero genérica.

La lectura del estudio es que **todo lo que Grafito hace mal es sustituible sin tocar su estructura, y todo lo que los otros tres hacen mal es estructural**: Marea tiene una geometría fija de 393 × 852 que no cabe en un iPhone SE y un 1.1 (once capas) que rompe su propia tesis; Dial es un panel de medida (150 marcas, SF Mono, "gadget técnico") y su Regla "sobre Slider del sistema" no se puede construir como está escrita; Silencio esconde el instrumento tras dos dedos y tiene colisiones de gestos dentro de su propia especificación. Cambiar un color y una tipografía cuesta un día; cambiar una gramática de gestos o una retícula cuesta el concepto.

Por tanto: **Grafito es la página, la fila, la palabra, la prueba, el paywall, los flujos y el copy. Lo que se ve a tres metros se injerta de los otros tres.** El sistema resultante conserva el nombre de trabajo "Grafito" (el material, no el tema de Bear).

### 1.2 Lo que se le quita a Grafito, con nombre

| Se quita | Por qué (jurado) | Lo sustituye |
|---|---|---|
| El acento `grafito-rojo #E0524D` | Derivativo de Bear; ECG; destructivo en iOS; 1,69:1 bajo rojo B | El **Índice** de Dial (§3.1) bajo la **ley "color = sonido"** de Silencio |
| New York en nombre de mezcla, titular del paywall y lectura larga | Dos familias contra P5; look Ōura/Rise 2025; NY a 15-17 pt en widgets contra su propia regla | SF Pro en todo; el texto largo de "Qué sabemos" en SF Pro 17/26 |
| Play como triángulo trazado de 1,5 pt | Sin peso; invisible a brillo mínimo; "ghost" | El **Disco** de Dial (§4.4), el único botón con física |
| La regla del sonido que "escribe" de izquierda a derecha | ECG/sismógrafo; la maqueta dibuja una señal que el motor no produce; polilínea inventada en Live Activity | El **Horizonte** (§4.1): una línea quieta cuyo grosor y luz son el RMS real; sin historia, sin desplazamiento |
| Hojas negras sobre negro | Contra P3 y el atributo Material; indistinguibles con "Reducir transparencia" | Hojas en `hoja #1C1C1E` con `trazo-hoja` declarado (Marea) |
| Toque sobre la fila = silenciar (0 ↔ último) | Filas contiguas de 76 pt sin canal: un roce apaga la lluvia | El toque no hace nada; silenciar es arrastrar a 0 o acción de VoiceOver |
| Doble toque en Noche = Madrugada | Retrasa la pausa o arranca 20 min por error | Madrugada siempre es un botón (C27): "Madrugada · 20 min" en Noche terminada (en el hueco del "+15 min", que ya no significa nada), widget pequeño (00:00–06:00), pantalla de bloqueo, Siri/Atajos, Centro de control y botón de Acción; Watch en 1.2 |
| Botón primario de contorno rojo con radio 8 | El único radio de la app y el "ghost button" web de 2014 | La **palabra entre dos hairlines de 64 pt** de Silencio (§4.6) |
| "+15 min" en `texto2` 17 pt fijo en Noche | El control nocturno más usado a 7,5:1 y sin Dynamic Type | 20 Medium `texto`, escala con `.title3` |
| Estado "fundiendo" como regla en `trazo` | 1,47:1: invisible, indistinguible de "en pausa" | La palabra "fundiendo · 8 min" (estado por palabra, como "Se funde a las 03:42" de Marea) |
| "Altavoz" sustituyendo a "+15 min" en el mismo sitio | Dos acciones intercambiables en la misma posición (lección del Reloj de iOS 26) | "Seguir por el altavoz" como segunda línea encima; "+15 min" no se mueve |
| Toggle del sistema teñido en `texto2` | Parece deshabilitado; pista "off" a 1,53:1 | Toggle con `.tint(texto)`: pomo blanco sobre pista `texto` en *on*, pista del sistema en *off*; se lee por la posición del pomo. Nunca en `índice`: un índice por pantalla (§3.1 regla 2; resuelve 04 §9 #14 y 05 §9 #12 por la regla "quita más sin perder función") |
| "Noches" como nombre de las mezclas guardadas | Colisión Noche / noche / Noches en la misma barra; el usuario hispano dice "mezcla" | **"Mezclas"** ["Mixes"]; "noche" solo para la pantalla y el copy ("7 noches con todo") |
| "Las once capas" como primera línea del paywall | Cuatro ya son gratis: "nothing should appear more than it is"; además, los números en marketing envejecen (C04) | "Todas las texturas" ["All textures"], con la lista nombrada debajo y sin número; nunca se cuentan texturas en paywall ni ficha (C04) |
| "insomnio" y "ansiedad" en "Qué sabemos" | Lista negra clínica sin excepción, también en "Qué sabemos" (C54) | La población se nombra por el criterio de selección del estudio parafraseado, con n y cita: "n participantes con dificultad para dormirse, según X"; el diagnóstico solo en Notes for Review; "No tratamos nada; no es un producto sanitario" |
| "Descenso" como mezcla de serie y como ajuste de la Marea | Mismo nombre para dos cosas; "Descenso" queda reservado al ritual de Marea (C14) | La mezcla pasa a "Mar y viento" (C18); el ajuste, a "Empezar a 12 por minuto" (ritmo de partida, parámetro; C34) |
| Cabecera "gratis · blanco, rosa, marrón, lluvia y 60 min" para siempre | Recordatorio permanente de límite en el sitio del lujo | Desaparece tras 7 sesiones; la información queda en la hoja Pro y en Ajustes |
| Timbre "más cálido ◂ ▸ más lejano" bajo pulsación larga | DSP por capa que no existe en ninguna textura; el gesto muere con el eje vertical (C29, C52) | Una fila `LevelRule` "Timbre" (extremos "Grave" / "Lejos") al pie de Capas sobre el bus maestro, 1.0 condicionada al spike I0-7 (si falla, 1.1); timbre por capa en 1.1; la pulsación larga sobre una fila abre el `Slider` del sistema (alternativa sin gesto, C21) |

### 1.3 Lo que se injerta, con nombre y apellidos

**De Marea (equipo Marea):**
- **El horizonte como constante del sistema**: la línea del sonido vive siempre a un tercio de la altura de la pantalla (y = 284 en 852; proporcional en SE y en AX, nunca absoluto), en la principal, en Noche, en Madrugada y en la Live Activity escalada. El usuario sabe dónde mirar sin leer.
- **Las fases por luminancia, no por matiz** (Día → Noche → Madrugada → Retirada de Manto en 1.1; "Descenso" es el ritual de Marea, C14), corregidas: de noche hay **una sola tinta de texto** (`texto-noche`), porque `texto2` al 70 % cae a 4,0:1.
- **El estado de Noche en palabras**: "Se funde a las 03:42" / "En pausa" / "Fundiendo · 8 min" a 22 Medium, además del reloj.
- **La ola de la hoja Marea como indicador y control** (TP-7): arrastrar la línea de agua cambia el ritmo, `.selection` por entero, aplicado al siguiente ciclo.
- `hoja #1C1C1E` y el token `trazo-hoja` que faltaba.
- "La tienda no responde. Nada cambia: sigue sonando." / "No se ha podido completar. No se ha cobrado nada." y el precio "—" hasta que StoreKit responde.
- "Se ha retirado. El mar sigue." / "It has receded. The sea goes on." y la regla de que **la Marea nunca apaga una capa que ella encendió**.
- La guarda de 300 ms tras desbloquear y el toque boca abajo ignorado en Noche.
- Las secciones **"tuyas" / "de la casa"** en Mezclas y "Esta noche" ["Tonight"] como nombre de la mezcla viva.
- **La compra que se oye**: la capa Pro entra con fundido de 800 ms en el instante de comprar.
- **El instrumento siempre suena**: si la mezcla cargada es toda Pro, Play arranca Rosa a 40 y lo dice.

**De Dial (equipo Dial):**
- **La regla del Índice**: un solo elemento de color por pantalla, siempre en "lo vivo" (bajo el dedo → el nivel que se arrastra; si no, el horizonte mientras suena); nunca relleno de botón, nunca cuerpo de texto. Y su color: el **amarillo atemperado `#F0C020`** (12,27:1; 4,71:1 bajo rojo, el mejor del set), con `índice-noche #BA941C` y `ocre #8A6508` de día. Es el segundero de Lubs que el brief puso en la pared.
- **El Disco**: el Play como círculo en `grafito` con relieve de tecla de 1 pt y glifo `play.fill` en `texto`. El único botón con volumen de la app, como el Magic Plus de Things.
- "Lo que está a cero no suena ni gasta." / "What's at zero makes no sound and costs nothing."
- **Mezclas de la casa que describen y no prometen** (lista de C18, nunca textura+adjetivo): "Rosa y lluvia" (rosa + lluvia, libre), "Mar y viento" (océano + viento, Pro), "Marrón y hoguera" (marrón + hoguera, Pro), "Pared" (marrón + lluvia + viento, libre); nada de "Foco" ni "Sueño profundo"; los nombres por problema se deciden en 1.1 con dato. Si una receta incluye Pro, se carga recortada (como una mezcla guardada) y no abre paywall; nunca cambian el temporizador.
- **El título honesto de la mezcla recortada**: "Mar y viento · sin Océano" / "Sea and wind · without Ocean".
- **La prueba se evalúa solo al arrancar una sesión** (nunca a medianoche, nunca al reanudar tras una interrupción).
- **Dentro de la ventana de la mañana (05:00–11:00, o fin de Manto −60 min si hay Manto) ninguna interrupción reanuda** (la alarma del sistema, que no se distingue de otra interrupción, gana siempre); fuera de ella toda interrupción reanuda con fundido de 3 s y una llamada (`CXCallObserver`) nunca termina la sesión (C48).
- **Nunca reanudar sola por el altavoz**: al caer la ruta (AirPods fuera), fundido corto de 40 ms y pausa; "Seguir por el altavoz" visible 60 s; el toque reanuda capado a 0,4 solo si la ruta cambió ("Nivel bajado al 40 para el altavoz"); el `pauseCommand` con auriculares es un fundido de 3 s (C49).
- **De noche no se vende**: entre 21:00 y 07:00 (`NightWindow`) el toque en una capa Pro no abre hoja y no pasa nada más; no hay escucha de 30 s (1.1, C06) ni "línea matinal" al día siguiente (C08): `showPaywall` se consume sin cola.
- **"Controles visibles de noche"** (−15 · pausa · +15 de 64 pt) activados solos con Switch Control o AssistiveTouch.
- **La Digital Crown como nivel maestro** en el Watch (1.2, C28), con los detents del sistema; en 1.0 el reloj controla con el Reproduciendo del sistema.
- **La escalera del error de audio** y la única petición de la app: "Nos gustaría saberlo: Enviar informe" (ayuda, no valoración).

**De Silencio (equipo Silencio):**
- **La ley "color = sonido"**: el acento solo existe mientras el DSP produce audio (o mientras hay un dedo sobre un nivel) y desaparece en 1,5 s al parar; fuera de la app no existe; la única excepción es el botón de compra. El usuario aprende sin texto que el color significa algo.
- **El botón primario como palabra entre dos hairlines de 64 pt**, sin relleno ni radio; el secundario, la misma palabra en `texto2`.
- **El paywall "Una vez."** ["Once."] con las dos listas "Con Pro" / "Gratis siempre" y el acento en "Comprar" **solo cuando StoreKit ha devuelto el precio**.
- **Pro como descripción, no como etiqueta** en la línea de estado ("Sonando · sin océano") y en la fila de mezcla ("· trueno es Pro"); al guardar encima: "Guardada sin trueno · Conservar el trueno".
- **La Live Activity terminada que se queda** (estado "terminada", 20 min; sigue sonando hasta las 7 h 55, cuando la app la cierra por el límite de 8 h, C50) con el único botón de texto "Madrugada · 20 min" (C27) **[condicionado al spike I0-3: intents sobre actividad terminada]**.
- **"Nada cambia de posición jamás, solo de longitud, opacidad o contenido"** como regla de movimiento; la cifra de Noche cambia en seco; Reduce Motion casi no tiene trabajo.
- **El widget que siempre ofrece un verbo** ("Dormir" ["Sleep"]) en vez del nombre de la app.
- "Sin sonido" ["No sound"] como error en Noche, sin rojo; Magic Tap para reproducir/pausar.

**De los cuatro, como formato obligatorio de toda especificación:** la tabla de movimiento "elemento → señal del motor → duración/curva → Reduce Motion → Always-On" (M1…Mn), la tabla VoiceOver "etiqueta / valor / pista / rasgos / acciones" por control, la tabla "gesto → alternativa sin gesto → Control por botón → teclado", la tabla de Dynamic Type por tramo (xS-L · xL-xxxL · AX1-AX2 · AX3-AX5) y el catálogo de cadenas ES/EN por clave. Ninguna especificación se acepta sin las cinco.

### 1.4 Lo que ningún concepto resolvió y aquí se decide

- **El visual del sonido no tiene historia.** Los cuatro dibujaron una traza temporal (sismógrafo, horizonte que corre, banda de marcas, cápsula) y los cuatro jurados de alta gama leyeron ECG, cotizaciones, código de barras o barra de progreso. El medidor RMS de blanco/rosa/marrón con τ 400-800 ms es casi plano: una traza sería mentira o AGC. Decisión: **el Horizonte es una línea quieta cuyo grosor (1,5 → 3 pt; el mínimo que §3.1 admite para `índice`) y luminancia siguen el RMS maestro real.** La prueba de "nunca se repite" no es una animación: es la página "Cómo se genera", el tamaño en MB en Ajustes y un test de autocorrelación a 10 min en CI (C53). Lluvia, océano y trueno la hacen respirar; el ruido la deja casi quieta, y eso es verdad. Bajo pulsación larga se descompone en una línea por capa (la transparencia de Halide), cada una con su grosor por nivel.
- **Prolongar desde el bloqueo es un botón.** P2 exige +15 a ciegas desde la pantalla de bloqueo; la HIG prefiere un control. Decisión: la Live Activity de bloqueo lleva **dos** botones de 64 pt en posiciones fijas que nunca cambian de significado: pausa/play (con fundido de 3 s) y "+15 min" (vacío en Manto, C50). Es la única superficie del sistema con dos controles y se defiende con P2; en StandBy queda un solo control, pausa/play (C25). Live Activity recortada en 1.0 solo en el escenario A (dos parejas); en B, 1.1 (C25).
- **La Marea en Madrugada es para todos.** Tres conceptos la regalaban sin decirlo. Decisión declarada (C05): Madrugada es una receta fija, océano a nivel bajo con Marea a 8 por minuto para todos, también sin Pro; entrada de 3 s; la Marea se retira hacia el minuto 13; el mar funde durante los últimos 5 min; al terminar no pasa nada; nunca muestra prueba ni paywall. Son veinte minutos, es la mejor demostración de la función y nadie lee "pro" a las 3:40.
- **El reparto gratuito es el de `AccessPolicy` más cuatro cambios** (reconciliación §1 regla 3): cinco texturas libres (blanco, rosa, marrón, lluvia, viento) y seis Pro (océano, ventilador, trueno, hoguera, arroyo, cabina), con una lista libre que solo crece (C04); **temporizador entero libre** (dos modos, cualquier duración, fin como hora, "+15"; la palabra "pro" no aparece en el temporizador, C03); Marea Pro que suena para todos en Madrugada (C05); **tres** mezclas propias gratis (no una; `freeSavedMixLimit` 1 → 3; Pro sin límite).

---

## 2. La tesis

**ES.** SleepNoise es un instrumento de sueño, no una biblioteca de sonidos: cada noche fabrica en el propio iPhone un ruido que no se repite jamás, y la interfaz se ha diseñado para que eso se vea y para que después no haga falta mirarla. La pantalla es una página negra con una sola línea de horizonte que respira con el sonido real y un solo punto de color que marca lo que está vivo; las capas se ajustan arrastrando sobre su nombre, el temporizador se funde en vez de cortar, y la Marea respiratoria acompasa el oleaje a seis respiraciones por minuto antes de retirarse sola. A las tres de la mañana, toda la pantalla es el botón, el estado se lee en una palabra a un metro y la mesilla sigue a oscuras. Se prueba siete noches sin tarjeta, se compra una sola vez, no tiene cuenta, ni red, ni puntuación: lo que no hay es parte del diseño.

**EN.** SleepNoise is a sleep instrument, not a sound library: every night it generates, on the iPhone itself, a noise that never repeats, and the interface is designed so you can see that happen and then never need to look again. The screen is a black page with a single horizon line that breathes with the real sound and a single point of colour marking whatever is alive; layers are adjusted by dragging across their names, the timer fades instead of cutting, and the Breathing Tide paces the sea to six breaths a minute before receding on its own. At three in the morning the whole screen is the button, the state reads as one word from a metre away, and the nightstand stays dark. Seven nights to try, no card; pay once; no account, no network, no score: what isn't there is part of the design.

---

## 3. Tokens definitivos

Resuelven las contradicciones entre Grafito, 02-Materiales y los jurados. Donde un concepto y 02 chocaban, se dice quién gana.

### 3.1 Color nocturno

| Token | Hex | Sobre `negro` | Sobre `hoja` | Rojo A / B | Uso |
|---|---|---|---|---|---|
| `negro` | `#000000` | — | — | — | Fondo de la principal, Noche, Madrugada, Mezclas, Capas, Qué sabemos. Píxel apagado. |
| `hoja` | `#1C1C1E` | 1,23 | — | — | Fondo de hojas modales (Marea, Temporizador, Pro, Ajustes). 02 y tres jurados ganan a Grafito: es "otra habitación". Nunca en Noche ni Madrugada. |
| `grafito` | `#1E1D1B` | 1,25 | — | — | Único relieve: cuerpo del Disco y pista del nivel **mientras dura el arrastre**. Nunca tarjeta. |
| `trazo` | `#2A2A2E` | 1,47 | — | — | Hairline de 0,5 pt sobre `negro`. Decorativa. |
| `trazo-hoja` | `#38383B` | — | 1,46 | — | Hairline sobre `hoja` (el token que Marea usó sin declarar). |
| `texto` | `#E8E4DC` | **16,56** | 13,42 | **4,43 / 4,30** | Texto principal, cifras, glifos, horizonte sonando (cuando no es índice), línea de nivel llena. **Única tinta** en StandBy, Live Activity, widgets y Watch. Criterio (C62): ≥ 4,5:1 dentro de la app; fuera de la app (StandBy, bloqueo) texto ≥ 24 pt y ≥ 3:1 bajo rojo medido en dispositivo (spike I0-6); plan B: `#F0ECE4` si la medida queda por debajo de 3,5. |
| `texto2` | `#9C9A96` | **7,48** | 6,06 | 2,41 | Secundario, subtítulos, estado, notas, versalitas. Nunca fuera de la app. |
| `texto3` | `#6E6C68` | **4,01** | 3,25 | 1,66 | Solo no textual (pista vacía, marcas de pleamar/bajamar) o texto ≥ 18 pt. |
| `texto-noche` | `#A2A09A` | **8,03** | — | — | **La única tinta de texto** en Noche, Madrugada y la página nocturna (Grafito ponía `texto` al 70 %: `texto2` caía a 4,0). |
| `índice` | `#F0C020` | **12,27** | 9,84 | **4,71 / 5,0** | **El acento.** Solo en líneas ≥ 1,5 pt, glifos ≥ 3 pt y texto ≥ 18 pt. Nunca relleno, nunca cuerpo, nunca fuera de la app salvo el tinte *on* del Centro de control. |
| `índice-noche` | `#BA941C` | 7,34 | — | 3,09 | El índice en Noche/Madrugada/página nocturna: solo formas ≥ 2 pt (el nivel bajo el dedo). |
| `índice-ac` | `#FFD23C` | 14,54 | 11,66 | 5,25 | Variante "Aumentar contraste" (asset catalog). |
| `texto2-ac` / `texto3-ac` / `trazo-ac` | `#B4B2AE` / `#7A7672` / `#3A3836` | 9,92 / 4,66 / 1,8 | — | — | Variantes "Aumentar contraste". Las variantes AC de `texto-noche`, `índice-noche` y `trazo-hoja` son, por decisión, `texto2-ac`, `índice-ac` y `trazo-ac` (04 §9 #21: no se miden tres hex más). |
| `error` | — | — | — | — | **No existe un rojo.** El fallo de audio es una línea en `texto2` que es un botón (Grafito 10.12). El rojo del sistema solo aparece en la acción "Eliminar" de deslizar, que es del sistema. |

**Sobre el acento.** El Índice amarillo es la recomendación del estudio y el valor por defecto de los tokens (única decisión de color que sigue en manos del dueño: reconciliación §6 #1, plazo 27-11-2026, con la prueba de cinco segundos sobre la página real sonando en un iPhone en la mesilla a oscuras). El sistema es **agnóstico al matiz por construcción**: todo estado se lee por forma y por palabra, el acento nunca rellena nada y nunca sale de la app. Si el dueño prefiere el rojo grafito (`#E0524D`, 5,48:1) por parentesco con Bear, cambian tres entradas del asset catalog y nada más. `brasa #C9A27A` queda **descartado** como acento: es el color más compartido de la categoría (Hatch, Calm cálido, Halide, la app actual) y el peor de los tres bajo rojo (3,48). Prueba de cinco segundos con diez personas ajenas en la primera semana de especificación: "¿qué pasa en esta pantalla?"; si más de dos dicen "aviso" o "algo va mal", se baja la saturación a `#E6BC3A` antes de cambiar de matiz.

**Reglas transversales de color** (las de 02 §2.3 más las que fijan los injertos):
1. **Color = sonido o dedo.** Hay índice cuando el motor produce audio (el horizonte) o cuando un dedo arrastra un nivel (la línea bajo el dedo, y entonces el horizonte pasa a `texto` mientras dura el gesto). En reposo y sin dedo, la principal no tiene color. Única excepción: las dos hairlines de 1,5 pt del botón "Comprar", y solo cuando hay precio.
2. **Un índice por pantalla**, siempre en lo vivo (Dial §3.0). El Play nunca lleva color. El Toggle de la Marea tampoco (`.tint(texto)`, §4.12); el `Slider` por pulsación larga tampoco.
3. **De noche, una tinta de texto** (`texto-noche`), hairlines en `trazo`, índice solo bajo el dedo.
4. **Fuera de la app, una tinta** (`texto`), formas ≥ 2 pt, estado por forma (`play.fill` / `pause.fill`; línea continua = suena, ausente = pausa). Se diseña primero en rojo.
5. Negro + tres grises + un acento por pantalla; nada más, nunca.

### 3.2 Fases de la noche (luminancia, no matiz)

| Fase | Cuándo | Texto | Índice | Qué hay |
|---|---|---|---|---|
| **Día** (`.day`) | App delante, antes de acostarse, y de día ("Descenso" es solo el ritual de Marea, C14) | `texto` / `texto2` / `texto3` | `índice` | La página completa |
| **Noche** | Pantalla Noche | `texto-noche` | `índice-noche` (solo bajo el dedo) | Horizonte, reloj, estado, "+15 min" |
| **Página nocturna** | Estado de tinta **por procedencia**: al volver de Noche; dura toda la sesión (toda entrada posterior a la página esa noche nace nocturna); sin salida por reloj (C40) | `texto-noche` para todo el texto; `texto3` para pistas | `índice-noche` | La página con una tinta; vuelve a Día al tocar el nombre de la mezcla (salida deliberada; no a las 07:00) |
| **Madrugada** | 20 min desde el botón "Madrugada · 20 min" (C27) | `texto-noche` (una sola tinta, sin ámbar, C60) | — | Horizonte (o línea de agua) y "20 min"; "Se retira · n min" los últimos 5; al terminar no pasa nada |
| **Retirada de Manto** (1.1) | Últimos 15-30 min del Manto (C36) | sube de `texto-noche` a `texto` en 15-30 min, con el fundido largo | — | El amanecer es luminancia, nunca naranja; "Amanecer acústico" en 2.0 o por demanda; en 1.0 Madrugada no tiene retirada luminosa (C60) |

Transición entre fases: 2 s de opacidad (250 ms con Reduce Motion). Una sola constante horaria para toda la app: `NightWindow` = 21:00–07:00 (tips, venta y reseña; C40); la ventana de la mañana de las interrupciones (05:00–11:00 o fin de Manto −60 min) es otra regla, no otra constante de fase (C48).

### 3.3 Día ("papel")

**1.1** (C32): 1.0 es solo oscura (`preferredColorScheme(.dark)` en la raíz); "Papel" llega en 1.1 junto con "Debajo de otro audio" y sigue entonces la apariencia del sistema, sin selector propio (HIG). Noche, Madrugada y la página nocturna son siempre negras. Los tokens quedan definidos aquí y en 04 marcados 1.1 (sus variantes High Contrast y el hex aplanado de `hoja-papel`, 04 §9 #22-23, se miden en 1.1):

| Token | Hex | Ratio sobre `papel` | Uso |
|---|---|---|---|
| `papel` | `#F3F0E9` | — | Fondo |
| `tinta` | `#1E1C19` | 14,94 | Texto principal |
| `tinta2` | `#5F5A53` | 6,00 | Secundario |
| `tinta3` | `#9C958A` | 2,61 | Solo pistas vacías (componentes que deban cumplir 3:1 usan `tinta2`) |
| `ocre` | `#8A6508` | 4,68 | El índice de día (el amarillo sobre papel da 1,5:1) |
| `trazo-papel` | `#D8D3C9` | 1,31 | Hairline |
| `pulsado-papel` / `hoja-papel` | `#E9E5DC` / `#FFFFFF` al 60 % sobre papel | — | Relieve del Disco; hojas del sistema |

### 3.4 Tipografía

**Una familia: SF Pro.** Text/Display automáticos. Sin New York (ni en el nombre de la mezcla, ni en el paywall, ni en la lectura larga), sin SF Mono (las lecturas técnicas bajo pulsación larga van en SF Pro Medium tabular), sin SF Pro Rounded (el código tipográfico del bienestar; a 72 pt la Display ya es suave). Versalitas reales (`.smallCaps()`), nunca `uppercased()`. Cifras siempre `monospacedDigit()`.

| Paso | Uso | Peso | pt / interlineado (Large) | `relativeTo` | De noche | Color |
|---|---|---|---|---|---|---|
| 1 · Cifra | Reloj de Noche, "20 min" de Madrugada, cuenta atrás, precio | Display Regular, tracking −1 % | 72 / 80 (Noche); 56 / 64 (precio, temporizador) | `.largeTitle`, tope `.accessibility2` | Regular (≥ 20 pt) | `texto` / `texto-noche` |
| 2 · Nombre | Nombre de la mezcla en la principal; titular del paywall | Display Medium | 28 / 34 | `.title1` | — | `texto` |
| 3 · Cabecera | Título de hoja y de pantalla empujada; estado de Noche | Semibold (hoja) / Medium (Noche) | 22 / 28 | `.title2` | Medium | `texto` / `texto-noche` |
| 4 · Acción nocturna | "+15 min", "Volver", "Parar" en Noche y Madrugada | Medium | 20 / 25 | `.title3` | Medium | `texto-noche` |
| 5 · Fila | Nombre de capa, nombre de ajuste, nombre de mezcla guardada, botón primario | Semibold | 17 / 22 | `.headline` | Semibold | `texto` |
| 6 · Cuerpo | Frases de una línea, paywall, "Qué sabemos" (17 / 26 en lectura larga), botón secundario | Regular | 17 / 22 | `.body` | Medium | `texto` / `texto2` |
| 7 · Secundario | Subtítulo de capa, línea de estado, receta de una mezcla | Regular | 15 / 20 | `.subheadline` | Medium | `texto2` |
| 8 · Nota | Pies, notas de temporizador, "no es un producto sanitario" | Regular | 13 / 18 | `.footnote` | Medium | `texto2` |
| 9 · Dato | Valor de nivel, minutos junto al control; versalitas de estado (tracking +2 %) | Medium tabular | 13 / 18 | `.footnote` | Medium | `texto2` (`texto` si ≥ 18 pt) |

Reglas: nada < 13 pt; nada < Medium sobre negro de noche; Regular solo ≥ 20 pt de noche; Light, Thin y Bold, nunca; nueve pasos en la escala, ≤ 6 estilos por pantalla y la principal ≤ 4 en reposo (2, 5, 7, 9); 17 Medium (barra, valor bajo el dedo) cuenta como estilo propio (C67); jerarquía título > filas por tamaño (28 frente a 17). Versalitas nunca por debajo de 13 pt y nunca para datos que se consulten de noche (la hora de retirada de la Marea va en el paso 7, no en versalitas). Dynamic Type xSmall → AX5 con `ViewThatFits` en filas desde AX1; la cifra de Noche escala hasta AX2; `minimumScaleFactor(0.8)` solo en nombres de mezcla escritos por el usuario.

### 3.5 Espaciado, hairline, radios, relieve

- Retícula de 4 pt: 4 / 8 / 12 / 16 / 20 / 24 / 32 / 56 / 64 / 80. Margen lateral **20 pt** (columna de 353 en 393; 335 en 375).
- **El horizonte a un tercio**: y = altura × 0,333 **medida sobre la pantalla completa** (área segura incluida; el usuario ve la pantalla entera), redondeada al múltiplo de 4 más próximo: 284 en 852, 280 en 844, 224 en 667; la misma cota que §1.3 (se corrige aquí la redacción "bajo el área segura", que daba ≈ 323: 04 §9 #15). Toda pantalla que lo lleve; en AX se ancla a 24 pt bajo la cabecera. La banda del horizonte mide 24 pt, o 120 pt **siempre que la mezcla cargada tenga Marea disponible** (no crece al activarla: nada cambia de posición, §3.7; 04 §9 #19).
- Filas: lista 56; fila con subtítulo 72; **fila de capa 80 de paso = 56 de área táctil + 24 de canal muerto** (P8: 24 pt entre objetivos sin borde). Grupos a 32 pt, el doble del aire interno (16).
- **Hairline 0,5 pt** (`1 / displayScale`), `trazo` sobre negro, `trazo-hoja` sobre hoja, de margen a margen. Único separador.
- **Radios: 0 en todo lo propio.** Solo el radio del sistema en hojas, Live Activity y widgets, y el círculo del Disco.
- **Relieve: solo el Disco** (`grafito` + sombra interior 1 pt `negro` al 60 %, la tecla del ET66) y la pista `grafito` de 44 pt bajo el dedo. Nada más tiene volumen. Sin sombras exteriores, sin degradados, sin materiales propios.
- Objetivos: ≥ 44 × 44; **64** en Play, "+15 min", acciones de Noche y botones de la Live Activity; pantalla completa en Noche y Madrugada; ≥ 24 entre objetivos sin borde; nada esencial en la esquina superior.

### 3.6 Iconografía

- **Cero iconos** en la principal y en el mezclador fuera de la barra: las palabras son los iconos; subtítulos honestos ("lejano, sin rayos cerca" / "far off, no close strikes").
- SF Symbols monocromos, peso heredado (Medium de noche), estado por variante (`.fill` = activo), `.contentTransition(.symbolEffect(.replace))` en play ↔ pause. Barra: solo `play.fill` / `pause.fill`; "Mezclas" y "Noche" son palabras (17 Medium); en AX4-AX5 pasan a `square.stack` y `circle.lefthalf.filled` con etiqueta accesible. **Nunca una luna.**
- Símbolos propios (plantilla SF Symbols, 9 pesos, 3 escalas): **la línea de agua** (horizontal con elevación 4:6; glifo de la Marea, del Centro de control "Madrugada", de la complicación), **las tres pendientes espectrales** (blanco 0 dB/oct, rosa −3, marrón −6; glifo del toggle del Centro de control y de los Atajos), **arroyo** (ondulada simple). Trazo 1,5 pt a 17 pt. Sin `lock`, `crown`, `checkmark.seal`, `gift`, `hourglass`.
- `symbolEffect`: solo `.pulse` en el glifo de pausa durante el fundido final (apagado con Reduce Motion). Prohibidos `.bounce`, `.breathe`, `.wiggle`, `.rotate`.

### 3.7 Movimiento

Se adopta 02 §3 íntegro (tres causas: respiración, fundido, nivel; sin springs; Core Animation para lo finito; `TimelineView` + `Canvas` aislado y pausable solo para horizonte y línea de agua). Lo que fija esta dirección:

| Regla | Valor |
|---|---|
| Causa | Nada se mueve sin señal del motor o sin dedo; la tabla M1…Mn de cada especificación nombra la señal |
| Posición | **Nada cambia de posición jamás**: solo longitud, grosor, opacidad o contenido (Silencio). Las hojas y la navegación son del sistema |
| Controles | 200-250 ms `.easeInOut` o `.smooth`; nunca `.bouncy` / `.snappy` |
| Arranque | 800 ms `.easeOut`, igual que la ganancia; el horizonte nace de la hairline |
| Parada / fin | 1,5-2 s `.easeInOut`; interrupción por llamada 300 ms; caída de ruta (AirPods fuera) 40 ms de audio y pausa / 2 s de interfaz; `pauseCommand` con auriculares 3 s (C49) |
| Horizonte | RMS maestro, 20 Hz, τ 500 ms; grosor 1,5 → 3 pt y opacidad 0,6 → 1,0 (suelo 0,6: el 0,45 de Silencio bajaba a 2,4:1); Reduce Motion: 4 Hz, τ 1,5 s; `isLuminanceReduced` / Noche / fondo / hoja encima: congelado a hairline en ≤ 2 s |
| Línea de agua | `BreathCurve` del motor con ancla `guide.anchor` + `outputLatency` (nunca `sin()`); 7,5-15 s por ciclo, 4:6; reutiliza el `TimelineView` a 30 Hz pausable del `BreathIndicator` actual (se descarta `KeyframeAnimator`); Reduce Motion: posición fija a media banda, opacidad 0,6 → 1,0 con la misma curva |
| Página ↔ Noche | 2 s opacidad (250 ms con Reduce Motion) |
| Cifra de Noche | Cambio seco por minuto; `Text(.time)` a 1 Hz; `.numericText()` solo al tocar "+15 min" |
| Límite | Ninguna animación finita > 2 s; ninguna infinita que no sea el sonido; 0 fotogramas con la pantalla apagada; ningún píxel cambia de luminancia > 3 veces/s (τ ≥ 300 ms) |
| Presupuesto | La interfaz ≤ 30 % del coste del motor con pantalla encendida (Instruments: Energy Log + Time Profiler); 10 min bloqueado sin actividad periódica salvo el audio |

### 3.8 Háptica

02 §4 íntegro, con estas precisiones de los jurados:

| Momento | iPhone | Watch (1.2, C28) | Anuncio VoiceOver |
|---|---|---|---|
| Play (página) | `.impact(.medium, 0.7)` al inicio del fundido | `.start` | "Sonando" |
| Pausa (página) | `.impact(.light, 0.5)` | `.stop` | "En pausa" |
| Nivel: cruzar 0 / llegar a 100 / pasos | `.selection` / `.impact(.light, 0.6)` / nada | detents de la corona | valor hablado |
| Toque en Noche o Madrugada | **ninguna**: lo confirma el sonido | `.click` | estado |
| "+15 min" | `.selection` **solo de día** (puerta por fase: de noche nunca vibra; sin CoreMotion en producción 1.0, C35) | `.click` | "Quedan 53 minutos" |
| Pulsación larga en Noche (volver) | `.impact(.light, 0.4)` al cumplirse 0,6 s | — | "Página" |
| Marea "Mínima" (opt-in) | Core Haptics continuo siguiendo `BreathCurve`, 3-5 respiraciones, solo si se activa en la hoja Marea; motor `playsHapticsOnly`, destruido al terminar; de noche (fase Noche) nunca (C35). "Marcada" (transitorio por inhalación toda la guía) se va al Watch | `.directionUp` por inhalación toda la guía (1.2) | opcional "inhala" / "exhala" |
| Guardar mezcla / compra | `.success` | — | "Guardada" / "Gracias. Todo abierto." |
| Fallo de compra | `.error` solo con la hoja Pro delante | — | texto del fallo |
| Fin de temporizador, fin de Marea, fin de prueba, error de audio, abrir el paywall, enseñar el precio | **ninguna** | ninguna | anuncio de la línea de estado |

Regla de silencio: la puerta de la háptica es **por fase** (`MotionGate.allows(phase) = !phase.isNight`): de noche nunca vibra; sin CoreMotion en producción 1.0 (el spike I0-5 queda como investigación; de día la háptica no sabe si el teléfono está en la mano, coste aceptado en C35); "Háptica del sistema" desactivada = nada; en segundo plano, nada.

---

## 4. Sistema de componentes definitivo

Convención: estados **normal · activo · bloqueado-Pro (sin castigo) · prueba · deshabilitado · VoiceOver**. Seis componentes propios; el resto, sistema con estilo.

### Propios

**4.1 Horizonte (`SoundLine`)** · el visual del sonido. Línea de margen a margen a un tercio de la pantalla, en una banda de 24 pt.
- Normal (reposo): hairline `trazo`, quieta. El silencio dibujado; en la tienda es verdad.
- Activo (sonando): `índice`, grosor 1,5 → 3 pt (errata corregida: §3.1 solo admite `índice` en líneas ≥ 1,5 pt; 05 §9 #6) y opacidad 0,6 → 1,0 por RMS maestro; nace de la hairline en 800 ms. Si un dedo arrastra un nivel, pasa a `texto` mientras dura el gesto (un índice por pantalla).
- Fundiendo: grosor y opacidad bajan con la ganancia real hasta la hairline en 1,5-2 s.
- Marea disponible en la mezcla cargada: la banda es de 120 pt desde el principio (no crece al activarla; 04 §9 #19); al encender la Marea aparecen las marcas y la línea **es** la línea de agua (4.3). Nada de lo de debajo cambia de sitio.
- Pulsación larga: se descompone en una línea por capa (hasta 11, grosor por nivel, `texto` con opacidad por RMS de esa capa), 400 ms; se recompone al soltar. Las sublíneas son decorativas para VoiceOver (C63).
- Noche / Madrugada: 2 pt `texto-noche`, estática, **continua = suena, ausente = pausa**; nunca escribe. En Noche el estado accesible vive en el `FullScreenControl` (4.5), no en el horizonte.
- Live Activity / StandBy / widget: estática, 2-3 pt `texto`, grosor = nivel maestro al emitir; continua / ausente.
- Bloqueado-Pro / prueba / deshabilitado: no aplica (el sonido nunca se bloquea).
- VoiceOver (C63): un elemento de estado, etiqueta "Sonido", valor "Sonando, nivel medio" / "En silencio" con histéresis de 3 s (para que no parlotee), acción "Ver capas por separado" (la descomposición). Sin `AXChartDescriptor` ni rotor Audio Graph: el Horizonte comunica estado, no datos. Magic Tap en la raíz = play/pausa.
- Prueba del nueve: si se silencia el motor, vuelve a hairline en < 1 s porque lee el motor, no un reloj.

**4.2 Regla de nivel (`LevelRule`)** · la fila es el control. Nombre (paso 5) + subtítulo (paso 7) + valor (paso 9) + línea de nivel de margen a margen a 12 pt del borde inferior: parte llena 2 pt `texto`, resto 1 pt `texto3`. Paso de fila 80 (56 táctiles + 24 de canal).
- Normal (nivel > 0): como arriba; valor "65".
- Normal (nivel 0): solo pista `texto3`; nombre en `texto`; valor oculto. **El toque no hace nada.**
- Activo (bajo el dedo): línea 3 pt `índice` (`índice-noche` de noche); pista `grafito` de 44 pt visible mientras dura el gesto; valor crece a 17 pt `texto` tabular a la derecha, en su sitio (nunca flotando sobre el dedo); `.selection` al cruzar 0, `.impact(.light)` al llegar a 100. **Arrastre relativo** (delta), `minimumDistance` 8 pt, bloqueo de eje a 30°; 1 pt = 1/333 del recorrido. El horizonte pasa a `texto` mientras tanto.
- Pulsación larga (0,6 s): un `Slider` del sistema de 44 pt con el mismo valor **sustituye a la línea en su sitio** (nada cambia de posición, §3.7; 05 §9 #3), en `.tint(texto)`, y se retira a los 5 s sin dedo encima; es la alternativa sin gesto (Button Shapes, Switch Control) y el ajuste fino (C21). Nada más: el timbre no es un gesto, es la fila "Timbre" al pie de Capas (C29).
- Bloqueado-Pro: nombre `texto2`, pista completa `texto3`, "pro" en versalitas `texto2` donde iría el valor ("pro · 30" si conserva nivel guardado; el nivel se conserva siempre, el motor lo ignora sin acceso y la degradación nunca escribe en disco, C23). Arrastrar no mueve nada; **tocar abre la hoja Pro** ("Empezar la prueba · 7 noches" / "Comprar", C06); entre 21:00 y 07:00 el toque no abre nada y no pasa nada más (C08). La escucha de 30 s pasa a 1.1 y, cuando llegue, no abrirá hoja sola.
- Prueba: idéntica a Normal.
- Deshabilitado: no existe.
- VoiceOver: `.adjustable`, pasos del 5 %, acciones "Silenciar" / "Máximo"; Pro: "Trueno, requiere Pro, botón; toca dos veces para ver Pro" (de noche, "Trueno, requiere Pro" sin acción).
- Fila "Timbre" (C29): la misma `LevelRule` al pie de Capas, extremos "Grave" / "Lejos" ["Deep" / "Far"] en lugar de valor; actúa sobre el bus maestro; 1.0 condicionada al spike I0-7 (semana 2) con puerta en la semana 4–6; si no llega, cae a 1.1 sin discusión.
- AX1+: nombre arriba, valor debajo, línea debajo; fila de 96-112.

**4.3 Línea de agua (`TideLine`)** · la forma de la Marea. Nunca un círculo. Línea horizontal que sube 4 s y baja 6 s dentro de una banda de 120 pt entre dos marcas hairline `texto3` (pleamar / bajamar), con la `BreathCurve` del motor.
- Apagada: no se dibuja (el horizonte ocupa su sitio); en la fila, toggle del sistema en off.
- Guiando: línea 2 pt `índice` en la principal, 2 pt `texto` en la hoja (en la hoja es también control: **arrastrar la línea cambia el ritmo**, 4-8 por minuto, `.selection` por entero, aplicado al siguiente ciclo); palabra "inhala" / "exhala" en paso 7 a la derecha durante las tres primeras respiraciones; versalita de estado "guiando · 6 por minuto" y, en paso 7, "se retira a las 23:27".
- Disolviendo: amplitud → 0 durante el último 20 % de la duración; "disolviendo"; al terminar, 2 s en bajamar y vuelve a ser el horizonte; nota 10 s "Se ha retirado. El mar sigue." / "It has receded. The sea goes on." Si se apaga a mano, la disolución dura 30 s, nunca es un corte.
- Bloqueado-Pro: el toggle abre la hoja Pro sin guiar (C06); de noche no abre nada (C08); en Madrugada la Marea guía para todos a 8 por minuto, sin control, y se retira hacia el minuto 13 (C05). Marea 1.0 = `bedDepth` sobre todas las camas + ritual (bajada 12 → 6, meseta, disolución) + toggle; ritmo de partida "Empezar a 12 por minuto" (parámetro, C34); gestos por textura en 1.1; Salud en 2.0; "v1/v2" no aparece en la interfaz (C24). "Solo oleaje" no es un estado (C59).
- Reduce Motion: posición fija a media banda; opacidad respira 0,6 → 1,0 con la misma curva.
- Noche: no se dibuja (la guía está en el oído y, si se pidió, en la mano o la muñeca); Madrugada: 1,5 pt `texto-noche` si hay Marea; `isLuminanceReduced`: quieta en bajamar.
- VoiceOver: "Marea, inhala, seis por minuto, se retira en doce minutos"; `.adjustable` en la hoja (ritmo), valor hablado "{n} por minuto" (C59).

**4.4 Disco (`PlayDisc`)** · el único botón con física. Círculo de 44 pt en `grafito` con sombra interior de 1 pt, glifo `play.fill` / `pause.fill` 22 pt `texto`; área táctil 64 × 64; centro de la barra inferior. En iOS 26 el sistema lo envuelve en vidrio y el relieve se sustituye por el vidrio (único `#available(iOS 26)` del proyecto, en `PrimaryActionStyle`). Nunca lleva color.
- Normal: play. Activo (sonando): pause. Pulsado: sombra interior 2 pt durante 200 ms. Durante el fundido final: `.pulse`. Deshabilitado: nunca. Noche y Madrugada: no existe; la pantalla es el botón.
- VoiceOver: "Reproducir" / "Pausar", `.startsMediaSession`. No puede ser el primero en el orden (la barra inferior se lee después del contenido; 04 §9 #17): lo que lo hace alcanzable desde cualquier foco es Magic Tap en la raíz de la página (C63).
- Vidrio: el del sistema en barras y hojas se acepta; sin `glassEffect` en contenido; sin control teñido; la "rama visual iOS 26" queda vacía y la app se ve igual en iOS 17 y 26 salvo el Disco (C66).

**4.5 Pantalla como botón (`FullScreenControl`)** · Noche y Madrugada. Anatomía fija (C47): reloj 72 ocultable, palabra de estado, pantalla-botón, "+15 min" fijo. Toque = pausa / reanuda (guarda de 300 ms tras desbloquear; ignorado boca abajo). Arrastre vertical = **nivel maestro de sesión** (`master` con rampa en `EngineCommand`; no persiste; nunca toca el volumen del sistema; estado "Sonando · al 40"; C51): regla vertical de 1 pt `texto-noche` de 200 pt a la derecha mientras dura; botones físicos como alternativa. Pulsación larga 0,6 s = volver (Noche) / nada (Madrugada). "+15 min" = botón de texto de 64 pt a todo el ancho en la parte baja (Noche), **solo si hay temporizador**: Noche nunca crea uno (`extend(by:)` sobre uno existente; si no lo hay, el hueco está vacío); cuando Noche ha terminado, ese hueco lo ocupa "Madrugada · 20 min" (C27). "Parar" en Madrugada (se mantiene frente a "+10 min", 04 §9 #5: parar es una función y la Isla expandida que daba casa a "+10" ya no existe, C25). Ningún gesto horizontal, ningún doble toque. Noche entra al bloquear por defecto, con opción 1 / 3 min solo desde la página; duerme por defecto (`isIdleTimerDisabled = false`), ajuste "Mantener encendida: mientras carga (defecto) / siempre / nunca", y se atenúa a los 60 s mientras está encendida; "atenuada" no es un estado (C46, C47). Alternativas: elemento único de VoiceOver con acciones ("Añadir quince minutos", "Volumen", "Volver"); "Controles visibles de noche" (−15 · pausa · +15 de 64 pt) activados solos bajo Switch Control, AssistiveTouch o a mano; Acceso asistido con disposición de un botón (1.1, C39).

**4.6 Acción primaria (`HairlineAction`)** · palabra 17 Semibold `texto` centrada en una fila de 64 pt a todo el ancho entre dos hairlines. "Comprar · {displayPrice}", "Empezar la prueba · 7 noches", "Guardar". Una por pantalla. Los números que se enseñan son los del código (`displayPrice`, `displayName`), nunca constantes de copy.
- Normal: hairlines `trazo-hoja`. **Comprar con precio cargado: hairlines de 1,5 pt `índice`** (el único borde de acento de la app es el del único botón que cuesta dinero; 1,5 pt es el mínimo que §3.1 admite para `índice`: 04 §9 #16). Pulsado: opacidad 0,6, 200 ms. Deshabilitado (StoreKit sin producto): texto `texto3`, hairlines `trazo-hoja`, debajo "La tienda no responde. Nada cambia: sigue sonando." En curso: "Comprando…" / "Buscando…" como texto, sin spinner. Button Shapes: subrayado del sistema.
- VoiceOver: "Comprar {displayName} por {displayPrice}, botón. Un solo pago."

### Sistema con estilo

**4.7 Fila editorial (`EditorialRow`)** · `List` del sistema. Texto a la izquierda, valor / estado a la derecha, hairline de margen a margen. 56 / 72. Pulsada: `grafito` 200 ms. Activa en lista de opciones: `checkmark` del sistema en `texto`. Bloqueado-Pro: nombre `texto2` + "pro" versalitas; al tocar abre la hoja Pro (C06); de noche no abre nada (C08). El temporizador no tiene filas Pro: es entero libre (C03). Deshabilitada: texto `texto3` solo si ≥ 18 pt; si no, se oculta.

**4.8 Palabra de estado (`StateWord`)** · es un `Text` en versalitas paso 9 `texto2`, tracking +2 %. "prueba · quedan 5 noches", "pro", "pro · 30", "guiando · 6 por minuto", "disolviendo", "en pausa". Nunca fondo, nunca color. Nunca para un dato que se consulte de noche.

**4.9 Acción secundaria (`TextAction`)** · `Button` `.borderless`, 17 Regular `texto2` (Medium de noche): "Restaurar compra", "Entendido", "Ahora no". 44 pt; 64 de noche.

**4.10 Hoja** · `.sheet` del sistema, `presentationBackground(hoja)`, indicador real, **sin botón Cerrar** en ninguna versión (iOS 26 tampoco lo añade solo: se cierra con el gesto, el indicador, el escape en Z y Control por voz; 04 §9 #18); cabecera paso 3 a la izquierda a 20 pt + hairline; detents `.medium` (Temporizador) / `.large` (Marea, Pro, Mezclas, Capas). Capas es hoja `.large` (no pantalla empujada: evita el gesto de volver desde el borde izquierdo sobre las filas que se arrastran) y es la única hoja **sobre `negro`**, con hairlines `trazo`: comparte fondo con la página porque hace lo mismo que la página (§3.1 la lista bajo `negro`; una hoja gris encendería toda la pantalla, P3; resuelve 05 §9 #4).

**4.11 Barra inferior** · `ToolbarItemGroup(placement: .bottomBar)`: "Mezclas" (17 Medium) · Disco · "Noche" (17 Medium). Vidrio del sistema en iOS 26; material `.bar` + hairline en 17/18. Siempre presente en la página y en Capas (nada bloquea el sonido). Sin tintes salvo el que el sistema ponga al Disco en 26.

**4.12 Toggle, Picker, DatePicker, TextField, contextMenu, TipKit** · del sistema. Toggle con `.tint(texto)` (nunca `índice`: §1.2 y §3.1 regla 2). TipKit: un solo tip en toda la app (el segundo arrastre, solo de día), `maxDisplayCount = 1`, `.tipBackground(.clear)`, sin imagen ni flecha, una línea paso 7; ningún tip entre las 21:00 y las 07:00 (`NightWindow`, C40); las dos frases de Noche son texto fijo de la pantalla, no tips; ninguno durante la Marea; la lista queda cerrada (C65).

**4.13 Live Activity, Dynamic Island, StandBy, widgets, Control, Watch** · del sistema, con la gramática de §3.1 regla 4 y las decisiones de §5.

---

## 5. Inventario de pantallas y superficies

Reparto de versiones según la reconciliación (§4 y §5 de `RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`; columna "V"). Especificadores en §8. Cada línea es la intención (P10: la pregunta a la que responde). Inventario cerrado (C38): entran "Cómo se genera", "Lo que no hay", el recibo y Now Playing (#31-34); no hay gesto de timbre, ranuras, selector de textura, panel "ahora mismo", botón AX ni carta Novedades (1.1); la web es de E8, posterior.

| # | Superficie | V | Intención (una línea) | Esp. |
|---|---|---|---|---|
| 1 | **Página principal** · reposo | 1.0 | "¿Qué va a sonar?": nombre de la mezcla (28), horizonte en hairline a un tercio, las capas que suenan como filas-control (máx. 3; "y 2 más"), "Todas las capas", Marea con toggle, Temporizador con estado, barra. Sin título de app, sin logo. | E2 |
| 2 | Página principal · sonando / con Marea / en pausa / fundiendo | 1.0 | "Esto se está fabricando ahora": el horizonte en índice respira con el RMS; con Marea, la banda crece a 120 y es la línea de agua; la línea de estado dice lo que pasa y lo que falta ("Sonando · sin trueno"). | E2 |
| 3 | Página nocturna (estado de tinta por procedencia: al volver de Noche; dura la sesión; sin salida por reloj a las 07:00, C40) | 1.0 | La misma página con una tinta, para silenciar la lluvia sin encenderse la cara. | E2 |
| 4 | Página · noche 1, noche 7, noche 8, error de audio, interrupción | 1.0 | Los cuatro momentos que un jurado tacha si no están dibujados. | E2 + E5 |
| 5 | **Capas** (mezclador, hoja `.large` sobre `negro`) | 1.0 (11) | "¿Qué capas, a qué nivel?": secciones "colores" / "camas", once texturas (PR-A; C19) sin ranuras ni huecos, filas-control de 80 de paso, "pro · N" sin candado y con nivel guardado, fila "Timbre" al pie (C29), tope de seis capas simultáneas como regla de modelo: al activar la séptima, la fila dice "Seis a la vez" y no se añade; nota "Se mezclan en tu iPhone mientras suenan. Nada se repite." | E2 |
| 6 | **Marea** (hoja `.large`) | 1.0 (profundidad común `bedDepth` + ritual + toggle; Pro, y para todos en Madrugada) | "¿Cómo respiro?": la línea de agua como héroe y control arriba (toggle + línea; nunca un círculo, C59), la frase que ya existe, Ritmo con nombre humano ("Tranquilo · 6", "Suave · 8"), ritual "Descenso" (bajada 12 → 6, meseta, disolución; C24) con ritmo de partida "Empezar a 12 por minuto" (C34), Se retira a los (5-30), Háptica "Mínima" opt-in bajo "Más ajustes" (C35); evidencia a un toque; sin "v1/v2" en la interfaz. | E3 |
| 7 | Marea: gestos por textura | 1.1 | Modulación por textura (parámetros nuevos en `RenderState`, C24); timbre por capa (C29). Fila "Salud" reservada para 2.0 (sin HealthKit en 1.1, C34). | E3 |
| 8 | **Temporizador** (hoja `.medium` → `.large`) | 1.0 | "¿Cuándo se apaga?": entero libre, sin la palabra "pro" (C03): Hasta dormirme (minutos, hasta 360; 45 por defecto), Manto (hora de fin con `DatePicker`; −6 dB a los 45 min por envolvente; C22), Apagado; hueco reservado para Siesta (1.1, C30); fin expresado como hora; cifra 56 y "+15 min" mientras suena; fundido de ganancia de 10-15 min con cuenta entera, estado "Fundiendo · n min" (C31); "El sonido se funde; tu alarma no se toca." | E4 |
| 9 | Retirada de Manto (luminancia + fundido largo) | 1.1 | Despertar no es dormir (C36); nunca naranja. Fundido por quietud: 1.2 tras el spike I0-5b (C37). Amanecer acústico: 2.0 o por demanda. | E4 |
| 10 | **Noche** | 1.0 | "¿Sigue todo bien?": horizonte estático a un tercio (continuo / ausente), reloj 72 ocultable, estado en palabras 22 ("Se funde a las 03:42" / "En pausa" / "Fundiendo · 8 min" / "hasta las 7:00"), "+15 min" de 64 abajo solo si hay temporizador (nunca crea uno; terminada: "Madrugada · 20 min" en su hueco, C27); toda la pantalla es el botón; entra al bloquear por defecto, opción 1 / 3 min solo desde la página, nunca con una hoja abierta (C47); duerme por defecto, "Mantener encendida: mientras carga / siempre / nunca", atenuada a los 60 s (C46). Primer acceso: "La pantalla puede dormir. El sonido sigue." (texto fijo, no tip; C65). | E4 |
| 11 | **Madrugada** | 1.0 | "¿Puedo volver a dormirme sin pensar?": receta fija (C05): océano a nivel bajo con Marea a 8 por minuto para todos, entrada de 3 s, la Marea se retira hacia el minuto 13, el mar funde los últimos 5 min ("Se retira · n min"); una sola tinta; sin hora a propósito (opt-in en Ajustes); "20 min" bajando; "Parar"; nada al terminar (C60); nunca prueba ni paywall. Siempre un botón (C27): "Madrugada · 20 min" en Noche terminada, widget pequeño (00:00–06:00), pantalla de bloqueo, Siri/Atajos, Centro de control y botón de Acción; Watch en 1.2. | E4 |
| 12 | **Mezclas** (pantalla empujada) | 1.0 | "¿Cuál de mis mezclas?": "tuyas" / "de la casa" (cuatro, C18: "Rosa y lluvia", "Mar y viento", "Marrón y hoguera", "Pared"; sin fila en la principal; nunca cambian el temporizador; con Pro dentro se cargan recortadas), fila 72 con receta en paso 7, "pro" inline en lo que no suena, toque = carga y suena (fundido cruzado 1,5 s), deslizar = Renombrar / Eliminar del sistema; vacío en una frase; tres propias gratis, sin límite con Pro; "Guardada sin trueno · Conservar el trueno"; formato de mezcla v2 (pares id+nivel, `version: 2`; C20); sin iCloud en 1.0 (KVS Pro en 1.1, C09). | E5 |
| 13 | Guardar / renombrar (menú del nombre) | 1.0 | `contextMenu` del nombre de la mezcla: "Guardar como mezcla…", "Renombrar", "Vaciar". | E5 |
| 14 | **Hoja Pro** (`.large`; título = `product.displayName`, C12) | 1.0 | "¿Cuánto, una vez, y qué sigue gratis?": precio 56 primero (`displayPrice`; "—" hasta StoreKit), "Una vez.", pie "Un solo pago. Para siempre, en todos tus iPhone.", lista "Con Pro" (Todas las texturas, nombradas y sin número (C04) · Marea · mezclas sin límite · En familia (Family Sharing)), "Gratis siempre", "Empezar la prueba · 7 noches" (C07) y "Comprar · {displayPrice}" entre hairlines de índice, Restaurar a la vista, pie "Sin suscripción. Sin cuenta. Sin rastreo." (C09); 29,99 € de lista sin precio de lanzamiento (C02); estados compra / cancelación / fallo / pendiente / restaurar / sin red; estado comprado = el recibo, con "Gracias. Todo abierto." y el enlace de texto "Escribir una reseña" (C55; único sitio de la app donde se pide, y nunca de noche). Sin "Desbloquear", sin nombre grabado (C12). | E5 |
| 15 | Prueba: noche 1, 2-7, 8 | 1.0 | Se dispara con la primera acción Pro desde la hoja Pro ("Empezar la prueba · 7 noches"), nunca con Play; estado en Keychain (C07). Texto en la cabecera de la página, nunca hoja: párrafo de una vez con "un solo pago", versalita "prueba · quedan n noches" solo desde que empieza, noche 8 con "La prueba terminó. Lo que usaste sigue aquí…"; caduca por sesión; la degradación conserva niveles y nunca escribe (C23). | E5 |
| 16 | **Primer uso** | 1.0 | No hay onboarding: la app abre en reposo con "Esta noche" cargada (receta de 05), Play manual suena en < 1 s (autoarranque solo vía Atajos "Al acostarte"; sin ajuste "abrir sin sonar", C33), tip único al segundo arrastre (C65); ningún permiso. | E5 (+E2) |
| 17 | **Qué sabemos y qué no** (empujada) | 1.0 | Plantilla por frase: afirmación (17 Semibold), estudio / n / quién lo pagó / qué no decimos (17/26); tres entradas más "Lo que no sabemos" y la entrada sobre quedarse en la cama despierto (hallazgo, no consejo; C60); población por criterio de selección parafraseado con n y cita, sin diagnóstico (lista negra clínica sin excepción, C54); sin iconos; pie de dos líneas "Nada de lo anterior es consejo médico." | E5 + E7 |
| 18 | Ajustes (lista del sistema) | 1.0 | Lista de C58: Noche (Pasar sola: al bloquear / 1 min / 3 min / nunca · Hora en Madrugada · Controles visibles · Mantener encendida), Háptica, Al acostarte (Siri/Atajos), Salida (picker del sistema `AVRoutePickerView`, C41), Pro (estado), Qué sabemos, Lo que no hay (+ privacidad), Diagnóstico (+ Escribir al autor: abre el correo del usuario), versión y MB. Sin "abrir sin sonar", sin fila de reseña; iCloud, guía AirPods y Novedades en 1.1. | E5 |
| 19 | **Live Activity** (bloqueo; recortada) | 1.0 (escenario A) / 1.1 (B) | Nombre 17, versalita de estado, tiempo 28 tabular (`Text(timerInterval:)`), horizonte estático 2 pt, **dos botones de 64 fijos: pausa/play (fundido 3 s) y "+15 min"** (vacío en Manto); seis estados (C50): sonando / guiando / en pausa · causa / fundiendo / terminada ("Madrugada · 20 min", 20 min) / madrugada; sin "prueba caducada" ni "bajando"; actualizaciones solo por hito; `.immediate` al terminar; límite de 8 h asumido y cerrado por la app (un Manto más largo la pierde a las 7 h 55 y sigue sonando); "terminada → Madrugada" condicionado al spike I0-3. Sin venta. | E6 |
| 20 | Dynamic Island (mínima, compacta) | 1.0 (A) / 1.1 (B) | Glifo + "38 m". Sin vista expandida (C25). | E6 |
| 21 | **StandBy nocturno** | 1.0 (A) / 1.1 (B) | La misma Live Activity escalada, sin diseño propio ni venta, con un solo control (pausa/play, sin "+15"); texto ≥ 24 pt y ≥ 3:1 bajo rojo medido en dispositivo (spike I0-6; C25, C62); **sin nombre de mezcla**; todo `texto`; nada se anima. StandBy en modo widgets = el pequeño con fondo removible (C42). | E6 |
| 22 | Widgets (pequeño; bloqueo rectangular / inline; mediano en 1.1) | 1.0 | El pequeño "Dormir" siempre ofrece un verbo (interactivo) y entre 00:00 y 06:00 dice "Madrugada · 20 min" (C27); fondo removible; sin `texto2` en el pequeño; sin acento (una tinta `texto`; Tinted = `widgetAccentable`, C61). Sin circular (C42). El mediano "Mezclas" (carga **y reproduce** tres mezclas) pasa a 1.1. | E6 |
| 23 | Centro de control + botón de Acción | 1.0 (iOS 18; corte sin coste en la semana 14 si no está, C26) | Toggle "SleepNoise" (pendiente rosa; *on* teñido por el sistema: la única excepción al "sin acento fuera de la app", C61) y botón "Madrugada" (línea de agua); pistas "Mantén para dormir" / "Mantén para Madrugada". | E6 |
| 24 | Siri / Atajos / automatización "Al acostarte" | 1.0 | Siete intents `AudioPlaybackIntent` con frase (`PlayLastMix`, `Pause`, `PlayMix`, `PlayLayer`, `ExtendTimer`, `SetTimer`, `SmallHours`) y dos sin frase (`Toggle`, `CurrentState`); `StartTide` / `StopTide` / `SetLevel` en 1.1 (C43); `${applicationName}` en las frases (C10); Siri nunca vende; "Al acostarte" es una página de texto con los pasos de Atajos. | E6 |
| 25 | Focus de Sueño (filtro) | 1.1 | Abrir en Noche; mezcla a cargar; oculta la cabecera de prueba. Nada se pospone a la mañana: de noche no se vende y no hay recordatorio (C08). | E6 |
| 26 | **Apple Watch mínimo** | 1.2 (C28) | Una pantalla: nombre 15, Disco 64 (toda la zona central), "+15 min", corona = volumen; "Madrugada · 20 min" cuando no suena; Smart Stack; complicación; Marea háptica "Marcada" `.directionUp` por inhalación (C35). Nunca más de dos botones; nunca vende. En 1.0 el reloj controla con el Reproduciendo del sistema; prototipo de batería en 1.1. | E6 |
| 27 | **Icono** | 1.0 | "La regla y la marea": trazo horizontal `texto` de **112 px** (no 56) de x 192 a 832 en y 608, con la elevación 4:6 en `índice` de x 384 a 832 (cresta en 576, y 352); cuatro apariencias; hoja junto a los diez iconos de la categoría; prueba a 29 pt y en Tinted. | E8 |
| 28 | Capturas (6) + preview muda (30 s) + nombre / subtítulo | 1.0 | Titulares de C57: 1 "Un solo pago." (sin cifra; página sonando, no en reposo) · 2 "Un toque y suena." · 3 "Seis capas a la vez. Una línea cada una." · 4 "El mar respira a seis por minuto." · 5 "A las tres de la mañana, nada." (Noche sola) · 6 "Lo que no hay." Solo fondo negro; una preview muda por idioma con la página real sonando (C53); título "SleepNoise: Sonidos para dormir" (C10); la ficha no cuenta texturas (C04). | E8 |
| 29 | Modo papel (día) | 1.1 (C32) | Mismos componentes, tokens de 3.3; solo página, Capas y hojas; Noche siempre negra. | E1 |
| 30 | Diagnóstico y "Enviar informe" | 1.0 | Anillo local acotado (tiempos relativos desde Play; sin fecha, `portName` ni nombres de mezcla; sesión actual y anterior; excluido de iCloud y del App Group), la escalera del error de audio, "Enviar informe" abre el correo del usuario con el texto; declarado en "Lo que no hay" (C56); el contador de sesiones se deriva del anillo. | E5 |
| 31 | Cómo se genera (una página, empujada) | 1.0 | La prueba de "nunca se repite" en prosa: qué se calcula en el iPhone, cuánto pesa (MB), el test de autocorrelación en CI (C38, C53). | E5 + E7 |
| 32 | Lo que no hay (pie + página) | 1.0 | Pie "Sin suscripción. Sin cuenta. Sin rastreo." en la hoja Pro y en Ajustes; la página lista como hechos de hoy lo que no existe, incluido "No te pediremos que la valores." (C55) y "Un registro de la noche, en tu teléfono. Solo sale si tú lo envías." (C56). | E5 + E7 |
| 33 | Recibo | 1.0 | = el estado comprado de la hoja Pro (#14): "Gracias. Todo abierto.", lo comprado, Restaurar, "Escribir una reseña". No es una pantalla aparte (C38). | E5 |
| 34 | Now Playing (Reproduciendo del sistema) | 1.0 | Título de la mezcla + "En directo"; sin carátula propia; es el control remoto del reloj en 1.0 (C28, C38). Estados de ruta: "Sonando · en Dormitorio" / "En pausa · auriculares" (C41). | E6 |

Texturas: 1.0 se especifica para **once texturas** (las seis de `main` más las cinco de PR-A, trueno sin crack; C19), con tope de seis capas simultáneas como regla de modelo reversible (seis camas en `RenderState`), no de interfaz: la interfaz no enseña huecos.

---

## 6. Lo que queda explícitamente fuera

Del sistema, para siempre o hasta nueva decisión:
- New York, SF Mono y SF Pro Rounded en la interfaz. Una familia.
- El rojo como acento; `brasa` como acento; cualquier acento en StandBy, Live Activity, widgets o Watch; cualquier relleno de color.
- Trazas temporales del sonido (sismógrafo, horizonte que corre, banda de marcas, polilíneas en Live Activity), AGC o escalas inventadas; FFT; cualquier visual que no sea el RMS real.
- La Frase-menú de Silencio, el toque de dos dedos, el doble toque en Noche, el arrastre horizontal en Noche, "bajar la persiana", el arrastre desde el borde inferior; cualquier gesto de varios dedos o de pellizco.
- La Regla con pulgar y escala de marcas de Dial; el Disco de 72 pt; la barra propia; los cuatro glifos en la barra.
- "Noches" como nombre de las mezclas guardadas; "Foco" / "Concentración" / "Sueño profundo" como mezclas de la casa; el chip "Bedtime"; "chip" como componente (el estado es `StateWord` o fila con estado, C64); las palabras que §3 de la reconciliación no graba: "Escudo", "Tu instrumento", "Desbloquear", "envolvente", "perfil de entorno", "Lluvia fina", "Cama rosa", "Mar lento", "Noche de fuego", "Control fino", "Tormenta lejana", "v1/v2", "Oleaje/Swell".
- Hojas negras; botones "Cerrar"; títulos centrados; radios propios; sombras; degradados; Liquid Glass en contenido; `.glassProminent` teñido.
- Candados, cápsulas, badges, tachaduras, cuentas atrás, "✓ Activo", sellos, "¿Qué es Pro?" en la cabecera, notificaciones de prueba; cualquier venta, tip o petición de reseña entre 21:00 y 07:00 (`NightWindow`); la "línea matinal" (C08); `requestReview` en 1.0 (política dormida tras bandera; se decide en 1.1 con dato, C55); la cifra del precio en capturas (C02); contar texturas en marketing (C04).
- Acento fuera de la app (una tinta `texto`; única excepción el tinte *on* del control del Centro de control, C61); Isla expandida; StandBy con diseño propio; widget circular (C25, C42, C50).
- "insomnio", "ansiedad", "mejora el sueño", "IA", "vitalicio", "timer", "mix" y el resto de la lista negra, en los dos idiomas.
- Luna, estrellas, nubes, `moon.zzz`, iconos de sonido, iconos animados.

Del alcance 1.0, según §5 de la reconciliación:
- **Timbre por capa** ("más cálido / más lejano"): 1.1. En 1.0, timbre en el bus maestro como fila "Timbre" en Capas, condicionado al spike I0-7 (C29); nunca un gesto.
- **Fundido espectral**: el corte de filtro solo si el bus maestro llega (puerta semana 4–6); "retirar capas" fuera; 1.0 funde en ganancia (10-15 min, cuenta entera; C31). **Subida suave** (+3 dB en 2-4 kHz): parámetro espectral que no existe en `RenderState`.
- **Fundido por quietud**: 1.2 tras el spike I0-5b (C37). **CoreMotion en producción**: fuera de 1.0; la háptica se gobierna por fase (C35).
- **Leer la hora de despertar del horario de Sueño**: no hay API; el Manto usa un `DatePicker` que el usuario fija una vez (C22).
- **Micrófono** (guía de nivel, enmascaramiento adaptativo) y **modo cuna**: fuera de 1.0 y 1.1 (no están en el alcance de la reconciliación; se reevalúa con datos).
- **Focus filter**, **Siesta**, **Papel**, **widget mediano**, **iCloud KVS**, **escucha de 30 s de capa Pro**, **Acceso asistido**, **Retirada de Manto**, **guía AirPods**, **carta Novedades**: 1.1 (C06, C09, C30, C32, C36, C38, C39, C42, C43). **Watch** y **háptica "Marcada"**: 1.2 (C28, C35). **Salud en Marea** y **Amanecer acústico**: 2.0 (C34, C36).
- **Marea por textura** (gestos, modulación de todas las texturas): 1.1 (C24). El ritual (bajada 12 → 6, meseta, disolución) sí entra en 1.0 porque cabe en la curva de `bedDepth` existente.
- **"Debajo de otro audio"** (uso diurno con podcast, antes "modo Capa"): 1.1, como estado de sesión que entra si suena otro audio y el usuario acepta ("Sonar debajo"), con línea de estado "Debajo de tu podcast", fila de nivel visible solo en ese estado y preferencia en Ajustes (Preguntar / Siempre / Nunca); nunca un toggle global de `mixWithOthers` (C16, C44).
- **Nivel maestro visible en la página**: no existe en 1.0 (el maestro es de sesión y se ajusta en Noche; C51).
- Notas de noche, cuaderno, informe matinal, ventana de sueño: fuera (no están en el alcance 1.0 ni 1.1 de la reconciliación).

Lo que sale del teléfono: **nada, salvo lo que el usuario envía por su propio correo** ("Enviar informe", "Escribir al autor"; C56, C58). Sin telemetría, sin cuenta, sin rastreo; iCloud (1.1) es del usuario y se puede apagar (C09).

---

## 7. Decisiones del dueño (registro histórico)

Las decisiones 7.1–7.10 se consolidan en `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` §2 y §6; este apartado queda como registro histórico (C01). Lo único que sigue en manos del dueño está en §6 de ese documento, con recomendación y plazo (acento, marca, segunda pareja, EN de "Manto"); lo demás está decidido y no vuelve.

| # | Decisión que tomaba este apartado | Estado |
|---|---|---|
| 7.1 | Acento: Índice `#F0C020` (recomendación) / rojo grafito / brasa | **Abierta en reconciliación §6 #1** (recomendación (a) Índice; prueba de cinco segundos con la página real sonando; plazo 27-11-2026). Los tokens de §3.1 llevan el Índice por defecto. |
| 7.2 | Nombre | **Cerrada por C10**: SleepNoise; cierre 04-12-2026; "Marea" es una función, no una marca; icono y legal independientes del nombre; Siri con `${applicationName}`. |
| 7.3 | Modo claro | **Cerrada por C32**: oscura en 1.0; Papel en 1.1 (tokens de §3.3 marcados 1.1). |
| 7.4 | iOS mínimo | **Cerrada por §5 de la reconciliación**: iOS 17, único `#available(iOS 26)` en el Disco (C66). |
| 7.5 | Marea v1 / v2 | **Cerrada por C24**: 1.0 = profundidad común + ritual + toggle; gestos por textura 1.1; Salud 2.0 (C34); Marea para todos en Madrugada (C05). |
| 7.6 | Micrófono | **Fuera de 1.0 y 1.1** (§6): no está en el alcance de la reconciliación; se reevalúa con datos. |
| 7.7 | Watch | **Cerrada por C28**: Watch 1.2 (no 1.1); en 1.0, Reproduciendo del sistema; prototipo de batería en 1.1. |
| 7.8 | Precio y prueba | **Cerrada por C02 y C07**: 29,99 € de lista. Sin precio de lanzamiento. Prueba de 7 noches local, iniciada desde la hoja Pro ("Empezar la prueba · 7 noches"), estado en Keychain; un solo `displayPrice`. |
| 7.9 | Reparto gratuito | **Cerrada por C03, C04, C05 y C06**: cinco libres (blanco, rosa, marrón, lluvia, viento); seis Pro; la lista libre solo crece; temporizador entero libre; Marea Pro, para todos en Madrugada; sin escucha de 30 s (toque en capa Pro → hoja Pro). |
| 7.10 | Mezclas guardadas gratis | **Cerrada por reconciliación §1 regla 3 (y C09)**: 3 (`freeSavedMixLimit` 1 → 3); Pro sin límite; formato v2 en 1.0; iCloud KVS en 1.1. |

---

## 8. Plan de trabajo de la fase de especificación

### 8.1 Quién escribe qué

| Equipo | Entrega | Contenido |
|---|---|---|
| **E1 · Sistema** (dos personas: diseño de sistemas + un iOS que construye) | `04-SISTEMA-FUNDAMENTOS.md` + build SwiftUI de referencia | Tokens de §3 en asset catalog (con High Contrast y papel), escala tipográfica con `relativeTo`, espaciado, hairline, `PrimaryActionStyle`; los seis componentes propios de §4 con sus seis estados, Dynamic Type por tramo, Reduce Motion, VoiceOver; patrones (entrar / salir de Noche, Pro sin candados, permiso en el momento de uso, hoja, tip); checklist de aceptación (doce pruebas de §4 del brief, conteos de §8, recorrido del día 8). Compilable en iOS 17 con el único `#available`. |
| **E2 · Página y Capas** | `05-PAGINA-Y-CAPAS.md` | Pantallas 1-5 del inventario: página en sus seis estados, página nocturna (por procedencia), Capas con once texturas y tope de seis, fila Timbre, geometría del arrastre (horizontal, relativo, 8 pt, 30°, canal de 24; validada por el spike I0-2, C52), `Slider` por pulsación larga, descomposición del horizonte, "y 2 más", primer uso en lo que toca a la página. iPhone 17 Pro y SE/16e, Large / xxxLarge / AX3 / AX5, ES / EN, negro (papel en 1.1). |
| **E3 · Marea** | `06-MAREA.md` | Pantallas 6-7: hoja, línea de agua como control, ritual Descenso (12 → 6), estados guiando / disolviendo / retirada / gratuito, minuto a minuto, háptica Mínima opt-in, voz de guía, Marea en Madrugada (8/min, receta fija), gestos por textura marcados 1.1 y Salud 2.0. |
| **E4 · Tiempo y noche** | `07-TEMPORIZADOR-NOCHE-MADRUGADA.md` | Pantallas 8-11: dos modos (Hasta dormirme, Manto por hora; hueco de Siesta 1.1), Noche, Madrugada, entradas y salidas, tabla "interrupción × ventana → reanuda / termina" (C48), AirPods (C49), "Controles visibles de noche", "Mantener encendida", Acceso asistido (1.1). |
| **E5 · Mezclas, Pro y honestidad** | `08-MEZCLAS-PRO-PRUEBA.md` | Pantallas 12-18 y 30-33: Mezclas (cuatro de la casa), guardar, hoja Pro, los tres momentos de la prueba, compra / restauración / familia / sin red, primer uso completo, Qué sabemos, Ajustes (lista de C58), Diagnóstico, Cómo se genera, Lo que no hay, recibo. |
| **E6 · Ecosistema** | `09-ECOSISTEMA.md` | Pantallas 19-26 y 34: Live Activity recortada (seis estados, dos botones; solo escenario A en 1.0), Isla compacta y mínima, StandBy = la misma vista escalada en rojo primero, widgets (pequeño y bloqueo; mediano 1.1), Control y botón de Acción, Salida, Siri / Atajos (7 + 2), Now Playing, Focus (1.1), Watch (1.2). Con los supuestos de ActivityKit resueltos por el spike I0-3. |
| **E7 · Copy** | `10-GUIA-DE-COPY.md` + String Catalog semilla | Voz, glosario ES/EN (es-ES y es-419) = §3 de la reconciliación, las dos listas negras (la clínica sin excepción, C54), todas las cadenas de §15 de Grafito corregidas (Mezclas, "Todas las texturas", Qué sabemos sin palabras vetadas, "un solo pago" en la noche 1), purpose strings, textos de Siri con `${applicationName}`, notas de versión; lint de nombres en test (C17). Revisa el copy de todas las demás entregas antes de su cierre. |
| **E8 · Icono y tienda** | `11-ICONO-Y-APP-STORE.md` | Icono en cuatro apariencias a 1024 / 60 / 29 junto a los diez de la categoría, sin letra ni nombre; seis capturas en es-ES, es-419 y en-US (solo negro); una preview muda por idioma con la página real; nombre y subtítulo de 30 caracteres; primera línea de descripción sin cifra ni cuenta de texturas; Notes for Review cita el test de autocorrelación. |
| **I0 · Ingeniería (spikes, semana 2; C45)** | notas en `docs/research/spikes/` | Antes de que E2-E6 cierren: I0-1 medidor RMS por capa en el hilo de audio + canal lock-free render → main + `master` con rampa en `EngineCommand`; I0-2 prototipo del arrastre de fila (umbral de 30°, relativo, canal) en dispositivo con VoiceOver y Switch Control; I0-3 `AudioPlaybackIntent` sobre una Live Activity terminada y re-emisión > 8 h; I0-4 `pauseCommand` de AirPods en iOS 26; I0-5 / I0-5b CoreMotion (quietud y háptica), solo investigación, sin producción; I0-6 el tinte real de StandBy con una actividad de prueba y foto calibrada (contraste bajo rojo); I0-7 timbre en el bus maestro (puerta de decisión en la semana 4–6). |

### 8.2 Orden

Unidad única de esfuerzo: la **semana-pareja** del plan (una pareja de ingenieros una semana). La especificación de diseño son **5 semanas dentro de las semanas 0–8** del bloque Primitivas del plan (C45); los deltas se aplican en el orden 10 → 04 → 05-09 → 11 → 03 → plan, para que cada documento herede el vocabulario ya corregido.

- **Semana 1. Reconciliación producto–diseño** (hecha: `RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`; C01). E1 fundamentos y los seis componentes en SwiftUI. I0-1. Prueba de cinco segundos del acento (reconciliación §6 #1) con la página real sonando en un iPhone en la mesilla a oscuras; el dueño responde la primera tanda de §6 el viernes 27-11-2026; lo que no responda se construye con la recomendación.
- **Semana 2.** Spikes I0-2, I0-3, I0-5 / I0-5b, I0-6 e I0-7 (C45). E2 y E4 (la página, Capas, Noche y Madrugada son el 70 % del uso). E7 abre el glosario con §3 de la reconciliación. Cierre de marca el viernes 04-12-2026 (C10).
- **Semana 3.** E3 y E5. E7 revisa E2 y E4. E8 arranca el icono con el acento ya decidido e independiente del nombre.
- **Semana 4.** E6 con los spikes cerrados; E8 capturas y preview sobre la build de referencia; E7 cierra el String Catalog. Checklist de aceptación de E1 pasado sobre la build. Puerta del bus maestro (semanas 4–6): si no llega, la fila Timbre cae a 1.1 y el fundido es solo de ganancia. Segunda pareja confirmada o no el 14-12-2026 (reconciliación §6 #3: decide el escenario A/B y la Live Activity).
- **Semana 5.** Entrega del paquete 04-11 al equipo de iOS. La estimación es la de §5 de la reconciliación (34,25–36,5 semanas-pareja en escenario A; 32,25–34 en B; hitos en las semanas 30 y 44), no una cifra propia de este documento.

### 8.3 Cómo se revisa

Cada entrega pasa tres puertas, en este orden, y no avanza sin las tres:

1. **Puerta de formato.** Las cinco tablas obligatorias (movimiento con señal, VoiceOver por control, gesto → alternativa, Dynamic Type por tramo, cadenas ES/EN por clave) están completas; todas las medidas en pt; un único juego de hex, el de §3; maqueta y texto coinciden (el jurado tachó a los cuatro conceptos por no coincidir).
2. **Puerta de los jurados.** Los cinco jurados (3 de la mañana · honestidad e instrumento · restricción tipográfica · plataforma · primera impresión) la leen con su lente y devuelven una lista; nada se discute en reunión: se corrige o se razona por escrito en la propia entrega. Un 1 en las dos primeras lentes devuelve la entrega entera.
3. **Puerta de dispositivo.** La build de referencia de E1 incorpora la pantalla y se prueba en un dormitorio a oscuras con brillo al mínimo (iPhone 17 Pro y SE), con el filtro rojo de StandBy, en escala de grises, con VoiceOver, Reduce Motion, Aumentar contraste, Button Shapes y Acceso asistido, y con Instruments 10 minutos bloqueado. La prueba a ciegas (cinco personas: pausar y añadir quince minutos a la primera en app, bloqueo y, en 1.2, Watch) y la prueba de cinco segundos en luz blanca se repiten al cierre de E2, E4 y E6.

Desempate, como en el brief: la versión que haya quitado más sin perder función.

---

## 12. Reconciliación aplicada (16-11-2026)

Fuente: `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`. Una línea por delta que nombra a 03 (por número, por "la dirección" o por regla transversal de §1, §3 y §4), más las correcciones internas que 04 §9 y 05 §9 pedían a este documento. Ningún delta se ha rechazado: ninguno contradice el código del hilo de audio ni es materialmente imposible; las tensiones que quedan se anotan al final como notas, no como rechazos.

**Deltas de §2 aplicados**

- C01 → §7 sustituido por el puntero a §2 y §6 de la reconciliación con tabla de estado por decisión; §8.2: reconciliación en la semana 1 (antes semana 5); cabecera: el plan existe y las jurisdicciones están escritas.
- C02 → §7.8: 29,99 € de lista, sin precio de lanzamiento; §4.6 y §5 #14 con `displayPrice`; §5 #28 captura 1 sin cifra; §6 lo lista como fuera.
- C03 → §1.4 y §7.9: temporizador entero libre; §4.7 sin filas Pro de temporizador; §5 #8 reescrito (sin "pro", sin "≤ 60"); §5 #14 sin "temporizador sin límite" en la lista Pro.
- C04 → §1.4 y §7.9: cinco libres (con viento) / seis Pro, la lista libre solo crece; §1.2 "Las siete capas Pro" → "Todas las texturas" sin número; §5 #14, #28 y E7/E8 en §8.1 sin cuenta de texturas.
- C05 → §1.4 y §5 #11: Madrugada = océano fijo a nivel bajo con Marea a 8/min para todos, entrada 3 s, retirada hacia el minuto 13, fundido final 5 min, nada al terminar, nunca prueba ni paywall; §4.3 Bloqueado-Pro lo recoge.
- C06 → §4.2, §4.3, §4.7 y §7.9: eliminada toda escucha de 30 s; toque en capa Pro → hoja Pro; VoiceOver de la fila Pro sin "treinta segundos"; §5 #25 y §1.3 (Dial) sin "la escucha de 30 s ocurre".
- C07 → §5 #15 y §7.8: la prueba se dispara desde la hoja Pro ("Empezar la prueba · 7 noches"), nunca con Play; Keychain; versalita solo desde que empieza; §4.6 con la cadena nueva; eliminada la "variante 3.1.1 si el dueño elige non-consumable".
- C08 → §1.3 (Dial): "La venta se pospone a la mañana" sustituida por "De noche no se vende" sin línea matinal; §5 #25 Focus sin posponer venta; §4.2, §4.3, §4.7: de noche el toque Pro no abre nada; §6 lo lista.
- C09 → §5 #12 formato v2 y sin iCloud en 1.0; §5 #14 y #18/#32 pie "Sin suscripción. Sin cuenta. Sin rastreo."; §7.10 y §6 (KVS 1.1, del usuario, apagable).
- C10 → §7.2: SleepNoise, cierre 04-12-2026, "Marea" es una función; §5 #24 `${applicationName}`; §5 #28 título de ficha; §8.1 E8 icono sin letra; §8.2 semana 2.
- C11 → "Escudo" → "Manto" en §3.2 (fase de retirada), §4.7, §5 #8, #14 y #19, y §6; "Escudo" en la lista de palabras no grabadas.
- C12 → §5 #14 titulada por `product.displayName`, "Una vez.", lista "Con Pro" que termina en "En familia", recibo = estado comprado, sin "Desbloquear" ni nombre grabado; §4.6 VoiceOver con `{displayName}` / `{displayPrice}`.
- C14 → §3.2 tabla de fases: "Descenso" → "Día" (`.day`); "Descenso" reservado al ritual de Marea en §1.2, §1.3, §3.2 y §5 #6.
- C16 / C44 → §6: "Capa de fondo con `mixWithOthers`" → "Debajo de otro audio" (1.1), estado de sesión con "Sonar debajo", línea "Debajo de tu podcast", preferencia Preguntar / Siempre / Nunca; nunca toggle global.
- C18 → §1.2, §1.3 (Dial) y §5 #12: mezclas de la casa = "Rosa y lluvia", "Mar y viento", "Marrón y hoguera", "Pared" (receta, reparto, carga recortada, sin fila en la principal, sin cambiar el temporizador); "Mar lento · sin Océano" → "Mar y viento · sin Océano"; "Lluvia fina", "Cama rosa", "Mar lento" en la lista de palabras no grabadas.
- C19 → §5 #5: "1.0 (6 capas) / 1.1 (11)" → "1.0 (11)", sin ranuras, tope de seis como regla de modelo y "Seis a la vez"; nota de texturas reescrita (eliminado "1.0 se especifica para seis capas"); §8.1 E2.
- C20 → §5 #12: formato de mezcla v2 (`[{id, level}]` + `version: 2`).
- C21 → §4.2: la pulsación larga abre el `Slider` del sistema como ajuste fino y alternativa sin gesto (ya estaba; se cita C21 y se adopta la variante "sustituye a la línea en su sitio" de 05 §9 #3).
- C22 → §5 #8 y §6: Manto por hora fija (`DatePicker`), −6 dB a los 45 min; minutos solo en Hasta dormirme (hasta 360).
- C23 → §4.2 Bloqueado-Pro: el nivel se conserva, el motor lo ignora, la degradación nunca escribe; §5 #15.
- C24 → §4.3, §5 #6-7, §6 y §7.5: Marea 1.0 = `bedDepth` común + ritual (bajada 12 → 6, meseta, disolución) + toggle; gestos por textura 1.1; Salud 2.0; "v1/v2" fuera de la interfaz y de las palabras grabadas.
- C25 → §1.4 y §5 #19-21: Live Activity recortada en 1.0 solo en escenario A (1.1 en B); Isla sin vista expandida; StandBy = la misma vista escalada, sin diseño propio ni venta, un solo control; §8.1 E6; §8.2 semana 4 (14-12-2026).
- C26 → §5 #23: Centro de control + botón de Acción en 1.0 (iOS 18) con corte sin coste en la semana 14.
- C27 → §1.2 (fila "Doble toque en Noche"), §1.3 (Silencio), §3.2, §4.5, §5 #10, #11 y #22: Madrugada siempre es un botón; "Madrugada · 20 min" ocupa el hueco del "+15 min" en Noche terminada; widget pequeño 00:00–06:00; sin doble toque.
- C28 → §7.7: Watch 1.2; propagado a §1.2, §1.3 (Dial), §3.8 (columna Watch), §5 #11 y #26, §6, §8.1 E6 y §8.3; en 1.0, Reproduciendo del sistema (§5 #34).
- C29 → §1.2 (fila Timbre), §4.2 (fila "Timbre", extremos Grave / Lejos, bus maestro, condicionada a I0-7), §5 #5, §6 y §8.1 E2: timbre = fila en Capas; sin gesto; por capa en 1.1.
- C30 → §5 #8: Siesta fuera de 1.0, hueco reservado; "Siesta" entre las palabras que no se graban hasta 1.1 (§6 lista 1.1).
- C31 → §5 #8 y §6: fundido de ganancia 10-15 min con cuenta entera, "Fundiendo · n min"; corte de filtro solo si el bus llega; "retira capas" fuera.
- C32 → §7.3: oscura en 1.0, Papel 1.1; §3.3 encabezado; §5 #28 sin capturas en papel; §5 #29 "1.1"; §8.1 E2 y E8 solo negro.
- C33 → §5 #16: la app abre en reposo y suena con Play; autoarranque solo vía Atajos; sin "abrir sin sonar"; captura 2 "Un toque y suena." (C57).
- C34 → §1.2 y §4.3 / §5 #6-7: ritmo de partida "Empezar a 12 por minuto" (parámetro) en vez de "Empezar a mi ritmo"; sin HealthKit en 1.1; fila Salud reservada para 2.0.
- C35 → §3.8: "+15 min" vibra solo de día; Marea "Mínima" 3-5 respiraciones opt-in; "Marcada" al Watch (1.2); regla de silencio por fase (`MotionGate.allows(phase) = !phase.isNight`), sin CoreMotion en producción 1.0; §5 #6 y #26; §6.
- C36 → §3.2 fila "Despertar" → "Retirada de Manto (1.1)", nunca naranja; "Amanecer acústico" 2.0; §5 #9; §6.
- C37 → §5 #9 y §6: fundido por quietud a 1.2 tras el spike I0-5b.
- C38 → §5: añadidas las entradas #31 "Cómo se genera", #32 "Lo que no hay", #33 recibo (= estado comprado de #14) y #34 Now Playing; cabecera de §5 declara que gesto de timbre, ranuras, selector de textura, panel "ahora mismo", botón AX y carta Novedades no están (ninguno figuraba en el inventario de 03; la web es de E8, posterior).
- C39 → §5 #29 Papel "1.1", #22 mediano "1.1", #9 Retirada "1.1"; §4.5 y §8.1 E4: Acceso asistido "1.1"; "Esta noche" confirmado como nombre de la mezcla viva (§1.3, §5 #16).
- C40 → §3.2 y §5 #3: página nocturna por procedencia, dura la sesión, sin salida por reloj a las 07:00; §4.12: ningún tip entre 21:00 y 07:00 (`NightWindow`); §3.2 nota de constante única; §6.
- C41 → §5 #18 fila "Salida" (picker del sistema) y §5 #34 estados "Sonando · en Dormitorio" / "En pausa · auriculares".
- C42 → §5 #22: pequeño "Dormir" + bloqueo rectangular / inline; sin circular; mediano 1.1; StandBy en modo widgets = el pequeño con fondo removible (§5 #21).
- C43 → §5 #24: "Diez intents con frases" → siete con frase y dos sin frase; "Al acostarte" como página de texto de una pantalla.
- C45 → §8.2: unidad semana-pareja, 5 semanas de especificación dentro de las semanas 0–8, spikes de la semana 2 (I0-2, I0-3, I0-5/5b, I0-6, I0-7), fechas 30/44 intactas; eliminada la cifra "20-22 semanas-ingeniero"; §8.1 fila I0 renumerada con I0-7 y la puerta del bus.
- C46 → §4.5 y §5 #10: Noche duerme por defecto; ajuste "Mantener encendida: mientras carga / siempre / nunca"; atenuada a los 60 s; §5 #18.
- C47 → §4.5 y §5 #10: anatomía fija de Noche, entra al bloquear por defecto con opción 1 / 3 min solo desde la página, nunca crea un temporizador ("+15 min" solo si existe; si no, hueco vacío), "atenuada" no es un estado; §5 #18 "Pasar sola a Noche".
- C48 → §1.3 (Dial): la regla de interrupciones por ventana de la mañana (05:00–11:00 o fin de Manto −60 min; fuera, toda interrupción reanuda con fundido de 3 s; `CXCallObserver`); §3.2 nota; §8.1 E4 tabla "interrupción × ventana".
- C49 → §1.3 (Dial) y §3.7: caída de ruta = 40 ms + pausa, nunca reanuda sola por el altavoz, "Seguir por el altavoz" 60 s, reanudación capada a 0,4 solo si la ruta cambió, `pauseCommand` con auriculares 3 s.
- C50 → §1.4 y §5 #19: dos botones (pausa con fundido 3 s / play; "+15" vacío en Manto), seis estados, sin "prueba caducada" ni "bajando", límite de 8 h cerrado por la app; §1.3 (Silencio) "hasta 4 h" → el límite de 8 h.
- C51 → §4.5: arrastre vertical = `master` con rampa en `EngineCommand` (sesión, no persiste, nunca el volumen del sistema), "Sonando · al 40"; §6: sin fila de maestro en la página en 1.0.
- C52 → §8.1 E2: arrastre horizontal (`LevelRule`) validado por el spike I0-2; el gesto vertical de timbre muere (§1.2).
- C53 → §1.4: Horizonte quieto y la prueba de "nunca se repite" (Cómo se genera + MB + test de autocorrelación en CI); §5 #28 preview = la página real sonando; §5 #31.
- C54 → §1.2 (fila "insomnio") y §5 #17: lista negra clínica sin excepción también en "Qué sabemos"; población por criterio de selección parafraseado con n y cita; tres entradas + "Lo que no sabemos"; pie de dos líneas.
- C55 → §5 #14 (enlace "Escribir una reseña" en el estado comprado), #18 (sin fila de reseña), #32 ("No te pediremos que la valores." como hecho de hoy); §6: sin `requestReview` en 1.0.
- C56 → §6: "nada sale del teléfono salvo lo que el usuario envía por su propio correo"; §5 #30 con los campos del anillo y "Enviar informe" por correo; §5 #32.
- C57 → §5 #28: los seis titulares, Noche sola en la 5, solo negro, una preview muda por idioma.
- C58 → §5 #18: inventario de Ajustes = la lista de C58 (incluye "Escribir al autor" y "Salida"; sin "abrir sin sonar" ni reseña; iCloud, guía AirPods y Novedades en 1.1).
- C59 → §4.3 y §5 #6: toggle + línea de agua, nunca círculo, "solo oleaje" no es un estado, valor hablado "{n} por minuto".
- C60 → §3.2 y §5 #11: Madrugada con una sola tinta, hora opt-in, "Se retira · n min", cierre silencioso, sin retirada luminosa en 1.0; la frase de levantarse va a "Qué sabemos" como hallazgo (§5 #17).
- C61 → §5 #22-23 y §6: una tinta `texto` fuera de la app; única excepción el tinte *on* del control del Centro de control; Tinted = `widgetAccentable`.
- C62 → §3.1 (fila `texto`): criterio ≥ 4,5:1 en app; fuera, ≥ 24 pt y ≥ 3:1 bajo rojo medido (I0-6); plan B `#F0ECE4` si < 3,5; §5 #21.
- C63 → §4.1 VoiceOver: elemento de estado "Sonido" con valor (histéresis 3 s) y acción "Ver capas por separado"; sin `AXChartDescriptor` ni rotor Audio Graph; sublíneas decorativas; Magic Tap en la raíz; en Noche el estado vive en el `FullScreenControl`; §4.4 y §1.1 coherentes.
- C64 → §6: "chip" no es un componente (StateWord o fila con estado).
- C65 → §4.12 y §5 #10/#16: un solo TipKit (segundo arrastre, de día); las dos frases de Noche son texto fijo; ningún tip en `NightWindow`; lista cerrada.
- C66 → §4.4: único `#available(iOS 26)` en el Disco; vidrio del sistema aceptado en barras y hojas; sin `glassEffect` en contenido; sin control teñido; "rama visual iOS 26" vacía.
- C67 → §3.4: nueve pasos, ≤ 6 estilos por pantalla, principal ≤ 4; 17 Medium cuenta como estilo.
- §1 regla 3 / §4 → §1.4 y §7.10: tres mezclas guardadas gratis, Pro sin límite; reparto de §4 reflejado en §5 (columna V) y en §6.
- §3 vocabulario → "Manto", "Día", "Mar y viento", "Timbre", "Debajo de otro audio", "Seis a la vez", "Se retira", "Empezar la prueba · 7 noches", "Escribir al autor", "Salida", "Mantener encendida", "Pasar sola a Noche", "Esta noche"; las palabras que no se graban listadas en §6.
- §5 de la reconciliación (alcance) → §5 de este documento y §7.4 (iOS 17, solo oscura, SleepNoise, 29,99 sin lanzamiento).

**Correcciones internas que 04 §9 y 05 §9 pedían a 03**

- Cota del horizonte (04 §9 #15, 05 §9 #24) → §3.5 alineada con §1.3: y = altura × 0,333 sobre la pantalla completa, redondeada a la retícula de 4 (284 / 280 / 224); se retira "bajo el área segura superior".
- Errata del grosor (05 §9 #6) → §4.1, §3.7 y §1.4: 1 → 3 pt pasa a 1,5 → 3 pt (mínimo de `índice` en §3.1).
- Hairlines de "Comprar" (04 §9 #16) → §4.6 y §3.1 regla 1: 1,5 pt, no 1 pt.
- Toggle de la Marea (04 §9 #14, 05 §9 #12) → `.tint(texto)` en §1.2, §3.1 regla 2 y §4.12. La reconciliación no lo cubre (C59 solo fija "toggle + línea de agua"); se resuelve por la regla "quita más sin perder función": el toggle *on* se lee por la posición del pomo (P7), desaparece el segundo acento de la principal y la regla "un índice por pantalla" queda sin excepciones. 04 y 05 deben retirar la exención del `IndexArbiter` y corregir sus conteos de color (05 §2.2 y §3).
- Hoja Capas (05 §9 #4) → §4.10: Capas es la única hoja sobre `negro`, con hairlines `trazo`, como ya listaba §3.1; §5 #5.
- Banda de la Marea (04 §9 #19) → §3.5 y §4.1: 120 pt siempre que la mezcla cargada tenga Marea disponible; no crece al activarla (§3.7).
- Orden de VoiceOver del Disco (04 §9 #17) → §4.4 y §1.1: no es el primero; Magic Tap en la raíz + `.startsMediaSession` (coincide con C63).
- Botón Cerrar en iOS 26 (04 §9 #18) → §4.10: ninguna versión lo añade sola.
- `Slider` por pulsación larga (05 §9 #3) → §4.2: sustituye a la línea en su sitio, `.tint(texto)`, 5 s.
- Tokens High Contrast que faltaban (04 §9 #21) → §3.1: `texto-noche`, `índice-noche` y `trazo-hoja` usan `texto2-ac`, `índice-ac` y `trazo-ac` por decisión; los de papel y `hoja-papel` (04 §9 #22-23) pasan a 1.1 con Papel (C32).
- "Parar" en Madrugada (04 §9 #5) → se mantiene en §4.5: parar es una función que "+10 min" perdería, y la Isla expandida que daba casa a "+10" ya no existe (C25).
- Salida de la página nocturna (05 §9 #14) → se mantiene el toque en el nombre (C40 no la cambia; la pulsación larga del nombre ya es el menú Guardar/renombrar de día).
- 04 §9 #1-3 (acento, papel, reparto), 05 §9 #7, #10, #13, #15, #18 → cerradas por reconciliación §6 #1, C32, C03/C04/§1 regla 3, C08, C40, C39 y C09 respectivamente; 05 §9 #11 (orden de filas) y #16-17 (nota de una vez, `defaultLevels()`) no son de 03 y siguen en 05.

**Rechazos**

Ninguno.

**Notas (tensiones registradas, no rechazos)**

- C25 dice "cuatro estados" y C50 "seis estados" para la Live Activity; 03 adopta los seis de C50 (es la ficha específica y el delta de 09 dice "tabla de estados = seis").
- C67 fija "la principal ≤ 4 estilos" y "17 Medium cuenta como estilo"; con la barra en 17 Medium, 05 §3 cuenta 6 en la página sonando. 03 escribe la regla de C67 tal cual (≤ 4 en reposo: 2, 5, 7, 9) y deja a 05 declarar su conteo honesto; si el dueño quiere ≤ 4 también sonando, la barra tendría que pasar al paso 5 (17 Semibold).
