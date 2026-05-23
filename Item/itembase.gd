# Item.gd
extends Node2D
class_name Item

@export_category("Identidade do Item")
@export var item_id: String = "item_generico" 
@export var item_name: String = "Item Genérico"

@export_category("Receita de Crafting")
@export var can_receive_items: bool = false
@export var required_items: Array[String] = [] 
@export var dissolved_items: Array[String] = [] 
@export var result_item: PackedScene


var remaining_sequence: Array[String] = []

func _ready():
	if can_receive_items:
		remaining_sequence = required_items.duplicate()

# A função agora recebe a String (ID) do item que foi jogado aqui
func apply_item(ingredient_id: String):
	if not can_receive_items:
		return
		
	if ingredient_id == remaining_sequence[0]:
		remaining_sequence.pop_front()
		
		if remaining_sequence.is_empty():
			transmute()
	else:
		print("Ingrediente errado! Resetando a receita...")
		remaining_sequence = required_items.duplicate()

func transmute():
	print(item_name + " transmutado com sucesso!")
	var new_item = result_item.instantiate()
	new_item.global_position = global_position
	get_parent().add_child(new_item)
	queue_free()
