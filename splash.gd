extends Control

var start = preload("res://Start.tscn")


func go_to_start():
	get_tree().get_root().add_child(start.instance())
	queue_free()
