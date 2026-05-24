extends MenuBase
class_name MenuRubedo

# @onready var NoDeControle e posicao_escondida já foram herdados do MenuBase!

func _ready() -> void:
	# O comando super() roda o _ready() do MenuBase original,
	# garantindo que a posição inicial escondida (648) seja configurada.
	super()
	print("Interface gráfica do Rubedo inicializada!")

# Se você quiser que algo especial aconteça visualmente quando o menu subir
func SubirOMenu() -> void:
	super() # Roda a animação original do Tween de subir
	print("Menu do Rubedo subiu!")

# Se você quiser que algo especial aconteça visualmente quando o menu descer
func DescerOMenu() -> void:
	super() # Roda a animação original do Tween de descer
	print("Menu do Rubedo desceu!")
