# AGENTS.md · SleepNoise

Instrucciones comunes para Cursor, Codex, Kimi y Claude Code. Tu encargo está en tu brief: `docs/briefs/<id>.md` o el issue de GitHub. Si el brief y este fichero chocan, manda el brief solo en lo que diga de forma expresa sobre ficheros que puedes tocar y formato de entrega. En todo lo demás manda este fichero. Si no puedes cumplir los dos, para: `ATASCO.md` en local, comentario en el PR en la nube. No preguntes en la sesión.

## 1. Qué es

- App iOS de ruido para dormir. SwiftUI, iOS 17 o superior, solo iPhone en 1.0. iPad es 1.2.
- El sonido se genera en el dispositivo con `AVAudioEngine`. No hay ficheros de audio.
- Sin dependencias, sin red propia, sin analítica y sin cuenta. StoreKit es lo único que habla con Apple.
- Pago único (Pro) con prueba local de 7 noches. Interfaz en inglés y en español.
- El proyecto de Xcode no está en Git. Lo genera XcodeGen desde `project.yml`.

## 2. Generar, compilar y probar

Desde la raíz del repo o de tu worktree, en un Mac con Xcode y XcodeGen:

```
xcodegen generate
xcodebuild test -project SleepNoise.xcodeproj -scheme SleepNoise -destination 'platform=iOS Simulator,name=iPhone 17'
```

- Solo compilar: el mismo comando con `build` o `build-for-testing`.
- Si existe `scripts/verify.sh`, es la única orden válida antes de entregar (regenera, compila, falla con cualquier aviso del log, tests y lint de copy): `SN_SIM='<tu simulador>' scripts/verify.sh`. Si espera más de 30 minutos una plaza de compilación, sale con 75: reintenta una vez.
- Repite `xcodegen generate` tras añadir, mover o borrar ficheros. Lo nuevo entra solo. No edites `SleepNoise.xcodeproj`.
- Los tests se alojan en la app: piden simulador y no se paralelizan.
- El Mac es compartido. Usa tu worktree (`~/wt/sleepnoise/<agente>-<id>`), `-derivedDataPath .build/DerivedData` y el simulador de tu brief.
- Sin Xcode (agente en la nube) tu puerta es la CI del PR. Solo lógica pura en ficheros nuevos: nada de App Intents, widgets, StoreKit ni vistas. Un push, abres el PR y terminas: el resultado de la CI te llega en un comentario.

## 3. Mapa de carpetas

```
SleepNoise/App        AppRoot (composición), Theme
SleepNoise/Audio      SleepAudioEngine, sesión, observador, Now Playing
SleepNoise/Audio/DSP  EngineCommand, ParameterMailbox, AtomicBridge, RenderState,
                      SoundGains, generadores y filtros (un fichero por pieza)
SleepNoise/Model      SoundID, AccessPolicy, TrialClock
SleepNoise/StoreKit   PurchaseManager
SleepNoise/Features   Mixer (MixerModel, MixerView), Timer, Breathing, Library, Paywall
SleepNoise/Resources  Localizable.xcstrings, Info.plist, entitlements, .storekit
SleepNoiseTests       XCTest, con Spectrum.swift para tests espectrales
docs/                 specs, planes y briefs. Solo lectura
scripts/              verify.sh y utilidades
```

Carpetas nuevas, solo si el brief lo dice.

## 4. Reglas del hilo de audio

El callback de render solo lee el buzón y ejecuta `processStereo`.

1. Sin heap, locks, `DispatchQueue` ni objetos con conteo de referencias. Captura punteros crudos, nunca `self`.
2. `RenderState`, `EngineCommand` y `BreathParameters` son POD: `Float`, enteros y structs de eso. Sin `Array`, `String`, clases ni closures.
3. Un solo escritor del buzón: el hilo principal. El lector no espera ni reintenta. Las barreras de `AtomicBridge` no se tocan.
4. El buzón guarda solo el último comando. No hay cola. Un evento es un contador (`envelopeGeneration`, `epoch`). `rampSamples < 0` significa no tocar.
5. Duraciones y fase en muestras enteras. Ningún parámetro entra en escalón: todo se suaviza.
6. Coeficientes (`expf`) en `prepare()`. `prepare()` y `resetForFreshStart()` solo con el motor parado. El hilo principal no lee `state` con el motor en marcha.
7. Salida acotada: `softClip`, NaN a silencio, `flushDenormal`. Ganancia cero: el generador se salta.
8. Cambiar la frecuencia de muestreo conserva la fracción del ciclo. Reconstruir el grafo no reinicia un fundido: una rampa en curso conserva la fracción recorrida y la duración restante en segundos.
9. Un campo nuevo en `EngineCommand` toca cuatro sitios: el struct, `RenderState`, `SleepAudioEngine.publishCurrent` y el test de desgarro (`SeqlockTearTests`, por bytes). Un método público nuevo del motor toca además el protocolo y el motor de pega (`AudioEngineControlling.swift` y `FakeAudioEngine.swift`).
10. Una textura es un struct puro en su fichero, con `init(seed:sampleRate:)`, `prepare(sampleRate:)` y `next()`, más sus tests. No la cablees tú.

