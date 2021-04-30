extends Node


onready var anim: AnimationPlayer = get_node("CardFlyAnimation/AnimationPlayer")
onready var player_names = get_node("player_names")
onready var net = get_node("/root/net")
onready var button = get_node("coolbutton")

var player_name: Resource = load("res://waitingroom/player_name.tscn")

var stop: bool = false
var backwards: bool = false

func _ready():
	anim.connect("animation_finished", self, "restart_video")
	anim.play("cardfly");

	var owner = net.is_room_owner()
	if owner:
		button.visible = true

	player_names_changed(net.get_player_names())

	net.connect("player_names_changed", self, "player_names_changed")


func restart_video(anim_name: String):
	if not stop:
		backwards = not backwards
		if backwards:
			anim.play_backwards(anim_name)
		else:
			anim.play(anim_name)


func player_names_changed(names: Array):
	# Remove old
	for nametag in player_names.get_children():
		nametag.queue_free()

	# Add new
	for name in names:
		var nametag = player_name.instance()
		player_names.add_child(nametag)
		nametag.call_deferred("set_name", name)


func start_game():
	stop = true
	net.request_start_game()
