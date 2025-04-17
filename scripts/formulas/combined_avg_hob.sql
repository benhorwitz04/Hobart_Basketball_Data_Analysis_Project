-- combined averages over the last 5 seasons

SELECT 
    ROUND(AVG(points), 1) AS points,
    ROUND(AVG(fgm), 1) AS avg_fgm,
    ROUND(AVG(fga), 1) AS avg_fga,
    ROUND(AVG(fgm3), 1) AS avg_fgm3,
    ROUND(AVG(fga3), 1) AS avg_fga3,
    ROUND(AVG(ftm), 1) AS ftm,
    ROUND(AVG(fta), 1) AS fta,
    ROUND(AVG(oreb), 1) AS oreb,
    ROUND(AVG(dreb), 1) AS dreb,
    ROUND(AVG(treb), 1) AS treb,
    ROUND(AVG(ast), 1) AS ast,
    ROUND(AVG(stl), 1) AS stl,
    ROUND(AVG(blk), 1) AS blk,
    ROUND(AVG(pf), 1) AS pf,
    ROUND(AVG(turnovers), 1) AS turnovers,
    ROUND(AVG(pts_paint), 1) AS avg_pts_paint,
    ROUND(AVG(pts_to), 1) AS avg_pts_to,
    ROUND(AVG(pts_ch2), 1) AS avg_pts_ch2,
    ROUND(AVG(pts_fastb), 1) AS avg_pts_fastb,
    ROUND(AVG(pts_bench), 1) AS avg_pts_bench
FROM team_stats
WHERE team_name = 'Hobart';
