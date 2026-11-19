# 12 · Exploración de color: pintura generada sobre Grafito

Fecha: 2026-11-19. Para el dueño del producto. Estado: exploración de diseño, sin código tocado y sin cambios en la dirección 03. Maquetas y notas completas en `docs/design/color/`.

Documentos de los que parte: `03-DIRECCION-DE-DISENO-2026-11-16.md` (tokens §3, componentes §4, inventario §5), `11-ICONO-Y-APP-STORE.md`, `docs/store/README.md`. Lo que aquí se propone se superpone a Grafito; no lo sustituye.

Convenciones: medidas en pt para iPhone de 402 × 874; contrastes WCAG medidos sobre negro; "Índice" es el amarillo `#F0C020` de 03; "texto" y "texto2" son las tintas `#E8E4DC` y `#9C9A96`. Sin nombres de pintores, obras ni movimientos en este documento ni en ningún fichero del repositorio: la razón está en §8.

---

## 0. Resumen para decidir en cinco minutos

1. **La queja es cierta y tiene causa.** Grafito es negro, tres grises, SF Pro y un amarillo que solo existe mientras suena. De día, con la app en la mano a las seis de la tarde, eso se lee como frío y sin terminar. La queja no es de la noche: de noche la app está exactamente donde debe.
2. **La respuesta no es una ilustración ni una foto.** Es un lenguaje pictórico propio, interno "Pigmento": pinceladas cortas de pigmento alto, borde duro y empaste, generadas en el iPhone con código, igual que el sonido. Once motivos abstractos, uno por textura (lluvia es dirección y ritmo, hoguera es lenguas que suben, mar es flujo que no se cierra), con una paleta medida por textura. Sin paisaje, sin figuras, sin nada que recuerde a una obra concreta.
3. **Tres caminos, del más contenido al más pleno.** A, color contenido: bandas en Mezclas, reglas en Capas, una ventana alrededor del horizonte en la página de día, una captura. B, lienzo vivo: la página de día pinta la mezcla que suena en una ventana de 240 pt que respira con el sonido. C, pintura plena: página y Capas pintadas a sangre. Un jurado de tres lentes (dirección creativa, ingeniería, propiedad intelectual) puntuó A 6 · 8 · 8, B 7 · 5 · 7 y C 4 · 3 · 4 sobre 10.
4. **Recomendación del estudio: el camino A con dos injertos de B** (la ventana del horizonte en la página de día y el titular de tienda "Lo que suena, se pinta."). Coste: 3 a 3,5 semanas de una persona. Mantiene la noche negra, el icono negro y la hoja Pro gris, y hace que al abrir la app de día haya color donde está el sonido.
5. **Variante mínima para 1.0 si quiere algo de color antes de enviar:** solo las bandas de las cuatro mezclas de la casa en Mezclas y la captura nueva de la tienda, generadas en tiempo de compilación como PNG. Una semana y media; no toca la página, el motor ni la noche.
6. **Tres decisiones suyas:** si aprueba el camino A con la ventana (recomendado: sí); si acepta que icono y hoja Pro sigan sin color (recomendado: sí); si quiere la variante mínima en 1.0 o el camino entero en 1.1 (recomendado: variante mínima en 1.0, ventana en 1.1 tras medir batería).

---

## 1. Por qué la app se ve fría y qué pide el dueño

### 1.1 Lo que Grafito eligió a propósito

La dirección 03 se definió por lo que no hay: fondo negro, tres grises, un solo acento que solo existe mientras suena, sin ilustraciones ni iconos, hojas gris oscuro. Las razones siguen siendo buenas:

- La app se usa en la cama, a oscuras. Una pantalla negra no ilumina el cuarto y una línea amarilla fina dice "suena" sin despertar a nadie.
- La categoría entera vende con degradados "aurora", lunas, nubes y fotos de bosques. Una página negra con una línea es la única que se reconoce entre diez capturas.
- El color igual a sonido es una ley simple: si hay amarillo, hay audio; si no, no. Esa ley es la base del Horizonte, de la Marea y de la página nocturna.

### 1.2 Lo que ha pasado al verla terminada

De día, la app se mira más de lo que se escucha: se elige una mezcla, se abre Capas, se ajusta el temporizador. En esas pantallas Grafito muestra negro con texto, y lo que de noche es cuidado, a las seis de la tarde parece una app sin acabar. El dueño lo dice con precisión: le ve poco color y pide contrastar con imágenes vivas de hogueras, lluvia, mar, con una pincelada expresiva y colorista, cuidando la propiedad intelectual.

Tres cosas de esa petición hay que respetar tal cual y una hay que traducir:

