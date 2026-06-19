# Concurrencia y Transacciones

Este documento explica los conceptos demostrados en los scripts de esta carpeta, qué problemas puede provocar cada nivel de aislamiento, cómo identificarlos y cómo mitigarlos en escenarios reales.

Los scripts se ejecutan manualmente en SSMS abriendo múltiples ventanas según se indica en cada sección. No son migraciones de Flyway sino demos de concurrencia.


## SP Anidados (01_SP_Anidados.sql)

Cuando un Stored Procedure llama a otro, que a su vez llama a otro, SQL Server no crea subtransacciones independientes. En cambio, incrementa la variable global @@TRANCOUNT en 1 por cada BEGIN TRANSACTION que se ejecuta, sin importar cuántos SPs distintos lo llamen.

### El peligro (CASO 1 - sin control de @@TRANCOUNT)

Si el SP más interno hace ROLLBACK TRANSACTION, SQL Server revierte TODO hasta el BEGIN TRANSACTION más externo y deja @@TRANCOUNT en 0.
Cuando el SP del medio intenta hacer COMMIT, el motor lanza el error 3902:

> *"The COMMIT TRANSACTION request has no corresponding BEGIN TRANSACTION"*

El error se propaga hacia arriba de forma descontrolada. Los datos quedan revertidos pero la aplicación recibe errores inesperados que no sabe manejar.

### La solución (CASO 2 - patrón con @@TRANCOUNT)

Cada SP declara una variable local @esTransaccionPropia BIT e inicia una transacción solo si @@TRANCOUNT = 0. De esta forma:

- Solo el SP más externo abre y cierra la transacción real.
- Los SPs internos se "unen" a la transacción existente sin crear una propia.
- Si ocurre un error en cualquier nivel, se propaga con THROW hacia arriba.
- El SP externo es el único responsable de hacer ROLLBACK o COMMIT.
- XACT_STATE() se usa en el CATCH para verificar si la transacción aún es reversible antes de intentar el ROLLBACK.


## Niveles de Aislamiento (02_Aislamiento.sql)

Los niveles de aislamiento controlan qué tan protegida está una transacción de los efectos de otras transacciones concurrentes. A mayor aislamiento, mayor consistencia pero menor concurrencia (más bloqueos).

### Dirty Read — READ UNCOMMITTED

**Qué es:** Una transacción lee datos modificados por otra que aún no ha hecho COMMIT. Si esa otra transacción hace ROLLBACK, la primera tomó decisiones basadas en datos que nunca existieron formalmente.

**Cómo identificarlo:** La lectura devuelve un valor que luego desaparece porque la transacción original fue revertida.

**Mitigación:** Nunca usar READ UNCOMMITTED en operaciones financieras o que afecten decisiones de negocio. Solo es aceptable en reportes estadísticos donde un margen de error mínimo es tolerable y el rendimiento es prioritario.


### Non-Repeatable Read — READ COMMITTED

**Qué es:** Una transacción lee la misma fila dos veces dentro de la misma operación y obtiene valores distintos porque otra transacción la modificó y confirmó entre las dos lecturas.

**Cómo identificarlo:** El primer SELECT devuelve un valor, el segundo SELECT sobre la misma fila devuelve un valor diferente dentro de la misma transacción.

**Mitigación:** Subir el nivel a REPEATABLE READ para que los S-locks sobre las filas leídas se mantengan hasta el fin de la transacción, evitando que otras transacciones las modifiquen mientras tanto.


### Phantom Read — REPEATABLE READ

**Qué es:** Una transacción lee un rango de filas por condición (WHERE Monto < 600), otra transacción inserta una fila nueva que cumple esa misma condición, y la primera transacción ve filas "fantasmas" que no estaban en su primera lectura. REPEATABLE READ protege las filas ya leídas contra modificaciones, pero no protege el rango contra nuevas inserciones.

**Cómo identificarlo:** El primer SELECT devuelve N filas, el segundo SELECT con la misma condición devuelve N+1 filas dentro de la misma transacción.

**Mitigación:** Subir el nivel a SERIALIZABLE, que bloquea el rango de claves del índice, impidiendo que cualquier inserción que satisfaga la condición se confirme mientras la transacción está activa.


### Lost Update — READ COMMITTED

**Qué es:** Dos transacciones leen el mismo valor, calculan una actualización basada en ese valor inicial, y la segunda en escribir sobreescribe el cambio de la primera. La actualización de la primera queda "perdida".

**Cómo identificarlo:** El resultado final no refleja ambas operaciones. En el ejemplo del script, el saldo debería ser 600 (500 + 200 - 100) pero queda en 700 porque T1 sobreescribe con el valor viejo que leyó antes del cambio de T2.

