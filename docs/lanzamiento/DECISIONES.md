# Decisiones abiertas del dueño · SleepNoise 1.0

Fecha: 17-11-2026. Una sola lista, sin duplicados, de todo lo que sigue esperando una respuesta tuya. Sale de tres sitios:

- `docs/agents/ESTADO.md` tal como está en la rama de S-08 (commit `80ebd1b`): lo que cada paquete dejó "a confirmar", "aplazado" o "necesita al dueño".
- `docs/PLAN-SIMPLE-1.0.md` §6 (tu trabajo) y §10 (propuestas pendientes de tu sí).
- `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` §6, y la tabla "Lo que el dueño debe rellenar o decidir" de `docs/store/README.md`.

Cómo leerla:

- **Recomendación.** Si viene de los documentos, lleva *(fuente)*. Si los documentos no recomendaban nada y la propone esta guía, lleva *(guía)*: es una opinión, no una decisión tomada.
- **Si no decides.** La regla del plan es que, pasado el plazo, se aplica la recomendación. Donde eso no vale porque el dato solo lo tienes tú, lo dice.
- **Fichero que cambia.** Dónde se escribe la decisión. Los cambios de código los hace Claude por PR.
- Para responder basta con el identificador y una palabra: "D-08: a".

Recuento: 13 condiciones de envío, 3 con fecha, 7 de ficha, 17 de producto e interfaz, 8 de proceso, 6 surgidas al escribir esta guía y un bloque de 36 confirmaciones. De ellas, tres están cerradas desde el 17-11-2026 y siguen en su fila para no perder el hilo: D-08 (condición de envío), D-32 y D-52 (producto e interfaz). Los identificadores no se renumeran: lo añadido en la corrección de esta guía lleva los números siguientes (D-51 a D-54, C-25 a C-36) y está en el apartado que le toca.

---

## 1. Con fecha en el plan

| Id | Decisión | Recomendación | Si no decides | Fichero que cambia |
|---|---|---|---|---|
| D-01 | **Acento.** Índice `#F0C020` o la alternativa. Plazo: viernes 27-11-2026 | Índice, tras mirarlo cinco segundos con la página sonando, en un iPhone, en la mesilla y a oscuras *(fuente: reconciliación §6 n.º 1)* | Se queda Índice | `SleepNoise/Design/Ink.swift` (un solo token y su variante nocturna); icono si cambiara |
| D-02 | **Nombre definitivo.** Plazo: viernes 04-12-2026. Si al crear la ficha el nombre está ocupado, esta decisión se adelanta a ese día | SleepNoise *(fuente: reconciliación §6 n.º 2)* | Se queda SleepNoise. Si está ocupado en la tienda no hay respuesta por defecto: hace falta un nombre tuyo | `SleepNoise/Resources/Info.plist` (nombre visible), cadena `app.name`, `docs/store/ficha-*.md`, `docs/store/compra-integrada.md`, `docs/privacy/index.md`, `SleepNoise.storekit` |
| D-03 | **Segunda fecha de envío** si no se llega al 11-12-2026: 18-12-2026 o 04-01-2027 | 18-12-2026 como segunda y 04-01-2027 como tercera *(fuente: plan §7 nombra el 18-12 como último recurso; §10 propone fijarla)* | Vale el 18-12-2026 | `docs/PLAN-SIMPLE-1.0.md` §7 |

## 2. Condiciones de envío

Sin cerrar estas, no se envía a revisión.

