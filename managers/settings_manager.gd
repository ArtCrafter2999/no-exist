extends Node
class_name SettingsManager

signal settings_updated

@export var settings_file_name = "user://settings"

var settings: Dictionary = {}

var DEFAULT_SETTINGS =  {
	#&"window_mode": DisplayServer.WINDOW_MODE_FULLSCREEN,
	#&"master_volume": 100,
	&"music_volume": 100,
	&"sfx_volume": 100,
	&"voice_volume": 100,
	#&"font_size": 28,
}

func _ready() -> void:
	if not FileAccess.file_exists(settings_file_name):
		_default()
	var file := FileAccess.open(settings_file_name, FileAccess.READ)
	if file:
		settings = Dictionary(file.get_var(true));
		file.close();
	else: 
		_default();
	settings_updated.connect(_save_volume)
	settings_updated.emit();


func get_setting(key: StringName):
	return settings.get_or_add(key, DEFAULT_SETTINGS.get(key))


func set_setting(key: StringName, value: Variant):
	print("set, ", key, " ", value)
	settings.set(key, value);
	save()


func save():
	settings_updated.emit();
	var file := FileAccess.open(settings_file_name, FileAccess.WRITE)
	file.store_var(settings, true)
	file.close();


func _default():
	settings = Dictionary(DEFAULT_SETTINGS)
	save();

func _save_volume():
	print("update, ", get_setting(&"voice_volume")/100.0)
	#var master = AudioServer.get_bus_index("Master")
	var music = AudioServer.get_bus_index("Music")
	var sound = AudioServer.get_bus_index("Sound")
	var voice = AudioServer.get_bus_index("Voice")
	#AudioServer.set_bus_volume_db(master, linear_to_db(get_setting(&"master_volume")))
	AudioServer.set_bus_volume_db(music, linear_to_db(get_setting(&"music_volume")/100.0))
	AudioServer.set_bus_volume_db(sound, linear_to_db(get_setting(&"sfx_volume")/100.0))
	AudioServer.set_bus_volume_db(voice, linear_to_db(get_setting(&"voice_volume")/100.0))
