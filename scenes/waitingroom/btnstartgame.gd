extends "res://scenes/matchmaking/button.gd"


onready var btn = get_node("Button")
onready var net = get_node("/root/net")
 

func _ready():
	btn.connect("pressed", self, "start_game")


func start_game():
	net.request_start_game()

