import os
import xml.etree.ElementTree as ET
import psycopg2
from datetime import datetime

# --- SETUP DATABASE CONNECTION ---
conn = psycopg2.connect(
    host="localhost",
    database="hobart_baketball_analysis",
    user="postgres",
    password="Otto194*!"
)
cur = conn.cursor()

# --- PATH TO XML FILES ---
folder_path = r"/Users/benjaminhorwitz/Documents/Developer/Hobart_Data_Analysis_Project/BasketballXMLs/2024_2025"

# --- LOOP THROUGH ALL XML FILES ---
for file in os.listdir(folder_path):
    if not file.lower().endswith(".xml"):
        continue

    print(f"📄 Processing file: {file}")
    filepath = os.path.join(folder_path, file)

    try:
        tree = ET.parse(filepath)
        root = tree.getroot()

        # --- Parse game info ---
        venue = root.find("venue")
        game_id = venue.get("gameid")
        date = datetime.strptime(venue.get("date"), "%m/%d/%Y").date()
        time = venue.get("time")
        location = venue.get("location")
        attendance = int(venue.get("attend") or 0)
        home_id = venue.get("homeid")
        home_name = venue.get("homename")
        away_id = venue.get("visid")
        away_name = venue.get("visname")

        cur.execute("""
            INSERT INTO games (game_id, game_date, start_time, location, attendance,
                               home_team_id, home_team_name, away_team_id, away_team_name)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING;
        """, (game_id, date, time, location, attendance,
              home_id, home_name, away_id, away_name))
        print(f"✅ Inserted game: {game_id}")

        # --- Parse team stats ---
        for team in root.findall("team"):
            team_id = team.get("id")
            team_name = team.get("name")
            is_home = team.get("vh") == "H"
            totals = team.find("totals/stats")
            special = team.find("totals/special")

            def get(tag): return int(totals.get(tag, 0)) if totals is not None else 0
            def get_special(tag): return int(special.get(tag, 0)) if special is not None else 0

            cur.execute("""
                INSERT INTO team_stats (
                    game_id, team_id, team_name, is_home,
                    points, fgm, fga, fgm3, fga3, ftm, fta,
                    oreb, dreb, treb, ast, stl, blk, pf, turnovers,
                    pts_paint, pts_to, pts_ch2, pts_fastb, pts_bench
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                          %s, %s, %s, %s, %s, %s, %s, %s,
                          %s, %s, %s, %s, %s)
                ON CONFLICT DO NOTHING;
            """, (
                game_id, team_id, team_name, is_home,
                get("tp"), get("fgm"), get("fga"), get("fgm3"), get("fga3"),
                get("ftm"), get("fta"), get("oreb"), get("dreb"), get("treb"),
                get("ast"), get("stl"), get("blk"), get("pf"), get("to"),
                get_special("pts_paint"), get_special("pts_to"),
                get_special("pts_ch2"), get_special("pts_fastb"), get_special("pts_bench")
            ))

            # --- Parse player stats ---
            for player in team.findall("player"):
                stats = player.find("stats")
                if stats is None:
                    continue
                name = player.get("name")
                jersey = player.get("uni")
                position = player.get("pos", "")

                def ps(tag): return int(stats.get(tag, 0))

                cur.execute("""
                    INSERT INTO player_stats (
                        game_id, team_id, player_name, jersey_number, position,
                        fgm, fga, fgm3, fga3, ftm, fta, tp,
                        oreb, dreb, treb, ast, stl, blk, pf, turnovers, minutes
                    ) VALUES (%s, %s, %s, %s, %s,
                              %s, %s, %s, %s, %s, %s, %s,
                              %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT DO NOTHING;
                """, (
                    game_id, team_id, name, jersey, position,
                    ps("fgm"), ps("fga"), ps("fgm3"), ps("fga3"),
                    ps("ftm"), ps("fta"), ps("tp"),
                    ps("oreb"), ps("dreb"), ps("treb"),
                    ps("ast"), ps("stl"), ps("blk"), ps("pf"),
                    ps("to"), ps("min")
                ))

        conn.commit()  # commit for this file
    except Exception as e:
        print(f"❌ Failed to process {file}: {e}")
        conn.rollback()  # undo only this file if something fails

# --- Clean up ---
cur.close()
conn.close()
print("🎉✅ All files loaded into PostgreSQL.")
