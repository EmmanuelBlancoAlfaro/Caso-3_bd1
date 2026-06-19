/* ================================================================
 Script : 01_SP_Anidados.sql
 Base de datos : GathelDB
 Descripción  : Demuestra el comportamiento de transacciones anidadas en SQL Server usando el flujo real de apuestas de Gathel (Predictions -> PaymentAttempts -> TransactionsLedger).

   CASO 1 - Sin control de @@TRANCOUNT:
     Cada SP abre su propio BEGIN TRANSACTION sin verificar si ya hay una transacción activa. Cuando el SP interno hace ROLLBACK por error, @@TRANCOUNT cae a 0 y el SP del medio falla con error 3902 al intentar COMMIT.

   CASO 2 - Con control de @@TRANCOUNT (patron correcto):
     Cada SP verifica @@TRANCOUNT antes de abrir una transaccion.
     Solo el SP mas externo inicia y cierra la transacción.
     Los errores internos se propagan con THROW y el SP externo decide si hace COMMIT o ROLLBACK sobre la totalidad.
 ================================================================ */

USE GathelDB;
GO

/* ================================================================
 CONSULTA DE APOYO
 Ejecutar primero para obtener IDs válidos para las demos.
 Anota una fila: propositionId, predictedOptionId, userId, walletId
 ================================================================ */

SELECT TOP 3
    p.propositionId,
    po.optionId     AS predictedOptionId,
    w.userId,
    w.walletId,
    b.currentBalance
FROM Propositions p
JOIN PropositionStates   ps ON ps.propositionStateId = p.propositionStateId
JOIN PropositionOptions  po ON po.propositionId      = p.propositionId
JOIN Wallets              w ON w.currencyId = 1 AND w.userId != 1
JOIN Balances             b ON b.walletId   = w.walletId
WHERE ps.allowsPredictions = 1 AND b.currentBalance >= 5
ORDER BY NEWID();
GO


/* ================================================================
 CASO 1: SIN CONTROL DE @@TRANCOUNT  (PELIGROSO)
 ================================================================ */

-- SP interno: inserta el movimiento en TransactionsLedger
CREATE OR ALTER PROCEDURE dbo.sp_InsertarLedger_Peligroso
    @walletId    INT,
    @attemptId   BIGINT,
    @amount      DECIMAL(18,6),
    @forzarError BIT = 0
AS
BEGIN
    PRINT 'SP_Ledger  | @@TRANCOUNT al entrar: ' + CAST(@@TRANCOUNT AS VARCHAR);

    BEGIN TRANSACTION;  -- @@TRANCOUNT sube a 2 si ya había una abierta

    INSERT INTO TransactionsLedger (
        transactionNumber, transactionDate, walletId, attemptId, movementTypeId, currencyId, amount, createdAt)
    VALUES (
        'TXN-DEMO-' + LEFT(CAST(NEWID() AS VARCHAR(40)), 8), GETDATE(), @walletId, @attemptId, 3, 1, @amount, GETDATE());

    IF @forzarError = 1
    BEGIN
        PRINT 'SP_Ledger  | Error forzado. Haciendo ROLLBACK...';
        ROLLBACK TRANSACTION;  -- REVIERTE TODO hasta el BEGIN mas externo.
                               -- @@TRANCOUNT queda en 0.
        PRINT 'SP_Ledger  | @@TRANCOUNT despues del ROLLBACK: ' + CAST(@@TRANCOUNT AS VARCHAR);
        RETURN;                -- Regresa sin lanzar excepción
    END

    COMMIT TRANSACTION;
    PRINT 'SP_Ledger  | COMMIT ejecutado';
END;
GO

-- SP medio: crea el intento de pago y llama al SP interno
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarPago_Peligroso
    @walletId      INT,
    @propositionId BIGINT,
    @amount        DECIMAL(18,6),
    @forzarError   BIT = 0
