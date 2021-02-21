extends Node


onready var video = get_node("video")
onready var player_count = get_node("pcount")
onready var net = get_node("/root/net")
onready var button = get_node("coolbutton")


func _ready():
	video.connect("finished", self, "restart_video")
	video.play()

	var owner = net.is_room_owner()
	if owner:
		button.visible = true

	net.connect("player_count_changed", self, "player_count_changed")


func restart_video():
	video.play()


func player_count_changed(new_count):
	player_count.text = str(new_count) + tr("PLYRS_IN_ROOM")
	
	
func start_game():
	net.request_start_game()
