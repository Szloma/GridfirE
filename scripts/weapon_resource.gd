extends Resource
class_name WeaponResource

@export var model: PackedScene 
@export var muzzle_position: Vector3 
@export var name:="Blank"

@export_range(0.1, 1) var cooldown: float = 0.1
@export_range(1, 20) var max_distance: int = 10 
@export_range(0, 100) var damage: float = 25  
@export_range(0, 5) var spread: float = 0 
@export_range(1, 500) var shot_count: int = 1  
@export_range(0, 50) var knockback: int = 20  
@export var price: int = 10
@export var icon : Texture


@export var sound_shoot: String 
