extends Node2D

func _ready():
	# Ensure the sprite is centered at its own position
	get_window().size_changed.connect(resize)
	# Call once at start
	resize()

func resize():
	var view_size = get_viewport_rect().size
	
	position = view_size / 2
