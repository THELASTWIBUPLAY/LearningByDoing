extends CharacterBody2D

var speed = 20 
var player_chase = false
var player = null
var last_direction = "down"

var health = 100.0
var attack_power = 10          
var player_inattack_zone = false
var can_take_damage = true


func _physics_process(delta: float) -> void:
	deal_with_damage()
	
	if player_chase and player != null:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		
		if abs(direction.x) > abs(direction.y):
			last_direction = "side"
			$AnimatedSprite2D.play("walk_side")
			$AnimatedSprite2D.flip_h = direction.x < 0
		else:
			if direction.y < 0:
				last_direction = "up"
				$AnimatedSprite2D.play("walk_up")
			else:
				last_direction = "down"
				$AnimatedSprite2D.play("walk_down")
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if last_direction == "side":
			$AnimatedSprite2D.play("idle_side")
		elif last_direction == "up":
			$AnimatedSprite2D.play("idle_up")
		else:
			$AnimatedSprite2D.play("idle_down")

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func mob():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			var dmg = max(1, Global.player_atk)   
			health = health - dmg
			$take_damage_cooldown.start()
			can_take_damage = false
			$HealthBar.value = health
			print("slime health: ", health)
			if health <= 0:
				Global.play_slime_death(global_position)
				Global.register_slime_kill()   
				self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
