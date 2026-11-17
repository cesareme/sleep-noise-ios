# Guía del dueño · de `main` a la App Store

Fecha: 17-11-2026. Esta guía lleva SleepNoise 1.0 desde el repositorio hasta la tienda, en orden. Está escrita para quien no trabaja con iOS todos los días: cada paso dice qué haces tú, cuánto tarda, cómo saber que está hecho y qué puede hacer Claude después.

Documentos hermanos, en esta misma carpeta:

| Fichero | Para qué |
|---|---|
| `ESCUCHA.md` | Escuchar las once texturas, las mezclas de la casa, los fundidos, Marea y Madrugada en un iPhone real |
| `PRUEBAS-EN-DISPOSITIVO.md` | Lo que ningún simulador prueba: la noche entera, interrupciones, auriculares, Atajos, compra, prueba de 7 noches, actualización |
| `BETA.md` | Invitación a TestFlight, qué probar en 5 noches y formulario de comentarios |
| `DECISIONES.md` | Todas las decisiones que siguen abiertas y lo que queda fuera de 1.0 |

## Cómo leer esta guía

- **Estado al escribirla.** El código se leyó en el commit `80ebd1b` (623 tests), que lleva la hoja Pro y la prueba de 7 noches (paquete S-07). La rama `main` todavía no lo tiene. El paquete S-08 (catálogo de cadenas, capturas y firma local) estaba en curso, con cambios sin confirmar: lo que esta guía dice de `Config/` y de `scripts/screenshots.sh` sale de ahí y puede cambiar antes de llegar a `main`. Donde un paso depende de algo que aún no está en `main`, lo dice.
- **Ningún plazo de Apple está garantizado.** Lo que esta guía dice de aprobaciones, procesado de builds, revisión de la beta, revisión de la tienda y aparición de la ficha es orientación: Apple no se compromete a ninguno. Cuenta con margen.
- **Las pantallas de Apple y de GitHub cambian.** Los nombres de menús se dan como orientación. Donde pone *comprobar en la pantalla*, manda lo que leas allí, no esta guía.
- **Nada personal en el repositorio.** El repositorio es público. El identificador de equipo, los datos del banco, tu teléfono y los correos de los probadores no se escriben en ningún fichero versionado, ni en un commit, ni en un PR. El último apartado lo resume.
- **"Claude después"** es lo que puedes pedirle a Claude Code en el Mac una vez hecho tu paso. Claude no entra en tus cuentas, no acepta contratos, no escribe contraseñas ni datos de pago y no pulsa "enviar" por ti: eso es tuyo.

## El camino de un vistazo

| # | Paso | Tu tiempo | Espera de terceros | Depende de |
|---|---|---|---|---|
| 1 | Cuenta de desarrollador | 30 min | De horas a varios días | Nada |
| 2 | Firma: el identificador de equipo en tu Mac | 20 min | No | 1 |
| 3 | Proteger `main` y el correo de los commits | 20 min | No | Nada |
| 4 | Crear la ficha y comprobar el nombre | 20 min | No | 1 |
| 5 | Acuerdos, banco y fiscalidad | 1 h | De uno a varios días | 1 |
| 6 | Producto Pro con En familia | 30 min | No | 4 y 5 |
| 7 | Política de privacidad en GitHub Pages | 30 min | Minutos | 3 |
| 8 | Identificador de la app y dirección de contacto en `AppLinks` | 10 min | No | 4 |
| 9 | Rellenar la ficha desde `docs/store/` | 1 h 30 min | No | 4, 6 y 7 |
| 10 | Escucha y pruebas en tu iPhone | 3 h y una noche | No | 2; la compra en sandbox (prueba 8.B), además 5 y 6 |
| 11 | Subir un build a TestFlight con Xcode | 45 min la primera vez | Procesado: de minutos a horas | 2 y 4 |
| 12 | Beta de 5 noches | 2 h de gestión | Revisión de la beta: sin plazo fijo, a menudo en torno a un día | 5, 6, 8, 10 y 11 |
| 13 | Envío a revisión | 1 h | Revisión de Apple: de uno a varios días | Todo lo anterior |
| 14 | Si Apple rechaza | Según el caso | Sí | 13 |
| 15 | Publicación y después | 30 min | No | 13 |

Total tuyo: entre tres y cuatro días repartidos en cuatro semanas, como prevé `docs/PLAN-SIMPLE-1.0.md` §6. Los pasos 1 y 5 tienen esperas que no controlas: empiézalos el primer día.

Fechas del plan: nombre definitivo el 04-12-2026, envío a revisión como tarde el viernes 11-12-2026. Para llegar a esa fecha, el build de la beta tiene que estar subido y en revisión de beta hacia el miércoles 02-12-2026: la cuenta está en el paso 12.

