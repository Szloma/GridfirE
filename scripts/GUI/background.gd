extends TextureRect

@export var textures: Array[Texture2D]
@export var scroll_speed: Vector2 = Vector2(50, 0) # pixels per second

var uv_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		set_process(false)
	else:
		pick_random_texture()
func pick_random_texture():
	var text = textures.pick_random()
	texture= text	


func _process(delta: float) -> void:
	
	uv_offset += scroll_speed * delta
	material.set_shader_parameter("uv_offset", uv_offset)
	#material.uv_offset,uv_offset
