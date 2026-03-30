-- Noclip + Anti-Zombie + Staff Notify
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ===== STAFF NOTIFY CONFIG =====
local STAFF_GROUP  = 15434910
local TESTER_GROUP = 9630142
local ROLE_MAP = {
    ["Contractor"]          = "Contractor",
    ["Moderator"]           = "Moderator",
    ["Senior Moderator"]    = "Senior Moderator",
    ["Administrator"]       = "Administrator",
    ["Chief Administrator"] = "Chief Administrator",
    ["Tester"]              = "Tester",
    ["Developer"]           = "Developer",
    ["Host"]                = "Developer",
}
local ROLE_COLOR = {
    ["Developer"]           = Color3.fromRGB(255, 90,  90),
    ["Chief Administrator"] = Color3.fromRGB(255, 150, 50),
    ["Administrator"]       = Color3.fromRGB(255, 210, 60),
    ["Senior Moderator"]    = Color3.fromRGB(80,  200, 255),
    ["Moderator"]           = Color3.fromRGB(80,  200, 120),
    ["Contractor"]          = Color3.fromRGB(180, 180, 180),
    ["Tester"]              = Color3.fromRGB(160, 140, 220),
}

local camera = workspace.CurrentCamera
local function getChar() return player.Character end
local function getHRP() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- State
local noclipActive = false
local noclipConn = nil
local NOCLIP_KEY = Enum.KeyCode.N
local rebinding = false
local dragMoved = false

local antiZombieActive = false
local frozenZombies = {}
local antiZombieConn = nil
local ZOMBIE_RADIUS = 10
local MIN_RAD, MAX_RAD, RAD_STEP = 5, 50, 5

local staffNotifyActive = false
local staffNotifyFrames = {}

local vnoclipActive = false
local vnoclipConn = nil
local VNOCLIP_KEY = Enum.KeyCode.V
local vrebinding = false
local vnoclipDisabledParts = {}


-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ACTools"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

local PANEL_W = 200
local PANEL_H = 370
local MINI_SIZE = 30

-- Color palette
local C_BG     = Color3.fromRGB(8, 8, 10)
local C_HEADER = Color3.fromRGB(13, 13, 13)
local C_BTN    = Color3.fromRGB(20, 20, 20)
local C_BTN_ON = Color3.fromRGB(185, 15, 15)
local C_ACCENT = Color3.fromRGB(210, 20, 20)
local C_SEP    = Color3.fromRGB(36, 36, 36)
local C_DARK   = Color3.fromRGB(26, 26, 26)
local C_TRACK  = Color3.fromRGB(20, 20, 20)
local C_TEXT   = Color3.fromRGB(185, 185, 185)
local C_SILVER = Color3.fromRGB(140, 140, 140)
local C_WHITE  = Color3.fromRGB(255, 255, 255)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
panel.Position = UDim2.new(1, -(PANEL_W + 12), 0, 60)
panel.BackgroundColor3 = C_BG
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(38, 38, 38)
panelStroke.Thickness = 1
panelStroke.Parent = panel

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = C_HEADER
titleBar.BorderSizePixel = 0
titleBar.Parent = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
local tfix = Instance.new("Frame")
tfix.Size = UDim2.new(1, 0, 0, 10)
tfix.Position = UDim2.new(0, 0, 1, -10)
tfix.BackgroundColor3 = C_HEADER
tfix.BorderSizePixel = 0
tfix.Parent = titleBar

local titleAccent = Instance.new("Frame")
titleAccent.Size = UDim2.new(0, 3, 1, -10)
titleAccent.Position = UDim2.new(0, 0, 0, 5)
titleAccent.BackgroundColor3 = C_ACCENT
titleAccent.BorderSizePixel = 0
titleAccent.Parent = titleBar
Instance.new("UICorner", titleAccent).CornerRadius = UDim.new(0, 2)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -44, 1, 0)
titleLbl.Position = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "ACtools"
titleLbl.TextColor3 = C_WHITE
titleLbl.TextSize = 12
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = titleBar

