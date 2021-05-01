extends Control

onready var name_label: Label = get_node("name")

func set_name(new_name: String):
	name_label.set_text(new_name)
