extends Label

@onready var round_timer = %RoundTimer

func start():
	for i in range(0, round_timer.wait_time):
		text =format_time(round_timer.time_left)
		await get_tree().create_timer(1.0).timeout
		
func stop():
	pass
	
func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]
