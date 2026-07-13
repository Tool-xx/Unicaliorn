-- Tabs/Misc.lua
-- Misc tab: Anti-AFK, FPS Counter, Ping Counter toggles + Keybinds system + Plugins
-- Receives Context, returns tab content frame

return function(Context)
    local Config = Context.Config
    local COLORS = Config.COLORS
    local Components = Context.UI.Components
    local FeatureState = Context.FeatureState
    local TweenService = Context.Services.TweenService
    local UserInputService = Context.Services.UserInputService

    -- ============================================================
    -- NOTIFICATION SYSTEM (small bind notifications)
    -- ============================================================
    local function showBindNotification(functionName, enabled)
        local ScreenGui = Context.UI.ScreenGui
        if not ScreenGui then return end

        local notifContainer = ScreenGui:FindFirstChild("BindNotifications")
        if not notifContainer then
            notifContainer = Instance.new("Frame")
            notifContainer.Name = "BindNotifications"
            notifContainer.Size = UDim2.new(0, 220, 1, 0)
            notifContainer.Position = UDim2.new(1, -230, 0, 10)
            notifContainer.BackgroundTransparency = 1
            notifContainer.Parent = ScreenGui
        end

        local existingCount = 0
        for _, child in ipairs(notifContainer:GetChildren()) do
            if child:IsA("Frame") then existingCount = existingCount + 1 end
        end

        local notif = Instance.new("Frame")
        notif.Name = "BindNotif_" .. functionName
        notif.Size = UDim2.new(1, 0, 0, 32)
        notif.Position = UDim2.new(0, 240, 0, existingCount * 37)
        notif.BackgroundColor3 = COLORS.Background
        notif.BackgroundTransparency = 0.1
        notif.BorderSizePixel = 1
        notif.BorderColor3 = COLORS.Border
        notif.Parent = notifContainer

        local statusColor = enabled and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(255, 80, 80)
        local statusText = enabled and "enabled" or "disabled"

        local icon = Instance.new("Frame")
        icon.Size = UDim2.new(0, 4, 1, 0)
        icon.Position = UDim2.new(0, 0, 0, 0)
        icon.BackgroundColor3 = statusColor
        icon.BorderSizePixel = 0
        icon.Parent = notif

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -14, 1, 0)
        text.Position = UDim2.new(0, 10, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = functionName .. " is " .. statusText
        text.TextColor3 = COLORS.Text
        text.TextSize = 12
        text.Font = Enum.Font.GothamBold
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Parent = notif

        TweenService:Create(notif, Config.TWEEN.Appear, {
            Position = UDim2.new(0, 0, 0, existingCount * 37)
        }):Play()

        task.delay(2, function()
            if notif and notif.Parent then
                TweenService:Create(notif, Config.TWEEN.Close, {
                    Position = UDim2.new(0, 240, 0, notif.Position.Y.Offset),
                    BackgroundTransparency = 1
                }):Play()
                task.delay(0.35, function()
                    if notif and notif.Parent then
                        notif:Destroy()
                        local idx = 0
                        for _, child in ipairs(notifContainer:GetChildren()) do
                            if child:IsA("Frame") and child ~= notif then
                                TweenService:Create(child, Config.TWEEN.Hover, {
                                    Position = UDim2.new(0, 0, 0, idx * 37)
                                }):Play()
                                idx = idx + 1
                            end
                        end
                    end
                end)
            end
        end)
    end

    -- ============================================================
    -- EXECUTE FUNCTION BY NAME
    -- ============================================================
    local function executeFunction(funcName)
        local Features = Context.Features

        local function toggleFeature(name, enableFunc, disableFunc, isEnabled)
            if isEnabled then
                disableFunc()
                showBindNotification(name, false)
            else
                enableFunc()
                showBindNotification(name, true)
            end
        end

        if funcName == "Rejoin" then
            pcall(function()
                Context.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)
            showBindNotification("Rejoin", true)

        elseif funcName == "Server Hop" then
            pcall(function()
                Context.Services.TeleportService:Teleport(game.PlaceId)
            end)
            showBindNotification("Server Hop", true)

        elseif funcName == "Anti-AFK" then
            if Features.AntiAFK then
                local running = Features.AntiAFK.IsRunning and Features.AntiAFK.IsRunning() or FeatureState.antiAfkRunning
                toggleFeature("Anti-AFK", Features.AntiAFK.Start, Features.AntiAFK.Stop, running)
            end

        elseif funcName == "FPS Counter" then
            if Features.FPSPing then
                local active = Features.FPSPing.IsFPSActive and Features.FPSPing.IsFPSActive() or (FeatureState.fpsWindow ~= nil)
                if active then
                    Features.FPSPing.DestroyFPS()
                    showBindNotification("FPS Counter", false)
                else
                    Features.FPSPing.CreateFPS()
                    showBindNotification("FPS Counter", true)
                end
            end

        elseif funcName == "Ping Counter" then
            if Features.FPSPing then
                local active = Features.FPSPing.IsPingActive and Features.FPSPing.IsPingActive() or (FeatureState.pingWindow ~= nil)
                if active then
                    Features.FPSPing.DestroyPing()
                    showBindNotification("Ping Counter", false)
                else
                    Features.FPSPing.CreatePing()
                    showBindNotification("Ping Counter", true)
                end
            end

        elseif funcName == "Noclip" then
            if Features.Noclip then
                local enabled = Features.Noclip.IsEnabled and Features.Noclip.IsEnabled() or FeatureState.noclipEnabled
                toggleFeature("Noclip", Features.Noclip.Enable, Features.Noclip.Disable, enabled)
            end

        elseif funcName == "Speedhack" then
            if Features.Speedhack then
                local enabled = Features.Speedhack.IsEnabled and Features.Speedhack.IsEnabled() or FeatureState.speedhackEnabled
                toggleFeature("Speedhack", Features.Speedhack.Enable, Features.Speedhack.Disable, enabled)
            end

        elseif funcName == "Fly" then
            if Features.Fly then
                local enabled = Features.Fly.IsEnabled and Features.Fly.IsEnabled() or FeatureState.flyEnabled
                toggleFeature("Fly", Features.Fly.Start, Features.Fly.Stop, enabled)
            end

        elseif funcName == "Infinite Jump" then
            if Features.InfinityJump then
                local enabled = Features.InfinityJump.IsEnabled and Features.InfinityJump.IsEnabled() or FeatureState.infinityJumpEnabled
                toggleFeature("Infinite Jump", Features.InfinityJump.Enable, Features.InfinityJump.Disable, enabled)
            end

        elseif funcName == "ESP" then
            if Features.ESP then
                local enabled = Features.ESP.IsEnabled and Features.ESP.IsEnabled() or FeatureState.espEnabled
                if enabled then
                    Features.ESP.Disable()
                    showBindNotification("ESP", false)
                else
                    Features.ESP.Enable()
                    showBindNotification("ESP", true)
                end
            end

        elseif funcName == "Boost FPS" then
            showBindNotification("Boost FPS", true)
        else
            -- Check if it's a plugin
            if Features.Plugins then
                Features.Plugins.ExecuteByBind(funcName)
                local isRunning = Features.Plugins.IsRunning(funcName)
                showBindNotification(funcName, isRunning)
            end
        end
    end

    -- ============================================================
    -- GLOBAL BIND LISTENER
    -- ============================================================
    if not FeatureState.bindGlobalConnection then
        FeatureState.bindGlobalConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if Context.State.bindListening then return end

            for funcName, boundKey in pairs(FeatureState.binds) do
                if input.KeyCode == boundKey then
                    executeFunction(funcName)
                    break
                end
            end
        end)
    end

    -- ============================================================
    -- CREATE CONTENT
    -- ============================================================
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_Misc"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.Border
    content.CanvasSize = UDim2.new(0, 0, 0, 200)
    content.Visible = false
    content.Parent = Context.UI.ContentFrame

    -- Anti-AFK Toggle
    local antiAfkToggle = Components.createToggle(content, "Anti-AFK", 10, function(enabled)
        if Context.Features.AntiAFK then
            if enabled then
                Context.Features.AntiAFK.Start()
            else
                Context.Features.AntiAFK.Stop()
            end
        end
    end)

    if FeatureState.antiAfkRunning then
        antiAfkToggle.setEnabled(true)
    end

    -- FPS Counter Toggle
    local fpsToggle = Components.createToggle(content, "FPS Counter", 50, function(enabled)
        if Context.Features.FPSPing then
            Context.Features.FPSPing.ToggleFPS(enabled)
        end
    end)

    if FeatureState.fpsWindow then
        fpsToggle.setEnabled(true)
    end

    -- Ping Counter Toggle
    local pingToggle = Components.createToggle(content, "Ping Counter", 90, function(enabled)
        if Context.Features.FPSPing then
            Context.Features.FPSPing.TogglePing(enabled)
        end
    end)

    if FeatureState.pingWindow then
        pingToggle.setEnabled(true)
    end

    -- ============================================================
    -- PLUGINS HEADER (collapsible)
    -- ============================================================
    local pluginsHeader = Instance.new("Frame")
    pluginsHeader.Name = "PluginsHeader"
    pluginsHeader.Size = UDim2.new(1, -20, 0, 30)
    pluginsHeader.Position = UDim2.new(0, 10, 0, 140)
    pluginsHeader.BackgroundColor3 = COLORS.Background
    pluginsHeader.BorderSizePixel = 0
    pluginsHeader.Parent = content

    local pluginsLabel = Instance.new("TextLabel")
    pluginsLabel.Size = UDim2.new(1, -80, 1, 0)
    pluginsLabel.Position = UDim2.new(0, 5, 0, 0)
    pluginsLabel.BackgroundTransparency = 1
    pluginsLabel.Text = "Plugins"
    pluginsLabel.TextColor3 = COLORS.Text
    pluginsLabel.TextSize = 14
    pluginsLabel.Font = Enum.Font.Gotham
    pluginsLabel.TextXAlignment = Enum.TextXAlignment.Left
    pluginsLabel.Parent = pluginsHeader

    -- Expand/collapse button
    local pluginsToggleBtn = Instance.new("TextButton")
    pluginsToggleBtn.Name = "PluginsToggle"
    pluginsToggleBtn.Size = UDim2.new(0, 30, 0, 22)
    pluginsToggleBtn.Position = UDim2.new(1, -70, 0.5, -11)
    pluginsToggleBtn.BackgroundColor3 = COLORS.Background
    pluginsToggleBtn.BorderSizePixel = 1
    pluginsToggleBtn.BorderColor3 = COLORS.Border
    pluginsToggleBtn.Text = "\u{25BC}"
    pluginsToggleBtn.TextColor3 = COLORS.Text
    pluginsToggleBtn.TextSize = 12
    pluginsToggleBtn.Font = Enum.Font.GothamBold
    pluginsToggleBtn.AutoButtonColor = false
    pluginsToggleBtn.Parent = pluginsHeader

    -- Add (+) button
    local pluginsAddBtn = Instance.new("TextButton")
    pluginsAddBtn.Name = "PluginsAdd"
    pluginsAddBtn.Size = UDim2.new(0, 30, 0, 22)
    pluginsAddBtn.Position = UDim2.new(1, -35, 0.5, -11)
    pluginsAddBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    pluginsAddBtn.BorderSizePixel = 1
    pluginsAddBtn.BorderColor3 = Color3.fromRGB(0, 150, 75)
    pluginsAddBtn.Text = "+"
    pluginsAddBtn.TextColor3 = COLORS.Text
    pluginsAddBtn.TextSize = 16
    pluginsAddBtn.Font = Enum.Font.GothamBold
    pluginsAddBtn.AutoButtonColor = false
    pluginsAddBtn.Parent = pluginsHeader

    pluginsAddBtn.MouseEnter:Connect(function()
        TweenService:Create(pluginsAddBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(0, 130, 65)}):Play()
    end)
    pluginsAddBtn.MouseLeave:Connect(function()
        TweenService:Create(pluginsAddBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(0, 100, 50)}):Play()
    end)

    -- Plugins Frame (collapsible list)
    local pluginsFrame = Instance.new("Frame")
    pluginsFrame.Name = "Plugins_List"
    pluginsFrame.Size = UDim2.new(1, -20, 0, 0)
    pluginsFrame.Position = UDim2.new(0, 10, 0, 175)
    pluginsFrame.BackgroundColor3 = COLORS.Background
    pluginsFrame.BorderSizePixel = 1
    pluginsFrame.BorderColor3 = COLORS.Border
    pluginsFrame.ClipsDescendants = true
    pluginsFrame.Visible = true
    pluginsFrame.Parent = content

    -- Scrollable plugin list inside pluginsFrame
    local pluginsScroll = Instance.new("ScrollingFrame")
    pluginsScroll.Name = "PluginsScroll"
    pluginsScroll.Size = UDim2.new(1, 0, 1, 0)
    pluginsScroll.BackgroundTransparency = 1
    pluginsScroll.BorderSizePixel = 0
    pluginsScroll.ScrollBarThickness = 4
    pluginsScroll.ScrollBarImageColor3 = COLORS.Border
    pluginsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pluginsScroll.Parent = pluginsFrame

    -- ============================================================
    -- REFRESH PLUGIN LIST
    -- ============================================================
    local function refreshPluginsList()
        if Context.Features.Plugins then
            local contentHeight = Context.Features.Plugins.RefreshListUI(pluginsScroll, refreshPluginsList)
            pluginsScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        end
    end

    -- Add button opens editor
    pluginsAddBtn.MouseButton1Click:Connect(function()
        if Context.Features.Plugins then
            Context.Features.Plugins.OpenEditor(nil, nil, function()
                refreshPluginsList()
                refreshBindList()
            end)
        end
    end)

    -- ============================================================
    -- BINDS HEADER (collapsible)
    -- ============================================================
    local bindsHeader = Instance.new("Frame")
    bindsHeader.Name = "BindsHeader"
    bindsHeader.Size = UDim2.new(1, -20, 0, 30)
    bindsHeader.Position = UDim2.new(0, 10, 0, 180)
    bindsHeader.BackgroundColor3 = COLORS.Background
    bindsHeader.BorderSizePixel = 0
    bindsHeader.Parent = content

    local bindsLabel = Instance.new("TextLabel")
    bindsLabel.Size = UDim2.new(1, -40, 1, 0)
    bindsLabel.Position = UDim2.new(0, 5, 0, 0)
    bindsLabel.BackgroundTransparency = 1
    bindsLabel.Text = "Keybinds"
    bindsLabel.TextColor3 = COLORS.Text
    bindsLabel.TextSize = 14
    bindsLabel.Font = Enum.Font.Gotham
    bindsLabel.TextXAlignment = Enum.TextXAlignment.Left
    bindsLabel.Parent = bindsHeader

    local bindsToggleBtn = Instance.new("TextButton")
    bindsToggleBtn.Name = "BindsToggle"
    bindsToggleBtn.Size = UDim2.new(0, 30, 0, 22)
    bindsToggleBtn.Position = UDim2.new(1, -35, 0.5, -11)
    bindsToggleBtn.BackgroundColor3 = COLORS.Background
    bindsToggleBtn.BorderSizePixel = 1
    bindsToggleBtn.BorderColor3 = COLORS.Border
    bindsToggleBtn.Text = "\u{25BC}"
    bindsToggleBtn.TextColor3 = COLORS.Text
    bindsToggleBtn.TextSize = 12
    bindsToggleBtn.Font = Enum.Font.GothamBold
    bindsToggleBtn.AutoButtonColor = false
    bindsToggleBtn.Parent = bindsHeader

    -- Binds Frame (collapsible)
    local bindsFrame = Instance.new("Frame")
    bindsFrame.Name = "Binds_Settings"
    bindsFrame.Size = UDim2.new(1, -20, 0, 0)
    bindsFrame.Position = UDim2.new(0, 10, 0, 215)
    bindsFrame.BackgroundColor3 = COLORS.Background
    bindsFrame.BorderSizePixel = 1
    bindsFrame.BorderColor3 = COLORS.Border
    bindsFrame.ClipsDescendants = true
    bindsFrame.Visible = true
    bindsFrame.Parent = content

    -- Bind rows container
    local bindsScroll = Instance.new("ScrollingFrame")
    bindsScroll.Name = "BindsScroll"
    bindsScroll.Size = UDim2.new(1, 0, 1, 0)
    bindsScroll.BackgroundTransparency = 1
    bindsScroll.BorderSizePixel = 0
    bindsScroll.ScrollBarThickness = 4
    bindsScroll.ScrollBarImageColor3 = COLORS.Border
    bindsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    bindsScroll.Parent = bindsFrame

    -- ============================================================
    -- REFRESH BIND LIST (includes plugins)
    -- ============================================================
    -- Ensure binds table exists
    FeatureState.binds = FeatureState.binds or {}

    -- List of built-in functions that can be bound
    local builtinFunctions = {
        "Rejoin",
        "Server Hop",
        "Anti-AFK",
        "FPS Counter",
        "Ping Counter",
        "Noclip",
        "Speedhack",
        "Fly",
        "Infinite Jump",
        "ESP",
        "Boost FPS",
    }

    local function formatKeyName(key)
        if not key then return "None" end
        -- If stored as Enum.KeyCode or string
        if typeof(key) == "EnumItem" then
            return key.Name
        elseif type(key) == "string" then
            return key
        else
            return tostring(key)
        end
    end

    local listeningConn = nil

    local function stopListening()
        if listeningConn then
            listeningConn:Disconnect()
            listeningConn = nil
        end
        Context.State.bindListening = false
    end

    local function startListening(editBtn, funcName, keyDisplay)
        -- Guard: don't allow nested listening
        if Context.State.bindListening then return end
        Context.State.bindListening = true
        editBtn.Text = "Press..."
        -- Capture single keypress
        listeningConn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local keyCode = input.KeyCode
            -- Save bind
            FeatureState.binds[funcName] = keyCode
            stopListening()
            showBindNotification(funcName, true)
            -- Update display
            keyDisplay.Text = formatKeyName(keyCode)
            -- minor delay then refresh the UI to ensure consistent ordering/heights
            task.delay(0.05, function() refreshBindList() end)
        end)

        -- Also listen for Escape to cancel
        listeningConn, listeningConnCancel = listeningConn, listeningConn
    end

    local function createBindRow(parent, yOffset, funcName)
        local row = Instance.new("Frame")
        row.Name = "BindRow_" .. funcName:gsub("%s", "_")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.Position = UDim2.new(0, 0, 0, yOffset)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.55, -8, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = funcName
        label.TextColor3 = COLORS.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local keyDisplay = Instance.new("TextButton")
        keyDisplay.Size = UDim2.new(0, 90, 0, 22)
        keyDisplay.Position = UDim2.new(0.6, 0, 0.5, -11)
        keyDisplay.BackgroundColor3 = COLORS.Background
        keyDisplay.BorderSizePixel = 1
        keyDisplay.BorderColor3 = COLORS.Border
        keyDisplay.Text = formatKeyName(FeatureState.binds[funcName])
        keyDisplay.TextColor3 = COLORS.Text
        keyDisplay.TextSize = 12
        keyDisplay.Font = Enum.Font.GothamBold
        keyDisplay.AutoButtonColor = false
        keyDisplay.Parent = row

        local editBtn = Instance.new("TextButton")
        editBtn.Size = UDim2.new(0, 50, 0, 22)
        editBtn.Position = UDim2.new(0.6, 100, 0.5, -11)
        editBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        editBtn.BorderSizePixel = 1
        editBtn.BorderColor3 = COLORS.Border
        editBtn.Text = "Edit"
        editBtn.TextColor3 = COLORS.Text
        editBtn.TextSize = 12
        editBtn.Font = Enum.Font.GothamBold
        editBtn.AutoButtonColor = false
        editBtn.Parent = row

        local unbindBtn = Instance.new("TextButton")
        unbindBtn.Size = UDim2.new(0, 50, 0, 22)
        unbindBtn.Position = UDim2.new(0.6, 156, 0.5, -11)
        unbindBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
        unbindBtn.BorderSizePixel = 1
        unbindBtn.BorderColor3 = Color3.fromRGB(150, 50, 50)
        unbindBtn.Text = "Unbind"
        unbindBtn.TextColor3 = COLORS.Text
        unbindBtn.TextSize = 12
        unbindBtn.Font = Enum.Font.GothamBold
        unbindBtn.AutoButtonColor = false
        unbindBtn.Parent = row

        -- Edit click -> start listening for next key
        editBtn.MouseButton1Click:Connect(function()
            -- If currently listening, cancel
            if Context.State.bindListening then
                stopListening()
                editBtn.Text = "Edit"
                keyDisplay.Text = formatKeyName(FeatureState.binds[funcName])
                return
            end

            startListening(editBtn, funcName, keyDisplay)
        end)

        -- Clicking keyDisplay also starts listening
        keyDisplay.MouseButton1Click:Connect(function()
            editBtn.MouseButton1Click:Fire()
        end)

        -- Unbind click
        unbindBtn.MouseButton1Click:Connect(function()
            FeatureState.binds[funcName] = nil
            showBindNotification(funcName, false)
            refreshBindList()
        end)

        return row
    end

    function refreshBindList()
        -- Clear existing rows
        for _, child in ipairs(bindsScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        local rows = {}
        local added = {} -- set for dedupe

        -- Add builtins first
        local y = 4
        for _, name in ipairs(builtinFunctions) do
            added[name] = true
            createBindRow(bindsScroll, y, name)
            y = y + 36
        end

        -- Add plugin functions (include even if not bound yet)
        if Context.Features.Plugins and Context.Features.Plugins.GetAll then
            local plugins = Context.Features.Plugins.GetAll()
            if plugins and type(plugins) == "table" then
                for _, plugin in ipairs(plugins) do
                    -- Depending on Plugins.GetAll return format: accept both table of names or table of tables with .name
                    local pname = nil
                    if type(plugin) == "string" then
                        pname = plugin
                    elseif type(plugin) == "table" and plugin.name then
                        pname = plugin.name
                    end
                    if pname and not added[pname] then
                        added[pname] = true
                        createBindRow(bindsScroll, y, pname)
                        y = y + 36
                    end
                end
            end
        end

        -- Also add any orphan binds that are set but not in builtins/plugins
        for name, _ in pairs(FeatureState.binds) do
            if not added[name] then
                added[name] = true
                createBindRow(bindsScroll, y, name)
                y = y + 36
            end
        end

        bindsScroll.CanvasSize = UDim2.new(0, 0, 0, y)
    end

    -- Initial refresh
    refreshPluginsList()
    refreshBindList()

    -- When plugins change (Add/Edit/Delete), caller refreshPluginsList will also call refreshBindList via the editor callback
    -- But also hook a simple loop to keep plugin list up-to-date in case plugins UI modifies FeatureState directly
    if Context.Features.Plugins and Context.Features.Plugins.RefreshListUI then
        -- Nothing to attach here; RefreshListUI is invoked by our UI already.
    end

    -- ============================================================
    -- COLLAPSIBLE BEHAVIOR FOR PLUGINS & BINDS
    -- ============================================================
    local pluginsExpanded = true
    local bindsExpanded = true

    local function togglePlugins()
        pluginsExpanded = not pluginsExpanded
        if pluginsExpanded then
            -- Expand (set to a reasonable height based on content)
            local targetH = math.max(100, tonumber(pluginsScroll.CanvasSize.Y.Offset) or 100)
            pluginsFrame:TweenSize(UDim2.new(1, -20, 0, targetH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
            pluginsToggleBtn.Text = "\u{25B2}"
        else
            pluginsFrame:TweenSize(UDim2.new(1, -20, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
            pluginsToggleBtn.Text = "\u{25BC}"
        end
    end

    local function toggleBinds()
        bindsExpanded = not bindsExpanded
        if bindsExpanded then
            local targetH = math.max(140, tonumber(bindsScroll.CanvasSize.Y.Offset) or 140)
            bindsFrame:TweenSize(UDim2.new(1, -20, 0, targetH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
            bindsToggleBtn.Text = "\u{25B2}"
        else
            bindsFrame:TweenSize(UDim2.new(1, -20, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
            bindsToggleBtn.Text = "\u{25BC}"
        end
    end

    pluginsToggleBtn.MouseButton1Click:Connect(togglePlugins)
    bindsToggleBtn.MouseButton1Click:Connect(toggleBinds)

    -- Ensure initial sizes are set after initial content is known
    task.delay(0.05, function()
        -- Plugins
        local pH = math.max(100, tonumber(pluginsScroll.CanvasSize.Y.Offset) or 100)
        pluginsFrame.Size = UDim2.new(1, -20, 0, pH)
        -- Binds
        local bH = math.max(140, tonumber(bindsScroll.CanvasSize.Y.Offset) or 140)
        bindsFrame.Size = UDim2.new(1, -20, 0, bH)
    end)

    -- Register tab (ensure Main has register function)
    if Context.UI.Main and Context.UI.Main.registerTabContent then
        Context.UI.Main.registerTabContent("Misc", content)
    end

    print("[Tab] Misc loaded.")
    return content
end