- **Imágenes vivas de hogueras, lluvia, mar.** Sí, y de las once texturas. Pero generadas en el dispositivo, no descargadas ni incrustadas: es la misma promesa que el sonido ("se genera aquí, sin archivos ni descargas") y es la única forma de que la pintura sea nuestra.
- **Pincelada expresiva y colorista.** Sí: trazo corto, pigmento saturado, borde de empaste. Es una técnica, nadie la posee.
- **Cuidado con la propiedad intelectual.** Sí, y más de lo que parece necesario: §8 explica por qué no se nombra a nadie ni se parte de ninguna obra aunque esté en dominio público.
- **"Al estilo de" un pintor concreto.** Esto es lo que se traduce. El estilo no se puede proteger, pero el nombre sí es marca de museos y herederos, y una escena que "sea" un cuadro famoso convierte la app en un producto derivado. Lo que se toma es el lenguaje (pigmento alto, pincelada visible, complementarios); lo que no se toma es ninguna composición, ningún motivo reconocible, ningún nombre.

### 1.3 Lo que no se negocia

Tomado de 03 y de la nota de propiedad intelectual, válido para los tres caminos:

- Entre las 21:00 y las 07:00 y en la pantalla Noche no se vende nada, y la pantalla no ilumina el cuarto. La pintura se funde a negro a las 21:00 y no vuelve sola.
- El sonido nunca se graba, se genera; la pintura tampoco: sin imágenes en el paquete para las piezas vivas, sin red, sin cuenta.
- Un solo color de interfaz, el Índice, y solo mientras suena. La pintura es papel, no acento; ningún texto toma color de la paleta.
- Texto sobre pintura, nunca. Nombre, filas, barra y cualquier glifo van sobre negro o sobre un velo que garantice 4,5:1.
- No se nombra a ningún pintor, obra ni movimiento en la app, la ficha, las capturas, el código, los commits ni los ficheros del repositorio público.
- Nada de esto toca la dirección 03 (tokens, componentes, decisiones C01 a C65), el motor de audio, el icono, la hoja Pro ni el reparto gratuito: cuando se apruebe un camino, 03 recibirá una nota de una línea en §12 que apunte aquí.

---

## 2. El lenguaje pictórico propio: Pigmento

Nota completa: `docs/design/color/lenguaje-pictorico.md`; muestras pintadas con código en `docs/design/color/paleta.html` (ábrala en un navegador; no necesita red).

### 2.1 Tres principios

1. **Trazo corto, pigmento alto, borde duro.** Lo que da calor es la saturación junta y la textura de empaste, no el degradado suave. Prohibidos los desenfoques y los gradientes radiales blandos: eso es el "aurora" que comparten las apps de la categoría.
2. **Un motivo por textura, abstracto antes que figurativo.** Lluvia es dirección y ritmo, no gotas; hoguera es lenguas que suben con un núcleo de calor, no un fuego dibujado; el mar es campo de flujo, no olas con cresta. Nada de paisaje, árboles, casas, estrellas ni luna.
3. **La pintura es fondo, nunca figura.** Texto, Índice y horizonte van encima, con velo y zonas de reserva; la pintura jamás supera cierta luminancia ni toca un píxel de texto.

### 2.2 La pincelada

Todo trazo es un listón: una curva central con ruido, un grosor variable (huso para casi todo, cono para las lenguas de fuego) y un relleno con gradiente de tres paradas donde dos coinciden: tinta clara hasta el 38 %, tinta base después, banda de sombra en el borde. El salto seco es el relieve del empaste; no hay difuminado. Los campos de flujo del mar y del ventilador nacen de un ruido de dos octavas con curvatura limitada, para que nada se cierre en espiral. Densidad entre 420 y 1.300 listones por ventana de 402 × 240, plena en la banda del horizonte y cayendo al 25 % a 120 pt de ella. Semilla determinista por mezcla y día: la pintura de hoy no es la de ayer y no cambia durante la sesión.

La hoguera se rehízo tras el jurado: la primera versión se leía como trigo seco. Ahora las lenguas son anchas en la base (8 a 14 pt) y se estrechan al subir, un 30 % de ellas son negras, la llama clara solo existe en un núcleo central del 40 % del ancho, el rojo brasa va a los bordes y la madera quemada fuera, con media docena de brasas de 2 a 3 pt por encima.

### 2.3 Paleta por textura

Tres o cuatro tintas por textura, de la más clara (el "toque de luz", 8 a 12 % de los trazos) a la base. Contraste sobre negro entre paréntesis. Ninguna tinta pasa a texto ni a glifos.

