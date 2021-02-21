extends Node


onready var nametag = get_node("name")
onready var down_count = get_node("downarrow/down")
onready var hand_count = get_node("handcount")
onready var up_cards = get_node("upcards")

onready var table: Control = get_parent().get_parent()

export var pid: int = 0
export var pname: String = ""


func _ready():
	nametag.text = pname


func update_cards(new_up, new_downc, new_handc):
	down_count.text = str(new_downc)
	hand_count.text = str(new_handc)

	# Add new up cards
	for card in new_up:
		if not is_card_in_array(card, card_nodes_to_transferables(up_cards.get_children())):
			var txr: Texture = table.game.find_card_texture(card)
			var inst: Control = table.mycard.instance()
			inst.disable_hover()
			up_cards.add_child(inst)
			inst.set_card_type(card[0], card[1], txr)

	# Remove old up cards
	for card in up_cards.get_children():
		if not is_card_in_array([card.value, card.color], new_up):
			card.get_parent().remove_child(card)
			card.queue_free()


func card_nodes_to_transferables(nodes: Array) -> Array:
	var transferables: Array = []
	for node in nodes:
		transferables.append([node.value, node.color])

	return transferables


func is_card_in_array(card: Array, array: Array) -> bool:
	for comp in array:
		if are_cards_equal(card, comp):
			return true

	return false


func are_cards_equal(card1: Array, card2: Array) -> bool:
	return card1[0] == card2[0] and card1[1] == card2[1]


func set_player_data(id: int, assigned_name: String):
	pid = id

	# Can't set label text before initialized into scene
	# Instead store in variable and use in _ready()
	pname = assigned_name
	
