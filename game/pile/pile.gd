extends Control

signal clicked

var top_value: int = 1
var top_color: int = 0
var card_ammount: int = 0

onready var game: Control = get_node("../../")
onready var cards: Button = get_node("cards")
onready var scrollbar: HScrollBar = get_node("HScrollBar")

var pilecard: Resource = preload("res://game/pile/pilecard.tscn")

const card_width: int = 50


func _ready():
	update_scrollbar()


func insert_card(value: int, color: int):
	card_ammount += 1

	top_value = value
	top_color = color

	# Create the new card
	var txtr: Texture = game.find_card_texture([value, color])
	var card: Node2D = pilecard.instance()
	card.set_card_type(color, value, txtr)
	cards.add_child(card)

	update_card_positions()
	update_scrollbar()


func empty_pile():
	top_value = 0
	top_color = 0
	card_ammount = 0

	# Remove all cards
	for card in cards.get_children():
		card.queue_free()


func clicked():
	emit_signal("clicked")


func scroll():
	update_card_positions()


func update_card_positions():
	for i in cards.get_child_count():
		cards.get_child(i).set_x_position(21 + (card_ammount - i - 1) * card_width - scrollbar.value)


func update_scrollbar():
	var required_space: int = 21 + (2 + card_ammount) * card_width
	var max_scroll: int = int(required_space - rect_size.x)

	if max_scroll <= 0:
		scrollbar.visible = false
	else:
		scrollbar.visible = true
		scrollbar.max_value = max_scroll
