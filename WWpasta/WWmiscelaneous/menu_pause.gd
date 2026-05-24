extends CanvasLayer
class_name MenuPause

@onready var NoDeControle: Control = %NoDeControle
@onready var livro: Sprite2D = $NoDeControle/Sprite2D
@onready var frames_do_livro: int = livro.hframes * livro.vframes



var posicao_escondida: float = -648

func _ready() -> void:
	NoDeControle.position.y = posicao_escondida

func SubirOMenu(player: PlayerCharacter) -> void:
	if player.is_active:
		player.set_active(false)
		var NewTween: Tween = create_tween()
		NewTween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		NewTween.tween_property(NoDeControle, "position:y", 0, 1.0)
	else:
		DescerOMenu(player)

func DescerOMenu(player: PlayerCharacter) -> void:
	player.set_active(true)
	var NewTween: Tween = create_tween()
	NewTween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	NewTween.tween_property(NoDeControle, "position:y", posicao_escondida, 1.0)


func _on_button_pressed() -> void:
	livro.frame = (livro.frame + 1) % frames_do_livro
	
