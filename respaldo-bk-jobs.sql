USE master;

--CONFIGURAR MODO DE RECUPERACION
ALTER DATABASE GIMNASIO_BD SET RECOVERY FULL;

--BACKUP FULL — DIARIO A LAS 4:00 AM

BACKUP DATABASE GIMNASIO_BD
TO DISK = 'C:\backups\GIMNASIO_FULL.bak'
WITH INIT, STATS = 10;

--BACKUP DIFERENCIAL — DIARIO A LAS 4:00 PM

BACKUP DATABASE GIMNASIO_BD
TO DISK = 'C:\backups\GIMNASIO_DIFERENCIAL.bak'
WITH DIFFERENTIAL, STATS = 10;

--BACKUP DEL LOG — 10:00 AM

BACKUP LOG GIMNASIO_BD
TO DISK = 'C:\backups\GIMNASIO_LOG_10AM.trn'
WITH STATS = 10;


--BACKUP DEL LOG — 10:00 PM

BACKUP LOG GIMNASIO_BD
TO DISK = 'C:\backups\GIMNASIO_LOG_10PM.trn'
WITH STATS = 10;

-- RESTAURACION 

-- 1? Restaurar el FULL 4 AM
RESTORE DATABASE GIMNASIO_BD
FROM DISK = 'C:\backups\GIMNASIO_FULL.bak'
WITH NORECOVERY;

-- 2? Restaurar el DIFERENCIAL 4 PM
RESTORE DATABASE GIMNASIO_BD
FROM DISK = 'C:\backups\GIMNASIO_DIFERENCIAL.bak'
WITH NORECOVERY;

-- 3? Restaurar LOG de 10 AM 
RESTORE LOG GIMNASIO_BD
FROM DISK = 'C:\backups\GIMNASIO_LOG_10AM.trn'
WITH NORECOVERY;

-- 4? Restaurar LOG de 10 PM 
RESTORE LOG GIMNASIO_BD
FROM DISK = 'C:\backups\GIMNASIO_LOG_10PM.trn'
WITH RECOVERY;  


--JOBS
USE msdb;

--Comprobar si se creo el job
SELECT name FROM msdb.dbo.sysjobs;

-----------------------------------------------

--Backup FULL Diario
EXEC sp_add_job
    @job_name = 'JOB_FULL_4AM',
    @description = 'Backup FULL diario 4 AM';
GO

-- Agregar Step para backup
EXEC sp_add_jobstep
    @job_name = 'JOB_FULL_4AM',
    @step_name = 'Backup_FULL',
    @subsystem = 'TSQL',
    @command = 'BACKUP DATABASE GIMNASIO_BD
        TO DISK = ''C:\backups\GIMNASIO_FULL.bak''
        WITH INIT, STATS=10;';
GO

-- Crear Schedule
EXEC sp_add_schedule
    @schedule_name = 'HORARIO_FULL_4AM',
    @freq_type = 4,      -- Diario
    @freq_interval = 1, 
    @active_start_time = 040000; 
GO

-- Asociar Schedule al Job
EXEC sp_attach_schedule
    @job_name = 'JOB_FULL_4AM',
    @schedule_name = 'HORARIO_FULL_4AM';
GO

-- Activar Job en el servidor
EXEC sp_add_jobserver
    @job_name = 'JOB_FULL_4AM';
GO

EXEC msdb.dbo.sp_start_job 'JOB_FULL_4AM';

-----------------------------------------------

--Backup DIF Diario
EXEC sp_add_job
    @job_name = 'JOB_DIF_4PM',
    @description = 'Backup diferencial diario 4 PM';
GO

-- Agregar Step para backup
EXEC sp_add_jobstep
    @job_name = 'JOB_DIF_4PM',
    @step_name = 'Backup_DIF',
    @subsystem = 'TSQL',
    @command = 'BACKUP DATABASE GIMNASIO_BD
        TO DISK = ''C:\backups\GIMNASIO_DIFERENCIAL.bak''
        WITH DIFFERENTIAL, STATS=10;';
GO

-- Crear Schedule
EXEC sp_add_schedule
    @schedule_name = 'HORARIO_DIF_4PM',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 160000;
GO

-- Asociar Schedule al Job
EXEC sp_attach_schedule
    @job_name = 'JOB_DIF_4PM',
    @schedule_name = 'HORARIO_DIF_4PM';
GO

-- Activar Job en el servidor
EXEC sp_add_jobserver
    @job_name = 'JOB_DIF_4PM';
GO

EXEC msdb.dbo.sp_start_job 'JOB_DIF_4PM';

-----------------------------------------------

--Backup LOG Diario 10AM y 10PM
EXEC sp_add_job
    @job_name = 'JOB_LOG_10AM_10PM',
    @description = 'Backup del log 10 AM y 10 PM';
GO

-- Agregar Step para backup
EXEC sp_add_jobstep
    @job_name = 'JOB_LOG_10AM_10PM',
    @step_name = 'Backup_LOG',
    @subsystem = 'TSQL',
    @command = 'BACKUP LOG GIMNASIO_BD
        TO DISK = ''C:\backups\GIMNASIO_LOG.trn''
        WITH STATS=10;';
GO


-- Horario 10 AM
-- Crear Schedule
EXEC sp_add_schedule
    @schedule_name = 'HORARIO_LOG_10AM',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 100000;
GO

-- Horario 10 PM
EXEC sp_add_schedule
    @schedule_name = 'HORARIO_LOG_10PM',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 220000;
GO

-- Asociar ambos horarios al mismo Job
EXEC sp_attach_schedule @job_name = 'JOB_LOG_10AM_10PM', @schedule_name = 'HORARIO_LOG_10AM';
EXEC sp_attach_schedule @job_name = 'JOB_LOG_10AM_10PM', @schedule_name = 'HORARIO_LOG_10PM';
GO

-- Activar Job en el servidor
EXEC sp_add_jobserver
    @job_name = 'JOB_LOG_10AM_10PM';
GO

EXEC msdb.dbo.sp_start_job 'JOB_LOG_10AM_10PM';
