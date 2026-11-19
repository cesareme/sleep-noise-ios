# SleepNoise · 11 · Icono y App Store

**Equipo E8 (Icono y tienda) · 16 de noviembre de 2026 · Documento 11 de la serie de diseño · Fase de especificación · Reconciliación del 16-11-2026 aplicada (§12)**

**Insumos leídos completos:** `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§0–§6: manda sobre 03 y sobre el plan; sus deltas para 11 y las reglas de §3 vocabulario, §4 reparto y §5 alcance están aplicados en §12), `03-DIRECCION-DE-DISENO` consolidado (§3 tokens, §4 componentes, §5 inventario y §8.3 puertas son ley aquí), `04-SISTEMA-FUNDAMENTOS` (nombres de componentes y medidas), `10-GUIA-DE-COPY` (toda cadena de interfaz que aparece en una captura se copia de ahí letra a letra; las cadenas de tienda de §5e.15 también), el brief del director creativo para E8, `tokens.md`, `grafts.md`, `decisions.md`, `00-BRIEF-CREATIVO` (P1-P12, listas negras §7), `02-MATERIALES` (§2 color, §3 movimiento, §4 háptica, §6 iconografía, §7 accesibilidad), `concepts/marea.md` entero (4.14 icono, 4.15 capturas, 12 ecosistema, 13 accesibilidad, 14 cadenas), y por grep de icono / capturas / preview / ficha los otros tres conceptos (`grafito.md` §4-5 y §15.7, `dial.md` 4.14-4.15, `silencio.md` §6-7); el código de `main` (`AccessPolicy.swift`, `SoundID.swift`, `MixerModel.swift`, `Features/Breathing`, `Features/Timer`, `Features/Paywall`, `Features/Library`, `Localizable.xcstrings`, `Info.plist`, `SleepNoise.storekit`, `Assets.xcassets/AppIcon`); `INVESTIGACION-MERCADO-SUENO` §1, §5.2 (lo que no se afirma) y §7.5 (qué comunicar); `COMPETIDORES` §1 y las fichas de diseño visual; `REVIEW-PR3` ("Encaje" y hallazgos de tienda: la descripción del IAP de 127/149 caracteres donde App Store Connect admite 45). Donde 05, 07 y 08 (anteriores a la reconciliación) y la reconciliación difieren, manda la reconciliación; en geometría de la página manda 05, en la redacción de la prueba 08 (= 10 §5e.3), en la fila Temporizador del primer uso 07, en la hoja Capas 03 consolidado (§4.10).

**Convenciones.** Medidas en pt para 393 × 852 (iPhone 17 Pro, Dynamic Type Large) en todo lo que es pantalla; el icono se cota en **px sobre un lienzo de 1024** porque así lo exige Icon Composer y así lo cotó 03 §5 (fila 27); las capturas se cotan en pt sobre su propio lienzo de tienda (440 × 956 pt, exportado a 3×), declarado en §2.2. Hex: solo los de 03 §3 (`negro #000000`, `hoja #1C1C1E`, `grafito #1E1D1B`, `trazo #2A2A2E`, `trazo-hoja #38383B`, `texto #E8E4DC`, `texto2 #9C9A96`, `texto3 #6E6C68`, `texto-noche #A2A09A`, `índice #F0C020`, `índice-noche #BA941C`, y las variantes "Aumentar contraste" `índice-ac #FFD23C`, `texto2-ac #B4B2AE`, `texto3-ac #7A7672`, `trazo-ac #3A3836`: quince tokens nocturnos; de los de papel (03 §3.3, marcados 1.1 por C32) esta entrega usa solo `tinta #1E1C19` y `ocre #8A6508`, y solo en la apariencia Clear claro del icono, que es del sistema y no un modo claro de la app). Textos de interfaz y de tienda en ES con EN entre corchetes; es-419 solo donde difiere. **[a medir]** marca lo no verificado en dispositivo o en App Store Connect; **[spike I0-n]** lo que depende de un spike de ingeniería (los de la reconciliación C45: I0-1 medidor RMS, I0-6 contraste bajo rojo, I0-7 timbre en bus; I0-1 lo hereda esta entrega de 03 §8.1); **[E2]…[E7]** lo que esta entrega toma de otra y no redefine. Las cadenas de §5.e son definitivas: son las que se suben a App Store Connect, y las de la app citadas en §5.e son las de 10 §5e (misma clave, mismo valor). Las `iap.*` no las compila ningún String Catalog: se introducen en App Store Connect (producto `com.cesareme.sleepnoise.pro`, localizaciones es-ES / es-MX / en-US) y se copian tal cual a `SleepNoise.storekit`. Los números que se enseñan al usuario son los del código (reconciliación §1 regla 8): `displayPrice` y `displayName` de StoreKit; ninguna cifra de precio escrita a mano en ninguna superficie de la tienda (C02).

Lo que esta entrega **no** hace: no rediseña ninguna pantalla de la app. Las capturas enseñan las pantallas tal como las especifican E2, E3, E4, E5 y E6; cuando una captura necesita un estado concreto de una pantalla, lo nombra con la clave de esa entrega. Si una captura y una especificación no coinciden, manda la especificación y se repite la captura: una captura nunca es una maqueta.

---

## 1. Intención (la pregunta P10 de cada superficie)

| # | Superficie | Pregunta a la que responde | Lo que debe sentirse en cinco segundos |
|---|---|---|---|
| I | **Icono** "La regla y la marea" | *¿Qué objeto es este?* | Un objeto grabado en un panel negro, no una luna ni una nube: una línea quieta de la que se levanta una ola que sube deprisa y baja despacio. Reconocible a 29 pt entre los diez de la categoría. Sin letra, sin nombre: no depende de la marca (C10). |
| C1 | **Captura 1** · "Un solo pago." | *¿Qué me va a pasar con el dinero?* | La ausencia de suscripción es la primera noticia; la cifra la pone la tienda en "Compras dentro de la app", nunca la captura (C02). Debajo, la página sonando: el objeto que se compra. |
| C2 | **Captura 2** · "Un toque y suena." | *¿Qué tengo que hacer?* | La página del primer uso en reposo: "Esta noche" cargada, el silencio dibujado como una hairline, el Disco. Nada que configurar, nada que aceptar (C33). |
| C3 | **Captura 3** · "Seis capas a la vez. Una línea cada una." | *¿Cómo lo controlo?* | Seis filas sonando en la hoja Capas; una fila es el control; bajo el dedo, el nivel se ve en una línea de color y una cifra. Sin iconos, sin cajas, sin ranuras (C19). |
| C4 | **Captura 4** · "El mar respira a seis por minuto." | *¿Qué hace esta app que las otras no?* | La línea de agua subiendo 4 y bajando 6, la palabra "inhala", la hora a la que se retira sola. |
| C5 | **Captura 5** · "A las tres de la mañana, nada." | *¿Me va a iluminar la cara?* | Noche sola (C57): negro, reloj, una frase, "+15 min". La captura más parecida a una pantalla apagada y, por eso, la más honesta. |
| C6 | **Captura 6** · "Lo que no hay." | *¿Qué me van a pedir después?* | La página "Lo que no hay" de la app (C38): sin suscripción, sin cuenta, sin rastreo, sin anuncios, sin puntuación, sin racha, sin tutorial. Pie: la etiqueta de privacidad y el peso. |
| V | **Preview muda de 30 s** (una por idioma) | *¿Cómo se usa, y qué se mueve?* | La página real sonando (C53): el horizonte nace, se descompone, una fila se arrastra, el mar respira un ciclo entero a tiempo real, la página se funde a Noche. Sin música, sin voz, sin texto animado, sin manos. |
| F | **Ficha** (nombre, subtítulo, palabras clave, texto promocional, descripción, IAP) | *¿Qué es, en una línea, y para quién?* | "SleepNoise: Sonidos para dormir" (C10). Las keywords buscan; el nombre dice; el subtítulo promete solo lo que se cumple; la ficha responde a las tres preguntas de la hoja Pro (03 §5 fila 14): cuánto (lo dice la tienda), una vez, y qué sigue gratis; nunca cuenta texturas (C04). |

Regla transversal (brief §6, fila "Capturas y app preview"): la primera captura dice lo que no hay con el dinero; la preview enseña la onda generándose, la mezcla y la Marea; nada de rejillas de iconos, nada que aparente más de lo que es (P4, Rams *honest*). Solo fondo negro (C57): no hay juego en papel (C32).

---

## 2. Anatomía

### 2.1 Icono · "La regla y la marea"

**Idea.** La regla es el horizonte de la app (la línea quieta que dibuja el silencio); la marea es la línea de agua (la única forma de la Marea, 4 partes de subida y 6 de bajada). Juntas son el único dibujo que la app hace de sí misma: una línea de la que se levanta una respiración. Es el "Un objeto, no una luna" del brief §6 y el "grabado en un panel de Braun" de 03. El icono no lleva letra ni nombre y no depende de la decisión de marca (C10): SleepNoise por defecto, cierre el 04-12-2026; el icono y la comprobación legal avanzan en las semanas 1-3 sin esperar.

**Lienzo:** 1024 × 1024 px, retícula de 32 px (x en múltiplos de 64; y en múltiplos de 32: la regla en 608 y la cresta en 352 no están en la de 64). Icon Composer, tres capas en este orden, de abajo arriba: **fondo · marea · regla**. La regla va encima: la marea arranca y aterriza con tangente horizontal en y 608, así que su trazo de 112 ocupa la misma banda (552-664) que la regla en x 384-450 y 770-832; si la marea fuera encima, la regla visible quedaría en un guion de ≈ 260 px y el objeto se leería como "un arco amarillo con una colita blanca". Con la regla encima, la línea blanca es continua de 192 a 832 y la marea solo asoma por encima de y 552: una línea de la que se levanta una respiración. Sin degradado, sin sombra, sin borde, sin texto, sin tercer elemento. Trazo **112 px** en las dos formas (el director lo subió de 56 a 112 para que a 29 pt mida 3,2 pt y no 1,6: la línea tiene que ser un objeto, no un pelo).

```
 y=0  ┌──────────────────────────────────────────────────────────────┐ 1024
      │                         negro #000000                        │
      │                                                              │
 296  │                      ┌───── cresta (576, 352) ─────┐         │
      │                 ╭────┴────╮   ◄── índice, 112 px   │         │
 352  │               ╭─╯         ╰──╮                     │         │
      │             ╭─╯               ╰────╮                │         │
      │           ╭─╯                      ╰─────╮          │         │
 552  │  ┌────────┴───────────────────────────────╰─────────┐        │
 608  │  │████████ regla · texto #E8E4DC · 112 px ███████████│        │ ← la regla va ENCIMA de la marea
 664  │  └──────────────────────────────────────────────────┘        │
      │  x=192     x=384 (despega)                        x=832      │
      │            ◄─ 192 ─►◄──────── 256 ─────────►                 │
      │              subida            bajada                        │
      │   (los flancos reales son más empinados que en este dibujo:  │
      │    73° la subida, 61° la bajada; ver la tabla)               │
      │                                                              │
1024  └──────────────────────────────────────────────────────────────┘
      márgenes: izq 192 (18,75 %) · der 192 · sup 296 (28,9 %) · inf 360 (35,2 %)
```

