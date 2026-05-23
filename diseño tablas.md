> [!NOTE]
> Diseño de la base de datos xD

> [!IMPORTANT]
> ## Vacios a no diseñar
> - No diseñar la demostracion para saber si un usuarios ejecutó x acción conforme a su reto, se debe limitar a diseñar el recording de eso, es decir, que ya hubo un modelo, IA, análisis que documento eso en bitácora (Se cumplió, no se cumplió, en duda).
> - No extender cualquier cosa relacionada a baneos, por ejemplo temas morales, sexuales o de integridad física. Si se debe hacer una capa filtring pero nada mas para documentar, para decir este y este request fue rechazado nada más, nada de análisis del porque se rechazo ni nada.
>

> [!TIP]
> Solo una tabla de bitacora para analizar procesos es suficiente con: el procesoId, procesTpe, tipoDeContenido, URL al content, tipo de URL, source type tambien puede ser, un response , un request y un result(aprobado, negado, irreconocible, etc). Para tener el tracking de lo que sucede. Entonces suponer que solo obtenemos los resultados de lo que sucede

> [!TIP]
> User, permisos, logins, logs, currency, transaction, balance. Los usamos de etheria o de Dynamic, copiar y pegar, unicamente un rename y modificar el contexto

> [!TIP]
> No tener tablas para insta, tiktok, etc, Son tablas de social network, con resouerce, resource types y se logea esos resources, entonces se logea el content el URL y esto se va registrando para que sea algo generico.

> [!TIP]
> ## Reglas de puntos
> - Es bueno tener una tabla de configuraciones para que los puntos y tristibucion no quede hardcodeado

> [!TIP]
> Todo lo relacionado con dinero se trae de etheria, metodos (paypal), pagos(intentos).
> ## Sistemas de pagos
> Payment method (Metodo, auditoria, url a la API, config.JSON, metodoDePagoPerCountry(opcional), Enabled, etc).
> PaymentsAttemps(ID, dia, usuario, amount, currencyId, operationTypeId, referenceObjectId, sourceObjectId, result, requeste, response, transactionResponse(VARCHAR))
> Transactions, este unicamente ingresa cuando es exito el paymentsAttemps, por lo que transaction es un hecho y este modelo es el de la clase.

> [!TIP]
> ## Validacion
> Es simplemente tema de registrarse, ya se valido el proceso de recompensas, el ejecutarse la imposibilidad, para poder ejecutar la economia, es algo simple son pocas tablas.

> [!IMPORTANT]
> Todo lo que es attempts de logins van a la tabla de logs

> [!IMPORTANT]
> EL DIAGRAMA EN DISEÑO FISICO, NO EN DISEÑO LOGICO
> EL DISEÑO DEBE MOSTRAR LAS COLUMNAS QUE EL PROFESOR HABIA PEDIDO MOSTRAR ANTERIORMENTE

> [!TIP]
> ## Security
> La parte de security se hace desde el mismo managment studio, se hace en la zona de security, donde se crean logins, roles y permisos, toca logearse y deslogearse, por lo que es demostrativo, en la revisión toca ver que cosas puede hacer tal usuario y cual puede hacer el otro.

> [!NOTE]
> Todo lo de MVP el profe espera que sea con IA
> ## Backend
> - Todas las operaciones de lectura deberán realisarse utilizando un ORM: Va a preguntar como definimos el modelo de las tablas y como se construyen las consultas usando ORM, cual ORM usamos.
> - Todas las operaciones de escritura deberán ejecutarse llamando directamente a SP: Se usara un driver nativo, por lo que en el driver nativo se preguntara, como se configura, como le doy la conexion, como le do el numero del puerto, como le doy el number and password, como funciona esa conexion con la base de datos.
> - Habilitar y configurar un esquema de fixed-size connection pooling para las conexiones hacia la base de datos.

> [!IMPORTANT]
> Guardar como trabajamos con los agentes para la defensa. 