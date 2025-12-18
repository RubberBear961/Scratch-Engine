extends Control

@onready var create_new_project_window = $"Create new"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_new_project_window.hide()
	$"Create new".load_all_projects()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_window_close_requested() -> void:
	create_new_project_window.hide()


func _on_create_new_pressed() -> void:
	create_new_project_window.show()
