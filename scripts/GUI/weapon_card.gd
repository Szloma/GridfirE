extends Button

signal buy(id, price)

var weapon_price =1000

var id = 0

func setup(weapon_data,_id):
	id = _id
	print("spawning weapon price ", weapon_data.price)
	weapon_price=weapon_data.price
	$MarginContainer/VBoxContainer/MarginContainer/WeaponName.text = weapon_data.name
	$MarginContainer/VBoxContainer/MarginContainer2/WeaponPrice.text = str(weapon_data.price)
	$MarginContainer/VBoxContainer/WeaponIcon.texture= weapon_data.icon
	

func _on_pressed() -> void:
	buy.emit(id,weapon_price)
