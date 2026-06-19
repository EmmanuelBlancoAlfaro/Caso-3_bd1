/* ================================================================
 Script : 03_Deadlocks.sql
 Descripción  : Demuestra tres escenarios de deadlock en SQL Server y como el motor los resuelve.

   ESCENARIO 1: Deadlock clásico entre dos transacciones
     T1 bloquea fila A y necesita fila B.
     T2 bloquea fila B y necesita fila A.
     Ciclo de espera -> SQL Server elige víctima -> error 1205.

   ESCENARIO 2: Deadlock entre tres transacciones
     T1 -> necesita T2 -> necesita T3 -> necesita T1.
     Ciclo de tres nodos, SQL Server sigue detectándolo.

   ESCENARIO 3: Deadlock causado por REPEATABLE READ.
     REPEATABLE READ retiene S-locks sobre las filas leídas hasta que la transacción termina.
     Cuando dos transacciones leen filas cruzadas y luego intentan actualizarlas, los S-locks (bloqueos compartidos) de cada una bloquean el X-lock (bloqueos exclusivos) que la otra necesita para escribir.
     El deadlock lo provoca el nivel de aislamiento, no un UPDATE directo.
 ================================================================ */

-- Crear tabla de demo (ejecutar una sola vez)
CREATE TABLE dbo.Billeteras (
    BilleteraID INT          PRIMARY KEY,
    Propietario VARCHAR(50)  NOT NULL,
    Saldo       DECIMAL(10,2) NOT NULL
);

INSERT INTO dbo.Billeteras VALUES
(1, 'Mariana', 1000.00),
(2, 'Esteban', 1000.00),
(3, 'Luciana',  500.00);
GO


/* ================================================================
 ESCENARIO 1: DEADLOCK CLÁSICO (2 transacciones)
 Ejecutar cada SP en una ventana de SSMS distinta.
 SQL Server detecta el ciclo en segundos, mata a la víctima con error 1205 y la otra transacción avanza.

 VENTANA A: EXEC dbo.sp_Deadlock_T1
 VENTANA B: EXEC dbo.sp_Deadlock_T2
 ================================================================ */

-- T1: bloquea Mariana, luego necesita a Esteban
CREATE OR ALTER PROCEDURE dbo.sp_Deadlock_T1
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Billeteras SET Saldo = Saldo - 100 
		WHERE BilleteraID = 1;
        -- Tiene bloqueo exclusivo sobre fila 1 (Mariana)
        PRINT 'T1: bloqueo sobre Mariana. Esperando...';
        WAITFOR DELAY '00:00:07';
        -- Necesita bloqueo sobre fila 2 (Esteban), que T2 ya tiene
        UPDATE dbo.Billeteras SET Saldo = Saldo + 100 
		WHERE BilleteraID = 2;
    COMMIT TRANSACTION;
    PRINT 'T1: COMMIT exitoso';
END;
GO

-- T2: bloquea Esteban, luego necesita a Mariana
CREATE OR ALTER PROCEDURE dbo.sp_Deadlock_T2
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Billeteras SET Saldo = Saldo - 50 
		WHERE BilleteraID = 2;
        -- Tiene bloqueo exclusivo sobre fila 2 (Esteban)
        PRINT 'T2: bloqueo sobre Esteban. Esperando...';
        WAITFOR DELAY '00:00:07';
        -- Necesita bloqueo sobre fila 1 (Mariana), que T1 ya tiene
        UPDATE dbo.Billeteras SET Saldo = Saldo + 50 
		WHERE BilleteraID = 1;
    COMMIT TRANSACTION;
    PRINT 'T2: COMMIT exitoso';
END;
GO

-- VENTANA A
EXEC dbo.sp_Deadlock_T1;

-- VENTANA B (ejecutar pocos segundos después)
EXEC dbo.sp_Deadlock_T2;

/* Despues de que el motor resuelva el deadlock:
 Una de las dos recibirá error 1205.
 La otra continuará y hará COMMIT. */
SELECT BilleteraID, Propietario, Saldo FROM dbo.Billeteras;
GO


