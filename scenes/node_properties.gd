extends PanelContainer

@onready var main_viewport = $"../../ViewPort/2D"

@onready var position_x = $Inside/Position/Position/HBoxContainer/LineEdit
@onready var position_y = $Inside/Position/Position/HBoxContainer2/LineEdit
@onready var size_x = $Inside/Size/Position/HBoxContainer/LineEdit
@onready var size_y = $Inside/Size/Position/HBoxContainer2/LineEdit

func _display_properties():
	var properties = main_viewport.get_properties_from_selected_node_in_sprite(Global.current_working_sprite)
	print(properties)
	position_x.text = str(properties["position"]["x"])
	position_y.text = str(properties["position"]["y"])
	size_x.text = str(properties["size"]["x"])
	size_y.text = str(properties["size"]["y"])
