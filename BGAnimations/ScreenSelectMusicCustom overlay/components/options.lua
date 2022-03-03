local List = {
    width = 250,
    spacing = 30,
    maxItems = 9,
}

List.middle = math.ceil( List.maxItems * 0.5 )

local playerData = {}
function ResetOptionsListState()
    for i, pn in ipairs({ PLAYER_1, PLAYER_2 }) do
        playerData[pn] = {}

        -- currently available options
        -- nil or empty table indicates that the options list is closed
        playerData[pn].stack = {}

        -- selected option index on latest stack
        playerData[pn].index = 1

        -- topmost item in stack list
        playerData[pn].current = nil
        playerData[pn].option = nil
        playerData[pn].field = nil
        playerData[pn].path = {}
    end
end

ResetOptionsListState()

function OptionsListOpened(pn)
    return playerData and playerData[pn] and playerData[pn].stack and #playerData[pn].stack > 0 or false
end


function OptionsToggle(context)
    if string.startswith( context.Menu, "Options" ) then
        if not OptionsListOpened(context.Player) then
            OpenOptionsList(context)
        end
    end

    if context.Menu == "Select" then
        if OptionsListOpened(context.Player) then
            CloseOptionsList(context)
        else
            OpenOptionsList(context)
        end
    end
end


local function CurrentOptionsStack(pn)
    if OptionsListOpened(pn) and #playerData[pn].stack > 0 then
        local index = #playerData[pn].stack
        return playerData[pn].stack[index]
    end
    return nil
end


local function CurrentSelectedOption(pn)
    local stack = CurrentOptionsStack(pn)
    if stack then
        local index = playerData[pn].index
        return stack[index]
    end
    return nil
end


function OpenOptionsList(context)
    playerData[context.Player].stack = { OptionsList }
    playerData[context.Player].index = 1
    RefreshElements(context)
    MESSAGEMAN:Broadcast("OptionsList", context)
end


function CloseOptionsList(context)
    playerData[context.Player].stack = {}
    playerData[context.Player].field = nil
    RefreshElements(context)
    MESSAGEMAN:Broadcast("OptionsList", context)
end


