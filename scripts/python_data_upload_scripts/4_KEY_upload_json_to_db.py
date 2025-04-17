import os
import json
import psycopg2

# --- CONFIGURE YOUR DATABASE CONNECTION ---
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "hobart_basketball_analysis",
    "user": "postgres",
    "password": "Otto194*!"
}

def insert_game(cur, metadata):
    cur.execute("""
        INSERT INTO games (
            game_date, game_id, start_time, location, attendance,
            home_team_id, home_team_name, away_team_id, away_team_name
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (game_date) DO NOTHING;
    """, (
        metadata["game_date"],
        metadata["game_id"],
        metadata["start_time"],
        metadata.get("location", None),
        metadata["attendance"],
        metadata["home_team_id"],
        metadata["home_team_name"],
        metadata["away_team_id"],
        metadata["away_team_name"]
    ))

def insert_team_stats(cur, metadata, totals, team_id, is_home):
    try:
        fgm, fga = map(int, totals["fg"].split("-"))
        fgm3, fga3 = map(int, totals["fg3"].split("-"))
        ftm, fta = map(int, totals["ft"].split("-"))
        oreb, dreb = map(int, totals["orb-drb"].split("-"))
    except Exception:
        fgm = fga = fgm3 = fga3 = ftm = fta = oreb = dreb = None

    cur.execute("""
        INSERT INTO team_stats (
            game_date, team_id, team_name, is_home, game_id,
            points, fgm, fga, fgm3, fga3, ftm, fta,
            oreb, dreb, treb, ast, stl, blk, pf, turnovers,
            pts_paint, pts_to, pts_ch2, pts_fastb, pts_bench
        )
        VALUES (%s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s)
        ON CONFLICT (game_date, team_id) DO NOTHING;
    """, (
        metadata["game_date"],
        team_id,
        team_id,
        is_home,
        metadata["game_id"],
        totals["pts"],
        fgm,
        fga,
        fgm3,
        fga3,
        ftm,
        fta,
        oreb,
        dreb,
        totals["reb"],
        totals["ast"],
        totals["stl"],
        totals["blk"],
        totals["pf"],
        totals["to"],
        totals.get("pts_paint"),
        totals.get("pts_to"),
        totals.get("pts_ch2"),
        totals.get("pts_fastb"),
        totals.get("pts_bench")
    ))

def insert_player_stats(cur, metadata, players, team_id):
    for player in players:
        cur.execute("""
            INSERT INTO player_stats (
                game_date, team_id, player_name,
                jersey_number, minutes, fgm, fga, fgm3, fga3, ftm, fta,
                oreb, dreb, treb, pf, ast, turnovers, blk, stl, tp
            )
            VALUES (%s, %s, %s,
                    %s, %s, %s, %s, %s, %s, %s, %s,
                    %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (game_date, team_id, player_name) DO NOTHING;
        """, (
            metadata["game_date"],
            team_id,
            player["player_name"],
            player["jersey_number"],
            player["min"],
            player["fgm"],
            player["fga"],
            player["fgm3"],
            player["fga3"],
            player["ftm"],
            player["fta"],
            player["oreb"],
            player["dreb"],
            player["treb"],
            player["pf"],
            player["ast"],
            player["turnovers"],
            player["blk"],
            player["stl"],
            player["pts"]
        ))

def main():
    input_dir = os.path.join(os.getcwd(), "output")
    files = [f for f in os.listdir(input_dir) if f.endswith(".json")]

    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    for file in files:
        path = os.path.join(input_dir, file)
        print(f"\n📄 Loading {file}...")

        try:
            with open(path, "r") as f:
                data = json.load(f)

            metadata = data["metadata"]

            insert_game(cur, metadata)

            insert_team_stats(cur, metadata, data["team1"]["totals"], metadata["away_team_id"], is_home=False)
            insert_team_stats(cur, metadata, data["team2"]["totals"], metadata["home_team_id"], is_home=True)


            insert_player_stats(cur, metadata, data["team1"]["players"], metadata["away_team_id"])
            insert_player_stats(cur, metadata, data["team2"]["players"], metadata["home_team_id"])

            conn.commit()
            print(f"✅ Saved game: {metadata['game_id']}")

        except Exception as e:
            conn.rollback()
            print(f"❌ Error processing {file}: {e}")

    cur.close()
    conn.close()
    print("\n🏁 All done!")

if __name__ == "__main__":
    main()