| Textura | Motivo | Tintas | Temperatura |
|---|---|---|---|
| Blanco | Campo abstracto fino | `#E3E0D8` hueso (15,9) · `#A9B8C6` gris azulado (10,4) · `#5E6B78` pizarra (3,9) | Neutra fría |
| Rosa | Campo abstracto medio | `#F3D2B8` arena cálida (14,7) · `#E8A598` coral pálido (10,3) · `#C77B8A` rosa viejo (6,6) · `#7A4A5E` ciruela (3,0) | Cálida |
| Marrón | Campo abstracto grueso | `#D9A66B` ocre claro (9,6) · `#B07A4A` tierra (5,7) · `#7A4E2E` castaño (3,0) · `#4A3222` tabaco (1,8) | Cálida |
| Lluvia | Trazos oblicuos a 72° | `#B9CDD9` gris agua (12,8) · `#7FA7C9` azul lluvia (8,3) · `#4A6B8A` azul noche (3,8) · `#2E4A5E` pizarra azul (2,3) | Fría |
| Ventilador | Arcos concéntricos | `#D7DBE0` aluminio claro (15,1) · `#B8BFC9` aluminio (11,3) · `#7C8794` gris frío (5,8) · `#4F5862` gris hierro (2,9) | Fría neutra |
| Océano | Campo de flujo | `#CFE7E0` espuma (16,2) · `#3FA7B0` turquesa (7,4) · `#1F6F8B` petróleo (3,7) · `#0F3C56` profundo (1,8) | Fría |
| Trueno | Campo oscuro con una grieta fija | `#C9C4E8` relámpago lila (12,5) · `#8E7FB8` violeta claro (5,9) · `#6A5A8E` violeta tormenta (3,5) · `#3A3250` añil oscuro (1,8) | Fría |
| Hoguera | Lenguas con núcleo central | `#FFB15C` llama clara (11,7) · `#F08A24` naranja fuego (8,4) · `#D9442B` rojo brasa (4,8) · `#5A2A14` madera quemada (1,8) | Muy cálida |
| Arroyo | Cintas sinuosas | `#BFE3C8` espuma verde (15,0) · `#5FB08A` verde agua (8,1) · `#2F7A5A` musgo (4,1) · `#1E4A3A` poza (2,1) | Fría húmeda |
| Viento | Hebras largas tumbadas | `#E8E0C4` trigo claro (15,9) · `#C9C2A8` hierba seca (11,8) · `#8FA07A` oliva pálido (7,5) · `#5F6B55` oliva oscuro (3,7) | Cálida seca |
| Cabina | Bandas horizontales con grano | `#D6CFC8` lino (13,6) · `#B9A9A0` beige rosado (9,3) · `#8A7F96` gris malva (5,6) · `#5B5566` malva oscuro (2,9) | Neutra tibia |

Por qué así:

- Los tres ruidos de color son la mitad del uso y no tienen imagen; se resuelven como campos abstractos que solo se distinguen en el grano (fino, medio, grueso), exactamente como se distinguen en el espectro.
- La hoguera es la paleta más caliente y la más cercana al Índice; se evita el amarillo puro (la llama clara está a 36° de matiz frente a los 47° del Índice) y va bajo velo, para que el amarillo del horizonte siga siendo lo más luminoso.
- El trueno no destella: una sola grieta lila fija en toda la sesión. Un rayo que parpadee sería un flash en un cuarto a oscuras y una mentira, porque el motor no sincroniza nada con la imagen.
- Sobre el océano no entra ningún pigmento cálido, y sobre la hoguera ningún azul: la pareja azul más ocre o amarillo en el mismo motivo es la combinación más asociada a la pincelada que no queremos imitar.
- Las mezclas de la casa heredan por capa dominante: "Rosa y lluvia" pinta lluvia sobre el campo rosa; "Mar y viento" océano con las dos tintas oliva oscuras del viento encima; "Marrón y hoguera" las lenguas sobre tabaco; "Pared" el campo marrón solo.

### 2.4 Cómo responde al sonido

La pintura escucha solo dos cosas que el motor ya publica: el RMS maestro (convertido a `presence` y `level`) y la fase de la Marea. Y solo mueve luz y aliento:

- `presence` la levanta (0 a 1 en 2 s) y la apaga (1 a 0 en 3 s). Sin sonido no hay pintura, igual que no hay Índice.
- `level` mueve solo la opacidad del 18 % de trazos marcados "vivos" (0,45 a 0,85), con el mismo suavizado del horizonte y un tope de cambio por segundo. Nunca el matiz, la posición, la escala ni el número de trazos.
- La Marea desliza el campo entero ±6 pt en la dirección del motivo, redondeado a píxel: una respiración, no un oleaje.
- La pausa seca la pintura (opacidad 0,3) sin fundirla: pausa no es noche.

El ruido blanco y rosa tienen RMS casi plano y por tanto una pintura casi quieta, y eso es verdad, igual que el horizonte. Lluvia, océano, trueno y hoguera son los que respiran.

### 2.5 Lo que lo hace nuestro

La pincelada nace del sonido y es generativa y determinista como el ruido. Once motivos de un solo gesto. El negro sigue mandando: la pintura es una ventana en una página negra, no una página pintada, y se apaga a las 21:00. Ninguna app de la categoría se atreve a apagar su color por la noche; ese es el gesto propio. Y empaste sin desenfoque: lo contrario del "aurora" de la competencia y lo contrario del render fotográfico.

---

## 3. La regla de día y noche

Una sola constante horaria, `NightWindow` = 21:00 a 07:00 (03, C40), y dos gestos distintos que el jurado pidió separar:

