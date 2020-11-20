extends Node

var time_max = 50
var first_load = true
var timer_done = false
var loaded_scene = null
var scene_to_move = null


onready var animator = get_node("AnimationPlayer")
onready var timer = get_node("Timer")


func _ready():
	start_netclient_node()

	var path = "res://choosename/choosename.tscn"
	var loader = ResourceLoader.load_interactive(path)
	if loader == null:
		print("could not start loading")
		return

	load_interactively(loader)


func start_netclient_node():
	var net_scene = load("res://net.tscn")
	var inst = net_scene.instance()
	get_node("/root").call_deferred("add_child", inst)


func load_and_set_scene(path):
	var loader = ResourceLoader.load_interactive(path)
	load_interactively(loader)


func load_interactively(loader):
	print("LADDAR IN ", loader)
	if loader == null:
		return

	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		# Poll your loader.
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			pass
		else: # Error during loading.
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
	get_node("/root/start/Next").add_child(inst)

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
