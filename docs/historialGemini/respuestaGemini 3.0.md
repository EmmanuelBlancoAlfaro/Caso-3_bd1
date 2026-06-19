Prompt enviado a la IA: 
Description del prediction muy pequeño
Te reto a no tener puntos y plata por separados, y más bien soportar N formas de fondos
El outcome mejor que no sea un bit por si luego eso evoluciona
Evita percentageagains y percetangefavor, porque te amarras en el diseño, mejor solo conta y diseñas por rows
No uses evidenceURL porque eso solo es un item una sola cosa, mejor tener colecciones de post de una red social que son usados por procesos, entre ellos predictions, AI moderation y Outcome results etc
No estoy seguro si ocupas la tabla de events
No se si systemconfiguration lo vas a usar para esto, pero es bueno tener los proveedores de AI, sus modelos y eso asociarlo en allprocesslogs para saber cuando interactuas con ellos los resutlados de esos procesos
No veo penalties, no veo cuando se evaluan los outcomes basados en que posts y como la AI los proceso y luego con esos outcomes empezar a repartir los puntos y platas; sin embargo , que no lo vea, no quiere decir que no esté en all process logs, transactions, movements y así, pero solo levanto la mano por si se te pudo haber olvidado algo de eso

Estos fueron los errores que me dijo el profesor sobre la base de datos, ya hice algunos cambios, puedes decirme como puedo arreglar los otros, la de tener N formas de pago no tiene mucha coherencia porque ya esta y aparte asi lo pide el proyecto, y lo del outcome no tiene mucha logica que pueda evulucionar, porque es saber si ya retorno las cosas o bueno termino esa proposicion. Luego lo de evidenceURL no se porque lo dice y los ultimos dos si se debe arreglar, y el sistemconfiguration si es necesario, algunos arreglos ya se hicieron 



Porque este prompt: Este prompt se realizo con la necesidad encontrar como solucionar algunos errores que el profe nos dijo que teniamos que corregir y no sabia como, antes del prompt ya se habian corregido varias de estas, pero todavia quedaban 2 o 3 cosas que no sabia como resolverlo entonces le pedi consejo a gemini.



La respuesta que me dio gemini fue esta con los cambios o errores que encontro:
El reto de las "N formas de fondos" (Puntos y plata juntos):

Por qué lo pide: Tener columnas separadas como totalAmountOfPoints y totalAmountOfMoney es un antipatrón porque "amarra" el diseño a solo esas dos opciones. Si el cliente decide agregar criptomonedas o fichas especiales, tendrías que modificar decenas de tablas.

La solución: Eliminamos esas columnas específicas de Propositions, Predictions y Balances. Ahora, el saldo y las apuestas se manejan por filas asociadas a un currencyId. En la tabla Currencies, la fila 1 serán "Puntos" y la fila 2 será "Dinero Real". Así, la tabla de Balances pasa a ser una tabla intermedia (walletId, currencyId, currentBalance). ¡Esto cumple al 100% el diseño genérico de N fondos!

Evolución del Outcome (No usar un BIT):

Por qué lo pide: Un BIT (0 o 1 / Verdadero o Falso) asume que el mundo es binario. ¿Qué pasa si una maratón se cancela por clima? ¿Qué pasa si hay un empate? ¿O si la proposición tiene múltiples opciones (ej: Elizabeth termina en 1°, 2° o 3° lugar)?

La solución: Creamos una tabla llamada PropositionOptions. Cada proposición puede tener N opciones de respuesta. El usuario en su predicción (Predictions) ya no elige un BIT, sino el optionId por el que quiere apostar.

Evitar porcentajes fijos en PropositionRates:

La solución: Al implementar la tabla de opciones del punto anterior, PropositionRates ahora guarda el volumen o multiplicador por opción (una fila por opción de la proposición), eliminando las columnas rígidas de "a favor" y "en contra".

Quitar evidenceUrl (Colecciones de Posts):

Por qué lo pide: Guardar un solo URL de texto limita la evidencia a una sola publicación. Un evento real puede requerir validar múltiples fuentes (un video de TikTok y una foto de Instagram).

