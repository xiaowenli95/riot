#### get each player's stats in a match as dataframe
### the dataframe consists following variables
## third hierarchy
# gameId, match id of the game
# queueId, queue type of the match
# gameDuration
# mapId, map type of the match
## fifth hierarchy
# participantId
# teamId
# championId
## sixth hierarchy
# win, if a player wins the match
# kills, score of kills
# deaths
# assists, score of assiantace of kills
# longestTimeSpentLiving
# totalDamageDealtToChampions
# totalDamageDealtToChampions
# physicalDamageDealtToChampions
# trueDamageDealtToChampions
# totalHeal
# visionScore
# totalDamageTaken
# magicalDamageTaken
# physicalDamageTaken
# trueDamageTaken
# goldEarned
# goldSpent
# totalMinionsKilled
# totalTimeCrowdControlDealt
# wardsPlaced

library(tidyverse)
library(listviewer)

# load("./data/ Wildwo0olf _matches_info.RData")
# # jsonedit(matches_game, mode = "view")

get_matches_dataframe <- function(match_info){
  # first fetch all variables into lists, then bind rows to transform them into a dataframe
  # get third hierarchy. Dataframe of queue info
  queue_info_var <- c("gameId", "queueId", "gameDuration", "mapId")
  queue_info_df <- match_info %>%
    map(~.x[queue_info_var]) %>%
    map_dfr(~as.data.frame(.x))
  a <- list("queue_info_df" = queue_info_df)
  
  # get fifth hierarchy
  player_var_1 <- c("participantId", "teamId", "championId")
  # preserve matchid in the temporary dataframe for identification
  matchid <- unlist(map(match_info, ~as.character(.x["gameId"])))
  temp1 <- match_info %>%
    setNames(matchid) %>%
    # dive
    map(~.x["participants"]) %>%
    # extraction
    map(~map(.x, ~map(.x, ~.x[player_var_1]))) %>%
    # bind rows
    map_dfr(~map_dfr(.x, ~map_dfr(.x, ~as.data.frame(.x))), .id = "matchid")
  
  # get sixth hierarchy
  player_var_2 <- c("participantId",
                    "win",
                    "kills",
                    "deaths",
                    "assists",
                    "longestTimeSpentLiving",
                    "totalDamageDealtToChampions",
                    "totalDamageDealtToChampions",
                    "physicalDamageDealtToChampions",
                    "trueDamageDealtToChampions",
                    "totalHeal",
                    "visionScore",
                    "totalDamageTaken",
                    "magicalDamageTaken",
                    "physicalDamageTaken",
                    "trueDamageTaken",
                    "goldEarned",
                    "goldSpent",
                    "totalMinionsKilled",
                    "totalTimeCrowdControlDealt",
                    "wardsPlaced")
  temp2 <- match_info %>%
    setNames(matchid) %>%
    # dive 1
    map(~.x["participants"]) %>%
    # dive 2
    map(~map(.x, ~map(.x, ~.x["stats"]))) %>%
    # extraction
    map(~map(.x, ~map(.x, ~map(.x, ~.x[player_var_2])))) %>%
    # bind rows
    # some variables in 'stats' are missing for some players. Therefore 'keep' is used to filter out NULL items
    map_dfr(~map_dfr(.x, ~map_dfr(.x, ~map_dfr(.x, ~as.data.frame(keep(.x, ~!is.null(.x)))))), .id = "matchid")
  
  # merge temp tables
  matches_df <- temp1 %>%
    inner_join(temp2, by = c("matchid", "participantId"))
  
  a$"matches_df" <- matches_df
  return(a)
}

# stats length are the same even when there is a null item
# t3 <- unlist(map(temp2, ~map(.x, ~map(.x, ~map(.x, ~length(.x))))))
# keep(t3, ~.x != 21)
# 
# t4 <- unlist(map(temp2, ~map(.x, ~map(.x, ~length(.x)))))
# keep(t4, ~.x != 1)
# 
# t5 <- unlist(map(temp2, ~map(.x, ~length(.x))))
# keep(t5, ~.x != 1)
# purrr::flatten(match_info[48][[1]][['participants']][[1]][['stats']])
