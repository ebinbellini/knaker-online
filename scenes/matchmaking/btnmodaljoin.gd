extends "res://scenes/matchmaking/button.gd"

onready var popup = get_node("../../popupjoin")
onready var btn = get_node("Button")


func _ready():
	btn.connect("pressed", self, "display_popup")


func display_popup():
	popup.display()
