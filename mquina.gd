extends Node2D

@export var hand_node: Node2D 
var item_fisco_na_mao: Node2D = null

func equipar_item_do_inventario_compartilhado(slot_index: int) -> void:
	if is_instance_valid(item_fisco_na_mao):
		item_fisco_na_mao.queue_free()
	
	for filho in hand_node.get_children():
		filho.queue_free()
		
	item_fisco_na_mao = null
	
	if InventarioGlobal.has_method("pegar_item_do_slot"):
		var item_selecionado: ItemData = InventarioGlobal.pegar_item_do_slot(slot_index)
		
		if item_selecionado != null and item_selecionado.ItemScene != null:
			var novo_item := item_selecionado.ItemScene.instantiate() as Node2D
			hand_node.add_child(novo_item)
			novo_item.position = Vector2.ZERO
			item_fisco_na_mao = novo_item
