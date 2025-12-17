extends Window

@onready var Preset_focus = preload("res://assets/styles/preset_focus.tres")
@onready var Preset_normal = preload("res://assets/styles/preset_normal.tres")

@onready var two_d = $"Control/Panel/VBoxContainer/Presets/HBoxContainer/2D"
@onready var three_d_tps = $"Control/Panel/VBoxContainer/Presets/HBoxContainer/3D"
@onready var three_d_fps = $"Control/Panel/VBoxContainer/Presets/HBoxContainer/3D2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Presets Dynamic Focus =========================================================
func _on_d_pressed() -> void:
	two_d.add_theme_stylebox_override("normal",Preset_focus)
	three_d_tps.add_theme_stylebox_override("normal", Preset_normal)
	three_d_fps.add_theme_stylebox_override("normal", Preset_normal)

func _on_3d_pressed() -> void:
	two_d.add_theme_stylebox_override("normal",Preset_normal)
	three_d_tps.add_theme_stylebox_override("normal", Preset_focus)
	three_d_fps.add_theme_stylebox_override("normal", Preset_normal)
	
func _on_d_3D_FPS_pressed() -> void:
	two_d.add_theme_stylebox_override("normal",Preset_normal)
	three_d_tps.add_theme_stylebox_override("normal",Preset_normal)
	three_d_fps.add_theme_stylebox_override("normal", Preset_focus)
