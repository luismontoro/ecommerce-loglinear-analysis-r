# Modelización log-lineal en R: intención de compra en e-commerce

Este repositorio recoge el código y la presentación de mi Trabajo de Fin de Grado en Estadística y Empresa (Universidad de Jaén). El objetivo del trabajo es analizar qué factores y combinaciones de comportamiento influyen en la intención de compra dentro de una tienda online.

## Datos y metodología

Para el estudio he utilizado el dataset *Online Shoppers Purchasing Intention*, que cuenta con 12.330 sesiones de usuario (de las cuales 1.908 terminan en compra, un 15,47 % del total).

En lugar de aplicar una regresión logística tradicional desde el principio, opté por un enfoque de **modelización log-lineal** sobre tablas de contingencia multidimensionales en R (`glm` con familia Poisson). Esto permite estudiar las relaciones e interacciones entre todas las variables sin imponer de antemano cuál es la variable respuesta.

Tras un análisis exploratorio inicial, descarté las variables Sistema Operativo (`OperatingSystems`), Navegador (`Browser`) y Región (`Region`) al presentar tasas de compra muy homogéneas en torno al 15 %. El modelo final se construyó con 5 variables recodificadas:
- `Revenue`: compra realizada (TRUE / FALSE).
- `Month_rec`: estacionalidad (Temporada Alta en noviembre y diciembre frente al resto del año).
- `Weekend`: navegación en fin de semana (Sí / No).
- `Product_rec`: nivel de interés según el número de páginas de productos visitadas (`ProductRelated`), discretizado por terciles en Bajo, Medio y Alto.
- `Visitor_rec`: tipo de visitante (Nuevo frente a Recurrente).

## Principales resultados

Partiendo del modelo saturado (AIC = 408,46), apliqué selección hacia atrás por criterio AIC mediante la función `step()`, eliminando 5 interacciones no significativas hasta llegar al modelo óptimo (AIC = 398,34; G² = 9,88):

- **Nivel de interés en páginas de productos visitadas:** Es el factor que más asociación positiva tiene con la compra. Pasar a un nivel medio o alto de páginas de producto visitadas incrementa de forma muy significativa la asociación con `Revenue` (coeficientes de +0,684 y +1,005 respectivamente, p < 0,001).
- **Tipo de visitante (Nuevo vs. Recurrente):** Si se miran los datos de forma agregada, los visitantes recurrentes compran proporcionalmente menos que los nuevos (13,97 % frente a 24,91 %; coef. -1,625). Sin embargo, al observar las interacciones de tercer orden del modelo, se ve que esta tendencia cambia cuando navegan en fin de semana (+0,738, p < 0,001) o alcanzan un nivel de interés medio en páginas de productos (+0,530, p < 0,05).

## Conclusiones aplicadas al negocio

A partir de los resultados del modelo, planteé tres líneas de acción para mejorar la conversión:
- **Aumentar el interés en páginas de productos:** Mejorar la velocidad de carga y las recomendaciones de productos relacionados para llevar al visitante hacia niveles medios y altos de páginas vistas.
- **Campañas en fin de semana:** Lanzar promociones específicas a partir del viernes por la tarde dirigidas a visitantes recurrentes.
- **Descuentos dinámicos en sesión:** Detectar a los visitantes recurrentes que alcanzan un nivel medio o alto de páginas de productos visitadas y mostrarles un incentivo antes de que abandonen la web.

## Archivos del repositorio

- `script_analisis_log_lineal.r`: script en R con las recodificaciones, tablas de contingencia, gráficos descriptivos, ajuste del modelo saturado y selección del modelo óptimo.
- `Presentacion_TFG.pdf`: presentación con el resumen visual y los resultados del proyecto.
- `TFG_FINAL.pdf`: memoria completa del Trabajo de Fin de Grado con el marco teórico, desarrollo metodológico y tablas detalladas.
