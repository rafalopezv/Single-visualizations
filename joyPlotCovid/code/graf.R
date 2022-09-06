# about: plots / sobre: visualizacion
library(tidyverse)
source("joyPlotCovid/code/cleaning.R")

# order countries according to the apppearance of firs case/ordenar países por el orden de aparición de sus primeros casos
df_mundo %>% 
  filter(casos_acumulados != 0) %>% 
  group_by(pais_region) %>% 
  summarise(
    fecha = min(fecha)
  ) %>% 
  arrange(fecha) %>% 
  mutate(num = 1:nrow(.)) -> orden

# get number of days/numero de días
df_mundo %>% 
  filter(base == "confirmados") %>%
  pull(fecha) %>% 
  unique %>% 
  {
    Range <<- range(.)
    Days <<- (Range[2] - Range[1]) %>% as.numeric
  } 

#----------------------------------------------
# labels for the graph/etiquetas del gráfico
#----------------------------------------------

# get number of world infections / numero de infectados nivel mundo 
df_mundo %>% 
  filter(base == "confirmados") %>% 
  summarise(sum = (sum(incidencia)/1000000) %>% round(0)) %>% 
  pull(sum) -> infected
  
# get number of world deaths / numero de muerte nivel mundo
df_mundo %>% 
  filter(base == "fallecidos") %>% 
  summarise(sum = (sum(incidencia)/1000000) %>% round(1)) %>% 
  pull(sum) -> deaths

#  most recent date of data base/ fecha mas reciente de la base
df_mundo %>% 
  filter(base == "confirmados") %>% 
  pull(fecha) %>% 
  max -> maxDate

paste0(
  lubridate::month(maxDate, label = T, abbr = F) %>% str_to_lower(),
  " ",
  lubridate::day(maxDate),
  ", ",
  lubridate::year(maxDate)
) -> maxDate 

# caption label/ etiqueta del caption
paste0(
  "· data until ",
  maxDate, 
  " · ",
  "new cases per week · ",
  Days, 
  " days · ",
  infected,
  " MM infected · ",
  deaths,
  " MM deaths · rafalopezv"
) -> caption 
 
# graph / grafico   
df_mundo %>% 
  filter(base == "confirmados") %>%
  group_by(pais_region, semana) %>% 
  summarise(incidencia = sum(incidencia)) %>% 
  left_join(., orden) -> graf

graf %>% 
  ggplot(aes(semana, incidencia)) +
  geom_area(
    size = .28,
    alpha = 1,
    fill = "#161618",
    color = "#CFD4CF"
  ) +
  facet_wrap(~pais_region , ncol = 1, scales = "free_y") +
  theme_void() +
  theme(
    legend.position = "none",
    strip.background = element_blank(),
    strip.text.x = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    plot.background = element_rect(fill = "#161618"),
    panel.spacing = unit(-.90, "cm", data = NULL), 
    plot.margin = margin(t = 2, r = 2, b = 2, l = 2, "cm"),
    plot.title = element_text(
      color = "#CFD4CF", 
      family = "Roboto Mono", 
      hjust = .5, 
      size = 14,
      margin = margin(0,0,15,0)
    ),
    plot.caption = element_text(
      family = "Open Sans Light", 
      color = "#CFD4CF",
      vjust = -5, 
      hjust = .5,
      size = 8
    )
  ) +
  labs(
    caption = caption,
    title = glue::glue({Days}, " days of Covid-19 | ", "Each line is 1 of 193 countries")
  )

ggsave("joyPlotCovid/covid_all.png", height = 28, width = 22, dpi = 300, units = "cm")
