extends Area3D

@export var type: String = "default"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_FloorFood_body_entered(body):
	if body.is_in_group("character"):
		body.add_to_food_contacts(self)

func _on_FloorFood_body_exited(body):
	if body.is_in_group("character"):
		body.remove_from_food_contacts(self)
