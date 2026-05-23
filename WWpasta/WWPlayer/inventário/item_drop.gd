extends Area2D
class_name ItemDrop

@export var itemdata: ItemData
@onready var sprite: Sprite2D = $Sprite2D
@onready var itemSway: Tween


func itemSway_init() -> void:
	itemSway = create_tween()
	itemSway.set_loops(200)
	itemSway.set_ease(Tween.EASE_IN_OUT)
	itemSway.set_trans(Tween.TRANS_CUBIC)
	itemSway.tween_property(sprite,"position:y",20,2)
	itemSway.tween_property(sprite,"position:y",-20,2)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if itemdata:
		sprite.texture = itemdata.icon
		itemSway_init()
