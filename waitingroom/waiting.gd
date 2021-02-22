extends Node


onready var anim: AnimationPlayer = get_node("CardFlyAnimation/AnimationPlayer")
onready var player_count = get_node("pcount")
onready var net = get_node("/root/net")
onready var button = get_node("coolbutton")

var stop: bool = false
var backwards: bool = false

func _ready():
	anim.connect("animation_finished", self, "restart_video")
	anim.play("cardfly");

	var owner = net.is_room_owner()
	if owner:
		button.visible = true

	net.connect("player_count_changed", self, "player_count_changed")


func restart_video(anim_name: String):
	if not stop:
		backwards = not backwards
		if backwards:
			anim.play_backwards(anim_name)
		else:
			anim.play(anim_name)


func player_count_changed(new_count):
	player_count.text = str(new_count) + tr("PLYRS_IN_ROOM")
	
	
func start_game():
	stop = true
	net.request_start_game()