| Id | Decisión | Recomendación | Si no decides | Fichero que cambia |
|---|---|---|---|---|
| D-04 | **Qué texturas entran**: sí, no o retocar para cada una de las once, tras `ESCUCHA.md` | La que no pase no entra en 1.0 *(fuente: plan §4.3 fila 5 y §7)* | No hay respuesta por defecto: nadie más la ha oído en un iPhone. Sin escucha, la ficha afirma cosas sin comprobar | `SleepNoise/Model/SoundID.swift` y la hoja Capas; `pro.incluye.texturas.detalle`; `SleepNoise/Model/HouseMix.swift` si cae océano u hoguera; fichas, notas de revisión, nota de la compra y captura 3 |
| D-05 | **Tres datos de la política de privacidad**: dirección de contacto, quién responde y plazo de borrado de correos | Una dirección creada para la app; el plazo, uno que vayas a cumplir *(fuente: `docs/store/README.md`)* | No hay respuesta por defecto. Sin ellos no se activa Pages ni hay URL de privacidad | `docs/privacy/index.md` |
| D-06 | **La política, dentro de la app.** La directriz 5.1.1(i) la pide en la ficha y también en la app. Las notas de revisión dicen que se lee en Ajustes, "Lo que no hay", pero hoy esa página solo lleva la lista de ausencias | Poner el texto corto de la política en "Lo que no hay", mejor que un enlace, que saca de la app y necesita red *(fuente: `docs/store/README.md`, "Antes de enviar")* | Las notas afirman algo falso y el envío queda expuesto a un rechazo por 5.1.1 | `SleepNoise/Features/Settings/`, `Localizable.xcstrings`, guía de copy, `docs/store/notas-revision.md` |
| D-07 | **`AppLinks`**: identificador numérico de la app y dirección pública de contacto | Rellenar los dos antes del build de la beta *(fuente: ESTADO, S-07)* | La 1.0 sale sin "Escribir una reseña" ni "Escribir al autor", y nada avisa | `SleepNoise/Features/Pro/ProSheetLogic.swift` |
| D-08 | **Cerrada el 17-11-2026: (a).** **Restaurar de noche.** De 21:00 a 07:00, en la página nocturna y en Madrugada no había forma de llegar a "Restaurar compra". Hecho: sin Pro y mientras no se puede vender, Ajustes tiene bajo "pro" una fila "Restaurar compra", sin precio y sin entrada a la hoja. Ejecuta la restauración de verdad, dice "Buscando…" en su sitio y deja debajo una línea con el resultado (gracias, no hay compra, no se ha podido completar o la tienda no responde). De día todo sigue igual. No hay cadenas nuevas | Aplicada la recomendación (a) | Ya no aplica | `SleepNoise/Features/Settings/SettingsLogic.swift` (`SettingsRestoreRow`) y `SettingsSheet.swift`, `SettingsTests`, `docs/store/notas-revision.md`. Falta verlo en el sandbox (`PRUEBAS-EN-DISPOSITIVO.md`, 8.A pasos 18 a 20 y 8.B paso 5b) |
| D-09 | **La nota bajo "Empezar la prueba · 7 noches"** ¿nombra lo que deja de estar disponible al acabar? Hoy dice la duración y lo que sigue gratis | Sí, nombrarlo *(fuente: `docs/store/notas-revision.md`, "Riesgo 3.1.1")* | Las notas afirman que la hoja lo dice y el revisor tiene que deducirlo de dos listas: riesgo de rechazo por 3.1.1 | Cadena `pro.prueba.empezar.nota`, guía de copy §2.8, hoja Pro (la nota ocupa una altura reservada) |
| D-10 | **Alternativa de producto gratuito para la prueba**, por si App Review la pide | Dejarla preparada sobre el papel: comprobar en App Store Connect si admite precio cero en un no consumible, tener redactada la respuesta y el encargo. No construirla hasta que Apple la pida *(fuente: plan §10 propone prepararla; el alcance "sobre el papel" es de la guía)* | Nada preparado: un rechazo por 3.1.1 cuesta más días | `docs/PLAN-SIMPLE-1.0.md` §10; si se construye, `SleepNoise/StoreKit/`, `NightTrial`, notas y política |
| D-11 | **"Nunca se repite" / "never loops"** en la ficha. Hoy no se sostiene: el generador repite su secuencia cada 24 h 51 min y cada arranque empieza igual. (a) Cambio de audio con semilla por arranque, estado de 64 bits y test de autocorrelación. (b) Textos de reserva: "sin archivos de audio ni bucles" | (b) para 1.0 y (a) para una versión posterior *(fuente: `docs/store/README.md` da (b) como caída; elegirla ya es de la guía)*. De paso, revisar `capas.nota`, que en español dice "Nada se repite." dentro de la app | Valen los textos de reserva | `docs/store/ficha-*.md`; `capas.nota`; si (a), `SleepNoise/Audio/DSP/` con su único escritor |
| D-12 | **Atajos con el iPhone bloqueado.** Cuatro de los cinco Atajos abren la app al ejecutarse. Cambiarlo (`AudioPlaybackIntent`, `openAppWhenRun = false`) no se hace sin probarlo en un iPhone real | Probar primero (`PRUEBAS-EN-DISPOSITIVO.md` §6) y cambiar solo si suena con el iPhone bloqueado *(fuente: ESTADO, corrección de S-06, "condición de publicación")* | Se quedan como están: funcionan, pero por voz con el iPhone bloqueado pueden pedir el código | `SleepNoise/Intents/SleepIntents.swift` |
| D-13 | **Compra real en sandbox**: comprar, restaurar, pendiente de aprobación, reembolso y En familia. Nada de eso se ha ejecutado contra StoreKit | Hacer `PRUEBAS-EN-DISPOSITIVO.md` §8 antes de la beta *(fuente: ESTADO, S-07, "sin verificar")* | No hay respuesta por defecto: es una prueba, no una opinión | Ninguno si pasa; `SleepNoise/StoreKit/` si falla |
| D-14 | **Una noche entera** en tu iPhone, con medida de energía | Hacer `PRUEBAS-EN-DISPOSITIVO.md` §1 en la semana 2 *(fuente: plan §2 y §6)* | No hay respuesta por defecto | Ninguno si pasa |
| D-15 | **Recorrido con VoiceOver real.** Etiquetas, valores y foco están puestos y probados por lógica; nadie ha recorrido las pantallas con VoiceOver encendido | Un recorrido de 30 minutos antes de la beta *(fuente: ESTADO, "sin verificar" de S-06 y S-07)* | Se envía sin haberlo oído | Vistas y cadenas `ax.*` si falla |
| D-51 | **China continental.** La app enlaza `CallKit` (`CXCallObserver`, para distinguir una llamada de cualquier otra interrupción), y ESTADO pide comprobar, antes de publicar allí, si esa tienda sigue rechazando las apps que lo enlazan | Dejar China continental fuera de los países de la 1.0 y añadirla cuando esté comprobado *(fuente: ESTADO, S-06 tarea 1, pide la comprobación; excluirla mientras tanto es de la guía)* | No hay respuesta por defecto: marcar todos los países sin comprobarlo expone el envío a un rechazo o a una retirada en esa tienda | Solo App Store Connect (`GUIA.md` §9); `SleepNoise/Audio/AudioSessionObserver.swift` si hubiera que quitar `CallKit` |

