extends Node


onready var nametag: Label = get_node("name")
onready var hand_cards: Control = get_node("handcards")
onready var up_cards: Control = get_node("upcards")
onready var down_count: Control = get_node("downarrow/down")
onready var done: Control = get_node("done")

onready var table: Control = get_parent().get_parent()

export var pid: int = 0
export var pname: String = ""

var all_up_cards: Array = []


func _ready():
	nametag.text = pname


func update_cards(new_up: Array, new_downc: int, new_handc: int, locked_indexes: Array):
	down_count.text = str(new_downc)
	hand_cards.update_card_ammount(new_handc)

	# Remove old up cards
	for card in up_cards.get_children():
		card.queue_free()

	# Add new up cards
	for new_stack in new_up:
		var new_top: Array = new_stack[len(new_stack)-1]
		var txr: Texture = table.game.find_card_texture(new_top)
		var inst: Control = table.mycard.instance()
		inst.disable_hover()
		up_cards.add_child(inst)
		inst.set_card_type(new_top[0], new_top[1], txr)
		inst.set_stack_cards(new_stack)

		# Should the card be locked?
		var index = new_up.find(new_stack)
		if locked_indexes.find(index) != -1:
			inst.lock()


func card_nodes_to_transferables(nodes: Array) -> Array:
	var transferables: Array = []
	for node in nodes:
		transferables.append([node.value, node.color])

	return transferables


func get_up_cards() -> Array:
	return up_cards.get_children()


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
	

func finished(reason: String):
	done.set_text(tr(reason))
	done.visible = true
	for card in up_cards.get_children():
		card.queue_free()


func recieve_turn():
	hand_cards.play_dance()


func lose_turn():
	hand_cards.stop_dance()
