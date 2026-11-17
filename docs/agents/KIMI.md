> **Aviso (16-11-2026):** sustituido para 1.0 por `docs/PLAN-SIMPLE-1.0.md`. Se conserva como referencia.

# SleepNoise 1.0 · Cuaderno de trabajo de Kimi

Fecha: 16-11-2026. Acompaña a `docs/PLAN-DESARROLLO-AGENTES-2026-11-16.md`: si algo de aquí lo contradice, manda el plan. No se ejecutó Kimi ni se compiló nada. [V] comprobado hoy. [INF] inferencia. [SV] sin verificar.

Kimi lleva 19 paquetes: diez con brief en la sección 3 (oleadas 0 a 2) y nueve en la tabla de la sección 4. Nueve están en la ruta crítica (F-02, DS-01, DS-03, S-01, X-01, X-02, X-03, L-01 y C-01): tienen plazo de corte de tres días laborables de "listo" a "aprobado" (plan §2.2, R7).

---

## 1. Cómo se usa Kimi en este proyecto

### 1.1 Entorno

- Corre en el Mac del dueño, con Xcode 26.6, XcodeGen y simuladores con iOS 26.5 [V]. Puede lanzar `xcodebuild` [INF, falta la prueba de humo].
- `kimi` 1.42.0 en `~/.local/bin` es la CLI antigua, archivada por su fabricante [V]. Su configuración no tiene proveedor ni modelo: es probable que hoy no responda [INF].
- Kimi Code.app 1.3.3 tiene sesión iniciada [V]. La CLI nueva no está instalada: hacerlo es decisión del dueño.
- Enviar código del repo al servicio de Kimi es decisión del dueño, el día 1. Antes no se lanza nada.
- Simulador propio: **iPhone 17e**. Worktree propio: `~/wt/sleepnoise/kimi-<id>`, con DerivedData dentro (`.build/DerivedData`).
- Modelo por defecto de la app: `k3.1-pro-highspeed`, que consume el doble [V]. Propuesta [INF]: K2.7 Code Highspeed para lo mecánico y un modelo de un millón de tokens para specs y catálogo. El nombre exacto para `-m` se confirma con `kimi info` [SV].
- Concurrencia: 2 agentes en los planes Plus y Pro, 4 en Max y Ultra [V web]. Plan contratado sin comprobar [SV]: hasta saberlo, dos paquetes de Kimi a la vez, contando los de solo documentos. Solo uno de ellos compila (plan §3.2).

### 1.2 Fichero de instrucciones

`AGENTS.md` en la raíz del repo. Lo leen la CLI antigua y la nueva [V web] y es la única fuente. Las dos CLI leen además otros ficheros (`.kimi/AGENTS.md`, `.kimi-code/AGENTS.md`, `~/.kimi-code/AGENTS.md`, `~/.agents/AGENTS.md`) sin precedencia documentada [SV]. Por eso **no se crea ninguno**, y si existe uno global se revisa antes de la prueba de humo.

El brief no es un fichero de instrucciones: vive en `docs/briefs/<id>.md` y se pasa como prompt. Los de la sección 3 son el texto que Claude copia a esa ruta con el `<sha>` de la base.

### 1.3 Pasar una tarea, paso a paso

Lo hace Claude. Kimi no crea worktrees, no hace push y no abre PR.

```
# 1. Worktree y rama (Claude)
cd ~/sleep-noise-ios && git fetch origin
git worktree add ~/wt/sleepnoise/kimi-f-02 -b kimi/f-02-partir-tests origin/main

# 2. Kimi sin interacción, con el brief como prompt
cd ~/wt/sleepnoise/kimi-f-02
kimi --print --quiet -w "$PWD" -p "$(cat docs/briefs/F-02.md)" > ~/wt/sleepnoise/kimi-f-02.salida.txt
echo "salida=$?"  # 0 bien, 1 fallo permanente, 75 transitorio (un reintento)

# 3. Antes de revisar (Claude)
git status --short && git diff --stat origin/main...HEAD
```

- `--print` no pregunta y aprueba todas las herramientas [V]. `--quiet` devuelve solo el mensaje final [V]. Juntas, se confirman con `kimi --help` [SV].
- Con la CLI nueva: `kimi -p "<brief>"`, con `--yolo` para no preguntar [V web, SV aquí].
- Si el turno se corta (1.000 pasos o 3.600 s [V]), Claude relanza en el mismo worktree con `-C` y "Continúa el brief donde lo dejaste" [SV].
- Antes de lanzar, Claude comprueba que el brief y cada ruta de "Lee antes" existen en `origin/main` (`git cat-file -e origin/main:<ruta>`). El brief se lee desde dentro del worktree, que nace de `origin/main`.
- Tope de reloj de Claude por lanzamiento: 90 minutos si el paquete es de hasta 2 días, 3 horas el resto. Una sesión que acaba sin commits nuevos, sin mensaje final y sin `ATASCO.md` cuenta como una ronda (plan §3.7).
- El modo print descarta solas las preguntas al usuario [V, `kimi --help`]. Kimi no pregunta en la sesión: si no puede seguir, escribe `ATASCO.md`.

**Con Kimi Code.app, si la CLI no responde** [SV, interfaz sin recorrer]: abrir como carpeta de trabajo el worktree, nunca el repo principal. Elegir modelo. Pegar el brief entero como primer mensaje. Si pide aprobación, se aprueba lo de dentro del worktree y `scripts/verify.sh`. Nada de red ni `git push`.

**Prueba de humo, día 1** (plan §9): `kimi --print -p "Responde solo: OK"`. Después, en un worktree sobre la rama de I-01, `SN_SIM='iPhone 17e' scripts/verify.sh` y un commit de prueba (`HUMO.md` en la raíz, `git add` y `git commit`), para comprobar que puede hacer commit en un worktree enlazado. Si la primera falla, la CLI antigua queda descartada.

### 1.4 Después de la entrega

Claude comprueba que el diff solo toca la lista cerrada, repite `scripts/verify.sh`, hace push y abre el PR con el mensaje final de Kimi. Revisa el agente que nombra el brief, con la lista de la sección 5. Dos rondas como máximo: después el paquete pasa a Codex (plan §3.7). Si Codex era su revisor, lo revisa Claude (plan §2.3).

---

## 2. Reglas propias de Kimi

