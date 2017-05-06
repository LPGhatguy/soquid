# Soquid Templates for Lua
Soquid is a templating "framework" designed to avoid any sort of fuss. Soquid enables you to write code in Lua instead of something else, enabling code reuse, simple integration, and very low complexity. The core parser and execution engine is only about 150 lines of code!

Soquid works with nearly any type of document, including HTML, Markdown, or even code files!

## Hello World
Generating HTML
```lua
local soquid = require("soquid")

local document = [[
<!doctype html>
<html>
	<head>
		<title>Hello, world!</title>
	</head>

	<body>
		<p>{%= content %}</p>
	</body>
</html>
]]

local data = {
	content = "Hello, world!"
}

print(soquid.renderDocument(document, data))
```

Output
```html
<!doctype html>
<html>
	<head>
		<title>Hello, world!</title>
	</head>

	<body>
		<p>Hello, world!</p>
	</body>
</html>
```

See `demos` for more demonstrations of Soquid functionality.

Soquid uses [SemVer](http://semver.org/).

## Future Features
- Optionally cache compiled documents onto the filesystem

## License
Soquid is public domain, see `LICENSE.txt`.
