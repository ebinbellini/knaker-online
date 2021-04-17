extends Control

onready var card_counter: Label = get_node("cards/card3/Label")
onready var anim: AnimationPlayer = get_node("anim")

var shall_we_dance: bool = false


func update_card_ammount(ammount: int): 
	card_counter.text = str(ammount)
	

func play_dance():
	shall_we_dance = true
	anim.play("dance")


func stop_dance():
	shall_we_dance = false


func animation_finished(_anim_name):
	if shall_we_dance:
		play_dance()
