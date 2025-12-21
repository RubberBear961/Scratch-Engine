extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func show_only_selected_code(selected_code : String):
	for child in self.get_children():
		print(child.name)
		print(selected_code)
		if child.name == selected_code:
			child.visible = true
		else:
			child.visible = false

func create_new_code_with_name(code_name : String):
	var code = preload("res://scenes/code.tscn")
	var new_code = code.instantiate()
	new_code.code_name(code_name)
	new_code.name = code_name
	new_code.visible = false
	self.add_child(new_code)

func rename_existing_code(rename_from : String, rename_to : String):
	print("Renaming from -> " + rename_from)
	var all_children = self.get_children()
	for child in all_children:
		if child.name == rename_from:
			child.name = rename_to
			child.code_name(rename_to)

func open_script(script_name : String):
	var all_children = self.get_children()
	var found_child = false
	for child in all_children:
		if child.name == script_name:
			found_child = true
	if found_child:
		show_only_selected_code(script_name)
	else:
		create_new_code_with_name(script_name)
		show_only_selected_code(script_name)
	Global.current_working_script = script_name