Van además de `AGENTS.md`. Las reglas 1 a 5 salen del modo print, que aprueba todo: el aislamiento lo pone el worktree. Las 6 a 9, de las zonas calientes. Las 10 a 13, de su fiabilidad sin medir en API de Apple [INF]. Las 14 a 16, del Mac compartido. Las 17 a 19, del texto y del atasco.

1. Trabaja solo dentro de su worktree. Nunca en el repo principal ni en otro worktree.
2. De Git solo usa `add`, `commit`, `mv`, `rm`, `status`, `diff`, `log` y `show`. Nada de `push`, `gh`, `fetch`, `merge` ni `rebase`.
3. No instala nada. No toca `~/.kimi`, `~/.kimi-code`, `~/.codex` ni ajustes del sistema.
4. No usa la red, salvo leer documentación oficial de Apple. No envía contenido del repo a otro servicio.
5. Lista cerrada de ficheros. Lo que no está en ella no se toca, aunque el arreglo parezca obvio: se anota.
6. Nunca toca `project.yml`, `Info.plist`, los entitlements ni el `.xcodeproj`.
7. Nunca toca el contrato de audio (`EngineCommand`, `RenderState`, `ParameterMailbox`, `AtomicBridge`, `SleepAudioEngine`), ni `SoundID` ni `SoundGains`. Tampoco en D-07: el anillo implementa el protocolo `DiagnosticsSink` que deja B-05b, en ficheros nuevos fuera de `SleepNoise/Audio/`.
8. `Localizable.xcstrings` solo lo edita en L-01. Después, las cadenas van en `strings/<id>.json` y entran con `scripts/strings-merge.sh`.
9. `SystemGallery.swift` y `PageView.swift` son de Claude. Cada componente trae su galería aparte.
10. No inventa API: si duda de una firma, la busca en el SDK. Objetivo iOS 17: nada posterior sin `#available`, y ningún `#available(iOS 26` nuevo.
11. No calla al compilador: nada de `@unchecked Sendable`, `nonisolated(unsafe)`, `try!` ni `as!` nuevos.
12. No debilita la prueba: no borra ni salta tests, no añade `XCTSkip`, no relaja umbrales.
13. Nunca dice que algo pasa sin pegar la salida de `scripts/verify.sh`.
14. Una compilación a la vez, siempre con `SN_SIM='iPhone 17e' scripts/verify.sh`. No arranca ni borra otros simuladores.
15. `scripts/verify.sh` puede tardar diez minutos. Va en el turno principal, no en un subagente de fondo, que tiene un tope de 900 s [V, INF].
16. Commits pequeños y frecuentes, por si el turno se corta.
17. Documentación en español, frases cortas, sin rayas largas como inciso, sin afirmaciones médicas, sin nombres de personas ni correos. Vocabulario de la reconciliación §3. Comentarios de código en inglés.
18. Cadenas: inglés como fuente y español. `es-419` solo en las entradas de 10 §0.3. Sin cifras de precio ni recuento de texturas.
19. Atasco: dos intentos sobre el mismo error y para. Escribe `ATASCO.md` en la raíz del worktree, sin commit, y no amplía el alcance. No pregunta en la sesión. Si el brief y `AGENTS.md` chocan, rige la cabecera de `AGENTS.md`.

---

## 3. Briefs listos para pegar (oleadas 0, 1 y 2)

Van en español, como las specs y sus criterios [INF]. Los números de línea son de hoy: si se han movido, se busca por título. Lo que va entre `<` y `>` lo pone Claude al emitir.

### F-02 (oleada 0)

````text
# BRIEF F-02 · Partir BreathingTests.swift en un fichero por clase
Agente: Kimi · Revisor: Codex
Rama: kimi/f-02-partir-tests · Base: main@<sha> (con I-01 fusionado)
Worktree: ~/wt/sleepnoise/kimi-f-02 · Simulador: iPhone 17e

## Objetivo
SleepNoiseTests/BreathingTests.swift mezcla seis clases sin relación y tres paquetes
añadirán tests ahí. Pártelo en un fichero por clase. Mismos 49 tests, cero cambios
de lógica. Es la prueba de humo de Kimi con compilación.

## Lee antes, y nada más
- AGENTS.md
- SleepNoiseTests/BreathingTests.swift, entero

## Ficheros que puedes tocar (todos en la raíz de SleepNoiseTests/)
BreathingTests.swift (se borra con git rm). Nuevos: BreathCurveTests.swift,
BreathingRenderTests.swift, EngineCommandEnvelopeTests.swift,
BreathingGuideControllerTests.swift, TrialClockTests.swift, CopyLintTests.swift.
Prohibido todo lo demás. En especial SleepNoise/, project.yml, Spectrum.swift,
DSPGeneratorTests.swift y PolicyTests.swift (otro agente trabaja en ellos).

## Pasos
1. Las clases empiezan hoy en las líneas 4, 41, 328, 355, 493 y 589.
2. Mueve cada clase tal cual a un fichero con su nombre, con su comentario de
   documentación y sus atributos (@MainActor en la de la guía). Cabecera de cada
   fichero: import XCTest y @testable import SleepNoise.
3. No renombres clases ni tests, no reordenes métodos, no cambies ningún literal.
   TrialClockTests conserva su test de PurchaseManager.
4. CopyLintTests localiza el catálogo desde #filePath subiendo dos niveles. Por eso
   los ficheros nuevos van en la raíz de SleepNoiseTests/, sin subcarpetas.
5. Un solo commit: "test(F-02): parte BreathingTests.swift en un fichero por clase".

## Criterio de aceptación
N="BreathCurveTests BreathingRenderTests EngineCommandEnvelopeTests BreathingGuideControllerTests TrialClockTests CopyLintTests"
SN_SIM='iPhone 17e' scripts/verify.sh  # sale 0: 49 tests, 0 fallos, 0 avisos
test ! -e SleepNoiseTests/BreathingTests.swift && echo borrado
for n in $N; do cat SleepNoiseTests/$n.swift; done | grep -c 'func test'  # 28
diff <(git show origin/main:SleepNoiseTests/BreathingTests.swift | grep -v '^import \|^@testable \|^$') \
     <(for n in $N; do cat SleepNoiseTests/$n.swift; done | grep -v '^import \|^@testable \|^$')  # vacío
git diff --stat origin/main...HEAD  # 7 ficheros: 1 borrado, 6 nuevos

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: F-02 · Parte BreathingTests.swift en un fichero por clase
- Descripción: qué se movió a dónde, en seis líneas. Ningún cambio de lógica.
- Evidencias: últimas 30 líneas de verify.sh y la salida de los otros cuatro comandos.
- No verificado en dispositivo: no aplica.

