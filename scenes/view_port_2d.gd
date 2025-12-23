extends Control


func show_only_selected_sprite(selected_sprite : String):
	for child in self.get_children():
		if child.name == selected_sprite:
			child.visible = true
		else:
			child.visible = false

func create_new_sprite_with_name(sprite_name : String):
	var code = preload("res://scenes/2D.tscn")
	var new_code = code.instantiate()
	new_code.name = sprite_name
	new_code.visible = false
	self.add_child(new_code)

func rename_existing_sprite(rename_from : String, rename_to : String):
	var all_children = self.get_children()
	for child in all_children:
		if child.name == rename_from:
			child.name = rename_to

func open_sprite(sprite_name : String):
	var all_children = self.get_children()
	var found_child = false
	for child in all_children:
		if child.name == sprite_name:
			found_child = true
	if found_child:
		show_only_selected_sprite(sprite_name)
		var new_all_children = $"../../left_panel/ProjectNodes/Inside/Tree Control".get_children()
		for child in new_all_children:
			if child.name == sprite_name:
				child.connected_viewport = self
	else:
		create_new_sprite_with_name(sprite_name)
		show_only_selected_sprite(sprite_name)
	Global.current_working_sprite = sprite_name
	
func reload_sprite(sprite_name : String):
	var all_children = get_children()
	for child in all_children:
		if child.name == sprite_name:
			for child_child in child.get_children():
				child_child.queue_free()
				
func get_focused_sprite(sprite_name : String):
	var all_children = get_children()
	for child in all_children:
		if child.name == sprite_name:
			return child

func get_properties_from_selected_node_in_sprite(sprite_name : String):
	var all_children = self.get_children()
	for child in all_children:
		if child.name == sprite_name:
			print(child.name)
			return child.get_focused_node_properties()
