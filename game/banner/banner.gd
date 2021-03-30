extends Control

onready var anim: AnimationPlayer = get_node("anim")
onready var label: Label = get_node("arrow/Label")


func display_message(message: String):
	label.set_text(message)
	anim.play("display")
