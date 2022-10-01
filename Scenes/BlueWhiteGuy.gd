extends Area2D

var blue: bool = false
@export var cooldown: float = 400.0
var cooldown_over: float

# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	cooldown_over = cooldown
	modulate = Color.GRAY

func _draw():
	draw_circle(Vector2(0, 0), 10.0, Color.WHITE)

func _process(delta):
	## check if clock is already paused
	if !Clock.paused:
		## check if it's my turn
		if Clock.time >= cooldown_over:
			## if so, pause clock
			Clock.paused = true
			## start wait timer
			$AnimationPlayer.play("yourturn")
			$Timer.wait_time = 3.0
			$Timer.start()

func _on_Timer_timeout():
	$AnimationPlayer.stop(true)
	## change color
	blue = !blue
	if blue:
		modulate = Color.cornflower
	else:
		modulate = Color.GRAY
	## add cooldown to list
	cooldown_over = Clock.time + cooldown
	Clock.paused = false
