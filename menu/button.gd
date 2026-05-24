extends Button
var ButtonInicalTween:Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ButtonInicalTween = create_tween()
	ButtonInicalTween.set_loops(200)
	ButtonInicalTween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	ButtonInicalTween.tween_property(self,"position:y", self.position.y + 14, 1.5 )
	ButtonInicalTween.tween_property(self,"position:y", self.position.y - 6, 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://itens/cenajogo.tscn")
	pass # Replace with function body.
