-- Indiviudal back-to-back wins/losses (both 1st day and 2nd day)

WITH hobart_games AS (
    SELECT
        ts.team_id,
        ts.game_date,
        ts.game_id,
        ts.is_win,
        LAG(ts.game_date) OVER (ORDER BY ts.game_date) AS prev_game_date,
        LAG(ts.game_id) OVER (ORDER BY ts.game_date) AS prev_game_id,
        LAG(ts.is_win) OVER (ORDER BY ts.game_date) AS prev_is_win
    FROM team_stats ts
    WHERE ts.team_id = 'HOB'
),
b2b_games AS (
    SELECT
        game_date,
        game_id,
        is_win,
        prev_game_date,
        prev_game_id,
        prev_is_win
    FROM hobart_games
    WHERE prev_game_date IS NOT NULL
      AND game_date - prev_game_date = 1
),
combined AS (
    SELECT game_date, game_id, is_win, TRUE AS is_second_day FROM b2b_games
    UNION ALL
    SELECT prev_game_date AS game_date, prev_game_id AS game_id, prev_is_win AS is_win, FALSE AS is_second_day FROM b2b_games
)
SELECT *
FROM combined
ORDER BY game_date;

-- overall wins/losses in back-to-back (1st and 2nd day)


WITH hobart_games AS (
    SELECT
        ts.team_id,
        ts.game_date,
        ts.game_id,
        ts.is_win,
        LAG(ts.game_date) OVER (ORDER BY ts.game_date) AS prev_game_date,
        LAG(ts.is_win) OVER (ORDER BY ts.game_date) AS prev_is_win
    FROM team_stats ts
    WHERE ts.team_id = 'HOB'
),
b2b_games AS (
    SELECT
        game_date,
        game_id,
        is_win,
        prev_game_date,
        prev_is_win
    FROM hobart_games
    WHERE prev_game_date IS NOT NULL
      AND game_date - prev_game_date = 1
),
combined AS (
    SELECT prev_game_date AS game_date, 'First Day' AS b2b_day, prev_is_win AS is_win FROM b2b_games
    UNION ALL
    SELECT game_date, 'Second Day' AS b2b_day, is_win FROM b2b_games
),
aggregated AS (
    SELECT
        b2b_day,
        COUNT(*) AS games_played,
        COUNT(*) FILTER (WHERE is_win = true) AS wins,
        COUNT(*) FILTER (WHERE is_win = false) AS losses
    FROM combined
    GROUP BY b2b_day
)
SELECT
    MAX(CASE WHEN b2b_day = 'First Day' THEN games_played END) AS first_day,
    MAX(CASE WHEN b2b_day = 'Second Day' THEN games_played END) AS second_day,
    SUM(wins) AS wins,
    SUM(losses) AS losses,
    ROUND(SUM(wins)::numeric / NULLIF(SUM(wins) + SUM(losses), 0), 3) AS win_percentage
FROM aggregated;

-- 2nd day game statistical averages by season

