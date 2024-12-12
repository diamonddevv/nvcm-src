@tool
extends HBoxContainer
class_name BetterSpinbox

@export var value: int = 0
@export var prefix: String = ""
@export var suffix: String = ""
@export var min: int = 0
@export var max: int = 25

func _process(delta: float) -> void:
	$Label.text = "%s [%s] %s" % [prefix, value, suffix]

func _change(up: bool) -> void:
	var mod: int = 5 if Input.is_key_pressed(KEY_CTRL) else 1
	value = clamp(value + (1 if up else -1) * mod, min, max)
