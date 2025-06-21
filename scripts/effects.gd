extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.died.connect(enable_sepia)
	Global.revived.connect(disable_sepia)
func enable_sepia():
	$Sepia.show()
func disable_sepia():
	$Sepia.hide()