AS
BEGIN
    PRINT 'SP_Pago    | @@TRANCOUNT al entrar: ' + CAST(@@TRANCOUNT AS VARCHAR);

    BEGIN TRANSACTION;

    INSERT INTO PaymentAttempts (
        attemptDate, walletId, amount, currencyId, movementTypeId, resultTypeId, referenceObjectTypeId, referenceObjectId, sourceObjectTypeId, sourceObjectId)
    VALUES (
        GETDATE(), @walletId, @amount, 1, 3, 1, 1, CAST(@propositionId AS VARCHAR(50)), 1, CAST(@walletId AS VARCHAR(50)));

    DECLARE @attemptId BIGINT = SCOPE_IDENTITY();

    EXEC dbo.sp_InsertarLedger_Peligroso
        @walletId    = @walletId,
        @attemptId   = @attemptId,
        @amount      = @amount,
        @forzarError = @forzarError;

    /* Si SP_Ledger hizo ROLLBACK, @@TRANCOUNT es 0 aquí.
     El COMMIT siguiente lanza error 3902:
		"The COMMIT TRANSACTION request has no corresponding BEGIN TRANSACTION" */
    PRINT 'SP_Pago    | @@TRANCOUNT antes del COMMIT: ' + CAST(@@TRANCOUNT AS VARCHAR);
    COMMIT TRANSACTION;
    PRINT 'SP_Pago    | COMMIT ejecutado';
END;
GO

-- SP externo: punto de entrada, valida la proposición e inicia la cadena
CREATE OR ALTER PROCEDURE dbo.sp_HacerApuesta_Peligroso
    @userId            INT,
    @propositionId     BIGINT,
    @predictedOptionId BIGINT,
    @amount            DECIMAL(18,6),
    @forzarError       BIT = 0
AS
BEGIN
    PRINT 'SP_Apuesta | @@TRANCOUNT al entrar: ' + CAST(@@TRANCOUNT AS VARCHAR);

    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM Propositions p
        JOIN PropositionStates ps ON ps.propositionStateId = p.propositionStateId
        WHERE p.propositionId = @propositionId AND ps.allowsPredictions = 1
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50000, 'La proposicion no acepta predicciones en este estado', 1;
    END

    INSERT INTO Predictions (
        propositionId, userId, predictionStateId, predictedOptionId, amount, currencyId, isActive, createdAt)
    VALUES (
        @propositionId, @userId, 1, @predictedOptionId, @amount, 1, 1, GETDATE());

    DECLARE @walletId INT;
    SELECT @walletId = walletId
    FROM Wallets
    WHERE userId = @userId AND currencyId = 1;

    EXEC dbo.sp_RegistrarPago_Peligroso
        @walletId      = @walletId,
        @propositionId = @propositionId,
        @amount        = @amount,
        @forzarError   = @forzarError;

    PRINT 'SP_Apuesta | @@TRANCOUNT antes del COMMIT: ' + CAST(@@TRANCOUNT AS VARCHAR);
    COMMIT TRANSACTION;
    PRINT 'SP_Apuesta | Apuesta registrada exitosamente';
END;
GO

 /* ---------------------------------------------------------------
 DEMO 1A: Ejecución exitosa (usar IDs del query de apoyo)
 --------------------------------------------------------------- */
DECLARE @propId BIGINT = (
    SELECT TOP 1 p.propositionId
    FROM Propositions p
    JOIN PropositionStates ps ON ps.propositionStateId = p.propositionStateId
    WHERE ps.allowsPredictions = 1 
	ORDER BY NEWID());

DECLARE @optId BIGINT = (
    SELECT TOP 1 optionId FROM PropositionOptions
    WHERE propositionId = @propId 
	ORDER BY NEWID());

DECLARE @uid INT = (
    SELECT TOP 1 userId FROM Wallets
    WHERE currencyId = 1 AND userId != 1 
	ORDER BY NEWID());

DECLARE @antesOK INT = (SELECT COUNT(*) FROM Predictions);

