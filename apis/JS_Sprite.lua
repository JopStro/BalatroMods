
JS_SPR = {}
JS_SPR.new_atli = {}
local fresh = true
function getLibSprite() 
    return {
        addAtlas = function(name, path, px, py)
            local fullPath = "\"textures/\"..self.SETTINGS.GRAPHICS.texture_scaling..\"x/"..path:gsub("([\\\"])","\\%1").."\""
            local entry = string.format("{name = \"%s\",path = %s,px=%d,py=%d},\n",
                name:gsub("([\\\"])","\\%1"), fullPath, px, py
            )
            local target = "self.asset_atli = {\n"
            inject("game.lua", "Game:set_render_settings", target, target..entry)
            fresh = false
            return entry
        end,
        removeAtlas = function(entry)
            inject("game.lua", "Game:set_render_settings", entry, "")
            fresh = false
        end,
        addToEnhancers = function(path,number_of_rows)
            local first_row = JS_SPR.enhancers_rows
            JS_SPR.enhancers_rows = JS_SPR.enhancers_rows + number_of_rows
            local fullPath = "textures/%dx/"..path:gsub("%%","%%%%")
            table.insert(JS_SPR.new_atli,fullPath)
            -- inject("game.lua","Game:set_render_settings", "--ENHANCERS PATHS BASE", fullPath)
            fresh = false
            return first_row
        end,
    }
end

local targets = {
    "elseif _center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher' then",
    "G.ASSET_ATLAS['Joker'], self.config.center.soul_pos",
}
local replacements = {
    "elseif (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and not _center.atlas then",
    "G.ASSET_ATLAS[_center.atlas or 'Joker'], self.config.center.soul_pos",
}

local enhancers_appending = [[
love.graphics.setLineStyle("rough")
    local enhancers_atli = {}
    local new_atlas_w, new_atlas_h = self.ASSET_ATLAS.centers.image:getDimensions()
    for i, path in ipairs(JS_SPR.new_atli) do
        enhancers_atli[i] = love.graphics.newImage(string.format(path,self.SETTINGS.GRAPHICS.texture_scaling),{dpiscale = self.SETTINGS.GRAPHICS.texture_scaling})
        local w, h = enhancers_atli[i]:getDimensions()
        new_atlas_h = new_atlas_h + h
        new_atlas_w = math.max(new_atlas_w,w)
    end
    table.insert(enhancers_atli,1,self.ASSET_ATLAS.centers.image)
    local centers_canvas = love.graphics.newCanvas(new_atlas_w,new_atlas_h,{mipmaps = "auto",dpiscale=self.SETTINGS.GRAPHICS.texture_scaling})
    centers_canvas:renderTo(function()
        love.graphics.clear(1,1,1,0)
        local draw_h = 0
        for _, atlas in ipairs(enhancers_atli) do
            love.graphics.draw(atlas,0,draw_h)
            draw_h = draw_h + atlas:getHeight()
        end
    end)
    local centers_image_data = centers_canvas:newImageData()
    JS_SPR.new_atli = {}
    JS_SPR.enhancers_rows = new_atlas_h / 95
]]

table.insert(mods,
    {
        mod_id = "libsprite",
        name = "LibSprite",
        author = "JoStro",
        version = "0.3",
        enabled = true,
        on_enable = function()
            JS_SPR.enhancers_rows = G.ASSET_ATLAS.centers.image:getHeight() / 95
            inject("game.lua","Game:set_render_settings","love.graphics.setLineStyle%(\"rough\"%)",enhancers_appending)
            inject("game.lua","Game:set_render_settings",[[%{name = "centers", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/Enhancers.png",px=71,py=95%},]],[[{name = "centers", path = centers_image_data,px=71,py=95},]])
            sendDebugMessage(extractFunctionBody("game.lua","Game:set_render_settings"))
            for i = 1, #targets do
                inject("card.lua", "Card:set_sprites", targets[i]:gsub("([^%w])","%%%1"), replacements[i])
            end
        end,
        on_disable = function()
            for i = 1, #targets do
                inject("card.lua", "Card:set_sprites", replacements[i]:gsub("([^%w])","%%%1"), targets[i])
            end
        end,
        on_post_update = function()
            if not fresh then
                G:set_render_settings()
                fresh = true
            end
        end,
    }
)
