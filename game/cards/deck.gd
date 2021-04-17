extends Control

onready var card_counter: Label = get_node("cards/card3/Label")


func update_card_ammount(ammount: int): 
	card_counter.text = str(ammount)
