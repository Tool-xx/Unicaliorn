-- Features/AntiAFK.lua
-- Anti-AFK feature: prevents idle kick with random simulated actions
-- Receives Context, returns Feature table

return function(Context)
    local FeatureState = Context.FeatureState
    local LocalPlayer = Context.LocalPlayer

    local AntiAFK = {}

    -- ============================================================
    -- START ANTI-AFK
    -- ============================================================
    function AntiAFK.Start()
        if FeatureState.antiAfkRunning then return end
        FeatureState.antiAfkRunning = true
        print("[AntiAFK] Enabled")

        -- Disable built-in idle connections if possible
        if getconnections then
            pcall(function()
                for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
                    if connection.Disable then
                        connection:Disable()
                    elseif connection.Disconnect then
                        connection:Disconnect()
                    end
                end
            end)
        end

        -- Hook Idled event
        LocalPlayer.Idled:Connect(function()
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(math.random(0, 500), math.random(0, 500)))
            end)
        end)

        -- Random camera movement
        local function CameraMove()
            pcall(function()
                local Camera = workspace.CurrentCamera
                local old = Camera.CFrame
                local angle = math.rad(math.random(-20, 20))
                Camera.CFrame = old * CFrame.Angles(0, angle, 0)
            end)
        end

        -- Random click
        local function SmallClick()
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(math.random(100, 700), math.random(100, 500)))
            end)
        end

        -- Random micro movement
        local function MicroMove()
            pcall(function()
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local keys = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D }
                local key = keys[math.random(1, #keys)]
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(math.random(20, 50) / 100)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end)
        end

        FeatureState.antiAfkLoopThread = task.spawn(function()
            while FeatureState.antiAfkRunning do
                local delay = math.random(600, 1500)
                local elapsed = 0
                while FeatureState.antiAfkRunning and elapsed < delay do
                    task.wait(1)
                    elapsed = elapsed + 1
                end
                if not FeatureState.antiAfkRunning then break end

                local action = math.random(1, 100)
                if action <= 50 then
                    CameraMove()
                elseif action <= 80 then
                    SmallClick()
                else
                    MicroMove()
                end
            end
        end)
    end

    -- ============================================================
    -- STOP ANTI-AFK
    -- ============================================================
    function AntiAFK.Stop()
        if not FeatureState.antiAfkRunning then return end
        FeatureState.antiAfkRunning = false
        print("[AntiAFK] Disabled")
        if FeatureState.antiAfkLoopThread then
            task.cancel(FeatureState.antiAfkLoopThread)
            FeatureState.antiAfkLoopThread = nil
        end
    end

    -- ============================================================
    -- TOGGLE
    -- ============================================================
    function AntiAFK.Toggle()
        if FeatureState.antiAfkRunning then
            AntiAFK.Stop()
            return false
        else
            AntiAFK.Start()
            return true
        end
    end

    -- ============================================================
    -- IS RUNNING
    -- ============================================================
    function AntiAFK.IsRunning()
        return FeatureState.antiAfkRunning
    end

    print("[Feature] AntiAFK module loaded.")
    return AntiAFK
end
