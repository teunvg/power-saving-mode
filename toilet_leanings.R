library(tidyverse)

toilets <- read_csv("data/toilets.csv")
toilet_mappings <- read_csv("data/toilet_polling_station_mapping.csv")
pp_leanings <- read_csv('data/pp_leanings.csv')

toilet_leanings <- toilets |>
  left_join(toilet_mappings) |>
  left_join(pp_leanings) |>
  select(toilet = Name, Address1, Town, State, leaning)
