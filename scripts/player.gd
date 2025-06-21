extends CharacterBody3D

signal coin_collected
signal health_updated(val)
@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var max_health:int = 20
var health:int = max_health
var ammo = 0
var max_ammo = 100

var coins = 5

@export var hit_sound_effects : Array[String]
@onready var particles_trail = $ParticleTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model =$CharacterSkin/BaseBody
@onready var animation = $CharacterSkin/AnimationPlayer
@onready var ghost = $CharacterSkin/ghost
@onready var camera = $Camera3D
@onready var skin = $CharacterSkin
@onready var crosshair = get_tree().get_first_node_in_group("crosshair")
@onready var leaderboard  = get_tree().get_first_node_in_group("leaderboard")
@onready var weapon_container =  $CharacterSkin/WeaponContainer
@onready var weapon_cooldown = $Cooldown
@onready var muzzle_flash =$CharacterSkin/MuzzleFlash
@onready var aimcast = $Aimcast
@export var weapons: Array[WeaponResource] = []
var owned_weapons: Array[WeaponResource] = []
@export var revive_time :=10
@onready var right_hand = $CharacterSkin/BaseBody/Body/handleft
@onready var shadowcast = $ShadowCast
@onready var shadow = $Shadow
var weapon
var weapon_index =0
var tween:Tween
var container_offset = Vector3(-0.5, 1, 0)

var team := "red"
var player_name := "-"
var player_character_settings := []
var team_color := Color.WHITE

var input_enabled = true
var shop = false
var shop_enabled = false
var dead = false


func disable_input():
	Input.mouse_mode =Input.MOUSE_MODE_VISIBLE
	if crosshair!=null:
		crosshair.hide()
	input_enabled=false
func enable_input():
	Input.mouse_mode =Input.MOUSE_MODE_CONFINED_HIDDEN
	input_enabled=true
	if crosshair!=null:
		crosshair.show()

#when shuffling teams
@rpc("any_peer","call_local")
func set_player_name_color(color):
	team_color = color
	model.set_player_name_color(team_color)
	pass
@rpc("any_peer","call_local")
func set_team(tm):
	team = tm

func _ready() -> void:
	print("spawned player ", name, " name ", player_name, " settings ", player_character_settings)
	model.set_player_name(player_name)
	if !player_character_settings.is_empty():
		model.import_params(player_character_settings)
	model.set_player_name_color(team_color)
	await get_tree().create_timer(0.1).timeout
	initiate_change_weapon.rpc(weapon_index)
	
	if not is_inside_tree() or not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		return
	
	camera.current = is_multiplayer_authority()
	if is_multiplayer_authority():
		if !weapons.is_empty():
			owned_weapons.append(0)
		#container_offset = $CharacterSkin/WeaponContainer.position
		Input.mouse_mode =Input.MOUSE_MODE_CONFINED_HIDDEN
		weapon = weapons[weapon_index] # Weapon must never be nil
		multiplayer.peer_connected.connect(_on_player_joined)
		Global.update_coin.connect(update_coins)
		Global.buy_weapon.connect(action_weapon_buy)
		Global.buy_hp.connect(collect_health)
		Global.buy_ammo.connect(collect_ammo)
		Global.close_shop.connect(close_shop)
		Global.health_updated.emit(health,max_health)
		Global.coin_updated.emit(coins)

func close_shop():
	shop= false
	enable_input()
	Global.shop.emit(shop, coins)

@rpc("any_peer","call_local")
func initiate_change_weapon(index):
	
	weapon_index = index
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	#tween.tween_property(weapon_container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon) 
	

func change_weapon():
	
	weapon = weapons[weapon_index]
	
	for n in weapon_container.get_children():
		weapon_container.remove_child(n)

	var weapon_model = weapon.model.instantiate()
	ammo=weapon.shot_count
	max_ammo=weapon.shot_count
	weapon_container.add_child(weapon_model)
	Global.ammo_count_updated.emit(ammo,max_ammo)
	print("adding weapon ", weapon_model)
	Audio.play("res://sounds/change-weapon.mp3")