- **Atenuar.** Con una hoja encima (Temporizador, Marea, Capas) o la app al fondo, la pintura baja a opacidad 0,3 en 1,5 s y vuelve en 800 ms al cerrar la hoja o volver. Abrir el Temporizador de día no mata la pintura para toda la sesión.
- **Fundir.** Al entrar en Noche o en Madrugada, cuando la página pasa a nocturna, cuando el reloj llega a las 21:00 con la app delante, o con luminancia reducida del sistema, la pintura se funde a negro en 3 s (250 ms con Reducir movimiento) y la vista deja de existir (nil, no opacidad 0; nada queda en memoria detrás de Noche). No vuelve sola: ni a las 07:00, ni al desbloquear. Vuelve solo con la salida deliberada de la página nocturna (tocar el nombre de la mezcla) y solo entre las 07:00 y las 21:00.
- **Noche, Madrugada y página nocturna:** negro, una tinta, horizonte a 2 pt, ningún píxel de pintura. La hoja Pro no se abre de noche, así que no hay nada que apagar en ella.
- **Fuera de la app** (Live Activity, StandBy, widgets, Watch): sin pintura, una tinta, como fija 03.

La "brasa" nocturna (un solo listón de madera quemada al 10 % bajo el horizonte) queda como experimento de 1.1, apagado por defecto: si en la prueba de la mesilla a oscuras se ve desde la almohada, se descarta.

---

## 4. Los tres caminos

Las tres maquetas están en `docs/design/color/`: `camino-contenido.html` (A), `camino-lienzo.html` (B) y `camino-pleno.html` (C). Cada una pinta sus pantallas con código al abrirse; no necesitan red. Las notas de cada camino, con costes por pantalla, están en los `.md` del mismo nombre.

### 4.1 Puntuaciones del jurado

Tres lentes, cada una de 0 a 10: dirección creativa, ingeniería, propiedad intelectual. Las puntuaciones se dieron a la primera versión de las maquetas; después se aplicaron los hallazgos (§5) y los caminos que aquí se describen son los revisados.

| Camino | Dirección creativa | Ingeniería | Propiedad intelectual | Suma |
|---|---|---|---|---|
| A · Color contenido | 6 | 8 | 8 | 22 |
| B · Lienzo vivo | 7 | 5 | 7 | 19 |
| C · Pintura plena | 4 | 3 | 4 | 11 |

Lectura: la dirección creativa prefería B por un punto porque A, en su primera versión, dejaba la página principal negra y no respondía a la queja; ingeniería y propiedad intelectual prefieren A con claridad; C pierde en las tres lentes.

### 4.2 Camino A · Color contenido (revisado)

**Tesis.** La pintura es contenido, como la receta de una mezcla, no interfaz: vive donde se elige algo y entra en la página de día como una ventana alrededor del horizonte. Grafito no cambia ni un token.

**Dónde aparece.** Página principal de día: ventana de 240 pt centrada en el horizonte, densidad plena en la banda del horizonte y al 25 % a 120 pt, velo del 35 % en el centro y 75 % en los bordes, franja de reserva de 24 pt bajo el Índice y velo del 90 % bajo las filas; nombre, filas y barra sobre negro. Mezclas: banda de 64 pt a sangre por la izquierda en las cuatro mezclas de la casa; las propias y Ajustes sin pintura ("la casa pinta, lo tuyo es tuyo"). Capas: una regla vertical pintada de 4 pt en el margen izquierdo por fila, viva si la capa suena. Tienda: una captura nueva. Icono: sin cambios, negro. Hoja Pro: gris, sin pintura (la maqueta conserva una pieza de cabecera para comparar; el estudio recomienda quitarla).

**Pros.** Es el único camino que deja Grafito intacto donde se le reconoce y a la vez pone color al abrir la app de día. Las piezas pequeñas (reglas, bandas, captura) se generan en tiempo de compilación como PNG de pocos KB: cero motor de pintura en runtime para ellas. Riesgo de marca bajo, de batería mínimo, de propiedad intelectual mínimo.

**Contras.** El color sigue siendo contenido, no la seña de la app: si el dueño quiere "una app pintada", A no se lo da. La ventana de la página es la única parte con coste real.

**Coste.** 3 a 3,5 semanas de una persona; 2 a 2,5 sin la ventana de la página.

### 4.3 Camino B · Lienzo vivo (revisado)

**Tesis.** La página de día es la mezcla que suena, pintada en una ventana de 240 pt alrededor del horizonte: cada capa activa pone su motivo y su color en proporción a su nivel, los campos debajo y las camas encima. La pintura es sonido como el Índice: nace con el audio, respira con el RMS, se desliza con la Marea, se seca al pausar y se funde a las 21:00.

**Lo que cambió tras el jurado.** La primera versión pintaba toda la página bajo velo y pasaba el texto a una sola tinta; contradecía "texto sobre pintura, nunca", aplanaba la jerarquía y dejaba texto2 en 2,4 a 3,6:1. Ahora pinta solo la ventana, con negro fuera y texto2 intacto. Con ese cambio, B es la ventana de A con composición por niveles de capa: la diferencia entre A y B es ya de grado, no de clase.

**Pros.** La pintura cuenta la mezcla sin leer: se ve cuánto pesa cada capa. Es la pieza más propia del lenguaje (nace del motor).

**Contras.** Exige el motor de pintura completo en runtime desde 1.0 (actor, raster en segundo plano, capa viva, tests de luminancia). Sin medir batería no hay cifra honesta. Capas, Mezclas y hojas quedan sin color salvo injertos de A.

