CREATE TABLE opp_back_to_back_averages AS
WITH hobart_games AS (
    SELECT
        ts.team_id,
        ts.game_id,
        g.game_date,
        LAG(g.game_date) OVER (ORDER BY g.game_date) AS prev_game_date
    FROM team_stats ts
    JOIN games g ON ts.game_id = g.game_id
    WHERE ts.team_id = 'HOB'
),
hobart_b2b_second_day AS (
    SELECT *
    FROM hobart_games
    WHERE prev_game_date IS NOT NULL
      AND AGE(game_date, prev_game_date) = INTERVAL '1 day'
),
opponent_stats AS (
    SELECT ts.*
    FROM team_stats ts
    WHERE ts.game_id IN (SELECT game_id FROM hobart_b2b_second_day)
      AND ts.team_id != 'HOB'
)
SELECT
    COUNT(*) AS games_played,
    ROUND(AVG(fgm)::numeric, 2) AS avg_fgm,
    ROUND(AVG(fga)::numeric, 2) AS avg_fga,
    ROUND(AVG(fgm3)::numeric, 2) AS avg_fgm3,
    ROUND(AVG(fga3)::numeric, 2) AS avg_fga3,
    ROUND(AVG(ftm)::numeric, 2) AS avg_ftm,
    ROUND(AVG(fta)::numeric, 2) AS avg_fta,
    ROUND(AVG(oreb)::numeric, 2) AS avg_oreb,
    ROUND(AVG(dreb)::numeric, 2) AS avg_dreb,
    ROUND(AVG(treb)::numeric, 2) AS avg_treb,
    ROUND(AVG(ast)::numeric, 2) AS avg_ast,
    ROUND(AVG(stl)::numeric, 2) AS avg_stl,
    ROUND(AVG(blk)::numeric, 2) AS avg_blk,
    ROUND(AVG(turnovers)::numeric, 2) AS avg_tov,
    ROUND(AVG(pf)::numeric, 2) AS avg_pf,
    ROUND(AVG(points)::numeric, 2) AS avg_pts
FROM opponent_stats;
