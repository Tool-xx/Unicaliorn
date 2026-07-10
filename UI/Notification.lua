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
    -- LOAD IMAGE
    -- ============================================================
    local function loadLogo()
        if writefile and readfile and getcustomasset then
            local logoPath = "Unicaliorn_logo.png"
            local success, cached = pcall(function()
                return readfile(logoPath)
            end)
            if success and cached and #cached > 0 then
                return getcustomasset(logoPath)
            end

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

        -- Main container (sharp corners)
        local notif = Instance.new("Frame")
        notif.Name = "InjectionNotification"
        notif.Size = UDim2.new(0, 320, 0, 100)
        notif.Position = UDim2.new(1, 20, 1, 20)
        notif.BackgroundColor3 = COLORS.Background
        notif.BackgroundTransparency = 0.1
        notif.BorderSizePixel = 1
        notif.BorderColor3 = COLORS.Border
        notif.Parent = ScreenGui

        -- Logo
        local logo = Instance.new("ImageLabel")
        logo.Name = "Logo"
        logo.Size = UDim2.new(0, 64, 0, 64)
        logo.Position = UDim2.new(0, 12, 0.5, -32)
        logo.BackgroundTransparency = 1
        logo.BorderSizePixel = 0
        logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
        logo.Parent = notif

        local logoAsset = loadLogo()
        if logoAsset then
            logo.Image = logoAsset
        else
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
        end

        -- Title text
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, -100, 0, 24)
        titleLabel.Position = UDim2.new(0, 88, 0, 18)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "Unicaliorn"
        titleLabel.TextColor3 = COLORS.Text
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

        -- Glow effect
        local glow = Instance.new("ImageLabel")
        glow.Name = "Glow"
        glow.Size = UDim2.new(1, 40, 1, 40)
        glow.Position = UDim2.new(0, -20, 0, -20)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://4996891970"
        glow.ImageColor3 = Color3.fromRGB(0, 255, 128)
        glow.ImageTransparency = 0.9
        glow.ScaleType = Enum.ScaleType.Stretch
        glow.Parent = notif

        -- Animate in
        TweenService:Create(notif, TWEEN.Appear, {
            Position = UDim2.new(1, -340, 1, -120)
        }):Play()

        -- Auto close after 4 seconds
        task.delay(4, function()
            if notif and notif.Parent then
                Notification.Close(notif)
            end
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