**Coste.** 5 a 6 semanas de una persona.

### 4.4 Camino C · Pintura plena (revisado)

**Tesis.** De día, página y Capas son una pintura a sangre de la mezcla, con tipografía, hairlines e Índice de Grafito encima sobre velo del 78 %. Mezclas lleva la banda de A, el Temporizador conserva la hoja gris con una cabecera pintada de 110 pt, la hoja Pro va sin pintura. La noche sigue siendo negra.

**Lo que cambió tras el jurado.** Se suprimió el segundo acento (texto en color de la paleta), que rompía la ley de un Índice por pantalla y no cumplía AA; se quitó la galería de bandas de 88 pt y la pieza sobre el precio, que eran el patrón visual del catálogo y el paywall de las apps de suscripción; las hojas conservan la hoja porque una hoja de SwiftUI no ve el lienzo de debajo; Mar lento perdió el marrón sobre el turquesa; y el camino se renombró porque su nombre anterior aludía a un movimiento artístico.

**Pros.** Es la respuesta literal a "le veo poco color": de día la app es cálida sin matices.

**Contras.** Convierte la app de día en una app de fondos pintados, el territorio de la competencia; la diferencia pasa a ser la calidad de la pintura y no el instrumento. Texto sobre pintura en toda la página, aunque sea sobre velo, contradice el lenguaje §5. Memoria: 12,6 MB por pieza a sangre a 3x más la capa viva; con audio de fondo toda la noche la app debe quedar pequeña para no ser expulsada. Batería claramente mayor en OLED, sin cifra hasta medir. Obliga a renombrar la dirección y rehacer la ficha.

**Coste.** 8 a 10 semanas de una persona.

---

## 5. Lo que dijo el jurado y cómo se aplicó

Hallazgos de severidad alta, con la corrección ya aplicada en maquetas y notas:

| Hallazgo | Dónde | Corrección aplicada |
|---|---|---|
| La hoguera se leía como hierba o trigo: lenguas finas, densas y uniformes, sin negro ni foco | Las tres maquetas y lenguaje §2 | Lenguas cónicas de 8 a 14 pt en la base, 30 % de negro, núcleo central de llama clara, brasa en los bordes, media docena de brasas |
| Marrón o beige sobre el flujo turquesa reproducía la pareja azul más ocre | Mar lento (C), Mar y viento (A) | Ningún pigmento cálido sobre el océano; Mar y viento solo con las dos oliva oscuras al 70 % |
| El segundo acento rompía "un Índice por pantalla" y no cumplía AA como texto | C | Suprimido; estado y nivel en texto y texto2 |
| Pieza sobre el precio y galería de bandas de 88 pt eran el patrón del paywall y el catálogo de suscripción | C | Hoja Pro gris sin pintura; Mezclas con la banda de 64 pt de A, solo en las de la casa |
| Al abrir la app de día seguía todo negro | A | Ventana de 240 pt alrededor del horizonte en la página de día |
| Texto sobre pintura en toda la página y una sola tinta | B | Pintura solo en la ventana; negro y texto2 fuera |
| `ImageRenderer` es `@MainActor`: miles de listones en el hilo principal al abrir la app | Los tres | Geometría en un actor, raster en cola de fondo con `UIGraphicsImageRenderer` o `CGContext`; `ImageRenderer` solo en snapshots |
| Memoria: 12,6 MB por pieza a sangre, hasta 25 MB por pantalla y 14 MB más en Mezclas | C | Una sola capa viva recortada a la banda; bandas por fila visible; todos los rasters a nil al entrar en Noche o al fondo |
| Una hoja de SwiftUI no ve el lienzo de debajo | C | Las hojas conservan la hoja; como mucho una cabecera de 110 pt rasterizada una vez |
| La captura contaba texturas ("Once sonidos") y prometía "nada se repite", que el código aún no sostiene | A y C | Titular común "Lo que suena, se pinta." y texto de reserva de la ficha: "Como el sonido: se genera aquí, sin archivos ni descargas." |
| El icono pintado rompía 11 §2.1 (fondo plano, sin segundo color) y obligaba a dos iconos | A | "La regla y la marea" se mantiene en negro en los tres caminos; el color de tienda va en las capturas |
| Icono y capturas ya nacen fuera del dispositivo: un icono y una captura pintados cuestan 2 a 3 días con cero coste en runtime | Los tres | Paso 0 común en el plan (§7): portar el generador a Swift, pintar una captura, enseñarla, decidir después |
| La pintura seguía en la jerarquía bajo Noche | Los tres | Sin `TimelineView` propio; a nil con `nightPhase.isNight`, `NightWindow` y luminancia reducida; test en `NightScreenTests` |
| Las notas identificaban obras y un museo por circunloquio inequívoco | lenguaje §7, propiedad intelectual §5 | Reescritas: las trampas se describen por lo que no se hace, sin identificar a nadie |
| El nombre del camino C aludía a un movimiento artístico | C | Renombrado "Pintura plena"; en ramas, commits, PR y docs solo Pigmento y descripciones |

