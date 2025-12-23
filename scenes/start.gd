extends Control

@onready var create_new_project_window = $"Create new"
@onready var Delete_menu = $"Delete Menu"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_new_project_window.hide()
	$"Create new".load_all_projects()


# Called every frame. 'delta' is the elapsed time since the previous frame.
	#print(get_global_mouse_position())
	#print(get_viewport().get_mouse_position())
	#print(DisplayServer.window_get_position())

func _on_window_close_requested() -> void:
	create_new_project_window.hide()


func _on_create_new_pressed() -> void:
	create_new_project_window.show()

func _on_h_flow_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_pos = event.position
		for child in $"VBoxContainer/ProjectsTab/VBoxContainer/ScrollContainer/HFlowContainer".get_children():
			if child.get_global_rect().has_point(mouse_pos):
				var mouse_position = get_global_mouse_position()
				var window_position = DisplayServer.window_get_position()
				var popup_position = Vector2(mouse_position) + Vector2(window_position)
				Delete_menu.popup(Rect2(popup_position,Delete_menu.size))
