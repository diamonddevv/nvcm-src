extends CanvasLayer
class_name Hud

static var money_particle: PackedScene = ResourceLoader.load("res://obj/particles/hud_money_particle.tscn")

@onready var low_health_warning_label: Label = $LowHealthWarning
@onready var money_label: MoneyLabel = $Panel/MarginContainer/VBoxContainer/MoneyLabel
@onready var health_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/HealthBar
@onready var boss_health_bar: ProgressBar = $BossHealthBar
@onready var boss_health_bar_label: Label = $BossHealthBar/Label
@onready var kills: Label = $Panel/Kills
@onready var combo: Label = $Panel/Combo
@onready var timer: Label = $Panel/Timer
@onready var combo_bar: ProgressBar = $Panel/Combo/Bar
@onready var shop_panel: Panel = $ShopPanel
@onready var shop_panel_text: Label = $ShopPanel/Label
@onready var shop_panel_hbox: HBoxContainer = $ShopPanel/HBoxContainer

var player: Player

var age: float = 0

var items_bought: int = 0
var shop_open_close_length: float = 0.25
var last_health: float = 100
var last_boss_health: float = 0
var last_money: int = 1000


func _process(delta):
	age += delta
	
	boss_health_bar.visible = GlobalManager.game_manager.boss_active
	if GlobalManager.game_manager.boss_active:
		boss_health_bar_label.text = GlobalManager.game_manager.boss_name
		boss_health_bar.max_value = GlobalManager.game_manager.boss_max_health
		
		create_tween().tween_property(
			boss_health_bar, "value", GlobalManager.game_manager.boss_health, 0.1).set_ease(Tween.EASE_OUT)
	
	shop_panel_text.rotation_degrees = 4 * sin(age)
	shop_panel_text.position = Vector2(364, 14) + Vector2(cos(age), sin(age))
	
	if player:
		timer.text = format_time(player.time_alive)
		
		if not GlobalManager.game_manager.in_wave:
			timer.text += "\nNext Wave Size: %s" % ("???" if GlobalManager.game_manager.next_wave_boss else GlobalManager.game_manager.next_wave_size)
		
		kills.text = "%s Kills" % player.kills if player.kills != 1 else "1 Kill"
		kills.text += " | Wave %s" % str(GlobalManager.game_manager.waves_cleared + 1)
		combo.text = "%sx Combo!" % player.combo
		combo.visible = player.combo != 0
		combo_bar.value = player.timer_combo.time_left
		combo_bar.max_value = player.timer_combo.wait_time
		
		if last_money > player.money and GlobalManager.save_data.game_money_particles:
			for i in min(last_money - player.money, 1000):
				var p: CPUParticles2D = money_particle.instantiate()
				p.finished.connect(func(): p.queue_free())
				p.global_position = Vector2(390, 750)
				add_child(p)
				p.emitting = true
		
		money_label.amount = player.money
		health_bar.max_value = player.max_health
		create_tween().tween_property(health_bar, "value", player.health, 0.1).set_ease(Tween.EASE_OUT)
		
		if player.health < last_health:
			health_bar.position = 2 * Vector2(randf() - 0.5, randf() - 0.5) * min(last_health - health_bar.value, 5)
		last_health = move_toward(last_health, player.health, 10 * delta)
		
		last_money = player.money
		
		if player.money <= 100:
			money_label.label.self_modulate = Color.RED
			money_label.position = Vector2(0, 30) + 4 * Vector2(randf() - 0.5, randf() - 0.5)
		else:
			money_label.label.self_modulate = Color.WHITE
			money_label.position = Vector2(0, 30)


func open_shop():
	boss_health_bar.visible = false
	
	var tween: Tween = shop_panel.create_tween()
	tween.tween_property(shop_panel, "position", Vector2(0, 0), shop_open_close_length).set_ease(Tween.EASE_OUT)
	
	for i in 3:
		var button: ShopButton = shop_panel_hbox.get_child(i)
		button.player = player
		
		var data: Dictionary = {}
		if i == 1:
			data = {
				"text": "Heal 40 health",
				"value": 40,
				"cost": 25,
				"func": func(_v): OptionSelector.caller.heal(player, 40)
			}
		else:
			data = OptionSelector.get_upgrade_data(player)
		
		var function: Callable = func(value): 
			items_bought += 1
			data["func"].call(value)
		button.set_values(data["text"], data["value"], min(8500, data["cost"] * pow(1.15, items_bought)), function)
	
	if player.health / player.max_health <= 0.35:
		low_health_warning_label.text = "You are at %.1f%% health." % ((player.health / player.max_health) * 100)
		low_health_warning_label.show()

func close_shop():
	low_health_warning_label.hide()
	
	var tween: Tween = shop_panel.create_tween()
	tween.tween_property(shop_panel, "position", Vector2(0, -shop_panel.size.y), shop_open_close_length).set_ease(Tween.EASE_OUT)

static func format_time(secs: float) -> String:
	var sekuntia: int = roundi(secs)
	
	var r_secs := (sekuntia) % 60
	var r_mins := sekuntia / 60
	
	return "%02d:%02d" % [r_mins, r_secs]
