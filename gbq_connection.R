library(bigrquery)
library(tidyverse)


# connect to google big query
load("C:/Users/jmlhz/Documents/riot/data/players_df_Hararplays.RData")
write.csv(players_df, file = "data/players_df_Hararplays.csv")

# pass service account token (porject and billing id included)
bq_auth(path = "C:/Users/jmlhz/Documents/gbq_key.json")

### write a table
# specify the dataset name
dataset <- "riot_lol_players_info"
# create a big query table object
table_trial <- bq_table(project, dataset, table = "upload_trial")
# reduce dataframe size
players_df <- players_df[,1]
# write the table to google big query
bq_table_trial <- bq_table_create(t1, as_bq_fields(players_df))
## delete a created table
# bq_table_delete
# write the table to google cloud storage (need to go to UI to delete the table)
# table url in second argument of the function
bq_table_save(bq_table_trial, "gs://xw-riot-berlin-feb-2021/uploadtrial.csv")

#### fetch a table in dplyr fashion
library(DBI)
con <- dbConnect(
  bigrquery::bigquery(),
  project = project,
  dataset = dataset,
  billing = billing
)
fetch <- tbl(con, table) %>%
  select(everything()) %>%
  collect()

# deactivate access token
bq_deauth()
