extends Node


onready var loader: Control = get_node("loader")
onready var anim: AnimationPlayer = get_node("anim")


func _ready():
	pass


func remove_loader():
	anim.play("rem_loader")
	
