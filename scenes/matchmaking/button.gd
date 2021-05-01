extends Node

onready var anim = get_node("anim")
onready var botan = get_node("Button")

func _ready():
	botan.connect("mouse_entered", self, "show_hovered_style")
	botan.connect("mouse_exited", self, "remove_hovered_style")

func show_hovered_style():
	anim.playback_speed = 1
	anim.play("hover")

func remove_hovered_style():
	if (anim.is_playing()):
		anim.playback_speed = -1
	else:
		anim.play_backwards("hover")

