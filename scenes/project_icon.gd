extends Control

@export var project_name : String
@export var project_path : String
@export var project_icon : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/VBoxContainer/Panel/VBoxContainer/Spacer/ProjectName.text = project_name
	$Panel/VBoxContainer/Panel/VBoxContainer/Icon/TextureButton.texture_normal = load(project_icon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_edit_pressed() -> void:
	Global.current_working_project_name = project_name
	Global.current_working_project_path = project_path
	get_tree().change_scene_to_file("res://scenes/main.tscn")
