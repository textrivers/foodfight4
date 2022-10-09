extends CharacterBody3D

#var velocity
var moving: bool = false
var thrown: bool = false
var gravity
var splat = preload("res://Scenes/SplatParticles.tscn")
var floor_splat = preload("res://Scenes/FloorSplat.tscn")
@export var splat_colors: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_parent().get_parent().connect("red_light",Callable(self,"on_red_light"))
	get_parent().get_parent().connect("green_light",Callable(self,"on_green_light"))
	call_deferred("finish_viewport_setup")

func finish_viewport_setup():
	$Sprite3D.texture = $SubViewport.get_texture()
	$SubViewport/FoodSprite/AnimatedSprite2D.play("default", bool(randi() % 2))
	$SubViewport/FoodSprite/AnimatedSprite2D.set_frame(0)
	$SubViewport/FoodSprite/AnimatedSprite2D.playing = false

func _physics_process(delta):
	if position.y < 0: 
		#spawn_splatter_particles(position)
		call_deferred("queue_free")
	if moving:
		var collided = move_and_slide()
		velocity.y -= gravity * delta
		if collided: 
			var last_coll = get_last_slide_collision()
			for splat_col in splat_colors:
				spawn_splatter_particles(last_coll.get_position(), splat_col)
			if last_coll.get_collider().is_in_group("character"):
				last_coll.get_collider().add_splatter(splat_colors[randi() % splat_colors.size()])
			for i in ((randi() % 3) + 1):
				var new_floor_splat = floor_splat.instantiate()
				new_floor_splat.modulate = splat_colors[randi() % splat_colors.size()]
				new_floor_splat.position = last_coll.get_position()
				new_floor_splat.position.x += randf() - 0.5
				new_floor_splat.position.y = 0.07
				new_floor_splat.position.z += randf() - 0.5
				new_floor_splat.rotation.y += randf() * PI
				get_parent().add_child(new_floor_splat)
			call_deferred("queue_free")

func spawn_splatter_particles(pos, col):
	var new_splat = splat.instantiate()
	new_splat.position = pos
	new_splat.emitting = true
	new_splat.material_override.albedo_color = col
	get_parent().add_child(new_splat)

func on_red_light():
	if thrown:
		moving = false
		$SubViewport/FoodSprite/AnimatedSprite2D.playing = false

func on_green_light():
	if thrown:
		moving = true
		$SubViewport/FoodSprite/AnimatedSprite2D.playing = true

func _on_Area_body_entered(body):
	if !thrown:
		if body.is_in_group("character"):
			body.add_to_food_contacts(self)

func _on_Area_body_exited(body):
	if !thrown:
		if body.is_in_group("character"):
			body.remove_from_food_contacts(self)
