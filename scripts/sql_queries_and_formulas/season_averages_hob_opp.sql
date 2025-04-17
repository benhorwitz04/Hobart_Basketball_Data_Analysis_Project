-- team averages over each indiviudal season

SELECT
    season,
    COUNT(*) AS games_played,

    -- Win/loss tracking
    SUM(CASE WHEN is_win = TRUE THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN is_win = FALSE THEN 1 ELSE 0 END) AS losses,
    ROUND(
        SUM(CASE WHEN is_win = TRUE THEN 1 ELSE 0 END)::numeric / COUNT(*),
        3
    ) AS win_pct,

    -- Total & FG shooting
    ROUND(AVG(points), 1) AS avg_points,
    ROUND(AVG(fgm), 1) AS avg_fgm,
    ROUND(AVG(fga), 1) AS avg_fga,
    ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,

    -- 3PT shooting
    ROUND(AVG(fgm3), 1) AS avg_fgm3,
    ROUND(AVG(fga3), 1) AS avg_fga3,
    ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,

    -- Free throws
    ROUND(AVG(ftm), 1) AS avg_ftm,
    ROUND(AVG(fta), 1) AS avg_fta,
    ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,

    -- Rebounds & misc
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

FROM team_stats
WHERE team_id = 'HOB' AND season IS NOT NULL
GROUP BY season
ORDER BY season;


-- opponnent averages over each indiviudal season

SELECT
    season,
    COUNT(*) AS games_played,

    -- Win/loss tracking
    SUM(CASE WHEN is_win = TRUE THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN is_win = FALSE THEN 1 ELSE 0 END) AS losses,
    ROUND(
        SUM(CASE WHEN is_win = TRUE THEN 1 ELSE 0 END)::numeric / COUNT(*),
        3
    ) AS win_pct,

    -- Total & FG shooting
    ROUND(AVG(points), 1) AS avg_points,
    ROUND(AVG(fgm), 1) AS avg_fgm,
    ROUND(AVG(fga), 1) AS avg_fga,
    ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,

    -- 3PT shooting
    ROUND(AVG(fgm3), 1) AS avg_fgm3,
    ROUND(AVG(fga3), 1) AS avg_fga3,
    ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,

    -- Free throws
    ROUND(AVG(ftm), 1) AS avg_ftm,
    ROUND(AVG(fta), 1) AS avg_fta,
    ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,

    -- Rebounds & misc
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

FROM team_stats
WHERE team_id != 'HOB' AND season IS NOT NULL
GROUP BY season
ORDER BY season;