| Elemento | Geometría exacta (px, lienzo 1024) | Color por apariencia (Default = Dark · Clear claro / oscuro · Tinted claro / oscuro) | Nota |
|---|---|---|---|
| Fondo | Cuadrado completo; la máscara la pone el sistema | Default y Dark: `negro` · Clear: ninguno (vidrio del sistema) · Tinted: lo pone el sistema | Plano. Nunca degradado. Capa inferior. La app es solo oscura en 1.0 (C32): Default = Dark, el objeto es negro también en la pantalla de inicio clara (Dial: "el objeto es negro"). |
| **Marea** | Trayectoria desde (384, 608): **sube** en una cúbica con tangentes horizontales hasta la cresta (576, 352) y **baja** en otra cúbica con tangentes horizontales hasta (832, 608), donde su extremo recto coincide con el de la regla. Grosor 112, uniones redondeadas (*round join*), extremos rectos. Puntos de control: subida (499, 608) y (461, 352); bajada (691, 352) y (717, 608). Medido sobre estas cúbicas: pendiente máxima 73° en la subida y 61° en la bajada; radio de curvatura mínimo ≈ 60 px en la cresta y el despegue (> 56, la mitad del trazo: sin pliegue interior, con 4 px de margen; si se cambia la cresta a 563, §9.1, se recalcula). Los puntos de control de la subida se cruzan (499 > 461) a propósito: con 256 px de altura sobre 192 de base, unos puntos a un tercio (448 / 512) dejan el radio en 24 px y pliegan el interior del trazo; a partir de 0,55 del tramo el radio pasa de 56. | Default y Dark: `índice` · Clear oscuro: `índice` sobre vidrio oscuro · Clear claro: `ocre` sobre vidrio claro (el amarillo sobre un vidrio claro da 1,5:1, 03 §3.3) · Tinted: se funde con la regla en una sola capa monocroma | Capa intermedia. La cresta a y 352 deja 296 px de aire arriba. La curva comparte con `BreathCurve.value` del motor la pendiente cero en cada unión; no es un coseno elevado literal (ese tendría los puntos de control a un tercio y se plegaría). A 60 pt la subida (73°) se lee más empinada que la bajada (61°); a 29 pt los dos flancos se leen como "una línea con una elevación", y eso es lo que hay. |
| **Regla** | Trazo recto de (192, 608) a (832, 608), grosor 112, extremos rectos (*butt*): ocupa y 552-664 | Default y Dark: `texto` · Clear oscuro: `texto` · Clear claro: `tinta` · Tinted: capa monocroma (tinte del sistema) | Capa superior: tapa el arranque y el aterrizaje de la marea. 640 px de largo = 62,5 % del ancho, la misma proporción que la columna de 353 en 393 redondeada a la retícula de 64. |
| Superficie de acento | ≈ 6 % del lienzo visible (trazo de 112 px sobre ≈ 724 px de trayectoria = 8,7 % del lienzo, de los que la regla tapa ≈ 2,7 %); la regla ocupa 6,8 %. Calculado del SVG; **[a medir en el PNG exportado]** | — | Es una sola línea, nunca un relleno: cumple la regla del Índice de 03 §3.1 en su letra ("solo en líneas, nunca relleno, nunca cuerpo"). El "< 0,3 % de la superficie" de 03 §7.1 es una regla de interfaz y no aplica al icono, donde la línea tiene que ser objeto. El acento sigue siendo decisión del dueño (reconciliación §6 #1, 27-11-2026): si elige otro matiz, cambia el hex de `marea` y nada más. |

**Sobre la proporción 4:6.** 03 §5 fija "elevación 4:6 de x 384 a 832 (cresta en 576, y 352)". Con la cresta en la retícula (576), la subida ocupa 192 px y la bajada 256 (3:4 en x); el 4:6 exacto sobre 448 px pondría la cresta en x = 563 (fuera de la retícula de 64; a 29 pt la diferencia es 0,37 pt). Esta entrega construye la cresta en **576** como dice 03 y lleva la pregunta a §9.1: si el dueño quiere el 4:6 literal, cambian dos números del SVG y nada más. Lo que sí es exacto y se mide: la subida es más corta (192 frente a 256 px) y más empinada (73° frente a 61°) que la bajada. Que el ojo lo lea como "inhalar rápido, exhalar despacio" a 60 pt es lo que se comprueba en la hoja de prueba; a 29 pt no se promete: se lee "una línea con una elevación". El motor, además, no respira 4:6 literal: `BreathParameters` fija inhale 0,40 · exhale 0,45 · reposo 0,15 (a 6 por minuto, 4,0 s de subida, 4,5 s de bajada y 1,5 s plana en bajamar); el 4:6 de 03 es la lectura visual subida-corta / bajada-larga (4 s arriba, 6 s hasta la siguiente subida), no la cifra del DSP. Si se quisiera literal al motor, la cresta iría en x 384 + 448 × 0,40 / 0,85 ≈ 595.

**SVG completo del icono (apariencia Default = Dark; es la fuente de las capas de Icon Composer):**

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <!-- SleepNoise · icono "La regla y la marea" · Default = Dark · tokens de 03 §3.1 -->
  <!-- capa 1 · fondo (negro). En Tinted y Clear la capa no se exporta. -->
  <rect id="fondo" x="0" y="0" width="1024" height="1024" fill="#000000"/>
  <!-- capa 2 · marea (índice). En Clear claro: #8A6508 (ocre). Sube 192 px y baja 256 px (en retícula). -->
  <path id="marea"
        d="M 384 608 C 499 608 461 352 576 352 C 691 352 717 608 832 608"
        fill="none" stroke="#F0C020" stroke-width="112" stroke-linecap="butt" stroke-linejoin="round"/>
  <!-- capa 3 · regla (texto), ENCIMA de la marea. En Clear claro: #1E1C19 (tinta). Trazo 112, extremos rectos. -->
  <path id="regla" d="M 192 608 H 832" fill="none" stroke="#E8E4DC" stroke-width="112" stroke-linecap="butt"/>
</svg>
```

Para **Tinted** se exporta una sola capa (`marea` y `regla` combinadas en un `<path>` con `stroke="#E8E4DC"`, la regla después para que siga encima) y el sistema la tiñe; la marea deja de distinguirse por color y se sigue leyendo por forma. Para **Clear** se exportan `marea` y `regla` sin fondo; en Clear claro con `#8A6508` y `#1E1C19`; el vidrio del sistema hace el resto. No existe un Default en papel: la app no tiene modo claro en 1.0 (C32) y el icono en la pantalla de inicio clara es el negro. En todas las apariencias la geometría es idéntica: lo que cambia es el color, nunca la forma (P7).

**Capas en Icon Composer**, de abajo arriba: `fondo` (no se exporta en Tinted ni Clear; en Clear el sistema aporta el vidrio); `marea` (opaca, sin especular, sin desenfoque; en Tinted se declara como parte de la capa de primer plano, no como "acento", para que la forma sobreviva donde el sistema no conserve el matiz **[a medir en Xcode 26 con todas las apariencias]**); `regla` (igual, y encima de la marea: el sistema añade su propio relieve de vidrio en Clear y no se le suma nada). Sin "Specular", sin "Blur", sin "Translucency" propios: lo que Apple pone, se deja; lo que no, no se imita. Prueba a 29 pt con este orden antes de tocar nada más (hoja de prueba, abajo).

**Comportamiento por tamaño** (trazo 112/1024 del lado):

| Tamaño | Dónde | Trazo | Altura de la ola (256 px) | Qué se lee |
|---|---|---|---|---|
| 1024 px | App Store, marketing | 112 px | 256 px | Todo, incluida la asimetría de la curva |
| 83,5 pt | iPad (si llega) | 9,1 pt | 20,9 pt | Todo |
| 60 pt | Pantalla de inicio | 6,6 pt | 15 pt | La línea y la ola con su asimetría; el color índice como una cinta, no como un punto |
| 40 pt | Spotlight | 4,4 pt | 10 pt | Línea y ola |
| 29 pt | Ajustes | 3,2 pt | 7,3 pt | "Una línea con una ola": no se confunde con un guion (que iría centrado) ni con una onda (que no tendría la regla) |
| 20 pt | Carpetas de la pantalla de inicio, Siri y Atajos, Centro de control (1.0), Watch en 1.2 (C28); la app no envía notificaciones en 1.0 (03 §6) | 2,2 pt | 5 pt | Sigue leyéndose como línea con una elevación; el color ya es una tinta más que una forma |

Prueba de impresión: a 29 pt en Tinted y en escala de grises, la elevación sigue siendo visible porque es **forma** (una ola de 7 pt de alto), no color. A 29 pt bajo "Aumentar contraste" el sistema no toca el icono; `índice-ac` no aplica al icono (no es interfaz).

**Hoja de prueba junto a los diez iconos de la categoría** (nombres de `COMPETIDORES` §1; descripción de lo que la investigación recogió sin capturar: ningún informe pudo capturar iconos, brief Anexo B, así que cada descripción es **[a capturar en dispositivo antes de cerrar]**): Calm (fondo azul nocturno con wordmark), Headspace (punto naranja), BetterSleep (luna, según `grafito.md`), myNoise (portada tipo app de música), Dark Noise ("D" con ondas; iconos animados dentro de la app), White Noise de TMSoft (estética 2010, altavoz), Rain Rain (nube con gotas), Endel (círculo sobre negro, líneas finas), Veil (velo/gradiente), Portal (puerta/paisaje). Formato de la hoja: fila de once iconos a 60 pt con el nuestro en la posición 6, repetida a 29 pt y a 60 pt en Tinted; fondo `negro` y fondo claro del sistema (la pantalla de inicio clara existe aunque la app no tenga modo claro); una tercera fila en escala de grises. Criterio de paso (brief §8, lente 5): **es el único icono con una línea horizontal sobre negro y el único cuyo color es una línea**; ninguno de los diez tiene una regla con una elevación. Si en la prueba de cinco segundos con diez personas alguien lo describe como "electrocardiograma" o "gráfica", se repite la prueba con la subida a 4:6 exacto (§9.1) antes de tocar el grosor. La hoja se hace en la semana 3 (C10): no espera al nombre.

**Lo que el icono no lleva** (brief §7.1, 03 §6 y C10): luna, estrellas, nubes, "zzz", auriculares, ondas de sonido, ojo cerrado, texto, letra, nombre, degradado, sombra, borde, segundo color. Tampoco iconos alternativos en 1.0 (son la firma de Dark Noise; 03 §6).

### 2.2 Lienzo común de las seis capturas

Las capturas son **la pantalla a tamaño real sobre un fondo negro**, con el titular arriba. Sin *mockup* inclinado, sin bisel pintado, sin mano, sin degradado, sin ilustración, sin sello. Solo fondo negro (C57): no existe un segundo juego en papel (C32).

- **Lienzo:** 440 × 956 pt (clase 6,9", obligatoria en App Store Connect), exportado a 3× = 1320 × 2868 px. El juego de 6,9" es el único que se sube; App Store Connect lo reescala para el resto de tamaños **[a verificar en App Store Connect el conjunto de tamaños obligatorios en la fecha de envío]**. Fondo `negro`.
- **Titular:** paso 2 (SF Pro Display Medium 28/34, tracking 0) en `texto`, alineado a la izquierda a x = 32, primera línea base en y = 100; **una o dos líneas** (y 72-140): a 28 pt caben unos 26 caracteres por línea en 376 pt **[a medir los seis titulares en pt antes de la puerta de dispositivo]**, así que los titulares de 27 a 41 caracteres (C3, C4, C5) van a dos líneas y los de C1, C2 y C6 a una. Máximo 41 caracteres (≈ dos líneas de 26). Los seis titulares son los de C57 (= 10 §5e.15).
- **Subtítulo:** paso 6 (SF Pro Regular 17/22) en `texto2`, x = 32, línea base y = 164, siempre en y 152-174 (no sube aunque el titular ocupe una línea); una línea, **≤ 42 caracteres** (a 17 pt caben ≈ 44 en 376 pt **[a medir]**). Lo llevan solo C1 y C3, donde dice algo que la pantalla no dice (la prueba sin tarjeta; que la fila se arrastra). C2 no lo lleva (la página en reposo es la frase); C4 y C5 tampoco (§2.6: la pantalla ya lo dice; §2.7: la captura que vende "nada" no es la que más texto lleva); C6 tampoco. **Séptima captura (19-11-2026):** Mezclas de día con las bandas pintadas, titular "Lo que suena, se pinta." y, desde la segunda decisión del 19-11-2026 (la ventana pintada de la página entra en 1.0), el subtítulo de reserva de la exploración 12 §5 acortado, "Se genera aquí, como el sonido. Sin archivos." (`docs/store/ficha-*.md`, captura 7); los topes de 41 y 42 son estimados y manda `shot-composer --list`.
- **La pantalla:** el render de 393 × 852 de la build de referencia de E1 a escala **0,855** → 336 × 728 pt, en x 52-388, y 196-924. La escala se deriva de la cota, no al revés: ancho 336 en la retícula de 4 y centrado (x 52), de ahí 0,855; el alto 852 × 0,855 = 728,4 se redondea al pt. Margen inferior 32, el mismo que el lateral del titular: ninguna cota sin razón. **Radio 0 y sin contorno** en las seis (03 §3.5: radios 0 en todo lo propio; el render del simulador es rectangular, y una hairline de 0,5 pt a 3× son 1,5 px que desaparecen en la miniatura de la ficha). La página a escala sobre negro **es** la captura: donde la pantalla negra termina y empieza el lienzo negro no hay nada que ver, y es verdad. C5 ya no necesita contorno: es una sola pantalla (C57). El estado inyectado `-ui-testing-state` **oculta la barra de estado y el indicador de inicio** (`.statusBarHidden()`, `.persistentSystemOverlays(.hidden)`; ninguno cambia el área segura ni la geometría de la página): la hora, la batería y la señal serían los únicos iconos de la captura y no son de la app.
- **Escala y tipografía dentro de la pantalla:** la de E2-E6 a Large, reducida al 85,5 %: el nombre de la mezcla (28) se ve a 23,9 pt; la fila (17) a 14,5; el dato (13) a 11,1. A 1320 px de ancho real, nada baja de 33 px **[a medir en un iPhone con la ficha abierta]**. La regla "nada < 13 pt" de 03 §3.4 es de la interfaz, no de su fotografía: dentro del render, los 13 pt de la build quedan en 11,1 pt del lienzo (33 px a 3×), y eso no es un texto de 11 pt sino una pantalla de 393 pt vista a 336.
- **Retícula del lienzo:** posiciones (x e y de origen) y anchos en múltiplos de 4 pt; la altura de un render es su proporción, redondeada al pt.
- **Idiomas:** es-ES, es-419 y en-US son tres juegos (la pantalla de dentro es la build en el idioma de la ficha; los titulares son los mismos en es-ES y es-419). Ningún titular cambia por tienda: no hay cifra (C02), así que en-US sirve a toda tienda inglesa.

```
 x=0            32                                    408        440
 y=0  ┌───────────────────────────────────────────────────────────┐
      │                       negro                               │
  72  │  Titular 28/34 Display Medium · texto ·················  │ ← una o dos líneas
 140  │                                                           │
 152  │  Subtítulo 17/22 Regular · texto2 (solo C1 y C3) ·······  │ ← siempre en y 152-174
 174  │                                                           │
 196  │       ┌ · · · · · · · · · · · · · · · · · · · · ┐         │ ← sin contorno (la línea
      │       ·                                         ·         │    punteada es de este dibujo,
      │       ·     pantalla 393 × 852 · escala 0,855   ·         │    no del lienzo)
      │       ·     = 336 × 728 · x 52-388              ·         │
      │       ·     sin barra de estado ni indicador    ·         │
      │       ·                                         ·         │
 924  │       └ · · · · · · · · · · · · · · · · · · · · ┘         │ ← margen inferior 32
 956  └───────────────────────────────────────────────────────────┘
```

### 2.3 Captura 1 · "Un solo pago." · la página sonando

Estado de la app: **página principal, sonando, en prueba (noche 2), sin Marea, con temporizador**. Mezcla de la casa **"Rosa y lluvia"** (rosa 20 · lluvia 55, la receta de 10 §5e.9) cargada tal cual: por eso el nombre es el suyo y no "Esta noche" (05 §2.1: la mezcla viva sin guardar o modificada se llama "Esta noche", §3 de la reconciliación; una guardada cargada sin tocar lleva su nombre). Estado "Sonando · se funde a las 00:42". La captura 1 enseña la página sonando y no en reposo (03 §5, fila 28): en la tienda, con el sonido apagado, el horizonte en `índice` es la única prueba de que algo se fabrica. Geometría de la página: 05 §2.1 (manda sobre 08 en geometría); redacción de la cabecera de prueba: 08 = 10 §5e.3 (`pro.prueba.estado`).

```
 pantalla 393 × 852 (coordenadas de la página, 05 §2.1)
 y
  59 ├ (barra de estado oculta por el estado inyectado, §2.2; el área segura no cambia)
  64 ├ prueba · quedan 6 noches            ← paso 9 versalitas texto2 (y 64-82; botón de día)
 100 ├ Rosa y lluvia                        ← paso 2 Display Medium 28 texto (y 100-134)
 144 ├ Sonando · se funde a las 00:42       ← paso 7 texto2
     │
 272 ├ ─────────────────────────────────── ← HORIZONTE a un tercio: y 284, banda 272-296,
 296 │                                         índice 1,5-3 pt, opacidad 0,6-1,0 por RMS
     │
 324 ├ Lluvia            sobre el tejado              55   ← fila de capa 80 (312-392): cama primero (05 §2.0)
     │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──────────────  línea de nivel: 2 pt texto / 1 pt texto3
 404 ├ Rosa              suave y equilibrado          20   ← fila 392-472
     │ ━━━━━━━━━━━━━━──────────────────────────────────────
 552 ├ ─────────────────────────────────── hairline
 569 ├ Todas las capas                                    ← fila 56; sin chevrón, sin cifra (03 §3.6; 10 `capas.todas`)
 640 ├ ─────────────────────────────────── hairline
 652 ├ Marea                                      [○ ]  ← fila 72 + Toggle del sistema .tint(texto) (03 §4.12)
 680 │ Apagada                                           ← paso 7 texto2 (10 `marea.estado.apagada.fila`)
 712 ├ ─────────────────────────────────── hairline
 729 ├ Temporizador           Hasta dormirme · 45 min     ← fila 56: el ajuste, no la cuenta (10 §2.1)
 769 ├   Mezclas           (●)  pausa          Noche      ← barra inferior: palabras + Disco 44 en grafito
 818 ┤
 852 └ (indicador de inicio oculto por el estado inyectado, §2.2)
```

| Elemento | Estilo (escala de nueve) | Color | Medidas | Comportamiento en la captura |
|---|---|---|---|---|
| Titular | 2 · Display Medium 28/34 | `texto` | x 32, y 72-106 | "Un solo pago." ["One payment."] en las tres localizaciones: sin cifra en ninguna tienda (C02, C57) |
| Subtítulo | 6 · Regular 17/22 | `texto2` | x 32, y 152-174 | "Siete noches con todo, sin tarjeta." ["Seven nights with everything, no card."] (la frase de `tienda.promo`, 10 §5e.15) |
| Cabecera de prueba | 9 · Medium 13 versalitas +2 % | `texto2` | y 64-82 [05] | `pro.prueba.estado` "prueba · quedan 6 noches": la segunda noche. Aparece solo desde que la prueba empezó en la hoja Pro (C07); nunca con Play |
| Nombre de la mezcla | 2 · Display Medium 28/34 | `texto` | y 100-134 [05] | `mezcla.casa.rosa_lluvia` "Rosa y lluvia": la mezcla de la casa cargada tal cual |
| Línea de estado | 7 · Regular 15/20 | `texto2` | y 144 [05] | `pagina.estado.sonando.funde` "Sonando · se funde a las 00:42" |
| Horizonte | `SoundLine` (04 §2.1) | `índice` | banda 24 pt centrada en y 284; margen a margen (x 20-373) | Grosor 1,5-3 pt y opacidad 0,6-1,0 por RMS maestro real **[spike I0-1]**: el motor de `main` no tiene medidor RMS ni canal render → main; sin el spike cerrado, el fotograma del horizonte sería inventado y C1 no se puede capturar de la build. El fotograma se elige con el RMS de lluvia + rosa en su media (grosor ≈ 2 pt): ni plano ni "excitado" |
| Filas de capa | `LevelRule` (04 §2.2): 5 nombre · 7 subtítulo · 9 valor | `texto` · `texto2` · `texto2` | paso 80 [05]: 312-392 y 392-472; camas primero | Lluvia 55 (`capas.rain.detalle` "sobre el tejado"), Rosa 20 (`capas.pink.detalle` "suave y equilibrado"); línea de nivel a 12 pt del borde inferior: 2 pt `texto` llena, 1 pt `texto3` resto |
| "Todas las capas" | 5 · Semibold 17 | `texto` | fila 56, y 552-608 [05] | `capas.todas`, sin cifra ni chevrón (03 §3.6: "cero iconos en la principal: las palabras son los iconos"); botón por rasgo (§5.b) y por Button Shapes; la pulsación la revela el `grafito` de 200 ms de 03 §4.7 |
| Marea | 5 · Semibold 17 + 7 | `texto` + `texto2`; toggle `.tint(texto)`, aquí **off** | fila 72, y 640-712 [05] | `marea.titulo` "Marea" (nunca "Marea respiratoria": C15) + `marea.estado.apagada.fila` "Apagada". El toggle nunca lleva índice (03 §4.12, §3.1 regla 2): un índice por pantalla, y el de esta captura es el horizonte |
| Temporizador | 5 · Semibold 17 · 7 estado | `texto` · `texto2` | fila 56, y 712-768 [05] | `temporizador.titulo` + `temporizador.estado.dormirme` "Hasta dormirme · 45 min": la fila muestra el ajuste; la cuenta vive en la línea de estado (10 §2.1). Hora de la build 23:57: la sesión acaba de empezar |
| Barra | 17 Medium (03 §4.11, variante del paso 6 según 04 §2.0.2) · Disco 44 | `texto`; Disco `grafito` + glifo `pause.fill` `texto` | y 769-818 [E1] | Material `.bar` + hairline (iOS 17/18) o vidrio del sistema (26, C66): se captura en la build de iOS 26 y se declara |

Conteos para el jurado (brief §8): colores distintos del gris en la captura: **uno** (el horizonte; el toggle va en `texto`). Rectángulos rellenos: **uno propio** (el Disco, el único relieve permitido) **y uno del sistema** (el toggle en off). Familias: una. Estilos de texto en la pantalla: 2, 5, 7, 9 + 17 Medium de la barra (cinco; 03 §3.4 y C67: la principal ≤ 4 en reposo, y sonando la barra añade el quinto: conteo honesto de 05); con el titular (2, compartido) y el subtítulo (6) del lienzo, seis distintos en la imagen (§10.2 P5).

### 2.4 Captura 2 · "Un toque y suena." · el primer uso, en reposo

Estado de la app: **la página del primer uso, en reposo** (03 §5 #16, C33: la app abre en reposo y suena con Play; sin onboarding, sin permiso, sin hoja). Es la noche 1: la prueba no ha empezado (C07), así que la cabecera está vacía y su hueco queda vacío (nada se mueve). Mezcla viva **"Esta noche"** (§3 de la reconciliación: el nombre de la mezcla viva sin guardar) con la receta del primer uso de 05 §4.4: Lluvia 30 · Rosa 50. La fila Temporizador dice lo que 07 fija por defecto desde la primera noche: **"Hasta dormirme · 45 min"** (07 §2.1: 45 min por defecto; nada Pro en el temporizador, C03). No hace falta el spike I0-1: en reposo el horizonte es la hairline.

```
 y
  64 ├ (cabecera vacía: la prueba no ha empezado, C07)
 100 ├ Esta noche                           ← paso 2 texto (10 `mezcla.nombre.vacio` / 05 `page.name.tonight`)
 144 ├ En silencio                          ← paso 7 texto2 (10 `pagina.estado.silencio`)
 284 ├ ─────────────────────────────────── ← hairline 0,5 trazo, quieta: el silencio dibujado
 324 ├ Lluvia            sobre el tejado              30   ← fila 312-392 (cama primero)
     │ ━━━━━━━━━━━━━━━━━━━━━━━━──────────────────────────────  2 pt texto al 30 % / 1 pt texto3
 404 ├ Rosa              suave y equilibrado          50   ← fila 392-472
     │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──────────────
 552 ├ ─────────────────────────────────── hairline
 569 ├ Todas las capas
 640 ├ ─────────────────────────────────── hairline
 652 ├ Marea                                      [○ ]
 680 │ Apagada
 712 ├ ─────────────────────────────────── hairline
 729 ├ Temporizador           Hasta dormirme · 45 min     ← 07: por defecto desde la primera noche
 769 ├   Mezclas           (▶)  play           Noche      ← Disco con play.fill
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Titular | 2 | `texto` | x 32, y 72-106 | "Un toque y suena." ["One tap and it plays."] (C33, C57). **Sin subtítulo**: la página en reposo es la frase |
| Cabecera | — | — | y 64-82, vacía | Noche 1: ninguna versalita, ningún párrafo en la captura (la nota de una vez de 05 §2.11 no se enseña: la captura es la página limpia, y en la build el estado inyectado la cierra) |
| Nombre | 2 | `texto` | y 100-134 | "Esta noche" ["Tonight"] |
| Línea de estado | 7 | `texto2` | y 144 | "En silencio" ["Silent"] |
| Horizonte | `SoundLine` reposo | `trazo` hairline 0,5 pt | y 284 | Quieto. En la tienda es verdad: nada suena todavía |
| Filas | `LevelRule` | como C1 | 312-392, 392-472 | Lluvia 30 · Rosa 50 (receta del primer uso, 05 §4.4; `defaultLevels()` de `main` es Rosa 65 sola: cambia la constante, 05 §9.17) |
| Resto | como C1 | | | Marea off, "Hasta dormirme · 45 min", Disco en `play.fill` |

Conteo de color: **cero** (en reposo y sin dedo la principal no tiene color, 03 §3.1 regla 1). Es la única captura de la página sin índice, a propósito: la frase "un toque y suena" la sostiene el Disco, no el color. Estilos en la pantalla: 2, 5, 7, 9 + 17 Medium de la barra (cinco); en la imagen, seis con el titular.

### 2.5 Captura 3 · "Seis capas a la vez. Una línea cada una." · Capas bajo el dedo

Estado de la app: **hoja Capas (`.large`) con la fila Lluvia bajo el dedo** (04 §2.2, estado "Activo"): línea 3 pt `índice`, pista `grafito` de 44 pt visible, valor a 17 pt `texto` tabular en su sitio. **Seis capas sonando** (Blanco 20 · Rosa 65 · Marrón 20 · Lluvia 52 · Viento 30 · Océano 30): el tope de seis simultáneas es regla de modelo (C19), y la captura lo enseña lleno, sin huecos ni ranuras. Cuenta: **prueba, noche 2** (Océano es Pro y suena porque la prueba lo incluye); el nombre de la mezcla, modificada, es "Esta noche" (no se ve: la hoja lo tapa). Secciones "colores" / "camas" (10 §5e.4); once texturas (C19), ocho camas: la hoja desplaza. La hoja va **sobre `negro` con hairlines `trazo`** (03 §4.10 consolidado: Capas es la única hoja sobre `negro`, porque hace lo mismo que la página). Sobre el número: la cifra del titular es el tope del motor (seis camas en `RenderState`), no el número de texturas; nunca se cuentan texturas en la ficha (C04).

```
 hoja .large sobre negro · indicador de arrastre del sistema · coordenadas de la hoja (05 §2.7; en 852 empieza en y ≈ 54)
 y
  24 ├ Capas                                    ← paso 3 Semibold 22, x 20
  64 ├ ─────────────────────────────────────── hairline trazo
  80 ├ colores                                  ← paso 9 versalitas texto2
 116 ├ Blanco           siseo parejo           20   ← fila 104-184
 196 ├ Rosa             suave y equilibrado    65   ← fila 184-264
 276 ├ Marrón           retumbo grave          20   ← fila 264-344
 376 ├ camas                                    ← 32 de aire + encabezado
 400 ├ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ← pista grafito 44 pt bajo el dedo (fila 400-480)
     │ Lluvia           sobre el tejado        52   ← valor 17 pt texto tabular, a la derecha, en su sitio
     │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──────   ← línea 3 pt ÍNDICE (el único color de la pantalla)
 492 ├ Viento           entre árboles          30   ← fila 480-560 (libre, C04)
 572 ├ Océano           oleaje lento           30   ← fila 560-640 (Pro; suena: prueba)
 652 ├ Ventilador       ventilador lejano       ·   ← fila 640-720, a 0: asoma bajo la barra; la hoja desplaza
 715 ├   Mezclas           (●)  pausa          Noche  ← barra de la hoja (715-764): nada bloquea el sonido
     (bajo el pliegue: Trueno · Hoguera · Arroyo · Cabina a 0 · fila "Timbre" · nota "Se mezclan en tu iPhone mientras suenan. Nada se repite." · "Lo que está a cero no suena ni gasta.")
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Titular | 2 | `texto` | y 72-140 (dos líneas) | "Seis capas a la vez. Una línea cada una." ["Six layers at once. One line each."] (C19, C57) |
| Subtítulo | 6 | `texto2` | y 152-174 | `tip.arrastre` "Arrastra sobre el nombre para cambiar el nivel." ["Drag across the name to change the level."] (47 / 41) **[a medir: supera por cinco el ≤ 42 estimado de §2.2; si no cabe en una línea a 17 pt, E7 fija una variante corta: §9 pendiente de E7]** |
| Cabecera "Capas" · encabezados | 3 · 9 versalitas | `texto` · `texto2` | y 24 · 80 · 376 [05 §2.7] | `capas.titulo` · `capas.seccion.colores` · `capas.seccion.camas` |
| Fila bajo el dedo | `LevelRule` activo: 5 · 7 · valor **17 Medium tabular** | `texto` · `texto2` · `texto`; línea `índice`; pista `grafito` | paso 80; pista 44 pt; línea 3 pt a 12 pt del borde inferior | Valor "52": un número que no es redondo, para que se lea como medida y no como preset. Arrastre horizontal (C52); pulsación larga → `Slider` del sistema (C21), no se enseña |
| Otras cinco filas sonando | 5 · 7 · 9 | `texto` · `texto2` · `texto2` | paso 80 | Subtítulos de 10 §5e.4: "siseo parejo", "suave y equilibrado", "retumbo grave", "entre árboles", "oleaje lento". Sin "pro" en ninguna: en prueba todo suena. **Cero candados.** Es la captura que responde al PR #3 (14 candados) sin decirlo |
| Fila a 0 (Ventilador) | 5 · 7 | `texto` · `texto2`; pista `texto3` | 640-720, cortada por la barra | Valor oculto; "ventilador lejano". El estado "pro · N" (nivel guardado conservado, C23) existe para el usuario gratuito tras la prueba y se verifica en el juego de control del pipeline, no en la tienda (§3.2) |
| Bajo el pliegue | — | — | — | Trueno ("lejano, sin rayos cerca"), Hoguera, Arroyo, Cabina a 0; fila "Timbre" (`LevelRule` del bus maestro, extremos "Grave" / "Lejos", C29, **[spike I0-7]**); `capas.nota` y `capas.cero` [E2] |

Si el usuario tocara la séptima fila, la hoja diría `capas.tope` "Seis a la vez" 3 s y no la añadiría (C19); la captura no lo enseña: el titular ya lo dice. Conteo de color: **uno** (la línea bajo el dedo; el horizonte, tapado por la hoja, se congela a hairline). Estilos en la hoja: 3, 5, 7, 9 + 17 Medium tabular (cinco; seis con la nota en paso 8 bajo el pliegue, que no sale); en la imagen, siete con titular y subtítulo.

### 2.6 Captura 4 · "El mar respira a seis por minuto." · Marea guiando

Estado de la app: **hoja Marea (`.large`, fondo `hoja`) en estado "guiando", tercera respiración, fase de subida** [E3]. La línea de agua como héroe y control arriba, en `texto` (04 §2.3: 2 pt `texto` en la hoja); el toggle va en `.tint(texto)` (03 §4.12: el Toggle nunca lleva índice). **Cero índice en la hoja**: todo se lee por forma y por palabra. Anatomía y claves de 10 §2.3 (E3 fija las cotas finales en 06). Marea = toggle + línea de agua, nunca un círculo (C59); "Descenso" (el ritual, C14/C24) existe como fila y está apagado en la captura: con Descenso el ritmo arrancaría a 12 (C34) y la versalita no diría "6 por minuto" en la tercera respiración.

```
 hoja .large sobre hoja · coordenadas de la hoja (10 §2.3)
 y
  20 ├ Marea                                     ← paso 3 Semibold 22; hairline trazo-hoja debajo (03 §4.10)
  56 ├ Inhala mientras la ola sube, exhala mientras se retira.
     │ No hace falta mirar la pantalla.          ← paso 6 texto2, 17/22 (marea.instruccion = breath.hint de main, conservada)
 128 ├ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  ← pleamar · hairline texto3
     │            ╭──────────╮
     │        ╭───╯          ╰───────╮           ← LÍNEA DE AGUA · 2 pt texto · banda 120 pt (128-248)
     │    ╭───╯                      ╰───────╮       sube 4,0 s / baja 4,5 s / bajamar 1,5 s
     │ ───╯                                  ╰───    inhala  ← paso 7 texto2, a la derecha, 3 primeras respiraciones
 248 ├ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  ← bajamar · hairline texto3
 264 ├ guiando · 6 por minuto                    ← paso 9 versalitas texto2
 288 ├ Se retira a las 23:27                     ← paso 7 texto2 (nunca versalitas: dato de noche)
 316 ├ ─────────────────────────────────────── hairline trazo-hoja
 316 ├ Marea                               [● ]  ← Toggle del sistema, on, .tint(texto)
 372 ├ Ritmo                        Tranquilo · 6    ← filas de 56, en la retícula de 4
 428 ├ Descenso                            [ ○]  ← toggle del ritual, off en la captura
     │ Empezar a 12 por minuto                   ← paso 7 texto2 (fila 72)
 500 ├ Se retira a los                     15 min
 556 ├ Más ajustes                             ›  ← chevron tipográfico de 10 (la háptica vive debajo)
 628 ├ Respirar a unas 6 veces por minuto se asocia en estudios
     │ a mayor variabilidad cardiaca.            ← paso 8 texto2 (marea.evidencia)
     │ Qué sabemos ›                             ← paso 8 texto2 (sabemos.enlace)
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Titular | 2 | `texto` | y 72-140 | "El mar respira a seis por minuto." ["The sea breathes six times a minute."]. **Sin subtítulo**: la hoja ya dice "Inhala mientras la ola sube, exhala mientras se retira." (`marea.instruccion`); decirlo dos veces a 17 pt en la misma imagen es residuo de tienda |
| Cabecera · instrucción | 3 · 6 | `texto` · `texto2` | y 20 · 56 | `marea.titulo` "Marea" (nunca "Marea respiratoria", C15) · `marea.instruccion` |
| Línea de agua | `TideLine` guiando (04 §2.3) | `texto` 2 pt; marcas `texto3` hairline | banda 120 (y 128-248 en la hoja), margen a margen | Fotograma en el 70 % de la subida (la ola a dos tercios de la pleamar): se ve que sube, no que ha llegado. El ciclo real es el del motor: `BreathParameters` inhale 0,40 · exhale 0,45 · reposo 0,15 → a 6 por minuto, 4,0 s de subida, 4,5 s de bajada y 1,5 s quieta en bajamar (03 §4.3 lo escribe como "sube 4 s y baja 6 s": 6 s hasta la siguiente subida). En la hoja es también control: arrastrarla cambia el ritmo |
| "inhala" | 7 · Regular 15 | `texto2` | a la derecha de la banda, y 232 | `marea.fase.inhala`; solo durante las tres primeras respiraciones: la captura se toma en la tercera |
| Estado | 9 versalitas · 7 | `texto2` | y 264 · 288 | `marea.estado.guiando.corto` "guiando · 6 por minuto" · `marea.retira.hora` "Se retira a las 23:27" (Marea iniciada a las 23:12:00 con "Se retira a los · 15 min"; la captura es ≈ 25 s después, §9.10) |
| Toggle Marea | sistema | `.tint(texto)` on | fila 56, y 316 | `marea.toggle` "Marea". Se lee on por la posición del pomo (P7); nunca índice (03 §4.12) |
| Ritmo · Descenso · Se retira a los · Más ajustes | 5 · valor 7 / 9 | `texto` · `texto2` | filas 56 (Descenso 72), y 372 · 428 · 500 · 556 [E3] | "Tranquilo · 6" (`marea.ritmo.tranquilo.corto`); "Descenso" con subtítulo "Empezar a 12 por minuto" (`marea.ritmo`, C34), off; "15 min"; `marea.mas` con chevron tipográfico; la háptica "Mínima" (opt-in, C35) vive bajo "Más ajustes" |
| Evidencia · "Qué sabemos ›" | 8 · 8 | `texto2` | y 628 [E3] | `marea.evidencia` + `sabemos.enlace` (el chevron es tipográfico, 10 §5e.5); abre la pantalla empujada "Qué sabemos" [E5], sin términos clínicos (C54) |

Estado de cuenta: **prueba o Pro** (la Marea es Pro, C24; en la tienda se enseña funcionando porque las siete noches la incluyen). No se escribe "pro" en esta captura: no hay nada bloqueado en ella. Mezcla viva con Rosa 65 · Lluvia 40 · Océano 30 (nombre "Esta noche", tapado por la hoja): la Marea de 1.0 modula `bedDepth` sobre todas las camas y el océano es la que se oye; sin océano en la mezcla `MixerModel.setBreathingEnabled` lo subiría (hoy a 50 en `main`; 10 fija 40 en `marea.oceano.subido`) y enseñaría la nota 4 s (§3.2). Conteo de color: **cero**. Estilos: 3, 5, 6, 7, 8, 9 (seis: el tope de 03 §3.4).

### 2.7 Captura 5 · "A las tres de la mañana, nada." · Noche sola

**Noche** (pantalla de la app, 03 §5 fila 10; `FullScreenControl`, 04 §2.5), sola (C57: StandBy ya no está en la tienda; en escenario B ni siquiera existe en 1.0, C25). **Sin subtítulo** (Grafito: "sin titular adicional"; la captura que vende "nada" no puede ser la que más líneas de texto lleve) y sin pie: una sola pantalla no necesita explicarse. La geometría la manda 07 (E4); la captura solo la toma, a la escala común de §2.2 (336 × 728, x 52, y 196-924, sin contorno). Instante: 03:07, se funde a las 03:42. Anatomía fija de C47: horizonte estático, reloj 72, palabra de estado, "+15 min" (solo porque hay temporizador; Noche nunca crea uno).

```
 pantalla 393 × 852 (coordenadas de la pantalla, 07 §2.2)
 y
   0 ├ (sin barra de estado: la build la oculta en Noche [E4])
 284 ├ ─────────────────────────────────── ← horizonte estático 2 pt texto-noche, continuo = suena
     │
 332 ├               3:07                   ← reloj paso 1 · 72/80 Display Regular texto-noche (ocultable)
     │
 436 ├        Se funde a las 03:42          ← paso 3 · 22/28 Medium texto-noche (noche.estado.funde)
     │
     │
 754 ├             +15 min                  ← paso 4 · 20/25 Medium texto-noche · botón 393 × 64 (754-818), nunca se mueve
 852 └
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Titular | 2 | `texto` | y 72-140 | "A las tres de la mañana, nada." ["At three in the morning, nothing."] |
| Horizonte | `SoundLine` Noche | 2 pt `texto-noche` | y 284 | Continuo = suena; ausente = pausa (P7). La Marea no se dibuja en Noche (04 §2.3) |
| Reloj | 1 · 72/80 Display Regular | `texto-noche` | centrado, y ≈ 332-412 [E4] | "3:07" (la hora del titular); formato del sistema (es-ES 24 h "03:07"; la captura se toma con la build del idioma) |
| Estado | 3 · 22/28 Medium | `texto-noche` | centrado, y 436-464 [07] | `noche.estado.funde` "Se funde a las 03:42" (quedan 35) |
| "+15 min" | 4 · 20/25 Medium | `texto-noche` | 393 × 64, y 754-818 [07] | `comun.mas15`; botón de texto a todo el ancho, siempre en el mismo sitio (03 §4.5); libre para todos (C03); solo si hay temporizador (C47) |
| Lo que no hay | — | — | — | Ningún nombre de mezcla, ningún logotipo, ningún índice (de noche solo bajo el dedo), ninguna frase de primera vez (no es la primera entrada), ningún "Seguir por el altavoz" (no hay pausa por auriculares) |

Conteo de color: **cero**. Una sola tinta (`texto-noche`, 8,03:1 sobre `negro`): el contraste se mide dentro de la app, ≥ 4,5:1 (C62); el spike I0-6 (rojo de StandBy) ya no condiciona ninguna captura. Estilos: 1, 3, 4 (tres); en la imagen, cuatro con el titular. Es la captura diseñada primero (P1) y la única en la que el estado se lee solo por forma y por una palabra.

### 2.8 Captura 6 · "Lo que no hay." · la página "Lo que no hay"

La página **"Lo que no hay"** de la app (03 §5 #32, C38: pie + página, empujada desde Ajustes, `negro`), capturada de la build [E5 + E7]. Es la captura que convierte las ausencias en producto (brief §2.3) y la que el jurado de Grafito señaló como voz "de un objeto de 29,99 € una vez" (03 §1.1); y como ahora es una pantalla real, la guía 2.3.3 de App Review (capturas de la app en uso) queda cumplida sin plan B (§9.15 cerrada). La anatomía de la página la fija E5; esta captura la toma con la lista `lo_que_no_hay.lista` como primer bloque y el pie de privacidad y peso al final. Debajo se dibuja lo que la captura espera encontrar; si E5 ordena la página de otro modo, se repite la captura, no la especificación.

```
 pantalla 393 × 852 (coordenadas de la pantalla; [E5] fija las cotas)
 y
  64 ├ Lo que no hay                               ← paso 3 (título de pantalla empujada; lo_que_no_hay.titulo)
 120 ├ ─────────────────────────────────────────  hairline trazo, x 20-373
     │ Sin suscripción                             ← paso 2 Display Medium 28/34 texto
 192 ├ ─────────────────────────────────────────
     │ Sin cuenta
 264 ├ ─────────────────────────────────────────
     │ Sin rastreo
 336 ├ ─────────────────────────────────────────
     │ Sin anuncios
 408 ├ ─────────────────────────────────────────
     │ Sin puntuación
 480 ├ ─────────────────────────────────────────
     │ Sin racha
 552 ├ ─────────────────────────────────────────
     │ Sin tutorial
 624 ├ ─────────────────────────────────────────
     │ No te pediremos que la valores.            ← paso 6 texto2 (lo_que_no_hay.resena, C55)
     │ Un registro de la noche, en tu teléfono. Solo sale si tú lo envías.  ← paso 6 texto2 (lo_que_no_hay.diagnostico, C56)
 760 ├ Sin suscripción. Sin cuenta. Sin rastreo.   ← paso 8 texto2 (lo_que_no_hay.pie, C09)
 784 ├ No se recopilan datos · {MB} MB             ← paso 8 texto2 (tienda.privacidad + peso)
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Titular del lienzo | 2 | `texto` | y 72-106 | "Lo que no hay." ["What's not here."] (§3 de la reconciliación; antes "What isn't here.") |
| Siete líneas | 2 · Display Medium 28/34 | `texto` | filas de 72 pt; texto a x 20; hairline `trazo` 0,5 pt entre filas [E5] | `lo_que_no_hay.lista`: "Sin suscripción · Sin cuenta · Sin rastreo · Sin anuncios · Sin puntuación · Sin racha · Sin tutorial" ["No subscription · No account · No tracking · No ads · No score · No streak · No tutorial"], en este orden (10 §5e.12). Siete: sin "Sin servidor" (deja de ser cierto en 1.1, C09), sin "Sin red" (StoreKit y Restaurar usan red), sin "sin candados" (sería nombrar lo que otros hacen; brief §7.2) |
| Entradas en prosa | 6 | `texto2` | bajo la lista [E5] | `lo_que_no_hay.resena` y `lo_que_no_hay.diagnostico`: hechos de hoy, no promesas (C55, C56) |
| Pie | 8 | `texto2` | y 760-784 [E5] | `lo_que_no_hay.pie` "Sin suscripción. Sin cuenta. Sin rastreo." (C09; en 1.1 añade "Tus mezclas, en tu iCloud si quieres.") y la etiqueta de privacidad con el peso: es-ES y es-419 "No se recopilan datos · {MB} MB" (31) · en-US "Data Not Collected · {MB} MB" (28). **Sin cifra de precio** (C02). El literal de la etiqueta en español es el que muestre la App Store en el momento de subir **[a verificar: "No se recopilan datos"]**; el peso es el de la build firmada **[a medir; `main` ronda 2 MB]**, el mismo que `ajustes.version` enseña |

**"Sin rastreo", no "Sin red" ni "Sin servidor".** "Sin red" no es verdad en el único momento en que la app pide dinero (StoreKit y "Restaurar compra"), y la propia app tiene un estado de red con texto (`pro.sin_tienda`, 03 §4.6); "Sin servidor" deja de ser verdad con iCloud en 1.1 (C09). "Sin rastreo" ["No tracking"] es verdad en cualquier momento y es la palabra del pie de C09. Conteo de color: cero. Estilos: 3, 2, 6, 8 (cuatro); cinco en la imagen con el titular.

### 2.9 Preview muda de 30 s · una por idioma, la página real sonando

Un solo plano: la pantalla de la app a tamaño real sobre negro, sin titular, sin dedo, sin texto animado, sin música, sin voz; pista de audio en silencio (la preview se reproduce muda en la ficha y se declara muda; §9.12 propone la variante con el sonido real). Una preview por idioma (es-ES, es-419, en-US: la build en ese idioma, el mismo guion), C57. Es **la página real sonando** (C53): la prueba de "nunca se repite" no es una animación sino la página "Cómo se genera", el peso en MB y el test de autocorrelación en CI; la preview solo enseña la app. Todo a **tiempo real**: nada se acelera, porque acelerar la Marea sería mentir sobre su ritmo. Formato: H.264, 30 fps, portrait, resolución de preview de la clase 6,9" **[a verificar en App Store Connect; la clase 6,5" usa 886 × 1920]**; 30,0 s exactos; fotograma de póster en el segundo 6.

Estado inyectado `-ui-testing-state preview` (§3.2): prueba, noche 2 (cabecera `pro.prueba.estado` "prueba · quedan 6 noches" visible, como C1); mezcla viva **"Esta noche"** con Rosa 65 · Lluvia 40 · Océano 30 desde t = 0 (las filas de la página, camas primero: Lluvia, Océano, Rosa), porque la Marea de 1.0 modula las camas y el océano es la que se oye; sin océano en la mezcla `MixerModel.setBreathingEnabled` lo subiría, añadiría una fila y enseñaría `marea.oceano.subido` durante 4 s: nada de eso está en el guion; temporizador "Hasta dormirme · 45 min" (el valor por defecto, 07 §2.1; nada Pro en el temporizador, C03); hora 23:12.

| t (s) | Escena | Estado de la app | Qué se ve | Señal que lo mueve |
|---|---|---|---|---|
| 0,0-2,0 | Reposo | Página, "Esta noche", "En silencio", horizonte en hairline `trazo` | El silencio dibujado. Nada se mueve | ninguna (motor parado) |
| 2,0-2,8 | Arranque | Toque en el Disco (no se ve el dedo: se ve el glifo pasar a `pause.fill` con `.replace`) | El horizonte nace de la hairline en `índice` durante 800 ms `.easeOut`; el estado pasa a "Sonando · se funde a las 23:57" | fundido de entrada del motor: 800 ms según 03 §3.7; hoy `SleepAudioEngine.defaultFadeIn` es 1,5 s (MP1) |
| 2,8-8,0 | Sonando | Página sonando | El horizonte respira con el RMS real (τ 500 ms, 20 Hz): casi quieto con rosa, un poco más con la lluvia y el océano. **Póster en t = 6,0** | RMS maestro **[spike I0-1]** |
| 8,0-10,0 | Pulsación larga | Horizonte bajo pulsación larga (04 §2.1) | Se descompone en tres líneas (Rosa 3 pt, Lluvia 2 pt, Océano 1 pt [E2 fija los grosores]) en `texto` en 400 ms; se mantienen 1,6 s. Las sublíneas son decorativas (C63) | RMS por capa **[spike I0-1]** |
| 10,0-10,4 | Suelta | — | Se recompone en 400 ms y vuelve al `índice` | RMS maestro **[spike I0-1]** |
| 10,4-13,0 | Sonando | — | Respira | RMS maestro **[spike I0-1]** |
| 13,0-17,2 | Arrastre | Fila Lluvia bajo el dedo | Arrastre horizontal (C52): la línea de la fila pasa a 3 pt `índice`, la pista `grafito` aparece, el valor sube 40 → 65 en 17 pt tabular; el horizonte pasa a `texto` mientras dura el gesto y vuelve al índice al soltar (t = 17,2) | ganancia de la capa (gesto) y RMS |
| 17,2-18,0 | Marea on | Toggle Marea a on (desde la página; `.tint(texto)`, 03 §4.12) | El toggle pasa a on por la posición del pomo; la banda del horizonte ya mide 120 pt desde el principio porque la mezcla tiene Marea disponible (03 §3.5, 04 §2.0.3: no crece al activarla; nada cambia de posición) y aparecen las marcas de pleamar / bajamar; la línea **es** la línea de agua en `índice` (04 §2.1 y §2.3). **Un índice por pantalla: la línea de agua.** El toggle en `texto` no compite | `BreathCurve` + ganancia |
| 18,0-28,0 | Un ciclo | Marea guiando, primera respiración | La línea de agua **sube 4,0 s (18,0-22,0), baja 4,5 s (22,0-26,5) y queda quieta en bajamar 1,5 s (26,5-28,0)**: `BreathCurve` con inhale 0,40 · exhale 0,45 · reposo 0,15, a 6 por minuto (Descenso apagado: con el ritual arrancaría a 12, C34). "inhala" en paso 7 a la derecha durante la subida; versalita `marea.estado.guiando.corto` "guiando · 6 por minuto" en la segunda línea de estado | `BreathCurve` del motor con `guide.anchor` + `outputLatency` |
| 28,0-30,0 | Noche | Toque en "Noche" en la barra (t = 28,0, sobre la línea ya quieta en bajamar desde 26,5) | La página se funde a Noche en 2 s de opacidad: queda el horizonte estático en `texto-noche`, el reloj "23:12", "Se funde a las 23:57", "+15 min". **Último fotograma: Noche quieta** | transición de fase (03 §3.2) |

Lo que no pasa en la preview: ningún corte de montaje dentro del plano, ningún zoom, ninguna mano, ningún texto superpuesto, ninguna hoja Pro, ningún precio (C02: no hay cifra en ninguna superficie de la tienda), ningún StandBy, nada acelerado, ninguna escucha de 30 s (no existe en 1.0, C06). Lo que sí pasa y no es nuestro: la App Store reproduce la preview en bucle, y tras el último fotograma (Noche negra) vuelve a t = 0 (la página en reposo, `texto` a 16,56:1). Ese salto negro → página es un corte y un "encendido" que se acepta **[a verificar si la App Store hace bucle en la fecha de envío]**; si molesta en la ficha, se abre con 0,5 s de fundido desde negro (t 0,0-0,5) y se recortan 0,5 s a la escena 10,4-13,0.

### 2.10 Ficha: nombre, subtítulo, palabras clave, texto promocional, descripción, IAP, Notes for Review

Las cadenas exactas y sus longitudes están en §5.e (claves `tienda.*` e `iap.*`); las de nombre, subtítulo, promo, descripción, IAP y notas de versión son las de 10 §5e.15, letra a letra. Aquí, la anatomía y las reglas:

| Campo | Límite | Regla de esta entrega | Por qué |
|---|---|---|---|
| Nombre | 30 | "SleepNoise" (10); sin "Pro", sin "HD", sin emoji | C10: SleepNoise por defecto, cierre el 04-12-2026; "Marea" es una función, no una marca. La ficha se lee "SleepNoise: Sonidos para dormir" porque Apple compone nombre + subtítulo; los 31 caracteres del título de C10 no caben en el campo Nombre (10 §12.2), por eso van repartidos |
| Subtítulo | 30 | es-ES / es-419 "Sonidos para dormir" (19; plural, keyword del VoC, C10); en-US "Sleep sounds. Pay once." (23); sin palabras del nombre; sin "relajante", "sueño profundo", "IA" | Brief §7.2; informe §5.2; 10 §5e.15 |
| Palabras clave | 100 | **Apple indexa el nombre y el subtítulo: ninguna palabra de los dos aparece en keywords** (es: ni "sonidos" ni "dormir"; en-US: ni "sleep", "sounds", "pay", "once"); separadas por comas sin espacio; sin tildes (Apple normaliza) **[a verificar: el índice de la App Store trata "marrón" y "marron" como iguales]**; "insomnio" / "insomnia" y "acufenos" / "tinnitus" **solo aquí** (informe §5.2; C54: lista negra clínica sin excepción en app y ficha; el campo de keywords no se muestra a nadie); sin "siesta" / "nap" (la palabra no se graba hasta 1.1, C30); sin "bebe" (03 §7.6) | El único sitio donde la lista negra permite esas dos palabras |
| Texto promocional | 170 | 10 §5e.15: "Sonido que nunca se repite, fabricado en tu iPhone. Siete noches con todo, sin tarjeta. Un solo pago." (es-419: "generado"); nunca una cifra (es por idioma) ni una oferta con cuenta atrás (C02: no hay precio de lanzamiento) | Brief §7.1 |
| Descripción | — | 10 §5e.15, letra a letra (cuatro párrafos: qué es y "Todas las texturas, una línea cada una."; Marea, temporizador, Noche; "Siete noches con todo, sin tarjeta. Después, Pro es un solo pago; blanco, rosa, marrón, lluvia, viento, todo el temporizador y tres mezclas siguen gratis."; "Sin suscripción. Sin cuenta. Sin rastreo."); es-419 "genera" por "fabrica"; EN con "Breathing tide" solo aquí (C15). Después, **los seis titulares de las capturas, en orden, como párrafos de una línea** [E7 integra] | VoiceOver no lee las capturas: el texto es la única vía (§5.b). Sin cifra (C02) y sin cuenta de texturas (C04): "Todas las texturas, una línea cada una." |
| IAP | nombre 30 · descripción 45 | nombre = `product.displayName` "SleepNoise Pro" (14; C12); descripción "Todo, un solo pago" (18) / "Everything, one payment" (23), de 10 §5e.15. Lo que incluye lo dice la hoja Pro ("Todas las texturas", nombradas sin número, C04; Marea; mezclas sin límite; En familia) | `REVIEW-PR3`: el `.storekit` lleva 108 / 88 caracteres donde se admiten 45; `displayPrice` es 4,99 en el fichero de pruebas y la lista es 29,99 sin lanzamiento (C02; §9.11). Se escriben en App Store Connect y se copian al `.storekit` |
| Etiqueta de privacidad | — | "Data Not Collected" | Brief §2.3: la única del grupo; `PrivacyInfo.xcprivacy` sin tipos recogidos **[a verificar en la build]**; el Diagnóstico sale solo por el correo del usuario (C56) y no es recogida |
| Categoría | — | Primaria Salud y forma física; secundaria Estilo de vida | Informe §7.5 |
| Edad | — | 4+ | Nada que lo suba |
| Notas de versión 1.0 | 4000 | 10 §5e.15 (cuatro líneas; la primera: "SleepNoise, rediseñada: una página negra, una línea que respira con el sonido real, y una pantalla de Noche que es toda ella el botón.") | Informe §7.5: como Dark Noise 3.0 y Bear 2 |
| Notes for Review | — | en-US, no se localiza: (1) cómo entrar en la prueba y comprar (Tier 0 detrás de "Empezar la prueba · 7 noches", C07); (2) el test de autocorrelación a 10 min en CI como prueba de "nunca se repite" (C53); (3) los estudios de "Qué sabemos" con su etiqueta clínica tal cual la usa cada estudio (C54: la etiqueta solo aquí, nunca en la app ni en la ficha); (4) que el diagnóstico sale solo por el correo del usuario (C56) | Es el único texto de la tienda que el usuario no ve |

---

## 3. Estados completos

Las superficies de esta entrega son estáticas (icono, capturas, ficha) o un vídeo (preview); sus "estados" son las apariencias del icono, los estados de la app que cada captura enseña, y lo que la ficha muestra mientras carga o sin red. Los estados que no aplican se dicen con su razón, para que el jurado no los eche en falta.

### 3.1 Icono

| Estado | Qué pasa | Especificación |
|---|---|---|
| Default (= Dark) | Fondo `negro`, regla `texto`, marea `índice` | En iOS 26 / Icon Composer no existe una apariencia "Light" aparte: Default es lo que se ve en la pantalla de inicio clara. La app es solo oscura en 1.0 (C32): Default = Dark, el objeto es negro (Dial). Las apariencias son Default, Dark, Clear claro / oscuro y Tinted claro / oscuro |
| Dark | Igual que Default | §2.1 |
| Clear (claro / oscuro) | Marea y regla sobre vidrio del sistema, sin fondo | `texto` + `índice` en Clear oscuro; `tinta` + `ocre` en Clear claro (el único uso de los tokens de papel en 1.0: es una apariencia del sistema, no un modo claro de la app) |
| Tinted (claro / oscuro) | Una capa monocroma (marea + regla, la regla encima) con el tinte del usuario | La elevación sigue leyéndose: es forma |
| iOS 18 | Xcode 26 genera del `.icon` los PNG Any (= Default) / Dark / Tinted del asset catalog | Comprobar el Tinted generado **[a medir]**; es el único `#available` que esta pieza tiene que resolver |
| iOS 17 | Un solo PNG de 1024 (el Default) | Sin vidrio; la máscara la pone el sistema |
| Escala de grises (ajuste de accesibilidad "Filtros de color") | `índice` → gris medio (luminancia ≈ 0,56); la regla (`texto`, L ≈ 0,78) queda más clara, 1,35:1 entre ambas | La ola se lee por forma y, además, algo más oscura que la regla: **la forma hace el trabajo**, como en Tinted; el contraste de luminancia es un extra, no la base |
| Icono a 20 pt (carpetas, Atajos, Centro de control) | Trazo 2,2 pt | Legible; sin texto |
| Marketing 1024 (App Store) | Sin máscara aplicada en el fichero: la pone la tienda | El fichero no lleva esquinas redondeadas ni sombra |
| Bajo el rojo de StandBy | No aplica | El icono de la app no aparece en StandBy; la Live Activity y los widgets son de E6 |

### 3.2 Capturas: estado de la app que enseña cada una

| Captura | Estado de reproducción | Estado de cuenta | Mezcla | Marea | Temporizador | Hora de la build | Qué no enseña, a propósito |
|---|---|---|---|---|---|---|---|
| C1 | sonando | prueba, noche 2 ("prueba · quedan 6 noches") | de la casa "Rosa y lluvia" (rosa 20 · lluvia 55), cargada tal cual | off | Hasta dormirme · 45 min (se funde a las 00:42) | 23:57 | Ningún precio (ni en la pantalla ni en el titular, C02); ninguna hoja; barra de estado e indicador (§2.2) |
| C2 | reposo | noche 1: la prueba no ha empezado (C07); cabecera vacía | viva "Esta noche" (Lluvia 30 · Rosa 50, 05 §4.4) | off | Hasta dormirme · 45 min (07: por defecto) | 23:40 | El índice (en reposo no hay color); la nota de una vez; cualquier hoja |
| C3 | sonando, fila bajo el dedo | prueba, noche 2 | hoja Capas: Blanco 20 · Rosa 65 · Marrón 20 · Lluvia 52 (bajo el dedo) · Viento 30 · Océano 30 (seis: el tope) | off | Hasta dormirme · 45 min | 23:40 | Candados (no existen en ningún estado); "pro · N" (el usuario está en prueba; el estado del día 8 vive en el juego de control, §4.4); la hoja Pro (no se abre: el arrastre es sobre Lluvia); "Seis a la vez" (no se toca la séptima) |
| C4 | sonando, guiando (tercera respiración, al 70 % de la subida; Marea iniciada a las 23:12:00, captura ≈ 25 s después) | prueba o Pro | viva "Esta noche": Rosa 65 · Lluvia 40 · Océano 30 | on, 6 por minuto, Descenso off, se retira a los 15 (a las 23:27) | Hasta dormirme · 45 min | 23:12 | La palabra "pro" (nada bloqueado); cualquier índice |
| C5 | Noche: sonando (horizonte continuo) | cualquiera (de noche no se ve) | la de C4 | off | se funde a las 03:42 (quedan 35) | 03:07 | Nombre de mezcla; color; StandBy (ya no está en la tienda, C57) |
| C6 | — (página "Lo que no hay", empujada desde Ajustes, C38) | cualquiera | — | — | — | — | Todo lo que suena: es una página de texto |
| preview | reposo → sonando → pulsación larga → arrastre → Marea → Noche (§2.9) | prueba, noche 2 (cabecera visible) | viva "Esta noche": Rosa 65 · Lluvia 40 · Océano 30 desde t = 0 | on desde t 17,2 (Descenso off) | Hasta dormirme · 45 min (por defecto; se funde a las 23:57) | 23:12 (no cambia en 30 s) | Pro, precio, StandBy, el dedo, `marea.oceano.subido` (no sale porque el océano ya está en la mezcla) |

Estados de la app que **no** se enseñan en la tienda y por qué (brief §7.1, informe §7.5):
- **Pausa / fundiendo / en pausa por llamada o AirPods:** son estados de interrupción; una captura de pausa enseña un instrumento callado. Viven en la preview como "lo que no pasa" y en E2/E4.
- **Pro bloqueado sin castigo ("pro · 30", C23):** no se enseña en la tienda porque ninguna captura muestra al usuario gratuito del día 8 (C3 necesita seis capas sonando y solo hay cinco libres, C04); se verifica en el juego de control del pipeline (§4.4). No se enseña la hoja Pro: una captura del paywall es lo que hacen las apps que viven del paywall.
- **Prueba:** se enseña como una versalita en C1 ("prueba · quedan 6 noches"), nunca como tarjeta; empieza en la hoja Pro (C07), que no se enseña.
- **Error de audio, vacío (Mezclas sin guardar), cargando ("—" del precio), sin red ("La tienda no responde"):** no se enseñan; son estados de la app que E5 especifica. Una tienda no enseña errores. Se nombran aquí para que el jurado sepa que no faltan por olvido.
- **Madrugada:** no se enseña (es una pantalla que no muestra la hora a propósito; en una captura parecería vacía). Se nombra en la descripción ("A las tres de la mañana, la pantalla entera es el botón.", 10 §5e.15).

### 3.3 Ficha

| Estado | Qué ve el usuario | Qué hacemos |
|---|---|---|
| Ficha completa | Icono, nombre, subtítulo, valoraciones (las que haya), capturas 1-3 visibles sin desplazar, preview si está activo el autoplay | El orden de las capturas es el orden del argumento: un solo pago → un toque → control → Marea → noche → lo que no hay. Las tres primeras tienen que bastar (lente 5 del jurado) |
| Reproducción automática de la preview desactivada (ajuste Ajustes › App Store › Reproducción automática de vídeo, y, posiblemente, Reduce Motion **[a verificar en iOS 26]**) | La preview muestra el póster (t = 6: la página sonando) | El póster es, en la práctica, una séptima captura: debe leerse sola |
| Sin red | La tienda no carga | Nada que hacer: es Apple |
| Precio del IAP | Aparece en "Compras dentro de la app" con el precio de la tienda local | Es la única cifra de la tienda (C02): `displayPrice`, nunca copy |
| Búsqueda | Nombre + subtítulo + icono a 60 pt sobre fondo del sistema (claro u oscuro) | Por eso el icono se prueba sobre `negro` y sobre fondo claro en la hoja de §2.1 |
| Página de producto en la Apple Store (iPhone de demostración, en claro) | La ficha en claro con el icono negro (Default = Dark) | El objeto es negro también en claro (C32): la tienda lo muestra bien en ambos fondos |

---

## 4. Flujos

### 4.1 Entradas a la ficha

| Entrada | Lo primero que se ve | Lo que debe pasar |
|---|---|---|
| Búsqueda "ruido blanco" / "brown noise" | Icono 60 pt + "SleepNoise" + "Sonidos para dormir" / "Sleep sounds. Pay once." + las dos primeras capturas en miniatura | El icono se distingue a esa escala de los diez de la categoría (§2.1); C1 y C2 dicen "un solo pago" y "un toque" sin leer nada más |
| Prensa / Reddit (enlace directo) | La ficha completa | El titular de C1 responde a la pregunta que trae el lector ("¿es suscripción?"); el "cuánto" lo dice "Compras dentro de la app" en su moneda |
| Featuring de Apple (si llega) | La tarjeta de la tienda con el icono y, si Apple lo pide, material de 4320 × 1080 y vídeo | Se entrega el icono en todas las apariencias y la preview; nada se redibuja para la tarjeta: la misma regla y la misma marea [fuera de 1.0; se anota] |
| Apple Store física (iPhone de demostración, en claro, luz blanca) | Icono negro en la pantalla de inicio clara; la app abierta por un dependiente, oscura (C32) | La prueba de cinco segundos de 03 §3.1 se hace en esta luz |

### 4.2 Salidas

| Salida | Qué ocurre | Lo que no ocurre |
|---|---|---|
| Descarga → primer arranque | La página en reposo con "Esta noche" cargada (Lluvia 30 · Rosa 50), un toque y suena (03 §5 fila 16, C33); el autoarranque existe solo vía Atajos "Al acostarte" | Ningún onboarding, ningún permiso, ninguna hoja de bienvenida, ningún ajuste "abrir sin sonar": la captura 2 se cumple en el primer segundo y la 6 también |
| Ver el IAP en la ficha ("Compras dentro de la app") | La sección muestra nombre, descripción y precio del IAP (`iap.*`, §5.e). **El IAP no se promociona en la ficha en 1.0**: comprar desde la ficha exigiría un IAP promocionado en App Store Connect (imagen promocional de 1024 × 1024 px, que no existe en esta entrega) y que la app atendiera `PurchaseIntent.intents` y llamara a `product.purchase()`; `PurchaseManager` hoy solo escucha `Transaction.updates`. Se compra desde la hoja Pro [E5], nunca de noche (reconciliación §1 regla 7) | Ningún activo promocional; nada propio encima. Si en 1.1 se promociona, el activo es "la regla y la marea sobre `negro`, sin texto" y E5 añade la escucha de `PurchaseIntent.intents` con la hoja Pro delante |
| Abandono | Nada | Ni notificación, ni retargeting (no hay datos), ni línea matinal (C08) |

### 4.3 Interrupciones y mantenimiento de los activos

| Momento | Qué cambia | Qué no cambia |
|---|---|---|
| Oferta posterior (si el dueño la quiere) | Se hace con StoreKit (offer code), no con copy ni con capturas (C02) | Las seis capturas, la ficha: ninguna cifra que caduque |
| Llega el formato v2 con iCloud (1.1, C09) | El pie de C6 pasa a "Sin suscripción. Sin cuenta. Sin rastreo. Tus mezclas, en tu iCloud si quieres." y se repite C6 | Las otras cinco |
| Llega Watch (1.2, C28) | Un juego de capturas de Watch (E6); no entra en las seis del iPhone | Las seis |
| Llega Papel (1.1, C32) | Sigue sin subirse un segundo juego (la App Store no admite dos por idioma); si se quiere para web y prensa, se produce entonces | Las seis de la tienda, el icono (Default sigue siendo negro: el objeto es negro) |
| Cambia la hora o el idioma de la build | Se repiten las capturas con la build nueva | Los titulares |
| iOS 27 cambia la máscara o las apariencias del icono | Se regenera desde el mismo SVG | La geometría |
| Cambia el nombre (reconciliación §6 #2, antes del 04-12-2026) | `tienda.nombre`, `iap.nombre` (= `displayName`), `widget.inline.prefijo` y `nowplaying.artist` (todos leen `app.name` o StoreKit) | El icono (sin letra ni nombre, C10), las capturas, la preview |

### 4.4 Cómo se produce cada captura (para que maqueta y pantalla coincidan, 03 §8.3 puerta 1)

1. Build de referencia de E1 en el simulador de iPhone 17 Pro (iOS 26) con el **estado inyectado** por argumentos de lanzamiento (`-ui-testing-state C3`, por ejemplo) que fijan hora, cuenta, mezcla, nivel bajo el dedo y fase de la Marea, y que ocultan la barra de estado y el indicador de inicio (§2.2). Los estados son los de §3.2; E1 los implementa como parte del pipeline de capturas de accesibilidad que 02 §7 ya exige. C1 y la preview necesitan el **[spike I0-1]** cerrado: sin RMS real no hay fotograma del horizonte que capturar (C2 es reposo: hairline; C3 es la hoja: el horizonte queda tapado).
2. Render a 1179 × 2556 px (393 × 852 a 3×) y composición en el lienzo de §2.2 con un script (no a mano): titular, subtítulo (C1 y C3), escala 0,855, radio 0, sin contorno.
3. El mismo script produce es-ES, es-419 y en-US.
4. Comprobación: cada captura se superpone a la especificación de su pantalla (E2-E5) a escala 1; cualquier diferencia devuelve la captura, no la especificación. Se comprueba además la miniatura de la ficha a tamaño de teléfono **[a medir]**.
5. Juego de control (no se sube): además de las seis, el pipeline produce C3 con el usuario gratuito del día 8 (cinco capas libres sonando, Océano "pro · 30" conservado, C23), para verificar que "Pro sin castigo" es cierto en la build aunque la tienda no lo enseñe.

---

## 5. Las cinco tablas obligatorias

### 5.a Movimiento: elemento → señal del motor → duración/curva → Reduce Motion → Always-On / `isLuminanceReduced`

Aplica a la preview (lo único de esta entrega que se mueve) y al icono (que no se mueve).

| # | Elemento | Señal del motor | Duración / curva | Reduce Motion | Always-On / `isLuminanceReduced` |
|---|---|---|---|---|---|
| MP1 | Preview · nacimiento del horizonte (2,0-2,8 s) | fundido de entrada del motor | 800 ms `.easeOut` (03 §3.7: "igual que la ganancia"). **[E1/E2: `SleepAudioEngine.defaultFadeIn` pasa de 1,5 s a 0,8 s; hasta entonces la grabación mostrará el horizonte naciendo en 1,5 s y el fin del arranque es 3,5 s, no 2,8]** | La preview es un vídeo: se graba **sin** Reduce Motion porque enseña el comportamiento por defecto; con la reproducción automática desactivada y, posiblemente, con Reduce Motion **[a verificar en iOS 26]**, la App Store muestra el póster (t = 6) | n/a (vídeo) |
| MP2 | Preview · horizonte respirando (2,8-8,0; 10,4-13,0) | RMS maestro, 20 Hz, τ 500 ms **[spike I0-1]** | continuo; grosor 1,5 → 3 pt, opacidad 0,6 → 1,0 | igual (vídeo) | n/a |
| MP3 | Preview · descomposición / recomposición (8,0-10,4) | RMS por capa **[spike I0-1]** | 400 ms `.easeInOut` cada sentido | igual | n/a |
| MP4 | Preview · línea de nivel bajo el dedo (13,0-17,2) | ganancia de la capa (gesto) | 0 ms (directo); grosor 2 → 3 en 150 ms | igual | n/a |
| MP5 | Preview · valor 40 → 65 | gesto | cambio de contenido por entero, sin `.numericText()` | igual | n/a |
| MP6 | Preview · línea de agua (17,2-28,0) | `BreathCurve` + `guide.anchor` + `outputLatency` | la banda ya es de 120 pt (la mezcla tiene Marea disponible: nada crece ni se mueve, 03 §3.5); aparecen las marcas y la línea pasa a ser la línea de agua. Un ciclo: sube 4,0 s (18,0-22,0), baja 4,5 s (22,0-26,5), bajamar 1,5 s (26,5-28,0): `BreathCurve` con inhale 0,40 · exhale 0,45 · reposo 0,15 | igual (en la app, Reduce Motion deja la línea fija a media banda y respira por opacidad; la preview no lo enseña) | n/a |
| MP7 | Preview · página → Noche (28,0-30,0) | transición de fase | 2 s de opacidad `.easeInOut`; el toque llega con la línea quieta en bajamar | igual (en la app: 250 ms) | n/a |
| MP8 | Preview · reloj de Noche | reloj del sistema | cambio seco por minuto; en 2 s no cambia | igual | n/a |
| MI1 | Icono en la pantalla de inicio | ninguna | ninguna animación propia; en Clear, el vidrio y el paralaje son del sistema | el sistema los reduce | el sistema |
| MI2 | Icono en la App Store | ninguna | ninguna | — | — |
| MF1 | Ficha · desplazamiento de capturas | del sistema | del sistema | del sistema | — |

Nada de esta entrega se mueve sin señal del motor (P4); la preview es una grabación de la app, no una animación hecha aparte (C53). Prueba: el vídeo se graba de la build con `-ui-testing-state preview` y se compara fotograma a fotograma con la tabla; si el ciclo de la Marea no dura lo que dice la tabla, **se corrige el guion: la señal manda** (los tiempos de MP6 son los de `BreathParameters`, no una cifra redonda del documento). Lo único que se corrige en la build es lo que 03 ya fija y el código aún no cumple (MP1: el fundido de 800 ms).

### 5.b VoiceOver por control

Dos familias: los controles **que las capturas y la preview enseñan** (deben leerse así en la build con la que se capturan: la captura es prueba de la build; las cadenas son las `ax.*` de 10 §5e.16 y las etiquetas visibles de 10 §5e) y los elementos **de la tienda** (que no controlamos pero sí alimentamos).

| Control | Etiqueta | Valor | Pista | Rasgos | Acciones personalizadas |
|---|---|---|---|---|---|
| Disco (C1, C2, preview) | "Reproducir" / "Pausar" ["Play" / "Pause"] (`control.play` / `control.pause`, conservadas de `main`) | — | "Suena en un segundo." ["Starts in a second."] | `.isButton`, `.startsMediaSession`; no es el primero del orden (la barra se lee después del contenido, 04 §9 #17); Magic Tap en la raíz = play/pausa (C63) | — |
| Nombre de la mezcla (C1, C2, preview) | "Rosa y lluvia" (C1) / "Esta noche" (C2, preview) | — | `ax.nombre.pista` "Mantén para guardar o renombrar." ["Hold to save or rename."] | `.isHeader` (el toque de día no hace nada, 05) | `ax.accion.guardar` "Guardar como mezcla", `comun.renombrar` "Renombrar", `mezcla.menu.vaciar` "Vaciar" |
| Cabecera de prueba (C1, preview) | `ax.prueba.cabecera` "Prueba, quedan seis noches" ["Trial, six nights left"] (sin versalitas en la lectura) | — | `ax.prueba.pista` "Toca dos veces para ver qué incluye Pro." ["Double-tap to see what's in Pro."] | `.isButton` de día; `.isStaticText` en `NightWindow` (C08) | — |
| Línea de estado (C1, C2) | "Sonando. Se funde a las cero cuarenta y dos" ["Playing. Fades at twelve forty-two a.m."] · C2: "En silencio" ["Silent"] | — | — | `.isStaticText`; anuncio al cambiar | — |
| Horizonte (C1, C2, preview) | `ax.horizonte` "Sonido" ["Sound"] | `ax.horizonte.valor.medio` "Sonando, nivel medio" / C2: "En silencio" ["Playing, medium level" / "Silent"], con histéresis de 3 s (C63) | — | elemento de estado; **sin `AXChartDescriptor` ni rotor Audio Graph** (C63): las sublíneas de la pulsación larga son decorativas | `ax.accion.capas_separadas` "Ver capas por separado" ["Show layers separately"] |
| Fila de capa (C1, C2, preview t < 13 s) | `ax.capa` "Lluvia, sobre el tejado" ["Rain, on the roof"] | "55 por ciento" (C1) / "30 por ciento" (C2) / "40 por ciento" (preview; sube a 65 durante el arrastre) | `ax.capa.pista` "Desliza arriba o abajo para ajustar." ["Swipe up or down to adjust."] | `.adjustable`, pasos del 5 % | `ax.accion.silenciar` "Silenciar", `ax.accion.maximo` "Máximo", `ax.accion.deslizador` "Ajuste con deslizador" (el `Slider` del sistema, C21) |
| Fila de capa bajo el dedo (C3) | "Lluvia, sobre el tejado" | "52 por ciento" (el valor es el nivel de la captura) | "Desliza arriba o abajo para ajustar." | `.adjustable`, pasos del 5 % | las mismas |
| Fila de capa a 0 (C3, Ventilador) | "Ventilador, ventilador lejano" ["Fan, distant fan"] | "0 por ciento, en silencio" ["0 percent, muted"] | "Desliza arriba o abajo para ajustar." | `.adjustable` (el toque no hace nada, 04 §2.2; el ajuste sí) [E2] | "Máximo", "Ajuste con deslizador" |
| "Capas" · "colores" · "camas" (C3) | `capas.titulo` / `capas.seccion.colores` / `capas.seccion.camas` ["Layers" / "colors" / "beds"] | — | — | `.isHeader` [E2] | — |
| Fila "Timbre" (C3, bajo el pliegue) | `capas.timbre` "Timbre" ["Tone"] | "Grave" … "Lejos" ["Deep" … "Far"] | "Desliza arriba o abajo para ajustar." | `.adjustable` [E2; **spike I0-7**] | — |
| Toggle Marea (C1, C2, C4, preview) | `marea.titulo` "Marea" ["Tide"] | `ax.marea.off` "Desactivada" / `ax.marea.valor` "Guiando, 6 por minuto, se retira a las 23:27" ["Off" / "Guiding, 6 per minute, recedes at 11:27 p.m."] | `ax.marea.pista` "Toca dos veces para encenderla; el sonido arranca." ["Double-tap to turn it on; the sound starts."] (con acceso, en silencio) | `.isToggle` (sistema) | — |
| Línea de agua (C4) | "Marea" ["Tide"] | `ax.agua.valor` "inhala, 6 por minuto, se retira en 15 minutos" ["breathe in, 6 per minute, recedes in 15 minutes"] (a los 25 s quedan 14 min 35 s, que el motor redondea a 15 [E3]) | `ax.agua.pista` "Desliza arriba o abajo para cambiar el ritmo." ["Swipe up or down to change the pace."] | `.adjustable` (1 por minuto); valor hablado "{n} por minuto" (C59) | — |
| Ritmo (C4) | `marea.ritmo.fila` "Ritmo" ["Pace"] | `marea.ritmo.tranquilo` "Tranquilo · 6 por minuto" ["Calm · 6 per minute"] | "Toca dos veces para cambiar" ["Double-tap to change"] [E3] | `.isButton` | — |
| Descenso (C4) | `marea.descenso` "Descenso" ["Descent"] | "Desactivado" ["Off"]; subtítulo "Empezar a 12 por minuto" | — | `.isToggle` [E3] | — |
| Se retira a los (C4) | `marea.retira` "Se retira a los" ["Recedes after"] | "15 minutos" ["15 minutes"] | "Toca dos veces para cambiar" | `.isButton` [E3] | — |
| Más ajustes (C4) | `marea.mas` "Más ajustes" ["More settings"] | — | — | `.isButton` [E3] | — |
| "Qué sabemos ›" (C4) | `sabemos.enlace` "Qué sabemos" ["What we know"] | — | `ax.sabemos.pista` "Abre la pantalla de evidencia." ["Opens the evidence screen."] | `.isButton` (empuja una pantalla; no es un enlace web) [E5] | — |
| Fila Temporizador (C1, C2) | `temporizador.titulo` "Temporizador" ["Timer"] | C1: `ax.temporizador.valor` "Hasta dormirme, quedan 45 minutos" ["Until I sleep, 45 minutes left"]; C2 (reposo): "Hasta dormirme, 45 minutos" | "Toca dos veces para cambiar" ["Double-tap to change"] | `.isButton` [E4] | — |
| "Todas las capas" (C1, C2) | `capas.todas` "Todas las capas" ["All layers"] | — | `ax.mas.pista` "Abre todas las capas." ["Opens all layers."] | `.isButton` | — |
| Barra · "Mezclas" / "Noche" (C1, C2) | `barra.mezclas` / `barra.noche` ["Mixes" / "Night"] | — | — | `.isButton` | — |
| Pantalla Noche (C5) | `ax.noche.pantalla` "Pantalla de noche" ["Night screen"] | `ax.noche.valor` "Tres y siete. Se funde a las tres y cuarenta y dos." ["Three oh seven. Fades at three forty-two."] | `ax.noche.pista` "Toca dos veces para pausar. Mantén para volver." ["Double-tap to pause. Hold to go back."] | un solo elemento (`FullScreenControl`, 04 §2.5); el estado accesible vive aquí, no en el horizonte (C63) | `ax.accion.pausar` "Pausar", `ax.volumen` "Volumen", `ax.accion.volver` "Volver a la página" |
| "+15 min" en Noche (C5) | `ax.mas15` "Quince minutos más" ["Fifteen more minutes"] | — | — | `.isButton` de 64 pt a todo el ancho (03 §4.5); anuncio `ax.anuncio.quedan` "Quedan 50 minutos" tras tocarlo [E4] | — |
| Página "Lo que no hay" (C6) | `lo_que_no_hay.titulo` "Lo que no hay" ["What's not here"] y cada línea como `.isStaticText` | — | — | `.isHeader` el título [E5] | — |
| Icono de la app (pantalla de inicio, tienda) | "SleepNoise" (es `CFBundleDisplayName` = `app.name`; no se añade nada) | — | — | el sistema | — |
| Capturas en la ficha | El sistema anuncia "Captura de pantalla 1 de 6"; **no hay texto alternativo en App Store Connect** | — | — | — | Por eso los seis titulares van como seis párrafos de una línea al final de la descripción (§2.10): es lo que VoiceOver lee |
| Preview en la ficha | El sistema anuncia "Vista previa de la app" | — | — | — | Sin pista de audio descriptiva (la preview es muda); la descripción dice lo que enseña |

### 5.c Gesto → alternativa sin gesto → Control por botón → teclado / Pointer

Los gestos que la preview enseña y que las capturas insinúan. La alternativa es la que fijan 03 §4 y 04, y la que E2-E4 especifican; aquí se cita para que la preview no enseñe un gesto sin alternativa.

| Gesto (dónde) | Alternativa sin gesto | Control por botón (Switch Control) | Teclado / Pointer (iPad, Mac si llega) |
|---|---|---|---|
| Toque en el Disco (preview 2,0 s) | Es un botón; Magic Tap en la raíz (C63); Siri "Pon ${applicationName}" (C10, C43); Live Activity (1.0 solo en escenario A, C25); Centro de control y botón de Acción (iOS 18; 1.0 con corte en la semana 14, C26); en iOS 17, Siri y el Reproduciendo del sistema | Un elemento en el barrido | Espacio / Retorno con foco; clic |
| Pulsación larga sobre el horizonte (preview 8,0 s) | Acción "Ver capas por separado" de VoiceOver (C63); la hoja Capas enseña lo mismo fila a fila | Acción del menú de Switch Control sobre el horizonte | Tecla de menú contextual con foco en el horizonte |
| Arrastre horizontal sobre la fila (preview 13,0 s; C3) (`LevelRule`, 04 §2.2; C52: horizontal = nivel, vertical = scroll) | `.adjustable` (flechas arriba/abajo de VoiceOver, 5 %); pulsación larga → `Slider` del sistema de 44 pt que sustituye a la línea en su sitio (C21); Control por voz: "incrementar Lluvia" / "disminuir Lluvia" (pasos del 5 %) o "tocar Lluvia" + el `Slider` | El `Slider` del sistema (aparece con Switch Control) | Flechas izquierda/derecha con foco en la fila (±5), Mayús + flechas (±1) |
| Toggle Marea (preview 17,2 s; C1, C4) | Es un toggle del sistema | Elemento del barrido | Espacio |
| Arrastrar la línea de agua (C4, control del ritmo) | Fila "Ritmo" con sus valores; `.adjustable` con valor hablado "{n} por minuto" (C59) | La fila "Ritmo" | Flechas con foco en la línea de agua |
| Toque en "Noche" (preview 28,0 s) | Es un botón de la barra; Noche entra al bloquear por defecto, con opción 1 / 3 min solo desde la página (C47) | Elemento del barrido | Retorno con foco |
| Toque en Noche = pausa (C5) | Acción por defecto del elemento único; "Controles visibles de noche" (−15 min · pausa · +15 min · Página, de 64 pt) activados solos bajo Switch Control o AssistiveTouch, o a mano en Ajustes (C58); Acceso asistido en 1.1 (C39) | Los controles visibles | Espacio |
| Arrastre vertical en Noche = nivel maestro de sesión (no se enseña; C51: `master` con rampa, nunca el volumen del sistema; "Sonando · al 40") | Botones físicos; acción "Volumen" (`ax.volumen`) | Botones físicos; el `Slider` "Volumen" de los controles visibles | Teclas de volumen |
| "+15 min" (C5, Noche) | Es un botón de 64 pt (03 §3.5), solo si hay temporizador (C47); Siri "Añade 15 minutos en ${applicationName}" (`ExtendTimer`, C43); la Live Activity de bloqueo lo lleva (escenario A) | Elemento del barrido | Retorno |
| Pulsación larga en Noche = volver (no se enseña) | Acción "Volver a la página"; con VoiceOver, el gesto en Z | Controles visibles: "Página" | Esc |
| Desplazar las capturas en la ficha | Del sistema | Del sistema | Del sistema |

Ningún gesto de varios dedos, ningún pellizco, ningún doble toque (Madrugada siempre es un botón, C27), ningún arrastre horizontal en Noche (03 §6), ningún gesto de timbre (C29, C52): la preview no enseña ninguno.

### 5.d Dynamic Type por tramo

Las capturas se toman en **Large** (es lo que la tienda muestra; los titulares del lienzo no son texto dinámico sino píxeles). Esta tabla fija (1) qué cambia en las pantallas que las capturas enseñan en cada tramo, para que el juego de control del pipeline (02 §7, punto 1: Large · xxxLarge · AX3 · AX5, ES y EN) coincida con E2-E5, y (2) qué pasa en la ficha y en el icono.

| Tramo | Página (C1, C2) | Capas (C3) | Marea (C4) | Noche (C5) · Lo que no hay (C6) | Icono y ficha |
|---|---|---|---|---|---|
| xS-L | Todo cabe en 852 sin desplazar; filas de capa de 80; nombre 28; horizonte en y 284 | Filas de 80; valor bajo el dedo a 17; la hoja desplaza (once filas) | Banda 120; filas 56 | Reloj 72; "+15 min" 20 en fila de 64 · C6: líneas 28 en filas de 72 | El icono no cambia. La ficha: la tienda escala su propio texto; el titular de la captura es imagen y **no** escala: por eso los titulares están también en la descripción |
| xL-xxxL | Filas crecen con `@ScaledMetric` (80 → 88 → 96); el aire entre grupos baja (32 → 24) antes que las filas; desde xxL aparece desplazamiento y el horizonte se ancla bajo la cabecera [E2] | Filas 88-96; el valor sigue en línea mientras quepa (`ViewThatFits`) | Banda 120 (no es texto); el estado puede ocupar dos líneas | Reloj 72 → 88 (tope `.accessibility2`); estado en dos líneas; "+15 min" escala con `.title3` · C6: dos líneas por entrada si hace falta | Igual |
| AX1-AX2 | Cada fila pasa a nombre arriba, valor debajo, línea debajo; fila 96-112 (04 §2.2); bloqueo de eje a 30° en el arrastre; la cabecera de prueba en dos líneas | Igual; las secciones "colores" / "camas" siguen | Las filas apilan clave y valor; la línea de agua se queda a 120 | Reloj 88; "+15 min" en dos líneas si hace falta · C6: igual | Igual |
| AX3-AX5 | Filas 112-140; "y 2 más" aparece con una sola capa visible; el horizonte reduce su altura; "Mezclas" y "Noche" pasan a `square.stack` y `circle.lefthalf.filled` con etiqueta accesible (`barra.mezclas.ax` / `barra.noche.ax`) en AX4-AX5 (03 §3.6) | Una capa visible por pantalla y desplazamiento; el valor bajo el dedo no crece más de 23 pt | Estado y filas en dos líneas; "Qué sabemos ›" en dos líneas | Reloj se queda en 88; "Se funde a las 03:42" en dos líneas centradas · C6: la lista desplaza | Igual. En la ficha, el nombre "SleepNoise" (10 caracteres) no se trunca; el subtítulo puede truncarlo el sistema |

Comprobación: el pipeline de capturas de E1 produce, además de las seis de tienda, las cuatro variantes (Large, xxxLarge, AX3, AX5) de C1, C3, C4 y C5 en ES y EN; ninguna se sube, todas se revisan.

### 5.e Catálogo de cadenas ES / EN por clave, con contexto y longitud máxima

Las claves `tienda.*`, `captura.*`, `preview.*`, `iap.*` y `novedades.*` las fija esta entrega y se suben a App Store Connect (o a las localizaciones del IAP). Sus valores son los de 10 §5e.15 donde 10 los fija (nombre, subtítulo, promo, descripción, IAP, notas de versión, titulares de las capturas, lista y pie de C6); esta entrega añade solo las keywords, el subtítulo de C1 (una frase de `tienda.promo`), el de C3 (= `tip.arrastre`) y las Notes for Review. Las claves de las pantallas que aparecen en las capturas pertenecen a E2-E5 y se citan con la clave y el valor de 10 §5e para que la captura y la build coincidan.

**Ficha (por tienda; longitudes contadas, carácter a carácter):**

| Clave | es-ES | es-419 (si difiere) | en-US | Contexto · máximo |
|---|---|---|---|---|
| tienda.nombre | SleepNoise (10) | = | SleepNoise (10) | Nombre de la ficha · 30. = `app.name`; sin "Pro"; C10 (cierre 04-12-2026; si cambia, cambia aquí y en `iap.nombre`, nunca en el icono) |
| tienda.subtitulo | Sonidos para dormir (19) | = | Sleep sounds. Pay once. (23) | Subtítulo · 30. Con el nombre se lee "SleepNoise: Sonidos para dormir" (C10; 10 §5e.15) |
| tienda.keywords | ruido blanco,marron,rosa,lluvia,viento,mar,ventilador,respiracion,sin suscripcion,insomnio,acufenos (99) | ruido blanco,marron,rosa,lluvia,viento,mar,ventilador,respirar,sin suscripcion,insomnio,acufenos (96) | brown noise,white,pink,rain,wind,ocean,fan,breathing,generative,insomnia,tinnitus,snoring,loop (94) | Palabras clave · 100; ninguna palabra del nombre ni del subtítulo ("sonidos", "dormir"; "sleep", "sounds", "pay", "once"); "insomnio" / "acufenos" / "insomnia" / "tinnitus" solo aquí (informe §5.2, C54); sin "siesta" / "nap" (C30); sin "bebe" (03 §7.6); "viento" entra porque es libre (C04) |
| tienda.promo | Sonido que nunca se repite, fabricado en tu iPhone. Siete noches con todo, sin tarjeta. Un solo pago. (101) | Sonido que nunca se repite, generado en tu iPhone. Siete noches con todo, sin tarjeta. Un solo pago. (100) | Sleep sound that never loops, made on your iPhone. Seven nights with everything, no card. One payment. (102) | Texto promocional · 170 (10 §5e.15). Sin cifra, sin fecha, sin cuenta de texturas (C02, C04); `tienda.promo.lanzamiento` retirada por C02 |
| tienda.descripcion | Los cuatro párrafos de 10 §5e.15 (ES; el primero: "SleepNoise fabrica en tu iPhone, mientras suena, un ruido que no se repite jamás: … Todas las texturas, una línea cada una." (230); el último: "Sin suscripción. Sin cuenta. Sin rastreo.") | "genera" por "fabrica" | Los cuatro párrafos EN de 10 §5e.15 ("Breathing tide" solo aquí, C15) | Descripción; sin cifra (C02) ni número de texturas (C04) · sin máximo práctico |
| tienda.descripcion.titulares | Los seis `captura.n.titular`, uno por párrafo, en orden, tras los cuatro párrafos | = | idem en EN | Es lo que VoiceOver lee en lugar de las capturas (§5.b) [E7 integra] |
| tienda.categoria | Salud y forma física · Estilo de vida | = | Health & Fitness · Lifestyle | — |
| tienda.privacidad | No se recopilan datos **[a verificar literal]** | = | Data Not Collected | Etiqueta de privacidad (la fija Apple; aquí se cita para el pie de C6) |
| tienda.notes_review | — | — | Texto en-US (no se localiza; §2.10): trial Tier 0 detrás de "Start the trial · 7 nights" (C07); test de autocorrelación a 10 min en CI (C53); estudios de "What we know" con su etiqueta clínica (C54); diagnóstico solo por el correo del usuario (C56) | Notes for Review · 4000 |
| iap.nombre | SleepNoise Pro (14) | = | SleepNoise Pro (14) | Nombre de visualización del IAP · 30 = `product.displayName` (C12) |
| iap.descripcion | Todo, un solo pago (18) | = | Everything, one payment (23) | Descripción del IAP · 45 (hoy 108 / 88 en `.storekit`: se corrige). 10 §5e.15. Se escribe en App Store Connect y se copia al `.storekit` (§9.11) |
| novedades | Las cuatro líneas de 10 §5e.15; l1 "SleepNoise, rediseñada: una página negra, una línea que respira con el sonido real, y una pantalla de Noche que es toda ella el botón." (134) | = | "SleepNoise, redesigned: a black page, one line that breathes with the real sound, and a Night screen that is all button." (120) + tres líneas | Notas de versión 1.0 · 4000 |

**Capturas (titular 28 Display Medium, una o dos líneas, ≤ 41; subtítulo 17 Regular, una línea ≤ 42, solo C1 y C3):**

| Clave | es-ES | es-419 (si difiere) | en-US | Contexto · máximo |
|---|---|---|---|---|
| captura.1.titular | Un solo pago. (13) | = | One payment. (12) | C1 · 41. Sin cifra en ninguna tienda (C02, C57) |
| captura.1.subtitulo | Siete noches con todo, sin tarjeta. (35) | = | Seven nights with everything, no card. (38) | C1 · 42 (frase de `tienda.promo`) |
| captura.2.titular | Un toque y suena. (17) | = | One tap and it plays. (21) | C2 · 41 (C33, C57). Sin subtítulo |
| captura.3.titular | Seis capas a la vez. Una línea cada una. (40) | = | Six layers at once. One line each. (34) | C3 · 41 (C19, C57; dos líneas) |
| captura.3.subtitulo | = `tip.arrastre`: Arrastra sobre el nombre para cambiar el nivel. (47) | = | Drag across the name to change the level. (41) | C3 · 42 **[a medir: ES supera el estimado; si no cabe en una línea, E7 fija la variante corta, §9]** |
| captura.4.titular | El mar respira a seis por minuto. (33) | = | The sea breathes six times a minute. (36) | C4 · 41. Sin subtítulo (§2.6) |
| captura.5.titular | A las tres de la mañana, nada. (30) | = | At three in the morning, nothing. (33) | C5 · 41. Sin subtítulo ni pie (§2.7); `captura.5.pie` retirada por C57 |
| captura.6.titular | Lo que no hay. (14) | = | What's not here. (16) | C6 · 41 (§3 de la reconciliación) |
| captura.6.lista | = `lo_que_no_hay.lista`: Sin suscripción · Sin cuenta · Sin rastreo · Sin anuncios · Sin puntuación · Sin racha · Sin tutorial (101) | = | No subscription · No account · No tracking · No ads · No score · No streak · No tutorial (88) | C6, siete líneas de 28 (la más larga, 15) |
| captura.6.pie | No se recopilan datos · {MB} MB (31) | = | Data Not Collected · {MB} MB (28) | C6, paso 8 · 40; sin cifra de precio (C02); el peso es el de `ajustes.version` |
| preview.poster | (sin texto: el fotograma t = 6,0) | = | = | Póster de la preview; una preview por idioma (C57) |

**Cadenas de la app que aparecen en las capturas (propiedad de E2-E5; clave y valor de 10 §5e):**

| Clave (10) | ES | EN | Dónde |
|---|---|---|---|
| `pro.prueba.estado` [E5] | prueba · quedan {n} noches | trial · {n} nights left | C1, preview (n = 6); C2 vacía (noche 1, C07) |
| `mezcla.casa.rosa_lluvia` [E5] | Rosa y lluvia | Pink and rain | C1 (mezcla de la casa cargada tal cual) |
| `mezcla.nombre.vacio` / `page.name.tonight` [E2/E5] | Esta noche | Tonight | C2, preview (la mezcla viva, §3 de la reconciliación) |
| `pagina.estado.sonando.funde` · `pagina.estado.silencio` [E2] | Sonando · se funde a las {hora} · En silencio | Playing · fades at {time} · Silent | C1, preview · C2 |
| `sound.{id}` / `capas.{id}.detalle` [E2] | Blanco · siseo parejo / Rosa · suave y equilibrado / Marrón · retumbo grave / Lluvia · sobre el tejado / Viento · entre árboles / Océano · oleaje lento / Ventilador · ventilador lejano | White · even hiss / Pink · soft and balanced / Brown · low rumble / Rain · on the roof / Wind · through trees / Ocean · slow swell / Fan · distant fan | C1, C2, C3 |
| `capas.todas` [E2] | Todas las capas | All layers | C1, C2 (sin cifra ni chevron) |
| `capas.titulo` / `capas.seccion.colores` / `capas.seccion.camas` / `capas.timbre` / `capas.nota` [E2] | Capas / colores · camas / Timbre / Se mezclan en tu iPhone mientras suenan. Nada se repite. | Layers / colors · beds / Tone / Mixed on your iPhone as they play. Nothing loops. | C3 |
| `marea.titulo` / `marea.estado.apagada.fila` [E3] | Marea / Apagada | Tide / Off | C1, C2 (fila de la página) |
| `marea.instruccion` [E3] | Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla. | Breathe in as the wave rises, out as it pulls back. No need to watch the screen. | C4 (= `breath.hint` de `main`, conservada) |
| `marea.fase.inhala` / `marea.estado.guiando.corto` / `marea.retira.hora` [E3] | inhala / guiando · 6 por minuto / Se retira a las {hora} | breathe in / guiding · 6 per minute / Recedes at {time} | C4, preview |
| `marea.toggle` / `marea.ritmo.fila` · `marea.ritmo.tranquilo.corto` / `marea.descenso` · `marea.ritmo` / `marea.retira` · `marea.retira.valor` / `marea.mas` [E3] | Marea / Ritmo · Tranquilo · 6 / Descenso · Empezar a 12 por minuto / Se retira a los · 15 min / Más ajustes | Tide / Pace · Calm · 6 / Descent · Start at 12 a minute / Recedes after · 15 min / More settings | C4 |
| `marea.evidencia` / `sabemos.enlace` [E3/E5] | Respirar a unas 6 veces por minuto se asocia en estudios a mayor variabilidad cardiaca. / Qué sabemos › | Breathing at about 6 per minute is linked in studies to higher heart-rate variability. / What we know › | C4 |
| `temporizador.titulo` / `temporizador.estado.dormirme` [E4] | Temporizador / Hasta dormirme · {n} min | Timer / Until I sleep · {n} min | C1, C2 (n = 45: el ajuste, 07 por defecto) |
| `barra.mezclas` / `barra.noche` [E1] | Mezclas / Noche | Mixes / Night | C1, C2, C3 |
| `noche.estado.funde` / `comun.mas15` [E4] | Se funde a las {hora} / +15 min | Fades at {time} / +15 min | C5, preview |
| `lo_que_no_hay.titulo` / `.lista` / `.resena` / `.diagnostico` / `.pie` [E5+E7] | Lo que no hay / (lista) / No te pediremos que la valores. / Un registro de la noche, en tu teléfono. Solo sale si tú lo envías. / Sin suscripción. Sin cuenta. Sin rastreo. | What's not here / (list) / We won't ask you to rate it. / A log of the night, on your phone. It only leaves if you send it. / No subscription. No account. No tracking. | C6 |

es-419: ninguna de las cadenas de las capturas cambia; de la ficha cambian `tienda.keywords` ("respirar") y "genera" por "fabrica" en `tienda.promo` y `tienda.descripcion` (10 §0.3). "Toca", "Guardar" y "de por vida" valen en los dos españoles (marea.md 14.1); "Hoguera" (es-419 "Fogata") no aparece en ninguna captura.

---

## 6. Variantes

| Variante | Icono | Capturas | Preview | Ficha |
|---|---|---|---|---|
| **iPhone 17 Pro (393 × 852)** | — | El render de dentro se toma en 17 Pro: es la geometría de referencia de 03 | Grabada en 17 Pro | — |
| **iPhone SE / 16e (375 × 667 · 390 × 844)** | — | No se sube un juego de SE (App Store Connect no lo pide desde 2024 **[a verificar]**); el pipeline produce C1, C3 y C4 en 16e como control: la columna pasa de 353 a 350, el horizonte a un tercio de 844 (y 280), nada se recorta | — | — |
| **Negro (único, C57)** | Default = Dark | Las seis de §2 | §2.9 | — |
| **Papel** | No existe en 1.0 (C32): el icono es negro en cualquier fondo | Ningún segundo juego: la App Store no admite dos por idioma, y la app no tiene modo claro hasta 1.1; si entonces se quiere para web y prensa, se produce en 1.1 | No se graba: la preview es nocturna | — |
| **ES / EN** | — | Tres juegos: es-ES, es-419, en-US (§5.e) | Una preview por idioma (la build en ese idioma; mismo guion; C57) | Tres fichas |
| **High Contrast (Aumentar contraste)** | Sin cambio (el icono no es interfaz) | No se sube; el pipeline produce C1 y C3 con `índice-ac`, `texto2-ac`, `texto3-ac`, `trazo-ac` como control de que nada desaparece | — | El sistema |
| **Button Shapes** | — | Control: en C1 y C2 "Mezclas", "Noche", "Todas las capas", la cabecera de prueba (C1) y en C4 "Más ajustes", "Qué sabemos ›" muestran el subrayado del sistema; el Disco no cambia (es un botón con forma); "+15 min" en C5 muestra el subrayado; las filas-control no son `Button` (su alternativa es el `Slider` por pulsación larga) | — | — |
| **Escala de grises (Filtros de color)** | La elevación se lee por forma; la marea (`índice`, L ≈ 0,56) queda algo más oscura que la regla (`texto`, L ≈ 0,78), 1,35:1 (§3.1) | Control: en C1 el horizonte en gris sigue siendo más grueso que la hairline; en C3 la línea bajo el dedo sigue siendo 3 pt sobre pista `grafito`; en C4 el toggle en on se distingue por la posición del pomo (ya va en `texto`). Nada se pierde (P7) | Idem | — |
| **Filtro rojo de StandBy** | No aplica (el icono no aparece en StandBy) | No aplica: StandBy no está en la tienda (C57); el criterio de C62 (≥ 24 pt, ≥ 3:1 medido, spike I0-6) es de E6 | No aparece | — |
| **Reduce Motion** | — | — | Con la reproducción automática desactivada (ajuste de la App Store) y, posiblemente, con Reduce Motion **[a verificar en iOS 26]**, la App Store no reproduce la preview sola; se ve el póster (t = 6) | — |
| **Reduce Transparency** | Clear pasa a opaco (sistema) | Control: la barra de C1-C3 pasa a opaca; nada propio usa materiales (C66) | — | — |

---

## 7. Háptica por evento

Nada de esta entrega vibra. La tabla existe para que la preview no simule lo que la app hace con el cuerpo, y para dejar escrito qué háptico corresponde a cada gesto que la tienda enseña (03 §3.8; C35: la puerta es por fase, de noche nunca vibra, sin CoreMotion en 1.0; E2-E4 los implementan).

| Evento (dónde) | De día, iPhone en la mano | De noche (Noche, Madrugada, página nocturna) | En la preview / capturas |
|---|---|---|---|
| Toque en el Disco (preview 2,0 s) | `.impact(.medium, 0.7)` al inicio del fundido | nada | No se simula: ni destello, ni "vibración" dibujada |
| Cruzar 0 / llegar a 100 en la fila (preview 13-18 s) | `.selection` / `.impact(.light, 0.6)` | nada | No se simula; el valor en la preview va de 40 a 65 sin tocar 0 ni 100 a propósito |
| Pasos intermedios del nivel | nada | — | — |
| Toggle Marea (preview 18 s) | el del sistema (`.selection`) | — | — |
| Marea "Mínima" (C4, bajo "Más ajustes") | Core Haptics continuo siguiendo `BreathCurve` 3-5 respiraciones al empezar, opt-in (C35); "Marcada" se va al Watch (1.2) | nunca | La captura no lo dice; la hoja lo lleva bajo "Más ajustes" |
| Toque en "Noche" (preview 28 s) | ninguna (03 §3.8: entrar en Noche no vibra) | — | — |
| Toque en Noche (C5) | — | **ninguna**: lo confirma el sonido | — |
| "+15 min" (C5) | — | ninguna: de noche nunca vibra (C35, puerta por fase) | — |
| Abrir la ficha, ver el precio, descargar | nada propio | — | — |

---

## 8. Lo que se queda fuera, y por qué

| Fuera | Por qué |
|---|---|
| *Mockups* inclinados, bisel pintado, manos, sombras, degradados, fondos de color, ilustraciones, estrellas, lunas | Brief §7.1; 03 §6; el lienzo es negro y la pantalla es la pantalla |
| Sellos ("Editors' Choice", "#1", premios, laureles), testimonios, estrellas de valoración dibujadas | Nada que parezca más de lo que es (P4, Rams); si Apple destaca la app, lo dice Apple en su tarjeta |
| Cualquier cifra de precio en la tienda (titular, descripción, promo, pie de C6) y cualquier precio de lanzamiento | C02: un solo `displayPrice` de StoreKit, en "Compras dentro de la app" y en la hoja Pro; una oferta posterior sería un offer code, no copy |
| Número de texturas ("once", "siete Pro", "50+ sonidos") | C04: nunca se cuentan texturas en paywall ni ficha ("Todas las texturas, una línea cada una."); Apple tiene 16 gratis (informe §7.5). La tienda dice "capas" (lo que suena a la vez) y "texturas" (el catálogo), nunca "sonidos" ni "ranuras" |
| Comparaciones nominales (Dark Noise, Calm, Apple) | Brief §7.2 |
| "IA", "personalizado", "mejora el sueño", "insomnio" en pantalla, "terapia", "relajante", "vitalicio", "timer", "mix", "Escudo", "Tu instrumento", "Desbloquear", "envolvente", "chip", "Lluvia fina", "Siesta" (hasta 1.1), "Amanecer" (hasta 2.0) | Lista negra §7.2, informe §5.2 y la lista de palabras que no se graban de la reconciliación §3; "insomnio" / "acufenos" solo en el campo de keywords |
| Captura del paywall | Una captura del paywall es el gesto de las apps que viven de él; el "cuánto" lo dice la tienda |
| StandBy, Live Activity, widgets, Isla en la tienda | C57: C5 es Noche sola; la Live Activity recortada existe solo en escenario A (C25) y una captura no puede depender de una pareja de ingenieros |
| Capturas de Madrugada, de la hoja Pro, de Ajustes, de "Qué sabemos", de "Cómo se genera" | No responden a una pregunta de compra; viven en la descripción [E7]. "Lo que no hay" sí se captura (C6), porque responde a "¿qué me van a pedir después?" |
| Capturas de iPad, Mac, Watch | No hay app de iPad ni de Mac; Watch es 1.2 (C28) |
| Segundo juego en papel | C32: la app es solo oscura en 1.0 |
| Preview con música, voz, texto animado, cortes, zoom o aceleración; una "envolvente" animada | La app no tiene música; el ritmo de la Marea es la verdad que se vende; la prueba de "nunca se repite" es "Cómo se genera" + MB + el test de CI (C53) |
| Iconos alternativos | Firma de Dark Noise (03 §6; `01-REFERENCIAS` §"Qué no") |
| Un icono con el nombre, con una "S", con una onda de sonido, con auriculares | Brief §6: "un objeto, no una luna"; `01` §7.1; C10: el icono no depende del nombre |
| Vídeo de featuring / material de tarjeta de la App Store | Fuera de 1.0 hasta que Apple lo pida; se haría con el mismo SVG |
| Web | C38: es de E8, posterior a 1.0; no forma parte de esta especificación |
| Campañas de pago (Apple Ads) y sus creatividades | Informe §1, riesgo 5: con un CPI de 4-10 $ no cierra; el crecimiento es prensa, Reddit y featuring |

---

## 9. Preguntas abiertas

Las que la reconciliación cierra se listan al final como cerradas, con su ficha; no vuelven al dueño.

**Para el dueño:**

1. **La cresta del icono: 576 (retícula, 3:4 en x) o 563 (4:6 exacto).** 03 §5 escribe las dos cosas; esta entrega construye 576 y recomienda mantenerlo (a 29 pt la diferencia es 0,37 pt y la retícula importa más para Tinted y Clear). Si prefiere el 4:6 literal, cambian dos números en el SVG: cresta en (563, 352) y el punto de control de bajada en (723, 352).
2. **Los diez iconos de la categoría.** La hoja de §2.1 los necesita capturados en dispositivo (ningún informe pudo hacerlo). ¿Los captura el estudio en la semana 3 con la cuenta del dueño? (Semana 3 = la del icono según C10; no espera al nombre.)
3. **Acento** (reconciliación §6 #1, 27-11-2026): el icono se entrega con `índice`; si el dueño elige otro matiz tras la prueba de cinco segundos, cambia el hex de la capa `marea` y nada más.
4. **Marca** (reconciliación §6 #2, 04-12-2026): `tienda.nombre` e `iap.nombre` leen el nombre; el icono no. Nada de esta entrega espera a la decisión.

**Para E7 (copy) y para los spikes y para ingeniería:**

5. **Pendiente de E7 · subtítulo de C3.** Esta entrega usa `tip.arrastre` tal cual (47 caracteres); si no cabe en una línea a 17 pt en 376 pt **[a medir]**, E7 fija una variante corta (≤ 42) en 10 §5e.15 y esta tabla la copia. No se inventa aquí una frase que no esté en la guía.
6. **Pendiente de E7 · Notes for Review.** El texto en-US de §2.10 (prueba Tier 0, test de autocorrelación, etiqueta clínica de los estudios, diagnóstico por correo) lo redacta E7 en 10 §5e.15; aquí solo está el guion.
7. **Pendiente de E5 · anatomía de "Lo que no hay".** C6 se captura de la página real (C38); el wireframe de §2.8 es lo que esta entrega espera (lista primero, entradas en prosa, pie); si E5 ordena la página de otro modo, se repite la captura.
8. **Estados inyectables** (`-ui-testing-state C1…C6, preview`) en la build de referencia de E1: hora fija (C1: 23:57 con 45 min; C2: 23:40 en reposo, noche 1; C3: 23:40; C4: Marea iniciada a las 23:12:00 y captura a los 25 s, Descenso off; C5: 03:07 con fin a las 03:42; preview: 23:12 con 45 min), cuenta (noche 1 sin prueba para C2; prueba noche 2 para C1, C3, C4, preview), mezcla (§3.2, columna "Mezcla": la de la casa "Rosa y lluvia" cargada tal cual en C1; "Esta noche" en las demás), nivel bajo el dedo (C3 a "52"), fase de la Marea (C4 en la tercera respiración al 70 % de la subida), barra de estado e indicador de inicio ocultos (§2.2), y la nota de una vez de la noche 1 cerrada (C2). Sin esto, las capturas se hacen a mano y dejan de ser prueba de la build.
9. **`SleepNoise.storekit` y App Store Connect:** `displayPrice` 4,99 y `familyShareable: false` en el fichero de pruebas contra 29,99 de lista sin lanzamiento (C02) y "En familia" en 1.0 (C12); descripción del IAP de 108 / 88 caracteres donde se admiten 45 (`REVIEW-PR3`). Las `iap.*` de §5.e se escriben en App Store Connect (localizaciones del producto) y se copian tal cual al `.storekit`: ningún String Catalog las compila. `displayName` del producto = "SleepNoise Pro" (es lo que `pro.titulo` enseña).
10. **Preview con el sonido real.** La dirección fija la preview muda. Propuesta para después del lanzamiento: una segunda preview idéntica con la pista de audio de la propia app (sin música, sin voz) para la prueba de "nunca se repite" con auriculares; se decide con datos de la ficha, no ahora. (La prueba de 1.0 es "Cómo se genera" + MB + el test de CI, C53.)
11. **Tinted en Xcode 26:** confirmar que una capa de primer plano con dos colores (regla `texto`, marea `índice`) se aplana a una sola tinta y que la forma de la marea se mantiene; si Icon Composer exige una sola capa para Tinted, se entrega la capa combinada de §2.1.
12. **Peso de la build** para el pie de C6 (`{MB}`): el de la build firmada de 1.0, con un decimal; el mismo valor que `ajustes.version` fija en build (10 §5e.12).
13. **[spike I0-1] es bloqueante para C1 y la preview.** El motor de `main` no tiene medidor RMS ni canal render → main: sin el spike cerrado, el fotograma del horizonte y la descomposición por capa serían inventados y esas dos piezas no se pueden capturar de la build (§2.3, §2.9, §5.a). C2 (reposo) y C3 (hoja) no dependen de él.
14. **[spike I0-7]** condiciona la fila "Timbre" de C3 (bajo el pliegue: si cae a 1.1, la captura no cambia).
15. **Constantes de la build que la preview enseña:** `SleepAudioEngine.defaultFadeIn` es 1,5 s y 03 §3.7 fija 800 ms (MP1: cambia la constante, no el guion); `BreathParameters` 0,40 · 0,45 · 0,15 manda sobre el "4 s / 6 s" (MP6: cambia el guion, no la constante); `MixerModel.setBreathingEnabled` sube el océano (hoy a 50; 10 fija 40 en `marea.oceano.subido`) y enseña la nota si la mezcla no lo lleva (la preview y C4 parten con océano a 30); `defaultLevels()` es Rosa 65 sola y 05 §4.4 fija Lluvia 30 · Rosa 50 para C2.

**Cerradas por la reconciliación** (antes abiertas en esta entrega; se dejan para que el jurado vea qué se preguntaba):

- "Seis" u "once" en C3 → **cerrada por C19**: once texturas en 1.0, tope de seis simultáneas como regla de modelo; el titular es "Seis capas a la vez. Una línea cada una." y la cifra es el tope, no el catálogo.
- La cifra del precio en el titular de C1 y las localizaciones en-GB / en-AU / en-CA → **cerrada por C02**: sin cifra en ninguna tienda; en-US sirve a todas las inglesas.
- Modo papel (7.3) → **cerrada por C32**: solo oscura en 1.0; Default = Dark; ningún juego en papel.
- Precio de lanzamiento (7.8) → **cerrada por C02**: no existe; `tienda.promo.lanzamiento` retirada.
- Prueba local o non-consumable a 0 € → **cerrada por C07**: se dispara con la primera acción Pro desde la hoja Pro, estado en Keychain, Tier 0 detrás de la misma palabra; el subtítulo de C1 ("sin tarjeta") sigue siendo verdad.
- "Sin red" en C6 → cerrada aquí (§2.8) y **confirmada por C09**: "Sin rastreo"; "Sin servidor" tampoco.
- C6 como composición o como pantalla → **cerrada por C38**: "Lo que no hay" es una página de la app; C6 se captura de la build (riesgo 2.3.3 resuelto).
- "Mar" en el nombre español ("Ruido Blanco y Mar") → **cerrada por C10**: "SleepNoise: Sonidos para dormir" (nombre + subtítulo).
- Tinte real de StandBy (spike I0-6) para C5 → **cerrada por C57**: C5 es Noche sola; el spike sigue siendo de E6, no de la tienda.
- Toggle de la Marea en on con la línea de agua en índice → **cerrada por 03 §4.12 consolidado**: el Toggle va en `.tint(texto)`; un índice por pantalla sin excepciones.
- "Apagada" junto al toggle de la fila Marea → **cerrada por 10 §2.1**: la fila lleva `marea.estado.apagada.fila` en paso 7; esta entrega la toma tal cual.

---

## 10. Autoevaluación

### 10.1 Contra la puerta de formato (03 §8.3, puerta 1)

| Requisito | Estado |
|---|---|
| Tabla de movimiento con señal del motor | §5.a: MP1-MP8 (preview), MI1-MI2 (icono), MF1 (ficha); cada fila nombra la señal o dice "ninguna" |
| Tabla VoiceOver por control (etiqueta / valor / pista / rasgos / acciones) | §5.b: 27 filas, todos los controles que las capturas enseñan (incluidas las filas de la hoja Marea, las cabeceras y la fila a 0 de Capas, la cabecera de prueba, la página "Lo que no hay") con las claves `ax.*` de 10 §5e.16, y los elementos de la tienda que no controlamos y lo que hacemos por ellos (los titulares en la descripción) |
| Tabla gesto → alternativa → Control por botón → teclado | §5.c: 11 filas; ningún gesto de la preview sin alternativa; sin gesto de timbre ni doble toque (C27, C29, C52) |
| Dynamic Type por tramo (xS-L · xL-xxxL · AX1-AX2 · AX3-AX5) | §5.d: cuatro tramos × cinco columnas, con el juego de control del pipeline |
| Catálogo de cadenas ES/EN por clave con contexto y máximo | §5.e: 23 claves propias (12 de ficha + 11 de capturas y preview) con longitudes contadas carácter a carácter (nombre 10, subtítulos 19/19/23, keywords 99/96/94, promo 101/100/102, IAP 18/23, titulares 13-40) y 17 filas de claves citadas de 10 §5e (E2-E5), con su clave y su valor |
| Todas las medidas en pt | Sí, salvo el icono (px sobre 1024, como 03 §5 fila 27) y las resoluciones de exportación, que son px por naturaleza. Las escalas de los renders se derivan de cotas en la retícula de 4 (§2.2) |
| Un único juego de hex, el de §3 de 03 | Sí: 15 tokens nocturnos listados en la cabecera (los 11 de §3.1 más los cuatro `-ac`) y, de los de papel (1.1, C32), solo `tinta` y `ocre` para la apariencia Clear claro del icono, que es del sistema; el SVG usa `#000000`, `#E8E4DC`, `#F0C020` y, en Clear claro, `#1E1C19`, `#8A6508`. Ningún rojo de StandBy: no hay StandBy en la tienda |
| Maqueta y texto coinciden | El SVG de §2.1 es la geometría de la tabla de §2.1 (mismos puntos, mismo trazo, mismo orden de capas; pendientes y radio medidos sobre esas cúbicas); los wireframes de §2.3-2.8 llevan las cotas de 05 §2.1 y §2.7, 10 §2.3 y 07 §2.2 y las mismas cadenas que sus tablas y que 10 §5e (C1 "Rosa y lluvia" 55/20, 45 min; C2 "Esta noche" 30/50; C3 seis capas; C5 03:07 → 03:42 = 35 min); la preview de §2.9 lleva tramos que no se solapan y suman 30,0 s, con el ciclo de la Marea a los tiempos de `BreathParameters` |
| Vocabulario y reparto | §3 y §4 de la reconciliación: "capa" / "textura" / "mezcla" / "Esta noche" / "Marea" / "Descenso" / "Hasta dormirme" / "Manto" / "Seis a la vez" / "Lo que no hay" / "Qué sabemos" / "Cómo se genera"; 5 texturas libres / 6 Pro sin contar; temporizador entero libre; 3 mezclas gratis; prueba de 7 noches desde la hoja Pro; "En familia" en 1.0; Watch 1.2; Live Activity solo en escenario A |
| Extensión | Objetivo 60-120 KB |

### 10.2 Contra las doce pruebas del brief (00 §4)

| P | Prueba | Cómo la pasa esta entrega |
|---|---|---|
| P1 Noche manda | C5 es la captura diseñada primero (negro, una tinta, una sola pantalla); la preview termina en Noche; el icono se prueba primero sobre negro |
| P2 Un gesto | C5 enseña "+15 min" como botón de 64 pt en Noche (solo si hay temporizador, C47); la preview enseña toque = suena y toque = Noche; §5.c da la alternativa de cada gesto; Madrugada siempre es un botón (C27) |
| P3 Negro real, un acento | Lienzo `negro`; un índice por captura (C1 horizonte, C3 línea bajo el dedo; C2, C4, C5 y C6 sin color: el toggle de la Marea va en `texto`, 03 §4.12); el icono: el índice como un solo trazo de 112 px (≈ 6 % de la superficie visible, 8,7 % de trazo), nunca relleno; la regla del 0,3 % de 03 §7.1 es de interfaz y no aplica a un icono, donde la línea tiene que ser objeto |
| P4 Causa en el sonido | §5.a: la preview es una grabación de la build (C53); ninguna animación hecha aparte; nada acelerado; los tiempos del ciclo son los de `BreathParameters`; C2 enseña el reposo como reposo (hairline, sin color) |
| P5 Una familia | SF Pro en todo lo propio (titulares 28 Display Medium, subtítulos 17 Regular, pies 13); sin New York. Estilos: la regla "≤ 6 por pantalla" de 03 §3.4 (C67: nueve pasos; 17 Medium cuenta) es por pantalla de la app, y todas las pantallas que las capturas enseñan la cumplen (C1 y C2 5: 2, 5, 7, 9 + 17 Medium de la barra; C3 5 visibles: 3, 5, 7, 9 + 17 Medium tabular; C4 6: 3, 5, 6, 7, 8, 9; C5 3: 1, 3, 4; C6 4: 3, 2, 6, 8). El lienzo es el rótulo de una fotografía, no una pantalla, y añade el titular (paso 2) y, en C1 y C3, el subtítulo (paso 6): estilos distintos en la imagen C1 6 · C2 6 · C3 7 · C4 7 · C5 4 · C6 5 |
| P6 Aire antes que cajas | Cero rectángulos rellenos propios en los lienzos; las capturas enseñan el Disco (único relieve), el toggle del sistema y la pista `grafito` bajo el dedo; C6 agrupa con hairlines; ninguna captura lleva contorno (una sola pantalla negra sobre el lienzo negro) |
| P7 Forma, no color | El icono se lee en Tinted, en gris y en Clear; C5 se lee en una tinta; el toggle on de C4 se lee por la posición del pomo; el estado de Noche es línea continua + palabra |
| P8 44 / 64 | Todo lo que las capturas enseñan como control cumple 03 §3.5 (Disco 64 de área, "+15 min" 64, filas 56 + 24 de canal) |
| P9 Nada bloquea el sonido | C3 enseña seis capas sonando con la barra presente y cero candados (ningún estado de la app tiene candados: "pro · N" conserva el nivel, C23); ninguna captura del paywall; la ficha no promete lo que la prueba no da ("lo gratis sigue gratis"); nada se vende de noche (reconciliación §1 regla 7) |
| P10 Una pantalla, una decisión | §1: cada superficie lleva su pregunta; C5 responde a una sola ("¿me va a iluminar la cara?") con una sola pantalla |
| P11 Lo técnico, debajo | C4 enseña "Tranquilo · 6" y "Más ajustes", no un stepper; C3 enseña el valor bajo el dedo, no un panel; "Timbre" vive bajo el pliegue |
| P12 Componentes de Apple | Capturas y preview sin marcos propios; el icono en Icon Composer con las apariencias del sistema y sin efectos propios; la ficha con los campos que Apple da (nombre, subtítulo, keywords, promo, IAP, Notes for Review) sin trucos; el precio lo dice StoreKit |

**Listas negras.** Visual (00 §7.1): sin tarjetas, halos, degradados, luna, estrellas, nubes, ilustración, rejilla, gamificación, candados, badges, tachaduras, cuentas atrás, SF Rounded, Light, blanco puro, vidrio propio, dos acentos, asas falsas, iconos animados, bienvenida. **Cumple.** Copy (00 §7.2, informe §5.2 y reconciliación §3 "palabras que no se graban"): revisado palabra a palabra en §5.e; "insomnio" / "acufenos" / "insomnia" / "tinnitus" solo en keywords (C54); "un solo pago" en lugar de "vitalicio"; "temporizador" y "mezcla"; sin "Escudo", "Tu instrumento", "Desbloquear", "envolvente", "chip", "Lluvia fina", "Cama rosa", "Mar lento", "Tormenta lejana", "v1/v2", "Siesta", "Amanecer", "lanzamiento"; ninguna cifra de precio ni de texturas; ninguna comparación nominal; ninguna cifra de eficacia; ningún "mejora", "terapia", "relajante", "IA". **Cumple.** Desempate del brief: esta entrega ha quitado el *mockup*, la mano, el degradado, el sello, la captura del paywall, el número de sonidos, los iconos alternativos, la música de la preview, el segundo color del icono, el contorno y la barra de estado de todas las capturas, los subtítulos de C2, C4 y C5, el pie de C5, el chevrón de la principal, la cifra del precio y el juego en papel, sin perder ninguna de las seis respuestas de §1.

---

## 11. Respuesta al jurado

Todo lo bloqueante y mayor de las cinco listas se ha aplicado, y lo menor salvo lo que sigue. Cada línea es un hallazgo rechazado (o aceptado solo en parte) y su razón escrita; 03 §3-§4 es ley y gana a cualquier jurado, y la reconciliación del 16-11-2026 gana a 03 (§12). Donde la reconciliación ha dejado sin objeto un hallazgo, se anota.

1. **Tipografía (mayor): quitar el subtítulo de las seis capturas.** Rechazado en parte: se conservan los de C1 y C3, porque dicen lo que la pantalla no dice (la prueba sin tarjeta; que la fila se arrastra); se quitan los de C4 y C5 (decían lo que la pantalla ya dice) y el de C2 (la página en reposo ya es la frase; C33/C57). El conteo honesto está en §10.2 P5 (C3 y C4 llegan a 7 estilos en la imagen).
2. **Tipografía (mayor): C5 con Noche a 0,65 y StandBy a 0,60 recortado al ancho del lienzo.** Sin objeto: C57 deja C5 como Noche sola, a la escala común de §2.2, sin contorno ni pie. Lo mismo para 3 de la mañana, plataforma y primera impresión sobre el díptico.
3. **Primera impresión (mayor), opción (a): bajar la cresta a y 448 y poner los puntos de control a un tercio.** Rechazado: 03 §5 fila 27 fija la cresta en (576, 352). Se toma la opción (b) y algo más: se mide (73° / 61°, radio 60 px), se quita del texto "coseno elevado" y la promesa de asimetría visible a 29 pt, y se suaviza solo la bajada (puntos de control a 0,45 del tramo: 61° en lugar de 68°, radio 74 px), que no toca ningún número de 03. Los puntos de control de la subida siguen cruzados a propósito: a un tercio el radio cae a 24 px y el trazo se pliega.
4. **Tipografía (menor): C1-C4 a 344 × 744 en x 48, y 212-956.** Rechazado: deja 0 pt de margen inferior. Se toma 336 × 728 en x 52, y 196-924 (margen inferior 32 = el lateral del titular, como pedía primera impresión), con la escala derivada de la cota y la regla de retícula escrita en §2.2.
5. **Primera impresión (menor): eliminar el pie de C6 y la clave `captura.6.pie`.** Rechazado en parte: se quita la cifra de precio (como pedía honestidad, y como manda C02), se conservan la etiqueta de privacidad y el peso, que son los dos hechos verificables detrás de "lo que no hay" y que la página real (C38) también enseña.
6. **Honestidad (mayor) / 3 de la mañana: el estado inyectado de la preview con temporizador de 90 min (Pro).** Sin objeto en parte: el temporizador es entero libre (C03) y ningún valor es Pro; se mantiene el 45 por defecto (07) porque es lo que ve quien no toca nada; "se funde a las 23:57".
7. **3 de la mañana (mayor): subtítulo "honesto" en C5 ("Un toque pausa; otro añade quince minutos").** Rechazado: C5 se queda sin subtítulo (tres jurados). La preocupación de fondo (que "+15 min" es una banda de 64 pt y no la pausa) está en la fila de §5.b y en 03 §4.5.
8. **Plataforma / primera impresión (menor): `iap.descripcion` como "Capas Pro, Marea, temporizador y mezclas" o "…temporizador sin límite".** Sin objeto: 10 §5e.15 fija "Todo, un solo pago" / "Everything, one payment" (C12: lo que incluye lo dice la hoja Pro; C03: el temporizador no es Pro; C04: no se cuentan texturas). La propuesta anterior de esta entrega ("Ventilador, océano, Marea, temporizador largo") queda retirada.
9. **Tipografía / 3 de la mañana / primera impresión (menor): sus listas de keywords concretas.** Aceptado el principio (ninguna palabra del nombre ni del subtítulo), rechazadas las listas tal cual: repetían palabras del título. Las de §5.e cumplen la regla con el nombre y el subtítulo de C10 y están contadas (99 / 96 / 94).
10. **Primera impresión (menor): cambiar el nombre español a "Ruido y Lluvia" o "Ruido Blanco".** Sin objeto: C10 fija "SleepNoise: Sonidos para dormir" (nombre + subtítulo); "ruido blanco" pasa a las keywords.
11. **3 de la mañana (menor): "Qué sabemos ›" como `.isLink`.** Rechazado: empuja una pantalla de la app, no abre una URL; es `.isButton` con la pista `ax.sabemos.pista` "Abre la pantalla de evidencia." (10 §5e.16).
12. **Tipografía (mayor): quitar los chevrones de C4 porque 03 §3.6 prohíbe iconos.** Aceptado con matiz: 03 §3.6 veta los iconos "en la principal y en el mezclador fuera de la barra"; la hoja Marea no es ninguna de las dos, y 10 §2.3 pone un chevron tipográfico ("›") en "Más ajustes" y en "Qué sabemos ›": la captura lo enseña así. En la principal ("Todas las capas") no hay chevron ni cifra.
13. **Primera impresión (mayor): contorno de C5 a 1 pt `trazo-hoja`.** Sin objeto: C5 es una sola pantalla (C57) y no lleva contorno, como las demás.
14. **Tipografía (mayor): toggle en on con `.tint(texto3)` mientras la línea de agua es índice.** Sin objeto: 03 §4.12 consolidado fija el Toggle en `.tint(texto)` siempre; un índice por pantalla sin excepciones; la preview y C4 lo toman así.

---

## 12. Reconciliación aplicada (16-11-2026)

Fuente: `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`. Orden de aplicación 10 → 04 → 05-09 → 11 → 03 → plan: esta entrega hereda el vocabulario de 10 (ya corregido) y los tokens y componentes de 04 y 03 consolidado; 05, 07 y 08 estaban sin reconciliar al escribir esto, así que donde difieren de la reconciliación manda la reconciliación, y de ellos se toma solo lo que la tarea les reserva (05: geometría de la página; 08 = 10 §5e.3: redacción de la prueba; 07: fila Temporizador del primer uso; 03 §4.10: la hoja Capas sobre `negro`). Una línea por delta que nombra a 11 (por número, por "ficha", "capturas", "preview" o por regla de §1, §3, §4 y §5 aplicable a todo el paquete).

**Deltas aplicados**

- C02 → captura 1 "Un solo pago." sin cifra en ninguna tienda (§2.3, §5.e); descripción, promo y pie de C6 sin cifra; `tienda.promo.lanzamiento` retirada; la única cifra de la tienda es `displayPrice` en "Compras dentro de la app" (§3.3); §4.3 sin precio de lanzamiento; §8; §9 preguntas 3 y 5 cerradas.
- C03 → ninguna captura ni cadena muestra un valor Pro en el temporizador; C3 deja de ser "60 min (el máximo gratuito)" y es "Hasta dormirme · 45 min"; `iap.descripcion` sin "temporizador largo"; §11 #6.
- C04 → ficha sin "once" ni "siete"; "Todas las texturas, una línea cada una." en la descripción (10 §5e.15); C3 titula el tope (seis capas), no el catálogo; "viento" en keywords como textura libre; §8.
- C05 → Madrugada no se enseña y se nombra en la descripción con la frase de 10; nunca prueba ni paywall (§3.2).
- C06 → sin escucha de 30 s: la preview no la enseña (§2.9); las filas Pro de VoiceOver con "treinta segundos" retiradas de §5.b.
- C07 → la cabecera "prueba · quedan 6 noches" aparece solo desde que la prueba empieza en la hoja Pro; C2 (noche 1) tiene la cabecera vacía; Notes for Review explica el Tier 0 detrás de "Empezar la prueba · 7 noches"; §9 pregunta 6 cerrada.
- C08 → §4.2: sin línea matinal; la cabecera de prueba es texto estático en `NightWindow` (§5.b).
- C09 → pie de C6 y de la página "Sin suscripción. Sin cuenta. Sin rastreo." (`lo_que_no_hay.pie`); "Sin rastreo" en la lista (ya estaba) y "Sin servidor" fuera; §4.3 anota el pie de 1.1 con iCloud.
- C10 → ninguna rama condicionada al nombre: el icono sin letra ni nombre, la hoja de prueba y el legal en la semana 3; título de ficha "SleepNoise: Sonidos para dormir" como `tienda.nombre` "SleepNoise" + `tienda.subtitulo` "Sonidos para dormir" (10 §12.2: 31 caracteres no caben en el campo Nombre de 30); keywords sin las palabras del nuevo subtítulo y con "ruido blanco"; §4.3 fila "Cambia el nombre"; §9.16 ("Mar" en el nombre) cerrada; §11 #10.
- C11 / C15 → "Manto", "Hasta dormirme" / "Until I sleep", "Marea" / "Tide" (la fila y el toggle ya no dicen "Marea respiratoria" / "Breathing tide"; "Breathing tide" solo en la prosa EN de la descripción), "Small hours" en §5.b; "Escudo" en la lista de palabras que no se graban (§8).
- C12 → `iap.nombre` = `product.displayName`; `iap.descripcion` "Todo, un solo pago" (10 §5e.15); sin "Desbloquear" ni "Tu instrumento" en la tienda; "En familia" (Family Sharing 1.0) citado en §2.10 y §9.11.
- C13 → "Trueno" con "lejano, sin rayos cerca" en C3 (bajo el pliegue) y en §5.e; "Tormenta lejana" no se graba.
- C17 / C18 → C1 carga la mezcla de la casa "Rosa y lluvia" (rosa 20 · lluvia 55, 10 §5e.9) tal cual; el subtítulo de Lluvia pasa de "lluvia fina" a "sobre el tejado" (10 §5e.4) en C1, C2, C3 y §5.e.
- C19 → captura 3 "Seis capas a la vez. Una línea cada una." con seis capas sonando sobre la hoja de once texturas; §9.2 ("seis u once") cerrada; §4.3 sin la fila "llegan las once capas"; "ranuras" fuera (§8).
- C21 / C52 → §5.c: arrastre horizontal = nivel, vertical = scroll; pulsación larga = `Slider` del sistema en su sitio; sin gesto de timbre.
- C23 → "pro · N" conserva el nivel: descrito en §2.5, §3.2 y verificado en el juego de control (§4.4 paso 5), ya no en C3 (la captura está en prueba para enseñar seis capas sonando).
- C24 / C34 / C59 → C4: toggle + línea de agua, nunca círculo; fila "Descenso" con "Empezar a 12 por minuto" (apagada en la captura); sin "v1/v2".
- C25 / C50 / C62 → StandBy y Live Activity fuera de la tienda (C5 es Noche sola); el spike I0-6 deja de condicionar una captura; §6 y §9 actualizados.
- C26 / C43 → §5.c: Centro de control y botón de Acción en 1.0 (iOS 18); Siri con `${applicationName}` ("Pon ${applicationName}", `ExtendTimer`).
- C27 → §5.c: Madrugada siempre es un botón; sin doble toque.
- C28 → Watch 1.2 en §2.1 (tamaño 20 pt), §4.3, §7 y §8 (antes 1.1).
- C29 → fila "Timbre" (`LevelRule` del bus maestro, extremos "Grave" / "Lejos") al pie de Capas en C3, bajo el pliegue, condicionada al spike I0-7 (§5.b, §9.14).
- C30 → "siesta" / "nap" fuera de las keywords; "Siesta" en la lista de palabras que no se graban hasta 1.1.
- C32 → solo oscura en 1.0: Default del icono = Dark (negro) en todas las apariencias salvo Clear claro (tokens `tinta` + `ocre` solo ahí, como apariencia del sistema); sin juego de capturas en papel; §2.1, §3.1, §3.3, §4.1, §6; §9.4 cerrada.
- C33 → captura 2 "Un toque y suena.": la página del primer uso en reposo ("Esta noche", Lluvia 30 · Rosa 50, cabecera vacía, Disco en play); §4.2 sin "abrir sin sonar", autoarranque solo vía Atajos.
- C35 → §7: puerta de háptica por fase (de noche nunca vibra); Marea "Mínima" opt-in; "Marcada" al Watch 1.2; "+15 min" en Noche sin háptica.
- C38 → C6 se captura de la página real "Lo que no hay" (plan B de 2.3.3 ya no hace falta; §9.15 cerrada); "Cómo se genera" citada como prueba de "nunca se repite"; la web es de E8, posterior (§8).
- C39 → "Esta noche" = el nombre de la mezcla viva en C2, C4 (tapado), preview y §5.b.
- C40 → `NightWindow` 21:00–07:00 para la cabecera de prueba como texto estático (§5.b).
- C46 / C47 → C5: anatomía fija de Noche (reloj 72 ocultable, palabra de estado, pantalla-botón, "+15 min" solo si hay temporizador); entra al bloquear (§5.c).
- C51 → §5.c: arrastre vertical en Noche = `master` de sesión ("Sonando · al 40"), no el volumen del sistema.
- C53 → preview = la página real sonando, una por idioma; Notes for Review cita el test de autocorrelación a 10 min en CI (§2.10, §5.e `tienda.notes_review`); "envolvente" fuera (§8).
- C54 → Notes for Review puede nombrar la etiqueta clínica de los estudios; en app y ficha, lista negra sin excepción (keywords aparte, como ya fijaba el informe §5.2).
- C55 / C56 → C6 enseña "No te pediremos que la valores." y "Un registro de la noche, en tu teléfono. Solo sale si tú lo envías." como entradas de la página; Notes for Review explica el diagnóstico por correo; la etiqueta "Data Not Collected" se justifica con C56.
- C57 → tabla de capturas con los seis titulares de 10 §5e.15 (C1 "Un solo pago." · C2 "Un toque y suena." · C3 "Seis capas a la vez. Una línea cada una." · C4 "El mar respira a seis por minuto." · C5 Noche sola "A las tres de la mañana, nada." · C6 "Lo que no hay." / "What's not here."); una preview muda por idioma; solo fondo negro; `captura.5.pie` retirada; §1, §2, §3.2, §5.e, §10.
- C63 → §5.b: el Horizonte es un elemento de estado "Sonido" con valor por tramos (histéresis 3 s) y acción "Ver capas por separado"; sin `AXChartDescriptor` ni rotor Audio Graph; en Noche el estado vive en el `FullScreenControl`; Magic Tap en la raíz; el Disco no es el primero del orden (04 §9 #17).
- C66 → barra con vidrio del sistema en iOS 26 declarada en C1-C3; nada propio usa materiales (§6 Reduce Transparency).
- C67 → §10.2 P5: nueve pasos, ≤ 6 por pantalla, 17 Medium cuenta; conteos por captura rehechos.
- §1 regla 7 (nada se vende de noche) → §4.2 y §5.b; regla 8 (los números son los del código) → cabecera, §2.10, §3.3.
- §3 vocabulario → "capa" (lo que suena a la vez) frente a "textura" (el catálogo) en §8 y §2.5; "Esta noche"; "Lo que no hay" / "What's not here"; "Qué sabemos"; "Cómo se genera"; "Seis a la vez"; "Se retira"; la lista de palabras que no se graban en §8 y §10.2.
- §4 reparto y §5 alcance → 5 texturas libres (con viento) / 6 Pro; temporizador entero libre; 3 mezclas gratis; Marea Pro (y para todos en Madrugada); prueba 7 noches en Keychain; En familia 1.0; Live Activity solo en escenario A; widget mediano, Papel, iCloud 1.1; Watch 1.2; iOS 17; 29,99 sin lanzamiento; reflejado en §2, §4.3, §6 y §8.

**Coherencia con las fuentes consolidadas (pasada de 10, 03 §3-§4 y 04)**

- Cadenas de interfaz de §5.e copiadas de 10 §5e con su clave: `pro.prueba.estado`, `mezcla.casa.rosa_lluvia`, `mezcla.nombre.vacio`, `pagina.estado.*`, `sound.*` / `capas.*.detalle`, `capas.todas`, `capas.titulo` / secciones / `capas.timbre` / `capas.nota`, `marea.*`, `sabemos.enlace`, `temporizador.*`, `barra.*`, `noche.estado.funde`, `comun.mas15`, `lo_que_no_hay.*`; VoiceOver con las `ax.*` de 10 §5e.16. Cadenas de tienda de 10 §5e.15 letra a letra (nombre, subtítulo, promo, descripción, IAP, notas, titulares, lista y pie de C6).
- Discrepancias entre specs resueltas: cabecera de la página con la geometría de 05 §2.1 (y 64-82, nombre y 100-134, estado y 144, filas 312/392, "Todas las capas" 552-608, Marea 640-712, Temporizador 712-768) y la redacción de 08 = 10 (`pro.prueba.estado`); nombre de la mezcla viva "Esta noche" (§3) y nombre propio solo para una mezcla guardada cargada tal cual (C1); fila Temporizador del primer uso "Hasta dormirme · 45 min" (07 §2.1); hoja Capas sobre `negro` con hairlines `trazo` (03 §4.10 consolidado), antes `hoja #1C1C1E`.
- Tokens y componentes: 15 tokens nocturnos de 03 §3.1 (los de papel marcados 1.1 salvo `tinta` / `ocre` en Clear claro del icono); grosor del horizonte 1,5-3 pt (03 §4.1, errata corregida); Toggle `.tint(texto)` (03 §4.12); nombres de 04: `SoundLine`, `LevelRule`, `TideLine`, `PlayDisc` (el Disco), `FullScreenControl`, `HairlineAction`; barra 17 Medium como variante del paso 6 (04 §2.0.2); banda de 120 pt siempre que la mezcla tenga Marea disponible (03 §3.5 / 04 §2.0.3): la preview ya no "crece" la banda.

**Deltas rechazados**

Ninguno. Ninguno contradice el código del hilo de audio ni es materialmente imposible. Dos matices, no rechazos: (1) el título de ficha de C10 (31 caracteres) no cabe en el campo Nombre de 30 y se aplica como nombre + subtítulo, igual que 10 §12.2; (2) C3 no puede enseñar a la vez "seis capas a la vez" y "pro · 30": con cinco texturas libres (C04) el tope de seis exige una capa Pro sonando, así que la captura va en prueba y el estado "pro · N" (C23) se verifica en el juego de control del pipeline (§4.4), no en la tienda.

**Pendiente que la reconciliación deja a 11** (§9): subtítulo de C3 si `tip.arrastre` no cabe (E7); Notes for Review redactadas (E7); anatomía de la página "Lo que no hay" (E5); cresta del icono (dueño); diez iconos de la categoría (dueño); spikes I0-1 (bloqueante para C1 y preview) e I0-7 (fila Timbre); `.storekit` y App Store Connect (`displayPrice`, `familyShareable`, descripción del IAP).
