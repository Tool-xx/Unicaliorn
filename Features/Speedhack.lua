-- Features/Speedhack.lua
-- Speedhack feature: modifies WalkSpeed with auto-apply on respawn
-- Receives Context, returns Feature table

return function(Context)
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer
    local Config = Context.Config
    local RunService = Context.Services.RunService

    local Speedhack = {}

    -- ============================================================
    -- APPLY SPEED TO CURRENT CHARACTER (с retry)
    -- ============================================================
    local function applySpeed(speed)
        local char = LocalPlayer.Character
        if not char then return false end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            -- Пробуем подождать Humanoid если персонаж только что заспавнился
            hum = char:WaitForChild("Humanoid", 2)
            if not hum then return false end
        end
        
        hum.WalkSpeed = speed
        return true
    end

    -- ============================================================
    -- FORCE APPLY (с задержкой для обхода race condition)
    -- ============================================================
    local function forceApplySpeed(speed, retries)
        retries = retries or 3
        local applied = applySpeed(speed)
        
        if not applied and retries > 0 then
            task.delay(0.1, function()
                if FeatureState.speedhackEnabled then
                    forceApplySpeed(speed, retries - 1)
                end
            end)
            return
        end
        
        -- Двойная проверка: Roblox иногда сбрасывает WalkSpeed после CharacterAdded
        if applied then
            task.delay(0.05, function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= speed and FeatureState.speedhackEnabled then
                    hum.WalkSpeed = speed
                end
            end)
        end
    end

    -- ============================================================
    -- ENABLE SPEEDHACK
    -- ============================================================
    function Speedhack.Enable()
        if FeatureState.speedhackEnabled then return end
        FeatureState.speedhackEnabled = true
        print("[Speedhack] Enabled (" .. FeatureState.speedhackSpeed .. ")")
        
        -- Применяем к текущему персонажу с retry
        forceApplySpeed(FeatureState.speedhackSpeed)

        -- Коннекшен на респавн
        FeatureState.speedhackCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            if not FeatureState.speedhackEnabled then return end
            
            -- Ждём Humanoid с таймаутом
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum then
                warn("[Speedhack] Humanoid not found after respawn")
                return
            end
            
            -- Применяем с задержкой, чтобы обойти Roblox reset
            task.delay(0.1, function()
                if FeatureState.speedhackEnabled and hum and hum.Parent then
                    hum.WalkSpeed = FeatureState.speedhackSpeed
                    
                    -- Дополнительная проверка через кадр
                    RunService.Heartbeat:Wait()
                    if FeatureState.speedhackEnabled and hum and hum.Parent 
                       and hum.WalkSpeed ~= FeatureState.speedhackSpeed then
                        hum.WalkSpeed = FeatureState.speedhackSpeed
                    end
                end
            end)
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
