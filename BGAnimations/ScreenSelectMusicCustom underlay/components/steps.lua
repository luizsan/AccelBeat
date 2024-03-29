local radar = {
    "RadarCategory_TapsAndHolds",
    "RadarCategory_Jumps",
    "RadarCategory_Holds",
    "RadarCategory_Mines",
    "RadarCategory_Hands",
    "RadarCategory_Rolls"
    --["RadarCategory_Lifts"] = 0,
}

local nps = {
    [PLAYER_1] = { peak = 0, average = 0, density = 0 },
    [PLAYER_2] = { peak = 0, average = 0, density = 0 },
}

local disabledColor = BoostColor( Color.White, 0.333333 )

local t = Def.ActorFrame{
    -- this is the worst hack of All Time™
    -- InitCommand=function(self)
    --     SCREENMAN:AddNewScreenToTop("ScreenSelectMusic", "LoadedScreen" )
    --     SCREENMAN:GetTopScreen():visible(false)
    -- end,
    StateChangedMessageCommand=function(self,context)
        if SelectMusic.state == 1 then SetDefaultSteps(context) end
    end
}

function SetDefaultSteps(context)
    local starting_index = -1
    local found_steps = false

    if context.sort == SortMode.Level then
        for i, st in ipairs(SelectMusic.steps) do
            if tonumber(context.folder) == st:GetMeter() and not found_steps then
                starting_index = i
                found_steps = true
            end
        end
    end

    for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
        local index = starting_index > -1 and starting_index or clamp( SelectMusic.stepsIndex[pn], 1, #SelectMusic.steps)
        SelectMusic.stepsIndex[pn] = index
        SelectMusic.playerSteps[pn] = SelectMusic.steps[index]
        CalculateNPS(pn)
        MESSAGEMAN:Broadcast("StepsChanged", { Player = pn })
    end
end


function StepsInputController(context)

    if context.Menu == "Back" or context.Menu == "Return" then 
        if SelectMusic.confirm[context.Player] > 0 then
            SelectMusic.confirm[context.Player] = 0
            MESSAGEMAN:Broadcast("Confirm", context )
            return
        else
            SelectMusic.state = 0
            for i,pn in ipairs(GAMESTATE:GetHumanPlayers()) do
                SelectMusic.confirm[pn] = 0
            end
            MESSAGEMAN:Broadcast("StateChanged")
            return
        end
    end

    if context.Direction == "Up" or context.Direction == "Left" then
        local index = SelectMusic.stepsIndex[context.Player] - 1
        if index < 1 then
            index = #SelectMusic.steps
        end
        SelectMusic.stepsIndex[context.Player] = index
        SelectMusic.playerSteps[context.Player] = SelectMusic.steps[index]
        SelectMusic.confirm[context.Player] = 0
        CalculateNPS(context.Player)
        MESSAGEMAN:Broadcast("StepsChanged", context )
    end
    
    if context.Direction == "Down" or context.Direction == "Right"  then
        local index = SelectMusic.stepsIndex[context.Player] + 1
        if index > #SelectMusic.steps then
            index = 1
        end
        SelectMusic.stepsIndex[context.Player] = index
        SelectMusic.playerSteps[context.Player] = SelectMusic.steps[index]
        SelectMusic.confirm[context.Player] = 0
        CalculateNPS(context.Player)
        MESSAGEMAN:Broadcast("StepsChanged", context )
    end

    if context.Menu == "Start" then

        if SelectMusic.confirm[context.Player] < 1 then
            SelectMusic.confirm[context.Player] = 1
            SCREENMAN:PlayStartSound()
            MESSAGEMAN:Broadcast("Confirm", context)
            return
        end
        
        local _confirms = 0
        for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
            _confirms = _confirms + SelectMusic.confirm[pn]
            if _confirms == GAMESTATE:GetNumSidesJoined() then
                Confirm()
            end
        end

    end
end


function CalculateNPS(pn)
    if SelectMusic.playerSteps[pn] then
        nps[pn].peak, nps[pn].density = LoadModule("Chart.GetNPS.lua")( SelectMusic.playerSteps[pn] )
        
        if nps[pn].density and #nps[pn].density > 0 then
            local total = 0
            for i, v in ipairs( nps[pn].density ) do
                total = total + v
            end
            nps[pn].average = total / #nps[pn].density
        end
    end
end


for i, pn in ipairs({ PLAYER_1, PLAYER_2 }) do
-- for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
    
    local joined = GAMESTATE:IsSideJoined(pn)
    local sideColor = joined and PlayerColor(pn) or disabledColor

    -- steps panel
    local side = Def.ActorFrame{
        InitCommand=function(self)
            self:diffusealpha(0)
            self:y(SCREEN_CENTER_Y-15)
            self:x(SCREEN_CENTER_X + (416 * pnSide(pn) ))
        end,
        
        StateChangedMessageCommand=function(self)
            self:stoptweening()
            self:decelerate(0.25)
            if SelectMusic.state == 1 then
                self:x( SCREEN_CENTER_X + (400 * pnSide(pn) ))
                self:diffusealpha(0.95)
            else
                self:x(SCREEN_CENTER_X + (416 * pnSide(pn) ))
                self:diffusealpha(0)
            end
        end
    }

    side[#side+1] = Def.Sprite{
        Texture = "../graphics/steps_panel",
        InitCommand=function(self)
            self:align(0.5, 0.5)
            self:zoomx(0.65 * (pn == PLAYER_1 and 1 or -1))
            self:zoomy(0.66)
        end
    }

    -- author label
    side[#side+1] = Def.BitmapText{
        Font = Font.UINormal,
        Text = "Chart Author",
        InitCommand=function(self)
            self:align(pnAlign(pn),0)
            self:xy(125 * pnSide(pn), -218)
            self:zoom(0.4)
            self:shadowlength(1)
            self:diffuse( sideColor )
        end
    }

    -- author name
    side[#side+1] =Def.BitmapText{
        Font = Font.UINormal,
        Text = "Author Name",
        InitCommand=function(self)
            self:align(pnAlign(pn),0)
            self:xy(125 * pnSide(pn), -204)
            self:zoom(0.45)
            self:shadowlength(1)
            self:maxwidth(500)
        end,

        StepsChangedMessageCommand=function(self)
            if SelectMusic.playerSteps[pn] then
                local author = SelectMusic.playerSteps[pn]:GetAuthorCredit()
                if joined and ValidMetadata(author) then
                    self:settext( author )
                    self:diffusealpha( 1 )
                    return
                end
            end

            self:settext( "Unknown Author" )
            self:diffusealpha( 0.15 )
        end
    }

    -- chart name + description
    side[#side+1] = Def.BitmapText{
        Font = Font.UINormal,
        Text = "No Description",
        InitCommand=function(self)
            self:align(pnAlign(pn),0)
            self:xy(125 * pnSide(pn), -164)
            self:zoom(0.425)
            self:shadowlength(1)
            self:maxwidth(580)
            self:wrapwidthpixels(580)
            self:maxheight(85)
        end,

        StepsChangedMessageCommand=function(self)
            if SelectMusic.playerSteps[pn] then
                local name = SelectMusic.playerSteps[pn]:GetChartName()
                local desc = SelectMusic.playerSteps[pn]:GetDescription()
                local label = name or ""

                if desc and desc ~= "" and name ~= desc then
                    if #label > 0 then label = label.."\n" end
                    label = label..desc
                end

                if ValidMetadata(label) then
                    self:settext( label )
                    self:diffusealpha( 1 )
                    return
                end
            end

            self:settext( "No Description" )
            self:diffusealpha( 0.15 )
        end
    }

    -- peak label
    side[#side+1] = Def.BitmapText{
        Font = Font.UINormal,
        Text = "Peak Notes/sec.",
        InitCommand=function(self)
            self:align(0,0)
            self:xy(-115 + (12 * pnSide(pn)), -12)
            self:zoom(0.425)
            self:shadowlength(1)
            self:diffuse( sideColor )
        end,
    }

    -- average label
    side[#side+1] = Def.BitmapText{
        Font = Font.UINormal,
        Text = "Average Notes/sec.",
        InitCommand=function(self)
            self:align(0,0)
            self:xy(-115 + (12 * pnSide(pn)), 4)
            self:zoom(0.425)
            self:shadowlength(1)
            self:diffuse( sideColor )
        end,
    }


    -- peak value
    side[#side+1] = Def.BitmapText{
        Font = Font.UINormal,
        Text = "0.00",
        InitCommand=function(self)
            self:align(1,0)
            self:xy(115 + (12 * pnSide(pn)), -12)
            self:zoom(0.425)
            self:shadowlength(1)
        end,

        StepsChangedMessageCommand=function(self)
            self:settext( string.format( "%.2f", nps[pn].peak ))
            self:diffuse( joined and Color.White or disabledColor )
        end
    }

    -- average value
    side[#side+1] = Def.BitmapText{
        Font = Font.UINormal,
        Text = "0.00",
        InitCommand=function(self)
            self:align(1,0)
            self:xy(115 + (12 * pnSide(pn)), 4)
            self:zoom(0.425)
            self:shadowlength(1)
        end,

        StepsChangedMessageCommand=function(self)
            self:settext( string.format( "%.2f", nps[pn].average ))
            self:diffuse( joined and Color.White or disabledColor )
        end
    }

    
    -- nps graph
    side[#side+1] = LoadActor("graph", 232, 80, false, pn)..{
        InitCommand=function(self)
            self:xy(pnSide(pn) * 12, 80)
        end,
        StepsChangedMessageCommand=function(self)
            self:queuecommand("RefreshGraph")
        end,
    }


    -- radar
    for r = 1, #radar do
        side[#side+1] = Def.ActorFrame{
            InitCommand=function(self)
                local offset = -85
                local hspacing = math.floor((r-1) % 3) * math.abs(offset)
                local adjust = 12 * pnSide(pn)
                self:x(6 + hspacing + offset + adjust)

                local vspacing = math.floor((r-1) / 3) * 48
                self:y(vspacing - 96)
            end,

            Def.Sprite{
                Texture = THEME:GetPathG("", "radar"),
                InitCommand=function(self)
                    self:animate(0)
                    self:setstate(r-1)
                    self:zoomto(40,40)
                    self:xy(-26,-6)
                    self:diffuse( BoostColor( sideColor, 0.75) )
                    self:diffusealpha( 0.25 )
                end,
            },

            Def.BitmapText{
                Font = Font.UINormal,
                Text = "Item",
                InitCommand=function(self)
                    self:zoom(0.4)
                    self:y(-16)
                    self:diffuse( sideColor )
                end,

                StepsChangedMessageCommand=function(self)
                    local val = radar[r]
                    val = string.gsub(val, "RadarCategory_", "")
                    val = string.gsub(val, "AndHolds", "")

                    self:settext( val )
                end,
            },

            Def.RollingNumbers{
                Font = Font.UIHeavy,
                Text = "0000",
                InitCommand=function(self)
                    self:zoom(0.6)
                    self:strokecolor( BoostColor( sideColor, 0.5 ))
                    self:shadowcolor( BoostColor( sideColor, 0.15 ))
                    self:shadowlength(1.5)
                    self:Load("RollingNumbersRadar")
                end,

                StepsChangedMessageCommand=function(self)
                    if joined and SelectMusic.playerSteps[pn] then
                        self:diffuse( Color.White )
                        self:targetnumber("0")
                        local rv = SelectMusic.playerSteps[pn]:GetRadarValues(pn)
                        local val = rv:GetValue(radar[r])
                        self:targetnumber( joined and string.cap(tostring(val), "0", 4) or 0 )
                    else
                        self:targetnumber( 0 )
                    end
                end,
            }
        }

        side[#side+1] = LoadActor("highscores")..{
            InitCommand=function(self)
                self:xy(12 * pnSide(pn), 140)
            end,
            StepsChangedMessageCommand=function(self, context)
                if context and context.Player == pn then
                    self:playcommand("RefreshScore", { Player = pn })
                end
            end
        }
    end


    -- selector
    local sel = Def.ActorFrame{
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X + (130 * pnSide(pn)), SCREEN_CENTER_Y + 140 + 16)
            self:diffusealpha(0)
        end,

        StateChangedMessageCommand=function(self)
            self:finishtweening()
            self:decelerate(0.15)
            if SelectMusic.state == 1 then
                self:y(SCREEN_CENTER_Y + 140)
                self:diffusealpha(1)
            else
                self:y(SCREEN_CENTER_Y + 140 + 16)
                self:diffusealpha(0)
            end
        end,
    }


    sel[#sel+1] = Def.Sprite{
        Texture = "../graphics/steps_selector",
        InitCommand=function(self)
            self:zoomx(0.65)
            self:zoomy(0.65)
            self:diffuse(sideColor)
        end,
    }
    
    -- minilabel
    sel[#sel+1] = Def.BitmapText{
        Text = "PLAYER "..i,
        Font = Font.UINormal,
        InitCommand=function(self)
            self:zoom(0.333333)
            self:halign(pnAlign(pn))
            self:y(-67)
            self:x(114 * pnSide(pn))
            self:shadowlength(1)
            self:diffuse( BoostColor( Color.White, 0.333333 ))
        end,
    }

    -- ready
    sel[#sel+1] = Def.BitmapText{
        Text = "READY!",
        Font = Font.UIHeavy,
        InitCommand=function(self)
            self:zoom(0.35)
            self:halign(pnAlign(OtherPlayer[pn]))
            self:y(-67)
            self:x(114 * -pnSide(pn))
            self:shadowlength(1)
            self:diffuse( 1,0.8,0.4,1 )
        end,
        StateChangedMessageCommand=function(self) self:visible(false) end,
        StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        ConfirmMessageCommand=function(self) self:playcommand("Refresh") end,
        RefreshMessageCommand=function(self)
            self:finishtweening()
            self:visible( SelectMusic.confirm[pn] > 0)
            self:diffuse( Color.White )
            self:linear(0.333333)
            self:diffuse( 1, 0.8, 0.4, 1 )
        end,
    }

    -- stepstype
    sel[#sel+1] = Def.BitmapText{
        Text = "STEPSTYPE",
        Font = Font.UINormal,
        InitCommand=function(self)
            self:zoom(0.45)
            self:y(-36)
            self:shadowlength(1.25)
        end,

        SongChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        StateChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,

        RefreshCommand=function(self)
            if joined and SelectMusic.playerSteps[pn] then
                self:settext( ShortType( SelectMusic.playerSteps[pn]):upper() )
                self:diffuse( StepsColor( SelectMusic.playerSteps[pn] ))
                self:diffusetopedge( Color.White )
            else
                self:settext( "NONE" )
                self:diffuse( disabledColor )
            end
        end,
    }
    
    -- tag (unused?)
    sel[#sel+1] = Def.BitmapText{
        Text = "TAG",
        Font = Font.UINormal,
        InitCommand=function(self)
            self:zoom(0.375)
            self:y(16)
            self:visible(false)
            self:shadowlength(1)
        end,
    }
    
    sel[#sel+1] = Def.BitmapText{
        Text = "00",
        Font = Font.LargeNumbers,
        InitCommand=function(self)
            self:zoom(0.666666)
            self:y(-8)
            self:shadowlength(1)
        end,

        SongChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        StateChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,

        RefreshCommand=function(self,context)
            if joined and SelectMusic.playerSteps[pn] then
                self:settext( string.cap( SelectMusic.playerSteps[pn]:GetMeter(), "0", 2))
                self:diffuse( StepsColor( SelectMusic.playerSteps[pn] ))
                self:strokecolor( BoostColor( StepsColor( SelectMusic.playerSteps[pn] ), 0.35 ))
                self:diffusetopedge( Color.White )
            else
                self:settext( "00" )
                self:strokecolor( BoostColor( disabledColor, 0.25 ) )
                self:diffuse( Color.White )
                self:diffusealpha( 0.333333 )
            end
        end,
    }
    
    for arrow = -1, 1, 2 do
        sel[#sel+1] = Def.Sprite{
            Texture = THEME:GetPathG("", "selection_arrows"),
            InitCommand=function(self)
                self:zoomx(0.666666 * arrow)
                self:zoomy(0.666666)
                self:y(-9)
                self:x(48 * arrow)
                self:halign(0)
                self:animate(0)
                self:setstate(GAMESTATE:IsSideJoined(pn) and 2 or 0)
            end,
        }

        sel[#sel+1] = Def.Sprite{
            Texture = THEME:GetPathG("", "selection_arrows"),
            InitCommand=function(self)
                self:zoomx(0.666666 * arrow)
                self:zoomy(0.666666)
                self:y(-9)
                self:x(48 * arrow)
                self:halign(0)
                self:animate(0)
                self:diffusealpha(0)
                self:setstate(GAMESTATE:IsSideJoined(pn) and 1 or 0)
                self:blend("BlendMode_Add")
            end,

            StepsChangedMessageCommand=function(self, context)
                if context and context.Direction and context.Player and context.Player == pn then
                    if DirectionIndex(context.Direction) == arrow then
                        self:finishtweening()
                        self:diffusealpha(1)
                        self:decelerate(0.25)
                        self:diffusealpha(0)
                    end
                end
            end
        }
    end
    
    for selection = 3, 1, -1 do 
        sel[#sel+1] = Def.Sprite{
            Texture = "../graphics/steps_selection",
            InitCommand=function(self)
                self:zoom(0.66666666)
                self:y(50)
                self:animate(0)
                self:setstate(selection-1)
                self:diffuse( AccentColor("Blue", selection + 1) )
                self:blend(selection > 1 and "BlendMode_Add" or "BlendMode_Normal")
                self:visible( joined )
            end,
        }
    end
    
    local coords = {}
    local numItems = 4
    
    for scroller = -numItems, numItems do
        coords[scroller] = (scroller * 32) + (8 * clamp(scroller,-1,1))
    
        sel[#sel+1] = Def.BitmapText{
            Text = "00",
            Font = Font.UIHeavy,
            InitCommand=function(self)
                local abs = math.abs(scroller)
                local sign = clamp(scroller, -1, 1)
    
                self:zoomx(0.575):zoomy(0.575)
                self:x( abs == numItems and coords[scroller-sign] or coords[scroller] )
                self:y(51)
                self:rotationy( abs == numItems and 90 or 0 )
            end,
    
            SongChosenMessageCommand=function(self) self:playcommand("Refresh") end,
            StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,
            StateChangedMessageCommand=function(self) self:playcommand("Refresh") end,
    
            RefreshCommand=function(self)
                local index = scroller + SelectMusic.stepsIndex[pn]
                local steps = SelectMusic.steps[index]
                if joined and steps then 
                    self:visible(true)
                    self:settext( string.cap( steps:GetMeter(), "0", 2 ))
                    self:diffuse( StepsColor( steps ))
                    self:strokecolor( BoostColor( StepsColor( steps ), 0.35 ))
                    self:diffusetopedge( Color.White )
                else
                    self:visible(false) 
                end
            end,
        }
    
    end
    
    -- mask
    sel[#sel+1] =  Def.Quad{
        InitCommand=function(self)
            self:diffuse( Color.Black )
            self:halign(1)
            self:faderight(0.9)
            self:zoomto(56, 24)
            self:xy(-68, 52)
        end,
    }
    
    sel[#sel+1] =  Def.Quad{
        InitCommand=function(self)
            self:diffuse( Color.Black )
            self:halign(0)
            self:fadeleft(0.9)
            self:zoomto(56, 24)
            self:xy(68, 52)
        end,
    }


    t[#t+1] = side
    t[#t+1] = sel

end


return t