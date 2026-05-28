# ReceitasGlobais.gd (Autoload)
extends Node

# Misturas de 3 itens (Ordem alfabética nas chaves)
var receita = {
	"B,G,R": {"resultado": "white", "feita": false},
	"G,R,R": {"resultado": "orange", "feita": false},
	"G,G,R": {"resultado": "olive", "feita": false},
	"B,R,R": {"resultado": "pink", "feita": false},
	"B,B,R": {"resultado": "purple", "feita": false},
	"B,B,G": {"resultado": "cobalt", "feita": false},
	"B,G,G": {"resultado": "turquoise", "feita": false},
	"R,R,R": {"resultado": "ruby", "feita": false},
	"B,B,B": {"resultado": "sapphire", "feita": false},
	"G,G,G": {"resultado": "emerald", "feita": false},
	"Azul,Verde,Vermelho": {"resultado": "white", "feita": false},
	"Verde,Vermelho,Vermelho": {"resultado": "orange", "feita": false},
	"Verde,Verde,Vermelho": {"resultado": "olive", "feita": false},
	"Azul,Vermelho,Vermelho": {"resultado": "pink", "feita": false},
	"Azul,Azul,Vermelho": {"resultado": "purple", "feita": false},
	"Azul,Azul,Verde": {"resultado": "cobalt", "feita": false},
	"Azul,Verde,Verde": {"resultado": "turquoise", "feita": false},
	"Vermelho,Vermelho,Vermelho": {"resultado": "ruby", "feita": false},
	"Azul,Azul,Azul": {"resultado": "sapphire", "feita": false},
	"Verde,Verde,Verde": {"resultado": "emerald", "feita": false}
}

# Misturas de 2 itens (Dissolvidos - Ordem alfabética nas chaves)
var dissolucao = {
	"G,R": {"resultado": "Y", "feita": false}, # Yellow
	"B,R": {"resultado": "M", "feita": false}, # Magenta
	"B,G": {"resultado": "C", "feita": false},  # Cyan
	"Verde,Vermelho": {"resultado": "amarelo", "feita": false},
	"Azul,Vermelho": {"resultado": "magenta", "feita": false},
	"Azul,Verde": {"resultado": "ciano", "feita": false},
	"espada,C": {"resultado": "espada_ciano", "feita": false},
	"panela,C": {"resultado": "panela_ciano", "feita": false},
	"bota,M": {"resultado": "bota_magenta", "feita": false},
	"raquete,M": {"resultado": "raquete_magenta", "feita": false},
	"placa,Y": {"resultado": "placa_amarela", "feita": false},
	"trompete,Y": {"resultado": "trompete_amarelo", "feita": false}
}

func consultar_mistura(ingredientes_jogados: Array[String]) -> String:
	var lista_ordenada = ingredientes_jogados.duplicate()
	lista_ordenada.sort() # Organiza: R, G, B vira B, G, R
	
	var chave_de_busca = ",".join(lista_ordenada)
	
	# Procura primeiro nas de 3 itens
	if receita.has(chave_de_busca):
		return receita[chave_de_busca]["resultado"]
		
	# Depois procura nas de 2 itens
	if dissolucao.has(chave_de_busca):
		return dissolucao[chave_de_busca]["resultado"]
		
	return "" # Retorna vazio se não achar nada

func consultar_dissolucao(objeto_id: String) -> String:
	# Percorre todas as chaves do dicionário de dissolução
	for chave in dissolucao:
		# Precisamos acessar o "resultado" dentro do dicionário daquela chave
		if dissolucao[chave]["resultado"] == objeto_id:
			return chave # Retorna a string da receita, ex: "espada,C"
			
	return "" # Retorna vazio se o item não estiver na lista de dissolução

# --- NOVAS FUNÇÕES PARA GERENCIAR STATUS DAS RECEITAS ---

func marcar_receita_feita(ingredientes_jogados: Array[String]) -> void:
	var lista_ordenada = ingredientes_jogados.duplicate()
	lista_ordenada.sort()
	var chave_de_busca = ",".join(lista_ordenada)
	
	if receita.has(chave_de_busca):
		receita[chave_de_busca]["feita"] = true
		print("Receita de 3 itens marcada como feita: ", receita[chave_de_busca]["resultado"])
	elif dissolucao.has(chave_de_busca):
		dissolucao[chave_de_busca]["feita"] = true
		print("Receita de 2 itens marcada como feita: ", dissolucao[chave_de_busca]["resultado"])

func checar_se_ja_foi_feita(ingredientes_jogados: Array[String]) -> bool:
	var lista_ordenada = ingredientes_jogados.duplicate()
	lista_ordenada.sort()
	var chave_de_busca = ",".join(lista_ordenada)
	
	if receita.has(chave_de_busca):
		return receita[chave_de_busca]["feita"]
	elif dissolucao.has(chave_de_busca):
		return dissolucao[chave_de_busca]["feita"]
		
	return false # Se a receita nem existe, retorna falso
