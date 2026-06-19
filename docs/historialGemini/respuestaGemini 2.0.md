Prompt enviado a la IA: Hola chat, necesito que realices una revision sobre esta base de datos enfocado en los siguientes temas:
reglas de negocio,
seguridad,
economía del juego,
transferencias y pagos,
procesamiento de AI,
integración con redes sociales,
normalización,
diseño optimizado para altos volúmenes de inserts y pocos updates,
autenticación y autorización,
eventos del juego,
monitoreo,
observabilidad,
auditoría,
trazabilidad,
rendimiento,
particionamiento,
índices,
y escalabilidad.

Continuamente te paso los markdown importantes y de donde se saco la informacion y porque elegimos hacer "x" o "y" tabla:

En el archivo "caso #3.md" se encuentra toda la información relacionada a este caso y el cual nos dice que quiere en la base de datos, por lo que de aqui debes leer todo para comprender que es lo que desea el profesor a hacer.
El archivo "Patrones de diseño para usar explicados.md" y "Investigación Caso#3.md" son archivos de apoyo para realizar la base de datos, por lo que son mas de apoyo, por lo que debes leerlos para poder a ayudarnos a hacer las correcciones.
Ahora si aqui vienen los dos diseños de tablas actuales que tenemos conforme a las indicaciones del archivo "caso #3.md", el archivo "diseño tablas.md" es donde se encuentra nuestro diseño actual y en el archivo "comparación.md" se encuentra un "arreglo" que nos dio otra IA, pero al hacerlo solo parcialmente bien, vengo a pedir tu consejo al ser la mejor IA, ahora si aqui vienen algunas cosas que hay en el archivo de comparación.md que no deberia o almenos no hay logica para ponerlas:

1. Primero y mas importante quito el orden de las tablas sin razon alguna
2. Quito el userAdresses cuando es importante saber de donde es el usuario para la trazabilidad
3. En contact la columna value en Contacts no tiene mucha logica lo que esta haciendo hay a menos que haga referencia al valor del contacto, pero el nombre esta mal dirigido
4. En AUDIT INFO AND CONFIG las tablas que agrego son correctas o algunas le cambio el nombre, pero elimino tablas como sessions, eventTypes, dataObjects, referencesObject, sourceObject, severities, usersLogs, systemErrorLogs, los cuales el profe pedia y elimino sin razon, alguna, entonces debes mejorarlo no eliminar estas tablas
5. Luego el contentTypes, sourceTypes, AIResultTypes, ProcessLog_AI, no es malo tenerlo pero la otra IA lo tomo como si se tuviera que hacer todo este proceso, pero el profesor dijo que debemos hacerlo lo mas simple posible, porque debemos suponer que la IA ya hizo todo este proceso, entonces eso mantenlo asi.
6. Ahora con la parte del juego en si, elimino propositionRates la cual es para saber en x proposition cuanta cantidad esta a favor y cual en contra es unicamente para datos esto
7. La parte de social platforms y todo relacionado a eso esta bien, elimino la parte de predictionState pero eso si esta bien
8. Ahora en la parte de currency, la IA agregago una parte de PaymentOperationTypes, pero eso seria casi lo mismo que paymentMethods, ya que lo importantes es saber cual metodo de pago uso el usuario, luego el paymentResultTypes no es correcto, ya que debe eso debe ser lo mismo que paymentAttempts y cuando el intento se completa se hace la transaction por lo que a transaction unicamente entra cuando se completo el paymentAttempt y por ultimo, tambien quito el balance, pero el balance pattern lo pidio el profesor y la IA lo quito tambien, ademas de agregar cosas como LedgerTransactionTypes y TransactionsLedger no es malo pero debe ser unicamente un transaction.

Ok despues de todos estos errores que cometio la IA anterior, o talvez no error, sino nada mas confuciones, necesito que tu arregles esto, entonces necesito que crees un .md con el diseño de las tablas arreglado, debes ser muy cuidadoso con cada cosa.

Otra cosa a tomar en cuenta es en el archivo "diseño tablas.md" son las lineas de la 2 a la 53, ya que ahi viene escrito detalles importantes que el profesor hablo en clase, pero tu solo toma lo que tenga que ver con el diseño lo que tenga que ver con BACKEND no lo tomes en cuenta, dura mucho para que leas todo muchas veces y puedas hacer el mejor resultado

