-- Utils/Helpers.lua
-- Shared helper functions used across Features and Tabs
-- ESP skeleton, color updates, safe operations
-- Receives Context, populates Context.Utils

return function(Context)
    local TweenService = Context.Services.TweenService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local FeatureState = Context.FeatureState

    local Utils = {}

    -- ============================================================
    -- CREATE SKELETON BEAMS
    -- ============================================================
    function Utils.createSkeleton(char, color)
        local beams = {}
        for _, bone in ipairs(Config.SKELETON_BONES) do
            local part0 = char:FindFirstChild(bone[1])
            local part1 = char:FindFirstChild(bone[2])
            if part0 and part1 and part0:IsA("BasePart") and part1:IsA("BasePart") then
                local attach0 = Instance.new("Attachment", part0)
                local attach1 = Instance.new("Attachment", part1)
                local beam = Instance.new("Beam")
                beam.Attachment0 = attach0
                beam.Attachment1 = attach1
                beam.Color = ColorSequence.new(color)
                beam.Width0 = 0.05
                beam.Width1 = 0.05
                beam.Parent = char
                table.insert(beams, beam)
            end
        end
        return beams
    end

    -- ============================================================
    -- DESTROY SKELETON BEAMS
    -- ============================================================
    function Utils.destroySkeleton(beams)
        for _, beam in ipairs(beams) do
            if beam then
                if beam.Attachment0 then beam.Attachment0:Destroy() end
                if beam.Attachment1 then beam.Attachment1:Destroy() end
                beam:Destroy()
            end
        end
    end

    -- ============================================================
    -- REMOVE ESP FOR PLAYER
    -- ============================================================
    function Utils.removeESP(player)
        local data = FeatureState.espHighlights[player]
        if not data then return end
        if data.box then data.box:Destroy() end
        if data.hitbox then data.hitbox:Destroy() end
        if data.skeleton then Utils.destroySkeleton(data.skeleton) end
        FeatureState.espHighlights[player] = nil
    end

    -- ============================================================
    -- CREATE ESP FOR PLAYER
    -- ============================================================
    function Utils.createESP(player)
        Utils.removeESP(player)
        if not FeatureState.espEnabled then return end
        local char = player.Character
        if not char then return end

        local box, hitbox, skeleton

        if FeatureState.espBoxEnabled then
            box = Instance.new("Highlight")
            box.Adornee = char
            box.FillTransparency = 1
            box.OutlineTransparency = 0
            box.FillColor = FeatureState.espBoxColor
            box.OutlineColor = FeatureState.espBoxColor
            box.Parent = char
        end

        if FeatureState.espHitboxEnabled then
            hitbox = Instance.new("Highlight")
            hitbox.Adornee = char
            hitbox.FillTransparency = 0.3
            hitbox.OutlineTransparency = 1
            hitbox.FillColor = FeatureState.espHitboxColor
            hitbox.Parent = char
        end

        if FeatureState.espSkeletonEnabled then
            skeleton = Utils.createSkeleton(char, FeatureState.espSkeletonColor)
        end

        FeatureState.espHighlights[player] = {box = box, hitbox = hitbox, skeleton = skeleton}
    end

    -- ============================================================
    -- UPDATE ALL BOX COLORS
    -- ============================================================
    function Utils.updateAllBoxColor(color)
        for _, data in pairs(FeatureState.espHighlights) do
            if data.box then
                data.box.FillColor = color
                data.box.OutlineColor = color
            end
        end
    end

    -- ============================================================
    -- UPDATE ALL HITBOX COLORS
    -- ============================================================
    function Utils.updateAllHitboxColor(color)
        for _, data in pairs(FeatureState.espHighlights) do
            if data.hitbox then
                data.hitbox.FillColor = color
            end
        end
    end

    -- ============================================================
    -- UPDATE ALL SKELETON COLORS
    -- ============================================================
    function Utils.updateAllSkeletonColor(color)
        for _, data in pairs(FeatureState.espHighlights) do
            if data.skeleton then
                for _, beam in ipairs(data.skeleton) do
                    beam.Color = ColorSequence.new(color)
                end
            end
        end
    end

    -- ============================================================
    -- SET BOX ENABLED (recreate ESP for all)
    -- ============================================================
    function Utils.setBoxEnabled(enabled)
        FeatureState.espBoxEnabled = enabled
        if FeatureState.espEnabled then
            for _, player in ipairs(Context.Services.Players:GetPlayers()) do
                Utils.removeESP(player)
                Utils.createESP(player)
            end
        end
    end

    -- ============================================================
    -- SET HITBOX ENABLED
    -- ============================================================
    function Utils.setHitboxEnabled(enabled)
        FeatureState.espHitboxEnabled = enabled
        if FeatureState.espEnabled then
            for _, player in ipairs(Context.Services.Players:GetPlayers()) do
                Utils.removeESP(player)
                Utils.createESP(player)
            end
        end
    end

    -- ============================================================
    -- SET SKELETON ENABLED
    -- ============================================================
    function Utils.setSkeletonEnabled(enabled)
        FeatureState.espSkeletonEnabled = enabled
        if FeatureState.espEnabled then
            for _, player in ipairs(Context.Services.Players:GetPlayers()) do
                Utils.removeESP(player)
                Utils.createESP(player)
            end
        end
    end

    -- ============================================================
    -- SET BOX COLOR
    -- ============================================================
    function Utils.setBoxColor(r, g, b)
        FeatureState.espBoxColor = Color3.fromRGB(r, g, b)
        Utils.updateAllBoxColor(FeatureState.espBoxColor)
    end

    -- ============================================================
    -- SET HITBOX COLOR
    -- ============================================================
    function Utils.setHitboxColor(r, g, b)
        FeatureState.espHitboxColor = Color3.fromRGB(r, g, b)
        Utils.updateAllHitboxColor(FeatureState.espHitboxColor)
    end

    -- ============================================================
    -- SET SKELETON COLOR
    -- ============================================================
    function Utils.setSkeletonColor(r, g, b)
        FeatureState.espSkeletonColor = Color3.fromRGB(r, g, b)
        Utils.updateAllSkeletonColor(FeatureState.espSkeletonColor)
    end

    -- ============================================================
    -- ENABLE ESP (global)
    -- ============================================================
    function Utils.enableESP()
        if FeatureState.espEnabled then return end
        FeatureState.espEnabled = true
        print("[ESP] Enabled")

        for _, player in ipairs(Context.Services.Players:GetPlayers()) do
            Utils.createESP(player)
            if not FeatureState.espCharacterAddedConns[player] then
                FeatureState.espCharacterAddedConns[player] = player.CharacterAdded:Connect(function(char)
                    if FeatureState.espEnabled then
                        Utils.createESP(player)
                    end
                end)
            end
        end

        if not FeatureState.espPlayerAddedConn then
            FeatureState.espPlayerAddedConn = Context.Services.Players.PlayerAdded:Connect(function(player)
                if FeatureState.espEnabled then
                    Utils.createESP(player)
                    if not FeatureState.espCharacterAddedConns[player] then
                        FeatureState.espCharacterAddedConns[player] = player.CharacterAdded:Connect(function(char)
                            if FeatureState.espEnabled then
                                Utils.createESP(player)
                            end
                        end)
                    end
                end
            end)
        end
    end

    -- ============================================================
    -- DISABLE ESP (global)
    -- ============================================================
    function Utils.disableESP()
        if not FeatureState.espEnabled then return end
        FeatureState.espEnabled = false
        print("[ESP] Disabled")

        if FeatureState.espPlayerAddedConn then
            FeatureState.espPlayerAddedConn:Disconnect()
            FeatureState.espPlayerAddedConn = nil
        end

        for _, conn in pairs(FeatureState.espCharacterAddedConns) do
            conn:Disconnect()
        end
        FeatureState.espCharacterAddedConns = {}

        for player in pairs(FeatureState.espHighlights) do
            Utils.removeESP(player)
        end
    end

    -- ============================================================
    -- INIT ESP COLORS FROM CONFIG
    -- ============================================================
    function Utils.initESPColors()
        FeatureState.espBoxColor = Config.ESP.BoxColor
        FeatureState.espHitboxColor = Config.ESP.HitboxColor
        FeatureState.espSkeletonColor = Config.ESP.SkeletonColor
    end

    -- Initialize colors immediately
    Utils.initESPColors()

    -- Register in Context
    Context.Utils = Utils
    print("[Helpers] Utils registered.")
end
