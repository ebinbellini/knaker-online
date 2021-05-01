extends "res://scenes/matchmaking/popups/popup.gd"


onready var net = get_node("/root/net")


func confirm():
	net.leave_game()


func cancel():
	remove_popup()