EXEC dbo.sp_HacerApuesta_Peligroso
    @userId            = @uid,
    @propositionId     = @propId,
    @predictedOptionId = @optId,
    @amount            = 1.000000,
    @forzarError       = 0;

SELECT @antesOK AS PrediccionesAntes, COUNT(*) AS PrediccionesDespues
FROM Predictions;
GO

/* ---------------------------------------------------------------
 DEMO 1B: Ejecucion con error forzado
 SP_Ledger hace ROLLBACK -> @@TRANCOUNT = 0
 SP_Pago intenta COMMIT -> error 3902
 Todos los datos quedan revertidos, pero los errores cascadean de forma descontrolada
 --------------------------------------------------------------- */
DECLARE @propId2 BIGINT = (
    SELECT TOP 1 p.propositionId
    FROM Propositions p
    JOIN PropositionStates ps ON ps.propositionStateId = p.propositionStateId
    WHERE ps.allowsPredictions = 1 
	ORDER BY NEWID());

DECLARE @optId2 BIGINT = (
    SELECT TOP 1 optionId FROM PropositionOptions
    WHERE propositionId = @propId2 
	ORDER BY NEWID());

DECLARE @uid2 INT = (
    SELECT TOP 1 userId FROM Wallets
    WHERE currencyId = 1 AND userId != 1 
	ORDER BY NEWID());

DECLARE @antesError INT = (SELECT COUNT(*) FROM Predictions);

EXEC dbo.sp_HacerApuesta_Peligroso
    @userId            = @uid2,
    @propositionId     = @propId2,
    @predictedOptionId = @optId2,
    @amount            = 1.000000,
    @forzarError       = 1;  -- SP_Ledger hace ROLLBACK; SP_Pago falla con 3902

SELECT @antesError AS PrediccionesAntes, COUNT(*) AS PrediccionesDespues,
       '@@TRANCOUNT cayo a 0 dentro de un SP anidado' AS Problema
FROM Predictions;
GO


/* ================================================================
 CASO 2: CON CONTROL DE @@TRANCOUNT  (PATRÓN CORRECTO)
 ================================================================
 Cada SP declara @esTransaccionPropia BIT.
 Solo abre BEGIN TRANSACTION si @@TRANCOUNT = 0.
 Solo hace COMMIT si fue el que abrió la transacción.
 El CATCH hace ROLLBACK solo si fue el que abrió la transacción, y siempre propaga el error con THROW para que el SP externo tambien lo maneje.
 ================================================================ */

-- SP interno: inserta en TransactionsLedger
CREATE OR ALTER PROCEDURE dbo.sp_InsertarLedger
    @walletId    INT,
    @attemptId   BIGINT,
    @amount      DECIMAL(18,6),
    @forzarError BIT = 0
AS
BEGIN
    DECLARE @esTransaccionPropia BIT = 0;
    PRINT 'SP_Ledger  | @@TRANCOUNT al entrar: ' + CAST(@@TRANCOUNT AS VARCHAR);

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @esTransaccionPropia = 1;
            PRINT 'SP_Ledger  | Transaccion propia abierta';
        END
        ELSE
            PRINT 'SP_Ledger  | Usando transaccion del SP externo';

        INSERT INTO TransactionsLedger (
            transactionNumber, transactionDate, walletId, attemptId, movementTypeId, currencyId, amount, createdAt)
        VALUES (
            'TXN-DEMO-' + LEFT(CAST(NEWID() AS VARCHAR(40)), 8), GETDATE(), @walletId, @attemptId, 3, 1, @amount, GETDATE());

        IF @forzarError = 1
            THROW 50001, 'Error forzado en SP_InsertarLedger', 1;

        IF @esTransaccionPropia = 1
        BEGIN
            COMMIT TRANSACTION;
            PRINT 'SP_Ledger  | COMMIT propio ejecutado';
        END
    END TRY
    BEGIN CATCH
        IF @esTransaccionPropia = 1 AND XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'SP_Ledger  | ROLLBACK propio ejecutado';
        END
        THROW;  -- Propaga el error al SP que lo llamó
    END CATCH