La solución: Eliminamos evidenceUrl de Propositions. Para eso ya existe la tabla SocialResources, la cual funciona como una colección natural de posts que se ligan a la proposición. Agregamos un catálogo SocialResourcePurposes (o un campo similar) para identificar si el post fue usado para "Evidencia", "Moderación" o "Resolución".

Proveedores de IA y Modelos en SystemConfigurations / Logs:

La solución: Creamos las tablas AIProviders (ej: OpenAI, Google, Anthropic) y AIModels (ej: GPT-4o, Gemini 1.5 Pro). De esta forma, la bitácora de procesos (AIBitacoraProcesos) referencia directamente al modelo de IA que tomó la decisión de aprobar, rechazar o evaluar un resultado.

Penalizaciones y Evaluación de Outcomes:

La solución: Creamos la tabla OutcomeResolutions. Esta tabla documenta exactamente cuándo y cómo la IA evaluó los posts de redes sociales para cerrar una proposición. Además, para las penalizaciones, simplemente nos aseguramos de que existan en la tabla MovementTypes filas explícitas para "Penalización por Evidencia Falsa" o "Cobro de Comisión", rastreándose de forma nativa en el Ledger.



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
- processTypeName : VARCHAR(50) -- Ej: 'ModeracionContenido', 'EvaluacionOutcome', 'VerificacionEvidencia'
- isActive : BIT
- createdAt : DATETIME2

## AIContentTypes
- contentTypeId : INT IDENTITY(1,1) (PK)
- contentTypeName : VARCHAR(50) -- Ej: 'Texto', 'Imagen', 'Video'
- isActive : BIT
- createdAt : DATETIME2

## AIBitacoraProcesos
- processLogId : BIGINT IDENTITY(1,1) (PK)
- processTypeId : INT (FK)
- modelId : INT (FK) -- Vinculación directa con el modelo de IA utilizado
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
-- Opcional, pero útil para agrupar macro-eventos reales (ej: Maratón de San José)
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
- propositionStateName : VARCHAR (40) -- (Pendiente_AI, Activa, Evaluando, Cerrada, Cancelada)
- allowsPredictions : BIT
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Propositions
- propositionId : BIGINT IDENTITY (1,1) (PK)
- eventId : INT (FK, NULL) 
- propositionTopic : VARCHAR(100)
- createdByUserId : INT (FK)
- targetUserId : INT (FK)
- propositionStateId : INT (FK)
- description : VARCHAR (255)
- votes : INT
- deadlineDate : DATETIME2
- eventDate : DATETIME2
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
- createdAt : DATETIME2

## PropositionRates
-- Se calcula por filas por opción, evitando amarrarse a porcentajes fijos
- propositionRateId: BIGINT IDENTITY(1,1) (PK)
- optionId: BIGINT (FK)
- currentVolume : DECIMAL (18, 6) -- Cantidad total apostada a esta opción
- currentRate: DECIMAL (6, 3)     -- Multiplicador actual calculado para pagos

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
- predictionStateName : VARCHAR(32) -- (Pendiente, Ganada, Perdida, Reembolsada)
- isActive : BIT
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK)

## Predictions
- predictionId : BIGINT IDENTITY (1,1) (PK)
- propositionId : BIGINT (FK)
- userId : INT (FK)
- predictedOptionId : BIGINT (FK) -- Apunta a la opción elegida (no un BIT)
- predictionStateId : INT (FK)
- description : VARCHAR (500) -- Ampliado el tamaño de la descripción según feedback
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
-- Aquí reside la colección de evidencias o posts analizados (se quitó evidenceUrl de la Proposición)
- resourceId : BIGINT IDENTITY(1,1) (PK)
- propositionId : BIGINT (FK)
- platformId : INT (FK)
- resourceTypeId : INT (FK)
- url : VARCHAR (255)
- resourcePurpose : VARCHAR (50) -- Ej: 'EvidenciaProposicion', 'ResultadoOutcome', 'Moderacion'
- metadataJson : VARCHAR (MAX)
- isActive : BIT						
- createdAt : DATETIME2
- updatedAt : DATETIME2
- updatedBy : INT (FK) 

