-- overall record over last 5 seasons

SELECT
    '2019 - 2025' AS "2019-2025",
    COUNT(*) FILTER (WHERE is_win = TRUE) AS wins,
    COUNT(*) FILTER (WHERE is_win = FALSE) AS losses,
    ROUND(
        COUNT(*) FILTER (WHERE is_win = TRUE)::decimal / NULLIF(COUNT(*), 0),
        3
    ) AS win_pct
FROM team_stats
WHERE team_id = 'HOB'
  AND season IN ('2019 - 2020', '2021 - 2022', '2022 - 2023', '2023 - 2024', '2024 - 2025');

-- home vs. away overall record

SELECT
    is_home,
    COUNT(*) FILTER (WHERE is_win = TRUE) AS wins,
    COUNT(*) FILTER (WHERE is_win = FALSE) AS losses,
    ROUND(
        COUNT(*) FILTER (WHERE is_win = TRUE)::decimal /
        NULLIF(COUNT(*), 0), 3
    ) AS win_pct
FROM team_stats
WHERE team_id = 'HOB'
GROUP BY is_home
ORDER BY is_home DESC;

-- confrence vs. non-conference record

SELECT
    CASE
        WHEN opponent_id IN ('ITH', 'RIT', 'VAS', 'SLU', 'CLK', 'UNI', 'BRD', 'SKD', 'RPI') THEN 'Conference'
        ELSE 'Non-Conference'
    END AS opponent_type,
    COUNT(*) FILTER (WHERE is_win = TRUE) AS wins,
    COUNT(*) FILTER (WHERE is_win = FALSE) AS losses,
    ROUND(
        COUNT(*) FILTER (WHERE is_win = TRUE)::decimal /
        NULLIF(COUNT(*), 0), 3
    ) AS win_pct
FROM (
    SELECT
        ts.game_date,
        ts.team_id,
        ts.is_win,
        -- Identify opponent as the other team in the same game
        opp.team_id AS opponent_id
    FROM team_stats ts
    JOIN team_stats opp
        ON ts.game_date = opp.game_date
        AND ts.team_id != opp.team_id
    WHERE ts.team_id = 'HOB'
) AS hobart_games
GROUP BY opponent_type;


--- Wins/losses by month over last 5 years


WITH hobart_monthly_games AS (
    SELECT
        TO_CHAR(game_date::date, 'Month') AS month,
        EXTRACT(MONTH FROM game_date) AS month_num,
        is_win
    FROM team_stats
    WHERE team_id = 'HOB'
),
monthly_summary AS (
    SELECT
        TRIM(month) AS month,
        month_num,
        COUNT(*) AS games_played,
        COUNT(CASE WHEN is_win THEN 1 END) AS wins,
        COUNT(CASE WHEN NOT is_win THEN 1 END) AS losses,
        ROUND(100.0 * COUNT(CASE WHEN is_win THEN 1 END) / COUNT(*), 1) AS win_pct
    FROM hobart_monthly_games
    GROUP BY month, month_num
)
SELECT
    month,
    games_played,
    wins,
    losses,
    win_pct
FROM monthly_summary
WHERE month IN ('November', 'December', 'January', 'February', 'March')
ORDER BY month_num;


-- Statistical averages for each month over the last 5 seasons

SELECT
    TO_CHAR(game_date, 'Month') AS month,
    COUNT(*) AS games_played,

    -- Scoring
    ROUND(AVG(points), 1) AS avg_points,

    -- Field Goals
    ROUND(AVG(fgm), 1) AS avg_fgm,
    ROUND(AVG(fga), 1) AS avg_fga,
    ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,

    -- 3PT Field Goals
    ROUND(AVG(fgm3), 1) AS avg_fgm3,
    ROUND(AVG(fga3), 1) AS avg_fga3,
    ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,

    -- Free Throws
    ROUND(AVG(ftm), 1) AS avg_ftm,
    ROUND(AVG(fta), 1) AS avg_fta,
    ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,

    -- Rebounds
    ROUND(AVG(oreb), 1) AS avg_oreb,
    ROUND(AVG(dreb), 1) AS avg_dreb,
    ROUND(AVG(treb), 1) AS avg_reb,

    -- Playmaking & Defense
    ROUND(AVG(ast), 1) AS avg_ast,
    ROUND(AVG(stl), 1) AS avg_stl,
    ROUND(AVG(blk), 1) AS avg_blk,
    ROUND(AVG(pf), 1) AS avg_pf,
    ROUND(AVG(turnovers), 1) AS avg_to,

    -- Specialty Points
    ROUND(AVG(pts_paint), 1) AS avg_pts_paint,
    ROUND(AVG(pts_to), 1) AS avg_pts_to,
    ROUND(AVG(pts_ch2), 1) AS avg_pts_ch2,
    ROUND(AVG(pts_fastb), 1) AS avg_pts_fastb,
    ROUND(AVG(pts_bench), 1) AS avg_pts_bench

FROM team_stats
WHERE team_id = 'HOB'
GROUP BY TO_CHAR(game_date, 'Month'), EXTRACT(MONTH FROM game_date)
ORDER BY EXTRACT(MONTH FROM game_date);



-- Opponent Statistical averages for each month over the last 5 seasons

SELECT
    TO_CHAR(game_date, 'Month') AS month,
    COUNT(*) AS games_played,

    -- Scoring
    ROUND(AVG(points), 1) AS avg_points,

    -- Field Goals
    ROUND(AVG(fgm), 1) AS avg_fgm,
    ROUND(AVG(fga), 1) AS avg_fga,
    ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,

    -- 3PT Field Goals
    ROUND(AVG(fgm3), 1) AS avg_fgm3,
    ROUND(AVG(fga3), 1) AS avg_fga3,
    ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,

    -- Free Throws
    ROUND(AVG(ftm), 1) AS avg_ftm,
    ROUND(AVG(fta), 1) AS avg_fta,
    ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,

    -- Rebounds
    ROUND(AVG(oreb), 1) AS avg_oreb,
    ROUND(AVG(dreb), 1) AS avg_dreb,
    ROUND(AVG(treb), 1) AS avg_reb,

    -- Playmaking & Defense
    ROUND(AVG(ast), 1) AS avg_ast,
    ROUND(AVG(stl), 1) AS avg_stl,
    ROUND(AVG(blk), 1) AS avg_blk,
    ROUND(AVG(pf), 1) AS avg_pf,
    ROUND(AVG(turnovers), 1) AS avg_to,

    -- Specialty Points
    ROUND(AVG(pts_paint), 1) AS avg_pts_paint,
    ROUND(AVG(pts_to), 1) AS avg_pts_to,
    ROUND(AVG(pts_ch2), 1) AS avg_pts_ch2,
    ROUND(AVG(pts_fastb), 1) AS avg_pts_fastb,
    ROUND(AVG(pts_bench), 1) AS avg_pts_bench

FROM team_stats
WHERE team_id != 'HOB'
GROUP BY TO_CHAR(game_date, 'Month'), EXTRACT(MONTH FROM game_date)
ORDER BY EXTRACT(MONTH FROM game_date);

