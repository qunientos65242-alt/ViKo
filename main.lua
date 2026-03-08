-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.8
--  Main logic. Interface is defined in ui_library.lua.
--  Repository: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

-- ── Load interface from repository ───────────────────────────
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"
))()

local Fluent      = UI.Fluent
local Window      = UI.Window
local Tabs        = UI.Tabs
local SaveManager = UI.SaveManager

-- ── Cargar Funciones Externas ────────────────────────────────
local Features = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/refs/heads/main/features.lua"
))()

-- ── Constants ────────────────────────────────────────────────
local SCRIPT_VERSION = "1.0.8"
local URL_REPO       = "https://github.com/qunientos65242-alt/ViKo"
local URL_UI         = "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"

-- ── Roblox Services ──────────────────────────────────────────
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local MarketService = game:GetService("MarketplaceService")
local StatsService  = game:GetService("Stats")

local player    = Players.LocalPlayer
local startTick = tick()

-- ════════════════════════════════════════════════════════════
--  HELPER FUNCTIONS
-- ════════════════════════════════════════════════════════════

local function try(fn, fallback)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return fallback
end

local function round(n)
    return math.floor(n + 0.5)
end

local function getExecutor()
    local name = try(function() return identifyexecutor and identifyexecutor() or nil end, nil)
    if name then return tostring(name) end
    name = try(function() return getexecutorname and getexecutorname() or nil end, nil)
    if name then return tostring(name) end

    local signatures = {
        {"KRNL_LOADED","Krnl"}, {"syn","Synapse X"}, {"fluxus","Fluxus"},
        {"DELTA_VERSION","Delta"}, {"MACSPLOIT_VERSION","MacSploit"},
    }
    for _, s in ipairs(signatures) do
        if try(function() return rawget(_G, s[1]) ~= nil end, false) then return s[2] end
    end
    return "Unknown"
end

local function supports(name)
    if rawget(_G, name) ~= nil then return true end
    local ok, env = pcall(function() return type(getfenv) == "function" and getfenv() or nil end)
    return ok and env and env[name] ~= nil
end

local function accountAge()
    local days = try(function() return player.AccountAge end, nil)
    if not days then return "N/A" end
    if days < 1   then return "Today" end
    if days < 30  then return days .. " day(s)" end
    if days < 365 then return ("%.1f month(s)"):format(days / 30) end
    return ("%.1f year(s)"):format(days / 365)
end

local function gameName()
    local info = try(function() return MarketService:GetProductInfo(game.PlaceId) end, nil)
    return (info and info.Name) or tostring(game.PlaceId)
end

local function startTime()
    return try(function() return os.date and os.date("%H:%M:%S") or nil end, "t=" .. tostring(round(startTick)))
end

local function formatUptime(s)
    s = math.floor(s)
    if s < 60   then return s .. "s" end
    if s < 3600 then return ("%dm %ds"):format(math.floor(s/60), s%60) end
    return ("%dh %dm %ds"):format(math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  TAB: MAIN (Movement Enhancements)
-- ════════════════════════════════════════════════════════════
local MainSection = Tabs.Main:AddSection("Movement & Hacks")

Tabs.Main:AddToggle("FlyToggle", { Title = "Fly Mode (High IQ)", Default = false, Callback = function(V) Features.ToggleFly(V) end })
Tabs.Main:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 50, Min = 10, Max = 500, Rounding = 0, Callback = function(V) Features.FlySpeed = V end })
Tabs.Main:AddToggle("SpeedToggle", { Title = "Speed Hack", Default = false, Callback = function(V) Features.Enabled = V end })
Tabs.Main:AddSlider("WalkSpeed", { Title = "Walk Speed", Default = 16, Min = 16, Max = 500, Rounding = 0, Callback = function(V) Features.WalkSpeedValue = V end })
Tabs.Main:AddToggle("InfJump", { Title = "Infinite Jump", Default = false, Callback = function(V) Features.InfJump = V end })
Tabs.Main:AddToggle("Noclip", { Title = "Noclip (Safe)", Default = false, Callback = function(V) Features.Noclip = V end })

-- ── WAYPOINT SYSTEM (Puntos de Guardado) ────────────────────
local WaypointSection = Tabs.Main:AddSection("Waypoints System (Max 10)")

local savedPoints = {} -- Diccionario para guardar coords
local pointNames = {}  -- Lista para el Dropdown
local selectedPoint = nil
local pointCounter = 1

