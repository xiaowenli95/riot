library(tidyverse)
library(httr)
library(jsonlite)

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

# summoner account id
summoner_name <- "Wildwo0olf"
account_id<- get_content("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-name/", summoner_name)$accountId

# matches history of the specified summoner
matches <- fromJSON(get_content("https://euw1.api.riotgames.com/lol/match/v4/matchlists/by-account/", account_id, as = "text"))$matches
matches_cleaned <- matches %>%
  mutate(date = as.POSIXct(timestamp/1000, origin = "1970-01-01"))

# historical stats of each match

  
  
  
  
## draft below
# url <- paste("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-account/", summoner, "?api_key=", key, sep = "")