function OptionsInputController(context)
    if not OptionsListOpened(context.Player) then return end

    if context.Menu == "Back" or context.Menu == "Return" then
        BackOptionsList(context)
    else
        local current_stack = CurrentOptionsStack(context.Player)
        if not current_stack then return end

        if context.Direction == "Left" or context.Direction == "Up" then
            if playerData[context.Player].field then
                ChangeProperty(context)
            else
                local index = loop( playerData[context.Player].index - 1, 1, #current_stack + 1)
                playerData[context.Player].index = index
                context.direction = -1
                MoveOptionsList(context)
            end
        end
        
        if context.Direction == "Right" or context.Direction == "Down" then
            if playerData[context.Player].field then
                ChangeProperty(context)
            else
                local index = loop( playerData[context.Player].index + 1, 1, #current_stack + 1)
                playerData[context.Player].index = index
                context.direction = 1
                MoveOptionsList(context)
            end
        end

        if context.Menu == "Start" then
            if playerData[context.Player].field then
                BackOptionsList(context)
            else
                ChooseOption(context)
            end
        end
    end
end


function RefreshElements(context)
    local index = playerData[context.Player].index
    playerData[context.Player].current = CurrentOptionsStack(context.Player)
    playerData[context.Player].option = stack and stack[index] or nil
end


function BackOptionsList(context)
    if playerData[context.Player].field then
        PathBackward(context.Player)
        table.remove( playerData[context.Player].stack )
        playerData[context.Player].field = nil
        
    elseif #playerData[context.Player].stack > 0 then
        context.menu = true
        PathBackward(context.Player)
        table.remove( playerData[context.Player].stack )
    else
        CloseOptionsList(context)
    end

    RefreshElements(context)
    MESSAGEMAN:Broadcast("OptionsList", context)
end


function PathForward(pn)
    table.insert( playerData[pn].path, playerData[pn].index )
    playerData[pn].index = 1
end

function PathBackward(pn)
    playerData[pn].index = playerData[pn].path[ #playerData[pn].path ]
    table.remove( playerData[pn].path )
end


function MoveOptionsList(context, direction)
    -- local current_option = CurrentSelectedOption(context.Player)
    -- if current_option and current_option.Disabled then
    --     OptionsInputController(context)
    --     return
    -- end
    RefreshElements(context)
    MESSAGEMAN:Broadcast("OptionsList", context)
end


function ChangeProperty(context)
    local field = playerData[context.Player].field

    if not field then return end
    local options = SelectMusic.playerOptions[context.Player]

    if field.Type == OptionsType.Value then
        if field.Choices and #field.Choices > 0 then
            local index = table.index( field.Choices, options[field.Name] ) or table.index( field.Choices, field.Default ) or 1
            if context.Direction == "Up" or context.Direction == "Left" then index = loop( index-1, 1, #field.Choices + 1) end
            if context.Direction == "Down" or context.Direction == "Right" then index = loop( index+1, 1, #field.Choices + 1) end
            SelectMusic.playerOptions[context.Player][field.Name] = field.Choices[index]

        elseif field.Range then 
            local step = field.Name == "SpeedMod" and options.Increment or field.Range.Step or 1
            local value = options[field.Name] or field.Default
            if context.Direction == "Up" or context.Direction == "Left" then value = clamp( value-step, field.Range.Min, field.Range.Max) end
            if context.Direction == "Down" or context.Direction == "Right" then value = clamp( value+step, field.Range.Min, field.Range.Max) end
            SelectMusic.playerOptions[context.Player][field.Name] = value
            
        end

        --WriteOptionsTable(context.Player)
        MESSAGEMAN:Broadcast("ChangeProperty", context)
        
    elseif field.Type == OptionsType.Toggle then
        local index = table.index( field.Choices, options[field.Name] ) or table.index( field.Choices, field.Default ) or 1
        index = loop( index+1, 1, #field.Choices + 1)
        SelectMusic.playerOptions[context.Player][field.Name] = field.Choices[index]
        
        --WriteOptionsTable(context.Player)
        MESSAGEMAN:Broadcast("ChangeProperty", context)
    end
end


function ChooseOption(context)
    local current_option = CurrentSelectedOption(context.Player)
    if current_option.Disabled then return end 


    if current_option.Type == OptionsType.Menu then
        context.menu = true
        
        PathForward(context.Player)
        table.insert( playerData[context.Player].stack, current_option.Choices )
        RefreshElements(context)
        MESSAGEMAN:Broadcast("OptionsList", context)
        
    elseif current_option.Type == OptionsType.Value then
        PathForward(context.Player)
        table.insert( playerData[context.Player].stack, {} )
        playerData[context.Player].field = current_option
        RefreshElements(context)
        MESSAGEMAN:Broadcast("OptionsList", context)

    elseif current_option.Type == OptionsType.Toggle then
        playerData[context.Player].field = current_option
        ChangeProperty(context)
        playerData[context.Player].field = nil
        RefreshElements(context)
        MESSAGEMAN:Broadcast("OptionsList", context)

    elseif current_option.Type == OptionsType.Action then
        current_option.Action(context)
        RefreshElements(context)
        MESSAGEMAN:Broadcast("OptionsList", context)

    elseif current_option.Type == OptionsType.Exit then
        BackOptionsList(context)
    end
end


local t = Def.ActorFrame{}

for index, pn in ipairs(GAMESTATE:GetHumanPlayers()) do

    -- side
    local s = Def.ActorFrame{
        OnCommand=function(self) 
            self:diffusealpha(0)
            self:playcommand("OptionsList") 
        end,

        OptionsListMessageCommand=function(self, context) 
            self:stoptweening()
            self:decelerate(0.125)
            self:x(OptionsListOpened(pn) and 0 or (16 * pnSide(pn)))
            self:diffusealpha( OptionsListOpened(pn) and 1 or 0 ) 
        end,
    }

    -- background
    s[#s+1] = Def.Quad{
        InitCommand=function(self)
            self:diffuse( BoostColor( PlayerColor(pn), 0.1 ))
            self:diffusealpha(0.9)
            self:xy( SCREEN_CENTER_X, SCREEN_CENTER_Y)
            self:halign(1)
            self:zoomto( SCREEN_WIDTH * 0.5 * pnSide( OtherPlayer[pn]), SCREEN_HEIGHT )
            self:cropright(0.2)
            self:faderight(0.5)
        end
    }

    -- s[#s+1] = Def.ActorFrame{
    --     Def.Sprite{
    --         Texture = THEME:GetPathG("", "selection_arrows"),
    --         InitCommand=function(self)
    --             self:zoom(0.5)
    --             self:animate(0)
    --             self:setstate(2)
    --             self:halign(0.25)

    --             local pos_x = SCREEN_CENTER_X + (430 * pnSide(pn)) + ( List.width * 0.5 + 8 )
    --             local pos_y = SCREEN_CENTER_Y + List.spacing - 4
    --             self:xy( pos_x, pos_y )
    --         end,
    --     },

    --     Def.Sprite{
    --         Texture = THEME:GetPathG("", "selection_arrows"),
    --         InitCommand=function(self)
    --             self:zoom(0.5)
    --             self:zoomx(-0.5)
    --             self:animate(0)
    --             self:setstate(2)
    --             self:halign(0.25)

    --             local pos_x = SCREEN_CENTER_X + (430 * pnSide(pn)) - ( List.width * 0.5 + 8 )
    --             local pos_y = SCREEN_CENTER_Y + List.spacing - 4
    --             self:xy( pos_x, pos_y )
    --         end,
    --     }
    -- }

    -- options
    for i = 1, List.maxItems do

        -- row
        local r = Def.ActorFrame{
            OptionsListMessageCommand=function(self, context)
                if context and context.Player ~= pn then return end

                local pos_x = SCREEN_CENTER_X + (430 * pnSide(pn))
                local pos_y = SCREEN_CENTER_Y + (List.maxItems * 0.5 - i) * -List.spacing + 10
                
                local target_alpha = 1
                
                --if OptionsListOpened(pn) then
                    self:stoptweening()
                --end

                if not playerData[pn].stack or #playerData[pn].stack < 1 then
                    target_alpha = 0
                    pos_x = pos_x + (20 * pnSide(pn))
                else
                    if context then
                        if context.direction then
                            self:addy( List.spacing * context.direction )

                            if i == 1 and context.direction < 0 then 
                                self:diffusealpha(0) 
                                self:zoomy(0) 
                            end

                            if i == List.maxItems and context.direction > 0 then 
                                self:diffusealpha(0) 
                                self:zoomy(0) 
                            end
                        end

                        if context.menu then
                            self:addx( 20 * pnSide(pn))
                            self:diffusealpha(0)
                        end
                    end
                end
                
                self:decelerate(0.125)
                self:diffusealpha(target_alpha)
                self:zoomy(1)
                self:xy(pos_x, pos_y)
            end,
        }

        -- background
        r[#r+1] = Def.ActorFrame{

            --flat
            Def.Quad{
                InitCommand=function(self)
                    self:zoomto( List.width + 3, List.spacing - 2)
                    self:diffuse( Color.Black )
                end,
            },

            --pattern
            Def.Sprite{
                Texture = THEME:GetPathG("", "patterns/diagonal"),
                InitCommand=function(self)
                    self:zoomto( List.width + 3, List.spacing - 2)
                    if List.middle == i then
                        self:customtexturerect( 0, 0, self:GetWidth() / 128 * 2, self:GetHeight() / 128 * 0.25)
                        self:texcoordvelocity( pnSide(pn) * 0.5, 0)
                        self:diffuse( BoostColor( PlayerColor(pn), 0.75 ))
                    end
                    self:visible( List.middle == i )
                    self:diffusealpha(0.15)
                end,
            },

            -- border
            Def.Sprite{
                Texture = "../graphics/options_slot",
                InitCommand=function(self)
                    self:zoomto( List.width + 20, List.spacing + 8)
                    self:animate(0)
                    self:setstate(0)
                    self:diffuse( List.middle == i and BoostColor( PlayerColor(pn), 1 ) or BoostColor( Color.White, 0.2 ))
                end,
            },

            -- selection
            Def.Sprite{
                Texture = "../graphics/options_slot",
                InitCommand=function(self)
                    self:zoomto( List.width + 20, List.spacing + 8)
                    self:animate(0)
                    self:setstate(1)
                    self:visible(List.middle == i)
                    self:diffuse( BoostColor( PlayerColor(pn), 0.5 ))
                    self:blend("BlendMode_Add")
                end,
            }
        }


        -- icon
        -- r[#r+1] = Def.Sprite{
        --     Texture = THEME:GetPathG("", "options_icons"),
        --     InitCommand=function(self)
        --         self:animate(0)
        --         self:x(8 * -pnSide(pn))
        --         self:zoom(0.75)
        --         self:halign( pnAlign(pn) )
        --         self:shadowlength(1)
        --     end,

        --     OptionsListMessageCommand=function(self, context)
        --         if not context then return end
        --         if not context.Player then return end
        --         if context.Player ~= pn then return end
                
        --         if not playerData[pn].stack or #playerData[pn].stack < 1 then return end
        --         local index = playerData[pn].index
        --         local target = loop( index - List.middle + i, 1, #playerData[pn].stack + 1)
        --         local option = playerData[pn].stack[target] or nil
                
        --         if option and option.Icon then
        --             self:visible(true)
        --             self:setstate( option.Icon )
        --             self:diffusealpha( List.middle == i and 1 or 0.2 )
        --         else
        --             self:visible(false)
        --         end
        --     end
        -- }
        
        -- label
        r[#r+1] = Def.BitmapText{
            Font = Font.UINormal,
            InitCommand=function(self)
                self:zoom(0.425)
                self:halign(0)
                self:xy( (List.width - 20) * -0.5, -3)
                self:shadowlength(0.75)
                self:shadowcolor(0,0,0,0.2)
            end,
            
            OptionsListMessageCommand=function(self, context)
                if not context then return end
                if not context.Player then return end
                if context.Player ~= pn then return end
                if not OptionsListOpened(pn) then return end

                if not playerData[pn].current or #playerData[pn].current < 1 then 
                    if List.middle == i then
                        self:playcommand("GainFocus")
                    else
                        self:playcommand( playerData[pn].field and "Disable" or "LoseFocus" )
                    end
                    return
                end

                local target = loop( playerData[pn].index - List.middle + i, 1, #playerData[pn].current + 1) 
                local option = playerData[pn].current[target] or nil
                
                self:settext(option and option.Name or "")
                
                if option and not option.Disabled then
                    self:diffuse( PlayerColor(pn) )
                    if List.middle == i then
                        self:playcommand("GainFocus")
                    else
                        if option.Type == OptionsType.Exit then
                            self:playcommand( "Exit" )
                        elseif option.Type == OptionsType.Action then
                            self:playcommand( "Action" )
                        else
                            self:playcommand( playerData[pn].field and "Disable" or "LoseFocus" )
                        end
                    end
                else
                    self:playcommand("Disable")
                end
            end,

            GainFocusCommand=function(self)
                self:diffuse( PlayerColor(pn) )
                self:diffuseshift()
                self:effectperiod(0.15)
                self:effectcolor1( Color.White )
                self:effectcolor2( BoostColor( PlayerColor(pn), 3.5 ))
            end,

            LoseFocusCommand=function(self)
                self:diffuse( BoostColor( PlayerColor(pn), 1 ))
                self:stopeffect()
            end,

            DisableCommand=function(self)
                self:diffuse( BoostColor( Color.White, 0.2 ))
                self:stopeffect()
            end,

            ActionCommand=function(self)
                self:diffuse(1, 0.9, 0.5, 1)
                self:stopeffect()
            end,

            ExitCommand=function(self)
                self:diffuse( 1, 0.4, 0.4, 1 )
                self:stopeffect()
            end,
        }

        -- value
        r[#r+1] = Def.BitmapText{
            Font = Font.UINormal,
            InitCommand=function(self)
                self:zoom(0.45)
                self:halign(1)
                self:xy( (List.width - 16) * 0.5, -2)
                self:shadowlength(0.75)
                self:settext( "..." )
            end,

            OptionsListMessageCommand=function(self, context) self:playcommand("Refresh", context) end,
            ChangePropertyMessageCommand=function(self, context) self:playcommand("Refresh", context) end,

            RefreshCommand=function(self,context)
                if not context then return end
                if not context.Player then return end
                if context.Player ~= pn then return end
                if not OptionsListOpened(pn) then return end
                

                local option = nil

                if playerData[pn].field then
                    option = List.middle == i and playerData[pn].field or nil

                elseif playerData[pn].current and #playerData[pn].current > 0 then 
                    local target = loop( playerData[pn].index - List.middle + i, 1, #playerData[pn].current + 1)
                    option = playerData[pn].current[target]
                end

                if option then
                    
                    self:diffusealpha(1)
                    self:visible(true)
                    if option.Type == OptionsType.Value and option.Default then
                        self:settext( SelectMusic.playerOptions[pn][option.Name] or option.Default )

                    elseif option.Type == OptionsType.Toggle and option.Default then
                        self:settext( (SelectMusic.playerOptions[pn][option.Name] or option.Default or 0) == 0 and "Off" or "On" )
                        
                    elseif option.Type == OptionsType.Menu and option.Choices then
                        self:settext( "▶")
                    else
                        self:visible(false)
                    end

                else
                    self:diffusealpha(0.1)
                end
                
            end,
        }

        s[#s+1] = r
    end

    t[#t+1] = s

    
end

return t