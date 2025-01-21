toilets <- read_csv('data/toilet_states.csv')
state_leanings <- read_csv('data/state_leanings.csv') %>%
  group_by(StateAb, leaning) %>%
  summarize(total_count = sum(total_count), relative_count=sum(relative_count)) %>%
  rename(State =StateAb) %>%
  select(-total_count) %>%
  pivot_wider(names_from=leaning,values_from=relative_count) %>%
  mutate(
    pol_leaning = `Conservative/Right`-`Progressive/Left`
  )

data <- toilets %>%
  left_join(state_leanings) %>%
  filter(!is.na(State))

data %>%
  ggplot() +
  geom_label() +
  aes(y=Male/Female, x=pol_leaning,label=State) +
  theme_light() +
  labs(title='Ratio of male vs female toilets per Australian state compared to political leaning')

data %>%
  ggplot() +
  geom_label() +
  aes(y=PaymentRequired, x=pol_leaning,label=State) +
  theme_light()
