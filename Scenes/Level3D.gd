extends Node3D

@export var board_size: Vector2 = Vector2(5, 5)
@export var tile_size: float = 1
var tile = preload("res://Scenes/FloorTile3D.tscn")

var characters: Array = []
var turn_tracker: Dictionary = {}
var whose_turn = null

var cam_rig_rot_target: Vector2
var cam_rig_zoom_target: float = 10.0
var cam_rig_trans_target
var cam_rig
@export var mouse_sensitivity = 0.008


var GUI
var current_action = []
var AI_actions = [
	["wait", null, 100],
	["pick_up", null, 25],
	["throw", null, 25],
	["walk", null, 25],
]
var action_target: Vector3
var turn_marker
var current_moment: int = 0
var advancing: bool = true

signal red_light
signal green_light
signal GUI_action_taken
signal selecting_action_target
signal done_selecting_action_target

func _ready():
	randomize()
	cam_rig = $CameraRig
	GUI = $GUI
	turn_marker = $TurnMarker
	cam_rig_rot_target = Vector2(cam_rig.rotation.y, cam_rig.rotation.x)
	cam_rig_zoom_target = $CameraRig/Camera3D.position.z
	build()
	for character in get_tree().get_nodes_in_group("character"):
		register_character(character)
	current_action.resize(3)

func build():
	var tot = board_size.x * board_size.y
	@warning_ignore(unused_variable)
	var rando = randi() % int(tot) + 1
	@warning_ignore(unused_variable)
	var rand_index = 0
	for x in int(board_size.x):
		for y in int(board_size.y): 
			rand_index += 1
#			if rand_index == rando: ## randomly don't place this tile
#				continue
			var new_tile = tile.instantiate()
			new_tile.position.x = (x * tile_size)
			new_tile.position.z = (y * tile_size)
			var new_mat = StandardMaterial3D.new()
			new_mat.albedo_color = Color.WHITE
			new_tile.set_material_override(new_mat)
			if (x + y) % 2 == 0:
				if randi() % 2 == 0: 
					new_tile.material_override.albedo_color = Global.palette_dict["babyblue_1"]
				else:
					new_tile.material_override.albedo_color = Global.palette_dict["babyblue_2"]
			else:
				if randi() % 2 == 0:
					new_tile.material_override.albedo_color = Global.palette_dict["black_2"]
				else:
					new_tile.material_override.albedo_color = Global.palette_dict["teal_3"]
			
			add_child(new_tile)
			new_tile.connect("give_on_select_info",Callable(self,"on_action_target_selected"))
			self.connect("selecting_action_target",Callable(new_tile,"on_target_selecting"))
			self.connect("done_selecting_action_target",Callable(new_tile,"on_target_unselecting"))

func register_character(_char):
	turn_tracker[_char] = 0
	self.connect("red_light",Callable(_char,"on_red_light"))
	self.connect("green_light",Callable(_char,"on_green_light"))
	_char.connect("give_on_select_info",Callable(self,"on_action_target_selected"))
	self.connect("selecting_action_target",Callable(_char,"on_target_selecting"))
	self.connect("done_selecting_action_target",Callable(_char,"on_target_unselecting"))
	if _char.player:
		cam_rig_trans_target = _char.get_node("TargetPosition")
	## label in left panel
#	var lab = load("res://Scenes/TurnDisplay.tscn").instantiate()
#	lab.get_node("HBoxContainer/NameLabel").text = _char.name
#	lab.get_node("HBoxContainer/TimeLabel").text = str(0)
#	lab.turn_disp_editable = true
#	GUI.get_node("Left").add_child(lab)

func _input(event):
	if event is InputEventMouseMotion && Input.is_action_pressed("right_click"):
		cam_rig_rot_target.x += (event.relative.x * mouse_sensitivity * -1)
		cam_rig_rot_target.y += (event.relative.y * mouse_sensitivity * -1)
	if Input.is_action_just_released("scroll_in"):
		cam_rig_zoom_target -= 1.0
	if Input.is_action_just_released("scroll_out"):
		cam_rig_zoom_target += 1.0
	cam_rig_zoom_target = clamp(cam_rig_zoom_target, 1.0, 10.0)

func _on_HSlider_value_changed(value):
	Global.AI_turn_delay = value
	$GUI/Left/TurnDelayLabel.text = "Opponent turn delay: " + str(value)

func _physics_process(_delta):
	advance_time()
	prompt_turns()
	translate_cam_rig()
	rotate_cam_rig()

