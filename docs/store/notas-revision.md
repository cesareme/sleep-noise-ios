# Notas para revisión (Notes for Review)

Campo "Notes" de "App Review Information", en la página de la versión 1.0. Va en inglés y no se traduce. Los campos de contacto de esa misma sección (nombre, teléfono y correo) los rellena el dueño en App Store Connect y no se escriben en este repositorio. "Sign-in required" se deja sin marcar: la app no tiene cuenta.

El texto describe el código de 1.0 tal como está (paquetes S-01 a S-10). Cada frase tiene su fila en la tabla de comprobación, con el tipo, la cadena o el test que la sostiene. Lo que depende del dueño está en "Condiciones del dueño antes de pegar": mientras una condición siga abierta, su frase no es cierta todavía.

## Texto para pegar (EN)

```text en
SleepNoise plays sleep sounds that are synthesized on the iPhone in real time. There are no audio files in the app.

HOW TO TEST
- No account, sign-in or setup. The app opens on its main page, silent.
- Tap the round Play button in the middle of the bottom bar to start the sound. Drag sideways on a layer to change its level. "All layers" opens a sheet with every texture.
- The first session has a 45-minute timer ("Until I sleep"). The "Timer" row on the main page changes it or turns it "Off".
- The app asks for no permissions: no microphone, notifications, location, motion, Health or tracking.

BACKGROUND AUDIO
- The app declares the "audio" background mode because its one job is to keep playing through the night with the screen off. It uses AVAudioEngine with the playback audio session category.
- To check: start the sound, then press the side button. The sound goes on, and the Lock Screen shows Now Playing with play and pause.
- When the timer ends, the sound fades out, playback stops and the audio session is released. Nothing runs in the background while no sound is playing.

NETWORK AND DATA
- The app makes no network requests of its own and contains no third-party code, analytics or ads. Its only contact with a server is StoreKit, for the in-app purchase.
- Mixes and settings are stored on the iPhone and are sent to no one. They leave it only inside the device backups the person makes with Apple. Privacy label: Data Not Collected.
- The app makes no health claims. It is not a medical product.

IN-APP PURCHASE
- One non-consumable, "SleepNoise Pro", paid once, with Family Sharing. It adds ocean, fan, thunder, campfire, brook and cabin, the Tide (the sea paced to a slow breath) and saved mixes without a limit.
- Free for everyone: white, pink, brown, rain and wind, the whole timer and three saved mixes.
- To open the Pro sheet: on the main page tap "All layers", then tap a texture marked "pro" (Fan, Ocean, Thunder, Campfire, Brook or Cabin). Another way: tap "Mixes" on the bottom bar, then "Settings" (the last row), then the row under "pro".
- IMPORTANT: by design the app sells nothing at night. The Pro sheet does not open between 21:00 and 07:00 on the iPhone's clock; those taps do nothing then. Please test the purchase between 07:00 and 21:00, local time on the iPhone.
- The sheet also stays shut, at any hour, on the night page: the main page as you find it after opening "Night" from the bottom bar and pressing and holding to go back. Tap the name of the mix at the top of the page to return to the day page.
- At the foot of the sheet: "Start the trial · 7 nights", "Buy" with the price, and "Restore purchase".

SEVEN-NIGHT TRIAL
- The trial is kept on the iPhone and involves no purchase: no payment method is requested and nothing renews.
- It starts only when the person taps "Start the trial · 7 nights" on the Pro sheet. It never starts by itself, and neither Play nor a Shortcut starts it.
- Before it starts, that sheet shows the one-time price (the figure and "Once."), what is in Pro (so, what is no longer available when the trial ends) under "with pro", what stays free under "always free", and this note: "Lasts seven nights. Nothing is charged and no card is needed. When it ends, free stays free and your mixes are kept." Nothing is ever charged automatically.
- During the trial everything in Pro is open. By day the main page shows "trial · 7 nights left" above the name of the mix; tapping it opens the Pro sheet. "Buy" is there during the trial and after it.
- When the trial ends, the app goes on with the free set listed above, and saved mixes are kept. The end of the trial never takes effect while sound is playing.
- The trial record is kept in the iPhone's keychain, so deleting and reinstalling the app does not start a second trial.
```

Recuento: 3809 de 4000.

Las palabras entre comillas del bloque son las de la app en inglés, letra a letra, tal como están en `SleepNoise/Resources/Localizable.xcstrings`. La única que no sale del catálogo es el nombre "SleepNoise Pro": la hoja enseña el `displayName` que dé App Store Connect (`compra-integrada.md`).

