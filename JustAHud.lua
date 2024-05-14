if CLIENT then
    local scrw, scrh = ScrW(), ScrH()
    local barW = scrw * .06
    local barH = scrh * .031
    local spacing = scrw * .07 

    surface.CreateFont("jars_hud_indicators", {
        font = "Roboto",
        size = 25,
        weight = 400,
        antialias = true,
    })

    hook.Add("HUDPaint", "hogwarts_hud", function()
        local ply = LocalPlayer()
        local char = ply:GetCharacter()
        if not char then return end
        if not IsValid(ply) then return end
        if not ply:Alive() then return end
        if ply:GetNoDraw() then return end
        local hp = ply:Health()
        local hunger = math.ceil(ply:GetLocalVar("hunger", 0)) or 0
        local stamina = ply:GetLocalVar("stm", 0)
        local hpbarchange = barW * math.Clamp(hp / ply:GetMaxHealth(), 0, 1)
        local hungerbarchange = barW * math.Clamp(hunger / 100, 0, 1)
        local staminabarchange = barW * math.Clamp(stamina / 100, 0, 1)

        -- Lebensbalken
        draw.RoundedBox(8, scrw * .006, scrh * .958, scrw * .062, scrh * .034, Color(0, 0, 0, 200))
        draw.RoundedBox(8, scrw * .007, scrh * .96, hpbarchange, scrh * .031, Color(255, 0, 0)) -- Rot
        draw.SimpleText(hp, "jars_hud_indicators", scrw * .036, scrh * .975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Hungerbalken
        draw.RoundedBox(8, scrw * .006 + spacing, scrh * .958, scrw * .062, scrh * .034, Color(0, 0, 0, 200))
        draw.RoundedBox(8, scrw * .007 + spacing, scrh * .96, hungerbarchange, scrh * .031, Color(205, 133, 63)) -- Hellbraun

        -- Ausdauerbalken
        draw.RoundedBox(8, scrw * .006 + 2 * spacing, scrh * .958, scrw * .062, scrh * .034, Color(0, 0, 0, 200))
        draw.RoundedBox(8, scrw * .007 + 2 * spacing, scrh * .96, staminabarchange, scrh * .031, Color(255, 255, 0)) -- Gelb
        draw.SimpleText(math.floor(stamina), "jars_hud_indicators", scrw * .036 + 2 * spacing, scrh * .975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
end

function PLUGIN:ShouldHideBars()
    return true
end