func advance_time():
	if advancing:
		current_moment += 1
	#$GUI/Left/TurnDisplay/HBoxContainer/TimeLabel.text = str(current_moment)

func prompt_turns():
	if advancing:
		for turn in turn_tracker:
			if current_moment >= turn_tracker[turn]:
				current_action.clear()
				current_action.resize(3)
				action_target = Vector3.ZERO
				advancing = false
				emit_signal("red_light")
				turn_marker.show()
				turn_marker.position.x = turn.position.x
				turn_marker.position.z = turn.position.z
				whose_turn = turn
				display_character_options(turn.player)
				if !turn.player:
					AI_action_select()
#				else:
#					turn.walking = false
				await self.GUI_action_taken
				resolve_turn()

func AI_action_select():
	await get_tree().create_timer(Global.AI_turn_delay).timeout
	## decide action
	var AI_rand = randi() % 4
	if AI_rand == 0: ## 1 in 4 chance to just stand there doing nothing
		current_action = AI_actions[0].duplicate(false) ## wait 100 
	elif AI_rand == 1:
		current_action = AI_actions[3].duplicate(false) ## walk somewhere
	else:
		if whose_turn.has_node("MyFood"):
			current_action = AI_actions[2].duplicate(false) ## throw
		else:
			if whose_turn.food_contacts.size() > 0:
				current_action = AI_actions[1].duplicate(false) ## pick up
			else:
				current_action = AI_actions[3].duplicate(false) ## walk
	## set action parameters
	if current_action[0] == "wait":
		pass
	if current_action[0] == "pick_up":
		pass
	if current_action[0] == "throw":
		var targets = get_tree().get_nodes_in_group("character").duplicate()
		targets.erase(whose_turn)
		var throw_target = targets[randi() % targets.size()]
		current_action[1] = throw_target.bullseye
	if current_action[0] == "walk":
		if get_tree().get_nodes_in_group("throwable").size() > 0:
			action_target = find_closest_food()
			current_action[1] = action_target
		else:
			action_target.x = randi() % int(board_size.x)
			action_target.y = 0
			action_target.z = randi() % int(board_size.y)
			current_action[1] = action_target
		current_action[2] = calculate_walk_duration()
	reset_character_options()
	hide_character_options()
	emit_signal("GUI_action_taken")

func find_closest_food():
	var nearest = null
	var food_array = get_tree().get_nodes_in_group("throwable")
	for food in food_array: 
		if nearest == null:
			nearest = food
			continue
		elif whose_turn.position.distance_to(food.to_global(food.position)) < whose_turn.position.distance_to(nearest.to_global(nearest.position)):
			nearest = food
	var nearest_translation = (nearest.position + nearest.get_parent().position)
	return Vector3(nearest_translation.x, 0, nearest_translation.z)

func resolve_turn():
	## send the action info to the character
	whose_turn.handle_action(current_action.duplicate(false))
	## send the action info to the GUI
	turn_tracker[whose_turn] += int(ceil(current_action[2]))
	## cleanup and proceed
	whose_turn = null
	advancing = true
	emit_signal("green_light")
	turn_marker.hide()
	reorder_character_display()

func reorder_character_display():
	## make array of turn_tracker values
	var display_array = []
	for character in turn_tracker:
		if display_array.size() == 0:
			display_array.append([character.name, turn_tracker[character]])
		else: ## append in order
			var index = 0
			for i in display_array: 
				if turn_tracker[character] <= i[1]:
					display_array.insert(index, [character.name, turn_tracker[character]])
					break
				else:
					index += 1
					continue
			if index >= display_array.size():
				display_array.insert(index, [character.name, turn_tracker[character]])
	## set text values of Left/labels 
#	var index = 0
#	for child in $GUI/Left.get_children():
#		if "turn_disp_editable" in child:
#			if !child.turn_disp_editable:
#				continue
#			else:
#				child.get_node("HBoxContainer/NameLabel").text = display_array[index][0] + " (" + current_action[0] + ")"
#				child.get_node("HBoxContainer/TimeLabel").text = str(display_array[index][1])
#				index += 1

func translate_cam_rig():
	cam_rig.position = cam_rig_trans_target.to_global(cam_rig_trans_target.position)
	if $CameraRig/Camera3D.position.z != cam_rig_zoom_target:
		$CameraRig/Camera3D.position.z = lerp($CameraRig/Camera3D.position.z, cam_rig_zoom_target, 0.2)