## 3. Ficha de la tienda

| Id | Decisión | Recomendación | Si no decides | Fichero que cambia |
|---|---|---|---|---|
| D-16 | **Palabras clave**: opción A (con dos palabras de diagnóstico) u opción B (sin ellas). De paso, resolver la contradicción entre `AGENTS.md` §5.4 y la guía de copy sobre si caben en ese campo | B *(fuente: `docs/store/ficha-es.md`)* | Vale la B | `docs/store/ficha-*.md`; guía de copy §0.4 si se aclara la regla |
| D-17 | **Subtítulo inglés "Pay once." y captura 1 con "Un solo pago." y "sin tarjeta"**, o los textos de reserva. La directriz 2.3.7 no quiere precios ni condiciones en nombre, subtítulo y capturas | Mantener y tener la reserva lista para un rechazo *(fuente: `docs/store/README.md`)* | Se quedan los de la guía y C57 | `docs/store/ficha-en.md`, `ficha-es.md` |
| D-18 | **Enmienda del tercer párrafo de la descripción**, que dice qué añade Pro (directriz 2.3.2) | Aceptarla: las capturas 3 y 4 enseñan cosas de Pro *(guía)* | Se queda el texto de la guía de copy, sin la enmienda | `docs/store/ficha-*.md` y guía de copy §5e.15 |
| D-19 | **URL de soporte**: la misma página de privacidad o la página de incidencias del repositorio | La de privacidad, que lleva el contacto *(fuente: `docs/store/README.md`)* | La de privacidad | Solo App Store Connect |
| D-20 | **Capturas de la página**: escenificadas con Pro comprado (cabecera vacía, todo abierto) o como una instalación nueva, donde la Marea se lee "pro" | Instalación nueva para la captura 2, "el primer uso", que es lo que la persona verá *(guía; ESTADO lo deja "a revisar en S-08")*. S-08, en curso, ya la hace así en su copia de trabajo (`02-first-use` con el estado `restFree`): falta tu sí | Se queda como S-08 la deje: la captura 2 como instalación nueva, con la Marea en "Apagada · pro" | `scripts/screenshots.sh` (S-08) |
| D-21 | **Abrir también la ficha "Spanish (Mexico)"** | No en 1.0: la app lleva una sola localización `es` *(guía)* | No se abre | `docs/store/ficha-es.md`, apartado final |
| D-22 | **Vídeo de vista previa** | Fuera de 1.0 *(fuente: plan §4.3 fila 28)* | Fuera | Ninguno |

## 4. Producto e interfaz

Salvo que se diga otra cosa, ninguna bloquea el envío.

