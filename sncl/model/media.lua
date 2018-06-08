Media = {}
Media_mt = {}

Media_mt.__index = Media

function Media.new()
	local mediaObject = {id=nil, source=nil, mType=nil, region = nil, descriptor = nil, properties={}, areas={}, _print=true, _end=nil }
	setmetatable(mediaObject, Media_mt)
	return mediaObject
end

--Setters
function Media:setId(id)
	self.id = id
end
function Media:setPrint(bool)
	self._print = bool
end
function Media:setSource(source)
	if self.source  then
		utils.printErro("Media ja tem source:", linha)
	else
		self.source = source
	end
end
function Media:setType(mType, linha)
	if self.mType then --Se ja tiver tipo
		--Imprimir que ja tem tipo
		utils.printErro('Media ja tem tipo.', linha)
	else
		--Adicionar tipo
		self.mType = mType
	end
end

-- Add

function Media:setRegion(region)
	self.region = region
end
function Media:addArea(area)
	table.insert(self.areas, area)
end

function Media:addProperty(property, value)
	if self.properties[property] then --Se ja tem essa property
		utils.printErro('Media property '..property..' ja declarada.', linha)
	else
		self.properties[property] = value
	end
end

--Getters
function Media:getId() return self.id end
function Media:getSource() return self.source end
function Media:getmType() return self.mType end
function Media:getType() return "media" end
function Media:getPrint() return self._print end
function Media:getRegion() return self.region end

--Checagens

function Media:checkProperty(property)
	for pos, val in pairs(mediaProperties) do
		if property == val then
			return true
		end
	end
	return false
end

function Media:checkType(mType)
	for pos, val in pairs(mediaTypes) do
		if mType == val then
			return true
		end
	end
	return false
end

function Media:pointRegion()
	for pos, val in pairs(tabelaSimbolos.regions) do
		if val:getId() == self.region then
			self.region = val
		end
	end
end

function Media:createDescriptor()
	if self.region then
		local newDescriptor = Descriptor:new()

		local descId = self.region:getId()
		descId = descId.."Desc"
		
		self.descriptor = newDescriptor
		newDescriptor:setId(descId)
		newDescriptor:setRegion(self.region)
		tabelaSimbolos[descId] = newDescriptor
		tabelaSimbolos.descriptors[descId] = newDescriptor
	end
end

-- Gerador de NCL
function Media:toNCL(indent) --Fazer checagens aqui
	local NCL = "\n"..indent.."<media id=\""..self.id.."\""

	if self.source then
		NCL = NCL.." src=\""..self.source.."\""
	end
	if self.mType then
		NCL = NCL.." type=\""..self.mType.."\""
	end
	if self.descriptor then
		NCL = NCL.." descriptor=\""..self.descriptor:getId().."\""
	end
	NCL = NCL.." >"

	for pos, val in pairs(self.properties) do
		if pos ~= "region" then
			NCL = NCL.."\n"..indent.."\t<property name=\""..pos.."\" value=\""..val.."\"/>"
		end
	end

	for pos, val in pairs(self.areas) do
		NCL = NCL..val:toNCL(indent.."\t")
	end

	NCL = NCL.."\n"..indent.."</media>"
	return NCL
end

local mediaProperties = {
	'style', 'player', 'reusePlayer', 'playerLife', 'deviceClass', 'explicitDur',
	'focusIndex', 'moveLeft', 'moveRight', 'moveUp', 'moveDown', 'top', 'bottom',
	'left', 'right', 'width', 'height', 'location', 'size', 'bounds', 'background',
	'rgbChromakey', 'visible', 'transparency', 'fit', 'scroll', 'zIndex', 'plan',
	'focusBorderColor', 'selBorderColor', 'focusBorderWidth', 'focusBorderTransparency',
	'focusSrc', 'focusSelSrc', 'freeze', 'contentId', 'standby', 'soundLevel',
	'balanceLevel', 'trebleLevel', 'bassLevel', 'transIn', 'transOut', 'fontColor',
	'fontFamily', 'textAlign', 'fontStyle', 'fontSize', 'fontVariant', 'fontWeight',
	'system.language', 'system.caption', 'system.subtitle', 'system.returnBitRate',
	'system.screenSize', 'system.screenGraphicSize', 'system.audioType', 'system.devNumber',
	'system.classType', 'system.parentDeviceRegion', 'system.info', 'system.classNumber',
	'system.CPU', 'system.memory', 'system.operationgSystem', 'system.luaVesion',
	'system.ncl.version', 'system.gingaNCL.version', 'system.xyz', 'service.currentFocus',
	'service.currentKeyMaster', 'service.xyz', 'service.interactivity', 'region'
}

local mediaTypes = {
	'text/html', 'text/css', 'text/xml', 'text/plain', 'image/bmp', 'image/png', 'image/gif',
	'image/jpeg', 'audio/basic', 'audio/x-wav', 'audio/mpeg', 'audio/mpeg4', 'video/mpeg',
	'video/mp4', 'video/x-mng', 'video-quicktime', 'video/x-msvideo', 'application/x-ginga-NCL',
	'application/x-ncl-NCL', 'application/x-ginga-NCLUA', 'application/x-ncl-NCLUA', 'application/x-ginga-NCLet',
	'application/x-ginga-settings', 'application/x-ncl-settings', 'application/x-ginga-time', 'application/x-ncl-time'
}
