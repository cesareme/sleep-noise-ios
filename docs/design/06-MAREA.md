# SleepNoise · 06 · Marea

**Equipo E3 · Marea · 16 de noviembre de 2026 · Documento 06 de la serie de diseño (fase de especificación) · revisión tras la puerta 2 (cinco jurados; respuestas en §11) · reconciliación producto–diseño del 16-11-2026 aplicada (§12)**

Cubre las pantallas **6** (Marea, hoja `.large`, 1.0: profundidad común `bedDepth` sobre todas las camas + ritual Descenso + toggle; Pro, y para todos en Madrugada) y **7** (Marea: gestos por textura, 1.1; Salud, 2.0) del inventario de `03-DIRECCION-DE-DISENO-2026-11-16.md` §5, más los tres lugares donde la Marea aparece sin ser una pantalla propia: la línea de agua en la página (E2), la Marea en Madrugada (E4) y el estado "guiando" de la Live Activity (E6). Donde este documento toca una superficie de otro equipo, da solo lo que la Marea pone en ella y remite al documento de ese equipo para la geometría.

**Insumos leídos completos, en este orden:** `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§0-§6: manda sobre 03 y sobre el plan; sus deltas para 06 están en §12); `03-DIRECCION-DE-DISENO-2026-11-16.md` consolidado (§3 tokens, §4 componentes, §5 inventario y §8.3 puertas son ley aquí); `04-SISTEMA-FUNDAMENTOS.md` (nombres de componentes y medidas); `10-GUIA-DE-COPY.md` (§0.2 glosario, §2.3, §5b, §5e.5, §5e.16, §5e.17: toda cadena de interfaz de este documento coincide letra a letra con la guía; lo que la guía no tiene está en §9 como pendiente de E7); el brief del director creativo para E3; `tokens.md`, `grafts.md` y `decisions.md` de la sesión; `00-BRIEF-CREATIVO-2026-11-16.md` (P1-P12, listas negras §7.1 y §7.2); `02-MATERIALES-2026-11-16.md` (paleta medida, tipografía, movimiento §3, háptica §4, accesibilidad §7); `concepts/marea.md` entero y, por grep, las secciones de Marea de `grafito.md`, `dial.md` y `silencio.md`; el código de `main` que afecta a la Marea (`Model/AccessPolicy.swift`, `Model/SoundID.swift`, `Features/Mixer/MixerModel.swift`, `Features/Breathing/BreathingGuideController.swift`, `Features/Breathing/BreathingCard.swift`, `Audio/DSP/Breath.swift`, `Features/Timer/SleepTimerController.swift`, `Features/Library/SavedMix.swift`, `Features/Paywall/PaywallView.swift`, `Resources/Localizable.xcstrings`); `docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md` §1 y §5.2; `docs/REVIEW-PR3-2026-11-16.md`; las cinco listas de la puerta 2.

**Convenciones.** Medidas en puntos para 393 × 852 (iPhone 17 Pro) en tamaño Large de Dynamic Type; la hoja se cota desde su propio borde superior (y = 0 es el borde de la hoja, no de la pantalla). Colores solo por su **token** de 03 §3; este documento no escribe ningún hex. Textos de interfaz en español con el inglés entre corchetes; son definitivos, son los de `10-GUIA-DE-COPY.md` y son los que se compilan (§5e, con las claves de 10; las claves `breath.*` de `main` se renombran como dice el Anexo de 10). Lo no verificado en dispositivo lleva **[a medir]**; lo que depende de un cambio de ingeniería lleva **[spike I0-n]**: los spikes de la semana 2 son los de la reconciliación C45 (I0-2 umbral LevelRule, I0-3 intents, I0-5/I0-5b quietud y háptica como investigación, I0-6 contraste bajo rojo, I0-7 timbre en bus); el paquete de cambios de `main` que esta especificación necesita se propone como **I0-8 · Marea** (§9; antes se llamaba I0-7 en este documento y colisionaba con el timbre). Los pasos tipográficos son los de la escala de nueve de 03 §3.4 (paso 1 Cifra … paso 9 Dato). "La hoja" es la pantalla 6; "la página" es la principal de E2; "Noche" y "Madrugada" son las de E4; "la barra" es la de 03 §4.11. "De noche" es la fase Noche, Madrugada o la página nocturna (estado de tinta por procedencia: al volver de Noche, dura la sesión; C40); `NightWindow` es la única constante horaria de la app, 21:00-07:00, y rige tips, venta y reseña (C40, regla 7 de la reconciliación).

**Lo que este documento hereda sin discutir (03 §1.3, §4.3 y §4.12, reconciliación §3-§4):** la línea de agua como forma de la Marea (toggle + línea; nunca un círculo; C59), indicador y control a la vez; `hoja` y `trazo-hoja`; "Se ha retirado. El mar sigue."; la regla de que la Marea nunca apaga una capa que ella encendió; la Marea Pro en 1.0 y para todos en Madrugada (receta fija, C05); el toggle del sistema con `.tint(texto)` (03 §4.12: ningún control del sistema lleva el acento; un índice por pantalla sin excepciones); el estado por palabra (03 §4.8: "guiando", "disolviendo", "en pausa", "pro"); "Descenso" reservado al ritual de la Marea (C14); "v1/v2", "Oleaje/Swell" y "solo oleaje" no se graban ni son estados (C24, C59); el formato obligatorio de las cinco tablas.

---

## 1. Intención

**P10: una pantalla, una pregunta.** Cada superficie de este documento responde a una sola.

| # | Superficie | V | Pregunta a la que responde | Lo que **no** responde (y quién sí) |
|---|---|---|---|---|
| 6 | **Marea** (hoja `.large`) | 1.0 | **"¿Cómo respiro?"** La línea de agua enseña el ritmo sin cifras, la mano lo ajusta sobre la propia línea, y la frase dice lo único que hay que saber: inhala cuando sube, exhala cuando se retira, no hace falta mirar. El ritual Descenso (bajada de 12 a 6 por minuto, meseta, disolución; C14, C24) es una fila con toggle de la misma hoja. | "¿Qué suena?" (E2, la página: también "Océano subido a 40"); "¿cuándo se apaga?" (E4, Temporizador); "¿cuánto cuesta?" (E5, hoja Pro: se abre desde el toggle sin acceso, nunca dentro de la hoja Marea, y nunca entre las 21:00 y las 07:00). |
| 7 | **Marea: gestos por textura** (el mismo motor, 1.1) · **Salud** (2.0) | 1.1 / 2.0 | 1.1: **"¿Respira cada textura a su manera?"** Modulación por textura (nivel y filtro por textura: parámetros nuevos en `RenderState`, C24); en la hoja no cambia nada visible. 2.0: "¿Puede empezar donde estoy yo?" (opción "Mi ritmo nocturno · según Salud" en el menú Ritmo, C34). | La hoja de 1.0 ya tiene el sitio de cada cosa (§2.6): no se rediseña, se destapa. |
| — | La línea de agua **en la página** | 1.0 | No es una pantalla: es la respuesta a "¿esto se está fabricando ahora?" de E2 cuando la Marea guía. | Geometría de la página: E2 (`05-PAGINA-Y-CAPAS.md`). Aquí: §2.4. |
| — | La Marea **en Madrugada** | 1.0 | No es una pantalla: es parte de "¿puedo volver a dormirme sin pensar?" de E4. Receta fija: océano a nivel bajo con Marea a 8 por minuto para todos, sin control (C05). | Geometría de Madrugada: E4 (`07-TEMPORIZADOR-NOCHE-MADRUGADA.md`). Aquí: §2.5. |
| — | "guiando" **en la Live Activity** | 1.0 (escenario A) / 1.1 (B) | Una palabra en una superficie de E6 (Live Activity recortada, C25; estado "guiando (Marea)", C50). | Todo lo demás: E6 (`09-ECOSISTEMA.md`). Aquí: §5e, `marea.estado.guiando.corto` compartida con la extensión. |

**Lo que la Marea debe comunicar** (00 §6): "El mar respira más despacio y yo con él, y después se retira". Tres pruebas de que lo comunica sin texto: (1) a tres metros, en la hoja solo se mueve una línea, y se mueve a la velocidad a la que suena el oleaje; (2) el dedo cambia el ritmo sobre esa misma línea, no en un control aparte; (3) el final no es un corte: la línea pierde altura ciclo a ciclo y el mar sigue.

**Lo que resuelve del PR #3 y de `main`** (REVIEW-PR3 "Encaje" y hallazgos): la Marea vivía en una tarjeta con radio 18, icono-disco ámbar que crecía y encogía (un círculo: el código de Apple Breathe), cápsula "PRO" con `lock.fill` y opacidad 0,72 para el gratuito, y una hoja con stepper "6 por minuto", rejilla de cinco botones rellenos y botón "Cerrar" (P11 violado: lo técnico encima del gesto; P6 y P9 violados). En el PR #3 la Marea quedó además enterrada en la hoja "Niveles" a ~270 pt del primer deslizador. Aquí: una línea, un toggle del sistema, dos nombres humanos para el ritmo, un ritual con nombre, y el ajuste exacto solo bajo pulsación larga.

**Reparto (reconciliación §4).** Marea (profundidad común + ritual + toggle + línea de agua + háptica Mínima opt-in): Pro, 1.0. Marea en Madrugada (receta fija, 8/min): para todos, 1.0. Gestos por textura: Pro, 1.1. Háptica "Marcada": Watch, 1.2 (C35). Salud: 2.0 (C34). Encender la Marea sin acceso es una "primera acción Pro" (C07): abre la hoja Pro con "Empezar la prueba · 7 noches" / "Comprar · {displayPrice}" de día; entre las 21:00 y las 07:00 no abre nada (C06, C08). Sin escucha de 30 s en 1.0 (C06; en 1.1, cuando llegue, no abrirá hoja sola).

---

## 2. Anatomía

### 2.1 La hoja en reposo (toggle apagado, nada suena o suena sin Marea)

`.sheet` del sistema, `presentationDetents([.large])`, `presentationBackground(hoja)` (de noche, `negro`: §3.13), `presentationDragIndicator(.visible)`, **sin botón Cerrar** (03 §4.10). Cabecera paso 3 a la izquierda a 20 pt. La hoja se abre desde la fila "Marea" de la página (toque en el nombre o en el subtítulo; el toggle de esa fila enciende sin abrir nada, §4.1). Altura visible de la hoja en 393 × 852: ≈ 808 pt **[a medir]**; en 375 × 667 (SE): ≈ 647 **[a medir]**. El contenido mide **752 pt en ES (732-752 en EN, según la nota de Háptica ocupe una o dos líneas [a medir])** y cabe sin desplazamiento en 17 Pro en Large; en SE aparece `ScrollView` desde Large (§5d, §6).

Tres grupos a 32 pt (03 §3.5: grupos a 32, el doble del aire interno de 16): la banda (termina en y 200), el texto (232-380) y las filas (desde 412). Dentro de cada grupo, 4 y 16. Filas de 56 (03 §3.5: lista 56); la fila Descenso lleva subtítulo y mide 72 (03 §3.5: fila con subtítulo 72).

```
 x:   0   20                                            373   393
 y    ┌─────────────────────────────────────────────────────────┐
  0   │                    ══ indicador ══                      │  sistema, 0-20
      │                                                         │
 24   │  Marea                                           pro    │  paso 3 · texto · (versalita "pro" solo bloqueado-Pro)
 52   │                                                         │
 64   │  ─────────────────────────────────────────────────────  │  hairline trazo-hoja, x 20→373
      │                                                         │
 80   │                                                         │  (aquí nace la marca de pleamar al encender; en reposo, nada)
      │                 (banda 120 · en reposo nada se dibuja   │
      │                  salvo la hairline en bajamar)          │
      │                                                         │
 200  │  ═══════════════════════════════════════════════        │  línea de agua en bajamar · hairline trazo-hoja (apagada) · sin marcas
      │                                                         │
 232  │                                                         │  caja de la palabra de estado (232-252) · vacía en reposo
 256  │                                                         │  caja de la línea de retirada (256-276) · vacía en reposo
      │                                                         │
 292  │  Inhala mientras la ola sube, exhala mientras se        │  paso 7 · texto2 · 2 líneas (la frase conservada)
 312  │  retira. No hace falta mirar la pantalla.               │
 332  │                                                         │
 336  │  Qué sabemos ›                                          │  TextAction · 17 Regular · texto2 · 44 pt de alto (336-380); el chevron es tipográfico
 380  │                                                         │
 412  │  ─────────────────────────────────────────────────────  │  hairline trazo-hoja (32 bajo el enlace)
 412  │  Marea                                         ( ◯ )    │  fila 56 · paso 5 texto · Toggle del sistema .tint(texto) (off)
 468  │  ─────────────────────────────────────────────────────  │
 468  │  Ritmo                                  Tranquilo · 6 ⌃⌄│  fila 56 · paso 5 · valor paso 6 texto2 · Picker .menu
 524  │  ─────────────────────────────────────────────────────  │
 524  │  Descenso                                      ( ◯ )    │  fila 72 · paso 5 · Toggle del sistema .tint(texto) (off)
 548  │  Empezar a 12 por minuto                                │  subtítulo paso 7 texto2
 596  │  ─────────────────────────────────────────────────────  │
 596  │  Se retira a los                              15 min ⌃⌄ │  fila 56 · idem Ritmo
 652  │  ─────────────────────────────────────────────────────  │
 652  │  Háptica                                     Ninguna ⌃⌄ │  fila 56 · idem (no se muestra sin motor háptico, §2.2)
 708  │  ─────────────────────────────────────────────────────  │  hairline trazo-hoja
 712  │  Tres a cinco respiraciones al empezar. De noche        │  paso 7 · texto2 · 2 líneas (nota de Háptica, §2.2)
 732  │  nunca vibra.                                           │
 752  │                                                         │
      │                        (aire)                           │
 808  └─────────────────────────────────────────────────────────┘
```

**Tabla de capas (reposo).**

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Indicador de arrastre | sistema | sistema | sistema | Arrastrar cierra; en iOS 26 el sistema no añade un botón Cerrar (03 §4.10). |
| Cabecera "Marea" ["Tide"] (`marea.titulo`) | 3 · Cabecera, Semibold 22/28 (Medium de noche) | `texto` | x 20, caja y 24-52 | Estática. Es el título de la hoja; no se repite el nombre de la app; "Breathing tide" solo en prosa de ficha (C15). `accessibilityAddTraits(.isHeader)`. |
| Versalita "pro" (solo bloqueado-Pro) | 9 · Dato versalitas, tracking +2 % | `texto2` | alineada a la derecha a x 373, misma línea base que la cabecera | Solo existe para el usuario gratuito tras la prueba (§3.5). Nunca cápsula, nunca candado (03 §4.7: "pro" en versalitas). |
| Hairline de cabecera | — | `trazo-hoja` | 0,5 pt (`1 / displayScale`), x 20→373, y 64 | Único separador. |
| Marcas de pleamar y bajamar | — | `texto3` | hairline, x 349→373, y 80 y y 200 | **Solo guiando, disolviendo y en pausa** (M16): nacen con la línea (M4) y se van con ella (M5). En reposo no existen: una marca de bajamar coincidiría con la hairline apagada y la de pleamar quedaría huérfana en 120 pt de vacío. 03 §4.3 dice "entre dos marcas" para la línea que recorre la banda; en reposo no hay recorrido que marcar (razonado para la puerta 2). 24 pt para que la banda no se lea como una caja (P6). |
| **Línea de agua** (`TideLine`, 03 §4.3 / 04 §2.3) apagada | — | `trazo-hoja` | hairline, x 20→373, y 200 (bajamar) | No respira. Es el silencio dibujado: en la tienda es verdad. **Apagada no es control**: no acepta el arrastre (sin señal del motor no hay nada que mover ni con qué responder, P4; el ritmo se elige en la fila Ritmo o sobre la línea cuando guía). |
| Caja de la palabra de estado (`StateWord`, 03 §4.8) | 9 · Dato versalitas | `texto2` | x 20, caja y 232-252 | **Vacía en reposo**: el estado apagado se lee por forma (hairline quieta en bajamar + toggle off, P7; 03 §4.8 no lista "apagada"). Se llena con "empieza al reproducir", "guiando · 6 por minuto", "disolviendo", "en pausa" (§3). Cambia por hito, nunca por reloj. La caja existe siempre: nada cambia de posición (03 §3.7). VoiceOver sí dice "apagada" (`marea.estado.apagada`, §5b). |
| Caja de la línea de retirada | 7 · Secundario 15/20 | `texto2` | x 20, caja y 256-276, 1 línea | **Vacía en reposo y armada**: solo existe cuando dice algo que las filas no dicen: "Se retira a las 23:27" (guiando, disolviendo, en pausa), 10 s "Se ha retirado. El mar sigue." tras la retirada natural, o la cadena del error de audio de E2 (§3.10). |
| La frase (`marea.instruccion`) | 7 · Secundario 15/20 | `texto2` | x 20→373, y 292-332, 2 líneas (ES) | La que ya existe en `main` (`breath.hint`), conservada en español letra por letra; EN el de 10. |
| Enlace a la evidencia (`sabemos.enlace`) | TextAction (03 §4.9): 17 Regular (Medium de noche) | `texto2` | x 20, alto 44, y 336-380; texto alineado a la izquierda | "Qué sabemos ›" ["What we know ›"]: la cadena de 10 (§5e.5; el chevron es tipográfico, no un glifo); la pantalla de destino se titula "Qué sabemos" (03 §5 fila 17; reconciliación §3) y es de E5+E7. 13 caracteres: 1 línea en 353 y en 335. Empuja la pantalla de E5 **dentro de la hoja no**: cierra la hoja y empuja desde la página (la lectura larga no vive en una hoja). La redacción anterior de este documento ("Por qué seis por minuto") queda en §9 como pendiente de E7. |
| Hairline | — | `trazo-hoja` | y 412 | — |
| Fila **Marea** ["Tide"] (`marea.toggle`) | 5 · Fila 17/22 Semibold | `texto` | 56 pt, y 412-468; toggle a la derecha, centrado verticalmente, borde a x 373 | `Toggle` del sistema, `.tint(texto)` (03 §4.12: nunca `índice`; el estado *on* se lee por la posición del pomo, P7). Encender = §4.1. |
| Fila **Ritmo** ["Pace"] (`marea.ritmo.fila`) | 5 | nombre `texto`; valor paso 6 `texto2` | 56 pt, y 468-524 | Valor a la derecha en paso 6 `texto2` (lo que el `Picker .menu` del sistema hace solo dentro de un `List`; el valor es secundario, 03 §4.7): "Tranquilo · 6" ["Calm · 6"] / "Suave · 8" ["Gentle · 8"] (`marea.ritmo.tranquilo.corto` / `.suave.corto`) / "5 por minuto" ["5 per minute"] (`marea.ritmo.exacto`) cuando el valor no tiene nombre. El menú muestra "Tranquilo · 6 por minuto", "Suave · 8 por minuto" (`marea.ritmo.tranquilo` / `.suave`) con el `checkmark` del sistema en `texto`; chevron `.tint(texto2)`. Nada cambia de posición (03 §3.7). En 2.0 el menú gana "Mi ritmo nocturno" (Salud, §2.6). |
| Fila **Descenso** ["Descent"] (`marea.descenso`) con subtítulo "Empezar a 12 por minuto" ["Start at 12 a minute"] (`marea.ritmo`) | 5 + 7 | nombre `texto`; subtítulo `texto2` | 72 pt, y 524-596; toggle a la derecha centrado en el renglón del nombre | **El ritual de la Marea (C14, C24), 1.0:** con el toggle *on*, la guía arranca a 12 por minuto y **baja un entero cada 40 s** hasta el ritmo de la fila Ritmo (de 12 a 6: cuatro minutos), se queda ahí (meseta) y disuelve como siempre (§3.7). El ritmo de partida es un **parámetro fijo**, 12, nunca Salud en 1.0 ni 1.1 (C34): el subtítulo lo dice tal cual y no cambia. Toggle del sistema `.tint(texto)`. Apagado (por defecto), la guía arranca al ritmo de la fila Ritmo. "Descenso" no se usa para ninguna otra cosa (la fase horaria es Día / Noche, interna; C14). |
| Fila **Se retira a los** ["Recedes after"] (`marea.retira`) | 5 | idem Ritmo | 56 pt, y 596-652 | Valor "15 min" (`marea.retira.valor`); menú 5 · 10 · 15 · 20 · 30 min. Cambia el fin de la ventana si la Marea está guiando (§4.2). |
| Fila **Háptica** ["Haptics"] (`marea.haptica`) | 5 | idem | 56 pt, y 652-708 | §2.2. Fila directa, sin desplegable (razón en §2.2 y §11.3). Si `CHHapticEngine.capabilitiesForHardware().supportsHaptics == false` (iPad), la fila y su nota **no se muestran** y la hoja termina en la hairline de y 652 (03 §4.7: deshabilitada se oculta si < 18 pt). |
| Hairline | — | `trazo-hoja` | y 708 | — |
| Nota de Háptica (`marea.haptica.nota`) | 7 · Secundario 15/20 | `texto2` | x 20→373, y 712-752 (2 líneas ES; EN 1-2 líneas **[a medir]**) | §2.2. Va en paso 7, el de la frase, no en paso 8: así la hoja usa cinco pasos (conteo abajo). |
| Fila **Ritmo exacto** (solo asistencia) | 5 | `texto` | 56 pt bajo la última hairline | Fila fija con el `Slider` de 44 pt (1.0) cuando Switch Control, AssistiveTouch, "Botones de accesibilidad" o Button Shapes están activos (§5c). No existe en otro caso. |

**Tinte de los controles del sistema.** La hoja no tiene acento en reposo ni guiando: los dos toggles van en `.tint(texto)` (03 §4.12), el `Slider` de pulsación larga en `.tint(texto)` (03 §4.2), los chevrons del `Picker .menu` en `.tint(texto2)` y el `checkmark` del menú en `texto`. La raíz de la app ya lleva `.tint(texto)` (04 §2.0.4): ningún control hereda `AccentColor`. El único acento posible de la hoja es la línea de agua **bajo el dedo** (`índice`; §2.3).

**Conteos** (00 §8 y 03 §8.3). Estilos de texto en la hoja: pasos **3, 5, 6** (valor de fila y TextAction, ambos 17 Regular), **7** (frase, línea de retirada, palabra de fase, subtítulo de Descenso, nota de Háptica) y **9** (palabra de estado, versalita "pro") = **5 pasos**, uno por debajo del tope de 03 §3.4 (≤ 6; C67); con la fila "Ritmo exacto" visible, los mismos cinco. Rectángulos rellenos propios: **0** (toggles y menús son del sistema). Colores distintos del gris: **0** en reposo y guiando; **1** mientras un dedo arrastra la línea (`índice`, 03 §3.1 regla 1: color = dedo). Iconos: cero propios; los chevrons de los menús son del sistema.

### 2.2 La fila Háptica y su nota

```
 652  │  Háptica                                     Ninguna ⌃⌄ │  fila 56 · Picker .menu: Ninguna · Mínima
 708  │  ─────────────────────────────────────────────────────  │
 712  │  Tres a cinco respiraciones al empezar. De noche        │  paso 7 · texto2 · 2 líneas
 732  │  nunca vibra.                                           │
 752  │                                                         │
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Fila **Háptica** ["Haptics"] | 5 | nombre `texto`; valor paso 6 `texto2` | 56, y 652-708 | Valor **"Ninguna"** ["None"] por defecto (`marea.haptica.ninguna`; la háptica es opt-in, C35; además Core Haptics no respeta "Háptica del sistema", §7, y "Ninguna" es la única desconexión fiable). Menú: "Ninguna" ["None"] · "Mínima" ["Minimal"] (`marea.haptica.minima`: tres a cinco respiraciones al empezar). **"Marcada" no está en 1.0**: se va al Watch en 1.2 (`marea.haptica.marcada` [1.2], C35). Cambia desde el siguiente ciclo si la Marea guía. Sin motor háptico, la fila y la nota no se muestran (§2.1). El mismo ajuste vive en Ajustes › háptica (C58); la hoja lo tiene porque es donde se enciende la Marea y donde se lee la nota (§9.7). |
| Nota de Háptica (`marea.haptica.nota`) | 7 · Secundario 15/20 | `texto2` | y 712-752 (ES, 2 líneas) | "Tres a cinco respiraciones al empezar. De noche nunca vibra." ["Three to five breaths at the start. Never at night."]. Es verdad por construcción: la puerta de la háptica es **por fase** (`MotionGate.allows(phase) = !phase.isNight`; 03 §3.8, C35): en Noche, Madrugada y la página nocturna no vibra nada; sin CoreMotion en producción 1.0 (el spike I0-5 queda como investigación). De día la háptica no sabe si el iPhone está en la mano: coste aceptado en C35. La nota es lo que hace honesta la función: dice lo que la háptica no hará. |

