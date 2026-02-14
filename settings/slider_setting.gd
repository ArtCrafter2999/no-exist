extends Range

@export var setting_key: StringName;

@onready var setting_manager: SettingsManager = find_parent("Game").settings_manager;

func _ready() -> void:
	while not setting_manager:
		await get_tree().process_frame
	value = setting_manager.get_setting(setting_key)
	value_changed.connect(_update_setting)

func _update_setting(new_value: float):
	setting_manager.set_setting(setting_key, new_value)