local Dropdown = Tabs.Main:AddDropdown("WaypointSelect", {
    Title = "Saved Locations",
    Values = pointNames,
    Multi = false,
    Default = nil,
    Callback = function(Value)
        selectedPoint = Value
    end
})

Tabs.Main:AddButton({
    Title = "Save Current Location",
    Description = "Saves where you are standing right now",
    Callback = function()
        if #pointNames >= 10 then
            Fluent:Notify({Title = "Limit Reached", Content = "You can only save up to 10 points! Delete one first.", Duration = 4})
            return
        end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local p = root.Position
            local name = string.format("Point #%d", pointCounter)
            pointCounter = pointCounter + 1
            
            savedPoints[name] = {x = p.X, y = p.Y, z = p.Z}
            table.insert(pointNames, name)
            
            Dropdown:SetValues(pointNames)
            Dropdown:SetValue(name)
            Fluent:Notify({Title = "Waypoint Saved", Content = name .. " has been saved.", Duration = 2})
        end
    end
})

Tabs.Main:AddButton({
    Title = "Teleport to Selected",
    Description = "Teleports you to the point chosen in the dropdown",
    Callback = function()
        if selectedPoint and savedPoints[selectedPoint] then
            local coords = savedPoints[selectedPoint]
            Features.TeleportTo(coords.x, coords.y, coords.z)
        else
            Fluent:Notify({Title = "Error", Content = "Please select a valid point from the list.", Duration = 2})
        end
    end
})

Tabs.Main:AddButton({
    Title = "Delete Selected Point",
    Description = "Removes the selected point to free up space",
    Callback = function()
        if selectedPoint and savedPoints[selectedPoint] then
            savedPoints[selectedPoint] = nil -- Borra las coords
            
            -- Reconstruir la lista
            local newNames = {}
            for _, name in ipairs(pointNames) do
                if name ~= selectedPoint then
                    table.insert(newNames, name)
                end
            end
            pointNames = newNames
            
            Dropdown:SetValues(pointNames)
            selectedPoint = pointNames[1] or nil
            if selectedPoint then Dropdown:SetValue(selectedPoint) end
            
            Fluent:Notify({Title = "Deleted", Content = "Waypoint removed.", Duration = 2})
        end
    end
})

-- ════════════════════════════════════════════════════════════
--  TAB: PROFILE (Restaurado)
-- ════════════════════════════════════════════════════════════
local sessionId = try(function() return tostring(game.JobId) end, "N/A")

Tabs.Profile:AddParagraph({
    Title   = "Identity",
    Content = table.concat({
        "  Username     " .. player.Name,
        "  Display Name " .. player.DisplayName,
        "  User ID      " .. tostring(player.UserId),
        "  Account Age  " .. accountAge(),
        "  Member of    " .. try(function() return player.MembershipType == Enum.MembershipType.Premium and "Roblox Premium" or "No Premium" end, "N/A"),
    }, "\n"),
})

Tabs.Profile:AddParagraph({
    Title   = "Current Session",
    Content = table.concat({
        "  Game         " .. gameName(),
        "  Place ID     " .. tostring(game.PlaceId),
        "  Server ID    " .. (#sessionId > 28 and sessionId:sub(1,26).."..." or sessionId),
        "  Server Size  " .. tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers) .. " players",
        "  VIP Server   " .. tostring(game.VIPServerId ~= "" and "Yes" or "No"),
    }, "\n"),
})

