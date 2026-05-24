# Item.gd
extends Node2D # Ou Area2D/RigidBody2D dependendo do seu jogo
class_name Item

@export_category("Identidade do Item")
@export var item_id: String = "item_generico" 
@export var item_name: String = "Item Genérico"

@export_category("Configuração de Mistura")
@export var can_receive_items: bool = false
@export var max_ingredients: int = 3 

var used_items: Array[String] = []


var ingredients_used_to_create_me: Array[String] = []

func apply_item(ingredient_id: String):
	if not can_receive_items:
		return
		
	used_items.append(ingredient_id)
	print("Panela recebeu: ", ingredient_id, " | Mistura atual: ", used_items)
	
	# Pergunta para o Autoload se essa mistura que está na panela existe
	var nome_resultado = Receitas.consultar_mistura(used_items)
	
	if nome_resultado != "":
		# Se achou uma receita válida, transforma!
		transmute(nome_resultado)
		
	elif used_items.size() >= max_ingredients:
		# Se a panela encheu até o limite e não deu em nada, a receita falhou
		print("Mistura falhou! Resetando a panela...")
		used_items.clear()

func transmute(nome_da_cena: String):
	print(item_name + " transmutou para " + nome_da_cena + "!")
	
	# ⚠️ ATENÇÃO: Ajuste este caminho para a pasta onde você salva as cenas dos seus itens!
	var caminho_da_cena = "res://itens/elementos/" + nome_da_cena + ".tscn"
	var cena_carregada = load(caminho_da_cena) as PackedScene
	
	if cena_carregada:
		var new_item = cena_carregada.instantiate()
		
		# Passa a história dos itens usados para o novo item
		new_item.ingredients_used_to_create_me = self.used_items.duplicate()
		new_item.global_position = global_position
		
		get_parent().add_child(new_item)
		queue_free() # Destrói a panela atual
	else:
		print("ERRO: O arquivo " + nome_da_cena + ".tscn não foi encontrado na pasta.")




func dissolver(objeto_alvo: Node2D):
	# Validação de segurança
	if not is_instance_valid(objeto_alvo) or not objeto_alvo is Item:
		print("Objeto inválido para dissolução.")
		return
		
	# 1. Faz a engenharia reversa no Autoload
	var composicao = Receitas.consultar_dissolucao(objeto_alvo.item_id)
	
	if composicao == "":
		print("O item " + objeto_alvo.item_name + " não é um item dissolvível.")
		return
		
	# 2. Divide a string retornada pelo Autoload (Ex: "Azul,Verde" -> ["Azul", "Verde"])
	var partes = composicao.split(",")
	print("Dissolvendo " + objeto_alvo.item_name + " nas partes: ", partes)
	
	# 3. Determina o tipo de dissolução baseado no que o Autoload nos devolveu
	var caminho_1 = ""
	var caminho_2 = ""
	
	# CENÁRIO A: Dissolvendo um objeto pintado (Ex: "espada,C")
	if partes.size() == 2 and ("C" in partes or "M" in partes or "Y" in partes):
		var lixo_id = ""
		var elemento_id = ""
		
		for parte in partes:
			if parte in ["C", "M", "Y"]:
				elemento_id = parte
			else:
				lixo_id = parte
				
		var nome_cena_elemento = ""
		if elemento_id == "C": nome_cena_elemento = "ciano"
		elif elemento_id == "M": nome_cena_elemento = "magenta"
		elif elemento_id == "Y": nome_cena_elemento = "amarelo"
		
		caminho_1 = "res://itens/" + lixo_id + ".tscn"
		caminho_2 = "res://itens/elementos/" + nome_cena_elemento + ".tscn"

	# CENÁRIO B: Dissolvendo uma cor pura em duas pedras base (Ex: "Azul,Verde")
	elif partes.size() == 2:
		# Puxa diretamente o arquivo da pedra usando o nome (ex: "Azul.tscn")
		# Atenção: Ajuste este caminho se as pedras base ficarem em outra pasta!
		caminho_1 = "res://itens/elementos/" + partes[0] + ".tscn"
		caminho_2 = "res://itens/elementos/" + partes[1] + ".tscn"
		
	else:
		print("Erro: A composição não tem duas partes para dissolver: ", partes)
		return

	# 4. Carrega as cenas
	var cena_1 = load(caminho_1) as PackedScene
	var cena_2 = load(caminho_2) as PackedScene
	
	# 5. Instancia e posiciona os itens
	if cena_1 and cena_2:
		var item_1 = cena_1.instantiate()
		var item_2 = cena_2.instantiate()
		
		# Offset de posição
		item_1.global_position = objeto_alvo.global_position + Vector2(-20, 0)
		item_2.global_position = objeto_alvo.global_position + Vector2(20, 0)
		
		objeto_alvo.get_parent().add_child(item_1)
		objeto_alvo.get_parent().add_child(item_2)
		
		objeto_alvo.queue_free() # Destrói o item original
	else:
		print("ERRO DE CARREGAMENTO: Verifique se as cenas existem na pasta:")
		print("Tentou carregar 1: ", caminho_1)
		print("Tentou carregar 2: ", caminho_2)
