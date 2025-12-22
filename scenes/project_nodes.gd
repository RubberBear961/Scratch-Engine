extends Tree

@onready var main = self.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()

@onready var folder_popup = $Folder_popup
@onready var folder_file_submenu = $Folder_popup/Folder_file_submenu
@onready var file_file_submenu = $File_popup/file_file_submenu
@onready var rename_panel = $Rename_node_panel
@onready var add_node_panel = $AddNode
@onready var warn = main.find_child("warning", false)

var next_id := 0
var Node_setup := {}


var node_icon = preload("res://assets/icons/EmptyNode.png")
var CanvasLayer_icon = preload("res://assets/icons/CanvasLayer.png")
var Panel_icon = preload("res://assets/icons/Panel.svg")

var focused_part = null

func add_node_to_tree(selected_node_data : Dictionary):
	var new_item = create_item(get_selected())
	new_item.set_text(0, selected_node_data["name"])
	new_item.set_custom_font_size(0,12)
	new_item.set_icon(0, selected_node_data["icon"])
	new_item.set_icon_max_width(0,15)
	new_item.set_metadata(0, selected_node_data["metadata"])


func rename_selected_item():
	var item = get_selected()
	if not item:
		return

	var text = item.get_text(0)
	
	var editor = rename_panel.get_child(0)
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
	add_node_panel.show()


func delete_part():
	var selected = get_selected()
	if selected == get_root():
		if warn != null:
			warn.push_warn("You cannot delete sprite's root element from here!")
		return
	if selected:
		var parent = selected.get_parent()
		parent.remove_child(selected) 
		selected.free()               


func prepare_folder_popup():
	folder_popup.clear()
	
	# --- File Submenu ---
	folder_popup.add_item("New node", 1)

	var node_index = folder_file_submenu.get_item_index(1)

	folder_popup.set_item_icon(node_index, node_icon)
	
	folder_popup.set_item_icon_max_width(node_index, 12)

	folder_popup.add_item("Rename", 2)
	
	folder_popup.add_item("Delete", 3)

	folder_popup.hide()

func load_project_tree() -> void:
	clear()
	var root_item = create_item()
	root_item.set_text(0,"CanvasLayer")
	root_item.set_metadata(0,"CanvasLayer")
	root_item.set_custom_font_size(0,12)
	root_item.set_icon(0,CanvasLayer_icon)
	root_item.set_icon_max_width(0,15)
	root_item.collapsed = false

func save_tree_recursive(item: TreeItem, parent_id: int) -> void:
	var my_id := next_id
	next_id += 1

	Node_setup[my_id] = {
		"name": item.get_text(0),
		"type": item.get_metadata(0),
		"parent": parent_id,
		"children": []
	}

	var child := item.get_first_child()
	while child:
		var child_id := next_id
		Node_setup[my_id]["children"].append(child_id)
		save_tree_recursive(child, my_id)
		child = child.get_next()


func load_tree_recursive(data: Dictionary, parent_item: TreeItem, node_id: int) -> void:
	var node_data = data.get(str(node_id))
	if not node_data:
		return
	
	# Tworzymy nowy element w drzewie
	var new_item = create_item(parent_item)
	new_item.set_text(0, node_data["name"])
	new_item.set_metadata(0, node_data["type"])
	new_item.set_custom_font_size(0,12)
	new_item.set_icon_max_width(0,15)
	
	if node_data["type"] == "CanvasLayer":
		new_item.set_icon(0,CanvasLayer_icon)
	elif node_data["type"] == "Panel":
		new_item.set_icon(0,Panel_icon)
	# Rekurencyjnie tworzymy dzieci
	for child_id in node_data["children"]:
		load_tree_recursive(data, new_item, child_id)


func load_tree_data(data: Dictionary) -> void:
	clear()
	
	if data.is_empty():
		return
	
	var root_id = -1
	for key in data:
		var node_data = data[key]
		if node_data["parent"] == -1:
			root_id = int(key)
			break
	
	if root_id != -1:
		var root_data = data[str(root_id)]
		var root_item = create_item()
		root_item.set_text(0, root_data["name"])
		root_item.set_metadata(0, root_data["type"])
		root_item.set_custom_font_size(0,12)
		root_item.set_icon_max_width(0,15)
		
		if root_data["type"] == "CanvasLayer":
			root_item.set_icon(0,CanvasLayer_icon)
		elif root_data["type"] == "Panel":
			root_item.set_icon(0,Panel_icon)
		
		# Rekurencyjnie tworzymy dzieci korzenia
		for child_id in root_data["children"]:
			load_tree_recursive(data, root_item, child_id)


func get_dictionary():
	return Node_setup

func save_project_tree():
	Node_setup.clear()
	next_id = 0

	var root := get_root()
	if root:
		save_tree_recursive(root, -1)


func _ready():
	load_project_tree()
	prepare_folder_popup()
	rename_panel.hide()
	add_node_panel.hide()
	



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
		1: create_part()
		2: rename_selected_item()
		3: delete_part()



func _on_line_edit_text_submitted(new_text: String) -> void:
	var item = get_selected()
	
	item.set_text(0, new_text)
	item.set_editable(0, false)
	
	rename_panel.hide()
	rename_panel.size.x = 44

func _create():
	clear()
	var root_item = create_item()
	root_item.set_text(0,"CanvasLayer")
	root_item.set_metadata(0,"CanvasLayer")
	root_item.set_custom_font_size(0,12)
	root_item.set_icon(0,CanvasLayer_icon)
	root_item.set_icon_max_width(0,15)
	root_item.collapsed = false
