
local fieldWidth = 420
local fieldPadding = 20

local answer = nil
local screen = nil
local input = nil
local children = {}
local cursor_pos = 0

function Update(self, dt)
    MESSAGEMAN:Broadcast("UpdateTextEntry")
end

local function AnswerInit(self)
    self:diffuse( BoostColor( Color.White, 0.333333 ))
    self:MaskDest()
    self:halign(0)
    self:y(SCREEN_CENTER_Y-4)
end

local function AnswerUpdate(self)
    local w = self:GetZoomedWidth()

    self:zoom(0.65)
    self:MaskDest()
    if w > fieldWidth then
        self:halign(1)
        self:xy(SCREEN_CENTER_X + (fieldWidth * 0.5), SCREEN_CENTER_Y-2)
    else
        self:halign(0)
        self:xy(SCREEN_CENTER_X - (fieldWidth * 0.5), SCREEN_CENTER_Y-2)
    end
end

local t = Def.ActorFrame{
    OnCommand=function(self)
        screen = SCREENMAN:GetTopScreen()
        children = screen:GetChildren()
        self:SetUpdateFunction(Update)

        children["Question"]:visible(false)
        answer = children["Answer"]
        AnswerInit(answer)
    end,

    UpdateTextEntryMessageCommand=function(self)
        self:playcommand("Refresh")
    end,

    RefreshCommand=function(self)
        if answer then AnswerUpdate(answer) end
    end
}

t[#t+1] = Def.Quad{
    InitCommand=function(self)
        self:diffuse(0.1,0.1,0.1,0.75) 
        self:FullScreen()
    end,
}

-- text field
local f = Def.ActorFrame{
    InitCommand=function(self)
        input = self:GetChild("Input")
    end,
}

    -- base
f[#f+1] = Def.Quad{
    InitCommand=function(self)
        self:diffuse( Color.White ) 
        self:zoomto( fieldWidth + fieldPadding, 36 )
        self:Center()
    end
}

-- mask
f[#f+1] = Def.Quad{
    InitCommand=function(self)
        self:halign(0)
        self:xy( SCREEN_LEFT, SCREEN_CENTER_Y)
        self:zoomto( (SCREEN_WIDTH * 0.5) - (fieldWidth * 0.5) , 36 )
        self:MaskSource(false)
    end
}

-- label
f[#f+1] = Def.BitmapText{
    Font = Font.UINormal,
    Text = "Type here to search for a song",
    InitCommand=function(self)
        self:Center()
        self:zoom(0.5)
        self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y - 40)
    end
} 

-- dummy field for cursor
f[#f+1] = Def.BitmapText{
    Font = Font.UINormal,
    Text = "Test",
    Name = "Input",
    InitCommand=function(self)
        self:MaskDest()
    end,

    UpdateTextEntryMessageCommand=function(self)
        self:visible(false)
        self:halign( answer and answer:GetHAlign() or 0 )
        self:zoom( answer and answer:GetZoom() or 1 )
        self:xy( answer and answer:GetX() or 0, answer and answer:GetY() or 0 )
        self:diffuse( Color.Red )

        local text = answer:GetText()
        local cursor = string.find( text, "|" )
        self:settext( string.sub(text, 1, cursor ))
        cursor_pos = self:GetZoomedWidth()
    end
}   


f[#f+1] = Def.ActorFrame{
    Def.Quad{
        InitCommand=function(self)
            self:zoomto( 4, 24 )
            self:Center()
            self:MaskSource(false)
        end,
        UpdateTextEntryMessageCommand=function(self)
            local r = answer:GetHAlign() == 0 and answer:GetX() + cursor_pos or answer:GetX()
            self:xy( r - 2.5, answer:GetY() + 2)
        end
    },

    Def.Quad{
        InitCommand=function(self)
            self:diffuseblink()
            self:effectcolor1( Color.Black )
            self:effectcolor2( Color.White )
            self:effectperiod(0.2)
            self:zoomto( 4, 24 )
            self:Center()
        end,

        UpdateTextEntryMessageCommand=function(self)
            local r = answer:GetHAlign() == 0 and answer:GetX() + cursor_pos or answer:GetX() - answer:GetZoomedWidth() + cursor_pos
            self:xy( r - 2.5, answer:GetY() + 2)
        end
    },

}

t[#t+1] = f


return t