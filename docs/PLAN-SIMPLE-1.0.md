# SleepNoise 1.0 · Plan simplificado

Fecha: 16-11-2026 (rev. 2, con la Dirección de diseño 03). Sustituye, para la versión 1.0, al "Plan de desarrollo con agentes" del mismo día. Se mantienen sus reglas de calidad; lo que cambia es el alcance, el número de agentes y el calendario.

**Jurisdicciones:** este plan manda **qué y cuándo** en 1.0. `docs/design/03-DIRECCION-DE-DISENO` (Grafito) manda **cómo**: carácter, tokens, componentes, arquitectura de pantalla y copy. Si una superficie de 1.0 del documento 03 no aparece aquí, pasa a 1.1 sin rediseñarla.

Objetivo: publicar en la App Store una app de sonidos para dormir sencilla, estable y bonita **en 4 semanas** (envío a revisión como tarde el viernes 11-12-2026, antes del parón navideño de App Review). Todo lo demás va a 1.1 y 1.2, guiado por reseñas y ventas reales.

---

## 1. Qué se mantiene del plan de Claude

- **Nada entra en `main` sin compilar.** `scripts/verify.sh` en verde en el Mac y CI de GitHub Actions (macOS) como check obligatorio.
- **`main` protegida**, todo por PR.
- **Autor y revisor distintos.**
- **Un solo escritor a la vez en `SleepNoise/Audio/`.**
- El repo sigue público: nada de claves, datos personales ni rutas locales en commits, PR o issues.

## 2. Qué se simplifica

| Antes | Ahora |
|---|---|
| 4 agentes (Claude, Codex, Kimi, Cursor) | **2 agentes**: Claude Code (local, con Xcode) y Cursor (nube). Codex o Kimi solo como revisor ocasional si Claude se satura |
| 59 paquetes, 6 oleadas | **12 paquetes, 4 semanas** |
| 18 a 26 semanas (hitos de semana 30 o 44) | **4 semanas + revisión de Apple** |
| 12,5 a 21,5 días de trabajo del dueño | **3 a 4 días** del dueño |
| Beta de 7 noches con 30+ personas | TestFlight de **5 noches con 10 a 15 personas** (familia, amigos, equipo) |
| Noches de 10 h con Instruments en dos iOS | **Una noche completa** en el iPhone del dueño con el Mac midiendo energía |
| 4 decisiones con plazos escalonados | Decisiones cerradas en la semana 1 o 2; si no hay respuesta, se aplica la recomendación |
| Límite de 4 PR y reglas de turnos | Máximo **2 PR abiertos**: uno de Claude y uno de Cursor |

## 3. Reparto

- **Claude Code (local, Xcode).** Integrador único. Autor de todo lo que necesita compilar o sonar: audio, rescate del PR #3, interfaz, StoreKit, App Intents. Ejecuta `verify.sh` y fusiona.
- **Cursor (nube, sin Xcode).** Solo lógica pura en ficheros nuevos con tests que corren en la CI: temporizador y ventana de noche, códec de mezclas, políticas de interrupción y ruta, tests de texturas, textos de la ficha y documentación. Claude revisa con el log de la CI. Si un PR de Cursor falla dos veces, pasa a Claude.
- **Dueño.** Decisiones, firma, Connect, escucha, compra sandbox, una noche real, beta y envío.

## 4. Alcance 1.0 (cerrado)

### 4.1 Diseño: Grafito, sin recortes de carácter

