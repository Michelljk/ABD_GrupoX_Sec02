USE [master];
GO

IF EXISTS (SELECT * FROM sys.server_audit_specifications WHERE name = 'ServerAudit_GIMNASIO_BD')
    ALTER SERVER AUDIT SPECIFICATION ServerAudit_GIMNASIO_BD WITH (STATE = OFF);


IF EXISTS (SELECT * FROM sys.server_audit_specifications WHERE name = 'ServerAudit_GIMNASIO_BD')
    DROP SERVER AUDIT SPECIFICATION ServerAudit_GIMNASIO_BD;


IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Audit_GIMNASIO_BD')
    ALTER SERVER AUDIT Audit_GIMNASIO_BD WITH (STATE = OFF);


IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Audit_GIMNASIO_BD')
    DROP SERVER AUDIT Audit_GIMNASIO_BD;


CREATE SERVER AUDIT Audit_GIMNASIO_BD
TO FILE 
(
    FILEPATH = 'C:\SQL_Audit\',
    MAXSIZE = 100 MB,
    MAX_ROLLOVER_FILES = 5,
    RESERVE_DISK_SPACE = OFF
)
WITH
(
    ON_FAILURE = CONTINUE,
    QUEUE_DELAY = 1000
);


ALTER SERVER AUDIT Audit_GIMNASIO_BD WITH (STATE = ON);


CREATE SERVER AUDIT SPECIFICATION ServerAudit_GIMNASIO_BD
FOR SERVER AUDIT Audit_GIMNASIO_BD
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (LOGOUT_GROUP),
ADD (SERVER_PRINCIPAL_CHANGE_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (BACKUP_RESTORE_GROUP)
WITH (STATE = ON);


USE [GIMNASIO_BD];
GO

IF EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'DBAudit_GIMNASIO_BD')
    ALTER DATABASE AUDIT SPECIFICATION DBAudit_GIMNASIO_BD WITH (STATE = OFF);


IF EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'DBAudit_GIMNASIO_BD')
    DROP DATABASE AUDIT SPECIFICATION DBAudit_GIMNASIO_BD;


