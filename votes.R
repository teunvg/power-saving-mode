library(tidyverse)

df <- read_csv("data/vote_preferences_by_division.csv", skip=1) |>
  pivot_wider(names_from = CalculationType, values_from = CalculationValue) |>
  rename(c("preference_count" = `Preference Count`))

state_counts <- df |>
  group_by(StateAb, PartyNm) |>
  summarise(total_count = sum(preference_count)) |>
  arrange(StateAb, -total_count) |>
  group_by(StateAb) |>
  mutate(relative_count = total_count / sum(total_count))

state_counts |> 
  filter(relative_count >= 0.10) |>
  ungroup() |>
  distinct(PartyNm) |>
  write_csv("data/major_parties_list.csv")

###-- party import and cleaning
parties_major <- read_csv('data/party-merge') |>
  rename(PartyNm = Party_Was, Party=Party_Be)

parties_leaning <- read_csv('data/party-leanings') |>
  rename(p_or_c=`p-or-c`, l_or_r=`l-or-r`) |>
  filter(!is.na(l_or_r))

state_leanings <- state_counts |>
  left_join(parties_major) |>
  left_join(parties_leaning) %>%
  mutate(
    p_or_c = ifelse(p_or_c < 0, 'p', 'c'),
    l_or_r = ifelse(l_or_r < 0, 'l', 'r'),
    leaning = ifelse(p_or_c=='p', 'Progressive/Left', 'Conservative/Right')
  ) |>
  select(-PartyNm, -p_or_c, -l_or_r) %>%
  mutate(Party = ifelse(Party == 'Independent', NA, Party)) |>
  group_by(StateAb, Party, leaning) %>%
  summarize(
    total_count = sum(total_count),
    relative_count = sum(relative_count)
  )

state_leanings |> write_csv('data/state_leanings.csv')
