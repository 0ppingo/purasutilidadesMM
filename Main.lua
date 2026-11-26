local shared = odh_shared_plugins
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local tab = shared.CreateTab(
    "MM2 Utilities",
    "/0ppingo/purasutilidadesMM/refs/heads/main/icon"
)

local section = tab:AddSection("MM2 Utilities", "BOMB JUMPS, HEADLESS & WALLHOP")

local pluginEnabled = false
local onCooldown = false
local debounce = false
local ScreenGui = nil
local MainFrame = nil
local CircleButton = nil
local SetupInputSystem_Bomb

local pluginEnabled_G = false
local onCooldown_G = false
local debounce_G = false
local ScreenGui_G = nil
local MainFrame_G = nil
local CircleButton_G = nil
local SetupInputSystem_Gold

local headlessEnabled = false
local headlessConnections = {}

local wallhopEnabled = false
local wallhopReady = true
local wallhopConnection = nil
local wallhopSmoothConnections = {}

local function CreateGUI_Bomb()
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FakeBombGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 65, 0, 65)
    MainFrame.Position = UDim2.new(1, -75, 0, 10)
    MainFrame.BackgroundTransparency = 1
    MainFrame.Active = false
    MainFrame.Parent = ScreenGui

    CircleButton = Instance.new("TextButton")
    CircleButton.Size = UDim2.new(1, 0, 1, 0)
    CircleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    CircleButton.BackgroundTransparency = 0.5
    CircleButton.Text = "clutch"
    CircleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    CircleButton.Font = Enum.Font.GothamBold
    CircleButton.TextSize = 14
    CircleButton.AutoButtonColor = false
    CircleButton.Active = true
    CircleButton.Parent = MainFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.15, 0)
    UICorner.Parent = CircleButton

    SetupInputSystem_Bomb()
end