## Si te atascas
Dos intentos sobre el mismo error y para. ATASCO.md en la raíz del worktree, sin
commit: error literal, lo probado e hipótesis. No amplíes el alcance.
````

### X-01 (oleada 0)

````text
# BRIEF X-01 · Aplicar la reconciliación a 05-PAGINA-Y-CAPAS
Agente: Kimi · Revisor: Claude
Rama: kimi/x-01-spec-05 · Base: main@<sha> (con I-03 fusionado y docs/ publicado)
Worktree: ~/wt/sleepnoise/kimi-x-01 · Simulador: ninguno, no se compila

## Objetivo
La spec 05 es el criterio de aceptación de la página principal y de la hoja Capas.
Tiene que decir lo mismo que la reconciliación. Trasladas decisiones ya tomadas.
No tomas ninguna.

## Lee antes, y nada más
R = docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md
- AGENTS.md
- R §1 (líneas 32-43), §3 (980-1031) y §4 (1033-1065)
- R, fichas C06, C18, C19, C20, C21, C23, C29, C40, C51 y C58
- docs/design/06-MAREA.md §12 (línea 703 en adelante): es el modelo del registro
- docs/design/10-GUIA-DE-COPY.md §0.5 (118-127): las dos listas vetadas
- docs/design/05-PAGINA-Y-CAPAS.md, entero
Dato de hoy: 05 ya cita fichas en más de 150 sitios. Casi todo es comprobar y
registrar.

## Ficheros que puedes tocar
docs/design/05-PAGINA-Y-CAPAS.md
Prohibido todo lo demás, incluido docs/PLAN-MAESTRO-2026-11-16.md. Una contradicción
con otra spec se anota en la sección 12. La otra spec no se edita.

## Pasos
1. grep -n '05-PAGINA' R: hoy da 11 líneas en 10 fichas. El paquete original decía
   9. Manda el grep: se registran todas.
2. Comprueba cada delta en 05. Si falta, aplícalo con las palabras de la decisión.
3. Pasada de vocabulario (R §3) y de reparto (R §4). Las cadenas de la tabla 5e
   quedan idénticas a 10 §5e: si difieren, gana 10. No tocas el catálogo.
4. Añade al final "## 12. Reconciliación aplicada (16-11-2026)" con la forma de 06 §12
   y una línea por delta: aplicado, ya estaba (comprobado) o rechazado con razón.
   05 no tiene secciones 10 ni 11: la nueva se llama 12 igual.
5. Texto nuevo en español, frases cortas, sin rayas largas como inciso. No
   reescribas lo que no cambia.

## Criterio de aceptación
F=docs/design/05-PAGINA-Y-CAPAS.md
cuerpo() { sed '/^## 12\./,$d' "$F" | awk '/^#+ /{h=$0} {print h " @@ " $0}' | sed 's/`[^`]*`//g'; }
cuerpo | grep -i -w -E 'ranuras?|chips?|envolventes?|escudo|v1|v2' \
  | grep -v -i -E '^## 8\.|formato v2'  # sin salida
for c in C06 C18 C19 C20 C21 C23 C29 C40 C51 C58; do
  sed -n '/^## 12\./,$p' "$F" | grep -q "$c" || echo "falta $c"; done  # sin salida
git diff --stat origin/main...HEAD  # 1 fichero
Lint de 10 §0.5 a mano (scripts/lint-copy.sh nace en L-01): lista ES en un fichero
fuera del repo y  cuerpo | grep -n -i -w -E -f <fichero>  → 0 fuera de los falsos
positivos que §0.5 admite. cuerpo quita la sección 12 y el código, y pone delante de
cada línea el título de su apartado. Se admiten "formato v2" (el formato de mezcla,
C20) y la sección 8. Una línea que cite la lista vetada se enumera en la entrega.

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: X-01 · Reconciliación aplicada a la spec 05
- Descripción: tabla ficha → estado → sección de 05. Contradicciones encontradas.
- Evidencias: salida de los tres comandos y del lint, con el patrón usado.
- No verificado: nada. No se ejecuta verify.sh.

## Si te atascas
Si una ficha admite dos lecturas, no elijas: ATASCO.md en la raíz del worktree, sin
commit, con las dos. Sigue con las demás.
````

### X-02 (oleada 0)

````text
# BRIEF X-02 · Aplicar la reconciliación a 07-TEMPORIZADOR-NOCHE-MADRUGADA
Agente: Kimi · Revisor: Claude
Rama: kimi/x-02-spec-07 · Base: main@<sha> (con I-03 fusionado)
Worktree: ~/wt/sleepnoise/kimi-x-02 · Simulador: ninguno, no se compila

## Objetivo
07 es el criterio de B-01 a B-05. Hoy no cita ninguna ficha y dice "Escudo" 46
veces. Deja escrito lo decidido: temporizador entero libre, Manto por hora, Noche
que no crea temporizador, Mantener encendida, Madrugada con Marea para todos y las
reglas de interrupciones. No decides nada.

## Lee antes, y nada más
R = docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md
- AGENTS.md
- R §1 (32-43), §3 (980-1031), §4 (1033-1065)
- R, las 14 fichas con delta para 07: C03, C05, C11, C22, C27, C30, C31, C36, C46,
  C47, C48, C51, C60, C65. C49 es de 09.
- docs/design/06-MAREA.md §12 (703 en adelante): modelo del registro
- docs/design/10-GUIA-DE-COPY.md §0.5 (118-127) y §5e.6 a §5e.8 (825-878)
- docs/design/07-TEMPORIZADOR-NOCHE-MADRUGADA.md, entero

## Ficheros que puedes tocar
docs/design/07-TEMPORIZADOR-NOCHE-MADRUGADA.md
Prohibido todo lo demás, incluido docs/PLAN-MAESTRO-2026-11-16.md.

## Pasos
1. grep -n '07-TEMPORIZADOR' R: 14 líneas, una por ficha. Aplica cada delta con las
   palabras de la decisión. Empieza por C11 (Escudo → Manto) y C30 (Siesta a 1.1).
2. Quita todo estado "pro" de duraciones y de Manto (C03), también en los flujos
   del día 8 de la sección 4.
