# Arquitectura de Datos: Patrones de Diseño Seleccionados

Este documento detalla los 8 patrones de diseño estructurales que fundamentan el modelo de base de datos transaccional, garantizando concurrencia, seguridad y trazabilidad.

---

	## 1. Patrón de Libro Mayor (Ledger / Append-Only)

	### Definición
	Un modelo de almacenamiento inmutable donde los datos nunca se actualizan ni se eliminan, únicamente se insertan nuevos registros (partida doble o simple). El estado actual se deriva de la suma de todo el historial.

	### Uso
	Es el núcleo de la economía del sistema. Se utiliza para manejar los saldos de **puntos virtuales** y **dinero real** de los jugadores. Garantiza que ninguna transacción concurrente (ej. múltiples apuestas simultáneas) genere bloqueos severos (deadlocks) por actualizaciones sobre la misma fila de saldo, y asegura auditoría financiera estricta.

	### Estructura

	[Billetera_Jugador]              [Transaccion_Ledger] (Append-Only)
	-------------------              ----------------------------------
	PK: id_billetera         <---    PK: id_transaccion
		id_jugador                   FK: id_billetera
										 monto (Decimal: positivo o negativo)
										 tipo_transaccion (Apuesta, Ganancia, Comision, Recarga)
										 fecha_creacion
										 
										 
	## 2. Patrón Maestro-Detalle (Master-Detail)
	
	### Definición
	Diseño que establece una jerarquía estricta de uno-a-muchos (1:N) donde los registros "Detalle" no tienen sentido ni existencia lógica sin su registro "Maestro".

	### Uso
	Vital para el motor del juego. Administra las relaciones donde una única entidad centraliza múltiples acciones secundarias. Por ejemplo, una Proposicion (Maestro) que recibe miles de Predicciones (Detalle), o un resultado que agrupa varias evidencias multimedia.
	
	### Estructura
	
	[Proposicion] (Maestro)          [Prediccion] (Detalle)
	-----------------------          ----------------------
	PK: id_proposicion       <---    PK: id_prediccion
		descripcion                  FK: id_proposicion
		fecha_limite                     id_jugador
										 postura_boolean (Cumple / No Cumple)
										 monto_arriesgado
										 
										 
	## 3. Normalización Estricta (OLTP - 3NF)
	
	### Definición
	Proceso de estructuración relacional que elimina la redundancia de datos y asegura las dependencias funcionales (Tercera Forma Normal - 3NF). Todo atributo no clave debe depender única y exclusivamente de la clave primaria.

	### Uso
	Garantiza el cumplimiento de las propiedades ACID (Atomicidad, Consistencia, Aislamiento, Durabilidad) requeridas para las pruebas de transacciones y niveles de aislamiento (SERIALIZABLE, READ COMMITTED). Evita anomalías al insertar, modificar o consultar configuraciones y perfiles.
	
	### Estructura
	
	[Jugador] (Entidad Normalizada)
	-------------------------------
	PK: id_jugador
		alias_usuario
		email
		-- No se incluyen campos calculados como "total_ganado" o arrays de redes sociales
		
		
	## 4. Patrón de Trazabilidad (Audit Trail / Event Logging)
	
	### Definición
	Registro cronológico continuo que documenta quién, cuándo y cómo modificó el estado de un recurso crítico dentro del sistema.

	### Uso
	Cumple con los requerimientos de observabilidad y auditoría. Permite seguir el ciclo de vida de un evento (ej. una proposición creada, luego rechazada, o activada) sin perder la historia previa al sobrescribir campos.
	
	### Estructura
	
	[Proposicion]                    [Bitacora_Proposicion]
	-------------                    ----------------------
	PK: id_proposicion       <---    PK: id_bitacora
									 FK: id_proposicion
										 estado_anterior
										 estado_nuevo
										 fecha_cambio
										 id_usuario_accion
										 
										 
	## 5. Control de Acceso Basado en Roles (RBAC)
	### Definición
	Mecanismo de seguridad que restringe el acceso a los datos y operaciones basándose en los roles asignados a los usuarios individuales, separando la identidad de la autorización.

	### Uso
	Requisito directo para el "Security Lab". Facilita la creación de políticas de seguridad a nivel de fila (Row-Level Security) y la gestión de permisos para ejecutar Stored Procedures, permitiendo diferenciar entre jugadores estándar, administradores u otros perfiles.
	
	### Estructura
	
	[Jugador]               [Jugador_Rol] (Puente)         [Rol]
	---------               ----------------------         -----
	PK: id_jugador  <---    FK: id_jugador           /---> PK: id_rol
							FK: id_rol    <---------/          nombre_rol
							

