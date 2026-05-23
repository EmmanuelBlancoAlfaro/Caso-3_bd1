
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

------------------------------------------------------------------------------------------------------------------------------------------------------		
		
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
		
		
	3. Manejo Asíncrono de tareas y el Patrón Outbox
	
	Existe un dilema cuando necesitemos hacer un cambio local (guardar algo en la db) e invocar un servicio externo (mandar a analizar la proposición a la IA) en la misma operación de negocio. Ejemplo:
	
		1. El sistema inicia la transacción en la db
		2. Guarda el registro "nueva proposición"
		3. Hace una llamada HTTP al modelo de IA pidiendo la validación
		4. La IA responde "Aprobado"
		5. El sistema hace COMMIT de la transacción
		
		Esto sería catastrófico, ya que el caso 3 puede llegar a durar hasta segundos en completarse, por lo que la transacción mantendría las filas de la db bloquedas por ese tiempo y si miles de personas hacen la misma vara al mismo tiempo, generaría un deadlock masivo
		Y si se decide hacer el COMMIT primero y luego llamar a la IA, si llega a ocurrir un error de red en media transacción, el registro queda en un limbo innacesible
		
	Por dicha los ingenieros actuales ya tienen una solución, el Patrón Outbox. Este asegura que la db transaccional solo se encargue de lo que se le da mejor, guardar datos en microsegundos usando garantías ACID
	
		Mecánica: En lugar de llamar a la IA directamente, la transacción local hace dos cosas a la vez:
		
			1. Inserta la entidad dominio (ej. la proposición en estado Pendiente_IA)
			2. Inserta un "Mensaje" o "Evento" en una tabla especial llamada Outbox dentro de la misma db
			
		Como ambas ocurren a la vez, hay la garantía de Atomicidad: o se guarda la proposición junto con la intención de llamar a la IA, o no se guarda ninguna
		
	Una vez el evento esté en la tabla Outbox, la db termina su trabajo. Ahora, entra un proceso secundario independiente del usuario que hizo clics. Existen 2 formas para leer y procesar este proceso:
	
		1. Polling: Un script o hilo ejecuta un SELECT cada 5 segundos buscando registros no procesados en el Outbox. Toma los registros, llama a la IA y si la IA responde bien, borra el mensaje del Outbox o lo marca como procesador
		
		2. Log Tailing: En lugar de ejecutar consultas lentas, una herramienta externa lee directamente el archivo binario de transacciones del motor de la db a nivel disco, extrayendo los eventos del Outbox sin agregar sobrecarga de lectura al motor relacional

	Todo muy bien con el Outbox, sin embargo, puede haber riesgo de duplicación, que pasa si el script lee el Outbox, llama a la IA y hace su trabajo, pero justo antes de que la IA responda y el script marque el proceso como completado, su cooldown se reinicia y vuelve a leer el Outbox? se duplica el proceso y resultado. Por lo que, los componentes externos deben estar diseñados para identificar que ya procesaron esa petición única y simplemente devolver el resultado anterior sin volver a ejecutar lo mismo
	
