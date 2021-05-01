extends Control


const color: Color = Color(0.08, 0.08, 0.08)

onready var tween = get_node("Tween")
onready var label = get_node("Label")

var ready: bool = false


func _ready():
	tween.interpolate_property(self, "rect_position",
		Vector2(272, 605), Vector2(272, 500), .4,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	set_process(true)
	tween.connect("tween_all_completed", self, "done_moving")

	ready = true


func _process(_delta):
	# Redraw while moving
	update()


func done_moving():
	set_process(false)


func _draw():
	# Draw rounded corners
	var size: Vector2 = rect_size
	draw_circle_arc_poly(Vector2(size.x - 10, 10), 10, 0, 90)
	draw_circle_arc_poly(Vector2(size.x - 10, size.y - 10), 10, 90, 180)
	draw_circle_arc_poly(Vector2(10, size.y - 10), 10, 180, 270)
	draw_circle_arc_poly(Vector2(10, 10), 10, 270, 360)

	# Draw the rest
	var rects = [
		Rect2(Vector2(10, 0), Vector2(size.x-20, 10)),
		Rect2(Vector2(0, 10), Vector2(size.x, size.y-20)),
		Rect2(Vector2(10, size.y-10), Vector2(size.x-20, 10))
	]
	for rect in rects:
		draw_rect(rect, color)


func draw_circle_arc_poly(center, radius, angle_from, angle_to):
	var nb_points = 48
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)


func leave_scene():
	tween.interpolate_property(self, "rect_position",
		Vector2(272, 500), Vector2(272, 605), .4,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	set_process(true)
	tween.connect("tween_all_completed", self, "queue_free")


func display_text(text):
	label.set_text(text)
