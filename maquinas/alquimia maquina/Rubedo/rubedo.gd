extends MaquinaBase
class_name Rubedo

var ingredientes: Array[ItemData] = []
var visuais: Array[Node2D] = []

var centro_flutuante: Node2D
var tempo_flutuacao: float = 0.0

signal mover_jogador(x)

var ordem_requerida: Array[String] = [
	"orange", "olive", "pink", "purple", "cobalt", 
	"turquoise", "ruby", "sapphire", "emerald", "white"
]

func _configura_maquina() -> void:
	print("Eu sou Rubedo e preparo a transmutação final!")

func _process(delta: float) -> void:
	if not menu_aberto:
		return
		
	if is_instance_valid(centro_flutuante):
		tempo_flutuacao += delta 
		
		var movimento_x = sin(tempo_flutuacao * 1.5) * 15.0 
		var movimento_y = cos(tempo_flutuacao * 2.0) * 10.0 
		
		centro_flutuante.position = Vector2(550, 340) + Vector2(movimento_x, movimento_y)

func _unhandled_key_input(event: InputEvent) -> void:
	if not menu_aberto:
		return
		
	if not event.is_pressed() or event.is_echo():
		return
		
	if event.keycode == KEY_1: takeItem(0)
	elif event.keycode == KEY_2: takeItem(1)
	elif event.keycode == KEY_3: takeItem(2)
	elif event.keycode == KEY_4: takeItem(3)
	elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		executar_transmutacao()

func takeItem(slot_index: int) -> void:
	var item_retirado = InventarioGlobal.retirar_item(slot_index)
	
	if item_retirado != null:
		if ingredientes.size() < 10: 
			ingredientes.append(item_retirado)
			print("Rubedo pegou: ", item_retirado.ItemName)
			atualizar_visual()
			InventarioGlobal.player_limpe_as_maos.emit()
		else:
			print("O círculo de transmutação já está completo! Pressione ENTER para ativar.")
			InventarioGlobal.colocar_item_no_slot(slot_index, item_retirado)
			
	else:
		if ingredientes.size() > 0:
			var item_devolvido = ingredientes.pop_back() 
			InventarioGlobal.colocar_item_no_slot(slot_index, item_devolvido)
			print("Rubedo devolveu: ", item_devolvido.ItemName)
			atualizar_visual()

func executar_transmutacao() -> void:
	if ingredientes.size() == 10:
		var transmutacao_valida = true
		for i in range(10):
			if ingredientes[i].ItemName != ordem_requerida[i]:
				transmutacao_valida = false
				break
				
		if transmutacao_valida:
			TempoFinal.fimdejogo.emit()
			print("A GRANDE TRANSMUTAÇÃO COMEÇOU!")
			_animacao_cinematica() 
		else:
			print("A ordem ou os elementos estão incorretos! A transmutação falhou.")
	else:
		print("O círculo não está completo!")

func atualizar_visual() -> void:
	for visual in visuais:
		if is_instance_valid(visual):
			visual.queue_free()
	visuais.clear()
	
	if centro_flutuante == null or not is_instance_valid(centro_flutuante):
		centro_flutuante = Node2D.new()
		menu_base.NoDeControle.add_child(centro_flutuante)
		
	var total = ingredientes.size()
	var raio_do_circulo = 230 
	
	for i in range(total):
		var item = ingredientes[i]
		
		if item.ItemScene == null:
			print("ERRO VISUAL: O item '", item.ItemName, "' não tem cena configurada!")
			continue
			
		var novo_visual = item.ItemScene.instantiate()
		
		centro_flutuante.add_child(novo_visual)
		visuais.append(novo_visual)
		novo_visual.z_index = 10
		
		if i < 9:
			var angulo = i * (TAU / 9.0) - (PI / 2.0)
			var pos_x = cos(angulo) * raio_do_circulo
			var pos_y = sin(angulo) * raio_do_circulo
			novo_visual.position = Vector2(pos_x, pos_y)
			
		else:
			novo_visual.position = Vector2(0, 0)

func _criar_item_por_nome(nome_do_item: String) -> ItemData:
	var caminho = "res://itens/elementosITEMDATA/" + nome_do_item + "ITEMDATA.tres"
	if ResourceLoader.exists(caminho):
		var NovoItem: ItemData = load(caminho)
		return NovoItem
	
	print("AVISO: Ainda não existe ItemData para: " + nome_do_item)
	return null

func _animacao_cinematica() -> void:
	
	set_process_unhandled_key_input(false)
	mover_jogador.emit(position)
	var tween = create_tween()
	tween.set_parallel(true)
	
	var camera_jogador = null
	if jogador_atual and jogador_atual.has_node("Camera2D"):
		camera_jogador = jogador_atual.get_node("Camera2D")
		var zoom_alvo = camera_jogador.zoom * 2.5 
		
		tween.tween_property(camera_jogador, "zoom", zoom_alvo, 6.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property($RubedoMenu.get_node("NoDeControle").get_node("TextureRect"), "modulate", Color(6.0, 6.0, 6.0, 0.0), 5.5)
		tween.tween_property($RubedoMenu.get_node("NoDeControle").get_node("circulo2"), "modulate", Color(6.0, 6.0, 6.0, 0.0), 5.5)

	if is_instance_valid(centro_flutuante):
		tween.tween_property(centro_flutuante, "modulate", Color(6.0, 6.0, 6.0, 1.0), 4.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(2.0)
	
	var canvas_branco = CanvasLayer.new()
	canvas_branco.layer = 100
	
	var tela_branca = ColorRect.new()
	tela_branca.color = Color(1.0, 1.0, 1.0, 0.0) 
	tela_branca.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_branco.add_child(tela_branca)
	add_child(canvas_branco)
	
	tween.tween_property(tela_branca, "color:a", 1.0, 2.5).set_delay(4.5)
	
	tween.tween_callback(func():
		var novo_item = _criar_item_por_nome("pedra_filosofal") 
		if novo_item != null:
			InventarioGlobal.adicionar_item(novo_item)
		
		get_tree().change_scene_to_file("res://menu/fim.tscn")
		
	).set_delay(7.0)
