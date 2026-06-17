> [!NOTE]
> Diseño de la base de datos xD

> [!IMPORTANT]
> ## Vacios a no diseñar
> - No diseñar la demostracion para saber si un usuarios ejecutó x acción conforme a su reto, se debe limitar a diseñar el recording de eso, es decir, que ya hubo un modelo, IA, análisis que documento eso en bitácora (Se cumplió, no se cumplió, en duda).
> - No extender cualquier cosa relacionada a baneos, por ejemplo temas morales, sexuales o de integridad física. Si se debe hacer una capa filtring pero nada mas para documentar, para decir este y este request fue rechazado nada más, nada de análisis del porque se rechazo ni nada.
>

> [!TIP]
> Solo una tabla de bitacora para analizar procesos es suficiente con: el procesoId, procesTYpe, tipoDeContenido, URL al content, tipo de URL, source type tambien puede ser, un response , un request y un result(aprobado, negado, irreconocible, etc). Para tener el tracking de lo que sucede. Entonces suponer que solo obtenemos los resultados de lo que sucede

> [!TIP]
> User, permisos, logins, logs, currency, transaction, balance. Los usamos de etheria o de Dynamic, copiar y pegar, unicamente un rename y modificar el contexto

> [!TIP]
> No tener tablas para insta, tiktok, etc, Son tablas de social network, con resouerce, resource types y se logea esos resources, entonces se logea el content, el URL y esto se va registrando para que sea algo generico.

> [!TIP]
> ## Reglas de puntos
> - Es bueno tener una tabla de configuraciones para que los puntos y Distibucion no quede hardcodeado

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
|        			USERS AND GEOGRAPHY			             |                                     
==============================================================

## Countries
- countryId : INT IDENTITY(1,1) (PK)
- isoCode : UNIQUE VARCHAR (3) 
- countryName : VARCHAR (50)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## States
- stateId : INT IDENTITY(1,1) (PK)
- countryId : INT (FK)
- stateName : VARCHAR (40)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Cities
- cityId : INT IDENTITY(1,1) (PK)
- stateId : INT (FK)
- cityName : VARCHAR (50)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Addresses
- addressId : INT IDENTITY(1,1) (PK)
- cityId : INT (FK)
- address : VARCHAR (100)
- zipCode : VARCHAR (20)
- position : GEOGRAPHY
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Permissions
- permissionId : INT IDENTITY(1,1) (PK)
- permissionName : VARCHAR (50)
- description : VARCHAR (200)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Roles
- roleId : INT IDENTITY(1,1) (PK)
- roleName : VARCHAR (50)
- description : VARCHAR (150)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PermissionsPerRoles
- permissionPerRoleId : INT IDENTITY(1,1) (PK)
- roleId : INT(FK)
- permissionId : INT(FK)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## UsersPerRoles
- userPerRoleId : INT IDENTITY(1,1) (PK)
- userId : INT(FK)
- roleId : INT(FK)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Users
- userId : INT IDENTITY(1,1) (PK)			 	
- name : VARCHAR(50)					
- lastName : VARCHAR(50)
- passwordHash: VARCHAR (255)							
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## UsersAddresses
- userAddressId : INT IDENTITY(1,1) (PK)
- userId : INT (FK)					
- addressId : INT (FK)					
- checksum : VARBINARY(MAX)					
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

==============================================================
|        					Contact Info                      |                                     
==============================================================

## ContactTypes
- contactTypeId: INT IDENTITY (1,1) (PK)
- contactTypeName: VARCHAR (50)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## Contacts
- contactId: INT IDENTITY (1,1) (PK)
- contactTypeId: INT (FK)
- userId : INT (FK)
- contactValue: VARCHAR (100)  
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

==============================================================
|        			AUDIT INFO AND CONFIG                    |                                     
==============================================================

## SystemConfigurations
- configId : INT IDENTITY(1,1) (PK)
- configKey : UNIQUE VARCHAR (100) 
- configValue : VARCHAR (255)
- description : VARCHAR (150)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## AIProviders
- providerId : INT IDENTITY(1,1) (PK)
- providerName : VARCHAR(50) -- Ej: 'OpenAI', 'Google', 'Anthropic'
- isActive : BIT
- createdAt : DATETIME2

