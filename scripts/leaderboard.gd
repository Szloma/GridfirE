extends Node

var player_scores = {} 
var team_scores = {}

var leaderboard=[]
var leadboard_teams= []

@rpc("any_peer","call_local")
func add_score(points: int, peer_id : int):
	var player_name = get_player_name(peer_id)
	var player_team = get_player_team(peer_id)
	if not team_scores.has(player_team):
		team_scores[player_team]= points
	else:
		team_scores[player_team]+=points
		
	if not player_scores.has(peer_id):
		
		player_scores[peer_id] = [player_name, points, player_team]
	else:

		var key = player_scores[peer_id]
		key[1]+= points
	print("scores ", player_scores)
	print("team scores ", team_scores)

func get_player_name(id):
	for nd in get_tree().get_nodes_in_group("players"):
		if str(id) == nd.name:
			return nd.player_name
	return "-"
func get_player_team(id):
	for nd in get_tree().get_nodes_in_group("players"):
		if str(id) == nd.name:
			return nd.team
	return "-"

func update_leaderboards():
	leaderboard.clear()
	leadboard_teams.clear()
	for player in player_scores.keys():
		var val = player_scores[player]
		leaderboard.append({
			"name": val[0],
			"score": val[1],
			"team": val[2]
		})
	leaderboard.sort_custom(func(a, b): return b["score"] - a["score"])
	for team in team_scores.keys():
		var val = team_scores[team]
		leadboard_teams.append({
			"team": team,
			"score": val
		})
	leadboard_teams.sort_custom(func(a, b): return b["score"] - a["score"])
	print("leaderboard: ", leaderboard)
	print("team leaderboard: ", leadboard_teams)


func get_leaderboard():
	return leaderboard
func get_winning_team():
	if leadboard_teams.size() >=1:
		var last_index = leadboard_teams.size()-1
		var before_last = leadboard_teams.size()-2
		if leadboard_teams[last_index]["score"]==leadboard_teams[before_last]["score"]:
			return leadboard_teams[last_index]["team"] + " and " + leadboard_teams[before_last]["team"]
	if !leadboard_teams.is_empty():
		return leadboard_teams.first()["team"]
	return ""
func end_round():
	update_leaderboards()
	player_scores.clear()
	team_scores.clear()
func reset():
	player_scores.clear()
	team_scores.clear()
