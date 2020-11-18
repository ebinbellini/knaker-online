extends ColorRect

onready var anim = get_node("anim")
onready var btn = get_node("Button")


func _ready():
	btn.connect("pressed", self, "remove_popup")


func remove_popup():
	anim.play_backwards("popup")