| Id | Decisión | Recomendación | Si no decides | Fichero que cambia |
|---|---|---|---|---|
| D-23 | **Cifra de "quedan n noches".** Hoy cuenta las noches que empiezan (21:00) antes del fin, con tope 7; el día en que la prueba se agota la cifra es 0 y la cabecera no enseña nada, porque no hay cadena aprobada para "termina hoy" | Confirmar el recuento como está *(fuente: ESTADO, S-07 tarea 1)* | Se queda | `SleepNoise/Model/NightTrial.swift`; una cadena nueva si quieres "termina hoy" |
| D-24 | **"Gratis siempre" en la cabecera**: hoy solo tras la prueba, siete sesiones. La spec 08 §2.4 la pone también en una instalación nueva | Dejarlo como está, para no cambiar la primera pantalla *(guía; ESTADO: "a decidir")* | Se queda | `SleepNoise/Features/Page/PageLogic.swift` |
| D-25 | **Atrasar el reloj del iPhone antes de abrir la app alarga la prueba.** Cerrarlo pide guardar el reloj continuo del sistema, y eso toca el manifiesto de privacidad | Aceptarlo en 1.0 y revisarlo después *(guía)* | Se queda abierto | `SleepNoise/Model/NightTrial.swift`, `PrivacyInfo.xcprivacy` |
| D-26 | **Nombre antes de que la tienda responda**: la palabra "Pro" en el título de la hoja y en la fila de Ajustes, o el título vacío | "Pro", como está construido *(fuente: ESTADO, S-07 tarea 3; falta tu sí)* | Se queda "Pro" | `SleepNoise/Features/Pro/ProSheetLogic.swift` |
| D-27 | **Texto de compra pendiente.** `pro.pendiente` dice "Pendiente de aprobación familiar…", pero el mismo estado llega con la autenticación reforzada del banco | "Pendiente de aprobación. Se abrirá solo cuando llegue." / "Waiting for approval. It will open on its own." *(fuente: ESTADO, S-07 tarea 3)* | Se queda el texto actual, que a veces no será cierto | `Localizable.xcstrings`, guía de copy §5e.10 |
| D-28 | **Háptica fuera de Ajustes.** El plan §4.3 la lista; no se construyó porque no hay nada que ajustar | Sí, y anotarlo en el plan *(fuente: ESTADO, S-07)* | Se queda fuera, con el plan diciendo otra cosa | `docs/PLAN-SIMPLE-1.0.md` §4.3 |
| D-29 | **El recibo y Ajustes no tienen control de cierre** (no hay cadena de cierre en el catálogo) | Aceptarlo en 1.0 si en tu iPhone el gesto de bajar la hoja resulta evidente *(guía)* | Se queda | `SleepNoise/Features/Pro/`, `Settings/`, una cadena nueva |
| D-30 | **"Lo que no hay" usa el botón de volver del sistema**: en iOS 26 es un círculo, lo único redondo de la hoja. Alternativa: una acción de texto "Ajustes" | Mirarlo en tu iPhone y en uno con iOS 17 o 18; si molesta, la alternativa *(guía)* | Se queda el del sistema | `SleepNoise/Features/Settings/SettingsSheet.swift` |
| D-31 | **Fondo de Capas de noche.** Sobre `hoja` (`#1C1C1E`) enciende la pantalla; el plan §4.1 prohíbe hojas negras sobre negro. ¿Capas sobre negro solo de noche? | Decidirlo el mismo día que el acento, a oscuras, con la página nocturna real *(guía)* | Se queda `hoja` | `SleepNoise/Features/Page/LayersSheet.swift` (es un argumento) |
| D-32 | **Cerrada el 17-11-2026: la recomendación.** **Tope de seis capas, una sola regla.** Se podía pasar de seis recuperando el acceso con capas Pro guardadas a nivel, o cargando una mezcla guardada con más de seis. Hecho: una regla sin memoria (`LayerCap`), aplicada donde se calculan las ganancias: suenan las seis capas incluidas de nivel más alto y las demás conservan su nivel sin sonar, sea cual sea el camino (mezcla guardada o de la casa, Atajo, niveles de una versión anterior, acceso recuperado, fin de la prueba). Nada guardado se reescribe. Con niveles iguales suena la que va antes en el orden de `SoundID` (blanco, rosa, marrón, lluvia, ventilador, océano, trueno, hoguera, arroyo, viento, cabina). La fila que espera va en tinta secundaria, sin tinta en su línea y con "Seis a la vez" debajo mientras espera; al bajar a cero una de las seis entra la siguiente por nivel. La séptima desde cero sigue sin añadirse | Aplicada | Ya no aplica | `SleepNoise/Model/LayerCap.swift`, `MixerModel.swift`, `LayerRow.swift`, `LevelRule.swift`, `LayerCapTests`. El desempate es decisión de Claude: a revisar si prefieres otro orden |
| D-33 | **Tocar "Noche" con la noche ya terminada** y dentro de las horas nocturnas: ¿abre Noche terminada, con "Madrugada · 20 min", en vez de arrancar la mezcla? Hoy Madrugada solo se alcanza con el dedo si Noche ya cubría la página al acabar | Decidir tras la noche real: si a las tres de la mañana no encuentras Madrugada, sí *(guía)* | Se queda como está; Madrugada sigue disponible por Atajo | `SleepNoise/Features/Mixer/MixerModel.swift` |
| D-34 | **Dos contradicciones de la guía de copy**: el inglés "Until I sleep" está en su propia lista negra inglesa, y "y n más" tiene dos pasos tipográficos distintos | Quitar "until I sleep" de la lista negra, porque es el nombre aprobado del modo; dejar "y n más" en el paso 9, como está *(guía; ESTADO pide cerrarlo antes del lint de S-08)*. S-08, en curso, ya aplica lo primero en su copia de trabajo: falta tu sí | Se queda como S-08 lo deje | `docs/design/10-GUIA-DE-COPY.md` §0.5 |
| D-35 | **"Se retira" sin cifra** en los últimos 5 minutos de Madrugada. C05 y C60 fijaban "Se retira · n min"; se quitó la cifra porque la de 72 pt de encima ya la dice | Mantenerlo *(fuente: ESTADO, ajuste final de S-06)* | Se queda | Una cadena si prefieres la letra de C05 |
| D-36 | **Audio aplazado sin paquete.** (a) Arrastrar el nivel en Noche durante el minuto en que el Manto baja termina esa bajada en 50 ms. (b) El paso de la mezcla a Madrugada cruza en 20 ms, sin fundido cruzado | Escucharlo en `ESCUCHA.md` §6, §7 y §9; corregir en 1.0 solo lo que se oiga *(guía)* | Pasa a 1.0.1 | `SleepNoise/Audio/` (un campo nuevo en `EngineCommand`) |
| D-37 | **La compra o la prueba "que se oyen"**: al comprar o empezar la prueba, la capa entra con el suavizado normal y no con el fundido de 800 ms de la spec 08 §2.3 | Dejarlo para después de 1.0 *(guía)* | Se queda | `SleepNoise/Audio/` |
| D-38 | **Hoguera: "brasas, sin chasquidos".** La línea de uso promete que no hay chasquidos y la textura lleva unos pocos | Decidir en la escucha: o se retoca el sonido o se cambia la línea *(guía)* | Se queda la contradicción a la vista de quien escuche | `SleepNoise/Audio/DSP/CampfireTexture.swift` o la cadena `capas.campfire.detalle` |
| D-52 | **Cerrada el 17-11-2026: se funde sola a la página de día.** **Noche terminada, por la mañana.** La mañana nunca quitaba la pantalla Noche: quien abría la app a las 08:00 con Noche delante veía "Terminó a las 23:45" y "Madrugada · 20 min". Hecho, como pedía la spec 07 (S5): fuera de la ventana de noche, Noche con la noche ya terminada cede sola a la página de día, sin sonido y sin abrir ni vender nada. Ocurre al abrir la app, al llegar las 07:00 con la app abierta y cuando una noche termina sola ya de día. De noche sigue como estaba, con "Terminó a las…" y la entrada a Madrugada. Una noche que sigue sonando, o en pausa dentro de sus veinte minutos, no se toca a ninguna hora. Madrugada tampoco | Aplicada sin esperar a la noche real: el paso 9 de `PRUEBAS-EN-DISPOSITIVO.md` §1.A queda como comprobación | Ya no aplica | `SleepNoise/Features/Mixer/MixerModel.swift` (`leaveNightScreenIfOverByDay`), `MixerSessionTests` (`testTheNightPageStaysWhileItsNightIsAlive` adaptado y tres tests nuevos) |

