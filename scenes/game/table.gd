# Copyright (C) 2021 Ebin Bellini ebinbellini@airmail.cc

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

extends Control

# Child nodes
onready var banner: Control = get_node("banner")
onready var chance: Button = get_node("passbuttons/chance")
onready var deck: Control = get_node("deck")
onready var deselect_button: TextureButton = get_node("handbuttons/clearselect")
onready var done_trading_button: Button = get_node("donetrading")
onready var done_trading_label: Label = get_node("donetradinglabel")
onready var iamdone: Label = get_node("iamdone")
onready var my_down: Control = get_node("mydown")
onready var my_hand: Control = get_node("myhand/hbox")
onready var my_up: Control = get_node("myup")
onready var opponents: Control = get_node("opponents")
onready var pass_buttons: Control = get_node("passbuttons")
onready var pickup: Button = get_node("passbuttons/pickup")
onready var pile: Control = get_node("pile")

# Other related nodes
onready var net: Node = get_node("/root/net")
onready var game: Control = get_parent()

export var mycard = preload("res://scenes/game/cards/mycard.tscn")
var opponent_cards = preload("res://scenes/game/cards/opponent_cards.tscn")
var snackbar = preload("res://scenes/widgets/snackbar/snackbar.tscn")

var cards_to_place: Array = []
var held_card: Control = null
var selected_cards_amount: int = 0
var turn_pid: int = 0


func _ready():
	# The down cards are not inserted dynamically
	for card in my_down.get_children():
		card.connect("held", self, "card_held")
		card.connect("dropped", self, "card_dropped")
		# TODO check if selecting down cards works
		card.connect("clicked", self, "card_clicked")


func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		remove_hover_on_all_cards_except(null)

	if is_instance_valid(held_card):
		if event is InputEventMouseMotion:
			held_card.mouse_moved(event.get_global_position())
		elif event.is_action_released("Click"):
			held_card.disable_dragging()


func update_my_hand(new_hand: Array):
	for card in new_hand:
		# Only insert if the card is not in my hand already
		if not is_card_in_container(card, my_hand):
			insert_card_in_container(card, my_hand)

	for card in my_hand.get_children():
		if not is_card_in_array([card.value, card.color], new_hand):
			card.get_parent().remove_child(card)
			card.queue_free()


func update_my_up(new_up: Array, locked_indexes: Array):
	# Add new up cards
	for new_stack in new_up:
		var new_top: Array = new_stack[len(new_stack)-1]
		var found: bool = false

		for up_stack in my_up.get_children():
			var top_card: Array = up_stack.get_top_card()
			if top_card == new_top:
				found = true

		if not found:
			var card_node: Control = create_card_node(new_top)
			my_up.add_child(card_node)
			card_node.set_stack_cards(new_stack)
			card_node.connect("held", self, "card_held")
			card_node.connect("clicked", self, "card_clicked")
			card_node.connect("dropped", self, "card_dropped")

			# Is the card locked?
			var index = new_up.find(new_stack)
			if locked_indexes.find(index) != -1:
				card_node.lock()


	# Remove old up cards
	for i in my_up.get_child_count():
		var top_card: Array = my_up.get_child(i).get_top_card()
		var found: bool = false

		for new_stack in new_up:
			var new_top: Array = new_stack[len(new_stack)-1]
			if new_top == top_card: 
				found = true
				break

		if not found:
			my_up.get_child(i).queue_free()


func is_card_in_array(card: Array, array: Array) -> bool:
	for comp in array:
		if are_cards_equal(card, comp):
			return true

	return false


func are_cards_equal(card1: Array, card2: Array) -> bool:
	return card1[0] == card2[0] and card1[1] == card2[1]


func insert_card_in_container(card: Array, container: Control) -> Control:
	# Create card node
	var card_node = create_card_node(card)
	container.add_child(card_node)
	card_node.connect("held", self, "card_held")
	card_node.connect("clicked", self, "card_clicked")
	card_node.connect("dropped", self, "card_dropped")

	insert_card_node_in_container(card_node, container)

	return card_node


func insert_card_node_in_container(card_node: Control, container: Control):
	if card_node.get_parent() == null:
		container.add_child(card_node)

	# Move card to make container sorted, assuming the container was sorted before insertion
	var children: Array = container.get_children()
	for i in range(len(children)):
		var child = children[i]
		# Insert before the first higher card
		if child.value > card_node.value or (child.value == card_node.value and child.color > card_node.color):
			container.move_child(card_node, i)
			break