Intenta ser lo mas detallado posible con cada tabla, ademas intenta no eliminar la base, unicamente agrega tablas si son necesarias.




Porque este prompt: Como el profesor habia indicado la idea era colocar información exacta sobre lo que se queria pedir, entonces cosas como normalización, seguridad, economía, etc, se le colocó. Además de eso se le pasaron archivos como "caso #3.md", "Patrones de diseño para usar explicados.md", "Investigación Caso#3.md", "diseño tablas.md" y "comparación.md".




La respuesta que me dio gemini fue esta con los cambios o errores que encontro:
Reglas de negocio & Eventos del juego: Se restauraron PropositionRates y PredictionStates. Todo el ciclo de vida (desde que se propone hasta que la IA valida y se paga) está cubierto por máquinas de estado (PropositionStates, PredictionStates) y su historial (PropositionStateHistories).

Economía del juego, Transferencias y Pagos: Implementación estricta del Patrón Ledger y Patrón Balances. PaymentAttempts registra todo intento (exitoso o fallido). Si es exitoso, pasa a Transactions (inmutable, Append-Only). El saldo actual se refleja en Balances para lecturas ultrarrápidas, cumpliendo lo que pidió el profe.

Seguridad, Autenticación y Autorización: Se aplica el patrón RBAC (Roles, Permisos, Usuarios x Roles). Todo el tema de cifrado y Row-Level Security (RLS) recaerá sobre estas tablas a nivel de motor de base de datos.

Procesamiento de AI: Se simplificó a una sola tabla de bitácora (AIBitacoraProcesos) tal como lo indicó el profesor ("Solo una tabla de bitácora para analizar procesos es suficiente..."). Esto evita la sobre-normalización innecesaria.

Integración con Redes Sociales: Tablas genéricas (SocialPlatforms, SocialResources) preparadas para escalar sin importar si mañana se agrega Twitch o X.

Monitoreo, Observabilidad, Auditoría y Trazabilidad: Se restauraron todas las tablas críticas (Sessions, SystemErrorLogs, UsersLogs). Además, el 90% de las tablas incluyen campos de auditoría (createdAt, updatedAt, updatedBy). Se mantuvo UserAddresses para trazabilidad geográfica.

Normalización, Rendimiento, Particionamiento e Índices: El diseño está en 3NF. Separamos los catálogos (Master-Detail) de las transacciones de alto volumen. Tablas como Transactions o UsersLogs son candidatas perfectas para particionamiento horizontal por fecha (createdAt).



Este fue el diseño que nos dio gemini como sugerencia:
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
- email : VARCHAR(100)		
- passwordHash: VARCHAR (255)
- phone : VARCHAR(20)							
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

## Sessions
- sessionId : INT IDENTITY(1,1) (PK)
- userId : INT(FK)
- sessionToken : VARCHAR(100)
- createdAt : DATETIME2

## EventTypes
- eventTypeId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(150)
- isActive : BIT
- createdAt: DATETIME2

## DataObjects
- dataObjectId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)
- isActive : BIT
- createdAt: DATETIME2

## ReferenceObjects
- referenceObjectId : INT IDENTITY(1,1) (PK)
- objectName : VARCHAR(100) 
- isActive : BIT

## SourceObjects
- sourceObjectId : INT IDENTITY(1,1) (PK)
- objectName : VARCHAR(100) 
- isActive : BIT

## Severities
- severityId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)
- isActive : BIT

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
- processTypeName : VARCHAR(50) -- Ej: 'FiltroContenido', 'VerificacionEvidencia', 'Moderacion'
- isActive : BIT
- createdAt : DATETIME2

## AIContentTypes
- contentTypeId : INT IDENTITY(1,1) (PK)
- contentTypeName : VARCHAR(50) -- Ej: 'Texto', 'Imagen', 'Video', 'Audio', 'Mixto'
- isActive : BIT
- createdAt : DATETIME2

