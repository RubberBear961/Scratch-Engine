extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func show_only_selected_code(selected_code : String):
	for child in self.get_children():
		child.visible = (child.name == selected_code)

func create_new_code_with_name(code_name : String):
	var code = preload("res://scenes/code.tscn")
	var new_code = code.instantiate()
	new_code.name = code_name
	self.add_child(new_code)
