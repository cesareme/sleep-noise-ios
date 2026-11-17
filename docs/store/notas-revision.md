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
- Mixes and settings stay on the iPhone. Privacy label: Data Not Collected.
- The app makes no health claims. It is not a medical product.

IN-APP PURCHASE
- One non-consumable, "SleepNoise Pro", paid once, with Family Sharing. It adds ocean, fan, thunder, campfire, brook and cabin, the Tide (the sea paced to a slow breath) and saved mixes without a limit.
- Free for everyone: white, pink, brown, rain and wind, the whole timer and three saved mixes.
- To open the Pro sheet: tap "All layers", then tap a texture marked "pro".
- IMPORTANT: by design the app sells nothing at night. The Pro sheet does not open between 21:00 and 07:00 on the iPhone's clock. Please test the purchase between 07:00 and 21:00, local time on the iPhone.
- "Restore purchase" is on the Pro sheet, below the Buy button.

SEVEN-NIGHT TRIAL
- The trial is local to the iPhone. It is not a StoreKit product: nothing is charged, no payment method is requested and nothing renews.
- It starts only when the person taps "Start the trial · 7 nights" on the Pro sheet. It never starts by itself, and pressing Play does not start it. The sheet states how long it lasts, that nothing is charged and what stays free afterwards.
- During the trial everything in Pro is open. The Buy button is there during the trial and after it.
- When the trial ends, the app goes on with the free set listed above, and saved mixes are kept. If the trial runs out while sound is playing, the change waits until playback stops.
- The trial state is kept in the iPhone's keychain, so deleting and reinstalling the app does not start a second trial.
```

Recuento: 2713 de 4000.

## Resumen (ES)

- **Cómo probarla.** No hay cuenta ni configuración. Se abre en silencio en la página principal; el Disco arranca el sonido; arrastrar en horizontal sobre una capa cambia su nivel. No pide ningún permiso.
- **Audio en segundo plano.** Declara el modo `audio` porque su única función es seguir sonando toda la noche con la pantalla apagada. Usa `AVAudioEngine` con la categoría `playback`. Al terminar el temporizador el sonido se funde, el motor para y se libera el audio: sin sonido no queda nada en segundo plano.
- **Red y datos.** La app no hace ninguna petición de red propia y no lleva código de terceros, analítica ni anuncios. Solo StoreKit habla con un servidor, para la compra. Etiqueta de privacidad: no se recopilan datos. No hace afirmaciones de salud.
- **Compra.** Un no consumible, pago único, con Family Sharing. La hoja Pro se abre tocando una textura marcada "pro" en "Todas las capas". Por diseño no se abre entre las 21:00 y las 07:00 del reloj del iPhone: se le pide al revisor que pruebe la compra de día. "Restaurar compra" está en la hoja Pro, bajo el botón de comprar.
- **Prueba de 7 noches.** Es local y no es un producto de StoreKit: no cobra, no pide medio de pago y no se renueva. Empieza solo con "Empezar la prueba · 7 noches" en la hoja Pro, nunca sola ni con Play. Al terminar, la app sigue con lo gratuito y las mezclas guardadas se conservan; si se acaba mientras suena, el cambio espera a que pare. El estado vive en el llavero del iPhone, así que reinstalar no da otra prueba.

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
| Un no consumible; lo que añade y lo que es gratis | Sí | `AccessPolicy` |
| Con Family Sharing | No depende del código | Se activa en App Store Connect; el fichero de pruebas `.storekit` aún dice `false` |
| La hoja Pro se abre al tocar una textura marcada "pro" | Sí | `LayerRow` (`onLockedTap`), `LevelRule` |
| La hoja Pro no se abre entre las 21:00 y las 07:00 | Sí | `SaleGate`, `NightWindow`, `MixerModel.offerPro()` |
| "Restore purchase" en la hoja Pro | A medias | El botón existe y llama a `AppStore.sync()`; hoy dice "Restore purchases". Cambia en S-07 |
| Botón "Buy" con el precio | A medias | El botón existe y enseña `displayPrice`; hoy lleva los textos antiguos (`paywall.purchaseFormat`, `paywall.keepFormat`). Cambia en S-07 |
| Comprar se puede durante la prueba y después | Sí | `PaywallView`: comprar y restaurar dependen de `isPro`, no de la prueba |
| La prueba no es un producto de StoreKit | Sí | La prueba es un reloj local; el único producto es Pro |
| La prueba empieza solo con "Start the trial · 7 nights" en la hoja Pro, nunca con Play | **No** | Hoy `MixerModel` llama a `startTrialIfNeeded()` al primer Play y la prueba cuenta días. Es el trabajo de S-07 (C07) |
| La hoja dice la duración, que no cobra y qué sigue gratis | A medias | Hoy lo dice con el texto de la prueba antigua. Se reescribe en S-07 |
| Al terminar sigue lo gratuito y las mezclas se conservan; si suena, espera | Sí | `PurchaseManager.refreshAccess(canDowngrade:)`, `AccessPolicy` |
| Estado de la prueba en el llavero; reinstalar no la repite | **No** | `NightTrial` y `KeychainTrialStorage` existen con sus tests, pero la app aún usa `TrialClock` sobre `UserDefaults`. Se conecta en S-07 |

Dos cosas que el documento 11 quería en estas notas y que no están, porque no se pueden sostener con `main`:

- La cita de un test de autocorrelación a diez minutos como prueba de que el sonido no se repite (C53). Ese test no existe: en `SleepNoiseTests` solo hay una autocorrelación sobre los intervalos del trueno. Las notas dicen lo que sí es cierto: que no hay ficheros de audio.
- La explicación de "Qué sabemos" y del Diagnóstico (C54, C56). Las dos pantallas pasan a 1.1 (`docs/PLAN-SIMPLE-1.0.md` §4.4).

Si App Review pide que la prueba sea un producto gratuito de la tienda, la alternativa está propuesta en `docs/PLAN-SIMPLE-1.0.md` §10 y espera el sí del dueño; estas notas habría que reescribirlas.
