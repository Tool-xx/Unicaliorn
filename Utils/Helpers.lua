-- Utils/Helpers.lua
-- Shared helper functions used across Features and Tabs
-- ESP skeleton, gradient color system, safe operations
-- Receives Context, populates Context.Utils

return function(Context)
    local TweenService = Context.Services.TweenService
    local RunService = Context.Services.RunService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local FeatureState = Context.FeatureState

    local Utils = {}

    -- ============================================================
    -- GRADIENT COLOR SYSTEM
    -- ============================================================
    local gradientConnection = nil
    local gradientTime = 0

    local function lerpColor3(a, b, t)
        return Color3.new(
            a.R + (b.R - a.R) * t,
            a.G + (b.G - a.G) * t,
            a.B + (b.B - a.B) * t
        )
    end

    local function getGradientColor()
        local speed = Config.ESP.GradientSpeed
        local c1 = Config.ESP.GradientColor1
        local c2 = Config.ESP.GradientColor2
        local t = (math.sin(gradientTime * math.pi * 2 / speed) + 1) / 2
        return lerpColor3(c1, c2, t)
    end

    function Utils.startGradientCycle()
        if gradientConnection then return end
        gradientConnection = RunService.Heartbeat:Connect(function(dt)
            gradientTime = gradientTime + dt
            local color = getGradientColor()
            for _, data in pairs(FeatureState.espHighlights) do
                if data.box then
                    data.box.Color = color
                end
                if data.hitbox then
                    data.hitbox.FillColor = color
                end
                if data.skeleton then
                    for _, beam in ipairs(data.skeleton) do
                        beam.Color = ColorSequence.new(color)
                    end
                end
            end
        end)
    end

    function Utils.stopGradientCycle()
        if gradientConnection then
            gradientConnection:Disconnect()
            gradientConnection = nil
        end
    end

    -- ============================================================
    -- CREATE BOX (rectangle using 4 LineHandles or Frame approach)
    -- Using BillboardGui with Frame corners for a clean rectangle
    -- ============================================================
    local function createBoxFrame(char, color)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBox"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 100, 0, 200)
        billboard.StudsOffset = Vector3.new(0, 0, 0)
        billboard.Adornee = hrp
        billboard.Parent = char

        -- Top line
        local top = Instance.new("Frame")
        top.Name = "Top"
        top.Size = UDim2.new(1, 0, 0, 2)
        top.Position = UDim2.new(0, 0, 0, 0)
        top.BackgroundColor3 = color
        top.BorderSizePixel = 0
        top.Parent = billboard

        -- Bottom line
        local bottom = Instance.new("Frame")
        bottom.Name = "Bottom"
        bottom.Size = UDim2.new(1, 0, 0, 2)
        bottom.Position = UDim2.new(0, 0, 1, -2)
        bottom.BackgroundColor3 = color
        bottom.BorderSizePixel = 0
        bottom.Parent = billboard

        -- Left line
        local left = Instance.new("Frame")
        left.Name = "Left"
        left.Size = UDim2.new(0, 2, 1, 0)
        left.Position = UDim2.new(0, 0, 0, 0)
        left.BackgroundColor3 = color
        left.BorderSizePixel = 0
        left.Parent = billboard

        -- Right line
        local right = Instance.new("Frame")
        right.Name = "Right"
        right.Size = UDim2.new(0, 2, 1, 0)
        right.Position = UDim2.new(1, -2, 0, 0)
        right.BackgroundColor3 = color
        right.BorderSizePixel = 0
        right.Parent = billboard

        return billboard
    end

    -- ============================================================
    -- CREATE SKELETON BEAMS (thicker and more visible)
    -- ============================================================
    function Utils.createSkeleton(char)
        local currentColor = getGradientColor()
        local beams = {}
        for _, bone in ipairs(Config.SKELETON_BONES) do
            local part0 = char:FindFirstChild(bone[1])
            local part1 = char:FindFirstChild(bone[2])
            if part0 and part1 and part0:IsA("BasePart") and part1:IsA("BasePart") then
                local attach0 = Instance.new("Attachment")
                attach0.Name = "SkelA_" .. bone[1]
                attach0.Parent = part0
                local attach1 = Instance.new("Attachment")
                attach1.Name = "SkelA_" .. bone[2]
                attach1.Parent = part1
                local beam = Instance.new("Beam")
                beam.Name = "SkelBeam_" .. bone[1] .. "_" .. bone[2]
                beam.Attachment0 = attach0
                beam.Attachment1 = attach1
                beam.Color = ColorSequence.new(currentColor)
                beam.Width0 = 0.15
                beam.Width1 = 0.15
                beam.FaceCamera = true
                beam.LightEmission = 1
                beam.LightInfluence = 0
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

        local currentColor = getGradientColor()
        local box, hitbox, skeleton

        if FeatureState.espBoxEnabled then
            box = createBoxFrame(char, currentColor)
        end

        if FeatureState.espHitboxEnabled then
            hitbox = Instance.new("Highlight")
            hitbox.Name = "ESPHitbox"
            hitbox.Adornee = char
            hitbox.FillTransparency = 0.3
            hitbox.OutlineTransparency = 1
            hitbox.FillColor = currentColor
            hitbox.Parent = char
        end

        if FeatureState.espSkeletonEnabled then
            skeleton = Utils.createSkeleton(char)
        end

        FeatureState.espHighlights[player] = {box = box, hitbox = hitbox, skeleton = skeleton}
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
    -- ENABLE ESP (global)
    -- ============================================================
    function Utils.enableESP()
        if FeatureState.espEnabled then return end
        FeatureState.espEnabled = true
        print("[ESP] Enabled")

        Utils.startGradientCycle()

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

        Utils.stopGradientCycle()

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
    -- INIT
    -- ============================================================
    function Utils.initESP()
        -- Gradient colors are computed on-the-fly
    end

    -- Register in Context
    Context.Utils = Utils
    print("[Helpers] Utils registered with neon green gradient ESP.")
end
