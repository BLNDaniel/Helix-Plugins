PLUGIN.name = "Hunger System"
PLUGIN.author = "Danny.gg"
PLUGIN.description = "A system to add hunger to your RP Helix server"

local speed = 300
local decay = 1	

ix.config.Add("hungerDecaySpeed", speed, "Speed at which hunger should decay.", nil, {
	data = {min = 100, max = 600},
	category = "Hunger System"
})

ix.config.Add("hungerDecayAmount", decay, "Amount at which hunger should decay", nil, {
	data = {min = 0, max = 5},
	category = "Hunger System"
})

if SERVER then
	function PLUGIN:OnCharacterCreated(client, character)
		character:SetData("hunger", 100)
	end

	function PLUGIN:PlayerLoadedCharacter(client, character)
		timer.Simple(0.25, function()
			client:SetLocalVar("hunger", character:GetData("hunger", 100))
		end)
	end

	function PLUGIN:CharacterPreSave(character)
		local client = character:GetPlayer()

		if (IsValid(client)) then
			character:SetData("hunger", client:GetLocalVar("hunger", 0))
		end
	end

	local playerMeta = FindMetaTable("Player")

	function playerMeta:SetHunger(amount)
		local char = self:GetCharacter()

		if (char) then
			char:SetData("hunger", amount)
			self:SetLocalVar("hunger", amount)
		end
	end

	function playerMeta:TickHunger(amount)
		local char = self:GetCharacter()

		if (char) then
			char:SetData("hunger", char:GetData("hunger", 100) - amount)
			self:SetLocalVar("hunger", char:GetData("hunger", 100) - amount)

			if char:GetData("hunger", 100) < 0 then
				char:SetData("hunger", 0)
				self:SetLocalVar("hunger", 0)
			end
		end
	end

	function PLUGIN:PlayerTick(ply)
		if ply:GetNetVar("hungertick", 0) <= CurTime() then
			ply:SetNetVar("hungertick", ix.config.Get("hunger_decay_speed", 300) + CurTime())
			ply:TickHunger(ix.config.Get("hunger_decay_amount", 1))
		end
	end
else
	ix.bar.Add(function()
		local status = ""
		local var = LocalPlayer():GetLocalVar("hunger", 0) / 100

		if var < 0.2 then
			status = "Starving"
		elseif var < 0.4 then
			status = "Hungry"
		elseif var < 0.6 then
			status = "Grumbling"
		elseif var < 0.8 then
			status = ""
		end

		return var, status
	end, Color(200, 200, 40), nil, "hunger")
end

local playerMeta = FindMetaTable("Player")

function playerMeta:GetHunger()
	local char = self:GetCharacter()

	if (char) then
		return char:GetData("hunger", 100)
	end
end

function PLUGIN:AdjustStaminaOffset(client, offset)
	if client:GetHunger() < 15 then
		return -1
	end
end

local hunger_items = {
	["melon"] = {
		["name"] = "Melon",
		["model"] = "models/props_junk/watermelon01.mdl",
		["desc"] = "A freshly grown watermelon, presumably by the Railroad.",
		["illegal"] = true,
		["hunger"] = 40,
		["width"] = 2,
		["height"] = 2
	},
	["bleach"] = {
		["name"] = "Bleach",
		["model"] = "models/props_junk/garbage_plasticbottle001a.mdl",
		["desc"] = "A bottle of bleach, a common houseware product, this is a non-flammable production unit, still. Drinking it isn't a good idea.",
		["hunger"] = -50
	}
}

for k, v in pairs(hunger_items) do
	local ITEM = ix.item.Register(k, nil, false, nil, true)
	ITEM.name = v.name
	ITEM.description = v.desc
	ITEM.model = v.model
	ITEM.width = v.width or 1
	ITEM.height = v.height or 1
	ITEM.category = "Survival"
	ITEM.hunger = v.hunger or 0
	ITEM.empty = v.empty or false
	function ITEM:GetDescription()
		return self.description
	end
	ITEM.functions.Consume = {
		name = "Consume",
		OnCanRun = function(item)
			if item.hunger != 0 then
				if item.player:GetCharacter():GetData("hunger", 100) >= 100 then
					return false
				end
			end
		end,
		OnRun = function(item)
			local hunger = item.player:GetCharacter():GetData("hunger", 100)
			item.player:SetHunger(hunger + item.hunger)
			item.player:EmitSound("physics/flesh/flesh_impact_hard6.wav")
			if item.empty then
				local inv = item.player:GetCharacter():GetInventory()
				inv:Add(item.empty)
			end
		end
	}
end