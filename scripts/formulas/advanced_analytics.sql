-- Hobart season advanced analytics

SELECT
    season,

    -- Possession & efficiency
    ROUND((avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 2) AS possessions,
    ROUND((avg_fgm + 0.5 * avg_fgm3) / avg_fga, 3) AS efg_pct,
    ROUND(avg_points / (2 * (avg_fga + 0.44 * avg_fta)), 3) AS ts_pct,
    ROUND(100.0 * avg_points / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 2) AS off_rating,

    -- Ball control
    ROUND(avg_to / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 3) AS tov_pct,
    ROUND(avg_ast / avg_to, 2) AS ast_to_ratio,
    ROUND(avg_ast / avg_fgm, 3) AS assist_pct,

    -- Rebounding
    ROUND(avg_oreb / avg_reb, 3) AS oreb_pct,
    ROUND(avg_dreb / avg_reb, 3) AS dreb_pct,

    -- Scoring profile
    ROUND((avg_fgm3 * 3.0) / avg_points, 3) AS pct_pts_3pt,
    ROUND(avg_ftm / avg_points, 3) AS pct_pts_ft,
    ROUND(avg_pts_bench / avg_points, 3) AS pct_pts_bench,
    ROUND(avg_pts_paint / avg_points, 3) AS pct_pts_paint,
    ROUND(avg_pts_fastb / avg_points, 3) AS pct_pts_fastb,
    ROUND(avg_pts_ch2 / avg_points, 3) AS pct_pts_ch2,
    ROUND(avg_pts_to / avg_points, 3) AS pct_pts_to,

    -- Style of play
    ROUND(avg_fta / avg_fga, 3) AS fta_rate,
    ROUND(avg_fga3 / avg_fga, 3) AS fga3_rate,
    ROUND(avg_fgm / (avg_fga - avg_oreb + avg_to), 3) AS play_pct

FROM hobart_season_averages
ORDER BY season;


-- Opponent season advanced analytics

SELECT
    season,

    -- Possession & efficiency
    ROUND((avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 2) AS possessions,
    ROUND((avg_fgm + 0.5 * avg_fgm3) / avg_fga, 3) AS efg_pct,
    ROUND(avg_points / (2 * (avg_fga + 0.44 * avg_fta)), 3) AS ts_pct,
    ROUND(100.0 * avg_points / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 2) AS off_rating,

    -- Ball control
    ROUND(avg_to / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 3) AS tov_pct,
    ROUND(avg_ast / avg_to, 2) AS ast_to_ratio,
    ROUND(avg_ast / avg_fgm, 3) AS assist_pct,

    -- Rebounding
    ROUND(avg_oreb / avg_reb, 3) AS oreb_pct,
    ROUND(avg_dreb / avg_reb, 3) AS dreb_pct,

    -- Scoring profile
    ROUND((avg_fgm3 * 3.0) / avg_points, 3) AS pct_pts_3pt,
    ROUND(avg_ftm / avg_points, 3) AS pct_pts_ft,
    ROUND(avg_pts_bench / avg_points, 3) AS pct_pts_bench,
    ROUND(avg_pts_paint / avg_points, 3) AS pct_pts_paint,
    ROUND(avg_pts_fastb / avg_points, 3) AS pct_pts_fastb,
    ROUND(avg_pts_ch2 / avg_points, 3) AS pct_pts_ch2,
    ROUND(avg_pts_to / avg_points, 3) AS pct_pts_to,

    -- Style of play
    ROUND(avg_fta / avg_fga, 3) AS fta_rate,
    ROUND(avg_fga3 / avg_fga, 3) AS fga3_rate,
    ROUND(avg_fgm / (avg_fga - avg_oreb + avg_to), 3) AS play_pct

FROM opp_season_averages
ORDER BY season;

-- Hobart vs. Opponent totals with margins

WITH hob_avg AS (
    SELECT
        'HOB' AS group_name,
        ROUND(AVG(avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 2) AS possessions,
        ROUND(AVG((avg_fgm + 0.5 * avg_fgm3) / avg_fga), 3) AS efg_pct,
        ROUND(AVG(avg_points / (2 * (avg_fga + 0.44 * avg_fta))), 3) AS ts_pct,
        ROUND(AVG(100.0 * avg_points / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta)), 2) AS off_rating,
        ROUND(AVG(avg_to / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta)), 3) AS tov_pct,
        ROUND(AVG(avg_ast / avg_to), 2) AS ast_to_ratio,
        ROUND(AVG(avg_ast / avg_fgm), 3) AS assist_pct,
        ROUND(AVG(avg_oreb / avg_reb), 3) AS oreb_pct,
        ROUND(AVG(avg_dreb / avg_reb), 3) AS dreb_pct,
        ROUND(AVG((avg_fgm3 * 3.0) / avg_points), 3) AS pct_pts_3pt,
        ROUND(AVG(avg_ftm / avg_points), 3) AS pct_pts_ft,
        ROUND(AVG(avg_pts_bench / avg_points), 3) AS pct_pts_bench,
        ROUND(AVG(avg_pts_paint / avg_points), 3) AS pct_pts_paint,
        ROUND(AVG(avg_pts_fastb / avg_points), 3) AS pct_pts_fastb,
        ROUND(AVG(avg_pts_ch2 / avg_points), 3) AS pct_pts_ch2,
        ROUND(AVG(avg_pts_to / avg_points), 3) AS pct_pts_to,
        ROUND(AVG(avg_fta / avg_fga), 3) AS fta_rate,
        ROUND(AVG(avg_fga3 / avg_fga), 3) AS fga3_rate,
        ROUND(AVG(avg_fgm / (avg_fga - avg_oreb + avg_to)), 3) AS play_pct
    FROM hobart_season_averages
),
opp_avg AS (
    SELECT
        'OPPONENT' AS group_name,
        ROUND(AVG(avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 2) AS possessions,
        ROUND(AVG((avg_fgm + 0.5 * avg_fgm3) / avg_fga), 3) AS efg_pct,
        ROUND(AVG(avg_points / (2 * (avg_fga + 0.44 * avg_fta))), 3) AS ts_pct,
        ROUND(AVG(100.0 * avg_points / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta)), 2) AS off_rating,
        ROUND(AVG(avg_to / (avg_fga - avg_oreb + avg_to + 0.475 * avg_fta)), 3) AS tov_pct,
        ROUND(AVG(avg_ast / avg_to), 2) AS ast_to_ratio,
        ROUND(AVG(avg_ast / avg_fgm), 3) AS assist_pct,
        ROUND(AVG(avg_oreb / avg_reb), 3) AS oreb_pct,
        ROUND(AVG(avg_dreb / avg_reb), 3) AS dreb_pct,
        ROUND(AVG((avg_fgm3 * 3.0) / avg_points), 3) AS pct_pts_3pt,
        ROUND(AVG(avg_ftm / avg_points), 3) AS pct_pts_ft,
        ROUND(AVG(avg_pts_bench / avg_points), 3) AS pct_pts_bench,
        ROUND(AVG(avg_pts_paint / avg_points), 3) AS pct_pts_paint,
        ROUND(AVG(avg_pts_fastb / avg_points), 3) AS pct_pts_fastb,
        ROUND(AVG(avg_pts_ch2 / avg_points), 3) AS pct_pts_ch2,
        ROUND(AVG(avg_pts_to / avg_points), 3) AS pct_pts_to,
        ROUND(AVG(avg_fta / avg_fga), 3) AS fta_rate,
        ROUND(AVG(avg_fga3 / avg_fga), 3) AS fga3_rate,
        ROUND(AVG(avg_fgm / (avg_fga - avg_oreb + avg_to)), 3) AS play_pct
    FROM opp_season_averages
),
abs_margin AS (
    SELECT
        'ABS_MARGIN' AS group_name,
        ROUND(h.possessions - o.possessions, 2) AS possessions,
        ROUND(h.efg_pct - o.efg_pct, 3) AS efg_pct,
        ROUND(h.ts_pct - o.ts_pct, 3) AS ts_pct,
        ROUND(h.off_rating - o.off_rating, 2) AS off_rating,
        ROUND(h.tov_pct - o.tov_pct, 3) AS tov_pct,
        ROUND(h.ast_to_ratio - o.ast_to_ratio, 2) AS ast_to_ratio,
        ROUND(h.assist_pct - o.assist_pct, 3) AS assist_pct,
        ROUND(h.oreb_pct - o.oreb_pct, 3) AS oreb_pct,
        ROUND(h.dreb_pct - o.dreb_pct, 3) AS dreb_pct,
        ROUND(h.pct_pts_3pt - o.pct_pts_3pt, 3) AS pct_pts_3pt,
        ROUND(h.pct_pts_ft - o.pct_pts_ft, 3) AS pct_pts_ft,
        ROUND(h.pct_pts_bench - o.pct_pts_bench, 3) AS pct_pts_bench,
        ROUND(h.pct_pts_paint - o.pct_pts_paint, 3) AS pct_pts_paint,
        ROUND(h.pct_pts_fastb - o.pct_pts_fastb, 3) AS pct_pts_fastb,
        ROUND(h.pct_pts_ch2 - o.pct_pts_ch2, 3) AS pct_pts_ch2,
        ROUND(h.pct_pts_to - o.pct_pts_to, 3) AS pct_pts_to,
        ROUND(h.fta_rate - o.fta_rate, 3) AS fta_rate,
        ROUND(h.fga3_rate - o.fga3_rate, 3) AS fga3_rate,
        ROUND(h.play_pct - o.play_pct, 3) AS play_pct
    FROM hob_avg h, opp_avg o
),
pct_margin AS (
    SELECT
        '%_MARGIN_DIFF' AS group_name,
        ROUND(100.0 * (h.possessions - o.possessions) / o.possessions, 2) AS possessions,
        ROUND(100.0 * (h.efg_pct - o.efg_pct) / o.efg_pct, 2) AS efg_pct,
        ROUND(100.0 * (h.ts_pct - o.ts_pct) / o.ts_pct, 2) AS ts_pct,
        ROUND(100.0 * (h.off_rating - o.off_rating) / o.off_rating, 2) AS off_rating,
        ROUND(100.0 * (h.tov_pct - o.tov_pct) / o.tov_pct, 2) AS tov_pct,
        ROUND(100.0 * (h.ast_to_ratio - o.ast_to_ratio) / o.ast_to_ratio, 2) AS ast_to_ratio,
        ROUND(100.0 * (h.assist_pct - o.assist_pct) / o.assist_pct, 2) AS assist_pct,
        ROUND(100.0 * (h.oreb_pct - o.oreb_pct) / o.oreb_pct, 2) AS oreb_pct,
        ROUND(100.0 * (h.dreb_pct - o.dreb_pct) / o.dreb_pct, 2) AS dreb_pct,
        ROUND(100.0 * (h.pct_pts_3pt - o.pct_pts_3pt) / o.pct_pts_3pt, 2) AS pct_pts_3pt,
        ROUND(100.0 * (h.pct_pts_ft - o.pct_pts_ft) / o.pct_pts_ft, 2) AS pct_pts_ft,
        ROUND(100.0 * (h.pct_pts_bench - o.pct_pts_bench) / o.pct_pts_bench, 2) AS pct_pts_bench,
        ROUND(100.0 * (h.pct_pts_paint - o.pct_pts_paint) / o.pct_pts_paint, 2) AS pct_pts_paint,
        ROUND(100.0 * (h.pct_pts_fastb - o.pct_pts_fastb) / o.pct_pts_fastb, 2) AS pct_pts_fastb,
        ROUND(100.0 * (h.pct_pts_ch2 - o.pct_pts_ch2) / o.pct_pts_ch2, 2) AS pct_pts_ch2,
        ROUND(100.0 * (h.pct_pts_to - o.pct_pts_to) / o.pct_pts_to, 2) AS pct_pts_to,
        ROUND(100.0 * (h.fta_rate - o.fta_rate) / o.fta_rate, 2) AS fta_rate,
        ROUND(100.0 * (h.fga3_rate - o.fga3_rate) / o.fga3_rate, 2) AS fga3_rate,
        ROUND(100.0 * (h.play_pct - o.play_pct) / o.play_pct, 2) AS play_pct
    FROM hob_avg h, opp_avg o
)

-- Combine 4 rows
SELECT * FROM hob_avg
UNION ALL
SELECT * FROM opp_avg
UNION ALL
SELECT * FROM abs_margin
UNION ALL
SELECT * FROM pct_margin;
