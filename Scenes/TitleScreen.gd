extends Node2D

var next_scene = "res://Scenes/CharacterSelection.tscn"
var game_start: bool = false

func _ready():
	pass # Replace with function body.

func _input(event):
	if game_start == false:
		if event is InputEventMouseButton || event is InputEventKey:
			game_start = true
			SceneManager.goto_scene(self, next_scene)

func _on_Timer_timeout():
	$AnyKey.visible = !$AnyKey.visible
