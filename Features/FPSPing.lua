-- Features/FPSPing.lua
-- FPS and Ping counter windows
-- Receives Context, returns Feature table

return function(Context)
    local RunService = Context.Services.RunService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local FeatureState = Context.FeatureState
    local Components = Context.UI.Components

    local FPSPing = {}

    -- ============================================================
    -- CREATE FPS WINDOW
    -- ============================================================
    function FPSPing.CreateFPS()
        if FeatureState.fpsWindow then return end
        print("[FPS] Window created")

        local window = Instance.new("Frame")
        window.Name = "FPSWindow"
        window.Size = UDim2.new(0, 80, 0, 30)
        window.Position = UDim2.new(1, -90, 0, 10)
        window.BackgroundColor3 = COLORS.Background
        window.BackgroundTransparency = 0.5
        window.BorderSizePixel = 1
        window.BorderColor3 = COLORS.Border
        window.Parent = Context.UI.ScreenGui

        local label = Instance.new("TextLabel")
        label.Name = "FPSLabel"
        label.Size = UDim2.new(1, -25, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "60 FPS"
        label.TextColor3 = COLORS.Text
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.Parent = window

        local dragIcon = Instance.new("TextButton")
        dragIcon.Name = "DragButton"
        dragIcon.Size = UDim2.new(0, 20, 1, 0)
        dragIcon.Position = UDim2.new(1, -20, 0, 0)
        dragIcon.BackgroundColor3 = COLORS.Border
        dragIcon.BackgroundTransparency = 0.5
        dragIcon.BorderSizePixel = 0
        dragIcon.Text = "⬙"
        dragIcon.TextColor3 = COLORS.Text
        dragIcon.TextSize = 14
        dragIcon.AutoButtonColor = false
        dragIcon.Parent = window

        local cleanupDrag = Components.setupWindowDrag(window, dragIcon)

        local lastTime = os.clock()
        local frames = 0
        local currentFPS = 60

        FeatureState.fpsConnection = RunService.Heartbeat:Connect(function()
            frames = frames + 1
            local now = os.clock()
            if now - lastTime >= 0.2 then
                currentFPS = math.floor(frames / (now - lastTime) + 0.5)
                frames = 0
                lastTime = now
            end
            label.Text = currentFPS .. " FPS"
        end)

        window.Destroying:Connect(function()
            cleanupDrag()
            if FeatureState.fpsConnection then
                FeatureState.fpsConnection:Disconnect()
                FeatureState.fpsConnection = nil
            end
        end)

        FeatureState.fpsWindow = window
    end

    -- ============================================================
    -- DESTROY FPS WINDOW
    -- ============================================================
    function FPSPing.DestroyFPS()
        if FeatureState.fpsWindow then
            FeatureState.fpsWindow:Destroy()
            FeatureState.fpsWindow = nil
            print("[FPS] Window destroyed")
        end
    end

    -- ============================================================
    -- CREATE PING WINDOW
    -- ============================================================
    function FPSPing.CreatePing()
        if FeatureState.pingWindow then return end
        print("[Ping] Window created")

        local window = Instance.new("Frame")
        window.Name = "PingWindow"
        local yPos = 10
        if FeatureState.fpsWindow then
            yPos = 50
        end
        window.Size = UDim2.new(0, 100, 0, 30)
        window.Position = UDim2.new(1, -110, 0, yPos)
        window.BackgroundColor3 = COLORS.Background
        window.BackgroundTransparency = 0.5
        window.BorderSizePixel = 1
        window.BorderColor3 = COLORS.Border
        window.Parent = Context.UI.ScreenGui

        local label = Instance.new("TextLabel")
        label.Name = "PingLabel"
        label.Size = UDim2.new(1, -25, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "0 ms"
        label.TextColor3 = COLORS.Text
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.Parent = window

        local dragIcon = Instance.new("TextButton")
        dragIcon.Name = "DragButton"
        dragIcon.Size = UDim2.new(0, 20, 1, 0)
        dragIcon.Position = UDim2.new(1, -20, 0, 0)
        dragIcon.BackgroundColor3 = COLORS.Border
        dragIcon.BackgroundTransparency = 0.5
        dragIcon.BorderSizePixel = 0
        dragIcon.Text = "⬙"
        dragIcon.TextColor3 = COLORS.Text
        dragIcon.TextSize = 14
        dragIcon.AutoButtonColor = false
        dragIcon.Parent = window

        local cleanupDrag = Components.setupWindowDrag(window, dragIcon)

        FeatureState.pingConnection = RunService.RenderStepped:Connect(function()
            label.Text = math.floor(Context.LocalPlayer:GetNetworkPing() * 1000) .. " ms"
        end)

        window.Destroying:Connect(function()
            cleanupDrag()
            if FeatureState.pingConnection then
                FeatureState.pingConnection:Disconnect()
                FeatureState.pingConnection = nil
            end
        end)

        FeatureState.pingWindow = window
    end

    -- ============================================================
    -- DESTROY PING WINDOW
    -- ============================================================
    function FPSPing.DestroyPing()
        if FeatureState.pingWindow then
            FeatureState.pingWindow:Destroy()
            FeatureState.pingWindow = nil
            print("[Ping] Window destroyed")
        end
    end

    -- ============================================================
    -- COMBINED TOGGLES (for Misc tab)
    -- ============================================================
    function FPSPing.ToggleFPS(enabled)
        if enabled then
            FPSPing.CreateFPS()
        else
            FPSPing.DestroyFPS()
        end
    end

    function FPSPing.TogglePing(enabled)
        if enabled then
            FPSPing.CreatePing()
        else
            FPSPing.DestroyPing()
        end
    end

    function FPSPing.IsFPSActive()
        return FeatureState.fpsWindow ~= nil
    end

    function FPSPing.IsPingActive()
        return FeatureState.pingWindow ~= nil
    end

    print("[Feature] FPSPing module loaded.")
    return FPSPing
end
