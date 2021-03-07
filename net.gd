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
	var peer = WebSocketClient.new()
	peer.connect_to_url("ws://" + SERVER_URL + ":" + str(PORT), PoolStringArray(["ludus"]), true)
	get_tree().network_peer = peer


func create_room(room_name):
	rname = room_name
	room_owner = true
	rpc_id(1, "create_room", room_name)


func join_room(room_name):
	rname = room_name
	room_owner = false
	rpc_id(1, "join_room", room_name)


remote func go_to_waiting_room():
	if get_tree().get_rpc_sender_id() != 1:
		return

	var path = "res://waitingroom/waiting.tscn"
	start.call_deferred("load_and_set_scene", path)


func update_rooms():
	# TODO view list of public rooms
	rpc_id(1, "update_rooms")


func set_username(name):
	rpc_id(1, "set_username", name)
	username = name
	

func is_room_owner():
	return room_owner


func request_start_game():
	rpc_id(1, "request_start_game")


remote func start_loading_game():
	if get_tree().get_rpc_sender_id() != 1:
		return

	var path = "res://game/game.tscn"
	# Wait for the scene to load, then tell the server I am ready
	start.call_deferred("load_and_set_scene", path, self, "ready_for_game")


func ready_for_game():
	# Tell the server that I'm ready to start playing
	rpc_id(1, "ready_for_game")
	call_deferred("get_game_node_ref")


remote func all_players_ready():
	if get_tree().get_rpc_sender_id() != 1:
		return

	game.remove_loader()


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
	if get_tree().get_rpc_sender_id() != 1:
		return

	# Recieve my cards from the server
	my_hand = transferable_array_to_cards(thand)
	my_up = []
	for stack in tup:
		my_up.append(transferable_array_to_cards(stack))
	my_down_count = down_count

	table.update_my_hand(thand)
	table.update_my_up(tup)
	table.update_my_down_count(down_count)


remote func update_player_names(names: Array):
	# names is an array consisting of elements with the form [PID, Username]

	if get_tree().get_rpc_sender_id() != 1:
		return

	for player in names:
		var index = find_player_index(player[0])
		if index == -1:
			# Insert new player
			var new_player: Player = Player.new()
			new_player.id = player[0]
			new_player.name = player[1]
			players.append(new_player)
		else:
			# Update existing player's name
			find_player(player[0]).name = player[1]

	emit_signal("player_count_changed", len(names))


remote func update_player_cards(id: int, hand_count: int, up: Array, down_count: int):
	if get_tree().get_rpc_sender_id() != 1:
		return

	var p = find_player(id)
	p.hand_count = hand_count
	p.up_cards = up
	p.down_count = down_count

	table.update_player_cards(id, up, down_count, hand_count)
	

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


func place_cards(cards: Array):
	rpc_id(1, "place_cards", cards)


remote func unruly_move(reason: String):
	if get_tree().get_rpc_sender_id() != 1:
		return

	table.show_snackbar(tr(reason))


remote func cards_placed(cards: Array, placer_pid: int):
	if get_tree().get_rpc_sender_id() != 1:
		return

	table.cards_placed(cards, placer_pid)


func place_down_card(_card_node: Control):
	rpc_id(1, "place_down_card")


remote func empty_pile():
	if get_tree().get_rpc_sender_id() != 1:
		return

	table.empty_pile()


func leave_game():
	rpc_id(0, "leave_game")
	game.queue_free()
	var waiting_room: Control = get_node("/root/start/Next/WaitingRoom")
	if waiting_room:
		waiting_room.queue_free()


remote func update_done_trading_ammount(ammount: int):
	if get_tree().get_rpc_sender_id() != 1:
		return

	var text: String = str(ammount) + "/" + str(len(players)) + tr("PLAYERS_DONE")
	table.update_done_trading_button_text(text)


remote func start_playing_phase():
	if get_tree().get_rpc_sender_id() != 1:
		return

	table.start_playing_phase()


remote func deck_ammount_changed(ammount: int):
	if get_tree().get_rpc_sender_id() != 1:
		return

	table.update_deck_ammount(ammount)
