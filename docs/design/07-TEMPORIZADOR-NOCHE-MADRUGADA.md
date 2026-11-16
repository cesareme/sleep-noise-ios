# SleepNoise · 07 · Temporizador, Noche y Madrugada

**Equipo E4 (Tiempo y noche) · 16 de noviembre de 2026 · Documento 07 de la serie de diseño · Especificación de las pantallas 8-11 del inventario de 03 · Revisión 2 tras la puerta de los jurados (respuesta en §11)**

Insumos leídos completos, en este orden: `03-DIRECCION-DE-DISENO-2026-11-16.md` (§3 tokens, §4 componentes, §5 inventario y §8.3 puertas son ley aquí), el brief E4 del director creativo, las notas `tokens.md`, `grafts.md` y `decisions.md`, `00-BRIEF-CREATIVO-2026-11-16.md` (P1-P12, listas negras §7.1 y §7.2), `02-MATERIALES-2026-11-16.md` (paleta medida, Dynamic Type §1.4, StandBy §2.3, movimiento §3, háptica §4, lista de accesibilidad §7), `concepts/dial.md` entero (es de donde más heredamos: la prueba por sesión, las 05:00-11:00, el 40 del altavoz, los controles visibles, la escalera del error) y, por tema, `grafito.md` (la estructura: Noche en cuatro cosas, "+15 min" fijo, "Seguir por el altavoz", las 20 min en pausa), `marea.md` (el horizonte a un tercio, las fases por luminancia, "Se funde a las 03:42", la guarda de 300 ms, el toque boca abajo) y `silencio.md` ("nada cambia de posición", la cifra en seco, "Sin sonido", Magic Tap, la Live Activity terminada que se queda). Código de `main`: `AccessPolicy.swift` (gratis = blanco, rosa, marrón, lluvia; `freeTimerMinutes = {15, 30, 60}`; `maxTimerMinutes = 360`; una mezcla guardada), `SoundID.swift` (seis capas), `MixerModel.swift` (`play(userInitiated:)`, `pause(resumeLater:)`, `endPlayback(canDowngrade:)`, `clampTimerToEntitlement()`, los manejadores de sesión), `Features/Timer` (`SleepTimerController`: `choose / start / pause`, ticker a 0,25 s, `TimerMath.fadeDuration` = un cuarto del total acotado a 5-20 s; `SleepTimerView` actual: rejilla 2 × 2, "Personalizado", candados), `Features/Breathing` (`BreathingGuideController`: `begin / resume / release(over:) / end`, `dissolveSeconds = 120`, `visualSeconds = 20 min`, `BreathingSettings.rateRange = 4...8`, `BreathParameters` inhale 0,4 / exhale 0,45 / reposo 0,15), `Features/Paywall`, `Features/Library`, `Audio/AudioSessionObserver.swift` (interrupción `.began / .ended(shouldResume)`, `.oldDeviceUnavailable`, `mediaServicesWereReset`), `Audio/RenderState` (`beginFade` / `advanceFade` con `fadeStep` en `Float32`), `Localizable.xcstrings` (claves `timer.*`, `control.*`, `error.audio`, `breath.*`). Informe de mercado §1 y §5.2 (lo que no se afirma). `REVIEW-PR3-2026-11-16.md` §"Encaje" y hallazgos de interfaz y de Noche (temporizador de 60 forzado y persistido; "Noche" sin saber si suena algo; reloj a 2,7:1; VoiceOver que lee "Hora"; paywall enganchado detrás de Noche; "Salir" que desaparece del árbol al atenuarse).

**Convenciones.** Medidas en pt para iPhone 17 Pro, 393 × 852, tamaño Large, área segura 59 arriba y 34 abajo; posiciones desde la esquina superior izquierda de la pantalla. Hex: solo los de §3 de 03, nombrados por token; en este documento no se escribe ningún hex, solo nombres de token; si hiciera falta uno que no existe, se propone en §9 y se usa el más cercano. Tipografía por el paso de la escala de nueve de 03 §3.4. Textos de interfaz en ES con EN entre corchetes; las cadenas de §5(e) son las definitivas y son las que se compilan. **[a medir]** marca lo no verificado en dispositivo; **[spike I0-n]** marca lo que depende de un spike de ingeniería de 03 §8.1. Las versalitas se escriben aquí entre `‹›` para distinguirlas (`‹pro›`), y en código son `.smallCaps()` reales. **Ventana nocturna**: 20:00-09:00 para las entradas automáticas en Noche (E2, E3); 22:00-07:00 para la página nocturna y las frases de primera vez (03 §3.2 y §4.12); 05:00-11:00 solo para la regla de interrupciones (03 §1.3). Son tres constantes porque 03 fija dos de ellas; la tercera es la única que esta entrega decide.

**Lo que esta entrega corrige del PR #3 y de `main`, con nombre:** la rejilla 2 × 2 más "Personalizado" (cinco botones para una decisión) pasa a tres intenciones con nombre y una duración; los candados de "Más de 60 minutos" desaparecen (`‹pro›` junto al valor, sin castigo); Noche ya no fuerza ni persiste un temporizador de 60 min que nadie eligió (si no hay temporizador, Noche dice "Toda la noche" y no inventa nada); Noche no se abre en silencio: la palabra "Noche" con la sesión parada arranca el sonido y entra en Noche en el mismo gesto; el reloj de Noche pasa de 2,7:1 a 8,03:1 (`texto-noche`) y VoiceOver lee la hora en palabras y lo que queda, nunca "Hora"; "Salir" deja de ser un botón que se evapora al atenuarse: volver es una pulsación larga con un háptico, un botón de VoiceOver al principio del orden y un botón visible bajo "Controles visibles de noche"; el paywall nunca queda "enganchado" detrás de Noche porque en Noche y Madrugada no se vende nada (la venta de un valor Pro ocurre en la hoja del temporizador, despierto, y solo al confirmar). De `main`, además: el ticker de 0,25 s de `SleepTimerController` se sustituye por dos timers de un disparo (§9.6); el fundido final deja de acumular en `Float32` (§2.1.4); `AudioSessionObserver` lee `AVAudioSessionInterruptionReasonKey` (§4.3).

---

## 1. Intención (P10: una pantalla, una pregunta)

| # | Pantalla | Pregunta a la que responde | Lo que **no** responde (y dónde vive eso) |
|---|---|---|---|
| 8 | **Temporizador** (hoja `.medium` → `.large`) | "¿Cuándo se apaga?" | Qué suena (página), cómo respiro (Marea), cuánto cuesta (hoja Pro, y solo al confirmar un valor Pro) |
| 9 | Fundido por quietud y Despertar (1.1) | "¿Puede apagarse cuando yo ya duermo, y subir suave por la mañana?" | Se deja dibujado en §8 como una fila y una frase; no entra en 1.0 (prototipo CoreMotion y parámetro espectral que no existen) |
| 10 | **Noche** | "¿Sigue todo bien?" | Qué mezcla suena, qué capas, nada de Pro, nada de Marea dibujada (la guía está en el oído) |
| 11 | **Madrugada** | "¿Puedo volver a dormirme sin pensar?" | Qué hora es (a propósito; opt-in en Ajustes), cuántas veces me desperté (no se cuenta), qué es Pro (nunca a esa hora) |

Las cuatro comparten una regla que no está escrita en ninguna de ellas: **ninguna anuncia su final.** El temporizador se funde, la Marea se retira, Madrugada se apaga, y la app no vibra, no suena, no enciende la pantalla ni envía nada. Lo que no hay es parte del diseño.

---

## 2. Anatomía

### 2.1 Pantalla 8 · Temporizador

Hoja del sistema (03 §4.10): `presentationDetents([.medium, .large], selection: $detent)`, `presentationBackground(hoja)`, indicador de arrastre real, **sin botón Cerrar**, sin título centrado. Se abre desde la fila "Temporizador" de la página (E2) y desde el Atajo "Abrir el temporizador". La hoja se cierra arrastrando o tocando fuera; **no hay "Aceptar"**: el valor que se ve es el que vale, salvo el único caso de confirmación (§2.1.4). Se diseña en `.medium` (≈ 420 pt visibles) y cabe entera en él. Una hoja no cambia de detent sola: la app pone `detent = .large` al desplegar la rueda de duración o el selector de hora, y al abrir si `dynamicTypeSize >= .xLarge` (o en SE); vuelve a `.medium` al plegar el control.

**Fase de luminancia de la hoja.** La hoja va siempre en Descenso (`texto` / `texto2` sobre `hoja`), también cuando se abre desde la página nocturna a las 2 de la mañana: 03 §3.1 define `hoja` como "otra habitación" y 03 §3.2 reserva `texto-noche` a Noche, Madrugada y la página nocturna. Abrir la hoja de noche es un acto despierto (elegir una duración); el salto de luminancia es el precio de esa decisión y se declara a propósito. Si el dueño prefiere lo contrario, es una fila de M24 y nada más.

#### 2.1.1 Wireframe · reposo, usuario en prueba o Pro, "Hasta dormirme" elegido

```
x: 0        20                                   373  393
y
 ─ 0   ┌─────────────────────────────────────────────┐  (hoja, esquinas del sistema)
   8   │                    ━━━                      │  indicador del sistema
  24   │  Temporizador                               │  paso 3 · 22/28 Semibold · texto · x 20
  60   │ ────────────────────────────────────────────│  hairline trazo-hoja, margen a margen
  60   │  Hasta dormirme                    45 min ✓ │  fila 72 · nombre paso 5 · valor paso 9 · checkmark del sistema en texto
  84   │  se funde en los últimos 10 min             │  subtítulo paso 7 · texto2 (fila + 24)
 132   │ ────────────────────────────────────────────│  hairline
 132   │  Escudo nocturno                hasta las 07:00 │  fila 72 · (sin pro: prueba/Pro)
 156   │  toda la noche · baja un poco cada hora     │  paso 7 · texto2
 204   │ ────────────────────────────────────────────│
 204   │  Siesta                              20 min │  fila 72
 228   │  se funde en los últimos 2 min              │
 276   │ ────────────────────────────────────────────│
 276   │  Apagado                                    │  fila 56 · paso 5 · texto2 (sin subtítulo)
 332   │ ────────────────────────────────────────────│
 332   │  Duración                            45 min │  fila 56 · hueco de control, SIEMPRE presente · nombre paso 5 · valor paso 9 texto2
 388   │ ────────────────────────────────────────────│  hairline
 400   │  El sonido se funde; tu alarma no se toca.  │  paso 8 · 13/18 · texto2 · x 20 · una línea en Large
 418   │                                             │
 420   └─────────────────────────────────────────────┘  ← borde del detent .medium: todo lo anterior es visible
```

Conteo (P6): cero rectángulos rellenos; cero iconos salvo el `checkmark` del sistema; seis estilos de texto (1 solo mientras suena, 3, 5, 7, 8, 9): el máximo de 03 §3.4. **La hoja no tiene color en 1.0**: ningún índice, ningún control teñido (el `DatePicker` del Escudo va con `.tint(texto)`); el único elemento que podrá llevar color es el toggle de "Fundido por quietud" cuando exista (1.1). El grupo de 32 pt entre "Apagado" y "Duración" de la revisión 1 se ha quitado para que el pie quepa en `.medium`: el pie existe para leerse.

**El hueco de control (fila de y 332).** Existe en los cuatro modos y **solo cambia de contenido**: "Duración · 45 min" (Hasta dormirme), "Hasta las · 07:00" (Escudo), "Duración · 20 min" (Siesta), "Duración · toda la noche" en `texto2` (Apagado; el toque no despliega nada). La rueda y el selector de hora se despliegan **debajo de esta fila** (debajo solo está el pie, que se ancla al borde inferior del detent `.large` cuando hay un control desplegado). Así ninguna fila de modo cambia de posición jamás (03 §3.7).

#### 2.1.2 Wireframe · mientras suena ("Hasta dormirme" corriendo, quedan 38 min)

La cabecera gana la cifra y la acción primaria. **Nada de lo anterior cambia de posición entre sí**: la cifra y la acción se insertan como un bloque propio encima de la lista, y la lista baja una sola vez, al abrir la hoja (es una `List` del sistema que hace scroll; en `.medium` el bloque y las dos primeras filas quedan visibles). Si la sesión termina o se pausa con la hoja abierta, **el bloque se queda y cambia de contenido** ("En pausa" / "Terminó a las 00:42"); nunca desaparece mientras la hoja esté abierta.

```
y
   8   │                    ━━━                      │
  24   │  Temporizador                               │  paso 3
  60   │ ────────────────────────────────────────────│  hairline trazo-hoja
  76   │  38 min                                     │  paso 1 · 56/64 Display Regular · tabular · texto · x 20 · SOLO el número
 140   │  Se funde a las 00:42                       │  paso 7 · 15/20 · texto2 (la palabra va aquí, nunca en la cifra)
 172   │ ────────────────────────────────────────────│  hairline trazo-hoja   ┐
 172   │                  +15 min                    │  HairlineAction 64 · paso 5 Semibold · texto · centrado · la misma etiqueta en los tres modos
 236   │ ────────────────────────────────────────────│  hairline trazo-hoja   ┘
 236   │  Hasta dormirme                    45 min ✓ │  la lista, como en 2.1.1
 ...
```

La cifra lleva **solo un número**: "38 min" / "8 min" (fundiendo) / "07:00" (Escudo) / "En pausa" **[a medir con la fuente real: a 56 pt Display, "Fundiendo · 8 min" ni "Hasta las 07:00" caben en 353 pt en Large, y en AX2 menos aún; por eso la palabra va en la línea de debajo]**. La línea de paso 7 dice lo que la cifra no puede: "Se funde a las 00:42" / "Fundiendo" / "toda la noche · baja un poco cada hora" (Escudo: la misma cadena que el subtítulo de su fila; nada nuevo que leer) / "quedan 38 min" (en pausa). La cifra cambia **en seco una vez por minuto**: `TimelineView(.periodic(from: endDate, by: 60))` con `Int(ceil(remaining / 60))` formateado con `timer.minutesFormat`; los ticks quedan alineados con la hora de fin, así "38 min" → "37 min" cambia en el segundo exacto. Nunca `Text(timerInterval:)`: pinta m:ss a 1 Hz y no tiene "unidad mínima" (se reserva para la Live Activity, E6, donde no hay `TimelineView`). Nunca segundos: nadie los mira y a 1 Hz tendríamos un píxel cambiando cada segundo sin causa en el sonido. El estado se lee por palabra, no por color (03 §1.2 quitó la "regla en `trazo`" porque era invisible).

#### 2.1.3 Capas (elemento → paso → token → medidas → comportamiento)

| Elemento | Paso tipográfico | Color | Medidas (Large) | Comportamiento |
|---|---|---|---|---|
| Indicador de arrastre | — (sistema) | sistema | sistema | Cierra la hoja; en iOS 26 el sistema añade su cierre |
| Cabecera "Temporizador" ["Timer"] | 3 · 22/28 Semibold | `texto` | x 20, y 24-52; hairline a y 60 | Estática; `accessibilityAddTraits(.isHeader)` |
| Cifra (solo sonando) | 1 · 56/64 Display Regular, tracking −1 %, `monospacedDigit()` | `texto` | x 20, y 76-140; `relativeTo: .largeTitle`, tope AX2 | "38 min" / "07:00" / "8 min" / "En pausa"; solo el número; cambio seco por minuto (M8) |
| Línea bajo la cifra | 7 · 15/20 Regular | `texto2` | x 20, y 140-160 | "Se funde a las 00:42" ["Fades at 00:42"] · "Fundiendo" ["Fading"] · Escudo: "toda la noche · baja un poco cada hora" · en pausa: "quedan 38 min"; hora local, formato del sistema |
| `HairlineAction` "+15 min" | 5 · 17/22 Semibold centrado | `texto`; hairlines `trazo-hoja` | 393 × 64 entre dos hairlines, y 172-236 | **La única `HairlineAction` de la hoja** (03 §4.6); dice siempre "+15 min" y suma 15 a la hora de fin en los tres modos (en Escudo es lo que ya hace Noche); pulsado: opacidad 0,6 200 ms; `.selection` solo con el iPhone en la mano |
| Fila de modo (× 3) | nombre 5 · 17/22 Semibold; subtítulo 7 · 15/20; valor 9 · 13/18 Medium tabular | nombre `texto` (`texto2` si `‹pro›` sin acceso); subtítulo `texto2`; valor `texto2` | `EditorialRow` 72; subtítulo a fila + 24; hairline de margen a margen; `checkmark` del sistema 17 pt en `texto` a la derecha del valor en la fila activa | Toque = elige el modo (`.selection`); **ninguna fila cambia de posición**: el control del modo elegido vive en el hueco de y 332 y se despliega bajo él (2.1.4-2.1.6) con `.smooth` 250 ms por opacidad |
| Fila "Apagado" ["Off"] | 5 · 17/22 Semibold | `texto2` (`texto` + `checkmark` cuando es la activa) | `EditorialRow` 56 | Es una fila de modo más (03 §4.7: nombre paso 5); se distingue por la tinta y el `checkmark`, no por el peso. Toque = sin temporizador; la línea de estado de la página dice "Sonando · toda la noche" (E2) |
| Hueco de control ("Duración" / "Hasta las") | nombre 5; valor 9 | `texto` / `texto2`; en Apagado todo `texto2` | `EditorialRow` 56, y 332-388; **siempre presente** | El nombre y el valor cambian con el modo: "Duración · 45 min" / "Hasta las · 07:00" / "Duración · 20 min" / "Duración · toda la noche". Toque = despliega debajo la rueda (Hasta dormirme, Siesta) o el selector de hora (Escudo); en Apagado no hace nada y no es botón (`.staticText`) |
| Rueda de duración | sistema (`Picker` `.wheel`) | sistema sobre `hoja` | 393 × 216 (altura del sistema), bajo el hueco de control; `detent = .large` mientras está desplegada | Valores 5 … 360 en pasos de 5 ("Hasta dormirme"); 10 · 20 · 30 ("Siesta"); los > 60 llevan `‹pro›` a la derecha del valor para el usuario gratuito; se pliega al tocar fuera de ella o al cerrar la hoja; plegarla **no** confirma nada |
| `DatePicker` de Escudo | sistema (`.compact`, `hourAndMinute`, `.labelsHidden()`) | `.tint(texto)` (`tinta` en papel): la hora se lee como texto en la cápsula del sistema; **la hoja no tiene color** (03 §3.1 regla 1; 03 §4.12 solo tiñe el Toggle) | Se despliega bajo el hueco de control, que en Escudo dice "Hasta las · 07:00" | Hora fija que el usuario pone una vez y la app recuerda (07:00 por defecto); nunca se lee de Reloj ni de Salud (no hay API) |
| Pie | 8 · 13/18 Regular | `texto2` | x 20, y 400-418; una línea en Large (41 caracteres en ES, 45 en EN **[a medir]**); dos desde xL, donde la hoja abre en `.large` | "El sonido se funde; tu alarma no se toca." ["Sound fades out; your alarm is never touched."]; el mismo en los cuatro modos |
| Hairlines | — | `trazo-hoja` | 0,5 pt (`1 / displayScale`), x 20-373 | Decorativas; `accessibilityHidden(true)` |

#### 2.1.4 Modo "Hasta dormirme" ["Until I fall asleep"]

