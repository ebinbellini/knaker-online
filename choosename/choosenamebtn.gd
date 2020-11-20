extends "res://matchmaking/button.gd"


onready var net = get_node("/root/net")
onready var input = get_node("../LineEdit")
onready var btn = get_node("Button")
onready var start = get_node("/root/start/ColorRect")


func _ready():
	btn.connect("pressed", self, "submit")


func submit():
	net.call("set_username", input.text)

	var path = "res://matchmaking/matchmaking.tscn"
	start.call_deferred("load_and_set_scene", path)

