# Plan maestro — SleepNoise 1.0 "el instrumento de sueño"

*16-11-2026. Documento de cabecera: resume y enlaza la investigación, el plan de funciones, la dirección de diseño, las ocho especificaciones y la reconciliación. Cuando un detalle de aquí difiera de un documento enlazado, manda el enlazado, con el orden de precedencia de la reconciliación §1.*

## 0. Resumen de una página

**Tesis.** SleepNoise deja de ser "otra app de ruido blanco" y se relanza como un instrumento de sueño: sonido generado en tiempo real que nunca se repite, una página que se lee a oscuras, un temporizador en el que se puede confiar y nada que vender entre las nueve de la noche y las siete de la mañana. Pago único, sin cuenta, sin rastreo.

**Cliente.** Tres segmentos (investigación §1 y §3): el durmiente ligero urbano que paga por fiabilidad, la persona con acúfenos o hipersensibilidad al silencio, y la pareja con horarios distintos. Los tres odian la suscripción y los loops que se repiten.

**Posicionamiento y precio.** Alta gama por sobriedad, no por lujo: tipografía primero, un acento, líneas finas, relieve solo en el disco de Play. 29,99 € de lista, sin precio de lanzamiento, prueba local de 7 noches que arranca con la primera acción Pro.

**Alcance 1.0.** Once texturas (cinco libres), página de 03, Marea 1.0, temporizador entero libre con Manto por hora, Noche y Madrugada, tres mezclas guardadas gratis, hoja Pro, Siri, widgets, Control y botón de Acción, Live Activity recortada solo si hay dos parejas. Lista cerrada en la reconciliación §5.

**Calendario.** Semana 30 con dos parejas de ingenieros (escenario A) o semana 44 con una (escenario B). Estimación 34,25–36,5 semanas-pareja en A, 32,25–34 en B, reserva del 30 % aparte.

**Cuatro decisiones del dueño con plazo** (§11): acento, marca, segunda pareja, "Blanket" en inglés. Todo lo demás está decidido.

## 1. Mapa de documentos

| Documento | Qué manda | Estado |
|---|---|---|
| `docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md` | Mercado, segmentos, ciencia permitida, ecosistema Apple verificado, precio | Cerrado |
| `docs/research/COMPETIDORES-2026-11-16.md` | 40 fichas de competidores, huecos | Cerrado |
| `docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md` | Qué, cuándo y cuánto: 12 principios, alcance por versión, 63 fichas, descartes, disposición del PR #3 | Reconciliado (§12) |
| `docs/design/00-02` | Brief creativo, referencias, materiales | Cerrados |
| `docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md` | Cómo: carácter, tokens, componentes, inventario de 30 superficies | Reconciliado (§12) |
| `docs/design/04-SISTEMA-FUNDAMENTOS.md` | Tokens, tipografía, rejilla, movimiento, accesibilidad | Reconciliado (§12) |
| `docs/design/05-PAGINA-Y-CAPAS.md` | Página principal, hoja Todas las capas, LevelRule | **Pendiente de aplicar la reconciliación** (ver §12) |
| `docs/design/06-MAREA.md` | Marea 1.0 | Reconciliado (§12) |
| `docs/design/07-TEMPORIZADOR-NOCHE-MADRUGADA.md` | Temporizador, Manto, Noche, Madrugada, interrupciones | **Pendiente de aplicar la reconciliación** |
| `docs/design/08-MEZCLAS-PRO-PRUEBA.md` | Mezclas guardadas, hoja Pro, prueba, degradación | Reconciliado (§12) |
| `docs/design/09-ECOSISTEMA.md` | Now Playing, Siri, widgets, Control, Live Activity, StandBy | **Pendiente de aplicar la reconciliación** |
| `docs/design/10-GUIA-DE-COPY.md` | Vocabulario ES/EN, claves de copy, lista de afirmaciones prohibidas | Reconciliado (§12) |
| `docs/design/11-ICONO-Y-APP-STORE.md` | Icono, capturas, ficha, Notes for Review | Reconciliado (§12) |
| `docs/design/mockups/sleepnoise-direccion-2026-11-16.html` | 19 cuadros de la dirección | Alineado con 05–09 antes de la reconciliación |
| `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` | Las 67 decisiones (C01–C67), precedencia, vocabulario, matriz gratis/Pro, alcance y estimación finales | **Lista única de decisiones** |
| `docs/REVIEW-PR3-2026-11-16.md` | Revisión del PR #3 de Cursor y su encaje | Cerrado |

## 2. Mercado y cliente (síntesis)