Hallazgos de severidad media aplicados: pastillas de 32 pt sustituidas por la regla vertical de 4 pt (A); densidad con centro y descanso (B); franja de reserva de 24 pt al 80 % y halo seco de 3 pt bajo el Índice (B y C); atenuar separado de fundir (los tres); barra inferior sobre negro sin material (B); capa viva solo en opacidad, Marea con desplazamiento redondeado a píxel, sin capa viva con Aumentar contraste (B y C); cifras de batería retiradas hasta medir con MetricKit; piezas pequeñas de A generadas en tiempo de compilación como PNG (el camino baja de 4 a 3,5 semanas con la ventana incluida); mismo generador aleatorio en Swift que en las maquetas para que los snapshots sirvan.

---

## 6. Recomendación del estudio

**Camino A con dos injertos de B: la ventana del horizonte en la página de día y el titular de tienda común.** Es decir, el camino A tal como queda revisado en §4.2.

Por qué:

1. **Responde a la queja donde se produce.** Al abrir la app de día hay color, y está donde está el sonido: alrededor del horizonte. Mezclas y Capas ganan color en las pantallas que más se miran de día. La tienda enseña la pintura en una captura.
2. **No toca lo que hace distinta a la app.** Noche, Madrugada y página nocturna siguen negras; el icono sigue siendo el único de la categoría cuyo color es una línea; la hoja Pro sigue siendo un objeto de 29,99 € una vez, en gris, sin pintura que venda.
3. **Cabe en el presupuesto y en el riesgo.** 3 a 3,5 semanas, sin Metal, sin dependencias. La mayor parte son PNG de compilación; solo la ventana lleva motor en runtime, y recortado a 3,5 MB.
4. **Deja la puerta abierta.** Si tras medir batería y hacer la prueba de cinco segundos el dueño quiere más, la ventana crece hacia B (composición por niveles) sin tirar nada. Si quiere menos, se apaga en Ajustes ("Pintura: de día / nunca").

Lo que el estudio recomienda **no** hacer: el camino C. No porque la pintura sea mala, sino porque convierte la app en lo que la competencia ya es, duplica la memoria de una app que debe sobrevivir toda la noche en segundo plano, y obliga a reescribir la dirección. Si el dueño lo prefiere igualmente, antes la prueba de cinco segundos de §9.

### 6.1 Variante mínima para 1.0

Si el dueño quiere algo de color antes de enviar 1.0 sin abrir el motor de pintura:

- **Las bandas de las cuatro mezclas de la casa en Mezclas** (PNG de 64 × 92 a 2x y 3x, generados en compilación con semilla fija; unos 200 KB en total) con su velo, su atenuado y su fundido nocturno.
- **La captura nueva de la tienda** con el titular común y el texto de reserva.
- Opcional, mismo coste: las reglas de 4 pt en Capas.

Una semana y media de una persona. No toca la página principal, el motor, la noche ni el icono. La ventana del horizonte pasa a 1.1 con la medida de batería hecha.

---

## 7. Plan de trabajo si se aprueba

### Fase 0 · Generador y prueba de ojo (3 días)

- Portar el generador de listones de las maquetas a Swift: mismo LCG (1664525, 1013904223) y FNV-1a como `RandomNumberGenerator`, `Float` con redondeo a 1/4 pt, semilla fija por textura. Vive en `scripts/paint/`, hermano de `scripts/icon/IconGenerator.swift`, con `CGContext`.
- Pintar una captura (Mezclas de día) y las once muestras de la paleta a 2x y 3x. Enseñárselas al dueño en un iPhone, a la luz y a oscuras.
- Decidir aquí si se sigue con la variante mínima o con el camino entero. Hasta aquí no se toca la app.

### Fase 1 · Piezas estáticas (1 semana)

- Script `scripts/paint/generate.sh` que escribe en `Assets.xcassets` las cuatro bandas, las once reglas y la captura, con semilla fija y menos de 2 MB en el paquete.
- Mezclas: fila de la casa con banda a sangre, velo del 12 %, atenuar y fundir; `ViewThatFits` en AX.
- Capas: regla de 4 pt en `LevelRule` con opacidad por nivel; VoiceOver la ignora.
- Tienda: una captura compuesta por `screenshots.sh` desde un `-pageState`; lint de S-08 al titular.
- Pruebas: snapshots con semilla fija; pintura ausente en página nocturna y a las 21:00.
- Qué no toca: `PageView`, el motor de audio, `Ink`, Noche, el icono, la hoja Pro.

### Fase 2 · Ventana del horizonte (1,5 a 2 semanas)

