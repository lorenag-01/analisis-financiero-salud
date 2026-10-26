# 🏥 Análisis financiero de clínicas y hospitales en Colombia (2025)

Proyecto de práctica en análisis de datos con **SQL (MySQL)** y **Power BI**. Explora los indicadores financieros de más de 5.500 prestadores de servicios de salud (IPS, ESE y hospitales) a partir de un dataset público de Kaggle, e incluye una **auditoría de datos extremos**.

> ⚠️ **Aviso:** es un proyecto de práctica. Las cifras corresponden al dataset utilizado y **no fueron verificadas contra fuentes oficiales**. No representan un diagnóstico del sector salud colombiano ni deben usarse para tomar decisiones.

![Dashboard](dashboard.png)

---

## 📌 Pregunta guía

**¿Quién gana y quién pierde en este conjunto de datos?**

## 📂 Fuente de datos

- **Dataset:** [Ranking Financiero Clínicas y Hospitales](https://www.kaggle.com/datasets/opuslibertati/ranking-financiero-clnicas-y-hospitales) (Kaggle, autor: *opuslibertati*).
- Revisa la página del dataset para conocer su descripción y licencia antes de reutilizarlo.

## 🛠️ Herramientas

| Herramienta | Uso |
|---|---|
| **MySQL 8+** | Exploración, indicadores y validación (CTEs, funciones de ventana, `CASE`, agregaciones) |
| **Power BI** | Modelo de datos, medidas DAX y dashboard interactivo |
| **GitHub** | Documentación y consultas |

## 🗂️ Contenido del repositorio

```
├── Consultas_Analisis_Financiero_2025.sql   # 16 bloques de consultas (solo SELECT)
├── dashboard.png                            # Captura del dashboard
└── README.md
```

El archivo SQL **no modifica ni elimina registros**: todas las consultas son `SELECT`. Espera una tabla llamada `prestadores_financieros`.

## 🔍 Qué hace el SQL

| # | Bloque | Descripción |
|---|---|---|
| 1 | Validación | Tamaño de la base y periodo |
| 2-3 | Rankings | Top 10 por ingresos y por utilidad |
| 4-5 | Indicadores generales | Ingresos, utilidad, margen global, prestadores con pérdida |
| 6 | Utilidad promedio y **mediana** | Mediana con funciones de ventana |
| 7-8 | Rankings de margen | Con y sin piso de ingresos ($100.000 millones) |
| 9-11 | Por departamento | Cantidad, margen ponderado y % con pérdida |
| 12 | Por naturaleza jurídica | Pérdidas, ingresos y margen ponderado |
| 13-14 | Mayores pérdidas | Global y para ingresos altos |
| 15-16 | **Auditoría** | Utilidad registrada vs. `ingresos − gastos − costos` |

## 🧠 Decisiones de análisis

1. **Margen ponderado, no promedio.** Se calcula como utilidad total ÷ ingresos totales, para que un prestador pequeño no pese lo mismo que uno gigante.
2. **Mediana además del promedio.** Unos pocos prestadores muy grandes sesgan el promedio de utilidades.
3. **Piso de ingresos en los rankings de margen.** Se usa un mínimo de $100.000 millones para evitar márgenes extremos de prestadores muy pequeños.
4. **Auditar antes de concluir.** Una diferencia entre la utilidad registrada y la calculada *requiere validación*; no prueba por sí sola que exista un error.

## 🕵️ Caso destacado: REMY IPS S.A.S.

| Indicador | Valor registrado |
|---|---|
| Ingresos | $3.030.601.802 |
| Gastos | $40.835.000.000 |
| Costos | $1.417.323.130 |
| Utilidad registrada | −$39.222.000.000 |
| Margen neto registrado | −1.294,2 % |

Al calcular `ingresos − gastos − costos` se obtiene **−$39.221.721.328**, con una diferencia de apenas **$278.672** frente a la utilidad registrada (compatible con un redondeo al millón).

**Conclusión:** la aritmética es consistente, pero los gastos equivalen a unas 13,5 veces los ingresos. Por eso la magnitud **requiere validación con la fuente original**. No se puede afirmar que sea un error contable sin investigar más.

## 📊 Indicadores del dashboard (en este dataset)

- Prestadores: 5.530
- Ingresos totales: 105,5 billones de COP
- Utilidad neta: 7 billones · Margen neto: 6,4 %
- Prestadores con pérdida: 929
- Endeudamiento global (pasivos ÷ activos): 46,1 %
- Participación en ingresos: 77,1 % privada · 21,9 % pública · 1,0 % mixta

El dashboard incluye filtros por **naturaleza jurídica**, **departamento** y **resultado** (pérdida / utilidad), y visuales de ranking, estructura financiera y dispersión de margen neto vs. ingresos.

## ▶️ Cómo usar el SQL

1. Descarga el dataset de Kaggle.
2. Cárgalo en MySQL 8+ como tabla `prestadores_financieros`, con columnas equivalentes a las usadas en las consultas (por ejemplo `nombre_prestador`, `departamento_prestador`, `naturaleza_juridica`, `ingresos`, `gastos`, `costos`, `utilidades`, `margen_neto_pct`, `periodo`).
3. Ejecuta los bloques del archivo `.sql` en orden.

> La mediana (bloque 6) usa funciones de ventana, disponibles desde MySQL 8.

## 💡 Aprendizajes

- Un gráfico atractivo vale poco si no se confía en el número que muestra.
- Un dato extremo no es un error ni una verdad hasta que se valida.
- Que una cuenta cuadre no significa que el dato sea correcto.

## 👤 Autora

**Angie Lorena Guerrero**
Business Data Analyst en formación · SQL · Power BI

[LinkedIn](https://www.linkedin.com/in/angielorenaguerrero)
