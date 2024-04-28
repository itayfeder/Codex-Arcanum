
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
    for i = 1, 4 do
      local center = G.P_CENTER_POOLS["Alchemical"][(j-1) * 4 + i + (8*(args.cycle_config.current_option - 1))]
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
        (4.25)*G.CARD_W,
        1*G.CARD_H, 
        {card_limit = 4, type = 'title', highlight_limit = 0, collection = true})
      table.insert(deck_tables, 
      {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
        {n=G.UIT.O, config={object = G.your_collection[j]}}
      }}
      )
    end
  
    local alchemical_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Alchemical/8) do
      table.insert(alchemical_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Alchemical/8)))
    end
  
    for j = 1, #G.your_collection do
      for i = 1, 4 do
        local center = G.P_CENTER_POOLS["Alchemical"][(j-1) * 4 + i]
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
                      create_option_cycle({options = alchemical_options, w = 4, cycle_shoulders = true, opt_callback = 'your_collection_alchemical_page', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
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

function CodexArcanum.INIT.CA_AlchemyUI()
    
end