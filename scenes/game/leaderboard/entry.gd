extends Control

onready var image: TextureRect = get_node("img")
onready var label: Label = get_node("Label")
onready var anim: AnimationPlayer = get_node("AnimationPlayer")


func _ready():
	anim.play("show")


func set_player_name(name: String):
	label.set_text(name)


func set_image(img: Texture):
	image.texture = img
