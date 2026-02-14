@tool
extends Label

@export var slider: Range
@export var template: String = "%.0f"

func _process(_delta: float) -> void:
	if !slider: return;

	text = template % slider.value
