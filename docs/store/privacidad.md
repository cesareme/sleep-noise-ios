# Privacidad, edad, exportación, categoría y derechos

Respuestas para los cuestionarios de App Store Connect que no son texto de ficha. Cada una lleva la comprobación en el código de `main` (17-11-2026). Los literales de los cuestionarios cambian con el tiempo: donde pone "a comprobar", manda lo que se lea en pantalla.

## 1. Privacidad de la app (App Privacy)

| Pregunta | Respuesta |
|---|---|
| ¿Tú o tus socios externos recogéis datos de esta app? | No, no recogemos datos de esta app |
| Etiqueta que resulta | "Data Not Collected" (en español, "No se recopilan datos"; literal a comprobar) |
| ¿Usa la app datos para hacer seguimiento? | No. No hay aviso de seguimiento ni identificador de publicidad |
| URL de la política de privacidad | La de GitHub Pages; ver `README.md`. Es obligatoria, y la directriz 5.1.1(i) pide además que la política se pueda leer dentro de la app: en 1.0 ese sitio es la página "Lo que no hay" (`README.md`, "Antes de enviar") |

Por qué es cierto:

| Hecho | Comprobación |
|---|---|
| La app no hace peticiones de red propias | Ningún uso de `URLSession`, `URLRequest` ni `Network` en `SleepNoise/` |
| No hay código de terceros | `project.yml` no declara paquetes ni dependencias |
| No hay cuenta, analítica ni anuncios | No existe código para ello; los únicos marcos son los de Apple (`AVFoundation`, `MediaPlayer`, `StoreKit`, `AppIntents`, `Security`, `SwiftUI`) |
| Mezclas y ajustes se guardan en el iPhone y la app no los envía a nadie | `UserDefaults`; el manifiesto declara la razón `CA92.1`. Entran en la copia de seguridad del iPhone que la persona haga con Apple, que no es recogida de datos por la app |
| El manifiesto de privacidad coincide | `SleepNoise/Resources/PrivacyInfo.xcprivacy`: `NSPrivacyTracking` en `false`, sin dominios y sin tipos de datos recogidos |
| La compra la gestiona Apple | `StoreKit` 2; la app recibe de Apple la transacción firmada y de ella lee el identificador del producto y si está revocada (`PurchaseManager`). No lleva nombre, correo ni datos de pago |
| No pide permisos | `Info.plist` no tiene claves de descripción de uso |

Matices que conviene tener presentes:

- El estado de la prueba irá al llavero del iPhone (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, sin sincronizar). No sale del iPhone, así que no es recogida. Hoy `main` todavía lo guarda en `UserDefaults`; lo cambia S-07.
- "Escribir al autor" abrirá el correo de la persona. Un mensaje que alguien decide enviar desde su propia app de correo no es recogida de datos por la app, pero quien lo recibe sí trata un dato personal: por eso la política dice quién responde, cuánto se guarda el mensaje y cómo pedir que se borre. La fila todavía no existe en `main`.
- Los informes de ventas de App Store Connect son agregados y no identifican a nadie.
- La respuesta deja de valer si entra red, un SDK, un informe de diagnóstico que salga de la app o iCloud. Cualquiera de esos cambios obliga a repasar este cuestionario antes de enviar.

## 2. Clasificación por edades

Resultado esperado: 4+, la más baja.

| Bloque del cuestionario | Respuesta |
|---|---|
| Violencia, contenido sexual o desnudos, lenguaje soez, alcohol, tabaco o drogas, terror, apuestas y concursos | Ninguno |
| Acceso web sin restricciones | No. No hay navegador ni vista web (ningún `WKWebView` ni `SafariServices`) |
| Contenido generado por usuarios, mensajería o chat | No. Las mezclas guardadas no se comparten ni se envían a nadie |
| Publicidad | No |
| Información de salud o bienestar | Ninguna. La app no da consejos ni mide nada |
| Controles parentales o verificación de edad dentro de la app | No hay; no hacen falta |
| Hecha para niños (categoría Kids) | No |

A comprobar: Apple cambió el cuestionario y los tramos de edad en 2025, y los literales de arriba son por tema, no palabra por palabra. Si la hoja de Marea sale con la frase sobre estudios de respiración que recoge la guía de copy (`marea.evidencia`), la pregunta sobre temas de salud o bienestar se responde con el nivel más bajo que no sea "ninguno", y se anota aquí. Esa frase tampoco debe verse en la captura 4 (`README.md`, "Antes de enviar").

## 3. Cumplimiento de exportación

| Pregunta | Respuesta |
|---|---|
| ¿Usa la app cifrado? | La app no implementa ni incluye cifrado propio. Solo usa lo que trae iOS |
| Qué declara el proyecto | `SleepNoise/Resources/Info.plist` tiene `ITSAppUsesNonExemptEncryption` en `false`, así que App Store Connect no pregunta en cada subida |
| Documentación que subir | Ninguna |

Comprobación: en `SleepNoise/` no se importa `CryptoKit` ni `CommonCrypto`, y no hay red, luego tampoco HTTPS. Lo único cercano es el llavero (`Security`) y `StoreKit`, que son servicios del sistema. Si App Store Connect pregunta de todos modos, la opción es la de "ninguno de los algoritmos mencionados" (literal a comprobar).

## 4. Categoría

| | Recomendación | Por qué |
|---|---|---|
| Principal | Salud y forma física (Health & Fitness) | Es donde están las búsquedas y las listas de apps de sonidos para dormir (`docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md` §7.5). `Info.plist` ya declara `public.app-category.healthcare-fitness` |
| Secundaria | Estilo de vida (Lifestyle) | Recoge a quien busca un objeto para la noche y no una app de salud; es la que fijan el informe §7.5 y el documento 11 §2.10 |

Estar en Salud y forma física no obliga a afirmar nada sobre la salud, y la ficha no lo hace. Si App Review lo discutiera, la salida es intercambiar las dos categorías; la ficha no cambia.

## 5. Derechos de contenido

| Pregunta | Respuesta |
|---|---|
| ¿Contiene, muestra o da acceso la app a contenido de terceros? | No |

Por qué: todo el sonido lo genera el código de la app mientras suena; no hay grabaciones, muestras ni música con licencia. La tipografía es la del sistema. No hay imágenes ni textos de terceros, ni SDK. El icono es propio (paquete S-10).

## 6. Otras preguntas que App Store Connect hace al enviar

| Pregunta | Respuesta |
|---|---|
| ¿Hace falta iniciar sesión para usar la app? | No |
| ¿Usa el identificador de publicidad (IDFA)? | No |
| Condición de comerciante para la Unión Europea (Ley de Servicios Digitales) | La declara el dueño en App Store Connect. Si se declara comerciante, Apple publica en la ficha los datos de contacto que se den allí; no se escriben en este repositorio |
| Línea de copyright | La escribe el dueño |
