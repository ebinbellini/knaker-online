extends Node


onready var anim = get_node("anim")


func enter():
	anim.play("enter")
