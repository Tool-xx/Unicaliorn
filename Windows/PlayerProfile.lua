-- Windows/PlayerProfile.lua
-- Player Profile window: displays player stats, health, position, etc.
-- Receives Context, returns Window table

return function(Context)
    local WindowManager = Context.UI.WindowManager
    local Config = Context.Config

    local PlayerProfile = {}

    -- ============================================================
    -- OPEN PROFILE WINDOW
    -- ============================================================
    function PlayerProfile.Open(targetPlayer)
        print("[Profile] Opened for " .. targetPlayer.Name)

        local win = WindowManager.createBaseWindow({
            title = "Profile: " .. targetPlayer.Name,
            width = 300,
            height = 350,
            startY = -200,
            targetY = -175,
            hasScroll = true,
        })

        local content = win.content

        local char = targetPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = hum and hum.RootPart

        local health = hum and hum.Health or 0
        local maxHealth = hum and hum.MaxHealth or 0
        local walkspeed = hum and hum.WalkSpeed or 0
        local jumppower = hum and hum.JumpPower or 0
        local team = targetPlayer.Team and targetPlayer.Team.Name or "None"
        local pos = root and root.Position or Vector3.zero
        local alive = hum and hum.Health > 0

        local lines = {
            "Name: " .. targetPlayer.Name,
            "Display: @" .. targetPlayer.DisplayName,
            "UserID: " .. targetPlayer.UserId,
            "Team: " .. team,
            "Health: " .. string.format("%.1f", health) .. " / " .. string.format("%.1f", maxHealth),
            "WalkSpeed: " .. walkspeed,
            "JumpPower: " .. jumppower,
            "Status: " .. (alive and "Alive" or "Dead"),
            "Position: " .. string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z),
        }

        local yOffset = 5
        for _, line in ipairs(lines) do
            yOffset = WindowManager.addTextLine(content, line, yOffset, {
                height = 18,
                spacing = 2,
                size = 13,
                font = Enum.Font.Gotham,
            })
        end

        -- Copy UserID button
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(1, -20, 0, 25)
        copyBtn.Position = UDim2.new(0, 10, 0, yOffset + 5)
        copyBtn.BackgroundColor3 = Config.COLORS.Background
        copyBtn.BorderSizePixel = 1
        copyBtn.BorderColor3 = Config.COLORS.Border
        copyBtn.Text = "Copy UserID"
        copyBtn.TextColor3 = Config.COLORS.Text
        copyBtn.TextSize = 13
        copyBtn.Font = Enum.Font.Gotham
        copyBtn.AutoButtonColor = false
        copyBtn.Parent = content
        copyBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(tostring(targetPlayer.UserId)) end)
            copyBtn.Text = "Copied!"
            task.delay(1.5, function()
                if copyBtn and copyBtn.Parent then
                    copyBtn.Text = "Copy UserID"
                end
            end)
        end)

        yOffset = yOffset + 40
        WindowManager.updateCanvasSize(content, yOffset)

        return win
    end

    print("[Window] PlayerProfile module loaded.")
    return PlayerProfile
end