--------------------------------------------------------------------------------------------------------------------------------------------------------
	
	TEMAS DE RENDIMIENTO Y PATRONES ESTRUCTURALES:
	
	1. CQRS y Segregación de Operaciones
		
	Según la teoría de CQRS, las lecturas y las escrituras tienen necesidades de rendimiento, escalabilidad y seguridad opuestas.
		
		1. Comportamiento de Escritura (Commands): Son validaciones, cálculos y bloqueos de la db. Su objetivo es garantizar la integridad ACID
		
		2. Comportamiento de Lectura (Queries): Son operaciones de consulta. Su objetivo es mostrar los datos de la manera más rápida posible
		
		Forzar a ambos procesos a usar las mismas estructuras crea un cuello de botella donde las consultas de lectura pesadas terminan bloqueando las transacciones de escritura críticas
		
	Un Command es una orden imperativa que cambia el estado del sistema. Un comando debe ejecutar una acción y no devolver datos (solo éxito, fallo o el ID generado). La teoría respalda que los comandos se deben ejecutar mediante SP:
	
		1. Reducción de latencia de red: Si se usa un ORM para escribir lógica compleja, el backend debe realizar múltiples viajes en la red. Si esta es lenta, la transacción tarda y bloquea la fila durante tiempo crítico. Un SP encapsula todo esto, viaja un solo comando al backend, la db procesa toda la lógica internamente a nivel de procesador y devuelve el resultado, minimizando el tiempo de bloqueo
		
		2. Seguridad por capas: Al usar SPs, puedes revocar todos los permisos de INSERT, UPDATE y DELETE directamente en las tablas. Los usuarios de la db solo tendrán permiso de EXECUTE sobre el SP. Esto impide que una inyección SQL o un error en el backend pueda vaciar una tabla o saltarse validaciones financieras
		
	Un Query es una solicitud sin efectos en el estado del sistema. Devuelve un modelo de datos de transferencia (DTO). Normalmente se usa un ORM para leer:
	
		1. Flexibilidad de Interfaz: Las interfaces de usuario cambian todo el rato, un día el frontend necesita algo, al día siguiente otra cosa. Un ORM permite que los devs de backend construyan SELECTS dinámicos y paginaciones rápidamente sin tener que pedirle a un administrador de la db que modifique y recompile un SP cada vez que cambia un pixel en la pantalla
		
		2. Hidratación de Objetos: El ORM sobresale en tomar filas y columnas planas de una db relacional y transformarlas en grafos de objetos orientados a objetos en la memoria del servidor, listos para ser serializados como JSON hacia el frontend
		
	El sistema CQRS no solo separa el código, sino que separa físicamente las db:
	
		1. Write DB: Una db super normalizada, optimizada para recibir miles de inserts por segundos
		
		2. Read DB: Una db desnormalizada, optimizada para tablas pre-calculadas donde la información ya está estructurada exactamente como la pide el frontend (sin necesidad de hacer JOINS)
		
	
	2. Estrategias de Particionamiento: 
		
	En las dbs relacionales, una tabla se almacena físicamente en el disco dentro de estructuras llamadas páginas y extensiones. Cuando la tabla crece a millones de filas, operaciones como el mantenimiento de índices, escaneos, etc.. se vuelve sumamente lento. El particionamiento horizontal resuelve esto dividiendo físicamente los datos en múltiples fragmentos más pequeños basándose en una regla, pero manteniendo la idea de que es una sola gran tabla:
	
		1. Aplicación Transparente: Para el backend, sigue siendo un SELECT FROM xxxx. El ORM o el SP no saben que la tabla está partida en 50 pedazos. El motor de la db hace el enrutamiento mágico en el fondo
		
		2. La llave de partición: Es la columna que define a qué fragmento va cada fila. En sistemas transaccionales, casi siempre es una columna de fecha temporal o una llave de estado
		
	El verdadero poder del particionamiento durante la lectura se llama Pruning.
	
		Si se tiene una tabla con 10 años de datos, particionada por mes, se tendrán 120 particiones físicas. Si un usuario quiere ver datos de esta semana, el optimizador de consultas lee la clásula "WHERE Fecha >= hace 4 días" y se da cuenta de que los datos requeridos solo pueden existir en la partición actual. Por lo que, el motor de la db ignora las otras 119 particiones. Gracias a esto se reduce el costo del disco en más de un 99% sin cambiar una sola línea de código
		
	El particionamiento introduce el patrón de Ventana Deslizante para evitar usar DELETES:
	
		1. Se crea una nueva partición vacía al frente para recibir los datos de mañana
		
		2. Se desconecta la partición más vieja de la parte trasera usando una operación de metadatos (ALTER TABLE SWITCH)
		
		Esto funciona porque un SWITCH de partición no borra los datos fila por fila, simplemente desenlaza el puntero que une esa partición con la tabla principal. Por lo que se pueden eliminar millones de filas al instante
		
	Mientras el particionamiento divide la tabla entera, los índices filtrados aplican una teoría similar pero a los B-Trees que acelaran las búsquedas En vez de tomar en cuenta todos los registros (en nuestro caso las proposiciones activas y cerradas) el índice filtrado solo toma en cuenta las proposiciones que estén activas
	
