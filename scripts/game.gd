extends Node3D



@export var player_scene: PackedScene
@export var player_container: Node

const PORT: int = 42069

var is_hosting_game : bool = false

@onready var main_menu: Control = $main_menu

const GAME_SCENE = "uid://dgcbevg7wm4wv"  # game.tscn
const MAIN_MENU_SCENE = "uid://bsn8o457q00p0"  # main_menu.tscn

func _ready() -> void:
	main_menu.send_test_msg.connect(_send_test_msg)
	main_menu.start_game.connect(start_game)
	main_menu.join_game.connect(join_game)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()







func start_game() -> void:
	print("Starting host!")
	
	main_menu.hide()

	is_hosting_game = true
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)  # MAX_CLIENTS defaults to 32
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)

	print("server created")
	
	# Add the host to the game
	_add_player_to_game(1)

func _add_player_to_game(id: int) -> void:
	print("Player %s joined the game" % id)
	
	# Setup player
	var player_to_add : Node3D = player_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	# Move the new player to the spawn point
	# Assign the position to transform.origin because objects not yet in the tree have no global_position
	var info_player_start : Node3D = get_tree().get_current_scene().get_node("world/test/info_player_start")
	player_to_add.transform.origin = info_player_start.global_position
	
	# Spawn player
	player_container.add_child(player_to_add, true)

func _remove_player_from_game(id: int) -> void:
	print("Player %s left the game" % id)
	
	if not player_container.has_node(str(id)):
		return
	
	player_container.get_node(str(id)).queue_free()



func join_game() -> void:
	print("Joining game")
	
	main_menu.hide()
	
	var client_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	client_peer.create_client("localhost", PORT)
	
	multiplayer.multiplayer_peer = client_peer






func _send_test_msg() -> void:
	_send_test_message.rpc("Hello there")

@rpc("any_peer", "call_remote")
func _send_test_message(message: String) -> void:
	print(
		"Message [%s] received on peer [%s] from peer [%s]" % [
			message,
			multiplayer.get_unique_id(),
			multiplayer.get_remote_sender_id()
		]
	)
