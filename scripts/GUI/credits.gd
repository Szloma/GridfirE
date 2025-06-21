extends Control
signal back

func _on_texture_button_pressed() -> void:
	back.emit()
