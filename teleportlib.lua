--[[
Based on Vynixu's Teleport Tool (https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Teleport%20Tool/Source.lua),
Converted the UI teleporter into a library to loadstring
Chnaged by melon!
]]

local Library = {}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Points = {}

function onCharacterAdded(char)
    Char, Root = char, char:WaitForChild("HumanoidRootPart")
end

function create(vec3)
    if #Points > 0 then
        local point, nearest = nil, 1
        for _, v in next, Points do
            local dist = (v.Position - vec3).Magnitude
            if dist < nearest then
                point, nearest = v, dist
            end
        end
        if point then
            point.Position = vec3
            return
        end
    end

    local point = Instance.new("Part")
    point.Anchored = true
    point.CanCollide = false
    point.Color = Color3.new(1, 1, 1)
    point.Material = Enum.Material.Neon
    point.Position = vec3
    point.Shape = Enum.PartType.Ball
    point.Size = Vector3.new(0.4, 0.4, 0.4)

    local attachment = Instance.new("Attachment", point)

    local beam = Instance.new("Beam")
    beam.Brightness = 5
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
    })
    beam.FaceCamera = true
    beam.Width0, beam.Width1 = 0.1, 0.1
    beam.Attachment0 = attachment
    beam.Parent = point

    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 9e9

    clickDetector.MouseHoverEnter:Connect(function()
        point.Color = Color3.new(1, 0, 0)
    end)

    clickDetector.MouseHoverLeave:Connect(function()
        point.Color = Color3.new(1, 1, 1)
    end)

    clickDetector.MouseClick:Connect(function()
        remove(point)
    end)

    clickDetector.Parent = point
    point.Parent = workspace

    return point
end

function update()
    for i, v in next, Points do
        local nextPoint = Points[i + 1]
        if nextPoint then
            v.Beam.Attachment1 = nextPoint.Attachment
            v.Color = Color3.new(1, 1, 1)
        end
    end
    Points[#Points].Color = Color3.fromRGB(0, 255, 128)
    Points[1].Color = Color3.fromRGB(85, 255, 0)
end

function add(vec3)
    Points[#Points + 1] = create(vec3)
    update()
end

function remove(point)
    local pointIdx = table.find(Points, point)
    if pointIdx then
        table.remove(Points, pointIdx)
        point:Destroy()
        update()
    end
end

local function clear()
    for i = #Points, 1, -1 do
        remove(Points[i])
    end
end

function teleportToPoint(vec3)
    local bV = Instance.new("BodyVelocity")
    bV.Velocity, bV.MaxForce = Vector3.new(), Vector3.new(9e9, 9e9, 9e9)
    bV.Parent = Root

    local reached = false
    local connection = RS.Stepped:Connect(function(_, step)
        local diff = vec3 - Root.Position
        Root.CFrame = CFrame.new(Root.Position + diff.Unit * math.min(50 * step, diff.Magnitude))

        if (Vector3.new(vec3.X, 0, vec3.Z) - Vector3.new(Root.Position.X, 0, Root.Position.Z)).Magnitude < 0.1 then
            Root.CFrame = CFrame.new(vec3)
            reached = true
        end
    end)

    repeat task.wait() until reached
    connection:Disconnect()
    bV:Destroy()
end

function placePointsBetween(point1, point2, spacing)
    local direction = (point2 - point1).Unit
    local distance = (point2 - point1).Magnitude
    local numPoints = math.floor(distance / spacing)
    
    for i = 0, numPoints do
        local newPosition = point1 + direction * (i * spacing)
        add(newPosition)
    end
end

onCharacterAdded(Char)
Plr.CharacterAdded:Connect(onCharacterAdded, Char)

Library.add = add
Library.clear = clear
Library.remove = remove
Library.placePointsBetween = placePointsBetween
Library.teleportToPoint = teleportToPoint

return Library
