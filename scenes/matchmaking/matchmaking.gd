extends Node


func _ready():
	pass


func slide_in_ui():
	var anim = get_node("Anim")
	anim.play("SlideIn")
