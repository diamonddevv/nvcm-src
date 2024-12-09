extends CanvasLayer
class_name PauseOverlay

var paused: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_pause"):
		paused = not paused
	
	visible = paused
	get_tree().paused = paused


func _on_give_up_pressed() -> void:
	get_tree().paused = false
	GlobalManager.game_manager.player.kill()