## OutcomeResolutions
-- Evidencia explícita de cómo y qué IA evaluó el resultado final para repartir los fondos/penalizaciones
- resolutionId : BIGINT IDENTITY(1,1) (PK)
- propositionId : BIGINT (FK)
- processLogId : BIGINT (FK) -- Enlace al log exacto de la IA que lo procesó
- finalOptionId : BIGINT (FK) -- La opción que se determinó como ganadora
- resolvedAt : DATETIME2
- observations : VARCHAR(MAX)

==============================================================
|        			ECONOMY AND LEDGER       			     |                                     
==============================================================

## Currencies
-- Aquí viven los "N" tipos de fondos (Fila 1: Puntos, Fila 2: Plata, Fila 3: Cripto)
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
-- Soporta de forma nativa Penalizaciones, Reparto de ganancias y Apuestas
- movementTypeId : INT IDENTITY(1,1) (PK)
- movementTypeName : VARCHAR(80) -- Ej: 'PremioPrediccion', 'ApuestaProposicion', 'PenalizacionEvidenciaFalsa'
- affectsSign: INT -- (+1 depósitos/ganancias, -1 retiros/apuestas/penalizaciones)
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
-- Estructura Clave de N Fondos: Se maneja por combinaciones de Wallet y Currency
- walletId : INT (FK)
- currencyId : INT (FK) -- (Llave Primaria Compuesta junto con walletId)
- currentBalance : DECIMAL (18, 6) -- Aquí cae el saldo final sea de Puntos o Plata
- updatedAt: DATETIME2
- CONSTRAINT PK_Balances PRIMARY KEY (walletId, currencyId)





Este fue el diseño que teniamos antes de la consulta: 

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

## SEGUN EL PROFE MEJOR ELIMINAR ESTO, Y TRABAJARLO EN EL BACKEND
## PropositionRates
- propositionRateId: BIGINT IDENTITY(1,1) (PK)
- propositionId: BIGINT (FK)
- percentageInFavorOf: DECIMAL (6, 3)
- percentageAgainst : DECIMAL (6, 3)
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





Diseño de la base de datos despúes de la respuesta de gemini:

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





Cambios especificos se hicieron:
1. Transformación del Resultado de la Proposición (De Binario a N-Opciones)
Estado Anterior: Las predicciones de los usuarios se limitaban a un tipo de dato lógico en la tabla Predictions (predictedOutcome : BIT).

Cambio Realizado: Se implementó la tabla PropositionOptions para definir dinámicamente las posibles resoluciones de un evento. En consecuencia, la tabla Predictions reemplazó el campo binario por predictedOptionId : BIGINT (FK).

2. Consolidación de la Economía Abierta (N-Fondos)
Estado Anterior: Las tablas transaccionales y de saldos requerían estructuras rígidas o duplicadas para manejar diferentes tipos de valores.

Cambio Realizado: Se consolidó el modelo utilizando currencyId. En Predictions se unificó la apuesta en el campo amount. De manera crítica, la tabla Balances se rediseñó para utilizar una llave primaria compuesta (walletId, currencyId) con una única columna currentBalance.

3. Supresión de Cálculos en Tiempo Real (Eliminación de PropositionRates)
Estado Anterior: El esquema contemplaba tablas físicas (PropositionRates) para almacenar los porcentajes en contra/a favor o los multiplicadores financieros.

Cambio Realizado: La tabla fue eliminada por completo del modelo relacional, delegando la responsabilidad del cálculo matemático a la capa de aplicación.

4. Simplificación y Centralización de la Bitácora de Inteligencia Artificial
Estado Anterior: Hubo propuestas para sobre-normalizar el esquema incluyendo proveedores, versiones de modelos (OpenAI, Gemini) y detalles operativos complejos.

Cambio Realizado: Se acató la restricción del alcance inicial. Se consolidó la observabilidad en una tabla centralizada AIProcessesLogs, apoyada por catálogos ligeros (AIProcessTypes, AIContentTypes, URLTypes, AIResultTypes).

5. Estandarización del Polimorfismo Relacional en Auditoría
Estado Anterior: La trazabilidad de transacciones o pagos (PaymentAttempts) apuntaba de forma genérica a objetos del sistema sin validación estricta de su naturaleza.

Cambio Realizado: Se incorporaron los catálogos ReferenceObjectsTypes y SourceObjectsTypes para acompañar a las referencias genéricas (referenceObjectId, sourceObjectId).