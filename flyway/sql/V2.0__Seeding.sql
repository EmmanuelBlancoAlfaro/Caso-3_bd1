-- V2.0 - Seeding inicial
-- 1 usuario Sistema + 1000 jugadores, 5000 proposiciones,
-- >250000 predicciones con retencion en ledger, pagos y sincronizacion de balances

USE GathelDB;
GO

SET NOCOUNT ON;
GO

-- USUARIO SISTEMA (userId = 1)
-- Recibe todas las comisiones de la plataforma. No participa como jugador.

DECLARE @sysNow DATETIME2 = DATEADD(DAY, -400, GETDATE());

INSERT INTO Users (name, lastName, passwordHash, isActive, createdAt)
VALUES ('Sistema', 'Gathel',
        CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'SYSTEM'), 2),
        1, @sysNow);

INSERT INTO UsersPerRoles (userId, roleId, isActive, createdAt)
VALUES (1, 1, 1, @sysNow);  -- rol Admin

INSERT INTO Wallets (userId, currencyId, isActive, createdAt)
VALUES (1, 1, 1, @sysNow);  -- walletId = 1, billetera de puntos de la plataforma

INSERT INTO Balances (walletId, currencyId, currentBalance, updatedAt)
VALUES (1, 1, 0, @sysNow);  -- se recalcula al final desde el ledger
GO

-- JUGADORES (1000)
-- Cada uno: 100 puntos iniciales (regla del caso) + compra de 4900 para liquidez

DECLARE @i         INT = 1;
DECLARE @userId    INT;
DECLARE @walletId  INT;
DECLARE @attemptId BIGINT;
DECLARE @now       DATETIME2 = GETDATE();
DECLARE @createdAt DATETIME2;
DECLARE @buyAt     DATETIME2;

WHILE @i <= 1000
BEGIN
    SET @createdAt = DATEADD(DAY, -(@i * 365 / 1000) - 1, @now);

    INSERT INTO Users (name, lastName, passwordHash, isActive, createdAt)
    VALUES (
        'Player' + CAST(@i AS VARCHAR),
        'User'   + CAST(@i AS VARCHAR),
        CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CAST(@i AS VARCHAR)), 2),
        1, @createdAt
    );
    SET @userId = SCOPE_IDENTITY();

    INSERT INTO UsersPerRoles (userId, roleId, isActive, createdAt)
    VALUES (@userId, 3, 1, @createdAt);

    INSERT INTO Contacts (contactTypeId, userId, contactValue, isActive, createdAt)
    VALUES (1, @userId, 'player' + CAST(@i AS VARCHAR) + '@gathel.com', 1, @createdAt);

    INSERT INTO Wallets (userId, currencyId, isActive, createdAt)
    VALUES (@userId, 1, 1, @createdAt);
    SET @walletId = SCOPE_IDENTITY();

    INSERT INTO Balances (walletId, currencyId, currentBalance, updatedAt)
    VALUES (@walletId, 1, 0, @createdAt);

    -- Puntos iniciales (100) - regla textual del caso
    INSERT INTO PaymentAttempts (attemptDate, walletId, amount, currencyId,
        movementTypeId, resultTypeId, referenceObjectTypeId, referenceObjectId, sourceObjectTypeId, sourceObjectId)
    VALUES (@createdAt, @walletId, 100.000000, 1, 10, 1, 3, CAST(@walletId AS VARCHAR), 2, 'SYSTEM');
    SET @attemptId = SCOPE_IDENTITY();

    INSERT INTO TransactionsLedger (transactionNumber, transactionDate, walletId,
        attemptId, movementTypeId, currencyId, amount, createdAt)
    VALUES ('TXN-INIT-' + CAST(@attemptId AS VARCHAR), @createdAt, @walletId, @attemptId, 10, 1, 100.000000, @createdAt);

    -- Compra de puntos (4900) para liquidez de apuestas
    SET @buyAt = DATEADD(HOUR, 1 + ABS(CHECKSUM(NEWID())) % 48, @createdAt);

    INSERT INTO PaymentAttempts (attemptDate, walletId, amount, currencyId,
        movementTypeId, resultTypeId, referenceObjectTypeId, referenceObjectId, sourceObjectTypeId, sourceObjectId)
    VALUES (@buyAt, @walletId, 4900.000000, 1, 9, 1, 3, CAST(@walletId AS VARCHAR), 1, CAST(@userId AS VARCHAR));
    SET @attemptId = SCOPE_IDENTITY();

    INSERT INTO TransactionsLedger (transactionNumber, transactionDate, walletId,
        attemptId, movementTypeId, currencyId, amount, createdAt)
    VALUES ('TXN-BUY-' + CAST(@attemptId AS VARCHAR), @buyAt, @walletId, @attemptId, 9, 1, 4900.000000, @buyAt);

    SET @i = @i + 1;
