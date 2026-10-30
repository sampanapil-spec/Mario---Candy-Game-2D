extends Control

@onready var canvas_layer = $CanvasLayer
@onready var fade = $CanvasLayer/Fade

func _ready() -> void:
	fade.modulate.a = 0.0  # ensure menu starts fully visible

func _on_start_pressed() -> void:
	await _fade_and_change_scene("res://scenes/main.tscn")

func _on_setting_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()

# ------------------------
# FADE TRANSITION
# ------------------------
func _fade_and_change_scene(path: String) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.0)  # fade to black over 1 second
	await tween.finished
	get_tree().change_scene_to_file(path)
