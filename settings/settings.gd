extends CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Settings"):
		visible = !visible;
		Engine.time_scale = 0 if visible else 1
