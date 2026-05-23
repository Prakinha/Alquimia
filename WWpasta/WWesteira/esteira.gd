extends Node2D

@export var goblinScene: PackedScene
@export var arrayDeItensPossiveis: Array[ItemData]


func _on_timer_timeout() -> void:
	var newgoblin: GoblinArea2D = goblinScene.instantiate()
	newgoblin.itemdata = arrayDeItensPossiveis.pick_random()
	add_child(newgoblin)
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is GoblinArea2D:
		area.queue_free()