func update_my_down_count(count: int):
	var current_count = my_down.get_child_count()
	if current_count == count:
		return

	if count < current_count:
		for i in range(current_count - count):
			my_down.get_children()[i].queue_free()


func card_dropped(card: Control):
	if pile.visible:
		if is_mouse_over_node(pile):
			# The mouse is over the pile
			card_placed(card)
	else:
		# Trading phase
		if card.get_parent().name == "myup" and is_mouse_over_node(my_hand):
			net.rpc_id(1, "pick_up_card", [card.value, card.color])
		elif card.get_parent().name == "hbox" and is_mouse_over_node(my_up):
			var length = len(my_up.get_children())
			# Loop backwards over cards
			for i in range(length - 1, -1, -1):
				var up_card: Control = my_up.get_child(i)
				if is_mouse_over_node(up_card):
					net.rpc_id(1, "put_down_card", [card.value, card.color], i)
					return

			# No specific card hovered
			net.rpc_id(1, "put_down_card", [card.value, card.color], -1)
		elif is_mouse_over_node(opponents):
			# Find which up card in which opponent's possession is hovered over
			for opponent in opponents.get_children():
				var up_cards = opponent.get_node("upcards").get_children()
				for i in len(up_cards):
					if is_mouse_over_node(up_cards[i]):
						net.rpc_id(1, "place_card_on_opponent", [card.value, card.color], opponent.pid, i)
						return


func is_mouse_over_node(node: Control):
	var pos_min: Vector2 = node.get_global_position()
	var pos_max: Vector2 = node.get_global_position() + node.rect_size

	# Check if mouse is within a given rectangle on the viewport
	var mp: Vector2 = get_viewport().get_mouse_position()
	return mp.x > pos_min.x and mp.y > pos_min.y and mp.x < pos_max.x and mp.y < pos_max.y


func create_card_node(card: Array) -> Control:
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


func update_player_cards(pid: int, up: Array, downc: int, handc: int, locked_up_indexes: Array):
	var opnt = find_opponent(pid)
	if opnt != null:
		opnt.update_cards(up, downc, handc, locked_up_indexes)
	

func remove_hover_on_all_cards_except(exception):
	remove_hover(self, exception)


func remove_hover(current, exception):
	# Recurse over all child nodes
	if current != exception && current.has_method("remove_hovered_style"):
		current.call("remove_hovered_style")
	for child in current.get_children():
		remove_hover(child, exception)


func card_held(card_node: Control):
	held_card = card_node


func update_selected_amount():
	selected_cards_amount = 0

	for card in my_hand.get_children():
		if card.is_selected():
			selected_cards_amount += 1

	for stack in my_up.get_children():
		if stack.is_selected():
			selected_cards_amount += 1

	for card in my_down.get_children():
		if card.is_selected():
			selected_cards_amount += 1
	
	if selected_cards_amount > 0:
		deselect_button.visible = true
	else:
		deselect_button.visible = false

	
func selectable_card_clicked(card_node: Control):
	update_selected_amount()

	if not card_node.is_selected():
		# Select
		# TODO allow selecting multiple by shift+clicking
		selected_cards_amount += 1
		card_node.select_with_number(selected_cards_amount)

		deselect_button.visible = true
	else:
		# Deselect
		var dorder: int = card_node.get_selected_order()
		card_node.deselect()

		# Decrease selected order on all cards with a higher number than
		# this card
		selected_cards_amount -= 1
		for cdn in my_up.get_children() + my_hand.get_children():
			var order: int = cdn.get_selected_order()
			if dorder < order:
				cdn.set_selected_order(order-1)

		if selected_cards_amount < 0:
			selected_cards_amount = 0
		deselect_button.visible = true


func card_clicked(card_node: Control):
	if card_node.get_parent().name == "myup":
		# This is an up card
		if not pile.visible:
			# In trading phase
			net.pick_up_card(card_node)
		else:
			# In playing phase
			selectable_card_clicked(card_node)
	elif card_node.get_parent().name == "mydown":
		# This is a down card
		net.place_down_card()
	else:
		# This is a hand card
		if pile.visible:
			# In playing phase
			selectable_card_clicked(card_node)
		else:
			# In trading phase

			# Move card to up cards
			net.rpc_id(1, "put_down_card", [card_node.value, card_node.color], -1)
	
	update_card_availability()


