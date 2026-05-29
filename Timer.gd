extends Panel

var time: float = 0.0
var min: int = 0
var sec: int = 0
var msec: int = 0

@onready var minutosText: Label = $Label
@onready var segundosText: Label = $Label2
@onready var msecsText: Label = $Label3

func _ready() -> void:
	TempoFinal.fimdejogo.connect(_on_fim_de_jogo)

func _process(delta: float) -> void:
	time += delta
	msec = fmod(time,1) * 100
	sec = fmod(time,60)
	min = fmod(time,3600) / 60
	minutosText.text = "%02d:" % min
	segundosText.text = "%02d." % sec
	msecsText.text = "%03d" % msec
	
func _on_fim_de_jogo():
	TempoFinal.minFinal = min
	TempoFinal.secFinal = sec
	TempoFinal.msecFinal = msec
	print("o tempo final foi: %02d:%02d.%03d" % [TempoFinal.minFinal, TempoFinal.secFinal, TempoFinal.msecFinal])
	