En 1.0 la hoja termina en la nota de Háptica. No hay filas de 1.1 en la hoja (§2.6): los gestos por textura son del motor y no se ven; la opción de Salud (2.0) entra en el menú Ritmo; "En la muñeca" (1.2) entra en el menú Háptica cuando haya Watch emparejado.

### 2.3 La hoja guiando (toggle encendido, suena)

```
 24   │  Marea                                                  │
 64   │  ─────────────────────────────────────────────────────  │
 80   │ ······················ cresta ····················· ─── │  marca de pleamar (nace con la línea)
      │              ╱‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾╲      │
      │   la línea de agua es UNA recta horizontal de 2 pt      │
      │   que sube 4 s, baja 4,5 s y reposa 1,5 s en bajamar;   │
      │   el dibujo de arriba es su recorrido en el tiempo,     │
      │   no su forma: en cada instante es una sola recta       │
 200  │  ═══════════════════════════════════════════════  ───   │  bajamar (instante t = 0) · marca de bajamar
 232  │  GUIANDO · 6 POR MINUTO                         inhala  │  versalitas texto2  ·  paso 7 texto2 (3 primeras respiraciones)
 256  │  Se retira a las 23:27                                  │  paso 7 texto2
 292  │  Inhala mientras la ola sube, exhala mientras se        │
 312  │  retira. No hace falta mirar la pantalla.               │
 336  │  Qué sabemos ›                                          │
 412  │  Marea                                         (●  )    │  Toggle on, .tint(texto)
 468  │  Ritmo                                  Tranquilo · 6 ⌃⌄│
 524  │  Descenso                                      ( ◯ )    │
 548  │  Empezar a 12 por minuto                                │
 596  │  Se retira a los                              15 min ⌃⌄ │
 652  │  Háptica                                     Ninguna ⌃⌄ │
```

| Elemento | Paso | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| **Línea de agua guiando** | — | `texto` (en la hoja; `índice` en la página, §2.4) | 2 pt, x 20→373; y = 200 − 120 × `BreathCurve(t)`; recorre de bajamar (200) a pleamar (80) | Señal: `BreathCurve.value(secondsSinceStart:parameters:)` del motor con ancla `guide.anchor` corregida por `AVAudioSession.outputLatency` (nunca `sin()`). Forma real del motor (`Breath.swift`): inhalación 40 % del ciclo, exhalación 45 %, reposo en bajamar 15 %; a 6 por minuto son **4,0 s subiendo, 4,5 s bajando y 1,5 s quieta en bajamar** (la "baja 6 s" de 03 §4.3 es la suma de bajada y reposo; se dice aquí para que la maqueta y el motor coincidan, §9 pregunta 1). Dibujo: `Canvas` de un solo trazo dentro de `TimelineView(.animation(minimumInterval: 1/30, paused:))`, el mismo que ya aísla `BreathIndicator` en `main` (03 §3.7 descarta `KeyframeAnimator`). Pausado cuando la Marea no guía, cuando `scenePhase != .active` y cuando otra hoja la cubre (`sheetPresented`, 04 §2.7). |
| Marcas de pleamar y bajamar | — | `texto3` | hairline, x 349→373, y 80 y 200 | Nacen con la línea (M4, 800 ms) y se van con ella (M5). Describen el recorrido mientras hay recorrido. |
| Línea de agua **bajo el dedo** | — | `índice` (`índice-noche` de noche) | 2 pt; sigue respirando mientras se arrastra | Color = dedo (03 §3.1 regla 1). Arrastre **horizontal** relativo (C52: horizontal = valor; vertical = desplazamiento, y en una hoja el gesto de cierre del sistema): **derecha = más por minuto (más rápido), izquierda = menos (más lento)**, la misma dirección que el `Slider` de pulsación larga (4 → 8 de izquierda a derecha) y que el `.adjustable` de VoiceOver (incremento = +1): tres controles sobre el mismo valor, una sola dirección. 1 respiración por minuto cada 56 pt; `minimumDistance` 8; bloqueo de eje a 30° (umbral validado por el spike I0-2 de `LevelRule`, C52); `.selection` por entero (03 §4.3); tope 4 y 8. El nuevo ritmo se aplica **al inicio del siguiente ciclo** (en el tope de la siguiente inhalación), nunca a mitad de una respiración **[spike I0-8: `pendingRate` aplicado en `advanceBreath` cuando `breathSample == 0`; §9.17]**. Mientras dura el arrastre, la palabra de estado muestra el ritmo de destino: "guiando · 5 por minuto"; si se suelta en el mismo entero, nada cambia. Al soltar, la línea vuelve a `texto` en 200 ms (M7). Con Descenso activo, el arrastre fija el ritmo de llegada (la meseta): la bajada sigue desde donde esté. |
| Palabra de estado (`marea.estado.guiando.corto`) | 9 versalitas | `texto2` | x 20, y 232-252 | "guiando · 6 por minuto" ["guiding · 6 per minute"]. Con Descenso: "guiando · 12 por minuto" → "guiando · 11 por minuto" … cada 40 s hasta la meseta. Cambia solo por hito (§3). `accessibilityAddTraits(.updatesFrequently)` **no**: se anuncia con `AccessibilityNotification.Announcement` en cada cambio (`StateWord`, 04 §2.7). |
| Palabra de fase (`marea.fase.inhala` / `.exhala`) | 7 · Secundario | `texto2` | alineada a la derecha a x 373, y 232-252 | "inhala" ["breathe in"] mientras la línea sube; "exhala" ["breathe out"] mientras baja y durante el reposo; fundido de 250 ms entre ambas; **desaparece al terminar la tercera exhalación** (fundido 500 ms) y no vuelve en esa guía (03 §4.3): ya no hace falta mirar. Señal: fase de `BreathCurve` (p < 0,40 → inhala). Si el ritmo cambia por arrastre, las tres respiraciones se cuentan de nuevo (la persona está mirando). Oculta a VoiceOver (§5b): voz de guía, ninguna (§8). |
| Línea de retirada (`marea.retira.hora`) | 7 | `texto2` | y 256-276 | "Se retira a las 23:27" ["Recedes at 23:27"]; hora calculada al arrancar (`windowStart` + Se retira a los), formateada por el sistema (12/24 h del usuario). Es la cadena de 10 (§5e.5); la forma "Se retira · 23:27" que este documento proponía por el caso "a la una" queda en §9 para E7. **Va en paso 7, nunca en versalitas** (03 §3.4: un dato que se consulta de noche). **Nada sobre Océano aquí**: si la Marea subió Océano desde 0, lo dice E2 en su línea de estado y VoiceOver lo anuncia (`marea.oceano.subido`, §5b); la hoja responde "¿cómo respiro?", no "¿qué suena?" (§1), y la línea de retirada no cambia de contenido a los 10 s por un reloj. |
| `Slider` de pulsación larga (1.0) | sistema | `.tint(texto)` (03 §4.2) | 44 pt, x 20→353, **en las cajas de la palabra de estado y de la línea de retirada (y 232-276 = 44 pt)**, que mientras dura se vacían | Pulsación larga 0,6 s sobre la banda (`Grid.longPress`; `.impact(.light, 0.4)` al cumplirse, 03 §3.8, solo de día). 4-8 en enteros; su etiqueta de VoiceOver es "Ritmo" (`marea.ritmo.fila`) y su valor `marea.ritmo.exacto`; a la vista, el valor es la palabra de estado durante el gesto. Aparece y desaparece por opacidad en 200 ms (M17); se cierra al tocar fuera o a los 5 s sin tocar (03 §4.2). **Nada se desplaza** (03 §3.7). Es la alternativa sin gesto y el ajuste fino (C21). |
| El resto | | | | Como en §2.1. El toggle Marea en *on*. |

**Un índice por pantalla en la hoja.** En reposo y guiando la hoja no tiene acento: la línea es `texto` (en la hoja la línea es control, y el acento se reserva para "lo vivo bajo el dedo", 03 §3.1 regla 2) y los toggles van en `texto` (03 §4.12). Mientras el dedo arrastra, la línea toma `índice`; al soltar vuelve en 200 ms. Es la misma gramática que ya usa la página (03 §4.1: el horizonte pasa a `texto` mientras un dedo arrastra un nivel). Nunca dos elementos en acento, ni durante un gesto; de noche, `índice-noche` solo bajo el dedo.

### 2.4 La línea de agua en la página (E2) · lo que la Marea pone allí

Geometría y cotas: `05-PAGINA-Y-CAPAS.md`. Lo que la Marea fija (03 §3.5, §4.1 "Marea disponible" y §4.3):

- La banda del horizonte mide **120 pt siempre que la mezcla cargada tenga Marea disponible** (03 §3.5 y §4.1; 04 §2.0.3 `HorizonLayout(bandHeight:)`): **no crece al activarla**; nada cambia de posición (03 §3.7). Al encender, las marcas y la línea de agua **aparecen por opacidad en 800 ms** dentro de la banda (M6); al retirarse, se van igual y la línea vuelve a ser el horizonte. Cuándo "la mezcla tiene Marea disponible" (toggle de la fila encendido o armado) lo decide E2 con la misma regla para toda la página.
- La línea de agua en la página es **2 pt `índice`** (sonido = color): sigue `BreathCurve` igual que en la hoja; **pasa a `texto` mientras un dedo arrastra un nivel** (un índice por pantalla); en la página nocturna es `texto-noche`, e `índice-noche` solo bajo el dedo (03 §3.1 regla 3).
- Marcas de pleamar y bajamar como en la hoja (hairline `texto3`, 24 pt a la derecha), solo mientras la línea recorre la banda.
- A la derecha de la banda, "inhala" / "exhala" paso 7 `texto2` las tres primeras respiraciones, igual que en la hoja (si la hoja está abierta, la página no se ve; si se cierra en la respiración 2, la página muestra la que quede).
- **Las cadenas que la Marea entrega a la página** (10 §5e.5): en reposo, el subtítulo de la fila "Marea" es "Apagada" (`marea.estado.apagada.fila`) o "Apagada · pro" (`marea.estado.apagada.pro`, bloqueado-Pro; 03 §4.7); guiando, la versalita "guiando · 6 por minuto" (`marea.estado.guiando.corto`) y, en paso 7, "Se retira a las 23:27" (`marea.retira.hora`; 03 §3.4 y §4.3: la hora nunca en versalitas); disolviendo, "disolviendo"; armada, lo que E2 decida con `marea.estado.*` (10 no tiene una cadena de "armada" para la fila: §9, pendiente de E7). Dónde van (subtítulo de la fila o segunda línea de estado) es decisión de E2 (05 §2.3 y 10 §2.1 difieren; la clave es la misma). La hora se escribe **una sola vez por superficie** (10). Si la Marea subió Océano desde 0 (persona con acceso), lo dice E2 (`marea.oceano.subido`, 4 s, 10 §2.3 / 05 `page.tide.raised`), no la hoja.
- La fila "Marea" de la página: nombre paso 5 (`marea.titulo`), subtítulo paso 7, fila 72 (03 §3.5), toggle del sistema `.tint(texto)` (03 §4.12); **en la página nocturna, `tint(texto-noche)`**: el estado se lee por la posición del pomo (P7). Tocar el nombre abre la hoja; tocar el toggle enciende sin abrir (§4.1). Bloqueado-Pro: nombre `texto2` + "pro" en versalitas (03 §4.7); el toggle abre la hoja Pro de día y no hace nada de noche (§3.5).
- Pulsación larga sobre la banda en la página: **descompone el horizonte por capas** (E2, 03 §4.1); con la Marea activa la línea de agua se dibuja encima en 1 pt `texto` y las capas debajo; se recompone al soltar. La Marea no añade gestos propios a la página: el ritmo se cambia en la hoja.
- Reduce Motion (03 §3.7): posición fija a media banda, opacidad 0,6 → 1,0 con la misma curva.
- En Noche la línea de agua **no se dibuja** (03 §4.3): el horizonte estático de Noche basta; la guía está en el oído.

### 2.5 La Marea en Madrugada (E4) · lo que la Marea pone allí

Geometría de Madrugada: `07-TEMPORIZADOR-NOCHE-MADRUGADA.md`. Lo que la Marea fija (03 §1.4 y §5 fila 11; reconciliación C05, C27, C60):

- **Para todos**, también sin Pro y después de la prueba (03 §1.4; `AccessPolicy.breathingIsIncluded(hasFullAccess:inSmallHours:)`). Nadie lee "pro" a las 3:40, nunca se dice "sin océano" y Madrugada nunca abre la hoja Pro ni muestra la prueba.
- **Receta fija (C05):** océano a nivel bajo (0,3) con Marea a **8 por minuto**, 20 min, entrada de 3 s; la Marea **se retira hacia el minuto 13** (guía hasta ≈ 10,5 y disuelve hasta el 13: la disolución es el último 20 % de su ventana, como en la hoja); el mar funde durante los últimos 5 min ("Se retira · n min", `madrugada.retirada`, de E4; distinto de "Fundiendo"); al terminar no pasa nada. Sin control: ignora Ritmo, Descenso, Se retira a los y Háptica de la hoja; la última mezcla no cuenta. Sin descenso 12 → 8 (a esa hora el descenso sería una subida; Silencio §12.4). Madrugada es una sola decisión.
- Como la receta es solo océano, la Marea respira con toda la excursión (`bedDepth` 0,4 ≈ 4,4 dB de oleaje, `Breath.swift`): cero ramas, cero DSP nuevo.
- Forma: **1,5 pt `texto-noche`**, sin marcas (04 §3.3, 07 §2.3), estática en bajamar bajo `isLuminanceReduced` (03 §4.3 literal); E4 decide si en Madrugada se dibuja la línea de agua o el horizonte estático; la Marea no exige verse: "la guía es el sonido". Se propone a E1 unificar en 2 pt con el horizonte de Noche (03 §4.1) y la regla 4 de §3.1 (§9.12); hasta entonces, 1,5.
- Háptica: **ninguna** en Madrugada (puerta por fase, C35; 02 §4.3). Voz: ninguna.
- Al terminar los 20 min: nada. Ni nota, ni palabra, ni háptico, ni retirada luminosa en 1.0 (C60). "Se ha retirado. El mar sigue." no se muestra en Madrugada (03 §5 fila 11: "nada al terminar").
- "Parar" en Madrugada para el sonido entero; la Marea se va con él (`end()`), sin disolución de 30 s: a esa hora, parar es parar.
- Entradas (C27): siempre un botón: "Madrugada · 20 min" en Noche terminada (el hueco del "+15"), widget pequeño (00:00-06:00), pantalla de bloqueo, Live Activity terminada (condicionado al spike I0-3), Centro de control, botón de Acción, Siri `SmallHours`; Watch en 1.2 (C28). La Marea arranca con el intent, sin pasar por la hoja ni por `settings`.

### 2.6 Lo que no está en 1.0 (pantalla 7 y después) · marcado

Todo lo de esta sección se construye después de 1.0; la hoja de 1.0 deja el hueco. Las cinco tablas de §5 llevan sus filas marcadas con su versión.

| Versión | Cambio | Dónde | Qué |
|---|---|---|---|
| **1.1** | Gestos por textura (C24) | motor | La Marea modula cada textura que suene (lluvia, ventilador, rosa, trueno, hoguera…) con su propio parámetro (nivel y filtro por textura: parámetros nuevos en `RenderState`), no solo la excursión de nivel común de `bedDepth`. En la hoja no cambia nada visible: la línea es la misma. Sin DSP nuevo no se promete (03 §6). |
| **1.1** | Escucha de 30 s de capa Pro (C06) | fila de la página / toggle | Cuando llegue, el toggle sin acceso guiará 30 s **sin abrir hoja sola**; sus cadenas se escriben entonces (E7). En 1.0 no existe (§3.5). |
| **1.1** | Siri `StartTide` / `StopTide` (C43) | E6 | "Marea en ${applicationName}" / "Retira la Marea en ${applicationName}"; sin acceso no suena y no se explica (10 §5e.17). En 1.0 la Marea no se enciende por voz: `PlayLastMix` arranca la mezcla con la Marea armada si el ajuste estaba encendido, y `CurrentState` la describe (`siri.estado.marea`). |
| **1.1** (propuesta E3, fuera de la reconciliación) | Ajuste exacto con medios | pulsación larga sobre la **banda** (el mismo gesto que en 1.0) | Un `Stepper` del sistema de **4,0 a 8,0 en pasos de 0,5** sustituiría al `Slider` de enteros **en el mismo sitio** (las cajas y 232-276) y bajo el mismo gesto; la fila fija "Ritmo exacto" de asistencia (§5c) pasaría a llevar el `Stepper`. Espera a que el motor acepte ritmos no enteros (`BreathParameters.guided(breathsPerMinute: Int)` hoy; §9.20). Valor "6,5 por minuto" (cadena pendiente de E7). |
| **1.2** | Háptica "Marcada" (C35) y "En la muñeca" | Watch | `.directionUp` por inhalación toda la guía (E6, 03 §3.8; `watch.haptica.marcada`). La fila Háptica del iPhone gana el valor "En la muñeca" cuando hay Watch emparejado (cadena pendiente de E7). |
| **2.0** | "Mi ritmo nocturno · según Salud" (C34) | menú de Ritmo, tercera opción | "Mi ritmo nocturno · 14 por minuto, según Salud" (`marea.ritmo.mio`). Elegirla pide el permiso de lectura de frecuencia respiratoria **en ese momento** (purpose string en §5e), nunca al abrir la app ni la hoja. Denegado o sin datos: "Mi ritmo nocturno · valor por defecto" (`marea.ritmo.mio.sin`) y la Marea arranca a 12 (el parámetro de Descenso). Solo lectura; nada se escribe en Salud. El subtítulo de Descenso ("Empezar a 12 por minuto") pasa entonces a decir el ritmo de partida real (cadena de 2.0, E7). |

