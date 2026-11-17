# Notas para revisión (Notes for Review)

Campo "Notes" de "App Review Information", en la página de la versión 1.0. Va en inglés y no se traduce. Los campos de contacto de esa misma sección (nombre, teléfono y correo) los rellena el dueño en App Store Connect y no se escriben en este repositorio. "Sign-in required" se deja sin marcar: la app no tiene cuenta.

## Texto para pegar (EN)

```text en
SleepNoise plays sleep sounds that are synthesized on the iPhone in real time. There are no audio files in the app.

HOW TO TEST
- No account, sign-in or setup. The app opens on its main page, silent.
- Tap the round Play button to start the sound. Drag sideways on a layer to change its level. "All layers" lists every texture.
- The app asks for no permissions: no microphone, notifications, location, motion, Health or tracking.

BACKGROUND AUDIO
- The app declares the "audio" background mode because its one job is to keep playing through the night with the screen off. It uses AVAudioEngine with the playback audio session category.
- To check: start the sound, then press the side button. The sound goes on, and the Lock Screen shows Now Playing with play and pause.
- When the timer ends, the sound fades out, the engine stops and the audio session is released. Nothing runs in the background while no sound is playing.

NETWORK AND DATA
- The app makes no network requests of its own and contains no third-party code, analytics or ads. Its only contact with a server is StoreKit, for the in-app purchase.
- Mixes and settings are stored on the iPhone and are sent to no one. They leave it only inside the device backups the person makes with Apple. Privacy label: Data Not Collected.
- The privacy policy can be read in the app, under Settings › "What's not here", and at the Privacy Policy URL of this listing.
- The app makes no health claims. It is not a medical product.

IN-APP PURCHASE
- One non-consumable, "SleepNoise Pro", paid once, with Family Sharing. It adds ocean, fan, thunder, campfire, brook and cabin, the Tide (the sea paced to a slow breath) and saved mixes without a limit.
- Free for everyone: white, pink, brown, rain and wind, the whole timer and three saved mixes.
- To open the Pro sheet: tap "All layers", then tap a texture marked "pro".
- IMPORTANT: by design the app sells nothing at night. The Pro sheet does not open between 21:00 and 07:00 on the iPhone's clock. Please test the purchase between 07:00 and 21:00, local time on the iPhone.
- The sheet also stays closed, at any hour, on the night page: the main page as you find it when you come back from the Night screen. Tap the name of the mix at the top of the page to go back to the day page, then tap a texture marked "pro".
- "Restore purchase" is on the Pro sheet, below the Buy button.

SEVEN-NIGHT TRIAL
- The trial is kept on the iPhone and involves no purchase: no payment method is requested and nothing renews.
- It starts only when the person taps "Start the trial · 7 nights" on the Pro sheet. It never starts by itself, and pressing Play does not start it.
- Before the trial starts, that sheet shows its length (seven nights), what belongs to Pro and is no longer available when the trial ends (the Pro textures, the Tide and more than three saved mixes), what stays free, and the one-time price of Pro. Nothing is ever charged automatically.
- During the trial everything in Pro is open. The Buy button is there during the trial and after it.
- When the trial ends, the app goes on with the free set listed above, and saved mixes are kept. If the trial runs out while sound is playing, the change waits until playback stops.
- The trial state is kept in the iPhone's keychain, so deleting and reinstalling the app does not start a second trial.
```

Recuento: 3355 de 4000.

## Resumen (ES)

