# SleepNoise · 10 · Guía de copy y String Catalog

**Equipo E7 · Copy y String Catalog · 16 de noviembre de 2026 · Documento 10 de la serie de diseño**

Entrega transversal de la fase de especificación. Fija la voz, el glosario, las dos listas negras y **todas las cadenas de interfaz de 1.0** (más las de 1.1 marcadas) para las superficies del inventario §5 de 03 (30, más "Cómo se genera" y "Lo que no hay" que la reconciliación añade, C38). Las cadenas de §5e son definitivas y exactas: son las que se compilan en `Localizable.xcstrings` y en `AppShortcuts.xcstrings`. **Reconciliación del 16-11-2026 aplicada** (`docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`): esta guía es la fuente de verdad del vocabulario (§3 de la reconciliación = §0.2 de aquí) y el reparto gratis/Pro es el de §4 de la reconciliación; los deltas aplicados y los rechazados están en §12. **Regla de nombres (C15):** sustantivo sin adjetivo en ES; unidad léxica de una o dos palabras en EN (Marea/Tide, Descenso/Descent, Madrugada/Small hours, Manto/Blanket); "Breathing tide" solo en prosa de ficha.

**Insumos leídos completos:** 03-Dirección (§3 tokens, §4 componentes, §5 inventario y §8.3 puertas son ley aquí); el brief de E7 y los de E1-E6 y E8; `specs/tokens.md`, `specs/grafts.md`, `specs/decisions.md`; 00-Brief creativo (P1-P12, §7.1 y §7.2); 02-Materiales (§2.6 estados sin candados, §4 háptica, §7 accesibilidad); `concepts/grafito.md` entero (§15 es el punto de partida de este catálogo) y, por grep, `marea.md`, `dial.md` y `silencio.md` en lo que el director injertó; el código de `main` (`AccessPolicy.swift`, `SoundID.swift`, `MixerModel.swift`, `TrialClock.swift`, `Features/Breathing`, `Features/Timer`, `Features/Paywall`, `Features/Library`, `Resources/Localizable.xcstrings`, 109 claves); informe de mercado §1 y §5.2 (lista cerrada de lo que no se afirma) y §7.5; `REVIEW-PR3-2026-11-16.md` ("Encaje", hallazgos de interfaz y de catálogo).

**Convenciones.** Medidas en pt para 393 × 852 en tamaño Large. Hex: solo los de §3 de 03, nombrados por token (`negro`, `hoja`, `grafito`, `trazo`, `trazo-hoja`, `texto`, `texto2`, `texto3`, `texto-noche`, `índice`, `índice-noche`, `índice-ac`, `texto2-ac`, `texto3-ac`, `trazo-ac`; papel: `papel`, `tinta`, `tinta2`, `tinta3`, `ocre`, `trazo-papel`, `pulsado-papel`); si un valor no está en §3 no se escribe aquí. Textos ES con EN entre corchetes. **[a medir]** = no verificado en dispositivo. **[spike I0-n]** = depende de un spike de ingeniería de §8.1 de 03. **[1.1]** / **[1.2]** / **[2.0]** = fuera de 1.0, especificado para que entre sin rediseño (versión según §5 de la reconciliación). **[retirada por Cnn]** = clave que existía y la reconciliación quita; no se compila. **[E2]…[E8]** marca la entrega dueña de la pantalla donde vive cada cadena; E7 es dueño del texto, no de la pantalla. `{…}` = argumento de formato; en el catálogo se indica el tipo (`%lld`, `%@`, `Text(timerInterval:)`). Las versalitas se escriben en minúscula: son `.smallCaps()` tipográficas, nunca `uppercased()`.

**Cómo se usa este documento.** E1 compila §5e tal cual en el String Catalog semilla (una entrada por clave, `en` como idioma fuente, `es` y `es-419` como localizaciones; `es-419` hereda `es` salvo las siete entradas de §0.3). E2-E6 copian las cadenas por clave, nunca el texto, y si necesitan una que no existe la piden aquí (§9) antes de inventarla. E8 toma de §5e.15 el nombre, el subtítulo, las primeras líneas y las notas de versión. QA pasa el lint de palabras vetadas (§0.5) y el lint de claves huérfanas (§0.6) sobre el catálogo y sobre los `.md` de la serie 04-11.

---

## 0. Voz, glosario y listas negras

### 0.1 La voz en cinco reglas

1. **Corto.** La frase media de interfaz tiene cinco palabras; ninguna cadena de estado pasa de una línea en 393 pt a Large; ninguna nota pasa de dos. Si una idea necesita tres líneas, es una pantalla ("Qué sabemos"), no una nota.
2. **Concreto.** Se dice lo que pasa, con la cifra: "Se funde a las 03:42", "Sonando · sin trueno", "No se ha cobrado nada". Nunca "listo", "perfecto", "genial", "todo en orden".
3. **Sereno.** Segunda persona del singular (ES: tú; es-419: tú, nunca usted ni vos), sin exclamaciones, sin diminutivos, sin emojis, sin signos de interrogación salvo en la confirmación de borrado del sistema y en las preguntas de desambiguación de Siri (`requestDisambiguation`). Punto final en frases completas; sin punto en etiquetas, estados y botones.
4. **Honesto.** Pro es una descripción ("· trueno es Pro", "Sonando · sin océano"), nunca una etiqueta de castigo. Un error dice qué ha pasado y qué no ha pasado ("Nada cambia: sigue sonando"). Una ausencia se dice como ausencia ("Sin cuenta"), no como mérito.
5. **Escrito, no traducido.** El inglés se escribe en inglés (en-US: *color*, *favorite*, *gray*; sin *whilst*); el español se escribe en español. Ninguna cadena se traduce palabra por palabra: "Small hours" no es "Pequeñas horas"; "Madrugada" no es "Dawn".

Cadencia de referencia: Bear ("No sign-up or tutorial"), Things ("Simply Powerful"), Aesop para la serenidad; Dark Noise ("White noise, refined") para la brevedad en inglés. Verbos de la app: suena, se funde, se retira, guía, guarda, carga, respira. Verbos prohibidos: desbloquea (se usa "abre": "Todo abierto"), activa (salvo en toggles del sistema), optimiza, mejora, relaja. Palabras que no se graban en la UI (reconciliación §3): "Escudo", "Tu instrumento", "Desbloquear", "envolvente", "chip", "perfil de entorno", "Lluvia fina", "Cama rosa", "Mar lento", "Noche de fuego", "Control fino", "Tormenta lejana", "v1/v2", "Oleaje/Swell" (como nombre de función), "Amanecer" (hasta 2.0), "Siesta" (hasta 1.1). Los números que ve el usuario son los del código (`displayPrice`, `displayName`, cuenta de capas, estado de la prueba): nunca constantes de copy.

### 0.2 Glosario ES / EN (vocabulario real, cerrado)

