extends Area2D
class_name GoblinArea2D


@export var itemdata: ItemData
@onready var goblinHand: Marker2D = $Hand
@export var itemdrop: PackedScene
@onready var isSegurandoItem: bool
@export var GoblinVelocidade: int = 2


func _ready() -> void:
	isSegurandoItem = false
	if itemdata:
		isSegurandoItem = true
		var itemDoGoblin : ItemDrop = itemdrop.instantiate()
		itemDoGoblin.itemdata = itemdata
		goblinHand.add_child(itemDoGoblin)



func _process(delta: float) -> void:
	position.x = position.x + GoblinVelocidade
	
func isSegurando() -> bool:
	return isSegurandoItem
	
	#essa função só deve ser chamada se isSegurando retornar false!
func ReceberItem(itemdata: ItemData) -> void:
	isSegurandoItem = true
	var itemDoGoblin : ItemDrop = itemdrop.instantiate()
	itemDoGoblin.itemdata = itemdata
	goblinHand.add_child(itemDoGoblin)
	
func limpar_as_maos() -> void:
	for item_na_mao in goblinHand.get_children():
		item_na_mao.queue_free()
