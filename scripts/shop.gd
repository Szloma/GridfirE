extends Control

@export var weapon_card: PackedScene
@onready var grid = $MarginContainer/MarginContainer/VBoxContainer/GridContainer

@export var hp_amount :=10
@export var ammo_amount :=10
@export var hp_price := 10
@export var ammo_price :=5

var coins = 0

func _ready() -> void:
	Global.shop.connect(display)

func populate_grid():
	var player = get_tree().get_first_node_in_group("players")
	if player !=null:
		var weapon_id = 0
		for weapon_data in player.weapons:
			var card = weapon_card.instantiate()
			card.setup(weapon_data, weapon_id )
			card.buy.connect(_on_buy_pressed)
			grid.add_child(card)
			weapon_id+=1


func display(value, coins):
	self.coins=coins
	if value == true:
		show()
		if grid.get_child_count()==0:
			populate_grid()
	else:
		hide()

func _on_buy_pressed(weapon_id, weapon_price):
	print("Buying weapon ", weapon_id, " for ", weapon_price, " coins: ", coins)
	if coins >= weapon_price:
		coins = coins -weapon_price
		Global.update_coin.emit(coins)
		Global.buy_weapon.emit(weapon_id)
		Audio.play("res://sounds/cash_register.mp3")
		print("new coins ", coins)
		#player.add_weapon(weapon) # Implement this method in the player
		print("Bought: ",weapon_id)
	else:
		print("Not enough money!")


func _on_back_pressed() -> void:
	Global.close_shop.emit()


func _on_hp_pressed() -> void:
	if coins >= hp_price:
		coins = coins -hp_price
		Global.update_coin.emit(coins)
		Global.buy_hp.emit(hp_amount)
func _on_ammo_pressed() -> void:
	if coins >= ammo_price:
		coins = coins -ammo_price
		Global.update_coin.emit(coins)
		Global.buy_ammo.emit(hp_amount)
