/*
Proyecto: Análisis financiero de prestadores de servicios de salud - 2025
Motor utilizado en DB Fiddle: MySQL
Tabla esperada: prestadores_financieros

Nota:
- Este archivo reúne consultas de exploración, indicadores y validación.
- No modifica ni elimina registros: son consultas SELECT.
- Los nombres de tablas y columnas corresponden al esquema usado en el proyecto.
*/

/* ============================================================
   1. VALIDAR EL TAMAÑO Y EL PERIODO DE LA BASE
   ============================================================ */
SELECT
    COUNT(*) AS total_prestadores,
    MIN(periodo) AS periodo_minimo,
    MAX(periodo) AS periodo_maximo
FROM prestadores_financieros;

/* ============================================================
   2. TOP 10 POR INGRESOS
   ============================================================ */
SELECT
    nombre_prestador,
    ingresos
FROM prestadores_financieros
ORDER BY ingresos DESC
LIMIT 10;

/* ============================================================
   3. TOP 10 POR UTILIDAD REGISTRADA
   ============================================================ */
SELECT
    nombre_prestador,
    ingresos,
    utilidades,
    margen_neto_pct
FROM prestadores_financieros
ORDER BY utilidades DESC
LIMIT 10;

/* ============================================================
   4. INDICADORES GENERALES DE LA BASE
   ============================================================ */
