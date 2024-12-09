extends Menu
class_name DeadScreen

static var main_menu: PackedScene = ResourceLoader.load("res://scene/main_menu.tscn")

@onready var dead: Sprite2D = $bg/CenterContainer/dead/Sprite2D
@onready var instruction: Sprite2D = $bg/CenterContainer/instruction/Sprite2D
@onready var score_label: Label = $bg/score_container/score


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	
	dead.rotation_degrees = 2 * sin(age)
	dead.position = Vector2(cos(age), -30 + sin(age))
	
	instruction.rotation_degrees = 2 * -sin(age)
	instruction.position = Vector2(-cos(age), -sin(age))
	
	score_label.text = """
	%s
	
	Time Survived: %s
	Waves Cleared: %s
	Enemies Killed: %s
	Money Left: %s
	Money Spent: %s
	
	""" % [
		str(GlobalManager.end_of_game_data["death_msg"]),
		
		Hud.format_time(GlobalManager.end_of_game_data["time_alive"]),
		str(GlobalManager.end_of_game_data["waves_cleared"]),
		str(GlobalManager.end_of_game_data["enemies_killed"]), 
		str(GlobalManager.end_of_game_data["money"]), 
		str(GlobalManager.end_of_game_data["spent"]) 
		]
	
	if Input.is_action_just_pressed("space_action"):
		get_tree().change_scene_to_packed(main_menu)