## Resumen (ES)

- **Cómo probarla.** No hay cuenta ni configuración. Se abre en silencio en la página principal; el Disco, en el centro de la barra inferior, arranca el sonido; arrastrar en horizontal sobre una capa cambia su nivel; "Todas las capas" abre la hoja con todas las texturas. La primera noche trae un temporizador de 45 minutos ("Hasta dormirme"), que se cambia o se apaga en la fila "Temporizador". No pide ningún permiso.
- **Audio en segundo plano.** Declara el modo `audio` porque su única función es seguir sonando toda la noche con la pantalla apagada. Usa `AVAudioEngine` con la categoría `playback`. Al terminar el temporizador el sonido se funde, la reproducción para y se libera el audio: sin sonido no queda nada en segundo plano.
- **Red y datos.** La app no hace ninguna petición de red propia y no lleva código de terceros, analítica ni anuncios. Solo StoreKit habla con un servidor, para la compra. Las mezclas y los ajustes se guardan en el iPhone y no se envían a nadie; solo salen de él dentro de las copias de seguridad que la persona haga con Apple. Etiqueta de privacidad: no se recopilan datos. No hace afirmaciones de salud. La frase sobre la política de privacidad dentro de la app ya no está: no es cierta en este código (condición 1).
- **Compra.** Un no consumible, pago único, con Family Sharing. De día hay dos caminos a la hoja Pro: "Todas las capas" y tocar una textura marcada "pro" (Ventilador, Océano, Trueno, Hoguera, Arroyo o Cabina), o "Mezclas" en la barra inferior, "Ajustes" (la última fila) y la fila que hay bajo "pro". Por diseño la hoja no se abre entre las 21:00 y las 07:00 del reloj del iPhone, y esos toques no hacen nada: se le pide al revisor que haga la compra de día. Tampoco se abre, a ninguna hora, en la página nocturna, que es la página tal como queda al volver de "Noche" con una pulsación larga: se sale de ella tocando el nombre de la mezcla. Al pie de la hoja están "Empezar la prueba · 7 noches", "Comprar" con el precio y "Restaurar compra".
- **Prueba de 7 noches.** Se lleva en el iPhone y no hay compra: no pide medio de pago y no se renueva. Empieza solo con "Empezar la prueba · 7 noches" en la hoja Pro, nunca sola, ni con Play ni con un Atajo. Antes de empezar, esa hoja enseña el precio único (la cifra y "Una vez."), lo que es de Pro bajo "con pro", lo que sigue gratis bajo "gratis siempre" y la nota "Dura siete noches. No se cobra nada ni se pide tarjeta. Al acabar, lo gratis sigue gratis y tus mezclas se conservan." Nunca se cobra nada de forma automática. Durante la prueba todo lo de Pro está abierto y, de día, la página dice "prueba · quedan 7 noches" sobre el nombre de la mezcla; tocarlo abre la hoja Pro, donde "Comprar" sigue estando durante la prueba y después. Al terminar, la app sigue con lo gratuito y las mezclas guardadas se conservan; el final de la prueba nunca llega mientras suena: se evalúa al empezar una sesión o al abrir la app. El registro vive en el llavero del iPhone, así que reinstalar no da otra prueba.

## Tabla de comprobación

Comprobado el 17-11-2026 leyendo el código de 1.0 de esta rama, frase a frase. Los tests se citan por nombre y no se han vuelto a ejecutar en este paquete, que solo toca documentación; la puerta es `scripts/verify.sh`. Nada se ha ejecutado en un iPhone ni contra la tienda de Apple.

Estados: **Sí**, lo sostiene el código y, donde se cita, un test. **Sí en código**, además falta verlo en un iPhone o en el sandbox. **Condición**, no depende del código o el código no lo cumple: lo resuelve el dueño antes de enviar (lista de abajo).

