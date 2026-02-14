extends Camera2D

@export var curve: Curve

var y: float:
	get: return offset.y / get_viewport_rect().size.y
	set(value):
		offset.y = get_viewport_rect().size.y * value
func animation():
	var view = get_viewport_rect().size
	
	zoom = Vector2.ONE * 3
	offset.y = view.y * 0.3
	var tween =  get_tree().create_tween()
	tween.tween_property(self, "y", -0.10, 5).set_custom_interpolator(tween_curve)
	tween.tween_property(self, "zoom", Vector2.ONE, 4).set_custom_interpolator(tween_curve)
	tween.parallel().tween_property(self, "offset", Vector2.ZERO, 4)#.set_custom_interpolator(tween_curve)
	await tween.finished
	
func tween_curve(v):
	return curve.sample_baked(v)