local function QuickButtonPress_Bomb()
    if not CircleButton then return end
    CircleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    task.spawn(function()
        task.wait(0.1)
        if CircleButton and pluginEnabled and not onCooldown then
            CircleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
end

local function GetCenterPosition_Bomb()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local camera = Workspace.CurrentCamera
        local lookDir = camera.CFrame.LookVector
        return character.HumanoidRootPart.Position + (lookDir * 5)
    end
    return nil
end

local function MakeCharacterJump_Bomb()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local function ResetCooldown_Bomb()
    onCooldown = false
    if CircleButton and CircleButton.Parent then
        CircleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        CircleButton.Text = "clutch"
    end
end

local function StartCooldown_Bomb()
    onCooldown = true
    debounce = false

    if CircleButton then
        CircleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CircleButton.Text = "24"
    end

    task.spawn(function()
        for i = 23, 0, -1 do
            if onCooldown and pluginEnabled and CircleButton then
                CircleButton.Text = tostring(i)
                task.wait(1)
            else
                break
            end
        end

        if onCooldown and pluginEnabled then
            ResetCooldown_Bomb()
        end
    end)
end

local function UnequipBomb_Bomb()
    task.spawn(function()
        task.wait(0.5)
        local character = LocalPlayer.Character
        if character then
            local bomb = character:FindFirstChild("FakeBomb")
            if bomb then
                bomb.Parent = LocalPlayer.Backpack or character
            end
        end
    end)
end

local function GetBombFast_Bomb()
    local character = LocalPlayer.Character
    if not character then return false end

    local bomb = character:FindFirstChild("FakeBomb")
    if bomb then return true, bomb end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        bomb = backpack:FindFirstChild("FakeBomb")
        if bomb then
            bomb.Parent = character
            return true, bomb
        end
    end

    local success = pcall(function()
        ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer("FakeBomb")
    end)

    if success then
        for _ = 1, 5 do
            bomb = character:FindFirstChild("FakeBomb")
            if bomb then return true, bomb end

            if backpack then
                bomb = backpack:FindFirstChild("FakeBomb")
                if bomb then
                    bomb.Parent = character
                    return true, bomb
                end
            end

            task.wait(0.05)
        end
    end

    return false, nil
end

local function FastBombJump_Bomb()
    if onCooldown or not pluginEnabled or debounce then return end

    debounce = true
    QuickButtonPress_Bomb()

    local success, bomb = GetBombFast_Bomb()
    if success and bomb then
        local position = GetCenterPosition_Bomb()
        if position then
            local remote = bomb:FindFirstChild("Remote")
            if remote then
                pcall(function()
                    remote:FireServer(CFrame.new(position), 50)
                end)
            end

            MakeCharacterJump_Bomb()
            UnequipBomb_Bomb()

            task.spawn(function()
                task.wait(0.1)
                StartCooldown_Bomb()
            end)
        end
    end

    task.spawn(function()
        task.wait(0.5)
        debounce = false
    end)
end

SetupInputSystem_Bomb = function()
    if not CircleButton then return end

    CircleButton.MouseButton1Click:Connect(function()
        if not onCooldown and pluginEnabled then
            FastBombJump_Bomb()
        end
    end)

    if UserInputService.TouchEnabled then
        CircleButton.TouchTap:Connect(function()
            if not onCooldown and pluginEnabled then
                FastBombJump_Bomb()
            end
        end)
    end
end

local function CreateGUI_Gold()
    if ScreenGui_G then
        ScreenGui_G:Destroy()
        ScreenGui_G = nil
    end

    ScreenGui_G = Instance.new("ScreenGui")
    ScreenGui_G.Name = "GoldBombGUI"
    ScreenGui_G.Parent = game.CoreGui
    ScreenGui_G.ResetOnSpawn = false
    ScreenGui_G.IgnoreGuiInset = true

    MainFrame_G = Instance.new("Frame")
    MainFrame_G.Size = UDim2.new(0, 65, 0, 65)
    MainFrame_G.Position = UDim2.new(1, -75, 0, 85)
    MainFrame_G.BackgroundTransparency = 1
    MainFrame_G.Active = false
    MainFrame_G.Parent = ScreenGui_G

    CircleButton_G = Instance.new("TextButton")
    CircleButton_G.Size = UDim2.new(1, 0, 1, 0)
    CircleButton_G.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    CircleButton_G.BackgroundTransparency = 0.5
    CircleButton_G.Text = "gold"
    CircleButton_G.TextColor3 = Color3.fromRGB(40, 40, 40)
    CircleButton_G.Font = Enum.Font.GothamBold
    CircleButton_G.TextSize = 14
    CircleButton_G.AutoButtonColor = false
    CircleButton_G.Active = true
    CircleButton_G.Parent = MainFrame_G

    local UICorner_G = Instance.new("UICorner")
    UICorner_G.CornerRadius = UDim.new(0.15, 0)
    UICorner_G.Parent = CircleButton_G

    SetupInputSystem_Gold()
end

local function QuickButtonPress_Gold()
    if not CircleButton_G then return end

    CircleButton_G.BackgroundColor3 = Color3.fromRGB(200, 170, 0)

    task.spawn(function()
        task.wait(0.1)
        if CircleButton_G and pluginEnabled_G and not onCooldown_G then
            CircleButton_G.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        end
    end)
end

local function GetCenterPosition_Gold()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local camera = Workspace.CurrentCamera
        local lookDir = camera.CFrame.LookVector
        return character.HumanoidRootPart.Position + (lookDir * 5)
    end
    return nil
end

local function MakeCharacterJump_Gold()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local function ResetCooldown_Gold()
    onCooldown_G = false

    if CircleButton_G and CircleButton_G.Parent then
        CircleButton_G.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        CircleButton_G.Text = "gold"
    end
end

local function StartCooldown_Gold()
    onCooldown_G = true
    debounce_G = false

    if CircleButton_G then
        CircleButton_G.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
        CircleButton_G.Text = "5"
    end

    task.spawn(function()
        for i = 4, 0, -1 do
            if onCooldown_G and pluginEnabled_G and CircleButton_G then
                CircleButton_G.Text = tostring(i)
                task.wait(1)
            else
                break
            end
        end

        if onCooldown_G and pluginEnabled_G then
            ResetCooldown_Gold()
        end
    end)
end

local function GetGoldBomb_Gold()
    local character = LocalPlayer.Character
    if not character then return false end

    local bomb = character:FindFirstChild("GoldBomb")
    if bomb then return true, bomb end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        bomb = backpack:FindFirstChild("GoldBomb")
        if bomb then
            bomb.Parent = character
            return true, bomb
        end
    end

    return false, nil
end

local function GoldBombJump_Gold()
    if onCooldown_G or not pluginEnabled_G or debounce_G then return end

    debounce_G = true
    QuickButtonPress_Gold()

    local success, bomb = GetGoldBomb_Gold()
    if success and bomb then
        local position = GetCenterPosition_Gold()
        if position then
            local remote = bomb:FindFirstChild("Remote")
            if remote then
                pcall(function()
                    remote:FireServer(CFrame.new(position), 50)
                end)
            end

            MakeCharacterJump_Gold()

            task.spawn(function()
                task.wait(0.1)
                StartCooldown_Gold()
            end)
        end
    end

    task.spawn(function()
        task.wait(0.5)
        debounce_G = false
    end)
end

SetupInputSystem_Gold = function()
    if not CircleButton_G then return end

    CircleButton_G.MouseButton1Click:Connect(function()
        if not onCooldown_G and pluginEnabled_G then
            GoldBombJump_Gold()
        end
    end)

    if UserInputService.TouchEnabled then
        CircleButton_G.TouchTap:Connect(function()
            if not onCooldown_G and pluginEnabled_G then
                GoldBombJump_Gold()
            end
        end)
    end
end

local function applyHeadless(char)
    if not headlessEnabled or not char then return end

    local head = char:FindFirstChild("Head")
    if not head then
        local success = pcall(function()
            head = char:WaitForChild("Head", 2)
        end)

        if not success or not head then
            return
        end
    end

    head.Transparency = 1

    for _, v in ipairs(head:GetChildren()) do
        if v:IsA("Decal") then
            v.Transparency = 1
        end
    end

    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") and acc:FindFirstChild("Handle") then
            local handle = acc.Handle
            local weld = handle:FindFirstChildWhichIsA("Weld")
                or handle:FindFirstChildWhichIsA("Motor6D")

            if weld and (
                (weld.Part0 and weld.Part0.Name == "Head")
                or (weld.Part1 and weld.Part1.Name == "Head")
            ) then
                handle.Transparency = 1

                for _, c in ipairs(handle:GetChildren()) do
                    if c:IsA("SpecialMesh") or c:IsA("Mesh") then
                        c.Transparency = 1
                    end
                end
            end
        end
    end
end

local function removeHeadless(char)
    if not char then return end

    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0

        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") then
                v.Transparency = 0
            end
        end
    end

    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") and acc:FindFirstChild("Handle") then
            local handle = acc.Handle
            local weld = handle:FindFirstChildWhichIsA("Weld")
                or handle:FindFirstChildWhichIsA("Motor6D")

            if weld and (
                (weld.Part0 and weld.Part0.Name == "Head")
                or (weld.Part1 and weld.Part1.Name == "Head")
            ) then
                handle.Transparency = 0

                for _, c in ipairs(handle:GetChildren()) do
                    if c:IsA("SpecialMesh") or c:IsA("Mesh") then
                        c.Transparency = 0
                    end
                end
            end
        end
    end
end

local function SetupHeadless()
    for _, connection in pairs(headlessConnections) do
        if connection then
            connection:Disconnect()
        end
    end

    headlessConnections = {}

    if headlessEnabled then
        if LocalPlayer.Character then
            applyHeadless(LocalPlayer.Character)
        end

        local charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            if headlessEnabled then
                char:WaitForChild("HumanoidRootPart")
                applyHeadless(char)
            end
        end)

        table.insert(headlessConnections, charAddedConnection)
    else
        if LocalPlayer.Character then
            removeHeadless(LocalPlayer.Character)
        end
    end
