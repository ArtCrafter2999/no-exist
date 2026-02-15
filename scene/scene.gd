extends Node2D
class_name Scene

@export var dialog_resource: DialogueResource

const BALLOON = preload("uid://draqcgirrl2n0")

var questions: Array[String] = []
var balloon: DialogueBalloon;
var music_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer
var glitch_increased: bool = false;
var last_of_chapter_left: bool = false;

@onready var character: Node2D = %Character
@onready var glitch_screen: GlitchScreen = %GlitchScreen
@onready var periodic_glitch_screen: PeriodicGlitchScreen = %PeriodicGlitchScreen
@onready var timer_label: Label = %TimerLabel
@onready var white: ColorRect = %WhiteFade
@onready var black: ColorRect = %BlackFade
@onready var restart_button_node: TextureButton = %RestartButton
@onready var game: GameManager = find_parent("Game")
@onready var camera: Camera2D = %Camera
@onready var container: Node2D = $Container

func _ready() -> void:
	if not OS.has_feature("editor"):
		await camera.animation()
	timer_fade_in();
	container.paralax = true;
	DialogueManager.got_dialogue.connect(_got_dialogue)
	balloon = DialogueManager.show_dialogue_balloon_scene(BALLOON, dialog_resource, 
			"start7" if OS.has_feature("editor") else "start", [self])
	var children = character.get_children(false)
	var emotions: Array[String] = []
	for node in children:
		if node.is_in_group(&"character_state"):
			emotions.append(node.name)
	balloon.emotions = emotions
	while not balloon or not balloon.responses_menu:
		await get_tree().process_frame
	balloon.responses_menu.response_selected.connect(func (response: DialogueResponse):
			ask(response.text)
	)
	

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
	glitch_screen.generate_random();
	await get_tree().create_timer(seconds).timeout
	glitch_screen.hide()

func increase_glitch():
	if glitch_increased: return;
	glitch_increased = true;
	periodic_glitch_screen.period_range = Vector2(3, 8)
	periodic_glitch_screen.size_range = Vector2(0.1, 0.15)
	periodic_glitch_screen.amount_range = Vector2(5, 6)

func timer(text: String, play_sound: bool = true):
	if play_sound:
		sound("timer_move.ogg")
	timer_label.text = text

func timer_fade():
	timer_label.fade();
	
func timer_fade_in():
	timer_label.get_parent().modulate = Color.TRANSPARENT;
	timer_label.get_parent().show();
	await get_tree().create_tween().tween_property(timer_label.get_parent(), "modulate", Color.WHITE, 1).from(Color.TRANSPARENT).finished

func character_fade():
	await get_tree().create_tween().tween_property(character, "modulate", Color.TRANSPARENT, 0.1).finished
	character.hide();
	
func white_fade_in():
	await get_tree().create_tween().tween_property(white, "modulate", Color.WHITE, 2).finished

func white_fade_out():
	character.hide();
	await get_tree().create_tween().tween_property(white, "modulate", Color.TRANSPARENT, 2).finished

func black_fade():
	await get_tree().create_tween().tween_property(black, "modulate", Color.WHITE, 2).finished
	
func quit():
	if OS.get_name() == "Web":
		restart()
	else:
		get_tree().quit()
		
func restart():
	game.start();
	queue_free()
	balloon.queue_free()
	
func restart_button():
	restart_button_node.show()
	get_tree().create_tween().tween_property(restart_button_node, "modulate", Color.WHITE, 2).from(Color.TRANSPARENT)
	
func ambience(options_string: String):
	music(options_string + " ambience")

func music(options_string: String):
	var options = Options.new(options_string)
	var file_name = options.array[0]
	var fade_in_value = options.get_int("fade-in", 1) # sec
	var fade_out_value = options.get_int("fade-out", 1) # sec
	var is_ambience = options.has("ambience")
	var off = options.has("off")
	
	if not is_ambience and music_player and music_player.name == file_name: return
	if is_ambience and ambience_player and ambience_player.name == file_name: return
	
	var new_player: AudioStreamPlayer = null
	var file = "res://%s/%s" % \
				["ambience" if is_ambience else "music", file_name]
	if not off and file_name:
		if ResourceLoader.exists(file):
			new_player = AudioStreamPlayer.new()
			new_player.name = file_name
			new_player.stream = load(file)
			new_player.bus = &"Music"
		else:
			push_warning("no '%s' %s found" % [file_name, "ambience" if is_ambience else "music"])
	
	if new_player and fade_in_value:
		new_player.volume_linear = 0
		var tween = get_tree().create_tween()
		tween.tween_property(new_player, "volume_linear", 1, fade_in_value)
	
	var old_player = ambience_player if is_ambience else music_player
	
	if old_player:
		if fade_out_value and old_player.playing:
			var tween = get_tree().create_tween()
			tween.tween_property(old_player, "volume_linear", 0, fade_out_value)
			tween.finished.connect(func (): 
					old_player.queue_free())
		else:
			old_player.queue_free()
	
	if new_player:
		add_child(new_player);
		new_player.play();
	
	if is_ambience:
		ambience_player = new_player
	else:
		music_player = new_player

func sound(options_string: String):
	var options = Options.new(options_string)
	var file_name = options.array[0]
	var awaiting = options.has("await")
	
	if not file_name: return;
	var file = "res://sound/%s" % file_name
	var new_player: AudioStreamPlayer = null
	if ResourceLoader.exists(file):
		new_player = AudioStreamPlayer.new()
		new_player.name = file_name
		new_player.stream = load(file)
		new_player.bus = &"Music"
	else:
		push_warning("no '%s' sound found" % file_name)
		return;
		
	if new_player:
		add_child(new_player);
		new_player.play();
	new_player.finished.connect(func (): new_player.queue_free())
	if awaiting:
		await new_player.finished

func _got_dialogue(dialogue_line: DialogueLine):
	var last_of_chapter = dialogue_line.has_tag("last_of_chapter")
	var allowed_responses = dialogue_line.responses.filter(
		func (response: DialogueResponse): 
			return response.is_allowed
	).size()
	if last_of_chapter and allowed_responses == 1:
		last_of_chapter_left = true
	
	if last_of_chapter_left:
		last_of_chapter_left = false
		music("off fade-out-10")
