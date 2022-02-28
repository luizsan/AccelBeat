local t = Def.ActorFrame{}

local PreviewSize = { x = 512, y = 320 }

-- local aft = Def.ActorFrameTexture{
--     InitCommand=function(self)
--         self:setsize(PreviewSize.x, PreviewSize.y)
--         self:SetTextureName("notefield_preview")
--         self:EnableAlphaBuffer(true)
--         self:EnablePreserveTexture(false)
--         self:Create()
--     end
-- }


-- local dist_before  = THEME:GetMetric("Player","DrawDistanceBeforeTargetsPixels")
-- local dist_after = THEME:GetMetric("Player","DrawDistanceAfterTargetsPixels")
-- local normal_y = THEME:GetMetric("Player","ReceptorArrowsYStandard")
-- local reverse_y = THEME:GetMetric("Player","ReceptorArrowsYReverse")
-- local y_offset = reverse_y - normal_y

-- local function InitializeField()
--     local song = SelectMusic.song or FilterSongs(SONGMAN:GetAllSongs())[1]
--     GAMESTATE:SetCurrentSong(song)

--     for i,pn in ipairs(GAMESTATE:GetHumanPlayers()) do
--         GAMESTATE:SetCurrentSteps( pn, FilterSteps(song)[1] )
--     end
-- end

-- InitializeField()

-- for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
    
--     local options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current')

--     aft[#aft+1] = Def.NoteField {
--         Name = "NotefieldPreview",
--         FOV = 60,
--         Player = pn,
--         NoteSkin = options:NoteSkin(),
--         DrawDistanceAfterTargetsPixels = dist_after,
--         DrawDistanceBeforeTargetsPixels = dist_before,
--         YReverseOffsetPixels = y_offset,
--         FieldID = i,

--         InitCommand=function(self)
--             self:zoom(0.75)
--             self:xy((PreviewSize.x * 0.5) + (128 * pnSide(pn)), SCREEN_CENTER_Y - 180)
--             self:SetBeatBars(true)
--             --self:SetNoteDataFromLua({})
--         end,

--         SongChangedMessageCommand=function(self) self:playcommand("Refresh") end,
--         StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,
--         RefreshCommand=function(self)
            
--             local str = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString('ModsLevel_Current')

--             --self:NoteSkin( SelectMusic.playerOptions[pn].NoteSkin )

--             -- self:AutoPlay(true)
--             self:SetNoteDataFromLua({})
--             --self:visible(false)

--             if not SelectMusic.song then return end

--             local index = 1
--             for n, c in ipairs(SelectMusic.song:GetAllSteps()) do
--                 if c == GAMESTATE:GetCurrentSteps(pn) then
--                     index = n
--                 end
--             end

--             local notedata = SelectMusic.song:GetNoteData(index)
--             if not notedata then return end
            

--             self:SetNoteDataFromLua(notedata)
--             self:ModsFromString(str)
--             self:visible(true)
--         end
--     }

-- end


-- t[#t+1] = aft

t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y - 85)
        self:visible(false)
    end,

    StateChangedMessageCommand=function(self)
        self:visible(SelectMusic.state == 1)
    end,

    Def.Sprite{
        Texture = THEME:GetPathG("", "patterns/noise"),
        InitCommand=function(self)
            self:zoomto(PreviewSize.x, PreviewSize.y)
            local ratio = PreviewSize.x / PreviewSize.y
            self:diffuse(0.5,0.5,0.5,0.5)
            self:customtexturerect(0,0, 1 * ratio, 1)
            self:texcoordvelocity(80,120)
            self:fadebottom(0.25)
        end
    },

    Def.BitmapText{
        Text = "Chart Preview",
        Font = Font.UINormal,
        InitCommand=function(self)
            self:zoom(0.5)
        end
    },

    -- Def.Sprite{
    --     Texture = "notefield_preview",
    --     InitCommand=function(self)
    --     end,
    -- }
}



return t
