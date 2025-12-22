extends Node

var current_project_path = ""

func _ready():
	pass

func save_script(script_data: Dictionary, script_name : String):
	if script_data.is_empty():
		return false
	var file_path = Global.current_working_project_path + "/" + script_name + ".scrx"
	var file = FileAccess.open(file_path,FileAccess.WRITE)
	
	if file == null:
		push_error("[Fluppy] -> There was an error while creating script file!")
	
	file.store_line(JSON.stringify(script_data,"\t"))
	file.close()

func save_sprite(sprite_data: Dictionary, sprite_name : String):
	if sprite_data.is_empty():
		return false
	var file_path = Global.current_working_project_path + "/" + sprite_name + ".spr"
	var file = FileAccess.open(file_path,FileAccess.WRITE)
	
	if file == null:
		push_error("[Fluppy] -> There was an error while creating script file!")
	
	file.store_line(JSON.stringify(sprite_data,"\t"))
	file.close()
	
func load_script(script_name : String) -> Dictionary:
	var file_path = Global.current_working_project_path + script_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("[Fluppy] -> Failed to load script: ", FileAccess.get_open_error())
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	if parsed == null:
		push_error("[Fluppy] -> couldn't parse script file")
		return {}
	
	current_project_path = file_path
	return parsed

func get_script_dictionary(script_name : String):
	var all_children = $"../GUI/Content/ViewPort/CODE".get_children()
	for child in all_children:
		if child.name == script_name:
			return child.get_dictionary()
			
func get_sprite_dictionary(sprite_name : String):
	var all_children = $"../GUI/Content/left_panel/ProjectNodes/Inside/Tree Control".get_children()
	for child in all_children:
		if child.name == sprite_name:
			child.save_project_tree()
			return child.get_dictionary()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		$"../SaveProgress".show()
		$"../SaveProgress/VBoxContainer/ProgressBar".value = 0

		await get_tree().process_frame
		
		if Global.current_working_script != null:
			save_script(
				get_script_dictionary(Global.current_working_script),
				Global.current_working_script
			)
		if Global.current_working_sprite != null:
			save_sprite(
				get_sprite_dictionary(Global.current_working_sprite),
				Global.current_working_sprite
			)

		$"../SaveProgress/VBoxContainer/ProgressBar".value = 100
		await get_tree().process_frame

		$"../SaveProgress".hide()
