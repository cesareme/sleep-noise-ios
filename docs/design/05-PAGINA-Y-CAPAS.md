# SleepNoise · 05 · Página principal y Capas

**Equipo E2 (Página y Capas) · 16 de noviembre de 2026 · Documento 05 de la serie de diseño · Fase de especificación · Revisión 3: revisión 2 tras la puerta de los jurados (§11) más la reconciliación producto–diseño aplicada (§12)**

Pantallas 1-5 del inventario de la dirección (03 §5): la página principal en sus estados, la página nocturna, los cuatro momentos de la página (noche 1, noche 7, noche 8, error de audio, interrupción) y la hoja Capas con once texturas y tope de seis a la vez. Primer uso en lo que toca a la página.

**Insumos leídos completos:** 03-DIRECCION-DE-DISENO consolidado (tokens §3, componentes §4, inventario §5, puertas §8.3, reconciliación aplicada §12), `RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§0-§6), 10-GUIA-DE-COPY consolidada (§0.2 glosario, §2.1-2.2, §3, §5b, §5e), 04-SISTEMA-FUNDAMENTOS (nombres de componentes y medidas), brief E2 del director creativo, `tokens.md`, `grafts.md`, `decisions.md`, 00-BRIEF-CREATIVO (P1-P12, listas negras §7), 02-MATERIALES, `concepts/grafito.md` entero y, por tema, `dial.md`, `marea.md`, `silencio.md`; el código de `main` (`AccessPolicy.swift`, `SoundID.swift`, `MixerModel.swift`, `MixerView.swift`, `SoundRowView.swift`, `BreathingGuideController.swift`, `BreathingCard.swift`, `SleepTimerController.swift`, `TimeFormat.swift`, `MixStore.swift`, `SavedMix.swift`, `Localizable.xcstrings`, `AudioSessionObserver.swift`, `AudioSessionConfigurator.swift`, `SleepAudioEngine.swift`); informe de mercado §1 y §5.2 (lo que no se afirma); REVIEW-PR3 §"Encaje" y hallazgos de interfaz; las cinco listas de la puerta de los jurados (respondidas en §11).

**Convenciones.** Medidas en pt para iPhone 393 × 852 en tamaño Large (área segura 59 arriba, 34 abajo; barra inferior del sistema 49 pt → ocupa 769-852). Variante SE/16e sobre 375 × 667 (barra de estado 20, sin inset inferior; barra 618-667). Columna de 353 pt (margen 20); 335 en 375. **Retícula de 4 pt** (03 §3.5): todo renglón y toda área táctil empiezan en un múltiplo de 4; el horizonte va a altura × 0,333 medida sobre la pantalla completa y redondeada al múltiplo de 4 más próximo (852 → 284; 844 → 280; 667 → 224). Hex: únicamente los de 03 §3; aquí se nombran por token y el hex se repite solo en la tabla de tokens de uso. Textos de interfaz en ES con EN entre corchetes; las cadenas de §5e son las que se compilan y van por las claves de 10 §5e (una cadena, una clave; cuando E2 necesita una cadena que 10 no tiene, se usa la redacción más cercana de 10 y se anota en §9 como "pendiente de E7"). **Hora:** `Date.FormatStyle` corto del sistema (es-ES "0:42", "7:00"; en-US "12:42 AM"); los wireframes se dibujan en es-ES y las medidas EN de §6 se toman con "12:42 AM". **`NightWindow`** = 21:00–07:00, la única constante horaria de la app (C40): ningún tip, ninguna venta, ninguna reseña dentro de ella. **[a medir]** = no verificado en dispositivo. **[spike I0-n]** = depende del spike de ingeniería n (03 §8.1; semana 2: I0-2, I0-3, I0-5/5b, I0-6, I0-7). Cuando esta entrega precisa algo que 03 deja abierto, lo dice como "decisión E2" y lo razona; cuando contradice lo que existe en `main`, lo dice en §9; cuando un jurado pidió algo contrario a 03 §3-§4, se rechaza y se razona en §11; lo que la reconciliación decidió manda sobre 03 y sobre el plan, y está aplicado sin marcas en §1-§11 y listado en §12.

**Tokens que usa esta entrega** (03 §3.1; sin inventar ninguno): `negro #000000` · `grafito #1E1D1B` · `trazo #2A2A2E` · `texto #E8E4DC` · `texto2 #9C9A96` · `texto3 #6E6C68` · `texto-noche #A2A09A` · `índice #F0C020` · `índice-noche #BA941C` · `índice-ac #FFD23C` · `texto2-ac #B4B2AE` · `texto3-ac #7A7672` · `trazo-ac #3A3836`. Papel (03 §3.3, **1.1**, C32; 1.0 es solo oscura con `preferredColorScheme(.dark)` en la raíz): `papel #F3F0E9` · `tinta #1E1C19` · `tinta2 #5F5A53` · `tinta3 #9C958A` · `ocre #8A6508` · `trazo-papel #D8D3C9` · `pulsado-papel #E9E5DC`. `hoja` y `trazo-hoja` no se usan: Capas es la única hoja sobre `negro` (03 §3.1 y §4.10).

