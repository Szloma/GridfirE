extends Node


var team_names: Array[String] = ["Blue", "Green"]

var teams: Dictionary = {}

var team_colors: Dictionary = {
	"Blue": Color(0.2, 0.4, 1.0),
	"Green": Color(0.2, 0.9, 0.2),
	"Red": Color(1.0, 0.2, 0.2),
	"Yellow": Color(1.0, 1.0, 0.2),
	"Orange": Color(1.0, 0.5, 0.0),
	"Purple": Color(0.6, 0.2, 0.8)
}

func get_team_color(team_name: String) -> Color:
	return team_colors.get(team_name, Color.GRAY)

func _ready():
	reset_teams()

func reset_teams():
	teams.clear()
	for name in team_names:
		teams[name] = []

func assign_player(player_id):
	var smallest_team := get_smallest_team()
	teams[smallest_team].append(player_id)
	return smallest_team


func get_smallest_team() -> String:
	var smallest = team_names[0]
	var min_size = teams[smallest].size()

	for name in team_names:
		if teams[name].size() < min_size:
			smallest = name
			min_size = teams[name].size()
	return smallest


func get_player_team(player_id) -> String:
	for name in team_names:
		if player_id in teams[name]:
			return name
	return ""

func shuffle_teams():
	# Gather all players
	print("current teams ", teams)
	print("shuffling teams, new team colors: ", team_names)
	var all_players: Array = []
	for team in teams.values():
		all_players += team

	# Shuffle players randomly
	all_players.shuffle()

	# Clear current teams
	reset_teams()

	# Redistribute players
	for i in range(all_players.size()):
		var team_index = i % team_names.size()
		var team_name = team_names[team_index]
		teams[team_name].append(all_players[i])
	print("new team: ", teams)

func set_custom_teams(new_names: Array[String]):
	team_names = new_names
	
func reset():
	teams.clear()
