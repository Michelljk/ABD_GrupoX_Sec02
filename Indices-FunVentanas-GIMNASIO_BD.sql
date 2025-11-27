USE GIMNASIO_BD;

--Indices para optimizacion de las consultas 
--Indices en SOCIOS
CREATE NONCLUSTERED INDEX NIX_SOCIOS_Email ON SOCIOS (Email);
CREATE NONCLUSTERED INDEX NIX_SOCIOS_FechaRegistro ON SOCIOS (FechaRegistro);

--Indices en PAGOS
CREATE NONCLUSTERED INDEX NIX_PAGOS_FechaPago ON PAGOS (FechaPago);
CREATE NONCLUSTERED INDEX NIX_PAGOS_MetodoPago ON PAGOS (MetodoPago);

--Indices en RESERVAS
CREATE NONCLUSTERED INDEX NIX_RESERVAS_Socio_Estado ON RESERVAS (SocioID, EstadoReserva);
CREATE NONCLUSTERED INDEX NIX_RESERVAS_Horario_Fecha ON RESERVAS (HorarioID, FechaReserva) 
    INCLUDE (SocioID, EstadoReserva);

--Indices en HORARIOS CLASE
CREATE NONCLUSTERED INDEX NIX_HORARIOS_Clase ON HORARIOS_CLASE (ClaseID);
CREATE NONCLUSTERED INDEX NIX_HORARIOS_Entrenador ON HORARIOS_CLASE (EntrenadorID);

--Medicion de rendimiento antes y despues de la creacion de indices de optimizacion
--Indices en SOCIOS
DROP INDEX NIX_SOCIOS_Email ON SOCIOS;
DROP INDEX NIX_SOCIOS_FechaRegistro ON SOCIOS;

--Indices en PAGOS
DROP INDEX NIX_PAGOS_FechaPago ON PAGOS;
DROP INDEX NIX_PAGOS_MetodoPago ON PAGOS;

--Indices en RESERVAS
DROP INDEX NIX_RESERVAS_Socio_Estado ON RESERVAS;
DROP INDEX NIX_RESERVAS_Horario_Fecha ON RESERVAS;

--Indices en HORARIOS CLASE
DROP INDEX NIX_HORARIOS_Clase ON HORARIOS_CLASE;
DROP INDEX NIX_HORARIOS_Entrenador ON HORARIOS_CLASE;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT COUNT(*) AS TotalPagos
FROM PAGOS
WHERE FechaPago BETWEEN '2024-01-01' AND '2024-12-31';

-- Observa los valores de "logical reads" y "CPU time"
SELECT SocioID, Nombre, Apellido, Email
FROM SOCIOS
WHERE Email LIKE '%gmail.com%';

--Consultar reservas por estado uso de indice compuesto
SELECT SocioID, COUNT(*) AS TotalActivas
FROM RESERVAS
WHERE EstadoReserva = 'Activa'
GROUP BY SocioID
ORDER BY TotalActivas DESC;

--Consulta pesada con JOINS y agrupacion
SELECT E.EntrenadoresID,E.Nombre + ' ' + E.Apellido AS Entrenador,
SUM(P.MontoPagado) AS TotalIngresos
FROM ENTRENADORES E
JOIN HORARIOS_CLASE H ON E.EntrenadoresID = H.EntrenadorID
JOIN RESERVAS R ON H.HorarioID = R.HorarioID
JOIN PAGOS P ON R.SocioID = P.SocioID
GROUP BY E.EntrenadoresID, E.Nombre, E.Apellido
ORDER BY TotalIngresos DESC;

-- Comparar velocidad con y sin indice
-- Deshabilitar temporalmente el indice
ALTER INDEX NIX_PAGOS_FechaPago ON PAGOS DISABLE;

-- Ejecutar la misma consulta (mas lenta)
SELECT SUM(MontoPagado) AS TotalPagosSinIndice
FROM PAGOS
WHERE FechaPago BETWEEN '2024-01-01' AND '2024-12-31';

-- Reconstruir el indice
ALTER INDEX NIX_PAGOS_FechaPago ON PAGOS REBUILD;

-- Ejecutar nuevamente la consulta mas rapida
SELECT SUM(MontoPagado) AS TotalPagosConIndice
FROM PAGOS
WHERE FechaPago BETWEEN '2024-01-01' AND '2024-12-31';


--Consulta con funcion ventana sobre gran volumen
SELECT S.SocioID, S.Nombre + ' ' + S.Apellido AS Socio,
SUM(P.MontoPagado) AS TotalPagado,
DENSE_RANK() OVER (ORDER BY SUM(P.MontoPagado) DESC) AS Ranking
FROM SOCIOS S
JOIN PAGOS P ON S.SocioID = P.SocioID
GROUP BY S.SocioID, S.Nombre, S.Apellido;

--Analisis de cache y lecturas repeticion de consulta

