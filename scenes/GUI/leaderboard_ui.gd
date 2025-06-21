extends Control

@export var player_card_scene : PackedScene 
@onready var leaderboard_container = %LeaderboardContainer
@onready var winning_team= $MarginContainer/MarginContainer/VBoxContainer2/MarginContainer2/WinningTeamLabel
func display_winning_team(team:String):
	if team.length() ==0:
		winning_team.text = "No definitive winner"
	else:
		winning_team.text = "Team " + team + " won!"


func display_leaderboard(leaderboard_data: Array):
	
	for child in leaderboard_container.get_children():
		child.queue_free()


	for i in range(leaderboard_data.size()):
		var entry = leaderboard_data[i]
		var player_name = entry["name"]
		var player_score = entry["score"]
		var player_team = entry["team"]
		var player_card = player_card_scene.instantiate()
		player_card.setup(player_name, player_score, player_team)
		leaderboard_container.add_child(player_card)
	visible = true

func request_leaderboard():
	pass

func end_round():
	pass
