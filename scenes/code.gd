extends Control

@onready var workspace = $HBoxContainer/Workspace
@onready var blocks_list = $HBoxContainer/DeadZones/Blocks/VBoxContainer
@onready var shadow = preload("res://scenes/blocks/shadow.tscn")

var dragging_column = false

var join_position
var join_offset = 5

var found_snap = false
var snap_position
var shadow_cast

var Connections : Dictionary = {}

var connecting_to
var connecting_with
var connected = false

var placedblock

var dragging_block
var drag_offset
var shadow_block : Control = null

var snap = null
var snapping_threshold = 30

func code_name(name : String):
	$HBoxContainer/DeadZones/Spacer2/path.text = name

func _ready() -> void:
	for block in blocks_list.get_children():
		var real_block = block.get_child(0)
		real_block.gui_input.connect(func(event): _on_block_grabbed(event, block))


func _on_go_to_changed(new_text: String, block: Control):
	print("changed!")
	var X = block.get_node("Panel/HBoxContainer/INP/LineEdit")
	var Y = block.get_node("Panel/HBoxContainer/INP2/LineEdit2")
	block.set_meta("x_target", int(X.text))
	block.set_meta("y_target", int(Y.text))
	if Connections.has(block.name):
		Connections[block.name]["meta"] = {
			"x_target": block.get_meta("x_target"),
			"y_target": block.get_meta("y_target")
		}

#Saving Functions --------------------------------------------------------
func update_dictionary(mode: int):
	print("Updating Dictionary!")
	if mode == 0: # if block was snapped to another
		var OldOne = Connections
		if OldOne.has(connecting_with.name):
			var one_below = OldOne[connecting_with.name]["connected_below"]
			var one_above = OldOne[connecting_with.name]["connected_above"]
			if str(one_below) != "-1":
				OldOne[one_below]["connected_above"] = one_above
			if str(one_above) != "-1":
				OldOne[one_above]["connected_below"] = one_below
			OldOne.erase(connecting_with.name)
		if OldOne.has(connecting_to.name):
			if snap == "UP":
				OldOne[connecting_with.name] = {
				"type": connecting_with.get_meta("type"),
				"position": connecting_with.position,
				"connected_above": OldOne[connecting_to.name]["connected_above"],
				"connected_below": connecting_to.name
				}
				
				OldOne[connecting_to.name]["connected_above"] = connecting_with.name
			if snap == "DOWN":
				OldOne[connecting_with.name] = {
				"type": connecting_with.get_meta("type"),
				"position": connecting_with.position,
				"connected_above": connecting_to.name,
				"connected_below": OldOne[connecting_to.name]["connected_below"]
				}
				
				OldOne[connecting_to.name]["connected_below"] = connecting_with.name
		Connections = OldOne
		print(Connections)
	if mode == 1: # Block was just placed
		var OldOne = Connections
		if OldOne.has(placedblock.name):
			var one_below = OldOne[placedblock.name]["connected_below"]
			var one_above = OldOne[placedblock.name]["connected_above"]
			if str(one_below) != "-1":
				OldOne[one_below]["connected_above"] = one_above
			if str(one_above) != "-1":
				OldOne[one_above]["connected_below"] = one_below
			OldOne.erase(placedblock.name)
			
		OldOne[placedblock.name] = {
		"type": placedblock.get_meta("type"),
		"position": placedblock.position,
		"connected_above": -1,
		"connected_below": -1
		}
		
		placedblock = null
		Connections = OldOne
		print(Connections)
	if mode == 2: # If the whole collumn is being moved
		if dragging_block == null:
			return
		if str(Connections[dragging_block.name]["connected_above"]) != "-1":
			var block_above = Connections[dragging_block.name]["connected_above"]
			Connections[block_above]["connected_below"] = -1
			Connections[dragging_block.name]["connected_above"] = -1
		Connections[dragging_block.name]["position"] = dragging_block.position

func get_block_above(block_name):
	if not Connections.has(block_name):
		return -1
	return Connections[block_name]["connected_above"]

func get_block_below(block_name):
	if not Connections.has(block_name):
		return -1
	return Connections[block_name]["connected_below"]

func update_positions_in_connections(block_name: String):
	var current = block_name
	while str(current) != "-1":
		var node = workspace.find_child(str(current), true, false)
		if node and Connections.has(current):
			Connections[current]["position"] = node.position
		current = get_block_below(current)

#Drag System -------------------------------------------------------------

