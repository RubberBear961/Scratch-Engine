extends Tree

@onready var folder_popup = $Folder_popup
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

	var text = item.get_text(0)
	
	var editor = $"../../../../../../Rename_panel/LineEdit"
	editor.text = text
	
	var mouse_local: Vector2 = get_viewport().get_mouse_position()
	var window_pos: Vector2i = DisplayServer.window_get_position()

	var screen_mouse: Vector2 = mouse_local + Vector2(window_pos)
	rename_panel.popup(Rect2i(screen_mouse, folder_popup.size))
	
	rename_panel.size = Vector2(44,28)
	editor.size = Vector2(0,0)
	
	editor.grab_focus()
	editor.select_all()

func create_part():
	pass


func delete_part(path : String, focused_path : String):
	if focused_path == Global.current_working_project_path:
		$"../../../../../../warning".push_warn("You cannot delete root node from here!")
		return
	var selected = get_selected()
	if selected:
		var parent = selected.get_parent()
		parent.remove_child(selected) 
		selected.free()               


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

func load_project_tree() -> void:
	clear()
	var root_item = create_item()
	root_item.set_text(0,"SpriteTexture")
	root_item.set_metadata(0,"SpriteTexture")
	root_item.set_custom_font_size(0,12)
	root_item.set_icon(0,folder_icon)
	root_item.set_icon_max_width(0,15)
	root_item.collapsed = false

func _ready():
	load_project_tree()
	prepare_folder_popup()
	rename_panel.hide()



func _on_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var item = get_item_at_position(event.position)
			if item:
				var mouse_local: Vector2 = get_viewport().get_mouse_position()
				var window_pos: Vector2i = DisplayServer.window_get_position()

				var screen_mouse: Vector2 = mouse_local + Vector2(window_pos)
				folder_popup.popup(Rect2i(screen_mouse, folder_popup.size))


func _on_folder_popup_id_pressed(id: int) -> void:
	match id:
		2: rename_selected_item()
		3: delete_part(Global.current_working_project_path,focused_part)

func _on_folder_file_submenu_id_pressed(id: int) -> void:
	match id:
		10: create_part()
		11: create_part()
		12: create_part()


func _on_line_edit_text_submitted(new_text: String) -> void:
	var item = get_selected()
	
	item.set_text(0, new_text)
	item.set_editable(0, false)
	
	rename_panel.hide()
	rename_panel.size.x = 44
	$"../../../../ViewPort/CODE".rename_existing_code(focused_part.get_file().get_basename(),item.get_text(0).get_basename())
