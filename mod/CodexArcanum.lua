--- STEAMODDED HEADER
--- MOD_NAME: Codex Arcanum
--- MOD_ID: CodexArcanum
--- MOD_AUTHOR: [itayfeder]
--- MOD_DESCRIPTION: Adds a new set of cards: Alchemy!
--- BADGE_COLOUR: C09D75
--- PRIORITY: -100
----------------------------------------------
------------MOD CODE -------------------------

G.C.SECONDARY_SET.Alchemy = HEX("C09D75")
G.P_CENTER_POOLS.Alchemical = {}
G.localization.descriptions.Alchemical = {}
G.localization.misc.dictionary["k_alchemical"] = "Alchemical"
G.localization.misc.dictionary["p_plus_alchemical"] = "+1 Alchemical"
G.localization.misc.dictionary["p_alchemy_plus_card"] = "+2 Cards"
G.localization.misc.dictionary["p_alchemy_plus_money"] = "+5 Dollars"
G.localization.misc.dictionary["p_alchemy_reduce_blind"] = "Reduce Blind"

CodexArcanum = {}
CodexArcanum.mod_id = 'CodexArcanum'
CodexArcanum.INIT = {}

local create_UIBox_your_collectionref = create_UIBox_your_collection
function create_UIBox_your_collection()
    local retval = create_UIBox_your_collectionref()
    table.insert(retval.nodes[1].nodes[1].nodes[1].nodes[1].nodes[4].nodes[2].nodes, UIBox_button({
        button = 'your_collection_alchemicals', label = { "Alchemical Cards" }, count = G.DISCOVER_TALLIES.alchemicals, minw = 4, id = 'your_collection_alchemicals', colour = G.C.SECONDARY_SET.Alchemy
    }))
    return retval
end

function SMODS.INIT.CodexArcanum()

	CodexArcanum.mod = SMODS.findModByID(CodexArcanum.mod_id)

  NFS.load(CodexArcanum.mod.path.."api/TagAPI.lua")()
  NFS.load(CodexArcanum.mod.path.."api/BoosterPackRegister.lua")()
  NFS.load(CodexArcanum.mod.path.."api/AlchemicalAPI.lua")()

  NFS.load(CodexArcanum.mod.path.."utils/CA_AlchemyUI.lua")()
  NFS.load(CodexArcanum.mod.path.."utils/CA_CardUtil.lua")()
  
  NFS.load(CodexArcanum.mod.path.."CA_Overrides.lua")()

  NFS.load(CodexArcanum.mod.path.."data/CA_Jokers.lua")()
  NFS.load(CodexArcanum.mod.path.."data/CA_Alchemicals.lua")()
  NFS.load(CodexArcanum.mod.path.."data/CA_BoosterPacks.lua")()
  NFS.load(CodexArcanum.mod.path.."data/CA_Others.lua")()


  for _, v in pairs(CodexArcanum.INIT) do
		if v and type(v) == 'function' then v() end
	end


  loc_colour("mult", nil)
  G.ARGS.LOC_COLOURS["alchemical"] = G.C.SECONDARY_SET.Alchemy

  SMODS.LOAD_LOC()
  SMODS.SAVE_UNLOCKS()
  ALCHEMICAL_SAVE_UNLOCKS()
  save_tags()

end

----------------------------------------------
------------MOD CODE END----------------------