local minimized = false

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -26, 0.5, -11)
minBtn.BackgroundColor3 = C_DARK
minBtn.BorderSizePixel = 0
minBtn.Text = "−"
minBtn.TextColor3 = C_SILVER
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.ZIndex = 5
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

-- Helpers
local function makeBtn(text, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 30)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = C_BTN
    btn.Text = text
    btn.TextColor3 = C_TEXT
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function setBtn(btn, active, label)
    btn.BackgroundColor3 = active and C_BTN_ON or C_BTN
    btn.TextColor3 = active and C_WHITE or C_TEXT
    btn.Text = (active and "● " or "") .. label
end

local function keyName(kc) return tostring(kc):gsub("Enum%.KeyCode%.", "") end

-- ===== NOCLIP SECTION =====
local noclipBtn = makeBtn("👻 Noclip  [N]", 38)

local kbLabel = Instance.new("TextLabel")
kbLabel.Size = UDim2.new(0, 65, 0, 24)
kbLabel.Position = UDim2.new(0, 8, 0, 76)
kbLabel.BackgroundTransparency = 1
kbLabel.Text = "Keybind:"
kbLabel.TextColor3 = C_SILVER
kbLabel.TextSize = 10
kbLabel.Font = Enum.Font.GothamBold
kbLabel.TextXAlignment = Enum.TextXAlignment.Left
kbLabel.Parent = panel

local kbBtn = Instance.new("TextButton")
kbBtn.Size = UDim2.new(1, -82, 0, 22)
kbBtn.Position = UDim2.new(0, 74, 0, 77)
kbBtn.BackgroundColor3 = C_DARK
kbBtn.Text = "[N]"
kbBtn.TextColor3 = C_SILVER
kbBtn.TextSize = 10
kbBtn.Font = Enum.Font.GothamBold
kbBtn.BorderSizePixel = 0
kbBtn.Parent = panel
Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 4)

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -16, 0, 1)
sep.Position = UDim2.new(0, 8, 0, 108)
sep.BackgroundColor3 = C_SEP
sep.BorderSizePixel = 0
sep.Parent = panel

-- ===== ANTI-ZOMBIE SECTION =====
local antiZombieBtn = makeBtn("🧟 Anti-Zombie", 116)

local radLabel = Instance.new("TextLabel")
radLabel.Size = UDim2.new(1, -16, 0, 16)
radLabel.Position = UDim2.new(0, 8, 0, 154)
radLabel.BackgroundTransparency = 1
radLabel.Text = "Stop Radius: " .. ZOMBIE_RADIUS
radLabel.TextColor3 = C_SILVER
radLabel.TextSize = 10
radLabel.Font = Enum.Font.GothamBold
radLabel.Parent = panel

local radMinus = Instance.new("TextButton")
radMinus.Size = UDim2.new(0, 28, 0, 20)
radMinus.Position = UDim2.new(0, 8, 0, 173)
radMinus.BackgroundColor3 = C_DARK
radMinus.Text = "−"
radMinus.TextColor3 = C_SILVER
radMinus.TextSize = 15
radMinus.Font = Enum.Font.GothamBold
radMinus.BorderSizePixel = 0
radMinus.Parent = panel
Instance.new("UICorner", radMinus).CornerRadius = UDim.new(0, 4)

local radPlus = Instance.new("TextButton")
radPlus.Size = UDim2.new(0, 28, 0, 20)
radPlus.Position = UDim2.new(1, -36, 0, 173)
radPlus.BackgroundColor3 = C_DARK
radPlus.Text = "+"
radPlus.TextColor3 = C_SILVER
radPlus.TextSize = 15
radPlus.Font = Enum.Font.GothamBold
radPlus.BorderSizePixel = 0
radPlus.Parent = panel
Instance.new("UICorner", radPlus).CornerRadius = UDim.new(0, 4)