| Afirmación de las notas | Estado | Qué la sostiene |
|---|---|---|
| El sonido se genera en el iPhone; no hay ficheros de audio | Sí | Generadores de `SleepNoise/Audio/DSP/` (`WhiteNoise`, `PinkNoise`, `BrownNoise` y una textura por fichero) mezclados en `RenderState`. En el repositorio no hay ningún fichero de sonido; `SleepNoise/Resources/` solo tiene los dos catálogos, `Assets.xcassets`, `Info.plist`, `SleepNoise.entitlements`, `PrivacyInfo.xcprivacy` y `SleepNoise.storekit` |
| Sin cuenta ni configuración; se abre en silencio | Sí | No hay código de cuenta. `SleepNoiseApp` y `AppRoot` no arrancan el sonido: solo lo hace `MixerModel.play()`, que llama la persona (el Disco, la pantalla de bloqueo, los auriculares, Noche o un Atajo) |
| Play en el centro de la barra inferior; arrastre horizontal; "All layers" | Sí | `PlayDisc` dentro de `PageBar` (`control.play`, "Play"); `LevelRule` y `LevelTouchSurface`; fila `capas.todas` ("All layers") de `PageView`, que abre `LayersSheet` con todos los colores y todas las camas (`PageLayers.colors`, `PageLayers.beds`) |
| La primera sesión trae 45 minutos de "Until I sleep"; la fila del temporizador lo cambia o lo apaga | Sí | `TimerChoice.firstUse` y `TimerChoice.defaultMinutes`; cadenas `temporizador.dormirme` ("Until I sleep"), `temporizador.titulo` (el título de la fila y de su hoja) y `temporizador.apagado` ("Off"); `TimerChoiceModelTests.testTheFirstNightHasATimerAndOffIsAChoice` |
| No pide permisos | Sí | `Info.plist` no tiene ninguna clave de descripción de uso. Los marcos que se importan son `AVFoundation`, `MediaPlayer`, `StoreKit`, `AppIntents`, `Security`, `CallKit`, `SwiftUI`, `UIKit` y `Combine`. `CallKit` solo se usa para saber si hay una llamada en curso (`AudioSessionObserver`), y eso no pide permiso |
| Modo `audio`, `AVAudioEngine`, categoría `playback` | Sí | `Info.plist` (`UIBackgroundModes`), `SleepAudioEngine`, `AudioSessionConfigurator.activate()` |
| Now Playing con reproducir y pausar | Sí en código | `NowPlayingController` (`MPRemoteCommandCenter`: reproducir, pausar y alternar). Sin comprobar en un iPhone con la pantalla apagada (condición 4) |
| Al acabar el temporizador se funde, para y libera el audio; sin sonido no queda nada en segundo plano | Sí en código | `SleepTimerController.onComplete`, `MixerModel.bindTimer()`, `SleepAudioEngine.stop(fadeOut:)`, que pausa el motor y llama a `AudioSessionConfigurator.deactivate()`; `NightSessionTests.testTheTimerFadesTheNightOutAndEndsIt`. No hay tareas de segundo plano en el código. Sin medir en un iPhone (condición 4) |
| Sin red propia, sin código de terceros, sin analítica ni anuncios | Sí | `SettingsTests.testTheSourcesAskForNoReviewPromptAndCarryNoAddress` recorre las fuentes y falla si alguna usa `URLSession`; tampoco se importa `Network`. `project.yml` no declara paquetes. `PrivacyInfo.xcprivacy`: sin seguimiento, sin dominios y sin datos recogidos. La tienda es StoreKit 2 (`AppStoreProStore`) |
| Mezclas y ajustes se guardan en el iPhone, no se envían a nadie y solo salen en las copias de seguridad | Sí | `MixStore`, `MixerModel` y `BreathingGuideController` escriben en `UserDefaults`, que entra en la copia de seguridad del iPhone. El registro de la prueba va al llavero y no pasa a otro iPhone (`KeychainTrialStorage`) |
| No hace afirmaciones de salud ("not a medical product") | Sí | `CopyLintTests.testNoMedicalClaimsInEitherLanguage`, `testEnglishKeepsOffBothBlackLists` y `testSpanishKeepsOffBothBlackLists` sobre los dos catálogos; `testTheStoreListingsPassTheLint` sobre las fichas |
| La política de privacidad se lee dentro de la app | **Condición 1** | Frase retirada del texto. `WhatIsNotHerePage` (Ajustes › "What’s not here") enseña la lista `lo_que_no_hay.lista` y la frase `lo_que_no_hay.resena`: ni el texto de la política ni un enlace. `AppLinks` solo tiene `appStoreID` y `authorAddress`, los dos vacíos |
| Un no consumible; lo que añade y lo que es gratis | Sí | `AccessPolicy` (`proProductID`, `freeSounds`, `freeSavedMixLimit`), `AccessPolicyTests.testFreeSounds`. La hoja lo dice con `pro.incluye.texturas.detalle` ("Ocean, fan, thunder, campfire, brook and cabin"), `pro.incluye.marea` ("Tide"), `pro.incluye.mezclas` ("Unlimited mixes") y `pro.gratis.lista` ("White, pink, brown, rain and wind · the whole timer · three mixes"); `ProCatalogTests.testTheFreeListOfTheSheetIsThePolicy` |
| Con Family Sharing | **Condición 2** | Lo que hay en el código: `SleepNoise.storekit` tiene `familyShareable` en `true` (`ProStoreTests.testTheLocalStoreSellsOneFamilySharedProductAndClaimsNothingOld`); la hoja añade `pro.familia` ("With your family") a "with pro" salvo que la tienda diga que el producto no se comparte (`ProSheetContent.listsFamily`, `ProSheetContentTests.testFamilySharingIsListedUnlessTheStoreSaysOtherwise`); la compra de un familiar se reconoce por `ownershipType` (`AppStoreProStore`, `ProStoreTests.testAFamilyPurchaseArrivesAtLaunch`). En la tienda real se activa en App Store Connect |
| Camino 1 a la hoja Pro: "All layers" y una textura marcada "pro" | Sí | `LayersSheet`; `LayerRow` pasa `onLockedTap` a `LevelRule` solo si `MixerModel.canSell`; la palabra es `LevelRuleSpeech.lockedWord` (`comun.pro`, "pro", o `comun.pro.nivel` cuando la capa guarda un nivel). Sin acceso llevan la palabra las texturas que no están en `AccessPolicy.freeSounds` |
| Camino 2: "Mixes", "Settings" (la última fila) y la fila bajo "pro" | Sí | `PageBar` (`barra.mezclas`, "Mixes"); `MixesSheet` (`ajustes.titulo`, "Settings", su última fila); `SettingsSheet.proRow` bajo la cabecera `ajustes.seccion.pro` ("pro"); `SettingsProRow.opensSheet`; `SettingsTests.testTheWayIntoTheSheetFollowsTheSaleGate` |
| La hoja Pro no se abre entre las 21:00 y las 07:00, y esos toques no hacen nada | Sí | `NightWindow` (21 y 7, una sola constante), `SaleGate`, `MixerModel.canSell` y `MixerModel.offerPro()`; `NightWindowTests.testWindowEdges`, `PageModelTests.testSaleGateFollowsTheNightWindow`, `PageModelTests.testNoPathOpensTheProSheetAtNight`, `SettingsTests.testAtNightTheProRowIsWordsWithoutAPrice`, `ProTrialTests.testASheetLeftOpenSellsNothingOnceTheNightBegins` |
| Tampoco se abre en la página nocturna; se llega desde "Night" con una pulsación larga y se sale tocando el nombre | Sí | `PageBar` (`barra.noche`, "Night") abre `NightScreen`; la pulsación larga llama a `MixerModel.leaveBedtime()`, que llama a `beginNightSession()`; el toque en el nombre de `PageView` llama a `endNightSession()`. `BedtimeModelTests.testNothingIsSoldOnNightOrOnTheNightPage`, `PageModelTests.testTheNightPageSellsNothingUntilThePersonLeavesIt`, `NightTouchTests.testAFingerThatStaysAndLiftsGoesBack`. El aviso `noche.volver` ("Hold to go back") solo se enseña la primera vez que se abre Noche: por eso las notas describen el gesto y no citan ese rótulo |
| Al pie de la hoja: "Start the trial · 7 nights", "Buy" con el precio y "Restore purchase" | Sí | `ProSheet.foot`: `pro.prueba.empezar` ("Start the trial · 7 nights"), `pro.comprar` ("Buy · %@", con `displayPrice`) y `pro.restaurar` ("Restore purchase"); `ProSheetContentTests.testANewInstallLeadsWithTheTrialAndThePurchaseSaysTheStorePrice`. Con el texto en tamaños de accesibilidad las tres acciones siguen en el pie |
| Comprar y restaurar funcionan | **Condición 3** | En código: `PurchaseManager.purchase()` y `restore()` sobre `ProStore`; `AppStoreProStore` usa `Product.purchase()` y `AppStore.sync()`; `ProStoreTests.testBuyingOpensEverythingAndKeepsTheReceipt` y `testRestoreSaysWhatItFound`, con la tienda de guion (`ScriptedProStore`). La compra de verdad no se ha hecho nunca: ni en el sandbox ni en un iPhone |
| La prueba se lleva en el iPhone y no hay compra | Sí | `NightTrial`: un registro local con dos fechas y lo consumido. El único producto de la tienda es Pro y no hay grupos de renovación (el mismo test del fichero `.storekit`) |
| Empieza solo con "Start the trial · 7 nights"; ni sola, ni con Play, ni con un Atajo | Sí | `MixerModel.startTrial()` y `PurchaseManager.startTrial(now:)`, a los que fuera del código de depuración solo llega el botón de `ProSheet`; `ProTrialTests.testANewInstallIsFreeAndTheTrialStartsOnlyFromTheSheet`, `ProTrialTests.testTheTrialNeverStartsAtNight`, `ShortcutTests.testNoPlayStartsTheTrial` |
| Antes de empezar, la hoja enseña el precio único, "with pro", "always free" y la nota | Sí, con un matiz | `ProSheet.column`: la cifra (`displayPrice`), `pro.una_vez` ("Once."), `pro.pie` ("One payment. Forever, on every iPhone you own."), `pro.con` ("with pro") y `pro.gratis` ("always free"). La nota es `pro.prueba.empezar.nota` (`ProSheetText.trialNoteKey`): "Lasts seven nights. Nothing is charged and no card is needed. When it ends, free stays free and your mixes are kept."; `ProSheetContentTests.testWhileTheTrialIsOnOfferTheFootSaysWhatItIs`. El matiz: lo que deja de estar disponible es la lista "with pro"; ninguna frase de la hoja lo dice con esas palabras ("Riesgo 3.1.1"). Si la tienda no responde, en el sitio del precio hay una raya (`pro.precio.cargando`) |
| Durante la prueba todo lo de Pro está abierto; de día la página dice "trial · 7 nights left" y tocarlo abre la hoja | Sí | `PurchaseManager.hasFullAccess`; `PageTrialWord` y `PageHeaderWord` (`pro.prueba.estado`, "trial · %lld nights left"; la última noche, `pro.prueba.estado.ultima`, "trial · final night"; el día en que se acaba no hay palabra); `ProTrialTests.testStartingTheTrialIsHeardAtOnce`, `ProTrialTests.testTheFigureFollowsTheNightsAndTheLastDayHasNone`, `PageTrialTests.testTheHeaderSaysNothingWhileNothingMayBeSold` |
| "Buy" está durante la prueba y después | Sí | `ProSheetContent.purchase` depende de `isPro`, no de la prueba; solo "Start the trial" desaparece una vez usada (`ProSheetContentTests.testTheTrialIsOfferedOnlyWhileItWasNeverUsed`) |
| Al terminar sigue lo gratuito y las mezclas se conservan; el final nunca llega mientras suena | Sí | `PurchaseManager.evaluateTrialAtSessionStart(now:)` es el único sitio donde una prueba en marcha pasa a terminada, y un registro que ya estaba agotado se lee como terminado al abrir la app (`PurchaseManager.init`); `ProTrialTests.testTheTrialEndsAtTheNextNightAndWritesNothing`, `ProTrialTests.testATrialThatEndsBetweenLaunchesStillSaysItsEnd`; `NightAndShortcutTests.testAMixLoadedDuringTheTrialIsMarkedStrippedWhenItEnds` y `HouseMixModelTests.testASavedMixWithProLayersLoadsTrimmed` (una mezcla con capas de Pro se conserva y suena sin ellas). La página lo dice una vez, de día, con `prueba.terminada` ("The trial is over. What you used is still here.") |
| Registro en el llavero; reinstalar no da otra prueba | Sí en código | `KeychainTrialStorage`: un elemento con `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, sin sincronizar, y `createTrial` nunca escribe encima de otro; `KeychainTrialStorageTests.testCreateNeverOverwrites` y `testItemStaysOnThisDevice`. Borrar la app y volver a instalarla en un iPhone no se ha hecho (condición 4) |

Dos cosas que el documento 11 quería en estas notas y que no están, porque el código no las sostiene:

- La cita de un test de autocorrelación a diez minutos como prueba de que el sonido no se repite (C53). Ese test no existe: en `SleepNoiseTests` solo hay una autocorrelación sobre los intervalos del trueno (`SleepNoiseTests/DSPGeneratorTests.swift`). Las notas dicen lo que sí es cierto: que no hay ficheros de audio.
- La explicación de "Qué sabemos" y del Diagnóstico (C54, C56). Las dos pantallas pasan a 1.1 (`docs/PLAN-SIMPLE-1.0.md` §4.4).

## Condiciones del dueño antes de pegar

1. **Política de privacidad dentro de la app.** La directriz 5.1.1(i) la pide en el campo de App Store Connect y también dentro de la app, y hoy la app no la lleva: es un arreglo de código y de catálogo que está sin hacer (`docs/agents/ESTADO.md`, "Política de privacidad dentro de la app"). Antes hace falta la política pública sin marcadores (`README.md`). Cuando la página "Lo que no hay" lleve el texto o un enlace, vuelve a las notas esta línea, bajo "NETWORK AND DATA", ajustada a lo que de verdad se construya: `- The privacy policy can be read in the app, under Settings › "What’s not here", and at the Privacy Policy URL of this listing.` Con ella el texto queda en 3937 de 4000.
2. **Family Sharing en App Store Connect.** Se activa en la página del producto antes de enviarlo (`compra-integrada.md`). Si no se activa, "with Family Sharing" sale de estas notas y de la nota de la compra; la hoja ya deja de decir "With your family" por su cuenta cuando la tienda responde que no se comparte.
3. **La compra de verdad.** Antes de enviar, en el sandbox y entre las 07:00 y las 21:00 del iPhone: seguir los dos caminos de las notas, comprar, restaurar en una instalación limpia, y ver el precio y el nombre que llegan de App Store Connect. Quedan también sin ver "Pedir para comprar", el reembolso y la compra que llega por la familia.
4. **En un iPhone.** Now Playing con la pantalla apagada; el final del temporizador (se funde, para y deja libre el audio para otra app); y que borrar la app y reinstalarla no ofrezca otra vez "Empezar la prueba · 7 noches".
5. **Las texturas de Pro que las notas nombran.** Dependen de la escucha del dueño (`docs/PLAN-SIMPLE-1.0.md` §4.3): la que no pase se quita del texto, de la hoja Pro y de la nota de la compra.
6. **Restaurar de noche.** "Restore purchase" solo está en la hoja Pro, así que entre las 21:00 y las 07:00 y en la página nocturna no hay forma de restaurar. Las notas dicen dónde está y a qué horas se abre la hoja; si el dueño decide poner una fila de restaurar en Ajustes (`docs/agents/ESTADO.md`, "Restaurar de noche"), se añade aquí.

## Riesgo 3.1.1

La directriz 3.1.1 describe la prueba gratuita de una app de pago único como un producto no consumible de precio cero y exige que, antes de empezar, la app diga con claridad tres cosas: cuánto dura, qué deja de estar disponible al acabar y qué cargo viene después (`docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md` §9.1). La prueba de 1.0 no es ese producto: es un registro en el llavero del iPhone (`NightTrial`). Las notas lo dicen una sola vez y en positivo ("kept on the iPhone and involves no purchase"), sin negar el mecanismo de la directriz.

Cómo responde la hoja Pro de este código a cada una de las tres:

| Lo que pide la directriz | Dónde está en la hoja | Cómo queda |
|---|---|---|
| Cuánto dura | El botón "Start the trial · 7 nights" y la nota, "Lasts seven nights." | Escrito, dos veces |
| Qué cargo viene después | La nota, "Nothing is charged and no card is needed."; arriba, la cifra con "Once."; el botón "Buy" con el precio | Escrito: ninguno, y comprar es un toque aparte |
| Qué deja de estar disponible al acabar | La lista "with pro" (texturas nombradas, "Tide", "Unlimited mixes", "With your family"); la nota solo dice lo que se queda, "free stays free and your mixes are kept" | Se deduce: ninguna frase lo dice |

Por eso las notas no afirman que la hoja diga lo que se pierde: dicen que lo de Pro está bajo "with pro" y citan la nota entera. Dos cosas quedan para el dueño:

- Si la nota (`pro.prueba.empezar.nota`) debe nombrar lo que deja de estar disponible. Es texto cerrado de la guía de copy §2.8 y un cambio de catálogo, fuera de este paquete. Con texto en tamaños de accesibilidad la nota pasa del pie al final de la columna, que se desplaza; sigue en la hoja.
- Si App Review pide que la prueba sea un producto gratuito de la tienda, la alternativa está propuesta en `docs/PLAN-SIMPLE-1.0.md` §10 y espera el sí del dueño; estas notas habría que reescribirlas.
