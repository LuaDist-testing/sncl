Area = {}
Area_mt = {}

Area_mt.__index = Area

local areaProperties = { "begin", "end", "first","last", "text", "positon", 
	"coords", "label", "clip" }

function Area.new()
	local areaObject = {id = nil, properties = {}, _print = false, _end=nil}
	setmetatable(areaObject, Area_mt)
	return areaObject
end

--Setters
function Area:setId(id) self.id = id end
function Area:addProperty(property, value)
	if self:checkProperty(property) then
		self.properties[property] = value
	else
		utils.printErro(property..' invalido', linha)
	end
end

--Getters
function Area:getId() return self.id end
function Area:getAttributes() return self.properties end
function Area:getType() return "area" end
function Area:getPrint() return self._print end

--Checagens
function Area:checkProperty(property)
	for pos, val in pairs(areaProperties) do
		if val == property then
			return true
		end
	end
	return false
end


-- Gerador de NCL
function Area:toNCL(indent)
	NCL = "\n"..indent.."<area id=\""..self.id.."\" "
	for pos, val in pairs(self.properties) do
		NCL = NCL..pos.."=".."\""..val.."\""
	end
	NCL = NCL.."/>"
	return NCL
end


