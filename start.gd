extends Node

var time_max = 50
var first_load = true
var timer_done = false
var loaded_scene = null
var scene_to_move = null
var scenes_to_remove = []


onready var animator: AnimationPlayer = get_node("AnimationPlayer")
onready var timer: Timer = get_node("Timer")
onready var remove_timer: Timer = get_node("RemoveTimer")
onready var neterranim: Node = get_node("../neterror/anim")
onready var loader_vid: VideoPlayer = get_node("VideoPlayer")
onready var next_node: Control = get_node("/root/start/Next")

func _ready():
	start_netclient_node()


func connected_ok():
	var path = "res://choosename/choosename.tscn"
	var loader = ResourceLoader.load_interactive(path)
	if loader == null:
		print("could not start loading")
		return

	load_interactively(loader)


func network_error():
	# TODO retry button
	neterranim.play("display")


func hide_network_error():
	neterranim.play_backwards("display")


func start_netclient_node():
	get_tree().connect("connected_to_server", self, "connected_ok")
	get_tree().connect("connection_failed", self, "network_error")
	get_tree().connect("server_disconnected", self, "network_error")

	var net_scene = load("res://net.tscn")
	var inst = net_scene.instance()
	get_node("/root").call_deferred("add_child", inst)


func remove_old_scenes():
	for scene in scenes_to_remove:
		scene.queue_free()


func load_and_set_scene(path, caller = null, callback = null):
	# Remove old scenes after 1 second
	for child in next_node.get_children():
		if not scenes_to_remove.has(child):
			scenes_to_remove.append(child)

	var loader = ResourceLoader.load_interactive(path)
	load_interactively(loader)
	if caller != null:
		caller.call(callback)


func load_interactively(loader):
	if loader == null:
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()

		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err != OK:
			print(err)
			loader = null
			break

	load_interactively(loader)
			

func set_new_scene(scene):
	if first_load:
		timer.start()
		first_load = false
	loaded_scene = scene
	if (timer_done):
		set_scene(scene)


func set_scene(scene):
	animator.play("fadeout")
	call_deferred("insert_node", scene)


func insert_node(scene):
	var inst = scene.instance()
	next_node.add_child(inst)

	scene_to_move = inst
	var movt = get_node("MoveTimer")
	movt.start()


func _on_Timer_timeout():
	timer_done = true;
	if (loaded_scene != null):
		set_scene(loaded_scene)


func move_timer_done():
	if scene_to_move:
		var parent = scene_to_move.get_parent()
		parent.move_child(scene_to_move, parent.get_child_count())

		var parent2 = parent.get_parent()
		parent2.move_child(parent, parent2.get_child_count())


func restart_loader_video():
	loader_vid.play()