func card_placed(card_node: Control):
	if card_node.get_parent() == my_down:
		net.place_down_card()
	else:
		var placing: Array = []

		if card_node == null or card_node.is_selected():
			# Ignore the placed card and instead place all selected cards
			place_selected_cards()
		else:
			# Place only the placed card
			placing = [card_node]

		request_placing_of_cards(placing)


func request_placing_of_cards(placing: Array):
	# Save for later in global variable
	cards_to_place = placing

	var transferable: Array = []
	for plc in placing:
		if plc.is_up_card:
			# Insert all cards in the stack
			for card in plc.get_stack_cards():
				transferable.append([card[0], card[1]])
		else:
			# Regular card
			transferable.append([plc.get_card_value(), plc.get_card_color()])

	# Send placement order to server
	net.place_cards(transferable)


func get_selected_cards() -> Array:
	var selected: Array = []

	for child in my_hand.get_children():
		if child.is_selected():
			selected.append(child)

	for stack in my_up.get_children():
		if stack.is_selected():
			selected.append(stack)

	return selected


func place_selected_cards():
	var placing: Array = get_selected_cards()
	placing.sort_custom(self, "sort_card_placements")
	request_placing_of_cards(placing)


func clear_selection():
	for container in [my_hand, my_up]:
		for card in container.get_children():
			if card.is_selected():
				card.deselect()
			card.remove_hovered_style()

	selected_cards_amount = 0
	deselect_button.visible = false


func sort_card_placements(card1, card2):
	# Sort by in which order the cards got selected
	return card1.get_selected_order() < card2.get_selected_order()


func show_snackbar(text: String):
	var inst: Control = snackbar.instance()
	add_child(inst)
	inst.display_text(text)


func cards_placed(cards, placer_pid):
	for card in cards:
		pile.insert_card(card[0], card[1])

	# Check if the cards were placed by me
	if placer_pid == get_tree().get_network_unique_id():
		move_accepted()


func move_accepted():
	selected_cards_amount = 0
	deselect_button.visible = false

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
	# They are always placeable during trading phase
	if not pile.visible:
		return true

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
	# Never placeable during trading phase
	if not pile.visible:
		return false

	for card in my_up.get_children():
		if not card.is_queued_for_deletion():
			return false

	return true


func enable_down_cards():
	for card in my_down.get_children():
		card.enable_hover()
		# The up cards block mouse input
		my_up.visible = false


func disable_down_cards():
	for card in my_down.get_children():
		card.disable_hover()
		my_up.visible = true


func empty_pile():
	pile.empty_pile()


func send_done_trading():
	done_trading_button.visible = false
	net.rpc_id(1, "done_trading")

	
func update_done_trading_button_text(text: String):
	done_trading_label.set_text(text)


func start_playing_phase():
	banner.display_message(tr("PLAYING_PHASE"))
	done_trading_button.visible = false
	done_trading_label.visible = false
	pile.visible = true
	update_card_availability()

	for card in my_up.get_children():
		card.unlock()

	for opponent in opponents.get_children():
		for card in opponent.get_up_cards():
			card.unlock()


func update_deck_amount(amount: int):
	deck.update_card_amount(amount)

	# You can't take a chance if there are no cards left
	if amount == 0:
		chance.visible = false


func take_chance():
	net.rpc_id(1, "take_chance")


func pick_up_cards():
	net.rpc_id(1, "pick_up_cards")


func player_finished(pid: int, reason: String):
	for opponent in opponents.get_children():
		if opponent.pid == pid:
			opponent.finished(reason)
			return


func i_am_finished(reason: String):
	iamdone.set_text(reason)
	iamdone.visible = true
	
	for child in pass_buttons.get_children():
		child.visible = false


func my_turn():
	player_lost_turn(turn_pid)
	turn_pid = get_tree().get_network_unique_id()
	pile.set_is_my_turn(true)

	pass_buttons.visible = true
	if pile.is_empty():
		pickup.visible = false
	else:
		pickup.visible = true


func new_player_has_turn(has_turn_pid: int):
	pass_buttons.visible = false

	player_lost_turn(turn_pid)
	turn_pid = has_turn_pid
	pile.set_is_my_turn(false)

	var opponent = find_opponent(has_turn_pid)
	if opponent != null:
		opponent.recieve_turn()


func player_lost_turn(lost_pid: int):
	var opponent = find_opponent(lost_pid)
	if opponent != null:
		opponent.lose_turn()
