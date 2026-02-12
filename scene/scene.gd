extends Node2D
class_name Scene

@export var dialog_resource: DialogueResource
const BALLOON = preload("uid://draqcgirrl2n0")

var questions: Array[String] = []
var balloon: DialogueBalloon;

@onready var character: Node2D = %Character
@onready var glitch_screen: Control = %GlitchScreen

func asked(question_ids: String):
	var ids = question_ids.split(",")
	for id in ids:
		if not questions.has(id.strip_edges()):
			return false
	return true;

func ask(question_ids: String):
	var ids = question_ids.split(",")
	for id in ids:
		questions.push_back(id.strip_edges())

func screen_glitch(seconds: float = 1):
	glitch_screen.show()
	# TODO додати рандом
	# TODO додати рандомний періодичний гліч протягом гри
	await get_tree().create_timer(seconds).timeout
	glitch_screen.hide()

func _ready() -> void:
	balloon = DialogueManager.show_dialogue_balloon_scene(BALLOON, dialog_resource, "start", [self])
	var children = character.get_children(false)
	var emotions: Array[String] = []
	for node in children:
		if node.is_in_group(&"character_state"):
			emotions.append(node.name)
	balloon.emotions = emotions
	await get_tree().process_frame
	balloon.responses_menu.response_selected.connect(func (response: DialogueResponse):
			ask(response.text)
	)
