extends Sprite2D

var posicao_original_y: float

func _ready() -> void:
	posicao_original_y = position.y
	
	animar_flutuacao()

func animar_flutuacao():
	var tween = create_tween().set_loops()
	
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", posicao_original_y - 15.0, 1.5)
	
	tween.tween_property(self, "position:y", posicao_original_y, 1.5)

func _process(delta: float) -> void:
	pass