SELECT
    COUNT(*) AS total_prestadores,
    SUM(ingresos) AS ingresos_totales,
    SUM(utilidades) AS utilidad_total,
    (SUM(utilidades) / NULLIF(SUM(ingresos), 0)) * 100 AS margen_neto_global,
    SUM(CASE WHEN utilidades < 0 THEN 1 ELSE 0 END) AS prestadores_con_perdida,
    SUM(CASE WHEN utilidades > 0 THEN 1 ELSE 0 END) AS prestadores_con_utilidad_positiva,
    SUM(CASE WHEN utilidades = 0 THEN 1 ELSE 0 END) AS prestadores_con_utilidad_cero,
    SUM(CASE WHEN utilidades < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS porcentaje_perdida,
    SUM(CASE WHEN utilidades > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS porcentaje_utilidad_positiva
FROM prestadores_financieros;

/* ============================================================
   5. PÉRDIDAS ACUMULADAS DE LOS PRESTADORES CON UTILIDAD NEGATIVA
   ============================================================ */
SELECT
    COUNT(*) AS prestadores_con_perdida,
    SUM(utilidades) AS perdidas_totales
FROM prestadores_financieros
WHERE utilidades < 0;

/* ============================================================
   6. UTILIDAD PROMEDIO Y MEDIANA
   La mediana usa funciones de ventana disponibles en MySQL 8+.
   ============================================================ */
SELECT
    AVG(utilidades) AS utilidad_promedio
FROM prestadores_financieros;

WITH ordenados AS (
    SELECT
        utilidades,
        ROW_NUMBER() OVER (ORDER BY utilidades) AS posicion,
        COUNT(*) OVER () AS total
    FROM prestadores_financieros
)
SELECT
    AVG(utilidades) AS utilidad_mediana
FROM ordenados
WHERE posicion IN (
    FLOOR((total + 1) / 2),
    CEIL((total + 1) / 2)
);

/* ============================================================
   7. TOP 10 POR MARGEN NETO REGISTRADO
   ============================================================ */
SELECT
    nombre_prestador,
    ingresos,
    utilidades,
    margen_neto_pct
FROM prestadores_financieros
ORDER BY margen_neto_pct DESC
LIMIT 10;

/* ============================================================
   8. TOP 10 POR MARGEN NETO CON INGRESOS MÍNIMOS DE $100.000 MILLONES
   ============================================================ */
SELECT
    nombre_prestador,
    ingresos,
    utilidades,
    margen_neto_pct
FROM prestadores_financieros
WHERE ingresos >= 100000000000
ORDER BY margen_neto_pct DESC
LIMIT 10;

/* ============================================================
   9. CANTIDAD DE PRESTADORES POR DEPARTAMENTO
   ============================================================ */
SELECT
    departamento_prestador,
    COUNT(*) AS cantidad_prestadores
FROM prestadores_financieros
GROUP BY departamento_prestador
ORDER BY cantidad_prestadores DESC;

/* ============================================================
   10. INGRESOS, UTILIDAD Y MARGEN PONDERADO POR DEPARTAMENTO
   El margen ponderado se calcula como utilidad total / ingresos totales.
   ============================================================ */
SELECT
    departamento_prestador,
    SUM(ingresos) AS ingresos_totales,
    SUM(utilidades) AS utilidad_total,
    (SUM(utilidades) / NULLIF(SUM(ingresos), 0)) * 100 AS margen_ponderado
FROM prestadores_financieros
GROUP BY departamento_prestador
ORDER BY margen_ponderado DESC;

/* ============================================================
   11. PORCENTAJE DE PRESTADORES CON PÉRDIDA POR DEPARTAMENTO
   ============================================================ */
SELECT
    departamento_prestador,
    COUNT(*) AS total_prestadores,
    SUM(CASE WHEN utilidades < 0 THEN 1 ELSE 0 END) AS prestadores_con_perdida,
    SUM(CASE WHEN utilidades < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS porcentaje_perdida
FROM prestadores_financieros
GROUP BY departamento_prestador
ORDER BY porcentaje_perdida DESC;

/* ============================================================
   12. RESULTADOS POR NATURALEZA JURÍDICA: TODA LA BASE
   ============================================================ */
SELECT
    naturaleza_juridica,
    COUNT(*) AS total_prestadores,
    SUM(CASE WHEN utilidades < 0 THEN 1 ELSE 0 END) AS prestadores_con_perdida,
    SUM(CASE WHEN utilidades < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS porcentaje_perdida,
    SUM(ingresos) AS ingresos_totales,
    SUM(utilidades) AS utilidad_total,
    (SUM(utilidades) / NULLIF(SUM(ingresos), 0)) * 100 AS margen_ponderado
FROM prestadores_financieros
GROUP BY naturaleza_juridica
ORDER BY porcentaje_perdida DESC;

/* ============================================================
   13. TOP 10 MAYORES PÉRDIDAS EN TODA LA BASE
   ============================================================ */
SELECT
    nombre_prestador,
    departamento_prestador,
    naturaleza_juridica,
    ingresos,
    utilidades,
    margen_neto_pct
FROM prestadores_financieros
WHERE utilidades < 0
ORDER BY utilidades ASC
LIMIT 10;

/* ============================================================
   14. PRESTADORES CON INGRESOS >= $100.000 MILLONES Y PÉRDIDAS
   ============================================================ */
SELECT
    nombre_prestador,
    departamento_prestador,
    naturaleza_juridica,
    ingresos,
    utilidades,
    margen_neto_pct
FROM prestadores_financieros
WHERE ingresos >= 100000000000
  AND utilidades < 0
ORDER BY utilidades ASC
LIMIT 10;

/* Resumen por departamento, dentro del grupo de ingresos altos con pérdidas */
SELECT
    departamento_prestador,
    COUNT(*) AS cantidad_prestadores,
    SUM(ingresos) AS ingresos_totales,
    SUM(utilidades) AS perdidas_totales,
    (SUM(utilidades) / NULLIF(SUM(ingresos), 0)) * 100 AS margen_ponderado
FROM prestadores_financieros
WHERE ingresos >= 100000000000
  AND utilidades < 0
GROUP BY departamento_prestador
ORDER BY perdidas_totales ASC;

/* Resumen por naturaleza jurídica, dentro del grupo de ingresos altos con pérdidas */
SELECT
    naturaleza_juridica,
    COUNT(*) AS cantidad_prestadores,
    SUM(ingresos) AS ingresos_totales,
    SUM(utilidades) AS perdidas_totales,
    (SUM(utilidades) / NULLIF(SUM(ingresos), 0)) * 100 AS margen_ponderado
FROM prestadores_financieros
WHERE ingresos >= 100000000000
  AND utilidades < 0
GROUP BY naturaleza_juridica
ORDER BY perdidas_totales ASC;

/* ============================================================
   15. INVESTIGAR EL CASO REMY IPS S.A.S.
   ============================================================ */
SELECT
    nombre_prestador,
    ingresos,
    gastos,
    costos,
    utilidades AS utilidad_registrada,
    (ingresos - gastos - costos) AS utilidad_calculada,
    (utilidades - (ingresos - gastos - costos)) AS diferencia
FROM prestadores_financieros
WHERE nombre_prestador = 'REMY IPS S.A.S';

/* ============================================================
   16. REVISIÓN DE DIFERENCIAS ENTRE UTILIDAD REGISTRADA Y CALCULADA
   Importante: la fórmula ingresos - gastos - costos es una comprobación
   preliminar, no necesariamente la fórmula contable oficial de la fuente.
   Una diferencia requiere validación; no prueba por sí sola que exista error.
   ============================================================ */
SELECT
    nombre_prestador,
    utilidades AS utilidad_registrada,
    (ingresos - gastos - costos) AS utilidad_calculada,
    (utilidades - (ingresos - gastos - costos)) AS diferencia
FROM prestadores_financieros
ORDER BY ABS(utilidades - (ingresos - gastos - costos)) DESC
LIMIT 10;
