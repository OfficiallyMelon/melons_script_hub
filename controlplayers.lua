--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
if game.CoreGui:FindFirstChild("Melon Hub || Control Players") then game.CoreGui:FindFirstChild("Melon Hub || Control Players"):Destroy() end

local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source2.lua"))()
local UI = Venyx.new({
    title = "Melon Hub || Control Players"
})

-- // Test Page
local Test = UI:addPage({
    title = "Main",
    icon = 5012544693
})

-- // Sections for Test Page
local SectionA = Test:addSection({
    title = "Aura"
})

local RespawnP = Test:addSection({
    title = "Respawn"
})

SectionA:addToggle({
    title = "Control Aura",
    callback = function(value)
        _G.PlayerControlAura = value
        print("Toggled", value)
    end
})

RespawnP:addToggle({
    title = "Respawn Control",
    callback = function(value)
        _G.RespawnControl = value
        print("Toggled", value)
    end
})


local SwitchTarget = game.ReplicatedStorage.SwitchTarget
local TargetValue = game.Players.LocalPlayer.Target

spawn(function()
    while true do
        if _G.PlayerControlAura then
            for _, player in pairs(game.Players:GetPlayers()) do
                if not TargetValue.Value then
                    SwitchTarget:FireServer(player)
                else
                    print(TargetValue.Value.Name)
                end
            end
        end
        wait(seconds)
    end
end)

game.ReplicatedStorage.BeingControlled.OnClientEvent:Connect(function()
    if _G.RespawnControl then
    local CF = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    game.Players.LocalPlayer.Character.Head:Destroy()
    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CF
    end)
    end
end)
