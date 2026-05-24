extends Node

# Esse sinal é o que avisa a UI para atualizar as fotos!
signal inventario_atualizado
signal player_limpe_as_maos

var itens: Array[ItemData] = [null, null, null, null]

func carregar_itens_iniciais(lista_de_itens: Array[ItemData]) -> void:
	for i in range(lista_de_itens.size()):
		if i < itens.size() and lista_de_itens[i] != null:
			itens[i] = lista_de_itens[i]
	inventario_atualizado.emit() # Avisa a UI

func adicionar_item(novo_item: ItemData) -> bool:
	for i in range(itens.size()):
		if itens[i] == null:
			itens[i] = novo_item
			inventario_atualizado.emit() # Avisa a UI
			return true 
	return false # Inventário cheio

func retirar_item(index: int) -> ItemData:
	if index >= 0 and index < itens.size() and itens[index] != null:
		var item_retirado = itens[index]
		itens[index] = null
		inventario_atualizado.emit() # Avisa a UI
		return item_retirado
	return null

func pegar_item(index: int) -> ItemData:
	if index >= 0 and index < itens.size():
		return itens[index]
	return null
	
func colocar_item_no_slot(index: int, novo_item: ItemData) -> bool:
	if index >= 0 and index < itens.size():
		if itens[index] == null:
			itens[index] = novo_item
			inventario_atualizado.emit() 
			return true
	return false 