---

## 3. Estados completos

Convención de 03 §4: **normal · activo · bloqueado-Pro (sin castigo) · prueba · deshabilitado · VoiceOver**, ampliada con los estados de sesión. Cada estado nombra la palabra que lo dice (`StateWord`, paso 9 versalitas `texto2`, nunca con color; vacía cuando el estado se lee por forma) y la forma de la línea.

| Estado | Cuándo | Palabra de estado | Línea de agua (hoja) | Línea de retirada | Toggle | Otros |
|---|---|---|---|---|---|---|
| **3.1 Apagada** (reposo) | Toggle off, suene o no la mezcla | **ninguna** (la caja queda vacía; VoiceOver: "apagada", `marea.estado.apagada`, §5b) | hairline `trazo-hoja` en bajamar, quieta, sin marcas | vacía | off | El estado se lee por forma: hairline quieta + toggle off (P7; 03 §4.8 no lista "apagada"). La línea no acepta el arrastre apagada (P4); el ritmo se elige en la fila Ritmo. |
| **3.2 Armada** | Toggle on con la mezcla en silencio o en pausa | "empieza al reproducir" ["starts with Play"] (cadena pendiente de E7, §9) | hairline en bajamar, sin marcas | vacía (la fila Se retira a los ya dice los minutos) | on | Es el `isEnabled = true` sin `begin()` de `main` (`setBreathingEnabled` solo arranca si `isPlaying`). Play en la barra o Magic Tap arranca mezcla y Marea a la vez; la Marea publica antes de que el motor arranque (`MixerModel`), así que la primera ola ya viene guiada. Si la mezcla cargada no tiene nada gratuito que sonar, Play arranca Rosa a 40 y lo dice (03 §1.3, E2). |
| **3.3 Guiando** (activo) | `phase == .guiding` | "guiando · 6 por minuto" ["guiding · 6 per minute"]; con Descenso, "guiando · 12 por minuto" bajando un entero cada 40 s hasta la meseta | 2 pt `texto`, respirando, con las dos marcas | "Se retira a las 23:27" | on | §2.3. Si la Marea subió Océano desde 0 (persona con acceso), la hoja no lo dice: E2 lo dice en su línea de estado y VoiceOver lo anuncia (§5b). |
| **3.4 Guiando, bajo el dedo** | Arrastre horizontal sobre la banda | "guiando · 5 por minuto" (destino) | 2 pt `índice`, sigue respirando al ritmo actual hasta el siguiente ciclo | igual (la hora de retirada no depende del ritmo) | on | `.selection` por entero (de día). Al soltar, la línea vuelve a `texto` en 200 ms (M7). |
| **3.5 Bloqueado-Pro sin castigo** | Usuario gratuito tras la prueba (`breathingIsIncluded == false`) | "pro" (versalita junto a la cabecera, en lugar de ninguna otra marca); caja de estado vacía | hairline en bajamar | vacía | **operable; vuelve a off solo** | **Encender el toggle (hoja o página) es una "primera acción Pro" (C07): de día (fuera de `NightWindow`) sube la hoja Pro de E5 con "Empezar la prueba · 7 noches" / "Comprar · {displayPrice}" (C06; 03 §4.3 "el toggle abre la hoja Pro sin guiar"); el toggle vuelve a off en 250 ms (sistema) y nada suena distinto. Entre las 21:00 y las 07:00 (`NightWindow`, C08, C40; también en la página nocturna y con la hoja abierta desde ella): la hoja Pro **no se presenta**, el toggle vuelve a off y no pasa nada más; sin nota, sin línea matinal.** Si empieza la prueba o compra con la hoja Pro delante, al cerrarla la Marea **arranca sola** desde 3.3 con los ajustes de la hoja y la versalita "pro" desaparece (03 §4.3); Océano, si la mezcla lo tenía a un nivel guardado, entra con 800 ms (la compra que se oye). Si cierra la hoja Pro sin comprar: la hoja Marea sigue en 3.5 con "pro". Sin escucha de 30 s en 1.0 (C06: pasa a 1.1 y, cuando llegue, no abrirá hoja sola). Las filas Ritmo, Descenso, Se retira a los y Háptica se pueden cambiar sin Pro (son ajustes; no abren nada). Nunca candado, nunca opacidad, nunca texto de venta en esta hoja (el precio vive solo en la hoja Pro). **[spike I0-8: `setBreathingEnabled` en `main` abre el paywall al instante también de noche; `refreshEntitledAudio` termina la Marea en cuanto cae el acceso: ambos cambian (§9.18).]** |
| **3.6 Prueba** (noches 1-7) | `hasFullAccess` por prueba (desde la hoja Pro, nunca con Play; Keychain; C07) | idéntico a 3.1-3.4 | idem | idem | idem | Nada en la hoja menciona la prueba: la prueba es "todo abierto" (03 §5 fila 15: la prueba vive en la cabecera de la página). La prueba **caduca por sesión**, nunca mientras la Marea guía (03 §1.3, Dial): la evaluación de acceso ocurre al arrancar una sesión; una Marea en curso termina su ventana aunque la fecha cambie. Al caducar, el ajuste de la Marea (toggle encendido) se conserva y no se escribe nada (misma regla que C23 para las capas): la fila de la página dice "Apagada · pro" y el motor no guía. |
| **3.7 Disolviendo** | Último 20 % de la ventana (15 min → minutos 12-15); o toggle off a mano (30 s); o fundido final del temporizador (`release(over:)`, la Marea se va con la cama) | "disolviendo" ["dissolving"] (`marea.estado.disolviendo`) | 2 pt `texto`, con marcas; **la amplitud decrece** ciclo a ciclo: y = 200 − 120 × `weight(t)` × `BreathCurve(t)`, con `weight` lineal 1 → 0 (es la ganancia real de la modulación que publica `scheduledWeight`) | "Se retira a las 23:27" (sin cambio); al apagar a mano, vacía | on | No hay háptica (la Mínima terminó en el minuto 1). Cada ola un poco más baja que la anterior; el mar sigue a su nivel. |
| **3.8 Retirada** | Fin de la disolución | **solo tras la retirada natural (3.7 por fin de ventana) y con el motor sonando** (`finish()` && `isPlaying`): durante **10 s** en la línea de retirada "Se ha retirado. El mar sigue." ["It has receded. The sea goes on."] (`marea.retirada`, paso 7); después **nada**: la hoja queda en 3.1. Nunca tras el fundido del temporizador, Parar, cambio de mezcla ni apagado a mano: en esos casos el mar no sigue o la persona lo apagó, y la caja pasa directamente a vacía (o la hoja ya no existe). | la línea termina en bajamar, se queda **2 s** quieta y pasa a hairline `trazo-hoja` (250 ms opacidad); las marcas se van con ella | ver palabra | **off** (pasa solo, 250 ms del sistema) | En la página, marcas y línea se van por opacidad y la línea vuelve a ser el horizonte (E2); la banda no cambia de altura. **Océano sigue al nivel al que la Marea lo subió**: la Marea nunca apaga una capa que ella encendió (03 §1.3). Ningún háptico, ningún sonido, ninguna Live Activity nueva salvo la actualización de estado. |
| **3.9 En pausa** | Pausa (Play, Noche, Live Activity, llamada, AirPods) con la Marea en ventana | "en pausa" ["paused"] (`marea.estado.pausa`) | se detiene donde estaba y en ≤ 2 s baja a bajamar con `.easeInOut` (03 §3.7: "congelado a hairline en ≤ 2 s"); allí queda en **2 pt `texto` a opacidad 0,6**, quieta, con marcas, hasta reanudar o terminar (forma + palabra, no un cuarto color: la línea solo conoce `trazo-hoja`, `texto` e `índice`) | "Se retira a las 23:27" → la hora **se desplaza** con la pausa; al reanudar se recalcula (§9 pregunta 3) | on | Al reanudar: la Marea retoma **desde el tope de una inhalación**, no desde donde quedó, para no empezar a medio respirar; si la ventana ya pasó, no vuelve. **[spike I0-8]**: en `main` esto solo es así para las reanudaciones del sistema; `play(userInitiated: true)` → `startBreathingIfEnabled()` → `begin()` abre una ventana **nueva** de 15 min, y `pause()` → `endPlayback` → `breathing.end()` pone `phase = .idle` y `anchor = nil`, así que no existe señal de "en pausa" (§9.23). Si la pausa dura más de 20 min, la sesión se da por terminada y la Marea con ella (E4/E6). |
| **3.10 Deshabilitado** | No existe para la Marea | — | — | — | — | Si el motor no arranca, la hoja sigue operable en estado 3.2, pero **mientras E2 muestre el error de audio, la línea de retirada de la hoja repite la misma cadena del error de E2** (paso 7, `texto2`, sin rojo; clave de E2, §5e "Fuera de la hoja") y la caja de la palabra de estado queda vacía: la hoja no promete "empieza al reproducir" cuando reproducir acaba de fallar. Al recuperarse el motor, vuelve 3.2. La Marea nunca es la que falla a la vista. |
| **3.11 Error** | No aplica | — | — | — | — | No hay red, ni tienda, ni permiso en 1.0 ni 1.1: nada que pueda fallar en la hoja. En 2.0 el permiso de Salud denegado no es un error: la opción dice la causa y el valor (§2.6). |
| **3.12 Vacío / cargando / sin red** | No aplican | — | — | — | — | Nada se carga ni se descarga; la hoja Pro (E5) tiene sus propios estados de tienda y de red; cuando se abre desde el toggle sin acceso, la mezcla sigue sonando debajo (P9). |
| **3.13 Página nocturna** (al volver de Noche; dura la sesión, C40) | La hoja abierta desde la página nocturna | igual que 3.1-3.9; 3.5 sin hoja Pro (no pasa nada) | `texto-noche`; bajo el dedo `índice-noche` | `texto-noche` | `tint(texto-noche)`: on se lee por la posición del pomo (P7); `índice-noche` solo bajo el dedo (03 §3.1 regla 3) | **Fondo `presentationBackground(negro)` y hairlines `trazo`**: 03 §3.3 fija que la página nocturna es siempre negra, y una hoja de 808 pt en `hoja` sería la única superficie que se enciende a esa hora; además `texto-noche` sobre `hoja` da ≈ 6,5:1 (calculado a partir de 03 §3.1, sin medir en dispositivo **[a medir]**) y sobre `negro` 8,03 medido. Una tinta: cabecera, filas, valores, frase, enlace y notas en `texto-noche`; marcas en `texto3`. **Pesos de la columna "De noche" de 03 §3.4**: cabecera Medium; filas Semibold; pasos 6, 7, 9 y el TextAction Medium; nada en Regular. Sin salida por reloj: la página vuelve a Día al tocar el nombre de la mezcla (C40). Háptica: nada (fase nocturna, C35). Se propone a E1 como regla del sistema para toda hoja abierta desde la página nocturna (§9.10). |
| **3.14 VoiceOver** | Siempre | se anuncia en cada cambio (solo con la app delante, §5b) | `.adjustable`; valor hablado "{n} por minuto" (C59) | estático | `.isToggle` | §5b. Magic Tap desde cualquier foco = Play/Pausa (03 §4.4, C63). |

**Estados que no existen y por qué.** "Toda la noche (sutil)" (`guideMinutes == 0`, `bedDepth 0,2`, existe en `main`): fuera de 1.0 (§8). "Se retiró" como estado persistente de la fila durante el resto de la sesión (Dial): no; tras 10 s la hoja vuelve a 3.1, porque la hora de retirada ya pasó y la forma ya lo dice. "Apagada" como palabra a la vista: no; es verdad, y la forma ya la dice (03 §4.8). "Solo oleaje": no es un estado (C59). "Muestra de 30 s": no en 1.0 (C06). "Guía hablada" (Silencio): fuera (§8).

---

## 4. Flujos

### 4.1 Entradas

| Entrada | Dónde | Qué pasa | Lo que no pasa |
|---|---|---|---|
| **Toggle de la fila en la página** | fila "Marea" (E2) | Enciende con el último ajuste (Ritmo, Descenso, Se retira a los, Háptica). Suena → 3.3 en 800 ms; en silencio → 3.2 (03 §1.3 y 10 §2.1 dicen que encender arranca el sonido si no sonaba: "el instrumento siempre suena"; E2 decide; la Marea admite las dos lecturas y publica antes de que el motor arranque). Gratuito tras la prueba: hoja Pro de día, nada de noche (§3.5). | No hay háptico en el toggle: el mar responde en 800 ms (03 §3.8 no lista el toggle; el sonido confirma). Ninguna nota flotante, ningún tip (C65). |
| **Nombre de la fila en la página** | idem | Abre la hoja en el estado que toque (3.1 o 3.3). La hoja es para ajustar, no para activar (Marea §9.4). | No enciende nada por abrirse. |
| **Play con la Marea armada** | barra, Live Activity, widget, Siri `PlayLastMix`, Centro de control | Arranca mezcla y Marea juntas (`startBreathingIfEnabled`). | No pide confirmar. |
| **Madrugada** | "Madrugada · 20 min" en Noche terminada, widget pequeño (00:00-06:00), pantalla de bloqueo, Live Activity terminada (spike I0-3), Centro de control, botón de Acción, Siri `SmallHours`; Watch (1.2) | Receta fija: Marea a 8 por minuto sobre océano bajo, 20 min, para todos (§2.5). | No consulta el ajuste de la hoja. No vende. Nunca un gesto oculto (C27). |
| **Siri `StartTide`** (1.1, C43) | E6 | Arranca la última mezcla con la Marea. | Siri nunca vende: sin acceso no suena y no se explica (10 §5e.17). En 1.0 no existe la frase. |
| **Mezcla guardada** | Mezclas | Cargar una mezcla **no** cambia la Marea: el formato v2 guarda solo pares id + nivel (C20, C09) y las mezclas de la casa son recetas de niveles (C18). La Marea sigue con el ajuste que tuviera (encendida o apagada) y respira sobre lo que suene. | `SavedMix` no lleva `breathing` (la propuesta anterior de este documento se retira, §9.19). Ninguna mezcla "trae" la Marea; "Sonando · sin Marea" no ocurre por cargar una mezcla. |

### 4.2 Dentro de la guía

| Acción | Resultado | Cuándo se aplica |
|---|---|---|
| Arrastrar la línea | Ritmo ±1 por cada 56 pt (derecha = más por minuto); `.selection` por entero (solo de día); destino en la palabra de estado | Siguiente ciclo (tope de inhalación). La hora de retirada no cambia. Con Descenso, fija la meseta. |
| Pulsación larga sobre la banda | `Slider` de 44 pt en las cajas 232-276 (M17) | Siguiente ciclo. Se cierra al tocar fuera o a los 5 s. |
| Menú Ritmo | Tranquilo · 6 / Suave · 8 | Siguiente ciclo (con Descenso, nueva meseta). |
| Toggle Descenso durante la guía | On: la guía reinicia la bajada desde 12 en el siguiente ciclo (la persona lo ha pedido; la ventana no cambia); off: salta a la meseta en el siguiente ciclo | Siguiente ciclo. |
| Menú Se retira a los | 5-30 min | De inmediato recalcula `guideEndsAt = windowStart + minutos` (`settingsDidChange` ya lo hace en `main`); si la nueva hora ya pasó, empieza a disolver ahora (también en `main`). La línea de retirada cambia de contenido en su sitio. |
| Menú Háptica | Ninguna / Mínima | Siguiente ciclo. Pasar a "Ninguna" destruye el motor háptico al terminar el ciclo en curso (§7). |
| Cerrar la hoja | La Marea sigue. La página muestra la línea de agua en la banda de 120 (E2). | — |
| Entrar en Noche (al bloquear por defecto; opción "Pasar sola a Noche" 1 / 3 min solo desde la página; nunca con la hoja abierta: C47, 03 §5 fila 10) | La línea de agua no se dibuja; el estado de Noche de E4 sigue diciendo lo suyo ("Se funde a las 03:42"). La Marea sigue en el oído. De noche no vibra nada (C35). | — |
| Bloquear el iPhone | El `TimelineView` se pausa (`scenePhase`); el motor sigue; la Live Activity (escenario A) pasa a "guiando · 6 por minuto" con una sola actualización (E6). Core Haptics no reproduce con la pantalla bloqueada **[a medir: comportamiento exacto de `CHHapticEngine` al bloquear con audio en segundo plano]**: un patrón Mínima en curso se interrumpe y **no se reanuda** al desbloquear (sería un sobresalto). | — |
| Tocar una fila de capa en la página mientras guía | Nada (03 §4.2). Arrastrar un nivel: la línea de agua pasa a `texto` mientras dura el gesto. Arrastrar Océano a 0 con la Marea guiando: la Marea **sigue** sobre las camas con `bedDepth` (no se apaga sola, no vuelve a subir Océano; la palabra de estado no cambia). | — |

### 4.3 Salidas

| Salida | Disolución | Palabra | Al final |
|---|---|---|---|
| **Retirada natural** | último 20 % de la ventana (15 → 3 min) | "disolviendo" → línea de retirada "Se ha retirado. El mar sigue." 10 s (solo con el motor sonando) → nada | Toggle off solo; Océano se queda; marcas y línea se van de la página por opacidad. **[spike I0-8: `main` guía la ventana entera y disuelve 120 s después; aquí la disolución va dentro de la ventana: `guideEndsAt = windowStart + 0,8 × duración`, `dissolveSeconds = 0,2 × duración` (5 → 60 s, 10 → 120, 15 → 180, 20 → 240, 30 → 360).]** |
| **Toggle off a mano** (hoja o página) | **30 s**, nunca un corte (03 §4.3) | "disolviendo" (30 s) → nada (sin la nota de retirada: la persona lo apagó, no hay nada que contar) | Océano se queda. **[spike I0-8: `end()` publica `.off` con `dissolveSeconds 0`; debe publicar `weight 0, dissolveSeconds 30` y pasar a `.idle` al terminar; `scheduledWeight` debe leer esta disolución manual (hoy solo deriva de `guideEndsAt`). `oceanBeforeTide` y su restauración en `setBreathingEnabled` se eliminan: contradicen "nunca apaga una capa que encendió".]** |
| **Fundido final del temporizador** | la de la cama (fundido de ganancia de 10-15 min con cuenta entera, "Fundiendo · n min", C31; Hasta dormirme y Manto, C03/C22) | "disolviendo"; **sin** la nota de retirada (el mar no sigue) | Todo se va junto; nada que ver en Noche. |
| **Pausa** | no es salida: §3.9 | "en pausa" | Reanuda desde el tope de una inhalación. |
| **Parar** (Disco, Noche, Madrugada "Parar", Siri `Pause`) | ninguna: con el sonido | — | `end()` inmediato con el fundido de parada que fije E2/E4 (03 §3.7: 1,5-2 s; hoy `engine.stop(fadeOut: 0.04)`, 40 ms: **[spike I0-8]**). Sin nota de retirada. |
| **Interrupción dentro de la ventana de la mañana** (05:00-11:00, o fin de Manto −60 min si hay Manto; C48) | ninguna: la sesión termina | — | La Marea termina con la sesión (la alarma de la mañana gana; tras la alarma del sistema nunca se reanuda). |
| **Cambio de mezcla** (Mezclas, Siri) | fundido cruzado de 1,5 s de la cama | — | La Marea sigue con su ajuste sobre la mezcla nueva (las mezclas no llevan Marea, §4.1). Sin nota de retirada. |
| **Mezcla toda Pro al caducar la prueba** | la Marea termina con la sesión, no antes | — | Al arrancar la siguiente sesión, 3.5. |

### 4.4 Interrupciones

Regla única de C48: dentro de la ventana de la mañana (05:00-11:00, o fin de Manto −60 min) ninguna interrupción reanuda; fuera de ella, toda interrupción reanuda con fundido de 3 s; una llamada (`CXCallObserver`) nunca termina la sesión fuera de la ventana. Regla de ruta de C49: AirPods fuera = 40 ms de fundido y pausa; nunca reanuda sola por el altavoz.

