#==========================================================
# Tabla general de futbol  #### 
#==========================================================

#Cargar paquetes
library(tidyverse)

#Crear función
Tabla_General <- function(x) {
  
  #Extraer información
  df <- read_csv(
    url(glue::glue('http://www.football-data.co.uk/mmz4281/1718/{x}.csv')))
  
  
  #Seleccionar columnas necesarias
  df <- df %>%
    select(Date:FTR)
  
  #Crear puntos por separado (Local y Visita)
  df <- df %>%
    mutate(
      Puntos_Local = case_when(
        FTHG > FTAG ~ 3,
        FTHG == FTAG ~ 1,
        FTHG < FTAG ~ 0
      ),
      Puntos_Visita = case_when(
        FTHG < FTAG ~ 3,
        FTHG == FTAG ~ 1,
        FTHG > FTAG ~ 0
      ))
  
  
  #Unir info local e info visita
  df <- bind_rows(
    df %>% select(Equipo = HomeTeam, Rival = AwayTeam, Goles_Favor = FTHG,
                  Goles_Contra = FTAG, Resultado = Puntos_Local),
    df %>% select(Equipo = AwayTeam, Rival = HomeTeam, Goles_Favor = FTAG,
                  Goles_Contra = FTHG, Resultado = Puntos_Visita))
  
  
  #Agrupar información para obtener tabla final
  df <- df %>%
    group_by(Equipo) %>%
    summarise(GolesF = sum(Goles_Favor), GolesC = sum(Goles_Contra),
              Puntos = sum(Resultado)) %>%
    arrange(-Puntos)
  
  
  #End
  
  
}


#Lista de ligas
Mis_Ligas <- list("D1",
                  "SP1",
                  "F1",
                  "E0",
                  "I1")


#Crear loop
df <- map(Mis_Ligas, Tabla_General)