## AIBitacoraProcesos
- processLogId : BIGINT IDENTITY(1,1) (PK)
- processTypeId : INT (FK)
- contentTypeId : INT (FK)
- contentUrl : VARCHAR(255)
- urlType : VARCHAR(50)
- sourceType : VARCHAR(50)
- requestJson : NVARCHAR(MAX)
- responseJson : NVARCHAR(MAX)
- resultState : VARCHAR(50) -- (Aprobado, Negado, Irreconocible)
- createdAt : DATETIME2

==============================================================
|        			GAME ENGINE (GATHEL)  			         |                                     
==============================================================

## Events
- eventId : INT IDENTITY(1,1) (PK)
- eventName : VARCHAR(100)
- description : VARCHAR(255)
- validFrom : DATETIME2
- validUntil : DATETIME2
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PropositionStates
- propositionStateId : INT IDENTITY(1,1) (PK)
- propositionStateName : VARCHAR (40)
- allowsPredictions : BIT
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Propositions
- propositionId : BIGINT IDENTITY (1,1) (PK)
- eventId : INT (FK, NULL) -- Permite asociar la proposición a un evento macro si aplica
- propositionTopic : VARCHAR(100)
- createdByUserId : INT (FK)
- targetUserId : INT (FK)
- propositionStateId : INT (FK)
- description : VARCHAR (255)
- votes : INT
- totalAmountOfPoints: INT
- totalAmountOfMoney: DECIMAL (18, 6)
- evidenceUrl : VARCHAR(MAX) 
- result : VARCHAR(255)
- deadlineDate : DATETIME2
- eventDate : DATETIME2
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PropositionRates
- propositionRateId: BIGINT IDENTITY(1,1) (PK)
- propositionId: BIGINT (FK)
- percentageInFavorOf: DECIMAL (6, 3)
- percentageAgainst : DECIMAL (6, 3)

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
- description : VARCHAR (50)
- predictedOutcome : BIT
- amountOfPoints: INT
- amountOfMoney: DECIMAL (18, 6)
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
- metadataJson : VARCHAR (MAX)
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
- affectsSign: INT -- (+1 depósitos/ganancias, -1 retiros/apuestas)
- movementTypeDescription : VARCHAR(255)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## PaymentAttempts
- attemptId : BIGINT IDENTITY(1,1) (PK)
- attemptDate : DATETIME2
- walletId : INT (FK)
- amount : DECIMAL (18, 6)
- currencyId : INT (FK)
- movementTypeId : INT (FK)
- referenceObjectId : VARCHAR (50)
- sourceObjectId : VARCHAR (50)
- result : VARCHAR(255) -- (Éxito, Fallo, Pendiente)
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
- walletId : INT (PK y FK)
- currentPointsBalance : INT
- currentMoneyBalance : DECIMAL (18, 6)
- updatedAt: DATETIME2







Este fue el diseño que teniamos antes de la consulta: 

==============================================================
|          				   Gathel	                        | 
==============================================================
## events
- eventId : INT IDENTITY(1,1) (PK)
- createdBy : INT (FK)
- validFrom : DATETIME2
- validUntil : DATETIME2

## propositionsState
- propositionStateId : INT IDENTITY(1,1) (PK)
- propositionStateName : VARCHAR(32)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## PropositionRates
- propositionRateId: INT IDENTITY(1,1) (PK)
- propositionId: INT (FK)
- percentageInFavorOf: DECIMAL (6, 3)
- percentageAgainst : DECIMAL (6, 3)

## propositions
- propositionsId : INT IDENTITY(1,1) (PK)
- propositionTopic : VARCHAR(100)
- createdBy : INT (FK)
- propositionFor : INT (FK)
- votes : INT
- totalAmountOfPoints: INT
- totaAmountOfMoney: DECIMAL (18, 6)
- createdAt : DATETIME2
- validFrom : DATETIME2
- validUntil : DATETIME2
- propositionStateId : INT (FK)
- evidence : VARCHAR(MAX) 
- result : VARCHAR(255)

