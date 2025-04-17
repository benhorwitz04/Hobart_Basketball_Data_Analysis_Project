SELECT
    ROUND(AVG(CASE WHEN team_id = 'HOB' THEN oreb END), 2) AS hob_oreb_game,
    ROUND(AVG(CASE WHEN team_id = 'HOB' THEN pts_ch2 END), 2) AS hob_second_chance_pts,
    ROUND(AVG(CASE WHEN team_id != 'HOB' THEN turnovers END), 2) AS opp_to_game,
    ROUND(AVG(CASE WHEN team_id = 'HOB' THEN pts_to END), 2) AS hob_pts_off_to
FROM team_stats;