---

## 1. Cuenta de desarrollador

Tiempo: 30 minutos, más la espera de la aprobación.

Qué haces tú:

- [ ] Decide si te inscribes como **persona** o como **empresa**. Como persona, en la tienda aparece tu nombre como vendedor. Como empresa aparece la razón social, y Apple pide un número D-U-N-S, que puede tardar días. Esta elección no se cambia con facilidad después: léela dos veces. (`DECISIONES.md`, D-48.)
- [ ] Inscríbete en el Apple Developer Program desde la web de desarrolladores de Apple o desde la app Apple Developer. Hace falta una cuenta de Apple con autenticación de doble factor. Tiene una cuota anual; el importe, *comprobar en la pantalla*.
- [ ] Cuando esté aprobada, entra en la web de desarrolladores, apartado de la cuenta (Membership o similar, *comprobar en la pantalla*) y localiza el **Team ID**: diez caracteres entre letras y cifras. Apúntalo fuera del repositorio.
- [ ] Comprueba que puedes entrar en App Store Connect con esa misma cuenta.

Hecho cuando: ves tu Team ID y App Store Connect te deja entrar.

Claude después: nada todavía. El Team ID se usa en el paso 2.

## 2. Firma: el identificador de equipo en tu Mac, sin subirlo

Tiempo: 20 minutos.

Qué necesitas saber antes:

- El proyecto de Xcode **no está en Git**. Lo genera XcodeGen a partir de `project.yml` cada vez (`xcodegen generate`, y también `scripts/verify.sh`). Por eso, lo que elijas a mano en Xcode se pierde en la siguiente generación, y el equipo de firma tiene que vivir en un fichero.
- El paquete S-08 trae ese fichero. Al escribir esta guía estaba en su copia de trabajo, **sin confirmar todavía**, así:

| Fichero | En Git | Qué es |
|---|---|---|
| `Config/Signing.xcconfig` | Sí | La configuración de firma, sin equipo, certificado ni perfil. Incluye de forma opcional el fichero local: si no existe, no pasa nada, y el simulador y la CI compilan igual |
| `Config/Local.xcconfig.example` | Sí | La plantilla: una línea `DEVELOPMENT_TEAM` con un valor de ejemplo |
| `Config/Local.xcconfig` | **No** (está en `.gitignore`) | El tuyo, con tu Team ID. Solo existe en tu Mac |

- `project.yml` apunta a `Config/Signing.xcconfig` para Debug y para Release, y mantiene la firma automática.
- En `main` nada de esto existe hasta que S-08 se fusione, y el README de la raíz todavía dice que el equipo se elige en Xcode. Si cuando leas esto `Config/` o el README dicen otra cosa, **mandan ellos** y no esta sección.

Qué haces tú:

- [ ] En Xcode, menú Settings, pestaña Accounts: añade tu cuenta de Apple. Debe aparecer tu equipo.
- [ ] En el Terminal, dentro de la carpeta del repositorio, copia la plantilla: `cp Config/Local.xcconfig.example Config/Local.xcconfig`.
- [ ] Abre `Config/Local.xcconfig` y sustituye el valor de ejemplo por tu Team ID.
- [ ] Ejecuta `git status`. **`Config/Local.xcconfig` no debe aparecer.** Si aparece, para y avisa: falta la línea en `.gitignore`.
- [ ] Conecta el iPhone por cable, acéptalo como dispositivo de confianza y, en el iPhone, activa el **modo de desarrollador** (Ajustes, Privacidad y seguridad; pide reiniciar; *comprobar en la pantalla*).
- [ ] `xcodegen generate`, abre `SleepNoise.xcodeproj` y elige **tu iPhone como destino**.
- [ ] En el target **SleepNoise**, pestaña *Signing & Capabilities*, el equipo ya debe estar elegido. Con una cuenta recién creada, sin ningún dispositivo registrado, Xcode no puede crear el perfil y enseña un error en rojo mientras no haya un iPhone conectado y elegido: ese error es el esperado y se va cuando el dispositivo queda registrado (*comprobar en la pantalla*). Con tu iPhone ya como destino no debe quedar ninguno.
- [ ] Pulsa Run. La primera vez Xcode registra el dispositivo y el identificador de la app en tu cuenta.

Si necesitas probar en el iPhone **antes** de que S-08 esté en `main`: genera el proyecto, elige el equipo a mano en *Signing & Capabilities* y pulsa Run. Vale, pero se pierde en cada regeneración.

Lo que nunca se sube: el Team ID, certificados (`.p12`, `.cer`), perfiles (`.mobileprovision`) ni ficheros `.env`. Todos están cubiertos por `.gitignore`; aun así, mira `git status` antes de cada commit.

