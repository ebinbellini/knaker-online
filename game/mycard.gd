extends Node


export var value: int = 2
export var color: int = 1
export var disabled: bool = false

onready var anim = get_node("anim")
onready var front: TextureRect = get_node("Control/front")


func _ready():
	connect("mouse_entered", self, "show_hovered_style")
	connect("mouse_exited", self, "remove_hovered_style")


func show_hovered_style():
	if not disabled:
		anim.playback_speed = 1
		anim.play("hover")


func remove_hovered_style():
	if not disabled:
		anim.playback_speed = -1
		if (not anim.is_playing()):
			anim.play("hover")


func set_card_type(new_value: int, new_color: int, image: Texture):
	value = new_value
	color = new_color
	front.texture = image


func disable_hover():
	# Disables the hovering effect
	disabled = true