local characterParagraph = Tabs.Profile:AddParagraph({ Title = "Character", Content = "Loading..." })
local networkParagraph = Tabs.Profile:AddParagraph({ Title = "Network & Performance", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  TAB: FULL INFO (Restaurado)
-- ════════════════════════════════════════════════════════════
Tabs.FullInfo:AddParagraph({
    Title   = "Executor",
    Content = table.concat({
        "  Name         " .. getExecutor(),
        "  UI Library   Fluent v" .. tostring(Fluent.Version or "latest"),
        "  Script       v" .. SCRIPT_VERSION,
        "  Lua Version  " .. (LuaVersion or tostring(_VERSION or "Luau")),
    }, "\n"),
})

Tabs.FullInfo:AddParagraph({
    Title   = "Repository",
    Content = table.concat({
        "  Script Hub   " .. URL_REPO,
        "  UI Source    " .. URL_UI,
    }, "\n"),
})

local capabilities = {
    { "HTTP Request    (request)",      "request"      }, { "Write File      (writefile)",    "writefile"    },
    { "Read File       (readfile)",     "readfile"     }, { "Load String     (loadstring)",   "loadstring"   },
    { "Hook Function   (hookfunction)", "hookfunction" }, { "GC Access       (getgc)",        "getgc"        },
    { "Debug Library   (debug)",        "debug"        }, { "Drawing API     (Drawing)",      "Drawing"      },
    { "Hidden GUI      (gethui)",       "gethui"       }, { "Clipboard       (setclipboard)", "setclipboard" },
    { "Synapse Request (syn)",          "syn"          }, { "Filesystem      (listfiles)",    "listfiles"    },
}

local capLines = {}
for _, cap in ipairs(capabilities) do
    local available = try(function() return supports(cap[2]) end, false)
    table.insert(capLines, (available and "  [YES]  " or "  [NO]   ") .. cap[1])
end

Tabs.FullInfo:AddParagraph({ Title = "Executor Capabilities", Content = table.concat(capLines, "\n") })

local runtimeParagraph = Tabs.FullInfo:AddParagraph({ Title = "Runtime Stats", Content = "Loading..." })

-- ════════════════════════════════════════════════════════════
--  TAB: SETTINGS (Restaurado)
-- ════════════════════════════════════════════════════════════
Tabs.Settings:AddSection("Config Management")

local function getConfigFolder()
    if SaveManager and SaveManager.Folder then return SaveManager.Folder end
    return "fluentscripts"
end

Tabs.Settings:AddButton({
    Title = "Delete All Configs", Description = "Permanently removes every saved configuration file",
    Callback = function()
        if not (listfiles and delfile) then return Fluent:Notify({Title="Error", Content="Not supported by executor", Duration=4}) end
        local folder, deleted = getConfigFolder(), 0
        local ok, files = pcall(listfiles, folder)
        if ok and files then
            for _, path in ipairs(files) do
                if tostring(path):sub(-5) == ".json" and pcall(delfile, path) then deleted = deleted + 1 end
            end
        end
        Fluent:Notify({Title = "Configs Deleted", Content = "Removed " .. deleted .. " config(s).", Duration = 5})
    end,
})

Tabs.Settings:AddSection("Interface")
Tabs.Settings:AddDropdown("Theme", {
    Title = "UI Theme", Values = { "Dark", "Light", "Darker", "Aqua", "Amethyst" }, Default = "Dark",
    Callback = function(value) Fluent:SetTheme(value) end,
})

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP (Restaurado completo)
-- ════════════════════════════════════════════════════════════
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
    accumulator = accumulator + dt
    if accumulator < 1 then return end
    accumulator = 0

    pcall(function()
        local fps  = round(dt > 0 and (1/dt) or 0)
        local ping = try(function() return round(player:GetNetworkPing() * 1000) end, 0)
        local mem  = try(function() return round(StatsService:GetTotalMemoryUsageMb()) end, 0)

        runtimeParagraph:SetDesc(table.concat({
            "  Uptime       " .. formatUptime(tick() - startTick),
            "  Started At   " .. startTime(),
            "  FPS          " .. fps .. " fps",
            "  Ping         " .. ping .. " ms",
            "  Memory       " .. mem .. " MB",
        }, "\n"))

        local pingQuality = ping < 80 and "Good" or ping < 150 and "Fair" or "Poor"
        networkParagraph:SetDesc(table.concat({
            "  FPS          " .. fps .. " fps",
            "  Ping         " .. ping .. " ms  (" .. pingQuality .. ")",
            "  Uptime       " .. formatUptime(tick() - startTick),
        }, "\n"))

        local char     = player.Character
        local team     = player.Team and player.Team.Name or "No team"
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local health   = humanoid and (tostring(round(humanoid.Health)) .. " / " .. tostring(round(humanoid.MaxHealth))) or "N/A"
        local speed    = humanoid and tostring(round(humanoid.WalkSpeed)) or "N/A"
        local jumpPow  = humanoid and tostring(round(humanoid.JumpPower)) or "N/A"

        characterParagraph:SetDesc(table.concat({
            "  Avatar       " .. (char and "Loaded" or "Not loaded"),
            "  Team         " .. team,
            "  Health       " .. health,
            "  Walk Speed   " .. speed,
            "  Jump Power   " .. jumpPow,
        }, "\n"))
    end)
end)

Window:SetSubtitle("v" .. SCRIPT_VERSION .. " · " .. getExecutor())
Window:SelectTab(1)
Fluent:Notify({ Title = "ViKo loaded", Content = "Version " .. SCRIPT_VERSION .. " ready!", Duration = 5 })
