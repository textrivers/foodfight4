extends Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Timer.wait_time = (randf() / 2) + 0.5
	for character in get_tree().get_nodes_in_group("character"):
		if character.player == true:
			if self.global_position.distance_to(character.global_position) < Global.character_proximity_radius:
				$Timer.start()
			else: 
				queue_free()
	get_parent().connect("red_light",Callable(self,"on_red_light"))
	get_parent().connect("green_light",Callable(self,"on_green_light"))

func _on_Timer_timeout():
	self.show()

func on_red_light():
	$Timer.paused = true

func on_green_light():
	$Timer.paused = false