- **La categoría crece por suscripción y se contrae en descargas**; la "sleep app tradicional" pierde usuarios frente a Background Sounds de iOS y a las apps de meditación. El hueco es la gama alta de pago único: nadie lo ocupa en español y pocos en inglés (investigación §2 y §4.3).
- **Lo que compra el cliente** no es "ruido" sino que el sonido no se repita, que el temporizador no falle, que la pantalla no ilumine el cuarto y que no haya suscripción. Son las cuatro frases que más se repiten en las reseñas de una estrella de los líderes (investigación §3.2).
- **Riesgo Apple**: Background Sounds cubre el caso básico gratis. Se neutraliza con lo que Apple no hace: mezcla, Marea, Manto, Madrugada, mezclas guardadas, Siri y widgets propios (investigación §2.7).
- **Ciencia**: solo se afirma lo que la tabla de mecanismos permite; la lista cerrada de afirmaciones prohibidas (investigación §5.2) es test de copy y criterio de App Review.

## 3. Producto: principios y alcance

Los doce principios están en FUNCIONES §1; los que deciden más son: nada se vende de noche; los números que ve el usuario salen del código; la lista de texturas libres solo crece; el hilo de audio veta lo que no quepa en `RenderState` sin puerta de ingeniería.

**1.0 (lista cerrada, reconciliación §5)**: primitivas (bus maestro con rampa, fundido de ganancia, formato de mezcla v2 + App Group, `NightWindow`, Keychain de prueba, spikes de la semana 2); bloque A sonido y página; bloque B temporizador y noche; bloque C mezclas y compra; bloque D ecosistema y confianza. Solo oscura, iOS 17, SleepNoise, 29,99 sin lanzamiento.

**1.1**: Live Activity (escenario B), Papel (modo claro), debajo de otro audio, iCloud KVS, escucha de 30 s, gestos de Marea por textura, timbre por capa, Siesta, retirada de Manto por luminancia, widget mediano, más frases de Siri, Novedades, Acceso asistido, decisión sobre `requestReview`.

**1.2**: Watch, fundido por quietud, háptica en el Watch. **2.0**: Salud en Marea, Amanecer acústico.

**Matriz gratis/Pro** (reconciliación §4): libre = blanco, rosa, marrón, lluvia, viento, temporizador entero, tres mezclas guardadas, Noche y Madrugada completas, Siri y widgets. Pro = seis texturas, Marea (suena para todos en Madrugada), mezclas sin límite, Family Sharing.

## 4. Diseño

- **Dirección Grafito** (03 §1–§4): negro `#000000` de fondo, hoja `#1C1C1E`, texto `#E8E4DC`, acento Índice `#F0C020` solo mientras hay sonido o dedo, nunca como relleno. SF Pro, escala de nueve pasos, rejilla de 4 pt, margen 20, horizonte a un tercio, radio 0, relieve solo en PlayDisc.
- **Seis componentes propios**: SoundLine, LevelRule, TideLine, PlayDisc, FullScreenControl, HairlineAction, más EditorialRow, StateWord, TextAction, Sheet y BottomBar (03 §4, 04).
- **Página principal** (C19, 05): nombre de la mezcla, Horizonte quieto, hasta tres filas que suenan y "y N más", "Todas las capas" en hoja. Sin ranuras ni selector por ranura.
- **Noche** (07): entra al bloquear, "Mantener encendida", atenuada a los 60 s, vertical = maestro. **Madrugada**: océano fijo a nivel bajo con Marea a 8 por minuto, para todos, sin prueba ni paywall.
- **Copy** (10): sustantivo sin adjetivo en español, unidad léxica de una o dos palabras en inglés; vocabulario fijado en reconciliación §3.
- **Criterios de aceptación** del diseño en FUNCIONES §6.3; cada spec lleva sus cinco tablas obligatorias (anatomía, estados, medidas, copy, accesibilidad).

## 5. Arquitectura técnica

- **Motor**: `AVAudioSourceNode`, mailbox seqlock, `EngineCommand` y `SoundGains` POD. Cambios que exige el plan y que no están en main: bus maestro con `master` y rampa; `defaultFadeIn` 1,5 s lineal → 0,8 s easeOut; retirar el tick de 4 Hz del `SleepTimerController`; `freeSavedMixLimit` 1 → 3; `startTrialIfNeeded()` fuera de `play()`; `AccessPolicy.freeTimerMinutes` desaparece; `SavedMix` versión 2 con App Group; `NightWindow`; estado de prueba en Keychain.
- **Puertas de ingeniería**: spikes de la semana 2 (I0-2 umbral LevelRule, I0-3 intents, I0-5/5b investigación, I0-6 contraste bajo rojo, I0-7 timbre en bus) y puerta del bus en la semana 4–6. Caídas ya decididas: fila Timbre → 1.1; fundido espectral → solo ganancia; Marea Mínima sin sensor.
- **Ecosistema**: App Intents compartidos entre Siri, widgets, Control, botón de Acción y Live Activity; `openAppWhenRun` donde haga falta; frases solo con AppEnum/AppEntity.
- **CI**: hoy no hay. Mínimo para la semana 1: build + tests + `CopyLintTests` + test de autocorrelación de las texturas.

## 6. Monetización y App Review