- **Cómo probarla.** No hay cuenta ni configuración. Se abre en silencio en la página principal; el Disco arranca el sonido; arrastrar en horizontal sobre una capa cambia su nivel. No pide ningún permiso.
- **Audio en segundo plano.** Declara el modo `audio` porque su única función es seguir sonando toda la noche con la pantalla apagada. Usa `AVAudioEngine` con la categoría `playback`. Al terminar el temporizador el sonido se funde, el motor para y se libera el audio: sin sonido no queda nada en segundo plano.
- **Red y datos.** La app no hace ninguna petición de red propia y no lleva código de terceros, analítica ni anuncios. Solo StoreKit habla con un servidor, para la compra. Las mezclas y los ajustes se guardan en el iPhone y no se envían a nadie; solo salen de él dentro de las copias de seguridad que la persona haga con Apple. Etiqueta de privacidad: no se recopilan datos. La política se lee dentro de la app, en Ajustes › "Lo que no hay", y en la URL de privacidad de la ficha. No hace afirmaciones de salud.
- **Compra.** Un no consumible, pago único, con Family Sharing. La hoja Pro se abre tocando una textura marcada "pro" en "Todas las capas". Por diseño no se abre entre las 21:00 y las 07:00 del reloj del iPhone: se le pide al revisor que pruebe la compra de día. Tampoco se abre, a ninguna hora, en la página nocturna a la que se vuelve desde Noche: se sale de ella tocando el nombre de la mezcla, y entonces la textura marcada "pro" ya abre la hoja. "Restaurar compra" está en la hoja Pro, bajo el botón de comprar.
- **Prueba de 7 noches.** Se lleva en el iPhone y no hay compra: no pide medio de pago y no se renueva. Empieza solo con "Empezar la prueba · 7 noches" en la hoja Pro, nunca sola ni con Play. Antes de empezar, esa hoja enseña las tres cosas que pide la directriz 3.1.1: cuánto dura, lo que es de Pro y deja de estar disponible al acabar (las texturas de Pro, la Marea y más de tres mezclas guardadas) y el precio único de Pro, además de lo que sigue gratis. Nunca se cobra nada de forma automática. Al terminar, la app sigue con lo gratuito y las mezclas guardadas se conservan; si se acaba mientras suena, el cambio espera a que pare. El estado vive en el llavero del iPhone, así que reinstalar no da otra prueba.

## Estado de cada afirmación frente a `main`

Comprobado leyendo el código de `main` el 17-11-2026 (rama de este paquete, sin S-06, S-07 ni S-08). Nada se ha ejecutado en un iPhone. Antes de pegar las notas hay que repasar las filas que no dicen "Sí".

