-- ============================================================
--  main.lua  |  ViKo Script Hub  v1.0.4
--  Main logic. Interface is defined in ui_library.lua.
--  Repository: https://github.com/qunientos65242-alt/ViKo
-- ============================================================

-- ── Load interface from repository ───────────────────────────
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/ui_library.lua"
))()

local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/qunientos65242-alt/ViKo/main/games.lua"))()(UI)

local Fluent      = UI.Fluent
local Window      = UI.Window
local Tabs        = UI.Tabs
local SaveManager = UI.SaveManager

-- ── Constants ────────────────────────────────────────────────
local SCRIPT_VERSION = "1.0.4"
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
    local name = try(function()
        return identifyexecutor and identifyexecutor() or nil
    end, nil)
    if name then return tostring(name) end

    name = try(function()
        return getexecutorname and getexecutorname() or nil
    end, nil)
    if name then return tostring(name) end

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

local function supports(name)
    if rawget(_G, name) ~= nil then return true end
    local ok, env = pcall(function()
        return type(getfenv) == "function" and getfenv() or nil
    end)
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
    local info = try(function()
        return MarketService:GetProductInfo(game.PlaceId)
    end, nil)
    return (info and info.Name) or tostring(game.PlaceId)
end

local function startTime()
    return try(function()
        return os.date and os.date("%H:%M:%S") or nil
    end, "t=" .. tostring(round(startTick)))
end

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

-- ── Identity ─────────────────────────────────────────────────
Tabs.Profile:AddParagraph({
    Title   = "Identity",
    Content = table.concat({
        "  Username     " .. player.Name,
        "  Display Name " .. player.DisplayName,
        "  User ID      " .. tostring(player.UserId),
        "  Account Age  " .. accountAge(),
        "  Member of    " .. try(function()
            return player.MembershipType == Enum.MembershipType.Premium
                and "Roblox Premium" or "No Premium"
        end, "N/A"),
    }, "\n"),
})