END;
GO

-- PROPOSICIONES (5000)

CREATE TABLE #PropOptions (
    propositionId BIGINT,
    optionId1     BIGINT,
    optionId2     BIGINT,
    propStateId   INT,
    createdAt     DATETIME2
);
GO

DECLARE @j              INT = 1;
DECLARE @creatorId      INT;
DECLARE @targetId       INT;
DECLARE @stateId        INT;
DECLARE @resultTypeId   INT;
DECLARE @propId         BIGINT;
DECLARE @opt1           BIGINT;
DECLARE @opt2           BIGINT;
DECLARE @rand           INT;
DECLARE @propCreatedAt  DATETIME2;
DECLARE @propValidUntil DATETIME2;
DECLARE @topicNum       INT;
DECLARE @now2           DATETIME2 = GETDATE();

DECLARE @topics TABLE (n INT, topic VARCHAR(100));
INSERT INTO @topics VALUES
(0, 'Llegara a tiempo al evento'),
(1, 'Completara el reto propuesto'),
(2, 'Publicara en redes antes del vencimiento'),
(3, 'Alcanzara la meta establecida'),
(4, 'Participara activamente en la actividad'),
(5, 'Superara su record personal'),
(6, 'Finalizara el proyecto en el plazo acordado'),
(7, 'Ganara la competencia local'),
(8, 'Cumplira con el compromiso adquirido'),
(9, 'Lograra el objetivo propuesto');

WHILE @j <= 5000
BEGIN
    -- jugadores van de userId 2 a 1001 (el 1 es Sistema)
    SET @creatorId = 2 + ABS(CHECKSUM(NEWID())) % 1000;
    SET @targetId  = 2 + ABS(CHECKSUM(NEWID())) % 1000;
    IF @targetId = @creatorId SET @targetId = 2 + ((@creatorId - 1) % 1000);

    SET @rand = ABS(CHECKSUM(NEWID())) % 100;
    SET @stateId = CASE
        WHEN @rand <  5 THEN 1   -- 5%  Pendiente
        WHEN @rand < 25 THEN 2   -- 20% Activa
        WHEN @rand < 40 THEN 3   -- 15% Cerrada
        WHEN @rand < 90 THEN 4   -- 50% Resuelta
        WHEN @rand < 97 THEN 5   -- 7%  Cancelada
        ELSE 6                   -- 3%  En disputa
    END;

    SET @resultTypeId   = CASE WHEN @stateId = 4 THEN 1 + ABS(CHECKSUM(NEWID())) % 2 ELSE NULL END;
    SET @propCreatedAt  = DATEADD(DAY, -(1 + ABS(CHECKSUM(NEWID())) % 364), @now2);
    SET @propValidUntil = DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 30, @propCreatedAt);
    SET @topicNum       = ABS(CHECKSUM(NEWID())) % 10;

    INSERT INTO Propositions (
        propositionTopic, createdByUserId, targetUserId, propositionStateId,
        description, resultTypeId, validFrom, validUntil, isActive, createdAt)
    SELECT topic, @creatorId, @targetId, @stateId,
        'Proposicion #' + CAST(@j AS VARCHAR) + ' generada por seeding',
        @resultTypeId, @propCreatedAt, @propValidUntil, 1, @propCreatedAt
    FROM @topics WHERE n = @topicNum;
    SET @propId = SCOPE_IDENTITY();

    INSERT INTO PropositionOptions (propositionId, optionText, isWinningOption, isActive, createdAt)
    VALUES (@propId, 'Si se cumple',
        CASE WHEN @stateId = 4 AND @resultTypeId = 1 THEN 1 ELSE NULL END, 1, @propCreatedAt);
    SET @opt1 = SCOPE_IDENTITY();

    INSERT INTO PropositionOptions (propositionId, optionText, isWinningOption, isActive, createdAt)
    VALUES (@propId, 'No se cumple',
        CASE WHEN @stateId = 4 AND @resultTypeId = 2 THEN 1 ELSE NULL END, 1, @propCreatedAt);
    SET @opt2 = SCOPE_IDENTITY();

    INSERT INTO PropositionStateHistories (propositionId, oldStateId, newStateId, isActive, createdAt)
    VALUES (@propId, NULL, 1, 1, @propCreatedAt);
    IF @stateId >= 2
        INSERT INTO PropositionStateHistories (propositionId, oldStateId, newStateId, isActive, createdAt)
        VALUES (@propId, 1, 2, 1, DATEADD(HOUR, 2, @propCreatedAt));
    IF @stateId >= 3
        INSERT INTO PropositionStateHistories (propositionId, oldStateId, newStateId, isActive, createdAt)
        VALUES (@propId, 2, @stateId, 1, DATEADD(HOUR, 26, @propCreatedAt));

    INSERT INTO #PropOptions VALUES (@propId, @opt1, @opt2, @stateId, @propCreatedAt);

    SET @j = @j + 1;
