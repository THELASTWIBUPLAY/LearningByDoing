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

var bird_sound_1 = preload("res://Audio/Surrounding/SE_Bird_01.ogg")  
var bird_sound_2 = preload("res://Audio/Surrounding/SE_Bird_02.ogg")  
var bird_sound_3 = preload("res://Audio/Surrounding/SE_Bird_03.ogg")  
var bird_sound_4 = preload("res://Audio/Surrounding/SE_Bird_04.ogg")  

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



# PLAYER LEVEL / EXP / STATS


signal player_stats_changed
signal player_leveled_up(new_level: int)

var player_level = 1
var player_exp = 0.0
var player_exp_to_next = 100.0        

var player_max_health = 100.0
var player_current_health = 100.0
var player_atk = 10
var player_def = 0

var slimes_killed = 0
var exp_per_kill = 25.0                

func add_player_exp(amount: float) -> void:
	player_exp += amount

	while player_exp >= player_exp_to_next:
		player_exp -= player_exp_to_next
		level_up_player()
	emit_signal("player_stats_changed")
	refresh_hud()

func level_up_player() -> void:
	player_level += 1
	player_exp_to_next = player_level * 100.0  

	player_max_health += 20.0
	player_atk += 3
	player_def += 1

	player_current_health = player_max_health

	emit_signal("player_leveled_up", player_level)
	emit_signal("player_stats_changed")

func register_slime_kill() -> void:
	slimes_killed += 1
	add_player_exp(exp_per_kill)

func set_player_health(current: float, max_value: float) -> void:
	player_current_health = current
	player_max_health = max_value
	refresh_hud()

# HUD (dibuat lewat code, jadi TIDAK perlu edit .tscn sama sekali)

var hud_layer: CanvasLayer
var hud_level_label: Label
var hud_exp_bar: ProgressBar
var hud_hp_label: Label
var hud_atk_label: Label
var hud_def_label: Label
var hud_kill_label: Label

func build_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 10
	add_child(hud_layer)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(16, 16)

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.05, 0.75)
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", panel_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	hud_level_label = Label.new()
	hud_level_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(hud_level_label)

	hud_exp_bar = ProgressBar.new()
	hud_exp_bar.custom_minimum_size = Vector2(150, 10)
	hud_exp_bar.show_percentage = false
	var exp_bg = StyleBoxFlat.new()
	exp_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	exp_bg.corner_radius_top_left = 3
	exp_bg.corner_radius_top_right = 3
	exp_bg.corner_radius_bottom_left = 3
	exp_bg.corner_radius_bottom_right = 3
	var exp_fill = StyleBoxFlat.new()
	exp_fill.bg_color = Color(0.3, 0.6, 1.0, 1.0)
	exp_fill.corner_radius_top_left = 3
	exp_fill.corner_radius_top_right = 3
	exp_fill.corner_radius_bottom_left = 3
	exp_fill.corner_radius_bottom_right = 3
	hud_exp_bar.add_theme_stylebox_override("background", exp_bg)
	hud_exp_bar.add_theme_stylebox_override("fill", exp_fill)
	vbox.add_child(hud_exp_bar)

	hud_hp_label = Label.new()
	hud_hp_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	vbox.add_child(hud_hp_label)

	hud_atk_label = Label.new()
	hud_atk_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	vbox.add_child(hud_atk_label)

	hud_def_label = Label.new()
	hud_def_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	vbox.add_child(hud_def_label)

	hud_kill_label = Label.new()
	hud_kill_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(hud_kill_label)

	hud_layer.add_child(panel)

func refresh_hud() -> void:
	if hud_level_label == null:
		return
	hud_level_label.text = "Lv. %d" % player_level
	hud_exp_bar.max_value = player_exp_to_next
	hud_exp_bar.value = player_exp
	hud_hp_label.text = "HP: %d / %d" % [int(round(player_current_health)), int(round(player_max_health))]
	hud_atk_label.text = "ATK: %d" % player_atk
	hud_def_label.text = "DEF: %d" % player_def
	hud_kill_label.text = "Slimes defeated: %d" % slimes_killed


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
	ambient1.finished.connect(_on_ambient1_finished)

	ambient2.stream = bird_sound_2
	ambient2.play()
	ambient2.finished.connect(_on_ambient2_finished)

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

	build_hud()
	refresh_hud()
	build_pause_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			toggle_fullscreen()
		if event.keycode == KEY_ESCAPE:
			pause()

var is_paused = false

func pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_menu_layer.visible = is_paused

func toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# PAUSE MENU 

var pause_menu_layer: CanvasLayer
var resume_button: Button
var quit_button: Button

func build_pause_menu() -> void:
	pause_menu_layer = CanvasLayer.new()
	pause_menu_layer.layer = 20   # di atas HUD (layer 10), biar nutupin semua
	add_child(pause_menu_layer)

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_menu_layer.add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_menu_layer.add_child(center)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)

	var title = Label.new()
	title.text = "PAUSED"
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	resume_button = Button.new()
	resume_button.text = "Resume"
	resume_button.custom_minimum_size = Vector2(180, 40)
	resume_button.pressed.connect(_on_resume_pressed)
	vbox.add_child(resume_button)

	quit_button = Button.new()
	quit_button.text = "Quit"
	quit_button.custom_minimum_size = Vector2(180, 40)
	quit_button.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_button)

	pause_menu_layer.hide()

func _on_resume_pressed() -> void:
	pause()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_wind_player_finished() -> void:
	wind_player.stream = wind_sounds[randi() % wind_sounds.size()]
	wind_player.play()

func _on_ambient1_finished() -> void:
	# jeda random sebelum bird_sound_1 muter lagi, biar gak berasa robotic
	get_tree().create_timer(randf_range(3.0, 8.0)).timeout.connect(func():
		ambient1.play()
	)

func _on_ambient2_finished() -> void:
	# jeda random sebelum bird_sound_2 muter lagi
	get_tree().create_timer(randf_range(3.0, 8.0)).timeout.connect(func():
		ambient2.play()
	)

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
