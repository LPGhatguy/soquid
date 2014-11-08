--[[
	You can use Soquid to generate webpages if you use a framework that's Lua-enabled

	Output of this file is in simplewebsite.html
]]
local soquid = require("soquid")

local my_document = [=[
<!doctype>
<html>
	<head>
		<title>{%= title %}</title>
	</head>

	<body>
		<h1>{%= title %}</h1>
		<p>{%= content %}</p>

		{% if (user.authenticated) then %}
			<p>You are logged in as {%= user.name %}</p>
		{% else %}
			<p>You are not logged in!</p>
		{% end %}
	</body>
</html>
]=]

local data = {
	title = "My Site",
	content = "My Site is the world's premiere source of garbage and placeholder content.",
	user = {
		authenticated = true,
		name = "bartnes"
	}
}

local pageBody = soquid.renderDocument(my_document, data)

print(pageBody)