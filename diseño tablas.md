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


==============================================================
|          				   Currency	                     	 | 
==============================================================
## Currencies
- currencyId: serial auto-increment (PK)
- currencySymbol: VARCHAR (5)
- currencyName: VARCHAR (40)
- isActive: BOOLEAN
- postTime: TIMESTAMP
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- updatedBy: integer (FK)

## ExchangeRates
- exchangeRateId: serial auto-increment (PK)
- currencyId1: integer (FK)
- currencyId2: integer (FK)
- exchangeRate: DECIMAL (18, 6)
- postTime: TIMESTAMP
- checkSum: BYTEA
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- updatedBy: integer (FK) 

## ExchangeHistories
- exchangeHistoryId: serial auto-increment (PK)
- startDateTime: TIMESTAMP
- endDateTime: TIMESTAMP
- currencyId1: integer (FK)
- currencyId2: integer (FK)
- exchangeRate: DECIMAL (18, 6)
- postTime: TIMESTAMP
- checkSum: BYTEA
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- updatedBy: integer (FK)
- exchangeRateId: integer (FK)

==============================================================
|          				   Addresses	                     |
==============================================================

## Countries
- countryId: serial auto-increment (PK)
- isoCode: UNIQUE VARCHAR (3) 
- countryName: VARCHAR (50)
- isActive: BOOLEAN
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- updatedBy: integer (FK)

## States
- stateId: serial auto-increment (PK)
- countryId: integer (FK)
- stateName: VARCHAR (40)
- isActive: BOOLEAN
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- updatedBy: integer (FK)

## Cities
- cityId: serial auto-increment (PK)
- stateId: integer (FK)
- cityName: VARCHAR (50)
- isActive: BOOLEAN
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- updatedBy: integer (FK)

## Addresses
- addressId: serial auto-increment (PK)
- cityId: integer (FK)
- address: VARCHAR (100)
- zipCode: VARCHAR (20)
- position: GEOGRAPHY
- isActive: BOOLEAN
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- updatedBy: integer (FK)


==============================================================
|          				        users 	                     |
==============================================================
## FUNCION: Aqui nada mas son los usuarios del sistema, no hay mucha explicacion es bastante obvio todo

## users
- userId : INT AUTO_INCREMENT (PK)			 	
- name : VARCHAR(50)					
- lastName : VARCHAR(50)				
- email : VARCHAR(100)		
- password : VARBINARY			
- phone : INT 							
- creadetAt : TIMESTAMP					
- enabled : BOOLEAN						

## usersAddresses
- userAddressId : INT AUTO_INCREMENT (PK)
- userId : INT (FK)					
- addressID : INT (FK)					
- enabled : BOOLEAN						
- checksum : VARBINARY					

## permision
- permisionId : INT AUTO_INCREMENT (PK)
- description : VARCHAR (200)
- 



==============================================================
|        					logs              	 	         |                                     
==============================================================
## sessions
- sessionId : INT AUTO_INCREMENT (PK)
- userId : INT(FK)
- sessionToken : VARCHAR(100)
- creadetAt : TIMESTAMP

## eventsTypes
- eventTypeId : INT AUTO_INCREMENT (PK)
- name : VARCHAR(50)
- description : VARCHAR(150)

## dataObjects
- dataObjectId : INT AUTO_INCREMENT(PK)
- name : VARCHAR(50)
- description : VARCHAR(100)

## severities
- severityId : INT AUTO_INCREMENT (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)

## usersLogs
- logId : INT AUTO_INCREMENT(PK)
- eventType : INT(FK)
- dataObjectId : INT(FK)
- websiteId : INT(FK)
- sessionId : INT(FK)
- description : VARCHAR(255)
- creadetAt : TIMESTAMP
- metadata : JSON 			

## systemErrorsLogs
- errorId : INT AUTO_INCREMENT (PK)
- severityId : INT (FK)
- processUuid : VARCHAR(100)
- processName : VARCHAR(100)
- stepName : VARCHAR(100)
- inputData : JSON
- errorMesage : TEXT
- creadetAt : DATE 

## statusTransactionType
- statusTypeId : INT AUTO_INCREMENT (PK)
- statusName : VARCHAR(50) 
- statusDescription : VARCHAR(150)

## spTransactionState
- stateId : INT AUTO_INCREMENT (PK)
- orderId : INT (FK, NULL) 
- statusTypeId : INT (FK)
- stepName : VARCHAR(100) 
- executionTime : TIMESTAMP
- observations : TEXT 


==============================================================
|        					Transactions              	 	 |                                     
==============================================================
## paymentsMethods
- paymentMethodId : INT AUTO_INCREMENT (PK)
- paymentMethodName : VARCHAR(50)
- URL : VARCHAR(255)

## paymentsAttempts 


## Transaction

Payment method (Metodo, auditoria, url a la API, config.JSON, metodoDePagoPerCountry(opcional), Enabled, etc).
> PaymentsAttemps(ID, dia, usuario, amount, currencyId, operationTypeId, referenceObjectId, sourceObjectId, result, requeste, response, transactionResponse(VARCHAR))
> Transactions, este unicamente ingresa cuando es exito el paymentsAttemps, por lo que transaction es un hecho y este modelo es el de la clase.