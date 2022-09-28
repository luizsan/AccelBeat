local width = 300
local height = 32

local t = Def.ActorFrame{}

for i, pn in ipairs({ PLAYER_1, PLAYER_2 }) do

    local joined = GAMESTATE:IsSideJoined(pn)

    t[#t+1] = Def.ActorFrame{
        InitCommand=function(self)
            self:x(SCREEN_CENTER_X + (width * pnSide(pn)))
            self:y(SCREEN_BOTTOM - height)
        end,

        -- Def.Sprite{
        --     Texture = "../graphics/header_circuits",
        --     InitCommand=function(self)
        --         self:align(0.5, 0.5)
        --         self:zoomx(-0.3 * pnSide(pn))
        --         self:zoomy(-0.3)
        --         self:fadeleft(1)
        --         self:y(-24)
        --         self:x(width * 1.33333 * pnSide(pn))
        --     end,

        --     OnCommand=function(self)
        --         if joined then
        --             self:rainbow()
        --             self:effectperiod(30)
        --         else
        --             self:stopeffect()
        --             self:diffuse(BoostColor(Color.White, 0.25))
        --         end
        --     end
        -- },

        Def.Sprite{
            Texture = "../graphics/player_name",
            InitCommand=function(self)
                self:align(0, 0.5)
                self:zoomx(0.666666 * pnSide(pn))
                self:zoomy(0.666666)
            end,

            OnCommand=function(self)
                local c = joined and 1 or 0.25
                self:diffuse(BoostColor(Color.White, c))
            end
        },


        Def.BitmapText{
            Font = Font.UINormal,
            InitCommand=function(self)
                self:align(pnAlign(pn), 0.5)
                self:zoom(0.425)
                self:x(210 * pnSide(pn))
                self:y(-2)
                self:shadowlengthy(-1.25)
            end,
            
            OnCommand=function(self)
                if joined then
                    self:diffuse(BoostColor(Color.White, 0.1))
                    self:settext(GAMESTATE:GetPlayerDisplayName(pn))
                    self:shadowcolor( Color.White )
                else
                    self:diffuse(BoostColor(Color.White, 0.666666))
                    self:shadowcolor( BoostColor(Color.White, 0.15) )
                    self:settext("Press &CENTER; to join")
                end
            end
        },

        Def.BitmapText{
            Font = Font.UIHeavy,
            InitCommand=function(self)
                self:align(pnAlign(pn), 0.5)
                self:zoom(0.325)
                self:x(236 * pnSide(pn))
                self:y(-1.5)
                self:shadowlengthy(-1.25)
            end,

            OnCommand=function(self)
                self:diffuse(BoostColor(PlayerColor(pn), 0.9))
                self:settext(ToEnumShortString(pn))
                self:shadowcolor( joined and Color.White or Color.Black )
            end
        }

    }

end

return t