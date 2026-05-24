extends Area2D

@onready var texto = $Label

var animacao_fade: Tween 

func _ready() -> void:

	texto.modulate.a = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:

		if animacao_fade and animacao_fade.is_running():
			animacao_fade.kill()
		

		animacao_fade = create_tween()
		

		animacao_fade.tween_property(texto, "modulate:a", 1.0, 0.3)


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerCharacter:
		if animacao_fade and animacao_fade.is_running():
			animacao_fade.kill()
			
		animacao_fade = create_tween()
		animacao_fade.tween_property(texto, "modulate:a", 0.0, 0.3)

		var maquina = get_parent()
		if maquina.menu_aberto == true:
			maquina.SubirOMenu()