| Interrupción | Marea | Pantalla |
|---|---|---|
| **Llamada entrante** (`interruptionNotification .began`, `CXCallObserver`) | El audio lo corta el sistema antes de avisar; la interfaz congela la línea en 300 ms (M13, 03 §3.7). | Hoja: 3.9. Página: "En pausa · llamada" (E2). |
| **Fin de la interrupción fuera de la ventana de la mañana** (llamada, Siri, otra app) | Reanuda con el fundido de 3 s de la cama, desde el tope de una inhalación (800 ms). Sin háptico. | Vuelve a 3.3. Las palabras "inhala/exhala" **no** vuelven (ya se vieron). |
| **Interrupción dentro de la ventana de la mañana** (la alarma del sistema no se distingue de otra) | La sesión termina; la Marea con ella. | Nada (la app no se enciende). |
| **AirPods fuera / caída de ruta** | 40 ms de fundido y pausa (C49); interfaz 2 s (03 §3.7). No reanuda sola. "Seguir por el altavoz" 60 s (E2/E4); el toque reanuda capado a 0,4 solo si la ruta cambió; la Marea retoma desde el tope de una inhalación si queda ventana. | 3.9. |
| **Pausa al dormirse de AirPods (`pauseCommand` con auriculares)** | Fundido de 3 s y pausa (C49; sin spike). A los 20 min la sesión se da por buena. | 3.9 → fin. |
| **`mediaServicesWereReset`** | El motor se reconstruye y rearranca; `resume()` continúa la ventana si queda, re-anclada. | Nada visible salvo el estado. |
| **Hoja Pro encima** (abierta desde el toggle sin acceso de día, o desde otro sitio) | La mezcla sigue sonando debajo (P9); la Marea no guía sin acceso. Con acceso y la hoja Pro abierta desde otro sitio: el `TimelineView` de la hoja Marea se pausa mientras está cubierta y retoma al descubrirse (lee el ancla: no se desfasa). | — |
| **La prueba caduca a medianoche con la Marea guiando** | Nada hasta que la sesión termine (§3.6). | Nada. |
| **Cambio de ruta a AirPlay/HomePod** | El ancla se corrige con `outputLatency` (hasta 2 s) en el siguiente ciclo (C41). | La línea puede saltar de fase una vez; se acepta (es verdad) y se mide **[a medir]**. |

### 4.5 Minuto a minuto de una sesión de 15 minutos

Premisa: 23:12, fase Día (la app delante, no se ha pasado por Noche), "Mar y viento" (Océano 50 · Viento 15; mezcla de la casa, Pro) sonando con "Hasta dormirme · 45 min"; prueba activa o Pro; Ritmo Tranquilo · 6; Descenso apagado; Se retira a los 15; Háptica **Mínima elegida a mano** (por defecto es Ninguna); la persona abre la hoja desde el nombre de la fila y enciende el toggle en la hoja; iPhone en la mano, pantalla encendida.

| Minuto | Se ve en la hoja | Se ve fuera de la hoja | Se oye | Se siente (Mínima, de día) | VoiceOver anuncia |
|---|---|---|---|---|---|
| **0:00** toggle → on | Toggle on (sistema, 250 ms, `texto`). La línea pasa de hairline `trazo-hoja` a 2 pt `texto` en 800 ms de opacidad, **en bajamar**; las dos marcas nacen con ella. Palabra "guiando · 6 por minuto". Línea de retirada "Se retira a las 23:27". | Página (si se cierra): marcas y línea de agua 2 pt `índice` aparecen en la banda de 120 en 800 ms; si Océano estaba a 0, la línea de estado de E2 lo dice ("Océano subido a 40 para oír la marea.", 4 s). | Nada cambia todavía: el motor espera el siguiente ancla. | Nada. | "Marea guiando, 6 por minuto, se retira en 15 minutos." (y, si subió Océano, "Océano subido a 40 para oír la marea.") |
| **0:00-0:01,5** enganche | Línea quieta en bajamar. | idem | El oleaje libre sigue. | Nada. | — |
| **0:01,5** primera inhalación | La línea empieza a subir (4,0 s hasta pleamar). A la derecha, "inhala" (250 ms). | idem | El oleaje de Océano se hincha durante 4 s (más nivel, filtro más abierto) y se retira 4,5 s; Viento apenas respira (`bedDepth`). | El patrón de Core Haptics arranca (§7): intensidad 0,15 + 0,40 × `BreathCurve(t)`, nitidez 0,2 (sube con la línea, baja con ella). | — |
| **0:05,5-0:11,5** | Baja 4,5 s hasta bajamar ("exhala"), queda 1,5 s quieta ("exhala" sigue). | idem | El arrastre de la arena. | Baja con la línea. | — |
| **0:11,5-0:31,5** segunda y tercera respiración | Idéntico. "inhala"/"exhala" alternan con 250 ms. | idem | Idem. | Idem. | — |
| **0:31,5** fin de la tercera exhalación | "inhala/exhala" se funde en 500 ms y no vuelve. La hoja queda: línea, marcas, palabra, hora, frase, enlace, filas. | idem | Idem. | Cuarta respiración completa con el patrón a escala 1; en la quinta la escala baja linealmente a cero dentro de su propio ciclo. | — |
| **0:50** | Nada nuevo. | idem | Idem. | **El patrón termina** (quinta respiración a cero; "tres a cinco respiraciones al empezar"). Motor háptico destruido. | — |
| **1:00-12:00** la guía | Nada cambia salvo la línea, seis veces por minuto, idéntica, re-anclada por ciclo. La persona deja de mirar: la frase lo dice. Si cierra la hoja: la línea de agua en la página. Si bloquea: Noche (entra al bloquear, C47); la Live Activity (escenario A) dice "guiando · 6 por minuto" (E6) y el `TimelineView` se pausa; en Noche la línea de agua no se dibuja. | — | A las 23:22 (10 min de "Hasta dormirme" ya corridos, quedan 35): nada; el fundido del temporizador empieza a las 23:47, después de la retirada. | Nada. | — |
| **1:00-12:00** si arrastra la línea | La línea pasa a `índice` bajo el dedo; "guiando · 5 por minuto" al cruzar el primer entero hacia la izquierda (`.selection`); al soltar, la línea vuelve a `texto`. El ciclo en curso termina a 6; el siguiente arranca a 5 (12 s por ciclo). Las palabras "inhala/exhala" vuelven tres respiraciones. | Página: la línea de agua sigue; la cadena de estado cambia. | El mar se alarga a partir de la siguiente ola. | `.selection` por entero; nada más. | "5 por minuto" (valor del `.adjustable`, `marea.ritmo.exacto`). |
| **12:00** empieza la disolución | "disolviendo". La línea sube cada vez menos: la pleamar de cada ciclo baja linealmente (y de cresta: 80 → 200 en 3 min). | Página: la misma pérdida de altura; Live Activity: una actualización ("disolviendo", E6). | Cada ola un poco menos alta que la anterior, hasta el oleaje libre de Océano a 50. Nada para. | Nada. | "Marea disolviéndose." solo si la hoja o la página están delante (§5b). |
| **15:00** retirada | El último ciclo termina en bajamar; 2 s quieta en 2 pt `texto`; en 250 ms pasa a hairline `trazo-hoja` y las marcas se van con ella. Línea de retirada: "Se ha retirado. El mar sigue." durante 10 s. Toggle → off (sistema). | Página: marcas y línea de agua se van en 800 ms; la línea vuelve a ser el horizonte en `índice` respirando con el RMS; la banda no cambia de altura. Live Activity: estado "sonando" de nuevo (E6). | Océano sigue a 50, libre. Viento a 15. El temporizador sigue (se funde a las 23:57). | Nada. Nunca un háptico al terminar: la persona duerme. | "Se ha retirado. El mar sigue." solo si la hoja o la página están delante. |
| **15:10** | Nada: la hoja queda en 3.1 (hairline en bajamar, cajas vacías, toggle off). | — | — | — | (con el foco en la línea: "apagada, 6 por minuto") |
| **23:47-23:57** fundido del temporizador | Si la hoja sigue abierta (improbable): nada: la Marea ya se retiró. | Página: horizonte bajando con la ganancia real. Noche: "Fundiendo · 8 min" (E4, C31). | El mar se aleja. | Nada. | — |

Variante **Descenso** (toggle de la fila Descenso *on*): a 0:00 la palabra dice "guiando · 12 por minuto"; la primera inhalación dura 2 s; cada 40 s, en el tope de una inhalación, el ritmo baja un entero (11, 10, 9, 8, 7) y la palabra cambia (250 ms); a 4:00 llega a 6 (meseta) y desde ahí todo es como arriba; "inhala/exhala" solo las tres primeras respiraciones. La disolución y la retirada, iguales. Variante **Ninguna** (la de fábrica): sin la columna "Se siente". Variante **de noche** (la hoja abierta desde la página nocturna, o Noche entre medias): la columna "Se siente" está vacía de principio a fin, aunque Mínima esté elegida (puerta por fase, C35), y la nota de la fila Háptica lo había dicho.

Variante **"Se retira a los 5"** (la más corta): guía 4 min, disuelve 1 min; las palabras se ven igual (30 s); la háptica Mínima termina a 0:50 igual. Variante **30**: guía 24, disuelve 6.

### 4.6 El usuario gratuito tras la prueba (noche 8)

1. Abre la hoja: cabecera "Marea" y, a la derecha, "pro" en versalitas. Todo lo demás idéntico a 3.1. Sin candado, sin opacidad, sin texto de venta, sin precio.
2. Toggle → on, **de día (fuera de `NightWindow`)**: es su primera acción Pro (C07). Sube la hoja Pro de E5 (`.sheet` sobre `.sheet`, del sistema) con el precio de StoreKit en la primera línea, "Empezar la prueba · 7 noches" (si nunca la empezó) y "Comprar · {displayPrice}". El toggle vuelve a off solo (250 ms). La mezcla sigue sonando como estaba; **Océano no cambia: es Pro.** Nada guía.
3. Toggle → on, **de noche (21:00-07:00, página nocturna o Noche entre medias)**: la hoja Pro **no se presenta** (C08, regla 7). El toggle vuelve a off y no pasa nada más: ni nota, ni versalita nueva, ni recordatorio por la mañana. La venta espera a que la persona vuelva a tocar algo Pro de día.
4. Si empieza la prueba o compra (de día): "Gracias. Todo abierto." (E5); al cerrar la hoja Pro, la Marea **arranca sola** desde 3.3 con los ajustes de la hoja, y la versalita "pro" desaparece de la cabecera; Océano, si la mezcla lo tenía guardado, entra con 800 ms.
5. Si cierra la hoja Pro sin comprar: la hoja Marea sigue debajo en 3.5 con "pro". Puede volver a tocar el toggle: otra hoja Pro (de día). No hay contador ni reproche.
6. Lo que no pasa: no se abre la hoja Pro al abrir la hoja Marea; no se abre al tocar una fila de ajuste (Ritmo, Descenso, Se retira a los y Háptica se pueden cambiar sin Pro: son ajustes); **no se abre de noche**; **Océano no sube ni baja**; no vibra `.error`; nada se tacha; la Marea en Madrugada sigue siendo suya, a 8 por minuto, sin hoja.

---

## 5. Las cinco tablas obligatorias

Las cinco cubren la pantalla 6 (1.0) y, en filas marcadas **1.1 / 1.2 / 2.0**, lo de §2.6.

### 5a. Movimiento · elemento → señal del motor → duración/curva → Reduce Motion → Always-On / `isLuminanceReduced`

Todo lo que se mueve en esta entrega nombra su señal. Prefijo **M** como exige 03 §1.3.

| # | Elemento | Señal del motor (causa) | Duración / curva | Reduce Motion | Always-On · `isLuminanceReduced` · Noche · hoja cubierta |
|---|---|---|---|---|---|
| M1 | Línea de agua en la hoja: posición y | `BreathCurve.value(secondsSinceStart:parameters:)` con `guide.anchor` + `outputLatency`; `rate` de `BreathParameters` | continua; 7,5-15 s por ciclo (40 % sube, 45 % baja, 15 % reposo); `TimelineView` 30 Hz pausable; sin curva propia: la del motor | **posición fija a media banda** (y = 140); opacidad 0,6 + 0,4 × `BreathCurve(t)` en el mismo `TimelineView` a 4 Hz (`minimumInterval: 0.25`), sin Core Animation (03 §3.7) | pausada y **quieta en bajamar** en ≤ 2 s (`.easeInOut`); al descubrirse, retoma desde la fase real del ancla (no interpola: salta, porque lo que suena ya está ahí) |
| M2 | Línea de agua en la hoja: amplitud | `weight` publicado por `BreathingGuideController` (`scheduledWeight`): 1 guiando, lineal → 0 disolviendo | la de la disolución: 20 % de la ventana, 30 s a mano | igual (modula la opacidad en lugar de la altura) | igual |
| M3 | Línea de agua en la página | igual que M1 y M2 | igual | igual | en Noche no se dibuja; bajo `isLuminanceReduced` no aplica (la página no se muestra en Always-On) |
| M4 | Nacimiento de la línea y de las dos marcas (toggle on) | `begin()` → primer `epoch` | 800 ms opacidad `.easeOut`, de hairline `trazo-hoja` a 2 pt `texto`, en bajamar; las marcas nacen a la vez | igual (es opacidad) | n/a |
| M5 | Muerte de la línea y de las marcas (retirada) | `finish()` → `.off` | 2 s quieta en bajamar + 250 ms opacidad a hairline; las marcas se van en los mismos 250 ms | igual | igual |
| M6 | Marcas y línea de agua en la banda de 120 de la página | `begin()` / `finish()` | 800 ms de opacidad (03 §4.1); **la banda no cambia de altura** (120 siempre que haya Marea disponible, 03 §3.5; nada cambia de posición, §3.7) | igual (es opacidad) | n/a |
| M7 | Bajo el dedo: línea `texto` ↔ `índice` | `DragGesture` empieza / termina | 200 ms opacidad (dos capas superpuestas) | igual | n/a |
| M8 | Palabra de estado | hitos: `phase` (.guiding / .dissolving / .idle / .paused), destino del arrastre, paso de Descenso (`pendingRate` aplicado); vacía en `.idle` | cambio de contenido con 250 ms de opacidad; nunca por reloj | igual | igual |
| M9 | "inhala" / "exhala" | fase de `BreathCurve` (p < 0,40) | 250 ms opacidad entre palabras; 500 ms al desaparecer tras la tercera exhalación | igual | no se dibuja |
| M10 | Línea de retirada (hora → nota → vacía) | `windowStart`; `finish()` && `isPlaying` (nota de retirada); error de audio de E2. **Reloj**: 10 s tras `finish()`, el único permitido por 03 §4.3 "nota 10 s"; ningún otro (nada cambia a los 10 s de `begin()`) | 250 ms opacidad | igual | igual |
| M11 | Toggles (Marea, Descenso) | sistema | sistema (250 ms) | sistema | sistema |
| M12 | Menús de Ritmo / Se retira a los / Háptica | sistema | sistema | sistema | sistema |
| M13 | Congelación en pausa | `interruption` / `pauseCommand` / Play; **[spike I0-8: `BreathingPhase.paused`]** | ≤ 2 s `.easeInOut` hasta bajamar; opacidad a 0,6 | igual | igual |
| M14 | Versalita "pro" en la cabecera | `breathingIsIncluded` (cambia por sesión) | 250 ms opacidad | igual | n/a |
| M15 | Hoja Pro desde el toggle sin acceso | toque en el toggle **fuera de `NightWindow`** (C06, C08) | sistema | sistema | **n/a de noche**: no se presenta |
| M16 | Marcas de pleamar y bajamar | `begin()` / `finish()` (con M4 y M5) | 800 ms al nacer; 250 ms al irse | igual | igual que la línea |
| M17 | `Slider` de pulsación larga (1.0) en las cajas 232-276 | pulsación larga 0,6 s; toque fuera; 5 s sin tocar | 200 ms opacidad; **nada se desplaza** | igual | n/a |
| M18 | Descenso de ritmo 12 → meseta (ritual, 1.0, C24) | `pendingRate` del motor aplicado en el tope de cada inhalación: un entero menos cada 40 s | el ciclo se alarga entre ciclos; sin curva propia; la palabra de estado cambia de contenido (250 ms) en cada paso | igual | igual |
| M19 **(1.1, propuesta)** | `Stepper` "Ritmo exacto" de 0,5 | sistema | sistema | sistema | sistema |

**Presupuesto.** Un solo `Canvas` con una sola trayectoria (M1-M2) en el `TimelineView` que ya existe; `paused` cuando `phase == .idle`, `scenePhase != .active` u hoja cubierta; con Reduce Motion, el mismo `TimelineView` a 4 Hz (03 §3.7 lo resuelve igual para el horizonte): cero Core Animation por ciclo, cero disparadores propios. Cero fotogramas con la pantalla apagada. Ningún píxel cambia de luminancia más de 3 veces por segundo: la línea se mueve a 2 pt / (4 s / 120 pt) ≈ 30 pt/s como máximo en el tramo central de la inhalación, es decir, un píxel dado cambia una vez por ciclo. **Sin CoreMotion** (C35): ningún sensor vive durante la guía. Medición de aceptación: Instruments 10 min con la hoja abierta y guiando (objetivo ≤ 30 % del coste del motor) y 10 min bloqueado con la Marea guiando (0 actividad de interfaz).

### 5b. VoiceOver por control · etiqueta → valor → pista → rasgos → acciones personalizadas

Orden en la hoja: 1 cabecera → 2 línea de agua → 3 palabra de estado → 4 línea de retirada → 5 frase → 6 enlace → 7 toggle Marea → 8 Ritmo → 9 Descenso → 10 Se retira a los → 11 Háptica → 12 nota → (13 Ritmo exacto, solo asistencia). Las cajas vacías no son elementos. Las palabras "inhala/exhala" a la vista están ocultas a VoiceOver (`accessibilityHidden`): voz de guía, ninguna (§8); la fase va solo en el **valor** de la línea de agua (`ax.agua.valor`, 10 y 03 §4.3), que se recalcula al enfocar y no se anuncia solo (sin `.updatesFrequently`: §9, pendiente de E7, el riesgo de una fase leída a destiempo). Magic Tap desde cualquier foco: Play/Pausa (03 §4.4, C63). Gesto en Z o Esc: cierra la hoja. Horas: siempre la cadena visible, formateada por el sistema (`Date.FormatStyle(time: .shortened)`); VoiceOver la lee bien sin un formateador en letras. Las cadenas marcadas **(E7)** no están en 10 y se listan en §9 como pendientes de E7; el resto son las de 10 §5b y §5e.16 letra a letra.

| Control | Etiqueta ES / EN | Valor ES / EN | Pista ES / EN | Rasgos | Acciones personalizadas |
|---|---|---|---|---|---|
| Cabecera | "Marea" / "Tide" (`marea.titulo`); bloqueado-Pro: "Marea, requiere Pro" / "Tide, requires Pro" (E7; construida con `ax.marea.off.pro`) | — | — | `.isHeader` | — |
| Línea de agua | "Marea" / "Tide" (`marea.toggle`, como 10 §5b) | guiando: "inhala, 6 por minuto, se retira en 12 minutos" / "breathe in, 6 per minute, recedes in 12 minutes" (`ax.agua.valor`; relativo, como 03 §4.3; plural "se retira en un minuto"); apagada: "apagada, 6 por minuto" / "off, 6 per minute" (E7); en pausa: "en pausa, 6 por minuto" (E7); disolviendo: "disolviéndose, quedan 3 minutos" / "dissolving, 3 minutes left" (E7; plural "queda un minuto") | "Desliza arriba o abajo para cambiar el ritmo." / "Swipe up or down to change the pace." (`ax.agua.pista`: el gesto de VoiceOver sobre un `.adjustable`, no el arrastre táctil, que es horizontal) | `.adjustable` (paso 1 por minuto, 4-8; incremento = más por minuto; valor hablado "{n} por minuto", `marea.ritmo.exacto`, C59); `.accessibilityIgnoresInvertColors` | "Tranquilo, 6 por minuto" / "Calm, 6 per minute" (`marea.ritmo.tranquilo`); "Suave, 8 por minuto" (`marea.ritmo.suave`) |
| Palabra de estado | "Estado" / "Status" (E7) | "guiando, 6 por minuto" … (§5e); no existe como elemento cuando la caja está vacía | — | `.isStaticText`; anuncio en cada cambio (`AccessibilityNotification.Announcement`, prioridad por defecto; nunca interrumpe) | — |
| Línea de retirada | la cadena visible ("Se retira a las 23:27", la nota de retirada o el error de E2) | — | — | `.isStaticText`; no existe cuando está vacía | — |
| Frase | el texto (`marea.instruccion`) | — | — | `.isStaticText` | — |
| Enlace | "Qué sabemos" / "What we know" (`sabemos.titulo`) | — | "Abre la pantalla de evidencia." / "Opens the evidence screen." (`ax.sabemos.pista`) | `.isLink` | — |
| Toggle Marea (hoja) | "Marea" / "Tide" (`marea.toggle`) | "activada" / "desactivada" (sistema) | bloqueado-Pro, de día: "Toca dos veces para ver Pro." / "Double-tap to see Pro." (`ax.marea.pista.pro`; de noche, sin pista: C06) | `.isToggle` (sistema) | — |
| Ritmo | "Ritmo" / "Pace" (`marea.ritmo.fila`) | "Tranquilo, 6 por minuto" / "Calm, 6 per minute" | — (el `Picker` de menú del sistema ya anuncia "botón desplegable" y su gesto) | `.isButton` (Picker de menú del sistema; el menú expone sus opciones con `.isSelected`) | — |
| Toggle Descenso | "Descenso" / "Descent" (`marea.descenso`) | "activada" / "desactivada" (sistema) + "Empezar a 12 por minuto" (`marea.ritmo`, como 10 §5b) | — | `.isToggle` | — |
| Se retira a los | "Se retira a los" / "Recedes after" (`marea.retira`) | "15 minutos" / "15 minutes" | — | idem Ritmo | — |
| Háptica | "Háptica" / "Haptics" (`marea.haptica`) | "Ninguna" / "None" | "De noche nunca vibra." / "Never at night." (`ax.haptica.pista`) | `.isButton` (menú) | — |
| Nota de Háptica | el texto (`marea.haptica.nota`) | — | — | `.isStaticText` | — |
| `Slider` de pulsación larga / fila "Ritmo exacto" (1.0) | "Ritmo" / "Pace" (`marea.ritmo.fila`) | "5 por minuto" / "5 per minute" (`marea.ritmo.exacto`) | "Se aplica en la siguiente respiración." / "Applies on the next breath." (E7) | `.adjustable` (sistema, paso 1) | — |
| Fila de la página (E2) | "Marea" / "Tide" (`marea.titulo`) | "Desactivada" (`ax.marea.off`) / "Desactivada, requiere Pro" (`ax.marea.off.pro`) / "Guiando, 6 por minuto, se retira a las 23:27" (`ax.marea.valor`); armada: lo que E2 decida (E7) | con acceso y en silencio: "Toca dos veces para encenderla; el sonido arranca." (`ax.marea.pista`); sin acceso, de día: "Toca dos veces para ver Pro." (`ax.marea.pista.pro`) | `.isButton` (el nombre) + `.isToggle` (el toggle, elemento propio a continuación, etiqueta "Marea") | — (encender dos veces para VoiceOver sería un control duplicado) |
| **2.0** Opción "Mi ritmo nocturno" (menú Ritmo) | "Mi ritmo nocturno, 14 por minuto, según Salud" (`marea.ritmo.mio`); denegado o sin datos: "Mi ritmo nocturno, valor por defecto" (`marea.ritmo.mio.sin`) | — | pista mientras no se ha pedido el permiso (cadena de 2.0, E7) | `.isSelected` cuando elegida (sistema) | — |
| **1.1 (propuesta)** `Stepper` "Ritmo exacto" | "Ritmo" / "Pace" | "6,5 por minuto" (E7) | "Se aplica en la siguiente respiración." (E7) | `.adjustable` (paso 0,5) | — |
| **1.2** Opción "En la muñeca" (menú Háptica) | "En la muñeca" / "On the wrist" (E7) | — | — | `.isSelected` (sistema) | — |
| **2.0** Diálogo de permiso de Salud | del sistema | del sistema | del sistema | del sistema | — |

