local S, R, V, P = lpeg.S, lpeg.R, lpeg.V, lpeg.P
local Cg, Ct, C = lpeg.Cg, lpeg.Ct, lpeg.C

local SPC = V'ESPACO'
local NL = V'NEWLINE'
local insideAction = false


snclGrammar = {
	'INICIAL';

	------ Bases ------
	ESPACO = S' \t\r\f',
	NEWLINE = (S'\n'
	/function(ch)
		if ch:byte() == 10 then
			linha = linha+1
		end
	end),

	Inteiro = R("09"),
	Alpha =  (R'az'+R'AZ'),
	AlphaNumeric = (V'Alpha'+P'_'+P'/'+P'.'+P'%'+P','+P'-'+V'Inteiro'),

	AlphaNumericSpaces = (SPC^0*(V'Alpha'+P'_'+P'/'+P'.'+P'%'+P','+V'Inteiro')^1*SPC^0)^1,
	AlphaSpaces = (SPC^0* (R'az'+R'AZ')^1 *SPC^0)^1,


	------ REGION ------
	--[[
	ImportBase = (SPC^0 * V'ImportBaseId'
	*(SPC^0+NL)* (V'ImportBaseProp' + NL)^1
	*(SPC^0+NL)* (V'ImportBaseEnd')),

	ImportBaseId = SPC^0* P'importBase' *SPC^1* V'AlphaNumeric'^1,
	ImportBaseProp = SPC^0* V'AlphaNumeric'^1 *SPC^0* P"=" *SPC^0* V'AlphaNumeric'^1,
	ImportBaseEnd = SPC^0* P'endImportBase',
	--]]

	Region = SPC^0* V'RegionId' 
	*(SPC^0+NL)* (V'Region' + V'RegionProperty' + NL)^0
	*(SPC^0+NL)* V'RegionEnd'/
	function(str)
		if currentRegion then
			if currentRegion:getFather() then
				currentRegion = currentRegion:getFather()
			else
				currentRegion = nil
			end
		end
	end, 

	RegionId = SPC^0* P'region' *SPC^1* V'AlphaNumeric'^1/
	function(str)
		regionScanId(str)
	end,

	RegionProperty = SPC^0* V'AlphaNumeric'^1 *SPC^0* P"=" *SPC^0* V'AlphaNumeric'^1/
	function(str)
		str = str:gsub("%s+", "")
		regionScanProperty(str)
	end,

	RegionEnd = SPC^0* V'AlphaNumeric'^1/
	function(str)
	end,

	------ LINK ------
	Link = (SPC^0+NL)*
	V'Condition'
	*(SPC^0+NL)*
	(V'ConditionParam'+V'Actions'+NL)^0
	*(SPC^0+NL) *
	V'EndLink',

	Exe = (V'AlphaNumeric'^1 *SPC^1* V'AlphaNumeric'^1),

	Condition = ((V'Exe'+SPC^1)^1 *SPC^0* V'AlphaNumeric'^1
	/function(str)
		linkScanCondition(str)
	end),

	ConditionParam = ((SPC^0* V'AlphaNumeric'^1 *SPC^0* P'=' *SPC^0* V'AlphaNumeric'^1)
	/function(str)
		str = str:gsub("%s+", "")
		linkScanConditionParam(str)
	end),

	Actions = V'ActionMedia' *(SPC^0+NL)*
	((V'ActionParam'+NL)^0 * V'EndAction')^0,

	ActionMedia = (SPC^0* V'AlphaNumeric'^1 *SPC^1* V'AlphaNumeric'^1 *SPC^0* V'AlphaNumeric'^0/
	function(str)
		linkScanAction(str)
	end),

	ActionParam = (SPC^0* V'AlphaNumeric'^1 *SPC^0* P'=' *SPC^0* V'AlphaNumeric'^1
	/function(str)
		str = str:gsub("%s+", "")
		linkScanActionParam(str)
	end),

	EndAction = SPC^0* P'endAction'/
	function(str)
		currentAction = nil
	end,

	EndLink = SPC^0* P'endLink'/
	function(str)
		currentLink:setEnd(linha)
		currentLink = nil
	end,

	------ MEDIA ------
	Media = ((SPC^0+NL)*
	V'MediaId'
	*NL*
	(V'Source' + V'Type' + V'Area' + V'Property' + NL)^0
	*(SPC^0+NL)*
	V'EndMedia'/
	function(str)
		currentMedia = nil
	end),

	MediaId = (P'media' *SPC^1* V'AlphaNumericSpaces'^1
	/function(str)
		mediaScanId(str)
	end),

	Source = ((SPC^0* P'src' *SPC^0* P'=' *SPC^0*  V'AlphaNumeric'^1)
	/function (str)
		str = str:gsub("%s+", "")
		mediaScanSource(str)
	end),

	Type = ((SPC^0* P'type' *SPC^0* P'=' *SPC^0* V'AlphaNumeric'^1)
	/function(str)
		str = str:gsub("%s+", "")
		mediaScanType(str)
	end),

	Property = ((SPC^0* V'AlphaNumeric'^1 *SPC^0* P'=' *SPC^0* V'AlphaNumeric'^1)
	/ function (str)
		str = str:gsub("%s+", "")
		mediaScanProperty(str)
	end),

	EndMedia = (SPC^0 * V'AlphaNumeric'^1/
	function(str)
	end),


	------ AREA ------
	Area = (SPC^0* V'AreaId'
	*(SPC^0+NL)*
	(V'AreaProperty' + NL)^0
	*(SPC^0+NL)*
	V'EndArea'^0 *
	(SPC^0+NL)/
	function()
		currentArea = nil
	end),

	AreaId = (SPC^0* P'area' *SPC^1* V'AlphaNumeric'^1 *SPC^0
	/function(str)
		areaScanId(str)
	end),

	AreaProperty = ((SPC^0 * V'AlphaNumeric'^1 *SPC^0* P'=' *SPC^0* V'AlphaNumeric'^1 * SPC^0)
	/function(str)
		str = str:gsub("%s+","")
		areaScanProperty(str)
	end),

	EndArea = SPC^0* V'AlphaNumeric'^1/
	function(str)
	end,

	------ CONTEXT ------
	Context = ((SPC^0+NL)*
	V'ContextId'
	*(SPC^0+NL)*
	(V'ContextPort'+ V'ContextProperty' + V'Link' + V'Context' + V'Media' + NL)^0
	*(SPC^0+NL)*
	V'EndContext'/
	function(str)
		if currentContext then
			if currentContext:getFather() then
				currentContext = currentContext:getFather()
			else
				currentContext = nil
			end
		end
	end),

	ContextId = ((SPC^0 * P'context' * SPC^1 * V'AlphaNumeric'^1)
	/function(str)
		contextScanId(str)
	end),

	ContextPort = ((SPC^0 * P'port' *SPC^1* V'AlphaNumeric'^1 *SPC^1* V'AlphaNumeric'^1)/
	function(str)
		contextScanPort(str)
	end),

	ContextProperty = ((SPC^0 * V'AlphaNumeric'^1 *SPC^0* P'=' *SPC^0 * V'AlphaNumeric'^1)/
	function(str)
		str = str:gsub("%s+","")
		contextScanProperty(str)
	end),

	EndContext = SPC^0* V'AlphaNumeric'^1/
	function(str)
	end,

	-- START --
	INICIAL = (SPC^1 + NL + V'Region' + V'Link'+V'Media' + V'Context')^0,

}
