# ReceitasGlobais.gd (Autoload)
extends Node

# Misturas de 3 itens (Ordem alfabética nas chaves)
var receita = {
	"B,G,R": "White",
	"G,R,R": "Orange",
	"G,G,R": "Olive",
	"B,R,R": "Pink",
	"B,B,R": "Purple",
	"B,B,G": "Cobalt",
	"B,G,G": "Turquoise",
	"R,R,R": "Ruby",
	"B,B,B": "Sapphire",
	"G,G,G": "Emerald"
}

# Misturas de 2 itens (Dissolvidos - Ordem alfabética nas chaves)
var dissolucao = {
	"G,R": "Y", # Yellow
	"B,R": "M", # Magenta
	"B,G": "C" , # Cyan
	"espada,C" : "espada ciano"
}

func consultar_mistura(ingredientes_jogados: Array[String]) -> String:
	var lista_ordenada = ingredientes_jogados.duplicate()
	#lista_ordenada.sort() # Organiza: R, G, B vira B, G, R #caso queiramos que tenha ordem
	
	var chave_de_busca = ",".join(lista_ordenada)
	
	# Procura primeiro nas de 3 itens
	if receita.has(chave_de_busca):
		return receita[chave_de_busca]
		
	# Depois procura nas de 2 itens
	if dissolucao.has(chave_de_busca):
		return dissolucao[chave_de_busca]
		
	return "" # Retorna vazio se não achar nada
