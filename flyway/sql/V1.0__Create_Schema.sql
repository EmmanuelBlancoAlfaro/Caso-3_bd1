-- V1.0 - Creacion del esquema inicial de Gathel

USE GathelDB;
GO

-- USERS AND GEOGRAPHY

CREATE TABLE Countries (
    countryId   INT IDENTITY(1,1) PRIMARY KEY,
    isoCode     VARCHAR(3)  NOT NULL UNIQUE,
    countryName VARCHAR(50) NOT NULL,
    isActive    BIT         NOT NULL DEFAULT 1,
    createdAt   DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt   DATETIME2   NULL,
    updatedBy   INT         NULL
);
GO

CREATE TABLE States (
    stateId   INT IDENTITY(1,1) PRIMARY KEY,
    countryId INT         NOT NULL REFERENCES Countries(countryId),
    stateName VARCHAR(40) NOT NULL,
    isActive  BIT         NOT NULL DEFAULT 1,
    createdAt DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt DATETIME2   NULL,
    updatedBy INT         NULL
);
GO

CREATE TABLE Cities (
    cityId    INT IDENTITY(1,1) PRIMARY KEY,
    stateId   INT         NOT NULL REFERENCES States(stateId),
    cityName  VARCHAR(50) NOT NULL,
    isActive  BIT         NOT NULL DEFAULT 1,
    createdAt DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt DATETIME2   NULL,
    updatedBy INT         NULL
);
GO

CREATE TABLE Addresses (
    addressId INT IDENTITY(1,1) PRIMARY KEY,
    cityId    INT           NOT NULL REFERENCES Cities(cityId),
    address   VARCHAR(100)  NOT NULL,
    zipCode   VARCHAR(20)   NULL,
    position  GEOGRAPHY     NULL,
    isActive  BIT           NOT NULL DEFAULT 1,
    createdAt DATETIME2     NOT NULL DEFAULT GETDATE(),
    updatedAt DATETIME2     NULL,
    updatedBy INT           NULL
);
GO

CREATE TABLE Permissions (
    permissionId   INT IDENTITY(1,1) PRIMARY KEY,
    permissionName VARCHAR(50)  NOT NULL,
    description    VARCHAR(200) NULL,
    isActive       BIT          NOT NULL DEFAULT 1,
    createdAt      DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME2    NULL,
    updatedBy      INT          NULL
);
GO

CREATE TABLE Roles (
    roleId      INT IDENTITY(1,1) PRIMARY KEY,
    roleName    VARCHAR(50)  NOT NULL,
    description VARCHAR(150) NULL,
    isActive    BIT          NOT NULL DEFAULT 1,
    createdAt   DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt   DATETIME2    NULL,
    updatedBy   INT          NULL
);
GO

CREATE TABLE Users (
    userId       INT IDENTITY(1,1) PRIMARY KEY,
    name         VARCHAR(50)  NOT NULL,
    lastName     VARCHAR(50)  NOT NULL,
    passwordHash VARCHAR(255) NOT NULL,
    isActive     BIT          NOT NULL DEFAULT 1,
    createdAt    DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt    DATETIME2    NULL,
    updatedBy    INT          NULL REFERENCES Users(userId)
);
GO

-- FK de updatedBy para las tablas creadas antes que Users
ALTER TABLE Countries  ADD CONSTRAINT FK_Countries_UpdatedBy  FOREIGN KEY (updatedBy) REFERENCES Users(userId);
ALTER TABLE States     ADD CONSTRAINT FK_States_UpdatedBy     FOREIGN KEY (updatedBy) REFERENCES Users(userId);
ALTER TABLE Cities     ADD CONSTRAINT FK_Cities_UpdatedBy     FOREIGN KEY (updatedBy) REFERENCES Users(userId);
ALTER TABLE Addresses  ADD CONSTRAINT FK_Addresses_UpdatedBy  FOREIGN KEY (updatedBy) REFERENCES Users(userId);
ALTER TABLE Permissions ADD CONSTRAINT FK_Permissions_UpdatedBy FOREIGN KEY (updatedBy) REFERENCES Users(userId);
ALTER TABLE Roles      ADD CONSTRAINT FK_Roles_UpdatedBy      FOREIGN KEY (updatedBy) REFERENCES Users(userId);
GO

