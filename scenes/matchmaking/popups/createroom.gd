extends "res://scenes/matchmaking/popups/popup.gd"


onready var input: LineEdit = get_node("content/LineEdit")
onready var public_checkbox: CheckBox = get_node("content/PublicCheckbox")
onready var net = get_node("/root/net")


func submit(_unused):
	net.call_deferred("create_room", input.text, public_checkbox.pressed)
	remove_popup()
