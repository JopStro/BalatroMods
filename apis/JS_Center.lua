-- Yet another center api, simple and raw with code injection to protect against profile switching

function JS_Center()
  -- serializes a table to a string containing it's lua representation
  local function tabToString(t)
    local b = {"{"}
    for k,v in pairs(t) do
      b[#b+1] = k
      b[#b+1] = "="
      if type(v) == "string" then
        b[#b+1] = string.format("%q",v)
      elseif type(v) == "table" then
        b[#b+1] = tabToString(v)
      else
        b[#b+1] = string.format("%s",v)
      end
      b[#b+1] = ","
    end
    b[#b+1] = "}"
    return table.concat(b)
  end
  jsCenter = {}
  
  function jsCenter:inject(key, center)
    center.order = center.order and center.order or #G.P_CENTER_POOLS[center.set] + 1
    local entry = key.."="..tabToString(center)..","
    local target = "self.P_CENTERS = {"
    inject("game.lua","Game:init_item_prototypes", target, target.."\n"..entry)
    -- this could be replaced with G:init_item_prototypes() if it didn't break every other mod.
    center.key = key
    center.alerted = true
    G.P_CENTERS[key] = center
    if center.set == 'Joker' then table.insert(G.P_CENTER_POOLS['Joker'], center) end
    if center.set and center.demo and center.pos then table.insert(G.P_CENTER_POOLS['Demo'], center) end
    if not center.wip then 
        if center.set and center.set ~= 'Joker' and not center.skip_pool and not center.omit then table.insert(G.P_CENTER_POOLS[center.set], center) end
        if center.set == 'Tarot' or center.set == 'Planet' then table.insert(G.P_CENTER_POOLS['Tarot_Planet'], center) end
        if center.consumeable then table.insert(G.P_CENTER_POOLS['Consumeables'], center) end
        if center.rarity and center.set == 'Joker' and not center.demo then table.insert(G.P_JOKER_RARITY_POOLS[center.rarity], center) end
    end
  end

  function jsCenter:addLoc(key, set, loc)
    -- TODO code inject the localization too, even if it stays in english across langs
    loc.name_parsed = {}
    loc.text_parsed = {}
    for _, line in ipairs(type(loc.name) == "table" and loc.name or {loc.name}) do
      loc.name_parsed[#loc.name_parsed+1] = loc_parse_string(line)
    end
    for _, line in ipairs(loc.text) do
      loc.text_parsed[#loc.text_parsed+1] = loc_parse_string(line)
    end
    G.localization.descriptions[set][key] = loc
  end
  
  function jsCenter:addCenter(key, center, loc)
    jsCenter:inject(key,center)
    jsCenter:addLoc(key,center.set,loc)
    sendDebugMessage(string.format("[jsCenter] Added %s: %s",center.set,key))
  end
  
  return jsCenter
end
