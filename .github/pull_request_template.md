<!-- Título: <id> · <qué cambia>. Ejemplo: S-03 · NightWindow y reloj de la prueba -->

## Qué cambia

<!-- Paquete (S-xx), dos o tres frases y los documentos o fichas que has seguido. -->

## Ficheros

<!-- Lista del diff (git diff --name-only origin/main...HEAD). Nada fuera de la lista de tu brief. -->

## Definición de hecho (PLAN-SIMPLE §8)

- [ ] 1. `scripts/verify.sh` en verde en el Mac y CI en verde. Pega la última línea (`VERIFY OK · N tests`). Si trabajas sin Xcode, escribe la frase literal "No he compilado ni ejecutado nada en local." y deja la casilla al revisor.
- [ ] 2. Sin avisos nuevos de compilación ni de metadatos de App Intents. No se ha tocado `scripts/verify-known-warnings.txt` ni se ha bajado `scripts/verify-min-tests.txt`.
- [ ] 3. Cadenas nuevas en EN y ES (o "ninguna cadena").
- [ ] 4. Sin red, sin analítica, sin afirmaciones médicas y sin palabras de la lista negra. Hoy solo los términos médicos son automáticos (`CopyLintTests`); el resto de la lista (`docs/design/10-GUIA-DE-COPY.md` §0.5) se revisa a mano.
- [ ] 5. Respeta el documento 03: un solo acento, SF Pro, sin candados ni degradados, y nada de venta entre 21:00 y 07:00.
- [ ] 6. Revisado por el otro agente y fusionado por Claude.

## Sin verificar

<!-- Lo que no has podido comprobar: dispositivo real, audio de verdad, compra, VoiceOver. "Nada" si no hay nada. -->
