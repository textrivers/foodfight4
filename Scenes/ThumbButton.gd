extends Button

signal change_thumb

@export var thumb_num: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	emit_signal("change_thumb", self.thumb_num)
