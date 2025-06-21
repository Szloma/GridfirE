extends Button

var map_data: MapResource

@onready var image = %MapPreview
@onready var label =$MarginContainer2/VBoxContainer/MarginContainer/MapName

signal voted(id)

var preview_image : Texture
var label_text : String
var map_id:=-1

func _ready() -> void:
	image.texture = preview_image
	label.text = label_text

func setup(data: MapResource, map_id):
	self.map_id = map_id
	map_data = data
	preview_image = data.preview_image
	label_text = data.name


func _on_pressed() -> void:
	voted.emit(map_id)
	pass # Replace with function body.
