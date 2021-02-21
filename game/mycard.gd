extends Control

signal clicked
signal placed
signal held

# What card is this
export var value: int = 0
export var color: int = 0

# Should this card not react to mouse events
export var disabled: bool = false

# Related nodes
onready var anim: AnimationPlayer = get_node("anim")
onready var front: TextureRect = get_node("Control/front")
onready var order_number: Label = get_node("Control/ordernumber")
onready var hover_effect: Control = get_node("Control/hovereffect")
onready var select_effect: Control = get_node("Control/selecteffect")
onready var table: Control = get_parent().get_parent()
# Set later in _ready
var pile: Control

# Is the mouse hovering over this card
#var mouse_over: bool 

# Is this card being dragged
var dragging: bool = false
# Is this card being held
var holding: bool = false
# Position of the card relative to the mouse
var mouse_rel_pos: Vector2
# Where on the viewport did the user grab the card
var holding_start_position: Vector2
# Parent node before dragging started
var previous_parent: Control = null
# Is hovering style actived
var hovered = false
# Is this card selected
var selected = false
# Is this a card on the player's hand
var is_hand_card = false
# Is this a down facing card
var is_down_card = false


func _ready():
	if table.name != "table":
		# Only true for hand cards
		is_hand_card = true
		table = table.get_parent()
	elif get_parent().name == "mydown":
		# Only true for down facing cards
		is_down_card = true

	pile = table.get_node("pile")

	connect("mouse_entered", self, "show_hovered_style")
	connect("mouse_exited", self, "remove_hovered_style")


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
		previous_parent.add_child(self)
		dragging = false
		holding = false

		# Check if mouse is within pile
		var mp: Vector2 = get_viewport().get_mouse_position()
		var pp: Vector2 = pile.rect_position
		var pe: Vector2 = pp + pile.rect_size
		if mp.x > pp.x and mp.y > pp.y and mp.x < pe.x and mp.y < pe.y:
			# The mouse is over the pile
			emit_signal("placed", self)
	elif holding:
		if not is_down_card:
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


func enable_hover():
	disabled = false


func select_with_number(num: int):
	if not selected:
		selected = true
		hover_effect.set_visible(false)
		select_effect.set_visible(true)
		order_number.set_text(str(num))


func deselect():
	if selected:
		selected = false
		hover_effect.set_visible(true)
		select_effect.set_visible(false)
		order_number.set_text("")


func get_selected_order() -> int:
	return int(order_number.get_text())


func set_selected_order(num: int):
	order_number.set_text(str(num))


func is_selected() -> bool:
	return selected


func get_card_value():
	return value


func get_card_color():
	return color
