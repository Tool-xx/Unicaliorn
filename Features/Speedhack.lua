-- Features/Speedhack.lua (Universal CFrame-based)
return function(Context)
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config
    local RunService = Context.Services.RunService
    local UserInputService = Context.Services.UserInputService

    local Speedhack = {}
    local heartbeatConnection = nil
    local lastPosition = nil

    -- ============================================================
    -- GET MOVEMENT DIRECTION FROM INPUT
    -- ============================================================
    local function getMoveDirection()
        local camera = workspace.CurrentCamera
        if not camera then return Vector3.zero end
        
        local moveDir = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        
        -- Убираем Y-компонент (чтобы не летать при W/S)
        moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end
        
        return moveDir
    end

    -- ============================================================
    -- CFRAME SPEEDHACK LOOP
    -- ============================================================
    local function startSpeedLoop()
        if heartbeatConnection then return end
        
        heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
            if not FeatureState.speedhackEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            local moveDir = getMoveDirection()
            if moveDir.Magnitude == 0 then 
                lastPosition = root.Position
                return 
            end
            
            -- Рассчитываем новую позицию
            local speed = FeatureState.speedhackSpeed
            local newPos = root.Position + (moveDir * speed * dt)
            
            -- Сохраняем высоту (чтобы не проваливаться)
            if hum then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), rayParams)
                if ray then
                    newPos = Vector3.new(newPos.X, math.max(newPos.Y, ray.Position.Y + hum.HipHeight + 1), newPos.Z)
                end
            end
            
            -- Применяем через CFrame
            root.CFrame = CFrame.new(newPos) * CFrame.Angles(0, math.atan2(moveDir.X, moveDir.Z), 0)
            lastPosition = newPos
        end)
    end

    local function stopSpeedLoop()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        lastPosition = nil
    end

    -- ============================================================
    -- ENABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Enable()
        if FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = true
        print("[Speedhack] Enabled CFrame mode (" .. FeatureState.speedhackSpeed .. ")")
        
        startSpeedLoop()

        -- На респавн перезапускаем
        FeatureState.speedhackCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            if not FeatureState.speedhackEnabled then return end
            task.wait(0.2)
            startSpeedLoop()
        end)
    end

    -- ============================================================
    -- DISABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Disable()
        if not FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = false
        print("[Speedhack] Disabled")
        
        stopSpeedLoop()
        
        if FeatureState.speedhackCharConnection then
            FeatureState.speedhackCharConnection:Disconnect()
            FeatureState.speedhackCharConnection = nil
        end
        
        -- Восстанавливаем WalkSpeed на всякий случай
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Config.DEFAULTS.WalkSpeed
            end
        end
    end

    -- ============================================================
    -- SET SPEED VALUE
    -- ============================================================
    function Speedhack.SetSpeed(value)
        FeatureState.speedhackSpeed = value
    end

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

    function Speedhack.IsEnabled()
        return FeatureState.speedhackEnabled
    end

    print("[Feature] Speedhack module loaded (CFrame universal).")
    return Speedhack
end
