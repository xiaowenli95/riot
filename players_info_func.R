#

get_accountid <- function(summoner_name){
  # get api key
  source("./access_api.R")
  # summoner account id
  account_id <- get_content("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-name/", summoner_name)$accountId
  return(account_id)
}

get_matchid <- function(account_id){
  source("./access_api.R")
  # matches history of the specified summoner
  matches_summoner <- fromJSON(get_content("https://euw1.api.riotgames.com/lol/match/v4/matchlists/by-account/", account_id, as = "text"))$matches
  # matches_summoner_cleaned <- matches_summoner %>%
  #   mutate(date = as.POSIXct(timestamp/1000, origin = "1970-01-01"))
  match_id <- matches_summoner$gameId
  return(match_id)
}

get_matches_info <- function(summoner = "NA", match_id){
  # the function takes a vector (match_id), repeats api calls to store result in a list, and save RData files (matches_info)
  source("./access_api.R")
  # historical stats of matches
  # one player per 2 mins according to get_multiple function rate limit
  matches_game <- get_multiple("https://euw1.api.riotgames.com/lol/match/v4/matches/", identifier = match_id[1:80], "text")
  save(matches_game, file = paste("./data/", summoner, "_matches_info.RData", sep = ""))
  return(matches_game)
}