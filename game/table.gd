extends Control


onready var my_hand: Control = get_node("myhand/hbox")
onready var my_down: Control = get_node("mydown")
onready var my_up: Control = get_node("myup")
onready var opponents: Control = get_node("opponents")
onready var pile: Control = get_node("pile")
onready var net: Node = get_node("/root/net")

onready var game: Control = get_parent()

export var mycard = preload("res://game/cards/mycard.tscn")
var opponent_cards = preload("res://game/cards/opponent_cards.tscn")
var snackbar = preload("res://widgets/snackbar/snackbar.tscn")

var removed_all_hover_styles: bool = false
var cards_to_place: Array = []

var held_card: Control = null

var selected_cards_ammount: int = 0


func _ready():
	for card in my_down.get_children():
		card.connect("held", self, "card_held")
		card.connect("placed", net, "place_down_card")
		pile.connect("clicked", self, "place_selected_cards")


func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion && not removed_all_hover_styles:
		remove_hover_on_all_cards_except(null)
		removed_all_hover_styles = true
	else:
		if held_card != null:
			if event is InputEventMouseMotion:
				held_card.mouse_moved(event.get_global_position())
			elif event.is_action_released("Click"):
				held_card.disable_dragging()


func disable_hover_for_down_cards():
	for card in my_down.get_children():
		card.disable_hover()


func update_my_down_count(count: int):
	var current_count = my_down.get_child_count()
	if current_count == count:
		return

	if count < current_count:
		for i in range(current_count - count):
			my_down.get_children()[i].queue_free()


func insert_card_to_my_hand(card: Array):
	insert_card_in_container(card, my_hand)


func insert_card_to_my_up(card: Array):
	insert_card_in_container(card, my_up)


func insert_card_in_container(card: Array, container: Node):
	# Only insert if the card is not in my hand already
	if is_card_in_container(card, container):
		return

	var card_node = create_card_node(card)
	container.add_child(card_node)
	card_node.connect("held", self, "card_held")
	card_node.connect("clicked", self, "card_clicked")
	card_node.connect("placed", self, "card_placed")

	# Move card to make hand sorted, assuming hand was sorted before insertion
	var children: Array = container.get_children()
	for i in range(len(children)):
		var child = children[i]
		if child.value > card[0] && child.color > card[1]:
			container.move_child(card_node, i)
			break


func create_card_node(card: Array) -> Node:
	var texture = game.find_card_texture(card)
	var card_node = mycard.instance()
	card_node.set_card_type(card[0], card[1], texture)
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
	

func remove_hover_on_all_cards_except(exception):
	remove_hover(self, exception)
	removed_all_hover_styles = false


func remove_hover(current, exception):
	# Recurse over all child nodes
	if current != exception && current.has_method("remove_hovered_style"):
		current.call("remove_hovered_style")
	for child in current.get_children():
		remove_hover(child, exception)


func card_held(card_node: Control):
	held_card = card_node


func card_clicked(card_node: Control):
	if not card_node.is_selected():
		selected_cards_ammount += 1
		card_node.select_with_number(selected_cards_ammount)
	else:
		var dorder: int = card_node.get_selected_order()
		card_node.deselect()

		# Decrease number on all cards with a higher number than this card
		# TODO ammount can become negative somehow
		selected_cards_ammount -= 1
		for cdn in card_node.get_parent().get_children():
			var order: int = cdn.get_selected_order()
			if dorder < order:
				cdn.set_selected_order(order-1)
	
	update_card_availability()


func card_placed(card_node: Control):
	var placing: Array = []

	if card_node == null or card_node.get_parent() != my_down:
		if card_node == null or card_node.is_selected():
			# Ignore placed card and instead place all selected cards
			placing = get_selected_cards()
			placing.sort_custom(self, "sort_card_placements")
		else:
			# Place only the placed card
			placing = [card_node]

		request_placing_of_cards(placing)
	else:
		net.place_down_card()


func request_placing_of_cards(placing: Array):
	# Save for later in global variable
	cards_to_place = placing

	var transferable: Array = []
	for p in placing:
		transferable.append([p.get_card_value(), p.get_card_color()])

	# Send placement order through net 
	net.place_cards(transferable)


func get_selected_cards() -> Array:
	var selected: Array = []

	for child in my_hand.get_children():
		if child.is_selected():
			selected.append(child)

	for child in my_up.get_children():
		if child.is_selected():
			selected.append(child)

	# TODO down

	return selected


func place_selected_cards():
	var placing: Array = get_selected_cards()
	placing.sort_custom(self, "sort_card_placements")
	request_placing_of_cards(placing)


func sort_card_placements(card1, card2):
	# Sort by in which order the cards got selected
	return card1.get_selected_order() < card2.get_selected_order()


func show_snackbar(text: String):
	var inst: Control = snackbar.instance()
	add_child(inst)
	inst.display_text(text)


func cards_placed(cards, placer_pid):
	var clen: int = len(cards)
	var top: Array = cards[clen-1]
	var txtr: Texture = game.find_card_texture(top)
	pile.set_card_type(top[0], top[1], txtr)
	pile.increase_ammount(clen)

	# Check if the cards were placed by me
	if placer_pid == get_tree().get_network_unique_id():
		move_accepted()


func move_accepted():
	selected_cards_ammount = 0
	for card in cards_to_place:
		card.queue_free()
	cards_to_place = []

	update_card_availability()


func update_card_availability():
	if are_my_down_placeable():
		enable_down_cards()
	else:
		disable_down_cards()

	if are_my_up_placeable():
		enable_up_cards()
	else:
		disable_up_cards()


func are_my_up_placeable() -> bool:
	for card in my_hand.get_children():
		if not card.is_queued_for_deletion() and not card.is_selected():
			return false
	
	return true


func enable_up_cards():
	for card in my_up.get_children():
		card.enable_hover()


func disable_up_cards():
	for card in my_up.get_children():
		card.disable_hover()


func are_my_down_placeable() -> bool:
	for card in my_hand.get_children():
		if not card.is_queued_for_deletion() and not card.is_selected():
			return false

	for card in my_up.get_children():
		if not card.is_queued_for_deletion() and not card.is_selected():
			return false

	return true


func enable_down_cards():
	for card in my_down.get_children():
		card.enable_hover()


func disable_down_cards():
	for card in my_down.get_children():
		card.disable_hover()


func empty_pile():
	pile.empty_pile()
