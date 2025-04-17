from lxml import etree

# Adjust this path if the XML file is located elsewhere
file_path = "/Users/benjaminhorwitz/Documents/Developer/Hobart_Data_Analysis_Project/BasketballXMLs/2023_2024/11-11-2023.XML"

with open(file_path, "rb") as f:
    tree = etree.parse(f)
    root = tree.getroot()

    teams = root.findall(".//team")
    for team in teams:
        team_name = team.get("name")
        print(f"\n📊 Team: {team_name}")

        players = team.findall(".//player")
        for player in players:
            print(f"🔎 {player.get('name')}: {player.attrib}")