-- Primera ejecucion sin cache
SELECT COUNT(*) AS TotalReservas FROM RESERVAS WHERE EstadoReserva = 'Activa';

-- Segunda ejecucion con cache, debe ser mas rapida
SELECT COUNT(*) AS TotalReservas FROM RESERVAS WHERE EstadoReserva = 'Activa';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

--Funciones Ventana
--1️-Ranking de horarios preferidos
SELECT H.HoraInicio,
COUNT(R.ReservaID) AS TotalReservas,
RANK() OVER (ORDER BY COUNT(R.ReservaID) DESC) AS RankingHorario
FROM HORARIOS_CLASE H
JOIN RESERVAS R ON H.HorarioID = R.HorarioID
WHERE R.EstadoReserva = 'Confirmada'
GROUP BY H.HoraInicio
ORDER BY RankingHorario;

--2️-Ranking de horarios por tipo de clase
SELECT C.NombreClase, H.DiaSemana, H.HoraInicio,
COUNT(R.ReservaID) AS TotalReservas,
RANK() OVER (PARTITION BY C.ClaseID ORDER BY COUNT(R.ReservaID) DESC) AS RankingPorClase
FROM CLASES C
JOIN HORARIOS_CLASE H ON C.ClaseID = H.ClaseID
JOIN RESERVAS R ON H.HorarioID = R.HorarioID
WHERE R.EstadoReserva = 'Confirmada'
GROUP BY C.NombreClase, C.ClaseID, H.DiaSemana, H.HoraInicio
ORDER BY C.NombreClase, RankingPorClase;

--3️-Clases preferidas
SELECT C.NombreClase,
COUNT(R.ReservaID) AS TotalReservas,
RANK() OVER (ORDER BY COUNT(R.ReservaID) DESC) AS RankingClase
FROM CLASES C
JOIN HORARIOS_CLASE H ON C.ClaseID = H.ClaseID
JOIN RESERVAS R ON R.HorarioID = H.HorarioID
WHERE R.EstadoReserva = 'Confirmada'
GROUP BY C.NombreClase
ORDER BY RankingClase;

--Analisis de asistencia utilizando lag
WITH AsistenciaMensual AS (
SELECT
FORMAT(R.FechaReserva, 'yyyy-MM') AS Mes,
COUNT(R.ReservaID) AS AsistenciaTotal
FROM RESERVAS R
WHERE R.EstadoReserva = 'Completada'
GROUP BY FORMAT(R.FechaReserva, 'yyyy-MM')
)SELECT Mes, AsistenciaTotal,
LAG(AsistenciaTotal, 1, 0) OVER (ORDER BY Mes) AS AsistenciaMesAnterior,
AsistenciaTotal - LAG(AsistenciaTotal, 1, 0) OVER (ORDER BY Mes) AS DiferenciaVsMesAnterior
FROM AsistenciaMensual
ORDER BY Mes;

--Estudiantes atendidos por entrenador
WITH EstudiantesPorClase AS (
SELECT DISTINCT
E.Nombre + ' ' + E.Apellido AS Entrenador,
FORMAT(R.FechaReserva, 'yyyy-MM') AS Mes,
R.SocioID
FROM ENTRENADORES E
JOIN HORARIOS_CLASE H ON E.EntrenadoresID = H.EntrenadorID
JOIN RESERVAS R ON H.HorarioID = R.HorarioID
WHERE R.EstadoReserva = 'Confirmada')
SELECT Mes, Entrenador,
COUNT(SocioID) OVER (PARTITION BY Mes, Entrenador) AS TotalEstudiantesAtendidos
FROM EstudiantesPorClase
ORDER BY Mes, TotalEstudiantesAtendidos DESC;


--Vista Optimizada Dashboard
CREATE VIEW Vista_Rendimiento_Clases_Optimizada
AS SELECT C.ClaseID, C.NombreClase, H.HorarioID,
H.DiaSemana, H.HoraInicio, E.EntrenadoresID,
E.Nombre + ' ' + E.Apellido AS NombreEntrenador,
COUNT(R.ReservaID) AS TotalReservasConfirmadas,
C.CapacidadMaxima,
CAST(COUNT(R.ReservaID) * 100.0 / C.CapacidadMaxima AS DECIMAL(5,2)) AS PorcentajeOcupacion
FROM CLASES C
JOIN HORARIOS_CLASE H ON C.ClaseID = H.ClaseID
JOIN ENTRENADORES E ON H.EntrenadorID = E.EntrenadoresID
LEFT JOIN RESERVAS R ON R.HorarioID = H.HorarioID AND R.EstadoReserva = 'Confirmada'
GROUP BY
    C.ClaseID, C.NombreClase, H.HorarioID, H.DiaSemana, H.HoraInicio,
    E.EntrenadoresID, E.Nombre, E.Apellido, C.CapacidadMaxima;

-- Consulta a vista
SELECT * FROM Vista_Rendimiento_Clases_Optimizada ORDER BY PorcentajeOcupacion DESC;