Anuncios por hito (no son controles; todos E7 salvo `marea.retirada` y `marea.oceano.subido`): "Marea guiando, 6 por minuto, se retira en 15 minutos." · "Marea disolviéndose." · "Se ha retirado. El mar sigue." (`marea.retirada`) · "Marea en pausa." · "Marea desactivada." · "Océano subido a 40 para oír la marea." (`marea.oceano.subido`; solo con acceso a Océano). **Los anuncios de disolución y retirada solo se emiten si `scenePhase == .active` y la hoja o la página están delante**; en Noche, con la pantalla bloqueada o con la hoja cubierta, no se anuncia nada: "nunca un háptico al terminar: la persona duerme" vale también para la voz; quien pregunte con el foco encuentra el estado en el valor de la línea. Sin "inhala"/"exhala" hablados por sí solos: voz de guía, ninguna (§8; la fila `marea.voz` de 10 queda para §9.5).

### 5c. Gesto → alternativa sin gesto → Control por botón → teclado / Pointer

| Gesto | Alternativa sin gesto | Control por botón (Switch Control) / AssistiveTouch | Teclado (Full Keyboard Access) / Pointer (iPad) |
|---|---|---|---|
| Arrastre horizontal sobre la banda (ritmo 4-8; **derecha = más por minuto**; C52) | Menú Ritmo (6 / 8); VoiceOver `.adjustable` (incremento = más por minuto, la misma dirección); **pulsación larga 0,6 s sobre la banda abre el `Slider` del sistema de 44 pt, 4-8 en enteros, en las cajas de la palabra de estado y la línea de retirada (y 232-276), sin desplazar nada** (misma solución que `LevelRule`, 03 §4.2, C21); etiqueta de VoiceOver "Ritmo" + valor `marea.ritmo.exacto`; se cierra al tocar fuera o a los 5 s. Control por voz: "Incrementar Marea" / "Reducir Marea" (lo que el sistema ofrece sobre un `.adjustable`), "Tocar Ritmo", "Tocar Suave" | El `Slider` es un elemento escaneable; el menú Ritmo también | `.focusable()` sobre la banda; **←/→ (y ↑/↓) cambian 1 por minuto** vía `accessibilityAdjustableAction` **[a medir con Acceso completo por teclado]**; Tab recorre en el orden de §5b; Esc cierra la hoja. Pointer: arrastre con cursor, `hoverEffect` ninguno (no hay nada que resaltar). |
| Toque en un toggle (Marea, Descenso) | Es un control, no un gesto; VoiceOver `.isToggle`; Control por voz "Tocar Marea" / "Tocar Descenso" | escaneable | Espacio |
| Toque en un menú | — | escaneable; el menú del sistema es escaneable | Espacio abre; flechas; Intro |
| Pulsación larga sobre la banda (`Slider` en 1.0) | el propio control es la alternativa; con VoiceOver, el `.adjustable` de la línea lo cubre | el control aparece también como fila permanente **"Ritmo exacto" ["Exact pace"]** (E7) **bajo la última hairline** cuando Switch Control, AssistiveTouch, "Botones de accesibilidad" o Button Shapes están activos, sin pulsación larga | ←/→ sobre la fila fija |
| Arrastrar la hoja para cerrar | toque fuera; VoiceOver gesto en Z | escaneable (el sistema expone "Cerrar") | Esc |
| Pulsación larga sobre la banda en la página (capas) | E2 | E2 | E2 |
| **2.0** Elegir "Mi ritmo nocturno" (toque en el menú) | no es un gesto; el diálogo de permiso de Salud es del sistema | escaneable (sistema) | del sistema |

No hay pulsación larga sobre la fila Ritmo en ninguna versión: el ajuste exacto vive bajo la banda. Ningún gesto vertical propio en la hoja: el vertical es desplazamiento y cierre del sistema (C52). Con Switch Control o AssistiveTouch activos (03 §1.3, Dial), la fila "Ritmo exacto" aparece sola bajo la última hairline. Acceso asistido (1.1, C39): la hoja no forma parte de la disposición de un botón de Noche/Madrugada (E4); la Marea en Madrugada funciona sin ella.

### 5d. Dynamic Type por tramo

Todo con `relativeTo` de 03 §3.4 (`TypeStep`, 04 §2.0.2). **Las filas miden lo que mida su texto**, con `frame(minHeight: 56)` (72 en Descenso) y 16 pt de aire vertical (sin `@ScaledMetric` en la fila: escalaría la fila con la fuente y daría 92-175 pt en AX, cotas que no coincidirían con la build). La banda **no es texto y no escala** (120 pt fijos: el movimiento, no la letra, es lo que informa); las marcas y la línea tampoco. **Suelo 13 pt** (03 §3.4: nada < 13 pt; versalitas nunca por debajo de 13): en xSmall y Small los pasos 7 y 9 se quedan en su tamaño de Large (`@ScaledMetric` con mínimo 13 sobre esos textos); se propone a E1 como regla del sistema (§9.11).

| Tramo | Qué cambia en la hoja | Cotas |
|---|---|---|
| **xSmall-Large** | Lo dibujado en §2, con el suelo de 13 pt en los pasos 7 y 9. Cabe entera (752 ES / 732-752 EN) en 17 Pro sin desplazamiento; en SE aparece `ScrollView` desde Large **[a medir]** (banda, texto y las cuatro primeras filas quedan sobre el pliegue). | Filas 56 (Descenso 72); frase 2 líneas; enlace 1 línea (13 caracteres, ≈ 110 pt **[a medir]**); nota 2 líneas ES. |
| **xLarge-xxxLarge** | Filas 56 → 64 → 72 (Descenso 72 → 80 → 92). La frase pasa a 3 líneas (ES, 353 pt) desde xxLarge **[a medir]**; el enlace sigue en 1 línea hasta AX1. La palabra de fase ("inhala") deja de caber a la derecha de la palabra de estado desde xxLarge: `ViewThatFits` la baja a una segunda línea bajo la versalita, alineada a la derecha; la caja de la línea de retirada baja con ella (es contenido estático que crece: las cajas crecen hacia abajo, nada se desplaza por reloj). Aparece `ScrollView` (SE ya desde Large; 17 Pro desde xLarge **[a medir]**); la banda queda arriba y es lo primero que se ve. El valor de las filas ("Tranquilo · 6") sigue a la derecha mientras quepa con 24 pt de aire respecto al nombre; si no, bajo el nombre. | Cabecera 22 → hasta ~30; versalita de estado 13 → ~20. |
| **AX1-AX2** | Filas: nombre arriba, valor debajo (`ViewThatFits`); los toggles se quedan a la derecha centrados. Palabra de estado y palabra de fase en dos líneas. Línea de retirada hasta 2 líneas. Frase 4-5 líneas. Enlace 2 líneas; el TextAction crece en alto manteniendo 44 de mínimo. "pro" baja a una segunda línea alineada a la izquierda bajo la cabecera (ya no cabe a la derecha). Subtítulo de Descenso 2 líneas. Nota de Háptica 3-4 líneas. | Filas ≈ 100 (28/33 pt de texto + valor + 32 de aire) **[a medir]**; banda 120 fija; marcas iguales; el arrastre sigue siendo horizontal, con el bloqueo de eje a 30° contra el scroll vertical. |
| **AX3-AX5** | La versalita de estado a 13 pt escala con `.footnote` hasta ~44 pt a AX5: se mantiene en versalitas (03 §3.4 las prohíbe por debajo de 13, no por encima) y en una sola idea por línea: "guiando" / "6 por minuto" en dos líneas (`\n` solo a partir de AX3). La palabra de fase se **oculta** desde AX3: la línea ya enseña la fase y la pantalla es para el texto. Los menús del sistema escalan solos. La nota de Háptica, 4-6 líneas. | Filas ≈ 130-170 **[a medir]**. Nada se trunca con "…". Capturas obligatorias: Large, xxxLarge, AX3 y AX5, ES y EN (03 §8.3). |

La fila de la página (E2) sigue las reglas de `EditorialRow` de E2 en cada tramo. La Live Activity "guiando" (E6, escenario A) va en `texto` y escala de Large a AX5 con `minimumScaleFactor(0.7)` del sistema; en StandBy, `marea.estado.guiando.corto` ocupa el estado de E6 a **≥ 24 pt** (C25, C62; 03 §5 fila 21), en `texto`, sin versalitas (§6).

### 5e. Catálogo de cadenas ES / EN por clave

Las claves y los textos son los de `10-GUIA-DE-COPY.md` (§5e.5 Marea, §5e.16 accesibilidad, §5e.17 Siri), letra a letra; 10 es la fuente de verdad del vocabulario (reconciliación §1 regla 4). Las claves de `main` (`breath.*`) se renombran como dice el Anexo de 10 ("antes `…`"). Las cadenas que este documento necesita y 10 no tiene llevan **(E7)**: se proponen con una clave de la familia de 10, se listan en §9 como pendientes de E7 y no se compilan hasta que E7 las incorpore. Longitud máxima en caracteres (ES) para que quepa en una línea de 353 pt en Large, salvo donde se indica. Formato de hora: `Date.FormatStyle(time: .shortened)` del sistema; los `%lld` son enteros y VoiceOver los pronuncia solo (ninguna clave con números en letras). Variación plural donde se indica, con el String Catalog.

**Hoja (pantalla 6).**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `marea.titulo` (antes `breath.title`) | Marea | Tide | cabecera de la hoja; nombre de la fila en la página; nunca marca (C10); "Breathing tide" solo en prosa de ficha (C15) | 20 |
| `marea.instruccion` (antes `breath.hint`; ES igual) | Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla. | Breathe in as the wave rises, out as it pulls back. No need to watch the screen. | la frase, paso 7, 2 líneas | 96 (2 líneas) |
| `sabemos.enlace` | Qué sabemos › | What we know › | TextAction bajo la frase; empuja la pantalla "Qué sabemos" de E5+E7 desde la página; el chevron es tipográfico | 34 |
| `marea.estado.apagada` | apagada | off | **solo VoiceOver** en la hoja (valor de la línea); a la vista, la caja queda vacía | 8 |
| `marea.estado.armada` **(E7)** | empieza al reproducir | starts with Play | StateWord, toggle on sin sonido ("Play" no aparece escrito en ningún otro sitio de la app: el Disco es un glifo) | 22 |
| `marea.estado.guiando.corto` (antes `breath.state.guiding`) | guiando · %lld por minuto | guiding · %lld per minute | StateWord de la hoja; fila o segunda línea de la página (E2); Live Activity, Dynamic Island y StandBy (E6: el catálogo se comparte con la extensión por target membership) | 26 |
| `marea.estado.disolviendo` (antes `breath.state.dissolving`) | disolviendo | dissolving | StateWord; E6 | 12 |
| `marea.estado.pausa` | en pausa | paused | StateWord | 10 |
| `marea.estado.apagada.fila` | Apagada | Off | subtítulo paso 7 de la fila de la página en reposo (E2) | 8 |
| `marea.estado.apagada.pro` | Apagada · pro | Off · pro | fila de la página sin acceso (03 §4.7); la versalita "pro" de la cabecera de la hoja usa su segunda palabra | 14 |
| `marea.retira.hora` | Se retira a las %@ | Recedes at %@ | línea de retirada guiando, disolviendo y en pausa; %@ = hora del sistema; también en la página (E2); nunca en versalitas | 22 |
| `marea.retirada` | Se ha retirado. El mar sigue. | It has receded. The sea goes on. | línea de retirada 10 s tras la retirada natural con el motor sonando; anuncio de VoiceOver | 32 |
| `marea.fase.inhala` | inhala | breathe in | palabra de fase, paso 7 | 10 |
| `marea.fase.exhala` | exhala | breathe out | idem | 11 |
| `marea.toggle` | Marea | Tide | fila 56 con el toggle; etiqueta de VoiceOver del toggle y de la línea de agua | 6 |
| `marea.ritmo.fila` | Ritmo | Pace | fila; etiqueta de VoiceOver del `Slider` | 8 |
| `marea.ritmo.tranquilo.corto` | Tranquilo · 6 | Calm · 6 | valor de la fila Ritmo | 14 |
| `marea.ritmo.tranquilo` | Tranquilo · 6 por minuto | Calm · 6 per minute | opción del menú; acción de VoiceOver | 26 |
| `marea.ritmo.suave.corto` | Suave · 8 | Gentle · 8 | valor de la fila | 14 |
| `marea.ritmo.suave` | Suave · 8 por minuto | Gentle · 8 per minute | opción del menú | 26 |
| `marea.ritmo.exacto` (antes `breath.rate.format`) | %lld por minuto | %lld per minute | valor de la fila Ritmo sin nombre (4, 5, 7); valor hablado de la línea y del `Slider` (C59) | 16 |
| `marea.descenso` | Descenso | Descent | fila 72 con toggle: el ritual (C14, C24) | 10 |
| `marea.ritmo` | Empezar a 12 por minuto | Start at 12 a minute | subtítulo paso 7 de la fila Descenso: ritmo de partida fijo (parámetro, C34) | 26 |
| `marea.retira` | Se retira a los | Recedes after | fila | 16 |
| `marea.retira.valor` | %lld min | %lld min | valor de la fila Se retira a los y opciones del menú | 7 |
| `marea.haptica` | Háptica | Haptics | fila (también grupo de Ajustes, C58) | 8 |
| `marea.haptica.ninguna` | Ninguna | None | opción (por defecto) | 8 |
| `marea.haptica.minima` | Mínima | Minimal | opción: tres a cinco respiraciones al empezar | 8 |
| `marea.haptica.nota` | Tres a cinco respiraciones al empezar. De noche nunca vibra. | Three to five breaths at the start. Never at night. | nota paso 7 bajo Háptica, 2 líneas ES | 60 (2 líneas) |
| `marea.ritmo.exacto.fila` **(E7)** | Ritmo exacto | Exact pace | fila fija de asistencia con el `Slider` (§5c) | 14 |

**VoiceOver.**

| Clave | ES | EN | Contexto |
|---|---|---|---|
| `ax.agua.valor` | %@, %lld por minuto, se retira en %lld minutos | %@, %lld per minute, recedes in %lld minutes | valor de la línea de agua guiando; `%@` = inhala / exhala (plural: one = "…, se retira en un minuto" / "…, recedes in one minute") |
| `ax.agua.pista` | Desliza arriba o abajo para cambiar el ritmo. | Swipe up or down to change the pace. | pista de la línea de agua (gesto de VoiceOver sobre `.adjustable`) |
| `ax.agua.apagada` **(E7)** | apagada, %lld por minuto | off, %lld per minute | valor apagada |
| `ax.agua.pausa` **(E7)** | en pausa, %lld por minuto | paused, %lld per minute | valor en pausa |
| `ax.agua.disolviendo` **(E7)** | disolviéndose, quedan %lld minutos | dissolving, %lld minutes left | valor disolviendo (plural: one = "disolviéndose, queda un minuto" / "dissolving, one minute left") |
| `ax.ritmo.pista` **(E7)** | Se aplica en la siguiente respiración. | Applies on the next breath. | pista del `Slider` |
| `ax.marea.valor` | Guiando, %lld por minuto, se retira a las %@ | Guiding, %lld per minute, recedes at %@ | valor del toggle encendido (fila de la página, E2) |
| `ax.marea.off` | Desactivada | Off | valor del toggle apagado |
| `ax.marea.off.pro` | Desactivada, requiere Pro | Off, requires Pro | sin acceso; la cabecera de la hoja bloqueado-Pro compone "Marea, requiere Pro" con ella (E7) |
| `ax.marea.pista` | Toca dos veces para encenderla; el sonido arranca. | Double-tap to turn it on; the sound starts. | pista con acceso, en silencio |
| `ax.marea.pista.pro` | Toca dos veces para ver Pro. | Double-tap to see Pro. | pista sin acceso, solo de día (C06) |
| `ax.sabemos.pista` | Abre la pantalla de evidencia. | Opens the evidence screen. | pista del enlace "Qué sabemos ›" |
| `ax.haptica.pista` | De noche nunca vibra. | Never at night. | pista de la fila Háptica (C35) |
| `ax.marea.estado` **(E7)** | Estado | Status | etiqueta de la palabra de estado |
| `ax.marea.anuncio.guiando` **(E7)** | Marea guiando, %lld por minuto, se retira en %lld minutos. | Tide guiding, %lld per minute, recedes in %lld minutes. | anuncio |
| `ax.marea.anuncio.disolviendo` **(E7)** | Marea disolviéndose. | Tide dissolving. | anuncio (solo con la app delante) |
| `ax.marea.anuncio.pausa` **(E7)** | Marea en pausa. | Tide paused. | anuncio |
| `ax.marea.anuncio.off` **(E7)** | Marea desactivada. | Tide off. | anuncio al apagar a mano |
| `marea.oceano.subido` | Océano subido a 40 para oír la marea. | Ocean raised to 40 so you can hear the tide. | anuncio de VoiceOver desde la hoja (solo con acceso a Océano); a la vista lo muestra E2 (4 s), no la hoja |
| `ax.horizonte.marea` | Marea, %@, %lld por minuto | Tide, %@, %lld per minute | valor del Horizonte de la página con Marea (E2, C63); `%@` = inhala / exhala |

**Fuera de la hoja (cadenas que la Marea entrega a E2, E4, E5, E6, y una que recibe).**

| Clave | ES | EN | Dueño de la superficie |
|---|---|---|---|
| `marea.estado.apagada.fila` / `.apagada.pro` / `marea.estado.guiando.corto` / `marea.estado.disolviendo` / `marea.retira.hora` | (arriba) | (arriba) | E2: subtítulo de la fila o segunda línea de estado (E2 decide la posición; 05 y 10 difieren); la hora una sola vez por superficie |
| `marea.estado.guiando.corto` / `marea.estado.disolviendo` | (arriba) | (arriba) | E6, Live Activity (escenario A), Dynamic Island y StandBy (≥ 24 pt); una sola clave por cadena: el catálogo se comparte con la extensión |
| `pagina.estado.sonando.sin.marea` | Sonando · sin Marea | Playing · without the tide | E2 (10 §5e.3): solo si E2 conserva un caso en que una sesión arranque con la Marea armada y sin acceso; con el formato v2 ninguna mezcla "tiene" Marea (§4.1) |
| `siri.estado.marea` | %@, Marea a %lld por minuto, quedan %lld minutos. | %@, tide at %lld per minute, %lld minutes left. | E6, respuesta de `CurrentState` con la Marea guiando (10 §5e.17) |
| `madrugada.retirada` | Se retira · %lld min | Winding down · %lld min | E4: Madrugada los últimos 5 min (C05, C60); no es de la Marea, se cita porque "se retira" es la misma familia |
| `pro.incluye.marea` (antes `paywall.benefit.breath`) | Marea | Tide | E5, lista "Con Pro" de la hoja Pro (fila 44 paso 6) |
| `sabemos.2.afirmacion` / `sabemos.2.cuerpo` | Te acompaña a respirar más despacio. / (el cuerpo de 10 §5e.11, con "veinte participantes con dificultad para dormirse, según Tsai…") | Keeps you company as you breathe more slowly. / (10) | E5 + E7, pantalla "Qué sabemos" (C54: sin diagnóstico, con n y cita); sustituyen a las cadenas `breath.evidence.*` de la versión anterior de este documento |
| (de E2) cadena del error de audio | la de E2 | la de E2 | E2 la posee; la hoja la repite en la línea de retirada mientras E2 la muestre (§3.10); no se duplica aquí |