Se construye con la Dirección de diseño 03 tal cual. Lo esencial para los agentes:
- **Solo modo oscuro en 1.0** (Papel en 1.1). Hojas en `hoja #1C1C1E` con `trazo-hoja`; nunca hojas negras sobre negro.
- **Una sola familia: SF Pro.** Nada de SF Pro Rounded, New York ni SF Mono (la interfaz del PR #3 se descarta).
- **Acento Índice `#F0C020`** (`índice-noche #BA941C`) bajo la ley "color = sonido": solo existe mientras suena o bajo el dedo, desaparece en 1,5 s al parar; un único elemento de color por pantalla; nunca relleno ni cuerpo de texto. Es un único token: si el dueño elige la alternativa, se cambia el token.
- **El Horizonte**: línea quieta a un tercio de la altura cuyo grosor y luz son el RMS real. Sin trazas temporales.
- **El Disco**: el Play como círculo `grafito` con relieve de 1 pt y `play.fill`; el único botón con volumen.
- **Filas = control** (arrastrar para nivel; el toque no silencia). Estado en palabras ("Sonando · sin trueno", "Se funde a las 03:42").
- Botón primario = **palabra entre dos hairlines de 64 pt**, sin relleno ni radio.
- **Movimiento**: nada cambia de posición, solo de longitud, opacidad o contenido.
- **De noche no se vende** (`NightWindow` 21:00–07:00): ni paywall, ni tips, ni reseñas.
- Fuera para siempre: candados, badges, cápsulas, degradados, sombras, luna y estrellas, iconos de sonido, y las palabras de la lista negra ("insomnio", "mejora el sueño", "IA", "vitalicio", "timer", "mix"…).

### 4.2 Producto (decisiones ya cerradas en el documento 03)

- **Precio: 29,99 € una vez**, sin precio de lanzamiento, un solo `displayPrice`. Pro con Family Sharing.
- **Prueba de 7 noches local**, iniciada desde la hoja Pro ("Empezar la prueba · 7 noches"), nunca con Play; estado en Keychain; se evalúa solo al arrancar una sesión. *Sustituye a la prueba de 7 días que arranca con el primer Play que hay hoy en `main`.*
- **Gratis siempre**: cinco texturas (blanco, rosa, marrón, lluvia, viento), **temporizador entero** y **3 mezclas guardadas**. **Pro**: océano, ventilador, trueno, hoguera, arroyo, cabina, Marea y mezclas ilimitadas. La lista gratis solo crece.
- **Mezclas de la casa** (no "presets"): "Rosa y lluvia", "Mar y viento", "Marrón y hoguera", "Pared". Nada de "Deep sleep" ni "Focus". Si llevan Pro, se cargan recortadas ("Mar y viento · sin Océano") y no abren paywall.
- Nombre de trabajo: **SleepNoise** (cierre legal 04-12-2026). Solo iPhone, iOS 17+.

### 4.3 Superficies que entran en 1.0 (números del inventario §5 del documento 03)

| # | Superficie | Nota de simplificación |
|---|---|---|
| 1-4 | Página principal: reposo, sonando, nocturna, noche 1/7/8, error, interrupción | Completa |
| 5 | Capas (mezclador) | Once texturas si pasan la escucha; sin fila "Timbre" (1.1) |
| 6 | Marea | Profundidad común + ritual + toggle (lo que ya existe en `bedDepth`) |
| 8 | Temporizador | Hasta dormirme y Manto (hora de fin); sin Siesta |
| 10 | Noche | Completa, con "+15 min" |
| 11 | Madrugada | Receta fija de 20 min, para todos. Se entra desde Noche terminada y desde Siri |
| 12-13 | Mezclas, guardar y renombrar | Formato v2, sin iCloud |
| 14-15, 33 | Hoja Pro, prueba y recibo | Completa |
| 16 | Primer uso | Sin onboarding, como dice el 03 |
| 18 | Ajustes | Lista mínima: Noche, Pintura (día: De día / Nunca, D-58), Háptica, Pro, Lo que no hay, Escribir al autor |
| 24 | Siri y Atajos | Cinco intents: `PlayLastMix`, `Pause`, `PlayMix`, `SetTimer`, `SmallHours` |
| 27 | Icono "La regla y la marea" | Completo |
| 28 | Seis capturas y titulares de C57, más una séptima: Mezclas de día con las bandas pintadas | Sin vídeo de vista previa (1.1). La séptima es la de la exploración 12 (D-57, 19-11-2026), sin segunda línea: la de reserva espera a una captura de la página pintada (C04) |
| 28 bis | Pigmento, camino A completo (exploración 12 §4.2 y §7; D-55 a D-58, 19-11-2026) | Las bandas pintadas de la casa en Mezclas (PNG generados en compilación, `scripts/paint/`); la ventana pintada de 240 pt alrededor del Horizonte en la página de día, generada en el iPhone y que respira con el RMS real y la Marea (`SleepNoise/Design/Paint/`, `PaintWindow`); las reglas de 4 pt en Capas; el ajuste "Pintura: de día / nunca"; y MetricKit al diagnóstico local. Una sola regla de día y noche (`PaintPolicy`): nada de 21:00 a 07:00, en la página nocturna, en Noche, en Madrugada, con `isLuminanceReduced` ni con Aumentar contraste. Nada en el icono ni en la hoja Pro. Condición de envío: la medida de batería con MetricKit de 20:00 a 21:00 y la prueba de cinco segundos (`PRUEBAS-EN-DISPOSITIVO.md` §11); ninguna cifra de batería se publica hasta medirla |
| 32 | Lo que no hay | Página de texto corta |
| 34 | Now Playing | Completo |

### 4.4 Pasa a 1.1 o después

Live Activity, Dynamic Island y StandBy (escenario B: decisión 3 resuelta), widgets, Centro de control y botón de Acción, "Qué sabemos y qué no", "Cómo se genera", diagnóstico y "Enviar informe", Timbre, Papel, Siesta, Focus, iCloud, Watch (1.2), iPad, y todo lo que el documento 03 ya marca como 1.1 o 1.2. Las specs 05, 07 y 09 no se reconcilian para 1.0.

## 5. Paquetes

| Id | Paquete | Autor | Revisor | Semana |
|---|---|---|---|---|
| S-01 | `scripts/verify.sh`, CI macOS como check obligatorio, `AGENTS.md` corto (<8 KiB), proteger `main`, solo iPhone | Claude | Cursor (lectura) | 1 |
| S-02 | Rescate del PR #3: traer motor, texturas, modelo e intents a una rama nueva, corregir los errores de compilación (metadatos de App Intents, `inclusiveRange`), cerrar el PR #3 | Claude | Cursor (CI) | 1 |
| S-03 | Lógica pura con tests: `NightWindow`, nuevo `AccessPolicy` (5 gratis, 6 Pro, 3 mezclas), reloj de prueba de 7 noches (Keychain detrás de un protocolo), receta de Madrugada | Cursor | Claude | 1 |
| S-04 | Tokens Grafito (§3 del 03), Horizonte, Disco, filas-control, página principal y Capas | Claude | Cursor (CI) | 2 |
| S-05 | Códec de mezclas v2 y mezclas de la casa con tests; políticas de interrupción (ventana de la mañana) y de ruta (nunca reanudar sola por el altavoz) con tests de tabla | Cursor | Claude | 2 |
| S-06 | Noche, Madrugada, Temporizador, Marea y Mezclas en la interfaz Grafito | Claude | Cursor (CI) | 2-3 |
| S-07 | Hoja Pro "Una vez.", prueba de 7 noches, recibo y estados de la tienda; StoreKit sandbox | Claude | Cursor (CI) | 3 |
| S-08 | Catálogo de cadenas EN/ES completo, test de interfaz que genera las capturas por idioma | Claude | Cursor (CI) | 3 |
| S-09 | Ficha de App Store EN/ES con los titulares de C57 y la lista negra de palabras, notas para revisión, página "Lo que no hay" y política de privacidad en GitHub Pages | Cursor | Claude + dueño | 3 |
| S-10 | Icono "La regla y la marea" (cuatro apariencias, prueba a 29 pt) | Claude o diseñador | Dueño | 3 |
| S-11 | Correcciones de la beta | Claude | Cursor (CI) | 4 |
| S-12 | Build de lanzamiento y envío | Claude + dueño | Dueño | 4 |

## 6. Trabajo del dueño (3 a 4 días en total)

| Cuándo | Qué | Tiempo |
|---|---|---|
| Martes 17-11 | Proteger `main`, confirmar plan de Cursor, iniciar sesión en Xcode y pasar el Team ID a Claude (fichero local sin versionar) | 1 h |
| Semana 1 | Crear la app y el producto Pro en App Store Connect (non-consumable, Family Sharing), firmar el Paid Apps Agreement y los datos bancarios y fiscales, apuntarse al Small Business Program (comisión del 15 %) | 2 h |
| Final semana 1 | Escucha de las texturas en el iPhone con auriculares: sí o no por textura | 1 h |
| Viernes 27-11 | Decisión del acento (recomendado: Índice `#F0C020`) | 5 min |
| Semana 2 | Una noche completa con la app en el iPhone | 1 noche |
| Semana 3 | Compra sandbox (comprar, restaurar, prueba caducada) | 1 h |
| Viernes 04-12 | Nombre definitivo (recomendado: SleepNoise). El precio ya está cerrado en 29,99 € | 15 min |
| Semana 4 | TestFlight con 10 a 15 personas, 5 noches; recoger comentarios | 2 h de gestión |
| Viernes 11-12 | Enviar a revisión | 1 h |

Si un plazo pasa sin respuesta, se aplica la recomendación. "Manto" en inglés se queda en "Blanket".

## 7. Calendario

| Semana | Fechas | Resultado |
|---|---|---|
| 1 | 17-11 al 22-11 | CI como puerta, PR #3 rescatado y compilando en `main`, escucha hecha |
| 2 | 23-11 al 29-11 | Tokens Grafito, página principal, Capas y Noche en `main`; acento decidido |
| 3 | 30-11 al 06-12 | Madrugada, Temporizador, Marea, Mezclas, hoja Pro y prueba de 7 noches; sandbox probado; cadenas, capturas, ficha, icono y nombre |
| 4 | 07-12 al 11-12 | Beta, correcciones y envío a revisión |
| Después | 14-12 en adelante | Respuesta de Apple. Lanzamiento antes de Navidad si se aprueba a la primera |

Si en la semana 2 se va más de 3 días tarde, se recorta en este orden, sin tocar el carácter de Grafito: texturas que no hayan pasado la escucha, Manto (queda solo "Hasta dormirme"), intents `PlayMix` y `SmallHours`, y como último recurso el envío pasa al 18-12-2026.

## 8. Definición de hecho para cada PR

1. `scripts/verify.sh` en verde en el Mac y CI en verde.
2. Sin avisos nuevos de compilación ni de metadatos de App Intents.
3. Cadenas nuevas en EN y ES.
4. Sin red, sin analítica, sin afirmaciones médicas y sin palabras de la lista negra (lint de copy).
5. Respeta el documento 03: un solo acento, SF Pro, sin candados ni degradados, y nada de venta entre 21:00 y 07:00.
6. Revisado por el otro agente y fusionado por Claude.

## 9. Hoja de ruta después del lanzamiento

- **1.1 (3 a 5 semanas después):** Live Activity, StandBy y Dynamic Island; widget "Dormir"; Centro de control; Papel (modo claro); Timbre; "Qué sabemos" y "Cómo se genera"; diagnóstico; iCloud; de Pigmento, solo la brasa nocturna de la hoguera como experimento apagado por defecto (exploración 12 §9 n.º 7): la ventana, las reglas de Capas y el ajuste "Pintura" entraron en 1.0 (D-58).
- **1.2:** Apple Watch, HealthKit, iPad si las ventas lo justifican.
- Cada actualización se decide con datos reales: descargas, conversión de prueba a Pro y reseñas.

## 10. Ajustes de ejecución (16-11-2026)

Notas del integrador al arrancar la semana 1. No cambian el texto de las secciones 1 a 9.

### Aplicados (no cambian el alcance)

- **S-03 se hace en dos mitades.** Mitad A: solo ficheros nuevos (`NightWindow`, el reloj de la prueba de 7 noches y la receta de Madrugada) con sus tests en ficheros nuevos; puede empezar en cuanto S-01 esté en `main`. Mitad B: cuando S-02 esté en `main`, los ficheros compartidos de política de acceso (`AccessPolicy.swift`) y sus tests. Brief: `docs/briefs/S-03.md`.
- **El trabajo de audio escondido se hace explícito.** S-04 incluye publicar el nivel RMS desde el hilo de audio para el Horizonte. S-06 incluye la ganancia maestra con rampa para Manto y para el eje vertical de Noche. Siempre con un solo escritor en `SleepNoise/Audio/`.

### Propuestos, pendientes del sí del dueño (no se aplican hasta entonces)

- Adelantar al martes 17-11 dos tareas del dueño que §6 pone en la semana 1: crear la ficha en App Store Connect, para comprobar que el nombre está libre, y el acuerdo de apps de pago, con banco y fiscalidad.
- En la escucha de texturas, empezar por el viento, porque es textura gratuita, en cuanto S-02 compile (hoy el viento no está en `main`).
- Accesibilidad con VoiceOver en la definición de hecho (§8).
- Reconciliar las specs 05 y 07 antes de S-04.
- Fijar una segunda fecha de envío: 18-12-2026 o 04-01-2027.
- Un segundo lector, en modo solo lectura, para los PR de audio y de StoreKit.
- Dejar preparada la alternativa de producto gratuito para la prueba, por si App Review la pide.
