-- Hobart statistical identity and comparison

WITH hobart_avg AS (
    SELECT
        'HOB' AS label,
        COUNT(*)::TEXT AS games_played,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm), 2) AS avg_fgm,
        ROUND(AVG(fga), 2) AS avg_fga,
        ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 2) AS avg_fgm3,
        ROUND(AVG(fga3), 2) AS avg_fga3,
        ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 2) AS avg_ftm,
        ROUND(AVG(fta), 2) AS avg_fta,
        ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,
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
    FROM team_stats
    WHERE team_id = 'HOB'
),
opponent_avg AS (
    SELECT
        'OPP' AS label,
        COUNT(*)::TEXT AS games_played,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm), 2) AS avg_fgm,
        ROUND(AVG(fga), 2) AS avg_fga,
        ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 2) AS avg_fgm3,
        ROUND(AVG(fga3), 2) AS avg_fga3,
        ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 2) AS avg_ftm,
        ROUND(AVG(fta), 2) AS avg_fta,
        ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,
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
    FROM team_stats
    WHERE team_id != 'HOB'
),
margin AS (
    SELECT
        'MARGIN' AS label,
        NULL::TEXT AS games_played,
        ROUND(h.avg_points - o.avg_points, 2) AS avg_points,
        ROUND(h.avg_fgm - o.avg_fgm, 2) AS avg_fgm,
        ROUND(h.avg_fga - o.avg_fga, 2) AS avg_fga,
        ROUND(h.fg_pct - o.fg_pct, 3) AS fg_pct,
        ROUND(h.avg_fgm3 - o.avg_fgm3, 2) AS avg_fgm3,
        ROUND(h.avg_fga3 - o.avg_fga3, 2) AS avg_fga3,
        ROUND(h.fg3_pct - o.fg3_pct, 3) AS fg3_pct,
        ROUND(h.avg_ftm - o.avg_ftm, 2) AS avg_ftm,
        ROUND(h.avg_fta - o.avg_fta, 2) AS avg_fta,
        ROUND(h.ft_pct - o.ft_pct, 3) AS ft_pct,
        ROUND(h.avg_oreb - o.avg_oreb, 2) AS avg_oreb,
        ROUND(h.avg_dreb - o.avg_dreb, 2) AS avg_dreb,
        ROUND(h.avg_reb - o.avg_reb, 2) AS avg_reb,
        ROUND(h.avg_ast - o.avg_ast, 2) AS avg_ast,
        ROUND(h.avg_stl - o.avg_stl, 2) AS avg_stl,
        ROUND(h.avg_blk - o.avg_blk, 2) AS avg_blk,
        ROUND(h.avg_pf - o.avg_pf, 2) AS avg_pf,
        ROUND(h.avg_to - o.avg_to, 2) AS avg_to,
        ROUND(h.avg_pts_paint - o.avg_pts_paint, 2) AS avg_pts_paint,
        ROUND(h.avg_pts_to - o.avg_pts_to, 2) AS avg_pts_to,
        ROUND(h.avg_pts_ch2 - o.avg_pts_ch2, 2) AS avg_pts_ch2,
        ROUND(h.avg_pts_fastb - o.avg_pts_fastb, 2) AS avg_pts_fastb,
        ROUND(h.avg_pts_bench - o.avg_pts_bench, 2) AS avg_pts_bench
    FROM hobart_avg h, opponent_avg o
),
pct_margin AS (
    SELECT
        '% MARGIN DIFF' AS label,
        NULL::TEXT AS games_played,
        ROUND((h.avg_points - o.avg_points) / NULLIF(o.avg_points, 0) * 100, 1) AS avg_points,
        ROUND((h.avg_fgm - o.avg_fgm) / NULLIF(o.avg_fgm, 0) * 100, 1) AS avg_fgm,
        ROUND((h.avg_fga - o.avg_fga) / NULLIF(o.avg_fga, 0) * 100, 1) AS avg_fga,
        ROUND((h.fg_pct - o.fg_pct) / NULLIF(o.fg_pct, 0) * 100, 1) AS fg_pct,
        ROUND((h.avg_fgm3 - o.avg_fgm3) / NULLIF(o.avg_fgm3, 0) * 100, 1) AS avg_fgm3,
        ROUND((h.avg_fga3 - o.avg_fga3) / NULLIF(o.avg_fga3, 0) * 100, 1) AS avg_fga3,
        ROUND((h.fg3_pct - o.fg3_pct) / NULLIF(o.fg3_pct, 0) * 100, 1) AS fg3_pct,
        ROUND((h.avg_ftm - o.avg_ftm) / NULLIF(o.avg_ftm, 0) * 100, 1) AS avg_ftm,
        ROUND((h.avg_fta - o.avg_fta) / NULLIF(o.avg_fta, 0) * 100, 1) AS avg_fta,
        ROUND((h.ft_pct - o.ft_pct) / NULLIF(o.ft_pct, 0) * 100, 1) AS ft_pct,
        ROUND((h.avg_oreb - o.avg_oreb) / NULLIF(o.avg_oreb, 0) * 100, 1) AS avg_oreb,
        ROUND((h.avg_dreb - o.avg_dreb) / NULLIF(o.avg_dreb, 0) * 100, 1) AS avg_dreb,
        ROUND((h.avg_reb - o.avg_reb) / NULLIF(o.avg_reb, 0) * 100, 1) AS avg_reb,
        ROUND((h.avg_ast - o.avg_ast) / NULLIF(o.avg_ast, 0) * 100, 1) AS avg_ast,
        ROUND((h.avg_stl - o.avg_stl) / NULLIF(o.avg_stl, 0) * 100, 1) AS avg_stl,
        ROUND((h.avg_blk - o.avg_blk) / NULLIF(o.avg_blk, 0) * 100, 1) AS avg_blk,
        ROUND((h.avg_pf - o.avg_pf) / NULLIF(o.avg_pf, 0) * 100, 1) AS avg_pf,
        ROUND((h.avg_to - o.avg_to) / NULLIF(o.avg_to, 0) * 100, 1) AS avg_to,
        ROUND((h.avg_pts_paint - o.avg_pts_paint) / NULLIF(o.avg_pts_paint, 0) * 100, 1) AS avg_pts_paint,
        ROUND((h.avg_pts_to - o.avg_pts_to) / NULLIF(o.avg_pts_to, 0) * 100, 1) AS avg_pts_to,
        ROUND((h.avg_pts_ch2 - o.avg_pts_ch2) / NULLIF(o.avg_pts_ch2, 0) * 100, 1) AS avg_pts_ch2,
        ROUND((h.avg_pts_fastb - o.avg_pts_fastb) / NULLIF(o.avg_pts_fastb, 0) * 100, 1) AS avg_pts_fastb,
        ROUND((h.avg_pts_bench - o.avg_pts_bench) / NULLIF(o.avg_pts_bench, 0) * 100, 1) AS avg_pts_bench
    FROM hobart_avg h, opponent_avg o
)
SELECT *
FROM hobart_avg
UNION ALL
SELECT * FROM opponent_avg
UNION ALL
SELECT * FROM margin
UNION ALL
SELECT * FROM pct_margin;

