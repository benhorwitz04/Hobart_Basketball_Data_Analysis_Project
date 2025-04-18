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



```
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
![hob_monthly_win_per](https://github.com/user-attachments/assets/6b359c2c-8cbf-442f-94b3-62e044d52b77)



### 2) Statistical Identity


![image](https://github.com/user-attachments/assets/e6e59f67-8f69-403e-ac0d-03fe6bd5ee98)



### 3) Back-to-Back Game Analysis



### 4) Advanced Analytical Breakdown





