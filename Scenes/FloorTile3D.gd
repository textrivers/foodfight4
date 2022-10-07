extends MeshInstance3D

var selecting: bool = false
var selected: bool = false
var revert_color: Color

@export var tile_description: String

signal give_on_select_info

func _ready():
	revert_color = material_override.albedo_color

func on_target_selecting():
	selecting = true
	_on_StaticBody_mouse_exited()

func on_target_unselecting():
	selecting = false

func _on_StaticBody_mouse_entered():
	if selecting == true && selected == false:
		material_override.albedo_color = Color.HOT_PINK

func _on_StaticBody_mouse_exited():
	if selecting == true && selected == false:
		material_override.albedo_color = revert_color

func _on_StaticBody_input_event(_camera, _event, _position, _normal, _shape_idx):
	if selecting:
		if Input.is_action_just_pressed("left_click"):
			for child in get_tree().get_nodes_in_group("selectable"):
				if child.selected:
					child.selected = false
					if child.is_in_group("character"):
						child.get_node("SubViewport/CharacterSprite").modulate = child.revert_color
					else:
						child.material_override.albedo_color = child.revert_color
			selected = true
			material_override.albedo_color = Color.CRIMSON
			emit_signal("give_on_select_info", global_position, tile_description)
