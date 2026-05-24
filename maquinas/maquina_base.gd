extends Node2D
class_name MaquinaBase

@onready var menu_base: MenuBase = $MenuBase
@onready var placa: Area2D = $Placa

var menu_aberto: bool = false
var jogador_atual: PlayerCharacter = null

func _ready() -> void:
	add_to_group("maquina")
	_configura_maquina() 

func _configura_maquina() -> void:
	pass

# Agora recebe o jogador para poder travar/destravar o inventário dele!
func SubirOMenu(jogador: PlayerCharacter = null) -> void:
	if jogador != null:
		jogador_atual = jogador
		
	if menu_aberto:
		menu_base.DescerOMenu()
		menu_aberto = false
		if placa.has_method("fade_texto"):
			placa.fade_texto(1.0) 
			
		# Destrava o jogador
		if jogador_atual:
			jogador_atual.inventario_bloqueado = false
	else:
		menu_base.SubirOMenu()
		menu_aberto = true
		if placa.has_method("fade_texto"):
			placa.fade_texto(0.0)
			
		# Trava o jogador
		if jogador_atual:
			jogador_atual.inventario_bloqueado = true
