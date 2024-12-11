library(tidyverse)
library(magrittr)
library(gganimate)
library(furrr)
library(future)
library(ggimage)
library(hrbrthemes)

future::plan(strategy = multisession)
options(scipen = 999)  

#-----------------------
# a nivel departamental
#-----------------------
temp <- read_csv("data/pobreza_estrato_2001_2012.csv")
etiqueta <- "img/car.png"

temp %<>% 
  group_by(DEPARTAMENTO, año) %>% 
  summarise(
    valor = (sum(pobre)/sum(poblacion_estudio)) * 100
  ) %>% 
  spread(año, valor) %>% 
  mutate(
    brecha =  `2001` - `2012`,
    ritmo = brecha/11
  ) %>% 
  ungroup()

temp %<>% 
  mutate(
    al_0 = `2001` / ritmo,
    al_0 = al_0 + 1,
    al_cien = 100 - `2001`,
    frec_al_cien  = al_cien/ritmo,
    total_años = round(frec_al_cien + al_0),
    año_base = round(2001 - al_cien),
    termino = 2001 + al_0
  ) %>% 
  filter(ritmo > 0) %>% 
  dplyr::select(DEPARTAMENTO, año_base, ritmo, total_años) %>% 
  mutate(
    valor = 100,
    año = año_base
  ) %>% 
  group_split(DEPARTAMENTO)


# funciones de relleno, compilacion y corrección

# compiliacion : crea el df con el ritmo anual de evolucion 
compilacion <- function(.data) {
  vueltas <- 1:(.data %>% pull(total_años))
  vueltas <- vueltas - 1
  año_base <- (.data %>% pull(año)) + 1
  ritmo_temp <- .data %>% pull(ritmo)
  
  for(i in vueltas) {
    df_1 <- tibble(
      año = año_base + vueltas[i],
      valor = 100 - (ritmo_temp * i)
    )
    .data %<>% bind_rows(., df_1) %>% 
      dplyr::select(DEPARTAMENTO, año, valor) %>% 
      fill(DEPARTAMENTO)
  }
  return(.data)
}

# corrije cuando el último y mínimo valor debuendo ser 0 es o negativo o no 0
correccion <- function(.data) {
  if(min(.data$valor) > 0) {
    temp <- .data %>% pull(año) %>% max()
    tibble(
      año = temp + 1,
      valor = 0
    ) %>% 
      bind_rows(., .data) %>% 
      arrange(año) %>% 
      fill(DEPARTAMENTO) -> .data
  }
  if(min(.data$valor) < 0) {
    .data %<>% 
      mutate(
        valor = case_when(
          valor < 0 ~ 0,
          T ~ valor
        ) 
      )
  }
  return(.data)
}

# rellena los años faltabtes desde el valor mimimno hasta el minimo de la base
completar_años_abajo <- function(.data) {
  if((min(.data$año) > minimo) == T) {
    
    vueltas <- min(.data$año) - minimo
    
    for(i in 1:vueltas) {
      df <- tibble(
        año = (minimo + i) - 1,
        valor = 100
      )
      .data %<>% bind_rows(., df) %>% 
        fill(DEPARTAMENTO) %>% 
        arrange(año)
    }
  }
  return(.data)
}

# rellena los años faltabtes desde el valor maximo hasta el maximo de la base
completar_años_arriba <- function(.data) {
  if((max(.data$año) < maximo) == T) {
    año <- .data %>% pull(año) %>% max() + 1
    tibble(
      año = año:maximo
    ) %>% 
      bind_rows(.data, .) %>% 
      fill(DEPARTAMENTO, valor) ->.data
  }
  return(.data)
}

# saca el año de llegada a pobreza 0
llegada <- function(.data) {
  .data %<>% 
    arrange(año)
  ay <- which(.data$valor == 0) %>% first()
  llegada <- .data %>% slice(ay) %>% pull(año)
  
  .data %<>% 
    mutate(
      llegada_1 = case_when(
        año == llegada ~ llegada
      )
    ) %>% 
    fill(llegada_1)
  
  return(.data)
}

# calcular minimos y máximos
minimo <- temp %>% 
  future_map(., compilacion, .progress = T) %>% 
  future_map(., correccion, .progress = T) %>% 
  map(., ~min(.$año)) %>% 
  unlist %>% 
  min()

maximo <- temp %>% 
  future_map(., compilacion, .progress = T) %>% 
  future_map(., correccion, .progress = T) %>% 
  map(., ~max(.$año)) %>% 
  unlist %>% 
  max()

# aplicar funciones
temp %<>% 
  future_map(., compilacion, .progress = T) %>%
  future_map(., correccion, .progress = T) %>%
  future_map(., completar_años_abajo, .progress = T) %>%
  future_map(., completar_años_arriba, .progress = T)  %>%
  future_map_dfr(., llegada, .progress = T) %>% 
  mutate(valor_1 = 100 - valor) %>% 
  mutate_if(is.numeric, round, 2) %>% 
  mutate(
    size = case_when(
      valor == 0 ~ 12, 
      T ~ 8
    )
  )

# que posiicon tiene cada quien
temp %>% 
  group_split(DEPARTAMENTO) %>% 
  map_dfr(., ~filter(., !is.na(llegada_1))) %>% 
  dplyr::select(DEPARTAMENTO, llegada_1, ) %>% 
  unique() %>% 
  arrange(llegada_1) %>% 
  mutate(rank = dplyr::min_rank(llegada_1)) %>% 
  left_join(temp, .) -> temp

# etiquetas de llegada
temp %<>% 
  mutate(
    etiqueta_llegada_puesto = case_when(
      !is.na(llegada_1) ~ paste0("Puesto: ", rank)
    ),
    etiqueta_llegada_año = case_when(
      !is.na(llegada_1) ~ paste0("Año: ", llegada_1)
    )
  ) %>% 
  mutate_if(is.numeric, round, 1)


etiqueta <- "img/car.png"


#------------------------------------------------------------------
#------------------------------------------------------------------

# animacion
aa <- ggplot(temp, aes(x = DEPARTAMENTO, y = valor_1)) +
  geom_hline(yintercept = seq(0, 100, 25), colour = "gray", 
             size = 0.5, alpha = 0.8, linetype = "dotted") +
  geom_image(aes(image = etiqueta, color = DEPARTAMENTO), size = 0.17) +
  geom_text(aes(label = valor, size = 12, vjust = .5, hjust = .73)) +
  geom_text(aes(label = etiqueta_llegada_puesto, size = size, hjust = 2.3, vjust = -0.7)) +
  geom_text(aes(label = etiqueta_llegada_año, size = size, hjust = 2.2, vjust = 1.2)) +
  theme_ipsum_rc(base_size = 18, grid_col = F, subtitle_size = 28, 
                 plot_title_size = 30, axis_title_size = 20) +
  theme(
    legend.position = 'none',
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    axis.text.y = element_text(hjust = 0.5)
  ) +
  coord_flip() +
  labs(title = "Pobreza 0: quién y cuándo",
       subtitle = "Año: {closest_state}",
       y = "porcentaje de pobreza", 
       x = "",
       caption = "rafalopezv") + 
  scale_y_continuous(limits = c(-10, 110),
                     breaks = seq(0, 100, 25),
                     label = c("100%", "75%", "50%", "25%", "0%")) +
  transition_states(año, transition_length = 1,
                    state_length = 1, wrap = T) +
  ease_aes('linear') 

anim_save(
  animation = aa, 
  filename = "gif.gif",
  width  = 1200, 
  height = 900,  
  fps = 35, 
  duration = 35, start_pause = 35
)


