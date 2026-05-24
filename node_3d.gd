extends Node3D
class_name MenuOrbita3D

@export var tamanho_das_gemas: float = 4.0 # Aumente ou diminua isso no Inspector!
@export var velocidade_giro: float = 0.8
@export var raio_orbitacao: float = 2.5 # No 3D os valores são menores (metros)
@export var altura_flutuacao: float = 0.3 # O quanto as pedras sobem e descem

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
		
		if FileAccess.file_exists(caminho):
			var item_data: ItemData = load(caminho)
			
			if item_data and item_data.ItemScene:
				var cena_2d_temporaria = item_data.ItemScene.instantiate()
				
				# Chama a nova função detetive para revirar a cena toda
				var textura_encontrada = _achar_textura(cena_2d_temporaria)
				
				if textura_encontrada != null:
					var nova_gema_3d = Sprite3D.new()
					nova_gema_3d.texture = textura_encontrada
					nova_gema_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED 
					nova_gema_3d.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST 
					
					# === ADICIONE ESTA LINHA AQUI ===
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

# ========================================================
# NOVA FUNÇÃO: O Detetive de Texturas (Busca Recursiva)
# ========================================================
func _achar_textura(no: Node) -> Texture2D:
	# Verifica se o nó atual é o que guarda a imagem
	if no is Sprite2D and no.texture != null:
		return no.texture
	elif no is TextureRect and no.texture != null:
		return no.texture
		
	# Se não for, vasculha todos os filhos desse nó um por um
	for filho in no.get_children():
		var textura_encontrada = _achar_textura(filho)
		if textura_encontrada != null:
			return textura_encontrada # Se achar, devolve a imagem pra cima!
			
	return null # Se revirou tudo e não achou, retorna nulo
func _process(delta: float) -> void:
	tempo_giro += delta * velocidade_giro
	
	var total = gemas_visuais.size()
	if total == 0:
		return
		
	for i in range(total):
		var gema = gemas_visuais[i]
		
		# Calcula o ângulo inicial da gema na roda + o avanço do tempo
		var angulo = i * (TAU / total) + tempo_giro
		
		# A matemática circular no eixo horizontal (X e Z)
		var pos_x = cos(angulo) * raio_orbitacao
		var pos_z = sin(angulo) * raio_orbitacao
		
		# Uma leve flutuação vertical no eixo Y para dar vida (cada gema sobe/desce em tempos diferentes)
		var pos_y = sin(tempo_giro * 2.0 + i) * altura_flutuacao
		
		# Aplica a posição 3D
		gema.position = Vector3(pos_x, pos_y, pos_z)
