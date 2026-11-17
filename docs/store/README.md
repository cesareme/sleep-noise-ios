# Textos para App Store Connect · SleepNoise 1.0

Paquete S-09. Todo lo que hay que pegar en App Store Connect para enviar la 1.0, más la política de privacidad pública. Son textos: aquí no hay código ni capturas.

## Orden de uso

1. **`../privacy/index.md`**: activar GitHub Pages (abajo) y comprobar que la página abre. Sin esa URL no se puede enviar.
2. **`privacidad.md`**: al crear la app, responder al cuestionario de privacidad, la clasificación por edades, la categoría, los derechos de contenido y el cumplimiento de exportación.
3. **`compra-integrada.md`**: crear el producto Pro, con Family Sharing, sus dos localizaciones, la nota y la captura para revisión.
4. **`ficha-en.md`** y **`ficha-es.md`**: página de la versión 1.0. El inglés (EE. UU.) es el idioma principal; el español (España) se añade como segunda localización.
5. **`notas-revision.md`**: sección "App Review Information", lo último antes de enviar.

Las capturas salen del test de interfaz de S-08 y el icono de S-10; aquí solo están los titulares.

## GitHub Pages

Activarlo es un ajuste del repositorio y lo hace el dueño: en GitHub, Settings › Pages › "Build and deployment" › Source "Deploy from a branch" › rama `main`, carpeta `/docs` › Save. Al cabo de un minuto la política queda en:

```text
https://<cuenta>.github.io/<repositorio>/privacy/
```

Dos avisos. Con ese ajuste GitHub publica como web toda la carpeta `docs/`, no solo la política; el repositorio ya es público, así que no se enseña nada nuevo. Y la página solo cambia cuando el cambio llega a `main`.

## Lo que el dueño debe rellenar

| Dónde | Qué |
|---|---|
| `../privacy/index.md` | La dirección de contacto, en los dos idiomas, donde hoy dice "[dirección de contacto pendiente del dueño]". Conviene que sea una dirección creada para la app |
| App Store Connect › URL de privacidad | La URL de GitHub Pages de arriba |
| App Store Connect › URL de soporte | Obligatoria. Puede ser la misma página de privacidad, que lleva el contacto, o la página de incidencias del repositorio |
| App Store Connect › URL de marketing | Opcional. Se puede dejar vacía |
| App Store Connect › identificador de la app | El identificador de paquete es el `PRODUCT_BUNDLE_IDENTIFIER` de `project.yml`; el SKU y el Apple ID de la app salen al crearla |
| App Store Connect › compra integrada | El precio y Family Sharing (`compra-integrada.md`) |
| App Store Connect › App Review Information | Nombre, teléfono y correo de contacto para el revisor. No se escriben en el repositorio |
| App Store Connect › copyright y condición de comerciante en la UE | Ver `privacidad.md` §6 |
| `ficha-es.md` y `ficha-en.md` › palabras clave | Elegir la opción A o la B |

## Antes de enviar: lo que estos textos dan por hecho

Los textos describen la 1.0 de `docs/PLAN-SIMPLE-1.0.md`, no el `main` del 17-11-2026. Cada fila es una frase que hoy no se cumple en `main`; se repasa cuando el paquete entre, y si la función no llega, la frase se quita.

| Frase | Dónde está | Depende de |
|---|---|---|
| "Siete noches con todo, sin tarjeta" y todo lo que las notas dicen de la prueba | Promoción, descripción, novedades, captura 1, notas de revisión, nota de la compra | S-07: hoy la prueba cuenta días y empieza con Play |
| "A las tres de la mañana, la pantalla entera es el botón" y la captura 5 | Descripción, novedades | S-06: pantalla Noche |
| "se retira sola" y la captura 4 | Descripción | S-06: hoja de Marea |
| "Madrugada: veinte minutos de mar que se retira solo" | Novedades | S-06. La receta ya está en `main` (`SmallHoursRecipe`); la pantalla no |
| "Mezclas con nombre, cuatro de la casa" | Novedades | S-06. Las cuatro recetas ya están en `main` (`HouseMix`) |
| "Ajustes › Escribir al autor" y la captura 6, "Lo que no hay" | Novedades, capturas | Ajustes y la página "Lo que no hay" no están en `main` ni tienen paquete asignado a la vista |
| "Restore purchase" y "Buy" | Notas de revisión, nota de la compra | S-07: hoy los botones llevan los textos antiguos (`paywall.restore`, `paywall.purchaseFormat`, `paywall.keepFormat`) |

Lo que sí se puede comprobar hoy en `main` está en la tabla de `notas-revision.md`.

## Lint de las listas de palabras

Los textos de esta carpeta y la política pasan las dos listas de `docs/design/10-GUIA-DE-COPY.md` (§0.4 a mano, §0.5 con expresiones regulares). Coincidencias declaradas, tres clases: las frases que la guía ya admite ("Sin suscripción", "No subscription", "not a medical product", "Lock Screen"); las palabras de diagnóstico de la opción A de palabras clave, que la guía solo permite en ese campo; y un falso positivo, la frase de la guía "Siete noches con todo […] Pro es un solo pago", que casa con el patrón pensado para impedir que se cuenten texturas Pro y aquí cuenta las noches de la prueba. El lint se pasó con un script fuera del repositorio; cuando S-08 amplíe `CopyLintTests`, estos ficheros deberían entrar en él.
