@tool
extends OmniLight3D

@export var targetname : String
@export var angle : Vector3
@export var energy_min : float = 8.0
@export var energy_max : float = 10.0

var unit_scale : float = 1.0 / 32.0
const light_brightness_scale := 16.0


@export var noise:NoiseTexture2D
var time_passed := 0.0



func _ready() -> void:
	if (Engine.is_editor_hint()):
		return  # don't do this stuff in editor (tool mode)



func _process(_delta: float) -> void:
	time_passed += _delta
	var sampled_noise = noise.noise.get_noise_1d(time_passed)
	sampled_noise = abs(sampled_noise)
	light_energy = energy_min + (sampled_noise * (energy_max - energy_min))



func set_import_value(key : String, value : String) -> bool:
	return true
	match key:
		"color", "_color":
			print("Current light_color is ", light_color)
			light_color = string_to_color(value)
			return true
		"light":
			#light_energy = value.to_float() * light_brightness_scale / 255.0
			omni_range = value.to_float() * unit_scale
			return true
			
	return false



func string_to_color(color_string : String) -> Color:
	var color := Color(1.0, 1.0, 1.0, 1.0)
	var floats := color_string.split_floats(" ")
	var scale := 1.0
	# Sometimes color is in the 0-255 range, so if anything is above 1, divide by 255
	for f in floats:
		if f > 1.0:
			scale = 1.0 / 255.0
			break
	for i in min(3, floats.size()):
		color[i] = floats[i] * scale
	return color



func post_import(root_node: Node):
	#var light_value := 300.0
	#var color_string : String
	
	#if (ent_dict.has(LIGHT_STRING_NAME)):
		#light_value = ent_dict[LIGHT_STRING_NAME].to_float()
	#if (ent_dict.has(_COLOR_STRING_NAME)):
		#light_color = string_to_color(ent_dict[_COLOR_STRING_NAME])
	#if (ent_dict.has(COLOR_STRING_NAME)):
		#light_color = string_to_color(ent_dict[COLOR_STRING_NAME])
	#light_node.omni_range = light_value * unit_scale
	
	#light_node.light_color = light_color
	shadow_enabled = true # Might want to have an option to shut this off for some lights?
