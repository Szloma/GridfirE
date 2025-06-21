extends Area3D

func _ready() -> void:
	body_entered.connect(shop_on)
	body_exited.connect(shop_off)
	

func shop_on(body):
	if body.has_method("enable_shop"):
		body.enable_shop()

	
func shop_off(body):
	if body.has_method("disable_shop"):
		body.disable_shop()
