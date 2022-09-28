local top_scores = {
    -- { label = "Last Run", score = nil },
    { label = "Player Best", score = nil },
}

local width = 256
local height = 64
local spacing = 4

local pn = nil

local t = Def.ActorFrame{
    RefreshScoreCommand=function(self,context)
        if not context then return end
        pn = context.Player

        if GAMESTATE:IsSideJoined(pn) then
            local profile = PROFILEMAN:GetProfile(pn)
            -- top_scores[1].score = GetScore(pn, profile, SortScoresByDate )
            top_scores[1].score = GetScore(pn, profile, SortScoresByPercent )
        end

        MESSAGEMAN:Broadcast("ScoreChanged", { Player = pn })
    end
}


function GetScore(pn, profile, sort)
    if not pn then return nil end
    if not SelectMusic.song then return nil end

    local steps = SelectMusic.playerSteps[pn]
    if not steps then return nil end

    local list = profile:GetHighScoreListIfExists( SelectMusic.song,steps )
    if not list then return nil end

    local scores = list:GetHighScores()
    if not scores or #scores < 1 then return nil end

    if sort then
        table.sort( scores, sort )
        return scores[1]
    end

    return scores[1]
end


-- player best
for i = 1, #top_scores do

    t[#t+1] = Def.ActorFrame{
        InitCommand=function(self) 
            self:y((i - #top_scores) * (height + spacing)) 
        end,

        Def.Quad{
            InitCommand=function(self)
                self:zoomto(width, height)
                self:align(0.5, 0)
                self:diffuse( BoostColor( Color.White, 0.085 ))
            end
        },

        -- label
        Def.BitmapText{
            Font = Font.UINormal,
            InitCommand=function(self) 
                self:zoom(0.4):shadowlength(1)
                self:xy(width * -0.5 + 16, 10):align(0, 0)
                self:diffuse( BoostColor( Color.White, 0.5 ))
            end,

            ScoreChangedMessageCommand=function(self, context)
                -- if context and context.Player ~= pn then return end
                self:settext( top_scores[i].label )
            end
        },

        -- award
        Def.BitmapText{
            Font = Font.UINormal,
            InitCommand=function(self) 
                self:zoom(0.425)
                self:shadowlength(1)
                self:diffuse( Color.Blue )
                self:xy(width * -0.5 + 16, 24)
                self:align(0, 0)
            end,

            ScoreChangedMessageCommand=function(self, context)
                local score = top_scores[i] and top_scores[i].score or nil
                local award = score and score:GetStageAward() or nil
                
                self:diffuse( score and PlayerColor(pn) or BoostColor( Color.White, 0.25 ))

                if score then 
                    if award ~= nil then 
                        award = FormatAward(award) 
                    elseif score:GetGrade() == "Grade_Failed" then
                        award = "Failed..."
                        self:diffuse( 1, 0.4, 0.4, 1 )
                    else
                        award = "Clear!"
                    end
                end
                
                self:settext( score and award or "No score" )
            end
        },

        -- date
        Def.BitmapText{
            Font = Font.UINormal,
            InitCommand=function(self) 
                self:zoom(0.35)
                self:shadowlength(1)
                self:diffuse( BoostColor( Color.White, 0.25 ))
                self:xy(width * -0.5 + 16, 40)
                self:align(0, 0)
            end,

            ScoreChangedMessageCommand=function(self, context)
                if context and context.Player ~= pn then return end

                local score = top_scores[i].score
                self:visible( score ~= nil )
                self:settext( score and score:GetDate() or "" )
            end
        },

        -- percent
        Def.BitmapText{
            Font = Font.UIHeavy,
            InitCommand=function(self) 
                self:zoom(0.5)
                self:shadowlength(1)
                self:diffuse( Color.Blue )
                self:xy(width * 0.5 - 16, 10)
                self:align(1, 0)
            end,

            ScoreChangedMessageCommand=function(self, context)
                if context and context.Player ~= pn then return end

                local score = top_scores[i].score
                local percent = string.format( "%.2f", score and score:GetPercentDP() * 100 or 0)
                self:visible( score ~= nil )
                self:settext( percent.."%" )
                self:diffuse( Color.White )
            end
        }
    }

end


-- play count
-- t[#t+1] = Def.ActorFrame{
--     InitCommand=function(self)
--         self:y( (-#top_scores) * (height + spacing) + (height * 0.75 + spacing))
--     end,

--     Def.Quad{
--         InitCommand=function(self)
--             self:zoomto(width, height * 0.333333)
--             self:align(0.5, 0.5)
--             self:diffuse( BoostColor( Color.White, 0.085 ))
--             self:y(1)
--         end
--     },

--     Def.BitmapText{
--         Font = Font.UINormal,
--         Text = "Play count",
--         InitCommand=function(self) 
--             self:zoom(0.375):shadowlength(1)
--             self:x( width * -0.5 + 16 ):align(0, 0.5)
--             self:diffuse( BoostColor( Color.White, 0.5 ))
--         end
--     },

--     Def.BitmapText{
--         Font = Font.UINormal,
--         InitCommand=function(self) 
--             self:zoom(0.375):shadowlength(1)
--             self:x( width * 0.5 - 16 ):align(1, 0.5)
--             self:diffuse( BoostColor( Color.White, 1 ))
--         end,

--         ScoreChangedMessageCommand=function(self, context)
--             if context and context.Player ~= pn then return end
--             local profile = PROFILEMAN:GetProfile(pn)
--             local num_played = SelectMusic.song and profile:GetSongNumTimesPlayed(SelectMusic.song) or 0
--             self:settext( num_played )
--         end
--     },
-- }





return t