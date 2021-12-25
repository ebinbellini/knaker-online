# Copyright (C) 2021 Ebin Bellini ebinbellini@airmail.cc

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

extends Node

signal player_names_changed(new_names)
signal public_rooms_recieved(public_rooms)

const SERVER_URL = "localhost"
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

onready var start = get_node("/root/start/ColorRect")

func _ready():
	connect_to_server()


func connect_to_server():
	var peer = WebSocketClient.new()
	peer.connect_to_url("ws://" + SERVER_URL + ":" + str(PORT), PoolStringArray(["ludus"]), true)
	get_tree().network_peer = peer


func create_room(room_name, public):
	rname = room_name
	room_owner = true
	players = []
	rpc_id(1, "create_room", room_name, public)


func join_room(room_name):
	rname = room_name
	room_owner = false
	players = []
	rpc_id(1, "join_room", room_name)


func get_public_rooms():
	rpc_id(1, "get_public_rooms")


remote func recieve_public_rooms(public_rooms: Array):
	if get_tree().get_rpc_sender_id() != 1:
		return

	emit_signal("public_rooms_recieved", public_rooms)


remote func go_to_waiting_room():
	if get_tree().get_rpc_sender_id() != 1:
		return

	load_and_go_to_waiting_room()


func load_and_go_to_waiting_room():
	var path = "res://scenes/waitingroom/waiting.tscn"
	start.call_deferred("load_and_set_scene", path)


func update_rooms():
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

	var path = "res://scenes/game/game.tscn"
	# Wait for the scene to load, then tell the server I am ready
	start.call_deferred("load_and_set_scene", path)


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


remote func update_my_cards(thand: Array, tup: Array, down_count: int, locked_up_indexes: Array):
	if get_tree().get_rpc_sender_id() != 1:
		return

	# Recieve my cards from the server
	my_hand = transferable_array_to_cards(thand)
	my_up = []
	for stack in tup:
		my_up.append(transferable_array_to_cards(stack))
	my_down_count = down_count

	table.update_my_hand(thand)
	table.update_my_up(tup, locked_up_indexes)
	table.update_my_down_count(down_count)


remote func update_player_names(names: Array):
	# names is an array consisting of elements with the form
	# [pid: Int, username: String]

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

	emit_signal("player_names_changed", get_player_names())


func get_player_names() -> Array:
	var names = []
	for p in players:
		names.append(p.name)

	return names


remote func update_player_cards(id: int, hand_count: int, up: Array, down_count: int, locked_up_indexes: Array):
	if get_tree().get_rpc_sender_id() != 1:
		return

	var p = find_player(id)
	p.hand_count = hand_count
	p.up_cards = up
	p.down_count = down_count

	table.update_player_cards(id, up, down_count, hand_count, locked_up_indexes)
	

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


func place_down_card():
	rpc_id(1, "place_down_card")


remote func empty_pile():
	if get_tree().get_rpc_sender_id() != 1:
		return

	table.empty_pile()


func leave_game():
	rpc_id(1, "leave_game")
	var path = "res://scenes/matchmaking/matchmaking.tscn"
	start.call_deferred("load_and_set_scene", path)


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


remote func player_finished(pid: int, reason: String):
	if get_tree().get_rpc_sender_id() != 1:
		return

	# Only care about other players for now
	if pid != get_tree().get_network_unique_id():
		table.player_finished(pid, reason)
	else:
		table.i_am_finished(reason)


remote func go_to_leaderboard(order: Array):
	if get_tree().get_rpc_sender_id() != 1:
		return

	game.go_to_leaderboard(order)


remote func update_players_who_want_to_play_again(ammount: int):
	if get_tree().get_rpc_sender_id() != 1:
		return

	game.update_players_who_want_to_play_again(ammount)


remote func restart_game():
	if get_tree().get_rpc_sender_id() != 1:
		return
		
	game.restart_game()
	load_and_go_to_waiting_room()


remote func this_player_has_turn(has_turn_pid: int):
	if get_tree().get_rpc_sender_id() != 1:
		return
		
	if has_turn_pid == get_tree().get_network_unique_id():
		table.my_turn()
	else:
		table.new_player_has_turn(has_turn_pid)
