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
		
	# 2. Divide a string retornada (Ex: "espada,C" vira o Array ["espada", "C"])
	var partes = composicao.split(",")
	
	var elemento_id = ""
	var lixo_id = ""
	
	# 3. Identifica quem é o lixo base e quem é o elemento de cor
	for parte in partes:
		if parte in ["C", "M", "Y"]:
			elemento_id = parte
		else:
			lixo_id = parte # O que sobrar (espada, panela, etc) é o objeto sem cor
			
	print("Dissolvendo " + objeto_alvo.item_name + " em: " + lixo_id + " e " + elemento_id)
	
	# 4. Define o nome exato das cenas a serem carregadas
	# Estamos assumindo que o lixo_id (ex: "espada") é exatamente o nome do arquivo .tscn
	var nome_cena_lixo = lixo_id 
	var nome_cena_elemento = ""
	
	if elemento_id == "C":
		nome_cena_elemento = "ciano"
	elif elemento_id == "M":
		nome_cena_elemento = "magenta"
	elif elemento_id == "Y":
		nome_cena_elemento = "amarelo"
		
	# 5. Carrega as cenas
	var caminho_lixo = "res://itens/" + nome_cena_lixo + ".tscn"
	var caminho_elemento = "res://itens/elementos/" + nome_cena_elemento + ".tscn"
	
	var cena_lixo = load(caminho_lixo) as PackedScene
	var cena_elemento = load(caminho_elemento) as PackedScene
	
	# 6. Instancia e posiciona os itens
	if cena_lixo and cena_elemento:
		var novo_lixo = cena_lixo.instantiate()
		var novo_elemento = cena_elemento.instantiate()
		
		# Offset de posição para que não nasçam colados
		novo_lixo.global_position = objeto_alvo.global_position + Vector2(-15, 0)
		novo_elemento.global_position = objeto_alvo.global_position + Vector2(15, 0)
		
		objeto_alvo.get_parent().add_child(novo_lixo)
		objeto_alvo.get_parent().add_child(novo_elemento)
		
		objeto_alvo.queue_free() # Destrói o item colorido original
	else:
		print("ERRO: Faltam os arquivos " + nome_cena_lixo + ".tscn ou " + nome_cena_elemento + ".tscn na pasta!")
