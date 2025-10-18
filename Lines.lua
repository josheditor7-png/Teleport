-- UNIVERSAL TELEPORT GUI (versión final)
-- Autor: nCw

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 🎨 Colores base
local PRIMARY = Color3.fromRGB(20,24,28)
local ACCENT  = Color3.fromRGB(50,115,220)
local TEXT    = Color3.fromRGB(240,240,245)
local SUBTEXT = Color3.fromRGB(170,175,185)
local CARD    = Color3.fromRGB(30,36,44)

local MAX_SLOTS = 5
local saved = {}

-- 🧠 Funciones auxiliares
local function trySetClipboard(str)
    pcall(function()
        if setclipboard then setclipboard(str) end
    end)
end

local function formatPos(v)
    return string.format("X: %.2f, Y: %.2f, Z: %.2f", v.X, v.Y, v.Z)
end

-- 🪟 GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalTeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 🔘 Botón flotante
local floatBtn = Instance.new("Frame")
floatBtn.Name = "FloatTP"
floatBtn.Size = UDim2.new(0,60,0,60)
floatBtn.Position = UDim2.new(0.5, -30, 0.85, 0)
floatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
floatBtn.BackgroundColor3 = ACCENT
floatBtn.BorderSizePixel = 0
floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)
local fLabel = Instance.new("TextLabel", floatBtn)
fLabel.Size = UDim2.new(1,1,1,1)
fLabel.BackgroundTransparency = 1
fLabel.Text = "TP"
fLabel.Font = Enum.Font.GothamBold
fLabel.TextSize = 20
fLabel.TextColor3 = Color3.new(1,1,1)
fLabel.TextScaled = true

-- 🧭 Panel principal
local main = Instance.new("Frame")
main.Name = "MainPanel"
main.Size = UDim2.new(0,420,0,320)
main.Position = UDim2.new(0.5, -210, 0.5, -160)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = PRIMARY
main.BorderSizePixel = 0
main.Visible = false
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Título
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-16,0,48)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Text = "Universal Teleport"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = TEXT
title.TextXAlignment = Enum.TextXAlignment.Left

-- Subtítulo (con más separación)
local sub = Instance.new("TextLabel", main)
sub.Size = UDim2.new(1,-16,0,20)
sub.Position = UDim2.new(0,8,0,42) -- ⬅️ antes estaba 26, ahora tiene más espacio
sub.BackgroundTransparency = 1
sub.Text = "Guarda hasta 5 ubicaciones"
sub.Font = Enum.Font.Gotham
sub.TextSize = 12
sub.TextColor3 = SUBTEXT
sub.TextXAlignment = Enum.TextXAlignment.Left

-- 📜 Scrolling frame
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-16,1,-90)
scroll.Position = UDim2.new(0,8,0,70)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
scroll.CanvasSize = UDim2.new(0,0,0,MAX_SLOTS * 56)

local uiList = Instance.new("UIListLayout", scroll)
uiList.Padding = UDim.new(0,4)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.SortOrder = Enum.SortOrder.LayoutOrder

-- 🗨️ Popup
local popup = Instance.new("Frame", screenGui)
popup.Size = UDim2.new(0,300,0,48)
popup.Position = UDim2.new(0,12,1,-70)
popup.BackgroundColor3 = Color3.fromRGB(28,28,28)
popup.BackgroundTransparency = 0.25
popup.BorderSizePixel = 0
popup.Visible = false
Instance.new("UICorner", popup).CornerRadius = UDim.new(0,8)
local pl = Instance.new("TextLabel", popup)
pl.Size = UDim2.new(1,-20,1,0)
pl.Position = UDim2.new(0,10,0,0)
pl.BackgroundTransparency = 1
pl.Font = Enum.Font.GothamBold
pl.TextSize = 15
pl.TextColor3 = Color3.fromRGB(245,245,245)
pl.Text = ""

local function showPopup(msg, seconds)
    pl.Text = msg
    popup.Visible = true
    task.delay(seconds or 3, function()
        popup.Visible = false
    end)
end

local function getRoot()
    local ch = LocalPlayer.Character
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso")
end

