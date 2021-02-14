library(dplyr)
library(httr)
library(jsonlite)

# acess api
key <- "RGAPI-a3bed222-98d3-41b1-b302-63c8ca7b25f0"
# routed url syntax e.g. https://api-id.execute-api.us-east-2.amazonaws.com/pets/6.

# summoner stats
summoner_name <- "Wildwo0olf"
url1 <- paste("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-name/", summoner_name, "?api_key=", key, sep = "")
# the returning data format is json
return1 <- GET(url1)
http_type(return)
# get the id/puuid
content1 <- content(return, as = "parsed")
account_id <- content$accountId

# matches history
url2 <- paste("https://euw1.api.riotgames.com/lol/match/v4/matchlists/by-account/", account_id, "?api_key=", key, sep = "")
return2 <- GET(url2)
content2_parsed <- content(return2, as = "parsed") 
content2 <- content(return2, as = "text") 
matches <- fromJSON(content2)$matches
  
  
  
  
  
  

# url <- paste("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-account/", summoner, "?api_key=", key, sep = "")
