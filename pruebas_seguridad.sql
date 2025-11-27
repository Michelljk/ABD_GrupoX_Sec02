USE GIMNASIO_BD;
GO

-- Prueba 1: rol_recepcion
EXECUTE AS USER = 'UsuarioRecepcion';

BEGIN TRY
    SELECT TOP 1 SocioID FROM Administracion.SOCIOS;
    SELECT 'OK: Recepcion puede leer socios' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'ERROR: Recepcion no puede leer socios' AS Resultado;
END CATCH

BEGIN TRY
    INSERT INTO Contabilidad.PAGOS (SocioID, MembresiaID, FechaPago, MontoPagado, MetodoPago, FechaVencimiento) 
    VALUES (1, 1, GETDATE(), 500, 'Tarjeta', DATEADD(month, 1, GETDATE()));
    ROLLBACK;
    SELECT 'OK: Recepcion puede registrar pagos' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'ERROR: Recepcion no puede registrar pagos' AS Resultado;
END CATCH

BEGIN TRY
    DELETE FROM Administracion.SOCIOS WHERE SocioID = 1;
    SELECT 'ERROR: Recepcion puede eliminar socios (fallo seguridad)' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'OK: Recepcion no puede eliminar socios' AS Resultado;
END CATCH

REVERT;
GO

-- Prueba 2: rol_entrenador
EXECUTE AS USER = 'UsuarioEntrenador';

BEGIN TRY
    SELECT TOP 1 ClaseID FROM Administracion.CLASES;
    SELECT 'OK: Entrenador puede leer clases' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'ERROR: Entrenador no puede leer clases' AS Resultado;
END CATCH

BEGIN TRY
    SELECT TOP 1 SocioID FROM Administracion.SOCIOS;
    SELECT 'ERROR: Entrenador puede leer socios (fallo seguridad)' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'OK: Entrenador no puede leer socios' AS Resultado;
END CATCH

BEGIN TRY
    UPDATE Administracion.CLASES SET NombreClase = 'Test' WHERE ClaseID = 1;
    SELECT 'ERROR: Entrenador puede modificar clases (fallo seguridad)' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'OK: Entrenador no puede modificar clases' AS Resultado;
END CATCH

REVERT;
GO

-- Prueba 3: rol_lector
EXECUTE AS USER = 'UsuarioLector';

BEGIN TRY
    SELECT TOP 1 * FROM Reportes.V_SociosActivos;
    SELECT 'OK: Lector puede acceder a vistas de reportes' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'ERROR: Lector no puede acceder a vistas de reportes' AS Resultado;
END CATCH

BEGIN TRY
    SELECT TOP 1 SocioID FROM Administracion.SOCIOS;
    SELECT 'ERROR: Lector puede acceder a tablas directamente (fallo seguridad)' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'OK: Lector no puede acceder a tablas directamente' AS Resultado;
END CATCH

BEGIN TRY
    INSERT INTO Reportes.V_SociosActivos (Nombre, Apellido, Email) VALUES ('Test', 'Test', 'test@test.com');
    SELECT 'ERROR: Lector puede insertar datos (fallo seguridad)' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'OK: Lector no puede insertar datos' AS Resultado;
END CATCH

REVERT;
GO

-- Prueba 4: rol_subadministrador
EXECUTE AS USER = 'UsuarioSubAdmin';

BEGIN TRY
    SELECT TOP 1 SocioID FROM Administracion.SOCIOS;
    SELECT 'OK: SubAdmin puede leer administracion' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'ERROR: SubAdmin no puede leer administracion' AS Resultado;
END CATCH

BEGIN TRY
    SELECT TOP 1 PagoID FROM Contabilidad.PAGOS;
    SELECT 'OK: SubAdmin puede leer contabilidad' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'ERROR: SubAdmin no puede leer contabilidad' AS Resultado;
END CATCH

BEGIN TRY
    UPDATE Administracion.CLASES SET NombreClase = NombreClase WHERE ClaseID = 1;
    SELECT 'OK: SubAdmin puede modificar administracion' AS Resultado;
END TRY
BEGIN CATCH
    SELECT 'ERROR: SubAdmin no puede modificar administracion' AS Resultado;
END CATCH

REVERT;
GO