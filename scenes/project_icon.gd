extends Control

@export var project_name : String
@export var project_icon : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/VBoxContainer/Panel/VBoxContainer/Spacer/ProjectName.text = project_name
	$Panel/VBoxContainer/Panel/VBoxContainer/Icon/TextureButton.texture_normal = load(project_icon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
