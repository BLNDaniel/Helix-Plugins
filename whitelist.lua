local whitelist = {
    ["STEAM_0:1:455322465"] = true,
    -- Add More Ids with ["STEAMID"] = true,
}

local function checkWhitelist(ply)
    local steamid = ply:SteamID()
    if not whitelist[steamid] then
        ply:Kick("Your are not whitelisted.")
    end
end

hook.Add("PlayerInitialSpawn", "CheckWhitelist", checkWhitelist)
