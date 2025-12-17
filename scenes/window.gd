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


func _on_file_dialog_confirmed() -> void:
	current_create_project_path = $"../FileDialog".current_path
	$"Control/Panel/VBoxContainer/Project Path/LineEdit".text = current_create_project_path

func _on_path_choose_pressed() -> void:
	$"../FileDialog".show()


func _on_project_name_changed(new_text: String) -> void:
	current_create_project_name = $"Control/Panel/VBoxContainer/Project Name/LineEdit".text
	current_create_project_path_with_name = str(current_create_project_path) + str(create_slug(current_create_project_name))
	$"Control/Panel/VBoxContainer/Project Path/LineEdit".text = current_create_project_path_with_name