## 5. Zonas calientes: un solo escritor

Un escritor a la vez. No toques ninguno si tu brief no lo lista en "Ficheros que puedes tocar".

- Contrato de audio (escritor único: Codex): `EngineCommand.swift`, `RenderState.swift`, `ParameterMailbox.swift`, `AtomicBridge.*`, `SleepAudioEngine.swift`, test de desgarro, `XorShift32.swift` y `DSPGeneratorTests.swift`. El diagnóstico (D-07) no entra aquí: implementa `DiagnosticsSink` en ficheros nuevos.
- `AudioEngineControlling.swift` y `FakeAudioEngine.swift`: los crea F-01. Después los toca quien añade un método público al motor, en el mismo PR.
- `MixerModel.swift` y sus extensiones, `MixerView.swift`, `SoundRowView.swift`.
- `SoundID.swift`, `SoundGains.swift`, `ChannelGenerators`.
- `AccessPolicy.swift`, `PolicyTests.swift`, `PurchaseManager.swift`, `TrialClock.swift`, `SleepTimerView.swift`.
- `Model/NightWindow.swift`: `NightWindow`, `SaleGate` y `TipGate` se declaran solo ahí.
- `AppRoot.swift`, `Theme.swift`, `PageView.swift`, `SystemGallery.swift`.
- `Localizable.xcstrings`. Hasta L-01 solo lo editan R-01, R-02 y L-01, que tienen el turno. Desde L-01 no se edita a mano: claves en `strings/<id>.json` (en y es) y `scripts/strings-merge.sh`.
- Solo del integrador (Claude Code): `project.yml`, `Info.plist`, entitlements, `scripts/verify.sh`, `.github/` y este fichero.

Si necesitas un cambio en zona ajena, pídelo.

## 6. Reglas de producto que no se negocian

1. **Nada se vende de noche.** Entre las 21:00 y las 07:00 ninguna superficie muestra prueba, hoja Pro, tip ni reseña. La ventana es una sola constante (`NightWindow`).
2. **Los números que ve el usuario salen del código**: `displayPrice`, `displayName`, cuenta de capas, estado de la prueba. Ninguna cadena lleva una cifra de precio ni un recuento de texturas.
3. **Sin afirmaciones médicas.** La app no trata, no mide y no promete ningún efecto sobre el sueño ni la salud. Listas prohibidas: `docs/design/10-GUIA-DE-COPY.md` §0.4 y §0.5. Entre otras: insomnio, ansiedad, terapia, clínico, relajante, inteligente, mejora, desbloquear, premium, oferta, exclamaciones y emojis. También suscripción, salvo en el pie obligatorio "Sin suscripción. Sin cuenta. Sin rastreo." Las excepciones admitidas están anotadas por clave en 10 §0.5 y no se añaden otras.
4. **Vocabulario de la reconciliación §3.** Se usa: capa, textura, mezcla, Esta noche, mezcla de la casa, Marea, Descenso, Hasta dormirme, Manto, Madrugada, Noche, Horizonte, Timbre. No se graba: Escudo, Tu instrumento, envolvente, chip, ranura, perfil de entorno, Lluvia fina, Tormenta lejana, v1/v2, Siesta (hasta 1.1), Amanecer (hasta 2.0).
5. Ningún candado. La degradación tras la prueba no escribe en disco. Madrugada no abre la hoja Pro. La app no toca el volumen del sistema.
6. El reparto gratis y Pro es el de la reconciliación §4. `AccessPolicy` lo implementa desde P-03b. Si el código y §4 difieren, manda §4.
7. Texturas: cinco libres (blanco, rosa, marrón, lluvia y viento) y seis Pro. La lista libre solo crece.
8. Temporizador entero libre. Ningún modo ni duración pide Pro y la palabra pro no aparece en el temporizador.
9. Mezclas guardadas: tres gratis, sin límite con Pro. Tope de seis capas a la vez, para todos.
10. La prueba de 7 noches solo empieza con el botón "Empezar la prueba · 7 noches" de la hoja Pro. Nunca en `play()`, ni al lanzar, ni desde un intent. Su estado vive en Keychain.
11. Marea es Pro. Solo suena para todos dentro de Madrugada, con receta fija.
12. Sin iCloud en 1.0: nada de `NSUbiquitousKeyValueStore`, CloudKit ni entitlements de iCloud. Sin `requestReview`.
13. Solo oscura, con `preferredColorScheme(.dark)` en la raíz. La app no activa la sesión de audio al lanzar.
14. ActivityKit y Live Activity solo dentro del paquete D-04, que existe solo en escenario A.

