extends Node


onready var loader: Control = get_node("loader")
onready var anim: AnimationPlayer = get_node("anim")
onready var table: Node = get_node("table")

var card_backside_texture: Resource = preload("res://cards/baksida.png")

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


func prepare_game_scene():
	load_textures()
	table.disable_hover_for_down_cards()


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

	txr.color = Spade
	txr.value = 1
	txr.res = load("res://cards/cardoutline.png")

	textures.append(txr)


func find_card_texture(card: Array) -> Texture:
	for txr in textures:
		if txr.value == card[0] && txr.color == card[1]:
			return txr.res

	return null


func update_my_hand(hand: Array):
	for card in hand:
		table.insert_card_to_my_hand(card)
		

func update_my_up(up: Array):
	for card in up:
		table.insert_card_to_my_up(card)

func update_my_down(count: int):
	table.update_my_down_count(count)