## 5. Confirmaciones en bloque

Decisiones que el integrador tomó al construir y marcó "a confirmar". Ninguna necesita respuesta: **si no dices nada, se quedan como están**. Léelas una vez con la app delante y marca solo la que quieras cambiar. De la C-25 en adelante son las de las tareas 1 a 4 de S-06. No se repiten aquí las que ESTADO ya da por corregidas ni las que solo dicen que una cifra sale del código.

| Id | Qué se hizo | Dónde |
|---|---|---|
| C-01 | Capas va sobre `hoja` y su relieve es `negro` | `LayersSheet.swift` |
| C-02 | La barra inferior es "Mezclas", el Disco y "Noche"; Marea y Temporizador son filas de la página | `PageBar.swift` |
| C-03 | La línea de estado elige en este orden: fundiendo, capa por defecto, hora del temporizador, "sin {capa}", "Sonando" | `PageLogic.swift` |
| C-04 | "y N más" cuenta también las capas Pro que conservan nivel | `PageLogic.swift` |
| C-05 | Versalitas con cifras a la altura de la versalita | `TypeStep.swift` |
| C-06 | Play con la mezcla en silencio sube rosa a 40; los Atajos y las filas de Mezclas hacen lo mismo | `MixerModel.swift` |
| C-07 | La noche es la sesión de audio: va del Play hasta que acaba sola. No se guarda tras un reinicio. La página nocturna dura hasta que tocas el nombre o abres la app de día | `MixerModel.swift` |
| C-08 | En la página nocturna, VoiceOver lee una fila Pro como cualquier otra, sin "requiere Pro" | Guía de copy §3 |
| C-09 | "Auriculares" solo cuando lo dice el sistema; Bluetooth cuenta como auriculares; AirPlay, coche y cable son "En pausa" a secas | `RoutePolicy.swift` |
| C-10 | La línea de agua de la página no se dibuja con tamaños de texto de accesibilidad; la palabra "inhala / exhala" no está en la página | `PageView.swift` |
| C-11 | El título recortado ("Mar y viento · sin Océano") baja hasta 0,7 de escala antes de quedarse en el nombre a secas | `PageView.swift` |
| C-12 | La cabecera del Temporizador no aparece al elegir un modo con la hoja abierta | `TimerSheet.swift` |
| C-13 | Una línea puede empezar por punto medio (recetas, estados de Noche) | `LineTies.swift` |
| C-14 | Fila Pro de Ajustes, de noche: palabras, sin precio y sin toque | `SettingsLogic.swift` |
| C-15 | "En familia" se lista salvo que el producto cargado diga que no se comparte | `ProSheetLogic.swift` |
| C-16 | "Lo que no hay" sin el párrafo del diagnóstico, sin fila de versión y sin pie | `SettingsSheet.swift` |
| C-17 | En la hoja Pro de una instalación nueva, la nota de la prueba ocupa el sitio del pie "Sin suscripción. Sin cuenta. Sin rastreo." | `ProSheet.swift` |
| C-18 | Una compra empezada antes de las 21:00 se termina aunque den las 21:00; restaurar no pasa por la puerta nocturna | `MixerModel.swift` |
| C-19 | El texto del pie fijo de la hoja Pro no crece más allá de AX3 | `ProSheet.swift` |
| C-20 | El recibo no comparte cotas entre idiomas; en 375 × 667 el pie corta la lista a media altura | `ProSheet.swift` |
| C-21 | De la hoja Pro abierta desde Ajustes se vuelve a Ajustes; desde Marea y Mezclas, a la página | `PageView.swift` |
| C-22 | La nota "La prueba terminó" se va con "Entendido" o con el siguiente Play de día; la tercera salida de la spec no está | `PageLogic.swift` |
| C-23 | Una revocación (reembolso, salida de En familia) con el sonido puesto espera a que pare | `PurchaseManager.swift` |
| C-24 | Rechazado en la revisión y no hecho: "Volver a la página" primero en VoiceOver, una pista para "Noche" con la mezcla parada, "desplegado / plegado" en la fila Duración y la tinta del valor central de las ruedas | ESTADO, corrección de S-06 |
| C-25 | El fundido final de "Hasta dormirme" dura un cuarto de la duración, con techo de 15 minutos: 10 minutos a los 40, 15 desde una hora | `TimerChoice.swift` |
| C-26 | La bajada del Manto (6 dB a los 45 minutos) se hace en un minuto de rampa | `SleepTimerController.swift` |
| C-27 | "+15 min" en Manto suma a la hora de fin de esa noche, sin tocar la hora elegida | `SleepTimerController.swift` |
| C-28 | El nivel de la noche tiene un suelo de 0,05: el arrastre en Noche baja el sonido, no lo apaga | `MixerModel.swift` |
| C-29 | Una interrupción que el sistema nunca da por acabada se cierra al volver la app a primer plano, salvo que haya una llamada en curso u otra app sonando | `MixerModel.swift` |
| C-30 | Temporizador y Marea, abiertas desde la página nocturna, toman la tinta única y siguen sobre `hoja`, como Capas (va con D-31) | `TimerSheet.swift`, `TideSheet.swift` |
| C-31 | En el Temporizador la línea bajo la cifra repite la cifra ("8 min" y "Fundiendo · 8 min"), y "Apagado" deja vacío su hueco de control: evitarlo pide cadenas que la guía de copy no tiene | `TimerSheetLogic.swift` |
| C-32 | Marea: el menú Ritmo ofrece los dos nombres y, si lo arrastraste a otro, ese valor; encendida sin sonar, la caja de estado queda vacía; "Toda la noche" ya no se ofrece y un ajuste guardado así se lee como 30 minutos | `TideSheetLogic.swift` |
| C-33 | Noche: la entrada sola al bloquear ocurre solo de 21:00 a 07:00, sonando y sin hoja delante; la pulsación larga no vibra; las dos frases de la primera vez duran 4 s y no salen desde AX3; la cifra de Madrugada va a 72 pt | `NightScreen.swift`, `NightLogic.swift` |
| C-34 | Mezclas es una hoja, como Capas; la fila "Esta noche" guarda al tocarla; el campo de guardar llega con el nombre automático y no se evita repetir un nombre; dos capas de Pro en una receta se dicen una a una | `MixesSheet.swift`, `MixesLogic.swift` |
| C-35 | El Atajo del temporizador guarda el modo, como la hoja, y ya no vale "solo por esta noche"; "Apagado" no arranca el sonido; el Atajo de una capa sola se retiró | `SleepIntents.swift` |
| C-36 | Cadenas que no están en la guía de copy y que nadie ha aprobado: `noche.estado.termino` ("Terminó a las…"), `ax.noche.pista.reanudar`, `ax.madrugada.pista.reanudar`, `mezcla.guardar.titulo` y las `atajo.*` | `Localizable.xcstrings`; guía de copy §5e si las apruebas |

