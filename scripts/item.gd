extends Area3D
var time := 0.0
var grabbed := false
signal despawn(nm)

@onready var amount_label = $SubViewport/Label
@onready var shadowcast = $ShadowCast
@onready var shadow = $Shadow
@onready var gravcast = $GravCast

var amount = 20

@export var range :Vector2

@rpc("any_peer", "call_local")
func propagate_amount(value):
	print("prog client ", multiplayer.get_unique_id())
	amount_label.text = str(value)+'x'

func _ready() -> void:
	visible=false
	$CollisionShape3D.disabled=true
	await get_tree().create_timer(0.1).timeout
	if shadowcast.is_colliding():
		var coll_point = shadowcast.get_collision_point()
		coll_point.y+=0.15
		shadow.global_position=coll_point
	else:
		shadow.hide()
	visible=true
	$Timer.start()
	if is_multiplayer_authority():
		$CollisionShape3D.disabled=false
		
		multiplayer.peer_connected.connect(_on_player_joined)
		print("peers ", multiplayer.get_peers())
		amount = randi_range(range.x,range.y)
		var peers = multiplayer.get_peers()
	
		propagate_amount.rpc(amount)

func _process(delta):
	if !gravcast.is_colliding():
		position.y-=delta*2
		if shadowcast.is_colliding():
			var coll_point = shadowcast.get_collision_point()
			coll_point.y+=0.15
			shadow.global_position=coll_point
	$MeshInstance3D2.rotate_y(2 * delta)
	$MeshInstance3D2.position.y += (cos(time * 5) * 2) * delta 
	
	time += delta


func _on_body_entered(body: Node3D) -> void:
	if multiplayer.is_server():
		if body.has_method("collect_ammo") and !grabbed:
			print("body entered ", body)
			body.collect_ammo.rpc(amount)
			
			
			#queue_free()
			despawn.emit(name)
			grabbed = true
func _on_player_joined(data):
	propagate_amount.rpc_id(data,amount)


func _on_timer_timeout() -> void:
	##animation goes here
	for i in range(0,10):
		await get_tree().create_timer(0.1).timeout
		if $MeshInstance3D2.visible:
			$MeshInstance3D2.visible=false
		else:
			$MeshInstance3D2.visible=true
	if multiplayer.is_server():
		despawn.emit(name)
	pass # Replace with function body.
