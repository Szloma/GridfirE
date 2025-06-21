extends CharacterBody3D


var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false


func damage(amount):
	#Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()

# Destroy the enemy when out of health

func destroy():
	#Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
	queue_free()
