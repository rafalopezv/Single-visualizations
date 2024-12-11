# about: data prep for  beeswarm  plot
library(tidyverse)
library(magrittr)
library(WDI)

source("function.R")

df <- rio::import("DataForFigure2.1+with+sub+bars+2024.xls")

df %>% 
  janitor::clean_names() %>% 
  select(country_name, ladder_score) -> df

gdp <- WDI(indicator = "NY.GDP.PCAP.CD")

gdp %>% 
  select(
    -iso2c,
    country_name = country,
    gdp = NY.GDP.PCAP.CD
  ) %>% 
  spread(year, gdp) %>% 
  mutate(
    gdp = case_when(
      !is.na(`2022`) ~ `2022`,
      T ~ `2021`
    )
  ) %>% 
  select(iso3c, country_name, gdp) -> gdp1

df$country_name[!df$country_name %in% gdp1$country]
gdp1$country_name %<>% gsub("Korea\\, Rep\\.", "South Korea", .)
gdp1$country_name %<>% gsub("Russian Federation", "Russia", .)
gdp1$country_name %<>% gsub("Viet Nam", "Vietnam", .)
gdp1$country_name %<>% gsub("Kyrgyz Republic", "Kyrgyzstan", .)
gdp1$country_name %<>% gsub("Venezuela\\, RB", "Venezuela", .)
gdp1$country_name %<>% gsub("Hong Kong SAR\\, China", "Hong Kong S.A.R. of China", .)
gdp1$country_name %<>% gsub("Congo\\, Rep\\.", "Congo (Brazzaville)", .)
gdp1$country_name %<>% gsub("Cote d'Ivoire", "Ivory Coast", .)
gdp1$country_name %<>% gsub("Lao PDR", "Laos", .)
gdp1$country_name %<>% gsub("Iran\\, Islamic Rep\\.", "Iran", .)
gdp1$country_name %<>% gsub("Egypt\\, Arab Rep\\.", "Egypt", .)
gdp1$country_name %<>% gsub("Yemen\\, Rep\\.", "Yemen", .)
gdp1$country_name %<>% gsub("Congo, Dem. Rep.", "Congo (Kinshasa)", .)
gdp1$country_name %<>% gsub("Slovak Republic", "Slovakia", .)
gdp1$country_name %<>% gsub("Gambia, The", "Gambia", .)
gdp1$country_name %<>% gsub("West Bank and Gaza", "State of Palestine", .)
df$country_name[!df$country_name %in% gdp1$country]

df %>% 
  left_join(., gdp1) %>% 
  mutate(
    gdp = case_when(
      country_name == "Taiwan Province of China" ~ 32690,
      T ~ gdp
    )
  ) %>% 
  filter(!is.na(gdp)) -> final

# add continents
countrycode::codelist %>% 
  select(continent, iso3c) %>% 
  left_join(final, .) %>%
  # correcting many repeated Taiwan entries
  mutate(
    continent = case_when(
      country_name == "Taiwan Province of China" ~ "Asia",
      country_name == "Kosovo" ~ "Europe",
      T ~ continent
    ),
    ladder_score = round(ladder_score, 2),
    gdp = round(gdp, 0)
  ) %>% 
  unique -> final


# converting
final %>% 
  convert_to_js_objects(file_path = "../vis/src/data/data1.js")


