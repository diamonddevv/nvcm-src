extends Unit
class_name Enemy

@onready var timer_reload: Timer = $ReloadTimer
@onready var timer_ai: Timer = $AiTimer
@onready var time_since_minions: Timer = $MinionTimer
@onready var sfx_spawn_minion: AudioStreamPlayer = $SpawnMinionSound

@export var kill_reward: int = 100
@export var behaviour: AiPattern = null

var target_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var has_moved: bool = true

var random_aggresiveness_modifier: float

var can_spawn_minions: bool = true
var minions_spawned: int = 0
var minions_active: int = 0

var target: Player = null
var shots_left: int = 0
var reloading: bool = false

static var behaviours := {
	"Normal": 		ResourceLoader.load("res://resource/ais/normal.tres"),
	"Aggressive": 	ResourceLoader.load("res://resource/ais/aggressive.tres"),
	"Powerhouse": 	ResourceLoader.load("res://resource/ais/powerhouse.tres"),
	"Skittish": 	ResourceLoader.load("res://resource/ais/skittish.tres"),
	"Spray n' Pray":	ResourceLoader.load("res://resource/ais/spray_and_pray.tres")
}

static var boss_behaviors := {
	"King Grayscale": ResourceLoader.load("res://resource/ais/king_grayscale.tres"),
	"Big Boom": ResourceLoader.load("res://resource/ais/big_boom.tres")
}

func _ready():
	super._ready()
	sprite.texture = sprite.texture.duplicate()
	(sprite.texture as AtlasTexture).region = Rect2(9 * behaviour.sprite_idx, 27, 8, 8)
	
	if behaviour.is_boss:
		dead.connect(func(): GlobalManager.game_manager.boss_active = false)
	
	random_aggresiveness_modifier = randf()
	spawn_effect()
	
	shots_left = behaviour.shots
	timer_ai.start(behaviour.aggression * random_aggresiveness_modifier * 2)

func on_die(killer: Unit):
	if killer is Player:
		killer.on_kill(self)
	queue_free()

func assign_random_behaviour(boss: bool = false):
	behaviour = (GlobalManager.game_manager.enemy_pool if (not boss or GlobalManager.game_manager.boss_pool.is_empty()) else GlobalManager.game_manager.boss_pool).pick_random().duplicate()
	assign_behaviour(behaviour)
		
func assign_behaviour(behaviour: AiPattern):
	regeneration = 1
	dmgless_time_to_regen = 8
	max_health = behaviour.max_health
	speed = behaviour.speed
	fire_delay = behaviour.fire_rate
	prj_damage = behaviour.damage / 2 * pow(1.12, GlobalManager.game_manager.waves_cleared)
	spread = behaviour.spread
	explosion_power = behaviour.explo_power
	explosion_freq = behaviour.explo_freq
	
	if behaviour.is_boss:
		max_health *= float(GlobalManager.game_manager.waves_cleared / 16.0)
	

func _process(delta):
	super._process(delta)
	if behaviour.is_boss:
		GlobalManager.game_manager.boss_max_health = max_health
		GlobalManager.game_manager.boss_health = health
		GlobalManager.game_manager.boss_name = behaviour.enemy_name

	
func spawn_effect():
	scale = Vector2(32, 32) if not behaviour.is_boss else Vector2(256, 256)
	
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "scale", 
	Vector2(16, 16) if not behaviour.is_boss else Vector2(64, 64), 
	0.5 if not behaviour.is_boss else 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", TAU, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	await tween.finished

func prepare_projectile(p: Projectile):
	p.is_enemy = true

func do_movement(delta: float):
	var direction_to_player: Vector2 = global_position.direction_to(
		target.global_position + Vector2(behaviour.get_accuracy(), behaviour.get_accuracy())
		)
	
	rotation = atan2(direction_to_player.y, direction_to_player.x) + deg_to_rad(90)
	if _can_fire and not reloading:
		if shots_left > 0:
			fire()
			shots_left -= 1
		else:
			reload()
			
	
	if not has_moved:
		has_moved = true
		var tween: Tween = create_tween()
		target_position = position
		tween.tween_property(
			self, "target_position", target_direction * behaviour.speed * delta * 10, 0.1
		).set_ease(Tween.EASE_OUT).as_relative()
		
	position += (target_position - position).normalized() * behaviour.speed * delta
		
func reload():
	timer_reload.start(behaviour.reload_time * randf_range(0.8, 1.5))
	reloading = true
	await timer_reload.timeout
	shots_left = behaviour.shots
	reloading = false


func _on_ai_timer_timeout() -> void:
	var direction_to_player: Vector2 = global_position.direction_to(
		target.global_position + Vector2(behaviour.get_accuracy(), behaviour.get_accuracy())
		).normalized()
	
	var aggression_randomness: float = behaviour.aggression * random_aggresiveness_modifier
	
	target_direction = Vector2(
		(randf() - 0.5) * (direction_to_player.x - 0.75 + aggression_randomness),
		(randf() - 0.5) * (direction_to_player.y - 0.75 + aggression_randomness)
	).normalized()
	has_moved = false
	
	timer_ai.start(max(0.5, aggression_randomness * 5))
	
	if minions_active == 0 and not can_spawn_minions:
		time_since_minions.start()
	
	if minions_active <= 0 and minions_spawned <= 8 * pow(1.24, GlobalManager.game_manager.waves_cleared) and can_spawn_minions:
		var minions: int = behaviour.should_summon_minions(health, GlobalManager.game_manager.waves_cleared)
		if minions > 0:
			spawn_minions(minions, func(): minions_active -= 1)
			minions_active = minions
			minions_spawned += minions
			can_spawn_minions = false

func spawn_minions(count: int, die_act: Callable = func(): pass):
	sfx_spawn_minion.pitch_scale = randf_range(0.8, 1.2)
	sfx_spawn_minion.play()
	for i in count:
		var e: Enemy = GlobalManager.game_manager.spawn_enemy(false)
		e.dead.connect(die_act)


func _on_minion_timer_timeout() -> void:
	can_spawn_minions = true
