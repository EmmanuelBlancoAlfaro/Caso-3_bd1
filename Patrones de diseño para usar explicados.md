# Arquitectura de Datos: Patrones de Diseño Seleccionados

Este documento detalla los 8 patrones de diseño estructurales que fundamentan el modelo de base de datos transaccional, garantizando concurrencia, seguridad y trazabilidad.

---

	## 1. Patrón de Libro Mayor (Ledger / Append-Only)

		### 1. Qué problema soluciona

		Imagina un sistema financiero o de billeteras virtuales sin este patrón:
		- Haces un UPDATE a una fila para sumar o restar saldo.
		- Dos procesos intentan actualizar el mismo saldo al mismo tiempo: ocurre un *deadlock* (bloqueo) o una condición de carrera (se pierde dinero).
		- Un cliente pregunta: "¿Por qué mi saldo es $50 si ayer tenía $100?". Si solo guardas el saldo actual, no tienes cómo responderle.
		- No hay auditoría contable. Si ocurre un error, el estado anterior desaparece para siempre.

		**El patrón resuelve:** Reemplazar las actualizaciones mutables (UPDATE) por un registro histórico inmutable (INSERT). El saldo final es simplemente la suma matemática de todas las transacciones previas.

		---

		### 2. Cuándo usarlo

		**Úsalo siempre en:**
		- Sistemas financieros, bancarios y billeteras virtuales (como los *puntos* y *dinero real* en Gathel).
		- Control de inventarios estrictos (donde necesitas saber exactamente cuándo entró y salió mercancía).
		- Sistemas de auditoría crítica donde la inmutabilidad es un requisito legal o de negocio.
		- Escenarios de alta concurrencia de escritura sobre una misma "cuenta".

		**No lo uses si:**
		- Solo necesitas guardar el último estado de algo trivial (ej. la "última fecha de login" de un usuario).
		- El costo de almacenamiento es una restricción extrema y la auditoría no importa.


		### 3. Errores comunes

		| Error | Qué pasa | Por qué está mal |
		|-------|----------|------------------|
		| **Permitir `UPDATE` o `DELETE`** | Se pierde la inmutabilidad | El principio básico del Ledger es que es **Append-Only** (Solo inserción). Si un registro está mal, se hace una "Compensación". |
		| **No incluir una Referencia Cruzada** | Tienes un descuento de $10, pero no sabes por qué | Cada movimiento debe estar atado al evento que lo originó (ej. `proposicionid` o `facturaid`). |
		| **No usar transacciones SQL (`BEGIN TRAN`)** | Inconsistencia de datos | Si insertas el retiro de dinero, pero falla la inserción de la apuesta en el sistema, el usuario pierde el dinero a cambio de nada. |
		| **Usar tipos flotantes (`FLOAT` o `REAL`)** | Pérdida de precisión centesimal | El dinero y los puntos deben guardarse siempre en tipos numéricos exactos como `DECIMAL(19,4)` o `NUMERIC`. |


		### 4. Diagrama ER (Entity-Relationship)

			┌─────────────────────────────────────────────────────────────────┐
			│                          JUGADORES                              │
			├─────────────────────────────────────────────────────────────────┤
			│ PK  jugadorid (INT)                                             │
			│     alias (VARCHAR)                                             │
			│     email (VARCHAR)                                             │
			└─────────────────────────────────────────────────────────────────┘
						│
						│ 1:1
						↓
			┌─────────────────────────────────────────────────────────────────┐
			│                      JUGADOR_BILLETERA                          │
			├─────────────────────────────────────────────────────────────────┤
			│ PK  billeteraid (INT)                                           │
			│ FK  jugadorid (INT)                                             │
			│     estado_cuenta (VARCHAR)                                     │
			│     fechacreacion (TIMESTAMP)                                   │
			└─────────────────────────────────────────────────────────────────┘
						│
						│ 1:M (Alta transaccionalidad)
						↓
			┌─────────────────────────────────────────────────────────────────┐
			│                   TRANSACCION_LEDGER (Append-Only)              │
			├─────────────────────────────────────────────────────────────────┤
			│ PK  transaccionid (BIGINT)                                      │
			│ FK  billeteraid (INT)                                           │
			│     monto (DECIMAL 19,4)   -- Positivo (Crédito) o Negativo (Débito)
			│     tipo_movimiento (VARCHAR) -- Ej: 'Apuesta', 'Premio', 'Penalizacion'
			│     moneda_tipo (VARCHAR)     -- Ej: 'Puntos', 'USD'
			│     referencia_id (VARCHAR)   -- ID de la proposición o pago externo
			│     fechatransaccion (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)      │
			└─────────────────────────────────────────────────────────────────┘
										 
	## 2. MASTER-DETAIL / CATALOGS-ACTIONS

		### 1. Qué problema soluciona

		Este patron soluciona un problema central en sistemas de negocio: separar datos de referencia estables (catalogos) de eventos transaccionales (acciones).

		Ejemplo clasico:
		- Catalogos: clientes, productos, metodos de pago, estados.
		- Acciones: pedido, factura, pago, devolucion.

		Si mezclas todo en una sola tabla grande:
		- Duplicas datos de catalogo en cada accion.
		- Pierdes integridad.
		- Mantener historico y auditar se vuelve dificil.

		Master-detail organiza el sistema asi:
		- Master (cabecera): una transaccion o documento.
		- Detail (lineas): elementos asociados a esa transaccion.
		- Catalogs-actions: los details apuntan a catalogos por FK.

		---

		### 2. Cuándo usarlo

		Usalo cuando modelas procesos como:
		- Ventas (pedido + lineas de pedido).
		- Compras (orden de compra + lineas).
		- Facturacion (factura + items).
		- Inventario (movimiento + detalle de productos).
		- Cualquier flujo donde una operacion agrupa multiples elementos.

		No lo uses cuando:
		- El proceso no tiene cabecera/detalle real.
		- Solo necesitas una entidad simple sin lineas asociadas.

		---

		### 3. Aporte al diseño

		Sin patron (mal diseño):
		- Tabla unica con columnas repetidas de cliente, producto, precio, estado.
		- Si el pedido tiene 5 productos, repites 5 veces los datos del cliente.

		Con patron (buen diseño):
		- `pedido` (master) guarda contexto general de la transaccion.
		- `pedido_detalle` (detail) guarda cada item.
		- `productos`, `clientes`, `estados_pedido`, `metodos_pago` son catalogos reutilizables.

		Resultado:
		- Menos duplicidad.
		- Mejor integridad.
		- Consultas mas claras.
		- Evolucion del sistema mas limpia.

		Diagrama detallado del patron

		```text
		CATALOGOS (estables)                         ACCIONES (crecimiento alto)

		┌───────────────────────────┐
		│         CLIENTES          │
		├───────────────────────────┤
		│ PK  clienteid             │
		│     nombre                │
		│     email                 │
		└───────────────────────────┘
					 │ 1
					 │
					 │ N
		┌───────────────────────────┐      1      ┌────────────────────────────┐      N      ┌────────────────────────────┐
		│      ESTADOS_PEDIDO       │────────────▶│           PEDIDO            │────────────▶│       PEDIDO_DETALLE        │
		├───────────────────────────┤             ├────────────────────────────┤             ├────────────────────────────┤
		│ PK  estadoid              │             │ PK  pedidoid                │             │ PK  pedidodetalleid         │
		│ UQ  codigo                │             │ FK  clienteid               │             │ FK  pedidoid                │
		│     nombre                │             │ FK  estadoid                │             │ FK  productoid              │
		└───────────────────────────┘             │ FK  metodopagoid            │             │     cantidad                │
												  │     fechapedido             │             │     precio_unitario         │
		┌───────────────────────────┐             │     total                   │             │     subtotal                │
		│      METODOS_PAGO         │────────────▶│     creado_por              │             └────────────────────────────┘
		├───────────────────────────┤      1      └────────────────────────────┘                           │ N
		│ PK  metodopagoid          │                                                                         │
		│ UQ  codigo                │                                                                         │ 1
		│     nombre                │                                                          ┌───────────────────────────┐
		└───────────────────────────┘                                                          │         PRODUCTOS         │
																							   ├───────────────────────────┤
																							   │ PK  productoid            │
																							   │ UQ  sku                   │
																							   │     nombre                │
																							   │     precio_lista          │
																							   └───────────────────────────┘

		Lectura del patron:
		1) CATALOGOS definen valores autorizados y reutilizables.
		2) PEDIDO (master) representa una transaccion.
		3) PEDIDO_DETALLE (detail) representa cada item de esa transaccion.
		4) DETAIL referencia catalogos (productos) y mantiene valores historicos (precio_unitario).
		```

										 
										 
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
										 
										 
	## 5. USER PERMISSIONS (Control de Acceso Basado en Roles - RBAC)

		### 1. Qué problema soluciona

		Imagina un sistema sin este patrón:
		- Usuarios sin columnas de permisos (¿"admin"? ¿"can_edit"? ¿"can_delete"?).
		- Si cambias políticas, editas 1000 registros.
		- No sabes quién dio qué permiso, ni cuándo.
		- Escalar a 100 tipos de permiso es un caos.

		**El patrón resuelve:** Separar usuarios, roles y permisos en tablas independientes, para poder combinarlos de forma flexible sin duplicar datos.

		---

		### 2. Cuándo usarlo

		**Usalo siempre** en:
		- Apps SaaS (múltiples usuarios, múltiples niveles de acceso).
		- Sistemas administrativos (backoffice, panel de control).
		- Plataformas colaborativas (equipos, departamentos).
		- Cualquier cosa que tenga más de 1 usuario.

		**No lo hagas si:**
		- Tu sistema es monousuario (pero eso es muy raro hoy).

		---

		### 3. Aporte al diseño

		**Sin patrón (Mal diseño):**
		```
		usuarios
		├── usuarioid
		├── nombre
		├── es_admin (boolean)           ← Para 1 nivel = OK
		├── puede_editar (boolean)
		├── puede_borrar (boolean)
		├── puede_comentar (boolean)
		├── puede_ver_reportes (boolean)
		└── ... (columnas a infinito)    ← ESCALA MAL
		```

		**Problema:** Cada nuevo permiso = nueva columna. A los 50 permisos, la tabla explota.

		**Con RBAC (Buen diseño):**
		```
		usuarios                  rolesdeusuario        permisos
		├── usuarioid            ├── roleid            ├── permisoid
		└── nombre               ├── nombre            ├── nombre
								 └── descripcion       └── descripcion

				↓ Tablas puente (Many-to-Many) ↓

		usuariosxrole (M:M)       permisoxrole (M:M)
		├── usuarioid            ├── permisoid
		├── roleid               ├── roleid
		└── fechaasignacion      └── fechaasignacion

		permisosxusuario (M:M, opcional)
		├── usuarioid
		├── permisoid
		└── fechaasignacion
		```

		**Ventaja:** Los permisos son **enumerables** y **reutilizables**. Cambias la política modificando *relaciones*, no *esquema*.
		
	# 6. PATRÓN: TRANSACTIONS / MOVEMENTS

		### 1. Qué problema soluciona

		Este patron modela cambios de estado como eventos inmutables.

		Problema real que evita:
		- Sobreescribir un valor final (por ejemplo stock = 25) sin saber como llego ahi.
		- No poder auditar errores ni reconstruir historia.

		Idea central:
		- El estado actual se calcula o se valida usando movimientos.
		- Nunca se pierde el rastro de entradas, salidas, ajustes o transferencias.

		### 2. Cuándo usarlo

		Usalo cuando hay "flujo" de cantidades o dinero:
		1. Inventario (entradas/salidas/ajustes/traslados).
		2. Cuentas financieras (creditos/debitos).
		3. Puntos de fidelidad.
		4. Consumos de cuota o licencias.

		### 3. Aporte al diseño

		1. Evita inconsistencias por updates directos al saldo.
		2. Permite trazabilidad completa por documento origen.
		3. Se integra bien con auditoria y conciliacion.

		### 4. Problemas comunes que soluciona

		1. "No me cuadra el stock" -> puedes reconstruir secuencia de movimientos.
		2. "No se quien hizo el ajuste" -> guardas usuario, fecha y referencia.
		3. "No puedo revertir" -> agregas un movimiento inverso.

		### 5. Diagrama detallado


		┌────────────────────────────┐        1:N        ┌────────────────────────────┐
		│       BODEGA_PRODUCTO      │──────────────────▶│      MOV_INV_CABECERA      │
		├────────────────────────────┤                   ├────────────────────────────┤
		│ PK bodegaproductoid        │                   │ PK movid                   │
		│ FK bodegaid                │                   │ FK tipomovid               │
		│ FK productoid              │                   │    fecha                   │
		│    stock_actual            │                   │    tipodoc                 │
		└────────────────────────────┘                   │    docid                   │
														 │    creado_por              │
		┌────────────────────────────┐                   └────────────────────────────┘
		│      TIPO_MOVIMIENTO       │                              │ 1:N
		├────────────────────────────┤                              ▼
		│ PK tipomovid               │                   ┌────────────────────────────┐
		│ UQ codigo (ENT/SAL/AJ)     │                   │      MOV_INV_DETALLE       │
		│    afecta_signo (+/-)      │                   ├────────────────────────────┤
		└────────────────────────────┘                   │ PK movdetalleid            │
														 │ FK movid                   │
														 │ FK productoid              │
														 │    cantidad                │
														 │    costo_unitario          │
														 └────────────────────────────┘
														 
														 
	# 7. PATRÓN: BALANCES

		### 1. Qué problema soluciona

		Permite tener lectura rapida del saldo actual sin perder exactitud historica.

		Modelo recomendado:
		1. Ledger (movimientos) = fuente de verdad.
		2. Balance materializado = lectura rapida.

		### 2. Cuándo usarlo

		1. Wallets o cuentas.
		2. Saldos de inventario por bodega.
		3. Puntos de usuario.
		4. Cualquier pantalla que exija "saldo ahora" en milisegundos.

		### 3. Problemas comunes que soluciona

		1. Consultas lentas por sumatorias grandes.
		2. Inconsistencias por actualizar saldo en varios puntos de la app.
		3. Falta de prueba forense de como se obtuvo un saldo.

		### 4. Diagrama detallado

		┌────────────────────────────┐        1:N        ┌────────────────────────────┐
		│          CUENTAS           │──────────────────▶│      CUENTA_MOVIMIENTO     │
		├────────────────────────────┤                   ├────────────────────────────┤
		│ PK cuentaid                │                   │ PK movid                   │
		│    titular                 │                   │ FK cuentaid                │
		│    estado                  │                   │    fecha                   │
		└────────────────────────────┘                   │    tipo (CRED/DEB/AJ)      │
														 │    monto                   │
														 │    referencia              │
														 └────────────────────────────┘
																	  │
																	  │ recalculo/actualizacion
																	  ▼
														 ┌────────────────────────────┐
														 │       CUENTA_BALANCE       │
														 ├────────────────────────────┤
														 │ PK/FK cuentaid             │
														 │    saldo_actual            │
														 │    fecha_actualizacion     │
														 └────────────────────────────┘
														 

	# 8. LOGS

		### 1. Qué problema soluciona

		Provee evidencia de eventos del sistema para seguridad, auditoria y diagnostico.

		### 2. Cuándo usarlo

		Siempre. En particular si tienes:
		1. Login/autorizacion.
		2. Operaciones sensibles.
		3. Integraciones externas.
		4. Requisitos de compliance.

		### 3. Problemas comunes que soluciona

		1. "No sabemos que paso en produccion".
		2. "No hay evidencia de quien ejecuto accion critica".
		3. "No podemos correlacionar errores entre servicios".


		### 4. Diagrama detallado

		```text
		┌────────────────────────────┐         1:N        ┌──────────────────────────────────────────────┐
		│          USUARIOS          │───────────────────▶│                    APP_LOG                   │
		├────────────────────────────┤                    ├──────────────────────────────────────────────┤
		│ PK usuarioid               │                    │ PK logid                                     │
		│    email                   │                    │ FK usuarioid (nullable)                      │
		└────────────────────────────┘                    │    nivel (INFO/WARN/ERROR/SECURITY)          │
														  │    modulo                                    │
														  │    accion                                    │
														  │    entidad                                   │
														  │    entidadid                                 │
														  │    traceid                                   │
														  │    payload_json                              │
														  │    ip                                        │
														  │    fechaevento                               │
														  └──────────────────────────────────────────────┘
```

	# 9. CURRENT AND HISTORICAL

		### 1. Qué problema soluciona

		Permite tener dos vistas del mismo dato:
		1. Estado actual (rapido para operacion diaria).
		2. Historial completo (auditoria y analitica temporal).

		### 2. Cuándo usarlo

		1. Cuando debes responder "como estaba esto en fecha X".
		2. Cuando hay cambios frecuentes en atributos clave.
		3. Cuando hay requerimientos legales de trazabilidad.

		### 3. Problemas comunes que soluciona

		1. No poder reconstruir estado pasado.
		2. No saber quien cambio un dato sensible.
		3. Reportes inconsistentes entre periodos.

		### 4. Diagrama detallado

		```text
		┌────────────────────────────┐         1:N        ┌────────────────────────────┐
		│       CLIENTE_CURRENT      │───────────────────▶│    CLIENTE_HISTORICAL      │
		├────────────────────────────┤                    ├────────────────────────────┤
		│ PK clienteid               │                    │ PK historialid             │
		│    nombre_actual           │                    │ FK clienteid               │
		│    categoria_actual        │                    │    nombre                  │
		│    updated_at              │                    │    categoria               │
		│    updated_by              │                    │    valido_desde            │
		└────────────────────────────┘                    │    valido_hasta            │
														  │    cambiado_por            │
														  └────────────────────────────┘
		```