local radBar = Instance.new("Frame")
radBar.Size = UDim2.new(1, -88, 0, 5)
radBar.Position = UDim2.new(0, 40, 0, 181)
radBar.BackgroundColor3 = C_TRACK
radBar.BorderSizePixel = 0
radBar.Parent = panel
Instance.new("UICorner", radBar).CornerRadius = UDim.new(0, 3)

local radFill = Instance.new("Frame")
radFill.Size = UDim2.new((ZOMBIE_RADIUS - MIN_RAD) / (MAX_RAD - MIN_RAD), 0, 1, 0)
radFill.BackgroundColor3 = C_ACCENT
radFill.BorderSizePixel = 0
radFill.Parent = radBar
Instance.new("UICorner", radFill).CornerRadius = UDim.new(0, 3)

local sep2 = Instance.new("Frame")
sep2.Size = UDim2.new(1, -16, 0, 1)
sep2.Position = UDim2.new(0, 8, 0, 198)
sep2.BackgroundColor3 = C_SEP
sep2.BorderSizePixel = 0
sep2.Parent = panel

local staffNotifyBtn = makeBtn("🔔 Staff Notify", 206)

local sep3 = Instance.new("Frame")
sep3.Size = UDim2.new(1, -16, 0, 1)
sep3.Position = UDim2.new(0, 8, 0, 244)
sep3.BackgroundColor3 = C_SEP
sep3.BorderSizePixel = 0
sep3.Parent = panel

local playerListBtn = makeBtn("👥 Player List", 252)

local sep4 = Instance.new("Frame")
sep4.Size = UDim2.new(1, -16, 0, 1)
sep4.Position = UDim2.new(0, 8, 0, 290)
sep4.BackgroundColor3 = C_SEP
sep4.BorderSizePixel = 0
sep4.Parent = panel

local vnoclipBtn = makeBtn("🚗 Vehicle Noclip  [V]", 298)

local vnKbLabel = Instance.new("TextLabel")
vnKbLabel.Size = UDim2.new(0, 65, 0, 24)
vnKbLabel.Position = UDim2.new(0, 8, 0, 336)
vnKbLabel.BackgroundTransparency = 1
vnKbLabel.Text = "Keybind:"
vnKbLabel.TextColor3 = C_SILVER
vnKbLabel.TextSize = 10
vnKbLabel.Font = Enum.Font.GothamBold
vnKbLabel.TextXAlignment = Enum.TextXAlignment.Left
vnKbLabel.Parent = panel

local vnKbBtn = Instance.new("TextButton")
vnKbBtn.Size = UDim2.new(1, -82, 0, 22)
vnKbBtn.Position = UDim2.new(0, 74, 0, 337)
vnKbBtn.BackgroundColor3 = C_DARK
vnKbBtn.Text = "[V]"
vnKbBtn.TextColor3 = C_SILVER
vnKbBtn.TextSize = 10
vnKbBtn.Font = Enum.Font.GothamBold
vnKbBtn.BorderSizePixel = 0
vnKbBtn.Parent = panel
Instance.new("UICorner", vnKbBtn).CornerRadius = UDim.new(0, 4)


-- ===== PLAYER LIST PANEL =====
local LIST_W = 220
local LIST_H = 300

local listPanel = Instance.new("Frame")
listPanel.Size = UDim2.new(0, LIST_W, 0, LIST_H)
listPanel.Position = UDim2.new(1, -(PANEL_W + LIST_W + 20), 0, 60)
listPanel.BackgroundColor3 = C_BG
listPanel.BorderSizePixel = 0
listPanel.Visible = false
listPanel.Parent = gui
Instance.new("UICorner", listPanel).CornerRadius = UDim.new(0, 8)
local listStroke = Instance.new("UIStroke")
listStroke.Color = Color3.fromRGB(38, 38, 38)
listStroke.Thickness = 1
listStroke.Parent = listPanel

