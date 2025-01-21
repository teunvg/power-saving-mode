library(tidyverse)

## Define states
states = c("ACT","NSW","NT","QLD","SA","TAS", "VIC","WA")

## Collapse same parties with "different" names
parties_major <- read_csv('data/party-merge') |>
  rename(PartyNm = Party_Was, Party=Party_Be)

parties_leaning <- read_csv('data/party-leanings') |>
  rename(p_or_c=`p-or-c`, l_or_r=`l-or-r`) |>
  filter(!is.na(l_or_r))


## Load polling places
pps <- read_csv("data/pps_ACT.csv", skip=1)
for (state in states[-1]) {
  pps <- bind_rows(pps, read_csv(str_glue("data/pps_", state, ".csv"), skip=1))
}
pps <- pps |>
  select(StateAb, DivisionID, DivisionNm, PollingPlaceID, PollingPlace, PartyNm, OrdinaryVotes)

## Clean party names
pps <- pps |>
  left_join(parties_major) |>
  select(-PartyNm) |>
  drop_na()

pp_leanings <- pps |> 
  group_by(StateAb, DivisionID, DivisionNm, PollingPlaceID, PollingPlace, Leaning) |>
  summarise(OrdinaryVotes = sum(OrdinaryVotes)) |>
  group_by(StateAb, DivisionID, DivisionNm, PollingPlaceID, PollingPlace) |>
  mutate(ppt_votes = OrdinaryVotes / sum(OrdinaryVotes)) |>
  select(-OrdinaryVotes) |>
  pivot_wider(names_from=Leaning, values_from=ppt_votes) |>
  mutate(leaning = Conservative - Progressive)

pp_leanings |> write_csv('data/pp_leanings.csv')
