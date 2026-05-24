extends Control
@onready var NoDeControle: Control = %NoDeControle

func _ready() -> void:
	SubirOMenu()


func SubirOMenu() -> void:
	var NewTween: Tween = create_tween()
	NewTween.set_trans(Tween.TRANS_EXPO)
	NewTween.set_ease(Tween.EASE_IN_OUT)
	NewTween.tween_property(NoDeControle,"position:y",0,1.0)
