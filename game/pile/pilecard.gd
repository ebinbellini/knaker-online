extends Node2D

# What card is this
export var value: int = 0
export var color: int = 0

# Related nodes
onready var container: Control = get_node("Control")
onready var front: TextureRect = get_node("Control/front")
onready var tween: Tween = get_node("Tween")

const y_pos: int = 21


func set_x_position(x_pos: int):
	tween.interpolate_property(self, "position",
		position, Vector2(x_pos, y_pos), 0.15,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func set_card_type(new_value: int, new_color: int, image: Texture):
	value = new_value
	color = new_color
	call_deferred("set_texture", image)


func set_texture(image: Texture):
	front.texture = image
