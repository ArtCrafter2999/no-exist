extends CanvasItem

@export var delay: float = 0

func _ready() -> void:
	hide()
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	show()
	await get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, 1).finished
