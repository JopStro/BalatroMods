jsCenter = JS_Center()
libSprite = getLibSprite()

table.insert(mods,
  {
    mod_id = "js_buffoon_deck",
    name = "Buffon Deck",
    author = "JoStro",
    description = {
      "Deck that gives you a Jumbo",
      "Buffoon Pack at the start of the run",
    },
    enabled = true,
    on_enable = function()
      local row_one = libSprite.addToEnhancers("buffoon_deck.png",1)
      local center = {
        name = "Buffoon Deck",
        stake = 1,
        unlocked = true,
        pos = {x=0,y=row_one},
        set = "Back",
        config = {booster="p_buffoon_jumbo_1"},
        discovered = true,
      }
      local loc = {
        name = "Buffoon Deck",
        text = {
          "Start by opening",
          "a {C:attention}Jumbo Buffoon Pack"
        }
      }
      jsCenter:addCenter("b_js_buffoon",center,loc)
      inject("game.lua","Game:update_blind_select","G.CONTROLLER.lock_input = false",[[
          G.CONTROLLER.lock_input = false
          self.GAME.selected_back:trigger_effect({context = 'blind_select'})
        ]])
      injectTail("back.lua","Back:trigger_effect",[[
  if args.context == 'blind_select' and self.effect.config.booster and not G.GAME.booster_deck_triggered then
    G.GAME.booster_deck_triggered = true
    G.E_MANAGER:add_event(Event({
          func = function()
            local key = self.effect.config.booster
            local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
            G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
            card.cost = 0
            card.from_tag = true
            G.FUNCS.use_card({config = {ref_table = card}})
            card:start_materialize()
            return true
          end
        }))
  end
      ]])
    end,
  }
)
