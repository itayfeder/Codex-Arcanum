--- STEAMODDED HEADER
--- MOD_NAME: Codex Arcanum
--- MOD_ID: CodexArcanum
--- MOD_AUTHOR: [itayfeder]
--- MOD_DESCRIPTION: Adds a new set of cards: Alchemy!
--- BADGE_COLOUR: C09D75
----------------------------------------------
------------MOD CODE -------------------------

G.C.SECONDARY_SET.Alchemy = HEX("C09D75")
G.P_CENTER_POOLS.Alchemical = {}
G.localization.descriptions.Alchemical = {}
G.localization.misc.dictionary["k_alchemical"] = "Alchemical"
G.localization.misc.dictionary["p_plus_alchemical"] = "+1 Alchemical"
G.localization.misc.dictionary["p_alchemy_plus_card"] = "+2 Cards"
G.localization.misc.dictionary["p_alchemy_plus_money"] = "+2 Dollars"
G.localization.misc.dictionary["p_alchemy_reduce_blind"] = "Reduce Blind"



local create_UIBox_your_collectionref = create_UIBox_your_collection
function create_UIBox_your_collection()
    local retval = create_UIBox_your_collectionref()
    table.insert(retval.nodes[1].nodes[1].nodes[1].nodes[1].nodes[4].nodes[2].nodes, UIBox_button({
        button = 'your_collection_alchemicals', label = { "Alchemical Cards" }, count = G.DISCOVER_TALLIES.alchemicals, minw = 4, id = 'your_collection_alchemicals', colour = G.C.SECONDARY_SET.Alchemy
    }))
    return retval
end

G.FUNCS.your_collection_alchemicals = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_alchemicals(),
  }
end

G.FUNCS.your_collection_alchemical_page = function(args)
  if not args or not args.cycle_config then return end
  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards,1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end
  
  for j = 1, #G.your_collection do
    for i = 1, 3 do
      local center = G.P_CENTER_POOLS["Alchemical"][(j-1) * 3 + i + (6*(args.cycle_config.current_option - 1))]
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  INIT_COLLECTION_CARD_ALERTS()
end

