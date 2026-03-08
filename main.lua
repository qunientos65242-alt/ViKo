-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.3
--  Main logic. Interface is defined in ui_library.lua.
--  Repository: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

-- ── Load interface from repository ───────────────────────────
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"
))()

local Fluent = UI.Fluent
local Window = UI.Window
local Tabs   = UI.Tabs

-- ── Constants ────────────────────────────────────────────────
local SCRIPT_VERSION = "1.0.3"
local URL_REPO       = "https://github.com/qunientos65242-alt/ViKo"
local URL_UI         = "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"

-- ── Roblox Services ──────────────────────────────────────────
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local MarketService = game:GetService("MarketplaceService")

local player    = Players.LocalPlayer
local startTick = tick()

-- ════════════════════════════════════════════════════════════
--  HELPER FUNCTIONS
-- ════════════════════════════════════════════════════════════

-- Safely calls a function; returns fallback if it errors or returns nil
local function try(fn, fallback)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return fallback
end

-- Safe round (math.round does not exist in base Luau)
local function round(n)
    return math.floor(n + 0.5)
end

-- Detects the name of the executor being used
local function getExecutor()
    local name = try(function()
        return identifyexecutor and identifyexecutor() or nil
    end, nil)
    if name then return tostring(name) end

    name = try(function()
        return getexecutorname and getexecutorname() or nil
    end, nil)
    if name then return tostring(name) end

    -- Detection by known global signatures
    local signatures = {
        {"KRNL_LOADED","Krnl"}, {"syn","Synapse X"}, {"fluxus","Fluxus"},
        {"DELTA_VERSION","Delta"}, {"MACSPLOIT_VERSION","MacSploit"},
    }
    for _, s in ipairs(signatures) do
        if try(function() return rawget(_G, s[1]) ~= nil end, false) then
            return s[2]
        end
    end
    return "Unknown"
end

-- Checks if the executor supports a specific function
local function supports(name)
    if rawget(_G, name) ~= nil then return true end
    local ok, env = pcall(function()
        return type(getfenv) == "function" and getfenv() or nil
    end)
    return ok and env and env[name] ~= nil
end

-- Returns the account age in a readable format
local function accountAge()
    local days = try(function() return player.AccountAge end, nil)
    if not days then return "N/A" end
    if days < 1   then return "Today" end
    if days < 30  then return days .. " day(s)" end
    if days < 365 then return ("%.1f month(s)"):format(days / 30) end
    return ("%.1f year(s)"):format(days / 365)
end

-- Safely gets the name of the current game
local function gameName()
    local info = try(function()
        return MarketService:GetProductInfo(game.PlaceId)
    end, nil)
    return (info and info.Name) or tostring(game.PlaceId)
end

-- Returns the time when the script started
local function startTime()
    return try(function()
        return os.date and os.date("%H:%M:%S") or nil
    end, "t=" .. tostring(round(startTick)))
end

-- Converts seconds into a readable hh mm ss format
local function formatUptime(s)
    s = math.floor(s)
    if s < 60   then return s .. "s" end
    if s < 3600 then return ("%dm %ds"):format(math.floor(s/60), s%60) end
    return ("%dh %dm %ds"):format(math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

-- ════════════════════════════════════════════════════════════
--  TAB: PROFILE
-- ════════════════════════════════════════════════════════════
local sessionId = try(function() return tostring(game.JobId) end, "N/A")

-- Identity section
Tabs.Profile:AddParagraph({
    Title   = "Identity",
    Content = table.concat({
        "Username   : " .. player.Name,
        "Display    : " .. player.DisplayName,
        "User ID    : " .. tostring(player.UserId),
        "Account Age: " .. accountAge(),
    }, "\n"),
})

-- Current Session section
Tabs.Profile:AddParagraph({
    Title   = "Current Session",
    Content = table.concat({
        "Game     : " .. gameName(),
        "Place ID : " .. tostring(game.PlaceId),
        "Server ID: " .. (#sessionId > 24 and sessionId:sub(1,22).."..." or sessionId),
    }, "\n"),
})

-- Character section (updates live)
local characterParagraph = Tabs.Profile:AddParagraph({
    Title   = "Character",
    Content = "Loading...",
})

-- ════════════════════════════════════════════════════════════
--  TAB: FULL INFO
-- ════════════════════════════════════════════════════════════

-- Executor section
Tabs.FullInfo:AddParagraph({
    Title   = "Executor",
    Content = table.concat({
        "Name      : " .. getExecutor(),
        "UI Library: Fluent v" .. tostring(Fluent.Version or "latest"),
        "Version   : v" .. SCRIPT_VERSION,
    }, "\n"),
})

-- Repository section
Tabs.FullInfo:AddParagraph({
    Title   = "Repository",
    Content = table.concat({
        "Script Hub : " .. URL_REPO,
        "UI Library : " .. URL_UI,
    }, "\n"),
})

-- Executor Capabilities section
local capabilities = {
    {"request / http_request", "request"      },
    {"writefile",              "writefile"     },
    {"readfile",               "readfile"      },
    {"loadstring",             "loadstring"    },
    {"hookfunction",           "hookfunction"  },
    {"getgc",                  "getgc"         },
    {"debug (lib)",            "debug"         },
    {"Drawing (API)",          "Drawing"       },
    {"gethui",                 "gethui"        },
    {"setclipboard",           "setclipboard"  },
    {"syn.request",            "syn"           },
}

local capLines = {}
for _, cap in ipairs(capabilities) do
    local available = try(function() return supports(cap[2]) end, false)
    table.insert(capLines, (available and "[YES]  " or "[NO]   ") .. cap[1])
end

Tabs.FullInfo:AddParagraph({
    Title   = "Executor Capabilities",
    Content = table.concat(capLines, "\n"),
})

-- Uptime section (updates live)
local uptimeParagraph = Tabs.FullInfo:AddParagraph({
    Title   = "Execution Time",
    Content = "Starting...",
})

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP
-- ════════════════════════════════════════════════════════════
local accumulator = 0

RunService.Heartbeat:Connect(function(dt)
    accumulator = accumulator + dt
    if accumulator < 1 then return end
    accumulator = 0

    -- Update uptime, FPS and ping
    pcall(function()
        local fps  = round(dt > 0 and (1/dt) or 0)
        local ping = try(function()
            return round(player:GetNetworkPing() * 1000)
        end, 0)

        uptimeParagraph:SetDesc(table.concat({
            "Uptime    : " .. formatUptime(tick() - startTick),
            "FPS       : " .. fps  .. " fps",
            "Ping      : " .. ping .. " ms",
            "Started at: " .. startTime(),
        }, "\n"))
    end)

    -- Update character data
    pcall(function()
        local char     = player.Character
        local team     = player.Team and player.Team.Name or "No team"
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local health   = humanoid
            and (tostring(round(humanoid.Health)) .. " / " .. tostring(round(humanoid.MaxHealth)))
            or "N/A"

        characterParagraph:SetDesc(table.concat({
            "Avatar loaded: " .. (char and "Yes" or "No"),
            "Team         : " .. team,
            "Health       : " .. health,
        }, "\n"))
    end)
end)

-- ── Final window setup ────────────────────────────────────────
Window:SetSubtitle("v" .. SCRIPT_VERSION .. " · " .. getExecutor())
Window:SelectTab(1)

-- Welcome notification
Fluent:Notify({
    Title    = "ViKo loaded",
    Content  = "Version " .. SCRIPT_VERSION .. " · " .. getExecutor(),
    Duration = 5,
})

print(("[ViKo] v%s ready | Executor: %s"):format(SCRIPT_VERSION, getExecutor()))
