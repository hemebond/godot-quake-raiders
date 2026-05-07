extends MultiplayerSynchronizer



# Synchronized property.
@export var direction := Vector2()


func _ready() -> void:
	set_process(
		get_multiplayer_authority() == multiplayer.get_unique_id()
	)



func _process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