-------------------------------------------------------------------------------------------------------------------------------------------------------

	TEMAS DE SEGURIDAD AVANZADA
	
	1. Cifrado a nivel de celda y certificados maestros:
	
	Para entender este tema, primero hay que ver qué problemas no resuelve. En seguridad de db, existen 2 capas previas:
	
		1. Cifrado en tránsito (TLS): Protege los datos meintras viajan pro el cable de red entre la API y la db
		
		2. Cifrado en reposo (TDE): Cifra los archivos físicos .mdf y .ldf en el disco duro. Si alguien entre al centro de datos y roba físicamente el servidor, no podrá leer los datos
		
		Problema: Si un atacante logra obtener credenciales válidas y hace un SELECT FROM billeteras, ni TLS ni TDE lo detienen. El motor de la db descifra los datos automáticamente y se los entrega en texto plano.
		
		El cifrado a nivel de celda agrega una capa de Defensa en Profundidad. Los datos se almacenan cifrados lógicamente dentro de la tabla. Incluso si alguien tiene acceso total a la db y ejecuta un SELECT, solo verá una cadena binaria incomprensible a menos que posea la llave criptógrafica exacta para esa columna
		
	La criptografía a escala no funciona encriptando datos directamente con una contraseña, sino que exige un sistema de gestión de llaves jerárquico. Se diseña como una cadena de confianza donde cada eslabón protege al siguiente:
	
		1. Service Master Key (SMK): Es la raíz matemática de toda la instancia del servidor. Se genera automáticamente al instalar el motor y está atada al sistema operativo
		
		2. Database Master Key (DMK): Es la llave maestra específica de la db. Se cifra usando la SMK
		
		3. Master Certificate: Un certificado de seguridad que se ancla a la DMK
		
		4. Symmetric Key: La llave final que hace el trabajo pesado. Se cifra usando el certificado
		
		Se usa tanta vara por que las llaves se deben cambiar cada cierto tiempo y si tuvieramos solo 1 contraseña para cifrar 10millones de datos, al cambiarla tendríamos que descifrar y volver a cifrarlos. En cambio, si se quiere cambiar la seguridad, solo se cambia el certificado que protege la symmetric key y ya
		
	Normalmente se usa la criptografía simétrica y asimétrica en dbs porque resuelven cosas distintas:
	
		1. Asimétrica (El certificado): Usa un par de llaves, es muy segura pero usa muchos recursos, entonces cifrar cada celda con esto petaría el CPU
		
		2. Simétrica (La llave final): Usa una sola llave matemática para cifrar y descifrar. Es mucho más rápida
		
		Por lo que se usa la simétrica para cifrar todas las celdas de datos y la asimétrica para cifrar esa llave simétrica
		
	En una arquitectura segura, el DBA no es alguien que tiene acceso a todo:
	
		1. EL DBA debe poder hacer respaldos de la db, restaurarla, hacer índices y particiones, pero sobre la data cifrada
		
		2. Para que la data se vuelva legible, se requiere abrir el Master Certificate, algo que el DBA no debería saber cómo, ya que se realiza mediante un SP de acceso temporal el cual es inyectado en memoria por la aplicación web autorizada
		
	La criptografía moderna usa Entropía (randomness). Esto destruye por completo el ordenamiento de los datos. Por lo que resulta en escaneos de tablas ultra costosos en poder computacional. Hay que saber ponerle límites para no destrozar todo

	2. Data Masking dinámicos
	
	Normalmente se confunden el enmascaramiento con el cifrado, pero son diferentes:
	
		1. Cifrado (seguridad): Altera físicamente los bits de la información en el disco duro o en la memoria. Cuesta ciclos de procesador para revertirlo
		
		2. Data Masking Dinámico (Privacidad): No altera absolutamente nada en el disco duro. Físicamente, el número de teléfono o el email de un cliente sigue guardado en texto plano perfecto en las páginas de la db. La magia ocurre en la capa de presentación, justo antes de enviar el paquete de red al cliente
		
		El motor relacional actua como un Proxy Interceptor. Cuando se ejecuta una instrucción SELECT, el motor compila los resultados y evalúa el contexto de seguridad de la sesión. Si el usuario que mandó el query no posee permisos de desenmascarar, el motor reemplaza los caracteres sensibles por caracteres como X o *
		
	El enmascaramiento establece distintos algoritmos dependiendo del tipo de dato, para no romper la experiencia del usuario: 
	
		1. Enmascaramiento total: Destruye completamente el valor. Un nombre se convierte en XXXX, un número 1500 se convierte en 0
		
		2. Enmascaramiento parcial: Preserva información útil para el contexto de soporte técnico. Muestra los primeros o últimos caracteres y oculta el centro 
		
		3. Enmascaramiento semántico: Reconoce la estructura del dato. Un correo se transforma manteniendo la primera letra y la sintaxis del dominio, lo que permite a un analista saber que es un correo válido sin revelar datos sensibles
		
		4. Enmascaramiento aleatorio: Exclusiva para campos numéricos. Sustituye el valor real por un valor aleatorio dentro de un rango definidos
		
	El data masking dinámico no es un mecanismo de seguridad hermético, porque sufre de vulnerabilidades de ataques de inferencia. Dado que el dato en el disco no está cifrado, el motor de la db sigue utilizando el valor real para resolver la lógica de las cláusulas "WHERE, JOIN, GROUP BY" y para el ordenamiento de los índices. Ejemplo: 
	
		Supongamos que el balance de puntos de un jugador está enmascarado y el usuario atacante solo ve un 0 en su pantalla. El atacante (con permisos básicos de SELECT) puede ejecutar ataques de fuerza bruta binaria:
		
		1. SELECT * FROM Jugadores WHERE Nombre = 'Elizabeth' AND BalancePuntos > 1000 (Devuelve $0$ filas).
		
		2. SELECT * FROM Jugadores WHERE Nombre = 'Elizabeth' AND BalancePuntos < 500 (Devuelve $1$ fila, aunque muestre un $0$ ofuscado).
		
		3. SELECT * FROM Jugadores WHERE Nombre = 'Elizabeth' AND BalancePuntos = 350 (Devuelve $1$ fila).
		
		Mediante este truco, el atacante ha logrado extraer el valor exacto sin haber tenido jamás el permiso para desenmascarar la columna. Por esta razón, se exige que el DDM se use solo para mitigar exposiciones accidentales en apps y herramientas de reportes, pero nunca como sustituto del control de acceso estricto o cifrado a nivel de celda para datos sensibles
		
	3. Row-Level Security (RLS) basado en predicados: 
	
	Normalmente, para aislar datos se delega la responsabilidad al dev de backend, mediante clásulas. El problema es que si a un programador se le olvida agregarlas correctamente en un nuevo endpoint de la API, ocurre una brecha de datos masiva. Para solucionar esto, el RLS traslada la responsabilidad del código de la app al nivel del kernel del motor de la db
	
	El RLS no funciona mediante permisos estáticos, sino aplicando una función de predicado matemática a cada fila. El motor de la db evalúa la función f(fila,contexto) ---> boolean
	
		1. Si la evaluación es verdadera, la fila se incluye en el flujo de resultados
		
		2. Si la evaluación es falsa, la fila se descarta a nivel de bajo nivel, antes de que el optimizador de consultas la envíe a la memoria
		
	Se deben de distinguir dos comportamientos de los predicados:
	
		1. Predicados de Filtro: Son silenciosos. Se aplican a las operaciones de lectura, actualizacion y borrado. Si un usuario intenta hacer un UPDATE masivo a todas las billeteras, el motor filtrará la instrucción para que solo afecte a su propia billetera
		
		2. Predicados de bloqueo: Son explícitos y ruidosos. Se aplican a los INSERTS. Previenen que un usuario cree un registro que luego no podrá ver. Si un usuario intenta insertar una predicción simulando que es otro usuario, el predicado detiene la transacción y lanza un error de SEGURIDAD
		
	Cómo sabe el motor de la db quién está ejecutando la consulta si todas las peticiones vienen del mismo Connection Pool del backend? En el RLS existen dos enfoques para inyectar el contexto de identidad: 
	
		1. Basado en el usuario de la db: Se utiliza la función USER_NAME(). Es útil si la app crea una conexión de db dedicada para cada jugador (ineficiente a gran escala)
		
		2. Basado en el Contexto de Sesión: Es el estándar para aplicaciones web. La app web se conecta usando un usuario genérico, pero inmediatamente ejecuta un SP temporal que inyecta un par clave-valor en la memoria de la sesión. El predicado de RLS leerá esta memoria volátil para aplicar el aislamiento matemático
		
	El mayor triunfo del RLS es su capacidad para mitigar ataques de inyección SQL
	
