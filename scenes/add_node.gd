extends Window

@onready var tree = $Panel/VBoxContainer/Tree
var CanvasLayer_icon = preload("res://assets/icons/CanvasLayer.svg")
var Button_icon = preload("res://assets/icons/Button.svg")
var Label_icon = preload("res://assets/icons/Label.svg")
var TextEdit_icon = preload("res://assets/icons/TextEdit.svg")
var Sprite_icon = preload("res://assets/icons/sprite.svg")
var AnimPlayer_icon = preload("res://assets/icons/AnimPlayer.svg")
var Texture2D_icon = preload("res://assets/icons/Texture2D.svg")
var Panel_icon = preload("res://assets/icons/Panel.svg")

func item_setup(node_type : String, node_icon : Texture2D, item : TreeItem) -> void:
	item.set_text(0, node_type)
	item.set_metadata(0, node_type)
	item.set_custom_font_size(0, 12)
	item.set_icon(0, node_icon)
	item.set_icon_max_width(0, 15)
	item.collapsed = false


func prepare_tree():
	var root_item = tree.create_item(null)
	root_item.collapsed = false
	tree.hide_root = true

	var canvas_layer_item = tree.create_item(root_item)
	item_setup("CanvasLayer", CanvasLayer_icon, canvas_layer_item)

	var button_item = tree.create_item(canvas_layer_item)
	item_setup("Button", Button_icon, button_item)

	var label_item = tree.create_item(canvas_layer_item)
	item_setup("Label", Label_icon, label_item)

	var text_edit_item = tree.create_item(canvas_layer_item)
	item_setup("TextEdit", TextEdit_icon, text_edit_item)
	
	var panel_item = tree.create_item(canvas_layer_item)
	item_setup("Panel", Panel_icon, panel_item)
	
	var sprite_item = tree.create_item(root_item)
	item_setup("Sprite", Sprite_icon, sprite_item)
	
	var anim_player_item = tree.create_item(sprite_item)
	item_setup("AnimPlayer",AnimPlayer_icon,anim_player_item)
	
	var texture_2d_item = tree.create_item(sprite_item)
	item_setup("Texture2D",Texture2D_icon,texture_2d_item)


func _ready() -> void:
	prepare_tree()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cancel_pressed() -> void:
	hide()


func _on_close_requested() -> void:
	hide()


func _on_add_pressed() -> void:
	var selected_node_data = {
		"name": tree.get_selected().get_text(0),
		"icon": tree.get_selected().get_icon(0),
		"metadata": tree.get_selected().get_metadata(0)
	}
	$"..".add_node_to_tree(selected_node_data)
	hide()
