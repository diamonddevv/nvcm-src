extends Panel
class_name CustomisePanel

signal close()
signal start_game()

@onready var seeded_run_check: CheckBox = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/SeededRun/CheckBox
@onready var seed_input_box: LineEdit = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/SeededRun/LineEdit
@onready var wave_size_inc_freq: BetterSpinbox = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/WaveSizeIncreaseFrequency/BetterSpinbox
@onready var boss_freq: BetterSpinbox = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/BossFrequency/BetterSpinbox
@onready var allowed_enemies: GridSelection = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/AllowedEnemyTypes/GridSelection
@onready var allowed_bosses: GridSelection = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/AllowedBossTypes/GridSelection

@onready var base_money: StatSlider = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/Stat_BaseMoney
@onready var max_health: StatSlider = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/Stat_MaxHealth
@onready var bullets_per_shot: StatSlider = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/Stat_BulletsShotPerClick
@onready var fire_delay: StatSlider = $CenterContainer/VBoxContainer/ScrollContainer/VBoxContainer/Stat_FireDelay


func _ready():
	$HackermanLabel.hide()
	$CenterContainer.show()
	
	allowed_enemies.options = Enemy.behaviours.keys()
	allowed_bosses.options = Enemy.boss_behaviors.keys()

func _process(delta: float) -> void:
	seed_input_box.visible = seeded_run_check.button_pressed

func _on_customise_button_pressed() -> void:
	close.emit()

func _on_play_pressed() -> void:
	hackermode()

func strip_condition(dict: Dictionary, cond: Callable) -> Dictionary:
	var d := {}
	for key in dict:
		if cond.call(dict[key]):
			d[key] = dict[key]
	return d

func keys_of(dict: Dictionary, keys: Array) -> Array:
	var a := []
	for key in keys:
		a.append(dict[key])
	return a

func play() -> void:
	GlobalManager.customisation = {
		"has_seed": seeded_run_check.button_pressed,
		"seed": seed_input_box.text,
		"wave_size_inc_freq": wave_size_inc_freq.value,
		"boss_freq": boss_freq.value,
		"enemy_pool": keys_of(Enemy.behaviours, strip_condition(allowed_enemies.fetch(), func(b: bool): return b).keys()),
		"boss_pool": keys_of(Enemy.boss_behaviors, strip_condition(allowed_bosses.fetch(), func(b: bool): return b).keys()),
		"stats": {
			"base_money": base_money.get_val(),
			"max_health": max_health.get_val(),
			"bullets_per_shot": bullets_per_shot.get_val(),
			"fire_delay": fire_delay.get_val()
		}
	}
	
	start_game.emit()

func hackermode():
	$HackermanLabel.text = ""
	$HackermanLabel/LineEdit.text = ""
	
	$CenterContainer.hide()
	$HackermanLabel.show()
	
	var tween: Tween = $HackermanLabel.create_tween()
	tween.tween_property($HackermanLabel, "text", "\n\nconfirm execution of\nN0T_V3RY_C45H_M0N3Y.exe? [y/n]:\n", 1)
	await tween.finished
	$HackermanLabel/LineEdit.grab_focus()
	
func hackermode_preplay():
	var tween: Tween = $HackermanLabel.create_tween()
	tween.tween_property($HackermanLabel, "text", "\n\nconfirm execution of\nN0T_V3RY_C45H_M0N3Y.exe? [y/n]:\n\n\n\n\n\n\n\n\n\n\nRUNNING...", 1)
	await tween.finished
	play()


func _on_hack_enter_change(new_text: String):
	if new_text.to_lower() == "n":
		_ready()
	elif new_text.to_lower() == "y":
		hackermode_preplay()
	else:
		$HackermanLabel/LineEdit.text = ""