# Drag Helpers ============================================
func get_blocks_in_column_below(block):
	var blocks_below : Dictionary = {}
	if block == null:
		return blocks_below
	var last_block = false
	var current_stage = block.name
	while last_block == false:
		if not Connections.has(current_stage):
			break
		var above_name
		var below_name
		if str(get_block_above(current_stage)) == "-1":
			above_name = -1
		else:
			above_name = get_block_above(current_stage)
			
		if str(get_block_below(current_stage)) == "-1":
			below_name = -1
		else:
			below_name = get_block_below(current_stage)
		
		blocks_below[current_stage] = {
			"type": Connections[current_stage]["type"],
			"position": Connections[current_stage]["position"],
			"connected_above": above_name,
			"connected_below": below_name
		}
		if str(Connections[current_stage]["connected_below"]) == "-1":
			last_block = true
		else:
			var block_below = get_block_below(current_stage)
			current_stage = block_below
	return blocks_below
	
func get_specific_block_in_column_below(block,n):
	var all_blocks = get_blocks_in_column_below(block)
	var focused_element = dragging_block.name
	var i = 1
	print("GET SPECIFIC BLOCK LOG ======================")
	print(all_blocks)
	if focused_element == null:
		return null
	
	while i < n+1:
		print(all_blocks)
		print(focused_element)
		var next_element = all_blocks[str(focused_element)]["connected_below"]
		if str(next_element) == "-1":
			return null
		focused_element = next_element
		i += 1
		
	return focused_element

func is_block_in_column(top_block_name: String, check_name: String) -> bool:
	var current = top_block_name
	while str(current) != "-1":
		if current == check_name:
			return true
		current = get_block_below(current)
	return false
# Drag Helpers ===============================================

func setup_draggable(real_block: Control, original_block: Control) -> void:
	real_block.gui_input.connect(func(event): _on_block_grabbed(event, original_block))
		
func check_if_visible():
	if Global.focus == "CODE":
		self.visible = true
	else:
		self.visible = false
		