## 6. Proceso

| Id | Decisión | Recomendación | Si no decides | Fichero que cambia |
|---|---|---|---|---|
| D-39 | **Adelantar al primer día** crear la ficha (para saber si el nombre está libre) y firmar el acuerdo de apps de pago con banco y fiscalidad | Sí *(fuente: plan §10)* | Quedan en la semana 1, sin día | `docs/PLAN-SIMPLE-1.0.md` §6 |
| D-40 | **Empezar la escucha por el viento**, que es textura gratuita | Sí, y la hoguera a su lado (D-38) *(fuente: plan §10)* | `ESCUCHA.md` ya empieza por las dos | Ninguno |
| D-41 | **VoiceOver en la definición de hecho** de cada PR | Sí *(fuente: plan §10)* | No entra; queda D-15 como única pasada | `docs/PLAN-SIMPLE-1.0.md` §8 |
| D-42 | **Un segundo lector, solo lectura**, para los PR de audio y de StoreKit | Sí *(fuente: plan §10)* | Un solo revisor | `docs/PLAN-SIMPLE-1.0.md` §3 |
| D-43 | **Reconciliar las specs 05 y 07.** Se propuso antes de S-04, que ya está integrado | Darla por superada para 1.0; reconciliarlas cuando se abra 1.1 *(guía)* | Siguen sin reconciliar; manda la reconciliación | `docs/design/05-*.md`, `07-*.md` |
| D-44 | **Correo en los commits.** El repositorio público lleva como autor una dirección real | La dirección `noreply` de GitHub de aquí en adelante. Reescribir la historia ya publicada es otra decisión, con coste: cambia todos los identificadores de commit *(fuente: ESTADO, corrección de S-06; lo de la historia es de la guía)* | Los commits nuevos siguen saliendo con la dirección actual | Configuración local de Git; ninguno del repositorio |
| D-45 | **`CODEOWNERS`** para `scripts/`, `.github/` y `project.yml`, al proteger `main`. El fichero solo impide algo si la regla exige la revisión de los propietarios, y esa revisión es una aprobación de otra cuenta: hoy todos los PR salen de una sola cuenta de GitHub y nadie aprueba su propio PR | Solo si hay una **segunda cuenta** que revise. Mientras no la haya, aprobaciones requeridas en 0 y sin revisión de propietarios obligatoria (`GUIA.md` §3) *(fuente: ESTADO, notas de S-01, lo proponía sin condición; la condición es de la guía)* | La CI avisa pero no impide | `.github/CODEOWNERS` y la regla de `main` en GitHub |
| D-50 | **Cursor.** El plan §6 te pedía confirmar su plan el 17-11, y reparte en él los paquetes S-03, S-05 y S-09. Las ramas de esos tres paquetes llevan el prefijo `claude/`: los hizo Claude | Decir si Cursor sigue en el reparto. Si no, anotar en el plan quién hace de revisor distinto del autor, que es una regla que se mantiene (plan §1) *(guía)* | El plan y la práctica siguen sin coincidir | `docs/PLAN-SIMPLE-1.0.md` §3 y §5, `AGENTS.md` §7 |

