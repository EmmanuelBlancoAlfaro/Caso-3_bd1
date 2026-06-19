/* ================================================================
 Script : 02_Aislamiento.sql
 Descripción  : Demuestra los cuatro fenómenos de concurrencia y como cada nivel de aislamiento los previene o permite.

   Cada sección necesita DOS ventanas de SSMS abiertas.
   Se indica claramente que ejecutar en cada ventana y en qué orden.

   FENÓMENOS DEMOSTRADOS:
     1. Dirty Read        -> nivel READ UNCOMMITTED
     2. Non-Repeatable Read -> nivel READ COMMITTED 
     3. Phantom Read      -> nivel REPEATABLE READ
     4. Lost Update       -> nivel READ COMMITTED
     5. Prevencion total  -> nivel SERIALIZABLE
 ================================================================ */

-- Crear tabla de demo (ejecutar una sola vez)
CREATE TABLE dbo.Apuestas (
    ApuestaID  INT          PRIMARY KEY,
    Jugador    VARCHAR(50)  NOT NULL,
    Monto      DECIMAL(10,2) NOT NULL,
    Estado     VARCHAR(20)  NOT NULL DEFAULT 'Activa'
);

INSERT INTO dbo.Apuestas VALUES
(1, 'Camila',  500.00, 'Activa'),
(2, 'Roberto', 800.00, 'Activa'),
(3, 'Daniela', 300.00, 'Activa');
GO


/* ================================================================
 1. DIRTY READ
 Nivel: READ UNCOMMITTED
 Fenómeno: se leen datos que aún no han sido confirmados (commit).
   Si la transacción original hace rollback, la lectura fue de datos que nunca existieron formalmente.

 VENTANA A (ejecutar primero):
   Modifica el monto pero NO hace commit durante 12 segundos
 VENTANA B (ejecutar mientras A espera):
   Lee con READ UNCOMMITTED y ve el dato no confirmado
 ================================================================ */

-- VENTANA A
BEGIN TRANSACTION;
    UPDATE dbo.Apuestas SET Monto = 99999.00 
	WHERE ApuestaID = 1;
    WAITFOR DELAY '00:00:12';
ROLLBACK TRANSACTION;  -- El dato modificado nunca existió

-- VENTANA B (ejecutar mientras A esta en el WAITFOR)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT ApuestaID, Jugador, Monto, '<<< Dato no confirmado (sucio)' AS Nota
FROM dbo.Apuestas
WHERE ApuestaID = 1;
-- Muestra 99999.00 aunque A hará rollback después
GO


/* ================================================================
 2. NON-REPEATABLE READ
 Nivel: READ COMMITTED (nivel por defecto de SQL Server)
 Fenómeno: dentro de una misma transacción, la misma fila se lee dos veces y devuelve valores distintos porque otra transacción la modificó entre las dos lecturas.

 VENTANA A: lee, espera, lee de nuevo
 VENTANA B: modifica entre las dos lecturas de A
 ================================================================ */

-- Resetear dato
UPDATE dbo.Apuestas SET Monto = 500.00 
WHERE ApuestaID = 1;

-- VENTANA A
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    SELECT Monto AS LecturaPrimera FROM dbo.Apuestas 
	WHERE ApuestaID = 1;
    WAITFOR DELAY '00:00:10';
    SELECT Monto AS LecturaSegunda FROM dbo.Apuestas 
	WHERE ApuestaID = 1;
COMMIT TRANSACTION;

-- VENTANA B (ejecutar mientras A esta en el WAITFOR)
UPDATE dbo.Apuestas SET Monto = 150.00 
WHERE ApuestaID = 1;
-- No necesita transaccion explicita, el default hace auto-commit
GO


/* ================================================================
 3. PHANTOM READ
 Nivel: REPEATABLE READ
 Fenómeno: una transacción lee un rango de filas por condición, otra transacción inserta una fila que cumple esa misma condición, y la primera transacción ve filas nuevas ("fantasmas") al releer.
 REPEATABLE READ protege las filas existentes pero no el rango.

 VENTANA A: lee filas con Monto < 600, espera, lee de nuevo
 VENTANA B: inserta una fila nueva que cumple la condición
 ================================================================ */

-- VENTANA A
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
    SELECT ApuestaID, Jugador, Monto AS LecturaPrimera
    FROM dbo.Apuestas 
	WHERE Monto < 600;
    -- Resultado: Camila (500) y Daniela (300)
    WAITFOR DELAY '00:00:10';
    SELECT ApuestaID, Jugador, Monto AS LecturaSegunda
    FROM dbo.Apuestas 
	WHERE Monto < 600;
    -- Resultado: aparece 'Gonzalo' que no estaba antes  -> Phantom
