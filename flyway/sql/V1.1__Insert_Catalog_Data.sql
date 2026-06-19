-- V1.1 - Datos de catalogo iniciales

USE GathelDB;
GO

-- PAISES
INSERT INTO Countries (isoCode, countryName) VALUES
('CRI', 'Costa Rica'),
('USA', 'Estados Unidos'),
('MEX', 'Mexico'),
('COL', 'Colombia'),
('ARG', 'Argentina'),
('ESP', 'Espana'),
('CHL', 'Chile'),
('BRA', 'Brasil'),
('PAN', 'Panama'),
('GTM', 'Guatemala');
GO

-- ESTADOS (algunos paises principales)
INSERT INTO States (countryId, stateName) VALUES
(1, 'San Jose'),
(1, 'Alajuela'),
(1, 'Cartago'),
(1, 'Heredia'),
(1, 'Guanacaste'),
(1, 'Puntarenas'),
(1, 'Limon'),
(2, 'California'),
(2, 'Texas'),
(2, 'Florida'),
(2, 'New York'),
(3, 'Ciudad de Mexico'),
(3, 'Jalisco'),
(3, 'Nuevo Leon'),
(4, 'Cundinamarca'),
(4, 'Antioquia');
GO

-- CIUDADES
INSERT INTO Cities (stateId, cityName) VALUES
(1, 'San Jose'),
(1, 'Desamparados'),
(1, 'Alajuelita'),
(2, 'Alajuela'),
(2, 'San Ramon'),
(3, 'Cartago'),
(4, 'Heredia'),
(4, 'Santo Domingo'),
(5, 'Liberia'),
(8, 'Los Angeles'),
(8, 'San Francisco'),
(9, 'Houston'),
(9, 'Dallas'),
(10, 'Miami'),
(11, 'New York City'),
(12, 'Ciudad de Mexico'),
(15, 'Bogota'),
(16, 'Medellin');
GO

-- ROLES
INSERT INTO Roles (roleName, description) VALUES
('Admin',      'Administrador con acceso total al sistema'),
('Moderator',  'Modera proposiciones y contenido de la plataforma'),
('Player',     'Jugador estandar de la plataforma');
GO

-- PERMISOS
INSERT INTO Permissions (permissionName, description) VALUES
('manage_users',        'Crear, editar y desactivar usuarios'),
('manage_roles',        'Asignar y revocar roles'),
('manage_config',       'Editar configuraciones del sistema'),
('moderate_content',    'Aprobar o rechazar proposiciones y predicciones'),
('view_all_logs',       'Ver todos los logs del sistema'),
('create_proposition',  'Crear proposiciones'),
('make_prediction',     'Realizar predicciones'),
('manage_wallet',       'Depositar y retirar fondos'),
('view_results',        'Ver resultados de proposiciones'),
('reject_proposition',  'Rechazar proposiciones sobre si mismo');
GO

-- PERMISOS POR ROL
-- Admin: todos los permisos
INSERT INTO PermissionsPerRoles (roleId, permissionId) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(1, 6), (1, 7), (1, 8), (1, 9), (1, 10);
GO

-- Moderador
INSERT INTO PermissionsPerRoles (roleId, permissionId) VALUES
(2, 4), (2, 5), (2, 9);
GO

-- Jugador
INSERT INTO PermissionsPerRoles (roleId, permissionId) VALUES
(3, 6), (3, 7), (3, 8), (3, 9), (3, 10);
GO

-- MONEDAS
INSERT INTO Currencies (currencySymbol, currencyName, isVirtual) VALUES
('PTS',  'Puntos Gathel', 1),
('USD',  'Dolar Americano', 0),
('EUR',  'Euro', 0),
('CRC',  'Colon Costarricense', 0),
('MXN',  'Peso Mexicano', 0),
('COP',  'Peso Colombiano', 0);
GO

-- TIPOS DE CONTACTO
INSERT INTO ContactTypes (contactTypeName) VALUES
('Email'),
('Telefono'),
('Instagram'),
('TikTok'),
('Twitter'),
('YouTube');
GO