local listTitleBar = Instance.new("Frame")
listTitleBar.Size = UDim2.new(1, 0, 0, 28)
listTitleBar.BackgroundColor3 = C_HEADER
listTitleBar.BorderSizePixel = 0
listTitleBar.Parent = listPanel
Instance.new("UICorner", listTitleBar).CornerRadius = UDim.new(0, 8)
local ltfix = Instance.new("Frame")
ltfix.Size = UDim2.new(1, 0, 0, 10)
ltfix.Position = UDim2.new(0, 0, 1, -10)
ltfix.BackgroundColor3 = C_HEADER
ltfix.BorderSizePixel = 0
ltfix.Parent = listTitleBar

local listAccent = Instance.new("Frame")
listAccent.Size = UDim2.new(0, 3, 1, -10)
listAccent.Position = UDim2.new(0, 0, 0, 5)
listAccent.BackgroundColor3 = C_ACCENT
listAccent.BorderSizePixel = 0
listAccent.Parent = listTitleBar
Instance.new("UICorner", listAccent).CornerRadius = UDim.new(0, 2)

local listTitleLbl = Instance.new("TextLabel")
listTitleLbl.Size = UDim2.new(1, -10, 1, 0)
listTitleLbl.Position = UDim2.new(0, 10, 0, 0)
listTitleLbl.BackgroundTransparency = 1
listTitleLbl.Text = "PLAYERS"
listTitleLbl.TextColor3 = C_WHITE
listTitleLbl.TextSize = 11
listTitleLbl.Font = Enum.Font.GothamBold
listTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
listTitleLbl.Parent = listTitleBar

local listScroll = Instance.new("ScrollingFrame")
listScroll.Size = UDim2.new(1, -8, 1, -34)
listScroll.Position = UDim2.new(0, 4, 0, 30)
listScroll.BackgroundTransparency = 1
listScroll.BorderSizePixel = 0
listScroll.ScrollBarThickness = 2
listScroll.ScrollBarImageColor3 = C_SILVER
listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
listScroll.Parent = listPanel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = listScroll

local function updateRadius(delta)
    ZOMBIE_RADIUS = math.clamp(ZOMBIE_RADIUS + delta, MIN_RAD, MAX_RAD)
    radLabel.Text = "Stop Radius: " .. ZOMBIE_RADIUS
    TweenService:Create(radFill, TweenInfo.new(0.1), {
        Size = UDim2.new((ZOMBIE_RADIUS - MIN_RAD) / (MAX_RAD - MIN_RAD), 0, 1, 0)
    }):Play()
end

radMinus.MouseButton1Click:Connect(function() updateRadius(-RAD_STEP) end)
radPlus.MouseButton1Click:Connect(function() updateRadius(RAD_STEP) end)

-- ===== MINIMIZE =====
minBtn.MouseButton1Click:Connect(function()
    if dragMoved then return end
    minimized = not minimized
    if minimized then
        titleLbl.Visible = false
        minBtn.Text = "+"
        minBtn.Position = UDim2.new(0.5, -11, 0.5, -11)
        TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, MINI_SIZE, 0, MINI_SIZE)
        }):Play()
    else
        titleLbl.Visible = true
        minBtn.Text = "−"
        minBtn.Position = UDim2.new(1, -26, 0.5, -11)
        TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
        }):Play()
    end
end)

