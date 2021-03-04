# create a table ready for logistic regressions, containing matches info

# create kda
WITH generate_kda AS
(SELECT 
  *,
  ROUND((kills + assists) / IF(deaths = 0, 1, deaths),
        1) AS kda
  FROM `graphite-cell-305418.riot_lol_players_info.matches_df`),
# filter out 2 least performers in each team in each match
filter_low_performers AS
(SELECT 
  *,
  # no ties rank
  ROW_NUMBER() OVER (
    PARTITION BY matchid, teamId
    ORDER BY kda) AS kda_rank
  FROM generate_kda),
# create features for logsitic regression, a ratio of the average of variables across both teams
logsitic_table AS
(SELECT * 
    FROM filter_low_performers
  WHERE kda_rank <= 3)

SELECT *
  FROM logsitic_table;