## predictionState
- predictionStateId : INT IDENTITY(1,1) (PK)
- predictionStateName : VARCHAR(32)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## prediction
- predictionId : INT IDENTITY(1,1) (PK)
- userId : INT(FK)
- predictionStateId : INT(FK)
- propositionsId : INT(FK)
- description : VARCHAR (50)
- result : VARCHAR (25)
- amountOfPoints: INT
- amountOfMoney: DECIMAL (18, 6)
- validFrom : DATETIME2
- validUntil : DATETIME2

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

- updatedAt: DATETIME2
- updatedBy : INT (FK)

## usersPerRol
- userPerRolId : INT IDENTITY(1,1) (PK)
- userId : INT(FK)
- rolId : INT(FK)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## users
- userId : INT IDENTITY(1,1) (PK)			 	
- name : VARCHAR(50)					
- lastName : VARCHAR(50)				
- email : VARCHAR(100)		
- password : VARBINARY(MAX)		
- phone : INT 							
- creadetAt : DATETIME2	

- isActive : BIT						
- rolId : INT (FK)
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## usersAddresses
- userAddressId : INT IDENTITY(1,1) (PK)
- userId : INT (FK)					
- addressID : INT (FK)
- isActive : BIT						
- checksum : VARBINARY(MAX)					
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## walletStates
- walletStateId : INT IDENTITY(1,1) (PK)
- walletStateName : VARCHAR(50)
- walletStateDescription : VARCHAR(255)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- createdBy : INT (FK)

## wallets
- walletId : INT IDENTITY(1,1) (PK)
- userId : INT (FK)	
- balanceId : INT (FK)
- stateId : INT (FK)
- currencyId : INT (FK)
- pin : INT 
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

==============================================================
|        					social network                   |                                     
==============================================================

## Social Networks

- socialNetworkId: INT IDENTITY (1,1) (PK)
- socialNetworkName: VARCHAR (40)
- socialURL : VARCHAR (255)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK) 

- userId : INT(FK)
- sessionToken : VARCHAR(100)
- creadetAt : DATETIME2

## eventsTypes
- eventTypeId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(150)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## dataObjects
- dataObjectId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

- updatedAt: DATETIME2
- updatedBy: INT (FK)


## paymentsMethods
- paymentMethodId : INT IDENTITY(1,1) (PK)
- paymentMethodName : VARCHAR(50)
- URL : VARCHAR(255)
- config : VARBINARY(MAX)
- enabled : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy: INT (FK)

## paymentsMethodsPerCountry
- paymentMethodCountryId : INT IDENTITY(1,1) (PK)
- countryId : INT (FK) 
- paymentMethodId : INT (FK)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## paymentsAttempts 
- paymentAttemptId : INT IDENTITY(1,1) (PK)
- paymentAttemptDate : DATETIME2
- walletId : INT (FK)
- amount : DECIMAL (18, 6)
- currencyId : INT (FK)
- movementTypeId : INT (FK)
- result : VARCHAR(255)
- request : VARCHAR(255)
- transactionResponse : VARCHAR(MAX) 
- referenceObjectId : VARCHAR (50)
- sourceObjectId : VARCHAR (50)

## statusTransactionType
- statusTypeId : INT IDENTITY(1,1) (PK)
- statusName : VARCHAR(50) 
- statusDescription : VARCHAR(150)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## transactionState
- stateId : INT IDENTITY(1,1) (PK)
- orderId : INT (FK, NULL) 
- statusTypeId : INT (FK)
- stepName : VARCHAR(100) 
- executionTime : DATETIME2
- observations : VARBINARY(MAX)
- isActive : BIT
- createdAt: DATETIME2
- updatedAt: DATETIME2
- updatedBy : INT (FK)

## Transaction
- transactionID : INT IDENTITY(1,1) (PK)
- transactionNumber : INT
- transactionDate : DATETIME2
- paymentMethodCountryId : INT (FK)
- walletId : INT (FK)
- amount : DECIMAL (18, 6)
- currencyId : INT (FK)
- movementTypeId : INT (FK)
- stateId : INT (FK)
- createdAT : DATETIME2

## Balance
- walletId : INT IDENTITY(1,1) (PK y FK)
- currentPointsBalance : INT
- currentMoneyBalance : DECIMAL (18, 6)
- updatedAt: DATETIME2





