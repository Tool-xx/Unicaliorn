-- Tabs/Visual.lua
-- Visual tab: ESP toggle + toggles for Box, Hitbox, Health, Name, Distance, BoostFPS
-- All ESP uses dynamic neon green gradient (no color selection)
-- Receives Context, returns tab content frame

return function(Context)
    local TweenService = Context.Services.TweenService
    local RunService = Context.Services.RunService
    local Lighting = game:GetService("Lighting")
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local Components = Context.UI.Components
    local FeatureState = Context.FeatureState

    -- ============================================================
    -- CREATE CONTENT
    -- ============================================================
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_Visual"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.Border
    content.CanvasSize = UDim2.new(0, 0, 0, 380)
    content.Visible = false
    content.Parent = Context.UI.ContentFrame

    -- ============================================================
    -- ESP HEADER (main toggle + settings expand)
    -- ============================================================
    local espHeader = Instance.new("Frame")
    espHeader.Name = "ESPHeader"
    espHeader.Size = UDim2.new(1, -20, 0, 30)
    espHeader.Position = UDim2.new(0, 10, 0, 10)
    espHeader.BackgroundColor3 = COLORS.Background
    espHeader.BorderSizePixel = 0
    espHeader.Parent = content

    local espLabel = Instance.new("TextLabel")
    espLabel.Size = UDim2.new(1, -60, 1, 0)
    espLabel.Position = UDim2.new(0, 5, 0, 0)
    espLabel.BackgroundTransparency = 1
    espLabel.Text = "ESP"
    espLabel.TextColor3 = COLORS.Text
    espLabel.TextSize = 14
    espLabel.Font = Enum.Font.Gotham
    espLabel.TextXAlignment = Enum.TextXAlignment.Left
    espLabel.Parent = espHeader

    -- ESP Toggle BG
    local espToggleBg = Instance.new("TextButton")
    espToggleBg.Size = UDim2.new(0, 50, 0, 22)
    espToggleBg.Position = UDim2.new(1, -55, 0.5, -11)
    espToggleBg.BackgroundColor3 = COLORS.ToggleOff
    espToggleBg.BorderSizePixel = 1
    espToggleBg.BorderColor3 = COLORS.Border
    espToggleBg.Text = ""
    espToggleBg.AutoButtonColor = false
    espToggleBg.Parent = espHeader

    local espToggleKnob = Instance.new("Frame")
    espToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    espToggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
    espToggleKnob.BackgroundColor3 = COLORS.Text
    espToggleKnob.BorderSizePixel = 0
    espToggleKnob.Parent = espToggleBg

    -- Settings Toggle Button (▼/▲)
    local settingsToggleBtn = Instance.new("TextButton")
    settingsToggleBtn.Name = "SettingsToggle"
    settingsToggleBtn.Size = UDim2.new(0, 30, 0, 22)
    settingsToggleBtn.Position = UDim2.new(1, -90, 0.5, -11)
    settingsToggleBtn.BackgroundColor3 = COLORS.Background
    settingsToggleBtn.BorderSizePixel = 1
    settingsToggleBtn.BorderColor3 = COLORS.Border
    settingsToggleBtn.Text = "▼"
    settingsToggleBtn.TextColor3 = COLORS.Text
    settingsToggleBtn.TextSize = 12
    settingsToggleBtn.Font = Enum.Font.GothamBold
    settingsToggleBtn.AutoButtonColor = false
    settingsToggleBtn.Parent = espHeader

    -- ESP Toggle Logic
    local espToggleEnabled = false
    espToggleBg.MouseButton1Click:Connect(function()
        espToggleEnabled = not espToggleEnabled
        if espToggleEnabled then
            TweenService:Create(espToggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOn}):Play()
            TweenService:Create(espToggleKnob, TWEEN.Hover, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            if Context.Features.ESP then
                Context.Features.ESP.Enable()
            end
        else
            TweenService:Create(espToggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOff}):Play()
            TweenService:Create(espToggleKnob, TWEEN.Hover, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            if Context.Features.ESP then
                Context.Features.ESP.Disable()
            end
        end
    end)

    -- Sync with current state
    if FeatureState.espEnabled then
        espToggleEnabled = true
        espToggleBg.BackgroundColor3 = COLORS.ToggleOn
        espToggleKnob.Position = UDim2.new(1, -20, 0.5, -9)
    end

    -- Settings Frame (collapsible)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "ESP_Settings"
    settingsFrame.Size = UDim2.new(1, -20, 0, 0)
    settingsFrame.Position = UDim2.new(0, 10, 0, 45)
    settingsFrame.BackgroundColor3 = COLORS.Background
    settingsFrame.BorderSizePixel = 1
    settingsFrame.BorderColor3 = COLORS.Border
    settingsFrame.ClipsDescendants = true
    settingsFrame.Visible = true
    settingsFrame.Parent = content

    local settingsOpen = false
    local targetHeight = 230

    settingsToggleBtn.MouseButton1Click:Connect(function()
        settingsOpen = not settingsOpen
        if settingsOpen then
            settingsToggleBtn.Text = "▲"
            TweenService:Create(settingsFrame, TWEEN.Open, {Size = UDim2.new(1, -20, 0, targetHeight)}):Play()
        else
            settingsToggleBtn.Text = "▼"
            TweenService:Create(settingsFrame, TWEEN.Close, {Size = UDim2.new(1, -20, 0, 0)}):Play()
        end
    end)

    -- ============================================================
    -- ESP SUB-TOGGLES
    -- ============================================================
    local yOffset = 10

    -- Box Toggle
    local boxToggle = Components.createToggle(settingsFrame, "Box", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableBox()
            else
                Context.Features.ESP.DisableBox()
            end
        end
    end)
    if FeatureState.espBoxEnabled then
        boxToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    -- Hitbox Toggle
    local hitboxToggle = Components.createToggle(settingsFrame, "Hitbox", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableHitbox()
            else
                Context.Features.ESP.DisableHitbox()
            end
        end
    end)
    if FeatureState.espHitboxEnabled then
        hitboxToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    -- Health Bar Toggle
    local healthToggle = Components.createToggle(settingsFrame, "Health Bar", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableHealth()
            else
                Context.Features.ESP.DisableHealth()
            end
        end
    end)
    if FeatureState.espHealthEnabled then
        healthToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    -- Name Toggle
    local nameToggle = Components.createToggle(settingsFrame, "Name", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableName()
            else
                Context.Features.ESP.DisableName()
            end
        end
    end)
    if FeatureState.espNameEnabled then
        nameToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    -- Distance Toggle
    local distanceToggle = Components.createToggle(settingsFrame, "Distance", yOffset, function(enabled)
        if Context.Features.ESP then
            if enabled then
                Context.Features.ESP.EnableDistance()
            else
                Context.Features.ESP.DisableDistance()
            end
        end
    end)
    if FeatureState.espDistanceEnabled then
        distanceToggle.setEnabled(true)
    end
    yOffset = yOffset + 40

    targetHeight = yOffset + 10
    settingsFrame.Size = UDim2.new(1, -20, 0, 0)

    -- ============================================================
    -- BOOST FPS SECTION
    -- ============================================================
    local boostSep = Instance.new("Frame")
    boostSep.Size = UDim2.new(1, -20, 0, 1)
    boostSep.Position = UDim2.new(0, 10, 0, 260)
    boostSep.BackgroundColor3 = COLORS.Border
    boostSep.BorderSizePixel = 0
    boostSep.Parent = content

    local boostLabel = Instance.new("TextLabel")
    boostLabel.Size = UDim2.new(1, -20, 0, 20)
    boostLabel.Position = UDim2.new(0, 10, 0, 270)
    boostLabel.BackgroundTransparency = 1
    boostLabel.Text = "Performance"
    boostLabel.TextColor3 = COLORS.Text
    boostLabel.TextSize = 14
    boostLabel.Font = Enum.Font.GothamBold
    boostLabel.TextXAlignment = Enum.TextXAlignment.Left
    boostLabel.Parent = content

    -- Store original values for restore
    local originalSettings = {}
    local boostActive = false
    local boostConnection = nil

    local function saveOriginalSettings()
        originalSettings = {
            waterWaveSize = workspace.Terrain.WaterWaveSize,
            waterWaveSpeed = workspace.Terrain.WaterWaveSpeed,
            waterReflectance = workspace.Terrain.WaterReflectance,
            waterTransparency = workspace.Terrain.WaterTransparency,
            globalShadows = Lighting.GlobalShadows,
            fogEnd = Lighting.FogEnd,
            fogStart = Lighting.FogStart,
            qualityLevel = settings().Rendering.QualityLevel,
            parts = {},
            decals = {},
            emitters = {},
            postEffects = {},
        }
    end

    local function applyBoostFPS()
        if boostActive then return end
        boostActive = true
        print("[BoostFPS] Enabled")

        saveOriginalSettings()

        local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9

        pcall(function()
            settings().Rendering.QualityLevel = 1
        end)

        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                originalSettings.parts[v] = {
                    castShadow = v.CastShadow,
                    material = v.Material,
                    reflectance = v.Reflectance,
                }
                v.CastShadow = false
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                originalSettings.decals[v] = v.Transparency
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                originalSettings.emitters[v] = v.Lifetime
                v.Lifetime = NumberRange.new(0)
            end
        end

        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") then
                originalSettings.postEffects[v] = v.Enabled
                v.Enabled = false
            end
        end

        -- Auto-destroy new effects
        boostConnection = workspace.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                    RunService.Heartbeat:Wait()
                    if boostActive then
                        child:Destroy()
                    end
                elseif child:IsA("BasePart") then
                    child.CastShadow = false
                end
            end)
        end)
    end

    local function restoreFPS()
        if not boostActive then return end
        boostActive = false
        print("[BoostFPS] Disabled")

        if boostConnection then
            boostConnection:Disconnect()
            boostConnection = nil
        end

        local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = originalSettings.waterWaveSize or 0.15
            Terrain.WaterWaveSpeed = originalSettings.waterWaveSpeed or 10
            Terrain.WaterReflectance = originalSettings.waterReflectance or 1
            Terrain.WaterTransparency = originalSettings.waterTransparency or 0.3
        end

        Lighting.GlobalShadows = originalSettings.globalShadows ~= false
        Lighting.FogEnd = originalSettings.fogEnd or 100000
        Lighting.FogStart = originalSettings.fogStart or 0

        pcall(function()
            settings().Rendering.QualityLevel = originalSettings.qualityLevel or 7
        end)

        for part, saved in pairs(originalSettings.parts) do
            if part and part.Parent then
                part.CastShadow = saved.castShadow
                part.Material = saved.material
                part.Reflectance = saved.reflectance
            end
        end

        for decal, savedTransparency in pairs(originalSettings.decals) do
            if decal and decal.Parent then
                decal.Transparency = savedTransparency
            end
        end

        for emitter, savedLifetime in pairs(originalSettings.emitters) do
            if emitter and emitter.Parent then
                emitter.Lifetime = savedLifetime
            end
        end

        for effect, savedEnabled in pairs(originalSettings.postEffects) do
            if effect and effect.Parent then
                effect.Enabled = savedEnabled
            end
        end

        originalSettings = {}
    end

    -- BoostFPS Toggle
    local boostToggle = Components.createToggle(content, "Boost FPS", 300, function(enabled)
        if enabled then
            applyBoostFPS()
        else
            restoreFPS()
        end
    end)

    -- Register tab
    Context.UI.Main.registerTabContent("Visual", content)

    print("[Tab] Visual loaded (full ESP suite + BoostFPS).")
    return content
end
