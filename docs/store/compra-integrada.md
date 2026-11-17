# Compra integrada · SleepNoise Pro

Un solo producto, no consumible. Se crea en App Store Connect, en "Compras dentro de la app", antes de enviar la versión 1.0, y se envía a revisión junto con ella.

## Datos del producto

| Campo | Valor |
|---|---|
| Tipo | No consumible (Non-Consumable) |
| Nombre de referencia (interno, no se ve en la tienda) | SleepNoise Pro |
| Identificador del producto | El valor de `AccessPolicy.proProductID` en `SleepNoise/Model/AccessPolicy.swift`, letra a letra. No se puede cambiar ni reutilizar después |
| Precio | El de `docs/PLAN-SIMPLE-1.0.md` §4.2, fijado a mano en la tienda de España. Sin precio de salida rebajado ni fecha de cambio programada |
| Disponibilidad | Los mismos países que la app. Cuáles son lo decide el dueño (`README.md`, fila "disponibilidad por países") |
| Family Sharing | Activado. Ver abajo |

## Nombre visible y descripción

El nombre visible es el que la app enseña como título de la hoja Pro y en la fila Pro de Ajustes (`ProProduct.displayName`, que llega de StoreKit), así que debe ser el mismo en los dos idiomas. La descripción no se ve en la app.

Inglés (EE. UU.), nombre visible:

```text en
SleepNoise Pro
```

Recuento: 14 de 30.

Inglés (EE. UU.), descripción:

```text en
Everything, one payment
```

Recuento: 23 de 45.

Español (España), nombre visible:

```text es
SleepNoise Pro
```

Recuento: 14 de 30.

Español (España), descripción:

```text es
Todo, un solo pago
```

Recuento: 18 de 45.

## Family Sharing

Se activa en la página del producto (sección "Family Sharing", botón "Turn On"; literal a comprobar), antes de enviarlo a revisión. Es una decisión cerrada (`docs/PLAN-SIMPLE-1.0.md` §4.2) y App Store Connect no deja desactivarlo una vez activado.

En el código, la compra de un familiar llega por `Transaction.currentEntitlements` igual que la propia y se reconoce por `ownershipType` (`SleepNoise/StoreKit/AppStoreProStore.swift`); una revocación, por ejemplo al salir del grupo familiar, quita Pro cuando deja de sonar (`PurchaseManager.applyAccess(canDowngrade:)`). La hoja Pro añade "En familia" (`pro.familia`) a la lista "con pro" salvo que la tienda responda que el producto no se comparte, y el recibo dice "· en familia" cuando la compra es de un familiar. La compra pendiente de aprobación tiene su aviso (`pro.pendiente`). Nada de esto se ha visto con un grupo familiar real: los tests usan la tienda de guion (`ProStoreTests.testAFamilyPurchaseArrivesAtLaunch`).

## Nota de revisión de la compra

Campo "Review Notes" del producto, en inglés:

```text en
SleepNoise Pro is the only in-app purchase of the app: a non-consumable, paid once, with Family Sharing turned on.
It adds ocean, fan, thunder, campfire, brook and cabin, the Tide (the sea paced to a slow breath) and saved mixes without a limit. White, pink, brown, rain and wind, the whole timer and three saved mixes are free for everyone.
To reach it, by day: tap "Mixes" on the bottom bar, then "Settings" (the last row), then the row under "pro". Before a trial or a purchase there is a shorter way: tap "All layers", then a texture marked "pro". The Pro sheet shows the price, "Buy" with the price and "Restore purchase".
By design the app sells nothing at night: the Pro sheet does not open between 21:00 and 07:00 on the iPhone's clock. Please test between 07:00 and 21:00, local time on the iPhone.
The sheet also stays shut, at any hour, on the night page: the main page as you find it after going back from "Night", the black screen with the clock that the bottom bar opens (to go back, press for about a second and lift). Tap the name of the mix at the top of the page to return to the day page.
The same sheet also starts the seven-night trial, which is described in the review notes of the app.
```

Recuento: 1208 caracteres. El tope del campo es amplio (4000, a comprobar en pantalla).

## Captura para revisión

App Store Connect pide una captura del producto para el revisor (no se publica). Vale la hoja Pro con el precio a la vista, hecha en un iPhone o en el simulador entre las 07:00 y las 21:00 y fuera de la página nocturna, que es cuando la hoja se abre.

## Lo que queda fuera de este fichero

- `SleepNoise/Resources/SleepNoise.storekit` es solo la tienda local de pruebas. Hoy coincide con esta página en lo que la app enseña: un único no consumible con el identificador de `AccessPolicy.proProductID`, `familyShareable` en `true`, el nombre visible de arriba en los dos idiomas y, como precio, la cifra de `docs/PLAN-SIMPLE-1.0.md` §4.2 (el fichero no lleva moneda: la pone el escaparate local, que es `USA`). Lo comprueba `ProStoreTests.testTheLocalStoreSellsOneFamilySharedProductAndClaimsNothingOld`. Sus descripciones no son las de esta página: pasan de los 45 caracteres que admite App Store Connect (74 la inglesa y 76 la española). En App Store Connect se pegan las de aquí.
- La nota de arriba nombra "Buy", "Restore purchase", "All layers", "Mixes", "Settings", "Night" y la palabra "pro": son las cadenas de la app en inglés (`pro.comprar`, `pro.restaurar`, `capas.todas`, `barra.mezclas`, `ajustes.titulo`, `barra.noche` y `comun.pro`). La comprobación, frase a frase, está en la tabla de `notas-revision.md`.
- El camino corto de la nota ("All layers" y una textura marcada "pro") solo existe antes de una prueba o de una compra, y la nota lo dice así: con la prueba en marcha o con Pro ninguna fila lleva esa palabra (`notas-revision.md`, tabla). El gesto de volver de "Night" es pulsar cerca de un segundo y levantar el dedo; mantener pulsado más de dos segundos no hace nada.
- La nota dice "with Family Sharing turned on": solo es cierto cuando el dueño lo activa en App Store Connect (`notas-revision.md`, condición 2).
- La compra de verdad no se ha hecho nunca, ni en el sandbox ni en un iPhone (`notas-revision.md`, condición 3).
- La nota no explica cómo funciona la prueba: eso se dice una sola vez, en las notas de la app (`notas-revision.md`, "Riesgo 3.1.1").
- La nota nombra las texturas de Pro, que dependen de la escucha del dueño (`README.md`, "Antes de enviar").
- Contrato de apps de pago, banco y fiscalidad: los firma el dueño. Sin ellos el producto no se puede enviar.
