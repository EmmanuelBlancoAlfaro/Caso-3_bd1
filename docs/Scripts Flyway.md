# Scripts de migracion Flyway

Este documento explica que hace cada uno de los scripts versionados con Flyway.
Todos viven en la carpeta `flyway/sql` y se aplican en orden con el comando:

```
flyway -configFiles="conf/flyway.conf" migrate
```

La base de datos `GathelDB` debe existir antes de migrar (Flyway no crea la base, solo
trabaja dentro de una existente). Las credenciales y la conexion estan en `flyway/conf/flyway.conf`.

---

## Estructura de carpetas

- `flyway/conf` : archivo de configuracion `flyway.conf` (conexion a SQL Server).
- `flyway/sql` : scripts de migracion. Flyway los detecta por el nombre `V<version>__<descripcion>.sql`.
- `flyway/drivers` : controladores JDBC externos. Vacia, porque el driver de SQL Server ya viene incluido.
- `flyway/jars` : migraciones en Java. No se usa en este proyecto.

---

## V1.0 - Create Schema

Crea todas las tablas de la base de datos a partir del diseno documentado en
[diseno tablas.md](diseño%20tablas.md). Cubre los seis bloques del modelo:

- Usuarios y geografia (paises, estados, ciudades, direcciones, roles, permisos).
- Informacion de contacto.
- Auditoria y configuracion (sesiones, logs, configuraciones, catalogos de IA).
- Motor del juego (proposiciones, opciones, predicciones, recursos sociales).
- Economia y ledger (monedas, billeteras, metodos de pago, intentos, transacciones, balances).

Detalle de implementacion: la columna `updatedBy` de varias tablas apunta a `Users`,
pero esas tablas se crean antes que `Users`. Por eso esas llaves foraneas se agregan
despues con `ALTER TABLE`, una vez que la tabla `Users` ya existe.

## V1.1 - Insert Catalog Data

Inserta los datos de catalogo que el resto del sistema necesita desde el inicio.
Son tablas de referencia, no datos de jugadores. Incluye:

- Paises, estados y ciudades.
- Roles (Admin, Moderator, Player), permisos y su asignacion por rol.
- Monedas (puntos virtuales, USD, EUR, etc.).
- Tipos de contacto, estados de proposicion y de prediccion, tipos de resultado.
- Plataformas y tipos de recurso social.
- Proveedores y modelos de IA, catalogos de procesos de IA.
- Metodos de pago, tipos de movimiento y de resultado de pago.
- Severidades, tipos de evento y objetos para los logs.
- Configuraciones del sistema (puntos iniciales, comisiones, ventanas de tiempo).

Las comisiones y reglas economicas se guardan en `SystemConfigurations` para no dejarlas
fijas en el codigo.

## V2.0 - Seeding

Genera el volumen de datos de prueba que pide el caso, usando bucles y operaciones de
conjunto en lugar de inserts uno por uno. Lo que produce:

- 1 usuario Sistema (userId 1) con su propia billetera. Recibe todas las comisiones de la
  plataforma, en vez de mandarlas a jugadores aleatorios. Demuestra un ledger de doble entrada.
- 1000 jugadores. Cada uno arranca con 100 puntos (regla textual del caso) y luego recibe
  una compra de 4900 puntos para tener liquidez suficiente para apostar sin quedar en negativo.
- 5000 proposiciones con estados variados (pendiente, activa, cerrada, resuelta, cancelada,
  en disputa), cada una con sus dos opciones y su historial de cambios de estado.
- Mas de 250000 predicciones: 55 por cada proposicion que no este en estado Pendiente
  (las pendientes no permiten predicciones). El conteo real ronda las 261000.
- Una retencion en el ledger por cada prediccion: cada apuesta genera su `PaymentAttempt`
  y su `TransactionsLedger`, simulando que se retiene el monto apostado.
- Registros de pago de las proposiciones resueltas: premio al ganador y comision (5%) a la
  billetera del Sistema.
- Sincronizacion final de balances: un `UPDATE` masivo recalcula `currentBalance` de cada
  billetera sumando su historial en `TransactionsLedger`. El signo de cada movimiento se
  determina con un `CASE` (negativo para apuestas, retiros y penalizaciones; positivo para
  el resto), sin modificar el esquema.

Consideraciones que cumple el seeding:

- Integridad referencial: todas las llaves foraneas apuntan a registros validos.
- Consistencia: ningun balance queda negativo y `Balances` refleja exactamente el ledger.
- Timestamps coherentes: las predicciones y pagos ocurren despues de creada su proposicion.
- Generacion variada: estados, topicos, montos y participantes se distribuyen al azar.

---

## Como reaplicar desde cero

Flyway no permite volver a correr un script ya aplicado (compara hashes). Si se modifica un
script ya migrado, hay que recrear la base:

```sql
DROP DATABASE GathelDB;
CREATE DATABASE GathelDB;
```

Y luego volver a ejecutar `flyway migrate`. Esto garantiza que todo el equipo tenga la misma
estructura y los mismos datos iniciales en sus ambientes locales.