3. Alinea la tabla 5(e) con 10 §5e.6 a §5e.8, claves y valores. Si difieren, gana 10.
4. Pasada de vocabulario (R §3) y de reparto (R §4). NightWindow es 21:00 a 07:00.
5. Añade "## 12. Reconciliación aplicada (16-11-2026)" con la forma de 06 §12 y una
   línea por ficha: aplicado, ya estaba (comprobado) o rechazado con razón.

## Criterio de aceptación
F=docs/design/07-TEMPORIZADOR-NOCHE-MADRUGADA.md
cuerpo() { sed '/^## 12\./,$d' "$F" | awk '/^#+ /{h=$0} {print h " @@ " $0}' | sed 's/`[^`]*`//g'; }
cuerpo | grep -i -w -E 'escudo|amanecer'  # sin salida
cuerpo | grep -i -w 'siesta' | grep -v '1\.1'  # sin salida: vale la marca en el título
sed '/^## 12\./,$d' "$F" | awk -F'|' '/^\| `(timer|temporizador)\./{print $3 "|" $4}' \
  | grep -n -i -w 'pro'  # sin salida
for c in C03 C05 C11 C22 C27 C30 C31 C36 C46 C47 C48 C51 C60 C65; do
  sed -n '/^## 12\./,$p' "$F" | grep -q "$c" || echo "falta $c"; done  # sin salida
git diff --stat origin/main...HEAD  # 1 fichero
Lint de 10 §0.5 a mano (scripts/lint-copy.sh nace en L-01): lista ES en un fichero
fuera del repo y  cuerpo | grep -i -w -E -f <fichero>  → 0 fuera de los falsos
positivos que §0.5 admite. cuerpo pone delante de cada línea el título de su apartado.

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: X-02 · Reconciliación aplicada a la spec 07
- Descripción: tabla ficha → estado → sección de 07. Dudas y contradicciones.
- Evidencias: salida de los cinco comandos y del lint, con el patrón usado.
- No verificado: nada. No se ejecuta verify.sh.

## Si te atascas
Si una ficha admite dos lecturas, no elijas: ATASCO.md en la raíz del worktree, sin
commit, con las dos. Sigue con las demás.
````

### X-03 (oleada 0)

````text
# BRIEF X-03 · Aplicar la reconciliación a 09-ECOSISTEMA
Agente: Kimi · Revisor: Claude
Rama: kimi/x-03-spec-09 · Base: main@<sha> (con I-03 fusionado)
Worktree: ~/wt/sleepnoise/kimi-x-03 · Simulador: ninguno, no se compila

## Objetivo
09 es el criterio de D-01a a D-05. Debe dejar escrito: siete intents con frase y dos
sin frase, widgets pequeño, rectangular e inline, Control y botón de Acción en 1.0,
Live Activity recortada solo en escenario A y una sola tinta fuera de la app.

## Lee antes, y nada más
R = docs/RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md
- AGENTS.md
- R §1 (32-43), §3 (980-1031), §4 (1033-1065)
- R, las 15 fichas con delta para 09: C09, C25, C26, C27, C28, C41, C42, C43, C44,
  C48, C49, C50, C58, C61, C62
- docs/design/06-MAREA.md §12 (703 en adelante): modelo del registro
- docs/design/10-GUIA-DE-COPY.md §0.5 (118-127), §5e.13 y §5e.14 (1019-1079)
- docs/design/09-ECOSISTEMA.md, entero
Dato de hoy: 09 ya cita fichas en más de 160 sitios. Casi todo es comprobar.

## Ficheros que puedes tocar
docs/design/09-ECOSISTEMA.md
Prohibido todo lo demás, incluido docs/PLAN-MAESTRO-2026-11-16.md.

## Pasos
1. grep -n '09-ECOSISTEMA' R: 15 líneas. Comprueba cada delta y aplica el que falte.
2. Marca de versión en la misma línea o en el título de su apartado: StartTide y
   StopTide 1.1, widget mediano 1.1, Focus 1.1, Watch 1.2.
3. El widget circular y la vista expandida de la Isla solo pueden aparecer negados
   o en la sección 8, con su ficha (C42, C25).
4. Pasada de vocabulario (R §3) y de reparto (R §4). Las frases de Siri quedan
   idénticas a 10 §5e.14. No tocas el catálogo.
5. Añade "## 12. Reconciliación aplicada (16-11-2026)" con la forma de 06 §12 y una
   línea por ficha: aplicado, ya estaba (comprobado) o rechazado con razón.

## Criterio de aceptación
F=docs/design/09-ECOSISTEMA.md
crudo()  { sed '/^## 12\./,$d' "$F" | awk '/^#+ /{h=$0} {print h " @@ " $0}'; }
cuerpo() { crudo | sed 's/`[^`]*`//g'; }
cuerpo | grep -i -w -E 'chips?|envolventes?|escudo|v1|v2' \
  | grep -v -i -E '^## 8\.|formato v2'  # sin salida
cuerpo | grep -i -w -E 'circular|expandida' \
  | grep -v -i -E 'sin |no hay|no tiene|no existe|C25|C42|1\.[12]'  # sin salida
crudo  | grep -E 'StartTide|StopTide' | grep -v '1\.1'  # sin salida
cuerpo | grep -i -w 'watch' | grep -v '1\.2'  # sin salida
for c in C09 C25 C26 C27 C28 C41 C42 C43 C44 C48 C49 C50 C58 C61 C62; do
  sed -n '/^## 12\./,$p' "$F" | grep -q "$c" || echo "falta $c"; done  # sin salida
git diff --stat origin/main...HEAD  # 1 fichero
Cada línea sale con el título de su apartado delante: una marca en el título vale.
Una línea que cite la lista vetada entre comillas se enumera en la entrega.
Lint de 10 §0.5 a mano (lint-copy.sh nace en L-01): lista ES en un fichero fuera del
repo y  cuerpo | grep -i -w -E -f <fichero>  → 0 fuera de los falsos positivos.

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: X-03 · Reconciliación aplicada a la spec 09
- Descripción: tabla ficha → estado → sección de 09. Dudas y contradicciones.
- Evidencias: salida de los seis comandos y del lint, con el patrón usado.
- No verificado: nada. No se ejecuta verify.sh.

## Si te atascas
Si una ficha admite dos lecturas, no elijas: ATASCO.md en la raíz del worktree, sin
commit, con las dos. Sigue con las demás.
````

### S-01 (oleada 1)