-- ===== NOCLIP LOGIC =====
local function setNoclip(state)
    noclipActive = state
    if noclipActive then
        noclipConn = RunService.Stepped:Connect(function()
            local c = getChar()
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
    setBtn(noclipBtn, noclipActive, "👻 Noclip  [" .. keyName(NOCLIP_KEY) .. "]")
end

noclipBtn.MouseButton1Click:Connect(function()
    setNoclip(not noclipActive)
end)

kbBtn.MouseButton1Click:Connect(function()
    if rebinding then return end
    rebinding = true
    kbBtn.Text = "Press key..."
    kbBtn.TextColor3 = Color3.fromRGB(210, 20, 20)
end)

-- ===== ANTI-ZOMBIE LOGIC =====
local function setPassiveGlobal(val)
    local globals = game:GetService("ReplicatedStorage"):FindFirstChild("Globals")
    if globals then
        local v = globals:FindFirstChild("ZombiesArePassive")
        if v then pcall(function() v.Value = val end) end
    end
    if _G.Globals and _G.Globals.ZombiesArePassive ~= nil then
        pcall(function() _G.Globals.ZombiesArePassive = val end)
    end
end

local function setAntiZombie(state)
    antiZombieActive = state
    if state then
        setPassiveGlobal(true)
        local zombieFolder = workspace:FindFirstChild("Zombies")
        antiZombieConn = RunService.Heartbeat:Connect(function()
            local myHRP = getHRP()
            if not myHRP then return end
            local zFolder = zombieFolder or workspace:FindFirstChild("Zombies")
            if not zFolder then return end
            local myPos = myHRP.Position
            for _, zombie in ipairs(zFolder:GetChildren()) do
                local hrp = zombie:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - myPos).Magnitude
                    if dist < ZOMBIE_RADIUS then
                        if not frozenZombies[zombie] then
                            frozenZombies[zombie] = true
                            pcall(function()
                                hrp.Anchored = true
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                for _, p in ipairs(zombie:GetDescendants()) do
                                    if p:IsA("BasePart") then
                                        p.AssemblyLinearVelocity = Vector3.zero
                                        p.AssemblyAngularVelocity = Vector3.zero
                                    end
                                end
                            end)
                        end
                    else
                        if frozenZombies[zombie] then
                            frozenZombies[zombie] = nil
                            pcall(function() hrp.Anchored = false end)
                        end
                    end
                end
            end
        end)
        setBtn(antiZombieBtn, true, "🧟 Anti-Zombie")
    else
        if antiZombieConn then antiZombieConn:Disconnect() antiZombieConn = nil end
        setPassiveGlobal(false)
        for zombie in pairs(frozenZombies) do
            pcall(function()
                local hrp = zombie:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end)
        end
        frozenZombies = {}
        setBtn(antiZombieBtn, false, "🧟 Anti-Zombie")
    end
end

antiZombieBtn.MouseButton1Click:Connect(function()
    setAntiZombie(not antiZombieActive)
end)

-- ===== PLAYER LIST LOGIC =====
local playerListOpen = false
local rankCache = {}   -- [UserId] = role string or false
local listRows  = {}   -- [Name]   = Frame

local function getRankAsync(p, cb)
    if rankCache[p.UserId] ~= nil then cb(rankCache[p.UserId]) return end
    task.spawn(function()
        local ok, roleStr = pcall(function() return p:GetRoleInGroup(STAFF_GROUP) end)
        local role = ok and ROLE_MAP[roleStr or ""] or nil
        if not role then
            local ok2, inGroup = pcall(function() return p:IsInGroup(TESTER_GROUP) end)
            if ok2 and inGroup then role = "Tester" end
        end
        rankCache[p.UserId] = role or false
        cb(rankCache[p.UserId])
    end)
end