func _on_block_grabbed(event: InputEvent, block: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print(block.get_parent())
			if block.get_parent() == workspace:
				if Connections.has(block.name) and str(Connections[block.name]["connected_below"]) != "-1":
					drag_offset = get_global_mouse_position() - block.global_position
					dragging_column = true
					dragging_block = block
					print("Now dragging Column!")
				else:
					dragging_column = false
					dragging_block = block
					drag_offset = get_global_mouse_position() - block.global_position
					print("Now dragging single block!")
			else:
				dragging_block = block.duplicate()
				dragging_block.name = str(workspace.get_child_count() + 1)
				dragging_block.set_meta("type", block.name)
				workspace.add_child(dragging_block)
				
				# Connecting to a different parameters functions:
				if dragging_block.get_meta("type") == "go_to":
					print("connected!")
					var real_block = dragging_block.get_child(0)
					print(real_block)
					var X = real_block.get_node("Panel/HBoxContainer/INP/LineEdit")
					var Y = real_block.get_node("Panel/HBoxContainer/INP2/LineEdit2")
					X.text = str(real_block.get_meta("x_target", 0))
					Y.text = str(real_block.get_meta("y_target", 0))
					X.connect("text_changed", Callable(self, "_on_go_to_changed").bind(real_block))
					Y.connect("text_changed", Callable(self, "_on_go_to_changed").bind(real_block))
				
				drag_offset = get_global_mouse_position() - block.global_position
				setup_draggable(dragging_block.get_child(0), dragging_block)
				dragging_block.position = workspace.get_local_mouse_position() - drag_offset
		else:
			if dragging_block != null:
				if found_snap:
					dragging_block.global_position = join_position
					update_dictionary(0) # if snapping then mode "0"
					print("Snappujesz")
				elif dragging_column == true:
					update_dictionary(2) # if dragging whole column then mode "2"
					print("Przesuwasz!")
				else:
					placedblock = dragging_block
					update_dictionary(1) # if placed a new block then mode "1"
					print("Stawiasz nowy blok!")
				dragging_column = false
				dragging_block = null
				found_snap = false
				snap = null
				if shadow_cast != null:
					shadow_cast.queue_free()
					shadow_cast = null

func _process(delta: float) -> void:
	
	found_snap = false
	
	# Dragging Handling +++++++++++++++++++++++++++++++++++++++++++++++
	
	#Dragging Blocks
	if dragging_block != null and not dragging_column:
		dragging_block.position = workspace.get_local_mouse_position() - drag_offset
	
	#Dragging Column
	if dragging_column == true and dragging_block != null:
		
		#Well Im co confused by my own code rn that i need those comments
		
		# So Move The Block
		var new_position = workspace.get_local_mouse_position() - drag_offset
		dragging_block.position = new_position
		
		# Search For All Blocks below
		var blocks_to_move = []
		var current = get_block_below(dragging_block.name)
		
		# Collect all of the names below
		while str(current) != "-1":
			blocks_to_move.append(current)
			current = get_block_below(current)
		
		# So If there are bloks below find the offset
		if blocks_to_move.size() > 0:
			var first_below_name = blocks_to_move[0]
			var first_below_node = workspace.find_child(str(first_below_name), true, false)
			
			if first_below_node:
				if Connections.has(dragging_block.name) and Connections.has(first_below_name):
					var original_y_offset = Connections[first_below_name]["position"].y - Connections[dragging_block.name]["position"].y
					
					# And Finally move all of the blocks below
					for i in range(blocks_to_move.size()):
						var block_name = blocks_to_move[i]
						var block_node = workspace.find_child(str(block_name), true, false)
						if block_node:
							block_node.position = Vector2(
								new_position.x,
								new_position.y + (original_y_offset * (i + 1))
							)
					update_positions_in_connections(dragging_block.name)
	
	# So this is the main snapping function
	if dragging_block != null:
		for b in workspace.get_children():
			if is_block_in_column(dragging_block.name, b.name):
				continue
			if b == dragging_block or b == shadow_cast:
				continue
			if not Connections.has(b.name):
				continue

			
			var b_rect = Rect2(b.get_child(0).global_position, b.get_child(0).size*0.7)
			var mouse_pos = get_global_mouse_position()
			
			# UP Check
			if abs(mouse_pos.y - (b_rect.position.y + b_rect.size.y)) < snapping_threshold and \
				mouse_pos.x > b_rect.position.x and \
				mouse_pos.x < b_rect.position.x + b_rect.size.x:
				
				snap_position = Vector2(b.global_position.x, b.global_position.y + b.size.y)
				join_position = Vector2(b.global_position.x, b.global_position.y + b.size.y - join_offset)
				snap = "DOWN"
				connecting_to = b
				connecting_with = dragging_block
				found_snap = true
				break
			
			#Down Check
			if abs(mouse_pos.y - b_rect.position.y) < snapping_threshold and \
				mouse_pos.x > b_rect.position.x and \
				mouse_pos.x < b_rect.position.x + b_rect.size.x:
				
				snap_position = Vector2(b.global_position.x, b.global_position.y - dragging_block.size.y)
				join_position = Vector2(b.global_position.x, b.global_position.y - dragging_block.size.y + join_offset)
				connecting_to = b
				connecting_with = dragging_block
				snap = "UP"
				found_snap = true
				break
	
	if found_snap and dragging_block != null:
		if shadow_cast == null:
			shadow_cast = shadow.instantiate()
			workspace.add_child(shadow_cast)
		shadow_cast.global_position = snap_position
	elif shadow_cast != null:
		shadow_cast.queue_free()
		shadow_cast = null
		snap = null

#Activators below --------------------------------------------------------

func _on_motion_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("change to Motion Tab")

#Trash below -------------------------------------------------------------
func _input(event: InputEvent):
	if event.is_action_pressed("save"):
		var ancestor = self.get_parent().get_parent().get_parent().get_parent().get_parent()
		var SaveManager = ancestor.get_node("SaveManager")
		print(SaveManager)
		SaveManager.save_script(Connections,self.name + ".sc")
	if dragging_block != null:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				var dead_zone_rect = $HBoxContainer/DeadZones.get_global_rect()
				var mouse_pos = get_global_mouse_position()
				
				if dead_zone_rect.has_point(mouse_pos):
					var column_blocks = get_blocks_in_column_below(dragging_block)
					var block_keys = column_blocks.keys()
					
					for block_id in block_keys:
						if not Connections.has(str(block_id)):
							continue
						
						workspace.find_child(block_id,true,false).queue_free()
						Connections.erase(str(block_id))
							
					dragging_block.queue_free()
					
					dragging_block = null
					found_snap = false
					snap = null
					dragging_column = false
					
					if shadow_cast != null:
						shadow_cast.queue_free()
						shadow_cast = null
					return
					
