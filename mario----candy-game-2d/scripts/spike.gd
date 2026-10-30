extends Area2D

signal player_died

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body is Ninja:
		player_died.emit(body)
