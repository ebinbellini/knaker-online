extends Control


onready var entries: VBoxContainer = get_node("entries")
onready var playagainlabel: Label = get_node("playagainlabel")
onready var timer = get_node("inserttimer")
onready var anim = get_node("AnimationPlayer")

onready var net = get_node("/root/net")

var entry_res: Resource = preload("res://scenes/game/leaderboard/entry.tscn")
var award_icons: Array = [
	preload("res://imgs/winner.png"),
	preload("res://imgs/2nd.png"),
	preload("res://imgs/3rd.png"),
]

var index = 0
var names = []

var exiting: bool = false


func _ready():
	anim.play("show")
	anim.connect("animation_finished", self, "after_anim")
	update_players_who_want_to_play_again(0, net.player_count())


func after_anim(_ignored):
	if exiting:
		get_parent().queue_free()
	else:
		if len(names) > 0:
			show_names()


func set_names(names_to_show: Array):
	# Save to use later after the animation finishes
	names = names_to_show


func show_names():
	index = 0
	show_next_entry()


func show_next_entry():
	var name: String = names[index]
	var inst: Control = entry_res.instance()
	entries.add_child(inst)
	inst.set_player_name(name)

	# Give an award icon to the top 3 players
	if index < 3:
		var txtr: Texture = award_icons[index]
		inst.set_image(txtr)

	index += 1

	# Stop if the end has been reached
	if index < len(names):
		# The timer will call this function when finished
		timer.start()
	

func update_players_who_want_to_play_again(amount: int, total: int):
	playagainlabel.set_text(str(amount) + "/" + str(total) + tr("WTPA"))


func vote_play_again():
	net.rpc_id(1, "leaderboard_want_to_play_again")


func leave_game():
	net.leave_game()


func hide():
	exiting = true
	anim.play_backwards("show")
