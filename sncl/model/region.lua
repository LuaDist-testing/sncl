Region = {}
Region__mt = {}

Region__mt.__index = Region

local regionProperties = {"title", "left", "right", "top", "bottom", "height",
"width", "zIndex"}

function Region.new()
	local RegionObject = {Id = nil, properties = {}, _print=true, father=nil, _end=nil}
	setmetatable(RegionObject, Region__mt)
	return RegionObject
end

-- Setters
function Region:setId(Id) 
	self.Id = Id 
end
function Region:setPrint(bool)
	self._print = bool
end
function Region:setFather(father)
	self.father = father
end

--Add
function Region:addProperty(attrName, attrValue)
	self.properties[attrName] = attrValue
end
function Region:addRegion(region)
	if self.regions == nil then
		self.regions = {}
	end
	table.insert(self.regions, region)
end

--Getters
function Region:getId()
	return self.Id
end
function Region.getType()
	return "region"
end
function Region:getPrint()
	return self._print
end
function Region:getFather()
	return self.father
end

--Checagens
function Region.checkProperty(property)
end

-- Gerador de codigo
function Region:toNCL(indent)
	local NCL = "\n"..indent.."<region id=\""..self.Id.."\" "

	for pos, val in pairs(self.properties) do
		NCL = NCL..pos.."=\""..val.."\" "
	end

	local regions = nil
	if self.regions then
		regions = ""
		for pos, val in pairs(self.regions) do
			regions = regions..val:toNCL("\t"..indent)
		end
	end
	
	if regions then
		NCL = NCL.." >"..regions.."\n"..indent.."</region>"
	else
		NCL = NCL.."/>"
	end

	return NCL
end
