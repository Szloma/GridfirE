extends Node3D

func get_spawn_location(team):
	var map = get_child(0)
	if map!=null:
		return map.get_spawn_location(team)
	else:
		return Vector3.ZERO
func get_random_point():
	var map = get_child(0)
	if map!=null:
		var point = map.get_random_point()
		return point 
	else:
		return Vector3.ZERO
