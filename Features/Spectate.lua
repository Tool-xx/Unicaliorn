-- Features/Spectate.lua
-- Spectate feature: free-look camera following target player
-- Mouse controls: move = rotate, wheel = zoom
-- Receives Context, returns Feature table

return function(Context)
    local RunService = Context.Services.RunService
    local UserInputService = Context.Services.UserInputService
    local FeatureState = Context.FeatureState

    local Spectate = {}

    -- ============================================================
    -- START SPECTATING
    -- ============================================================
    function Spectate.Start(player)
        if FeatureState.activeSpectatePlayer == player then
            Spectate.Stop()
            return false
        end

        -- Stop current if any
        if FeatureState.activeSpectatePlayer then
            Spectate.Stop()
        end

        print("[Spectate] Watching " .. player.Name)
        FeatureState.activeSpectatePlayer = player

        local camera = workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Scriptable

        FeatureState.spectateDistance = 10
        FeatureState.spectateYaw = 0
        FeatureState.spectatePitch = -math.rad(15)

        -- RenderStepped: update camera position
        FeatureState.spectateConnection = RunService.RenderStepped:Connect(function()
            if FeatureState.activeSpectatePlayer and FeatureState.activeSpectatePlayer.Character then
                local root = FeatureState.activeSpectatePlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local offset = CFrame.fromOrientation(
                        FeatureState.spectatePitch,
                        FeatureState.spectateYaw,
                        0
                    ) * Vector3.new(0, 0, FeatureState.spectateDistance)
                    local cameraPos = root.Position + offset
                    local lookAt = root.Position + Vector3.new(0, 3, 0)
                    camera.CFrame = CFrame.lookAt(cameraPos, lookAt)
                end
            end
        end)

        -- Mouse movement: rotate camera
        local lastMousePos = UserInputService:GetMouseLocation()
        FeatureState.spectateInputConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if FeatureState.activeSpectatePlayer then
                    local currentPos = UserInputService:GetMouseLocation()
                    local delta = currentPos - lastMousePos
                    lastMousePos = currentPos
                    local sensitivity = Config.DEFAULTS.SpectateYawSens * (math.rad(1))
                    FeatureState.spectateYaw = FeatureState.spectateYaw - delta.X * sensitivity
                    FeatureState.spectatePitch = math.clamp(
                        FeatureState.spectatePitch - delta.Y * sensitivity,
                        Config.DEFAULTS.SpectatePitchMin,
                        Config.DEFAULTS.SpectatePitchMax
                    )
                end
            end
        end)

        -- Mouse wheel: zoom
        FeatureState.spectateWheelConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                if FeatureState.activeSpectatePlayer then
                    FeatureState.spectateDistance = math.clamp(
                        FeatureState.spectateDistance - input.Position.Z * 0.5,
                        Config.DEFAULTS.SpectateDistMin,
                        Config.DEFAULTS.SpectateDistMax
                    )
                end
            end
        end)

        return true
    end

    -- ============================================================
    -- STOP SPECTATING
    -- ============================================================
    function Spectate.Stop()
        if not FeatureState.activeSpectatePlayer then return end

        print("[Spectate] Stopped watching " .. FeatureState.activeSpectatePlayer.Name)

        if FeatureState.spectateConnection then
            FeatureState.spectateConnection:Disconnect()
            FeatureState.spectateConnection = nil
        end
        if FeatureState.spectateInputConnection then
            FeatureState.spectateInputConnection:Disconnect()
            FeatureState.spectateInputConnection = nil
        end
        if FeatureState.spectateWheelConnection then
            FeatureState.spectateWheelConnection:Disconnect()
            FeatureState.spectateWheelConnection = nil
        end

        FeatureState.activeSpectatePlayer = nil
        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end)
    end

    -- ============================================================
    -- TOGGLE (convenience for UI)
    -- ============================================================
    function Spectate.Toggle(player)
        if FeatureState.activeSpectatePlayer == player then
            Spectate.Stop()
            return false
        else
            return Spectate.Start(player)
        end
    end

    -- ============================================================
    -- GET TARGET
    -- ============================================================
    function Spectate.GetTarget()
        return FeatureState.activeSpectatePlayer
    end

    -- ============================================================
    -- IS SPECTATING
    -- ============================================================
    function Spectate.IsSpectating()
        return FeatureState.activeSpectatePlayer ~= nil
    end

    print("[Feature] Spectate module loaded.")
    return Spectate
end
