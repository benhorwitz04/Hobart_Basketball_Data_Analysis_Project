SELECT
    COUNT(*) AS total_home_games,
    ROUND(AVG(attendance), 1) AS avg_home_attendance
FROM games
WHERE home_team_id = 'HOB';



SELECT
    COUNT(*) AS total_away_games,
    ROUND(AVG(attendance), 1) AS avg_away_attendance
FROM games
WHERE away_team_id = 'HOB';
