local utilsTable = {}

function utilsTable.isValidSncl(fileName)
	local found = fileName:find(".sncl")
	if found then
		return true
	else
		return false
	end
end


function utilsTable.conteudoArquivo(fileLocation)
	local file = io.open(fileLocation, 'r')

	if file then
		local fileContent = file:read('*a')
		if fileContent then
			return fileContent
		end
	end

	print("Can't open file.")
end

function utilsTable.parse(gramatica, input)
	lpeg.match(gramatica, input)
	for pos, val in pairs(tabelaSimbolos.links) do
		val:checkEnd()
		val:createConnector()
	end
	for pos, val in pairs(tabelaSimbolos.body) do
		if val:getType() == "media" then
			val:pointRegion()
			val:createDescriptor()
		end
	end
end

function utilsTable.printErro(string, linha)
	if string ~= nil then
		print(ansicolors.red.."ERRO:linha "..linha..": "..string..ansicolors.reset)
	end
end

function utilsTable.printAviso(string, linha)
	if string ~= nil then
		print(ansicolors.yellow.."AVISO:linha "..linha..": "..string..ansicolors.reset)
	end
end

function utilsTable.printNCL(t)
	local NCL = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
	NCL = NCL.."\n<ncl id=\"main\" xmlns=\"http://www.ncl.org.br/NCL3.0/EDTVProfile\">"
	NCL = NCL.."\n\t<head>"

	-- Regions --
	local Regions = ""
	for pos, val in pairs(t.regions) do
		if val:getPrint() then
			Regions = Regions..val:toNCL("\t\t\t")
		end
	end
	if Regions ~= "" then
		NCL = NCL.."\n\t\t<regionBase>"
		NCL = NCL..Regions
		NCL = NCL.."\n\t\t</regionBase>"
	end

	--Descriptors --
	local Descriptors = ""
	for pos, val in pairs(t.descriptors) do
		Descriptors = Descriptors..val:toNCL("\t\t\t")
	end
	if Descriptors ~= "" then
		NCL = NCL.."\n\t\t<descriptorBase>"
		NCL = NCL..Descriptors
		NCL = NCL.."\n\t\t</descriptorBase>"
	end

	-- Connectors --
	local Connectors = ""
	for pos, val in pairs(t.connectors) do
		Connectors = Connectors..val:toNCL("\t\t\t")
	end

	if Connector ~= "" then
		NCL = NCL.."\n\t\t<connectorBase>"
		NCL = NCL..Connectors
		NCL = NCL.."\n\t\t</connectorBase>"
	end
	-- Medias, Contexts, Areas
	NCL = NCL.."\n\t</head>\n\n\t<body>"
	for pos, val in pairs(t.body) do
		if val:getPrint() == true then
			NCL = NCL..val:toNCL("\t\t")
		end
	end

	NCL = NCL.."\n"
	-- Links fora de contexts
	for pos, val in pairs(t.links) do
		NCL = NCL..val:toNCL("\t\t")
	end

	NCL = NCL.."\n\n\t</body>\n</ncl>"
	return NCL
end

return utilsTable

