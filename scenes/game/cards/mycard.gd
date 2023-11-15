extends Control

signal clicked
signal dropped
signal held

# What card is this
export var value: int = 0
export var color: int = 0

# Only used for up cards where there can be multiple cards stacked on top of
# each other
export var amount: int = -1


# Should this card not react to mouse events
export var disabled: bool = false

# Related nodes
onready var anim: AnimationPlayer = get_node("anim")
onready var front: TextureRect = get_node("Control/front")
onready var order_number: Label = get_node("Control/ordernumber")
onready var hover_effect: Control = get_node("Control/hovereffect")
onready var select_effect: Control = get_node("Control/selecteffect")
onready var table: Control = get_parent().get_parent()

var dragging: bool = false           # Is this card being dragged
var holding: bool = false            # Is this card being held
var holding_start_position: Vector2  # Where on the viewport did the user grab the card
var hovered: bool = false            # Is hovering style actived
var is_down_card: bool = false       # Is this a downwards facing card
var is_hand_card: bool = false       # Is this a card on the player's hand
var is_up_card: bool = false         # Is this an upwards facing card
var locked: bool = false             # Is this card locked
var mouse_rel_pos: Vector2           # Position of the card relative to the mouse
var previous_parent: Control = null  # Parent node before dragging started
var selected: bool = false           # Is this card selected
var stack_cards: Array = []          # All cards in this stack. Only used for up cards.
var selected_order: int = 0          # Number in selection order


func _ready():
	if table.name != "table":
		# Only true for hand cards
		is_hand_card = true
		table = table.get_parent()
	elif get_parent().name == "mydown":
		# Only true for down facing cards
		is_down_card = true
	else:
		# All other possibilities are ruled out
		is_up_card = true

	connect("mouse_entered", self, "show_hovered_style")


func _gui_input(event: InputEvent):
	if not disabled and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			card_held(event.get_global_position())
	if holding or dragging:
		if event is InputEventMouseMotion:
			mouse_moved(event.get_global_position())
		elif event.is_action_released("Click"):
			disable_dragging()


func card_held(mouse_position: Vector2):
	emit_signal("held", self)
	holding = true
	holding_start_position = mouse_position


func enable_dragging():
	if not dragging and holding:
		dragging = true
		holding = false

		var mouse_position: Vector2 = get_viewport().get_mouse_position()

		# Save where this card came from
		previous_parent = get_parent()

		# Calculate card position relative to the mouse
		var card_position = get_global_position()
		if is_hand_card:
			mouse_rel_pos = card_position - mouse_position
		else:
			mouse_rel_pos = Vector2(-100, -50)

		previous_parent.remove_child(self)
		table.add_child(self)

		mouse_moved(mouse_position)


func disable_dragging():
	if dragging:
		table.remove_child(self)
		table.insert_card_node_in_container(self, previous_parent)
		dragging = false
		holding = false

		emit_signal("dropped", self)
	elif holding:
		emit_signal("clicked", self)
		holding = false


func mouse_moved(mouse_position):
	if holding or dragging:
		if not Input.is_action_pressed("Click"):
			disable_dragging()
			return

	if dragging:
		rect_position = mouse_position + mouse_rel_pos

	if holding:
		# Start dragging if mouse is moved far enough
		if holding_start_position.distance_squared_to(mouse_position) >= 15 * 15:
			enable_dragging()


func show_hovered_style():
	if not disabled && not hovered:
		hovered = true
		table.remove_hover_on_all_cards_except(self)
		anim.playback_speed = 1
		anim.play("hover")


func remove_hovered_style():
	if not dragging && not selected:
		if hovered:
			hovered = false
			anim.play_backwards("hover")


func set_card_type(new_value: int, new_color: int, image: Texture):
	value = new_value
	color = new_color
	call_deferred("set_texture", image)


func set_texture(image: Texture):
	front.texture = image


func disable_hover():
	disabled = true
	mouse_filter = MOUSE_FILTER_PASS
	mouse_default_cursor_shape = CURSOR_ARROW


func enable_hover():
	disabled = false
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CURSOR_POINTING_HAND


func select_with_number(num: int):
	if not selected:
		selected = true
		hover_effect.set_visible(false)
		select_effect.set_visible(true)
		selected_order = num
		order_number.set_text(str(num))


func deselect():
	if selected:
		selected = false
		hover_effect.set_visible(true)
		select_effect.set_visible(false)
		order_number.set_text("")

		# Only for up cards
		if not is_hand_card and not is_down_card:
			set_amount(amount)


func get_selected_order() -> int:
	return selected_order


func set_selected_order(num: int):
	selected_order = num
	order_number.set_text(str(num))


func is_selected() -> bool:
	return selected


func get_card_value():
	return value


func get_card_color():
	return color


func set_amount(num: int):
	amount = num
	if amount > 1:
		order_number.set_text(str(num))
	else:
		order_number.set_text("")


func increase_amount():
	amount += 1
	set_amount(amount)


func set_stack_cards(cards: Array):
	stack_cards = cards
	set_amount(len(stack_cards))


func get_top_card() -> Array:
	return stack_cards[len(stack_cards) - 1]


func get_stack_cards() -> Array:
	return stack_cards


func lock():
	# TODO Disable dragging?
	locked = true
	anim.play("lock")


func unlock():
	if not locked:
		return
	locked = false
	anim.play_backwards("lock")