func look_at_target(object, target_position: Vector3):
	var origin = object.global_transform.origin
	var flat_target = Vector3(target_position.x, origin.y, target_position.z)
	var direction = (flat_target - origin).normalized()
	var angle = atan2(direction.x, direction.z)
	object.global_transform.basis = Basis(Vector3.UP, -angle)

func look_at_cursor():
	var mouse_pos = get_viewport().get_mouse_position()
	#annoying
	if crosshair!=null:
		var crosshair_offset = Vector2(crosshair.texture.get_width()/2*crosshair.scale.x,crosshair.texture.get_height()/2*crosshair.scale.y)
	#/annoying
		crosshair.position = mouse_pos-crosshair_offset
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state

	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to

	var result = space_state.intersect_ray(ray_params)
	var look_at_point = result.position if result else to
	$Pointer.global_position =lerp($Pointer.global_position,look_at_point,0.2)
	var skin_rotation_backup = skin.rotation
	skin.look_at($Pointer.global_position)
	
	#
	aimcast.look_at($Pointer.global_position)
	
	skin.rotation.x=skin_rotation_backup.x
	skin.rotation.z = skin_rotation_backup.z

func handle_shadow():
	if shadowcast.is_colliding():

		var shadow_location = shadowcast.get_collision_point()
		shadow_location.y+=0.2
		shadow.global_position= shadow_location


func _physics_process(delta):
	##make sure there's a multiplayer peer or else it throws an error when despawning
	if !multiplayer.has_multiplayer_peer():
		return
	handle_shadow()
	handle_effects(delta)
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("escape"):
			if shop:
				shop= false
				enable_input()
				Global.shop.emit(shop, coins)
			else:
				if input_enabled:
					disable_input()
					Global.shop.emit(false, coins)
					Global.ingame_menu.emit(input_enabled)
				else:
					enable_input()
					Global.shop.emit(false, coins)
					Global.ingame_menu.emit(input_enabled)
		if Input.is_action_just_pressed("shop") and not dead and shop_enabled:
			if !shop:
				shop=true
				disable_input()
				Global.shop.emit(shop, coins)
			else:
				shop= false
				enable_input()
				Global.shop.emit(shop, coins)
	if is_multiplayer_authority() and input_enabled:

		look_at_cursor()
		handle_controls(delta)
		handle_gravity(delta)

		#handle_effects(delta)
		# Movement

		var applied_velocity: Vector3

		applied_velocity = velocity.lerp(movement_velocity, delta * 10)
		applied_velocity.y = -gravity
		#		weapon_container.position = lerp(weapon_container.position, container_offset - (basis.inverse() * applied_velocity / 30), delta * 10)
		
		weapon_container.position = lerp(weapon_container.position, container_offset - (weapon_container.basis.inverse() * applied_velocity / 30), delta * 10)

		right_hand.position = -weapon_container.position
		right_hand.position.y = 0.55
		camera.position = lerp(camera.position,$CameraTarget.position - (basis.inverse() * applied_velocity / 30), delta * 10)

		velocity = applied_velocity
		move_and_slide()

		# Rotation

		if Vector2(velocity.z, velocity.x).length() > 0:
			rotation_direction = Vector2(velocity.z, velocity.x).angle()
		

		#$CharacterSkin.rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

		# Falling/respawning

		if position.y < -10:
			position =find_respawn_point()
			damage(health*0.25, null)
			

		# Animation for scale (jumping and landing)

		model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

		# Animation when landing

		if is_on_floor() and gravity > 2 and !previously_floored:
			model.scale = Vector3(1.25, 0.75, 1.25)
			Audio.play("res://sounds/land.mp3")

		previously_floored = is_on_floor()

