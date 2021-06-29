extends "res://scenes/matchmaking/popups/popup.gd"


onready var input: LineEdit = get_node("content/LineEdit")
onready var net: Node = get_node("/root/net")
onready var rooms: Control = get_node("content/publicrooms/vbox")
onready var anim_refresh: AnimationPlayer = get_node("content/anim_refresh")

var public_room_entry: Resource = preload("res://scenes/matchmaking/publicroomentry/publicroomentry.tscn")

var awaiting_response = false

func _ready():
	net.connect("public_rooms_recieved", self, "public_rooms_recieved")
	anim_refresh.connect("animation_finished", self, "done_spinning")

	fetch_public_rooms()


func fetch_public_rooms():
	awaiting_response = true

	anim_refresh.play("rotate_refreshbutton")

	for room in rooms.get_children():
		room.queue_free()

	net.get_public_rooms()


func public_rooms_recieved(public_rooms):
	awaiting_response = false

	for room in public_rooms:
		var inst: Control = public_room_entry.instance()
		rooms.add_child(inst)
		inst.call_deferred("set_info", room[0], room[1])
		inst.connect("pressed", net, "join_room", [room[0]])


func done_spinning(_ignored):
	if awaiting_response:
		anim_refresh.play("rotate_refreshbutton")


func submit(_unused):
	net.join_room(input.text)
	remove_popup()