- Un no consumible a 29,99 € (`displayPrice` del producto, nunca constante de copy); Family Sharing activado ("En familia"); sin precio de lanzamiento (Directiva 98/6/CE).
- Prueba local de 7 noches: se dispara con la primera acción Pro tras una hoja que dice "Empezar la prueba · 7 noches"; estado en Keychain; degradación sin escritura; nunca entre 21:00 y 07:00.
- App Review: Notes for Review (11), lista de afirmaciones prohibidas (investigación §5.2), "Qué sabemos" y "Lo que no hay" como páginas de texto, sin analítica.

## 7. Lanzamiento y ASO

- Nombre SleepNoise salvo decisión contraria el 04-12-2026; icono y comprobación legal avanzan en paralelo (semanas 1–3).
- Capturas: la 1 sin cifra de precio; la 3 vende la página; C2/C3 con los títulos fijados en 11 §12.
- Ficha: "Sin suscripción. Sin cuenta. Sin rastreo." como pie; sin contar texturas ("Todas las texturas").
- Idiomas de 1.0: español e inglés (en-US revisado por hablante antes de la semana 6).

## 8. Métricas sin analítica

Sin SDK ni telemetría. Lo que se mide (FUNCIONES §8): conversión y reembolsos en App Store Connect, reseñas por versión, informes de diagnóstico local que el usuario envía, tests de autocorrelación en CI. Criterio de éxito 1.0: conversión prueba→compra ≥ 8 %, valoración ≥ 4,6, cero reseñas de una estrella por temporizador.

## 9. Riesgos

| Riesgo | Mitigación |
|---|---|
| El bus maestro no cabe en el hilo de audio | Spike I0-7 en la semana 2; puerta en 4–6; caída escrita (timbre a 1.1) |
| Una sola pareja de ingenieros | Escenario B: semana 44, Live Activity a 1.1 |
| App Review rechaza la prueba local | Hoja de prueba explícita como divulgación; plan B: no consumible de nivel 0 |
| Background Sounds de Apple mejora | Diferenciación en Marea, Manto, Madrugada, mezclas y ecosistema |
| El nombre no supera la comprobación legal | Icono y copy usan `${applicationName}`; cierre el 04-12-2026 |

## 10. Equipo y calendario

| Semanas | Hito |
|---|---|
| 1 | Reconciliación aplicada a 05, 07 y 09; CI mínima; icono y legal arrancan |
| 2 | Spikes I0-2, I0-3, I0-5/5b, I0-6, I0-7 |
| 3–8 | Primitivas: bus, fundido, formato v2, NightWindow, Keychain, PR-A del PR #3 |
| 4–6 | Puerta del bus; confirmación de la segunda pareja (14-12-2026) |
| 9–18 | Bloque A (página, capas, Marea) y bloque B (temporizador, Noche, Madrugada) |
| 14 | Corte de Control y botón de Acción |
| 19–24 | Bloque C (mezclas, Pro, prueba) y bloque D (Siri, widgets, Live Activity si A) |
| 25–28 | Accesibilidad, diagnóstico, copy EN, capturas, Notes for Review |
| 29–30 | Beta cerrada en iPhone real (auriculares, interrupciones, Auto-Lock), envío |

Escenario B desplaza los bloques C y D y termina en la semana 44. La reserva del 30 % no está en esta tabla.

## 11. Decisiones del dueño (las únicas abiertas)

| # | Pregunta | Recomendación | Plazo |
|---|---|---|---|
| 1 | Acento Índice `#F0C020` u opción (b) | Índice, tras probar la página real sonando a oscuras | 27-11-2026 |
| 2 | Marca | SleepNoise | 04-12-2026 |
| 3 | Segunda pareja de ingenieros | Si no está confirmada el 14-12-2026, escenario B | 14-12-2026 |
| 4 | "Manto" en inglés | "Blanket" salvo veto en-US | Semana 6 |

Si un plazo pasa sin respuesta, se aplica la recomendación.

## 12. PR #3 y secuencia de PRs

**PR #3 (Cursor)**: pedir cambios y partir. **PR-A** (fusionable tras corregir los cinco puntos de la revisión): motor, modelo, once texturas con el trueno sin crack, App Intents y el modelo de Noche. **PR-B** (interfaz de baldosas, chips, resplandor, hoja "Niveles"): se descarta y se rehace desde las specs 05–07, conservando los tokens AA, los identificadores de accesibilidad y la pantalla de arranque. Detalle en la revisión del PR #3 y en FUNCIONES §5.

**Secuencia prevista**: (1) este plan y los documentos de `docs/` en `research/plan-sueno`; (2) PR-A; (3) primitivas; (4) un PR por bloque A–D, cada uno con su spec como criterio de aceptación; (5) ficha y capturas.

**Pendiente de este documento**: las specs 05, 07 y 09 no tienen aún aplicada la reconciliación (el equipo se detuvo a petición del dueño antes de terminar esa pasada; 05 y 09 pueden tener cambios parciales). Hasta que se aplique, en esas tres specs la reconciliación §2 manda donde difieran. No se hizo la revisión adversarial final de este plan con las cinco lentes previstas (dueño, ingeniero iOS, App Review, director creativo, analista de mercado).