Hecho cuando: la app arranca en tu iPhone desde Xcode y `git status` no muestra nada nuevo.

Claude después:

- Crear el fichero local por ti si le dictas el Team ID en la conversación: lo escribe en `Config/Local.xcconfig` y en ningún otro sitio.
- Instalar en tu iPhone el build que le pidas y dejarlo listo para `ESCUCHA.md` y `PRUEBAS-EN-DISPOSITIVO.md`.
- Actualizar el README de la raíz si al fusionar S-08 sigue diciendo que el equipo se elige en Xcode.

## 3. Proteger `main` y el correo de los commits

Tiempo: 20 minutos.

Qué haces tú, en GitHub, en los ajustes del repositorio (Settings, apartado Branches o Rules; GitHub tiene dos interfaces para lo mismo, *comprobar en la pantalla*):

- [ ] Crea una regla para la rama `main` que exija **pull request antes de fusionar**.
- [ ] En esa opción, deja las **aprobaciones requeridas en 0**. La interfaz clásica las trae en 1 al marcarla (*comprobar en la pantalla*), y GitHub no deja que nadie apruebe su propio PR. Todos los PR de este repositorio salen de tu cuenta, también los que abre y fusiona Claude: con 1 aprobación y la regla aplicada a los administradores, en `main` no se podría fusionar nada. Por lo mismo, no marques la revisión de propietarios de código (Code Owners) mientras no haya una segunda cuenta que revise (`DECISIONES.md`, D-45). La revisión entre agentes de `AGENTS.md` §6 sigue haciéndose; lo que no puede ser es una aprobación de GitHub.
- [ ] En la misma regla, exige que pasen las comprobaciones de estado y marca como obligatoria la que se llama **`verify`**. Es el nombre del trabajo de `.github/workflows/ci.yml`; si alguien lo renombra, hay que actualizar la regla. Para que GitHub te deje elegirla, la CI tiene que haberse ejecutado al menos una vez.
- [ ] Impide los push forzados y el borrado de la rama.
- [ ] Decide si la regla se aplica también a los administradores. Recomendado: sí.
- [ ] En los ajustes de tu cuenta de GitHub, apartado Emails, activa la opción de mantener privado tu correo y copia la dirección `noreply` que GitHub te da. Configúrala en tu Mac con `git config user.email` dentro del repositorio. Los commits que ya están en GitHub conservan la dirección anterior: ver `DECISIONES.md`, D-44. Los que aún no has subido se pueden corregir antes del push, una vez configurada la dirección nueva: `git commit --amend --reset-author --no-edit` para el último, o `git rebase --exec 'git commit --amend --reset-author --no-edit' main` para todos los de la rama. La rama que trae esta guía está en ese caso: sus commits se hicieron con la dirección que había configurada.

Hecho cuando: un push directo a `main` es rechazado, un PR con la CI en rojo no se puede fusionar y un PR tuyo con la CI en verde sí.

Claude después:

- Añadir `.github/CODEOWNERS` para `scripts/`, `.github/` y `project.yml`, pendiente desde S-01, solo si decides tener una segunda cuenta que revise (`DECISIONES.md`, D-45). Hoy la CI avisa cuando un PR toca la puerta, pero no lo impide; con una sola cuenta, el fichero tampoco impide nada y, exigido en la regla, lo bloquea todo.

## 4. Crear la ficha y comprobar el nombre

Tiempo: 20 minutos. Conviene hacerlo el primer día: es la única forma segura de saber si el nombre está libre.

Qué haces tú, en App Store Connect:

- [ ] En la lista de apps, crea una app nueva. Te pedirá, con estos nombres u otros parecidos (*comprobar en la pantalla*):
  - **Plataforma:** iOS.
  - **Nombre:** el de `docs/store/ficha-en.md`. Si ya lo usa otra app, App Store Connect lo rechaza aquí mismo. Si pasa, el nombre queda reservado para ti.
  - **Idioma principal:** inglés (EE. UU.), como indica `docs/store/README.md`. El español (España) se añade después como segunda localización.
  - **Identificador de paquete (Bundle ID):** el valor de `PRODUCT_BUNDLE_IDENTIFIER` de `project.yml`, letra a letra. Si no aparece en el desplegable, es que aún no está registrado: se registra solo al ejecutar la app en tu iPhone con firma automática (paso 2), o a mano en la web de desarrolladores.
  - **SKU:** un código interno tuyo. No se ve en la tienda.
- [ ] Anota el **identificador numérico de la app** (aparece como "Apple ID" en la información de la app; es un número, no tu cuenta). Lo necesita el paso 8.
- [ ] Si el nombre está ocupado: no improvises uno. Ve a `DECISIONES.md`, D-02.

