extends MultiplayerSpawner

var map
@export var maps :Array[MapResource]

func _ready():
	#multiplayer.peer_disconnected.connect(despawn_map)
	spawn_function = spawn_player
	
func get_map_resource(id):
	return maps[id]
func spawn_player(data):
	print("PLAYER SPAWNER ", multiplayer.get_unique_id(), " spawning player: ", data)
	
	var map_id = data[0]

	var p =maps[map_id].scene.instantiate()
	p.rotation.y =maps[map_id].rotation
	
	p.teams = %TeamManager.team_names
	#print("P: ", p)

	map = p
		
		#p.position = spawnpoint
		#p.load_from_character_chart(character_id)

	return p
func despawn_map():
	if map !=null:
		map.queue_free()
		await get_tree().create_timer(0.1).timeout
		print("despawned map")
