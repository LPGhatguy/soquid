--[[
	Soquid: templates that don't suck
	Version 1.0.0
	Lucien Greathouse (LPGhatguy)
	PUBLIC DOMAIN
]]

local soquid
soquid = {
	version = "1.0.1",
	versionMajor = 1,
	versionMinor = 0,
	versionRevision = 1,

	partials = {},

	defaultEnvironment = {
		math = math,
		string = string,
		table = table,
		tostring = tostring,
		tonumber = tonumber,
		ipairs = ipairs,
		pairs = pairs,
		unpack = unpack,
		next = next,
		select = select,
		type = type,
		newproxy = newproxy,
		renderPartial = function(name, data)
			if (soquid.partials[name]) then
				return soquid.executeTemplate(soquid.partials[name], data)
			else
				return ("[could not load partial '%s']"):format(name)
			end
		end
	}
}

local block_pattern = "%-?%-?%s*{%%%s*(.-)%s*%%}" --matches {% block %}
local put_pattern = "^=%s*(.+)" --matches the inner part of {%= output %}

local function load_with_environment(code, environment)
	if (setfenv) then --5.0, 5.1, LuaJIT
		local func = loadstring(code)
		setfenv(func, environment)

		return func
	else --5.2, newer?
		return load(code, nil, nil, environment)
	end
end

local function shallow_copy(from, to)
	to = to or {}
	for key, value in pairs(from) do
		to[key] = value
	end
	return to
end

local function strip_line_if_just_spaces(line)
	if (line:match("^[\t ]*$")) then
		return ""
	end
end

--[[
	Takes the contents of a soquid-enabled document and compiles it to a real Soquid template
]]
function soquid.compileDocument(document)
	--Determine how many equals signs we need to safely embed this document's contents in a string
	local equals_depth = 0
	for signs in document:gmatch("[%[%]](=+)[%[%]]") do
		equals_depth = math.max(equals_depth, #signs)
	end

	local equals = ("="):rep(equals_depth + 1) --We'll use this in our embedded strings
	local output_buffer = {}
	local last = 0 --The last character we dealt with

	while (true) do
		local start, finish, result = document:find(block_pattern, last)

		--Have we finished dealing with template blocks?
		if (not start) then
			break
		end

		--Gather up all the plain document contents since the last block, generate code to print it
		--We use the number of equals signs we calculated above
		local precontent = document:sub(last, start - 1)
		precontent = precontent:gsub("^[^\n]+$", strip_line_if_just_spaces)
		table.insert(output_buffer, ("_([%s[%s]%s])"):format(equals, precontent, equals))

		if (result:sub(1, 1) == "=") then
			--'put'-style template blocks output directly to screen
			table.insert(output_buffer, ("_(%s)"):format(result:match(put_pattern)))
		else
			--This block is plain code
			table.insert(output_buffer, result)
		end

		--We've dealt with all the characters to this point
		last = finish + 1
	end

	--Gather all of the document after the last template block
	local postcontent = document:sub(last)
	table.insert(output_buffer, ("_([%s[%s]%s])"):format(equals, postcontent, equals))

	return table.concat(output_buffer, "\n")
end

--[[
	Executes an already-compiled Soquid document with the given data
]]
function soquid.executeTemplate(template, data)
	--Create a relatively sandboxed environment
	local env = shallow_copy(data, shallow_copy(soquid.defaultEnvironment))

	--Define a buffer append function so the template can write out results
	local buffer = {}
	local function append_to_buffer(s)
		table.insert(buffer, s)
	end

	env._ = append_to_buffer

	--Load the function and try executing it
	local func = load_with_environment(template, env)
	local result, err = pcall(func)

	--Did something go wrong? Abort!
	if (not result) then
		return false, err
	end

	--Yield the results
	return table.concat(buffer)
end

--[[
	Compiles and executes a Soquid document with the given data
	Performs no caching, beware!
]]
function soquid.renderDocument(document, data)
	return soquid.executeTemplate(soquid.compileDocument(document), data)
end

--[[
	Adds a partial document with a given name
]]
function soquid.addPartial(name, document)
	local compiled = soquid.compileDocument(document)
	soquid.partials[name] = compiled
end

return soquid