local c = { 0.125490, 0.188235, 0.250980, 0.8 }

return Def.ActorFrame{
    Def.Quad{
        InitCommand=function(self)
            self:align(0.5, 0)
            self:zoomto(SCREEN_WIDTH, 420)
            self:xy(SCREEN_CENTER_X, SCREEN_TOP)
            self:diffuse(c)
            self:fadebottom(1)
        end
    },
    
    Def.Quad{
        InitCommand=function(self)
            self:align(0.5, 1)
            self:zoomto(SCREEN_WIDTH, 260)
            self:xy(SCREEN_CENTER_X, SCREEN_BOTTOM)
            self:diffuse(c)
            self:fadetop(1)
        end
    }
}