# General Instructions

1. Do not add comments to code.
2. Use descriptive variable and function names.
3. If no programming language is specified in a prompt or given by context please use lua. / love2d
4. Alphanumeric sort variables within objects

# Lua specific Instructions

1. before adding imports know that most of the time you will find imports already in the ./_mainImports.lua file
2. imports preferably should be added to the _mainImports.lua file (alphanumeric sorted)
3. utils should be imported in the util/_index.lua file -> only files which are also located in the util folder should be imported here

# how to start the game:

```bash
& "C:\Program Files\LOVE\love.exe" .
```

# you can also run unit tests with:

```bash
lua tests/unitTestLib/main.lua
```

Feel free to propose new unit tests . be aware that 90% off all tests should be handled with the assert_equal function

- do not add any print statements to the test code!

# File example to draw inspiration from

```lua
local MyOObject = {}
MyObject.__index = MyObject

function MyObject.new(param1, param2)
    local self = setmetatable({}, MyObject)
    self.param1 = param1
    self.param2 = param2
    return self
end

return MyObject
```

This will then get imported like this and made available trough the project. Usually in mainImport.lua or util/_index.lua
Alternativly I tend to import an Item object in the ItemManager and then import the ItemManager in the mainImport.lua file.

```lua
MyObject = require("path.to.MyObject")
```