extends CanvasLayer

var fade_to_black: bool = true
var can_fade: bool = true
signal squares_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneManager.connect("fade_to_black",Callable(self,"do_fade"))
	randomize()
	for square in $SquaresContainer.get_children():
		square.scale = Vector2(float(!fade_to_black), float(!fade_to_black))

func _process(_delta):
#	if Input.is_action_just_pressed("fade"):
#		if can_fade:
#			do_fade(fade_to_black)
	pass

func do_fade(to_black):
	fade_to_black = to_black
	if can_fade:
		can_fade = false
		var my_delay = 0.015
		var squares = $SquaresContainer.get_children()
		for square in squares:
#			var my_rot = randi() % 2
#			if my_rot == 0:
#				my_rot = 90
#			else:
#				 my_rot = -90
			var my_rot: float = deg_to_rad(90)
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(square, "scale", Vector2(float(fade_to_black), float(fade_to_black)), 0.9) #, Tween.TRANS_CIRC, Tween.EASE_OUT_IN, my_delay)
			tween.tween_property(square, "rotation", square.rotation + my_rot, 0.9) #, Tween.TRANS_QUART, Tween.EASE_OUT, my_delay)
			await get_tree().create_timer(my_delay).timeout
		await get_tree().create_timer(0.915).timeout
		emit_signal("squares_finished")
		#tween.start()
		fade_to_black = !fade_to_black
		can_fade = true

func _on_Tween_tween_all_completed():
	for square in $SquaresContainer.get_children():
		if square.scale != Vector2(1, 1): 
			square.rotation = 0
	can_fade = true
