extends Panel
class_name CustomisePanel

signal close()
signal start_game()

@onready var seed_input_container: HBoxContainer = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/Seed

@onready var seeded_run_check: CheckBox = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/SeededRun/CheckBox
@onready var seed_input_box: LineEdit = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/Seed/LineEdit
@onready var boss_freq: BetterSpinbox = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/BossFrequency/BetterSpinbox

func _process(delta: float) -> void:
	seed_input_container.visible = seeded_run_check.button_pressed


func _on_customise_button_pressed() -> void:
	close.emit()


func _on_play_pressed() -> void:
	GlobalManager.customisation = {
		"has_seed": seeded_run_check.button_pressed,
		"seed": seed_input_box.text,
		"boss_freq": boss_freq.value
	}
	
	start_game.emit()
