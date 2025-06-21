extends Area3D
var time := 0.0
var grabbed := false
signal despawn(nm)
var amount = 20
@export var range :Vector2
@onready var shadowcast = $ShadowCast
@onready var shadow = $Shadow
@onready var gravcast = $GravCast

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
	if multiplayer.is_server():
		
		$CollisionShape3D.disabled=false
		amount = randi_range(range.x,range.y)

func _process(delta):
	if !gravcast.is_colliding():
		position.y-=delta*2
		if shadowcast.is_colliding():
			var coll_point = shadowcast.get_collision_point()
			coll_point.y+=0.15
			shadow.global_position=coll_point
	
	$MeshInstance3D.rotate_y(2 * delta)
	$MeshInstance3D.position.y += (cos(time * 5) * 2) * delta 
	time += delta


func _on_body_entered(body: Node3D) -> void:
	if multiplayer.is_server():
		if body.has_method("collect_health") and !grabbed:
			print("body entered ", body)
			
			body.collect_health.rpc(amount)
			
			despawn.emit(name)
			grabbed = true


func _on_timer_timeout() -> void:
	
	for i in range(0,10):
		await get_tree().create_timer(0.1).timeout
		if $MeshInstance3D.visible:
			$MeshInstance3D.visible=false
		else:
			$MeshInstance3D.visible=true
	if multiplayer.is_server():
		despawn.emit(name)
