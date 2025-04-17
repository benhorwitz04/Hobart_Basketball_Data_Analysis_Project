UPDATE games
SET season = 
    CASE
        WHEN game_date BETWEEN '2019-08-01' AND '2020-07-31' THEN '2019–20'
        WHEN game_date BETWEEN '2020-08-01' AND '2021-07-31' THEN '2020–21'
        WHEN game_date BETWEEN '2021-08-01' AND '2022-07-31' THEN '2021–22'
        WHEN game_date BETWEEN '2022-08-01' AND '2023-07-31' THEN '2022–23'
        WHEN game_date BETWEEN '2023-08-01' AND '2024-07-31' THEN '2023–24'
        WHEN game_date BETWEEN '2024-08-01' AND '2025-07-31' THEN '2024–25'
        ELSE 'Unknown'
    END;
