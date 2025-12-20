extends Control

var Mode = "2D"
var active = preload("res://assets/styles/selected_mode.tres")
var normal = preload("res://assets/styles/normal_state_mode.tres")

@onready var project_nodes = $GUI/Content/left_panel/ProjectNodes/Inside/ItemList
@onready var project_files = $GUI/Content/left_panel/ProjectFiles/Inside/ItemList

# Called when the node enters the scene tree for the first time.

func color_list_positions():
	var colors = ["#202020", "#1f1f1f"]
	for i in range(project_nodes.get_item_count()):
		project_nodes.set_item_custom_bg_color(i, colors[i % 2])
	for i in range(project_files.get_item_count()):
		project_files.set_item_custom_bg_color(i, colors[i % 2])


func _ready() -> void:
	$"GUI/Main Categories/ViewPorts/2D".add_theme_stylebox_override("normal", active)
	$"GUI/Settings etc/HBoxContainer/File".get_popup().id_pressed.connect(_on_menu_button_pressed)
	$"Project Settings".hide()

func check_focus():
	for child in $GUI/Content/ViewPort.get_children():
		if child.name == Global.focus:
			child.visible = true
		else:
			child.visible = false
	for child in $"GUI/Main Categories/ViewPorts".get_children():
		if child.name == Global.focus:
			child.add_theme_stylebox_override("normal", active)
		else:
			child.add_theme_stylebox_override("normal", normal)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_focus()

func _on_3d_pressed() -> void:
	Global.focus = "3D"

func _on_2d_pressed() -> void:
	Global.focus = "2D"

func _on_code_pressed() -> void:
	Global.focus = "CODE"
	

# Handling Main Options ====================================================================

func _on_menu_button_pressed(id : int) -> void:
	match id:
		0: $"Project Settings".show()
		1: $SaveManager.save_script()


func _on_project_settings_close_requested() -> void:
	$"Project Settings".hide()
