# Copyright (C) 2021 Ebin Bellini ebinbellini@airmail.cc

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
	var path = "res://scenes/choosename/choosename.tscn"
	var loader = ResourceLoader.load_interactive(path)
	if loader == null:
		print("could not start loading")
		return

	load_interactively(loader)


func network_error():
	neterranim.play("display")


func hide_network_error():
	neterranim.play_backwards("display")


func start_netclient_node():
	get_tree().connect("connected_to_server", self, "connected_ok")
	get_tree().connect("connection_failed", self, "network_error")
	get_tree().connect("server_disconnected", self, "network_error")

	var net_scene = load("res://scenes/net/net.tscn")
	var inst = net_scene.instance()
	get_node("/root").call_deferred("add_child", inst)


func remove_old_scenes():
	for scene in scenes_to_remove:
		if is_instance_valid(scene):
			scene.queue_free()


func load_and_set_scene(path):
	# Select old scenes to remove after loading
	for child in next_node.get_children():
		if not scenes_to_remove.has(child):
			scenes_to_remove.append(child)

	# Start loading
	var loader = ResourceLoader.load_interactive(path)
	load_interactively(loader)

	# Remove old scenes in 1 second
	remove_timer.start()


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