/* ================================================================
 ESCENARIO 2: DEADLOCK DE TRES TRANSACCIONES
 T1 necesita lo que tiene T2.
 T2 necesita lo que tiene T3.
 T3 necesita lo que tiene T1.
 Ciclo de 3 nodos. SQL Server lo detecta igual y elige una víctima.

 VENTANA A: EXEC dbo.sp_Deadlock_T3a
 VENTANA B: EXEC dbo.sp_Deadlock_T3b
 VENTANA C: EXEC dbo.sp_Deadlock_T3c
 ================================================================ */

-- Resetear saldos
UPDATE dbo.Billeteras SET Saldo = 1000.00 
WHERE BilleteraID IN (1,2);
UPDATE dbo.Billeteras SET Saldo = 500.00  
WHERE BilleteraID = 3;

CREATE OR ALTER PROCEDURE dbo.sp_Deadlock_T3a
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Billeteras SET Saldo = Saldo - 10 
		WHERE BilleteraID = 1;
        -- Bloquea fila 1
        PRINT 'T3a: bloqueo sobre fila 1. Esperando...';
        WAITFOR DELAY '00:00:06';
        UPDATE dbo.Billeteras SET Saldo = Saldo - 10 
		WHERE BilleteraID = 2;
        -- Necesita fila 2 (que tiene T3b)
    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Deadlock_T3b
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Billeteras SET Saldo = Saldo - 10 
		WHERE BilleteraID = 2;
        -- Bloquea fila 2
        PRINT 'T3b: bloqueo sobre fila 2. Esperando...';
        WAITFOR DELAY '00:00:06';
        UPDATE dbo.Billeteras SET Saldo = Saldo - 10 
		WHERE BilleteraID = 3;
        -- Necesita fila 3 (que tiene T3c)
    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Deadlock_T3c
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Billeteras SET Saldo = Saldo - 10 
		WHERE BilleteraID = 3;
        -- Bloquea fila 3
        PRINT 'T3c: bloqueo sobre fila 3. Esperando...';
        WAITFOR DELAY '00:00:06';
        UPDATE dbo.Billeteras SET Saldo = Saldo - 10 
		WHERE BilleteraID = 1;
        -- Necesita fila 1 (que tiene T3a)
    COMMIT TRANSACTION;
END;
GO

-- VENTANA A
EXEC dbo.sp_Deadlock_T3a;

-- VENTANA B (ejecutar pocos segundos después)
EXEC dbo.sp_Deadlock_T3b;

-- VENTANA C (ejecutar pocos segundos después)
EXEC dbo.sp_Deadlock_T3c;
GO


/* ================================================================
 ESCENARIO 3: DEADLOCK CAUSADO POR REPEATABLE READ.

 Por qué ocurre:
   REPEATABLE READ retiene los S-locks sobre las filas que lee hasta que la transacción termina, no solo mientras lee. Esto garantiza que si las vuelve a leer, obtenga los mismos valores.

   El problema: un S-lock impide que otros obtengan un X-lock sobre esa fila. Si T1 lee la fila de Mariana y T2 lee la fila de Esteban, y luego cada una intenta actualizar la fila que la otra ya tiene bloqueada, ninguna puede avanzar.

   La diferencia con el Escenario 1:
     - En el Escenario 1, el deadlock lo causan los UPDATE directos.
     - Aqui, el deadlock lo causa el propio nivel de aislamiento:
       los SELECT retienen los S-locks, y esos S-locks bloquean los UPDATE de la otra transacción.

 VENTANA A: EXEC dbo.sp_Deadlock_RR_T1
 VENTANA B: EXEC dbo.sp_Deadlock_RR_T2
 ================================================================ */

-- Resetear saldos
UPDATE dbo.Billeteras SET Saldo = 1000.00 
WHERE BilleteraID IN (1,2);

