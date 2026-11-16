# AGENTS.md · SleepNoise

Instrucciones para los dos agentes de 1.0: **Claude Code** (local, con Xcode, integrador) y **Cursor** (nube, sin Xcode). Tu encargo es tu brief: `docs/briefs/<id>.md`. El brief manda en ficheros que puedes tocar y formato de entrega; en lo demás manda este fichero.

## 1. Qué es

App iOS de sonidos para dormir. SwiftUI, iOS 17 o posterior, solo iPhone, inglés y español. El sonido se genera en el dispositivo con `AVAudioEngine`: no hay ficheros de audio. Pago único (Pro) con prueba local. El proyecto de Xcode no está en Git: lo genera XcodeGen desde `project.yml`.

## 2. Compilar y probar

```
SN_SIM='<tu simulador>' scripts/verify.sh
```

- Es la única puerta. Regenera el proyecto, compila en limpio, pasa los tests y termina con `VERIFY OK · N tests` o `VERIFY FAIL · motivo`. Log en `.build/verify.log`.
- Falla con error de compilación, test rojo, cualquier aviso del compilador o de metadatos de App Intents, o cero tests.
- `--fast` no limpia: sirve para iterar, no como puerta. `--ci` elige simulador solo (lo usa GitHub Actions).
- `SN_SIM` por defecto es `iPhone 17`. En un Mac compartido, cada worktree con su simulador.
- Ficheros nuevos entran solos al regenerar. No edites `SleepNoise.xcodeproj`.
- Avisos tolerados: `scripts/verify-known-warnings.txt`. No añadas ninguno para pasar.
- Sin Xcode, tu única prueba es la CI del PR (`.github/workflows/ci.yml`, check `verify`).

## 3. Mapa

```
SleepNoise/App        AppRoot, Theme
SleepNoise/Audio      SleepAudioEngine, sesión, observador, Now Playing
SleepNoise/Audio/DSP  EngineCommand, ParameterMailbox, AtomicBridge, RenderState,
                      SoundGains, generadores y filtros
SleepNoise/Model      SoundID, AccessPolicy, TrialClock
SleepNoise/StoreKit   PurchaseManager
SleepNoise/Features   Mixer, Timer, Breathing, Library, Paywall
SleepNoise/Resources  Localizable.xcstrings, Info.plist, entitlements, .storekit
SleepNoiseTests       XCTest (Spectrum.swift para tests espectrales)
```

## 4. Hilo de audio

El callback de render solo lee el buzón y ejecuta `RenderState.processStereo`.

1. Sin heap, locks, colas ni objetos con conteo de referencias. Captura punteros crudos, nunca `self`.
2. `EngineCommand`, `RenderState` y `BreathParameters` son POD: `Float`, enteros y structs de eso. Sin `Array`, `String`, clases ni closures.
3. Un solo escritor del buzón, el hilo principal. El lector no espera ni reintenta: si la secuencia se movió, conserva el comando anterior. Las barreras de `AtomicBridge.c` no se tocan.
4. El buzón guarda solo el último comando; no hay cola. Un evento es un contador (`envelopeGeneration`, `epoch`). `rampSamples < 0` significa no tocar el fundido.
5. Duraciones en muestras enteras. Ningún parámetro entra en escalón: todo se suaviza.
6. Coeficientes (`expf`) en `prepare()`. `prepare()` y `resetForFreshStart()` solo con el motor parado.
7. Salida acotada: `softClip`, NaN a silencio, `flushDenormal`. Con ganancia cero el generador se salta.
8. Reconstruir el grafo o cambiar la frecuencia de muestreo no reinicia un fundido en curso.
9. Un campo nuevo en `EngineCommand` toca cuatro sitios: el struct, `RenderState`, `SleepAudioEngine.publishCurrent` y el test de desgarro (`ParameterMailboxTests.testConcurrentReadsNeverTear`), que debe escribirlo y comprobarlo.
10. Una textura es un struct puro en su fichero, con `init(seed:)`, `prepare(sampleRate:)` y `next()`, más sus tests.

**Un solo escritor en `SleepNoise/Audio/`.** En 1.0 es Claude, y nunca con dos ramas de audio abiertas a la vez. Cursor no toca esa carpeta.

## 5. Producto y diseño: no se negocia

