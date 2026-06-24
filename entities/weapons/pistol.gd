class_name Pistol extends Node3D



@onready var animation_player = $animation_player



func shoot() -> void:
	if not animation_player.is_playing():
		animation_player.play(&"shoot")
		animation_player.seek(0)
