function create_alchemical() 
    local card = create_card("Alchemical", G.pack_cards, nil, nil, true, true, nil, 'alc')
    return card
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

function return_to_deck(count, card)
    if not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and
        G.hand.config.card_limit <= 0 and #G.hand.cards == 0 then 
        G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false 
        return true
    end

    delay(0.05)
    draw_card(G.hand,G.deck, 100,'up', false, card)
end

function CodexArcanum.INIT.CA_CardUtil()
    
end