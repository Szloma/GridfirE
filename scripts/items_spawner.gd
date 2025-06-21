extends MultiplayerSpawner

@onready var spawn_interval = $SpawnInterval

var items = {}
@export var item_scenes :Array[PackedScene]
@export var item_limit := 10
@onready var map = %Map
func stop_spawning():
	if !spawn_interval.is_stopped():
		spawn_interval.stop()
func start_spawning():
	print("start spawning")
	spawn_interval.start()
		
func _ready():
	spawn_function = spawn_item
func spawn_item(data):
	print("spawning item")

	var item_id = data[0]
	var item_position = data[1]
	var item_name = data[2]
	var p=null
	if item_id >=0 and item_id < item_scenes.size():
		
		p =item_scenes[item_id].instantiate()
		if multiplayer.is_server():
			p.set_multiplayer_authority(multiplayer.get_unique_id())
		p.despawn.connect(despawn_item)
		p.name = str(item_name)
		items[item_name] = p;
		p.position =item_position

	return p
func despawn_item(data):
	if items.has(data):
		var item = items[data]

		items[data].queue_free()
		items.erase(data)
	else:
		print("error ", data, " not in items{}")

func despawn_all():
	for key in items.keys():
		
		var itm = items[key]
		if itm!=null:
			itm.despawn.disconnect(despawn_item)
			itm.queue_free()
			items.erase(key)

func _on_spawn_interval_timeout() -> void:
	if multiplayer.is_server():
		if items.size()<item_limit:
			
			var item_position = map.get_random_point()

			var spawn_arr = [
				randi_range(0,item_scenes.size()-1),
				item_position,
				str(randi())
			]
			spawn(spawn_arr)