Diseño de la base de datos despúes de la respuesta de gemini:
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
- email : VARCHAR(100)	
- passwordHash: VARCHAR (255)
- phone : VARCHAR(20)							
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

## SystemConfigurations
- configId : INT IDENTITY(1,1) (PK)
- configKey : UNIQUE VARCHAR (100) 
- configValue : VARCHAR (255)
- description : VARCHAR (150)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Sessions
- sessionId : INT IDENTITY(1,1) (PK)
- userId : INT(FK)
- sessionToken : VARCHAR(100)
- createdAt : DATETIME2

## EventTypes
- eventTypeId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(150)
- isActive : BIT
- createdAt: DATETIME2

## DataObjects
- dataObjectId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)
- isActive : BIT
- createdAt: DATETIME2

## ReferenceObjects
- referenceObjectId : INT IDENTITY(1,1) (PK)
- objectName : VARCHAR(100) 
- isActive : BIT

## SourceObjects
- sourceObjectId : INT IDENTITY(1,1) (PK)
- objectName : VARCHAR(100) 
- isActive : BIT

## Severities
- severityId : INT IDENTITY(1,1) (PK)
- name : VARCHAR(50)
- description : VARCHAR(100)
- isActive : BIT

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


## AIBitacoraProcesos
- processLogId : BIGINT IDENTITY(1,1) (PK)
- processTypeId : INT (FK)
- contentTypeId : INT (FK)
- contentUrl : VARCHAR(255)
- urlType : VARCHAR(50)
- sourceTypeId : INT (FK)
- requestJson : NVARCHAR(MAX)
- responseJson : NVARCHAR(MAX)
- resultTypeId : INT (FK)
- createdAt : DATETIME2

- propositionId : BIGINT (FK)
- platformId : INT (FK)
- resourceTypeId : INT (FK)
- url : VARCHAR (255)
- metadataJson : VARCHAR (MAX)
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
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

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
- referenceObjectId : INT (FK)
- sourceObjectId : INT (FK)
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



Cambios especificos se hicieron:
1. Abstracción de Fondos (De columnas estáticas a N-Formas de Pago)
Estado Anterior: Las tablas Propositions, Predictions y Balances tenían columnas fuertemente tipadas separadas: amountOfPoints (INT) y amountOfMoney (DECIMAL).

Cambio Realizado: Se eliminaron estas columnas estáticas. Se introdujo currencyId en Predictions y TransactionsLedger. La tabla Balances se refactorizó a una llave primaria compuesta (walletId, currencyId) con una sola columna currentBalance.

2. Evolución del Outcome (Eliminación del sesgo binario)
Estado Anterior: La tabla Predictions guardaba la predicción del usuario usando un tipo de dato lógico: predictedOutcome : BIT (Verdadero/Falso).

Cambio Realizado: Se creó la tabla catálogo PropositionOptions. En Predictions, el BIT se reemplazó por predictedOptionId : BIGINT (FK).

3. Refactorización de Tasas y Probabilidades (PropositionRates)
Estado Anterior: La tabla utilizaba columnas horizontales rígidas: percentageInFavorOf y percentageAgainst.

Cambio Realizado: Se cambió a un modelo vertical por filas apuntando a las opciones: optionId, currentVolume (cantidad total apostada a esa opción) y currentRate (multiplicador).

4. Gestión de Evidencia (De un enlace único a Colecciones)
Estado Anterior: La tabla Propositions contenía un campo evidenceUrl : VARCHAR(MAX).

Cambio Realizado: Se eliminó este campo de la cabecera. La evidencia ahora se maneja exclusivamente a través de la tabla relacional SocialResources, añadiendo un clasificador de propósito (resourcePurpose).

5. Trazabilidad de Proveedores de IA y Resoluciones
Estado Anterior: Había una bitácora básica (AIBitacoraProcesos), pero no existía trazabilidad sobre qué entidad resolvía la proposición ni con qué versión de motor.

Cambio Realizado: Se agregaron las tablas maestras AIProviders (ej. OpenAI, Anthropic) y AIModels vinculadas a la bitácora. Además, se creó OutcomeResolutions para registrar el momento exacto y la lógica con la que se cerró un evento.
