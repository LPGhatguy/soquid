--[[
	Don't forget about partials!

	Output of this file is in partials.html
]]

local soquid = require("soquid")

--A simple master page to contain everything
local master = [=[
<!doctype html>
<html>
	<head>
		<title>{%= title %}</title>
	</head>

	<body>
	{%= content %}
	</body>
</html>
]=]

--A partial that describes a list element with a url and name
local list_element = [=[
<li><a href="{%= url %}">{%= name %}</a></li>
]=]

--A list to contain our partial above
local list_container = [=[
<ul>
	{% for index, element in ipairs(elements) do %}
	{%= renderPartial("list_element", element) %}
	{% end %}
</ul>
]=]

--Register our list element partial with Soquid
soquid.addPartial("list_element", list_element)

--Create some content to put into our page relating to tasty things
local content = soquid.renderDocument(list_container, {
	elements = {
		{
			name = "Mashed Potatoes!",
			url = "mashed.html"
		},

		{
			name = "Fried Potatoes!",
			url = "fried.html"
		},

		{
			name = "STEAK!",
			url = "nomnomnom.html"
		}
	}
})

--Render our main page body
local pageBody = soquid.renderDocument(master, {
	title = "Page Title",
	content = content
})

print(pageBody)