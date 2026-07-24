extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_scene = "cliff_side"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_scenes()


func _on_cliffside_exitpoint_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true


func _on_cliffside_exitpoint_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = false

func change_scenes():
	if Global.transition_scene == true:
		if Global.current_scene == "cliff_side":
			get_tree().change_scene_to_file("res://Scenes/world.tscn")
			Global.finish_changescenes()
