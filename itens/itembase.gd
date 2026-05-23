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
