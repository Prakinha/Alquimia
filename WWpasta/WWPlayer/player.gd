extends CharacterBody2D
class_name PlayerCharacter

@export var speed: float = 500.0
@export var itens_iniciais: Array[ItemData] = [null, null, null, null]
@export var cena_item_drop: PackedScene # Passe a cena do drop aqui no Inspector do Player!

@onready var meu_inventario := $"Inventário"
@onready var Hand := $Hand
@onready var area_coleta := $AreaColeta

var item_atualmente_equipado: int = 99
var is_active: bool = true 
var inventario_bloqueado: bool = false 

func _ready() -> void:
	# Carrega os itens no Global
	InventarioGlobal.carregar_itens_iniciais(itens_iniciais)

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	if is_active:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
	if direction:
		velocity = direction * speed
		Hand.rotation = lerp_angle(Hand.rotation, direction.angle(), 0.5)
		inventario_bloqueado = false
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func set_active(state: bool) -> void:
	is_active = state
	if not is_node_ready():
		await ready
	if is_active:
		modulate = Color(1, 1, 1, 1) 
		meu_inventario.visible = true
	else:
		modulate = Color(0.7, 0.7, 0.7, 1)
		meu_inventario.visible = false

func limpar_as_maos() -> void:
	for item_na_mao in Hand.get_children():
		item_na_mao.queue_free()
	item_atualmente_equipado = 99

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
		
	# Só permite usar as teclas de inventário se ele NÃO estiver bloqueado
	if not inventario_bloqueado:
		if event.keycode == KEY_1: equipar_item(0)
		elif event.keycode == KEY_2: equipar_item(1)
		elif event.keycode == KEY_3: equipar_item(2)
		elif event.keycode == KEY_4: equipar_item(3)
		elif event.keycode == KEY_F and is_active:
			coletar_items()
		elif event.keycode == KEY_G and is_active:
			dropar_items()
			
	# O botão "E" funciona mesmo com o inventário bloqueado
	if event.keycode == KEY_E:
		interagir_com_maquina()
	elif event.keycode == KEY_J and is_active:
		dialogar()

func interagir_com_maquina() -> void:
	var todas_as_maquinas = get_tree().get_nodes_in_group("maquina")
	
	for maquina in todas_as_maquinas:
		# Usa get_node_or_null para evitar o erro de quebrar o jogo
		var placa = maquina.get_node_or_null("Placa")
		
		# Só checa a colisão SE a placa realmente existir ali dentro
		if placa != null and placa.overlaps_body(self):
			if maquina.has_method("SubirOMenu"):
				maquina.SubirOMenu(self)
			return
		
func equipar_item(slot_index: int) -> void:
	limpar_as_maos()
	
	if meu_inventario.has_method("moverMaoParaOSlot"):
		meu_inventario.moverMaoParaOSlot(slot_index)
	
	# Chama direto do Global
	var item_selecionado: ItemData = InventarioGlobal.pegar_item(slot_index)
	
	if item_selecionado != null and item_selecionado.ItemScene != null:
		var novo_item := item_selecionado.ItemScene.instantiate()
		Hand.add_child(novo_item)
		print("Equipou o item: ", item_selecionado.ItemName)
		item_atualmente_equipado = slot_index
	else:
		print("Slot vazio!")

func coletar_items() -> void:
	var areas_proximas: Array[Area2D] = area_coleta.get_overlapping_areas()
	for area in areas_proximas:
		var possivelGoblin = area.get_parent().get_parent()
		
		# Coleta de Goblin
		if possivelGoblin is GoblinArea2D:
			if possivelGoblin.isSegurando() and InventarioGlobal.adicionar_item(area.itemdata):
				print("Coletou do goblin: ", area.itemdata.ItemName)
				possivelGoblin.isSegurandoItem = false
				area.queue_free()
				return
			
		# Coleta do chão
		if area is ItemDrop:
			if InventarioGlobal.adicionar_item(area.itemdata):
				print("Coletou: ", area.itemdata.ItemName)
				area.queue_free() 
				return 
				
	print("Nenhum item por perto ou inventário cheio.")

func dropar_items() -> void:
	if item_atualmente_equipado == 99:
		print("Nenhum item equipado!")
		return

	var areas_proximas: Array[Area2D] = area_coleta.get_overlapping_areas()
	
	# Entrega para o Goblin primeiro
	for area in areas_proximas:
		if area is GoblinArea2D and not area.isSegurando():
			var item_para_goblin = InventarioGlobal.retirar_item(item_atualmente_equipado)
			if item_para_goblin:
				area.ReceberItem(item_para_goblin)
				limpar_as_maos()
				print("Item dropado para o goblin!")
				return

	# Se não entregou para goblin, joga no chão
	var item_dropado_data = InventarioGlobal.retirar_item(item_atualmente_equipado)
	if item_dropado_data != null:
		# AQUI o player instancia a cena física no mundo (precisa linkar a cena 'cena_item_drop' no Inspector do Player)
		if cena_item_drop:
			var drop_fisico: ItemDrop = cena_item_drop.instantiate()
			drop_fisico.itemdata = item_dropado_data
			get_parent().add_child(drop_fisico)
			drop_fisico.global_position = self.global_position
			
		limpar_as_maos()
		print("Item dropado no chão!")
	else:
		print("Não foi possível dropar o item!")

func dialogar() -> void:
	pass
