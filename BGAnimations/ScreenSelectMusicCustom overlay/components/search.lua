local t = Def.ActorFrame{
    OnCommand=function(self)
        self:SetUpdateFunction(UpdateTextField)
    end,

    SearchMessageCommand=function(self)
        SCREENMAN:AddNewScreenToTop("ScreenSearch")
        local ste = SCREENMAN:GetTopScreen()

        local settings = {
            Question = "Test text entry",
            MaxInputLength = 255,
            OnOK = function(answer)
                SearchGrid(answer)
            end,
        };

        ste:PostScreenMessage("On", 0)
        ste:Load(settings)
    end,
}

return t