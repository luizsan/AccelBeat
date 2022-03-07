local function Update(self, dt)
    MESSAGEMAN:Broadcast("UpdateGameplay")
end

local t = Def.ActorFrame{
    InitCommand=function(self)
        self:SetUpdateFunction(Update)
    end,
}

t[#t+1] = LoadActor("components/progress")

return t