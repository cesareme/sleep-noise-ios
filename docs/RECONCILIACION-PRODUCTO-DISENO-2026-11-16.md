# Reconciliación producto–diseño — SleepNoise

**Fecha:** 2026-11-16 · **Autoría:** presidencia del comité de reconciliación (dueño del producto delegado) · **Entradas:** `docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md` (el plan), `docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md` (la dirección) y las especificaciones `04`–`11`, más el dossier de 67 conflictos con tres opiniones (producto, diseño, ingeniería) por conflicto.

Este documento decide. Cada conflicto tiene una decisión en negrita, una razón, un coste aceptado y los deltas exactos a aplicar en los documentos afectados. Nada queda "a valorar" salvo lo listado en §6, que es lo indecidible sin el dueño y lleva recomendación y fecha límite.

Convenciones: "el plan" = FUNCIONES-PRIORIZADAS; "la dirección" o "03" = 03-DIRECCION-DE-DISENO; "04"…"11" = especificaciones de diseño por número; "semana-pareja" = una pareja de ingenieros una semana (= 2 semanas-ingeniero). Las versiones son 1.0, 1.1, 1.2, 2.0.

---

## §0 Resumen de una página

Las diez decisiones que más pesan. El resto (57) están en §2 y no son menores, pero cuelgan de estas.

| # | Conflicto | Decisión | Por qué, en una línea | A quién obliga |
|---|---|---|---|---|
| 1 | Autoridad de los documentos | El plan manda **qué, cuándo y cuánto** (alcance, matriz libre/Pro, precio, calendario); la dirección manda **cómo** (carácter, tokens, componentes, arquitectura de pantalla, copy); el código veta lo que toque el hilo de audio. Esta reconciliación es la semana 1 del calendario (03 §8.2 la ponía en la 5) y deja una sola lista de decisiones, cada una con su plazo. | Dos documentos con dos jurisdicciones claras cuestan menos que uno que gane siempre. | Todos. 03 §7 pasa a ser un puntero a §2 de este documento. |
| 2 | Precio | **29,99 € de lista, sin precio de lanzamiento.** Un solo `displayPrice` en la hoja Pro; la captura 1 no lleva cifra. | Un precio con rebaja exige precio anterior real (Directiva 98/6/CE) y dos cadenas de copy; no vende más en una compra única de 30 €. | 03 §7.8, 08, 10, 11. `pro.precio.lanzamiento` se retira. |
| 3 | Temporizador | **Entero libre**: los dos modos, cualquier duración, fin como hora, "+15" libre. La palabra "pro" no aparece en el temporizador. Siesta a 1.1. | El temporizador es fiabilidad nocturna, no un argumento de venta; capar a 60 min solo produce reseñas de una estrella. | 03 §7.9 y §1.4, 07, 08, `AccessPolicy.freeTimerMinutes` desaparece. |
| 4 | Matriz de texturas | **5 libres (blanco, rosa, marrón, lluvia, viento) / 6 Pro**; nunca se cuentan texturas en paywall ni ficha ("Todas las texturas"); la lista libre solo crece. | El viento es la textura que completa la mezcla gratuita básica; contar texturas en marketing obliga a reescribir cada vez que se añade una. | 03 §1.4 y §7.9, 08, 11, `AccessPolicy.soundIsIncluded` (rama libre). |
| 5 | Madrugada | **Océano fijo a nivel bajo con Marea a 8/min para todos**, entrada 3 s, Marea se retira hacia el minuto 13, el mar funde 5 min; nada al terminar; nunca prueba ni paywall. | A las cuatro de la mañana no se vende nada y no se elige nada; una receta fija es más fiable que "la última mezcla". | 03 §1.4, 06, 07, 08, 10. |
| 6 | Prueba de 7 noches | **Se dispara con la primera acción Pro, nunca con Play**, siempre tras una hoja Pro que dice "Empezar la prueba · 7 noches". `startTrialIfNeeded()` sale de `play()`. Estado en Keychain. | Una prueba que arranca sola al pulsar Play caduca sin que el usuario sepa que existía. | 08, 10, `MixerModel.play()`, `TrialClock`. |
| 7 | Página principal | **La página de 03**: nombre de la mezcla, Horizonte, hasta tres filas que suenan + "y N más", "Todas las capas" en hoja. **Sin ranuras ni selector por ranura**; once texturas en 1.0 con tope de seis simultáneas como regla de modelo. | El mezclador por ranuras es el PR #3 con otro nombre; la página de 03 es lo que vende la captura 3. | 05, plan §3.1 (ítems ranuras y selector eliminados), `SavedMix` formato v2 (pares id+nivel, que ya guarda, más `version: 2`, que falta). |
| 8 | Live Activity y StandBy | **Live Activity recortada en 1.0 solo en el escenario A** (dos parejas): pantalla de bloqueo, dos botones, cuatro estados, Isla compacta/mínima; StandBy = la misma vista escalada, sin diseño propio ni venta, con un solo control (pausa/play). En escenario B pasa entera a 1.1 (donde el plan ya la tenía). | Es la función con mejor ratio visibilidad/coste, pero no cabe en una pareja sola sin tocar la reserva del 30 %. | Plan §2 tabla de versiones y §9.7, 09 §3, §6 de este documento (condicionado a la segunda pareja). |
| 9 | iCloud | **1.0 sin KVS.** Formato de mezcla v2 + App Group + test de ida y vuelta para que 1.1 lo active sin migración. Pie: "Sin suscripción. Sin cuenta. Sin rastreo." | Tres mezclas no justifican un sistema de sincronización en la primera versión; prepararlo sí. | Plan §2.1 bloque B y §1 principio 10, 08, 09 §5, 10. |
| 10 | Marca | **SleepNoise por defecto**, cierre el viernes de la semana 2; icono y comprobación legal independientes del nombre (semanas 1-3); Siri usa `${applicationName}`; "Marea" descartada como marca. | Un cambio de nombre tras lanzar cuesta más que el nombre perfecto; lo urgente es que el nombre no bloquee icono ni legal. | 03 §7.2, 11, 10 (Siri), §6. |

Estimación final 1.0 (§5): **≈ 34,25–36,5 semanas-pareja** (≈ 68,5–73 semanas-ingeniero) en escenario A y 32,25–34 en B, frente a 33,5 del plan; las fechas de hito (semana 30 en escenario A, semana 44 en B) no se mueven porque los añadidos se pagan con lo que sale (ranuras, gestos de Marea por textura, KVS, timbre por capa).

---

## §1 Reglas de precedencia aplicadas

Las reglas, en el orden en que se aplicaron cuando dos documentos chocaban:

1. **Carácter visual, tokens, componentes y arquitectura de pantalla: manda la dirección (03 y 04–11).** El plan no describe pantallas; donde lo hacía (ranuras, selector, panel "ahora mismo", chips), se corrige el plan.
2. **Alcance, versión, calendario y presupuesto: manda el plan, salvo que lo que meta rompa el carácter o la fiabilidad nocturna.** Cuando la dirección quería meter más (Marea v2, gestos por textura, Watch, Siesta, modo claro), gana el plan y la función queda especificada para la versión que el plan dice.
3. **Reparto gratis/Pro: manda el código existente (`AccessPolicy.swift`) salvo decisión explícita en este documento.** Hay cuatro cambios explícitos: viento pasa a libre, el temporizador pasa entero a libre, Marea es Pro pero suena para todos en Madrugada, y las mezclas guardadas gratis pasan de una a tres (`freeSavedMixLimit` 1 → 3; el plan §2.1 y 03 §7.10 coinciden; Pro sigue sin límite, como en `canSave`).
4. **Vocabulario: manda la guía de copy (10) y se fija aquí (§3).** Donde 10 y el plan difieren, se elige el término y se enumeran los ficheros a corregir. Regla general: sustantivo sin adjetivo en ES; unidad léxica de una o dos palabras en EN.
5. **Hilo de audio: manda el código.** Nada que exija nuevos parámetros en `RenderState` se decide aquí sin puerta de ingeniería: el bus maestro con tilt se condiciona al spike I0-7 (semana 2) con puerta de decisión en la semana 4–6; si no llega, la función que depende de él cae a 1.1 sin discusión.
6. **Cuando las tres opiniones coinciden, se adopta sin más.** Cuando difieren, se elige la que quita más sin perder función ni fiabilidad nocturna, y se escribe por qué.
7. **Nada se vende de noche.** Ninguna superficie entre 21:00 y 07:00 muestra prueba, paywall, tip ni reseña. Esta regla es transversal y supera a cualquier ficha.
8. **Los números que se enseñan al usuario son los del código.** `displayPrice`, `displayName`, cuenta de capas, estado de la prueba: nunca constantes de copy duplicadas.

---

## §2 Fichas de conflicto (67)

Formato de cada ficha: lo que decía cada documento · tres opiniones en una línea · **decisión** · razón · coste aceptado · deltas por fichero.

### C01 · autoridad-de-la-reconciliacion

- **Plan:** sus hitos (§2.1) cierran "ranuras y matriz libre/Pro por escrito antes de la semana 2"; el plan decide qué y la dirección cómo, pero sus 10 decisiones del dueño (§9) se cruzan con las 10 de 03 §7.
- **Dirección:** 03 §7 toma diez decisiones (acento, marca, modo claro, iOS mínimo, Marea, micrófono, Watch, precio, reparto, mezclas) que el plan considera suyas; 03 §8.2 sitúa la reconciliación en la semana 5.
- **En juego:** dos listas de decisiones del dueño, con plazos distintos, para las mismas preguntas.
- **Producto:** jurisdicciones claras y una sola lista. **Diseño:** 03 §7 se queda como registro, apunta a la lista única. **Ingeniería:** la reconciliación es la semana 1, no la 5; el código veta hilo de audio.
- **Decisión: el plan manda qué/cuándo/cuánto; la dirección manda cómo; el código veta el hilo de audio; la reconciliación es la semana 1 del calendario; una sola lista de decisiones del dueño (§6 de este documento), cada línea con su plazo y primera tanda el viernes 27-11-2026; 03 §7 pasa a ser un puntero.**
- **Razón:** dos listas con plazos distintos garantizan contradicción; adelantar la reconciliación a la semana 1 evita cuatro semanas de especificación sobre bases en disputa.
- **Coste aceptado:** cuatro semanas de calendario del plan se reordenan (la especificación de 5 semanas cabe dentro de las semanas 0–8 del bloque Primitivas).
- **Deltas:**
  - `03-DIRECCION` §7: sustituir el cuerpo por "Las decisiones 7.1–7.10 se consolidan en `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` §2 y §6; este apartado queda como registro histórico."; §8.2: "Reconciliación: semana 1" (antes semana 5).
  - `FUNCIONES-PRIORIZADAS` §2.1 hitos: añadir "Reconciliación producto–diseño: semana 1"; §9: añadir línea de cabecera "Lista única en RECONCILIACION §6; cada línea con su plazo; primera tanda 27-11-2026".

### C02 · precio-de-lanzamiento

- **Plan:** 29,99 € de lista, sin descuento de lanzamiento mencionado.
- **Dirección:** 03 §7.8: 29,99 lista + 19,99 de lanzamiento; 08 y 10 llevan la clave `pro.precio.lanzamiento`; 11 lo mete en la captura 1.
- **En juego:** cumplimiento (precio anterior real), dos cadenas de copy, una captura con cifra que caduca.
- **Producto:** lista única 29,99, sin lanzamiento. **Diseño:** acepta quitar la cifra de la captura. **Ingeniería:** un solo `displayPrice`, ninguna constante de precio en copy.
- **Decisión: 29,99 € de lista sin precio de lanzamiento; un solo `displayPrice` de StoreKit en la hoja Pro; la captura 1 no lleva cifra.**
- **Razón:** un lanzamiento rebajado exige precio anterior demostrable y mantiene dos cadenas; el beneficio en una compra única de 30 € no está probado y la cifra en captura caduca.
- **Coste aceptado:** se renuncia al empujón de lanzamiento; si el dueño quiere una oferta posterior se hará con StoreKit (offer code), no con copy.
- **Deltas:**
  - `03-DIRECCION` §7.8: "29,99 € de lista. Sin precio de lanzamiento. Prueba de 7 noches local."
  - `08-MEZCLAS-PRO-PRUEBA`: eliminar la clave `pro.precio.lanzamiento` y cualquier línea "antes/ahora"; la hoja muestra `product.displayPrice` una vez.
  - `10-GUIA-DE-COPY`: eliminar `pro.precio.lanzamiento`; conservar `pro.precio` = "{displayPrice} · Una vez."
  - `11-ICONO-Y-APP-STORE`: captura 1 "Un solo pago." sin cifra; descripción sin cifra.

### C03 · temporizador-modos-y-reparto

- **Plan:** temporizador entero libre (matriz 2.1).
- **Dirección:** 03 §7.9: temporizador libre hasta 60 min, duraciones largas Pro; 07 distingue dos modos (Hasta dormirme / Manto) y un "Escudo".
- **En juego:** `AccessPolicy.freeTimerMinutes=[15,30,60]` existe en código; el usuario que pone 8 horas y se topa con un paywall a medianoche.
- **Producto:** entero libre. **Diseño:** acepta si la hoja Pro deja de listar el temporizador. **Ingeniería:** quitar `freeTimerMinutes` y `maxTimerMinutes` como límites Pro; mantener 360 como tope técnico de UI.
- **Decisión: temporizador entero libre: dos modos (Hasta dormirme, Manto), cualquier duración (Hasta dormirme hasta 360 min; Manto por hora, sin tope en minutos, C22), fin expresado como hora, "+15" libre. La palabra "pro" no aparece en el temporizador. Siesta a 1.1.**
- **Razón:** el temporizador es fiabilidad nocturna; un límite de 60 min solo produce quejas y no diferencia Pro mejor que las texturas y Marea.
- **Coste aceptado:** un argumento de venta menos en la hoja Pro.
- **Deltas:**
  - `AccessPolicy.swift`: eliminar `freeTimerMinutes`; `maxTimerMinutes = 360` es el tope de Hasta dormirme (para todos); Manto se expresa por hora y no tiene tope en minutos (C22).
  - `03-DIRECCION` §7.9 y §1.4: "Temporizador entero libre."
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: eliminar cualquier estado "pro" en duraciones; "Escudo" → "Manto" (ver C11).
  - `08-MEZCLAS-PRO-PRUEBA`: eliminar la línea "Temporizador largo" de la lista de la hoja Pro.
  - `FUNCIONES-PRIORIZADAS` §2.1 matriz: sin cambio (ya libre); añadir nota "confirmado en reconciliación C03".

### C04 · matriz-texturas-libres-pro

