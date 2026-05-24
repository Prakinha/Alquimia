extends MaquinaBase
class_name Nigredo

var item_dissoluto: ItemData 
var item_visual: Node2D 

func _configura_maquina() -> void:
	print("Eu sou Nigredo e estou pronto para dissolver!")

func _unhandled_key_input(event: InputEvent) -> void:
	# A mágica está aqui: ele usa a variável menu_aberto da MaquinaBase!
	if not menu_aberto:
		return
		
	if not event.is_pressed() or event.is_echo():
		return
		
	if event.keycode == KEY_1: takeItem(0)
	elif event.keycode == KEY_2: takeItem(1)
	elif event.keycode == KEY_3: takeItem(2)
	elif event.keycode == KEY_4: takeItem(3)
	elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		executar_dissolucao()

func takeItem(slot_index: int) -> void:
	if item_dissoluto == null:
		var item_retirado = InventarioGlobal.retirar_item(slot_index)
		if item_retirado != null:
			item_dissoluto = item_retirado
			atualizar_visual()
			print("Máquina pegou: ", item_dissoluto.ItemName)
	else:
		if InventarioGlobal.colocar_item_no_slot(slot_index, item_dissoluto):
			print("Máquina devolveu: ", item_dissoluto.ItemName)
			item_dissoluto = null
			atualizar_visual()
		else:
			var item_do_inventario = InventarioGlobal.retirar_item(slot_index)
			InventarioGlobal.colocar_item_no_slot(slot_index, item_dissoluto)
			item_dissoluto = item_do_inventario
			atualizar_visual()
			print("Trocou pelo item: ", item_dissoluto.ItemName)
			
			

func executar_dissolucao() -> void:
	if item_dissoluto != null and is_instance_valid(item_visual):
		if item_visual.has_method("dissolver"):
			print("Tentando dissolver: ", item_dissoluto.ItemName)
			item_visual.dissolver(item_visual)
			
			item_dissoluto = null
			atualizar_visual() 
		else:
			print("Este item não possui a função de dissolver. Devolvendo...")
			InventarioGlobal.adicionar_item(item_dissoluto)
			item_dissoluto = null
			atualizar_visual()
			
	else:
		print("Nenhum item na máquina para dissolver!")
func atualizar_visual() -> void:
	if is_instance_valid(item_visual):
		item_visual.queue_free()
		item_visual = null
		
	if item_dissoluto != null:
		if item_dissoluto.ItemScene == null:
			print("ERRO VISUAL: O ItemData '", item_dissoluto.ItemName, "' não tem cena no Inspector!")
			return
			
		item_visual = item_dissoluto.ItemScene.instantiate()
		
		# A MÁGICA AQUI: Em vez de add_child(item_visual), nós 
		# adicionamos ele como filho do NoDeControle do MenuBase!
		menu_base.NoDeControle.add_child(item_visual)
		
		# Ajuste a posição de acordo com o centro do NoDeControle
		item_visual.position = Vector2(410, 300) 
		item_visual.z_index = 10
