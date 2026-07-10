-- Features/Speedhack.lua
-- Speedhack feature: modifies WalkSpeed with auto-apply on respawn
-- Receives Context, returns Feature table

return function(Context)
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config

    local Speedhack = {}

    -- ============================================================
    -- APPLY SPEED TO CURRENT CHARACTER
    -- ============================================================
    local function applySpeed(speed)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = speed
            end
        end
    end

    -- ============================================================
    -- ENABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Enable()
        if FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = true
        print("[Speedhack] Enabled (" .. FeatureState.speedhackSpeed .. ")")
        applySpeed(FeatureState.speedhackSpeed)

        FeatureState.speedhackCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 10)
            if hum and FeatureState.speedhackEnabled then
                hum.WalkSpeed = FeatureState.speedhackSpeed
            end
        end)
    end

    -- ============================================================
    -- DISABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Disable()
        if not FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = false
        print("[Speedhack] Disabled")
        if FeatureState.speedhackCharConnection then
            FeatureState.speedhackCharConnection:Disconnect()
            FeatureState.speedhackCharConnection = nil
        end
        applySpeed(Config.DEFAULTS.WalkSpeed)
    end

    -- ============================================================
    -- SET SPEED VALUE
    -- ============================================================
    function Speedhack.SetSpeed(value)
        FeatureState.speedhackSpeed = value
        if FeatureState.speedhackEnabled then
            applySpeed(value)
        end
    end

    -- ============================================================
    -- GET SPEED VALUE
    -- ============================================================
    function Speedhack.GetSpeed()
        return FeatureState.speedhackSpeed
    end

    -- ============================================================
    -- TOGGLE
    -- ============================================================
    function Speedhack.Toggle()
        if FeatureState.speedhackEnabled then
            Speedhack.Disable()
            return false
        else
            Speedhack.Enable()
            return true
        end
    end

    -- ============================================================
    -- IS ENABLED
    -- ============================================================
    function Speedhack.IsEnabled()
        return FeatureState.speedhackEnabled
    end

    print("[Feature] Speedhack module loaded.")
    return Speedhack
end