END;
GO

-- SP medio: crea el PaymentAttempt y llama al SP interno
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarPago
    @walletId      INT,
    @propositionId BIGINT,
    @amount        DECIMAL(18,6),
    @forzarError   BIT = 0
AS
BEGIN
    DECLARE @esTransaccionPropia BIT = 0;
    PRINT 'SP_Pago    | @@TRANCOUNT al entrar: ' + CAST(@@TRANCOUNT AS VARCHAR);

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @esTransaccionPropia = 1;
            PRINT 'SP_Pago    | Transaccion propia abierta';
        END
        ELSE
            PRINT 'SP_Pago    | Usando transaccion del SP externo';

        INSERT INTO PaymentAttempts (
            attemptDate, walletId, amount, currencyId, movementTypeId, resultTypeId, referenceObjectTypeId, referenceObjectId, sourceObjectTypeId, sourceObjectId)
        VALUES (
            GETDATE(), @walletId, @amount, 1, 3, 1, 1, CAST(@propositionId AS VARCHAR(50)), 1, CAST(@walletId AS VARCHAR(50)));

        DECLARE @attemptId BIGINT = SCOPE_IDENTITY();

        EXEC dbo.sp_InsertarLedger
            @walletId    = @walletId,
            @attemptId   = @attemptId,
            @amount      = @amount,
            @forzarError = @forzarError;

        IF @esTransaccionPropia = 1
        BEGIN
            COMMIT TRANSACTION;
            PRINT 'SP_Pago    | COMMIT propio ejecutado';
        END
    END TRY
    BEGIN CATCH
        IF @esTransaccionPropia = 1 AND XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'SP_Pago    | ROLLBACK propio ejecutado';
        END
        THROW;
    END CATCH
END;
GO

-- SP externo: punto de entrada, único dueño de la transacción
CREATE OR ALTER PROCEDURE dbo.sp_HacerApuesta
    @userId            INT,
    @propositionId     BIGINT,
    @predictedOptionId BIGINT,
    @amount            DECIMAL(18,6),
    @forzarError       BIT = 0
AS
BEGIN
    DECLARE @esTransaccionPropia BIT = 0;
    PRINT 'SP_Apuesta | @@TRANCOUNT al entrar: ' + CAST(@@TRANCOUNT AS VARCHAR);

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @esTransaccionPropia = 1;
            PRINT 'SP_Apuesta | Transaccion propia abierta';
        END

        IF NOT EXISTS (
            SELECT 1 FROM Propositions p
            JOIN PropositionStates ps ON ps.propositionStateId = p.propositionStateId
            WHERE p.propositionId = @propositionId AND ps.allowsPredictions = 1
        )
            THROW 50000, 'La proposicion no acepta predicciones en este estado', 1;

        INSERT INTO Predictions (
            propositionId, userId, predictionStateId, predictedOptionId, amount, currencyId, isActive, createdAt)
        VALUES (
            @propositionId, @userId, 1, @predictedOptionId, @amount, 1, 1, GETDATE());

        DECLARE @walletId INT;
        SELECT @walletId = walletId
        FROM Wallets
        WHERE userId = @userId AND currencyId = 1;

        EXEC dbo.sp_RegistrarPago
            @walletId      = @walletId,
            @propositionId = @propositionId,
            @amount        = @amount,
            @forzarError   = @forzarError;

        IF @esTransaccionPropia = 1
        BEGIN
            COMMIT TRANSACTION;
            PRINT 'SP_Apuesta | COMMIT total ejecutado. Las 3 tablas quedaron escritas.';
        END
    END TRY
    BEGIN CATCH
        IF @esTransaccionPropia = 1 AND XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'SP_Apuesta | ROLLBACK total ejecutado. Ninguna tabla fue modificada.';
        END
        PRINT 'SP_Apuesta | Error capturado: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

