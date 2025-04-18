# Hobart Basketball Data Analysis Project (2019–2025)

## 📚 Project Overview
This project analyzes Hobart Basketball's team performance from 2019 to 2025, using advanced metrics and data-driven insights to uncover team tendencies, strengths, and areas for growth.

It includes a combination of SQL, Python scripting, and manual data validation to build a clean, reliable database from raw XML, PDF, and manual entry sources.

> 📄 [Download the Full Data Analysis Portfolio (PDF)](Hobart_Basketball_Data_Analysis_Portfolio.pdf)

## 📚 Background
I currently serve as an assistant basketball coach for Hobart Basketball. One of the most exciting aspects of game preparation is the process of scouting opponents. When preparing for an upcoming scout, our coaching staff naturally tries to compile as much information as possible. A key part of that process involves gathering data and assembling a clear, objective picture of a team’s identity. While numbers are certainly not the entire story, they provide an unbiased foundation with large amounts of data to support the conclusions we draw.

For years, obtaining advanced metrics and in-depth analysis has been a challenge for programs like Hobart at the Division III level. Historically, there was a barrier to accessing the type of analytics and breakdowns available at higher levels of basketball. However, in recent years, the enthusiasm for analyzing sports through a data-focused lens has grown significantly, and the tools, formulas, and understanding of advanced metrics have become much more accessible.

As someone who considers himself an analytical coach, I was overjoyed from the outset of this project. The opportunity to provide value in a way that differentiates us from most programs at our level was exciting and motivating. I was eager to bring a more data-driven approach to our preparation and contribute a unique layer of insight to our program’s competitive strategy.

> 📄 [Download the Full Data Analysis Portfolio (PDF)](Hobart_Basketball_Data_Analysis_Portfolio.pdf)

---

## 🏀 Included Reports
- **Overall Success Summary (2019–2025)**: Wins, losses, month-by-month, home vs. away, top wins/losses by opponent.
- **Statistical Identity (2019–2025)**: Core tendencies across scoring, rebounding, special categories, and season comparisons.
- **Back-to-Back Game Analysis (2019–2025)**: Comparing performance on second games of back-to-backs.
- **Advanced Analytical Breakdown (2019–2025)**: 20+ advanced efficiency metrics, Dean Oliver's Four Factors.

---

## 📊 Data Collection Process
1. **Initial Web Scraping Attempt:** Tried scraping Hobart's website but faced dynamic content issues (Sidearm Sports platform).
2. **PDF Data Extraction Attempt:** Attempted parsing PDF box scores but found inconsistent formatting challenges.
3. **NCAA Game Manager (XML Files):** Gained access to XML files for structured data — but 18 games had missing/incomplete data.
4. **Database Schema and Table Setup:** Created PostgreSQL schema with `game_date` as the primary key.
5. **XML Upload Scripts:** Wrote Python scripts to upload XML files into PostgreSQL.
6. **PDF to JSON Conversion:** Built a PDF parsing script to convert data into JSON for consistent structure.
7. **JSON Upload to Database:** Uploaded converted JSONs into PostgreSQL.
8. **Data Export & Cleaning:** Exported database to CSV, cleaned datasets manually in Excel.
9. **Manual Data Entry:** Manually entered 8 missing games.
10. **Final Data Validation:** Used SQL `COUNT()` and manual checks to ensure integrity.

---

## ⚙️ Tech Stack
- **Python** (Data Parsing, Upload Scripts)
- **PostgreSQL** (Database Management)
- **SQL** (Data Analysis Queries)
- **Excel** (Manual Data Cleaning)
- **Bricks** (Graphs and Visuals)
- **VS Code** (Development Environment)
- **ChatGPT** (Code revsion and construciton)

---

## 🛠 The Analysis & Sample SQL Queries

### 1) Overall Success Summary



```sql
--- Wins/losses by month over last 5 years


WITH hobart_monthly_games AS (
    SELECT
        TO_CHAR(game_date::date, 'Month') AS month,
        EXTRACT(MONTH FROM game_date) AS month_num,
        is_win
    FROM team_stats
    WHERE team_id = 'HOB'
),
monthly_summary AS (
    SELECT
        TRIM(month) AS month,
        month_num,
        COUNT(*) AS games_played,
        COUNT(CASE WHEN is_win THEN 1 END) AS wins,
        COUNT(CASE WHEN NOT is_win THEN 1 END) AS losses,
        ROUND(100.0 * COUNT(CASE WHEN is_win THEN 1 END) / COUNT(*), 1) AS win_pct
    FROM hobart_monthly_games
    GROUP BY month, month_num
)
SELECT
    month,
    games_played,
    wins,
    losses,
    win_pct
FROM monthly_summary
WHERE month IN ('November', 'December', 'January', 'February', 'March')
ORDER BY month_num;
```

![hob_monthly_win_per](https://github.com/user-attachments/assets/b0d4de50-cab2-4643-ad0f-32699003f3c3)


### 2) Statistical Identity

```sql
--- Hobart % margin comparison for each season

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

```

![image](https://github.com/user-attachments/assets/0054b815-b751-4fcb-8f4a-560b0ff5d358)


### 3) Back-to-Back Game Analysis


```sql
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
```


#### Key Highlights – Second Day B2B vs. Full Season
| Metric             | Full Season | Second Day B2B | Margin Change | % Margin Change |
|--------------------|-------------|----------------|---------------|-----------------|
| Win %              | 66.7        | 75.0           | 8.3           | 12.5%           |
| FTM                | 12.87       | 13.95          | 1.08          | 8.4%            |
| FTA                | 18.87       | 19.98          | 1.11          | 5.9%            |
| 3pt FG%            | 32.6        | 34.4           | 1.8           | 5.5%            |
| Second Chance Pts  | 11.47       | 11.93          | 0.46          | 4.0%            |
| Bench Points       | 21.43       | 22.09          | 0.66          | 3.1%            |
| Turnovers          | 13.7        | 13.27          | 0.43          | 3.1%            |
| FT %               | 68.2        | 69.9           | 1.7           | 2.5%            |



### 4) Advanced Analytical Breakdown

```sql
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
```

![Dean_Olivers_Four_Factors Breakdown jpeg 11-15-28-504](https://github.com/user-attachments/assets/63b61b3a-3a7d-4b17-bb4c-e0e67d513716)




