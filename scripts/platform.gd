extends Node3D

var tween
var dropped = false
@export var drop_delay:=1
@export var respawn_time:=5
@export var default_y = -7
var starting_position
func _ready() -> void:
	starting_position=global_position
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(_on_player_joined)
	pass # Replace with function body.

@rpc("any_peer")
func propagate_dropped(time):
	$DropTimer.start(time)
	var destination = global_position
	destination.y= default_y
	global_position= destination
	dropped = true

func _on_player_joined(id):
	print("propagating dropped for ", id)
	propagate_dropped.rpc_id(id,$DropTimer.time_left)
	

func _on_drop_timer_timeout() -> void:
	
	tween = get_tree().create_tween()
	var destination 
	if dropped:
		destination =starting_position
		dropped = false
	else:
		destination= global_position
		destination.y=default_y
		dropped = true
		$DropTimer.start(respawn_time)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "global_position", destination, 0.5)

func _on_player_detector_body_entered(body: Node3D) -> void:
	if !body.is_in_group("players"):
		return
	print("drop body entered")
	if !dropped:
		$DropTimer.start(drop_delay)