Hecho cuando: la app existe en App Store Connect con su nombre y tienes su identificador numérico.

Claude después: nada en Connect. Con el identificador, el paso 8.

## 5. Acuerdos, banco y fiscalidad

Tiempo: 1 hora, más la espera. Sin esto no se puede vender Pro, y es probable que la compra tampoco cargue en las pruebas de sandbox ni en TestFlight.

Qué haces tú, en App Store Connect, en el apartado de negocio (Business, o "Acuerdos, impuestos y banca", *comprobar en la pantalla*):

- [ ] Acepta el **acuerdo de apps de pago** (Paid Apps Agreement). Solo lo puede aceptar el titular de la cuenta.
- [ ] Añade una **cuenta bancaria** para cobrar. Los datos del banco se escriben solo allí.
- [ ] Rellena los **formularios fiscales** que te presente. Para alguien de fuera de Estados Unidos suele haber un formulario estadounidense además de los datos del país propio. Si dudas de una respuesta, consulta a tu asesor: esta guía no da consejo fiscal.
- [ ] Declara tu **condición de comerciante** para la Unión Europea (Ley de Servicios Digitales). Si te declaras comerciante, Apple publica en la ficha los datos de contacto que des allí: decide antes qué dirección y qué teléfono quieres que sean públicos. Sin esta declaración la app no se distribuye en la UE.
- [ ] Solicita el **Small Business Program** (comisión reducida). Se pide desde la web de desarrolladores; las condiciones y la fecha en que empieza a aplicarse, *comprobar en la pantalla*.
- [ ] Espera a que el acuerdo aparezca como activo. La verificación del banco y de los impuestos puede tardar días.

Hecho cuando: el acuerdo de apps de pago figura como activo.

Claude después: nada. Nada de esto toca el repositorio.

## 6. Producto Pro con En familia

Tiempo: 30 minutos. Todo el contenido está en `docs/store/compra-integrada.md`: aquí solo va el orden.

Qué haces tú, en App Store Connect, dentro de la app, en el apartado de compras dentro de la app:

- [ ] Crea un producto de tipo **no consumible**.
- [ ] **Identificador del producto:** el valor de `AccessPolicy.proProductID` en `SleepNoise/Model/AccessPolicy.swift`, letra a letra. No se puede cambiar ni reutilizar después: cópialo y pégalo, no lo teclees.
- [ ] **Nombre de referencia**, **nombre visible** y **descripción** en inglés y en español: los de `compra-integrada.md`. El nombre visible es el título que enseña la hoja Pro, así que debe ser el mismo en los dos idiomas.
- [ ] **Precio:** el de `docs/PLAN-SIMPLE-1.0.md` §4.2, con España como país de referencia. Sin precio de salida rebajado y sin cambio programado. Apple calcula los demás países; revisa dos o tres.
- [ ] **En familia (Family Sharing):** actívalo en la página del producto. **No se puede desactivar después.** Es una decisión cerrada del plan.
- [ ] **Nota de revisión** del producto: el bloque en inglés de `compra-integrada.md`.
- [ ] **Captura para revisión:** una captura de la hoja Pro con el precio a la vista, hecha de día (entre las 07:00 y las 21:00 del reloj del iPhone, que es cuando la hoja se abre). No se publica.
- [ ] Deja el producto listo para enviar. El primer producto de una app se envía a revisión **junto con la versión**: en el paso 13 hay que añadirlo a la página de la versión.

Hecho cuando: el producto existe, con sus dos localizaciones, precio, En familia y captura, y su estado indica que está listo para enviar.

Claude después:

- Comprobar que `SleepNoise/Resources/SleepNoise.storekit` (la tienda local de pruebas) dice lo mismo que has puesto en Connect.
- Generar la captura de la hoja Pro en el simulador con el estado de depuración `-pageState proOffer`. Lleva una tienda de guion: si prefieres que el precio sea el real, hazla tú en el iPhone con sandbox.

## 7. Política de privacidad en GitHub Pages

Tiempo: 30 minutos. Sin esta URL no se puede enviar. El detalle está en `docs/store/README.md`, apartado "GitHub Pages".

Qué haces tú:

