Descriptor = {}
Descriptor_mt = {}

Descriptor_mt.__index = Descriptor

function Descriptor.new()
	local descriptorObject = {id = nil, region = nil, params = {}}
	setmetatable(descriptorObject, Descriptor_mt)
	return descriptorObject
end

-- Setters
function Descriptor:setId(id)
	self.id = id
end

function Descriptor:setRegion(region)
	self.region = region
end

-- Add

--Getters
function Descriptor:getId()
	return self.id
end

function Descriptor:toNCL(indent)
	NCL = "\n"..indent.."<descriptor id=\""..self.id.."\""
	NCL = NCL.." region=\""..self.region:getId().."\" />"

	for pos, val in pairs(self.params) do
	end

	return NCL
end
