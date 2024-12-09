extends CharacterBody2D
class_name Unit

signal dead()

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_fire: AudioStreamPlayer = $FireSound
@onready var sfx_hurt: AudioStreamPlayer = $HurtSound
@onready var sfx_die: AudioStreamPlayer = $DieSound
@onready var timer_shoot: Timer = $ShotTime
@onready var timer_invincible: Timer = $InvicibilityTime
@onready var timer_regen: Timer = $RegenTimer
@onready var timer_to_heal: Timer = $HealTimer

static var projectile: PackedScene = ResourceLoader.load("res://obj/projectile.tscn")
static var die_particle: PackedScene = ResourceLoader.load("res://obj/particles/die_particle.tscn")

@export var speed: float = 1000
@export var fire_delay: float = 0.5
@export var max_health: float = 100
@export var invincibility_time: float = 0.1
@export var prj_damage: float = 10
@export var spread: float = 25
@export var barrels: int = 1
@export var regeneration: int = 3
@export var dmgless_time_to_regen: float = 16
@export var explosion_freq: float = 0.0
@export var explosion_power: float = 0.5
@export var base_damage_reduction: float = 0.0

var health: int = 0

var time_alive: float = 0

var _can_fire: bool = true
var _can_hurt: bool = true
var _can_heal: bool = true

func _ready():
	time_alive = 0
	health = max_health
	dmgless_time_to_regen = 5
	
	timer_shoot.timeout.connect(func(): _can_fire = true)
	timer_invincible.timeout.connect(func(): _can_hurt = true)
	timer_to_heal.timeout.connect(func(): _can_heal = true)
	timer_regen.timeout.connect(func(): 
		if _can_heal and GlobalManager.game_manager and GlobalManager.game_manager.in_wave:
			health += regeneration
			)

func _physics_process(delta: float):
	do_movement(delta)
	move_and_slide()
	
func _process(delta: float):
	time_alive += delta
		
	health = min(health, max_health)
	


func fire():
	for i in barrels:
		var prj: Projectile = projectile.instantiate()
		
		var sprd := randf_range(-spread / 2, spread / 2)
		var deg_dir := deg_to_rad((rotation_degrees + sprd) - 90)
		
		prj.direction = Vector2(cos(deg_dir), sin(deg_dir))
		prj.global_position = global_position
		prj.damage = prj_damage
		prj.creator = self
		
		if randf() < explosion_freq:
			prj.explode = true
			prj.explosion_power = explosion_power * randf()
		
		prepare_projectile(prj)
		
		get_tree().current_scene.add_child(prj)
		
		sfx_fire.pitch_scale = randf_range(0.8, 1.2)
		sfx_fire.play()
		
		_can_fire = false
		timer_shoot.start(fire_delay)
	
	after_shoot()

func damage(attacker: Unit, damage: float):
	if _can_hurt:
		health -= damage
		
		_can_heal = false
		timer_to_heal.start(dmgless_time_to_regen)
		
		_can_hurt = false
		on_hurt(attacker if is_instance_valid(attacker) else null, damage)

		if health <= 0:
			on_die(attacker if is_instance_valid(attacker) else null)
			dead.emit()
			
			if self is not Player:
				var dpart: CPUParticles2D = die_particle.instantiate()
				dpart.global_position = global_position
				dpart.finished.connect(func(): dpart.queue_free())
				get_tree().current_scene.add_child(dpart)
				dpart.emitting = true
		else:
			timer_invincible.start(invincibility_time)
			flash_sprite(4)
			
			sfx_hurt.pitch_scale = randf_range(0.8, 1.2)
			sfx_hurt.play()
		
		
		#damage_recoil(projectile, 12 * damage)

func do_movement(delta: float):
	pass
	
func on_die(killer: Unit):
	pass

func on_hurt(hurter: Unit, amount: float):
	pass

func prepare_projectile(projectile: Projectile):
	pass
	
func after_shoot():
	pass

func flash_sprite(count: int):
	for i in count:
		sprite.self_modulate.a = 0.0
		if get_tree(): await get_tree().process_frame
		sprite.self_modulate.a = 1.0
		if get_tree(): await get_tree().process_frame
	sprite.self_modulate.a = 1.0

func damage_recoil(projectile: Projectile, strength: float):
	position += projectile.direction * strength
	move_and_slide()
