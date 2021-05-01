extends Button

# Black Gradient
# When hovered the gradient slides to the right and becomes red on the left end

var primary: Color = primary1
var secondary: Color = secondary1

const primary1: Color = Color(0, 0, 0)
const primary2: Color = Color(0.4, 0.02, 0.02)
const secondary1: Color = Color(0.2, 0.2, 0.2)
const secondary2: Color = Color(0.2, 0, 0)

var is_hovered: bool = false
var is_pressed: bool = false

const sections: float = 48.0
const transition_time: float = 0.2

onready var tween: Tween = get_node("Tween")
onready var anim: AnimationPlayer = get_node("anim")
onready var label: Label = get_node("Label")


func _ready():
	connect("mouse_entered", self, "move_gradient")
	connect("mouse_exited", self, "reset_gradient")
	tween.connect("tween_all_completed", self, "tween_done")
	connect("button_down", self, "pressed")
	connect("button_up", self, "released")


func _process(_delta: float):
	update()


func pressed():
	if not is_pressed:
		is_pressed = true
		anim.playback_speed = 1
		anim.play("pressed")


func released():
	if is_pressed:
		is_pressed = false
		anim.play_backwards("pressed")


func move_gradient():
	if not is_hovered:
		is_hovered = true
		tween.stop_all()
		tween.interpolate_property(self, "primary",
			primary, primary2, transition_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(self, "secondary",
			secondary, secondary2, transition_time,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		set_process(true)


func reset_gradient():
	if is_hovered:
		is_hovered = false
		tween.stop_all()
		tween.interpolate_property(self, "primary",
			primary, primary1, transition_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(self, "secondary",
			secondary, secondary1, transition_time,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		set_process(true)


func _draw():
	var size: Vector2 = rect_size
	
	# Divide gradient into 32 rectangles
	for i in range(sections):
		secondary.a = i / sections
		var color: Color = primary.blend(secondary)
		var rect: Rect2 = Rect2(Vector2(i * size.x / sections, 0), Vector2(size.x / sections,  size.y))
		draw_rect(rect, color)
		

func tween_done():
	set_process(false)


func update_text(text: String):
	label.set_text(text)
