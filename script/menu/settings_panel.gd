extends Panel
class_name SettingsPanel

@onready var master_volume_slider: HSlider = $CenterContainer/VBoxContainer/MasterVolume/Slider
@onready var music_volume_slider: HSlider = $CenterContainer/VBoxContainer/MusicVolume/Slider

func _ready():
	master_volume_slider.value = GlobalManager.save_data.master_volume * master_volume_slider.max_value
	music_volume_slider.value = GlobalManager.save_data.music_volume * music_volume_slider.max_value

func save():
	GlobalManager.save_data.master_volume = master_volume_slider.value / master_volume_slider.max_value
	GlobalManager.save_data.music_volume = music_volume_slider.value / music_volume_slider.max_value
	
	GlobalManager.apply_settings()
