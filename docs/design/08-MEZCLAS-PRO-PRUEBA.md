# SleepNoise · 08 · Mezclas, Pro, prueba y honestidad

**Equipo E5 (Mezclas, Pro, prueba y honestidad) · 16 de noviembre de 2026 · Documento 08 de la serie de diseño · Fase de especificación · revisión 3 (tras la puerta de los jurados, §11, y la reconciliación producto–diseño, §12)**

Pantallas del inventario de 03 §5 que cubre esta entrega: **12** Mezclas, **13** Guardar / renombrar (menú del nombre), **14** hoja Pro (título = `product.displayName`), **15** la prueba en la cabecera de la página, **16** primer uso completo, **17** Qué sabemos, **18** Ajustes, **30** Diagnóstico y la escalera del error de audio, **31** Cómo se genera, **32** Lo que no hay, **33** recibo (= estado comprado de la hoja Pro). De la pantalla **4** (página en la última noche de prueba, prueba terminada, error de audio) especificamos el texto, su posición y su comportamiento; la geometría de la página es de E2 (05) y aquí se cita con sus cotas (05 manda en geometría; 08 manda en la redacción de la prueba). La guía "Al acostarte" (una página de texto, C43) es la superficie 24 de E6 (09): aquí solo está la fila que la empuja.

**Insumos leídos completos**: `RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§0–§6: manda sobre 03 y sobre el plan; sus deltas para este fichero están aplicados en §12); `03-DIRECCION-DE-DISENO-2026-11-16.md` consolidado (§3 tokens, §4 componentes, §5 inventario y §8.3 puertas son ley); `04-SISTEMA-FUNDAMENTOS.md` (nombres de componentes y medidas); `10-GUIA-DE-COPY.md` consolidada (toda cadena de §5e coincide letra a letra con ella o está marcada "pendiente de E7" en §9); `05-PAGINA-Y-CAPAS.md` (geometría de la cabecera) y `07-TEMPORIZADOR-NOCHE-MADRUGADA.md` (fila Temporizador del primer uso); brief del director para E5; `tokens.md`, `grafts.md`, `decisions.md`; `00-BRIEF-CREATIVO` (P1-P12, listas negras); `02-MATERIALES`; `concepts/silencio.md` entero; de `grafito.md`, `marea.md` y `dial.md` las secciones de Noches / paywall / prueba / compra / Qué sabemos / Ajustes / error de audio / onboarding; el código de `main` (`AccessPolicy.swift`, `SoundID.swift`, `TrialClock.swift`, `PurchaseManager.swift`, `MixerModel.swift`, `MixStore.swift`, `SavedMix.swift`, `SavedMixesView.swift`, `PaywallView.swift`, `SleepTimerController.swift`, `BreathingGuideController.swift`, `SleepAudioEngine.swift`, `RenderState.swift`, `Localizable.xcstrings`); `INVESTIGACION-MERCADO-SUENO` §1, §5.1, §5.2, §7.3 y §9.1; `REVIEW-PR3` §"Encaje"; las cinco listas de la puerta de los jurados.

**Convenciones**: medidas en pt para 393 × 852 en tamaño Large (iPhone 17 Pro); SE = 375 × 667; 16e = 390 × 844 y se comporta como el 17 Pro con 8 pt menos de alto. **Toda cota del eje y es múltiplo de 4** (retícula de 03 §3.5); la cabecera de sección (versalita 13/18) mide **28** (18 de línea + 10 de aire inferior). Hex: solo los de 03 §3.1, citados por nombre de token (el único hex escrito es `trazo-ac` #3A3836 en §9.8). Pasos tipográficos 1-9 de 03 §3.4 / 04 §2.0.2. Textos de interfaz en ES con EN entre corchetes; son las cadenas que se compilan (§5e es el catálogo de E5 y sus claves son las de 10 §5e). **[a medir]** = no verificado en dispositivo. **[spike I0-n]** = depende de ingeniería con los nombres de la reconciliación C45 (I0-2 umbral LevelRule, I0-3 intents, I0-5/5b quietud y háptica, I0-6 contraste bajo rojo, I0-7 timbre en bus); el único spike propio de esta entrega es el opcional I0-9 (vigilante del motor, §9.17). "Pro" es siempre descripción; nunca etiqueta, nunca candado. Los números que se enseñan son los del código: `product.displayPrice`, `product.displayName`, `freeSavedMixLimit`, el estado de la prueba (reconciliación §1 regla 8).

**Tres reglas transversales, dichas una sola vez** (reconciliación §1 reglas 3 y 7; 03 §3.2 y §4.12):
- **Nada se vende de noche.** Una sola constante `NightWindow` = **21:00–07:00**: entre esas horas no se muestra ningún tip ni párrafo de sistema (se muestran en la siguiente apertura de día), **la hoja Pro no se abre por ninguna vía** (ni automática ni por toque: la versalita de cabecera es texto estático, la fila "pro" no hace nada, el ítem "Guardar como mezcla… · pro" no hace nada, la fila Pro de Ajustes no abre) y no hay recordatorio por la mañana (C08: `showPaywall` se consume sin cola). Lo mismo bajo Noche y Madrugada a cualquier hora. **Madrugada nunca abre la hoja Pro** (C05).
- **Página nocturna** es un estado de tinta **por procedencia**, no una hora: la página al volver de Noche; dura toda la sesión; sin salida por reloj a las 07:00; vuelve a la página de día al tocar el nombre de la mezcla (C40, 03 §3.2). En ella todo el texto va en `texto-noche`, nada por debajo de Medium, hairlines `trazo`, índice solo bajo el dedo. Mezclas y Qué sabemos heredan la fase de la página desde la que se abren (§2.1). Una primera apertura a las 23:08 sin haber pasado por Noche es **página de día** (`texto` / `texto2`); la hora solo rige `NightWindow`. La fase horaria interna es Día / Noche (`.day` / `.night`): "Descenso" es solo el ritual de la Marea (C14).
- **Todo texto de E5 que pueda aparecer sobre la página nocturna** (cabecera, línea de estado, peldaños del error, confirmaciones) va en `texto-noche` y peso Medium (03 §3.4, columna "De noche"); `TextAction` de 64 (03 §4.9).

**Reparto gratis/Pro que esta entrega enseña** (reconciliación §4; fuente de verdad `AccessPolicy.swift`): cinco texturas libres (blanco, rosa, marrón, lluvia, viento) y seis Pro (océano, ventilador, trueno, hoguera, arroyo, cabina), **nunca contadas** en la hoja ni en la ficha ("Todas las texturas", C04); el temporizador entero libre, sin la palabra "pro" (C03); la Marea Pro, y para todos en Madrugada (C05); tres mezclas guardadas gratis y sin límite con Pro (`freeSavedMixLimit` 1 → 3, `canSave` intacto); cuatro mezclas de la casa, las que incluyen Pro se cargan recortadas y nunca abren hoja (C18); prueba de 7 noches que empieza en la hoja Pro con la primera acción Pro, nunca con Play, estado en Keychain (C07); compra única 29,99 € de lista sin precio de lanzamiento (C02); "En familia" (Family Sharing) en 1.0 (C12); la degradación tras la prueba nunca escribe (C23). Once texturas en 1.0 (PR-A, C19); los ejemplos de este documento son de 1.0.

Lo que el PR #3 hizo mal y esta entrega resuelve a propósito: 14 candados para el usuario gratuito (aquí cero: lo bloqueado se describe), un paywall que no podía presentarse bajo Noche y quedaba "enganchado" (aquí de noche no se vende y nada queda pendiente), un preset Pro que seguía "seleccionado" al caducar la prueba sin decirlo (aquí el título dice "· sin Océano"), un temporizador forzado que se persistía (aquí nada se escribe sin que el usuario lo elija), un "Cerrar" redundante en cada pantalla empujada (aquí ninguno), una prueba que arrancaba sola al primer Play (aquí empieza con una decisión en la hoja Pro, C07), y textos de catálogo con pares mixtos (aquí cada clave lleva su contexto y su tope).

---

## 1. Intención (la pregunta P10 de cada pantalla)

| # | Pantalla | Pregunta a la que responde | Lo que no responde (vive en otra pantalla) |
|---|---|---|---|
| 12 | **Mezclas** (empujada desde la barra) | "¿Cuál de mis mezclas?" | Qué suena ahora (página), a qué nivel cada capa (Capas: hoja `.large` sobre `negro`, E2, 03 §4.10) |
| 13 | **Menú del nombre** + alertas Guardar / Renombrar | "¿Guardo esto, con qué nombre?" | Qué hay dentro (página, Capas) |
| 14 | **Hoja Pro** (`.large`; título = `product.displayName`) | "¿Cuánto, una vez, y qué sigue gratis?" | Por qué (lo demuestra el producto; la prueba de 7 noches es la demo, C06) |
| 15 | **La prueba** (texto en la cabecera de la página; nunca una hoja) | "¿Qué tengo y hasta cuándo?" | Cuánto cuesta (está a un toque, en la hoja Pro); cómo empieza (en la hoja Pro, C07) |
| 16 | **Primer uso** (la página sin nada encima) | "¿Suena?" | Todo lo demás, que se aprende usándolo |
| 17 | **Qué sabemos** (empujada) | "¿Qué sostiene cada frase de la app, y qué no?" | Qué comprar (no se vende nada aquí) |
| 18 | **Ajustes** (hoja `.large`) | "¿Qué decide la app por mí y cómo lo cambio?" | Ajustar el sonido (Capas, Marea, Temporizador) |
| 30 | **Diagnóstico** (empujada desde Ajustes) | "¿Puedo ayudar a arreglarlo?" | Arreglarlo (la escalera del error vive en la página) |
| 31 | **Cómo se genera** (empujada desde Ajustes) | "¿Por qué no se repite?" | Cuánto pesa (lo dice la fila de versión de Ajustes) |
| 32 | **Lo que no hay** (pie + página empujada desde Ajustes) | "¿Qué no hace la app?" | Qué sí hace (toda la app) |
| 33 | **Recibo** (= estado comprado de la hoja Pro) | "¿Qué tengo y desde cuándo?" | No es una pantalla aparte (C38) |

Regla transversal (P9): ninguna de estas pantallas se presenta sola. Mezclas, Ajustes, Qué sabemos, Lo que no hay, Cómo se genera y Diagnóstico se abren por toque en una palabra; la hoja Pro, solo por toque explícito en algo que dice "pro" o "Pro" y solo entre las 07:00 y las 21:00; la prueba es texto que no se interpone; el primer uso no tiene pantalla.

---

## 2. Anatomía de cada pantalla

Capas comunes a todas (03 §3.5, 04 §2.0.3): margen lateral 20; hairline 0,5 pt (`1 / displayScale`) de margen a margen, `trazo` sobre `negro`, `trazo-hoja` sobre `hoja`; filas 56 (lista) / 72 (con subtítulo), `EditorialRow` (03 §4.7); grupos a 32; radios 0 en lo propio; ningún icono salvo los del sistema donde el sistema los pone (chevron de empuje en `texto3` 13 pt **solo en filas que empujan** con `NavigationLink`; nunca en filas que presentan una hoja; toggles del sistema con `.tint(texto)`, 03 §4.12). Componentes propios que esta entrega usa: `HairlineAction` (03 §4.6 / 04 §2.6), `TextAction` (03 §4.9), `StateWord` (03 §4.8), `EditorialRow` (03 §4.7), hoja del sistema (03 §4.10), barra inferior (03 §4.11).

### 2.1 Pantalla 12 · Mezclas (empujada, `negro`)

Se llega desde la palabra "Mezclas" de la barra inferior (03 §4.11), desde Siri ("Pon Rosa y lluvia en ${applicationName}" carga sin abrirla; intent `PlayMix(MixEntity)`, C43) y, en 1.1, desde el widget mediano (carga y reproduce sin abrirla, C42). La barra inferior **permanece** (nada bloquea el sonido): el Disco sigue ahí. En la propia pantalla Mezclas el hueco izquierdo de la barra queda **vacío** (la palabra "Mezclas" no haría nada y el título ya la dice); la barra conserva el Disco y "Noche". **"Noche" desde Mezclas** → pop sin animación y Noche (2 s de opacidad; 250 ms con Reduce Motion); el sonido no se toca. Anotado para 03 §4.11 como estado "en Mezclas" (§9.16).

```
393 × 852 · Large · 1.0 (once texturas) · usuario gratuito tras la prueba, con dos mezclas propias
┌─────────────────────────────────────────────────────┐ y 0
│ ‹            (barra de navegación del sistema)      │ 59-103   solo el atrás del sistema; nada a la derecha
│                                                     │
│ Mezclas                                             │ 112-148  paso 3 · 22 Semibold texto · x 20
│ ───────────────────────────────────────────────────  │ 148      hairline trazo
│ tuyas                                               │ 164-192  cabecera 28: paso 9 versalitas texto2 (tracking +2 %)
│ Hotel                                  sonando ahora│ 192-264  fila 72: nombre paso 5 (y+12) · versalita de estado a la derecha
│ lluvia 45 · marrón 30                               │          receta paso 7 texto2 (y+36)
│ ───────────────────────────────────────────────────  │ 264      hairline
│ Ventilador y lluvia                                 │ 264-336  fila 72 (la receta cabe en una línea)
│ lluvia 50 · ventilador 30 · marrón 20 · ventilador  │
│ es Pro                                              │ 264-356  → fila 92 si la receta pasa a dos líneas (como aquí)
│ ───────────────────────────────────────────────────  │ 356
│                                                     │ 32 de aire
│ de la casa                                          │ 388-416  cabecera 28
│ Rosa y lluvia                                       │ 416-488  fila 72
│ lluvia 55 · rosa 20                                 │
│ ───────────────────────────────────────────────────  │ 488
│ Mar y viento                                        │ 488-560
│ océano 50 · viento 20 · océano es Pro               │
│ ───────────────────────────────────────────────────  │ 560
│ Marrón y hoguera                                    │ 560-632
│ marrón 40 · hoguera 30 · hoguera es Pro             │
│ ───────────────────────────────────────────────────  │ 632
│ Pared                                               │ 632-704
│ marrón 40 · lluvia 30 · viento 30                   │
│ ───────────────────────────────────────────────────  │ 704
│                                                     │ 32
│ Ajustes                                             │ 736-792  fila 56 · paso 6 Regular texto2 · sin chevron (abre una hoja)
│ ───────────────────────────────────────────────────  │ 792      (la lista desplaza 24 bajo la barra en Large con dos propias)
│                      ◉ (Disco 44/64)          Noche │ 769-818  barra inferior del sistema (03 §4.11), hueco izquierdo vacío
└─────────────────────────────────────────────────────┘ 852
```

Con dos propias la lista mide 792 y desplaza 24 bajo la barra en Large; con 3 propias (el máximo gratuito) desplaza 96; con Pro desplaza lo que haga falta; en xS-M (filas más bajas) cabe sin desplazar. "Ajustes" es la última fila de la pantalla, no un icono: es la única entrada a Ajustes de toda la app (decisión de E5, ver §9.1); va en `texto2` y a 32 de aire porque es salida, no mezcla. Las once texturas de 1.0 (C19) caben en la misma pantalla sin cambios: las recetas ganan nombres de capa; el ejemplo "Domingo de tormenta · trueno 30 · trueno es Pro" de 03 §1.3 es una propia como cualquier otra.

| Elemento | Estilo | Color (día / página nocturna) | Medidas | Comportamiento |
|---|---|---|---|---|
| Botón atrás | sistema | sistema (sin tinte: `texto` / `texto-noche`) | 44 × 44 | Vuelve a la página; también el gesto de borde del sistema (la lista no tiene arrastres propios, así que no colisiona). Nada a la derecha de la barra |
| Título "Mezclas" | paso 3 · 22/28 Semibold | `texto` / `texto-noche` | x 20, y 112; 36 de alto | Estático. Es `.header` para VoiceOver |
| Hairline | 0,5 pt | `trazo` | de margen a margen, y 148 | — |
| Cabecera de sección "tuyas" / "de la casa" | paso 9 versalitas Medium, tracking +2 % | `texto2` / `texto-noche` | 28 (13/18 + 10); y = inicio de sección | `.header` para VoiceOver |
| Fila de mezcla · nombre | paso 5 · 17/22 Semibold | `texto` / `texto-noche` | x 20, y + 12; una línea; `minimumScaleFactor(0.8)` solo aquí (nombre escrito por el usuario); 24 caracteres máx. (`mezcla.guardar.campo` corta a 24, como la página de E2) | Toda la fila es un `Button` |
| Fila de mezcla · receta | paso 7 · 15/20 Regular (Medium en página nocturna) | `texto2` / `texto-noche` | y + 36; hasta 2 líneas; "{capa} es Pro" en la misma tinta, al final, separado por " · " | Describe; no promete; no se trunca (la fila crece a 92) |
| Fila de mezcla · estado | paso 9 versalitas (`StateWord`); **en página nocturna paso 7 Medium sin versalitas** (03 §3.4: versalitas nunca para un dato que se consulte de noche) | `texto2` / `texto-noche` | derecha, alineada al nombre | "sonando ahora" si esta mezcla es la cargada y suena; nada en las demás (lo cargado y en pausa lo dice el nombre de la página) |
| Fila · pulsada | fondo | `grafito` | toda la fila | 200 ms `.easeInOut` (03 §4.7) |
| Hairline entre filas | 0,5 pt | `trazo` | de margen a margen | — |
| Deslizar fila propia | sistema `.swipeActions` | sistema ("Eliminar" en el rojo del sistema; "Renombrar" sin tinte) | — | `allowsFullSwipe: false`: nunca se elimina de un gesto. **Desactivadas en página nocturna** (renombrar, eliminar y reordenar son de día; el toque = cargar y las acciones de VoiceOver siguen) |
| Reordenar fila propia | `onMove` del sistema: pulsación larga y arrastre, sin modo edición | sistema | — | Solo en "tuyas" y solo de día. Sin `EditButton`: la barra no lleva nada a la derecha. Alternativa sin gesto: "Subir" / "Bajar" en el `contextMenu` de la fila (§5c) |
| Fila "Ajustes" | paso 6 · 17/22 Regular (Medium en página nocturna) | `texto2` / `texto-noche` | 56; sin chevron | Abre Ajustes (hoja `.large`, 2.7). Es salida, no mezcla: a 32 de aire del último grupo |
| Vacío de "tuyas" | paso 6 · 17/22 Regular | `texto2` / `texto-noche` | fila 72, x 20, una o dos líneas | "La mezcla de esta noche se guarda desde su nombre." (`mezclas.vacio`; sin imperativo: con Button Shapes no debe parecer un botón). Sin icono. No es botón (el nombre está en la página) |
| Barra inferior | sistema (03 §4.11) | sistema | 49 + área segura | Hueco izquierdo vacío; Disco; "Noche" (→ pop sin animación + Noche). "Mezclas" no aparece en su propia pantalla |

**Página nocturna en Mezclas** (hereda la fase de la página, 03 §3.2): una sola tinta `texto-noche` para título, cabeceras, nombres, recetas, estado y "Ajustes"; pasos 6 y 7 en Medium; el estado "sonando ahora" deja las versalitas; sin deslizar ni reordenar; hairlines `trazo`; el botón atrás sin tinte. Vuelve a la página de día con la página (al tocar el nombre de la mezcla; nunca por reloj, C40); el cambio es el de la página (2 s de opacidad; 250 ms con Reduce Motion). Ninguna medida cambia.

**Mezclas de la casa** (C17, C18; 03 §5 #12; nombres que describen y no prometen, nunca textura + adjetivo): **"Rosa y lluvia"** ["Pink and rain"] = lluvia 55 · rosa 20 (libre); **"Mar y viento"** ["Sea and wind"] = océano 50 · viento 20 (Pro: se carga recortada sin acceso, como una mezcla guardada, y nunca abre la hoja); **"Marrón y hoguera"** ["Brown and fire"; es-419 "Marrón y fogata"] = marrón 40 · hoguera 30 (Pro, carga recortada); **"Pared"** ["Wall"] = marrón 40 · lluvia 30 · viento 30 (libre). Son recetas de niveles: **nunca cambian el temporizador** ni la Marea. Los nombres por problema ("para ronquidos") se deciden en 1.1 con dato. No se renombran, no se eliminan, no se reordenan: deslizar sobre ellas no hace nada (§8).

**Receta** (formato de mezcla v2, C09/C20: `[{id, level}]` + `version: 2`, solo pares id + nivel): capas con nivel > 0 ordenadas por nivel descendente, nombre en minúscula; valor entero; " · " (`mezclas.receta.separador`, U+00B7 con espacios finos U+2009) como separador que admite partir línea; ninguna pieza de Marea ni de temporizador (la mezcla no los guarda). La parte Pro del usuario sin acceso va al final como frase: "· ventilador es Pro" (`mezclas.receta.pro`; con dos o más capas Pro, "· trueno y océano son Pro": §9, pendiente de E7). Nada tachado, nada en `texto3`, ninguna opacidad.

### 2.2 Pantalla 13 · Menú del nombre, Guardar y Renombrar

El nombre de la mezcla en la página (paso 2, E2; "Esta noche" mientras la mezcla viva no sea una guardada sin modificar, reconciliación §3) lleva un `contextMenu` del sistema (pulsación larga; con VoiceOver, acciones personalizadas; con Control por botón, el menú del elemento). Guardar y Renombrar son las dos únicas entradas de texto de la app, y las dos son la **alerta del sistema con `TextField`** (03 §4.12: `TextField` del sistema; una misma anatomía para las dos, sin hoja propia ni geometría de teclado que medir). **En página nocturna la pulsación larga no hace nada** (guardar, renombrar y vaciar son de día; 03 §3.2 / C40: tocar el nombre devuelve la página a la página de día, y entonces el menú vuelve a existir).

```
contextMenu del sistema sobre "Esta noche"
┌──────────────────────────────┐
│ Guardar como mezcla…         │   ← "Guardar como mezcla… · pro" cuando ya hay 3 propias y no hay acceso
│ Guardar en «Hotel»           │   ← solo si la mezcla viva viene de una propia y ha cambiado
│ Renombrar                    │
│ Vaciar                       │
└──────────────────────────────┘

alerta del sistema "Guardar como mezcla"
┌──────────────────────────────┐
│     Guardar como mezcla      │   título = `guardar.titulo` (§9, pendiente de E7)
│ ┌──────────────────────────┐ │
│ │ Nombre de la mezcla      │ │   TextField del sistema; placeholder `mezcla.guardar.campo`; prefijado con el nombre de la página
│ └──────────────────────────┘ │   si no es "Esta noche"
│   Cancelar    |    Guardar   │   `comun.cancelar` / `comun.guardar`
└──────────────────────────────┘
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Ítem "Guardar como mezcla…" ["Save as a mix…"] | menú del sistema | sistema | — | Abre la alerta Guardar. Si `mixes.count ≥ AccessPolicy.freeSavedMixLimit` (3) y no hay acceso completo: el ítem dice "Guardar como mezcla… · pro" (`mezcla.menu.guardar.pro`) y, **de día**, abre la hoja **Pro** en lugar de la alerta; entre las 21:00 y las 07:00 no hace nada (`NightWindow`: nada se vende de noche). La mezcla viva no se pierde en ningún caso: sigue cargada y sonando |
| Ítem "Guardar en «{nombre}»" ["Save to “{name}”"] | menú del sistema | sistema | — | Sobrescribe la receta de esa mezcla con lo que suena, **conservando las capas Pro silenciadas a su nivel** (C23: guardar conserva el nivel sin diálogo). Gratis siempre (no crea una cuarta). Solo aparece si la viva procede de una propia y difiere de ella. Clave `menu.guardar.en` (§9, pendiente de E7) |
| Ítem "Renombrar" ["Rename"] | menú del sistema | sistema | — | `.alert` del sistema con `TextField` (prefijado con el nombre), botones "Guardar" (`comun.guardar`) / "Cancelar" (`comun.cancelar`); título `comun.renombrar`. Renombra la mezcla cargada; si está guardada, también en Mezclas. Vacío = no cambia nada |
| Ítem "Vaciar" ["Clear"] | menú del sistema | sistema | — | Si suena: `engine.stop(fadeOut: 1.5)` (envolvente maestra, ya existe) y después `levels = 0`; si no suena, `levels = 0` en seco. Después `endPlayback`; el nombre pasa a "Esta noche" (`mezcla.nombre.vacio`); la línea de estado de E2 dice "En silencio". Sin confirmación: es reversible cargando una mezcla (`ax.vaciar.pista`). La mezcla guardada de la que venía no se toca. Solo de día (ver arriba) |
| Alerta Guardar · campo | `TextField` del sistema, placeholder "Nombre de la mezcla" (`mezcla.guardar.campo`) | sistema | — | Prefijado con el nombre de la página cuando la viva viene de una propia; vacío (solo placeholder) cuando la viva es "Esta noche". Retorno = Guardar; 24 caracteres máx. (`SavedMix` ya recorta); vacío al guardar → se guarda como "Esta noche" ("Esta noche 2", …) en lugar de "Mezcla {n}" |
| Alerta Guardar · "Guardar" | botón de la alerta (`comun.guardar`) | sistema | — | Guarda **la receta completa** (también las capas Pro silenciadas a su nivel guardado, C23), cierra la alerta, háptico `.success`, anuncio "Guardada"; en la página, **en el hueco de la línea de estado** (una línea paso 7, E2), 3 s: "Guardada" (`mezclas.guardada`). Nunca una línea nueva, nunca una pregunta |

Las tres mezclas gratuitas (reconciliación §1 regla 3 y §4; `freeSavedMixLimit` pasa de 1 a 3, §9.5; `canSave` sigue sin límite con acceso completo): la primera, la segunda y la tercera se guardan sin que nada mencione un límite. La cuarta lo dice en el menú (" · pro"), no con una hoja encima del teclado. Las guardadas no se borran nunca por caducar la prueba (`MixStore` no las toca) y guardar nunca quita una capa Pro: el día que compra, la mezcla vuelve entera (C23). Por eso no existe "Guardada sin {capa} · Conservar {capa}": la receta ya conserva la capa; lo que no suena lo dice la receta en Mezclas ("· ventilador es Pro") y la línea de estado de la página ("Sonando · sin ventilador"). Anotado en §9.19 porque 03 §5 #12 y 10 §5e.9 aún llevan esas cadenas.

### 2.3 Pantalla 14 · Hoja Pro (hoja `.large`, `hoja`; título = `product.displayName`)

Se abre solo por toque explícito y **solo entre las 07:00 y las 21:00, en página de día, fuera de Noche y Madrugada** (`NightWindow`, reconciliación §1 regla 7): la versalita de cabecera de la página ("gratis siempre" / "prueba · quedan n noches"), una fila "pro" de Capas o de la página (C06: el toque abre la hoja; no hay escucha de 30 s en 1.0), el toggle "pro" de la Marea (E3), el ítem "Guardar como mezcla… · pro" con tres propias, y la fila Pro de Ajustes. Nunca al abrir la app, nunca al parar el sonido, nunca por una ruta automática, nunca de noche, nunca desde Madrugada (C05), nunca desde el temporizador (C03: no hay nada Pro en él). Lo que suena sigue sonando debajo: la hoja es `.large`, no pantalla completa. El horizonte, cubierto por la hoja, se congela a hairline `trazo` en ≤ 2 s (03 §3.7); no se ve: se oye. **El único acento con la hoja delante son las dos hairlines de Comprar.**

