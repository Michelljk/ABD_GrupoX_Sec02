-- creacion de logins --
USE [master];
GO 

IF NOT EXISTS (SELECT *FROM sys.server_principals WHERE name = 'LoginAdminGym')
BEGIN 
CREATE LOGIN [LoginAdminGym] WITH PASSWORD = N'Adminpassword1*', DEFAULT_DATABASE = [GIMNASIO_BD],
CHECK_EXPIRATION = ON, CHECK_POLICY = ON;
END
GO

IF NOT EXISTS (SELECT *FROM sys.server_principals WHERE name = 'LoginSubAdmin')
BEGIN
CREATE LOGIN [LoginSubAdmin] WITH PASSWORD = N'SubAdminPassword2*', DEFAULT_DATABASE = [GIMNASIO_BD],
CHECK_EXPIRATION = ON, CHECK_POLICY = ON;
END 
GO 

IF NOT EXISTS (SELECT *FROM sys.server_principals WHERE name = 'LoginRecepcion')
BEGIN
CREATE LOGIN [LoginRecepcion] WITH PASSWORD = N'Recepcionpassword3*', DEFAULT_DATABASE = [GIMNASIO_BD],
CHECK_EXPIRATION = ON, CHECK_POLICY = ON;
END 
GO 

IF NOT EXISTS (SELECT *FROM sys.server_principals WHERE name = 'LoginEntrenador')
BEGIN
CREATE LOGIN [LoginEntrenador] WITH PASSWORD = N'Entrenadorpassword4*', DEFAULT_DATABASE = [GIMNASIO_BD],
CHECK_EXPIRATION = ON, CHECK_POLICY = ON; 
END
GO 


IF NOT EXISTS (SELECT *FROM sys.server_principals WHERE name = 'LoginLector')
BEGIN
CREATE LOGIN [LoginLector] WITH PASSWORD = N'Lectorpassword*', DEFAULT_DATABASE = [GIMNASIO_BD],
CHECK_EXPIRATION = ON, CHECK_POLICY = ON; 
END 
GO 

USE [GIMNASIO_BD]
GO 

-- rol de administrador --

IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NULL
CREATE ROLE rol_administrador;
GO 
IF NOT EXISTS(SELECT *FROM sys.database_principals WHERE name = 'usuarioAdmin')
CREATE USER [UsuarioAdmin] FOR LOGIN [LoginAdminGym];
GO 
ALTER ROLE rol_administrador ADD MEMBER [UsuarioAdmin];
GO 

-- rol de subadministrador --

IF DATABASE_PRINCIPAL_ID('rol_Subadministrador') IS NULL
CREATE ROLE rol_subadministrador;
GO 
IF NOT EXISTS(SELECT *FROM sys.database_principals WHERE name = 'usuarioSubAdmin')
CREATE USER [UsuarioSubAdmin] FOR LOGIN [LoginSubAdmin];
GO 
ALTER ROLE rol_subadministrador ADD MEMBER [UsuarioSubAdmin];
GO 

-- rol de recepcion --
IF DATABASE_PRINCIPAL_ID('rol_recepcion') IS NULL
CREATE ROLE rol_recepcion;
GO 
IF NOT EXISTS (SELECT *FROM sys.database_principals WHERE name = 'UsuarioRecepcion')
CREATE USER [UsuarioRecepcion] FOR LOGIN [LoginRecepcion];
GO 
ALTER ROLE rol_recepcion ADD MEMBER [UsuarioRecepcion];
GO 

--rol de entrenador --
IF DATABASE_PRINCIPAL_ID('rol_entrenador') IS NULL
CREATE ROLE rol_entrenador;
GO 
IF NOT EXISTS (SELECT *FROM sys.database_principals WHERE name = 'UsuarioEntrenador')
CREATE USER [UsuarioEntrenador] FOR LOGIN [LoginEntrenador];
GO 
ALTER ROLE rol_entrenador ADD MEMBER [UsuarioEntrenador];
GO 

-- rol del lector --
IF DATABASE_PRINCIPAL_ID('rol_lector') IS NULL
CREATE ROLE rol_lector;
GO 
IF NOT EXISTS (SELECT *FROM sys.database_principals WHERE name = 'UsuarioLector')
CREATE USER [UsuarioLector] FOR LOGIN [LoginLector];
GO
ALTER ROLE rol_lector ADD MEMBER [UsuarioLector];
GO 

-- Asignacion de permisos --
GRANT CONTROL TO rol_administrador;
GO 

-- permisos para el rol de subadministrador --
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.ENTRENADORES TO rol_subadministrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.CLASES TO rol_subadministrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.HORARIOS_CLASE TO rol_subadministrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.MEMBRESIAS TO rol_subadministrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.PAGOS TO rol_subadministrador;
GRANT SELECT ON dbo.SOCIOS TO rol_subadministrador;
GRANT SELECT ON dbo.RESERVAS TO rol_subadministrador;


--permisos para el rol de recepcion --
GRANT SELECT, INSERT, UPDATE ON dbo.SOCIOS TO rol_recepcion;
GRANT SELECT, INSERT, UPDATE ON dbo.RESERVAS TO rol_recepcion;
GRANT SELECT, INSERT ON dbo.PAGOS TO rol_recepcion;
GRANT SELECT ON dbo.CLASES TO rol_recepcion;
GRANT SELECT ON dbo.HORARIOS_CLASE TO rol_recepcion;
GRANT SELECT ON dbo.MEMBRESIAS TO rol_recepcion;

DENY DELETE ON dbo.SOCIOS TO rol_recepcion;
DENY DELETE ON dbo.PAGOS TO rol_recepcion;
DENY DELETE ON dbo.RESERVAS TO rol_recepcion;


--permisos para el entrenador --
GRANT SELECT ON dbo.CLASES TO rol_entrenador;
GRANT SELECT ON dbo.HORARIOS_CLASE TO rol_entrenador;
GRANT SELECT ON dbo.RESERVAS TO rol_entrenador;
GRANT SELECT ON dbo.ENTRENADORES TO rol_entrenador;


--permisos para lector --
GRANT SELECT ON dbo.SOCIOS TO rol_lector;
GRANT SELECT ON dbo.ENTRENADORES TO rol_lector;
GRANT SELECT ON dbo.CLASES TO rol_lector;
GRANT SELECT ON dbo.HORARIOS_CLASE TO rol_lector;
GRANT SELECT ON dbo.RESERVAS TO rol_lector;
GRANT SELECT ON dbo.MEMBRESIAS TO rol_lector;
GRANT SELECT ON dbo.PAGOS TO rol_lector;



