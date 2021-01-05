extends Node


onready var nametag = get_node("name")
onready var down_count = get_node("downarrow/down")
onready var hand_count = get_node("handcount")
onready var up_cards = get_node("upcards")

onready var table: Control = get_parent().get_parent()

export var pid: int = 0
export var pname: String = ""


func _ready():
	nametag.text = pname


func update_cards(up, downc, handc):
	print("upp-korten är ", up)
	down_count.text = str(downc)
	hand_count.text = str(handc)

	for card in up:
		var txr: Texture = table.game.find_card_texture(card)
		var inst: Control = table.mycard.instance()
		inst.disable_hover()
		up_cards.add_child(inst)
		inst.set_card_type(card[0], card[1], txr)
		print("value ", card[0], " color ", card[1], " txr ", txr)



func set_player_data(id: int, assigned_name: String):
	print(id, " är idn och namnet var ", assigned_name)
	pid = id

	# Can't set label text before initialized into scene
	# Instead store in variable and use in _ready()
	pname = assigned_name
	
