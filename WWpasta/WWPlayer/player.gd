extends CharacterBody2D

class_name PlayerCharacter

@export var speed: float = 500.0
@onready var meu_inventario := $"Inventário"
@export var itens_iniciais: Array[ItemData] = [null, null, null, null]
@onready var Hand := $Hand
@onready var area_coleta := $AreaColeta
var item_atualmente_equipado: int = 99



var is_active: bool = true # Define se este personagem recebe comandos

func _ready() -> void:
	if meu_inventario.has_method("carregar_itens"):
		meu_inventario.carregar_itens(itens_iniciais)

func _physics_process(_delta: float) -> void:

	var direction := Vector2.ZERO
	if is_active:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction:
		velocity = direction * speed
		Hand.rotation = lerp_angle(Hand.rotation, direction.angle(), 0.5)
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
	if not event.is_pressed():
		return
	if not is_active:
		return
		
	# Troca por número (1, 2, 3)
	if event.keycode == KEY_Q:
		equipar_item(0)
	elif event.keycode == KEY_W:
		equipar_item(1)
	elif event.keycode == KEY_E:
		equipar_item(2)
	elif event.keycode == KEY_R:
		equipar_item(3)
	elif event.keycode == KEY_F:
		coletar_items()
	elif event.keycode == KEY_G:
		dropar_items()
	elif event.keycode == KEY_J:
		
		dialogar()

		
		
		
func equipar_item(slot_index: int) -> void:
	
	limpar_as_maos()
		
	
	var item_selecionado: ItemData = meu_inventario.pegar_item_do_slot(slot_index)
	
	
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
		if possivelGoblin is GoblinArea2D:
			if meu_inventario.adicionar_item_novo(area.itemdata) and possivelGoblin.isSegurando():
				print("Coletou do goblin: ", area.itemdata.ItemName)
				possivelGoblin.isSegurandoItem = false
				area.queue_free()
				return
			
		
		if area is ItemDrop:
			if meu_inventario.adicionar_item_novo(area.itemdata):
				print("Coletou: ", area.itemdata.ItemName)
				area.queue_free() 
				return 
				
	print("Nenhum item por perto ou inventário cheio.")
func dropar_items() -> void:



	if item_atualmente_equipado == 99:
		print("nemhum item equipado!")
		return


	var areas_proximas: Array[Area2D] = area_coleta.get_overlapping_areas()
	for area in areas_proximas:
		if area is GoblinArea2D:
			if not area.isSegurando():
				area.ReceberItem(meu_inventario.retirar_item_do_slot(item_atualmente_equipado,true))
				limpar_as_maos()
				print("item dropado para o goblin!")
				return
				
			

		
	if meu_inventario.retirar_item_do_slot(item_atualmente_equipado):
		limpar_as_maos()
		print("item dropado!")
		return
	else:
		print("Não foi possível dropar o item!")

func dialogar() -> void:
	pass
