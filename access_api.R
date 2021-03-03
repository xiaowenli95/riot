library(httr)

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
  # the function takes a vector (identifier) and repeats api calls to store results into a list
  a <- list()
  # count
  m = 1
  for (i in identifier) {
    a[[m]] <- get_content(url_component, i, as = "parsed")
    # rate limit of 20 per sec
    Sys.sleep(0.05)
    if (m == 80) {
      # rate limit of 100 per 2 mins
      Sys.sleep(120)
    }
    m = m + 1
  }
  return(a)
}


## draft below
# url <- paste("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-account/", summoner, "?api_key=", key, sep = "")
# matches_game <- fromJSON(get_content("https://euw1.api.riotgames.com/lol/match/v4/matches/", match_id[1], "text"))

