# create a table ready for logistic regressions, containing matches info

# create kda
WITH generate_kda AS
    (SELECT 
        *,
        ROUND((kills + assists) / IF(deaths = 0, 1, deaths),
         1) AS kda
    FROM `graphite-cell-305418.riot_lol_players_info.matches_df`),
# create kda rank of each participant
    filter_low_performers AS
    (SELECT 
        *,
        # no ties rank
        ROW_NUMBER() OVER (
            PARTITION BY matchid, teamId
            ORDER BY kda) AS kda_rank
    FROM generate_kda),
# filter out 2 least performers in each team in each match
    filter_prep AS
    (SELECT * 
    FROM filter_low_performers
    WHERE kda_rank <= 3),
# create features for logsitic regression, a ratio of the average of variables across both teams
# the feature generation takes two steps. First average is calculated, then ratio across win/lose teams of averages is calculated
# the match history overlaps among some players. Therefore 815 matches have 806 distinct match id
    feature_first AS
# first
    (SELECT DISTINCT 
        matchId, 
        teamId,
        AVG(visionScore) OVER(
            PARTITION BY matchId, teamId
        ) AS avg_visionScore,
        AVG(totalDamageDealtToChampions) OVER(
            PARTITION BY matchId, teamId
        ) AS avg_damage,
        win
    FROM filter_prep),
# second
    logistic_table_win AS
    (SELECT 
        matchId, 
        teamId,
        avg_visionScore,
        LAG(avg_visionScore, 1) OVER(
            PARTITION BY matchId
            ORDER BY win) AS avg_visionScore_l,
        avg_damage,
        LAG(avg_damage, 1) OVER(
            PARTITION BY matchId
            ORDER BY win) AS avg_damage_l,    
        win
    FROM feature_first),

        logistic_table_lose AS
    (SELECT 
        matchId, 
        teamId,
        avg_visionScore,
        LAG(avg_visionScore, 1) OVER(
            PARTITION BY matchId
            ORDER BY win DESC) AS avg_visionScore_l,
        avg_damage,
        LAG(avg_damage, 1) OVER(
            PARTITION BY matchId
            ORDER BY win DESC) AS avg_damage_l,    
        win
    FROM feature_first),

       logistic_table AS
    (SELECT 
        matchId,
        teamId,
        avg_visionScore / NULLIF(avg_visionScore_l,0) AS vision_rt,
        avg_damage / NULLIF(avg_damage_l,0) AS damage_rt,
        win
    FROM logistic_table_win
    WHERE win = TRUE
    UNION ALL
    SELECT 
        matchId,
        teamId,
        avg_visionScore / NULLIF(avg_visionScore_l,0) AS vision_rt,
        avg_damage / NULLIF(avg_damage_l,0) AS damage_rt,
        win
    FROM logistic_table_lose
    WHERE win = FALSE
    ORDER BY matchId, teamId)

/*
CREATE OR REPLACE VIEW
  `model.logistic` AS
SELECT 
    *,
    CASE
    WHEN ROW_NUMBER() < 500 THEN 'training'
    WHEN ROW_NUMBER() > 500 AND ROW_NUMBER() < 1000 THEN 'evaluation'
    WHEN ROW_NUMBER() > 1000 THEN 'prediction'
  END AS dataframe
FROM logistic_table 
*/
CREATE OR REPLACE VIEW
  `model.logistic` AS
SELECT * FROM logistic_table 


