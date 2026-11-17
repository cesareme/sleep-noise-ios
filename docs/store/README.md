# Textos para App Store Connect · SleepNoise 1.0

Paquete S-09. Todo lo que hay que pegar en App Store Connect para enviar la 1.0, más la política de privacidad pública. Son textos: aquí no hay código ni capturas.

## Orden de uso

1. **`../privacy/index.md`**: rellenar sus tres marcadores, activar GitHub Pages (abajo) y comprobar que la página abre. Sin esa URL no se puede enviar.
2. **`privacidad.md`**: al crear la app, responder al cuestionario de privacidad, la clasificación por edades, la categoría, los derechos de contenido y el cumplimiento de exportación.
3. **`compra-integrada.md`**: crear el producto Pro, con Family Sharing, sus dos localizaciones, la nota y la captura para revisión.
4. **`ficha-en.md`** y **`ficha-es.md`**: página de la versión 1.0. El inglés (EE. UU.) es el idioma principal; el español (España) se añade como segunda localización.
5. **`notas-revision.md`**: sección "App Review Information", lo último antes de enviar.

Las capturas las genera `scripts/screenshots.sh` (S-08), que lee los titulares de las dos fichas, y el icono es de S-10; aquí solo están los titulares.

## GitHub Pages

Activarlo es un ajuste del repositorio y lo hace el dueño: en GitHub, Settings › Pages › "Build and deployment" › Source "Deploy from a branch" › rama `main`, carpeta `/docs` › Save. Al cabo de un minuto la política queda en:

```text
https://<cuenta>.github.io/<repositorio>/privacy/
```

Tres condiciones antes de activarlo:

- **Sin marcadores.** La política lleva tres textos entre corchetes (contacto, responsable y plazo). No se activa Pages ni se pega la URL en App Store Connect mientras quede alguno.
- **Solo la política.** Con ese ajuste GitHub publica como web toda la carpeta `docs/`, no solo la política: la investigación con sus comparaciones con otras apps, los planes con el precio, las maquetas y estas mismas fichas. Que el repositorio sea público no convierte todo eso en la web del producto, que es lo que pasa a ser en cuanto la ficha enlaza ese dominio; la guía de copy §0.4 aplica sus listas también a la web. Antes de activar Pages hay que dejar fuera todo salvo `privacy/`. Hay dos maneras, y ninguna está hecha ni probada en este paquete: un fichero `docs/_config.yml` que excluya lo demás (abajo), o un flujo de GitHub Actions que publique solo `docs/privacy`. La primera hay que mantenerla: cada carpeta o fichero nuevo en la raíz de `docs/` se publica hasta que se añade a la lista.
- **Comprobarlo.** Con Pages activo, `/privacy/` abre y las demás rutas dan 404: por ejemplo `/store/ficha-es`, `/research/` y `/design/10-GUIA-DE-COPY`.

Contenido de `docs/_config.yml` para la primera manera, con lo que hay hoy en `docs/`:

```yaml
exclude:
  - agents
  - briefs
  - design
  - research
  - store
  - PLAN-DESARROLLO-AGENTES-2026-11-16.md
  - PLAN-MAESTRO-2026-11-16.md
  - PLAN-SIMPLE-1.0.md
  - RECONCILIACION-PRODUCTO-DISENO-2026-11-16.md
  - REVIEW-2026-11-15.md
  - REVIEW-PR3-2026-11-16.md
  - ROADMAP.md
```

La página solo cambia cuando el cambio llega a `main`.

## Lo que el dueño debe rellenar o decidir

