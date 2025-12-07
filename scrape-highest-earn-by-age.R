pacman::p_load(tidyverse, rvest)

age_url <- "https://www.esportsearnings.com/players/highest-earnings-by-age"

age_page <- read_html(age_url)

age_rows <- age_page %>%
  html_elements("table.detail_list_table tr")

age_df <- age_rows %>%
  map(~ .x %>% html_elements("td") %>% html_text2()) %>%   
  keep(~ length(.x) == 4) %>%                   
  map_dfr(~ tibble(rank_label = .x[1],age_label = .x[2],total_prize_raw = .x[3],n_players_raw   = .x[4]))

age_clean <- age_df %>%
  mutate(age = str_extract(age_label, "\\d+"),
         age = as.integer(age),
         total_prize_usd = parse_number(total_prize_raw),
         n_players = parse_number(n_players_raw),
         rank = parse_number(rank_label))%>%
  select(rank, age, total_prize_usd, n_players) %>%
  arrange(rank)

if (!dir.exists("data")) {
  dir.create("data")
}

output_file <- "data/esports_earnings_by_age.csv"
write_csv(age_clean, output_file)

message("Saved age earnings data to: ", output_file)

print(head(age_clean))
