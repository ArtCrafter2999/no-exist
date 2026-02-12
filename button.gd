extends TextureButton

const DECORATION_HOVER_TEXTURE: Texture2D = preload("uid://b4ipu5io01486")

@export var text: String;

var decoration_default_texture: Texture2D;

@onready var label: Label = $Label
@onready var decoration: TextureRect = $decoration

func _ready() -> void:
	label.text = text;
	decoration_default_texture = decoration.texture
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	
	update_my_size()

	# Optional: If the label text changes dynamically at runtime, 
	# connect to the minimum_size_changed signal of the container.
	label.minimum_size_changed.connect(update_my_size)

func update_my_size():
	# Set the button's custom minimum size to match the container's needs
	custom_minimum_size = label.get_combined_minimum_size()

func _mouse_entered() -> void:
	label.add_theme_color_override("font_color", Color("322F29"));
	decoration.texture = DECORATION_HOVER_TEXTURE
	
func _mouse_exited() -> void:
	label.add_theme_color_override("font_color", Color("D6D0B8"));
	decoration.texture = decoration_default_texture
	