func find_respawn_point():
	var map = get_tree().get_first_node_in_group("map")
	if map ==null:
		return Vector3.ZERO
	else:
		var rsp =  map.get_spawn_location(team)
		return rsp 

func action_weapon_buy(val):
	print("Setting new weapon: ",val)
	weapon_index=val
	initiate_change_weapon.rpc(weapon_index)

func action_weapon_toggle():
	
	if Input.is_action_just_pressed("toggle_weapon") and not dead:
		
		weapon_index = wrap(weapon_index + 1, 0, weapons.size())
		initiate_change_weapon.rpc(weapon_index)
		
		#Audio.play("sounds/weapon_change.ogg")

@rpc("any_peer","call_local")
func spawn_impact(pos:Vector3):
	var impact = preload("res://scenes/impact.tscn")
	var impact_instance = impact.instantiate()
	impact_instance.play("default")
	get_tree().root.add_child(impact_instance)
	
	impact_instance.position =pos
	
@rpc("any_peer","call_local")
func play_muzzle_flash():
	muzzle_flash.play("default")
		
	muzzle_flash.rotation_degrees.z = randf_range(-45, 45)
	muzzle_flash.scale = Vector3.ONE * randf_range(0.10, 0.35)
	pass

func action_shoot():
	
	if Input.is_action_pressed("shoot") and not dead:
	
		if !weapon_cooldown.is_stopped(): return # Cooldown for shooting
		if ammo <=0:
			return
		
		Audio.play(weapon.sound_shoot)
		
		weapon_container.position.z += 0.25
		#camera.rotation.x += 0.025 
		movement_velocity += Vector3(0, 0, weapon.knockback) 
		
		play_muzzle_flash.rpc()
		#muzzle_flash.position = container.position - weapon.muzzle_position
		
		weapon_cooldown.start(weapon.cooldown)

		

		
		ammo-=1
		Global.ammo_count_updated.emit(ammo,max_ammo)
		aimcast.target_position.x = randf_range(-weapon.spread, weapon.spread)
		aimcast.target_position.y = randf_range(-weapon.spread, weapon.spread)
		var collider = aimcast.get_collider()
		print("aimcast rotation ", aimcast.rotation)
		if collider!=null:
			var impact_instance_position =  aimcast.get_collision_point() + (aimcast.get_collision_normal() / 10)
			print("impact instance pos ", impact_instance_position)
			spawn_impact.rpc(impact_instance_position)
			
			if collider.has_method("damage"):
				collider.damage.rpc(weapon.damage, team)
				Audio.play(hit_sound_effects.pick_random())
	
			#raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
			#raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)
			#
			#raycast.force_raycast_update()
			#
			#if !raycast.is_colliding(): continue # Don't create impact when raycast didn't hit
			#
			#var collider = raycast.get_collider()
			#
			# Hitting an enemy

			#if collider.has_method("damage"):
				#collider.damage(weapon.damage)
			
			# Creating an impact animation
			
			#var impact = preload("res://objects/impact.tscn")
			#var impact_instance = impact.instantiate()
			#
			#impact_instance.play("shot")
			#
			#get_tree().root.add_child(impact_instance)
			#
			#impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
			#impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true) 
			


func handle_effects(delta):

	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor() and not dead:
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.05:
			#if animation.current_animation != "walk":
				#animation.play("walk", 0.1)

			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true

		#elif animation.current_animation != "idle":
			#animation.play("idle", 0.1)
	#elif animation.current_animation != "jump":
		#animation.play("jump", 0.1)

# Handle movement input

