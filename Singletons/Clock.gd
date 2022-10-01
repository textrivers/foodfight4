extends Node

var time: int = 0
var interval: int = 5
var last_stamp: int = 0
var current_stamp: int = 0
var paused: bool = false
var progress: int

signal time_is

func _physics_process(delta):
	if !paused:
		time += 1
	emit_signal("time_is", time, paused)
