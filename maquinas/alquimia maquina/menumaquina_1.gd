extends MenuBase

func _ready() -> void:
	NoDeControle.position.y = posicao_escondida

func SubirOMenu() -> void:
	var NewTween: Tween = create_tween()
	NewTween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	NewTween.tween_property(NoDeControle, "position:y", 0, 1.0)

func DescerOMenu() -> void:
	var NewTween: Tween = create_tween()
	NewTween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	NewTween.tween_property(NoDeControle, "position:y", posicao_escondida, 1.0)