WITH hobart_games AS (
    SELECT
        game_date,
        game_id,
        team_id,
        season,
        fgm, fga, fgm3, fga3, ftm, fta,
        points, oreb, dreb, treb, ast, stl, blk, pf,
        turnovers, pts_paint, pts_to, pts_ch2, pts_fastb, pts_bench
    FROM team_stats
    WHERE team_id = 'HOB'
),
b2b_second_days AS (
    SELECT
        curr.*
    FROM hobart_games curr
    JOIN hobart_games prev
        ON curr.game_date - prev.game_date = 1
)
SELECT
    season,
    COUNT(*) AS games_played,

    -- Shooting
    ROUND(AVG(fgm), 1) AS avg_fgm,
    ROUND(AVG(fga), 1) AS avg_fga,
    ROUND(SUM(fgm)::NUMERIC / NULLIF(SUM(fga), 0), 3) AS fg_pct,

    ROUND(AVG(fgm3), 1) AS avg_fgm3,
    ROUND(AVG(fga3), 1) AS avg_fga3,
    ROUND(SUM(fgm3)::NUMERIC / NULLIF(SUM(fga3), 0), 3) AS fg3_pct,

    ROUND(AVG(ftm), 1) AS avg_ftm,
    ROUND(AVG(fta), 1) AS avg_fta,
    ROUND(SUM(ftm)::NUMERIC / NULLIF(SUM(fta), 0), 3) AS ft_pct,

    -- Other stats
    ROUND(AVG(points), 1) AS avg_points,
    ROUND(AVG(oreb), 1) AS avg_oreb,
    ROUND(AVG(dreb), 1) AS avg_dreb,
    ROUND(AVG(treb), 1) AS avg_reb,
    ROUND(AVG(ast), 1) AS avg_ast,
    ROUND(AVG(stl), 1) AS avg_stl,
    ROUND(AVG(blk), 1) AS avg_blk,
    ROUND(AVG(pf), 1) AS avg_pf,
    ROUND(AVG(turnovers), 1) AS avg_to,

    -- Special points
    ROUND(AVG(pts_paint), 1) AS avg_pts_paint,
    ROUND(AVG(pts_to), 1) AS avg_pts_to,
    ROUND(AVG(pts_ch2), 1) AS avg_pts_ch2,
    ROUND(AVG(pts_fastb), 1) AS avg_pts_fastb,
    ROUND(AVG(pts_bench), 1) AS avg_pts_bench

FROM b2b_second_days
GROUP BY season
ORDER BY season;


-- overall stats comparing full-season and back-to-back games

