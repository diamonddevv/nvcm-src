extends Resource
class_name AiPattern

@export var is_boss: bool = false
@export var enemy_name: String = ""
@export var speed: int = 1000
@export var max_health: float = 100
@export var aggression: float = 0.5
@export var fire_rate: float = 0.5
@export var damage: float = 10
@export var shots: int = 10
@export var spread: float = 25
@export var reload_time: float = 1
@export var explo_power: float = 0.0
@export var explo_freq: float = 0.0
@export var sprite_idx: int = 0

func should_focus_attack(health: float, rand_aggression_mod: float) -> bool:
	return (health / max_health) * aggression > rand_aggression_mod

func get_accuracy() -> float:
	return randf_range(-100, 100) * aggression

func should_summon_minions(health: float, waves_cleared: int) -> int:
	if not is_boss:
		return 0
	
	if (health / max_health) > 0.5 / aggression * 1.2:
		return 0
	
	var chance: float = aggression / waves_cleared / 48
	chance = 1
	if randf() > chance:
		return 0
	
	print("spawning..")
	return min(5, roundi(1 / (health / max_health) * aggression / 2))
