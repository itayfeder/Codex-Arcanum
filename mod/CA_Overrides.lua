
local get_type_colourref = get_type_colour
function get_type_colour(_c, card)
  local fromRef = get_type_colourref(_c, card)

  if _c.set == "Alchemical" then
    return G.C.SECONDARY_SET.Alchemy
  end

  return fromRef
end

local create_cardref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)

  if not forced_key and soulable and (not G.GAME.banned_keys['c_soul']) then
    if (_type == 'Alchemical' or _type == 'Spectral') and
    not (G.GAME.used_jokers['c_philosopher_stone'] and not next(find_joker("Showman")))  then
        if pseudorandom('philosopher_stone_'.._type..G.GAME.round_resets.ante) > 0.997 then
            forced_key = 'c_philosopher_stone'
        end
    end
  end

  local card = create_cardref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)

  if G.GAME.used_vouchers.v_cauldron and pseudorandom('cauldron') > 0.5 and _type == "Alchemical" then
    card:set_edition({negative = true}, true)
  end

  return card
end


local create_card_for_shopref = create_card_for_shop
function create_card_for_shop(area)
  if G.GAME.alchemical_rate then
    if area == G.shop_jokers and G.SETTINGS.tutorial_progress and G.SETTINGS.tutorial_progress.forced_shop and G.SETTINGS.tutorial_progress.forced_shop[#G.SETTINGS.tutorial_progress.forced_shop] then
      local t = G.SETTINGS.tutorial_progress.forced_shop
      local _center = G.P_CENTERS[t[#t]] or G.P_CENTERS.c_empress
      local card = Card(area.T.x + area.T.w/2, area.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, _center, {bypass_discovery_center = true, bypass_discovery_ui = true})
      t[#t] = nil
      if not t[1] then G.SETTINGS.tutorial_progress.forced_shop = nil end
      
      create_shop_card_ui(card)
      return card
    else
      local forced_tag = nil
      for k, v in ipairs(G.GAME.tags) do
        if not forced_tag then
          forced_tag = v:apply_to_run({type = 'store_joker_create', area = area})
          if forced_tag then
            for kk, vv in ipairs(G.GAME.tags) do
              if vv:apply_to_run({type = 'store_joker_modify', card = forced_tag}) then break end
            end
            return forced_tag end
        end
      end
        G.GAME.spectral_rate = G.GAME.spectral_rate or 0
        local total_rate = G.GAME.joker_rate + G.GAME.tarot_rate + G.GAME.planet_rate + G.GAME.playing_card_rate + G.GAME.spectral_rate + G.GAME.alchemical_rate
        local polled_rate = pseudorandom(pseudoseed('cdt'..G.GAME.round_resets.ante))*total_rate
        local check_rate = 0
        for _, v in ipairs({
          {type = 'Joker', val = G.GAME.joker_rate},
          {type = 'Tarot', val = G.GAME.tarot_rate},
          {type = 'Planet', val = G.GAME.planet_rate},
          {type = 'Alchemical', val = G.GAME.alchemical_rate},
          {type = (G.GAME.used_vouchers["v_illusion"] and pseudorandom(pseudoseed('illusion')) > 0.6) and 'Enhanced' or 'Base', val = G.GAME.playing_card_rate},
          {type = 'Spectral', val = G.GAME.spectral_rate},
        }) do
          if polled_rate > check_rate and polled_rate <= check_rate + v.val then
            local card = create_card(v.type, area, nil, nil, nil, nil, nil, 'sho')
            create_shop_card_ui(card, v.type, area)
            G.E_MANAGER:add_event(Event({
                func = (function()
                    for k, v in ipairs(G.GAME.tags) do
                      if v:apply_to_run({type = 'store_joker_modify', card = card}) then break end
                    end
                    return true
                end)
            }))
            if (v.type == 'Base' or v.type == 'Enhanced') and G.GAME.used_vouchers["v_illusion"] and pseudorandom(pseudoseed('illusion')) > 0.8 then 
              local edition_poll = pseudorandom(pseudoseed('illusion'))
              local edition = {}
              if edition_poll > 1 - 0.15 then edition.polychrome = true
              elseif edition_poll > 0.5 then edition.holo = true
              else edition.foil = true
              end
              card:set_edition(edition)
            end
            return card
          end
          check_rate = check_rate + v.val
        end
    end
  else
    return create_card_for_shopref(area)
  end
end


local get_current_poolref = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
  if _type == 'Alchemical' or _type == 'Spectral' then
    G.ARGS.TEMP_POOL = EMPTY(G.ARGS.TEMP_POOL)
    local _pool, _starting_pool, _pool_key, _pool_size = G.ARGS.TEMP_POOL, nil, '', 0
    _starting_pool, _pool_key = G.P_CENTER_POOLS[_type], _type..(_append or '')

    for k, v in ipairs(_starting_pool) do
      local add = nil
      if _type == 'Enhanced' then
          add = true
      elseif _type == 'Demo' then
          if v.pos and v.config then add = true end
      elseif _type == 'Tag' then
          if (not v.requires or (G.P_CENTERS[v.requires] and G.P_CENTERS[v.requires].discovered)) and 
          (not v.min_ante or v.min_ante <= G.GAME.round_resets.ante) then
              add = true
          end
      elseif not (G.GAME.used_jokers[v.key] and not next(find_joker("Showman"))) and
          (v.unlocked ~= false or v.rarity == 4) then
          if v.set == 'Voucher' then
              if not G.GAME.used_vouchers[v.key] then 
                  local include = true
                  if v.requires then 
                      for kk, vv in pairs(v.requires) do
                          if not G.GAME.used_vouchers[vv] then 
                              include = false
                          end
                      end
                  end
                  if G.shop_vouchers and G.shop_vouchers.cards then
                      for kk, vv in ipairs(G.shop_vouchers.cards) do
                          if vv.config.center.key == v.key then include = false end
                      end
                  end
                  if include then
                      add = true
                  end
              end
          elseif v.set == 'Planet' then
              if (not v.config.softlock or G.GAME.hands[v.config.hand_type].played > 0) then
                  add = true
              end
          elseif v.enhancement_gate then
              add = nil
              for kk, vv in pairs(G.playing_cards) do
                  if vv.config.center.key == v.enhancement_gate then
                      add = true
                  end
              end
          else
              add = true
          end
          if v.name == 'Black Hole' or v.name == 'The Soul' or v.name == "Philosopher's Stone" then
              add = false
          end
      end

      if v.no_pool_flag and G.GAME.pool_flags[v.no_pool_flag] then add = nil end
      if v.yes_pool_flag and not G.GAME.pool_flags[v.yes_pool_flag] then add = nil end
      
      if add and not G.GAME.banned_keys[v.key] then 
          _pool[#_pool + 1] = v.key
          _pool_size = _pool_size + 1
      else
          _pool[#_pool + 1] = 'UNAVAILABLE'
      end
    end

    if _pool_size == 0 then
      _pool = EMPTY(G.ARGS.TEMP_POOL)
      if _type == 'Tarot' or _type == 'Tarot_Planet' then _pool[#_pool + 1] = "c_fool"
      elseif _type == 'Alchemical' then _pool[#_pool + 1] = "c_alchemy_ignis"
      elseif _type == 'Planet' then _pool[#_pool + 1] = "c_pluto"
      elseif _type == 'Spectral' then _pool[#_pool + 1] = "c_incantation"
      elseif _type == 'Joker' then _pool[#_pool + 1] = "j_joker"
      elseif _type == 'Demo' then _pool[#_pool + 1] = "j_joker"
      elseif _type == 'Voucher' then _pool[#_pool + 1] = "v_blank"
      elseif _type == 'Tag' then _pool[#_pool + 1] = "tag_handy"
      else _pool[#_pool + 1] = "j_joker"
      end
    end

    return _pool, _pool_key..G.GAME.round_resets.ante
  end 

  return get_current_poolref(_type, _rarity, _legendary, _append)
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

    if card_type == 'Locked' then
      localize{type = 'unlocks', key = _c.key, set = _c.set, nodes = desc_nodes, vars = loc_vars}
    elseif hide_desc then
      localize{type = 'other', key = 'undiscovered_'..(string.lower(_c.set)), set = _c.set, nodes = desc_nodes}
    elseif _c.set == "Alchemical" then
      info_queue[#info_queue+1] = {key = "alchemical_card", set = "Other"}
      if _c.name == 'Bismuth' then info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
      elseif _c.name == 'Manganese' then info_queue[#info_queue+1] = G.P_CENTERS.m_steel
      elseif _c.name == 'Glass' then info_queue[#info_queue+1] = G.P_CENTERS.m_glass
      elseif _c.name == 'Gold' then info_queue[#info_queue+1] = G.P_CENTERS.m_gold
      elseif _c.name == 'Silver' then info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
      elseif _c.name == 'Stone' then info_queue[#info_queue+1] = G.P_CENTERS.m_stone
      elseif _c.name == 'Cobalt' then 
        local loc_text = "Not chosen"
        if G.hand then
          local text,disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
          loc_text = localize(text, 'poker_hands')
          if loc_text == "ERROR" then
            loc_text = "Not chosen"
          end
        end
        loc_vars = {loc_text}
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

local set_spritesref = Card.set_sprites
function Card:set_sprites(_center, _front)
    if _center and _center.set == "Alchemical" then
      if _center.set then
        if self.children.center then
          self.children.center.atlas = G.ASSET_ATLAS[_center.atlas]
          self.children.center:set_sprite_pos(_center.pos)
        else
          if not _center.unlocked and not self.params.bypass_discovery_center then 
            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["c_alchemy_locked"], {x=0,y=0})
          elseif not self.params.bypass_discovery_center and not _center.discovered then 
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
  if self.config.in_booster and (self.ability.set == "Alchemical" or self.ability.name == "Philosopher's Stone") then
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
    local key = self.config.center.key
    local center_obj = CodexArcanum.Alchemicals[key]
    if center_obj and center_obj.use and type(center_obj.use) == 'function' then
      stop_use()
      if not copier then set_consumeable_usage(self) end
      if self.debuff then return nil end
      if self.ability.consumeable.max_highlighted then
        update_hand_text({ immediate = true, nopulse = true, delay = 0 },
          { mult = 0, chips = 0, level = '', handname = '' })
      end
      center_obj.use(self, area, copier)
      check_for_unlock({type = 'used_alchemical'})
    end

    if self.ability.name == "Philosopher's Stone" then
      G.deck.config.philosopher = true
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
    if self.ability.set == "Alchemical" then
      local t = nil
      local key = self.config.center.key
      local center_obj = CodexArcanum.Alchemicals[key]

      self.config.in_booster = false
      if center_obj and center_obj.can_use and type(center_obj.can_use) == 'function' then
          t = center_obj.can_use(self)
      end
      if not (t == nil) then
        return t
      end
    end
  end

  if G.STATE == G.STATES.STANDARD_PACK or G.STATE == G.STATES.TAROT_PACK 
  or G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.BUFFOON_PACK then
    if self.ability.set == "Alchemical" then
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
  
  if G.deck.config.philosopher then
    G.deck.config.philosopher = false
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

  if G.deck.config.manganese then
    for _, manganese_id in ipairs(G.deck.config.manganese) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == manganese_id and card.config.center == G.P_CENTERS.m_steel then
          
          card:set_ability(G.P_CENTERS.c_base, nil, true)
        end
      end
    end
    G.deck.config.manganese = {}
  end

  if G.deck.config.wax then
    local _first_dissolve = false
    for _, wax_id in ipairs(G.deck.config.wax) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == wax_id then
          card:start_dissolve(nil, _first_dissolve)
          _first_dissolve = true
        end
      end
    end
    G.deck.config.wax = {}
  end

  if G.deck.config.borax then
    for _, borax_table in ipairs(G.deck.config.borax) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == borax_table.id then
          card:change_suit(borax_table.suit)
        end
      end
    end
    G.deck.config.borax = {}
  end
  
  if G.deck.config.glass then
    for _, glass_id in ipairs(G.deck.config.glass) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == glass_id and card.config.center == G.P_CENTERS.m_glass then
          
          card:set_ability(G.P_CENTERS.c_base, nil, true)
        end
      end
    end
    G.deck.config.glass = {}
  end

  if G.deck.config.gold then
    for _, gold_id in ipairs(G.deck.config.gold) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == gold_id and card.config.center == G.P_CENTERS.m_gold then
          
          card:set_ability(G.P_CENTERS.c_base, nil, true)
        end
      end
    end
    G.deck.config.gold = {}
  end

  if G.deck.config.silver then
    for _, silver_id in ipairs(G.deck.config.silver) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == silver_id and card.config.center == G.P_CENTERS.m_lucky then
          
          card:set_ability(G.P_CENTERS.c_base, nil, true)
        end
      end
    end
    G.deck.config.silver = {}
  end

  if G.deck.config.stone then
    for _, stone_id in ipairs(G.deck.config.stone) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == stone_id and card.config.center == G.P_CENTERS.m_stone then
          
          card:set_ability(G.P_CENTERS.c_base, nil, true)
        end
      end
    end
    G.deck.config.stone = {}
  end

  if G.deck.config.acid then
    for _, acid in ipairs(G.deck.config.acid) do
      G.playing_card = (G.playing_card and G.playing_card + 1) or 1
      local _card = copy_card(acid, nil, nil, G.playing_card)
      G.deck:emplace(_card)
      G.deck.config.card_limit = G.deck.config.card_limit + 1
      table.insert(G.playing_cards, _card)
    end
    G.deck.config.acid = {}
  end
  
  for k, card in ipairs(G.playing_cards) do
    if card.ability.extra and card.ability.extra.oil then
      card.ability.extra.oil = nil
    end
  end

  if G.deck.config.uranium then
    for _, uranium_id in ipairs(G.deck.config.uranium) do
      for k, card in ipairs(G.playing_cards) do
        if card.unique_val == uranium_id then
          
          card:set_ability(G.P_CENTERS.c_base, nil, true)
          card:set_edition({}, nil, true)
          card:set_seal(nil, true, nil)
        end
      end
    end
    G.deck.config.uranium = {}
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

local calculate_jokerref = Card.calculate_joker;
function Card:calculate_joker(context)

  local val = calculate_jokerref(self, context)

  if context.scoring_name then
    G.GAME.last_played_hand = context.scoring_name
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

local card_updateref = Card.update
function Card:update(dt)
  card_updateref(self, dt)

  if G.STAGE == G.STAGES.RUN then
    if self.ability.name == "Catalyst Joker" then 
      self.ability.consumeable_tally = #G.consumeables.cards
    end
  end
end

local calculate_sealref = Card.calculate_seal
function Card:calculate_seal(context)
  if self.debuff then return nil end
  if context.repetition and G.deck.config.philosopher then
    return {
        message = localize('k_again_ex'),
        repetitions = 1,
        card = self
    }
  end
  return calculate_sealref(self, context)
end

local ease_background_colour_blindref = ease_background_colour_blind
function ease_background_colour_blind(state, blind_override)
  ease_background_colour_blindref(state, blind_override)

  if G.deck and G.deck.config.philosopher then 
    G.GAME.blind:change_colour(G.C.RAINBOW_EDITION)
    ease_background_colour{new_colour = G.C.RAINBOW_EDITION, contrast = 1}
  end
end

function hue_to_rgb(hue) 
  local r, g, b = 0;

  local saturation = 0.5;
  local lightness = 0.75;

  if hue < 60 then 
    r = 1; 
    g = saturation + (1 - saturation) * (hue / 60); 
    b = 1 - saturation; 
  elseif hue < 120 then 
    r = saturation + (1 - saturation) * ((120 - hue) / 60); 
    g = 1; 
    b = 1 - saturation;
  elseif hue < 180 then 
    r = 1 - saturation; 
    g = 1; 
    b = saturation + (1 - saturation) * ((hue - 120) / 60);
  elseif hue < 240 then 
    r = 1 - saturation; 
    g = saturation + (1 - saturation) * ((240 - hue) / 60); 
    b = 1;
  elseif hue < 300 then 
    r = saturation + (1 - saturation) * ((hue - 240) / 60); 
    g = 1 - saturation; 
    b = 1;
  else 
    r = 1; 
    g = 1 - saturation; 
    b = saturation + (1 - saturation) * ((360 - hue) / 60); end

  local gray = 0.2989 * r + 0.5870 * g + 0.1140 * b

  r = (1 - 0.5) * r + 0.5 * gray
  g = (1 - 0.5) * g + 0.5 * gray
  b = (1 - 0.5) * b + 0.5 * gray

  r = r * lightness;
  g = g * lightness;
  b = b * lightness;

  return r, g, b
end


local game_updateref = Game.update
function Game:update(dt)
  game_updateref(self, dt)

  if not self.C.RAINBOW_EDITION then
    self.C.RAINBOW_EDITION = {0,0,0,1}
    self.C.RAINBOW_EDITION_HUE = 0
  end

  local r, g, b = hue_to_rgb(self.C.RAINBOW_EDITION_HUE)

  self.C.RAINBOW_EDITION[1] = r
  self.C.RAINBOW_EDITION[3] = g
  self.C.RAINBOW_EDITION[2] = b

  self.C.RAINBOW_EDITION_HUE = (self.C.RAINBOW_EDITION_HUE + 0.25) % 360

  if G.deck and G.deck.config.philosopher then 
    G.GAME.blind:change_colour(G.C.RAINBOW_EDITION)
    ease_background_colour{new_colour = G.C.RAINBOW_EDITION, contrast = 1}
  end
  
end


local init_item_prototypes_ref = Game.init_item_prototypes
function Game:init_item_prototypes()
  init_item_prototypes_ref(self)

  G.C.SECONDARY_SET.Alchemy = HEX("C09D75")
  G.P_CENTER_POOLS.Alchemical = {}
  G.localization.descriptions.Alchemical = {}

  for _, booster in pairs(SMODS.Boosters) do
    booster:register()
  end

  for _, alchemical in pairs(CodexArcanum.Alchemicals) do
    alchemical:register()
  end

  for _, tag in pairs(SMODS.Tags) do
    tag:register()
  end
  SMODS.LOAD_LOC()
  SMODS.SAVE_UNLOCKS()
  ALCHEMICAL_SAVE_UNLOCKS()
  save_tags()
end


local alias__G_UIDEF_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons;
function G.UIDEF.use_and_sell_buttons(card)
	local ret = alias__G_UIDEF_use_and_sell_buttons(card)

  if (card.ability.set == "Alchemical" or card.ability.name == "Philosopher's Stone") and G.ARGS.is_alchemical_booster and (card.area == G.pack_cards and G.pack_cards) then
		return {
			n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
				{n=G.UIT.R, config={mid = true}, nodes={
				}},
				{n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, minh = 0.8*card.T.h, maxw = 0.7*card.T.w - 0.15, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'select_alchemical', func = 'can_select_alchemical'}, nodes={
				{n=G.UIT.T, config={text = localize("b_select"),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
			}},
		}}
	end
	
	return ret
end

G.FUNCS.can_select_alchemical = function(e)
  if (e.config.ref_table.edition and e.config.ref_table.edition.negative) or #G.consumeables.cards < G.consumeables.config.card_limit then 
      e.config.colour = G.C.GREEN
      e.config.button = 'select_alchemical'
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.select_alchemical = function(e, mute, nosave)
  e.config.button = nil
  local card = e.config.ref_table
  local area = card.area
  local prev_state = G.STATE
  local dont_dissolve = nil
  local delay_fac = 1

  G.TAROT_INTERRUPT = G.STATE
  if card.ability.set == 'Booster' then G.GAME.PACK_INTERRUPT = G.STATE end 
  G.STATE = (G.STATE == G.STATES.TAROT_PACK and G.STATES.TAROT_PACK) or
    (G.STATE == G.STATES.PLANET_PACK and G.STATES.PLANET_PACK) or
    (G.STATE == G.STATES.SPECTRAL_PACK and G.STATES.SPECTRAL_PACK) or
    (G.STATE == G.STATES.STANDARD_PACK and G.STATES.STANDARD_PACK) or
    (G.STATE == G.STATES.BUFFOON_PACK and G.STATES.BUFFOON_PACK) or
    G.STATES.PLAY_TAROT
    
  G.CONTROLLER.locks.use = true
  if G.booster_pack and not G.booster_pack.alignment.offset.py and (card.ability.consumeable or not (G.GAME.pack_choices and G.GAME.pack_choices > 1)) then
    G.booster_pack.alignment.offset.py = G.booster_pack.alignment.offset.y
    G.booster_pack.alignment.offset.y = G.ROOM.T.y + 29
  end
  if G.shop and not G.shop.alignment.offset.py then
    G.shop.alignment.offset.py = G.shop.alignment.offset.y
    G.shop.alignment.offset.y = G.ROOM.T.y + 29
  end
  if G.blind_select and not G.blind_select.alignment.offset.py then
    G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
    G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
  end
  if G.round_eval and not G.round_eval.alignment.offset.py then
    G.round_eval.alignment.offset.py = G.round_eval.alignment.offset.y
    G.round_eval.alignment.offset.y = G.ROOM.T.y + 29
  end

  if card.children.use_button then card.children.use_button:remove(); card.children.use_button = nil end
  if card.children.sell_button then card.children.sell_button:remove(); card.children.sell_button = nil end
  if card.children.price then card.children.price:remove(); card.children.price = nil end

  if card.area then card.area:remove_card(card) end
  
  if card.ability.set == 'Alchemical' or card.ability.name == "Philosopher's Stone" then
    card:add_to_deck()
    G.consumeables:emplace(card)
    play_sound('card1', 0.8, 0.6)
    play_sound('generic1')
    dont_dissolve = true
    delay_fac = 0.2
  end
G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2,
func = function()
  if not dont_dissolve then card:start_dissolve() end
  G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,
  func = function()
    G.STATE = prev_state
    G.TAROT_INTERRUPT=nil
    G.CONTROLLER.locks.use = false

    if (prev_state == G.STATES.TAROT_PACK or prev_state == G.STATES.PLANET_PACK or
      prev_state == G.STATES.SPECTRAL_PACK or prev_state == G.STATES.STANDARD_PACK or
      prev_state == G.STATES.BUFFOON_PACK) and G.booster_pack then
      if area == G.consumeables then
      G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
      G.booster_pack.alignment.offset.py = nil
      elseif G.GAME.pack_choices and G.GAME.pack_choices > 1 then
      if G.booster_pack.alignment.offset.py then 
        G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
        G.booster_pack.alignment.offset.py = nil
      end
      G.GAME.pack_choices = G.GAME.pack_choices - 1
      else
        G.CONTROLLER.interrupt.focus = true
        
        G.FUNCS.end_consumeable(nil, delay_fac)
      end
    else
      if G.shop then 
      G.shop.alignment.offset.y = G.shop.alignment.offset.py
      G.shop.alignment.offset.py = nil
      end
      if G.blind_select then
      G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
      G.blind_select.alignment.offset.py = nil
      end
      if G.round_eval then
      G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
      G.round_eval.alignment.offset.py = nil
      end
      if area and area.cards[1] then 
      G.E_MANAGER:add_event(Event({func = function()
        G.E_MANAGER:add_event(Event({func = function()
        G.CONTROLLER.interrupt.focus = nil
        if card.ability.set == 'Voucher' then 
          G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')})
        elseif area then
          G.CONTROLLER:recall_cardarea_focus(area)
        end
        return true end }))
      return true end }))
      end
    end
  return true
  end}))
return true
end}))
end


local create_UIBox_notify_alertref = create_UIBox_notify_alert
function create_UIBox_notify_alert(_achievement, _type)
  local retval = create_UIBox_notify_alertref(_achievement, _type)

  if _type == 'Alchemical' then
    local _c = G.P_CENTERS[_achievement]
    local _atlas = G.ASSET_ATLAS[_c.atlas]
   
    local t_s = Sprite(0,0,1.5*(_atlas.px/_atlas.py),1.5,_atlas, _c and _c.pos or {x=3, y=0})
    t_s.states.drag.can = false
    t_s.states.hover.can = false
    t_s.states.collide.can = false

    local subtext = localize('k_alchemical')

    local t = {n=G.UIT.ROOT, config = {align = 'cl', r = 0.1, padding = 0.06, colour = G.C.UI.TRANSPARENT_DARK}, nodes={
      {n=G.UIT.R, config={align = "cl", padding = 0.2, minw = 20, r = 0.1, colour = G.C.BLACK, outline = 1.5, outline_colour = G.C.GREY}, nodes={
        {n=G.UIT.R, config={align = "cm", r = 0.1}, nodes={
          {n=G.UIT.R, config={align = "cm", r = 0.1}, nodes={
            {n=G.UIT.O, config={object = t_s}},
          }},
          _type ~= 'achievement' and {n=G.UIT.R, config={align = "cm", padding = 0.04}, nodes={
            {n=G.UIT.R, config={align = "cm", maxw = 3.4}, nodes={
              {n=G.UIT.T, config={text = subtext, scale = 0.5, colour = G.C.FILTER, shadow = true}},
            }},
            {n=G.UIT.R, config={align = "cm", maxw = 3.4}, nodes={
              {n=G.UIT.T, config={text = localize('k_unlocked_ex'), scale = 0.35, colour = G.C.FILTER, shadow = true}},
            }}
          }}
          or {n=G.UIT.R, config={align = "cm", padding = 0.04}, nodes={
            {n=G.UIT.R, config={align = "cm", maxw = 3.4, padding = 0.1}, nodes={
              {n=G.UIT.T, config={text = name, scale = 0.4, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
            {n=G.UIT.R, config={align = "cm", maxw = 3.4}, nodes={
              {n=G.UIT.T, config={text = subtext, scale = 0.3, colour = G.C.FILTER, shadow = true}},
            }},
            {n=G.UIT.R, config={align = "cm", maxw = 3.4}, nodes={
              {n=G.UIT.T, config={text = localize('k_unlocked_ex'), scale = 0.35, colour = G.C.FILTER, shadow = true}},
            }}
          }}
        }}
      }}
    }}
    return t
  end

  return retval
end

local create_UIBox_card_unlockref = create_UIBox_card_unlock
function create_UIBox_card_unlock(card_center)
  local retval = create_UIBox_card_unlockref(card_center)

  if card_center.set == 'Alchemical' then
 
    retval.nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].config.object:remove()
    retval.nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1] = {n=G.UIT.O, config={object = DynaText({string = {localize('k_alchemical')}, colours = {G.C.BLUE},shadow = true, rotate = true, bump = true, pop_in = 0.3, pop_in_rate = 2, scale = 1.2})}}
    retval.nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[2].nodes[1].config.object:remove()
    retval.nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[2].nodes[1] = {n=G.UIT.O, config={object = DynaText({string = {localize('k_unlocked_ex')}, colours = {G.C.RED},shadow = true, rotate = true, bump = true, pop_in = 0.6, pop_in_rate = 2, scale = 0.8})}}

  end

  return retval
end


function ALCHEMICAL_SAVE_UNLOCKS() 
  G:save_progress()
  -------------------------------------
  local TESTHELPER_unlocks = false and not _RELEASE_MODE
  -------------------------------------
  if not love.filesystem.getInfo(G.SETTINGS.profile .. '') then
      love.filesystem.createDirectory(G.SETTINGS.profile ..
          '')
  end
  if not love.filesystem.getInfo(G.SETTINGS.profile .. '/' .. 'meta.jkr') then
      love.filesystem.append(
          G.SETTINGS.profile .. '/' .. 'meta.jkr', 'return {}')
  end

  convert_save_to_meta()

  local meta = STR_UNPACK(get_compressed(G.SETTINGS.profile .. '/' .. 'meta.jkr') or 'return {}')
  meta.unlocked = meta.unlocked or {}
  meta.discovered = meta.discovered or {}
  meta.alerted = meta.alerted or {}

  for k, v in pairs(G.P_CENTERS) do
      if not v.wip and not v.demo then
          if TESTHELPER_unlocks then
              v.unlocked = true; v.discovered = true; v.alerted = true
          end --REMOVE THIS
          if not v.unlocked and (string.find(k, '^j_') or string.find(k, '^b_') or string.find(k, '^v_')) or string.find(k, '^c_') and meta.unlocked[k] then
              v.unlocked = true
          end
          if not v.unlocked and (string.find(k, '^j_') or string.find(k, '^b_') or string.find(k, '^v_')) or string.find(k, '^c_') then
              G.P_LOCKED[#G.P_LOCKED + 1] =
                  v
          end
          if not v.discovered and (string.find(k, '^j_') or string.find(k, '^b_') or string.find(k, '^e_') or string.find(k, '^c_') or string.find(k, '^p_') or string.find(k, '^v_')) and meta.discovered[k] then
              v.discovered = true
          end
          if v.discovered and meta.alerted[k] or v.set == 'Back' or v.start_alerted then
              v.alerted = true
          elseif v.discovered then
              v.alerted = false
          end
      end
  end

  for k, v in pairs(G.P_BLINDS) do
      v.key = k
      if not v.wip and not v.demo then 
          if TESTHELPER_unlocks then v.discovered = true; v.alerted = true  end --REMOVE THIS
          if not v.discovered and meta.discovered[k] then 
              v.discovered = true
          end
          if v.discovered and meta.alerted[k] then 
              v.alerted = true
          elseif v.discovered then
              v.alerted = false
          end
      end
  end

  for k, v in pairs(G.P_SEALS) do
      v.key = k
      if not v.wip and not v.demo then
          if TESTHELPER_unlocks then
              v.discovered = true; v.alerted = true
          end                                                                   --REMOVE THIS
          if not v.discovered and meta.discovered[k] then
              v.discovered = true
          end
          if v.discovered and meta.alerted[k] then
              v.alerted = true
          elseif v.discovered then
              v.alerted = false
          end
      end
  end
end


local check_for_unlockref = check_for_unlock
function check_for_unlock(args)
  if not next(args) then return end
  if G.GAME.seeded then return end

  local alchemicals_count = 0
  for k, v in pairs(G.GAME.consumeable_usage) do
    if v.set == 'Alchemical' then alchemicals_count = alchemicals_count + 1 end
  end

  local i=1
  while i <= #G.P_LOCKED do
    local ret = false
    local card = G.P_LOCKED[i]

    if not card.unlocked and card.unlock_condition and card.unlock_condition.type == args.type then
      if args.type == 'used_alchemical' and alchemicals_count >= card.unlock_condition.extra then
        ret = true
        unlock_card(card)
      end
    end

    if ret == true then
      table.remove(G.P_LOCKED, i)
    else
        i = i + 1
    end
  end

end

local blind_debuff_cardref = Blind.debuff_card
function Blind:debuff_card(card, from_blind)
  if card.ability and card.ability.extra and type(card.ability.extra) == "table" and card.ability.extra.oil then return end
  blind_debuff_cardref(self, card, from_blind)
end

function CodexArcanum.INIT.CA_Overrides()
  
end