-- ── Current Session ───────────────────────────────────────────
Tabs.Profile:AddParagraph({
    Title   = "Current Session",
    Content = table.concat({
        "  Game         " .. gameName(),
        "  Place ID     " .. tostring(game.PlaceId),
        "  Server ID    " .. (#sessionId > 28 and sessionId:sub(1,26).."..." or sessionId),
        "  Server Size  " .. tostring(#Players:GetPlayers()) .. " / " ..
                             tostring(Players.MaxPlayers) .. " players",
        "  VIP Server   " .. tostring(game.VIPServerId ~= "" and "Yes" or "No"),
    }, "\n"),
})

-- ── Character (live) ──────────────────────────────────────────
local characterParagraph = Tabs.Profile:AddParagraph({
    Title   = "Character",
    Content = "Loading...",
})

-- ── Network (live) ────────────────────────────────────────────
local networkParagraph = Tabs.Profile:AddParagraph({
    Title   = "Network & Performance",
    Content = "Loading...",
})

-- ════════════════════════════════════════════════════════════
--  TAB: FULL INFO
-- ════════════════════════════════════════════════════════════

-- ── Executor ──────────────────────────────────────────────────
Tabs.FullInfo:AddParagraph({
    Title   = "Executor",
    Content = table.concat({
        "  Name         " .. getExecutor(),
        "  UI Library   Fluent v" .. tostring(Fluent.Version or "latest"),
        "  Script       v" .. SCRIPT_VERSION,
        "  Lua Version  " .. (LuaVersion or tostring(_VERSION or "Luau")),
    }, "\n"),
})

-- ── Repository ────────────────────────────────────────────────
Tabs.FullInfo:AddParagraph({
    Title   = "Repository",
    Content = table.concat({
        "  Script Hub   " .. URL_REPO,
        "  UI Source    " .. URL_UI,
    }, "\n"),
})

-- ── Executor Capabilities ────────────────────────────────────
local capabilities = {
    { "HTTP Request    (request)",      "request"      },
    { "Write File      (writefile)",    "writefile"    },
    { "Read File       (readfile)",     "readfile"     },
    { "Load String     (loadstring)",   "loadstring"   },
    { "Hook Function   (hookfunction)", "hookfunction" },
    { "GC Access       (getgc)",        "getgc"        },
    { "Debug Library   (debug)",        "debug"        },
    { "Drawing API     (Drawing)",      "Drawing"      },
    { "Hidden GUI      (gethui)",       "gethui"       },
    { "Clipboard       (setclipboard)", "setclipboard" },
    { "Synapse Request (syn)",          "syn"          },
    { "Filesystem      (listfiles)",    "listfiles"    },
}

local capLines = {}
for _, cap in ipairs(capabilities) do
    local available = try(function() return supports(cap[2]) end, false)
    table.insert(capLines, (available and "  [YES]  " or "  [NO]   ") .. cap[1])
end

Tabs.FullInfo:AddParagraph({
    Title   = "Executor Capabilities",
    Content = table.concat(capLines, "\n"),
})

-- ── Runtime Stats (live) ──────────────────────────────────────
local runtimeParagraph = Tabs.FullInfo:AddParagraph({
    Title   = "Runtime Stats",
    Content = "Loading...",
})

-- ════════════════════════════════════════════════════════════
--  TAB: SETTINGS
-- ════════════════════════════════════════════════════════════

-- ── Config Management ─────────────────────────────────────────
Tabs.Settings:AddSection("Config Management")

-- Resolve the real folder Fluent uses to save configs
local function getConfigFolder()
    if SaveManager and SaveManager.Folder then
        return SaveManager.Folder
    end
    return "fluentscripts"
end

-- Delete ALL config files
Tabs.Settings:AddButton({
    Title       = "Delete All Configs",
    Description = "Permanently removes every saved configuration file",
    Callback    = function()
        -- Require filesystem support
        if not (listfiles and delfile) then
            Fluent:Notify({
                Title    = "Not Supported",
                Content  = "Your executor does not support filesystem access.",
                Duration = 4,
            })
            return
        end

        local folder  = getConfigFolder()
        local deleted = 0
        local failed  = 0

        local ok, files = pcall(listfiles, folder)
        if ok and files then
            for _, path in ipairs(files) do
                -- Only target .json config files
                if tostring(path):sub(-5) == ".json" then
                    if pcall(delfile, path) then
                        deleted = deleted + 1
                    else
                        failed = failed + 1
                    end
                end
            end
        end

        if deleted > 0 then
            Fluent:Notify({
                Title    = "Configs Deleted",
                Content  = "Removed " .. deleted .. " config(s)."
                    .. (failed > 0 and " Failed: " .. failed .. "." or ""),
                Duration = 5,
            })
        else
            Fluent:Notify({
                Title    = "Nothing to Delete",
                Content  = "No config files found in: " .. folder,
                Duration = 4,
            })
        end
    end,
})

-- Delete ONLY the currently selected config
Tabs.Settings:AddButton({
    Title       = "Delete Current Config",
    Description = "Removes only the currently active configuration file",
    Callback    = function()
        if not (isfile and delfile) then
            Fluent:Notify({
                Title    = "Not Supported",
                Content  = "Your executor does not support filesystem access.",
                Duration = 4,
            })
            return
        end

        local configName = try(function()
            return SaveManager and SaveManager.CurrentConfig or nil
        end, nil)

        if not configName or configName == "" then
            Fluent:Notify({
                Title    = "No Config Selected",
                Content  = "Select a config from the list first.",
                Duration = 4,
            })
            return
        end

        local path = getConfigFolder() .. "/" .. configName .. ".json"

        if isfile(path) then
            if pcall(delfile, path) then
                Fluent:Notify({
                    Title    = "Config Deleted",
                    Content  = '"'.. configName ..'" removed successfully.',
                    Duration = 4,
                })
            else
                Fluent:Notify({
                    Title    = "Delete Failed",
                    Content  = "Could not delete the file. Check executor permissions.",
                    Duration = 4,
                })
            end
        else
            Fluent:Notify({
                Title    = "File Not Found",
                Content  = '"'.. configName ..'"' .. " does not exist.",
                Duration = 4,
            })
        end
    end,
})

-- ── Interface ─────────────────────────────────────────────────
Tabs.Settings:AddSection("Interface")

Tabs.Settings:AddDropdown("Theme", {
    Title   = "UI Theme",
    Values  = { "Dark", "Light", "Darker", "Aqua", "Amethyst" },
    Default = "Dark",
    Callback = function(value)
        Fluent:SetTheme(value)
    end,
})

-- ════════════════════════════════════════════════════════════
--  LIVE UPDATE LOOP
-- ════════════════════════════════════════════════════════════
local accumulator = 0

RunService.Heartbeat:Connect(function(dt)
    accumulator = accumulator + dt
    if accumulator < 1 then return end
    accumulator = 0

    -- Runtime stats (Full Info tab)
    pcall(function()
        local fps  = round(dt > 0 and (1/dt) or 0)
        local ping = try(function()
            return round(player:GetNetworkPing() * 1000)
        end, 0)
        local mem  = try(function()
            return round(StatsService:GetTotalMemoryUsageMb())
        end, 0)

        runtimeParagraph:SetDesc(table.concat({
            "  Uptime       " .. formatUptime(tick() - startTick),
            "  Started At   " .. startTime(),
            "  FPS          " .. fps .. " fps",
            "  Ping         " .. ping .. " ms",
            "  Memory       " .. mem .. " MB",
        }, "\n"))
    end)

    -- Network & Performance (Profile tab)
    pcall(function()
        local fps  = round(dt > 0 and (1/dt) or 0)
        local ping = try(function()
            return round(player:GetNetworkPing() * 1000)
        end, 0)
        local pingQuality = ping < 80 and "Good" or ping < 150 and "Fair" or "Poor"

        networkParagraph:SetDesc(table.concat({
            "  FPS          " .. fps .. " fps",
            "  Ping         " .. ping .. " ms  (" .. pingQuality .. ")",
            "  Uptime       " .. formatUptime(tick() - startTick),
        }, "\n"))
    end)

    -- Character (Profile tab)
    pcall(function()
        local char     = player.Character
        local team     = player.Team and player.Team.Name or "No team"
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local health   = humanoid
            and (tostring(round(humanoid.Health)) .. " / " .. tostring(round(humanoid.MaxHealth)))
            or "N/A"
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

-- ── Final window setup ────────────────────────────────────────
Window:SetSubtitle("v" .. SCRIPT_VERSION .. " · " .. getExecutor())
Window:SelectTab(1)

Fluent:Notify({
    Title    = "ViKo loaded",
    Content  = "Version " .. SCRIPT_VERSION .. " · " .. getExecutor(),
    Duration = 5,
})

print(("[ViKo] v%s ready | Executor: %s"):format(SCRIPT_VERSION, getExecutor()))
