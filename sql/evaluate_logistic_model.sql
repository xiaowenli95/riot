SELECT
  *
FROM
  ML.EVALUATE (MODEL `riot_lol_players_info.logistic_model`,
    (
  SELECT
    * EXCEPT(nrow, matchId, teamId)
  FROM
    `riot_lol_players_info.logistic_table`
  WHERE
    nrow > 500
    )
  )