## AIModels
- modelId : INT IDENTITY(1,1) (PK)
- providerId : INT (FK)
- modelName : VARCHAR(100) -- Ej: 'gpt-4o', 'gemini-1.5-pro'
- modelVersion : VARCHAR(20)
- isActive : BIT
- createdAt : DATETIME2

## Sessions
- sessionId : INT IDENTITY(1,1) (PK)
- userId : INT(FK)
- sessionToken : VARCHAR(100)
- isActive : BIT	
- createdAt : DATETIME2

## EventTypes
- eventTypeId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(150)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## DataObjects
- dataObjectId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## ReferenceObjectsTypes
- referenceObjectTypeId : INT IDENTITY(1,1) (PK)
- objectTypeName : VARCHAR(100) 
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## SourceObjectsTypes
- sourceObjectTypeId : INT IDENTITY(1,1) (PK)
- objectTypeName : VARCHAR(100) 
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Severities
- severityId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## UsersLogs
- logId : INT IDENTITY(1,1) (PK)
- eventTypeId : INT(FK)
- dataObjectId : INT(FK)
- sessionId : INT(FK)
- description : VARCHAR(255)
- metadata : VARBINARY(MAX) 			
- createdAt : DATETIME2

## SystemErrorLogs
- errorId : INT IDENTITY(1,1) (PK)
- severityId : INT (FK)
- processUuid : VARCHAR(100)
- processName : VARCHAR(100)
- stepName : VARCHAR(100)
- inputData : VARBINARY(MAX)
- errorMessage : VARBINARY(MAX)
- createdAt : DATETIME2

## AIProcessTypes
- processTypeId : INT IDENTITY(1,1) (PK)
- processTypeName : VARCHAR(50)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## AIContentTypes
- contentTypeId : INT IDENTITY(1,1) (PK)
- contentTypeName : VARCHAR(50)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## SourceTypes
- sourceTypeId : INT IDENTITY(1,1) (PK)
- sourceTypeName : VARCHAR (40)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## AIResultTypes
- resultTypeId : INT IDENTITY(1,1) (PK)
- resultTypeName : VARCHAR (40)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

# URLTypes
- urlTypeId : INT IDENTITY(1,1) (PK)
- urlTypeName : VARCHAR (50)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK) 

## AIProcessesLogs
- processLogId : BIGINT IDENTITY(1,1) (PK)
- processTypeId : INT (FK)
- contentTypeId : INT (FK)
- urlTypeId : INT (FK)
- resultTypeId : INT (FK)
- sourceTypeId : INT (FK)
- contentUrl : VARCHAR(255)
- requestJson : NVARCHAR(MAX)
- responseJson : NVARCHAR(MAX)
- createdAt : DATETIME2

==============================================================
|        			GAME ENGINE (GATHEL)  			         |                                     
==============================================================
## PropositionStates
- propositionStateId : INT IDENTITY(1,1) (PK)
- propositionStateName : VARCHAR (40)
- allowsPredictions : BIT
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PropositionsResultsTypes
- resultTypeId : INT IDENTITY(1,1) (PK)
- resultTypeName : VARCHAR (40)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Propositions
- propositionId : BIGINT IDENTITY (1,1) (PK)
- eventId : INT (FK) 
- propositionTopic : VARCHAR(100)
- createdByUserId : INT (FK)
- targetUserId : INT (FK)
- propositionStateId : INT (FK)
- description : VARCHAR (255)
- evidenceUrl : VARCHAR(MAX) 
- resultTypeId : INT (FK)
- validFrom : DATETIME2
- validUntil : DATETIME2
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PropositionOptions
-- Soportar que el outcome evolucione más allá de un BIT (Verdadero/Falso/Múltiples opciones)
- optionId : BIGINT IDENTITY(1,1) (PK)
- propositionId : BIGINT (FK)
- optionText : VARCHAR(100) -- Ej: 'Elizabeth asiste', 'Elizabeth no asiste', 'Evento Cancelado'
- isWinningOption : BIT (NULL) -- Se marca en TRUE cuando se resuelve la proposición
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PropositionStateHistories
- historyId : BIGINT IDENTITY (1,1) (PK)
- propositionId : BIGINT (FK)
- oldStateId : INT (FK)
- newStateId : INT (FK)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PredictionStates
- predictionStateId : INT IDENTITY(1,1) (PK)
- predictionStateName : VARCHAR(32)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Predictions
- predictionId : BIGINT IDENTITY (1,1) (PK)
- propositionId : BIGINT (FK)
- userId : INT (FK)
- predictionStateId : INT (FK)
- description : VARCHAR (255)
- predictedOptionId : BIGINT (FK) -- Apunta a la opción elegida (no un BIT)
- amount : DECIMAL (18, 6) -- Genérico: Soporta N formas de fondos
- currencyId : INT (FK)    -- Define si apostó puntos (1) o dinero real (2), etc.
- validFrom : DATETIME2
- validUntil : DATETIME2
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## SocialPlatforms
- platformId : INT IDENTITY(1,1) (PK)
- platformName : VARCHAR (50)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## SocialResourceTypes
- resourceTypeId : INT IDENTITY (1,1) (PK)
- resourceTypeName : VARCHAR (40)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK) 

