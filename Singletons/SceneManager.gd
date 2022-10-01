extends Node

## based checked method used here: 
## https://www.youtube.com/watch?v=TJaeGJ9DADI
## and update to Godot 4:
## https://www.youtube.com/watch?v=_aAr4-j7SI4

@export var max_time = 200000
signal fade_to_black
var transition_squares
var progress = []
var scene_load_status = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_squares = get_node_or_null("/root/Main/TransitionSquares")

func goto_scene(current_scene, path):
	emit_signal("fade_to_black", true)
	await get_node("/root/Main/TransitionSquares").squares_finished
	ResourceLoader.load_threaded_request(path)
	var load_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - load_time < max_time: 
		scene_load_status = ResourceLoader.load_threaded_get_status(path, progress)
		## TODO update anim here
		print(progress[0])
		transition_squares.get_node("SquaresContainer/Sprite50/AnimatedSprite2").frame = int(progress[0] * 12)
		transition_squares.get_node("SquaresContainer/Sprite28/AnimatedSprite2D").frame = int(progress[0] * 8)
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED: #Load_complete
			var resource = ResourceLoader.load_threaded_get(path)
			get_tree().get_root().call_deferred("add_child", resource.instantiate())
			current_scene.queue_free()
			break
#		if err == ERR_FILE_EOF: #Load complete
#			var resource = loader.get_resource()
#			get_tree().get_root().call_deferred("add_child", resource.instantiate())
#			current_scene.queue_free()
#			break
#		elif err == OK:
#			var progress = float(loader.get_stage()) / loader.get_stage_count()
#			progress = int(progress * 12)
#			print(progress)
#			transition_squares.get_node("SquaresContainer/Sprite50/AnimatedSprite2").frame = progress
#			progress = int(progress * 0.67)
#			transition_squares.get_node("SquaresContainer/Sprite28/AnimatedSprite2D").frame = progress
#		else: 
#			print("error, something went wrong during loading?")
#			break
		#await get_tree().idle_frame
	
	await get_tree().create_timer(0.1).timeout
#	var new_scene = load(path).instantiate()
#	current_scene.get_parent().add_child(new_scene)
#	current_scene.get_parent().remove_child(current_scene)
	emit_signal("fade_to_black", false)