COMMIT TRANSACTION;

-- VENTANA B (ejecutar mientras A esta en el WAITFOR)
INSERT INTO dbo.Apuestas VALUES (4, 'Gonzalo', 250.00, 'Activa');
GO


/* ================================================================
 4. LOST UPDATE 
 Nivel: READ COMMITTED
 Fenómeno: dos transacciones leen el mismo valor, calculan una actualización basada en ese valor inicial, y la primera en escribir es sobreescrita por la segunda.
 La actualización de la primera transaccion se pierde.

 VENTANA A: lee 500, espera, suma 200 y escribe 700
 VENTANA B: mientras A espera, le resta 100 y escribe 400
 El resultado final deberia ser 600 (500+200-100) pero queda en 700 porque A sobrescribe el cambio de B con su valor viejo + 200

 VENTANA A (ejecutar primero):
 VENTANA B (ejecutar mientras A espera):
 ================================================================ */

-- Resetear dato
UPDATE dbo.Apuestas SET Monto = 500.00 WHERE ApuestaID = 1;

-- VENTANA A
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    DECLARE @montoActual DECIMAL(10,2);
    SELECT @montoActual = Monto FROM dbo.Apuestas 
	WHERE ApuestaID = 1;
    -- Lee 500.00
    WAITFOR DELAY '00:00:10';
    UPDATE dbo.Apuestas
    SET Monto = @montoActual + 200  -- usa el valor viejo (500), escribe 700
    WHERE ApuestaID = 1;
    -- La actualización de B (400) queda sobreescrita
COMMIT TRANSACTION;

-- VENTANA B (ejecutar mientras A está en el WAITFOR)
UPDATE dbo.Apuestas SET Monto = Monto - 100 
WHERE ApuestaID = 1;
-- Lee el valor actual (todavia 500), escribe 400
-- Hace commit antes que A, pero A lo sobreescribe con 700

-- Verificar resultado final (debe ser 700 en vez de 600)
SELECT Monto, '600 era el esperado, 700 evidencia el Lost Update' AS Nota
FROM dbo.Apuestas 
WHERE ApuestaID = 1;
GO


/* ================================================================
 5. SERIALIZABLE: prevención total
 Nivel: SERIALIZABLE
 Previene: Dirty Read, Non-Repeatable Read y Phantom Read.
 Mecanismo: bloquea tanto las filas leídas como el rango de claves, impidiendo inserciones que afecten la condición de la query.

 VENTANA A: lee filas con Monto < 600, espera, lee de nuevo
 VENTANA B: intenta insertar una fila que cumpla la condición.
   La inserción queda bloqueada hasta que A haga COMMIT.
   Cuando A relee, la cantidad de filas es la misma.

 ================================================================ */

-- VENTANA A
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    SELECT ApuestaID, Jugador, Monto AS LecturaPrimera
    FROM dbo.Apuestas 
	WHERE Monto < 600;
    WAITFOR DELAY '00:00:10';
    SELECT ApuestaID, Jugador, Monto AS LecturaSegunda
    FROM dbo.Apuestas 
	WHERE Monto < 600;
    -- Mismo resultado que la primera lectura: sin fantasmas
COMMIT TRANSACTION;

-- VENTANA B (ejecutar mientras A esta en el WAITFOR)
-- Esta inserción queda bloqueada hasta que A haga COMMIT
INSERT INTO dbo.Apuestas VALUES (5, 'Valentina', 100.00, 'Activa');
-- Ejecutar SELECT * FROM dbo.Apuestas para ver cuando se desbloquea
GO


/* ================================================================
 TABLA RESUMEN DE NIVELES DE AISLAMIENTO
 ================================================================ */
SELECT
    nivel         = v.nivel,
    dirty_read    = v.dirty,
    non_repeatable= v.nr,
    phantom_read  = v.phantom,
    lost_update   = v.lu
FROM (VALUES
    ('READ UNCOMMITTED', 'Posible',  'Posible',  'Posible',  'Posible'),
    ('READ COMMITTED',   'Prevenido','Posible',  'Posible',  'Posible'),
    ('REPEATABLE READ',  'Prevenido','Prevenido','Posible',  'Prevenido'),
    ('SERIALIZABLE',     'Prevenido','Prevenido','Prevenido','Prevenido')
) v(nivel, dirty, nr, phantom, lu);
GO


/* ================================================================
 LIMPIEZA (ejecutar al finalizar las demos)
 ================================================================
 DROP TABLE IF EXISTS dbo.Apuestas; */
