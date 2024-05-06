-- This is horrendously cursed, TODO: update once lovely lets you access the individual mod directory
do
  local osString = love.system.getOS()
  local ext = osString == "Windows" and "dll" or osString == "OS X" and "dylib"
  if ext then
    _G.package.cpath = require("lovely").mod_dir.."/?/json5."..ext..";".._G.package.cpath
  end
end