END;
GO

-- PREDICCIONES (>250000)
-- 55 por cada proposicion que NO este Pendiente (~4750 props -> ~261k predicciones)
-- Fecha posterior a la creacion de la proposicion padre

INSERT INTO Predictions (
    propositionId, userId, predictionStateId, predictedOptionId,
    amount, currencyId, isActive, createdAt)
SELECT
    po.propositionId,
    2 + ABS(CHECKSUM(NEWID())) % 1000,
    CASE po.propStateId
        WHEN 4 THEN CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 2 ELSE 3 END  -- Ganada / Perdida
        WHEN 5 THEN 5                                                            -- Cancelada
        ELSE 1                                                                   -- Activa (a la espera)
    END,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN po.optionId1 ELSE po.optionId2 END,
    CAST(1 + ABS(CHECKSUM(NEWID())) % 100 AS DECIMAL(18,6)) / 100.0,  -- 0.01 a 1.00 punto
    1, 1,
    DATEADD(MINUTE, (nums.n * 13) + (ABS(CHECKSUM(NEWID())) % 600), po.createdAt)
FROM #PropOptions po
CROSS JOIN (
    SELECT TOP 55 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
) nums
WHERE po.propStateId != 1;
GO

-- RETENCION DE APUESTAS EN EL LEDGER
-- Una PaymentAttempt + TransactionsLedger por cada prediccion (movimiento 3 = Apuesta)

INSERT INTO PaymentAttempts (attemptDate, walletId, amount, currencyId,
    movementTypeId, resultTypeId, referenceObjectTypeId, referenceObjectId, sourceObjectTypeId, sourceObjectId)
SELECT p.createdAt, w.walletId, p.amount, 1, 3, 1, 2, CAST(p.predictionId AS VARCHAR), 1, CAST(p.userId AS VARCHAR)
FROM Predictions p
JOIN Wallets w ON w.userId = p.userId AND w.currencyId = 1;
GO

INSERT INTO TransactionsLedger (transactionNumber, transactionDate, walletId,
    attemptId, movementTypeId, currencyId, amount, createdAt)
SELECT 'TXN-BET-' + CAST(pa.attemptId AS VARCHAR), pa.attemptDate, pa.walletId,
    pa.attemptId, 3, 1, pa.amount, pa.attemptDate
FROM PaymentAttempts pa
WHERE pa.movementTypeId = 3;
GO

-- PAGOS DE PROPOSICIONES RESUELTAS
-- Premio a un participante real + comision (5%) a la billetera Sistema (walletId 1)

