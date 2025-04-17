INSERT INTO games (
    game_id, game_date, start_time, location, attendance,
    home_team_id, home_team_name,
    away_team_id, away_team_name, season
)
VALUES (
    'HOB-YORK',
    '2024-11-09',       -- game_date
    '15:00',            -- start_time (3:00 PM)
    'Wolf Gymnasium',   -- location
    420,                -- attendance
    'YORK', 'York (Pa.)',
    'HOB', 'Hobart',
    '2024–25'           -- season label
);
