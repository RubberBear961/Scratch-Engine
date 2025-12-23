extends Control

var CanvasLayer_node = preload("res://scenes/nodes/CanvasLayer.tscn")

func add_node(node_type_to_add : String, node_params : Dictionary, root_node):
	if node_params == null:
		return
	if node_type_to_add == "CanvasLayer":
		var new_canvas_layer = CanvasLayer_node.instantiate()
		root_node.add_child(new_canvas_layer)

func get_focused_node_properties():
	var all_children = get_children()
	print("2D section debug =========================")
	for child in all_children:
		print(child.name)
		print(Global.current_working_sprite_node.get_text(0))
		if child.name == Global.current_working_sprite_node.get_text(0):
			print("yup!")
			return {
				"position": {
					"x": child.position.x,
					"y": child.position.y
				},
				"size": {
					"x": child.size.x,
					"y": child.size.y
				}
			}
	print("/2D section debug =========================")
