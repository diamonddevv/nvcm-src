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
	value = clamp(value + (1 if up else -1), min, max)
