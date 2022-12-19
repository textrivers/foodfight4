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
	await transition_squares.squares_finished
	current_scene.call_deferred("queue_free")
	await current_scene.tree_exited
	await get_tree().create_timer(0.1).timeout
	print("previous scene freed")
	var resource = load(path)
	await get_tree().create_timer(0.1).timeout
	print("new scene loaded")
	var main = get_tree().get_root().get_node("Main")
	#await get_tree().create_timer(0.1).timeout
	var new_res = resource.instantiate()
	#await get_tree().create_timer(0.1).timeout
	main.call_deferred("add_child", new_res)
	#await get_tree().create_timer(0.1).timeout
	await new_res.tree_entered
	print("new scene added to tree")
#	ResourceLoader.load_threaded_request(path)
#	var load_time = Time.get_ticks_msec()
#	while Time.get_ticks_msec() - load_time < max_time: 
#		scene_load_status = ResourceLoader.load_threaded_get_status(path, progress)
#		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED: #Load_complete
#			print("done loading")
#			var resource = ResourceLoader.load_threaded_get(path)
#			var main = get_tree().get_root().get_node("Main")
#			var new_res = resource.instantiate()
#			main.call_deferred("add_child", new_res)
#			## TODO may not need this await statement, it doesn't seem to do anything
#			await new_res.tree_entered
#			break
	await get_tree().create_timer(0.1).timeout
	emit_signal("fade_to_black", false)
	print("squares fade out")
	

