extends Menu
class_name MainMenu

@onready var title: Sprite2D = $bg/CenterContainer/title/Sprite2D
@onready var instruction: Sprite2D = $bg/CenterContainer/instruction/Sprite2D
@onready var sfx_money: AudioStreamPlayer = $MoneySound
@onready var how_to_play_panel: Panel = $HowToPlayPanel
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var customise_panel: CustomisePanel = $CustomisePanel
@onready var credits_label: Label = $bg/Credit/Label

static var main_game_scene: PackedScene = ResourceLoader.load("res://scene/main.tscn")

var how_to_play_shown: bool = false
var settings_shown: bool = false
var customise_shown: bool = false

var _last_mpos: Vector2 = Vector2.INF

var _last_tutorial_press: bool = true

func _ready():
	super._ready()
	
	credits_label.text = """
	Game by DiamondDev
	Music by GaboDabo
	v%s
	""" % ProjectSettings.get_setting("application/config/version")
	
	settings_panel.position = Vector2(0, -800)
	customise_panel.position = Vector2(850, 25)
	
	settings_panel.show()
	customise_panel.show()

func _process(delta: float):
	super._process(delta)
	
	if GlobalManager.save_data.menu_particles and get_global_mouse_position().distance_squared_to(_last_mpos) >= 50 * 50:
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
	
	if Input.is_action_just_pressed("space_action") and not (
		how_to_play_shown or settings_shown or customise_shown
		):
		_play()
		
	var tutorial_press: bool = Input.is_key_pressed(KEY_H)
	if tutorial_press and not _last_tutorial_press:
		_on_how_to_play_opened()
		
	_last_tutorial_press = tutorial_press

func _play():
	get_tree().change_scene_to_packed(main_game_scene)
	

func _on_how_to_play_opened() -> void:
	if settings_shown or customise_shown:
		return
		
	how_to_play_shown = not how_to_play_shown
	
	var tween: Tween = how_to_play_panel.create_tween()
	
	if not how_to_play_shown:
		tween.tween_property(how_to_play_panel, "global_position", Vector2(0, 800), 0.2).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(how_to_play_panel, "global_position", Vector2(0, 800 - how_to_play_panel.size.y), 0.2).set_ease(Tween.EASE_OUT)
		

func _on_settings_button_pressed():
	if how_to_play_shown or customise_shown:
		return
	
	settings_shown = not settings_shown
	
	var tween: Tween = settings_panel.create_tween()
	
	if not settings_shown:
		tween.tween_property(settings_panel, "global_position", Vector2(0, -800), 0.2).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(settings_panel, "global_position", Vector2(0, 0), 0.2).set_ease(Tween.EASE_OUT)

func _on_customise_button_pressed():
	if how_to_play_shown or settings_shown:
		return
	
	customise_shown = not customise_shown
	
	var tween: Tween = customise_panel.create_tween()
	
	if not customise_shown:
		tween.tween_property(customise_panel, "global_position", Vector2(850, 25), 0.2).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(customise_panel, "global_position", Vector2(50, 25), 0.2).set_ease(Tween.EASE_OUT)


func _on_customise_panel_start_game() -> void:
	_play()
