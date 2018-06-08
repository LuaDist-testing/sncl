lpeg = require("lpeg")
argparse = require("argparse")
ansicolors = require("ansicolors")

--[[
package.path = package.path..";./model/init.lua;./grammar/init.lua"
require("model")
require("grammar")
]]--
utils = require("sncl.utils.utils")
require("sncl.grammar.grammar_parser")
require("sncl.grammar.grammar_scan")

require("sncl.model.descriptor")
require("sncl.model.connector")
require("sncl.model.context")
require("sncl.model.region")
require("sncl.model.media")
require("sncl.model.link")
require("sncl.model.area")

--Variaveis globais
linha = 1
tabelaSimbolos = {}
tabelaSimbolos.regions = {}
tabelaSimbolos.connectors = {}
tabelaSimbolos.descriptors = {}
tabelaSimbolos.body = {}
tabelaSimbolos.links = {}
temErro = false 

function beginParse(entrada, saida) 
	if utils.isValidSncl(entrada) == true then
		local conteudoArquivoEntrada = utils.conteudoArquivo(entrada)
		utils.parse(snclGrammar, conteudoArquivoEntrada)
		if temErro == false then
			arquivoSaida = nil
			arquivoSaida = entrada:sub(1, entrada:len()-4)
			arquivoSaida = arquivoSaida.."ncl"
			arquivoSaida = io.open(arquivoSaida, "w")
			if arquivoSaida ~= nil then
				io.output(arquivoSaida)
				io.write(utils.printNCL(tabelaSimbolos))
				io.close(arquivoSaida)
			else
				print "ERRO NO ARQUIVO DE SAIDA"
				print(arquivoSaida)
			end
		else
			print "ARQUIVO TEM ERRO"
		end
	else
		print("Arquivo nao é um sncl valido")
	end
end
