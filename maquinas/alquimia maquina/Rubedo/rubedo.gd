extends MaquinaBase
class_name Rubedo

var ingredientes: Array[ItemData] = []
var visuais: Array[Node2D] = []

# NOVO: Variáveis para o centro flutuante
var centro_flutuante: Node2D
var tempo_flutuacao: float = 0.0

# A ordem exata que o jogador precisa colocar na máquina
var ordem_requerida: Array[String] = [
	"orange", "olive", "pink", "purple", "cobalt", 
	"turquoise", "ruby", "sapphire", "emerald", "white"
]

func _configura_maquina() -> void:
	print("Eu sou Rubedo e preparo a transmutação final!")

# NOVO: O motor que faz o centro flutuar o tempo todo
func _process(delta: float) -> void:
	if not menu_aberto:
		return
		
	if is_instance_valid(centro_flutuante):
		# O delta faz o tempo avançar suavemente
		tempo_flutuacao += delta 
		
		# Matemática da flutuação (Ajuste os valores multiplicados para mudar a força/velocidade)
		# sin() e cos() criam um movimento de vai-e-vem perfeito.
		var movimento_x = sin(tempo_flutuacao * 1.5) * 15.0 # Vai 15 pixels pra esquerda e direita
		var movimento_y = cos(tempo_flutuacao * 2.0) * 10.0 # Vai 10 pixels pra cima e pra baixo
		
		# A posição base é 550, 340. Somamos o movimento nela!
		centro_flutuante.position = Vector2(550, 340) + Vector2(movimento_x, movimento_y)

func _unhandled_key_input(event: InputEvent) -> void:
	if not menu_aberto:
		return
		
	if not event.is_pressed() or event.is_echo():
		return
		
	if event.keycode == KEY_1: takeItem(0)
	elif event.keycode == KEY_2: takeItem(1)
	elif event.keycode == KEY_3: takeItem(2)
	elif event.keycode == KEY_4: takeItem(3)
	elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		executar_transmutacao()

func takeItem(slot_index: int) -> void:
	var item_retirado = InventarioGlobal.retirar_item(slot_index)
	
	if item_retirado != null:
		if ingredientes.size() < 10: 
			ingredientes.append(item_retirado)
			print("Rubedo pegou: ", item_retirado.ItemName)
			atualizar_visual()
			InventarioGlobal.player_limpe_as_maos.emit()
		else:
			print("O círculo de transmutação já está completo! Pressione ENTER para ativar.")
			InventarioGlobal.colocar_item_no_slot(slot_index, item_retirado)
			
	else:
		if ingredientes.size() > 0:
			var item_devolvido = ingredientes.pop_back() 
			InventarioGlobal.colocar_item_no_slot(slot_index, item_devolvido)
			print("Rubedo devolveu: ", item_devolvido.ItemName)
			atualizar_visual()

func executar_transmutacao() -> void:
	if ingredientes.size() == 10:
		var transmutacao_valida = true
		for i in range(10):
			if ingredientes[i].ItemName != ordem_requerida[i]:
				transmutacao_valida = false
				break
				
		if transmutacao_valida:
			print("A GRANDE TRANSMUTAÇÃO COMEÇOU!")
			# INICIA O EFEITO CINEMATOGRÁFICO AQUI!
			_animacao_cinematica() 
		else:
			print("A ordem ou os elementos estão incorretos! A transmutação falhou.")
	else:
		print("O círculo não está completo!")
		

func atualizar_visual() -> void:
	# 1. Limpa os visuais antigos
	for visual in visuais:
		if is_instance_valid(visual):
			visual.queue_free()
	visuais.clear()
	
	# 2. Cria o Nó Âncora Flutuante se ele não existir ainda
	if centro_flutuante == null or not is_instance_valid(centro_flutuante):
		centro_flutuante = Node2D.new()
		menu_base.NoDeControle.add_child(centro_flutuante)
		
		# Se você tiver um Sprite de um círculo mágico ou pentagrama que você quer
		# que flutue JUNTO com as pedras no fundo, você pode instanciar e adicionar ele 
		# como filho do 'centro_flutuante' aqui mesmo!
	
	# 3. Posiciona os novos itens
	var total = ingredientes.size()
	var raio_do_circulo = 230 
	
	for i in range(total):
		var item = ingredientes[i]
		
		if item.ItemScene == null:
			print("ERRO VISUAL: O item '", item.ItemName, "' não tem cena configurada!")
			continue
			
		var novo_visual = item.ItemScene.instantiate()
		
		# MUDANÇA AQUI: Adicionamos a pedra como filha do Centro Flutuante!
		centro_flutuante.add_child(novo_visual)
		visuais.append(novo_visual)
		novo_visual.z_index = 10
		
		# LÓGICA DE POSICIONAMENTO LOCAL
		# Como o pai (centro_flutuante) já está em 550,340 e se movendo,
		# as pedras orbitam ao redor do (0, 0) dele.
		if i < 9:
			var angulo = i * (TAU / 9.0) - (PI / 2.0)
			var pos_x = cos(angulo) * raio_do_circulo
			var pos_y = sin(angulo) * raio_do_circulo
			novo_visual.position = Vector2(pos_x, pos_y)
			
		else:
			# O 10º item (White) fica exatamente no meio do objeto flutuante
			novo_visual.position = Vector2(0, 0)

