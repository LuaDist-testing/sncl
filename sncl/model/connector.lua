Connector = {}
Connector_mt = {}

Connector_mt.__index = Connector

function Connector.new()
	local connectorObject = {id = nil, conditions = {}, actions = {}, params = {}, condParam = false, actionParam = false}
	setmetatable(connectorObject, Connector_mt)
	return connectorObject
end

function Connector:setId()
	local Id = ""

	for pos, val in pairs(self.conditions) do
		Id = Id..pos
		if val > 1 then
			Id = Id.."N"
		end
	end
	
	for pos, val in pairs(self.actions) do
		Id = Id..pos
		if val.count > 1 then
			Id = Id.."N"
		end
	end

	self.id = Id
end

function Connector:getId()
	return self.id
end

function Connector:addCondition(condition)
	if self.conditions[condition] then
		self.conditions[condition] = self.conditions[condition]+1
	else
		self.conditions[condition] = 1
	end
end

function Connector:addAction(action, params)
	if self.actions[action] then
		self.actions[action].count = self.actions[action].count+1
		if params then
			self.actions[action].params = params
		end
	else
		self.actions[action] = {}
		self.actions[action].count = 1
	end
end

function Connector:addConditionParam(param)
	self.condParam = true
end

function Connector:addActionParam(param)
	self.actionParam = true
end

function Connector:toNCL(indent)
	local NCL = "\n"..indent.."<causalConnector id=\""..self.id.."\">\n"

	--[[
	for pos, val in pairs(self.params) do
		NCL = NCL.."\n"..indent.."<connectorParam name=\""..pos.."\""
	end
	]]
	if self.condParam then
		NCL = NCL.."\n"..indent.."\t<connectorParam name=\"keyCode\" />"
	end

	if self.actionParam then
		NCL = NCL.."\n"..indent.."\t<connectorParam name=\"var\" />"
	end


	local conditionsTable = {}
	for pos, val in pairs(self.conditions) do
		local condition =indent.."\t<simpleCondition role=\""..pos.."\""
		if self.condParam then
			condition = condition.." key=\"$keyCode\""
		end
		if val > 1 then
			condition = condition.." max=\"unbounded\" qualifier=\"seq\""
		end
		condition = condition.."/>"
		table.insert(conditionsTable, condition)
	end

	if #conditionsTable > 1 then
		NCL = NCL..indent.."\t<compoundCondition operator=\"and\" >"
		for pos, val in pairs(conditionsTable) do
			NCL = NCL.."\n\t"..val
		end
		NCL = NCL.."\n"..indent.."\t</compoundCondition>"
	else
		NCL = NCL..conditionsTable[1].."\n"
	end

	local actionsTable = {}
	for pos, val in pairs(self.actions) do
		local action = indent.."\t<simpleAction role=\""..pos.."\""
		if val.count > 1 then
			action = action.." max=\"unbounded\" qualifier=\"seq\""
		end
		if val.params then
			for i, j in pairs(val.params) do
				action = action.." "..i.."=\""..j.."\""
			end
		end
		action = action.." />"
		table.insert(actionsTable, action)
	end
	if #actionsTable > 1 then
		NCL = NCL..indent.."\t<compoundAction operator=\"seq\" >"
		for pos, val in pairs(actionsTable) do
			NCL = NCL.."\n\t"..val
		end
		NCL = NCL.."\n"..indent.."\t</compoundAction>"
	else
		NCL = NCL..actionsTable[1]
	end
	NCL = NCL.."\n"..indent.."</causalConnector>"
	return NCL
end