- **Plan:** 5 libres (blanco, rosa, marrón, lluvia, viento) / 6 Pro.
- **Dirección:** 03 §7.9: 4 libres (las del código) + "5 nuevas Pro"; 11 habla de "once texturas" en ficha y de "7 Pro".
- **En juego:** la rama libre de `AccessPolicy.soundIsIncluded` tiene 4 (`.white, .pink, .brown, .rain`); `SoundID` aún no tiene `.wind`; la ficha de App Store cuenta números que cambiarán.
- **Producto:** 5/6 con viento libre; nunca contar en marketing. **Diseño:** acepta 5/6; la ficha dice "todas las texturas". **Ingeniería:** la lista libre solo crece (nunca se quita una textura libre a quien ya la tenía).
- **Decisión: 5 libres (blanco, rosa, marrón, lluvia, viento) / 6 Pro (océano, ventilador, trueno, hoguera, arroyo, cabina: las dos del código más las cinco de PR-A menos el viento); nunca se cuentan texturas en paywall ni ficha; capa = ranura simultánea, textura = elemento del catálogo; la lista libre solo crece; se cierra ahora.**
- **Razón:** el viento completa la mezcla gratuita mínima creíble (rosa+lluvia+viento); los números en marketing envejecen.
- **Coste aceptado:** una textura menos en el argumento Pro.
- **Deltas:**
  - `AccessPolicy.swift` y `SoundID.swift`: añadir `.wind` a `SoundID` (PR-A) y a la rama libre de `soundIsIncluded` (o introducir `freeSounds` como `Set<SoundID>` y que `soundIsIncluded` lo consulte).
  - `03-DIRECCION` §1.4 y §7.9: "Cinco libres (blanco, rosa, marrón, lluvia, viento); seis Pro."
  - `08-MEZCLAS-PRO-PRUEBA`: hoja Pro: "Todas las texturas" (lista nombrada debajo, sin número).
  - `11-ICONO-Y-APP-STORE`: ficha sin "once"/"siete"; "Todas las texturas, una línea cada una."
  - `FUNCIONES-PRIORIZADAS` §2.1 matriz: sin cambio; añadir nota "cerrada en C04; la lista libre solo crece".

### C05 · marea-en-madrugada-gratis

- **Plan:** §2.1 (matriz y bloque B) y §3.2 ficha madrugada: 20 min de océano bajo, fuera del mezclador, carve-out explícito en `AccessPolicy` "sin Marea"; con Pro, Marea opcional a 8/min.
- **Dirección:** 03 §5 #11 y 07: 20 min de la última mezcla al 60 %, con Marea para todos; 03 §7.5 y 06: Marea para todos en Madrugada desde 1.0.
- **En juego:** fiabilidad a las 4:00 (la última mezcla puede ser trueno al 80 %); coherencia del reparto.
- **Producto:** carve-out sí, receta fija. **Diseño:** océano fijo bajo con Marea 8/min. **Ingeniería:** receta fija = cero ramas; Marea se retira hacia el minuto 13 para que el final sea mar plano.
- **Decisión: Madrugada = océano fijo a nivel bajo con Marea a 8/min para todos; entrada de 3 s; Marea se retira hacia el minuto 13; el mar funde durante los últimos 5 min; al terminar no pasa nada; nunca muestra prueba ni paywall.**
- **Razón:** una receta fija es más fiable que la última mezcla y la Marea en Madrugada es la mejor demostración posible de Pro sin venderla. Dar la Marea a todos en Madrugada es un cambio del plan (su carve-out decía "sin Marea"), y se declara como tal.
- **Coste aceptado:** Madrugada no respeta la mezcla favorita del usuario.
- **Deltas:**
  - `03-DIRECCION` §5 #11: sustituir "última mezcla al 60 %" por "océano fijo a nivel bajo"; §1.4: añadir "océano fijo, 8/min, retirada en el minuto 13".
  - `06-MAREA`: apartado Madrugada: "8 respiraciones/min, sin control, se retira a los 13 min".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: sustituir "última mezcla" por la receta "océano · nivel 0,3 · Marea 8/min · 20 min · entrada 3 s · fundido final 5 min".
  - `08-MEZCLAS-PRO-PRUEBA`: "Madrugada nunca abre la hoja Pro."
  - `10-GUIA-DE-COPY`: `madrugada.estado` = "Madrugada · 20 min"; `madrugada.retirada` = "Se retira · n min".
  - `FUNCIONES-PRIORIZADAS` §2.1 matriz: "Marea: Pro; suena para todos en Madrugada (receta fija)"; §3.2 ficha madrugada: el carve-out pasa de "océano bajo, 20 min, sin Marea" a "océano bajo, 20 min, con Marea a 8/min para todos" (cambio del plan, C05).

### C06 · tocar-pro-escucha-30s

