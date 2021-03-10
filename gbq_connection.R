library(bigrquery)
library(tidyverse)


# pass service account token (porject and billing id included)
source("C:/Users/jmlhz/Documents/api_key.R")
bq_auth(path = "C:/Users/jmlhz/Documents/gbq_key.json")

# save a table to google bigquery
write_to_bq <- function(project, dataset, table, df, gcloud = FALSE){
  ### write a table
  # specify the dataset name
  print(paste("Stored in dataset ", dataset))
  # create a big query table object locally
  upload_table_prep <- bq_table(project, dataset, table = table)
  if (!bq_table_exists(upload_table_prep)){
    # create a table to google big query (cloud)
    bq_table_create(upload_table_prep, as_bq_fields(df))
    # write the dataframe to the cloud
    bq_table_upload(upload_table_prep, df)
  }
  # write the table to google cloud storage (need to go to UI to delete the table)
  if (gcloud == TRUE){
  # table url in second argument of the function
    bq_table_save(upload_table_prep, paste("gs://xw-riot-berlin-feb-2021/", deparse(substitute(df)), sep = ""))
  }
}
## delete a created table
# bq_table_delete

# #### fetch a table in dplyr fashion
# library(DBI)
# con <- dbConnect(
#   bigrquery::bigquery(),
#   project = project,
#   dataset = dataset,
#   billing = billing
# )
# fetch <- tbl(con, table) %>%
#   select(everything()) %>%
#   collect()

# 2021-02-24 upload champions_df and champions_spells_df
load("data/champion_stats_df.RData")
load("data/champions_spells_df.RData")
bq_dataset_create(bq_dataset(project, "riot_lol_champions_info"), location = "europe-west3")
write_to_bq(project, dataset = "riot_lol_champions_info", table = "champions_df", df = champions_df, gcloud = TRUE)
write_to_bq(project, dataset = "riot_lol_champions_info", table = "champions_spells_df", df = champions_spells_df, gcloud = TRUE)

# 2021-03-01 upload matches_df and queue_info_df
load("data/20210303_some_players_match_history.Rdata")
write_to_bq(project, dataset = "riot_lol_players_info", table = "matches_df", df = matches_df, gcloud = TRUE)
write_to_bq(project, dataset = "riot_lol_players_info", table = "queue_info_df", df = queue_info_df, gcloud = TRUE)

## execute sql
# read the sql file. Works when there is no "//" started comment
q1 <- read_file("./sql/logistic_table.sql")
# execte query within the project
t1_create <- bq_project_query(project, q1)
# return the result table
t1 <- bq_table_download(t1_create)

# deactivate access token
bq_deauth()
