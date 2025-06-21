extends Node3D

var spawnzones:Array
var teams:Array
var team_spawnzone: Dictionary
@export var spawn_spread: Vector2
var item_spawnzone: Array

func _ready() -> void:
	for nd in $ItemSpawnZone.get_children():
		item_spawnzone.append(nd)
	
	for nd in $SpawnZones.get_children():
		spawnzones.append(nd.global_position)
	
	team_spawnzone = distribute_spawnzones(teams,spawnzones)



func get_spawn_location(team):
	if team_spawnzone.has(team):
		var spawn_position = team_spawnzone[team].pick_random()
		spawn_position.x+= randi_range(-spawn_spread.x,spawn_spread.x)
		spawn_position.z+= randi_range(-spawn_spread.y,spawn_spread.y)
		return spawn_position
	return Vector3.ZERO


func get_random_point() -> Vector3:
	if item_spawnzone.is_empty():
		return Vector3.ZERO
	
	var collision_shape = item_spawnzone.pick_random()
	
	if collision_shape == null:
		return Vector3.ZERO

	var shape = collision_shape.shape
	if typeof(shape) != TYPE_OBJECT or not shape is BoxShape3D:
		return Vector3.ZERO

	var extents = shape.extents
	var random_offset = Vector3(
		randf_range(-extents.x, extents.x),
		collision_shape.position.y,
		randf_range(-extents.z, extents.z)
	)

	return global_transform.origin + random_offset

func distribute_spawnzones(team_names: Array, spawnzones: Array) -> Dictionary:
	var result := {}
	var team_count := team_names.size()
	var spawn_count := spawnzones.size()

	spawnzones.shuffle()
	
	for team in team_names:
		result[team] = []

	for i in range(spawn_count):
		var team_index := i % team_count
		var team = team_names[team_index]
		result[team].append(spawnzones[i])
	
	return result
