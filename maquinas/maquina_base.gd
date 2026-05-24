extends Node2D

@onready var aviso_e: Label = $AvisoE # Ou Sprite2D se for uma imagem
@onready var menu_da_maquina: CanvasLayer = $MenuDaMaquina # Seu menu
@onready var area_interacao: Area2D = $AreaInteracao

var jogador_perto: bool = false
var menu_aberto: bool = false

func _ready() -> void:
	aviso_e.visible = false
	menu_da_maquina.visible = false
	
	# Conecta os sinais da Area2D via código (assim você não esquece de fazer no Inspector)
	area_interacao.body_entered.connect(_on_area_body_entered)
	area_interacao.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node2D) -> void:
	# Verifica se quem entrou foi o jogador (usando a class_name do seu código anterior)
	if body is PlayerCharacter:
		jogador_perto = true
		if not menu_aberto:
			aviso_e.visible = true # Mostra o aviso para apertar E

func _on_area_body_exited(body: Node2D) -> void:
	if body is PlayerCharacter:
		jogador_perto = false
		aviso_e.visible = false
		
		# Opcional: fecha o menu automaticamente se o jogador sair andando
		if menu_aberto:
			fechar_menu()

func _unhandled_key_input(event: InputEvent) -> void:
	# Se apertou E e o jogador está na área
	if event.is_pressed() and event.keycode == KEY_E and jogador_perto:
		
		if menu_aberto:
			fechar_menu()
		else:
			abrir_menu()

func abrir_menu() -> void:
	menu_aberto = true
	aviso_e.visible = false # Esconde o "E" para não poluir a tela
	menu_da_maquina.visible = true
	
	# Opcional: Se quiser travar o movimento do jogador enquanto o menu está aberto
	# var player = get_tree().get_first_node_in_group("player")
	# player.set_active(false)

func fechar_menu() -> void:
	menu_aberto = false
	menu_da_maquina.visible = false
	aviso_e.visible = true # Mostra o "E" de novo já que ele ainda tá perto
	
	# Opcional: Se quiser destravar o movimento do jogador
	# var player = get_tree().get_first_node_in_group("player")
	# player.set_active(true)