- [ ] Decide los tres datos que la política lleva entre corchetes en `docs/privacy/index.md`: la **dirección de contacto**, **quién responde** de la app (nombre o razón social) y el **plazo** en que se borran los correos recibidos. Los tres quedarán a la vista en un repositorio público y en una web pública. Conviene una dirección creada para la app.
- [ ] Pásaselos a Claude para que abra el PR. No actives Pages mientras quede un corchete.
- [ ] **Antes de activar Pages**, que esté resuelto qué se publica. Con el ajuste más simple, GitHub publica como web **toda** la carpeta `docs/`: planes, precios, investigación sobre otras apps y estas guías. `docs/store/README.md` propone dos formas de publicar solo `privacy/` y avisa de que ninguna está hecha ni probada. La lista de exclusiones que propone es anterior a esta carpeta: hay que añadirle `lanzamiento`.
- [ ] En GitHub, ajustes del repositorio, apartado Pages: origen "Deploy from a branch", rama `main`, carpeta `/docs`. Guarda. (*Comprobar en la pantalla*.)
- [ ] Al cabo de un minuto, abre la dirección que GitHub te muestra, con `/privacy/` al final. Debe abrir la política en los dos idiomas.
- [ ] Comprueba que **lo demás da 404**: prueba al menos una ruta de `store`, una de `research`, una de `design` y una de `lanzamiento`.

Hecho cuando: la URL de la política abre, no queda ningún corchete y las demás rutas no existen en la web.

Claude después:

- El PR que rellena los tres marcadores.
- El PR que limita lo publicado a `privacy/` (un `docs/_config.yml` con exclusiones, o un flujo de GitHub Actions que publique solo esa carpeta) y la comprobación de las rutas una vez activo.

## 8. Identificador de la app y dirección de contacto en `AppLinks`

Tiempo: 10 minutos tuyos.

Por qué importa: en `SleepNoise/Features/Pro/ProSheetLogic.swift`, `AppLinks.appStoreID` y `AppLinks.authorAddress` están vacíos. Mientras lo estén, la app **no enseña** "Escribir una reseña" en el recibo ni "Escribir al autor" en Ajustes, y nada avisa de ello. La 1.0 saldría sin ninguna forma de contacto dentro de la app.

Qué haces tú:

- [ ] Dale a Claude el **identificador numérico** de la app (paso 4).
- [ ] Dale la **dirección pública de contacto**, la misma de la política de privacidad. Quedará escrita en el código de un repositorio público: es su función, pero que sea una dirección hecha para esto y no la tuya personal.

Hecho cuando: en un build instalado en tu iPhone, Ajustes enseña "Escribir al autor" y abre tu app de correo con la dirección puesta, y el recibo de Pro enseña "Escribir una reseña".

Claude después:

- El PR que rellena las dos constantes y repite las capturas de Ajustes y del recibo.
- "Escribir una reseña" abre la página de la tienda, que no existe hasta que la app se publica: antes solo se puede comprobar que el enlace se forma bien. Queda como comprobación del paso 15.

## 9. Rellenar la ficha desde `docs/store/`

Tiempo: 1 hora y 30 minutos. Los textos ya están escritos y contados; tu trabajo es pegarlos y decidir lo que `docs/store/README.md` deja a tu elección.

Antes de pegar nada:

- [ ] Lee la tabla "Antes de enviar: lo que estos textos dan por hecho" de `docs/store/README.md`. Cada fila es una frase de la ficha que depende de algo: la escucha, la prueba de 7 noches, la frase "nunca se repite". Lo que no se cumpla en el build que envíes, se quita de la ficha.
- [ ] Cierra las decisiones de ficha de `DECISIONES.md` (D-11 y D-16 a D-22). Si no decides, cada una tiene su texto por defecto.

Qué haces tú, en App Store Connect, en el orden de `docs/store/README.md`:

- [ ] **Privacidad de la app** (cuestionario): respuestas de `docs/store/privacidad.md` §1. El resultado debe ser "no se recopilan datos". Publica el cuestionario.
- [ ] **Clasificación por edades:** `privacidad.md` §2. Resultado esperado: la más baja.
- [ ] **Categoría** principal y secundaria: `privacidad.md` §4.
- [ ] **Derechos de contenido** y **cumplimiento de exportación:** `privacidad.md` §3 y §5.
- [ ] **Precio y disponibilidad de la app:** gratuita; países en los que se vende. Antes de marcarlos todos, mira `DECISIONES.md`, D-51: la app enlaza `CallKit` y China continental queda fuera mientras no se compruebe que esa tienda lo admite.
- [ ] **Página de la versión 1.0, en inglés:** nombre, subtítulo, texto promocional, descripción y palabras clave de `docs/store/ficha-en.md`.
- [ ] **Añade la localización española** y pega `docs/store/ficha-es.md`.
- [ ] **URL de privacidad:** la del paso 7. **URL de soporte:** obligatoria; puede ser la misma.
- [ ] **Capturas:** las seis de la ficha, en los dos idiomas. Las genera `scripts/screenshots.sh` (paquete S-08, en curso), que las deja en `.build/store-shots/`, sin versionar, compuestas con su titular y al tamaño de la pantalla de 6,9 pulgadas. Si Connect pide algún tamaño más, *comprobar en la pantalla*.
- [ ] **Copyright:** lo escribes tú.