1. **De noche no se vende.** Entre las 21:00 y las 07:00 (`NightWindow`, una sola constante) no hay hoja Pro, prueba, tip ni reseña.
2. **Los números salen del código**: `displayPrice`, `displayName`, cuenta de capas, estado de la prueba. Ninguna cadena lleva una cifra de precio ni un recuento de texturas.
3. **Sin afirmaciones médicas.** La app no trata, no mide y no promete nada sobre el sueño ni la salud.
4. **Lista negra de palabras** (`docs/design/10-GUIA-DE-COPY.md` §0.4 y §0.5): insomnio, ansiedad, terapia, clínico, mejora el sueño, relajante, inteligente, IA, premium, vitalicio, desbloquear, oferta, timer, mix y preset en español, exclamaciones y emojis. "Suscripción" solo en "Sin suscripción. Sin cuenta. Sin rastreo."
5. **Gratis siempre**: blanco, rosa, marrón, lluvia y viento; el temporizador entero; tres mezclas guardadas. **Pro**: océano, ventilador, trueno, hoguera, arroyo, cabina, Marea y mezclas sin límite. La lista gratis solo crece.
6. **Precio**: 29,99 € una vez, un solo `displayPrice`, Family Sharing.
7. **Prueba de 7 noches** local: empieza solo con "Empezar la prueba · 7 noches" en la hoja Pro, nunca con Play ni desde un intent. Estado en Keychain. Se evalúa solo al arrancar una sesión.
8. **Mezclas de la casa**: "Rosa y lluvia", "Mar y viento", "Marrón y hoguera", "Pared". Las que llevan Pro se cargan recortadas y no abren la hoja Pro. Madrugada tampoco la abre.
9. **Grafito** (documento 03): solo modo oscuro; hojas `#1C1C1E`, nunca negro sobre negro; una familia, SF Pro; un acento, Índice `#F0C020`, que solo existe mientras suena o bajo el dedo y nunca es relleno; un único elemento de color por pantalla; nada cambia de posición, solo de longitud, opacidad o contenido.
10. **Fuera para siempre**: candados, badges, cápsulas, degradados, sombras, luna y estrellas, iconos de sonido.
11. Sin red (`URLSession`), analítica, cuenta, iCloud, `requestReview`, SDK de terceros ni dependencias. La app no toca el volumen del sistema.
12. Vocabulario: reconciliación §3.

## 6. Ramas, commits y PR

- Rama `agente/id-slug` desde `main` al día: `claude/s-04-tokens`, `cursor/s-03a-logica-pura`.
- Un paquete, una rama, un PR. Máximo dos PR abiertos: uno de Claude y uno de Cursor.
- Commits pequeños, en inglés y en imperativo, como los de `git log`.
- Nunca push a `main`. Todo entra por PR con la plantilla, `verify.sh` y CI en verde, y revisión del otro agente. Fusiona Claude.
- Repo público: sin claves, datos personales ni rutas locales en commits, PR o issues.
- No desactives ni debilites tests para pasar.

## 7. Cursor

- Hace lógica pura en **ficheros nuevos** con tests en ficheros nuevos, textos de la ficha y documentación. Solo `import Foundation` (o `Security` si el brief lo pide).
- No toca: `SleepNoise/Audio/`, `MixerModel.swift`, vistas (`*View.swift`, `AppRoot`, `Theme`), `PurchaseManager.swift`, `project.yml`, `Info.plist`, entitlements, `Localizable.xcstrings`, `scripts/`, `.github/` ni este fichero. Tampoco App Intents, StoreKit ni widgets. Un fichero existente solo si el brief lo lista.
- Un push, abre el PR y termina. La CI es su compilador: Claude la lee y revisa. Si la CI falla dos veces, el paquete pasa a Claude.
- En los tests, nada de `Date()`, `Calendar.current`, `TimeZone.current` ni `Locale.current`: todo inyectado.

## 8. Qué documento manda

1. `docs/PLAN-SIMPLE-1.0.md`: **qué y cuándo** (alcance, paquetes, calendario).
2. `docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md`: **cómo** (carácter, tokens, componentes, copy).
3. `docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md`: lista única de decisiones (§2 fichas C01 a C67, §3 vocabulario, §4 gratis y Pro).
4. Las specs 05, 07 y 09 no están reconciliadas: si contradicen a la reconciliación, manda la reconciliación.
5. Hilo de audio: manda el código.

Estado de los paquetes: `docs/agents/ESTADO.md`. El plan anterior y los cuadernos de `docs/agents/` son solo referencia.

## 9. Ante una duda

- No inventes una API de Apple, una cadena ni una decisión de producto o diseño.
- Para tras dos intentos fallidos sobre el mismo error y dilo en el PR. No amplíes el alcance.
- Lo que no puedas comprobar (dispositivo, audio real, compra) se declara no verificado.
