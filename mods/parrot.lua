checked = false
parrot_target = "if self.ability.set == \"Joker\" and not self.debuff then"
parrot_replacement = [[
if self.ability.set == "Joker" and not self.debuff then
if self.ability.name == "Parrot" then
  local compat_jokers = {}
  for i = 1, #G.jokers.cards do
    if G.jokers.cards[i] ~= self and G.jokers.cards[i].config.center.blueprint_compat then
      compat_jokers[#compat_jokers+1] = G.jokers.cards[i]
    end
  end
  local other_joker = #compat_jokers > 0 and pseudorandom_element(compat_jokers, pseudoseed('parrot')) or nil
  if other_joker then
    context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
    context.blueprint_card = context.blueprint_card or self
    if context.blueprint > #G.jokers.cards + 1 then return end
    local other_joker_ret = other_joker:calculate_joker(context)
    if other_joker_ret then
      other_joker_ret.card = context.blueprint_card or self
      other_joker_ret.colour = G.C.GREEN
      return other_joker_ret
    end
  end
end
]]

jsCenter = JS_Center()
libSprite = getLibSprite()

table.insert(mods,
  {
    mod_id = "parrot_joker",
    name = "Parrot Joker",
    author = "JoStro",
    description = {
      "Adds, the Joker, Parrot to the game",
    },
    enabled = true,
    on_enable = function()
      libSprite.addAtlas("Parrot","parrot_joker_placeholder.png",71,95)
      local j_parrot = {
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        eternal_compat = true,
        rarity = 3,
        cost = 10,
        name = "Parrot",
        pos = {x=0,y=0},
        set = "Joker",
        effect = "Copycat",
        cost_mult = 1.0,
        config = {},
        atlas = "Parrot"
        -- key = "j_parrot",
        -- alerted = true,
      }
      local parrot_loc = {
        name = "Parrot",
        text = {
          "Randomly copies",
          "the abilities",
          "of other {C:attention}Jokers{}",
        },
      }
      jsCenter:addCenter("j_parrot",j_parrot,parrot_loc)
      inject("card.lua", "Card:calculate_joker", parrot_target,  parrot_replacement)
    end,
  }
)
