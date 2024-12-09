extends Node2D
class_name Explosion

static var pckd: PackedScene = ResourceLoader.load("res://obj/explosion.tscn")

@onready var area: Area2D = $Area2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var sfx_explode: AudioStreamPlayer = $SfxExplode

var creator: Unit = null
var power: float = 0.0

func _ready() -> void:
	sfx_explode.pitch_scale = randf_range(0.8, 1.2)
	sfx_explode.play()
	
	particles.finished.connect(func(): queue_free())
	particles.emitting = true
	GlobalManager.game_manager.add_screenshake(power * 2)
	

static func explode(pos: Vector2, power: float, p_creator: Unit):
	var explo: Explosion = pckd.instantiate()
	explo.global_position = pos
	explo.power = power
	explo.creator = p_creator
	
	explo.scale *= power
	
	if p_creator:
		p_creator.get_tree().current_scene.add_child.call_deferred(explo)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == creator:
		return
	
	if body is Unit:
		body.damage(body, 20 * power)
