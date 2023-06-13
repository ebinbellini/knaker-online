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


onready var loader: Control = get_node("loader")
onready var anim: AnimationPlayer = get_node("anim")
onready var table: Control = get_node("table")

onready var net: Node = get_node("/root/net")

var card_backside_texture: Resource = preload("res://cards/baksida.png")
var leaderboard: Resource = preload("res://scenes/game/leaderboard/leaderboard.tscn")
var table_res: Resource = preload("res://scenes/game/table.tscn")

var leaderboard_instance: Control = null

enum { Spade, Heart, Diamond, Clover }
enum { Knight = 11, Queen, King, Ace, Knaker }

class CardTexture:
	var color: int
	var value: int
	var res: Resource

class Card:
	var color: int
	var value: int

onready var textures: Array = []


func _ready():
	prepare_game_scene()

	# Tell the server that I've finished loading
	net.ready_for_game()


func prepare_game_scene():
	load_textures()
	table.disable_down_cards()


func remove_loader():
	anim.play("rem_loader")
	

func load_textures():
	var color_folders: Array = ["spades", "heart", "diamonds", "clovers"]
	var unique_names: Array = ["knekt", "drottning", "knug", "ess"]

	# Load regular cards textures
	for color in [ Spade, Heart, Diamond, Clover ]:
		# 2 - 10, Kn 11, Q 12, K 13, A 14
		for value in range(2, 15):
			# Find the folder
			var folder: String = color_folders[color]
			var name: String = str(value)

			# Find the name of the file
			if (value > 10):
				name = unique_names[value - 11]

			# Combine into complete path
			var path = "res://cards/" + folder + "/" + name + ".png"

			# Create texture object
			var txr = CardTexture.new()
			txr.color = color
			txr.value = value

			# Load texture
			txr.res = load(path)

			# Store texture
			textures.append(txr)

	# Load knaker textures
	for card in [["res://cards/knakers/black knaker.png", Spade], ["res://cards/knakers/red knaker.png", Clover], ["res://cards/knakers/red knaker.png", Heart]]:
		var txr = CardTexture.new()

		txr.value = Knaker
		txr.color = card[1]
		txr.res = load(card[0])

		textures.append(txr)

	# Load empty card texture
	var txr = CardTexture.new()
	txr.value = 1
	txr.color = Spade
	txr.res = load("res://cards/cardoutline.png")

	textures.append(txr)


func find_card_texture(card: Array) -> Texture:
	for txr in textures:
		if txr.value == card[0] && txr.color == card[1]:
			return txr.res

	return null


func go_to_leaderboard(order: Array):
	var inst = leaderboard.instance()
	leaderboard_instance = inst
	inst.set_names(order)
	add_child(inst)


func update_players_who_want_to_play_again(ammount: int):
	if is_instance_valid(leaderboard_instance):
		leaderboard_instance.update_players_who_want_to_play_again(ammount, net.player_count())


func restart_game():
	leaderboard_instance.hide()
