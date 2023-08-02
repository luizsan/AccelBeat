return Def.ActorFrame{
    InitCommand=function(self)
        self:zoomto(1,1)
        self:Center()
    end,

        Def.AudioVisualizer{
            Amount = 24, -- The amount of colums, its from min of 16 to a max of 128.
            LinearPeaks = true, -- define if we want lenear peaks, as in a slow animation when it goes back to 0.
            PeakHeight = 256, -- the hight of the columns,
            UpdateRate = 0.01, -- the update rate of the columns, the lower the faster, between 10 and 0.01.
            InitCommand=function(self)
                self:diffusetopedge(1,0,0,0.75)
            end,

            OnCommand=function(self)
                -- self:SetSound( --[[ A RageSound to set--]] )
                -- if SetSound is not set, it will fallback to the cur playing music, this does not work for screen gameplay, in screengameplay do
                -- self:SetSound(SCREENMAN:GetTopScreen():GetSound())
            end    
        }
}