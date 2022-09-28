local t = {
    "&DOWNLEFT;&DOWNRIGHT; Move Left/Right     &UPLEFT;&UPRIGHT; Move Up/Down     &DOWNLEFT;&DOWNRIGHT;&DOWNLEFT;&DOWNRIGHT;&DOWNLEFT;&DOWNRIGHT; Options     &UPLEFT; + &UPRIGHT; Back to Top     &CENTER; Select",
    "&DOWNLEFT;&DOWNRIGHT; Move Left/Right     &UPLEFT;&UPRIGHT; Cancel     &DOWNLEFT;&DOWNRIGHT;&DOWNLEFT;&DOWNRIGHT;&DOWNLEFT;&DOWNRIGHT; Options     &CENTER; Select",
}

local textSize = 0.4

return Def.ActorFrame{

    Def.BitmapText{
        Font = Font.UINormal,
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, SCREEN_TOP + 16):align(0.5, 0):zoom(textSize):diffuse( BoostColor( Color.White, 0.75 )):shadowlength(1.25)
        end,

        OnCommand=function(self) self:playcommand("Refresh") end,
        StateChangedMessageCommand=function(self) self:playcommand("Refresh") end,

        RefreshCommand=function(self)
            self:stoptweening()
            self:settext( t[SelectMusic.state+1] )
            self:zoomy(0)
            self:decelerate(0.2)
            self:zoomy(textSize)
        end,
    }

}