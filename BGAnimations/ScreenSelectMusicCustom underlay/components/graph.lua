-- Original NPS graph from Soundwaves by Team Rizu
-- copied from infinitesimal because it's already implemented...

local width, height, gameplay, pn = ...
height = height * 0.5

local colorrange = function(val,range,color1,color2)
    return lerp_color((val/range), color1, color2)
end

local peak, npst, NMeasure, mcount = 0, {}, {}, 0
local verts = {}

local function SongPosition(self, dt)
    self:playcommand("SongPosition")
end


local amv = Def.ActorFrame{
    OnCommand=function(self) 
        self:SetUpdateFunction(SongPosition)
        self:stoptweening():sleep(0.4):queuecommand("RefreshGraph")
        self:visible( GAMESTATE:IsSideJoined(pn) )
    end,

    -- background
    Def.Quad{
        InitCommand=function(self)
            self:diffuse( 0, 0, 0, 0.085 )
            self:zoomto(width, height * 2)
            self:xy(0, 0)
        end,
    },

    -- graph
    Def.ActorMultiVertex{
        OnCommand=function(self)
            self:SetDrawState{Mode="DrawMode_QuadStrip"}
            :xy(0, 0):MaskDest()
        end,
        RefreshGraphCommand=function(self)
            verts = {}
            self:SetNumVertices(#verts):SetVertices(verts)
            if GAMESTATE:GetCurrentSong() and GAMESTATE:IsHumanPlayer(pn) and GAMESTATE:GetCurrentSteps(pn) then
                -- Grab every instance of the NPS data.
                local step = GAMESTATE:GetCurrentSteps(pn)
                local stepcolor = PlayerColor(pn)
                local graphcolor = BoostColor( PlayerColor(pn), 0.2 )
                peak, npst, NMeasure, mcount = LoadModule("Chart.GetNPS.lua")(step)
                if npst then
                    for k,v in pairs( npst ) do
                        -- Each NPS area is per MEASURE. not beat. So multiply the area by 4 beats.
                        local t = step:GetTimingData():GetElapsedTimeFromBeat((k-1)*4)
                        -- With this conversion on t, we now apply it to the x coordinate.
                        local x
                        if gameplay then
                            x = scale( t, GAMESTATE:GetCurrentSong():GetFirstSecond(), 
                            GAMESTATE:GetCurrentSong():GetLastSecond(), -(width/2), (width/2))
                        else
                            x = scale( t, math.min(step:GetTimingData():GetElapsedTimeFromBeat(0), 0), 
                            GAMESTATE:GetCurrentSong():GetLastSecond(), -(width/2), (width/2))
                        end
                        -- Clamp the graph to ensure it will stay within boundaries.
                        if x < -(width/2) then x = -(width/2) end
                        if x > (width/2) then x = (width/2) end
                        -- Now scale that position on v to the y coordinate.
                        local y = math.round( scale( v, 0, peak, height, -height ))
                        local colrange = colorrange( v, peak, graphcolor, stepcolor )
                        -- And send them to the table to be rendered.
                        if #verts > 2 and (verts[#verts][1][2] == y and verts[#verts-2][1][2] == y) then
                            verts[#verts][1][1] = x
                            verts[#verts-1][1][1] = x
                        else
                            if x < (width/2) then
                                verts[#verts+1] = {{x, height, 0}, graphcolor }
                                verts[#verts+1] = {{x, y, 0}, colrange}
                            end
                        end
                    end
                end
            end
            self:SetNumVertices(#verts):SetVertices(verts)
            verts = {} -- To free some memory, let's empty the table.
        end
    },


    -- preview area
    Def.Quad{
        InitCommand=function(self)
            self:diffusealpha(0.2)
            self:zoomto(width, height * 2)
            self:halign(0)
            self:xy(0, 0)
        end,

        RefreshGraphCommand=function(self)
            local song = SelectMusic.song
            if not song then return end
            local start = song:GetSampleStart() / song:GetLastSecond()
            local len = song:GetSampleLength() / song:GetLastSecond()
            self:xy( (-width *0.5) + (start * width), 0)
            self:zoomto( len * width, height * 2)
        end,
    },

    -- preview pointer
    Def.Quad{
        InitCommand=function(self)
            self:zoomto(1, height * 2)
            self:diffusealpha(0.75)
        end,
        
        SongPositionCommand=function(self)
            local song = SelectMusic.song
            if not SelectMusic.song then return end

            local st = SelectMusic.playerSteps[pn]
            if not st then return end

            self:x( scale( GAMESTATE:GetCurMusicSeconds(), 0, song:GetLastSecond(), (-width*0.5), (width*0.5) ))
            self:y( 0 )
        end,
    }
}

return amv