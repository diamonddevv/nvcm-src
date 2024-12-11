@tool
extends HBoxContainer
class_name StatSlider

@export var text: String
@export var min: float
@export var max: float
@export var step: float
@export var start_value: float
@export var express_as_percentage: bool = false

func _ready():
	$HSlider.min_value = min
	$HSlider.max_value = max
	$HSlider.step = step
	$HSlider.value = start_value

func _process(delta):
	$Label.text = text
	$Value.text = ("(%.1f%%)" if express_as_percentage else "(%s)") % (get_percentage() * 100 if express_as_percentage else $HSlider.value)

func get_val() -> float:
	return $HSlider.value
	
func get_percentage() -> float:
	return $HSlider.value / $HSlider.max_value