Hecho cuando: la página de la versión no muestra avisos de campos pendientes, salvo el build y la información para revisión.

Claude después:

- Ejecutar `scripts/screenshots.sh` y enseñarte las doce capturas antes de que las subas.
- Repasar la ficha contra el build real y decirte qué frases sobran.
- Contar de nuevo los caracteres si quitas una textura o cambias un texto.

## 10. Escucha y pruebas en tu iPhone

Tiempo: unas 3 horas y una noche.

- [ ] `ESCUCHA.md`: una hora con auriculares y otra por el altavoz. El resultado es un sí, un no o un "retocar" por textura. **La textura que no pase no entra en 1.0** y hay que quitarla de la ficha, de las notas y de la captura de Capas.
- [ ] `PRUEBAS-EN-DISPOSITIVO.md`: la noche entera, las interrupciones, los auriculares, los Atajos, la pantalla de bloqueo, la compra en sandbox, la prueba de 7 noches y la actualización. La compra en sandbox necesita el acuerdo activo (paso 5) y el producto creado (paso 6); lo demás solo necesita el paso 2.

Hecho cuando: las dos tablas están rellenas y cada "no" tiene dueño.

Claude después: corregir lo que salga (paquete S-11). Los cambios de sonido tienen un solo escritor y van de uno en uno.

## 11. Subir un build a TestFlight con Xcode

Tiempo: 45 minutos la primera vez; después, 15.

Antes:

- [ ] El código que quieres probar está en `main`, con la CI en verde.
- [ ] El número de versión y el de build son los que tocan. Viven en `project.yml` (`MARKETING_VERSION` y `CURRENT_PROJECT_VERSION`). Cada subida necesita un número de build mayor que el anterior. Subirlo es un PR pequeño de Claude. Xcode, al distribuir, también puede ofrecer gestionar el número por ti (*comprobar en la pantalla*).

Qué haces tú:

- [ ] En el Terminal: `git switch main`, `git pull`, `xcodegen generate`. Abre el proyecto.
- [ ] Comprueba el equipo de firma (paso 2).
- [ ] En el selector de destino elige **Any iOS Device** (no un simulador ni tu iPhone).
- [ ] Menú Product, **Archive**. Tarda unos minutos. Al terminar se abre el Organizer con el archivo.
- [ ] Pulsa **Distribute App** y elige el destino de App Store Connect o TestFlight (los nombres de las opciones cambian entre versiones de Xcode, *comprobar en la pantalla*). Acepta la firma automática.
- [ ] Espera el correo de Apple o mira la pestaña TestFlight de la app en App Store Connect: el build aparece primero como "procesando".
- [ ] El proyecto ya declara que no usa cifrado propio (`ITSAppUsesNonExemptEncryption` en `false`), así que Connect no debería preguntar por exportación. Si pregunta, la respuesta está en `docs/store/privacidad.md` §3.

Lo que cambia en un build de TestFlight frente a uno lanzado desde Xcode:

- Los estados de depuración (`-pageState`, `-gallery`) **no existen**: solo se compilan en modo Debug.
- La tienda local (`SleepNoise.storekit`) **no se usa**: el producto y el precio salen de App Store Connect. Si el paso 5 o el 6 no están terminados, la hoja Pro dirá que la tienda no responde.
- Las compras en TestFlight no se cobran. Se hacen con la cuenta de Apple del iPhone, no con una de sandbox, y no pasan a la versión de la tienda. Antes de comprar tú con un build de TestFlight, lee `PRUEBAS-EN-DISPOSITIVO.md` §8.B: esa compra te dejaría Pro fijo en los builds de prueba.

Hecho cuando: el build está en la pestaña TestFlight sin avisos y lo instalas en tu iPhone desde la app TestFlight.

Claude después:

- El PR del número de build.
- Etiquetar el commit del que salió cada build, para saber qué se probó.
- Repasar que el archivo lleva dentro `PrivacyInfo.xcprivacy`.

## 12. Beta de 5 noches

Tiempo: 2 horas de gestión, repartidas en una semana. Textos en `BETA.md`.

Antes: el acuerdo activo y el producto creado (pasos 5 y 6), `AppLinks` relleno (paso 8), tus pruebas hechas con la compra en sandbox incluida (paso 10) y el build en TestFlight (paso 11). Es lo que pide `BETA.md` §1.

Cuándo: el plan pone la beta en la semana 4 (07-12 al 11-12) y el envío el viernes 11-12. Dentro de esa semana no cabe: la revisión de la beta, cinco noches, uno o dos días de correcciones y un build nuevo suman más de cinco días. Para enviar el 11-12, los probadores tienen que empezar hacia el viernes 04-12 y el build tiene que estar subido y enviado a la revisión de beta hacia el miércoles 02-12. Es una cuenta de esta guía, no una fecha del plan. Si el 02-12 no hay build, o la beta se acorta o el envío pasa a la segunda fecha (`DECISIONES.md`, D-03).

