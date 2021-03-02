## Question ##
# for a given summoner, in his/her recent matches, what's the average win rate of his teammates and opponents?


library(tidyverse)
library(jsonlite)
library(listviewer)

get_accountid <- function(summoner_name){
  # get api key
  source("C:/Users/jmlhz/Documents/riot/access_api.R")
  # summoner account id
  account_id <- get_content("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-name/", summoner_name)$accountId
  return(account_id)
}

get_matchid <- function(account_id){
  source("C:/Users/jmlhz/Documents/riot/access_api.R")
  # matches history of the specified summoner
  matches_summoner <- fromJSON(get_content("https://euw1.api.riotgames.com/lol/match/v4/matchlists/by-account/", account_id, as = "text"))$matches
  # matches_summoner_cleaned <- matches_summoner %>%
  #   mutate(date = as.POSIXct(timestamp/1000, origin = "1970-01-01"))
  match_id <- matches_summoner$gameId
  return(match_id)
}

get_matches_info <- function(summoner = "NA", match_id){
  source("C:/Users/jmlhz/Documents/riot/access_api.R")
  # historical stats of matches
  matches_game <- get_multiple("https://euw1.api.riotgames.com/lol/match/v4/matches/", identifier = match_id, "text")
  save(matches_game, file = paste("./data/", summoner, "_matches_info.RData", sep = ""))
  return(matches_game)
}

# prep: get a player's playing history dataframe, containing its teammates and opponents performance and info
get_players_dataframe <- function(summoner_name){
  
  source("C:/Users/jmlhz/Documents/riot/access_api.R")
  
  # summoner account id
  account_id <- get_accountid(summoner_name)
  
  # match id
  match_id <- get_matchid(account_id)
  
  # matches info (match_id a vector)
  matches_game <- get_matches_info(match_id)
  
  # qa: remove elements not conforming with majority(possibly due to bad return)
  t1 <- map(matches_game, length) %>%
    unlist() %>%
    unique() %>%
    # assumption is majority lists have larger length
    max()
  matches_game <- matches_game %>%
    keep(~length(.x) == t1)
  # save(matches_game, file = "data\matches_game.RData")
  # load("matches_game.RData")
  
  # getting all players info in each match
  
  # get fifth hierarchy
  players <- matches_game %>%
    map("participantIdentities") %>%
    map(~map(.x, "player"))
  
  # are players having homogeneous columns?
  # preserve match_id to be duplicated in the end dataframe
  # get third hierarchy
  matchid <- matches_game %>%
    map("gameId") %>%
    unlist()
  names(players) <- matchid
  players <- map(players, setNames, 1:10)
  map(players, length) %>%
    unique()
  # some players don't have account id in the data
  map(players, ~map(.x, .f = length)) %>%
    unlist() %>%
    keep(~mean(.x) == 7)
  
  # transform players list to dataframe
  names(players[[1]][[1]])
  # select preserved columns
  players_attributes <- c("platformId","matchHistoryUri", "summonerName", "profileIcon")
  players_df <- map_dfr(players, ~map_dfr(.x, `[`, players_attributes)) %>%
    # bind columns and rows from the list
    bind_cols(tibble(rep(matchid, each = 10)), 
              tibble(rep(1:10, times = length(matches_game)))) %>%
    rename(matchid = `rep(matchid, each = 10)`)
           # participant_label = `rep(1:10, times = length(matches_game)`)
  
  # get win&lose info of a participant
  players_wl <- matches_game %>%
    map("participants") %>%
    map(~map(.x, "stats")) %>%
    map(~map(.x, "win")) %>%
    unlist()
  
  # enrich players_df 1
  players_df <- players_df %>%
    bind_cols(tibble(players_wl))
  
  # qa if participants label match sequentially to label extracted from participants identities
  # this helps ensure the player level win&lose vector match the rows in players_df
  qa1 <- map(matches_game, "participants") %>%
    map(~map(.x, "participantId")) %>%
    unlist()
  
  qa2 <- map(matches_game, "participantIdentities") %>%
    map(~map(.x, "participantId")) %>%
    unlist()
  
  # stop when this is not true
  all(qa1 == qa2)    
  
  return(players_df)
}

# is 1-5 participants always one team?

# draft below
# all_participants <- matches_game$participantIdentities$player
# map(players, names)
# map(players, unnest)
# players <- map(players, unnest, cols = c(1:10))
# matches <- players %>%
#   map_dfr(~map_dfr(.x, `[`, players_attributes))
# ul1 <- unlist(players)
# t1 <- map(players, ~map(.x, ~append(.x, map(list(1:10), `[`))))
