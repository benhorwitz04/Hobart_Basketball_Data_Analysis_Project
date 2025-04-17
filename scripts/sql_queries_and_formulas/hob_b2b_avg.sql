-- Create B2B table for Hobart

CREATE TABLE team_back_to_back_averages AS
WITH team_games AS (
    SELECT
        ts.team_id,
        ts.team_name,
        g.game_date,
        ts.fgm, ts.fga, ts.fgm3, ts.fga3, ts.ftm, ts.fta,
        ts.oreb, ts.dreb, ts.treb,
        ts.ast, ts.stl, ts.blk, ts.pf, ts.turnovers, ts.points,
        LAG(g.game_date) OVER (PARTITION BY ts.team_id ORDER BY g.game_date) AS prev_game_date
    FROM team_stats ts
    JOIN games g ON ts.game_id = g.game_id
),
second_day_b2bs AS (
    SELECT *
    FROM team_games
    WHERE prev_game_date IS NOT NULL
      AND AGE(game_date, prev_game_date) = INTERVAL '1 day'
)
SELECT
    team_id,
    team_name,
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
FROM second_day_b2bs
GROUP BY team_id, team_name;