func handle_controls(delta):
	#action_weapon_toggle()
	action_shoot()
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode== Input.MOUSE_MODE_CONFINED_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode =Input.MOUSE_MODE_CONFINED_HIDDEN
		#mouse_captured = false
		
		#input_mouse = Vector2.ZERO
	

	# Movement

	var input := Vector3.ZERO

	input.x = Input.get_axis("left", "right")
	input.z = Input.get_axis("down", "up")

	#input = input.rotated(Vector3.UP, view.rotation.y)

	if input.length() > 1:
		input = input.normalized()

	movement_velocity = input * movement_speed * delta

	# Jumping

	if Input.is_action_just_pressed("jump"):

		if jump_single or jump_double:
			jump()
	
# Handle gravity

func handle_gravity(delta):

	gravity += 25 * delta

	if gravity > 0 and is_on_floor():

		jump_single = true
		gravity = 0

# Jumping

func jump():

	Audio.play("res://sounds/jump.mp3")

	gravity = -jump_strength

	model.scale = Vector3(0.5, 1.5, 0.5)

	if jump_single:
		jump_single = false;
		jump_double = true;
	else:
		jump_double = false;

@rpc("any_peer","call_local")
func collect_ammo(amount):
	if dead:
		return
	Audio.play("res://sounds/reload.mp3") 
	ammo+=amount
	if ammo >= max_ammo:
		ammo=max_ammo
	Global.ammo_count_updated.emit(ammo,max_ammo)
@rpc("any_peer","call_local")
func collect_health(amount):
	if dead:
		return
	if is_multiplayer_authority():
		Audio.play("res://sounds/health-refill1.mp3") 
		print()
		health+=amount
		if health >=max_health:
			health = max_health
		print("player ", name,  " health ", health)
		Global.health_updated.emit(health,max_health)
@rpc("any_peer","call_local")
func collect_coin():
	coins += 1
	Global.coin_updated.emit(coins)

func update_coins(value):
	coins = value
	print("new coins in player ", value)
	Global.coin_updated.emit(coins)
@rpc("any_peer", "call_local")	
func damage(amount, p_team):
	if is_multiplayer_authority():
		if p_team ==null:
			health-=amount
			Global.health_updated.emit(health,max_health)
			return
		if dead:
			return
		if team==p_team:
			return
			
		health -= amount
		
		if health < 0:
			health = -1
			die()
			var killed_by = multiplayer.get_remote_sender_id()
			collect_coin.rpc_id(killed_by)
			leaderboard.add_score.rpc_id(Global.host_id, 1, killed_by)
			print("dead ", name, " killed  by ", multiplayer.get_remote_sender_id())
		Global.health_updated.emit(health,max_health)


@rpc("any_peer","call_local")
func turn_ghost():
	model.hide()
	ghost.show()
	weapon_container.hide()
	collision_layer &= ~(0 << 0)
	collision_mask &= ~(0 << 0)
@rpc("any_peer","call_local")
func turn_alive():
	ghost.hide()
	model.show()
	weapon_container.show()
	dead=false
	collision_layer |= (0 << 0)
	collision_mask |= (0 << 0)
func die():
	Global.died.emit()
	dead=true
	turn_ghost.rpc()
	$ReviveTimer.start(revive_time)
	Global.start_revive_timer.emit($ReviveTimer)
func revive():

	dead=false
	print("revived ", multiplayer.get_unique_id(), " ", dead)
	health = max_health*0.7
	ammo = max_ammo*0.7
	Global.revived.emit()
	Global.ammo_count_updated.emit(ammo,max_ammo)
	Global.health_updated.emit(health,max_health)
	turn_alive.rpc()
func _on_revive_timer_timeout() -> void:
	revive()

func _on_player_joined(player_id):
	if dead:
		turn_ghost.rpc_id(player_id)

@rpc("any_peer")
func reset():
	if !$ReviveTimer.is_stopped():
		$ReviveTimer.stop
	Global.revived.emit()
	previously_floored = false
	health=max_health
	ammo=max_ammo
	dead=false
	position =find_respawn_point()
	

func enable_shop():
	shop_enabled=true
func disable_shop():
	close_shop()
	shop_enabled=false
