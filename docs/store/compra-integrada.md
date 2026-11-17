# Compra integrada · SleepNoise Pro

Un solo producto, no consumible. Se crea en App Store Connect, en "Compras dentro de la app", antes de enviar la versión 1.0, y se envía a revisión junto con ella.

## Datos del producto

| Campo | Valor |
|---|---|
| Tipo | No consumible (Non-Consumable) |
| Nombre de referencia (interno, no se ve en la tienda) | SleepNoise Pro |
| Identificador del producto | El valor de `AccessPolicy.proProductID` en `SleepNoise/Model/AccessPolicy.swift`, letra a letra. No se puede cambiar ni reutilizar después |
| Precio | El de `docs/PLAN-SIMPLE-1.0.md` §4.2, fijado a mano en la tienda de España. Sin precio de salida rebajado ni fecha de cambio programada |
| Disponibilidad | Todos los países donde se venda la app |
| Family Sharing | Activado. Ver abajo |

## Nombre visible y descripción

El nombre visible es el que la app enseña como título de la hoja Pro (`product.displayName`), así que debe ser el mismo en los dos idiomas.

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

En el código, la compra de un familiar llega por `Transaction.currentEntitlements` igual que la propia, y una revocación (por ejemplo, salir del grupo familiar) quita Pro: `SleepNoise/StoreKit/PurchaseManager.swift`. La compra pendiente de aprobación familiar tiene su aviso. Ninguna de las dos cosas se ha probado con un grupo familiar real.

## Nota de revisión de la compra

Campo "Review Notes" del producto, en inglés:

```text en
SleepNoise Pro is the only in-app purchase of the app: a non-consumable, paid once, with Family Sharing turned on.
It adds ocean, fan, thunder, campfire, brook and cabin, the Tide (the sea paced to a slow breath) and saved mixes without a limit. White, pink, brown, rain and wind, the whole timer and three saved mixes are free for everyone.
To reach it: on the main page tap "All layers", then tap a texture marked "pro". The Pro sheet shows the price, the Buy button and "Restore purchase".
By design the app sells nothing at night: the Pro sheet does not open between 21:00 and 07:00 on the iPhone's clock. Please test between 07:00 and 21:00, local time on the iPhone.
The seven-night trial that starts on the same sheet is local to the iPhone and is not a StoreKit product: nothing is charged and no payment method is requested.
```

Recuento: 833 caracteres. El tope del campo es amplio (4000, a comprobar en pantalla).

## Captura para revisión

App Store Connect pide una captura del producto para el revisor (no se publica). Vale la hoja Pro con el precio a la vista, hecha en un iPhone o en el simulador entre las 07:00 y las 21:00, que es cuando la hoja se abre.

## Lo que queda fuera de este fichero

- `SleepNoise/Resources/SleepNoise.storekit` es solo para pruebas locales y hoy no coincide con esta página: `familyShareable` está en `false`, las descripciones pasan de 45 caracteres y el precio de prueba es otro. Corregirlo es código y le toca a S-07.
- La nota de arriba nombra el botón "Restore purchase" y la prueba que empieza en la hoja Pro. En `main` el botón todavía dice "Restore purchases" y la prueba todavía empieza con Play. Ver `notas-revision.md`, tabla de estado.
- Contrato de apps de pago, banco y fiscalidad: los firma el dueño. Sin ellos el producto no se puede enviar.
