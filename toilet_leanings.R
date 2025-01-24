library(tidyverse)
library(sf)

# Read necessary data
toilets <- read_csv("data/toilets.csv")
toilet_mappings <- read_csv("data/toilet_polling_station_mapping.csv")
pp_leanings <- read_csv("data/pp_leanings.csv")

# Map toilets, to polling places, to political leanings
toilet_leanings <- toilets |>
  left_join(toilet_mappings) |>
  left_join(pp_leanings) |>
  select(Toilet = Name, ToiletAddress = Address1, PollingPlace, everything()) |>
  select(-FacilityID)

# Write combined data to file
toilet_leanings |> write_csv("data/toilet_leanings.csv")


## Plot political leaning toilets map
toilet_leanings |>
  st_as_sf(coords = c("Longitude", "Latitude")) |>
  st_set_crs(4326) |>
  ggplot() +
  aes(color = Leaning) +
  geom_sf() +
  coord_sf() +
  scale_colour_gradient2(low = "blue", mid = "gray", high = "red")
