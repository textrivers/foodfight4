extends Node

@export var board_size: Vector2 = Vector2(5, 5)
@export var tile_size: float = 120
var tile = preload("res://Scenes/BaseTile.tscn")
var offset: Vector2

func _ready():
	offset.x = (get_viewport().size.x / 2.0) + (board_size.y / 2 * tile_size / 2) - (board_size.x / 2 * tile_size / 2)
	offset.y = (get_viewport().size.y / 2.0) - (((board_size.y / 2.0 * tile_size / 2.0) + (board_size.x / 2.0 * tile_size / 2.0)) / 2)
	offset.y += tile_size / 4.0
	print(offset)
	build()

func build():
	for x in board_size.x:
		for y in board_size.y: 
			var new_tile = tile.instantiate()
			new_tile.position.x = (x * (tile_size / 2)) - (y * (tile_size / 2))
			new_tile.position.x += offset.x
			new_tile.position.y = ((x * (tile_size / 2)) + (y * (tile_size / 2))) / 2.0 
			new_tile.position.y += offset.y 
			
			if (x + y) % 2 == 0:
				new_tile.modulate = Color(0.5, 0.5, 0.5)
			add_child(new_tile)
			
