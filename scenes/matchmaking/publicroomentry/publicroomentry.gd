extends Button

onready var room_name_label: Label = get_node("roomname")
onready var player_count_label: Label = get_node("playercount")


func set_info(room_name: String, player_count: int):
	room_name_label.text = room_name
	player_count_label.text = str(player_count) + "/6"
