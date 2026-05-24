extends MaquinaBase
class_name Citrinas

var ingredientes: Array[ItemData] = []
var visuais: Array[Node2D] = []

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
	
	# Se o jogador clicou num slot que TEM um item
	if item_retirado != null:
		if ingredientes.size() < 3: # Limite de 3 itens na máquina
			ingredientes.append(item_retirado)
			print("Citrinas pegou: ", item_retirado.ItemName)
			atualizar_visual()
		else:
			print("A máquina já está cheia! Devolvendo...")
			InventarioGlobal.colocar_item_no_slot(slot_index, item_retirado)
			
	# Se o jogador clicou num slot VAZIO, ele quer pegar um item de volta da máquina
	else:
		if ingredientes.size() > 0:
			var item_devolvido = ingredientes.pop_back() # Tira o último item colocado
			InventarioGlobal.colocar_item_no_slot(slot_index, item_devolvido)
			print("Citrinas devolveu: ", item_devolvido.ItemName)
			atualizar_visual()

func executar_juncao() -> void:
	if ingredientes.size() >= 2:
		# Extrai os nomes/IDs dos itens para mandar para o ReceitasGlobais
		var nomes_ingredientes: Array[String] = []
		for item in ingredientes:
			nomes_ingredientes.append(item.ItemName) # Use a propriedade que guarda o nome ("R", "G", etc)
			
		print("Tentando misturar: ", nomes_ingredientes)
		var nome_resultado = Receitas.consultar_mistura(nomes_ingredientes)
		
		if nome_resultado != "":
			print("Sucesso! O resultado é: ", nome_resultado)
			
			# 1. Limpa os ingredientes usados
			ingredientes.clear()
			atualizar_visual() # Limpa as imagens da tela
			
			# 2. Gera o novo item e tenta mandar pro inventário
			var novo_item = _criar_item_por_nome(nome_resultado)
			
			if novo_item != null:
				InventarioGlobal.adicionar_item(novo_item)
				print("Item ", nome_resultado, " enviado para o inventário!")
			
		else:
			print("Essa mistura não resulta em nada. Receita inválida!")
			# Opcional: Ejetar todos os itens de volta se falhar, ou deixá-los na máquina
			
	else:
		print("Preciso de pelo menos 2 itens para fazer uma junção!")

func atualizar_visual() -> void:
	# 1. Limpa todos os visuais antigos
	for visual in visuais:
		if is_instance_valid(visual):
			visual.queue_free()
	visuais.clear()
	
	# 2. Cria os novos visuais baseados na lista atual
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
		
		# Lógica para espalhar os itens lado a lado no MenuBase (Espaçamento de 80 pixels)
		var espacamento = 100
		var pos_x = 410 + (i - (total - 1) / 2.0) * espacamento 
		novo_visual.position = Vector2(pos_x, 300)


# ATENÇÃO: VOCÊ PRECISA CONFIGURAR ESTA FUNÇÃO ABAIXO!

func _criar_item_por_nome(nome_do_item: String) -> ItemData:
	var caminho = "res://itens/elementosITEMDATA/" + nome_do_item + "ITEMDATA.tres"
	if FileAccess.file_exists(caminho):
		var NovoItem: ItemData = load(caminho)
		return NovoItem
	
	print("AVISO: Ainda não existe ItemData para: " + nome_do_item + " ou Função _criar_item_por_nome precisa ser implementada para criar o: ", nome_do_item)
	
	
	return null