end

local function smoothLook_Wall(rootPart, targetDirection, duration)
    local startCF = rootPart.CFrame
    local goalCF = CFrame.lookAt(rootPart.Position, rootPart.Position + targetDirection)
    local startTime = tick()
    local connection

    connection = RunService.Heartbeat:Connect(function()
        if not wallhopEnabled or not rootPart.Parent then
            connection:Disconnect()
            wallhopSmoothConnections[connection] = nil
            return
        end

        local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
        local smoothAlpha = 1 - (1 - alpha) ^ 2

        rootPart.CFrame = startCF:Lerp(goalCF, smoothAlpha)

        if alpha >= 1 then
            connection:Disconnect()
            wallhopSmoothConnections[connection] = nil
        end
    end)

    wallhopSmoothConnections[connection] = true
end

local function getWallRaycastResult_Wall()
    local character = LocalPlayer.Character
    if not character then return nil end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character}

    local detectionDistance = 2.5
    local closestHit = nil
    local minDistance = detectionDistance + 1
    local hrpCF = humanoidRootPart.CFrame

    for i = 0, 7 do
        local angle = math.rad(i * 45)
        local direction = (hrpCF * CFrame.Angles(0, angle, 0)).LookVector

        local ray = Workspace:Raycast(
            humanoidRootPart.Position,
            direction * detectionDistance,
            raycastParams
        )

        if ray and ray.Instance then
            if math.abs(ray.Normal.Y) < 0.4 and ray.Distance < minDistance then
                minDistance = ray.Distance
                closestHit = ray
            end
        end
    end

    local blockCastOriginCF = hrpCF * CFrame.new(0, -1, -0.5)
    local okBlock, blockResult = pcall(function()
        return Workspace:Blockcast(
            blockCastOriginCF,
            Vector3.new(1.5, 1, 0.5),
            hrpCF.LookVector * 1.8,
            raycastParams
        )
    end)

    if okBlock and blockResult and blockResult.Instance then
        if math.abs(blockResult.Normal.Y) < 0.4 and blockResult.Distance < minDistance then
            minDistance = blockResult.Distance
            closestHit = blockResult
        end
    end

    return closestHit
