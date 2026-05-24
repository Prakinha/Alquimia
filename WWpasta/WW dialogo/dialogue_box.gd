extends Area2D
class_name DialogueArea2D
@export var OwnDialogue: DialogueResource




func StartDialogue() -> void:
	DialogueManager.show_dialogue_balloon(OwnDialogue)
	
	pass
	
