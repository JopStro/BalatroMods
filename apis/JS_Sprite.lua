
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
    }
end

local targets = {
    "elseif _center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher' then",
    "G.ASSET_ATLAS['Joker'], self.config.center.soul_pos",
    "self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[\"centers\"], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))",
}
local replacements = {
    "elseif (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and not _center.atlas then",
    "G.ASSET_ATLAS[_center.atlas or 'Joker'], self.config.center.soul_pos",
    "self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[self.playing_card and G.GAME[self.back].effect.center.atlas or \"centers\"], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))",
}


local change_viewed_backref
table.insert(mods,
    {
        mod_id = "libsprite",
        name = "LibSprite",
        author = "JoStro",
        version = "0.3",
        enabled = true,
        on_enable = function()
            for i = 1, #targets do
                inject("card.lua", "Card:set_sprites", targets[i]:gsub("([^%w])","%%%1"), replacements[i])
            end

            -- Credit to itayfeder for this great trick
            change_viewed_backref = G.FUNCS.change_viewed_back
            G.FUNCS.change_viewed_back = function(args)
                change_viewed_backref(args)

                for key, val in pairs(G.sticker_card.area.cards) do
                    val.children.back = nil
                    val:set_sprites(val.config.center)
                end
            end
        end,
        on_disable = function()
            for i = 1, #targets do
                inject("card.lua", "Card:set_sprites", replacements[i]:gsub("([^%w])","%%%1"), targets[i])
            end
            G.FUNCS.change_viewed_back = change_viewed_backref
        end,
        on_post_update = function()
            if not fresh then
                G:set_render_settings()
                fresh = true
            end
        end,
    }
)