/* ---------------------------------------------------------------
 DEMO 2A: Ejecución exitosa
 @@TRANCOUNT sube a 1 en SP_Apuesta, se mantiene en 1 en SP_Pago y SP_Ledger (no abren transaccion propia).
 COMMIT ocurre una sola vez, en SP_Apuesta.
 --------------------------------------------------------------- */
DECLARE @propId3 BIGINT = (
    SELECT TOP 1 p.propositionId
    FROM Propositions p
    JOIN PropositionStates ps ON ps.propositionStateId = p.propositionStateId
    WHERE ps.allowsPredictions = 1 
	ORDER BY NEWID());

DECLARE @optId3 BIGINT = (
    SELECT TOP 1 optionId FROM PropositionOptions
    WHERE propositionId = @propId3 
	ORDER BY NEWID());

DECLARE @uid3 INT = (
    SELECT TOP 1 userId FROM Wallets
    WHERE currencyId = 1 AND userId != 1 
	ORDER BY NEWID());

DECLARE @antesOK2 INT = (SELECT COUNT(*) FROM Predictions);

EXEC dbo.sp_HacerApuesta
    @userId            = @uid3,
    @propositionId     = @propId3,
    @predictedOptionId = @optId3,
    @amount            = 1.000000,
    @forzarError       = 0;

SELECT @antesOK2 AS PrediccionesAntes, COUNT(*) AS PrediccionesDespues,
       'Debe haber exactamente 1 nueva prediccion' AS Esperado
FROM Predictions;
GO

/* ---------------------------------------------------------------
 DEMO 2B: Ejecución con error forzado
 SP_Ledger lanza THROW. Su CATCH propaga el error a SP_Pago.
 SP_Pago no abrió transacción propia, propaga a SP_Apuesta.
 SP_Apuesta captura el error, hace ROLLBACK total.
 Predictions, PaymentAttempts y TransactionsLedger: sin cambios.
 --------------------------------------------------------------- */
DECLARE @antesError2 INT = (SELECT COUNT(*) FROM Predictions);

DECLARE @propId4 BIGINT = (
    SELECT TOP 1 p.propositionId
    FROM Propositions p
    JOIN PropositionStates ps ON ps.propositionStateId = p.propositionStateId
    WHERE ps.allowsPredictions = 1 
	ORDER BY NEWID());

DECLARE @optId4 BIGINT = (
    SELECT TOP 1 optionId FROM PropositionOptions
    WHERE propositionId = @propId4 
	ORDER BY NEWID());

DECLARE @uid4 INT = (
    SELECT TOP 1 userId FROM Wallets
    WHERE currencyId = 1 AND userId != 1 
	ORDER BY NEWID());

EXEC dbo.sp_HacerApuesta
    @userId            = @uid4,
    @propositionId     = @propId4,
    @predictedOptionId = @optId4,
    @amount            = 1.000000,
    @forzarError       = 1;

SELECT @antesError2 AS PrediccionesAntes, COUNT(*) AS PrediccionesDespues,
       CASE WHEN @antesError2 = COUNT(*) THEN 'OK: Atomicidad garantizada'
            ELSE 'ERROR: Datos parciales persistieron' END AS Resultado
FROM Predictions;
GO


/* ================================================================
 LIMPIEZA (ejecutar al finalizar las demos)
 ================================================================
 DROP PROCEDURE IF EXISTS dbo.sp_InsertarLedger_Peligroso;
 DROP PROCEDURE IF EXISTS dbo.sp_RegistrarPago_Peligroso;
 DROP PROCEDURE IF EXISTS dbo.sp_HacerApuesta_Peligroso;
 DROP PROCEDURE IF EXISTS dbo.sp_InsertarLedger;
 DROP PROCEDURE IF EXISTS dbo.sp_RegistrarPago;
 DROP PROCEDURE IF EXISTS dbo.sp_HacerApuesta; */