func _criar_item_por_nome(nome_do_item: String) -> ItemData:
	var caminho = "res://itens/elementosITEMDATA/" + nome_do_item + "ITEMDATA.tres"
	if FileAccess.file_exists(caminho):
		var NovoItem: ItemData = load(caminho)
		return NovoItem
	
	print("AVISO: Ainda não existe ItemData para: " + nome_do_item)
	return null

func _animacao_cinematica() -> void:
	# Trava o jogador para ele não interromper a cena
	set_process_unhandled_key_input(false)
	
	var tween = create_tween()
	tween.set_parallel(true) # Inicia a linha do tempo paralela
	
	# ==========================================
	# 1. ZOOM (Começa no segundo 0.0 e dura 6.0s)
	# ==========================================
	var camera_jogador = null
	if jogador_atual and jogador_atual.has_node("Camera2D"):
		camera_jogador = jogador_atual.get_node("Camera2D")
		var zoom_alvo = camera_jogador.zoom * 2.5 # Aproxima bem de perto
		tween.tween_property(camera_jogador, "zoom", zoom_alvo, 6.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# ==========================================
	# 2. GLOW (Começa no segundo 2.0 e dura 4.5s)
	# ==========================================
	if is_instance_valid(centro_flutuante):
		# Atrasamos 2.0 segundos para o Glow só começar depois que o Zoom já pegou embalo
		tween.tween_property(centro_flutuante, "modulate", Color(6.0, 6.0, 6.0, 1.0), 4.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(2.0)
	
	# ==========================================
	# 3. FADE TO WHITE (Começa no seg 4.5 e dura 2.5s)
	# ==========================================
	var canvas_branco = CanvasLayer.new()
	canvas_branco.layer = 100
	
	var tela_branca = ColorRect.new()
	tela_branca.color = Color(1.0, 1.0, 1.0, 0.0) # Nasce invisível
	tela_branca.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_branco.add_child(tela_branca)
	add_child(canvas_branco)
	
	# Atrasamos 4.5 segundos. A tela começa a embranquecer enquanto o Glow está explodindo
	tween.tween_property(tela_branca, "color:a", 1.0, 2.5).set_delay(4.5)
	
	# ==========================================
	# 4. O CLÍMAX (Acontece no segundo 7.0)
	# ==========================================
	# Como as animações anteriores somam 7 segundos no total, colocamos esse atraso aqui
	tween.tween_callback(func():
		# A tela agora está totalmente branca. Podemos trocar os itens escondidos!
		ingredientes.clear()
		atualizar_visual()
		
		# Reseta as modificações da câmera e do círculo mágico para o padrão
		if is_instance_valid(centro_flutuante):
			centro_flutuante.modulate = Color(1, 1, 1, 1)
		if camera_jogador:
			# OBS: Coloquei Vector2(1,1) ou (2,2) dependendo de qual é o zoom normal do seu jogo
			camera_jogador.zoom = Vector2(2, 2) 
			
		# Transmuta a Pedra Filosofal
		var novo_item = _criar_item_por_nome("pedra_filosofal") 
		if novo_item != null:
			InventarioGlobal.adicionar_item(novo_item)
			print("Transmutação concluída com sucesso!")
			
		# ==========================================
		# 5. DISSIPANDO A LUZ (Fade Out)
		# ==========================================
		var tween_volta = create_tween()
		# Demora 3 segundos para a luz branca baixar revelando o resultado
		tween_volta.tween_property(tela_branca, "color:a", 0.0, 3.0) 
		tween_volta.tween_callback(func():
			canvas_branco.queue_free() 
			menu_base.DescerOMenu() 
			set_process_unhandled_key_input(true) # Devolve o controle ao jogador
		)
	).set_delay(7.0)
