extends Control
class_name MoneyLabel

@onready var label: Label = $HBoxContainer/Label

var amount: int = 0

func _process(_delta):
	label.text = str(amount)
