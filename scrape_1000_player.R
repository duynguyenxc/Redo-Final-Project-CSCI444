pacman::p_load(tidyverse, rvest)

if (!dir.exists("data")) {
  dir.create("data")
}

output_file <- "data/players_top1000_raw_12_4.csv"

player_urls <- c(
  "https://www.esportsearnings.com/players/highest-earnings",
  "https://www.esportsearnings.com/players/highest-earnings-top-200",
  "https://www.esportsearnings.com/players/highest-earnings-top-300",
  "https://www.esportsearnings.com/players/highest-earnings-top-400",
  "https://www.esportsearnings.com/players/highest-earnings-top-500",
  "https://www.esportsearnings.com/players/highest-earnings-top-600",
  "https://www.esportsearnings.com/players/highest-earnings-top-700",
  "https://www.esportsearnings.com/players/highest-earnings-top-800",
  "https://www.esportsearnings.com/players/highest-earnings-top-900",
  "https://www.esportsearnings.com/players/highest-earnings-top-1000"
)

scrape_players_page <- function(url) {
  message("Scraping: ", url)
  page <- read_html(url)
  table_nodes <- page %>%
    html_elements("table")
  all_tables <- table_nodes %>%
    html_table(fill = TRUE)
  if (length(all_tables) == 0) {
    warning("No tables found on page: ", url)
    return(tibble())
  }
  n_rows<- sapply(all_tables, nrow)
  best_idx <- which.max(n_rows)
  players_tbl <-all_tables[[best_idx]]
  players_table_node <- table_nodes[[best_idx]]
  row_nodes <- players_table_node %>%
    html_elements("tr") %>%
    keep(~ length(html_elements(.x, "td")) > 0) %>%
    discard(~ length(html_elements(.x, "th")) > 0)
  
  country_vec <- map_chr(row_nodes, function(tr) {
    img_node <- tr %>% html_element("img")
    if (length(img_node) == 0) {
      return(NA_character_)
    } else {
      return(html_attr(img_node, "alt"))
    }
  })
  if (length(country_vec) != nrow(players_tbl)) {
    warning("Country vector length (", length(country_vec),
            ") != nrow(players_tbl) (", nrow(players_tbl),
            ") for url: ", url)
    len <- min(length(country_vec), nrow(players_tbl))
    country_vec <- country_vec[seq_len(len)]
    if (len < nrow(players_tbl)) {
      country_vec <- c(country_vec,
                       rep(NA_character_, nrow(players_tbl) - len))
    }
  }
  
  players_tbl <- players_tbl %>%
    mutate(
      country = country_vec,
      source_url = url
    )
  
  return(players_tbl)
}
players_top1000_raw_12_4 <- player_urls %>%
  map_dfr(scrape_players_page)

glimpse(players_top1000_raw_12_4)

write_csv(players_top1000_raw_12_4, output_file)

message("Saved raw Top 1000 players data to: ", output_file)

players_top1000_raw_12_4

