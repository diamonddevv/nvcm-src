extends Resource
class_name SaveData

const SAVE_LOCATION: String = "user://save_data.tres"

@export_category("Settings")
@export var master_volume: float = 1.0
@export var music_volume: float = 1.0
@export var menu_particles: bool = true
@export var crt_shader: bool = true

@export_category("High Scores")
@export var highest_floor_reached: int = -1

func save():
	print("Saving..")
	ResourceSaver.save(self, SAVE_LOCATION)
	print("Saved.")

static func load_save() -> SaveData:
	if not ResourceLoader.exists(SAVE_LOCATION):
		print("No save file existed, making one..")
		SaveData.new().save()
		print("Save file made at %s." % ProjectSettings.localize_path(SAVE_LOCATION))
	
	print("Loading save data..")
	return ResourceLoader.load(SAVE_LOCATION) as SaveData
