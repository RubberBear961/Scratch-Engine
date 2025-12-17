extends Node

const SAVE_PATH = "user://saved_projects/"
const FILE_EXTENSION = ".sc"

var current_project_path = ""

func _ready():
	# Utwórz folder zapisu jeśli nie istnieje
	DirAccess.make_dir_absolute(SAVE_PATH)

func save_project(project_name: String, blocks_data: Dictionary) -> bool:
	if project_name.is_empty():
		return false
	
	var file_path = SAVE_PATH + project_name + FILE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to save project: ", FileAccess.get_open_error())
		return false
	
	# Zapisujemy dane w formacie JSON dla łatwiejszego parsowania
	var save_data = {
		"blocks": blocks_data,
		"version": "1.0",
		"created": Time.get_datetime_string_from_system()
	}
	
	file.store_line(JSON.stringify(save_data, "\t"))
	file.close()
	
	current_project_path = file_path
	print("Project saved to: ", file_path)
	return true

func load_project(project_name: String) -> Dictionary:
	var file_path = SAVE_PATH + project_name + FILE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to load project: ", FileAccess.get_open_error())
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	if parsed == null:
		push_error("Failed to parse project file")
		return {}
	
	current_project_path = file_path
	return parsed

func get_saved_projects() -> Array:
	var projects = []
	var dir = DirAccess.open(SAVE_PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(FILE_EXTENSION):
				projects.append(file_name.trim_suffix(FILE_EXTENSION))
			file_name = dir.get_next()
	
	return projects

func delete_project(project_name: String) -> bool:
	var file_path = SAVE_PATH + project_name + FILE_EXTENSION
	return DirAccess.remove_absolute(file_path) == OK
