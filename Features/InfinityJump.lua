-- Features/InfinityJump.lua
-- Infinity Jump feature: allows jumping mid-air indefinitely
-- Receives Context, returns Feature table

return function(Context)
    local UserInputService = Context.Services.UserInputService
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer

    local InfinityJump = {}

    -- ============================================================
    -- ENABLE INFINITY JUMP
    -- ============================================================
    function InfinityJump.Enable()
        if FeatureState.infinityJumpEnabled then return end
        FeatureState.infinityJumpEnabled = true
        print("[InfinityJump] Enabled")

        FeatureState.infinityJumpConnection = UserInputService.JumpRequest:Connect(function()
            if not FeatureState.infinityJumpEnabled then return end

            local char = LocalPlayer.Character
            if not char then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local root = hum.RootPart
            if not root then return end

            local currentVel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(
                currentVel.X,
                hum.JumpPower,
                currentVel.Z
            )
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end

    -- ============================================================
    -- DISABLE INFINITY JUMP
    -- ============================================================
    function InfinityJump.Disable()
        if not FeatureState.infinityJumpEnabled then return end
        FeatureState.infinityJumpEnabled = false
        print("[InfinityJump] Disabled")
        if FeatureState.infinityJumpConnection then
            FeatureState.infinityJumpConnection:Disconnect()
            FeatureState.infinityJumpConnection = nil
        end
    end

    -- ============================================================
    -- TOGGLE
    -- ============================================================
    function InfinityJump.Toggle()
        if FeatureState.infinityJumpEnabled then
            InfinityJump.Disable()
            return false
        else
            InfinityJump.Enable()
            return true
        end
    end

    -- ============================================================
    -- IS ENABLED
    -- ============================================================
    function InfinityJump.IsEnabled()
        return FeatureState.infinityJumpEnabled
    end

    print("[Feature] InfinityJump module loaded.")
    return InfinityJump
end
