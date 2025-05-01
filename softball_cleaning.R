library(vroom)
library(dplyr)
library(tidyr)

data <- vroom("Softball Data - Data.csv")

home_stats <- data %>%
  filter(HA == "Home") %>%
  select(-HA) %>%
  rename_with(~paste0(., "_Home"), -c(Player, Team, POS, CF))

away_stats <- data %>%
  filter(HA == "Away") %>%
  select(-HA) %>%
  rename_with(~paste0(., "_Away"), -c(Player, Team, POS, CF))

# Merge Home and Away stats by Player, Team, Conference, and POS
df_combined <- left_join(home_stats, away_stats, 
                         by = c("Player", "Team", "POS", "CF")) %>%
  mutate(PS = BA_Home - BA_Away) %>%
  select(-PS_Home, -PS_Away) 

ws_teams <- c("Alabama", "UCLA", "Duke", "Oklahoma", 
              "Texas", "Stanford", "Oklahoma State", "Florida")

df_combined <- df_combined %>%
  mutate(WS = if_else(Team %in% ws_teams, 1, 0))

p4_conferences <- c("Big Ten", "Big 12", "Southeastern", "Atlantic Coast")

df_combined <- df_combined %>%
  mutate(P4 = if_else(CF %in% p4_conferences, 1, 0))

df_combined <- df_combined %>%
  select(-CF, -Team)

write.csv(df_combined, "softball_data.csv", row.names = FALSE)
