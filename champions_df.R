library(tidyverse)

current_patch <- "11.4.1"
champion_summary_url <- paste("http://ddragon.leagueoflegends.com/cdn/", current_patch, 
                      "/data/en_US/champion.json", sep = "")
champion_summary <- content(GET(champion_summary_url), as = "parsed")
jsonedit(champion_summary, mode = "view")

# as a first step, the dataframe needs columns "id, key, tags, stats"
# v1 <- map_chr(champion_summary$data, "id")
v2 <- map_chr(champion_summary$data, "key") %>%
  data.frame() %>%
  rownames_to_column("champion_name") %>%
  rename(key = ".")
v3 <- map(champion_summary$data, "tags") %>%
  # filter champions that don't have secondary tags
  keep(~length(.x) == 1) %>%
  # insert secondary tag where it's null
  map(~append(.x, NA)) %>%
  # join to champions having both tags
  append(values = map(champion_summary$data, "tags") %>%
           # filter champions that don't have secondary tags
           keep(~length(.x) == 2))
v3_1 <- map_chr(v3, ~.x[[1]]) %>%
  data.frame() %>%
  rownames_to_column("champion_name") %>%
  rename(first_label = ".")
v3_2 <- map_chr(v3, ~.x[[2]]) %>%
  data.frame() %>%
  rownames_to_column("champion_name") %>%
  rename(second_label = ".")
v4 <- map(champion_summary$data, "stats")

champions_df <- v4 %>%
  map_dfr(~data.frame(.x), .id = "champion_name") %>%
  inner_join(v2, by = "champion_name") %>%
  inner_join(v3_1, by = "champion_name") %>%
  inner_join(v3_2, by = "champion_name")

# enrich champion data with specifics (spells and passive)
get_champion_specifics <- function(champion_name, current_patch = "11.4.1"){
  current_patch <- current_patch
  champion_url <- paste("http://ddragon.leagueoflegends.com/cdn/", current_patch, 
                                "/data/en_US/champion/", champion_name, ".json", sep = "")
  champion_summary <- content(GET(champion_url), as = "parsed")$data
  Sys.sleep(0.05)
  return(champion_summary)
}
champion_specifics <- list()
for (i in champions_df$champion_name[101:length(champions_df$champion_name)]){
  champion_specifics[[i]] <- get_champion_specifics(i)
}
# save(champion_specifics, file = "data/champion_specifics.RData")

# qa: Akali Q has no spell value in effect burn variable
jsonedit(champion_specifics[[3]], mode = "view")

# is champion key same as champion id?
load("data/matches_game.RData")