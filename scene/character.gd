extends Node2D

@export var state_name: String = "Спокій":
	get: return state_name;
	set(value): 
		state_name = value;
		_show_state();

@onready var scene: Scene = find_parent("Scene")

func _ready() -> void:
	while not scene or not scene.balloon:
		await get_tree().process_frame
	scene.balloon.emotion_changed.connect(_emotion_changed)

func _emotion_changed(emotion: String):
	state_name = emotion

func _show_state():
	var component = _find_state(state_name);
	if !component: return;
	var children = get_children(false)
	for node in children:
		if node.is_in_group(&"character_state"):
			node.hide()
	component.show();

func _find_state(searching_state: String): 
	var depth = searching_state.split("/", false)
	var node: Node2D = self
	for node_name in depth:
		node = node.find_child(node_name, false, false)
		if !node: 
			push_warning("Character state not found, searching: %s" % name)
			return;
	if !node.is_in_group(&"character_state"):
		push_warning("Character state should be of group character_state." +
				"Maybe you forgot to add it to the group. Searching: %s " % name)
		return;
	return node
