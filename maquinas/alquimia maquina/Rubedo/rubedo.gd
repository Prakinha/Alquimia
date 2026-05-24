extends MaquinaBase
class_name Rubedo

var ingredientes: Array[ItemData] = []
var visuais: Array[Node2D] = []

# A ordem exata que o jogador precisa colocar na máquina
var ordem_requerida: Array[String] = [
	"orange", "olive", "pink", "purple", "cobalt", 
	"turquoise", "ruby", "sapphire", "emerald", "white"
]

func _configura_maquina() -> void:
	print("Eu sou Rubedo e preparo a transmutação final!")

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
	
	# Se o jogador clicou num slot que TEM um item
	if item_retirado != null:
		if ingredientes.size() < 10: # O limite agora é a transmutação de 10 itens
			ingredientes.append(item_retirado)
			print("Rubedo pegou: ", item_retirado.ItemName)
			atualizar_visual()
		else:
			print("O círculo de transmutação já está completo! Pressione ENTER para ativar.")
			InventarioGlobal.colocar_item_no_slot(slot_index, item_retirado)
			
	# Se o jogador clicou num slot VAZIO, ele quer pegar um item de volta
	else:
		if ingredientes.size() > 0:
			var item_devolvido = ingredientes.pop_back() 
			InventarioGlobal.colocar_item_no_slot(slot_index, item_devolvido)
			print("Rubedo devolveu: ", item_devolvido.ItemName)
			atualizar_visual()

func executar_transmutacao() -> void:
	# 1. Verifica se a máquina tem os 10 itens
	if ingredientes.size() == 10:
		var transmutacao_valida = true
		
		# 2. Verifica se estão exatamente na ordem requerida
		for i in range(10):
			# Lembre-se: se você migrou para usar item_id em vez de ItemName, mude a linha abaixo!
			if ingredientes[i].ItemName != ordem_requerida[i]:
				transmutacao_valida = false
				break
				
		if transmutacao_valida:
			print("A GRANDE TRANSMUTAÇÃO COMEÇOU!")
			
			# Limpa os itens do círculo
			ingredientes.clear()
			atualizar_visual() 
			
			# GERA O ITEM FINAL (Substitua "pedra_filosofal" pelo nome do seu item supremo)
			var novo_item = _criar_item_por_nome("pedra_filosofal") 
			
			if novo_item != null:
				InventarioGlobal.adicionar_item(novo_item)
				print("Transmutação concluída com sucesso!")
		else:
			print("A ordem ou os elementos estão incorretos! A transmutação falhou.")
			# Opcional: Você pode adicionar lógica aqui para devolver todos os 10 itens ao jogador ou destruí-los.
			
	else:
		print("O círculo não está completo! Faltam elementos. (Atual: ", ingredientes.size(), "/10)")

func atualizar_visual() -> void:
	# 1. Limpa os visuais antigos
	for visual in visuais:
		if is_instance_valid(visual):
			visual.queue_free()
	visuais.clear()
	
	# 2. Posiciona os novos itens
	var total = ingredientes.size()
	var centro_x = 550
	var centro_y = 340
	var raio_do_circulo = 230 # Aumente ou diminua para afastar/aproximar os itens do centro
	
	for i in range(total):
		var item = ingredientes[i]
		
		if item.ItemScene == null:
			print("ERRO VISUAL: O item '", item.ItemName, "' não tem cena configurada!")
			continue
			
		var novo_visual = item.ItemScene.instantiate()
		menu_base.NoDeControle.add_child(novo_visual)
		visuais.append(novo_visual)
		novo_visual.z_index = 10
		
		# LÓGICA DE POSICIONAMENTO
		if i < 9:
			# Distribui os 9 primeiros itens em um círculo perfeito
			# TAU equivale a 360 graus. Subtraímos PI/2 para o primeiro item ficar exatamente no topo (12 horas).
			var angulo = i * (TAU / 9.0) - (PI / 2.0)
			
			var pos_x = centro_x + cos(angulo) * raio_do_circulo
			var pos_y = centro_y + sin(angulo) * raio_do_circulo
			novo_visual.position = Vector2(pos_x, pos_y)
			
		else:
			# O 10º item (White) fica exatamente no meio
			novo_visual.position = Vector2(centro_x, centro_y)

# =======================================================
# FUNÇÃO DE CRIAÇÃO DO ITEM
# =======================================================
func _criar_item_por_nome(nome_do_item: String) -> ItemData:
	var caminho = "res://itens/elementosITEMDATA/" + nome_do_item + "ITEMDATA.tres"
	if FileAccess.file_exists(caminho):
		var NovoItem: ItemData = load(caminho)
		return NovoItem
	
	print("AVISO: Ainda não existe ItemData para: " + nome_do_item)
	return null
