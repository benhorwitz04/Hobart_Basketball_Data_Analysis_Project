-- Drop tables if they exist (order matters due to foreign key constraints)
DROP TABLE IF EXISTS player_stats;
DROP TABLE IF EXISTS team_stats;
DROP TABLE IF EXISTS games;

-- Recreate 'games' table
CREATE TABLE games (
    game_date DATE PRIMARY KEY,
    game_id TEXT,
    start_time TEXT,
    location TEXT,
    attendance INTEGER,
    home_team_id TEXT,
    home_team_name TEXT,
    away_team_id TEXT,
    away_team_name TEXT
);

-- Recreate 'team_stats' table
CREATE TABLE team_stats (
    game_date DATE REFERENCES games(game_date),
    game_id TEXT,
    team_id TEXT,
    team_name TEXT,
    is_home BOOLEAN,
    points INTEGER,
    fgm INTEGER,
    fga INTEGER,
    fgm3 INTEGER,
    fga3 INTEGER,
    ftm INTEGER,
    fta INTEGER,
    oreb INTEGER,
    dreb INTEGER,
    treb INTEGER,
    ast INTEGER,
    stl INTEGER,
    blk INTEGER,
    pf INTEGER,
    turnovers INTEGER,
    pts_paint INTEGER,
    pts_to INTEGER,
    pts_ch2 INTEGER,
    pts_fastb INTEGER,
    pts_bench INTEGER,
    PRIMARY KEY (game_date, team_id)
);

-- Recreate 'player_stats' table
CREATE TABLE player_stats (
    game_date DATE REFERENCES games(game_date),
    game_id TEXT,
    team_id TEXT,
    player_name TEXT,
    jersey_number TEXT,
    position TEXT,
    fgm INTEGER,
    fga INTEGER,
    fgm3 INTEGER,
    fga3 INTEGER,
    ftm INTEGER,
    fta INTEGER,
    tp INTEGER,
    oreb INTEGER,
    dreb INTEGER,
    treb INTEGER,
    ast INTEGER,
    stl INTEGER,
    blk INTEGER,
    pf INTEGER,
    turnovers INTEGER,
    minutes INTEGER,
    PRIMARY KEY (game_date, team_id, player_name)
);