Qué haces tú, en App Store Connect, pestaña TestFlight:

- [ ] Rellena la **información de la prueba** (Test Information): descripción de la beta, correo para comentarios y datos de contacto. Los textos están en `BETA.md`.
- [ ] Crea un **grupo externo**. Familia y amigos no son usuarios de tu cuenta de App Store Connect, así que no pueden ser probadores internos.
- [ ] Añade el build al grupo. El primer build de una versión pasa una **revisión de beta** antes de llegar a los probadores externos; suele ser más corta que la de la tienda.
- [ ] Invita por correo, o activa el enlace público del grupo y compártelo tú. Los correos de los probadores se escriben solo en Connect.
- [ ] Rellena el campo **"Qué probar"** (What to Test) con el texto de `BETA.md`.
- [ ] Envía a cada persona el mensaje de invitación y, el quinto día, el formulario.
- [ ] Recoge los comentarios en un documento tuyo, fuera del repositorio, sin nombres.

Hecho cuando: entre diez y quince personas han dormido al menos tres noches con la app y tienes sus respuestas.

Claude después:

- Convertir los comentarios, ya sin nombres, en una lista de correcciones ordenada (S-11).
- Subir builds de corrección. Los siguientes builds de la misma versión no suelen repetir la revisión completa de la beta (*comprobar en la pantalla*).

## 13. Envío a revisión

Tiempo: 1 hora. Fecha del plan: viernes 11-12-2026.

Lista antes de pulsar:

- [ ] `DECISIONES.md` no tiene ninguna decisión marcada como **condición de envío** sin cerrar.
- [ ] El build elegido es el último de TestFlight y es el que se probó.
- [ ] La ficha (paso 9) coincide con ese build: texturas nombradas, frases condicionadas, capturas.
- [ ] La política de privacidad abre en su URL y también se lee **dentro de la app** (Ajustes, "Lo que no hay"). La directriz 5.1.1(i) pide las dos cosas: ver `DECISIONES.md`, D-06.
- [ ] `AppLinks` está relleno (paso 8).

Qué haces tú, en la página de la versión:

- [ ] En el apartado **Build**, elige el build.
- [ ] En el apartado de **compras dentro de la app** de la versión, añade el producto Pro. Si no lo añades, la app puede aprobarse sin su compra.
- [ ] En **App Review Information**: tu nombre, teléfono y correo de contacto (solo allí), "Sign-in required" sin marcar, y en **Notes** el bloque en inglés de `docs/store/notas-revision.md`.
- [ ] Antes de pegar las notas, repasa en ese mismo fichero la tabla de estado: cada afirmación debe ser cierta en el build que envías.
- [ ] Elige cómo se publica al aprobarse: **manual** (recomendado, para elegir el día) o automática. (`DECISIONES.md`, D-49.)
- [ ] Añade para revisión y envía (*comprobar en la pantalla*: suele ser en dos pasos).

Tres cosas que el revisor tiene que saber y que ya están en las notas; no las quites:

1. El audio en segundo plano es el producto.
2. La hoja Pro **no se abre entre las 21:00 y las 07:00** del reloj del iPhone, ni en la página nocturna. Un revisor en otro huso horario puede probar de noche.
3. La prueba de 7 noches es local, sin compra, y empieza solo con su botón.

Hecho cuando: el estado de la versión pasa a "esperando revisión".

Claude después: tener a mano las respuestas tipo del paso 14 y no tocar `main` mientras dure la revisión, salvo que haga falta un build nuevo.

## 14. Si Apple rechaza

Los rechazos llegan como un mensaje en App Store Connect, con la directriz citada. Se puede **responder** sin enviar un build nuevo, y a menudo basta. Tómate un día: no contestes en caliente y no reenvíes lo mismo sin cambios.

### 14.1 Por la prueba local (directriz 3.1.1)

Es el riesgo que los documentos tienen anotado (`docs/store/notas-revision.md`, "Riesgo 3.1.1"; `docs/research/INVESTIGACION-MERCADO-SUENO-2026-11-16.md` §9.1). Apple describe la prueba de una app de pago único como un producto no consumible de precio cero, con un nombre del tipo "7-day Trial". La de SleepNoise es un reloj en el iPhone.

Primero, responder (sin build nuevo):