**Después de 1.0, marcadas.**

| Clave | V | ES | EN | Contexto |
|---|---|---|---|---|
| `marea.ritmo.mio` | 2.0 | Mi ritmo nocturno · %lld por minuto, según Salud | My night pace · %lld per minute, from Health | opción del menú Ritmo; pide el permiso al elegirla (C34) |
| `marea.ritmo.mio.sin` | 2.0 | Mi ritmo nocturno · valor por defecto | My night pace · default value | permiso denegado o sin datos |
| `NSHealthShareUsageDescription` | 2.0 | SleepNoise lee tu frecuencia respiratoria nocturna para empezar la Marea a tu ritmo. Solo lectura; nada sale de tu iPhone. | SleepNoise reads your overnight respiratory rate to start the tide at your pace. Read-only; nothing leaves your iPhone. | purpose string (10 §5e); sin `NSHealthUpdateUsageDescription` |
| `marea.haptica.marcada` | 1.2 | Marcada | Prominent | se va al Watch (C35; `watch.haptica.marcada`); no se compila en 1.0 |
| `marea.haptica.muneca` **(E7)** | 1.2 | En la muñeca | On the wrist | opción de Háptica con Watch emparejado |
| `marea.ritmo.medio` **(E7)** | 1.1 (propuesta) | %@ por minuto | %@ per minute | valor del `Stepper` (%@ = "6,5" formateado por el sistema) |
| `StartTide` / `StopTide` | 1.1 | Marea en ${applicationName} · Retira la Marea en ${applicationName} | Tide in ${applicationName} · Stop the tide in ${applicationName} | E6 (10 §5e.17, C43) |

**Claves de `main` que se retiran** (no se compilan en 1.0): `breath.subtitle.off` ("Las olas siguen tu respiración lenta"), `breath.subtitle.format` y `breath.subtitle.allNightFormat` ("resp/min"), `breath.allNight`, `breath.allNight.note`, `breath.dissolve`, `breath.duration` ("Guiar durante"), `breath.rate` ("Respiraciones por minuto"), `breath.comfort` (su idea vive en "Suave · 8"), `breath.settings.hint`, `breath.oceanRaised` (→ `marea.oceano.subido`), `sound.proOnly` y `sound.locked` en lo que tocaba a la Marea. **Claves de la primera versión de este documento retiradas tras la puerta 2:** `breath.summary.format`, `breath.armed.recedes.format`, `breath.number.4` … `breath.number.8`, `breath.oceanRaised.recedesAt.format`, `breath.row.more`, `breath.vo.choose.hint`, `breath.vo.action.on` / `.off`, `breath.la.guiding.format`, `breath.la.dissolving`, `breath.pace.mine.default`, `breath.row.exact`. **Claves de la segunda versión retiradas por la reconciliación** (§12): `breath.state.sample`, `breath.sample.over`, `breath.vo.toggle.pro.hint` ("Guía treinta segundos."), `breath.vo.announce.sample` (C06: sin escucha de 30 s); `breath.haptics.note` (CoreMotion), `breath.haptics.note.noMotion`, `breath.haptics.pronounced` en 1.0 (C35); `breath.row.startAtMine`, `breath.startAtMine.note` / `.default`, `breath.vo.startAtMine.hint` (C24/C34: el ritual es Descenso con un parámetro fijo); `breath.pace.mine.format` / `.noAccess` / `.noData`, `breath.vo.pace.mine.hint`, `breath.health.purpose` en 1.1 (C34: Salud 2.0, con las cadenas de 10); `breath.row.subtitle.format` (la fila de la página dice "Apagada", 10); `breath.siri.notIncluded` (C43: Siri no explica); `breath.evidence.link` / `.claim` / `.supports` / `.doesNotSay` / `.howWeUse` y `paywall.benefit.breath.detail` (10 fija `sabemos.enlace`, `sabemos.2.*` y `pro.incluye.marea`); `breath.recedesAt.format` "Se retira · %@" (10 fija `marea.retira.hora`); `breath.haptics.wrist` en 1.1 (→ 1.2). Las frases de Siri son de E6 y van en `AppShortcuts.xcstrings`.

**Revisión de la lista negra (10 §0.4-§0.5) sobre todas las cadenas anteriores:** ninguna contiene "mejora", "sueño profundo", "insomnio", "ansiedad", "terapia", "nervio vago", "regula", "relajante", "IA", "vitalicio", "timer", "mix", "protocolo", "sesión", "v1", "v2", "oleaje" como nombre, "chip", ni promesas; "Play" no aparece escrito salvo en `marea.estado.armada` (pendiente de E7, que decide si "al reproducir" basta). Las palabras que la reconciliación no graba (§3) no aparecen.

---

## 6. Variantes

| Variante | Qué cambia | Qué no cambia |
|---|---|---|
| **iPhone 17 Pro (393 × 852)** | Lo cotado en §2. Hoja ≈ 808 de alto **[a medir]**; 56 pt de aire bajo la nota de Háptica en Large (ES). | — |
| **iPhone SE (375 × 667) y 16e (390 × 844)** | Columna 335 (SE) / 350 (16e); la banda sigue siendo 120 (es proporción de aire, no del tercio: en la hoja no rige el tercio, que es de la página). Hoja ≈ 647 en SE **[a medir]**: aparece `ScrollView` desde Large; banda, texto y las cuatro primeras filas quedan sobre el pliegue. La frase en SE puede pasar a 3 líneas en Large **[a medir]**; si lo hace, el enlace baja 20 pt y las filas también: se acepta porque es contenido estático. En 16e, idéntico al 17 Pro con 3 pt menos de columna. | Tamaños tipográficos, 56/72 de fila, 44 del enlace. |
| **iPad** (`TARGETED_DEVICE_FAMILY = 1,2`) | Sin motor háptico: la fila Háptica y su nota no se muestran; la hoja termina en la hairline de y 652 (y 708 con "Ritmo exacto" por asistencia). Pointer: arrastre con cursor sobre la banda, sin `hoverEffect`. La hoja es `.sheet` del sistema en el tamaño que el sistema le dé; la columna sigue a 20 pt de margen. | Todo lo demás. |
| **Papel (modo claro)** · **1.1** (C32) | 1.0 es solo oscura (`preferredColorScheme(.dark)` en la raíz). En 1.1, con apariencia clara del sistema: fondo `hoja-papel`, texto `tinta`, secundario `tinta2`, marcas `tinta3`, hairlines `trazo-papel`, línea de agua 2 pt `tinta`, bajo el dedo `ocre` (el índice de día), toggles `tint(tinta)`, `Slider` `.tint(tinta)` (03 §3.3; tokens marcados 1.1 en 04). | La página nocturna y la hoja abierta desde ella son siempre negras (03 §3.3; §3.13). Nada más cambia. |
| **ES / EN** | Las cadenas de §5e. El inglés es más corto en todas (la frase: 2 líneas en ambos; la nota de Háptica: 2 líneas ES, 1-2 EN **[a medir]**). es-419: ninguna diferencia en las cadenas de la Marea (no hay "prende", "celular" ni "timer"). | — |
| **High Contrast ("Aumentar contraste")** | `texto2` → `texto2-ac`, `texto3` → `texto3-ac`, `índice` → `índice-ac` (línea bajo el dedo), `trazo-hoja` → `trazo-ac` (03 §3.1: la variante AC de `trazo-hoja` es `trazo-ac` por decisión; cierra §9.8). | Pesos, tamaños, formas. |
| **Button Shapes** | El enlace "Qué sabemos ›" se subraya (sistema). Las filas con menú muestran su contorno del sistema. Los toggles, igual. La banda no es un botón y no se contornea; el `Slider` de pulsación larga aparece como fila fija "Ritmo exacto" bajo la última hairline mientras Button Shapes esté activo (03 §4.2 lo hace así para `LevelRule`). | — |
| **Escala de grises** (prueba de P7) | Todo sigue leyéndose: el estado es palabra o forma; guiando/apagada se distinguen por la línea (2 pt viva con marcas frente a hairline quieta sin marcas); en pausa, por la opacidad 0,6 y la palabra; bajo el dedo, por la palabra de destino; los toggles, por la posición del pomo del sistema (ya no dependen del color: `.tint(texto)`). | — |
| **Filtro rojo de StandBy** | **No aplica a la hoja** (StandBy no muestra la app). Aplica al estado "guiando" de la Live Activity (E6, escenario A): en StandBy, `marea.estado.guiando.corto` ocupa el estado de E6 a **≥ 24 pt** en `texto`, sin versalitas y nada en `texto2`; criterio de C62: ≥ 3:1 bajo rojo medido en dispositivo (spike I0-6), plan B `texto` → `#F0ECE4` si la medida queda por debajo de 3,5 (lo fija 03 §3.1; aquí solo se hereda); la línea de agua allí es estática, 2 pt `texto`, en bajamar; nada se anima. | — |
| **Reduce Motion** | M1 por opacidad a media banda a 4 Hz; M6 ya es opacidad; M9-M10 ya son opacidad. La háptica no depende de Reduce Motion. | Las curvas y tiempos del audio. |
| **Reducir transparencia** | La hoja es `hoja` (o `negro`) opaca: nada que cambiar. | — |
| **Smart Invert** | La línea de agua y las marcas llevan `.accessibilityIgnoresInvertColors()`; el resto se invierte como decida la persona. | — |
| **Bold Text** | SF Pro responde sola; Semibold → Bold en cabecera y filas se acepta (es el sistema, no la app). | — |
| **Página nocturna** (al volver de Noche; dura la sesión; C40) | §3.13: `negro`, `trazo`, `texto-noche`, pesos Medium, toggles `tint(texto-noche)`, sin hoja Pro, sin háptica. | — |
| **Escenario B** (una pareja; C25) | Sin Live Activity en 1.0: "guiando" no se ve fuera de la app; la pantalla de bloqueo muestra el Reproduciendo del sistema. | La hoja, la página y Madrugada. |

---

## 7. Háptica por evento

02 §4 y 03 §3.8 íntegros; aquí, el inventario de la Marea. **Regla de silencio (C35).** (1) **La puerta es por fase**: `MotionGate.allows(phase) = !phase.isNight`; en Noche, Madrugada y la página nocturna no vibra nada, nunca; de día la háptica no sabe si el iPhone está en la mano (coste aceptado en C35). Sin CoreMotion en producción 1.0: el spike I0-5 queda como investigación y nada de esta especificación depende de él. (2) **Core Haptics no respeta "Háptica del sistema" de Ajustes › Sonidos y no hay API pública para consultarlo**: por eso existe la fila Háptica, por eso el valor por defecto es "Ninguna" (opt-in) y "Ninguna" es la única desconexión fiable; `sensoryFeedback` (`.selection`, tope) sí lo respeta solo. (3) Mínima exige `scenePhase == .active` (la pantalla encendida y la app delante); en segundo plano, nada. (4) Durante cualquier fundido, nada. (5) "Marcada" (transitorio por inhalación toda la guía) no existe en el iPhone: se va al Watch en 1.2. Cada háptico tiene su anuncio de VoiceOver.

| Evento | iPhone, de día (fase Día) | iPhone, de noche (Noche · Madrugada · página nocturna) | Watch (1.2, C28) | VoiceOver |
|---|---|---|---|---|
| Toggle on / off (Marea, Descenso) | **ninguna**: el mar responde en 800 ms (el toggle del sistema no vibra) | ninguna | `.start` / `.stop` | anuncio guiando / "Marea desactivada." |
| Arrastre de la línea: cruzar un entero | `.selection` | ninguna | detent de la corona | valor |
| Arrastre: tope 4 u 8 | `.impact(.light, 0.6)` una vez | ninguna | — | "4 por minuto" / "8 por minuto" (el valor; el tope lo dice el sistema del `.adjustable`) |
| Pulsación larga sobre la banda | `.impact(.light, 0.4)` al cumplirse 0,6 s (03 §3.8) | ninguna | — | el `Slider` toma el foco |
| Elegir en un menú | `.selection` (sistema) | ninguna | — | opción |
| **Marea "Mínima"** (opt-in) | Un `CHHapticPattern` de **cinco eventos `.hapticContinuous` de un ciclo cada uno** (≤ 30 s por evento: un evento de 50 s no existe), intensidad por `CHHapticParameterCurve` con 8 puntos de control por ciclo tomados de `BreathCurve` (0,15 + 0,40 × valor), nitidez 0,2; **las cuatro primeras a escala 1, la quinta con la escala bajando linealmente a 0 dentro de su propio ciclo**: el patrón termina a 0:50 (03 §3.8 y C35: tres a cinco respiraciones). Motor `try CHHapticEngine()` con `playsHapticsOnly = true` (es una propiedad, no un parámetro del inicializador), creado al arrancar la guía y **destruido** en `stoppedHandler` o al terminar el patrón | **nada** (puerta por fase) | `.directionUp` al inicio de cada inhalación, cinco respiraciones | anuncio guiando (una vez) |
| **Marea "Marcada"** (1.2, Watch) | no existe en el iPhone | — | `.directionUp` toda la guía, perdiendo intensidad hacia `.click` en la disolución | idem |
| **Marea "Ninguna"** (por defecto) | nada | nada | nada | idem |
| Descenso: cada paso de ritmo | ninguna (sería un metrónomo) | ninguna | — | la palabra de estado se anuncia |
| Disolución, retirada | **ninguna** (la persona duerme) | ninguna | ninguna | "Marea disolviéndose." / "Se ha retirado. El mar sigue." solo con la app delante |
| Pausa / reanudación de la Marea | ninguna propia (la pausa del sonido tiene la suya: 03 §3.8) | ninguna | — | "Marea en pausa." |
| Hoja Pro desde el toggle sin acceso (solo de día) | **ninguna** (03 §3.8: abrir el paywall y enseñar el precio no vibran) | no se abre | — | título de la hoja Pro (E5) |
| Marea en Madrugada | — (Madrugada es fase nocturna) | **ninguna** (02 §4.3, C35) | `.directionUp` por inhalación si la Marea en Madrugada se inició desde el Watch (1.2) | — |
| Bloqueo del iPhone con Mínima en curso | el patrón se interrumpe (Core Haptics no reproduce bloqueado **[a medir]**) y **no se reanuda** al desbloquear | — | — | — |

---

## 8. Lo que se queda fuera y por qué

| Fuera | Por qué | Dónde vive, si vive |
|---|---|---|
| **Voz de guía** ("inhala" / "exhala" hablados, con VoiceOver o sin él; Silencio "Guía hablada", Dial "Voz de guía", 03 §3.8 "opcional") | El encargo de E3 lo fija: voz de guía, ninguna; háptica por inhalación. Una voz cada cinco segundos durante quince minutos son 180 interrupciones sobre una cama que se compra para no oír transitorios (02 §5.1); la frase ya dice "no hace falta mirar", y tampoco hace falta oír instrucciones: la guía es el mar. | 10 define `marea.voz` ("Decir inhala y exhala") como fila visible solo con VoiceOver; §9.5 la deja al dueño (1.1). |
| **"Toda la noche (sutil)"** (`guideMinutes == 0`, `bedDepth 0,2`, existe en `main`) | 03 §5 fila 6 fija "Se retira a los (5-30)"; una ola de 4 dB cada diez segundos durante ocho horas "es lo que un durmiente ligero llama pulsación" (comentario en `BreathingGuideController`); y contradice la tesis "después se retira". La Marea del Manto es la de quince minutos. | El modelo conserva la decodificación (ajustes antiguos con 0 se leen como 30) para no romper `sleepnoise.breath.v1`. §9 pregunta 4. |
| **Escucha de 30 s del gratuito** (la "muestra" de la versión anterior de este documento) | C06: sin escucha de 30 s en 1.0; la prueba de 7 noches ya es la demo; tocar algo Pro abre la hoja Pro de día y nada de noche (C08). | 1.1 (C06), sin hoja automática; sus cadenas se escriben entonces. |
| **CoreMotion / "en la mesilla no vibra"** | C35: sin CoreMotion en producción 1.0; la puerta de la háptica es por fase y produce el mismo silencio nocturno sin sensor. | Spike I0-5 como investigación; fundido por quietud 1.2 (C37). |
| **Háptica "Marcada" en el iPhone** | C35: se va al Watch (1.2), donde el transitorio por inhalación está en la muñeca y no en la mesilla. | `marea.haptica.marcada` [1.2]; §2.6. |
| **Salud (ritmo de partida leído de la frecuencia respiratoria)** | C34: un permiso de Salud en 1.1 contradice "Sin rastreo" por una mejora no medida; el ritmo de partida es un parámetro (12). | 2.0: `marea.ritmo.mio` (§2.6). |
| **Marea guardada en la mezcla** (`breathing: BreathingSettings?` en `SavedMix`; "Mar y viento · Marea 15 min") | C20/C09: el formato v2 son pares id + nivel; C18: las mezclas de la casa son recetas de niveles. La Marea es un ajuste de la persona, no de la mezcla. | El ajuste persistido (`sleepnoise.breath.v1`); §4.1. |
| **"v1 / v2" en cualquier etiqueta**; **"Oleaje" / "Swell" como nombre**; **"solo oleaje" como estado** | C24, C59, reconciliación §3: palabras que no se graban. | — |
| **Círculo que respira** (`BreathIndicator` de `main`, Apple Breathe, Balance) | Código ocupado por Apple y el bienestar; 03 §4.3: nunca un círculo (C59). | Se reutiliza su `TimelineView` pausable, no su forma. |
| **Disco (dial) de ritmo** (plan) | C59: toggle + línea de agua; un componente circular en una app de líneas; VoiceOver sin valor. | La línea es el control. |
| **Stepper "6 por minuto" y rejilla de cinco botones** como primera capa | P11 violado (lo técnico encima del gesto); rellenos (P6); botón "Cerrar" (P12). | El `Slider` del sistema bajo pulsación larga (1.0). |
| **Punto de fase sobre la línea** (Marea concepto §3.7, Dial §3.9) | 03 §4.3 fija "línea horizontal que sube y baja": la línea entera es el indicador; un punto es un segundo elemento y, en `índice`, un segundo acento. | — |
| **Escala de marcas bajo la línea** (Dial) | "Panel de medida" (03 §1.1). Dos marcas bastan, y solo mientras hay recorrido. | — |
| **"Exhalación · más larga / igual"** (Silencio) | El motor fija 40/45/15 y no expone otra forma; prometer "igual" sin DSP es mentir (03 §6). | §9 pregunta 1 (si el motor pasa a 40/60 sin reposo). |
| **Registrar la Marea en Salud como atención plena** (Dial) | Escritura en Salud en una app "que no mira nada"; un permiso más; nada que ver con dormir. | Fuera de todas las versiones. |
| **Marea desde la barra inferior** (Marea concepto §3.5) | La barra es Mezclas · Disco · Noche (03 §4.11). | La fila de la página. |
| **Respiración de muestra al arrastrar apagada** (Silencio §12.4) y **el arrastre con la Marea apagada** | Movimiento sin señal del motor (P4); una hairline que acepta un gesto sin responder es un control fantasma. | El ritmo apagada se elige en la fila Ritmo. |
| **Palabra "apagada" a la vista** | 03 §4.8 no la lista; el estado apagado se lee por forma (hairline quieta, toggle off) y escribir un negativo como primera palabra de la hoja es una cosa más que leer (P7, desempate). | VoiceOver (`marea.estado.apagada`). |
| **Línea de resumen en reposo** y **línea armada** | Repetían palabra por palabra las filas Ritmo y Se retira a los, 180 pt más abajo. La línea de retirada solo existe cuando dice algo que las filas no dicen. | — |
| **"Océano al 50" en la hoja** | La hoja responde "¿cómo respiro?" (§1); el nivel de una capa es "¿qué suena?" (E2) y cambiaba la línea de retirada a los 10 s por reloj. | Línea de estado de E2 (`marea.oceano.subido`); anuncio de VoiceOver. |
| **"Más ajustes" (DisclosureGroup)** | Un nivel de jerarquía, un chevron, un estado recordado y una clave para una sola fila. 03 §5 fila 6 y 10 §2.3 aún lo nombran: §9 para E1/E7. | Háptica es fila directa (§2.2). |
| **Acento en los toggles** (`.tint(índice)`) | 03 §4.12 consolidado: ningún control del sistema lleva el acento; un índice por pantalla sin excepciones; el estado *on* se lee por el pomo. | `.tint(texto)`; `índice` solo bajo el dedo. |
| **Venta de noche** (hoja Pro entre las 21:00 y las 07:00, o línea matinal) | Reconciliación §1 regla 7, C08, C40; 03 §4.12. | Nada: de noche el toggle sin acceso no hace nada. |
| **Chip, cápsula, candado, "PRO" ámbar, opacidad 0,72** | 00 §7.1; 03 §6; C64 ("chip" = StateWord o fila con estado). | La versalita "pro". |
| **Icono de ola en la fila de la página** | 03 §3.6: cero iconos en la principal; las palabras son los iconos. El símbolo propio "línea de agua" vive solo donde el sistema exige glifo (Centro de control "Madrugada", complicación: E6). | — |
| **Que la Marea apague Océano al retirarse o al apagarla** (`oceanBeforeTide` de `main`; "retirar también el mar" de Marea concepto) | 03 §1.3: la Marea nunca apaga una capa que ella encendió. Apagar Océano es un cambio audible en el peor momento. | Quien no quiera Océano lo baja con un dedo (E2). |
| **Permiso de Salud antes de usarlo** | 03 §4.12 / Marea §15: permiso en el momento de uso; y Salud es 2.0. | §2.6. |
| **Disolución "nunca es un corte" al Parar** | Parar es parar: la Marea se va con el fundido de parada del motor (03 §3.7: 1,5-2 s; hoy 40 ms, §4.3 **[spike I0-8]**). | §4.3. |

