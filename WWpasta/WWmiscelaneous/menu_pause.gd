extends CanvasLayer
class_name MenuPause

@onready var node_controle: Control = $NodeControle
@onready var livro: Sprite2D = $NodeControle/Sprite2D
@onready var frames_do_livro: int = livro.hframes * livro.vframes

@onready var anim_sprite = $NodeControle/AnimatedSprite2D
@onready var btn_anterior = $NodeControle/BtnAnterior
@onready var btn_proxima = $NodeControle/BtnProxima
@onready var container_receitas = %ContainerReceitas

@onready var paginas_tutoriais = %PaginasTutoriais

var icones_das_receitas: Dictionary = {
	"Azul": preload("res://itens/elementosITEMDATA/AzulITEMDATA.tres"),
	"Verde": preload("res://itens/elementosITEMDATA/VerdeITEMDATA.tres"),
	"Vermelho": preload("res://itens/elementosITEMDATA/VermelhoITEMDATA.tres"),
	"white": preload("res://itens/elementosITEMDATA/whiteITEMDATA.tres"),
	"orange": preload("res://itens/elementosITEMDATA/orangeITEMDATA.tres"),
	"olive": preload("res://itens/elementosITEMDATA/oliveITEMDATA.tres"),
	"pink": preload("res://itens/elementosITEMDATA/pinkITEMDATA.tres"),
	"purple": preload("res://itens/elementosITEMDATA/purpleITEMDATA.tres"),
	"cobalt": preload("res://itens/elementosITEMDATA/cobaltITEMDATA.tres"),
	"turquoise": preload("res://itens/elementosITEMDATA/turquoiseITEMDATA.tres"),
	"ruby": preload("res://itens/elementosITEMDATA/rubyITEMDATA.tres"),
	"sapphire": preload("res://itens/elementosITEMDATA/sapphireITEMDATA.tres"),
	"emerald": preload("res://itens/elementosITEMDATA/emeraldITEMDATA.tres"),
	"amarelo": preload("res://itens/elementosITEMDATA/amareloITEMDATA.tres"),
	"magenta": preload("res://itens/elementosITEMDATA/magentaITEMDATA.tres"),
	"ciano": preload("res://itens/elementosITEMDATA/CianoITEMDATA.tres")
}

var pagina_atual: int = 0
var total_paginas: int = 10
var animando: bool = false
var posicao_escondida: float = -648

var receitas_por_pagina: int = 10
var pagina_de_inicio_das_receitas: int = 2

func _ready() -> void:
	node_controle.position.y = posicao_escondida
	atualizar_botoes()
	atualizar_tela_de_receitas()
	atualizar_conteudo_da_pagina()

func _on_btn_anterior_pressed():
	if pagina_atual > 0 and not animando:
		animando = true
		anim_sprite.play("backwards")
		pagina_atual -= 1
		atualizar_botoes()

func _on_animated_sprite_2d_animation_finished():
	animando = false
	atualizar_conteudo_da_pagina()
	
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

func atualizar_tela_de_receitas():
	for filho in container_receitas.get_children():
		filho.queue_free()
		
	if pagina_atual < pagina_de_inicio_das_receitas:
		container_receitas.hide()
		return
		
	container_receitas.show()
	
	var lista_de_chaves = []
	for chave in Receitas.receita.keys():
		if not ("B" in chave or "G" in chave or "R" in chave):
			lista_de_chaves.append(chave)
			
	var pagina_relativa = pagina_atual - pagina_de_inicio_das_receitas 
	var indice_inicial = pagina_relativa * receitas_por_pagina
	var indice_final = indice_inicial + receitas_por_pagina
	
	for i in range(indice_inicial, indice_final):
		if i >= lista_de_chaves.size():
			break 
			
		var chave = lista_de_chaves[i] 
		var resultado = Receitas.receita[chave] 
		
		criar_linha_visual_da_receita(chave, resultado)

func criar_linha_visual_da_receita(ingredientes_str: String, resultado_str: String):
	var linha = HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var ingredientes = ingredientes_str.split(",")
	
	for i in range(ingredientes.size()):
		var item = ingredientes[i]
		
		var rect_img = TextureRect.new()
		if icones_das_receitas.has(item):
			rect_img.texture = icones_das_receitas[item].icon
		
		rect_img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		rect_img.custom_minimum_size = Vector2(32, 32) 
		linha.add_child(rect_img)
		
		if i < ingredientes.size() - 1:
			var seta = Label.new()
			seta.text = " + "
			seta.add_theme_color_override("font_color", Color(0, 0, 0))
			linha.add_child(seta)
			
	var igual = Label.new()
	igual.text = " = "
	igual.add_theme_color_override("font_color", Color(0, 0, 0))
	linha.add_child(igual)
	
	var rect_resultado = TextureRect.new()
	if icones_das_receitas.has(resultado_str):
		rect_resultado.texture = icones_das_receitas[resultado_str].icon
	rect_resultado.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	rect_resultado.custom_minimum_size = Vector2(32, 32)
	linha.add_child(rect_resultado)
	
	container_receitas.add_child(linha)
	
	
func atualizar_conteudo_da_pagina():
	# 1. Atualiza as receitas (a função que você já tem)
	atualizar_tela_de_receitas()
	
	# 2. Esconde todas as páginas estáticas por padrão
	if paginas_tutoriais != null:
		for pagina in paginas_tutoriais.get_children():
			pagina.hide()
			
		# 3. Se a página atual tiver um nó correspondente, mostra ele
		# O get_child_count() garante que não dê erro se você estiver na página 8 e só tiver 3 páginas desenhadas
		if pagina_atual < paginas_tutoriais.get_child_count():
			paginas_tutoriais.get_child(pagina_atual).show()
func _input(event: InputEvent) -> void:
	# Só permite usar as setas se o menu estiver na tela (posição 0)
	# Isso evita que o jogador vire as páginas enquanto o livro está escondido
	if node_controle.position.y != 0:
		return
		
	# "ui_right" é a seta direita (padrão do Godot)
	if event.is_action_pressed("ui_right"):
		_on_btn_proxima_pressed()
		
	# "ui_left" é a seta esquerda (padrão do Godot)
	elif event.is_action_pressed("ui_left"):
		_on_btn_anterior_pressed()
