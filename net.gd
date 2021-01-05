extends Node

signal player_count_changed(new_num)

const SERVER_URL = "127.0.0.1"
const PORT = 1840


class Player:
	var name: String
	var id: int
	var hand_count: int
	var down_count: int
	var up_cards: Array


class Card:
	var color: int
	var value: int


var my_hand: Array = []
var my_up: Array = []
var my_down_count: int = 3
var players: Array = []

var username = ""
var room_owner = false
var rname = ""

var game: Control
var table: Control

export remote var room_names = []

onready var start = get_node("/root/start/ColorRect")

func _ready():
	connect_to_server()


func connect_to_server():
	print("ANSLUTER NU")
	var peer = WebSocketClient.new()
	peer.connect_to_url("ws://" + SERVER_URL + ":" + str(PORT), PoolStringArray(["ludus"]), true)
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
	

func is_room_owner():
	return room_owner


func request_start_game():
	rpc_id(1, "request_start_game", rname)


remote func start_loading_game():
	var path = "res://game/game.tscn"
	# Wait for the scene to load, then tell the server I am ready
	start.call_deferred("load_and_set_scene", path, self, "ready_for_game")


func ready_for_game():
	# Tell the server that I'm ready to start playing
	rpc_id(1, "ready_for_game", rname)
	call_deferred("get_game_node_ref")


func get_game_node_ref():
	game = get_node("/root/start/Next/game")
	table = game.table
	table.insert_enemy_players(players)


func find_player_index(pid: int) -> int:
	for i in range(player_count()):
		var p = players[i]
		if pid == p.id:
			return i

	return -1


func player_count():
	return len(players)


func find_player(pid: int) -> Player:
	return players[find_player_index(pid)]


remote func update_my_cards(thand: Array, tup: Array, down_count: int):
	# Recieve my cards from the server
	my_hand = transferable_array_to_cards(thand)
	my_up = transferable_array_to_cards(tup)
	my_down_count = down_count

	game.update_my_hand(thand)
	game.update_my_up(tup)


remote func update_player_names(names: Array):
	for player in names:
		var index = find_player_index(player[0])
		if index == -1:
			var new_player: Player = Player.new()
			new_player.id = player[0]
			new_player.name = player[1]
			players.append(new_player)
		else:
			find_player(player[0]).name = player[1]

	emit_signal("player_count_changed", len(names))


remote func update_player_cards(id: int, hand_count: int, up: Array, down_count: int):
	print("JAG ÄR ", get_tree().get_network_unique_id())
	print(id, hand_count, up, down_count)
	var p = find_player(id)
	p.hand_count = hand_count
	p.up_cards = up
	p.down_count = down_count

	table.update_player_cards(id, up, down_count, hand_count)
	# TODO update in GUI as well
	

func card_to_transferable(card: Card) -> Array:
	return [card.value, card.color]
	

func card_array_to_transferable(card_array: Array) -> Array:
	var result: Array = []
	for card in card_array:
		result.append(card_to_transferable(card))
	return result


func transferable_to_card(transferable: Array) -> Card:
	var result = Card.new()
	result.value = transferable[0]
	result.color = transferable[1]
	return result


func transferable_array_to_cards(transferable_array: Array) -> Array:
	var result: Array = []
	for transferable in transferable_array:
		result.append(transferable_to_card(transferable))
	return result
