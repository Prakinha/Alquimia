# MaquinaBase.gd
extends Node2D
class_name MaquinaBase

@onready var menu_base: CanvasLayer = $MenuBase
@onready var placa: Area2D = $Placa

var menu_aberto: bool = false

func _ready() -> void:
	add_to_group("maquina")
	_configura_maquina() 

func _configura_maquina() -> void:
	pass

func SubirOMenu() -> void:
	if menu_aberto:
		menu_base.DescerOMenu()
		menu_aberto = false
		if placa.has_method("fade_texto"):
			placa.fade_texto(1.0) 
	else:
		menu_base.SubirOMenu()
		menu_aberto = true
		if placa.has_method("fade_texto"):
			placa.fade_texto(0.0)