-- ESTADOS DE PROPOSICION
INSERT INTO PropositionStates (propositionStateName, allowsPredictions) VALUES
('Pendiente',   0),  -- creada, esperando votacion
('Activa',      1),  -- aceptada por el target, recibe predicciones
('Cerrada',     0),  -- periodo de predicciones terminado
('Resuelta',    0),  -- resultado determinado
('Cancelada',   0),  -- rechazada o imposible de validar
('En disputa',  0);  -- resultado ambiguo, requiere revision
GO

-- TIPOS DE RESULTADO DE PROPOSICION
INSERT INTO PropositionsResultsTypes (resultTypeName) VALUES
('Cumplida'),
('No cumplida'),
('Inconclusiva'),
('Cancelada');
GO

-- ESTADOS DE PREDICCION
INSERT INTO PredictionStates (predictionStateName) VALUES
('Activa'),
('Ganada'),
('Perdida'),
('Reembolsada'),
('Cancelada');
GO

-- PLATAFORMAS SOCIALES
INSERT INTO SocialPlatforms (platformName) VALUES
('Instagram'),
('TikTok'),
('Twitter'),
('YouTube'),
('Facebook'),
('Twitch');
GO

-- TIPOS DE RECURSO SOCIAL
INSERT INTO SocialResourceTypes (resourceTypeName) VALUES
('Post'),
('Video'),
('Story'),
('Reel'),
('Live'),
('Comentario');
GO

-- PROVEEDORES DE IA
INSERT INTO AIProviders (providerName) VALUES
('OpenAI'),
('Google'),
('Anthropic');
GO

-- MODELOS DE IA
INSERT INTO AIModels (providerId, modelName, modelVersion) VALUES
(1, 'gpt-4o',            '2024-08'),
(1, 'gpt-4o-mini',       '2024-07'),
(2, 'gemini-1.5-pro',    '001'),
(2, 'gemini-1.5-flash',  '001'),
(3, 'claude-3-5-sonnet', '20241022'),
(3, 'claude-3-haiku',    '20240307');
GO

-- METODOS DE PAGO
INSERT INTO PaymentMethods (paymentMethodName, apiURL) VALUES
('PayPal',            'https://api.paypal.com/v2'),
('Stripe',            'https://api.stripe.com/v1'),
('Transferencia SINPE', NULL),
('Tarjeta de credito', NULL);
GO

-- METODOS DE PAGO POR PAIS
INSERT INTO PaymentMethodsPerCountry (countryId, paymentMethodId) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),  -- Costa Rica
(2, 1), (2, 2), (2, 4),           -- USA
(3, 1), (3, 2), (3, 4),           -- Mexico
(4, 1), (4, 2), (4, 4),           -- Colombia
(5, 1), (5, 2), (5, 4),           -- Argentina
(6, 1), (6, 2), (6, 4);           -- Espana
GO

-- TIPOS DE MOVIMIENTO
INSERT INTO MovementTypes (movementTypeName, movementTypeDescription) VALUES
('Deposito',            'Ingreso de fondos a la billetera'),
('Retiro',              'Salida de fondos de la billetera'),
('Apuesta',             'Fondos comprometidos en una prediccion'),
('Premio',              'Ganancias recibidas por prediccion correcta'),
('Comision plataforma', 'Comision cobrada por Gathel al resolver una proposicion'),
('Comision creador',    'Comision al jugador que creo la proposicion'),
('Penalizacion',        'Descuento por no poder validar el resultado'),
('Reembolso',           'Devolucion de fondos por proposicion cancelada'),
('Compra de puntos',    'Adquisicion de puntos mediante dinero real'),
('Puntos iniciales',    'Balance inicial otorgado al registrarse');
GO

-- TIPOS DE RESULTADO DE PAGO
INSERT INTO PaymentResultTypes (resultTypeName) VALUES
('Exitoso'),
('Fallido'),
('Pendiente'),
('Cancelado'),
('Reembolsado');
GO