local function addPlayerRow(p)
    if listRows[p.Name] then return end
    local row = Instance.new("Frame")
    row.Name = p.Name
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    row.BorderSizePixel = 0
    row.Parent = listScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 6, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    dot.BorderSizePixel = 0
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(0.55, -14, 1, 0)
    nameL.Position = UDim2.new(0, 18, 0, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = p.DisplayName
    nameL.TextColor3 = Color3.fromRGB(185, 185, 185)
    nameL.TextSize = 10
    nameL.Font = Enum.Font.Gotham
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.TextTruncate = Enum.TextTruncate.AtEnd
    nameL.Parent = row

    local rankL = Instance.new("TextLabel")
    rankL.Size = UDim2.new(0.45, -4, 1, 0)
    rankL.Position = UDim2.new(0.55, 0, 0, 0)
    rankL.BackgroundTransparency = 1
    rankL.Text = "..."
    rankL.TextColor3 = Color3.fromRGB(80, 80, 80)
    rankL.TextSize = 10
    rankL.Font = Enum.Font.GothamBold
    rankL.TextXAlignment = Enum.TextXAlignment.Right
    rankL.TextTruncate = Enum.TextTruncate.AtEnd
    rankL.Parent = row

    listRows[p.Name] = row

    getRankAsync(p, function(role)
        if not listRows[p.Name] then return end
        if role then
            local c = ROLE_COLOR[role] or Color3.fromRGB(180, 180, 180)
            rankL.Text = role
            rankL.TextColor3 = c
            dot.BackgroundColor3 = c
            row.BackgroundColor3 = Color3.fromRGB(28, 10, 10)
        else
            rankL.Text = "Player"
            rankL.TextColor3 = Color3.fromRGB(90, 90, 110)
        end
    end)
end

local function removePlayerRow(p)
    local row = listRows[p.Name]
    if row then
        row:Destroy()
        listRows[p.Name] = nil
    end
    rankCache[p.UserId] = nil
end

local function setPlayerList(state)
    playerListOpen = state
    listPanel.Visible = state
    if state then
        -- populate current players
        for _, p in ipairs(Players:GetPlayers()) do
            addPlayerRow(p)
        end
    end
    setBtn(playerListBtn, state, "👥 Player List")
end

playerListBtn.MouseButton1Click:Connect(function()
    setPlayerList(not playerListOpen)
end)

Players.PlayerAdded:Connect(function(p)
    if playerListOpen then addPlayerRow(p) end
end)

Players.PlayerRemoving:Connect(function(p)
    removePlayerRow(p)
end)

-- ===== STAFF NOTIFY LOGIC =====
local function showStaffNotif(displayText, role)
    local color = ROLE_COLOR[role] or Color3.fromRGB(200, 200, 200)
    for _, f in ipairs(staffNotifyFrames) do
        TweenService:Create(f, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, 10, f.Position.Y.Scale, f.Position.Y.Offset - 58)
        }):Play()
    end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 270, 0, 52)
    frame.Position = UDim2.new(0, 10, 1, 20)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = frame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -14, 0, 22)
    header.Position = UDim2.new(0, 12, 0, 5)
    header.BackgroundTransparency = 1
    header.Text = "⚠  Staff member joined"
    header.TextColor3 = Color3.fromRGB(200, 200, 200)
    header.TextSize = 11
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = frame
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -14, 0, 18)
    nameLabel.Position = UDim2.new(0, 12, 0, 27)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = displayText .. "  ·  " .. role
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    table.insert(staffNotifyFrames, frame)
    TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 10, 1, -62)
    }):Play()
    task.delay(5, function()
        local idx = table.find(staffNotifyFrames, frame)
        if idx then table.remove(staffNotifyFrames, idx) end
        TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = UDim2.new(-0.25, 0, frame.Position.Y.Scale, frame.Position.Y.Offset)
        }):Play()
        task.delay(0.3, function() frame:Destroy() end)
    end)
end

local function checkStaffPlayer(p)
    if p == player then return end
    task.spawn(function()
        local ok, roleStr = pcall(function() return p:GetRoleInGroup(STAFF_GROUP) end)
        local role = ok and ROLE_MAP[roleStr or ""] or nil
        if not role then
            local ok2, inGroup = pcall(function() return p:IsInGroup(TESTER_GROUP) end)
            if ok2 and inGroup then role = "Tester" end
        end
        if role and staffNotifyActive then
            showStaffNotif(p.DisplayName .. " (@" .. p.Name .. ")", role)
        end
    end)
end

local staffNotifyConn = nil

local function setStaffNotify(state)
    staffNotifyActive = state
    if state then
        staffNotifyConn = Players.PlayerAdded:Connect(checkStaffPlayer)
        for _, p in ipairs(Players:GetPlayers()) do
            checkStaffPlayer(p)
        end
    else
        if staffNotifyConn then staffNotifyConn:Disconnect() staffNotifyConn = nil end
    end
    setBtn(staffNotifyBtn, state, "🔔 Staff Notify")
end

