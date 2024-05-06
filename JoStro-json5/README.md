# JSON5

Exposes a lua module for reading [json5](https://json5.org) via lovely

## Usage
```lua
-- Require gives a function table
json5 = require "json5"

-- Return a json encoded string from a given value (also valid json5)
json5.encode({ "oh", {hello = "world"}}) -- Returns '["oh",{"hello":"world"}]'

-- Returns a value representing a given json5 string
json5.decode("[1,2,3,{hello: 'world',},]") -- Returns {1,2,3,{hello = "world"}}
```