## SocialResources
- resourceId : BIGINT IDENTITY(1,1) (PK)
- propositionId : BIGINT (FK)
- platformId : INT (FK)
- resourceTypeId : INT (FK)
- url : VARCHAR (255)
- resourcePurpose : VARCHAR (50) -- Ej: 'EvidenciaProposicion', 'ResultadoOutcome', 'Moderacion'
- metadataJson : NVARCHAR (MAX)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK) 

==============================================================
|        			ECONOMY AND LEDGER       			     |                                     
==============================================================

## Currencies
- currencyId: INT IDENTITY(1,1) (PK)
- currencySymbol: VARCHAR (5)
- currencyName: VARCHAR (40)
- isVirtual : BIT
- isActive: BIT
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
- exchangeRateId: INT (FK)
- currencyId1: INT (FK)
- currencyId2: INT (FK)
- exchangeRate: DECIMAL (18, 6)
- postTime: DATETIME2
- checkSum: VARBINARY(MAX)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## Wallets
- walletId : INT IDENTITY(1,1) (PK)
- userId : INT (FK)
- currencyId : INT (FK)
- pin : INT
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PaymentMethods
- paymentMethodId : INT IDENTITY(1,1) (PK)
- paymentMethodName : VARCHAR (50)
- apiURL : VARCHAR (255)
- configJson : NVARCHAR (MAX)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PaymentMethodsPerCountry
- paymentMethodCountryId : INT IDENTITY(1,1) (PK)
- countryId : INT (FK) 
- paymentMethodId : INT (FK)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## MovementTypes
- movementTypeId : INT IDENTITY(1,1) (PK)
- movementTypeName : VARCHAR(80)
- movementTypeDescription : VARCHAR(255)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## PaymentResultTypes
- resultTypeId : INT IDENTITY(1,1) (PK)
- resultTypeName : VARCHAR (40)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PaymentAttempts
- attemptId : BIGINT IDENTITY(1,1) (PK)
- attemptDate : DATETIME2
- walletId : INT (FK)
- amount : DECIMAL (18, 6)
- currencyId : INT (FK)
- movementTypeId : INT (FK)
- resultTypeId : INT (FK)
- referenceObjectTypeId : INT (FK)
- referenceObjectId: VARCHAR (50)
- sourceObjectTypeId : INT (FK)
- sourceObjectId : VARCHAR (50)
- requestJson : NVARCHAR (MAX)
- responseJson : NVARCHAR (MAX)
- transactionResponse : VARCHAR (MAX)

## TransactionsLedger
- transactionId : BIGINT IDENTITY(1,1) (PK)
- transactionNumber : VARCHAR(100) UNIQUE
- transactionDate : DATETIME2
- walletId : INT (FK)
- attemptId : BIGINT (FK)
- movementTypeId : INT (FK)
- currencyId : INT (FK)
- amount : DECIMAL (18, 6)
- createdAt : DATETIME2

## Balances
-- Estructura Clave de N Fondos: Se maneja por combinaciones de Wallet y Currency
- walletId : INT (FK)
- currencyId : INT (FK) -- (Llave Primaria Compuesta junto con walletId)
- currentBalance : DECIMAL (18, 6) -- Aquí cae el saldo final sea de Puntos o Plata
- updatedAt: DATETIME2
- CONSTRAINT PK_Balances PRIMARY KEY (walletId, currencyId)