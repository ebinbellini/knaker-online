extends Node


onready var loader: Control = get_node("loader")
onready var anim: AnimationPlayer = get_node("anim")
onready var table: Node = get_node("table")

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


func remove_loader():
	anim.play("rem_loader")
	

func load_textures():
	var color_folders: Array = ["spades", "heart", "diamonds", "clovers"]
	var unique_names: Array = ["knekt", "drottning", "knug", "ess"]

	for color in [ Spade, Heart, Diamond, Clover ]:
		# 2 - 10, Kn 11, Q 12, K 13, A 14
		for value in range(2, 15):
			# Find the folder
			var folder: String = ""
			var name: String = str(value)

			folder = color_folders[color]

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

	# Load knakers
	for card in [["res://cards/knakers/black knaker.png", Spade], ["res://cards/knakers/red knaker.png", Heart]]:
		# Create texture object
		var txr = CardTexture.new()
		txr.color = card[1]
		txr.value = Knaker

		# Load texture
		txr.res = load(card[0])

		# Store texture
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
