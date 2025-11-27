# 🗃️ Proyecto de Cátedra: Administración de Bases de Datos - Gimnasio

¡Bienvenido al repositorio del proyecto de cátedra sobre Administración de Bases de Datos!  
Este proyecto se centra en la implementación de una solución integral para la gestión y análisis de datos de un gimnasio, abarcando desde la seguridad y recuperación de la información hasta la optimización del rendimiento y la visualización de métricas clave de negocio.

## ✨ Características Principales

El proyecto se divide en tres componentes fundamentales que aseguran una gestión de datos robusta y eficiente:

### 1. 🛡️ Estrategia de Backup y Recuperación

Se ha diseñado e implementado una sólida estrategia de copias de seguridad para garantizar la integridad y disponibilidad de los datos ante cualquier eventualidad. Esta estrategia incluye:

- **📦 Backups Completos (Full):** Respaldo diario de la base de datos completa.
- **🔄 Backups Diferenciales:** Copias de seguridad de los cambios realizados desde el último backup completo.
- **📋 Logs de Transacciones:** Registro continuo de todas las transacciones para permitir una recuperación a un punto específico en el tiempo (Point-in-Time Recovery).

Estos procesos se han automatizado mediante Jobs en SQL Server Agent, asegurando una ejecución periódica y minimizando la intervención manual.

### 2. ⚡ Optimización y Rendimiento

Para mejorar la velocidad y eficiencia de las consultas, se ha llevado a cabo un proceso de optimización basado en la creación de índices estratégicos. Las principales optimizaciones incluyen:

- **📊 Índices No Agrupados:** Implementados para acelerar consultas analíticas, de filtrado y agregación, reduciendo significativamente los tiempos de respuesta.
- **📈 Funciones de Ventana:** Utilizadas para consultas complejas de ranking y análisis de tendencias, como la identificación de horarios y clases más populares.


### 3. 📊 Dashboard de Business Intelligence

Se ha desarrollado un dashboard interactivo en **Power BI** para visualizar y analizar los indicadores clave de rendimiento (KPIs) del gimnasio. El dashboard ofrece una visión completa sobre:

- **💰 Ingresos y Socios:** Seguimiento de ingresos totales, socios activos y tasa de retención.
- **🏋️ Análisis de Clases:** Ranking de las clases más populares y con mayor ocupación.
- **🎛️ Filtros Interactivos:** Permite segmentar la información por período (año y mes) para un análisis detallado.
- **📝 Narrativa Ejecutiva:** Resúmenes en lenguaje natural de los hallazgos más importantes para facilitar la toma de decisiones.

---

## 🛠️ Tecnologías Utilizadas

- **🗄️ Motor de Base de Datos:** Microsoft SQL Server
- **📈 Herramienta de BI:** Microsoft Power BI
- **🔍 Lenguaje de Consultas:** T-SQL

---

## 🎬 Demostración

¡Explora el proyecto en acción!

- **🎥 Video Explicativo:** https://ucaedusv-my.sharepoint.com/:v:/g/personal/00111219_uca_edu_sv/IQDN0KyQ0uk3QY0wpgnZ2-P_AeY6NjQzdvXOyg87WXAzApI?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=n7We7b
  
- **📱 Dashboard Interactivo:** https://ucaedusv-my.sharepoint.com/:f:/g/personal/00111219_uca_edu_sv/IgAIRZ4v7H85ToU9iQaNtSGyAQ3LnHzjpXWEiBYYkZAcDvs?e=hmkFOj

---

