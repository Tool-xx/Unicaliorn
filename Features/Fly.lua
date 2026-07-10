-- Features/Fly.lua
-- Fly feature: fly with BodyGyro + BodyVelocity, WASD + QE controls
-- Receives Context, returns Feature table

return function(Context)
    local UserInputService = Context.Services.UserInputService
    local RunService = Context.Services.RunService
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config

    local Fly = {}

    -- ============================================================
    -- START FLY
    -- ============================================================
    function Fly.Start()
        if FeatureState.flyEnabled then return end
        FeatureState.flyEnabled = true
        print("[Fly] Enabled (" .. FeatureState.flySpeed .. ")")

        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local root = humanoid.RootPart
        if not root then return end

        -- Create physics objects
        FeatureState.flyBodyGyro = Instance.new("BodyGyro")
        FeatureState.flyBodyGyro.P = 9e4
        FeatureState.flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FeatureState.flyBodyGyro.Parent = root

        FeatureState.flyBodyVelocity = Instance.new("BodyVelocity")
        FeatureState.flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FeatureState.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FeatureState.flyBodyVelocity.Parent = root

        -- Reset controls
        FeatureState.flyControl = {F=0, B=0, L=0, R=0, Q=0, E=0}
        FeatureState.flyLastControl = {F=0, B=0, L=0, R=0, Q=0, E=0}
        FeatureState.flyCurrentSpeed = 0

        -- Input handlers
        FeatureState.flyInputBegan = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            local spd = FeatureState.flySpeed
            if input.KeyCode == Enum.KeyCode.W then FeatureState.flyControl.F = spd
            elseif input.KeyCode == Enum.KeyCode.S then FeatureState.flyControl.B = -spd
            elseif input.KeyCode == Enum.KeyCode.A then FeatureState.flyControl.L = -spd
            elseif input.KeyCode == Enum.KeyCode.D then FeatureState.flyControl.R = spd
            elseif input.KeyCode == Enum.KeyCode.E then FeatureState.flyControl.Q = spd*2
            elseif input.KeyCode == Enum.KeyCode.Q then FeatureState.flyControl.E = -spd*2
            end
            pcall(function()
                workspace.CurrentCamera.CameraType = Enum.CameraType.Track
            end)
        end)

        FeatureState.flyInputEnded = UserInputService.InputEnded:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then FeatureState.flyControl.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then FeatureState.flyControl.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then FeatureState.flyControl.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then FeatureState.flyControl.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then FeatureState.flyControl.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then FeatureState.flyControl.E = 0
            end
        end)

        -- Physics loop
        FeatureState.flyLoop = RunService.RenderStepped:Connect(function()
            if not FeatureState.flyEnabled then return end
            local camera = workspace.CurrentCamera
            if humanoid and humanoid.Parent then
                humanoid.PlatformStand = true
            end

            local spd = FeatureState.flySpeed
            local ctrl = FeatureState.flyControl
            local isMoving = ctrl.L + ctrl.R ~= 0 or ctrl.F + ctrl.B ~= 0 or ctrl.Q + ctrl.E ~= 0

            if isMoving then
                FeatureState.flyCurrentSpeed = spd
            elseif FeatureState.flyCurrentSpeed ~= 0 then
                FeatureState.flyCurrentSpeed = 0
            end

            if isMoving then
                FeatureState.flyBodyVelocity.Velocity = (
                    (camera.CFrame.LookVector * (ctrl.F + ctrl.B)) +
                    ((camera.CFrame * CFrame.new(
                        ctrl.L + ctrl.R,
                        (ctrl.F + ctrl.B + ctrl.Q + ctrl.E) * 0.2,
                        0
                    ).p) - camera.CFrame.p)
                ) * FeatureState.flyCurrentSpeed
                FeatureState.flyLastControl = {
                    F=ctrl.F, B=ctrl.B, L=ctrl.L, R=ctrl.R
                }
            elseif FeatureState.flyCurrentSpeed ~= 0 then
                FeatureState.flyBodyVelocity.Velocity = (
                    (camera.CFrame.LookVector * (FeatureState.flyLastControl.F + FeatureState.flyLastControl.B)) +
                    ((camera.CFrame * CFrame.new(
                        FeatureState.flyLastControl.L + FeatureState.flyLastControl.R,
                        (FeatureState.flyLastControl.F + FeatureState.flyLastControl.B + ctrl.Q + ctrl.E) * 0.2,
                        0
                    ).p) - camera.CFrame.p)
                ) * FeatureState.flyCurrentSpeed
            else
                FeatureState.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            FeatureState.flyBodyGyro.CFrame = camera.CFrame
        end)
    end

    -- ============================================================
    -- STOP FLY
    -- ============================================================
    function Fly.Stop()
        if not FeatureState.flyEnabled then return end
        FeatureState.flyEnabled = false
        print("[Fly] Disabled")

        if FeatureState.flyInputBegan then
            FeatureState.flyInputBegan:Disconnect()
            FeatureState.flyInputBegan = nil
        end
        if FeatureState.flyInputEnded then
            FeatureState.flyInputEnded:Disconnect()
            FeatureState.flyInputEnded = nil
        end
        if FeatureState.flyLoop then
            FeatureState.flyLoop:Disconnect()
            FeatureState.flyLoop = nil
        end
        if FeatureState.flyCharConnection then
            FeatureState.flyCharConnection:Disconnect()
            FeatureState.flyCharConnection = nil
        end

        if FeatureState.flyBodyGyro then
            FeatureState.flyBodyGyro:Destroy()
            FeatureState.flyBodyGyro = nil
        end
        if FeatureState.flyBodyVelocity then
            FeatureState.flyBodyVelocity:Destroy()
            FeatureState.flyBodyVelocity = nil
        end

        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end)
    end

    -- ============================================================
    -- SET SPEED
    -- ============================================================
    function Fly.SetSpeed(value)
        FeatureState.flySpeed = value
    end

    function Fly.GetSpeed()
        return FeatureState.flySpeed
    end

    -- ============================================================
    -- TOGGLE
    -- ============================================================
    function Fly.Toggle()
        if FeatureState.flyEnabled then
            Fly.Stop()
            return false
        else
            Fly.Start()
            return true
        end
    end

    -- ============================================================
    -- IS ENABLED
    -- ============================================================
    function Fly.IsEnabled()
        return FeatureState.flyEnabled
    end

    -- ============================================================
    -- AUTO-RESTART ON RESPAWN
    -- ============================================================
    FeatureState.flyCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        if FeatureState.flyEnabled then
            Fly.Stop()
            task.wait(0.2)
            if not FeatureState.flyEnabled then return end
            Fly.Start()
        end
    end)

    print("[Feature] Fly module loaded.")
    return Fly
end
