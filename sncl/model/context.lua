Context = {}
Context_mt = {}

Context_mt.__index = Context

function Context.new ()
	local contextObject = {id=nil, refer=nil, ports={}, medias={}, links={}, contexts={}, properties={}, _print = true, father = nil, _end=nil}
	setmetatable(contextObject, Context_mt)
	return contextObject
end

------- Setters -------
function Context:setId (id)
	self.id = id
end

function Context:setPrint(bool)
	self._print = bool
end

function Context:setFather(father)
	self.father = father
end

-- Add -- 
function Context:addMedia (media)
	table.insert(self.medias, media)
end
function Context:addLink (link)
	table.insert(self.links, link)
end
function Context:addContext (context)
	table.insert(self.contexts, context)
end
function Context:addPort(id, component, interface)
	if self.ports[id] then
		utils.printErro("Port com id "..id.." ja declarada.",linha)
	else
		self.ports[id] = {}
		self.ports[id].component = component
		if interface ~= nil then
			self.ports[id].interface = interface
		end
	end
end
function Context:addProperty(name, value)
	self.properties[name] = value
end

------ Getters ------
function Context:getType()
	return "context"
end
function Context:getFather()
	return self.father
end
function Context:getPrint()
	return self._print
end

-- Checagens
function Context:getPrint() return self._print end

-- Gerador de NCL
function Context:toNCL(indent)
	local NCL = "\n"..indent.."<context id=\""..self.id.."\""

	if refer == nil then
		NCL = NCL..">"
	else
		NCL = NCL.." refer=\""..self.refer.."\">"
	end

	for pos, val in pairs(self.ports) do
		NCL = NCL.."\n"..indent.."\t<port id=\""..pos
		for pos1, val1 in pairs(val) do 
			if pos1 == "component" then
				NCL = NCL.."\" component=\""..val1
			elseif pos1 == "interface" then
				NCL = NCL.."\" interface=\""..val1
			end
		end
		NCL = NCL.."\" />"
	end

	for pos, val in pairs(self.properties) do
		NCL = NCL.."\n"..indent.."\t<property name=\""..pos.."\" value=\""..val.."\" />"
	end

	for pos, val in pairs(self.medias) do
		NCL = NCL..val:toNCL(indent.."\t")
	end

	for pos, val in pairs(self.contexts) do
		NCL = NCL..val:toNCL(indent.."\t")
	end

	for pos, val in pairs(self.links) do
		NCL = NCL..val:toNCL(indent.."\t")
	end

	NCL = NCL.."\n"..indent.."</context>"
	return NCL
end