- **Plan:** tocar algo Pro presenta la tarjeta de prueba (§2.1 bloque D, §6.1 #14); no hay escucha de 30 s.
- **Dirección:** 03 §4.2, §4.3, §4.7 y §7.9, y 08: tocar hace sonar la capa 30 s (la Marea guía 30 s) y después sube la hoja Pro; "pro · 30" como etiqueta en la fila.
- **En juego:** un temporizador de 30 s por textura en el motor, estados nuevos de fila, un paywall que aparece a medianoche.
- **Producto:** escucha 30 s a 1.1. **Diseño:** toque abre hoja Pro con "Empezar la prueba"/"Comprar"; etiqueta "pro". **Ingeniería:** sin temporizadores por capa en 1.0.
- **Decisión: sin escucha de 30 s en 1.0; tocar una capa Pro abre la hoja Pro ("Empezar la prueba · 7 noches" / "Comprar"); la fila muestra "pro · 30" solo como nivel guardado (ver C23); la escucha de 30 s pasa a 1.1 y, cuando llegue, no abrirá hoja automáticamente.**
- **Razón:** la prueba de 7 noches ya es la demo; una segunda demo de 30 s añade estados al motor y a la fila sin dato que la justifique.
- **Coste aceptado:** el usuario no oye el océano antes de empezar la prueba.
- **Deltas:**
  - `03-DIRECCION` §4.2, §4.3, §4.7 y §7.9: eliminar "30 s" ("tocar hace sonar la capa 30 s", "guía 30 s", "con 30 s al tocar"); "toque en capa Pro → hoja Pro".
  - `08-MEZCLAS-PRO-PRUEBA`: eliminar "escucha 30 s"; "Toque en capa Pro → hoja Pro".
  - `05-PAGINA-Y-CAPAS`: estado de fila "pro" sin cuenta atrás.
  - `FUNCIONES-PRIORIZADAS` §3.1: añadir ítem "Escucha 30 s de capa Pro" en 1.1, nota "sin hoja automática".

### C07 · prueba-inicio-y-tarjeta

- **Plan:** la prueba arranca con la primera acción Pro; tarjeta de estado "quedan n noches".
- **Dirección:** 08: la prueba arranca al pulsar Play por primera vez (como el código: `play()` llama `startTrialIfNeeded()`); versalita "prueba · quedan n noches" en la página.
- **En juego:** el código actual consume la prueba sin que el usuario lo sepa.
- **Producto:** disparador = primera acción Pro tras una hoja explícita. **Diseño:** hoja Pro con "Empezar la prueba · 7 noches" (tres líneas, 3.1.1). **Ingeniería:** `startTrialIfNeeded()` fuera de `play()`; estado en Keychain; Tier 0 (sin StoreKit) detrás de la misma palabra.
- **Decisión: la prueba se dispara con la primera acción Pro, nunca con Play, y siempre desde la hoja Pro con "Empezar la prueba · 7 noches"; la versalita "prueba · quedan n noches" aparece solo desde que empieza; `startTrialIfNeeded()` sale de `play()`; estado en Keychain.**
- **Razón:** una prueba que arranca sola caduca sin uso; la hoja explícita cumple 3.1.1 y hace del inicio una decisión. Sobre Keychain: el comentario de `TrialClock` lo descarta porque "survives reinstalls but also survives the person changing their mind about the app, which feels worse"; ese argumento vale cuando la prueba arranca sola con Play (reinstalar es la única forma de deshacer un inicio no elegido). Con la prueba iniciada por una decisión explícita en la hoja, reinstalar para repetirla no es cambiar de opinión sino repetir una prueba ya aceptada, y el plan (§2.1 bloque D, §3.2 prueba-sin-tarjeta) ya la pone en Keychain.
- **Coste aceptado:** ninguno nuevo: el plan §2.1 bloque D ya presupuesta "prueba 1" con disparador por primera acción Pro y fecha en Keychain; menos usuarios entran en la prueba, pero los que entran saben que están en ella.
- **Deltas:**
  - `MixerModel.play()`: eliminar `startTrialIfNeeded()`; nuevo `startTrial()` llamado desde la hoja Pro.
  - `TrialClock`: de UserDefaults a Keychain; sustituir el comentario que defiende UserDefaults por la razón de C07.
  - `08-MEZCLAS-PRO-PRUEBA`: "Inicio de la prueba: botón 'Empezar la prueba · 7 noches' en la hoja Pro"; eliminar "al primer Play".
  - `10-GUIA-DE-COPY`: `pro.prueba.empezar` = "Empezar la prueba · 7 noches"; `pro.prueba.estado` = "prueba · quedan n noches".
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Prueba: añadir "Keychain; Tier 0 detrás de la misma palabra".

### C08 · venta-pospuesta-focus

- **Plan:** si el usuario toca Pro de noche, el paywall se pospone y aparece una "línea matinal" al día siguiente.
- **Dirección:** 03 §2 / 10: de noche no se vende; nada de recordatorios.
- **En juego:** `showPaywall` pendiente en estado; una superficie de venta más.
- **Producto:** sin línea matinal. **Diseño:** sin línea matinal. **Ingeniería:** `showPaywall` se consume sin efecto si estamos en ventana nocturna.
- **Decisión: de noche no se vende y no hay línea matinal; `showPaywall` se consume (sin cola).**
- **Razón:** las tres coinciden; un recordatorio de compra por la mañana es exactamente la práctica que el pie "Sin rastreo" promete no hacer.
- **Coste aceptado:** una conversión perdida por toque nocturno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Pro: eliminar "línea matinal".
  - `08-MEZCLAS-PRO-PRUEBA`: "Entre 21:00 y 07:00 el toque en capa Pro no abre hoja; la fila muestra 'pro' y no pasa nada más."

### C09 · icloud-vs-nada-sale

- **Plan:** iCloud KVS (Pro) en 1.0, bloque B "Mezclas que sobreviven" ("mezclas e iCloud 1"); principio 10: "las mezclas sobreviven a reinstalar y a cambiar de iPhone sin cuenta".
- **Dirección:** 03 §6 / 09 §5: "nada sale del teléfono" en 1.0; iCloud fuera.
- **En juego:** 0,5 semanas-pareja, el pie de privacidad, la migración de formato.
- **Producto:** 1.0 sin KVS; preparar formato. **Diseño:** pie "Sin suscripción. Sin cuenta. Sin rastreo." **Ingeniería:** formato v2 + App Group + test ida/vuelta ahora; KVS en 1.1 activo por defecto con fila en Ajustes.
- **Decisión: 1.0 sin KVS; formato de mezcla v2 (pares id+nivel, versionado) + App Group + test de ida y vuelta en 1.0; pie "Sin suscripción. Sin cuenta. Sin rastreo."; KVS Pro en 1.1, activo por defecto con fila en Ajustes para apagarlo; en 1.1 el pie pasa a "Sin suscripción. Sin cuenta. Sin rastreo. Tus mezclas, en tu iCloud si quieres."; no se usa "Sin servidor" porque deja de ser cierto en 1.1.**
- **Razón:** tres mezclas no justifican sincronización; el coste real está en no preparar el formato.
- **Coste aceptado:** quien cambia de iPhone en 1.0 pierde sus mezclas; el principio 10 del plan se cumple a partir de 1.1.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2.1 bloque B "Mezclas que sobreviven": "iCloud KVS → 1.1; en 1.0 formato v2 + App Group"; matriz: "iCloud: Pro, 1.1"; §1 principio 10: "sobreviven a cambiar de iPhone a partir de 1.1".
  - `08-MEZCLAS-PRO-PRUEBA`: formato v2 descrito; "sin sincronización en 1.0".
  - `09-ECOSISTEMA` §5: "iCloud: 1.1; App Group desde 1.0".
  - `10-GUIA-DE-COPY`: `lo_que_no_hay.pie` = "Sin suscripción. Sin cuenta. Sin rastreo."

### C10 · nombre-de-marca-y-icono

- **Plan:** §9.2 abre el naming: "SleepNoise es descriptivo y suena a utilidad de 0,99 $"; candidato "Marea" (si se elige, la función pasa a "Oleaje"/"Swell"), alternativas "Umbra" y "Vela"; decidir en las dos primeras semanas; título de ficha "<Marca>: Sonidos para dormir".
- **Dirección:** 03 §7.2: "Mantener en 1.0"; si se abre naming, para web y prensa después del lanzamiento; 11 hace depender el icono del nombre.
- **En juego:** el icono y la comprobación legal bloqueados por una decisión de nombre.
- **Producto:** SleepNoise, cierre viernes semana 2; naming post-lanzamiento descartado. **Diseño:** icono independiente del nombre (semana 3); "Marea" no es marca. **Ingeniería:** Siri con `${applicationName}`.
- **Decisión: SleepNoise por defecto; cierre el viernes de la semana 2; icono independiente del nombre (semana 3); Siri usa `${applicationName}`; "Marea" descartada como marca; comprobación legal semanas 1–2; naming post-lanzamiento descartado; título de ficha "SleepNoise: Sonidos para dormir" (plural, keyword del VoC).**
- **Razón:** el nombre no debe bloquear icono ni legal; cambiar tras lanzar cuesta más que lanzar con el nombre actual.
- **Coste aceptado:** un nombre genérico.
- **Deltas:**
  - `03-DIRECCION` §7.2: "SleepNoise. Cierre 04-12-2026. 'Marea' es una función, no una marca."
  - `11-ICONO-Y-APP-STORE`: ninguna rama condicionada al nombre; título "SleepNoise: Sonidos para dormir"; icono sin letra ni nombre.
  - `10-GUIA-DE-COPY`: frases Siri con `${applicationName}`.
  - `FUNCIONES-PRIORIZADAS` §9 decisión 2: "cerrada: SleepNoise; Marea sigue siendo la función; Oleaje/Swell no se usa".

### C11 · temporizador-nombres-manto-escudo

- **Plan:** "Manto" para el modo toda la noche.
- **Dirección:** 07 usa "Escudo" en dos sitios y "Manto" en otros; 10 fija "Manto"; EN sin fijar ("Shield"/"Blanket").
- **En juego:** un término en dos documentos y una frase Siri.
- **Producto:** Manto. **Diseño:** Manto. **Ingeniería:** indiferente; un solo identificador `.blanket`.
- **Decisión: "Manto" único; EN "Blanket" (a verificar en en-US por un hablante, §6); sustituir "Escudo" en 03–10; sinónimo Siri "toda la noche" / "all night".**
- **Razón:** las tres coinciden; "Escudo" sugiere protección frente a algo y no es lo que hace.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "Escudo" → "Manto" en todas las apariciones.
  - `03-DIRECCION` §3.2 (fase Despertar: "del Escudo" → "del Manto"), §4.7, §5 #8, #14 y #19, y §6: ídem.
  - `10-GUIA-DE-COPY`: `timer.modo.manto` = "Manto" / "Blanket"; sinónimos Siri "toda la noche", "all night".
  - Código: `TimerMode.blanket`.

### C12 · tu-instrumento-vs-pro

- **Plan:** la hoja de compra y el recibo se llaman "Tu instrumento" (§2.1 bloque D, §3.2 compra-objeto, §6.1 #15–17); la lista "Con Pro" lleva Family Sharing (principio 6, bloque D: "dicho en el paywall").
- **Dirección:** 03 §5 #14 titula la hoja "SleepNoise Pro" con la lista "Con Pro" (… · En familia); 08/10 proponen "Desbloquear" y un nombre grabado.
- **En juego:** el nombre del producto en StoreKit, el verbo de compra, el nombre grabado del usuario.
- **Producto:** "{marca} Pro" y "Una vez." **Diseño:** acepta; retira "Desbloquear" y el nombre grabado. **Ingeniería:** `product.displayName` manda.
- **Decisión: hoja "{marca} Pro" con `product.displayName`; frase "Una vez." y pie "Un solo pago. Para siempre, en todos tus iPhone."; la lista "Con Pro" termina en "En familia" (Family Sharing, 1.0); el recibo es el estado comprado de la misma hoja; sin nombre grabado; sin "Desbloquear"; "Tu instrumento" no se graba.**
- **Razón:** "Tu instrumento" obliga a explicar; "Pro" se entiende y coincide con el `productID`.
- **Coste aceptado:** menos poesía en la hoja.
- **Deltas:**
  - `08-MEZCLAS-PRO-PRUEBA`: título de hoja = `product.displayName`; eliminar "Desbloquear" y "nombre grabado"; lista "Con Pro" con "En familia"; estado comprado = recibo.
  - `10-GUIA-DE-COPY`: `pro.titulo` = "{displayName}"; `pro.una_vez` = "Una vez."; `pro.pie` = "Un solo pago. Para siempre, en todos tus iPhone."; `pro.comprar` = "Comprar · {displayPrice}"; `pro.familia` = "En familia" / "With your family".
  - `FUNCIONES-PRIORIZADAS` §2.1 bloque D y §6.1 #15–17: "Tu instrumento" → "{marca} Pro" (hoja y recibo); la ficha Family Sharing se queda tal cual.

### C13 · trueno-vs-tormenta-lejana

- **Plan:** textura "Trueno".
- **Dirección:** 10 propone "Tormenta lejana" porque "Trueno" asusta.
- **En juego:** `SoundID.thunder`, un nombre de dos palabras con adjetivo (rompe C15), el diseño del sonido.
- **Producto:** Trueno. **Diseño:** acepta si el subtítulo explica. **Ingeniería:** `thunder` intacto; el rediseño del sonido sin crack es trabajo de DSP, no de nombre.
- **Decisión: "Trueno" / "Thunder" se queda; línea de uso "lejano, sin rayos cerca"; el rediseño del sonido elimina el crack; `thunder` intacto; "tormenta" sinónimo Siri.**
- **Razón:** el problema es el sonido, no el nombre; un nombre con adjetivo rompe la regla de catálogo.
- **Coste aceptado:** rediseño DSP del trueno (dentro del bloque A, ya presupuestado).
- **Deltas:**
  - `10-GUIA-DE-COPY`: `textura.trueno` = "Trueno" / "Thunder"; línea de uso "lejano, sin rayos cerca" / "distant, no strikes nearby"; sinónimo Siri "tormenta"/"storm".
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha texturas: añadir "trueno sin crack: solo rumor".

### C14 · descenso-dos-significados

- **Plan:** "Descenso" = fase de la página al caer la tarde (§3.3 del plan).
- **Dirección:** 06: "Descenso" = el ritual de Marea (rampa de 12→6 por minuto).
- **En juego:** la misma palabra para una fase horaria y un ritual de respiración.
- **Producto:** reservar al ritual. **Diseño:** reservar al ritual. **Ingeniería:** la fase es `.day`/`.night`, nunca `.descent`.
- **Decisión: "Descenso" queda reservado al ritual de Marea (1.0, C24); la fase horaria pasa a llamarse "Día" (`.day`); el §3.3 del plan se retitula "Papel"; la rampa se describe como "bajada 12→6".**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.3: título "Papel (modo claro, 1.1)"; sustituir "Descenso" por "Día".
  - `03-DIRECCION` §3.2 tabla de fases: "Descenso" → "Día" ("App delante, antes de acostarse, y de día").
  - `06-MAREA`: "Descenso: bajada de 12 a 6 por minuto, meseta, disolución".
  - `10-GUIA-DE-COPY`: `marea.descenso` = "Descenso" / "Descent".

### C15 · nombres-en-ingles-una-palabra

- **Plan:** §2.1 bloque D "Sistema de nombres" fija "Marea, Descenso, Madrugada, Manto; sustantivos de una palabra en ES y EN; Escudo descartado", pero el propio plan escribe "Breathing tide" y "Small hours mode", excepciones a su regla.
- **Dirección:** 10: una palabra en ES; EN sin regla.
- **En juego:** longitud en filas de 44 pt, widgets y frases Siri.
- **Producto:** sustantivo sin adjetivo en ES; unidad léxica en EN. **Diseño:** ídem. **Ingeniería:** nombres cortos caben en el widget pequeño.
- **Decisión: se adopta la regla del plan, precisada: "sustantivo sin adjetivo en ES; unidad léxica (una o dos palabras) en EN": Marea/Tide, Descenso/Descent, Madrugada/Small hours, Manto/Blanket; "Breathing tide" solo en prosa de ficha; "Small hours mode" → "Small hours"; "Oleaje/Swell" no se graba.**
- **Razón:** las tres coinciden; la regla no es nueva, es la del plan aplicada también a sus propias excepciones.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `10-GUIA-DE-COPY`: añadir la regla en la cabecera; tabla de términos = §3 de este documento.
  - `FUNCIONES-PRIORIZADAS`: "Small hours mode" → "Small hours"; "Breathing tide" solo en §6.3 brief.

### C16 · capa-vs-capas

- **Plan:** "modo Capa" = sonar debajo de otro audio (`mixWithOthers`).
- **Dirección:** "capa" = un sonido en la mezcla (hoja Capas).
- **En juego:** la palabra más frecuente de la app con dos significados.
- **Producto:** "capa" = sonido; el modo se renombra. **Diseño:** ídem. **Ingeniería:** el modo es un estado de sesión, no una pantalla.
- **Decisión: "capa" significa un sonido de la mezcla; el modo de sesión se llama "Debajo de otro audio" / "Under other audio" (estado de sesión con preferencia en Ajustes, ver C44; 1.1); el tema 1.1 del plan se retitula "El día y la mesilla".**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2 tabla de versiones y §3.2: "modo Capa" → "Debajo de otro audio"; tema 1.1 "El día y la mesilla".
  - `10-GUIA-DE-COPY`: `ajustes.debajo` = "Debajo de otro audio" / "Under other audio"; `estado.debajo` = "Debajo de tu podcast" / "Under your podcast".

### C17 · lluvia-fina-colision

- **Plan:** mezcla de la casa "Lluvia fina" (rosa + lluvia).
- **Dirección:** 10: las texturas son sustantivos; "Lluvia fina" parece una textura nueva.
- **En juego:** confusión catálogo/mezcla; el lint de nombres.
- **Producto:** mezclas de la casa nunca textura+adjetivo. **Diseño:** ídem. **Ingeniería:** lint en test de copy.
- **Decisión: textura = sustantivo + línea de uso; las mezclas de la casa nunca son textura+adjetivo; "Lluvia fina" → "Rosa y lluvia"; test de lint sobre las claves de copy.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** un test más.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 mezclas de la casa: "Lluvia fina" → "Rosa y lluvia".
  - `08-MEZCLAS-PRO-PRUEBA`: lista de mezclas de la casa actualizada (C18).
  - `10-GUIA-DE-COPY`: regla de nombres de mezclas de la casa; `mezcla.casa.rosa_lluvia` = "Rosa y lluvia" / "Pink and rain".

### C18 · perfiles-de-entorno-vs-mezclas-de-la-casa

- **Plan:** "perfiles de entorno" (bebé, ronquidos, oficina) con fila en la página principal; cambian temporizador.
- **Dirección:** 03 §1.2 y §5 #12 / 08: tres "mezclas de la casa" ("Lluvia fina", "Cama rosa", "Mar lento") en Mezclas, sin fila en principal, sin cambiar temporizador.
- **En juego:** una fila más en la principal; nombres por problema que prometen resultados.
- **Producto:** mezclas de la casa; nombre por problema a 1.1 tras medir. **Diseño:** en Mezclas, sin fila en principal. **Ingeniería:** receta de niveles; `playMix` por id; carga recortada si incluye Pro.
- **Decisión: cuatro mezclas de la casa en la hoja Mezclas: "Rosa y lluvia" (rosa + lluvia, libre; antes "Lluvia fina"), "Mar y viento" (océano + viento, Pro, carga recortada; antes "Mar lento"), "Marrón y hoguera" (marrón + hoguera, Pro, carga recortada; nueva), "Pared" (marrón + lluvia + viento, libre; es la mezcla libre "sobre marrón, lluvia y viento" que pedía el plan); "Cama rosa" se retira (una segunda mezcla sobre rosa no añade nada a "Rosa y lluvia"); "Noche de fuego" no se usa (colisiona con la pantalla Noche, C47); sin fila en la principal, receta de niveles, nunca cambian el temporizador; los nombres por problema se deciden en 1.1 con dato; si una receta incluye Pro, se carga recortada (como una mezcla guardada), no abre paywall; `playMix` por id.**
- **Razón:** la principal no admite una fila más; prometer "para ronquidos" es un claim.
- **Coste aceptado:** −0,25 semanas-pareja (menos que perfiles).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.1/§3.2: "perfiles de entorno" → "mezclas de la casa (4)"; 1.1: "nombres por problema, tras medir".
  - `08-MEZCLAS-PRO-PRUEBA`: lista: "Rosa y lluvia" (libre), "Mar y viento" (Pro), "Marrón y hoguera" (Pro), "Pared" (marrón, lluvia y viento; libre); "no cambian el temporizador; carga recortada si incluyen Pro".
  - `03-DIRECCION` §1.2 y §5 #12, `05-PAGINA-Y-CAPAS` (ejemplos "Mar lento · sin Océano"): sustituir "Lluvia fina", "Cama rosa", "Mar lento" por la lista de arriba ("Mar y viento · sin Océano").
  - `05-PAGINA-Y-CAPAS`: la principal no lleva fila de mezclas de la casa.

### C19 · once-texturas-en-1-0

- **Plan:** once texturas en 1.0 vía PR-A (las cinco nuevas de PR #3 reescritas) en seis ranuras.
- **Dirección:** 03 §5 #5 y nota final de texturas: "Capas 1.0 (6 capas) / 1.1 (11)", "1.0 se especifica para seis capas (las de main)"; sin ranuras, "capas que suenan".
- **En juego:** `SoundID` de 6 → 11; `RenderState.mix` fijo; tope de simultáneas.
- **Producto:** once en 1.0. **Diseño:** sin ranuras. **Ingeniería:** tope de seis simultáneas como regla de modelo (constante), no de UI.
- **Decisión: once texturas en 1.0 (PR-A), sin ranuras; tope de seis capas simultáneas como regla de modelo reversible; captura 3 "Seis capas a la vez. Una línea cada una."**
- **Razón:** la decisión sigue al plan (once en 1.0 vía PR-A); el tope es del motor (seis camas en `RenderState`), no de la interfaz; la interfaz no debe enseñar huecos.
- **Coste aceptado:** −1,5/−2 semanas-pareja (desaparece el mezclador por ranuras).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.1: ítem "mezclador de seis ranuras" eliminado; "tope de seis capas simultáneas (regla de modelo)".
  - `03-DIRECCION` §5 #5 y nota de texturas: "1.0 (11)"; eliminar "1.0 se especifica para seis capas".
  - `05-PAGINA-Y-CAPAS`: "al activar la séptima capa, la fila muestra 'Seis a la vez' y no se añade".
  - `11-ICONO-Y-APP-STORE`: captura 3 "Seis capas a la vez. Una línea cada una."
  - `10-GUIA-DE-COPY`: `capas.tope` = "Seis a la vez" / "Six at once".

### C20 · pantalla-principal-mezclador-o-resumen

- **Plan:** principal = mezclador (seis filas siempre visibles, con huecos).
- **Dirección:** 03 §4 / 05: principal = nombre, Horizonte, hasta tres filas que suenan + "y N más", "Todas las capas" en hoja.
- **En juego:** la captura 2 y todo 05.
- **Producto:** la de 03. **Diseño:** la de 03. **Ingeniería:** `SavedMix` ya guarda pares id+nivel (`levels: [MixLevel]`); falta añadir `version: 2` (formato v2, C09).
- **Decisión: principal = la página de 03; el formato de mezcla es pares id+nivel versionado (v2).**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno nuevo (incluido en C19).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha "pantalla principal": sustituir por "ver 05-PAGINA-Y-CAPAS".
  - `05-PAGINA-Y-CAPAS`: añadir "formato v2: `[{id, level}]` + `version: 2`".

### C21 · selector-de-textura-por-ranura

- **Plan:** ítem 11 "selector de textura por ranura".
- **Dirección:** no hay ranuras; cada capa es una fila con su nombre.
- **En juego:** un componente entero.
- **Producto:** eliminar. **Diseño:** eliminar; pulsación larga abre Slider del sistema (accesibilidad). **Ingeniería:** eliminar.
- **Decisión: sin selector por ranura; el ítem 11 del plan se elimina; la pulsación larga en una fila abre un Slider del sistema para ajuste fino y accesibilidad.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.1: eliminar ítem 11; renumerar.
  - `05-PAGINA-Y-CAPAS`: "pulsación larga → Slider del sistema con el mismo valor".

### C22 · hora-de-levantarte-version

- **Plan:** ficha "Hora de levantarte" (1.1) como función aparte.
- **Dirección:** 07: Manto se programa por hora fija (DatePicker) en 1.0.
- **En juego:** duplicidad; la envolvente del Manto.
- **Producto:** Manto por hora en 1.0 absorbe la ficha. **Diseño:** Manto por hora con −6 dB a los 45 min. **Ingeniería:** +0,25/0,5 semanas-pareja (DatePicker + envolvente).
- **Decisión: Manto se programa por hora fija (DatePicker) en 1.0, con −6 dB a los 45 min por envolvente; la duración en minutos solo existe en Hasta dormirme; la ficha "Hora de levantarte" queda absorbida.**
- **Razón:** una función con dos nombres; la hora es el modelo mental de "toda la noche".
- **Coste aceptado:** +0,25 semanas-pareja (solo el DatePicker: el plan ponía la hora en 1.1); la envolvente −6 dB a los 45 min y el "fin como hora" ya están presupuestados en "temporizador de dos modos 1,5" del bloque A.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.1/§3.2: eliminar "Hora de levantarte"; en Manto: "por hora fija, 1.0".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "Manto: hora de fin (DatePicker); −6 dB a los 45 min; Hasta dormirme: minutos".

### C23 · capa-pro-nivel-cero-o-guardado

- **Plan:** al caducar la prueba, las capas Pro pasan a nivel cero y se guardan a cero.
- **Dirección:** 05: la fila conserva el nivel y muestra "pro · N".
- **En juego:** `loadedMixWasStripped`; si la degradación escribe, el usuario que compra después recupera una mezcla rota.
- **Producto:** conservar. **Diseño:** conservar con "pro · N". **Ingeniería:** el motor ignora capas Pro sin acceso; la degradación nunca escribe; guardar conserva sin diálogo.
- **Decisión: la capa Pro conserva su nivel y la fila muestra "pro · N"; el motor la ignora sin acceso; la degradación nunca escribe en disco; guardar conserva el nivel sin diálogo.**
- **Razón:** las tres coinciden; es lo que hace que comprar después "devuelva" la mezcla.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Prueba: "degradación: el nivel se conserva; nada se escribe".
  - `05-PAGINA-Y-CAPAS`: estado de fila "pro · N".
  - Código: `MixerModel.endPlayback(engineAction:canDowngrade:)` (privada) no toca `SavedMix`.

### C24 · marea-v1-v2-en-1-0

- **Plan:** Marea v1 (sobre todas las camas, `bedDepth`) en 1.0; v2 (gestos por textura, Salud) en 1.1.
- **Dirección:** 06 mete el ritual (rampa, meseta, disolución) y los gestos por textura en 1.0 y habla de "v1/v2" en la UI.
- **En juego:** 0,5/0,75 semanas-pareja; parámetros nuevos por cama en `RenderState`.
- **Producto:** v1 + ritual en 1.0; gestos 1.1. **Diseño:** acepta; sin "v1/v2" en UI. **Ingeniería:** el ritual es una curva de `bedDepth` (cero parámetros nuevos); los gestos por textura exigen `RenderState` nuevo.
- **Decisión: Marea 1.0 = `bedDepth` sobre todas las camas (como en main) + ritual (bajada 12→6, meseta, disolución) + toggle; gestos por textura a 1.1; Salud a 2.0; "v1/v2" no aparece en UI.**
- **Razón:** el ritual cabe en la curva existente; los gestos por textura no.
- **Coste aceptado:** −0,5/0,75 semanas-pareja en 1.0.
- **Deltas:**
  - `06-MAREA`: "1.0: profundidad común + ritual; 1.1: gesto por textura; 2.0: Salud"; eliminar "v1/v2" de cualquier etiqueta.
  - `FUNCIONES-PRIORIZADAS` §2.1 bloque A: "Marea 1.0 incluye ritual"; 1.1 "gestos por textura".

### C25 · live-activity-standby-version

- **Plan:** Live Activity + StandBy en 1.1 (§2 tabla de versiones; §9.7: "este plan la pone en 1.1… 1.0 no tiene StandBy"); §9.7 estima ~2 semanas-pareja una Live Activity recortada si el dueño la quiere en 1.0; la base de 33,5 no la incluye.
- **Dirección:** 09 §3 diseña StandBy con tinte rojo y venta ("prueba caducada") y una Isla expandida.
- **En juego:** ~2–3 semanas-pareja; el 30 % de reserva en escenario B.
- **Producto:** recortada en A; 1.1 en B. **Diseño:** StandBy = vista escalada sin diseño propio ni venta. **Ingeniería:** 2–2,5 semanas-pareja recortada (bloqueo, dos botones, cuatro estados, Isla compacta/mínima); estado terminada→Madrugada solo si I0-3 (intents) va bien.
- **Decisión: Live Activity recortada en 1.0 solo en escenario A (pantalla de bloqueo, dos botones, cuatro estados, Isla compacta y mínima, StandBy = la misma vista escalada sin diseño propio ni venta y con un solo control, pausa/play, sin "+15", ~2–2,5 semanas-pareja); en escenario B se queda en 1.1, como en el plan; "terminada → Madrugada" condicionado al spike I0-3.**
- **Razón:** mejor ratio visibilidad/coste del plan, pero no cabe en una pareja sin tocar la reserva; en A se adelanta desde 1.1, en B no se mueve.
- **Coste aceptado:** +2/2,5 semanas-pareja en A; en B, la pantalla de bloqueo solo muestra el Now Playing del sistema.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2 tabla de versiones: "Live Activity recortada: 1.0 en escenario A / 1.1 en B"; §9.7: "cerrada en C25; +2–2,5 semanas-pareja solo en A".
  - `09-ECOSISTEMA` §3: eliminar Isla expandida, estado "prueba caducada" y cualquier venta; "StandBy: la misma vista escalada con un solo control (pausa/play), texto ≥24 pt".

### C26 · centro-de-control-version

- **Plan:** control de Centro de control en 1.0 (0,5 semanas).
- **Dirección:** 09 lo pone en 1.1.
- **En juego:** 0,5/0,75 semanas-pareja; depende de intents (I0-3).
- **Producto:** 1.0 fino. **Diseño:** acepta si es un control del sistema sin diseño. **Ingeniería:** sobre los mismos intents; corte sin coste si en la semana 14 no está.
- **Decisión: Centro de control + botón de Acción en 1.0 (0,5–0,75 semanas-pareja) sobre los intents de C43; corte sin coste en la semana 14 si no está.**
- **Razón:** es casi gratis una vez existen los intents.
- **Coste aceptado:** +0,5/0,75 semanas-pareja.
- **Deltas:**
  - `09-ECOSISTEMA` §4: "1.0 (condicionado a semana 14)".
  - `FUNCIONES-PRIORIZADAS` §2.1 bloque A: añadir "Control + botón de Acción, 0,5–0,75".

### C27 · madrugada-entradas

- **Plan:** Madrugada se entra por doble toque en la página y por Siri.
- **Dirección:** 07: botón explícito en Noche terminada y en el widget; nunca gesto oculto.
- **En juego:** descubribilidad a las 4:00; el hueco del "+15" cuando el temporizador ha terminado.
- **Producto:** siempre botón. **Diseño:** botón "Madrugada · 20 min" en el hueco del "+15" cuando Noche ha terminado. **Ingeniería:** intent `SmallHours` para Siri/Atajos/widget/bloqueo.
- **Decisión: Madrugada siempre es un botón: Siri/Atajos, widget pequeño (intent, visible 00–06), pantalla de bloqueo (widgetURL) y botón "Madrugada · 20 min" en Noche terminada ocupando el hueco del "+15"; sin doble toque.**
- **Razón:** a las cuatro nadie recuerda gestos.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Madrugada: eliminar "doble toque"; entradas = botón/widget/Siri/bloqueo.
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "Noche terminada: el botón '+15' se sustituye por 'Madrugada · 20 min'".
  - `09-ECOSISTEMA`: widget pequeño muestra "Madrugada · 20 min" entre 00:00 y 06:00.

### C28 · watch-version

- **Plan:** Watch en 1.2 (§2 tabla "Muñeca, mesilla grande y oído"; catálogo: watch 1.2).
- **Dirección:** 03 §7.7: Watch 1.1 "de verdad mínimo"; 09 lo especifica ya como 1.2.
- **En juego:** batería de la serie S; una app más que mantener.
- **Producto:** 1.2. **Diseño:** 1.2, especificado ahora. **Ingeniería:** prototipo de batería en 1.1; en 1.0 el Reproduciendo del sistema ya controla desde el reloj.
- **Decisión: Watch se queda en 1.2, como dice el plan (09 ya lo especifica así); 03 §7.7 se corrige; prototipo de batería en 1.1; en 1.0 el usuario controla desde el reloj con Reproduciendo del sistema.**
- **Razón:** el control remoto ya existe gratis vía Now Playing; una app de reloj exige su propio ciclo.
- **Coste aceptado:** ninguno en 1.0.
- **Deltas:**
  - `03-DIRECCION` §7.7: "Watch: 1.2".
  - `09-ECOSISTEMA` §6: "1.2"; añadir "1.0: Reproduciendo del sistema".
  - `FUNCIONES-PRIORIZADAS` §2 tabla de versiones: sin cambio (Watch 1.2); nota "confirmado en C28".

### C29 · timbre-con-un-gesto

- **Plan:** "timbre con un gesto" (deslizar vertical en pantalla completa cambia grave/agudo).
- **Dirección:** 03 §1.2 lo quita; 05 propone filas de timbre en Capas.
- **En juego:** bus maestro con tilt que no existe (`RenderState` sin bus); el eje vertical ya es scroll/maestro.
- **Producto:** DSP maestro en bus, expuesto como fila. **Diseño:** fila(s) LevelRule "Timbre" (Grave–Lejos) en Capas; sin gesto. **Ingeniería:** prototipo = spike I0-7 (semana 2); por capa a 1.1.
- **Decisión: timbre = DSP en el bus maestro (1.0, condicionado al spike I0-7) expuesto como fila LevelRule "Timbre" (Grave–Lejos) en Capas; sin gesto en pantalla completa; timbre por capa a 1.1.**
- **Razón:** el gesto muere con el eje vertical (C52); el bus es necesario para el fundido espectral (C31).
- **Coste aceptado:** −0,5 semanas-pareja frente a por capa; si el spike falla, la fila cae a 1.1.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.1/§3.2: "timbre con un gesto" → "Timbre (fila en Capas, bus maestro)"; 1.1 "por capa".
  - `05-PAGINA-Y-CAPAS`: fila "Timbre" al pie de Capas, LevelRule con extremos "Grave"/"Lejos".
  - `10-GUIA-DE-COPY`: `capas.timbre` = "Timbre" / "Tone"; extremos "Grave"/"Lejos", "Deep"/"Far".

### C30 · siesta-en-1-0

- **Plan:** Siesta (20–30 min, fundido corto, sin ventana nocturna) en 1.1.
- **Dirección:** 07 la nombra como tercer modo en 1.0.
- **En juego:** un modo más en el selector; una palabra en Siri.
- **Producto:** 1.1. **Diseño:** acepta; hueco reservado. **Ingeniería:** 1.1.
- **Decisión: Siesta no está en 1.0; 07 reserva el hueco; la palabra no aparece en catálogo ni en Siri hasta 1.1.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "Siesta: 1.1 (hueco en el selector de modo)".
  - `10-GUIA-DE-COPY`: clave `timer.modo.siesta` marcada 1.1.

### C31 · fundido-espectral-en-1-0

- **Plan:** fundido espectral (corte de filtro + retirada de capas) en 1.0 bloque A.
- **Dirección:** 07: "fundido" = ganancia 10–15 min; no describe espectral.
- **En juego:** `beginFade` lineal con `fadeStep` Float (precisión en rampas largas); el bus no existe.
- **Producto:** ganancia en 1.0; espectral si el bus llega. **Diseño:** una sola palabra "Fundiendo · n min". **Ingeniería:** cuenta entera para la rampa; corte de filtro solo con bus; "retira capas" fuera.
- **Decisión: fundido de ganancia de 10–15 min con cuenta entera (no `fadeStep` Float); corte de filtro solo si el bus maestro llega (puerta semana 4–6); "retira capas" fuera; estado "Fundiendo · n min".**
- **Razón:** la rampa larga con Float acumula error audible; el espectral depende del bus.
- **Coste aceptado:** si el bus no llega, 1.0 funde solo en ganancia.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Fundido: "ganancia 10–15 min (1.0); corte de filtro condicionado al bus; retirada de capas eliminada".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: estado "Fundiendo · n min".
  - Código: `beginFade` con contador entero de muestras.

### C32 · modo-claro-papel

- **Plan:** modo claro ("Papel") en 1.1.
- **Dirección:** 03 §7.3 opción (b): modo claro en 1.0; 04 define tokens de papel.
- **En juego:** cada pantalla en dos esquemas; QA doble.
- **Producto:** 1.1. **Diseño:** acepta si los tokens quedan en el catálogo. **Ingeniería:** `preferredColorScheme(.dark)` en la raíz en 1.0.
- **Decisión: solo oscura en 1.0 (`preferredColorScheme(.dark)` en la raíz); Papel en 1.1 junto con "Debajo de otro audio"; los tokens de papel quedan en 04 marcados 1.1.**
- **Razón:** el plan manda en alcance; el carácter no se rompe porque la app es nocturna.
- **Coste aceptado:** quien usa la app de día en 1.0 la ve oscura.
- **Deltas:**
  - `03-DIRECCION` §7.3: "oscura en 1.0; Papel 1.1".
  - `04-SISTEMA-FUNDAMENTOS`: tokens `papel`, `tinta` marcados "1.1".
  - `FUNCIONES-PRIORIZADAS` §3.3: sin cambio (1.1).

### C33 · primera-noche-autoarranque

- **Plan:** la app arranca sonando la primera vez ("primera noche sin tocar nada") y hay ajuste "abrir sin sonar".
- **Dirección:** 05: la app abre en reposo; Play manual; titular "Un toque y suena".
- **En juego:** `AVAudioSession` activa al lanzar; sorpresa a volumen alto; una preferencia más.
- **Producto:** reposo + Play. **Diseño:** reposo + Play. **Ingeniería:** autoarranque solo por Atajos "Al acostarte".
- **Decisión: la app abre en reposo y suena con Play; el autoarranque existe solo vía Atajos "Al acostarte"; sin ajuste "abrir sin sonar"; titular de la captura 2 "Un toque y suena." (C57).**
- **Razón:** las tres coinciden.
- **Coste aceptado:** −0,25/0,5 semanas-pareja.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2: eliminar "arranca sonando" y "abrir sin sonar"; "autoarranque por Atajos".
  - `11-ICONO-Y-APP-STORE`: titular de la captura 2 "Un toque y suena."

### C34 · healthkit-en-marea-v2

- **Plan:** HealthKit (frecuencia respiratoria) para la Marea v2 en 1.1.
- **Dirección:** 06: ritmo de partida fijo; Salud en 2.0.
- **En juego:** permisos de Salud en una app que promete "sin rastreo".
- **Producto:** sin HealthKit en 1.1. **Diseño:** "Empezar a 12 por minuto". **Ingeniería:** el ritmo de partida es un parámetro; la fila Salud reservada.
- **Decisión: sin HealthKit en 1.1; ritmo de partida "Empezar a 12 por minuto" (parámetro); fila "Salud" reservada para 2.0.**
- **Razón:** un permiso de Salud en 1.1 contradice el pie de privacidad por una mejora no medida.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2 tabla: HealthKit → 2.0.
  - `06-MAREA`: "ritmo de partida 12/min (parámetro); Salud 2.0".
  - `10-GUIA-DE-COPY`: `marea.ritmo` = "Empezar a 12 por minuto" / "Start at 12 a minute".

### C35 · coremotion-en-haptics-1-0

- **Plan:** CoreMotion para suprimir háptica cuando el teléfono está quieto en la mesilla (1.0).
- **Dirección:** 06: Marea háptica "Marcada" y "Mínima"; sin sensores.
- **En juego:** un sensor activo toda la noche; batería; opt-in.
- **Producto:** sin CoreMotion en producción 1.0. **Diseño:** háptica Mínima 3–5 respiraciones opt-in; "Marcada" → Watch. **Ingeniería:** MotionGate por fase (de noche nunca vibra); spike I0-5 como investigación.
- **Decisión: sin CoreMotion en producción 1.0; la puerta de háptica es por fase (de noche nunca vibra); Marea "Mínima" = 3–5 respiraciones opt-in; "Marcada" se va al Watch (1.2); spike I0-5 queda como investigación.**
- **Razón:** una regla por fase evita el sensor y produce el mismo silencio nocturno.
- **Coste aceptado:** de día la háptica no sabe si el teléfono está en la mano.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Háptica: "sin CoreMotion; puerta por fase".
  - `06-MAREA`: "háptica: Mínima (3–5 respiraciones, opt-in); Marcada: Watch 1.2".

### C36 · despertar-amanecer-version

- **Plan:** "Amanecer" (despertar acústico con subida de luz y sonido) en 1.1.
- **Dirección:** 07: solo "Retirada de Manto" (luminancia + fundido largo); nunca naranja.
- **En juego:** una alarma de facto; el color.
- **Producto:** 1.1 solo retirada. **Diseño:** nunca naranja. **Ingeniería:** amanecer acústico 2.0/por demanda.
- **Decisión: 1.1 lleva solo "Retirada de Manto" (subida de luminancia + fundido largo); "Amanecer acústico" a 2.0 o por demanda; nunca naranja.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2 tabla: "Amanecer" → "Retirada de Manto (1.1)"; "Amanecer acústico 2.0".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "Retirada: luminancia + fundido; una tinta".

### C37 · fundido-por-quietud-version

- **Plan:** fundido por quietud (bajar cuando el usuario deja de moverse) en 1.1.
- **Dirección:** no lo contempla.
- **En juego:** CoreMotion de noche (C35).
- **Producto:** 1.2 tras spike. **Diseño:** indiferente. **Ingeniería:** spike I0-5b (semana 2) decide si es viable sin sensor continuo.
- **Decisión: fundido por quietud a 1.2, tras el spike I0-5b (semana 2).**
- **Razón:** depende del mismo sensor que C35 descarta de noche.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2 tabla: "Fundido por quietud 1.2 (spike I0-5b)".

### C38 · pantallas-del-plan-sin-inventario

- **Plan:** menciona pantallas que 03 §5 no inventaría: "Cómo se genera", "Lo que no hay", recibo, Now Playing, gesto timbre, ranuras, elegir textura, panel "ahora mismo", botón AX, carta Novedades, web.
- **Dirección:** 03 §5 inventario cerrado.
- **En juego:** pantallas sin diseño o diseño sin pantalla.
- **Producto:** entran las de confianza; salen las de mecánica. **Diseño:** ídem. **Ingeniería:** ídem.
- **Decisión: entran en el inventario de 03 §5: "Cómo se genera" (una página), "Lo que no hay" (pie + página), recibo (= estado comprado de la hoja Pro), Now Playing (título + "En directo"); salen: gesto timbre, ranuras, elegir textura, panel "ahora mismo", botón AX, carta Novedades (1.1), web (E8, posterior).**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `03-DIRECCION` §5: añadir las cuatro entradas; eliminar las siete.
  - `FUNCIONES-PRIORIZADAS` §3.1: eliminar panel "ahora mismo", botón AX; Novedades 1.1; web E8.

### C39 · pantallas-de-la-direccion-sin-plan

- **Plan:** no presupuesta: página nocturna, hoja Marea, menú Guardar/renombrar, "Esta noche", Controles visibles, Diagnóstico declarado, Acceso asistido, Despertar, widget mediano, papel.
- **Dirección:** 03 §5 las inventaría todas en 1.0.
- **En juego:** ~1,5 semanas-pareja sin presupuesto.
- **Producto:** 1.0 las de la noche; 1.1 el resto. **Diseño:** acepta. **Ingeniería:** presupuesta cada una.
- **Decisión: 1.0: página nocturna, Capas, hoja Marea, menú Guardar/renombrar, "Esta noche" (el nombre de la mezcla viva sin guardar, 03 §1.3 / 05 / 10; no es una pantalla), Controles visibles, Diagnóstico declarado, Live Activity recortada (solo A), Slider por pulsación larga (C21); 1.1: Papel, widget mediano, Acceso asistido, Retirada de Manto.**
- **Razón:** lo que toca la noche entra; lo que toca el día espera.
- **Coste aceptado:** +0,25 página nocturna, +0,5 Noche, +0,75/1 Diagnóstico (ver §5).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2.1: añadir líneas de presupuesto por pantalla (página nocturna 0,25; Noche 0,5; Diagnóstico 0,75–1; hoja Marea dentro de Marea).
  - `03-DIRECCION` §5: marcar "1.1" en Papel, mediano, Acceso asistido, Retirada.

### C40 · pagina-nocturna-y-ventanas-horarias

- **Plan:** "ventana nocturna" 21:00–06:00 (§2.1 primera noche, §9.8) para abrir sonando y para tips; "ventana de la mañana" para interrupciones.
- **Dirección:** 03 §3.2 y §5 #3: página nocturna al volver de Noche entre 22:00 y 07:00, que "vuelve a Descenso al tocar el nombre de la mezcla o a las 07:00" (salida por reloj); 03 §4.12: ningún tip entre 22:00 y 07:00; 05: estado de tinta por procedencia.
- **En juego:** tres constantes horarias distintas; un reloj que cambia la pantalla mientras la miras.
- **Producto:** una constante. **Diseño:** estado por procedencia, por sesión. **Ingeniería:** `NightWindow` 21:00–07:00 única; sin salida por reloj.
- **Decisión: la página nocturna es un estado de tinta por procedencia (al volver de Noche, dura la sesión); una sola constante `NightWindow` (21:00–07:00) para tips, venta y reseña; sin salida por reloj a las 07:00; los tips nunca de noche.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2.1 primera noche, §3.2 y §9.8: unificar "ventana nocturna" en 21:00–07:00 (`NightWindow`).
  - `03-DIRECCION` §3.2 y §5 #3: "página nocturna: por procedencia, dura la sesión; sin salida a las 07:00"; §4.12: "ningún tip entre 21:00 y 07:00 (`NightWindow`)".
  - `05-PAGINA-Y-CAPAS`: "estado nocturno: por procedencia, dura la sesión".
  - Código: `NightWindow.contains(Date)`.

### C41 · airplay-ruta-ausente

- **Plan:** "AirPlay y altavoces" con pantalla propia (1.0).
- **Dirección:** no hay superficie; solo el estado "Sonando · en Dormitorio".
- **En juego:** `routeSharingPolicy = .longFormAudio` vs `mixWithOthers`; latencia de salida.
- **Producto:** sin superficie. **Diseño:** fila "Salida" en Ajustes con el picker del sistema. **Ingeniería:** `longFormAudio`; `outputLatency` para los fundidos; vuelta al altavoz a nivel 40.
- **Decisión: AirPlay sin superficie propia: `routeSharingPolicy = .longFormAudio`, `outputLatency` tenido en cuenta en los fundidos, estados "Sonando · en Dormitorio" / "En pausa · auriculares", picker del sistema solo como fila "Salida" en Ajustes, vuelta al altavoz a nivel 40.**
- **Razón:** el picker del sistema ya es la pantalla.
- **Coste aceptado:** `longFormAudio` es incompatible con "Debajo de otro audio" (1.1), que tendrá que cambiar de política al activarse.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.1: "AirPlay" → "Salida (fila en Ajustes, picker del sistema)".
  - `09-ECOSISTEMA`: añadir "Salida: `AVRoutePickerView` en Ajustes; `longFormAudio`".
  - `10-GUIA-DE-COPY`: `estado.ruta` = "Sonando · en {ruta}"; `estado.pausa.auriculares` = "En pausa · auriculares".

### C42 · widgets-familia-y-standby

- **Plan:** widgets pequeño, mediano, circular, rectangular, inline; StandBy propio.
- **Dirección:** 09: pequeño "Dormir", mediano "Mezclas", bloqueo rectangular e inline; sin circular.
- **En juego:** cada familia es un diseño y un test.
- **Producto:** sin circular; StandBy = pequeño en modo widgets. **Diseño:** ídem. **Ingeniería:** +0,25 semanas-pareja.
- **Decisión: widgets 1.0: pequeño "Dormir" (interactivo; "Madrugada · 20 min" 00–06; sin fondo en StandBy), mediano "Mezclas" (tres mezclas, 1.1), rectangular e inline de bloqueo; sin circular; StandBy 1.0 = el pequeño en modo widgets; estados de 09 §3.4.**
- **Razón:** el circular no tiene nada que decir sin un valor numérico.
- **Coste aceptado:** +0,25 semanas-pareja.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.1: "widgets: pequeño, rectangular, inline (1.0); mediano (1.1); sin circular".
  - `09-ECOSISTEMA` §2: mediano marcado 1.1; "StandBy = pequeño, `containerBackground` removable".
  - `03-DIRECCION` §5 #22: "bloqueo rectangular / inline" (sin circular); mediano 1.1.

### C43 · siri-intents-y-automatizacion

- **Plan:** lista larga de intents (12) y un "Focus filter".
- **Dirección:** 09: siete frases; "Al acostarte" como pantalla de texto.
- **En juego:** tope de 10 App Shortcuts; cada intent es una prueba.
- **Producto:** siete con frase + dos sin frase. **Diseño:** "Al acostarte" = una pantalla de texto. **Ingeniería:** +0,25/0,5 semanas-pareja.
- **Decisión: Siri 1.0: `PlayLastMix`, `Pause`, `PlayMix(MixEntity)`, `PlayLayer`, `ExtendTimer`, `SetTimer(mode)`, `SmallHours` con frase; `Toggle` y `CurrentState` sin frase; `StartTide`/`StopTide`/`SetLevel` a 1.1; "Al acostarte" es una pantalla de texto en 1.0; Focus filter 1.1.**
- **Razón:** siete frases caben en el tope y cubren la noche; el resto no se dice en voz alta a las 3:00.
- **Coste aceptado:** +0,25/0,5 semanas-pareja.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Siri: lista reducida; "Focus filter 1.1".
  - `09-ECOSISTEMA` §4: tabla de intents con versión; "Al acostarte: página de texto con los pasos de Atajos".
  - `03-DIRECCION` §5 #24: "Diez intents con frases" → "siete intents con frase y dos sin frase (C43)"; guía "Al acostarte" de una pantalla.

### C44 · modo-capa-toggle-ajustes

- **Plan:** "modo Capa" = toggle global en Ajustes que cambia `mixWithOthers`.
- **Dirección:** 05/09: un estado de sesión que entra si hay otro audio sonando.
- **En juego:** `master` en `EngineCommand` (necesario para el nivel bajo otro audio); la política de sesión.
- **Producto:** estado de sesión (1.1). **Diseño:** línea de estado "Debajo de tu podcast"; fila de nivel solo en ese estado. **Ingeniería:** `master` entra en `EngineCommand` ya en 1.0 (lo usa C51).
- **Decisión: "Debajo de otro audio" (1.1) es un estado de sesión: entra si suena otro audio y el usuario acepta ("Sonar debajo"), línea de estado "Debajo de tu podcast", fila de nivel visible solo en ese estado; preferencia en Ajustes (Preguntar / Siempre / Nunca); `master` entra en `EngineCommand` en 1.0.**
- **Razón:** un toggle global rompe `longFormAudio` para todos; un estado de sesión lo rompe solo cuando hace falta.
- **Coste aceptado:** ninguno en 1.0.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha "modo Capa": retitular y describir como estado de sesión; 1.1.
  - `09-ECOSISTEMA`: "Debajo de otro audio: preferencia Preguntar/Siempre/Nunca".
  - `10-GUIA-DE-COPY`: `debajo.sonar` = "Sonar debajo" / "Play underneath".

### C45 · calendario-esfuerzo-y-unidades

- **Plan:** semanas-pareja (33,5) con fechas 30/44.
- **Dirección:** 03 §8: "20–22 semanas-ingeniero" para la especificación y el sistema.
- **En juego:** dos unidades; una cifra que no cuadra con ninguna.
- **Producto:** una unidad. **Diseño:** acepta; su especificación son 5 semanas dentro de 0–8. **Ingeniería:** reconciliación semana 1; spike timbre semana 2.
- **Decisión: unidad única semana-pareja; se retira "20–22 semanas-ingeniero"; la especificación de diseño son 5 semanas dentro de las semanas 0–8; reconciliación semana 1; spikes de la semana 2: I0-2 (umbral LevelRule), I0-3 (intents), I0-5/I0-5b (quietud y háptica, investigación), I0-6 (contraste bajo rojo), I0-7 (timbre en bus); fechas 30 (A) y 44 (B) intactas.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `03-DIRECCION` §8: "5 semanas de especificación (semanas 0–8 del plan); unidad: semana-pareja"; eliminar "20–22 semanas-ingeniero".
  - `FUNCIONES-PRIORIZADAS` §2.1 hitos: "semana 1 reconciliación; semana 2 spikes I0-2, I0-3, I0-5, I0-5b, I0-6, I0-7".

### C46 · noche-pantalla-despierta

- **Plan:** la pantalla Noche mantiene el iPhone encendido toda la noche (`isIdleTimerDisabled = true`).
- **Dirección:** 07: Noche se atenúa a los 60 s y respeta el bloqueo del sistema.
- **En juego:** batería, OLED, un teléfono encendido en la mesilla.
- **Producto:** duerme por defecto. **Diseño:** atenuada a 60 s. **Ingeniería:** ajuste "Mantener encendida" con tres valores; por defecto mientras carga.
- **Decisión: Noche duerme por defecto (`isIdleTimerDisabled = false`); ajuste "Mantener encendida: mientras carga (defecto) / siempre / nunca"; la pantalla se atenúa a los 60 s mientras está encendida.**
- **Razón:** un teléfono encendido sin cargar amanece muerto; mientras carga, la pantalla es el reloj de la mesilla.
- **Coste aceptado:** el ajuste existe (una fila más en Ajustes).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Noche: "duerme por defecto; ajuste Mantener encendida".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "atenuada a 60 s; `isIdleTimerDisabled` según ajuste y `batteryState`".
  - `10-GUIA-DE-COPY`: `ajustes.pantalla` = "Mantener encendida" con valores "Mientras carga", "Siempre", "Nunca".

### C47 · noche-controles-y-automatismo

- **Plan:** Noche entra sola a los 3 min sin tocar; tiene sus propios controles (crea temporizador si no lo hay).
- **Dirección:** 07: anatomía fija (reloj 72 pt ocultable, palabra de estado, pantalla-botón, "+15" fijo, vertical = maestro, larga = volver); entra al bloquear.
- **En juego:** dos caminos de entrada; un temporizador creado por una pantalla.
- **Producto:** anatomía de 03; entra al bloquear por defecto. **Diseño:** ídem; "atenuada" no es un estado. **Ingeniería:** nunca crea temporizador (`extend(by:)` solo si existe); estados verificables.
- **Decisión: Noche usa la anatomía de 03 (reloj 72 ocultable, palabra de estado, pantalla-botón, "+15" fijo, arrastre vertical = maestro, pulsación larga = volver); entra al bloquear por defecto, con opción de entrada automática a 1/3 min solo desde la página; nunca crea un temporizador (`extend(by:)` sobre uno existente); los estados son verificables; "atenuada" deja de ser estado.**
- **Razón:** una pantalla que crea temporizadores es una fuente de bugs nocturnos; la entrada al bloquear es la que no exige recordar nada.
- **Coste aceptado:** +0,5 semanas-pareja (Noche completa).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Noche: "entra al bloquear; opción 1/3 min; nunca crea temporizador".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: eliminar estado "atenuada"; "+15 solo si hay temporizador; si no, el hueco está vacío".
  - `10-GUIA-DE-COPY`: `ajustes.noche.pasar_sola` = "Pasar sola a Noche: Al bloquear / 1 min / 3 min / Nunca".

### C48 · interrupcion-alarma-regla

- **Plan:** principio 8 y contrato de fiabilidad (bloque B): "llamada, Siri y otra app reanudan con fundido de 3 s; tras la alarma del sistema no se reanuda"; §3.2 ficha Interrupciones: cualquier interrupción termina la sesión.
- **Dirección:** 03 §2: entre 05:00 y 11:00 una interrupción termina la sesión (la alarma de la mañana); 07/09: fuera de eso, siempre reanudar.
- **En juego:** la alarma de la mañana que, al terminar, vuelve a sonar el ruido; la llamada de las 3:00 que deja la casa en silencio.
- **Producto:** reanudar salvo en ventana de la mañana. **Diseño:** acepta. **Ingeniería:** `CXCallObserver` para distinguir llamada; la ventana se calcula desde el Manto si existe.
- **Decisión: tras la alarma del sistema nunca se reanuda, en ningún modo (principio 8 del plan); como la alarma no se distingue de otra interrupción, su detector es la ventana de la mañana (05:00–11:00, o fin de Manto −60 min si hay Manto): dentro de ella ninguna interrupción reanuda, fuera de ella toda interrupción reanuda con fundido de 3 s; una llamada (`CXCallObserver`) nunca termina la sesión fuera de la ventana.**
- **Razón:** la alarma matinal es la única interrupción que debe ganar y debe ganar también a un Hasta dormirme de 6 h puesto a la 1:00; una llamada a las 3:00 no es el fin de la noche.
- **Coste aceptado:** una llamada dentro de la ventana de la mañana termina la sesión aunque no fuera la alarma.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Interrupciones: sustituir por la regla; §1 principio 8: sin cambio (se cumple).
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: tabla "interrupción × ventana → reanuda/termina" (igual para todos los modos).
  - `09-ECOSISTEMA`: `AudioSessionObserver` + `CXCallObserver`.

### C49 · airpods-altavoz-reanudacion

- **Plan:** al quitarse los AirPods, la app pasa al altavoz y sigue.
- **Dirección:** 09: al quitarse los AirPods, pausa; "Seguir por el altavoz" durante 60 s.
- **En juego:** el altavoz a las 2:00 al 80 % con alguien al lado.
- **Producto:** nunca reanuda sola por altavoz. **Diseño:** "Seguir por el altavoz" 60 s. **Ingeniería:** caída de ruta = fundido corto 40 ms + pausa; toque reanuda capado a 0,4 solo si la ruta cambió; pausa con auriculares = fundido 3 s.
- **Decisión: al caer la ruta (AirPods fuera), fundido corto de 40 ms y pausa; nunca reanuda sola por el altavoz; "Seguir por el altavoz" visible 60 s; el toque reanuda capado a 0,4 solo si la ruta cambió; el `pauseCommand` con auriculares es un fundido de 3 s.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha AirPods: sustituir "pasa al altavoz" por la regla.
  - `09-ECOSISTEMA` §5: "caída de ruta: 40 ms + pausa; reanudación capada a 0,4".
  - `10-GUIA-DE-COPY`: `ruta.seguir_altavoz` = "Seguir por el altavoz" / "Keep playing on speaker".

### C50 · live-activity-botones-y-estados

- **Plan:** Live Activity con cuatro botones y estados "prueba caducada", "bajando".
- **Dirección:** 03 §1.4: dos botones; 09 §3: seis estados.
- **En juego:** espacio en StandBy; venta en la pantalla de bloqueo; límite de 8 h.
- **Producto:** dos botones; sin venta. **Diseño:** seis estados; StandBy un control. **Ingeniería:** 8 h asumidas; cierre por la app.
- **Decisión: dos botones (pausa con fundido 3 s / play; "+15", vacío en Manto); en StandBy un solo control (pausa/play, C25); seis estados: sonando, guiando (Marea), en pausa · causa, fundiendo, terminada (20 min; sigue sonando hasta las 7 h 55), madrugada; sin "prueba caducada" ni "bajando"; límite de 8 h asumido y cerrado por la app; texto en StandBy ≥24 pt.**
- **Razón:** la pantalla de bloqueo a las 3:00 no es un panel; dos botones son los que se pulsan a ciegas.
- **Coste aceptado:** el Manto de más de 8 h pierde la Live Activity a las 7 h 55 (sigue sonando).
- **Deltas:**
  - `09-ECOSISTEMA` §3: tabla de estados = seis; eliminar "prueba caducada", "bajando"; "+15 vacío en Manto".
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Live Activity: "dos botones; seis estados; 8 h".

### C51 · nivel-maestro-donde-vive

- **Plan:** nivel maestro como fila en la página principal, persistente.
- **Dirección:** 05: no hay maestro en la página; el volumen es el del sistema.
- **En juego:** dos volúmenes para el usuario; el nivel bajo otro audio (C44) y la reanudación capada (C49) necesitan un maestro interno.
- **Producto:** maestro interno de sesión, no visible en la página 1.0. **Diseño:** arrastre vertical en Noche/Madrugada; "Sonando · al 40". **Ingeniería:** `master` con rampa en `EngineCommand`; no persiste; nunca toca el volumen del sistema.
- **Decisión: el nivel maestro es `master` con rampa en `EngineCommand` (nivel de sesión, no persiste, nunca toca el volumen del sistema); no aparece en la página en 1.0; se ajusta con arrastre vertical en Noche y Madrugada; estado "Sonando · al 40"; la fila visible solo existe en "Debajo de otro audio" (1.1).**
- **Razón:** el maestro hace falta por dentro (C44, C49) pero enseñarlo duplica el botón de volumen.
- **Coste aceptado:** ninguno (parámetro ya previsto).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2: eliminar "fila maestro en principal"; "maestro de sesión, vertical en Noche".
  - `05-PAGINA-Y-CAPAS`: "sin fila de maestro en 1.0".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "vertical = maestro con rampa; 'Sonando · al 40'".
  - Código: `EngineCommand.setMaster(level:, ramp:)`.

### C52 · eje-del-arrastre

- **Plan:** vertical sobre la fila = nivel de capa; vertical en pantalla completa = timbre.
- **Dirección:** 04 LevelRule: horizontal relativo sobre la fila (8 pt, 30°); vertical = scroll.
- **En juego:** conflicto con el scroll de la lista; el gesto de timbre (C29).
- **Producto:** horizontal. **Diseño:** horizontal (LevelRule). **Ingeniería:** prototipo en spike I0-2 para validar el umbral de 30°.
- **Decisión: arrastre horizontal sobre la fila = nivel de la capa; vertical = scroll (y maestro en Noche); el gesto de timbre muere; el prototipo del umbral es el spike I0-2.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2: "arrastre horizontal (LevelRule)"; eliminar gesto vertical de timbre.
  - `04-SISTEMA-FUNDAMENTOS`: sin cambio; añadir "validado por spike I0-2".

### C53 · envolvente-vs-horizonte

- **Plan:** "envolvente" animada que demuestra que el sonido "nunca se repite"; preview de App Store con la envolvente.
- **Dirección:** 03 §1.4: Horizonte quieto (RMS, grosor 1→3 pt); nada animado de noche.
- **En juego:** un claim ("nunca se repite") que necesita prueba, no animación.
- **Producto:** Horizonte quieto; la prueba se hace fuera de la UI. **Diseño:** ídem. **Ingeniería:** autocorrelación a 10 min en CI + MB del binario + "Cómo se genera".
- **Decisión: Horizonte quieto; la prueba de "nunca se repite" es la página "Cómo se genera" + el tamaño en MB en Ajustes + un test de autocorrelación a 10 min en CI (citado en Notes for Review y prensa); la preview de App Store es la página real sonando; "envolvente" → "Horizonte" en el plan.**
- **Razón:** una animación no demuestra nada; un test sí.
- **Coste aceptado:** un test de CI más.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS`: sustituir "envolvente" por "Horizonte" en todas las apariciones; §3.2 "prueba de no repetición: test de autocorrelación".
  - `11-ICONO-Y-APP-STORE`: preview = página real; Notes for Review cita el test.

### C54 · que-sabemos-poblaciones-clinicas

- **Plan:** página "Qué sabemos" con bloques por población (bebés, tinnitus, TDAH) y un pie corto.
- **Dirección:** 10: lista negra de palabras clínicas sin excepción.
- **En juego:** claims médicos en la ficha y en la app.
- **Producto:** lista negra sin excepción; población solo por criterio de selección con n y cita. **Diseño:** tres entradas + "Lo que no sabemos". **Ingeniería:** etiqueta clínica solo en Notes for Review.
- **Decisión: lista negra de términos clínicos sin excepción en app y ficha, también en "Qué sabemos" (el plan la declaraba "única pantalla exenta del lint"; deja de estarlo); una población se nombra por el criterio de selección del estudio parafraseado sin diagnóstico ("n participantes con dificultad para dormirse, según X"; "n participantes con un zumbido constante en los oídos, según X"), con n y cita; el nombre del diagnóstico solo aparece en Notes for Review; la página lleva tres entradas y "Lo que no sabemos"; pie de dos líneas.**
- **Razón:** un claim clínico sin estudio propio es un rechazo de revisión o una queja; el criterio de selección de los estudios de referencia es un diagnóstico, así que nombrarlo tal cual reintroducía las palabras vetadas por la puerta de atrás.
- **Coste aceptado:** la página no habla de bebés, insomnio ni acúfenos por nombre; el lint de copy corre también sobre "Qué sabemos".
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §2.1 bloque D y §3.2 ficha que-sabemos: eliminar "única pantalla exenta del lint"; reescribir con la plantilla sin diagnóstico.
  - `10-GUIA-DE-COPY`: lista negra con "sin excepción"; plantilla de entrada "n participantes con {criterio parafraseado}, según {cita}".
  - `11-ICONO-Y-APP-STORE`: Notes for Review puede citar la etiqueta.

### C55 · peticion-de-resena

- **Plan:** `requestReview` tras la tercera noche completa; fila "Valorar" en Ajustes.
- **Dirección:** 10: "No te pediremos que la valores" en "Lo que no hay".
- **En juego:** una promesa de copy frente a una llamada del sistema; el dato de conversión de reseñas.
- **Producto:** sin `requestReview` en 1.0; decidir en 1.1 con dato. **Diseño:** la frase se queda como hecho de hoy. **Ingeniería:** política dormida tras bandera; enlace de texto en estado comprado.
- **Decisión: sin `requestReview` en 1.0 (política dormida tras bandera, se decide en 1.1 con dato); sin fila "Valorar" en Ajustes; un enlace de texto "Escribir una reseña" en el estado comprado de la hoja Pro; "No te pediremos que la valores" se escribe como hecho de hoy; métrica objetivo ≥0,5–1 % de reseñas por instalación.**
- **Razón:** la promesa de copy pesa más que una ventana del sistema.
- **Coste aceptado:** menos reseñas en el lanzamiento.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Reseña: "1.0 sin requestReview; bandera; decidir 1.1".
  - `08-MEZCLAS-PRO-PRUEBA`: estado comprado con enlace "Escribir una reseña".
  - `10-GUIA-DE-COPY`: `lo_que_no_hay.resena` = "No te pediremos que la valores." / "We won't ask you to rate it."

### C56 · diagnostico-enviar-informe

- **Plan:** diagnóstico local con "Enviar informe" (1.0).
- **Dirección:** 03 §6: "nada sale del teléfono"; sin telemetría.
- **En juego:** un anillo de log con datos de sesión; el canal de envío.
- **Producto:** 1.0, acotado y declarado. **Diseño:** declarado en "Lo que no hay". **Ingeniería:** anillo local (tiempos relativos desde Play, sin fecha, sin `portName`, sin nombres), sesión actual + anterior, excluido de iCloud; escalera del error; envío por el correo del usuario.
- **Decisión: Diagnóstico en 1.0: anillo local acotado (tiempos relativos desde Play; sin fecha, `portName` ni nombres de mezcla; sesión actual y anterior; excluido de iCloud y App Group), escalera del error, "Enviar informe" abre el correo del usuario con el texto; declarado en "Lo que no hay" y en claims; el contador de sesiones se deriva del anillo.**
- **Razón:** sin diagnóstico la primera semana de soporte es ciega; acotado y por correo del usuario no contradice "nada sale".
- **Coste aceptado:** +0,75/1 semana-pareja.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Diagnóstico: campos del anillo listados; "por correo del usuario".
  - `03-DIRECCION` §6: "nada sale del teléfono salvo lo que tú envías por correo".
  - `10-GUIA-DE-COPY`: `lo_que_no_hay.diagnostico` = "Un registro de la noche, en tu teléfono. Solo sale si tú lo envías."

### C57 · capturas-y-previews

- **Plan:** seis capturas con cifra de precio, envolvente animada y mockups claros.
- **Dirección:** 11: capturas negras, una preview muda.
- **En juego:** la cifra (C02), la animación (C53), la cuenta de texturas (C04).
- **Producto:** acepta 11 con los cambios. **Diseño:** acepta. **Ingeniería:** indiferente.
- **Decisión: C1 "Un solo pago." sin cifra; C2 "Un toque y suena." (C33); C3 "Seis capas a la vez. Una línea cada una." (C19); C5 Noche sola; C6 "Lo que no hay"; una preview muda por idioma con la página real; solo fondo negro.**
- **Razón:** consecuencia de C02, C04, C19, C33 y C53.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `11-ICONO-Y-APP-STORE`: tabla de capturas actualizada con los seis titulares; "preview: una, muda, por idioma".
  - `FUNCIONES-PRIORIZADAS` §6.3 brief: eliminar "envolvente animada" y cifra.

### C58 · ajustes-inventario

- **Plan:** Ajustes con 14 filas (incl. "abrir sin sonar", "Valorar", iCloud, guía AirPods).
- **Dirección:** 05/09: lista del sistema con grupos; sin filas de venta.
- **En juego:** cada fila es una decisión que el usuario no quiere tomar a las 23:00.
- **Producto:** lista corta. **Diseño:** grupos. **Ingeniería:** cada fila mapea a un ajuste real.
- **Decisión: Ajustes (lista del sistema) en 1.0: Noche (Pasar sola · Hora en Madrugada · Controles visibles · Mantener encendida), Háptica, Al acostarte (Siri/Atajos), Salida, Pro (estado), Qué sabemos, Lo que no hay (+ privacidad), Diagnóstico (+ Escribir al autor: abre el correo del usuario, la misma vía que "Enviar informe", C56), versión y MB (→ Novedades en 1.1); iCloud en 1.1; sin "abrir sin sonar"; sin fila de reseña (el enlace "Escribir una reseña" vive solo en el estado comprado de la hoja Pro, C55, y así nunca se ve de noche); guía AirPods en 1.1 (día, no noche, C39).**
- **Razón:** todo lo que no es de la noche o de confianza sale.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Ajustes: sustituir la lista.
  - `09-ECOSISTEMA` §7 / `05-PAGINA-Y-CAPAS`: inventario de Ajustes = esta lista.

### C59 · marea-control-disco-o-linea

- **Plan:** Marea con un disco (dial) de ritmo.
- **Dirección:** 06: toggle + línea de agua; nunca un círculo.
- **En juego:** un componente circular en una app de líneas; VoiceOver.
- **Producto:** toggle + línea. **Diseño:** toggle + línea; "solo oleaje" no es estado. **Ingeniería:** valor hablado para VoiceOver.
- **Decisión: Marea = toggle + línea de agua; nunca círculo; "solo oleaje" no es un estado; el valor se expone hablado ("8 por minuto").**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Marea: "toggle + línea de agua".
  - `06-MAREA`: eliminar "solo oleaje"; "VoiceOver: '{n} por minuto'".

### C60 · madrugada-hora-y-cierre

- **Plan:** Madrugada con tinte ámbar, hora obligatoria, pantalla de cierre "Levántate".
- **Dirección:** 07: una tinta; sin frase de levantarse; nada al terminar.
- **En juego:** el color de noche; un mensaje imperativo a las 4:20.
- **Producto:** una tinta; hora opt-in; nada al terminar. **Diseño:** ídem; la frase de levantarse va a "Qué sabemos". **Ingeniería:** audio se retira 5 min; "Se retira · n min".
- **Decisión: Madrugada usa una sola tinta (sin ámbar); la hora es opt-in en Ajustes; al terminar no pasa nada; lo que dicen los estudios sobre quedarse en la cama despierto va a "Qué sabemos" como una entrada más (con n y cita, redactada como hallazgo y no como consejo; nunca en Madrugada); el audio se retira en 5 min con estado "Se retira · n min"; en 1.0 no hay retirada luminosa (la pantalla se queda en su tinta y al terminar no pasa nada); en 1.1 reutiliza la Retirada de Manto (C36).**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Madrugada: eliminar ámbar, hora obligatoria y "Levántate".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: "una tinta; cierre silencioso".
  - `10-GUIA-DE-COPY`: `madrugada.retirada` = "Se retira · n min" / "Winding down · n min"; la frase de levantarse desaparece; en su lugar, entrada `que_sabemos.en_vela` ("n participantes …, según X", sin imperativo).

### C61 · acento-fuera-de-la-app

- **Plan:** el acento (Índice `#F0C020`) se usa en widgets, Live Activity y StandBy.
- **Dirección:** 04: fuera de la app una sola tinta `texto`; Tinted = `widgetAccentable`.
- **En juego:** contraste bajo el tinte rojo de StandBy; coherencia con el modo Tinted de iOS.
- **Producto:** sin acento fuera. **Diseño:** sin acento fuera; excepción el tinte "on" del control del Centro de control. **Ingeniería:** verificación bajo rojo es criterio de elección (C62).
- **Decisión: sin acento fuera de la app (una tinta `texto`), con la única excepción del tinte "on" del control de Centro de control; Tinted = `widgetAccentable`; la verificación bajo rojo es el criterio de elección de tinta; en modo claro (1.1) `tinta` sobre `papel`.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 widgets/LA: "una tinta; sin acento".
  - `04-SISTEMA-FUNDAMENTOS` §tokens fuera: añadir la excepción del Control.
  - `09-ECOSISTEMA`: "widgetAccentable en texto; nunca en fondo".

### C62 · contraste-rojo-standby-texto

- **Plan:** exige 4,5:1 en todas las superficies.
- **Dirección:** 03 §3: `texto #E8E4DC` da 4,43 / 4,30 bajo rojo (StandBy noche).
- **En juego:** StandBy bajo tinte rojo no llega a 4,5 con el texto actual.
- **Producto:** 4,5 en app; fuera, texto grande y 3:1 medido. **Diseño:** plan B `texto` → `#F0ECE4`. **Ingeniería:** spike I0-6 mide en dispositivo.
- **Decisión: criterio: ≥4,5:1 dentro de la app; fuera de la app (StandBy, bloqueo) texto ≥24 pt y ≥3:1 bajo rojo medido en dispositivo (spike I0-6); plan B: `texto` → `#F0ECE4` si la medida queda por debajo de 3,5.**
- **Razón:** el tinte rojo de StandBy es una capa del sistema; se mide, no se calcula.
- **Coste aceptado:** un spike.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §1 principio de accesibilidad: "4,5 en app; 3:1 con texto grande fuera, medido".
  - `04-SISTEMA-FUNDAMENTOS`: nota de plan B en el token `texto`.
  - `09-ECOSISTEMA` §3: "StandBy: 24 pt mínimo".

### C63 · envolvente-decorativa-voiceover

- **Plan:** §6.1 #2: "envolvente real por capa (decorativa para VoiceOver)"; §1/§2.1 no mencionan `AXChartDescriptor`.
- **Dirección:** 03 §4.1: Horizonte "Sonido" + `AXChartDescriptor` con el nivel por capa (rotor Audio Graph); 04 lo implementa (`LayerChart`, `sys.a11y.layersChart`) junto al elemento `SoundLine` con valor.
- **En juego:** un descriptor de gráfica para una línea que no es un gráfico.
- **Producto:** Horizonte = elemento de estado. **Diseño:** sublíneas decorativas; acción "Ver capas por separado". **Ingeniería:** valor con histéresis de 3 s para que VoiceOver no parlotee; Magic Tap en la raíz.
- **Decisión: Horizonte = elemento de accesibilidad "Sonido" con valor (histéresis 3 s) y acción "Ver capas por separado"; sin `AXChartDescriptor`; las sublíneas son decorativas; Magic Tap en la raíz = play/pausa; en Noche el estado vive en el FullScreenControl.**
- **Razón:** el Horizonte comunica estado, no datos.
- **Coste aceptado:** +0,5 semanas-pareja de accesibilidad (incluye C21 Slider y C59).
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Accesibilidad: eliminar `AXChartDescriptor`; "Horizonte: elemento de estado".
  - `03-DIRECCION` §4.1: eliminar `AXChartDescriptor` / rotor Audio Graph.
  - `04-SISTEMA-FUNDAMENTOS` Horizonte: "accesibilidad: etiqueta 'Sonido', valor con histéresis, acción"; eliminar `LayerChart` y `sys.a11y.layersChart`.

### C64 · chips-vs-versalitas

- **Plan:** usa "chip" seis veces (estado Pro, prueba, temporizador, ruta, Marea, capa Pro).
- **Dirección:** 04: no hay cápsulas; el estado es StateWord o fila con estado en versalita.
- **En juego:** un componente que no existe en el sistema.
- **Producto:** corregir el plan. **Diseño:** StateWord/fila. **Ingeniería:** indiferente.
- **Decisión: "chip" significa StateWord o fila con estado; no hay cápsulas; se corrigen las seis frases del plan.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS`: sustituir "chip" por "estado en versalita" (6 apariciones: §3.2 Pro, Prueba, Temporizador, Ruta, Marea, Capa Pro).

### C65 · tipkit-de-noche

- **Plan:** cuatro tips (arrastre, Marea, Noche, Madrugada), con TipKit.
- **Dirección:** 05/07: un tip (segundo arrastre); las frases de Noche son texto fijo.
- **En juego:** burbujas a las 23:00.
- **Producto:** uno. **Diseño:** uno de día; dos frases de Noche como texto fijo. **Ingeniería:** ninguno 21:00–07:00; lista cerrada.
- **Decisión: un solo TipKit (segundo arrastre, solo de día); las dos frases de Noche son texto fijo de la pantalla; ningún tip entre 21:00 y 07:00; la lista queda cerrada.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2 ficha Onboarding/Tips: "un tip; ventana NightWindow".
  - `07-TEMPORIZADOR-NOCHE-MADRUGADA`: frases de Noche como texto fijo, no tips.

### C66 · liquid-glass-y-relieve

- **Plan:** usar Liquid Glass (iOS 26) en filas, hoja Pro y controles cuando esté disponible; "rama visual iOS 26".
- **Dirección:** 03 §4: un único `#available(iOS 26)` en el Disco (PrimaryActionStyle); sin `glassEffect` en contenido.
- **En juego:** dos apariencias por versión de iOS; vidrio sobre grafito.
- **Producto:** la de 03. **Diseño:** la de 03; fila tocada = pista grafito 44 pt. **Ingeniería:** la "rama visual iOS 26" queda vacía; el vidrio del sistema (barras, hojas) se acepta; sin control teñido.
- **Decisión: único `#available(iOS 26)` en el Disco; fila tocada = pista grafito de 44 pt; sin `glassEffect` en contenido; el vidrio del sistema en barras y hojas se acepta; la "rama visual iOS 26" del plan queda vacía; sin control teñido.**
- **Razón:** el carácter manda; dos apariencias es QA doble.
- **Coste aceptado:** la app se ve igual en iOS 17 y 26 salvo el Disco.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §3.2: eliminar "rama visual iOS 26"; "vidrio del sistema aceptado; ninguno propio".
  - `04-SISTEMA-FUNDAMENTOS`: sin cambio; añadir "fila tocada: pista grafito 44 pt".

### C67 · escala-tipografica

- **Plan:** "cinco estilos de texto" por pantalla.
- **Dirección:** 03 §3: nueve pasos; ≤6 estilos por pantalla; principal ≤4.
- **En juego:** una cifra que no coincide.
- **Producto:** la de 03. **Diseño:** la de 03. **Ingeniería:** 17 Medium cuenta como estilo propio.
- **Decisión: nueve pasos en la escala; ≤6 estilos por pantalla; la principal ≤4; "cinco" del plan se corrige; 17 Medium cuenta como estilo.**
- **Razón:** las tres coinciden.
- **Coste aceptado:** ninguno.
- **Deltas:**
  - `FUNCIONES-PRIORIZADAS` §1 principio tipográfico: "≤6 estilos por pantalla (principal ≤4), de una escala de nueve pasos".
  - `04-SISTEMA-FUNDAMENTOS`: añadir "17 Medium es un estilo (cuenta)".

---

## §3 Vocabulario único final

| Término | ES (UI) | EN (UI) | Lo fijaba antes | Nota |
|---|---|---|---|---|
| Capa | capa | layer | 03/05 | Un sonido de la mezcla. Nunca "modo". |
| Capas (hoja) | Todas las capas | All layers | 05 | Hoja `.large`. |
| Textura | textura | texture | 10 | Elemento del catálogo. Sustantivo + línea de uso. |
| Mezcla | mezcla | mix | 08 | Guardada por el usuario: 3 gratis, sin límite con Pro (`freeSavedMixLimit`). |
| Esta noche | Esta noche | Tonight | 03 §1.3 / 05 / 10 | Nombre de la mezcla viva sin guardar; no es una pantalla. |
| Mezcla de la casa | mezcla de la casa | house mix | plan ("perfil de entorno") | Nunca textura+adjetivo. |
| Rosa y lluvia | Rosa y lluvia | Pink and rain | plan ("Lluvia fina"), 03 ("Cama rosa") | rosa + lluvia, libre. |
| Mar y viento | Mar y viento | Sea and wind | 03 ("Mar lento") | océano + viento, Pro (carga recortada). |
| Marrón y hoguera | Marrón y hoguera | Brown and fire | nuevo (C18) | marrón + hoguera, Pro (carga recortada). |
| Pared | Pared | Wall | nuevo (C18) | marrón + lluvia + viento, libre. |
| Trueno | Trueno | Thunder | plan | Línea de uso "lejano, sin rayos cerca". |
| Marea | Marea | Tide | 06 | Función, no marca. |
| Descenso | Descenso | Descent | plan (fase) → 06 (ritual) | Solo el ritual de Marea (1.0, C24). |
| Día / Noche (fase) | — | — | plan ("Descenso") | Interno: `.day`/`.night`. |
| Papel | Papel | Paper | plan §3.3 | Modo claro, 1.1. |
| Hasta dormirme | Hasta dormirme | Until I sleep | 07 | Modo de temporizador. |
| Manto | Manto | Blanket | 07 ("Escudo"/"Manto") | EN pendiente de verificar en-US (§6). Sinónimo Siri "toda la noche". |
| Siesta | Siesta | Nap | 07 | 1.1. |
| Madrugada | Madrugada | Small hours | 07 / plan ("Small hours mode") | Botón "Madrugada · 20 min". |
| Noche (pantalla) | Noche | Night | 07 | FullScreenControl. |
| Horizonte | Horizonte | Horizon | 03 | plan decía "envolvente". |
| Timbre | Timbre | Tone | plan ("timbre con un gesto") | Fila en Capas, extremos Grave/Lejos, Deep/Far. |
| Debajo de otro audio | Debajo de otro audio | Under other audio | plan ("modo Capa") | 1.1; estado de sesión. |
| Sonar debajo | Sonar debajo | Play underneath | nuevo (C44) | Botón de entrada al estado. |
| Pro | {displayName} | {displayName} | plan ("Tu instrumento") / 03 §5 #14 ("SleepNoise Pro") | `product.displayName`; la lista "Con Pro" termina en "En familia". |
| Una vez. | Una vez. | Once. | 08 | Bajo el precio. |
| Prueba | prueba · quedan n noches | trial · n nights left | 08 | Versalita. |
| Empezar la prueba | Empezar la prueba · 7 noches | Start the trial · 7 nights | nuevo (C07) | |
| Fundiendo | Fundiendo · n min | Fading · n min | 07 | |
| Se retira | Se retira · n min | Winding down · n min | 07 (Madrugada) | Distinto de "Fundiendo" también en EN. |
| Sonando | Sonando · en {ruta} / al {n} | Playing · on {route} / at {n} | 09 | |
| Seguir por el altavoz | Seguir por el altavoz | Keep playing on speaker | 09 | 60 s. |
| Seis a la vez | Seis a la vez | Six at once | nuevo (C19) | Tope de capas. |
| Estado en versalita | — | — | plan ("chip") | StateWord / fila con estado. |
| Qué sabemos | Qué sabemos | What we know | plan | Sin términos clínicos. |
| Lo que no hay | Lo que no hay | What's not here | 10 | Pie: "Sin suscripción. Sin cuenta. Sin rastreo." |
| Cómo se genera | Cómo se genera | How it's made | plan | Una página. |
| Diagnóstico | Diagnóstico | Diagnostics | plan | "Enviar informe" por correo del usuario. |
| Escribir al autor | Escribir al autor | Write to the author | nuevo (C58) | Fila de Ajustes (grupo Diagnóstico) que abre el correo del usuario; sin formulario. |
| Al acostarte | Al acostarte | At bedtime | 09 | Página de texto Siri/Atajos. |
| Salida | Salida | Output | nuevo (C41) | Fila con picker del sistema. |
| Mantener encendida | Mantener encendida | Keep screen on | nuevo (C46) | Mientras carga / Siempre / Nunca. |
| Pasar sola a Noche | Pasar sola a Noche | Switch to Night | 07 | Al bloquear / 1 min / 3 min / Nunca. |
| semana-pareja | — | — | plan | Unidad única de esfuerzo. |

Palabras que no se graban en la UI: "Escudo", "Tu instrumento", "Desbloquear", "envolvente", "chip", "perfil de entorno", "Lluvia fina", "Cama rosa", "Mar lento", "Noche de fuego", "Control fino", "Tormenta lejana", "v1/v2", "Oleaje/Swell", "Amanecer" (hasta 2.0), "Siesta" (hasta 1.1), cualquier término de la lista negra clínica de 10.

---

## §4 Reparto gratis/Pro final

| Capa | Función | Gratis | Pro | Versión | Fuente de verdad |
|---|---|---|---|---|---|
| Texturas | Blanco, rosa, marrón, lluvia, viento | sí | sí | 1.0 | `AccessPolicy.soundIsIncluded` (rama libre + `.wind`) |
| Texturas | Océano, ventilador, trueno, hoguera, arroyo, cabina | — | sí | 1.0 | `AccessPolicy.soundIsIncluded` |
| Texturas | Lista libre | solo crece | — | siempre | C04 |
| Mezcla | Capas simultáneas (tope 6) | sí | sí | 1.0 | regla de modelo |
| Mezcla | Nivel por capa (LevelRule) | sí | sí | 1.0 | |
| Mezcla | Timbre (fila maestro) | sí | sí | 1.0* | *condicionado al spike I0-7 |
| Mezclas | Guardar mezclas | 3 | sin límite | 1.0 | `freeSavedMixLimit` (hoy 1, pasa a 3; §1 regla 3); `canSave` sin límite con acceso completo |
| Mezclas | Mezclas de la casa (4) | sí (las que no incluyen Pro suenan enteras; las demás recortadas) | sí | 1.0 | C18 |
| Mezclas | iCloud (KVS) | — | sí, activo por defecto | 1.1 | C09 |
| Temporizador | Hasta dormirme, Manto, cualquier duración, "+15", fin como hora | sí | sí | 1.0 | C03 |
| Temporizador | Siesta | sí | sí | 1.1 | |
| Temporizador | Retirada de Manto (luminancia) | sí | sí | 1.1 | C36 |
| Marea | Marea (profundidad común + ritual + toggle) | — | sí | 1.0 | C24 |
| Marea | Marea en Madrugada (receta fija, 8/min) | sí | sí | 1.0 | C05 carve-out |
| Marea | Gestos por textura | — | sí | 1.1 | |
| Marea | Háptica Mínima (opt-in) | — | sí | 1.0 | sigue a Marea |
| Noche | Pantalla Noche, Madrugada, Controles visibles | sí | sí | 1.0 | |
| Ecosistema | Now Playing, Siri (7 frases), widgets pequeño/bloqueo, Control, botón de Acción | sí | sí | 1.0 | C26, C42, C43 |
| Ecosistema | Live Activity recortada | sí | sí | 1.0 (A) / 1.1 (B) | C25 |
| Ecosistema | Widget mediano Mezclas | sí | sí | 1.1 | |
| Ecosistema | Debajo de otro audio | sí | sí | 1.1 | C44 |
| Ecosistema | Watch | sí | sí | 1.2 | C28 |
| Confianza | Qué sabemos, Lo que no hay, Cómo se genera, Diagnóstico | sí | sí | 1.0 | |
| Compra | Prueba 7 noches (Keychain), compra única 29,99 | — | — | 1.0 | C02, C07 |
| Compra | Family Sharing ("En familia" en la hoja Pro) | — | sí | 1.0 | plan principio 6 y bloque D; C12 |

Reglas transversales: nunca se vende entre 21:00 y 07:00; nunca se cuentan texturas en marketing; la degradación tras la prueba nunca escribe; Madrugada nunca abre la hoja Pro.

---

## §5 Alcance 1.0 final

### Entra en 1.0 (lista cerrada)

Primitivas (semanas 0–8): bus maestro con `master` + rampa (`EngineCommand`), fundido de ganancia con cuenta entera, formato de mezcla v2 + App Group + test ida/vuelta, `NightWindow`, Keychain de prueba, spikes I0-2 (umbral LevelRule), I0-3 (intents), I0-5/I0-5b (investigación, sin producción), I0-6 (contraste bajo rojo), I0-7 (timbre en bus).

A — Sonido y página: once texturas (PR-A, trueno sin crack), tope seis simultáneas, página de 03 (nombre, Horizonte quieto, ≤3 filas + "y N más"), hoja Todas las capas, LevelRule horizontal + Slider por pulsación larga, fila Timbre (condicionada a I0-7), Marea 1.0 (profundidad + ritual + toggle + línea de agua + háptica Mínima opt-in), estados de fila "pro · N".

B — Temporizador y noche: Hasta dormirme, Manto por hora (DatePicker, −6 dB a los 45 min), "+15", fin como hora, fundido 10–15 min "Fundiendo · n min", Noche (anatomía de 03, entra al bloquear, "Mantener encendida", atenuada 60 s, vertical = maestro), Madrugada (océano fijo + Marea 8/min, botón en todas las entradas, cierre silencioso), página nocturna por procedencia, regla de interrupciones (ventana de la mañana, `CXCallObserver`), regla de AirPods (40 ms + pausa, "Seguir por el altavoz").

C — Mezclas y compra: mezclas guardadas (3 gratis, sin límite con Pro; `freeSavedMixLimit` 1 → 3), menú Guardar/renombrar, 4 mezclas de la casa, hoja Pro (`displayName`, `displayPrice`, "Una vez.", "En familia" (Family Sharing), "Empezar la prueba · 7 noches", estado comprado = recibo + enlace "Escribir una reseña"), prueba por primera acción Pro, degradación sin escritura, "Esta noche" (nombre de la mezcla viva).

D — Ecosistema y confianza: Now Playing ("En directo"), Siri 7 frases + 2 sin frase, "Al acostarte" (página de texto), widgets pequeño "Dormir" + rectangular + inline (StandBy = pequeño), Control de Centro de control + botón de Acción (corte semana 14), Live Activity recortada (solo escenario A), Salida (picker del sistema), Ajustes (lista de C58), Qué sabemos, Lo que no hay, Cómo se genera, Diagnóstico local + Enviar informe, test de autocorrelación en CI, un TipKit, accesibilidad (Horizonte elemento de estado, Magic Tap, VoiceOver en Marea).

Solo oscura. iOS 17. SleepNoise. 29,99 sin lanzamiento.

### Sale a 1.1 (y por qué)

| Función | Por qué sale |
|---|---|
| Live Activity recortada (en escenario B) | No cabe en una pareja sin tocar la reserva del 30 % (C25). |
| Papel (modo claro) | Dobla el QA visual; la app es nocturna (C32). |
| Debajo de otro audio | Exige cambiar la política de sesión y una fila de nivel visible (C44). |
| iCloud KVS (Pro) | Tres mezclas no lo justifican; el formato queda listo (C09). |
| Escucha 30 s de capa Pro | Temporizadores por capa en el motor; la prueba ya es la demo (C06). |
| Gestos de Marea por textura | Parámetros nuevos en `RenderState` (C24). |
| Timbre por capa | Igual que el anterior (C29). |
| Siesta | Un modo más en el selector; no es nocturno (C30). |
| Retirada de Manto (luminancia) | Despertar no es dormir (C36). |
| Widget mediano Mezclas | Depende de MixEntity estable (C42). |
| Siri StartTide/StopTide/SetLevel, Focus filter | No se dicen en voz alta de noche (C43). |
| Nombres de mezclas de la casa por problema | Necesitan dato de uso (C18). |
| Carta Novedades, Acceso asistido, guía AirPods | Día, no noche (C38, C39, C58). |
| Decisión sobre `requestReview` | Con dato (C55). |

A 1.2: Watch (C28), fundido por quietud (C37), háptica "Marcada" en el Watch (C35). A 2.0: Salud en Marea (C34), Amanecer acústico (C36).

### Estimación

Base del plan: 33,5 semanas-pareja (Primitivas 4; A 10,5; B 5,75; C 3,5; D 9,75), reserva 30 % aparte. La base no incluye la Live Activity (el plan la tenía en 1.1), por eso en el escenario A suma entera; sí incluye la prueba con Keychain (bloque D "prueba 1") y la envolvente del Manto (bloque A "temporizador de dos modos 1,5"), por eso C07 no suma y C22 solo suma el DatePicker.

| Ajuste | Δ semanas-pareja |
|---|---|
| Mezclador por ranuras y selector eliminados (C19, C21) | −1,5 … −2 |
| Gestos de Marea por textura → 1.1 (C24) | −0,5 … −0,75 |
| Timbre en bus en vez de por capa (C29) | −0,5 |
| Mezclas de la casa en vez de perfiles (C18) | −0,25 |
| KVS → 1.1 (C09) | −0,5 |
| Autoarranque y "abrir sin sonar" fuera (C33) | −0,25 … −0,5 |
| Diagnóstico acotado (C56) | +0,75 … +1 |
| Live Activity recortada, solo escenario A (C25) | +2 … +2,5 |
| Control + botón de Acción (C26) | +0,5 … +0,75 |
| Manto por hora: DatePicker (C22; la envolvente ya está en la base) | +0,25 |
| Página nocturna (C40) | +0,25 |
| Accesibilidad (C21, C59, C63) | +0,5 |
| Widgets (C42) | +0,25 |
| Siri (C43) | +0,25 … +0,5 |
| Noche completa (C46, C47) | +0,5 |
| Suma de recortes | −3,5 … −4,5 |
| Suma de añadidos (A) | +5,25 … +6,5 |
| **Total escenario A** | **+0,75 … +3 → 34,25–36,5 semanas-pareja (≈ 68,5–73 semanas-ingeniero)** |
| **Total escenario B** (sin Live Activity: añadidos +3,25 … +4) | **−1,25 … +0,5 → 32,25–34 semanas-pareja (≈ 64,5–68 semanas-ingeniero)** |

Las fechas de hito no se mueven: semana 30 (escenario A, dos parejas; la segunda confirmada a más tardar al inicio de la semana 4, §6 n.º 3) y semana 44 (escenario B, una pareja). La reserva del 30 % se mantiene fuera de estas cifras. Los spikes de la semana 2 (I0-2, I0-3, I0-5, I0-5b, I0-6, I0-7) y la puerta del bus en la semana 4–6 son los únicos puntos donde el alcance puede volver a moverse, y las caídas ya están decididas (fila Timbre → 1.1; fundido espectral → solo ganancia; Marea Mínima sin sensor).

---

## §6 Lo que sigue abierto y necesita al dueño

Solo lo que ninguna de las tres opiniones podía cerrar. Cada línea lleva recomendación y plazo; si el plazo pasa sin respuesta, se aplica la recomendación.

| # | Pregunta | Recomendación | Plazo |
|---|---|---|---|
| 1 | Acento: Índice `#F0C020` (03 §7.1 opción a) o la alternativa (b). | (a) Índice, tras una prueba de 5 segundos con la página real sonando en un iPhone en la mesilla a oscuras. | Viernes 27-11-2026 |
| 2 | Marca: confirmar SleepNoise. | SleepNoise. Icono y legal avanzan sin esperar. | Viernes semana 2 (04-12-2026) |
| 3 | Live Activity recortada en 1.0: depende de que la segunda pareja exista a más tardar desde la semana 4 (no empieza antes de los spikes de la semana 2). | Si no hay segunda pareja confirmada el 14-12-2026 (inicio de la semana 4), escenario B y Live Activity a 1.1 sin discusión. | 14-12-2026 |
| 4 | EN de "Manto": "Blanket" o alternativa de un hablante en-US. | "Blanket" salvo veto del revisor en-US. | Antes de grabar copy EN (semana 6) |

Todo lo demás está decidido en §2 y no vuelve al dueño salvo que un spike de la semana 2 o la puerta del bus (semana 4–6) lo reabra, y para esos casos la caída ya está escrita. En particular no vuelven: el defecto "mientras carga" de "Mantener encendida" (C46), iCloud activo por defecto en 1.1 y el pie de privacidad (C09), ni la fila Timbre si el spike I0-7 pasa (C29).

---

*Registro:* 67 conflictos, 67 decisiones. Este documento sustituye a 03 §7 y a FUNCIONES §9 como lista única de decisiones. Los deltas se aplican por fichero en el orden 10 (copy) → 04 (tokens) → 05/06/07/08/09 (specs) → 11 (ficha) → 03 (dirección) → FUNCIONES (plan), para que cada documento aguas abajo herede el vocabulario ya corregido.
