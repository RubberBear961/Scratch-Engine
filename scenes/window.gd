extends Window

@onready var Preset_focus = preload("res://assets/styles/preset_focus.tres")
@onready var Preset_normal = preload("res://assets/styles/preset_normal.tres")

@onready var two_d = $"Control/Panel/VBoxContainer/Presets/HBoxContainer/2D"
@onready var three_d_tps = $"Control/Panel/VBoxContainer/Presets/HBoxContainer/3D"
@onready var three_d_fps = $"Control/Panel/VBoxContainer/Presets/HBoxContainer/3D2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func create_workflow(path: String) -> bool:
	path = path.simplify_path()
	
	print("[Fluppy] -> Attempting to create project at: ", path)
	
	if path.is_empty():
		print("[Fluppy] -> Path is empty!")
		return false
	
	if DirAccess.dir_exists_absolute(path):
		print("[Fluppy] -> Directory already exists!")
		return false
	
	var root_dir = DirAccess.open("")
	if not root_dir:
		print("[Fluppy] -> Couldn't open root directory access")
		return false
	
	var error = root_dir.make_dir_recursive(path)
	if error != OK:
		print("[Fluppy] -> Couldn't create directory. Error: ", error)
		return false
	
	print("[Fluppy] -> Directory created successfully")
	
	var file_path = path.path_join("project.sce")
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if not file:
		print("[Fluppy] -> Couldn't create project file. Error: ", FileAccess.get_open_error())
		return false
	
	file.store_string("[HEAD]")
	file.close()
	
	var image_path = "res://assets/scratch_engine_logo.svg"
	var dest_path = path.path_join("icon.svg")
	
	var dir = DirAccess.open(path)
	
	if dir.copy(image_path,dest_path) == OK:
		print("[Fluppy] -> Copied project icon")
	else:
		print("[Fluppy] -> Couldn't copy project icon! This is not a fatal error!")
	
	create_project(current_create_project_name,current_create_project_path_with_name)
	load_all_projects()
	
	print("[Fluppy] -> Project created successfully at: ", path)
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_slug(input: String) -> String:
	# Tworzenie i kompilacja RegEx
	var regex = RegEx.create_from_string("[^\\w\\d]+")
	
	# Zamień niealfanumeryczne znaki na myślniki
	var slug = regex.sub(input.to_lower(), "-")
	
	# Usuń ewentualne myślniki na końcach - DWA sposoby:
	
	# SPOSÓB 1: strip_edges() bez argumentów usuwa białe znaki
	slug = slug.strip_edges()
	# Następnie usuń myślniki z końców ręcznie:
	while slug.begins_with("-"):
		slug = slug.substr(1)
	while slug.ends_with("-"):
		slug = slug.substr(0, slug.length() - 1)
	
	# SPOSÓB 2: Użyj trim_prefix() i trim_suffix()
	slug = slug.strip_edges()  # najpierw białe znaki
	slug = slug.trim_prefix("-").trim_suffix("-")
	
	return slug

# Presets Dynamic Focus =========================================================
func _on_d_pressed() -> void:
	two_d.add_theme_stylebox_override("normal",Preset_focus)
	three_d_tps.add_theme_stylebox_override("normal", Preset_normal)
	three_d_fps.add_theme_stylebox_override("normal", Preset_normal)

func _on_3d_pressed() -> void:
	two_d.add_theme_stylebox_override("normal",Preset_normal)
	three_d_tps.add_theme_stylebox_override("normal", Preset_focus)
	three_d_fps.add_theme_stylebox_override("normal", Preset_normal)
	
func _on_d_3D_FPS_pressed() -> void:
	two_d.add_theme_stylebox_override("normal",Preset_normal)
	three_d_tps.add_theme_stylebox_override("normal",Preset_normal)
	three_d_fps.add_theme_stylebox_override("normal", Preset_focus)

# Main Create Section ==========================================================
var current_create_project_path
var current_create_project_path_with_name
var current_create_project_name
var current_create_project_git_integrity

func _on_create_pressed() -> void:
	create_workflow(current_create_project_path_with_name)
	$".".hide()


func _on_file_dialog_confirmed() -> void:
	current_create_project_path = $"../FileDialog".current_path
	$"Control/Panel/VBoxContainer/Project Path/LineEdit".text = current_create_project_path

func _on_path_choose_pressed() -> void:
	$"../FileDialog".show()


func _on_project_name_changed(new_text: String) -> void:
	current_create_project_name = $"Control/Panel/VBoxContainer/Project Name/LineEdit".text
	current_create_project_path_with_name = str(current_create_project_path) + str(create_slug(current_create_project_name))
	$"Control/Panel/VBoxContainer/Project Path/LineEdit".text = current_create_project_path_with_name


# Handling Multiple Projects ==============================================
func load_project(project_name : String):
	if not FileAccess.file_exists("user://projects/" + project_name + "/project.save"):
		return

	var file = FileAccess.open("user://projects/" + project_name + "/project.save", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	var data_to_return : Dictionary = {
		"project_name": data.project_name,
		"project_path": data.project_path,
		"project_icon": data.project_icon
	}
	
	return data_to_return
		
func create_project(project_to_create_name, project_to_create_path):
	var dir_path = "user://projects/" + project_to_create_name

	DirAccess.make_dir_recursive_absolute(dir_path)

	var file = FileAccess.open(dir_path + "/project.save", FileAccess.WRITE)
	if file == null:
		push_error("[Fluppy] -> couldn't create save file for project link. This shouldn't be treatened as a fatal error")
		return

	var Project: Dictionary = {
		"project_name": project_to_create_name,
		"project_path": project_to_create_path,
		"project_icon": project_to_create_path + "/icon.svg"
	}

	file.store_string(JSON.stringify(Project))
	file.close()

func load_all_projects():
	var dir = DirAccess.open("user://projects/")
	if dir == null:
		return

	dir.list_dir_begin()
	while true:
		var name = dir.get_next()
		if name == "":
			break

		if dir.current_is_dir() and not name.begins_with("."):
			var project = load_project(name)
			var project_icon = preload("res://scenes/project_icon.tscn")
			var ready_project_icon = project_icon.instantiate()
			ready_project_icon.project_name = name
			ready_project_icon.project_icon = project.project_icon
			$"../VBoxContainer/ProjectsTab/VBoxContainer/ScrollContainer/HFlowContainer".add_child(ready_project_icon)
			
	dir.list_dir_end()
