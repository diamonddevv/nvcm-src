extends Node

const UPGRADE_OPTIONS_PATH: String = "res://asset/data/upgrade_options.json"

var save_data: SaveData
var game_manager: GameManager

var has_set_seed: bool = false
var set_seed: String = ""
var customisation: Dictionary = {}

var end_of_game_data := {}

@onready var global__music_stream: AudioStreamPlayer = $/root/Global/MusicStream


func _ready():
	#######################################
	# This code runs when the game boots. #
	#######################################
	
	# load save data
	save_data = SaveData.load_save()
	apply_settings()
	
	# load upgrade options
	OptionSelector.upgrade_options = JSON.parse_string(FileAccess.open(UPGRADE_OPTIONS_PATH, FileAccess.READ).get_as_text())["options"]


func apply_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(save_data.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(save_data.music_volume))
	$/root/Global/CRTShaderPass.visible = save_data.crt_shader
	
	save_data.save()
