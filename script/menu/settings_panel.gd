extends Panel
class_name SettingsPanel

signal close()

@onready var master_volume_slider: HSlider = $CenterContainer/VBoxContainer/MasterVolume/Slider
@onready var music_volume_slider: HSlider = $CenterContainer/VBoxContainer/MusicVolume/Slider
@onready var menu_particles: CheckButton = $CenterContainer/VBoxContainer/MenuParticles/CheckButton
@onready var crt_shader: CheckButton = $CenterContainer/VBoxContainer/CRTShader/CheckButton

func _ready():
	master_volume_slider.value = GlobalManager.save_data.master_volume * master_volume_slider.max_value
	music_volume_slider.value = GlobalManager.save_data.music_volume * music_volume_slider.max_value
	menu_particles.button_pressed = GlobalManager.save_data.menu_particles
	crt_shader.button_pressed = GlobalManager.save_data.crt_shader

func save():
	GlobalManager.save_data.master_volume = master_volume_slider.value / master_volume_slider.max_value
	GlobalManager.save_data.music_volume = music_volume_slider.value / music_volume_slider.max_value
	GlobalManager.save_data.menu_particles = menu_particles.button_pressed
	GlobalManager.save_data.crt_shader = crt_shader.button_pressed
	
	GlobalManager.apply_settings()
	close.emit()
