-- Features/Noclip.lua
-- Noclip feature: disables collision for all character parts
-- Receives Context, returns Feature table

return function(Context)
    local RunService = Context.Services.RunService
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer

    local Noclip = {}

    -- ============================================================
    -- ENABLE NOCLIP
    -- ============================================================
    function Noclip.Enable()
        if FeatureState.noclipEnabled then return end
        FeatureState.noclipEnabled = true
        print("[Noclip] Enabled")

        FeatureState.noclipConnection = RunService.Stepped:Connect(function()
            if FeatureState.noclipEnabled then
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide == true then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    -- ============================================================
    -- DISABLE NOCLIP
    -- ============================================================
    function Noclip.Disable()
        if not FeatureState.noclipEnabled then return end
        FeatureState.noclipEnabled = false
        print("[Noclip] Disabled")

        if FeatureState.noclipConnection then
            FeatureState.noclipConnection:Disconnect()
            FeatureState.noclipConnection = nil
        end

        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end

    -- ============================================================
    -- TOGGLE
    -- ============================================================
    function Noclip.Toggle()
        if FeatureState.noclipEnabled then
            Noclip.Disable()
            return false
        else
            Noclip.Enable()
            return true
        end
    end

    -- ============================================================
    -- IS ENABLED
    -- ============================================================
    function Noclip.IsEnabled()
        return FeatureState.noclipEnabled
    end

    print("[Feature] Noclip module loaded.")
    return Noclip
end
