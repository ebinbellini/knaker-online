extends Control


onready var my_hand: Control = get_node("myhand/hbox")
onready var my_down: Control = get_node("mydown")
onready var my_up: Control = get_node("myup")
onready var opponents: Control = get_node("opponents")

onready var game: Control = get_parent()

var mycard: Resource = preload("res://game/mycard.tscn")
var opponent_cards = preload("res://game/opponent_cards.tscn")


func _ready():
	pass


func insert_card_to_my_hand(card: Array):
	insert_card_in_container(card, my_hand)


func insert_card_to_my_up(card: Array):
	insert_card_in_container(card, my_up)


func insert_card_in_container(card: Array, container: Node):
	# Only insert if the card is not in my hand already
	if is_card_in_container(card, container):
		return

	var card_node = create_card_node(card)

	# Insert card node before a card with greater value and color
	var children: Array = container.get_children()
	for i in range(len(children)):
		var child = children[i]
		if child.value > card[0] && child.color > card[1]:
			container.add_child(card_node)
			container.move_child(card_node, i)

	# There is no card with greater value and color, insert last
	container.add_child(card_node)


func create_card_node(card: Array) -> Node:
	var texture = game.find_card_texture(card)
	var card_node = mycard.instance()
	card_node.call_deferred("set_card_type", card[0], card[1], texture)
	return card_node


func is_card_in_container(card: Array, container: Node) -> bool:
	for child in container.get_children():
		if child.value == card[0] && child.color == card[1]:
			return true

	return false


func insert_enemy_players(players: Array):
	for player in players:
		if player.id != get_tree().get_network_unique_id():
			var opc: Control = opponent_cards.instance()
			opc.set_player_data(player.id, player.name)
			print(player.id, player.name)
			opponents.add_child(opc)


func find_opponent(pid: int) -> Control:
	for child in opponents.get_children():
		if child.pid == pid:
			return child

	return null


func update_player_cards(pid, up, downc, handc):
	var opnt = find_opponent(pid)
	if opnt != null:
		opnt.update_cards(up, downc, handc)
	
