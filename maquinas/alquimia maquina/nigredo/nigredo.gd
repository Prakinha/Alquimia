extends MaquinaBase
class_name Nigredo

var item_dissoluto: ItemData 
var item_visual: Node2D 

# Nova variável para guardar os visuais do preview (agora é um Array pois são 2 itens!)
var visuais_preview: Array[Node2D] = []

func _configura_maquina() -> void:
	print("Eu sou Nigredo e estou pronto para dissolver!")

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
		executar_dissolucao()

func takeItem(slot_index: int) -> void:
	if item_dissoluto == null:
		var item_retirado = InventarioGlobal.retirar_item(slot_index)
		if item_retirado != null:
			item_dissoluto = item_retirado
			atualizar_visual()
			_checar_preview_dissolucao() # Mostra o preview
			InventarioGlobal.player_limpe_as_maos.emit()
			print("Máquina pegou: ", item_dissoluto.ItemName)
	else:
		if InventarioGlobal.colocar_item_no_slot(slot_index, item_dissoluto):
			print("Máquina devolveu: ", item_dissoluto.ItemName)
			item_dissoluto = null
			atualizar_visual()
			_checar_preview_dissolucao() # Limpa o preview
		else:
			var item_do_inventario = InventarioGlobal.retirar_item(slot_index)
			InventarioGlobal.colocar_item_no_slot(slot_index, item_dissoluto)
			item_dissoluto = item_do_inventario
			atualizar_visual()
			_checar_preview_dissolucao() # Atualiza o preview pro novo item
			print("Trocou pelo item: ", item_dissoluto.ItemName)

func executar_dissolucao() -> void:
	if item_dissoluto != null:
		var id_alvo = item_dissoluto.ItemName 
		var composicao = Receitas.consultar_dissolucao(id_alvo)
		
		if composicao != "":
			print("Dissolvendo ", id_alvo, " em: ", composicao)
			var partes = composicao.split(",")
			
			# --- MARCA A RECEITA COMO FEITA ---
			var array_partes: Array[String] = []
			array_partes.assign(partes)
			Receitas.marcar_receita_feita(array_partes)
			
			var nome_item_1 = ""
			var nome_item_2 = ""
			
			if partes.size() == 2 and ("C" in partes or "M" in partes or "Y" in partes):
				var lixo_id = ""
				var elemento_id = ""
				for parte in partes:
					if parte in ["C", "M", "Y"]: elemento_id = parte
					else: lixo_id = parte
					
				nome_item_1 = lixo_id
				if elemento_id == "C": nome_item_2 = "ciano"
				elif elemento_id == "M": nome_item_2 = "magenta"
				elif elemento_id == "Y": nome_item_2 = "amarelo"
			elif partes.size() == 2:
				nome_item_1 = partes[0]
				nome_item_2 = partes[1]
				
			item_dissoluto = null
			atualizar_visual()
			_limpar_preview() # Limpa os hologramas ao dissolver
			
			var novo_item_1 = _criar_item_por_nome(nome_item_1)
			var novo_item_2 = _criar_item_por_nome(nome_item_2)
			
			if novo_item_1: InventarioGlobal.adicionar_item(novo_item_1)
			if novo_item_2: InventarioGlobal.adicionar_item(novo_item_2)
			
			print("Sucesso! As partes foram enviadas para o inventário.")
			
		else:
			print("Este item não pode ser dissolvido. Devolvendo...")
			InventarioGlobal.adicionar_item(item_dissoluto)
			item_dissoluto = null
			atualizar_visual()
			_limpar_preview()
			
	else:
		print("Nenhum item na máquina para dissolver!")

func atualizar_visual() -> void:
	if is_instance_valid(item_visual):
		item_visual.queue_free()
		item_visual = null
		
	if item_dissoluto != null:
		if item_dissoluto.ItemScene == null:
			print("ERRO VISUAL: O ItemData '", item_dissoluto.ItemName, "' não tem cena configurada!")
			return
			
		item_visual = item_dissoluto.ItemScene.instantiate()
		menu_base.NoDeControle.add_child(item_visual)
		item_visual.position = Vector2(410, 300) 
		item_visual.z_index = 10
		item_visual.scale = Vector2(1.5, 1.5) # Aumentando a escala igual na Citrinas

# --- NOVAS FUNÇÕES PARA O PREVIEW ---

func _checar_preview_dissolucao() -> void:
	_limpar_preview() # Sempre limpa antes de verificar novamente
	
	if item_dissoluto != null:
		var id_alvo = item_dissoluto.ItemName
		var composicao = Receitas.consultar_dissolucao(id_alvo)
		
		if composicao != "":
			var partes = composicao.split(",")
			var nome_item_1 = ""
			var nome_item_2 = ""
			
			# Recria a lógica de tradução de ID para pegar os nomes visuais certos
			if partes.size() == 2 and ("C" in partes or "M" in partes or "Y" in partes):
				var lixo_id = ""
				var elemento_id = ""
				for parte in partes:
					if parte in ["C", "M", "Y"]: elemento_id = parte
					else: lixo_id = parte
					
				nome_item_1 = lixo_id
				if elemento_id == "C": nome_item_2 = "ciano"
				elif elemento_id == "M": nome_item_2 = "magenta"
				elif elemento_id == "Y": nome_item_2 = "amarelo"
			elif partes.size() == 2:
				nome_item_1 = partes[0]
				nome_item_2 = partes[1]
				
			var resultados = [nome_item_1, nome_item_2]
			
			# Instancia os dois itens gerados
			for i in range(resultados.size()):
				var item_preview = _criar_item_por_nome(resultados[i])
				
				if item_preview != null and item_preview.ItemScene != null:
					var visual = item_preview.ItemScene.instantiate()
					menu_base.NoDeControle.add_child(visual)
					visuais_preview.append(visual)
					
					visual.z_index = 15
					visual.scale = Vector2(1.8, 1.8) # Um pouco maior
					
					# Calcula o X para eles ficarem lado a lado flutuando
					var espacamento = 60 
					var pos_x = 740 + (i - 0.5) * espacamento 
					var pos_inicial = Vector2(pos_x, 300)
					
					visual.position = pos_inicial
					visual.modulate.a = 0.3
					
					# Efeito Tween individual para cada item flutuando
					var tween = visual.create_tween().set_loops()
					tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
					
					tween.tween_property(visual, "position:y", pos_inicial.y - 15, 1.0)
					tween.parallel().tween_property(visual, "modulate:a", 0.8, 1.0)
					
					tween.tween_property(visual, "position:y", pos_inicial.y, 1.0)
					tween.parallel().tween_property(visual, "modulate:a", 0.5, 1.0)

func _limpar_preview() -> void:
	for visual in visuais_preview:
		if is_instance_valid(visual):
			visual.queue_free()
	visuais_preview.clear()

# ------------------------------------

func _criar_item_por_nome(nome_do_item: String) -> ItemData:
	var caminho = "res://itens/elementosITEMDATA/" + nome_do_item + "ITEMDATA.tres"
	
	if ResourceLoader.exists(caminho):
		return load(caminho) as ItemData
		
	print("AVISO: Arquivo .tres não encontrado para: " + nome_do_item)
	return null