- `PaintWindow` detrás del `VStack` de `PageView`: geometría en un actor, raster en cola de fondo con `UIGraphicsImageRenderer` recortado a la ventana, capa seca y capa viva de 3,5 MB cada una, capa viva solo en opacidad leída dentro del `TimelineView` del horizonte (comparte su `isFrozen`), Marea con `offset` redondeado a píxel.
- Velo y reservas: 35 % en el centro, 75 % en los bordes, franja de 24 pt al 80 % bajo el Índice, 90 % bajo las filas que entren en la ventana; halo seco de 3 pt del horizonte.
- Reglas de fase: atenuar con `sheetPresented` y `scenePhase`; fundir y nil con `nightPhase.isNight`, `NightWindow.contains(now)`, `isLuminanceReduced`.
- Ajustes: fila "Pintura: de día / nunca". Se apaga sola con Reducir movimiento más Aumentar contraste a la vez.
- Pruebas: snapshots de las cuatro mezclas de la casa; luminancia media del raster velado ≤ 0,08 fuera de la banda y máximo Y ≤ 0,28 tras velo; test en `NightScreenTests` de que la vista de pintura no existe bajo Noche ni a las 21:01.
- Qué no toca: `Ink` y las tintas de texto (fuera de la ventana no hay pintura), el motor de audio, la hoja Pro, el icono, Live Activity, StandBy, widgets, Watch.

### Fase 3 · Medida y cierre (3 días)

- Build interna con MetricKit: una hora de página negra frente a una hora pintada, de 20:00 a 21:00, `MXDisplayMetric.averagePixelLuminance` y `MXCPUMetric`. Hasta tener el dato no se publica ninguna cifra de batería.
- Prueba de cinco segundos: la página de día con ventana junto a la página Grafito, a diez personas, "¿qué hace esta app?". Si más de tres dicen "fondos" o "pinturas", se sube el velo o se reduce la ventana a 180 pt antes de enviar.
- Ficha: titular común en la captura, sin estilos, autores ni cuentas de texturas; pasar el lint de S-08.

Total: 3 a 3,5 semanas de una persona para el camino completo; la variante mínima son las fases 0 y 1.

---

## 8. Propiedad intelectual y marca, en corto

Nota completa, con fuentes y fechas: `docs/design/color/propiedad-intelectual.md`. No es asesoramiento legal; antes de registrar marcas, firmar un encargo o publicar material promocional conviene una revisión profesional en España y, si se vende en EE. UU., otra allí.

Lo esencial:

- Un **estilo** (pincelada visible, empaste, color saturado) no se puede proteger. Una **obra concreta** sí, mientras dure el plazo; reproducirla, recortarla o "versionarla" sigue siendo reproducción.
- Las obras de pintores fallecidos hace más de 70 años son de dominio público en la UE, el Reino Unido y, con matices por fecha de publicación, EE. UU. En España el plazo es de 80 años para autores fallecidos antes de diciembre de 1987. Para pintores del siglo XIX no hay duda en ningún mercado. Aun así no se parte de ninguna obra: no aporta nada y abre otros frentes.
- Los **nombres** de pintores célebres y de algunas obras son marcas registradas de museos, fundaciones y herederos, en clases que incluyen software; se han opuesto a registros de terceros y Apple retira fichas por palabras clave con marcas ajenas. Por eso no se nombra a nadie ni se escribe "estilo de", "inspirado en" o "a lo".
- Las imágenes generadas **solo con prompts** no son registrables en EE. UU. y, desde agosto de 2026, llevan obligaciones de transparencia en la UE. Si entra IA en el flujo, nunca con prompts que nombren artistas u obras y siempre con repintado humano documentado. Las piezas de este proyecto se generan con código propio y parámetros documentados: autoría humana demostrable con el historial del repositorio.

**Sí:**

- Pintar con código propio (SVG, Core Graphics, canvas), con parámetros y semillas documentados, y guardar el historial como prueba de autoría.
- Si se quiere mano humana, encargar obra original con cesión exclusiva, mundial y por todo el plazo, creada desde cero, con garantía de originalidad y ficheros fuente.
- Registrar las piezas finales (Registro de la Propiedad Intelectual en España; Copyright Office en EE. UU.) y, si el tema visual se vuelve seña de la app, su nombre como marca.
- Describir lo que se ve: "pintura de pincelada viva", "color nocturno", "escenas pintadas", "generada en tu iPhone".

**No:**

- No copiar, calcar, recortar ni "homenajear" ningún cuadro ni fotografía de museo, aunque esté en dominio público.
- No incrustar imágenes bajadas de internet ni de bancos "gratuitos" sin licencia verificada, ni en maquetas ni en la app.
- No nombrar pintores, obras, museos ni movimientos en la app, la ficha, las palabras clave, las capturas, el repositorio público, los commits ni la publicidad.
- No publicar imágenes cien por cien de IA como arte final ni usar prompts que nombren artistas, obras, museos o colecciones.
- No usar la estética para vender nada entre las 21:00 y las 07:00 ni en la pantalla Noche.
- No aceptar de un ilustrador externo obra "basada en" referencias sin ver cuáles son.
- No contar texturas ni prometer "nada se repite" en la ficha hasta que el código lo sostenga (C04, C53).

---

## 9. Decisiones que le tocan al dueño

