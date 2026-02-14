extends Label

func fade():
	await get_tree().create_tween().tween_property(get_parent(), "modulate", Color.TRANSPARENT, 1).finished
	get_parent().hide();
