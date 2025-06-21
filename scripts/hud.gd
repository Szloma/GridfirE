extends CanvasLayer

@onready var health_bar = $MarginContainer/HBoxContainer/TextureProgressBar
@onready var ammo_counter = $MarginContainer/HBoxContainer/Ammo
@onready var time_to_respawn = $MarginContainer2/MarginContainer/VBoxContainer/TimeToRespawn
@onready var coin_amount =$MarginContainer3/CenterContainer/CoinLabel

var tween : Tween

func start_round_timer():
	$MarginContainer2/MarginContainer/VBoxContainer/TimeLeft.start()

func _ready() -> void:
	hide()
	Global.health_updated.connect(update_health_bar)
	Global.ammo_count_updated.connect(update_ammo_counter)
	Global.died.connect(dead_message)
	Global.revived.connect(revived)
	Global.start_revive_timer.connect(update_time_to_respawn)
	Global.coin_updated.connect(update_coin)
	Global.hud.connect(func(val)->void:
		if val==true:
			$MarginContainer.show()
			$MarginContainer3.show()
		else:
			$MarginContainer.hide()
			$MarginContainer3.hide()
		)

func revived():
	time_to_respawn.hide()


func update_coin(value):
	coin_amount.text = str(value)

func dead_message():
	time_to_respawn.show()
	$YouDied.show()
	await get_tree().create_timer(2.0).timeout
	$YouDied.hide()

func update_health_bar(value,max_value):
	print("updating hp bar ", value, " ", max_value , " on ", multiplayer.get_unique_id())
	#var tween = get_tree().create_tween()
	#tween.tween_property(health_bar, "value", value, 0.5)
	health_bar.value = value
	health_bar.max_value=max_value

func update_ammo_counter(value,max_value):
	var outstr=str(value)+"/"+str(max_value)
	ammo_counter.text=outstr

func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]


func update_time_to_respawn(tm: Timer):
	for i in range(0, tm.wait_time):
		time_to_respawn.text =format_time(tm.time_left)
		await get_tree().create_timer(1.0).timeout