function create_UIBox_your_collection_alchemicals()
    local deck_tables = {}
  
    G.your_collection = {}
    for j = 1, 2 do
      G.your_collection[j] = CardArea(
        G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
        (3.25)*G.CARD_W,
        1*G.CARD_H, 
        {card_limit = 3, type = 'title', highlight_limit = 0, collection = true})
      table.insert(deck_tables, 
      {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
        {n=G.UIT.O, config={object = G.your_collection[j]}}
      }}
      )
    end
  
    local alchemical_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Alchemical/6) do
      table.insert(alchemical_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Alchemical/6)))
    end
  
    for j = 1, #G.your_collection do
      for i = 1, 3 do
        local center = G.P_CENTER_POOLS["Alchemical"][(j-1) * 3 + i]
        if type(center) == "table" then
          local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
          card:start_materialize(nil, i>1 or j>1)
          G.your_collection[j]:emplace(card)
        end
      end
    end
  
    INIT_COLLECTION_CARD_ALERTS()
    
    local t = create_UIBox_generic_options({ back_func = 'your_collection', contents = {
              {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                      create_option_cycle({options = alchemical_options, w = 3.5, cycle_shoulders = true, opt_callback = 'your_collection_alchemical_page', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
                    }}
            }})
    return t
end

local set_discover_talliesref = set_discover_tallies
function set_discover_tallies()
  set_discover_talliesref()

  G.DISCOVER_TALLIES.alchemicals = {tally = 0, of = 0}

  for _, v in pairs(G.P_CENTERS) do
    if not v.omit then 
      if v.set and v.consumeable and v.set == 'Alchemical' then
        G.DISCOVER_TALLIES.alchemicals.of = G.DISCOVER_TALLIES.alchemicals.of+1
          if v.discovered then 
              G.DISCOVER_TALLIES.alchemicals.tally = G.DISCOVER_TALLIES.alchemicals.tally+1
          end
      end
    end
  end
end

function create_alchemical() 
  local card = create_card("Alchemical", G.pack_cards, nil, nil, true, true, nil, 'alc')
  if G.GAME.used_vouchers.v_cauldron and pseudorandom('cauldron') > 0.5 then
    card:set_edition({negative = true}, true)
  end
  return card
end

local get_type_colourref = get_type_colour
function get_type_colour(_c, card)
  local fromRef = get_type_colourref(_c, card)

  if _c.set == "Alchemical" then
    return G.C.SECONDARY_SET.Alchemy
  end

  return fromRef
end

local generate_card_uiref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
  if _c.set == "Alchemical" or (_c.set == 'Booster' and _c.name:find("Alchemy")) or _c.name == 'Shock Humor' then
    local first_pass = nil
    if not full_UI_table then 
        first_pass = true
        full_UI_table = {
            main = {},
            info = {},
            type = {},
            name = nil,
            badges = badges or {}
        }
    end

    local desc_nodes = (not full_UI_table.name and full_UI_table.main) or full_UI_table.info
    local name_override = nil
    local info_queue = {}

    if full_UI_table.name then
        full_UI_table.info[#full_UI_table.info+1] = {}
        desc_nodes = full_UI_table.info[#full_UI_table.info]
    end

    if not full_UI_table.name then
        if specific_vars and specific_vars.no_name then
            full_UI_table.name = true
        elseif card_type == 'Locked' then
            full_UI_table.name = localize{type = 'name', set = 'Other', key = 'locked', nodes = {}}
        elseif card_type == 'Undiscovered' then 
            full_UI_table.name = localize{type = 'name', set = 'Other', key = 'undiscovered_'..(string.lower(_c.set)), name_nodes = {}}
        elseif specific_vars and (card_type == 'Default' or card_type == 'Enhanced') then
            if (_c.name == 'Stone Card') then full_UI_table.name = true end
            if (specific_vars.playing_card and (_c.name ~= 'Stone Card')) then
                full_UI_table.name = {}
                localize{type = 'other', key = 'playing_card', set = 'Other', nodes = full_UI_table.name, vars = {localize(specific_vars.value, 'ranks'), localize(specific_vars.suit, 'suits_plural'), colours = {specific_vars.colour}}}
                full_UI_table.name = full_UI_table.name[1]
            end
        elseif card_type == 'Booster' then
            
        else
            full_UI_table.name = localize{type = 'name', set = _c.set, key = _c.key, nodes = full_UI_table.name}
        end
        full_UI_table.card_type = card_type or _c.set
    end 

    local loc_vars = {}
    if main_start then 
        desc_nodes[#desc_nodes+1] = main_start 
    end


    if _c.set == "Alchemical" then
      if _c.name == 'Bismuth' then info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
      elseif _c.name == 'Cobalt' then loc_vars = {localize(G.GAME.last_played_hand, 'poker_hands') or localize('High Card', 'poker_hands')} 
      elseif _c.name == 'Antimony' then 
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative 
        info_queue[#info_queue+1] = {key = 'eternal', set = 'Other'} 
      end
      localize{type = 'descriptions', key = _c.key, set = _c.set, nodes = desc_nodes, vars = loc_vars}
    elseif _c.set == 'Booster' and _c.name:find("Alchemy") then 
      local desc_override = 'p_arcana_normal'
      if _c.name == 'Alchemy Pack' then desc_override = 'p_alchemy_normal'; loc_vars = {_c.config.choose, _c.config.extra} end
      if _c.name == 'Jumbo Alchemy Pack' then desc_override = 'p_alchemy_jumbo'; loc_vars = {_c.config.choose, _c.config.extra} end
      if _c.name == 'Mega Alchemy Pack' then desc_override = 'p_alchemy_mega'; loc_vars = {_c.config.choose, _c.config.extra} end
      name_override = desc_override
      if not full_UI_table.name then full_UI_table.name = localize{type = 'name', set = 'Other', key = name_override, nodes = full_UI_table.name} end
      localize{type = 'other', key = desc_override, nodes = desc_nodes, vars = loc_vars}
    elseif _c.set == 'Joker' then
      if _c.name == 'Shock Humor' then 
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
      end
      localize{type = 'descriptions', key = _c.key, set = _c.set, nodes = desc_nodes, vars = specific_vars or {}}
    end

    if main_end then 
        desc_nodes[#desc_nodes+1] = main_end 
    end

   --Fill all remaining info if this is the main desc
    if not ((specific_vars and not specific_vars.sticker) and (card_type == 'Default' or card_type == 'Enhanced')) then
        if desc_nodes == full_UI_table.main and not full_UI_table.name then
            localize{type = 'name', key = _c.key, set = _c.set, nodes = full_UI_table.name} 
            if not full_UI_table.name then full_UI_table.name = {} end
        elseif desc_nodes ~= full_UI_table.main then 
            desc_nodes.name = localize{type = 'name_text', key = name_override or _c.key, set = name_override and 'Other' or _c.set} 
        end
    end

    if first_pass and not (_c.set == 'Edition') and badges then
        for k, v in ipairs(badges) do
            if v == 'foil' then info_queue[#info_queue+1] = G.P_CENTERS['e_foil'] end
            if v == 'holographic' then info_queue[#info_queue+1] = G.P_CENTERS['e_holo'] end
            if v == 'polychrome' then info_queue[#info_queue+1] = G.P_CENTERS['e_polychrome'] end
            if v == 'negative' then info_queue[#info_queue+1] = G.P_CENTERS['e_negative'] end
            if v == 'negative_consumable' then info_queue[#info_queue+1] = {key = 'e_negative_consumable', set = 'Edition', config = {extra = 1}} end
            if v == 'gold_seal' then info_queue[#info_queue+1] = {key = 'gold_seal', set = 'Other'} end
            if v == 'blue_seal' then info_queue[#info_queue+1] = {key = 'blue_seal', set = 'Other'} end
            if v == 'red_seal' then info_queue[#info_queue+1] = {key = 'red_seal', set = 'Other'} end
            if v == 'purple_seal' then info_queue[#info_queue+1] = {key = 'purple_seal', set = 'Other'} end
            if v == 'eternal' then info_queue[#info_queue+1] = {key = 'eternal', set = 'Other'} end
            if v == 'pinned_left' then info_queue[#info_queue+1] = {key = 'pinned_left', set = 'Other'} end
        end
    end

    for _, v in ipairs(info_queue) do
        generate_card_ui(v, full_UI_table)
    end

    return full_UI_table
  end
  return generate_card_uiref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
end

local generate_UIBox_ability_tableref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table()
  local card_type, hide_desc = self.ability.set or "None", nil
  local loc_vars = nil
  local main_start, main_end = nil, nil
  local no_badge = nil
  local is_custom = false

  if not self.bypass_lock and self.config.center.unlocked ~= false and
  (self.ability.set == 'Joker' or self.ability.set == 'Edition' or self.ability.consumeable or self.ability.set == 'Voucher' or self.ability.set == 'Booster') and
  not self.config.center.discovered and 
  ((self.area ~= G.jokers and self.area ~= G.consumeables and self.area) or not self.area) then
      card_type = 'Undiscovered'
  end    
  if self.config.center.unlocked == false and not self.bypass_lock then --For everyting that is locked
      card_type = "Locked"
      if self.area and self.area == G.shop_demo then loc_vars = {}; no_badge = true end
  elseif card_type == 'Undiscovered' and not self.bypass_discovery_ui then -- Any Joker or tarot/planet/voucher that is not yet discovered
      hide_desc = true
  elseif self.debuff then
      loc_vars = { debuffed = true, playing_card = not not self.base.colour, value = self.base.value, suit = self.base.suit, colour = self.base.colour }
  elseif card_type == 'Default' or card_type == 'Enhanced' then
      loc_vars = { playing_card = not not self.base.colour, value = self.base.value, suit = self.base.suit, colour = self.base.colour,
                  nominal_chips = self.base.nominal > 0 and self.base.nominal or nil,
                  bonus_chips = (self.ability.bonus + (self.ability.perma_bonus or 0)) > 0 and (self.ability.bonus + (self.ability.perma_bonus or 0)) or nil,
              }
  elseif self.ability.set == 'Joker' then
    if self.ability.name == 'Essence of Comedy' then is_custom = true; loc_vars = {self.ability.extra, self.ability.x_mult}
    elseif self.ability.name == 'Bottled Buffoon' then is_custom = true; loc_vars = {self.ability.extra.every + 1, localize{type = 'variable', key = (self.ability.loyalty_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = {self.ability.loyalty_remaining}}}
    elseif self.ability.name == 'Shock Humor' then is_custom = true; loc_vars = {''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds}
    elseif self.ability.name == 'Catalyst Joker' then is_custom = true; loc_vars = {self.ability.extra.bonus, 1 + self.ability.extra.bonus*(self.ability.consumeable_tally or 0)} end
  elseif self.ability.set == 'Alchemical' then
    if self.ability.name == 'Cobalt' then 
      sendDebugMessage("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
      sendDebugMessage(localize(G.GAME.last_played_hand, 'poker_hands'))
      is_custom = true; 
      loc_vars = {localize(G.GAME.last_played_hand, 'poker_hands') or localize('High Card', 'poker_hands')} 
    end
  end

  if is_custom then
    local badges = {}
    if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or self.debuff then
        badges.card_type = card_type
    end
    if self.ability.set == 'Joker' and self.bypass_discovery_ui and (not no_badge) then
        badges.force_rarity = true
    end
    if self.edition then
        if self.edition.type == 'negative' and self.ability.consumeable then
            badges[#badges + 1] = 'negative_consumable'
        else
            badges[#badges + 1] = (self.edition.type == 'holo' and 'holographic' or self.edition.type)
        end
    end
    if self.seal then badges[#badges + 1] = string.lower(self.seal)..'_seal' end
    if self.ability.eternal then badges[#badges + 1] = 'eternal' end
    if self.pinned then badges[#badges + 1] = 'pinned_left' end

    if self.sticker then loc_vars = loc_vars or {}; loc_vars.sticker=self.sticker end

    return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)
  end
  
  return generate_UIBox_ability_tableref(self)
end

local set_spritesref = Card.set_sprites
function Card:set_sprites(_center, _front)
    if _center and _center.set == "Alchemical" then
      if _center.set then
        if self.children.center then
          self.children.center.atlas = G.ASSET_ATLAS[_center.atlas]
          self.children.center:set_sprite_pos(_center.pos)
        else
          if not self.params.bypass_discovery_center and not _center.discovered then 
            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["c_alchemy_undiscovered"], {x=0,y=0})
          else
            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[_center.atlas], _center.pos)
          end
            self.children.center.states.hover = self.states.hover
            self.children.center.states.click = self.states.click
            self.children.center.states.drag = self.states.drag
            self.children.center.states.collide.can = false
            self.children.center:set_role({major = self, role_type = 'Glued', draw_major = self})
        end
      end

      if not self.children.back then
          self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["centers"], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))
          self.children.back.states.hover = self.states.hover
          self.children.back.states.click = self.states.click
          self.children.back.states.drag = self.states.drag
          self.children.back.states.collide.can = false
          self.children.back:set_role({major = self, role_type = 'Glued', draw_major = self})
      end
    else
      set_spritesref(self, _center, _front);
    end
    
end

local use_consumeableref = Card.use_consumeable
function Card:use_consumeable(area, copier)

  local used_alchemical = copier or self

  use_consumeableref(self, area, copier)
  if self.config.in_booster then
    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
      G.E_MANAGER:add_event(Event({
        func = (function()
          G.E_MANAGER:add_event(Event({
            func = function() 
              local card = copy_card(used_alchemical, nil, nil, nil)
              card:add_to_deck()
              G.consumeables:emplace(card)
              G.GAME.consumeable_buffer = 0
              return true end }))   
      return true end)}))
    end
  else
    if self.ability.name == 'Aqua' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        ease_hands_played(self.ability.extra)
        return true end }))
    end
    if self.ability.name == 'Ignis' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        ease_discard(self.ability.extra)
        return true end }))
    end
    if self.ability.name == 'Aero' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        G.FUNCS.draw_from_deck_to_hand(self.ability.extra)
        return true end }))
    end
    if self.ability.name == 'Terra' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.9)
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        
        local chips_UI = G.hand_text_area.blind_chips
        G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
        G.HUD_blind:recalculate() 
        chips_UI:juice_up()

        if not silent then play_sound('chips2') end
        return true end }))
    end
    if self.ability.name == 'Quicksilver' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        G.hand:change_size(self.ability.extra)
        if not G.deck.config.quicksilver then G.deck.config.quicksilver = 0 end
        G.deck.config.quicksilver = G.deck.config.quicksilver + self.ability.extra
        return true end }))
    end
    if self.ability.name == 'Salt' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        if G.FORCE_TAG then return G.FORCE_TAG end
        local i = 1
        while i <= 2 do
          local _pool, _pool_key = get_current_pool('Tag', nil, nil, nil)
          local _tag_name = pseudorandom_element(_pool, pseudoseed(_pool_key))
          local it = 1
          while _tag_name == 'UNAVAILABLE' or _tag_name == "tag_double" or _tag_name == "tag_orbital" do
              it = it + 1
              _tag_name = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
          end

          G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
          local _tag = Tag(_tag_name, nil, G.GAME.blind)
          add_tag(_tag)
          i = i + 1
        end
        return true end }))
    end
    if self.ability.name == 'Sulfur' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        ease_dollars(10, true)
        return true end }))
    end
    if self.ability.name == 'Phosphorus' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        take_cards_from_discard(self.ability.extra)
        return true end }))
    end
    if self.ability.name == 'Bismuth' then
      G.deck.config.bismuth = G.deck.config.bismuth or {}
      for k, card in ipairs(G.hand.highlighted) do
        card:set_edition({polychrome = true}, true)
        table.insert(G.deck.config.bismuth, card.unique_val)
      end
    end
    if self.ability.name == 'Cobalt' then
      if G.GAME.last_played_hand then
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(G.GAME.last_played_hand, 'poker_hands'),chips = G.GAME.hands[G.GAME.last_played_hand].chips, mult = G.GAME.hands[G.GAME.last_played_hand].mult, level=G.GAME.hands[G.GAME.last_played_hand].level})
        level_up_hand(self, G.GAME.last_played_hand)
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
      end
    end
    if self.ability.name == 'Arsenic' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        local temp_hands = G.GAME.current_round.hands_left
        local temp_discards = G.GAME.current_round.discards_left
        G.GAME.current_round.hands_left = 0
        G.GAME.current_round.discards_left = 0
        ease_hands_played(temp_discards)
        ease_discard(temp_hands)
        return true end }))
    end
    if self.ability.name == 'Antimony' then
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        G.jokers.config.antimony = G.jokers.config.antimony or {}
        if #G.jokers.cards > 0 then 
          local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('invisible'))
          local card = copy_card(chosen_joker, nil, nil, nil, chosen_joker.edition and chosen_joker.edition.negative)
          card:set_edition({negative = true}, true)
          card:set_eternal(true)
          if card.ability.invis_rounds then card.ability.invis_rounds = 0 end
          card:add_to_deck()
          G.jokers:emplace(card)
          table.insert(G.jokers.config.antimony, card.unique_val)
        end
        return true end }))
    end
  end
