import pandas as pd
import psycopg2

# === Load CSVs ===
games_df = pd.read_csv("games.csv")
player_stats_df = pd.read_csv("player_stats.csv")
team_stats_df = pd.read_csv("team_stats.csv")

# === Clean missing/null values ===
games_df = games_df.where(pd.notnull(games_df), None)
player_stats_df = player_stats_df.where(pd.notnull(player_stats_df), None)
team_stats_df = team_stats_df.where(pd.notnull(team_stats_df), None)

# === Format columns ===
games_df["game_date"] = games_df["game_date"].astype(str).str.strip()
player_stats_df["game_date"] = player_stats_df["game_date"].astype(str).str.strip()
team_stats_df["game_date"] = team_stats_df["game_date"].astype(str).str.strip()

# Convert is_home to proper boolean
team_stats_df["is_home"] = team_stats_df["is_home"].apply(lambda x: True if str(x).lower() in ["true", "1"] else False)

# === Connect to PostgreSQL ===
conn = psycopg2.connect(
    host="localhost",
    database="hobart_basketball_analysis",
    user="postgres",
    password="Otto194*!"
)
cur = conn.cursor()

# === Insert into games ===
for _, row in games_df.iterrows():
    try:
        cur.execute("""
            INSERT INTO games (
                game_date, game_id, start_time, location, attendance,
                home_team_id, home_team_name, away_team_id, away_team_name
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (game_date) DO NOTHING;
        """, (
            row["game_date"], row["game_id"], row["start_time"], row["location"], row["attendance"],
            row["home_team_id"], row["home_team_name"], row["away_team_id"], row["away_team_name"]
        ))
        print(f"✅ Inserted game: {row['game_id']}")
    except Exception as e:
        print(f"❌ Error inserting game on {row['game_date']}: {e}")

# === Cache valid game_dates for foreign key checks ===
cur.execute("SELECT game_date FROM games")
valid_game_dates = set(str(row[0]).strip() for row in cur.fetchall())

# === Insert into team_stats ===
for _, row in team_stats_df.iterrows():
    if row["game_date"] not in valid_game_dates:
        print(f"⚠️ Skipping {row['team_id']} on {row['game_date']} — game_date not in games table")
        continue
    try:
        cur.execute("""
            INSERT INTO team_stats (
                game_date, game_id, team_id, team_name, is_home,
                points, fgm, fga, fgm3, fga3, ftm, fta,
                oreb, dreb, treb, ast, stl, blk, pf, turnovers,
                pts_paint, pts_to, pts_ch2, pts_fastb, pts_bench
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (game_date, team_id) DO NOTHING;
        """, (
            row["game_date"], row["game_id"], row["team_id"], row["team_name"], row["is_home"],
            row["points"], row["fgm"], row["fga"], row["fgm3"], row["fga3"],
            row["ftm"], row["fta"], row["oreb"], row["dreb"], row["treb"],
            row["ast"], row["stl"], row["blk"], row["pf"], row["turnovers"],
            row["pts_paint"], row["pts_to"], row["pts_ch2"], row["pts_fastb"], row["pts_bench"]
        ))
        print(f"✅ Inserted team_stats for {row['team_id']} on {row['game_date']}")
    except Exception as e:
        print(f"❌ Error inserting team_stats on {row['game_date']} ({row['team_id']}): {e}")

# === Insert into player_stats ===
for _, row in player_stats_df.iterrows():
    if row["game_date"] not in valid_game_dates:
        print(f"⚠️ Skipping {row['player_name']} on {row['game_date']} — game_date not in games table")
        continue
    try:
        cur.execute("""
            INSERT INTO player_stats (
                game_date, game_id, team_id, player_name, jersey_number, position,
                fgm, fga, fgm3, fga3, ftm, fta, tp,
                oreb, dreb, treb, pf, ast, turnovers, blk, stl, minutes
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (game_date, team_id, player_name) DO NOTHING;
        """, (
            row["game_date"], row["game_id"], row["team_id"], row["player_name"],
            row["jersey_number"], row["position"],
            row["fgm"], row["fga"], row["fgm3"], row["fga3"], row["ftm"], row["fta"], row["tp"],
            row["oreb"], row["dreb"], row["treb"], row["pf"], row["ast"],
            row["turnovers"], row["blk"], row["stl"], row["minutes"]
        ))
        print(f"✅ Inserted player_stats for {row['player_name']} on {row['game_date']}")
    except Exception as e:
        print(f"❌ Error inserting player_stats on {row['game_date']} ({row['player_name']}): {e}")

# === Finalize ===
conn.commit()
cur.close()
conn.close()
print("🏁 All data uploaded successfully!")
