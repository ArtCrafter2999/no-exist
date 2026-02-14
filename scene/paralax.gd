extends Node2D

@export_group("Parallax Settings")
## Nodes to move. Ensure they have a 'modifier' variable (e.g., 0.1 for back, 1.0 for front).
@export var controls: Array[Node2D] 
## How many pixels the elements can move at maximum.
@export var maximum_movement: Vector2 = Vector2(50, 50)
## Extra padding to prevent seeing edges during parallax (1.1 = 10% extra size).
@export var overscan_factor: float = 1.15 

@export_group("Circular Motion (Idle)")
@export var circle_speed: float = 1.0
## How many pixels wide/tall the circle is.
@export var circle_radius: float = 70.0
@export var paralax = false;

@export_group("References")
@onready var bg: Sprite2D = $Bg

var _previous_screen_percent: Vector2 = Vector2.ZERO
var _current_tween: Tween
var _time: float = 0.0

func _ready() -> void:
	# Connect resize signal to handle resolution changes / Fullscreen toggle
	get_tree().root.size_changed.connect(resize)
	_process(0);
	resize()

func _process(delta: float) -> void:
	# Don't follow mouse if a focus-tween is currently running
	if _current_tween and _current_tween.is_running():
		return
	if not paralax: return;
	
	_time += delta

	var mouse_pos = get_viewport().get_mouse_position()
	
	# We use sin and cos to create a perfect circle
	var circle_offset = Vector2(
		cos(_time * circle_speed),
		sin(_time * circle_speed)
	) * circle_radius
	
	# 3. Combine them
	var final_pos = mouse_pos + circle_offset
	
	var screen_percent = _calculate_screen_percent_from_abs(final_pos)
	_set_parallax(screen_percent)

func resize() -> void:
	if not bg or not bg.texture:
		return
		
	var tex_size = bg.texture.get_size()
	var view_size = get_viewport_rect().size
	
	# Calculate scale to fill screen
	var scale_x = view_size.x / tex_size.x
	var scale_y = view_size.y / tex_size.y
	
	# Use max() to fill, and multiply by overscan to hide parallax edges
	var final_scale = max(scale_x, scale_y) * overscan_factor
	
	self.scale = Vector2(final_scale, final_scale)
	
	# Center the parent node so children move relative to screen center
	self.position = view_size / 2

func _calculate_screen_percent_from_abs(absolute_pos: Vector2) -> Vector2:
	var viewport_size = get_viewport_rect().size
	if viewport_size == Vector2.ZERO: return Vector2.ZERO
	
	var p = absolute_pos / viewport_size - Vector2(0.5, 0.5)
	return p.clamp(Vector2.ONE * -0.5, Vector2.ONE * 0.5)

func _set_parallax(screen_percent: Vector2) -> void:
	for c in controls:
		if is_instance_valid(c):
			var mod = c.get("modifier") if "modifier" in c else 1.0
			# We apply movement relative to the center (0,0) of this Node2D
			c.position = maximum_movement * screen_percent * mod
	
	_previous_screen_percent = screen_percent
