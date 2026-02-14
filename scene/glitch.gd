extends Control
class_name GlitchScreen

@export var template: ColorRect
@export var amount_range: Vector2i = Vector2(10, 20)
@export var size_range: Vector2 = Vector2(.07, .20) # Макс. розмір одного блоку
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	template = template.duplicate()

func generate_random():
	if visible and audio_stream_player.is_node_ready():
		audio_stream_player.play();
	# 1. Очищуємо старі блоки
	for child in get_children():
		if child != template and child is ColorRect: # Не видаляємо сам шаблон
			child.queue_free()
	
	# 2. Визначаємо рандомну кількість блоків у діапазоні
	var amount = randi_range(amount_range.x, amount_range.y)
	var screen_size = get_viewport_rect().size

	for i in range(amount):
		# Створюємо дублікат
		var glitch = template.duplicate()
		glitch.visible = true
		
		# 3. Рандомний розмір
		var random_w = randf_range(screen_size.x*size_range.x, screen_size.x*size_range.y)
		var random_h = randf_range(screen_size.y*size_range.x, screen_size.y*size_range.y)
		glitch.size = Vector2(random_w, random_h)
		
		# 4. Рандомна позиція (враховуючи розмір блоку, щоб не вилазив за край)
		var pos_x = randf_range(0, screen_size.x - glitch.size.x)
		var pos_y = randf_range(0, screen_size.y - glitch.size.y)
		glitch.position = Vector2(pos_x, pos_y)
		
		# 5. (Опціонально) Рандомний колір для ефекту
		glitch.color.a = randf_range(0.3, 0.8) # Прозорість
		
		add_child(glitch)
