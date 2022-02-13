
local def_ds  = THEME:GetMetric("Player","DrawDistanceBeforeTargetsPixels")
local def_dsb = THEME:GetMetric("Player","DrawDistanceAfterTargetsPixels")
local receptposnorm = THEME:GetMetric("Player","ReceptorArrowsYStandard")
local receptposreve = THEME:GetMetric("Player","ReceptorArrowsYReverse")
local yoffset = receptposreve-receptposnorm
local notefieldmid = (receptposnorm + receptposreve)/2

local options = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions('ModsLevel_Current')

return Def.NoteField {
    Name = "NotefieldPreview",
    FOV = 60,
    Player = PLAYER_1,
    NoteSkin = "delta-note",
    DrawDistanceAfterTargetsPixels = def_dsb,
    DrawDistanceBeforeTargetsPixels = def_ds,
    YReverseOffsetPixels = yoffset,
    FieldID = 3,
    InitCommand=function(self)
        self:y(notefieldmid)
    end,

    -- StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,
    -- StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,
    -- RefreshCommand=function(self)
    --     SCREENMAN:SystemMessage("Steps changed")
    --     self:SetNoteDataFromLua({})
    --     self:visible(false)
    --     local song = GAMESTATE:GetCurrentSong()
    --     if not song then return end -- If there's no song, do nothing
    --     if not SelectMusic.playerSteps[pn] then return end -- If there's no chart, do nothing
    --     local nd = song:GetNoteData(SelectMusic.playerSteps[pn])
    --     if not nd then return end -- If there's no notedata, you guessed it, do nothing
    --     self:SetNoteDataFromLua(nd)
    --     self:visible(true)
    -- end
}