function ReadOptionsTable(pn)
    local options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
    local t = {}

    -- speedmod
    local speed = GetSpeed(pn)
    if speed then
        t.SpeedMod = speed[1]
        t.SpeedType = speed[2]
    else
        t.SpeedMod = DEFAULT_SPEED_VALUE
        t.SpeedType = DEFAULT_SPEED_TYPE
    end

    if PROFILEMAN:IsPersistentProfile(pn) then
        local profile_dir = GetPlayerOrMachineProfileDir(pn)
        t.Increment = LoadModule("Config.Load.lua")("Increment", profile_dir.."/"..PlayerConfigDir) or DEFAULT_INCREMENT
        t.Increment = math.ceil( t.Increment )
    else
        t.Increment = DEFAULT_INCREMENT
    end

    t.Hidden = options:Hidden()
    t.Sudden = options:Sudden()
    t.Stealth = options:Stealth()
    t.Blink = options:Blink()

    t.Dizzy = options:Dizzy()
    t.Tipsy = options:Tipsy()
    t.Drunk = options:Drunk()
    t.Boost = options:Boost()
    t.Brake = options:Brake()
    t.Boomerang = options:Boomerang()
    t.Tornado = options:Tornado()
    t.Invert = options:Invert()
    t.Flip = options:Flip()

    t.Reverse = options:Reverse()
    t.Noteskin = options:NoteSkin()

    return t
end

function WriteOptionsTable(pn, t)
    local state = GAMESTATE:GetPlayerState(pn)
    local options = state:GetPlayerOptions("ModsLevel_Preferred")
    
    SetSpeed(pn, t.SpeedMod, t.SpeedType)

    if PROFILEMAN:IsPersistentProfile(pn) then
        local profile_dir = GetPlayerOrMachineProfileDir(pn)
        LoadModule("Config.Save.lua")("Increment", math.ceil( t.Increment ) or 25, profile_dir.."/"..PlayerConfigDir)
    end
    
    options:Hidden( t.Hidden or 0 )
    options:Sudden( t.Sudden or 0 )
    options:Stealth( t.Stealth or 0 )
    options:Blink( t.Blink or 0 )

    options:Dizzy( t.Dizzy or 0 )
    options:Tipsy( t.Tipsy or 0 )
    options:Drunk( t.Drunk or 0 )
    options:Boost( t.Boost or 0 )
    options:Brake( t.Brake or 0 )
    options:Boomerang( t.Boomerang or 0 )
    options:Tornado( t.Tornado or 0 )
    options:Invert( t.Invert or 0 )
    options:Flip( t.Flip or 0 )

    options:NoteSkin(t.Noteskin or "default")
    options:Reverse(t.Reverse or 0)

    state:ApplyPreferredOptionsToOtherLevels()
    return t
end

local function ItemMenu(label, choices)
    return { Name = label, Type = OptionsType.Menu, Choices = choices }
end

local function ItemChoices(label, default, choices)
    return { Name = label, Type = OptionsType.Value, Default = default, Choices = choices }
end

local function ItemRange(label, default, min, max, step)
    return { Name = label, Type = OptionsType.Value, Default = default, Range = { Min = min, Max = max, Step = step } }
end

local function ItemToggle(label, default, choices)
    return { Name = label, Type = OptionsType.Toggle, Default = default, Choices = choices or { 0, 1 } }
end

local function ItemAction(label, func)
    return { Name = label, Type = OptionsType.Action, Action = func }
end

local function ItemExit(label)
    return { Name = label, Type = OptionsType.Exit }
end


local function ResetSpeed(t)
    t.SpeedMod = DEFAULT_SPEED_VALUE
    t.SpeedType = DEFAULT_SPEED_TYPE
    t.Increment = DEFAULT_INCREMENT
end


local function ResetDisplay(t)
    t.Hidden = 0
    t.Sudden = 0
    t.Stealth = 0
    t.Blink = 0
end

local function ResetTransform(t)
    t.Reverse = 0
end

local function ResetModifiers(t)
    t.Dizzy = 0
    t.Tipsy = 0
    t.Drunk = 0
    t.Boost = 0
    t.Brake = 0
    t.Boomerang = 0
    t.Tornado = 0
    t.Invert = 0
    t.Flip = 0
end

local function ResetAll(t)
    ResetSpeed(t)
    ResetDisplay(t)
    ResetTransform(t)
    ResetModifiers(t)
end


-- options layout
OptionsList = {
    {
        Name = "Speed", 
        Icon = 0,
        Type = OptionsType.Menu,
        Choices = {
            ItemRange( "SpeedMod", 250, 1, 9999, 25 ),
            ItemChoices( "Increment", 25, { 5, 10, 25, 50, 100 }),
            ItemChoices( "SpeedType", "maximum", SpeedType),
            ItemAction( "Reset", function(t) ResetSpeed(t) end),
            ItemExit( "Exit" )
        },
    },
    
    ItemChoices( "Noteskin", 1, NOTESKIN:GetNoteSkinNames()),

    {
        Name = "Display",
        Type = OptionsType.Menu,
        Choices = {
            ItemToggle( "Hidden", 0 ),
            ItemToggle( "Sudden", 0 ),
            ItemToggle( "Stealth", 0 ),
            ItemToggle( "Blink", 0 ),
            -- glow during fade [?]
            { Name = "Extras", Type = OptionsType.Menu, Disabled = true },
            -- ItemMenu( "Extras", {
            --     ItemToggle( "ReverseJudgment", false ),
            --     ItemToggle( "ShowScreenFilter", false ),
            --     ItemToggle( "ShowEarlyLate", false ),
            --     ItemToggle( "ShowOffsetMeter", false ),
            --     ItemToggle( "ShowDetailedInfo", false ),
            --     ItemExit( "Exit" ),
            -- }),
            ItemAction( "Reset", function(t) ResetDisplay(t) end),
            ItemExit( "Exit" ),
        },
    },

    {
        Name = "Transform",
        Type = OptionsType.Menu,
        Choices = {
            { Name = "Zoom", Type = OptionsType.Menu, Disabled = true },
                -- zoom x y z
            { Name = "Rotation", Type = OptionsType.Menu, Disabled = true },
                -- rotation x y z
            ItemMenu( "Viewport", {
                ItemToggle( "Reverse", 0 ),
                -- yoffset
                -- fov
                ItemExit( "Exit" ),
            }),
            ItemAction( "Reset", function(t) ResetTransform(t) end),
            ItemExit( "Exit" )
        },
    },
    
    {
        Name = "Effects",
        Type = OptionsType.Menu,
        Choices = {
            ItemToggle( "Dizzy", 0 ),
            ItemToggle( "Tipsy", 0 ),
            ItemToggle( "Drunk", 0 ),
            ItemToggle( "Boost", 0 ),
            ItemToggle( "Brake", 0 ),
            ItemToggle( "Boomerang", 0 ),
            ItemToggle( "Tornado", 0 ),
            ItemToggle( "Invert", 0 ),
            ItemToggle( "Flip", 0 ),
            ItemAction( "Reset", function(t) ResetModifiers(t) end),
            ItemExit( "Exit" )
        },
    },
    
    ItemAction( "Reset All", function(t) ResetAll(t) end),
    ItemExit("Exit")
}