## 7. Convenciones

- Rama `agente/id-slug` en minúsculas, por ejemplo `codex/r-01-pr-a-base`. Base: `main` actualizado, salvo que el brief diga otra.
- Un paquete, una rama, un PR. No amplíes el alcance.
- Commits pequeños, en español: `<tipo>(<id>): <qué cambia>`. Tipos: feat, fix, test, refactor, docs, chore.
- Nunca push a `main`. Nunca fusiones `main` en tu rama ni hagas rebase. Los conflictos los resuelve el integrador.
- Codex y Kimi: commits en tu worktree, sin `git push` ni `gh`. El integrador abre el PR. Si no puedes hacer commit, deja los cambios sin commit y termina con `git status --short`. Cursor: push solo de tu rama y PR con la plantilla.
- No toques `docs/` salvo que el brief lo pida.
- No añadas dependencias (SPM, CocoaPods, binarios) ni ficheros de audio.
- No añadas red (`URLSession`), analítica ni SDK de terceros. Tampoco CoreMotion ni HealthKit.
- Sin credenciales, cuentas ni firma. No cambies ajustes del repo.
- No silencies avisos ni desactives o debilites tests para pasar.

## 8. Definición de hecho

1. `scripts/verify.sh` devuelve 0 en tu worktree, sin avisos. Los paquetes que solo tocan `docs/` no ejecutan `verify.sh`: su puerta son los greps del brief.
2. Cada línea del criterio de aceptación tiene un test con nombre o un grep.
3. El diff solo toca los ficheros de la lista cerrada del brief.
4. Cadenas nuevas en los dos idiomas, con lint de copy en verde y vocabulario de §6.
5. Visto bueno escrito del revisor cruzado en el PR.
6. La CI está en verde en el PR.
7. La entrega lista lo no verificado: dispositivo, audio real, compra.

En audio, además: el test de desgarro por bytes sigue en verde, `RenderState` sigue POD y la mediana de `scripts/verify.sh --bench` no sube más del 10 % sobre `docs/research/bench/BASELINE.md`.

## 9. Specs y cuál manda

- Cabecera: `docs/PLAN-MAESTRO-2026-11-16.md`. Reparto: `docs/PLAN-DESARROLLO-AGENTES-2026-11-16.md`.
- Árbitro: `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md` (§2 fichas C01 a C67, §3 vocabulario, §4 gratis y Pro, §5 alcance 1.0).
- Diseño: `docs/design/03` (dirección) y `04` a `11`. Funciones: `docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md`.

Si dos documentos chocan, manda la reconciliación. Su precedencia (§1):

1. Carácter visual, tokens, componentes y pantallas: la dirección (03 y 04 a 11).
2. Alcance, versión y calendario: el plan.
3. Gratis y Pro: `AccessPolicy.swift`, con los cambios escritos en la reconciliación.
4. Vocabulario: la guía de copy (10), fijada en §3.
5. Hilo de audio: el código.
6. Nada se vende de noche y los números son los del código. Superan a cualquier ficha.

Si una spec (05, 07, 09) aún no tiene su sección 12, manda la ficha C que cite tu brief.

## 10. Ante una duda

- No inventes una API de Apple, una cadena ni una decisión de producto o diseño.
- En la nube, para y deja un comentario en el PR. En local, escribe `ATASCO.md` en la raíz del worktree: error, lo probado e hipótesis. No preguntes en la sesión: en modo no interactivo nadie responde.
- Para tras dos intentos fallidos sobre el mismo error. No amplíes el alcance.
- Lo que no puedas comprobar se declara no verificado.
