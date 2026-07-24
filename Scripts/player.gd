extends CharacterBody2D

var mob_inattack_range = false
var mob_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false

const SPEED = 100.0
var current_dir = "none"

var regen_rate = 2.0        
var regen_delay = 3.0      
var time_since_damage = 999.0

var footstep_interval = 0.35
var footstep_time_accum = 0.0
 
func _ready() -> void:
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta: float) -> void:
	player_movement(delta) 
	mob_attack()
	attack()
	current_camera()
	update_health_color()
	regen_health(delta)
	
	if health <= 0:
		respawn()

func respawn():
	health = 100
	player_alive = true
	time_since_damage = 999.0
	position.x = Global.player_start_posx
	position.y = Global.player_start_posy
	print("player respawned")

func regen_health(delta):
	time_since_damage += delta
	if time_since_damage >= regen_delay and health < max_health:
		health = min(health + regen_rate * delta, max_health)

func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -SPEED
		velocity.x = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = SPEED
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
		
	if velocity.x != 0 or velocity.y != 0:
		footstep_time_accum += delta
		if footstep_time_accum >= footstep_interval:
			footstep_time_accum = 0.0
			Global.play_footstep(global_position)
	else:
		footstep_time_accum = footstep_interval
 
	move_and_slide()	
	
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle") 
			
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("back_idle")
			
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("front_idle")

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("mob"):
		mob_inattack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("mob"):
		mob_inattack_range = false

func mob_attack():
	if mob_inattack_range and mob_attack_cooldown == true:
		health = health - 10
		mob_attack_cooldown = false
		time_since_damage = 0.0
		Global.play_hit(global_position)
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout() -> void:
	mob_attack_cooldown = true

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack"):
		Global.player_current_attack = true
		attack_ip = true
		$AnimatedSprite2D.speed_scale = 1
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("back_attack")
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attack_ip = false

func current_camera():
	if Global.current_scene == "world":
		$cliffside_camera.enabled = false
		$world_camera.enabled = true
		$world_camera.make_current()
	elif Global.current_scene == "cliff_side":
		$world_camera.enabled = false
		$cliffside_camera.enabled = true
		$cliffside_camera.make_current()

@export var low_health_threshold := 0.25  
var max_health = 100.0

func update_health_color():
	var hp_percent = float(health) / max_health
	var sprite = $AnimatedSprite2D
	if hp_percent <= low_health_threshold:
		var t = hp_percent / low_health_threshold  
		sprite.modulate = Color.WHITE.lerp(Color(1, 0.2, 0.2), 1.0 - t)
	else:
		sprite.modulate = Color.WHITE
	$HealthBar.value = health
