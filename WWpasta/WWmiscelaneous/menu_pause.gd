extends CanvasLayer
class_name MenuPause

@onready var node_controle: Control = $NodeControle 
@onready var livro: Sprite2D = $NodeControle/Sprite2D
@onready var frames_do_livro: int = livro.hframes * livro.vframes

@onready var anim_sprite = $NodeControle/AnimatedSprite2D
@onready var btn_anterior = $NodeControle/BtnAnterior
@onready var btn_proxima = $NodeControle/BtnProxima

var pagina_atual: int = 0
var total_paginas: int = 10
var animando: bool = false

var posicao_escondida: float = -648

func _ready() -> void:
	node_controle.position.y = posicao_escondida
	atualizar_botoes()

func _on_btn_anterior_pressed():
	if pagina_atual > 0 and not animando:
		animando = true
		anim_sprite.play("backwards")
		pagina_atual -= 1
		atualizar_botoes()
		

func _on_animated_sprite_2d_animation_finished():
	animando = false
	

func atualizar_botoes():
	if pagina_atual == 0:
		btn_anterior.disabled = true
	else:
		btn_anterior.disabled = false
		
	if pagina_atual == total_paginas:
		btn_proxima.disabled = true
	else:
		btn_proxima.disabled = false

func _on_btn_proxima_pressed():
	if pagina_atual < total_paginas and not animando:
		animando = true
		anim_sprite.play("fowards")
		pagina_atual += 1
		atualizar_botoes()

func SubirOMenu(player: PlayerCharacter) -> void:
	if player.is_active:
		player.set_active(false)
		var NewTween: Tween = create_tween()
		NewTween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		NewTween.tween_property(node_controle, "position:y", 0, 1.0)
	else:
		DescerOMenu(player)

func DescerOMenu(player: PlayerCharacter) -> void:
	player.set_active(true)
	var NewTween: Tween = create_tween()
	NewTween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	NewTween.tween_property(node_controle, "position:y", posicao_escondida, 1.0)


func _on_button_pressed() -> void:
	livro.frame = (livro.frame + 1) % frames_do_livro
	