## 7. Surgidas al escribir esta guía

No están en los tres documentos de origen. Se anotan aquí para que no se pierdan.

| Id | Decisión | Recomendación | Si no decides | Fichero que cambia |
|---|---|---|---|---|
| D-46 | **Qué publica GitHub Pages.** Con el ajuste simple se publica toda la carpeta `docs/`, también esta | Publicar solo `privacy/`, y añadir `lanzamiento` a la lista de exclusiones si se usa esa vía | No se activa Pages, y sin URL de privacidad no se envía | `docs/_config.yml` o un flujo en `.github/workflows/` |
| D-47 | **Poder repetir la prueba de 7 noches en un build de depuración.** El registro vive en el llavero y sobrevive a borrar la app: en un iPhone real el ensayo solo se puede hacer una vez. Además manda sobre la prueba antigua, así que `PRUEBAS-EN-DISPOSITIVO.md` §9, §10 pasos 1 a 10 y §10 paso 12 piden cada uno un llavero limpio | Un argumento de lanzamiento, solo en Debug, que borre el registro al arrancar, antes de leer nada. Construirlo **antes** de las pruebas 9 y 10: con un solo iPhone es un requisito para hacerlas enteras | Un ensayo por iPhone: una sola de esas tres pruebas; las otras, en otro iPhone o en el simulador | `SleepNoise/Model/KeychainTrialStorage.swift`, `PageDebug.swift` |
| D-48 | **Vendedor**: persona o empresa, y condición de comerciante en la UE, que hace públicos unos datos de contacto | Decidirlo antes de inscribirte; no se cambia con facilidad | No hay respuesta por defecto | Ninguno del repositorio |
| D-49 | **Publicación al aprobarse**: manual o automática | Manual, para elegir el día | Lo que App Store Connect traiga marcado | Ninguno |
| D-53 | **Una compra pendiente que se rechaza deja el botón en "Pendiente".** La tienda no avisa de un rechazo y la app solo retira ese estado cuando Pro se abre: hasta cerrar la app del todo y abrirla no se puede volver a comprar (`PRUEBAS-EN-DISPOSITIVO.md` §8.A, paso 12) | Corregirlo en S-11: que "Pendiente" no impida volver a pedir la compra, por ejemplo retirándolo al cerrar la hoja o al volver la app a primer plano | Se queda: quien vea rechazada su petición tiene que cerrar la app para pedirla otra vez | `SleepNoise/StoreKit/PurchaseManager.swift`, `SleepNoise/Features/Pro/ProSheetLogic.swift` |
| D-54 | **La beta gasta la prueba de 7 noches de los probadores.** TestFlight y la tienda comparten el llavero: quien empiece la prueba en la beta no la tendrá en la versión de la tienda, en ese iPhone. Y la compra de la beta no pasa a la tienda | Decirlo en la invitación, como ya hace `BETA.md` §2, y no pedir a nadie que empiece la prueba en la beta | La invitación lo avisa y cada probador decide | `docs/lanzamiento/BETA.md` |

---

## Cerradas: no vuelven

Para que nadie las reabra por despiste.

