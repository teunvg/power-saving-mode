library(tidyverse)

## Define states
states <- c("ACT", "NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA")

## Load polling places
pps <- read_csv("data/pps_ACT.csv", skip = 1)
for (state in states[-1]) {
  pps <- bind_rows(pps, read_csv(str_glue("data/pps_", state, ".csv"), skip = 1))
}
pps <- pps |>
  select(StateAb, DivisionID, DivisionNm, PollingPlaceID, PollingPlace, PartyNm, OrdinaryVotes)

## Collapse parties into leanings, same parties with "different" n
parties_major <- read_csv("data/party-merge") |>
  rename(PartyNm = Party_Was, Party = Party_Be)

pps <- pps |>
  left_join(parties_major) |>
  mutate(Party = replace_na(Party, "Other"),
         Leaning = replace_na(Leaning, "Other")) |>
  mutate(Party = fct(Party),
         Leaning = fct(Leaning))

## Calculate votes and leanings per PP
pp_leanings <- pps |>
  group_by(StateAb, DivisionID, DivisionNm, PollingPlaceID, PollingPlace, Leaning) |>
  summarise(OrdinaryVotes = sum(OrdinaryVotes)) |>
  pivot_wider(names_from = Leaning, values_from = OrdinaryVotes) |>
  mutate(TotalVotes = Progressive + Conservative + Other) |>
  pivot_longer(c(Progressive, Conservative, Other), names_to = "Leaning", values_to = "OrdinaryVotes") |>
  group_by(StateAb, DivisionID, DivisionNm, PollingPlaceID, PollingPlace) |>
  mutate(ppt_votes = OrdinaryVotes / TotalVotes) |>
  select(-OrdinaryVotes) |>
  pivot_wider(names_from = Leaning, values_from = ppt_votes) |>
  mutate(Leaning = Conservative - Progressive)

pp_leanings |> write_csv("data/pp_leanings.csv")
