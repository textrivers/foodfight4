extends Button

signal change_color

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	emit_signal("change_color", $ColorRect.color)