| Dónde | Qué |
|---|---|
| `../privacy/index.md` | La dirección de contacto, en los dos idiomas, donde hoy dice "[dirección de contacto pendiente del dueño]". Conviene que sea una dirección creada para la app |
| `../privacy/index.md` | Quién responde de la app y de los correos que se reciben, donde hoy dice "[nombre o razón social, pendiente del dueño]". Es el responsable del tratamiento que pide el artículo 13 del RGPD. El repositorio es público: ese nombre quedará a la vista, igual que en la ficha |
| `../privacy/index.md` | El plazo en que se borran los correos recibidos, donde hoy dice "[plazo pendiente del dueño]", y cumplirlo. La directriz 5.1.1(i) pide que la política diga la retención, el borrado y cómo pedirlo |
| App Store Connect › URL de privacidad | La URL de GitHub Pages de arriba |
| App Store Connect › URL de soporte | Obligatoria. Puede ser la misma página de privacidad, que lleva el contacto, o la página de incidencias del repositorio |
| App Store Connect › URL de marketing | Opcional. Se puede dejar vacía |
| App Store Connect › identificador de la app | El identificador de paquete es el `PRODUCT_BUNDLE_IDENTIFIER` de `project.yml`; el SKU y el Apple ID de la app salen al crearla |
| App Store Connect › compra integrada | El precio y Family Sharing (`compra-integrada.md`) |
| App Store Connect › App Review Information | Nombre, teléfono y correo de contacto para el revisor. No se escriben en el repositorio |
| App Store Connect › copyright y condición de comerciante en la UE | Ver `privacidad.md` §6 |
| `ficha-es.md` y `ficha-en.md` › palabras clave | Elegir la opción A o la B. Sin respuesta vale la B, la que no lleva palabras de diagnóstico. De paso, resolver la contradicción entre `AGENTS.md` §5.4, la guía §0.4 y la guía §5e.15 sobre si esas palabras caben en ese campo |
| `ficha-en.md` › subtítulo; las dos fichas › captura 1 | Mantener "Pay once." en el subtítulo inglés y "Un solo pago." con "sin tarjeta" en la captura 1, o pasar a los textos de reserva. La directriz 2.3.7 no quiere precios ni condiciones en nombre, subtítulo y capturas. Sin respuesta se quedan los que fijan la guía y C57 |
| Las dos fichas › texto promocional y descripción | "Nunca se repite" y "never loops": esperar al cambio de audio y a su test (tabla de abajo) o pasar al texto de reserva |
| Las dos fichas › descripción, tercer párrafo | Aceptar o no la enmienda que dice qué añade Pro (directriz 2.3.2). Si se acepta, se enmienda también la guía §5e.15 |
| Política de privacidad dentro de la app | Ajustes y la página "Lo que no hay" ya existen (`SettingsSheet`, `WhatIsNotHerePage`), pero la página no lleva ni el texto de la política ni un enlace. Decidir cuál de los dos y con qué título de fila (la guía de copy §0.2 no admite "Política" ni "Privacidad" como título) y encargar el cambio, que es de código y de catálogo. Sin él no se envía (`notas-revision.md`, condición 1) |
| `AppLinks.authorAddress` y `AppLinks.appStoreID` | Están vacíos. Sin la dirección pública no aparece "Escribir al autor" en Ajustes, y sin el identificador numérico de la app no aparece "Escribir una reseña" en el recibo. Dárselos a quien haga el cambio de código; la dirección es la misma de la política |
| Hoja Pro › nota bajo "Empezar la prueba · 7 noches" | Si la nota nombra lo que deja de estar disponible al acabar la prueba (`notas-revision.md`, "Riesgo 3.1.1"). Es texto cerrado de la guía y un cambio de catálogo |
| Sandbox y un iPhone | La compra de verdad, la restauración, Now Playing con la pantalla apagada, el final del temporizador y la reinstalación con la prueba usada (`notas-revision.md`, condiciones 3 y 4) |

## Antes de enviar: lo que estos textos dan por hecho

Los textos describen la 1.0 de `docs/PLAN-SIMPLE-1.0.md`, y el código de 1.0 (paquetes S-01 a S-10) ya tiene las funciones que nombran. Esta tabla recoge solo lo que sigue abierto: frases que el código todavía no sostiene o que dependen de algo que el dueño tiene que dar, activar o decidir. Si la condición no se cumple, la frase se quita.

