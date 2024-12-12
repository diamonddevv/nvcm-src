extends Node2D
class_name GameManager

static var dead_screen: PackedScene = ResourceLoader.load("res://scene/dead_screen.tscn")
static var enemy: PackedScene = ResourceLoader.load("res://obj/enemy.tscn")
static var option_selector: PackedScene = ResourceLoader.load("res://obj/option_selector.tscn")
static var label_settings: LabelSettings = ResourceLoader.load("res://resource/labels.tres")

signal wave_cleared()
signal wave_start()

@onready var hud: Hud = $HUD
@onready var player: Player = $Player
@onready var pause_ol: PauseOverlay = $Pause
@onready var camera: Camera2D = $Camera2D

var action_costs: Dictionary = {
	"shoot": 10,
	"move": 2
}

var enemy_pool: Array = []
var boss_pool: Array = []

var current_wave: Array[Enemy] = []
var next_wave_size: int = 1
var next_wave_boss: bool = false
var in_wave: bool = false
var waves_cleared: int = 0
var increase_every_x_waves: int = 3
var can_do_boss: bool = true
var boss_every_x_waves: int = 15
var screenshake_trauma: float = 0

var boss_active: bool = false
var boss_name: String = ""
var boss_max_health: float = 0.0
var boss_health: float = 0.0

func _ready():
	
	## APPLY CUSTOMISATION
	if GlobalManager.customisation:
		GlobalManager.has_set_seed = GlobalManager.customisation.get("has_seed", false)
		GlobalManager.set_seed = GlobalManager.customisation.get("seed", "")
		
		increase_every_x_waves = GlobalManager.customisation.get("wave_size_inc_freq", increase_every_x_waves)
		boss_every_x_waves = GlobalManager.customisation.get("boss_freq", boss_every_x_waves)
		
		enemy_pool = GlobalManager.customisation["enemy_pool"] if not GlobalManager.customisation["enemy_pool"].is_empty() else Enemy.behaviours.values()
		boss_pool = GlobalManager.customisation["boss_pool"]
		
		# player stats
		var stats: Dictionary = GlobalManager.customisation["stats"]
		player.money = stats["base_money"]
		player.max_health = stats["max_health"]
		player.barrels = stats["bullets_per_shot"]
		player.fire_delay = stats["fire_delay"]
		player.speed = stats["speed"]
		player.prj_damage = stats["damage"]
		
		# action costs
		action_costs = GlobalManager.customisation["action_costs"]
	else:
		enemy_pool = Enemy.behaviours.values()
		boss_pool = Enemy.boss_behaviors.values()
	
	player.health = player.max_health
	
	# reset customisation
	GlobalManager.customisation = {}
	
	# set up randomness
	if not GlobalManager.has_set_seed:
		GlobalManager.set_seed = str(hash(Time.get_unix_time_from_system()))
	seed(GlobalManager.set_seed.hash())
	
	GlobalManager.game_manager = self
	hud.player = player
	
	next_wave_boss = false
	
	hud.player.dead.connect(_on_player_die)
	wave_cleared.connect(hud.open_shop)
	wave_start.connect(hud.close_shop)
	
	create_wave(next_wave_size, player, 1 % boss_every_x_waves == 0)


func _process(delta):
	if len(current_wave) <= 0 and in_wave:
		waves_cleared += 1
		in_wave = false
		if waves_cleared % increase_every_x_waves == 0:
			next_wave_size += 1
		wave_cleared.emit()
		next_wave_boss = can_do_boss and (waves_cleared + 1) % boss_every_x_waves == 0
		on_wave_cleared(waves_cleared - 1)
		
	camera.position = 3 * Vector2(randf() - 0.5, randf() - 0.5) * screenshake_trauma
	screenshake_trauma = move_toward(screenshake_trauma, 0, delta * 5)

func _on_player_die():
	get_tree().change_scene_to_packed.call_deferred(dead_screen)


func create_wave(size: int, player: Player, boss: bool = false):
	boss_active = boss
	
	if boss:
		spawn_enemy(true)
	else:
		for i in size:
			spawn_enemy(false)
	
	wave_start.emit()
	player.timer_to_heal.start(player.dmgless_time_to_regen)
	in_wave = true
		
func on_wave_cleared(wave: int):
	if boss_active:
		boss_active = false
	
	var opt_nodes: Array[Node] = []
	
	player.health += 25
	player.money += 80 * (1 + player.combo)
	
	for i in 3:
		var opt: OptionSelector = option_selector.instantiate()
		opt.selected.connect(func():
			opt.function.call()
			for n in opt_nodes:
				n.queue_free()
			create_wave(next_wave_size, player, next_wave_boss)
			)
			
		opt.global_position = Vector2(-1000 + 1000 * i, 0)
		get_tree().current_scene.add_child(opt)
		
		if i == 1:
			var cash: int = randi_range(5, 30) * pow(1.05, (waves_cleared + 1) * 3)
			opt.set_option("Gain %s cash" % cash, 0.1, func():
				player.money += cash
			)
		else:
			opt.pick_upgrade_option(player, 0.5)
		
		opt_nodes.append(opt)
		
	var label := Label.new()
	label.global_position = Vector2(-420, -800)
	label.label_settings = label_settings
	get_tree().current_scene.add_child(label)
	label.scale = Vector2.ONE * 4
	label.create_tween().tween_property(label, "text", "Pick an option", 1)
	opt_nodes.append(label)
	
func spawn_enemy(boss: bool = false) -> Enemy:
	var unit: Enemy = enemy.instantiate()
	var spawn_pos := Vector2(randi_range(-1800, 1800), randi_range(-800, 800)) if not boss else Vector2.ZERO
	
	unit.dead.connect(func(): current_wave.erase(unit))
	unit.global_position = spawn_pos
	unit.target = player
	unit.assign_random_behaviour(boss)
	
	get_tree().current_scene.add_child.call_deferred(unit)
	current_wave.append(unit)
	
	return unit
	

func add_screenshake(trauma: float):
	if GlobalManager.save_data.screenshake:
		screenshake_trauma += trauma
		trauma = min(trauma, 5)
