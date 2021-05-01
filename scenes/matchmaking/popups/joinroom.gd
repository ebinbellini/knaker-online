extends "res://scenes/matchmaking/popups/popup.gd"


onready var input = get_node("content/LineEdit")
onready var net = get_node("/root/net")
onready var rooms = get_node("content/publicrooms/vbox")

var public_room_entry: Resource = preload("res://scenes/matchmaking/publicroomentry/publicroomentry.tscn")


func _ready():
	net.connect("public_rooms_recieved", self, "public_rooms_recieved")
	fetch_public_rooms()


func fetch_public_rooms():
	for room in rooms.get_children():
		room.queue_free()

	net.get_public_rooms()


func public_rooms_recieved(public_rooms):
	for room in public_rooms:
		var inst: Control = public_room_entry.instance()
		rooms.add_child(inst)
		inst.call_deferred("set_info", room[0], room[1])
		inst.connect("pressed", net, "join_room", [room[0]])


func submit(_unused):
	net.join_room(input.text)
	remove_popup()

