extends "res://matchmaking/button.gd"

onready var btn = get_node("Button")
onready var input = get_node("../LineEdit")
onready var net = get_node("/root/net")
onready var start = get_node("/root/start/ColorRect")


func _ready():
	print("TESTAR")
	btn.connect("pressed", self, "create_room")


func create_room():
	net.call_deferred("create_room", input.text)

	var path = "res://waitingroom/waiting.tscn"
	start.call_deferred("load_and_set_scene", path)

