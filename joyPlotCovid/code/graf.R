# pruebas de tamaño grafico joy plot

df_mundo %>% 
  filter(casos_acumulados != 0) %>% 
  group_by(pais_region) %>% 
  summarise(
    fecha = min(fecha)
  ) %>% 
  arrange(fecha) %>% 
  mutate(num = 1:nrow(.)) -> orden

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
    # panel.spacing = unit(-.55, "cm", data = NULL), 
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
    caption = "· Data until august 23,2022 · New cases per week · 941 days · 595 MM infected · 6.4 MM deaths · rafalopezv",
    title = "- Each line is 1 of 194 countries -"
  )

ggsave("/Users/rafalopezv/Desktop/covid_all.png", height = 28, width = 22, dpi = 300, units = "cm")