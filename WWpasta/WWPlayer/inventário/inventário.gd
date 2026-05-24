extends CanvasLayer

@onready var grid_container: GridContainer = $Panel/MarginContainer/GridContainer
var slots: Array[ItemSlot]

func _ready() -> void:
	# 1. Pega todos os slots visuais
	for filho in grid_container.get_children():
		if filho is ItemSlot:
			slots.append(filho)
	
	# 2. Conecta o sinal do Global! É isso que faz as fotos atualizarem.
	InventarioGlobal.inventario_atualizado.connect(sincronizar_com_global)
	
	# 3. Força uma sincronização inicial
	sincronizar_com_global()

func sincronizar_com_global() -> void:
	for i in range(slots.size()):
		if i < InventarioGlobal.itens.size():
			# Passa a informação do Global para o Slot visual
			slots[i].item = InventarioGlobal.itens[i]
			
			# Chama a função do seu slot que atualiza a textura (foto)
			if slots[i].has_method("update_inventory"):
				slots[i].update_inventory()

# Mantemos essa função pois o Player tenta chamá-la ao apertar 1, 2, 3 ou 4
func moverMaoParaOSlot(slot_index: int) -> void:
	# Se você tiver alguma lógica que desenha uma borda vermelha 
	# no slot selecionado, ela deve ficar aqui!
	pass
