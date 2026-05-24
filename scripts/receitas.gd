# ReceitasGlobais.gd (Autoload)
extends Node

# Misturas de 3 itens (Ordem alfabética nas chaves)
var receita = {
	"B,G,R": "white",
	"G,R,R": "orange",
	"G,G,R": "olive",
	"B,R,R": "pink",
	"B,B,R": "purple",
	"B,B,G": "cobalt",
	"B,G,G": "turquoise",
	"R,R,R": "ruby",
	"B,B,B": "sapphire",
	"G,G,G": "emerald",
	"Azul,Verde,Vermelho": "white",
	"Verde,Vermelho,Vermelho": "orange",
	"Verde,Verde,Vermelho": "olive",
	"Azul,Vermelho,Vermelho": "pink",
	"Azul,Azul,Vermelho": "purple",
	"Azul,Azul,Verde": "cobalt",
	"Azul,Verde,Verde": "turquoise",
	"Vermelho,Vermelho,Vermelho": "ruby",
	"Azul,Azul,Azul": "sapphire",
	"Verde,Verde,Verde": "emerald"
}

# Misturas de 2 itens (Dissolvidos - Ordem alfabética nas chaves)
var dissolucao = {
	"G,R": "Y", # Yellow
	"B,R": "M", # Magenta
	"B,G": "C",  # Cyan
	"verde,vermelho" :"amarelo",
	"azul,vermelho" :"magenta",
	"azul,verde" :"ciano",
	"espada,C": "espada_ciano",
	"panela,C": "panela_ciano",
	"bota,M": "bota_magenta",
	"raquete,M": "raquete_magenta",
	"placa,Y": "placa_amarela",
	"trompete,Y": "trompete_amarelo"
}

func consultar_mistura(ingredientes_jogados: Array[String]) -> String:
	var lista_ordenada = ingredientes_jogados.duplicate()
	lista_ordenada.sort() # Organiza: R, G, B vira B, G, R
	
	var chave_de_busca = ",".join(lista_ordenada)
	
	# Procura primeiro nas de 3 itens
	if receita.has(chave_de_busca):
		return receita[chave_de_busca]
		
	# Depois procura nas de 2 itens
	if dissolucao.has(chave_de_busca):
		return dissolucao[chave_de_busca]
		
	return "" # Retorna vazio se não achar nada

func consultar_dissolucao(objeto_id: String) -> String:
	# Percorre todas as chaves do dicionário de dissolução
	for chave in dissolucao:
		# Se o valor daquela chave for igual ao objeto_id, achamos a origem dele!
		if dissolucao[chave] == objeto_id:
			return chave # Retorna a string da receita, ex: "espada,C"
			
	return "" # Retorna vazio se o item não estiver na lista de dissolução
