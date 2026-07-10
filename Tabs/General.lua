-- Tabs/General.lua
-- General tab: player info, avatar, server name, Rejoin, Server Hop, Server Info buttons
-- Receives Context, returns tab content frame

return function(Context)
    local Players = Context.Services.Players
    local TeleportService = Context.Services.TeleportService
    local MarketplaceService = Context.Services.MarketplaceService
    local Config = Context.Config
    local COLORS = Config.COLORS
    local Components = Context.UI.Components
    local LocalPlayer = Context.LocalPlayer

    -- ============================================================
    -- CREATE CONTENT
    -- ============================================================
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_General"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.Border
    content.CanvasSize = UDim2.new(0, 0, 0, 300)
    content.Visible = false
    content.Parent = Context.UI.ContentFrame

    -- Player info frame
    local playerInfoFrame = Instance.new("Frame")
    playerInfoFrame.Name = "PlayerInfo"
    playerInfoFrame.Size = UDim2.new(1, -20, 0, 80)
    playerInfoFrame.Position = UDim2.new(0, 10, 0, 10)
    playerInfoFrame.BackgroundColor3 = COLORS.Background
    playerInfoFrame.BorderSizePixel = 1
    playerInfoFrame.BorderColor3 = COLORS.Border
    playerInfoFrame.Parent = content

    -- Avatar
    local skinImage = Instance.new("ImageLabel")
    skinImage.Size = UDim2.new(0, 60, 0, 60)
    skinImage.Position = UDim2.new(0, 10, 0.5, -30)
    skinImage.BackgroundColor3 = COLORS.Background
    skinImage.BorderSizePixel = 1
    skinImage.BorderColor3 = COLORS.Border
    task.spawn(function()
        local success, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if success then skinImage.Image = thumb end
    end)
    skinImage.Parent = playerInfoFrame

    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -90, 0, 25)
    nameLabel.Position = UDim2.new(0, 80, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = LocalPlayer.Name
    nameLabel.TextColor3 = COLORS.Text
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = playerInfoFrame

    -- Display name
    local displayLabel = Instance.new("TextLabel")
    displayLabel.Size = UDim2.new(1, -90, 0, 20)
    displayLabel.Position = UDim2.new(0, 80, 0, 32)
    displayLabel.BackgroundTransparency = 1
    displayLabel.Text = "@" .. LocalPlayer.DisplayName
    displayLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    displayLabel.TextSize = 12
    displayLabel.Font = Enum.Font.Gotham
    displayLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayLabel.Parent = playerInfoFrame

    -- Server name
    local serverLabel = Instance.new("TextLabel")
    serverLabel.Size = UDim2.new(1, -90, 0, 20)
    serverLabel.Position = UDim2.new(0, 80, 0, 52)
    serverLabel.BackgroundTransparency = 1
    local placeName = "Loading..."
    task.spawn(function()
        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            placeName = info.Name
            serverLabel.Text = "Server: " .. placeName
        end)
    end)
    serverLabel.Text = "Server: " .. placeName
    serverLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    serverLabel.TextSize = 12
    serverLabel.Font = Enum.Font.Gotham
    serverLabel.TextXAlignment = Enum.TextXAlignment.Left
    serverLabel.Parent = playerInfoFrame

    -- Buttons
    Components.createButton(content, "Rejoin", 110, function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end)
    end)

    Components.createButton(content, "Server Hop", 155, function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end)

    Components.createButton(content, "Server Info", 200, function()
        if Context.Windows.ServerInfo and Context.Windows.ServerInfo.Open then
            Context.Windows.ServerInfo.Open()
        end
    end)

    -- Register tab
    Context.UI.Main.registerTabContent("General", content)

    print("[Tab] General loaded.")
    return content
end