**Mitigación:**
- Usar REPEATABLE READ o SERIALIZABLE para que la segunda transacción no pueda leer el valor sin esperar a que la primera termine.
- En aplicaciones: usar concurrencia optimista con un campo de versión (rowversion o timestamp) y verificar que el valor no cambió antes de escribir.


### SERIALIZABLE — protección total

El nivel más estricto. Bloquea tanto las filas leídas como el rango de claves del índice que cubre la condición del WHERE. Garantiza que el resultado de ejecutar transacciones concurrentes sea idéntico a ejecutarlas en serie.

**Costo:** Reduce drásticamente la concurrencia. En sistemas de alto tráfico puede generar colas de espera largas y aumentar el riesgo de deadlocks. Se usa solo cuando la consistencia absoluta es un requisito no negociable.

### Tabla resumen

| Nivel             | Dirty Read | Non-Repeatable | Phantom   | Lost Update |
|-------------------|:----------:|:--------------:|:---------:|:-----------:|
| READ UNCOMMITTED  | Posible    | Posible        | Posible   | Posible     |
| READ COMMITTED    | Prevenido  | Posible        | Posible   | Posible     |
| REPEATABLE READ   | Prevenido  | Prevenido      | Posible   | Prevenido   |
| SERIALIZABLE      | Prevenido  | Prevenido      | Prevenido | Prevenido   |


## Deadlocks (03_Deadlocks.sql)

Un deadlock ocurre cuando dos o más transacciones se bloquean mutuamente porque cada una tiene un recurso que la otra necesita para continuar, formando un ciclo de espera del que no pueden salir solas. 
SQL Server tiene un proceso en segundo plano (Lock Monitor) que recorre el árbol de bloqueos activos periódicamente. Al detectar un ciclo, elige una transacción como víctima (normalmente la que ha escrito menos datos) y la termina con el error 1205, liberando sus recursos para que la otra pueda avanzar.

### Escenario 1 — Deadlock clásico entre dos transacciones (escritura-escritura)

T1 bloquea la fila de Mariana con un X-lock al actualizarla, luego necesita la fila de Esteban. T2 bloquea la fila de Esteban, luego necesita la de Mariana. Ciclo de dos nodos: ninguna puede avanzar.

**Causa:** Dos UPDATE sobre filas distintas en orden inverso entre dos transacciones.

**Prevención:** Establecer un orden canónico de acceso a recursos (siempre actualizar primero la fila de menor ID) para eliminar el ciclo.

### Escenario 2 — Deadlock cíclico T1 → T2 → T3 → T1

T1 bloquea fila 1 y necesita fila 2. T2 bloquea fila 2 y necesita fila 3. T3 bloquea fila 3 y necesita fila 1. Ciclo de tres nodos.

SQL Server detecta el ciclo de la misma manera independientemente del número de participantes y elige una víctima.

### Escenario 3 — Deadlock provocado por SELECT + escritura concurrente (REPEATABLE READ)

Este es el escenario más importante de entender porque el deadlock no lo causan los UPDATE directamente, sino el nivel de aislamiento.

**Por qué ocurre:** REPEATABLE READ retiene los S-locks sobre las filas leídas hasta que la transacción termina. Un S-lock es compatible con otros S-locks
(varias transacciones pueden leer la misma fila al mismo tiempo), pero es incompatible con un X-lock.

**El ciclo:**
1. T1 lee la fila de Mariana con SELECT → adquiere S-lock sobre fila 1.
2. T2 lee la fila de Esteban con SELECT → adquiere S-lock sobre fila 2.
3. T1 intenta UPDATE sobre Esteban → necesita X-lock sobre fila 2, bloqueado por el S-lock de T2.
4. T2 intenta UPDATE sobre Mariana → necesita X-lock sobre fila 1, bloqueado por el S-lock de T1.

Deadlock. Ningún UPDATE explícito causó el bloqueo inicial; fue el SELECT que retuvo su S-lock lo que provocó el ciclo.

**Mitigación:**
- Usar READ COMMITTED o nivel SNAPSHOT si no se necesita la garantía de lectura repetible.
- Si se necesita REPEATABLE READ, acceder a los recursos siempre en el mismo orden entre todas las transacciones.
- Capturar el error 1205 en el código de la aplicación y reintentar la operación.

### Registro de deadlocks

El script incluye la consulta para leer el Deadlock Graph desde el buffer del system_health, la sesión de Extended Events que SQL Server mantiene activa por defecto. También se puede activar el Trace Flag 1222 para registrar el XML en el error log del servidor.