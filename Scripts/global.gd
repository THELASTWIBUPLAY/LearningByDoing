extends Node

var player_current_attack = false

var current_scene = "world"
var transition_scene = false

var player_exit_cliffside_posx = 983
var player_exit_cliffside_posy = 10
var player_start_posx = 983
var player_start_posy = 130

var can_transition = true

var game_first_loading = true

@onready var ambient1 = $AmbientPlayer1
@onready var ambient2 = $AmbientPlayer2
@onready var random_ambient = $RandomAmbientPlayer
@onready var ambient_timer = $AmbientTimer
@onready var wind_player = $WindPlayer

var bird_sound_1 = preload("res://Audio/Surrounding/SE_Bird_01.ogg")  # sering
var bird_sound_2 = preload("res://Audio/Surrounding/SE_Bird_02.ogg")  # sering
var bird_sound_3 = preload("res://Audio/Surrounding/SE_Bird_03.ogg")  # jarang
var bird_sound_4 = preload("res://Audio/Surrounding/SE_Bird_04.ogg")  # jarang

var bird_pool = [
	{"sound": bird_sound_3, "weight": 3},
	{"sound": bird_sound_4, "weight": 3},
]

var random_chance = 0.4

var wind_sounds = [
	preload("res://Audio/Wind/SE_Wind_02.ogg"),
	preload("res://Audio/Wind/SE_Wind_04.ogg"),
]
 
var footstep_sounds = [
	preload("res://Audio/Walk/SE_FootStep_03a.ogg"),
	preload("res://Audio/Walk/SE_FootStep_03b.ogg"),
	preload("res://Audio/Walk/SE_FootStep_03c.ogg"),
	preload("res://Audio/Walk/SE_FootStep_03d.ogg"),
]
 
var hit_sounds = [
	preload("res://Audio/Hit/SE_Hit_01.ogg"),
	preload("res://Audio/Hit/SE_Hit_02.ogg"),
]
 
var slime_death_sound = preload("res://Audio/Slime_Death/SE_PanPan.ogg")
 
const SFX_POOL_SIZE = 8
var sfx_pool: Array = []

func finish_changescenes():
	if transition_scene == true:
		transition_scene = false
		can_transition = false
		if current_scene == "world":
			current_scene = "cliff_side"
		else:
			current_scene = "world"
		get_tree().create_timer(0.5).timeout.connect(func(): can_transition = true)
			
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_scene = "world"
	
	ambient1.stream = bird_sound_1
	ambient1.play()

	ambient2.stream = bird_sound_2
	ambient2.play()

	ambient_timer.wait_time = 6.0
	ambient_timer.timeout.connect(_on_ambient_timer_timeout)
	ambient_timer.start()
	
	wind_player.stream = wind_sounds[randi() % wind_sounds.size()]
	wind_player.play()
	wind_player.finished.connect(_on_wind_player_finished)
 
	for i in SFX_POOL_SIZE:
		var p = AudioStreamPlayer2D.new()
		add_child(p)
		sfx_pool.append(p)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_wind_player_finished() -> void:
	wind_player.stream = wind_sounds[randi() % wind_sounds.size()]
	wind_player.play()

func play_sfx(stream: AudioStream, pos: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	for p in sfx_pool:
		if not p.playing:
			p.stream = stream
			p.global_position = pos
			p.volume_db = volume_db
			p.play()
			return
	sfx_pool[0].stream = stream
	sfx_pool[0].global_position = pos
	sfx_pool[0].volume_db = volume_db
	sfx_pool[0].play()
 
func play_footstep(pos: Vector2 = Vector2.ZERO) -> void:
	play_sfx(footstep_sounds[randi() % footstep_sounds.size()], pos, -6.0)
 
func play_hit(pos: Vector2 = Vector2.ZERO) -> void:
	play_sfx(hit_sounds[randi() % hit_sounds.size()], pos)
 
func play_slime_death(pos: Vector2 = Vector2.ZERO) -> void:
	play_sfx(slime_death_sound, pos)
	
func _on_ambient_timer_timeout() -> void:
	if randf() < random_chance:
		play_random_bird()

	ambient_timer.wait_time = randf_range(4.0, 10.0)
	
func play_random_bird():
	var total_weight = 0
	for item in bird_pool:
		total_weight += item.weight

	var roll = randi() % total_weight
	var cumulative = 0
	for item in bird_pool:
		cumulative += item.weight
		if roll < cumulative:
			random_ambient.stream = item.sound
			random_ambient.play()
			return
