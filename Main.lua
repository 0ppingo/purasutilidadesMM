local shared = odh_shared_plugins
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local tab = shared.CreateTab("MM2 Utilities", "/axioriasolver/testplugin/refs/heads/main/icon")
local section = tab:AddSection("MM2 Utilities", "BOMB JUMPS & HEADLESS")

local bombEnabled = true
local goldEnabled = true
local headlessEnabled = true

local function

local function

local function applyHeadless(char)
    if not headlessEnabled or not char then return end
    
    if not char:FindFirstChild("Head") then
        local success, result = pcall(function()
            return char:WaitForChild("Head", 2)
        end)
        if not success then return end
    end
    
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") then
                v.Transparency = 1
            end
        end
    end

    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") and acc:FindFirstChild("Handle") then
            local handle = acc.Handle
            local weld = handle:FindFirstChildWhichIsA("Weld") or handle:FindFirstChildWhichIsA("Motor6D")
            if weld and ((weld.Part0 and weld.Part0.Name == "Head") or (weld.Part1 and weld.Part1.Name == "Head")) then
                handle.Transparency = 1
                for _, c in ipairs(handle:GetChildren()) do
                    if c:IsA("SpecialMesh") or c:IsA("Mesh") then
                        c.Transparency = 1
                    end
                end
            end
        end
    end

    local rightLower = char:FindFirstChild("RightLowerLeg")
    local rightUpper = char:FindFirstChild("RightUpperLeg")
    local rightFoot  = char:FindFirstChild("RightFoot")

    if rightLower then
        rightLower.MeshId = "rbxassetid://902942093"
        rightLower.Transparency = 1
    end
    if rightUpper then
        rightUpper.MeshId = "rbxassetid://902942096"
        rightUpper.TextureID = "rbxassetid://902843398"
    end
    if rightFoot then
        rightFoot.MeshId = "rbxassetid://902942089"
        rightFoot.Transparency = 1
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
            local weld = handle:FindFirstChildWhichIsA("Weld") or handle:FindFirstChildWhichIsA("Motor6D")
            if weld and ((weld.Part0 and weld.Part0.Name == "Head") or (weld.Part1 and weld.Part1.Name == "Head")) then
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

local function

local function setBombEnabled(state)
    bombEnabled = state
    pluginEnabled = state

    if state then
        if not ScreenGui then
            CreateGUI_Bomb()
        end
    elseif ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
        MainFrame = nil
        CircleButton = nil
    end
end

local function setGoldEnabled(state)
    goldEnabled = state
    pluginEnabled_G = state

    if state then
        if not ScreenGui_G then
            CreateGUI_Gold()
        end
    elseif ScreenGui_G then
        ScreenGui_G:Destroy()
        ScreenGui_G = nil
        MainFrame_G = nil
        CircleButton_G = nil
    end
end

section:AddToggle("Bomb Jump", function(state)
    setBombEnabled(state)
end)

section:AddToggle("Gold Bomb Jump", function(state)
    setGoldEnabled(state)
end)

section:AddToggle("Headless", function(state)
    headlessEnabled = state
    SetupHeadless()
end)

