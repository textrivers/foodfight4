extends Area2D

var dir: Vector2 = Vector2.ZERO
var pos_target: Vector2
@export var cooldown: float = 120.0
var cooldown_over: float
var my_turn: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	cooldown_over = cooldown

func _process(delta):
	dir = Vector2.ZERO
#	if Clock.time >= cooldown_over:
#		$AnimationPlayer.play("yourturn")
#		my_turn = true
#		Clock.paused = true
#	if !Clock.paused:
#		move_player()
#	else:
#		if my_turn:
#			handle_input()
#			if dir != Vector2.ZERO:
#				my_turn = false
#				Clock.paused = false
#				cooldown_over = Clock.time + cooldown
#				$AnimationPlayer.stop(true)

func handle_input():
	if Input.is_action_just_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_just_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_just_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_just_pressed("ui_down"):
		dir.y += 1
	pos_target.x += (dir.x * 60) - (dir.y * 60)
	pos_target.y += (dir.x * 30) + (dir.y * 30) 

func move_player():
	if !position.is_equal_approx(pos_target):
		position = lerp(position, pos_target, 0.2)

func _draw():
	draw_circle(Vector2.ZERO, 10.0, Color.CRIMSON)
