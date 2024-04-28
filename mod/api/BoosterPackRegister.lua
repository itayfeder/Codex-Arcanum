------------------------------------
-- BOOSTER API
------------------------------------

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

	sendDebugMessage("The Booster named " .. self.name .. " with the slug " .. self.slug ..
						 " have been registered at the id " .. id .. ".")
end

------------------------------------

function CodexArcanum.INIT.BoosterPackRegister()
    
end