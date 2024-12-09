extends Node2D
class_name OptionSelector

signal selected()

@onready var label: Label = $Label
@onready var timer: Timer = $WaitTimer

var timer_ended: bool = false
var function: Callable = func(): pass

static var caller := OptionSelector.new()
static var upgrade_options: Array = []

func _ready() -> void:
	timer_ended = false
	timer.timeout.connect(func(): timer_ended = true)


func set_label_text(text: String, time: float):
	label.text = ""
	create_tween().tween_property(label, "text", text, time)

static func get_upgrade_data(player: Player):
	var opt: Dictionary = upgrade_options.pick_random()
	var value: float = randf_range(opt["min"], opt["max"])
	
	var concat_value: bool = opt.get("concat_value", true)
	var f = func(value: float): caller.call(opt["func"], player, value)
	
	return {
		"text": (opt["text"] % roundi(value)) if concat_value else opt["text"],
		"func": f,
		"cost": opt["cost"],
		"value": value
	}

func pick_upgrade_option(player: Player, text_time: float):
	var data: Dictionary = get_upgrade_data(player)
	
	set_label_text(data["text"], text_time)
	function = (data["func"] as Callable).bind(data["value"])
	
func set_option(text: String, text_time: float, callable: Callable):
	set_label_text(text, text_time)
	function = callable

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and timer_ended:
		selected.emit()


# upgrades functions
func upgrade_spread(player: Player, value: float):
	player.spread *= (1 - (value / 100))
	
func upgrade_spread_up(player: Player, value: float):
	player.spread *= (1 + (value / 100))
	
func upgrade_dmg_percent(player: Player, value: float):
	player.prj_damage *= (1 + (value / 100))
	
func upgrade_max_health_percent(player: Player, value: float):
	player.max_health *= (1 + (value / 100))
	
func upgrade_speed_percent(player: Player, value: float):
	player.speed *= (1 + (value / 100))
	
func upgrade_barrel(player: Player, value: float):
	player.barrels += roundi(value)

func upgrade_fire_rate(player: Player, value: float):
	player.fire_delay *= (1 - (value / 100))

func upgrade_regen(player: Player, value: float):
	player.regeneration *= (1 + (value / 100))
	
func upgrade_combo_retain_chance(player: Player, value: float):
	player.combo_retain_chance *= (1 + (value / 100))

func upgrade_combo_timer(player: Player, value: float):
	player.combo_timer_length *= (1 + (value / 100))
	
func upgrade_explo_power(player: Player, value: float):
	player.explosion_power *= (1 + (value / 100))
	
func upgrade_explo_freq(player: Player, value: float):
	player.explosion_freq += min(0.8, value / 100)
	
func upgrade_dmg_reduction(player: Player, value: float):
	player.base_damage_reduction *= (1 + (value / 100))
	
func heal(player: Player, value: float):
	player.health += value
