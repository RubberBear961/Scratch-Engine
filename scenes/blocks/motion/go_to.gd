extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var inp1 = find_child("INP")  # Szuka w całym drzewie
	var inp2 = find_child("INP2")
	var line_edit1 = find_child("LineEdit")
	var line_edit2 = find_child("LineEdit2")
	var panel = find_child("Panel")
	
	if inp1 and inp2 and line_edit1 and line_edit2 and panel:
		if len(line_edit1.text) > 3:
			inp1.custom_minimum_size.x = 20 + len(line_edit1.text) * 10.7
			panel.custom_minimum_size.x = 250 + len(line_edit2.text) * 10.7 + len(line_edit1.text) * 10.7
		else:
			inp1.custom_minimum_size.x = 45
		if len(line_edit2.text) > 3:
			inp2.custom_minimum_size.x = 20 + len(line_edit2.text) * 10.7
			panel.custom_minimum_size.x = 250 + len(line_edit2.text) * 10.7 + len(line_edit1.text) * 10.7
		else:
			inp2.custom_minimum_size.x = 45
			
		if len(line_edit2.text) <= 3 and len(line_edit1.text) <= 3:
			panel.custom_minimum_size.x = 250
