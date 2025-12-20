extends Tree

@onready var folder_popup = $Folder_popup
@onready var file_popup = $File_popup
@onready var folder_file_submenu = $Folder_popup/Folder_file_submenu
@onready var file_file_submenu = $File_popup/file_file_submenu
@onready var rename_panel = $"../../../../../../Rename_panel"

var sprite_icon = preload("res://assets/icons/sprite.png")
var folder_icon = preload("res://assets/icons/folder.png")
var script_icon = preload("res://assets/icons/script.png")

var focused_part = null

func rename_selected_item():
	var item = get_selected()
	if not item:
		return
	if item.get_metadata(0) == Global.current_working_project_path:
		$"../../../../../../warning".push_warn("[Fluppy] -> You cannot change root dir name from here!")
		return

	var text = item.get_text(0)
	var dot = text.rfind(".")
	var base = text.substr(0, dot) if dot > 0 else text

	var editor = $"../../../../../../Rename_panel/LineEdit"
	editor.text = text
	
	var mouse_local: Vector2 = get_viewport().get_mouse_position()
	var window_pos: Vector2i = DisplayServer.window_get_position()

	var screen_mouse: Vector2 = mouse_local + Vector2(window_pos)
	rename_panel.popup(Rect2i(screen_mouse, folder_popup.size))
	
	rename_panel.size = Vector2(44,28)
	editor.size = Vector2(0,0)
	
	editor.grab_focus()
	editor.select(0,base.length())


	

func create_part(type : String, path : String):
	if not path:
		return
	if type == "Folder":
		DirAccess.make_dir_absolute(path + "/New Folder")
	elif type == "Script":
		var new_file = FileAccess.open(path + "/New_Script.sc",FileAccess.WRITE)
		new_file.close()
		$"../../../../ViewPort/CODE".create_new_code_with_name("New_Script")
	elif type == "Sprite":
		var new_file = FileAccess.open(path + "/New_Sprite.scs",FileAccess.WRITE)
		new_file.close()
	load_project_tree()

