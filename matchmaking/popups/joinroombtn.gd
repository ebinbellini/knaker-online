extends "res://matchmaking/button.gd"


onready var btn = get_node("Button")
onready var input = get_node("../LineEdit")
onready var net = get_node("/root/net")
onready var start = get_node("/root/start/ColorRect")


func _ready():
	btn.connect("pressed", self, "submit")


func submit():
	net.join_room(input.text)