---

## 9. Preguntas abiertas

Las que la reconciliación cierra se marcan **cerrada por Cnn** y salen de la lista abierta; se dejan tachadas para que la numeración de §11 siga valiendo.

**Para el dueño.**

1. **Forma del ciclo: 4 s sube, 4,5 s baja, 1,5 s de reposo (motor hoy) o 4 s sube, 6 s baja sin reposo (03 §4.3 literal).** Este documento dibuja la del motor para que maqueta y audio coincidan (puerta 1). El reposo en bajamar es la pausa natural tras exhalar y hace la guía más fácil de seguir; si se prefiere el 4:6 continuo, es un cambio de `inhale = 0,4, exhale = 0,6` en `Breath.swift` y nada en la interfaz. La cadena pública de E5 (`sabemos.2.cuerpo`) no describe la forma, así que es verdad en las dos. Recomendación: dejar el reposo. (Sigue abierta: la reconciliación no la toca.)
2. ~~Océano sube a 50 o a 45~~ **cerrada por 10 y 03 §1.3 (nivel 40)**: la guía fija "Océano subido a 40 para oír la marea." y 03 §1.3 arranca Rosa a 40; `main` sube a 0,5: la constante pasa a 0,4 (una línea en `MixerModel`, regla 8 de la reconciliación: los números que se enseñan son los del código). Queda a E2 confirmar que su línea de estado lo muestra.
3. **Qué pasa con la hora de retirada en una pausa larga.** `main` conserva `guideEndsAt` absoluto: una pausa de 10 min dentro de una Marea de 15 deja 2 min de guía al reanudar. Alternativa: desplazar la ventana con la pausa (la hora se recalcula, §3.9 lo da por hecho). Recomendación: desplazar, porque "se retira a los 15 min" es una promesa de duración, no de hora; cambia tres líneas en `resume()` **[spike I0-8]**. (Sigue abierta.)
4. **"Toda la noche (sutil)"**: se retira de la hoja en 1.0 (§8). ¿Vuelve en 1.1 como quinta opción "Toda la noche · más sutil" para el Manto, o se da por muerta? (Sigue abierta.)
5. **Voz de guía como opción de accesibilidad** (1.1, solo con VoiceOver; 10 ya tiene la clave `marea.voz` "Decir inhala y exhala"): sí / no. (Sigue abierta.)
6. ~~Háptica por defecto~~ **cerrada por C35**: la háptica es opt-in ("Ninguna" por defecto), Mínima = 3-5 respiraciones, Marcada al Watch 1.2, puerta por fase, sin CoreMotion; ya no hay un I0-5 del que dependa.
7. ~~Háptica en la hoja o solo en Ajustes~~ **cerrada por C58**: Ajustes lleva el grupo "háptica" (Ninguna · Mínima, con la nota); la hoja conserva la fila directa porque es donde se enciende la Marea y donde se lee la nota, y de noche no se va a Ajustes a apagar una vibración (03 §4.12). El mismo valor en dos sitios se acepta por eso.

**Para E1 (sistema).**