local function refreshSlotUI(i)
    local slot = saved[i]
    local ref = slotList[i]
    if slot then
        ref.label.Text = ("Guardado %d"):format(i)
        ref.coordsLabel.Text = formatPos(slot)
    else
        ref.label.Text = ("Guardado %d - Vacío"):format(i)
        ref.coordsLabel.Text = ""
    end
end

local function saveSlot(i)
    local root = getRoot()
    if not root then
        showPopup("Error: personaje no encontrado", 2)
        return
    end
    saved[i] = root.Position
    refreshSlotUI(i)
    showPopup("Coordenadas guardadas", 2)
end

local function tpToSlot(i)
    local v = saved[i]
    if not v then
        showPopup("Guardado vacío", 2)
        return
    end
    local ch = LocalPlayer.Character
    if ch and ch:FindFirstChild("HumanoidRootPart") then
        ch.HumanoidRootPart.CFrame = CFrame.new(v + Vector3.new(0,3,0))
        showPopup("Teletransportado", 2)
    else
        showPopup("Error al teletransportar", 2)
    end
end

local function deleteSlot(i)
    saved[i] = nil
    refreshSlotUI(i)
    showPopup("Guardado eliminado", 2)
end

local function copySlot(i)
    local v = saved[i]
    if not v then showPopup("Slot vacío", 2) return end
    trySetClipboard(string.format("%.3f, %.3f, %.3f", v.X, v.Y, v.Z))
    showPopup("Coordenadas copiadas", 2)
end

-- 🧩 Crear los slots
slotList = {}
for i=1,MAX_SLOTS do
    local row = Instance.new("Frame", scroll)
    row.Name = "Slot"..i
    row.Size = UDim2.new(1,0,0,52)
    row.BackgroundColor3 = CARD
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextButton", row)
    lbl.Size = UDim2.new(0.5,-8,1,0)
    lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = TEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Guardado "..i.." - Vacío"
    lbl.AutoButtonColor = false

    local saveBtn = Instance.new("TextButton", row)
    saveBtn.Size = UDim2.new(0,86,0,28)
    saveBtn.Position = UDim2.new(0.5,6,0.15,0)
    saveBtn.Text = "Guardar"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 14
    saveBtn.BackgroundColor3 = ACCENT
    saveBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)

    local delBtn = Instance.new("TextButton", row)
    delBtn.Size = UDim2.new(0,46,0,28)
    delBtn.Position = UDim2.new(0.78,6,0.15,0)
    delBtn.Text = "X"
    delBtn.Font = Enum.Font.Gotham
    delBtn.TextSize = 14
    delBtn.BackgroundColor3 = Color3.fromRGB(220,60,60)
    delBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,6)

    local copyBtn = Instance.new("TextButton", row)
    copyBtn.Size = UDim2.new(0,66,0,28)
    copyBtn.Position = UDim2.new(0.88,-66,0.15,0)
    copyBtn.Text = "Copiar"
    copyBtn.Font = Enum.Font.Gotham
    copyBtn.TextSize = 12
    copyBtn.BackgroundColor3 = Color3.fromRGB(50,55,62)
    copyBtn.TextColor3 = TEXT
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,6)

    local coords = Instance.new("TextLabel", row)
    coords.Size = UDim2.new(1,-16,0,14)
    coords.Position = UDim2.new(0,8,0.65,0)
    coords.BackgroundTransparency = 1
    coords.Font = Enum.Font.Gotham
    coords.TextSize = 11
    coords.TextColor3 = SUBTEXT
    coords.TextXAlignment = Enum.TextXAlignment.Left

    slotList[i] = {
        frame = row,
        label = lbl,
        saveBtn = saveBtn,
        delBtn = delBtn,
        copyBtn = copyBtn,
        coordsLabel = coords
    }

    -- Eventos
    saveBtn.MouseButton1Click:Connect(function() saveSlot(i) end)
    delBtn.MouseButton1Click:Connect(function() deleteSlot(i) end)
    copyBtn.MouseButton1Click:Connect(function() copySlot(i) end)
    lbl.MouseButton1Click:Connect(function() tpToSlot(i) end)
end

-- 🔁 Mostrar/ocultar GUI
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        main.Visible = not main.Visible
    end
end)

-- ✋ Hacer draggable
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput == input and dragging then
                    local delta = moveInput.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
        end
    end)
end

makeDraggable(floatBtn)
makeDraggable(main)

showPopup("Universal Teleport listo", 2)