| Asunto | Cómo quedó | Dónde |
|---|---|---|
| Live Activity en 1.0 (reconciliación §6 n.º 3) | Escenario B: pasa a 1.1 | Plan §4.4 |
| "Manto" en inglés (reconciliación §6 n.º 4) | "Blanket" | Plan §6 |
| Precio | Pago único, sin precio de salida, un solo `displayPrice` | Plan §4.2 |
| En familia | Activado; no se puede desactivar en App Store Connect | Plan §4.2 |
| Prueba | Siete noches, local, empieza solo con su botón | C07 |
| Mezclas guardadas gratis | Tres | Reconciliación §4 |
| Pomo del interruptor de Marea | Estilo propio dibujado con tokens | ESTADO, corrección de S-06 |
| Dónde vive el identificador de equipo | En `Config/Local.xcconfig`, fuera de Git. Lo trae S-08, en curso; a ti solo te queda crear el fichero (`GUIA.md` §2) | `Config/`, `project.yml`, `.gitignore` |
| Frase sobre estudios de respiración en la hoja de Marea | No está en el catálogo de 1.0 | `Localizable.xcstrings` |
| D-08, restaurar de noche (17-11-2026) | Fila "Restaurar compra" en Ajustes cuando no hay Pro y no se puede vender; sin precio y sin hoja | `SettingsRestoreRow`, `docs/store/notas-revision.md` |
| D-32, tope de seis capas (17-11-2026) | Una sola regla: suenan las seis incluidas más altas, las demás esperan con su nivel; nada guardado se reescribe | `SleepNoise/Model/LayerCap.swift` |
| D-52, Noche terminada por la mañana (17-11-2026) | De día cede sola a la página de día; de noche sigue con "Terminó a las…" y Madrugada | `MixerModel.leaveNightScreenIfOverByDay` |

## Fuera de 1.0, con su versión

| Función | Versión | Fuente |
|---|---|---|
| Live Activity, Dynamic Island y StandBy | 1.1 | Plan §4.4 y §9 |
| Widgets: pequeño "Dormir", pantalla de bloqueo y mediano "Mezclas" | 1.1 | Plan §4.4; reconciliación §5 |
| Centro de control y botón de Acción | 1.1 | Plan §4.4 |
| Papel (modo claro) | 1.1 | Plan §4.1; C32 |
| Timbre (fila en Capas) y timbre por capa | 1.1 | Plan §4.3 fila 5; C29 |
| Siesta | 1.1 | Plan §4.3 fila 8; C30 |
| "Qué sabemos" y "Cómo se genera" | 1.1 | Plan §4.4 |
| Diagnóstico y "Enviar informe" | 1.1 | Plan §4.4 |
| iCloud para las mezclas (Pro) | 1.1 | Plan §4.4; C09 |
| "Debajo de otro audio" | 1.1 | C44 |
| Filtro de Focus y Atajos de Marea y de nivel | 1.1 | Plan §4.4; C43 |
| Escucha de 30 s de una capa Pro | 1.1 | C06 |
| Gestos de Marea por textura | 1.1 | C24 |
| Retirada de Manto | 1.1 | C36 |
| Nombres de las mezclas de la casa por uso | 1.1 | C18 |
| Carta de novedades, Acceso asistido, guía de AirPods | 1.1 | Reconciliación §5 |
| Decisión sobre pedir reseñas desde la app | 1.1, con datos | C55 |
| Vídeo de vista previa de la ficha | 1.1 | Plan §4.3 fila 28 |
| Página "Al acostarte", fila "Salida", "Pasar sola a Noche" como ajuste, TipKit y háptica de la Marea | 1.1: no están en la lista del plan §4.3, y lo que no aparece allí pasa a 1.1 | Plan, cabecera |
| Reconciliar las specs 05, 07 y 09 | Con 1.1 | Plan §4.4 |
| Apple Watch | 1.2 | Plan §9; C28 |
| iPad | 1.2, si las ventas lo justifican | Plan §9 |
| Fundido por quietud | 1.2 | C37 |
| Salud: leer el horario de sueño, con permiso explícito | 1.2 según el plan §9 y `docs/ROADMAP.md` | Plan §9 |
| Salud dentro de la Marea | 2.0 | C34 |
| Amanecer acústico | 2.0 | C36 |
| Rampa propia para la bajada del Manto; fundido cruzado entre mezclas; fundido de 800 ms al comprar | Sin versión: 1.0.1 si se oyen (D-36, D-37) | ESTADO |
| Semilla por arranque y test de autocorrelación | Sin versión (D-11) | `docs/store/README.md` |
| Paquete I0-8 de la Marea (spec 06): disolución dentro de la ventana, 30 s de disolución al apagarla a mano, interruptor que vuelve solo a apagado tras la retirada y ancla corregida con la latencia de salida | Sin versión | ESTADO, S-06 tarea 2 |
| "Guardar en «…»", descomposición del Horizonte por pulsación larga | Sin versión | ESTADO, S-04 y S-06 |
| Cuentas, anuncios, analítica, red propia, bibliotecas de terceros, grabaciones de audio, petición de reseña del sistema | Nunca | `AGENTS.md` §5.11; `docs/ROADMAP.md` |
| Candados, insignias, cápsulas, degradados, sombras, luna y estrellas, iconos de sonido | Nunca | `AGENTS.md` §5.10 |
