extends Control
signal back

@onready var music_vol_slider = $MarginContainer/MarginContainer/VBoxContainer/MusicVolSlider
@onready var sfx_vol_slider = $MarginContainer/MarginContainer/VBoxContainer/SFXVolSlider

func _ready() -> void:
	if OS.has_feature("web"):
		var music_vol = LocalStorage.get_item("music_volume")
		Audio.set_music_volume(music_vol)
		music_vol_slider.value = music_vol
		
		var sfx_vol = LocalStorage.get_item("sfx_volume")
		Audio.set_sfx_volume(sfx_vol)
		sfx_vol_slider.value = sfx_vol

func _on_back_pressed() -> void:

	back.emit()
	

func _on_music_vol_slider_drag_ended(value_changed: bool) -> void:
	#var new_value =linear_to_db(music_vol_slider.value)
	Audio.set_music_volume(music_vol_slider.value)
	if OS.has_feature("web"):
		LocalStorage.set_item("music_volume", music_vol_slider.value)


func _on_sfx_vol_slider_drag_ended(value_changed: bool) -> void:
	Audio.set_sfx_volume(sfx_vol_slider.value)
	Audio.play("res://sounds/laser.mp3")
	if OS.has_feature("web"):
		LocalStorage.set_item("sfx_volume", sfx_vol_slider.value)
