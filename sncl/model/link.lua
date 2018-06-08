Link = {}
Link_mt = {}

Link_mt.__index = Link

--Tables
local conditions = {"onSelection", "onBeginSelection", "onEndSelection",
	"onBeginAttribution", "onEndAttribution",
	"onAbortAttribution", "onPauseAttribution",
	"onResumeAttribution"}

local actions = {"start", "stop", "abort", "pause", "resume", "set",
	"startAttribution", "stopAttribution",
	"abortAttribution", "pauseAttribution", "resumeAttribution"}

local conditionParams = {"delay", "key", "eventType", "transition"}

local actionParams = {"delay", "eventType", "actionType", "value", "repeat",
	"repeatDelay", "duration", "by"}

function Link.new()
	local linkObject = {conditions = {},  actions = {}, xconnector=nil, _end = nil}
	setmetatable(linkObject, Link_mt)
	return linkObject
end

--Set
function Link:setEnd(linha)
	self._end = linha
end
--Add
function Link:addCondition(condition)
	table.insert(self.conditions, condition)
end

function Link:addConditionParam(param, paramValue)
end

function Link:addAction(action)
	table.insert(self.actions, action)
end

--Get
function Link:getType()
	return "link"
end

function Link:getActions()
	return self.actions
end

function Link:getConditions()
	return self.conditions
end

--Checagens
function Link.checkCondition(condition)
end

function Link.checkActions(action)
end

function Link.checkConditionParam(param)
	for pos, val in pairs(conditionParams) do
		if param == val then
			return true
		end
	end
	return false
end

function Link:checkActionParam(param)
end

function Link:checkEnd()
	print"checking end"
	if (self._end == nil) then
		hasError = 1
		print("Link "..self.id.." nao tem end")
	else
		--for pos, val in pairs(self.actions) do
			--if ºk
		--end
	end
end

function Link:createConnector()

	local newConnector = Connector:new()

	for pos, val in pairs(self.conditions) do
		newConnector:addCondition(val.condition)
		if val.param then
			newConnector:addConditionParam(val.param)
		end
	end

	for pos, val in pairs(self.actions) do
		newConnector:addAction(val.action, val.params)
		if val.param then
			newConnector:addActionParam(val.param)
		end
	end
	newConnector:setId()
	
	local Id = newConnector:getId()
	self.xconnector = Id
	if tabelaSimbolos[Id] == nil then
		tabelaSimbolos[Id] = newConnector
		tabelaSimbolos.connectors[Id] = newConnector
	end

end

-- Gerador de NCL
function Link:toNCL(indent) --Fazer verificacao aqui

	local Link = "\n"..indent.."<link xconnector=\""..self.xconnector.."\">"

	-- CONDITIONS --
	for pos, val in pairs(self.conditions) do
		local component = val.media
		local role = val.condition
		local interface = val.interface
		local param = val.param
		local bindParam = nil

		Link = Link.."\n"..indent.."\t<bind role=\""..role.."\" component=\""..component
		if interface then
			Link = Link.."\" interface=\""..interface.."\" />"
		end

		if param then
			bindParam="\n"..indent.."\t\t<bindParam name=\"keyCode\" value=\""..param.."\" />"
		end

		if bindParam then
			Link = Link.."\" >"
			Link = Link..bindParam
			Link = Link.."\n"..indent.."\t</bind>"
		else
			Link=Link.."\" />"
		end
	end

	-- ACTIONS --
	for pos, val in pairs(self.actions) do -- Cada pos eh um action
		local bindParam = nil
		local action = val.action 
		local media = val.media 
		local interface = val.interface 
		local param = val.param

		if param then --Se a action tem params
			bindParam = "\n"..indent.."\t\t<bindParam name=\"var\" value=\""..param.."\"/>"
		end

		Link = Link.."\n"..indent.."\t<bind role=\""..action.."\" component=\""..media.."\"" -- Escreve a action
		if interface then
			Link = Link.." interface=\""..interface.."\""
		end

		if bindParam == nil then
			Link = Link.."/>"
		else
			Link = Link..">"
			Link = Link..bindParam
			Link = Link.."\n"..indent.."\t</bind>"
		end
	end

	Link = Link.."\n"..indent.."</link>"

	return Link
end
