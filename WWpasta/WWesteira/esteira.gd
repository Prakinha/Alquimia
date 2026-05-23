extends Node2D

@export var goblinScene: PackedScene


func _on_timer_timeout() -> void:
	var newgoblin = goblinScene.instantiate()
	add_child(newgoblin)
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is GoblinArea2D:
		area.queue_free()
