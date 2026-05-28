extends CharacterBody2D
class_name PlayerCharacter

@export var speed: float = 500.0
@export var itens_iniciais: Array[ItemData] = [null, null, null, null]
@export var cena_item_drop: PackedScene 

@onready var meu_inventario := $"Inventário"
@onready var Hand := $Hand
@onready var area_coleta := $AreaColeta
@onready var menu_pause : MenuPause = $MenuPause 

var item_atualmente_equipado: int = 99
var is_active: bool = true 
var inventario_bloqueado: bool = false 
var indice_cheat: int = 0
var is_holding: bool = false
var pedras_do_rubedo: Array[String] = [
	"orange", "olive", "pink", "purple", "cobalt", 
	"turquoise", "ruby", "sapphire", "emerald", "white"
]

# --- NOVAS VARIÁVEIS DE MOVIMENTO ---
var alvo_movimento: Vector2 = Vector2.ZERO
var movendo_automaticamente: bool = false

func _ready() -> void:
	InventarioGlobal.carregar_itens_iniciais(itens_iniciais)
	InventarioGlobal.player_limpe_as_maos.connect(_on_limpar_as_maos_signal)
	pausar()

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	
	# Lógica de movimento automático ou manual
	if movendo_automaticamente:
		direction = global_position.direction_to(alvo_movimento)
		
		# Margem de segurança de 10 pixels para parar e não ficar tremendo
		if global_position.distance_to(alvo_movimento) < 10.0:
			movendo_automaticamente = false
			direction = Vector2.ZERO
			set_active(true) # Devolve o controle ao jogador após chegar
			
	elif is_active:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
	if direction:
		velocity = direction * speed
		Hand.rotation = lerp_angle(Hand.rotation, direction.angle() + Vector2.DOWN.angle(), 0.5)
		inventario_bloqueado = false
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

# --- NOVA FUNÇÃO PARA CHAMAR DE OUTROS SCRIPTS ---
func mover_para_coordenada(alvo: Vector2) -> void:
	alvo_movimento = alvo
	movendo_automaticamente = true
	set_active(false) # Tira o controle manual do jogador temporariamente

func set_active(state: bool) -> void:
	is_active = state
	if not is_node_ready():
		await ready
	if is_active:
		modulate = Color(1, 1, 1, 1) 
		meu_inventario.visible = true
		inventario_bloqueado = false
	else:
		modulate = Color(0.7, 0.7, 0.7, 1)
		meu_inventario.visible = false
		inventario_bloqueado = true

func limpar_as_maos() -> void:
	for item_na_mao in Hand.get_children():
		item_na_mao.queue_free()
	is_holding = false
	item_atualmente_equipado = 99

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
		
	if not inventario_bloqueado:
		if event.keycode == KEY_1: equipar_item(0)
		elif event.keycode == KEY_2: equipar_item(1)
		elif event.keycode == KEY_3: equipar_item(2)
		elif event.keycode == KEY_4: equipar_item(3)
		elif event.keycode == KEY_F and is_active:
			coletar_items()
		elif event.keycode == KEY_G and is_active:
			dropar_items()
		elif event.keycode == KEY_P and is_active:
			cheat()
			
	if event.keycode == KEY_E:
		interagir_com_maquina()
	if event.keycode == KEY_ESCAPE:
		pausar()
	elif event.keycode == KEY_J and is_active:
		dialogar()

func interagir_com_maquina() -> void:
	var todas_as_maquinas = get_tree().get_nodes_in_group("maquina")
	
	for maquina in todas_as_maquinas:
		var placa = maquina.get_node_or_null("Placa")
		
		if placa != null and placa.overlaps_body(self):
			if maquina.has_method("SubirOMenu"):
				maquina.SubirOMenu(self)
			return

func equipar_item(slot_index: int) -> void:
	limpar_as_maos()
	
	if meu_inventario.has_method("moverMaoParaOSlot"):
		meu_inventario.moverMaoParaOSlot(slot_index)
	
	var item_selecionado: ItemData = InventarioGlobal.pegar_item(slot_index)
	
	if item_selecionado != null and item_selecionado.ItemScene != null:
		var novo_item := item_selecionado.ItemScene.instantiate()
		Hand.add_child(novo_item)
		print("Equipou o item: ", item_selecionado.ItemName)
		is_holding = true
		item_atualmente_equipado = slot_index
	else:
		print("Slot vazio!")

func coletar_items() -> void:
	var areas_proximas: Array[Area2D] = area_coleta.get_overlapping_areas()
	for area in areas_proximas:
		var possivelGoblin = area.get_parent().get_parent()
		
		if possivelGoblin is GoblinArea2D:
			if possivelGoblin.isSegurando() and InventarioGlobal.adicionar_item(area.itemdata):
				print("Coletou do goblin: ", area.itemdata.ItemName)
				possivelGoblin.isSegurandoItem = false
				area.queue_free()
				return
				
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
	
	for area in areas_proximas:
		if area is GoblinArea2D and not area.isSegurando():
			var item_para_goblin = InventarioGlobal.retirar_item(item_atualmente_equipado)
			if item_para_goblin:
				area.ReceberItem(item_para_goblin)
				limpar_as_maos()
				print("Item dropado para o goblin!")
				return

	var item_dropado_data = InventarioGlobal.retirar_item(item_atualmente_equipado)
	if item_dropado_data != null:
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

func pausar() -> void:
	menu_pause.SubirOMenu(self)

func cheat() -> void:
	print("=== FORNECEDOR CHEAT ACIONADO ===")
	
	for i in range(4): 
		if indice_cheat >= pedras_do_rubedo.size():
			print("Você já pegou todas as 10 pedras da lista do Rubedo! Reiniciando...")
			indice_cheat = 0 
			
		var nome_pedra = pedras_do_rubedo[indice_cheat]
		var caminho = "res://itens/elementosITEMDATA/" + nome_pedra + "ITEMDATA.tres"
		
		if ResourceLoader.exists(caminho):
			var nova_pedra: ItemData = load(caminho)
			
			if InventarioGlobal.adicionar_item(nova_pedra):
				print("+ Recebeu: ", nome_pedra)
				indice_cheat += 1 
			else:
				print("- Inventário está cheio! Esvazie na máquina antes de pedir mais.")
				break 
		else:
			print("x Arquivo não encontrado: ", caminho)
			indice_cheat += 1 

func _on_limpar_as_maos_signal():
	limpar_as_maos()


func _on_rubedo_mover_jogador(x) -> void:
	mover_para_coordenada(x)
	pass # Replace with function body.