| Afirmación de las notas | En `main` | Dónde se ve o qué falta |
|---|---|---|
| El sonido se genera en el iPhone; no hay ficheros de audio | Sí | `SleepNoise/Audio/DSP/`; `SleepNoise/Resources/` solo tiene icono, colores, catálogos y manifiestos |
| Sin cuenta ni configuración; se abre en silencio | Sí | No hay código de cuenta; reproducir es siempre una acción de la persona (`AudioSessionConfigurator`) |
| Disco para sonar; arrastre horizontal para el nivel; "All layers" | Sí | `PlayDisc`, `LevelRule`, cadena `capas.todas` |
| No pide permisos | Sí | `Info.plist` no tiene ninguna clave de descripción de uso |
| Modo `audio`, `AVAudioEngine`, categoría `playback` | Sí | `Info.plist` (`UIBackgroundModes`), `AudioSessionConfigurator.activate()` |
| Now Playing con reproducir y pausar | Sí en código | `NowPlayingController`. Sin comprobar en un iPhone con la pantalla apagada |
| Al acabar el temporizador se funde, para y libera el audio | Sí en código | `SleepTimerController`, `SleepAudioEngine` (llama a `AudioSessionConfigurator.deactivate()`) |
| Sin red propia, sin código de terceros, sin analítica ni anuncios | Sí | Ningún uso de `URLSession` ni de `Network`; `project.yml` sin dependencias; `PrivacyInfo.xcprivacy` sin seguimiento ni datos recogidos |
| Mezclas y ajustes se guardan en el iPhone, no se envían a nadie y solo salen en las copias de seguridad | Sí | `MixStore`, `MixerModel` y `BreathingGuideController` escriben en `UserDefaults`, que entra en la copia de seguridad del iPhone (iCloud u ordenador). El registro de la prueba irá en el llavero con `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` (`KeychainTrialStorage`), que no pasa a otro iPhone |
| La política de privacidad se lee dentro de la app, en Ajustes › "Lo que no hay" | **No** | Ajustes y la página ya existen (S-07), pero la página lleva siete hechos y una frase: ni el texto de la política ni un enlace, y `AppLinks` no tiene dirección de privacidad. Es obligatoria para enviar (directriz 5.1.1(i)): ver `README.md` y "Arreglos del repaso completo" en `docs/agents/ESTADO.md`. Mientras no esté, esta frase no se pega en las notas |
| Un no consumible; lo que añade y lo que es gratis | Sí | `AccessPolicy` |
| Con Family Sharing | No depende del código | Se activa en App Store Connect; el fichero de pruebas `.storekit` aún dice `false` |
| La hoja Pro se abre al tocar una textura marcada "pro" | Sí | `LayerRow` (`onLockedTap`), `LevelRule` |
| La hoja Pro no se abre entre las 21:00 y las 07:00 | Sí | `SaleGate`, `NightWindow`, `MixerModel.offerPro()` |
| La hoja Pro tampoco se abre en la página nocturna, a ninguna hora, y de ella se sale tocando el nombre de la mezcla | Sí en el modelo | `SaleGate` (`nightSession`), `MixerModel.leaveBedtime()`, que llama a `beginNightSession()`, y el toque en el nombre de `PageView`, que llama a `endNightSession()`. La pantalla Noche desde la que se llega a esa página es de S-06: hoy solo se entra con el modo de depuración. Cuando S-06 entre hay que comprobar que la salida sigue siendo ese toque, y que con la hoja cerrada tampoco hay Restaurar ni inicio de la prueba |
| "Restore purchase" en la hoja Pro | A medias | El botón existe y llama a `AppStore.sync()`; hoy dice "Restore purchases". Cambia en S-07 |
| Botón "Buy" con el precio | A medias | El botón existe y enseña `displayPrice`; hoy lleva los textos antiguos (`paywall.purchaseFormat`, `paywall.keepFormat`). Cambia en S-07 |
| Comprar se puede durante la prueba y después | Sí | `PaywallView`: comprar y restaurar dependen de `isPro`, no de la prueba |
| La prueba se lleva en el iPhone y no hay compra | Sí | La prueba es un reloj local; el único producto de la tienda es Pro |
| La prueba empieza solo con "Start the trial · 7 nights" en la hoja Pro, nunca con Play | **No** | Hoy `MixerModel` llama a `startTrialIfNeeded()` al primer Play y la prueba cuenta días. Es el trabajo de S-07 (C07) |
| Antes de empezar, la hoja enseña la duración, lo que deja de estar disponible al acabar, lo que sigue gratis y el precio único | A medias | Hoy lo dice con el texto de la prueba antigua. Se reescribe en S-07. En el diseño (guía de copy §2.8 y `pro.prueba.empezar.nota`) la duración y el precio están escritos; lo que se pierde se deduce de las listas "con pro" y "gratis siempre", no hay una frase que lo diga. Ver "Riesgo 3.1.1", abajo |
| Al terminar sigue lo gratuito y las mezclas se conservan; si suena, espera | Sí | `PurchaseManager.refreshAccess(canDowngrade:)`, `AccessPolicy` |
| Estado de la prueba en el llavero; reinstalar no la repite | **No** | `NightTrial` y `KeychainTrialStorage` existen con sus tests, pero la app aún usa `TrialClock` sobre `UserDefaults`. Se conecta en S-07 |

Dos cosas que el documento 11 quería en estas notas y que no están, porque no se pueden sostener con `main`:

- La cita de un test de autocorrelación a diez minutos como prueba de que el sonido no se repite (C53). Ese test no existe: en `SleepNoiseTests` solo hay una autocorrelación sobre los intervalos del trueno. Las notas dicen lo que sí es cierto: que no hay ficheros de audio.
- La explicación de "Qué sabemos" y del Diagnóstico (C54, C56). Las dos pantallas pasan a 1.1 (`docs/PLAN-SIMPLE-1.0.md` §4.4).

## Riesgo 3.1.1

La directriz 3.1.1 describe la prueba gratuita de una app de pago único como un producto no consumible de precio cero y exige que, antes de empezar, la app diga con claridad tres cosas: cuánto dura, qué deja de estar disponible al acabar y qué cargo viene después (`docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md` §9.1). La prueba de 1.0 no es ese producto: es un reloj en el iPhone. Las notas lo dicen una sola vez y en positivo ("kept on the iPhone and involves no purchase"), sin negar el mecanismo de la directriz, y dedican una línea a las tres cosas con las palabras de Apple.

Dos cosas quedan para el dueño y para S-07:

- La nota bajo el botón (`pro.prueba.empezar.nota`) dice la duración y lo que sigue gratis, pero no nombra lo que se pierde. Conviene que lo nombre, o las notas afirmarán algo que el revisor tendrá que deducir de dos listas.
- Si App Review pide que la prueba sea un producto gratuito de la tienda, la alternativa está propuesta en `docs/PLAN-SIMPLE-1.0.md` §10 y espera el sí del dueño; estas notas habría que reescribirlas.
