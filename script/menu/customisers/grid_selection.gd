@tool
extends GridContainer
class_name GridSelection

var _options_back: Array

@export var default: bool = false
@export var font: Font
@export var options: Array:
	get: 
		return _options_back
	set(v): 
		_options_back = v
		_update()

func fetch() -> Dictionary:
	var dict := {}
	for c in get_children():
		if c is CheckBox:
			dict[c.text] = c.button_pressed
	return dict

func _update():
	for c in get_children():
		if c is CheckBox:
			c.queue_free()
	
	for c in options:
		var cb := CheckBox.new()
		cb.add_theme_color_override("font_color", Color.GREEN)
		cb.add_theme_color_override("font_pressed_color", Color.GREEN)
		cb.add_theme_font_override("font", font)
		cb.add_theme_font_size_override("font_size", 16)
		cb.button_pressed = default
		cb.text = c
		add_child(cb)
