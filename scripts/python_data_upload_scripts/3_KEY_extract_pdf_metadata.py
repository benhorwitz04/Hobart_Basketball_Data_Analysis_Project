import pdfplumber
import re
from datetime import datetime
import os
import json

def standardize_team_name(name):
    return re.sub(r"\(.*?\)", "", name).strip()

def get_game_date_from_filename(filename):
    base = os.path.splitext(filename)[0]
    try:
        date_obj = datetime.strptime(base, "%m-%d-%Y")
        return date_obj.strftime("%Y-%m-%d")
    except Exception:
        return None

def extract_game_metadata(text):
    lines = text.splitlines()

    metadata = {
        "game_date": None,
        "start_time": None,
        "attendance": None,
        "location": None,  # Now always NULL
        "home_team_name": None,
        "away_team_name": None,
        "home_team_id": None,
        "away_team_id": None,
        "home_points": None,
        "away_points": None,
        "game_id": None
    }

    for line in lines:
        if "-vs-" in line:
            parts = line.split("-vs-")
            if len(parts) == 2:
                away_raw = parts[0].strip()
                home_raw = parts[1].strip()
                metadata["away_team_name"] = standardize_team_name(away_raw)
                metadata["away_team_id"] = metadata["away_team_name"]
                metadata["home_team_name"] = standardize_team_name(home_raw)
                metadata["home_team_id"] = metadata["home_team_name"]

        if "Time:" in line:
            metadata["start_time"] = line.split("Time:")[1].strip()

        if "Attendance:" in line:
            try:
                metadata["attendance"] = int(line.split("Attendance:")[1].strip())
            except Exception:
                metadata["attendance"] = None

        if metadata["away_team_name"] and metadata["away_team_name"] in line and metadata["away_points"] is None:
            match = re.match(rf"^{re.escape(metadata['away_team_name'])}\s+(\d+)$", line.strip())
            if match:
                metadata["away_points"] = int(match.group(1))

        if metadata["home_team_name"] and metadata["home_points"] is None:
            if metadata["home_team_name"] in line and re.search(r"\d+\s+\d+\s+\d+$", line.strip()):
                try:
                    metadata["home_points"] = int(line.strip().split()[-1])
                except Exception:
                    pass

    # Add game_id
    if metadata["away_team_id"] and metadata["home_team_id"]:
        metadata["game_id"] = f"{metadata['away_team_id']} - {metadata['home_team_id']}"

    return metadata

def extract_team_players(text, team_number=1):
    lines = text.splitlines()
    players = []
    player_blocks_found = 0
    current_block = []

    for i, line in enumerate(lines):
        if re.search(r"GS\s+MIN\s+FG\s+3PT\s+FT", line):
            player_blocks_found += 1
            if player_blocks_found == team_number:
                current_block = lines[i+1:]
                break

    player_lines = []
    for line in current_block:
        if line.startswith("TM Team") or line.startswith("Totals"):
            break
        if line.strip():
            player_lines.append(line.strip())

    for line in player_lines:
        parts = line.split()
        if len(parts) < 15:
            continue

        jersey_number = parts[0]
        name_parts = []
        stat_start_idx = None
        for i in range(1, len(parts)):
            if parts[i].isdigit():
                name_parts = parts[1:i]
                stat_start_idx = i
                break

        if stat_start_idx is None:
            continue

        stat_parts = parts[stat_start_idx:]
        player_name = " ".join(name_parts).replace("*", "").strip()

        try:
            player = {
                "jersey_number": jersey_number,
                "player_name": player_name,
                "min": int(stat_parts[0]),
                "fgm": int(stat_parts[1].split("-")[0]),
                "fga": int(stat_parts[1].split("-")[1]),
                "fgm3": int(stat_parts[2].split("-")[0]),
                "fga3": int(stat_parts[2].split("-")[1]),
                "ftm": int(stat_parts[3].split("-")[0]),
                "fta": int(stat_parts[3].split("-")[1]),
                "oreb": int(stat_parts[4].split("-")[0]),
                "dreb": int(stat_parts[4].split("-")[1]),
                "treb": int(stat_parts[5]),
                "pf": int(stat_parts[6]),
                "ast": int(stat_parts[7]),
                "turnovers": int(stat_parts[8]),
                "blk": int(stat_parts[9]),
                "stl": int(stat_parts[10]),
                "pts": int(stat_parts[11])
            }
            players.append(player)
        except Exception:
            print(f"⚠️ Could not parse player line: {line}")
            continue

    return players

def extract_team_totals(text, team_number=1):
    lines = text.splitlines()
    totals_found = 0

    for line in lines:
        if line.startswith("Totals"):
            totals_found += 1
            if totals_found == team_number:
                parts = line.replace("Totals -", "").strip().split()
                try:
                    return {
                        "minutes": int(parts[0]),
                        "fg": parts[1],
                        "fg3": parts[2],
                        "ft": parts[3],
                        "orb-drb": parts[4],
                        "reb": int(parts[5]),
                        "pf": int(parts[6]),
                        "ast": int(parts[7]),
                        "to": int(parts[8]),
                        "blk": int(parts[9]),
                        "stl": int(parts[10]),
                        "pts": int(parts[11])
                    }
                except Exception:
                    print(f"⚠️ Could not parse team {team_number} totals: {line}")
                    return None
    return None

if __name__ == "__main__":
    pdf_filename = "1-10-2023.pdf"
    pdf_path = os.path.join("/Users/benjaminhorwitz/Documents/Developer/Hobart_Data_Analysis_Project/pdf_games", pdf_filename)

    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[0].extract_text()

    metadata = extract_game_metadata(text)
    game_date = get_game_date_from_filename(pdf_filename)
    if game_date:
        metadata["game_date"] = game_date

    print("\n📋 Game Metadata:")
    print(json.dumps(metadata, indent=2))

    print("\n🏀 Hobart (Team 1) Player Stats:")
    team1_players = extract_team_players(text, team_number=1)
    print(json.dumps(team1_players, indent=2))

    print("\n📊 Hobart (Team 1) Team Totals:")
    team1_totals = extract_team_totals(text, team_number=1)
    print(json.dumps(team1_totals, indent=2))

    print("\n🏀 York (Team 2) Player Stats:")
    team2_players = extract_team_players(text, team_number=2)
    print(json.dumps(team2_players, indent=2))

    print("\n📊 York (Team 2) Team Totals:")
    team2_totals = extract_team_totals(text, team_number=2)
    print(json.dumps(team2_totals, indent=2))

    # ✅ Save all extracted data to JSON
    game_data = {
        "metadata": metadata,
        "team1": {
            "players": team1_players,
            "totals": team1_totals
        },
        "team2": {
            "players": team2_players,
            "totals": team2_totals
        }
    }

    output_dir = os.path.join(os.getcwd(), "output")
    os.makedirs(output_dir, exist_ok=True)

    output_file = os.path.join(output_dir, f"{metadata['game_date']}_game_data.json")

    with open(output_file, "w") as f:
        json.dump(game_data, f, indent=2)

    print(f"\n💾 Saved to: {output_file}")
