extends Node


onready var anim = get_node("anim")
onready var input = get_node("LineEdit")
onready var net = get_node("/root/net")
onready var start = get_node("/root/start/ColorRect")


func enter():
	anim.play("enter")
	input.grab_focus()
	

func choose_name(_unused):
	net.call_deferred("set_username", input.text)
	start.load_and_set_scene("res://scenes/matchmaking/matchmaking.tscn")
