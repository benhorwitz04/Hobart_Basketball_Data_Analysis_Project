-- Most wins and losses for Hobart

WITH hobart_wins AS (
    SELECT
        game_date
    FROM team_stats
    WHERE team_id = 'HOB' AND is_win = TRUE
),
hobart_all_games AS (
    SELECT
        game_date
    FROM team_stats
    WHERE team_id = 'HOB'
),
opponent_wins AS (
    SELECT
        ts.game_date,
        ts.team_id AS opponent_id,
        ts.team_name AS opponent_name
    FROM team_stats ts
    JOIN hobart_wins hw ON ts.game_date = hw.game_date
    WHERE ts.team_id != 'HOB'
),
opponent_total_games AS (
    SELECT
        ts.game_date,
        ts.team_id AS opponent_id
    FROM team_stats ts
    JOIN hobart_all_games hg ON ts.game_date = hg.game_date
    WHERE ts.team_id != 'HOB'
),
win_summary AS (
    SELECT
        ow.opponent_id,
        ow.opponent_name,
        COUNT(*) AS hobart_wins
    FROM opponent_wins ow
    GROUP BY ow.opponent_id, ow.opponent_name
),
game_counts AS (
    SELECT
        otg.opponent_id,
        COUNT(*) AS games_played
    FROM opponent_total_games otg
    GROUP BY otg.opponent_id
)
SELECT
    ws.opponent_id,
    ws.opponent_name,
    gc.games_played,
    ws.hobart_wins,
    ROUND(ws.hobart_wins::NUMERIC / gc.games_played, 3) AS hobart_win_pct
FROM win_summary ws
JOIN game_counts gc ON ws.opponent_id = gc.opponent_id
ORDER BY hobart_wins DESC
LIMIT 5;

WITH hobart_opponents AS (
    SELECT
        game_date,
        team_id,
        team_name,
        is_win
    FROM team_stats
    WHERE team_id != 'HOB'
),
games_vs_hobart AS (
    SELECT
        team_id,
        team_name,
        COUNT(*) AS games_played,
        SUM(CASE WHEN is_win THEN 1 ELSE 0 END) AS wins
    FROM hobart_opponents
    WHERE game_date IN (
        SELECT game_date FROM team_stats WHERE team_id = 'HOB'
    )
    GROUP BY team_id, team_name
)
SELECT
    team_id AS opponent_id,
    team_name AS opponent_name,
    games_played,
    wins AS wins_against_hobart,
    ROUND(wins::NUMERIC / games_played, 3) AS win_percentage
FROM games_vs_hobart
ORDER BY wins_against_hobart DESC
LIMIT 5;