`Product.products(for:)` se pide al arrancar la app (ya lo hace `PurchaseManager.start()`) y se repite al volver a primer plano y al presentar la hoja (§9.5); la hoja casi siempre abre con precio. Coordenadas relativas al borde superior de la hoja (alto útil ≈ 808 en 17 Pro; ≈ 633 en SE).

```
Estado "precio cargado", prueba no usada, usuario gratuito, 1.0 (once texturas)
┌─────────────────────────────────────────────────────┐ 0      indicador del sistema
│ sleepnoise pro                                      │ 24-42  paso 9 versalitas texto2 · product.displayName
│                                                     │
│ 29,99 €                                             │ 48-112 paso 1 · 56/64 Display Regular tabular texto (displayPrice: el que se cobra)
│ Una vez.                                            │ 116-134 paso 8 texto2 · siempre (injerto de 03 §1.3)
│                                                     │
│ Un solo pago. Para siempre,                         │ 152-220 paso 2 · 28/34 Display Medium texto · 2 líneas
│ en todos tus iPhone.                                │
│ ───────────────────────────────────────────────────  │ 244    hairline trazo-hoja
│ con pro                                             │ 252-280 cabecera 28 · versalitas texto2
│ Todas las texturas                                  │ 280-324 fila 44 · paso 6 · 17/22 Regular texto
│ Océano, ventilador, trueno, hoguera, arroyo y cabina│          detalle paso 7 texto2 (sin cifra: C04)
│ Marea                                               │ 324-368 fila 44 · paso 6 texto · sin hairlines entre filas
│ Mezclas sin límite                                  │ 368-412
│ En familia                                          │ 412-456
│ ───────────────────────────────────────────────────  │ 472    hairline trazo-hoja (solo entre bloques)
│ gratis siempre                                      │ 480-508 cabecera 28
│ Blanco, rosa, marrón, lluvia y viento · todo el     │ 508-552 paso 6 · 17/22 Regular texto2 · 2 líneas
│ temporizador · tres mezclas                         │
│ ·  ·  ·  ·  ·  ·  ·  (zona que desplaza) ·  ·  ·  · │ 576    fin de la columna (552 + 24)
├═════════════════════════════════════════════════════┤ 576    pie fijo (safeAreaInset inferior, 232 de alto con la prueba sin usar, fondo hoja)
│ ───────────────────────────────────────────────────  │ 576    hairline trazo-hoja 0,5 pt (borde superior de Empezar la prueba)
│            Empezar la prueba · 7 noches             │ 576-640 HairlineAction 64 · 17 Semibold texto · acción primaria mientras la prueba no se ha usado
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ 640    hairline 1,5 pt índice (borde superior de Comprar)
│                Comprar · 29,99 €                    │ 640-704 HairlineAction 64 · 17 Semibold texto
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ 704    hairline 1,5 pt índice
│ Restaurar compra                           Ahora no │ 704-748 TextAction 44 · 17 Regular texto2 (izquierda x 20 / derecha x 373)
│ Sin suscripción. Sin cuenta. Sin rastreo.           │ 752-770 paso 8 texto2 · centrado (3 líneas reservadas: 752-806; la línea de resultado lo sustituye mientras dura)
└─────────────────────────────────────────────────────┘ 808
```

