extends Area2D

@onready var texto = $Label
var animacao_fade: Tween 

func _ready() -> void:
	texto.modulate.a = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		fade_texto(1.0)

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerCharacter:
		fade_texto(0.0)
		
		var maquina = get_parent()
		if maquina.menu_aberto == true:
			maquina.SubirOMenu(body)

func fade_texto(alvo_alpha: float) -> void:
	if animacao_fade and animacao_fade.is_running():
		animacao_fade.kill()
		
	animacao_fade = create_tween()
	animacao_fade.tween_property(texto, "modulate:a", alvo_alpha, 0.3)
