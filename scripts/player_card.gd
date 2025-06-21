extends MarginContainer

func setup(nm:String, score:int, team:String):
	$VBoxContainer/HBoxContainer/Name.text = nm
	$VBoxContainer/HBoxContainer/Score.text = str(score)
	$VBoxContainer/HBoxContainer/Team.text = team
