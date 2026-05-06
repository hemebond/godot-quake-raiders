@tool
extends OmniLight3D

@export var targetname : String
@export var angle : Vector3
@export var style : float = 0



var unit_scale : float = 1.0 / 32.0
const light_brightness_scale := 16.0



func _ready() -> void:
	if (Engine.is_editor_hint()):
		return  # don't do this stuff in editor (tool mode)



#func _process(_delta: float) -> void:
	#pass



func set_import_value(key : String, value : String) -> bool:
	print("set_import_value")
	match key:
		"color", "_color":
			print("Current light_color is ", light_color)
			light_color = string_to_color(value)
			return true
		"light":
			print("Light has light of", value)
			light_energy = value.to_float() * light_brightness_scale / 255.0
			omni_range = value.to_float() * unit_scale
			return true
			
	return false



func string_to_color(color_string : String) -> Color:
	var color := Color(1.0, 1.0, 1.0, 1.0)
	var floats := color_string.split_floats(" ")
	var color_scale:float = 1.0
	# Sometimes color is in the 0-255 range, so if anything is above 1, divide by 255
	for f:float in floats:
		if f > 1.0:
			color_scale = 1.0 / 255.0
			break
	for i:int in min(3, floats.size()):
		color[i] = floats[i] * color_scale
	return color



func post_import(_root_node: Node) -> void:
	shadow_enabled = true # Might want to have an option to shut this off for some lights?
