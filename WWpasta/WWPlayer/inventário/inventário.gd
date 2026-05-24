extends CanvasLayer

@onready var grid_container: GridContainer = $Panel/MarginContainer/GridContainer
@onready var player: PlayerCharacter = self.get_parent()
@export var item_drop: PackedScene
var slots: Array[ItemSlot]
@onready var HandTexture: TextureRect = %HandTexture


func _ready() -> void:
	for filho in grid_container.get_children():
		if filho is ItemSlot:
			slots.append(filho)
	HandTexture.global_position = slots[0].global_position + Vector2(25,100)
	# Toda vez que a UI abrir/carregar, ela puxa os dados do Global
	sincronizar_com_global()

func sincronizar_com_global() -> void:
	for i in range(slots.size()):
		if i < InventarioGlobal.itens.size():
			slots[i].item = InventarioGlobal.itens[i]
			slots[i].update_inventory()

func carregar_itens(lista_de_itens: Array[ItemData]) -> void:
	for i in range(lista_de_itens.size()):
		if i < InventarioGlobal.itens.size():
			InventarioGlobal.itens[i] = lista_de_itens[i]
	sincronizar_com_global()

func pegar_item_do_slot(index: int) -> ItemData:
	if index >= 0 and index < InventarioGlobal.itens.size():
		return InventarioGlobal.itens[index]
	return null

func retirar_item_do_slot(index: int, paraOGoblin: bool = false) -> ItemData:
	if index >= 0 and index < InventarioGlobal.itens.size():
		if InventarioGlobal.itens[index] == null:
			return null
			
		var itemRetirado = InventarioGlobal.itens[index]
		
		if not paraOGoblin:
			var item_dropado: ItemDrop = item_drop.instantiate()
			item_dropado.itemdata = itemRetirado
			player.get_parent().add_child(item_dropado)
			item_dropado.global_position = player.global_position
		
		# Apaga do Global e da UI
		InventarioGlobal.itens[index] = null
		slots[index].item = null
		slots[index].update_inventory()
		
		return itemRetirado
	else:
		return null

func adicionar_item_novo(novo_item: ItemData) -> bool:
	for i in range(InventarioGlobal.itens.size()):
		if InventarioGlobal.itens[i] == null:
			# Adiciona no Global e na UI simultaneamente
			InventarioGlobal.itens[i] = novo_item
			slots[i].item = novo_item
			slots[i].update_inventory()
			return true 
			
	return false # Inventário cheio

func _on_panel_inventario_alterado() -> void:
	# Importante: se você tiver mecânica de arrastar e soltar (drag and drop)
	# que altera o "slots[i].item" direto na UI, você precisaria atualizar 
	# a array do Global aqui. Se não tiver drag and drop, ignore!
	player.limpar_as_maos()
	
func moverMaoParaOSlot(index: int) -> void:

	var MoverMaoTween: Tween = create_tween()
	MoverMaoTween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	MoverMaoTween.tween_property(HandTexture, "global_position",slots[index].global_position + Vector2(25,100), 0.3)
