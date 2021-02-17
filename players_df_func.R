library(tidyverse)

get_win_rate <- function(summoner_name){
  players_df <- get_players_dataframe(summoner_name)
  # calculate win rate of the summoner
  win_rate <- players_df %>%
    filter(summonerName == summoner_name) %>%
    summarize(mean(players_wl)) %>%
    pull(1)
  return(win_rate)
}

who_i_play_with <- function(summoner_name){
  # prep: summoner win label
  matches_summoner_win <- players_df %>%
    group_by(matchid) %>%
    filter(summonerName == summoner_name) %>%
    select(matchid, players_wl)
  # label teammates and opponents in each match. Enrich players_df 2
  players_df <- players_df %>%
    left_join(matches_summoner_win, by = c("matchid")) %>%
    group_by(matchid) %>%
    mutate(team = ifelse(players_wl.x == players_wl.y, 1, 0)) %>%
    ungroup() %>%
    select(-ends_with(c(".x", ".y")))
  
  # get teammates list
  participants_name <- list(team = unique(select(filter(players_df, team == 1), summonerName)))
  participants_name$opponent <- unique(select(filter(players_df, team == 0), summonerName))
  
  return(participants_name)
}