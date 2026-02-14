extends Node
class_name GameManager

const PLAY_SCENE = preload("uid://cls0jt3mur20d")

@export var settings_manager: SettingsManager

@onready var intro: CanvasLayer = $Intro
@onready var color_rect: ColorRect = $Intro/ColorRect

func _ready() -> void:
	if not intro.visible and not OS.has_feature("editor"):
		intro.show();
	if not intro.visible:
		start()

func start():
	var scene = PLAY_SCENE.instantiate()
	add_child(scene)
	if intro.visible:
		await get_tree().create_tween().tween_property(color_rect, "modulate", Color.TRANSPARENT, 1).finished
		intro.hide();
