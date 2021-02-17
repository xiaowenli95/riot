library(tidyverse)
library(httr)
library(jsonlite)
library(listviewer)

# access api key, stored locally
source("C:/Users/jmlhz/Documents/api_key.R")
# routed url syntax e.g. https://api-id.execute-api.us-east-2.amazonaws.com/pets/6.

# get content function that gets the content of each api access
get_content <- function(url_component, identifier, as = "parsed"){
  url <- paste(url_component, identifier, "?api_key=", key, sep = "")
  return <- GET(url)
  print(paste("Return data type is ", http_type(return), sep = ""))
  content <- content(return, as = as)
  return(content)
}

# multiple requests with rate limits
get_multiple <- function(url_component, identifier,  as = "parsed"){
  # storing returns of each call
  a <- list()
  # count
  m = 1
  for (i in identifier) {
    a[[m]] <- get_content(url_component, i, as = "parsed")
    # rate limit of 20 per sec
    Sys.sleep(0.05)
    if (m == 100) {
      # rate limit of 100 per 2 mins
      Sys.sleep(120)
    }
    m = m + 1
  }
  return(a)
}

# summoner account id
summoner_name <- "Wildwo0olf"
account_id<- get_content("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-name/", summoner_name)$accountId

# matches history of the specified summoner
matches_summoner <- fromJSON(get_content("https://euw1.api.riotgames.com/lol/match/v4/matchlists/by-account/", account_id, as = "text"))$matches
matches_summoner_cleaned <- matches_summoner %>%
  mutate(date = as.POSIXct(timestamp/1000, origin = "1970-01-01"))
match_id <- matches_summoner_cleaned$gameId

# historical stats of matches
matches_game <- get_multiple("https://euw1.api.riotgames.com/lol/match/v4/matches/", identifier = match_id, "text")
save(matches_game, file = "matches_game.RData")
load("matches_game.RData")

# getting all players info in each match
# preserve match_id to be duplicated in the end dataframe
matchid <- matches_game %>%
  map("gameId") %>%
  unlist()

players <- matches_game %>%
  map("participantIdentities") %>%
  map(~map(.x, "player"))

# are players having homogeneous columns?
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

# bind columns and rows from the list
players_df <- map_dfr(players, ~map_dfr(.x, `[`, players_attributes)) %>%
  bind_cols(tibble(rep(matchid, each = 10)), 
            tibble(rep(1:10, times = 100))) %>%
  rename(matchid = `rep(matchid, each = 10)`,
         participant_label = `rep(1:10, times = 100)`)
  
  


## draft below
# url <- paste("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-account/", summoner, "?api_key=", key, sep = "")
# matches_game <- fromJSON(get_content("https://euw1.api.riotgames.com/lol/match/v4/matches/", match_id[1], "text"))
# all_participants <- matches_game$participantIdentities$player
# map(players, names)
# map(players, unnest)
# players <- map(players, unnest, cols = c(1:10))
# matches <- players %>%
#   map_dfr(~map_dfr(.x, `[`, players_attributes))
# ul1 <- unlist(players)
# t1 <- map(players, ~map(.x, ~append(.x, map(list(1:10), `[`))))

