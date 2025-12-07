pacman::p_load(tidyverse)

players_raw <- read_csv("data/players_top1000_raw_12_4.csv",show_col_types = FALSE)

glimpse(players_raw)

players_clean <- players_raw %>%
  rename(rank= `Â`,
         player_id = `Player ID`,
         player_name = `Player Name`,
         total_overall = `Total (Overall)`,
         highest_paying_game = `Highest Paying Game`,
         total_game= `Total (Game)`,
         pct_of_total= `% of Total`)%>%
  mutate(rank= as.integer(rank),
         total_overall_usd = parse_number(total_overall),
         total_game_usd= parse_number(total_game),
         pct_of_total_num = parse_number(pct_of_total)) %>%
  select(rank,player_id,player_name,country,highest_paying_game,total_overall_usd,total_game_usd,pct_of_total_num,source_url) %>%
  arrange(rank)
glimpse(players_clean)

write_csv(players_clean, "data/players_top1000_clean_12_4.csv")

message("Saved clean Top 1000 players data to: data/players_top1000_clean_12_4.csv")

clean_players <- read_csv("data/players_top1000_clean_12_4.csv",
                          show_col_types = FALSE)
glimpse(clean_players)
