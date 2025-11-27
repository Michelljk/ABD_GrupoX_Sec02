USE GIMNASIO_BD;
GO

IF OBJECT_ID('dbo.v_AnalisisRendimiento', 'V') IS NOT NULL
    DROP VIEW dbo.v_AnalisisRendimiento;
GO

CREATE VIEW dbo.v_AnalisisRendimiento
AS
SELECT 
    p.PagoID,
    p.FechaPago,
    p.MontoPagado AS Ingresos,
    p.MetodoPago,
    p.FechaVencimiento,
    YEAR(p.FechaPago) AS AnioPago,
    MONTH(p.FechaPago) AS MesPago,
    DATENAME(MONTH, p.FechaPago) AS NombreMesPago,
    FORMAT(p.FechaPago, 'MMM yyyy', 'es-ES') AS MesAnioPago,
    
    s.SocioID,
    s.Nombre + ' ' + s.Apellido AS NombreSocio,
    s.FechaNacimiento,
    DATEDIFF(YEAR, s.FechaNacimiento, GETDATE()) AS EdadSocio,
    CASE 
        WHEN DATEDIFF(YEAR, s.FechaNacimiento, GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN DATEDIFF(YEAR, s.FechaNacimiento, GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
        WHEN DATEDIFF(YEAR, s.FechaNacimiento, GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
        WHEN DATEDIFF(YEAR, s.FechaNacimiento, GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS RangoEdad,
    s.Genero,
    s.Email,
    s.FechaRegistro,
    s.Estado AS EstadoSocio,
    CASE WHEN s.Estado = 1 THEN 'Activo' ELSE 'Inactivo' END AS EstadoSocioTexto,
    
    m.MembresiaID,
    m.NombreMembresia,
    m.CostoMensual,
    m.DuracionMeses,
    
    r.ReservaID,
    r.FechaReserva,
    r.EstadoReserva,
    YEAR(r.FechaReserva) AS AnioReserva,
    MONTH(r.FechaReserva) AS MesReserva,
    
    c.ClaseID,
    c.NombreClase,
    c.CapacidadMaxima,
    c.DuracionMinutos,
    c.Costo AS CostoClase,
    
    h.HorarioID,
    h.DiaSemana,
    h.HoraInicio,
    h.HoraFin,
    
    e.EntrenadoresID,
    e.Nombre + ' ' + e.Apellido AS NombreEntrenador,
    e.Especialidad,
    
    CASE WHEN r.EstadoReserva = 'Completada' THEN 1 ELSE 0 END AS EsCompletada,
    CASE WHEN r.EstadoReserva = 'Cancelada' THEN 1 ELSE 0 END AS EsCancelada,
    CASE WHEN r.EstadoReserva = 'Confirmada' THEN 1 ELSE 0 END AS EsConfirmada,
    CASE WHEN p.FechaVencimiento >= GETDATE() THEN 'Vigente' ELSE 'Vencida' END AS EstadoMembresia

FROM Contabilidad.PAGOS p
INNER JOIN Administracion.SOCIOS s ON p.SocioID = s.SocioID
INNER JOIN Administracion.MEMBRESIAS m ON p.MembresiaID = m.MembresiaID
LEFT JOIN Administracion.RESERVAS r ON s.SocioID = r.SocioID
LEFT JOIN Administracion.HORARIOS_CLASE h ON r.HorarioID = h.HorarioID
LEFT JOIN Administracion.CLASES c ON h.ClaseID = c.ClaseID
LEFT JOIN Administracion.ENTRENADORES e ON h.EntrenadorID = e.EntrenadoresID;
GO

SELECT TOP 10 * FROM dbo.v_AnalisisRendimiento ORDER BY FechaPago DESC;