----------------------------------------------------------------------------------------------------------------------------------------------

	TEMAS DE AISLAMIENTO Y CONCURRENCIA 
	
	1. Isolation Levels: 
	
	Los niveles de aislamiento dictan las reglas de como el motor de la db maneja el tráfico de múltiples transacciones queriendo modificar una misma tabla a la vez. Los cuatro niveles estándar y los fenómenos que permiten y previenen son los siguientes:
	
		El fenómeno base: Dirty Reads y READ UNCOMMITED
		
			1. El nivel (READ UNCOMMITED): Es el nivel más relajado. Las consultas en este nivel no solicitan bloqueos compartidos al leer datos, además, ignoran los bloqueos exclusivos que otras transacciones hayan puesto
			
			2. El problema (Dirty Read): Ocurre cuando la transacción A modifica un dato, pero aún no hace COMMIT. La transacción B lee ese dato modificado. Si la transacción A decide hacer un ROLLBACK, la transacción B se queda operando con un dato fantasma que nunca existió en la db
			
			3. Uso real: Nunca se usa para finanzas. Se usa para reportes estadísticos masivos donde un margen de error mínimo es aceptable a cambio de no bloquear el sistema
			
		El fenómeno: Non-Repeatable Reads y READ COMMITED
		
			1. El nivel (READ COMMITED): Es el nivel por defecto en SQL Server. Garantiza que solo leerás datos que ya han sido confirmados. Si la transacción A está modificando una fila, la transacción B que intenta leerla se quedará esperando a que termine la años
			
			2. El problema (Lectura no repetible): Ocurre cuando una misma transacción lee la misma fila dos veces y obtiene datos distintos
			
		El fenómeno: Phantom Reads y REPEATABLE Read
		
			1. El nivel (REPEATABLE READ): Sube la seguridad. Soluciona el problema anterior manteniendo los bloqueos de lectura sobre las filas hasta que la transacción completa termina. Nadie puede modificar las filas que ya se leyó
			
			2. El problema (Lectura Fantasma): Este fenómeno no afecta a las filas existentes, sino a las filas nuevas:

					Transacción A ejecuta: SELECT * FROM Predicciones WHERE ProposicionID = 10. Retorna 5 apuestas.

					Transacción B inserta una nueva apuesta para la ProposicionID = 10 y hace COMMIT.

					Transacción A vuelve a ejecutar la misma consulta exacta y, de la nada, aparece una sexta apuesta "fantasma".
					
		El aislamiento absoluto: SERIALIZABLE
		
			1. El nivel (SERIALIZABLE): El resultado de ejecutar transacciones concurrentes debe ser idéntico al resultado si se ejecutaran en serie
			
			2. El Mecanismo: Para prevenir los Phantom Reads, este nivel no solo bloquea las filas que lee, sino que usa Bloqueos de Rango de Claves. Si se está leyendo un registro, la db bloquea el índice para que nadie pueda insertar ningun registro nueva que coincida con esa condición hasta que se termine de leer
			
			3. El costo: Es la garantía absoluta ACID, pero es devastador para el RENDIMIENTO

				
		El aislamiento optimista: SNAPSHOT
		
			1. En lugar de bloquear filas y generar filas de espera masivas, utiliza un mecanismo llamado control de concurrencia multiversión
			
			2. Cuando la Transacción A inicia, se toma una foto a la db y se guarda en la db del sistema "tempdb". Si la transacción B modifica y compromete datos, la Transacción A sigue leyendo su versión SNAPSHOT
			
			3. No hay lecturas sucias, ni repetibles ni fantasmas y los lectores no bloquean a los escritores ni viceversa. Es una solución buena para evitar deadlocks al costo de consumir más disco y RAM del servidor
			
	2. Deadlock Graph y Trace Flags:
	
	Un motor como SQL Server tiene un hilo de procesamiento en segundo plano llamado Lock Monitor. Este hilo despierta periódicamente para recorrer en memoria el árbol de bloqueos activos. Cuando el monitor detecta un ciclo cerrado, sabe que las transacciones estarán en un estado de inanición eterna. El motor debe romper el ciclo eligiendo una víctima. La escoge de la siguiente manera:
	
		1. Prioridad: El motor revisa si alguna sesión tiene asignado un DEADLOCK_PRIORITY más bajo
		
		2. Costo de Reversión: Si todas tienen la misma prioridad, el motor calcula cuál transacción ha escrito menos bytes en el registro. Matar a esta transacción es más rápido y barato para el servidor

		A la víctima se le inyecta un ERROR 1205, su transacción hace ROLLBACK forzoso y se liberan sus recursos

	Normalmente cuando ocurre un Deadlock no se guarda un registro de qué causó el choque. Para forzar al motor a registrar la evidencia se utilizan Trace Flags. Son interruptores de diagnóstico a bajo nivel que alteran el comportamiento del motor

		1. Trace Flag 1204: Devuelve un reporte en texto plano de los nodos involucrados en el Deadlock

		2. Trace Flag 1222: Devuelve la información en formato XML estructurado, que describe los procesos y recursos
		
		Se activan globalmente mediante el comando DBCC TRACEON (1222, -1). Una vez encendido, cada vez que ocurra un deadlock, se activará como ya se explicó
		
	El deadlock Graph es la representación en formato XML del evento capturado. En SQL Server Management Studio, si se guarda el XML como .xdl, el programa lo renderiza gráficamente. Las tres secciones principales de este grafo son:

		1. Process-List: Enumera las sesiones que chocaron. Aquí se verán qué SPs o instrucciones SQL estaban ejecutando cada hilo en el momento del choque

		2. Resource-List: Enumera los objetos físicos que estaban en disputa. Se verán bloqueos de llave sobre índices específicos o bloqueos de página. Muestra quién era el "dueño" del recurso y quién estaba en espera
		
		3. Victim-List: Declara cuál de los procesos del Process-List fue sacrificado
		
	Aunque es bueno conocer de los Trace Flags, actualmente en modelos como SQL Server se usan los Extended Events (XEvents)
	
		1. Proporcionan un sistema de telemetría asíncrono y de bajo impacto
		
		2. El "System Health": SQL Server trae por defecto una sesión de eventos extendidos llamada system_health que corre en el fondo desde que se instala el servidor. Esta sesión captura automáticamente el XML del Deadlock Graph y lo guarda en un ring buffer  