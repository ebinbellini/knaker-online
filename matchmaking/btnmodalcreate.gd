extends "res://matchmaking/button.gd"

onready var popupanim = get_node("../../popupcreate/anim")
onready var btn = get_node("Button")


func _ready():
	btn.connect("pressed", self, "display_popup")


func display_popup():
	popupanim.play("popup")

