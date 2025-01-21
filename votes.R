library(tidyverse)

df <- read_csv("data/vote_preferences_by_division.csv", skip=1) |>
  pivot_wider(names_from = CalculationType, values_from = CalculationValue) |>
  rename(c("preference_count" = `Preference Count`))

state_counts <- df |>
  group_by(StateAb, PartyNm) |>
  summarise(total_count = sum(preference_count)) |>
  arrange(StateAb, -total_count)
  group_by(StateAb) |>
  mutate(relative_count = total_count / sum(total_count))

state_counts |> 
  filter(relative_count >= 0.10) |>
  ungroup() |>
  distinct(PartyNm) |>
  write_csv("data/major_parties_list.csv")
