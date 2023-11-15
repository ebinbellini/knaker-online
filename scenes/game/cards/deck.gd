extends Control

onready var card_counter: Label = get_node("cards/card3/Label")


func update_card_amount(amount: int): 
	card_counter.text = str(amount)
