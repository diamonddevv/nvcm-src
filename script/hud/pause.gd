extends CanvasLayer
class_name PauseOverlay

@onready var settings_panel: SettingsPanel = $SettingsPanel

var paused: bool = false
var settings_shown: bool = false

func _ready():
	settings_panel.close.connect(_on_settings_pressed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_pause"):
		paused = not paused
	
	visible = paused
	get_tree().paused = paused


func _on_give_up_pressed() -> void:
	get_tree().paused = false
	GlobalManager.game_manager.player.kill()


func _on_resume_pressed():
	paused = not paused


func _on_report_bugs_pressed():
	OS.shell_open("https://github.com/diamonddevv/nvcm-src/issues/")


func _on_settings_pressed():
	settings_shown = not settings_shown
	
	var tween: Tween = settings_panel.create_tween()
	
	if not settings_shown:
		tween.tween_property(settings_panel, "global_position", Vector2(0, -800), 0.2).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(settings_panel, "global_position", Vector2(0, 0), 0.2).set_ease(Tween.EASE_OUT)
