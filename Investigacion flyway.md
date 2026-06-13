## Que es y que hace?
Flyway es una herramienta pensada para solucionar el problema del "control de versiones" en bases de datos. En el software tradicional, Git se encarga de registrar los cambios del código; Flyway hace lo mismo con el esquema de datos (tablas, vistas, procedimientos).

Al ejecutarse en tu servidor SQL Server, Flyway busca una tabla de metadatos exclusiva llamada flyway_schema_history.
    1. Si no existe, la crea de inmediato.
    2. Escanea tu directorio local buscando scripts de migración.
    3. Compara el historial registrado con tus archivos locales para identificar cuáles son "nuevos" o "pendientes".
    4. Los ejecuta cronológicamente y guarda un hash (firma única) de cada script en la tabla para garantizar la inmutabilidad del código aplicado.

## Como se instala?
Para SQL Server, el método más limpio e independiente de plataformas (como Java o .NET) es la Interfaz de Línea de Comandos (CLI).
    1. Descarga: Se obtiene el paquete nativo comprimido en .zip para tu sistema operativo desde el portal de descargas oficial.
    2. Descompresión: Se extrae en una ruta local fija, por ejemplo, C:\flyway.
    3. Variable de Entorno: Se añade dicha ruta al PATH del sistema de Windows para habilitar el comando global flyway.
    4. Dependencias: Las versiones modernas de la CLI de Flyway ya traen embebido el controlador JDBC nativo de Microsoft SQL Server (mssql-jdbc), eliminando la necesidad de buscar librerías externas de conexión.

## Como se configura?
Toda la comunicación entre la herramienta y tu instancia de base de datos se gestiona a través del archivo centralizado flyway.conf. Para conectar Flyway con Microsoft SQL Server de forma segura, se deben estructurar las siguientes variables obligatorias utilizando la sintaxis de cadenas JDBC:
# URL de conexión JDBC para Microsoft SQL Server
flyway.url=jdbc:sqlserver://localhost:1433;databaseName=MiBaseDeDatos;encrypt=true;trustServerCertificate=true

# Credenciales de Autenticación de SQL Server
flyway.user=mi_usuario_sql
flyway.password=mi_super_contraseňa

# Ubicación de los archivos del proyecto
flyway.locations=filesystem:sql

## Como es la estructura de carpetas?
Cuando utilizas la distribución CLI estándar de Flyway, el ciclo de vida del despliegue requiere una arquitectura de directorios muy simple pero estricta. Al descomprimir el entorno, te encontrarás con la siguiente jerarquía operativa:
📂 /conf: Almacena el archivo maestro flyway.conf.
📂 /sql: El repositorio local por defecto donde colocarás todos tus scripts de migración SQL.
📂 /drivers: Carpeta destinada a alojar controladores JDBC de terceros (vacía por defecto en SQL Server, ya que viene preinstalado).
📂 /jars: Espacio reservado para desarrolladores avanzados que prefieren escribir lógica de migración compleja basada en código Java en lugar de scripts SQL planos.

## Versionamiento
Flyway lee los archivos de la carpeta /sql mediante un motor de análisis sintáctico que exige un patrón de nombres muy estricto. Si no lo sigues, Flyway ignorará los scripts de forma silenciosa. El patrón obligatorio es: Prefijo + Versión + Separador + Descripción + .sql
    Prefijos válidos:
        V: Migración Versionada (Avanza la base de datos).
        U: Migración de Deshacer (Undo - Exclusiva de versiones comerciales).
        R: Migración Repetible (Repeatable - Útil para vistas o Stored Procedures que se sobrescriben cada vez que cambian).
    Versión: Números separados por puntos o guiones bajos (1, 1.2, 2026.06.13).
    Separador: Obligatoriamente dos guiones bajos seguidos (__).
    Descripción: Texto explicativo breve separado por guiones bajos.
Ejemplo: V1.2__Crear_tabla_clientes.sql

## Ejecucion de migraciones
El motor se opera mediante comandos explícitos en tu consola. Los más importantes que debes conocer para tus fases de desarrollo y despliegue son:

    flyway info: Imprime en consola un reporte detallado con el estado de todas las migraciones (Cuáles han sido aplicadas con éxito, cuáles están pendientes y cuándo se ejecutaron).

    flyway migrate: Escanea, compila y ejecuta todas las migraciones con prefijo V pendientes en orden secuencial directo hacia tu SQL Server.

    flyway validate: Valida los hashes locales contra los guardados en SQL Server. Si alguien alteró un script que ya se ejecutó en producción, este comando detiene el proceso para evitar inconsistencias.

    flyway baseline: Se usa para introducir Flyway en bases de datos que ya existen y tienen datos en producción. Crea la tabla de historial y marca el estado actual como punto de partida ("línea base"), ignorando los scripts anteriores a esa versión.

    flyway clean: Borra absolutamente todos los objetos (tablas, vistas, índices) del esquema configurado. Este no lo vamos a usar por razones obvias xD 


## Rollback
El manejo de reversión de cambios (rollback) en Flyway depende por completo de la licencia que adquieras:

El comando flyway undo (Licencia Comercial): Permite ejecutar los scripts con prefijo U (ej. U1.2__Eliminar_tabla_clientes.sql) para deshacer la migración homónima de forma automática. Está limitado a las ediciones Teams y Enterprise de Redgate.

Roll-Forward (Licencia Community / Gratuita): En la versión libre, no existe el comando para retroceder de manera automatizada. Siguiendo la filosofía moderna de DevOps de bases de datos, los errores se corrigen yendo hacia adelante. Si la migración V5 rompió algo, la solución consiste en programar un nuevo script V6__Corregir_error_de_V5.sql que altere o devuelva las estructuras a su estado deseado y ejecutar flyway migrate.

## Hallazgos importantes



## Referencias de donde se saco esta informacion
1. https://documentation.red-gate.com/fd/getting-started-with-flyway-184127223.html 
2. https://www.red-gate.com/products/flyway/
3. https://github.com/flyway/flyway/blob/main/documentation/Reference/Commands/Migrate.md
4. https://documentation.red-gate.com/fd/quickstart-command-line-184127576.html 
5. https://documentation.red-gate.com/flyway/reference/configuration
6. https://learn.microsoft.com/en-us/sql/connect/jdbc/setting-the-connection-properties?view=sql-server-ver17 
7. https://www.j-labs.pl/en/tech-blog/flyway-migrations-with-spring/#:~:text=Upon%20migrating%2C%20Flyway%20compares%20the%20content%20of,the%20version%20part%20of%20the%20script%20name. 
8. https://github.com/flyway/flywaydb.org/blob/gh-pages/documentation/concepts/migrations.md 
9. https://www.learnthatstack.com/interview-questions/database_technologies/flyway/explain-flyway-s-naming-convention-for-migration-files-20576 
10. https://documentation.red-gate.com/flyway/reference/commands
11. https://www.red-gate.com/hub/product-learning/flyway/managing-database-changes-using-flyway-an-overview/ -- Esta es la mas importante o la que trae mas informacion en general 