El bloque Empezar / Comprar / Restaurar · Ahora no / pie es un `safeAreaInset(edge: .bottom)` sobre la hoja: siempre a la vista, también en SE y en AX, donde la columna superior desplaza (SE: ≈ 175 pt con la prueba sin usar). Con la prueba ya usada o en curso, la fila "Empezar la prueba · 7 noches" no existe y el pie fijo mide 168 (Comprar 64 + Restaurar · Ahora no 44 + pie 60 con 3 líneas reservadas): la columna cabe en 17 Pro sin desplazar (576 + 168 = 744 ≤ 808). El precio es lo primero que se lee y Comprar lo último que cuesta dinero; entre ambos no hay nada que tocar. Las hairlines de la hoja son: la de 244, la de 472 (entre bloques), la `trazo-hoja` que abre el pie fijo y las dos `índice` de Comprar (con la prueba sin usar, la primera de Comprar es también el borde inferior de "Empezar la prueba": una hairline, dos filas); el pie fijo no lleva hairline propia. "Empezar la prueba" va entre `trazo-hoja` arriba e `índice` abajo porque el único borde de acento de la app es el del único botón que cuesta dinero (03 §4.6, 04 §2.6); 03 §5 #14 escribe las dos "entre hairlines de índice" y se anota en §9.8 para E1.

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Versalita `pro.titulo` | paso 9 versalitas, tracking +2 % | `texto2` | x 20, y 24 | `product.displayName` en minúscula tipográfica (hoy "SleepNoise Pro"); nunca un nombre grabado, nunca "Tu instrumento" (C12). Única aparición del nombre dentro de la app junto con Ajustes. `.header` |
| Precio | paso 1 · 56/64 Display Regular, tracking −1 %, `monospacedDigit` | `texto`; "—" en `texto3` (56 pt ≥ 18: permitido) | x 20, y 48; `relativeTo: .largeTitle`, tope `.accessibility2` (79 pt) | `Product.displayPrice` literal (moneda del usuario, nunca escrito a mano; un solo precio, sin lanzamiento ni tachadura, C02). "—" (`pro.precio.cargando`) hasta que StoreKit responde; el cambio es `.contentTransition(.opacity)` 250 ms (nunca `numericText`: 03 §3.7 lo reserva a "+15 min") |
| "Una vez." | paso 8 · 13/18 | `texto2` | y 116, 18 de alto; siempre presente | `pro.una_vez`. Dice el modelo de pago debajo de la cifra (03 §1.3). El hueco no cambia por estado |
| Titular | paso 2 · 28/34 Display Medium | `texto` | y 152, 2 líneas (3 en EN xxxLarge) | `pro.pie` "Un solo pago. Para siempre, en todos tus iPhone." |
| Cabecera "con pro" / "gratis siempre" | paso 9 versalitas | `texto2` | 28 | `.header` |
| Filas "con pro" (4) | paso 6 · 17/22 Regular; la primera con detalle paso 7 · 15/20 | `texto`; detalle `texto2` | 44 cada una, **sin hairlines entre ellas** (el aire agrupa; una hairline solo entre bloques) | Texto estático sin icono ni marca (03 §5 #14: lista). "Todas las texturas" + "Océano, ventilador, trueno, hoguera, arroyo y cabina" (lista nombrada, nunca contada: C04; en es-419, fogata) · "Marea" (C15) · "Mezclas sin límite" · "En familia" (Family Sharing en 1.0; la lista termina aquí, C12). El temporizador no está: es entero libre (C03) |
| Párrafo "gratis siempre" | paso 6 · 17/22 | `texto2` | 2 líneas | `pro.gratis.lista` "Blanco, rosa, marrón, lluvia y viento · todo el temporizador · tres mezclas". Es la rama libre de `AccessPolicy` (con `.wind`, C04) más el temporizador (C03) y `freeSavedMixLimit` (3); la lista libre solo crece |
| **Empezar la prueba · 7 noches** | `HairlineAction` (03 §4.6) | texto `texto`; hairline superior `trazo-hoja` 0,5 pt; la inferior es la `índice` de Comprar | 64 a todo el ancho, primera fila del pie fijo; **solo mientras la prueba no se ha usado** (`trialState == .notStarted`) y sin Pro | `pro.prueba.empezar`. Toque → `startTrial()` (nuevo; sale de `play()`, C07): la fecha de inicio va al Keychain; la hoja se cierra sola (animación del sistema); la página aparece ya con la versalita "prueba · quedan 7 noches" (M6) y, si la hoja se abrió desde una capa Pro o desde la Marea, **esa capa entra con fundido de 800 ms** a su nivel guardado o por defecto (`updateGains(_, ramp: 0.8)`, §9.5): la prueba se oye. Sin hoja del sistema, sin cobro, sin tarjeta. Pulsado: opacidad 0,6 200 ms. Debajo no lleva nota propia en el pie fijo: `pro.prueba.empezar.nota` vive en la pista de VoiceOver (`ax.prueba.empezar.pista`) y en la columna **solo en AX3+**, donde el pie ya desplaza (§5d); en Large el titular y "gratis siempre" ya dicen lo que la nota dice |
| **Comprar** | `HairlineAction` (03 §4.6) | precio cargado: texto `texto`, **hairlines 1,5 pt `índice`** (el único borde de acento de la app; 03 §3.1 regla 1 y §4.6 consolidados); sin precio: texto **`texto2`** (17 pt < 18: `texto3` no está permitido para texto, 03 §3.1; 6,06:1 sobre `hoja`; 03 §4.6 y 04 §2.6 escriben `texto3`: §9.8), hairlines `trazo-hoja` 0,5 pt; en curso: texto `texto2` "Comprando…" | 64 a todo el ancho, en el pie fijo | `pro.comprar` "Comprar · {displayPrice}". Lanza `product.purchase()`; pulsado: opacidad 0,6 200 ms. Deshabilitado (`product == nil` o `isPurchasing`) para el sistema y para VoiceOver (`.notEnabled`); lo que lo distingue del cargado es el grosor y color de las hairlines y la ausencia de cifra (`pro.comprar.sin_precio` "Comprar"; lo mismo que §6 "Escala de grises" usa) |
| Restaurar compra | `TextAction` 17 Regular | `texto2` | 44, alineado a x 20 | `pro.restaurar`. `AppStore.sync()` con tope de 10 s (§9.5); el texto pasa a "Buscando…" (`pro.buscando`) mientras |
| Ahora no | `TextAction` 17 Regular | `texto2` | 44, alineado a x 373, en la misma fila que Restaurar (≥ 24 entre objetivos, 03 §3.5) | `comun.ahora_no`. Cierra la hoja y nada más: es el toque simple que cierra una hoja `.large` para quien no usa gestos (03 §4.9 la nombra; §9.13). Nunca aplaza ni programa nada |
| Pie | paso 8 | `texto2` | centrado, 1 línea (2 en EN AX) | `lo_que_no_hay.pie` "Sin suscripción. Sin cuenta. Sin rastreo." (C09; literal en 1.0: la entrega no sincroniza nada; en 1.1 la clave gana "Tus mezclas, en tu iCloud si quieres.") |
| Línea de resultado (fallo, sin confirmar, pendiente, restaurar sin nada, sin tienda) | paso 8 · 13/18 | `texto2` | **ocupa el lugar del pie** (contenido, no altura; hasta 3 líneas en el mismo hueco: el pie fijo siempre reserva 3 líneas = 54 + 6 de aire, de ahí 60) | Aparece 250 ms opacidad; se queda hasta cerrar la hoja o reintentar; al irse, vuelve el pie. **Ningún rojo** (03 §3.1: `error` no existe) |

**Estado "comprado" = el recibo** (03 §5 #33, C12; Pro activo; se llega desde Ajustes › fila Pro "SleepNoise Pro · gracias · 16 nov 2026"): la versalita pasa a `pro.ajustes.gracias` "{displayName} · gracias · {fecha}" (+ `pro.ajustes.familia` "· en familia" si `transaction.ownershipType == .familyShared`); en el lugar del precio, paso 2 `pro.gracias` "Gracias. Todo abierto."; "Una vez." y el titular se quedan (es lo que se pagó); listas iguales (es lo que se tiene); pie fijo sin Comprar ni Empezar: `TextAction` **"Escribir una reseña"** (`pro.resena`, C55: la única petición de reseña de la app; abre App Store; como toda la hoja, nunca de noche) a x 20, "Restaurar compra" a x 373 en la misma fila de 44, y el pie de privacidad. Sin `requestReview` en 1.0 (política dormida tras bandera, se decide en 1.1 con dato) y sin fila "Valorar" en Ajustes.

### 2.4 Pantalla 15 · La prueba como texto en la página

Nunca una hoja, nunca una notificación, nunca una cuenta atrás, **nunca arranca sola**: la prueba empieza con "Empezar la prueba · 7 noches" en la hoja Pro (C07), a la que se llega con la primera acción Pro; `startTrialIfNeeded()` sale de `play()`; el estado vive en el Keychain (sobrevive a reinstalar: quien la empezó, la empezó; `TrialClock` cambia de `UserDefaults` a Keychain y su comentario se sustituye por la razón de C07). En la página la prueba es texto en la cabecera editorial (E2 dibuja la página; aquí se fijan el texto y su vida; las cotas son las de 05 §2.1). Paleta de la página: `negro`; en la página nocturna la cabecera va en `texto-noche` Medium y es texto estático; en `NightWindow` (21:00–07:00) no se muestra ningún párrafo (se muestra en la siguiente apertura de día) y la versalita no es botón. **Nada cambia de posición**: la cabecera ocupa un renglón de 18 (64-82; área táctil 52-96 de día) que existe siempre, también vacío; el nombre está siempre en 100-134; la nota de una vez ocupa 196-256 solo en silencio y, cuando no está, el hueco queda vacío.

```
Cabecera de la página · Large · cotas de 05 §2.1 (solo el tramo 59-296; debajo, la página de E2)
          SIN PRUEBA (instalación nueva)           PRUEBA · NOCHES 1-6                 ÚLTIMA NOCHE (de día)               PRUEBA TERMINADA (primera apertura de día)
┌───────────────────────────────┐   ┌───────────────────────────────┐   ┌───────────────────────────────┐   ┌───────────────────────────────┐ y 59 (área segura)
│ gratis siempre                │   │ prueba · quedan 5 noches      │   │ prueba · última noche         │   │ gratis siempre                │ 64-82   versalita paso 9 texto2 · botón 44 (52-96) de día
│ Esta noche                    │   │ Esta noche                    │   │ Mar y viento                  │   │ Mar y viento · sin Océano     │ 100-134 paso 2 (E2)
│ En silencio                   │   │ En silencio                   │   │ Última noche con todo. Mañana,│   │ En silencio                   │ 144-164 línea de estado paso 7 texto2 (E2); aquí `prueba.ultima` hasta el Play
│                               │   │                               │   │ lo gratis sigue gratis.       │   │                               │ 164-184 línea 2 (vacía; en la última noche, la 2.ª línea de `prueba.ultima`)
│                               │   │                               │   │                               │   │ La prueba terminó. Lo que     │ 196-236 nota de una vez · paso 7 texto2 · 1-2 líneas · solo en silencio
│                               │   │                               │   │                               │   │ usaste sigue aquí.            │
│                               │   │                               │   │                               │   │ Entendido                     │ 234-256 TextAction 17 Regular texto2 (área táctil 212-256), x 20
│ ─────── horizonte ─────────── │   │ ─────── horizonte ─────────── │   │ ─────── horizonte ─────────── │   │ ─────── horizonte ─────────── │ 284 (banda 272-296, E2)
└───────────────────────────────┘   └───────────────────────────────┘   └───────────────────────────────┘   └───────────────────────────────┘
```

| Momento | Cuándo | Texto | Estilo / color | Vida |
|---|---|---|---|---|
| **Sin prueba** | `trialState == .notStarted` y sin Pro (instalación nueva, hasta la primera acción Pro) | Versalita `pro.prueba.estado.gratis` "gratis siempre". **Ningún párrafo la primera noche** (C07: la prueba no arranca sola, no hay nada que explicar; lo gratis lo enumera la hoja Pro, a un toque) | versalita paso 9 `texto2` (`texto-noche` Medium en página nocturna) | Toque de día → hoja Pro con "Empezar la prueba · 7 noches". Dura siete sesiones gratuitas (siete Play sin acceso completo; contador en `UserDefaults`, §9.5) y después desaparece: la entrada a Pro sigue en cada fila "pro", en la Marea y en Ajustes. El contador se pone a cero al empezar la prueba |
| **Prueba · noches 1-6** | `trialState == .active(n)`, n ≥ 2 | Versalita `pro.prueba.estado` "prueba · quedan {n} noches" (plural del catálogo; con n = 1 la clave `one` no se usa: ver la fila siguiente) | paso 9 versalitas `texto2`; `texto-noche` Medium en página nocturna | Desde el toque en "Empezar la prueba" (M6) hasta el fin. **Toque → hoja Pro solo de día y en página de día; en página nocturna o en `NightWindow` la versalita es texto estático.** No crece, no cambia de sitio, no parpadea; n cambia en seco al abrir la app. n = noches de calendario locales que quedan hasta el fin (§9.3) |
| **Última noche** | n = 1 | Versalita `pro.prueba.estado.ultima` "prueba · última noche"; de día, en el lugar de la línea de estado y hasta el Play, `prueba.ultima` "Última noche con todo. Mañana, lo gratis sigue gratis." (2 líneas: estado + línea 2; sin botón) | versalita como arriba; la frase paso 7 `texto2`, Regular | La frase muere al Play o al pasar a Noche; no vuelve. En `NightWindow` solo la versalita |
| **Prueba terminada** | Primera apertura **de día** con `trialState == .ended` y sin Pro | Versalita "gratis siempre" (la misma que sin prueba; siete sesiones) + nota de una vez `prueba.terminada` "La prueba terminó. Lo que usaste sigue aquí." + "Entendido" (`comun.entendido`). Lo que espera a Pro ya se ve inline en las filas ("pro · 30", C23): la nota no lo enumera | nota paso 7 `texto2` 15/20, 1-2 líneas; "Entendido" `TextAction` 17 Regular `texto2`, 44 | Nota: hasta "Entendido", hasta el Play (05: la nota solo existe en silencio) o hasta la siguiente apertura de día, lo que llegue antes. Versalita: siete sesiones y después desaparece para siempre; la información queda en la hoja Pro y en Ajustes (03 §1.2). Toque → hoja Pro con las mismas condiciones que en la prueba |
| **Pro comprado** | `isPro` | Nada. La cabecera no existe; su renglón de 18 queda vacío y el nombre sigue en 100 (nada sube) | — | La versalita se va por M6 (opacidad) |

**Cuándo caduca** (03 §1.3 Dial + código): la prueba se evalúa al terminar de verdad una sesión (`endPlayback(canDowngrade: true)`: fundido completo, pausa del usuario, fin del temporizador) y al arrancar la siguiente; **nunca** a medianoche, nunca al reanudar tras una interrupción (`canDowngrade: !resumeAfterInterruption`), nunca en Madrugada. Nada cambia mientras suena: ni la página, ni la Live Activity, ni el widget. Si la prueba agota sus siete días a las 03:10 con océano sonando, océano suena hasta el fundido y la cabecera no cambia hasta la siguiente apertura de la página. El fin es `start + 7 × 86 400 s` desde el toque en "Empezar la prueba"; **la cifra de la versalita es otra cosa**: n = noches de calendario locales entre el inicio del día de hoy y el inicio del día del fin (`Calendar.current`), con suelo 1 → "última noche" (§9.3). Quien empieza a las 23:00 lee "quedan 6 noches" toda la segunda noche, que es verdad. **La degradación nunca escribe** (C23): las capas Pro conservan su nivel y muestran "pro · N" (E2); `endPlayback(engineAction:canDowngrade:)` no toca `SavedMix`.

**De noche no se vende y no hay mañana** (C08): si el usuario toca una capa Pro, la Marea o la versalita entre las 21:00 y las 07:00, o bajo Noche o Madrugada, **no pasa nada**: la fila sigue diciendo "pro" (o "pro · 30"), el toggle sigue diciendo "pro", y nada se anota para la mañana. `showPaywall` se consume sin cola. Resuelve el paywall "enganchado" del PR #3 por el camino corto: nada queda pendiente de presentarse.

### 2.5 Pantalla 16 · Primer uso (completo)

No hay onboarding, pantalla de bienvenida, carrusel, permiso ni valoración (00 §7.1; C33: la app abre en reposo y suena con Play; el autoarranque existe solo vía Atajos "Al acostarte"; no hay ajuste "abrir sin sonar"). La primera pantalla es la página en reposo con **"Esta noche"** cargada (receta de 05 §2.11: Lluvia 30 · Rosa 50; `defaultLevels()` cambia, §9.4), el horizonte en hairline, la versalita "gratis siempre" y la barra. Play suena en < 1 s (el motor se crea perezosamente; ya es así en `main`).

| Momento | Qué aparece | Qué se aprende | Cuándo se retira |
|---|---|---|---|
| 0 s · abre | La página: versalita "gratis siempre" (botón de día, texto estático de noche), "Esta noche", "En silencio", el horizonte quieto, dos filas-control (Lluvia 30, Rosa 50), "Todas las capas" (abre la hoja Capas `.large` sobre `negro`, E2), "Marea" con toggle off (`.tint(texto)`), **"Temporizador · Hasta dormirme · 45 min"** (07 §2.1.4: 45 min por defecto desde la primera noche; la fila enseña el ajuste, no la cuenta), barra "Mezclas · ◉ · Noche". Ningún párrafo (C07) | Que no hay nada que configurar y que lo que hay es gratis | La versalita, tras siete sesiones gratuitas o al empezar la prueba |
| Toca el Disco | Suena en 800 ms; `.impact(.medium, 0.7)`; el horizonte nace en `índice`; estado "Sonando · se funde a las {hora}" (E2/E4). **La prueba no arranca** (C07) | Toque = suena; el color significa sonido | — |
| Primer arrastre sobre una fila | La fila responde (E2; horizontal = nivel, C52; pulsación larga = `Slider` del sistema, C21) | La fila es el control | — |
| **Segundo** arrastre, de día | Tip único de la vida de la app, TipKit (03 §4.12), una línea paso 7 `texto2` bajo la fila, sin fondo ni flecha, 6 s: "Arrastra sobre el nombre para cambiar el nivel." (`tip.arrastre`) | Que el arrastre es relativo y vive en la fila | A los 6 s; `maxDisplayCount = 1`. Solo fuera de `NightWindow`: si el segundo arrastre es de noche, el tip espera al segundo arrastre de la primera apertura de día (C65) |
| Toca "Mezclas" por primera vez | Mezclas con "tuyas" vacía ("La mezcla de esta noche se guarda desde su nombre.") y las cuatro de la casa | Que hay mezclas de la casa y dónde se guarda | — |
| Toca una capa Pro (océano, ventilador…) de día | La hoja Pro con "Empezar la prueba · 7 noches" arriba del pie fijo (C06, C07). Toca "Empezar": la hoja se cierra, la cabecera dice "prueba · quedan 7 noches" y la capa entra con fundido de 800 ms | Que la prueba es una decisión y que se oye | — |
| Toca una capa Pro de noche | Nada (C08). La fila sigue diciendo "pro" | Que de noche no se vende | — |
| Bloquea con sonido | Live Activity (E6; solo escenario A, C25) o el Reproduciendo del sistema | Que desde ahí se pausa y se prolonga | — |
| Primera Noche | Las dos frases de Noche (E4; texto fijo, no tips, C65) | — | — |
| Prueba terminada | 2.4 | Qué sigue gratis (todo lo que suena), dónde está Pro | — |
| Nunca | Permiso de notificaciones (no hay), de micrófono (fuera de alcance), de Salud (2.0, C34), de movimiento (C35), valoración, "novedades", correo, encuesta | — | — |

Presupuesto de enseñanza en toda la vida de la instalación: un tip en la página (el del segundo arrastre), las dos frases de Noche (E4), la frase de la última noche de prueba y la nota de "La prueba terminó". Ninguno entre las 21:00 y las 07:00 salvo las de Noche; ninguno durante la Marea. La lista queda cerrada (C65).

### 2.6 Pantalla 17 · Qué sabemos (empujada, `negro`)

Se llega desde Ajustes, desde la nota de la hoja Marea (`sabemos.enlace` "Qué sabemos ›" como botón de texto, E3), desde la ficha de la App Store mediante `sleepnoise://sabemos` (**E6 declara el esquema en 09**, §9.18) y, en 1.1, desde cualquier afirmación de la app. Una sola familia (SF Pro, sin New York: 03 §1.2), lectura larga en 17/26 (paso 6 `.reading`, 04 §2.0.2), columna de 353, hairlines entre entradas. Sin iconos, sin sellos, sin tablas, sin negritas ni cursivas dentro del cuerpo (los títulos de revista van en redonda, dentro del paréntesis), sin logotipos de revistas. Hereda la fase de la página como Mezclas (página nocturna: `texto-noche`, Medium); se abre desde Ajustes, así que en la práctica es de día. **La lista negra clínica rige aquí sin excepción** (C54): una población se nombra por el criterio de selección del estudio parafraseado, sin diagnóstico ("n participantes con dificultad para dormirse, según X"), con n y cita; el nombre del diagnóstico solo aparece en Notes for Review (E8).

```
393 × 852 · Large · desplaza (≈ 1 400 pt de contenido)
┌─────────────────────────────────────────────────────┐
│ ‹                                                   │ 59-103  barra del sistema, solo atrás
│ Qué sabemos                                         │ 112-148 paso 3 · 22 Semibold texto
│ ───────────────────────────────────────────────────  │ 164     hairline trazo
│ Enmascara los sonidos que te despiertan.            │ 188-212 afirmación · paso 5 · 17/22 Semibold texto
│ El ruido continuo redujo los despertares provocados │ 228-384 cuerpo · paso 6 · 17/26 Regular texto · tres párrafos separados por \n (6 líneas)
│ por ruidos intermitentes en un estudio de           │
│ laboratorio (Stanchina y otros, Sleep Medicine,     │
│ 2005; cuatro voluntarios sanos).                    │
│ La evidencia de que el ruido ayude a dormir en      │
│ general es de muy baja calidad (…).                 │
│ Por eso no decimos que duermas mejor.               │
│ ───────────────────────────────────────────────────  │ 416     hairline (32 de aire)
│ Te acompaña a respirar más despacio.                │ 440     (misma plantilla: afirmación + cuerpo)
│ …                                                   │
│ ───────────────────────────────────────────────────  │
│ Nunca se repite.                                    │
│ …                                                   │
│ ───────────────────────────────────────────────────  │
│ Quedarse en la cama despierto.                      │         entrada `que_sabemos.en_vela` (C60): hallazgo con n y cita; se compila cuando E7 verifique la cita
│ …                                                   │
│ ───────────────────────────────────────────────────  │
│ Lo que no sabemos                                   │         paso 5 Semibold texto
│ Si el ruido te ayuda a dormir más o mejor. …        │         paso 6 texto
│ ───────────────────────────────────────────────────  │
│ Nada de lo anterior es consejo médico. Si duermes   │         pie · paso 8 · 13/18 texto2 · 2 líneas (C54)
│ mal muchas noches, habla con un profesional.        │
│ (área segura inferior 34)                           │
└─────────────────────────────────────────────────────┘
```

**Plantilla por frase** (obligatoria para cualquier entrada futura; E7 la hereda; la estructura es la de 10 §2.9): afirmación (paso 5, `texto`, `.header` nivel 2) → cuerpo (paso 6 `texto` 17/26; párrafos con `\n`: qué midió el estudio, con autor, revista, año y **n**; lo que no se afirma, como último párrafo de la misma cadena). Entre afirmación y cuerpo, 16; entre entradas, 32 y hairline. Sin etiquetas intermedias ("lo que lo sostiene", "quién lo pagó": se retiran; la financiación se cita solo cuando esté verificada, 10 §5e.11). Prohibido en esta pantalla y en toda la app, sin excepción: "insomnio", "ansiedad", "acúfenos", "mejora el sueño", "terapia", "clínico", "tratamiento", "IA", porcentajes de mejora, umbrales (00 §7.2, investigación §5.2, 10 §0.4-§0.5). Tsai 2015 se describe como "un ensayo con veinte participantes con dificultad para dormirse, según Tsai y otros"; Zaccaro 2018 con "menor activación", nunca con la palabra vetada.

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Título | paso 3 | `texto` | x 20, y 112 | `sabemos.titulo` "Qué sabemos" (reconciliación §3; 03 §5 #17 sigue nombrando la superficie "Qué sabemos y qué no": el título de pantalla es la cadena de 10). `.header` |
| Afirmación | paso 5 · 17/22 Semibold | `texto` | hasta 2 líneas | `.header` (nivel 2) para navegar por el rotor; en 1.1 es el ancla del enlace desde la app |
| Cuerpo | paso 6 · 17/26 (lectura larga) | `texto` | hasta 8 líneas; párrafos con `\n` | Estático. Nombres de revista sin cursiva (una familia, un estilo; la cursiva no aporta a oscuras) |
| "Lo que no sabemos" | paso 5 + un párrafo paso 6 | `texto` | — | Sección propia; es la parte que ningún competidor tiene |
| Pie | paso 8 · 13/18 | `texto2` | 2 líneas, 16 bajo la última entrada | `sabemos.pie` "Nada de lo anterior es consejo médico. Si duermes mal muchas noches, habla con un profesional." (C54: pie de dos líneas) |

Entradas de 1.0 (cadenas completas en §5e, letra a letra las de 10 §5e.11): **(1)** "Enmascara los sonidos que te despiertan." (Stanchina 2005, cuatro voluntarios sanos; Riedy 2021 para lo que no se afirma; §9.6: E7 verifica el n contra el artículo). **(2)** "Te acompaña a respirar más despacio." (Zaccaro 2018, revisión de quince estudios; Tsai 2015, veinte participantes con dificultad para dormirse; "No tratamos nada; no es un producto sanitario." dentro del cuerpo). **(3)** "Nunca se repite." (sin archivo ni bucle; "Puedes comprobarlo en el tamaño de la app": la cifra en MB vive en la fila de versión de Ajustes, fijada en build, nunca medida en runtime, C53; lo que no se afirma: que un sonido sin bucle te despierte menos). **(4)** "Quedarse en la cama despierto." (`que_sabemos.en_vela`, C60: hallazgo con n y cita, nunca consejo ni en Madrugada; no se compila hasta que E7 verifique la cita). **Lo que no sabemos** (`sabemos.4.*`). No hay cifra de MB en esta pantalla.

### 2.7 Pantalla 18 · Ajustes (hoja `.large`, `hoja`)

Se abre desde la última fila de Mezclas (2.1). Es hoja porque 03 §3.1 pone Ajustes sobre `hoja` ("otra habitación") y 03 §4.10 fija las hojas `.large`; Qué sabemos, Lo que no hay, Cómo se genera y Diagnóstico se empujan dentro de su `NavigationStack` (un solo nivel de empuje dentro de una hoja; §11 razona por qué no pasa a pantalla empujada). `List` del sistema con `.listStyle(.plain)`, `scrollContentBackground(.hidden)`, `presentationBackground(hoja)`, filas `EditorialRow` (03 §4.7) de 56 / 72, hairlines `trazo-hoja`, cabeceras de sección en versalitas paso 9 `texto2`. **Inventario cerrado por C58**: sin selector de apariencia (HIG; Papel es 1.1, C32), sin "Valorar" (C55), sin notificaciones, sin cuenta, sin "abrir sin sonar" (C33), sin duración de Madrugada (receta fija, C05), sin iCloud (1.1, C09), sin guía AirPods (1.1).

```
393 × 808 (relativo a la hoja) · Large · usuario gratuito tras la prueba · desplaza ≈ 516
┌─────────────────────────────────────────────────────┐ 0     indicador
│ Ajustes                                             │ 24-52 paso 3 · 22 Semibold texto
│ ───────────────────────────────────────────────────  │ 60    hairline trazo-hoja
│ noche                                               │ 76-104 cabecera 28 · versalitas texto2
│ Pasar sola a Noche                    Al bloquear › │ 104-160 fila 56 · valor paso 7 texto2 + chevron texto3 (empuja) → lista de opciones
│ Mantener encendida                 Mientras carga › │ 160-216 fila 56 → lista de opciones (C46)
│ Mostrar la hora en Madrugada                  (○  ) │ 216-288 fila 72 · toggle .tint(texto) · nota paso 8 texto2:
│ Madrugada no enseña la hora a propósito.            │
│ Controles visibles de noche                   (○  ) │ 288-360 fila 72 + nota (2 líneas):
│ Cuatro botones grandes en Noche: −15 min, pausa,    │
│ +15 min y Página.                                   │
│                                                     │ 32
│ háptica                                             │ 392-420 cabecera 28
│ Háptica                                   Ninguna › │ 420-476 fila 56 (empuja) → Ninguna · Mínima
│ Tres a cinco respiraciones al empezar. De noche     │ 476-512 nota paso 8 texto2 (fuera de la fila; 2 líneas reservadas)
│ nunca vibra.                                        │
│                                                     │ 32
│ al acostarte                                        │ 544-572 cabecera 28
│ Al acostarte                                      › │ 572-644 fila 72 (empuja la página de texto de E6) · subtítulo "Que suene sola al activar Sueño. Dos pasos en Atajos."
│                                                     │ 32
│ salida                                              │ 676-704 cabecera 28
│ Salida                                      (picker)│ 704-760 fila 56 · AVRoutePickerView del sistema a la derecha (C41)
│                                                     │ 32
│ pro                                                 │ 792-820 cabecera 28
│ SleepNoise Pro                    29,99 € · Una vez.│ 820-876 fila 56 · sin chevron (abre una hoja, solo de día) · valor paso 7 texto2
│                                                     │ 32
│ sobre sleepnoise                                    │ 908-936 cabecera 28 (`ajustes.seccion.sobre` con app.name)
│ Qué sabemos                                       › │ 936-992 fila 56 → 2.6
│ Lo que no hay                                     › │ 992-1048 fila 56 → 2.10
│ Cómo se genera                                    › │ 1048-1104 fila 56 → 2.9
│ Diagnóstico                                       › │ 1104-1160 fila 56 → 2.8
│ Escribir al autor                                   │ 1160-1216 fila 56 · sin chevron (abre el correo del usuario)
│                                                     │ 32
│ Sin suscripción. Sin cuenta. Sin rastreo.           │ 1248-1266 paso 8 texto2
│ Versión 1.0 · 4,2 MB                                │ 1270-1288 paso 9 tabular texto2 (+ 34 de área segura)
└─────────────────────────────────────────────────────┘
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Título "Ajustes" | paso 3 | `texto` | x 20, y 24 | `.header` |
| Cabeceras "noche" / "háptica" / "al acostarte" / "salida" / "pro" / "sobre {app}" | paso 9 versalitas | `texto2` | 28 | `.header` |
| "Pasar sola a Noche" ["Switch to Night"] | fila 56; valor paso 7; chevron (empuja) | nombre `texto`, valor `texto2`, chevron `texto3` | 56 | Empuja una lista del sistema (misma anatomía: título paso 3 a 24, hairline a 60, filas 56 desde 76 con `checkmark` del sistema en `texto`): "Al bloquear" · "1 min" · "3 min" · "Nunca". Por defecto **"Al bloquear"** (C47: Noche entra al bloquear; 1 / 3 min solo desde la página; nunca con una hoja abierta). Lo lee E4 |
| "Mantener encendida" ["Keep screen on"] | fila 56; valor; chevron | — | 56 | Lista: "Mientras carga" (defecto) · "Siempre" · "Nunca" (C46). Noche duerme por defecto (`isIdleTimerDisabled` según el ajuste y `batteryState`) y se atenúa a los 60 s mientras está encendida. Lo lee E4 |
| "Mostrar la hora en Madrugada" ["Show the clock in Small hours"] | fila 72 con nota; `Toggle` del sistema `.tint(texto)` (03 §4.12) | `texto`; nota `texto2` | 72 | Off por defecto (opt-in, C60). Nota: "Madrugada no enseña la hora a propósito." (`madrugada.ajuste.nota`; claves de E4) |
| "Controles visibles de noche" ["Visible controls at night"] | fila 72 + nota; toggle `.tint(texto)` | — | 72 | Off por defecto; **se enciende sola** y se muestra como encendida cuando Control por botón o AssistiveTouch están activos (03 §4.5); el usuario puede encenderla a mano. Nota de dos líneas (`ajustes.noche.controles.nota`). Con `.tint(texto)` ya no hay dos acentos posibles en Ajustes (§9.8 cerrada) |
| "Háptica" ["Haptics"] | fila 56 → lista de opciones (empuja, chevron) | — | 56 | "Ninguna" · "Mínima" (`marea.haptica.ninguna` / `.minima`); por defecto "Ninguna" (opt-in, C35). "Marcada" se va al Watch (1.2) y no se compila en 1.0. Nota fuera de la fila: `marea.haptica.nota` "Tres a cinco respiraciones al empezar. De noche nunca vibra." (la puerta es por fase, sin CoreMotion: C35). Sin motor háptico (`supportsHaptics == false`) la fila no aparece |
| "Al acostarte" ["At bedtime"] | fila 72 con subtítulo; chevron (empuja) | — | 72 | Empuja **una página de texto** de E6 (C43; 03 §5 #24; 09 la especifica con las cadenas `ajustes.acostarte.p1` / `.p2` / `.abrir` de 10 §5e.12). E5 solo es dueña de la fila y del subtítulo `ajustes.acostarte.sub` "Que suene sola al activar Sueño. Dos pasos en Atajos." Es el único autoarranque de la app (C33) |
| "Salida" ["Output"] | fila 56 con `AVRoutePickerView` del sistema a la derecha (C41) | nombre `texto`; el picker sin tinte (`.tint(texto)`) | 56 | La única superficie de AirPlay: `routeSharingPolicy = .longFormAudio` (E6, 09). Sin chevron: el picker es el control |
| Fila Pro | fila 56; valor paso 7; sin chevron | — | 56 | Sin Pro: `pro.ajustes.ver` = `product.displayName` con `pro.precio` "{displayPrice} · Una vez." a la derecha ("—" mientras no hay producto); en prueba, el mismo valor (la prueba se lee en la página). Con Pro: `pro.ajustes.gracias` "{displayName} · gracias · {fecha}" y, si `ownershipType == .familyShared`, `pro.ajustes.familia` "· en familia" en una segunda línea (fila 72). Toque → hoja Pro en su estado, **solo de día** (`NightWindow`; de noche la fila es `.isStaticText`) |
| "Qué sabemos" / "Lo que no hay" / "Cómo se genera" / "Diagnóstico" | fila 56; chevron | — | 56 | Empujan 2.6 / 2.10 / 2.9 / 2.8 dentro del `NavigationStack` de la hoja |
| "Escribir al autor" ["Write to the author"] | fila 56; sin chevron | — | 56 | `ajustes.autor` (C58): abre el compositor de correo del usuario con el destinatario (soporte) y el asunto `app.name`; sin formulario, sin cuerpo prellenado; la misma vía que "Enviar informe" (C56). Sin Mail configurado: `mailto:` al cliente que haya; si no hay ninguno, la fila no aparece (`canOpenURL`) |
| Pie de privacidad | paso 8 | `texto2` | 1 línea | `lo_que_no_hay.pie` "Sin suscripción. Sin cuenta. Sin rastreo." (C09; 03 §5 #32: en la hoja Pro y en Ajustes). Estático; no es botón; la página "Lo que no hay" está a una fila de distancia |
| Versión | paso 9 Medium tabular | `texto2` | 1 línea | `ajustes.version` "Versión {versión} · {MB} MB". El tamaño es el de descarga fijado en build (script sobre el .ipa de referencia en `Info.plist`), nunca `Bundle` en runtime (C53, 10 §5e.12). Pulsación larga = copiar (menú "Copiar" del sistema): es lo que se pega en un correo de soporte |

Lo que Ajustes **no** tiene: duración de Madrugada (receta fija, C05), apariencia (Papel 1.1, C32), idioma, "Debajo de otro audio" (1.1, C44; entonces fila con Preguntar / Siempre / Nunca), "Tus mezclas en iCloud" (1.1, C09), restaurar compra (vive en la hoja Pro), valoración (C55), enlaces a redes, "novedades" (1.1), precio escrito a mano (el valor de la fila Pro es `displayPrice`), "abrir sin sonar" (C33).

### 2.8 Pantalla 30 · Diagnóstico y "Enviar informe" (empujada dentro de Ajustes)

Anillo local acotado (C56): **tiempos relativos desde Play** (nunca hora de reloj con fecha), sin fecha, sin `portName`, sin nombres de mezcla (solo capas y niveles), sesión actual y anterior, excluido de iCloud y del App Group; la escalera del error (2.11) escribe en él; el contador de sesiones de la versalita "gratis siempre" se deriva de él (§9.5). "Enviar informe" abre el correo del usuario **con el texto del anillo en el cuerpo**: nada sale si la persona no lo envía.

```
393 × 808 (relativo a la hoja) · Large
┌─────────────────────────────────────────────────────┐
│ ‹ Ajustes                                           │ 0-44    barra del sistema (atrás)
│ Diagnóstico                                         │ 56-84   paso 3
│ Un registro de la noche, en tu teléfono: tiempos    │ 96-184  paso 6 texto2 · 17/22 · 4 líneas (`diagnostico.nota`)
│ desde Play, cortes y errores de esta sesión y la    │
│ anterior. Sin fecha, sin nombres, sin               │
│ identificadores. Solo sale si tú lo envías por correo.│
│ ───────────────────────────────────────────────────  │ 200
│ Motor                             48 kHz · Bluetooth│ 208-264  fila 56 · valor paso 7 tabular texto2 (tipo de puerto, nunca el nombre)
│ ───────────────────────────────────────────────────  │ 264
│ esta sesión                                         │ 280-308  cabecera 28 · versalitas texto2
│ +0:00:00   Arranque · rosa 50 · lluvia 30           │ 308-352  filas 44 · tiempo paso 9 Medium tabular texto2 (x 20, ancho 84) · evento paso 7 texto2 (x 112)
│ +0:00:00   Ruta · Bluetooth                         │ 352-396
│ +0:45:38   Fundido · 10 min                         │ 396-440
│ +0:55:38   Parada · temporizador                    │ 440-484
│ sesión anterior                                     │ 500-528  cabecera 28
│ +0:00:00   Arranque · océano 50 · marrón 15         │ 528-572
│ +2:33:05   Interrupción · reinicio de servicios     │ 572-616
│ +2:33:06   Reinicio del motor · fallido             │ 616-660
│ …  (hasta 50 eventos por sesión; desplaza)          │
├═════════════════════════════════════════════════════┤ 744    pie fijo (safeAreaInset): HairlineAction 64, sin hairline propia
│ ───────────────────────────────────────────────────  │ 744    hairline trazo-hoja superior del botón (= separador del pie)
│                 Enviar informe                      │ 744-808
│ ───────────────────────────────────────────────────  │ 808
└─────────────────────────────────────────────────────┘
```

| Elemento | Estilo | Color | Medidas | Comportamiento |
|---|---|---|---|---|
| Nota | paso 6 · 17/22 | `texto2` | 4 líneas | `diagnostico.nota`. Es la declaración de privacidad del registro, y la pantalla la cumple: ningún nombre de dispositivo, ninguna fecha, ningún nombre de mezcla |
| "Motor" | fila 56; valor paso 7 tabular | `texto2` | — | Frecuencia de muestreo real de la sesión y **tipo de puerto** (`AVAudioSession.currentRoute.outputs.first.portType` → "Bluetooth" / "Altavoz" / "Auriculares"); en pantalla y en el texto lo mismo. El nombre del dispositivo (`portName`, "AirPods de Ana") no se enseña ni se escribe. Cadenas `diag.motor` y `diag.puerto.*` pendientes de E7 (§9.19) |
| Cabeceras "esta sesión" / "sesión anterior" | paso 9 versalitas | `texto2` | 28 | `.header`. Claves `diag.sesion.actual` / `.anterior` pendientes de E7 |
| Registro | filas 44; tiempo paso 9 Medium tabular + evento paso 7 | tiempo `texto2`, evento `texto2` (03 §3.4: el paso 7 es `texto2`; todo el registro es lectura secundaria) | hasta 50 eventos por sesión, más recientes abajo | Tiempo = `+h:mm:ss` desde el Play de esa sesión. Eventos: Arranque, Parada (causa), Fundido, Interrupción (causa), Reanudado, Ruta, Reinicio del motor (resultado), Error (código). El detalle tras " · " es texto traducido: "temporizador", "usuario", "fundido completo", "fallido", "correcto", "reinicio de servicios de audio"; los códigos de error, tal cual. Claves `diag.ev.*` y `diag.ev.detalle.*` pendientes de E7 |
| Vacío del registro | paso 6 | `texto2` | fila 72 | `diagnostico.vacio` "Nada que informar." |
| **"Enviar informe"** ["Send report"] | `HairlineAction` 64, hairlines `trazo-hoja` | `texto` | pie fijo 64 (sin hairline propia del inset: la superior del botón es el separador) | `diagnostico.enviar`. Abre el compositor de correo del sistema (`mailto:` con destinatario de soporte, asunto `diagnostico.asunto` "Informe de {app} {versión}" y **el registro como cuerpo del mensaje**, ≤ 8 KB: cabecera con versión, iOS, modelo genérico, kHz, ruta por tipo, y las dos sesiones en texto). Sin adjunto. Sin Mail configurado: hoja de compartir del sistema con el mismo texto. El usuario lo ve antes de enviar. Ninguna red propia. La misma vía que "Escribir al autor" (C58) |

"Borrar el registro" no existe: el registro rota solo, no contiene nada del usuario y un toque equivocado bajo "Enviar informe" destruiría la única prueba de "se detuvo a las 02:14" que la app quiere que el usuario envíe. Es la única petición que hace la app, y pide ayuda, no valoración (03 §1.3 Dial; C55). No existe un "Enviar informe" automático ni telemetría: el texto solo sale si la persona lo envía. Declarado en "Lo que no hay" (`lo_que_no_hay.diagnostico`, C56).

### 2.9 Pantalla 31 · Cómo se genera (empujada dentro de Ajustes)

Una página (C38, C53): la prueba de "nunca se repite" en prosa; la animación no demuestra nada, un test sí. Misma anatomía que Qué sabemos: título paso 3 (`como.titulo` "Cómo se genera") a 112, hairline a 164, cuerpo paso 6 17/26 `texto` (`como.cuerpo`: qué se calcula en el iPhone, por qué pesa lo que pesa, el test de autocorrelación a 10 min que corre en CI en cada versión). Sin cifra de MB aquí (está en la fila de versión de Ajustes: "mira el tamaño en Ajustes"), sin diagramas, sin la palabra "procedural" ni "IA". Hereda la fase de la página. Dynamic Type como Qué sabemos (§5d).

### 2.10 Pantalla 32 · Lo que no hay (pie + página empujada dentro de Ajustes)

El pie `lo_que_no_hay.pie` "Sin suscripción. Sin cuenta. Sin rastreo." vive en la hoja Pro y en Ajustes (03 §5 #32); la página lista **como hechos de hoy** lo que no existe. Misma anatomía que Qué sabemos: título paso 3 (`lo_que_no_hay.titulo` "Lo que no hay") a 112, hairline a 164; después la lista `lo_que_no_hay.lista` partida por " · ", **una línea por hecho** en paso 6 17/26 `texto` ("Sin suscripción" / "Sin cuenta" / "Sin rastreo" / "Sin anuncios" / "Sin puntuación" / "Sin racha" / "Sin tutorial"); hairline; dos párrafos paso 6 `texto`: `lo_que_no_hay.resena` "No te pediremos que la valores." (C55, escrito como hecho de hoy) y `lo_que_no_hay.diagnostico` "Un registro de la noche, en tu teléfono. Solo sale si tú lo envías." (C56); pie paso 8 `texto2` = `lo_que_no_hay.pie`. Nunca "Sin servidor" (deja de ser cierto en 1.1, C09) ni "Sin red" (StoreKit usa red). Sin iconos, sin ticks: las palabras son los hechos. Es también el texto de la captura 6 (E8).

### 2.11 La escalera del error de audio (dónde aparece cada peldaño)

Nunca rojo (03 §3.1), nunca alerta modal, nunca sonido ni vibración, nunca código de error en pantalla (va al registro). Todo peldaño es texto **en el único renglón de estado de la página** (05: 144-164, botón de 44 en 140-184; paso 7 `texto2`; `texto-noche` Medium en página nocturna), que **cambia de contenido**: los peldaños no apilan líneas ni desplazan nada; cuando hace falta una acción, va en la **línea 2** de 05 (164-184, `TextAction` 44). En Noche, una sola palabra (E4). Las cadenas son las de 10 §5e.2.

| Peldaño | Disparador | Qué se ve | Qué hace la app sola |
|---|---|---|---|
| 1 · No arranca | `engine.start` lanza (sesión denegada, hardware ocupado) **y el reintento silencioso de los 2 s también falla** | Durante los 2 s, nada (el Disco en `play.fill` ya dice que no arrancó). Después, el renglón de estado = botón 44 (64 en página nocturna): `pagina.error.inicio` "No se ha podido iniciar el sonido. Toca para reintentar." El horizonte sigue en hairline | Reintenta **una vez** a los 2 s en silencio; si suena, nadie se entera. Anota "Error · {código}" |
| 2 · Segundo fallo seguido | — | El mismo renglón cambia: `pagina.error.inicio.2` "Si sigue sin sonar, cierra la app y vuelve a abrirla." (botón: el toque reintenta) | Solo reintento manual |
| 3 · Tercer fallo seguido | — | El mismo renglón, 2 líneas: `pagina.error.inicio.3` "Cierra las apps que usen el micrófono y vuelve a intentarlo." (botón). **Solo entre las 07:00 y las 21:00**, en la línea 2, `TextAction` "Enviar informe" (`diagnostico.enviar`) → el compositor de correo de 2.8 directamente, sin pasar por Ajustes. En `NightWindow` la línea 2 queda vacía (el compositor es la superficie más luminosa posible y pide escribir); el peldaño 5 lo recoge por la mañana | Anota el tercer fallo |
| 4 · Se cae a mitad de la noche | `mediaServicesWereReset`, `AVAudioEngineConfigurationChange` o `engine.isRunning == false` con `isPlaying`, comprobado **en los hitos que ya existen** (tick del temporizador, "+15 min", actualización de la Live Activity), sin timer propio (03 §3.7: 10 min bloqueado sin actividad periódica). Si el director quiere un vigilante de verdad: **spike I0-9** con medición de batería | Nada si el reinicio funciona. Si falla: Live Activity "Se detuvo a las {hora}" con `play.fill` (E6); en Noche: la palabra `noche.estado.sin_sonido` "Sin sonido" en el lugar del estado (E4); la sesión termina (`endPlayback(canDowngrade: false)`: una caída no caduca la prueba) | Dentro de un `beginBackgroundTask` (≤ 30 s): reconstruye el grafo y reanuda una vez con fundido de 800 ms (`defaultFadeIn` 1,5 → 0,8, §9.5); si el reinicio falla **a los 2 s**, actualiza la Live Activity, anota (tiempo relativo en el anillo; la hora de reloj del corte se guarda aparte, sin fecha, para la línea de la mañana) y termina la tarea |
| 5 · La mañana siguiente | Primera apertura de día tras el peldaño 4, o tras un tercer fallo nocturno | En el renglón de estado, una vez: `pagina.estado.manana.error` "Anoche el sonido se detuvo a las {hora}." y, en la línea 2, `TextAction` "Enviar informe" (la única petición de la app). Tras un tercer fallo nocturno sin arranque, la variante "Anoche el sonido no pudo iniciarse." (`pagina.estado.manana.error.inicio`, pendiente de E7, §9.19) | Se va al tocar "Enviar informe" o en la siguiente apertura |

VoiceOver anuncia cada peldaño una vez (`AccessibilityNotification.Announcement`, prioridad alta); el botón del renglón se etiqueta con `ax.reintentar` "No se ha podido iniciar el sonido. Reintentar"; el Disco conserva su etiqueta "Reproducir". `MixerModel.audioError` deja de ser una cadena única y pasa a un enumerado con el número de fallo consecutivo (§9.5). No hay peldaño de "escucha": la escucha de 30 s no existe en 1.0 (C06).

---

## 3. Estados completos

| Pantalla | Reposo | Sonando | Pausa | Fundiendo | Pro bloqueado sin castigo | Prueba | Error | Vacío | Cargando | Sin red |
|---|---|---|---|---|---|---|---|---|---|---|
| **12 Mezclas** | Lista sin estado en ninguna fila; en página nocturna, una tinta (`texto-noche`) | La mezcla cargada lleva "sonando ahora" a la derecha; el horizonte no está en esta pantalla (la barra sí) | Nada en ninguna fila (lo cargado lo dice el nombre de la página) | Igual que sonando (el fundido se ve en la página) | Receta con "· {capa} es Pro" al final; fila entera en `texto`/`texto2` normales; toque = carga recortada y suena lo que tiene acceso (también las de la casa, C18); nunca abre hoja; la receta guardada no se modifica | Idéntica a Pro (todo abierto): sin frase "es Pro" en ninguna receta | No aplica (no hay red ni motor aquí); si la carga falla al arrancar el motor, la página enseña el peldaño 1 | "tuyas" vacía: la frase de 2.1; "de la casa" nunca está vacía | No existe (`UserDefaults` es síncrono; sin sincronización en 1.0, C09) | No aplica |
| **13 Menú / Guardar** | Menú de 3 ítems (ninguno en página nocturna) | Igual; "Guardar en «…»" si procede | Igual | Igual | Ítem "Guardar como mezcla… · pro" → hoja Pro de día; de noche no hace nada; la mezcla sigue cargada | Idéntico a normal | Nombre vacío → "Esta noche"; no hay estado de error | — | — | — |
| **14 Pro** | Precio cargado, "Una vez.", Comprar con hairlines `índice` 1,5 pt; "Empezar la prueba · 7 noches" encima si la prueba no se ha usado | Lo que suena sigue (nunca se pausa para vender) | Igual | Igual | — (es la hoja) | Sin "Empezar": solo Comprar; la prueba se lee en la página | Fallo: línea `texto2` `pro.fallo` / `pro.fallo.sin_confirmar`; `.error` solo con la hoja delante; botón intacto | — | Precio "—" en `texto3`, Comprar en `texto2` con hairlines `trazo-hoja`, deshabilitado | A los 8 s sin producto, en el lugar del pie: `pro.sin_tienda.silencio` "La tienda no responde. Nada cambia." (en silencio) / `pro.sin_tienda` "La tienda no responde. Nada cambia: sigue sonando." (`isPlaying`); Comprar sigue en `texto2`; se reintenta al volver a primer plano y al reaparecer la hoja |
| **15 Prueba** | Versalita en la cabecera ("gratis siempre" / "prueba · quedan n noches" / "prueba · última noche") | Igual (no crece) | Igual | Igual | Tras la prueba: versalita "gratis siempre" siete sesiones; filas "pro · 30" en la página (E2); estado "Sonando · sin océano" | Noches 1-7 | — | — | — | — |
| **16 Primer uso** | La página con "gratis siempre", "Esta noche", "En silencio" | Suena en < 1 s | — | — | Filas "pro" en Capas; el toque abre la hoja de día | Solo si se empezó desde la hoja | Peldaño 1 si el motor no entra | — | — | — |
| **17 Qué sabemos** | Lectura | — | — | — | — | — | — | — | — | No usa red |
| **18 Ajustes** | Lista | Igual | Igual | Igual | Fila Pro con `displayName` y "{displayPrice} · Una vez." | Igual (la prueba se lee en la página) | — | — | Fila Pro con "—" como precio | Igual |
| **30 Diagnóstico** | Registro de dos sesiones | Igual (la sesión actual crece en los hitos) | Igual | Igual | — | — | Última fila "Reinicio del motor · fallido" | "Nada que informar." | — | "Enviar informe" funciona sin red (el correo se queda en la bandeja de salida del sistema) |
| **31 Cómo se genera** / **32 Lo que no hay** | Lectura | — | — | — | — | — | — | — | — | No usan red |
| **4 Página · error de audio** | — | — | — | — | — | — | Peldaños 1-5 en el renglón de estado y la línea 2 (2.11) | — | — | — |

**14 · estados de StoreKit** (tabla aparte: una fila por estado, no por columna):

| Estado | Botón | Línea (en el lugar del pie) | Lo demás |
|---|---|---|---|
| Compra en curso | "Comprando…" (`pro.comprando`) `texto2`, hairlines `trazo-hoja`, `.notEnabled` | — | Restaurar y Ahora no deshabilitados |
| Éxito | "Gracias. Todo abierto." (`pro.gracias`) paso 5 `texto` 1,5 s | — | Si la mezcla cargada tenía capas Pro silenciadas y suena, entran con fundido de 800 ms en el instante de comprar (la compra se oye); la hoja se cierra sola |
| Cancelación (`.userCancelled`) | Vuelve a "Comprar · {precio}" | `pro.fallo` "No se ha podido completar. No se ha cobrado nada." | Cancelar no es un error: sin `.error`, sin más |
| Fallo antes del pago | Intacto | `pro.fallo` | `.error` |
| Sin confirmar (`.unverified`, red tras la hoja del sistema) | Intacto | `pro.fallo.sin_confirmar` "No se ha podido confirmar. Si App Store te ha cobrado, Restaurar compra lo abre." | Si la transacción llega después por `Transaction.updates`, la fila de §4.7 la recoge |
| Pendiente (En familia, Pedir para comprar) | "Pendiente" (`pro.pendiente.boton`, pendiente de E7, §9.19) `texto2`, deshabilitado | `pro.pendiente` "Pendiente de aprobación familiar. Se abrirá solo cuando llegue." | La hoja se puede cerrar; al llegar `Transaction.updates`, Pro en silencio |
| Restaurar | "Buscando…" (`pro.buscando`, ≤ 10 s) | Encontrado: como éxito; nada: `pro.restaurar.no`; sin tienda: `pro.sin_tienda` / `.silencio` | — |
| Empezar la prueba | Toque → `startTrial()`; la hoja se cierra (sistema) | — | La página ya lleva "prueba · quedan 7 noches"; la capa que abrió la hoja entra con fundido de 800 ms (2.3). Sin StoreKit, sin cobro, sin tarjeta (C07) |
| Comprado | Sin Comprar ni Empezar; "Escribir una reseña" · "Restaurar compra" | — | Estado 2.3 "comprado" = recibo (C12, C38) |

Estados que **no existen** en estas pantallas: deshabilitado visible salvo los dos de la hoja Pro que 03 §4.6 exige (Comprar sin precio, en `texto2`, y "Pendiente"); en el resto, lo que no se puede hacer no aparece (03 §4.7); candado, cápsula, badge, cuenta atrás, spinner (`ProgressView` sustituido por texto: "Comprando…", "Buscando…"), alerta modal propia (solo las del sistema: Guardar, Renombrar, confirmación de Eliminar, hoja de compra de App Store, compositor de correo), "prueba caducada", precio de lanzamiento, línea de la mañana.

---

## 4. Flujos (entradas, salidas, interrupciones)

Regla de lectura (herencia de Silencio §12): cada paso dice qué se ve, qué se oye y qué se siente. Ningún paso de estos flujos exige mirar salvo los que ocurren de día (guardar, comprar, leer, empezar la prueba).

### 4.1 Cargar una mezcla de la casa (noche 3, en prueba, 23:40, vuelta de Noche: página nocturna)

1. **Toca "Mezclas"** en la barra. Se ve: la pantalla empujada del sistema (transición del sistema), en una tinta `texto-noche` (hereda la página nocturna), "tuyas" con una propia, "de la casa" con cuatro; sin deslizar, sin reordenar. Se oye: lo que sonaba sigue sonando. Se siente: nada.
2. **Toca "Mar y viento"**. Se oye: fundido cruzado de 1,5 s (`.easeInOut`) de las ganancias de capa (`engine.updateGains(_, ramp: 1.5)`, cambio de código §9.5): rosa y lluvia bajan mientras océano y viento suben; la Marea no cambia (la mezcla no la guarda: formato v2, C20). Si no sonaba nada: arranca como un Play (800 ms `.easeOut`, `.impact(.medium, 0.7)`, anuncio "Sonando"). Se ve: fondo `grafito` 200 ms en la fila; la pantalla vuelve a la página (pop del sistema, 250 ms después del toque) con el nombre "Mar y viento", las filas Océano 50 y Viento 20, el horizonte que crece (E2). Se siente: `.impact(.medium, 0.7)` solo si arrancó el sonido; nada si cruzó. El temporizador no se toca (C18).
3. **Entrada por Siri / Atajo** (`PlayMix(MixEntity)`, C43): lo mismo sin abrir la app; la Live Activity lo dice (E6). La pantalla Mezclas no se abre nunca por un intent. El widget mediano llega en 1.1 (C42).

Salida: atrás del sistema, gesto de borde, cargar una mezcla, o **"Noche" en la barra** (pop sin animación y Noche en 2 s de opacidad; 250 ms con Reduce Motion; el sonido no se toca: quien entró en Mezclas por error a las 3 tiene Noche a un toque). Interrupción (llamada) con Mezclas delante: la lista no cambia; "sonando ahora" se va en 250 ms; al reanudar (regla de la ventana de la mañana, C48) vuelve. Bloqueo con Mezclas delante: al desbloquear, si suena, la app está en Noche (C47: entra al bloquear por defecto); si no, Mezclas tal cual.

### 4.2 Guardar la mezcla de esta noche (día 2, de día)

1. **Pulsación larga sobre "Esta noche"** (o acción de VoiceOver "Guardar como mezcla", `ax.accion.guardar`). Menú del sistema con 3 ítems (sin "Guardar en", porque la viva no viene de una propia).
2. **"Guardar como mezcla…"**. Alerta del sistema con el campo vacío (placeholder "Nombre de la mezcla") y el teclado. Escribe "Hotel". Retorno o "Guardar".
3. Se ve: la alerta se cierra (sistema); en el renglón de estado, 3 s, paso 7 `texto2`: "Guardada". El nombre de la página pasa a "Hotel". Se siente: `.success`. VoiceOver: "Guardada". Se oye: nada cambia (guardar no toca el sonido).
4. Variante **tercera noche sin Pro, cuarta mezcla**: el ítem dice "Guardar como mezcla… · pro"; al tocarlo de día se abre la hoja Pro con el precio arriba y "Empezar la prueba · 7 noches" si la prueba no se ha usado; cerrarla ("Ahora no", gesto) deja todo como estaba, la mezcla sigue cargada y sonando. De noche el ítem no hace nada. Nada se pierde; nada se guarda. "Guardar en «Hotel»" sigue disponible y gratis.
5. Variante **mezcla con capa Pro silenciada** (día 9, "Ventilador y lluvia" cargada sin ventilador, el usuario subió el marrón): "Guardar en «Ventilador y lluvia»" → la receta se reescribe con lo que suena **y el ventilador a su nivel guardado** (C23: guardar conserva el nivel sin diálogo); el renglón de estado dice "Guardada". En Mezclas la receta sigue diciendo "· ventilador es Pro"; el día que compre, sonará.
6. Variante **Vaciar** (de día): el nombre pasa a "Esta noche", el renglón de estado dice "En silencio"; se deshace cargando una mezcla.

### 4.3 Eliminar, renombrar y reordenar en Mezclas (de día)

- **Deslizar** una fila propia a la izquierda: "Renombrar" (sin tinte) y "Eliminar" (rojo del sistema, el único rojo de la app, porque es del sistema). Sin deslizamiento completo. Pulsación larga sobre la fila: `contextMenu` del sistema con "Renombrar", "Eliminar", "Subir", "Bajar".
- **Eliminar** → `confirmationDialog` del sistema: título `mezclas.eliminar.titulo` "¿Eliminar "Hotel"?", mensaje `mezclas.eliminar.nota` "La mezcla de esta noche no cambia.", botones "Eliminar" (destructivo) / "Cancelar". Si la eliminada es la mezcla cargada: la página conserva lo que suena con el nombre "Esta noche"; el sonido no se toca.
- **Renombrar** → `.alert` con campo, como 2.2. Si es la cargada, el nombre de la página cambia también.
- **Reordenar** → pulsación larga y arrastre (`onMove`, sin modo edición ni `EditButton`) en "tuyas"; las de la casa no se mueven. Sin gesto: "Subir" / "Bajar" del `contextMenu`.
- Con VoiceOver: acciones personalizadas "Renombrar", "Eliminar", "Subir", "Bajar" en cada fila propia.
- En página nocturna no hay nada de esto: el toque carga, y ya.

### 4.4 La prueba caduca mientras suena, y después (noche 7 → día 8)

1. **Noche 7, 23:00** (vuelta de Noche: página nocturna). Cabecera "prueba · última noche" en `texto-noche`, texto estático; la frase `prueba.ultima` no se muestra (es `NightWindow`; si abrió de día, la leyó y murió al Play). Toca el Disco: suena "Mar y viento" con océano.
2. **03:10.** `TrialClock` cruza los 7 × 86 400 s. **No pasa nada**: `refreshAccess(canDowngrade:)` solo se llama con `true` al terminar la sesión. Océano suena, la Live Activity no cambia.
3. **05:40, el temporizador funde y termina.** `endPlayback(canDowngrade: true)` aplica la baja en silencio **sin escribir nada** (C23). Pantalla apagada; nadie lo ve.
4. **Día 8, 09:15, abre la app.** Página de día: cabecera "gratis siempre"; nombre **"Mar y viento · sin Océano"** (`mezcla.nombre.sin`, 03 §1.3); nota de una vez "La prueba terminó. Lo que usaste sigue aquí." + "Entendido"; fila Océano con nombre en `texto2`, pista `texto3` y "pro · 50" (su nivel guardado, E2); fila Marea "pro"; Viento 20 normal. Ninguna hoja, ningún candado, ninguna cuenta atrás.
5. **Toca el Disco.** Suena viento 20. Estado "Sonando · sin océano" (`pagina.estado.sonando.sin`, E2). La nota muere. Si la mezcla cargada fuera toda Pro ("Ventilador 70", guardada como "Ventilador"): el nombre no cambia, el estado en reposo dice "En silencio · esta mezcla es Pro" (`pagina.estado.silencio.pro`) y Play arranca Rosa a 40 y lo dice: "Sonando · rosa a 40" (`pagina.estado.sonando.defecto`; 03 §1.3 Marea: el instrumento siempre suena).
6. **Toca la fila Océano (de día).** La hoja Pro con el precio arriba y solo Comprar (la prueba ya se usó). Cierra la hoja: todo como antes. Sin límite de veces. Nada suena por tocarla (C06).
7. **Noche 8, 23:30, toca la fila Océano.** Nada: la fila sigue diciendo "pro · 50" (C08). Día 9 por la mañana: nada tampoco (no hay línea matinal).
8. **Abre Mezclas.** "Mar y viento" dice "océano 50 · viento 20 · océano es Pro". "Ventilador y lluvia" (propia) dice "… · ventilador es Pro". Nada tachado. Las tres propias siguen; la cuarta pedirá Pro.
9. **Si nunca compra**: tras siete sesiones la versalita "gratis siempre" desaparece y la página queda sin cabecera (el renglón vacío), como la de un usuario Pro. Las filas "pro" se quedan donde están. Ninguna notificación, correo ni descuento, jamás.

### 4.5 Compra y restauración (día 8, 09:20)

1. **Entrada**: la versalita (de día), una fila "pro" de día, el toggle "pro" de la Marea de día, el ítem de la cuarta mezcla, la fila Pro de Ajustes. Siempre por toque, siempre entre las 07:00 y las 21:00.
2. **La hoja** abre con el precio ya cargado (se pidió al arrancar y al presentar). Se ve: "29,99 €", "Una vez.", el titular, las dos listas, Comprar con hairlines `índice` (sin "Empezar la prueba": ya se usó). Se oye: lo que sonaba sigue. Se siente: nada (03 §3.8: abrir el paywall y enseñar el precio no vibran).
3. **Toca "Comprar · 29,99 €"**: opacidad 0,6 200 ms; "Comprando…"; la hoja de App Store del sistema encima (Face ID). Nada gira.
4. **Éxito**: la hoja del sistema se cierra; en el lugar del botón, paso 5 `texto` "Gracias. Todo abierto." 1,5 s; `.success`; anuncio "Gracias. Todo abierto."; la hoja se cierra sola. Detrás: la versalita de cabecera se ha ido (250 ms de opacidad; su renglón queda vacío, nada sube), "Mar y viento · sin Océano" vuelve a "Mar y viento", Océano recupera nombre en `texto` y su 50, la Marea su toggle; **si sonaba, océano entra con fundido de 800 ms en ese instante** (`updateGains(_, ramp: 0.8)`). Ajustes: "SleepNoise Pro · gracias · 16 nov 2026".
5. **Cancelación**: el botón vuelve; en el lugar del pie, "No se ha podido completar. No se ha cobrado nada." (`pro.fallo`, sin `.error`: cancelar no es un error). Sin "¿seguro?".
6. **Fallo** antes del pago: la misma línea con `.error` (la persona está en la hoja, despierta); el botón intacto para reintentar. **Sin confirmar** (`.unverified` o red tras la hoja del sistema): `pro.fallo.sin_confirmar`; lo que haya pasado en la tienda llegará por `Transaction.updates`.
7. **Pendiente** (Pedir para comprar): "Pendiente" en el botón y la línea de familia; la hoja se puede cerrar; la transacción llega por `Transaction.updates` y Pro se aplica en silencio (la mezcla recupera sus capas si está sonando: la compra se oye aunque la apruebe otro).
8. **Restaurar**: "Buscando…" ≤ 10 s (tope propio: `AppStore.sync()` no tiene timeout); encontrado → como 4; nada → `pro.restaurar.no`; sin tienda → `pro.sin_tienda` si suena, `pro.sin_tienda.silencio` si no. En familia: la compra del organizador llega por `currentEntitlements` al arrancar sin tocar nada; la fila de Ajustes añade "· en familia".
9. **Reinstalar o cambiar de iPhone**: `currentEntitlements` en el primer arranque; si hay Pro, la app abre ya sin cabecera. Las mezclas viajan con la copia de seguridad del sistema y con la migración de iPhone (`UserDefaults` del App Group, formato v2: C09 lo deja listo para el KVS de 1.1); no hay sincronización propia en 1.0: "Sin rastreo" es literal. La prueba, en el Keychain, no se repite al reinstalar (C07).

### 4.6 Primer uso (23:08, instalada hace un minuto, luz apagada)

1. **Abre.** Página en < 300 ms. Son las 23:08 pero es la primera apertura y no se ha pasado por Noche: la página está en **página de día** (`texto`, `texto2`; 03 §3.2). Se ve: "gratis siempre" (texto estático: `NightWindow`), "Esta noche", "En silencio", el horizonte quieto, Lluvia 30 y Rosa 50 como filas-control, "Todas las capas", "Marea" off, "Temporizador · Hasta dormirme · 45 min", la barra. Ningún párrafo (C07). Ningún permiso, ningún nombre de app, ningún tutorial. Nada que leer.
2. **Toca el Disco.** Suena en 800 ms. `.impact(.medium, 0.7)`. El horizonte nace en `índice`. La prueba no arranca (C07); el contador de sesiones gratuitas cuenta una.
3. **Arrastra Lluvia a 20.** La fila responde (E2). Nada se enseña.
4. **Arrastra Rosa.** Nada se enseña: es `NightWindow`. El tip espera al segundo arrastre de la primera apertura de día.
5. **Toca Océano por curiosidad.** Nada (C08): la fila dice "pro" y sigue diciéndolo.
6. **Deja el iPhone.** Al bloquear, Noche (E4, C47). Live Activity al bloquear (E6, escenario A).
7. **Mañana, día 2, 08:30.** Al abrir: cabecera "gratis siempre" (botón), "Esta noche" tal como la dejó. Toca Océano: la hoja Pro con "Empezar la prueba · 7 noches" arriba del pie fijo y "Comprar · 29,99 €" debajo. Toca "Empezar": la hoja se cierra, la cabecera pasa a "prueba · quedan 7 noches", Océano entra con fundido de 800 ms sobre lo que suene (o queda a su nivel si nada suena). Nada más.

### 4.7 Interrupciones que tocan a estas pantallas

| Interrupción | Hoja Pro delante | Alerta Guardar / Renombrar delante | Mezclas / Ajustes / Qué sabemos / Diagnóstico delante |
|---|---|---|---|
| Llamada / Siri / alarma | La hoja se queda; el sonido pausa (E2/E4; reanuda o termina según la ventana de la mañana, C48); al volver, igual. Si la compra estaba en curso, StoreKit la termina en segundo plano y la hoja refleja el estado al volver | La alerta se queda con su teclado; nada se guarda hasta "Guardar" | Nada cambia; "sonando ahora" se va |
| Bloqueo del iPhone | Al desbloquear, la hoja sigue. **Noche no entra mientras hay una hoja abierta** (03 §5 #10, C47): el paso a Noche espera a que se cierre | La alerta sigue con su campo; nada se pierde | Se cubren por Noche (pantallas empujadas, no hojas) |
| Paso de las 21:00 con la hoja Pro abierta | La hoja sigue (está delante por decisión del usuario); solo las aperturas **nuevas** quedan vetadas por `NightWindow` | — | — |
| Fin de la prueba mientras una de estas pantallas está delante | Imposible (la baja solo se aplica al terminar una sesión, y entonces se refleja al reaparecer la página) | — | Mezclas: las recetas ganan "· océano es Pro" en la siguiente aparición de la pantalla, no en vivo |
| `Transaction.updates` trae Pro (familia, otro dispositivo, o una compra que la app dio por no confirmada) | La hoja pasa a "comprado" en 250 ms de opacidad; anuncio "Gracias. Todo abierto." | Nada | Ajustes: la fila Pro cambia en la siguiente aparición |
| Sin red | Hoja Pro: 2.3 "sin tienda". Todo lo demás de estas pantallas funciona sin red, por construcción | — | — |

---

## 5. Las cinco tablas obligatorias

### 5a · Movimiento (elemento → señal del motor → duración/curva → Reduce Motion → Always-On / `isLuminanceReduced`)

Nada de estas pantallas cambia de posición jamás; solo longitud, opacidad o contenido (03 §3.7). Ninguna animación finita > 2 s salvo las de audio (que no son interfaz); ninguna infinita (el horizonte vive en la página y es de E2). Las hojas, los empujes, las alertas y los menús son del sistema y no se personalizan. **Las rampas por capa no existen hoy en el motor** (`RenderState.prepare` solo tiene τ = 20 ms fijo; `updateGains` salta en ~60 ms): M1 y M13 son **cambio de código** (§9.5), no spike.

| # | Elemento | Qué cambia | Señal / causa | Duración · curva | Reduce Motion | Always-On / `isLuminanceReduced` / pantalla apagada |
|---|---|---|---|---|---|---|
| M1 | Fundido cruzado al cargar una mezcla | Ganancias de capa (audio) y, en la página, grosor/opacidad del horizonte por RMS real | Carga de una mezcla (toque, Siri) → `engine.updateGains(_, ramp: 1.5)` con rampa por capa **[cambio de código, §9.5]** | 1 500 ms · `FadeCurve` de la envolvente (la interfaz solo lee el RMS) | Igual (es audio; el horizonte ya está a 4 Hz, τ 1,5 s) | 0 fotogramas: no hay interfaz propia encendida; la Live Activity se actualiza una vez por hito |
| M2 | Arranque desde silencio al cargar | Ganancia maestra 0 → nivel | Mismo que Play (envolvente maestra, ya existe) | 800 ms · `.easeOut` | Igual | — |
| M3 | Fila de mezcla pulsada | Fondo `grafito` aparece/desaparece | Dedo | 200 ms · `.easeInOut` | Igual (opacidad) | — |
| M4 | Estado "sonando ahora" ↔ nada | Contenido/opacidad | `isPlaying` | 250 ms · opacidad | Igual | — |
| M5 | Receta que gana "· {capa} es Pro" | Contenido | Cambio de `hasFullAccess` | Sin animación: se aplica al reaparecer la pantalla | — | — |
| M6 | Versalita de cabecera ("gratis siempre" / "prueba · …") aparece / desaparece; n cambia; deja de ser botón | Opacidad; contenido; rasgo | `trialState` al reaparecer la página; `startTrial()`; compra; `NightWindow` y fase | 250 ms · opacidad; la cifra n cambia en seco (nunca `numericText` en versalitas); el renglón permanece | Igual | — |
| M7 | Nota "La prueba terminó" + "Entendido" se van; frase de la última noche se va | Opacidad; el hueco queda vacío (el horizonte está anclado a un tercio y no se mueve) | "Entendido", Play, siguiente apertura de día | 250 ms · opacidad | Igual | — |
| M8 | — (retirada: la cabecera se va por M6; nada sube al comprar) | — | — | — | — | — |
| M9 | Hoja Pro: precio "—" → "29,99 €" | Contenido | `product` cargado | `.contentTransition(.opacity)` 250 ms (nunca `numericText`: 03 §3.7) | Igual | — |
| M10 | Hoja Pro: hairlines de Comprar `trazo-hoja` 0,5 → `índice` 1,5 pt | Color y grosor | `product != nil` | 250 ms · opacidad (el grosor cambia en seco: 0,5 pt no se interpola bien) | Igual | — |
| M11 | Comprar / Empezar la prueba pulsados | Opacidad 0,6 | Dedo | 200 ms · `.easeInOut` | Igual | — |
| M12 | Comprar → "Comprando…" / "Buscando…" / "Pendiente" / "Gracias. Todo abierto." | Contenido | `isPurchasing`, `notice`, éxito | 250 ms · opacidad; "Gracias" se queda 1 500 ms y la hoja se cierra (animación del sistema) | Igual | — |
| M13 | Capa Pro que entra al comprar o al empezar la prueba (la compra, y la prueba, se oyen) | Ganancia de esa capa 0 → nivel guardado; el horizonte lo refleja | Compra verificada o `startTrial()` con `isPlaying` → `updateGains(_, ramp: 0.8)` **[cambio de código, §9.5]** | 800 ms · `FadeCurve` | Igual (audio) | — |
| M14 | — (retirada por C06: no hay escucha de 30 s ni disolución en 1.0) | — | — | — | — | — |
| M15 | Línea de resultado en el lugar del pie (fallo, sin confirmar, pendiente, sin tienda, restaurar) | Contenido / opacidad | `notice` | 250 ms | Igual | — |
| M16 | Renglón de estado: "Guardada"; "En silencio" tras Vaciar | Contenido / opacidad | Guardar, Vaciar; 3 s | 250 ms entrar; 250 ms salir | Igual | — |
| M17 | Tip del segundo arrastre | Opacidad | Segundo `DragGesture` terminado de día; 6 s | 250 ms; TipKit sin fondo ni flecha | Igual | No se muestra en `NightWindow` (21:00–07:00) |
| M18 | Peldaños del error de audio | Contenido del renglón de estado y de la línea 2 | Fallo de `engine.start`; `mediaServicesWereReset`; `isRunning == false` en un hito | 250 ms opacidad | Igual | En Noche, "Sin sonido" cambia en seco (E4) |
| M19 | Toggle de Ajustes, listas de opciones, `checkmark`, picker de Salida | Del sistema | Dedo | Sistema | Sistema | — |
| M20 | Hojas (Pro, Ajustes), empujes (Mezclas, Qué sabemos, Lo que no hay, Cómo se genera, Diagnóstico), menú contextual, alertas, `onMove` | Del sistema | — | Sistema | Sistema | — |
| M21 | Horizonte de la página bajo una hoja (Pro, Ajustes) | Grosor y color → hairline `trazo` | Hoja presentada (03 §3.7 "hoja encima") | ≤ 2 s · `.easeInOut`; al cerrar la hoja, vuelve a leer el RMS en 800 ms | Igual | — |

Lo que no se mueve nunca aquí: ningún spinner, ningún `symbolEffect`, ningún spring, ningún desplazamiento de texto, ninguna transición propia de hoja, ningún `numericText`.

### 5b · VoiceOver por control (etiqueta → valor → pista → rasgos → acciones personalizadas)

Orden de la página (E2, 05 §5b): Disco → cabecera → nombre → horizonte → estado → línea 2 → nota → filas → "Todas las capas" → Marea → Temporizador → Mezclas → Noche; Magic Tap en la raíz = play/pausa (C63). Idioma: el de la app; los precios se hablan con `Product.displayPrice` ("veintinueve con noventa y nueve euros" lo produce el sistema). Las etiquetas y pistas que no son la cadena visible tienen clave `ax.*` en 10 §5e.16 (citadas aquí por clave); las cabeceras de sección se leen con su cadena en minúscula (`mezclas.seccion.tuyas`, `pro.con`): el sistema no necesita mayúscula.

| Pantalla · control | Etiqueta | Valor | Pista | Rasgos | Acciones personalizadas |
|---|---|---|---|---|---|
| Página · versalita cabecera (día, página de día) | `ax.prueba.cabecera` "Prueba, quedan 5 noches" / "Prueba, última noche" / "Gratis siempre" | — | `ax.prueba.pista` "Toca dos veces para ver qué incluye Pro." | `.isButton` | — |
| Página · versalita cabecera (`NightWindow` o página nocturna) | literal | — | — | `.isStaticText` | — |
| Página · frase de la última noche / nota "La prueba terminó" | el texto literal | — | — | `.isStaticText` | — |
| Página · "Entendido" | "Entendido" | — | `vo.entendido.pista` "Cierra esta nota" (pendiente de E7, §9.19) | `.isButton` | — |
| Página · nombre de la mezcla (E2) | "Nombre de la mezcla" (`mezcla.guardar.campo`), valor "Esta noche" / "Mar y viento, sin Océano" | el nombre | `ax.nombre.pista` "Mantén para guardar o renombrar." (de día); `ax.nombre.pista.noche` en página nocturna | `.header` | `ax.accion.guardar` "Guardar como mezcla", "Guardar en Hotel" (si procede), "Renombrar", "Vaciar" (ninguna en página nocturna; allí `ax.accion.volver.dia`) |
| Página · "Guardar" junto al nombre (Formas de botón / Controles visibles) | "Guardar" | — | `ax.nombre.pista` | `.isButton` | las mismas (como `Menu`) |
| Página · renglón de estado como botón (peldaños 1, 2, 3) | `ax.reintentar` "No se ha podido iniciar el sonido. Reintentar" | — | — | `.isButton` | — |
| Página · línea 2 "Enviar informe" (peldaños 3 y 5) | "Enviar informe" | — | `ax.informe.pista` "Abre tu correo con el registro de la noche. Sin nombre ni identificadores." | `.isButton` | — |
| Página · renglón de estado como texto ("Guardada", "En silencio", "Anoche el sonido se detuvo a las 02:14.") | literal | — | — | `.isStaticText` (anunciado además) | — |
| Alertas Guardar / Renombrar · campo | "Nombre de la mezcla" (`mezcla.guardar.campo`) | el nombre | — | campo de texto del sistema | — |
| Menú del nombre · "Guardar como mezcla… · pro" | `ax.guardar.pro` "Guardar como mezcla, requiere Pro" | — | `ax.guardar.pro.pista` "Toca dos veces para ver Pro. La mezcla no cambia." (de día; de noche sin pista) | `.isButton` | — |
| Menú del nombre · "Vaciar" | "Vaciar" | — | `ax.vaciar.pista` "Pone todas las capas a cero. Se deshace cargando una mezcla." | `.isButton` | — |
| Mezclas · título | "Mezclas" | — | — | `.isHeader` | — |
| Mezclas · cabeceras de sección | "tuyas" / "de la casa" | — | — | `.isHeader` | — |
| Mezclas · fila propia | "Hotel" | "Lluvia 45, marrón 30" (+ "sonando ahora") | `ax.mezcla.pista` "Toca dos veces para cargarla." | `.isButton` | `ax.accion.subir` / `ax.accion.bajar`, "Renombrar", "Eliminar" (solo de día) |
| Mezclas · fila propia con Pro silenciado | "Ventilador y lluvia" | "Lluvia 50, ventilador 30, marrón 20. Ventilador requiere Pro." (`ax.receta.pro` como sufijo) | `ax.mezcla.pista` | `.isButton` | las mismas |
| Mezclas · fila de la casa | "Mar y viento" | "Océano 50, viento 20. Océano requiere Pro." | `ax.mezcla.pista` | `.isButton` | — |
| Mezclas · vacío | "La mezcla de esta noche se guarda desde su nombre." | — | — | `.isStaticText` | — |
| Mezclas · "Ajustes" | "Ajustes" | — | — | `.isButton` | — |
| Mezclas · barra · "Noche" | "Noche" (`barra.noche`) | — | `vo.noche.pista` "Vuelve a la página y pasa a Noche" (pendiente de E7, §9.19) | `.isButton` | — |
| Pro · versalita | `product.displayName` | — | — | `.isHeader` | — |
| Pro · precio | `Product.displayPrice` hablado / "precio no disponible" (`ax.comprar.sin_precio.valor`) | — | — | `.isStaticText`, `.updatesFrequently` no | — |
| Pro · "Una vez." / titular | literal | — | — | `.isStaticText` | — |
| Pro · "con pro" / "gratis siempre" | "con pro" / "gratis siempre" | — | — | `.isHeader` | — |
| Pro · filas de la lista | literal (la primera con su detalle) | — | — | `.isStaticText` | — |
| Pro · Empezar la prueba | `ax.prueba.empezar` "Empezar la prueba de siete noches" | — | `ax.prueba.empezar.pista` "No se cobra nada ni se pide tarjeta." | `.isButton` | — |
| Pro · Comprar | `ax.comprar` "Comprar {displayName}, {displayPrice}" | — | `ax.comprar.pista` "Un solo pago. Abre la confirmación de App Store." | `.isButton` | — |
| Pro · Comprar sin precio / en curso | `ax.comprar.sin_precio` "Comprar {displayName}" / "Comprando" | "precio no disponible" | `ax.comprar.sin_precio.pista` "La tienda no responde." | `.isButton`, `.notEnabled` | — |
| Pro · "Pendiente" | "Pendiente" | — | — | `.isButton`, `.notEnabled` | — |
| Pro · Restaurar | "Restaurar compra" / "Buscando" | — | — | `.isButton` | — |
| Pro · Ahora no | "Ahora no" | — | — | `.isButton` | — |
| Pro · "Escribir una reseña" (comprado) | "Escribir una reseña" | — | `ax.resena.pista` "Abre App Store." | `.isButton` | — |
| Pro · pie / línea de resultado (en el mismo sitio) | literal (la de resultado, anunciada además con `.announcement`) | — | — | `.isStaticText` | — |
| Qué sabemos / Cómo se genera / Lo que no hay · título, afirmaciones, "Lo que no sabemos" | literal | — | — | `.isHeader` (afirmaciones: nivel 2) | — |
| Qué sabemos / Cómo se genera / Lo que no hay · cuerpos y lista | literal | — | — | `.isStaticText` | — |
| Ajustes · título / cabeceras | "Ajustes" / "noche" / "háptica" / "al acostarte" / "salida" / "pro" / "sobre sleepnoise" | — | — | `.isHeader` | — |
| Ajustes · "Pasar sola a Noche" / "Mantener encendida" | literal | "Al bloquear" / "Mientras carga" | — | `.isButton` | — |
| Ajustes · lista de opciones | la opción | "Seleccionado" | — | `.isButton` (+ `.isSelected`) | — |
| Ajustes · toggles | "Mostrar la hora en Madrugada" / "Controles visibles de noche" | "Desactivado" / "Activado" | la nota | `.isToggle` | — |
| Ajustes · "Háptica" | "Háptica" | "Ninguna" | `ax.haptica.pista` "De noche nunca vibra." | `.isButton` | — |
| Ajustes · "Al acostarte" | "Al acostarte" | "Que suene sola al activar Sueño. Dos pasos en Atajos." | — | `.isButton` | — (la página y "Abrir Atajos" son de E6, 09; pista `ax.atajos.pista`) |
| Ajustes · "Salida" | "Salida" | la ruta actual (la habla el `AVRoutePickerView`) | — | el elemento del sistema | — |
| Ajustes · fila Pro | `product.displayName` | "29,99 €, una vez" / "gracias, 16 de noviembre de 2026" (+ "en familia") | — | `.isButton` (de día) / `.isStaticText` (de noche) | — |
| Ajustes · Qué sabemos / Lo que no hay / Cómo se genera / Diagnóstico | literal | — | — | `.isButton` | — |
| Ajustes · "Escribir al autor" | "Escribir al autor" | — | `ax.autor.pista` "Abre tu correo." | `.isButton` | — |
| Ajustes · pie | literal | — | — | `.isStaticText` | — |
| Ajustes · versión | "Versión 1.0 · 4,2 MB" | — | — | `.isStaticText` | "Copiar" (menú del sistema) |
| Diagnóstico · "Motor" | literal | el valor | — | `.isStaticText` | — |
| Diagnóstico · cabeceras "esta sesión" / "sesión anterior" | literal | — | — | `.isHeader` | — |
| Diagnóstico · fila del registro | "cero minutos, Arranque, rosa 50, lluvia 30" (tiempo hablado como duración) | — | — | `.isStaticText` | — |
| Diagnóstico · "Enviar informe" | "Enviar informe" | — | `ax.informe.pista` | `.isButton` | — |

Anuncios (`AccessibilityNotification.Announcement`): "Sonando" al cargar una mezcla desde silencio; "Guardada"; "En silencio"; "Gracias. Todo abierto."; "Prueba, quedan 7 noches" al empezar la prueba; el texto literal de fallo, pendiente, restaurar sin nada y sin tienda; cada peldaño del error una vez con prioridad alta. VoiceOver atenúa la cama (`duckOthers` del sistema) y la cama vuelve a su nivel en 1 s (02 §5.2). Escape de Z cierra toda hoja y vuelve de toda pantalla empujada.

### 5c · Gesto → alternativa sin gesto → Control por botón → teclado / Pointer

| Gesto | Dónde | Alternativa sin gesto (toque simple) | Control por botón / AssistiveTouch / Acceso asistido | Teclado completo (iPad / Mac Catalyst si llega) / Pointer |
|---|---|---|---|---|
| Pulsación larga sobre el nombre de la mezcla (de día) | Página | Con "Controles visibles de noche" o Button Shapes activos, aparece a la derecha del nombre un `TextAction` "Guardar" (`comun.guardar`) 44 que abre el mismo menú como `Menu` (toque simple) | El elemento "nombre" expone el menú como acciones; el `Menu` de toque simple también está | Pulsar Retorno con foco en el nombre abre el `Menu`; Pointer: clic secundario abre el `contextMenu` |
| Deslizar fila propia (Renombrar / Eliminar) | Mezclas | Pulsación larga sobre la fila abre un `contextMenu` del sistema con "Renombrar" / "Eliminar" / "Subir" / "Bajar"; con Button Shapes, el mismo menú como `Menu` en un `TextAction` "Más" (`mezclas.mas`, pendiente de E7) 44 a la derecha de la fila | Acciones del elemento (VoiceOver) o el `Menu` | Supr con foco en la fila = confirmación de eliminar; Retorno = cargar |
| Pulsación larga y arrastre para reordenar (`onMove`) | Mezclas · "tuyas" | Acciones "Subir" / "Bajar" del `contextMenu` | Acciones "Subir" / "Bajar" | ⌥↑ / ⌥↓ con foco en la fila |
| Toque en fila | Mezclas | Es ya el toque simple | Elemento seleccionable | Retorno / Espacio; Pointer: clic |
| Arrastre para cerrar hoja | Hojas | Pro: "Ahora no" (`TextAction`, 2.3). Ajustes (`.large`): **no hay toque simple en iOS 17/18** (tocar el indicador no cierra una hoja de un solo detent); con VoiceOver, escape de Z; iOS 26: cierre del sistema **[a verificar]**. Elevado al director en §9.13 | Elemento "Cerrar" que el sistema expone para la hoja (Control por botón) | Esc (`.keyboardShortcut(.cancelAction)`) |
| Gesto de borde para volver | Mezclas, Qué sabemos, Lo que no hay, Cómo se genera, Diagnóstico | Botón atrás del sistema | Elemento atrás | Esc / ⌘[ |
| Toque en "Comprar" / "Empezar la prueba" | Pro | Es ya el toque simple | Elemento | Retorno / Espacio |
| Toque en toggle / picker de Salida | Ajustes | — | Elemento `.isToggle` / el del sistema | Espacio |
| Pulsación larga en la versión (copiar) | Ajustes | `Menu` de toque simple con "Copiar" cuando Button Shapes está activo | Acción "Copiar" | ⌘C con foco |

No hay en estas pantallas ningún gesto propio (arrastres de nivel, pellizcos, varios dedos, dobles toques): todo lo que no es del sistema es un toque. Por eso la alternativa sin gesto casi siempre es "el mismo toque".

### 5d · Dynamic Type por tramo (qué cambia en cada tramo)

Todo escala con `relativeTo` (03 §3.4, 04 §2.0.2 `TypeStep`); las alturas de fila van en `@ScaledMetric(relativeTo: .body)`. **Nada por debajo de 13 pt en ningún tramo: los pasos 7, 8 y 9 llevan suelo de 13 pt (`max(13, scaled)`) en xS-M** (con `relativeTo` del sistema, `.footnote` y `.subheadline` bajan a 12 en xSmall-Medium); el resto escala libre. §9.15 pide a E1 que lo fije en `TypeStep` para todas las entregas.

| Tramo | Mezclas (12) | Menú y alertas (13) | Hoja Pro (14) | Prueba y renglón de estado en la página (15, 4) | Qué sabemos · Cómo se genera · Lo que no hay (17, 31, 32) | Ajustes y listas de opciones (18) | Diagnóstico (30) |
|---|---|---|---|---|---|---|---|
| **xS-L** | Fila 72 (92 con receta a 2 líneas); 2 propias + 4 de la casa + Ajustes = 792: desplaza 24 en Large; sin desplazar en xS-M | Del sistema (menú y alertas escalan solos) | Columna 576 + pie fijo 168 (232 con "Empezar la prueba"); sin desplazar en 17 Pro salvo con la prueba sin usar (desplaza 0: 576 + 232 = 808); SE desplaza ≈ 111 / 175 | Versalita 13 (suelo) en 64-82; frase de la última noche en 144-184 (2 líneas); nota 1-2 líneas de 15/20 en 196-236 + "Entendido" 234-256; todo cabe sobre el horizonte (banda desde 272). Renglón de estado: 1-2 líneas paso 7 (hueco de E2) | Afirmación 17; cuerpo 17/26; Qué sabemos ~1 400 de alto | Filas 56/72; desplaza ≈ 516; listas de opciones: filas 56 desde 76 | Filas 44 del registro; pie fijo 64 |
| **xL-xxxL** | Fila 80-96; la receta pasa a 2-3 líneas; desplaza siempre | Del sistema | Precio 64-72 (tope `.accessibility2` = 79 no alcanzado); titular 3 líneas; filas 52-60; pie fijo 196-216 (260-284 con Empezar); la columna desplaza | Nota a 3-4 líneas: ya no cabe sobre el horizonte; **regla**: desde xL la nota y "Entendido" viven **debajo del horizonte, en el hueco del renglón de estado** (la página es `ScrollView` siempre, 05 §2.0); **el horizonte no se mueve** (03 §3.5 solo lo ancla bajo la cabecera en AX, y nunca de forma transitoria) **[E2 confirma, §9.14]**. Renglón de estado: 3 líneas | Cuerpo 20-26/32-38; hairlines iguales | Filas 64-80; notas 15-18; cabeceras versalitas 15-18; opciones 64-80 | Tiempo y evento en 2 líneas (tiempo arriba) desde xxL; fila 64 |
| **AX1-AX2** | Fila 96-112: nombre arriba, receta debajo a 3-4 líneas, estado **debajo del nombre** (no a la derecha) | Del sistema | Precio 72-79 (tope `.accessibility2` = 79: `largeTitle` 34 → 48 en AX2, 56 × 48/34); titular 4 líneas; filas 60-72; pie fijo 240-260 (Comprar 80, Restaurar · Ahora no apilados 56 + 56, pie 2-3 líneas; + Empezar 80) **[a medir]** | Versalita 20-24; nota 5-6 líneas de 24-28 bajo el horizonte; "Entendido" 64; el horizonte anclado bajo la cabecera (03 §3.5, fijo para el tramo). Renglón de estado: 4-5 líneas, botón 64 | Cuerpo 28-34/40-46 | Filas 88-112; valor **debajo** del nombre (`ViewThatFits`); toggles a la derecha del nombre en su propia línea; notas 20-24 a 4 líneas; opciones 88-112 | Tiempo en su línea, evento en 2-3 líneas; fila 96 |
| **AX3-AX5** | Fila 128-160; la receta hasta 6 líneas; una mezcla por pantalla casi; la barra inferior sustituye "Noche" por `circle.lefthalf.filled` (03 §3.6) | Del sistema | Precio fijo en 79 (tope); titular 5-6 líneas; una fila de la lista por 80 pt; pie fijo ≤ 40 % del alto (Comprar 96 + Restaurar 64 + Ahora no 64 + pie); la columna desplaza siempre; en AX3+ `pro.prueba.empezar.nota` aparece **dentro de la columna** bajo "gratis siempre" (el pie ya desplaza y la pista no basta); en AX5 el pie de privacidad pasa **dentro** de la columna para que Comprar y Restaurar quepan fijos **[a medir]** | Versalita 28-34 a 2 líneas; nota 6-8 líneas de 34-40; "Entendido" 80; la nota desplaza con la página. Renglón de estado: 5 líneas, botón 64 | Cuerpo 40-53/52-66; una afirmación por pantalla | Filas 160-200; todo apilado; notas 28-34; opciones 160 | Tiempo + evento en 3-5 líneas; fila 140 |

Lo que nunca cambia: una columna; cero cajas; las hairlines; el precio antes que nada; Comprar y Restaurar siempre visibles; "Entendido" siempre debajo de su nota; ningún texto trunca (`lineLimit(nil)`), salvo el nombre de mezcla escrito por el usuario (`minimumScaleFactor(0.8)` y después 2 líneas). Capturas de control del entregable: Large, xxxLarge, AX3, AX5 en ES y EN de las diez pantallas.

### 5e · Catálogo de cadenas ES / EN por clave (contexto y longitud máxima)

Son las cadenas que se compilan (String Catalog; E7 revisa voz y es-419 antes del cierre). **Toda clave y toda cadena de esta tabla coincide letra a letra con 10 §5e** (secciones 5e.1, 5e.2, 5e.3, 5e.9, 5e.10, 5e.11, 5e.12 y 5e.16); las cadenas que esta entrega necesita y 10 no tiene van marcadas **[pendiente de E7]** y listadas en §9.19, con la redacción de 10 más cercana como provisional. Reglas (10 §0): segunda persona sin exclamaciones; sin diminutivos; sin emojis; punto medio " · " U+00B7 con espacios finos U+2009; versalitas con `.smallCaps()` sobre la cadena en minúscula (nunca `uppercased()`); números con el formateador local (`29,99 €` / `$29.99`); `%@` / `%lld` son argumentos del catálogo; las claves con `%lld` llevan variante plural (one / other). "Máx." es el tope de caracteres de la cadena ES para que quepa en su sitio en Large en una línea (o en las líneas indicadas); si EN lo supera, se acorta EN. Ninguna cadena contiene palabras de la lista negra (10 §0.4-§0.5: tampoco "Escudo", "lanzamiento", "Lluvia fina", "Cama rosa", "Mar lento", "chip", "envolvente", "Desbloquear", "Tu instrumento"); el lint corre también sobre Qué sabemos (C54). "Tide" siempre con mayúscula en EN (es el nombre de la función).

**Comunes (10 §5e.1)**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `app.name` | SleepNoise | SleepNoise | asunto de "Escribir al autor", `ajustes.seccion.sobre`, `diagnostico.asunto`; nunca en la página | 10 |
| `comun.guardar` | Guardar | Save | botón de las alertas Guardar y Renombrar y `TextAction` junto al nombre (Button Shapes) | 10 |
| `comun.cancelar` | Cancelar | Cancel | alertas del sistema | 10 |
| `comun.entendido` | Entendido | Got it | `TextAction` bajo la nota "La prueba terminó" | 12 |
| `comun.ahora_no` | Ahora no | Not now | `TextAction` de la hoja Pro, fila de Restaurar; cierra la hoja | 10 |
| `comun.pro` | pro | pro | palabra de estado (E2: filas de capa; E3: Marea) | 3 |
| `comun.pro.nivel` | pro · %lld | pro · %lld | versalita con el nivel guardado ("pro · 30"); la capa conserva su nivel, el motor la ignora sin acceso, la degradación nunca escribe (C23) [E2] | 8 |
| `comun.renombrar` | Renombrar | Rename | deslizar en Mezclas; `contextMenu` del nombre; título de la alerta Renombrar | 10 |
| `comun.eliminar` | Eliminar | Delete | acción destructiva del sistema (rojo del sistema) | 10 |

**Cabecera de la página y prueba (pantallas 15, 16; 10 §5e.3)**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `pro.prueba.estado` (plural) | other: prueba · quedan %lld noches · one: prueba · queda 1 noche | other: trial · %lld nights left · one: trial · 1 night left | Versalita paso 9; botón 44 de día en página de día, texto estático en `NightWindow`; aparece solo desde que la prueba empieza (C07); n = noches de calendario locales que quedan (§9.3); con n = 1 se usa `pro.prueba.estado.ultima` | 28 |
| `pro.prueba.estado.ultima` | prueba · última noche | trial · last night | Última noche de la prueba | 22 |
| `pro.prueba.estado.gratis` | gratis siempre | always free | Sin prueba (instalación nueva) y tras la prueba; botón → hoja Pro (que ya enumera lo gratis); desaparece tras 7 sesiones gratuitas (03 §1.2; el contador se pone a cero al empezar la prueba) | 14 |
| `prueba.ultima` | Última noche con todo. Mañana, lo gratis sigue gratis. | Last night with everything. Tomorrow, free stays free. | Última noche, en el sitio de la línea de estado (144-184, 2 líneas), paso 7 `texto2`, hasta el Play; sin botón; solo de día | 60 |
| `prueba.terminada` | La prueba terminó. Lo que usaste sigue aquí. | The trial is over. What you used is still here. | Nota de una vez (196-236), primera apertura de día tras el fin, + `comun.entendido`; lo que espera a Pro se ve inline en las filas ("pro · 30"); nada se escribe (C23) | 48 |
| `pro.prueba.empezar` | Empezar la prueba · 7 noches | Start the trial · 7 nights | `HairlineAction` primaria de la hoja Pro mientras la prueba no se ha usado (C07); `startTrial()` desde la hoja; estado en Keychain | 28 |
| `pro.prueba.empezar.nota` | Dura siete noches. No se cobra nada ni se pide tarjeta. Al acabar, lo gratis sigue gratis y tus mezclas se conservan. | Lasts seven nights. Nothing is charged and no card is asked. When it ends, free stays free and your mixes are kept. | Paso 8 `texto2`; en Large vive en la pista de VoiceOver; visible en la columna solo desde AX3 (§5d) | 110 |
| `pagina.estado.sonando.sin` | Sonando · sin %@ | Playing · without %@ | Renglón de estado (E2 lo dibuja); `%@` = capa(s) Pro sin acceso en minúscula: "océano", "trueno ni océano" (`pagina.capas.ni`) | 40 |
| `pagina.estado.silencio.pro` | En silencio · esta mezcla es Pro | Silent · this mix is Pro | Mezcla cargada toda Pro sin acceso, en reposo [E2] | 34 |
| `pagina.estado.sonando.defecto` | Sonando · rosa a 40 | Playing · pink at 40 | Play con todo a 0 o toda la mezcla Pro sin acceso: el instrumento siempre suena (03 §1.3) [E2] | 22 |
| `pagina.estado.silencio` | En silencio | Silent | Renglón de estado en reposo y tras Vaciar [E2] | 12 |
| `mezcla.nombre.sin` | %@ · sin %@ | %@ · without %@ | Nombre de la página con la mezcla recortada ("Mar y viento · sin Océano"; también las de la casa con Pro, C18); la capa con mayúscula inicial (03 §1.3) [E2] | 34 |
| `mezcla.nombre.vacio` | Esta noche | Tonight | Nombre de la página tras Vaciar; el mismo texto que `mezclas.esta_noche` [E2] | 10 |
| `tip.arrastre` | Arrastra sobre el nombre para cambiar el nivel. | Drag across the name to change the level. | El único TipKit (C65), paso 7, 6 s, segundo arrastre, solo fuera de `NightWindow` [E2] | 50 |

**Mezclas (pantalla 12; 10 §5e.9)**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `mezclas.titulo` | Mezclas | Mixes | Título paso 3 (sustituye a `mixes.title` / `control.mixes`); la palabra de la barra es `barra.mezclas` (E2) | 8 |
| `mezclas.seccion.tuyas` | tuyas | yours | Cabecera versalita (VoiceOver la lee tal cual) | 6 |
| `mezclas.seccion.casa` | de la casa | from the house | Cabecera versalita | 14 |
| `mezclas.esta_noche` | Esta noche | Tonight | Nombre de la mezcla viva sin guardar (página; nombre por defecto al guardar vacío: "Esta noche", "Esta noche 2", …); no es una pantalla (reconciliación §3). 10 §2.7 la dibuja además como primera fila de "tuyas": aquí no (§9.19) | 10 |
| `mezcla.casa.rosa_lluvia` | Rosa y lluvia | Pink and rain | Mezcla de la casa: lluvia 55 · rosa 20; libre (C17, C18) | 14 |
| `mezcla.casa.mar_viento` | Mar y viento | Sea and wind | océano 50 · viento 20; Pro (carga recortada sin acceso, nunca hoja) | 14 |
| `mezcla.casa.marron_hoguera` | Marrón y hoguera (es-419: Marrón y fogata) | Brown and fire | marrón 40 · hoguera 30; Pro (carga recortada) | 18 |
| `mezcla.casa.pared` | Pared | Wall | marrón 40 · lluvia 30 · viento 30; libre | 6 |
| `mezclas.receta.capa` | %@ %lld | %@ %lld | Segmento de receta en minúscula ("lluvia 55"); la receta es solo niveles: formato v2 `[{id, level}]` + `version: 2` (C09, C20); nunca Marea ni temporizador | 14 |
| `mezclas.receta.separador` | · | · | Se compila para que la receta se componga por segmentos y parta líneas en el separador | 1 |
| `mezclas.receta.pro` | %@ es Pro | %@ is Pro | Segmento final inline, sin tachar ("· océano es Pro"); con dos o más capas Pro, `mezclas.receta.pro.2` / `.n` **[pendiente de E7]**: "%@ y %@ son Pro" / "%@ and %@ are Pro" | 18 |
| `mezclas.sonando` | sonando ahora | playing now | Versalita paso 9 `texto2` junto al nombre de la mezcla cargada que suena; paso 7 Medium en página nocturna | 14 |
| `mezclas.vacio` | La mezcla de esta noche se guarda desde su nombre. | Tonight's mix is saved from its name. | Fila 72 vacía, paso 6 `texto2`; sin imperativo | 52 |
| `mezclas.guardada` | Guardada | Saved | Confirmación 3 s en el renglón de estado y anuncio; `.success` | 10 |
| `mezclas.eliminar.titulo` | ¿Eliminar "%@"? | Delete "%@"? | `confirmationDialog` | 30 |
| `mezclas.eliminar.nota` | La mezcla de esta noche no cambia. | Tonight's mix doesn't change. | Mensaje del diálogo | 36 |
| `ax.accion.subir` / `ax.accion.bajar` | Subir / Bajar | Move up / Move down | Acciones del `contextMenu` de la fila propia y de VoiceOver (10 §5e.16) | 10 |
| `mezclas.mas` | Más | More | `TextAction` del `Menu` de fila con Button Shapes (§5c) **[pendiente de E7]** | 8 |
| `mezclas.ajustes` | Ajustes | Settings | Última fila (el mismo texto que `ajustes.titulo`) | 10 |

**Menú del nombre, Guardar y Renombrar (pantalla 13; 10 §5e.2)**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `mezcla.menu.guardar` | Guardar como mezcla… | Save as a mix… | Ítem del `contextMenu` del nombre | 22 |
| `mezcla.menu.guardar.pro` | Guardar como mezcla… · pro | Save as a mix… · pro | Cuarta mezcla propia sin acceso (`freeSavedMixLimit` 1 → 3; sin límite con Pro); al tocar, hoja Pro de día, mezcla intacta; de noche nada | 28 |
| `menu.guardar.en` | Guardar en «%@» | Save to “%@” | Ítem, solo si la viva viene de una propia y cambió; conserva las capas Pro a su nivel (C23) **[pendiente de E7]** | 20 + nombre |
| `mezcla.menu.vaciar` | Vaciar | Clear | Ítem (solo de día); pone todo a 0 sin alerta: es reversible cargando una mezcla | 8 |
| `guardar.titulo` | Guardar como mezcla | Save as a mix | Título de la alerta Guardar **[pendiente de E7]** (provisional: `mezcla.menu.guardar` sin puntos suspensivos) | 22 |
| `mezcla.guardar.campo` | Nombre de la mezcla | Mix name | Placeholder y etiqueta accesible del campo (alertas Guardar y Renombrar); precargado con el nombre de la página cuando viene de una propia; 24 caracteres máx. | 20 |

**Hoja Pro (pantalla 14; 10 §5e.10)**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `pro.titulo` | %@ | %@ | `%@` = `product.displayName` ("SleepNoise Pro"), versalita paso 9 `texto2` arriba de la hoja; nunca un nombre grabado ni "Tu instrumento" (C12) | 14 |
| `pro.precio.cargando` | — | — | Cifra paso 1 en `texto3` hasta `Product.displayPrice` | 1 |
| `pro.una_vez` | Una vez. | Once. | Paso 8 `texto2` 13/18 bajo la cifra, siempre | 10 |
| `pro.precio` | %@ · Una vez. | %@ · Once. | `%@` = `Product.displayPrice`; valor de la fila Pro de Ajustes y VoiceOver; un solo `displayPrice`, nunca una constante de copy (C02) | 20 |
| `pro.pie` | Un solo pago. Para siempre, en todos tus iPhone. | One payment. Forever, on every iPhone you own. | Titular paso 2 · 28/34, 2 líneas (C12; antes `pro.titular`; el pie de privacidad es `lo_que_no_hay.pie`) | 50 |
| `pro.con` | con pro | with pro | Versalita de sección | 8 |
| `pro.incluye.texturas` | Todas las texturas | All textures | Primera fila 44 paso 6 de "con pro"; sin número (C04) | 20 |
| `pro.incluye.texturas.detalle` | Océano, ventilador, trueno, hoguera, arroyo y cabina | Ocean, fan, thunder, campfire, brook and cabin | Detalle paso 7 `texto2` (es-419: fogata); la lista nombrada, nunca la cifra | 64 |
| `pro.incluye.marea` | Marea | Tide | Fila 44 paso 6 (C15) | 20 |
| `pro.incluye.mezclas` | Mezclas sin límite | Unlimited mixes | Fila 44; 3 gratis, sin límite con Pro | 20 |
| `pro.familia` | En familia | With your family | Última fila de "con pro" (Family Sharing, 1.0, C12) | 16 |
| `pro.gratis` | gratis siempre | always free | Versalita de sección | 14 |
| `pro.gratis.lista` | Blanco, rosa, marrón, lluvia y viento · todo el temporizador · tres mezclas | White, pink, brown, rain and wind · the whole timer · three mixes | Paso 6 `texto2`, 2 líneas (C03, C04; la lista libre solo crece) | 72 |
| `pro.comprar` | Comprar · %@ | Buy · %@ | `HairlineAction` 64 entre hairlines `índice` 1,5 pt (solo con precio); `%@` = `displayPrice`; sin "Desbloquear" (C12) | 20 |
| `pro.comprar.sin_precio` | Comprar | Buy | Sin producto: `texto2` entre hairlines `trazo-hoja`, `.notEnabled` | 8 |
| `pro.comprando` | Comprando… | Buying… | El botón mientras StoreKit trabaja; sin spinner | 12 |
| `pro.restaurar` | Restaurar compra | Restore purchase | `TextAction` 44 (x 20) | 18 |
| `pro.buscando` | Buscando… | Looking… | El botón de restaurar mientras `AppStore.sync()` (≤ 10 s) | 10 |
| `pro.resena` | Escribir una reseña | Write a review | `TextAction` solo en el estado comprado (C55); abre App Store; nunca de noche | 20 |
| `pro.gracias` | Gracias. Todo abierto. | Thank you. Everything's open. | Sustituye al botón 1,5 s tras comprar o restaurar; `.success`; también el paso 2 del estado comprado en el lugar del precio | 24 |
| `pro.fallo` | No se ha podido completar. No se ha cobrado nada. | Couldn't complete. Nothing was charged. | Línea de resultado; `.error` salvo en `.userCancelled`; botón intacto | 52 |
| `pro.fallo.sin_confirmar` | No se ha podido confirmar. Si App Store te ha cobrado, Restaurar compra lo abre. | Couldn't confirm. If the App Store charged you, Restore purchase opens it. | `.unverified` y errores de red tras la hoja del sistema (la transacción puede llegar por `Transaction.updates`) | 84 |
| `pro.pendiente` | Pendiente de aprobación familiar. Se abrirá solo cuando llegue. | Waiting for family approval. It will open on its own. | Línea de resultado, 2 líneas | 66 |
| `pro.pendiente.boton` | Pendiente | Pending | Botón deshabilitado mientras la compra está pendiente **[pendiente de E7]** | 12 |
| `pro.sin_tienda` | La tienda no responde. Nada cambia: sigue sonando. | The store isn't responding. Nothing changes: it keeps playing. | 8 s sin producto o error de StoreKit, **con sonido** (`isPlaying`); botón `pro.comprar.sin_precio` | 54 |
| `pro.sin_tienda.silencio` | La tienda no responde. Nada cambia. | The store isn't responding. Nothing changes. | Ídem cuando nada suena | 36 |
| `pro.restaurar.no` | No hay ninguna compra con esta cuenta de Apple. Si la hiciste con otra, inicia sesión con ella en App Store. | No purchase found for this Apple Account. If you bought with another one, sign in with it in the App Store. | Línea de resultado, 3 líneas | 108 |
| `pro.ajustes.gracias` | %@ · gracias · %@ | %@ · thank you · %@ | Fila Pro de Ajustes y versalita del estado comprado de la hoja (el recibo, C12); `%@` = `displayName`, `%@` fecha corta | 36 |
| `pro.ajustes.familia` | · en familia | · with your family | Sufijo (segunda línea en Ajustes) si `ownershipType == .familyShared` | 16 |
| `pro.ajustes.ver` | %@ | %@ | Fila Pro de Ajustes sin Pro (`displayName`), con `pro.precio` a la derecha; abre la hoja solo de día | 16 |
| `lo_que_no_hay.pie` | Sin suscripción. Sin cuenta. Sin rastreo. | No subscription. No account. No tracking. | Pie paso 8 de la hoja Pro, de Ajustes y de la página "Lo que no hay" (C09); en 1.1 gana "Tus mezclas, en tu iCloud si quieres." | 44 |

**Qué sabemos (pantalla 17; 10 §5e.11, letra a letra; cuerpos con `\n` entre párrafos)**

| Clave | ES | EN |
|---|---|---|
| `sabemos.titulo` | Qué sabemos | What we know |
| `sabemos.1.afirmacion` | Enmascara los sonidos que te despiertan. | Masks the sounds that wake you. |
| `sabemos.1.cuerpo` | El ruido continuo redujo los despertares provocados por ruidos intermitentes en un estudio de laboratorio (Stanchina y otros, Sleep Medicine, 2005; cuatro voluntarios sanos).\nLa evidencia de que el ruido ayude a dormir en general es de muy baja calidad (Riedy y otros, Sleep Medicine Reviews, 2021; revisión de 38 estudios).\nPor eso no decimos que duermas mejor. | Continuous noise reduced arousals caused by intermittent noise in one lab study (Stanchina et al., Sleep Medicine, 2005; four healthy volunteers).\nEvidence that noise helps sleep in general is of very low quality (Riedy et al., Sleep Medicine Reviews, 2021; 38 studies reviewed).\nThat is why we never say you will sleep better. |
| `sabemos.2.afirmacion` | Te acompaña a respirar más despacio. | Keeps you company as you breathe more slowly. |
| `sabemos.2.cuerpo` | Respirar a unas seis veces por minuto se asocia a mayor variabilidad cardiaca y a menor activación en una revisión (Zaccaro y otros, Frontiers in Human Neuroscience, 2018; quince estudios) y en un ensayo con veinte participantes con dificultad para dormirse, según Tsai y otros (Psychophysiology, 2015).\nNo tratamos nada; no es un producto sanitario. La Marea acompasa el oleaje a ese ritmo y se retira sola. | Breathing at about six times a minute is associated with higher heart-rate variability and lower arousal in one review (Zaccaro et al., Frontiers in Human Neuroscience, 2018; fifteen studies) and in one trial with twenty participants who had trouble falling asleep, per Tsai et al. (Psychophysiology, 2015).\nWe treat nothing; this is not a medical product. The tide paces the sea to that rhythm and recedes on its own. |
| `sabemos.3.afirmacion` | Nunca se repite. | It never loops. |
| `sabemos.3.cuerpo` | El sonido se fabrica en tu iPhone mientras suena; no hay archivo ni bucle. Puedes comprobarlo en el tamaño de la app.\nLo que no podemos afirmar: que un sonido sin bucle te despierte menos que uno con bucle. No conocemos un estudio que lo mida. | The sound is made on your iPhone as it plays; there is no file and no loop. You can check the app's size.\nWhat we cannot claim: that a sound without a loop wakes you less than one with a loop. We know of no study that measures it. |
| `que_sabemos.en_vela.afirmacion` | Quedarse en la cama despierto. | Lying awake in bed. |
| `que_sabemos.en_vela` | En %lld participantes con dificultad para dormirse, salir de la cama al no dormirse y volver con sueño se asoció a menos tiempo despierto en la cama, según %@.\nLo decimos como hallazgo, no como consejo: Madrugada no te dice que te levantes. | In %lld participants who had trouble falling asleep, getting out of bed when sleep didn't come and returning when sleepy was associated with less time awake in bed, per %@.\nWe say it as a finding, not advice: Small hours never tells you to get up. |
| `sabemos.4.titulo` | Lo que no sabemos | What we don't know |
| `sabemos.4.cuerpo` | Si el ruido te ayuda a dormir más o mejor. Si el ruido rosa o el marrón hacen algo que el blanco no haga. Si una noche con la Marea cambia algo al día siguiente. Nadie lo ha medido bien todavía, y no vamos a decir que sí. | Whether noise helps you sleep more or better. Whether pink or brown noise does anything white noise doesn't. Whether a night with the tide changes anything the next day. Nobody has measured it well yet, and we won't say they have. |
| `sabemos.pie` | Nada de lo anterior es consejo médico. Si duermes mal muchas noches, habla con un profesional. | None of this is medical advice. If you sleep badly many nights, talk to a professional. |

Longitud: afirmaciones ≤ 48 car.; cuerpos ≤ 420 car. (es-ES); pie ≤ 96 (dos líneas). `que_sabemos.en_vela` no se compila hasta que E7 verifique la cita (§9.6); `sabemos.2.cuerpo` no cita financiación porque ninguna está verificada (10 §5e.11).

**Ajustes, Lo que no hay y Cómo se genera (pantallas 18, 31, 32; 10 §5e.12, §5e.8, §5e.5)**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `ajustes.titulo` | Ajustes | Settings | Título | 10 |
| `ajustes.seccion.noche` | noche | night | Cabecera versalita | 8 |
| `ajustes.noche.pasar_sola` | Pasar sola a Noche | Switch to Night | Fila 56 con valor (C47) | 30 |
| `ajustes.noche.pasar_sola.bloquear` | Al bloquear | When locked | Opción, por defecto | 12 |
| `ajustes.noche.auto.1` | 1 min | 1 min | Opción (entrada automática solo desde la página) | 6 |
| `ajustes.noche.auto.3` | 3 min | 3 min | Opción | 6 |
| `ajustes.noche.auto.nunca` | Nunca | Never | Opción | 6 |
| `ajustes.pantalla` | Mantener encendida | Keep screen on | Fila 56 con valor (C46) | 20 |
| `ajustes.pantalla.carga` | Mientras carga | While charging | Opción, por defecto | 16 |
| `ajustes.pantalla.siempre` | Siempre | Always | Opción | 8 |
| `ajustes.pantalla.nunca` | Nunca | Never | Opción | 6 |
| `madrugada.ajuste.hora` | Mostrar la hora en Madrugada | Show the clock in Small hours | Toggle (opt-in, C60) [E4] | 30 |
| `madrugada.ajuste.nota` | Madrugada no enseña la hora a propósito. | Small hours hides the clock on purpose. | Nota paso 8 [E4] | 44 |
| `ajustes.noche.controles` | Controles visibles de noche | Visible controls at night | Toggle; se activa solo con Control por botón / AssistiveTouch | 30 |
| `ajustes.noche.controles.nota` | Cuatro botones grandes en Noche: −15 min, pausa, +15 min y Página. | Four large buttons in Night: −15 min, pause, +15 min and Page. | Nota paso 8, 2 líneas | 68 |
| `ajustes.seccion.haptica` | háptica | haptics | Cabecera versalita (C58) | 8 |
| `marea.haptica` | Háptica | Haptics | Fila 56 → lista de opciones [E3] | 8 |
| `marea.haptica.ninguna` / `.minima` | Ninguna · Mínima | None · Minimal | Opciones; por defecto Ninguna (C35); "Marcada" no se compila en 1.0 | 8 |
| `marea.haptica.nota` | Tres a cinco respiraciones al empezar. De noche nunca vibra. | Three to five breaths at the start. Never at night. | Nota paso 8 fuera de la fila | 60 |
| `ajustes.seccion.acostarte` | al acostarte | at bedtime | Cabecera versalita | 14 |
| `ajustes.acostarte` | Al acostarte | At bedtime | Fila 72 → una página de texto (E6, 09; cadenas `ajustes.acostarte.p1` / `.p2` / `.abrir` en 10 §5e.12) | 34 |
| `ajustes.acostarte.sub` | Que suene sola al activar Sueño. Dos pasos en Atajos. | Start on its own when Sleep turns on. Two steps in Shortcuts. | Subtítulo paso 7 | 56 |
| `ajustes.seccion.salida` | salida | output | Cabecera versalita (C41) | 8 |
| `ajustes.salida` | Salida | Output | Fila 56 con el `AVRoutePickerView` del sistema | 8 |
| `ajustes.seccion.pro` | pro | pro | Cabecera versalita | 4 |
| `ajustes.seccion.sobre` | sobre %@ | about %@ | Cabecera versalita; `%@` = `app.name` en minúscula tipográfica | 16 |
| `lo_que_no_hay.titulo` | Lo que no hay | What's not here | Fila de Ajustes → página 2.10; título de la página | 16 |
| `lo_que_no_hay.lista` | Sin suscripción · Sin cuenta · Sin rastreo · Sin anuncios · Sin puntuación · Sin racha · Sin tutorial | No subscription · No account · No tracking · No ads · No score · No streak · No tutorial | Lista de la página (una línea por hecho, partida por " · ") y de la captura 6 | 110 |
| `lo_que_no_hay.resena` | No te pediremos que la valores. | We won't ask you to rate it. | Párrafo de la página (C55) | 36 |
| `lo_que_no_hay.diagnostico` | Un registro de la noche, en tu teléfono. Solo sale si tú lo envías. | A log of the night, on your phone. It only leaves if you send it. | Párrafo de la página (C56) | 72 |
| `como.titulo` | Cómo se genera | How it's made | Fila de Ajustes → página 2.9; título | 16 |
| `como.cuerpo` | El sonido se fabrica en tu iPhone mientras suena: no hay archivo ni bucle. Por eso la app ocupa lo que ocupa (mira el tamaño en Ajustes) y por eso nunca se repite. En cada versión comprobamos con un test que diez minutos de sonido no se parecen a sí mismos. | The sound is made on your iPhone as it plays: there is no file and no loop. That is why the app is as small as it is (see the size in Settings) and why it never repeats. Every release is checked with a test that ten minutes of sound never resemble themselves. | Cuerpo paso 6, 17/26 (es-419: "se genera") | 300 |
| `ajustes.version` | Versión %@ · %@ | Version %@ · %@ | "Versión 1.0 · 4,2 MB"; el segundo `%@` es el tamaño de descarga fijado en build; pulsación larga = Copiar | 24 |
| `ajustes.autor` | Escribir al autor | Write to the author | Fila del grupo "sobre" (C58): abre el correo del usuario; sin formulario | 18 |

**Diagnóstico y error de audio (pantallas 30, 4; 10 §5e.12 y §5e.2)**

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `diagnostico.titulo` | Diagnóstico | Diagnostics | Fila de Ajustes y título | 12 |
| `diagnostico.nota` | Un registro de la noche, en tu teléfono: tiempos desde Play, cortes y errores de esta sesión y la anterior. Sin fecha, sin nombres, sin identificadores. Solo sale si tú lo envías por correo. | A log of the night, on your phone: times since Play, drops and errors for this session and the last. No date, no names, no identifiers. It only leaves if you send it by mail. | Paso 6 `texto2`, 4 líneas (C56) | 180 |
| `diagnostico.enviar` | Enviar informe | Send report | `HairlineAction` de Diagnóstico; `TextAction` en la línea 2 de la página (peldaños 3 y 5) | 16 |
| `diagnostico.vacio` | Nada que informar. | Nothing to report. | Anillo vacío, fila 72 paso 6 | 20 |
| `diagnostico.asunto` | Informe de %@ %@ | %@ report %@ | Asunto del correo; `%@` = `app.name`, `%@` versión | 30 |
| `diag.motor` | Motor | Engine | Fila 56 **[pendiente de E7]** | 10 |
| `diag.motor.valor` | %@ kHz · %@ | %@ kHz · %@ | Valor tabular; el segundo `%@` = `diag.puerto.*` **[pendiente de E7]** | 28 |
| `diag.puerto.bluetooth` / `.altavoz` / `.auriculares` | Bluetooth · Altavoz · Auriculares | Bluetooth · Speaker · Headphones | Tipo de puerto (`portType`); nunca `portName` **[pendiente de E7]** | 12 |
| `diag.sesion.actual` / `diag.sesion.anterior` | esta sesión · sesión anterior | this session · last session | Cabeceras versalitas del registro **[pendiente de E7]** | 16 |
| `diag.ev.arranque` … | Arranque · Parada · Fundido · Interrupción · Reanudado · Ruta · Reinicio del motor · Error | Start · Stop · Fade · Interruption · Resumed · Route · Engine restart · Error | Eventos del registro, con detalle tras " · " **[pendiente de E7]** | 24 |
| `diag.ev.detalle.*` | temporizador · usuario · fundido completo · fallido · correcto · reinicio de servicios de audio | timer · user · full fade · failed · ok · audio services reset | Detalles traducidos; los códigos de error van tal cual **[pendiente de E7]** | 32 |
| `pagina.error.inicio` | No se ha podido iniciar el sonido. Toca para reintentar. | Couldn't start the sound. Tap to try again. | Peldaño 1, renglón de estado como botón 44, tras fallar el reintento silencioso (sustituye `error.audio`) [E2] | 56 |
| `pagina.error.inicio.2` | Si sigue sin sonar, cierra la app y vuelve a abrirla. | If it still won't play, close the app and open it again. | Peldaño 2, mismo renglón, botón [E2] | 56 |
| `pagina.error.inicio.3` | Cierra las apps que usen el micrófono y vuelve a intentarlo. | Close any app using the microphone and try again. | Peldaño 3, renglón de estado (2 líneas) + `diagnostico.enviar` en la línea 2 solo de día [E2] | 60 |
| `noche.estado.sin_sonido` | Sin sonido | No sound | Peldaño 4 en Noche (E4) | 12 |
| `pagina.estado.manana.error` | Anoche el sonido se detuvo a las %@. | Last night the sound stopped at %@. | Peldaño 5, renglón de estado a la mañana + `diagnostico.enviar` en la línea 2 [E2] | 40 |
| `pagina.estado.manana.error.inicio` | Anoche el sonido no pudo iniciarse. | Last night the sound couldn't start. | Peldaño 5 tras un tercer fallo nocturno sin arranque **[pendiente de E7]** | 40 |

**VoiceOver (etiquetas y pistas de 5b que no coinciden con ninguna cadena visible; 10 §5e.16)**

| Clave | ES | EN | Contexto |
|---|---|---|---|
| `ax.prueba.cabecera` (pl) | Prueba, quedan %lld noches | Trial, %lld nights left | Etiqueta de la cabecera en la prueba; `one`: "Prueba, queda una noche" |
| `ax.prueba.pista` | Toca dos veces para ver qué incluye Pro. | Double-tap to see what's in Pro. | Pista de la cabecera (de día) |
| `ax.nombre.pista` | Mantén para guardar o renombrar. | Hold to save or rename. | Pista del nombre de la mezcla (página de día) [E2] |
| `ax.nombre.pista.noche` | Toca dos veces para volver a la página de día. | Double-tap to go back to the day page. | Pista del nombre en la página nocturna [E2] |
| `ax.accion.guardar` | Guardar como mezcla | Save as a mix | Acción del nombre |
| `ax.accion.volver.dia` | Volver a la página de día | Back to the day page | Acción del nombre en la página nocturna [E2] |
| `ax.receta.pro` | %@ requiere Pro | %@ requires Pro | Sufijo hablado de la fila de mezcla |
| `ax.mezcla.pista` | Toca dos veces para cargarla. | Double-tap to load it. | Pista de toda fila de Mezclas |
| `ax.guardar.pro` | Guardar como mezcla, requiere Pro | Save as a mix, requires Pro | Etiqueta del ítem con la cuarta mezcla sin acceso |
| `ax.guardar.pro.pista` | Toca dos veces para ver Pro. La mezcla no cambia. | Double-tap to see Pro. The mix doesn't change. | Pista (solo de día) |
| `ax.vaciar.pista` | Pone todas las capas a cero. Se deshace cargando una mezcla. | Sets every layer to zero. Undo by loading a mix. | Pista de Vaciar |
| `ax.comprar` | Comprar %@, %@ | Buy %@, %@ | Etiqueta de Comprar; `%@` = `displayName`, `%@` = `displayPrice` (C12) |
| `ax.comprar.pista` | Un solo pago. Abre la confirmación de App Store. | One payment. Opens the App Store confirmation. | Pista |
| `ax.comprar.sin_precio` | Comprar %@ | Buy %@ | Etiqueta sin producto |
| `ax.comprar.sin_precio.valor` | precio no disponible | price unavailable | Valor sin producto; también el valor hablado del "—" |
| `ax.comprar.sin_precio.pista` | La tienda no responde. | The store isn't responding. | Pista sin producto |
| `ax.prueba.empezar` | Empezar la prueba de siete noches | Start the seven-night trial | Etiqueta de `pro.prueba.empezar` (C07) |
| `ax.prueba.empezar.pista` | No se cobra nada ni se pide tarjeta. | Nothing is charged and no card is asked. | Pista de "Empezar la prueba · 7 noches" |
| `ax.resena.pista` | Abre App Store. | Opens the App Store. | Pista de "Escribir una reseña" (C55) |
| `ax.reintentar` | No se ha podido iniciar el sonido. Reintentar | Couldn't start the sound. Try again | Etiqueta del botón de error (peldaños 1-3) |
| `ax.informe.pista` | Abre tu correo con el registro de la noche. Sin nombre ni identificadores. | Opens your mail with the night's log. No name or identifiers. | Pista de "Enviar informe" (C56) |
| `ax.autor.pista` | Abre tu correo. | Opens your mail. | Pista de "Escribir al autor" (C58) |
| `ax.atajos.pista` | Abre la app Atajos. | Opens the Shortcuts app. | Pista de "Abrir Atajos" (E6) |
| `ax.haptica.pista` | De noche nunca vibra. | Never at night. | Pista de la fila Háptica (C35) |
| `ax.accion.subir` / `ax.accion.bajar` | Subir / Bajar | Move up / Move down | Acciones de orden en Mezclas |
| `vo.entendido.pista` | Cierra esta nota | Closes this note | Pista de "Entendido" **[pendiente de E7]** |
| `vo.noche.pista` | Vuelve a la página y pasa a Noche | Returns to the page and switches to Night | Pista de "Noche" en la barra desde Mezclas **[pendiente de E7]** |

Claves de `main` que esta entrega **retira** del catálogo (E7 ejecuta; coincide con el Anexo de 10): `paywall.*` (todas), `trial.*` (todas), `mixes.*` (todas), `control.pro`, `control.save` (ahora `comun.guardar` en el menú del nombre), `control.mixes` (= `mezclas.titulo`), `common.pro`, `sound.locked`, `sound.proOnly`, `timer.locked`, `mixer.tagline`, `error.audio`, `common.close`. Claves de las revisiones 1 y 2 de esta entrega que se retiran por la reconciliación: `cab.prueba`, `cab.prueba.noche1`, `cab.prueba.empezar`, `cab.gratis`, `cab.gratis.corta`, `prueba.noche1`, `prueba.noche1.311`, `prueba.noche8`, `prueba.entendido` (→ `comun.entendido`), `prueba.manana`, `prueba.manana.tiempo`, `prueba.valor.escudo`, `prueba.valor.60` (C03, C08), `estado.sin` (→ `pagina.estado.sonando.sin`), `estado.rosa40` (→ `pagina.estado.sonando.defecto`), `estado.escucha`, `error.escucha` (C06), `estado.silencio` (→ `pagina.estado.silencio`), `mezcla.titulo.sin` (→ `mezcla.nombre.sin`), `mezcla.titulo.todoPro` (→ `pagina.estado.silencio.pro`), `mezcla.nombre.auto` (el nombre de la viva es "Esta noche"), `mezclas.tuyas` / `mezclas.casa` (→ `mezclas.seccion.*`), `mezclas.casa.lluvia*`, `mezclas.casa.rosa*`, `mezclas.casa.mar*` (C18), `mezclas.receta.marea`, `mezclas.receta.temporizador`, `mezclas.receta.escudo` (C20), `mezclas.receta.pro.1` (→ `mezclas.receta.pro`), `mezclas.estado.sonando` (→ `mezclas.sonando`), `mezclas.estado.cargada`, `mezclas.renombrar` (→ `comun.renombrar`), `mezclas.eliminar` (→ `comun.eliminar`), `mezclas.subir` / `mezclas.bajar` (→ `ax.accion.*`), `mezclas.vo.pro.*` (→ `ax.receta.pro`), `menu.guardar` (→ `mezcla.menu.guardar`), `menu.guardar.pro` (→ `mezcla.menu.guardar.pro`), `menu.renombrar`, `menu.vaciar` (→ `mezcla.menu.vaciar`), `menu.vaciar.deshacer`, `guardar.campo` (→ `mezcla.guardar.campo`), `guardar.defecto` (→ `mezclas.esta_noche`), `guardar.guardada` (→ `mezclas.guardada`), `guardar.guardada.sin`, `guardar.conservar`, `capa.art.*` (C23), `renombrar.titulo` (→ `comun.renombrar`), `common.save` / `common.cancel` (→ `comun.guardar` / `comun.cancelar`), `pro.cabecera` (→ `pro.titulo`), `pro.lanzamiento` (C02), `pro.prueba.linea`, `pro.titular` (→ `pro.pie`), `pro.con.capas` (→ `pro.incluye.texturas` + `.detalle`), `pro.con.marea` (→ `pro.incluye.marea`), `pro.con.tiempo` (C03), `pro.con.mezclas` (→ `pro.incluye.mezclas`), `pro.con.familia` (→ `pro.familia`), `pro.gratis.texto` (→ `pro.gratis.lista`), `pro.comprar.sinprecio` (→ `pro.comprar.sin_precio`), `pro.restaurar.buscando` (→ `pro.buscando`), `pro.restaurar.nada` (→ `pro.restaurar.no`), `pro.sinred` / `pro.sinred.sonando` (→ `pro.sin_tienda.silencio` / `pro.sin_tienda`), `pro.pie` con el texto de privacidad (→ `lo_que_no_hay.pie`), `pro.comprado.titulo` / `.fecha` / `.familia` (→ `pro.gracias`, `pro.ajustes.gracias`, `pro.ajustes.familia`), `pro.vo.*` (→ `ax.comprar*`), `prueba.empezar` (→ `pro.prueba.empezar`), `prueba.empezar.nota` (→ `pro.prueba.empezar.nota`), `prueba.empezando`, `prueba.empezada`, `sabemos.intro`, `sabemos.sostiene`, `sabemos.pago`, `sabemos.nodecimos`, `sabemos.n.frase` / `.sostiene` / `.pago` / `.nodecimos` (→ `sabemos.n.afirmacion` / `.cuerpo`), `sabemos.nosabemos.*` (→ `sabemos.4.*`), `sabemos.sanitario` (dentro de `sabemos.2.cuerpo`), `ajustes.noche` / `ajustes.marea` (→ `ajustes.seccion.*`), `ajustes.noche.sola*` (→ `ajustes.noche.pasar_sola*` / `.auto.*`), `ajustes.noche.hora*` (→ `madrugada.ajuste.*`), `ajustes.marea.haptica*` (→ `marea.haptica*`), `ajustes.pro` (→ `pro.ajustes.ver`), `ajustes.pro.valor.prueba`, `ajustes.pro.gracias` / `.familia` (→ `pro.ajustes.*`), `ajustes.diagnostico` (→ `diagnostico.titulo`), `ajustes.privacidad` (→ `lo_que_no_hay.pie`), `diag.titulo` / `.intro` / `.ultima*` / `.registro` / `.vacio` / `.enviar` / `.correo.*` (→ `diagnostico.*`), `error.inicio*` (→ `pagina.error.inicio*`), `error.noche` (→ `noche.estado.sin_sonido`), `error.anoche` (→ `pagina.estado.manana.error`), `vo.*` salvo las dos pendientes. Claves que se conservan: `sound.*` nombres y detalles (E2 revisa), `breath.*` (E3), `timer.*` restantes (E4), `a11y.percentFormat`, `nowplaying.*`, `app.name`.

---

## 6. Variantes

| Variante | Qué cambia en estas pantallas |
|---|---|
| **iPhone 17 Pro (393 × 852)** | Las cotas de §2. Mezclas desplaza 24 con dos propias; la hoja Pro no desplaza (con "Empezar la prueba" la columna y el pie fijo suman exactamente 808); Ajustes desplaza ≈ 516 |
| **iPhone SE (375 × 667)** | Columna de 335: la receta de "Ventilador y lluvia" a 2 líneas (fila 92). Hoja Pro: alto útil ≈ 633, pie fijo 168 / 232, la columna desplaza ≈ 111 / 175 ("gratis siempre" bajo el pliegue; el precio, Empezar y Comprar siempre a la vista). Nota "La prueba terminó": horizonte a un tercio = 222 (05); la nota + "Entendido" no caben encima → se aplica la regla de xL de §5d (nota y "Entendido" bajo el horizonte, en el hueco del renglón de estado; el horizonte no se mueve) **[a medir]**. Ajustes desplaza ≈ 690; Diagnóstico muestra ~8 eventos antes del pie fijo |
| **16e (390 × 844)** | Como el 17 Pro con 8 pt menos: sin cambios de disposición |
| **Negro (página nocturna, 03 §3.2, C40)** | Mezclas, Qué sabemos, Lo que no hay y Cómo se genera heredan la fase de la página: una tinta `texto-noche`, pasos 6-7 en Medium, estado sin versalitas, sin deslizar ni reordenar, hairlines `trazo` (§2.1). La página: cabecera `texto-noche` Medium y estática; renglón de estado, peldaños y confirmaciones en `texto-noche` Medium; `TextAction` de 64; ningún párrafo ni tip (`NightWindow`). Hojas Pro y Ajustes: `hoja` + `trazo-hoja`, sin cambio de tinta (son otra habitación y las abre el usuario; la hoja Pro, además, solo de día) |
| **Papel (día, 1.1; C32)** | 1.0 es solo oscura (`preferredColorScheme(.dark)` en la raíz). En 1.1: Mezclas, Qué sabemos, Lo que no hay y Cómo se genera sobre `papel` con `tinta` / `tinta2`, hairline `trazo-papel`, pulsado `pulsado-papel`; hojas sobre `hoja-papel`; versalitas `tinta2`; "pro" `tinta2`; el precio en `tinta`; **las hairlines de Comprar en `ocre`** (el índice de día); toggles `.tint(tinta)`. Nada más cambia. Noche no se toca |
| **ES / EN** | ES es la lengua de diseño; EN ~15 % más corto en estas pantallas (la excepción es `pro.pie`, 2 líneas en ambas). Toda cadena EN cabe en el tope de su clave. es-419: "Marrón y fogata", "iPhone" y "App Store" iguales (10 §0.3); E7 revisa "Entendido" |
| **Aumentar contraste** | `texto2 → texto2-ac`, `texto3 → texto3-ac`, `índice → índice-ac`, `trazo → trazo-ac`; `trazo-hoja → trazo-ac` por decisión de 03 §3.1 (ya no hace falta un `trazo-hoja-ac`: §9.8 cerrada en esa parte). Todo desde el asset catalog, nada en código |
| **Formas de botón** | El sistema subraya `TextAction` ("Entendido", "Restaurar compra", "Ahora no", "Escribir una reseña", "Enviar informe" en la línea 2) y `HairlineAction`; la versalita de cabecera (de día) se subraya también (es botón); las filas de Mezclas no (son filas de lista); aparecen el `TextAction` "Guardar" junto al nombre y "Más" en las filas propias (§5c). Las versalitas no se convierten en mayúsculas |
| **Escala de grises** | Todo estado se lee: "sonando ahora", "es Pro", "pro · 30" son palabras; Comprar con precio se distingue de Comprar sin precio por grosor (1,5 pt vs 0,5) y luminancia (9,84 vs 1,46 sobre `hoja`), además de la cifra en el botón; "Empezar la prueba" se distingue de Comprar por la cifra y por la hairline inferior. Capturas de control en gris de las diez pantallas en el entregable |
| **Filtro rojo de StandBy** | Ninguna de estas superficies existe fuera de la app (la hoja Pro nunca aparece en StandBy, widgets ni Live Activity: 03 §3.1 regla 4; fuera de la app una sola tinta `texto`, C61). Se comprueba igualmente que nada depende del matiz (ver fila anterior): con el modelo B de rojo, `índice` da 5,0:1 — la diferencia de grosor sigue leyéndose **[a medir con la foto calibrada del spike I0-6]** |
| **Reduce Motion** | Sin trabajo: todo es opacidad o del sistema (§5a) |
| **Reducir transparencia** | Solo afecta a las hojas del sistema; `presentationBackground(hoja)` ya es opaco |
| **Texto en negrita** | SF lo hace solo; las versalitas pasan a Semibold y siguen siendo versalitas |
| **Acceso asistido** (1.1, C39) | Mezclas y Ajustes no entran en la disposición de un botón (son de día); Noche y Madrugada son de E4 |

## 7. Háptica por evento (03 §3.8, 02 §4)

| Evento | iPhone | Condición | Anuncio VoiceOver |
|---|---|---|---|
| Cargar una mezcla desde silencio (arranca el sonido) | `.impact(.medium, 0.7)` al inicio del fundido | Como Play | "Sonando" |
| Cargar una mezcla sonando (fundido cruzado) | ninguna | — | el nombre de la mezcla |
| Guardar / "Guardar en «…»" | `.success` | Despierto, con luz | "Guardada" |
| Renombrar, Eliminar, Reordenar, Vaciar, "Entendido", "Ahora no" | ninguna (las acciones del sistema llevan la suya) | — | el resultado |
| Abrir la hoja Pro; enseñar el precio | **ninguna** | Nunca háptica de marketing | — |
| Empezar la prueba | ninguna (03 §3.8 no la lista; la prueba se oye) | — | "Prueba, quedan 7 noches" |
| Compra completada / restaurada | `.success` | Solo con la hoja Pro delante | "Gracias. Todo abierto." |
| Fallo de compra (no la cancelación) | `.error` | Solo con la hoja Pro delante | el texto del fallo |
| Pendiente, cancelación, sin tienda, restaurar sin nada | ninguna | — | el texto |
| Fin de la prueba; aparición o desaparición de la versalita | **ninguna** | — | — |
| Error de audio (todos los peldaños); Enviar informe; Escribir al autor | ninguna | — | el texto, prioridad alta |
| Toggles, listas y picker de Ajustes | la del sistema | — | el valor |

Regla de silencio (C35): la puerta de la háptica es **por fase** (`MotionGate.allows(phase) = !phase.isNight`): de noche nunca vibra; sin CoreMotion en producción 1.0; "Háptica del sistema" desactivada = nada; en segundo plano, nada. Ninguna háptica de esta entrega ocurre de noche: todas sus acciones son de día.

## 8. Lo que se queda fuera y por qué

- **Candados, cápsulas, badges, tachaduras, cuentas atrás, "✓ Activo", `checkmark.seal`, `gift`, `hourglass`** (todos en `PaywallView` de `main`): 00 §7.1 y 03 §6. Pro es una frase. "chip" no es un componente (C64): el estado es `StateWord` o fila con estado.
- **Icono de engranaje** y cualquier icono en Mezclas, Pro, Qué sabemos, Ajustes: las palabras son los iconos (03 §3.6). Chevrones solo donde el sistema los pone: filas que empujan.
- **`EditButton` en Mezclas**: reordenar es pulsación larga y arrastre (`onMove`) o "Subir" / "Bajar"; renombrar y eliminar ya están en deslizar y en el menú. La barra de Mezclas queda con el atrás del sistema y nada más.
- **"Noches"** como nombre de las mezclas; **"Lluvia fina", "Cama rosa", "Mar lento", "Noche de fuego"** y cualquier textura + adjetivo como mezcla de la casa (C17, C18); **"Foco" / "Descenso" / "Sueño profundo" / "Avión"** (03 §1.2). Las cuatro de la casa describen lo que llevan; los nombres por problema esperan a 1.1 con dato.
- **Escucha de 30 s de una capa Pro** (C06): pasa a 1.1 y, cuando llegue, no abrirá hoja sola. En 1.0 tocar una capa Pro de día abre la hoja; de noche, nada.
- **La prueba que arranca al primer Play** (`startTrialIfNeeded()` en `play()`, C07): la prueba empieza con "Empezar la prueba · 7 noches". **La variante 3.1.1 con non-consumable a 0 €**: innecesaria; la prueba es local, en Keychain, sin StoreKit.
- **La línea de la mañana** ("Anoche probaste Océano", C08): de noche no se vende y no hay recordatorio; el pie "Sin rastreo" lo promete.
- **Precio de lanzamiento, línea "Precio de lanzamiento hasta el…", compuerta `AccessPolicy.listPrice`** (C02): un solo `displayPrice`; una oferta posterior se haría con StoreKit (offer code), no con copy.
- **"Temporizador sin límite y Escudo" en la lista Pro; "más de 60 min es Pro"; "Anoche quisiste el Escudo"** (C03, C11): el temporizador es entero libre y se llama Manto.
- **"Las siete capas Pro" / "Ventilador y océano" como conteo** (C04): "Todas las texturas", nombradas.
- **Reproducir desde la lista sin salir de ella** (Dial, Disco por fila): un segundo botón por fila y un icono; cargar y volver a la página enseña el horizonte, que es la prueba de que suena.
- **Ocultar / restaurar las mezclas de la casa** (`mezclas.casa.restaurar` de 10 queda sin uso en 08): cuatro filas no estorban y "lo que no hay" también es decisión; si el dueño lo pide, es un `swipeAction` "Ocultar" y la fila terciaria de 10.
- **"Guardada sin {capa} · Conservar {capa}"** (C23): guardar conserva la capa Pro a su nivel sin preguntar; la mezcla vuelve entera al comprar. Las claves siguen en 10 §5e.9 y 03 §5 #12 (§9.19).
- **"Deshacer" tras Vaciar**: se deshace cargando una mezcla (`ax.vaciar.pista`, 10); un `TextAction` y una cadena menos en el renglón de estado.
- **Hoja propia "Guardar como mezcla" con `TextField .plain`**: la alerta del sistema con campo hace lo mismo (igual que Renombrar), sin geometría de teclado que medir.
- **"¿Qué es Pro?", "¿seguro que quieres comprar?", botón Cerrar pintado**: el gesto y "Ahora no" cierran; la pregunta ya está respondida arriba.
- **La versalita "una vez" repetida**: "Una vez." se dice una sola vez, bajo la cifra (03 §1.3); el titular dice "un solo pago".
- **"Borrar el registro"**: el registro rota solo y no contiene nada del usuario; el botón solo podía destruir la prueba que se quiere enviar.
- **Adjunto `sleepnoise-motor.txt`, horas de reloj con fecha, `portName`, nombres de mezcla en el registro** (C56): el anillo es acotado y va en el cuerpo del correo.
- **Espejo de `MixStore` en iCloud (`NSUbiquitousKeyValueStore`)** (C09): 1.1, Pro, activo por defecto con fila en Ajustes; en 1.0 el formato v2 y el App Group lo dejan listo.
- **Notificaciones de prueba, correos, descuentos de retención, `requestReview`, fila "Valorar"** (C55): nunca en 1.0; la única petición de reseña es el enlace del estado comprado.
- **Hoja de prueba al abrir** (`PaywallView.trialStatus` y la tarjeta de `main`): la prueba es texto en la cabecera.
- **Párrafo de bienvenida la primera noche** (C07, 10 §5e.3): no hay nada que explicar antes de la primera acción Pro; lo gratis lo enumera la hoja Pro.
- **Spinners**: texto ("Comprando…", "Buscando…").
- **Rojo de error**: 03 §3.1; el único rojo es "Eliminar" del sistema.
- **Vigilante del motor con timer propio**: 03 §3.7 (10 min bloqueado sin actividad periódica); el motor se comprueba en los hitos que ya existen; si se quiere un vigilante, spike I0-9.
- **Telemetría, informe automático, "crash reporting" de terceros**: el registro solo sale por correo y por la mano del usuario.
- **Duración de Madrugada, "Debajo de otro audio", iCloud, guía AirPods, Novedades, apariencia** en Ajustes (C05, C44, C09, C58, C32): receta fija / 1.1.
- **Entradas de Qué sabemos con diagnóstico por nombre** (C54): la población se nombra por el criterio de selección parafraseado; bebés, acúfenos y TDAH no aparecen ni por nombre ni por función en 1.0.

## 9. Preguntas abiertas (dueño, director, spikes)

**Cerradas por la reconciliación** (se dejan numeradas para no romper referencias):

- **2** ("Las siete capas Pro" vs "Ventilador y océano") → **cerrada por C04**: "Todas las texturas" con la lista nombrada, sin cifra.
- **9** (spike Tier 0 para el non-consumable a 0 €) → **cerrada por C07**: la prueba es local, en Keychain, sin StoreKit; no hay variante 3.1.1 ni spike.
- **10** (contador de sesiones y espejo iCloud) → **cerrada por C09**: sin sincronización en 1.0, formato v2 + App Group; el contador de sesiones gratuitas se deriva del anillo de Diagnóstico (C56) y es cambio de código (§9.5), no spike.
- **11** (campaña de lanzamiento y compuerta `listPrice`) → **cerrada por C02**: sin precio de lanzamiento; ninguna cifra escrita a mano en la build.
- **12** (guía "Al acostarte") → **cerrada por C43**: una página de texto de E6 (09) con las cadenas `ajustes.acostarte.*` de 10; E5 conserva la fila y el subtítulo.
- **8, en parte** → `trazo-hoja-ac` **cerrada por 03 §3.1** (`trazo-ac` por decisión); hairlines de Comprar 1,5 pt **cerrada por 03 §4.6 consolidado**; toggles con `.tint(texto)` y "dos acentos encendidos en Ajustes" **cerradas por 03 §4.12**. Sigue abierto lo que se lista en 8.
- **13, en parte** → la hoja Pro tiene "Ahora no" (`TextAction`, 03 §4.9 y 10 §5e.1): toque simple que la cierra. Sigue abierto para Ajustes.

**Abiertas:**

1. **Entrada a Ajustes** (director/E2): E5 la pone como última fila de Mezclas (única entrada, sin icono, `texto2`, a 32 de aire). Alternativa: ítem "Ajustes…" en el `contextMenu` del nombre; se descarta porque el menú del nombre es de día y de la mezcla (guardar, renombrar, vaciar: P10), y un ítem "Ajustes" ahí mezclaría dos preguntas; además el menú no existe en página nocturna. ¿Se acepta la fila?
3. **"Noches" en la versalita** (dueño/E7): el fin de la prueba sigue siendo `start + 7 × 86 400 s` desde el toque en "Empezar la prueba" (evaluado por sesión), pero **la cifra que se enseña es de calendario**: n = noches locales entre el inicio del día de hoy y el inicio del día del fin, suelo 1 → "última noche". Así quien empieza a las 23:00 lee "quedan 6 noches" toda la segunda noche. Cambio en `TrialClock.daysRemaining` (§9.5). ¿Se acepta o se prefiere la fecha ("prueba · hasta el {día de la semana}")?
4. **Mezcla de primer uso** (E2/ingeniería): `defaultLevels()` pasa de rosa 65 a la receta de 05 §2.11 (Lluvia 30 · Rosa 50). Cambio de una línea; confirmar que no rompe `mixer.silent` (→ `pagina.estado.silencio`).
5. **Código que cambia** (ingeniería, sin spike): `freeSavedMixLimit` 1 → 3; `freeTimerMinutes` desaparece y `maxTimerMinutes = 360` queda como tope de Hasta dormirme (C03, E4); `.wind` en `SoundID` y en la rama libre de `soundIsIncluded` (C04); `startTrialIfNeeded()` sale de `play()` y nace `startTrial()` llamado desde la hoja Pro; `TrialClock` de `UserDefaults` a Keychain, con el comentario sustituido por la razón de C07; `PurchaseNotice` gana `.storeUnavailable` (hoy `product == nil` se reporta como `.failed`) con dos textos por `isPlaying`, y `.unverified` con su texto; `PurchaseManager.refresh()` en `scenePhase == .active` y en `onAppear` de la hoja; `restore()` con `withTimeout(10 s)` que devuelve `.storeUnavailable`; `MixerModel.audioError` pasa a enumerado con contador de fallos consecutivos; `SavedMix` gana `version: 2` (ya guarda pares id + nivel: `levels: [MixLevel]`; **no** gana `tideMinutes` ni `timerMinutes`, C20) y `MixStore` escribe en el App Group (C09); nombre por defecto "Esta noche" en lugar de `mixes.defaultNameFormat`; `TrialClock.daysRemaining` por calendario (§9.3); contador de sesiones sin acceso completo derivado del anillo de Diagnóstico, a cero al empezar la prueba; **rampas por capa**: `EngineCommand` gana `gainRampSamples: Int32` (−1 = τ 20 ms actual); `RenderState.processStereo` interpola `smoothed` → `gains` linealmente en ese número de muestras con la misma `FadeCurve` de la envolvente; `SleepAudioEngine.updateGains(_ gains:, ramp seconds: TimeInterval = 0)`; lo usan la carga de mezcla (1,5 s) y la compra o la prueba que se oyen (0,8 s); Vaciar no lo necesita (`engine.stop(fadeOut: 1.5)`); `defaultFadeIn` 1,5 → 0,8 s para el reinicio tras caída; el reinicio del peldaño 4 dentro de `beginBackgroundTask`; comprobación de `engine.isRunning` en los hitos existentes; anillo de Diagnóstico con tiempos relativos desde Play, dos sesiones, excluido de iCloud y del App Group, y la hora de reloj del último corte guardada aparte sin fecha para `pagina.estado.manana.error`; `showPaywall` se consume sin cola en `NightWindow` (C08); `endPlayback(engineAction:canDowngrade:)` no toca `SavedMix` (C23).
6. **n de Stanchina 2005, financiación de Zaccaro 2018 y Tsai 2015, cita de `que_sabemos.en_vela`** (E7/investigación): 10 escribe "cuatro voluntarios sanos" (la tabla 5.1 del informe decía 5): E7 lo verifica contra el artículo antes de compilar; la financiación no se cita hasta estar verificada (10 §5e.11); `que_sabemos.en_vela` no se compila sin cita verificada (control de estímulos). **Condición de cierre, no pregunta.**
7. **Nota de "La prueba terminó" en una vuelta de Noche** (E2): si la primera apertura de día tras el fin es una vuelta de Noche (página nocturna) a las 08:30, ¿se muestra la nota (es de día) o espera a la página de día? Propuesta de E5: espera a la página de día (tocar el nombre o la siguiente apertura), porque la página nocturna es "una tinta y nada que leer". Lo mismo para `prueba.ultima`.
8. **Tokens y reglas que E1 debe alinear en 03 / 04**: 03 §4.6 y 04 §2.6 dicen "deshabilitado: texto `texto3`" mientras 03 §3.1 restringe `texto3` a texto ≥ 18 pt: esta entrega (y 10 §5e.10) sigue §3.1 (`texto2`) y pide corregir §4.6 y 04 §2.6; 04 §2.0.1 y §2.7 aún dan al Toggle `.tint(Ink.index)` y `AccentColor` mientras 03 §4.12 consolidado fija `.tint(texto)`: 08 sigue 03; 03 §5 #14 escribe "Empezar la prueba" y "Comprar" "entre hairlines de índice" mientras 03 §4.6 / 04 §2.6 reservan el acento al botón que cuesta dinero: 08 pone `trazo-hoja` sobre "Empezar la prueba" y la `índice` de Comprar debajo (2.3); 03 §3.1 regla 3 ("índice solo bajo el dedo") y §3.2 ("página nocturna: `índice-noche`") no dicen lo mismo del horizonte sonando en página nocturna: E1/E2 reconcilian; nombre del tinte "sin tinte" de las acciones de deslizar en 17/18 (`.tint(texto2)` en "Renombrar" o aceptar el gris del sistema).
13. **Ajustes sin cierre sin gesto** (director): 03 §4.10 fija "sin botón Cerrar"; en iOS 17/18 una hoja `.large` no tiene toque simple que la cierre para quien no usa gestos ni tecnología de asistencia. La hoja Pro ya tiene "Ahora no"; ¿Ajustes acepta el gesto, gana un "Listo" del sistema, o pasa a pantalla empujada? E5 recomienda aceptarlo en 1.0 y verificar el cierre del sistema en iOS 26.
14. **Nota bajo el horizonte desde xL y en SE** (E2): la regla de §5d evita mover el horizonte; E2 confirma que el hueco del renglón de estado admite 3-8 líneas en esos tramos y que la nota de 05 (196-256) admite el `TextAction` "Entendido" como control separado (05 la dibuja como un bloque-botón con "Entendido" solo como acción de VoiceOver; 03 §4.9 nombra "Entendido" como `TextAction`).
15. **Suelo de 13 pt en los pasos 7, 8 y 9 en xS-M** (E1): fijarlo en `TypeStep` (04 §2.0.2) para todas las entregas.
16. **Barra inferior "en Mezclas"** (E1, 03 §4.11): hueco izquierdo vacío; "Noche" → pop sin animación + Noche.
17. **[spike I0-9, opcional]** Vigilante del motor con medición de batería (10 min bloqueado), solo si el director lo quiere; hasta entonces, comprobación en hitos.
18. **Esquema de URL `sleepnoise://sabemos`** (E6): lo declara 09 en `CFBundleURLTypes`; sin él, la entrada desde la ficha se retira.
19. **Pendiente de E7 y tensiones de coherencia** (nuevo tras la reconciliación):
    - Cadenas que esta entrega necesita y 10 no tiene (provisionales en §5e, marcadas **[pendiente de E7]**): `guardar.titulo` "Guardar como mezcla"; `menu.guardar.en` "Guardar en «%@»"; `mezclas.receta.pro.2` / `.n` ("%@ y %@ son Pro"); `mezclas.mas` "Más"; `pro.pendiente.boton` "Pendiente"; `pagina.estado.manana.error.inicio` "Anoche el sonido no pudo iniciarse."; `diag.motor`, `diag.motor.valor`, `diag.puerto.*`, `diag.sesion.actual` / `.anterior`, `diag.ev.*`, `diag.ev.detalle.*`; `vo.entendido.pista` "Cierra esta nota"; `vo.noche.pista` "Vuelve a la página y pasa a Noche". E7 las añade a 10 §5e o las sustituye.
    - 03 §5 #15 sigue diciendo "párrafo de una vez con 'un solo pago'" para la noche 1; 10 §5e.3 retira `prueba.bienvenida` por C07 ("la prueba no arranca la primera noche ni con Play: no hay párrafo de bienvenida"). 08 sigue a 10 y a C07 (2.4: sin párrafo la primera noche); E1 alinea 03 §5 #15.
    - 03 §5 #12 y 10 §5e.9 conservan "Guardada sin trueno · Conservar el trueno" (`mezclas.guardada.sin`, `mezclas.conservar`); C23 dice "guardar conserva el nivel sin diálogo". 08 aplica C23 (2.2) y deja esas claves sin uso; E1/E7 deciden si se retiran de 03 y 10.
    - 10 §2.7 dibuja "Esta noche" como primera fila de "tuyas" en Mezclas (`ax.esta_noche`, `ax.esta_noche.pista`); 03 §5 #12 y #16 sitúan la mezcla viva en la página y la reconciliación §3 dice que no es una pantalla. 08 no la dibuja en Mezclas (la viva vive en la página y se guarda desde su nombre); esas dos claves quedan sin uso salvo que el director prefiera la fila.
    - 10 §5e.2 mantiene `pagina.capas.y` / `mezcla.nombre.auto.*` como nombre automático de la página ("Rosa y lluvia"); 05 §2.1, 03 §5 #16 y la reconciliación §3 nombran la mezcla viva "Esta noche". 08 usa "Esta noche" (E2 decide el nombre de la página; 08 solo lo cita).
    - 10 §5e.9 tiene `mezclas.casa.restaurar` (las de la casa se pueden borrar); 08 no las deja borrar (§8). Si el director prefiere borrables, se añade el `swipeAction` y la fila terciaria sin tocar nada más.
    - 03 §5 #17 sigue nombrando la superficie "Qué sabemos y qué no"; el título de pantalla es "Qué sabemos" (reconciliación §3, 10 §5e.11).
    - C25 dice "cuatro estados" y C50 "seis" para la Live Activity: no toca a 08 (lo anota 09).

## 10. Autoevaluación

**Puerta de formato (03 §8.3.1).** Las cinco tablas están completas: 5a movimiento con señal (M1-M21, M8 y M14 retiradas), 5b VoiceOver por control (todos los controles de las diez pantallas, con clave `ax.*` de 10 §5e.16 para cada etiqueta y pista que no es visible), 5c gesto → alternativa → Control por botón → teclado (nueve filas; ningún gesto propio), 5d Dynamic Type por los cuatro tramos y las diez pantallas más el renglón de error, 5e catálogo ES/EN por clave con contexto y tope (≈ 150 claves, todas de 10 §5e salvo las 14 marcadas pendientes de E7 en §9.19). Todas las medidas en pt y toda cota del eje y múltiplo de 4; un único juego de hex (los de 03 §3.1, citados por nombre de token; el único hex escrito es `trazo-ac` #3A3836 en §9.8). Maqueta y texto coinciden: cada wireframe de §2 lleva su tabla de capas con las mismas cotas; las cadenas de los wireframes son las de §5e; el precio dibujado es `displayPrice`; los ejemplos son de 1.0 con once texturas; la cabecera de la página usa las cotas de 05 §2.1.

**Las doce pruebas del brief (00 §4).**

| P | Prueba | Resultado en esta entrega |
|---|---|---|
| P1 | Diseñado primero a oscuras | Lo que puede verse de noche aquí es la cabecera (versalita estática en `texto-noche`), el renglón de estado (peldaños, "Guardada") y Mezclas en una tinta; todo lo demás es de día (venta, prueba, nota, tip, guardar, renombrar, vaciar, correo). Nada que tocar por error enseña un precio: la hoja Pro no se abre entre las 21:00 y las 07:00 por ninguna vía |
| P2 | Un gesto para lo de medio dormido | No aplica a estas pantallas; ninguna se abre sola de noche ni se interpone; desde Mezclas, "Noche" a un toque |
| P3 | Negro real, un acento | Mezclas, Qué sabemos, Lo que no hay, Cómo se genera: `negro`; cero rellenos. Conteo de colores no gris por pantalla: Pro = 1 (las dos hairlines de Comprar, solo con precio; el horizonte de la página está congelado a hairline debajo); Ajustes = 0 (toggles y picker con `.tint(texto)`, 03 §4.12); Mezclas, Qué sabemos, Lo que no hay, Cómo se genera, Diagnóstico = 0 |
| P4 | Lo que se mueve tiene causa | §5a: M1, M2, M13 son audio; M21 es la hoja; el resto, dedo o estado; nada infinito; ningún `numericText` |
| P5 | Una familia, ≤ 6 estilos (nueve pasos; 17 Medium cuenta, C67) | SF Pro; Mezclas 3, 5, 7, 9 + 6 (Ajustes) + barra 17 Medium = 6; Pro 1, 2, 5, 6, 7, 8, 9 = 7 → el detalle de texturas (paso 7) y "Una vez." / pie (paso 8) comparten `texto2` 13-15/18-20 y se componen como un estilo (10 §2.8: "E5 confirma ≤ 6"): **6**; Qué sabemos, Cómo se genera, Lo que no hay 3, 5, 6, 8 = 4; Ajustes 3, 5, 7, 8, 9 = 5; Diagnóstico 3, 6, 7, 9 + 5 (botón) = 5; página con cabecera: 2, 5, 6, 7, 9 + barra = 6 (tope alcanzado: E5 no puede añadir ningún estilo más a la página) |
| P6 | Aire antes que cajas | Cero rectángulos rellenos o con borde propios en las diez pantallas (las alertas son del sistema; el `grafito` de la fila pulsada dura 200 ms) |
| P7 | Estado por forma, no por color | §6 escala de grises: "sonando ahora", "es Pro", "pro · 30" son palabras; Comprar con precio se distingue por grosor y por la cifra; el toggle *on* por la posición del pomo |
| P8 | 44 / 64 | Filas 56/72/92; `HairlineAction` 64; `TextAction` 44 (64 de noche); versalita de cabecera como botón de 44 de día (52-96, 05); Restaurar y Ahora no en la misma fila con ≥ 24 entre objetivos; nada en la esquina superior |
| P9 | Nada bloquea el sonido | Recorrido del día 8 (§4.4): blanco, rosa, marrón, lluvia, viento, todo el temporizador y tres mezclas sin ver una venta; la hoja Pro solo por toque en una palabra, de día; candados: 0; la palabra "Pro" visible en Mezclas con las cuatro de la casa: 2 ("océano es Pro", "hoguera es Pro"); ninguna capa suena para venderse (C06) |
| P10 | Una pantalla, una pregunta | §1: diez pantallas, diez preguntas; Ajustes no contiene ajustes de sonido ni precio escrito a mano; Mezclas lleva la fila "Ajustes" como salida separada por aire; el recibo no es una pantalla |
| P11 | Lo técnico, debajo | El registro del motor está a dos niveles (Mezclas › Ajustes › Diagnóstico) y en `texto2`; la receta de una mezcla es humana ("lluvia 55 · rosa 20"); el registro habla en el idioma del usuario y en tiempo desde Play |
| P12 | Sistema donde existe | Propios: `HairlineAction`, `TextAction`, `StateWord`, `EditorialRow` (de 03 §4). Del sistema: `List`, `onMove`, `swipeActions`, `contextMenu`, `confirmationDialog`, `alert` con `TextField` (Guardar y Renombrar), `sheet` con detents, `Toggle`, `AVRoutePickerView`, compositor de correo, hoja de compra de StoreKit. Cero `glassEffect` propio (C66) |

**Listas negras.** Visual (00 §7.1): ninguna tarjeta, resplandor, ilustración, rejilla, racha, candado, badge, precio tachado, cuenta atrás, SF Rounded, Light, blanco puro, vidrio en contenido, selector de apariencia, asa falsa, Cerrar pintado, bienvenida, petición de valoración. Copy (10 §0.4-§0.5): grep de "insomnio", "ansiedad", "mejora", "terapia", "clínic", "IA", "vitalicio", "timer", "mix", "relajante", "mágico", "unlock", "escudo", "lanzamiento", "lluvia fina", "cama rosa", "mar lento", "chip", "envolvente", "desbloque", "tu instrumento", "siesta", "ranura" sobre §5e devuelve cero (la única "mix" es la clave inglesa `Mixes`, que es la traducción pedida; "Deep" no aparece en E5).

**Desempate.** Lo que esta entrega quita respecto a `main`: la pantalla de paywall con cuatro beneficios ilustrados, dos tarjetas de prueba, un badge de activo, el estado vacío con icono, el botón Cerrar en dos pantallas, la fecha de creación en cada mezcla, el límite de una mezcla, la cadena de error única, el aviso "Pro no está disponible ahora", la prueba que arranca sola. Lo que quita respecto a su revisión 2 (tras la reconciliación): el precio de lanzamiento y su compuerta, la escucha de 30 s y su peldaño, la línea de la mañana, el párrafo de la noche 1, la variante 3.1.1, "Conservar {capa}", "Deshacer", la hoja Guardar, las piezas de Marea y temporizador en la receta, las etiquetas intermedias de Qué sabemos, el adjunto del informe, "Borrar el registro", el índice de los toggles. Lo que añade: "Empezar la prueba · 7 noches" como decisión en la hoja, "Ahora no", "Escribir una reseña", la fila "Salida", "Mantener encendida", "Escribir al autor", dos páginas de confianza (Lo que no hay, Cómo se genera), la cuarta mezcla de la casa. Sin perder ninguna función de la noche.

## 11. Respuesta al jurado

Todo lo bloqueante y mayor se aplicó en la revisión 2; de lo menor, todo salvo lo que sigue. Donde dos jurados pedían cosas contrarias, decidió 03 y, si 03 callaba, el desempate del brief (quitar más sin perder función). Una línea por hallazgo rechazado o aplicado de otro modo. **Las filas marcadas "⟶ Cnn" han sido superadas por la reconciliación (§12): la decisión vigente es la de la ficha citada, no la de esta tabla.**

| Jurado · hallazgo | Decisión | Razón escrita |
|---|---|---|
| Honestidad · §9.7 "se acepta la excepción del párrafo de noche 1 en fase nocturna" | **Rechazado** ⟶ C07 | Contradecía 03 §4.12 (ningún texto de sistema de noche). Con C07 el párrafo de la noche 1 ya no existe: la prueba no arranca sola, así que no hay nada que explicar antes de la primera acción Pro (§2.4) |
| Primera impresión · retirar `prueba.noche1`, `prueba.noche8`, `prueba.entendido` y M7; mantener `prueba.noche7` | **Aplicado en parte** ⟶ C07 | `prueba.noche1` se retira (C07); la nota de la prueba terminada se queda como `prueba.terminada` + `comun.entendido` (03 §5 #15, 10 §5e.3), solo de día y sin mover el horizonte; la última noche lleva `prueba.ultima` en el renglón de estado (10) |
| Primera impresión · quitar `pro.lanzamiento` y la reserva de 36 pt; titular a y 128 fuera de prueba | **Aplicado** ⟶ C02 | Sin precio de lanzamiento. El hueco bajo la cifra lo ocupa ahora "Una vez." en todo estado: nada cambia de posición (03 §3.7) |
| Primera impresión · "con pro" como párrafo de 3 líneas | **Rechazado** | 03 §5 #14 define la lista "Con Pro" (Todas las texturas · Marea · mezclas sin límite · En familia). Se queda la lista; sin hairlines internas; filas 44 en paso 6 (03 §3.4: el paywall es paso 6) |
| Primera impresión · Ajustes como pantalla empujada en la pila de Mezclas; Qué sabemos y Diagnóstico detrás | **Rechazado** | 03 §3.1 pone Ajustes sobre `hoja` ("otra habitación") y 03 §4.10 fija las hojas `.large`; cambiar la hoja por un empuje es decisión de E1/director, no de E5 (§9.13 la eleva junto con el cierre sin gesto). Se aplica la alternativa de la lente: la fila "Ajustes" en Mezclas separada por 32 y en `texto2`, y §9.1 razona por qué no va en el `contextMenu` |
| Primera impresión · "Cama rosa" → "Solo rosa" | **Sin objeto** ⟶ C18 | "Cama rosa" se retira (una segunda mezcla sobre rosa no añade nada a "Rosa y lluvia"); las cuatro de la casa son las de C18 |
| 3 de la mañana · quitar "Vaciar" y `menu.vaciar` | **Rechazado** | 03 §5 #13 lista "Vaciar" en el `contextMenu` del nombre. Se aplica la alternativa de la lente: el menú no existe en página nocturna; se deshace cargando una mezcla (10 `ax.vaciar.pista`) |
| 3 de la mañana · "Al acostarte" como `Link` directo a Atajos; retirar `acostarte.*` | **Aplicado de otro modo** ⟶ C43 | "Al acostarte" es una página de texto de E6 (una sola, C43) con las cadenas `ajustes.acostarte.*` de 10; la fila y su subtítulo se quedan aquí |
| 3 de la mañana · `prueba.manana.sinprecio` como respaldo sin `product` | **Sin objeto** ⟶ C08 | La línea de la mañana no existe: de noche no se vende y no hay recordatorio |
| Honestidad · `prueba.manana.escudo` "…Pro, {precio} una vez." | **Sin objeto** ⟶ C03, C08 | El temporizador es entero libre y no hay línea de la mañana |
| 3 de la mañana · fila "Mezclas" en la barra con `.isSelected` y toque sin efecto | Aplicado de otro modo | En su propia pantalla el hueco izquierdo de la barra queda vacío (una palabra que no hace nada se quita); "Noche" desde Mezclas → pop + Noche; anotado para 03 §4.11 en §9.16 |
| Restricción tipográfica · "entre 22:00 y 07:00 Mezclas / la página pasan a `texto-noche`" como fase horaria | Aplicado con la definición de 03 ⟶ C40 | La página nocturna es un estado por procedencia (al volver de Noche; dura la sesión; sin salida por reloj); Mezclas y Qué sabemos heredan **esa** fase. La hora sola rige `NightWindow` (21:00–07:00): tips, párrafos, venta y el botón de la cabecera |
| Restricción tipográfica · variante nocturna del párrafo de noche 1 y de "Entendido" | Sin objeto | Ningún párrafo aparece en `NightWindow` ni en página nocturna. La regla transversal (todo texto de E5 sobre la página nocturna en `texto-noche` Medium, `TextAction` 64) cubre peldaños y confirmaciones |
| Restricción tipográfica · "El horizonte nace en 2 pt `texto-noche`" a las 23:08 | Sin objeto | La primera apertura a las 23:08 es página de día (03 §3.2): el horizonte nace en `índice`. La contradicción entre 03 §3.1 regla 3 y §3.2 para la página nocturna sigue elevada a E1/E2 en §9.8 |
| Restricción tipográfica · chevron a `texto3` en Mezclas nocturna | Sin objeto | Mezclas no tiene chevron (la fila "Ajustes" abre una hoja) |
| Honestidad · `pro.pie` / `ajustes.privacidad` opción B ("Sin servidores nuestros") | **Superada** ⟶ C09 | El pie es "Sin suscripción. Sin cuenta. Sin rastreo." (`lo_que_no_hay.pie`); "Sin servidor" no se usa porque deja de ser cierto en 1.1 |
| Honestidad · sustituir la cifra por la fecha ("prueba · hasta el {día}") | Alternativa no elegida | Se aplica la primera opción de la lente (noches de calendario locales); la fecha queda como alternativa en §9.3 |
| Plataforma · rotular el wireframe de Mezclas como 1.1 | **Sin objeto** ⟶ C19 | Once texturas en 1.0: el wireframe es de 1.0 con "Ventilador y lluvia" (ventilador es Pro) y las cuatro de la casa |
| Plataforma · `AccessPolicy.listPriceAfterLaunch` como precio escrito a mano aceptado por escrito | **Sin objeto** ⟶ C02 | No hay precio de lanzamiento ni compuerta: ninguna cifra escrita a mano |
| Restricción tipográfica / honestidad · Comprar sin precio en `texto3` (03 §4.6) frente a `texto2` (03 §3.1) | Aplicado `texto2` | 03 §4.6 / 04 §2.6 y 03 §3.1 se contradicen; se sigue §3.1 (tokens), 10 §5e.10 coincide, y §9.8 pide a E1 corregir §4.6 y 04 §2.6. Las hairlines de Comprar ya son 1,5 pt en 03 consolidado |

## 12. Reconciliación aplicada (16-11-2026)

Fuente: `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`. Una línea por delta que nombra a 08 (por número, por nombre, o por "todas las specs" / "FUNCIONES" / "plan") y por regla transversal de §1, §3 y §4 aplicada a todo el paquete, más la pasada de coherencia contra 10, 03 §3-§4, 04, 05 y 07. Ningún delta se ha rechazado: ninguno contradice el código del hilo de audio ni es materialmente imposible.

**Deltas aplicados**

- C02 → eliminadas la clave `pro.lanzamiento`, la línea "Precio de lanzamiento hasta el…", el estado "campaña de lanzamiento", la compuerta `AccessPolicy.listPrice` y "19,99 €" en §4.5; la hoja muestra `product.displayPrice` una vez (2.3); §8, §9.11 (cerrada), §11.
- C03 → eliminada la fila "Temporizador sin límite y Escudo" de la lista de la hoja Pro (`pro.con.tiempo`); eliminados "más de 60 min es Pro", "el temporizador largo" (`prueba.noche8`, nota), `prueba.manana.tiempo`, `prueba.valor.*`, "un valor Pro del temporizador" como entrada a la hoja; `pro.gratis.lista` dice "todo el temporizador"; `freeTimerMinutes` desaparece en §9.5.
- C04 → hoja Pro: "Todas las texturas" con la lista nombrada debajo, sin número (`pro.incluye.texturas` + `.detalle`); "gratis siempre" con viento (`pro.gratis.lista`); cinco libres / seis Pro en la cabecera; `.wind` en §9.5; §9.2 cerrada.
- C05 → "Madrugada nunca abre la hoja Pro." en la cabecera, 2.3 y §4; Ajustes sin duración de Madrugada; "Mostrar la hora en Madrugada" opt-in con la nota de E4.
- C06 → eliminada toda "escucha 30 s": §1 (fila 14 y regla P9), 2.3 (entrada por fila "pro" sin cuenta atrás), 2.4, 4.4 (pasos 6-7), 4.5, M14, peldaño 6 y `error.escucha`, `estado.escucha`, "Conservar" con nivel "si se arrastró durante los 30 s", §8, §10 P9; "Toque en capa Pro → hoja Pro" (de día).
- C07 → "Inicio de la prueba: botón 'Empezar la prueba · 7 noches' en la hoja Pro" (2.3, `pro.prueba.empezar` como `HairlineAction` primaria mientras la prueba no se ha usado, `startTrial()` fuera de `play()`); eliminado "al primer Play" / `startTrialIfNeeded` en 2.4, 2.5, 4.6, §9; estado en Keychain (`TrialClock`, §9.5); versalita "prueba · quedan n noches" solo desde que empieza; eliminada la variante 3.1.1 (non-consumable a 0 €) y el spike Tier 0 (§9.9 cerrada); sin párrafo la primera noche (10 §5e.3); la capa que abrió la hoja entra con fundido de 800 ms al empezar (M13).
- C08 → "Entre 21:00 y 07:00 el toque en capa Pro no abre hoja; la fila muestra 'pro' y no pasa nada más." en la cabecera, 2.4 y 4.4; eliminada la "venta pospuesta a la mañana", la frase de la mañana (`prueba.manana*`), `showPaywall` se consume sin cola (§9.5); la hoja Pro no se abre de noche por ninguna vía (ni Ajustes ni la cuarta mezcla).
- C09 → formato v2 descrito en 2.1 y §9.5 (`[{id, level}]` + `version: 2`; `SavedMix` no gana `tideMinutes` ni `timerMinutes`); "sin sincronización en 1.0" (4.5, §8, §9.10 cerrada); App Group en 1.0; pie "Sin suscripción. Sin cuenta. Sin rastreo." (`lo_que_no_hay.pie`) en la hoja Pro y en Ajustes, en lugar de "Nada sale de tu iPhone".
- C10 → `product.displayName` para el nombre del producto; `app.name` para "SleepNoise" en Ajustes, asunto del correo y cabecera "sobre"; Siri con `${applicationName}` en 2.1.
- C11 → "Escudo" no aparece en ningún sitio (las cadenas que lo llevaban se retiran por C03/C20); "Manto" solo se cita por 07.
- C12 → título de hoja = `product.displayName` (`pro.titulo`); "Una vez." (`pro.una_vez`) bajo la cifra; titular `pro.pie`; lista "Con Pro" que termina en "En familia" (`pro.familia`); estado comprado = recibo (2.3, 03 §5 #33); sin "Desbloquear" ni nombre grabado (ya no los había: se confirma); `pro.comprar` "Comprar · {displayPrice}".
- C14 → "Descenso" como fase sustituido por "página de día" en todo el documento; la fase interna es `.day` / `.night`.
- C15 → "Marea respiratoria" → "Marea" (`pro.incluye.marea`); "Small hours" en EN.
- C17 / C18 → lista de mezclas de la casa: "Rosa y lluvia" (libre), "Mar y viento" (Pro), "Marrón y hoguera" (Pro), "Pared" (libre); recetas de 10 §2.7; "no cambian el temporizador; carga recortada si incluyen Pro, nunca hoja" (2.1, §3, 4.1); "Mar lento · sin Océano" → "Mar y viento · sin Océano" (2.4, 4.4, 4.5); Siri "Pon Rosa y lluvia en ${applicationName}"; wireframe de Mezclas con cuatro de la casa y desplazamiento recalculado.
- C19 → once texturas en 1.0: eliminados "1.0 (seis capas)" / "1.1 (once)" y "Las siete capas Pro"; las once en los ejemplos y en `pro.incluye.texturas.detalle`.
- C20 → receta = solo niveles: retiradas `mezclas.receta.marea`, `.temporizador`, `.escudo`; "Mar lento · Marea 15 min" desaparece; §9.5 sin `tideMinutes` / `timerMinutes`.
- C21 / C52 → citados en 2.5 (pulsación larga = `Slider`; arrastre horizontal = nivel).
- C23 → "pro · N" con nivel conservado; la degradación nunca escribe (2.4, 4.4 paso 3, §9.5); guardar conserva la capa Pro a su nivel sin diálogo: retirado "Guardada sin {capa} · Conservar {capa}" (2.2, 4.2 paso 5, M16, §7, §8; anotado en §9.19).
- C25 / C42 / C43 → Live Activity solo escenario A en 2.5 y 4.6; widget mediano a 1.1 (2.1, 4.1); Siri `PlayMix(MixEntity)`; "Al acostarte" como una página de texto (2.7, §9.12 cerrada).
- C32 → variante Papel marcada 1.1 (§6); 1.0 solo oscura.
- C33 → primer uso sin autoarranque ni "abrir sin sonar" (2.5, 2.7).
- C35 → Háptica: "Ninguna · Mínima" ("Marcada" al Watch 1.2); nota `marea.haptica.nota`; grupo "háptica"; regla de silencio por fase (§7); `[spike I0-5]` retirado de la nota.
- C38 → entran "Cómo se genera" (2.9) y "Lo que no hay" (2.10) como páginas de E5+E7 y el recibo como estado comprado de la hoja (2.3); §1, §3, §5b-§5e, §10 ampliados a diez pantallas.
- C39 → "Esta noche" como nombre de la mezcla viva sin guardar (no es una pantalla) en 2.2, 2.4, 2.5, 4.2, 4.6; Acceso asistido 1.1 (§6).
- C40 → `NightWindow` 21:00–07:00 en todo el documento (antes 22:00); página nocturna por procedencia, dura la sesión, sin salida a las 07:00 (cabecera, 2.1, 2.4, §6, §11); el tip nunca de noche.
- C41 → fila "Salida" con `AVRoutePickerView` en Ajustes (2.7, `ajustes.salida`).
- C45 → spikes renombrados a los de la reconciliación (I0-6 en §6); el antiguo "spike I0-7 (Tier 0)" desaparece (C07) y el "I0-8" pasa a cambio de código; I0-9 opcional se mantiene.
- C46 → fila "Mantener encendida" (Mientras carga / Siempre / Nunca) en Ajustes.
- C47 → "Pasar sola a Noche" con "Al bloquear" por defecto (antes "Al minuto"), 1 min / 3 min / Nunca; Noche al bloquear en 4.1 y 4.6.
- C48 / C49 → interrupciones por ventana de la mañana en 4.1 y 4.7 (cita a 07/09).
- C53 → "{MB}" fijado en build, nunca `Bundle` en runtime (2.6, 2.7, `ajustes.version`); "Cómo se genera" cita el test de autocorrelación.
- C54 → Qué sabemos con lista negra sin excepción; población por criterio parafraseado ("veinte participantes con dificultad para dormirse, según Tsai…"); plantilla afirmación + cuerpo de 10 §2.9; pie de dos líneas; título "Qué sabemos".
- C55 → estado comprado con enlace "Escribir una reseña" (`pro.resena`); sin `requestReview` ni fila "Valorar"; "No te pediremos que la valores." en Lo que no hay.
- C56 → Diagnóstico: anillo acotado (tiempos relativos desde Play, sin fecha ni `portName` ni nombres de mezcla, sesión actual y anterior, excluido de iCloud y App Group), "Enviar informe" abre el correo con el texto (sin adjunto), `diagnostico.nota`; declarado en Lo que no hay; el contador de sesiones se deriva del anillo.
- C58 → inventario de Ajustes = la lista de C58 (2.7): Noche (Pasar sola · Mantener encendida · Hora en Madrugada · Controles visibles), Háptica, Al acostarte, Salida, Pro, sobre (Qué sabemos · Lo que no hay · Cómo se genera · Diagnóstico · Escribir al autor), pie y versión; iCloud 1.1; sin "abrir sin sonar", sin reseña, sin guía AirPods.
- C60 → entrada `que_sabemos.en_vela` en Qué sabemos (hallazgo con n y cita; no se compila sin cita); "Mostrar la hora en Madrugada" opt-in.
- C63 → orden de VoiceOver de la página y Magic Tap en la raíz citados en 5b.
- C64 → "chip" no aparece; §8 lo dice.
- C65 → un solo tip; las frases de Noche son texto fijo; lista cerrada (2.5).
- C66 / C67 → cero `glassEffect` (P12); conteo de estilos con nueve pasos y 17 Medium contado (P5; la hoja Pro queda en 6 con el detalle de texturas compuesto como un estilo, como 10 §2.8 pide a E5 confirmar).
- §1 regla 3 / §4 → tres mezclas gratis (`freeSavedMixLimit` 1 → 3), viento libre, temporizador libre, Marea Pro salvo Madrugada, En familia 1.0: reparto en la cabecera y en 2.2, 2.3, §3.
- §1 regla 7 → "Nada se vende de noche" como primera regla de la cabecera; aplicada a la versalita, la fila "pro", el ítem " · pro" y la fila Pro de Ajustes (ya no hay "toque explícito" que abra la hoja de noche).
- §1 regla 8 → `displayPrice`, `displayName`, `freeSavedMixLimit` y el estado de la prueba como únicos números enseñados; ninguna constante de copy.
- §3 vocabulario → "Esta noche", "Qué sabemos", "Manto", "Día", "Mar y viento", "Marrón y hoguera", "Pared", "Rosa y lluvia", "Empezar la prueba · 7 noches", "Lo que no hay", "Cómo se genera", "Escribir al autor", "Salida", "Mantener encendida", "Pasar sola a Noche", "En familia", "Una vez."; las palabras que no se graban, en §5e y §10.
- §5 alcance → solo oscura, iOS 17, SleepNoise, 29,99 sin lanzamiento; 1.1 marcado en Papel, iCloud, widget mediano, "Debajo de otro audio", Acceso asistido, escucha de 30 s, guía AirPods.

**Pasada de coherencia contra las fuentes consolidadas**

- 10 §5e → todas las claves y cadenas de §5e renombradas y reescritas letra a letra (`pro.*`, `pro.prueba.*`, `prueba.*`, `mezclas.*`, `mezcla.*`, `comun.*`, `sabemos.*`, `que_sabemos.*`, `ajustes.*`, `madrugada.ajuste.*`, `marea.haptica*`, `lo_que_no_hay.*`, `como.*`, `diagnostico.*`, `pagina.*`, `ax.*`); las 14 cadenas sin equivalente en 10 van marcadas **[pendiente de E7]** y listadas en §9.19; "Deshacer" tras Vaciar retirado (10: se deshace cargando una mezcla); `mezclas.eliminar.nota` "La mezcla de esta noche no cambia."; `pro.fallo` / `pro.fallo.sin_confirmar` / `pro.sin_tienda*` / `pro.restaurar.no`; "Ahora no" añadido (10 §5e.1 lo asigna a E5; 03 §4.9).
- 03 §3-§4 / 04 → paso 6 para las filas del paywall (03 §3.4); `Toggle` y picker con `.tint(texto)` (03 §4.12); hairlines de Comprar 1,5 pt `índice`; `trazo-hoja-ac` = `trazo-ac` (03 §3.1); Capas citada como hoja `.large` sobre `negro` (03 §4.10); Comprar sin precio en `texto2` (03 §3.1; anotada la contradicción con §4.6 / 04 §2.6 en §9.8); "Empezar la prueba" entre `trazo-hoja` y la `índice` de Comprar (03 §4.6 / 04 §2.6; anotado 03 §5 #14 en §9.8); nombres de componentes de 04 (`HairlineAction`, `TextAction`, `StateWord`, `EditorialRow`, `TypeStep`).
- 05 → geometría de la cabecera de la página tomada de 05 §2.1: versalita 64-82 (área táctil 52-96), nombre 100-134, línea de estado 144-164, línea 2 164-184, nota de una vez 196-256, horizonte 272-296 (antes 60-104 / 104 / 152-260); los peldaños del error y "Enviar informe" repartidos entre renglón de estado y línea 2; 08 conserva la redacción de la prueba.
- 07 → fila Temporizador del primer uso "Hasta dormirme · 45 min" (antes "Apagado"); 07 manda.
- Reconciliación §3 → la mezcla viva se llama "Esta noche" (antes "Rosa y lluvia" por `mezcla.nombre.auto`); "Rosa y lluvia" queda solo como mezcla de la casa.

**Deltas rechazados**

Ninguno.

**Tensiones registradas, no rechazos** (detalle en §9.19): 03 §5 #15 (párrafo de la noche 1) frente a 10 §5e.3 y C07; "Guardada sin · Conservar" en 03 §5 #12 y 10 §5e.9 frente a C23; "Esta noche" como fila de Mezclas en 10 §2.7; `pagina.capas.y` como nombre de la página en 10 §5e.2 frente a "Esta noche"; `mezclas.casa.restaurar` sin uso; 03 §5 #14 "entre hairlines de índice" para "Empezar la prueba".
