extends Node2D

func _ready():
	# 1. Configuração Inicial:
	# Garante que a cena comece exatamente como a transição anterior terminou
	$ColorRect.color = Color.WHITE
	
	# Deixa a tela de vitória e o texto transparentes (invisíveis)
	$ScreenVictory.modulate.a = 0.0
	$Label3.modulate.a = 0.0
	
	# Inicia a animação
	animar_cena_final()

func animar_cena_final():
	# Cria um novo Tween. No Godot 4, as animações do Tween
	# acontecem em sequência (uma após a outra) por padrão.
	var tween = create_tween()
	
	# Passo 1: O ColorRect vai de branco para preto. (Duração: 2.0 segundos)
	tween.tween_property($ColorRect, "color", Color.BLACK, 2.0)
	
	# Passo 2: Fade in da ScreenVictory. (Duração: 1.5 segundos)
	tween.tween_property($ScreenVictory, "modulate:a", 1.0, 2.5)
	
	# Passo 3: Fade in do Label3. (Duração: 1.0 segundo)
	tween.tween_property($Label3, "modulate:a", 3.5, 3.0)
