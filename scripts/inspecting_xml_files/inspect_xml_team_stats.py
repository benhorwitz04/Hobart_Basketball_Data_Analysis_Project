import os
from lxml import etree

# Path to the XML file
xml_file = "/Users/benjaminhorwitz/Documents/Developer/Hobart_Data_Analysis_Project/BasketballXMLs/2023_2024/11-11-2023.XML"

# Parse the XML
tree = etree.parse(xml_file)
root = tree.getroot()

def extract_team_data(team_tag):
    team_id = team_tag.get("id")
    team_name = team_tag.get("name")
    vh = team_tag.get("vh")

    # Standard stats
    stats = team_tag.find("totals/stats")
    team_stats = {k: stats.get(k) for k in stats.keys()}

    # Special stats
    special = team_tag.find("totals/special")
    special_stats = {k: special.get(k) for k in special.keys() if k != "vh"}

    return {
        "team_id": team_id,
        "team_name": team_name,
        "vh": vh,
        **team_stats,
        **special_stats
    }

# Process both teams
teams = root.findall("team")
team_data = [extract_team_data(team) for team in teams]

# Print out extracted data
for i, team in enumerate(team_data):
    print(f"\n🏀 Team {i+1}: {team['team_name']} ({'Home' if team['vh'] == 'H' else 'Visitor'})")
    print("Standard Stats:")
    print({k: team[k] for k in team if k not in ['team_id', 'team_name', 'vh', 'pts_to', 'pts_ch2', 'pts_paint', 'pts_fastb', 'pts_bench']})
    print("Special Stats:")
    print({k: team[k] for k in ['pts_to', 'pts_ch2', 'pts_paint', 'pts_fastb', 'pts_bench']})
