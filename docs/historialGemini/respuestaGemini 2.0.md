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