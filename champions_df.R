library(tidyverse)

current_patch <- "11.4.1"
champion_summary_url <- paste("http://ddragon.leagueoflegends.com/cdn/", current_patch, 
                      "/data/en_US/champion.json", sep = "")
champion_summary <- content(GET(champion_summary_url), as = "parsed")
listviewer::jsonedit(champion_summary, mode = "view")

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
listviewer::jsonedit(champion_specifics[[3]], mode = "view")

load("data/champion_specifics.RData")

listviewer::jsonedit(champion_specifics, mode = "view")

# effectburn keeps values of (nonexhaustive) controlling period, damage values, cost values (if health)
# details of a spell related values can be put in vars, effectBurn, or costBurn
# most likely unified metrics of spells across champions are cooldownBurn, costBurn, rangeBurn
# a dataset to check how many champions have no effect burn variable
# champion spell1 effectburn 1
# champion spell1 effectburn 2
# champion spell2 effectburn 1
# get champion spell variables
get_spell_var <- function(var, var_rename){
  champions_df <- champion_specifics %>%
    map(~map(.x, `[`, "spells")) %>%
    map(~map(.x, ~map(.x, ~map(.x, var)))) %>%
    map_dfc(unlist) %>%
    mutate(label = c("Q", "W", "E", "R")) %>%
    pivot_longer(!label,  names_to = "champion", values_to = var_rename) %>%
    mutate(key = names(var_rename)) %>%
    arrange(champion)
  return(champions_df)
}

effectburn <- champion_specifics %>%
  # get spells sublist
  map(~map(.x, `[`, "spells")) %>%
  # get effectBurn sublist
  map(~map(.x, ~map(.x, ~map(.x, "effectBurn")))) %>%
  # label each spell
  map(~map(.x, ~map(.x, setNames, c("Q", "W", "E", "R")))) %>%
  # consolidate a dataframe
  map_dfr(
    ~map_dfr(.x, 
             ~map_dfr(.x, 
                      ~map_dfr(.x, 
                               ~as.data.frame(as.matrix(.x)), .id = "label"))), .id = "champion") %>%
  rename(effectburn_value = V1) %>%
  # remove first null in every spell
  group_by(champion) %>%
  filter(effectburn_value != "NULL") %>%
  ungroup()

champions_df <- get_spell_var("id", "spell1") %>%
  # enrich champions_df by spell name
  left_join(get_spell_var("name", "spell2"),
            by = c("champion" = "champion", "label" = "label")) %>%
  # enrich champions_df by spell value
  left_join(effectburn,
            by = c("champion" = "champion", "label" = "label"))

# 29 champions have no effect burn values
champions_df %>%
  group_by(champion) %>%
  filter(map_lgl(effectburn_value, ~.x != 0)) %>%
  ungroup() %>%
  distinct(champion)


# for every spell sublist, only variables id, name and effectburn are kept


# is champion key same as champion id?
load("data/matches_game.RData")
