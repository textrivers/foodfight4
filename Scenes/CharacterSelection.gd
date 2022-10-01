extends Node2D

var thumb_calc: int = 0
var thumbnails: Array = [
	"res://Assets/CharacterSprites/Wid_Vanilla.png",
	"res://Assets/CharacterSprites/Wid_Halo.png",
	"res://Assets/CharacterSprites/Wid_Horns.png",
	"res://Assets/CharacterSprites/Wid_HaloHorns.png",
	"res://Assets/CharacterSprites/Uni_Vanilla.png", 
	"res://Assets/CharacterSprites/Uni_Halo.png", 
	"res://Assets/CharacterSprites/Uni_Horns.png", 
	"res://Assets/CharacterSprites/Uni_HaloHorns.png",
	"res://Assets/CharacterSprites/Tal_Vanilla.png",
	"res://Assets/CharacterSprites/Tal_Halo.png",
	"res://Assets/CharacterSprites/Tal_Horns.png",
	"res://Assets/CharacterSprites/Tal_HaloHorns.png",
	"res://Assets/CharacterSprites/Pik_Vanilla.png",
	"res://Assets/CharacterSprites/Pik_Halo.png",
	"res://Assets/CharacterSprites/Pik_Horns.png",
	"res://Assets/CharacterSprites/Pik_HaloHorns.png",
	"res://Assets/CharacterSprites/Ort_Vanilla.png",
	"res://Assets/CharacterSprites/Ort_Halo.png",
	"res://Assets/CharacterSprites/Ort_Horns.png",
	"res://Assets/CharacterSprites/Ort_HaloHorns.png",
	"res://Assets/CharacterSprites/Nor_Vanilla.png",
	"res://Assets/CharacterSprites/Nor_Halo.png",
	"res://Assets/CharacterSprites/Nor_Horns.png",
	"res://Assets/CharacterSprites/Nor_HaloHorns.png",
	"res://Assets/CharacterSprites/Mer_Vanilla.png",
	"res://Assets/CharacterSprites/Mer_Halo.png",
	"res://Assets/CharacterSprites/Mer_Horns.png",
	"res://Assets/CharacterSprites/Mer_HaloHorns.png",
	"res://Assets/CharacterSprites/Cho_Vanilla.png",
	"res://Assets/CharacterSprites/Cho_Halo.png",
	"res://Assets/CharacterSprites/Cho_Horns.png",
	"res://Assets/CharacterSprites/Cho_HaloHorns.png"
]
var next_scene = "res://Scenes/Level3D.tscn"

func _ready():
	pass

func on_thumbnail_changed(thumb_num):
	thumb_calc = thumb_num
	if $CharGUI/VBoxContainer/MainChoiceArea/ThumbsEtc/HBoxContainer/HaloCheck.button_pressed == true:
		thumb_calc += 1
	if $CharGUI/VBoxContainer/MainChoiceArea/ThumbsEtc/HBoxContainer/HornsCheck.button_pressed == true:
		thumb_calc += 2
	$CharGUI/VBoxContainer/MainChoiceArea/PhotoEtc/TextureRect.texture = load(thumbnails[thumb_calc])
	Global.character_sprite = thumbnails[thumb_calc]
	Global.character_light_mask = Global.light_mask_lookup[thumbnails[thumb_calc]]

func on_halo_or_horns(_pressed):
	while thumb_calc % 4 != 0:
		thumb_calc -= 1
	if $CharGUI/VBoxContainer/MainChoiceArea/ThumbsEtc/HBoxContainer/HaloCheck.button_pressed == true:
		thumb_calc += 1
	if $CharGUI/VBoxContainer/MainChoiceArea/ThumbsEtc/HBoxContainer/HornsCheck.button_pressed == true:
		thumb_calc += 2
	$CharGUI/VBoxContainer/MainChoiceArea/PhotoEtc/TextureRect.texture = load(thumbnails[thumb_calc])
	Global.character_sprite = thumbnails[thumb_calc]
	Global.character_light_mask = Global.light_mask_lookup[thumbnails[thumb_calc]]

func on_color_changed(new_color):
	$CharGUI/VBoxContainer/MainChoiceArea/PhotoEtc/TextureRect.self_modulate = new_color
	Global.character_modulate = new_color
	
func _on_DoneButton_pressed():
	SceneManager.goto_scene(self, next_scene)