WITH hobart_games AS (
    SELECT
        game_date,
        game_id,
        season,
        is_win,
        fgm, fga, fgm3, fga3, ftm, fta,
        points, oreb, dreb, treb, ast, stl, blk, pf, turnovers,
        pts_paint, pts_to, pts_ch2, pts_fastb, pts_bench
    FROM team_stats
    WHERE team_id = 'HOB'
),
b2b_games AS (
    SELECT
        curr.*
    FROM hobart_games curr
    JOIN hobart_games prev
        ON curr.game_date = prev.game_date + 1
    WHERE curr.season = prev.season
),
combined AS (
    SELECT
        season,
        'Full Season' AS full_season_or_back_to_back,
        COUNT(*) AS games_played,
        SUM(CASE WHEN is_win THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN NOT is_win THEN 1 ELSE 0 END) AS losses,
        ROUND(SUM(CASE WHEN is_win THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 3) AS win_pct,
        ROUND(AVG(points), 1) AS avg_points,
        ROUND(AVG(fgm), 1) AS avg_fgm,
        ROUND(AVG(fga), 1) AS avg_fga,
        ROUND(AVG(fgm)::NUMERIC / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 1) AS avg_fgm3,
        ROUND(AVG(fga3), 1) AS avg_fga3,
        ROUND(AVG(fgm3)::NUMERIC / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 1) AS avg_ftm,
        ROUND(AVG(fta), 1) AS avg_fta,
        ROUND(AVG(ftm)::NUMERIC / NULLIF(AVG(fta), 0), 3) AS ft_pct,
        ROUND(AVG(oreb), 1) AS avg_oreb,
        ROUND(AVG(dreb), 1) AS avg_dreb,
        ROUND(AVG(treb), 1) AS avg_reb,
        ROUND(AVG(ast), 1) AS avg_ast,
        ROUND(AVG(stl), 1) AS avg_stl,
        ROUND(AVG(blk), 1) AS avg_blk,
        ROUND(AVG(pf), 1) AS avg_pf,
        ROUND(AVG(turnovers), 1) AS avg_to,
        ROUND(AVG(pts_paint), 1) AS avg_pts_paint,
        ROUND(AVG(pts_to), 1) AS avg_pts_to,
        ROUND(AVG(pts_ch2), 1) AS avg_pts_ch2,
        ROUND(AVG(pts_fastb), 1) AS avg_pts_fastb,
        ROUND(AVG(pts_bench), 1) AS avg_pts_bench
    FROM hobart_games
    GROUP BY season

    UNION ALL

    SELECT
        season,
        'Second Day B2B' AS full_season_or_back_to_back,
        COUNT(*) AS games_played,
        SUM(CASE WHEN is_win THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN NOT is_win THEN 1 ELSE 0 END) AS losses,
        ROUND(SUM(CASE WHEN is_win THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 3) AS win_pct,
        ROUND(AVG(points), 1) AS avg_points,
        ROUND(AVG(fgm), 1) AS avg_fgm,
        ROUND(AVG(fga), 1) AS avg_fga,
        ROUND(AVG(fgm)::NUMERIC / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 1) AS avg_fgm3,
        ROUND(AVG(fga3), 1) AS avg_fga3,
        ROUND(AVG(fgm3)::NUMERIC / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 1) AS avg_ftm,
        ROUND(AVG(fta), 1) AS avg_fta,
        ROUND(AVG(ftm)::NUMERIC / NULLIF(AVG(fta), 0), 3) AS ft_pct,
        ROUND(AVG(oreb), 1) AS avg_oreb,
        ROUND(AVG(dreb), 1) AS avg_dreb,
        ROUND(AVG(treb), 1) AS avg_reb,
        ROUND(AVG(ast), 1) AS avg_ast,
        ROUND(AVG(stl), 1) AS avg_stl,
        ROUND(AVG(blk), 1) AS avg_blk,
        ROUND(AVG(pf), 1) AS avg_pf,
        ROUND(AVG(turnovers), 1) AS avg_to,
        ROUND(AVG(pts_paint), 1) AS avg_pts_paint,
        ROUND(AVG(pts_to), 1) AS avg_pts_to,
        ROUND(AVG(pts_ch2), 1) AS avg_pts_ch2,
        ROUND(AVG(pts_fastb), 1) AS avg_pts_fastb,
        ROUND(AVG(pts_bench), 1) AS avg_pts_bench
    FROM b2b_games
    GROUP BY season
)
SELECT * FROM combined
ORDER BY season, full_season_or_back_to_back;


-- overall B2B stats comparing across all seasons against their margins

WITH hobart_games AS (
    SELECT
        game_date,
        is_win,
        fgm, fga, fgm3, fga3, ftm, fta,
        points, oreb, dreb, treb, ast, stl, blk, pf, turnovers,
        pts_paint, pts_to, pts_ch2, pts_fastb, pts_bench
    FROM team_stats
    WHERE team_id = 'HOB'
),
b2b_games AS (
    SELECT
        curr.*
    FROM hobart_games curr
    JOIN hobart_games prev
        ON curr.game_date = prev.game_date + 1
),
full_season_avg AS (
    SELECT
        'Full Season Avg' AS category,
        COUNT(*) AS games_played,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm), 2) AS avg_fgm,
        ROUND(AVG(fga), 2) AS avg_fga,
        ROUND(AVG(fgm)::NUMERIC / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 2) AS avg_fgm3,
        ROUND(AVG(fga3), 2) AS avg_fga3,
        ROUND(AVG(fgm3)::NUMERIC / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 2) AS avg_ftm,
        ROUND(AVG(fta), 2) AS avg_fta,
        ROUND(AVG(ftm)::NUMERIC / NULLIF(AVG(fta), 0), 3) AS ft_pct,
        ROUND(AVG(oreb), 2) AS avg_oreb,
        ROUND(AVG(dreb), 2) AS avg_dreb,
        ROUND(AVG(treb), 2) AS avg_reb,
        ROUND(AVG(ast), 2) AS avg_ast,
        ROUND(AVG(stl), 2) AS avg_stl,
        ROUND(AVG(blk), 2) AS avg_blk,
        ROUND(AVG(pf), 2) AS avg_pf,
        ROUND(AVG(turnovers), 2) AS avg_to,
        ROUND(AVG(pts_paint), 2) AS avg_pts_paint,
        ROUND(AVG(pts_to), 2) AS avg_pts_to,
        ROUND(AVG(pts_ch2), 2) AS avg_pts_ch2,
        ROUND(AVG(pts_fastb), 2) AS avg_pts_fastb,
        ROUND(AVG(pts_bench), 2) AS avg_pts_bench
    FROM hobart_games
),
b2b_avg AS (
    SELECT
        'Second Day B2B Avg' AS category,
        COUNT(*) AS games_played,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm), 2) AS avg_fgm,
        ROUND(AVG(fga), 2) AS avg_fga,
        ROUND(AVG(fgm)::NUMERIC / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 2) AS avg_fgm3,
        ROUND(AVG(fga3), 2) AS avg_fga3,
        ROUND(AVG(fgm3)::NUMERIC / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 2) AS avg_ftm,
        ROUND(AVG(fta), 2) AS avg_fta,
        ROUND(AVG(ftm)::NUMERIC / NULLIF(AVG(fta), 0), 3) AS ft_pct,
        ROUND(AVG(oreb), 2) AS avg_oreb,
        ROUND(AVG(dreb), 2) AS avg_dreb,
        ROUND(AVG(treb), 2) AS avg_reb,
        ROUND(AVG(ast), 2) AS avg_ast,
        ROUND(AVG(stl), 2) AS avg_stl,
        ROUND(AVG(blk), 2) AS avg_blk,
        ROUND(AVG(pf), 2) AS avg_pf,
        ROUND(AVG(turnovers), 2) AS avg_to,
        ROUND(AVG(pts_paint), 2) AS avg_pts_paint,
        ROUND(AVG(pts_to), 2) AS avg_pts_to,
        ROUND(AVG(pts_ch2), 2) AS avg_pts_ch2,
        ROUND(AVG(pts_fastb), 2) AS avg_pts_fastb,
        ROUND(AVG(pts_bench), 2) AS avg_pts_bench
    FROM b2b_games
),
margin AS (
    SELECT
        'Margin (B2B - Full)' AS category,
        NULL::INTEGER AS games_played,
        ROUND(b.avg_points - f.avg_points, 2) AS avg_points,
        ROUND(b.avg_fgm - f.avg_fgm, 2) AS avg_fgm,
        ROUND(b.avg_fga - f.avg_fga, 2) AS avg_fga,
        ROUND(b.fg_pct - f.fg_pct, 3) AS fg_pct,
        ROUND(b.avg_fgm3 - f.avg_fgm3, 2) AS avg_fgm3,
        ROUND(b.avg_fga3 - f.avg_fga3, 2) AS avg_fga3,
        ROUND(b.fg3_pct - f.fg3_pct, 3) AS fg3_pct,
        ROUND(b.avg_ftm - f.avg_ftm, 2) AS avg_ftm,
        ROUND(b.avg_fta - f.avg_fta, 2) AS avg_fta,
        ROUND(b.ft_pct - f.ft_pct, 3) AS ft_pct,
        ROUND(b.avg_oreb - f.avg_oreb, 2) AS avg_oreb,
        ROUND(b.avg_dreb - f.avg_dreb, 2) AS avg_dreb,
        ROUND(b.avg_reb - f.avg_reb, 2) AS avg_reb,
        ROUND(b.avg_ast - f.avg_ast, 2) AS avg_ast,
        ROUND(b.avg_stl - f.avg_stl, 2) AS avg_stl,
        ROUND(b.avg_blk - f.avg_blk, 2) AS avg_blk,
        ROUND(b.avg_pf - f.avg_pf, 2) AS avg_pf,
        ROUND(b.avg_to - f.avg_to, 2) AS avg_to,
        ROUND(b.avg_pts_paint - f.avg_pts_paint, 2) AS avg_pts_paint,
        ROUND(b.avg_pts_to - f.avg_pts_to, 2) AS avg_pts_to,
        ROUND(b.avg_pts_ch2 - f.avg_pts_ch2, 2) AS avg_pts_ch2,
        ROUND(b.avg_pts_fastb - f.avg_pts_fastb, 2) AS avg_pts_fastb,
        ROUND(b.avg_pts_bench - f.avg_pts_bench, 2) AS avg_pts_bench
    FROM b2b_avg b, full_season_avg f
),
perc_margin AS (
    SELECT
        '% Margin Change' AS category,
        NULL::INTEGER AS games_played,
        ROUND((b.avg_points - f.avg_points) / NULLIF(f.avg_points, 0), 3) AS avg_points,
        ROUND((b.avg_fgm - f.avg_fgm) / NULLIF(f.avg_fgm, 0), 3) AS avg_fgm,
        ROUND((b.avg_fga - f.avg_fga) / NULLIF(f.avg_fga, 0), 3) AS avg_fga,
        ROUND((b.fg_pct - f.fg_pct) / NULLIF(f.fg_pct, 0), 3) AS fg_pct,
        ROUND((b.avg_fgm3 - f.avg_fgm3) / NULLIF(f.avg_fgm3, 0), 3) AS avg_fgm3,
        ROUND((b.avg_fga3 - f.avg_fga3) / NULLIF(f.avg_fga3, 0), 3) AS avg_fga3,
        ROUND((b.fg3_pct - f.fg3_pct) / NULLIF(f.fg3_pct, 0), 3) AS fg3_pct,
        ROUND((b.avg_ftm - f.avg_ftm) / NULLIF(f.avg_ftm, 0), 3) AS avg_ftm,
        ROUND((b.avg_fta - f.avg_fta) / NULLIF(f.avg_fta, 0), 3) AS avg_fta,
        ROUND((b.ft_pct - f.ft_pct) / NULLIF(f.ft_pct, 0), 3) AS ft_pct,
        ROUND((b.avg_oreb - f.avg_oreb) / NULLIF(f.avg_oreb, 0), 3) AS avg_oreb,
        ROUND((b.avg_dreb - f.avg_dreb) / NULLIF(f.avg_dreb, 0), 3) AS avg_dreb,
        ROUND((b.avg_reb - f.avg_reb) / NULLIF(f.avg_reb, 0), 3) AS avg_reb,
        ROUND((b.avg_ast - f.avg_ast) / NULLIF(f.avg_ast, 0), 3) AS avg_ast,
        ROUND((b.avg_stl - f.avg_stl) / NULLIF(f.avg_stl, 0), 3) AS avg_stl,
        ROUND((b.avg_blk - f.avg_blk) / NULLIF(f.avg_blk, 0), 3) AS avg_blk,
        ROUND((b.avg_pf - f.avg_pf) / NULLIF(f.avg_pf, 0), 3) AS avg_pf,
        ROUND((b.avg_to - f.avg_to) / NULLIF(f.avg_to, 0), 3) AS avg_to,
        ROUND((b.avg_pts_paint - f.avg_pts_paint) / NULLIF(f.avg_pts_paint, 0), 3) AS avg_pts_paint,
        ROUND((b.avg_pts_to - f.avg_pts_to) / NULLIF(f.avg_pts_to, 0), 3) AS avg_pts_to,
        ROUND((b.avg_pts_ch2 - f.avg_pts_ch2) / NULLIF(f.avg_pts_ch2, 0), 3) AS avg_pts_ch2,
        ROUND((b.avg_pts_fastb - f.avg_pts_fastb) / NULLIF(f.avg_pts_fastb, 0), 3) AS avg_pts_fastb,
        ROUND((b.avg_pts_bench - f.avg_pts_bench) / NULLIF(f.avg_pts_bench, 0), 3) AS avg_pts_bench
    FROM b2b_avg b, full_season_avg f
)
SELECT * FROM full_season_avg
UNION ALL
SELECT * FROM b2b_avg
UNION ALL
SELECT * FROM margin
UNION ALL
SELECT * FROM perc_margin;
