local t = Def.ActorFrame{
    GridSelectedMessageCommand=function(self)
        self:stoptweening()
        SOUND:StopMusic()
        self:sleep(0.4)
        self:queuecommand("PlayMusic")
    end,

    PlayMusicCommand=function(self)
        local song = GAMESTATE:GetCurrentSong()
        if song then
            SOUND:PlayMusicPart( song:GetMusicPath(), song:GetSampleStart(), song:GetSampleLength(), 0, 1, false, false, false )
        end
    end
}

return t