- [ ] Contesta en el mismo hilo, en inglés y en pocas líneas, que la prueba no es una compra ni una transacción, que no se pide medio de pago y nada se renueva, y que **antes de empezar** la hoja Pro dice las tres cosas que la directriz exige: cuánto dura, qué deja de estar disponible al acabar y qué precio único tiene Pro. Adjunta una captura de la hoja con el botón de la prueba a la vista.
- [ ] Ojo: hoy la nota bajo el botón dice la duración y lo que sigue gratis, pero **no nombra lo que se pierde** (`DECISIONES.md`, D-09). Si el rechazo va por ahí, la corrección es un cambio de texto y un build nuevo, no un cambio de modelo.

Si Apple insiste, la alternativa anotada (`docs/PLAN-SIMPLE-1.0.md` §10, propuesta que **espera tu sí** y **no está construida**):

- [ ] Crear en App Store Connect un **segundo producto no consumible, gratuito**, con el nombre que la directriz pide. Que App Store Connect admita hoy un precio cero para un no consumible está **sin comprobar** en los documentos: lo primero es mirarlo en la pantalla de precios.
- [ ] Claude cambia el inicio de la prueba para que pase por esa "compra" de precio cero y reescribe la nota de la hoja, las notas de revisión y la política de privacidad. Es trabajo de StoreKit con sus tests: cuenta varios días y una beta corta.
- [ ] Consecuencias que debes aceptar antes: la prueba pasaría a depender de la tienda (hoy funciona sin red), y con En familia activo habría que decidir si la prueba se comparte.

Si tampoco eso es viable, la salida que no necesita a Apple: **enviar sin prueba**. La app ya tiene un nivel gratuito completo; se quita el botón "Empezar la prueba · 7 noches" y se retiran de la ficha y de la captura 1 las frases sobre las siete noches. Es la más rápida y la que menos te gusta: decide tú.

### 14.2 Por otras causas previstas

| Motivo probable | Qué responder o hacer | Dónde está el material |
|---|---|---|
| "No encuentro la compra" o "no puedo restaurar" | El revisor probó de noche. Repite que la hoja se abre de 07:00 a 21:00 y por dónde se llega. Si el problema es restaurar de noche, ver `DECISIONES.md`, D-08 | `docs/store/notas-revision.md` |
| 4.3, app parecida a otras | El sonido se genera en el iPhone en tiempo real, sin grabaciones; indica la carpeta `SleepNoise/Audio/DSP`, el reparto gratis y Pro y que no es una plantilla | `docs/ROADMAP.md`, apartado 4.3 |
| 2.3, precio o condiciones en subtítulo o capturas | Pasar a los textos de reserva de las fichas | `docs/store/ficha-en.md`, `ficha-es.md` |
| 5.1.1, política de privacidad dentro de la app | Comprobar D-06 | `docs/store/README.md` |
| Afirmaciones de salud | La app no mide ni promete nada; revisar que ninguna captura enseña una frase sobre el cuerpo | `docs/store/privacidad.md` §2 |
| Audio en segundo plano | Es la función de la app; no suena sola ni reproduce silencio | `docs/store/notas-revision.md` |

Claude después: redactar el borrador de la respuesta en inglés con los datos del rechazo (pégale el texto de Apple sin tus datos de contacto), preparar el cambio y el build nuevo si hace falta, y actualizar las notas de revisión.

## 15. Publicación y después

- [ ] Si elegiste publicación manual, publica el día que quieras. La ficha tarda unas horas en verse en todos los países.
- [ ] Descarga la app de la tienda en un iPhone limpio y repite lo mínimo: Play, bloquear, temporizador corto, hoja Pro de día, comprar, restaurar.
- [ ] Comprueba "Escribir una reseña" en el recibo: ahora la página de la tienda ya existe.
- [ ] Mira la URL de privacidad y la de soporte desde la ficha pública.
- [ ] Abre el buzón de contacto y cumple el plazo de borrado que promete la política.

Claude después: etiquetar la versión, actualizar `docs/agents/ESTADO.md` y abrir la lista de 1.0.1 con lo que digan las primeras reseñas y correos.

## Lo que nunca va al repositorio

| Dato | Dónde vive |
|---|---|
| Team ID y cualquier certificado o perfil | Tu Mac y tu cuenta de desarrollador |
| Banco, fiscalidad, condición de comerciante | App Store Connect |
| Tu nombre, teléfono y correo para el revisor | App Store Connect, "App Review Information" |
| Correos y nombres de los probadores | App Store Connect, TestFlight |
| Respuestas de la beta | Un documento tuyo; al repositorio solo llegan resumidas y sin nombres |
| Contraseñas y cuentas de sandbox | Tu gestor de contraseñas |

Lo que sí es público por diseño, porque la app y la política lo necesitan: la dirección de contacto de la app, quién responde de ella y el plazo de borrado de correos.