end

local can_use_consumeableref = Card.can_use_consumeable
function Card:can_use_consumeable(any_state, skip_check)
  if not skip_check and ((G.play and #G.play.cards > 0) or
    (G.CONTROLLER.locked) or
    (G.GAME.STOP_USE and G.GAME.STOP_USE > 0))
    then  return false end

  if G.STATE == G.STATES.SELECTING_HAND then
    if self.ability.name == 'Aqua' or self.ability.name == 'Ignis' or self.ability.name == 'Aero'
     or self.ability.name == 'Terra' or self.ability.name == 'Quicksilver' or self.ability.name == 'Salt'
     or self.ability.name == 'Sulfur' or self.ability.name == 'Phosphorus' or self.ability.name == 'Bismuth'
     or self.ability.name == 'Cobalt' or self.ability.name == 'Arsenic' or self.ability.name == 'Antimony' then
      if self.ability.name == 'Bismuth' then
        if #G.hand.highlighted <= self.ability.extra and #G.hand.highlighted >= 1 then
          self.config.in_booster = false
          return true
        end
        self.config.in_booster = false
        return false
      end
      self.config.in_booster = false
      return true
    end
  end

  if G.STATE == G.STATES.STANDARD_PACK then
    if self.ability.name == 'Aqua' or self.ability.name == 'Ignis' or self.ability.name == 'Aero'
     or self.ability.name == 'Terra' or self.ability.name == 'Quicksilver' or self.ability.name == 'Salt'
     or self.ability.name == 'Sulfur' or self.ability.name == 'Phosphorus' or self.ability.name == 'Bismuth'
     or self.ability.name == 'Cobalt' or self.ability.name == 'Arsenic' or self.ability.name == 'Antimony' then
      self.config.in_booster = true
      return true
    end
  end

  return can_use_consumeableref(self, any_state, skip_check)
end

local update_round_evalref = Game.update_round_eval
function Game:update_round_eval(dt)
  if G.deck.config.quicksilver then
    G.hand:change_size(-G.deck.config.quicksilver)
    G.deck.config.quicksilver = nil
  end

  for i = 1, #G.jokers.cards do
    if G.jokers.cards[i].ability.name == "Chain Reaction" then
      G.jokers.cards[i].ability.extra.used = false
    end
  end

  update_round_evalref(self, dt)
  
  if G.deck.config.bismuth then
    for _, poly_id in ipairs(G.deck.config.bismuth) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == poly_id and card.edition and card.edition.polychrome then
          card:set_edition(nil, true)
        end
      end
    end
    G.deck.config.bismuth = {}
  end

  if G.jokers.config.antimony then
    for _, poly_id in ipairs(G.jokers.config.antimony) do
      for k, joker in ipairs(G.jokers.cards) do
        if joker.unique_val == poly_id then
          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
          func = function()
            G.jokers:remove_card(joker)
            joker:remove()
            joker = nil
          return true; end})) 
        end
      end
    end
    G.jokers.config.antimony = {}
  end