**Escala tipográfica** (03 §3.4, nueve pasos; se citan por número): 1 Cifra · 2 Nombre (Display Medium 28/34, `.title1`) · 3 Cabecera (Semibold 22/28, `.title2`) · 4 Acción nocturna · 5 Fila (Semibold 17/22, `.headline`) · 6 Cuerpo (Regular 17/22, `.body`) · 7 Secundario (Regular 15/20, `.subheadline`; Medium de noche) · 8 Nota (Regular 13/18, `.footnote`) · 9 Dato (Medium tabular 13/18, `.footnote`; versalitas reales tracking +2 %). Además, **un estilo compartido fuera de los nueve pasos: 17 Medium** (`relativeTo: .body`, `monospacedDigit()` cuando es cifra), el de las palabras de la barra (03 §4.11) y del valor bajo el dedo (03 §4.2); cuenta como estilo propio (C67). La página usa 2, 5, 6 (solo las acciones de la línea 2: "Seguir por el altavoz", "Enviar informe"), 7, 9 y 17 Medium: **6, al límite de 03 §3.4** (≤ 4 en reposo: 2, 5, 7, 9; el 6 y el 17 Medium aparecen con la barra y con una acción, conteo honesto declarado en 03 §12 nota). Capas usa 3, 5, 7, 9 y 17 Medium: 5 (las notas van en paso 7, no en 8: decisión E2, §9 #5).

---

## 1. Intención (P10: la pregunta de cada pantalla)

| # (03 §5) | Pantalla | Pregunta a la que responde | Lo que NO responde (vive en otra pantalla) |
|---|---|---|---|
| 1 | Página principal · reposo | **"¿Qué va a sonar?"** El nombre de la mezcla ("Esta noche" mientras no sea una guardada), la línea quieta, las capas que suenan y a qué nivel, si hay Marea, cuándo se apaga. | Qué capas existen (Capas), cuál de mis mezclas (Mezclas), cómo respiro (Marea), cuánto cuesta (Pro). |
| 2 | Página principal · sonando / con Marea / en pausa / fundiendo | **"Esto se está fabricando ahora."** El horizonte respira con el RMS real; la línea de estado dice lo que pasa y lo que falta. | Cuánto queda al segundo (Noche / Live Activity). |
| 3 | Página nocturna | **"¿Puedo silenciar la lluvia sin encenderme la cara?"** La misma página con una tinta, por procedencia (al volver de Noche; dura la sesión; C40). | Nada nuevo: no es otra pantalla. |
| 4 | Página · noche 1, noche 7, noche 8, error de audio, interrupción | **"¿Qué ha cambiado y qué hago?"** Un texto de una vez, nunca una hoja; un error que es un botón; una pausa que dice lo que el sistema sabe y nada más. | Comprar y empezar la prueba (hoja Pro, E5), qué sigue gratis en detalle (Pro y Ajustes, E5). |
| 5 | Capas (hoja `.large` sobre `negro`) | **"¿Qué capas, a qué nivel?"** Once filas-control (1.0, C19), dos secciones, tope de seis a la vez, fila "Timbre" al pie (C29), una nota. | Marea, temporizador, mezclas, Pro (la fila "pro" lleva a la hoja Pro de día, C06). |

La regla de reparto con las otras entregas: **todo lo que la página enseña de la Marea, el Temporizador, las Mezclas y Pro es su fila o su línea de estado, nunca su contenido.** La fila "Marea" de esta página es de E2; la hoja que abre, de E3. La fila "Temporizador", de E2; la hoja, de E4. La barra "Mezclas", de E2; la pantalla, de E5. El texto de la nota de una vez lo fija 10 (E7) con E5; su sitio, su medida y su comportamiento son de E2. Las cadenas se citan por las claves de 10 §5e.

---

## 2. Anatomía

### 2.0 Geometría común de la página (Large, 393 × 852)

El horizonte va a un tercio de la altura: **y = 284** (852 × 0,333 = 283,7 → 284, en retícula). Es la constante del sistema (03 §1.3 y §3.5); todo lo demás se coloca a partir de él. Nada cambia de posición entre estados: cada elemento tiene su renglón y, cuando no tiene contenido, el renglón queda vacío (Silencio, 03 §3.7). La banda del horizonte mide **24 pt (272-296), o 120 pt siempre que la mezcla cargada tenga Marea disponible** (prueba activa o Pro; 03 §3.5 y §4.1): entonces ocupa **176-296, hacia arriba** desde el horizonte (bajamar = horizonte), reservada desde el principio y vacía en reposo; al encender la Marea no crece nada: aparecen por opacidad las marcas y la línea de agua (§2.3). La nota de una vez ocupa el aire que hay entre el estado y el horizonte (196-256) y solo existe en silencio, cuando la banda, reservada o no, no dibuja nada.

La página es **siempre un `ScrollView`** con `.scrollBounceBehavior(.basedOnSize)` (iOS 16.4): en xS-L cabe entera en 852 y en 667 y no se desplaza; desde xL se desplaza (§5d). Una sola jerarquía para todos los tamaños; la barra queda fija. El canal de 24 pt y el cono de 30° (§2.6) protegen por tanto un scroll real en todos los tramos.

```
 y (pt)   ┌──────────────────────── 393 ────────────────────────┐
   0      │ barra de estado del sistema                          │  0-59
  64      │ cabecera · paso 9 versalitas texto2                  │  64-82  (área táctil 52-96; botón solo fuera de NightWindow)
 100      │ NOMBRE DE LA MEZCLA · paso 2 Display Medium 28/34    │  100-134 (área táctil 96-140 solo en la página nocturna)
 144      │ línea de estado · paso 7 texto2        [fase Marea]  │  144-164 (botón 140-184, 2 líneas, en error de audio)
 164      │ línea 2 · acción secundaria 17 Regular · o vacía     │  164-184 (área táctil 152-196 cuando es botón)
 176      │ ┄ marca de pleamar (solo con la Marea guiando) ┄     │  banda reservada 176-296 si la mezcla tiene Marea disponible
 196      │ nota de una vez · paso 7 texto2 · 3 líneas · botón   │  196-256 (solo en silencio) · o "Enviar informe" (3.er fallo)
 272      │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ banda del HORIZONTE ┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │  272-296 · línea en 284 · 16 de aire bajo la nota
 312      │ fila-control 1 · 80 de paso (56 táctil + 24 canal)   │  312-392 (sin hairline: el horizonte es la única línea sobre las filas)
 392      │ fila-control 2                                       │  392-472
 472      │ fila-control 3                                       │  472-552
 552      ├──────────────────────────────────────────────────────┤  hairline trazo (fila editorial, 03 §4.7)
 552      │ Todas las capas · fila 56 ·          [y 2 más]       │  552-608
 608      │ (aire 32)                                            │  608-640
 640      ├──────────────────────────────────────────────────────┤  hairline
 640      │ Marea · fila 72 con subtítulo · toggle               │  640-712
 712      ├──────────────────────────────────────────────────────┤  hairline
 712      │ Temporizador · fila 56 · ajuste a la derecha         │  712-768
 769      │ ▌ Mezclas ▐      ( ▶ Disco 44 en 64 )      ▌ Noche ▐ │  769-818 barra (la barra trae su propia hairline en 17/18) · 818-852 home
          └──────────────────────────────────────────────────────┘
 x: margen 20 · columna 353 (20-373) · toggle 51 × 31 alineado a x 373 · valor de fila alineado a x 373
```

**Hairlines de la página: tres** (552, 640, 712), las de las tres filas editoriales (03 §4.7: hairline de margen a margen). Las filas-control no llevan hairline: el canal de 24 pt y la propia línea de nivel separan (03 §4.2 define `LevelRule` sin hairline). No hay hairline en 312 (el horizonte es la única línea entre el bloque de texto y las filas, y así se reconoce como firma), ni en 608 (el aire de 32 y la de 640 ya separan el grupo), ni en 768 (la barra `.bar` pone la suya en 769 en iOS 17/18; en 26 es vidrio). En reposo la página tiene **cuatro líneas horizontales** (horizonte + tres hairlines) además de las de nivel.

Con la Marea guiando, dentro de la banda reservada de 120 (176-296) aparecen las marcas hairline `texto3` en y 176 (pleamar) y 296 (bajamar; coincide con el borde inferior de la banda de 24) y la línea de agua recorre **184 ↔ 284** (100 pt; 8 pt de aire hasta la marca de pleamar y 12 hasta la de bajamar). La marca de pleamar cae dentro del renglón de la línea 2 (164-184), que no se usa mientras la Marea guía (el estado de la Marea vive en su fila). Nada de lo que hay debajo del horizonte se mueve nunca, y nada de lo de arriba tampoco: la banda está reservada desde que la mezcla tiene Marea disponible (03 §3.7, 04 §2.0.4). La nota de una vez nunca coexiste con la Marea (la nota vive en silencio; la Marea solo guía sonando).

**Anatomía de la fila-control (`LevelRule`, 03 §4.2)**, y0 = borde superior de la fila:

```
 y0+0    ┌───────────────────────────────────────────────────┐ ┐
 y0+12   │ Rosa · suave y equilibrado                    50  │ │  nombre paso 5 Semibold texto · " · " · subtítulo paso 7 texto2
 y0+34   │                                                   │ │  (misma línea base; 12 + 22 = 34) · valor paso 9 tabular texto2 a x 373
 y0+44   │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━───────────────│ │  línea de nivel: llena 2 pt texto (0 → nivel) + resto 1 pt texto3 (a 12 del borde táctil)
 y0+56   ├ · · · · · · · · · · · · · · · · · · · · · · · · · ┤ ┘ 56 táctiles (toda la fila es el control)
 y0+58   │ (canal muerto 24 · aquí viven el tip y "Seis a la vez") │ 24 de canal: ningún gesto arranca aquí (P8)
 y0+80   └───────────────────────────────────────────────────┘    límite de fila: ninguno dibujado
```

El nombre y el subtítulo van en un solo renglón porque es lo que permite 56 pt táctiles + 24 de canal real; en xL-xxxL, cuando no caben, `ViewThatFits` baja el subtítulo a un segundo renglón (fila 72 + 24 = 96) (§5d).

**Conjunto y orden de las filas-control (decisión E2; pregunta al dueño en §9 #11).** Las filas visibles son las capas con nivel > 0 de la mezcla cargada, **camas primero** (Lluvia, Viento, Ventilador, Océano, Trueno, Hoguera, Arroyo, Cabina) **y después colores** (Blanco, Rosa, Marrón), las tres primeras; Capas conserva su orden colores / camas (§2.7). Razón: lo que se baja a las 3 son las capas con eventos (lluvia, océano, trueno), no el ruido de fondo; con cuatro capas, lo que cae a "y 1 más" debe ser una cama de ruido. **El conjunto y el orden se fijan al cargar una mezcla y al cerrar Capas; durante la sesión no se recalculan.** Una fila arrastrada a 0 se queda en su renglón como fila a 0 (pista `texto3`, valor oculto) hasta la próxima carga, y se puede volver a subir desde la página. Rosa a 40 (03 §1.3) ocupa el primer renglón vacío; si no hay ninguno, no aparece en la página (suena, se ve en Capas, y "Sonando · rosa a 40" lo dice). **Tope de seis capas simultáneas** (C19, regla de modelo): la página nunca lo enseña como hueco; si una fila a 0 se arrastra hacia arriba con seis capas ya sonando, el nivel no sube y el canal de esa fila dice "Seis a la vez" 3 s (§2.6 caso 24). La principal no lleva fila de mezclas de la casa (C18) ni fila de nivel maestro (C51): el maestro es de sesión y se ajusta con el arrastre vertical de Noche (E4).

### 2.1 Página · reposo (pantalla 1)

```
 y        ┌────────────────────────────────────────────────┐
   0      │ 9:41                                  ▲ ▮▮▮ ▮  │
  64      │ prueba · quedan 5 noches                       │  paso 9 versalitas texto2 · botón → hoja Pro (solo fuera de NightWindow) · solo desde que la prueba empezó (C07)
 100      │ Esta noche                                     │  paso 2 texto · 28/34 · pulsación larga = menú contextual
 144      │ En silencio                                    │  paso 7 texto2
 164      │                                                │  línea 2 vacía
 196      │                                                │  nota de una vez: vacía (noches 1-6)
 272      │                                                │
 284      │ ────────────────────────────────────────────── │  hairline 0,5 trazo · quieta · el silencio dibujado · la única línea sobre las filas
 296      │                                                │
 324      │ Lluvia · sobre el tejado                   30  │  fila 1 (312-392) · cama primero
 356      │ ━━━━━━━━━━━━━━━━──────────────────────────────  │  2 pt texto al 30 % · 1 pt texto3
 404      │ Rosa · suave y equilibrado                 50  │  fila 2 (392-472)
 436      │ ━━━━━━━━━━━━━━━━━━━━━━━━━━──────────────────── │
 484      │                                                │  fila 3 vacía (solo dos capas > 0): ni línea ni hairline
 552      ├────────────────────────────────────────────────┤  hairline
 569      │ Todas las capas                                │  fila 56 · paso 5 · sin valor (solo "y 2 más" si desborda) · sin chevron
 640      ├────────────────────────────────────────────────┤  hairline
 652      │ Marea                                   ( ◯  ) │  paso 5 · toggle del sistema off, .tint(texto) (03 §4.12)
 680      │                                                │  subtítulo vacío: el toggle ya dice "apagada" (decisión E2 #9)
 712      ├────────────────────────────────────────────────┤  hairline
 729      │ Temporizador             Hasta dormirme · 45 min│  paso 5 · ajuste elegido, paso 7 texto2 a x 373 (45 min por defecto desde la primera noche, 07 §2.1.4)
 769      │   Mezclas            (  ▶  )            Noche  │  barra · 17 Medium texto · Disco 44 grafito, glifo 22 texto · hairline propia de la barra
 852      └────────────────────────────────────────────────┘
           píxeles encendidos: texto, dos líneas de nivel, tres hairlines, el horizonte y el Disco (< 6 % de la superficie) [a medir]
```

**Tabla de capas (reposo):**

| Elemento | Estilo | Color | Medidas (pt) | Comportamiento |
|---|---|---|---|---|
| Cabecera de prueba | 9 · versalitas | `texto2` | y 64-82; x 20; área táctil 52-96 a todo el ancho (solo fuera de `NightWindow`) | Texto según el momento (§2.11): `pro.prueba.estado` / `.ultima` / `.gratis`. **Aparece solo desde que la prueba empieza** (desde la hoja Pro con "Empezar la prueba · 7 noches", C07); antes, y con Pro, y tras 7 sesiones gratuitas (03 §1.2), vacía. Toque → hoja Pro (E5) **salvo dentro de `NightWindow` y en la página nocturna: entonces es texto, no botón (§2.10)**. Nunca se mueve: si está vacía, el renglón queda vacío. |
| Nombre de la mezcla | 2 | `texto` | y 100-134; x 20; una línea; `minimumScaleFactor(0.8)` **solo** en nombres escritos por el usuario, después truncado por el final; los nombres recortados no escalan | "Esta noche" ["Tonight"] mientras la mezcla no sea una guardada sin modificar (nombre de la mezcla viva, reconciliación §3, C39); nombre de la mezcla guardada si está cargada tal cual; "Mar y viento · sin Océano" (`mezcla.nombre.sin`) si está recortada (03 §1.3; también para las mezclas de la casa con Pro, C18); con dos o más capas que faltan, la lista con `pagina.capas.ni` ("Mar y viento · sin Océano ni trueno"), truncada por el final si no cabe (la línea de estado conserva los nombres; §9 pendiente de E7). **Toque de día: nada** (decisión E2, §9 #2: la barra ya entra en Mezclas; dos objetivos sin borde pegados, 52-96 y 96-140, no caben con 24 de aire, 03 §3.5). En la página nocturna, toque → página de día (03 §3.2, C40; §2.10). Pulsación larga → `contextMenu` del sistema: `mezcla.menu.guardar` "Guardar como mezcla…" / `comun.renombrar` "Renombrar" / `mezcla.menu.vaciar` "Vaciar" (E5, pantalla 13). |
| Línea de estado | 7 | `texto2` | y 144-164; x 20; una línea; a la derecha, alineada a x 373, la palabra de fase de la Marea cuando guía | Contenido por estado (§3). Cambia por opacidad 250 ms. Es `.staticText`; VoiceOver la anuncia solo cuando el cambio lo causó un toque (§5b). En error de audio es un botón de 44 pt de dos líneas (140-184; §2.12). |
| Línea 2 | 6 (`TextAction`, 17 Regular) o 7 | `texto2` | y 164-184; área táctil 44 (152-196) cuando es botón | Solo `ruta.seguir_altavoz` "Seguir por el altavoz" (60 s, C49; §2.4), `estado.volumen` "Sonando · al 40" tras reanudar por el altavoz (hasta el primer toque, C49/C51) o `diagnostico.enviar` "Enviar informe" la mañana siguiente a una caída nocturna (§2.12). Vacía el resto del tiempo. |
| Nota de una vez | 7 | `texto2` | y 196-256; 3 líneas máx.; **≤ 135 caracteres** (3 × ≈ 47 a Large); todo el bloque es un botón de 60 pt | Solo noche 7 (`prueba.ultima`) y noche 8 (`prueba.terminada`) (§2.11); solo en silencio. **La primera noche no hay nota: la prueba no arranca sola (C07).** Toque → se funde a vacío (250 ms); el renglón sigue vacío hasta la próxima apertura. También muere al primer Play. VoiceOver: "Entendido, botón" como acción (`comun.entendido`; sin botón visible, §9 #16). En el tercer fallo de audio el renglón lo ocupa `diagnostico.enviar` (§2.12). |
| Horizonte (`SoundLine`) | — | `trazo` (hairline 0,5) | banda y 272-296 (o 176-296 reservada si la mezcla tiene Marea disponible); línea en 284; x 20-373 | Quieto. No responde a nada en silencio (la pulsación larga de descomposición solo existe sonando). |
| Filas-control (hasta 3) | 5 + 7 + 9 | `texto` / `texto2` / `texto2`; línea `texto` 2 pt + `texto3` 1 pt | y 312-392 / 392-472 / 472-552; paso 80; texto en y0+12, línea en y0+44 | Conjunto y orden según §2.0 (camas primero; fijado al cargar y al cerrar Capas). Arrastre horizontal = nivel (§2.6, C52). Toque = nada (fila Pro sin acceso: toque → hoja Pro de día, C06). Pulsación larga = `Slider` del sistema (§2.5, C21). Renglones sobrantes: vacíos, sin línea ni hairline. |
| "Todas las capas" | 5 (+ 9 si desborda) | `texto`; valor `texto2` | y 552-608; fila 56; hairline en 552 | Sin valor y sin chevron (03 §3.6: cero iconos fuera de la barra; decisión E2 en §9 #1: la fila vive de su posición, de ser `Button` y de la versalita). Solo si suenan más capas de las que caben: `capas.mas` "y 2 más" ["and 2 more"] en paso 9 a x 373. Toque → hoja Capas (§2.7). Pulsado: fondo `grafito` 200 ms (C66: fila tocada = pista grafito). |
| Marea (fila) | 5 + 7 / 9 | `texto` / `texto2`; toggle `.tint(texto)` (03 §3.1 regla 2 y §4.12: nunca `índice`) | y 640-712; fila 72; hairline en 640; toggle 51 × 31 centrado en el renglón del nombre, borde derecho en x 373 | Título `marea.titulo` "Marea" ["Tide"] (C15). Toggle = encender/apagar; **encender arranca el sonido si no sonaba** (el instrumento siempre suena, 03 §1.3; 10 §2.1). Toque en el texto → hoja Marea (E3). Subtítulo por estado: vacío (apagada o armada con acceso: el toggle lo dice) / `marea.estado.apagada.pro` "Apagada · pro" (gratuito tras la prueba; 03 §4.7) / versalitas `marea.estado.guiando.corto` "guiando · 6 por minuto" + paso 7 `marea.retira.hora` "Se retira a las 23:27" (03 §4.3: dos claves, dos `Text`) / "guiando · 6 por minuto" + paso 7 `marea.oceano.subido` 4 s si la Marea subió Océano desde 0 (03 §1.3) / `marea.estado.disolviendo` "disolviendo" / `marea.retirada` "Se ha retirado. El mar sigue." (10 s). |
| Temporizador (fila) | 5 + 7 | `texto` / `texto2` | y 712-768; fila 56; hairline en 712; ajuste alineado a x 373, una línea; si no cabe a la derecha del nombre, `ViewThatFits` lo baja al segundo renglón (fila 56 → 72) también a Large | **Solo el ajuste elegido, nunca la cuenta**: `temporizador.apagado` "Apagado" / `temporizador.estado.dormirme` "Hasta dormirme · 45 min" / `temporizador.estado.manto` "Manto · hasta las 7:00". El temporizador es entero libre (C03): la palabra "pro" no aparece en la fila en ningún momento, tampoco en la noche 8. Siesta no existe en 1.0 (C30). La hora de apagado y el fundido viven en la línea de estado ("Sonando · se funde a las 0:42", "Sonando · fundiendo · 8 min"): nada en la fila late por minuto. Toque → hoja Temporizador (E4). |
| Barra inferior | 17 Medium + Disco | `texto`; Disco `grafito` + sombra interior 1 pt `negro` 60 %; glifo `texto` | y 769-818; "Mezclas" x 20-…, "Noche" …-373, Disco 44 en área 64 × 64 centrado en x 196,5 | `ToolbarItemGroup(.bottomBar)`; vidrio del sistema en iOS 26, material `.bar` + su hairline en 17/18 (único `#available(iOS 26)` del proyecto, en el Disco; C66). `barra.mezclas` "Mezclas" empuja; `barra.noche` "Noche" entra en Noche (E4). Disco = Play (03 §4.4). Sin tintes propios. |
| Hairlines | — | `trazo` | 0,5 pt (`1 / displayScale`); x 20-373 | En y 552, 640, 712. Decorativas; no transmiten estado. |

### 2.2 Página · sonando (pantalla 2)

```
 y        ┌────────────────────────────────────────────────┐
  64      │ prueba · quedan 5 noches                       │
 100      │ Esta noche                                     │
 144      │ Sonando · se funde a las 0:42                  │  paso 7 texto2 · la hora es un dato: tabular, formato corto del sistema
 272      │                                                │
 284      │ ═══════════════════════════════════════════════ │  ÍNDICE · 1,5 → 3 pt y opacidad 0,6 → 1,0 por RMS maestro
 296      │                                                │  (el ruido la deja casi quieta; lluvia y océano la hacen respirar)
 324      │ Lluvia · sobre el tejado                   30  │
 356      │ ━━━━━━━━━━━━━━━━──────────────────────────────  │  sin cambios: las filas no reaccionan al sonido (solo el horizonte)
 404      │ Rosa · suave y equilibrado                 50  │
 436      │ ━━━━━━━━━━━━━━━━━━━━━━━━━━──────────────────── │
 552      ├────────────────────────────────────────────────┤
 569      │ Todas las capas                                │
 640      ├────────────────────────────────────────────────┤
 652      │ Marea                                   ( ◯  ) │
 712      ├────────────────────────────────────────────────┤
 729      │ Temporizador             Hasta dormirme · 45 min│  el ajuste; no cambia mientras suena
 769      │   Mezclas            (  ❚❚ )            Noche  │  glifo pause.fill (.replace 200 ms)
 852      └────────────────────────────────────────────────┘
           un solo elemento de color en la pantalla: el horizonte (regla del Índice; el Toggle va en texto, 03 §3.1 regla 2)
```

**Lo que cambia respecto a 2.1** (solo contenido, grosor, opacidad; ninguna posición):

| Elemento | Reposo → sonando |
|---|---|
| Horizonte | Nace de la hairline hasta `índice` siguiendo **la ganancia maestra real** (envelope del `RenderState`), con la duración y la curva del motor: 800 ms `.easeOut` (03 §3.7; `SleepAudioEngine.defaultFadeIn` pasa de 1,5 s lineal a 0,8 s, 04 §0 (7) y §9 #27). Después, grosor **1,5 → 3 pt** y opacidad 0,6 → 1,0 según el RMS maestro (20 Hz, τ 500 ms) [spike I0-1]. Mapeo: m = RMS normalizado entre −40 dBFS (0) y −6 dBFS (1) [a medir con el medidor real]; grosor = 1,5 + 1,5 m; opacidad = 0,6 + 0,4 m. El mínimo de 1,5 pt es el que 03 §3.1 exige a cualquier línea en `índice` (4,71:1 bajo rojo); 03 §4.1 ya lo dice así (errata corregida en 03 §12). Nunca escribe, nunca se desplaza. |
| Línea de estado | `pagina.estado.sonando` "Sonando" ["Playing"]; con Hasta dormirme `pagina.estado.sonando.funde` "Sonando · se funde a las 0:42" ["Playing · fades at 12:42 AM"]; Manto: `pagina.estado.sonando.hasta` "Sonando · hasta las 7:00" ["Playing · until 7:00 AM"]; mezcla recortada: `pagina.estado.sonando.sin` "Sonando · sin trueno" ["Playing · without thunder"]; mezcla toda Pro o vacía: `pagina.estado.sonando.defecto` "Sonando · rosa a 40" ["Playing · pink at 40"] (03 §1.3: el instrumento siempre suena); ruta externa (AirPlay, altavoz; C41): `estado.ruta` "Sonando · en Dormitorio" ["Playing · on Bedroom"]. |
| Fila Temporizador | Sin cambio: "Hasta dormirme · 45 min". La cuenta no está en la página (está en la línea de estado como hora, y en Noche y la Live Activity como cuenta). |
| Disco | `play.fill` → `pause.fill` con `.contentTransition(.symbolEffect(.replace))` 200 ms, **solo cuando `engine.start` ha devuelto sin error** (§2.12). Háptica `.impact(.medium, 0.7)` al inicio del fundido. |
| Rosa a 40 | Si ninguna capa accesible está > 0 al tocar Play, Rosa sube a 40 como nivel real y el nombre no cambia (no es una edición del usuario). Su fila ocupa el primer renglón vacío; si no hay ninguno, no aparece (§2.0). |
| Mezcla toda Pro sin acceso, en reposo | La línea de estado dice `pagina.estado.silencio.pro` "En silencio · esta mezcla es Pro" ["Silent · this mix is Pro"]; al tocar Play, "Sonando · rosa a 40". Nunca abre nada (P9). |

### 2.3 Página · con Marea guiando (pantalla 2)

```
 y        ┌────────────────────────────────────────────────┐
  64      │ prueba · quedan 5 noches                       │
 100      │ Mar y viento                                   │
 144      │ Sonando · se funde a las 0:42           inhala │  palabra de fase paso 7 texto2 a x 373 (3 primeras respiraciones)
 164      │                                                │  línea 2 vacía (la marca de pleamar cae en este renglón)
 176      │ · · · · · · · · · · · · · · · · · · · · · · · ·│  marca pleamar · hairline texto3
 184      │                                                │  ┐
          │                                                │  │ recorrido de la LÍNEA DE AGUA (184 ↔ 284)
 236      │ ═══════════════════════════════════════════════ │  │ 2 pt índice · sube 4 s · baja 6 s · BreathCurve del motor (dibujada a media banda; Reduce Motion la deja aquí)
          │                                                │  │
 284      │                                                │  ┘ bajamar = horizonte (la hairline de la que nació)
 296      │ · · · · · · · · · · · · · · · · · · · · · · · ·│  marca bajamar · hairline texto3
 324      │ Océano · oleaje lento                      50  │  nada de aquí abajo se ha movido (ni nada de arriba: la banda estaba reservada)
 356      │ ━━━━━━━━━━━━━━━━━━━━━━━━━━──────────────────── │
 404      │ Viento · entre árboles                     20  │
 552      ├────────────────────────────────────────────────┤
 569      │ Todas las capas                                │
 640      ├────────────────────────────────────────────────┤
 652      │ Marea                                   ( ● )  │  toggle on · .tint(texto): se lee por la posición del pomo (P7); el único índice es la línea de agua
 680      │ guiando · 6 por minuto  Se retira a las 23:27  │  versalitas paso 9 texto2 (marea.estado.guiando.corto) + paso 7 texto2 (marea.retira.hora), dos Text
 712      ├────────────────────────────────────────────────┤
 729      │ Temporizador             Hasta dormirme · 45 min│
 769      │   Mezclas            (  ❚❚ )            Noche  │
 852      └────────────────────────────────────────────────┘
```

| Elemento | Con Marea |
|---|---|
| Banda | Reservada de 120 pt (176-296) desde que la mezcla cargada tiene Marea disponible; **no crece** (03 §3.5, §4.1; 04 §2.0.4). Al empezar la guía aparecen por opacidad, en 800 ms `.easeInOut`, las marcas hairline `texto3` en 176 y 296 y la línea de agua. Reduce Motion: 250 ms. |
| Línea de agua (`TideLine`) | 2 pt `índice` (el horizonte "es" la línea de agua, no hay dos). `BreathCurve` del motor con `guide.anchor` + `outputLatency`; 4:6; 7,5-15 s por ciclo. Reutiliza el `TimelineView` a 30 Hz pausable del `BreathIndicator` actual (03 §3.7). Bajo un dedo que arrastra un nivel, pasa a `texto` mientras dure el gesto. Reduce Motion: fija en y 236 (media banda), opacidad 0,6 → 1,0 con la misma curva. Con Descenso activo (C24, E3) la versalita empieza en "guiando · 12 por minuto" y baja hasta 6; la línea de agua sigue la curva real. |
| Palabra de fase | `marea.fase.inhala` "inhala" / `marea.fase.exhala` "exhala" ["breathe in" / "breathe out"], paso 7 `texto2`, alineada a x 373 en el renglón del estado; fundido 250 ms al cambiar; desaparece (500 ms) en la tercera exhalación y no vuelve. Oculta a VoiceOver (el valor del horizonte ya la dice si la persona activó la voz de guía, E3). |
| Fila Marea | Subtítulo: versalitas "guiando · 6 por minuto" ["guiding · 6 per minute"] y, en paso 7, "Se retira a las 23:27" ["Recedes at 11:27 PM"] (03 §4.3 y §3.4: la hora nunca en versalitas). Si la Marea subió Océano desde 0 (03 §1.3), los primeros 4 s el paso 7 dice `marea.oceano.subido` "Océano subido a 40 para oír la marea." ["Ocean raised to 40 so you can hear the tide."] y después pasa a la hora. "disolviendo" ["dissolving"] en el último 20 % (E3 fija los minutos); al terminar, 2 s en bajamar y las marcas y la línea de agua se funden a la hairline en 800 ms; subtítulo 10 s "Se ha retirado. El mar sigue." ["It has receded. The sea goes on."]; después **el toggle sigue en on** (es un ajuste, no un estado: `settings.isEnabled` persiste en `main` y la Marea volverá al próximo Play) y el subtítulo queda vacío (armada: el toggle lo dice; §9 pendiente de E7 si E3 quiere una cadena de "armada"). |
| Pausa con Marea | La Marea se retira con el sonido (`endPlayback` → `breathing.end()` en `main`): la línea de agua y las marcas se funden a la hairline en 2 s junto con el horizonte. Al reanudar con el Disco, `play(userInitiated:)` llama a `begin()`: ventana nueva de 15 min desde una inhalación. Solo la reanudación por el sistema (`play(userInitiated: false)`) conserva la ventana (`resume()`). Si E3 quiere conservarla también tras una pausa corta, es un cambio a `MixerModel.play` (§9 #31). |
| Gratuito tras la prueba | El toggle **no se enciende** (vuelve a off al soltarlo) y la banda es de 24 (no hay Marea disponible). De día (fuera de `NightWindow`) sube la hoja Pro con "Empezar la prueba · 7 noches" / "Comprar" (C06); si compra, el toggle pasa a on y la Marea guía. **Dentro de `NightWindow` o en la página nocturna no pasa nada más** (C08): el toggle vuelve a off y el subtítulo sigue en "Apagada · pro". Sin escucha de 30 s en 1.0 (C06). |

### 2.4 Página · en pausa y fundiendo (pantalla 2)

```
 EN PAUSA · AURICULARES                                       FUNDIENDO
 y        ┌──────────────────────────────────────┐    y        ┌──────────────────────────────────────┐
 144      │ En pausa · auriculares               │    144      │ Sonando · fundiendo · 8 min          │
 164      │ Seguir por el altavoz                │    164      │                                      │
 284      │ ──────────────────────────────────── │    284      │ ═════════════════════════════════════│ grosor y opacidad bajan con la
 324      │ Lluvia · sobre el tejado         30  │    324      │ Lluvia · sobre el tejado         30  │ ganancia real hasta la hairline
 356      │ ━━━━━━━━━━━━━━━━──────────────────── │    356      │ ━━━━━━━━━━━━━━━━──────────────────── │ (las filas no cambian: el nivel
 729      │ Temporizador  Hasta dormirme · 45 min│    729      │ Temporizador  Hasta dormirme · 45 min│  guardado sigue siendo 30)
 769      │  Mezclas        ( ▶ )         Noche  │    769      │  Mezclas        ( ❚❚ )        Noche  │ pause.fill con .pulse (off con RM y de noche)
```

| Estado | Horizonte | Línea de estado | Línea 2 | Temporizador | Disco |
|---|---|---|---|---|---|
| **En pausa** (toque en el Disco) | `índice` → hairline `trazo` en 2 s `.easeInOut` (1,5 s al parar el motor + el color se va: ley color = sonido) | `pagina.estado.pausa` "En pausa" ["Paused"] | vacía | "Hasta dormirme · 45 min" (el ajuste; `timer.pause()` conserva `remaining`, que se ve en Noche y la Live Activity) | `play.fill`; háptica `.impact(.light, 0.5)` |
| **En pausa · llamada** (`interruptionNotification .began` **y** `CXCallObserver` confirma una llamada activa; C48) | hairline en 300 ms (el sistema ya tomó la salida) | `pagina.estado.pausa.llamada` "En pausa · llamada" ["Paused · call"] | vacía | sin cambio | `play.fill`; sin háptica |
| **En pausa** por el sistema (`interruptionNotification .began` sin llamada confirmada: alarma, Siri, otra app; iOS no comunica la causa y la línea no la inventa) | hairline en 300 ms | "En pausa" (la misma clave: 10 no distingue causas que el sistema no da) | vacía | sin cambio | `play.fill`; sin háptica |
| **En pausa · auriculares** (`routeChangeNotification .oldDeviceUnavailable`: caída de ruta = fundido de 40 ms y pausa, C49) | hairline en 2 s (audio 40 ms) | `estado.pausa.auriculares` "En pausa · auriculares" ["Paused · headphones"] | `TextAction` `ruta.seguir_altavoz` "Seguir por el altavoz" ["Keep playing on speaker"] **durante 60 s** (C49); después vacía: el Disco sigue reanudando | sin cambio | `play.fill` |
| **En pausa · AirPods** (`pauseCommand` con auriculares puestos = fundido de 3 s, C49; iOS 26 pausa al dormirse) | hairline en 3 s | `pagina.estado.pausa.airpods` "En pausa · AirPods" ["Paused · AirPods"] **si el comando llega con auriculares como ruta activa**; si no se distingue de otro `pauseCommand`, "En pausa" [a medir] | vacía (no se ofrece reanudar: los AirPods han decidido; nunca reanuda sola por el altavoz) | sin cambio | `play.fill` |
| **En pausa · se interrumpió el sonido** (`mediaServicesWereReset` sin reanudación) | hairline en 300 ms | `pagina.estado.pausa.interrumpido` "En pausa · se interrumpió el sonido" ["Paused · the sound was interrupted"] | vacía; un toque en el Disco reintenta | sin cambio | `play.fill` |
| **Fundiendo** (`timer.isFading`: fundido de ganancia de 10–15 min con cuenta entera, C31) | grosor y opacidad siguen la ganancia real hasta la hairline; el color se va con el último 10 % de ganancia | `pagina.estado.fundiendo` "Sonando · fundiendo · 8 min" ["Playing · fading · 8 min"] (minutos que faltan; cambia en seco por minuto) | vacía | sin cambio | `pause.fill` con `symbolEffect(.pulse)` (apagado con Reduce Motion y en la página nocturna) |
| **Terminada** (tras el fin del temporizador, los 20 min en pausa o una interrupción en la ventana de la mañana; hasta el próximo Play) | hairline | "En silencio" (10 §3: la sesión terminada vuelve al reposo; la hora del fundido vive en la Live Activity terminada, E6; §9 pendiente de E7: "Se fundió a las 0:42") | vacía | sin cambio | `play.fill`; ninguna háptica, ningún sonido, ningún anuncio de VoiceOver (la persona duerme) |
| **Reanudación por el altavoz tras `oldDeviceUnavailable`** (C49, C51) | nace de la hairline con la ganancia | "Sonando · …" (la que toque) | `estado.volumen` "Sonando · al 40" ["Playing · at 40"] hasta el primer toque: el maestro de sesión (`master` con rampa en `EngineCommand`) queda capado a 0,4 **solo si la ruta cambió** | sin cambio | `pause.fill` |

Regla: en todas las pausas **las filas no cambian**. El nivel guardado es el nivel; lo que ha dejado de sonar es el motor, y eso lo dice el horizonte (hairline) y la palabra. Nada rojo, nada modal, nada que vibre fuera del toque voluntario en el Disco.

**Altavoz (C49; 03 §1.3: nunca reanudar por el altavoz por encima de 40).** Tras `oldDeviceUnavailable`, nada reanuda solo por el altavoz; **cualquier** reanudación por el altavoz (Disco, "Seguir por el altavoz", Magic Tap, Live Activity, Centro de control) acota el maestro de sesión a 0,4 y la línea 2 dice "Sonando · al 40" hasta el primer toque; al volver a conectar auriculares, el maestro vuelve a 1,0 en 800 ms. El maestro nunca toca el volumen del sistema y no persiste (C51). "Seguir por el altavoz" (60 s) y el Disco hacen lo mismo: la línea 2 existe porque se lee (03 §1.2), el Disco porque se encuentra a ciegas.

### 2.5 Página · fila bajo el dedo y pulsación larga

```
 BAJO EL DEDO (arrastre relativo)                                 PULSACIÓN LARGA (alternativa sin gesto)
 y0+0   ┌──────────────────────────────────────────────┐          ┌──────────────────────────────────────────────┐
 y0+6   │▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│ pista    │ Lluvia · sobre el tejado                  38  │ nombre texto3 mientras dure
 y0+12  │▒Lluvia · sobre el tejado▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒38▒▒│ grafito  │                                              │
 y0+44  │▒━━━━━━━━━━━━━━━━━━━━━━━▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│ 44 pt    │ ────────────●──────────────────────────────  │ Slider del sistema 44 pt, .tint(texto), pista texto3
 y0+50  │▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│          │                                              │ sustituye a la línea en su sitio (y0+6..y0+50)
 y0+56  ├ · · · · · · · · · · · · · · · · · · · · · · · ┤          ├ · · · · · · · · · · · · · · · · · · · · · · ·┤
 y0+80  └──────────────────────────────────────────────┘          └──────────────────────────────────────────────┘
         línea 3 pt índice (índice-noche de noche) · valor crece a 17 Medium texto tabular EN SU SITIO (x 373), nunca bajo el dedo
```

| Elemento | Bajo el dedo | Al soltar |
|---|---|---|
| Pista | Rectángulo `grafito` de 44 pt (y0+6..y0+50, x 20-373), radio 0; aparece en 150 ms `.easeInOut`. Es el único relleno transitorio del sistema (03 §1.1, §3.5, §4.2; C66) y dura lo que el gesto; de noche no se ve a brillo mínimo (1,25:1) y no informa: la línea de 3 pt y el valor de 17 lo hacen. | Desaparece en 250 ms. |
| Línea de nivel | 3 pt `índice` hasta el nivel; resto 1 pt `texto3`. De noche `índice-noche`. (En papel, 1.1, `ocre`.) | Vuelve a 2 pt `texto` en 250 ms. |
| Valor | 13 → 17 pt `texto` tabular (17 Medium, `relativeTo: .body`), alineado a x 373. Entero 0-100. | 17 → 13 pt `texto2`; oculto si 0. |
| Horizonte | Pasa a `texto` mientras dura el gesto (un índice por pantalla; la línea de agua también). | Vuelve a `índice` en 250 ms. |
| Audio | El nivel sigue al dedo sin escalones (`engine.updateGains` por fotograma del gesto; el motor interpola). | — |
| Háptica | `.selection` al cruzar 0 (en los dos sentidos); `.impact(.light, 0.6)` al llegar a 100; nada en pasos intermedios. **Puerta por fase (C35, `MotionGate.allows(phase) = !phase.isNight`)**: en la página nocturna nunca; sin CoreMotion en 1.0. | — |
| Pulsación larga (**0,6 s** sin recorrer 10 pt; `Grid.longPress`, 03 §4.2 y 04 §2.0.3: una sola duración para fila, horizonte y Noche) | El nombre y el subtítulo pasan a `texto3`; la línea de nivel y el valor se ocultan; un `Slider` del sistema de 44 pt con **`.tint(texto)`** (`texto-noche` de noche) y pista vacía `texto3` **sustituye a la línea en su sitio** (03 §4.2 consolidado; nada cambia de posición, 03 §3.7), con el mismo valor (C21: ajuste fino y accesibilidad; etiqueta `capas.deslizador` "Nivel de Lluvia"). Sin índice: es la alternativa sin gesto, no "lo vivo", y queda 5 s sin dedo encima (03 §3.1 regla 1: color solo con sonido o dedo); el horizonte no cambia. Es la alternativa de Button Shapes y de Control por botón. **Si antes de soltar el dedo recorre 8 pt a \|α\| ≤ 30°, el Slider se cancela (150 ms) y el gesto sigue como nivel relativo desde el nivel actual.** Se cierra al tocar fuera; con el dedo, también 5 s después del último cambio. Con VoiceOver, Switch Control o Control por voz activos (`UIAccessibility.isVoiceOverRunning` / `isSwitchControlRunning`) **no hay cierre automático**: se cierra al mover el foco fuera de la fila o con el gesto de escape (no hay acción "Cerrar": la palabra está en la lista negra de 10 §0.5 para botones). **Nada más** (el timbre no es un gesto: es la fila "Timbre" al pie de Capas, C29). | La fila vuelve en 250 ms. |
| Fila Pro (gratuito tras la prueba) | El arrastre no mueve nada (la línea queda en pista `texto3`). Pulsación larga: nada. Toque: hoja Pro fuera de `NightWindow` (§2.8). | — |

### 2.6 Geometría del arrastre relativo (03 §4.2: relativo, 8 pt, 30°, canal 24; C52) [spike I0-2]

Reglas: **(1)** `DragGesture(minimumDistance: 8)` sobre el área táctil de la fila (y0..y0+56, x 0-393: el margen también coge). **(2)** Al cumplirse los 8 pt se mide el ángulo del desplazamiento respecto a la horizontal: \|α\| ≤ 30° → **eje bloqueado en horizontal**, la fila posee el gesto y el `ScrollView` lo rechaza; \|α\| > 30° → el gesto es del `ScrollView` (o del cierre de la hoja) y la fila no cambia nunca. El bloqueo dura hasta levantar el dedo. La página es siempre `ScrollView` (§2.0), así que la regla es la misma en la página y en Capas en todos los tramos. **(3)** El arrastre es **relativo**: nivel = nivel inicial + Δx / 333 × 100 (1 pt = 1/333 del recorrido; 333 = 353 − 20 de reserva; 1/315 en 375), redondeado a entero al soltar; la posición absoluta del dedo no importa, así se puede coger la fila por el nombre a oscuras sin "saltar" al punto tocado. **(4)** Sin inercia, sin aceleración, sin detentes intermedios. **(5)** Tope sin deuda: pasado 100 o 0 no se acumula recorrido; al volver, el nivel cambia desde el primer pt. **(6)** Un solo dedo; el segundo dedo cancela nada y no se interpreta. **(7)** El canal de 24 pt (y0+56..y0+80) no pertenece a ninguna fila: un gesto que empieza ahí es scroll. **(8)** Toque (< 8 pt de recorrido y < 0,6 s) = nada. **(9)** 0,6 s sin recorrer 10 pt = pulsación larga (§2.5). **(10)** Si tras la pulsación larga, sin soltar, el dedo recorre 8 pt a \|α\| ≤ 30°, el `Slider` se cancela y manda el nivel (§2.5). **(11)** Tope de seis a la vez (C19): si la fila está a 0 y ya suenan seis capas, el arrastre hacia la derecha no sube el nivel; el canal de la fila dice `capas.tope` "Seis a la vez" 3 s (paso 7 `texto2`, el mismo sitio del tip) y no hay háptica (no se cruza 0). El vertical es scroll aquí y maestro en Noche (C52): el gesto de timbre no existe.

```
          ángulo medido al cumplirse 8 pt de recorrido
                     ╲  30°  │  30°  ╱
             scroll   ╲      │      ╱   scroll
                       ╲     │     ╱
   ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─●─ ─ ─ ─ ─ ─ ─ ─ ─ ─   eje horizontal → NIVEL (|α| ≤ 30°)
                       ╱     │     ╲
             scroll   ╱      │      ╲   scroll
                     ╱       │       ╲
   fila (56 táctiles) ────────────────────────────────
   canal (24)         · · · · · · · · · · · · · · · ·  ← ningún gesto nace aquí
```

**Tabla de casos:**

| # | Gesto | Dónde empieza | Resultado | Háptica / anuncio |
|---|---|---|---|---|
| 1 | Toque y soltar sin recorrer 8 pt | fila | Nada (03 §1.2: el toque no silencia) | ninguna |
| 2 | 8 pt a \|α\| ≤ 30° | fila | Eje horizontal; el nivel sigue a Δx; pista, 3 pt `índice`, valor 17 | `.selection` solo si cruza 0; `.impact(.light, 0.6)` al llegar a 100; VoiceOver no participa (es gesto directo) |
| 3 | 8 pt a \|α\| > 30° | fila | Scroll de la página / hoja; la fila no cambia; tampoco cambia si después el dedo se endereza | ninguna |
| 4 | 8 pt a \|α\| = 30° exactos | fila | Scroll (en el empate gana lo que se deshace sin coste) | ninguna |
| 5 | Empieza horizontal y deriva a vertical | fila | Sigue siendo nivel hasta soltar (el bloqueo no se revisa) | según nivel |
| 6 | Arrastre a la derecha más allá de 100 | fila | 100; sin acumulación; al volver a la izquierda baja desde el primer pt | `.impact(.light, 0.6)` una vez al llegar |
| 7 | Arrastre a la izquierda más allá de 0 | fila | 0; la línea queda vacía y el valor se oculta; sin acumulación; la fila conserva su renglón (§2.0) | `.selection` una vez al cruzar |
| 8 | Dedo empieza en el canal (y0+56..80) | canal | Scroll; ninguna fila lo posee | ninguna |
| 9 | Dedo empieza sobre el valor o el nombre | fila | Igual que 2 (toda la fila es el control) | según nivel |
| 10 | Dedo empieza en el límite de fila (y0+80) | límite | Pertenece al canal | ninguna |
| 11 | Segundo dedo durante el arrastre | — | Ignorado; el primero manda | ninguna |
| 12 | Arrastre rápido (flick) | fila | Solo cuenta el desplazamiento; la velocidad no añade nada | según nivel |
| 13 | Arrastre con la Marea guiando | fila | Igual; la línea de agua pasa a `texto` mientras dure | según nivel |
| 14 | Arrastre en la página nocturna | fila | Igual; línea `índice-noche`, valor `texto-noche` | ninguna (puerta por fase, C35) |
| 15 | Arrastre en fila Pro (gratuito tras la prueba) | fila Pro | Nada se mueve (la línea queda `texto3`); al soltar, nada | ninguna |
| 16 | Toque en fila Pro (gratuito) | fila Pro | Fuera de `NightWindow`: hoja Pro ("Empezar la prueba · 7 noches" / "Comprar", C06); dentro de `NightWindow` o en la página nocturna: nada (C08). Sin escucha de 30 s (1.1) | ninguna (ni al abrir la hoja) |
| 17 | 0,6 s quieto (≤ 10 pt) | fila | `Slider` del sistema en la fila (§2.5) | ninguna |
| 18 | Arrastre desde el borde izquierdo de la pantalla (x < 20) | fila | Igual que 2: la página es raíz (sin gesto de volver) y Capas es hoja (su cierre es vertical). Por eso Capas no es pantalla empujada (03 §4.10) | según nivel |
| 19 | Arrastre vertical en la hoja Capas desde la primera fila con el scroll arriba | fila | Cierre interactivo de la hoja (del sistema): el nivel no cambia | ninguna |
| 20 | VoiceOver activo | fila | El `DragGesture` no recibe nada; la fila es `.adjustable` (§5b) | valor hablado |
| 21 | Switch Control / Control por voz | fila | Acciones "Subir", "Bajar", "Silenciar", "Máximo"; o el `Slider` por pulsación larga (sin cierre automático) | valor hablado |
| 22 | Arrastre con el motor caído (error de audio) | fila | El nivel cambia y se guarda (es un ajuste, no una reproducción); no suena nada | según nivel |
| 23 | Quieto 0,6 s y luego arrastre horizontal sin soltar | fila | Se cancela el `Slider` (150 ms) y manda el nivel, relativo desde el nivel actual | según nivel |
| 24 | Arrastre a la derecha en una fila a 0 con seis capas sonando (C19) | fila | El nivel se queda en 0; "Seis a la vez" en el canal 3 s; la capa no se añade | ninguna; VoiceOver lee "Seis a la vez" al aparecer (lo causó el gesto) |

Prueba de aceptación del spike I0-2: en dispositivo, con la hoja Capas desplazada a media lista **y con la página en xxxLarge** (también `ScrollView`), 20 arrastres horizontales deliberados y 20 scrolls verticales deliberados por tres personas: ≥ 95 % de los gestos van al destino que la persona quería; ningún nivel cambia durante un scroll. 04 §2.2 propone hasta el spike un umbral distinto en la página nocturna (16 pt, cono de 20°); E2 mantiene una sola regla y lo lleva al spike (§9 #21).

### 2.7 Capas · once texturas (pantalla 5, 1.0)

Hoja `.large` del sistema sobre la página (03 §4.10): **`presentationBackground(negro)`**, la única hoja sobre `negro`, con hairlines `trazo` (03 §3.1 y §4.10 consolidados; resuelve §9 #4: comparte fondo con la página porque hace lo mismo que la página; una hoja gris encendería toda la pantalla, P3; la hoja se reconoce por la esquina, el indicador del sistema y el título, no por un relleno). Indicador real, sin botón Cerrar, cabecera paso 3 a la izquierda + hairline `trazo`. Dentro, un `NavigationStack` con su propia barra inferior **idéntica a la de la página** (Mezclas · Disco · Noche), porque nada bloquea el sonido y el Disco está siempre a la vista (03 §4.11). Coordenadas desde el borde superior de la hoja (en 852 la hoja empieza en y ≈ 54 y mide ≈ 798 **[a medir: la altura del detent `.large` y su borde varían por dispositivo e iOS; en 26 cambian el radio y el inset]**; su barra ocupa los últimos 83). **Once texturas en 1.0** (PR-A; C19): la lista desplaza (11 × 80 + encabezados + Timbre + notas ≈ 1 220 pt); la barra permanece; el scroll convive con el arrastre por el bloqueo de eje (§2.6). Sin ranuras ni huecos: la interfaz no enseña el tope de seis (C19).

```
 y (hoja) ┌────────────────────────────────────────────────┐  fondo negro · esquina del sistema
   5      │                    ▬▬▬▬                        │  indicador de arrastre del sistema
  24      │ Capas                                          │  paso 3 Semibold 22/28 texto · x 20
  64      ├────────────────────────────────────────────────┤  hairline trazo
  80      │ colores                                        │  paso 9 versalitas texto2 (encabezado de sección)
 116      │ Blanco · siseo parejo                          │  fila 104-184 · nivel 0: solo pista 1 pt texto3, valor oculto
 148      │ ───────────────────────────────────────────────│
 196      │ Rosa · suave y equilibrado                 50  │  fila 184-264
 228      │ ━━━━━━━━━━━━━━━━━━━━━━━━━━──────────────────── │
 276      │ Marrón · retumbo grave                         │  fila 264-344 · a 0
 308      │ ───────────────────────────────────────────────│
 376      │ camas                                          │  (32 de aire) encabezado de sección
 412      │ Lluvia · sobre el tejado                   30  │  fila 400-480 · libre
 444      │ ━━━━━━━━━━━━━━━━──────────────────────────────  │
 492      │ Viento · entre árboles                         │  fila 480-560 · libre (C04) · a 0
 524      │ ───────────────────────────────────────────────│
 572      │ Ventilador · ventilador lejano                 │  fila 560-640 · Pro (en prueba / Pro: normal) · a 0
 652      │ Océano · oleaje lento                          │  fila 640-720 · Pro
 732      │ Trueno · lejano, sin rayos cerca               │  fila 720-800 · Pro
 812      │ Hoguera · brasas, sin chasquidos               │  fila 800-880 · Pro
 892      │ Arroyo · agua sobre piedras                    │  fila 880-960 · Pro
 972      │ Cabina · avión en crucero                      │  fila 960-1040 · Pro
1044      ├────────────────────────────────────────────────┤  hairline trazo
1060      │ Timbre                                         │  fila 1048-1128 · LevelRule del bus maestro (C29) [spike I0-7]
1092      │ ───────────────────────●───────────────────────│  línea bipolar: llena 2 pt texto del centro al punto; resto 1 pt texto3
1156      │ Se mezclan en tu iPhone mientras suenan.       │  paso 7 texto2 · 3 líneas (1144-1204)
1176      │ Nada se repite.                                │
1196      │ Lo que está a cero no suena ni gasta.          │  capas.cero [a verificar con I0-1]
1220      │ (fin del contenido · +83 de barra)             │
 715      │   Mezclas            (  ▶  )            Noche  │  barra de la hoja fija (715-764 en la hoja) · home 764-798
 798      └────────────────────────────────────────────────┘
           desplaza en todos los tamaños · sin hairlines entre filas: separan el canal y las líneas de nivel · candados: 0 · cápsulas: 0
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Cabecera "Capas" | 3 | `texto` | y 24-52; x 20 | `capas.titulo`. Texto fijo. Es el título de la hoja, no de la app. |
| Encabezados "colores" / "camas" | 9 · versalitas | `texto2` | y 80-98 y 376-394; x 20; 32 pt de aire antes de "camas" | `capas.seccion.colores` / `capas.seccion.camas`; `.header` para VoiceOver. "camas" ["beds"] viene del PR #3 y es exacto. |
| Fila de capa × 11 | 5 + 7 + 9 | como §2.0 | paso 80: 104, 184, 264 / 400, 480, 560, 640, 720, 800, 880, 960; texto en y0+12 | Orden fijo: Blanco, Rosa, Marrón / Lluvia, Viento (libres) y después las Pro en el orden de `SoundID.allCases` (Ventilador, Océano, Trueno, Hoguera, Arroyo, Cabina): decisión E2, las dos camas libres primero (§9 #26 pide a PR-A ese orden en `allCases`). Nombres `sound.{id}`, subtítulos `capas.{id}.detalle` (10 §5e.4). Comportamiento §2.5-2.6. Al cerrar la hoja se recalculan el conjunto y el orden de las filas de la página (§2.0). Tope de seis (C19): §2.6 caso 24. |
| Fila "Timbre" (C29) | 5 + 9 | `texto` / `texto2`; línea `texto` 2 pt + `texto3` 1 pt | fila 1048-1128 tras una hairline `trazo` en 1044; texto en 1060, línea en 1092 | `LevelRule` sobre el **bus maestro** (DSP de tilt; 1.0 condicionada al spike I0-7, puerta semana 4–6: si no llega, la fila cae a 1.1 sin cambiar nada más). Nombre `capas.timbre` "Timbre" ["Tone"], sin subtítulo. Línea **bipolar**: punto neutro en el centro (x 196,5); la parte llena va del centro hacia el extremo elegido; por defecto en el centro. En el sitio del valor, paso 9 `texto2`, el extremo hacia el que se inclina: `capas.timbre.grave` "Grave" ["Deep"] a la izquierda del centro, `capas.timbre.lejos` "Lejos" ["Far"] a la derecha; vacío en el centro (decisión E2, §9 #6: 10 dibuja los dos extremos flanqueando la línea; 03 §4.2 fija la línea de margen a margen, así que la palabra ocupa el sitio del valor). Bajo el dedo: pista `grafito`, línea 3 pt `índice`, la palabra crece a 17 Medium `texto`. Pulsación larga: `Slider` del sistema con rango −100…100. Nunca "pro": el timbre es libre (reconciliación §4). Timbre por capa: 1.1. |
| Notas | 7 | `texto2` | y 1144-1204; x 20; 3 líneas | `capas.nota` "Se mezclan en tu iPhone mientras suenan. Nada se repite." ["Mixed on your iPhone as they play. Nothing loops."] + `capas.cero` "Lo que está a cero no suena ni gasta." ["What's at zero makes no sound and costs nothing."] (injerto de 03 §1.3; **[a verificar con I0-1: bypass real de las capas a 0 en el render; si no, la variante corta de 10]**). Fijas. Paso 7 y no 8: un estilo menos en la hoja (5 en total; decisión E2, §9 #5). |
| Barra de la hoja | igual que la página | igual | y 715-764 | "Mezclas" cierra la hoja y empuja Mezclas; "Noche" cierra la hoja y entra en Noche; Disco = Play. |
| Hairlines | — | `trazo` | 0,5 pt; x 20-373 | Bajo la cabecera (y 64) y antes de "Timbre" (y 1044). "colores" / "camas" se separan con 32 pt de aire y la versalita. |
| Página nocturna (§2.10) | igual | `texto-noche` para todo el texto; pistas `texto3`; nivel bajo el dedo `índice-noche`; `Slider` `.tint(texto-noche)` | igual | Capas hereda la tinta de la página que la abre; sin cambio de posición. |

### 2.8 Capas · estados Pro (gratuito tras la prueba) y tope de seis

Usuario gratuito tras la prueba, con "Trueno 30" en la mezcla guardada (la degradación no escribió nada, C23):

```
 y (hoja) ┌────────────────────────────────────────────────┐
  24      │ Capas                                          │
  80      │ colores                                        │
 104-344  │ Blanco · siseo parejo / Rosa 50 / Marrón        │  igual que 2.7
 376      │ camas                                          │
 412      │ Lluvia · sobre el tejado                   30  │
 492      │ Viento · entre árboles                     20  │  libre (C04)
 572      │ Ventilador · ventilador lejano            pro  │  nombre texto2 · pista completa texto3 · "pro" versalitas texto2 a x 373
 652      │ Océano · oleaje lento                     pro  │
 732      │ Trueno · lejano, sin rayos cerca     pro · 30  │  conserva el nivel guardado: "pro · 30" (C23)
 812      │ Hoguera · brasas, sin chasquidos          pro  │
 892      │ Arroyo · agua sobre piedras               pro  │
 972      │ Cabina · avión en crucero                 pro  │
1060      │ Timbre                                         │  libre: sin "pro"
          └────────────────────────────────────────────────┘
           candados: 0 · cápsulas: 0 · palabras "pro": una por capa Pro (nunca se cuentan: C04), en versalitas texto2
```

| Estado de fila (03 §4.2) | Nombre | Subtítulo | Línea | Valor / palabra | Toque | Arrastre |
|---|---|---|---|---|---|---|
| Normal, nivel > 0 | `texto` | `texto2` | 2 pt `texto` + 1 pt `texto3` | "65" paso 9 `texto2` | nada | nivel |
| Normal, nivel 0 | `texto` | `texto2` | 1 pt `texto3` completa | oculto | nada | nivel (sube desde 0; `.selection` al cruzar); con seis sonando, "Seis a la vez" 3 s y no sube (C19) |
| Bajo el dedo | `texto` | `texto2` | 3 pt `índice` | 17 pt `texto` | — | — |
| Bloqueado-Pro, sin nivel guardado | `texto2` | `texto2` | 1 pt `texto3` completa | `comun.pro` "pro" versalitas `texto2` | fuera de `NightWindow`: hoja Pro (C06); dentro, nada (C08) | nada |
| Bloqueado-Pro, con nivel guardado | `texto2` | `texto2` | 1 pt `texto3` completa | `comun.pro.nivel` "pro · 30" (el nivel se conserva; el motor lo ignora sin acceso; la degradación nunca escribe; guardar conserva sin diálogo, C23) | igual | nada |
| Prueba (noches 1-7 desde que empieza) y Pro | idéntico a Normal | | | | | |
| Deshabilitado | no existe | | | | | |

Sin escucha de 30 s en 1.0 (C06: pasa a 1.1 y, cuando llegue, no abrirá hoja sola). Tocar una capa Pro fuera de `NightWindow` sube la hoja Pro (E5) sobre esta hoja con "Empezar la prueba · 7 noches" / "Comprar"; lo que sonaba sigue sonando debajo. Si empieza la prueba o compra, la capa entra con fundido de 800 ms en el instante (la compra que se oye, 03 §1.3) y la fila pasa a Normal con su nivel guardado; la cabecera de la página pasa a "prueba · quedan 7 noches" (C07). Dentro de `NightWindow` o en la página nocturna el toque no hace nada y no hay línea matinal (C08).

### 2.9 Descomposición del horizonte (pulsación larga, sonando)

```
 HASTA 6 CAPAS SONANDO (tope C19) · banda 272-296, paso 4
 272 ┌──────────────────────────────────────┐
 274 │ ──────────────────────────────────── │ Blanco
 278 │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ Rosa 50          una línea por capa con nivel > 0, en el orden del mezclador;
 282 │ ──────────────────────────────────── │ Marrón           grosor 1 → 3 pt por nivel; opacidad 0,6 → 1,0 por RMS de esa capa
 286 │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ Lluvia 30
 290 │ ──────────────────────────────────── │ Viento
 294 │ ──────────────────────────────────── │ Océano
 296 └──────────────────────────────────────┘
      capas a 0: no se dibujan (lo que está a cero no suena ni gasta: Dial) · todo en texto, sin etiquetas (cero iconos, cero texto nuevo)
```

Pulsación larga de 0,6 s sobre la banda (área táctil 44 pt: 262-306) mientras suena: el horizonte se descompone en 400 ms `.easeInOut` en una línea por capa con nivel > 0 (**como mucho seis**, por el tope de C19: la banda de 24 basta siempre; 03 §4.1 dice "hasta 11" y el tope lo acota), en el orden del mezclador, grosor por nivel (1 + 2 × nivel; son `texto`, no `índice`, así que el mínimo de 1,5 no aplica) y opacidad por el RMS real de esa capa (0,6 + 0,4 m) [spike I0-1: medidor por capa]; todas en `texto`, ninguna en `índice` (durante la descomposición no hay "una cosa viva": hay varias, así que no hay índice). Se recompone al soltar (400 ms). Con la Marea guiando, las líneas se superponen dentro de la banda de 120 sin tocar la línea de agua, que pasa a `texto`. Reduce Motion: fundido cruzado 250 ms. Alternativa sin gesto: acción de VoiceOver `ax.accion.capas_separadas` "Ver capas por separado" (C63: las sublíneas son decorativas; no hay `AXChartDescriptor` ni rotor Audio Graph: el Horizonte comunica estado, no datos). No existe en la página nocturna ni en Capas (en Capas cada fila ya es su línea).

### 2.10 Página nocturna (pantalla 3)

**Estado de tinta por procedencia (03 §3.2, C40):** al volver de Noche, la misma página con **una tinta**, y dura toda la sesión: la página nocturna se activa la primera vez que se sale de Noche (`UserDefaults` `sleepnoise.nightSession.v1`, fecha de la sesión) y se mantiene para **toda entrada posterior** a la página en esa sesión (icono, Spotlight, Live Activity, widget, cierre de una hoja, vuelta de Noche) hasta la salida deliberada: el toque en el nombre de la mezcla (o "Noche", que vuelve a Noche). **Sin salida por reloj**: no vuelve sola a la página de día a las 07:00 ni a ninguna hora (C40; 03 §12 mantiene el toque en el nombre frente a la pulsación larga, §11 #2). Así, a las 3, cuando el temporizador se fundió a las 0:42 y la persona abre la app desde el icono o desde la Live Activity en pausa, la página nace nocturna. Una apertura sin haber pasado por Noche en esa sesión nace en la página de día, a cualquier hora (la fase horaria se llama Día, `.day`, C14; "Descenso" es solo el ritual de la Marea). La transición Noche → página es de 2 s de opacidad (250 ms con Reduce Motion) y la página nocturna → página de día, también. Lo que no se vende ni se enseña de noche no depende de esta tinta sino de `NightWindow` (21:00–07:00): tips, hoja Pro y reseña; la página nocturna lo hereda a cualquier hora porque viene de Noche.

```
 y        ┌────────────────────────────────────────────────┐  negro
  64      │ prueba · quedan 5 noches                       │  texto-noche (versalitas; sigue siendo paso 9, Medium) · texto, no botón
 100      │ Esta noche                                     │  texto-noche · toque = vuelve a la página de día (03 §3.2)
 144      │ Sonando · se funde a las 3:42                  │  texto-noche · paso 7 Medium (de noche nada < Medium)
 284      │ ══════════════════════════════════════════════ │  texto-noche · grosor 1 → 3 por RMS · opacidad fija 1,0 (sin índice: ley 3)
 324      │ Lluvia · sobre el tejado                   30  │  nombre y subtítulo texto-noche · valor texto-noche
 356      │ ━━━━━━━━━━━━━━━━──────────────────────────────  │  ← un arrastre a la izquierda la pone a 0 sin encenderse la cara
 404      │ Rosa · suave y equilibrado                 50  │     bajo el dedo: 3 pt índice-noche (el único índice de noche)
 436      │ ━━━━━━━━━━━━━━━━━━━━━━━━━━──────────────────── │  llena 2 pt texto-noche · resto 1 pt texto3
 552      ├────────────────────────────────────────────────┤  hairlines trazo (sin cambio)
 569      │ Todas las capas                                │
 640      ├────────────────────────────────────────────────┤
 652      │ Marea                                   ( ◯  ) │  toggle del sistema · .tint(texto-noche) · el pomo blanco es del sistema (§6)
 712      ├────────────────────────────────────────────────┤
 729      │ Temporizador             Hasta dormirme · 45 min│
 769      │   Mezclas            (  ❚❚ )            Noche  │  palabras texto-noche · Disco grafito · glifo texto-noche
 852      └────────────────────────────────────────────────┘
```

| Qué cambia | Página de día | Página nocturna |
|---|---|---|
| Tinta de texto (todo: nombre, estado, filas, valores, barra, versalitas) | `texto` / `texto2` | `texto-noche` (8,03:1). Una sola. |
| Pistas vacías y marcas | `texto3` | `texto3` |
| Horizonte sonando | `índice`, grosor 1,5 → 3 y opacidad por RMS | `texto-noche`, solo grosor 1 → 3 por RMS (opacidad 1,0): de noche la luminancia no respira |
| Línea de agua | `índice` | `texto-noche` 2 pt; la hora de retirada en la fila va en paso 7 Medium (03 §3.4: nunca versalitas para un dato nocturno) |
| Nivel bajo el dedo | `índice` 3 pt; pista `grafito` | `índice-noche` 3 pt; pista `grafito` |
| Tintes del sistema (Toggle de la Marea) | `.tint(texto)` (03 §4.12) | `.tint(texto-noche)`. El pomo blanco del `Toggle` es del sistema y no se puede teñir. |
| `Slider` por pulsación larga | `.tint(texto)`; pista `texto3` | `.tint(texto-noche)`; pista `texto3` |
| Pesos | Regular en 6, 7, 8 | Medium en 6, 7, 8, 9 (03 §3.4: nada < Medium de noche) |
| Hairlines | `trazo` | `trazo` |
| Disco fundiendo | `pause.fill` + `.pulse` | `pause.fill` quieto (el horizonte bajando ya lo dice: nada se mueve de noche salvo el sonido) |
| Cabecera de prueba | botón → hoja Pro (fuera de `NightWindow`) | **texto, no botón** (pierde el rasgo `.button` y la pista de VoiceOver) |
| Hoja Pro (fila "pro", toggle de Marea sin acceso, cabecera) | sube al tocar, fuera de `NightWindow` | **nunca, por ninguna vía** (C06, C08): el toque en una fila Pro no hace nada; el toggle vuelve a off con "Apagada · pro"; no hay línea matinal. "pro", "pro · N" y "sin {capa}" se quedan: describen. |
| Capas (hoja abierta desde la página nocturna) | §2.7 | hereda la tinta: texto `texto-noche`, pistas `texto3`, nivel bajo el dedo `índice-noche`, `Slider` `.tint(texto-noche)`, encabezados y notas `texto-noche` Medium, glifo del Disco `texto-noche`; sin cambio de posición (M25) |
| Tips y "Seis a la vez" | tip según §4.4; "Seis a la vez" en `texto2` | ningún tip (C65, `NightWindow`); "Seis a la vez" sí, en `texto-noche` (describe el tope, no enseña) |
| Háptica de nivel | según §7 | ninguna (puerta por fase, C35) |
| Línea 2 como botón | 44 pt | 64 pt (03 §4.9: `TextAction` de noche) |
| Salida | — | toque en el nombre → página de día (2 s) (03 §3.2); "Noche" → Noche (2 s). Nunca por reloj (C40). |

### 2.11 Página · los cuatro momentos (pantalla 4)

```
 NOCHE 1 (primera apertura, silencio)                   NOCHE 7 (última de la prueba)             NOCHE 8 (gratuito)
  64 │                                      │   64 │ prueba · última noche            │   64 │ gratis siempre                                  │
 100 │ Esta noche                           │  100 │ Mar y viento                     │  100 │ Mar y viento · sin Océano                       │
 144 │ En silencio                          │  144 │ En silencio                      │  144 │ En silencio                                     │
 196 │                                      │  196 │ Última noche con todo. Mañana,   │  196 │ La prueba terminó. Lo que usaste sigue aquí.    │
 216 │                                      │  216 │ lo gratis sigue gratis.          │  216 │                                                 │
 236 │                                      │  236 │                                  │  236 │                                                 │
 284 │ ──────────────────────────────────── │  284 │ ──────────────────────────────── │  284 │ ────────────────────────────────────────────── │
 324 │ Lluvia · sobre el tejado         30  │  324 │ Océano · oleaje lento        50  │  324 │ Océano · oleaje lento                 pro · 50  │ nombre texto2 · pista texto3
 404 │ Rosa · suave y equilibrado       50  │  404 │ Viento · entre árboles       20  │  404 │ Viento · entre árboles                     20  │ libre: suena
 652 │ Marea                         ( ◯ )  │  652 │ Marea                        ( ● )│  652 │ Marea                                   ( ◯  )  │
 680 │                                      │  680 │                                  │  680 │ Apagada · pro                                  │ paso 7 + versalita
 729 │ Temporizador  Hasta dormirme · 45 min│  729 │ Temporizador  Hasta dormirme · 45 min │ 729 │ Temporizador  Hasta dormirme · 90 min          │ sin cambio: libre (C03)
```

| Momento | Cabecera (64) | Nota de una vez (196-256) | Filas | Lo que no hay |
|---|---|---|---|---|
| **Noche 1** (primera apertura; la prueba no ha empezado: solo empieza desde la hoja Pro, C07) | vacía | vacía (C07: la primera noche no hay párrafo) | "Esta noche": Lluvia 30 · Rosa 50 (camas primero; §9 #17: `defaultLevels()` hoy es Rosa 65 sola); Temporizador "Hasta dormirme · 45 min" (07 §2.1.4: 45 min por defecto desde la primera noche); las capas Pro, en Capas, dicen "pro" | Hoja, permiso, precio, candado, cápsula, tutorial, párrafo |
| **Primera acción Pro** (tocar una capa Pro, encender la Marea, guardar la cuarta mezcla; fuera de `NightWindow`) | → hoja Pro (E5) con "Empezar la prueba · 7 noches"; al empezar, `pro.prueba.estado` "prueba · quedan 7 noches" (estado en Keychain) | vacía | la capa tocada entra con 800 ms | Nada automático: nunca con Play |
| **Noches 2-6** | "prueba · quedan {n} noches" (`one`: "prueba · queda 1 noche") | vacía | iguales; todo abierto | — |
| **Noche 7** | `pro.prueba.estado.ultima` "prueba · última noche" | `prueba.ultima` "Última noche con todo. Mañana, lo gratis sigue gratis." · muere al Play o al tocarla | iguales | Hoja, precio, cuenta atrás |
| **Noche 8** (la prueba caduca al terminar la sesión de la noche 7: `refreshAccess(canDowngrade:)`) | `pro.prueba.estado.gratis` "gratis siempre" durante 7 sesiones gratuitas (03 §1.2); después vacía para siempre | `prueba.terminada` "La prueba terminó. Lo que usaste sigue aquí." · botón (`comun.entendido` como acción de VoiceOver) · una vez | Las Pro con su nivel guardado: nombre `texto2`, pista `texto3`, "pro · 50" (C23); Marea con `marea.estado.apagada.pro` "Apagada · pro"; **Temporizador sin cambio** (entero libre, C03) | Candados, notificación, hoja al abrir, descuento, reproche en la fila, "pro" en el temporizador |
| **Noche 8 · Play** | igual | vacía | Viento suena; estado "Sonando · sin océano" (con dos: "Sonando · sin océano ni trueno" ["Playing · without ocean or thunder"], `pagina.capas.ni`); si todas eran Pro: "Sonando · rosa a 40" | Reproche |
| **Pro comprado** | vacía para siempre | vacía | todas normales | Toda mención: ni "pro", ni sello, ni "✓ Activo" |

### 2.12 Error de audio, vacío, cargando, sin red

```
 ERROR DE AUDIO (no arranca)                                      MEZCLA VACÍA (todo a 0)
 144 │ No se ha podido iniciar el sonido.                  │      100 │ Esta noche                                    │
 164 │ Toca para reintentar.                               │      144 │ En silencio                                   │
 284 │ ──────────────────────────────────────────────────  │      284 │ ───────────────────────────────────────────── │
 769 │  Mezclas             ( ▶ )              Noche      │      324 │                                               │ renglones vacíos: el estado
      2.º fallo: "Si sigue sin sonar, cierra la app y vuelve a abrirla."    569 │ Todas las capas                               │
      3.er fallo: "Cierra las apps que usen el micrófono y vuelve a intentarlo." + "Enviar informe" (196-240)
```

| Estado | Cómo se ve | Por qué así |
|---|---|---|
| **Error de audio · no arranca** (`engine.start` lanza; hoy `audioError = "error.audio"`) | El glifo del Disco **solo pasa a `pause.fill` cuando `engine.start` ha devuelto sin error**; si lanza, conserva `play.fill` y el único feedback del toque es la sombra interior de 2 pt (M14). La línea de estado es un botón de 44 pt de dos líneas (140-184: ocupa el renglón del estado y el de la línea 2) con la escalera de 10 §4.12: 1.er fallo `pagina.error.inicio` "No se ha podido iniciar el sonido. Toca para reintentar." ["Couldn't start the sound. Tap to try again."]; 2.º fallo seguido `pagina.error.inicio.2` "Si sigue sin sonar, cierra la app y vuelve a abrirla." ["If it still won't play, close the app and open it again."]; 3.er fallo `pagina.error.inicio.3` "Cierra las apps que usen el micrófono y vuelve a intentarlo." ["Close any app using the microphone and try again."] y, en el renglón de la nota (196-240, vacío: la nota muere al primer Play, también al fallido), `diagnostico.enviar` "Enviar informe" ["Send report"] como `TextAction` de 44 que abre el correo del usuario con el registro (C56). Paso 7 `texto2`. Sin rojo (03 §3.1: `error` no existe), sin háptica `.error` (no es una hoja de compra), sin alerta. VoiceOver: `ax.reintentar` "No se ha podido iniciar el sonido. Reintentar", `.announcement` (lo causó un toque). Las filas siguen operables (caso 22 de §2.6). | 03 §1.3: la escalera del error de audio; la app dice lo que sabe y no adivina; "Enviar informe" es la única petición de la app (Dial) y aparece solo al tercer fallo y la mañana siguiente a una caída. |
| **Error de audio · se cae a mitad** | Reanuda sola en < 1 s sin decir nada; si no puede: "En pausa · se interrumpió el sonido" (§2.4). A la mañana siguiente, en la primera apertura de día tras una caída nocturna no recuperada: `pagina.estado.manana.error` "Anoche el sonido se detuvo a las 2:14." ["Last night the sound stopped at 2:14 AM."] en la línea de estado y `diagnostico.enviar` en la línea 2 (164-184; 44 táctiles), hasta el primer toque. | Nada que leer si se arregló solo. |
| **Vacío** (todas las capas a 0) | Nombre `mezcla.nombre.vacio` "Esta noche"; estado "En silencio"; renglones de fila vacíos; horizonte hairline. Play → Rosa a 40 (nivel real, primer renglón) y "Sonando · rosa a 40". | El instrumento siempre suena (03 §1.3) y la línea de estado lo dice al tocar Play; una frase que lo explique antes es lo que la interfaz ya hace. Sustituye a `mixer.silent` de `main`. |
| **Cargando** | No existe: la app abre con la última mezcla desde `UserDefaults` en < 1 s; nada remoto. El único "cargando" de la app es el precio ("—") en la hoja Pro (E5). | Sin red, sin spinner. |
| **Sin red** | No aplica a la página ni a Capas. | Lo único con red es StoreKit (E5). |
| **Deshabilitado** | No existe en la página: nada bloquea el sonido (P9). | — |

### 2.13 SE / 16e (375 × 667): la misma página, dos filas

```
 y        ┌──────────────────────────────────────────┐  375 · columna 335 (20-355) · barra de estado 20 · sin inset inferior
  28      │ prueba · quedan 5 noches                 │  28-46 (área táctil 16-60)
  56      │ Esta noche                               │  56-90
 100      │ Sonando · se funde a las 0:42            │  100-120 · línea 2: 120-140
 148      │ (nota de una vez: 148-208)               │
 224      │ ═════════════════════════════════════════ │  horizonte en y 224 (667 × 0,333 = 222,1 → 224 en retícula) · banda 212-236 · Marea disponible: banda reservada 96 (140-236), marcas 140 y 236, recorrido 148 ↔ 224 [a medir]
 248      │ fila-control 1 (248-328)                 │  12 bajo la banda; sin hairline
 328      │ fila-control 2 (328-408)                 │  solo dos filas: la tercera capa va a "y 1 más"
 408      ├──────────────────────────────────────────┤  hairline
 408      │ Todas las capas                   y 1 más│  408-464
 488      ├──────────────────────────────────────────┤  aire 24 (no 32: decisión E2 para SE, §9) · hairline
 488      │ Marea                             ( ◯  ) │  488-560 (72)
 560      ├──────────────────────────────────────────┤  hairline
 560      │ Temporizador     Hasta dormirme · 45 min  │  560-616
 618      │   Mezclas          (  ▶  )         Noche  │  618-667 barra (sin home indicator)
```

En 16e (390 × 844) la página es la de 393 × 852 con 1-2 pt menos por renglón: se toma la geometría de 852 con el horizonte en y 280 (844 × 0,333 = 281 → 280 en retícula; 03 §3.5) y la columna en 350; ningún renglón se recorta. La banda reservada de la Marea en 667 es de **96** y no de 120 (decisión E2: 120 hacia arriba pisaría la línea de estado en 100-120; la línea de agua recorre 148 ↔ 224) [a medir]. Capas en SE: once filas más Timbre y notas (≈ 1 220 pt) en una hoja de ≈ 647 [a medir]: desplaza, como en Large.

### 2.14 Página · papel (1.1, C32)

La apariencia clara del sistema (03 §3.3) llega en **1.1** con "Debajo de otro audio"; 1.0 es solo oscura (`preferredColorScheme(.dark)` en la raíz). Se deja especificada para que la retícula no cambie: mismas cotas que §2.1-2.2; tokens de 03 §3.3. Es lo que se verá en un iPhone de demostración de la tienda y lo que se prueba en luz blanca (§10.2 P1).

```
 REPOSO                                                   SONANDO
 y        ┌────────────────────────────────────────┐      ┌────────────────────────────────────────┐  fondo papel
  64      │ prueba · quedan 5 noches               │      │ prueba · quedan 5 noches               │  versalitas tinta2
 100      │ Esta noche                             │      │ Esta noche                             │  tinta
 144      │ En silencio                            │      │ Sonando · se funde a las 0:42          │  tinta2
 284      │ ────────────────────────────────────── │      │ ══════════════════════════════════════ │  reposo: 1 pt tinta3 (2,61:1) · sonando: ocre, 1,5 → 3 pt
 324      │ Lluvia · sobre el tejado           30  │      │ Lluvia · sobre el tejado           30  │  tinta · tinta2 · línea 2 pt tinta + 1 pt tinta3
 356      │ ━━━━━━━━━━━━━━━━──────────────────────  │      │ ━━━━━━━━━━━━━━━━──────────────────────  │
 404      │ Rosa · suave y equilibrado         50  │      │ Rosa · suave y equilibrado         50  │
 552      ├────────────────────────────────────────┤      ├────────────────────────────────────────┤  hairlines trazo-papel (552, 640, 712)
 569      │ Todas las capas                        │      │ Todas las capas                        │
 652      │ Marea                           ( ◯  ) │      │ Marea                           ( ◯  ) │  toggle .tint(tinta)
 729      │ Temporizador       Hasta dormirme · 45 min    │ Temporizador       Hasta dormirme · 45 min  tinta · tinta2
 769      │   Mezclas          (  ▶  )       Noche │      │   Mezclas          (  ❚❚ )       Noche │  Disco pulsado-papel + sombra interior 1 pt tinta 20 % [a medir]
```

**Decisión E2 frente a 03 §4.1 ("reposo: hairline `trazo`").** En papel, el horizonte en reposo es una línea de **1 pt en `tinta3`** (2,61:1), no la hairline de 0,5 en `trazo-papel` (1,31:1, que bajo luz blanca desaparece): la firma de la página tiene que verse en la tienda, y el silencio sigue dibujado (una línea quieta y fina). Las tres hairlines separadoras siguen en `trazo-papel` 0,5 pt: así el horizonte es, también en papel, distinto de cualquier separador. En negro no cambia nada. La página nocturna es siempre negra (03 §3.3).

---

## 3. Estados completos

Resumen de los estados de la página y de Capas, con el elemento que los distingue **por forma o por palabra** (P7). Cada uno está dibujado en §2. Las palabras son las de 10 §3.

| Estado | Pantalla | Horizonte | Estado (palabra) | Disco | Color en pantalla | Dibujado en |
|---|---|---|---|---|---|---|
| Reposo | Página | hairline `trazo` | "En silencio" | `play.fill` | ninguno (el Toggle va en `texto`, 03 §3.1 regla 2) | §2.1 |
| Reposo · mezcla toda Pro sin acceso | Página | hairline | "En silencio · esta mezcla es Pro" | `play.fill` | 0 | §2.2 |
| Sonando | Página | `índice` 1,5-3 pt respirando | "Sonando · se funde a las 0:42" / "Sonando · hasta las 7:00" (Manto) / "Sonando · en Dormitorio" (ruta) | `pause.fill` | 1 (horizonte) | §2.2 |
| Sonando · con Marea | Página | línea de agua `índice` 2 pt | "Sonando · …" + "inhala" / fila Marea "guiando · 6 por minuto" + "Se retira a las 23:27" | `pause.fill` | 1 (la línea de agua; el Toggle en `texto`) | §2.3 |
| Sonando · recortada | Página | `índice` | "Sonando · sin trueno" | `pause.fill` | 1 | §2.11 |
| Sonando · Rosa a 40 | Página | `índice` | "Sonando · rosa a 40" | `pause.fill` | 1 | §2.2 |
| Bajo el dedo | Página / Capas | `texto` (cede el índice) | sin cambio | sin cambio | 1 (la línea bajo el dedo) | §2.5 |
| Seis a la vez | Página / Capas | sin cambio | "Seis a la vez" en el canal de la fila, 3 s | sin cambio | sin cambio | §2.6 #24 |
| Pulsación larga en fila | Página / Capas | sin cambio | sin cambio | sin cambio | 1 (horizonte) sonando / 0 en silencio: el `Slider` va en `texto` | §2.5 |
| Descomposición | Página | ≤ 6 líneas `texto` | sin cambio | sin cambio | 0 | §2.9 |
| En pausa (y lo que el sistema sabe) | Página | hairline | "En pausa" / "· llamada" / "· auriculares" / "· AirPods" / "· se interrumpió el sonido" | `play.fill` | 0 | §2.4 |
| Reanudada por el altavoz | Página | `índice` | "Sonando · …" + línea 2 "Sonando · al 40" | `pause.fill` | 1 | §2.4 |
| Fundiendo | Página | baja a hairline con la ganancia | "Sonando · fundiendo · 8 min" | `pause.fill` + `.pulse` (quieto de noche) | 1 → 0 | §2.4 |
| Terminada | Página | hairline | "En silencio" | `play.fill` | 0 | §2.4 |
| Pro bloqueado sin castigo | Página / Capas | — | "pro" / "pro · 30" en versalitas; Marea "Apagada · pro"; el temporizador no cambia (libre, C03) | — | 0 | §2.8, §2.11 |
| Hoja Pro | Página / Capas | — | sube al tocar una fila "pro", el toggle de Marea sin acceso o la cabecera, **solo fuera de `NightWindow` y de la página nocturna**; nunca sola, nunca de noche | — | — | §2.8, §2.10, §4.2 |
| Prueba | Página | — | cabecera "prueba · quedan n noches" / "prueba · última noche" (solo desde que empieza, C07) | — | — | §2.11 |
| Gratis (noche 8) | Página | — | cabecera "gratis siempre" 7 sesiones; nota una vez | — | — | §2.11 |
| Error de audio | Página | hairline | la línea es un botón: "No se ha podido iniciar el sonido. Toca para reintentar." (escalera de tres) | `play.fill` (no cambió: el motor no arrancó) | 0 | §2.12 |
| Mañana tras caída nocturna | Página | hairline | "Anoche el sonido se detuvo a las 2:14." + línea 2 "Enviar informe" | `play.fill` | 0 | §2.12 |
| Vacío | Página | hairline | "En silencio"; renglones vacíos | `play.fill` | 0 | §2.12 |
| Página nocturna | Página / Capas | `texto-noche` | todo en `texto-noche` | glifo `texto-noche` | 0 propio (índice-noche solo bajo el dedo) | §2.10 |
| Cargando / sin red | — | no existen en estas pantallas | | | | §2.12 |

Conteos (P3, P6, P9, brief §8): rectángulos rellenos propios en la página: 0 en reposo, 1 transitorio bajo el dedo (la pista `grafito`, 03 §1.1; el Disco es un control que se coge). Colores distintos del gris por pantalla: **0 en reposo; 1 sonando** (el horizonte o la línea de agua; el Toggle de la Marea va en `.tint(texto)`, 03 §3.1 regla 2 y §4.12: la regla "un índice por pantalla" queda sin excepciones). Candados: 0. Palabras "pro" visibles en la página para un usuario gratuito con la mezcla "Mar y viento" recortada: 2 ("pro · 50" en Océano, "Apagada · pro" en la Marea); ninguna en el temporizador (C03). Estilos de texto en la página: 6 (2, 5, 7, 9, el 6 solo en las acciones de la línea 2, y 17 Medium en la barra y el valor bajo el dedo), al límite; Capas: 5. Familias: 1. Hairlines en la página: 3. Iconos fuera de la barra: 0.

---

## 4. Flujos

### 4.1 Entradas a la página
| Desde | Cómo llega | Estado al llegar | Tinta al llegar (§2.10) |
|---|---|---|---|
| Icono / Spotlight | Arranque frío < 1 s; última mezcla desde `UserDefaults` (formato v2: `[{id, level}]` + `version: 2`, C20); `startIfNeeded()` | Reposo (o Sonando si el motor seguía en segundo plano). La app nunca arranca sonando (C33): el autoarranque existe solo vía Atajos "Al acostarte" | Nocturna si en esta sesión ya se pasó por Noche; si no, página de día, a cualquier hora (C40) |
| Noche (pulsación larga 0,6 s, E4) | 2 s opacidad (250 ms RM) | El que tuviera | Nocturna (abre la sesión nocturna) |
| Live Activity / widget (toque fuera del botón) | Abre la app: en Noche si suena, en la página si no (E6) | Reposo / Sonando / En pausa / Terminada | Nocturna si hay sesión nocturna; si no, página de día |
| Hoja Capas / Marea / Temporizador / Pro cerrada | Sistema | El estado que tuviera: ninguna hoja cambia la página al cerrarse salvo lo que la persona hizo dentro (empezar la prueba o comprar: la cabecera y las filas Pro cambian) | La que tenía la página |
| Mezclas (toque en una mezcla, E5; también las cuatro de la casa, C18) | Vuelve con la mezcla cargada; si sonaba, fundido cruzado 1,5 s | Nombre = el de la mezcla (o "Mar y viento · sin Océano": carga recortada, nunca hoja, C18); filas = sus capas (conjunto y orden recalculados, §2.0); el temporizador no cambia (C18) | La que tenía la página |
| Prueba empezada o compra completada (E5) | La hoja se cierra sola | Cabecera "prueba · quedan 7 noches" / vacía; filas Pro → normales con su nivel; la capa entra con 800 ms si sonaba | Página de día (de noche no hay hoja Pro) |

### 4.2 Salidas de la página
| Acción | Destino | Nota |
|---|---|---|
| Barra "Mezclas" | Mezclas (empujada, E5) | La única entrada; el nombre no es objetivo de toque de día (§2.1, §9 #2) |
| Barra "Noche" | Noche (E4), 2 s | Nunca entra sola si no suena nada |
| Bloquear el iPhone sonando | Noche al desbloquear (entrada por defecto, C47) | Ajuste "Pasar sola a Noche: Al bloquear (defecto) / 1 min / 3 min / Nunca" (C47, C58); con 1 / 3 min, el reloj se reinicia con cualquier toque y **nunca con una hoja abierta** (03 §5 #10). La página no se ve; la Live Activity sí (E6) |
| "Todas las capas" | Hoja Capas | `.large`, sobre `negro`, con barra |
| Toggle o texto de Marea | Toggle: enciende (y arranca el sonido si no sonaba) / apaga; texto: hoja Marea (E3) | Sin acceso: el toggle no se enciende; fuera de `NightWindow`, hoja Pro (C06) |
| Fila Temporizador | Hoja Temporizador (E4) | `.medium` → `.large`; entero libre (C03) |
| Cabecera de prueba / fila "pro" / toggle de Marea sin acceso / cuarta mezcla | Hoja Pro (E5): "Empezar la prueba · 7 noches" / "Comprar" | Nunca sola, nunca al abrir, nunca encima de Play. **Nunca dentro de `NightWindow` ni en la página nocturna** (C06, C08): el toque no hace nada y no hay línea matinal |
| Pulsación larga en el nombre | `contextMenu` (E5) | Guardar como mezcla… / Renombrar / Vaciar |
| Toque en el nombre en la página nocturna | Página de día (2 s) | 03 §3.2; de día el toque no hace nada |

**Ajustes que afectan a la página** (inventario de C58, E5): Noche (Pasar sola a Noche · Hora en Madrugada · Controles visibles · Mantener encendida), Háptica, Al acostarte (Siri/Atajos), Salida (picker del sistema), Pro (estado), Qué sabemos, Lo que no hay (+ privacidad), Diagnóstico (+ Escribir al autor), versión y MB. Sin "abrir sin sonar" (C33), sin fila de reseña (C55), sin iCloud en 1.0 (C09). La página no tiene ajustes propios.

### 4.3 Interrupciones (lo que la página hace; el motor y Noche son de E4; la regla es C48 y C49)
| Interrupción | Página | Reanudación |
|---|---|---|
| Cualquier interrupción del sistema (`interruptionNotification .began`: alarma, Siri, otra app; iOS no comunica la causa y la línea no la inventa) | "En pausa"; horizonte → hairline 300 ms; sin háptica ni sonido | **Fuera de la ventana de la mañana** (05:00–11:00, o fin de Manto −60 min si hay Manto): reanuda con fundido de 3 s y "Sonando · …", sin texto. **Dentro de ella ninguna interrupción reanuda**: la sesión termina (así gana la alarma), la página dice "En silencio" y el Disco arranca una sesión nueva (C48). Igual en todos los modos |
| Llamada (`.began` + `CXCallObserver` con llamada activa) | "En pausa · llamada" | Igual que arriba; una llamada **nunca termina la sesión fuera de la ventana de la mañana** (C48) |
| Auriculares fuera / desconectados (`oldDeviceUnavailable`: caída de ruta) | Fundido de 40 ms y pausa; "En pausa · auriculares" + "Seguir por el altavoz" 60 s | **Nunca reanuda sola por el altavoz** (C49). El toque (Disco, línea 2, Live Activity, bloqueo) reanuda capado a 0,4 **solo si la ruta cambió** → línea 2 "Sonando · al 40" hasta el primer toque. **Con la app delante**, al reconectar auriculares reanuda sola (800 ms) a nivel completo; **en segundo plano o bloqueada no hay nada automático**: en `main`, `pause` → `engine.stop` → `deactivate()`, y sin audio iOS suspende el proceso a los pocos segundos (§9 #19) |
| AirPods al dormirse (`pauseCommand` con auriculares como ruta activa; iOS 26) | `pauseCommand` con auriculares = fundido de 3 s; "En pausa · AirPods" (C49) | No reanuda sola; el Disco reanuda (o empieza una sesión nueva si pasaron 20 min) |
| `mediaServicesWereReset` | Reconstruye y reanuda sola en < 1 s sin decir nada; si no: "En pausa · se interrumpió el sonido"; a la mañana, "Anoche el sonido se detuvo a las 2:14." + "Enviar informe" (§2.12) | Disco |
| 20 min en pausa | La sesión termina (E4). El fin se evalúa **al volver a primer plano o al siguiente Play** (`Date` guardada en la pausa), no con un temporizador: el proceso puede estar suspendido. La Live Activity no cambia hasta entonces (E6); pregunta a E4/E6 en §9 #19 | Estado "En silencio" |
| Fin de la prueba mientras suena | **Nada cambia** hasta que la sesión acaba (`canDowngrade`); al abrir la app en la sesión siguiente, §2.11 noche 8; la degradación nunca escribe (C23) | — |
| Volver del fondo con la hoja Capas abierta | La hoja sigue; la página debajo actualiza su estado | — |

### 4.4 Primer uso en lo que toca a la página (pantalla 16 es de E5; esto es lo que E2 aporta)
1. Primera apertura: §2.11 noche 1. La app abre en reposo (C33): "Esta noche" con Lluvia 30 · Rosa 50 (§9 #17: hoy `defaultLevels()` = Rosa 65). Cabecera vacía, nota vacía (la prueba no ha empezado, C07). Temporizador "Hasta dormirme · 45 min" (07). Ningún permiso, ninguna hoja.
2. Toque en el Disco: suena en < 1 s con el fundido del motor (800 ms `.easeOut`, 03 §3.7); `.impact(.medium, 0.7)`. Nada más cambia: la prueba no arranca con Play.
3. Primer arrastre sobre una fila: nada se enseña (lo descubrió solo).
4. **Segundo arrastre de su vida, fuera de `NightWindow`**: TipKit, una vez, en el **canal** de esa fila (y0+58..y0+78), paso 7 `texto2`, sin imagen ni flecha ni botón de cierre: `tip.arrastre` "Arrastra sobre el nombre para cambiar el nivel." ["Drag across the name to change the level."]; 6 s y fundido 250 ms. El canal sigue muerto al tacto: el tip no es un objetivo. Es el único TipKit de la app (C65; la lista queda cerrada: las dos frases de Noche son texto fijo, E4). Implementación: estilo `ChannelTipStyle: TipViewStyle` que dibuja solo `tip.message` en paso 7 `texto2` (el `TipView` del sistema trae título, cierre y relleno y no cabe en 24 pt; 04 lo llama `LineTipStyle`: un solo estilo, E1 elige el nombre); regla `#Rule(Self.levelDragged) { $0.donations.count >= 2 }` con `levelDragged.donate()` al soltar un arrastre válido; parámetros `@Parameter static var isNightWindow` e `isTideGuiding` que vetan 21:00–07:00 y la guía; `Tips.MaxDisplayCount(1)`.
5. Primer "Todas las capas": nada que enseñar; las palabras "pro" se explican solas al tocarlas: fuera de `NightWindow`, hoja Pro con "Empezar la prueba · 7 noches" (C06, C07); ahí empieza la prueba y la cabecera pasa a "prueba · quedan 7 noches".
6. Lo que la página nunca enseña: pantalla de bienvenida, carrusel, valoración, notificaciones, "novedades".

---

## 5. Las cinco tablas obligatorias

### 5a · Movimiento (elemento → señal del motor → duración/curva → Reduce Motion → Always-On / `isLuminanceReduced`)

| # | Elemento | Señal del motor que lo mueve | Duración / curva | Reduce Motion | Always-On · `isLuminanceReduced` · Noche · fondo · hoja encima |
|---|---|---|---|---|---|
| M1 | Horizonte: hairline → `índice` | Arranque: **sigue la ganancia maestra real** (envelope del `RenderState`; `defaultFadeIn` 0,8 s `.easeOut`, 03 §3.7, 04 §0 (7)) | La del motor: 800 ms `.easeOut` | Igual (es opacidad y grosor) | n/a (no se arranca desde ahí) |
| M2 | Horizonte: grosor 1,5 → 3, opacidad 0,6 → 1,0 | RMS maestro, 20 Hz, τ 500 ms [spike I0-1] | Continua; sin curva (lee la señal) | 4 Hz, τ 1,5 s | Congelado a hairline en ≤ 2 s `.easeInOut`; `TimelineView` `paused`. Página nocturna: `texto-noche`, solo grosor 1 → 3 (opacidad 1,0) |
| M3 | Horizonte: → hairline (pausa, fin) | Ganancia → 0 | 1,5-2 s `.easeInOut`; interrupción 300 ms; caída de ruta 40 ms de audio / 2 s de interfaz; `pauseCommand` con auriculares 3 s (C49) | Igual | Igual |
| M4 | Horizonte: `índice` ↔ `texto` al arrastrar un nivel | Dedo | 250 ms opacidad (cruce de color) | Igual | n/a |
| M5 | Descomposición en ≤ 6 líneas | Pulsación larga 0,6 s; RMS por capa [spike I0-1] | 400 ms `.easeInOut` ida y vuelta | Fundido cruzado 250 ms | No existe de noche |
| M6 | Marcas de pleamar / bajamar (176, 296) y línea de agua aparecen dentro de la banda reservada | Marea empieza (`breathing.begin`) | 800 ms opacidad; **la banda no crece** (03 §3.5, §4.1) | 250 ms | Se funden a la hairline en ≤ 2 s |
| M7 | Línea de agua 184 ↔ 284 | `BreathCurve` con `guide.anchor` + `outputLatency`; 7,5-15 s por ciclo, 4:6 | Continua; `TimelineView` 30 Hz pausable | Posición fija a media banda (y 236); opacidad 0,6 → 1,0 con la misma curva | Quieta en bajamar (284); en Noche no se dibuja (E4) |
| M8 | Palabra "inhala" / "exhala" | Fase de la curva | 250 ms opacidad; 500 ms al retirarse | Igual | n/a |
| M9 | Disolución: amplitud → 0; marcas y línea se funden | Modulación del motor se abre (`dissolve`) | último 20 % de la guía (E3); cierre 800 ms | Opacidad → 0,6 | Igual |
| M10 | Fila bajo el dedo: pista `grafito`, línea 2 → 3 pt, valor 13 → 17 | Dedo | 150 ms entrada / 250 ms salida `.easeInOut` | Igual (sigue al dedo; nada cambia de posición) | n/a |
| M11 | Longitud de la línea de nivel | Dedo (Δx) | 0 (directa) | Igual | n/a |
| M12 | `Slider` del sistema sustituye a la línea en la fila (y se cancela si el dedo arrastra) | Pulsación larga 0,6 s | 250 ms opacidad (150 ms al cancelarse); se retira a los 5 s sin dedo | Igual | n/a |
| M13 | Disco: `play.fill` ↔ `pause.fill` | Estado real del motor tras `start` (nunca antes de que devuelva) | 200 ms `.contentTransition(.symbolEffect(.replace))` | Igual (es fundido) | — |
| M14 | Disco pulsado: sombra interior 1 → 2 pt | Toque | 200 ms | Igual | — |
| M15 | Disco: `.pulse` en el glifo | `timer.isFading` | el del sistema | Apagado | Apagado en la página nocturna |
| M16 | Línea de estado, línea 2, cabecera, subtítulos | Cambio de estado | 250 ms opacidad | Igual | — |
| M17 | Nota de una vez → vacía | Toque / primer Play | 250 ms opacidad; el renglón conserva su altura | Igual | — |
| M18 | Fila pulsada ("Todas las capas"): fondo `grafito` | Toque | 200 ms `.easeInOut` (C66) | Igual | — |
| M19 | (suprimida: la fila Temporizador enseña el ajuste, no la cuenta; en la página nada late por minuto) | — | — | — | — |
| M20 | Página ↔ Noche; página de día ↔ página nocturna | Bloqueo / "Noche" / "Pasar sola a Noche" / toque en el nombre (nunca el reloj, C40) | 2 s opacidad | 250 ms | — |
| M21 | Tip en el canal | Segundo arrastre (fuera de `NightWindow`) | 250 ms in / 6 s / 250 ms out | Igual | Nunca de noche |
| M22 | Hoja Capas abre / cierra; scroll | Sistema | Sistema | Sistema | — |
| M23 | "Seis a la vez" en el canal | Arrastre hacia arriba de una fila a 0 con seis sonando (C19) | 250 ms in · 3 s · 500 ms out; la capa no se añade | Igual | De noche igual, en `texto-noche` |
| M24 | Cambio prueba → gratis | Nueva sesión | 0: entre sesiones, nunca animado | — | — |
| M25 | Capas de noche: tinta `texto-noche` heredada de la página | Sesión nocturna | 0 (nace así); sin cambio de posición | — | — |
| M26 | (suprimida: la escucha de 30 s pasa a 1.1, C06) | — | — | — | — |

Transversales: nada cambia de posición ni de tamaño; ninguna finita > 2 s; las dos infinitas (M2, M7) son el sonido y llevan `paused:` ligado a `scenePhase`, `isLuminanceReduced`, "hoja encima" y "suena algo"; 0 fotogramas con la pantalla apagada; ningún píxel cambia de luminancia > 3 veces/s (τ ≥ 300 ms); springs: ninguno. El medidor RMS acumula por búfer, no por muestra, y solo cuando `EngineCommand.metering == true` (lo pone la vista al entrar en escena y lo quita con `scenePhase != .active`, `isLuminanceReduced` o hoja encima); con la pantalla apagada el hilo de audio no mide (§9 #20).

### 5b · VoiceOver por control

**Orden de lectura de la página** (03 §4.4 y 04 §5b: la barra inferior se lee después del contenido, así que el Disco no puede ser el primero; lo que lo hace alcanzable desde cualquier foco es **Magic Tap en la raíz de la página** = play/pausa, C63, y `.startsMediaSession` en el Disco): 1 cabecera · 2 nombre · 3 horizonte · 4 estado · 5 línea 2 · 6 nota · 7-9 filas · 10 Todas las capas · 11 Marea · 12 Temporizador · 13 Mezclas · 14 Disco · 15 Noche. Capas: 1 "Capas" · 2 "colores" · 3-5 · 6 "camas" · 7-14 · Timbre · notas · Mezclas · Disco · Noche.

**Regla de anuncios.** Se anuncia (`.announcement`) solo lo que causa un toque de la persona: Play, Pausa, error al tocar Play, nivel, "Seis a la vez", Marea encendida o apagada, `Slider`, descomposición. Lo que ocurre sin tocar (Fundiendo, Terminada, interrupciones y sus reanudaciones, fin de la prueba, retirada de la Marea) cambia el texto y se lee al enfocarlo; **nunca se anuncia**: VoiceOver no habla en el momento exacto en que el sonido se retira para no despertar a nadie (03 §3.8 "anuncio de la línea de estado" se lee aquí como "el texto de la línea de estado es el anuncio", sin `.announcement` posted; 10 §5b dice "anuncio al cambiar" y E2 lo acota a los cambios causados por un toque: §9 pendiente de E7).

| Control | Etiqueta ES [EN] | Valor | Pista ES [EN] | Rasgos | Acciones personalizadas |
|---|---|---|---|---|---|
| Disco | "Reproducir" / "Pausar" ["Play" / "Pause"] (`control.play` / `control.pause`) | — | "Suena en un segundo." ["Starts in a second."] (10 §5b) | `.button`, `.startsMediaSession`; Magic Tap en la raíz | — |
| Cabecera de prueba | `ax.prueba.cabecera` "Prueba, quedan %lld noches" / "Prueba, última noche" / "Gratis siempre" ["Trial, %lld nights left" / "Trial, last night" / "Always free"] | — | `ax.prueba.pista` "Toca dos veces para ver qué incluye Pro." ["Double-tap to see what's in Pro."] (fuera de `NightWindow`) | `.button` de día; `.staticText` sin pista en la página nocturna y dentro de `NightWindow` | — |
| Nombre de la mezcla | `mezcla.guardar.campo` "Nombre de la mezcla" ["Mix name"] | "Esta noche" / "Mar y viento, sin Océano" | `ax.nombre.pista` "Mantén para guardar o renombrar." ["Hold to save or rename."]; en la página nocturna `ax.nombre.pista.noche` "Toca dos veces para volver a la página de día." | `.header` (no `.button`: el toque de día no hace nada); `.button` en la página nocturna | `ax.accion.guardar` "Guardar como mezcla", `comun.renombrar` "Renombrar", `mezcla.menu.vaciar` "Vaciar"; en la página nocturna, además `ax.accion.volver.dia` "Volver a la página de día" ["Back to the day page"] |
| Horizonte (elemento de estado, C63) | `ax.horizonte` "Sonido" ["Sound"] | `ax.horizonte.valor.bajo` / `.medio` / `.alto` "Sonando, nivel bajo / medio / alto" / `pagina.estado.silencio` "En silencio" / `ax.horizonte.marea` "Marea, inhala, 6 por minuto" ["Playing, low / medium / high level" / "Silent" / "Tide, breathe in, 6 per minute"]. El nivel se recalcula al enfocar con histéresis de 3 s (solo cambia de palabra si el nuevo tramo se sostiene 3 s). La fase ("inhala" / "exhala") solo se habla si la persona activó la voz de guía en la hoja Marea (E3) | — | `.image` (sin `.updatesFrequently`: con la lluvia el RMS vacila y la Marea diría la fase cada 4-6 s); **sin `AXChartDescriptor` ni rotor Audio Graph**: las sublíneas son decorativas (C63) | `ax.accion.capas_separadas` "Ver capas por separado" ["Show layers separately"] (solo sonando) |
| Línea de estado | `accessibilityLabel` derivada de la cadena visible: " · " → ", " y la hora como `Date` hablada por el sistema ("Sonando, se funde a las doce y cuarenta y dos") | — | — | `.staticText`; `.announcement` solo si el cambio lo causó un toque (regla de arriba) | — |
| Seguir por el altavoz | `ruta.seguir_altavoz` "Seguir por el altavoz" ["Keep playing on speaker"] | — | `ax.altavoz.pista` "El volumen baja al cuarenta." ["The volume drops to forty."] | `.button` (60 s) | — |
| Reintentar audio | `ax.reintentar` "No se ha podido iniciar el sonido. Reintentar" ["Couldn't start the sound. Try again"] | — | — | `.button`; `.announcement` al aparecer (lo causó Play) | Enviar informe (3.er fallo) |
| Enviar informe | `diagnostico.enviar` "Enviar informe" ["Send report"] | — | `ax.informe.pista` "Abre tu correo con el registro de la noche. Sin nombre ni identificadores." | `.button` | — |
| Nota de una vez | el texto tal cual | — | (ninguna: la acción lo dice) | `.button` | `comun.entendido` "Entendido" ["Got it"] |
| Tip del canal / "Seis a la vez" | el texto tal cual | — | — | `.staticText`; se lee una vez al aparecer (lo causó un arrastre) | — |
| Palabra de fase | oculta (`accessibilityHidden`) | — | — | — (el valor del horizonte ya la dice si hay voz de guía) | — |
| Fila de capa | `ax.capa` "Rosa, suave y equilibrado" ["Pink, soft and balanced"] | `a11y.percentFormat` "50 por ciento" ["50 percent"]; a 0: "0 por ciento" (§9 pendiente de E7: "a cero") | `ax.capa.pista` "Desliza arriba o abajo para ajustar." ["Swipe up or down to adjust."] | `.adjustable` (pasos del 5 %) | `ax.accion.silenciar` "Silenciar" ["Mute"], `ax.accion.maximo` "Máximo" ["Maximum"], `ax.accion.deslizador` "Ajuste con deslizador" ["Adjust with slider"], `ax.accion.subir` / `.bajar` |
| Fila de capa Pro (gratuito) | `ax.capa.pro` "Trueno, lejano, sin rayos cerca, requiere Pro" ["Thunder, distant, no strikes nearby, requires Pro"] | `ax.capa.pro.valor` "en silencio, nivel guardado treinta" ["silent, saved level thirty"]; sin nivel: "en silencio" | `ax.capa.pro.pista` "Toca dos veces para ver Pro." ["Double-tap to see Pro."] (solo fuera de `NightWindow`; de noche sin pista) | `.button` | `ax.accion.ver_pro` "Ver Pro" ["See Pro"] (no existe de noche) |
| Fila Timbre (C29) | `capas.timbre` "Timbre" ["Tone"] | "grave" / "lejos" por tramos (`capas.timbre.grave` / `.lejos`); centro: "centrado" (§9 pendiente de E7) | `ax.capa.pista` | `.adjustable` | — |
| `Slider` del sistema | `capas.deslizador` "Nivel de Rosa" ["Pink level"] | "50 por ciento" | — | el del sistema; sin cierre automático con VoiceOver / Switch Control / Control por voz; se cierra al mover el foco o con el escape en Z (sin acción "Cerrar": lista negra) | — |
| Todas las capas | `capas.todas` "Todas las capas" ["All layers"]; con desbordamiento, el valor visible "y 2 más" se lee a continuación (§9 pendiente de E7: "Todas las capas, y dos más") | — | `ax.mas.pista` "Abre todas las capas." ["Opens all layers."] | `.button` | — |
| Marea (toggle) | `marea.titulo` "Marea" ["Tide"] | `ax.marea.valor` "Guiando, 6 por minuto, se retira a las once y veintisiete" / `ax.marea.off` "Desactivada" / `ax.marea.off.pro` "Desactivada, requiere Pro" ["Guiding, 6 per minute, recedes at eleven twenty-seven" / "Off" / "Off, requires Pro"]; armada sin sonar: el valor del sistema ("activado") | `ax.marea.pista` "Toca dos veces para encenderla; el sonido arranca." ["Double-tap to turn it on; the sound starts."]; sin acceso y fuera de `NightWindow`: `ax.marea.pista.pro` "Toca dos veces para ver Pro." | `Toggle` del sistema | — (el texto de la fila es un `.button` aparte "Marea" → hoja Marea) |
| Temporizador (fila) | `temporizador.titulo` "Temporizador" ["Timer"] | en reposo, el ajuste como en pantalla ("Hasta dormirme, 45 min" / "Apagado" / "Manto, hasta las siete"); sonando, `ax.temporizador.valor` "Hasta dormirme, quedan 38 minutos" ["Until I sleep, 38 minutes left"] | — | `.button` | — |
| Mezclas (barra) | `barra.mezclas.ax` "Mezclas" ["Mixes"] | — | — | `.button` | — |
| Noche (barra) | `barra.noche.ax` "Pantalla de noche" ["Night screen"] | — | — | `.button` | — |
| Cabecera "Capas" | `capas.titulo` "Capas" ["Layers"] | — | — | `.header` | — |
| Encabezados de sección | "colores" / "camas" ["colors" / "beds"] | — | — | `.header` | — |
| Notas de Capas | el texto | — | — | `.staticText` | — |

24 filas. Si la persona tiene activada la **Atenuación de audio de VoiceOver**, el sistema baja la cama mientras habla y la devuelve solo; la app no hace nada (categoría `.playback` sin opciones). Cada háptico de §7 tiene su anuncio en esta tabla o en §7.

### 5c · Gesto → alternativa sin gesto → Control por botón → teclado / Pointer

| Gesto | Dónde | Alternativa sin gesto (VoiceOver / Control por voz) | Control por botón (Switch Control) | Teclado / Full Keyboard Access / Pointer (iPad, Catalyst si llega) |
|---|---|---|---|---|
| Arrastre horizontal (nivel; C52) | Página, Capas | `.adjustable`: deslizar arriba/abajo; voz: "Subir Rosa", "Bajar Rosa", "Silenciar", "Máximo" | La fila es un elemento; "Ajuste con deslizador" abre el `Slider` del sistema, que Switch Control opera con sus propios pasos y que no se cierra solo | Tab al foco de la fila; ← → ±5; ⇧← → ±1; Pointer: arrastre con el puntero sobre la fila (mismo gesto); la rueda desplaza la lista, no cambia el nivel |
| Toque en fila (nada) | Página, Capas | — | — | — |
| Pulsación larga en fila (`Slider`, C21) | Página, Capas | Acción "Ajuste con deslizador"; se cierra al mover el foco o con el escape en Z | Idem | Espacio sobre la fila; Esc cierra |
| Pulsación larga en el horizonte (descomposición) | Página | Acción "Ver capas por separado" (C63: sin Audio Graph) | Acción en el elemento "Sonido" | Espacio sobre "Sonido"; se recompone con Esc |
| Pulsación larga en el nombre (`contextMenu`) | Página | VoiceOver expone el menú como acciones; voz: "Mostrar menú" | El nombre es un elemento con las tres acciones | ⌘S guardar como mezcla; ⌃⏎ o la tecla de menú abren el menú (⏎ no hace nada: el toque de día tampoco) |
| Toque en el nombre en la página nocturna (página de día) | Página | Acción "Volver a la página de día" | Idem | ⏎ sobre el nombre, solo en la página nocturna |
| Toque en el Disco | Página, Capas | Magic Tap (dos dedos, dos toques) desde cualquier foco (raíz de la página) | Elemento de la barra | Espacio / ⏎; teclas multimedia del sistema (Now Playing) |
| Toggle de la Marea | Página | `Toggle` del sistema | Idem | Espacio |
| Scroll (Capas, página desde xL) | Hoja, página | Deslizar con tres dedos | Grupo de scroll del sistema | Flechas / rueda |
| Cerrar la hoja Capas | Hoja | Gesto Z de dos dedos (escape); voz: la orden del sistema | Elemento de cierre del sistema | Esc |
| Toque en una fila Pro (hoja Pro de día; C06) | Página, Capas | Doble toque; acción "Ver Pro" | Elemento `.button` | ⏎ |
| Toque en "Todas las capas" / Temporizador / cabecera (de día) / nota / "Enviar informe" | Página | Doble toque | Elementos `.button` | ⏎ |

Ningún gesto es la única vía; ninguno es de varios dedos; ninguno horizontal choca con el gesto de volver porque la página es raíz y Capas es hoja. No hay gesto de timbre (C29, C52) ni doble toque (C27).

### 5d · Dynamic Type por tramo

Tamaños de referencia de los estilos del sistema (pt): `.title1` 28 / 34 (xxxL) / 48 (AX3) / 56 (AX5); `.headline` 17 / 23 / 33 / 43; `.subheadline` 15 / 21 / 30 / 36; `.footnote` 13 / 19 / 27 / 33; `.body` 17 / 23 / 40 / 53. Todo escala con `relativeTo`; las medidas gráficas (grosor de líneas, banda, hairlines, Disco 44) **no** escalan; las alturas de fila sí (`@ScaledMetric`). El horizonte deja de estar a un tercio desde AX1: se ancla a 24 pt bajo el bloque de cabecera (cabecera, nombre, estado; 03 §3.5, 04 §2.0.3). La página es siempre `ScrollView` (§2.0); en xS-L no se desplaza porque cabe.

| Tramo | Página | Fila-control | Capas | Barra |
|---|---|---|---|---|
| **xS-L** | Como §2.1-2.14; cabe sin desplazar en 852 y en 667 (2 filas). Los tres tamaños menores conservan la geometría (sobra aire). Fila Temporizador: si el ajuste no cabe a la derecha del nombre, `ViewThatFits` lo baja al segundo renglón (56 → 72) también aquí (caso EN "Blanket · until 7:00 AM", §6). | 80 de paso (56 + 24); nombre · subtítulo en un renglón; valor 13 → 17 bajo el dedo. | Once capas con scroll. | "Mezclas" · Disco · "Noche" en 17 Medium. |
| **xL-xxxL** | Se desplaza (la barra queda fija); el horizonte sigue en y 284 mientras el bloque superior cabe (cabecera + nombre + estado ≤ 272 − 64); si no cabe, se ancla 24 pt bajo el estado. Nota de una vez: hasta 5 líneas; el renglón crece y empuja (el único caso en que algo "empuja", y solo en silencio y entre sesiones). Marea 72 → 88 (subtítulo a dos renglones). | `ViewThatFits`: cuando "nombre · subtítulo · valor" no cabe en 353, el subtítulo baja a un segundo renglón: fila 72 + 24 = 96. Línea de nivel sigue a 12 pt del borde inferior táctil. | Igual. | Igual; `minimumScaleFactor(0.9)` en las palabras; el Disco no cambia. |
| **AX1-AX2** | Horizonte anclado 24 pt bajo el estado. Máximo 2 filas-control visibles antes de "Todas las capas" (la tercera va a "y 1 más"). Nombre de la mezcla hasta 2 líneas (solo nombres del usuario). Línea de estado hasta 2 líneas. | Apilada (03 §4.2): nombre / subtítulo / valor en columna, línea debajo; fila 96-112 + 24 de canal. El valor bajo el dedo crece a 17 `.body` = 38-43 pt y sigue a la derecha. El bloqueo de eje (30°) sigue igual. | Apilada igual; encabezados en versalitas (escalan con `.footnote`); 11 × ≈ 130 = scroll largo. | Palabras en 17 `.body` → 38-43 pt; caben en 353 con el Disco (≈ 150 + 64 + 110). |
| **AX3-AX5** | Igual que AX1-AX2 con una fila-control visible y "y n más"; nombre 48-56 pt en 2 líneas; estado en 2-3 líneas; horizonte y banda conservan 24 / 120 pt. | Fila 128-160 + 24; el valor en su sitio. | Una capa por pantalla aproximadamente; el scroll es largo y no pasa nada: es una lista. | AX3: palabras (40 pt caben: ≈ 140 + 64 + 100 en 353). **AX4-AX5**: `square.stack` ("Mezclas") y `circle.lefthalf.filled` ("Noche") monocromos 28 pt con etiqueta accesible `barra.mezclas.ax` / `barra.noche.ax` (03 §3.6: nunca una luna). Disco igual. |

### 5e · Catálogo de cadenas ES / EN por clave

Las cadenas son las de 10 §5e, letra a letra, citadas por su clave (10 es la fuente de verdad del vocabulario, reconciliación §1 regla 4); también las de VoiceOver (`ax.*`, 10 §5e.16). Esta tabla es el subconjunto que la página y Capas usan, con el contexto de E2 y la longitud máxima que cabe en su renglón a Large en el peor idioma; E7 las revisa sin cambiarles la medida. Las cadenas que E2 necesita y 10 no tiene están en §9 "pendiente de E7" y aquí se usa la redacción de 10 más cercana. Hora: `%@` es siempre una `Date` con `Date.FormatStyle` corto del sistema (es-ES "0:42"; en-US "12:42 AM"); VoiceOver la habla como fecha. Las versalitas se escriben en minúscula.

| Clave (10 §5e) | ES | EN | Contexto en E2 | Máx. |
|---|---|---|---|---|
| `pro.prueba.estado` (pl) | prueba · quedan %lld noches | trial · %lld nights left | Cabecera, versalitas paso 9; solo desde que la prueba empieza (C07); `one`: "prueba · queda 1 noche" | 48 |
| `pro.prueba.estado.ultima` | prueba · última noche | trial · last night | Cabecera, noche 7 | 48 |
| `pro.prueba.estado.gratis` | gratis siempre | always free | Cabecera, 7 sesiones gratuitas tras la prueba (03 §1.2); botón → hoja Pro de día | 48 |
| `mezcla.nombre.vacio` | Esta noche | Tonight | Nombre de la mezcla viva (reconciliación §3, C39) y de la mezcla vaciada; §9: E7 decide si el nombre vivo lleva clave propia | 28 |
| `mezcla.nombre.sin` | %@ · sin %@ | %@ · without %@ | Nombre de mezcla recortada, capa con mayúscula inicial: "Mar y viento · sin Océano"; con dos o más, la lista con `pagina.capas.ni`; sin escala | 28 |
| `pagina.capas.ni` | %@ ni %@ | %@ or %@ | Lista negativa: "sin océano ni trueno" | 24 |
| `pagina.estado.silencio` | En silencio | Silent | Línea de estado, reposo y terminada; valor del horizonte en silencio | 46 |
| `pagina.estado.silencio.pro` | En silencio · esta mezcla es Pro | Silent · this mix is Pro | Mezcla cargada toda Pro sin acceso | 46 |
| `pagina.estado.sonando` | Sonando | Playing | Sin temporizador | 46 |
| `pagina.estado.sonando.funde` | Sonando · se funde a las %@ | Playing · fades at %@ | Hasta dormirme; hora corta regional, tabular | 46 |
| `pagina.estado.sonando.hasta` | Sonando · hasta las %@ | Playing · until %@ | Manto (E4) | 46 |
| `pagina.estado.sonando.sin` | Sonando · sin %@ | Playing · without %@ | Capas en minúscula: "sin trueno", "sin océano ni trueno" | 46 |
| `pagina.estado.sonando.defecto` | Sonando · rosa a 40 | Playing · pink at 40 | Mezcla vacía o toda Pro | 46 |
| `estado.ruta` | Sonando · en %@ | Playing · on %@ | Ruta externa (AirPlay, altavoz; C41) | 46 |
| `estado.volumen` | Sonando · al %lld | Playing · at %lld | Línea 2 tras reanudar por el altavoz capado a 0,4 (C49, C51), hasta el primer toque | 40 |
| `pagina.estado.fundiendo` | Sonando · fundiendo · %lld min | Playing · fading · %lld min | Fundido de ganancia de 10–15 min (C31); minutos que faltan | 46 |
| `pagina.estado.pausa` | En pausa | Paused | Pausa por el Disco y toda interrupción del sistema salvo llamada (C48) | 46 |
| `pagina.estado.pausa.llamada` | En pausa · llamada | Paused · call | `CXCallObserver` confirma una llamada activa (C48) | 46 |
| `estado.pausa.auriculares` | En pausa · auriculares | Paused · headphones | Caída de ruta (`oldDeviceUnavailable`; C49); es-419 "audífonos" | 46 |
| `pagina.estado.pausa.airpods` | En pausa · AirPods | Paused · AirPods | `pauseCommand` con auriculares = fundido 3 s (C49) | 46 |
| `pagina.estado.pausa.interrumpido` | En pausa · se interrumpió el sonido | Paused · the sound was interrupted | Motor caído sin reanudación | 46 |
| `pagina.estado.manana.error` | Anoche el sonido se detuvo a las %@. | Last night the sound stopped at %@. | Línea de estado la mañana siguiente a una caída nocturna; debajo `diagnostico.enviar` | 46 |
| `ruta.seguir_altavoz` | Seguir por el altavoz | Keep playing on speaker | Línea 2, `TextAction` 44 (64 en la página nocturna), 60 s (C49) | 40 |
| `diagnostico.enviar` | Enviar informe | Send report | Línea 2 (mañana tras caída) o renglón de la nota (3.er fallo); abre el correo del usuario (C56) | 40 |
| `pagina.error.inicio` | No se ha podido iniciar el sonido. Toca para reintentar. | Couldn't start the sound. Tap to try again. | Línea de estado como botón 44 de 2 líneas (140-184); sustituye `error.audio` | 92 [a medir] |
| `pagina.error.inicio.2` | Si sigue sin sonar, cierra la app y vuelve a abrirla. | If it still won't play, close the app and open it again. | Segundo fallo seguido | 92 [a medir] |
| `pagina.error.inicio.3` | Cierra las apps que usen el micrófono y vuelve a intentarlo. | Close any app using the microphone and try again. | Tercer fallo + `diagnostico.enviar` | 92 [a medir] |
| `prueba.ultima` | Última noche con todo. Mañana, lo gratis sigue gratis. | Last night with everything. Tomorrow, free stays free. | Nota de una vez, noche 7; muere al Play | 135 (3 líneas) |
| `prueba.terminada` | La prueba terminó. Lo que usaste sigue aquí. | The trial is over. What you used is still here. | Nota de una vez, noche 8; botón; lo que espera a Pro se ve inline ("pro · 50") | 135 |
| `comun.entendido` | Entendido | Got it | Acción de VoiceOver de la nota (sin botón visible, §9 #16) | 12 |
| `marea.fase.inhala` | inhala | breathe in | Palabra de fase, x 373 | 12 |
| `marea.fase.exhala` | exhala | breathe out | Palabra de fase | 12 |
| `capas.todas` | Todas las capas | All layers | Fila; sin valor ni chevron | 24 |
| `capas.mas` (pl) | y %lld más | and %lld more | Valor paso 9 de "Todas las capas" solo cuando hay más capas sonando que renglones (E2: valor, no fila) | 12 |
| `capas.tope` | Seis a la vez | Six at once | Canal de la fila tocada, paso 7, 3 s (C19) | 24 |
| `marea.titulo` | Marea | Tide | Fila (existe `breath.title`, cambia de valor: C15) | 24 |
| `marea.estado.apagada.pro` | Apagada · pro | Off · pro | Subtítulo de la fila sin acceso (03 §4.7); con acceso y apagada, vacío (§9 #9) | 20 |
| `marea.estado.guiando.corto` | guiando · %lld por minuto | guiding · %lld per minute | Versalitas paso 9; primer `Text` del subtítulo mientras guía (03 §4.3); con Descenso empieza en 12 | 24 |
| `marea.retira.hora` | Se retira a las %@ | Recedes at %@ | Paso 7; segundo `Text` del subtítulo mientras guía (03 §3.4: la hora nunca en versalitas); Medium en la página nocturna | 24 |
| `marea.oceano.subido` | Océano subido a 40 para oír la marea. | Ocean raised to 40 so you can hear the tide. | Paso 7, 4 s, en lugar de la hora si la Marea subió Océano desde 0 (03 §1.3; sustituye `breath.oceanRaised`) | 44 |
| `marea.estado.disolviendo` | disolviendo | dissolving | Versalitas | 20 |
| `marea.retirada` | Se ha retirado. El mar sigue. | It has receded. The sea goes on. | Subtítulo 10 s; paso 7 | 40 |
| `temporizador.titulo` | Temporizador | Timer | Fila (existe `timer.title`; EN cambia) | 16 |
| `temporizador.apagado` | Apagado | Off | Ajuste | 32 |
| `temporizador.estado.dormirme` | Hasta dormirme · %lld min | Until I sleep · %lld min | Ajuste, en todos los estados de reproducción; sin "pro" nunca (C03) | 32 |
| `temporizador.estado.manto` | Manto · hasta las %@ | Blanket · until %@ | Manto por hora fija (C11, C22); EN pendiente de en-US (reconciliación §6.4) | 32 |
| `barra.mezclas` | Mezclas | Mixes | Barra; sustituye `control.mixes` | 10 |
| `barra.noche` | Noche | Night | Barra | 8 |
| `barra.mezclas.ax` | Mezclas | Mixes | Etiqueta accesible del glifo en AX4-AX5 | — |
| `barra.noche.ax` | Pantalla de noche | Night screen | Etiqueta de "Noche" y del glifo en AX4-AX5 | — |
| `control.play` / `control.pause` | Reproducir / Pausar | Play / Pause | Etiquetas accesibles del Disco (existen; `control.pause` pasa de "Pausa" a "Pausar") | — |
| `capas.titulo` | Capas | Layers | Cabecera de la hoja | 12 |
| `capas.seccion.colores` | colores | colors | Encabezado versalitas | 12 |
| `capas.seccion.camas` | camas | beds | Encabezado versalitas | 12 |
| `capas.nota` | Se mezclan en tu iPhone mientras suenan. Nada se repite. | Mixed on your iPhone as they play. Nothing loops. | Nota paso 7 (E2), 2 líneas | 70 |
| `capas.cero` | Lo que está a cero no suena ni gasta. | What's at zero makes no sound and costs nothing. | Tercera línea de la nota [a verificar con I0-1] | 47 |
| `comun.pro` | pro | pro | Versalitas, lugar del valor | 3 |
| `comun.pro.nivel` | pro · %lld | pro · %lld | Versalitas con nivel guardado (C23) | 8 |
| `capas.timbre` | Timbre | Tone | Fila al pie de Capas (C29) [spike I0-7] | 14 |
| `capas.timbre.grave` | Grave | Deep | Extremo izquierdo; en el sitio del valor cuando la línea está a la izquierda del centro | 6 |
| `capas.timbre.lejos` | Lejos | Far | Extremo derecho; ídem a la derecha | 6 |
| `capas.deslizador` | Nivel de %@ | %@ level | Etiqueta del `Slider` del sistema (C21) | — |
| `sound.white` / `capas.white.detalle` | Blanco / siseo parejo | White / even hiss | Existe; subtítulo renombrado, valor igual | 14 / 22 |
| `sound.pink` / `capas.pink.detalle` | Rosa / suave y equilibrado | Pink / soft and balanced | Existe | 14 / 22 |
| `sound.brown` / `capas.brown.detalle` | Marrón / retumbo grave | Brown / low rumble | EN pasa de "Deep rumble" | 14 / 22 |
| `sound.rain` / `capas.rain.detalle` | Lluvia / sobre el tejado | Rain / on the roof | Libre; cambia ("Gotas sobre un fondo constante"); no "lluvia fina" (C17) | 14 / 22 |
| `sound.wind` / `capas.wind.detalle` | Viento / entre árboles | Wind / through trees | Libre (C04); PR-A | 14 / 22 |
| `sound.fan` / `capas.fan.detalle` | Ventilador / ventilador lejano | Fan / distant fan | Pro; cambia ("Zumbido mecánico lento") | 14 / 22 |
| `sound.ocean` / `capas.ocean.detalle` | Océano / oleaje lento | Ocean / slow swell | Pro; cambia ("Oleaje que va y viene") | 14 / 22 |
| `sound.thunder` / `capas.thunder.detalle` | Trueno / lejano, sin rayos cerca | Thunder / distant, no strikes nearby | Pro; PR-A; "Trueno" se queda (C13) | 14 / 28 |
| `sound.campfire` / `capas.campfire.detalle` | Hoguera / brasas, sin chasquidos | Campfire / embers, no crackle | Pro; PR-A (es-419 "Fogata") | 14 / 28 |
| `sound.brook` / `capas.brook.detalle` | Arroyo / agua sobre piedras | Brook / water over stones | Pro; PR-A | 14 / 28 |
| `sound.cabin` / `capas.cabin.detalle` | Cabina / avión en crucero | Cabin / aircraft at cruise | Pro; PR-A | 14 / 28 |
| `tip.arrastre` | Arrastra sobre el nombre para cambiar el nivel. | Drag across the name to change the level. | TipKit, canal de la fila, una vez, fuera de `NightWindow` (C65) | 52 |
| `mezcla.menu.guardar` / `comun.renombrar` / `mezcla.menu.vaciar` | Guardar como mezcla… / Renombrar / Vaciar | Save as a mix… / Rename / Clear | `contextMenu` del nombre (E5) | — |
| `mezcla.guardar.campo` | Nombre de la mezcla | Mix name | Etiqueta accesible del nombre (10 §5b) | — |
| `ax.prueba.cabecera` (pl) | Prueba, quedan %lld noches | Trial, %lld nights left | Etiqueta de la cabecera; "Prueba, última noche" / "Gratis siempre" se componen de las cadenas visibles | — |
| `ax.prueba.pista` | Toca dos veces para ver qué incluye Pro. | Double-tap to see what's in Pro. | Pista; solo fuera de `NightWindow` | — |
| `ax.nombre.pista` | Mantén para guardar o renombrar. | Hold to save or rename. | Pista del nombre, página de día | — |
| `ax.nombre.pista.noche` | Toca dos veces para volver a la página de día. | Double-tap to go back to the day page. | Pista del nombre, página nocturna | — |
| `ax.accion.guardar` | Guardar como mezcla | Save as a mix | Acción del nombre | — |
| `ax.accion.volver.dia` | Volver a la página de día | Back to the day page | Acción del nombre en la página nocturna | — |
| `ax.horizonte` | Sonido | Sound | Horizonte | — |
| `ax.horizonte.valor.bajo` / `.medio` / `.alto` | Sonando, nivel bajo / medio / alto | Playing, low / medium / high level | Valor por RMS con histéresis de 3 s (C63) | — |
| `ax.horizonte.marea` | Marea, %@, %lld por minuto | Tide, %@, %lld per minute | Horizonte con Marea; `%@` = fase (solo con voz de guía; si no, se omite) | — |
| `ax.accion.capas_separadas` | Ver capas por separado | Show layers separately | Acción del horizonte | — |
| `ax.capa` | %@, %@ | %@, %@ | Etiqueta de fila: nombre + subtítulo | — |
| `ax.capa.pista` | Desliza arriba o abajo para ajustar. | Swipe up or down to adjust. | Pista de fila (también Timbre) | — |
| `ax.accion.silenciar` / `.maximo` / `.deslizador` / `.subir` / `.bajar` | Silenciar / Máximo / Ajuste con deslizador / Subir / Bajar | Mute / Maximum / Adjust with slider / Move up / Move down | Acciones de fila; "Máximo" también anuncio al llegar a 100 | — |
| `ax.capa.pro` | %@, %@, requiere Pro | %@, %@, requires Pro | Etiqueta de fila Pro sin acceso | — |
| `ax.capa.pro.valor` | en silencio, nivel guardado %@ | silent, saved level %@ | Valor; sin nivel guardado: "en silencio" | — |
| `ax.capa.pro.pista` | Toca dos veces para ver Pro. | Double-tap to see Pro. | Pista, solo fuera de `NightWindow` (C06, C08) | — |
| `ax.accion.ver_pro` | Ver Pro | See Pro | Acción de la fila Pro (no existe de noche) | — |
| `ax.mas.pista` | Abre todas las capas. | Opens all layers. | Pista de "Todas las capas" | — |
| `ax.marea.valor` | Guiando, %lld por minuto, se retira a las %@ | Guiding, %lld per minute, recedes at %@ | Valor del toggle mientras guía | — |
| `ax.marea.off` / `ax.marea.off.pro` | Desactivada / Desactivada, requiere Pro | Off / Off, requires Pro | Valor del toggle apagado / sin acceso | — |
| `ax.marea.pista` / `ax.marea.pista.pro` | Toca dos veces para encenderla; el sonido arranca. / Toca dos veces para ver Pro. | Double-tap to turn it on; the sound starts. / Double-tap to see Pro. | Pistas del toggle | — |
| `ax.temporizador.valor` | %@, quedan %lld minutos | %@, %lld minutes left | Valor de la fila Temporizador sonando | — |
| `ax.altavoz.pista` | El volumen baja al cuarenta. | The volume drops to forty. | Pista de "Seguir por el altavoz" | — |
| `ax.reintentar` | No se ha podido iniciar el sonido. Reintentar | Couldn't start the sound. Try again | Etiqueta del botón de error | — |
| `ax.informe.pista` | Abre tu correo con el registro de la noche. Sin nombre ni identificadores. | Opens your mail with the night's log. No name or identifiers. | Pista de "Enviar informe" | — |
| `a11y.percentFormat` | %lld por ciento | %lld percent | Existe; sin cambio | — |

Claves de `main` que esta entrega deja sin uso en la página y en Capas (10 Anexo decide su destino): `app.name` (la página no enseña el nombre), `mixer.tagline`, `mixer.silent` (→ `pagina.estado.silencio`), `sound.proOnly` (→ `comun.pro`), `sound.locked`, `control.save` (el guardado vive en el menú del nombre), `control.mixes`, `trial.*` (la prueba pasa a cabecera y nota), `mixes.stripped` (→ `mezcla.nombre.sin` + `pagina.estado.sonando.sin`), `breath.oceanRaised` (→ `marea.oceano.subido`), `breath.subtitle.*`, `error.audio` (→ `pagina.error.inicio`). Claves de las revisiones 1 y 2 de esta entrega que desaparecen con la reconciliación: todas las `page.*`, `layers.*`, `layer.*`, `bar.*` y `a11y.*` propias (sustituidas por las de 10: `pagina.*`, `capas.*`, `barra.*`, `ax.*`), y en particular `page.header.free` (lista de lo gratis: C04), `page.note.night1` (C07), `page.status.listening` y `layer.listening` (C06), `page.status.paused.system` (10 no distingue), `page.status.fading.short` (C31), `page.timer.until` "Escudo nocturno" (C11), `page.tide.guiding.pro` (C06), `page.tide.ready`, `page.status.faded`, `page.status.ended` y `page.name.without.many` (§9 pendientes de E7).

---

## 6. Variantes

| Variante | Qué cambia | Qué no cambia |
|---|---|---|
| **iPhone 17 Pro (393 × 852)** | La referencia (§2). | — |
| **iPhone 16e (390 × 844)** | Horizonte en 280; columna 350; mismos renglones. | Todo. |
| **iPhone SE 3 (375 × 667)** | §2.13: horizonte 224; dos filas-control; aire entre grupos 24; banda reservada de Marea 96 [a medir]; Capas desplaza como en Large. | Tipografía, tokens, gestos, barra. |
| **Negro (oscuro; la única apariencia de 1.0, C32)** | §2. `preferredColorScheme(.dark)` en la raíz. El pomo del `Toggle` de la Marea (#FFFFFF, del sistema, no se puede teñir) es **el único blanco puro de la página**; se declara aquí para que la lista negra de blancos puros no lo cuente como propio. | — |
| **Papel (apariencia clara del sistema; 1.1, C32)** | §2.14. `negro` → `papel`; `texto` → `tinta`; `texto2` → `tinta2`; `texto3` (pistas, marcas) → `tinta3`; `índice` → `ocre` (horizonte sonando, línea bajo el dedo); toggle `.tint(tinta)`; `Slider` `.tint(tinta)`; `trazo` → `trazo-papel`; horizonte en reposo 1 pt `tinta3` (decisión E2, §2.14); Disco: `pulsado-papel` con sombra interior 1 pt `tinta` al 20 % [a medir]; pista bajo el dedo `pulsado-papel`; hoja Capas: `papel` con hairline `trazo-papel`. Nada tiene sombra exterior: el papel es mate. | Geometría, pesos, gestos, cadenas. La página nocturna es siempre negra: en la sesión nocturna se fuerza `negro` aunque el sistema esté en claro, y vuelve a papel al tocar el nombre. |
| **ES** | Las medidas de §5e están tomadas con el español, que es el idioma largo (≈ 7,6 pt por carácter en paso 7 a Large). Fila Temporizador, caso más largo: "Temporizador · Manto · hasta las 7:00" ≈ 105 + 175 = 280 pt en 353: cabe. Línea de estado más larga: "En pausa · se interrumpió el sonido" (35) ≈ 266: cabe; "En silencio · esta mezcla es Pro" (33) ≈ 250: cabe. Error: "No se ha podido iniciar el sonido. Toca para reintentar." (56) ≈ 426: dos líneas, por eso el botón es de 2 renglones (140-184). | — |
| **EN** | Más corto en todo salvo "Keep playing on speaker" (≈ 190 pt, cabe), "Playing · without ocean or thunder" (≈ 250, cabe) y la hora con "AM" / "PM": "Playing · fades at 12:42 AM" (27) ≈ 205, cabe; "Blanket · until 7:00 AM" (23) con "Timer" ≈ 50 + 175 = 225, cabe. | — |
| **Aumentar contraste** | `texto2` → `texto2-ac`, `texto3` → `texto3-ac`, `trazo` → `trazo-ac`, `índice` → `índice-ac` (asset catalog, no código); `texto-noche` e `índice-noche` usan `texto2-ac` e `índice-ac` (03 §3.1). El Disco sube su sombra interior a 2 pt. | Nada más: el sistema ya tiene margen (texto 16,56:1). |
| **Button Shapes** | El sistema subraya "Mezclas", "Noche", "Todas las capas", "Seguir por el altavoz", "Enviar informe", la cabecera de prueba (de día), la nota de una vez y la línea de estado en error (son `Button`). El nombre de la mezcla no es `Button` de día. Las filas-control no son `Button`: su alternativa visible es el `Slider` por pulsación larga y la acción "Ajuste con deslizador". El Disco ya es forma. | — |
| **Escala de grises** | Sonando: el horizonte se distingue por grosor (hasta 3 pt frente a 0,5) y luminancia (`índice` es el píxel más claro tras `texto`); bajo el dedo: la línea pasa de 2 a 3 pt y aparece la pista; pausa: hairline; Pro: palabra. Ningún estado depende del matiz. | — |
| **Filtro rojo de StandBy** | No aplica a la página (es la app, no la actividad), pero la página se diseñó para sobrevivirlo: una tinta de texto `texto` (4,43 / 4,30 bajo rojo), `índice` como forma ≥ 1,5 pt (4,71 / 5,0; de ahí el mínimo del horizonte), estado por forma y palabra. Criterio C62: ≥ 4,5:1 dentro de la app; fuera (StandBy, bloqueo) texto ≥ 24 pt y ≥ 3:1 bajo rojo medido en dispositivo (spike I0-6; plan B `texto` → `#F0ECE4`, 03 §3.1). `texto2` no se usa para nada que decida un estado. | — |
| **Reducir transparencia** | La barra pasa a opaca sola (sistema); la hoja Capas no usa materiales. | — |
| **Diferenciar sin color** | Ya cumplido: todo estado tiene forma o palabra. | — |
| **Texto en negrita** | SF escala de peso solo; nada en Light ni Bold que se rompa. | — |
| **Smart Invert** | El horizonte y la línea de agua llevan `.accessibilityIgnoresInvertColors()` (son contenido); el negro invertido es decisión del usuario. | — |
| **Reduce Motion** | Columna de §5a. | — |
| **Acceso asistido (1.1, C39)** | La página no es la superficie de Acceso asistido (lo es Noche, E4); si se abre en Acceso asistido, la barra conserva Mezclas · Disco · Noche y las filas aceptan el `Slider` por pulsación larga. | — |

---

## 7. Háptica por evento (03 §3.8; cada háptico con su anuncio de VoiceOver; puerta por fase, C35)

| Evento | iPhone | Condición | Anuncio VoiceOver |
|---|---|---|---|
| Play (Disco, página o Capas) | `.impact(.medium, 0.7)` al inicio del fundido | siempre de día (está despierto y tocando); de noche nunca (puerta por fase) | "Sonando" |
| Pausa (Disco) | `.impact(.light, 0.5)` | ídem | "En pausa" |
| Nivel: cruzar 0 (en los dos sentidos) | `.selection` | `MotionGate.allows(phase)`: nunca en la página nocturna (sin CoreMotion en 1.0, C35); nunca con "Háptica del sistema" desactivada | valor hablado |
| Nivel: llegar a 100 | `.impact(.light, 0.6)` | ídem | "Máximo" |
| Nivel: pasos intermedios | ninguna | — | — |
| Tope "Seis a la vez" (C19) | ninguna (no se cruza 0) | — | "Seis a la vez" (se lee al aparecer; lo causó el gesto) |
| Pulsación larga en fila (`Slider`) / en el horizonte (descomposición) | ninguna | — | el nombre de la acción: "Ajuste con deslizador" / "Ver capas por separado" (§9 pendiente de E7: anuncios propios) |
| Toggle de la Marea | el del sistema (`Toggle` lo trae) | — | el valor del toggle (`ax.marea.valor` / `ax.marea.off`) |
| Toque en fila Pro, apertura de la hoja Pro | **ninguna** (nunca marketing) | — | anuncio de la hoja si sube (solo fuera de `NightWindow`) |
| Error de audio al tocar Play | ninguna | — | "No se ha podido iniciar el sonido. Reintentar" (lo causó un toque) |
| Interrupción, fin de prueba, fundido, fin del temporizador, sesión terminada, retirada de la Marea | **ninguna** | — | **ninguno; se lee al enfocar** (la persona puede estar dormida: §5b) |
| Toque en la nota de una vez, cabecera, "Todas las capas", barra, "Enviar informe" | ninguna | — | — |
| Página nocturna: todo lo anterior | **nunca** (fase nocturna: está en la mesilla; vibrar es sonido) | — | igual |

Regla de silencio: en segundo plano, nada; durante cualquier fundido, nada; Capas y la página nunca usan Core Haptics (eso es de la Marea "Mínima", opt-in, E3).

---

## 8. Lo que se queda fuera y por qué

| Fuera | Por qué |
|---|---|
| El toque sobre la fila como silenciar (0 ↔ último) | Filas contiguas de 56 pt sin borde: un roce apaga la lluvia (03 §1.2). Silenciar es arrastrar a 0 o la acción "Silenciar". |
| El timbre por capa bajo pulsación larga ("más cálido ◂ ▸ más lejano") y el gesto vertical de timbre | DSP por capa que no existe (1.1, C29); el gesto muere con el eje vertical (C52). En 1.0 el timbre es la fila "Timbre" al pie de Capas sobre el bus maestro (condicionada al spike I0-7). La pulsación larga abre el `Slider` del sistema (C21). |
| La escucha de 30 s de una capa Pro | 1.1 (C06): la prueba de 7 noches ya es la demo; tocar una capa Pro abre la hoja Pro de día y no hace nada de noche. |
| La nota de una vez de la noche 1 ("Siete noches con todo…") | La prueba no arranca sola ni con Play (C07): no hay nada que anunciar hasta que la persona la empiece desde la hoja Pro. |
| Una fila de mezclas de la casa en la principal | La principal no admite una fila más (C18); las cuatro de la casa viven en Mezclas. |
| Una fila de nivel maestro en la principal | Duplica el botón de volumen (C51); el maestro es de sesión y se ajusta con el arrastre vertical de Noche; la fila visible solo existe en "Debajo de otro audio" (1.1). |
| Ranuras, huecos y el selector de textura por ranura | Sin ranuras (C19, C21): la interfaz no enseña el tope de seis; "Seis a la vez" solo aparece al intentar la séptima. |
| `AXChartDescriptor` y el rotor Audio Graph en el horizonte | El Horizonte comunica estado, no datos (C63): elemento "Sonido" con valor y acción. |
| La regla del sonido que "escribe", la banda de marcas, cualquier traza temporal, AGC, FFT | El RMS del ruido es casi plano; una traza sería mentira (03 §1.4; C53: Horizonte quieto). El horizonte es una línea quieta cuyo grosor y luz son el RMS real. |
| Iconos en la página y en el mezclador (incluidos los `symbolName` de `SoundID` y el `chevron.right` de "Todas las capas") | Las palabras son los iconos (03 §3.6). `SoundID.symbolName` queda solo para widgets, Control y Atajos (E6). La fila "Todas las capas" vive de su posición, de ser botón y de la versalita. |
| El número de capas ("11") como valor de "Todas las capas" | Es tamaño de catálogo, ambiguo junto a dos filas que suenan, y las texturas no se cuentan (C04); el valor solo existe cuando hay desbordamiento ("y 2 más"). |
| La cuenta de minutos en la fila Temporizador ("quedan 38 min", "fundiendo · 8 min") | El mismo dato dicho dos veces en dos unidades (la línea de estado ya da la hora) y la única cosa que latía en la página sin ser el sonido (03 §3.7). La fila enseña el ajuste; la cuenta vive en Noche y en la Live Activity. |
| "antes 90 · pro", "pro" o "60 min" en la fila Temporizador | El temporizador es entero libre (C03): nada que recortar ni que vender. |
| "Apagada" bajo el toggle de la Marea con acceso | El interruptor ya lo dice; etiquetar cada estado es el hábito de la categoría. Sin acceso sí: "Apagada · pro" (03 §4.7, 10). |
| "Siesta" en la fila Temporizador | 1.1 (C30). |
| La frase "Ninguna capa suena. Play empezará con rosa a 40." | La interfaz ya lo hace: renglones vacíos, "En silencio" y, al tocar Play, "Sonando · rosa a 40". Y "Play" en el copy español está en la lista negra por el mismo motivo que "timer". |
| Las causas de pausa que el sistema no da ("alarma", "otra app") | `AVAudioSession` no distingue una alarma de otra app; solo la llamada es verificable (`CXCallObserver`, C48). La línea dice "En pausa" y no adivina. |
| "Se fundió a las 0:42" / "Terminó a las 6:58" tras el fin de la sesión | 10 cierra la sesión terminada en "En silencio"; la hora del fundido vive en la Live Activity terminada (E6). E2 lo pide en §9 como pendiente de E7. |
| Hairlines entre filas-control, en 312 y en 768 | Diez líneas horizontales en 852 pt competían con la única que importa; 03 §4.2 define `LevelRule` sin hairline y la barra trae la suya. |
| Cápsulas "PRO", `lock.fill`, opacidad 0,72 en filas, tarjeta de prueba con "Entendido" relleno, `gift`, `hourglass` | Cada candado es un reproche (P9); el estado es una palabra en versalitas (C64: no hay cápsulas). |
| Título de app y subtítulo "Para la noche" | No informa a quien ya abrió la app (P5). |
| Cápsula "Prueba · 7 días" y botón "Pro" permanente en la cabecera | Badge y venta permanente en el sitio del lujo; la prueba es una versalita y desaparece. |
| Fondo `NightBackground` con degradado y resplandor | No es negro, cuesta GPU, no tiene causa (P3, P4). |
| "Guardar" en la barra | El guardado vive en el menú del nombre (03 §5 #13); la barra es Mezclas · Disco · Noche. |
| El Play de 76-88 pt relleno de ámbar; el Play trazado de 1,5 pt | El Disco de 44 pt en `grafito` con glifo `texto` es el único botón con física (03 §4.4); nunca lleva color. |
| Colocar el valor "flotando" junto al dedo | Tapa el nombre y rompe el orden de lectura (Dial); el valor crece en su sitio. |
| Que lo de debajo baje 96 pt cuando la Marea abre su banda (Grafito M6), o que la banda crezca | Nada cambia de posición ni de tamaño (03 §3.5, §3.7): la banda de 120 está reservada desde que la mezcla tiene Marea disponible. |
| Doble toque, arrastre vertical, dos dedos, pellizco en la página | Lista de 03 §6 y C27; la página tiene un gesto (arrastre horizontal en fila) y pulsaciones largas con alternativa. |
| Un "y 2 más" como fila propia de 80 pt | No cabe con tres filas en 852 sin scroll; va como valor de "Todas las capas", que es su destino. |
| Mostrar la receta de la mezcla bajo el nombre | Es de Mezclas (E5); la página ya enseña las capas como filas. |
| Spinner, alerta modal, rojo de error | 03 §3.1: `error` no existe; la línea de estado es el botón. |
| Hoja Pro al cargar una mezcla recortada (`mixes.stripped` de `main`), también una de la casa | El nombre honesto y "Sonando · sin trueno" lo dicen sin interponerse (P9; C18). |
| Hoja Pro dentro de `NightWindow` o en la página nocturna; "línea matinal" | Nada vende de noche y no hay recordatorio por la mañana (C08). |
| Salida de la página nocturna por reloj (07:00) | Un reloj que cambia la pantalla mientras la miras (C40); la salida es el toque en el nombre. |
| Modo claro (Papel) en 1.0 | 1.1 (C32); 1.0 es solo oscura. |
| Marea por textura, Retirada de Manto, fundido por quietud, micrófono, Watch, Focus de Sueño | Fuera de 1.0 o de esta entrega (reconciliación §5: 1.1, 1.1, 1.2, —, 1.2, 1.1). |

---

## 9. Preguntas abiertas y cambios a `main`

Las preguntas que la reconciliación o 03 consolidado cierran se marcan "cerrada por …" y salen de la lista abierta; se conservan numeradas para que las referencias de §2-§8 y §11 sigan valiendo.

**Decisiones E2 (razonadas en el texto; se listan para que el dueño las vea):**
1. **Sin chevron ni número en "Todas las capas"** (03 §3.6: cero iconos fuera de la barra; C04: no se cuentan texturas). La fila vive de su posición, del valor "y 2 más" cuando desborda, de Button Shapes y de VoiceOver ("botón").
2. **El toque en el nombre no hace nada de día**; solo la pulsación larga tiene menú. Dos objetivos sin borde pegados (cabecera 52-96 y nombre 96-140) no caben con 24 de aire (03 §3.5), y la barra ya entra en Mezclas. En la página nocturna, el toque devuelve a la página de día (03 §3.2, C40).
3. *Cerrada por 03 §4.2 consolidado (03 §12):* el `Slider` por pulsación larga sustituye a la línea en su sitio, en `.tint(texto)`, y se retira a los 5 s. Duración 0,6 s (`Grid.longPress`, una sola para fila, horizonte y Noche; 03 §4.2, 04 §2.0.3): E2 proponía 0,8 s y lo retira para no tener dos duraciones de pulsación larga en la app.
4. *Cerrada por 03 §4.10 consolidado:* Capas es la única hoja sobre `negro`, con hairlines `trazo`.
5. **Notas de Capas en paso 7, no en 8** (`capas.nota` y `capas.cero`): un estilo menos en la hoja (5 en total); 10 las anota en paso 8 por defecto y E2 fija el paso (03 §3.4 manda en estilos). Pendiente de E7 solo como nota de contexto.
6. **Fila "Timbre": una palabra en el sitio del valor, línea bipolar desde el centro.** 10 §2.2 dibuja "Grave ━━━━┄ Lejos" flanqueando una línea corta; 03 §4.2 fija la línea de `LevelRule` de margen a margen, así que E2 pone la palabra del extremo hacia el que se inclina ("Grave" / "Lejos") donde iría el valor, y nada en el centro. Mismas cadenas, misma clave.
7. *Cerrada por C08 y C40:* nada vende dentro de `NightWindow` (21:00–07:00) ni en la página nocturna; sin línea matinal.
8. **La fila Temporizador enseña el ajuste, nunca la cuenta.** La hora de apagado vive en la línea de estado; nada late por minuto en la página.
9. **Subtítulo vacío con la Marea apagada o armada y con acceso**; `marea.estado.apagada.pro` "Apagada · pro" solo para el gratuito (03 §4.7); mientras guía, versalitas + hora en paso 7 como dos `Text` con dos claves (03 §4.3 y §3.4). `marea.estado.apagada.fila` ("Apagada") queda sin uso en la página: pendiente de E7.
10. *Cerrada por C40:* página nocturna por procedencia (al volver de Noche), dura la sesión, sin salida por reloj.
11. **Orden de las filas en la página: camas primero** (Lluvia, Viento, Ventilador, Océano, Trueno, …) y después colores; Capas conserva colores / camas con las dos camas libres primero. **Sigue abierta para el dueño.** Afecta a la captura 2 ("Un toque y suena.", E8) y al primer uso ("Lluvia 30 · Rosa 50" en la página).
12. *Cerrada por 03 §3.1 regla 2 y §4.12 consolidados (03 §12):* el Toggle de la Marea va en `.tint(texto)`; el toggle *on* se lee por la posición del pomo (P7); se retira la exención del `IndexArbiter` y los conteos de §2.2 y §3 ya no cuentan un segundo índice. Coincide con la recomendación del jurado de restricción (§11 #9).
13. *Cerrada por C40:* la página nocturna no depende de la hora sino de la procedencia; una apertura sin haber pasado por Noche nace en la página de día.
14. *Cerrada por 03 §12:* la salida de la página nocturna es el toque en el nombre (la pulsación larga del nombre ya es el menú Guardar/renombrar).
15. *Cerrada por C39 y reconciliación §3:* "Esta noche" / "Tonight" es el nombre de la mezcla viva sin guardar; no es una pantalla. 10 §2.1 dibuja un nombre automático ("Rosa y lluvia", `pagina.capas.y`): pendiente de E7 alinear 10 con §3 y dar clave propia al nombre vivo (aquí se cita `mezcla.nombre.vacio`, que ya vale "Esta noche").
16. **La nota de una vez es un botón sin "Entendido" visible** (el texto entero cierra; "Entendido" es la acción de VoiceOver, `comun.entendido`). 10 §2.1 y 08 dibujan un `TextAction` "Entendido" de 44 bajo el párrafo; no cabe en 852 sin mover el horizonte. **Sigue abierta para el dueño:** ¿vale, o prefieres el botón y el horizonte cediendo 16 pt solo esa noche?
17. **Mezcla por defecto del primer uso**: Rosa 50 · Lluvia 30, con nombre "Esta noche" (03 §5 #16: "receta de 05"). `main` arranca con Rosa 65 sola. Hay que cambiar `defaultLevels()`; **¿se confirma la receta?** (08 dibuja la misma receta con el nombre "Rosa y lluvia"; el nombre lo fija §3 de la reconciliación.)
18. *Cerrada por reconciliación §1 regla 3 y C09:* `freeSavedMixLimit` 1 → 3 y las mezclas guardadas se conservan; la nota de la noche 7 es `prueba.ultima` de 10 y ya no afirma nada sobre las mezclas.
19. **Para E4/E6**: ¿mantener la sesión de audio activa (y el proceso vivo) durante los 20 min de pausa compensa la batería? Sin ello, la reconexión de auriculares en segundo plano no reanuda sola y el fin de sesión se evalúa al volver (§4.3). 10 §4.6 lo anota como limitación escrita; sigue abierta.

**Para los spikes (I0):**
20. **[I0-1]** Medidor RMS maestro y por capa a 20 Hz con τ 500 ms, y el mapeo −40 / −6 dBFS → 0 / 1 que propone §2.2: hay que medirlo con las once texturas reales y fijar los dos extremos para que la lluvia "respire" y el rosa "quede casi quieto" sin AGC. El medidor acumula por búfer, no por muestra, y solo con `EngineCommand.metering == true` (§5a): con la pantalla apagada el hilo de audio no mide. Además, bypass real de las capas a 0 en el render (`capas.cero`) y el `master` con rampa en `EngineCommand` (C51).
21. **[I0-2]** El arrastre de §2.6 en dispositivo: `minimumDistance: 8` y 30° dentro de un `ScrollView` de SwiftUI con `simultaneousGesture` o `UIGestureRecognizer` propio; la prueba de aceptación está en §2.6 e incluye la página en xxxLarge. Si el 30° pelea con el scroll de iOS 26, probar 25° antes de subir `minimumDistance`. Incluye la cancelación del `Slider` por arrastre (caso 23) y decide si la página nocturna necesita el umbral distinto que 04 §2.2 propone (16 pt, 20°): E2 prefiere una sola regla.
22. *Cerrada por C49:* el `pauseCommand` con auriculares es un fundido de 3 s y "En pausa · AirPods"; queda solo [a medir] si iOS lo distingue de otro `pauseCommand`; si no, "En pausa".
23. *Cerrada por C35:* sin CoreMotion en 1.0; la puerta de la háptica es por fase (de noche nunca vibra); el spike I0-5 queda como investigación.
24. **[a medir]** Banda reservada de la Marea en SE (96 pt, frente a los 120 de 03 §3.5 y 04) y la posición del horizonte en 667 (224): comprobar en dispositivo que la línea de agua no pisa la línea 2. Altura real del detent `.large` de Capas por dispositivo e iOS (§2.7). Las medidas de ancho de §6.
25. **[I0-7]** Timbre en el bus maestro (C29): si el spike no llega o la puerta de la semana 4–6 lo tumba, la fila "Timbre" de §2.7 cae a 1.1 sin cambiar nada más (la hairline de 1044 desaparece con ella).

**Cambios a `main` que la página necesita (modelo):**
26. **Reparto y catálogo.** `AccessPolicy.freeSavedMixLimit` 1 → 3; `freeTimerMinutes` desaparece (C03); `.wind` en `SoundID` y en la rama libre de `soundIsIncluded` (C04), declarado tras `.rain` en `allCases` para que las dos camas libres vayan primero en Capas (§2.7); `SavedMix` con `version: 2` sobre los pares id+nivel que ya guarda (C20); `MixerModel.setLevel` sobre una capa Pro sin acceso abre la hoja Pro de día y no hace nada en `NightWindow` (sin `preview(sound:)`: C06); `startTrialIfNeeded()` sale de `play()` y pasa a `startTrial()` desde la hoja Pro, con el estado en Keychain (C07); tope de seis capas simultáneas como regla de modelo (C19); `master` con rampa en `EngineCommand` (C51).
27. **`play()` eleva `pink` a 0,4 si `isSilent`** y lo persiste sin tocar `loadedMixName` (hoy no lo hace). `UserDefaults` `sleepnoise.freeSessions.v1` para la cabecera "gratis siempre" (7 sesiones); `sleepnoise.note.night7/8.v1` para las notas de una vez; `sleepnoise.nightSession.v1` para la página nocturna por procedencia (sin hora); `outputLatency` sumada al ancla en el `TimelineView` de la línea de agua; `Date` de la pausa para evaluar los 20 min al volver. `NightWindow.contains(Date)` como única constante horaria (C40).
28. **`SleepAudioEngine.defaultFadeIn`**: 1,5 s lineal → 0,8 s `.easeOut`, como fija 03 §3.7 y ya adopta 04 §0 (7); el horizonte lee la ganancia real, así que no miente en ningún caso.
29. **`SleepTimerController` debe dejar el tick de 0,25 s** (`startTicking()` dispara un `Timer` a 4 Hz en `.common` toda la noche, también bloqueado: la actividad periódica que 03 §3.7 prohíbe). Un `Timer` de un disparo en el próximo límite de minuto (tolerancia 2 s) mientras la escena está activa y Noche lo necesita; ninguno con la pantalla apagada; la cuenta y el fundido se calculan desde `endDate`, y el fundido se programa como un solo `Timer(fire:)` igual que `BreathingGuideController.schedule(at:)`. La página no necesita ningún tick: la fila enseña el ajuste y la línea de estado, una hora. El fundido de 10–15 min con cuenta entera de muestras es C31.
30. **`AudioSessionObserver.handleInterruption`** debe consultar `CXCallObserver` para distinguir "llamada" (C48) y aplicar la ventana de la mañana (05:00–11:00 o fin de Manto −60 min): dentro ninguna interrupción reanuda; fuera, todas con fundido de 3 s.
31. **Marea tras una pausa corta**: si E3 quiere que el Disco reanude conservando la ventana (`resume()`), es un cambio a `MixerModel.play(userInitiated:)`, que hoy llama a `begin()`. Encender el toggle debe arrancar el sonido si no sonaba (10 §2.1).
32. **Pendiente de E7 (cadenas que E2 necesita y 10 no tiene; aquí se usa la redacción más cercana de 10):** (a) un estado tras el fin de la sesión que diga la hora ("Se fundió a las 0:42" / "Terminó a las 6:58"): 10 lo deja en "En silencio"; (b) nombre recortado con dos o más capas que faltan en una forma corta ("Mar y viento · sin 2 capas"): aquí se compone con `pagina.capas.ni` y se trunca; (c) valor de fila a 0 "a cero" (aquí "0 por ciento"); (d) "Todas las capas, y dos más" como etiqueta única (aquí etiqueta + valor); (e) valor del toggle de Marea armada sin sonar (aquí el valor del sistema); (f) anuncios propios "Deslizador" / "Capas por separado" (aquí el nombre de la acción); (g) valor "centrado" de la fila Timbre; (h) una pista para "Noche" en la barra ("La pantalla puede apagarse; el sonido sigue."): aquí sin pista; (i) clave propia para la pista del Disco "Suena en un segundo." (10 §5b la cita sin clave); (j) clave propia para el nombre de la mezcla viva "Esta noche" (#15); (k) `pagina.estado.sonando.sin.marea` no aplica a la página: el formato v2 no guarda Marea (C20); (l) `marea.estado.apagada.fila` sin uso (#9); (m) la regla de anuncios de §5b (solo lo que causa un toque) frente a "anuncio al cambiar" de 10 §5b. Para E7 también: las once parejas nombre · subtítulo de §5e son las de 10 §5e.4 (`capas.{id}.detalle`). Para E5: la nota de una vez tiene 135 caracteres de techo y es un botón. Para E3: el subtítulo de la fila Marea usa `marea.estado.guiando.corto`, `marea.retira.hora`, `marea.oceano.subido`, `marea.estado.disolviendo` y `marea.retirada`, no las `breath.subtitle.*` de `main`. Para E6: la regla "nada vende de noche" es `NightWindow` (C40) y no hay línea matinal (C08).
