USE GIMNASIO_BD;
GO

-- Crear esquemas
IF SCHEMA_ID('Administracion') IS NULL
    EXEC('CREATE SCHEMA Administracion AUTHORIZATION dbo');


IF SCHEMA_ID('Contabilidad') IS NULL
    EXEC('CREATE SCHEMA Contabilidad AUTHORIZATION dbo');


IF SCHEMA_ID('Reportes') IS NULL
    EXEC('CREATE SCHEMA Reportes AUTHORIZATION dbo');


-- Transferir tablas a esquemas
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SOCIOS' AND schema_id = SCHEMA_ID('dbo'))
    ALTER SCHEMA Administracion TRANSFER dbo.SOCIOS;


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ENTRENADORES' AND schema_id = SCHEMA_ID('dbo'))
    ALTER SCHEMA Administracion TRANSFER dbo.ENTRENADORES;


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CLASES' AND schema_id = SCHEMA_ID('dbo'))
    ALTER SCHEMA Administracion TRANSFER dbo.CLASES;


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'HORARIOS_CLASE' AND schema_id = SCHEMA_ID('dbo'))
    ALTER SCHEMA Administracion TRANSFER dbo.HORARIOS_CLASE;


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RESERVAS' AND schema_id = SCHEMA_ID('dbo'))
    ALTER SCHEMA Administracion TRANSFER dbo.RESERVAS;


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MEMBRESIAS' AND schema_id = SCHEMA_ID('dbo'))
    ALTER SCHEMA Administracion TRANSFER dbo.MEMBRESIAS;


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PAGOS' AND schema_id = SCHEMA_ID('dbo'))
    ALTER SCHEMA Contabilidad TRANSFER dbo.PAGOS;


-- Crear vistas en esquema Reportes
IF OBJECT_ID('Reportes.V_SociosActivos', 'V') IS NOT NULL
    DROP VIEW Reportes.V_SociosActivos;
GO

CREATE VIEW Reportes.V_SociosActivos AS
SELECT 
    SocioID,
    Nombre,
    Apellido,
    Email,
    Telefono,
    FechaRegistro,
    DATEDIFF(YEAR, FechaNacimiento, GETDATE()) AS Edad
FROM Administracion.SOCIOS
WHERE Estado = 1;
GO

IF OBJECT_ID('Reportes.V_IngresosMensuales', 'V') IS NOT NULL
    DROP VIEW Reportes.V_IngresosMensuales;
GO

CREATE VIEW Reportes.V_IngresosMensuales AS
SELECT
    YEAR(FechaPago) AS Anio,
    MONTH(FechaPago) AS Mes,
    COUNT(PagoID) AS TotalPagos,
    SUM(MontoPagado) AS IngresoTotal,
    AVG(MontoPagado) AS PromedioTicket
FROM Contabilidad.PAGOS
GROUP BY YEAR(FechaPago), MONTH(FechaPago);
GO

IF OBJECT_ID('Reportes.V_OcupacionClases', 'V') IS NOT NULL
    DROP VIEW Reportes.V_OcupacionClases;
GO

CREATE VIEW Reportes.V_OcupacionClases AS
SELECT
    c.NombreClase,
    h.DiaSemana,
    h.HoraInicio,
    COUNT(r.ReservaID) AS TotalReservas,
    c.CapacidadMaxima,
    CAST(COUNT(r.ReservaID) * 100.0 / c.CapacidadMaxima AS DECIMAL(5,2)) AS PorcentajeOcupacion
FROM Administracion.HORARIOS_CLASE h
INNER JOIN Administracion.CLASES c ON h.ClaseID = c.ClaseID
LEFT JOIN Administracion.RESERVAS r ON h.HorarioID = r.HorarioID
GROUP BY c.NombreClase, h.DiaSemana, h.HoraInicio, c.CapacidadMaxima;
GO

-- Revocar permisos anteriores
REVOKE CONTROL ON SCHEMA::dbo FROM rol_subadministrador;
REVOKE CONTROL ON SCHEMA::dbo FROM rol_recepcion;
REVOKE CONTROL ON SCHEMA::dbo FROM rol_entrenador;
REVOKE CONTROL ON SCHEMA::dbo FROM rol_lector;

-- Permisos: rol_administrador
GRANT CONTROL TO rol_administrador;


-- Permisos: rol_subadministrador 
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Administracion TO rol_subadministrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Contabilidad TO rol_subadministrador;


-- Permisos: rol_recepcion 
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Administracion TO rol_recepcion;
GRANT SELECT, INSERT ON SCHEMA::Contabilidad TO rol_recepcion;

DENY DELETE ON SCHEMA::Administracion TO rol_recepcion;
DENY DELETE ON SCHEMA::Contabilidad TO rol_recepcion;


-- Permisos: rol_entrenador 
GRANT SELECT ON Administracion.CLASES TO rol_entrenador;
GRANT SELECT ON Administracion.HORARIOS_CLASE TO rol_entrenador;
GRANT SELECT ON Administracion.RESERVAS TO rol_entrenador;
GRANT SELECT ON Administracion.ENTRENADORES TO rol_entrenador;


-- Permisos: rol_lector 
GRANT SELECT ON SCHEMA::Reportes TO rol_lector;
DENY SELECT ON SCHEMA::Administracion TO rol_lector;
DENY SELECT ON SCHEMA::Contabilidad TO rol_lector;

--prueba esquemas --

EXECUTE AS USER = 'UsuarioLector';
BEGIN TRY
    SELECT TOP 1 SocioID FROM Administracion.SOCIOS;
END TRY
BEGIN CATCH
    SELECT 'Seguridad OK: Acceso a tabla cruda bloqueado para Lector' AS Resultado;
END CATCH