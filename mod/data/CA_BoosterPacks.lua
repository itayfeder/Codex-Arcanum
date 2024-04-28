function CodexArcanum.INIT.CA_BoosterPacks()
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
  
    SMODS.Sprite:new("ca_booster_atlas", CodexArcanum.mod.path, "ca_booster_atlas.png", 71, 95, "asset_atli"):register();
    SMODS.Booster:new("Alchemy Pack", "alchemy_normal_1", {extra = 2, choose = 1}, { x = 0, y = 0 }, 4, false, 1, "Celestial", "ca_booster_atlas"):register()
    SMODS.Booster:new("Alchemy Pack", "alchemy_normal_2", {extra = 2, choose = 1}, { x = 1, y = 0 }, 4, false, 1, "Celestial", "ca_booster_atlas"):register()
    SMODS.Booster:new("Alchemy Pack", "alchemy_normal_3", {extra = 2, choose = 1}, { x = 2, y = 0 }, 4, false, 1, "Celestial", "ca_booster_atlas"):register()
    SMODS.Booster:new("Alchemy Pack", "alchemy_normal_4", {extra = 2, choose = 1}, { x = 3, y = 0 }, 4, false, 1, "Celestial", "ca_booster_atlas"):register()
    SMODS.Booster:new("Jumbo Alchemy Pack", "alchemy_jumbo_1", {extra = 4, choose = 1}, { x = 0, y = 1 }, 4, false, 1, "Celestial", "ca_booster_atlas"):register()
    SMODS.Booster:new("Jumbo Alchemy Pack", "alchemy_jumbo_2", {extra = 4, choose = 1}, { x = 1, y = 1 }, 4, false, 1, "Celestial", "ca_booster_atlas"):register()
    SMODS.Booster:new("Mega Alchemy Pack", "alchemy_mega_1", {extra = 4, choose = 2}, { x = 2, y = 1 }, 4, false, 0.25, "Celestial", "ca_booster_atlas"):register()
end