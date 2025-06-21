extends Node3D

signal character_created(player_name,player_character_settings)
signal back

@onready var camera =$Camera3D
@onready var model = $BaseBody
@onready var hair_select = $GUI/MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/VBoxContainer/Hair
@onready var eyebrows_select =$GUI/MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/VBoxContainer/Eyebrows
@onready var eyes_select =$GUI/MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/VBoxContainer/Eyes
@onready var mouth_select = $GUI/MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/VBoxContainer/Mouth
@onready var body_select =$GUI/MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/VBoxContainer/Body
@onready var accessory_select =$GUI/MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/VBoxContainer/Accessory
@onready var path = $Path3D/PathFollow3D
@onready var focus_point =$FocusPoint
@onready var cam_position_point =$Path3D/PathFollow3D/CameraPosition
@onready var name_entry =$GUI/MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/VBoxContainer/LineEdit

var sign = 1
var player_name = ""
var player_character_settings = []

func _process(delta: float) -> void:
	if path.progress_ratio >=0.99:
		sign = -1
	if path.progress_ratio < 0.01:
		sign = 1
	
	path.progress_ratio+=delta/10*sign
	camera.look_at(focus_point.position)
	camera.position = lerp(camera.position, cam_position_point.global_position,0.1)
	
func get_random_player_name() -> String:
	var names = ["ShadowWolf", "PixelKnight", "NeoRider", "LavaFang", "CyberNova", "IronGhost", "BlitzStorm", "SilentJanosh"]
	return names[randi() % names.size()]

func _ready() -> void:
	camera.current=true
	player_name = get_random_player_name()
	name_entry.placeholder_text=player_name
	model.set_player_name(player_name)
	hair_select.set_title("Hair")
	eyebrows_select.set_title("Eyebrows")
	eyes_select.set_title("Eyes")
	mouth_select.set_title("Mouth")
	accessory_select.set_title("Accesory")
	body_select.set_title("Body")
	eyebrows_select.set_id(model.get_eyebrow_id())
	eyes_select.set_id(model.get_eyes_id())
	mouth_select.set_id(model.get_mouth_id())
	body_select.set_id(model.get_body_id())
	body_select.next.connect(func()->void:
		model.next_body_texture()
		body_select.set_id(model.get_body_id())
		)
	body_select.prev.connect(func()->void:
		model.next_body_texture()
		body_select.set_id(model.get_body_id())
		)
	hair_select.next.connect(func()->void:
		model.next_hair()
	
		hair_select.set_id(	model.get_hair_id())
		)
	hair_select.prev.connect(func()->void:
		model.prev_hair()
		hair_select.set_id(	model.get_hair_id())
		)

	eyebrows_select.next.connect(func()->void:
		model.next_eyebrows_texture()
		eyebrows_select.set_id(model.get_eyebrow_id())
		)
	eyebrows_select.prev.connect(func()->void:
		model.prev_eyebrows_texture()
		eyebrows_select.set_id(model.get_eyebrow_id())
		)
	eyes_select.next.connect(func()->void:
		model.next_eye_texture()
		eyes_select.set_id(model.get_eyes_id())
		)
	eyes_select.prev.connect(func()->void:
		model.prev_eye_texture()
		eyes_select.set_id(model.get_eyes_id())
		)
	mouth_select.prev.connect(func()->void:
		model.prev_mouth_texture()
		mouth_select.set_id(model.get_mouth_id())
		)
	mouth_select.next.connect(func()->void:
		model.next_mouth_texture()
		mouth_select.set_id(model.get_mouth_id())
		)
	accessory_select.next.connect(func()->void:
		model.next_accessory()
		accessory_select.set_id(model.get_accesory_id())
		)
	accessory_select.prev.connect(func()->void:
		model.prev_accessory()
		accessory_select.set_id(model.get_accesory_id())
		)


func _on_randomize_pressed() -> void:
	model.randomize_character()
	eyebrows_select.set_id(model.get_eyebrow_id())
	hair_select.set_id(	model.get_hair_id())
	eyes_select.set_id(model.get_eyes_id())
	mouth_select.set_id(model.get_mouth_id())
	accessory_select.set_id(model.get_accesory_id())
	body_select.set_id(model.get_body_id())


func _on_join_pressed() -> void:
	if !name_entry.text == "":
		player_name = name_entry.text
		model.set_player_name(player_name)
	player_character_settings = model.export_params()
	character_created.emit(player_name,player_character_settings)
	pass # Replace with function body.


func _on_line_edit_text_changed(new_text: String) -> void:
	model.set_player_name(new_text)



func _on_back_pressed() -> void:
	back.emit()
