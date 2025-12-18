extends Node

var current_project_path = ""

func _ready():
	pass

func save_script(script_data: Dictionary, script_name : String):
	if script_data.is_empty():
		return false
	
	var file_path = Global.current_working_project_path + script_name
	var file = FileAccess.open(file_path,FileAccess.WRITE)
	
	if file == null:
		push_error("[Fluppy] -> There was an error while creating script file!")
	
	file.store_line(JSON.stringify(script_data,"\t"))
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