staffNotifyBtn.MouseButton1Click:Connect(function()
    setStaffNotify(not staffNotifyActive)
end)


-- ===== VEHICLE NOCLIP LOGIC =====
local PhysicsService = game:GetService("PhysicsService")
pcall(function()
    PhysicsService:RegisterCollisionGroup("VehicleNoclip")
    PhysicsService:CollisionGroupSetCollidable("VehicleNoclip", "Default", false)
    PhysicsService:CollisionGroupSetCollidable("VehicleNoclip", "VehicleNoclip", false)
end)

local function getVehicle()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, closestDist = nil, 10
    for _, model in ipairs(workspace.Vehicles:GetChildren()) do
        local primary = model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
        if primary then
            local dist = (primary.Position - hrp.Position).Magnitude
            if dist < closestDist then
                closest = model
                closestDist = dist
            end
        end
    end
    return closest
end

local function setVnoclip(state)
    vnoclipActive = state
    if vnoclipActive then
        vnoclipConn = RunService.Stepped:Connect(function()
            local v = getVehicle()
            if not v then return end
            for _, p in ipairs(v:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function()
                        p.CanCollide = false
                        p.CanTouch = false
                    end)
                end
            end
        end)
    else
        if vnoclipConn then vnoclipConn:Disconnect() vnoclipConn = nil end
        local v = getVehicle()
        if v then
            for _, p in ipairs(v:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function()
                        p.CanCollide = true
                        p.CanTouch = true
                    end)
                end
            end
        end
    end
    setBtn(vnoclipBtn, vnoclipActive, "🚗 Vehicle Noclip  [" .. keyName(VNOCLIP_KEY) .. "]")
end

vnoclipBtn.MouseButton1Click:Connect(function()
    setVnoclip(not vnoclipActive)
end)

vnKbBtn.MouseButton1Click:Connect(function()
    if vrebinding then return end
    vrebinding = true
    vnKbBtn.Text = "Press key..."
    vnKbBtn.TextColor3 = Color3.fromRGB(255, 220, 80)
end)


-- ===== INPUT =====
UserInputService.InputBegan:Connect(function(input, gp)
    if rebinding then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            NOCLIP_KEY = input.KeyCode
            kbBtn.Text = "[" .. keyName(NOCLIP_KEY) .. "]"
            kbBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
            rebinding = false
            setBtn(noclipBtn, noclipActive, "👻 Noclip  [" .. keyName(NOCLIP_KEY) .. "]")
        end
        return
    end
    if vrebinding then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            VNOCLIP_KEY = input.KeyCode
            vnKbBtn.Text = "[" .. keyName(VNOCLIP_KEY) .. "]"
            vnKbBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
            vrebinding = false
            setBtn(vnoclipBtn, vnoclipActive, "🚗 Vehicle Noclip  [" .. keyName(VNOCLIP_KEY) .. "]")
        end
        return
    end
    if gp then return end
    if input.KeyCode == NOCLIP_KEY then
        setNoclip(not noclipActive)
    end
    if input.KeyCode == VNOCLIP_KEY then
        setVnoclip(not vnoclipActive)
    end
end)

-- ===== DRAG =====
local dragging, dragStart, startPos = false, nil, nil
local listDragging, listDragStart, listStartPos = false, nil, nil

local function startDrag(input)
    dragging = true
    dragMoved = false
    dragStart = input.Position
    startPos = panel.Position
end

local function startListDrag(input)
    listDragging = true
    listDragStart = input.Position
    listStartPos = listPanel.Position
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(input) end
end)
minBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(input) end
end)
listTitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then startListDrag(input) end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    if dragging then
        local d = input.Position - dragStart
        if d.Magnitude > 3 then dragMoved = true end
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    if listDragging then
        local d = input.Position - listDragStart
        listPanel.Position = UDim2.new(listStartPos.X.Scale, listStartPos.X.Offset + d.X, listStartPos.Y.Scale, listStartPos.Y.Offset + d.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        listDragging = false
    end
end)