func rotate_cam_rig():
	# clamp value so you can only look so high or low
	cam_rig_rot_target.y = clamp(cam_rig_rot_target.y, deg_to_rad(-30), deg_to_rad(20))
	if cam_rig.rotation.x != cam_rig_rot_target.y:
		var new_rad_y = cam_rig_rot_target.y
		cam_rig.rotation.x = lerp_angle(cam_rig.rotation.x, new_rad_y, 0.1)
	if cam_rig.rotation.y != cam_rig_rot_target.x:
		var new_rad_x = cam_rig_rot_target.x
		cam_rig.rotation.y = lerp_angle(cam_rig.rotation.y, new_rad_x, 0.2)

func display_character_options(_player):
	reset_character_options()
	$Panel.show()
	$GUI/Right.show()
	$GUI/Right/PlayerOptions.show()
	if _player == true: 
		$GUI/Right/PlayerOptions/Label.text = "It is your turn"
		for button in $GUI/Right/PlayerOptions.get_children():
			if button is Button:
				button.disabled = false
		if whose_turn.has_node("MyFood"):
			$GUI/Right/PlayerOptions/PickUp.disabled = true
		else:
			$GUI/Right/PlayerOptions/Throw.disabled = true
		if whose_turn.food_contacts.size() == 0:
			$GUI/Right/PlayerOptions/PickUp.disabled = true
		if Global.splat_count >= Global.splat_threshold:
			$GUI/Right/PlayerOptions/Read.disabled = false
		else:
			$GUI/Right/PlayerOptions/Read.disabled = true
	else: 
		$GUI/Right/PlayerOptions/Label.text = "It is " + str(whose_turn.name) + "'s turn"
		for button in $GUI/Right/PlayerOptions.get_children():
			if button is Button:
				button.disabled = true

func reset_character_options():
	for child in $GUI/Right/PlayerOptions.get_children():
		child.show()
	$GUI/Right/WaitOptions.hide()
	$GUI/Right/WalkOptions.hide()
	$GUI/Right/ThrowOptions.hide()
	$GUI/Right/ProceedCancel.hide()
	$GUI/Right/ProceedCancel/Proceed.hide()

func hide_character_options():
	$Panel.hide()
	$GUI/Right.hide()

func _on_PickUp_pressed():
	current_action[0] = "pick_up"
	current_action[2] = 25
	_on_Proceed_pressed()

func _on_Throw_pressed():
	$GUI/Right/PlayerOptions.hide()
	$GUI/Right/ThrowOptions.show()
	$GUI/Right/ProceedCancel.show()
	current_action[0] = "throw"
	current_action[2] = 25
	emit_signal("selecting_action_target")

func _on_Wait_pressed():
	$GUI/Right/PlayerOptions.hide()
	$GUI/Right/WaitOptions.show()
	$GUI/Right/ProceedCancel.show()
	$GUI/Right/ProceedCancel/Proceed.show()
	current_action[0] = "wait"

func _on_Walk_pressed():
	$GUI/Right/PlayerOptions.hide()
	$GUI/Right/WalkOptions.show()
	$GUI/Right/ProceedCancel.show()
	current_action[0] = "walk"
	emit_signal("selecting_action_target")

func calculate_walk_duration():
	var walk_dur: float
	var dist = whose_turn.position.distance_to(action_target)
	walk_dur = dist / whose_turn.walk_speed * 60
	return walk_dur

@warning_ignore(unused_parameter)
func on_action_target_selected(dest, _desc):
	action_target = dest
	_on_Proceed_pressed()

func _on_Proceed_pressed():
	emit_signal("done_selecting_action_target")
	if current_action[0] == "wait":
		if whose_turn.player:
			current_action[2] = $GUI/Right/WaitOptions/WaitDuration.value
		else: 
			current_action[2] = (randi() % 101) + 25
	if current_action[0] == "throw":
		current_action[1] = action_target
	if current_action[0] == "walk": ## player character calculates duration
		current_action[1] = action_target
		## TODO calculate duration and assign it to current_action[2]
		current_action[2] = calculate_walk_duration()
	reset_character_options()
	hide_character_options()
	emit_signal("GUI_action_taken")

func _on_Cancel_pressed():
	display_character_options(true)
	current_action = []
	current_action.resize(3)
	emit_signal("selecting_action_target")
	emit_signal("done_selecting_action_target")

func _on_CheckButton_toggled(button_pressed):
	if button_pressed == true:
		Global.AI_turn_delay = 3
	else:
		Global.AI_turn_delay = 0.01
