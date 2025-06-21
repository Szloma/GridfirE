extends Node

@export var menu_music :Array[String]
var in_menu =true
var in_game = false

func _ready() -> void:
	Audio.track_ended.connect(_on_track_ended)
	start_menu_music()

func _on_track_ended():

	if in_menu:
		Audio.play_music(menu_music.pick_random())

func start_menu_music():
	Audio.play_music(menu_music.pick_random())
func stop_menu_music():
	in_menu=false
	in_game=true
	Audio.stop_music()
