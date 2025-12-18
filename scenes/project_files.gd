extends Tree

# Funkcja rekurencyjna do dodawania folderów i plików
func add_folder_to_tree(parent_item: TreeItem, path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue  # pomiń ukryte pliki/foldery

		var full_path = path + "/" + file_name
		var item = create_item(parent_item)
		item.set_text(0, file_name)

		# Tutaj możesz ustawić własną ikonę, np. z pliku:
		# var folder_icon = preload("res://icons/folder.png")
		# var file_icon = preload("res://icons/file.png")
		# if dir.dir_exists(full_path):
		#     item.set_icon(0, folder_icon)
		# else:
		#     item.set_icon(0, file_icon)

		if dir.dir_exists(full_path):  # jeśli to folder
			add_folder_to_tree(item, full_path)  # rekurencyjnie dodaj zawartość
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# Funkcja do wczytania całego folderu
func load_project_tree() -> void:
	clear()  # usuń poprzednią zawartość drzewa
	var root_item = create_item()  # root drzewa (ukryty)
	add_folder_to_tree(root_item, Global.current_working_project_path)
	root_item.collapsed = false  # root rozwinięty

func _ready():
	load_project_tree()
