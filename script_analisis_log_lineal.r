# Modelización Log-Lineal: Intención de Compra en E-Commerce (TFG)
# Luis Miguel Montoro Cárdenas | Grado en Estadística y Empresa (UJA)
# Dataset: Online Shoppers Purchasing Intention (12.330 sesiones)

datos <- read.csv("online_shoppers_intention.csv", stringsAsFactors = FALSE)

# 1. Comprobar frecuencias iniciales
round(prop.table(table(datos$OperatingSystems)) * 100, 2)
round(prop.table(table(datos$Browser)) * 100, 2)
round(prop.table(table(datos$Region)) * 100, 2)

# 2. Recodificaciones y discretización
# Agrupamos categorías minoritarias en SO, navegador y región
datos$OS_rec <- "Otros"
datos$OS_rec[datos$OperatingSystems == 1] <- "1"
datos$OS_rec[datos$OperatingSystems == 2] <- "2"
datos$OS_rec[datos$OperatingSystems == 3] <- "3"
datos$OS_rec <- as.factor(datos$OS_rec)

datos$Browser_rec <- "Otros"
datos$Browser_rec[datos$Browser == 1] <- "1"
datos$Browser_rec[datos$Browser == 2] <- "2"
datos$Browser_rec <- as.factor(datos$Browser_rec)

datos$Region_rec <- "Otras"
datos$Region_rec[datos$Region == 1] <- "1"
datos$Region_rec[datos$Region == 3] <- "3"
datos$Region_rec <- as.factor(datos$Region_rec)

# Estacionalidad: Temporada Alta (Nov-Dic) vs. Resto del año
datos$Month_rec <- "Resto del año"
datos$Month_rec[datos$Month == "Nov"] <- "Temporada Alta"
datos$Month_rec[datos$Month == "Dec"] <- "Temporada Alta"
datos$Month_rec <- as.factor(datos$Month_rec)

# Tipo de visitante: Nuevo vs. Recurrente
datos$Visitor_rec <- "Recurrente"
datos$Visitor_rec[datos$VisitorType == "New_Visitor"] <- "Nuevo"
datos$Visitor_rec <- as.factor(datos$Visitor_rec)

# Discretizamos páginas de producto visitadas por terciles
cortes <- quantile(datos$ProductRelated, probs = c(0, 1/3, 2/3, 1))
datos$Product_rec <- cut(datos$ProductRelated, 
                         breaks = cortes, 
                         labels = c("Bajo", "Medio", "Alto"), 
                         include.lowest = TRUE)

datos$Revenue <- as.factor(datos$Revenue)
datos$Weekend <- as.factor(datos$Weekend)

# Comprobación de niveles y celdas totales
head(datos[, c("OS_rec", "Browser_rec", "Region_rec", "Month_rec", 
               "Visitor_rec", "Product_rec", "Revenue", "Weekend")])

categorias <- c(nlevels(datos$OS_rec), 
                nlevels(datos$Browser_rec), 
                nlevels(datos$Region_rec), 
                nlevels(datos$Month_rec), 
                nlevels(datos$Visitor_rec),
                nlevels(datos$Product_rec),
                nlevels(datos$Weekend),
                nlevels(datos$Revenue))
categorias
print(prod(categorias))

# 3. Análisis descriptivo y gráficos bivariantes
gris_portada    <- "#D5D8DC"
naranja_portada <- "darkorange"

# Compra global (Revenue)
tabla_compra <- table(datos$Revenue)
prop_compra  <- prop.table(tabla_compra) * 100
print(tabla_compra)
print(prop_compra)

barplot(tabla_compra, 
        col = c(gris_portada, naranja_portada),
        names.arg = c("No Compra", "Compra"))

# Estacionalidad - Compra
tabla_mes <- table(datos$Revenue, datos$Month_rec)
barplot(tabla_mes, beside = TRUE,
        col = c(gris_portada, naranja_portada),
        legend = TRUE)

# Tipo de visitante - Compra
tabla_vis <- table(datos$Revenue, datos$Visitor_rec)
print(tabla_vis)
prop_vis <- round(prop.table(tabla_vis, 2) * 100, 2)
print(prop_vis)

barplot(tabla_vis, 
        beside = TRUE, 
        legend = TRUE, 
        col = c(gris_portada, naranja_portada),
        xlab = "Tipo de Visitante",
        args.legend = list(x = "topright"))

# Nivel de interés en productos - Compra
tabla_prod <- table(datos$Revenue, datos$Product_rec)
print(tabla_prod)
prop_prod <- round(prop.table(tabla_prod, 2) * 100, 2)
print(prop_prod)

barplot(tabla_prod, 
        beside = TRUE, 
        legend = TRUE, 
        col = c(gris_portada, naranja_portada),
        main = "Compra según Nivel de Interés",
        xlab = "Nivel páginas de productos visitadas",
        ylim = c(0, max(tabla_vis) * 0.6),
        args.legend = list(x = "topright"))

# Variables descartadas (tasas homogéneas en torno al ~15 %)
tabla_os <- table(datos$Revenue, datos$OS_rec)
print(round(prop.table(tabla_os, 2) * 100, 2))
barplot(tabla_os, beside = TRUE, legend = TRUE, col = c(gris_portada, naranja_portada),
        main = "Compra según Sistema Operativo", xlab = "Sistema Operativo",
        args.legend = list(x = "topright"))

tabla_browser <- table(datos$Revenue, datos$Browser_rec)
print(round(prop.table(tabla_browser, 2) * 100, 2))
barplot(tabla_browser, beside = TRUE, legend = TRUE, col = c(gris_portada, naranja_portada),
        main = "Compra según Navegador", xlab = "Navegador",
        args.legend = list(x = "topright"))

tabla_region <- table(datos$Revenue, datos$Region_rec)
print(round(prop.table(tabla_region, 2) * 100, 2))
barplot(tabla_region, beside = TRUE, legend = TRUE, col = c(gris_portada, naranja_portada),
        main = "Compra según Región", xlab = "Región",
        ylim = c(0, max(tabla_vis) * 0.7),
        args.legend = list(x = "topright"))

# 4. Modelización log-lineal y selección del modelo óptimo
datos_modelo <- datos[, c("Revenue", "Month_rec", "Weekend", "Product_rec", "Visitor_rec")]
datos_modelo <- droplevels(datos_modelo)

# Tabla de contingencia multidimensional
df_frecuencias <- as.data.frame(table(datos_modelo))

# Modelo saturado (todas las interacciones hasta orden 5) y selección backward por AIC
modelo_saturado <- glm(Freq ~ .^5, data = df_frecuencias, family = poisson)
summary(modelo_saturado)

modelo_optimo <- step(modelo_saturado, direction = "backward")

# Coeficientes asociados a Revenue y sus interacciones
summary(modelo_optimo)$coefficients[grep("Revenue", rownames(summary(modelo_optimo)$coefficients)), ]