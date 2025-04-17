WITH hobart_games AS (
    SELECT
        ts.team_id,
        ts.game_id,
        g.game_date,
        ts.points,
        LAG(g.game_date) OVER (ORDER BY g.game_date) AS prev_game_date
    FROM team_stats ts
    JOIN games g ON ts.game_id = g.game_id
    WHERE ts.team_id = 'HOB'
),
hobart_b2b_games AS (
    SELECT *
    FROM hobart_games
    WHERE prev_game_date IS NOT NULL
      AND AGE(game_date, prev_game_date) = INTERVAL '1 day'
),
opponent_scores AS (
    SELECT
        game_id,
        points AS opp_points
    FROM team_stats
    WHERE team_id != 'HOB'
)
SELECT
    h.game_id,
    h.game_date,
    h.points AS hob_points,
    o.opp_points,
    CASE 
        WHEN h.points > o.opp_points THEN 'Win'
        WHEN h.points < o.opp_points THEN 'Loss'
        ELSE 'Tie'
    END AS result
FROM hobart_b2b_games h
JOIN opponent_scores o ON h.game_id = o.game_id
ORDER BY h.game_date;