8. ~~Token `trazo-hoja-ac`~~ **cerrada por 03 §3.1 consolidado**: la variante AC de `trazo-hoja` es `trazo-ac` por decisión (04 §9 #21).
9. **`TideLine` como componente**: este documento fija su API de vista: `TideLine(anchor:parameters:weight:style:)` con `style` ∈ {hoja, página, páginaNocturna, madrugada}, `isDragging` y `onPaceChange(Int)`; marcas de 24 pt a la derecha (§2.1) solo mientras la línea recorre la banda. Que E1 lo construya una vez con sus estados (apagada, guiando, bajo el dedo, disolviendo, en pausa, retirándose). **Dos discrepancias de 04 con 03 consolidado que E1 debe cerrar en 04:** (a) 04 §2.3 escribe "arrastre vertical sobre la banda = ritmo"; este documento y C52 (horizontal = valor; vertical = desplazamiento y cierre de la hoja) fijan **horizontal**; (b) 04 §2.7 y §2.0.4 mantienen el Toggle de Marea en `.tint(Ink.index)` y fuera del `IndexArbiter`; 03 §4.12 consolidado fija `.tint(texto)` sin excepción y pide a 04 y 05 retirar la exención. Este documento sigue a 03.
10. **Hoja abierta desde la página nocturna** (§3.13): `presentationBackground(negro)`, hairlines `trazo`, pesos de la columna "De noche" de 03 §3.4, toggles `tint(texto-noche)`. 03 §4.10 y §4.12 no contemplan la hoja de noche; se propone como regla del sistema para toda hoja abierta desde la página nocturna (Temporizador, Ajustes; la hoja Pro no se abre de noche). Medir `texto-noche` sobre `hoja` (≈ 6,5:1 calculado) y sobre `negro` en dispositivo con brillo al mínimo.
11. **Suelo de 13 pt en xSmall y Small** para los pasos 7, 8 y 9 (03 §3.4: nada < 13 pt; el sistema baja `.subheadline` y `.footnote` a 12 en esos tamaños). Regla común a todas las entregas.
12. **Línea de agua en Madrugada: 1,5 pt (03 §4.3, 04 §3.3, 07) o 2 pt** como el horizonte de Noche (03 §4.1) y la regla 4 de §3.1 (formas ≥ 2 pt). Esta entrega conserva 1,5 porque 03 §4.3 lo fija; propone 2 (un grosor menos en el sistema, y el más fino no sería justo el de las 3:40 con brillo al mínimo).
13. ~~Venta de noche~~ **cerrada por C08 y C40 (regla 7 de la reconciliación)**: entre las 21:00 y las 07:00 (`NightWindow`) nada se vende y no hay línea matinal; el toggle sin acceso no hace nada; 03 §4.3 y §4.12 consolidados ya lo dicen.
14. ~~"Se retira · 23:27" en lugar de "se retira a las 23:27"~~ **cerrada por 10** (`marea.retira.hora` = "Se retira a las %@"). Se adopta letra a letra. Queda **para E7** el caso de la una: "Se retira a las 1:27" es incorrecto en español entre la 1:00 y la 1:59, justo donde termina una Marea empezada a las 0:45; soluciones posibles sin cambiar la clave: variación por hora en el String Catalog ("Se retira a la %@" cuando la hora es 1) o la forma sin preposición que proponía este documento.
15. **"Más ajustes" y la fila Háptica.** 03 §5 fila 6 y 10 §2.3 (`marea.mas`) siguen escribiendo Háptica "bajo 'Más ajustes'"; esta entrega la deja como fila directa (§2.2, §11.3: un desplegable para una sola fila es un nivel de jerarquía de más) y no usa `marea.mas`. E1 decide si 03 §5 #6 y 10 §2.3 adoptan la fila directa o si 06 debe volver al desplegable.
16. **Cantidad de "Háptica del sistema".** 03 §3.8 consolidado promete '"Háptica del sistema" desactivada = nada'; no hay API pública para leer ese ajuste y Core Haptics lo ignora (§7). La única desconexión fiable es la fila con "Ninguna" por defecto; se pide a E1 que 03 §3.8 lo diga así.

**Para I0 (spikes).** Se propone el **I0-8 · Marea** (antes I0-7 en este documento; I0-7 es el timbre en bus de C29/C45), que agrupa los cambios de `main` que esta especificación necesita y que no son de interfaz:

17. Disolución **dentro** de la ventana y proporcional (20 %) en lugar de 120 s después (§4.3).
18. Apagado a mano con **30 s** de disolución (`end()` → `weight 0, dissolveSeconds 30`); `scheduledWeight` lee también la disolución manual; eliminación de `oceanBeforeTide` (§4.3).
19. Cambio de ritmo **al siguiente ciclo** (arrastre, menú y cada paso del Descenso, M18). Cerrada la pregunta técnica: sí, sin comando por ciclo desde el hilo principal. `RenderState.advanceBreath` ya detecta el cruce de ciclo (`breathSample` vuelve a 0 y recalcula `breathPeriod` cuando cambia `rate`); un `pendingRate` en `BreathParameters` aplicado en ese cruce es determinista. La interfaz calcula el instante del cambio sin callback: `tSwitch = anchor + ceil((now − anchor) × rateOld) / rateOld` y reancla ahí con `rateNew` (§2.3). El Descenso es una secuencia de `pendingRate` cada 40 s: cero parámetros nuevos en `RenderState` (C24: "el ritual cabe en la curva existente").
20. Gratuito: `setBreathingEnabled` sin acceso **no guía y no abre el paywall de noche** (`NightWindow`); de día publica `showPaywall` una vez y vuelve a off (§3.5); `refreshEntitledAudio` no termina la Marea en curso (§3.6). (La "muestra de 30 s" de la versión anterior se retira: C06.)
21. ~~`SavedMix` con `breathing: BreathingSettings?`~~ **cerrada por C20**: el formato v2 son pares id + nivel más `version: 2`; la Marea no se guarda en la mezcla (§4.1).
22. Ritmo entero 4-8 hoy; el `Stepper` de 0,5 propuesto para 1.1 exigiría `breathsPerMinute: Double` (§2.6). Sin versión asignada por la reconciliación.
23. ~~Con I0-5 (CoreMotion)~~ **cerrada por C35**: sin CoreMotion en producción 1.0; la puerta es `MotionGate.allows(phase)`.
24. Con **I0-3** (Live Activity terminada → Madrugada): la Marea de Madrugada arranca con el intent (`SmallHours`), sin pasar por la hoja ni por `settings`, con la receta fija de C05 (océano 0,3, 8/min, retirada hacia el minuto 13).
25. **Pausa a mano** (§3.9): (a) Play tras pausa manual con `windowStart != nil` y ventana viva llama a `resume()` (desplazada por la duración de la pausa, pregunta 3), no a `begin()`; (b) nuevo caso `BreathingPhase.paused` (o `isActive` derivado de `windowStart != nil && !isPlaying`) para que la palabra "en pausa" y la congelación M13 tengan señal.
26. **Parar**: fundido de parada de 1,5-2 s (03 §3.7) en lugar de `stop(fadeOut: 0.04)` (§4.3); lo fija E2/E4, la Marea lo hereda.
27. **Madrugada a 8 por minuto** (C05): `BreathParameters.guided(breathsPerMinute: 8)` con `guideMinutes ≈ 10,5` y disolución hasta el minuto 13; hoy `main` usa 6/min y `guideMinutes = 5, dissolveSeconds = 120` (07 §2.3.3).
28. **[a medir]** `CHHapticEngine` al bloquear con audio en segundo plano: ¿se detiene, falla o sigue? La especificación asume que se detiene y no se reanuda.
29. **[a medir]** Desfase visible de la línea al cambiar a AirPlay (hasta 2 s): vídeo a 240 fps con el nivel de salida, criterio de aceptación ≤ 100 ms tras el siguiente ciclo.

**Para E7 (copy): cadenas que este documento necesita y 10 no tiene (marcadas (E7) en §5b y §5e; no se compilan hasta que E7 las incorpore o las sustituya).** `marea.estado.armada` "empieza al reproducir" / "starts with Play" (StateWord del toggle encendido sin sonido; 10 no tiene estado armado); `marea.ritmo.exacto.fila` "Ritmo exacto" / "Exact pace" (fila fija de asistencia); `ax.agua.apagada` / `.pausa` / `.disolviendo` (valores de la línea fuera de "guiando"); `ax.ritmo.pista` "Se aplica en la siguiente respiración."; `ax.marea.estado` "Estado"; los cuatro anuncios `ax.marea.anuncio.*`; la cabecera bloqueado-Pro "Marea, requiere Pro" (compuesta con `ax.marea.off.pro`); la cadena de la fila de la página en estado armada (E2 la necesita: 05 propone "%lld por minuto · se retira a los %lld min"); `marea.haptica.muneca` "En la muñeca" (1.2); `marea.ritmo.medio` "%@ por minuto" (1.1, si el `Stepper` entra). Además: (a) "Por qué seis por minuto" / "Why six per minute" era la redacción de este documento para el enlace a la evidencia; se usa `sabemos.enlace` "Qué sabemos ›" (la más cercana de 10); E7 decide si la primera merece entrar; (b) `ax.agua.valor` lleva la fase ("inhala, …"): leída con el foco a mitad de ciclo es una palabra desfasada hasta 10 s; E7 y E1 deciden si se quita la fase del valor (como hizo este documento tras la puerta 2) o se mantiene como en 03 §4.3; (c) el caso de la una en `marea.retira.hora` (pregunta 14); (d) el inglés de `marea.instruccion` cambia de "recedes" (propuesta anterior) a "pulls back" (10): se adopta.

---

## 10. Autoevaluación

### 10.1 Contra la puerta de formato (03 §8.3, puerta 1)

| Requisito | Cumplido | Dónde |
|---|---|---|
| Tabla de movimiento con señal del motor | Sí, pantalla 6: M1-M18 (1.0) y M19 (1.1, propuesta), cada una con su señal, duración/curva, Reduce Motion y Always-On | §5a |
| Tabla VoiceOver por control (etiqueta / valor / pista / rasgos / acciones) | Sí: catorce controles de 1.0 (con la fila y el toggle de la página), cuatro de 1.1/1.2/2.0 y seis anuncios | §5b |
| Tabla gesto → alternativa sin gesto → Control por botón → teclado | Sí | §5c |
| Dynamic Type por tramo (xS-L · xL-xxxL · AX1-AX2 · AX3-AX5) | Sí, con lo que cambia en cada tramo, lo que no escala (la banda), el suelo de 13 pt y la fila de 72 | §5d |
| Catálogo de cadenas ES/EN por clave | Sí: 30 claves de hoja (28 de 10, 2 pendientes de E7), 20 de VoiceOver (11 de 10, 9 pendientes de E7), 8 entregadas a otros equipos (más una recibida de E2), 7 posteriores a 1.0, 12 de `main` retiradas, 16 retiradas tras la puerta 2 y 24 retiradas por la reconciliación; todas las de 10 letra a letra, con contexto y longitud máxima | §5e |
| Todas las medidas en pt | Sí; ninguna en px. Los porcentajes que aparecen (fracciones del ciclo del motor, 20 % de la ventana, opacidades) son parámetros del motor o de opacidad, no cotas | §2 |
| Un único juego de hex, el de §3 de 03 | Sí: este documento **no escribe ningún hex** salvo el plan B de C62 citado de 03 §3.1; solo tokens (`negro`, `hoja`, `trazo`, `trazo-hoja`, `texto`, `texto2`, `texto3`, `texto-noche`, `índice`, `índice-noche`, `índice-ac`, `texto2-ac`, `texto3-ac`, `trazo-ac`, `papel`, `hoja-papel`, `tinta`, `tinta2`, `tinta3`, `ocre`, `trazo-papel`), todos existentes en 03 §3.1 y §3.3 y en el asset catalog de 04 §2.0.1 | todo |
| Maqueta y texto coinciden | Los wireframes de §2 llevan las mismas cotas que las tablas de capas (32 entre grupos, 4 y 16 dentro; filas 56 y 72); el rótulo del recorrido en §2.3 dice la forma del motor (4 / 4,5 / 1,5), la misma que la tabla y que §5a; el minuto a minuto de §4.5 usa los mismos tiempos que §5a y §7; el enlace mide lo que dice §5d. No hay maqueta HTML en esta entrega: el wireframe cotado es la maqueta, y la build de E1 la sustituye en la puerta 3. | §2, §4.5 |
| Componentes y nombres de 04 | `TideLine`, `StateWord`, `TextAction`, `EditorialRow`, hoja `.systemSheet(.large)`, `Hairline(.onSheet)`, `Grid.longPress`, `TypeStep` pasos 3/5/6/7/9; Toggle, Picker `.menu`, Slider del sistema | §2, §5 |

### 10.2 Contra las doce pruebas del brief (00 §4)

| P | Prueba | Cómo lo cumple la Marea | Riesgo que queda |
|---|---|---|---|
| **P1** Noche primero | La Marea se diseñó primero donde no se ve: Madrugada (línea 1,5 pt `texto-noche` o nada; sin háptica; sin palabra; receta fija para todos) y Noche (no se dibuja). De noche no vende: entre las 21:00 y las 07:00 el toggle sin acceso no hace nada. La hoja abierta desde la página nocturna es negra, de una tinta, en Medium, sin acento. De noche no vibra nada (puerta por fase); de día la háptica es opt-in. | La hoja nocturna en `negro` es una propuesta a E1 (§9.10) hasta que la acepte. |
| **P2** Un gesto a ciegas | Encender es un toque en el toggle de la página; el ritmo es un arrastre sobre la línea en la dirección del `Slider` y de VoiceOver; Madrugada arranca la Marea sin tocar nada de ella y siempre desde un botón. Nada de la Marea necesita hacerse medio dormido: se retira sola. | — |
| **P3** Negro real, un acento | La hoja no es negra de día por decisión de 03 (§3.1 `hoja`); de noche sí (§3.13). Cero acentos en reposo y guiando (toggles en `texto`, 03 §4.12); uno bajo el dedo (la línea en `índice`). En la página, la línea de agua es el único índice y pasa a `texto` cuando un dedo arrastra un nivel. `Slider` en `texto`, chevrons en `texto2`. | — |
| **P4** Causa en el sonido | M1-M3 leen `BreathCurve` del motor con el ancla real; M2 lee `weight`; M18 lee `pendingRate`; nada usa `sin()`; la línea apagada no hace respiraciones de muestra ni acepta gestos. Reduce Motion por opacidad en el mismo `TimelineView`; `isLuminanceReduced` quieta en bajamar en ≤ 2 s. | Un reloj, el permitido: 10 s de la nota de retirada (03 §4.3 "nota 10 s"). |
| **P5** Una familia, ≤ 6 estilos | SF Pro; pasos 3, 5, 6, 7 y 9 = **cinco**, uno por debajo del tope (C67); versalitas reales; cifras tabulares; nada < 13 pt (suelo en xSmall/Small); Dynamic Type xSmall-AX5 con `ViewThatFits`. | — |
| **P6** Aire antes que cajas | Cero rectángulos rellenos propios; hairlines `trazo-hoja` de margen a margen; marcas de 24 pt solo mientras hay recorrido; grupos a 32 (banda → texto → filas: 200 → 232, 380 → 412) y 4 / 16 dentro, como manda 03 §3.5. | — |
| **P7** Estado por forma | Apagada: hairline quieta + toggle off, sin palabra. Guiando / disolviendo / en pausa: por la línea (viva con marcas, amplitud, quieta a 0,6) y por palabra. Nada depende del color (§6 escala de grises); los toggles se leen por el pomo. | — |
| **P8** 44 / 64 | Filas 56 (Descenso 72); enlace 44; banda 120 como objetivo del arrastre; toggles del sistema; `Slider` de 44 en su propio hueco; nada de noche en la hoja salvo lo que la persona abra. | — |
| **P9** Nada bloquea el sonido | El toggle sin acceso abre la hoja Pro debajo del sonido (de día) o no hace nada (de noche); la mezcla nunca se interrumpe; Madrugada lleva la Marea para todos; la prueba caduca por sesión y nunca escribe; cero candados; "pro" en versalitas. | Depende del spike I0-8 (§9.20): en `main` hoy el paywall salta también de noche y `refreshEntitledAudio` corta la Marea en curso. |
| **P10** Una pantalla, una decisión | "¿Cómo respiro?" La hoja no decide cuándo se apaga el sonido (E4), ni qué suena (E2: tampoco dice "Océano subido a 40"), ni cuánto cuesta (E5). El ritual Descenso es una respuesta más a la misma pregunta. | — |
| **P11** Lo técnico debajo del gesto | Primer nivel: la línea, dos nombres (Tranquilo, Suave) y un ritual con nombre (Descenso). Segundo nivel: pulsación larga → `Slider` de enteros, un gesto y un sitio. Las fracciones del ciclo (40/45/15) no se enseñan nunca; el "12" de Descenso sí, porque es el único número que la persona necesita para entender de dónde baja. | — |
| **P12** Sistema cuando existe | Hoja, toggles, Picker de menú y Slider del sistema; propios solo `TideLine` y `StateWord`. Un único `#available` en todo el proyecto (03 §4.4, C66), ninguno aquí. | — |

### 10.3 Contra las cinco lentes del jurado (puerta 2, aplicada) y la reconciliación

Las 3 de la mañana: la Marea no pide mirar nada de noche, no vende de noche (regla 7), no vibra de noche (puerta por fase) ni de día sin pedirlo, y en Madrugada es para todos con una receta fija; la hoja nocturna es negra y de una tinta. Honestidad e instrumento: la forma del ciclo es la del motor; la disolución es la ganancia real; el ritual Descenso cabe en la curva existente; la nota de háptica dice solo lo que la háptica hará; el precio no aparece en esta hoja; ninguna cadena está en la lista negra; ninguna cadena es distinta de la de 10. Restricción: cinco pasos, cero acentos en reposo y uno bajo el dedo, cero rellenos, una familia, controles del sistema en `texto` / `texto2`. Plataforma: todo del sistema salvo la línea; Core Haptics descrito con sus límites reales; sin sensores; la pausa a mano marcada como spike; VoiceOver completo con `.adjustable` y valor hablado "{n} por minuto"; Reduce Motion, Smart Invert, Button Shapes, Switch Control resueltos. Primera impresión: la captura 4 de E8 ("El mar respira a seis por minuto.", C57) es esta hoja guiando con la línea a media subida: cabecera, una línea entre dos marcas, una versalita con "inhala" a su derecha, la hora, la frase, un enlace de dos palabras y cinco filas; en reposo, menos: una hairline, la frase, el enlace y las filas.

**Desempate del brief (lo que se ha quitado sin perder función):** respecto a `main`, se quitan la tarjeta, el disco, el icono, la cápsula, el candado, el stepper visible, la rejilla, el botón Cerrar, la opción "toda la noche" y dos subtítulos; respecto al concepto Marea, el punto de fase y "retirar también el mar"; respecto a Dial, la escala de marcas, el Mono y Salud en escritura; respecto a Silencio, la Cifra de ritmo, el botón "Empezar" y la exhalación "igual"; respecto a la primera versión de este documento, la palabra "apagada", la línea de resumen, el desplegable "Más ajustes", las marcas en reposo, el chevron glifo, "Océano al 50" en la hoja, el arrastre apagada, dieciséis claves y una pulsación larga; respecto a la segunda versión, por la reconciliación, la muestra de 30 s, CoreMotion, "Marcada" en el iPhone, Salud en 1.1, la Marea guardada en la mezcla, el acento del toggle y veinticuatro claves. Se añade una sola fila que no estaba: Descenso, porque el plan y la dirección coincidían en que el ritual es 1.0 (C24) y necesita un nombre y un interruptor.

---

## 11. Respuesta al jurado

Las cinco listas de la puerta 2 (69 hallazgos: 28 mayores y 41 menores) se han aplicado salvo lo que sigue. Donde dos jurados pedían soluciones distintas para el mismo defecto, se ha elegido una y se dice cuál. Lo que la reconciliación del 16-11-2026 ha cambiado después se anota entre corchetes.

**Rechazados (contrarios a 03 §3-§4, o a una decisión de otro jurado que pesa más).**

1. *Las 3 de la mañana, menor · Línea de agua en Madrugada a 2 pt.* **Rechazado en esta entrega**: 03 §4.3 fija "Madrugada: 1,5 pt `texto-noche`" y es ley aquí; el argumento (un grosor más en el sistema, el más fino justo a las 3:40) es correcto y se eleva a E1 como corrección de 03 en §9.12. Hasta que E1 decida, §2.5 conserva 1,5.
2. *Las 3 de la mañana, menor · Formatear la hora de retirada para VoiceOver con `.spellOut` y dos claves.* **Rechazado**: el jurado de plataforma pide lo contrario (VoiceOver lee bien una hora formateada por el sistema) y el desempate es quitar. [Tras la reconciliación, la forma visible es la de 10, "Se retira a las 23:27"; el caso de la una va a E7, §9.14.]
3. *Primera impresión, mayor · Quitar la fila Háptica de la hoja en 1.0 y dejarla solo en Ajustes › Marea.* **Rechazado en su forma**: 03 §5 fila 6 pone Háptica en la hoja y 03 §4.12 veta, de noche, lo que exigiría ir a Ajustes para apagar una vibración. Se aplica la parte que no choca con 03: el desplegable desaparece y Háptica es fila directa (§2.2), con la nota en paso 7. [C58 confirma el grupo "háptica" en Ajustes; la duplicidad se acepta, §9.7.]

**Resueltos por otra vía (el defecto se corrige; la solución no es la propuesta por ese jurado).**

4. *Las 3 de la mañana, mayor · Toggle "sin tinte (gris del sistema)" en la página nocturna.* Se usa `tint(texto-noche)`: el estado se lee por la posición del pomo (§2.4, §3.13). [03 §4.12 consolidado extiende la misma lógica al día: `.tint(texto)`.]
5. *Las 3 de la mañana, mayor · Hoja nocturna: medir `texto-noche` sobre `hoja` y pasar a `negro` solo si baja de 7.* El ratio calculado es ≈ 6,5:1: se decide `negro` directamente, sin esperar la medición (que sigue siendo obligatoria en la puerta 3), y se propone a E1 como regla (§9.10).
6. *Las 3 de la mañana, menor · "Océano al 50 · se retira a las 23:27" se queda toda la guía.* El defecto desaparece porque la hoja ya no dice nada sobre Océano: E2 lo dice en su línea de estado y VoiceOver lo anuncia. [10 fija la cadena y el nivel: "Océano subido a 40 para oír la marea.".]
7. *Las 3 de la mañana, menor · `Slider` de pulsación larga dentro de la banda, centrado en y 140.* El `Slider` ocupa las cajas de la palabra de estado y de la línea de retirada (y 232-276 = 44 pt exactos), que se vacían mientras dura. Dentro de la banda se superpondría a la línea que respira.
8. *Las 3 de la mañana, menor · Añadir el estado "3.1b Apagada, bajo el dedo".* La línea apagada no es control (§3.1, §8): la versión más corta y la única sin movimiento sin señal del motor.
9. *Las 3 de la mañana, menor · Entregar a E2 el estado en el subtítulo de la fila "y nada bajo el nombre de la mezcla".* La Marea entrega sus cadenas y una sola posición por dato; E2 decide dónde (§2.4). [10 §2.1 y 05 §2.3 siguen difiriendo en la posición; la clave es la misma.]
10. *Honestidad, menor · Sustituir el resumen por "Oleaje a %lld por minuto durante %lld min."* Superado: la línea de resumen desaparece de la hoja, y con ella las claves `breath.number.*`. ["Oleaje" tampoco se graba ya, C59.]
11. *Restricción, mayor · El `Stepper` de 1.1 ocupa el valor de la fila Ritmo.* Superado: el `Stepper` (si entra) sustituye al `Slider` en el mismo sitio y bajo el mismo gesto.
12. *Honestidad, menor · Conservar la fase en el valor de VoiceOver actualizándola mientras tenga el foco.* Se tomó la opción de quitar la fase. [10 y 03 §4.3 consolidados la devuelven al valor (`ax.agua.valor`); se adopta letra a letra y se eleva a E7/E1 en §9.]
13. *Plataforma, menor · Valor guiando de la línea con hora absoluta.* Se toma la forma relativa de 03 §4.3 ("se retira en doce minutos") para el valor y el anuncio, con variación plural; la hora absoluta queda en la línea de retirada visible, que VoiceOver lee tal cual. [Coincide con `ax.agua.valor` de 10.]
14. *Primera impresión, mayor · Opción (b): retirar "7" de la cabecera.* Se toma la (a): las cinco tablas llevan sus filas posteriores a 1.0 marcadas. [La pantalla 7 es ahora "gestos por textura" (1.1) y Salud (2.0), C24/C34.]

Lo demás se ha aplicado como se pedía. Las decisiones que de ello se derivan y afectan a 03 o a 04 (hoja nocturna negra, suelo de 13 pt, Madrugada 2 pt, arrastre horizontal, toggle sin acento, "Más ajustes") están en §9.9-§9.16 para E1, E2, E5 y E7.

---

## 12. Reconciliación aplicada (16-11-2026)

Fuente: `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`. Una línea por delta que nombra a 06 (por número, por "la dirección" o por regla transversal de §1, §3 y §4), más la pasada de coherencia contra 10 (cadenas), 03 §3-§4 y 04 (tokens, tipografía, componentes) y §4/§5 de la reconciliación (reparto y versiones), y las discrepancias entre specs que la maqueta anotó. Orden de aplicación: 10 → 04 → 05-09 → 11 → 03 → FUNCIONES; este documento hereda el vocabulario de 10 ya corregido. Ningún delta se ha rechazado; las tensiones que quedan se anotan al final como notas, no como rechazos.

**Deltas de §2 aplicados**

- C05 → §2.5, §1, §4.1, §9.27: Madrugada = océano fijo a nivel bajo (0,3) con Marea a 8 por minuto para todos, entrada 3 s, la Marea se retira hacia el minuto 13, el mar funde 5 min, nada al terminar, nunca prueba ni hoja Pro; sin control de la hoja; la última mezcla no cuenta (antes: 6/min, 20 min con disolución los últimos 4, sobre la última mezcla al 60 %).
- C06 → §1, §2.6, §3.5, §4.6, M14-M15, §5e, §8: sin escucha de 30 s; encender sin acceso abre la hoja Pro de día ("Empezar la prueba · 7 noches" / "Comprar") sin guiar; la "muestra" y sus cuatro claves se retiran; escucha de 30 s a 1.1 sin hoja automática.
- C07 → §1, §3.5, §3.6, §4.6: encender la Marea sin acceso es la primera acción Pro; la prueba empieza solo desde la hoja Pro, nunca con Play; Keychain; al empezar la prueba o comprar, la Marea arranca sola al cerrar la hoja.
- C08 / C40 (regla 7) → convenciones, §3.5, §3.13, §4.6, M15, §6, §8, §9.13: `NightWindow` 21:00-07:00 (antes 22:00-07:00 en 15 sitios); de noche el toggle sin acceso no hace nada; sin nota "Muestra terminada" ni línea matinal; la página nocturna es un estado por procedencia que dura la sesión, sin salida por reloj.
- C11 → §8, §9.4: "Escudo" → "Manto" (dos apariciones).
- C14 → §1, §2.1, §2.3, §5e: "Descenso" reservado al ritual de la Marea: fila con toggle "Descenso" y subtítulo, bajada de 12 a 6 por minuto (un entero cada 40 s), meseta, disolución; la fase horaria es Día / Noche.
- C15 / §3 vocabulario → cabecera, §1, §2, §5b, §5e: "Marea respiratoria" / "Breathing tide" → "Marea" / "Tide" (`marea.titulo`) en la hoja, la fila de la página y la hoja Pro; "Breathing tide" solo en prosa de ficha; "Qué sabemos y qué no" → "Qué sabemos".
- C18 → §4.5, §4.1, §8: "Mar lento" → "Mar y viento" (océano + viento, Pro); las mezclas de la casa son recetas de niveles y no llevan Marea.
- C20 / C09 → §4.1, §4.3, §8, §9.21: el formato v2 son pares id + nivel; `SavedMix` no guarda la Marea; la propuesta `breathing: BreathingSettings?` se retira; cargar una mezcla no toca la Marea.
- C21 / C52 → §2.3, §5c, §9.9: pulsación larga = `Slider` del sistema (ya estaba; se cita C21); arrastre horizontal = valor, vertical = desplazamiento y cierre; bloqueo de eje a 30° validado por el spike I0-2; sin gesto vertical propio.
- C24 → cabecera, §1, §2.1, §2.6, §3.3, M18, §5e, §9.19: Marea 1.0 = `bedDepth` sobre todas las camas + ritual Descenso + toggle (el ritual era 1.1 como "Empezar a mi ritmo"); gestos por textura a 1.1; Salud a 2.0; "v1/v2" eliminado de todas las etiquetas y del texto ("Marea v1", "Marea v2").
- C25 / C50 → §1, §4.2, §4.5, §5d, §6: Live Activity recortada en 1.0 solo en escenario A (1.1 en B); "guiando (Marea)" es uno de sus seis estados; StandBy = la misma vista escalada con texto ≥ 24 pt (antes 22); variante "Escenario B" en §6.
- C27 → §2.5, §4.1: Madrugada siempre es un botón: "Madrugada · 20 min" en Noche terminada, widget pequeño (00:00-06:00), pantalla de bloqueo, Live Activity terminada (I0-3), Centro de control, botón de Acción, Siri; sin doble toque.
- C28 → §2.6, §7, §4.1: Watch 1.2 (antes 1.1): "En la muñeca", `.directionUp`, Marea en Madrugada desde el Watch.
- C30 → §4.3: "Siesta" eliminada del fundido final del temporizador (Hasta dormirme y Manto, C03/C22).
- C31 → §4.3, §4.5: fundido final de ganancia de 10-15 min con cuenta entera, "Fundiendo · n min".
- C34 → §1, §2.1, §2.6, §5e, §8: ritmo de partida "Empezar a 12 por minuto" (`marea.ritmo`, parámetro fijo) como subtítulo de Descenso; sin HealthKit en 1.1; "Mi ritmo nocturno · según Salud" y su purpose string a 2.0 con las cadenas de 10; las tres claves `breath.pace.mine.*` y `breath.vo.pace.mine.hint` se retiran.
- C35 → §2.1, §2.2, §4.2, §4.5, §5a, §6, §7, §8, §9.6, §9.23: háptica Mínima = 3-5 respiraciones opt-in ("Ninguna" por defecto); "Marcada" al Watch 1.2; puerta por fase (`MotionGate.allows(phase) = !phase.isNight`); sin CoreMotion (25 menciones de I0-5 y la regla de la mesilla eliminadas); nota de Háptica = `marea.haptica.nota` ("Tres a cinco respiraciones al empezar. De noche nunca vibra."); las dos notas anteriores y `breath.haptics.pronounced` (1.0) se retiran; la columna "iPhone en la mesilla" de §7 pasa a ser "de noche".
- C41 → §4.4: cambio de ruta a AirPlay con `outputLatency` (ya estaba; se cita).
- C43 → §2.6, §4.1, §5e: Siri `StartTide` / `StopTide` a 1.1; en 1.0 `PlayLastMix` arranca con la Marea armada y `CurrentState` la describe (`siri.estado.marea`); `breath.siri.notIncluded` se retira (Siri no explica lo Pro).
- C45 → convenciones, §9, todo el documento: los spikes son I0-2, I0-3, I0-5/5b, I0-6, I0-7 de la reconciliación; el paquete de `main` de la Marea pasa de "I0-7" a **I0-8** (I0-7 es el timbre en bus); I0-4 (AirPods) cerrado por C49.
- C46 / C47 → §4.2, §4.5: Noche entra al bloquear por defecto, opción "Pasar sola a Noche" 1 / 3 min solo desde la página (antes "a los 60 s, ajuste 1/3/nunca").
- C48 → §4.3, §4.4: regla única de interrupciones por ventana de la mañana (05:00-11:00, o fin de Manto −60 min; dentro nada reanuda, fuera todo reanuda con fundido de 3 s; `CXCallObserver`); la fila "Alarma del Reloj" y "Otra app toma el audio: no reanuda sola" sustituidas por la regla.
- C49 → §4.4: AirPods fuera = 40 ms de fundido y pausa (antes 3 s); "Seguir por el altavoz" 60 s; reanudación capada a 0,4 solo si la ruta cambió; `pauseCommand` con auriculares = fundido de 3 s, sin spike.
- C54 → §5e: las cadenas de evidencia (`breath.evidence.*`) se retiran en favor de `sabemos.2.afirmacion` / `sabemos.2.cuerpo` de 10 (sin diagnóstico, con n y cita); el enlace de la hoja es `sabemos.enlace`.
- C58 → §2.2, §9.7: Háptica vive también en Ajustes (grupo "háptica"); la hoja conserva la fila directa.
- C59 → cabecera, §3, §5b, §8, §12: toggle + línea de agua, nunca círculo (ya); "solo oleaje" declarado no-estado; valor hablado "{n} por minuto" (`marea.ritmo.exacto`) en la línea y el `Slider`; "Oleaje" fuera de todo texto de interfaz.
- C60 → §2.5: Madrugada con una sola tinta, "Se retira · n min" los últimos 5 min (E4), cierre silencioso, sin retirada luminosa en 1.0.
- C62 → §5d, §6: StandBy ≥ 24 pt y ≥ 3:1 bajo rojo medido (I0-6), plan B de 03 §3.1 (antes "4,43 bajo rojo A" y 22 pt).
- C63 → §5b, §3.14: Magic Tap en la raíz = play/pausa; `ax.horizonte.marea` como valor del Horizonte de E2 con Marea.
- C64 → §8: "chip" = StateWord o fila con estado (ya listado como fuera; se cita).
- C65 → §4.1: ningún tip; "Ninguna nota flotante, ningún tip".
- C66 / C67 → §10.2 P5 y P12: ≤ 6 estilos (la hoja usa 5); único `#available` en el Disco.
- §3 vocabulario → todo el documento: "Marea", "Descenso", "Manto", "Mar y viento", "Qué sabemos", "Se retira", "Empezar la prueba · 7 noches", "Pasar sola a Noche", "Madrugada · 20 min"; palabras que no se graban ("v1/v2", "Oleaje/Swell", "Escudo", "Mar lento", "chip", "Siesta" hasta 1.1) eliminadas o listadas como vetadas.
- §4 reparto / §5 alcance → §1 "Reparto", §2.6, columna V de §1: Marea Pro 1.0 (profundidad + ritual + toggle + línea + háptica Mínima opt-in); Madrugada para todos; gestos por textura 1.1; Marcada Watch 1.2; Salud 2.0; Live Activity 1.0 (A) / 1.1 (B); Papel 1.1 (C32, §6).

**Pasada de coherencia**

- Cadenas (10 §2.3, §5b, §5e.5, §5e.16, §5e.17) → §5e reescrito con las claves y los textos de 10 letra a letra: `marea.titulo`, `marea.instruccion` (EN "pulls back"), `sabemos.enlace` (antes "Por qué seis por minuto"), `marea.estado.*`, `marea.retira.hora` ("Se retira a las %@", antes "Se retira · %@"), `marea.retirada`, `marea.fase.*`, `marea.toggle`, `marea.ritmo.*`, `marea.descenso`, `marea.ritmo`, `marea.retira*`, `marea.haptica*`, `marea.oceano.subido` (40, antes "al cincuenta"), `ax.agua.*`, `ax.marea.*`, `ax.sabemos.pista`, `ax.haptica.pista`, `ax.horizonte.marea`, `siri.estado.marea`, `pro.incluye.marea`, `sabemos.2.*`. Lo que 10 no tiene (11 cadenas de 1.0 y 3 posteriores) va marcado (E7) y listado en §9.
- Tokens, tipografía y componentes (03 §3-§4, 04) → toggles `.tint(texto)` (03 §4.12; antes `índice` con cesión durante el arrastre: M7 simplificado, conteo de colores 0 / 1 bajo el dedo); `Slider` `.tint(texto)` (03 §4.2); fila con subtítulo 72 (03 §3.5); variante AC de `trazo-hoja` = `trazo-ac` (03 §3.1; §9.8 cerrada); banda de la página de 120 pt siempre que haya Marea disponible, sin crecer (03 §3.5, §4.1, 04 §2.0.3; M6 pasa a opacidad); nombres de 04 (`TideLine`, `StateWord`, `TextAction`, `EditorialRow`, `Hairline(.onSheet)`, `Grid.longPress`, `sheetPresented`); Papel marcado 1.1 (C32).
- Reparto y versiones (§4, §5) → §1 Reparto, §2.6, §5e "Después de 1.0" con la versión por fila.
- Discrepancias anotadas por la maqueta → nombre de la mezcla viva: este documento no la nombra; "Esta noche" (§3) queda como término reservado y ninguna mezcla "tiene" Marea (§4.1); hoja Capas: solo se cita como superficie de E2 (pulsación larga en la banda); cabecera de la página: la prueba vive ahí (03 §5 #15) y la hoja no la menciona; fila Temporizador en el primer uso: no aparece en este documento.

**Rechazos**

Ninguno.

**Notas (tensiones registradas, no rechazos)**

- 04 §2.3 ("arrastre vertical" en la hoja) y 04 §2.7 / §2.0.4 (toggle en `índice`) no han aplicado aún 03 consolidado; este documento sigue a 03 §4.12 y a C52 y lo anota en §9.9 para E1.
- 03 §5 #6 y 10 §2.3 siguen poniendo Háptica "bajo 'Más ajustes'" y 10 define `marea.mas`; esta entrega mantiene la fila directa decidida tras la puerta 2 (§9.15).
- 03 §4.3 y 10 `ax.agua.valor` devuelven la fase al valor de VoiceOver de la línea; se adopta y se anota el riesgo de desfase (§9, E7).
- 10 `pagina.estado.sonando.sin.marea` presupone una mezcla "con Marea"; con el formato v2 (C20) ninguna mezcla la tiene; se anota para E2/E7.
- `marea.retira.hora` "Se retira a las %@" tiene el caso de la una (§9.14); se adopta la cadena de 10 y se deja a E7.
- 07 §2.3.3 (Madrugada a 6/min, disolución desde el minuto 5) está pendiente de C05; este documento ya escribe 8/min y retirada hacia el minuto 13.
