extends Control
class_name Menu

var age: float = 0

func _ready():
	age = 0
	
func _process(delta):
	age += delta
