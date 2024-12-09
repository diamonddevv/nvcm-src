extends Button
class_name ShopButton

@onready var money_label: MoneyLabel = $MoneyLabel
@onready var sound: AudioStreamPlayer = $SelectSound

var shake: float = 0.0

var player: Player
var cost: int
var value: float
var function: Callable = func(): pass

var def_pos := Vector2.INF

func set_values(txt: String, p_value: float, p_cost: int, p_function: Callable):
	text = txt
	value = p_value
	cost = p_cost
	function = p_function
	disabled = false
	visible = true
	
	money_label.amount = cost

func _process(delta: float) -> void:
	if def_pos == Vector2.INF:
		def_pos = position
	position = def_pos + (2 * Vector2(randf() - 0.5, randf() - 0.5) * min(shake, 5))
	shake = move_toward(shake, 0, 10 * delta)

func _on_pressed() -> void:
	if player.money >= cost:
		sound.pitch_scale = randf_range(0.8, 1.4)
		sound.play()
		
		function.call(value)
		disabled = true
		visible = false
		player.spend(cost)
	else:
		shake += 2
