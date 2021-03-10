CREATE OR REPLACE MODEL
  `riot_lol_players_info.logistic_model`
OPTIONS
  ( model_type='LOGISTIC_REG',
    auto_class_weights=TRUE,
    data_split_method='NO_SPLIT',
    input_label_cols=['win']
  ) AS
SELECT
  * EXCEPT(nrow, matchId, teamId)
FROM
  `riot_lol_players_info.logistic_table`
WHERE
  nrow <= 500;