DECLARE @resolved TABLE (rn INT IDENTITY(1,1), propositionId BIGINT, createdAt DATETIME2);
INSERT INTO @resolved (propositionId, createdAt)
SELECT propositionId, createdAt FROM #PropOptions WHERE propStateId = 4;

DECLARE @k        INT = 1;
DECLARE @maxK     INT = (SELECT COUNT(*) FROM @resolved);
DECLARE @curProp  BIGINT;
DECLARE @propDate DATETIME2;
DECLARE @payDate  DATETIME2;
DECLARE @wId      INT;
DECLARE @aId      BIGINT;
DECLARE @prizeAmt DECIMAL(18,6);
DECLARE @comAmt   DECIMAL(18,6);

WHILE @k <= @maxK
BEGIN
    SELECT @curProp = propositionId, @propDate = createdAt FROM @resolved WHERE rn = @k;
    SET @payDate = DATEADD(HOUR, 26 + ABS(CHECKSUM(NEWID())) % 72, @propDate);

    -- ganador: una billetera de alguien que predijo en esa proposicion
    SELECT TOP 1 @wId = w.walletId
    FROM Predictions p
    JOIN Wallets w ON w.userId = p.userId AND w.currencyId = 1
    WHERE p.propositionId = @curProp
    ORDER BY NEWID();

    SET @prizeAmt = CAST(5 + ABS(CHECKSUM(NEWID())) % 46 AS DECIMAL(18,6));
    SET @comAmt   = CAST(@prizeAmt * 0.05 AS DECIMAL(18,6));

    -- Premio al ganador
    INSERT INTO PaymentAttempts (attemptDate, walletId, amount, currencyId,
        movementTypeId, resultTypeId, referenceObjectTypeId, referenceObjectId, sourceObjectTypeId, sourceObjectId)
    VALUES (@payDate, @wId, @prizeAmt, 1, 4, 1, 1, CAST(@curProp AS VARCHAR), 2, 'SYSTEM');
    SET @aId = SCOPE_IDENTITY();

    INSERT INTO TransactionsLedger (transactionNumber, transactionDate, walletId,
        attemptId, movementTypeId, currencyId, amount, createdAt)
    VALUES ('TXN-PRIZE-' + CAST(@aId AS VARCHAR), @payDate, @wId, @aId, 4, 1, @prizeAmt, @payDate);

    -- Comision (5%) a la billetera Sistema (walletId 1)
    INSERT INTO PaymentAttempts (attemptDate, walletId, amount, currencyId,
        movementTypeId, resultTypeId, referenceObjectTypeId, referenceObjectId, sourceObjectTypeId, sourceObjectId)
    VALUES (@payDate, 1, @comAmt, 1, 5, 1, 1, CAST(@curProp AS VARCHAR), 2, 'SYSTEM');
    SET @aId = SCOPE_IDENTITY();

    INSERT INTO TransactionsLedger (transactionNumber, transactionDate, walletId,
        attemptId, movementTypeId, currencyId, amount, createdAt)
    VALUES ('TXN-COM-' + CAST(@aId AS VARCHAR), @payDate, 1, @aId, 5, 1, @comAmt, @payDate);

    SET @k = @k + 1;
END;
GO

-- SINCRONIZACION FISICA DE BALANCES
-- currentBalance = suma del ledger por billetera. El signo se calcula con CASE
-- (no existe columna affectsSign en MovementTypes, no se altera el esquema).

UPDATE b
SET b.currentBalance = s.bal,
    b.updatedAt      = GETDATE()
FROM Balances b
JOIN (
    SELECT t.walletId,
           SUM(t.amount * CASE
               WHEN mt.movementTypeName IN ('Retiro', 'Apuesta', 'Penalizacion') THEN -1
               ELSE 1
           END) AS bal
    FROM TransactionsLedger t
    JOIN MovementTypes mt ON mt.movementTypeId = t.movementTypeId
    GROUP BY t.walletId
) s ON s.walletId = b.walletId;
GO

DROP TABLE #PropOptions;
GO
