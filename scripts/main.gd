extends Node3D

@onready var HUD = $HUD
@onready var server_controller = $ServerController
@onready var client_controller =$ClientController
@export var character_creator_scene : PackedScene
@onready var character_creator_container =$CharacterCreator
@onready var ingame_menu = $GUI/IngameMenu
@onready var main_menu = $GUI/MainMenu
@onready var game_manager = $GameManager
@export var round_length := 60
@onready var options = $GUI/Options
@onready var music = $MusicManager
@onready var background = $GUI/Background
@onready var credits = $GUI/Credits
@onready var effects = $Effects
@onready var tutorial = $GUI/Tutorial

var player_name = "aaa"
var player_character_settings=[]

func _ready() -> void:

	if DisplayServer.get_name() == "headless":
		start_server()

		start_round()

	multiplayer.peer_connected.connect(_on_player_joined)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connected_to_server.connect(_peer_connected_to_server)
	multiplayer.connection_failed.connect(_on_peer_connection_failed)
	Global.disconnect.connect(_on_peer_connection_failed)
	Global.close_server.connect(_on_close_server)
	if OS.has_feature("web"):
		$GUI/MainMenu/VBoxContainer/Exit.hide()
		$GUI/MainMenu/VBoxContainer/Host.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("tutorial"):
		if tutorial.visible:
			tutorial.hide()
		else:
			tutorial.show()

func start_server():
	server_controller.start()
func join_server():
	client_controller.join_game()

func create_changing_room():
	
	for n in character_creator_container.get_children():
		character_creator_container.remove_child(n)
	var character_creator = character_creator_scene.instantiate()
	character_creator.character_created.connect(_on_character_created)
	character_creator.back.connect(show_main_menu)
	character_creator_container.add_child(character_creator)
	

func remove_changing_room():
	for n in character_creator_container.get_children():
		character_creator_container.remove_child(n)


###SIGNALS
func _on_join_pressed() -> void:
	create_changing_room()
	background.hide()
	background.set_process(false)
	main_menu.hide()
	main_menu.set_process(false)
	
func _on_host_pressed() -> void:
	start_server()
	start_round()
	background.hide()
	background.set_process(false)
	HUD.show()
	music.stop_menu_music()
	_on_player_joined(multiplayer.get_unique_id())
	main_menu.hide()
	main_menu.set_process(false)
	
	
func _on_character_created(player_name,player_character_settings):
	self.player_name=player_name
	self.player_character_settings=player_character_settings
	remove_changing_room()
	join_server()

func show_main_menu():
	music.start_menu_music()
	background.set_process(true)
	background.pick_random_texture()
	background.show()
	main_menu.set_process(true)
	main_menu.show()
	options.hide()
	options.set_process(false)
	remove_changing_room()

func get_player_name():
	return player_name

func get_player_character_settings():
	return player_character_settings

func _on_player_joined(id):
	if multiplayer.is_server():
		var _player_name =player_name
		var _player_character_settings = [3, 1, 7, 8, 1, 0]
		
		if id!=1:
			_player_name = await RpcAwait.send_rpc(id, get_player_name)
			_player_character_settings = await RpcAwait.send_rpc(id, get_player_character_settings)
		
		if _player_name==null or _player_character_settings==null:
			$ServerController.disconnect_peer(id)
			return
		
		var assigned_team = %TeamManager.assign_player(id)
		var team_color = %TeamManager.get_team_color(assigned_team)
		var spawn_position = %Map.get_spawn_location(assigned_team)
		var spawn_array =[
			id, _player_name,_player_character_settings,assigned_team, team_color, spawn_position
		]
		
		var player = %PlayerSpawner.spawn(spawn_array)

func _on_server_disconnected():
	background.pick_random_texture()
	background.show()
	background.set_process(true)
	main_menu.show()
	main_menu.set_process(true)

	HUD.hide()

func _peer_connected_to_server():
	HUD.show()

	
func stop_round():
	pass

func start_round():
	game_manager.start_round()
	HUD.start_round_timer()
	

func _on_round_timer_timeout() -> void:
	print("round is over")

func _on_peer_connection_failed():
	ingame_menu.hide()
	effects.disable_sepia()
	music.start_menu_music()
	client_controller.stop()
	
	_on_server_disconnected()
func _on_close_server():
	music.start_menu_music()
	server_controller.stop()
	main_menu.show()
	game_manager.reset()
	

func _on_options_pressed() -> void:
	options.show()
	main_menu.hide()
	await options.back
	options.hide()
	main_menu.show()


func _on_exit_pressed() -> void:
	if multiplayer.is_server():
		_on_close_server()
	else:
		_on_peer_connection_failed()
	get_tree().quit()


func _on_credits_pressed() -> void:
	credits.show()
	main_menu.hide()
	await credits.back
	credits.hide()
	main_menu.show()
