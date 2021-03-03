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
