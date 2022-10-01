extends Node

## code from https://www.youtube.com/watch?v=kbDj9V2MZvw, youtube user ACB_Gamez

var materials = [
	preload("res://Materials/SplatSpriteParticlesMaterial.tres"),
	preload("res://Materials/ParticleContainerMatOverrideMaterial.tres")
]

func _ready():
	for material in materials:
		var part_cache = GPUParticles3D.new()
		part_cache.set_process_material(material)
		part_cache.set_one_shot(true)
		#part_cache.set_modulate(Color.WHITE)
		part_cache.set_emitting(true)
		self.add_child(part_cache)

