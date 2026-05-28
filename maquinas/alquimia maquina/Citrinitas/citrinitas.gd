extends MaquinaBase
class_name Citrinas

var ingredientes: Array[ItemData] = []
var visuais: Array[Node2D] = []

# Variável nova para guardar o objeto visual do preview
var visual_preview: Node2D = null

func _configura_maquina() -> void:
	print("Eu sou Citrinas e estou pronta para fundir!")

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
		executar_juncao()

func takeItem(slot_index: int) -> void:
	var item_retirado = InventarioGlobal.retirar_item(slot_index)
	
	if item_retirado != null:
		if ingredientes.size() < 3:
			ingredientes.append(item_retirado)
			print("Citrinas pegou: ", item_retirado.ItemName)
			atualizar_visual()
			_checar_preview_receita() # Atualiza o preview!
			InventarioGlobal.player_limpe_as_maos.emit()
		else:
			print("A máquina já está cheia! Devolvendo...")
			InventarioGlobal.colocar_item_no_slot(slot_index, item_retirado)
			
	else:
		if ingredientes.size() > 0:
			var item_devolvido = ingredientes.pop_back()
			InventarioGlobal.colocar_item_no_slot(slot_index, item_devolvido)
			print("Citrinas devolveu: ", item_devolvido.ItemName)
			atualizar_visual()
			_checar_preview_receita() # Atualiza o preview!

func executar_juncao() -> void:
	if ingredientes.size() >= 2:
		var nomes_ingredientes: Array[String] = []
		for item in ingredientes:
			nomes_ingredientes.append(item.ItemName)
			
		print("Tentando misturar: ", nomes_ingredientes)
		var nome_resultado = Receitas.consultar_mistura(nomes_ingredientes)
		
		if nome_resultado != "":
			print("Sucesso! O resultado é: ", nome_resultado)
			
			# --- MARCA A RECEITA COMO DESCOBERTA ---
			Receitas.marcar_receita_feita(nomes_ingredientes)
			
			# Limpa tudo: itens e o preview flutuante
			ingredientes.clear()
			atualizar_visual()
			_limpar_preview()
			
			var novo_item = _criar_item_por_nome(nome_resultado)
			
			if novo_item != null:
				InventarioGlobal.adicionar_item(novo_item)
				print("Item ", nome_resultado, " enviado para o inventário!")
			
		else:
			print("Essa mistura não resulta em nada. Receita inválida!")
			
	else:
		print("Preciso de pelo menos 2 itens para fazer uma junção!")

func atualizar_visual() -> void:
	for visual in visuais:
		if is_instance_valid(visual):
			visual.queue_free()
	visuais.clear()
	
	var total = ingredientes.size()
	for i in range(total):
		var item = ingredientes[i]
		
		if item.ItemScene == null:
			print("ERRO VISUAL: O item '", item.ItemName, "' não tem cena configurada!")
			continue
			
		var novo_visual = item.ItemScene.instantiate()
		menu_base.NoDeControle.add_child(novo_visual)
		visuais.append(novo_visual)
		
		novo_visual.z_index = 10
		novo_visual.scale = Vector2(1.5, 1.5)
		
		var espacamento = 10
		var pos_x = 390 + (i - (total - 1) / 2.0) * espacamento
		novo_visual.position = Vector2(pos_x, 270)

# --- FUNÇÕES PARA O PREVIEW ---

func _checar_preview_receita() -> void:
	_limpar_preview() # Limpa qualquer preview anterior primeiro
	
	if ingredientes.size() >= 2:
		var nomes_ingredientes: Array[String] = []
		for item in ingredientes:
			nomes_ingredientes.append(item.ItemName)
			
		var nome_resultado = Receitas.consultar_mistura(nomes_ingredientes)
		
		if nome_resultado != "":
			# --- CHECAGEM DE RECEITA DESCOBERTA ---
			var nome_para_mostrar = nome_resultado
			
			if not Receitas.checar_se_ja_foi_feita(nomes_ingredientes):
				nome_para_mostrar = "Espada" # Coloque aqui o nome do seu item placeholder de interrogação depois!
				print("Receita desconhecida! Mostrando placeholder.")
			
			# Cria o preview visual baseado na variável nome_para_mostrar
			var item_preview = _criar_item_por_nome(nome_para_mostrar)
			
			if item_preview != null and item_preview.ItemScene != null:
				visual_preview = item_preview.ItemScene.instantiate()
				menu_base.NoDeControle.add_child(visual_preview)
				
				visual_preview.z_index = 15
				visual_preview.scale = Vector2(2.0, 2.0)
				
				var pos_inicial = Vector2(740, 280)
				visual_preview.position = pos_inicial
				visual_preview.modulate.a = 0.3
				
				var tween = visual_preview.create_tween().set_loops()
				tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				
				tween.tween_property(visual_preview, "position:y", pos_inicial.y - 15, 1.0)
				tween.parallel().tween_property(visual_preview, "modulate:a", 0.8, 1.0)
				
				tween.tween_property(visual_preview, "position:y", pos_inicial.y, 1.0)
				tween.parallel().tween_property(visual_preview, "modulate:a", 0.5, 1.0)

func _limpar_preview() -> void:
	if is_instance_valid(visual_preview):
		visual_preview.queue_free()
		visual_preview = null

func _criar_item_por_nome(nome_do_item: String) -> ItemData:
	var caminho = "res://itens/elementosITEMDATA/" + nome_do_item + "ITEMDATA.tres"
	if ResourceLoader.exists(caminho):
		var NovoItem: ItemData = load(caminho)
		return NovoItem
	
	print("AVISO: Ainda não existe ItemData para: " + nome_do_item + " ou Função _criar_item_por_nome precisa ser implementada.")
	return null