| Concepto | es-ES | es-419 | en-US | Nunca |
|---|---|---|---|---|
| El objeto que se guarda | mezcla | mezcla | mix | *preset*, *noche* (como sustantivo de mezcla), *blend*, *escena* |
| La pantalla de las guardadas | Mezclas | Mezclas | Mixes | *Noches*, *Biblioteca*, *Library* |
| La mezcla viva, sin guardar | Esta noche | Esta noche | Tonight | *Sin título*, *Actual* |
| Las cuatro de la casa | de la casa / mezcla de la casa | de la casa | from the house / house mix | *predeterminadas*, *presets*, *perfil de entorno*, *Apple*-anything |
| Sus nombres (C18) | Rosa y lluvia · Mar y viento · Marrón y hoguera · Pared | igual | Pink and rain · Sea and wind · Brown and fire · Wall | *Lluvia fina*, *Cama rosa*, *Mar lento*, *Noche de fuego*; nunca textura + adjetivo (C17) |
| Las del usuario | tuyas | tuyas | yours | *personalizadas*, *mis mezclas* |
| Cada sonido de la mezcla | capa | capa | layer | *sonido* (salvo en Siri), *pista*, *canal*, *track*, *ranura*, *modo* |
| El tope de capas | Seis a la vez | Seis a la vez | Six at once | *ranuras*, *huecos*, cifras de texturas en marketing |
| El elemento del catálogo | textura | textura | texture | *fondo*, *ambiente*, *sonido* (salvo Siri); nunca se cuentan en paywall ni ficha ("Todas las texturas") |
| Los tres ruidos | colores | colores | colors | *ruidos*, *noise colors* |
| Las dos secciones de Capas | colores / camas | colores / camas | colors / beds | *ruidos* / *fondos* (PR #3), *ambientes* |
| Nombre de cada textura (once en 1.0; libres: Blanco, Rosa, Marrón, Lluvia, Viento) | Blanco, Rosa, Marrón, Lluvia, Viento, Océano, Ventilador, Trueno, Hoguera, Arroyo, Cabina | igual (Fogata) | White, Pink, Brown, Rain, Wind, Ocean, Fan, Thunder, Campfire, Brook, Cabin | *Ruido blanco* en la fila (sí en Siri y en la ficha); *Tormenta lejana* (C13) |
| El timbre (fila al pie de Capas, bus maestro) | Timbre · Grave / Lejos | igual | Tone · Deep / Far | *Control fino*, *ecualizador*, *tilt*; gesto vertical |
| El valor de una capa | nivel | nivel | level | *volumen* (reservado al maestro), *ganancia* |
| El volumen de todo | volumen · Sonando · al n | volumen | volume · Playing · at n | *maestro* en pantalla (sí en código: `master` de sesión, nunca el del sistema); fila visible solo en Debajo de otro audio (1.1) |
| Lo que apaga el sonido | temporizador | temporizador | timer | *timer* en español, *sleep timer* en pantalla |
| Cómo termina | se funde / fundido | se funde / fundido | fades / fade | *desvanece*, *fade out* en español, *se apaga de golpe* |
| El modo de toda la noche | Manto | Manto | Blanket (pendiente de verificar en en-US, reconciliación §6.4) | *Escudo*, *Shield*, *Toda la noche* como modo (sí como sinónimo Siri) |
| El otro modo | Hasta dormirme | Hasta dormirme | Until I sleep | *Until I sleep*, *Sleep timer* |
| Siesta | Siesta [1.1] | Siesta | Nap | no se graba hasta 1.1 |
| La función respiratoria | Marea | Marea | Tide ("Breathing tide" solo en prosa de ficha) | *Respiración guiada*, *Breathe*, *ejercicio*, *Oleaje/Swell*, *v1/v2*; nunca marca |
| El ritual de la Marea (bajada 12→6, meseta, disolución) | Descenso | Descenso | Descent | *Descenso* como fase horaria (la fase es Día / Noche, interna: `.day` / `.night`) |
| Su velocidad | ritmo · n por minuto | ritmo · n por minuto | pace · n per minute | *frecuencia*, *bpm*, *rpm*, *resp/min* |
| Cómo acaba la Marea | se retira / disolviendo | se retira / disolviendo | recedes / dissolving | *termina*, *para*, *se apaga* |
| La pantalla negra | Noche | Noche | Night | *Modo noche*, *Bedtime*, *Dormir* como pantalla |
| La vuelta a dormir | Madrugada · Madrugada · 20 min (botón) | Madrugada | Small hours · Small hours · 20 min | *Dawn*, *Small hours mode*, *Modo madrugada* en pantalla, *Pausa de 20*, *Amanecer* (hasta 2.0) |
| Cómo acaba Madrugada | Se retira · n min | igual | Winding down · n min | *Fundiendo* (es otro estado, también en EN) |
| El estado de pago | Pro / `product.displayName` (hoy "SleepNoise Pro") | Pro | Pro / `product.displayName` | *Premium*, *Plus*, *Lifetime*, *Tu instrumento* |
| El modelo de pago | un solo pago / Una vez. | un solo pago / Una vez. | one payment / Once. | *vitalicio*, *lifetime* en español, *compra única*, *precio de lanzamiento* (C02) |
| La prueba | prueba · quedan n noches | igual | trial · n nights left | *trial* en español, *periodo de prueba*, *días gratis* |
| Empezarla (solo desde la hoja Pro, C07) | Empezar la prueba · 7 noches | igual | Start the trial · 7 nights | *Probar gratis*, cualquier arranque al pulsar Play |
| Lo que sigue sin pagar | gratis siempre | gratis siempre | always free | *versión gratuita*, *free tier*, *lite* |
| El acto de comprar | Comprar | Comprar | Buy | *Desbloquear*, *Unlock*, *Hazte Pro*, *Suscribir* |
| Restaurar | Restaurar compra | Restaurar compra | Restore purchase | *Restaurar compras* (es una) |
| Compartir en familia | En familia | En familia | With your family | *Familiar*, *Compartido*, *Family Sharing* en pantalla (sí en la ficha) |
| El iPhone | tu iPhone | tu iPhone | your iPhone | *dispositivo*, *device*, *teléfono* |
| Lo que la app no hace (pie, C09) | Sin suscripción. Sin cuenta. Sin rastreo. | igual | No subscription. No account. No tracking. | *privado*, *seguro*, *encriptado*, *Sin servidor* (deja de ser cierto en 1.1) |
| La página que lo lista | Lo que no hay | Lo que no hay | What's not here | *Privacidad* como título, *Política* |
| Cómo se hace el sonido (página) | Cómo se genera | Cómo se genera | How it's made | *Tecnología*, *Motor* |
| El registro local | Diagnóstico · Enviar informe | igual | Diagnostics · Send report | *Telemetría*, *Analíticas* |
| Escribir al autor (fila de Ajustes) | Escribir al autor | igual | Write to the author | *Soporte*, *Contacto*, formularios |
| La salida de audio | Salida | Salida | Output | *AirPlay* como pantalla, *Altavoces* |
| Dónde suena / a cuánto | Sonando · en {ruta} / Sonando · al {n} | igual | Playing · on {route} / Playing · at {n} | *Volumen bajado* |
| Tras quitarse los auriculares | Seguir por el altavoz (60 s) | Seguir por la bocina | Keep playing on speaker | reanudar sola por el altavoz |
| Sonar bajo otro audio (1.1) | Debajo de otro audio · Sonar debajo · Debajo de tu podcast | igual | Under other audio · Play underneath · Under your podcast | *modo Capa*, *mezclar con otras apps* |
| Ajustes de la pantalla Noche | Pasar sola a Noche · Mantener encendida | igual | Switch to Night · Keep screen on | *Modo noche*, *Auto-lock* |
| La guía de Atajos | Al acostarte | Al acostarte | At bedtime | *Automatización* como título |
| Sin sonido por error | Sin sonido | Sin sonido | No sound | *Error*, *Fallo*, códigos |
| Lo que no suena por Pro | · sin {capa} / · {capa} es Pro | igual | · without {layer} / · {layer} is Pro | *bloqueado*, *locked*, *no disponible* |
| Pantalla de evidencia | Qué sabemos | Qué sabemos | What we know | *Ciencia*, *Evidencia*, *Estudios*; ningún término clínico, sin excepción (C54) |
| El sonido como hecho | se fabrica en tu iPhone / nunca se repite | se genera en tu iPhone / nunca se repite | made on your iPhone / never loops | *procedural*, *generativo* en pantalla, *IA* |

### 0.3 es-419: lo que cambia respecto a es-ES

Siete entradas; el resto hereda es-ES. No cambia la voz (tú), no cambian los nombres de textura ni "Madrugada" ni "Manto". Una lista de comprobación para QA (claves que *podrían* cambiar y no cambian: `comun.ahora_no`, `capas.fan.detalle` ("abanico" es MX coloquial), `sound.brook`, `temporizador.siesta` [1.1], `pro.pie`, `sabemos.pie`) va en una nota del catálogo, no en esta tabla: aquí solo lo que cambia.

| Clave | es-ES | es-419 | Por qué |
|---|---|---|---|
| `estado.pausa.auriculares` | En pausa · auriculares | En pausa · audífonos | "auriculares" es España; "audífonos" en MX, CO, CL, PE |
| `ruta.seguir_altavoz` | Seguir por el altavoz | Seguir por la bocina | "altavoz" se entiende, "bocina" es lo que se dice en MX y CA; AR y UY dicen "parlante": se elige "bocina" por población (una sola clave para página y Noche, C49) |
| `sound.campfire` | Hoguera | Fogata | "hoguera" en LatAm suena a hoguera de San Juan; "fogata" es la palabra |
| `pro.incluye.texturas.detalle` | …trueno, hoguera, arroyo… | …trueno, fogata, arroyo… | idem |
| `mezcla.casa.marron_hoguera` | Marrón y hoguera | Marrón y fogata | idem |
| Ficha de App Store, primera línea de la descripción (§5e.15; sin clave: no se compila) | SleepNoise fabrica en tu iPhone… | SleepNoise genera en tu iPhone… | "fabricar" suena industrial en LatAm; "generar" es neutro y es lo que dicen las reseñas |

Números y horas: `Text(.time)` y `DateFormatter` del sistema. es-ES: 24 h, "03:42"; es-419 y en-US: según la región del iPhone, "3:42 a. m." / "3:42 AM" (el sufijo lo pinta el sistema dentro de la frase con `Date.FormatStyle`; la app no compila "am" / "pm"). **Excepción (corrección de S-06, 17-11-2026): la hora como cifra de paso 1** (el reloj de Noche a 72 y la hora del Manto a 56 en la hoja del Temporizador) va sin sufijo, "2:14", como en 07 §2.2.2 y la maqueta; las frases ("Se funde a las 2:59 AM", "hasta las 7:00 AM", la fila Hora) lo conservan. Decimales: "29,99 €" (es-ES, es-419 con €), "$29.99" (en-US), "MX$ 599" (es-MX): siempre `Product.displayPrice`, nunca una cifra escrita a mano. Signo de minutos: "min" sin punto en los tres idiomas; "m" solo en la Isla Dinámica.

### 0.4 Lista negra 1 · Lo que no se afirma (cerrada; informe §5.2 y brief §7.2)

Vale para interfaz, ficha, web, notas de versión, Siri y respuestas de soporte, en los tres idiomas, **sin excepción**: también para "Qué sabemos" (C54; el plan la declaraba exenta del lint y deja de estarlo). El lint de QA (§0.5) la aplica como expresiones regulares sobre el catálogo y los documentos.

| No se afirma ni se insinúa | Lo que se dice en su lugar (y ya está en §5e) |
|---|---|
| Mejora el sueño, duermes mejor, calidad del sueño, te dormirás un X % más rápido, clínicamente / científicamente probado | "Enmascara los sonidos que te despiertan." · "Sonido que nunca se repite, fabricado en tu iPhone." |
| Sueño profundo, ondas lentas, ondas cerebrales, consolida la memoria | nada |
| Trata / cura / alivia, insomnio, terapia, tratamiento, clínico, grado médico, sanitario como promesa | "No tratamos nada; no es un producto sanitario." · "n participantes con dificultad para dormirse, según X" (plantilla de C54: el criterio de selección del estudio parafraseado, sin diagnóstico, con n y cita; el nombre del diagnóstico solo en Notes for Review) |
| Acúfenos / tinnitus como efecto, TRT | "n participantes con un zumbido constante en los oídos, según X" (solo como entrada de Qué sabemos con n y cita); la palabra, solo en keywords y Notes for Review |
| Nervio vago, sistema nervioso, ansiedad, estrés como efecto | "Te acompaña a respirar más despacio." · "Respirar a unas 6 veces por minuto se asocia en estudios a mayor variabilidad cardiaca." · "Empezar a 12 por minuto" (parámetro, nunca "según tu cuerpo") |
| Fase ligera, detecta tus fases, alarma inteligente | "Tu alarma no se toca." · (1.1) "subida suave" |
| Seguro para bebés, recomendado por… | fuera de 1.0 y 1.1 (modo cuna no existe) |
| IA, personalizado por IA, se adapta a tu cuerpo, sabe lo que necesitas, inteligente | "Se mezclan en tu iPhone mientras suenan." · (2.0, C34) "Mi ritmo nocturno · según Salud" con el dato a la vista |
| TDAH, foco, concentración como promesa de mezcla | las mezclas de la casa describen lo que llevan: "Rosa y lluvia", "Mar y viento", "Marrón y hoguera", "Pared"; nombres por problema solo en 1.1 con dato (C18) |
| Porcentajes de mejora, umbrales, cuestionarios, puntuaciones, rachas | nada; la app no mide nada |
| Superlativos vacíos: la mejor, increíble, mágico, perfecto, relajante como promesa, inmersivo | frases cortas con hecho: "Un solo pago." "Lo que no hay." |
| Comparaciones nominales con Apple o competidores ("a diferencia de…", "16 sonidos") | se dice lo que hacemos |
| Cifras de texturas en paywall o ficha ("once texturas", "siete Pro") y cifras de precio en capturas o descripción (C02, C04) | "Todas las texturas" · "Un solo pago." · el precio solo como `Product.displayPrice` en la hoja Pro |

### 0.5 Lista negra 2 · Palabras vetadas (el lint)

Dos listas, una por idioma, aplicadas **solo a la columna de ese idioma** del catálogo (`es` y `es-419` con la lista ES; `en` con la lista EN) y, en los `.md` de la serie 04-11, al texto fuera de acentos graves (el código y las claves heredadas del Anexo no se lintan) y fuera de las secciones que citan la lista (§0.4-§0.5, §8, §10, §11 y el Anexo de este documento). Expresiones con límite de palabra (`\b`), `grep -E -w`; las siglas sin `-i`. Coincidencia no declarada = fallo de build de documentación.

**ES** (`grep -i -E -w`): `timer`, `mix`, `preset`, `vitalicio`, `lifetime`, `premium`, `desbloque[a-z]*`, `unlock`, `activar pro`, `suscri[a-z]*` (salvo "Sin suscripción"), `insomn[a-z]*`, `ansied[a-z]*`, `terap[a-z]*`, `clínic[a-z]*`, `médic[a-z]*` (salvo "consejo médico"), `sanitari[a-z]*` (salvo "no es un producto sanitario"), `profund[a-z]*`, `relaj[a-z]*`, `inteligen[a-z]*`, `personaliz[a-z]*`, `mejora[a-z]*`, `mejor sueño`, `óptim[a-z]*`, `perfect[a-z]*`, `genial`, `increíble`, `mágic[a-z]*`, `protocolo`, `sesión de`, `módulo`, `semana 1`, `foco`, `concentración` (como nombre de mezcla), `noches` como sustantivo de mezcla guardada, `cerrar` (botón), `candado[s]?`, `bloquead[a-z]*`, `oferta`, `descuento`, `antes` seguido de una cifra con "€" o "$", `¡`, `!`, emojis, `Modo noche`, `Modo madrugada`, `luna`, `escudo`, `tu instrumento`, `envolvente`, `chip[s]?`, `perfil de entorno`, `lluvia fina`, `cama rosa`, `mar lento`, `noche de fuego`, `control fino`, `tormenta lejana`, `v1`, `v2`, `oleaje` (salvo `capas.ocean.detalle`), `amanecer` (hasta 2.0), `siesta` (hasta 1.1), `ranura[s]?`, `lanzamiento`, `once texturas`, `siete .*pro`. Sin `-i`: `\bIA\b`.

**EN** (`grep -i -E -w`): `preset`, `lifetime`, `premium`, `unlock[a-z]*`, `subscri[a-z]*` (salvo "No subscription"), `insomn[a-z]*`, `anxiet[a-z]*`, `therap[a-z]*`, `clinic[a-z]*`, `medical` (salvo "medical advice" y "not a medical product"), `deep sleep`, `relax[a-z]*`, `smart`, `personaliz[a-z]*`, `improve[a-z]*`, `better sleep`, `optimi[a-z]*`, `perfect[a-z]*`, `awesome`, `amazing`, `magic[a-z]*`, `protocol`, `module`, `focus` (as mix name), `nights` as a saved-mix noun, `close` (solo en claves de botón: `*.boton`, `comun.*`), `lock(ed)?` (salvo "Lock Screen"; "clock" no casa con `-w`), `offer`, `discount`, `was \$`, `!`, emojis, `Night mode`, `Dawn`, `moon`, `shield`, `envelope`, `chip[s]?`, `fine rain`, `pink bed`, `slow sea`, `swell` (salvo `capas.ocean.detalle`), `sunrise` (hasta 2.0), `nap` (hasta 1.1), `slot[s]?`, `launch price`, `Small hours mode`, `until I sleep`. Sin `-i`: `\bAI\b`.

Falsos positivos admitidos y anotados en el lint, por clave: "Sin suscripción" / "No subscription" (`lo_que_no_hay.pie`, captura 6); "consejo médico" / "medical advice" (`sabemos.pie`); "no es un producto sanitario" / "not a medical product" (`sabemos.2.cuerpo`); "Lock Screen" (notas de versión EN); "close the app" / "Close any app using the microphone" (`pagina.error.inicio.2` y `.3` EN: son frases, no botones); "no close strikes" (`capas.thunder.detalle` EN: adjetivo); "Noche" (la pantalla) y "noche" en "7 noches", "esta noche", "de noche"; "Focus" solo como nombre del Focus de Sueño de iOS en Ajustes; "Deep" en `capas.timbre.grave` (extremo de la fila Timbre: el lint EN solo veta `deep sleep`).

### 0.6 Lint de claves huérfanas

Toda clave escrita entre corchetes o acentos graves en §0-§4 de este documento y en los `.md` de 04-09 debe existir en la primera columna de §5e (incluidos §5e.16 y §5e.17). Comprobación: extraer `\[([a-z0-9_.]+)\]` y `` `([a-z]+(\.[a-z0-9_]+)+)` `` de §0-§4, quitar las claves heredadas del Anexo (`sound.*.detail`, `paywall.*`, `breath.*`, `timer.*`, `trial.*`, `mixes.*`, `common.*`, `control.play`, `control.pause`, `a11y.*`), y pasar `comm -23` contra la lista de §5e. Cero huérfanas es condición de cierre; el recuento real está en §10.

---

## 1. Intención (P10): la pregunta de cada pantalla y la frase que la responde

Cada superficie del inventario §5 de 03 responde a una pregunta. Esta tabla fija, además, **la única frase de copy que puede responderla**, para que ninguna entrega añada un título que explique el contenido (P10: si hace falta, la pantalla está mal partida).

| # | Superficie | Esp. | Pregunta | La frase que responde (ES [EN]) | Lo que esa pantalla nunca dice |
|---|---|---|---|---|---|
| 1-2 | Página principal | E2 | ¿Qué va a sonar? / ¿Esto se fabrica ahora? | El nombre de la mezcla ("Rosa y lluvia" ["Pink and rain"]) y la línea de estado ("En silencio" ["Silent"] / "Sonando · se funde a las 00:42" ["Playing · fades at 00:42"]) | "SleepNoise", "Bienvenido", "Pro" como título, cualquier promesa |
| 3 | Página nocturna (por procedencia: al volver de Noche, dura la sesión; sin salida por reloj, C40) | E2 | ¿Puedo bajar la lluvia sin encenderme la cara? | Las mismas cadenas en `texto-noche` con los pesos "De noche" de 03 §3.4; ningún texto nuevo; "pro" y "sin {capa}" describen y se quedan | tips, prueba, precio, hoja Pro (nada se vende en `NightWindow` 21:00–07:00) |
| 4 | Página · última noche de prueba, prueba terminada, error, interrupción | E2+E5 | ¿Qué cambia y qué no? | "prueba · última noche" ["trial · last night"]; "La prueba terminó. Lo que usaste sigue aquí." ["The trial is over. What you used is still here."]; "No se ha podido iniciar el sonido. Toca para reintentar." ["Couldn't start the sound. Tap to try again."]; "En pausa · auriculares" ["Paused · headphones"]; "Sonando · en Dormitorio" ["Playing · on Bedroom"] | "Error", códigos, "Actualiza a Pro"; ningún párrafo la primera noche (la prueba no arranca sola, C07) |
| 5 | Capas | E2 | ¿Qué capas, a qué nivel? | "colores" / "camas" y los once nombres con su subtítulo honesto; "Seis a la vez" ["Six at once"] al activar la séptima (C19); fila "Timbre" Grave–Lejos al pie (C29); "Se mezclan en tu iPhone mientras suenan. Nada se repite." ["Mixed on your iPhone as they play. Nothing loops."] | "Niveles", "Sonidos", "Biblioteca", iconos, ranuras, huecos |
| 6-7 | Marea | E3 | ¿Cómo respiro? | "Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla." ["Breathe in as the wave rises, out as it pulls back. No need to watch the screen."] | "ejercicio", "sesión", "relájate", "ansiedad", "v1/v2", "solo oleaje" |
| 8-9 | Temporizador (entero libre, C03) | E4 | ¿Cuándo se apaga? | "Hasta dormirme" ["Until I sleep"] · "Manto" ["Blanket"] (por hora, DatePicker, C22) · "Apagado" ["Off"] ("Siesta" ["Nap"] en 1.1, hueco reservado); "El sonido se funde; tu alarma no se toca." ["The sound fades; your alarm is never touched."] | "Sleep timer", "Personalizado" como modo, "timer", "pro" en cualquier duración |
| 10 | Noche | E4 | ¿Sigue todo bien? | "Se funde a las 03:42" ["Fades at 03:42"] / "En pausa" ["Paused"] / "Fundiendo · 8 min" ["Fading · 8 min"] (C31) / "hasta las 7:00" ["until 7:00"] / "Sonando · al 40" ["Playing · at 40"] (C51); "+15 min" solo si hay temporizador; terminada: "Madrugada · 20 min" en su hueco (C27) | nombre de la mezcla, "Pro", precio, tips (las dos frases de la primera vez son texto fijo, no tips, C65) |
| 11 | Madrugada (océano fijo a nivel bajo + Marea 8/min para todos, C05) | E4 | ¿Puedo volver a dormirme sin pensar? | "20 min" y "Parar" ["Stop"]; últimos 5 min: "Se retira · 4 min" ["Winding down · 4 min"] (C60) | la hora (salvo opt-in), "sin océano", "Pro", prueba, cualquier frase; nada al terminar; ningún imperativo de levantarse (va a Qué sabemos, C60) |
| 12-13 | Mezclas / guardar (3 gratis, sin límite con Pro) | E5 | ¿Cuál de mis mezclas? | "Esta noche" ["Tonight"] (la mezcla viva, no es una pantalla); "tuyas" ["yours"] / "de la casa" ["from the house"]: "Rosa y lluvia", "Mar y viento", "Marrón y hoguera", "Pared"; "Guardar como mezcla…" ["Save as a mix…"] | "Noches", "Biblioteca", "Favoritos", "Lluvia fina", "Cama rosa", "Mar lento" |
| 14 | Pro (título = `product.displayName`, C12) | E5 | ¿Cuánto, una vez, y qué sigue gratis? | `Product.displayPrice` + "Una vez." ["Once."]; "Un solo pago. Para siempre, en todos tus iPhone." ["One payment. Forever, on every iPhone you own."]; "Con Pro" ["With Pro"]: "Todas las texturas" … "En familia" / "Gratis siempre" ["Always free"]; "Empezar la prueba · 7 noches" ["Start the trial · 7 nights"]; comprado: recibo + "Escribir una reseña" | "Desbloquea", "Premium", "Oferta", precio de lanzamiento, precio tachado, "¿Qué es Pro?", "Tu instrumento", cifras de texturas, el temporizador |
| 15 | Prueba (empieza en la hoja Pro con la primera acción Pro, C07; estado en Keychain) | E5 | ¿Qué tengo y hasta cuándo? | "prueba · quedan 5 noches" ["trial · 5 nights left"], solo desde que empieza | cuenta atrás en horas, notificaciones, "caduca", cualquier arranque con Play, tarjetas la primera noche |
| 16 | Primer uso | E5+E2 | (ninguna: no hay pantalla) | la página en reposo con "Rosa y lluvia" y Play (la app no arranca sonando, C33); el único tip, al segundo arrastre y solo de día: "Arrastra sobre el nombre para cambiar el nivel." ["Drag across the name to change the level."] (C65) | "Bienvenido", "Empecemos", permisos, prueba |
| 17 | Qué sabemos | E5+E7 | ¿Qué sostiene cada frase? | tres afirmaciones con su estudio y su n (plantilla "n participantes con {criterio parafraseado}, según {cita}", C54), una entrada más sobre quedarse en vela (C60), "Lo que no sabemos" ["What we don't know"]; pie de dos líneas "Nada de lo anterior es consejo médico." ["None of this is medical advice."] | "insomnio", "ansiedad", "acúfenos", "demostrado", sellos, consejos en imperativo; ninguna palabra de la lista negra, sin excepción |
| 18 | Ajustes (lista de C58) | E5 | ¿Qué decide la app por mí y cómo lo cambio? | filas con nombre humano: "Pasar sola a Noche" ["Switch to Night"] (Al bloquear / 1 min / 3 min / Nunca), "Mantener encendida" ["Keep screen on"] (Mientras carga / Siempre / Nunca), "Madrugada no enseña la hora a propósito." ["Small hours hides the clock on purpose."], "Salida" ["Output"], "Lo que no hay" con "Sin suscripción. Sin cuenta. Sin rastreo." ["No subscription. No account. No tracking."], "Escribir al autor" ["Write to the author"] | "Configuración avanzada", "Cuenta", "Notificaciones", "Valorar", "abrir sin sonar", iCloud (1.1) |
| 19-21 | Live Activity recortada (1.0 solo en escenario A; 1.1 en B, C25), Isla compacta y mínima, StandBy | E6 | ¿Suena? ¿Cuánto queda? ¿Puedo prolongar? | nombre + versalita de estado + tiempo vivo ("38:12", `Text(timerInterval:)`); dos botones: pausa/play y "+15 min" (vacío en Manto); seis estados (C50); terminada: "madrugada · 20 min" ["small hours · 20 min"]; StandBy = la misma vista escalada con un solo control (pausa/play), texto ≥ 24 pt | "SleepNoise", "Pro", "prueba caducada", "bajando", "Abrir la app", Isla expandida, venta |
| 22 | Widgets (pequeño "Dormir", rectangular e inline de bloqueo en 1.0; mediano "Mezclas" 1.1; sin circular, C42) | E6 | ¿Puedo dormir con un toque? | "Dormir" ["Sleep"] cuando no suena; "sonando" + "38:12" vivo cuando suena; "Madrugada · 20 min" ["Small hours · 20 min"] entre 00:00 y 06:00 (C27) | "SleepNoise" en el pequeño, "Abrir", acento (una sola tinta `texto`, C61) |
| 23 | Centro de control + botón de Acción (1.0, corte sin coste en la semana 14, C26) | E6 | ¿Lo enciendo sin abrir nada? | toggle "SleepNoise"; botón "Madrugada" ["Small hours"]; pistas "Mantén para dormir" ["Hold for sleep"] / "Mantén para Madrugada" ["Hold for Small hours"] | "Modo", "Activar" |
| 24 | Siri / Atajos (siete intents con frase y dos sin frase, C43; "Al acostarte" es una página de texto) | E6 | ¿Puedo pedirlo con la voz? | "Pon ${applicationName}" ["Play ${applicationName}"]; respuestas sin exclamación: "Rosa y lluvia, quedan 38 minutos." ["Pink and rain, 38 minutes left."] | "¡Listo!", precios, "Pro", "Siesta" (hasta 1.1), el nombre de la app escrito en una frase |
| 25 | Focus de Sueño [1.1] | E6 | ¿La app sabe que es de noche? | "Abrir en Noche" ["Open in Night"] | venta de noche, línea matinal (no existe: C08) |
| 26 | Apple Watch [1.2] (C28; en 1.0 el reloj controla con Reproduciendo del sistema) | E6 | ¿Lo paro desde la muñeca? | nombre, "+15 min", "Madrugada · 20 min" ["Small hours · 20 min"] | precios, "Pro", más de dos botones |
| 27 | Icono | E8 | (sin texto) | — | — |
| 28 | Capturas y ficha | E8 | ¿Qué es y cómo se paga? | "Un solo pago." ["One payment."] sin cifra (C02); "Un toque y suena." ["One tap and it plays."] (C33); "Seis capas a la vez. Una línea cada una." (C19); "Lo que no hay." ["What's not here."] | superlativos, promesas de sueño, "#1", cifras de precio o de texturas, envolvente animada |
| 29 | Papel (modo claro) [1.1] (C32: 1.0 solo oscura) | E1 | (las mismas cadenas) | — | nada propio del día |
| 30 | Diagnóstico (anillo local acotado, C56) | E5 | ¿Puedo ayudar a arreglarlo? | "Anoche el sonido se detuvo a las 02:14." + "Enviar informe" ["Send report"] (abre tu correo con el texto); "Un registro de la noche, en tu teléfono. Solo sale si tú lo envías." ["A log of the night, on your phone. It only leaves if you send it."] | "Valora la app", "Contacta con soporte", "Sin datos personales" (las horas lo son) |
| 31 | Cómo se genera (una página, C38/C53) | E5+E7 | ¿Por qué no se repite? | "Se fabrica en tu iPhone mientras suena. No hay archivo ni bucle." + el tamaño en MB (de Ajustes) | "procedural", "IA", animaciones que "demuestran" |
| 32 | Lo que no hay (pie + página, C38) | E5+E7 | ¿Qué no hace la app? | "Sin suscripción. Sin cuenta. Sin rastreo."; "No te pediremos que la valores." (C55); "Un registro de la noche, en tu teléfono. Solo sale si tú lo envías." (C56) | "Sin servidor" (C09), "privado", "seguro" |

---

## 2. Anatomía del texto en cada pantalla

Esta guía no vuelve a dibujar las pantallas (eso lo hacen E2-E6); dibuja **dónde vive cada cadena**, con qué paso de la escala de nueve (§3.4 de 03), en qué token y con qué longitud máxima. Los wireframes están cotados en pt para 393 × 852 Large; `[clave]` remite a §5e y toda clave escrita aquí existe allí (§0.6). Área segura: 59 arriba, 34 abajo. Margen 20. Columna 353. Todas las cotas y son múltiplos de 4 salvo las del sistema (59 de área segura, 83 de barra); las versalitas de 13/18 ocupan una caja de 20.

### 2.1 Página principal [E2] · reposo, con prueba (noche 3)

```
 y                                           393
 0   ┌─────────────────────────────────────────┐
 59  │ (barra de estado del sistema)           │
 72  │ prueba · quedan 5 noches     [pro.prueba.estado]  paso 9 versalitas texto2 (caja 20; área táctil 44)
 96  │ Rosa y lluvia                [pagina.capas.y] paso 2 · 28/34 texto (una capa: [mezcla.nombre.auto.1])
 136 │ En silencio                  [pagina.estado.silencio] paso 7 texto2 (caja 20)
 160 │ (segunda línea de estado: sitio reservado, 64 pt de alto, texto centrado) [ruta.seguir_altavoz] · [estado.volumen] · [pagina.estado.manana.error] · [marea.estado.guiando.corto]
 224 │ ····························· (pleamar)│ ← banda del horizonte: 120 pt reservados SIEMPRE (y 224-344)
 284 │ ─────────────────────────────────────── │ ← horizonte: hairline trazo en reposo; índice 1-3 pt sonando; con Marea, la línea de agua dentro de la banda
 344 │ ····························· (bajamar)│ (las marcas de pleamar / bajamar solo se dibujan con Marea)
 348 │ ──────────────────────────────────────  │ hairline
     │ Rosa                                65  │ paso 5 texto · paso 9 texto2
     │ suave y equilibrado                     │ paso 7 texto2  [capas.pink.detalle]
 416 │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┄┄┄ │ línea de nivel 2 pt texto / 1 pt texto3 (a 12 del borde inferior de la fila)
 428 │ Lluvia                              40  │
     │ sobre el tejado                         │ [capas.rain.detalle]
 496 │ ━━━━━━━━━━━━━━━━━━━━━┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │
 508 │ Todas las capas                         │ [capas.todas] paso 5 texto · fila 56 (botón por rasgo y por Button Shapes; sin chevron, sin cifra)
 564 │ ──────────────────────────────────────  │ (32 de aire + hairline)
 596 │ Marea                              (○ ) │ [marea.titulo] paso 5 · toggle del sistema .tint(índice)
     │ Apagada                                 │ [marea.estado.apagada.fila] paso 7 texto2
 668 │ Temporizador     Hasta dormirme · 45 min│ [temporizador.titulo] · [temporizador.estado.dormirme]
 724 │                                         │ aire
 769 │  Mezclas          ( ▶ )          Noche  │ [barra.mezclas] 17 Medium · Disco · [barra.noche]
 852 └─────────────────────────────────────────┘
```

Nada de esta anatomía cambia de posición con el estado (03 §3.7): el horizonte está en y 284 en reposo, sonando y con Marea; la banda de 120 está reservada aunque no haya Marea, y la línea de agua crece dentro de ella sin mover nada. La última noche de la prueba y la primera sin ella, el párrafo de prueba ocupa el sitio de las dos líneas de estado (y 136-224: dos líneas 15/20 + "Entendido" 44) y mientras está a la vista la línea de estado no se muestra (el horizonte ya dice silencio o sonido por forma); al "Entendido" (o al Play la última noche) vuelve la línea de estado en su sitio. La primera noche no hay párrafo: la prueba no arranca sola (C07). Nada se desplaza.

| Elemento | Clave | Paso | Token | Medida | Longitud máx. | Comportamiento |
|---|---|---|---|---|---|---|
| Cabecera de prueba | `pro.prueba.estado` / `pro.prueba.estado.ultima` / `pro.prueba.estado.gratis` | 9 versalitas, tracking +2 % | `texto2` | y 72, x 20, caja 20, área táctil 44 | 40 car. | Botón → hoja Pro (solo fuera de `NightWindow`). Aparece solo desde que la prueba empieza (C07); desaparece con Pro; la versión "gratis siempre" desaparece tras 7 sesiones |
| Nombre de la mezcla | `pagina.capas.y` / `mezcla.nombre.auto.1` / `.auto.3` / `.auto.mas` o el nombre del usuario | 2 | `texto` | y 96, 28/34, 1 línea, `minimumScaleFactor(0.8)` solo si lo escribió el usuario | 24 car. (el campo corta a 24) | Toque: nada (en la página nocturna, vuelta a la página de día: 03 §3.2 / C40). Pulsación larga: `contextMenu` con `mezcla.menu.guardar`, `comun.renombrar`, `mezcla.menu.vaciar`. Si la mezcla cargada perdió capas Pro: `mezcla.nombre.sin` ("Mar y viento · sin Océano") |
| Línea de estado | `pagina.estado.*` | 7 | `texto2` | y 136, caja 20, 1 línea (2 desde xL) | 44 car. | Cambia con 250 ms de opacidad; VoiceOver la anuncia |
| Segunda línea de estado | `ruta.seguir_altavoz`, `estado.volumen`, `pagina.estado.manana.error`, `marea.estado.guiando.corto` / `marea.retira.hora` | 6 (botón) / 7 / 9 (versalita de la Marea) | `texto2` | y 160, sitio reservado de 64 pt de alto, texto centrado; área táctil 44 (64 en la página nocturna) | 44 car., 2 líneas admitidas | Solo una a la vez; la del altavoz 60 s (C49); hasta el primer toque la de la mañana; con Marea, la versalita toda la guía |
| Nombre de capa | `sound.{id}` | 5 | `texto` (`texto2` si Pro sin acceso) | fila de 80 de paso desde y 348 | 14 car. | Es el control (arrastre horizontal, C52; pulsación larga → Slider del sistema, C21); tocar una capa Pro sin acceso abre la hoja Pro de día y no hace nada de noche (C06, C08) |
| Subtítulo de capa | `capas.{id}.detalle` | 7 | `texto2` | bajo el nombre | 28 car. | Honesto, sin promesa |
| Valor | número tabular / `comun.pro` / `comun.pro.nivel` | 9 | `texto2` (17 `texto` bajo el dedo) | derecha, en su sitio | 8 car. | "pro · N" conserva el nivel guardado; la degradación nunca escribe (C23) |
| "y n más" | `capas.mas` | 5 | `texto` | fila 56 | 20 car. | Botón → Capas; plural |
| Tope de capas | `capas.tope` | 7 | `texto2` | 1 línea bajo la fila tocada, 3 s | 14 car. | "Seis a la vez" al activar la séptima; la capa no se añade (C19; tope del motor, no de la interfaz: ningún hueco) |
| Todas las capas | `capas.todas` | 5 | `texto` | fila 56, sin chevron ni cifra | 16 car. | Botón por rasgo `.button` y por Button Shapes (03 §3.6: cero glifos en la principal fuera de la barra) |
| Fila Marea | `marea.titulo` + `marea.estado.apagada.fila` / `marea.estado.apagada.pro` / `marea.estado.guiando.corto` | 5 + 7 (9 la versalita) | `texto` + `texto2` | fila 72 | 20 + 44 car. | Toggle del sistema `.tint(índice)` (03 §4.12). **Encender el toggle arranca el sonido** si no sonaba (el instrumento siempre suena, 03 §1.3): nunca hay índice sin audio. [Conflicto anotado para el director: sonando hay dos índices en la página, horizonte y toggle, contra 03 §3.1 regla 2; propuesta `.tint(texto)`: el estado del toggle ya se lee por forma y por palabra] |
| Fila Temporizador | `temporizador.titulo` + `temporizador.estado.*` | 5 + 7 | `texto` + `texto2` | fila 56 | 14 + 30 car. | Muestra el ajuste ("Hasta dormirme · 45 min"), no la cuenta: la cuenta vive en la línea de estado |
| Barra | `barra.mezclas` · Disco · `barra.noche` | 17 Medium | `texto` | 83 pt | 10 car. | AX4-AX5: glifos con `barra.mezclas.ax` / `barra.noche.ax` como etiqueta |
| Párrafo de prueba (última noche / primera sin prueba) | `prueba.ultima`, `prueba.terminada` + `comun.entendido` | 7 (botón: 6) | `texto2` | en el sitio de las dos líneas de estado (y 136-224): 2 líneas 15/20 + botón 44 | 96 car. | Una vez; nada se desplaza; nunca hoja; nunca la primera noche (C07) |
| Tip | `tip.arrastre` | 7 | `texto2` | 1 línea bajo la fila, 6 s | 60 car. | El único TipKit de la app (C65), `maxDisplayCount = 1`, sin fondo ni flecha; nunca en `NightWindow` |
| Error de audio | `pagina.error.inicio`, `.inicio.2`, `.inicio.3` + `diagnostico.enviar` | 7 (botón 44; 64 en la página nocturna) | `texto2` | en el sitio de la línea de estado (el botón "Enviar informe", en la segunda línea) | 60 car. | Sin rojo; `.announcement` |

Sonando, la misma anatomía con: horizonte en `índice` 1-3 pt; estado `pagina.estado.sonando.funde`; Marea activa: la línea de agua ocupa la banda (y 224-344) y en la segunda línea de estado va la versalita `marea.estado.guiando.corto` ("guiando · 6 por minuto") en paso 9; "inhala" / "exhala" (`marea.fase.*`) a la derecha de la banda durante tres respiraciones. La hora de retirada no se escribe en la página de día (está en la hoja, paso 7). **Página nocturna** (estado de tinta por procedencia: al volver de Noche, dura la sesión; C40): mismas cadenas, todo el texto en `texto-noche` y con los pesos de la columna "De noche" de 03 §3.4 (pasos 6, 7, 8 y 9 en Medium); con Marea, la segunda línea es `marea.retira.hora` ("Se retira a las 23:27") en paso 7 Medium en vez de la versalita (03 §3.4: versalitas nunca para un dato que se consulte de noche); los botones de la segunda línea miden 64 (03 §4.9); ningún tip, ninguna cadena de prueba, ningún precio y ninguna hoja Pro: tocar una fila Pro no hace nada y no hay línea matinal (C06, C08). "pro", "pro · N" y "sin {capa}" se quedan: describen (§3). La vuelta a la página de día (toque en el nombre; nunca por reloj, C40) es 2 s de opacidad (250 ms con Reduce Motion; 5a T21).

### 2.2 Capas [E2] · hoja `.large`, once texturas (C19), tope de seis a la vez

```
 y(hoja)
 0    ┌─ indicador del sistema ────────────────┐
 20   │ Capas                                  │ [capas.titulo] paso 3 · 22/28 Semibold texto
 56   │ ───────────────────────────────────────│ hairline trazo
 72   │ colores                                │ [capas.seccion.colores] paso 9 versalitas texto2 (caja 20)
 92   │ Blanco                                 │ [sound.white] paso 5 · [capas.white.detalle] paso 7 · nivel
 172  │ Rosa                                65 │ [sound.pink] · [capas.pink.detalle]
 252  │ Marrón                                 │ [sound.brown] · [capas.brown.detalle]
 332  │ (32 de aire)                           │
 364  │ camas                                  │ [capas.seccion.camas] (caja 20)
 384  │ Lluvia                              40 │ [sound.rain] · [capas.rain.detalle]
 464  │ Viento                               0 │ [sound.wind] · [capas.wind.detalle] (libre, C04)
 544  │ Océano                        pro · 30 │ [capas.ocean.detalle] · [comun.pro.nivel]
 624  │ Ventilador                         pro │ nombre texto2 · [capas.fan.detalle] · [comun.pro]
      │ Trueno · Hoguera · Arroyo · Cabina     │ cuatro filas más de 80 (Pro)
      │ ───────────────────────────────────────│ hairline
      │ Timbre               Grave ━━━━┄ Lejos │ [capas.timbre] LevelRule del bus maestro, extremos [capas.timbre.grave] / [capas.timbre.lejos] paso 9 texto2 [spike I0-7]
      │ Se mezclan en tu iPhone mientras       │ [capas.nota] paso 8 texto2, 2 líneas
      │ suenan. Nada se repite.                │
 769  │  Mezclas          ( ❙❙ )         Noche │ barra presente: nada bloquea el sonido
```

Capas es fondo `negro` (03 §3.1: la hoja `hoja` es para Marea, Temporizador, Pro, Ajustes; Capas y Mezclas van en `negro`), hairlines en `trazo`. Pulsación larga en una fila: `Slider` del sistema de 44 pt debajo con etiqueta accesible `capas.deslizador` ("Nivel de {capa}") (C21). Capa Pro sin acceso al tocar: de día sube la hoja Pro con "Empezar la prueba · 7 noches" / "Comprar"; entre las 21:00 y las 07:00 (`NightWindow`) no pasa nada (C06, C08; la escucha de 30 s pasa a 1.1 y no abrirá hoja). Séptima capa activada: `capas.tope` ("Seis a la vez") 3 s y la capa no se añade (C19). Fila "Timbre" al pie: LevelRule sobre el bus maestro, extremos "Grave" / "Lejos" (C29; si el spike I0-7 falla, la fila cae a 1.1 sin cambiar el copy). Encabezado "camas": ocho filas (lluvia y viento libres; el resto Pro).

### 2.3 Marea [E3] · hoja `.large`, fondo `hoja`

```
 y(hoja)
 20   │ Marea                                  │ [marea.titulo] paso 3 texto
 56   │ Inhala mientras la ola sube, exhala    │ [marea.instruccion] paso 6 texto2, 2 líneas 17/22
      │ mientras se retira. No hace falta mirar│
      │ la pantalla.                           │
 128  │ ····························· (pleamar)│ marca hairline texto3
      │ ╲        línea de agua 2 pt texto      │ inhala   ← [marea.fase.inhala] paso 7 texto2
 248  │ ····························· (bajamar)│
 264  │ guiando · 6 por minuto                 │ [marea.estado.guiando.corto] paso 9 versalitas texto2 (caja 20)
 288  │ Se retira a las 23:27                  │ [marea.retira.hora] paso 7 texto2 (la hora, una sola vez, nunca en versalitas)
 316  │ ───────────────────────────────────────│ hairline trazo-hoja
 316  │ Marea                            (●  ) │ [marea.toggle] paso 5 · Toggle .tint(índice) (03 §4.12; conflicto anotado en §2.1)
 372  │ Ritmo                   Tranquilo · 6  │ [marea.ritmo.fila] · [marea.ritmo.tranquilo.corto]
 428  │ Descenso                         (●  ) │ [marea.descenso] toggle del ritual (1.0, C24)
      │ Empezar a 12 por minuto                │ [marea.ritmo] paso 7 texto2 (parámetro fijo, C34)
 500  │ Se retira a los                 15 min │ [marea.retira] · [marea.retira.valor] opciones 5·10·15·20·30
 556  │ Más ajustes                          › │ [marea.mas] → Háptica · [2.0] Mi ritmo nocturno (Salud)
 556  │ Respirar a unas 6 veces por minuto se  │ [marea.evidencia] paso 8 texto2 + enlace
      │ asocia en estudios a mayor variabilidad│ [sabemos.enlace] "Qué sabemos ›"
      │ cardiaca.                              │
```

Versalitas nunca para un dato que se consulte de noche: la hora de retirada va solo en paso 7 (`marea.retira.hora`, "Se retira a las 23:27"), bajo la versalita en la hoja y en la segunda línea de la página nocturna; de noche la versalita no se enseña (la hoja no se abre de noche; si se abre, solo paso 7). La fila "Se retira a los · 15 min" es el ajuste (duración), no la hora: son dos datos. Al terminar: `marea.retirada` ("Se ha retirado. El mar sigue.") 10 s en paso 7. Si la Marea subió el océano porque estaba a 0: `marea.oceano.subido` ("Océano subido a 40 para oír la marea.") 4 s. Descenso (C14, C24): el ritual de la Marea, bajada de 12 a 6 por minuto, meseta y disolución, en 1.0 sobre la profundidad común de todas las camas; la fila dice `marea.descenso` con el subtítulo `marea.ritmo` ("Empezar a 12 por minuto": parámetro, nunca Salud). "v1/v2" no aparece en ninguna etiqueta. Gestos por textura en 1.1; [2.0] Ritmo añade `marea.ritmo.mio` y `marea.ritmo.mio.sin` (Salud, C34). Sin acceso: el toggle abre la hoja Pro (C06); en Madrugada la Marea suena para todos a 8 por minuto, sin control (C05). VoiceOver expone el valor hablado "{n} por minuto" (C59); "solo oleaje" no es un estado.

### 2.4 Temporizador [E4] · hoja `.medium` → `.large`, fondo `hoja`

```
 20   │ Temporizador                           │ [temporizador.titulo] paso 3
 56   │ 38 min                                 │ [solo sonando] [comun.min] paso 1 · 56/64 Display tabular texto; cambio seco por minuto
 128  │ +15 min                                │ [comun.mas15] botón 64 paso 6 texto2 (03 §3.5: 64 en todas partes)
 192  │ ───────────────────────────────────────│
 192  │ Hasta dormirme                       ✓ │ [temporizador.dormirme] paso 5 · checkmark texto
      │ 45 min · se funde al final             │ [temporizador.dormirme.detalle] paso 7 texto2
 264  │ Manto                                  │ [temporizador.manto] (libre, C03)
      │ hasta las 07:00 · baja un poco a los 45 min│ [temporizador.manto.detalle] (−6 dB a los 45 min, C22)
 336  │ (hueco reservado para Siesta, 1.1)     │ [temporizador.siesta] [1.1]
 408  │ Apagado                                │ [temporizador.apagado]
 464  │ ───────────────────────────────────────│
 464  │ Duración                        45 min │ [temporizador.duracion] · Picker de rueda hasta 360 (Hasta dormirme) · [temporizador.hora] DatePicker (Manto)
 532  │ El sonido se funde; tu alarma no se    │ [temporizador.nota] paso 8 texto2 (la misma nota en los cuatro modos)
      │ toca.                                  │
```

El temporizador es entero libre (C03): la palabra "pro" no aparece en ninguna duración ni modo; `AccessPolicy.freeTimerMinutes` desaparece y 360 es el tope técnico de Hasta dormirme. Manto se programa por hora fija con el `DatePicker` del sistema (`temporizador.hora`), sin tope en minutos, y baja −6 dB a los 45 min por envolvente (C22). Siesta no está en 1.0: el selector reserva el hueco y la palabra no se graba hasta 1.1 (C30). El fundido final es de ganancia, 10–15 min, con estado "Fundiendo · n min" (C31).

### 2.5 Noche [E4] · pantalla completa, `negro`, una tinta

```
 y
 0    ┌─────────────────────────────────────────┐ sin barra de estado
 284  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ horizonte 2 pt texto-noche (continuo = suena; ausente = pausa)
 332  │                03:07                    │ hora del sistema, paso 1 · 72/80 Display Regular texto-noche (es-ES 24 h; 12 h donde la región lo pida, **sin sufijo**: la cifra es "2:14", nunca "2:14 AM"; corrección de S-06)
 428  │        Se funde a las 03:42             │ [noche.estado.funde] paso 3 · 22/28 Medium texto-noche
 472  │  (primera vez, 4 s) Puedes apagar la    │ [noche.primera] paso 6 Medium texto-noche
      │  pantalla. El sonido sigue.             │
      │  Mantén pulsado para volver             │ [noche.volver]
 652  │        Seguir por el altavoz            │ [ruta.seguir_altavoz] paso 4 Medium, 64 pt (y 652-716); 24 pt de canal hasta "+15 min"
 740  │               +15 min                   │ [comun.mas15] paso 4 · 20/25 Medium texto-noche · botón 64 a todo el ancho
 852  └─────────────────────────────────────────┘
```

Regla de la maqueta: entre dos objetivos sin borde hay ≥ 24 pt de canal (P8, 03 §3.5); por eso "Seguir por el altavoz" vive en y 652 y no pegado a "+15 min". Estados de la palabra (y 428): `noche.estado.funde` "Se funde a las 03:42" · `noche.estado.pausa` "En pausa" · `noche.estado.fundiendo` "Fundiendo · 8 min" (C31) · `noche.estado.hasta` "hasta las 7:00" (Manto) · `noche.estado.sonando` "Sonando" · `estado.volumen` "Sonando · al 40" (tras el arrastre vertical, 3 s; C51) · `noche.estado.sin_sonido` "Sin sonido" (error; toque reintenta) · `noche.estado.pausa.causa` "En pausa · auriculares". **"+15 min" nunca cambia de sitio ni de significado**, y Noche nunca crea un temporizador (C47): sin temporizador el hueco está vacío; con Hasta dormirme suma 15 a la cuenta ("Se funde a las 03:57"); con Manto mueve la hora fija 15 min y la palabra pasa a "hasta las 7:15". VoiceOver anuncia el resultado ("Quedan cincuenta y tres minutos" / "Hasta las siete y cuarto"). Noche terminada: el hueco del "+15 min" lo ocupa `madrugada.estado` "Madrugada · 20 min" (C27); nunca un gesto oculto. "Seguir por el altavoz" (`ruta.seguir_altavoz`) aparece encima, nunca en su lugar (lección del Reloj de iOS 26, 03 §1.2), y permanece 60 s (C49); nunca reanuda sola por el altavoz; el toque reanuda capado a 0,4 solo si la ruta cambió. La pantalla se atenúa a los 60 s y duerme por defecto (`isIdleTimerDisabled` según "Mantener encendida": mientras carga / siempre / nunca, C46). "atenuada" no es un estado (C47). "Controles visibles de noche" (fila de cuatro botones de 64 bajo la palabra de estado): `noche.ctl.menos15` "−15 min" · pausa (glifo `pause.fill`, etiqueta `ax.accion.pausar`) · `comun.mas15` "+15 min" · `noche.ctl.pagina` "Página" (vuelve a la página; coincide con el anuncio "Página" de §7), más un `Slider` "Volumen" (`ax.volumen`) debajo.

### 2.6 Madrugada [E4] · como Noche, sin hora

```
 284  │ ╲╱ línea de agua 1,5 pt texto-noche (o horizonte 2 pt sin Marea) │
 332  │                20 min                  │ [madrugada.quedan] paso 1 · 56/64 texto-noche; baja por minuto
 428  │           Se retira · 4 min            │ [madrugada.retirada] paso 3 Medium texto-noche, solo los últimos 5 min (C60)
 740  │                Parar                   │ [comun.parar] paso 4 Medium, 64 pt a todo el ancho
```

Ninguna otra cadena. Ni "Pro", ni "sin océano", ni la hora (opt-in `madrugada.ajuste.hora`), ni prueba, ni hoja (C05). Receta fija: océano a nivel bajo con Marea a 8 por minuto para todos, entrada 3 s, la Marea se retira hacia el minuto 13, el mar funde los últimos 5 min con "Se retira · n min" (`madrugada.retirada`; distinto de "Fundiendo" también en EN). Una sola tinta (sin ámbar). Al terminar, nada; en 1.0 no hay retirada luminosa (C60). En pausa: la línea desaparece; ninguna palabra (la cifra congelada y la ausencia de línea bastan; VoiceOver sí dice "En pausa").

### 2.7 Mezclas [E5] · pantalla empujada, `negro`

```
 (barra de navegación del sistema, título inline)
 112  │ Mezclas                                │ [mezclas.titulo] paso 3 (título de navegación)
 152  │ tuyas                                  │ [mezclas.seccion.tuyas] paso 9 versalitas texto2 (caja 20)
 172  │ Esta noche                             │ [mezclas.esta_noche] paso 5 texto (la mezcla viva, siempre primera; no es una pantalla)
      │ rosa 65 · lluvia 40                    │ receta paso 7 texto2  [mezclas.receta.capa] (formato v2: solo pares id + nivel, C09/C20)
 244  │ Verano con ventana                     │ nombre del usuario
      │ ventilador 70 · rosa 20 · ventilador es Pro │ [mezclas.receta.pro] inline, sin tachar
 316  │ (32 de aire)                           │
 348  │ de la casa                             │ [mezclas.seccion.casa] (caja 20)
 368  │ Rosa y lluvia                          │ [mezcla.casa.rosa_lluvia] · "rosa 20 · lluvia 55" (libre)
 440  │ Mar y viento                           │ [mezcla.casa.mar_viento] · "océano 50 · viento 20 · océano es Pro" (carga recortada sin acceso)
 512  │ Marrón y hoguera                       │ [mezcla.casa.marron_hoguera] · "marrón 40 · hoguera 30 · hoguera es Pro"
 584  │ Pared                                  │ [mezcla.casa.pared] · "marrón 40 · lluvia 30 · viento 30" (libre)
 672  │ La mezcla de esta noche se guarda      │ [mezclas.vacio] paso 6 texto2 (solo si "tuyas" está vacío: sustituye a la sección)
      │ desde su nombre.                       │
```

Deslizar: "Renombrar" / "Eliminar" del sistema (`comun.renombrar`, `comun.eliminar`; el rojo es del sistema). Cuarta mezcla propia sin Pro (`freeSavedMixLimit` = 3; sin límite con Pro): el menú dice `mezcla.menu.guardar.pro` ("Guardar como mezcla… · pro") y al tocar sube la hoja Pro con la mezcla intacta. Mezclas de la casa (C18): cuatro, receta de niveles, nunca cambian el temporizador; si la receta incluye una textura Pro sin acceso se carga recortada (como una mezcla guardada: `mezcla.nombre.sin`) y no abre la hoja; nombres por problema ("para ronquidos") solo en 1.1 con dato. Guardar encima de una mezcla cuya capa Pro no suena: `mezclas.guardada.sin` ("Guardada sin trueno") 3 s + `mezclas.conservar` ("Conservar el trueno") como botón de texto en la misma línea.

### 2.8 Pro [E5] · hoja `.large`, `hoja` · título = `product.displayName` (C12)

```
 24   │ sleepnoise pro                         │ [pro.titulo] = product.displayName en paso 9 versalitas texto2 (caja 20); nunca un nombre grabado
 48   │ 29,99 €                                │ [precio: Product.displayPrice, una sola vez] paso 1 · 56/64 texto; "—" hasta StoreKit
 112  │ Una vez.                               │ [pro.una_vez] paso 8 texto2 13/18 (bajo la cifra, siempre; injerto de 03 §1.3)
 136  │ Un solo pago. Para siempre, en todos   │ [pro.pie] paso 2 · 28/34 Display Medium texto, 2 líneas
      │ tus iPhone.                            │
 220  │ con pro                                │ [pro.con] paso 9 versalitas texto2 (caja 20)
 240  │ Todas las texturas                     │ [pro.incluye.texturas] paso 6 texto, filas 44 (sin número, C04)
      │ océano, ventilador, trueno, hoguera, arroyo y cabina │ [pro.incluye.texturas.detalle] paso 7 texto2
 284  │ Marea                                  │ [pro.incluye.marea]
 328  │ Mezclas sin límite                     │ [pro.incluye.mezclas]
 372  │ En familia                             │ [pro.familia] (Family Sharing, 1.0; la lista termina aquí)
 432  │ gratis siempre                         │ [pro.gratis] versalitas (caja 20)
 452  │ Blanco, rosa, marrón, lluvia y viento ·│ [pro.gratis.lista] paso 6 texto2, 2 líneas
      │ todo el temporizador · tres mezclas    │
 516  │ ═══════════════════════════════════════│ hairline 1,5 pt índice (solo con precio) [a decidir por el director: 03 §3.1 pide ≥ 1,5 pt para índice; 03 §4.6 escribe 1 pt]
 516  │     Empezar la prueba · 7 noches       │ [pro.prueba.empezar] paso 5 Semibold texto, fila 64 (primera acción Pro sin prueba usada, C07)
 580  │ ═══════════════════════════════════════│
 580  │             Comprar · 29,99 €          │ [pro.comprar] paso 5 Semibold texto, fila 64
 644  │ ═══════════════════════════════════════│
 660  │          Restaurar compra              │ [pro.restaurar] paso 6 texto2, 44
 720  │ Sin suscripción. Sin cuenta. Sin       │ [lo_que_no_hay.pie] paso 8 texto2 (C09)
      │ rastreo.                               │
```

La hoja usa seis estilos: pasos 1, 2, 5, 6, 7, 8 y 9 cuentan siete; el detalle de texturas (paso 7) y la nota (paso 8) comparten `texto2` 13/18 y se componen en el mismo estilo [E5 confirma ≤ 6]. Sin precio de lanzamiento (C02): un solo `displayPrice`, ninguna línea "antes/ahora", ninguna fecha. La prueba (C07): el botón `pro.prueba.empezar` ("Empezar la prueba · 7 noches") es la acción primaria mientras la prueba no se ha usado; tocar cualquier cosa Pro abre esta hoja; nunca arranca con Play; estado en Keychain. Comprado: la misma hoja es el recibo (estado `pro.ajustes.gracias` arriba, sin precio ni botones) con el enlace de texto `pro.resena` ("Escribir una reseña", C55: la única petición de reseña de la app, nunca de noche). Entre las 21:00 y las 07:00 la hoja no se abre (§1 regla 7). Estados bajo el botón (paso 8 `texto2`, una a la vez): `pro.sin_tienda` / `pro.sin_tienda.silencio` (el único estado sin producto; tras 8 s sin respuesta), `pro.fallo`, `pro.fallo.sin_confirmar`, `pro.pendiente`, `pro.restaurar.no`. Sin producto, el botón dice `pro.comprar.sin_precio` en `texto2` entre hairlines `trazo-hoja`, con `.notEnabled`. En curso, el propio botón dice `pro.comprando` ("Comprando…") / `pro.buscando` ("Buscando…"). Éxito: el botón se sustituye por `pro.gracias` ("Gracias. Todo abierto.") 1,5 s y la hoja se cierra. Bajo "Empezar la prueba · 7 noches" va `pro.prueba.empezar.nota`.

### 2.9 Qué sabemos [E5+E7] · pantalla empujada, `negro`, lectura 17/26

```
 112  │ Qué sabemos                   │ [sabemos.titulo] título de navegación
 152  │ Enmascara los sonidos que te despiertan.│ [sabemos.1.afirmacion] paso 5 Semibold 17/22 texto
 176  │ El ruido continuo redujo los despertares│ [sabemos.1.cuerpo] paso 6 Regular 17/26 texto, 5-6 líneas
      │ … (estudio · n)                        │ (el "por eso no decimos…" es el último párrafo de la misma cadena)
      │ ───────────────────────────────────────│ hairline
      │ Te acompaña a respirar más despacio.   │ [sabemos.2.*]
      │ Nunca se repite.                       │ [sabemos.3.*]
      │ Quedarse en la cama despierto.         │ [que_sabemos.en_vela] (C60: hallazgo con n y cita, nunca consejo)
      │ Lo que no sabemos                      │ [sabemos.4.titulo] paso 5 Semibold
      │ …                                      │ [sabemos.4.cuerpo]
      │ Nada de lo anterior es consejo médico. │ [sabemos.pie] paso 8 texto2, 2 líneas
      │ Si duermes mal muchas noches, habla    │
      │ con un profesional.                    │
```

Sin iconos, sin sellos, sin tablas, sin negritas ni cursivas dentro del cuerpo (los títulos de revista van en redonda, dentro del paréntesis: un estilo menos y ningún Markdown en el catálogo). Las entradas se escriben en §5e.11 enteras: son las únicas cadenas largas de la app y las únicas con `\n`. Plantilla de entrada (C54): una población se nombra por el criterio de selección del estudio parafraseado, sin diagnóstico: "n participantes con {criterio parafraseado}, según {cita}"; el nombre del diagnóstico solo aparece en Notes for Review; el lint corre también aquí, sin excepción.

### 2.10 Ajustes [E5] · `List` del sistema, `hoja`

Inventario cerrado por C58. Secciones (encabezados en versalitas paso 9 `texto2`): **noche** (`ajustes.noche.pasar_sola` "Pasar sola a Noche" → Al bloquear (defecto) · 1 min · 3 min · Nunca, C47; `madrugada.ajuste.hora` "Mostrar la hora en Madrugada" con nota `madrugada.ajuste.nota` "Madrugada no enseña la hora a propósito."; `ajustes.noche.controles` "Controles visibles de noche" con nota `ajustes.noche.controles.nota`; `ajustes.pantalla` "Mantener encendida" → Mientras carga (defecto) · Siempre · Nunca, C46), **háptica** (`marea.haptica` "Háptica" → Ninguna · Mínima; nota `marea.haptica.nota`; "Marcada" se va al Watch 1.2, C35), **al acostarte** (`ajustes.acostarte` + `ajustes.acostarte.sub`: una página de texto, C43), **salida** (`ajustes.salida` "Salida" con el `AVRoutePickerView` del sistema, C41), **pro** (`pro.ajustes.gracias` "{displayName} · gracias · 16 nov 2026" o la fila `pro.ajustes.ver` "{displayName}" con `pro.precio` "29,99 € · Una vez." a la derecha), **sobre** (`sabemos.titulo` "Qué sabemos", `lo_que_no_hay.titulo` "Lo que no hay" con el pie `lo_que_no_hay.pie`, `como.titulo` "Cómo se genera", `diagnostico.titulo` "Diagnóstico" + `ajustes.autor` "Escribir al autor" (abre el correo del usuario, la misma vía que "Enviar informe"), `ajustes.version` "Versión 1.0 · 4,2 MB"; → Novedades en 1.1). [1.1] `ajustes.icloud` "Tus mezclas en iCloud" (activo por defecto, C09) y `ajustes.debajo` "Debajo de otro audio" → Preguntar · Siempre · Nunca (C44). Sin "Cuenta", sin "Notificaciones", sin "Apariencia" (HIG), sin "abrir sin sonar" (C33), sin fila de reseña (C55), sin duración de Madrugada (receta fija, C05), sin guía AirPods (1.1, C58).

### 2.11 Live Activity, Isla, StandBy, widgets, Control [E6]

```
 Bloqueo 393 × 132
 ┌──────────────────────────────────────────────┐
 │ Rosa y lluvia                           38:12│ nombre 17 Semibold texto · Text(timerInterval:, countsDown: true, showsHours: false) 28 Medium tabular
 │ sonando · hasta dormirme                     │ [la.estado.sonando] versalita 13 Medium texto (única tinta)
 │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ horizonte 2 pt texto (continuo = suena)
 │ [   ❙❙   ]                     [  +15 min  ] │ dos botones de 64, posiciones fijas: pausa (fundido 3 s) / play · [comun.mas15] (vacío en Manto, C50)
 └──────────────────────────────────────────────┘
 Terminada: "Rosa y lluvia" · [la.estado.terminada] "se fundió a las 00:25" · [la.madrugada] "madrugada · 20 min" + ▶ (20 min; sigue hasta las 7 h 55 de actividad)
 Madrugada: [la.madrugada.prefijo] "madrugada · " + tiempo vivo "20:00"
```

Live Activity recortada (C25): 1.0 solo en el escenario A (dos parejas); en B pasa entera a 1.1 y la pantalla de bloqueo solo muestra el Reproduciendo del sistema. Seis estados (C50): sonando, guiando (Marea), en pausa · causa, fundiendo, terminada, madrugada; sin "prueba caducada" ni "bajando"; nunca venta; límite de 8 h asumido y cerrado por la app (un Manto más largo pierde la actividad a las 7 h 55 y sigue sonando).

Fuera de la app no hay reloj propio: toda cifra de tiempo es `Text(timerInterval:, countsDown: true, showsHours: false)` ("38:12") y la actividad solo se actualiza por hito (T20). Las claves de superficie son prefijos sin `%lld` que se componen con ese `Text`. Isla compacta y mínima: glifo + tiempo vivo ("38:12"; Madrugada: "20:00"; Manto: también el restante, "3:53" con `showsHours: true`, nunca la hora de fin pelada, que a un metro se lee como "son las siete"); sin Isla expandida (C25). StandBy = la misma vista escalada, sin diseño propio ni venta, con un solo control (pausa/play) y sin "+15" (C25): tiempo vivo 96 (con Manto, el restante "3:53", y la versalita dice `la.hasta` "hasta las 7:00"), versalita ≥ 24 pt (C62), horizonte 3 pt, **sin nombre de mezcla**, todo `texto`; sin unidad junto a la cifra; sin fondo (`containerBackground` removable, C42). Widget pequeño "Dormir" (interactivo): nombre 17 + versalita (`widget.silencio` / `widget.sonando`) + tiempo vivo 17 tabular + botón 44 con glifo; sin sesión, donde iba el tiempo: `widget.dormir` "Dormir" en 17 Semibold; entre las 00:00 y las 06:00 el botón dice `madrugada.estado` "Madrugada · 20 min" (C27, C42). Mediano "Mezclas" [1.1]: tres mezclas (`mezcla.casa.*` o las tres primeras "tuyas") con receta. Bloqueo rectangular e inline: `widget.inline.prefijo` + tiempo vivo / `widget.inline.silencio`; sin circular (C42). Fuera de la app, una sola tinta `texto` (C61). Centro de control: toggle `control.titulo` "SleepNoise" con `pagina.estado.sonando` / `pagina.estado.silencio` como valor; botón `madrugada.titulo` "Madrugada" con `control.madrugada.sub` "20 min"; botón de Acción: `accion.pista` / `accion.pista.madrugada`.

---

## 3. Estados: qué dice la app en cada uno

La regla de 03 §4.8: el estado es una palabra, nunca un color ni un fondo. Esta tabla fija **la palabra** de cada estado en cada superficie, para que las cinco entregas digan lo mismo en el mismo momento.

| Estado | Página (línea de estado, paso 7) | Noche (paso 3) | Live Activity (versalita 13) | Isla compacta | Widget pequeño | VoiceOver anuncia |
|---|---|---|---|---|---|---|
| Reposo (nada suena, nada cargado a > 0) | En silencio [Silent] | (Noche no se abre) | (no hay actividad) | — | Dormir [Sleep] | "En silencio" |
| Reposo con mezcla toda Pro sin acceso | En silencio · esta mezcla es Pro [Silent · this mix is Pro] | — | — | — | Dormir | "En silencio. Esta mezcla es Pro." |
| Sonando sin temporizador | Sonando [Playing] | Sonando [Playing] | sonando [playing] | ❙❙ | sonando [playing] | "Sonando" |
| Sonando con temporizador | Sonando · se funde a las 00:42 [Playing · fades at 00:42] | Se funde a las 00:42 [Fades at 00:42] | sonando · hasta dormirme [playing · until I sleep] | 38:12 (vivo) | sonando + 38:12 (vivo) | "Sonando. Se funde a las doce y cuarenta y dos." |
| Sonando, Manto | Sonando · hasta las 7:00 [Playing · until 7:00] | hasta las 7:00 [until 7:00] | sonando · manto [playing · blanket]; tiempo: hasta las 7:00 [until 7:00]; "+15" vacío (C50) | 3:53 (restante, vivo) | hasta las 7:00 [until 7:00] | "Sonando hasta las siete" |
| Sonando, Siesta [1.1] | Sonando · siesta · quedan 18 min [Playing · nap · 18 min left] | Se funde a las 15:20 | sonando · siesta [playing · nap] | 18:00 (vivo) | sonando + 18:00 (vivo) | "Sonando. Siesta, quedan dieciocho minutos." |
| Sonando por una ruta externa (C41) | Sonando · en Dormitorio [Playing · on Bedroom] (`estado.ruta`, `%@` = nombre de la ruta del sistema) | Sonando | sonando | ❙❙ | sonando | "Sonando en Dormitorio" |
| Nivel maestro tras el arrastre vertical (C51) | (no hay maestro en la página en 1.0) | Sonando · al 40 [Playing · at 40] (`estado.volumen`, 3 s) | — | — | — | "Volumen cuarenta por ciento" |
| Sonando sin una capa Pro | Sonando · sin trueno [Playing · without thunder] (también en la página nocturna: describe) | Se funde a las 00:42 (nunca "sin") | sonando · hasta dormirme | 38:12 | sonando | "Sonando sin trueno" |
| Sonando, mezcla por defecto forzada | Sonando · rosa a 40 [Playing · pink at 40] | Sonando | sonando | ❙❙ | sonando | "Sonando. Rosa a cuarenta." |
| Marea guiando | (segunda línea, versalita 9) guiando · 6 por minuto [guiding · 6 per minute]; página nocturna: Se retira a las 23:27 [Recedes at 23:27] en paso 7 | (nada: la guía está en el oído) | guiando · 6 por minuto [guiding · 6 per minute] | 38:12 (solo el tiempo; el ritmo se lee en la expandida) | sonando | "Marea guiando, seis por minuto" |
| Marea disolviendo | disolviendo [dissolving] | — | guiando · 6 por minuto | — | — | "Marea disolviéndose" |
| Marea retirada (10 s) | Se ha retirado. El mar sigue. [It has receded. The sea goes on.] | — | sonando · hasta dormirme | — | — | la frase |
| Fundiendo (fundido de ganancia de 10–15 min con cuenta entera, C31; corte de filtro solo si llega el bus) | Sonando · fundiendo · 8 min [Playing · fading · 8 min] | Fundiendo · 8 min [Fading · 8 min] | fundiendo [fading] | 8:00 | sonando | "Fundiendo, quedan ocho minutos" |
| Pausa (persona) | En pausa [Paused] | En pausa [Paused] | en pausa [paused] | ▶ | en pausa [paused] | "En pausa" |
| Pausa por el sistema (interrupción: alarma, otra app) | En pausa [Paused]; fuera de la ventana de la mañana reanuda con fundido de 3 s; dentro (05:00–11:00, o fin de Manto −60 min) la sesión termina: En silencio (C48) | En pausa | en pausa | ▶ | en pausa | "En pausa" |
| Pausa · llamada (`CXCallObserver`, 1.0, C48) | En pausa · llamada [Paused · call]; nunca termina la sesión fuera de la ventana de la mañana | En pausa · llamada | en pausa · llamada | ▶ | en pausa | "En pausa, llamada" |
| Pausa · auriculares fuera (caída de ruta: fundido 40 ms + pausa, C49) | En pausa · auriculares [Paused · headphones] + botón "Seguir por el altavoz" 60 s; nunca reanuda sola por el altavoz | En pausa · auriculares + "Seguir por el altavoz" encima de "+15 min" | en pausa · auriculares | ▶ | en pausa | "En pausa, auriculares desconectados. Seguir por el altavoz, botón." |
| Pausa · AirPods al dormirse (`pauseCommand` con auriculares = fundido de 3 s, C49) | En pausa · AirPods [Paused · AirPods] | En pausa | se pausó a las 00:12 · airpods [paused at 00:12 · airpods] | ▶ | en pausa | "En pausa. Tus AirPods pausaron el sonido a las doce y doce." |
| Reanudado por altavoz, capado a 0,4 (solo si la ruta cambió, C49) | Sonando · al 40 [Playing · at 40] (`estado.volumen`, segunda línea, hasta el primer toque) | Sonando · al 40 | sonando | ❙❙ | sonando | la frase |
| Terminada (sesión acabó) | En silencio | (vuelve a la página) | se fundió a las 00:25 · madrugada · 20 min [faded at 00:25 · small hours · 20 min] (hasta 4 h) | — | Dormir | "Sesión terminada. Madrugada, veinte minutos, botón." |
| Madrugada | (la app abre en Madrugada) | 20 min; últimos 5 min: Se retira · 4 min [Winding down · 4 min] (C60) | madrugada · [small hours · ] + 20:00 vivo | 20:00 | 20:00 | "Madrugada, quedan veinte minutos" |
| Pro sin acceso (fila) | nombre `texto2` + "pro" / "pro · 30" (el nivel se conserva, C23) | — | — | — | — | "Trueno, requiere Pro, botón. Toca dos veces para ver Pro." (de noche: sin pista) |
| Escucha de 30 s | [retirada por C06: pasa a 1.1 y no abrirá hoja] | — | — | — | — | — |
| Prueba (noches 2-7) | cabecera: prueba · quedan 5 noches [trial · 5 nights left] | — | — | — | — | "Prueba, quedan cinco noches, botón" |
| Prueba, última noche | prueba · última noche [trial · last night] | — | — | — | — | "Prueba, última noche" |
| Gratis (noche 8 → 7 sesiones) | cabecera: gratis siempre [always free] (botón → hoja Pro, que enumera lo gratis) | — | — | — | — | "Gratis siempre, botón" |
| Pro comprado | (ninguna mención) | — | — | — | — | — |
| Error al arrancar | No se ha podido iniciar el sonido. Toca para reintentar. [Couldn't start the sound. Tap to try again.] (botón) | Sin sonido [No sound] (toque reintenta) | (sin actividad) | — | Dormir | la frase, `.announcement` |
| Error, tercer intento | Cierra las apps que usen el micrófono y vuelve a intentarlo. [Close any app using the microphone and try again.] + botón "Enviar informe" [Send report] en la segunda línea | Sin sonido | — | — | — | la frase |
| Motor caído y no recuperado | En pausa · se interrumpió el sonido [Paused · the sound was interrupted] | Sin sonido | se detuvo a las 02:14 [stopped at 02:14] (30 min) | ▶ | Dormir | la frase |
| Mañana tras error | Anoche el sonido se detuvo a las 02:14. [Last night the sound stopped at 02:14.] + botón "Enviar informe" (la única petición de la app) | — | — | — | — | la frase |
| Vacío (Mezclas sin propias) | La mezcla de esta noche se guarda desde su nombre. [Tonight's mix is saved from its name.] | — | — | — | — | la frase |
| Cargando (StoreKit) | hoja Pro: "—" en la cifra; botón "Comprar" en `texto2`, hairlines `trazo-hoja`, `.notEnabled` | — | — | — | — | "Comprar SleepNoise Pro, precio no disponible" (`displayName` hablado) |
| Debajo de otro audio [1.1] (C44) | Debajo de tu podcast [Under your podcast] (`estado.debajo`); entrada con el botón "Sonar debajo" (`debajo.sonar`); fila de nivel visible solo en este estado | — | sonando | ❙❙ | sonando | la frase |
| Sin red (StoreKit) | hoja Pro: La tienda no responde. Nada cambia: sigue sonando. [The store isn't responding. Nothing changes: it keeps playing.] si `isPlaying`; si no, La tienda no responde. Nada cambia. [The store isn't responding. Nothing changes.] | — | — | — | — | la frase |
| Guardado | Guardada [Saved] 1,5 s junto al nombre | — | — | — | — | "Guardada" |
| Guardado parcial | Guardada sin trueno · Conservar el trueno [Saved without thunder · Keep thunder] | — | — | — | — | la frase + botón |
| Compra | Gracias. Todo abierto. [Thank you. Everything's open.] | — | — | — | — | la frase |
| Fallo de compra (cancelación o error antes del pago) | No se ha podido completar. No se ha cobrado nada. [Couldn't complete. Nothing was charged.] | — | — | — | — | la frase |
| Compra sin confirmar (`.unverified`, red tras la hoja del sistema) | No se ha podido confirmar. Si App Store te ha cobrado, Restaurar compra lo abre. [Couldn't confirm. If the App Store charged you, Restore purchase opens it.] | — | — | — | — | la frase |
| Pendiente (En familia) | Pendiente de aprobación familiar. Se abrirá solo cuando llegue. [Waiting for family approval. It will open on its own.] | — | — | — | — | la frase |

Reglas: **ningún estado se anuncia con sonido ni con háptica** salvo los de 03 §3.8; en Noche, Madrugada, Live Activity, Isla, StandBy y widgets no existen las palabras "Pro", "prueba" ni "sin {capa}"; en la página nocturna no existe ningún precio, ninguna cadena de prueba, ninguna hoja Pro ni "es Pro / requiere Pro", pero "pro", "pro · N" y "sin {capa}" permanecen porque describen lo que suena (nada se vende entre las 21:00 y las 07:00 y no hay línea matinal, C08); la Live Activity y los widgets usan la misma versalita que la página, en minúscula tipográfica; "Sin sonido" es la única cadena de error que puede verse de noche. StandBy no tiene columna propia: es la Live Activity escalada con un solo control (tiempo vivo 96 = la columna Isla; versalita ≥ 24 pt = la columna Live Activity; con Manto, cifra restante y versalita "hasta las 7:00"). Interrupciones (C48): fuera de la ventana de la mañana (05:00–11:00, o fin de Manto −60 min si hay Manto) toda interrupción reanuda con fundido de 3 s; dentro de ella ninguna reanuda (así gana la alarma); la regla es igual en todos los modos.

---

## 4. Flujos: lo que se lee en cada paso

Solo el texto. Las entradas, salidas e interrupciones están en 03 §4.5 y en E4; aquí se fija qué cadena aparece en cada paso para que el copy de las entregas coincida.

**4.1 Primera noche (sin tutorial).** Abre en reposo (la app nunca arranca sonando, C33) → "Rosa y lluvia" · "En silencio" (el horizonte en hairline ya dice silencio). Play → "Sonando · se funde a las 23:55" (el temporizador "Hasta dormirme · 45 min" ya está puesto). Segundo arrastre, solo de día → `tip.arrastre` 6 s. Bloqueo (entrada por defecto, C47) o "Noche" → `noche.primera` + `noche.volver` 4 s (texto fijo, no tips). Lo que no lee: precio, prueba, permiso, "SleepNoise", "Bienvenido". El autoarranque solo existe vía Atajos "Al acostarte".

**4.2 Sesión normal (tercera noche de prueba).** Cabecera `pro.prueba.estado` con n = 5 (solo si la prueba se empezó desde la hoja Pro). Guardar desde el nombre → campo `mezcla.guardar.campo` precargado con el nombre automático → `comun.guardar` → `mezclas.guardada` 1,5 s y `.success`. Bloqueo → Live Activity "Rosa y lluvia · sonando · hasta dormirme · 38:12". Fundido final → `la.estado.fundiendo` (C31); nada se lee al terminar.

**4.3 Ajustar a oscuras.** Noche: arrastre vertical = maestro de sesión con rampa → `estado.volumen` "Sonando · al 40" 3 s (C51; nunca toca el volumen del sistema). Pulsación larga 0,6 s → página nocturna, mismas cadenas en `texto-noche` y pesos "De noche" (03 §3.4); sin tips. Toque en la fila: nada (03 §1.2); arrastrar a 0 silencia; VoiceOver: acción "Silenciar". Toque en el nombre de la mezcla → vuelta a la página de día (03 §3.2; nunca por reloj, C40), 2 s de opacidad.

**4.4 Marea, 15 minutos.** Toggle on → si no sonaba, arranca el sonido (el instrumento siempre suena); versalita `marea.estado.guiando.corto` ("guiando · 6 por minuto") en la segunda línea y, en la hoja, `marea.retira.hora` ("Se retira a las 23:27") debajo en paso 7; "inhala" / "exhala" tres respiraciones; minuto 12 → "disolviendo"; minuto 15 → `marea.retirada` 10 s → vuelve "Sonando · se funde a las 00:42". Toggle off a mano → 30 s de disolución con "disolviendo". Con Descenso activo, la versalita empieza en "guiando · 12 por minuto" y baja hasta 6 (C24). Sin acceso → el toggle no se enciende y sube la hoja Pro de día (C06); de noche no pasa nada (C08); una mezcla cargada con Marea sin acceso dice "Sonando · sin Marea".

**4.5 Temporizador.** Elegir modo → la fila de la página dice `temporizador.estado.*` (el ajuste, nunca la cuenta). "+15 min" → la cifra cambia (`.numericText()`); VoiceOver "Quedan 53 minutos". Sin temporizador, "+15 min" no existe (Noche nunca crea uno, C47); con Manto mueve la hora fija 15 min (§2.5). Todo el temporizador es libre: ninguna cadena "pro" (C03). Alarma del sistema → "En pausa"; dentro de la ventana de la mañana (05:00–11:00, o fin de Manto −60 min) ninguna interrupción reanuda y la sesión termina: "En silencio" y la Live Activity se cierra; fuera de ella toda interrupción reanuda con fundido de 3 s (C48).

**4.6 Noche y vuelta.** Entrar → `noche.primera` solo la primera vez. Pausa en Noche → "En pausa"; reanudar → la palabra de estado vuelve. "+15 min" en Noche: solo si hay temporizador; con Hasta dormirme → la hora de la palabra avanza 15 min; con Manto → "hasta las 7:15" (§2.5). Noche terminada → el hueco del "+15 min" dice "Madrugada · 20 min" (C27). 20 min en pausa → la sesión termina; Live Activity "se fundió a las 00:25 · madrugada · 20 min". **Limitación escrita:** la reanudación sola al reconectar los auriculares y el cierre de sesión a los 20 min solo ocurren con la app despierta (Noche en pantalla): al pausar, `SleepAudioEngine.stop` desactiva la sesión y iOS suspende la app en segundos; bloqueada, la actividad se queda "en pausa · auriculares" y la sesión termina al siguiente arranque. [Alternativa a decidir con E4 / I0 como spike: mantener el motor rindiendo silencio durante la pausa, con coste de batería medido, para conservar la ventana de 20 min.] Vuelta → página nocturna (por procedencia, dura la sesión; C40) o página de día.

**4.7 Madrugada.** Live Activity terminada → botón ▶ junto a "madrugada · 20 min" → `AudioPlaybackIntent`, la app no se abre; la actividad pasa a "madrugada · quedan 20 min". Si enciende la pantalla → pantalla Madrugada: "20 min" y "Parar"; últimos 5 min "Se retira · n min". Al terminar → nada. Entradas, siempre un botón (C27): Siri "Madrugada en ${applicationName}", widget pequeño (00:00–06:00), pantalla de bloqueo (`widgetURL`), Noche terminada, Centro de control "Madrugada · 20 min"; sin doble toque. Receta fija (C05): océano a nivel bajo con Marea a 8 por minuto para todos; nunca prueba ni hoja Pro; la última mezcla no cuenta.

**4.8 Prueba: empezar, última noche y la primera sin ella.** La prueba empieza solo desde la hoja Pro con `pro.prueba.empezar` ("Empezar la prueba · 7 noches"), tras la primera acción Pro de día (tocar una textura Pro, encender la Marea, guardar la cuarta mezcla); nunca con Play (C07; `startTrialIfNeeded()` sale de `play()`; estado en Keychain). Desde entonces la cabecera dice `pro.prueba.estado` ("prueba · quedan 5 noches"). Última noche: `pro.prueba.estado.ultima`; en el sitio de la línea de estado `prueba.ultima` hasta el Play. La prueba termina **con la sesión**, nunca a medianoche (coincide con `endPlayback(canDowngrade:)`). Primera noche sin prueba: `pro.prueba.estado.gratis` ("gratis siempre"); en el sitio de la línea de estado `prueba.terminada` + "Entendido" una vez; la mezcla cargada conserva sus valores y nada se escribe en disco (C23): "Trueno" en `texto2` con "pro · 30"; Marea "Apagada · pro"; el temporizador no cambia (es libre, C03). Play → "Sonando · sin trueno". Tocar Trueno → hoja Pro de día; entre las 21:00 y las 07:00, nada (C06, C08). Tras 7 sesiones en gratuito la cabecera desaparece; la información queda en la hoja Pro ("Gratis siempre") y en Ajustes.

**4.9 Compra y restauración.** Abrir la hoja → "—" hasta `Product.products(for:)`; con precio, "Comprar · 29,99 €" entre hairlines de índice. Tocar → hoja del sistema; la nuestra no cambia. Éxito → `pro.gracias` 1,5 s; la capa Pro que estaba en escucha **no se corta**; la que estaba a "pro · 30" entra con fundido de 800 ms (la compra que se oye); cabecera de prueba desaparece; Ajustes `pro.ajustes.gracias`. Cancelación → nada. Fallo antes del pago o `.userCancelled` → `pro.fallo`. `.unverified` o error de red tras la hoja del sistema → `pro.fallo.sin_confirmar` (la transacción puede llegar luego por `Transaction.updates`; la app no afirma lo que no sabe). Pendiente → `pro.pendiente`. Restaurar → botón "Buscando…" → éxito como arriba / `pro.restaurar.no`. En familia → `pro.ajustes.familia`. Sin red → `pro.sin_tienda` (o `pro.sin_tienda.silencio` si nada suena), botón `pro.comprar.sin_precio` en `texto2` entre hairlines `trazo-hoja`.

**4.10 Mezcla guardada que pierde capas Pro.** Cargar "Mar y viento" sin acceso (también si es de la casa: carga recortada, nunca hoja, C18) → nombre `mezcla.nombre.sin` "Mar y viento · sin Océano" (03 §1.3); fila Marea "Apagada · pro"; en Mezclas la receta completa con "· océano es Pro" inline. Play → "Sonando · sin océano" si queda algo que suene; si no queda nada que suene, Play arranca Rosa a 40 y la línea dice "Sonando · rosa a 40" ["Playing · pink at 40"] (03 §1.3: el instrumento siempre suena). Tocar una fila Pro de día → hoja Pro; entre las 21:00 y las 07:00 nada (C06, C08). Guardar encima → `mezclas.guardada.sin` + `mezclas.conservar`; guardar conserva el nivel Pro sin diálogo (C23).

**4.11 Interrupciones (C48, C49).** Interrupción del sistema (alarma, otra app) → "En pausa"; llamada (`CXCallObserver`, 1.0) → "En pausa · llamada". Fuera de la ventana de la mañana (05:00–11:00, o fin de Manto −60 min) toda interrupción reanuda con fundido de 3 s y sin texto; dentro de ella ninguna reanuda y la sesión termina (la alarma de la mañana gana, también a un Hasta dormirme de 6 h puesto a la 1:00). Auriculares fuera (caída de ruta) → fundido de 40 ms + "En pausa · auriculares" + "Seguir por el altavoz" (44 pt de día, 64 en la página nocturna y en Noche) 60 s; nunca reanuda sola por el altavoz; el toque reanuda capado a 0,4 solo si la ruta cambió → "Sonando · al 40" (es el maestro de sesión, nunca el nivel de una capa: glosario §0.2). AirPods al dormirse (`pauseCommand` = fundido de 3 s) → "En pausa · AirPods"; no reanuda sola. Ruta externa → "Sonando · en Dormitorio" (C41). Nada se anuncia con sonido ni háptica.

**4.12 Error de audio (la escalera de Dial).** Primer fallo → `pagina.error.inicio` (botón). Segundo → `pagina.error.inicio.2` ("Si sigue sin sonar, cierra la app y vuelve a abrirla."). Tercero → `pagina.error.inicio.3` + `diagnostico.enviar` ("Enviar informe") como botón de texto. Caída nocturna recuperada → nada. No recuperada → Live Activity `la.estado.detenido` 30 min; mañana `pagina.estado.manana.error` en la línea de estado + `diagnostico.enviar` como botón en la segunda línea. Nunca alerta modal, código, rojo ni vibración.

**4.13 Primer uso de Siri / Atajos / Control.** Cada intent de reproducción es `AudioPlaybackIntent`: sin diálogo; siete intents con frase y dos sin frase (C43); todas las frases con `${applicationName}` (C10). Solo `siri.estado` habla: "Rosa y lluvia, quedan 38 minutos." / "Nada suena ahora." Siri nunca vende: una mezcla con capas Pro sin acceso suena sin ellas y Siri dice `siri.estado.sin` solo si se le pregunta el estado ("Rosa y lluvia, sin océano, quedan 38 minutos.").

---

## 5. Las cinco tablas obligatorias

Para una guía de copy, las tablas (a)-(d) recogen **el texto que se mueve, se lee, se sustituye y se reajusta**: lo que E7 debe garantizar en cada entrega. Las geometrías viven en E1-E6; aquí se fija qué cadena interviene y cómo.

### 5a. Movimiento del texto: elemento → señal del motor → duración/curva → Reduce Motion → Always-On / `isLuminanceReduced`

| # | Elemento textual | Señal del motor / causa | Duración · curva | Reduce Motion | Always-On · `isLuminanceReduced` · Noche |
|---|---|---|---|---|---|
| T1 | Línea de estado ("En silencio" ↔ "Sonando · …") | `isPlaying` y `timer` del modelo | 250 ms opacidad | igual | Live Activity: cambio en la siguiente actualización, sin animación |
| T2 | Valor de capa (13 → 17 pt, `texto2` → `texto`) | dedo sobre la fila (gesto), no el motor | 150 ms entrada / 250 ms salida, `.easeInOut`; la cifra sigue al dedo sin animar | igual (es tamaño y color, no posición) | n/a (de noche no se arrastra en Noche; en página nocturna igual, `texto-noche`) |
| T3 | "pro" / "pro · N" ↔ valor | compra o fin de prueba (`refreshAccess`; la degradación nunca escribe, C23) | 0: ocurre entre sesiones o al cerrar la hoja (250 ms opacidad) | igual | n/a |
| T4 | Versalita de la Marea ("guiando · 6 por minuto" → "disolviendo"); toggle on arranca el sonido si no sonaba (T1 a la vez) | `BreathingPhase` del controlador | 250 ms opacidad | igual | no se muestra en Noche; página nocturna: `marea.retira.hora` paso 7 en su lugar |
| T5 | "inhala" / "exhala" | fase de `BreathCurve` (ancla + `outputLatency`) | 250 ms opacidad; desaparece a la 3.ª exhalación en 500 ms | igual | no se dibuja de noche; `isLuminanceReduced`: se oculta |
| T6 | Cifra del ritmo durante el Descenso (ritual, 1.0, C24) ("12 por minuto" → "6") | periodo interpolado por el motor (curva de `bedDepth`) | cambio seco cada 30 s | igual | — |
| T7 | Nota "Se ha retirado. El mar sigue." | fin de la Marea | 250 ms in · 10 s · 500 ms out | igual | no de noche |
| T8 | Cifra del temporizador en la hoja ("38 min") | reloj del temporizador | cambio seco por minuto (`comun.min`); nada cambia por segundo dentro de la app | — | — |
| T9 | "+15 min" → cifra nueva (hoja, Noche, Live Activity) | toque | 250 ms `.contentTransition(.numericText())` | opacidad | Live Activity: inmediata |
| T10 | Reloj de Noche | tiempo | `TimelineView(.everyMinute)` + `Date.FormatStyle` hora/minuto; cambio seco por minuto (03 §3.7 escribe `Text(.time)` a 1 Hz: `Text(date, style: .time)` no se actualiza sola; el cambio visible sigue siendo por minuto; anotado para E1) | — | en Always-On la app no se dibuja (se ve el bloqueo con la Live Activity): `isLuminanceReduced` no aplica a Noche |
| T11 | Palabra de estado de Noche ("Se funde a las 03:42" ↔ "En pausa" ↔ "Fundiendo · 8 min" (C31) ↔ "Sonando · al 40" (C51)) | estado del motor / inicio del fundido | 250 ms opacidad; "Fundiendo · n min" cambia la cifra en seco por minuto | igual | es la única cosa de Noche que cambia además del reloj, por minuto |
| T12 | "Seguir por el altavoz" aparece / desaparece | `routeChange` (auriculares fuera) · 60 s (C49) | 250 ms opacidad; **"+15 min" no se mueve** | igual | igual |
| T13 | "20 min" de Madrugada | reloj | cambio seco por minuto | — | — |
| T14 | Cifra del precio "—" → "29,99 €" | respuesta de StoreKit | 250 ms opacidad; las hairlines pasan a `índice` a la vez | igual | n/a |
| T15 | Botón "Comprar · 29,99 €" → "Comprando…" → "Gracias. Todo abierto." | eventos de StoreKit | 250 ms opacidad cada cambio; "Gracias" 1,5 s y la hoja se cierra | igual | n/a |
| T16 | "Guardada" / "Guardada sin trueno" | guardar | 250 ms in · 1,5 s (3 s con "Conservar") · 500 ms out | igual | n/a |
| T17 | Tip (`tip.arrastre`, el único, C65) | TipKit | 250 ms opacidad, 6 s, sin fondo ni flecha | igual | ninguno entre 21:00 y 07:00 (`NightWindow`) |
| T18 | Párrafos de prueba (última noche / primera sin prueba), en el sitio de la línea de estado | sesión nueva | aparecen sin animación con la pantalla; se van 250 ms al "Entendido" (o al Play la última noche) y la línea de estado vuelve en su sitio | igual | no de noche |
| T19 | Error de audio (botón) | fallo del motor | 250 ms opacidad; `.announcement` | igual | Noche: "Sin sonido" sustituye la palabra de estado |
| T20 | Live Activity: versalita y tiempo | hitos (estado, fundido, +15, toggle de Marea, fin) | actualización por hito, nunca periódica; el tiempo lo lleva `Text(timerInterval:)` sin `update()`; al terminar, `end(content, dismissalPolicy: .after(fin + 4 h))` (tope del sistema) con `la.estado.terminada` + `la.madrugada` (03 §5 #19 escribe `.immediate`: es una `DismissalPolicy` que retira la actividad en el acto y contradice las 4 h de 03 §1.3; se sigue §1.3); Manto: `la.hasta`; límite de 8 h asumido y cerrado por la app a las 7 h 55 (C50) | — | StandBy: nada se anima |
| T21 | Página de día ↔ página nocturna (todo el texto a `texto-noche` y pesos Medium) | vuelta de Noche (por procedencia, dura la sesión) / toque en el nombre; nunca por reloj (C40) | 2 s opacidad | 250 ms | — |
| T22 | [retirada por C06: sin escucha de 30 s en 1.0] | — | — | — | — |
| T23 | `marea.oceano.subido` | la Marea sube el océano desde 0 | 250 ms in · 4 s · 500 ms out | igual | no de noche |
| T24 | `capas.tope` ("Seis a la vez") | activar la séptima capa (C19) | 250 ms in · 3 s · 500 ms out; la capa no se añade | igual | de noche igual, en `texto-noche` |
| T25 | `noche.primera` + `noche.volver` (no son TipKit) | primera entrada en Noche | aparecen con la pantalla · 4 s · 500 ms out | igual | sí de noche: son las dos frases de Noche |
| T26 | `mezclas.sonando` (versalita junto a la mezcla cargada) | cargar una mezcla | 250 ms opacidad, con el fundido cruzado | igual | n/a |
| T27 | `pagina.estado.manana.error` | sesión nueva a la mañana tras un corte | aparece con la pantalla; se va 250 ms al primer toque | igual | nunca de noche |
| T28 | `madrugada.retirada` ("Se retira · n min") | últimos 5 min de Madrugada (C60) | 250 ms opacidad; cifra en seco por minuto | igual | sí de noche, `texto-noche` |
| T29 | `madrugada.estado` ("Madrugada · 20 min") en el hueco del "+15 min" | Noche terminada (C27) | 250 ms opacidad; mismo sitio | igual | sí de noche |

Reglas: **ningún texto cambia de posición jamás** (03 §3.7): la segunda línea de estado tiene su sitio reservado (y 160, 64 pt) aunque esté vacía, el horizonte vive en y 284 y la banda de 120 está reservada aunque no haya Marea; nada parpadea (cifras por minuto, nunca por segundo); fuera de la app el tiempo lo pinta el sistema (`Text(timerInterval:)`), no una actualización; ninguna cadena se anima con `.bounce` ni cambia de tamaño salvo T2.

### 5b. VoiceOver por control: etiqueta → valor → pista → rasgos → acciones personalizadas

Las etiquetas, valores con argumento, pistas y nombres de acción son cadenas del catálogo: viven en §5e.16 (`ax.*`) y se compilan igual que las visibles; cuando la etiqueta es la propia cadena visible (títulos, botones de texto, filas), E1 la compone desde esa clave y aquí se cita entre paréntesis. VoiceOver lee cifras en palabras (`percentSpoken`, ya en `TimeFormat`); las horas con `Date.FormatStyle` hablado; los precios con `Product.displayPrice` (nunca una cifra escrita a mano). El orden de lectura es el de 03 §4 (Play primero en la página; en Noche, "Pantalla de noche" primero y "Volver a la página" último).

| Control | Etiqueta ES [EN] | Valor | Pista ES [EN] | Rasgos | Acciones personalizadas |
|---|---|---|---|---|---|
| Disco | Reproducir / Pausar [Play / Pause] | — | Suena en un segundo. [Starts in a second.] | `.button`, `.startsMediaSession`; Magic Tap desde cualquier foco | — |
| Cabecera de prueba (solo desde que la prueba empieza, C07) | Prueba, quedan cinco noches [Trial, five nights left] (`ax.prueba.cabecera`) · Prueba, última noche · Gratis siempre | — | Toca dos veces para ver qué incluye Pro. [Double-tap to see what's in Pro.] (`ax.prueba.pista`) | `.button` | — |
| Nombre de la mezcla | Nombre de la mezcla [Mix name] (`mezcla.guardar.campo`) | "Rosa y lluvia" / "Mar y viento, sin Océano" | Mantén para guardar o renombrar. [Hold to save or rename.] (`ax.nombre.pista`); página nocturna: Toca dos veces para volver a la página de día. (`ax.nombre.pista.noche`) | `.button`, `.header` | Guardar como mezcla, Renombrar, Vaciar; página nocturna: Volver a la página de día |
| Horizonte (elemento de estado, C63) | Sonido [Sound] (`ax.horizonte`) | Sonando, nivel bajo / medio / alto (`ax.horizonte.valor.*`, tres tramos del RMS con histéresis de 3 s) / En silencio / Marea, inhala, seis por minuto [Playing, low / medium / high level / Silent / Tide, breathe in, six per minute] | — | `.image`; sin `.updatesFrequently` (de noche re-anunciaría); sin `AXChartDescriptor` (las sublíneas son decorativas); Magic Tap en la raíz = play/pausa | Ver capas por separado (`ax.accion.capas_separadas`) |
| Línea de estado | (el texto tal cual) | — | — | `.staticText`; anuncio al cambiar | — |
| Fila de capa | Rosa, suave y equilibrado [Pink, soft and balanced] (`ax.capa`: nombre + subtítulo) | sesenta y cinco por ciento [65 percent] (`a11y.percentFormat`) | Desliza arriba o abajo para ajustar. [Swipe up or down to adjust.] (`ax.capa.pista`) | `.adjustable`, pasos del 5 % | Silenciar, Máximo, Ajuste con deslizador (`ax.accion.silenciar`, `.maximo`, `.deslizador`) |
| Fila de capa Pro sin acceso | Trueno, lejano, sin rayos cerca, requiere Pro [Thunder, far off, no close strikes, requires Pro] (`ax.capa.pro`) | en silencio, nivel guardado treinta [silent, saved level thirty] (`ax.capa.pro.valor`) | Toca dos veces para ver Pro. [Double-tap to see Pro.] (`ax.capa.pro.pista`; de noche sin pista) | `.button` | Ver Pro (`ax.accion.ver_pro`; de noche no existe) |
| Fila Timbre (C29) | Timbre [Tone] (`capas.timbre`) | grave / lejos, por tramos (`capas.timbre.grave` / `capas.timbre.lejos`) | Desliza arriba o abajo para ajustar. (`ax.capa.pista`) | `.adjustable` | — |
| "y 2 más" | Y dos capas más [And two more layers] | — | Abre todas las capas. [Opens all layers.] | `.button` | — |
| Todas las capas | Todas las capas [All layers] (`capas.todas`) | — | Abre todas las capas. (`ax.mas.pista`) | `.button` | — |
| Toggle Marea | Marea [Tide] (`marea.titulo`) | Guiando, seis por minuto, se retira a las once y veintisiete / Desactivada / Desactivada, requiere Pro [Guiding, six per minute, recedes at eleven twenty-seven / Off / Off, requires Pro] (`ax.marea.valor`, `ax.marea.off`, `ax.marea.off.pro`) | Sin acceso: Toca dos veces para ver Pro. (`ax.marea.pista.pro`). Con acceso y en silencio: Toca dos veces para encenderla; el sonido arranca. (`ax.marea.pista`) | `Toggle` del sistema | — |
| Toggle Descenso (hoja Marea, C24) | Descenso [Descent] (`marea.descenso`) | Empezar a 12 por minuto (`marea.ritmo`) | — | `Toggle` del sistema | — |
| Línea de agua (hoja; nunca un círculo, C59) | Marea [Tide] (`marea.toggle`) | Inhala, seis por minuto, se retira en doce minutos [Breathe in, six per minute, recedes in twelve minutes] (`ax.agua.valor`; el valor hablado es "{n} por minuto", `marea.ritmo.exacto`) | Desliza arriba o abajo para cambiar el ritmo. [Swipe up or down to change the pace.] (`ax.agua.pista`) | `.adjustable` (4-8), `.updatesFrequently` | Decir inhala y exhala (`marea.voz`) |
| Qué sabemos › (hoja Marea) | Qué sabemos [What we know] (`sabemos.titulo`) | — | Abre la pantalla de evidencia. (`ax.sabemos.pista`) | `.link` | — |
| Más ajustes | Más ajustes [More settings] (`marea.mas`) | — | — | `.button` | — |
| Ritmo | Ritmo [Pace] (`marea.ritmo.fila`) | Tranquilo, seis por minuto | — | `.button` | — |
| Se retira a los | Se retira a los [Recedes after] | quince minutos | — | `.button` | — |
| Háptica | Háptica [Haptics] | Mínima | De noche nunca vibra. [Never at night.] (`ax.haptica.pista`) | `.button` | — |
| Temporizador (fila) | Temporizador [Timer] | Hasta dormirme, quedan treinta y ocho minutos [Until I sleep, thirty-eight minutes left] | — | `.button` | — |
| Modo de temporizador | Hasta dormirme, cuarenta y cinco minutos, se funde al final [Until I sleep, forty-five minutes, fades out at the end] (nombre + detalle) | seleccionado | — | `.button`, `.isSelected` | — |
| Manto | Manto, hasta las siete [Blanket, until seven] (nombre + detalle) | seleccionado | — | `.button`, `.isSelected`; `DatePicker` del sistema para la hora | — |
| Duración | Duración [Length] | cuarenta y cinco minutos | Desliza arriba o abajo. [Swipe up or down.] (`ax.duracion.pista`) | `.adjustable` | — |
| +15 min (hoja, Noche, Live Activity, Watch 1.2) | Quince minutos más [Fifteen more minutes] (`ax.mas15`) | — | — | `.button`; solo con temporizador (C47); tras tocar, anuncio `ax.anuncio.quedan` "Quedan cincuenta y tres minutos" (Manto: `ax.anuncio.hasta` "Hasta las siete y cuarto") | — |
| Madrugada · 20 min (Noche terminada, widget, C27) | Madrugada, veinte minutos [Small hours, twenty minutes] (`ax.la.madrugada`) | — | — | `.button` 64 | — |
| Pantalla Noche (1.º en el orden) | Pantalla de noche [Night screen] (`ax.noche.pantalla`) | Tres y siete. Sonando. Se funde a las tres y cuarenta y dos. [Three oh seven. Playing. Fades at three forty-two.] (`ax.noche.valor`: hora hablada + estado) · En pausa · Fundiendo, quedan ocho minutos · Hasta las siete · **Sin sonido.** (error) | Toca dos veces para pausar. Mantén para volver. [Double-tap to pause. Hold to go back.] (`ax.noche.pista`); error: Toca dos veces para reintentar. [Double-tap to try again.] (`ax.noche.pista.error`) | `.button`; Magic Tap | Pausar / Reanudar (`ax.accion.pausar` / `.reanudar`), Volver a la página (`ax.accion.volver`), Seguir por el altavoz (cuando aplica, `ruta.seguir_altavoz`). Noche no es un elemento único: son cinco elementos en este orden, y una acción personalizada no puede ser `.adjustable` |
| Quince minutos más (Noche, 2.º) | Quince minutos más (`ax.mas15`) | — | — | `.button` 64 | — |
| Seguir por el altavoz (Noche 3.º y página) | Seguir por el altavoz [Keep playing on speaker] (`ruta.seguir_altavoz`) | — | El volumen baja al cuarenta. [The volume drops to forty.] (`ax.altavoz.pista`) | `.button`; 60 s (C49) | — |
| Volumen (Noche, 4.º; rotor) | Volumen [Volume] (`ax.volumen`) | cuarenta por ciento | — | `.adjustable` (`master` con rampa en `EngineCommand`, C51) | — |
| Volver (Noche, 5.º y último) | Volver a la página [Back to the page] (`ax.accion.volver`) | — | — | `.button`; último en el orden; visible solo con VoiceOver | — |
| Controles visibles de noche (fila de cuatro + Slider) | Quince minutos menos [Fifteen minutes less] (`ax.menos15`) · Pausar / Reanudar (`ax.accion.pausar` / `.reanudar`) · Quince minutos más (`ax.mas15`) · Volver a la página (`ax.accion.volver`) · Slider Volumen (`ax.volumen`) | — / — / — / — / cuarenta por ciento | — | `.button` × 4 de 64; Slider `.adjustable` | — |
| Pantalla Madrugada | Madrugada [Small hours] (`madrugada.titulo`) | Quedan veinte minutos. Sonando. [Twenty minutes left. Playing.] (`ax.madrugada.valor`) · En pausa · Se retira, quedan cuatro minutos (`ax.madrugada.retirada`) | Toca dos veces para pausar. [Double-tap to pause.] (`ax.madrugada.pista`) | `.button`; Magic Tap | Parar (`comun.parar`) |
| Barra: Mezclas / Noche | Mezclas [Mixes] / Pantalla de noche [Night screen] | — | — | `.button` | — |
| Fila de mezcla | Mar y viento, océano cincuenta, viento veinte [Sea and wind, ocean fifty, wind twenty] (nombre + receta hablada; + `ax.receta.pro` "océano requiere Pro") | sonando ahora (si es la cargada, `mezclas.sonando`) | Toca dos veces para cargarla. [Double-tap to load.] (`ax.mezcla.pista`) | `.button` | Renombrar, Eliminar (`comun.*`), Subir, Bajar (`ax.accion.subir` / `.bajar`) |
| Esta noche (fila) | Esta noche, la mezcla de ahora [Tonight, the current mix] (`ax.esta_noche`) | rosa sesenta y cinco, lluvia cuarenta | Mantén para guardarla. [Hold to save it.] (`ax.esta_noche.pista`) | `.button` | Guardar como mezcla |
| Guardar como mezcla… · pro (4.ª mezcla sin acceso) | Guardar como mezcla, requiere Pro [Save as a mix, requires Pro] (`ax.guardar.pro`) | — | Toca dos veces para ver Pro. La mezcla no cambia. (`ax.guardar.pro.pista`) | `.button` | — |
| Vaciar | Vaciar [Clear] (`mezcla.menu.vaciar`) | — | Pone todas las capas a cero. Se deshace cargando una mezcla. (`ax.vaciar.pista`) | `.button` | — |
| Conservar el trueno | Conservar el trueno [Keep thunder] (`mezclas.conservar`) | — | Guarda la mezcla completa. (`ax.conservar.pista`) | `.button` | — |
| Volver a poner las de la casa | Volver a poner las de la casa [Bring back the house mixes] (`mezclas.casa.restaurar`) | — | — | `.button` | — |
| Comprar | Comprar {displayName}, %@ [Buy {displayName}, %@] (`ax.comprar`; `displayName` y `Product.displayPrice`: VoiceOver lee la moneda sola) | — | Un solo pago. Abre la confirmación de App Store. [One payment. Opens the App Store confirmation.] (`ax.comprar.pista`) | `.button` | — |
| Comprar sin precio | Comprar {displayName} (`ax.comprar.sin_precio`) | precio no disponible (`ax.comprar.sin_precio.valor`) | La tienda no responde. (`ax.comprar.sin_precio.pista`) | `.button`, `.notEnabled` | — |
| Restaurar | Restaurar compra [Restore purchase] | — | — | `.button` | — |
| Empezar la prueba · 7 noches (hoja Pro, C07) | Empezar la prueba de siete noches [Start the seven-night trial] (`ax.prueba.empezar`) | — | No se cobra nada ni se pide tarjeta. (`ax.prueba.empezar.pista`) | `.button` | — |
| Escribir una reseña (estado comprado, C55) | Escribir una reseña [Write a review] (`pro.resena`) | — | Abre App Store. (`ax.resena.pista`) | `.link` | — |
| Entendido / Ahora no | Entendido [Got it] / Ahora no [Not now] | — | — | `.button` | — |
| Reintentar audio | No se ha podido iniciar el sonido. Reintentar [Couldn't start the sound. Try again] | — | — | `.button`; `.announcement` al aparecer | Enviar informe (3.er fallo) |
| Enviar informe | Enviar informe [Send report] (`diagnostico.enviar`) | — | Abre tu correo con el registro de la noche. Sin nombre ni identificadores. [Opens your mail with the night's log. No name or identifiers.] (`ax.informe.pista`) | `.button` | — |
| Escribir al autor (C58) | Escribir al autor [Write to the author] (`ajustes.autor`) | — | Abre tu correo. (`ax.autor.pista`) | `.button` | — |
| Salida (C41) | Salida [Output] (`ajustes.salida`) | Dormitorio (ruta actual) | — | `AVRoutePickerView` del sistema | — |
| Abrir Atajos | Abrir Atajos [Open Shortcuts] (`ajustes.acostarte.abrir`) | — | Abre la app Atajos. [Opens the Shortcuts app.] (`ax.atajos.pista`) | `.link` | — |
| Afirmación de Qué sabemos | (la frase) | — | — | `.header` (rotor Encabezados) | — |
| Live Activity botón 1 | Pausar SleepNoise / Reproducir SleepNoise [Pause SleepNoise / Play SleepNoise] (`ax.la.pausar` / `ax.la.reproducir`) | — | — | `.button` | — |
| Live Activity botón 2 | Quince minutos más [Fifteen more minutes] (`ax.mas15`) | — | — | `.button` | — |
| Live Activity terminada ▶ | Madrugada, veinte minutos [Small hours, twenty minutes] (`ax.la.madrugada`) | — | — | `.button` | — |
| StandBy (un solo control, C25) | Pausar / Reproducir (`ax.la.pausar` / `ax.la.reproducir`) | — | — | `.button` | — |
| Widget pequeño | Rosa y lluvia, en silencio. Dormir. [Pink and rain, silent. Sleep.] · 00:00–06:00: Madrugada, veinte minutos | — | — | `.button` | — |
| Widget mediano, fila [1.1] | Rosa y lluvia, rosa veinte, lluvia cincuenta y cinco. Reproducir. | — | — | `.button` | — |
| Control (Centro de control) | SleepNoise | Sonando / En silencio | — | toggle del sistema | — |
| Control Madrugada | Madrugada, veinte minutos | — | — | botón del sistema | — |
| Watch, zona central [1.2] | Pausar / Reproducir | Rosa y lluvia, quedan treinta y ocho minutos | — | `.button` | — |

Anuncios (`AccessibilityNotification.Announcement`) exactos: "Sonando" · "En pausa" · "Guardada" · "Gracias. Todo abierto." · "Quedan {n} minutos" (`ax.anuncio.quedan`) · "Hasta las {hora}" (`ax.anuncio.hasta`) · "Página" (`ax.anuncio.pagina`) · "Máximo" (`ax.accion.maximo`) · "Se ha retirado. El mar sigue." · la línea de estado al cambiar · la cadena de error al aparecer. Ningún anuncio de noche salvo los que responden a un toque. 53 controles en la tabla tras la reconciliación (entran Timbre, Descenso, Manto, Madrugada · 20 min, StandBy, Escribir una reseña, Escribir al autor, Salida; salen la escucha, Manto sin acceso e Isla expandida).

### 5c. Gesto → alternativa sin gesto → Control por botón → teclado / Pointer

Cada gesto con el nombre que usan las acciones de VoiceOver, Control por voz y Control por botón (las cadenas `ax.accion.*` del catálogo).

| Gesto | Dónde | Alternativa sin gesto (VoiceOver / acción) | Control por botón · AssistiveTouch | Teclado · Pointer (iPad, Mac) |
|---|---|---|---|---|
| Arrastre horizontal sobre la fila (nivel) | Página, Capas | `.adjustable` arriba/abajo; acciones "Subir", "Bajar", "Silenciar", "Máximo" | Pulsación larga → `Slider` del sistema "Nivel de Lluvia" | ← → de 5 en 5; ⇧ de 10 en 10; Home/End 0/100 |
| Toque en la fila | Página, Capas | (nada: el toque no hace nada) | — | — |
| Pulsación larga en la fila (deslizador) | Página, Capas | acción "Ajuste con deslizador" | Menú de AssistiveTouch "Mantener" | Enter sobre la fila |
| Pulsación larga sobre el horizonte (una línea por capa) | Página | acción "Ver capas por separado" (sin Audio Graph, C63) | — | Espacio sobre el horizonte |
| Pulsación larga sobre el nombre | Página | `contextMenu` expuesto como acciones (Guardar como mezcla, Renombrar, Vaciar); renombrar solo desde aquí | — | Enter abre el menú |
| Toque sobre el nombre | Página nocturna (de día no hace nada) | acción "Volver a la página de día" | — | Enter |
| Toque en toda la pantalla (pausa) | Noche, Madrugada | elemento "Pantalla de noche" (primero en el orden) con acciones Pausar / Reanudar; Magic Tap | "Controles visibles de noche": −15 min · pausa · +15 min · Página (se activan solos con `isSwitchControlRunning` / `isAssistiveTouchRunning`) | Espacio |
| Arrastre vertical (maestro de sesión, C51) | Noche, Madrugada | rotor "Volumen"; Control por voz "Volumen cuarenta"; botones físicos | fila "Controles visibles" añade un `Slider` "Volumen" | ↑ ↓ |
| Arrastre horizontal sobre la fila Timbre (C29) | Capas | `.adjustable`; Grave / Lejos | pulsación larga → `Slider` | ← → |
| Pulsación larga 0,6 s (volver) | Noche | botón "Volver a la página" (último en el orden); acción "Volver a la página" del elemento "Pantalla de noche"; gesto Z de VoiceOver | botón "Página" (cuarto de la fila visible) | Esc |
| Arrastrar la línea de agua (ritmo) | Marea | `.adjustable`; fila "Ritmo" | fila "Ritmo" (opciones) | ← → |
| Deslizar fila (renombrar / eliminar) | Mezclas | acciones "Renombrar", "Eliminar"; modo edición | botón "Editar" de la barra | ⌫ con confirmación |
| Reordenar | Mezclas | acciones "Subir", "Bajar" | modo edición | ⌥↑ ⌥↓ |
| Arrastrar para cerrar hoja | Hojas | gesto de escape de VoiceOver; iOS 26: botón del sistema | botón del sistema (iOS 26) / escape | Esc |
| Raise to wake + toque ▶ (Madrugada) | Bloqueo | Siri "Madrugada en ${applicationName}"; botón de Acción; Centro de control; widget pequeño (00–06); botón en Noche terminada (C27) | — | — |
| Digital Crown (volumen) [1.2] | Watch | botón "Volumen" `.adjustable` | — | — |

Ningún gesto es la única vía; ningún gesto es de varios dedos ni de pellizco; ningún doble toque propio (03 §6; C27: Madrugada nunca por gesto). Dieciséis gestos; el gesto vertical de timbre no existe (C52).

### 5d. Dynamic Type por tramo: qué cambia en el texto

| Pantalla | xS-L | xL-xxxL | AX1-AX2 | AX3-AX5 |
|---|---|---|---|---|
| Página | Cabe sin desplazar: 2 capas + 3 filas; línea de estado 1 línea | El aire se consume; la línea de estado puede ir a 2 líneas ("Sonando · se funde a las 00:42" parte en el "·") | `ScrollView`; el horizonte se ancla bajo la cabecera (03 §3.5); fila de capa 96-112: nombre, subtítulo, valor en columna; la cabecera de prueba sigue en versalitas (escala con `.footnote`, suelo 13) | Nombre de la mezcla hasta 40 pt en 2 líneas; "Mezclas" / "Noche" pasan a glifos con `barra.*.ax` como etiqueta; segunda línea de estado siempre a 2 líneas |
| Capas | 80 por fila | 88 | 96-112 apiladas; versalitas de sección escalan con `.footnote` | igual; valor bajo el nombre en 17 |
| Marea | hoja `.large` | igual | la instrucción pasa a 3-4 líneas; la banda no escala; "inhala" baja a la izquierda bajo la banda | igual; "guiando · 6 por minuto" cabe en una línea; "Se retira a las 23:27" en paso 7 escala con `.subheadline` |
| Temporizador | `.medium` → `.large` | `.large` | cifra 56 → tope AX2; "+15 min" (64) bajo la cifra a todo el ancho; detalles de modo en 2 líneas | igual |
| Noche | 72 / 22 / 20 | igual | reloj tope AX2; "Se funde a las 03:42" 28; "+15 min" 24 | igual; nada se corta porque solo hay cuatro cosas; "Seguir por el altavoz" en 2 líneas si hace falta |
| Madrugada | 56 / 20 | igual | cifra tope AX2; "Parar" 24 | igual |
| Mezclas | 72 por fila | 88 | nombre + receta en columna, 110; la receta se parte en los "·" | igual |
| Pro | todo en pantalla | desplaza | precio tope AX2; `pro.pie` 2-3 líneas; filas 44 → 56; "Comprar · 29,99 €" y "Empezar la prueba · 7 noches" en 2 líneas si hace falta (parten en el "·") | igual |
| Qué sabemos | 17/26 | 20/30 | `.body` escala; afirmaciones `.headline` | igual |
| Ajustes | lista del sistema | sistema | sistema | sistema |
| Live Activity / widgets | tamaños del sistema | — | el sistema limita; nombre `minimumScaleFactor(0.8)`, tiempo `(0.7)`; la versalita puede ocultarse antes que el tiempo | — |

Reglas de copy para Dynamic Type: toda cadena con "·" admite salto de línea en el "·" y nunca dentro de un segmento; ninguna cadena de botón pasa de 2 líneas en AX5 a 353 pt; las versalitas escalan pero nunca por debajo de 13 pt: `.footnote` mide 12 pt en xS, S y M, así que el suelo se aplica en código (`@ScaledMetric(relativeTo: .footnote) var versalita = 13` con `max(13, …)` en `StateWord`; en xS-M el paso 9 no escala hacia abajo); `minimumScaleFactor` solo en nombres escritos por el usuario; el español se verifica un 30 % más largo que el inglés (02 §7.18).

### 5e. Catálogo de cadenas ES / EN por clave

Formato: clave → ES (es-ES; es-419 solo si cambia, en §0.3) → EN (en-US) → contexto (pantalla [Esp.], paso, token) → longitud máxima en caracteres a Large (la medida es del segmento ES, el más largo). Argumentos: `%lld` entero, `%@` cadena, `%@` para horas y precios ya formateados por el sistema. **Plurales:** las claves marcadas (pl) llevan variantes `one` / `other` en el String Catalog (ES y EN; es-419 hereda). Las versalitas se escriben en minúscula. Idioma fuente del catálogo: `en`. **Pasos por defecto** cuando la columna Contexto no los dice: fila paso 5 `texto`; opción paso 5 `texto`; subtítulo y valor a la derecha paso 7 `texto2`; nota paso 8 `texto2`; versalita paso 9 `texto2`; botón de texto paso 6 `texto2`; de noche, el mismo paso en Medium `texto-noche`. Una clave por texto: las cadenas idénticas que se usan en varias superficies viven en `comun.*` y el contexto dice dónde (44 o 64 pt).

#### 5e.1 Comunes

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `app.name` | SleepNoise | SleepNoise | ficha, Ajustes, hoja Pro; nunca en la página (existente, se conserva) | 10 |
| `comun.guardar` | Guardar | Save | botón primario de la hoja de guardar [E5] (existente `common.save`, se conserva) | 10 |
| `comun.cancelar` | Cancelar | Cancel | alerta del sistema (existente `common.cancel`) | 10 |
| `comun.entendido` | Entendido | Got it | acción secundaria paso 6 `texto2` bajo los párrafos de prueba [E5] (existente `trial.gotIt`, renombrada) | 12 |
| `comun.ahora_no` | Ahora no | Not now | acción secundaria en la hoja Pro junto a "Empezar la prueba · 7 noches" [E5] | 10 |
| `comun.pro` | pro | pro | palabra de estado paso 9 versalitas `texto2`, donde iría el valor [E2][E4][E5] | 3 |
| `comun.pro.nivel` | pro · %lld | pro · %lld | versalita con el nivel guardado ("pro · 30"); la capa conserva su nivel, el motor la ignora sin acceso, la degradación nunca escribe (C23) [E2] | 8 |
| `comun.min` (pl) | %lld min | %lld min | minutos abreviados en estados y recetas (existente `timer.minutesFormat`) | 7 |
| `comun.min.quedan` (pl) | quedan %lld min | %lld min left | dentro de la app: Siesta [1.1] en la línea de estado (`pagina.estado.sonando.siesta` la compone); Watch [1.2]. Fuera de la app el tiempo lo pinta `Text(timerInterval:)`, nunca un `%lld` | 16 |
| `comun.mas15` | +15 min | +15 min | la misma cadena en hoja del Temporizador (64), Noche (64 a todo el ancho, paso 4; nunca cambia de sitio; solo si hay temporizador, C47), Live Activity (64; vacío en Manto, C50), Controles visibles de noche (64), Watch [1.2]; libre para todos (C03); un solo paso (P2) | 8 |
| `comun.parar` | Parar | Stop | botón 64 a todo el ancho en Madrugada (paso 4); la única vez que aparece "Parar" en la app | 6 |
| `comun.escucha` | [retirada por C06] | — | la escucha de 30 s pasa a 1.1 y no abrirá hoja | — |
| `comun.renombrar` | Renombrar | Rename | deslizar en Mezclas; `contextMenu` del nombre (única vía para renombrar) [E5] | 10 |
| `comun.eliminar` | Eliminar | Delete | acción destructiva del sistema (rojo del sistema) [E5] | 10 |

#### 5e.2 Página principal [E2]

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `pagina.estado.silencio` | En silencio | Silent | línea de estado paso 7 `texto2`; sustituye `mixer.silent`; también valor *off* del Control | 12 |
| `pagina.estado.silencio.pro` | En silencio · esta mezcla es Pro | Silent · this mix is Pro | mezcla cargada toda Pro sin acceso | 34 |
| `pagina.estado.sonando` | Sonando | Playing | sin temporizador; también valor *on* del Control del Centro de control | 8 |
| `pagina.estado.sonando.funde` | Sonando · se funde a las %@ | Playing · fades at %@ | con "Hasta dormirme" o "Siesta"; `%@` hora corta del sistema | 30 |
| `pagina.estado.sonando.hasta` | Sonando · hasta las %@ | Playing · until %@ | Manto | 24 |
| `pagina.estado.sonando.siesta` [1.1] | Sonando · siesta · quedan %lld min | Playing · nap · %lld min left | Siesta (de día se piensa en minutos); no se compila en 1.0 (C30) | 36 |
| `pagina.estado.sonando.sin` | Sonando · sin %@ | Playing · without %@ | `%@` = capa(s) Pro sin acceso en minúscula: "trueno", "trueno ni océano" (`pagina.capas.ni`) | 40 |
| `pagina.estado.sonando.sin.marea` | Sonando · sin Marea | Playing · without the tide | la mezcla tenía Marea y no hay acceso | 26 |
| `pagina.estado.sonando.defecto` | Sonando · rosa a 40 | Playing · pink at 40 | Play con todo a 0: el instrumento siempre suena (Marea, 03 §1.3) | 22 |
| `pagina.estado.fundiendo` | Sonando · fundiendo · %lld min | Playing · fading · %lld min | fundido de ganancia de 10–15 min con cuenta entera (C31); corte de filtro solo si llega el bus | 30 |
| `pagina.estado.pausa` | En pausa | Paused | pausa de la persona y toda interrupción del sistema salvo llamada (`InterruptionReason` solo distingue `.default`, `.appWasSuspended`, `.builtInMicMuted`, `.routeDisconnected`); regla de reanudación por ventana de la mañana (C48) | 10 |
| `pagina.estado.pausa.llamada` | En pausa · llamada | Paused · call | `CXCallObserver` en 1.0 (C48); una llamada nunca termina la sesión fuera de la ventana de la mañana | 20 |
| `estado.pausa.auriculares` | En pausa · auriculares | Paused · headphones | `oldDeviceUnavailable`: caída de ruta = fundido de 40 ms + pausa (C49); también palabra de Noche (es-419: audífonos); antes `pagina.estado.pausa.auriculares` | 24 |
| `pagina.estado.pausa.airpods` | En pausa · AirPods | Paused · AirPods | `pauseCommand` con auriculares = fundido de 3 s (C49) | 20 |
| `estado.ruta` | Sonando · en %@ | Playing · on %@ | `%@` = nombre de la ruta del sistema ("Dormitorio", AirPlay/altavoz externo; `routeSharingPolicy = .longFormAudio`); sin superficie propia de AirPlay (C41) | 30 |
| `pagina.estado.pausa.interrumpido` | En pausa · se interrumpió el sonido | Paused · the sound was interrupted | `mediaServicesWereReset` no recuperado | 40 |
| `ruta.seguir_altavoz` | Seguir por el altavoz | Keep playing on speaker | botón de texto paso 6 `texto2` en la segunda línea de la página (44; 64 en la página nocturna) y botón 64 en Noche (paso 4); visible 60 s (C49); una sola clave (antes `pagina.accion.altavoz` y `noche.altavoz`); es-419: bocina | 28 |
| `estado.volumen` | Sonando · al %lld | Playing · at %lld | el maestro de sesión (`master` con rampa en `EngineCommand`; nunca el volumen del sistema; no persiste): tras el arrastre vertical en Noche y Madrugada (3 s) y en la segunda línea de la página tras reanudar por el altavoz capado a 0,4 (C49, C51); sustituye `pagina.estado.volumen40` | 20 |
| `pagina.estado.manana.error` | Anoche el sonido se detuvo a las %@. | Last night the sound stopped at %@. | línea de estado paso 7 a la mañana; debajo, `diagnostico.enviar` como `TextAction` en la segunda línea: la única petición de la app (Dial) | 40 |
| `pagina.estado.manana.pro` | [retirada por C08] | — | de noche no se vende y no hay línea matinal; `showPaywall` se consume sin cola | — |
| `pagina.capas.y` | %@ y %@ | %@ and %@ | nombre automático de dos capas ("Rosa y lluvia"; la segunda en minúscula) | 24 |
| `pagina.capas.ni` | %@ ni %@ | %@ or %@ | lista negativa ("sin trueno ni océano") | 24 |
| `mezcla.nombre.auto.1` | %@ | %@ | una sola capa > 0: su nombre ("Rosa") | 14 |
| `mezcla.nombre.auto.3` | %@, %@ y %@ | %@, %@ and %@ | tres capas; con cuatro o más: `mezcla.nombre.auto.mas` | 34 |
| `mezcla.nombre.auto.mas` (pl) | %@ y %lld más | %@ and %lld more | "Rosa y 3 más" | 20 |
| `mezcla.nombre.sin` | %@ · sin %@ | %@ · without %@ | título honesto de la mezcla recortada ("Mar y viento · sin Océano"; también para las mezclas de la casa con Pro, C18; la capa en mayúscula inicial, como la escribe 03 §1.3; en la línea de estado va en minúscula: son un nombre y una frase) | 34 |
| `mezcla.nombre.vacio` | Esta noche | Tonight | nombre por defecto cuando el usuario vacía la mezcla y no hay capas > 0 | 10 |
| `mezcla.menu.guardar` | Guardar como mezcla… | Save as a mix… | `contextMenu` del nombre | 22 |
| `mezcla.menu.guardar.pro` | Guardar como mezcla… · pro | Save as a mix… · pro | cuarta mezcla propia sin acceso (`freeSavedMixLimit` 1 → 3; sin límite con Pro); al tocar, hoja Pro de día, mezcla intacta | 28 |
| `mezcla.menu.vaciar` | Vaciar | Clear | `contextMenu`; pone todo a 0 (sin alerta: es reversible con Mezclas) | 8 |
| `mezcla.guardar.campo` | Nombre de la mezcla | Mix name | placeholder del campo del sistema (precargado con el nombre automático) | 20 |
| `capas.todas` | Todas las capas | All layers | fila 56 paso 5 `texto`; sin cifra ni chevron (botón por rasgo y por Button Shapes) | 16 |
| `capas.mas` (pl) | y %lld más | and %lld more | fila 56 cuando suenan más de tres capas | 12 |
| `capas.tope` | Seis a la vez | Six at once | nota paso 7 `texto2` 3 s al activar la séptima capa; la capa no se añade; tope de seis simultáneas como regla de modelo (C19), nunca huecos ni ranuras | 14 |
| `barra.mezclas` | Mezclas | Mixes | barra inferior 17 Medium `texto` | 8 |
| `barra.noche` | Noche | Night | barra inferior | 6 |
| `barra.mezclas.ax` | Mezclas | Mixes | etiqueta accesible del glifo `square.stack` en AX4-AX5 | 8 |
| `barra.noche.ax` | Pantalla de noche | Night screen | etiqueta accesible del glifo `circle.lefthalf.filled` en AX4-AX5 | 18 |
| `tip.arrastre` | Arrastra sobre el nombre para cambiar el nivel. | Drag across the name to change the level. | el único TipKit (C65), segundo arrastre, solo de día (`NightWindow`), 6 s, paso 7 `texto2` (sin "un toque lo silencia": el toque ya no hace nada) | 50 |
| `pagina.error.inicio` | No se ha podido iniciar el sonido. Toca para reintentar. | Couldn't start the sound. Tap to try again. | botón 44 en el sitio del estado, paso 7 `texto2`; sustituye `error.audio` | 56 |
| `pagina.error.inicio.2` | Si sigue sin sonar, cierra la app y vuelve a abrirla. | If it still won't play, close the app and open it again. | segundo fallo (Dial) | 56 |
| `pagina.error.inicio.3` | Cierra las apps que usen el micrófono y vuelve a intentarlo. | Close any app using the microphone and try again. | tercer fallo (línea de estado, 2 líneas) + `diagnostico.enviar` en la segunda línea; "Close" aquí es frase, no botón (falso positivo declarado) | 60 |

#### 5e.3 Prueba [E5] (empieza en la hoja Pro, C07; el estado va en la página)

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `pro.prueba.empezar` | Empezar la prueba · 7 noches | Start the trial · 7 nights | acción primaria de la hoja Pro mientras la prueba no se ha usado (C07); se dispara con la primera acción Pro, nunca con Play; `startTrial()` desde la hoja; estado en Keychain; Tier 0 (sin StoreKit) detrás de la misma palabra; antes `prueba.empezar` | 28 |
| `pro.prueba.empezar.nota` | Dura siete noches. No se cobra nada ni se pide tarjeta. Al acabar, lo gratis sigue gratis y tus mezclas se conservan. | Lasts seven nights. Nothing is charged and no card is asked. When it ends, free stays free and your mixes are kept. | paso 8 `texto2` bajo el botón; antes `prueba.empezar.nota` | 110 |
| `pro.prueba.estado` (pl) | prueba · quedan %lld noches | trial · %lld nights left | cabecera paso 9 versalitas `texto2` de la página, botón → hoja Pro (solo de día); aparece solo desde que la prueba empieza; `one`: "prueba · queda 1 noche" / "trial · 1 night left"; antes `prueba.cabecera` | 28 |
| `pro.prueba.estado.ultima` | prueba · última noche | trial · last night | última noche de la prueba; antes `prueba.cabecera.ultima` | 22 |
| `pro.prueba.estado.gratis` | gratis siempre | always free | desde la primera noche sin prueba; botón → hoja Pro (que ya enumera lo gratis); desaparece tras 7 sesiones gratuitas (03 §1.2); antes `prueba.cabecera.gratis` | 14 |
| `prueba.bienvenida` | [retirada por C07] | — | la prueba no arranca la primera noche ni con Play: no hay párrafo de bienvenida; la lista de lo gratis vive solo en `pro.gratis.lista` | — |
| `prueba.bienvenida.14` | [retirada por C07] | — | la prueba es de 7 noches (reconciliación §4) | — |
| `prueba.ultima` | Última noche con todo. Mañana, lo gratis sigue gratis. | Last night with everything. Tomorrow, free stays free. | última noche de la prueba, en el sitio de la línea de estado, paso 7 `texto2`, hasta el Play; sin botón | 60 |
| `prueba.terminada` | La prueba terminó. Lo que usaste sigue aquí. | The trial is over. What you used is still here. | primera noche sin prueba, una vez, paso 7 `texto2` + `comun.entendido` (sustituye `trial.ended.*`); lo que espera a Pro ya se ve inline en las filas ("pro · 30"); nada se escribe (C23) | 48 |

#### 5e.4 Capas [E2]

Once texturas en 1.0 vía PR-A (C19): cinco libres (blanco, rosa, marrón, lluvia, viento) y seis Pro (océano, ventilador, trueno, hoguera, arroyo, cabina) (C04); `SoundID` añade `.wind` a la rama libre de `soundIsIncluded`; la lista libre solo crece. Nunca se cuentan en paywall ni ficha. Los nombres siguen las claves existentes `sound.{id}`; los subtítulos cambian de valor y de clave (`sound.{id}.detail` → `capas.{id}.detalle`). Regla de catálogo (C13, C17): textura = sustantivo + línea de uso; nunca adjetivo en el nombre.

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `capas.titulo` | Capas | Layers | cabecera de la hoja paso 3 | 8 |
| `capas.seccion.colores` | colores | colors | encabezado versalitas paso 9 `texto2` | 8 |
| `capas.seccion.camas` | camas | beds | idem (término del PR #3, exacto) | 6 |
| `sound.white` | Blanco | White | nombre paso 5 (existente, se conserva) | 10 |
| `capas.white.detalle` | siseo parejo | even hiss | subtítulo paso 7 `texto2` (existente `sound.white.detail`, renombrada; valor igual) | 24 |
| `sound.pink` | Rosa | Pink | existente | 10 |
| `capas.pink.detalle` | suave y equilibrado | soft and balanced | existente, renombrada; valor igual | 24 |
| `sound.brown` | Marrón | Brown | existente | 10 |
| `capas.brown.detalle` | retumbo grave | low rumble | EN cambia de "Deep rumble" a "low rumble" (sin "deep": lista negra) | 24 |
| `sound.rain` | Lluvia | Rain | existente | 10 |
| `capas.rain.detalle` | sobre el tejado | on the roof | cambia: antes "Gotas sobre un fondo constante"; no "lluvia fina" (colisiona con el nombre vetado de mezcla, C17) | 24 |
| `sound.fan` | Ventilador | Fan | existente | 12 |
| `capas.fan.detalle` | ventilador lejano | distant fan | cambia: antes "Zumbido mecánico lento" | 24 |
| `sound.ocean` | Océano | Ocean | existente | 10 |
| `capas.ocean.detalle` | oleaje lento | slow swell | cambia: antes "Oleaje que va y viene" | 24 |
| `sound.thunder` | Trueno | Thunder | se queda "Trueno" (C13; "Tormenta lejana" no se graba); `SoundID.thunder` intacto; sinónimo Siri "tormenta" / "storm" | 10 |
| `capas.thunder.detalle` | lejano, sin rayos cerca | distant, no strikes nearby | línea de uso fijada por C13; el rediseño DSP elimina el crack (solo rumor): el DSP cumple el subtítulo | 28 |
| `sound.campfire` | Hoguera (es-419: Fogata) | Campfire | Pro | 10 |
| `capas.campfire.detalle` | brasas, sin chasquidos | embers, no crackle | | 28 |
| `sound.brook` | Arroyo | Brook | Pro | 10 |
| `capas.brook.detalle` | agua sobre piedras | water over stones | | 28 |
| `sound.wind` | Viento | Wind | libre (C04) | 10 |
| `capas.wind.detalle` | entre árboles | through trees | | 28 |
| `sound.cabin` | Cabina | Cabin | Pro | 10 |
| `capas.cabin.detalle` | avión en crucero | aircraft at cruise | | 28 |
| `capas.timbre` | Timbre | Tone | fila LevelRule al pie de Capas sobre el bus maestro (C29) [spike I0-7: si falla, la fila cae a 1.1 sin cambiar el copy]; timbre por capa en 1.1 | 8 |
| `capas.timbre.grave` | Grave | Deep | extremo izquierdo de la fila Timbre, paso 9 `texto2` ("Deep" no es "deep sleep": falso positivo declarado) | 6 |
| `capas.timbre.lejos` | Lejos | Far | extremo derecho | 6 |
| `capas.nota` | Se mezclan en tu iPhone mientras suenan. Nada se repite. | Mixed on your iPhone as they play. Nothing loops. | nota paso 8 `texto2` al pie de la hoja | 60 |
| `capas.deslizador` | Nivel de %@ | %@ level | etiqueta accesible del `Slider` del sistema bajo pulsación larga | 20 |
| `capas.cero` | Lo que está a cero no suena ni gasta. | What's at zero makes no sound and costs nothing. | pie de la hoja Capas (segunda nota; injerto de 03 §1.3); once texturas en 1.0 (C19). **[a verificar con I0-1: bypass real de las capas a 0 en el render; si el DSP las sigue calculando, "Lo que está a cero no suena." / "What's at zero makes no sound."]** | 44 |

#### 5e.5 Marea [E3] (Pro; suena para todos en Madrugada, C05)

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `marea.titulo` | Marea | Tide | hoja paso 3; fila de la página (existente `breath.title`, cambia de valor: C15, una unidad léxica; "Breathing tide" solo en prosa de ficha); nunca marca (C10) | 20 |
| `marea.instruccion` | Inhala mientras la ola sube, exhala mientras se retira. No hace falta mirar la pantalla. | Breathe in as the wave rises, out as it pulls back. No need to watch the screen. | paso 6 `texto2` bajo el título (existente `breath.hint`, valor igual, renombrada) | 96 |
| `marea.fase.inhala` | inhala | breathe in | paso 7 `texto2` junto a la banda, 3 respiraciones | 10 |
| `marea.fase.exhala` | exhala | breathe out | idem | 10 |
| `marea.estado.guiando.corto` | guiando · %lld por minuto | guiding · %lld per minute | versalita paso 9 `texto2` en la segunda línea de la página, en la hoja (y 264) y en la Live Activity; la hora de retirada nunca va en versalitas | 26 |
| `marea.estado.disolviendo` | disolviendo | dissolving | versalita | 12 |
| `marea.estado.pausa` | en pausa | paused | versalita, Marea con el sonido pausado | 10 |
| `marea.estado.apagada` | apagada | off | versalita en la hoja | 8 |
| `marea.estado.apagada.fila` | Apagada | Off | subtítulo paso 7 de la fila de la página | 8 |
| `marea.estado.apagada.pro` | Apagada · pro | Off · pro | fila de la página sin acceso (03 §4.7: fila editorial sin acceso lleva "pro") | 14 |
| `marea.retira.hora` | Se retira a las %@ | Recedes at %@ | paso 7 `texto2` bajo la versalita en la hoja (y 288) y en la segunda línea de la página nocturna (paso 7 Medium `texto-noche`); dato consultable, nunca versalita; la hora se escribe una sola vez por superficie | 22 |
| `marea.retirada` | Se ha retirado. El mar sigue. | It has receded. The sea goes on. | nota paso 7, 10 s, al terminar (Marea) | 32 |
| `marea.oceano.subido` | Océano subido a 40 para oír la marea. | Ocean raised to 40 so you can hear the tide. | nota 4 s cuando la Marea sube el océano desde 0 (sustituye `breath.oceanRaised`); la Marea nunca lo vuelve a bajar | 44 |
| `marea.toggle` | Marea | Tide | fila 56 con el toggle, dentro de la hoja (toggle + línea de agua; nunca un círculo, C59) | 6 |
| `marea.descenso` | Descenso | Descent | fila 56 con toggle: el ritual de la Marea (bajada 12→6 por minuto, meseta, disolución) sobre la profundidad común, 1.0 (C14, C24); "Descenso" queda reservado al ritual; la fase horaria es Día / Noche; sustituye `marea.empezar` | 10 |
| `marea.ritmo` | Empezar a 12 por minuto | Start at 12 a minute | subtítulo paso 7 de la fila Descenso: ritmo de partida fijo (parámetro, C34); nunca Salud en 1.0 ni 1.1 | 26 |
| `marea.ritmo.fila` | Ritmo | Pace | fila 56 de opciones (antes `marea.ritmo`) | 8 |
| `marea.ritmo.tranquilo` | Tranquilo · 6 por minuto | Calm · 6 per minute | opción con `checkmark`; a la derecha de la fila se abrevia "Tranquilo · 6" (`marea.ritmo.tranquilo.corto`) | 26 |
| `marea.ritmo.suave` | Suave · 8 por minuto | Gentle · 8 per minute | opción | 26 |
| `marea.ritmo.tranquilo.corto` | Tranquilo · 6 | Calm · 6 | valor a la derecha de la fila Ritmo | 14 |
| `marea.ritmo.suave.corto` | Suave · 8 | Gentle · 8 | idem | 14 |
| `marea.ritmo.exacto` | %lld por minuto | %lld per minute | valor cuando se arrastró la línea de agua a un entero distinto de 6 u 8; también el valor hablado para VoiceOver (C59) (existente `breath.rate.format`, renombrada) | 16 |
| `marea.ritmo.mio` [2.0] | Mi ritmo nocturno · %lld por minuto, según Salud | My night pace · %lld per minute, from Health | opción; pide el permiso al elegirla; Salud a 2.0 (C34), fila reservada | 48 |
| `marea.ritmo.mio.sin` [2.0] | Mi ritmo nocturno · valor por defecto | My night pace · default value | permiso denegado o sin datos | 40 |
| `marea.retira` | Se retira a los | Recedes after | fila 56 | 16 |
| `marea.retira.valor` | %lld min | %lld min | opciones 5 · 10 · 15 · 20 · 30 | 7 |
| `marea.mas` | Más ajustes | More settings | fila 56 con chevron → Háptica (1.0); Mi ritmo nocturno (2.0) | 14 |
| `marea.haptica` | Háptica | Haptics | fila 56 (también grupo de Ajustes, C58) | 8 |
| `marea.haptica.ninguna` | Ninguna | None | opción (defecto: la háptica es opt-in, C35) | 8 |
| `marea.haptica.minima` | Mínima | Minimal | opción: 3–5 respiraciones al empezar | 8 |
| `marea.haptica.marcada` [1.2] | Marcada | Prominent | se va al Watch (C35); no se compila en 1.0 | 10 |
| `marea.haptica.nota` | Tres a cinco respiraciones al empezar. De noche nunca vibra. | Three to five breaths at the start. Never at night. | nota paso 8 `texto2`; la puerta es por fase, sin CoreMotion (C35) | 60 |
| `marea.empezar` | [retirada por C14/C24] | — | sustituida por `marea.descenso` (1.0) | — |
| `marea.empezar.detalle` | [retirada por C34] | — | sustituida por `marea.ritmo` ("Empezar a 12 por minuto") | — |
| `marea.voz` | Decir inhala y exhala | Say breathe in and out | fila visible solo con VoiceOver (anuncios de fase) | 24 |
| `marea.evidencia` | Respirar a unas 6 veces por minuto se asocia en estudios a mayor variabilidad cardiaca. | Breathing at about 6 per minute is linked in studies to higher heart-rate variability. | nota paso 8 `texto2` al pie de la hoja + `sabemos.enlace` | 96 |
| `sabemos.enlace` | Qué sabemos › | What we know › | enlace paso 8 `texto2` (el chevron es tipográfico) | 34 |

#### 5e.6 Temporizador [E4] (entero libre, C03: la palabra "pro" no aparece)

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `temporizador.titulo` | Temporizador | Timer | hoja paso 3; fila de la página (existente `timer.title`: ES igual, EN cambia de "Sleep timer") | 14 |
| `temporizador.dormirme` | Hasta dormirme | Until I sleep | opción paso 5 (EN: una unidad léxica, C15); hasta 360 min | 20 |
| `temporizador.dormirme.detalle` | %lld min · se funde al final | %lld min · fades out at the end | subtítulo paso 7 `texto2`; siempre verdadera: la duración del fundido no se escribe hasta que salga del modelo (`TimerMath.fadeDuration` da 5-20 s hoy). Cuando exista en minutos: "%lld min · se funde los últimos %lld" con el segundo argumento del modelo | 28 |
| `temporizador.manto` | Manto | Blanket | opción paso 5; libre (C03); "Escudo" no se graba (C11); EN pendiente de verificar en en-US (reconciliación §6.4); `TimerMode.blanket`; antes `temporizador.escudo` | 18 |
| `temporizador.manto.detalle` | hasta las %@ · baja un poco a los 45 min | until %@ · eases down after 45 min | subtítulo; hora fija con `DatePicker`, −6 dB a los 45 min por envolvente (C22); antes `temporizador.escudo.detalle` | 40 |
| `temporizador.escudo.pro.nota` | [retirada por C03] | — | el temporizador es libre: no hay hoja Pro al confirmar la hora | — |
| `temporizador.siesta` [1.1] | Siesta | Nap | opción; hueco reservado en el selector; la palabra no se graba hasta 1.1 (C30) | 8 |
| `temporizador.siesta.detalle` [1.1] | %lld min · termina con una subida suave | %lld min · ends with a soft rise | subtítulo 1.1 (la variante `.detalle.10` se retira con la Siesta) | 40 |
| `temporizador.apagado` | Apagado | Off | opción (existente `timer.off`, se conserva) | 8 |
| `temporizador.duracion` | Duración | Length | fila con `Picker` de rueda, solo en Hasta dormirme, hasta 360 (`maxTimerMinutes` es el tope técnico para todos, C03) | 10 |
| `temporizador.duracion.pro` | [retirada por C03] | — | ninguna duración es Pro; `freeTimerMinutes` desaparece | — |
| `temporizador.hora` | Hora | Time | fila del `DatePicker` del Manto (C22); Manto no tiene tope en minutos | 8 |
| `temporizador.estado.dormirme` | Hasta dormirme · %lld min | Until I sleep · %lld min | valor paso 7 en la fila de la página: el ajuste, antes y durante (la cuenta vive en la línea de estado, en Noche y en la Live Activity: un solo reloj por pregunta) | 30 |
| `temporizador.estado.manto` | Manto · hasta las %@ | Blanket · until %@ | fila de la página; antes `temporizador.estado.escudo` | 32 |
| `temporizador.estado.siesta` [1.1] | Siesta · %lld min | Nap · %lld min | fila de la página | 18 |
| `temporizador.estado.recortado` | [retirada por C03] | — | el temporizador no se recorta al caducar la prueba | — |
| `temporizador.nota` | El sonido se funde; tu alarma no se toca. | The sound fades; your alarm is never touched. | nota paso 8 `texto2` en los cuatro modos (sustituye `timer.note`) | 48 |
| `temporizador.nota.airpods` | Si tus AirPods pausan el sonido al dormirte, %@ lo respeta y no lo reanuda. | If your AirPods pause sound when you fall asleep, %@ respects that and won't resume. | nota; `%@` = `app.name`; el `pauseCommand` con auriculares es un fundido de 3 s y nunca reanuda sola por el altavoz (C49) | 92 |
| `temporizador.quietud` [1.2] | Fundido por quietud | Fade when still | toggle; 1.2 tras el spike I0-5b (C37) | 20 |
| `temporizador.quietud.detalle` [1.2] | Si el iPhone lleva 20 min quieto, empieza antes | If your iPhone has sat still for 20 min, it starts early | subtítulo | 52 |
| `temporizador.quietud.estado` [1.2] | se funde ahora · quieto 20 min | fading now · still for 20 min | fila de la página | 32 |

#### 5e.7 Noche [E4]

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `noche.estado.sonando` | Sonando | Playing | palabra de estado paso 3 Medium `texto-noche`, sin temporizador (una palabra para un estado, como en la página) | 8 |
| `noche.estado.funde` | Se funde a las %@ | Fades at %@ | con "Hasta dormirme" / "Siesta" | 22 |
| `noche.estado.hasta` | hasta las %@ | until %@ | Manto (minúscula: completa al reloj) | 16 |
| `noche.estado.fundiendo` | Fundiendo · %lld min | Fading · %lld min | fundido de ganancia de 10–15 min con cuenta entera (C31); la cifra cambia por minuto; distinto de "Se retira" (Madrugada) | 20 |
| `noche.estado.pausa` | En pausa | Paused | pausa | 10 |
| `noche.estado.pausa.causa` | En pausa · %@ | Paused · %@ | con causa en minúscula: auriculares, AirPods, llamada (`CXCallObserver`, C48, C49) | 26 |
| `noche.estado.sin_sonido` | Sin sonido | No sound | error; el toque reintenta (Silencio) | 12 |
| `ruta.seguir_altavoz` | [retirada: unificada en `ruta.seguir_altavoz`, C49] | — | botón 64 en y 652, encima de "+15 min" con 24 pt de canal; 60 s | — |
| `noche.primera` | Puedes apagar la pantalla. El sonido sigue. | You can turn the screen off. The sound keeps playing. | primera vez, 4 s, paso 6 Medium `texto-noche` (03 §5 #10 cita la frase del PR #3 "La pantalla puede dormir."; se reescribe para que no se lea como instrucción ambigua y sube al paso 6: es la frase más pequeña que se lee de noche) | 48 |
| `noche.volver` | Mantén pulsado para volver | Hold to go back | primera vez, con la anterior; paso 6 Medium | 28 |
| `noche.ctl.menos15` | −15 min | −15 min | "Controles visibles de noche", botón 64 paso 4 (menos tipográfico); el "+15 min" de la fila es `comun.mas15` | 8 |
| `noche.ctl.pagina` | Página | Page | cuarto botón de la fila visible (vuelve a la página; el nombre dice lo que hace y coincide con el anuncio "Página" de §7) | 8 |
| `madrugada.estado` | Madrugada · 20 min | Small hours · 20 min | botón 64 que ocupa el hueco del "+15 min" en Noche terminada (C27); el mismo texto en el widget pequeño entre 00:00 y 06:00, en el Control, en el Watch (1.2) y en la Live Activity terminada (versalita `la.madrugada`); nunca un gesto oculto | 20 |

#### 5e.8 Madrugada [E4]

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `madrugada.titulo` | Madrugada | Small hours | nombre de la función en Ajustes, `ControlWidgetButton` del Centro de control, Siri, Live Activity (nunca en la propia pantalla); EN "Small hours", nunca "Small hours mode" (C15); receta fija de 20 min (C05): sin fila de duración | 12 |
| `madrugada.quedan` | %lld min | %lld min | cifra paso 1 · 56 `texto-noche`, baja por minuto (= `comun.min` en paso 1; clave propia solo por el paso) | 7 |
| `madrugada.retirada` | Se retira · %lld min | Winding down · %lld min | palabra de estado paso 3 Medium `texto-noche` los últimos 5 min, cuando el mar funde (C05, C60); también versalita en la Live Activity; distinto de "Fundiendo" / "Fading" también en EN; en 1.0 sin retirada luminosa; al terminar, nada | 20 |
| `madrugada.ajuste.nota` | Madrugada no enseña la hora a propósito. | Small hours hides the clock on purpose. | nota de Ajustes paso 8 | 44 |
| `madrugada.ajuste.hora` | Mostrar la hora en Madrugada | Show the clock in Small hours | toggle de Ajustes (opt-in, C60); una sola tinta, sin ámbar; ninguna frase de levantarse (lo que dicen los estudios va a `que_sabemos.en_vela`) | 30 |

#### 5e.9 Mezclas y guardar [E5]

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `mezclas.titulo` | Mezclas | Mixes | título de navegación (sustituye `mixes.title` / `control.mixes` "Mezclas guardadas") | 8 |
| `mezclas.seccion.tuyas` | tuyas | yours | versalita paso 9 | 6 |
| `mezclas.seccion.casa` | de la casa | from the house | versalita | 14 |
| `mezclas.esta_noche` | Esta noche | Tonight | primera fila de "tuyas": la mezcla viva | 10 |
| `mezcla.casa.rosa_lluvia` | Rosa y lluvia | Pink and rain | mezcla de la casa: rosa 20 · lluvia 55; libre (C17, C18); antes "Lluvia fina" (`mezclas.casa.lluvia`, retirada) | 14 |
| `mezcla.casa.mar_viento` | Mar y viento | Sea and wind | océano 50 · viento 20; Pro (carga recortada sin acceso, nunca hoja); antes "Mar lento" (`mezclas.casa.mar`, retirada) | 14 |
| `mezcla.casa.marron_hoguera` | Marrón y hoguera (es-419: fogata) | Brown and fire | marrón 40 · hoguera 30; Pro (carga recortada); nueva (C18) | 18 |
| `mezcla.casa.pared` | Pared | Wall | marrón 40 · lluvia 30 · viento 30; libre; nueva (C18) | 6 |
| `mezclas.casa.cama` | [retirada por C18] | — | "Cama rosa" no añade nada a "Rosa y lluvia" | — |
| `mezclas.receta.capa` | %@ %lld | %@ %lld | segmento de receta en minúscula ("lluvia 55"); la receta es solo niveles: formato v2 `[{id, level}]` + `version: 2` (C09, C20); las mezclas de la casa nunca cambian el temporizador (C18) | 14 |
| `mezclas.receta.marea` | [retirada por C20] | — | la mezcla no guarda Marea ni temporizador (formato v2 = pares id + nivel) | — |
| `mezclas.receta.temporizador` | [retirada por C20] | — | idem | — |
| `mezclas.receta.escudo` | [retirada por C20] | — | idem | — |
| `mezclas.receta.pro` | %@ es Pro | %@ is Pro | segmento final inline, sin tachar ("· océano es Pro") | 18 |
| `mezclas.receta.separador` | · | · | se compila para que la receta se componga por segmentos y parta líneas en el separador | 1 |
| `mezclas.sonando` | sonando ahora | playing now | versalita paso 9 `texto2` junto al nombre de la mezcla cargada | 14 |
| `mezclas.vacio` | La mezcla de esta noche se guarda desde su nombre. | Tonight's mix is saved from its name. | paso 6 `texto2`, sustituye a la sección "tuyas" vacía (sustituye `mixes.empty`); sin imperativo: con Button Shapes no debe parecer un botón | 52 |
| `mezclas.guardada` | Guardada | Saved | 1,5 s junto al nombre; `.success` | 10 |
| `mezclas.guardada.sin` | Guardada sin %@ | Saved without %@ | 3 s; guardar encima con una capa Pro sin acceso | 24 |
| `mezclas.conservar` | Conservar el %@ | Keep %@ | botón de texto paso 6 `texto2` en la misma línea; guarda la mezcla completa | 24 |
| `mezclas.eliminar.titulo` | ¿Eliminar "%@"? | Delete "%@"? | alerta del sistema | 30 |
| `mezclas.eliminar.nota` | La mezcla de esta noche no cambia. | Tonight's mix doesn't change. | mensaje de la alerta | 36 |
| `mezclas.casa.restaurar` | Volver a poner las de la casa | Bring back the house mixes | fila terciaria paso 6 `texto2` al final si se borró alguna de la casa (Dial) | 32 |
| `ajustes.icloud` [1.1] | Tus mezclas en iCloud | Your mixes in iCloud | fila de Ajustes, Pro, activa por defecto (C09); en 1.0 no hay sincronización (formato v2 + App Group listos) | 24 |

#### 5e.10 Pro [E5] (hoja "{marca} Pro" con `product.displayName`, C12; 29,99 € de lista sin precio de lanzamiento, C02)

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `pro.titulo` | %@ | %@ | `%@` = `product.displayName` ("SleepNoise Pro"), versalita paso 9 `texto2` arriba de la hoja; nunca un nombre grabado ni "Tu instrumento" (C12); antes `pro.cabecera` | 14 |
| `pro.precio.cargando` | — | — | cifra paso 1 hasta `Product.displayPrice` (guion largo tipográfico) | 1 |
| `pro.una_vez` | Una vez. | Once. | paso 8 `texto2` 13/18 bajo la cifra (injerto de 03 §1.3) | 10 |
| `pro.precio` | %@ · Una vez. | %@ · Once. | `%@` = `Product.displayPrice`; la cifra y la frase compuestas para la fila `pro.ajustes.ver` de Ajustes y para VoiceOver; un solo `displayPrice` de StoreKit, nunca una constante de copy (C02) | 20 |
| `pro.precio.lanzamiento` | [retirada por C02] | — | sin precio de lanzamiento; una oferta posterior se haría con StoreKit (offer code), no con copy | — |
| `pro.pie` | Un solo pago. Para siempre, en todos tus iPhone. | One payment. Forever, on every iPhone you own. | paso 2 · 28/34, 2 líneas bajo "Una vez." (sustituye `paywall.once` / `paywall.subtitle`); antes `pro.titular` (C12 fija la clave `pro.pie` para esta frase; el pie de privacidad pasa a `lo_que_no_hay.pie`) | 50 |
| `pro.con` | con pro | with pro | versalita de sección | 8 |
| `pro.incluye.texturas` | Todas las texturas | All textures | primera fila 44 paso 6 de "Con Pro"; sin número (C04: nunca se cuentan texturas); sustituye `pro.incluye.capas.6` / `.capas.11` | 20 |
| `pro.incluye.texturas.detalle` | Océano, ventilador, trueno, hoguera, arroyo y cabina | Ocean, fan, thunder, campfire, brook and cabin | subtítulo paso 7 (es-419: fogata); la lista nombrada, nunca la cifra | 64 |
| `pro.incluye.capas.6` | [retirada por C04] | — | contaba texturas | — |
| `pro.incluye.capas.11` | [retirada por C04] | — | idem | — |
| `pro.incluye.capas.11.detalle` | [retirada por C04] | — | → `pro.incluye.texturas.detalle` | — |
| `pro.incluye.marea` | Marea | Tide | fila 44 paso 6 (C15) | 20 |
| `pro.incluye.temporizador` | [retirada por C03] | — | el temporizador es entero libre: la hoja Pro no lo lista | — |
| `pro.incluye.mezclas` | Mezclas sin límite | Unlimited mixes | 3 gratis, sin límite con Pro (`freeSavedMixLimit` 1 → 3) | 20 |
| `pro.familia` | En familia | With your family | última fila de "Con Pro" (Family Sharing, 1.0, C12); antes `pro.incluye.familia` | 16 |
| `pro.gratis` | gratis siempre | always free | versalita de sección | 14 |
| `pro.gratis.lista` | Blanco, rosa, marrón, lluvia y viento · todo el temporizador · tres mezclas | White, pink, brown, rain and wind · the whole timer · three mixes | paso 6 `texto2`, 2 líneas (C03, C04; la lista libre solo crece) | 72 |
| `pro.comprar` | Comprar · %@ | Buy · %@ | acción primaria 64 entre hairlines (`índice` solo con precio); `%@` = `displayPrice`; sin "Desbloquear" (C12) | 20 |
| `pro.comprar.sin_precio` | Comprar | Buy | botón mientras no hay producto: palabra en `texto2` (6,06:1 sobre `hoja`) entre hairlines `trazo-hoja`, `.notEnabled` [anotado para el director: 03 §4.6 escribe `texto3`, pero 03 §3.1 y §4.7 reservan `texto3` a texto ≥ 18 pt y a 17 pt daría 3,25:1] | 8 |
| `pro.comprando` | Comprando… | Buying… | el botón mientras StoreKit trabaja; sin spinner | 12 |
| `pro.restaurar` | Restaurar compra | Restore purchase | acción secundaria paso 6 `texto2` (sustituye `paywall.restore` en plural) | 18 |
| `pro.buscando` | Buscando… | Looking… | el botón de restaurar mientras `AppStore.sync()` | 10 |
| `pro.resena` | Escribir una reseña | Write a review | enlace de texto paso 6 `texto2` solo en el estado comprado de la hoja Pro (C55): sin `requestReview` en 1.0 (política dormida tras bandera), sin fila "Valorar" en Ajustes; abre App Store; nunca se ve de noche | 20 |
| `pro.gracias` | Gracias. Todo abierto. | Thank you. Everything's open. | sustituye al botón 1,5 s; `.success` (sustituye `paywall.restored`, `paywall.active`) | 24 |
| `pro.fallo` | No se ha podido completar. No se ha cobrado nada. | Couldn't complete. Nothing was charged. | paso 8 bajo el botón; `.error`; botón intacto; solo `.userCancelled` y errores previos al pago (sustituye `paywall.failed`) | 52 |
| `pro.fallo.sin_confirmar` | No se ha podido confirmar. Si App Store te ha cobrado, Restaurar compra lo abre. | Couldn't confirm. If the App Store charged you, Restore purchase opens it. | paso 8; `.unverified` y errores de red tras la hoja del sistema (la transacción puede llegar por `Transaction.updates`) | 84 |
| `pro.pendiente` | Pendiente de aprobación familiar. Se abrirá solo cuando llegue. | Waiting for family approval. It will open on its own. | paso 8 (sustituye `paywall.pending`) | 66 |
| `pro.sin_tienda` | La tienda no responde. Nada cambia: sigue sonando. | The store isn't responding. Nothing changes: it keeps playing. | paso 8, solo con `isPlaying`; el único estado sin producto (tras 8 s sin respuesta o error de StoreKit; no se adivina la causa); botón `pro.comprar.sin_precio` (sustituye `paywall.purchaseUnavailable`; frase de 03 §1.3) | 54 |
| `pro.sin_tienda.silencio` | La tienda no responde. Nada cambia. | The store isn't responding. Nothing changes. | idem cuando nada suena (hoja abierta desde reposo o desde Ajustes): la app no afirma que suene algo que no suena | 36 |
| `pro.restaurar.no` | No hay ninguna compra con esta cuenta de Apple. Si la hiciste con otra, inicia sesión con ella en App Store. | No purchase found for this Apple Account. If you bought with another one, sign in with it in the App Store. | paso 8 (sustituye `paywall.nothingToRestore`); "Apple ID" dejó de ser el nombre en iOS 18 | 108 |
| `pro.ajustes.gracias` | %@ · gracias · %@ | %@ · thank you · %@ | fila de Ajustes y cabecera del estado comprado de la hoja (el recibo, C12); `%@` = `displayName`, `%@` fecha corta | 36 |
| `pro.ajustes.familia` | · en familia | · with your family | sufijo de la fila anterior | 16 |
| `pro.ajustes.ver` | %@ | %@ | fila de Ajustes sin Pro (`displayName`), con `pro.precio` a la derecha; abre la hoja (solo de día) | 16 |

#### 5e.11 Qué sabemos [E5+E7]

Cadenas largas con `\n` entre párrafos; los títulos de revista van en redonda dentro del paréntesis (sin Markdown ni `AttributedString` en el catálogo). La financiación de los estudios se cita solo cuando está verificada: hoy ninguna lo está, así que la pantalla da estudio y n (§1 fila 17). Plantilla de población (C54): "n participantes con {criterio parafraseado}, según {cita}"; nunca un diagnóstico; el lint corre aquí sin excepción. Lo que dicen los estudios sobre quedarse en la cama despierto entra como una entrada más, redactada como hallazgo, nunca como consejo ni en Madrugada (C60).

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

Longitud: afirmaciones ≤ 48 car.; cuerpos ≤ 420 car. (es-ES); pie ≤ 96 (dos líneas, C54). `que_sabemos.en_vela`: el n y la cita (`%lld`, `%@`) se rellenan desde un valor de configuración cuando E7 verifique el estudio de referencia (control de estímulos; hoy sin cita verificada: la entrada no se compila hasta tenerla, nunca con un estudio inventado). Ninguna cifra de tamaño en runtime: el tamaño instalado no coincide con el de descarga (thinning, cifrado) y una cifra que varía por dispositivo invita a la discrepancia que esta pantalla quiere evitar.

#### 5e.12 Ajustes y Diagnóstico [E5]

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `ajustes.titulo` | Ajustes | Settings | título de navegación | 10 |
| `ajustes.seccion.noche` | noche | night | versalita | 8 |
| `ajustes.noche.pasar_sola` | Pasar sola a Noche | Switch to Night | fila con valor (C47); antes `ajustes.noche.auto` | 30 |
| `ajustes.noche.pasar_sola.bloquear` | Al bloquear | When locked | opción, por defecto (C47: entra al bloquear) | 12 |
| `ajustes.noche.auto.1` | 1 min | 1 min | opción (entrada automática solo desde la página) | 6 |
| `ajustes.noche.auto.3` | 3 min | 3 min | opción | 6 |
| `ajustes.noche.auto.nunca` | Nunca | Never | opción | 6 |
| `ajustes.pantalla` | Mantener encendida | Keep screen on | fila con valor (C46); Noche duerme por defecto (`isIdleTimerDisabled` según el ajuste y `batteryState`) y se atenúa a los 60 s mientras está encendida | 20 |
| `ajustes.pantalla.carga` | Mientras carga | While charging | opción, por defecto | 16 |
| `ajustes.pantalla.siempre` | Siempre | Always | opción | 8 |
| `ajustes.pantalla.nunca` | Nunca | Never | opción | 6 |
| `ajustes.noche.controles` | Controles visibles de noche | Visible controls at night | toggle; se activa solo con Control por botón / AssistiveTouch | 30 |
| `ajustes.noche.controles.nota` | Cuatro botones grandes en Noche: −15 min, pausa, +15 min y Página. | Four large buttons in Night: −15 min, pause, +15 min and Page. | nota paso 8 | 68 |
| `ajustes.seccion.haptica` | háptica | haptics | versalita (C58; antes `ajustes.seccion.marea`) | 8 |
| `ajustes.seccion.acostarte` | al acostarte | at bedtime | versalita | 14 |
| `ajustes.acostarte` | Al acostarte | At bedtime | fila → una página de texto con los pasos de Atajos (C43); el único autoarranque de la app (C33) | 34 |
| `ajustes.acostarte.sub` | Que suene sola al activar Sueño. Dos pasos en Atajos. | Start on its own when Sleep turns on. Two steps in Shortcuts. | subtítulo | 56 |
| `ajustes.acostarte.p1` | En Atajos, toca Automatización y elige el modo de concentración Sueño, "Al activarse". | In Shortcuts, tap Automation and choose the Sleep Focus, "When turning on". | párrafo 1 de la página, paso 6 | 100 |
| `ajustes.acostarte.p2` | Añade la acción "Pon %@" y elige "Ejecutar inmediatamente". Desde esa noche sonará sola al acostarte. | Add the action "Play %@" and choose "Run immediately". From that night on it will start on its own at bedtime. | párrafo 2 (misma página); `%@` = `app.name` | 120 |
| `ajustes.acostarte.abrir` | Abrir Atajos | Open Shortcuts | botón | 14 |
| `ajustes.seccion.salida` | salida | output | versalita (C41) | 8 |
| `ajustes.salida` | Salida | Output | fila con el `AVRoutePickerView` del sistema (`routeSharingPolicy = .longFormAudio`); la única superficie de AirPlay (C41) | 8 |
| `ajustes.seccion.pro` | pro | pro | versalita | 4 |
| `ajustes.seccion.sobre` | sobre %@ | about %@ | versalita; `%@` = `app.name` en minúscula tipográfica | 16 |
| `lo_que_no_hay.titulo` | Lo que no hay | What's not here | fila de Ajustes → página (C38); también título de la captura 6 | 16 |
| `lo_que_no_hay.pie` | Sin suscripción. Sin cuenta. Sin rastreo. | No subscription. No account. No tracking. | pie de la página "Lo que no hay", de la hoja Pro y de la ficha (C09); en 1.1 pasa a "Sin suscripción. Sin cuenta. Sin rastreo. Tus mezclas, en tu iCloud si quieres."; nunca "Sin servidor"; sustituye `ajustes.privacidad` / `.sub` y el antiguo `pro.pie` | 44 |
| `lo_que_no_hay.resena` | No te pediremos que la valores. | We won't ask you to rate it. | entrada de la página, escrita como hecho de hoy (C55: sin `requestReview` en 1.0) | 36 |
| `lo_que_no_hay.diagnostico` | Un registro de la noche, en tu teléfono. Solo sale si tú lo envías. | A log of the night, on your phone. It only leaves if you send it. | entrada de la página (C56); también nota de Diagnóstico | 72 |
| `lo_que_no_hay.lista` | Sin suscripción · Sin cuenta · Sin rastreo · Sin anuncios · Sin puntuación · Sin racha · Sin tutorial | No subscription · No account · No tracking · No ads · No score · No streak · No tutorial | lista de la página y de la captura 6; sin "Sin servidor" (C09) ni "Sin red" (StoreKit usa red) | 110 |
| `como.titulo` | Cómo se genera | How it's made | fila de Ajustes → una página (C38, C53): la prueba de "nunca se repite" es esta página + el tamaño en MB + el test de autocorrelación en CI, no una animación | 16 |
| `como.cuerpo` | El sonido se fabrica en tu iPhone mientras suena: no hay archivo ni bucle. Por eso la app ocupa lo que ocupa (mira el tamaño en Ajustes) y por eso nunca se repite. En cada versión comprobamos con un test que diez minutos de sonido no se parecen a sí mismos. | The sound is made on your iPhone as it plays: there is no file and no loop. That is why the app is as small as it is (see the size in Settings) and why it never repeats. Every release is checked with a test that ten minutes of sound never resemble themselves. | cuerpo paso 6, 17/26 (es-419: "se genera") | 300 |
| `ajustes.privacidad` | [retirada por C09/C58] | — | → `lo_que_no_hay.titulo` + `lo_que_no_hay.pie` | — |
| `ajustes.privacidad.sub` | [retirada por C09/C58] | — | idem | — |
| `ajustes.debajo` [1.1] | Debajo de otro audio | Under other audio | fila de Ajustes con preferencia Preguntar / Siempre / Nunca (C16, C44); estado de sesión, no un toggle global; antes "modo Capa" | 24 |
| `ajustes.debajo.preguntar` [1.1] | Preguntar | Ask | opción, por defecto | 10 |
| `ajustes.debajo.siempre` [1.1] | Siempre | Always | opción | 8 |
| `ajustes.debajo.nunca` [1.1] | Nunca | Never | opción | 6 |
| `debajo.sonar` [1.1] | Sonar debajo | Play underneath | botón de entrada al estado cuando suena otro audio (C44) | 14 |
| `estado.debajo` [1.1] | Debajo de tu podcast | Under your podcast | línea de estado en ese estado; la fila de nivel maestro solo existe aquí (C44, C51) | 24 |
| `ajustes.version` | Versión %@ · %@ | Version %@ · %@ | "Versión 1.0 · 4,2 MB"; el segundo `%@` es el tamaño de descarga fijado en build (script sobre el .ipa thinned de referencia en `Info.plist`), nunca `Bundle` en runtime | 24 |
| `diagnostico.titulo` | Diagnóstico | Diagnostics | fila y título | 12 |
| `diagnostico.nota` | Un registro de la noche, en tu teléfono: tiempos desde Play, cortes y errores de esta sesión y la anterior. Sin fecha, sin nombres, sin identificadores. Solo sale si tú lo envías por correo. | A log of the night, on your phone: times since Play, drops and errors for this session and the last. No date, no names, no identifiers. It only leaves if you send it by mail. | paso 6 `texto2`; anillo local acotado (tiempos relativos desde Play; sin fecha, `portName` ni nombres de mezcla; sesión actual y anterior; excluido de iCloud y App Group, C56); las horas relativas no son fecha, pero no se dice "sin datos personales" | 180 |
| `diagnostico.enviar` | Enviar informe | Send report | acción primaria entre hairlines en Diagnóstico; `TextAction` en la segunda línea de la página (tercer fallo, mañana tras error); abre el correo del usuario con el texto (`mailto:` con cuerpo; C56), la misma vía que "Escribir al autor" | 16 |
| `diagnostico.vacio` | Nada que informar. | Nothing to report. | cuando el anillo está vacío | 20 |
| `diagnostico.asunto` | Informe de %@ %@ | %@ report %@ | asunto del correo; `%@` = `app.name`, `%@` versión | 30 |
| `ajustes.autor` | Escribir al autor | Write to the author | fila del grupo Diagnóstico (C58): abre el correo del usuario; sin formulario | 18 |

#### 5e.13 Superficies del sistema [E6]

| Clave | ES | EN | Contexto | Máx. |
|---|---|---|---|---|
| `la.estado.sonando` | sonando · %@ | playing · %@ | versalita 13 Medium `texto`; `%@` modo en minúscula ("hasta dormirme", "manto"; "siesta" en 1.1); Live Activity recortada: 1.0 solo en escenario A, 1.1 en B (C25); seis estados (C50) | 28 |
| `la.estado.sonando.solo` | sonando | playing | sin temporizador | 8 |
| `la.estado.pausa` | en pausa | paused | | 10 |
| `la.estado.pausa.causa` | en pausa · %@ | paused · %@ | causa en minúscula (auriculares, airpods, llamada; C48, C49) | 24 |
| `la.estado.pausa.hora` | se pausó a las %@ · airpods | paused at %@ · airpods | `pauseCommand` de AirPods (C49) | 30 |
| `la.estado.fundiendo` | fundiendo | fading | fundido de ganancia 10–15 min (C31) | 10 |
| `la.estado.terminada` | se fundió a las %@ | faded at %@ | terminada, fila superior | 22 |
| `la.estado.detenido` | se detuvo a las %@ | stopped at %@ | motor caído no recuperado, 30 min | 22 |
| `la.madrugada` | madrugada · 20 min | small hours · 20 min | terminada, fila inferior junto a ▶ (hasta 4 h: `end(content, dismissalPolicy: .after(fin + 4 h))`); "terminada → Madrugada" condicionado al spike I0-3 (C25) | 20 |
| `la.madrugada.retirada` | se retira · %@ | winding down · %@ | versalita de Madrugada los últimos 5 min; `%@` = tiempo vivo (C60) | 20 |
| `la.madrugada.prefijo` | madrugada · | small hours · | durante Madrugada: prefijo + `Text(timerInterval:)` vivo ("madrugada · 20:00"); sin `%lld`: fuera de la app no hay reloj propio | 12 |
| `la.hasta` | hasta las %@ | until %@ | Manto: versalita de tiempo en la Live Activity y en StandBy (la cifra grande es el restante); límite de 8 h asumido y cerrado por la app a las 7 h 55, el sonido sigue (C50) | 14 |
| `widget.dormir` | Dormir | Sleep | pequeño, sin sesión, 17 Semibold en el sitio del tiempo (Silencio); también nombre del widget en la galería; entre las 00:00 y las 06:00 el botón dice `madrugada.estado` (C27, C42) | 8 |
| `widget.silencio` | en silencio | silent | versalita 13 | 12 |
| `widget.sonando` | sonando | playing | versalita; el tiempo, `Text(timerInterval:)` vivo al lado | 8 |
| `widget.inline.prefijo` | SleepNoise · | SleepNoise · | inline de bloqueo: prefijo + tiempo vivo (el único widget que nombra la app: no hay sitio para el nombre de la mezcla) | 12 |
| `widget.inline.silencio` | SleepNoise · en silencio | SleepNoise · silent | | 26 |
| `widget.pequeno.descripcion` | Tu última mezcla, con Play. | Your last mix, with Play. | descripción en la galería | 30 |
| `widget.mediano.nombre` [1.1] | Mezclas | Mixes | galería (C42: mediano en 1.1; sin widget circular) | 8 |
| `widget.mediano.descripcion` [1.1] | Tres mezclas. Un toque y suenan. | Three mixes. One tap and they play. | galería (03 §5 #22: tres mezclas, no cuatro) | 36 |
| `control.titulo` | SleepNoise | SleepNoise | `ControlWidgetToggle` (= `app.name`); valores `pagina.estado.sonando` / `pagina.estado.silencio`; 1.0 sobre los intents de C43, corte sin coste en la semana 14 (C26); el tinte "on" del Control es la única excepción al "sin acento fuera de la app" (C61) | 10 |
| `control.sub.on` | %@ · %lld min | %@ · %lld min | subtítulo con la mezcla y los minutos del ajuste (el Control no tiene reloj vivo) | 26 |
| `control.sub.off` | Última: %@ | Last: %@ | subtítulo off | 24 |
| `control.madrugada.sub` | 20 min | 20 min | subtítulo del `ControlWidgetButton` `madrugada.titulo` | 6 |
| `accion.pista` | Mantén para dormir | Hold for sleep | pista del botón de Acción (toggle) | 20 |
| `accion.pista.madrugada` | Mantén para Madrugada | Hold for Small hours | pista del botón de Acción (Madrugada) | 24 |
| `nowplaying.artist` | SleepNoise | SleepNoise | Now Playing (existente, se conserva) | 10 |
| `nowplaying.title` | (nombre de la mezcla) | (mix name) | Now Playing: el título es la mezcla ("Rosa y lluvia"), ya no "Ruido para dormir"; clave retirada | 24 |
| `focus.titulo` [1.1] | SleepNoise en este modo | SleepNoise in this Focus | título del filtro | 26 |
| `focus.abrir` [1.1] | Abrir en | Open in | parámetro | 10 |
| `focus.abrir.pagina` [1.1] | Página | Page | valor | 8 |
| `focus.mezcla` [1.1] | Mezcla a cargar | Mix to load | parámetro | 16 |
| `focus.mezcla.ultima` [1.1] | La última | The last one | valor por defecto | 12 |
| `watch.madrugada` [1.2] | Madrugada · 20 min | Small hours · 20 min | segundo botón cuando no suena (= `madrugada.estado`); Watch en 1.2 (C28); en 1.0 el reloj controla con Reproduciendo del sistema | 20 |
| `watch.marea` [1.2] | %lld por minuto · %lld min | %lld per minute · %lld min | versalita bajo la línea de agua | 26 |
| `watch.volumen` [1.2] | Volumen | Volume | etiqueta accesible de la corona | 8 |
| `watch.haptica.marcada` [1.2] | Marcada | Prominent | háptica Marcada en el Watch (C35) | 10 |

#### 5e.14 Siri y Atajos [E6] · `AppShortcuts.xcstrings` (catálogo aparte: App Intents solo localiza frases desde ahí, PR #3 hallazgo 3)

Siete `AppShortcut` con frase (`PlayLastMix`, `Pause`, `PlayMix`, `PlayLayer`, `ExtendTimer`, `SetTimer`, `SmallHours`) y dos intents sin frase (`Toggle`, `CurrentState`), C43; `StartTide` / `StopTide` / `SetLevel` y el Focus filter pasan a 1.1. Todos `AudioPlaybackIntent` salvo `CurrentState`; `openAppWhenRun = false` en todos (PR #3 hallazgo 4). Siri nunca vende: sin acceso, lo Pro no suena y no se explica salvo al preguntar el estado. Todas las frases con `${applicationName}` (C10: el nombre de la app nunca se escribe en una frase); parámetros solo `AppEnum` / `AppEntity` (nunca `Int` interpolado en la frase: PR #3 bloqueante 2). "Al acostarte" es una página de texto en Ajustes (§5e.12), no una pantalla propia.

| Intent | Título ES [EN] | Frases ES | Frases EN | Respuesta hablada (solo si se pregunta o falla) |
|---|---|---|---|---|
| `PlayLastMix` | Pon ${applicationName} [Play ${applicationName}] | Pon ${applicationName} · Reproduce ${applicationName} | Play ${applicationName} · Start ${applicationName} | ninguna; sin sesión de audio: `siri.error` "No se ha podido iniciar el sonido." ["Couldn't start the sound."] |
| `PlayMix(mix)` | Pon una mezcla [Play a mix] | Pon ${mix} en ${applicationName} · Pon la mezcla ${mix} en ${applicationName} | Play ${mix} in ${applicationName} · Play the ${mix} mix in ${applicationName} | sin coincidencia: `siri.mezcla.cual` "¿Cuál de tus mezclas?" ["Which of your mixes?"] (lista) |
| `PlayLayer(layer)` | Pon una capa [Play a layer] | Pon ${layer} en ${applicationName} · Pon ruido ${layer} en ${applicationName} | Play ${layer} in ${applicationName} · Play ${layer} noise in ${applicationName} | ninguna; capa Pro sin acceso: `siri.pro` "${layer} es Pro. Suena lo demás." ["${layer} is Pro. Playing the rest."] |
| `Pause` | Pausa ${applicationName} [Pause ${applicationName}] | Pausa ${applicationName} · Para ${applicationName} | Pause ${applicationName} · Stop ${applicationName} | ninguna; si nada sonaba: nada (PR #3 hallazgo 4) |
| `ExtendTimer(minutes: AppEnum 5·10·15·30)` | Añade minutos [Add minutes] | Añade ${minutes} minutos en ${applicationName} · Alarga ${applicationName} | Add ${minutes} minutes in ${applicationName} · Extend ${applicationName} | `siri.quedan` "Quedan %lld minutos." ["%lld minutes left."] |
| `SetTimer(mode: AppEnum)` | Temporizador [Timer] | Pon ${mode} en ${applicationName} · ${applicationName} ${mode} | Set ${mode} in ${applicationName} · ${applicationName} ${mode} | ninguna (el temporizador es libre, C03) |
| `SmallHours` | Madrugada [Small hours] | Madrugada en ${applicationName} · Empieza Madrugada en ${applicationName} | Small hours in ${applicationName} · Start Small hours in ${applicationName} | ninguna; nunca prueba ni hoja (C05, C27) |
| `Toggle` (sin frase) | Alternar [Toggle] | — (solo Atajos, Control, botón de Acción) | — | ninguna |
| `StartTide` / `StopTide` / `SetLevel` [1.1] | Marea [Tide] · Nivel [Level] | Activa la Marea en ${applicationName} · Quita la Marea en ${applicationName} | Turn on the tide in ${applicationName} · Turn off the tide in ${applicationName} | 1.1 (C43); sin acceso: no suena y no se explica |
| `CurrentState` (sin frase) | Qué suena [What's playing] | — (solo Atajos) | — | `siri.estado` "%@, quedan %lld minutos." ["%@, %lld minutes left."] · `siri.estado.sin_temporizador` "%@, sin temporizador." ["%@, no timer."] · `siri.estado.sin` "%@, sin %@, quedan %lld minutos." · `siri.silencio` "Nada suena ahora." ["Nothing is playing."] · `siri.estado.marea` "%@, Marea a %lld por minuto, quedan %lld minutos." |

`AppEnum` de la Marea [1.1]: "encendida" / "apagada" con sinónimos ("activa", "quita"; "on", "off"): un `Bool` no puede ir en la frase. `AppEnum` de modos: "Hasta dormirme" / "Manto" / "Apagado" ("Siesta" solo desde 1.1, C30) con sinónimos ES ("hasta que me duerma", "toda la noche", "sin temporizador") y EN ("until I sleep", "all night", "no timer") (C11). `AppEntity` de capas: los nombres de `sound.*` con sinónimos "ruido blanco / rosa / marrón" ["white / pink / brown noise"] y "tormenta" / "storm" para Trueno (C13). Ninguna respuesta lleva exclamación, "Listo", "Hecho", precio ni "Pro" salvo `siri.pro`, que describe. Las respuestas habladas se compilan por clave en §5e.17.

#### 5e.15 Purpose strings, ficha y notas de versión

**Purpose strings (Info.plist).** 1.0 no pide ningún permiso: no hay micrófono, ni notificaciones, ni Salud, ni localización, ni seguimiento. Sin CoreMotion en producción 1.0 (C35: la puerta de háptica es por fase; el spike I0-5 es investigación): ningún `NSMotionUsageDescription` [texto preparado para el fundido por quietud de 1.2, C37: "Para saber si el iPhone está en la mesilla y no vibrar. Nada se guarda ni sale de tu iPhone." / "To tell whether your iPhone is on the nightstand, so it never buzzes there. Nothing is stored or leaves your iPhone."]. 2.0, solo si existe "Mi ritmo nocturno" (C34): `NSHealthShareUsageDescription` = "SleepNoise lee tu frecuencia respiratoria nocturna para empezar la Marea a tu ritmo. Solo lectura; nada sale de tu iPhone." / "SleepNoise reads your overnight respiratory rate to start the tide at your pace. Read-only; nothing leaves your iPhone." Sin `NSHealthUpdateUsageDescription` (no se escribe nada).

**Ficha de App Store (E8 toma de aquí).** Marca: SleepNoise, cierre el 04-12-2026 (C10); el icono no depende del nombre. Nombre (30): "SleepNoise" (10). Subtítulo (30): es-ES y es-419 "Sonidos para dormir" (19; plural, keyword del VoC: la ficha se lee "SleepNoise: Sonidos para dormir", C10; la cadena entera, 31 caracteres, no cabe en el campo Nombre, por eso va como nombre + subtítulo); en-US "Sleep sounds. Pay once." (23). Texto promocional (170): "Sonido que nunca se repite, fabricado en tu iPhone. Siete noches con todo, sin tarjeta. Un solo pago." / "Sleep sound that never loops, made on your iPhone. Seven nights with everything, no card. One payment." Primeras líneas de la descripción (sin cifra de precio ni cuenta de texturas, C02, C04): ES "SleepNoise fabrica en tu iPhone, mientras suena, un ruido que no se repite jamás: ruido blanco, rosa y marrón, lluvia, viento, océano y las demás texturas, mezcladas a tu gusto bajo un dedo. Todas las texturas, una línea cada una.\nLa Marea acompasa el oleaje a seis respiraciones por minuto y se retira sola. El temporizador se funde en vez de cortar y nunca toca tu alarma. A las tres de la mañana, la pantalla entera es el botón.\nSiete noches con todo, sin tarjeta. Después, Pro es un solo pago; blanco, rosa, marrón, lluvia, viento, todo el temporizador y tres mezclas siguen gratis.\nSin suscripción. Sin cuenta. Sin rastreo." (es-419: "genera" por "fabrica"). EN "SleepNoise makes, on your iPhone and as it plays, a noise that never loops: white, pink and brown noise, rain, wind, ocean and the other textures, mixed under one finger. All textures, one line each.\nThe Breathing tide paces the sea to six breaths a minute and recedes on its own. The timer fades instead of cutting and never touches your alarm. At three in the morning the whole screen is the button.\nSeven nights with everything, no card. After that, Pro is one payment; white, pink, brown, rain, wind, the whole timer and three mixes stay free.\nNo subscription. No account. No tracking." ("Breathing tide" solo aquí, en prosa de ficha: C15). Descripción del IAP en App Store Connect (45): "Todo, un solo pago" (19) / "Everything, one payment" (23). Keywords: §7.5 del informe; "insomnio" y "acúfenos" solo ahí. Notes for Review: cita el test de autocorrelación a 10 min en CI (C53) y puede nombrar la etiqueta clínica de los estudios de referencia (C54).

**Titulares de las seis capturas** (E8; C57: solo fondo negro, una preview muda por idioma con la página real sonando, nada animado): C1 "Un solo pago." ["One payment."] sin cifra (C02) · C2 "Un toque y suena." ["One tap and it plays."] (C33) · C3 "Seis capas a la vez. Una línea cada una." ["Six layers at once. One line each."] (C19) · C4 "El mar respira a seis por minuto." ["The sea breathes six times a minute."] · C5 Noche sola: "A las tres de la mañana, nada." ["At three in the morning, nothing."] · C6 "Lo que no hay." ["What's not here."] con `lo_que_no_hay.lista` "Sin suscripción · Sin cuenta · Sin rastreo · Sin anuncios · Sin puntuación · Sin racha · Sin tutorial" ["No subscription · No account · No tracking · No ads · No score · No streak · No tutorial"] (sin "Sin servidor", C09; sin "Sin red": StoreKit y Restaurar usan red) y el pie "Data Not Collected".

**Notas de versión 1.0** (plantilla; ≤ 4 líneas, sin "nuevo", sin "¡", sin "mejoras y correcciones"): ES "SleepNoise, rediseñada: una página negra, una línea que respira con el sonido real, y una pantalla de Noche que es toda ella el botón.\nMezclas con nombre, cuatro de la casa. Temporizador que se funde: Hasta dormirme y Manto. Madrugada: veinte minutos desde la pantalla de bloqueo.\nSiete noches con todo. Después, Pro es un solo pago. Lo gratis sigue gratis.\nSi algo no suena, Ajustes › Diagnóstico › Enviar informe. Nos gustaría saberlo." EN "SleepNoise, redesigned: a black page, one line that breathes with the real sound, and a Night screen that is all button.\nNamed mixes, four from the house. A timer that fades: Until I sleep and Blanket. Small hours: twenty minutes from the Lock Screen.\nSeven nights with everything. After that, Pro is one payment. Free stays free.\nIf something won't play, Settings › Diagnostics › Send report. We'd like to know." Plantilla para versiones siguientes: primera línea = lo que cambia para quien duerme (un hecho); segunda = lo que cambia para quien paga (si algo); tercera = gracias si alguien envió un informe que arregló algo ("Gracias a quien envió el informe del corte de las 02:14." / "Thanks to whoever sent the report about the 02:14 drop."). Nunca: "Hemos mejorado", "rendimiento", "experiencia", "estabilidad".

#### 5e.16 Accesibilidad [todas] · etiquetas, valores, pistas y acciones de 5b y 5c (`ax.*`)

Sin columna Máx.: VoiceOver no mide. Las etiquetas que son la propia cadena visible no se repiten aquí (5b las cita por su clave). Los valores con cifra usan `percentSpoken` / `Date.FormatStyle` hablado; el precio, `Product.displayPrice`.

| Clave | ES | EN | Contexto |
|---|---|---|---|
| `ax.prueba.cabecera` (pl) | Prueba, quedan %lld noches | Trial, %lld nights left | etiqueta de la cabecera (noches 2-7); `one`: "Prueba, queda una noche" / "Trial, one night left" |
| `ax.prueba.pista` | Toca dos veces para ver qué incluye Pro. | Double-tap to see what's in Pro. | pista de la cabecera |
| `ax.nombre.pista` | Mantén para guardar o renombrar. | Hold to save or rename. | pista del nombre de la mezcla (página de día) |
| `ax.nombre.pista.noche` | Toca dos veces para volver a la página de día. | Double-tap to go back to the day page. | pista del nombre en la página nocturna |
| `ax.horizonte` | Sonido | Sound | etiqueta del horizonte |
| `ax.horizonte.valor.bajo` | Sonando, nivel bajo | Playing, low level | valor por tramos del RMS con histéresis de 3 s (C63: Horizonte = elemento de estado, sin `AXChartDescriptor`) |
| `ax.horizonte.valor.medio` | Sonando, nivel medio | Playing, medium level | idem |
| `ax.horizonte.valor.alto` | Sonando, nivel alto | Playing, high level | idem |
| `ax.horizonte.marea` | Marea, %@, %lld por minuto | Tide, %@, %lld per minute | valor con Marea; `%@` = inhala / exhala |
| `ax.capa` | %@, %@ | %@, %@ | etiqueta de la fila: nombre + subtítulo ("Rosa, suave y equilibrado") |
| `ax.capa.pista` | Desliza arriba o abajo para ajustar. | Swipe up or down to adjust. | pista de la fila |
| `ax.capa.pro` | %@, %@, requiere Pro | %@, %@, requires Pro | etiqueta de la fila Pro sin acceso |
| `ax.capa.pro.valor` | en silencio, nivel guardado %@ | silent, saved level %@ | valor; `%@` = cifra hablada; sin nivel guardado: "en silencio" |
| `ax.capa.pro.pista` | Toca dos veces para ver Pro. | Double-tap to see Pro. | pista de la fila Pro, solo de día (C06, C08) |
| `ax.capa.escucha` | [retirada por C06] | — | sin escucha de 30 s en 1.0 |
| `ax.mas.pista` | Abre todas las capas. | Opens all layers. | pista de "y n más" y de "Todas las capas" |
| `ax.marea.valor` | Guiando, %lld por minuto, se retira a las %@ | Guiding, %lld per minute, recedes at %@ | valor del toggle encendido |
| `ax.marea.off` | Desactivada | Off | valor del toggle apagado |
| `ax.marea.off.pro` | Desactivada, requiere Pro | Off, requires Pro | sin acceso |
| `ax.marea.pista` | Toca dos veces para encenderla; el sonido arranca. | Double-tap to turn it on; the sound starts. | pista con acceso, en silencio |
| `ax.marea.pista.pro` | Toca dos veces para ver Pro. | Double-tap to see Pro. | pista sin acceso, solo de día (C06) |
| `ax.agua.valor` | [retirada en la corrección de S-06: la fase y los minutos caducaban entre dos dibujos] | — | el valor de la línea de agua se compone con `marea.ritmo.exacto` y `marea.retira.hora`: "6 por minuto, Se retira a las 23:27" |
| `ax.agua.pista` | Desliza arriba o abajo para cambiar el ritmo. | Swipe up or down to change the pace. | pista de la línea de agua |
| `ax.sabemos.pista` | Abre la pantalla de evidencia. | Opens the evidence screen. | pista del enlace "Qué sabemos ›" |
| `ax.haptica.pista` | De noche nunca vibra. | Never at night. | pista de la fila Háptica (C35) |
| `ax.temporizador.valor` | %1$@, %2$@ | %1$@, %2$@ | valor de la fila Temporizador sonando: el modo y los minutos tal como los dice `ax.anuncio.quedan` (plural: "Queda 1 minuto"); corrección de S-06 |
| `temporizador.cabecera.fundiendo` | Fundiendo | Fading | hoja del Temporizador, línea bajo la cifra de minutos durante el fundido: no repite la cifra (corrección de S-06) |
| `temporizador.cabecera.manto` | Baja un poco a los %lld min | Eases down after %lld min | hoja del Temporizador, línea bajo la hora del Manto, solo mientras la bajada está por venir; después, nada (corrección de S-06) |
| `ax.escudo.pro` | [retirada por C03] | — | el temporizador es libre |
| `ax.escudo.pro.pista` | [retirada por C03] | — | idem |
| `ax.duracion.pista` | Desliza arriba o abajo. | Swipe up or down. | pista de la rueda Duración (sin "requiere Pro", C03) |
| `ax.mas15` | Quince minutos más | Fifteen more minutes | etiqueta de "+15 min" en todas las superficies |
| `ax.menos15` | Quince minutos menos | Fifteen minutes less | Controles visibles de noche |
| `ax.volumen` | Volumen | Volume | rotor / Slider de Noche y Madrugada (`master` con rampa en `EngineCommand`, C51) |
| `ax.noche.pantalla` | Pantalla de noche | Night screen | etiqueta del elemento de Noche y del glifo de la barra en AX4-AX5 (= `barra.noche.ax`) |
| `ax.noche.valor` | %@. %@ | %@. %@ | valor: hora hablada + palabra de estado ("Tres y siete. Sonando. Se funde a las tres y cuarenta y dos.") |
| `ax.noche.pista` | Toca dos veces para pausar. Mantén para volver. | Double-tap to pause. Hold to go back. | pista de Noche |
| `ax.noche.pista.error` | Toca dos veces para reintentar. | Double-tap to try again. | pista con "Sin sonido" |
| `ax.altavoz.pista` | El volumen baja al cuarenta. | The volume drops to forty. | pista de "Seguir por el altavoz" |
| `ax.madrugada.valor` | Quedan %lld minutos. %@ | %lld minutes left. %@ | valor de Madrugada (`%@` = Sonando / En pausa) |
| `ax.madrugada.pista` | Toca dos veces para pausar. | Double-tap to pause. | pista de Madrugada |
| `ax.madrugada.retirada` (pl) | Se retira, quedan %lld minutos | Winding down, %lld minutes left | valor de Madrugada los últimos 5 min (C60) |
| `ax.receta.pro` | %@ requiere Pro | %@ requires Pro | sufijo hablado de la fila de mezcla |
| `ax.mezcla.pista` | Toca dos veces para cargarla. | Double-tap to load it. | pista de la fila de mezcla |
| `ax.esta_noche` | Esta noche, la mezcla de ahora | Tonight, the current mix | etiqueta de la primera fila de Mezclas |
| `ax.esta_noche.pista` | Mantén para guardarla. | Hold to save it. | pista |
| `ax.guardar.pro` | Guardar como mezcla, requiere Pro | Save as a mix, requires Pro | etiqueta del menú con la cuarta mezcla sin acceso |
| `ax.guardar.pro.pista` | Toca dos veces para ver Pro. La mezcla no cambia. | Double-tap to see Pro. The mix doesn't change. | pista |
| `ax.vaciar.pista` | Pone todas las capas a cero. Se deshace cargando una mezcla. | Sets every layer to zero. Undo by loading a mix. | pista de Vaciar |
| `ax.conservar.pista` | Guarda la mezcla completa. | Saves the whole mix. | pista de "Conservar el trueno" |
| `ax.comprar` | Comprar %@, %@ | Buy %@, %@ | etiqueta de Comprar; `%@` = `product.displayName`, `%@` = `Product.displayPrice` (VoiceOver lee la moneda sola; nunca una cifra ni un nombre escritos a mano, C12) |
| `ax.comprar.pista` | Un solo pago. Abre la confirmación de App Store. | One payment. Opens the App Store confirmation. | pista |
| `ax.comprar.sin_precio` | Comprar %@ | Buy %@ | etiqueta sin producto; `%@` = `displayName` |
| `ax.comprar.sin_precio.valor` | precio no disponible | price unavailable | valor sin producto |
| `ax.comprar.sin_precio.pista` | La tienda no responde. | The store isn't responding. | pista sin producto |
| `ax.prueba.empezar` | Empezar la prueba de siete noches | Start the seven-night trial | etiqueta de `pro.prueba.empezar` (C07) |
| `ax.prueba.empezar.pista` | No se cobra nada ni se pide tarjeta. | Nothing is charged and no card is asked. | pista de "Empezar la prueba · 7 noches" |
| `ax.resena.pista` | Abre App Store. | Opens the App Store. | pista de "Escribir una reseña" (C55) |
| `ax.reintentar` | No se ha podido iniciar el sonido. Reintentar | Couldn't start the sound. Try again | etiqueta del botón de error |
| `ax.informe.pista` | Abre tu correo con el registro de la noche. Sin nombre ni identificadores. | Opens your mail with the night's log. No name or identifiers. | pista de Enviar informe (C56) |
| `ax.autor.pista` | Abre tu correo. | Opens your mail. | pista de Escribir al autor (C58) |
| `ax.atajos.pista` | Abre la app Atajos. | Opens the Shortcuts app. | pista de Abrir Atajos |
| `ax.la.pausar` | Pausar SleepNoise | Pause SleepNoise | botón 1 de la Live Activity |
| `ax.la.reproducir` | Reproducir SleepNoise | Play SleepNoise | idem |
| `ax.la.madrugada` | Madrugada, veinte minutos | Small hours, twenty minutes | ▶ de la actividad terminada |
| `ax.isla.parar` | [retirada por C25] | — | sin Isla expandida en la Live Activity recortada |
| `ax.widget.pequeno` | %@, %@. %@ | %@, %@. %@ | etiqueta del widget pequeño: nombre, estado, verbo ("Rosa y lluvia, en silencio. Dormir.") |
| `ax.widget.fila` [1.1] | %@, %@. Reproducir. | %@, %@. Play. | fila del widget mediano: nombre, receta hablada |
| `ax.control.madrugada` | Madrugada, veinte minutos | Small hours, twenty minutes | botón del Centro de control |
| `ax.accion.silenciar` | Silenciar | Mute | acción personalizada de la fila de capa |
| `ax.accion.maximo` | Máximo | Maximum | idem; también anuncio al llegar a 100 |
| `ax.accion.deslizador` | Ajuste con deslizador | Adjust with slider | idem |
| `ax.accion.subir` | Subir | Move up | acciones de nivel (5 %) y de orden en Mezclas |
| `ax.accion.bajar` | Bajar | Move down | idem |
| `ax.accion.capas_separadas` | Ver capas por separado | Show layers separately | acción del horizonte |
| `ax.accion.ver_pro` | Ver Pro | See Pro | acción de la fila Pro (no existe de noche) |
| `ax.accion.pausar` | Pausar | Pause | acción de Noche / Madrugada; glifo de los Controles visibles |
| `ax.accion.reanudar` | Reanudar | Resume | idem |
| `ax.accion.volver` | Volver a la página | Back to the page | acción y botón (último) de Noche |
| `ax.accion.volver.dia` | Volver a la página de día | Back to the day page | acción del nombre en la página nocturna (la única salida: nunca por reloj, C40) |
| `ax.accion.guardar` | Guardar como mezcla | Save as a mix | acción del nombre y de "Esta noche" |
| `ax.anuncio.quedan` (pl) | Quedan %lld minutos | %lld minutes left | anuncio tras "+15 min" |
| `ax.anuncio.hasta` | Hasta las %@ | Until %@ | anuncio tras "+15 min" con Manto |
| `ax.anuncio.pagina` | Página | Page | anuncio al volver de Noche |
| `ax.anuncio.terminada` | Sesión terminada. Madrugada, veinte minutos, botón. | Session over. Small hours, twenty minutes, button. | anuncio de la actividad terminada |

#### 5e.17 Siri · respuestas habladas [E6] (`siri.*`, en `Localizable.xcstrings`)

| Clave | ES | EN | Contexto |
|---|---|---|---|
| `siri.estado` | %@, quedan %lld minutos. | %@, %lld minutes left. | `CurrentState` con temporizador |
| `siri.estado.sin_temporizador` | %@, sin temporizador. | %@, no timer. | sin temporizador |
| `siri.estado.sin` | %@, sin %@, quedan %lld minutos. | %@, without %@, %lld minutes left. | mezcla con capas Pro sin acceso |
| `siri.estado.marea` | %@, Marea a %lld por minuto, quedan %lld minutos. | %@, tide at %lld per minute, %lld minutes left. | con Marea |
| `siri.silencio` | Nada suena ahora. | Nothing is playing. | nada suena |
| `siri.quedan` (pl) | Quedan %lld minutos. | %lld minutes left. | tras `Extend` |
| `siri.pro` | %@ es Pro. Suena lo demás. | %@ is Pro. Playing the rest. | `PlayLayer` sin acceso |
| `siri.escudo.pro` | [retirada por C03] | — | el temporizador es libre: Manto no es Pro |
| `siri.mezcla.cual` | ¿Cuál de tus mezclas? | Which of your mixes? | `requestDisambiguation` (la única pregunta de la app fuera del borrado) |
| `siri.error` | No se ha podido iniciar el sonido. | Couldn't start the sound. | sin sesión de audio |

---

## 6. Variantes

| Variante | Qué cambia en el texto | Qué no cambia |
|---|---|---|
| **iPhone 17 Pro (393) / SE y 16e (375)** | Columna 335 en vez de 353: las cadenas de estado con dos "·" ("Sonando · se funde a las 00:42") caben a Large en los dos; `marea.estado.guiando.corto` (26 car.) cabe en una línea en 375 en todos los tramos; `pro.pie` siempre 2 líneas. Longitudes máximas de §5e medidas en 375 [a medir]. | Ninguna cadena tiene variante corta por dispositivo: se parte en el "·" |
| **Negro / papel [1.1]** | Ninguna: las mismas claves; los tokens cambian (`texto` → `tinta`, `texto2` → `tinta2`, versalitas en `tinta2`). 1.0 solo oscura (`preferredColorScheme(.dark)`, C32); Noche, Madrugada y la página nocturna siempre negras. | El copy no menciona "modo oscuro" ni "claro" en ningún sitio (HIG) |
| **ES / EN / es-419** | §0.3: siete entradas. EN es un 20-30 % más corto: las longitudes máximas son las de ES. | Nombres propios de función (Madrugada / Small hours, Manto / Blanket) no se mezclan entre idiomas |
| **High Contrast** | Ninguna en el texto; tokens `-ac`. | — |
| **Button Shapes** | Los botones de texto ("Mezclas", "Noche", "+15 min", "Entendido", "Restaurar compra", "Seguir por el altavoz", "Parar", "Enviar informe") reciben subrayado del sistema; por eso ningún texto no interactivo puede parecer un botón: las notas (`*.nota`) nunca empiezan por verbo en imperativo salvo las de ayuda de Atajos. | — |
| **Escala de grises** | Todo estado es palabra o forma: comprobado en §3 (ninguna columna depende del color). | — |
| **Filtro rojo de StandBy** | Solo `texto` fuera de la app (C61); texto ≥ 24 pt y ≥ 3:1 bajo rojo medido en dispositivo **[spike I0-6]**; plan B: `texto` → `#F0ECE4` si la medida queda por debajo de 3,5 (C62); el tiempo 96 (vivo, sin unidad) se lee a un metro; sin nombre de mezcla en StandBy (un solo elemento legible, un solo control). | — |
| **VoiceOver** | §5b; anuncios en §5b al pie. | — |
| **Acceso asistido** | Noche con un solo botón: el elemento de pantalla completa; "+15 min" sigue; nada más que leer. | — |

## 7. Háptica por evento (lo que E7 añade: el anuncio de VoiceOver que acompaña a cada háptico)

| Evento | iPhone (03 §3.8) | Anuncio VoiceOver exacto |
|---|---|---|
| Play en la página | `.impact(.medium, 0.7)` | "Sonando" |
| Pausa en la página | `.impact(.light, 0.5)` | "En pausa" |
| Nivel cruza 0 / llega a 100 | `.selection` / `.impact(.light, 0.6)` | valor hablado / "Máximo" |
| Toque en Noche o Madrugada | ninguna | "En pausa" / "Sonando" |
| +15 min (solo en la mano) | `.selection` | "Quedan 53 minutos" |
| Pulsación larga en Noche (volver) o botón "Página" | `.impact(.light, 0.4)` | "Página" (`ax.anuncio.pagina`) |
| Marea Mínima (3–5 respiraciones, opt-in; de noche nunca; Marcada → Watch 1.2, C35) | Core Haptics con `BreathCurve`, puerta por fase | "inhala" / "exhala" solo con `marea.voz` activo |
| Guardar mezcla | `.success` | "Guardada" |
| Compra | `.success` | "Gracias. Todo abierto." |
| Fallo de compra (hoja delante) | `.error` | `pro.fallo` |
| Fin de temporizador, fin de Marea, fin de prueba, error de audio, abrir Pro, enseñar el precio | **ninguna** | la línea de estado (error: `.announcement`); nada al dormir |

## 8. Lo que se queda fuera, y por qué

- **"Noches" como nombre de las mezclas** y toda la familia de Grafito §15.6 (`serie.foco`, `serie.descenso`, "Guardar como noche…"): colisión Noche / noche / Noches y "Foco" como promesa (03 §1.2). "Descenso" desaparece también como ajuste: "Empezar a mi ritmo".
- **"Un toque lo silencia"** en el tip: el toque ya no hace nada (03 §1.2).
- **"Timbre · más cálido ◂ ▸ más lejano"** y el gesto vertical de timbre: la fila existe como "Timbre" con extremos "Grave" / "Lejos" sobre el bus maestro (C29, C52); el gesto en pantalla completa no.
- **"Las once capas" / "Las siete capas Pro" / "Noches ilimitadas" / "Familia incluida"**: nunca se cuentan texturas (C04); "Todas las texturas", "sin límite" y "En familia" son los términos.
- **"insomnio" y "ansiedad"** en "Qué sabemos": "personas que duermen mal"; "No tratamos nada".
- **"Cargando precio…"** y **"No se ha podido cargar el precio. Comprueba la conexión."**: el precio en carga es "—" y el botón "Comprar" deshabilitado en `texto2`; no se anuncia una espera; sin producto hay un solo estado (`pro.sin_tienda`) y no se adivina la causa.
- **"Precio de lanzamiento hasta el…"** y **"Después, 29,99 €."**: no hay precio de lanzamiento (C02); el precio es `displayPrice` en la hoja Pro y no se escribe en la ficha ni en las capturas.
- **"antes 90"**, **"60 min · pro"** y cualquier "pro" en el temporizador: el temporizador es entero libre (C03).
- **"En pausa · alarma" / "En pausa · otra app"**: el motor no conoce la causa de una interrupción; la alarma se detecta por la ventana de la mañana (C48). "En pausa · llamada" sí existe (`CXCallObserver`).
- **"Asigna Madrugada al botón de Acción…"** en Ajustes: tip reubicado; la pista del botón de Acción ya vive en `accion.pista.madrugada`.
- **"am" / "pm"** junto al reloj de Noche: lo pinta el sistema dentro de la cifra.
- **"6/min" alternando en la Isla**: cambio periódico sin hito.
- **"Sin datos personales"** en Diagnóstico: las horas de arranque y corte lo son.
- **"Toda la noche (sutil)"** de la Marea (`breath.allNight*`, hoy en `main`): 03 §5 fija "Se retira a los 5-30"; se retira del catálogo y se pregunta en §9.
- **"Cerrar"**, "¿Qué es Pro?", "Ver Pro", "Pro está activo en este dispositivo", "Prueba de 7 días" como chip, "Personalizado": contra P9, P12 y la lista negra.
- **"Escudo nocturno" / "Night shield"**, **"Tu instrumento"**, **"Desbloquear"**, **"Lluvia fina" / "Cama rosa" / "Mar lento"**, **"Tormenta lejana"**, **"Marea respiratoria" / "Breathing tide"** en UI, **"v1/v2"**, **"Oleaje/Swell"** como función, **"perfil de entorno"**, **"chip"**, **"envolvente"**: vocabulario cerrado por la reconciliación (§3).
- **"Anoche probaste Océano. Pro, 29,99 € una vez."** (línea matinal) y la escucha de 30 s: de noche no se vende y no hay recordatorio (C06, C08).
- **"Levántate"** o cualquier frase de levantarse en Madrugada: lo que dicen los estudios va a Qué sabemos como hallazgo (C60).
- **"Siete noches con todo. Sin tarjeta…"** la primera noche: la prueba no arranca sola (C07).
- **"Sin servidor"**: deja de ser cierto en 1.1 (C09). **"Nada sale de tu iPhone"** como pie: pasa a "Sin suscripción. Sin cuenta. Sin rastreo."; en Diagnóstico, "Solo sale si tú lo envías" (C56).
- **"Valorar"** en Ajustes y `requestReview`: sin reseña en 1.0 salvo el enlace de texto en el estado comprado (C55).
- **Exclamaciones, "Listo", "Hecho"** en Siri; "Stopped" cuando nada sonaba.
- **Cualquier texto en Madrugada** salvo "20 min" y "Parar"; cualquier "Pro" o "sin {capa}" en Noche, Madrugada y las superficies del sistema (en la página nocturna "pro" y "sin {capa}" describen y se quedan; lo que no existe de noche es el precio, la prueba y la hoja).
- **Micrófono, modo cuna, informe matinal, notas de noche**: fuera de 1.0 y 1.1 (03 §6, §7.6); sin cadenas. **Siesta** (1.1), **Papel** (1.1), **Debajo de otro audio** (1.1), **Watch** (1.2), **fundido por quietud** (1.2), **Amanecer acústico** y **Salud** (2.0): especificados para su versión, no se compilan en 1.0.

## 9. Preguntas abiertas

**Para el dueño.**
1. **"Noches" de prueba frente a días del reloj.** `TrialClock` cuenta 7 × 86 400 s desde "Empezar la prueba · 7 noches" (ya no desde Play, C07; estado en Keychain) y la prueba termina con la sesión (`canDowngrade`). El copy dice "quedan 5 noches". Propuesta: n = días completos restantes redondeados hacia arriba, nunca "0 noches" (ese estado es "última noche"). ¿De acuerdo, o se cambia el contador a noches reales (sesiones con Play después de las 20:00)?
2. ~~Precio de lanzamiento~~ **cerrada por C02**: 29,99 € de lista, sin precio de lanzamiento; `pro.precio.lanzamiento` retirada; la captura 1 sin cifra.
3. **"Toda la noche"** como duración de la Marea existe en `main` (`guideMinutes = 0`, profundidad 0,2). 03 la deja fuera de la hoja y la reconciliación (C24) fija Marea 1.0 = profundidad común + ritual + toggle con "Se retira a los". ¿Se retira la función del código o solo la opción visible?
4. ~~Reparto 7.9 y 7.10~~ **cerrada por C03, C04 y §1 regla 3 de la reconciliación**: temporizador entero libre; cinco texturas libres (con viento); tres mezclas gratis (`freeSavedMixLimit` 1 → 3); `pro.gratis.lista` lo da por hecho.
5. **"Fabrica" (es-ES) / "genera" (es-419)** en la ficha, en "Qué sabemos" y en el texto promocional. es-ES usa un solo verbo en todo el documento ("se fabrica", el de la tesis de 03 §2); es-419 "se genera" (glosario §0.2). ¿Un solo verbo para las dos tiendas?
6. **Subtítulo de capa en la página.** 03 §4.2 lleva el subtítulo en todas las `LevelRule`; el jurado de primera impresión propone quitarlo en la página (ya se eligió en Capas) y dejar nombre + valor + línea. Es una variante de componente que deciden E1/E2 con el director; el copy no cambia en ningún caso.
7. **Toggle de la Marea en `índice`** (03 §4.12) frente a "un índice por pantalla" (03 §3.1): anotado en §2.1 y §2.3; propuesta `.tint(texto)`.

**Para los spikes.**
- **I0-3** (`AudioPlaybackIntent` sobre actividad terminada; C25 lo condiciona): si no es posible, `la.madrugada` pasa al widget de bloqueo y la Live Activity terminada dice solo `la.estado.terminada`.
- ~~I0-4~~ **cerrada por C49**: el `pauseCommand` con auriculares es un fundido de 3 s; `pagina.estado.pausa.airpods`, `la.estado.pausa.hora` y `temporizador.nota.airpods` se compilan.
- ~~I0-5~~ **cerrada por C35**: sin CoreMotion en producción 1.0; el spike queda como investigación; ningún purpose string en 1.0 (el texto espera al fundido por quietud de 1.2, C37).
- **I0-6** (tinte real de StandBy; C62): texto ≥ 24 pt y ≥ 3:1 bajo rojo medido en dispositivo; plan B `texto` → `#F0ECE4` por debajo de 3,5. El copy no cambia en ningún caso.
- **I0-7** (timbre en bus, C29): si falla, la fila `capas.timbre` cae a 1.1 sin cambiar el copy.
- ~~Decisión E4~~ **cerrada por C31**: fundido de ganancia de 10–15 min con cuenta entera; las claves `*.fundiendo` se compilan; `temporizador.dormirme.detalle` sigue diciendo "se funde al final" hasta que la duración salga del modelo.
- ~~Spike `CXCallObserver`~~ **cerrada por C48**: `CXCallObserver` en 1.0; `pagina.estado.pausa.llamada` se compila; la alarma se detecta por la ventana de la mañana.
- **Spike de pausa bloqueada (E4 / I0)**: ¿se mantiene el motor rindiendo silencio durante la pausa para que la reanudación por auriculares y la ventana de 20 min funcionen con la pantalla bloqueada? Coste de batería a medir.

**Tokens que no existen y se han necesitado:** ninguno. Todas las cadenas viven en `texto`, `texto2`, `texto3`, `texto-noche` o `tinta*`; ninguna lleva `índice` (03 §3.1: el acento nunca es cuerpo de texto; "Comprar" lo lleva en las hairlines, no en la palabra).

## 10. Autoevaluación

**Puerta de formato (03 §8.3.1).** Cinco tablas: 5a movimiento con señal (T1-T27) · 5b VoiceOver por control (53 controles tras la reconciliación) · 5c gesto → alternativa → Control por botón → teclado (16 gestos) · 5d Dynamic Type por tramo (11 pantallas) · 5e catálogo ES/EN por clave (17 grupos; recuento real tras la poda de duplicados en la nota al pie de esta sección). Medidas en pt; todas las y en la retícula de 4 salvo las del sistema. Hex: ninguno escrito; solo tokens de §3. Maqueta y texto coinciden: tras la pasada de reconciliación (lint de §0.6, `comm -23` de las claves de §0-§4 contra la primera columna de §5e), cero claves huérfanas; el resultado se repite en cada cierre.

**Las doce pruebas del brief.**

| P | Prueba hecha sobre el copy |
|---|---|
| P1 Noche manda | De noche existen 15 cadenas (§5e.7-8 más `comun.mas15`, `comun.parar`, `ruta.seguir_altavoz`, `estado.volumen`, `madrugada.estado`) y ninguna de venta, prueba ni error salvo "Sin sonido"; la página nocturna describe ("pro", "sin trueno") y no vende (ninguna hoja, ningún precio, ninguna línea matinal: C08; `NightWindow` 21:00–07:00). |
| P2 Un gesto | "+15 min" es una sola clave (`comun.mas15`) en hoja, Noche, Live Activity, Isla, Controles visibles y Watch; nunca cambia de sitio ni de texto, y su resultado está escrito en los tres casos (§2.5). |
| P3 Negro real | Ninguna cadena lleva color; el acento no es texto. |
| P4 Causa en el sonido | Cada texto que cambia nombra su señal (5a); ninguna cadena promete un dato que el motor no produce (la causa de una interrupción, la duración del fundido, el precio futuro). |
| P5 Tipografía primero | Cada cadena tiene su paso de la escala de nueve; ninguna en Bold ni en mayúsculas sostenidas; versalitas reales ≥ 13 pt. |
| P6 Aire antes que cajas | Ninguna cadena pide un fondo: estados como palabra, errores como línea. |
| P7 Estado por forma | §3: cada estado es una palabra distinta en cada superficie; comprobado en escala de grises por construcción. |
| P8 44 / 64 | Las cadenas que son botón de noche ("+15 min", "Parar", "Seguir por el altavoz", "Página", la segunda línea de la página nocturna) van en 64 pt; "+15 min" también en la hoja; ≥ 24 pt de canal entre objetivos sin borde. |
| P9 Nada bloquea | Ninguna palabra de la lista negra; "pro" describe y conserva el nivel (C23); ningún "antes X"; el temporizador entero es libre (C03). Recorrido de la primera noche sin prueba escrito en §4.8. |
| P10 Una pantalla, una decisión | §1: cada pantalla con su pregunta y su única frase; ningún título explicativo. |
| P11 Lo técnico debajo | "Tranquilo · 6" antes que "6 por minuto"; "Nivel de Lluvia" solo bajo pulsación larga; cifras exactas en VoiceOver y Siri. |
| P12 Componentes de Apple | "Renombrar" / "Eliminar" / "Cancelar" son los del sistema; sin "Cerrar"; Toggle, Picker y DatePicker sin etiquetas propias. |

**Listas negras.** Lint de §0.5 (límites de palabra, por idioma, fuera de acentos graves y de §0.4-§0.5, §8, §10, §11 y Anexo) pasado el 16 de noviembre de 2026 sobre las columnas ES y EN de §5e (lo que se compila): **ocho coincidencias, las ocho declaradas en §0.5** (`pagina.error.inicio.2` y `.3` "close" en frase, `lo_que_no_hay.pie` "No subscription", `sabemos.2.cuerpo` "no es un producto sanitario" / "not a medical product", `sabemos.pie` "consejo médico" / "medical advice"; tras la reconciliación `capas.thunder.detalle` ya no lleva "close" y entra "Deep" en `capas.timbre.grave`; la pasada se repite al cerrar §12); ninguna cadena lleva "improves", "mejore", "antes" seguido de cifra, "Apple ID", "am" / "pm" ni "Sin datos personales". Sobre el cuerpo de este documento el lint solo tiene sentido con las exclusiones de §0.5 más §0.1-§0.2 (la voz y el glosario citan lo vetado) y la columna "Lo que esa pantalla nunca dice" de §1; con ellas, las coincidencias restantes son las mismas ocho y las menciones de "Noche" / "noche". El recuento se anota en el `.xcstrings` semilla con la fecha de cada pasada; esta frase no vuelve a decir "cero" sin el comando y la fecha al lado.

**Recuento del catálogo tras la poda.** Las claves que la reconciliación del 16-11-2026 retira, renombra o añade están en §12 (una línea por delta). Claves retiradas antes por duplicado o por promesa sin modelo: `temporizador.mas15`, `noche.mas15`, `la.mas15`, `watch.mas15` (→ `comun.mas15`); `madrugada.parar`, `la.parar` (→ `comun.parar`); `isla.noche`, `focus.abrir.noche` (→ `barra.noche`); `mezcla.menu.renombrar` (→ `comun.renombrar`); `tip.noche` (→ `noche.volver`); `la.estado.guiando`, `marea.estado.guiando` (→ `marea.estado.guiando.corto`); `widget.quedan`, `la.madrugada.quedan`, `isla.tiempo`, `widget.inline` con `%lld` (→ `Text(timerInterval:)` + prefijos); `control.on`, `control.off`, `control.madrugada` (→ `pagina.estado.*`, `madrugada.titulo`); `madrugada.ajuste.duracion` (→ `madrugada.titulo`); `temporizador.estado.apagado` (→ `temporizador.apagado`); `widget.pequeno.nombre` (→ `widget.dormir`); `temporizador.estado.dormirme.quedan`, `temporizador.estado.siesta.quedan`, `temporizador.mas30`, `temporizador.mas5`, `isla.mas10`, `isla.ritmo`, `standby.min`, `noche.am`, `noche.pm`, `noche.ctl.mas15`, `temporizador.nota.siesta`, `pro.precio.error`, `pagina.estado.pausa.alarma`, `pagina.estado.pausa.otra`, `marea.estado.activa.fila`, `ajustes.accion.sugerencia`. Añadidas: `comun.mas15`, `comun.parar`, `mezclas.receta.escudo`, `pro.sin_tienda.silencio`, `pro.fallo.sin_confirmar`, `la.madrugada.prefijo`, `widget.inline.prefijo`, `noche.ctl.pagina`, las `ax.*` de §5e.16 y las `siri.*` de §5e.17.

**Lo que no se ha verificado:** longitudes en 375 pt y en AX5 en dispositivo [a medir]; legibilidad de la versalita 22 en StandBy [spike I0-6]; las frases de Siri en español reconocidas de verdad por el NLU (PR #3 lo dejó sin probar); la pronunciación de "SleepNoise" por Siri en español.

---

## Anexo · Claves de `Localizable.xcstrings` (main, 109) y su destino

**Se conservan (clave y valor):** `app.name`, `a11y.percentFormat`, `common.save` (→ `comun.guardar` por alias), `common.cancel`, `sound.white`, `sound.pink`, `sound.brown`, `sound.rain`, `sound.fan`, `sound.ocean`, `nowplaying.artist`, `timer.off` (→ `temporizador.apagado`), `timer.minutesFormat` (→ `comun.min`), `trial.gotIt` (→ `comun.entendido`), `control.play` / `control.pause` (etiquetas del Disco).

**Se conservan con el valor cambiado:** `sound.white.detail` → `capas.white.detalle` (igual), `sound.pink.detail` → igual, `sound.brown.detail` → "retumbo grave" / "low rumble", `sound.rain.detail` → "lluvia fina" / "fine rain", `sound.fan.detail` → "ventilador lejano" / "distant fan", `sound.ocean.detail` → "oleaje lento" / "slow swell", `timer.title` → EN "Timer", `breath.title` → `marea.titulo` ("Marea" / "Tide", C15), `breath.hint` → `marea.instruccion` (igual), `breath.rate.format` → `marea.ritmo.exacto`, `breath.oceanRaised` → `marea.oceano.subido`, `error.audio` → `pagina.error.inicio`, `mixer.silent` → `pagina.estado.silencio`, `mixes.empty` → `mezclas.vacio`, `mixes.title` / `control.mixes` → `mezclas.titulo`, `mixes.save.title` → `mezcla.menu.guardar`, `mixes.name.placeholder` → `mezcla.guardar.campo`, `paywall.restore` → `pro.restaurar`, `paywall.failed` → `pro.fallo`, `paywall.pending` → `pro.pendiente`, `paywall.nothingToRestore` → `pro.restaurar.no`, `paywall.purchaseUnavailable` → `pro.sin_tienda`, `paywall.benefit.breath` → `pro.incluye.marea`, `paywall.benefit.mixes` → `pro.incluye.mezclas`, `paywall.benefit.timer` → retirada (el temporizador es libre, C03), `paywall.title` → `pro.ajustes.ver`, `paywall.benefit.textures` → `pro.incluye.texturas`.

**Se retiran (sin sustituto o sustituidas por la estructura):** `common.close`, `common.pro`, `control.pro`, `control.save`, `control.timer` (la fila dice `temporizador.titulo`), `mixer.tagline` ("Para la noche"), `mixes.defaultNameFormat` ("Mezcla %lld": el nombre automático viene de las capas), `mixes.save.message`, `mixes.stripped` (→ `mezcla.nombre.sin` + `pagina.estado.sonando.sin`; el identificador de UI test `strippedMixNote` se conserva), `nowplaying.title` (el título es la mezcla), `paywall.active`, `paywall.benefit.*.detail` (4), `paywall.keepFormat`, `paywall.once`, `paywall.purchaseFormat` ("Desbloquear Pro"), `paywall.restored`, `paywall.subtitle`, `paywall.trial.*` (5), `sound.locked`, `sound.proOnly` (→ `comun.pro`), `timer.custom`, `timer.locked`, `timer.note` (→ `temporizador.nota`), `timer.remaining`, `trial.*` (11: chip, intro, ended, price), `breath.allNight`, `breath.allNight.note`, `breath.comfort`, `breath.dissolve`, `breath.duration`, `breath.rate`, `breath.settings.hint`, `breath.state.dissolving`, `breath.state.guiding`, `breath.subtitle.*` (3).

Los once identificadores de accesibilidad de `main` (`playButton`, `openMixes`, `openTimer`, `openPaywall`, `breathToggle`, `breathLocked`, `strippedMixNote`, `trialIntroCard`, `trialEndedCard`, `trialCardDismiss`, `paywall.purchase`, `paywall.trial`) se conservan como `accessibilityIdentifier` para los UI tests; `breathLocked`, `strippedMixNote` y las dos tarjetas de prueba se mantienen como identificadores de los nuevos elementos equivalentes (fila Marea con "pro", `mezcla.nombre.sin`, los párrafos de prueba).

---

## 11. Respuesta al jurado

Registro histórico del 16-11-2026 (mañana). Donde la reconciliación del mismo día decide otra cosa, manda §12: en particular el punto 16 (precio de lanzamiento, cerrado por C02: la clave se retira), el 2 ("Mar lento" pasa a "Mar y viento", C18) y el 3 (la pausa de AirPods queda confirmada por C49, ya no depende de spike).

Hallazgos no aplicados o aplicados en otra dirección, con la razón escrita. Todo lo demás de las cinco listas está aplicado en el cuerpo del documento (puerta de los jurados, 03 §8.3.2: se corrige o se razona aquí).

1. **3 de la mañana · página nocturna sin "sin %@" ni "pro"** (vaciar el valor de la fila Pro, nombre sin sufijo, Marea solo "Apagada"). Rechazado: 03 §5 #3 define la página nocturna como "la misma página con una tinta" y 03 §3.1 regla 3 solo cambia el color; "pro" y "sin trueno" describen lo que suena y quitarlos a las 3 de la mañana haría mentir a la línea de estado. Se adopta la lectura del jurado de honestidad: lo que no existe de noche es el precio, la prueba y la hoja Pro (§2.1, §3 Reglas, §4.10).
2. **3 de la mañana · "Mar lento · sin océano" en minúscula**. Rechazado: 03 §1.3 injerta literalmente "Mar y viento · sin Océano" / "Sea and wind · without Ocean" (es un nombre); en la línea de estado, que es una frase, la capa va en minúscula. La distinción se escribe en `mezcla.nombre.sin`.
3. **3 de la mañana · una sola cadena de pausa por auriculares** (fundir "En pausa · auriculares" y "En pausa · AirPods"). Rechazado: 03 §1.3 y §3.7 distinguen la pausa de AirPods (3 s audio / 2 s interfaz; nunca reanudar por encima de 40) de la desconexión; la segunda cadena ya depende del spike I0-4 y se retira sola si no se confirma (§9).
4. **3 de la mañana · columna StandBy en la tabla de §3**. Aplicado como nota al pie de la tabla, no como columna: StandBy es la Live Activity a pantalla completa y una columna más haría ilegible la tabla; el contenido (restante 96 + "hasta las 7:00") está escrito en §2.11 y en la nota.
5. **Honestidad · `pro.sin_tienda` = "La tienda no responde. Nada cambia."** Aplicado a medias: 03 §1.3 y §4.6 injertan literalmente "Nada cambia: sigue sonando", así que esa frase se conserva cuando `isPlaying`; para la hoja abierta en silencio se añade `pro.sin_tienda.silencio` sin la afirmación. Es la variante que el propio jurado ofrecía como alternativa.
6. **Honestidad · añadir la financiación de los cuatro estudios**. Se toma la otra rama que el jurado proponía: §1 y §2.9 dicen "estudio y n" y "financiación académica" se quita hasta verificarla (§5e.11).
7. **Tipografía · `pro.una_vez` retirada (3 de la mañana, primera impresión)**. Rechazado retirarla: 03 §1.3 injerta "Una vez." ["Once."] de Silencio como pieza del paywall. Se aplica la versión del jurado tipográfico: pasa a paso 8 y la hoja queda en seis estilos.
8. **Tipografía · toggle de la Marea en `texto`**. No aplicado: 03 §4.12 fija `.tint(índice)` y es ley; el conflicto con 03 §3.1 regla 2 queda anotado para el director en §2.1, §2.3 y §9.7, con la propuesta `.tint(texto)`. Lo que sí se corrige es el índice sin sonido: encender la Marea arranca el sonido (03 §1.3) y `marea.estado.activa.fila` se retira.
9. **Tipografía · hairlines de Comprar a 1,5 pt**. Aplicado como propone el jurado (1,5 pt cumple el token de 03 §3.1) y marcado [a decidir por el director] porque 03 §4.6 escribe 1 pt: es una contradicción interna de 03 que E7 no puede resolver.
10. **Tipografía · "Comprar" deshabilitado en `texto2`**. Aplicado y anotado: 03 §4.6 dice `texto3`, pero 03 §3.1 y §4.7 reservan `texto3` a texto ≥ 18 pt; se sigue la regla del token y se deja la contradicción escrita para el director.
11. **Plataforma · T10 `TimelineView(.everyMinute)`**. Aplicado con nota: 03 §3.7 escribe "`Text(.time)` a 1 Hz"; el cambio visible sigue siendo por minuto, que es lo que la regla protege, y la implementación concreta se anota para E1.
12. **Plataforma · "+15 min" también en Madrugada e Isla (retirar `isla.mas10`)**. Aplicado aunque 03 §5 #20 escriba "+10": P2 (un gesto, un paso) y 03 §3.5 pesan más que una cifra de la tabla de inventario; se deja anotado en §2.11.
13. **Plataforma · `.immediate` en T20**. Aplicado contra la letra de 03 §5 #19, porque contradice 03 §1.3 (la actividad terminada que se queda hasta 4 h) y en ActivityKit `.immediate` la retiraría en el acto; se sigue §1.3 y se anota.
14. **Primera impresión · horizonte en y ≈ 323**. Rechazado: 03 §1.3 fija y = 284 en 852 de forma explícita; se fija 284 en reposo, sonando y con Marea, y se recoloca todo alrededor (§2.1).
15. **Primera impresión · retirar `pro.prueba.estado.gratis`**. Rechazado: 03 §1.2 decide que la cabecera "gratis" existe y desaparece tras 7 sesiones. Se aplica la versión de 3 de la mañana: "gratis siempre" (14 car.), botón a la hoja Pro.
16. **Primera impresión · retirar `pro.precio.lanzamiento` del todo**. Rechazado: 03 §7.8 pide que el precio de lanzamiento se diga "como tal" y el brief §2.2 pide la fecha de fin. Se aplica la versión de honestidad y plataforma: un solo argumento, sin cifra futura.
17. **Primera impresión · retirar `marea.estado.apagada.pro`** (la fila de la Marea dice solo "Apagada"). Rechazado: 03 §4.7 fija que la fila editorial sin acceso lleva "pro" en versalitas; la Marea es una fila editorial. Sí se quita "antes 90" de la fila del temporizador, que era el otro "pro" sobrante.
18. **Primera impresión · retirar `mezcla.nombre.sin`** (el nombre no cambia). Rechazado: 03 §1.3 injerta "el título honesto de la mezcla recortada" de Dial. La ausencia se dice en el nombre (sustantivo) y en la línea de estado (frase); en Mezclas la receta es otra pantalla.
19. **Primera impresión · fila de capa sin subtítulo en la página**. No es decisión de copy: 03 §4.2 lleva el subtítulo en toda `LevelRule`. Se anota como pregunta 6 de §9 para E1/E2 y el director; el copy no cambia en ningún caso.
20. **Primera impresión · retirar `capas.nota`**. Rechazado: 03 §5 #5 la pide en la hoja Capas. `capas.cero` se conserva como injerto de 03 §1.3 y se marca [a verificar con I0-1] (honestidad).
21. **Primera impresión · un solo verbo "se genera" en es-ES y es-419**. Rechazado para es-ES: la tesis de 03 §2 dice "fabrica" y el glosario §0.2 ya fija "se fabrica" (es-ES) / "se genera" (es-419). Se unifica es-ES en "se fabrica" en todo el documento (jurado tipográfico) y la pregunta queda en §9.5 para el dueño. El subtítulo de la ficha sí cambia ("Sonido de noche. Un solo pago").
22. **Primera impresión · reducir la guía de Atajos a una fila y un botón** (borrar `.p1` / `.p2`). Rechazado: 03 §5 #24 pide "guía de dos pantallas de texto"; las dos pantallas son texto plano sin imágenes y no son un onboarding (viven en Ajustes, bajo demanda). `ajustes.accion.sugerencia` sí se retira (plataforma, primera impresión, honestidad coinciden).
23. **Primera impresión · cifra de la hoja del Temporizador "38 min" frente a la Live Activity "38:12"**. Aplicado dentro de la app (cambio seco por minuto, §2.4, T8); fuera de la app se mantiene `Text(timerInterval:)` porque no hay reloj propio (plataforma): son dos reglas para dos sitios y se escriben las dos.

---

## 12. Reconciliación aplicada (16-11-2026)

Fuente: `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§0–§6). Este fichero se corrige primero (orden de aplicación: 10 → 04 → 05–09 → 11 → 03 → FUNCIONES) para que los demás hereden el vocabulario. Una línea por delta que nombra a 10 o que la reconciliación aplica a todo el paquete (§3 vocabulario, §4 reparto, §1 regla 7 "nada se vende de noche"). Las claves retiradas quedan en §5e marcadas **[retirada por Cnn]** y no se compilan; las renombradas conservan en su fila la clave anterior ("antes `…`").

### 12.1 Deltas aplicados

| C | Qué cambió en 10 |
|---|---|
| C01 | Cabecera: esta guía es la fuente de verdad del vocabulario (§3 de la reconciliación = §0.2) y declara el reparto de §4; regla 8 de la reconciliación ("los números son los del código") en §0.1. |
| C02 | `pro.precio.lanzamiento` retirada; `pro.precio` = "{displayPrice} · Una vez."; captura C1 "Un solo pago." sin cifra; descripción de ficha sin cifra; §8 y §9.2 (cerrada); T27 sin la clave; lint ES añade `lanzamiento`, EN `launch price`. |
| C03 | Temporizador entero libre: retiradas `temporizador.duracion.pro`, `temporizador.escudo.pro.nota`, `temporizador.estado.recortado`, `pro.incluye.temporizador`, `ax.escudo.pro`, `ax.escudo.pro.pista`, `siri.escudo.pro`; `ax.duracion.pista` sin "requiere Pro"; `pro.gratis.lista` dice "todo el temporizador"; "pro" no aparece en §2.4, §3, §4.5, §4.8; `temporizador.hora` = DatePicker del Manto; Siesta a 1.1. |
| C04 | Cinco libres / seis Pro, sin contar: `pro.incluye.texturas` "Todas las texturas" + `.detalle` (lista nombrada); retiradas `pro.incluye.capas.6`, `.capas.11`, `.capas.11.detalle`; `sound.wind` libre; `pro.gratis.lista` con viento; glosario y §0.4 vetan cifras de texturas en paywall y ficha; lint `once texturas`. |
| C05 | Madrugada = océano fijo bajo + Marea 8/min para todos: `madrugada.estado` = "Madrugada · 20 min", `madrugada.retirada` = "Se retira · n min" (+ `la.madrugada.retirada`, `ax.madrugada.retirada`); §2.6, §3, §4.7; sin fila de duración en Ajustes; nunca prueba ni hoja. |
| C06 | Sin escucha de 30 s: retiradas `comun.escucha`, `ax.capa.escucha`, T22; `ax.capa.pro.pista` / `ax.marea.pista.pro` = "Toca dos veces para ver Pro."; §2.2, §3, §4.4, §4.8, §4.10, §10 P9; "pro · N" solo como nivel guardado. |
| C07 | Prueba desde la hoja Pro: `pro.prueba.empezar` = "Empezar la prueba · 7 noches" (+ `.nota`, `ax.prueba.empezar`), `pro.prueba.estado` = "prueba · quedan n noches" (+ `.ultima`, `.gratis`); antes `prueba.empezar*` y `prueba.cabecera*`; retiradas `prueba.bienvenida` y `prueba.bienvenida.14` (la primera noche no hay párrafo); §1 fila 4/15, §2.1, §2.8, §4.1, §4.2, §4.8, T18, §9.1 reformulada (Keychain). |
| C08 | Sin línea matinal: `pagina.estado.manana.pro` retirada; T27 solo con `.manana.error`; §1 fila 25, §2.1, §2.2, §3, §4.10; de noche tocar una fila Pro no hace nada. |
| C09 | `lo_que_no_hay.pie` = "Sin suscripción. Sin cuenta. Sin rastreo." (sustituye el antiguo `pro.pie` de privacidad y `ajustes.privacidad` / `.sub`); nota del texto 1.1 ("Tus mezclas, en tu iCloud si quieres"); "Sin servidor" fuera de `lo_que_no_hay.lista` y de la captura 6; `ajustes.icloud` [1.1]; receta de mezcla = solo niveles (formato v2). |
| C10 | SleepNoise por defecto; todas las frases Siri con `${applicationName}` (también los títulos de `PlayLastMix` y `Pause`); `ajustes.acostarte.p2`, `diagnostico.asunto`, `temporizador.nota.airpods` y `ajustes.seccion.sobre` toman el nombre de `app.name` (`%@`); "Marea" nunca marca; ficha "SleepNoise: Sonidos para dormir" como nombre + subtítulo (ver 12.2). |
| C11 | `timer.modo.manto` → aquí `temporizador.manto` = "Manto" / "Blanket" (+ `.detalle`, `temporizador.estado.manto`, `mezclas.receta.*` retiradas por C20); "Escudo" sustituido en todo el documento salvo como término vetado; sinónimos Siri "toda la noche" / "all night"; EN pendiente de verificación en-US (reconciliación §6.4). |
| C12 | `pro.titulo` = "{displayName}" (antes `pro.cabecera` "sleepnoise pro"); `pro.una_vez` = "Una vez."; `pro.pie` = "Un solo pago. Para siempre, en todos tus iPhone." (antes `pro.titular`); `pro.comprar` = "Comprar · {displayPrice}"; `pro.familia` = "En familia" / "With your family" (antes `pro.incluye.familia`, EN "Family Sharing"); estado comprado = recibo (`pro.ajustes.gracias` con `displayName`); `ax.comprar*` con `displayName`; sin "Desbloquear", sin nombre grabado, sin "Tu instrumento". |
| C13 | `sound.thunder` = "Trueno" / "Thunder" se queda (ver 12.2: "Tormenta lejana" rechazada); `capas.thunder.detalle` = "lejano, sin rayos cerca" / "distant, no strikes nearby"; sinónimo Siri "tormenta" / "storm"; ya no hay falso positivo "close" en EN. |
| C14 | `marea.descenso` = "Descenso" / "Descent" (ritual de Marea, 1.0); "Descenso" como fase horaria sustituido por "página de día" en §2.1, §4.3, §4.6, 5c, T21, `ax.nombre.pista`; glosario: fase Día / Noche interna. |
| C15 | Regla de nombres en la cabecera (sustantivo sin adjetivo en ES; unidad léxica en EN); `marea.titulo` = "Marea" / "Tide" (antes "Marea respiratoria" / "Breathing tide"; "Breathing tide" solo en la prosa EN de la ficha); `temporizador.dormirme` EN "Until I sleep"; "Small hours" nunca "Small hours mode"; glosario §0.2 = §3 de la reconciliación. |
| C16 | `ajustes.debajo` = "Debajo de otro audio" / "Under other audio" [1.1] (+ Preguntar / Siempre / Nunca); `estado.debajo` = "Debajo de tu podcast" / "Under your podcast" [1.1]; "capa" = un sonido de la mezcla; "modo Capa" vetado. |
| C17 | Regla en §5e.4 y §0.2: textura = sustantivo + línea de uso; mezcla de la casa nunca textura + adjetivo; `mezcla.casa.rosa_lluvia` = "Rosa y lluvia" / "Pink and rain"; `capas.rain.detalle` pasa de "lluvia fina" a "sobre el tejado" / "on the roof" para no colisionar con el nombre vetado (el lint es `-i`); lint añade `lluvia fina`, `cama rosa`, `mar lento`, `noche de fuego`. |
| C18 | Cuatro mezclas de la casa: `mezcla.casa.rosa_lluvia`, `mezcla.casa.mar_viento` ("Mar y viento", Pro, carga recortada), `mezcla.casa.marron_hoguera` ("Marrón y hoguera", Pro; es-419 "fogata"), `mezcla.casa.pared` ("Pared", libre); retiradas `mezclas.casa.lluvia`, `mezclas.casa.cama`, `mezclas.casa.mar`; receta de niveles, nunca cambian el temporizador; `mezcla.nombre.sin` ejemplo "Mar y viento · sin Océano"; §0.4 y §1 fila 12-13; widget mediano [1.1]. |
| C19 | `capas.tope` = "Seis a la vez" / "Six at once" (T24); once texturas en 1.0 en §2.2 y §5e.4 (ninguna marca [1.1]); `capas.cero` en 1.0; captura C3 "Seis capas a la vez. Una línea cada una."; lint `ranura[s]?` / `slot[s]?`. |
| C20 | Formato v2 (pares id + nivel): retiradas `mezclas.receta.marea`, `mezclas.receta.temporizador`, `mezclas.receta.escudo`; receta de "Esta noche" solo niveles (§2.7). |
| C21 | Pulsación larga → Slider del sistema (`capas.deslizador`) escrito en §2.1 fila de capa y §2.2; sin selector por ranura. |
| C22 | Manto por hora: `temporizador.hora` (DatePicker), `temporizador.manto.detalle` = "hasta las %@ · baja un poco a los 45 min" / "until %@ · eases down after 45 min" (−6 dB a los 45 min); sin tope en minutos; "Hora de levantarte" no existe. |
| C23 | "pro · N" conserva el nivel; la degradación nunca escribe; guardar conserva sin diálogo: `comun.pro.nivel`, §2.1, §3, §4.8, §4.10, T3, §10 P9. |
| C24 | Marea 1.0 = profundidad común + ritual (Descenso) + toggle: §2.3, `marea.descenso`, T6 pasa a 1.0; gestos por textura 1.1; Salud 2.0; "v1/v2" vetado en §0.1, §0.2 y lint. |
| C25 | Live Activity recortada: 1.0 solo en escenario A, 1.1 en B; sin Isla expandida (`ax.isla.parar` retirada; `comun.mas15` y `comun.parar` ya no la citan); StandBy = la misma vista escalada con un solo control (pausa/play), sin "+15", texto ≥ 24 pt; §1 fila 19-21, §2.11, §3, 5b. |
| C26 | Control de Centro de control + botón de Acción en 1.0 (corte semana 14): `control.titulo`, §1 fila 23. |
| C27 | Madrugada siempre botón: `madrugada.estado` "Madrugada · 20 min" en Noche terminada (hueco del "+15", T29), widget pequeño 00:00–06:00, bloqueo, Control, Siri; sin doble toque (5c); §2.5, §4.6, §4.7. |
| C28 | Watch 1.2: todas las `watch.*`, `comun.min.quedan`, `comun.mas15`, 5b, 5c y §1 fila 26 pasan de [1.1] a [1.2]; en 1.0 Reproduciendo del sistema. |
| C29 | `capas.timbre` = "Timbre" / "Tone", `capas.timbre.grave` = "Grave" / "Deep", `capas.timbre.lejos` = "Lejos" / "Far" [spike I0-7]; fila al pie de Capas en §2.2; 5b y 5c; §8 actualizado; falso positivo "Deep" declarado en §0.5. |
| C30 | Siesta a 1.1: `temporizador.siesta`, `temporizador.siesta.detalle`, `temporizador.estado.siesta`, `pagina.estado.sonando.siesta` marcadas [1.1]; `temporizador.siesta.detalle.10` retirada; hueco reservado en §2.4; fuera de las frases y `AppEnum` de Siri; lint `siesta` / `nap` hasta 1.1. |
| C31 | Fundido de ganancia 10–15 min con cuenta entera: "Fundiendo · n min" deja de depender de la decisión E4 en `pagina.estado.fundiendo`, `noche.estado.fundiendo`, `la.estado.fundiendo`, §1 fila 10, §3, T11, §4.2 y §9 (cerrada). |
| C32 | Solo oscura en 1.0: §1 fila 29 y §6 "Negro / papel" marcadas [1.1]. |
| C33 | La app abre en reposo: §1 fila 16 y §4.1; sin "abrir sin sonar" (§2.10); autoarranque solo vía "Al acostarte"; captura C2 "Un toque y suena." / "One tap and it plays.". |
| C34 | `marea.ritmo` = "Empezar a 12 por minuto" / "Start at 12 a minute" (parámetro; la fila de opciones pasa a `marea.ritmo.fila` "Ritmo"); `marea.ritmo.mio` / `.mio.sin` a [2.0]; `marea.empezar.detalle` retirada; §0.4; purpose string de Salud marcado 2.0. |
| C35 | Sin CoreMotion en 1.0: `marea.haptica.nota` = "Tres a cinco respiraciones al empezar. De noche nunca vibra." / "Three to five breaths at the start. Never at night."; `ax.haptica.pista`; `marea.haptica.marcada` → [1.2] Watch (+ `watch.haptica.marcada`); grupo "háptica" en Ajustes; purpose string de movimiento fuera de 1.0; §7 y §9 I0-5 (cerrada). |
| C36 | "Amanecer" vetado hasta 2.0 en §0.1, §0.2 y lint; Retirada de Manto 1.1 citada en §2.6 (Madrugada sin retirada luminosa en 1.0). |
| C37 | `temporizador.quietud*` de [1.1] a [1.2]; texto del purpose string reservado para entonces. |
| C38 | Entran "Cómo se genera" (`como.titulo`, `como.cuerpo`) y "Lo que no hay" (`lo_que_no_hay.titulo`, `.pie`, `.resena`, `.diagnostico`, `.lista`) como filas de Ajustes y páginas (§1 filas 31-32, §2.10); Now Playing título = mezcla (ya estaba); sin panel "ahora mismo" ni botón AX. |
| C39 | "Esta noche" definido en §0.2, §1 fila 12-13 y §2.7 como nombre de la mezcla viva, no pantalla; Papel, widget mediano, Acceso asistido y Retirada a 1.1. |
| C40 | `NightWindow` 21:00–07:00 en todo el documento (antes 22:00-07:00); página nocturna por procedencia, dura la sesión, sin salida a las 07:00 (§1 fila 3, §2.1, §4.6, T21); el tip nunca de noche (T17). |
| C41 | `estado.ruta` = "Sonando · en %@" / "Playing · on %@"; `estado.pausa.auriculares` = "En pausa · auriculares" (antes `pagina.estado.pausa.auriculares`, también palabra de Noche); `ajustes.salida` = "Salida" / "Output" + `ajustes.seccion.salida`; §3 fila nueva; 5b. |
| C42 | Widgets: pequeño "Dormir" + rectangular + inline en 1.0; mediano "Mezclas" [1.1] (`widget.mediano.*`, `ax.widget.fila`); sin circular; StandBy = pequeño sin fondo; §1 fila 22, §2.11. |
| C43 | Tabla de Siri reescrita: siete intents con frase (`PlayLastMix`, `Pause`, `PlayMix`, `PlayLayer`, `ExtendTimer`, `SetTimer`, `SmallHours`) + `Toggle` y `CurrentState` sin frase; `Resume` absorbido por `Toggle`; `StartTide` / `StopTide` / `SetLevel` y Focus filter a 1.1; "Al acostarte" = una página de texto (`ajustes.acostarte` "Al acostarte", `.p1` / `.p2` como párrafos de la misma página). |
| C44 | `debajo.sonar` = "Sonar debajo" / "Play underneath" [1.1]; preferencia `ajustes.debajo.*` Preguntar / Siempre / Nunca; fila de nivel visible solo en ese estado (§3). |
| C45 | Sin cambio de copy; los spikes citados en §9 pasan a los nombres de la reconciliación (I0-2, I0-3, I0-5/5b, I0-6, I0-7). |
| C46 | `ajustes.pantalla` = "Mantener encendida" / "Keep screen on" con `ajustes.pantalla.carga` "Mientras carga" (defecto), `.siempre`, `.nunca`; Noche duerme por defecto, atenuada a 60 s (§2.5, §2.10). |
| C47 | `ajustes.noche.pasar_sola` = "Pasar sola a Noche" / "Switch to Night" (antes `ajustes.noche.auto`) con `ajustes.noche.pasar_sola.bloquear` "Al bloquear" (defecto) · 1 min · 3 min · Nunca; Noche nunca crea temporizador ("+15" solo si existe; `comun.mas15`, §2.5, §4.5, §4.6, 5b); "atenuada" no es estado. |
| C48 | Regla de interrupciones por ventana de la mañana (05:00–11:00 o fin de Manto −60 min) en §3, §4.5, §4.11; `pagina.estado.pausa.llamada` se compila (`CXCallObserver` en 1.0); `noche.estado.pausa.causa` y `la.estado.pausa.causa` incluyen "llamada"; §9 spike cerrado. |
| C49 | `ruta.seguir_altavoz` = "Seguir por el altavoz" / "Keep playing on speaker" (una clave; antes `pagina.accion.altavoz` y `noche.altavoz` con EN "on the speaker"), visible 60 s; caída de ruta = 40 ms + pausa; reanudación capada a 0,4 → `estado.volumen`; `pauseCommand` de AirPods confirmado (`pagina.estado.pausa.airpods`, `la.estado.pausa.hora`, `temporizador.nota.airpods` sin spike); §0.3, §2.5, §3, §4.11, T12, 5b, §9 I0-4 (cerrada). |
| C50 | Live Activity: dos botones (pausa con fundido 3 s / play, "+15" vacío en Manto), seis estados, sin "prueba caducada" ni "bajando", 8 h asumidas y cierre a las 7 h 55 (`la.hasta`, T20, §2.11). |
| C51 | `estado.volumen` = "Sonando · al %lld" / "Playing · at %lld" (sustituye `pagina.estado.volumen40`); maestro de sesión solo por arrastre vertical en Noche y Madrugada; sin fila en la página en 1.0; `ax.volumen` sin spike I0-1; §1 fila 10, §2.5, §3, §4.3, T11, 5c. |
| C52 | Arrastre horizontal = nivel; vertical = scroll / maestro; el gesto de timbre no existe (5c, §8). |
| C53 | Horizonte, no "envolvente": `como.titulo` / `como.cuerpo` + test de autocorrelación citados; preview de App Store = página real; "envolvente" vetado en §0.1 y lint; Notes for Review cita el test (§5e.15). |
| C54 | Lista negra "sin excepción" también en Qué sabemos (§0.4, §0.5); plantilla "n participantes con {criterio parafraseado}, según {cita}" en §2.9 y §5e.11; `sabemos.2.cuerpo` reescrito ("veinte participantes con dificultad para dormirse, según Tsai…"); título `sabemos.titulo` = "Qué sabemos" / "What we know" (§3 de la reconciliación) en todo el documento; `sabemos.enlace` "Qué sabemos ›". |
| C55 | `lo_que_no_hay.resena` = "No te pediremos que la valores." / "We won't ask you to rate it." (hecho de hoy); `pro.resena` = "Escribir una reseña" / "Write a review" solo en el estado comprado (+ `ax.resena.pista`); sin fila "Valorar"; sin `requestReview` en 1.0. |
| C56 | `lo_que_no_hay.diagnostico` = "Un registro de la noche, en tu teléfono. Solo sale si tú lo envías."; `diagnostico.nota` describe el anillo acotado (tiempos desde Play, sin fecha ni nombres, sesión actual y anterior); `diagnostico.enviar` abre el correo del usuario (ya no `ShareLink`); `diagnostico.asunto` con `app.name`; `ax.informe.pista`; §1 fila 30. |
| C57 | Capturas C1–C6 en §5e.15: "Un solo pago." · "Un toque y suena." · "Seis capas a la vez. Una línea cada una." · "El mar respira a seis por minuto." · Noche sola "A las tres de la mañana, nada." · "Lo que no hay." con `lo_que_no_hay.lista`; una preview muda por idioma con la página real; solo fondo negro; EN "What's not here." (§3). |
| C58 | Inventario de Ajustes en §2.10 y §5e.12 = la lista de C58: Noche (Pasar sola · Hora en Madrugada · Controles visibles · Mantener encendida), Háptica, Al acostarte, Salida, Pro, Qué sabemos, Lo que no hay, Diagnóstico + `ajustes.autor` "Escribir al autor" / "Write to the author" (+ `ax.autor.pista`), versión y MB; iCloud [1.1]; sin "abrir sin sonar", sin reseña, sin duración de Madrugada, sin guía AirPods. |
| C59 | Marea = toggle + línea de agua, nunca círculo; "solo oleaje" no es estado (§1 fila 6-7); valor hablado "{n} por minuto" (`marea.ritmo.exacto`, 5b). |
| C60 | `madrugada.retirada` = "Se retira · n min" / "Winding down · n min" (+ `la.madrugada.retirada`, `ax.madrugada.retirada`, T28); una sola tinta, hora opt-in, nada al terminar; la frase de levantarse no existe (§8); `que_sabemos.en_vela` (+ `.afirmacion`) como hallazgo con n y cita (se compila cuando E7 verifique la cita; ver 12.3). |
| C61 | Una sola tinta `texto` fuera de la app; la excepción del tinte "on" del Control anotada en `control.titulo`; §1 fila 22, §2.11, §6. |
| C62 | StandBy: texto ≥ 24 pt y ≥ 3:1 bajo rojo medido (spike I0-6), plan B `texto` → `#F0ECE4` (§6, §9); el copy no cambia. |
| C63 | Horizonte = elemento de estado "Sonido" con valor (histéresis 3 s) y acción "Ver capas por separado"; sin `AXChartDescriptor` ni rotor Audio Graph (5b, 5c, `ax.horizonte.valor.*`); Magic Tap en la raíz. |
| C64 | "chip" vetado en §0.1 y lint (el estado es StateWord o fila con estado en versalita). |
| C65 | Un solo TipKit (`tip.arrastre`, solo de día); `noche.primera` / `noche.volver` son texto fijo (ya lo eran, T25); lista cerrada (§1 filas 10 y 16, §2.1, T17). |
| C66 / C67 | Sin cambio de copy (vidrio y escala tipográfica son de 04); §2.8 anota que E5 confirma ≤ 6 estilos con el detalle de texturas añadido. |
| §3 | Glosario §0.2 reescrito con los términos de §3 de la reconciliación (mezclas de la casa, Seis a la vez, textura, Timbre, Manto, Hasta dormirme / Until I sleep, Descenso, Se retira, Empezar la prueba, Lo que no hay, Cómo se genera, Diagnóstico, Escribir al autor, Salida, Sonando · en / al, Seguir por el altavoz, Debajo de otro audio, Pasar sola a Noche, Mantener encendida, Al acostarte) y la lista de palabras que no se graban (§0.1, lint §0.5). |
| §4 | Reparto gratis/Pro de 10 = §4 de la reconciliación: 5 texturas libres, temporizador libre, Marea Pro salvo Madrugada, 3 mezclas gratis (`freeSavedMixLimit` 1 → 3), prueba 7 noches en Keychain, En familia en 1.0; reglas transversales (nunca se vende en `NightWindow`, nunca se cuentan texturas, la degradación nunca escribe, Madrugada nunca abre la hoja) repartidas por §1, §2, §3 y §4. |
| §9 | Preguntas cerradas y marcadas: 2 (C02), 4 (C03/C04/§1 regla 3), I0-4 (C49), I0-5 (C35), decisión E4 (C31), `CXCallObserver` (C48); reformuladas 1 (Keychain, C07) y 3 (C24). Siguen abiertas: 1, 3, 5, 6, 7, I0-3, I0-6, I0-7 y el spike de pausa bloqueada. |

### 12.2 Deltas rechazados o aplicados con matiz (con razón)

| C | Qué pide la tarea | Qué se hace y por qué |
|---|---|---|
| C13 | La lista de la tarea nombra "Tormenta lejana" entre el vocabulario a actualizar. | Se aplica C13 tal cual la decide la reconciliación: la textura es "Trueno" / "Thunder" y "Tormenta lejana" queda vetada (§3: palabras que no se graban). `SoundID.thunder` es código del hilo de audio y un nombre con adjetivo rompe la regla de catálogo (C15, C17). La propuesta anterior de 10 queda retirada. |
| C10 | Título de ficha "SleepNoise: Sonidos para dormir". | Materialmente imposible como campo Nombre de App Store Connect: 31 caracteres para un límite de 30. Se aplica como nombre "SleepNoise" + subtítulo "Sonidos para dormir" (19), que es como la ficha lo muestra ("SleepNoise: Sonidos para dormir"). El subtítulo anterior ("Sonido de noche. Un solo pago") se retira; "Un solo pago" sigue en la captura C1, el texto promocional y la descripción. |
| C12 (clave `pro.pie`) | `pro.pie` = "Un solo pago. Para siempre, en todos tus iPhone." | Aplicado, pero la clave `pro.pie` de 10 llevaba el pie de privacidad. Para no dejar dos frases bajo una clave: la frase de C12 toma `pro.pie` (antes `pro.titular`) y el pie de privacidad pasa a `lo_que_no_hay.pie` (C09), que la hoja Pro también muestra. |
| C34 (clave `marea.ritmo`) | `marea.ritmo` = "Empezar a 12 por minuto". | Aplicado; la fila de opciones de ritmo que usaba esa clave pasa a `marea.ritmo.fila` ("Ritmo" / "Pace"). Se anota para 06. |
| C60 (`que_sabemos.en_vela`) | Entrada "n participantes …, según X". | Clave y redacción añadidas (hallazgo, sin imperativo), pero el n y la cita quedan como argumentos sin rellenar: E7 no cita un estudio que no ha verificado. La entrada no se compila hasta tener la cita (misma regla que la financiación de los estudios, §5e.11). |
| C07 / C19 / C30 etc. (nombres de clave) | La reconciliación nombra claves (`timer.modo.manto`, `timer.modo.siesta`, `pro.prueba.*`, `capas.tope`, `estado.ruta`…). | Se adoptan tal cual cuando la clave no existía; cuando 10 ya tenía la clave con otro prefijo (`timer.*` → `temporizador.*`), se conserva el prefijo del catálogo de 10 y se anota la equivalencia en la fila ("antes `…`"). El prefijo `timer.` está reservado a las claves heredadas de `main` (Anexo). |
| C25 vs C50 (número de estados) | C25 dice "cuatro estados" para la Live Activity recortada; C50 dice seis. | Se sigue C50 (la ficha específica: sonando, guiando, en pausa · causa, fundiendo, terminada, madrugada). Se anota para 09. |

### 12.3 Pendiente que la reconciliación deja a 10

- Verificar "Blanket" con un hablante en-US antes de la semana 6 (reconciliación §6.4); si cambia, cambian `temporizador.manto`, `temporizador.manto.detalle`, `temporizador.estado.manto`, `la.estado.sonando` (modo) y la frase de Siri, nada más.
- Cita verificada para `que_sabemos.en_vela` (control de estímulos) antes de compilarla.
- Repetir el lint de §0.5 sobre el catálogo con las palabras nuevas (`escudo`, `lanzamiento`, `siesta`, `ranura`, `v1`/`v2`, `chip`, `envolvente`…) y anotar la fecha en el `.xcstrings` semilla; §10 ya no afirma el recuento anterior.
- Reconteo de longitudes en 375 pt para las cadenas nuevas más largas: `pro.gratis.lista` (72), `pro.prueba.empezar` (28), `lo_que_no_hay.lista` (110, solo página y captura).
