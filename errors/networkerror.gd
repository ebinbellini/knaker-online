extends Control

onready var anim: AnimationPlayer = get_node("anim")

func retry():
	var net = get_node("/root/net")
	net.connect_to_server()
	anim.play_backwards("display")

