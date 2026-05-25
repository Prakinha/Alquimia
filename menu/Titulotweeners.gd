extends Control
@onready var titulo: TextureRect = $Titulo
@onready var aderecos: TextureRect = $Aderecos
var titulotween:Tween
var aderecotween:Tween

func _ready() -> void:
	#titulotween = create_tween()
	#titulotween.set_loops(200)
	#titulotween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#titulotween.tween_property(titulo,"position:y", titulo.position.y + 2, 3)
	#titulotween.tween_property(titulo,"position:y", titulo.position.y - 2, 3)
	#aderecotween = create_tween()
	#aderecotween.set_loops(200)
	#aderecotween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#aderecotween.tween_property(aderecos,"position",aderecos.position + Vector2(16,2),3)
	#aderecotween.tween_property(aderecos,"position",aderecos.position - Vector2(16,2),3)
	pass
	
