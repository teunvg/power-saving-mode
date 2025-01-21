library(tidyverse)

# Read necessary data
toilets <- read_csv("data/toilets.csv")
toilet_mappings <- read_csv("data/toilet_polling_station_mapping.csv")
pp_leanings <- read_csv('data/pp_leanings.csv')

# Map toilets, to polling places, to political leanings
toilet_leanings <- toilets |>
  left_join(toilet_mappings) |>
  left_join(pp_leanings) |>
  select(Toilet = Name, Leaning=leaning, ToiletAddress = Address1, PollingPlace, everything()) |>
  select(-FacilityID)

# Write combined data to file
toilet_leanings |> write_csv("data/toilet_leanings.csv")

