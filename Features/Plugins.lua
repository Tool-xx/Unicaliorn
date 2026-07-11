-- Features/Plugins.lua
-- Plugin system: create, edit, delete, run Lua scripts dynamically
-- Receives Context, returns Feature table

return function(Context)
    local TweenService = Context.Services.TweenService
    local UserInputService = Context.Services.UserInputService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local FeatureState = Context.FeatureState

    local Plugins = {}

    -- ============================================================
    -- SYNTAX HIGHLIGHTER
    -- ============================================================
    local LUA_KEYWORDS = {
        ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
        ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
        ["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
        ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
        ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
        ["while"] = true,
    }

    local SYNTAX_COLORS = {
        keyword   = Color3.fromRGB(255, 120, 180),
        string    = Color3.fromRGB(150, 255, 150),
        comment   = Color3.fromRGB(120, 120, 120),
        number    = Color3.fromRGB(150, 200, 255),
        operator  = Color3.fromRGB(255, 200, 100),
        default   = Color3.fromRGB(220, 220, 220),
    }

    local function tokenizeCode(code)
        local tokens = {}
        local i = 1
        local len = #code

        while i <= len do
            local c = code:sub(i, i)

            -- Comments
            if c == "-" and code:sub(i+1, i+1) == "-" then
                local start = i
                i = i + 2
                while i <= len and code:sub(i, i) ~= "\n" do
                    i = i + 1
                end
                table.insert(tokens, {type = "comment", text = code:sub(start, i - 1)})

            -- Strings
            elseif c == "\"" or c == "'" then
                local start = i
                local quote = c
                i = i + 1
                while i <= len do
                    local ch = code:sub(i, i)
                    if ch == "\\" then
                        i = i + 2
                    elseif ch == quote then
                        i = i + 1
                        break
                    else
                        i = i + 1
                    end
                end
                table.insert(tokens, {type = "string", text = code:sub(start, i - 1)})

            -- Numbers
            elseif c:match("%d") then
                local start = i
                i = i + 1
                while i <= len and code:sub(i, i):match("[%d%.%xXaAbBcCdDeEfF]") do
                    i = i + 1
                end
                table.insert(tokens, {type = "number", text = code:sub(start, i - 1)})

            -- Identifiers / Keywords
            elseif c:match("[%a_]") then
                local start = i
                i = i + 1
                while i <= len and code:sub(i, i):match("[%w_]") do
                    i = i + 1
                end
                local word = code:sub(start, i - 1)
                if LUA_KEYWORDS[word] then
                    table.insert(tokens, {type = "keyword", text = word})
                else
                    table.insert(tokens, {type = "default", text = word})
                end

            -- Operators
            elseif c:match("[%+%-%*/%%^#=~<>]") then
                local start = i
                i = i + 1
                while i <= len and code:sub(i, i):match("[%+%-%*/%%^#=~<>]") do
                    i = i + 1
                end
                table.insert(tokens, {type = "operator", text = code:sub(start, i - 1)})

            -- Whitespace
            elseif c:match("%s") then
                local start = i
                i = i + 1
                while i <= len and code:sub(i, i):match("%s") do
                    i = i + 1
                end
                table.insert(tokens, {type = "whitespace", text = code:sub(start, i - 1)})

            -- Other
            else
                table.insert(tokens, {type = "default", text = c})
                i = i + 1
            end
        end

        return tokens
    end

    local function renderHighlightedText(container, code, lineNumbersContainer)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("Frame") then
                child:Destroy()
            end
        end
        if lineNumbersContainer then
            for _, child in ipairs(lineNumbersContainer:GetChildren()) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
        end

        local tokens = tokenizeCode(code)
        local lines = {}
        local currentLine = {}

        for _, token in ipairs(tokens) do
            if token.text:find("\n") then
                local parts = {}
                for part in token.text:gmatch("[^\n]*") do
                    table.insert(parts, part)
                end
                for idx, part in ipairs(parts) do
                    if idx > 1 then
                        table.insert(lines, currentLine)
                        currentLine = {}
                    end
                    if #part > 0 then
                        table.insert(currentLine, {type = token.type, text = part})
                    end
                end
            else
                table.insert(currentLine, token)
            end
        end
        if #currentLine > 0 then
            table.insert(lines, currentLine)
        end

        local lineHeight = 18
        local padding = 4

        for lineIdx, lineTokens in ipairs(lines) do
            if lineNumbersContainer then
                local numLabel = Instance.new("TextLabel")
                numLabel.Size = UDim2.new(1, 0, 0, lineHeight)
                numLabel.Position = UDim2.new(0, 0, 0, (lineIdx - 1) * lineHeight)
                numLabel.BackgroundTransparency = 1
                numLabel.Text = tostring(lineIdx)
                numLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
                numLabel.TextSize = 12
                numLabel.Font = Enum.Font.Code
                numLabel.TextXAlignment = Enum.TextXAlignment.Right
                numLabel.Parent = lineNumbersContainer
            end

            local lineBg = Instance.new("Frame")
            lineBg.Size = UDim2.new(1, 0, 0, lineHeight)
            lineBg.Position = UDim2.new(0, 0, 0, (lineIdx - 1) * lineHeight)
            lineBg.BackgroundTransparency = 1
            lineBg.BorderSizePixel = 0
            lineBg.Parent = container

            local xOffset = padding
            for _, token in ipairs(lineTokens) do
                if token.type ~= "whitespace" then
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0, 0, 0, lineHeight)
                    label.Position = UDim2.new(0, xOffset, 0, 0)
                    label.BackgroundTransparency = 1
                    label.Text = token.text
                    label.TextColor3 = SYNTAX_COLORS[token.type] or SYNTAX_COLORS.default
                    label.TextSize = 13
                    label.Font = Enum.Font.Code
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.AutomaticSize = Enum.AutomaticSize.X
                    label.Parent = lineBg
                    xOffset = xOffset + label.TextBounds.X
                else
                    local spaces = 0
                    for _ in token.text:gmatch(" ") do
                        spaces = spaces + 1
                    end
                    xOffset = xOffset + spaces * 7
                end
            end
        end

        return #lines * lineHeight
    end

    -- ============================================================
    -- PLUGIN MANAGEMENT
    -- ============================================================
    local function stopPlugin(name)
        if FeatureState.pluginRunningThreads[name] then
            pcall(function()
                task.cancel(FeatureState.pluginRunningThreads[name])
            end)
            FeatureState.pluginRunningThreads[name] = nil
        end
        for _, plugin in ipairs(FeatureState.plugins) do
            if plugin.name == name then
                plugin.enabled = false
                break
            end
        end
        print("[Plugins] Stopped: " .. name)
    end

    local function runPlugin(name, code)
        stopPlugin(name)

        local success, err = pcall(function()
            local loaded = loadstring(code)
            if not loaded then
                error("Failed to compile script")
            end
            FeatureState.pluginRunningThreads[name] = task.spawn(loaded)
        end)

        if not success then
            warn("[Plugins] Error running '" .. name .. "': " .. tostring(err))
            local ScreenGui = Context.UI.ScreenGui
            if ScreenGui then
                local errNotif = Instance.new("Frame")
                errNotif.Size = UDim2.new(0, 300, 0, 40)
                errNotif.Position = UDim2.new(0.5, -150, 0, 50)
                errNotif.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
                errNotif.BorderSizePixel = 1
                errNotif.BorderColor3 = Color3.fromRGB(255, 80, 80)
                errNotif.Parent = ScreenGui

                local errText = Instance.new("TextLabel")
                errText.Size = UDim2.new(1, -10, 1, 0)
                errText.Position = UDim2.new(0, 5, 0, 0)
                errText.BackgroundTransparency = 1
                errText.Text = "Plugin error: " .. tostring(err):sub(1, 40)
                errText.TextColor3 = Color3.fromRGB(255, 150, 150)
                errText.TextSize = 11
                errText.Font = Enum.Font.Gotham
                errText.TextWrapped = true
                errText.Parent = errNotif

                TweenService:Create(errNotif, TWEEN.Fade, {BackgroundTransparency = 1}):Play()
                TweenService:Create(errText, TWEEN.Fade, {TextTransparency = 1}):Play()
                task.delay(3, function()
                    if errNotif and errNotif.Parent then
                        errNotif:Destroy()
                    end
                end)
            end
            return false
        end

        for _, plugin in ipairs(FeatureState.plugins) do
            if plugin.name == name then
                plugin.enabled = true
                break
            end
        end
        print("[Plugins] Running: " .. name)
        return true
    end

    function Plugins.Add(name, code)
        for _, plugin in ipairs(FeatureState.plugins) do
            if plugin.name == name then
                return false, "Plugin with this name already exists"
            end
        end

        table.insert(FeatureState.plugins, {
            name = name,
            code = code,
            enabled = false,
        })

        FeatureState.binds[name] = nil
        print("[Plugins] Added: " .. name)
        return true
    end

    function Plugins.Update(oldName, newName, newCode)
        local plugin = nil
        local idx = nil
        for i, p in ipairs(FeatureState.plugins) do
            if p.name == oldName then
                plugin = p
                idx = i
                break
            end
        end
        if not plugin then
            return false, "Plugin not found"
        end

        if newName ~= oldName then
            for _, p in ipairs(FeatureState.plugins) do
                if p.name == newName then
                    return false, "Plugin with this name already exists"
                end
            end
            FeatureState.binds[newName] = FeatureState.binds[oldName]
            FeatureState.binds[oldName] = nil
        end

        if plugin.enabled then
            stopPlugin(oldName)
        end

        plugin.name = newName
        plugin.code = newCode
        plugin.enabled = false

        print("[Plugins] Updated: " .. oldName .. " -> " .. newName)
        return true
    end

    function Plugins.Delete(name)
        for i, plugin in ipairs(FeatureState.plugins) do
            if plugin.name == name then
                if plugin.enabled then
                    stopPlugin(name)
                end
                table.remove(FeatureState.plugins, i)
                FeatureState.binds[name] = nil
                print("[Plugins] Deleted: " .. name)
                return true
            end
        end
        return false
    end

    function Plugins.GetAll()
        return FeatureState.plugins
    end

    function Plugins.Toggle(name)
        for _, plugin in ipairs(FeatureState.plugins) do
            if plugin.name == name then
                if plugin.enabled then
                    stopPlugin(name)
                    return false
                else
                    return runPlugin(name, plugin.code)
                end
            end
        end
        return false
    end

    function Plugins.IsRunning(name)
        for _, plugin in ipairs(FeatureState.plugins) do
            if plugin.name == name then
                return plugin.enabled
            end
        end
        return false
    end

    function Plugins.ExecuteByBind(name)
        for _, plugin in ipairs(FeatureState.plugins) do
            if plugin.name == name then
                if plugin.enabled then
                    stopPlugin(name)
                else
                    runPlugin(name, plugin.code)
                end
                return true
            end
        end
        return false
    end

    -- ============================================================
    -- EDITOR WINDOW
    -- ============================================================
    function Plugins.OpenEditor(editPluginName, editPluginCode, onSaveCallback)
        if Context.State.pluginEditorOpen then return end
        Context.State.pluginEditorOpen = true

        local ScreenGui = Context.UI.ScreenGui
        if not ScreenGui then return end

        local defaultText = "Plugins is a feature that allows you to run and manage scripts directly in Roblox without executor"
        local currentCode = editPluginCode or defaultText
        local isEditing = editPluginName ~= nil

        -- Fullscreen overlay
        local overlay = Instance.new("Frame")
        overlay.Name = "PluginEditorOverlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = COLORS.Overlay
        overlay.BackgroundTransparency = 0.3
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 200
        overlay.Parent = ScreenGui

        -- Resizable window
        local window = Instance.new("Frame")
        window.Name = "PluginEditorWindow"
        window.Size = UDim2.new(0, 700, 0, 500)
        window.Position = UDim2.new(0.5, -350, 0.5, -250)
        window.BackgroundColor3 = COLORS.Background
        window.BorderSizePixel = 1
        window.BorderColor3 = COLORS.Border
        window.ZIndex = 201
        window.Parent = overlay

        -- Title bar
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 32)
        titleBar.BackgroundColor3 = COLORS.Background
        titleBar.BorderSizePixel = 0
        titleBar.ZIndex = 202
        titleBar.Parent = window

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -120, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = isEditing and ("Edit Plugin: " .. editPluginName) or "New Plugin"
        titleLabel.TextColor3 = COLORS.Text
        titleLabel.TextSize = 15
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 203
        titleLabel.Parent = titleBar

        -- Close button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 32, 0, 32)
        closeBtn.Position = UDim2.new(1, -32, 0, 0)
        closeBtn.BackgroundColor3 = COLORS.Background
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "X"
        closeBtn.TextColor3 = COLORS.CloseButton
        closeBtn.TextSize = 16
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.AutoButtonColor = false
        closeBtn.ZIndex = 203
        closeBtn.Parent = titleBar

        -- Separator
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, 0, 0, 1)
        sep.Position = UDim2.new(0, 0, 0, 32)
        sep.BackgroundColor3 = COLORS.Border
        sep.BorderSizePixel = 0
        sep.ZIndex = 202
        sep.Parent = window

        -- Line numbers panel
        local lineNumbers = Instance.new("Frame")
        lineNumbers.Size = UDim2.new(0, 45, 1, -77)
        lineNumbers.Position = UDim2.new(0, 0, 0, 33)
        lineNumbers.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        lineNumbers.BorderSizePixel = 0
        lineNumbers.ZIndex = 202
        lineNumbers.Parent = window

        -- Code container
        local codeContainer = Instance.new("Frame")
        codeContainer.Size = UDim2.new(1, -45, 1, -77)
        codeContainer.Position = UDim2.new(0, 45, 0, 33)
        codeContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        codeContainer.BorderSizePixel = 0
        codeContainer.ZIndex = 202
        codeContainer.Parent = window

        -- Scrolling for code
        local codeScroll = Instance.new("ScrollingFrame")
        codeScroll.Size = UDim2.new(1, 0, 1, 0)
        codeScroll.BackgroundTransparency = 1
        codeScroll.BorderSizePixel = 0
        codeScroll.ScrollBarThickness = 6
        codeScroll.ScrollBarImageColor3 = COLORS.Border
        codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        codeScroll.ZIndex = 203
        codeScroll.Parent = codeContainer

        -- Hidden text box for input
        local inputBox = Instance.new("TextBox")
        inputBox.Size = UDim2.new(1, 0, 1, 0)
        inputBox.Position = UDim2.new(0, 0, 0, 0)
        inputBox.BackgroundTransparency = 1
        inputBox.Text = currentCode
        inputBox.TextColor3 = Color3.fromRGB(0, 0, 0)
        inputBox.TextTransparency = 1
        inputBox.TextSize = 13
        inputBox.Font = Enum.Font.Code
        inputBox.ClearTextOnFocus = false
        inputBox.MultiLine = true
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.TextYAlignment = Enum.TextYAlignment.Top
        inputBox.ZIndex = 210
        inputBox.Parent = codeScroll

        local function refreshHighlight()
            local contentHeight = renderHighlightedText(codeScroll, inputBox.Text, lineNumbers)
            codeScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(contentHeight, codeScroll.AbsoluteSize.Y + 50))
        end

        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            refreshHighlight()
        end)

        task.defer(refreshHighlight)

        -- Bottom bar
        local bottomBar = Instance.new("Frame")
        bottomBar.Size = UDim2.new(1, 0, 0, 44)
        bottomBar.Position = UDim2.new(0, 0, 1, -44)
        bottomBar.BackgroundColor3 = COLORS.Background
        bottomBar.BorderSizePixel = 1
        bottomBar.BorderColor3 = COLORS.Border
        bottomBar.ZIndex = 202
        bottomBar.Parent = window

        local bottomSep = Instance.new("Frame")
        bottomSep.Size = UDim2.new(1, 0, 0, 1)
        bottomSep.Position = UDim2.new(0, 0, 0, 0)
        bottomSep.BackgroundColor3 = COLORS.Border
        bottomSep.BorderSizePixel = 0
        bottomSep.ZIndex = 203
        bottomSep.Parent = bottomBar

        -- Save button
        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0, 100, 0, 30)
        saveBtn.Position = UDim2.new(1, -220, 0.5, -15)
        saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
        saveBtn.BorderSizePixel = 1
        saveBtn.BorderColor3 = Color3.fromRGB(0, 180, 90)
        saveBtn.Text = "Save"
        saveBtn.TextColor3 = COLORS.Text
        saveBtn.TextSize = 14
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.AutoButtonColor = false
        saveBtn.ZIndex = 203
        saveBtn.Parent = bottomBar

        saveBtn.MouseEnter:Connect(function()
            TweenService:Create(saveBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(0, 150, 75)}):Play()
        end)
        saveBtn.MouseLeave:Connect(function()
            TweenService:Create(saveBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(0, 120, 60)}):Play()
        end)

        -- Close button (bottom)
        local closeBottomBtn = Instance.new("TextButton")
        closeBottomBtn.Size = UDim2.new(0, 100, 0, 30)
        closeBottomBtn.Position = UDim2.new(1, -110, 0.5, -15)
        closeBottomBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        closeBottomBtn.BorderSizePixel = 1
        closeBottomBtn.BorderColor3 = Color3.fromRGB(180, 60, 60)
        closeBottomBtn.Text = "Close"
        closeBottomBtn.TextColor3 = COLORS.Text
        closeBottomBtn.TextSize = 14
        closeBottomBtn.Font = Enum.Font.GothamBold
        closeBottomBtn.AutoButtonColor = false
        closeBottomBtn.ZIndex = 203
        closeBottomBtn.Parent = bottomBar

        closeBottomBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBottomBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(150, 50, 50)}):Play()
        end)
        closeBottomBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBottomBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(120, 40, 40)}):Play()
        end)

        -- Status label
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -240, 0, 20)
        statusLabel.Position = UDim2.new(0, 10, 0.5, -10)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = isEditing and "Editing existing plugin" or "Create a new plugin"
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        statusLabel.TextSize = 12
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.ZIndex = 203
        statusLabel.Parent = bottomBar

        -- Drag
        local dragConn1, dragConn2, dragConn3
        local dragging, dragStart, startPos

        dragConn1 = titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = window.Position
            end
        end)

        dragConn2 = titleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if dragging then
                    local delta = input.Position - dragStart
                    window.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)

        dragConn3 = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        -- Resize handle
        local resizeHandle = Instance.new("TextButton")
        resizeHandle.Size = UDim2.new(0, 16, 0, 16)
        resizeHandle.Position = UDim2.new(1, -16, 1, -16)
        resizeHandle.BackgroundColor3 = COLORS.Border
        resizeHandle.BorderSizePixel = 0
        resizeHandle.Text = ""
        resizeHandle.AutoButtonColor = false
        resizeHandle.ZIndex = 205
        resizeHandle.Parent = window

        local resizeConn1, resizeConn2, resizeConn3
        local resizing, resizeStart, startSize

        resizeConn1 = resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                resizeStart = input.Position
                startSize = window.Size
            end
        end)

        resizeConn2 = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
                local delta = input.Position - resizeStart
                local newW = math.max(400, startSize.X.Offset + delta.X)
                local newH = math.max(300, startSize.Y.Offset + delta.Y)
                window.Size = UDim2.new(0, newW, 0, newH)
            end
        end)

        resizeConn3 = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)

        local function closeEditor()
            Context.State.pluginEditorOpen = false
            FeatureState.pluginEditorWindow = nil
            pcall(function() dragConn1:Disconnect() end)
            pcall(function() dragConn2:Disconnect() end)
            pcall(function() dragConn3:Disconnect() end)
            pcall(function() resizeConn1:Disconnect() end)
            pcall(function() resizeConn2:Disconnect() end)
            pcall(function() resizeConn3:Disconnect() end)
            overlay:Destroy()
        end

        closeBtn.MouseButton1Click:Connect(closeEditor)
        closeBottomBtn.MouseButton1Click:Connect(closeEditor)

        -- Save handler
        saveBtn.MouseButton1Click:Connect(function()
            local code = inputBox.Text
            if code == "" or code == defaultText then
                statusLabel.Text = "Error: Code cannot be empty"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                return
            end

            Plugins.OpenNamePrompt(isEditing and editPluginName or nil, function(name)
                if not name or name == "" then
                    statusLabel.Text = "Error: Name is required"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    return
                end

                local success, err
                if isEditing then
                    success, err = Plugins.Update(editPluginName, name, code)
                else
                    success, err = Plugins.Add(name, code)
                end

                if success then
                    closeEditor()
                    if onSaveCallback then
                        onSaveCallback()
                    end
                else
                    statusLabel.Text = "Error: " .. tostring(err)
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end)
        end)

        FeatureState.pluginEditorWindow = window

        window.BackgroundTransparency = 1
        TweenService:Create(window, TWEEN.Appear, {BackgroundTransparency = 0}):Play()
    end

    -- ============================================================
    -- NAME PROMPT
    -- ============================================================
    function Plugins.OpenNamePrompt(defaultName, onConfirm)
        if Context.State.pluginNamePromptOpen then return end
        Context.State.pluginNamePromptOpen = true

        local ScreenGui = Context.UI.ScreenGui
        if not ScreenGui then return end

        local overlay = Instance.new("Frame")
        overlay.Name = "PluginNamePromptOverlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = COLORS.Overlay
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 300
        overlay.Parent = ScreenGui

        local promptWindow = Instance.new("Frame")
        promptWindow.Name = "PluginNamePrompt"
        promptWindow.Size = UDim2.new(0, 320, 0, 140)
        promptWindow.Position = UDim2.new(0.5, -160, 0.5, -70)
        promptWindow.BackgroundColor3 = COLORS.Background
        promptWindow.BorderSizePixel = 1
        promptWindow.BorderColor3 = COLORS.Border
        promptWindow.ZIndex = 301
        promptWindow.Parent = overlay

        local promptTitle = Instance.new("TextLabel")
        promptTitle.Size = UDim2.new(1, -20, 0, 24)
        promptTitle.Position = UDim2.new(0, 10, 0, 10)
        promptTitle.BackgroundTransparency = 1
        promptTitle.Text = "Name Your Plugin"
        promptTitle.TextColor3 = COLORS.Text
        promptTitle.TextSize = 15
        promptTitle.Font = Enum.Font.GothamBold
        promptTitle.TextXAlignment = Enum.TextXAlignment.Left
        promptTitle.ZIndex = 302
        promptTitle.Parent = promptWindow

        local nameInput = Instance.new("TextBox")
        nameInput.Size = UDim2.new(1, -20, 0, 30)
        nameInput.Position = UDim2.new(0, 10, 0, 42)
        nameInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        nameInput.BorderSizePixel = 1
        nameInput.BorderColor3 = COLORS.Border
        nameInput.Text = defaultName or ""
        nameInput.PlaceholderText = "Enter plugin name..."
        nameInput.TextColor3 = COLORS.Text
        nameInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        nameInput.TextSize = 13
        nameInput.Font = Enum.Font.Gotham
        nameInput.ClearTextOnFocus = false
        nameInput.ZIndex = 302
        nameInput.Parent = promptWindow

        local errorLabel = Instance.new("TextLabel")
        errorLabel.Size = UDim2.new(1, -20, 0, 16)
        errorLabel.Position = UDim2.new(0, 10, 0, 76)
        errorLabel.BackgroundTransparency = 1
        errorLabel.Text = ""
        errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        errorLabel.TextSize = 11
        errorLabel.Font = Enum.Font.Gotham
        errorLabel.TextXAlignment = Enum.TextXAlignment.Left
        errorLabel.ZIndex = 302
        errorLabel.Parent = promptWindow

        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size = UDim2.new(0, 90, 0, 28)
        confirmBtn.Position = UDim2.new(0, 10, 1, -38)
        confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
        confirmBtn.BorderSizePixel = 1
        confirmBtn.BorderColor3 = Color3.fromRGB(0, 180, 90)
        confirmBtn.Text = "Save"
        confirmBtn.TextColor3 = COLORS.Text
        confirmBtn.TextSize = 13
        confirmBtn.Font = Enum.Font.GothamBold
        confirmBtn.AutoButtonColor = false
        confirmBtn.ZIndex = 302
        confirmBtn.Parent = promptWindow

        confirmBtn.MouseEnter:Connect(function()
            TweenService:Create(confirmBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(0, 150, 75)}):Play()
        end)
        confirmBtn.MouseLeave:Connect(function()
            TweenService:Create(confirmBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(0, 120, 60)}):Play()
        end)

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 90, 0, 28)
        cancelBtn.Position = UDim2.new(0, 110, 1, -38)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        cancelBtn.BorderSizePixel = 1
        cancelBtn.BorderColor3 = COLORS.Border
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = COLORS.Text
        cancelBtn.TextSize = 13
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.AutoButtonColor = false
        cancelBtn.ZIndex = 302
        cancelBtn.Parent = promptWindow

        cancelBtn.MouseEnter:Connect(function()
            TweenService:Create(cancelBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end)
        cancelBtn.MouseLeave:Connect(function()
            TweenService:Create(cancelBtn, TWEEN.Hover, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        end)

        local function closePrompt()
            Context.State.pluginNamePromptOpen = false
            FeatureState.pluginNamePromptWindow = nil
            overlay:Destroy()
        end

        cancelBtn.MouseButton1Click:Connect(closePrompt)

        confirmBtn.MouseButton1Click:Connect(function()
            local name = nameInput.Text:gsub("^%s*(.-)%s*$", "%1")
            if name == "" then
                errorLabel.Text = "Name cannot be empty"
                return
            end
            closePrompt()
            if onConfirm then
                onConfirm(name)
            end
        end)

        nameInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                confirmBtn.MouseButton1Click:Fire()
            end
        end)

        FeatureState.pluginNamePromptWindow = promptWindow

        promptWindow.BackgroundTransparency = 1
        TweenService:Create(promptWindow, TWEEN.Appear, {BackgroundTransparency = 0}):Play()
    end

    -- ============================================================
    -- REFRESH PLUGIN LIST UI
    -- ============================================================
    function Plugins.RefreshListUI(listFrame, onListChanged)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local yOff = 5
        for _, plugin in ipairs(FeatureState.plugins) do
            local row = Instance.new("Frame")
            row.Name = "PluginRow_" .. plugin.name
            row.Size = UDim2.new(1, -10, 0, 32)
            row.Position = UDim2.new(0, 5, 0, yOff)
            row.BackgroundColor3 = COLORS.Background
            row.BorderSizePixel = 1
            row.BorderColor3 = COLORS.Border
            row.Parent = listFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -130, 1, 0)
            nameLabel.Position = UDim2.new(0, 8, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plugin.name
            nameLabel.TextColor3 = COLORS.Text
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = row

            local editBtn = Instance.new("TextButton")
            editBtn.Size = UDim2.new(0, 28, 0, 24)
            editBtn.Position = UDim2.new(1, -90, 0.5, -12)
            editBtn.BackgroundColor3 = COLORS.Background
            editBtn.BorderSizePixel = 1
            editBtn.BorderColor3 = COLORS.Border
            editBtn.Text = "\u{270E}"
            editBtn.TextColor3 = Color3.fromRGB(150, 200, 255)
            editBtn.TextSize = 14
            editBtn.Font = Enum.Font.GothamBold
            editBtn.AutoButtonColor = false
            editBtn.Parent = row

            editBtn.MouseEnter:Connect(function()
                TweenService:Create(editBtn, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
            end)
            editBtn.MouseLeave:Connect(function()
                TweenService:Create(editBtn, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
            end)

            editBtn.MouseButton1Click:Connect(function()
                Plugins.OpenEditor(plugin.name, plugin.code, onListChanged)
            end)

            local deleteBtn = Instance.new("TextButton")
            deleteBtn.Size = UDim2.new(0, 28, 0, 24)
            deleteBtn.Position = UDim2.new(1, -60, 0.5, -12)
            deleteBtn.BackgroundColor3 = COLORS.Background
            deleteBtn.BorderSizePixel = 1
            deleteBtn.BorderColor3 = COLORS.Border
            deleteBtn.Text = "\u{2715}"
            deleteBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            deleteBtn.TextSize = 14
            deleteBtn.Font = Enum.Font.GothamBold
            deleteBtn.AutoButtonColor = false
            deleteBtn.Parent = row

            deleteBtn.MouseEnter:Connect(function()
                TweenService:Create(deleteBtn, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
            end)
            deleteBtn.MouseLeave:Connect(function()
                TweenService:Create(deleteBtn, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
            end)

            deleteBtn.MouseButton1Click:Connect(function()
                Plugins.Delete(plugin.name)
                if onListChanged then
                    onListChanged()
                end
            end)

            local toggleBg = Instance.new("TextButton")
            toggleBg.Size = UDim2.new(0, 44, 0, 20)
            toggleBg.Position = UDim2.new(1, -52, 0.5, -10)
            toggleBg.BackgroundColor3 = plugin.enabled and COLORS.ToggleOn or COLORS.ToggleOff
            toggleBg.BorderSizePixel = 1
            toggleBg.BorderColor3 = COLORS.Border
            toggleBg.Text = ""
            toggleBg.AutoButtonColor = false
            toggleBg.Parent = row

            local toggleKnob = Instance.new("Frame")
            toggleKnob.Size = UDim2.new(0, 16, 0, 16)
            toggleKnob.Position = plugin.enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleKnob.BackgroundColor3 = COLORS.Text
            toggleKnob.BorderSizePixel = 0
            toggleKnob.Parent = toggleBg

            toggleBg.MouseButton1Click:Connect(function()
                local newState = Plugins.Toggle(plugin.name)
                if newState then
                    TweenService:Create(toggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOn}):Play()
                    TweenService:Create(toggleKnob, TWEEN.Hover, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                else
                    TweenService:Create(toggleBg, TWEEN.Hover, {BackgroundColor3 = COLORS.ToggleOff}):Play()
                    TweenService:Create(toggleKnob, TWEEN.Hover, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                end
            end)

            yOff = yOff + 37
        end

        return yOff + 5
    end

    function Plugins.Cleanup()
        for name, _ in pairs(FeatureState.pluginRunningThreads) do
            stopPlugin(name)
        end
        FeatureState.plugins = {}
    end

    print("[Feature] Plugins module loaded.")
    return Plugins
end
