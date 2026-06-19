## READ UNCOMMITTED
1. El nivel (READ UNCOMMITED): Es el nivel más relajado. Las consultas en este nivel no solicitan bloqueos compartidos al leer datos, además, ignoran los bloqueos exclusivos que otras transacciones hayan puesto.
			
2. El problema (Dirty Read): Ocurre cuando la transacción A modifica un dato, pero aún no hace COMMIT. La transacción B lee ese dato modificado. Si la transacción A decide hacer un ROLLBACK, la transacción B se queda operando con un dato fantasma que nunca existió en la db.

3. Uso real: Nunca se usa para transacciones financieras o datos críticos. Se utiliza para reportes estadísticos masivos o dashboards de monitoreo (por ejemplo, contar la cantidad aproximada de usuarios activos en un sitio web en este momento), donde un margen de error mínimo es aceptable a cambio de no bloquear el sistema y mantener un rendimiento altísimo.

## READ COMMITTED
1. El nivel (READ COMMITED): Es el nivel por defecto en SQL Server. Garantiza que solo leerás datos que ya han sido confirmados. Si la transacción A está modificando una fila, la transacción B que intenta leerla se quedará esperando a que termine la años.
			
2. El problema (Lectura no repetible): Ocurre cuando una misma transacción lee la misma fila dos veces y obtiene datos distintos, porque otra transacción modificó ese registro e hizo COMMIT entre ambas lecturas.

3. Uso real: Es el escenario general para el 90% de las aplicaciones web y móviles (como consultar el catálogo de productos de una tienda en línea o cargar la información de un perfil de usuario). Es rápido y protege contra datos corruptos, asumiendo que no necesitas garantizar la inmutabilidad de la lectura por tiempos prolongados.
## REPEATABLE READ
1. El nivel (REPEATABLE READ): Sube la seguridad. Soluciona el problema anterior manteniendo los bloqueos de lectura sobre las filas hasta que la transacción completa termina. Nadie puede modificar las filas que ya se leyó

2. El problema (Lectura Fantasma): Este fenómeno no afecta a las filas existentes, sino a las filas nuevas:

Transacción A ejecuta: SELECT * FROM Predicciones WHERE ProposicionID = 10. Retorna 5 apuestas.

Transacción B inserta una nueva apuesta para la ProposicionID = 10 y hace COMMIT.

Transacción A vuelve a ejecutar la misma consulta exacta y, de la nada, aparece una sexta apuesta "fantasma".

3. Uso real: Se utiliza en procesos de auditoría local, generación de estados de cuenta o flujos donde se requiere leer varios registros, realizar cálculos con ellos y actualizarlos posteriormente dentro de la misma transacción (ej. aplicar un descuento masivo a un grupo específico de facturas), asegurando que nadie modifique esos registros en el interín.

## SERIALIZABLE
El aislamiento absoluto: SERIALIZABLE

1. El nivel (SERIALIZABLE): El resultado de ejecutar transacciones concurrentes debe ser idéntico al resultado si se ejecutaran en serie

2. El Mecanismo: Para prevenir los Phantom Reads, este nivel no solo bloquea las filas que lee, sino que usa Bloqueos de Rango de Claves. Si se está leyendo un registro, la db bloquea el índice para que nadie pueda insertar ningun registro nueva que coincida con esa condición hasta que se termine de leer

3. El costo y Uso real: Es la garantía absoluta ACID, pero es devastador para el RENDIMIENTO. Su uso real se restringe exclusivamente a operaciones financieras ultra críticas, como el cierre mensual de un libro mayor contable (Ledger) o la transferencia final de fondos entre cuentas bancarias, donde se debe garantizar matemáticamente que no ingrese ni un solo registro a destiempo.