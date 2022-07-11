-- Simple, generalized code highlighter.
-- Only deals with (, ), {, }, [, ], strings,
-- numbers, and a few functions that may apply
-- to many languages (especially SF/E2/Lua)

local punctuation = {
	['['] = 'bracket',
	[']'] = 'bracket',
	['{'] = 'bracket',
	['}'] = 'bracket',
	['('] = 'bracket',
	[')'] = 'bracket'
}

local groups = {
	['"'] = 'string',
	['\''] = 'string'
}

local keywords = {
	['if'] = 'keyword',
	['then'] = 'keyword',
	['elseif'] = 'keyword',
	['else'] = 'keyword',
	['do'] = 'keyword',
	['end'] = 'keyword',
	['local'] = 'keyword',
	['for'] = 'keyword',
	['while'] = 'keyword',
	['continue'] = 'keyword',
	['var'] = 'keyword',
	['print'] = 'func',
	['true'] = 'const',
	['false'] = 'const',
	['_G'] = 'const'
}

local colors = {
	text = '#FFFFFF',
	bracket = '#FFD700',
	string = '#CE9178',
	number = '#97D879',
	keyword = '#C586C0',
	func = '#DCDCAA',
	const = '#569CD6'
}

function SChat:GenerateHighlightTokens(inputStr)
	local inputLen = string.len(inputStr) + 1
	local tokens = {}
	local buff = ''
	local c = 0

	local function chatAt(idx)
		return string.sub(inputStr, idx, idx)
	end

	local function pushToken(type, value)
		if buff:len() > 0 then
			tokens[#tokens + 1] = {
				color = colors['text'],
				value = buff
			}

			buff = ''
		end

		tokens[#tokens + 1] = {
			color = colors[type],
			value = value
		}
	end

	while c < inputLen do
		c = c + 1

		local char = chatAt(c)

		if punctuation[char] then
			pushToken(punctuation[char], char)
			continue
		end

		if char:find('%d') then
			local value = ''

			while char:find('%d') do
				value = value .. char
				c = c + 1
				char = chatAt(c)
			end

			pushToken('number', value)
			c = c - 1
			continue
		end

		if groups[char] then
			local type = groups[char]
			local opener = char
			local value = char

			c = c + 1
			char = chatAt(c)

			while char ~= opener and c < inputLen do
				value = value .. char
				c = c + 1
				char = chatAt(c)
			end

			pushToken(type, value .. char)
			continue
		end

		if char:find('%a') then
			local value = ''

			while char:find('%w') and c < inputLen do
				value = value .. char
				c = c + 1
				char = chatAt(c)
			end

			pushToken(keywords[value] or 'text', value)
			c = c - 1
			continue
		end

		buff = buff .. char
	end

	if buff:len() > 0 then
		tokens[#tokens + 1] = {
			color = colors['text'],
			value = buff
		}
	end

	return tokens
end