CREATE TABLE PermissionsPerRoles (
    permissionPerRoleId INT IDENTITY(1,1) PRIMARY KEY,
    roleId              INT       NOT NULL REFERENCES Roles(roleId),
    permissionId        INT       NOT NULL REFERENCES Permissions(permissionId),
    isActive            BIT       NOT NULL DEFAULT 1,
    createdAt           DATETIME2 NOT NULL DEFAULT GETDATE(),
    updatedAt           DATETIME2 NULL,
    updatedBy           INT       NULL REFERENCES Users(userId)
);
GO

CREATE TABLE UsersPerRoles (
    userPerRoleId INT IDENTITY(1,1) PRIMARY KEY,
    userId        INT       NOT NULL REFERENCES Users(userId),
    roleId        INT       NOT NULL REFERENCES Roles(roleId),
    isActive      BIT       NOT NULL DEFAULT 1,
    createdAt     DATETIME2 NOT NULL DEFAULT GETDATE(),
    updatedAt     DATETIME2 NULL,
    updatedBy     INT       NULL REFERENCES Users(userId)
);
GO

CREATE TABLE UsersAddresses (
    userAddressId INT IDENTITY(1,1) PRIMARY KEY,
    userId        INT            NOT NULL REFERENCES Users(userId),
    addressId     INT            NOT NULL REFERENCES Addresses(addressId),
    checksum      VARBINARY(MAX) NULL,
    isActive      BIT            NOT NULL DEFAULT 1,
    createdAt     DATETIME2      NOT NULL DEFAULT GETDATE(),
    updatedAt     DATETIME2      NULL,
    updatedBy     INT            NULL REFERENCES Users(userId)
);
GO

-- CONTACT INFO