end

local card_openref = Card.open
function Card:open()
  G.ARGS.is_alchemical_booster = false
  if self.ability.set == "Booster" and self.ability.name:find('Alchemy') then
      stop_use()
      G.STATE_COMPLETE = false 
      self.opening = true

      if not self.config.center.discovered then
          discover_card(self.config.center)
      end
      self.states.hover.can = false

      G.ARGS.is_alchemical_booster = true
      G.STATE = G.STATES.STANDARD_PACK
      G.GAME.pack_size = self.ability.extra

      G.GAME.pack_choices = self.config.center.config.choose or 1

      if self.cost > 0 then 
          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
              inc_career_stat('c_shop_dollars_spent', self.cost)
              self:juice_up()
          return true end }))
          ease_dollars(-self.cost) 
     else
         delay(0.2)
     end

      G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
          self:explode()
          local pack_cards = {}

          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1.3*math.sqrt(G.SETTINGS.GAMESPEED), blockable = false, blocking = false, func = function()
              local _size = self.ability.extra
              
              for i = 1, _size do
                  local card = nil
                  card = create_alchemical()
                  card.T.x = self.T.x
                  card.T.y = self.T.y
                  card:start_materialize({G.C.WHITE, G.C.WHITE}, nil, 1.5*G.SETTINGS.GAMESPEED)
                  pack_cards[i] = card
              end
              return true
          end}))

          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1.3*math.sqrt(G.SETTINGS.GAMESPEED), blockable = false, blocking = false, func = function()
              if G.pack_cards then 
                  if G.pack_cards and G.pack_cards.VT.y < G.ROOM.T.h then 
                  for k, v in ipairs(pack_cards) do
                      G.pack_cards:emplace(v)
                  end
                  return true
                  end
              end
          end}))

          for i = 1, #G.jokers.cards do
              G.jokers.cards[i]:calculate_joker({open_booster = true, card = self})
          end

          if G.GAME.modifiers.inflation then 
              G.GAME.inflation = G.GAME.inflation + 1
              G.E_MANAGER:add_event(Event({func = function()
                for k, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
                return true end }))
          end

      return true end }))
  else
    card_openref(self)
  end
end

local create_UIBox_standard_packref = create_UIBox_standard_pack
function create_UIBox_standard_pack()
  if G.ARGS.is_alchemical_booster then
    local _size = G.GAME.pack_size
    G.pack_cards = CardArea(
      G.ROOM.T.x + 9 + G.hand.T.x, G.hand.T.y,
      _size*G.CARD_W*1.1,
      1.05*G.CARD_H, 
      {card_limit = _size, type = 'consumeable', highlight_limit = 1})

      local t = {n=G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes={
        {n=G.UIT.R, config={align = "cl", colour = G.C.CLEAR,r=0.15, padding = 0.1, minh = 2, shadow = true}, nodes={
          {n=G.UIT.R, config={align = "cm"}, nodes={
          {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
            {n=G.UIT.C, config={align = "cm", r=0.2, colour = G.C.CLEAR, shadow = true}, nodes={
              {n=G.UIT.O, config={object = G.pack_cards}},
            }}
          }}
        }},
        {n=G.UIT.R, config={align = "cm"}, nodes={
        }},
        {n=G.UIT.R, config={align = "tm"}, nodes={
          {n=G.UIT.C,config={align = "tm", padding = 0.05, minw = 2.4}, nodes={}},
          {n=G.UIT.C,config={align = "tm", padding = 0.05}, nodes={
          UIBox_dyn_container({
            {n=G.UIT.C, config={align = "cm", padding = 0.05, minw = 4}, nodes={
              {n=G.UIT.R,config={align = "bm", padding = 0.05}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = localize('k_alchemy_pack'), colours = {G.C.WHITE},shadow = true, rotate = true, bump = true, spacing =2, scale = 0.7, maxw = 4, pop_in = 0.5})}}
              }},
              {n=G.UIT.R,config={align = "bm", padding = 0.05}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = {localize('k_choose')..' '}, colours = {G.C.WHITE},shadow = true, rotate = true, bump = true, spacing =2, scale = 0.5, pop_in = 0.7})}},
                {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.GAME, ref_value = 'pack_choices'}}, colours = {G.C.WHITE},shadow = true, rotate = true, bump = true, spacing =2, scale = 0.5, pop_in = 0.7})}}
              }},
            }}
          }),
        }},
          {n=G.UIT.C,config={align = "tm", padding = 0.05, minw = 2.4}, nodes={
            {n=G.UIT.R,config={minh =0.2}, nodes={}},
            {n=G.UIT.R,config={align = "tm",padding = 0.2, minh = 1.2, minw = 1.8, r=0.15,colour = G.C.GREY, one_press = true, button = 'skip_booster', hover = true,shadow = true, func = 'can_skip_booster'}, nodes = {
              {n=G.UIT.T, config={text = localize('b_skip'), scale = 0.5, colour = G.C.WHITE, shadow = true, focus_args = {button = 'y', orientation = 'bm'}, func = 'set_button_pip'}}
            }}
          }}
        }}
      }}
    }}
    return t
  else
    return create_UIBox_standard_packref()
  end
end

local func_use_cardref = G.FUNCS.use_card
G.FUNCS.use_card = function(e, mute, nosave)
  func_use_cardref(e, mute, nosave)
  local card = e.config.ref_table
  local area = card.area
  local prev_state = G.STATE
  local dont_dissolve = nil
  local delay_fac = 1

  if card:check_use() then 
    G.E_MANAGER:add_event(Event({func = function()
      e.disable_button = nil
      e.config.button = 'use_card'
    return true end }))
    return
  end

  if card.ability.set == 'Booster' and not nosave and G.STATE == G.STATES.SHOP then
    save_with_action({
      type = 'use_card',
      card = card.sort_id,
    })
  end
end