WITH hobart_season_avg AS (
    SELECT
        season,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm), 2) AS avg_fgm,
        ROUND(AVG(fga), 2) AS avg_fga,
        ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 2) AS avg_fgm3,
        ROUND(AVG(fga3), 2) AS avg_fga3,
        ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 2) AS avg_ftm,
        ROUND(AVG(fta), 2) AS avg_fta,
        ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,
        ROUND(AVG(treb), 2) AS avg_reb,
        ROUND(AVG(ast), 2) AS avg_ast,
        ROUND(AVG(stl), 2) AS avg_stl,
        ROUND(AVG(blk), 2) AS avg_blk,
        ROUND(AVG(turnovers), 2) AS avg_to
    FROM team_stats
    WHERE team_id = 'HOB'
    GROUP BY season
),
opponent_season_avg AS (
    SELECT
        season,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm), 2) AS avg_fgm,
        ROUND(AVG(fga), 2) AS avg_fga,
        ROUND(AVG(fgm)::numeric / NULLIF(AVG(fga), 0), 3) AS fg_pct,
        ROUND(AVG(fgm3), 2) AS avg_fgm3,
        ROUND(AVG(fga3), 2) AS avg_fga3,
        ROUND(AVG(fgm3)::numeric / NULLIF(AVG(fga3), 0), 3) AS fg3_pct,
        ROUND(AVG(ftm), 2) AS avg_ftm,
        ROUND(AVG(fta), 2) AS avg_fta,
        ROUND(AVG(ftm)::numeric / NULLIF(AVG(fta), 0), 3) AS ft_pct,
        ROUND(AVG(treb), 2) AS avg_reb,
        ROUND(AVG(ast), 2) AS avg_ast,
        ROUND(AVG(stl), 2) AS avg_stl,
        ROUND(AVG(blk), 2) AS avg_blk,
        ROUND(AVG(turnovers), 2) AS avg_to
    FROM team_stats
    WHERE team_id != 'HOB'
    GROUP BY season
),
season_margin AS (
    SELECT
        h.season,
        ROUND(h.avg_points - o.avg_points, 2) AS margin_points,
        ROUND(h.avg_fgm - o.avg_fgm, 2) AS margin_fgm,
        ROUND(h.avg_fga - o.avg_fga, 2) AS margin_fga,
        ROUND(h.fg_pct - o.fg_pct, 3) AS margin_fg_pct,
        ROUND(h.avg_reb - o.avg_reb, 2) AS margin_reb,
        ROUND(h.avg_ast - o.avg_ast, 2) AS margin_ast,
        ROUND(h.avg_stl - o.avg_stl, 2) AS margin_stl,
        ROUND(h.avg_blk - o.avg_blk, 2) AS margin_blk,
        ROUND(h.avg_to - o.avg_to, 2) AS margin_to
    FROM hobart_season_avg h
    JOIN opponent_season_avg o ON h.season = o.season
)
SELECT *
FROM season_margin
ORDER BY margin_points DESC;




