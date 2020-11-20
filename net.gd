extends Node

signal player_count_changed(new_num)

const IP = "127.0.0.1"
const PORT = 1840

var username = ""

var room_owner = false
var rname = ""

var pnames = []
var pids = []

onready var start = get_node("/root/start/ColorRect")

export remote var room_names = []


func _ready():
	connect_to_server()


func connect_to_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(IP, PORT)
	get_tree().network_peer = peer


func create_room(room_name):
	print("SKAPAR RUM ", room_name)
	rname = room_name
	room_owner = true
	print("begärde att få skapa rum " + room_name)
	rpc_id(1, "create_room", room_name)


func join_room(room_name):
	rname = room_name
	room_owner = false
	print("begärde att gå med i rum " + room_name)
	rpc_id(1, "join_room", room_name)


remote func go_to_waiting_room():
	var path = "res://waitingroom/waiting.tscn"
	start.call_deferred("load_and_set_scene", path)


func update_rooms():
	rpc_id(1, "update_rooms")
	print(room_names)


func set_username(name):
	print("sätter ", name)
	rpc_id(1, "set_username", name)
	username = name
	

remote func update_player_data(new_num, names, ids):
	emit_signal("player_count_changed", new_num)
	pnames = names
	pids = ids
	print(pnames)
	print(pids)


func is_room_owner():
	return room_owner


func request_start_game():
	rpc_id(1, "request_start_game", rname)


remote func start_game():
	var path = "res://game/game.tscn"
	start.call_deferred("load_and_set_scene", path)