function take_cards_from_discard(count)
  G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = function()
          for i=1, count do --draw cards from deck
              draw_card(G.discard, G.deck, i*100/count,'up', nil ,nil, 0.005, i%2==0, nil, math.max((21-i)/20,0.7))
          end
          return true
      end
    }))
end

function add_random_alchemical(selff)
  if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = (function()
                local card = create_alchemical()
                card:add_to_deck()
                G.consumeables:emplace(card)
                G.GAME.consumeable_buffer = 0
            return true
        end)}))
  end
end

local calculate_jokerref = Card.calculate_joker;
function Card:calculate_joker(context)

  local val = calculate_jokerref(self, context)

  if context.scoring_name then
    G.GAME.last_played_hand = context.scoring_name
  end

  
  if self.ability.set == "Joker" and not self.debuff then
    if context.using_consumeable and not context.consumeable.config.in_booster then
      if self.ability.name == 'Essence of Comedy' and context.consumeable.ability.set == 'Alchemical' then
        self.ability.x_mult = self.ability.x_mult + self.ability.extra
        G.E_MANAGER:add_event(Event({
            func = function() card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={self.ability.x_mult}}}); return true
            end}))
        return
      elseif self.ability.name == 'Breaking Bozo' and context.consumeable.ability.set == 'Alchemical' then
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
          local choice = math.random(1,3)
          if choice == 1 then
            G.FUNCS.draw_from_deck_to_hand(2)
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('p_alchemy_plus_card'), colour = G.C.SECONDARY_SET.Alchemy})
          elseif choice == 2 then
            ease_dollars(5, true)
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('p_alchemy_plus_money'), colour = G.C.SECONDARY_SET.Alchemy})
          else 
            G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.95)
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            
            local chips_UI = G.hand_text_area.blind_chips
            G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
            G.HUD_blind:recalculate() 
            chips_UI:juice_up()
    
            if not silent then play_sound('chips2') end
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('p_alchemy_reduce_blind'), colour = G.C.SECONDARY_SET.Alchemy})
          end
        return true end }))
      elseif self.ability.name == 'Chain Reaction' and context.consumeable.ability.set == 'Alchemical' then
        if not self.ability.extra.used then
          G.E_MANAGER:add_event(Event({
            func = function() context.consumeable:use_consumeable(context.consumeable.area); return true
            end}))
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = "Re-Triggered", colour = G.C.SECONDARY_SET.Alchemy})
            self.ability.extra.used = true
          return
        end
      end
    elseif context.selling_self then
      if self.ability.name == 'Studious Joker' and not context.blueprint then
        add_random_alchemical(self)
        card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('p_plus_alchemical'), colour = G.C.SECONDARY_SET.Alchemy})
        return {
            card = self
        }
      end
    elseif context.discard then
      if self.ability.name == 'Shock Humor' and not context.other_card.debuff then
        if context.other_card.config.center == G.P_CENTERS.m_steel or context.other_card.config.center == G.P_CENTERS.m_gold or
        context.other_card.config.center == G.P_CENTERS.m_stone then
          if pseudorandom('shock_humor') < G.GAME.probabilities.normal/self.ability.extra.odds then
            add_random_alchemical(self)
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('p_plus_alchemical'), colour = G.C.SECONDARY_SET.Alchemy})
          end
        end
      end
    end
    if context.cardarea == G.jokers then
      if context.before then

      elseif context.after then        
        if self.ability.name == 'Bottled Buffoon' then
          self.ability.loyalty_remaining = (self.ability.extra.every-1-(G.GAME.hands_played - self.ability.hands_played_at_create))%(self.ability.extra.every+1)
          if context.blueprint then
            if self.ability.loyalty_remaining == self.ability.extra.every then
                add_random_alchemical(self)
                self.ability.loyalty_remaining = self.ability.extra.every
                return {
                  message = localize('p_plus_alchemical')
                }
            end
          else
            if self.ability.loyalty_remaining == 0 then
              local eval = function(card) return (card.ability.loyalty_remaining == 0) end
              juice_card_until(self, eval, true)
            elseif self.ability.loyalty_remaining == self.ability.extra.every then
              add_random_alchemical(self)
              self.ability.loyalty_remaining = self.ability.extra.every
              return {
                message = localize('p_plus_alchemical')
              }
            end
          end
        end
      else
        if self.ability.name == 'Studious Joker' then
          return {
            message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
            mult_mod = self.ability.mult
          }
        elseif self.ability.name == 'Catalyst Joker' then
          return {
            message = localize{type='variable',key='a_xmult',vars={1 + self.ability.extra.bonus * self.ability.consumeable_tally}},
            Xmult_mod = 1 + self.ability.extra.bonus * self.ability.consumeable_tally, 
            colour = G.C.MULT
          }
        end
      end
    end
  end
  return val
end

local set_abilityref = Card.set_ability;
function Card:set_ability(center, initial, delay_sprites)
  set_abilityref(self, center, initial, delay_sprites)
  if self.ability.name == 'Bottled Buffoon' then 
    self.ability.burnt_hand = 0
    self.ability.loyalty_remaining = self.ability.extra.every
  end
end

local apply_to_runref = Card.apply_to_run
function Card:apply_to_run(center)
  apply_to_runref(self, center)

  local center_table = {
    name = center and center.name or self and self.ability.name,
    extra = center and center.config.extra or self and self.ability.extra
  }

  if center_table.name == 'Mortar and Pestle' then
    G.E_MANAGER:add_event(Event({func = function()
      G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
      return true end }))
  end
end

local add_to_deckref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
  if not self.added_to_deck then
    if self.ability.name == 'Catalyst Joker' then
      G.consumeables:change_size(self.ability.extra.slots)
    end
  end
  add_to_deckref(self, from_debuff)
end

local remove_from_deckref = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
  if self.added_to_deck then
    if self.ability.name == 'Catalyst Joker' then
      G.consumeables:change_size(-self.ability.extra.slots)
    end
  end
  remove_from_deckref(self, from_debuff)
end

local updateref = Card.update
function Card:update(dt)
  updateref(self, dt)

  if G.STAGE == G.STAGES.RUN then
    if self.ability.name == "Catalyst Joker" then 
      self.ability.consumeable_tally = #G.consumeables.cards
    end
  end

  if not G.GAME.last_played_hand then
    G.GAME.last_played_hand = "High Card"
  end
end



CodexArcanum = {}
CodexArcanum.Alchemicals = {}
CodexArcanum.Alchemical = {
  name = "",
  slug = "",
	cost = 3,
	config = {},
  pos = {},
	loc_txt = {},
	discovered = false, 
	consumeable = true
}

function CodexArcanum.Alchemical:new(name, slug, config, pos, loc_txt, cost, discovered)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.loc_txt = loc_txt
  o.name = name
  o.slug = "c_alchemy_" .. slug
  o.config = config or {}
  o.pos = pos or {
      x = 0,
      y = 0
  }
  o.cost = cost
  o.discovered = discovered or false
  o.consumeable = true
  return o
end