| # | Decisión | Recomendación del estudio | Por qué |
|---|---|---|---|
| 1 | ¿Camino A con la ventana del horizonte (3 a 3,5 semanas), B (5 a 6) o C (8 a 10)? **Tomada el 19-11-2026: sí, A con la ventana.** | **A con la ventana** | Responde a la queja donde se produce sin tocar la noche, el icono ni la venta; 22 puntos del jurado frente a 19 y 11 |
| 2 | ¿Icono y hoja Pro siguen sin color? **Tomada el 19-11-2026: sí, sin color.** | **Sí** | El icono es el único de la categoría cuyo color es una línea; la hoja Pro es un objeto de 29,99 € una vez y la pintura sobre el precio es el patrón del paywall de suscripción |
| 3 | ¿Variante mínima en 1.0 (bandas de la casa y captura, 1,5 semanas) y ventana en 1.1, o todo en 1.0? **Tomada el 19-11-2026: sí, la variante mínima en 1.0 y la ventana en 1.1 tras medir batería.** | **Variante mínima en 1.0** | La ventana merece la medida de batería y la prueba de cinco segundos antes de enviar; las bandas y la captura no arriesgan nada |
| 4 | ¿Reglas de 4 pt en Capas, o Capas sin color? | **Reglas** | Coste de un día; dan color a la pantalla que más se mira de día sin tocar el control ni mover el nombre |
| 5 | ¿La pintura se puede apagar en Ajustes? | **Sí, "Pintura: de día / nunca"** | Hay quien quiere la página negra también de día; y es la salida si una medida de batería sale mal |
| 6 | ¿Prueba de cinco segundos con diez personas antes de la ventana? | **Sí, en fase 0 con la captura y en fase 3 con la app** | Es la única forma de saber si la ventana se lee como "sonido" o como "fondos" |
| 7 | ¿Experimento de la brasa nocturna en 1.1? | **Apagado por defecto, decidir con la prueba de la mesilla** | Un solo listón al 10 %; si se ve desde la almohada, se descarta |
| 8 | ¿Encargo a un ilustrador humano en algún momento? | **No para 1.0 ni 1.1** | El código ya da el lenguaje; si se encarga, con el contrato de §8 y sin referencias concretas |

Fecha sugerida para decidir: antes del 27-11-2026, junto con la hoja de prueba del icono, para que la fase 0 entre en la semana siguiente. Las decisiones 1, 2 y 3 se tomaron el 19-11-2026; las 4 a 8 siguen abiertas y no bloquean la 1.0.

**Estado (19-11-2026).** En la 1.0 entra solo la variante mínima de §6.1, fases 0 y 1 de §7 en su parte estática: las bandas pintadas de las cuatro mezclas de la casa en la hoja Mezclas (PNG de 64 × 288 a 2x y 3x generados en compilación por `scripts/paint/generate.sh`, con semilla fija por mezcla y la composición en los 92 pt de arriba, para que ninguna fila la escale; `HousePaint`, `MixesSheet`) y la captura nueva de la tienda (la séptima de `scripts/screenshots.sh`, titular común "Lo que suena, se pinta."). La regla de día y noche de §3 es una sola función pura con test, `PaintPolicy.showsHousePaint`: dentro de `NightWindow`, en la página nocturna y con Reducir transparencia o Aumentar contraste no hay banda y la fila es la de siempre; si la regla cambia con la hoja abierta la banda se funde en 2 s (0,25 s con Reducir movimiento) y no vuelve sola. Las bandas no escuchan el motor ni se atenúan bajo otra hoja (el "atenuar" de §3 es de la ventana; §6.1 dice "su atenuado": a confirmar por el dueño cuál de las dos lecturas vale). La captura 7 va sin subtítulo: el texto de reserva de §5 habla de pintura generada en el dispositivo, que es la ventana. Para la 1.1 quedan la ventana pintada del Horizonte (fase 2) tras la medida de batería con MetricKit (fase 3), las reglas de 4 pt de Capas, el ajuste "Pintura: de día / nunca" y la prueba de cinco segundos. Icono y hoja Pro siguen sin color. Registro en `docs/lanzamiento/DECISIONES.md` (D-55 a D-57) y `docs/agents/ESTADO.md` ("Pigmento 1.0").

---

## 10. Ficheros de esta exploración

En `docs/design/color/`:

- `lenguaje-pictorico.md`: el lenguaje Pigmento completo (principios, paleta, pincelada, respuesta al sonido, día y noche, convivencia con el Índice, accesibilidad, trampas de copia, coste de render).
- `paleta.html`: once muestras de 200 × 200 pintadas con código y la jerarquía ventana, velo, horizonte.
- `propiedad-intelectual.md`: la nota legal con lo verificado, la opinión del equipo, la lista de sí y no y las fuentes.
- `camino-contenido.html` y `camino-contenido.md`: camino A, siete pantallas.
- `camino-lienzo.html` y `camino-lienzo.md`: camino B, seis pantallas, con movimiento simulado del RMS y de la Marea.
- `camino-pleno.html` y `camino-pleno.md`: camino C, siete pantallas.

Todos los HTML son autocontenidos: fuentes del sistema, colores por variables CSS, pinturas en canvas con pinceladas generadas por código y semilla fija. Ninguno incrusta imágenes externas ni rutas absolutas; se abren sin red.
