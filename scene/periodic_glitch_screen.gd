extends GlitchScreen
class_name PeriodicGlitchScreen

@export var period_range: Vector2 = Vector2(5, 10)
@export var time_range: Vector2 = Vector2(0.5, 1)

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true;
	timer.timeout.connect(_timer_timeout)
	add_child(timer)
	timer.start(randf_range(period_range.x, period_range.y))

func _timer_timeout():
	show();
	generate_random()
	await get_tree().create_timer(randf_range(time_range.x, time_range.y)).timeout
	hide();
	timer.start(randf_range(period_range.x, period_range.y));
