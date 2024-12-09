extends Control
class_name MainMenu

@onready var title: Sprite2D = $bg/CenterContainer/title/Sprite2D
@onready var instruction: Sprite2D = $bg/CenterContainer/instruction/Sprite2D
@onready var sfx_money: AudioStreamPlayer = $MoneySound
@onready var how_to_play_panel: Panel = $HowToPlayPanel

static var main_game_scene: PackedScene = ResourceLoader.load("res://scene/main.tscn")

var age: float = 0
var how_to_play_shown: bool = false
var _last_mpos: Vector2 = Vector2.INF

var _last_tutorial_press: bool = true

func _ready():
	age = 0
		
func _process(delta: float):
	age += delta
	
	if get_global_mouse_position().distance_squared_to(_last_mpos) >= 50 * 50:
		var p: CPUParticles2D = Hud.money_particle.instantiate()
		p.finished.connect(func(): p.queue_free())
		p.global_position = get_global_mouse_position()
		p.lifetime = 10
		add_child(p)
		p.emitting = true
		
		sfx_money.pitch_scale = randf_range(0.9, 1.1)
		sfx_money.play()
		
		_last_mpos = get_global_mouse_position()
	
	title.rotation_degrees = 2 * sin(age)
	title.position = Vector2(cos(age), -30 + sin(age))
	
	instruction.rotation_degrees = 2 * -sin(age)
	instruction.position = Vector2(-cos(age), -sin(age))
	
	if Input.is_action_just_pressed("space_action"):
		_play()
		
	var tutorial_press: bool = Input.is_key_pressed(KEY_H)
	if tutorial_press and not _last_tutorial_press:
		_on_how_to_play_opened()
		
	_last_tutorial_press = tutorial_press

func _play():
	get_tree().change_scene_to_packed(main_game_scene)
	

func _on_how_to_play_opened() -> void:
	how_to_play_shown = not how_to_play_shown
	
	var tween: Tween = how_to_play_panel.create_tween()
	
	if how_to_play_shown:
		tween.tween_property(how_to_play_panel, "global_position", Vector2(0, 800), 0.2).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(how_to_play_panel, "global_position", Vector2(0, 800 - how_to_play_panel.size.y), 0.2).set_ease(Tween.EASE_OUT)
		
