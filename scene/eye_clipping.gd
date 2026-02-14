extends Sprite2D

const EYE_CLOSED = preload("uid://l73o7odsjtbe")

@export var clipping_range: Vector2 = Vector2(3,6)

var timer: Timer
var default_texture: Texture2D

@onready var scene: Scene = find_parent("Scene")

func _ready() -> void:
	default_texture = texture
	timer = Timer.new()
	timer.one_shot = true;
	timer.timeout.connect(_timer_timeout)
	add_child(timer)
	_timer_timeout()

func _timer_timeout():
	if texture == default_texture:
		texture = EYE_CLOSED;
		timer.start(0.1)
		await timer.timeout
		texture = default_texture
		timer.start(randf_range(clipping_range.x, clipping_range.y))