````text
# BRIEF S-01 · Spike I0-2: umbral del arrastre de LevelRule
Agente: Kimi · Revisor: Codex
Rama: kimi/s-01-spike-i0-2 (no se fusiona) · Base: main@<sha> (con I-01)
Worktree: ~/wt/sleepnoise/kimi-s-01 · Simulador: iPhone 17e

## Objetivo
Prototipo desechable. Pregunta: con qué umbrales un scroll diagonal sobre tres
filas no cambia ningún nivel. La nota fija los umbrales de DS-04.

## Lee antes, y nada más
- AGENTS.md
- docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md §4, fila LevelRule (desde 246)
- docs/design/04-SISTEMA-FUNDAMENTOS.md §2.2 (124-161) y Anexo A9 (1411-1568)
- docs/design/05-PAGINA-Y-CAPAS.md §2.6 (260-307)
- Reconciliación, fichas C21 y C52. FUNCIONES-PRIORIZADAS §6.3 (591-596)

## Ficheros que puedes tocar
SleepNoise/Spike/LevelDragSpike.swift (nuevo, entero bajo #if DEBUG)
SleepNoise/App/SleepNoiseApp.swift (solo un gancho #if DEBUG que abre la pantalla
  con el argumento de lanzamiento -spikeLevelDrag)
SleepNoiseUITests/LevelDragSpikeUITests.swift (nuevo)
docs/research/spikes/I0-2.md (nuevo)
Prohibido todo lo demás: MixerView, MixerModel, SleepNoise/Design/, project.yml.

## Pasos
1. La decisión del gesto va en un reductor puro, sin SwiftUI: entra la traslación,
   sale scroll o cambio de valor. Parámetros: distancia mínima y ángulo de bloqueo.
2. Pantalla DEBUG: tres filas dentro de un ScrollView. Arrastre relativo, distancia
   mínima 8 pt, bloqueo de eje a 30 grados. Pulsación larga: la fila pasa a ser un
   Slider del sistema. Cada fila expone su valor como accessibilityValue. Los
   textos de esta pantalla no van al catálogo.
3. Test de interfaz: 10 scrolls diagonales sobre las filas y lectura de los tres
   valores antes y después. Otro test: un arrastre horizontal sí cambia el valor.
4. Prueba ángulos de 20, 30 y 40 grados con distancias de 8 y 12 pt.
5. Nota en español: método, tabla de combinaciones, umbral elegido, descartes y un
   apartado "Pendiente de dispositivo (H-02b)" con las pruebas de VoiceOver y
   Switch Control que hará el dueño.

## Criterio de aceptación
SN_SIM='iPhone 17e' scripts/verify.sh  # sale 0
xcodebuild test -project SleepNoise.xcodeproj -scheme SleepNoise \
  -destination 'platform=iOS Simulator,name=iPhone 17e' -derivedDataPath .build/DerivedData \
  -only-testing:SleepNoiseUITests/LevelDragSpikeUITests  # 0 fallos; sobra si verify.sh ya los ejecuta
grep -n 'Pendiente de dispositivo' docs/research/spikes/I0-2.md  # 1 línea

## Entrega
Commits sin push. Tu mensaje final es el texto del PR de la nota:
- Título: S-01 · Spike I0-2: umbral del arrastre
- Descripción: umbral elegido y por qué, en cinco líneas.
- Evidencias: últimas 30 líneas de verify.sh y resultado del test de interfaz.
- No verificado: VoiceOver y Switch Control en iPhone real (H-02b).

## Si te atascas
Dos intentos sobre el mismo error y para. ATASCO.md en la raíz del worktree, sin
commit. Si el test no logra un gesto diagonal fiable, dilo: es un dato.
````

### S-03 (oleada 1)

````text
# BRIEF S-03 · Spikes I0-5 e I0-5b: háptica y quietud
Agente: Kimi · Revisor: Codex
Rama: kimi/s-03-spike-i0-5 (no se fusiona) · Base: main@<sha>
Worktree: ~/wt/sleepnoise/kimi-s-03 · Simulador: iPhone 17e

## Objetivo
Dos notas para decidir la versión 1.2. No bloquean 1.0. I0-5: qué hace Core Haptics
en primer plano, en segundo plano y con la pantalla bloqueada. I0-5b: si la quietud
se puede detectar sin sensor continuo y cuánto costaría en batería.

## Lee antes, y nada más
- AGENTS.md
- docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md §3.8 (221-241) y §8.1 fila I0 (419)
- Reconciliación, fichas C35 y C37
- docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md §2.3 (210-220)
- Documentación de Apple de Core Haptics y CoreMotion, con URL y fecha

## Ficheros que puedes tocar
docs/research/spikes/I0-5.md e I0-5b.md (nuevos)
SleepNoise/Spike/StillnessHarness.swift (nuevo, opcional, entero bajo #if DEBUG)
Prohibido todo lo demás. Si el arnés pide una cadena de permiso en Info.plist, para.

## Pasos
1. I0-5.md: tabla estado de la app → qué permite el sistema → fuente. Lo que la
   documentación no dice va con [SV].
2. I0-5b.md: opciones para detectar quietud, con coste esperado y fuente.
3. No tienes iPhone. Deja el protocolo de medida y la tabla de resultados con las
   celdas en "pendiente de dispositivo". No inventes cifras.
4. El arnés, si lo escribes, solo registra en consola. No se enlaza a ninguna vista.
5. Cada nota acaba con una recomendación provisional y lo que la confirmaría. Sin
   afirmaciones médicas: la quietud es movimiento del teléfono, no de la persona.

## Criterio de aceptación
ls docs/research/spikes/I0-5.md docs/research/spikes/I0-5b.md  # existen
grep -c 'pendiente de dispositivo' docs/research/spikes/I0-5b.md  # 1 o más
git grep -n 'import CoreMotion' origin/main -- SleepNoise | wc -l  # 0
SN_SIM='iPhone 17e' scripts/verify.sh  # sale 0 si hay arnés

## Entrega
Commits sin push. Tu mensaje final es el texto del PR de las notas:
- Título: S-03 · Spikes I0-5 e I0-5b: háptica y quietud
- Descripción: las dos recomendaciones, en seis líneas.
- Evidencias: fuentes citadas y, si hay arnés, últimas 30 líneas de verify.sh.
- No verificado: todas las medidas en iPhone real.

## Si te atascas
Si la fuente oficial no responde, escribe [SV] y sigue. No rellenes con suposiciones.
````

### L-01 (oleada 1)

````text
# BRIEF L-01 · Catálogo ES y EN semilla, lint de copy y strings-merge.sh
Agente: Kimi · Revisor: Claude
Rama: kimi/l-01-catalogo · Base: main@<sha> (con I-01, R-02 y F-02; es-419 ya en project.yml)
Worktree: ~/wt/sleepnoise/kimi-l-01 · Simulador: iPhone 17e

## Objetivo
Sembrar en el catálogo las claves de la guía de copy y dejar el lint y el script
con los que ningún paquete posterior edita el catálogo a mano.

## Lee antes, y nada más
G = docs/design/10-GUIA-DE-COPY.md
- AGENTS.md
- G §0.2 a §0.6 (27-133), §5e entero (661-1196), Anexo de claves (1306-1317), §12.3 (1440)
- Reconciliación §3 (980-1031) y ficha C17
- SleepNoiseTests/CopyLintTests.swift

## Ficheros que puedes tocar
SleepNoise/Resources/Localizable.xcstrings y AppShortcuts.xcstrings
SleepNoiseTests/CopyLintTests.swift, SleepNoiseTests/CatalogCompletenessTests.swift (nuevo)
scripts/lint-copy.sh, scripts/strings-merge.sh, strings/L-01.json, strings/README.md (nuevos)
Prohibido todo lo demás: project.yml, scripts/verify.sh (el lint lo engancha Claude)
y cualquier .swift de SleepNoise/.

## Pasos
1. Una entrada por clave de G §5e que sea de 1.0: en es el idioma fuente, es la
   traducción, es-419 solo en las entradas de G §0.3. Conserva el formato que escribe
   Xcode. No siembres las claves marcadas [1.1], [1.2] o [2.0] ni las retiradas:
   temporizador.siesta*, pagina.estado.sonando.siesta, ajustes.icloud, ajustes.debajo*,
   debajo.*, estado.debajo, widget.mediano.*, focus.*, ax.widget.fila y
   pro.precio.lanzamiento. Tampoco las claves la.* de la Live Activity: las siembra
   D-04 si hay escenario A. Lista en la entrega las claves omitidas.
2. No borres ni renombres ninguna clave que el Swift de main use hoy: la pantalla
   actual vive hasta A-03b. Las retiradas del Anexo van listadas en la entrega.
3. scripts/strings-merge.sh strings/<id>.json: fusiona un fragmento en el catálogo.
   Idempotente, salida determinista, solo herramientas de macOS y Xcode. Falla si
   falta en o es, o si la clave existe con otro valor. Formato propuesto:
   {"clave": {"en": "...", "es": "...", "es-419": "...", "comment": "..."}}
4. scripts/lint-copy.sh: lista ES sobre es y es-419, lista EN sobre en, con los
   falsos positivos anotados por clave. Reglas nuevas: sin cifras de precio, sin
   recuento de texturas, ningún nombre de mezcla que sea textura más adjetivo, y
   fuera ranura, chip, envolvente, Escudo y lanzamiento.
5. Tests: las mismas reglas en CopyLintTests. Toda clave tiene en y es. Toda clave
   usada en Swift existe. Las sembradas que nadie usa aún van en una lista de espera
   explícita, con el id del paquete que las usará. Falla si una ya está en uso.
6. "Manto" en inglés queda como "Blanket". Lista en la entrega las claves que lo
   contienen.

## Criterio de aceptación
SN_SIM='iPhone 17e' scripts/verify.sh  # sale 0
scripts/lint-copy.sh; echo $?  # 0
scripts/strings-merge.sh strings/L-01.json && git diff --exit-code  # no cambia nada
python3 -c "import json;json.load(open('SleepNoise/Resources/Localizable.xcstrings'))"
grep -cE 'siesta|icloud|debajo|widget\.mediano|focus\.|precio\.lanzamiento|"la\.' strings/L-01.json  # 0
Control: con "premium" en una cadena, lint-copy.sh sale distinto de 0 y el test
falla. Deshaz el cambio.

## Cadenas
Este paquete es el catálogo. Sin afirmaciones médicas: G §0.4 manda sin excepción.

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: L-01 · Catálogo semilla, lint de copy y fragmentos de cadenas
- Descripción: claves añadidas por pantalla, claves omitidas por ser de 1.1 o
  posteriores, claves que el Anexo retira y siguen vivas, lista de espera, claves
  con "Blanket".
- Evidencias: últimas 30 líneas de verify.sh, salida de los comandos y del control.
- No verificado: revisión del inglés por un hablante nativo.

## Si te atascas
Si G se contradice, gana §5e y lo anotas. Dos intentos sobre el mismo error y para:
ATASCO.md en la raíz del worktree, sin commit.
````

### DS-01 (oleada 1)

````text
# BRIEF DS-01 · Tokens, escala tipográfica y rejilla en código
Agente: Kimi · Revisor: Codex
Rama: kimi/ds-01-tokens · Base: main@<sha> (con I-01)
Worktree: ~/wt/sleepnoise/kimi-ds-01 · Simulador: iPhone 17e

## Objetivo
Llevar a código los fundamentos del sistema de diseño: tintas y fases de noche,
escala de nueve pasos y rejilla de 4 pt.

## Lee antes, y nada más
S = docs/design/04-SISTEMA-FUNDAMENTOS.md
- AGENTS.md
- docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md §3 (110-241)
- S §2.0 (36-93), Anexo A1 a A3 (882-1117) y Anexo B, prueba P5 (línea 1955)
- Reconciliación, fichas C61, C62, C66, C67 y §6 n.º 1
- SleepNoise/App/Theme.swift

## Ficheros que puedes tocar
SleepNoise/Design/Ink.swift, TypeStep.swift, Grid.swift (nuevos)
SleepNoise/Resources/Assets.xcassets (solo colorsets nuevos)
SleepNoise/App/Theme.swift (cambio mínimo)
SleepNoiseTests/DesignTokenTests.swift (nuevo)
Prohibido todo lo demás: ninguna vista, AccentColor.colorset, project.yml.

## Pasos
1. Colorsets con los hex de S §2.0.1, ni uno más. El acento es un único token. Su
   valor por defecto es el Índice de 03 §3. El dueño lo decide el 27-11-2026.
2. Ink.swift, TypeStep.swift y Grid.swift según los listados A1 a A3. Si no
   compilan tal cual, arréglalos sin cambiar valores.
3. Solo SF Pro del sistema. Sin rounded ni serif, sin pesos light, thin ni bold,
   sin tamaños sueltos.
4. Theme.swift: la API de Palette y de NightBackground no cambia y ninguna vista se
   toca. Si redirigir un color a un token cambia la pantalla actual, no lo hagas
   y anótalo.
5. Test de contraste: cada tinta de texto sobre negro y sobre hoja da 4,5:1 o más.

## Criterio de aceptación
SN_SIM='iPhone 17e' scripts/verify.sh  # sale 0
D=SleepNoise/Design
grep -nE 'custom\(|design: \.rounded|design: \.serif' $D/*.swift  # sin salida
grep -nE 'Font\.Weight\.(light|thin|bold)|weight: \.(light|thin|bold)\)' $D/*.swift # sin salida
grep -n 'font(.system(size:' $D/*.swift  # sin salida
grep -rn 'AccentColor' $D ; grep -rn 'Timer' $D  # sin salida
grep -rhoE '#[0-9A-Fa-f]{6}' $D | sort -u  # solo valores de la lista de S §2.0.1
git diff --stat origin/main...HEAD  # solo la lista cerrada

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: DS-01 · Tokens, escala tipográfica y rejilla
- Descripción: tokens creados, qué quedó de Theme.swift y diferencias con A1 a A3.
- Evidencias: últimas 30 líneas de verify.sh, salida de los greps, tabla de contrastes.
- No verificado: legibilidad a oscuras y bajo rojo en iPhone real (H-05).

## Si te atascas
Dos intentos sobre el mismo error y para. ATASCO.md en la raíz del worktree, sin
commit. Si un contraste no llega a 4,5:1, no cambies el hex: es un hallazgo.
````

### DS-03 (oleada 1)

````text
# BRIEF DS-03 · Horizonte: SoundLine y SoundMeter
Agente: Kimi · Revisor: Codex
Rama: kimi/ds-03-horizonte · Base: main@<sha> (con DS-01 y DS-02)
Worktree: ~/wt/sleepnoise/kimi-ds-03 · Simulador: iPhone 17e

## Objetivo
La línea del sonido: reposo en hairline, sonando, fundiendo, descomposición por
capas y variantes de Noche. Para VoiceOver es un solo elemento de estado.

## Lee antes, y nada más
S = docs/design/04-SISTEMA-FUNDAMENTOS.md
- AGENTS.md
- docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md §4, fila Horizonte (desde 246)
- S §2.1 (94-123), §3.1 (307-324), §5a (472-513), §5b (514-546), Anexo A4 (1118-1162)
  y A8 (1320-1410)
- Reconciliación, fichas C53 y C63
- Un fichero de galería de DS-02 en SleepNoise/Design/, como patrón

## Ficheros que puedes tocar
SleepNoise/Design/SoundLine.swift, SoundMeter.swift, SoundLineGallery.swift (nuevos)
SleepNoiseTests/SoundMeterTests.swift (nuevo), strings/DS-03.json (si hace falta)
Prohibido todo lo demás: SystemGallery.swift (la línea de registro la añade Claude),
el contrato de audio, SleepAudioEngine.swift, las vistas de Features/ y el catálogo.

## Pasos
1. SoundMeter recibe sus valores por un protocolo inyectable. El valor provisional
   sale, en el hilo principal, de lo que el modelo ya sabe: si suena, niveles y
   fundido. No lee el estado del render. El canal real llega con P-05.
2. SoundLine pinta los estados de S §3.1. Grosor de 1,5 a 3 pt según el valor. El
   único reloj es TimelineView. Ningún Timer.
3. VoiceOver: un elemento, con histéresis de 3 s en el valor hablado.
4. Reduce Motion: sin cambio de posición ni de escala.
5. Galería: una sección propia con todos los estados y un identificador por estado.

## Criterio de aceptación
SN_SIM='iPhone 17e' scripts/verify.sh  # sale 0
grep -rn 'Timer' SleepNoise/Design  # sin salida
grep -n 'SleepAudioEngine\|RenderState' SleepNoise/Design/Sound*.swift # sin salida
grep -c 'func test' SleepNoiseTests/SoundMeterTests.swift  # 3 o más
git diff --stat origin/main...HEAD  # solo la lista cerrada
Tests, con reloj inyectado: el valor hablado no cambia antes de 3 s, el grosor va
de 1,5 a 3 pt y con Reduce Motion la posición no cambia.

## Cadenas
Valores hablados de 10 §5e.16, en inglés y en español. La clave que falte va en
strings/DS-03.json y entra con scripts/strings-merge.sh, si ya existe.

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: DS-03 · Horizonte: SoundLine y SoundMeter
- Descripción: estados, origen del valor provisional y diferencias con A4 y A8.
- Evidencias: últimas 30 líneas de verify.sh y salida de los greps.
- No verificado: movimiento con audio real y VoiceOver en iPhone (H-05).

## Si te atascas
Dos intentos sobre el mismo error y para. ATASCO.md en la raíz del worktree, sin
commit. Si te falta un dato del motor, pídelo: no lo leas del render.
````

### C-01 (oleada 2)

````text
# BRIEF C-01 · Mezclas en el modelo: guardadas, de la casa y Esta noche
Agente: Kimi · Revisor: Claude
Rama: kimi/c-01-mezclas-modelo · Base: main@<sha> (con P-03b, P-04a, P-04b, F-01 y L-01)
Worktree: ~/wt/sleepnoise/kimi-c-01 · Simulador: iPhone 17e

## Objetivo
Cuatro mezclas de la casa, guardar, renombrar y vaciar sobre el formato v2 con tres
mezclas gratis, y "Esta noche" como nombre de la mezcla viva sin guardar.

## Lee antes, y nada más
- AGENTS.md
- docs/design/08-MEZCLAS-PRO-PRUEBA.md §2.1 y §2.2 (46-144) y §4.1 a §4.4 (472-509)
- Reconciliación, fichas C17, C18, C23 y §4 (1033-1065)
- docs/research/FUNCIONES-PRIORIZADAS-2026-11-16.md §5, punto 6 (509-532)
- Código: SoundPreset.swift, SavedMix.swift, MixStore.swift y el códec v2 de P-04a

## Ficheros que puedes tocar
SleepNoise/Model/SoundPreset.swift (pasa a HouseMix.swift con git mv)
SleepNoise/Features/Library/MixStore.swift y SavedMix.swift
La extensión de mezclas de MixerModel que dejó F-01: <fichero que indica Claude>
SleepNoiseTests/PolicyTests.swift (solo MixStoreTests), HouseMixTests.swift (nuevo)
strings/C-01.json (si hace falta)
Prohibido todo lo demás: AccessPolicy.swift, PurchaseManager.swift, las otras
extensiones de MixerModel, SoundID.swift, las vistas, project.yml y el catálogo a mano.

## Pasos
1. Exactamente cuatro: Rosa y lluvia (rosa y lluvia, libre), Mar y viento (océano y
   viento, Pro), Marrón y hoguera (marrón y hoguera, Pro), Pared (marrón, lluvia y
   viento, libre). Son recetas de niveles. No llevan Marea ni temporizador.
2. Carga recortada: sin acceso, una mezcla con capas Pro carga y suena sin ellas.
   Nunca pide compra. Las capas conservan su nivel.
3. Guardar, renombrar y vaciar sobre v2. La cuarta mezcla sin acceso devuelve
   needsPro sin perder el nombre escrito.
4. "Esta noche" sale del catálogo, no de un literal.
5. Al caducar el acceso no se escribe nada en disco. Cargar una mezcla no toca el
   temporizador.

## Criterio de aceptación
SN_SIM='iPhone 17e' scripts/verify.sh  # sale 0
git grep -n 'SoundPreset' -- SleepNoise SleepNoiseTests | wc -l  # 0
grep -c 'func test' SleepNoiseTests/HouseMixTests.swift  # 5 o más
git diff --stat origin/main...HEAD  # solo la lista cerrada
Tests con nombre: cuatro mezclas con su clasificación; las dos con Pro cargan
recortadas sin pedir compra; cargar no cambia el temporizador; al caducar el acceso
los bytes guardados no cambian y la capa conserva su nivel; ningún nombre de mezcla
es textura más adjetivo.

## Cadenas
Nombres del catálogo (L-01): Pink and rain, Sea and wind, Brown and fire, Wall,
Tonight. es-419: "Marrón y fogata". Clave nueva: strings/C-01.json y strings-merge.sh.

## Entrega
Commits sin push. Tu mensaje final es el texto del PR:
- Título: C-01 · Mezclas en el modelo
- Descripción: qué cambió en MixStore y en la extensión de MixerModel, y por qué.
- Evidencias: últimas 30 líneas de verify.sh y salida de los comandos.
- No verificado: cómo suenan las cuatro mezclas en un iPhone con auriculares.

## Si te atascas
Dos intentos sobre el mismo error y para. ATASCO.md en la raíz del worktree, sin
commit. Si hace falta tocar otra extensión de MixerModel, para y pídelo.
````

---

## 4. Oleadas posteriores, una línea por paquete

| Id | Ol. | Qué | Depende de | Revisor |
|---|---|---|---|---|
| A-04 | 3 | Hoja Todas las capas y el único tip | A-03b | Codex |
| B-02 | 3 | Hoja Temporizador | B-01, DS-02, X-02, L-01 | Codex |
| C-02 | 3 | Pantalla Mezclas y menú del nombre | C-01, DS-02, A-03a, L-01 | Codex |
| E-01 | 3 | Icono en cuatro apariencias | DS-01, H-01 (acento) | Codex |
| D-05 | 4 | Ajustes, Salida, Reproduciendo, Al acostarte | DS-02, B-03, C-04, X-03, L-01 | Codex |
| D-06 | 4 | Páginas de confianza | DS-02, L-01, T-01, D-05 | Codex |
| D-07 | 4 | Diagnóstico local y Enviar informe. El anillo implementa `DiagnosticsSink` (de B-05b) en ficheros nuevos y se inyecta en `AppRoot`. No toca `SleepNoise/Audio/` | D-05, B-05b | Claude |
| E-02 | 4 | Ficha, capturas y Notes for Review. Textos en es y en según 11 y C57, sin cifra de precio ni recuento de texturas. Un test de interfaz genera las seis capturas por idioma en simulador | L-01, A-04, B-03, C-02, C-04, D-05, H-01 (marca) | Claude |
| Q-01 | 5 | Auditoría de accesibilidad | A-04, A-07, B-02, B-03, B-04, C-02, C-04, D-05, D-06 | Codex |

A-04, B-02, C-02, D-05 y D-06 dependen de la calibración (F-02, X-01 y DS-01 en dos rondas o menos, plan §3.7): si Kimi no la pasa, van a Codex y los revisa Claude. Si la pasa, DS-04, DS-05, D-03 y B-04 pasan a Kimi por defecto, con revisión de Claude, y el cambio se escribe en `ESTADO.md`. Kimi es suplente de P-03a, P-04a, T-01, B-05a y A-02c (Cursor) y de P-02, DS-04, DS-05, B-04 y D-03 (Codex). P-03a pasa a Kimi el día 3 si Cursor no está listo (plan §2.2, R7). Sus briefs se escriben al cerrar la oleada anterior.

---

## 5. Lista de comprobación del revisor de un PR de Kimi

1. El diff solo toca la lista cerrada. Ni `project.yml`, ni entitlements, ni contrato de audio, ni configuración de agentes.
2. `SN_SIM='iPhone Air' scripts/verify.sh` sale 0 en el worktree del revisor, sin avisos. La salida pegada por Kimi no cuenta.
3. El número de tests no baja. Ningún `XCTSkip`, test vaciado ni umbral relajado.
4. Cada línea del criterio de aceptación tiene un test con nombre o un grep. Ningún test es una tautología.
5. Las API de Apple existen con esa firma en iOS 17. Nada de lo que vetan las reglas 10 y 11.
6. Sin `Timer`, `DispatchQueue` ni red en `SleepNoise/Design`. El hilo principal no lee el estado del render.
7. Interfaz: una tinta de noche, sin candados, acento solo por su token, objetivos de 44 pt o más. Se mira en la galería, en el simulador.
8. Cadenas: en y es, por fragmento, con el vocabulario de la reconciliación §3. Sin precios, recuentos de texturas ni afirmaciones médicas.
9. Specs (X-01 a X-03): cada ficha está en la sección 12 y el cambio existe en el cuerpo. Cinco deltas al azar contra la reconciliación. Ninguna decisión nueva.
10. Texto nuevo en español, frases cortas, sin rayas largas como inciso, sin nombres.
11. El PR dice qué no se verificó en dispositivo y a qué paquete del dueño queda.
12. No queda `ATASCO.md` en la rama. Segunda ronda fallida: el paquete pasa al suplente.
