extends GPUParticles3D

var porous: bool = false
var extra: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if randi() % 3 == 0:
		porous = true
	if randi() % 2 == 0:
		extra = true
	get_parent().connect("red_light",Callable(self,"_on_red_light"))
	get_parent().connect("green_light",Callable(self,"_on_green_light"))
	material_override = material_override.duplicate()
	material_override.albedo_texture = get_parent().get_node("SubViewport").get_texture()
	if porous:
		get_parent().get_node("SubViewport/PartSprite/PointLight2D").show()
	if extra:
		get_parent().get_node("SubViewport/PartSprite/Sprite3").show()
	$AnimationPlayer.play("splort")
	$SubViewport/PartSprite/Sprite2.offset = Vector2(randf() * 84, randf() * 84)

func _on_red_light():
	speed_scale = 0
	$Timer.set_paused(true) 
	$AnimationPlayer.stop(false)

func _on_green_light():
	speed_scale = 1
	$Timer.set_paused(false) 
	$AnimationPlayer.play()

func _on_Timer_timeout():
	call_deferred("queue_free")
