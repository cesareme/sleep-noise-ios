# SleepNoise privacy policy

**Status.** Draft for the App Store privacy URL. Do not submit this URL until the three blanks at the end are filled in with a legal name, a contact address, and a retention period for email. The same blanks are still open in [`privacy/index.md`](privacy/index.md), which is the page prepared for GitHub Pages. This document and that one should be updated together.

Last updated: 17 November 2026.

The facts below describe the app in this repository at marketing version 1.0.0 (build 1). They are the basis for an App Store privacy label of **Data Not Collected**.

## English

SleepNoise does not collect, store on a server, or send any personal data.

**Who we are.** The seller named on the App Store product page for SleepNoise is responsible for the app. A legal name is not yet written in this repository. See the note at the end before this page is linked from App Store Connect.

**No account, no analytics, no ads.** The app has no sign-in, no analytics, and no advertising. It contains no third-party code. It does not use the advertising identifier and it does not show a tracking prompt.

**Network.** The app makes no connections of its own. There is no `URLSession` in the app. The only network use is Apple's. StoreKit asks the App Store for the price of the in-app purchase and handles buying it and restoring it. Sound is synthesized on the iPhone while it plays.

**What stays on the iPhone.** Mixes, levels, and settings are saved on the iPhone (`UserDefaults`). They leave it only inside backups the person makes with Apple. If the seven-night trial is started, a small record of it — when it started, when it was last observed, and how much time has been consumed — is kept in the Keychain of that iPhone. The item is not synchronized, and it is available only after the first unlock of that device. The app sends none of this to the developer or to anyone else.

**Purchases.** The one in-app purchase is handled by Apple. Apple gives the app proof of the purchase: which product, when, whether it is revoked, and whether it arrived through Family Sharing. That proof does not include a name, an email address, or payment details. The app stores, on the iPhone, that Pro is purchased, the date, whether the purchase is shared with the family, and the product name the store returned, so the receipt can be shown. Apple's sales reports to the developer are totals and do not identify a person. Apple's own privacy policy covers Apple's processing.

**If you write to us.** The app can open the person's own mail app, with the name of the app as the subject and nothing else filled in. That row is hidden until a public address is configured, and none is configured in this version. A message someone chooses to send is received at that address and used only to answer. How long it is kept, and the address itself, are not yet stated in this repository. A person will be able to ask for deletion by writing to the same address, and can complain to their data-protection authority.

**Permissions.** The app does not prompt for access to contacts, photos, location, microphone, tracking, or health data. It links CallKit only to learn whether a phone call is in progress, so playback does not resume over the call. It does not learn who is calling and it stores nothing from that check. Background audio is the product: after Play, sound continues with the screen locked.

**Children.** The app collects nothing from anyone, at any age. It is not in the Kids category.

**Changes.** If the app ever starts to collect or send data, this page will say so before that version ships. Reading or writing HealthKit, adding iCloud, or adding any network call of our own would be such a change.

**This page.** If it is hosted on GitHub Pages, GitHub may record visits to the page, as GitHub's own privacy statement describes. That hosting is separate from the app. The app does not load this page.

## Español

SleepNoise no recoge datos personales, no los guarda en un servidor y no los envía.

**Quiénes somos.** Quien figure como vendedor en la ficha de SleepNoise en el App Store responde de la app. En este repositorio todavía no hay un nombre legal. Antes de enlazar esta página desde App Store Connect, lee la nota del final.

**Sin cuenta, sin analítica, sin anuncios.** La app no tiene inicio de sesión, ni analítica, ni publicidad. No lleva código de terceros. No usa el identificador de publicidad ni muestra un aviso de rastreo.

**Red.** La app no hace conexiones propias. El único uso de la red es el de Apple: StoreKit pregunta al App Store el precio de la compra dentro de la app y se ocupa de comprarla y de restaurarla. El sonido se sintetiza en el iPhone mientras suena.

**Lo que se queda en el iPhone.** Las mezclas, los niveles y los ajustes se guardan en el iPhone. Solo salen de él dentro de las copias de seguridad que la persona hace con Apple. Si se empieza la prueba de siete noches, se guarda un registro pequeño en el llavero de ese iPhone: cuándo empezó, cuándo se observó por última vez y cuánto tiempo se ha consumido. El elemento no se sincroniza y solo está disponible tras el primer desbloqueo de ese dispositivo. La app no envía nada de esto al desarrollador ni a nadie más.

**Compras.** La única compra dentro de la app la gestiona Apple. Apple entrega a la app el justificante: qué producto, cuándo, si está revocada y si llegó por En familia. Ese justificante no incluye nombre, correo ni datos de pago. La app guarda en el iPhone que Pro está comprado, la fecha, si la compra es de un familiar y el nombre del producto que devolvió la tienda, para poder mostrar el recibo. Los informes de ventas que Apple da al desarrollador son totales y no identifican a una persona. El tratamiento que hace Apple se rige por su propia política.

**Si nos escribes.** La app puede abrir la app de correo de la persona, con el nombre de la app como asunto y nada más escrito. Esa fila permanece oculta hasta que haya una dirección pública, y esta versión no tiene ninguna. Un mensaje que alguien decide enviar se recibe en esa dirección y se usa solo para responder. Cuánto se conserva, y cuál es la dirección, todavía no constan en este repositorio. Se podrá pedir el borrado escribiendo a la misma dirección, y se puede reclamar ante la autoridad de protección de datos.

**Permisos.** La app no pide acceso a contactos, fotos, ubicación, micrófono, rastreo ni datos de salud. Enlaza CallKit solo para saber si hay una llamada en curso, y así no reanudar el sonido encima de ella. No sabe con quién es la llamada y no guarda nada de esa consulta. El audio en segundo plano es el producto: tras pulsar Play, el sonido sigue con la pantalla bloqueada.

**Menores.** La app no recoge nada de nadie, tenga la edad que tenga. No está en la categoría Infantil.

**Cambios.** Si la app empieza alguna vez a recoger o a enviar datos, esta página lo dirá antes de que esa versión se publique. Leer o escribir en Salud, añadir iCloud o hacer una conexión de red propia serían un cambio de ese tipo.

**Esta página.** Si se aloja en GitHub Pages, GitHub puede registrar las visitas, como explica su propia declaración. Ese alojamiento es distinto de la app. La app no carga esta página.

## Before this page is linked from App Store Connect

Three facts are deliberately absent, because they are not in the repository and this document does not invent them:

1. The legal name of the controller (the person or company responsible for the app and for any email it receives).
2. The contact address.
3. The period after which a reply email is deleted.

Until those three are written here and in [`privacy/index.md`](privacy/index.md), this page is the policy text and is not yet the privacy URL. Guideline 5.1.1 also expects the policy to be readable inside the app. The page "What's not here" does not yet include this text.
