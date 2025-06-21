extends MarginContainer
signal prev
signal next

func set_id(id):
	var fid =""
	if id==-1:
		fid+="None"
	elif id >=0 and id <=9:
		id+=1
		fid += "0"
		fid+= str(id)
	else:
		id+=1
		fid+=str(id)
	$VBoxContainer/HBoxContainer/ID.text = fid

func set_title(title):
	$VBoxContainer/Title.text = title




func _on_prev_pressed() -> void:
	prev.emit()


func _on_next_pressed() -> void:
	next.emit()
