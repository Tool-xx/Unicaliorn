-- Utils/Helpers.lua
-- Shared helper functions used across Features and Tabs
-- ESP box, hitbox, health bar, name, distance, gradient color system
-- Receives Context, populates Context.Utils

return function(Context)
    local TweenService = Context.Services.TweenService
    local RunService = Context.Services.RunService
    local Players = Context.Services.Players
    local Config = Context.Config
    local COLORS = Config.COLORS
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer

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

    function Utils.getCurrentGradientColor()
        return getGradientColor()
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
                if data.nameLabel then
                    data.nameLabel.TextColor3 = color
                end
                if data.distanceLabel then
                    data.distanceLabel.TextColor3 = color
                end
                if data.healthText then
                    data.healthText.TextColor3 = color
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
    -- CREATE BOX (rectangle using BillboardGui with Frame lines)
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

        local top = Instance.new("Frame")
        top.Name = "Top"
        top.Size = UDim2.new(1, 0, 0, 2)
        top.Position = UDim2.new(0, 0, 0, 0)
        top.BackgroundColor3 = color
        top.BorderSizePixel = 0
        top.Parent = billboard

        local bottom = Instance.new("Frame")
        bottom.Name = "Bottom"
        bottom.Size = UDim2.new(1, 0, 0, 2)
        bottom.Position = UDim2.new(0, 0, 1, -2)
        bottom.BackgroundColor3 = color
        bottom.BorderSizePixel = 0
        bottom.Parent = billboard

        local left = Instance.new("Frame")
        left.Name = "Left"
        left.Size = UDim2.new(0, 2, 1, 0)
        left.Position = UDim2.new(0, 0, 0, 0)
        left.BackgroundColor3 = color
        left.BorderSizePixel = 0
        left.Parent = billboard

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
    -- CREATE HEALTH BAR (left side, close to box)
    -- ============================================================
    local function createHealthBar(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return nil, nil end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPHealth"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 40, 0, 100)
        billboard.StudsOffset = Vector3.new(-2.2, 0, 0) -- Close left side
        billboard.Adornee = hrp
        billboard.Parent = char

        -- Background (red - missing health)
        local bg = Instance.new("Frame")
        bg.Name = "Background"
        bg.Size = UDim2.new(0, 6, 1, 0)
        bg.Position = UDim2.new(0.5, -3, 0, 0)
        bg.BackgroundColor3 = COLORS.HealthRed
        bg.BorderSizePixel = 1
        bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        bg.Parent = billboard

        -- Fill (green - current health)
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new(0, 6, 1, 0)
        fill.Position = UDim2.new(0.5, -3, 0, 0)
        fill.BackgroundColor3 = COLORS.HealthGreen
        fill.BorderSizePixel = 0
        fill.Parent = billboard

        -- Health text (next to bar, clearly visible)
        local healthText = Instance.new("TextLabel")
        healthText.Name = "HealthText"
        healthText.Size = UDim2.new(0, 40, 0, 14)
        healthText.Position = UDim2.new(0.5, -20, 0, -16)
        healthText.BackgroundTransparency = 1
        healthText.Text = tostring(math.floor(hum.Health))
        healthText.TextColor3 = getGradientColor()
        healthText.TextSize = 12
        healthText.Font = Enum.Font.GothamBold
        healthText.TextStrokeTransparency = 0
        healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthText.Parent = billboard

        return billboard, healthText
    end

    -- ============================================================
    -- CREATE NAME LABEL (lower above head, not too high)
    -- ============================================================
    local function createNameLabel(char, playerName)
        local head = char:FindFirstChild("Head")
        if not head then return nil end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPName"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 24)
        billboard.StudsOffset = Vector3.new(0, 2.2, 0) -- Lower above head
        billboard.Adornee = head
        billboard.Parent = char

        local label = Instance.new("TextLabel")
        label.Name = "NameLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = playerName
        label.TextColor3 = getGradientColor()
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = billboard

        return billboard, label
    end

    -- ============================================================
    -- CREATE DISTANCE LABEL (just below box)
    -- ============================================================
    local function createDistanceLabel(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPDistance"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 100, 0, 18)
        billboard.StudsOffset = Vector3.new(0, -2.8, 0) -- Just below box
        billboard.Adornee = hrp
        billboard.Parent = char

        local label = Instance.new("TextLabel")
        label.Name = "DistanceLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "0m"
        label.TextColor3 = getGradientColor()
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = billboard

        return billboard, label
    end

    -- ============================================================
    -- UPDATE HEALTH BAR
    -- ============================================================
    local function updateHealthBar(data, hum)
        if not data or not data.healthBar or not hum then return end
        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local fill = data.healthBar:FindFirstChild("Fill", true)
        if fill then
            fill.Size = UDim2.new(0, 6, healthPercent, 0)
            fill.Position = UDim2.new(0.5, -3, 1 - healthPercent, 0)
        end
        if data.healthText then
            data.healthText.Text = tostring(math.floor(hum.Health))
        end
    end

    -- ============================================================
    -- UPDATE DISTANCE
    -- ============================================================
    local function updateDistance(data, player)
        if not data or not data.distanceLabel then return end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local theirChar = player.Character
        local theirRoot = theirChar and theirChar:FindFirstChild("HumanoidRootPart")
        if myRoot and theirRoot then
            local dist = (myRoot.Position - theirRoot.Position).Magnitude
            data.distanceLabel.Text = string.format("%.0fm", dist)
        else
            data.distanceLabel.Text = "?"
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
        if data.healthBar then data.healthBar:Destroy() end
        if data.nameLabel then
            local parent = data.nameLabel.Parent
            if parent then parent:Destroy() end
        end
        if data.distanceLabel then
            local parent = data.distanceLabel.Parent
            if parent then parent:Destroy() end
        end
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
        local box, hitbox, healthBar, healthText, nameBillboard, nameLabel, distBillboard, distanceLabel

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

        if FeatureState.espHealthEnabled then
            healthBar, healthText = createHealthBar(char)
        end

        if FeatureState.espNameEnabled then
            nameBillboard, nameLabel = createNameLabel(char, player.Name)
        end

        if FeatureState.espDistanceEnabled then
            distBillboard, distanceLabel = createDistanceLabel(char)
        end

        FeatureState.espHighlights[player] = {
            box = box,
            hitbox = hitbox,
            healthBar = healthBar,
            healthText = healthText,
            nameLabel = nameLabel,
            distanceLabel = distanceLabel,
        }
    end

    -- ============================================================
    -- UPDATE LOOP (health bars + distances)
    -- ============================================================
    local updateConnection = nil
    local function startUpdateLoop()
        if updateConnection then return end
        updateConnection = RunService.Heartbeat:Connect(function()
            if not FeatureState.espEnabled then return end
            for player, data in pairs(FeatureState.espHighlights) do
                if player and player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if FeatureState.espHealthEnabled then
                        updateHealthBar(data, hum)
                    end
                    if FeatureState.espDistanceEnabled then
                        updateDistance(data, player)
                    end
                end
            end
        end)
    end

    local function stopUpdateLoop()
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
    end

    -- ============================================================
    -- SET BOX ENABLED
    -- ============================================================
    function Utils.setBoxEnabled(enabled)
        FeatureState.espBoxEnabled = enabled
        if FeatureState.espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
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
            for _, player in ipairs(Players:GetPlayers()) do
                Utils.removeESP(player)
                Utils.createESP(player)
            end
        end
    end

    -- ============================================================
    -- SET HEALTH ESP ENABLED
    -- ============================================================
    function Utils.setHealthEnabled(enabled)
        FeatureState.espHealthEnabled = enabled
        if FeatureState.espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                Utils.removeESP(player)
                Utils.createESP(player)
            end
        end
    end

    -- ============================================================
    -- SET NAME ESP ENABLED
    -- ============================================================
    function Utils.setNameEnabled(enabled)
        FeatureState.espNameEnabled = enabled
        if FeatureState.espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                Utils.removeESP(player)
                Utils.createESP(player)
            end
        end
    end

    -- ============================================================
    -- SET DISTANCE ESP ENABLED
    -- ============================================================
    function Utils.setDistanceEnabled(enabled)
        FeatureState.espDistanceEnabled = enabled
        if FeatureState.espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
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
        startUpdateLoop()

        for _, player in ipairs(Players:GetPlayers()) do
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
            FeatureState.espPlayerAddedConn = Players.PlayerAdded:Connect(function(player)
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
        stopUpdateLoop()

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
    print("[Helpers] Utils registered with full ESP suite.")
end
