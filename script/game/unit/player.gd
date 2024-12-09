extends Unit
class_name Player

@onready var timer_combo: Timer = $ComboTimer
@onready var sfx_lost_combo: AudioStreamPlayer = $LostComboSound
@onready var sfx_money: AudioStreamPlayer = $GainMoneySound
@onready var sfx_combo_build: AudioStreamPlayer = $ComboBuildSound

@export var combo_retain_chance: float = 0.2
@export var combo_timer_length: float = 1.5

var kills: int = 0
var money: float = 1000
var spent: float = 0
var combo: int = 0

var _moving: bool = false

func _ready():
	super._ready()
	kills = 0

func _process(delta):
	super._process(delta)
	
	if Input.is_action_pressed("shoot") and _can_fire and GlobalManager.game_manager.in_wave:
		if money - GlobalManager.action_costs["shoot"] >= 0:
			fire()
			
func do_movement(delta: float):
	var movevec := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	look_at(get_global_mouse_position())
	
	if money < GlobalManager.action_costs["move"]:
		# no move if no money lolsies
		_moving = false
		
		# just die
		kill()
		return
	
	if movevec.length_squared() != 0:
		_moving = true
	else:
		_moving = false
		
	rotation_degrees += 90
	position += movevec * speed * delta

func after_shoot():
	spend(GlobalManager.action_costs["shoot"])

func on_die(killer: Unit):
	var enemy_name: String = ""
	if killer is Enemy:
		enemy_name = killer.behaviour.enemy_name
	
	GlobalManager.end_of_game_data = {
		"death_msg": "You ran out of money." if money <= GlobalManager.action_costs["move"] else ("Killed by %s." % enemy_name if enemy_name != "" else "You stopped living, some way or another."),
		"enemies_killed": kills,
		"waves_cleared": GlobalManager.game_manager.waves_cleared,
		"time_alive": time_alive,
		"money": money,
		"spent": spent
	}
	
func on_kill(killed: Enemy):
	kills += 1
	
	var reward: int = killed.kill_reward * (1 + combo) * (5 if killed.behaviour.is_boss else 1)
	money += reward
	
	sfx_money.pitch_scale = randf_range(0.6, 1.4)
	sfx_money.play()
	
	if combo > 3:
		sfx_combo_build.pitch_scale = min(1 + (combo - 3) / 2, 3) * randf_range(0.8, 1.2)
		sfx_combo_build.play()
	
	timer_combo.start(combo_timer_length * (5 / (combo + 1)))
	combo += 1

func on_hurt(attacker: Unit, dmg: float):
	if randf() > combo_retain_chance:
		_on_combo_end()

func _on_walk_timer_timeout() -> void:
	if _moving:
		spend(GlobalManager.action_costs["move"])


func _on_combo_end():
	timer_combo.stop()
	if combo > 3:
		sfx_lost_combo.pitch_scale = randf_range(0.8, 1.2)
		sfx_lost_combo.play()
	combo = 0

func spend(amnt: int):
	money -= amnt
	spent += amnt

func kill():
	on_die(null)
	dead.emit()
