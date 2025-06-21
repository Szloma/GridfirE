extends Control

@onready var grid =$MarginContainer/MarginContainer/VBoxContainer/GridContainer
@export var map_vote_card: PackedScene
@onready var game_manager = $"../../GameManager"
var vote = -1
var enabled = false
var vote_results :Dictionary

func _ready():
	populate_grid()

func populate_grid():
	var map_id = 0
	for map_data in %MapSpawner.maps:
		var card = map_vote_card.instantiate()
		card.setup(map_data, map_id)
		card.voted.connect(_on_vote_pressed)
		grid.add_child(card)
		map_id+=1

@rpc("any_peer")
func receive_vote(map_id):
	print("received vote from ", multiplayer.get_unique_id(), " ", map_id)
	if enabled:
		var sender_id = multiplayer.get_remote_sender_id()
		vote_results[sender_id] = map_id
		print("vote results ", vote_results)
	else:
		return

func send_vote():
	return vote

func _on_vote_pressed(map_id):
	# Register vote
	print("sending vote to ", Global.host_id, " ", map_id)
	receive_vote.rpc_id(Global.host_id,map_id)
	vote = map_id
	#game_manager.vote_results[name] = game_manager.vote_results.get(name, 0) + 1
	#return map_data.name

	# After delay, load winning map
#	await get_tree().create_timer(3).timeout
	
	#load_voted_map()
func calculate_votes():
	var vote_counts: Dictionary = {}

	for player_id in vote_results:
		var map_id = vote_results[player_id]
		vote_counts[map_id] = vote_counts.get(map_id, 0) + 1

	var most_voted_map := -1
	var highest_votes := -1

	for map_id in vote_counts:
		if vote_counts[map_id] > highest_votes:
			highest_votes = vote_counts[map_id]
			most_voted_map = map_id

	return most_voted_map
#func load_voted_map():
	#var highest_votes = -1
	#var selected: MapData = null
	#for map_data in GameManager.available_maps:
		#var votes = GameManager.vote_results.get(map_data.name, 0)
		#if votes > highest_votes:
			#highest_votes = votes
			#selected = map_data
#
	#if selected:
		#GameManager.load_map(selected)
