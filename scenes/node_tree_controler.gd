extends Control


func show_only_selected_sprite(selected_sprite : String):
	for child in self.get_children():
		if child.name == selected_sprite:
			child.visible = true
		else:
			child.visible = false

func create_new_sprite_with_name(sprite_name : String):
	var code = preload("res://scenes/node_tree.tscn")
	var new_code = code.instantiate()
	new_code.name = sprite_name
	new_code.visible = false
	self.add_child(new_code)

func rename_existing_sprite(rename_from : String, rename_to : String):
	var all_children = self.get_children()
	for child in all_children:
		if child.name == rename_from:
			child.name = rename_to
			child.code_name(rename_to)

func open_sprite(sprite_name : String):
	var all_children = self.get_children()
	var found_child = false
	for child in all_children:
		if child.name == sprite_name:
			found_child = true
	if found_child:
		show_only_selected_sprite(sprite_name)
	else:
		create_new_sprite_with_name(sprite_name)
		show_only_selected_sprite(sprite_name)
	Global.current_working_sprite = sprite_name

func load_sprite_node_content(sprite_name : String, Dict : Dictionary):
	var all_children = self.get_children()
	print("searching for matching children!")
	for child in all_children:
		if child.name == sprite_name:
			print("loading project file")
			child.load_tree_data(Dict)
