extends Control

@onready var options = $"../Options"

func _ready() -> void:
	Global.ingame_menu.connect(_on_called)


func _on_called(val):
	if val:
		hide()
		options.hide()
	else:
		show()


func _on_options_pressed() -> void:
	options.show()
	hide()
	await options.back
	options.hide()
	show()


func _on_back_pressed() -> void:
	for i in get_tree().get_nodes_in_group("players"):
		i.enable_input()
	hide()


func _on_disconnect_pressed() -> void:
	if !multiplayer.is_server():
		Global.disconnect.emit()
	else:
		Global.close_server.emit()
	hide()
	options.hide()
