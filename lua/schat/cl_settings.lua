local Settings = {
	filePath = 'schat.json',

	width = 800,
	height = 450,
	offset_left = 0,
	offset_bottom = 0,

	font_size = 14,
	allow_any_url = false
}

function Settings:ValidateInteger(n, min, max)
	return math.Round( math.Clamp(tonumber(n), min, max) )
end

function Settings:ValidateColor(clr)
	return Color(
		self:ValidateInteger(clr.r or 255, 0, 255),
		self:ValidateInteger(clr.g or 255, 0, 255),
		self:ValidateInteger(clr.b or 255, 0, 255),
		self:ValidateInteger(clr.a or 255, 0, 255)
	)
end

function Settings:Save()
	file.Write(self.filePath, util.TableToJSON({
		width			= self.width,
		height			= self.height,
		font_size		= self.font_size,
		allow_any_url 	= self.allow_any_url,
		offset_left		= self.offset_left,
		offset_bottom	= self.offset_bottom
	}, true))
end

function Settings:Load()
	-- try to load settings
	local rawData = file.Read(self.filePath, 'DATA')
	if rawData == nil then return end

	local data = util.JSONToTable(rawData) or {}

	if data.width then
		self.width = self:ValidateInteger(data.width, 250, 1000)
	end

	if data.height then
		self.height = self:ValidateInteger(data.height, 150, 1000)
	end

	if data.font_size then
		self.font_size = self:ValidateInteger(data.font_size, 10, 64)
	end

	if data.offset_left then
		self.offset_left = self:ValidateInteger(data.offset_left, -1, 1000)
	end

	if data.offset_bottom then
		self.offset_bottom = self:ValidateInteger(data.offset_bottom, -1, 1000)
	end

	self.allow_any_url = tobool(data.allow_any_url)
end

function Settings:ResetDefaultPosition()
	self.offset_left = -1
	self.offset_bottom = -1
end

function Settings:GetDefaultPosition()
	local bottomY = (ScrH() - self.height)
	return
		Either(self.offset_left > 0, self.offset_left, ScrW() * 0.032),
		Either(self.offset_bottom > 0, bottomY - self.offset_bottom, bottomY - ScrH() * 0.18)
end

function Settings:GetDefaultSize()
	return 550, 260
end

function Settings:SetWhitelistEnabled(enabled)
	self.allow_any_url = not enabled

	if enabled then
		SChat.InternalMessage('Whitelist', 'Only load images from trusted websites.')
	else
		SChat.InternalMessage('Whitelist', 'Load images from any website.')
	end
end
 
SChat.Settings = Settings