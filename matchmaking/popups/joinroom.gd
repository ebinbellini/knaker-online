extends "res://matchmaking/popups/popup.gd"


onready var input = get_node("content/LineEdit")
onready var net = get_node("/root/net")


func submit():
	net.join_room(input.text)
