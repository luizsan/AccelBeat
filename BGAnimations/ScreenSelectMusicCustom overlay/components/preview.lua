local t = Def.ActorFrame{}

local PreviewSize = { x = 512, y = 320 }

-- remember the last selected steps and number 
-- of columns so we only update stuff when needed
local cachedSteps = {}

local aft = Def.ActorFrameTexture{
    InitCommand=function(self)
        self:setsize(PreviewSize.x, PreviewSize.y)
        self:SetTextureName("notefield_preview")
        self:EnableAlphaBuffer(true)
        self:EnablePreserveTexture(false)
        self:Create()
    end
}


local dist_before  = THEME:GetMetric("Player","DrawDistanceBeforeTargetsPixels")
local dist_after = THEME:GetMetric("Player","DrawDistanceAfterTargetsPixels")
local normal_y = THEME:GetMetric("Player","ReceptorArrowsYStandard")
local reverse_y = THEME:GetMetric("Player","ReceptorArrowsYReverse")
local y_offset = reverse_y - normal_y


for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
    
    cachedSteps[pn] = nil
    local options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Current')

    aft[#aft+1] = Def.NoteField {
        Name = "NotefieldPreview",
        FOV = 60,
        Player = pn,
        NoteSkin = "default",
        DrawDistanceAfterTargetsPixels = dist_after,
        DrawDistanceBeforeTargetsPixels = dist_before,
        YReverseOffsetPixels = y_offset,
        FieldID = i,

        InitCommand=function(self)
            self:zoom(0.7)
            self:x( (PreviewSize.x * 0.5) + (128 * pnSide(pn)) )
            self:y( SCREEN_CENTER_Y - 192 )
            self:AutoPlay(false)
            self:SetBeatBars(false)
        end,

        SongChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        StepsChangedMessageCommand=function(self) self:playcommand("Refresh") end,
        ChangePropertyMessageCommand=function(self) self:playcommand("Refresh") end,


        RefreshCommand=function(self)
            self:visible(false)

            if SelectMusic.state ~= 1 then return end

            -- setup
            local st = SelectMusic.playerSteps[pn]
            GAMESTATE:SetCurrentSong( SelectMusic.song )
            GAMESTATE:SetCurrentSteps( pn, st )
            
            local style = GAMESTATE:GetNumSidesJoined() > 1 and "versus" or string.lower(ShortType(st))
            GAMESTATE:SetCurrentStyle( style )

            if st == nil then return end

            local speed = SelectMusic.playerOptions[pn].SpeedMod * 0.9
            self:ModsFromString("c"..speed..",overhead" )


            -- ensure the notefield has the correct amount of columns
            -- when changing between StepsTypes
            if not cachedSteps[pn] or cachedSteps[pn]:GetStepsType() ~= st:GetStepsType() then
                self:ChangeReload( st )
                cachedSteps[pn] = st
            end

            -- center when double
            self:x((PreviewSize.x * 0.5) + (128 * pnSide( style == "double" and 0 or pn )))
            self:SetNoteDataFromLua({})
            
            -- fail checks
            local index = table.index( SelectMusic.song:GetAllSteps(), SelectMusic.playerSteps[pn] )
            if index < 0 then return end
            local notedata = SelectMusic.song:GetNoteData(index)
            if not notedata then return end
    
            self:SetNoteDataFromLua(notedata)
            self:visible(true)
        end
    }

end


t[#t+1] = aft



t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y - 92)
        self:visible(false)
    end,

    StateChangedMessageCommand=function(self)
        self:visible(SelectMusic.state == 1)
    end,

    -- Def.Sprite{
    --     Texture = THEME:GetPathG("", "patterns/noise"),
    --     InitCommand=function(self)
    --         self:zoomto(PreviewSize.x, PreviewSize.y)
    --         local ratio = PreviewSize.x / PreviewSize.y
    --         self:diffuse(0.5,0.5,0.5,0.5)
    --         self:customtexturerect(0,0, 1 * ratio, 1)
    --         self:texcoordvelocity(80,120)
    --         self:fadebottom(0.25)
    --     end
    -- },

    -- Def.BitmapText{
    --     Text = "Chart Preview",
    --     Font = Font.UINormal,
    --     InitCommand=function(self)
    --         self:zoom(0.5)
    --     end
    -- },

    Def.Sprite{
        Texture = "notefield_preview",
        InitCommand=function(self)
            self:fadebottom(0.125)
        end,
    }
}



return t
