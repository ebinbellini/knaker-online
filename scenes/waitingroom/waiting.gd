extends Node


onready var anim: AnimationPlayer = get_node("CardFlyAnimation/AnimationPlayer")
onready var player_names = get_node("player_names")
onready var net = get_node("/root/net")
onready var start_button = get_node("startbutton")

var player_name: Resource = load("res://scenes/waitingroom/player_name.tscn")

var animation_playing: bool = true
var backwards: bool = false

# TODO leave room button

func _ready():
	anim.connect("animation_finished", self, "restart_video")
	anim.play("cardfly");

	player_names_changed(net.get_player_names())

	net.connect("player_names_changed", self, "player_names_changed")


func restart_video(anim_name: String):
	if animation_playing:
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

	var owner = net.is_room_owner()
	if owner && len(names) > 1:
		start_button.visible = true


func start_game():
	animation_playing = false
	net.request_start_game()
