library(tidyverse)


# shove the files into archive
players_df_list <- list.files("./data") %>%
  str_subset(pattern = fixed("players_df"))

dir.create(file.path(getwd(), "data/archive"))
dir.create(file.path(getwd(), "data/archive/20210225"))

for (i in players_df_list){
  file_name <- i
  file.copy(from = paste("./data/", file_name, sep = ""), to = "./data/archive/20210225")
  file.remove(paste("./data/", file_name, sep = ""))
}

# union players_df datasets
df_list <- list()
for (i in players_df_list){
  file_name <- i
  # anything preceded by "df_" and followed by a dot
  df_name <- str_extract(file_name, "(?<=df_).*(?=\\.)")
  try({
    # load players_df
    load(paste("./data/archive/20210225/", file_name, sep = ""))
    df_list[[paste(df_name, sep = "")]] <- players_df
  })
}
players_df <- map_dfr(df_list, as.data.frame, .id = "history_of")
save(players_df, file = "./data/20210225_some_players_match_history.Rdata")
