
=====================================================================================
Esta investigación tiene cómo propósito entender bien los mecanismos necesarios para realizar la db del juego Gathel de la mejor manera posible, porque ahorita mismo estamos mamando
======================================================================================

	TEMAS DE FINTECH:
	
	1. Patrón Ledger:
	
	Cuando uno tiene un sistema de balances en un base de datos y quiere actualizar el balance de una persona, es un error hacerlo de la siguiente manera:
	
		///
		UPDATE Usuarios SET BalancePuntos = BalancePuntos - 10 WHERE UsuarioID = 5;
		UPDATE Usuarios SET BalancePuntos = BalancePuntos + 10 WHERE UsuarioID = 8;
		///
		
	Esto debido a varios motivos:
	
		1. No hay un historial del por qué se realizaron los cambios en el balance del jugador, si el mae te pregunta por qué sus 100 puntos iniciales cambiaron, no habría manera de responderle certeramente
		
		2. Si el usuario hace dos clics inmediatos para apostar sus últimos 5 puntos, ambos procesos de apuesta podrían leerse y hacerse antes de que el sistema cambie de 5 puntos a 0, ocasionando que el usuario haga 2 apuestas (10 puntos) teniendo solo 5. FUN FACT: un mae se hizo millonario gracias a esta estupidez de error en una web de bitcoin jajaja
		
		3. Puede llegar a pasar que el sistema pete justo después de descontar el dinero al usuario A, pero antes de sumárselo al usuario B, entonces ese dinero queda en el limbo, como un puntero X que guardaba información y se elimina, esa información queda ahí en la nada. También se debe aplicar algo acá para los transactions, para evitar lo que el profe había dicho que asustaban xDD
		
	Todo esto se soluciona con el Patrón Ledger. Este patrón tiene una regla fundamental: "Todo movimiento de dinero implica sacar de una cuenta y meter en otra cuenta distinta. El dinero nunca se destruye ni se crea, solo se transfiere". CINE
	Por lo tanto, la suma de todos los movimientos de una transacción debe ser siempre exactamente cero
	
	Para que el dinero siempre vaya a algún lado, Gathel no solo tendrá cuentas de usuarios, sino también se necesitan crear cuentas de sistema en la db. Más o menos algo así:
	
		1. Cuenta de Emisión (Mint): De donde salen los 100 puntos iniciales que se regalan al registro. Su balance será siempre negativo
		
		2. Cuenta de Custodia (Escrow/Pool): Donde se guarda el dinero apostado mientras la proposición está activa y aún no hay ganador
		
		3. Cuenta de Comisiones (Revenue): Donde la plataforma Gathel acumula sus ganancias
	
	
	2. Sistemas de Apuestas Mutuas:
	
	Mae di, cuando se hacen apuestas, existen 2 sistemas, el de cuota fija y el de apuestas Mutuas
		
		1. Cuota Fija: Es el que se usa en los casinos que es el jugador apostando contra la casa. La casa define una probabilidad estática y asume el riesgo financiero si pierde
		
		2. Apuestas Mutuas: Los jugadores apuestan entre sí y meten su dinero en el pool. La casa no asume ningún riesgo financiero, solo está ahí para mediar, cobrar una comisión fija por el servicio y distribuir las ganancias entre los ganadores. Por lo que las ganancias que obtienen los ganadores no se sabe hasta que se cierren las predicciones y el premio fluctúa dependiendo de la cantidad de apostadores a favor y en contra. Mae como un Polymarket o las apuestas de partidos
		
	Para la distribución de las ganancias y el pozo neto se deben usar las siguientes variables para realizar los cálculos necesarios:
	
		1. P: Pozo total (Suma de todas las apuestas, ganadoras y perdedoras)
		
		2. Cp: Porcentaje de comisión para la plataforma Gathel
		
		3. Ce: Porcentaje de comisión para el jugador que ejecutó la proposición
		
		4. W: Sub-pozo ganador (la suma de las apuestas de quienes acertaron)
		
	Los cálculos siguen la siguiente secuencia:
	
		Paso 1: Extracción del "Vigorish" (comisiones)
		Antes de pagarle a nadie, el sistema retira las ganancias aseguradas. A esto se le llama Vigorish o Takeout y se calcula así:
			Ctotal = P * (Cp + Ce)
			
		Paso 2: Cálculo del Pozo neto
		Es la cantidad del dinero real o puntos que los ganadores se van a repartir:
			N = P - Ctotal
			
		Paso 3: Determinación del Dividendo (ROI)
		Para saber cuánto le toca a cada ganador por cada punto o dinero apostado, se calcula el dividendo R:
			R = N/W 
			
	Hay que tener cuidado cuando se hagan los cálculos del dividendo, casi siempre va a resultar con que será un número con múltiples decimales periodicos o infinitos, pero di esto no nos sirve, ya que las apuestas son con un número de puntos enteros y el dinero darlo con tantos decimales es ineficiente.
	Cuando pasan estas cosas, utilizaremos un sistema llamado Breakage. Este sistema define un tamaño de tick mínimo (esto se refiere a redondear). El pago siempre se redondea hacia el tick más cercano
	Ejemplo: Si un jugador gana 3.56 puntos solo se le dan 3 y si gana 14.4534 dolares, solo se le dan 14.45. La plata o puntos restantes se guarda en una cuenta especial de la plataforma (nos forramos)
	
	Hay 2 escenarios a tomar en cuenta, cuando hay 0 perdedores y cuando hay 0 ganadores.
	
		1. Cuando hay 0 perdedores: Si todos aciertan, según los cálculos, R será menor a 1 por lo que los ganadores recibirán menos dinero del que apostaron
		
		2. Cuando hay 0 ganadores: Si nadie acierta, Gathel se queda con el 100% de las ganancias apostadas
		
	
	3. La teoría del "Doble Gasto" y las Condiciones de Carrera:
	
	Una condición de carrera ocurre cuando el resultado de un proceso depende de la secuencias o el tiempo exacto en que los hilos de ejecución alcanzan el procesador.
	En nuestro caso esto se manifiesta como el Doble Gasto, el usuario gasta el mismo dinero dos veces. Mira este ejemplo:
	
		Un usuario X tiene 10 puntos. Abre la aplicación web y la app móvil al mismo tiempo y presiona "Apostar 10 puntos" exactamente en ambas al mismo tiempo:
		
		1. Hilo A (Web): Lee el balance. ¿Tiene 10 puntos? Sí.

		2. Hilo B (Móvil): Lee el balance. ¿Tiene 10 puntos? Sí (el Hilo A aún no ha descontado nada).

		3. Hilo A: Ejecuta la deducción. Balance nuevo = 0.

		4. Hilo B: Ejecuta la deducción. Balance nuevo = -10 (o simplemente 0 si el código no acepta negativos).
		
		El usuario logró apostar 20 puntos teniendo solo 10, esto es malo por obvias razones
		
	Para esto hay 2 tipos de soluciones:
	
		1. Control de Concurrencia Pesimista: La primera aproximación teórica es ser pesimista. La teoría dicta: "Asume que siempre habrá otro proceso intentando modificar los mismos datos al mismo tiempo, así que bloquea el recurso desde el primer contacto"
			1. Mecánica: Cuando el Hilo A lee el balance del usuario, solicita un bloqueo exclusivo a nivel de fila a la db (en SQL SERVER se conceptualiza con hints como UPDLOCK)
			
			2. Mientras el hilo tenga este bloqueo, si el hilo B intenta leer esa misma fila, el motor de la db lo pondrá a dormir en una cola de espera
			
			3. Problema: Genera un cuello de botella masivo. Si cientos o miles de transacciones intentan tocar la misma fila, todas se formarán en fila india. Además, aumenta exponencialmente el riesgo de Deadlocks
			
		2. Control de Concurrencia Optimista: Es la más usada actualmente. La teoría dicta: "Asume que las colisiones son raras. Deja que todos lean sin bloquear, pero valida la integridad justo en el momento de escribir"
			1. Mecánica mediante Versionamiento: Se le agrega a la fila de la db un token de versión (un serial o TIMESTAMP o RowVersion)
			
			2. El flujo seguro:
				* El hilo A lee el balance (10 puntos) y la versión actual (v1)
				* El hilo B lee el balance (10 puntos) y la versión actual (v1)
				* El hilo A procesa su apuesta e intenta guardar, enviando la instrucción: "Actualiza el balance a 0, SOLO SI la versión sigue siendo v1". Como es v1, se actualiza y cambia la versión a v2
				* El hilo B intenta guardar: "Actualiza el balance a 0, SOLO SI la versión sigue siendo v1". La db rechaza porque ya está en v2
				
			3. Resolución: El Hilo B recibe un error de concurrencia. El backend deberá agarrar el error y decidir si reintenta la operación desde cero o si le dice al usuario que hubo un error
			
	El caso de Gathel exige demostrar los posibles problemas en distintos niveles de aislamiento. Hay 3 fenómenos de lectura que rompen la consistencia:
	
		1. Lecturas Sucias: Un Hilo A modifica un dato, pero aún no hace COMMIT. El Hilo B lee ese dato modificado. Si el Hilo A falla y hace ROLLBACK, el Hilo B tomó decisiones con un dato que nunca existió. Solo ocurre un nivel READ UNCOMMITED
		
		2. Lecturas No Repetibles: El Hilo A lee una fila. El Hilo B actualiza esa fila y hace COMMIT. El Hilo A vuelve a leer la misma fila dentro de su misma transacción y obtiene datos diferentes. Se soluciona subiendo el aislamiento a REPEATABLE READ
		
		3. Lecturas Fantasma: El Hilo A hace un query de rango (Ejemplo: Traer todas las apuestas de la proposición #5). El Hilo B inserta una apuesta nueva para esa proposición. Si el Hilo A repite el query, aparece una fila fantasma que antes no estaba. Solo se soluciona con aislamiento SERIALIZABLE
		
		La teoría dice que SERIALIZABLE es el único nivel que garantiza integridad absoluta, ejecutando las transacciones como si ocurrieran una tras otra. La práctica dice que en una db de alto tráfico mata el rendimiento y colapsa el servidor por exceso de bloqueos. Hay que buscarle el balance
				
	El último concepto importante es el Deadlock, es un estado de parálisis del cual la db no puede salir sola
	
		1. Definición Formal: Dos o más transacciones se bloquean mutuamente porque cada una tiene un recurso que la otra necesita para terminar, creando un ciclo infinito de espera
		
		2. Ejemplo:
			* La transacción 1 bloquea la billetera de X y necesita la billetera de Y para transferirle el dinero
			* La transacción 2 bloquea la billetera de Y y necesita la billetera de X para transferirle el dinero
			* Ambos se quedan esperando para siempre
			
		3. Resolución del motor: SQL Server tiene un "Monitor de Deadlocks" que corre en el background. Al detectar un bucle, elige una transacción como víctima (normalmente la que ha consumido menos recursos) y la extermina a la fuerza (Rollback), permitiendo que la otra avance
		
		
	TEMAS DE MODELADO DE DOMINIO Y LÓGICA DE NEGOCIO:
	
	1. Máquinas de Estado Finito (FSM)
	
	El error teórico más común en el diseño de dbs complejas es modelar el estado de una entidad utilizando múltiples banderas booleanas. Si se intenta algo así:
	
		* isApprovedByAi (boolean)
		* isAcceptedByTarget (boolean)
		* isActiveForBetting (boolean)
		* isResolved (boolean)
		
		Las combinaciones totales para estos 4 booleanos son 16 posibles. Sin embargo, en la práctica, hay estados que serían "ilegales" que estén activos al mismo tiempo porque serían contradicciones
		
	Por lo que, la teoría de las FSM dicta: "la entidad debe tener un único atributo de Estado, limitando el universo a solo los estados válidos definidos formalmente"
	
	Teóricamente, una FSM se modela como un grafo dirigido:
	
		1. Nodos: Son los estados válidos
		2. Aristas: Son las transiciones legales entre esos estados
		
	A la hora de programar, no se puede confiar que el frontend o el backend respeten estas reglas ciegamente. La db debe conocer los datos de la Matriz de Transición
	Esto significa diseñar (ya sea mediante restricciones de FK en tablas maestras o mediante lógica estricta en los SP de escritura) para asegurar que una transición Sa -> Sb sea legal
	
		1. Transición legal: Activa -> Cerrada
		2. Transición Illegal: Terminada y pagada -> activa
		
	En sistemas transaccionales, las transiciones de estado son eventos activos. Para que una ocurra, se debe evaluar una Guarda: una operación que debe devolver verdadero
	
		* Ejemplo: Para pasar del estado Cerrada al estado Validando_Evidencia, la guarda debe verificar que FechaActual sea mayor o igual a FechaEvento
		
	Si pasa, la transición ejecutra efectos secundarios dentro de la misma transacción ACID:
	
		* Ejemplo: Al pasar del estado Activación_Pendiente a Activa, el efecto secundario es iniciar el contador de tiempo y habilitar el pool
		
	La atomicidad exige que el cambio de estado y sus efectos tengan éxito juntos o fallen juntos
	
	Las FSM son vulnerables a las condiciones de carrera si no se combinan con el control optimista. Como en este ejemplo:
	
		1. La IA termina de validar la proposición como verdadera y envía el comando: Transicionar proposición a "Pagada"
		2. El usuario al que le hicieron la proposición odia el resultado y rechaza la proposición
		
		Si ambas de estas solicitudes se hacen al mismo tiempo y el sistema no exige la validación del estado previo, la proposición podría pagarse y luego marcarse como rechazada
		
	La teoría exige que cualquier orden de mutación sea condicional: Actualizar estados a uno nuevo SOLO SI el estado actual es igual al actual (un poco raro si)
	
	Luego, si una proposición está en estado Cerrada, el equipo de auditoría necesita saber la cronología exacta. El diseño auditable sugiere implementar un patrón "Append-Only" para el ciclo de vida, en lugar de hacer un simple UPDATE, cada cambio inserta un registro en una tabla de Historial de Estados que responde al quién, cuándo y por qué. 
	
	2. Soft Deletes vs Tablas de Archivos:
	
	Ya sabemos qué es un Soft Delete. Algunos problemas del Soft Delete son:
	
		1. Fugas de Datos: Exige que todas las consultas del sistema incluyan "WHERE isDeleted = 0". Si a un dev se le olvida esto en un JOIN o reporte, los datos borrados resucitan en la interfaz
		
		2. Degradación de índices: Si tu db tiene 1M de eventos y el 80% están borrados o finalizados, los index de los B-Trees siguen conteniendo esa basura. El motor de búsqueda pierde tiempo recorriendo datos muertos
		
		3. Conflictos de Unicidad: Tenemos una tabla de usuarios con un soft delete y su email tiene una restricción UNIQUE. Si un usuario X borra su cuenta, ya esa cuenta no debería existir, pero si intenta registrarse tiempo después con el mismo correo, la db lanzará un error de porque el correo sigue ocupando el espacio físico

	La alternativa a esto es el borrado fuera de sitio. En lugar marcar el dato como borrado, se mueve físicamente a otra estructura
	
		Mecánica: Al eliminar o finalizar un ciclo de vida, se lee el registro de la tabla (Proposiciones Activas), se inserta en una tabla con estructura idéntica (Proposiciones Archivo) y finalmente se ejecuta un DELETE físico en la primera tabla
		
	Este sistema tiene una serie de Ventajas y Desventajas:
	
		VENTAJAS
		1. Tablas Transaccionales UltraLigeras: La tabla activa solo contiene lo que importa en este momento. Esto hace que los SELECT, INSERTS y los bloqueos de concurrencia sean más rápidos
		
		2. Seguridad por Diseño: Es imposible que un desarrollador consulte accidentalmente un dato borrado, porque tendría que hacerle SELECT a la tabla de Archivo
		
		DESVENTAJAS
		1. Mover datos interrumpe la integridad referencial. Si se mueve una proposición al archivo, hay que decidir si se mueven sus predicciones asociadas o si se rompen las FK
		
		2. Requiere migraciones dobles. Si se agrega una nueva columna, hay que hacerlo en ambas tablas
		
	Si hay dudas de qué usar, no hay que preocuparse, el estándar ANSI SQL:2011 y SQL Server ya implementa la solución de forma nativa, las tablas Temporales
	En lugar de programar los triggers o código para mover los datos, la teoría dicta que la base de datos hace lo siguiente:
	
		1. La tabla principal siempre muestra el estado actual
		
		2. El motor crea y mantiene una Tabla Histórica en la sombra
		
		3. Cada vez que ocurre un UPDATE o DELETE, el motor captura el estado previo y lo envía a la tabla histórica marcando el inicio y fin de su validez temporal (ValidFrom, ValidTo)
		
	Gracias a esto sepueden hacer consultas de viaje en el tiempo. Ejemplo:
		
		SELECT * FROM Proposiciones FOR SYSTEM_TIME AS OF "xxxx"
		La db reconstruirá cómo se veía esa fila en ese momento exacto, ignorando los soft deletes o modificaciones posteriores
		
	En el caso de Gathel, el diseño de sistema se puede aplicar usando varias de estas estrategias a la vez:
	
		1. En la parte financiera se usa el Patrón Ledger, nunca se borra nada. Si hay un error, se ahce una transacción inversa para anular matemáticamente la anterior
		
		2. En la parte de los usuarios y cuentas se suele hacer Soft Delete combinado con Data Masking para cumplir con leyes de privacidad, cambiando el usuario a [DELETEDUSER]
		
		3. En la parte de proposiciones y eventos, las tablas de archivo o las temporales aseguran que la tabla principal vuele, mitigando el problema del millón de registros generados por el seeding
		
		
		
		
		
		
		
		