function CodexArcanum.Alchemical:register()
  CodexArcanum.Alchemicals[self.slug] = self
  local minId = table_length(G.P_CENTER_POOLS['Alchemical']) + 1
  local id = 0
  local i = 0
	i = i + 1

  id = i + minId

	local alchemical_obj = {
		discovered = self.discovered,
		consumeable = true,
		name = self.name,
		set = "Alchemical",
		order = id,
		key = self.slug,
		pos = self.pos,
    cost = self.cost,
		config = self.config
	}

	for _i, sprite in ipairs(SMODS.Sprites) do
		sendDebugMessage(sprite.name)
		sendDebugMessage(alchemical_obj.key)
		if sprite.name == alchemical_obj.key then
			alchemical_obj.atlas = sprite.name
		end
	end

  G.P_CENTERS[self.slug] = alchemical_obj
	table.insert(G.P_CENTER_POOLS['Alchemical'], alchemical_obj)

  G.localization.descriptions["Alchemical"][self.slug] = self.loc_txt

  for g_k, group in pairs(G.localization) do
		if g_k == 'descriptions' then
			for _, set in pairs(group) do
				for _, center in pairs(set) do
					center.text_parsed = {}
					for _, line in ipairs(center.text) do
						center.text_parsed[#center.text_parsed + 1] = loc_parse_string(line)
					end
					center.name_parsed = {}
					for _, line in ipairs(type(center.name) == 'table' and center.name or {center.name}) do
						center.name_parsed[#center.name_parsed + 1] = loc_parse_string(line)
					end
					if center.unlock then
						center.unlock_parsed = {}
						for _, line in ipairs(center.unlock) do
							center.unlock_parsed[#center.unlock_parsed + 1] = loc_parse_string(line)
						end
					end
				end
			end
		end
	end

	sendDebugMessage("The Alchemical named " .. self.name .. " with the slug " .. self.slug ..
						 " have been registered at the id " .. id .. ".")
end





-- BOOSTER API

SMODS.Boosters = {}
SMODS.Booster = {
  	name = "",
  	slug = "",
	cost = 4,
	config = {},
  	pos = {},
	discovered = false,
    weight = 1, 
    kind = 'Standard',
    atlas = 'Booster'
}

function SMODS.Booster:new(name, slug, config, pos, cost, discovered, weight, kind, atlas)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.name = name
    o.slug = "p_" .. slug
    o.config = config or {}
    o.pos = pos or {
        x = 0,
        y = 0
    }
    o.cost = cost
    o.discovered = discovered or false
    o.weight = weight or 1
	o.kind = kind or 'Standard'
	o.atlas = atlas or 'Booster'
	return o
end

function SMODS.Booster:register()
	SMODS.Boosters[self.slug] = self

	local minId = table_length(G.P_CENTER_POOLS['Booster']) + 1
    local id = 0
    local i = 0
	i = i + 1
	-- Prepare some Datas
	id = i + minId

	local booster_obj = {
		discovered = self.discovered,
		name = self.name,
		set = "Booster",
		order = id,
		key = self.slug,
		pos = self.pos,
        cost = self.cost,
		config = self.config,
		weight = self.weight,
		kind = self.kind,
		atlas = self.atlas
	}

	for _i, sprite in ipairs(SMODS.Sprites) do
		sendDebugMessage(sprite.name)
		sendDebugMessage(booster_obj.key)
		if sprite.name == booster_obj.key then
			booster_obj.atlas = sprite.name
		end
	end

	-- Now we replace the others
	G.P_CENTERS[self.slug] = booster_obj
	table.insert(G.P_CENTER_POOLS['Booster'], booster_obj)

	-- Load it
	for g_k, group in pairs(G.localization) do
		if g_k == 'descriptions' then
			for _, set in pairs(group) do
				for _, center in pairs(set) do
					center.text_parsed = {}
					for _, line in ipairs(center.text) do
						center.text_parsed[#center.text_parsed + 1] = loc_parse_string(line)
					end
					center.name_parsed = {}
					for _, line in ipairs(type(center.name) == 'table' and center.name or {center.name}) do
						center.name_parsed[#center.name_parsed + 1] = loc_parse_string(line)
					end
					if center.unlock then
						center.unlock_parsed = {}
						for _, line in ipairs(center.unlock) do
							center.unlock_parsed[#center.unlock_parsed + 1] = loc_parse_string(line)
						end
					end
				end
			end
		end
	end

	sendDebugMessage("The Booster named " .. self.name .. " with the slug " .. self.slug ..
						 " have been registered at the id " .. id .. ".")
end

-- BOOSTER API





function SMODS.INIT.CodexArcanum()
	local mod_id = "CodexArcanum"
  local rota_mod = SMODS.findModByID(mod_id)
	
  SMODS.Sprite:new("c_alchemy_undiscovered", rota_mod.path, "c_alchemy_undiscovered.png", 71, 95, "asset_atli"):register();


	local alchemy_ignis_def = {
      name = "Ignis",
      text = {
          "Gain {C:attention}+1{} discard"
      }
  }

  local alchemy_ignis = CodexArcanum.Alchemical:new("Ignis", "ignis", {extra = 1}, { x = 0, y = 0 }, alchemy_ignis_def, 3)
  SMODS.Sprite:new("c_alchemy_ignis", rota_mod.path, "c_alchemy_ignis.png", 71, 95, "asset_atli"):register();
  alchemy_ignis:register()
	
	local alchemy_aqua_def = {
      name = "Aqua",
      text = {
          "Gain {C:attention}+1{} hand"
      }
  }

  local alchemy_aqua = CodexArcanum.Alchemical:new("Aqua", "aqua", {extra = 1}, { x = 0, y = 0 }, alchemy_aqua_def, 3)
  SMODS.Sprite:new("c_alchemy_aqua", rota_mod.path, "c_alchemy_aqua.png", 71, 95, "asset_atli"):register();
  alchemy_aqua:register()
  	
	local alchemy_terra_def = {
      name = "Terra",
      text = {
          "Reduce blind by {C:attention}10%{}"
      }
  }

  local alchemy_terra = CodexArcanum.Alchemical:new("Terra", "terra", {}, { x = 0, y = 0 }, alchemy_terra_def, 3)
  SMODS.Sprite:new("c_alchemy_terra", rota_mod.path, "c_alchemy_terra.png", 71, 95, "asset_atli"):register();
  alchemy_terra:register()
    	
	local alchemy_aero_def = {
    name = "Aero",
    text = {
        "Draw {C:attention}4{} cards"
    }
  }

  local alchemy_aero = CodexArcanum.Alchemical:new("Aero", "aero", {extra = 4}, { x = 0, y = 0 }, alchemy_aero_def, 3)
  SMODS.Sprite:new("c_alchemy_aero", rota_mod.path, "c_alchemy_aero.png", 71, 95, "asset_atli"):register();
  alchemy_aero:register()
    	
	local alchemy_quicksilver_def = {
    name = "Quicksilver",
    text = {
        "{C:attention}+2{} hand size",
        "for this blind"
    }
  }

  local alchemy_quicksilver = CodexArcanum.Alchemical:new("Quicksilver", "quicksilver", {extra = 2}, { x = 0, y = 0 }, alchemy_quicksilver_def, 3)
  SMODS.Sprite:new("c_alchemy_quicksilver", rota_mod.path, "c_alchemy_quicksilver.png", 71, 95, "asset_atli"):register();
  alchemy_quicksilver:register()

  local alchemy_salt_def = {
    name = "Salt",
    text = {
        "Gain {C:attention}+2{} tags"
    }
  }

  local alchemy_salt = CodexArcanum.Alchemical:new("Salt", "salt", {extra = 2}, { x = 0, y = 0 }, alchemy_salt_def, 3)
  SMODS.Sprite:new("c_alchemy_salt", rota_mod.path, "c_alchemy_salt.png", 71, 95, "asset_atli"):register();
  alchemy_salt:register()

  local alchemy_sulfur_def = {
    name = "Sulfur",
    text = {
        "Gain {C:attention}10${} "
    }
  }

  local alchemy_sulfur = CodexArcanum.Alchemical:new("Sulfur", "sulfur", {extra = 10}, { x = 0, y = 0 }, alchemy_sulfur_def, 3)
  SMODS.Sprite:new("c_alchemy_sulfur", rota_mod.path, "c_alchemy_sulfur.png", 71, 95, "asset_atli"):register();
  alchemy_sulfur:register()

  local alchemy_phosphorus_def = {
    name = "Phosphorus",
    text = {
        "Return {C:attention}4{} discarded",
        "cards to deck"
    }
  }

  local alchemy_phosphorus = CodexArcanum.Alchemical:new("Phosphorus", "phosphorus", {extra = 4}, { x = 0, y = 0 }, alchemy_phosphorus_def, 3)
  SMODS.Sprite:new("c_alchemy_phosphorus", rota_mod.path, "c_alchemy_phosphorus.png", 71, 95, "asset_atli"):register();
  alchemy_phosphorus:register()

  local alchemy_bismuth_def = {
    name = "Bismuth",
    text = {
      "Converts up to",
      "{C:attention}2{} selected cards",
      "to {C:dark_edition}Polychrome",
      "for 1 blind"
    }
  }

  local alchemy_bismuth = CodexArcanum.Alchemical:new("Bismuth", "bismuth", {extra = 2}, { x = 0, y = 0 }, alchemy_bismuth_def, 3)
  SMODS.Sprite:new("c_alchemy_bismuth", rota_mod.path, "c_alchemy_bismuth.png", 71, 95, "asset_atli"):register();
  alchemy_bismuth:register()

  local alchemy_cobalt_def = {
    name = "Cobalt",
    text = {
      "Upgrade last played",
      "{C:legendary,E:1}poker hand",
      "by {C:attention}1{} level", 
      "{C:inactive}(hand: #1#)"
    }
  }

  local alchemy_cobalt = CodexArcanum.Alchemical:new("Cobalt", "cobalt", {extra = 1}, { x = 0, y = 0 }, alchemy_cobalt_def, 3)
  SMODS.Sprite:new("c_alchemy_cobalt", rota_mod.path, "c_alchemy_cobalt.png", 71, 95, "asset_atli"):register();
  alchemy_cobalt:register()

  local alchemy_arsenic_def = {
    name = "Arsenic",
    text = {
      "{C:attention}Swap{} your hands",
      "and your discards"
    }
  }

  local alchemy_arsenic = CodexArcanum.Alchemical:new("Arsenic", "arsenic", {}, { x = 0, y = 0 }, alchemy_arsenic_def, 3)
  SMODS.Sprite:new("c_alchemy_arsenic", rota_mod.path, "c_alchemy_arsenic.png", 71, 95, "asset_atli"):register();
  alchemy_arsenic:register()

  local alchemy_antimony_def = {
    name = "Antimony",
    text = {
      "Create a {C:dark_edition}Negative{} {C:eternal}eternal{}",
      "{C:attention}copy{} of a random",
      "joker for one blind"
    }
  }

  local alchemy_antimony = CodexArcanum.Alchemical:new("Antimony", "antimony", {}, { x = 0, y = 0 }, alchemy_antimony_def, 3)
  SMODS.Sprite:new("c_alchemy_antimony", rota_mod.path, "c_alchemy_antimony.png", 71, 95, "asset_atli"):register();
  alchemy_antimony:register()





  loc_colour("mult", nil)
  G.ARGS.LOC_COLOURS["alchemical"] = G.C.SECONDARY_SET.Alchemy




  
  G.localization.descriptions["Other"]["undiscovered_alchemical"] = {
    name = "Not Discovered",
    text = {
        "Purchase or use",
        "this card in an",
        "unseeded run to",
        "learn what it does"
    }
  }

  G.localization.misc.dictionary["k_alchemy_pack"] = "Alchemy Pack"

  G.localization.descriptions["Other"]["p_alchemy_normal"] = {
    name = "Alchemy Pack",
    text = {
        "Choose {C:attention}1{} of up to",
        "{C:attention}2{C:alchemical} Alchemical{} cards to",
        "add to your consumeables"
    }
  }

  G.localization.descriptions["Other"]["p_alchemy_jumbo"] = {
    name = "Alchemy Pack",
    text = {
        "Choose {C:attention}1{} of up to",
        "{C:attention}4{C:alchemical} Alchemical{} cards to",
        "add to your consumeables"
    }
  }

  G.localization.descriptions["Other"]["p_alchemy_mega"] = {
    name = "Alchemy Pack",
    text = {
        "Choose {C:attention}2{} of up to",
        "{C:attention}4{C:alchemical} Alchemical{} cards to",
        "add to your consumeables"
    }
  }

  SMODS.Sprite:new("alchemy_booster_atlas", rota_mod.path, "alchemy_booster_atlas.png", 71, 95, "asset_atli"):register();
  SMODS.Booster:new("Alchemy Pack", "alchemy_normal_1", {extra = 2, choose = 1}, { x = 0, y = 0 }, 4, false, 1, "Celestial", "alchemy_booster_atlas"):register()
  SMODS.Booster:new("Alchemy Pack", "alchemy_normal_2", {extra = 2, choose = 1}, { x = 1, y = 0 }, 4, false, 1, "Celestial", "alchemy_booster_atlas"):register()
  SMODS.Booster:new("Alchemy Pack", "alchemy_normal_3", {extra = 2, choose = 1}, { x = 2, y = 0 }, 4, false, 1, "Celestial", "alchemy_booster_atlas"):register()
  SMODS.Booster:new("Alchemy Pack", "alchemy_normal_4", {extra = 2, choose = 1}, { x = 3, y = 0 }, 4, false, 1, "Celestial", "alchemy_booster_atlas"):register()
  SMODS.Booster:new("Jumbo Alchemy Pack", "alchemy_jumbo_1", {extra = 4, choose = 1}, { x = 0, y = 1 }, 4, false, 1, "Celestial", "alchemy_booster_atlas"):register()
  SMODS.Booster:new("Jumbo Alchemy Pack", "alchemy_jumbo_2", {extra = 4, choose = 1}, { x = 1, y = 1 }, 4, false, 1, "Celestial", "alchemy_booster_atlas"):register()
  SMODS.Booster:new("Mega Alchemy Pack", "alchemy_mega_1", {extra = 4, choose = 2}, { x = 2, y = 1 }, 4, false, 0.25, "Celestial", "alchemy_booster_atlas"):register()





  -- Studious Joker
  local studious_joker_def = {
    name = "Studious Joker",
    text = {
        "{C:mult}+4{} Mult. Sell this",
        "joker to get one",
        "{C:alchemical} Alchemical{} card"
    }
  }

  local studious_joker = SMODS.Joker:new("Studious Joker", "studious_joker", {mult = 4}, { x = 0, y = 0 }, studious_joker_def, 1, 5, false, false, true, true, "Mult")
  SMODS.Sprite:new("j_studious_joker", rota_mod.path, "j_studious_joker.png", 71, 95, "asset_atli"):register();
  studious_joker:register()


  -- Chain Reaction
  local chain_reaction_def = {
    name = "Chain Reaction",
    text = {
        "{C:attention} Re-Trigger{} the first",
        "{C:alchemical} Alchemical{} card used",
        "each blind"
    }
  }

  local chain_reaction = SMODS.Joker:new("Chain Reaction", "chain_reaction", { extra = {used = false} }, { x = 0, y = 0 }, chain_reaction_def, 1, 5, false, false, true, true)
  SMODS.Sprite:new("j_chain_reaction", rota_mod.path, "j_chain_reaction.png", 71, 95, "asset_atli"):register();
  chain_reaction:register()


  -- Bottled Buffoon
  local bottled_buffoon_def = {
    name = "Bottled Buffoon",
    text = {
        "Create an {C:alchemical}Alchemical{} card",
        "every {C:attention}#1#{} hands played",
        "{C:inactive}#2#"
    }
  }

  local bottled_buffoon = SMODS.Joker:new("Bottled Buffoon", "bottled_buffoon", {extra = {every = 5, remaining = "5 remaining"}}, { x = 0, y = 0 }, bottled_buffoon_def, 1, 5, false, false, true, true)
  SMODS.Sprite:new("j_bottled_buffoon", rota_mod.path, "j_bottled_buffoon.png", 71, 95, "asset_atli"):register();
  bottled_buffoon:register()

  
  -- Essence of Comedy
  local essence_of_comedy_def = {
    name = "Essence of Comedy",
    text = {
      "Gains {X:mult,C:white} X#1# {} Mult",
      "per {C:alchemical}Alchemical{} card used",
      "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
    }
  }

  local essence_of_comedy = SMODS.Joker:new("Essence of Comedy", "essence_of_comedy", {extra = 0.1, Xmult = 1}, { x = 0, y = 0 }, essence_of_comedy_def, 2, 6, false, false, true, true)
  SMODS.Sprite:new("j_essence_of_comedy", rota_mod.path, "j_essence_of_comedy.png", 71, 95, "asset_atli"):register();
  essence_of_comedy:register()

  
  -- Shock Humor
  local shock_humor_def = {
    name = "Shock Humor",
    text = {
        "{C:green}#1# in #2#{} chance to",
        "get an {C:alchemical}Alchemical{} card",
        "when you discard a {C:attention}Gold{},",
        "{C:attention}Steel{} or {C:attention}Stone{} card"
    }
  }

  local shock_humor = SMODS.Joker:new("Shock Humor", "shock_humor", {extra = {odds = 5}}, { x = 0, y = 0 }, shock_humor_def, 2, 5, false, false, true, true)
  SMODS.Sprite:new("j_shock_humor", rota_mod.path, "j_shock_humor.png", 71, 95, "asset_atli"):register();
  shock_humor:register()


  -- Breaking Bozo
  local breaking_bozo_def = {
    name = "Breaking Bozo",
    text = {
        "When {C:alchemical}Alchemical{} card is used,",
        "activate a weaker version of a ",
        "random {C:alchemical}Alchemical{} card"
    }
  }

  local breaking_bozo = SMODS.Joker:new("Breaking Bozo", "breaking_bozo", {}, { x = 0, y = 0 }, breaking_bozo_def, 3, 7, false, false, true, true)
  SMODS.Sprite:new("j_breaking_bozo", rota_mod.path, "j_breaking_bozo.png", 71, 95, "asset_atli"):register();
  breaking_bozo:register()


  -- Catalyst Joker
  local catalyst_joker_def = {
    name = "Catalyst Joker",
    text = {
        "{C:attention}+2{} consumable slots.",
        "Gains {X:mult,C:white} X#1# {} Mult for",
        "every {C:attention}Consumable Card{} held",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
    }
  }

  local catalyst_joker = SMODS.Joker:new("Catalyst Joker", "catalyst_joker", {extra = {slots = 2, bonus = 1}}, { x = 0, y = 0 }, catalyst_joker_def, 3, 6, false, false, true, true)
  SMODS.Sprite:new("j_catalyst_joker", rota_mod.path, "j_catalyst_joker.png", 71, 95, "asset_atli"):register();
  catalyst_joker:register()




  
  -- Mortar and Pestle
  local v_mortar_and_pestle_def = {
    name = "Mortar and Pestle",
    text = {
        "{C:attention}+1{} consumable slot",
    }
  }

  local mortar_and_pestle = SMODS.Voucher:new("Mortar and Pestle", "mortar_and_pestle", {extra = 1}, { x = 0, y = 0 }, v_mortar_and_pestle_def)
  SMODS.Sprite:new("v_mortar_and_pestle", rota_mod.path, "v_mortar_and_pestle.png", 71, 95, "asset_atli"):register();
  mortar_and_pestle:register()

    -- Cauldron
  local v_cauldron_def = {
    name = "Cauldron",
    text = {
        "Some {C:alchemical}Alchemical{} cards",
        "may become Negative"
    }
  }

  local cauldron = SMODS.Voucher:new("Cauldron", "cauldron", {}, { x = 0, y = 0 }, v_cauldron_def, 10, true, false, true, {"v_mortar_and_pestle"})
  SMODS.Sprite:new("v_cauldron", rota_mod.path, "v_cauldron.png", 71, 95, "asset_atli"):register();
  cauldron:register()





  -- Philosopher's Deck
  local philosopher_deck_def = {
    name = "Philosopher's Deck",
    text = {
      "Start run with the",
      "{C:tarot,T:v_mortar_and_pestle}Mortar and Pestle{} voucher",
      "and {C:attention}2{} {C:alchemical}Alchemical{} cards"
    },
  }
  
  local philosopher_deck = SMODS.Deck:new("Philosopher's Deck", "philosopher", {voucher = 'v_mortar_and_pestle', consumables = {'c_alchemy_ignis', 'c_alchemy_terra'}, atlas = "b_philosopher"}, {x = 0, y = 0}, philosopher_deck_def)
  SMODS.Sprite:new("b_philosopher", rota_mod.path, "b_philosopher.png", 71, 95, "asset_atli"):register();
  philosopher_deck:register()


  SMODS:SAVE_UNLOCKS()
end

----------------------------------------------
------------MOD CODE END----------------------