CREATE OR ALTER PROCEDURE dbo.sp_Deadlock_RR_T1
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    BEGIN TRANSACTION;
        -- Lee la fila de Mariana. REPEATABLE READ retiene el S-lock.
        DECLARE @saldoMariana DECIMAL(10,2);
        SELECT @saldoMariana = Saldo FROM dbo.Billeteras 
		WHERE BilleteraID = 1;
        PRINT 'RR_T1: leyo Mariana (' + CAST(@saldoMariana AS VARCHAR) + '). S-lock retenido.';

        WAITFOR DELAY '00:00:07';

        -- Intenta actualizar Esteban, que T2 ya leyó con S-lock retenido.
        -- El X-lock que necesita este UPDATE es incompatible con el S-lock de T2.
        PRINT 'RR_T1: intentando actualizar Esteban...';
        UPDATE dbo.Billeteras SET Saldo = @saldoMariana + Saldo 
		WHERE BilleteraID = 2;
    COMMIT TRANSACTION;
    PRINT 'RR_T1: COMMIT exitoso';
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Deadlock_RR_T2
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    BEGIN TRANSACTION;
        -- Lee la fila de Esteban. REPEATABLE READ retiene el S-lock.
        DECLARE @saldoEsteban DECIMAL(10,2);
        SELECT @saldoEsteban = Saldo FROM dbo.Billeteras 
		WHERE BilleteraID = 2;
        PRINT 'RR_T2: leyo Esteban (' + CAST(@saldoEsteban AS VARCHAR) + '). S-lock retenido.';

        WAITFOR DELAY '00:00:07';

        -- Intenta actualizar Mariana, que T1 ya leyó con S-lock retenido.
        -- El X-lock que necesita este UPDATE es incompatible con el S-lock de T1.
        PRINT 'RR_T2: intentando actualizar Mariana...';
        UPDATE dbo.Billeteras SET Saldo = @saldoEsteban + Saldo 
		WHERE BilleteraID = 1;
    COMMIT TRANSACTION;
    PRINT 'RR_T2: COMMIT exitoso';
END;
GO

-- VENTANA A
EXEC dbo.sp_Deadlock_RR_T1;

-- VENTANA B (ejecutar pocos segundos después, antes de que A llegue al UPDATE)
EXEC dbo.sp_Deadlock_RR_T2;

/* Resultado: SQL Server detecta el deadlock y mata a una de las dos.
 El mensaje de la víctima será error 1205.
 La clave para explicar: el deadlock no lo causaron los UPDATE directamente, sino los S-locks que REPEATABLE READ retuvo desde el SELECT inicial. */
SELECT BilleteraID, Propietario, Saldo FROM dbo.Billeteras;
GO


/* ================================================================
 HABILITAR REGISTRO DE DEADLOCKS 
 Captura el XML del deadlock en el buffer de SQL Server.
 Consultar con la query de abajo después de reproducir un deadlock.
 ================================================================ */

-- Activar trace flags para registrar deadlocks en el error log
DBCC TRACEON(1222, -1);  -- Formato XML detallado
GO

-- Leer el deadlock graph desde el System Health (sin instalar nada)
SELECT
    xdr.value('@timestamp', 'datetime2')      AS FechaDeadlock,
    xdr.query('.')                             AS DeadlockGraph
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_session_targets  t
    JOIN sys.dm_xe_sessions         s ON s.address = t.event_session_address
    WHERE s.name = 'system_health' AND t.target_name = 'ring_buffer'
) AS data
CROSS APPLY target_data.nodes('//RingBufferTarget/event[@name="xml_deadlock_report"]') AS n(xdr)
ORDER BY FechaDeadlock DESC;
GO


/* ================================================================
 LIMPIEZA (ejecutar al finalizar las demos)
 ================================================================
 DBCC TRACEOFF(1222, -1);
 DROP PROCEDURE IF EXISTS dbo.sp_Deadlock_T1;
 DROP PROCEDURE IF EXISTS dbo.sp_Deadlock_T2;
 DROP PROCEDURE IF EXISTS dbo.sp_Deadlock_T3a;
 DROP PROCEDURE IF EXISTS dbo.sp_Deadlock_T3b;
 DROP PROCEDURE IF EXISTS dbo.sp_Deadlock_T3c;
 DROP PROCEDURE IF EXISTS dbo.sp_Deadlock_RR_T1;
 DROP PROCEDURE IF EXISTS dbo.sp_Deadlock_RR_T2;
 DROP TABLE IF EXISTS dbo.Billeteras; */
