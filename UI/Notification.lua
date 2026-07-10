-- UI/Notification.lua
-- Injection notification: slides in from bottom-right with logo
-- Uses getcustomasset for universal image loading
-- Receives Context

return function(Context)
    local TweenService = Context.Services.TweenService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local TWEEN = Config.TWEEN
    local BASE_URL = Context.BASE_URL or "https://raw.githubusercontent.com/Tool-xx/Unicaliorn/main/"

    local Notification = {}

    -- ============================================================
    -- BASE64 ENCODE/DECODE HELPERS
    -- ============================================================
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    local function base64Encode(data)
        local result = {}
        local padding = ""
        local remainder = #data % 3
        if remainder == 1 then
            padding = "=="
            data = data .. "\0\0"
        elseif remainder == 2 then
            padding = "="
            data = data .. "\0"
        end

        for i = 1, #data, 3 do
            local a, b, c = string.byte(data, i, i + 2)
            local n = a * 65536 + b * 256 + c
            table.insert(result, b64chars:sub(math.floor(n / 262144) % 64 + 1, math.floor(n / 262144) % 64 + 1))
            table.insert(result, b64chars:sub(math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1))
            table.insert(result, b64chars:sub(math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1))
            table.insert(result, b64chars:sub(n % 64 + 1, n % 64 + 1))
        end

        local out = table.concat(result)
        if padding ~= "" then
            out = out:sub(1, -1 - #padding) .. padding
        end
        return out
    end

    local function base64Decode(data)
        local result = {}
        local decodeMap = {}
        for i = 1, #b64chars do
            decodeMap[b64chars:sub(i, i)] = i - 1
        end
        decodeMap["="] = 0

        data = data:gsub("[^" .. b64chars .. "=]", "")

        for i = 1, #data, 4 do
            local a = decodeMap[data:sub(i, i)] or 0
            local b = decodeMap[data:sub(i + 1, i + 1)] or 0
            local c = decodeMap[data:sub(i + 2, i + 2)] or 0
            local d = decodeMap[data:sub(i + 3, i + 3)] or 0
            local n = a * 262144 + b * 4096 + c * 64 + d
            table.insert(result, string.char(math.floor(n / 65536) % 256))
            if data:sub(i + 2, i + 2) ~= "=" then
                table.insert(result, string.char(math.floor(n / 256) % 256))
            end
            if data:sub(i + 3, i + 3) ~= "=" then
                table.insert(result, string.char(n % 256))
            end
        end
        return table.concat(result)
    end

    -- ============================================================
    -- LOAD IMAGE
    -- ============================================================
    local function loadLogo()
        -- Try getcustomasset approach
        if writefile and readfile and getcustomasset then
            local logoPath = "Unicaliorn_logo.png"
            -- Check if already cached
            local success, cached = pcall(function()
                return readfile(logoPath)
            end)
            if success and cached and #cached > 0 then
                return getcustomasset(logoPath)
            end

            -- Download and cache
            local url = BASE_URL .. "logo.png"
            local dlSuccess, response = pcall(function()
                return game:HttpGet(url, true)
            end)
            if dlSuccess and response and #response > 0 then
                pcall(function()
                    writefile(logoPath, response)
                end)
                return getcustomasset(logoPath)
            end
        end
        return nil
    end

    -- ============================================================
    -- CREATE NOTIFICATION
    -- ============================================================
    function Notification.Show()
        local ScreenGui = Context.UI.ScreenGui
        if not ScreenGui then return end

        -- Main container
        local notif = Instance.new("Frame")
        notif.Name = "InjectionNotification"
        notif.Size = UDim2.new(0, 320, 0, 100)
        notif.Position = UDim2.new(1, 20, 1, 20) -- Start off-screen bottom-right
        notif.BackgroundColor3 = COLORS.Background
        notif.BackgroundTransparency = 0.1
        notif.BorderSizePixel = 1
        notif.BorderColor3 = COLORS.Border
        notif.Parent = ScreenGui

        -- Corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notif

        -- Logo
        local logo = Instance.new("ImageLabel")
        logo.Name = "Logo"
        logo.Size = UDim2.new(0, 64, 0, 64)
        logo.Position = UDim2.new(0, 12, 0.5, -32)
        logo.BackgroundTransparency = 1
        logo.BorderSizePixel = 0
        logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
        logo.Parent = notif

        -- Try to load logo image
        local logoAsset = loadLogo()
        if logoAsset then
            logo.Image = logoAsset
        else
            -- Fallback: stylized "U" text logo
            logo:Destroy()
            local textLogo = Instance.new("TextLabel")
            textLogo.Name = "TextLogo"
            textLogo.Size = UDim2.new(0, 64, 0, 64)
            textLogo.Position = UDim2.new(0, 12, 0.5, -32)
            textLogo.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
            textLogo.BackgroundTransparency = 0.2
            textLogo.BorderSizePixel = 0
            textLogo.Text = "U"
            textLogo.TextColor3 = Color3.fromRGB(0, 0, 0)
            textLogo.TextSize = 36
            textLogo.Font = Enum.Font.GothamBlack
            textLogo.Parent = notif
            local textCorner = Instance.new("UICorner")
            textCorner.CornerRadius = UDim.new(0, 12)
            textCorner.Parent = textLogo
        end

        -- Title text
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, -100, 0, 24)
        titleLabel.Position = UDim2.new(0, 88, 0, 18)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "Unicaliorn"
        titleLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.GothamBlack
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = notif

        -- Subtitle text
        local subtitleLabel = Instance.new("TextLabel")
        subtitleLabel.Name = "Subtitle"
        subtitleLabel.Size = UDim2.new(1, -100, 0, 18)
        subtitleLabel.Position = UDim2.new(0, 88, 0, 44)
        subtitleLabel.BackgroundTransparency = 1
        subtitleLabel.Text = "successfully injected, wait a little bit"
        subtitleLabel.TextColor3 = COLORS.Text
        subtitleLabel.TextSize = 12
        subtitleLabel.Font = Enum.Font.Gotham
        subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        subtitleLabel.TextWrapped = true
        subtitleLabel.Parent = notif

        -- Close button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "Close"
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -28, 0, 4)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = COLORS.Text
        closeBtn.TextSize = 14
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = notif

        -- Glow effect (subtle)
        local glow = Instance.new("ImageLabel")
        glow.Name = "Glow"
        glow.Size = UDim2.new(1, 40, 1, 40)
        glow.Position = UDim2.new(0, -20, 0, -20)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://4996891970" -- soft glow
        glow.ImageColor3 = Color3.fromRGB(0, 255, 128)
        glow.ImageTransparency = 0.9
        glow.ScaleType = Enum.ScaleType.Stretch
        glow.Parent = notif

        -- Animate in
        TweenService:Create(notif, TWEEN.Appear, {
            Position = UDim2.new(1, -340, 1, -120)
        }):Play()

        -- Auto close after 4 seconds
        local autoCloseThread = task.delay(4, function()
            if notif and notif.Parent then
                Notification.Close(notif)
            end
        end)

        closeBtn.MouseButton1Click:Connect(function()
            pcall(function() task.cancel(autoCloseThread) end)
            Notification.Close(notif)
        end)
    end

    -- ============================================================
    -- CLOSE NOTIFICATION
    -- ============================================================
    function Notification.Close(notif)
        if not notif or not notif.Parent then return end
        local tween = TweenService:Create(notif, TWEEN.Close, {
            Position = UDim2.new(1, 20, 1, 20),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            if notif and notif.Parent then
                notif:Destroy()
            end
        end)
    end

    print("[Notification] Notification module loaded.")
    return Notification
end