| Frase | Dónde está | Depende de |
|---|---|---|
| "Sonido que nunca se repite", "un ruido que no se repite jamás", "never loops" | Promoción y descripción, en los dos idiomas | Un cambio de audio y un test que no existen. El generador (`XorShift32`) tiene un estado de 32 bits: su secuencia vuelve a empezar cada 2^32 − 1 muestras, unas 24 h 51 min a 48 kHz. Y las semillas de `RenderState` son constantes: solo el calendario del trueno cambia en cada arranque (`SleepAudioEngine`), así que cada arranque de la app repite la misma secuencia desde la primera muestra. Para sostener la frase hace falta una semilla distinta por arranque, un estado de 64 bits y el test de autocorrelación de C53. Si no llega, valen los textos de reserva de las fichas, que dicen lo comprobable: no hay archivos de audio ni bucles. La app dice lo mismo en la hoja Capas (`capas.nota`, "Nada se repite."), con la misma dependencia. Decide el dueño; el cambio es de audio, con su único escritor |
| Las texturas nombradas: océano, ventilador, trueno, hoguera, arroyo y cabina en Pro; viento entre las gratuitas | Notas de revisión; nota de la compra; descripción (océano y la lista de lo gratis); palabras clave, opciones A y B; captura 3 | La escucha del dueño (`docs/PLAN-SIMPLE-1.0.md` §4.3, fila 5: las texturas entran "si pasan la escucha"). La textura que no pase se quita del código, de esos cinco sitios y de la hoja Pro, y se vuelven a contar los caracteres |
| "Si algo no suena, Ajustes › Escribir al autor" | Novedades, en los dos idiomas | La dirección pública del dueño. La fila existe en `SettingsSheet`, pero solo se enseña con `AppLinks.authorAddress` relleno y un cliente de correo en el iPhone (`SettingsTests.testWritingToTheAuthorNeedsAnAddressTheOwnerGave`). Hoy está vacío: sin dirección, esa línea de las novedades se quita |
| La política de privacidad dentro de la app | Ya no está en las notas de revisión; `privacidad.md` §1 | **Condición de envío**: la directriz 5.1.1(i) pide la política en el campo de App Store Connect y también dentro de la app. La guía retiró la fila de privacidad de Ajustes (`ajustes.privacidad`) y dejó en su lugar "Lo que no hay": esa página existe (`WhatIsNotHerePage`) y no lleva ni el texto ni un enlace. Tiene que llevar el texto de la política, que es corto, o un enlace a la URL de Pages. Mejor el texto: el enlace saca a la persona de la app y depende de la red. Cuando esté, la frase vuelve a las notas (`notas-revision.md`, condición 1) |
| "with Family Sharing", "with Family Sharing turned on" | Notas de revisión, nota de la compra | Que el dueño lo active en App Store Connect (`compra-integrada.md`). El fichero de la tienda local ya lo tiene en `true` y la hoja Pro lo dice ("En familia") salvo que la tienda responda lo contrario |
| Todo lo que las notas dicen de comprar y de restaurar | Notas de revisión, nota de la compra | El sandbox. Los estados de la hoja están cubiertos por tests con la tienda de guion (`ScriptedProStore`); la compra de verdad no se ha hecho nunca (`notas-revision.md`, condición 3) |
| Now Playing con la pantalla apagada, el final del temporizador y "reinstalar no da otra prueba" | Notas de revisión | Verlo en un iPhone. En código están hechos y con tests (`notas-revision.md`, condición 4) |

Lo que estaba en esta tabla y ya se cumple en el código, con el tipo que lo sostiene:

- La prueba de siete noches que empieza en la hoja Pro, "sin tarjeta" (promoción, descripción, novedades, captura 1 y notas): `NightTrial`, `ProSheet`, `MixerModel.startTrial()`.
- "A las tres de la mañana, la pantalla entera es el botón" y la captura 5: `NightScreen`, `FullScreenControl`.
- La página nocturna y su salida, tocando el nombre de la mezcla (notas y nota de la compra): `MixerModel.leaveBedtime()`, `PageView`.
- "se retira sola" y la captura 4: `TideSheet`, `BreathingGuideController`. La captura no enseña la frase sobre estudios (`marea.evidencia`) ni el enlace "Qué sabemos" porque el catálogo no tiene ninguna de las dos cadenas.
- "Madrugada: veinte minutos de mar que se retira solo": `SmallHoursRecipe`, `SmallHoursScreen`.
- "Mezclas con nombre, cuatro de la casa": `HouseMix`, `MixesSheet`.
- La captura 6, "Lo que no hay": `WhatIsNotHerePage`, dentro de `SettingsSheet`.
- "Restore purchase" y "Buy": `pro.restaurar` y `pro.comprar`.

La comprobación de las notas, frase a frase, está en la tabla de `notas-revision.md`.

## Lint de las listas de palabras

Los textos de esta carpeta y la política pasan las dos listas de `docs/design/10-GUIA-DE-COPY.md` (§0.4 a mano, §0.5 con expresiones regulares). Coincidencias declaradas, tres clases: las frases que la guía ya admite ("Sin suscripción", "No subscription", "not a medical product", "Lock Screen"); las palabras de diagnóstico de la opción A de palabras clave, que ya no es la opción por defecto; y un falso positivo, la frase de la guía "Siete noches con todo […] Pro es un solo pago", que casa con el patrón pensado para impedir que se cuenten texturas Pro y aquí cuenta las noches de la prueba. Los bloques de texto de las dos fichas pasan además por `CopyLintTests` (`testTheStoreListingsPassTheLint` y `testTheStoreHeadlinesPassTheLint`). Las notas de revisión, la nota de la compra y la política no están en ese test: su lint se pasa a mano, con un script fuera del repositorio, cada vez que cambian. La tabla de comprobación de `notas-revision.md` cita cadenas de la app en inglés letra a letra; son citas, no texto de la ficha.
