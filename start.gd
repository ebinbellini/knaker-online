extends Node

var time_max = 50
var timer_done = false
var loaded_scene = null


onready var animator = get_node("AnimationPlayer")
onready var timer = get_node("Timer")


func _ready():
	var path = "res://matchmaking/matchmaking.tscn"
	var loader = ResourceLoader.load_interactive(path)
	if loader == null:
		print("could not start loading")
		return

	load_interactively(loader)


func load_interactively(loader):
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
	loaded_scene = scene
	if (timer_done):
		set_scene(scene)


func set_scene(scene):
	animator.play("fadeout")
	call_deferred("insert_node", scene)


func insert_node(scene):
	var inst = scene.instance()
	get_node("/root/Start/Next").add_child(inst)

	var delt = get_node("DeleteTimer")
	delt.start()


func _on_Timer_timeout():
	timer_done = true;
	if (loaded_scene != null):
		set_scene(loaded_scene)


func remove_this_node():
	queue_free()

