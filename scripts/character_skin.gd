extends Node3D

@export var eye_textures : Array[Texture2D]
var eye_texture_id =0

@export var mouth_textures : Array[Texture2D]
var mouth_texture_id =0

@export var eyebrows_textures : Array[Texture2D]
var eyebrows_texture_id =0

@export var accesory_scenes : Array[Mesh]
var accesory_id =-1

@export var hair_scenes : Array[Mesh]
var hair_id =-1

@export var body_textures : Array[Texture2D]

@export var hair_textures : Array[Texture2D]
var body_texture_id =0
@export var accessory_textures : Array[Texture2D]

var eye_material
var mouth_material
var body_material
var eyebrows_material
@onready var accessory = $Accessory
@onready var hair = $Hair
@onready var name_label = $SubViewport/Label

func set_texture_to_object(object, texture):

	var mat := StandardMaterial3D.new()

	mat.albedo_texture = texture

	object.material_override = mat

func _ready():
	eye_material = $Body/Eyes.get_surface_override_material(0)
	mouth_material = $Body/Mouth.get_surface_override_material(0)
	eyebrows_material = $Body/Eyebrows.get_surface_override_material(0)
	body_material = $Body/Body.get_surface_override_material(0)
	print("loading body settings: ", export_params(), " player ", multiplayer.get_unique_id())

func set_player_name(nm,preview_mode=false):
	name_label.text=nm
	
	if preview_mode:
		name_label.add_theme_font_size_override("font_size",20)

func set_player_name_color(color:Color):
	name_label.set("theme_override_colors/font_color",color)


func refresh():
	if accesory_id == accesory_scenes.size():
		accessory.set_mesh(null)
	else:
		accessory.set_mesh(accesory_scenes[accesory_id])
		set_texture_to_object($Accessory, accessory_textures[accesory_id])
	if hair_id == hair_scenes.size():
		hair.set_mesh(null)
	else:
		hair.set_mesh(hair_scenes[hair_id])
		set_texture_to_object($Hair, hair_textures[hair_id])
	mouth_material.albedo_texture = mouth_textures[mouth_texture_id]
	eye_material.albedo_texture = eye_textures[eye_texture_id]
	eyebrows_material.albedo_texture =  eyebrows_textures[eyebrows_texture_id]
	body_material.albedo_texture = body_textures[body_texture_id]



func get_body_id():
	if body_texture_id == body_textures.size():
		return -1
	return body_texture_id
func get_hair_id():
	if hair_id == hair_scenes.size():
		return -1
	return hair_id
func get_eyebrow_id():
	if eyebrows_texture_id == eyebrows_textures.size():
		return -1
	return eyebrows_texture_id
func get_mouth_id():
	if mouth_texture_id == mouth_textures.size():
		return -1
	return mouth_texture_id
func get_eyes_id():
	if eye_texture_id == eye_textures.size():
		return -1
	return eye_texture_id
func get_accesory_id():
	if accesory_id== accesory_scenes.size():
		return -1
	return accesory_id

func next_body_texture():
	body_texture_id+=1
	if body_texture_id > body_textures.size()-1:
		body_texture_id=0

	body_material.albedo_texture = body_textures[body_texture_id]
func prev_body_texture():
	body_texture_id-=1
	if body_texture_id < 0:
		body_texture_id = body_textures.size()-1
	body_material.albedo_texture = body_textures[body_texture_id]


func next_hair():
	hair_id+=1
	if hair_id > hair_scenes.size():
		hair_id=0
	
	if hair_id == hair_scenes.size():
		hair.set_mesh(null)
	else:
		hair.set_mesh(hair_scenes[hair_id])
	
	
func prev_hair():
	hair_id-=1
	if hair_id < 0:
		hair_id = hair_scenes.size()
	
	if hair_id == hair_scenes.size():
		hair.set_mesh(null)
	else:
		hair.set_mesh(hair_scenes[hair_id])


func next_accessory():
	accesory_id+=1
	if accesory_id > accesory_scenes.size():
		accesory_id=0
	
	if accesory_id == accesory_scenes.size():
		accessory.set_mesh(null)
	else:
		accessory.set_mesh(accesory_scenes[accesory_id])

func prev_accessory():
	accesory_id-=1
	if accesory_id < 0:
		accesory_id = accesory_scenes.size()
	
	if accesory_id == accesory_scenes.size():
		accessory.set_mesh(null)
	else:
		accessory.set_mesh(accesory_scenes[accesory_id])

func next_eye_texture():
	eye_texture_id+=1
	if eye_texture_id > eye_textures.size()-1:
		eye_texture_id=0
	eye_material.albedo_texture = eye_textures[eye_texture_id]
func prev_eye_texture():
	eye_texture_id-=1
	if eye_texture_id < 0:
		eye_texture_id = eye_textures.size()-1
	eye_material.albedo_texture = eye_textures[eye_texture_id]

func next_mouth_texture():
	mouth_texture_id+=1
	if mouth_texture_id > mouth_textures.size()-1:
		mouth_texture_id=0
	mouth_material.albedo_texture = mouth_textures[mouth_texture_id]
func prev_mouth_texture():
	mouth_texture_id-=1
	if mouth_texture_id < 0:
		mouth_texture_id = mouth_textures.size()-1
	mouth_material.albedo_texture =  mouth_textures[mouth_texture_id]



func next_eyebrows_texture():
	eyebrows_texture_id+=1
	if eyebrows_texture_id > eyebrows_textures.size()-1:
		eyebrows_texture_id=0
	eyebrows_material.albedo_texture = eyebrows_textures[eyebrows_texture_id]
func prev_eyebrows_texture():
	eyebrows_texture_id-=1
	if eyebrows_texture_id < 0:
		eyebrows_texture_id= eyebrows_textures.size()-1
	eyebrows_material.albedo_texture =  eyebrows_textures[eyebrows_texture_id]

func randomize_character():
	eyebrows_texture_id = randi_range(0,eyebrows_textures.size()-1)
	mouth_texture_id =  randi_range(0,mouth_textures.size()-1)
	eye_texture_id =  randi_range(0,eye_textures.size()-1)
	hair_id = randi_range(0,hair_scenes.size())
	accesory_id=randi_range(0,accesory_scenes.size())
	body_texture_id=randi_range(0,body_textures.size()-1)
	refresh()
func export_params():
	return [
		hair_id,
		eyebrows_texture_id,
		eye_texture_id,
		mouth_texture_id,
		accesory_id,
		body_texture_id
	]
	
func import_params(prms):
	hair_id = prms[0]
	eyebrows_texture_id=prms[1]
	eye_texture_id=prms[2]
	mouth_texture_id=prms[3]
	accesory_id=prms[4]
	body_texture_id=prms[5]
	refresh()

func reset():
	accesory_id =-1
	hair_id = -1
	eyebrows_texture_id =0
	mouth_texture_id =  0
	eye_texture_id = 0
	hair_id =0
