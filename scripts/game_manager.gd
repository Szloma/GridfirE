extends Node

@onready var HUD = $"../HUD"
@onready var vote_ui = $"../GUI/VoteUI"
@onready var leaderboard_ui = $"../GUI/Leaderboard"
@onready var leaderboard = $"../Leaderboard"
@onready var music= $"../MusicManager"
@onready var team = %TeamManager
@onready var background = $"../GUI/Background"
@export var round_time := 16
@export var break_time := 6
@export var vote_time :=6 
var round_active := false
var voting_active :=false
var break_active :=false
var map_id = 0

var vote_results := {}

func _ready() -> void:
	map_id=randi_range(0, %MapSpawner.maps.size()-1)
	multiplayer.connected_to_server.connect(_peer_connected_to_server)
	Global.leaderboard.connect(func()->void:
		if leaderboard_ui.visible:
			leaderboard_ui.hide()
		else:
			leaderboard_ui.show()
		)
	

func reset():
	leaderboard.reset()
	team.reset()


func start_round():
	
	round_active = true
	voting_active=false
	break_active=false
	%MapSpawner.spawn([map_id])
	%RoundTimer.start(round_time)
	%ItemsSpawner.start_spawning()
	leaderboard_ui.hide()
	hide_voting_ui.rpc()

func update_team_colors():
	for nd in get_tree().get_nodes_in_group("players"):
		var player_name = nd.name.to_int()
		var player_team = %TeamManager.get_player_team(player_name)
		var team_color =  %TeamManager.get_team_color(player_team)
		nd.set_player_name_color.rpc(team_color)

func update_teams():
	for nd in get_tree().get_nodes_in_group("players"):
		var player_name = nd.name.to_int()
		var player_team = %TeamManager.get_player_team(player_name)
		nd.set_team.rpc(player_team)
func disable_player_input():
	for nd in get_tree().get_nodes_in_group("players"):
		nd.disable_input()
func enable_player_input():
	for nd in get_tree().get_nodes_in_group("players"):
		nd.enable_input()

func end_round():
	if multiplayer.is_server():
		round_active = false
		vote_ui.enabled=true
		%ItemsSpawner.stop_spawning()
		%ItemsSpawner.despawn_all()
		%MapSpawner.despawn_map()

	##update players
		for nd in get_tree().get_nodes_in_group("players"):
			nd.reset.rpc()
		leaderboard.end_round()
		

@rpc("any_peer","call_local")
func hide_voting_ui():
	background.hide()
	background.set_process(false)
	Global.hud.emit(true)
	enable_player_input()
	vote_ui.set_process(false)
	vote_ui.hide()
	var _round_length=1
	if not multiplayer.is_server():
		_round_length = await RpcAwait.send_rpc(Global.host_id, get_remaining_time)
	else:
		_round_length=get_remaining_time()
	%RoundTimer.start(_round_length)
	HUD.start_round_timer()
	#get_tree().paused = false
	
@rpc("any_peer","call_local")
func show_voting_ui():
	disable_player_input()
	vote_results.clear()
	vote_ui.set_process(true)
	vote_ui.show()
	var _round_length=1
	if not multiplayer.is_server():
		_round_length = await RpcAwait.send_rpc(Global.host_id, get_remaining_time)
	else:
		_round_length=get_remaining_time()
	print("host id ", Global.host_id)
	%RoundTimer.start(_round_length)
	HUD.start_round_timer()
	#get_tree().paused = true
@rpc("any_peer","call_local")
func show_leaderboard(leaderboard, win_team):
	background.show()
	background.set_process(true)
	Global.hud.emit(false)
	disable_player_input()
	leaderboard_ui.set_process(true)
	leaderboard_ui.show()
	leaderboard_ui.display_winning_team(win_team)
	leaderboard_ui.display_leaderboard(leaderboard)
	var _round_length=1
	if not multiplayer.is_server():
		_round_length = await RpcAwait.send_rpc(Global.host_id, get_remaining_time)
	else:
		_round_length=get_remaining_time()
	print("host id ", Global.host_id)
	%RoundTimer.start(_round_length)
	HUD.start_round_timer()
@rpc("any_peer","call_local")
func hide_leaderboard():
	leaderboard_ui.set_process(false)
	leaderboard_ui.hide()
	show_voting_ui()


func _on_round_timer_timeout() -> void:
	if multiplayer.is_server():
		if round_active:
			end_round()

			break_active=true
			voting_active=false
			%RoundTimer.start(break_time)
			HUD.start_round_timer()
			show_leaderboard.rpc(leaderboard.get_leaderboard(), leaderboard.get_winning_team())
		elif break_active:
			break_active=false
			voting_active=true
			%RoundTimer.start(vote_time)
			hide_leaderboard.rpc()
		elif voting_active:
			round_active=true
			break_active=false
			voting_active=false
			map_id= vote_ui.calculate_votes()
			var team_names = %MapSpawner.get_map_resource(map_id).team_names
			%TeamManager.set_custom_teams(team_names)
			%TeamManager.shuffle_teams()
			update_teams()
			update_team_colors()
			start_round()
			

func _peer_connected_to_server():
	var _round_length = await RpcAwait.send_rpc(Global.host_id, get_remaining_time)
	%RoundTimer.start(_round_length)
	HUD.start_round_timer()
	music.stop_menu_music()
	

@rpc("any_peer")
func get_remaining_time():
	return %RoundTimer.time_left