func _remove_dir_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path := path + "/" + file_name
			if dir.current_is_dir():
				_remove_dir_recursive(full_path)
			else:
				DirAccess.remove_absolute(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

	# usuń pusty folder
	DirAccess.remove_absolute(path)


func delete_part(path : String, focused_path : String):
	var dir = DirAccess.open(path)
	if not dir:
		return
	if focused_path == Global.current_working_project_path:
		$"../../../../../../warning".push_warn("You cannot delete root folder from here!")
		return
	var unknown = DirAccess.open(focused_path)
	if unknown:  # if the path is pointing to a directory
		_remove_dir_recursive(focused_path)
	else:        # if it's pointing to a file
		DirAccess.remove_absolute(focused_path)
	load_project_tree()

func prepare_folder_popup():
	folder_popup.clear()
	
	# --- File Submenu ---
	folder_file_submenu.add_item("Folder", 10)
	folder_file_submenu.add_item("Script", 11)
	folder_file_submenu.add_item("Sprite", 12)

	var folder_index = folder_file_submenu.get_item_index(10)
	var script_index = folder_file_submenu.get_item_index(11)
	var sprite_index = folder_file_submenu.get_item_index(12)

	folder_file_submenu.set_item_icon(folder_index, folder_icon)
	folder_file_submenu.set_item_icon(script_index, script_icon)
	folder_file_submenu.set_item_icon(sprite_index, sprite_icon)
	
	folder_file_submenu.set_item_icon_max_width(folder_index, 15)
	folder_file_submenu.set_item_icon_max_width(script_index, 15)
	folder_file_submenu.set_item_icon_max_width(sprite_index, 12)

	folder_popup.add_submenu_node_item("New", folder_file_submenu)

	folder_popup.add_item("Rename", 2)
	
	folder_popup.add_item("Delete", 3)

	folder_popup.hide()

func prepare_file_popup():
	file_popup.clear()
	
	file_popup.add_item("Open",0)
	
	# --- File Submenu ---
	file_file_submenu.add_item("Folder", 10)
	file_file_submenu.add_item("Script", 11)
	file_file_submenu.add_item("Sprite", 12)

	var folder_index = file_file_submenu.get_item_index(10)
	var script_index = file_file_submenu.get_item_index(11)
	var sprite_index = file_file_submenu.get_item_index(12)

	file_file_submenu.set_item_icon(folder_index, folder_icon)
	file_file_submenu.set_item_icon(script_index, script_icon)
	file_file_submenu.set_item_icon(sprite_index, sprite_icon)

	file_file_submenu.set_item_icon_max_width(folder_index, 15)
	file_file_submenu.set_item_icon_max_width(script_index, 15)
	file_file_submenu.set_item_icon_max_width(sprite_index, 12)

	file_popup.add_submenu_node_item("New",file_file_submenu)
	
	file_popup.add_item("Rename",2)
	file_popup.add_item("Duplicate",3)
	
	file_popup.add_item("Delete", 4)

	file_popup.hide()

func add_folder_to_tree(parent_item: TreeItem, path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.begins_with(".") or file_name.ends_with(".import"):
			file_name = dir.get_next()
			continue

		var full_path = path + "/" + file_name
		var item = create_item(parent_item)
		item.set_text(0, file_name)
		item.set_custom_font_size(0,12)
		item.set_metadata(0,full_path)
		
		if dir.dir_exists(full_path):
			item.set_icon(0,folder_icon)
			item.set_icon_max_width(0,15)
		elif full_path.ends_with(".sc"):
			item.set_icon(0, script_icon)
			item.set_icon_max_width(0,15)
		elif full_path.ends_with(".svg") or full_path.ends_with(".png"):
			var preloaded_custom_icon = load(full_path)
			item.set_icon(0, preloaded_custom_icon)
			item.set_icon_max_width(0,15)
		elif full_path.ends_with(".scs"):
			item.set_icon(0, sprite_icon)
			item.set_icon_max_width(0,12)

		if dir.dir_exists(full_path): 
			add_folder_to_tree(item, full_path) 
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func load_project_tree() -> void:
	clear()
	var root_item = create_item()
	root_item.set_text(0,"root://")
	root_item.set_custom_font_size(0,12)
	root_item.set_metadata(0,Global.current_working_project_path)
	root_item.set_icon(0,folder_icon)
	root_item.set_icon_max_width(0,15)
	add_folder_to_tree(root_item, Global.current_working_project_path)
	root_item.collapsed = false

func _ready():
	load_project_tree()
	prepare_folder_popup()
	prepare_file_popup()
	rename_panel.hide()



func _on_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var item = get_item_at_position(event.position)
			if item:
				var path = item.get_metadata(0)
				var dir = DirAccess.open(path)
				if dir:
					var mouse_local: Vector2 = get_viewport().get_mouse_position()
					var window_pos: Vector2i = DisplayServer.window_get_position()

					var screen_mouse: Vector2 = mouse_local + Vector2(window_pos)
					folder_popup.popup(Rect2i(screen_mouse, folder_popup.size))
					focused_part = path
					print("dir")
				else:
					var mouse_local: Vector2 = get_viewport().get_mouse_position()
					var window_pos: Vector2i = DisplayServer.window_get_position()

					var screen_mouse: Vector2 = mouse_local + Vector2(window_pos)
					file_popup.popup(Rect2i(screen_mouse, file_popup.size))
					focused_part = path


func _on_folder_popup_id_pressed(id: int) -> void:
	match id:
		2: rename_selected_item()
		3: delete_part(Global.current_working_project_path,focused_part)

func _on_folder_file_submenu_id_pressed(id: int) -> void:
	match id:
		10: create_part("Folder", focused_part)
		11: create_part("Script", focused_part)
		12: create_part("Sprite", focused_part)
		
func _on_file_popup_id_pressed(id: int) -> void:
	match id:
		0: $"../../../../ViewPort/CODE".show_only_selected_code(get_selected().get_text(0).get_basename())
		2: rename_selected_item()
		4: delete_part(Global.current_working_project_path,focused_part)


func _on_item_edited() -> void:
	var dir = DirAccess.open(Global.current_working_project_path)
	var item = self.get_selected()
	if not dir:
		return
	dir.rename(focused_part,self.get_selected().get_text(0))
	item.set_editable(0,false)


func _on_file_file_submenu_id_pressed(id: int) -> void:
	var parent_dir = focused_part.get_base_dir() if focused_part else ""
	match id:
		10: create_part("Folder", parent_dir)
		11: create_part("Script", parent_dir)
		12: create_part("Sprite", parent_dir)


func _on_line_edit_text_submitted(new_text: String) -> void:
	var dir = DirAccess.open(Global.current_working_project_path)
	if not dir:
		return
	
	var item = get_selected()
	
	item.set_text(0, new_text)
	item.set_editable(0, false)
	
	var parent_path = focused_part.get_base_dir()
	dir.rename(focused_part,parent_path + "/" + item.get_text(0))
	rename_panel.hide()
	rename_panel.size.x = 44
	$"../../../../ViewPort/CODE".rename_existing_code(focused_part.get_file().get_basename(),item.get_text(0).get_basename())
