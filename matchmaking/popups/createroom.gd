extends "res://matchmaking/popups/popup.gd"


onready var input = get_node("content/LineEdit")
onready var net = get_node("/root/net")

func submit(_unused):
	net.call_deferred("create_room", input.text)
