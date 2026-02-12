extends Node2D

@onready var bg: Sprite2D = $Bg

func _ready():
	# Ensure the sprite is centered at its own position
	get_window().size_changed.connect(resize)
	# Call once at start
	resize()

func resize():
	if not bg.texture:
		return
		
	var tex_size = bg.texture.get_size()
	var view_size = get_viewport_rect().size
	
	# 1. Calculate scale factors for both axes
	var scale_x = view_size.x / tex_size.x
	var scale_y = view_size.y / tex_size.y
	
	# 2. Use the LARGER scale factor to ensure the screen is fully covered
	# (Use min(scale_x, scale_y) if you wanted "Contain" instead)
	var final_scale = max(scale_x, scale_y)
	
	scale = Vector2(final_scale, final_scale)
	
	# 3. Center the sprite in the middle of the viewport
	position = view_size / 2