CREATE TABLE ContactTypes (
    contactTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    contactTypeName VARCHAR(50) NOT NULL,
    isActive        BIT         NOT NULL DEFAULT 1,
    createdAt       DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt       DATETIME2   NULL,
    updatedBy       INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE Contacts (
    contactId     INT IDENTITY(1,1) PRIMARY KEY,
    contactTypeId INT          NOT NULL REFERENCES ContactTypes(contactTypeId),
    userId        INT          NOT NULL REFERENCES Users(userId),
    contactValue  VARCHAR(100) NOT NULL,
    isActive      BIT          NOT NULL DEFAULT 1,
    createdAt     DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt     DATETIME2    NULL,
    updatedBy     INT          NULL REFERENCES Users(userId)
);
GO

-- AUDIT INFO AND CONFIG

CREATE TABLE SystemConfigurations (
    configId    INT IDENTITY(1,1) PRIMARY KEY,
    configKey   VARCHAR(100) NOT NULL UNIQUE,
    configValue VARCHAR(255) NOT NULL,
    description VARCHAR(150) NULL,
    isActive    BIT          NOT NULL DEFAULT 1,
    createdAt   DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt   DATETIME2    NULL,
    updatedBy   INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE AIProviders (
    providerId   INT IDENTITY(1,1) PRIMARY KEY,
    providerName VARCHAR(50) NOT NULL,
    isActive     BIT         NOT NULL DEFAULT 1,
    createdAt    DATETIME2   NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE AIModels (
    modelId      INT IDENTITY(1,1) PRIMARY KEY,
    providerId   INT          NOT NULL REFERENCES AIProviders(providerId),
    modelName    VARCHAR(100) NOT NULL,
    modelVersion VARCHAR(20)  NULL,
    isActive     BIT          NOT NULL DEFAULT 1,
    createdAt    DATETIME2    NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE Sessions (
    sessionId    INT IDENTITY(1,1) PRIMARY KEY,
    userId       INT          NOT NULL REFERENCES Users(userId),
    sessionToken VARCHAR(100) NOT NULL,
    isActive     BIT          NOT NULL DEFAULT 1,
    createdAt    DATETIME2    NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE EventTypes (
    eventTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    description VARCHAR(150) NULL,
    isActive    BIT          NOT NULL DEFAULT 1,
    createdAt   DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt   DATETIME2    NULL,
    updatedBy   INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE DataObjects (
    dataObjectId INT IDENTITY(1,1) PRIMARY KEY,
    name         VARCHAR(50)  NOT NULL,
    description  VARCHAR(100) NULL,
    isActive     BIT          NOT NULL DEFAULT 1,
    createdAt    DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt    DATETIME2    NULL,
    updatedBy    INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE ReferenceObjectsTypes (
    referenceObjectTypeId INT IDENTITY(1,1) PRIMARY KEY,
    objectTypeName        VARCHAR(100) NOT NULL,
    isActive              BIT          NOT NULL DEFAULT 1,
    createdAt             DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt             DATETIME2    NULL,
    updatedBy             INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE SourceObjectsTypes (
    sourceObjectTypeId INT IDENTITY(1,1) PRIMARY KEY,
    objectTypeName     VARCHAR(100) NOT NULL,
    isActive           BIT          NOT NULL DEFAULT 1,
    createdAt          DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt          DATETIME2    NULL,
    updatedBy          INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE Severities (
    severityId  INT IDENTITY(1,1) PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    description VARCHAR(100) NULL,
    isActive    BIT          NOT NULL DEFAULT 1,
    createdAt   DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt   DATETIME2    NULL,
    updatedBy   INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE UsersLogs (
    logId        INT IDENTITY(1,1) PRIMARY KEY,
    eventTypeId  INT            NOT NULL REFERENCES EventTypes(eventTypeId),
    dataObjectId INT            NOT NULL REFERENCES DataObjects(dataObjectId),
    sessionId    INT            NOT NULL REFERENCES Sessions(sessionId),
    description  VARCHAR(255)   NULL,
    metadata     VARBINARY(MAX) NULL,
    createdAt    DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE SystemErrorLogs (
    errorId      INT IDENTITY(1,1) PRIMARY KEY,
    severityId   INT            NOT NULL REFERENCES Severities(severityId),
    processUuid  VARCHAR(100)   NULL,
    processName  VARCHAR(100)   NULL,
    stepName     VARCHAR(100)   NULL,
    inputData    VARBINARY(MAX) NULL,
    errorMessage VARBINARY(MAX) NULL,
    createdAt    DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE AIProcessTypes (
    processTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    processTypeName VARCHAR(50) NOT NULL,
    isActive        BIT         NOT NULL DEFAULT 1,
    createdAt       DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt       DATETIME2   NULL,
    updatedBy       INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE AIContentTypes (
    contentTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    contentTypeName VARCHAR(50) NOT NULL,
    isActive        BIT         NOT NULL DEFAULT 1,
    createdAt       DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt       DATETIME2   NULL,
    updatedBy       INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE SourceTypes (
    sourceTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    sourceTypeName VARCHAR(40) NOT NULL,
    isActive       BIT         NOT NULL DEFAULT 1,
    createdAt      DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME2   NULL,
    updatedBy      INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE AIResultTypes (
    resultTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    resultTypeName VARCHAR(40) NOT NULL,
    isActive       BIT         NOT NULL DEFAULT 1,
    createdAt      DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME2   NULL,
    updatedBy      INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE URLTypes (
    urlTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    urlTypeName VARCHAR(50) NOT NULL,
    isActive    BIT         NOT NULL DEFAULT 1,
    createdAt   DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt   DATETIME2   NULL,
    updatedBy   INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE AIProcessesLogs (
    processLogId  BIGINT IDENTITY(1,1) PRIMARY KEY,
    processTypeId INT           NOT NULL REFERENCES AIProcessTypes(processTypeId),
    contentTypeId INT           NOT NULL REFERENCES AIContentTypes(contentTypeId),
    urlTypeId     INT           NOT NULL REFERENCES URLTypes(urlTypeId),
    resultTypeId  INT           NOT NULL REFERENCES AIResultTypes(resultTypeId),
    sourceTypeId  INT           NOT NULL REFERENCES SourceTypes(sourceTypeId),
    contentUrl    VARCHAR(255)  NULL,
    requestJson   NVARCHAR(MAX) NULL,
    responseJson  NVARCHAR(MAX) NULL,
    createdAt     DATETIME2     NOT NULL DEFAULT GETDATE()
);
GO

-- GAME ENGINE

CREATE TABLE PropositionStates (
    propositionStateId   INT IDENTITY(1,1) PRIMARY KEY,
    propositionStateName VARCHAR(40) NOT NULL,
    allowsPredictions    BIT         NOT NULL DEFAULT 0,
    isActive             BIT         NOT NULL DEFAULT 1,
    createdAt            DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt            DATETIME2   NULL,
    updatedBy            INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PropositionsResultsTypes (
    resultTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    resultTypeName VARCHAR(40) NOT NULL,
    isActive       BIT         NOT NULL DEFAULT 1,
    createdAt      DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME2   NULL,
    updatedBy      INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE SocialPlatforms (
    platformId   INT IDENTITY(1,1) PRIMARY KEY,
    platformName VARCHAR(50) NOT NULL,
    isActive     BIT         NOT NULL DEFAULT 1,
    createdAt    DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt    DATETIME2   NULL,
    updatedBy    INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE SocialResourceTypes (
    resourceTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    resourceTypeName VARCHAR(40) NOT NULL,
    isActive         BIT         NOT NULL DEFAULT 1,
    createdAt        DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt        DATETIME2   NULL,
    updatedBy        INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PredictionStates (
    predictionStateId   INT IDENTITY(1,1) PRIMARY KEY,
    predictionStateName VARCHAR(32) NOT NULL,
    isActive            BIT         NOT NULL DEFAULT 1,
    createdAt           DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt           DATETIME2   NULL,
    updatedBy           INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE Currencies (
    currencyId     INT IDENTITY(1,1) PRIMARY KEY,
    currencySymbol VARCHAR(5)  NOT NULL,
    currencyName   VARCHAR(40) NOT NULL,
    isVirtual      BIT         NOT NULL DEFAULT 0,
    isActive       BIT         NOT NULL DEFAULT 1,
    createdAt      DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME2   NULL,
    updatedBy      INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE Propositions (
    propositionId      BIGINT IDENTITY(1,1) PRIMARY KEY,
    eventId            INT          NULL,
    propositionTopic   VARCHAR(100) NOT NULL,
    createdByUserId    INT          NOT NULL REFERENCES Users(userId),
    targetUserId       INT          NOT NULL REFERENCES Users(userId),
    propositionStateId INT          NOT NULL REFERENCES PropositionStates(propositionStateId),
    description        VARCHAR(255) NULL,
    evidenceUrl        VARCHAR(MAX) NULL,
    resultTypeId       INT          NULL REFERENCES PropositionsResultsTypes(resultTypeId),
    validFrom          DATETIME2    NULL,
    validUntil         DATETIME2    NULL,
    isActive           BIT          NOT NULL DEFAULT 1,
    createdAt          DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt          DATETIME2    NULL,
    updatedBy          INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PropositionOptions (
    optionId        BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId   BIGINT       NOT NULL REFERENCES Propositions(propositionId),
    optionText      VARCHAR(100) NOT NULL,
    isWinningOption BIT          NULL,
    isActive        BIT          NOT NULL DEFAULT 1,
    createdAt       DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt       DATETIME2    NULL,
    updatedBy       INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PropositionStateHistories (
    historyId     BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId BIGINT    NOT NULL REFERENCES Propositions(propositionId),
    oldStateId    INT       NULL     REFERENCES PropositionStates(propositionStateId),
    newStateId    INT       NOT NULL REFERENCES PropositionStates(propositionStateId),
    isActive      BIT       NOT NULL DEFAULT 1,
    createdAt     DATETIME2 NOT NULL DEFAULT GETDATE(),
    updatedAt     DATETIME2 NULL,
    updatedBy     INT       NULL REFERENCES Users(userId)
);
GO

CREATE TABLE Predictions (
    predictionId      BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId     BIGINT         NOT NULL REFERENCES Propositions(propositionId),
    userId            INT            NOT NULL REFERENCES Users(userId),
    predictionStateId INT            NOT NULL REFERENCES PredictionStates(predictionStateId),
    description       VARCHAR(255)   NULL,
    predictedOptionId BIGINT         NOT NULL REFERENCES PropositionOptions(optionId),
    amount            DECIMAL(18, 6) NOT NULL,
    currencyId        INT            NOT NULL REFERENCES Currencies(currencyId),
    validFrom         DATETIME2      NULL,
    validUntil        DATETIME2      NULL,
    isActive          BIT            NOT NULL DEFAULT 1,
    createdAt         DATETIME2      NOT NULL DEFAULT GETDATE(),
    updatedAt         DATETIME2      NULL,
    updatedBy         INT            NULL REFERENCES Users(userId)
);
GO

CREATE TABLE SocialResources (
    resourceId      BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId   BIGINT         NOT NULL REFERENCES Propositions(propositionId),
    platformId      INT            NOT NULL REFERENCES SocialPlatforms(platformId),
    resourceTypeId  INT            NOT NULL REFERENCES SocialResourceTypes(resourceTypeId),
    url             VARCHAR(255)   NOT NULL,
    resourcePurpose VARCHAR(50)    NULL,
    metadataJson    NVARCHAR(MAX)  NULL,
    isActive        BIT            NOT NULL DEFAULT 1,
    createdAt       DATETIME2      NOT NULL DEFAULT GETDATE(),
    updatedAt       DATETIME2      NULL,
    updatedBy       INT            NULL REFERENCES Users(userId)
);
GO

-- ECONOMY AND LEDGER

CREATE TABLE ExchangeRates (
    exchangeRateId INT IDENTITY(1,1) PRIMARY KEY,
    currencyId1    INT            NOT NULL REFERENCES Currencies(currencyId),
    currencyId2    INT            NOT NULL REFERENCES Currencies(currencyId),
    exchangeRate   DECIMAL(18, 6) NOT NULL,
    postTime       DATETIME2      NOT NULL,
    checkSum       VARBINARY(MAX) NULL,
    createdAt      DATETIME2      NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME2      NULL,
    updatedBy      INT            NULL REFERENCES Users(userId)
);
GO

CREATE TABLE ExchangeHistories (
    exchangeHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    startDateTime     DATETIME2      NOT NULL,
    endDateTime       DATETIME2      NULL,
    exchangeRateId    INT            NOT NULL REFERENCES ExchangeRates(exchangeRateId),
    currencyId1       INT            NOT NULL REFERENCES Currencies(currencyId),
    currencyId2       INT            NOT NULL REFERENCES Currencies(currencyId),
    exchangeRate      DECIMAL(18, 6) NOT NULL,
    postTime          DATETIME2      NOT NULL,
    checkSum          VARBINARY(MAX) NULL,
    createdAt         DATETIME2      NOT NULL DEFAULT GETDATE(),
    updatedAt         DATETIME2      NULL,
    updatedBy         INT            NULL REFERENCES Users(userId)
);
GO

CREATE TABLE Wallets (
    walletId   INT IDENTITY(1,1) PRIMARY KEY,
    userId     INT       NOT NULL REFERENCES Users(userId),
    currencyId INT       NOT NULL REFERENCES Currencies(currencyId),
    pin        INT       NULL,
    isActive   BIT       NOT NULL DEFAULT 1,
    createdAt  DATETIME2 NOT NULL DEFAULT GETDATE(),
    updatedAt  DATETIME2 NULL,
    updatedBy  INT       NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PaymentMethods (
    paymentMethodId   INT IDENTITY(1,1) PRIMARY KEY,
    paymentMethodName VARCHAR(50)   NOT NULL,
    apiURL            VARCHAR(255)  NULL,
    configJson        NVARCHAR(MAX) NULL,
    isActive          BIT           NOT NULL DEFAULT 1,
    createdAt         DATETIME2     NOT NULL DEFAULT GETDATE(),
    updatedAt         DATETIME2     NULL,
    updatedBy         INT           NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PaymentMethodsPerCountry (
    paymentMethodCountryId INT IDENTITY(1,1) PRIMARY KEY,
    countryId              INT       NOT NULL REFERENCES Countries(countryId),
    paymentMethodId        INT       NOT NULL REFERENCES PaymentMethods(paymentMethodId),
    isActive               BIT       NOT NULL DEFAULT 1,
    createdAt              DATETIME2 NOT NULL DEFAULT GETDATE(),
    updatedAt              DATETIME2 NULL,
    updatedBy              INT       NULL REFERENCES Users(userId)
);
GO

CREATE TABLE MovementTypes (
    movementTypeId          INT IDENTITY(1,1) PRIMARY KEY,
    movementTypeName        VARCHAR(80)  NOT NULL,
    movementTypeDescription VARCHAR(255) NULL,
    createdAt               DATETIME2    NOT NULL DEFAULT GETDATE(),
    updatedAt               DATETIME2    NULL,
    updatedBy               INT          NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PaymentResultTypes (
    resultTypeId   INT IDENTITY(1,1) PRIMARY KEY,
    resultTypeName VARCHAR(40) NOT NULL,
    isActive       BIT         NOT NULL DEFAULT 1,
    createdAt      DATETIME2   NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME2   NULL,
    updatedBy      INT         NULL REFERENCES Users(userId)
);
GO

CREATE TABLE PaymentAttempts (
    attemptId             BIGINT IDENTITY(1,1) PRIMARY KEY,
    attemptDate           DATETIME2      NOT NULL DEFAULT GETDATE(),
    walletId              INT            NOT NULL REFERENCES Wallets(walletId),
    amount                DECIMAL(18, 6) NOT NULL,
    currencyId            INT            NOT NULL REFERENCES Currencies(currencyId),
    movementTypeId        INT            NOT NULL REFERENCES MovementTypes(movementTypeId),
    resultTypeId          INT            NOT NULL REFERENCES PaymentResultTypes(resultTypeId),
    referenceObjectTypeId INT            NULL     REFERENCES ReferenceObjectsTypes(referenceObjectTypeId),
    referenceObjectId     VARCHAR(50)    NULL,
    sourceObjectTypeId    INT            NULL     REFERENCES SourceObjectsTypes(sourceObjectTypeId),
    sourceObjectId        VARCHAR(50)    NULL,
    requestJson           NVARCHAR(MAX)  NULL,
    responseJson          NVARCHAR(MAX)  NULL,
    transactionResponse   VARCHAR(MAX)   NULL
);
GO

CREATE TABLE TransactionsLedger (
    transactionId     BIGINT IDENTITY(1,1) PRIMARY KEY,
    transactionNumber VARCHAR(100)   NOT NULL UNIQUE,
    transactionDate   DATETIME2      NOT NULL,
    walletId          INT            NOT NULL REFERENCES Wallets(walletId),
    attemptId         BIGINT         NOT NULL REFERENCES PaymentAttempts(attemptId),
    movementTypeId    INT            NOT NULL REFERENCES MovementTypes(movementTypeId),
    currencyId        INT            NOT NULL REFERENCES Currencies(currencyId),
    amount            DECIMAL(18, 6) NOT NULL,
    createdAt         DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE Balances (
    walletId       INT            NOT NULL REFERENCES Wallets(walletId),
    currencyId     INT            NOT NULL REFERENCES Currencies(currencyId),
    currentBalance DECIMAL(18, 6) NOT NULL DEFAULT 0,
    updatedAt      DATETIME2      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Balances PRIMARY KEY (walletId, currencyId)
);
GO
