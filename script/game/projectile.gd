extends Node2D
class_name Projectile

@onready var sprite: Sprite2D = $Sprite2D
@onready var texture: AtlasTexture = sprite.texture as AtlasTexture

var is_enemy: bool = false
var speed: float = 3000
var damage: float = 0
var direction: Vector2 = Vector2.ZERO
var creator: Node2D = null
var explode: bool = false
var explosion_power: float = 0.75


func _ready():
	sprite.texture = texture.duplicate()
	texture = sprite.texture
	if is_enemy:
		texture.region = Rect2(36, 0, 8, 8)

func _process(delta: float):
	position += direction.normalized() * speed * delta
	rotation_degrees += 5 * delta

func _hit_something(body: Node2D):
	if body != creator:
		if is_enemy and body is Enemy:
			return
			
		if explode:
			Explosion.explode(global_position, explosion_power, creator if is_instance_valid(creator) else null)
		elif body is Unit:
			body.damage(creator if is_instance_valid(creator) else null, damage)
		
		self.queue_free()
