extends Panel
class_name CustomisePanel

signal close()

@onready var seeded_run_check: CheckBox = $CenterContainer/VBoxContainer/SeededRun/CheckBox
@onready var seed_input_container: HBoxContainer = $CenterContainer/VBoxContainer/Seed
@onready var seed_input_box: LineEdit = $CenterContainer/VBoxContainer/Seed/LineEdit

func _process(delta: float) -> void:
	GlobalManager.has_set_seed = seeded_run_check.button_pressed
	GlobalManager.set_seed = seed_input_box.text
	
	seed_input_container.visible = GlobalManager.has_set_seed


func _on_customise_button_pressed() -> void:
	close.emit()