-- SEVERIDADES DE ERROR
INSERT INTO Severities (name, description) VALUES
('Info',     'Informacion general del sistema'),
('Warning',  'Situacion inusual que no interrumpe el flujo'),
('Error',    'Fallo que afecta una operacion especifica'),
('Critical', 'Fallo grave que requiere atencion inmediata');
GO

-- TIPOS DE EVENTO (logs de usuario)
INSERT INTO EventTypes (name, description) VALUES
('Login',                  'Inicio de sesion'),
('Logout',                 'Cierre de sesion'),
('Proposicion creada',     'Usuario creo una proposicion'),
('Proposicion aceptada',   'Target acepto la proposicion'),
('Proposicion rechazada',  'Target rechazo la proposicion'),
('Prediccion realizada',   'Usuario realizo una prediccion'),
('Deposito realizado',     'Usuario deposito fondos'),
('Retiro realizado',       'Usuario retiro fondos'),
('Resultado registrado',   'Se determino el resultado de una proposicion'),
('Evidencia subida',       'Usuario subio evidencia de resultado');
GO

-- OBJETOS DE DATOS (para logs)
INSERT INTO DataObjects (name, description) VALUES
('User',          'Entidad de usuario'),
('Proposition',   'Entidad de proposicion'),
('Prediction',    'Entidad de prediccion'),
('Wallet',        'Billetera del usuario'),
('Transaction',   'Transaccion economica'),
('Session',       'Sesion de usuario'),
('SocialResource','Recurso de red social');
GO

-- TIPOS DE OBJETO DE REFERENCIA
INSERT INTO ReferenceObjectsTypes (objectTypeName) VALUES
('Proposition'),
('Prediction'),
('Wallet'),
('User'),
('Transaction');
GO

-- TIPOS DE OBJETO FUENTE
INSERT INTO SourceObjectsTypes (objectTypeName) VALUES
('User'),
('System'),
('Payment Gateway'),
('AI Agent');
GO

-- TIPOS DE PROCESO IA
INSERT INTO AIProcessTypes (processTypeName) VALUES
('Moderacion de contenido'),
('Validacion de resultado'),
('Deteccion de fraude'),
('Analisis de evidencia');
GO

-- TIPOS DE CONTENIDO IA
INSERT INTO AIContentTypes (contentTypeName) VALUES
('Imagen'),
('Video'),
('Texto'),
('Audio'),
('Multimedia');
GO

-- TIPOS DE FUENTE IA
INSERT INTO SourceTypes (sourceTypeName) VALUES
('Instagram'),
('TikTok'),
('Twitter'),
('YouTube'),
('Manual'),
('Sistema');
GO

-- TIPOS DE RESULTADO IA
INSERT INTO AIResultTypes (resultTypeName) VALUES
('Aprobado'),
('Rechazado'),
('Inconclusivo'),
('Error de procesamiento');
GO

-- TIPOS DE URL
INSERT INTO URLTypes (urlTypeName) VALUES
('Red social'),
('Evidencia'),
('Perfil de usuario'),
('Contenido multimedia');
GO

-- CONFIGURACIONES DEL SISTEMA
INSERT INTO SystemConfigurations (configKey, configValue, description) VALUES
('initial_points',           '100',   'Puntos otorgados al registrarse'),
('max_points_per_prediction','1',     'Maximo de puntos apostables por prediccion'),
('platform_commission_pct',  '0.05',  'Porcentaje de comision de la plataforma (5%)'),
('creator_commission_pct',   '0.03',  'Porcentaje de comision para el creador (3%)'),
('penalty_pct',              '0.15',  'Porcentaje de penalizacion por no validar (15%)'),
('prediction_window_hours',  '24',    'Horas disponibles para realizar predicciones'),
('voting_window_hours',      '24',    'Horas para votar la proposicion ganadora'),
('min_deposit_usd',          '5',     'Deposito minimo en USD'),
('max_withdrawal_usd',       '10000', 'Retiro maximo diario en USD');
GO