CREATE DATABASE AUDIT SPECIFICATION DBAudit_GIMNASIO_BD
FOR SERVER AUDIT Audit_GIMNASIO_BD
ADD (DATABASE_OBJECT_CHANGE_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (SELECT ON SCHEMA::[Administracion] BY [PUBLIC]),
ADD (INSERT ON SCHEMA::[Administracion] BY [PUBLIC]),
ADD (UPDATE ON SCHEMA::[Administracion] BY [PUBLIC]),
ADD (DELETE ON SCHEMA::[Administracion] BY [PUBLIC]),
ADD (SELECT ON SCHEMA::[Contabilidad] BY [PUBLIC]),
ADD (INSERT ON SCHEMA::[Contabilidad] BY [PUBLIC]),
ADD (UPDATE ON SCHEMA::[Contabilidad] BY [PUBLIC]),
ADD (DELETE ON SCHEMA::[Contabilidad] BY [PUBLIC]),
ADD (SELECT ON SCHEMA::[Reportes] BY [PUBLIC])
WITH (STATE = ON);


IF OBJECT_ID('dbo.V_Auditoria_Eventos_Criticos', 'V') IS NOT NULL
    DROP VIEW dbo.V_Auditoria_Eventos_Criticos;
    GO

CREATE VIEW dbo.V_Auditoria_Eventos_Criticos
AS
SELECT
    event_time AS [Fecha/Hora Evento],
    session_server_principal_name AS [Usuario (Login)],
    server_principal_name AS [Usuario (DB)],
    action_id AS [Tipo Accion],
    CASE 
        WHEN action_id = 'LGIS' THEN 'Login Exitoso'
        WHEN action_id = 'LGIF' THEN 'Login Fallido'
        WHEN action_id = 'LGO' THEN 'Logout'
        WHEN action_id = 'SL' THEN 'SELECT'
        WHEN action_id = 'IN' THEN 'INSERT'
        WHEN action_id = 'UP' THEN 'UPDATE'
        WHEN action_id = 'DL' THEN 'DELETE'
        WHEN action_id = 'CR' THEN 'CREATE'
        WHEN action_id = 'AL' THEN 'ALTER'
        WHEN action_id = 'DR' THEN 'DROP'
        WHEN action_id = 'EX' THEN 'EXECUTE'
        WHEN action_id = 'DBRM' THEN 'Cambio en Rol'
        WHEN action_id = 'DBPE' THEN 'Cambio en Permiso'
        ELSE action_id
    END AS [Descripcion Accion],
    succeeded AS [exito (1=Si, 0=No)],
    database_name AS [Base de Datos],
    schema_name AS [Esquema],
    object_name AS [Objeto Afectado],
    statement AS [Sentencia SQL Ejecutada],
    client_ip AS [Direccion IP],
    application_name AS [Aplicacion],
    host_name AS [Host]
FROM sys.fn_get_audit_file('C:\SQL_Audit\Audit_GIMNASIO_BD*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = 'GIMNASIO_BD' OR action_id IN ('LGIS', 'LGIF', 'LGO');
GO

IF OBJECT_ID('dbo.V_Auditoria_Logins', 'V') IS NOT NULL
    DROP VIEW dbo.V_Auditoria_Logins;
GO

CREATE VIEW dbo.V_Auditoria_Logins
AS
SELECT
    event_time AS [Fecha/Hora],
    CASE 
        WHEN action_id = 'LGIS' THEN 'Login Exitoso'
        WHEN action_id = 'LGIF' THEN 'Login Fallido'
        WHEN action_id = 'LGO' THEN 'Logout'
    END AS [Tipo Evento],
    server_principal_name AS [Usuario],
    database_name AS [Base de Datos],
    client_ip AS [IP],
    application_name AS [Aplicacion],
    host_name AS [Host],
    succeeded AS [Exitoso]
FROM sys.fn_get_audit_file('C:\SQL_Audit\Audit_GIMNASIO_BD*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id IN ('LGIS', 'LGIF', 'LGO');
GO

IF OBJECT_ID('dbo.V_Auditoria_DML', 'V') IS NOT NULL
    DROP VIEW dbo.V_Auditoria_DML;
GO

CREATE VIEW dbo.V_Auditoria_DML
AS
SELECT
    event_time AS [Fecha/Hora],
    CASE 
        WHEN action_id = 'SL' THEN 'SELECT'
        WHEN action_id = 'IN' THEN 'INSERT'
        WHEN action_id = 'UP' THEN 'UPDATE'
        WHEN action_id = 'DL' THEN 'DELETE'
    END AS [Operacion],
    server_principal_name AS [Usuario],
    database_principal_name AS [Usuario BD],
    schema_name AS [Esquema],
    object_name AS [Tabla],
    statement AS [Sentencia SQL],
    client_ip AS [IP],
    application_name AS [Aplicacion],
    succeeded AS [Exitoso]
FROM sys.fn_get_audit_file('C:\SQL_Audit\Audit_GIMNASIO_BD*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = 'GIMNASIO_BD'
    AND action_id IN ('SL', 'IN', 'UP', 'DL');
GO

IF OBJECT_ID('dbo.V_Auditoria_Pagos', 'V') IS NOT NULL
    DROP VIEW dbo.V_Auditoria_Pagos;
GO

CREATE VIEW dbo.V_Auditoria_Pagos
AS
SELECT
    event_time AS [Fecha/Hora],
    CASE 
        WHEN action_id = 'SL' THEN 'SELECT'
        WHEN action_id = 'IN' THEN 'INSERT'
        WHEN action_id = 'UP' THEN 'UPDATE'
        WHEN action_id = 'DL' THEN 'DELETE'
    END AS [Operacion],
    server_principal_name AS [Usuario],
    database_principal_name AS [Usuario BD],
    statement AS [Sentencia SQL],
    client_ip AS [IP],
    application_name AS [Aplicacion],
    succeeded AS [Exitoso]
FROM sys.fn_get_audit_file('C:\SQL_Audit\Audit_GIMNASIO_BD*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = 'GIMNASIO_BD'
    AND schema_name = 'Contabilidad'
    AND object_name = 'PAGOS'
    AND action_id IN ('SL', 'IN', 'UP', 'DL');
GO

IF OBJECT_ID('dbo.V_Auditoria_Cambios_Seguridad', 'V') IS NOT NULL
    DROP VIEW dbo.V_Auditoria_Cambios_Seguridad;
GO

CREATE VIEW dbo.V_Auditoria_Cambios_Seguridad
AS
SELECT
    event_time AS [Fecha/Hora],
    CASE 
        WHEN action_id = 'DBRM' THEN 'Cambio en Rol de BD'
        WHEN action_id = 'DBPE' THEN 'Cambio en Permiso de BD'
        WHEN action_id = 'DBPR' THEN 'Cambio en Principal de BD'
        WHEN action_id = 'SVRM' THEN 'Cambio en Rol de Servidor'
        WHEN action_id = 'SL' THEN 'Cambio en Login'
    END AS [Tipo Cambio],
    server_principal_name AS [Usuario Ejecutor],
    database_principal_name AS [Usuario Afectado],
    object_name AS [Objeto],
    statement AS [Sentencia SQL],
    succeeded AS [Exitoso]
FROM sys.fn_get_audit_file('C:\SQL_Audit\Audit_GIMNASIO_BD*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id IN ('DBRM', 'DBPE', 'DBPR', 'SVRM', 'SL');
GO

GRANT SELECT ON dbo.V_Auditoria_Eventos_Criticos TO rol_administrador;
GRANT SELECT ON dbo.V_Auditoria_Logins TO rol_administrador;
GRANT SELECT ON dbo.V_Auditoria_DML TO rol_administrador;
GRANT SELECT ON dbo.V_Auditoria_Pagos TO rol_administrador;
GRANT SELECT ON dbo.V_Auditoria_Cambios_Seguridad TO rol_administrador;
GO

GRANT SELECT ON dbo.V_Auditoria_Logins TO rol_subadministrador;
GRANT SELECT ON dbo.V_Auditoria_DML TO rol_subadministrador;
GRANT SELECT ON dbo.V_Auditoria_Pagos TO rol_subadministrador;
GO

SELECT TOP 10 [Fecha/Hora Evento], [Usuario (Login)], [Descripcion Accion], [Objeto Afectado], [Sentencia SQL Ejecutada]
FROM dbo.V_Auditoria_Eventos_Criticos
ORDER BY [Fecha/Hora Evento] DESC

SELECT TOP 5 [Fecha/Hora], Operacion, [Usuario BD], Tabla, [Sentencia SQL] 
FROM V_Auditoria_DML 
ORDER BY [Fecha/Hora] DESC;
