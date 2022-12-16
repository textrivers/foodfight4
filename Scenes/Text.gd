extends Area3D

signal enable_read_action
signal disable_read_action
var readable: bool = false
@export var poem_text: Dictionary = {
	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var k
	var v
	k = Global.poem_text_dict.keys().pick_random()
	v = Global.poem_text_dict[k]
	poem_text[k] = v
	Global.poem_text_dict.erase(k)


func _on_body_entered(body):
	if body.player == true: 
		readable = true
		emit_signal("enable_read_action", poem_text)


func _on_body_exited(body):
	if body.player == true: 
		readable = false
		emit_signal("disable_read_action")
