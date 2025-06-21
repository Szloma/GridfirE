extends MultiplayerSpawner

var players = {}
@export var player_scene :PackedScene
func _ready():
	multiplayer.peer_disconnected.connect(despawn_player)
	spawn_function = spawn_player
func spawn_player(data):
	print("PLAYER SPAWNER ", multiplayer.get_unique_id(), " spawning player: ", data)

	var player_id = data[0]
	var player_name = data[1]
	var player_character_settings = data[2]
	var team = data[3]
	var team_color = data[4]
	var spawn_position = data[5]
	if spawn_position==null:
		spawn_position = Vector3.ZERO
	var p =player_scene.instantiate()

	p.set_multiplayer_authority(player_id)
#
	p.name = str(player_id)
	p.player_name = player_name
	p.player_character_settings =player_character_settings
	p.team =team
	p.team_color=team_color
	p.position = spawn_position
	players[player_id] = p;
		
		#p.position = spawnpoint
		#p.load_from_character_chart(character_id)

	return p
func despawn_player(data):
	if players.has(data):
		var player = players[data]

		players[data].queue_free()
		players.erase(data)
		print("players data: ", players, "authority: ", multiplayer.get_unique_id())
	else:
		print("error ", data, " not in players{}")
