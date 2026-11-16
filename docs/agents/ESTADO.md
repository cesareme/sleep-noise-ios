# Tablero de estado · SleepNoise 1.0

Última actualización: 16-11-2026. Creado con 61 paquetes y ampliado a 67 en la revisión del mismo día, todos en estado pendiente. Nada se ha lanzado todavía.

Solo lo edita Claude Code. Las reglas, los estados y los momentos de actualización están en `docs/agents/CLAUDE-ORQUESTADOR.md` §7. El reparto, las dependencias y las puertas están en `docs/PLAN-DESARROLLO-AGENTES-2026-11-16.md` §4 y §5. Si este tablero y el plan difieren en agente, rama o revisor, manda el plan hasta que una reasignación quede escrita aquí.

Estados: pendiente, listo, en curso, entregado, en revisión, cambios (r1), cambios (r2), aprobado, integrado, atascado, reasignado, cancelado.

Resumen: 67 pendientes, 0 en curso, 0 integrados. Autores: Codex 31, Kimi 19, Cursor 5, Claude 4, dueño 8. PR abiertos: 1 de 4 (el PR #3, que se cierra al fusionar R-01). Estos contadores se recalculan solo en el PR diario de documentación.

## Oleada 0 · Infraestructura y rescate del PR #3

| Id | Agente | Rama | Estado | PR | Revisor |
|---|---|---|---|---|---|
| H-01 | Dueño | `claude/h-01-decisiones` | pendiente | - | no aplica |
| I-01 | Claude | `claude/i-01-verify` | pendiente | - | Codex |
| I-03 | Claude | `claude/i-03-agents-md` | pendiente | - | Codex |
| F-02 | Kimi | `kimi/f-02-partir-tests` | pendiente | - | Codex |
| I-02 | Codex | `codex/i-02-ci` | pendiente | - | Claude |
| R-01 | Codex | `codex/r-01-pr-a-base` | pendiente | - | Claude |
| X-01 | Kimi | `kimi/x-01-spec-05` | pendiente | - | Claude |
| X-02 | Kimi | `kimi/x-02-spec-07` | pendiente | - | Claude |
| X-03 | Kimi | `kimi/x-03-spec-09` | pendiente | - | Claude |
| R-02 | Codex | `codex/r-02-pr-a-noche` | pendiente | - | Claude |
| H-02a | Dueño | `claude/h-02a-acta` | pendiente | - | no aplica |

## Oleada 1 · Spikes y primitivas

| Id | Agente | Rama | Estado | PR | Revisor |
|---|---|---|---|---|---|
| S-04 | Codex | `codex/s-04-spike-i0-7` | pendiente | - | Claude |
| S-02 | Codex | `codex/s-02-spike-i0-3-6` | pendiente | - | Claude |
| S-01 | Kimi | `kimi/s-01-spike-i0-2` | pendiente | - | Codex |
| F-01 | Claude | `claude/f-01-motor-protocolo` | pendiente | - | Codex |
| P-01 | Codex | `codex/p-01-bus-maestro` | pendiente | - | Claude |
| P-03a | Cursor | `cursor/p-03a-nightwindow` | pendiente | - | Codex |
| P-04a | Cursor | `cursor/p-04a-mezcla-v2` | pendiente | - | Codex |
| T-01 | Cursor | `cursor/t-01-autocorrelacion` | pendiente | - | Codex |
| DS-01 | Kimi | `kimi/ds-01-tokens` | pendiente | - | Codex |
| L-01 | Kimi | `kimi/l-01-catalogo` | pendiente | - | Claude |
| P-02 | Codex | `codex/p-02-timer-sin-tick` | pendiente | - | Claude |
| P-03b | Codex | `codex/p-03b-politica-keychain` | pendiente | - | Claude |
| P-04b | Claude | `claude/p-04b-app-group-widgets` | pendiente | - | Codex |
| DS-02 | Codex | `codex/ds-02-disco-galeria` | pendiente | - | Claude |
| DS-03 | Kimi | `kimi/ds-03-horizonte` | pendiente | - | Codex |
| S-03 | Kimi | `kimi/s-03-spike-i0-5` | pendiente | - | Codex |
| H-02b | Dueño | `claude/h-02b-acta` | pendiente | - | no aplica |

## Oleada 2 · Bloque A y bases de B y C

| Id | Agente | Rama | Estado | PR | Revisor |
|---|---|---|---|---|---|
| P-05 | Codex | `codex/p-05-canal-inverso` | pendiente | - | Claude |
| A-06 | Codex | `codex/a-06-descenso` | pendiente | - | Claude |
| A-02a | Codex | `codex/a-02a-prng` | pendiente | - | Claude |
| A-02b | Codex | `codex/a-02b-trueno-hoguera` | pendiente | - | Claude |
| A-01 | Codex | `codex/a-01-loudness` | pendiente | - | Claude |
| A-02c | Cursor | `cursor/a-02c-criterio-texturas` | pendiente | - | Codex |
| DS-04 | Codex | `codex/ds-04-levelrule` | pendiente | - | Claude |
| DS-05 | Codex | `codex/ds-05-tideline-fullscreen` | pendiente | - | Claude |
| A-03a | Codex | `codex/a-03a-pagina-rutas` | pendiente | - | Claude |
| A-03b | Codex | `codex/a-03b-tope-retirada` | pendiente | - | Claude |
| B-01 | Codex | `codex/b-01-temporizador-modelo` | pendiente | - | Claude |
| C-03 | Codex | `codex/c-03-storekit-estados` | pendiente | - | Claude |
| C-01 | Kimi | `kimi/c-01-mezclas-modelo` | pendiente | - | Claude |
| B-05a | Cursor | `cursor/b-05a-politicas` | pendiente | - | Codex |

## Oleada 3 · Hojas de A, B y C

| Id | Agente | Rama | Estado | PR | Revisor |
|---|---|---|---|---|---|
| A-04 | Kimi | `kimi/a-04-capas` | pendiente | - | Codex |
| A-07 | Codex | `codex/a-07-hoja-marea` | pendiente | - | Claude |
| B-02 | Kimi | `kimi/b-02-hoja-temporizador` | pendiente | - | Codex |
| B-03 | Codex | `codex/b-03-noche` | pendiente | - | Claude |
| B-05b | Codex | `codex/b-05b-sesion-rutas` | pendiente | - | Claude |
| C-02 | Kimi | `kimi/c-02-pantalla-mezclas` | pendiente | - | Codex |
| C-04 | Codex | `codex/c-04-hoja-pro` | pendiente | - | Claude |
| E-01 | Kimi | `kimi/e-01-icono` | pendiente | - | Codex |

## Oleada 4 · Bloque D, Madrugada y Timbre

| Id | Agente | Rama | Estado | PR | Revisor |
|---|---|---|---|---|---|
| B-04 | Codex | `codex/b-04-madrugada` | pendiente | - | Claude |
| A-05 | Codex | `codex/a-05-timbre` | pendiente | - | Claude |
| D-01a | Codex | `codex/d-01a-intents-frase` | pendiente | - | Claude |
| D-01b | Codex | `codex/d-01b-intents-snapshot` | pendiente | - | Claude |
| D-02 | Codex | `codex/d-02-widgets` | pendiente | - | Claude |
| D-03 | Codex | `codex/d-03-control-accion` | pendiente | - | Claude |
| D-04 | Codex | `codex/d-04-live-activity` | pendiente | - | Claude |
| D-05 | Kimi | `kimi/d-05-ajustes` | pendiente | - | Codex |
| D-06 | Kimi | `kimi/d-06-confianza` | pendiente | - | Codex |
| D-07 | Kimi | `kimi/d-07-diagnostico` | pendiente | - | Claude |
| E-02 | Kimi | `kimi/e-02-ficha-capturas` | pendiente | - | Claude |
| H-03 | Dueño | `claude/h-03-acta` | pendiente | - | no aplica |
| H-04 | Dueño | `claude/h-04-acta` | pendiente | - | no aplica |

## Oleada 5 · Cierre

| Id | Agente | Rama | Estado | PR | Revisor |
|---|---|---|---|---|---|
| Q-01 | Kimi | `kimi/q-01-accesibilidad` | pendiente | - | Codex |
| H-05 | Dueño | `claude/h-05-acta` | pendiente | - | no aplica |
| H-06a | Dueño | `claude/h-06a-beta-acta` | pendiente | - | no aplica |
| H-06b | Dueño | `claude/h-06b-appstore` | pendiente | - | no aplica |

## Notas

- Dentro de cada oleada las filas van en el orden de arranque del plan §4.
- Las ramas de los paquetes del dueño (H-01 a H-06b) solo llevan el acta, que escribe Claude.
- H-01 se reparte entre las oleadas 0 y 1: permisos y planes el día 1, decisiones con plazo después.
- Las ramas de spike (S-01 a S-04) no se fusionan. Su estado final es "integrado" cuando la nota está en `main`.
- A-05 solo existe si H-02b aprueba la puerta del bus, y no se recorta por capacidad. D-04 solo existe en escenario A, con un sí escrito del dueño el 14-12-2026. D-03 se corta si no está integrado el 22-02-2027.
- Al reasignar, la fila cambia de agente, de rama y, si el suplente era el revisor, de revisor. Nunca autor igual a revisor.
- Si Kimi pasa su calibración (F-02, X-01 y DS-01), DS-04, DS-05, D-03 y B-04 pasan a Kimi con revisión de Claude. Hasta entonces figuran con Codex.
- La marca "integrado" se escribe en el PR diario de documentación, no en el PR del paquete. Entre medias, la verdad es el estado del PR.
- Ruta crítica con plazo de corte de tres días laborables: P-03a, P-04a, F-02, DS-01, DS-03, S-01, X-01, X-02, X-03, L-01 y C-01.
- Las correcciones que salgan de H-03, H-04 y H-05 se añaden como filas nuevas con el id del acta, por ejemplo `H-03-c1`.

## Registro

| Fecha | Paquete | Cambio |
|---|---|---|
| 16-11-2026 | todos | Se crea el tablero con 61 paquetes en estado pendiente |
| 16-11-2026 | A-02, A-03, D-01, H-06, E-02 | Revisión del plan: A-02 se parte en A-02a y A-02b (Codex) y A-02c (Cursor, revisa Codex). A-03 en A-03a y A-03b. D-01 en D-01a y D-01b. H-06 en H-06a y H-06b. E-02 nuevo (Kimi, revisa Claude). Total: 67 |
