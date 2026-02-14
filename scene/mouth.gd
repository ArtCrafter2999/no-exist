extends Sprite2D

const MOUTH_CLOSED = preload("uid://donty0w6akfjw")

var timer: Timer
var default_texture: Texture2D

@onready var scene: Scene = find_parent("Scene")

func _ready() -> void:
	default_texture = texture
	texture = MOUTH_CLOSED
	timer = Timer.new()
	timer.one_shot = true;
	timer.wait_time = 0.3
	timer.timeout.connect(_timer_timeout)
	add_child(timer)
	while not scene or not scene.balloon or not scene.balloon.dialogue_label:
		await get_tree().process_frame
	scene.balloon.dialogue_label.started_typing.connect(_started_typing)

func _timer_timeout():
	if texture == default_texture:
		texture = MOUTH_CLOSED;
		if scene.balloon.dialogue_label.is_typing:
			timer.start();
	else:
		texture = default_texture
		timer.start();

func _started_typing():
	if scene.balloon.dialogue_line.text.remove_chars(".,?!").strip_edges():
		timer.start();
