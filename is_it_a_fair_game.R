library(tidyverse)


## calculate win rate of the summoner's teammates vs opponents 
# (what about time frame? Participants have history)

summoner_name <- "Wildwo0olf"

their_win_rate <- function(summoner_name, they = "team"){
  # load functions
  source("C:/Users/jmlhz/Documents/riot/players_df.R")
  source("C:/Users/jmlhz/Documents/riot/players_df_func.R")
  
  my_win_rate <- get_win_rate(summoner_name)
  i_played_with <- who_i_play_with(summoner_name)
  team <- i_played_with[["team"]][1:2]
  their_win_rate <- list()
  m = 1
  for (i in team){
    their_win_rate[[m]] <- get_win_rate(i)
    m = m + 1
  }
  return(their_win_rate)
}

tw <- their_win_rate(summoner_name)