WITH hobart_season_avg AS (
    SELECT
        season,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm)::numeric / AVG(fga), 3) AS fg_pct,
        ROUND(AVG(fgm3)::numeric / AVG(fga3), 3) AS fg3_pct,
        ROUND(AVG(ftm)::numeric / AVG(fta), 3) AS ft_pct,
        ROUND(AVG(treb), 2) AS avg_reb,
        ROUND(AVG(ast), 2) AS avg_ast,
        ROUND(AVG(stl), 2) AS avg_stl,
        ROUND(AVG(blk), 2) AS avg_blk,
        ROUND(AVG(turnovers), 2) AS avg_to
    FROM team_stats
    WHERE team_id = 'HOB'
    GROUP BY season
),
opponent_season_avg AS (
    SELECT
        season,
        ROUND(AVG(points), 2) AS avg_points,
        ROUND(AVG(fgm)::numeric / AVG(fga), 3) AS fg_pct,
        ROUND(AVG(fgm3)::numeric / AVG(fga3), 3) AS fg3_pct,
        ROUND(AVG(ftm)::numeric / AVG(fta), 3) AS ft_pct,
        ROUND(AVG(treb), 2) AS avg_reb,
        ROUND(AVG(ast), 2) AS avg_ast,
        ROUND(AVG(stl), 2) AS avg_stl,
        ROUND(AVG(blk), 2) AS avg_blk,
        ROUND(AVG(turnovers), 2) AS avg_to
    FROM team_stats
    WHERE team_id != 'HOB'
    GROUP BY season
),
season_pct_margin AS (
    SELECT
        h.season,
        ROUND((h.avg_points - o.avg_points) / o.avg_points * 100, 1) AS pct_margin_points,
        ROUND((h.fg_pct - o.fg_pct) / o.fg_pct * 100, 1) AS pct_margin_fg_pct,
        ROUND((h.fg3_pct - o.fg3_pct) / o.fg3_pct * 100, 1) AS pct_margin_fg3_pct,
        ROUND((h.ft_pct - o.ft_pct) / o.ft_pct * 100, 1) AS pct_margin_ft_pct,
        ROUND((h.avg_reb - o.avg_reb) / o.avg_reb * 100, 1) AS pct_margin_reb,
        ROUND((h.avg_ast - o.avg_ast) / o.avg_ast * 100, 1) AS pct_margin_ast,
        ROUND((h.avg_stl - o.avg_stl) / o.avg_stl * 100, 1) AS pct_margin_stl,
        ROUND((h.avg_blk - o.avg_blk) / o.avg_blk * 100, 1) AS pct_margin_blk,
        ROUND((o.avg_to - h.avg_to) / h.avg_to * 100, 1) AS pct_margin_to  -- reversed logic
    FROM hobart_season_avg h
    JOIN opponent_season_avg o ON h.season = o.season
)
SELECT *
FROM season_pct_margin
ORDER BY season;
