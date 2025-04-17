# Hobart Basketball Data Analysis Project (2019–2025)

## 📚 Project Overview
This project analyzes Hobart Basketball's team performance from 2019 to 2025, using advanced metrics and data-driven insights to uncover team tendencies, strengths, and areas for growth.

It includes a combination of SQL, Python scripting, and manual data validation to build a clean, reliable database from raw XML, PDF, and manual entry sources.

> 📄 [Download the Full Data Analysis Portfolio (PDF)](Hobart_Basketball_Data_Analysis_Portfolio.pdf)

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

## 🏀 Included Reports
- **Overall Success Summary (2019–2025)**: Wins, losses, month-by-month, home vs. away.
- **Statistical Identity (2019–2025)**: Core tendencies across scoring, rebounding, and special teams.
- **Back-to-Back Game Analysis (2019–2025)**: Comparing performance on second games of back-to-backs.
- **Advanced Analytical Breakdown (2019–2025)**: Dean Oliver's Four Factors, advanced efficiency metrics.

---

## ⚙️ Tech Stack
- **Python** (Data Parsing, Upload Scripts)
- **PostgreSQL** (Database Management)
- **SQL** (Data Analysis Queries)
- **Excel** (Manual Data Cleaning)
- **VS Code** (Development Environment)

---

## 🛠 Sample SQL Query
Here's a small example of one of the queries used to calculate team possessions:

```sql
SELECT 
    season,
    ROUND(AVG(avg_fga - avg_oreb + avg_to + 0.475 * avg_fta), 2) AS possessions
FROM team_stats
WHERE team_id = 'HOB'
GROUP BY season;


