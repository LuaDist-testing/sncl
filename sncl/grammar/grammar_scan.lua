currentRegion = nil

currentLink = nil
currentCondition = nil
currentAction = nil

currentContext = nil
currentMedia = nil
currentArea = nil


-- REGION --
function regionScanId(str)
	local w = {}

	for p in str:gmatch("%S+") do
		table.insert(w, p)
	end

	if #w == 2 then
		local Id = w[2]
		if tabelaSimbolos[Id] then
			utils.printErro("Region Id "..Id.." ja declarado.")
		else
			local newRegion = Region:new()
			newRegion:setId(Id)
			if currentRegion then
				currentRegion:addRegion(newRegion)
				newRegion:setPrint(false)
				newRegion:setFather(currentRegion)
			end
			currentRegion = newRegion
			tabelaSimbolos[Id] = newRegion
			tabelaSimbolos.regions[Id] = newRegion
		end
	else
		utils.printErro("Erro", linha)
	end
end

function regionScanProperty(str)
	local igual = str:find("=")

	local name = str:sub(1, igual-1)
	local value = str:sub(igual+1)

	if currentRegion then
		currentRegion:addProperty(name, value)
	else
		utils.printErro("Região não declarada.", linha)
	end
end

-- LINK --
function linkScanCondition(string) -- Insert
	local conditionString = {}

	for p in string:gmatch("%S+") do
		table.insert(conditionString, p)
	end
	
	if conditionString[#conditionString] ~= "do" then
		utils.printErro("Link não termina com do", linha)
		return
	end

	local newLink = Link:new()
	for i=1, #conditionString-1, 2 do
		local condition = conditionString[i]
		local media = conditionString[i+1]
		local interface = nil
		local param = nil

		local barra = media:find("/")

		if barra then
			interface = media:sub(barra+1)
			media = media:sub(1, barra-1)
		end
		
		barra = condition:find("/")
		if barra then
			param = condition:sub(barra+1)
			condition = condition:sub(1, barra-1)
		end

		local conditionTable = {}

		conditionTable.condition = condition
		conditionTable.media = media
		conditionTable.interface = interface
		conditionTable.param = param

		newLink:addCondition(conditionTable)
	end

	if currentContext then
		currentContext:addLink(newLink)
	else
		table.insert(tabelaSimbolos.links, newLink)
	end

	currentLink = newLink
end

function linkScanConditionParam(string)
	if currentLink then
		local igual = string:find("=")

		local param = string:sub(1, igual-1)
		local paramValue = string:sub(igual+1)

		currentLink:addConditionParam(param, paramValue)
	else
	end
end

function linkScanAction(string)
	if currentLink then
		local w = {}
		for p in string:gmatch("%S+") do
			table.insert(w, p)
		end

		local action = w[1]
		local media = w[2]
		local interface = nil
		local param = nil
		if w[3] then
			param = w[3]
		end

		local barra = w[2]:find("/")

		if barra then
			media = w[2]:sub(1, barra-1)
			interface = w[2]:sub(barra+1)
		end

		local newAction = {}
		newAction._end = nil
		newAction.media = media
		newAction.action = action
		newAction.param = param

		if interface then
			newAction.interface = interface
		end
		currentAction = newAction
		currentLink:addAction(newAction)
	else
		utils.printErro("Nao ha link.", linha)
	end
end

function linkScanActionParam(string)
	if currentLink then
		local igual = string:find("=")
		local param = string:sub(1, igual-1)
		local value = string:sub(igual+1)

		if currentAction.params == nil then
			currentAction.params = {}
		end
		currentAction.params[param] = value
	else
	end
end

-- CONTEXT --
function contextScanId(string) --Insert
	local w = {}
	for p in string:gmatch("%S+") do
		table.insert(w, p)
	end

	if #w == 2 then
		local Id = w[2]
		if tabelaSimbolos[Id] then
			utils.printErro("Id "..Id.." ja declarado.", linha)
		else
			local newContext = Context:new()
			newContext:setId(Id)
			if currentContext then
				currentContext:addContext(newContext)
				newContext:setFather(currentContext)
				newContext:setPrint(false)
			else
				tabelaSimbolos[Id] = newContext
				tabelaSimbolos.body[Id] = newContext
			end
			currentContext = newContext
		end
	else
		utils.printErro("Context mais de 2 IDs", linha)
	end

end

function contextScanProperty(string)
	local igual = string:find("=")

	local propName = string:sub(1, igual-1)
	local propValue = string:sub(igual+1)

	if currentContext then
		currentContext:addProperty(propName, propValue)
	else
		utils.printErro("Context nao declarado", linha)
	end
end

function contextScanPort(string)
	local w = {}
	for p in string:gmatch("%S+") do
		table.insert(w, p)
	end

	local id = w[2]
	local component = w[3]
	local interface = nil

	if #w == 3 then
		local ponto = w[3]:find('/')
		if ponto then
			component = w[3]:sub(1, ponto-1)
			interface = w[3]:sub(ponto+1)
		end
		currentContext:addPort(id, component, interface)
	else
	end
end

-- MEDIA -- 
function mediaScanId(str) -- Insert
	local w = {}

	for p in str:gmatch("%S+") do --Separa str em espacos
		table.insert(w, p)
	end

	if #w == 2 then
		local Id = w[2]
		--Se nao tem elementos com esse id
		if tabelaSimbolos[Id] then
			utils.printErro("Id:"..Id.." ja declarado.", linha)
		else
			local newMedia = Media.new()
			newMedia:setId(Id)
			if currentContext then
				currentContext:addMedia(newMedia)
				newMedia:setPrint(false)
			else
				tabelaSimbolos[Id] = newMedia
				tabelaSimbolos.body[Id] = newMedia
			end
			currentMedia = newMedia
		end
	else
		utils.printErro("Media só aceita um ID.", linha)
	end
end

function mediaScanSource(source)
	source = string.sub(source, source:find("=")+1)

	if currentMedia then
		currentMedia:setSource(source)
	else
		utils.printErro("Media nao declarada.", linha)
	end
end

function mediaScanType(mediaType)
	mediaType =string.sub(mediaType, mediaType:find("=")+1)

	if currentMedia then
		currentMedia:setType(mediaType)
	else
	end
end

function mediaScanProperty(property)
	local propertyName = nil
	local propertyValue = nil

	local igual = property:find("=")

	if igual == nil then
		propertyName = property
		propertyValue = "Default"
	else
		propertyName = property:sub(1, igual-1)
		propertyValue = property:sub(igual+1)
	end

	if currentMedia then
		if propertyName == "region" then
			currentMedia:setRegion(propertyValue)
		else
			currentMedia:addProperty(propertyName, propertyValue)
		end
	else
		utils.printErro("Media nao declarada.", linha)
	end
end

-- AREA --
function areaScanId(ID) -- Insert
	local w = {}
	for p in ID:gmatch("%S+") do
		table.insert(w, p)
	end

	if #w == 2 then
		local areaID = w[2]
		if tabelaSimbolos[areaID] then
			utils.printErro("Id "..areaID.." ja declarado.", linha)
		else
			local novaArea = Area:new()
			novaArea:setId(areaID)
			currentArea = novaArea
			currentMedia:addArea(novaArea)
		end
	else
		utils.printErro("Area so aceita um ID.", linha)
	end
end

function areaScanProperty(property)
	if currentArea then
		local igual = property:find("=")

		local propertyName = property:sub(1, igual-1)
		local propertyValue = property:sub(igual+1)
		currentArea:addProperty(propertyName, propertyValue)
	else
		utils.printErro("Area nao declarada.",linha)
	end
end


