library(tidyverse)

# get 200 players match info

# get one player's opponents and teammates
source("./players_df_func.R")
summoner_name <- "Wildwo0olf"
players_df <- get_players_dataframe(summoner_name)
a <- who_i_play_with(summoner_name, players_df)

# get each opponent match history (<=100)
# 12 players processed in the opponent list (20210303)
source("./players_info_func.R")
for (i in as.matrix(a[['opponent']])){
  summoner_name <- i
  account_id <- get_accountid(summoner_name)
  match_id <- get_matchid(account_id)
  a <- get_matches_info(summoner_name, match_id)
}

# create and union matches_df datasets
matches_info_list <- list.files("./data") %>%
  str_subset("^.*(?=_matches_info)")
df_list <- list()
# load the data transformation function
source("./matches_df.R")
queue_info_list <- list()
matches_list <- list()

for (i in matches_info_list){
  file_name <- i
  try({
    # load matches_game list
    load(paste("./data/", file_name, sep = ""))
    # get the list of dataframes
    b <- get_matches_dataframe(match_info = matches_game)
    # separate dataframes
    queue_info_list[[file_name]] <- b$"queue_info_df"
    matches_list[[file_name]] <- b$"matches_df"
  })
}

# create data frames
matches_df <- bind_rows(matches_list) %>%
  # drop duplicates
  select(!contains("."))
queue_info_df <- bind_rows(queue_info_list)

save(matches_df, queue_info_df, file = "./data/20210303_some_players_match_history.Rdata")

