extends Control


signal send_test_msg
signal start_game
signal join_game


func _on_host_pressed() -> void:
	emit_signal("start_game")


func _on_join_pressed() -> void:
	emit_signal("join_game")


func _on_send_test_msg_pressed() -> void:
	emit_signal("send_test_msg")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("quit"):
		get_tree().quit()
