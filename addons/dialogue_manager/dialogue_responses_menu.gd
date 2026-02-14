@icon("./assets/responses_menu.svg")
## A container that places dialogue responses at random positions without overlapping.
class_name DialogueResponsesMenu extends Control

signal response_focused(response: Control)
signal response_selected(response: DialogueResponse)

@export var response_template: Control
@export var next_action: StringName = &""
@export var auto_configure_focus: bool = true
@export var auto_focus_first_item: bool = true
@export var hide_failed_responses: bool = false

## Maximum attempts to find a random spot before giving up.
@export var max_placement_attempts: int = 50
## Areas where buttons should NOT be placed (in local coordinates).
@export var positions: Array[Control] = []

@onready var balloon: DialogueBalloon = $".."

var responses: Array = []:
	set(value):
		responses = value
		_apply_responses()
	get:
		return responses

var _previously_focused_item: Control = null

func _ready() -> void:
	# Ensure the container doesn't force children into a layout (like VBox would)
	# This script works best if 'this' is a simple Control or Panel.
	visibility_changed.connect(func():
		if auto_focus_first_item and visible and get_menu_items().size() > 0:
			var first_item: Control = get_menu_items()[0]
			if first_item.is_inside_tree():
				first_item.grab_focus()
	)

	if is_instance_valid(response_template):
		response_template.hide()

	get_viewport().gui_focus_changed.connect(_on_focus_changed)

func get_menu_items() -> Array:
	var items: Array = []
	for child in get_children():
		if child == response_template: continue
		if not (child is BaseButton): continue
		if not child.visible: continue
		if "Disallowed" in child.name: continue
		items.append(child)
	return items

func configure_focus() -> void:
	var items = get_menu_items()
	if items.size() == 0: return
	
	for i in items.size():
		var item: Control = items[i]
		item.focus_mode = Control.FOCUS_ALL
		# For random placement, standard directional focus neighbors 
		# might feel weird, but we keep the logic for manual overrides.
		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.pressed.connect(_on_response_gui_input.bind(item, item.get_meta("response")))

	_previously_focused_item = items[0]
	if auto_focus_first_item:
		items[0].grab_focus()

#region Internal Placement Logic

func _apply_responses() -> void:
	for item in get_children():
		if item == response_template: continue
		item.queue_free()

	if responses.size() > 0:
		for i in range(responses.size()):
			var response = responses[i]
			if hide_failed_responses and not response.is_allowed: continue

			var item: Control
			if is_instance_valid(response_template):
				item = response_template.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
				item.show()
			else:
				item = Button.new()
			
			item.name = "Response%d" % get_child_count()
			if not response.is_allowed:
				item.name = item.name + &"Disallowed"
				item.visible = false

			if "response" in item:
				item.response = response
			else:
				item.text = response.text

			item.set_meta("response", response)
			add_child(item)
			
			# Wait for the item to resize if using a template, or call reset_size
			if item is Button: item.reset_size()
			
			if i < positions.size() and is_instance_valid(positions[i]):
				# Use call_deferred to ensure the marker has updated its own position 
				# based on its anchors before we snap the button to it.
				item.global_position = positions[i].global_position
			else:
				push_warning("DialogueResponsesMenu: No preset position found for index %d" % i)
			
		if auto_configure_focus:
			configure_focus()

#region Signals

func _on_focus_changed(control: Control) -> void:
	if "Disallowed" in control.name: return
	if not control in get_menu_items(): return
	if _previously_focused_item != control:
		_previously_focused_item = control
		response_focused.emit(control)

func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return
	item.grab_focus()

func _on_response_gui_input(item: Control, response: DialogueResponse) -> void:
	if "Disallowed" in item: return
	get_viewport().set_input_as_handled()
	response_selected.emit(response)
	#if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
	#elif event.is_action_pressed(&"ui_accept" if next_action.is_empty() else next_action):
		#get_viewport().set_input_as_handled()
		#response_selected.emit(response)

#endregion