end

local function executeWallJump_Wall(wallRayResult)
    if not wallhopReady then return end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera

    if not (humanoid and rootPart and camera and wallRayResult) then return end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

    wallhopReady = false

    local wallNormal = wallRayResult.Normal

    local baseDirectionAwayFromWall = Vector3.new(wallNormal.X, 0, wallNormal.Z)
    if baseDirectionAwayFromWall.Magnitude < 0.1 then
        baseDirectionAwayFromWall = -rootPart.CFrame.LookVector
    end
    baseDirectionAwayFromWall = baseDirectionAwayFromWall.Unit

    local cameraLook = camera.CFrame.LookVector
    local horizontalCameraLook = Vector3.new(cameraLook.X, 0, cameraLook.Z)
    if horizontalCameraLook.Magnitude < 0.1 then
        horizontalCameraLook = baseDirectionAwayFromWall
    else
        horizontalCameraLook = horizontalCameraLook.Unit
    end

    local finalDirection = (baseDirectionAwayFromWall * 0.7 + horizontalCameraLook * 0.3).Unit

    local randomAngle = math.rad(math.random(-3, 3))
    finalDirection = CFrame.Angles(0, randomAngle, 0) * finalDirection

    smoothLook_Wall(rootPart, finalDirection, 0.08)

    RunService.Heartbeat:Wait()

    if not wallhopEnabled or not rootPart.Parent or humanoid.Health <= 0 then
        wallhopReady = true
        return
    end

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

    task.wait(0.04 + math.random() * 0.02)

    if wallhopEnabled and rootPart.Parent then
        smoothLook_Wall(rootPart, -baseDirectionAwayFromWall, 0.12)
    end

    task.delay(0.12 + math.random() * 0.03, function()
        wallhopReady = true
    end)
end

local function setBombEnabled(state)
    pluginEnabled = state

    if state then
        if not ScreenGui then
            CreateGUI_Bomb()
        end
    else
        onCooldown = false
        debounce = false

        if ScreenGui then
            ScreenGui:Destroy()
            ScreenGui = nil
        end

        MainFrame = nil
        CircleButton = nil
    end
end

local function setGoldEnabled(state)
    pluginEnabled_G = state

    if state then
        if not ScreenGui_G then
            CreateGUI_Gold()
        end
    else
        onCooldown_G = false
        debounce_G = false

        if ScreenGui_G then
            ScreenGui_G:Destroy()
            ScreenGui_G = nil
        end

        MainFrame_G = nil
        CircleButton_G = nil
    end
end

local function setWallhopEnabled(state)
    wallhopEnabled = state

    if wallhopConnection then
        wallhopConnection:Disconnect()
        wallhopConnection = nil
    end

    for connection in pairs(wallhopSmoothConnections) do
        connection:Disconnect()
    end
    wallhopSmoothConnections = {}
    wallhopReady = true

    if state then
        wallhopConnection = UserInputService.JumpRequest:Connect(function()
            if not wallhopEnabled then return end

            local wallRayResult = getWallRaycastResult_Wall()
            if wallRayResult then
                executeWallJump_Wall(wallRayResult)
            end
        end)
    end
end

local bombToggle = section:AddToggle("Bomb Jump", function(state)
    setBombEnabled(state)
end)

local goldToggle = section:AddToggle("Gold Bomb Jump", function(state)
    setGoldEnabled(state)
end)

local headlessToggle = section:AddToggle("Headless", function(state)
    headlessEnabled = state
    SetupHeadless()
end)

local wallhopToggle = section:AddToggle("Wallhop", function(state)
    setWallhopEnabled(state)
end)

task.defer(function()
    bombToggle()
    bombToggle()

    goldToggle()
    goldToggle()

    headlessToggle()
    headlessToggle()

    wallhopToggle()
    wallhopToggle()
end)
