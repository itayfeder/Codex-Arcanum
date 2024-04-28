------------------------------------
-- ALCHEMICALS API
------------------------------------

CodexArcanum.Alchemicals = {}
CodexArcanum.Alchemical = {
    name = "",
    slug = "",
    cost = 3,
    config = {},
    pos = {},
    loc_txt = {},
	unlocked = true,
    discovered = false, 
    consumeable = true,
	unlock_condition = {}
}

function CodexArcanum.Alchemical:new(name, slug, config, pos, loc_txt, cost, discovered, unlocked, unlock_condition, atlas)
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
  o.unlocked = unlocked
  o.consumeable = true
  o.unlock_condition = unlock_condition or {}
  o.atlas = atlas or "alchemical_atlas"
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
		unlocked = self.unlocked,
		consumeable = true,
		name = self.name,
		set = "Alchemical",
		order = id,
		key = self.slug,
		pos = self.pos,
    	cost = self.cost,
		config = self.config,
		unlock_condition = self.unlock_condition,
		atlas = self.atlas
	}

	for _i, sprite in ipairs(SMODS.Sprites) do
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

------------------------------------

function CodexArcanum.INIT.AlchemicalAPI()
    
end