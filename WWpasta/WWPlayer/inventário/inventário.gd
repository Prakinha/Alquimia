extends CanvasLayer # Ou Panel, dependendo de qual é o seu nó raiz do Inventário

# Pega todos os ItemSlots que estão dentro do GridContainer de uma vez só
@onready var grid_container: GridContainer = $Panel/MarginContainer/GridContainer
@onready var player: PlayerCharacter = self.get_parent()
@export var item_drop: PackedScene
var slots: Array[ItemSlot]

func _ready() -> void:
	for filho in grid_container.get_children():
		if filho is ItemSlot:
			slots.append(filho)



func carregar_itens(lista_de_itens: Array[ItemData]) -> void:

	for i in range(slots.size()):
		if i < lista_de_itens.size():
			slots[i].item = lista_de_itens[i]
			slots[i].update_inventory() 
			
func pegar_item_do_slot(index: int) -> ItemData:
	
	if index >= 0 and index < slots.size():
		return slots[index].item 
		
	return null
	
func retirar_item_do_slot(index: int, paraOGoblin: bool = false) -> ItemData:
	if index >= 0 and index < slots.size():
		if slots[index].item == null:
			return null
		if not paraOGoblin:
			var item_dropado: ItemDrop = item_drop.instantiate()
			item_dropado.itemdata = slots[index].item
			player.get_parent().add_child(item_dropado)
			item_dropado.global_position = player.global_position
		
		var itemRetirado = slots[index].item
		slots[index].item = null
		slots[index].update_inventory()
		
		return itemRetirado
	else:
		return null
		
func adicionar_item_novo(novo_item: ItemData) -> bool:

	for slot in slots:

		if slot.item == null:
			slot.item = novo_item
			slot.update_inventory()
			return true 
			
	# Se o loop terminar e não achar nenhum vazio, o inventário está cheio
	return false


func _on_panel_inventario_alterado() -> void:
	player.limpar_as_maos()
