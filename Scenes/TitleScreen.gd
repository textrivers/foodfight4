extends Node2D

var next_scene = "res://Scenes/CharacterSelection.tscn"
var game_start: bool = false
var ice_cream_speed = 0.5

func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	for ice_cream in $IceCreamLights.get_children():
		ice_cream.offset.x -= 1 * ice_cream_speed
		if ice_cream.offset.x < -512:
			ice_cream.offset.x = 1536
			

func _input(event):
	if game_start == false:
		if event is InputEventMouseButton || event is InputEventKey:
			game_start = true
			SceneManager.goto_scene(self, next_scene)

func _on_Timer_timeout():
	$AnyKey.visible = !$AnyKey.visible
