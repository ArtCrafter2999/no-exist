extends RefCounted
class_name Options

var array: Array[String] = []

func _init(options: String) -> void:
	array.assign(options.split(" ", false));

func get_int(param_name: String, default_value: Variant = null):
	var regex = RegEx.create_from_string("^-\\[?([\\d]+)\\]?$")
	var index = array.rfind_custom(func (param: String): 
			return param.begins_with(param_name) and regex.search(param.substr(param_name.length()))
	);
	if index == -1: return default_value;
	var param_value = regex.search(array[index].substr(param_name.length())).strings[1]
	return int(param_value)

func get_float(param_name: String, default_value: Variant = null):
	var regex = RegEx.create_from_string("^-\\[?([\\d.]+)\\]?$")
	var index = array.rfind_custom(func (param: String): 
			return param.begins_with(param_name) and regex.search(param.substr(param_name.length()))
	);
	if index == -1: return default_value;
	var param_value = regex.search(array[index].substr(param_name.length())).strings[1]
	return float(param_value)

func has(param_name: String):
	if array.has(param_name):
		return true
	var regex = RegEx.create_from_string("-([\\w]+)$")
	var index = array.rfind_custom(func (param: String): 
			return param.begins_with(param_name) and regex.search(param.substr(param_name.length()))
	);
	if index != -1:
		return true
	return false
