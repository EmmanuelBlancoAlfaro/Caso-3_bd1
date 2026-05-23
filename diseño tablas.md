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
- currencyId: INT IDENTITY(1,1) (PK)
- currencySymbol: VARCHAR (5)
- currencyName: VARCHAR (40)
- isActive: BIT
- postTime: DATETIME2
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## ExchangeRates
- exchangeRateId: INT IDENTITY(1,1) (PK)
- currencyId1: INT (FK)
- currencyId2: INT (FK)
- exchangeRate: DECIMAL (18, 6)
- postTime: DATETIME2
- checkSum: VARBINARY(MAX)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK) 

## ExchangeHistories
- exchangeHistoryId: INT IDENTITY(1,1) (PK)
- startDateTime: DATETIME2
- endDateTime: DATETIME2
- currencyId1: INT (FK)
- currencyId2: INT (FK)
- exchangeRate: DECIMAL (18, 6)
- postTime: DATETIME2
- checkSum: VARBINARY(MAX)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)
- exchangeRateId: INT (FK)

==============================================================
|          				   Addresses	                     |
==============================================================

## Countries
- countryId: INT IDENTITY(1,1) (PK)
- isoCode: UNIQUE VARCHAR (3) 
- countryName: VARCHAR (50)
- isActive: BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## States
- stateId: INT IDENTITY(1,1) (PK)
- countryId: INT (FK)
- stateName: VARCHAR (40)
- isActive: BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## Cities
- cityId: INT IDENTITY(1,1) (PK)
- stateId: INT (FK)
- cityName: VARCHAR (50)
- isActive: BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## Addresses
- addressId: INT IDENTITY(1,1) (PK)
- cityId: INT (FK)
- address: VARCHAR (100)
- zipCode: VARCHAR (20)
- position: GEOGRAPHY
- isActive: BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)


==============================================================
|          				        users 	                     |
==============================================================
## FUNCION: Aqui nada mas son los usuarios del sistema, no hay mucha explicacion es bastante obvio todo

## users
- userId : INT IDENTITY(1,1) (PK)			 	
- name : VARCHAR(50)					
- lastName : VARCHAR(50)				
- email : VARCHAR(100)		
- password : VARBINARY(MAX)		
- phone : INT 							
- creadetAt : DATETIME2					
- enabled : BIT						

## usersAddresses
- userAddressId : INT IDENTITY(1,1) (PK)
- userId : INT (FK)					
- addressID : INT (FK)					
- enabled : BIT						
- checksum : VARBINARY(MAX)					

## permision
- permisionId : INT AUTO_INCREMENT (PK)
- description : VARCHAR (200)
- 



==============================================================
|        					logs              	 	         |                                     
==============================================================
## sessions
- sessionId : INT IDENTITY(1,1) (PK)
- userId : INT(FK)
- sessionToken : VARCHAR(100)
- creadetAt : DATETIME2

## eventsTypes
- eventTypeId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(150)

## dataObjects
- dataObjectId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)

## referenceObject
- referenceObjectId


## severities
- severityId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)

## usersLogs
- logId : INT IDENTITY(1,1) (PK)
- eventType : INT(FK)
- dataObjectId : INT(FK)
- sessionId : INT(FK)
- description : VARCHAR(255)
- creadetAt : DATETIME2
- metadata : VARBINARY(MAX) 			

## systemErrorsLogs
- errorId : INT IDENTITY(1,1) (PK)
- severityId : INT (FK)
- processUuid : VARCHAR(100)
- processName : VARCHAR(100)
- stepName : VARCHAR(100)
- inputData : VARBINARY(MAX)
- errorMesage : VARBINARY(MAX)
- creadetAt : DATE 

==============================================================
|        					Transactions              	 	 |                                     
==============================================================
## movements
- movementId : INT IDENTITY(1,1) (PK)
- movementName : VARCHAR(80)
- movementDescription : VARCHAR(255)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## movementsTypes
- movementTypeId : INT IDENTITY(1,1) (PK)
- movementTypeName : VARCHAR(80)
- movementTypeDescription : VARCHAR(255)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)


## paymentsMethods
- paymentMethodId : INT IDENTITY(1,1) (PK)
- paymentMethodName : VARCHAR(50)
- URL : VARCHAR(255)
- config : VARBINARY(MAX)
- enabled : BIT

## paymentsMethodsPerCountry
- paymentMethodCountryId : INT IDENTITY(1,1) (PK)
- countryId : INT (FK) 
- paymentMethodId : INT (FK)


## paymentsAttempts 
- paymentAttemptId : INT IDENTITY(1,1) (PK)
- paymentAttemptDate : DATETIME2
- userId : INT (FK)
- amount : DECIMAL (18, 6)
- currencyId : INT (FK)
- movementTypeId : INT (FK)
- result : VARCHAR(255)
- request : VARCHAR(255)
- transactionResponse : VARCHAR(MAX) 

> [!NOTE]
> TOCA AGREGAR LAS TABLAS DE ESTOS DOS
>- referenceObjectId : INT (FK)
>- sourceObjectId : INT (FK)

## Transaction
- transactionID : INT IDENTITY(1,1) (PK)
- transactionNumber : INT
- 

## statusTransactionType
- statusTypeId : INT IDENTITY(1,1) (PK)
- statusName : VARCHAR(50) 
- statusDescription : VARCHAR(150)

## transactionState
- stateId : INT IDENTITY(1,1) (PK)
- orderId : INT (FK, NULL) 
- statusTypeId : INT (FK)
- stepName : VARCHAR(100) 
- executionTime : DATETIME2
- observations : VARBINARY(MAX) 

> PaymentsAttemps(ID, dia, usuario, amount, currencyId, operationTypeId, referenceObjectId, sourceObjectId, result, request, response, transactionResponse(VARCHAR))
> Transactions, este unicamente ingresa cuando es exito el paymentsAttemps, por lo que transaction es un hecho y este modelo es el de la clase.