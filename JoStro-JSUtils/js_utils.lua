-- Internal "js_utils" module, contains various functions injected throughout the codebase
local _M = {}

local lovely = require "lovely"
local json = require "json"
local fs = require "nativefs"
local modDir = lovely.mod_dir

-- Iterator for running through mod config files
local function configs(file_name)
  local folders = fs.getDirectoryItemsInfo(modDir,"directory")
  local index = 1
  return function()
    for j = index, #folders do
      local mod_path = modDir.."/"..folders[j].name
      local file = mod_path.."/js_utils/"..file_name
      local info = fs.getInfo(file)
      if info and info.type == "file" then
        local contents, _ = fs.read(file)
        local obj = json.decode(contents)
        if obj then
          index = j + 1
          return obj, mod_path
        end
      end
    end
  end
end

-- Add centers from any config files in installed mods
function _M.addCenters(game)
  local set_amounts = {}
  for _, center in pairs(game.P_CENTERS) do
    if center.set and center.order then
      set_amounts[center.set] = math.max(set_amounts[center.set] or 0, center.order)
    end
  end
  for centers in configs("centers.json") do
    local base_amounts = copy_table(set_amounts)
    local unordered = {}
    for k, v in pairs(centers) do
      v.pos = v.pos or {x=0,y=0} --Set a default sprite pos since single sprite atli are so common
      if v.order then
        v.order = v.order + base_amounts[v.set]
        set_amounts[v.set] = math.max(v.order, set_amounts[v.set])
        game.P_CENTERS[k] = v
      else 
        unordered[k] = v
      end
    end
    for k,v in pairs(unordered) do
      v.order = set_amounts[v.set]+1
      set_amounts[v.set] = v.order
      game.P_CENTERS[k] = v
    end
  end
end

local function add_prototypes(tab,count,additions,mutations)
  local base = count
  local unordered = {}
  for k, v in pairs(additions) do
    mutations(v)
    if v.order then
      v.order = base + v.order
      count = math.max(count, v.order)
      tab[k] = v
    else
      unordered[k] = v
    end
  end
  for k, v in pairs(unordered) do
    v.order = count + 1
    count = v.order
    tab[k] = v
  end
  return count
end

function _M.addBlinds(game)
  local count = 0
  for _ in pairs(game.P_BLINDS) do
    count = count + 1
  end
  for blinds in configs("blinds.json") do
    count = add_prototypes(game.P_BLINDS,count,blinds,function(v)
      v.pos = v.pos or {x=0,y=0}
      if type(v.boss_colour) == "string" then
        v.boss_colour = HEX(v.boss_colour)
      end
    end)
  end
end

function _M.gen_additional_nodes(from,matrix)
  local additional_nodes = {}
  for i = from, #matrix do
    table.insert(additional_nodes, {n=G.UIT.R, config={align="cm"}, nodes=matrix[i]})
  end
  return additional_nodes
end

function _M.addTags(game)
  local count = 0
  for _ in pairs(game.P_TAGS) do
    count = count + 1
  end
  for tags in configs("tags.json") do
    count = add_prototypes(game.P_TAGS,count,tags,function(v)
      v.pos = v.pos or {x=0,y=0}
      v.set = "Tag"
    end)
  end
end

function _M.addSeals(game)
  local count = 0
  for _ in pairs(game.P_SEALS) do
    count = count + 1
  end
  for seals in configs("seals.json") do
    count = add_prototypes(game.P_SEALS,count,seals,function(v)
      v.set = "Seal"
    end)
  end
end

function _M.addSharedSeals(game)
  for k, v in pairs(game.P_SEALS) do
    if v.order > 4 then
      game.shared_seals[k] = Sprite(0, 0, game.CARD_W, game.CARD_H, game.ASSET_ATLAS[v.atlas or "centers"], v.pos or {x = 0, y = 0})
    end
  end
end

-- Add configured descriptions to the localizations
function _M.addLoc(game)
  for locs in configs("descriptions.json") do
    local loc = locs[game.SETTINGS.language] or locs["en-us"]
    for set, _ in pairs(loc) do
      for key, v in pairs(loc[set]) do
        game.localization.descriptions[set][key] = v
      end
    end
  end
end

-- Add custom asset atli
function _M.addAtli(game)
  for _, type in ipairs({"asset_atli","animation_atli"}) do
    for atli, mod_path in configs(type..".json") do
      for _, atlas in ipairs(atli) do
        atlas.path = fs.newFileData(mod_path.."/textures/"..game.SETTINGS.GRAPHICS.texture_scaling.."x/"..atlas.path)
        table.insert(game[type],atlas)
      end
    end
  end
end

return _M
