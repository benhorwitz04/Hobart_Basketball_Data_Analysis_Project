import os
import glob
from lxml import etree
import psycopg2

# === DATABASE CONNECTION ===
conn = psycopg2.connect(
    host="localhost",
    database="hobart_basketball_analysis",
    user="postgres",
    password="Otto194*!"
)
cur = conn.cursor()

# === BASE DIRECTORY CONTAINING ALL SEASON FOLDERS ===
base_dir = "/Users/benjaminhorwitz/Documents/Developer/Hobart_Data_Analysis_Project/BasketballXMLs"

# === LOOP THROUGH EACH SEASON FOLDER ===
for season_folder in os.listdir(base_dir):
    season_path = os.path.join(base_dir, season_folder)
    if not os.path.isdir(season_path):
        continue

    season = season_folder
    xml_files = glob.glob(os.path.join(season_path, "*.xml")) + \
                glob.glob(os.path.join(season_path, "*.XML"))

    print(f"\n📂 Season: {season} — {len(xml_files)} file(s) found")

    for file_path in xml_files:
        try:
            with open(file_path, "rb") as f:
                tree = etree.parse(f)
                root = tree.getroot()

                # Get game_id, or generate fallback from game_date + season
                game_date = root.findtext(".//date")
                game_id = root.findtext(".//gamecode")

                if not game_id:
                    if game_date:
                        game_id = f"{game_date.replace('-', '')}_{season}"
                    else:
                        raise ValueError("Missing both game_id and game_date")

                teams = root.findall(".//team")

                for team in teams:
                    team_id = team.get("vh")     # "H" or "V"
                    team_name = team.get("name")
                    is_home = team_id == "H"

                    stats = {
                        "fgm": int(team.findtext(".//fgm", default="0")),
                        "fga": int(team.findtext(".//fga", default="0")),
                        "fgm3": int(team.findtext(".//fgm3", default="0")),
                        "fga3": int(team.findtext(".//fga3", default="0")),
                        "ftm": int(team.findtext(".//ftm", default="0")),
                        "fta": int(team.findtext(".//fta", default="0")),
                        "oreb": int(team.findtext(".//oreb", default="0")),
                        "dreb": int(team.findtext(".//dreb", default="0")),
                        "treb": int(team.findtext(".//reb", default="0")),
                        "ast": int(team.findtext(".//ast", default="0")),
                        "stl": int(team.findtext(".//stl", default="0")),
                        "blk": int(team.findtext(".//blk", default="0")),
                        "pf": int(team.findtext(".//pf", default="0")),
                        "turnovers": int(team.findtext(".//to", default="0")),
                        "points": int(team.findtext(".//pts", default="0")),
                        "pts_paint": int(team.findtext(".//pts_paint", default="0")),
                        "pts_to": int(team.findtext(".//pts_to", default="0")),
                        "pts_ch2": int(team.findtext(".//pts_ch2", default="0")),
                        "pts_fastb": int(team.findtext(".//pts_fastb", default="0")),
                        "pts_bench": int(team.findtext(".//pts_bench", default="0")),
                    }

                    cur.execute("""
                        INSERT INTO team_stats (
                            game_id, team_id, team_name, is_home, season,
                            fgm, fga, fgm3, fga3, ftm, fta,
                            oreb, dreb, treb,
                            ast, stl, blk, pf, turnovers, points,
                            pts_paint, pts_to, pts_ch2, pts_fastb, pts_bench
                        ) VALUES (%s, %s, %s, %s, %s,
                                  %s, %s, %s, %s, %s, %s,
                                  %s, %s, %s,
                                  %s, %s, %s, %s, %s, %s,
                                  %s, %s, %s, %s, %s)
                        ON CONFLICT (game_id, team_id, season) DO NOTHING;
                    """, (
                        game_id, team_id, team_name, is_home, season,
                        stats["fgm"], stats["fga"], stats["fgm3"], stats["fga3"],
                        stats["ftm"], stats["fta"],
                        stats["oreb"], stats["dreb"], stats["treb"],
                        stats["ast"], stats["stl"], stats["blk"], stats["pf"],
                        stats["turnovers"], stats["points"],
                        stats["pts_paint"], stats["pts_to"], stats["pts_ch2"],
                        stats["pts_fastb"], stats["pts_bench"]
                    ))

            print(f"✅ Uploaded {os.path.basename(file_path)} from {season}")

        except Exception as e:
            print(f"❌ Error in {file_path}: {e}")
            conn.rollback()

# === CLOSE CONNECTION ===
conn.commit()
cur.close()
conn.close()

print("\n🎉 All XML files uploaded successfully.")
