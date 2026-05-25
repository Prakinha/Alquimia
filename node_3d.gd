extends Node3D
class_name MenuOrbita3D

@export var tamanho_das_gemas: float = 4.0
@export var velocidade_giro: float = 0.8
@export var raio_orbitacao: float = 2.5
@export var altura_flutuacao: float = 0.3

var gemas_visuais: Array[Node3D] = []
var tempo_giro: float = 0.0

var nomes_gemas: Array[String] = [
	"orange", "olive", "pink", "purple", "cobalt", 
	"turquoise", "ruby", "sapphire", "emerald", "white"
]

func _ready() -> void:
	print("Inicializando menu 3D com gemas orbitando...")
	_carregar_gemas()

func _carregar_gemas() -> void:
	for nome in nomes_gemas:
		var caminho = "res://itens/elementosITEMDATA/" + nome + "ITEMDATA.tres"
		
		if ResourceLoader.exists(caminho):
			var item_data: ItemData = load(caminho)
			
			if item_data and item_data.ItemScene:
				var cena_2d_temporaria = item_data.ItemScene.instantiate()
				var textura_encontrada = _achar_textura(cena_2d_temporaria)
				
				if textura_encontrada != null:
					var nova_gema_3d = Sprite3D.new()
					nova_gema_3d.texture = textura_encontrada
					nova_gema_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED 
					nova_gema_3d.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST 
					nova_gema_3d.scale = Vector3(tamanho_das_gemas, tamanho_das_gemas, tamanho_das_gemas)
					add_child(nova_gema_3d)
					gemas_visuais.append(nova_gema_3d)
				else:
					print("AVISO: Nenhuma textura encontrada para a gema: ", nome)
				
				cena_2d_temporaria.queue_free()
			else:
				print("AVISO: ", nome, " não possui ItemScene configurada!")
		else:
			print("ERRO: Arquivo não encontrado - ", caminho)

func _achar_textura(no: Node) -> Texture2D:
	if no is Sprite2D and no.texture != null:
		return no.texture
	elif no is TextureRect and no.texture != null:
		return no.texture
		
	for filho in no.get_children():
		var textura_encontrada = _achar_textura(filho)
		if textura_encontrada != null:
			return textura_encontrada 
			
	return null 

func _process(delta: float) -> void:
	tempo_giro += delta * velocidade_giro
	
	var total = gemas_visuais.size()
	if total == 0:
		return
		
	for i in range(total):
		var gema = gemas_visuais[i]
		var angulo = i * (TAU / total) + tempo_giro
		var pos_x = cos(angulo) * raio_orbitacao
		var pos_z = sin(angulo) * raio_orbitacao
		var pos_y = sin(tempo_giro * 2.0 + i) * altura_flutuacao
		gema.position = Vector3(pos_x, pos_y, pos_z)