- Por defecto desde la primera noche, 45 min (ni "nunca elegí" ni "elegí Apagado" se confunden: el modo activo se guarda como enumeración con cuatro casos, y el temporizador que corre no persiste nada que el usuario no haya elegido; esto corrige el 60 forzado del PR #3).
- Gratis **hasta 60 min continuo** (03 §1.4 y §7.9: `freeTimerMinutes` pasa de `{15, 30, 60}` a `1...60`; `timerIsIncluded` cambia una línea). En la rueda, 65 … 360 llevan `‹pro›` para el usuario gratuito fuera de prueba. El dedo nunca se bloquea: la rueda gira hasta 360. **Una sola regla de confirmación para toda la hoja** (03 §4.7: "abre la hoja al confirmar"): confirmar es **cerrar la hoja** con un valor Pro vigente (rueda en 65-360, o Escudo marcado). Plegar la rueda tocando fuera no confirma: quien gira por curiosidad y la pliega no ve ninguna venta. Al cerrar la hoja con un valor Pro se abre la hoja Pro (E5) encima de la página, con el precio en la primera línea; si no compra, la duración vuelve a 60 sin ninguna nota (la fila dirá "60 min ✓" la próxima vez que se abra; el usuario acaba de ver y rechazar la hoja Pro y la rueda ya llevaba `‹pro›`: decirlo una tercera vez sería un toast). VoiceOver sí lo anuncia, porque es un cambio que no ve: "Sesenta minutos; más de sesenta requiere Pro". Sin 30 s de escucha: no hay nada que oír en un temporizador (03 §4.7).
- Fundido final de **10 min** sobre el nivel maestro con `.easeInOut` en el motor **[spike I0-1: nivel maestro en `EngineCommand`; hasta entonces el fundido escala las seis ganancias a la vez, que es lo que hace `engine.fadeOut(over:)` hoy; lo que cambia es `TimerMath.fadeDuration`: de 5-20 s a 600 s, con un mínimo del 25 % del total para temporizadores < 40 min]**. **Precondición de ingeniería:** `RenderState.beginFade` pone `fadeStep = 1 / Float(samples)`; con 600 s a 48 kHz son 28,8 M de muestras y un paso de 3,5e-8 acumulado en un `Float32`, que se redondea a la baja entre 0,25 y 0,5 y al alza a partir de 0,5: el fundido "de 10 min" duraría 7-8 min con un codo audible. Se cuentan muestras en entero (`UInt32 done / total`) y `progress = Float(done) / Float(total)` (cuatro líneas en `beginFade` / `advanceFade`). El fundido ya corre en el hilo de audio con `FadeCurve.unity` (smoothstep = ease-in-out): solo hay que arreglar la precisión, nada se mueve al hilo principal (cierra §9.6). La Marea, si está guiando, se suelta con el mismo fundido (`breathing.release(over:)`, ya existe).
- "+15 min" suma a la hora de fin. Sin tope para el usuario Pro o en prueba. Para el usuario gratuito, la recomendación al dueño (§9.2) es **sin tope de noche**: el límite gratuito vive en la duración elegida, despierto, no en prolongar a oscuras; un botón que dice +15 y hace +7 es un control que miente. Si el dueño mantiene el tope (60 min *restantes* desde el momento de pulsar; nunca "60 desde el inicio"), la verdad la dice el propio estado ("Se funde a las 03:49" en vez de 03:57: la hora real, sin nota de venta) y VoiceOver anuncia los minutos reales añadidos ("Quedan sesenta minutos"). Nada se vende de noche. Necesita `SleepTimerController.extend(by: 900)` (`endDate += 900`, `didRequestFade = false`, `isFading = false`), que `main` no tiene (`choose()` borra `remaining`).

#### 2.1.5 Modo "Escudo nocturno" ["Night shield"] · `‹pro›`

- Hora fija de fin ("Hasta las 07:00"); el sonido suena toda la noche; **a partir de la segunda hora, el nivel maestro baja un 6 % cada hora en punto con una rampa de 60 s `.easeInOut`, hasta un mínimo del 50 % del nivel inicial** (brief E4) **[spike I0-1: la rampa de 60 s y el RMS]**. Fallback sin nivel maestro: un timer de un disparo por hora en punto (tolerancia 60 s; siete despertares por noche) que publica `updateGains(currentGains() × factor)` sin rampa: un escalón de 0,5 dB con el suavizado existente (`gainCoefficient` 0,002) es inaudible. Es la respuesta a "a las 4 suena demasiado alto" sin tocar la mezcla ni su identidad. A la hora fijada: fundido de 10 min que *termina* a esa hora (empieza a las 06:50). La alarma del sistema no se toca ni se sustituye: la sesión es `.playback` sin `mixWithOthers`, y la alarma de Reloj suena por encima (§4.3).
- "+15 min" en la hoja y en Noche hace +15 sobre la hora de fin: el botón nunca cambia de etiqueta ni de sitio (03 §1.2), y 15 min más antes de las 07:00 es una petición legítima. (La revisión 1 tenía "+30 min" en la hoja; tres etiquetas para una acción cuyo valor exacto está en el selector de debajo eran dos de más.)
- Usuario gratuito fuera de prueba: la fila existe entera, el nombre en `texto2` y `‹pro›` donde iría el valor. Tocarla la marca (`checkmark` + `‹pro›`) y despliega el `DatePicker` **igual que a un usuario Pro** (sin castigo: se puede ver y poner la hora). Al cerrar la hoja con Escudo marcado se abre la hoja Pro encima (la misma confirmación que la rueda > 60, §2.1.4); si no compra, el modo anterior sigue activo y la hora puesta se recuerda por si compra mañana. Esta es la "confirmación" de 03 §4.7: el Escudo no tiene nada que escuchar en 30 s, así que se vende al confirmar, no al tocar. No hay "Activar el Escudo": la hoja tiene una sola `HairlineAction` (03 §4.6) y una sola regla de venta.
- Live Activity con Escudo > 8 h: E6 con el resultado del **[spike I0-3]**; lo que esta pantalla garantiza es que el sonido no depende de la actividad.

#### 2.1.6 Modo "Siesta" ["Nap"] · gratis

- 10 · 20 · 30 min (rueda de tres valores; 20 por defecto). Fundido final de **2 min**. "+15 min" como en los demás modos (la rueda ya da el valor exacto).
- La página no cambia de aspecto por ser de día: la línea de estado dice "Sonando · se funde a las 15:20" (E2). Siesta **no entra sola en Noche ni al bloquear** (§4.1, E2 y E3): de día, con la app delante o al desbloquear, nadie quiere una pantalla negra.
- El pie es el mismo de los demás modos ("El sonido se funde; tu alarma no se toca."): ya dice que la alarma no se toca; un segundo pie con un guiño ("no nosotros") sobraba y no era la voz del brief.

#### 2.1.7 "Apagado" ["Off"]

Sin temporizador. La línea de estado de la página dice "Sonando · toda la noche" ["Playing · all night"]; Noche dice "Toda la noche" ["All night"]. Lo que nunca hace el temporizador, en ningún modo: vibrar, sonar, encender la pantalla, enviar una notificación, silenciar la alarma, cortar en seco.

### 2.2 Pantalla 10 · Noche

Vista a pantalla completa **como capa de un `ZStack` sobre la página** (no `fullScreenCover`: usa la presentación del sistema, no admite una transición propia por opacidad y deja el `TimelineView` del horizonte renderizando bajo el negro): `.opacity(nightIsOn ? 1 : 0)` con `.animation(.easeInOut(duration: reduceMotion ? 0.25 : 2))`, `.statusBarHidden(nightIsOn)` y, en la página, `TimelineView(.animation(paused: nightIsOn))` para que el horizonte no dibuje debajo. Las hojas siguen mandando porque se presentan desde la misma jerarquía. Fondo `negro`. **`isIdleTimerDisabled = false`**: la pantalla puede apagarse por el ajuste del usuario y el sonido sigue; la app no toca el brillo (HIG y PR #3, conservado). Fase de luminancia "Noche" (03 §3.2): **una sola tinta de texto, `texto-noche` (8,03:1)**, también si se entra de día a mano por E1 (es la fase de la pantalla, no de la hora; de día Noche solo se abre a propósito); hairlines en `trazo`; `índice-noche` solo bajo el dedo (la regla vertical de volumen no es índice: es `texto-noche`; de noche no hay color salvo cuando un dedo mueve un nivel, y en Noche no hay niveles por capa).

#### 2.2.1 Wireframe · sonando, "Hasta dormirme", quedan 35 min

```
x: 0        20                                   373  393
y
   0   ┌─────────────────────────────────────────────┐  negro · sin barra de estado
       │                                             │
       │                                             │
 283   │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━│  horizonte · 2 pt · texto-noche · x 20-373 · y 283-285 (centro 284 = 852 × ⅓)
       │                                             │  continuo = suena · ausente = en pausa · nunca escribe
 340   │                   03:07                     │  reloj · paso 1 · 72/80 Display Regular · tabular · texto-noche · centrado · y 340-420 · sin "am/pm"
       │                                             │
 436   │            Se funde a las 03:42             │  estado · paso 3 · 22/28 Medium · texto-noche · centrado · y 436-464
       │                                             │
 480   │   La pantalla puede dormir. El sonido sigue.│  SOLO primera vez · paso 6 · 17/22 Medium · texto-noche · 10 s · y 480-502
 504   │         Mantén pulsado para volver          │  SOLO primera vez · paso 6 Medium · texto-noche · 10 s · y 504-526
       │                                             │
       │         (toda la pantalla es el botón)      │
       │                                             │
 690   │                                             │  ┐ "Seguir por el altavoz" · solo 60 s tras una pausa por auriculares · 64 pt · y 690-754
 754   │                                             │  ┘
 754   │                  +15 min                    │  paso 4 · 20/25 Medium · texto-noche · botón 393 × 64 · y 754-818 · NUNCA se mueve
 818   │                                             │  área segura inferior 34 (indicador de inicio del sistema)
 852   └─────────────────────────────────────────────┘
```

Cuatro cosas: horizonte, reloj, estado, "+15 min". Luminancia: < 4 % de píxeles encendidos **[a medir]**. Nada se mueve: el horizonte es estático (continuo / ausente), el reloj cambia en seco, el estado cambia en seco; la única animación finita es la entrada y la salida (2 s). La Marea **no se dibuja** en Noche (03 §4.3): la guía está en el oído y, si se pidió, en la mano o en la muñeca. Cuatro pasos tipográficos (1, 3, 4, 6) y ninguno por debajo de 17 pt: lo más pequeño de la pantalla es la frase que enseña a salir.

#### 2.2.2 Capas

| Elemento | Paso | Color | Medidas (Large) | Comportamiento |
|---|---|---|---|---|
| Fondo | — | `negro` | 393 × 852 | Es el botón (`FullScreenControl`, 03 §4.5) |
| Horizonte (`SoundLine` en modo Noche) | — | `texto-noche` | 353 × 2, x 20-373, centro y 284 (= altura × 0,333; proporcional: SE 222, nunca absoluto; en AX se ancla bajo el reloj) | **Continuo = suena; ausente = en pausa.** Durante el fundido final sigue continuo (el estado lo dice con palabras). Al terminar la sesión desaparece en 2 s. Nunca lee el RMS: en Noche el único `TimelineView` es el del reloj, por minuto |
| Reloj | 1 · 72/80 Display Regular, tracking −1 %, `monospacedDigit()`; `relativeTo: .largeTitle`, tope AX2 | `texto-noche` | centrado, y 340-420 | Dentro de `TimelineView(.everyMinute)`: `Text(context.date, format: .dateTime.hour().minute())` → "03:07"; en formato de 12 h, `.hour(.defaultDigits(amPM: .omitted)).minute()` → "3:07" **sin sufijo** (en Noche siempre es de noche; el "am" lo lleva el estado, donde el sistema lo pone solo con `.shortened`). Cambia en seco por minuto. Opcional "Sin reloj" en Ajustes › Noche: la fila se vacía y nada se mueve de sitio |
| Estado | 3 · 22/28 **Medium** (Noche usa Medium, no Semibold) | `texto-noche` | centrado, y 436-464; 2 líneas en AX | "Se funde a las 03:42" ["Fades at 03:42"] · "Toda la noche" ["All night"] · "Fundiendo · 8 min" ["Fading · 8 min"] · "Hasta las 07:00" ["Until 07:00"] (Escudo) · "En pausa" ["Paused"] · "En pausa · auriculares" ["Paused · headphones"] · "En pausa · coche" ["Paused · car"] · "Terminó a las 00:42" ["Ended at 00:42"] · "Sin sonido" ["No sound"]. Cambio seco con 250 ms de opacidad (M6) |
| Frases de primera vez | 6 · 17/22 **Medium** | `texto-noche` | centradas, y 480-502 y 504-526; 10 s; solo la primera entrada en Noche de la instalación | "La pantalla puede dormir. El sonido sigue." ["The screen can sleep. Sound keeps playing."] y "Mantén pulsado para volver" ["Hold to go back"]. Son las dos únicas frases permitidas entre las 22:00 y las 07:00 (03 §4.12); no son TipKit (no hay fondo ni flecha), son dos `Text` que se funden en 250 ms. Van en paso 6 y no en 8 porque la segunda es la única enseñanza del gesto de salida y puede ocurrir por primera vez a las 3 de la mañana con el brillo al mínimo: 13 pt no se leería |
| Nota de 4 s "Nivel bajado al 40 para el altavoz" ["Level lowered to 40 for the speaker"] | 6 · 17/22 Medium | `texto-noche` | centrada, y 480-502 (la fila de las frases de primera vez; nunca coinciden: la primera vez no hay pausa por auriculares que reanudar) | Solo al reanudar por el altavoz con nivel > 40 (03 §1.3); 250 ms / 4 s / 250 ms (M12). No añade ningún estilo a la pantalla |
| "Seguir por el altavoz" ["Keep playing on the speaker"] | 4 · 20/25 Medium | `texto-noche` | 393 × 64, y 690-754, **encima** de "+15 min" (nunca en su lugar) | Solo durante 60 s tras una pausa por auriculares (03 §1.2). **Es la palabra que explica lo que el toque ya hace**: tocar en cualquier punto de la pantalla con "En pausa · auriculares" reanuda por la ruta actual con la regla del 40 en cualquier momento, no solo en esos 60 s (§4.3 regla 3). Desaparece sola a los 60 s sin mover nada |
| "+15 min" ["+15 min"] | 4 · 20/25 Medium | `texto-noche` | 393 × 64, y 754-818, a todo el ancho | Siempre en el mismo sitio y con la misma etiqueta (Escudo incluido). Toque = +15 sobre la hora de fin; el estado cambia a "Se funde a las 03:57" con `.numericText()` (la única vez que la cifra se anima; seca con Reduce Motion); `.selection` solo con el iPhone en la mano. **Con "Toda la noche" (Apagado) la fila queda vacía**: "+15" significa siempre "más", y pasar de infinito a 15 min sería "menos" a las 3 de la mañana; VoiceOver no ofrece "Añadir quince minutos" en ese estado. Tras "Terminó": reanuda la última mezcla 15 min con fundido de 3 s (ahí "+15" vuelve a ser "más"). En "Sin sonido": suma 15 a la hora de fin **y** reintenta arrancar; si el reintento falla, el estado sigue "Sin sonido" y la hora de fin no cambia |
| Regla vertical de volumen | — | `texto-noche` | 1 pt × 200, x 352, y 184-384 (centrada en el horizonte; la misma cota en Madrugada); aparece solo mientras dura el arrastre vertical | Longitud llena = nivel maestro: `engine.mainMixerNode.outputVolume` (ya existe; `buildGraph` lo fija a 1), que sirve también para el 0,6 de Madrugada y el 0,4 del altavoz sin tocar `EngineCommand` |
| Controles visibles de noche | 4 · 20/25 Medium | `texto-noche` | filas de 64 **apiladas encima** de "+15 min", que no se mueve: "−15 min" · "Pausa" en y 690-754, "Volver" en y 626-690 | §2.4 |

#### 2.2.3 Variantes del estado (mismo wireframe, solo cambia el contenido)

| Variante | Horizonte | Reloj | Estado | "+15 min" |
|---|---|---|---|---|
| Sonando, Hasta dormirme | continuo | 03:07 | Se funde a las 03:42 | sí |
| Sonando, Escudo | continuo | 03:07 | Hasta las 07:00 | sí (+15 sobre las 07:00) |
| Sonando, Siesta (solo por E1, de día) | continuo | 15:02 | Se funde a las 15:20 | sí |
| Sonando, sin temporizador | continuo | 03:07 | Toda la noche | **no: la fila queda vacía** (nada se mueve; no se crea nada) |
| Fundiendo (últimos 10 min; 2 en Siesta) | continuo | 03:34 | Fundiendo · 8 min | sí (cancela el fundido: `SleepAudioEngine.fadeIn(over: 0.8)` publica envolvente 1 y el estado pasa a "Se funde a las 03:57"; la Marea ya soltada sigue disolviéndose: +15 no la devuelve) |
| En pausa (toque) | ausente | 03:07 | En pausa | sí |
| En pausa · auriculares | ausente | 03:07 | En pausa · auriculares | sí, y encima "Seguir por el altavoz" 60 s; el toque reanuda por la ruta actual con la regla del 40 en cualquier momento |
| En pausa (interrupción del sistema: llamada, Siri, alarma fuera de 05:00-11:00, otra app) | ausente | 03:07 | En pausa | sí (la API no distingue la causa: §4.3) |
| En pausa · coche | ausente | 03:07 | En pausa · coche | sí |
| Terminó | ausente | 03:42 | Terminó a las 03:42 | sí (reanuda 15 min) |
| Sin sonido (error de audio) | ausente | 03:07 | Sin sonido | sí (+15 y reintenta); el toque en cualquier punto es el reintento puro |
| Con Marea guiando | continuo (la línea de agua **no** se dibuja) | 03:07 | Se funde a las 03:42 (el estado visual no cambia, 03 §4.3; la etiqueta de VoiceOver sí lo dice) | sí |

### 2.3 Pantalla 11 · Madrugada

La misma `FullScreenControl` con otra pregunta. Fondo `negro`, `texto-noche`, sin índice de ninguna clase (03 §3.2: Madrugada no tiene índice ni bajo el dedo, porque no hay nada que arrastrar salvo el volumen, y la regla de volumen es `texto-noche`). **Sin hora a propósito** ("Madrugada no enseña la hora a propósito." / "Small hours hides the clock on purpose.", frase de Ajustes; opt-in "Mostrar la hora en Madrugada").

#### 2.3.1 Wireframe · sonando con Marea, quedan 14 min

```
x: 0        20                                   373  393
y
   0   ┌─────────────────────────────────────────────┐  negro
       │                                             │
       │                                             │  ┐ banda de 120 (y 224-344): existe como geometría, NO se dibuja
 284   │ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~│  línea de agua · 1,5 pt · texto-noche · sube 4 s / baja 4,5 s / reposo 1,5 s (BreathCurve)
       │                                             │  ┘ sin marcas de pleamar / bajamar: la excursión de la línea ya enseña la banda
       │                                             │
 396   │                   14 min                    │  paso 1 · 72/80 Display Regular · tabular · texto-noche · centrado · y 396-476 (el mismo paso 1 de Noche)
       │                                             │
 492   │                   03:41                     │  SOLO con "Mostrar la hora en Madrugada" · paso 3 · 22/28 Medium · texto-noche · y 492-520
       │                                             │
       │         (toda la pantalla es el botón)      │
       │                                             │
 754   │                   Parar                     │  paso 4 · 20/25 Medium · texto-noche · botón 393 × 64 · y 754-818
 818   │                                             │
 852   └─────────────────────────────────────────────┘
```

Sin Marea audible (la mezcla no tiene Océano, §2.3.3): en su lugar está el horizonte de 2 pt `texto-noche` a y 284, continuo / ausente, como en Noche. Es lo único que cambia. Tres pasos tipográficos (1, 3, 4) y una sola tinta: en Madrugada solo se necesitan `texto-noche` y `negro`.

#### 2.3.2 Capas

| Elemento | Paso | Color | Medidas (Large) | Comportamiento |
|---|---|---|---|---|
| Fondo | — | `negro` | 393 × 852 | Es el botón: toque = pausa / reanuda (tras una pausa por auriculares, reanuda por la ruta actual con la regla del 40; Madrugada no ofrece "Seguir por el altavoz": si se caen los auriculares a las 4, se pausa y un toque reanuda); pulsación larga = **nada** (03 §4.5: a las 4 no hay "volver"; se sale bloqueando o con "Parar") |
| Línea de agua (`TideLine` en modo Madrugada) | — | `texto-noche`; **sin marcas** | 1,5 pt; banda 120 (y 224-344) como geometría; x 20-373 | `BreathCurve` del motor con `guide.anchor` + `outputLatency`: sube 4 s, baja 4,5 s, reposo 1,5 s (`BreathParameters.inhale / exhale` de `main`; 10 s por ciclo, 6 por minuto; la línea sigue al motor, nunca al copy: §9.13); reutiliza el `TimelineView` a 30 Hz pausable de `BreathIndicator`; Reduce Motion: posición fija a media banda (y 284), opacidad 0,6 → 1,0 con la misma curva; `scenePhase != .active`: quieta en bajamar en ≤ 2 s y 0 fotogramas. Durante la disolución (minutos 5-7 de guía; §4.2) la amplitud baja con la ganancia de la guía hasta quedarse en bajamar, y entonces se convierte en el horizonte de 2 pt (M19) |
| Horizonte (sin Marea audible) | — | `texto-noche` | 353 × 2, y 284 | Continuo = suena; ausente = en pausa |
| Cifra "14 min" ["14 min"] | 1 · 72/80 Display Regular, tracking −1 %, tabular; `relativeTo: .largeTitle`, tope AX2 | `texto-noche` | centrada, y 396-476 | Baja en seco por minuto, en el mismo `TimelineView` que dibuja la línea de agua (o `.periodic(from: endDate, by: 60)` sin Marea), con `Int(ceil(remaining / 60))`; al terminar dice "0 min" 2 s y después la pantalla se funde sola a la página nocturna (S10) |
| Hora (opt-in) | 3 · 22/28 Medium | `texto-noche` | centrada, y 492-520 | Solo con "Mostrar la hora en Madrugada" activado en Ajustes; por minuto; `accessibilityHidden(true)`: la hora va dentro de la etiqueta del elemento de pantalla completa |
| "Parar" ["Stop"] | 4 · 20/25 Medium | `texto-noche` | 393 × 64, y 754-818 | Fundido de 3 s y fin de Madrugada; sin háptica; la Live Activity vuelve a "terminada" (E6). Nunca "Pausar": a las 4, parar es lo que se busca (Grafito 13.1; 03 §4.5 y §5 lo fijan; la objeción del jurado de las 3 de la mañana va en §9.8) |
| Regla vertical de volumen | — | `texto-noche` | 1 × 200, x 352, y 184-384 (centrada en la banda; la misma cota que en Noche) | Como en Noche (`mainMixerNode.outputVolume`) |
| Controles visibles de noche (variante) | 4 | `texto-noche` | "+10 min" · "Pausa" en y 690-754 (dos de 164 × 64 con 24 de canal); "Parar" sigue en y 754-818 | §2.4 |

#### 2.3.3 Lo que Madrugada arranca (el modelo, para que la pantalla no mienta)

1. **La última mezcla que sonó**, al **60 %** de las ganancias con las que se durmió (`mainMixerNode.outputVolume = 0.6`), con **fundido de entrada de 3 s** (no 800 ms: a las 4 todo entra más despacio). En `main` hace falta `play(mode: .smallHours)`.
2. **La Marea a 6 por minuto, para todos** (03 §1.4), con la disolución a partir del minuto 5 (`guideMinutes = 5`, `dissolveSeconds = 120`, los valores que ya existen en `BreathingGuideController`): en Madrugada la Marea no es Pro ni en prueba ni fuera de ella. En `main`, `startBreathingIfEnabled` y `refreshEntitledAudio` exigen `settings.isEnabled` y `AccessPolicy.breathingIsIncluded`, y `refreshEntitledAudio` hace `breathing.end()` sin acceso: `play(mode: .smallHours)` llama a `breathing.begin()` con `guideMinutes = 5` sin mirar entitlement ni ajuste, y `refreshEntitledAudio` no termina la guía mientras `mode == .smallHours`. **Condición honesta:** en 1.0 la Marea v1 solo modula el Océano (`main`); si la última mezcla no tiene Océano (nivel 0), Madrugada **no sube el Océano** para forzarla (cambiar la mezcla a las 4 contradice "la última mezcla tal como la dejaste") y suena sin Marea; la línea de agua no se dibuja. Con Marea v2 (1.1, todas las texturas) la condición desaparece sola. Pregunta abierta en §9.
3. **20 minutos** (10 · 20 · 30 en Ajustes › Madrugada), con fundido final de **3 min** (minutos 17-20), igual que la salida de la guía. Ninguna Live Activity nueva por defecto (sería luz en la mesilla); la terminada se actualiza a "madrugada · 14 min" (`smallHours.liveActivityFormat` con `Text(timerInterval:)`) solo si ya estaba en pantalla (E6) **[spike I0-3]**.
4. **"+10 min"** (desde la Isla expandida, la acción de VoiceOver "Diez minutos más" o los controles visibles): como máximo dos veces (40 min). **Tras la segunda prolongación el botón desaparece por opacidad (250 ms, M25)** en los controles visibles y en la Isla expandida, su hueco queda vacío (nada se mueve) y la acción "Diez minutos más" se retira del rotor: un botón visible que no hace nada sería un instrumento que miente. Por la mañana, la línea de estado de la página dice una vez "Anoche Madrugada siguió hasta las 04:21." ["Last night Small hours ran until 04:21."] (E2).
5. **Nunca Pro, nunca "sin océano"**: si la última mezcla tenía capas Pro y la prueba terminó, suena sin ellas y no lo dice; lo dirá la página por la mañana con el título honesto ("Mar lento · sin Océano", E5). Siri tampoco lo dice (E6). **Sin capas libres** (la última mezcla era solo Pro, p. ej. Océano + Trueno): Madrugada arranca **Rosa a 40 × 0,6**, la misma regla que Play (03 §1.3: el instrumento siempre suena), sin Marea (no hay Océano libre: horizonte en vez de línea de agua), y por la mañana la línea de estado dice una vez "Anoche Madrugada sonó con Rosa: tu mezcla es Pro." ["Last night Small hours played Pink: your mix is Pro."] (`smallHours.morningPinkFallback`, E2). La cifra baja y el horizonte está continuo porque de verdad suena.
6. **Al terminar: nada.** Ni háptico, ni pantalla, ni notificación, ni pregunta por la mañana. No se cuenta cuántas veces se despertó nadie. Con la app delante, tras "0 min" 2 s la pantalla se funde sola a la página nocturna (S10).

### 2.4 "Controles visibles de noche" (variante de Noche y Madrugada)

Para quien no puede o no quiere hacer gestos. Se activan **solos** cuando `UIAccessibility.isSwitchControlRunning`, `UIAccessibility.isAssistiveTouchRunning` o `UIAccessibility.buttonShapesEnabled` son ciertos al entrar en Noche **[a medir: Full Keyboard Access no expone un indicador público; se cubre con el foco de teclado de §5(c)]**, y **a mano** en Ajustes › Noche › "Controles visibles de noche" ["Visible controls at night"]. **Nada de la pantalla cambia de sitio ni de tamaño**: "+15 min" sigue a todo el ancho en y 754-818 (es el botón de la prueba a ciegas y nunca se mueve); los controles añadidos se apilan **encima**, uno por fila de 64: "−15 min" · "Pausa" en y 690-754 (dos botones de 164 × 64 con 24 pt de canal muerto entre ellos, P8), "Volver" en y 626-690, y "Seguir por el altavoz", si coincide, en y 562-626 (el único caso de tres filas sobre "+15 min").

```
 626   │                   Volver                    │  paso 4 Medium · texto-noche · 393 × 64            (solo Noche)
 690   │        −15 min              Pausa           │  dos botones de 164 × 64 · paso 4 Medium · canal de 24 entre ellos
 754   │                  +15 min                    │  393 × 64 · el mismo botón de siempre, en el mismo sitio
 818   │                                             │
```

Sin líneas verticales: los botones se separan solo por el canal de 24 pt (03 §3.5: la hairline es horizontal, de margen a margen). El botón de pausa es una **palabra**, "Pausa" / "Seguir" ["Pause" / "Resume"], como el resto de la fila (03 §3.6: las palabras son los iconos; un glifo entre tres textos tendría otra afordancia bajo Button Shapes). En Madrugada la fila de y 690-754 dice "+10 min" · "Pausa" y "Parar" sigue en y 754-818; no hay "Volver" (no existe en Madrugada). Button Shapes: subrayado del sistema en todos los textos. Con Switch Control, el escaneo recorre: Volver → −15 min → Pausa → +15 min, y en primer lugar el elemento de pantalla completa, que sigue existiendo como botón único de pausa/reanuda y cuya única etiqueta es la frase de estado (§5(b)).

### 2.5 Acceso asistido (iOS 17) y Acceso guiado

La app declara `UISupportsFullScreenInAssistiveAccess = YES` y Noche / Madrugada se dibujan dentro del marco reducido que impone el sistema (con su botón "Atrás" grande abajo). Disposición de **un botón**: la pantalla entera es pausa / reanuda; los controles visibles se fuerzan (no hay pulsación larga ni arrastres en Acceso asistido); "Volver" no existe (el "Atrás" del sistema vuelve a la página). El horizonte, el reloj y el estado se mantienen; el reloj baja a 56 pt para que todo quepa en el marco **[a medir en dispositivo con Acceso asistido activado]**. Acceso guiado funciona sin que la app lo anuncie: no hay nota en Ajustes (un texto para enseñar a usar una función del sistema es un tip, y lo conoce quien lo usa).

---

## 3. Estados completos

Convención de 03 §4: normal · activo · bloqueado-Pro (sin castigo) · prueba · deshabilitado · VoiceOver, más los estados de sesión que estas pantallas tienen de propio. Cada estado dice qué se ve, qué suena y qué anuncia VoiceOver. Lo que no aparece en una tabla no existe en esa pantalla.

### 3.1 Temporizador (hoja)

| Estado | Qué se ve | Qué suena | VoiceOver anuncia |
|---|---|---|---|
| **Reposo** (nada suena) | 2.1.1: cabecera, tres modos, Apagado, hueco de control, pie; `checkmark` en el modo activo; sin cifra ni "+15 min" | Nada | "Temporizador, cabecera" y la lista |
| **Sonando** | 2.1.2: cifra "38 min" + "Se funde a las 00:42" + "+15 min" encima de la lista | La mezcla | Al abrir: "Quedan treinta y ocho minutos, se funde a las doce y cuarenta y dos" |
| **Fundiendo** | Cifra "8 min", debajo "Fundiendo"; el `checkmark` sigue; "+15 min" sigue (tocarlo cancela el fundido) | Nivel bajando con `.easeInOut` en el motor | "Fundiendo, ocho minutos" |
| **En pausa** | Cifra "En pausa", debajo "quedan 38 min"; todo lo demás igual | Nada (lo que queda está congelado) | "En pausa, quedan treinta y ocho minutos" |
| **Elegido un valor Pro sin acceso** (65-360 en la rueda; Escudo marcado) | La rueda gira; `‹pro›` junto a los valores; Escudo marcado con `checkmark` + `‹pro›` y su selector desplegado; **al cerrar la hoja**, hoja Pro encima de la página; al volver sin compra: la duración es 60 (o el modo anterior) y nada lo dice en pantalla (la fila dirá "60 min ✓" al reabrir) | Sigue lo que sonara: nada cambia | "Sesenta minutos; más de sesenta requiere Pro" (anuncio al volver) |
| **Prueba** (noches 1-7) | Idéntico a Pro: sin `‹pro›` en ningún sitio | — | — |
| **Día 8 con un valor Pro guardado** (`clampTimerToEntitlement`) | El cambio ocurre **al arrancar la sesión del día 8**, no al abrir la hoja. Duración > 60: la fila "Hasta dormirme" dice "60 min" y, una sola vez, en paso 7 debajo: "antes 90 · más de 60 es Pro" ["was 90 · beyond 60 is Pro"]. Escudo activo: el modo pasa a "Hasta dormirme · 60" y la fila dice, una sola vez y en el mismo sitio: "antes Escudo · el Escudo es Pro" ["was Shield · the Shield is Pro"]; Escudo vuelve a `‹pro›` | Si el Escudo estaba corriendo al caducar, **no se corta**: la prueba se evalúa al arrancar la sesión, nunca a medianoche ni al reanudar (03 §1.3, Dial); `clampTimerToEntitlement` se llama solo al terminar la sesión | "Sesenta minutos, antes noventa" / "Sesenta minutos, antes Escudo nocturno" |
| **Deshabilitado** | No existe: ninguna fila se deshabilita (03 §4.7) y la hoja no tiene ningún control de tienda ("La tienda no responde" vive en la hoja Pro, E5) | — | — |
| **Error de audio** | La hoja no cambia: el error vive en la página (E5, escalera de Dial) | — | — |
| **Vacío / cargando / sin red** | No aplican: la hoja no carga nada; sin red todo funciona salvo comprar | — | — |

### 3.2 Noche

| Estado | Horizonte | Estado (palabra) | Qué suena | Entrada al estado | VoiceOver (etiqueta del elemento único) |
|---|---|---|---|---|---|
| **Sonando** | continuo | "Se funde a las 03:42" / "Hasta las 07:00" / "Toda la noche" | La mezcla | Entrar en Noche con la sesión sonando | "Sonando, quedan treinta y cinco minutos, las tres y siete"; con Marea guiando: "Sonando, guiando a seis por minuto, quedan treinta y cinco minutos, las tres y siete" |
| **Fundiendo** | continuo | "Fundiendo · 8 min" | Nivel bajando; la Marea soltada | Últimos 10 min (2 en Siesta) | "Fundiendo, ocho minutos, las tres y treinta y cuatro" |
| **En pausa** (toque) | ausente | "En pausa" | Nada; lo que queda, congelado | Toque válido (§4.1) | "En pausa, quedan treinta y cinco minutos; toca dos veces para reanudar" |
| **En pausa** (interrupción del sistema) | ausente | "En pausa" | Nada | §4.3 filas 1-4, 9 | "En pausa, quedan treinta y cinco minutos; toca dos veces para reanudar" |
| **En pausa · causa** | ausente | "En pausa · auriculares" / "· coche" | Nada | §4.3 filas 5, 8 | "En pausa, auriculares desconectados, quedan treinta y cinco minutos; toca dos veces para seguir por el altavoz, como mucho al cuarenta" |
| **Pausa larga** (20 min en pausa) | ausente | "Terminó a las 03:12" | Nada; la sesión termina (`endPlayback(canDowngrade: true)`) al siguiente despertar del proceso (§4.3 regla 7), la Live Activity ofrece Madrugada | 20 min en cualquier pausa | "Terminó a las tres y doce" |
| **Terminó** | ausente (desaparece en 2 s) | "Terminó a las 03:42" | Nada | Fin del fundido | El elemento pasa a `.staticText`: "Terminó a las tres y cuarenta y dos"; la pista "Toca dos veces en Más quince minutos para seguir" se mueve al botón "+15 min" |
| **Sin sonido** (error) | ausente | "Sin sonido" | Nada | El motor cae con Noche delante; un reintento silencioso a los 2 s (Dial 9.12); si falla, este estado | "Sin sonido; toca dos veces para intentarlo otra vez" |
| **Primera vez** | como Sonando | como Sonando + las dos frases 10 s | La mezcla | Primera entrada en Noche de la instalación | La etiqueta más la pista "Mantén pulsado para volver" |
| **Bloqueado-Pro / prueba** | No aplican: en Noche no hay nada Pro ni nada que se venda | | | | |
| **Deshabilitado** | No aplica | | | | |
| **Vacío** | No existe: Noche no se abre sin sonido (§4.1: "Noche" con la sesión parada arranca el sonido). Si la sesión se para desde otra superficie con Noche delante, Noche pasa a "En pausa" o a "Terminó", nunca a vacío | | | | |
| **Cargando / sin red** | No aplican | | | | |

### 3.3 Madrugada

| Estado | Línea de agua / horizonte | Cifra | Qué suena | VoiceOver |
|---|---|---|---|---|
| **Arrancando** (0-3 s) | La línea de agua nace de la hairline en 3 s (M17) | "20 min" | Fundido de entrada de 3 s al 60 % | "Madrugada, veinte minutos" |
| **Guiando** (min 0-5) | Línea de agua respirando a 6 por minuto | baja por minuto | Mezcla + Marea a peso 1 | "Madrugada, respirando a seis por minuto, quedan catorce minutos; toca dos veces para pausar" |
| **Disolviendo** (min 5-7) | Amplitud → 0 en 120 s; queda 2 s en bajamar y se vuelve horizonte | baja | La Marea se retira; la mezcla sigue | "Madrugada, quedan trece minutos" |
| **Sonando sin guía** (min 7-17) | Horizonte 2 pt continuo | baja | La mezcla al 60 % | igual |
| **Fundido final** (min 17-20) | continuo | "3 min" → "0 min" | Nivel → 0 en 3 min | "Madrugada, fundiendo, tres minutos" |
| **Terminó** | ausente | "0 min" 2 s; después la pantalla se funde sola a la página nocturna en 2 s (S10) | Nada | Elemento `.staticText` "Terminó" (una vez, prioridad baja); el toque no hace nada mientras tanto |
| **En pausa** (toque, o auriculares desconectados) | ausente (la línea de agua se funde en 2 s) | se queda | Nada | "En pausa; toca dos veces para reanudar" (por auriculares: "…para seguir por el altavoz, como mucho al cuarenta") |
| **Parado** ("Parar") | ausente | nada | Fundido de 3 s y fin | "Parado" |
| **Sin Marea audible** | Horizonte 2 pt en lugar de la línea de agua | igual | Mezcla sin Océano | sin "respirando" en la etiqueta |
| **Sin capas libres** (la última mezcla era toda Pro) | Horizonte 2 pt | igual | Rosa a 40 × 0,6 (03 §1.3); por la mañana la página lo dice una vez (`smallHours.morningPinkFallback`) | "Madrugada, quedan catorce minutos" |
| **Con hora** (opt-in) | igual | igual + "03:41" | igual | añade "las tres y cuarenta y uno" dentro de la etiqueta |
| **Bloqueado-Pro / prueba** | **No existen.** Madrugada es igual para todos; si la mezcla tenía capas Pro y no hay acceso, suena sin ellas y no lo dice | | | |
| **Sin sonido** (error) | ausente | "Sin sonido" en el lugar de la cifra (paso 1) | Nada | "Sin sonido; toca dos veces para intentarlo otra vez" |

---

## 4. Flujos

### 4.1 Noche · entradas y salidas (tabla completa)

**Entradas.** Todas con la transición de 2 s por opacidad (250 ms con Reduce Motion; 03 §3.7). Noche no se abre en silencio y no tiene un estado muerto: la palabra "Noche" de la barra funciona **siempre**; con la sesión parada arranca la mezcla cargada (fundido de 800 ms; si es toda Pro, Rosa a 40, 03 §1.3) y entra en Noche en el mismo gesto. Las entradas automáticas exigen una sesión sonando o en pausa. Nunca se entra con una hoja abierta (Temporizador, Marea, Pro, Capas, Mezclas): la hoja manda, y al cerrarla el contador de 60 s vuelve a cero.

| # | Entrada | Condición | Qué pasa | Qué dice la pantalla al llegar |
|---|---|---|---|---|
| E1 | Palabra "Noche" ["Night"] en la barra inferior (17 Medium; la barra es de E2) | Siempre. Sonando o en pausa: entra. Parada: Play (800 ms) + entra | Fundido de 2 s página → negro; el reloj y el estado aparecen por opacidad; nada se desplaza. VoiceOver con la sesión parada: "Noche, botón; toca dos veces para sonar y pasar a Noche" | El estado real: "Se funde a las 03:42" / "En pausa" / "Toda la noche" |
| E2 | Bloquear el iPhone con la sesión sonando | Sonando; modo distinto de Siesta; **entre las 20:00 y las 09:00** (la misma ventana que E3); la app delante o detrás. Señal: `UIApplication.protectedDataWillBecomeUnavailableNotification` (bloqueo con código); sin código, `scenePhase == .background` dentro de la ventana | Al desbloquear, la app enseña Noche, no la página (el bloqueo es la señal de "ya acostado"). Con "Pasar a Noche sola · Nunca" también: bloquear es un gesto explícito | El estado real |
| E3 | 60 s sin tocar la pantalla con la app delante y la sesión sonando | Ajustes › Noche › "Pasar a Noche sola · 1 min / 3 min / Nunca" (1 min por defecto); **solo entre las 20:00 y las 09:00** (de día, con la app delante, nadie quiere una pantalla negra; la Siesta no entra sola jamás) | Igual que E1 | El estado real |
| E4 | Focus de Sueño activo con la app delante (1.1, E6) | El filtro "Abrir en Noche" | Igual que E1 | El estado real |
| E5 | Toque en la Live Activity fuera de sus botones (E6) | Sonando o en pausa | `widgetURL` → la app abre en Noche | El estado real |
| E6 | Atajo "Noche en SleepNoise" (E6) | Sonando o en pausa | Abre la app en Noche; si no suena nada, Siri dice "No está sonando nada." ["Nothing is playing."] y no abre nada | — |
| E7 | Desbloquear con Noche delante | Siempre | Noche sigue; **guarda de 300 ms** (`protectedDataDidBecomeAvailableNotification`): ningún toque cuenta en los 300 ms siguientes al desbloqueo (el pulgar que desbloquea y toca) | Lo que había |

Lo que **no** es una entrada, a propósito: deslizar hacia abajo en la página (03 §6: ningún arrastre de "persiana"; el gesto compite con el Centro de notificaciones), la quietud del iPhone por CoreMotion (1.1, prototipo), abrir la app desde el icono (icono = página; bloqueo = Noche), el fin de la prueba, cualquier hora del reloj por sí sola, bloquear durante una Siesta o de día.

**Salidas.**

| # | Salida | Gesto / causa | Qué pasa | A dónde |
|---|---|---|---|---|
| S1 | Pulsación larga en cualquier punto | Dedo quieto (tolerancia 10 pt) **entre 0,6 y 2 s; se dispara al soltar**. Un contacto de más de 2 s (una mano o una mejilla apoyadas) no hace nada: "ignorado boca abajo" no cubría la mano apoyada boca arriba | `.impact(.light, 0.4)` al cumplirse 0,6 s (la única háptica de Noche: aquí el sonido no cambia y hace falta un "ya"); fundido de 250 ms al soltar | **Página nocturna** entre las 22:00 y las 07:00 (una tinta, `texto-noche`; vuelve a Descenso al tocar el nombre de la mezcla o a las 07:00; E2); página en Descenso el resto del día |
| S2 | Acción de VoiceOver "Volver a la página" / gesto de escape (Z con dos dedos) | VoiceOver | Igual que S1, con anuncio "Página" | Igual |
| S3 | Botón "Volver" de los controles visibles | Toque | Igual que S1 | Igual |
| S4 | Bloquear el iPhone | Botón lateral o auto-bloqueo | La pantalla se apaga; **la app no hace nada** (0 fotogramas: `scenePhase == .background`); al desbloquear, Noche sigue (E7) | Noche |
| S5 | Fin de la sesión (fundido completo, "Terminó a las 03:42") | Reloj del temporizador | El horizonte desaparece en 2 s; el estado dice "Terminó a las 03:42"; el reloj sigue; "+15 min" sigue y reanuda 15 min; el toque **no** hace nada (evita arranques con la mejilla) y el elemento de VoiceOver pasa a `.staticText`. La pantalla se apaga por el ajuste del sistema. Si por la mañana la app sigue delante y son más de las 07:00, Noche se funde sola a la página en Descenso en 2 s | Noche terminada → página a las 07:00 |
| S6 | Pausa larga (20 min en pausa) | Reloj, evaluado al siguiente despertar (§4.3 regla 7) | Igual que S5 con "Terminó a las 03:12" (la hora calculada `pausedAt + 20 min`, que es la que se enseña) | Igual |
| S7 | Hoja del sistema encima (llamada entrante, alarma) | Sistema | Noche no se cierra; al volver, Noche en pausa o sonando según §4.3 | Noche |
| S8 | Acceso asistido: "Atrás" del sistema | Sistema | Página en luminancia nocturna | Página |
| S9 | Error fatal del motor sin recuperación (§4.3, fila 11) | `mediaServicesWereReset` sin reconstrucción posible | "Sin sonido"; Noche se queda; un toque reintenta | Noche |
| S10 | Fin de Madrugada con la app delante | `onComplete` de Madrugada | Tras "0 min" 2 s, la capa se funde sola a la página nocturna en 2 s (la misma mecánica que S5 a las 07:00); mientras tanto el toque no hace nada y el elemento de VoiceOver dice "Terminó" sin rasgo `.button`. Nada vibra ni suena | Página nocturna |

Lo que **no** es una salida: el toque (es pausa), el arrastre hacia abajo o hacia arriba (no existen gestos verticales de navegación: el vertical es volumen), el doble toque (03 §1.2), tocar el reloj, el fin de la prueba, una notificación.

### 4.2 Flujos paso a paso

**4.2.1 Elegir el temporizador y dormirse (noche 3, prueba).** 23:10. La página dice "Rosa y lluvia" y la fila "Temporizador · Hasta dormirme · 45 min" (E2). Toca la fila → hoja `.medium` (2.1.1) con "Hasta dormirme" marcada. Toca "Duración" → la rueda se despliega bajo el hueco de control, la hoja pasa a `.large`; gira a 60; toca fuera de la rueda: se pliega, la hoja vuelve a `.medium`; la fila dice "60 min"; `.selection` del sistema en la rueda, nada propio. Arrastra la hoja hacia abajo. La página: "Sonando · se funde a las 00:10" en cuanto toca el Disco (`.impact(.medium, 0.7)` al inicio del fundido de 800 ms). Bloquea el iPhone: la Live Activity (E6) muestra "Rosa y lluvia · 60 min" con pausa y "+15 min". A los 50 min el motor empieza el fundido de 10 min; la actividad pasa a "fundiendo". A las 00:10 el motor para; `activity.end(content, dismissalPolicy: .after(Date().addingTimeInterval(4 * 3600)))` la deja como terminada con "madrugada · 20 min" hasta 4 h. Nada vibra. Nadie se entera.

**4.2.2 Entrar en Noche y prolongar a ciegas.** 23:40, ha vuelto a coger el iPhone porque no se dormía. Está en Noche (E2: bloqueó sonando a las 23:12). Lee "Se funde a las 00:10" a un metro. Toca "+15 min" sin mirar bien (64 pt a todo el ancho, abajo, donde cae el pulgar): el estado pasa a "Se funde a las 00:25" con `.numericText()`; `.selection` porque el iPhone está en la mano (CoreMotion **[spike I0-5]**; sin la señal, ninguna háptica). Deja el iPhone en la mesilla: la pantalla se apaga sola a los 30 s (su ajuste). A las 00:15 el fundido empieza; el Disco de la Live Activity hace `.pulse` (E6; apagado con Reduce Motion).

**4.2.3 Pausar en Noche y reanudar.** 02:50, ruido en la calle; quiere silencio un momento. Levanta el iPhone (raise to wake), Face ID, Noche. Espera sin querer 300 ms (la guarda). Toca: el horizonte desaparece en 250 ms, el estado dice "En pausa", el sonido se funde en 1,5 s (`pause(resumeLater:fadeOut: 1.5)`: la pausa por toque es la única que puede fundir, porque el render sigue corriendo; las de ruta e interrupción cortan en 40 ms, §4.3). Ninguna háptica: el silencio lo confirma. Dos minutos después toca otra vez: el horizonte vuelve, el sonido en 800 ms, el estado "Se funde a las 03:44" (los dos minutos de pausa se han añadido: lo que queda estaba congelado). Si no vuelve a tocar, a las 03:10 (20 min en pausa) la sesión termina: "Terminó a las 03:10", y la actividad ofrece Madrugada.

**4.2.4 Madrugada desde la Live Activity terminada.** 03:41. Se despierta. El temporizador terminó a las 00:25. Levanta el iPhone: en el bloqueo, la actividad terminada (hasta 4 h) dice "Rosa y lluvia · terminó a las 00:25" y, en su botón de texto, "madrugada · 20 min" con `play.fill` **[spike I0-3: `AudioPlaybackIntent` sobre una actividad terminada]**. Lo toca: no se abre nada. Oye la mezcla entrar en 3 s al 60 % con la Marea a 6 (si la mezcla tiene Océano; si la mezcla era toda Pro, Rosa a 40). La actividad pasa a "madrugada · 20 min" con pausa. Deja el iPhone. Minuto 5: la guía se disuelve en 2 min. Minuto 17-20: fundido final. Minuto 20: silencio; la actividad vuelve a "terminada". Si en el minuto 12 desbloquea para mirar, la app abre en **Madrugada** (2.3.1): sin hora, la línea de agua ya convertida en horizonte, "8 min", "Parar". Nada más. Si la actividad ya expiró (más de 4 h): el control "Madrugada" del Centro de control o el botón de Acción (iOS 18), o Siri "Madrugada en SleepNoise" (la voz a las 4 es la peor opción y se documenta como la última). Abrir la app desde el icono a esa hora **no** es Madrugada: abre la página nocturna con el Disco (icono = página).

**4.2.5 Escudo nocturno, una noche entera (Pro).** 23:30, "Hasta las 07:00". La página: "Sonando · hasta las 07:00". Noche: "Hasta las 07:00". 01:30 (segunda hora en punto): el nivel maestro baja un 6 % con rampa de 60 s; 02:30 otro 6 %; … hasta el 50 % como mínimo (a las 07:00 habría bajado ocho veces: se detiene en el 50 %). 06:50: fundido de 10 min. 07:00: silencio; la actividad se cierra. Si la alarma de Reloj suena a las 06:45: el sistema interrumpe, la app termina la sesión (05:00-11:00, §4.3), la actividad se cierra, y la página de la mañana dice "Terminó a las 06:45" (la regla va por reloj, no por causa: la app no sabe que fue la alarma). La app nunca ha tocado la alarma.

**4.2.6 El día 8 abre el temporizador.** Tenía 90 min. Al arrancar la sesión del día 8 la duración pasó a 60. La fila dice "Hasta dormirme · 60 min" y, una vez, "antes 90 · más de 60 es Pro". Escudo lleva `‹pro›`. Toca Escudo por curiosidad: la fila se marca y el `DatePicker` se despliega igual que siempre con su hora de las 07:00 recordada. Cambia de idea, toca "Hasta dormirme" otra vez y cierra la hoja: nada se vende (no había ningún valor Pro vigente al cerrar). Pone Play: 60 min, blanco, rosa, marrón, lluvia. El día 8 se parece al día 7 (03 §7.10). **Variante Escudo:** tuvo el Escudo activo siete noches. Al arrancar la sesión del día 8 el modo pasa a "Hasta dormirme · 60" y, cuando abre la hoja, bajo esa fila lee una vez "antes Escudo · el Escudo es Pro"; VoiceOver: "Sesenta minutos, antes Escudo nocturno".

### 4.3 Interrupciones (tabla completa)

Reglas transversales, antes de la tabla:

1. **Lo que queda se congela en cualquier pausa** y la hora de fin se recalcula al reanudar (`SleepTimerController.pause()` ya lo hace; la Live Activity usa `Text(timerInterval:pauseTime:)`). Se descarta la alternativa "la hora de fin es fija aunque se pause" (Dial, Silencio) por añadir una segunda regla que el usuario tendría que aprender.
2. **Entre las 05:00 y las 11:00 una interrupción del sistema termina la sesión en lugar de pausarla** (03 §1.3, Dial): es la alarma de la mañana, y reanudar el ruido tras descartarla es un error de producto. La regla va **por reloj, no por causa**: la API no dice si fue la alarma. Fuera de esa ventana, la interrupción pausa y reanuda si el sistema lo pide (`shouldResume`).
3. **Nunca se reanuda solo por el altavoz por encima de 40.** Si la ruta al reanudar es el altavoz del iPhone y el nivel maestro es > 40, se reanuda a 40 y se dice (`mainMixerNode.outputVolume = 0.4`). Tras una pausa por auriculares, reanudar ocurre: sola si los auriculares vuelven con la app delante; o **con un toque en cualquier superficie** (Noche, Madrugada, página, Live Activity) por la ruta actual con la regla del 40, en cualquier momento. "Seguir por el altavoz" (Noche y página, 60 s; 03 §1.2) es la palabra visible de esa misma acción, no una acción distinta: quien se despierta cinco minutos después de perder un AirPod ve "En pausa · auriculares", toca, y suena.
4. **Nada se anuncia con sonido ni háptica**: la llamada, la alarma o los AirPods ya han hecho bastante.
5. **La prueba no se evalúa al reanudar** (`play(userInitiated: false)` → `canDowngrade: false`, ya en `main`).
6. **La Marea reanuda en su ventana** (`breathing.resume()`, ya en `main`): si la guía terminó durante la pausa, no vuelve.
7. **Las reglas de los 20 min son perezosas.** Tras cualquier pausa `engine.stop` desactiva la sesión y, sin audio activo, iOS suspende el proceso en segundos: ningún timer de la app dispara a los 20 min. Se guarda `pausedAt`; "Terminó a las …" se evalúa en el siguiente despertar (foreground, intent de la Live Activity, `.ended`, cambio de ruta con la app delante) con la hora calculada `pausedAt + 20 min`, que es la que se enseña. La Live Activity pasa sola a "terminada" con `staleDate = pausedAt + 20 min` (ActivityKit pinta el estado stale sin la app). La reanudación automática al volver los auriculares existe solo mientras la app está delante; si no, es el botón de play de la actividad. (Para I0, §9.)
8. **Las causas son las que da la API.** `AVAudioSession.interruptionNotification` trae solo `.began` / `.ended`, `.shouldResume` y, desde iOS 17, `AVAudioSessionInterruptionReasonKey` (`.default`, `.routeDisconnected`, `.builtInMicMuted`). No distingue llamada, Siri, alarma ni "otra app": el estado dice "En pausa" a secas. Las dos causas reales son **auriculares** (`.routeDisconnected`, o `.oldDeviceUnavailable` en iOS 16) y **coche** (puerto `carAudio`). `AudioSessionObserver` lee `AVAudioSessionInterruptionReasonKey` para que `.routeDisconnected` vaya a `onHeadphonesUnplugged` (hoy etiquetaría quitarse los AirPods como una interrupción cualquiera).
9. **Las pausas por ruta e interrupción cortan en 40 ms** (`engine.stop(fadeOut: 0.04)`, como `main`): al llegar `.oldDeviceUnavailable` la ruta ya ha cambiado al altavoz y `AVAudioEngine` se rearma solo (`observeConfigurationChanges` → `restartIfWanted`); un fundido de 1,5 s serían 1,5 s de ruido por el altavoz a las 3 de la mañana. Al recibir `.began` el sistema ya ha silenciado la app y el render no corre: lo que dura 300 ms es la opacidad del horizonte, no el sonido. Solo la pausa por toque funde (1,5 s): `pause(resumeLater:fadeOut:)` con 1,5 para el toque y 0,04 para rutas e interrupciones.

| # | Interrupción | Señal | Qué hace el sonido | Qué dice la pantalla (Noche · página · Madrugada) | Qué dice la Live Activity (E6) | Al terminar la interrupción |
|---|---|---|---|---|---|---|
| 1 | **Interrupción del sistema** (llamada, FaceTime, Siri, alarma o temporizador fuera de 05:00-11:00, otra app que toma la sesión) | `interruptionNotification .began` sin `.routeDisconnected` | El sistema para nuestro audio en el instante del `.began`; lo que queda se congela | Noche: horizonte ausente en 300 ms, "En pausa" ["Paused"] · Página: "En pausa" en la línea de estado, Disco en play · Madrugada: línea de agua / horizonte ausente, cifra se queda | "en pausa", botón en play, tiempo en pausa | `.ended` con `shouldResume` y fuera de 05:00-11:00: reanuda con 800 ms, horizonte vuelve, estado "Se funde a las 03:57". Sin `shouldResume` (colgó desde otro sitio, eligió otra app): se queda en pausa; un toque reanuda; a los 20 min termina (regla 7). Entre 05:00 y 11:00: termina la sesión, "Terminó a las 07:02" |
| 2 | **Alarma del sistema, 05:00-11:00** (la app no sabe que es la alarma: es la ventana) | `.began` entre las 05:00 y las 11:00 | Para; **la sesión termina** al `.ended` o en el siguiente despertar del proceso | Noche: "Terminó a las 06:45" ["Ended at 06:45"]; la pantalla se funde a la página en Descenso a las 07:00 si sigue delante · Página: línea de estado "Terminó a las 06:45" · Madrugada: igual que Noche | "terminó a las 06:45", sin botón de Madrugada (es de día) | Nada se reanuda. `endPlayback(canDowngrade: true)` |
| 3 | **AirPods fuera de la oreja / desconectados / sin batería** (también cualquier auricular o altavoz Bluetooth) | `.began` con `.routeDisconnected` (iOS 17+) o `routeChange .oldDeviceUnavailable` | **Corte en 40 ms**: un fundido sonaría por el altavoz. El horizonte desaparece en 250 ms (M3) | Noche: "En pausa · auriculares" ["Paused · headphones"] y, encima de "+15 min", **"Seguir por el altavoz"** ["Keep playing on the speaker"] durante 60 s · Página: lo mismo en la línea de estado con el botón de texto debajo · Madrugada: horizonte ausente, sin fila extra (un toque reanuda) | "en pausa · auriculares"; el botón de pausa/play sigue (tocarlo = reanudar con la regla del 40) | Si los auriculares vuelven con la app delante (`.newDeviceAvailable` con la misma ruta): reanuda sola con 800 ms. Un toque en cualquier superficie: reanuda por la ruta actual a ≤ 40 ("Nivel bajado al 40 para el altavoz" ["Level lowered to 40 for the speaker"] 4 s en la fila de y 480, paso 6 Medium). Si no: 20 min en pausa → termina (regla 7) |
| 4 | **Pausa de AirPods al dormirse** (iOS 26, "Pausar al dormirse") | `pauseCommand` de Now Playing **[spike I0-4]**: es el mismo comando que la pausa manual desde el bloqueo o el tallo; no hay señal que los distinga | Fundido de **3 s de audio y 2 s de interfaz** si el comando llega con el motor corriendo (la interfaz acaba antes para que nada se mueva en una pantalla que se va a apagar) | "En pausa" sin causa (etiquetarla sería adivinar) en Noche, página y Madrugada | "en pausa" | **No reanuda sola.** A los 20 min la sesión termina (regla 7) y la actividad ofrece Madrugada. Un toque en cualquier superficie reanuda (por la misma ruta si los AirPods siguen conectados; si no, regla del 40) |
| 5 | **Altavoz del iPhone con nivel > 40 al reanudar** | Ruta `builtInSpeaker` al `play` tras una pausa | Reanuda a **40** (regla 3) | "Nivel bajado al 40 para el altavoz" 4 s (Noche, fila de y 480; página, línea de estado); Madrugada: nada (ya va al 60 % × 0,4) | nada | — |
| 6 | **CarPlay / audio del coche** | `routeChange .newDeviceAvailable` con puerto `carAudio` | Corte en 40 ms (ruido blanco por sorpresa en el coche a las 07:30 no es lo que nadie quiere); SleepNoise no tiene app de CarPlay | "En pausa · coche" ["Paused · car"] en la línea de estado de la página; Noche: igual | "en pausa · coche" | Reanuda solo a mano (Disco, Now Playing del coche). Al desconectar el coche (`.oldDeviceUnavailable`) no reanuda |
| 7 | **Notificación con sonido, Siri de otra persona cerca, ducking** | El sistema atenúa (`mixWithOthers` no; `.playback` recibe ducking solo si el otro lo pide) | Nada: la app no reacciona a atenuaciones | Nada | Nada | — |
| 8 | **El motor cae en mitad de la noche** (`mediaServicesWereReset`, `AVAudioEngineConfigurationChange`) | `onMediaServicesReset` / cambio de configuración | Reconstruye el grafo y reanuda **una vez** con 800 ms (ya en `main`). Si falla: la sesión termina. Sin watchdog de callbacks: necesitaría un latido render → main que `ParameterMailbox` no tiene (es de un solo sentido) y las dos señales del sistema ya cubren los fallos conocidos | Noche / Madrugada: "Sin sonido" ["No sound"]; un toque reintenta · Página: la escalera de Dial sin rojo (E5): "No se pudo arrancar el sonido. Toca el Disco para intentarlo." | "se detuvo a las 02:14" ["stopped at 02:14"] con play; se queda 30 min | Por la mañana la página dice una vez "Anoche el sonido se detuvo a las 02:14 por un error. Nos gustaría saberlo: Enviar informe." (E5) |
| 9 | **Batería baja del iPhone (modo de bajo consumo)** | `ProcessInfo.isLowPowerModeEnabled` | Nada: el audio sigue; la línea de agua pasa a Reduce Motion (opacidad) para ahorrar | Nada | Nada | — |
| 10 | **Cambio de ruta a AirPlay / HomePod** | `.newDeviceAvailable` + `outputLatency` hasta 2 s | Sigue sonando; la línea de agua compensa la latencia con `guide.anchor` + `outputLatency` para que lo que se ve coincida con lo que se oye en la habitación | Nada | Nada | La Marea háptica se desactiva en esa ruta (no se puede sincronizar con 2 s de retraso) |
| 11 | **Pantalla apagada / Always-On** | `scenePhase` | Nada | Noche y Madrugada: 0 fotogramas con `scenePhase == .background`. En iPhone, Always-On enseña la pantalla de bloqueo, nunca la app: lo único que se ve es la Live Activity (E6, `isLuminanceReduced`) | — | Al despertar la pantalla, la línea de agua vuelve a respirar desde el ancla del motor (sin saltos) |

Durante **cualquier** pausa de la tabla, el elemento de VoiceOver de Noche cambia su etiqueta a "En pausa[, <causa>], quedan n minutos" y la pista a "Toca dos veces para reanudar"; en las filas 3 y 6 la pista es "Toca dos veces para seguir por el altavoz, como mucho al cuarenta".

---

## 5. Las cinco tablas obligatorias

### 5(a) Movimiento · elemento → señal del motor → duración / curva → Reduce Motion → pantalla apagada / fondo

Regla madre (03 §3.7): nada se mueve sin señal del motor o sin dedo; **nada cambia de posición jamás**, solo longitud, grosor, opacidad o contenido. En estas tres pantallas hay dos `TimelineView`: el del reloj de Noche (por minuto) y el de la línea de agua de Madrugada (30 Hz, pausable), que también sirve a la cifra de Madrugada. **Always-On no aplica a ninguna fila**: en iPhone, Always-On enseña la pantalla de bloqueo (fondo, widgets, Live Activity), nunca la app; `isLuminanceReduced` solo le importa a la Live Activity (E6). Con `scenePhase == .background`, 0 fotogramas.

| # | Elemento | Qué cambia | Señal del motor / causa | Duración · curva | Reduce Motion | Pantalla apagada / fondo |
|---|---|---|---|---|---|---|
| M1 | Página → Noche (entrada) | Opacidad de la capa Noche del `ZStack` 0 → 1: la página se funde a negro; horizonte (2 pt), reloj, estado y "+15 min" aparecen por opacidad en su sitio definitivo; el `TimelineView` del horizonte de la página se pausa | Gesto (E1/E3/E5/E6) o desbloqueo (E2) | 2 s · `.easeInOut` (03 §3.7) | 250 ms · opacidad | No aplica (la pantalla está encendida) |
| M2 | Noche → página (salida) | Inversa | Pulsación larga / acción / "Volver" / S10 | 250 ms · `.easeInOut` (S1-S3); 2 s en S5 y S10 | Igual / 250 ms | — |
| M3 | Horizonte de Noche: continuo ↔ ausente | Opacidad 1 ↔ 0 de la línea entera | `isPlaying` del motor (`.began` / `.ended` / toque / ruta) | 250 ms · `.easeInOut` (la ganancia tarda 1,5 s en la pausa por toque, 40 ms en rutas e interrupciones y 800 ms al reanudar; la línea no sigue la ganancia: es estado, no nivel) | Igual (ya es opacidad) | 0 fotogramas |
| M4 | Horizonte de Noche: fin de sesión | Opacidad → 0 | `onComplete` del temporizador | 2 s · `.easeInOut` | Igual | Igual |
| M5 | Reloj de Noche | Contenido "03:07" → "03:08" | `TimelineView(.everyMinute)` (reloj del sistema, no del motor: es la única excepción permitida, porque es la hora) | Cambio seco; 0 ms | Igual | 0 fotogramas (el `TimelineView` se pausa en fondo) |
| M6 | Estado de Noche (palabra) | Contenido; opacidad cruzada | Estado de sesión (`isPlaying`, `isFading`, causa de pausa, `onComplete`) | 250 ms · opacidad | Igual | 0 fotogramas |
| M7 | Estado de Noche al tocar "+15 min" | Los dígitos de la hora de fin | Dedo | `.contentTransition(.numericText())` del sistema | Cambio seco | — |
| M8 | Cifra de la hoja Temporizador ("38 min") | Contenido | `TimelineView(.periodic(from: endDate, by: 60))`; `remaining = endDate - now` calculado bajo demanda | Seco, por minuto, alineado con la hora de fin | Igual | — (hoja: la pantalla está encendida) |
| M9 | Cifra de Madrugada ("14 min") | Contenido | El mismo `TimelineView` de la línea de agua (o `.periodic(from: endDate, by: 60)` sin Marea) | Seco, por minuto | Igual | 0 fotogramas |
| M10 | Frases de primera vez en Noche | Opacidad 0 → 1 → 0 | Primera entrada | 250 ms · aparecen; 10 s; 250 ms · desaparecen | Igual | — |
| M11 | "Seguir por el altavoz" | Opacidad 0 → 1 → 0 en su fila | `.routeDisconnected` / `.oldDeviceUnavailable`; 60 s | 250 ms; 60 s; 250 ms | Igual | — |
| M12 | "Nivel bajado al 40 para el altavoz" (paso 6 Medium, fila de y 480) | Opacidad | Reanudación por altavoz con nivel > 40 | 250 ms; 4 s; 250 ms | Igual | — |
| M13 | Regla vertical de volumen (Noche y Madrugada) | Longitud llena = nivel maestro; aparece / desaparece por opacidad | Dedo (arrastre vertical, `minimumDistance` 8, eje a 30°); `mainMixerNode.outputVolume` | Directa; aparece 150 ms `.easeOut`; desaparece 1,5 s después de soltar, 250 ms | Igual | — |
| M14 | Hoja del Temporizador: control que se despliega bajo el hueco de control (rueda, `DatePicker`) | Opacidad del contenido nuevo; **ninguna fila cambia de posición** (el control aparece bajo la fila de y 332; debajo solo está el pie) | Selección (toque) | 250 ms · `.smooth` | Aparece por opacidad | — |
| M15 | `checkmark` del modo activo | `.transition(.opacity)` en la fila que lo gana y en la que lo pierde (es inserción / eliminación, no un reemplazo de símbolo) | Selección | 250 ms | Igual | — |
| M16 | `HairlineAction` "+15 min" de la hoja: pulsado | Opacidad 1 → 0,6 → 1 | Dedo | 200 ms · `.easeInOut` | Igual | — |
| M17 | Línea de agua de Madrugada: nacimiento | Amplitud 0 → plena desde la hairline | Fundido de entrada del motor (3 s) y `guide.anchor` | 3 s · `.easeOut` (sigue a la ganancia) | Opacidad 0,6 → 1,0 | — |
| M18 | Línea de agua de Madrugada: respiración | Posición vertical dentro de la banda de 120 (la única "posición" que cambia, y es la forma del sonido) | `BreathCurve(t)` del motor con `guide.anchor` + `outputLatency`; sube 4 s, baja 4,5 s, reposo 1,5 s (`BreathParameters` de `main`) | 10 s por ciclo (6 por minuto); `TimelineView` a 30 Hz pausable (el de `BreathIndicator`), nunca `sin()` | Posición fija a media banda; opacidad 0,6 → 1,0 con la misma curva | Quieta en bajamar en ≤ 2 s; 0 fotogramas; al despertar la pantalla retoma desde el ancla |
| M19 | Línea de agua: disolución → horizonte | Amplitud → 0 con la ganancia de la guía; 2 s en bajamar; la línea pasa a 2 pt y a y 284 **sin desplazarse** (bajamar está a y 344: la línea se funde en bajamar y aparece en 284; nunca se mueve de una a otra) | `release` / `dissolve` del motor (120 s) | 120 s lineal (es la ganancia) + 2 s + 250 ms de opacidad cruzada | La excursión de opacidad decrece igual | 0 fotogramas |
| M20 | Horizonte de Madrugada: continuo ↔ ausente / fin | Opacidad | `isPlaying`; `onComplete` | 250 ms / 2 s | Igual | 0 fotogramas |
| M21 | "Parar" / "+15 min" / "Volver" / controles visibles: pulsado | Opacidad 1 → 0,6 → 1 | Dedo | 200 ms | Igual | — |
| M22 | Botón "Pausa" / "Seguir" de los controles visibles | Contenido (la palabra); 250 ms de opacidad, como M6 | `isPlaying` | 250 ms | Igual | 0 fotogramas |
| M23 | Reloj de Noche en Acceso asistido | Tamaño 72 → 56 (una vez, al entrar) | Modo del sistema | Sin animación | — | — |
| M24 | Cambio de fase de luminancia (Noche → página nocturna → Descenso a las 07:00) | Color de tinta `texto-noche` → `texto` | Reloj (07:00) o toque en el nombre | 2 s · opacidad | 250 ms | — |
| M25 | "+10 min" de Madrugada tras la segunda prolongación (controles visibles, Isla) | Opacidad 1 → 0; el hueco queda vacío | Segunda pulsación de "+10 min" | 250 ms | Igual | — |
| M26 | Hoja: detent `.medium` → `.large` y vuelta | Altura de la hoja (sistema) | Rueda o selector desplegados; al abrir con Dynamic Type ≥ xL o en SE | La del sistema | La del sistema | — |
| M27 | `DatePicker` compacto: despliegue del selector | Sistema | Toque en la hora | La del sistema | La del sistema | — |

Lo que **no** se anima nunca aquí: el fundido final del temporizador (en Noche el horizonte no sigue la ganancia: es continuo hasta el final y la palabra dice "Fundiendo"; en la página sí lo sigue, E2); el `.pulse` del Disco (no hay Disco en Noche; el de la barra lo especifica E2 y el de la Live Activity E6); cualquier rebote, escala, desplazamiento o `spring`. Límites de 03 §3.7 comprobables: ninguna animación finita > 2 s salvo M1 (2 s exactos) y las que son el sonido (M17-M19); ningún píxel cambia de luminancia más de 3 veces por segundo (el peor caso es la línea de agua a 30 Hz, área < 0,2 % de la pantalla, τ del `BreathCurve` ≥ 2 s); presupuesto: Noche bloqueada = 0 trabajo salvo el audio y el fundido en el hilo de render (sin ticker: §9.6); Noche encendida = un `Text` por minuto **[a medir con Instruments, 10 min bloqueado]**.

### 5(b) VoiceOver por control · etiqueta → valor → pista → rasgos → acciones personalizadas

Orden de lectura en **Noche**: (1) "Volver a la página" (botón al principio del orden, invisible pero presente: Grafito 10.6), (2) el elemento de pantalla completa, (3) "Seguir por el altavoz" (si existe), (4) "+15 min" (si existe), (5) controles visibles (si existen). Orden en **Madrugada**: (1) el elemento de pantalla completa, (2) "Parar", (3) controles visibles (si existen); la hora opt-in va dentro de la etiqueta del elemento y el `Text` es `accessibilityHidden(true)`. Magic Tap (dos dedos, dos toques) = pausa / reanuda desde cualquier foco (`accessibilityPerformMagicTap`). Escape (Z) = volver (solo Noche). El foco entra en el elemento de pantalla completa al abrir. Las hairlines, el horizonte, la línea de agua y la regla de volumen son `accessibilityHidden(true)`: su información está en la etiqueta. **El elemento de pantalla completa tiene una sola etiqueta, la frase de estado** (un solo anuncio; también para Switch Control, que lee la misma `accessibilityLabel`); no se llama "Pantalla de noche".

| Control | Etiqueta ES [EN] | Valor | Pista | Rasgos | Acciones personalizadas (rotor) |
|---|---|---|---|---|---|
| **Noche: pantalla completa** | "Sonando, quedan 35 minutos, las tres y siete" ["Playing, 35 minutes left, 3:07 a.m."]; con Marea: "Sonando, guiando a seis por minuto, quedan 35 minutos, las tres y siete"; en pausa: "En pausa, quedan 35 minutos"; por auriculares: "En pausa, auriculares desconectados, quedan 35 minutos"; Escudo: "Sonando, hasta las siete, las tres y siete"; sin temporizador: "Sonando, toda la noche, las tres y siete"; fundiendo: "Fundiendo, ocho minutos, las tres y treinta y cuatro"; terminó: "Terminó a las tres y cuarenta y dos" | — (todo va en la etiqueta: un solo anuncio) | "Toca dos veces para pausar" ["Double-tap to pause"]; en pausa: "Toca dos veces para reanudar"; en pausa por auriculares o coche: "Toca dos veces para seguir por el altavoz, como mucho al cuarenta"; sin sonido: "Toca dos veces para intentarlo otra vez"; primera vez: añade "Mantén pulsado para volver" | `.button`, `.startsMediaSession`; `.updatesFrequently` **no** (cambia por minuto; evitaría anuncios espontáneos). **Terminó: `.staticText`** (un botón que no hace nada no se anuncia como botón) | "Añadir quince minutos" ["Add fifteen minutes"] (no se ofrece con "Toda la noche") · "Quitar quince minutos" ["Remove fifteen minutes"] (mínimo 5 restantes) · "Subir el volumen" ["Volume up"] · "Bajar el volumen" ["Volume down"] (pasos del 5 %, con anuncio del valor) · "Volver a la página" ["Back to the page"] · "Mostrar controles" ["Show controls"] (activa los controles visibles para esta sesión) · "Mostrar la hora" / "Ocultar la hora" (toggle "Sin reloj") |
| Noche: "Volver a la página" (primero en el orden) | "Volver a la página" ["Back to the page"] | — | — | `.button` | — |
| Noche: "+15 min" | "Más quince minutos" ["Fifteen more minutes"] | "Se funde a las tres y cuarenta y dos" ["Fades at 3:42"]; Escudo: "hasta las siete"; terminó: "terminó a las tres y cuarenta y dos"; sin sonido: "sin sonido" | "Toca dos veces para añadir quince minutos"; terminó: "Toca dos veces para seguir quince minutos"; sin sonido: "Toca dos veces para añadir quince minutos e intentarlo otra vez". Con "Toda la noche" el botón no existe en el árbol | `.button` | — |
| Noche: "Seguir por el altavoz" | "Seguir por el altavoz" ["Keep playing on the speaker"] | — | "Reanuda por el altavoz del iPhone, como mucho al cuarenta" ["Resumes on the iPhone speaker, at forty at most"] | `.button` | — |
| Controles visibles: "−15 min" | "Quince minutos menos" ["Fifteen minutes less"] | "Se funde a las tres y veintisiete" | — | `.button` | — |
| Controles visibles: "Pausa" / "Seguir" | "Pausar" / "Reproducir" ["Pause" / "Play"] (`control.pause` / `control.play` de `main`) | — | — | `.button`, `.startsMediaSession` | — |
| Controles visibles: "+15 min" | como "+15 min" | | | | |
| Controles visibles: "Volver" | "Volver a la página" | — | — | `.button` | — |
| **Madrugada: pantalla completa** | "Madrugada, veinte minutos" (arrancando); "Madrugada, respirando a seis por minuto, quedan catorce minutos" ["Small hours, breathing at six per minute, fourteen minutes left"]; sin Marea: "Madrugada, quedan catorce minutos"; fundiendo: "Madrugada, fundiendo, tres minutos"; en pausa: "En pausa, quedan catorce minutos"; con hora: añade ", las tres y cuarenta y uno"; terminó: "Terminó" | — | "Toca dos veces para pausar" / "para reanudar" / por auriculares: "Toca dos veces para seguir por el altavoz, como mucho al cuarenta" | `.button`, `.startsMediaSession`; terminó: `.staticText` | "Diez minutos más" ["Ten more minutes"] (se retira del rotor tras la segunda vez) · "Parar" ["Stop"] · "Subir el volumen" · "Bajar el volumen" · "Mostrar la hora" / "Ocultar la hora" |
| Madrugada: "Parar" | "Parar" ["Stop"] | — | "Apaga Madrugada en tres segundos" ["Turns Small hours off over three seconds"] | `.button` | — |
| Controles visibles (Madrugada): "+10 min" | "Diez minutos más" | "quedan veinticuatro minutos" | — | `.button`; desaparece del árbol tras la segunda vez | — |
| Controles visibles (Madrugada): "Pausa" / "Seguir" | como en Noche | | | | |
| **Temporizador: cabecera** | "Temporizador" ["Timer"] | — | — | `.isHeader` | — |
| Temporizador: cifra (sonando) | "Quedan treinta y ocho minutos" ["Thirty-eight minutes left"]; fundiendo: "Fundiendo, ocho minutos"; en pausa: "En pausa, quedan treinta y ocho minutos"; Escudo: "Hasta las siete, toda la noche, baja un poco cada hora" | — | — | `.staticText`; anunciada al abrir la hoja (`.screenChanged` con este elemento) | — |
| Temporizador: línea bajo la cifra | agrupada con la cifra | | | | |
| Temporizador: "+15 min" (hoja) | "Más quince minutos" (la misma etiqueta en los tres modos) | "Se funde a las doce y cuarenta y dos" | "Toca dos veces para prolongar" ["Double-tap to extend"] | `.button` | — |
| Fila "Hasta dormirme" | "Hasta dormirme" ["Until I fall asleep"] | "45 minutos, se funde en los últimos diez minutos, seleccionado" ["45 minutes, fades over the last ten minutes, selected"]; día 8: "60 minutos, antes noventa" / "60 minutos, antes Escudo nocturno" | "Toca dos veces para elegir este modo" ["Double-tap to choose this mode"] | `.button`, `.isSelected` cuando activa | — |
| Fila "Escudo nocturno" | "Escudo nocturno" ["Night shield"] | "hasta las siete, toda la noche, baja un poco cada hora" + ", requiere Pro" ["needs Pro"] si no hay acceso | "Toca dos veces para elegir este modo" (el selector se anuncia solo al aparecer) | `.button`, `.isSelected` | — |
| `DatePicker` "Hasta las" | "Hasta las" ["Until"] | "07:00" | sistema | sistema | sistema |
| Fila "Siesta" | "Siesta" ["Nap"] | "20 minutos, se funde en los últimos dos minutos" | "Toca dos veces para elegir este modo" | `.button`, `.isSelected` | — |
| Fila "Apagado" | "Apagado" ["Off"] | "sin temporizador" ["no timer"] | — (el valor ya dice lo que hay; "Suena hasta que lo pares" prometía lo que la app no garantiza: los 20 min en pausa y las 05:00-11:00 también terminan la sesión) | `.button`, `.isSelected` | — |
| Hueco de control ("Duración" / "Hasta las") | "Duración" ["Length"] / "Hasta las" ["Until"] | "45 minutos"; gratuito: "60 minutos, tope; más requiere Pro" ["60 minutes, limit; more needs Pro"]; Escudo: "siete"; Apagado: "toda la noche" | "Toca dos veces para cambiar la duración" ["Double-tap to change the length"]; Escudo: "Toca dos veces para cambiar la hora" | `.button` (abre la rueda / el selector); Apagado: `.staticText` | — |
| Rueda de duración | "Duración" | sistema ("65 minutos, Pro") | sistema | `.adjustable` (sistema) | — |
| Pie | el texto | — | — | `.staticText` | — |
| Anuncios (`AccessibilityNotification.Announcement`, prioridad baja) | "Sonando" · "En pausa" · "Quedan cincuenta minutos" (tras +15; los minutos reales) · "Página" (al volver) · "Nivel bajado al cuarenta para el altavoz" · "Terminó" (una vez) · "Parado" (tras "Parar") · "Sesenta minutos; más de sesenta requiere Pro" · "Sesenta minutos, antes noventa" / "Sesenta minutos, antes Escudo nocturno" (día 8) | | | | |

VoiceOver no detiene la cama: la sesión permite *ducking* y recupera el nivel en 1 s (02 §7.8). El reloj se lee en palabras con `Date.FormatStyle(time: .shortened)` hablado ("las tres y siete"), nunca "Hora" ni dígitos sueltos (corrige el PR #3). La hora hablada llega a las etiquetas ya formada, con su artículo (`spokenTime(_:)`: "las tres y siete" / "la una y siete"), para que "Se funde a la una y siete" sea correcto en ES; las cadenas de pantalla resuelven lo mismo con las variantes `.one` del catálogo.

### 5(c) Gesto → alternativa sin gesto → Control por botón (Switch Control) → teclado / Pointer

Principio: ningún gesto es la única vía; ningún gesto es de varios dedos, de pellizco ni horizontal.

| Gesto | Dónde | Alternativa visible / sin gesto | Switch Control (escaneo) | Teclado / Pointer (iPad, Mac Catalyst si llega) |
|---|---|---|---|---|
| Toque en cualquier punto = pausa / reanuda | Noche, Madrugada | El elemento de pantalla completa (etiqueta = la frase de estado) para VoiceOver; botón "Pausa" / "Seguir" de los controles visibles; Live Activity (E6); Watch (1.1); Siri "Para SleepNoise" / "Reproduce SleepNoise" | El elemento de pantalla completa es el primer botón del escaneo (tras "Volver" en Noche) | Espacio = pausa / reanuda; el foco de teclado entra en la pantalla al abrir Noche; anillo de foco del sistema alrededor del reloj (único elemento con foco visible) |
| Toque en "+15 min" | Noche | Es ya un botón de 64 pt a todo el ancho; acción de VoiceOver; Live Activity "+15 min"; Siri "Añade quince minutos a SleepNoise"; Watch | Botón en el escaneo | Tab hasta "+15 min", Retorno; atajo ⌘+ (más) |
| Arrastre vertical = volumen maestro | Noche, Madrugada | **Botones físicos de volumen del iPhone** (siempre funcionan; el sistema dibuja su indicador); acciones de VoiceOver "Subir / Bajar el volumen"; con controles visibles, no se añade nada (los botones físicos bastan); Watch: corona | Las acciones "Subir / Bajar el volumen" aparecen en el menú de Switch Control del elemento | ↑ / ↓ = ±5 % |
| Pulsación larga (0,6-2 s, se dispara al soltar) = volver | Noche | "Volver" de los controles visibles; botón "Volver a la página" al principio del orden de VoiceOver; gesto de escape (Z); Acceso asistido: el "Atrás" del sistema; bloquear y abrir desde el icono (icono = página) | Botón "Volver" en el escaneo | Esc = volver |
| Toque en "Parar" | Madrugada | Es un botón; acción de VoiceOver "Parar"; Isla expandida "Parar" (E6); Siri "Para SleepNoise" | Botón en el escaneo | Tab, Retorno; Esc = Parar (en Madrugada no hay "volver") |
| +10 min (no hay gesto en la pantalla) | Madrugada | Isla expandida "+10"; acción de VoiceOver "Diez minutos más"; controles visibles "+10 min"; Siri "Diez minutos más de Madrugada"; las tres desaparecen tras la segunda vez | Botón en el escaneo si hay controles visibles | ⌘+ |
| Toque en una fila de modo | Temporizador | Es una fila de `List` del sistema | Escaneo de la lista | Tab / flechas, Retorno |
| Girar la rueda de duración | Temporizador | La rueda del sistema admite toque en cada valor; con VoiceOver es `.adjustable` (no hay ningún control añadido: la rueda ya es la alternativa) | Switch Control ofrece Incrementar / Decrementar sobre la rueda | ↑ / ↓ en la rueda; Pointer con desplazamiento |
| `DatePicker` compacto | Temporizador | Sistema (teclado numérico del sistema al tocar la hora) | Sistema | Sistema |
| Arrastrar la hoja para cerrarla | Temporizador | Tocar fuera; en iOS 26 el botón de cierre del sistema; VoiceOver: escape (Z) | "Cerrar" en el menú del escaneo | Esc |
| Bloquear el iPhone = entrar en Noche | Sistema | La palabra "Noche" de la barra; "Pasar a Noche sola" | La palabra "Noche" es un botón de la barra | ⌘N |
| Mantener el botón de Acción / control del Centro de control = Madrugada | Sistema (iOS 18) | Live Activity terminada ("madrugada · 20 min"); Siri; Watch (1.1) | Sistema | — |

### 5(d) Dynamic Type por tramo

Todo escala con `relativeTo`; nada se trunca con "…"; nada se superpone. Comprobación: previews en Large, xxxLarge, AX3 y AX5 en ES (30 % más largo) y EN.

| Tramo | Temporizador (hoja) | Noche | Madrugada |
|---|---|---|---|
| **xS-L** | Como 2.1; filas 72 / 56; cifra 56; `HairlineAction` 64; detent `.medium` | Como 2.2.1; reloj 72; estado 22; frases de primera vez 17; "+15 min" 20 en 64 pt | Como 2.3.1; cifra 72; "Parar" 20 en 64 |
| **xL-xxxL** | Filas 80-96 (`@ScaledMetric`); nombre y subtítulo siguen en línea mientras quepan (`ViewThatFits`); el valor pasa bajo el nombre en xxL si no cabe; la hoja abre en `.large` desde xL (`detent = .large`); cifra escala con `.largeTitle` (56 → ~76 en xxxL); el pie en dos líneas | Reloj escala con `.largeTitle` (72 → ~96 en xxxL; sigue en una línea: "03:07" cabe en 353 hasta AX2); estado 22 → ~30, puede pasar a dos líneas ("Se funde a las 03:42" en ES cabe en una hasta xxL); frases de primera vez 17 → ~23, dos líneas cada una si hace falta; "+15 min" 20 → ~28, fila de 64 → 72 (`@ScaledMetric(relativeTo: .title3)`, mínimo 64); el horizonte sigue a y 284 | Cifra 72 → ~96; "Parar" como "+15 min"; la banda de 120 no cambia (no es texto) |
| **AX1-AX2** | Filas de modo en dos líneas (nombre arriba, valor debajo, subtítulo tercero), 112-128 de alto; el hueco de control en dos líneas; cifra con tope **AX2 = ~112 pt** (`dynamicTypeSize(...accessibility2)` solo para la cifra); la `HairlineAction` crece a 80 con el texto en una línea; la hoja hace scroll con la cifra arriba | Reloj con tope AX2 (~112 pt; "03:07" sigue en una línea); estado en dos líneas de ~34 pt (y 436-504); las frases de primera vez bajan a y 520 y pueden ocupar dos líneas cada una; "+15 min" en fila de 80 (y 738-818); "Seguir por el altavoz" en dos líneas en fila de 96 encima (y 642-738; cuelga de los 818 del área segura); **el horizonte se ancla a 24 pt bajo el reloj** en vez de al tercio si el reloj lo alcanzaría (03 §3.5: en AX se ancla bajo la cabecera): con reloj a y 300-412, horizonte a y 436 y estado a y 460; se decide con `ViewThatFits` entre las dos disposiciones | Cifra con tope AX2; "Parar" en fila de 80; la banda de 120 baja a y 160-280 si la cifra lo pide (`ViewThatFits`); la hora opt-in en una fila propia bajo la cifra |
| **AX3-AX5** | Las filas de modo pueden ocupar tres líneas (nombre / subtítulo / valor) de hasta 160 pt; "Apagado" en dos líneas; la rueda del sistema escala sola; el pie hasta cuatro líneas; la cifra se queda en el tope AX2; la `HairlineAction` en dos líneas de texto si hace falta | Reloj en el tope AX2 (no crece más: a un metro ya se lee; crecer más lo sacaría de la pantalla en SE); estado hasta tres líneas (~40 pt cada una); "+15 min" en fila de 96 con el texto en una línea (siempre cabe: es corto a propósito); las frases de primera vez se omiten en AX4-AX5 (están en la pista de VoiceOver); los controles visibles pasan a filas de 96: "−15 min" · "Pausa" en y 626-722 y "+15 min" a todo el ancho en y 722-818 (sigue siendo la fila inferior), "Volver" encima (y 530-626); las filas cuelgan del borde del área segura (818), como el propio "+15 min" | Cifra en el tope AX2; "Parar" en fila de 96; la hora opt-in en una fila propia; los controles visibles en filas de 96 como en Noche ("+10 min" · "Pausa" / "Parar") |

Comprobación adicional por idioma: "Seguir por el altavoz" (23 caracteres) y "Keep playing on the speaker" (27) caben en una línea hasta xxL a 20 pt en 353 pt; en AX1+ pasan a dos. "Se funde a las 03:42" (20) cabe en una línea hasta AX1 a 22-30 pt. "Mantén pulsado para volver" (26) y "La pantalla puede dormir. El sonido sigue." (42) caben en una línea a 17 pt hasta xL **[a medir]**. Los nombres de modo son cortos a propósito: "Hasta dormirme" (14), "Escudo nocturno" (15), "Siesta" (6), "Apagado" (7).

### 5(e) Catálogo de cadenas ES / EN por clave

Las claves son identificadores de código (no copy): se conserva el prefijo `timer.` de `main` para no romper el catálogo; las claves de Noche y Madrugada son nuevas. **Una fila por clave** (E7 compila la tabla tal cual). Longitud máxima = caracteres en los que la cadena debe caber en una línea en Large en 353 pt al paso indicado; E7 revisa es-419 (ninguna de estas cadenas usa léxico que diverja: "madrugada", "siesta", "escudo", "auriculares", "altavoz" son comunes). Las que sustituyen a una clave de `main` lo dicen en "Contexto". Las variantes `.one` existen porque en ES la una lleva artículo singular ("hasta la 01:00", "Se funde a la una"); en EN son idénticas a la base.

| Clave | ES | EN | Contexto (dónde, paso) | Máx. |
|---|---|---|---|---|
| `timer.title` | Temporizador | Timer | Cabecera de la hoja, paso 3 (ya existe en `main`, mismo valor; "Sleep timer" EN pasa a "Timer": la hoja ya está dentro de una app de dormir) | 20 |
| `timer.mode.untilAsleep` | Hasta dormirme | Until I fall asleep | Fila de modo, paso 5 | 24 |
| `timer.mode.untilAsleep.detail` | se funde en los últimos 10 min | fades over the last 10 min | Subtítulo, paso 7; también línea bajo la cifra | 36 |
| `timer.mode.shield` | Escudo nocturno | Night shield | Fila de modo, paso 5 | 24 |
| `timer.mode.shield.detail` | toda la noche · baja un poco cada hora | all night · eases down each hour | Subtítulo, paso 7; también línea bajo la cifra en Escudo | 40 |
| `timer.mode.shield.until` | Hasta las | Until | Nombre del hueco de control en Escudo, paso 5 | 12 |
| `timer.mode.nap` | Siesta | Nap | Fila de modo, paso 5 | 24 |
| `timer.mode.nap.detail` | se funde en los últimos 2 min | fades over the last 2 min | Subtítulo, paso 7 | 36 |
| `timer.mode.off` | Apagado | Off | Fila, paso 5 (sustituye a `timer.off`, mismo valor) | 12 |
| `timer.length` | Duración | Length | Hueco de control, paso 5 | 16 |
| `timer.length.allNight` | toda la noche | all night | Valor del hueco de control con Apagado, paso 9 | 16 |
| `timer.minutesFormat` | %lld min | %lld min | Valores, paso 9; cifra, paso 1 (ya existe) | 8 |
| `timer.untilFormat` | hasta las %@ | until %@ | Valor de Escudo en la fila (paso 9) | 16 |
| `timer.untilFormat.one` | hasta la %@ | until %@ | Igual, cuando la hora es la una (ES) | 16 |
| `timer.untilFormat.sentence` | Hasta las %@ | Until %@ | Estado de Noche, paso 3 | 16 |
| `timer.untilFormat.sentence.one` | Hasta la %@ | Until %@ | Igual, a la una | 16 |
| `timer.fadesAtFormat` | Se funde a las %@ | Fades at %@ | Estado de Noche (paso 3); línea bajo la cifra (paso 7); línea de estado de la página (E2, misma clave) | 22 |
| `timer.fadesAtFormat.one` | Se funde a la %@ | Fades at %@ | Igual, a la una | 22 |
| `timer.allNight` | Toda la noche | All night | Estado de Noche sin temporizador, paso 3 | 16 |
| `timer.fading` | Fundiendo | Fading | Línea bajo la cifra de la hoja, paso 7 | 12 |
| `timer.fadingFormat` | Fundiendo · %lld min | Fading · %lld min | Estado de Noche, paso 3 (nunca en la cifra de paso 1: no cabe) | 20 |
| `timer.leftFormat` | quedan %lld min | %lld min left | Bajo "En pausa" en la hoja, paso 7 | 18 |
| `timer.endedAtFormat` | Terminó a las %@ | Ended at %@ | Estado de Noche tras el fin, paso 3; línea de estado de la página | 22 |
| `timer.endedAtFormat.one` | Terminó a la %@ | Ended at %@ | Igual, a la una | 22 |
| `timer.plus15` | +15 min | +15 min | Botón de Noche (paso 4) y `HairlineAction` (paso 5), en los tres modos | 8 |
| `timer.minus15` | −15 min | −15 min | Controles visibles (03 §4.5) | 8 |
| `timer.proWasFormat` | antes %lld · más de 60 es Pro | was %lld · beyond 60 is Pro | Nota del día 8, paso 7, una sola vez | 32 |
| `timer.proWasShield` | antes Escudo · el Escudo es Pro | was Shield · the Shield is Pro | Nota del día 8 si el modo era Escudo, paso 7, una sola vez, en el mismo sitio | 32 |
| `timer.note` | El sonido se funde; tu alarma no se toca. | Sound fades out; your alarm is never touched. | Pie, paso 8, una línea en Large (sustituye el valor de `timer.note` de `main`) | 45 |
| `night.title` | Noche | Night | Palabra de la barra (E2), Ajustes | 8 |
| `night.paused` | En pausa | Paused | Estado, paso 3 | 12 |
| `night.pausedCauseFormat` | En pausa · %@ | Paused · %@ | Estado con causa, paso 3 | 28 |
| `night.cause.headphones` | auriculares | headphones | Causa (fila 3 de §4.3) | 14 |
| `night.cause.car` | coche | car | Causa (CarPlay) | 8 |
| `night.noSound` | Sin sonido | No sound | Estado de error en Noche y Madrugada, paso 3 / 1 | 12 |
| `night.speaker.continue` | Seguir por el altavoz | Keep playing on the speaker | Botón de 64, paso 4 (Noche y página; 03 §1.2) | 28 |
| `night.speaker.lowered` | Nivel bajado al 40 para el altavoz | Level lowered to 40 for the speaker | Nota de 4 s, paso 6 Medium (Noche); línea de estado (página) | 40 |
| `night.first.screen` | La pantalla puede dormir. El sonido sigue. | The screen can sleep. Sound keeps playing. | Primera vez, paso 6 Medium | 44 |
| `night.first.hold` | Mantén pulsado para volver | Hold to go back | Primera vez, paso 6 Medium; también la pista de VoiceOver de la primera vez (la misma cadena) | 30 |
| `night.back` | Volver | Back | Controles visibles, paso 4 | 8 |
| `night.pause` | Pausa | Pause | Controles visibles, paso 4 | 8 |
| `night.resume` | Seguir | Resume | Controles visibles, paso 4 (en pausa) | 8 |
| `night.controls.visible` | Controles visibles de noche | Visible controls at night | Ajustes › Noche (E5), fila paso 5 | 30 |
| `night.auto.title` | Pasar a Noche sola | Switch to Night on its own | Ajustes › Noche, fila | 30 |
| `night.auto.1` | 1 min | 1 min | Opción | 6 |
| `night.auto.3` | 3 min | 3 min | Opción | 6 |
| `night.auto.never` | Nunca | Never | Opción | 8 |
| `night.noClock` | Sin reloj | No clock | Ajustes › Noche, toggle | 12 |
| `smallHours.title` | Madrugada | Small hours | Nombre de la pantalla, control, Ajustes | 12 |
| `smallHours.stop` | Parar | Stop | Botón de 64, paso 4 | 8 |
| `smallHours.plus10` | +10 min | +10 min | Isla expandida (E6), controles visibles | 8 |
| `smallHours.liveActivityFormat` | madrugada · %lld min | small hours · %lld min | Botón de texto de la Live Activity terminada (E6), versalitas; E6 lo rellena con `Text(timerInterval:)` cuando corre y con el valor de Ajustes cuando está terminada | 20 |
| `smallHours.setting.clock` | Mostrar la hora en Madrugada | Show the clock in Small hours | Ajustes › Madrugada, toggle (apagado) | 32 |
| `smallHours.setting.clock.note` | Madrugada no enseña la hora a propósito. | Small hours hides the clock on purpose. | Ajustes, nota paso 8 | 48 |
| `smallHours.setting.length` | Madrugada dura | Small hours lasts | Ajustes, fila con opciones 10 · 20 · 30 min | 20 |
| `smallHours.setting.liveActivity` | Mostrar Madrugada en la pantalla de bloqueo | Show Small hours on the Lock Screen | Ajustes, toggle (apagado: menos luz en la mesilla) | 48 |
| `smallHours.setting.liveActivity.note` | Apagado: menos luz en la mesilla. | Off: less light on the nightstand. | Nota paso 8 | 40 |
| `smallHours.morningFormat` | Anoche Madrugada siguió hasta las %@. | Last night Small hours ran until %@. | Línea de estado de la página por la mañana (E2), una vez, paso 7 | 48 |
| `smallHours.morningPinkFallback` | Anoche Madrugada sonó con Rosa: tu mezcla es Pro. | Last night Small hours played Pink: your mix is Pro. | Línea de estado de la página por la mañana (E2), una vez, paso 7 | 56 |
| `smallHours.actionButton.hint` | Mantén para Madrugada | Hold for Small hours | Sugerencia del botón de Acción (E6) | 24 |
| `siri.nothingPlaying` | No está sonando nada. | Nothing is playing. | Respuesta de Siri al Atajo "Noche" sin sesión (E6) | 24 |
| `a11y.night.enter.hint` | Toca dos veces para sonar y pasar a Noche | Double-tap to play and switch to Night | Pista de la palabra "Noche" de la barra con la sesión parada (la barra es de E2; la cadena se declara aquí) | — |
| `a11y.night.back` | Volver a la página | Back to the page | Botón de VoiceOver y acción | — |
| `a11y.night.add15` | Añadir quince minutos | Add fifteen minutes | Acción (no se ofrece con "Toda la noche") | — |
| `a11y.night.remove15` | Quitar quince minutos | Remove fifteen minutes | Acción | — |
| `a11y.night.volumeUp` | Subir el volumen | Volume up | Acción | — |
| `a11y.night.volumeDown` | Bajar el volumen | Volume down | Acción | — |
| `a11y.night.showControls` | Mostrar controles | Show controls | Acción | — |
| `a11y.night.showClock` | Mostrar la hora | Show the clock | Acción | — |
| `a11y.night.hideClock` | Ocultar la hora | Hide the clock | Acción | — |
| `a11y.night.playingFormat` | Sonando, quedan %1$lld minutos, %2$@ | Playing, %1$lld minutes left, %2$@ | Etiqueta del elemento (hora hablada con artículo en %2$@) | — |
| `a11y.night.playingGuidedFormat` | Sonando, guiando a %1$lld por minuto, quedan %2$lld minutos, %3$@ | Playing, guiding at %1$lld per minute, %2$lld minutes left, %3$@ | Etiqueta mientras `guide` está activa | — |
| `a11y.night.playingShieldFormat` | Sonando, hasta %1$@, %2$@ | Playing, until %1$@, %2$@ | Etiqueta (%1$@ = "las siete" / "la una", con artículo) | — |
| `a11y.night.playingAllNightFormat` | Sonando, toda la noche, %@ | Playing, all night, %@ | Etiqueta | — |
| `a11y.night.fadingFormat` | Fundiendo, %1$lld minutos, %2$@ | Fading, %1$lld minutes, %2$@ | Etiqueta | — |
| `a11y.night.pausedFormat` | En pausa, quedan %lld minutos | Paused, %lld minutes left | Etiqueta (Noche, Madrugada, cifra de la hoja en pausa) | — |
| `a11y.night.pausedCauseFormat` | En pausa, %1$@, quedan %2$lld minutos | Paused, %1$@, %2$lld minutes left | Etiqueta; %1$@ = causa hablada ("auriculares desconectados" / "headphones disconnected", "coche" / "car") | — |
| `a11y.night.cause.headphones` | auriculares desconectados | headphones disconnected | Causa hablada | — |
| `a11y.night.endedFormat` | Terminó a %@ | Ended at %@ | Etiqueta (%@ con artículo: "las tres y cuarenta y dos") | — |
| `a11y.night.hint.pause` | Toca dos veces para pausar | Double-tap to pause | Pista | — |
| `a11y.night.hint.resume` | Toca dos veces para reanudar | Double-tap to resume | Pista | — |
| `a11y.night.hint.speaker` | Toca dos veces para seguir por el altavoz, como mucho al cuarenta | Double-tap to keep playing on the speaker, at forty at most | Pista del elemento en pausa por auriculares o coche | — |
| `a11y.night.hint.retry` | Toca dos veces para intentarlo otra vez | Double-tap to try again | Pista del elemento en "Sin sonido" | — |
| `a11y.night.hint.ended` | Toca dos veces para seguir quince minutos | Double-tap to continue fifteen minutes | Pista del botón "+15 min" tras "Terminó" | — |
| `a11y.night.plus15.label` | Más quince minutos | Fifteen more minutes | Etiqueta del botón | — |
| `a11y.night.plus15.hint` | Toca dos veces para añadir quince minutos | Double-tap to add fifteen minutes | Pista del botón | — |
| `a11y.night.plus15.hint.retry` | Toca dos veces para añadir quince minutos e intentarlo otra vez | Double-tap to add fifteen minutes and try again | Pista del botón en "Sin sonido" | — |
| `a11y.night.minus15.label` | Quince minutos menos | Fifteen minutes less | Etiqueta | — |
| `a11y.night.speaker.hint` | Reanuda por el altavoz del iPhone, como mucho al cuarenta | Resumes on the iPhone speaker, at forty at most | Pista del botón "Seguir por el altavoz" | — |
| `a11y.smallHours.startingFormat` | Madrugada, %lld minutos | Small hours, %lld minutes | Etiqueta al arrancar | — |
| `a11y.smallHours.breathingFormat` | Madrugada, respirando a %1$lld por minuto, quedan %2$lld minutos | Small hours, breathing at %1$lld per minute, %2$lld minutes left | Etiqueta | — |
| `a11y.smallHours.plainFormat` | Madrugada, quedan %lld minutos | Small hours, %lld minutes left | Etiqueta sin Marea | — |
| `a11y.smallHours.fadingFormat` | Madrugada, fundiendo, %lld minutos | Small hours, fading, %lld minutes | Etiqueta en el fundido final | — |
| `a11y.smallHours.plus10` | Diez minutos más | Ten more minutes | Acción (se retira tras la segunda vez) | — |
| `a11y.smallHours.stop.hint` | Apaga Madrugada en tres segundos | Turns Small hours off over three seconds | Pista | — |
| `a11y.timer.leftFormat` | Quedan %lld minutos | %lld minutes left | Cifra de la hoja | — |
| `a11y.timer.fadingFormat` | Fundiendo, %lld minutos | Fading, %lld minutes | Cifra de la hoja en el fundido | — |
| `a11y.timer.plus.hint` | Toca dos veces para prolongar | Double-tap to extend | Pista de la `HairlineAction` | — |
| `a11y.timer.mode.hint` | Toca dos veces para elegir este modo | Double-tap to choose this mode | Pista de las filas de modo | — |
| `a11y.timer.untilAsleep.valueFormat` | %lld minutos, se funde en los últimos diez minutos | %lld minutes, fades over the last ten minutes | Valor | — |
| `a11y.timer.shield.valueFormat` | hasta %@, toda la noche, baja un poco cada hora | until %@, all night, eases down each hour | Valor de la fila y de la cifra en Escudo (%@ con artículo) | — |
| `a11y.timer.needsPro` | requiere Pro | needs Pro | Sufijo de valor | — |
| `a11y.timer.nap.valueFormat` | %lld minutos, se funde en los últimos dos minutos | %lld minutes, fades over the last two minutes | Valor | — |
| `a11y.timer.off.value` | sin temporizador | no timer | Valor de "Apagado" (sin pista) | — |
| `a11y.timer.length.hint` | Toca dos veces para cambiar la duración | Double-tap to change the length | Pista del hueco de control | — |
| `a11y.timer.until.hint` | Toca dos veces para cambiar la hora | Double-tap to change the time | Pista del hueco de control en Escudo | — |
| `a11y.timer.length.limit` | 60 minutos, tope; más requiere Pro | 60 minutes, limit; more needs Pro | Valor para el usuario gratuito | — |
| `a11y.timer.wasFormat` | Sesenta minutos, antes %lld | Sixty minutes, was %lld | Anuncio y valor del día 8 | — |
| `a11y.timer.wasShield` | Sesenta minutos, antes Escudo nocturno | Sixty minutes, was Night shield | Anuncio y valor del día 8 (modo Escudo) | — |
| `a11y.announce.playing` | Sonando | Playing | Anuncio | — |
| `a11y.announce.paused` | En pausa | Paused | Anuncio | — |
| `a11y.announce.page` | Página | Page | Anuncio al volver | — |
| `a11y.announce.ended` | Terminó | Ended | Anuncio (una vez) y etiqueta del elemento terminado en Madrugada | — |
| `a11y.announce.stopped` | Parado | Stopped | Anuncio tras "Parar" | — |
| `a11y.announce.leftFormat` | Quedan %lld minutos | %lld minutes left | Anuncio tras +15 (los minutos reales) | — |
| `a11y.announce.proBeyond60` | Sesenta minutos; más de sesenta requiere Pro | Sixty minutes; beyond sixty needs Pro | Anuncio al volver de la hoja Pro sin compra | — |
| `a11y.announce.speakerLowered` | Nivel bajado al cuarenta para el altavoz | Level lowered to forty for the speaker | Anuncio | — |

**Claves de `main` que esta entrega reutiliza sin cambio:** `control.pause` ("Pausar" / "Pause") y `control.play` ("Reproducir" / "Play") como etiquetas de VoiceOver del botón "Pausa" / "Seguir" de los controles visibles.

**Claves de `main` que esta entrega retira** (E7 las marca obsoletas en el String Catalog): `timer.custom` ("Personalizado"), `timer.locked` ("Los temporizadores de más de 60 minutos y a medida son parte de Pro."), `timer.remaining` ("Restante"), `timer.off` (sustituida por `timer.mode.off`). **Claves de la revisión 1 de este documento que desaparecen**, para que E7 no las busque: `timer.mode.shield.activate`, `timer.store.unavailable` (vive solo en E5), `timer.plus30`, `timer.plus5`, `timer.proBeyond60`, `timer.note.nap`, `timer.endedAtCauseFormat`, `night.cause.call`, `night.cause.siri`, `night.cause.alarm`, `night.cause.airpods`, `night.cause.otherApp`, `night.guidedAccess.hint`, `smallHours.liveActivity` (fija), `a11y.timer.shield.activate.hint`, `a11y.timer.plus30.label`, `a11y.timer.plus5.label`, `a11y.timer.off.hint`, `a11y.smallHours.plus10.limit`. `paywall.benefit.timer.detail` ("90 minutos, a medida, hasta seis horas.") lo reescribe E5 como "Sin límite, y el Escudo nocturno hasta tu hora." ["No limit, and the Night shield until your hour."]. Listas negras de 00 §7.2 y del informe §5.2 pasadas con grep sobre todo el catálogo, en los dos idiomas: cero apariciones de cualquier palabra vetada (anglicismos incluidos); ningún superlativo; ninguna exclamación.

---

## 6. Variantes

### 6.1 iPhone 17 Pro (393 × 852) frente a SE 3.ª gen (375 × 667) y 16e (390 × 844)

El horizonte es proporcional, nunca absoluto (03 §3.5): y = altura × 0,333. Todo lo demás se cuelga de él o del borde inferior; nada se escala.

| Elemento | 17 Pro (393 × 852; segura 59 / 34) | 16e (390 × 844; segura 47 / 34) | SE (375 × 667; segura 20 / 0) |
|---|---|---|---|
| Horizonte / centro de la banda de Madrugada | y 284 | y 281 | y 222 |
| Reloj de Noche (72/80) | y 340-420 | y 337-417 | y 262-342 **[a medir: con 72 pt el reloj queda a 40 pt del horizonte; se mantiene 72, no se reduce]** |
| Estado (22/28) | y 436-464 | y 433-461 | y 358-386 |
| Frases de primera vez (17/22) | y 480 / 504 | y 477 / 501 | y 402 / 426 |
| "Seguir por el altavoz" (64) | y 690-754 | y 682-746 | y 539-603 (fuera de la retícula de 4 porque cuelga del borde de pantalla, 667; se acepta y se dice) |
| "+15 min" / "Parar" (64) | y 754-818 | y 746-810 | y 603-667 (sin indicador de inicio: el botón llega al borde; el área táctil sigue siendo 64 y el texto queda a 22 pt del borde) |
| Cifra de Madrugada (72/80) | y 396-476 | y 393-473 | y 314-394 |
| Columna | 353 (x 20-373) | 350 | 335 (x 20-355) |
| Hoja Temporizador `.medium` | ≈ 420 pt visibles: cabecera + 3 modos + Apagado + hueco de control + pie (todo) | ≈ 416: igual | ≈ 330: cabecera + 3 modos; Apagado, hueco de control y pie tras un desplazamiento, o la hoja abre en `.large` (`detent = .large` en SE) |

En SE la hoja abre en `.large` directamente. En AX3-AX5 sobre SE, Noche apila: reloj (tope AX2, 112 pt) a y 60-172, horizonte a y 196, estado a y 212+, y los botones abajo; es la disposición de `ViewThatFits` de §5(d).

### 6.2 Negro y papel

Noche, Madrugada y la página nocturna son **siempre negras** (03 §3.3 y §7.3): no tienen variante papel. La hoja del Temporizador sí sigue la apariencia del sistema de día: fondo `hoja-papel`, hairlines `trazo-papel`, cabecera y nombres `tinta`, subtítulos y valores `tinta2`, `‹pro›` en `tinta2`, `checkmark` en `tinta`, `DatePicker` con `.tint(tinta)` (la hoja no tiene color tampoco de día), `HairlineAction` con hairlines `trazo-papel` y texto `tinta`; pulsado `pulsado-papel`. Nada más cambia. Si el dueño elige "solo oscura" (7.3 a), la hoja se queda en `hoja` y no hay nada que quitar.

### 6.3 ES / EN

Las cadenas EN están escritas, no traducidas (§5(e)). Diferencias que afectan a la maqueta: "Small hours" ocupa dos palabras donde "Madrugada" ocupa una (el control del Centro de control y la Live Activity de E6 lo tienen en cuenta); "Until I fall asleep" (19) es más largo que "Hasta dormirme" (14) y sigue cabiendo en una línea de fila con el valor hasta xL; la hora en EN sigue el formato del sistema: con 12 h, el reloj de Noche dice "3:42" en paso 1 **sin sufijo** (`.hour(.defaultDigits(amPM: .omitted))`) y el estado "Fades at 3:42 am" con `.shortened`. Los formatos de hora nunca se escriben a mano: `Date.FormatStyle(time: .shortened)`. En ES, la una lleva las variantes `.one` del catálogo.

### 6.4 Aumentar contraste (High Contrast)

Variantes del asset catalog (03 §3.1): `texto2 → texto2-ac`, `texto3 → texto3-ac`, `trazo → trazo-ac`, `índice → índice-ac`. En Noche y Madrugada la única tinta es `texto-noche` (8,03:1), que no tiene variante AC porque ya supera 7:1; no hay ningún otro token en esas dos pantallas. Con "Diferenciar sin color" no hay nada que hacer: ningún estado de estas pantallas se lee por color.

### 6.5 Button Shapes

"+15 min", "Parar", "Seguir por el altavoz", "Volver", "−15 min", "+10 min", "Pausa" / "Seguir" y la `HairlineAction` muestran el subrayado del sistema (son `Button` con texto; `buttonStyle(.borderless)` lo hace solo). El elemento de pantalla completa no se subraya ni lleva contorno: **con Button Shapes activo (`UIAccessibility.buttonShapesEnabled`) se activan solos los controles visibles de noche (§2.4)**, igual que con Switch Control y AssistiveTouch; quien necesita ver dónde está el botón ve un botón con subrayado del sistema, no un marco (un contorno `trazo` sobre `negro` da 1,47:1: no se vería, y si se viera sería el único borde cerrado de la app). Las filas de la hoja son filas de `List`: el sistema no las subraya; el `checkmark` basta.

### 6.6 Escala de grises

Todo se lee igual: continuo / ausente, palabras, `checkmark`. Única comprobación: `texto-noche` sobre `negro` en gris sigue a 8,03:1 (es un gris: no cambia).

### 6.7 Filtro rojo de StandBy

No aplica a estas pantallas (StandBy muestra la Live Activity de E6, diseñada en rojo primero). Sí aplica como principio: Noche y Madrugada se diseñaron en gris, sin ningún color, así que bajo cualquier filtro se leen igual. Si alguna vez la app tuviese que dibujarse en StandBy (iPad en modo noche, 1.x), Noche ya cumple: una tinta, formas ≥ 2 pt, estado por forma.

### 6.8 Reduce Motion, Reducir transparencia, Smart Invert, Bold Text

Reduce Motion: §5(a) (transición de 2 s → 250 ms; línea de agua por opacidad; sin `numericText`). Reducir transparencia: no hay materiales propios; la hoja del sistema pasa a opaca sola. Smart Invert: el horizonte y la línea de agua llevan `accessibilityIgnoresInvertColors()`; el negro invertido del resto es decisión del usuario y se respeta. Bold Text: automático (SF Pro); el reloj Regular pasa a Medium y sigue cabiendo.

---

## 7. Háptica por evento

Regla de silencio (03 §3.8): iPhone quieto y horizontal = nunca vibra **[spike I0-5: CoreMotion con audio en segundo plano]**; "Háptica del sistema" desactivada = nada; segundo plano = nada; cada háptico tiene su anuncio de VoiceOver.

| Evento | iPhone | Anuncio VoiceOver | Por qué |
|---|---|---|---|
| Elegir un modo del temporizador (toque en la fila) | `.selection` | "Hasta dormirme, seleccionado" (el `.isSelected` lo lee solo) | Es una selección; estamos despiertos, con luz |
| Girar la rueda de duración | la del sistema (`Picker`) | la del sistema | Componente del sistema |
| Cerrar la hoja con un valor Pro sin acceso (se abre la hoja Pro) | **ninguna** | "Sesenta minutos; más de sesenta requiere Pro" (al volver sin compra) | Nunca háptica como marketing |
| "+15 min" (hoja, Noche), "−15 min", "+10 min" | `.selection` **solo con el iPhone en la mano**; en la mesilla, nada | "Quedan cincuenta minutos" | La mesilla de madera es un altavoz |
| Toque en Noche o Madrugada (pausa / reanuda) | **ninguna** | "En pausa" / "Sonando" | Lo confirma el sonido |
| Pulsación larga en Noche (volver) | `.impact(.light, 0.4)` al cumplirse 0,6 s, también en la mesilla (es la excepción: aquí el sonido no cambia y hace falta un "ya"; 0,4 de intensidad no suena sobre madera **[a medir]**); si el dedo sigue apoyado más de 2 s, no pasa nada más | "Página" (al soltar) | La única háptica de Noche |
| "Parar" en Madrugada | **ninguna** | "Parado" | El silencio lo confirma |
| "Seguir por el altavoz" / toque que reanuda por el altavoz | **ninguna** | "Sonando" + "Nivel bajado al cuarenta para el altavoz" si aplica | El sonido lo confirma |
| Arrastre vertical de volumen (cruzar 0 / llegar a 100 / pasos) | `.selection` / `.impact(.light, 0.6)` / nada, solo en la mano | valor hablado al soltar | Como la regla de nivel de 03 §3.8 |
| Fin del temporizador, fin de Madrugada, fin de la Marea, inicio del fundido, 20 min en pausa, error de audio, "Sin sonido", cualquier interrupción, entrar en Noche, cualquier anuncio de Pro | **ninguna** | anuncio de la línea de estado, prioridad baja | La persona duerme; nada no solicitado |
| Marea en Madrugada ("Mínima" / "Marcada", opt-in de E3) | Core Haptics siguiendo `BreathCurve`, 3-5 respiraciones, solo en la mano; motor `playsHapticsOnly`, destruido al terminar | opcional "inhala" / "exhala" | E3 lo especifica; aquí solo se dice que Madrugada lo hereda con la Marea |

---

## 8. Lo que se queda fuera y por qué

| Fuera | Por qué | Dónde vive, si vive |
|---|---|---|
| **Fundido por quietud** (CoreMotion: el iPhone lleva 20 min quieto y horizontal → el fundido empieza antes) | Prototipo obligatorio antes de prometerlo (03 §6); el falso positivo (iPhone en la mesilla con la persona despierta) apaga el sonido a quien lo necesita | 1.1: una fila "Fundido por quietud" ["Fade when still"] con toggle (tinte `índice`: el único color que tendrá la hoja) bajo el hueco de control y una segunda frase en el pie: "Si el iPhone lleva 20 minutos quieto en la mesilla, el fundido puede empezar antes." ["If your iPhone has sat still for 20 minutes, the fade may start early."]; en Noche el estado diría "Fundiendo · quieto 20 min". Ya tiene su sitio: no hay rediseño |
| **Despertar / subida suave** (+3 dB en 2-4 kHz y +10 % de nivel en los últimos 15 min del Escudo) y **fundido espectral** | El parámetro espectral no existe en `RenderState` (03 §6); prometer "subida suave" con un fundido lineal sería mentir | 1.1: una frase en el subtítulo del Escudo ("sube suave antes de las 07:00") y la fase Despertar de luminancia (03 §3.2) |
| **Noche automática por CoreMotion** (a los 20 s quieto y horizontal) | Mismo prototipo; de momento 60 s sin tocar basta y no tiene falsos positivos de sensor | 1.1 como opción de "Pasar a Noche sola" |
| **Arrastre horizontal en Noche** (±15 min bajo el dedo, de Dial / Marea / Silencio) | 03 §1.2 y §6: un roce horizontal con la almohada cambiaría el temporizador; "+15 min" como botón de 64 pt es el que supera la prueba a ciegas | El botón |
| **Doble toque en Noche = Madrugada** (Grafito) | Retrasa la pausa 300 ms y arranca 20 min por error (03 §1.2) | Live Activity, Centro de control, botón de Acción, Siri, Watch |
| **"Altavoz" sustituyendo a "+15 min"** | Dos acciones intercambiables en la misma posición (03 §1.2) | "Seguir por el altavoz" como fila encima, y el toque hace lo mismo |
| **"Activar el Escudo" como `HairlineAction`** (revisión 1) | Dos `HairlineAction` en la misma hoja (03 §4.6) y dos reglas de venta para una cosa; 03 §4.7 ya decía "al confirmar" | La regla única de confirmación (§2.1.4) |
| **"+30 min" / "+5 min" en la hoja** (revisión 1) | Tres etiquetas para una acción cuyo valor exacto está en la rueda; el botón de Noche ya había demostrado que una etiqueta fija es la que se aprende | "+15 min" en los tres modos |
| **Las causas "llamada", "Siri", "alarma", "otra app", "AirPods"** (revisión 1) | La API no las distingue (§4.3 regla 8): eran ficción de plataforma | "En pausa"; "auriculares" y "coche" son las dos causas reales |
| **Hoja "Noche" bajo pulsación larga en el reloj** (Dial: "Sin reloj", "Brillo mínimo") | Una hoja de ajustes a las 3 de la mañana es luz y lectura; la pulsación larga ya es "volver" | Ajustes › Noche (E5): "Sin reloj", "Pasar a Noche sola", "Controles visibles de noche" |
| **"Brillo mínimo al entrar"** como recordatorio, nota de Acceso guiado en Ajustes | La app no controla el brillo (HIG); un recordatorio o una explicación de una función del sistema son tips | Nada |
| **Regla de la noche con aguja** (Dial: escala de 353 pt con el índice en la fracción transcurrida) | Es un panel de medida y una traza temporal; el tiempo que queda ya está en palabras (03 §1.4) | El estado en palabras |
| **Reloj en Madrugada por defecto** | "Saber la hora a las 4 es lo peor que se puede ofrecer" (Dial, Grafito); es la única decisión de la app que esconde un dato, y se explica en Ajustes | Opt-in "Mostrar la hora en Madrugada" |
| **"+20" durante Madrugada** desde la pantalla | Prolongar a las 4 es volver a tocar al terminar (Silencio) o "+10" desde la Isla; un segundo botón en la pantalla de Madrugada rompe "un botón" | Isla expandida, VoiceOver, controles visibles |
| **Marcas de pleamar / bajamar en Madrugada** (revisión 1) | Dos hairlines grises de 0,5 pt a brillo mínimo son invisibles y, si se ven, son dos elementos más; en Madrugada no son control (03 §4.3 las prevé en la hoja de la Marea, E3) | La banda existe como geometría; la excursión de la línea la enseña |
| **Leer la hora de despertar del horario de Sueño / de la alarma de Reloj** | No hay API pública (03 §6); el `DatePicker` que el usuario fija una vez es honesto | El `DatePicker` |
| **Live Activity nueva al arrancar Madrugada** | Luz en la mesilla; por defecto apagada | Toggle en Ajustes (E6 la dibuja) |
| **Hora de fin fija que no se congela en pausa** (Dial, Silencio) | Dos reglas para una cosa; el código congela y la actividad admite `pauseTime` | §4.3 regla 1 |
| **Vender en Noche o Madrugada**, cualquier `‹pro›` a esas horas, "sin océano" a las 4 | 03 §1.3 (Dial, Silencio): nadie lee "pro" a las 3:40; la venta se pospone a la mañana | Hoja del Temporizador (despierto), página por la mañana |
| **Micrófono** (guía de nivel), **modo cuna**, **capa de fondo `mixWithOthers`** | 03 §6-§7.6 | Fuera de 1.0 y 1.1 / decisión del plan de funciones |
| **Watch** (toque = pausa, corona, "+15 min", "Madrugada · 20 min") | 1.1 (03 §7.7); E6 | 09-ECOSISTEMA |
| **Timbre, segundos en la cuenta atrás, sonido o háptico al terminar, notificación de fin, "Siesta" que despierta** | 03 §6; 02 §4-§5; la alarma es del usuario | Nada |

---

## 9. Preguntas abiertas

### Para el dueño

1. **Madrugada sin Océano (1.0).** La Marea v1 solo modula el Océano. Si la última mezcla no lo tiene, proponemos que Madrugada suene **sin Marea** y no suba el Océano (no cambiar la mezcla a las 4). Alternativa: subir Océano a 30 con fundido de 3 s y decirlo por la mañana. Recomendación: la primera; v2 lo resuelve en 1.1.
2. **Tope de "+15 min" para el usuario gratuito a oscuras.** Recomendación: **sin tope de noche**. "+15 min" siempre suma 15; el límite gratuito vive en la duración elegida, despierto. Un botón que dice +15 y hace +7 es exactamente el control que la lente de honestidad tacha, y cuesta cero. Si el dueño mantiene el tope (60 min restantes desde el momento de pulsar), la verdad la dice el propio estado (la hora real de fin) y VoiceOver anuncia los minutos reales; no habrá ninguna nota de venta de noche.
3. **Escudo: −6 %/h desde la segunda hora hasta el 50 %.** Son los números del brief E4; el jurado de "honestidad" preguntará por qué 6 y por qué 50. Propuesta de defensa: 6 % ≈ 0,5 dB por hora (imperceptible en el momento, −4 dB al amanecer); 50 % es el umbral por debajo del cual el enmascaramiento de ruido intermitente deja de funcionar según la experiencia del equipo **[a medir en el prototipo con auriculares y con altavoz]**. Si se prefiere, "baja un poco cada hora" admite 4-8 % sin tocar el copy.
4. **"Toda la noche" como estado de Noche sin temporizador.** Tomado de Marea. La alternativa "Sonando" repite lo que el horizonte ya dice. Confirmar la palabra (E7 la revisa).
5. **Transición página ↔ Noche de 2 s.** 03 §3.7 la fija y esta entrega la cumple. El jurado de las 3 de la mañana responde que 2 s se notan cuando se toca "Noche" para pausar acto seguido (la página fundiéndose con el sonido aún sonando se percibe como "no ha hecho nada", aunque el toque funcione desde el primer fotograma) y propone 1 s para las entradas con la pantalla encendida (E1/E3/E5/E6), 250 ms con Reduce Motion, y 2 s solo para el cambio de fase de luminancia (M24). Es una constante de 03 §3.7: la decisión es del dueño y de E1; aquí se deja escrita la propuesta y no se cambia.
6. **Los nombres "Hasta dormirme" y "Escudo nocturno" (03 §5).** Dos jurados los señalan: "Hasta dormirme" promete un resultado que 1.0 no detecta (el fundido por quietud es 1.1); "Escudo nocturno" es la única metáfora de la entrega. Propuestas para E7 y el dueño: "Para dormirme" ["To fall asleep"] (misma longitud, dice la intención sin la promesa) y "Hasta la mañana" ["Until morning"] (paralelo a "Hasta dormirme"; subtítulo "baja un poco cada hora"; claves `timer.mode.untilMorning*`). Vienen de 03 §5, así que aquí se mantienen tal cual; si se cambian, es una sustitución en el catálogo y nada se mueve.
7. **Siesta como fila propia.** El jurado de primera impresión pregunta si "Siesta" no es "Hasta dormirme" con 20 min. 03 §5 la fija como modo, y esta entrega la defiende por el fundido de 2 min (un fundido de 10 min sobre una siesta de 20 es media siesta apagándose) y por no entrar jamás en Noche ni al bloquear: dos reglas que, absorbidas en "Hasta dormirme", pasarían a depender de la duración elegida y habría que explicarlas. Si el dueño prefiere absorberla: fundido = 25 % del total si el temporizador es < 40 min, y la hoja queda en tres filas.

### Para E1, E2, E3 y E7

8. **Propuestas a 03 §4.5 ("Pantalla como botón").** (a) "Parar" en Madrugada: el jurado de las 3 de la mañana señala que Noche y Madrugada son casi idénticas a ciegas y que el mismo punto del pulgar significa "más sonido" en Noche y "apagar" en Madrugada; propone quitar "Parar" de la pantalla (el toque ya pausa; una pausa en Madrugada terminaría la sesión sola a los 5 min) y dejarlo en la Isla, en VoiceOver y en los controles visibles, o, si hay botón, que sea "+10 min". 03 §4.5 y §5 fijan "Parar": esta entrega lo mantiene y lo deja escrito para E1 y el dueño. (b) "−15 min" en los controles visibles: 03 §1.3 y §4.5 fijan "−15 · pausa · +15"; el jurado propone "pausa · +15" (acortar ya vive en la hoja; nadie lo necesita medio dormido). Esta entrega los mantiene, pero los apila para que "+15 min" no cambie nunca de sitio ni de tamaño (§2.4). (c) Pulsación larga: disparar al soltar, solo si el dedo estuvo quieto entre 0,6 y 2 s (una mano apoyada no vuelve a la página). Esta entrega ya lo hace (S1) y propone escribirlo en 03.
9. **"Noche" con la sesión parada = Play + Noche (E2).** La barra es de E2; esta entrega necesita que la palabra funcione siempre (§4.1 E1). Coordinar la etiqueta de VoiceOver (`a11y.night.enter.hint`).
10. **La hoja del Temporizador en fase Descenso también desde la página nocturna.** Declarado en §2.1 con su razón (03 §3.1: `hoja` es "otra habitación"). Si E1 o el dueño prefieren la hoja en `texto-noche` entre las 22:00 y las 07:00, es una fila de M24.
11. **Horizonte: ⅓ de la altura total (y 284) o ⅓ bajo el área segura (y 323).** 03 dice las dos cosas (§1.3: "y = 284 en 852"; §3.5: "bajo el área segura superior"). Hemos cotado con 284 (la constante de Marea). E1 decide y todas las entregas se corrigen con una sustitución.
12. **Full Keyboard Access** no tiene indicador público para auto-activar los controles visibles; se cubre con el foco de teclado (§5(c)). Confirmar con E1 si hay señal alternativa.
13. **El ritmo de la línea de agua (E3, I0).** `BreathParameters` en `main` es inhale 0,4 / exhale 0,45 / reposo 0,15: a 6 por minuto la línea sube 4 s, baja 4,5 s y descansa 1,5 s. El "4:6" de 03 §4.3 no es lo que suena. O el motor pasa a 0,4 / 0,6 (cambia el oleaje) o 03 §4.3 corrige su 4:6. Esta entrega dibuja lo que suena (M18).
14. **Token que falta:** ninguno. Noche y Madrugada han necesitado solo `texto-noche` y `negro`; la hoja, los tokens de `hoja`. No proponemos ningún hex nuevo.

### Para los spikes de ingeniería (I0)

15. **[I0-1] Nivel maestro.** Acotado a lo que de verdad lo necesita: la rampa de 60 s del Escudo y el RMS por capa. El 0,6 de Madrugada, el 0,4 del altavoz y el arrastre vertical van a `engine.mainMixerNode.outputVolume`, que ya existe (`buildGraph` lo fija a 1), y pierden la marca [spike]. El fundido final de 10 min ya corre en el hilo de audio con `FadeCurve.unity`; lo único que hace falta es contar muestras en entero (§2.1.4). **Y quitar el ticker**: el `Timer` de 0,25 s de `SleepTimerController` son cuatro despertares por segundo del hilo principal toda la noche y `@Published remaining` a 4 Hz recompone cualquier vista que observe el temporizador; se sustituye por dos timers de un disparo calculados desde `endDate` (inicio del fundido, fin), con tolerancia, como ya hace `BreathingGuideController.schedule(at:)`; `remaining` pasa a ser `endDate - now` bajo demanda y las tres pantallas lo leen dentro de su `TimelineView` por minuto. Con eso, Noche bloqueada = 0 trabajo salvo el audio (03 §3.7).
16. **[I0] Las reglas de los 20 min son perezosas** (§4.3 regla 7): `pausedAt` persistido; evaluación al siguiente despertar; `staleDate` en la Live Activity. Confirmar que ActivityKit pinta el estado stale sin la app en iOS 17.
17. **[I0-3] `AudioPlaybackIntent` sobre una Live Activity terminada y re-emisión > 8 h.** Si no es posible, la entrada principal de Madrugada pasa a ser el Centro de control y el botón de Acción (iOS 18) y, en iOS 17, el widget de bloqueo con un intent "Madrugada" (E6). La pantalla Madrugada no cambia.
18. **[I0-4] `pauseCommand` de AirPods en iOS 26.** Confirmar que llega por `MPRemoteCommandCenter` y no como interrupción. En cualquier caso no se etiqueta la causa: es el mismo comando que la pausa manual.
19. **[I0-5] CoreMotion quieto-horizontal con audio en segundo plano.** Decide la háptica de "+15 min" y de la pulsación larga, y en 1.1 el fundido por quietud. Si el coste de energía supera el 2 % de la noche, la regla pasa a "nunca vibra de noche" y la pulsación larga pierde su háptico (se compensa con la frase de primera vez).
20. **`AudioSessionObserver`**: leer `AVAudioSessionInterruptionReasonKey` y enrutar `.routeDisconnected` a `onHeadphonesUnplugged` (§4.3 regla 8); `pause(resumeLater:fadeOut:)` con 1,5 s para el toque y 0,04 para rutas e interrupciones (regla 9); `SleepTimerController.extend(by:)`; `SleepAudioEngine.fadeIn(over:)`; `play(mode: .smallHours)` y la excepción de `refreshEntitledAudio` (§2.3.3).

---

## 10. Autoevaluación

### 10.1 Puerta de formato (03 §8.3, punto 1)

| Requisito | Cumplido | Dónde |
|---|---|---|
| Tabla de movimiento con señal del motor, duración / curva, Reduce Motion, pantalla apagada (Always-On no aplica a la app: se dice una vez) | Sí, 27 filas | §5(a) |
| Tabla VoiceOver por control: etiqueta / valor / pista / rasgos / acciones | Sí, 24 filas + la fila de anuncios; orden de lectura de Noche y de Madrugada | §5(b) |
| Tabla gesto → alternativa sin gesto → Control por botón → teclado / Pointer | Sí, 12 filas | §5(c) |
| Dynamic Type por tramo (xS-L · xL-xxxL · AX1-AX2 · AX3-AX5) para las tres pantallas | Sí | §5(d) |
| Catálogo de cadenas ES / EN por clave con contexto y longitud | Sí, 117 claves, una fila por clave | §5(e) |
| Todas las medidas en pt | Sí; posiciones para 17 Pro, 16e y SE; retícula de 4 salvo las dos cotas de SE que cuelgan del borde de pantalla (dicho en §6.1) | §2, §6.1 |
| Un único juego de hex, el de 03 §3 | Sí: en este documento no se escribe ningún hex, solo nombres de token; ningún token nuevo | §9.14 |
| Maqueta y texto coinciden | Los wireframes ASCII de §2 llevan las mismas cotas que las tablas de capas; todo lo que aparece en §3-§5 está dibujado en §2 (el `Stepper`, el contorno de Button Shapes y "Activar el Escudo" de la revisión 1 se han quitado por eso); la maqueta de alta fidelidad la construye E1 sobre esta especificación y se verifica en la puerta de dispositivo | §2 |

### 10.2 Las doce pruebas del brief (00 §4)

| P | Prueba | Cómo lo cumple esta entrega |
|---|---|---|
| P1 Noche manda | Noche y Madrugada se diseñaron primero (gris, una tinta, cero color); la hoja del Temporizador se derivó después y es la única superficie "despierta" de la entrega. Reloj a 8,03:1 (antes 2,7:1). Nada de Noche por debajo de 17 pt. |
| P2 Un gesto medio dormido | Pausar = un toque en cualquier punto (también tras una pausa por auriculares); prolongar = un botón de 64 pt que nunca se mueve ni cambia de tamaño; bajar = botones físicos o un arrastre vertical. Desde la app, el bloqueo (E6) y el Watch (1.1). Prueba a ciegas de cinco personas al cierre. |
| P3 Negro real, luz mínima | `negro` en Noche y Madrugada; < 4 % de píxeles encendidos **[a medir]**; cero colores distintos del gris en Noche y Madrugada; en la hoja, cero color. |
| P4 Lo que se mueve tiene causa | §5(a): cada fila nombra la señal. En Noche nada se mueve salvo un `Text` por minuto; en Madrugada, solo la línea de agua con `BreathCurve` (4 / 4,5 / 1,5 s: lo que suena). El fundido se ve como palabra ("Fundiendo · 8 min") porque de noche el horizonte no sigue el nivel: decisión declarada, no omisión. |
| P5 Tipografía primero, una familia | SF Pro; Noche usa los pasos 1, 3, 4 y 6 (cuatro); Madrugada 1, 3, 4 (tres); la hoja 1, 3, 5, 7, 8, 9 (seis, el máximo; el paso 1 solo mientras suena). Nada < 13 pt; nada < 17 pt de noche; nada < Medium de noche; Regular solo en la cifra ≥ 56. |
| P6 Aire antes que cajas | Cero rectángulos rellenos en las tres pantallas; hairlines horizontales como único separador; ningún borde cerrado (tampoco con Button Shapes). |
| P7 Estado por forma | Continuo / ausente; palabras; `checkmark`; la línea de agua respira o no está. Verificado en gris por construcción (no hay color que perder). |
| P8 44 y 64 | "+15 min", "Parar", "Seguir por el altavoz", "Volver" y los controles visibles: 64 de alto a todo el ancho o 164 × 64 con 24 de canal; pantalla completa como botón; nada esencial en la esquina superior; la hoja: filas 56-72. |
| P9 Nada bloquea el sonido | En Noche y Madrugada no hay nada Pro ni ninguna hoja; la hoja Pro solo aparece al **cerrar la hoja del Temporizador con un valor Pro**, despierto, nunca al plegar la rueda ni al tocar una fila, y si no se compra nada se pierde. Recorrido del día 8 en §4.2.6: 60 min sin ver una venta salvo la que se pide. |
| P10 Una pantalla, una decisión | §1: cuatro preguntas, una por pantalla; la hoja no contiene Noche ni Marea ni niveles (lo que el PR #3 mezcló en "Niveles"); un solo hueco de control para el dato exacto. |
| P11 Lo técnico, debajo del gesto | La duración exacta y la hora del Escudo viven detrás del hueco de control (rueda / selector); los ajustes de Noche en Ajustes, no en Noche. Ninguna acción habitual a más de dos toques: Temporizador → modo (uno); +15 (uno); Madrugada (uno desde el bloqueo). |
| P12 Componentes de Apple | `List`, `DatePicker`, `Picker` `.wheel`, `.sheet` con detents y `selection`, `checkmark`, `TimelineView(.everyMinute)` y `.periodic`, `ZStack` con opacidad para Noche; propios solo `FullScreenControl`, `SoundLine` (modo Noche), `TideLine` (modo Madrugada) y `HairlineAction`, todos de 03 §4 con sus seis estados en §3. Cero `glassEffect`. |

Desempate del brief: lo que esta entrega **quita** respecto a `main`, al PR #3 y a su propia revisión 1 sin perder función: la rejilla de cinco botones, "Personalizado", dos candados, "Restante", el temporizador de 60 forzado, el botón "Salir" que desaparecía, el reloj fino, cualquier gesto horizontal, cualquier hoja de noche, cualquier venta de noche, cualquier aviso al terminar; y de la revisión 1: una `HairlineAction`, un estado deshabilitado, dos etiquetas de "+15", una nota de 4 s, un segundo pie, cinco causas de pausa inventadas, dos marcas, un glifo, un `Stepper`, un contorno, un sufijo "am", un ticker y diecinueve claves.

---

## 11. Respuesta al jurado

Se ha corregido todo lo bloqueante y lo mayor que no contradice 03 §3-§4, y lo menor que iba en la misma dirección. Lo que sigue es lo **rechazado**, con su razón; cuando la propuesta merece llegar a 03 o al dueño, está además en §9.

| Jurado | Hallazgo | Por qué no se aplica |
|---|---|---|
| 3 de la mañana (mayor) | Quitar "Parar" de la pantalla Madrugada | 03 §4.5 ("'Parar' en Madrugada") y §5 fila 11 lo fijan. El argumento (el mismo punto del pulgar significa "más" en Noche y "apagar" en Madrugada) es bueno y se traslada a 03 en §9.8(a); mientras 03 no cambie, Madrugada lleva "Parar" |
| 3 de la mañana (mayor) / Honestidad (mayor) | Quitar la fila "Seguir por el altavoz" (M11) | 03 §1.2 la injerta explícitamente ("'Seguir por el altavoz' como segunda línea encima; '+15 min' no se mueve"). Se acepta lo esencial de ambos hallazgos: el toque reanuda con la regla del 40 en cualquier momento (sin callejón sin salida), y la fila se declara como la palabra visible de esa misma acción, no como una acción distinta (§2.2.2, §4.3 regla 3). En Madrugada sí se quita |
| 3 de la mañana (mayor) | Controles visibles sin "−15 min" ("pausa · +15") | 03 §1.3 y §4.5 fijan "−15 · pausa · +15". Se corrige lo que sí dependía de esta entrega: "+15 min" ya no cambia de sitio ni de tamaño (los controles se apilan encima, §2.4). La propuesta va a 03 en §9.8(b) |
| 3 de la mañana (menor) | Noche con la tinta de Descenso (`texto`) entre las 09:00 y las 20:00 | 03 §3.2 define la fase Noche por la pantalla, no por la hora: `texto-noche` siempre. Con E2 limitada a la ventana nocturna y sin Siesta, Noche de día solo se abre a mano por E1, y quien la abre a propósito acepta la pantalla nocturna (§2.2) |
| 3 de la mañana (menor) | Hoja del Temporizador en fase nocturna (`texto-noche`) desde la página nocturna | 03 §3.1 define `hoja` como "otra habitación" y 03 §3.2 reserva `texto-noche` a tres superficies. Se declara por escrito en §2.1 que la hoja va siempre en Descenso y por qué; la alternativa queda en §9.10 |
| 3 de la mañana (menor) | Transición página → Noche de 1 s | 03 §3.7 fija 2 s. La respuesta del jurado se recoge íntegra en §9.5 como propuesta al dueño y a E1 |
| 3 de la mañana (menor) | Quitar de Noche la nota "Nivel bajado al 40 para el altavoz" | 03 §1.3 la injerta con su texto ("Nunca reanudar por el altavoz por encima de 40 ('Nivel bajado al 40 para el altavoz')"). Se corrige lo que sí era defecto: ya no añade un quinto estilo (va en paso 6 Medium, en la fila de las frases de primera vez) y tiene posición en la tabla de capas |
| Honestidad (mayor) | La hoja Pro solo al tocar una `HairlineAction` explícita ("Activar más de 60 min") | Reintroduciría la segunda `HairlineAction` que 03 §4.6 prohíbe ("una por pantalla") y que tres jurados pidieron quitar, y 03 §4.7 dice literalmente "abre la hoja al confirmar". Se acepta la mitad honesta: plegar la rueda **no** confirma (quien gira por curiosidad no ve ninguna venta); confirmar es cerrar la hoja con un valor Pro vigente, la única "aceptación" que existe en una hoja sin "Aceptar" (§2.1.4) |
| Honestidad (mayor) | Mantener "60 min · más de 60 es Pro" / `timer.proBeyond60` hasta cerrar la hoja | Con la regla única de confirmación la hoja ya está cerrada cuando se vuelve de la hoja Pro: no hay dónde mostrarla, y la hoja Pro acaba de decirlo. Se mantiene solo el anuncio de VoiceOver (un cambio que el usuario ciego no ve). Se acepta en cambio la nota del día 8 (`timer.proWasFormat`, `timer.proWasShield`), que explica un cambio que nadie pidió |
| Honestidad (mayor) | "+15 min" sin tope para el usuario gratuito | No es de esta entrega: el reparto gratuito es de 03 §1.4 y §7.9 y del dueño. Se recomienda sin tope en §9.2 y, si el tope se mantiene, la pantalla y VoiceOver dicen la verdad sin nota de venta |
| Honestidad (menor) | `presentationDetents([.height(488), .large])` | 03 §4.10 fija `.medium` para el Temporizador. El pie entra en `.medium` sin tocar el detent: se quita el grupo de 32 pt (ya no hace falta: el hueco de control es una fila de la misma lista) y el pie cabe en una línea en Large (§2.1.1) |
| Honestidad (menor) | Renombrar "Hasta dormirme" → "Para dormirme" | Viene de 03 §5. Se traslada a E7 y al dueño en §9.6 |
| Plataforma (menor) | `a11y.night.screen` = "Pantalla de noche" como nombre del elemento | Se ha tomado la otra mitad del mismo hallazgo, compartida por tres jurados: el elemento tiene una sola etiqueta, la frase de estado; "Pantalla de noche" desaparece del documento (dos anuncios a las 3 de la mañana son uno de más) |
| Plataforma (menor) | Una sola ventana nocturna (20:00-09:00) para E2, E3, la página nocturna y las frases de Noche | 03 §3.2 fija 22:00-07:00 para la página nocturna y 03 §4.12 para las dos frases. Se unifica lo que sí era de esta entrega: E2 y E3 comparten 20:00-09:00 (una constante menos); las tres ventanas restantes se declaran en Convenciones con su origen |
| Plataforma (menor) | `a11y.timer.shield.untilFormat` = "Suena hasta las %@" | Se ha elegido la otra corrección, pedida por cuatro jurados: "Suena hasta las" desaparece del documento; la cifra de Escudo lleva solo la hora y la línea de debajo reutiliza el subtítulo del modo |
| Primera impresión (mayor) | Quitar la fila "Duración" (la rueda se despliega bajo la fila activa) | 03 §5 fila 8 nombra "Duración con 'pro' junto a los valores > 60". Se acepta en cambio la solución del jurado de restricción, que resuelve la misma crítica (nada se mueve, un solo dato exacto): un único hueco de control, siempre en el mismo sitio, que cambia solo de contenido con el modo (§2.1.1) |
| Primera impresión (menor) | Renombrar "Escudo nocturno" → "Hasta la mañana" | Viene de 03 §5. Se traslada a E7 y al dueño en §9.6 |
| Primera impresión (menor) | Absorber "Siesta" en "Hasta dormirme" | 03 §5 fila 8 la fija como modo. La razón para una fila propia (el fundido de 2 min y no entrar jamás en Noche) está escrita en §9.7, como pedía el propio jurado |
| Restricción (mayor, variante b) | Añadir "Seguir por el altavoz" a Madrugada | Se ha tomado la variante restrictiva del mismo hallazgo: Madrugada no la ofrece; el toque reanuda con la regla del 40 (§2.3.2) |
