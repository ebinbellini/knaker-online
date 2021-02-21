extends Control

signal clicked

var value: int = 0
var color: int = 0
var card_ammount: int = 0
var empty_texture: Texture = preload("res://cards/emptycard.png")

onready var front: TextureRect = get_node("front")
onready var counter: Label = get_node("counter")

# TODO place selected cards when clicked

func set_card_type(new_value: int, new_color: int, image: Texture):
	value = new_value
	color = new_color
	front.texture = image


func increase_ammount(ammount: int):
	card_ammount += ammount
	update_counter()


func update_counter():
	counter.set_text(str(card_ammount))


func flip_pile():
	card_ammount = 0
	update_counter()
	front.texture = empty_texture


func clicked():
	emit_signal("clicked")
